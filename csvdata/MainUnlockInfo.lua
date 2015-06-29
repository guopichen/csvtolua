local t =
{
["2"] = {
{
"MenuBack",
"PartyMenu_Soldier",
},
"10",
"MainUnlock10",
"MainUnlock",
"FrameChooseButtonLock",
"MainUI",
},
["3"] = {
{
"MenuButtonBack",
"ButtonDuel",
},
"15",
"MainUnlock15",
"MainUnlock",
"FrameChooseButtonLock",
"MainUI",
},
["keyword"] = {
["UnlockLv"] = 2,
["PlistPic"] = 4,
["LockPist"] = 6,
["LockPic"] = 5,
["Details"] = 1,
["UnitPic"] = 3,
},
["1"] = {
{
"MenuButtonBack",
"ButtonLottery",
},
"3",
"MainUnlock5",
"MainUnlock",
"FrameChooseButtonLock",
"MainUI",
},
}
t.get = function (id, key) if not (t[id] and t.keyword[key]) then return nil end return t[id][t.keyword[key]] end
return t