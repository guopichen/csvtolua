 
-- xx_csv -> tabel_xx.lua
--require("global_func")

local pairs = pairs
local print = print
local ipairs = ipairs

local split = ";"
local sen_split = "|"

local in_path = "csv"
local out_path = "csvdata"
-- local in_path = "server/GameServer/ServerData/csv"
-- local out_path = "client/csvdata"
local file_type = "csv"

-------------------树形打印table-----------------
local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
function print_t(root)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    print(_dump(root, "",""))
end



-------------------解析csv文件为一个tabel-----------------
-- 去掉字符串左空白  
local function trim_left(s)  
    return string.gsub(s, "^%s+", "");  
end  
  
  
-- 去掉字符串右空白  
local function trim_right(s)  
    return string.match(s,"%s*(.-)%s*$")--string.gsub(s, "%+$", "");  
end  

-- 解析一行  
local function parseline(line)  
    local ret = {};  
  
    local s = line .. ",";  -- 添加逗号,保证能得到最后一个字段  
  
    while (s ~= "") do  
        --print(0,s);  
        local v = "";  
        local tl = true;  
        local tr = true;  
  
        while(s ~= "" and string.find(s, "^,") == nil) do  
            --print(1,s);  
            if(string.find(s, "^\"")) then  
                local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                --print(2,vx,vz);  
                if(vx == nil) then  
                    return nil;  -- 不完整的一行  
                end  
  
                -- 引号开头的不去空白  
                if(v == "") then  
                    tl = false;  
                end  
  
                v = v..vx;  
                s = vz;  
  
                --print(3,v,s);  
  
                while(string.find(s, "^\"")) do  
                    local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                    --print(4,vx,vz);  
                    if(vx == nil) then  
                        return nil;  
                    end  
  
                    v = v.."\""..vx;  
                    s = vz;  
                    --print(5,v,s);  
                end  
  
                tr = true;  
            else  
                local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");  
                --print(6,vx,vz);  
                if(vx~=nil) then  
                    v = v..vx;  
                    s = vz;  
                else  
                    v = v..s;  
                    s = "";  
                end  
                --pr.,int(7,v,s);  
  
                tr = false;  
            end  
        end  
  
        if(tl) then v = trim_left(v); end  
        if(tr) then v = trim_right(v); end
        v = trim_left(v); 
        v = trim_right(v); 
  
        ret[#ret+1] = v;  
        --print(8,"ret["..table.getn(ret).."]=".."\""..v.."\"");  
  
        if(string.find(s, "^,")) then  
            s = string.gsub(s,"^,", "");  
        end  
  
    end  
  
    return ret;  
end  
  
  
  
--解析csv文件的每一行  
local function getRowContent(file)  
    local content;  
  
    local check = false  
    local count = 0  
    while true do  
        local t = file:read()  
        if not t then  if count==0 then check = true end  break end  
  
        if not content then  
            content = t  
        else  
            content = content..t  
        end  
  
        local i = 1  
        while true do  
            local index = string.find(t, "\"", i)  
            if not index then break end  
            i = index + 1  
            count = count + 1  
        end  
  
        if count % 2 == 0 then check = true break end  
    end  
  
    if not check then  assert(1~=1) end  
    return content  
end  
  
  
  
--解析csv文件  
local function LoadCsv(fileName)  
    local ret = {};  
  
     --print("-----"..fileName)
    local file = io.open(fileName, "r")  
    if not file then
		return ret
	end
    while true do  
        local line = getRowContent(file)  
        if not line then break end  
        ret[#ret+1] = parseline(line)  
    end  
    file:close()  
    return ret  
end 



local function Split(szFullString, szSeparator)  
    local nFindStartIndex = 1  
    local nSplitIndex = 1  
    local nSplitArray = {}  
    while true do  
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
       if not nFindLastIndex then  
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
        if nSplitIndex == 1 then nSplitArray = nil end -- 没有可分割的
        break  
       end
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
       nSplitIndex = nSplitIndex + 1  
    end  
    return nSplitArray  
end 

------------------- 解析从csv读取出来的tabel -------------------

local function prase_csvtabel( t, out_t )
    --
    out_t["keyword"] = {}

    local col_line = 1
    for i=1, #t do
        if t[i][1] == "ID" then -- "ID"前的行 不读取
            col_line = i
            break
        end
    end
    -- print("col_line =="..col_line)


    local keys = t[col_line]
    local max_col_len = #keys 
    for i=2, max_col_len do
      local key = keys[i]
      
      if key ~= "" then     -- 没有key值的列不读
        -- print("key: "..key)
        out_t["keyword"][key] = i - 1
        end
    end
    
    for line=2, #t do -- 忽略第一个id
        -- print("-----line : "..line)
        local values = t[line]
        local id = values[1]
        if id ~= "" and line>col_line-1 then --ID之前的行不写入
            out_t[id] = {}
            for col=2,#values do
                if col>max_col_len then break end
              local value = values[col]
              -- if value ~= "" then 空的也要写入文件, 否则会错位
              if keys[col] ~= ""  then -- 没有ID的列不写入
                -- print("id = "..id.."  ".."value: "..value.." col = "..col.." line = "..line)
                local sec_list = Split(value,sen_split)
                if not sec_list then 
                    local list_value = Split(value, split)
                    if not list_value then
                        table.insert(out_t[id],value)
                    else
                        -- print("list_value")
                        table.insert(out_t[id],list_value)
                    end

                else -- 有二级分隔符
                    local tab = {}
                    for k_s,v_s in pairs(sec_list) do
                        local list = Split(v_s, split)
                        print("k_s: "..k_s)

                        -- table.insert(tab[k_s],v_f)
                        tab[k_s] = {}
                        for k_f,v_f in pairs(list) do -- 若此行报错,则说明csv表的分隔符不对
                            print("k: "..k_f.." v: "..v_f)
                            table.insert(tab[k_s],v_f)
                        end
                        -- if not list_value then
                        --     table.insert(out_t[id],v)
                        -- else
                            -- print("k: "..k.." v: "..v)
                            -- table.insert(tab,)
                        -- end
                    end
                    table.insert(out_t[id],tab)
                    -- print("hhahaha")
                    -- print_t(out_t[id])
                end

                
              end
            end
        end
  end

  -- print("\n\n out: ")
  -- print_t(out_t)
end

-------------------存储tabel到文件(return t 的格式)-----------------

local function save_table_content( file, obj )
     local szType = type(obj);
      if szType == "number" then
            file:write(obj);
      elseif szType == "string" then
            file:write(string.format("%q", obj));
      elseif szType == "table" then
            --把table的内容格式化写入文件
            file:write("{\n");
            for k, v in pairs(obj) do
                if type(k) == "number" then
                    save_table_content(file, v);
                else
                    file:write("[");
                    save_table_content(file, k);
                    file:write("]");
                    file:write(" = ");
                    save_table_content(file, v);
                end
            file:write(",\n");
            end
            file:write("}");
      else
      error("can't serialize a "..szType);
      end
end



--
local function saveto_luatabel( filename, t, path, keys )
    -- local aaa = path..filename
    print( path .. filename )
    local file = io.open(path..filename, "w");
    assert(file);
    -- print(filename)
    file:write("local t =\n")
    save_table_content(file, t, keys);
    file:write("\n")

    local function save_tab_fun()
        file:write("t.get = function (id, key) if not (t[id] and t.keyword[key]) then return nil end return t[id][t.keyword[key]] end\n")
    end
    save_tab_fun()
    -- file:write("\n")
    file:write("return t")
    file:close();
end


function load_filenames(directory,type,t)
   local i, popen = 0, io.popen
   -- for filename in popen('dir /B "'..directory..'"'):lines() do  --windows
   for filename in popen('ls  "'..directory..'"'):lines() do -- Linux 
      i = i + 1
      local a = string.find(filename,"."..type)
               if a~=nil then  
                    t[i] = string.sub(filename,0,a-1) 
                end  
   end
   return t
end


local function save_game_tab( filename, filenames, path, keys )
    local file = io.open(path..filename, "w");
    assert(file);
    -- print(filename)
    file:write("local t =\n {")
    for k,v in ipairs(filenames) do
        file:write('["'..v..'"]')
        -- file:write(' = import ("'..'app.'..out_path..'.') -- import
        -- file:write(' = import ("'..out_path..'.') -- import
            file:write(' = import ("csvdata'..'.') -- import
        file:write(v..'")')
        file:write(",\n")
    end
    file:write(" }")
    file:write("\n")
    file:write("return t \n")
    file:close();
end

------------------------------------------------------------------------

local function rnil( s )
    if s == nil then return ""
    else return s end
end

local function createWave( t )
    local stage = {}

    local i_wave = 0
    for k ,v in pairs(t) do
        print("in table ............................... line # " .. k ) -- 当前遍历的排数
        
        for kk ,vv in pairs(v) do
            if tostring(vv) == "tag" then
                i_wave = 1 + i_wave
                print( "found the wave # " .. i_wave )
                stage[i_wave] = {} -- 创建一个新的 wave teble
                --else print("it's not tag , it is " .. vv )

                stage[i_wave][1] = { rnil(t[k][2]) , rnil(t[k][3]) , rnil(t[k][4]) , rnil(t[k][5]) , rnil(t[k][6]) , rnil(t[k][7]) , rnil(t[k][8]) , }
                
                if t[k + 1] == nil then t[k + 1] = { "" , "" , "" , "" , "" , "" , "" , } end
                if t[k + 2] == nil then t[k + 2] = { "" , "" , "" , "" , "" , "" , "" , } end
                if t[k + 3] == nil then t[k + 3] = { "" , "" , "" , "" , "" , "" , "" , } end

                stage[i_wave][2] = { rnil(t[k + 1][2]) , rnil(t[k + 1][3]) , rnil(t[k + 1][4]) , rnil(t[k + 1][5]) , rnil(t[k + 1][6]) , rnil(t[k + 1][7]) , rnil(t[k + 1][8]) , }
                stage[i_wave][3] = { rnil(t[k + 2][2]) , rnil(t[k + 2][3]) , rnil(t[k + 2][4]) , rnil(t[k + 2][5]) , rnil(t[k + 2][6]) , rnil(t[k + 2][7]) , rnil(t[k + 2][8]) , }
                stage[i_wave][4] = { rnil(t[k + 3][2]) , rnil(t[k + 3][3]) , rnil(t[k + 3][4]) , rnil(t[k + 3][5]) , rnil(t[k + 3][6]) , rnil(t[k + 3][7]) , rnil(t[k + 3][8]) , }
            end
        end
    end

    return stage
end

local function toluastring(mon)
    if mon == "" then return ( "''" )
    else
        local list = Split( mon , ";")
        local size = Split( list[2] , "|")
        local sizes = "{ " .. size[1] .. " , " .. size[2] .. " }"
        return ("{ " .. list[1] .. " , " .. sizes .. " , " .. "'" .. list[3] .. "'" .. " , " .. list[4] .. " }")
        
    end
end


local function save_stage( filename , stage )
    local file = io.open(out_path.."/stage/"..filename..".lua", "w");
    assert(file)
    file:write("local stage = {\n")
    -------------------------------------
    for k_wave ,wave in pairs(stage) do
        file:write("\n    {\n")
        -------------------------------------
        for k_line ,line in pairs(wave) do
            file:write("        { ")
            for k_mon ,mon in pairs(line) do
                file:write( toluastring(mon) .. " , " )
            end
            file:write("} ,\n")
        end
        -------------------------------------
        file:write("    } ,\n")
    end
    -------------------------------------
    file:write("}\n\nreturn stage")
    --[[
    -- print(filename)
    file:write("local t =\n {")
    for k,v in ipairs(filenames) do
        file:write('["'..v..'"]')
        file:write(' = import ("'..'app.'..out_path..'.') -- import
        file:write(v..'")')
        file:write(",\n")
    end
    file:write(" }")
    file:write("\n")
    file:write("return t \n")]]
    file:close();
end

-------------------------------------------


local function run_stage()
    -- 定义
    local file_count = 0
    local files = {}
	local stagePath = in_path .. '/stage/'
    load_filenames( inpath,file_type, files)
    os.execute("mkdir " .. out_path )
    local out_t = {}
    local filenames = {}

    local i = 1
    for key, value in pairs(files) do
        if value ~= nil then
            print( "found a new file ! # " .. i )
            print( "file name is " .. '"' .. value .. '"' )
            i = i + 1
            t = LoadCsv( stagepath..value..".csv")
            
            local newstage = createWave( t )
            save_stage( value , newstage )
            
        end
    end
end

--------------------------------------------------------------------

local function run(  )
    -- 定义
    local file_count = 0
    local files = {}
    load_filenames( in_path,file_type, files)
    -- os.execute("mkdir client\\csvdata") -- windows
    os.execute('mkdir '..out_path) -- Linux
    local out_t = {}
    local filenames = {}
    for key, value in pairs(files) do
        local name = value
        t = LoadCsv(in_path.."/"..name..".csv")
        prase_csvtabel(t,out_t)
        saveto_luatabel(name..".lua",out_t,out_path .. "/", t)
        out_t = {} -- 置空
        out_keys = {}
        file_count = file_count + 1

        filenames[file_count] = name
    end 
    save_game_tab("csvdatas.lua",filenames,out_path .. "/",t)
    print( "file amount: " .. file_count )
end

run()
-- run_stage()






