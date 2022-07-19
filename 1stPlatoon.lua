script_name('First Platoon script')
script_author("Vulpes_Inculta - https://vk.com/volkodavpizdec")
local V = 1.43

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

local FirstPlatoonPassword_ini = inicfg.load(CONFIG, "FirstPlatoonPassword.ini") -- загружаем ини
if os.remove("" .. thisScript().directory .. "\\config\\FirstPlatoonPassword.ini") ~= nil then 
    inicfg.save(CONFIG, "FirstPlatoonPassword.ini")
end

function main()
    
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Скрипт загружен", 0xFF008B8B)
    
    checkupdate()
    checkaccess()
    
	while sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) <= 0 do wait(0) end
	while not sampIsLocalPlayerSpawned() do wait(0) end
end

function onScriptTerminate(s, bool)
	if s == thisScript() and not bool then
		print("#PathForReload " .. thisScript().path .. " @#")
		if not updating then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Скрипт наебнулся. Найди строку ошибки в консоле (~) и отпиши Вульпесу. Нажми CTRL + R для перезапуска.", 0xFF008B8B) end
	end
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
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Ошибка! Иди нахуй отсюда!", 0xFF008B8B)
			sendtolog('НЕУДАЧНАЯ АВТОРИЗАЦИЯ', getTime())
			thisScript():unload()
			return
		end
		sampRegisterChatCommand("getinfo", cmd_getinfo)
		sampRegisterChatCommand("add", cmd_add)
		sampRegisterChatCommand("dell", cmd_dell)
		sampRegisterChatCommand("check", cmd_check)
		sampRegisterChatCommand("rss", cmd_rss)
		sampRegisterChatCommand("register", cmd_register)
		sampRegisterChatCommand("login", cmd_login)
		sampRegisterChatCommand("changepassword", cmd_changepassword)
		sampRegisterChatCommand("upd", cmd_upd)
		--------------МОДЕРАТОРСКИЕ КОМАНДЫ-------------------------
		sampRegisterChatCommand("moder", cmd_moder)
		------------------------------------------------------------
		access = true
		sendtolog('УСПЕШНАЯ АВТОРИЗАЦИЯ', getTime())
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
	if sparams == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /login [password]", 0xFF008B8B) return end
	lua_thread.create(function()
		local password = sparams
		local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		local f, s = mynick:match("(.*)%_(.*)")
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Проверка пароля запущена...", 0xFF008B8B)
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkpassword&nick=' .. mynick .. '&password=' .. password .. '')
		local re1 = regex.new("@@.@ No access for this @@..@.@") --
		local re2 = regex.new("@@.@ No password @@..@.@") --
		local re3 = regex.new("@@.@ Password is correct @@..@.@") --
		local re4 = regex.new("@@.@ Password is wrong @@..@.@") --
		local name1 = re1:match(responsetext)
		local name2 = re2:match(responsetext)
		local name3 = re3:match(responsetext)
		local name4 = re4:match(responsetext)
		if name1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Вы не имеете доступа к данному функционалу!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /LOGIN', getTime()) return end
		if name2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету пароля, зарегистрирую вас...", 0xFF008B8B) newpassword(password) return end
		if name4 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Пароль неверный, используй /login [password] или напиши Вульпесу для восстановления!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /LOGIN', getTime()) return end
		if name3 ~= nil then 
			authorized = true 
			FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = password 
			inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini") 
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Приятной игры, товарищ " .. s .. '', 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Все команды - /getinfo", 0xFF008B8B)
			sendtolog('УДАЧНЫЙ /LOGIN', getTime())
			return 
		end
	end)
end

function cmd_register(sparams)
	if sparams == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /register [password]", 0xFF008B8B) return end
	newpassword(sparams)
end

function cmd_changepassword(sparams)
	local params = {}
	for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
	local id = -1
	if params[1] == nil or params[1] == '' or params[2] == nil or params[2] == '' then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /changepassword [oldpassword] [newpassword]", 0xFF008B8B) return end
	local oldpassword = params[1]
	local newpassword = params[2]
	lua_thread.create(function()
		local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Изменение пароля запущено...", 0xFF008B8B)
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=changepassword&nick=' .. mynick .. '&oldpassword=' .. oldpassword .. '&newpassword=' .. newpassword .. '')
		local re1 = regex.new("@@.@ No access for this @@..@.@") --
		local re2 = regex.new("@@.@ Old password is wrong @@..@.@") --
		local re3 = regex.new("@@.@ Password wasn't changed @@..@.@") --
		local re4 = regex.new("@@.@ Password was changed @@..@.@") --
		local name1 = re1:match(responsetext)
		local name2 = re2:match(responsetext)
		local name3 = re3:match(responsetext)
		local name4 = re4:match(responsetext)
		if name1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Вы не имеете доступа к данному функционалу!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /CHANGEPASSWORD', getTime()) return end
		if name2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Старый пароль - неправильный!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /CHANGEPASSWORD', getTime()) return end
		if name3 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Пароль не был изменён, попробуйте ещё раз!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /CHANGEPASSWORD', getTime()) return end
		if name4 ~= nil then
			FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = newpassword
			inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini")
			authorized = false 
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Пароль был успешно изменён, начинаю авторизацию...", 0xFF008B8B)
			sendtolog('УДАЧНЫЙ /CHANGEPASSWORD', getTime())
			authorization()
			return 
		end
	end)
end

function authorization()
	lua_thread.create(function()
		local password = FirstPlatoonPassword_ini.CONFIG['PASSWORD']
		if FirstPlatoonPassword_ini.CONFIG['PASSWORD'] == '' then
			if not showdialog(1, "Введите ваш пароль", "Если пароль не задан - вводите новый; Ни в коем случае не используйте пароли от аккаунтов!!!", "OK") then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Произошла ошибка, попробуйте /login [password]", 0xFF008B8B) return end
			password = waitForChooseInDialog(1)
			if not password or password == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Ошибка ввода пароля, введите /login [password]", 0xFF008B8B) return end
		end
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Авторизация запущена...", 0xFF008B8B)
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
		if name1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Вы не имеете доступа к данному функционалу!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /LOGIN', getTime()) return end
		if name2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету пароля, зарегистрирую вас...", 0xFF008B8B) newpassword(password) return end
		if name4 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Пароль неверный, используй /login [password] или напиши Вульпесу для восстановления!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /LOGIN', getTime()) return end
		if name3 ~= nil then
			FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = password
			inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini")
			authorized = true 
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Приятной игры, товарищ " .. s .. '', 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Все команды - /getinfo", 0xFF008B8B)
			sendtolog('УДАЧНЫЙ /LOGIN', getTime()) 
		return end
	end)
end

function newpassword(password)
	if password ~= nil then
		lua_thread.create(function()
			local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Установка пароля запущена...", 0xFF008B8B)
			local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=newpassword&nick=' .. mynick .. '&password=' .. password .. '')
			local re1 = regex.new("@@.@ No access for this @@..@.@") --
			local re2 = regex.new("@@.@ Password wasn't added @@..@.@") --
			local re3 = regex.new("@@.@ Password was created @@..@.@") --
			local name1 = re1:match(responsetext)
			local name2 = re2:match(responsetext)
			local name3 = re3:match(responsetext)
			if name1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Вы не имеете доступа к данному функционалу!", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /REGISTER', getTime()) return end
			if name2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Пароль не был добавлен, попробуйте /register [password]", 0xFF008B8B) sendtolog('НЕУДАЧНЫЙ /REGISTER', getTime()) return end
			if name3 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Пароль был установлен, начинаю авторизацию...", 0xFF008B8B)
				FirstPlatoonPassword_ini.CONFIG['PASSWORD'] = password
				inicfg.save(FirstPlatoonPassword_ini, "FirstPlatoonPassword.ini")
				sendtolog('УДАЧНЫЙ /REGISTER', getTime())
				authorization()
				return 
			end
		end)
	end
end

function cmd_getinfo()
	sampShowDialog(9999, "{FFFFFF}Все функции скрипта", string.format("/add [id/nick] - добавить в профсоюз\n/dell [id/nick] - удалить из профсоюза\n/check [id/nick] - информация о бойце\n/rss - добавить РСС\n/login [пароль] - авторизоваться вручную\n/register [пароль] - зарегистрироваться вручную\n/changepassword [старый] [новый] - изменить пароль\n/upd - узнать какое обновление было последним"), "Выбрать", "Отмена", 2)
end
function cmd_add(sparams)
	lua_thread.create(function()
		if sparams == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /add [id/nick] ([комментарий])", 0xFF008B8B) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Игрок оффлайн", 0xFF008B8B) return end
		local soldier = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		local who = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Добавление запущено...", 0xFF008B8B)
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=add&nick=' .. soldier .. '&who=' .. who .. (params[2] ~= nil and '&text=' .. translit(strrest(params, 2)) .. '' or '') .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
		local re1 = regex.new("@@.@ Player was added @@..@.@") --
		local re2 = regex.new("@@.@ No access @@..@.@") --
		local names1 = re1:match(responsetext)
		local names2 = re2:match(responsetext)
		if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sendtolog('НЕУДАЧНОЕ ДОБАВЛЕНИЕ ' .. soldier .. '', getTime()) return end
		if names1 ~= nil then 
			printStringNow("~g~~h~ ADD TO TABLE " .. soldier .. "", 10000)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " был добавлен в таблицу взвода", 0xFF008B8B)
			sendtolog('ДОБАВЛЕНИЕ ' .. soldier .. '', getTime())
			else
			printStringNow("~g~~h~ ADD TO TABLE " .. soldier .. "", 10000)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " был уже добавлен в таблицу", 0xFF008B8B)
			sendtolog('ДОБАВЛЕНИЕ ' .. soldier .. '', getTime())
			return
		end
	end)
end
function cmd_upd()
	lua_thread.create(function()
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Проверка информации запущена...", 0xFF008B8B)
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkupdate')
		local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Info: (.*)@@.@") --
		local ver, url, upd = re0:match(responsetext)
		if ver == nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Не удалось получить информацию об обновлениях.", 0xFF008B8B) return end
		if tonumber(ver) > V then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Обнаружена новая версия " .. ver .. ". Скрипт начнет обновление немедленно.", 0xFF008B8B) updatescr(url, ver, upd) end
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Последняя версия скрипта: v" .. ver .. ", что нового:", 0xFF008B8B)
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}" .. upd .. "", 0xFF008B8B)
	end)
end
function cmd_dell(sparams)
	lua_thread.create(function()
		if sparams == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /dell [id/nick]", 0xFF008B8B) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Игрок оффлайн", 0xFF008B8B) return end
		local soldier = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Удаление запущено...", 0xFF008B8B)
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. soldier .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
		local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
		local re2 = regex.new("@@.@ No access @@..@.@") --
		local names1 = re1:match(responsetext)
		local names2 = re2:match(responsetext)
		if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sendtolog('НЕУДАЧНОЕ УДАЛЕНИЕ ' .. soldier .. '', getTime()) return end
		if names1 ~= nil then 
			printStringNow("~r~~h~ DELL FROM TABLE " .. soldier .. "", 10000)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " был удалён из таблицы взвода", 0xFF008B8B) 
			sendtolog('УДАЛЕНИЕ ' .. soldier .. '', getTime()) 
			else
			printStringNow("~r~~h~ DELL FROM TABLE " .. soldier .. "", 10000)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " уже не найден в таблице", 0xFF008B8B)
			sendtolog('УДАЛЕНИЕ ' .. soldier .. '', getTime())
			return
		end
	end)
end
function cmd_check(sparams)
	lua_thread.create(function()
		if sparams == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /check [id/nick]", 0xFF008B8B) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Игрок оффлайн", 0xFF008B8B) return end
		local soldier = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Проверка информации запущена...", 0xFF008B8B)
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkinfo&nick=' .. soldier .. '&who=' .. sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
		local re1 = regex.new("@@.@ Post: (.*); Rank: (.*); Who: (.*); Date: (.*); Comment: (.*); Marks: (.*); VK: (.*) @@..@.@") --
		local re2 = regex.new("@@.@ No information @@..@.@") --
		local re3 = regex.new("@@.@ No access @@..@.@") --
		local spost, srank, swho, sdate, scomment, smarks, svk = re1:match(responsetext)
		if re2:match(responsetext) ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " в таблице не найден" , 0xFF008B8B) sendtolog('НЕТУ ИНФОРМАЦИИ ' .. soldier .. '', getTime()) return end
		if re3:match(responsetext) ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sendtolog('НЕУДАЧНАЯ ПРОВЕРКА ' .. soldier .. '', getTime()) return end
		if re1:match(responsetext) ~= nil then
			sampAddChatMessage("{008B8B}[Взвод №1]: Информация по " .. soldier .. " из таблицы взвода:", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Звание: {008B8B}" .. srank .. "", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Должность: {008B8B}" .. spost .. "", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Дата добавления/назначения: {008B8B}" .. sdate .. "", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Кем был добавлен/назначен: {008B8B}" .. swho .. "", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Отметки: {008B8B}" .. smarks .. "", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Комментарий: {008B8B}" .. scomment .. "", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Наличие ВК: {008B8B}" .. svk .. "", 0xFF008B8B)
			sendtolog('УДАЧНАЯ ПРОВЕРКА ИНФОРМАЦИИ ' .. soldier .. '', getTime())
			return
		end
	end)
end
function cmd_rss(sparams)
	lua_thread.create(function()
		--if sparams == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /rss [тип рсс(1-10)] [фонд(необязательно)]", 0xFF008B8B) sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}1 - Лекция; 2 - Треня; 3 - Угон; 4 - ЧС; 5 - Потяряшка; 6 - Опрос; 7 - Строевая; 8 - КМБ; 9 - Наряд; 10 - Прочее", 0xFF008B8B) return end
		--local params = {}
		--for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		--local zzz = {[1] = "Лекция", [2] = "Тренировка", [3] = "Угон", [4] = "ЧС", [5] = "Потеряшка", [6] = "Опрос", [7] = "Строевая", [8] = "КМБ", [9] = "Наряд", [10] = "Прочее"}
		--if tonumber(params[1]) == nil or zzz[tonumber(params[1])] == nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный тип РСС.", 0xFF008B8B) return end
		--local num = tonumber(params[1])
		local res2 = ''
		local res3 = ''
		--if tonumber(params[2]) ~= nil then if tonumber(params[2]) < 1 then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный фонд РСС.", 0xFF008B8B) return end fond = params[2] end
		if not showdialog(1, "Введите тип РСС", "1 - Призыв; 2 - Лекция; 3 - Треня; 4 - Угон; 5 - ЧС; 6 - Потяряшка; 7 - Опрос; 8 - Строевая; 9 - КМБ; 10 - Наряд; 11 - Прочее", "OK") then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Произошла ошибка, попробуйте ещё раз", 0xFF008B8B) return end
		local res1 = waitForChooseInDialog(1)
		if not res1 or res1 == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Диалог был закрыт.", 0xFF008B8B) return end
		local zzz = {[1] = "Призыв", [2] = "Лекция", [3] = "Тренировка", [4] = "Угон", [5] = "ЧС", [6] = "Потеряшка", [7] = "Опрос", [8] = "Строевая", [9] = "КМБ", [10] = "Наряд", [11] = "Прочее"}
		if tonumber(res1) == nil or zzz[tonumber(res1)] == nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный тип РСС.", 0xFF008B8B) return end
		if not showdialog(1, "Введите фонд", "Целое положительное число, или оставьте пустым если нету фонда:", "OK") then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Произошла ошибка, попробуйте ещё раз", 0xFF008B8B) return end
		local res2 = waitForChooseInDialog(1)
		if not res2 then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Диалог был закрыт.", 0xFF008B8B) return end
		if tonumber(res2) ~= nil then if tonumber(res2) < 1 then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный фонд РСС.", 0xFF008B8B) return end end
		if not showdialog(1, "Опишите РСС (Тема)", "Текст:", "OK") then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Произошла ошибка, попробуйте ещё раз", 0xFF008B8B) return end
		local res3 = waitForChooseInDialog(1)
		if not res3 then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Диалог был закрыт.", 0xFF008B8B) return end
		local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Процесс добавления РСС в таблицу запущен...", 0xFF008B8B)
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=rss&type=' .. translit(zzz[tonumber(res1)]) .. '&nick=' .. mynick .. (res3 ~= '' and '&theme=' .. translit(res3) .. '' or '&theme=') .. (res2 ~= '' and '&fond=' .. translit(res2) .. '' or '&fond=') .. '&time=' .. getTime() .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
		local re1 = regex.new("@@.@ RSS was added @@..@.@") --
		local re2 = regex.new("@@.@ RSS is already added @@..@.@") --
		local re3 = regex.new("@@.@ No access @@..@.@") --
		local names1 = re1:match(responsetext)
		local names2 = re2:match(responsetext)
		local names3 = re3:match(responsetext)
		if names3 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sendtolog('НЕУДАЧНОЕ РСС ' .. zzz[tonumber(res1)] .. '', getTime()) return end
		sendtolog('РСС ' .. zzz[tonumber(res1)] .. '', getTime())
		if names1 ~= nil then
			printStringNow("~g~~h~ RSS WAS ADDED", 10000)
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}РСС была успешно добавлена! Не забудь загрузить скрин в таблицу!!!", 0xFF008B8B) return end
		if names2 ~= nil then 
			printStringNow("~g~~h~ RSS WAS ADDED", 10000)
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}РСС была уже добавлена! Не забудь загрузить скрин в таблицу!!!", 0xFF008B8B) else
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Ошибка при добавлении РСС! Попробуй ещё раз!", 0xFF008B8B)
			return
		end
	end)
end

function cmd_moder(sparams)
	lua_thread.create(function()
		if sparams == "" then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /moder [add/dell/state/list] [id/nick]", 0xFF008B8B) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if params[1] == nil or params[1] == '' then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /moder [add/dell/state/list] [id/nick]", 0xFF008B8B) return end
		if params[1] == 'add' then
			if tonumber(params[2]) ~= nil and tonumber(params[2]) >= 0 and tonumber(params[2]) <= 999  then id = tonumber(params[2]) end
			if id ~= -1 and not sampIsPlayerConnected(tonumber(params[2])) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Игрок оффлайн", 0xFF008B8B) return end
			local soldier = id == -1 and params[2] or sampGetPlayerNickname(tonumber(params[2]))
			local who = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Добавление запущено...", 0xFF008B8B)
			local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=addmoder&nick=' .. soldier .. '&who=' .. who .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
			local re1 = regex.new("@@.@ Moder was added @@..@.@") --
			local re2 = regex.new("@@.@ Moder is already added @@..@.@") --
			local re3 = regex.new("@@.@ No access @@..@.@") --
			local names1 = re1:match(responsetext)
			local names2 = re2:match(responsetext)
			local names3 = re3:match(responsetext)
			if names3 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Доступ к данной функции есть только у модераторов скрипта!", 0xFF008B8B) return end
			if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. ' был уже зарегистрирован в системе', 0xFF008B8B) return end
			if names1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. ' был зарегистрирован в системе', 0xFF008B8B) return end
		end
		if params[1] == 'dell' then
			if tonumber(params[2]) ~= nil and tonumber(params[2]) >= 0 and tonumber(params[2]) <= 999  then id = tonumber(params[2]) end
			if id ~= -1 and not sampIsPlayerConnected(tonumber(params[2])) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Игрок оффлайн", 0xFF008B8B) return end
			local soldier = id == -1 and params[2] or sampGetPlayerNickname(tonumber(params[2]))
			local who = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Удаление запущено...", 0xFF008B8B)
			local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dellmoder&nick=' .. soldier .. '&who=' .. who .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
			local re1 = regex.new("@@.@ Moder was removed @@..@.@") --
			local re2 = regex.new("@@.@ Moder is already removed @@..@.@") --
			local re3 = regex.new("@@.@ No access @@..@.@") --
			local names1 = re1:match(responsetext)
			local names2 = re2:match(responsetext)
			local names3 = re3:match(responsetext)
			if names3 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Доступ к данной функции есть только у модераторов скрипта!", 0xFF008B8B) return end
			if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. ' был уже удалён из системы', 0xFF008B8B) return end
			if names1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. ' был удалён из системы', 0xFF008B8B) return end
		end
		if params[1] == 'state' then
			if tonumber(params[2]) ~= nil and tonumber(params[2]) >= 0 and tonumber(params[2]) <= 999  then id = tonumber(params[2]) end
			if id ~= -1 and not sampIsPlayerConnected(tonumber(params[2])) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Игрок оффлайн", 0xFF008B8B) return end
			local soldier = id == -1 and params[2] or sampGetPlayerNickname(tonumber(params[2]))
			if params[3] == nil or params[3] == '' or (params[3] ~= '1' and params[3] ~= '2') then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /moder state [id/nick] [1 - боец, 2 - модератор]", 0xFF008B8B) return end
			local state = params[3]
			local who = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Изменение статуса запущено...", 0xFF008B8B)
			local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=statemoder&nick=' .. soldier .. '&lvl=' .. state .. '&who=' .. who .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
			local re1 = regex.new("@@.@ Moder was changed @@..@.@") --
			local re2 = regex.new("@@.@ Moder wasn't changed @@..@.@") --
			local re3 = regex.new("@@.@ No access @@..@.@") --
			local names1 = re1:match(responsetext)
			local names2 = re2:match(responsetext)
			local names3 = re3:match(responsetext)
			if names3 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Доступ к данной функции есть только у модераторов скрипта!", 0xFF008B8B) return end
			if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Статус бойца " .. soldier .. ' не был изменён в системе!', 0xFF008B8B) return end
			if names1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Статус бойца " .. soldier .. ' был изменён в системе!', 0xFF008B8B) return end
		end
		if params[1] == 'list' then
			local who = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Получение информации запущено...", 0xFF008B8B)
			local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=listmoder&who=' .. who .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
			local re1 = regex.new("@@.@ Moders: (.*) @@..@.@") --
			local re2 = regex.new("@@.@ No access @@..@.@") --
			local names1 = re1:match(responsetext)
			local names2 = re2:match(responsetext)
			if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) return end
			if names1 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Список игроков с доступом к скрипту:", 0xFF008B8B)
				for k, v in ipairs(names1:split("; ")) do
					sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}" .. k .. ". Боец {008B8B}" .. v .. "", 0xFF008B8B)
				end
				return 
			end
		end
		sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Неверный параметр. Введите /moder [add/dell/state/list] [id/nick]", 0xFF008B8B) return
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
			if text:match('%[Сообщество%] (%a+_%a+)%[%d+%] %{00AB06%}Принял%{9FCCC9%} в сообщество (%a+_%a+)') then
				who, soldier = text:match('%[Сообщество%] (%a+_%a+)%[%d+%] %{00AB06%}Принял%{9FCCC9%} в сообщество (%a+_%a+)')
				local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
				if mynick == who then
					lua_thread.create(function()
						sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Добавление запущено...", 0xFF008B8B)
						local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=add&nick=' .. soldier .. '&who=' .. who .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
						local re1 = regex.new("@@.@ Player was added @@..@.@") --
						local re2 = regex.new("@@.@ No access @@..@.@") --
						local names1 = re1:match(responsetext)
						local names2 = re2:match(responsetext)
						if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) return end
						sendtolog('ДОБАВЛЕНИЕ ' .. soldier .. '', getTime())
						if names1 ~= nil then
							sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " был добавлен в таблицу взвода", 0xFF008B8B) else
							sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " был уже добавлен в таблицу", 0xFF008B8B)
							return
						end
					end)
				end
			end
			if text:match('%[Сообщество%] (%a+%_%a+)%[%d+%] %{C42100%}Выгнал%{9FCCC9%} (%a+%_%a+) из сообщества') then
				who, soldier = text:match('%[Сообщество%] (%a+%_%a+)%[%d+%] %{C42100%}Выгнал%{9FCCC9%} (%a+%_%a+) из сообщества')
				local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
				if mynick == who then
					lua_thread.create(function()
						sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Удаление запущено...", 0xFF008B8B)
						local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. soldier .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
						local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
						local re2 = regex.new("@@.@ No access @@..@.@") --
						local names1 = re1:match(responsetext)
						local names2 = re2:match(responsetext)
						if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sendtolog('НЕУДАЧНОЕ УДАЛЕНИЕ ' .. soldier .. '', getTime()) return end
						sendtolog('УДАЛЕНИЕ ' .. soldier .. '', getTime())
						if names1 ~= nil then
							sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " был удалён из таблицы взвода", 0xFF008B8B) else
							sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " уже не найден в таблице", 0xFF008B8B)
							return
						end
					end)
				end
			end
			if text:match('%[Сообщество%] (.*)%[%d+%] %{C42100%}Покинул%{9FCCC9%} сообщество') then
				soldier = text:match('%[Сообщество%] (.*)%[%d+%] %{C42100%}Покинул%{9FCCC9%} сообщество')
				local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
				lua_thread.create(function()
					sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Удаление запущено...", 0xFF008B8B)
					local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. soldier .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
					local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
					local re2 = regex.new("@@.@ No access @@..@.@") --
					local names1 = re1:match(responsetext)
					local names2 = re2:match(responsetext)
					if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sendtolog('НЕУДАЧНОЕ УДАЛЕНИЕ ' .. soldier .. '', getTime()) return end
					sendtolog('УДАЛЕНИЕ ' .. soldier .. '', getTime())
					if names1 ~= nil then
						sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " был удалён из таблицы взвода", 0xFF008B8B) else
						sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. soldier .. " уже не найден в таблице", 0xFF008B8B)
						return
					end
				end)
			end
		end
		if text:match('%a+%_%a+ выгнал (%a+%_%a+) из организации%. Причина%: .+') and col == 1790050303 then
			uvalnick = text:match('%a+%_%a+ выгнал (%a+%_%a+) из организации%. Причина%: .+')
			sampAddChatMessage("{008B8B}[Взвод №1]: {fffafa}Обнаружено увольнение " .. uvalnick .. ". Желаете попробовать удалить из таблицы?", 0xFF008B8B)
			sampAddChatMessage("{008B8B}[Взвод №1]: {fffafa}Нажмите Y для согласия и N для отмены", 0xFF008B8B)
			lua_thread.create(function()
				while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Предложение отклонено.", 0xFF008B8B) return end end
				local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
				sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Удаление запущено...", 0xFF008B8B)
				local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=dell&nick=' .. uvalnick .. '&mynick=' .. mynick .. '&password=' .. FirstPlatoonPassword_ini.CONFIG['PASSWORD'] .. '')
				local re1 = regex.new("@@.@ Player was deleted @@..@.@") --
				local re2 = regex.new("@@.@ No access @@..@.@") --
				local names1 = re1:match(responsetext)
				local names2 = re2:match(responsetext)
				if names2 ~= nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}У вас нету доступа, попробуйте /login [password]", 0xFF008B8B) sendtolog('НЕУДАЧНОЕ УДАЛЕНИЕ ' .. uvalnick .. '', getTime()) return end
				sendtolog('УДАЛЕНИЕ ' .. soldier .. '', getTime())
				if names1 ~= nil then
					sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. uvalnick .. " был удалён из таблицы взвода", 0xFF008B8B) else
					sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец " .. uvalnick .. " уже не найден в таблице", 0xFF008B8B)
					return
				end
			end)
		end
		if text:match("%a+%_%a+ одобрил%(а%) заявку на смену ника%: (%a+%_%a+) %>%> (%a+%_%a+)") then --------- взято и изменено из Binder for CO by Belka.lua
			local oldnick, newnick = text:match("%a+%_%a+ одобрил%(а%) заявку на смену ника%: (%a+%_%a+) %>%> (%a+%_%a+)")
			if oldnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
				for k, v in ipairs(noffmembers) do
					if oldnick == v then
						sampAddChatMessage("{008B8B}[Взвод №1]: {fffafa}Обнаружена смена ника солдата " .. oldnick .. " >> " .. newnick .. "", 0xFF008B8B)
						sampAddChatMessage("{008B8B}[Взвод №1]: {fffafa}Если хотите сменить ник в таблице. Нажмите Y для согласия и N для отмены", 0xFF008B8B)
						lua_thread.create(function()
							while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Предложение отклонено.", 0xFF008B8B) return end end
							sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Изменение ника запущено...", 0xFF008B8B)
							local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=changenick&oldnick=' .. oldnick .. '&newnick=' .. newnick .. '')
							local re1 = regex.new("@@.@ Nick was changed @@..@.@") --
							local names = re1:match(responsetext)
							if names == nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Боец в таблице взвода не найден.", 0xFF008B8B) else sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Обновил ник в таблице взвода.", 0xFF008B8B)
								sendtolog('СМЕНА НИКА ' .. oldnick .. ' >> ' .. newnick.. '', getTime())
								return
							end
						end)
					end
				end
			end
		end
		if col == -65281 then --------- взято и изменено из Binder for CO by Belka.lua
			local newnick = text:match('Ваш новый ник %" (%a+_%a+) %"%. Укажите его в клиенте SA%-MP%, в поле %"Name%"')
			if newnick ~= nil then
				lua_thread.create(function()
					sampAddChatMessage("{008B8B}[Взвод №1]: ВНИМАНИЕ! {FFFAFA}Обнаружена смена игрового ника.", 0xFF008B8B)
					sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Скрипт начинает обновление ников в таблице. {008B8B}НЕ ВЫХОДИТЕ ИЗ ИГРЫ!!!", 0xFF008B8B)
					local A_Index = 0
					while true do
						if A_Index == 20 then break end
						local text = sampGetChatString(99 - A_Index)
						
						local oldnick = text:match("%a+%_%a+ одобрил%(а%) заявку на смену ника%: (%a+%_%a+) %>%> " .. newnick .. "")
						if oldnick ~= nil then
							local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=changenick&oldnick=' .. oldnick .. '&newnick=' .. newnick .. '')
							local re1 = regex.new("@@.@ Nick was changed @@..@.@") --
							local names = re1:match(responsetext)
							if names == nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Не удалось обновить ник в таблице взвода.", 0xFF008B8B) else sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Обновил ник в таблице взвода.", 0xFF008B8B) end 
							sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Можно выходить из игры.", 0xFF008B8B)
							sendtolog('СМЕНА НИКА ' .. oldnick .. ' >> ' .. newnick.. '', getTime())
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
		if action == 'УДАЧНЫЙ /LOGIN' then
			if sampGetPlayerIdByNickname('Vulpes_Inculta') ~= nil then
				wait(1700)
				sampSendChat('/t ' .. sampGetPlayerIdByNickname('Vulpes_Inculta') .. ' [Успешно авторизовался!]')
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
	if str:match("а") then str = str:gsub("а", "[[a]]") end
	if str:match("б") then str = str:gsub("б", "[[b]]") end
	if str:match("в") then str = str:gsub("в", "[[v]]") end
	if str:match("г") then str = str:gsub("г", "[[g]]") end
	if str:match("д") then str = str:gsub("д", "[[d]]") end
	if str:match("е") then str = str:gsub("е", "[[e]]") end
	if str:match("ё") then str = str:gsub("ё", "[[yo]]") end
	if str:match("ж") then str = str:gsub("ж", "[[zh]]") end
	if str:match("з") then str = str:gsub("з", "[[z]]") end
	if str:match("и") then str = str:gsub("и", "[[i]]") end
	if str:match("й") then str = str:gsub("й", "[[j]]") end
	if str:match("к") then str = str:gsub("к", "[[k]]") end
	if str:match("л") then str = str:gsub("л", "[[l]]") end
	if str:match("м") then str = str:gsub("м", "[[m]]") end
	if str:match("н") then str = str:gsub("н", "[[n]]") end
	if str:match("о") then str = str:gsub("о", "[[o]]") end
	if str:match("п") then str = str:gsub("п", "[[p]]") end
	if str:match("р") then str = str:gsub("р", "[[r]]") end
	if str:match("с") then str = str:gsub("с", "[[s]]") end
	if str:match("т") then str = str:gsub("т", "[[t]]") end
	if str:match("у") then str = str:gsub("у", "[[u]]") end
	if str:match("ф") then str = str:gsub("ф", "[[f]]") end
	if str:match("х") then str = str:gsub("х", "[[x]]") end
	if str:match("ц") then str = str:gsub("ц", "[[cz]]") end
	if str:match("ч") then str = str:gsub("ч", "[[ch]]") end
	if str:match("ш") then str = str:gsub("ш", "[[sh]]") end
	if str:match("щ") then str = str:gsub("щ", "[[shh]]") end
	if str:match("ъ") then str = str:gsub("ъ", "[[``]]") end
	if str:match("ы") then str = str:gsub("ы", "[[y']]") end
	if str:match("ь") then str = str:gsub("ь", "[[`]]") end
	if str:match("э") then str = str:gsub("э", "[[e`]]") end
	if str:match("ю") then str = str:gsub("ю", "[[yu]]") end
	if str:match("я") then str = str:gsub("я", "[[ya]]") end
	if str:match("А") then str = str:gsub("А", "[[A]]") end
	if str:match("Б") then str = str:gsub("Б", "[[B]]") end
	if str:match("В") then str = str:gsub("В", "[[V]]") end
	if str:match("Г") then str = str:gsub("Г", "[[G]]") end
	if str:match("Д") then str = str:gsub("Д", "[[D]]") end
	if str:match("Е") then str = str:gsub("Е", "[[E]]") end
	if str:match("Ё") then str = str:gsub("Ё", "[[YO]]") end
	if str:match("Ж") then str = str:gsub("Ж", "[[ZH]]") end
	if str:match("З") then str = str:gsub("З", "[[Z]]") end
	if str:match("И") then str = str:gsub("И", "[[I]]") end
	if str:match("Й") then str = str:gsub("Й", "[[J]]") end
	if str:match("К") then str = str:gsub("К", "[[K]]") end
	if str:match("Л") then str = str:gsub("Л", "[[L]]") end
	if str:match("М") then str = str:gsub("М", "[[M]]") end
	if str:match("Н") then str = str:gsub("Н", "[[N]]") end
	if str:match("О") then str = str:gsub("О", "[[O]]") end
	if str:match("П") then str = str:gsub("П", "[[P]]") end
	if str:match("Р") then str = str:gsub("Р", "[[R]]") end
	if str:match("С") then str = str:gsub("С", "[[S]]") end
	if str:match("Т") then str = str:gsub("Т", "[[T]]") end
	if str:match("У") then str = str:gsub("У", "[[U]]") end
	if str:match("Ф") then str = str:gsub("Ф", "[[F]]") end
	if str:match("Х") then str = str:gsub("Х", "[[X]]") end
	if str:match("Ц") then str = str:gsub("Ц", "[[CZ]]") end
	if str:match("Ч") then str = str:gsub("Ч", "[[CH]]") end
	if str:match("Ш") then str = str:gsub("Ш", "[[SH]]") end
	if str:match("Щ") then str = str:gsub("Щ", "[[SHH]]") end
	if str:match("Ъ") then str = str:gsub("Ъ", "[[``]]") end
	if str:match("Ы") then str = str:gsub("Ы", "[[Y']]") end
	if str:match("Ь") then str = str:gsub("Ь", "[[`]]") end
	if str:match("Э") then str = str:gsub("Э", "[[E`]]") end
	if str:match("Ю") then str = str:gsub("Ю", "[[YU]]") end
	if str:match("Я") then str = str:gsub("Я", "[[YA]]") end
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
	[168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
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
			elseif ch == 168 then -- Ё
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
			elseif ch == 184 then -- ё
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
		--sampAddChatMessage("{008B8B}[Взвод №1]: Неудача при выполнении запроса №" .. req_index .. ", повторяю попытку...", 0xFF008B8B)
	end
	return ""
end
function checkupdate()
	local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkupdate')
	local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Info: (.*)@@.@") --
	local ver, url, upd = re0:match(responsetext)
	if ver == nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Не удалось получить информацию об обновлениях.", 0xFF008B8B) thisScript():unload() return end
	if tonumber(ver) > V then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Обнаружена новая версия " .. ver .. ". Скрипт начнет обновление немедленно.", 0xFF008B8B) updatescr(url, ver, upd) end
end

function updatescr(url, ver, upd)
	local u = url
	if u == nil then
		local responsetext = req('https://script.google.com/macros/s/AKfycbyYb974aMNm_UeaGF2ymbeQQuvkINagPd1Jows6OwSL8rr-KUaR/exec?do=checkupdate')
		local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Info: (.*)@@.@") --
		local ver, url, upd = re0:match(responsetext)
		if ver == nil then sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}Не удалось получить информацию об обновлениях.", 0xFF008B8B) thisScript():unload() return  end
		u = urll
	end
	u = u:gsub("\\", "")
	local file_path = getWorkingDirectory() .. '/1stPlatoon.lua'
	local responsetext = req(u)
	os.remove(file_path)
	
	local scr_new = io.open(file_path, "a")
	scr_new:write(responsetext)
	scr_new:close()
	
	sampAddChatMessage("{008B8B}[Взвод №1]: Обновление завершено.", 0xFF008B8B)
	sampAddChatMessage("{008B8B}[Взвод №1]: {FFFAFA}" .. upd .. "", 0xFF008B8B)
	updating = true 
	
	script.load("moonloader\1stPlatoon.lua") 
	thisScript():unload() 
	return
end

function download_handler(id, status, p1, p2)
	if stop_downloading then
		stop_downloading = false
		download_id = nil
		return false -- прервать загрузку
	end
	
	if status == dlstatus.STATUS_DOWNLOADINGDATA then
		print(string.format('Загружено %d из %d.', p1, p2))
		elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
		sysdownloadcomplete = true
	end
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            										