script_author("Montri")
script_name("new autozoom")
script_version("1.0")

require"lib.moonloader"
require"lib.sampfuncs"
local inicfg = require "inicfg"
local key = require "vkeys"
local PressType = {KeyDown = isKeyDown, KeyPressed = wasKeyPressed}
----
onetwo = true

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("az", autozoom)
	while true do
		zoom()
		wait(1)
	end
end
function zoom()
	if isCurrentCharWeapon(PLAYER_PED, 34) and isKeyDown(2) and ToggleAutoZoom == true then
		local i = 0
		while(i <= 1000) do
			setGameKeyState(5, 255)
			i = i + 1
		end
	end
end
function keycheck(k)
    local r = true
    for i = 1, #k.k do
        r = r and PressType[k.t[i]](k.k[i])
    end
    return r
end

function isKeyControlAvailable()
	if not isSampLoaded() then return true end
	if not isSampfuncsLoaded() then return not sampIsChatInputActive() and not sampIsDialogActive() end
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end

function autozoom()
	ToggleAutoZoom = not ToggleAutoZoom
	if ToggleAutoZoom == true then
		onetwo = true
		sampAddChatMessage("{FFFFFF}Sniperautozoom has been turned on.")
		print("on")
	elseif ToggleAutoZoom == false then
		onetwo = false
		sampAddChatMessage("{FFFFFF}Sniperautozoom has been turned off.")
		print("on")
	end
end
