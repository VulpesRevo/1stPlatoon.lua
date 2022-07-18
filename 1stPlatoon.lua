script_name('Script for personnel of the First platoon')
script_author("Vulpes_Inculta - https://vk.com/volkodavpizdec")
local V = 1.1
local updating = false

local ev = require 'samp.events'
local inicfg = require 'inicfg'
local vkeys = require 'vkeys'
local regex = require 'rex_pcre'
local dlstatus = require('moonloader').download_status
local requests = require('requests')
local freereq = true
local req_index = 0
local font_flag = require('moonloader').font_flag
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local authorized = false
local noffmembers = {}

local CONFIG = {
	CONFIG = {['PASSWORD'] = ""}
}

local FirstPlatoonPassword_ini = inicfg.load(CONFIG, "FirstPlatoonPassword.ini") --  
if os.remove("" .. thisScript().directory .. "\\config\\FirstPlatoonPassword.ini") ~= nil then 
	inicfg.save(CONFIG, "FirstPlatoonPassword.ini")
end

function main()
	
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ", 0xFF008B8B)
	
	checkupdate()
	checkaccess()
	
	while sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) <= 0 do wait(0) end
	while not sampIsLocalPlayerSpawned() do wait(0) end
end

function onScriptTerminate(s, bool)
	if s == thisScript() and not bool then
		print("#PathForReload " .. thisScript().path .. " @#")
		if not updating then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .      (~)   .  CTRL + R  .", 0xFF008B8B) end
	end
end

function checkupdate()
	local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkupdate')
	local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Info: (.*)@@.@") --
	local ver, url, inf = re0:match(responsetext)
	if tonumber(ver) == nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}     ", 0xFF008B8B) thisScript():unload() return end
	if tonumber(ver) > V then 
		updating = true 
		sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  ,   ...", 0xFF008B8B) 
		updatescript(url, ver, inf) 
	end
end

function updatescript(url, ver, inf)
	local u = url
	local upd = inf
	if u == nil or upd == nil then
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkupdate')
		local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Info: (.*)@@.@") --
		local ver, url2, inf2 = re0:match(responsetext)
		if ver == nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}     ", 0xFF008B8B) thisScript():unload() return end
		u = url2
		upd = inf2
	end
	u = u:gsub("\\", "")
	local file_path = getWorkingDirectory() .. '/1stPlatoon.lua'
	local responsetext = req(u)
	os.remove(file_path)
	
	local luascript = io.open(file_path, "a")
	luascript:write(responsetext)
	luascript:close()
	
	sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  ,  :", 0xFF008B8B)
	sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}" .. upd .. ",  ...", 0xFF008B8B)
	os.remove(thisScript().path) 
	
	script.load("Moonloader\\1stPlatoon.lua") 
	thisScript():unload() 
	return
end

function checkaccess()
lua_thread.create(function()

while sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) <= 0 do wait(0) end
while not sampIsLocalPlayerSpawned() do wait(0) end

local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
local f, s = mynick:match("(.*)%_(.*)")
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkaccess&nick=' .. mynick .. '')
local re1 = regex.new("@@.@ Access allowed @@..@.@") --
if re1:match(responsetext) == nil then
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}!   !", 0xFF008B8B)
sendtolog(' ', getTime())
thisScript():unload()
return
end
sampRegisterChatCommand("getinfo", cmd_getinfo)
sampRegisterChatCommand("add", cmd_add)
sampRegisterChatCommand("dell", cmd_dell)
sampRegisterChatCommand("rss", cmd_rss)
sampRegisterChatCommand("register", cmd_register)
sampRegisterChatCommand("login", cmd_login)
sampRegisterChatCommand("changepassword", cmd_changepassword)
access = true
sendtolog(' ', getTime())
authorization()
local responsetext = req("https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=offmembers")
local offmembers = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
for k, v in ipairs(offmembers:split("],[")) do
local name, rank, otmd, otmw = v:match(".(%w+_%w+).%,(%d+)%,%[(%d+)%,(%d+)%]%,.%d+%/%d+%/%d+ %d+%:%d+%:%d+.")
table.insert(noffmembers, name)
end
end)
end

function cmd_login(sparams)
if sparams == "" then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .  /login [password]", 0xFF008B8B) return end
lua_thread.create(function()
local password = sparams
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
local f, s = mynick:match("(.*)%_(.*)")
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  ...", 0xFF008B8B)
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkpassword&nick=' .. mynick .. '&password=' .. password .. '')
local re1 = regex.new("@@.@ No access for this @@..@.@") --
local re2 = regex.new("@@.@ No password @@..@.@") --
local re3 = regex.new("@@.@ Password is correct @@..@.@") --
local re4 = regex.new("@@.@ Password is wrong @@..@.@") --
local name1 = re1:match(responsetext)
local name2 = re2:match(responsetext)
local name3 = re3:match(responsetext)
local name4 = re4:match(responsetext)
if name1 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}      !", 0xFF008B8B) sendtolog(' /LOGIN', getTime()) return end
if name2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  ...", 0xFF008B8B) newpassword(password) return end
if name4 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,  /login [password]     !", 0xFF008B8B) sendtolog(' /LOGIN', getTime()) return end
if name3 ~= nil then 
authorized = true 
FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = password 
inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini") 
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,  " .. s .. '', 0xFF008B8B)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  - /getinfo", 0xFF008B8B)
sendtolog(' /LOGIN', getTime())
return 
end
end)
end

function cmd_register(sparams)
if sparams == "" then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .  /register [password]", 0xFF008B8B) return end
newpassword(sparams)
end

function cmd_changepassword(sparams)
local params = {}
for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
local id = -1
if params[1] == nil or params[1] == '' or params[2] == nil or params[2] == '' then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .  /changepassword [oldpassword] [newpassword]", 0xFF008B8B) return end
local oldpassword = params[1]
local newpassword = params[2]
lua_thread.create(function()
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  ...", 0xFF008B8B)
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=changepassword&nick=' .. mynick .. '&oldpassword=' .. oldpassword .. '&newpassword=' .. newpassword .. '')
local re1 = regex.new("@@.@ No access for this @@..@.@") --
local re2 = regex.new("@@.@ Old password is wrong @@..@.@") --
local re3 = regex.new("@@.@ Password wasn't changed @@..@.@") --
local re4 = regex.new("@@.@ Password was changed @@..@.@") --
local name1 = re1:match(responsetext)
local name2 = re2:match(responsetext)
local name3 = re3:match(responsetext)
local name4 = re4:match(responsetext)
if name1 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}      !", 0xFF008B8B) sendtolog(' /CHANGEPASSWORD', getTime()) return end
if name2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  - !", 0xFF008B8B) sendtolog(' /CHANGEPASSWORD', getTime()) return end
if name3 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,   !", 0xFF008B8B) sendtolog(' /CHANGEPASSWORD', getTime()) return end
if name4 ~= nil then
FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = newpassword
inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini")
authorized = false 
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  ...", 0xFF008B8B)
sendtolog(' /CHANGEPASSWORD', getTime())
authorization()
return 
end
end)
end

function authorization()
lua_thread.create(function()
local password = FirstPlatoonPassword_ini.CONFIG['PASSWORD']
if FirstPlatoonPassword_ini.CONFIG['PASSWORD'] == '' then
if not showdialog(1, "  ", "    -  ;         !!!", "OK") then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,  /login [password]", 0xFF008B8B) return end
password = waitForChooseInDialog(1)
if not password or password == "" then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  ,  /login [password]", 0xFF008B8B) return end
end
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
local f, s = mynick:match("(.*)%_(.*)")
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkpassword&nick=' .. mynick .. '&password=' .. password .. '')
local re1 = regex.new("@@.@ No access for this @@..@.@") --
local re2 = regex.new("@@.@ No password @@..@.@") --
local re3 = regex.new("@@.@ Password is correct @@..@.@") --
local re4 = regex.new("@@.@ Password is wrong @@..@.@") --
local name1 = re1:match(responsetext)
local name2 = re2:match(responsetext)
local name3 = re3:match(responsetext)
local name4 = re4:match(responsetext)
if name1 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}      !", 0xFF008B8B) sendtolog(' /LOGIN', getTime()) return end
if name2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  ...", 0xFF008B8B) newpassword(password) return end
if name4 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,  /login [password]     !", 0xFF008B8B) sendtolog(' /LOGIN', getTime()) return end
if name3 ~= nil then
FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = password
inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini")
authorized = true 
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,  " .. s .. '', 0xFF008B8B)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  - /getinfo", 0xFF008B8B)
sendtolog(' /LOGIN', getTime()) 
return end
end)
end

function newpassword(password)
if password ~= nil then
lua_thread.create(function()
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  ...", 0xFF008B8B)
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=newpassword&nick=' .. mynick .. '&password=' .. password .. '')
local re1 = regex.new("@@.@ No access for this @@..@.@") --
local re2 = regex.new("@@.@ Password wasn't added @@..@.@") --
local re3 = regex.new("@@.@ Password was created @@..@.@") --
local name1 = re1:match(responsetext)
local name2 = re2:match(responsetext)
local name3 = re3:match(responsetext)
if name1 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}      !", 0xFF008B8B) sendtolog(' /REGISTER', getTime()) return end
if name2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /register [password]", 0xFF008B8B) sendtolog(' /REGISTER', getTime()) return end
if name3 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  ,  ...", 0xFF008B8B)
FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = password
inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini")
sendtolog(' /REGISTER', getTime())
authorization()
return 
end
end)
end
end

function cmd_getinfo()
sampShowDialog(9999, "{FFFFFF}  ", string.format("/add [id/nick] -   \n/dell [id/nick] -   \n/rss -  \n/login [] -  \n/register [] -  \n/changepassword [] [] -  "), "", "", 2)
end
function cmd_add(sparams)
lua_thread.create(function()
if sparams == "" then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .  /add [id/nick] ([])", 0xFF008B8B) return end
local params = {}
for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
local id = -1
if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ", 0xFF008B8B) return end
local soldier = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
local who = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=add&nick=' .. soldier .. '&who=' .. who .. (params[2] ~= nil and '&text=' .. translit(strrest(params, 2)) .. '' or '') .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
local re1 = regex.new("@@.@ Player was added @@..@.@") --
local re2 = regex.new("@@.@ No access @@..@.@") --
local names1 = re1:match(responsetext)
local names2 = re2:match(responsetext)
if names2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /login [password]", 0xFF008B8B) sendtolog('  ' .. soldier .. '', getTime()) return end
sendtolog(' ' .. soldier .. '', getTime())
if names1 ~= nil then 
printStringNow("~g~~h~ ADD TO TABLE " .. soldier .. "", 10000)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B) else
printStringNow("~g~~h~ ADD TO TABLE " .. soldier .. "", 10000)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B)
return
end
end)
end
function cmd_dell(sparams)
lua_thread.create(function()
if sparams == "" then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .  /dell [id/nick]", 0xFF008B8B) return end
local params = {}
for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
local id = -1
if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ", 0xFF008B8B) return end
local soldier = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. soldier .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
local re2 = regex.new("@@.@ No access @@..@.@") --
local names1 = re1:match(responsetext)
local names2 = re2:match(responsetext)
if names2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /login [password]", 0xFF008B8B) sendtolog('  ' .. soldier .. '', getTime()) return end
sendtolog(' ' .. soldier .. '', getTime())
if names1 ~= nil then 
printStringNow("~r~~h~ DELL FROM TABLE " .. soldier .. "", 10000)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B) else
printStringNow("~r~~h~ DELL FROM TABLE " .. soldier .. "", 10000)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B)
return
end
end)
end
function cmd_rss(sparams)
lua_thread.create(function()
--if sparams == "" then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .  /rss [ (1-10)] [()]", 0xFF008B8B) sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}1 - ; 2 - ; 3 - ; 4 - ; 5 - ; 6 - ; 7 - ; 8 - ; 9 - ; 10 - ", 0xFF008B8B) return end
--local params = {}
--for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
--local zzz = {[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = ""}
--if tonumber(params[1]) == nil or zzz[tonumber(params[1])] == nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  .", 0xFF008B8B) return end
--local num = tonumber(params[1])
local res2 = ''
local res3 = ''
--if tonumber(params[2]) ~= nil then if tonumber(params[2]) < 1 then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  .", 0xFF008B8B) return end fond = params[2] end
if not showdialog(1, "  ", "1 - ; 2 - ; 3 - ; 4 - ; 5 - ; 6 - ; 7 - ; 8 - ; 9 - ; 10 - ; 11 - ", "OK") then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,   ", 0xFF008B8B) return end
local res1 = waitForChooseInDialog(1)
if not res1 or res1 == "" then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  .", 0xFF008B8B) return end
local zzz = {[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = "", [11] = ""}
if tonumber(res1) == nil or zzz[tonumber(res1)] == nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  .", 0xFF008B8B) return end
if not showdialog(1, " ", "  ,      :", "OK") then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,   ", 0xFF008B8B) return end
local res2 = waitForChooseInDialog(1)
if not res2 then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  .", 0xFF008B8B) return end
if tonumber(res2) ~= nil then if tonumber(res2) < 1 then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  .", 0xFF008B8B) return end end
if not showdialog(1, "  ()", ":", "OK") then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} ,   ", 0xFF008B8B) return end
local res3 = waitForChooseInDialog(1)
if not res3 then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}  .", 0xFF008B8B) return end
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}     ...", 0xFF008B8B)
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=rss&type=' .. translit(zzz[tonumber(res1)]) .. '&nick=' .. mynick .. (res3 ~= '' and '&theme=' .. translit(res3) .. '' or '&theme=') .. (res2 ~= '' and '&fond=' .. translit(res2) .. '' or '&fond=') .. '&time=' .. getTime() .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
local re1 = regex.new("@@.@ RSS was added @@..@.@") --
local re2 = regex.new("@@.@ RSS is already added @@..@.@") --
local re3 = regex.new("@@.@ No access @@..@.@") --
local names1 = re1:match(responsetext)
local names2 = re2:match(responsetext)
local names3 = re3:match(responsetext)
if names3 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /login [password]", 0xFF008B8B) sendtolog('  ' .. zzz[tonumber(res1)] .. '', getTime()) return end
sendtolog(' ' .. zzz[tonumber(res1)] .. '', getTime())
if names1 ~= nil then
printStringNow("~g~~h~ RSS WAS ADDED", 10000)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   !      !!!", 0xFF008B8B) return end
if names2 ~= nil then 
printStringNow("~g~~h~ RSS WAS ADDED", 10000)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   !      !!!", 0xFF008B8B) else
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   !   !", 0xFF008B8B)
return
end
end)
end


function showdialog(style, title, text, button1, button2)
if isDialogActiveNow then return false end
sampShowDialog(9048, title, text, button1, button2, style)
isDialogActiveNow = true
return true
end

function waitForChooseInDialog(style)
if style ~= 0 and style ~= 1 and style ~= 2 then return nil end
while sampIsDialogActive(9048) do wait(100) end
local result, button, list, input = sampHasDialogRespond(9048)
returnWalue = style == 1 and input or list
isDialogActiveNow = false
if style == 0 or button == 0 then return nil end
return returnWalue
end

function ev.onServerMessage(col, text)
if authorized then
if col == -1613968897 then
if text:match('%[%] (%a+_%a+)%[%d+%] %{00AB06%}%{9FCCC9%}   (%a+_%a+)') then
who, soldier = text:match('%[%] (%a+_%a+)%[%d+%] %{00AB06%}%{9FCCC9%}   (%a+_%a+)')
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
if mynick == who then
lua_thread.create(function()
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=add&nick=' .. soldier .. '&who=' .. who .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
local re1 = regex.new("@@.@ Player was added @@..@.@") --
local re2 = regex.new("@@.@ No access @@..@.@") --
local names1 = re1:match(responsetext)
local names2 = re2:match(responsetext)
if names2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /login [password]", 0xFF008B8B) return end
sendtolog(' ' .. soldier .. '', getTime())
if names1 ~= nil then
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B) else
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B)
return
end
end)
end
end
if text:match('%[%] (%a+%_%a+)%[%d+%] %{C42100%}%{9FCCC9%} (%a+%_%a+)  ') then
who, soldier = text:match('%[%] (%a+%_%a+)%[%d+%] %{C42100%}%{9FCCC9%} (%a+%_%a+)  ')
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
if mynick == who then
lua_thread.create(function()
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. soldier .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
local re2 = regex.new("@@.@ No access @@..@.@") --
local names1 = re1:match(responsetext)
local names2 = re2:match(responsetext)
if names2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /login [password]", 0xFF008B8B) sendtolog('  ' .. soldier .. '', getTime()) return end
sendtolog(' ' .. soldier .. '', getTime())
if names1 ~= nil then
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B) else
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B)
return
end
end)
end
end
if text:match('%[%] (.*)%[%d+%] %{C42100%}%{9FCCC9%} ') then
soldier = text:match('%[%] (.*)%[%d+%] %{C42100%}%{9FCCC9%} ')
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
lua_thread.create(function()
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. soldier .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
local re2 = regex.new("@@.@ No access @@..@.@") --
local names1 = re1:match(responsetext)
local names2 = re2:match(responsetext)
if names2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /login [password]", 0xFF008B8B) sendtolog('  ' .. soldier .. '', getTime()) return end
sendtolog(' ' .. soldier .. '', getTime())
if names1 ~= nil then
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B) else
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. soldier .. "     ", 0xFF008B8B)
return
end
end)
end
end
if text:match('%a+%_%a+  (%a+%_%a+)  %. %: .+') and col == 1790050303 then
uvalnick = text:match('%a+%_%a+  (%a+%_%a+)  %. %: .+')
sampAddChatMessage("{008B8B}[ 1]: {fffafa}  " .. uvalnick .. ".     ?", 0xFF008B8B)
sampAddChatMessage("{008B8B}[ 1]: {fffafa} Y    N  ", 0xFF008B8B)
lua_thread.create(function()
while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .", 0xFF008B8B) return end end
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. uvalnick .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
local re2 = regex.new("@@.@ No access @@..@.@") --
local names1 = re1:match(responsetext)
local names2 = re2:match(responsetext)
if names2 ~= nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   ,  /login [password]", 0xFF008B8B) sendtolog('  ' .. uvalnick .. '', getTime()) return end
sendtolog(' ' .. soldier .. '', getTime())
if names1 ~= nil then
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. uvalnick .. "     ", 0xFF008B8B) else
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} " .. uvalnick .. "     ", 0xFF008B8B)
return
end
end)
end
if text:match("%a+%_%a+ %(%)    %: (%a+%_%a+) %>%> (%a+%_%a+)") then ---------     Binder for CO by Belka.lua
local oldnick, newnick = text:match("%a+%_%a+ %(%)    %: (%a+%_%a+) %>%> (%a+%_%a+)")
if oldnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
for k, v in ipairs(noffmembers) do
if oldnick == v then
sampAddChatMessage("{008B8B}[ 1]: {fffafa}    " .. oldnick .. " >> " .. newnick .. "", 0xFF008B8B)
sampAddChatMessage("{008B8B}[ 1]: {fffafa}     .  Y    N  ", 0xFF008B8B)
lua_thread.create(function()
while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA} .", 0xFF008B8B) return end end
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=changenick&oldnick=' .. oldnick .. '&newnick=' .. newnick .. '')
local re1 = regex.new("@@.@ Nick was changed @@..@.@") --
local names = re1:match(responsetext)
if names == nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}     .", 0xFF008B8B) else sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}    .", 0xFF008B8B)
sendtolog('  ' .. oldnick .. ' >> ' .. newnick.. '', getTime())
return
end
end)
end
end
end
end
if col == -65281 then ---------     Binder for CO by Belka.lua
local newnick = text:match('   %" (%a+_%a+) %"%.     SA%-MP%,   %"Name%"')
if newnick ~= nil then
lua_thread.create(function()
sampAddChatMessage("{008B8B}[ 1]: ! {FFFAFA}   .", 0xFF008B8B)
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}     . {FF0000}   !!!", 0xFF008B8B)
local A_Index = 0
while true do
if A_Index == 20 then break end
local text = sampGetChatString(99 - A_Index)

local oldnick = text:match("%a+%_%a+ %(%)    %: (%a+%_%a+) %>%> " .. newnick .. "")
if oldnick ~= nil then
local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=changenick&oldnick=' .. oldnick .. '&newnick=' .. newnick .. '')
local re1 = regex.new("@@.@ Nick was changed @@..@.@") --
local names = re1:match(responsetext)
if names == nil then sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}      .", 0xFF008B8B) else sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}    .", 0xFF008B8B) end 
sampAddChatMessage("{008B8B}[ 1]: {FFFAFA}   .", 0xFF008B8B)
sendtolog('  ' .. oldnick .. ' >> ' .. newnick.. '', getTime())
return 
end
A_Index = A_Index + 1
end
end)
return false
end
end
end
end

function getTime()
return os.date('!%H:%M', os.time() + 3 * 60 * 60)
end

function sendtolog(action, ctime)
lua_thread.create(function()
local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
local text = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=sendtolog&nick=' .. mynick .. '&text=' .. translit(action) .. '&time=' .. ctime .. '')
if action == ' /LOGIN' then
if sampGetPlayerIdByNickname('Vulpes_Inculta') ~= nil then
wait(1700)
sampSendChat('/t ' .. sampGetPlayerIdByNickname('Vulpes_Inculta') .. ' [ !]')
end
end
end)
while not sysdownloadcomplete do wait(0) end
end

function strrest(arr, index)
local result = ""
local A_Index = 1
for k, v in ipairs(arr) do if A_Index >= index then result = result == "" and v or "" .. result .. " " .. v .. "" end A_Index = A_Index + 1 end
return result
end

function indexof(var, arr)
for k, v in ipairs(arr) do if v == var then return k end end return false
end

function sampGetPlayerIdByNickname(nick)
local _, myid = sampGetPlayerIdByCharHandle(playerPed)
if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function translit(str)
if str:match("") then str = str:gsub("", "[[a]]") end
if str:match("") then str = str:gsub("", "[[b]]") end
if str:match("") then str = str:gsub("", "[[v]]") end
if str:match("") then str = str:gsub("", "[[g]]") end
if str:match("") then str = str:gsub("", "[[d]]") end
if str:match("") then str = str:gsub("", "[[e]]") end
if str:match("") then str = str:gsub("", "[[yo]]") end
if str:match("") then str = str:gsub("", "[[zh]]") end
if str:match("") then str = str:gsub("", "[[z]]") end
if str:match("") then str = str:gsub("", "[[i]]") end
if str:match("") then str = str:gsub("", "[[j]]") end
if str:match("") then str = str:gsub("", "[[k]]") end
if str:match("") then str = str:gsub("", "[[l]]") end
if str:match("") then str = str:gsub("", "[[m]]") end
if str:match("") then str = str:gsub("", "[[n]]") end
if str:match("") then str = str:gsub("", "[[o]]") end
if str:match("") then str = str:gsub("", "[[p]]") end
if str:match("") then str = str:gsub("", "[[r]]") end
if str:match("") then str = str:gsub("", "[[s]]") end
if str:match("") then str = str:gsub("", "[[t]]") end
if str:match("") then str = str:gsub("", "[[u]]") end
if str:match("") then str = str:gsub("", "[[f]]") end
if str:match("") then str = str:gsub("", "[[x]]") end
if str:match("") then str = str:gsub("", "[[cz]]") end
if str:match("") then str = str:gsub("", "[[ch]]") end
if str:match("") then str = str:gsub("", "[[sh]]") end
if str:match("") then str = str:gsub("", "[[shh]]") end
if str:match("") then str = str:gsub("", "[[``]]") end
if str:match("") then str = str:gsub("", "[[y']]") end
if str:match("") then str = str:gsub("", "[[`]]") end
if str:match("") then str = str:gsub("", "[[e`]]") end
if str:match("") then str = str:gsub("", "[[yu]]") end
if str:match("") then str = str:gsub("", "[[ya]]") end
if str:match("") then str = str:gsub("", "[[A]]") end
if str:match("") then str = str:gsub("", "[[B]]") end
if str:match("") then str = str:gsub("", "[[V]]") end
if str:match("") then str = str:gsub("", "[[G]]") end
if str:match("") then str = str:gsub("", "[[D]]") end
if str:match("") then str = str:gsub("", "[[E]]") end
if str:match("") then str = str:gsub("", "[[YO]]") end
if str:match("") then str = str:gsub("", "[[ZH]]") end
if str:match("") then str = str:gsub("", "[[Z]]") end
if str:match("") then str = str:gsub("", "[[I]]") end
if str:match("") then str = str:gsub("", "[[J]]") end
if str:match("") then str = str:gsub("", "[[K]]") end
if str:match("") then str = str:gsub("", "[[L]]") end
if str:match("") then str = str:gsub("", "[[M]]") end
if str:match("") then str = str:gsub("", "[[N]]") end
if str:match("") then str = str:gsub("", "[[O]]") end
if str:match("") then str = str:gsub("", "[[P]]") end
if str:match("") then str = str:gsub("", "[[R]]") end
if str:match("") then str = str:gsub("", "[[S]]") end
if str:match("") then str = str:gsub("", "[[T]]") end
if str:match("") then str = str:gsub("", "[[U]]") end
if str:match("") then str = str:gsub("", "[[F]]") end
if str:match("") then str = str:gsub("", "[[X]]") end
if str:match("") then str = str:gsub("", "[[CZ]]") end
if str:match("") then str = str:gsub("", "[[CH]]") end
if str:match("") then str = str:gsub("", "[[SH]]") end
if str:match("") then str = str:gsub("", "[[SHH]]") end
if str:match("") then str = str:gsub("", "[[``]]") end
if str:match("") then str = str:gsub("", "[[Y']]") end
if str:match("") then str = str:gsub("", "[[`]]") end
if str:match("") then str = str:gsub("", "[[E`]]") end
if str:match("") then str = str:gsub("", "[[YU]]") end
if str:match("") then str = str:gsub("", "[[YA]]") end
return str
end

function string.split(str, delim, plain) -- bh FYP
local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
repeat
local npos, epos = string.find(str, delim, pos, plain)
table.insert(tokens, string.sub(str, pos, npos and npos - 1))
pos = epos and epos + 1
until not pos
return tokens
end

function strunsplit(str, delim)
local str = string.split(str, " ")
local estr = {[1] = ""}
local A_Index = 1
for k, i in ipairs(str) do
if #estr[A_Index] + #i > delim then A_Index = A_Index + 1 estr[A_Index] = "" end    
estr[A_Index] = estr[A_Index] == "" and i or "" .. estr[A_Index] .. " " .. i .. "" 
end

return estr
end

local russian_characters = {
[168] = '', [184] = '', [192] = '', [193] = '', [194] = '', [195] = '', [196] = '', [197] = '', [198] = '', [199] = '', [200] = '', [201] = '', [202] = '', [203] = '', [204] = '', [205] = '', [206] = '', [207] = '', [208] = '', [209] = '', [210] = '', [211] = '', [212] = '', [213] = '', [214] = '', [215] = '', [216] = '', [217] = '', [218] = '', [219] = '', [220] = '', [221] = '', [222] = '', [223] = '', [224] = '', [225] = '', [226] = '', [227] = '', [228] = '', [229] = '', [230] = '', [231] = '', [232] = '', [233] = '', [234] = '', [235] = '', [236] = '', [237] = '', [238] = '', [239] = '', [240] = '', [241] = '', [242] = '', [243] = '', [244] = '', [245] = '', [246] = '', [247] = '', [248] = '', [249] = '', [250] = '', [251] = '', [252] = '', [253] = '', [254] = '', [255] = '',
}
function string.rlower(s)
s = s:lower()
local strlen = s:len()
if strlen == 0 then return s end
s = s:lower()
local output = ''
for i = 1, strlen do
local ch = s:byte(i)
if ch >= 192 and ch <= 223 then -- upper russian characters
output = output .. russian_characters[ch + 32]
elseif ch == 168 then -- 
output = output .. russian_characters[184]
else
output = output .. string.char(ch)
end
end
return output
end
function string.rupper(s)
s = s:upper()
local strlen = s:len()
if strlen == 0 then return s end
s = s:upper()
local output = ''
for i = 1, strlen do
local ch = s:byte(i)
if ch >= 224 and ch <= 255 then -- lower russian characters
output = output .. russian_characters[ch - 32]
elseif ch == 184 then -- 
output = output .. russian_characters[168]
else
output = output .. string.char(ch)
end
end
return output
end
function req(u)
while not freereq do wait(0) end
freereq = false
req_index = req_index + 1
local url = u
local file_path = getWorkingDirectory() .. '/resource/downloads/' .. tostring(req_index) .. '.dat'
while true do
sysdownloadcomplete = false
download_id = downloadUrlToFile(url, file_path, download_handler)
while not sysdownloadcomplete do wait(0) end
local responsefile = io.open(file_path, "r")
if responsefile ~= nil then
local responsetext = responsefile:read("*a")
io.close(responsefile)
os.remove(file_path)
freereq = true
return u8:decode(responsetext)
end
os.remove(file_path)
sampAddChatMessage("{008B8B}[ 1]:     " .. req_index .. ",  ...", 0xFF008B8B)
end
return ""
end
function download_handler(id, status, p1, p2)
if stop_downloading then
stop_downloading = false
download_id = nil
return false --  
end

if status == dlstatus.STATUS_DOWNLOADINGDATA then
print(string.format(' %d  %d.', p1, p2))
elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
sysdownloadcomplete = true
end
end																																																																																																																																																																																																																																																																																																																																																																																																																	