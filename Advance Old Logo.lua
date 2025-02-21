script_name('Advance RolePlay Blue Old Logo by routefleeder')
script_author('routefleeder')

local encoding = require('encoding')
encoding.default = 'CP1251'

local ffi = require('ffi')
ffi.cdef [[
    unsigned long GetTickCount();
]]

local function getTickCount()
    return ffi.C.GetTickCount()
end

local dlstatus = require('moonloader').download_status
local inicfg = require('inicfg')

update_state = false

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/routefleeder/arpoldlogo/refs/heads/main/update.ini"
local update_path = getWorkingDirectory() .. "/aol_update.ini"

local script_url = ""
local script_path = thisScript().path

local textdraws = {}
local timeout = 10000
local server_ip = "54.37.142.74"

function tableInsert()
	for i = 196, 209 do
    	table.insert(textdraws, i)
	end
end

function waitForTextdraws()
	local startTime = getTickCount()
    local allLoaded = false
    while not allLoaded do
        wait(100)
        allLoaded = true

        if getTickCount() - startTime > timeout then
            print("\nВремя ожидания истекло!\nСкрипт не смог найти стандартный текстдрав, так как его не существует или он был обновлён.")
            
            --тут была выгрузка скрипта, но я понял что её не должно тут быть

            return false
        end

        for _, id in ipairs(textdraws) do
            if not sampTextdrawIsExists(id) then
                allLoaded = false
                break
            end
        end
    end
    return true
end

function createTextdraw()
    sampTextdrawCreate(1111, 'Advance_RP', 540, 5)
    sampTextdrawSetProportional(1111, 1)
    sampTextdrawSetLetterSizeAndColor(1111, 0.333000, 1.666666, 0xFF2198F4)
    sampTextdrawSetOutlineColor(1111, 1, 0xFF041E88)
end

function main()
    while not isSampAvailable() do wait(0) end

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage('upd, v: ' .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)

    while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Обновлено", -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end

    while true do
    	wait(0)
        local ip, port = sampGetCurrentServerAddress()

	    if ip == server_ip and not sampTextdrawIsExists(1111) then
            tableInsert()

            if waitForTextdraws() then
                for _, id in ipairs(textdraws) do
                    sampTextdrawDelete(id)
                end
                
                createTextdraw()
            else
                thisScript():unload()
            end
        end
	end
end