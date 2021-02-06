---- Remade Damageinformer v2.0 by MONTRI
-----------------------------------------
---- Contains Full imgui-Support and new extra features.
---- Has a complete rescrachted Damage-Informer System, with alot of bug-fixes.
-----------------------------------------

script_author("Montri")
script_version("2.0")
script_description("Remade Version of the old DamageInformer with alot of new features.")

require"lib.moonloader"
require"lib.sampfuncs"
local raknet = require"lib.samp.raknet"
local ffi =			require "ffi"
local events = require 'lib.samp.events.core'
local utils = require 'lib.samp.events.utils'
local handler	= require 'lib.samp.events.handlers'
            	require 'lib.samp.events.extra_types'
local sampevents = require "lib.samp.events"
local inicfg = require "inicfg"
local imgui = require "imgui"
local ec = require "encoding"
local moon = require "MoonAdditions"


ec.default = 'CP1251'
u8 = ec.UTF8

path = getWorkingDirectory() .. '\\config\\Montris Folder\\'
cfg = path .. 'DMGInformer.ini'

--- VARIABLES ----
MenuBar_Value = 0
Power_Name = "Power: Off"
taken = 0
given = 0

Give_Damage = 0
Give_PreviousDamage = 0
Give_Weapon = 0
Give_Bodypart = 0
Give_X = 0
Give_Y = 0
Give_Y = 0
Give_Boolean = false
Give_TextNumber = 0
Give_ID = 0
Give_PreviousID = 0
Give_Bell = 0
Give_StackedDamage = 0

Take_Damage = 0
Take_Weapon = 0
Take_Bell = 0
Take_Bodypart = 0
Take_ID = 0
Take_X = 0
Take_Y = 0
Take_Z = 0
Take_Boolean = false
Take_TextNumber = 0
Take_PreviousID = 0
Take_PreviousDamage = 0
Take_StackedDamage = 0


---- CONFIG SPECFIC ----

---- imgui ---
function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.WindowRounding = 2.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	style.ChildWindowRounding = 2.0
	style.FrameRounding = 2.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0
	colors[clr.Text]                   = ImVec4(0.82, 0.85, 0.83, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.50,0.20, 0.10, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.90, 0.53, 0.30, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.MenuBarBg]              = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.22, 0.23, 0.29, 1.00)
	colors[clr.ButtonHovered]          = ImVec4(0.18, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.Header]                 = ImVec4(255.26, 249.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.50, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.SeparatorActive]        = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.CloseButtonHovered]     = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.24, 0.23, 0.29, 1.00)
end
apply_custom_style()


local taken_damage = imgui.ImBool(false)
local bell_given = imgui.ImBool(false)
local takendamage_stacked = imgui.ImBool(false)
local damage_stacked = imgui.ImBool(false)
local bell_taken = imgui.ImBool(false)
local power = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)
function imgui.OnDrawFrame()
	if main_window_state.v then
		local sw, sh = getScreenResolution() -- Get Screenresolution to make perfect results.
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(620, 415), imgui.Cond.FirstUseEver)
		imgui.Begin("DMGInformer v2.0 by Montri", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.MenuBar + imgui.WindowFlags.NoCollapse)
		local btn_size = imgui.ImVec2(-0.1, 0)
		if imgui.BeginMenuBar() then
			if imgui.MenuItem("Main") then
				MenuBar_Value = 0
			end
			if imgui.MenuItem("Others") then
				MenuBar_Value = 1
			end
			imgui.EndMenuBar()
		end
		if MenuBar_Value == 0 then
			imgui.Text("                                                  This is the new DMGInformer v2.0 by Montri.")
			imgui.Text("For both Bell-modes: Have radio activated in your game settings!")
			--- GIVEN DAMAGE SECTION ----
			cheat_name = tostring(dmg.cheatcode)
			cheatcode_string = imgui.ImBuffer(cheat_name, 1000)
			imgui.PushItemWidth(115)
			if imgui.InputText("Cheat to open Menu", cheatcode_string) then
				dmg.cheatcode = cheatcode_string.v
			end
			imgui.PopItemWidth()
			if imgui.Checkbox(Power_Name, power) then
				dmg.power = power.v
				if power.v == true then
					Power_Name = "Power: On"
				else
					Power_Name = "Power: Off"
				end
			end
			if power.v == true then
				color = imgui.ImFloat3(hex2rgb(dmg.color[1]))
				imgui.PushItemWidth(115)
	            if imgui.ColorEdit3("Color of Given-Damage", color, imgui.ColorEditFlags.HEX) then
					dmg.color[1] = join_argb(255, color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
				end
				imgui.PopItemWidth()
				if imgui.Checkbox("Bell-Mode", bell_given) then
					dmg.bell = bell_given.v
				end
				imgui.SameLine()
				if imgui.Checkbox("Stacked-Damage", damage_stacked) then
					dmg.damage_stacked = damage_stacked.v
				end
				if bell_given.v == true then
					imgui.NewLine()
					local bell_number = imgui.ImInt(dmg.belltype)
					for number = 1,4 do
						if number == 1 or number == 2 or number == 4 then
							imgui.SameLine()
						end
						imgui.RadioButton("givendamage0".. number .. ".mp3", bell_number, number)
					end
					givenbell = loadAudioStream("moonloader\\resource\\montris audio\\" .. "givendamage0".. bell_number.v .. ".mp3")
					Give_Bell = givenbell
					if dmg.belltype ~= bell_number.v then
						dmg.belltype = bell_number.v
						printStringNow("Given-Bell " .. dmg.belltype .. " loaded successfully!"
						, 2000)
						setAudioStreamState(givenbell, 1)
					end
				end
			end
			--- TAKEN DAMAGE SECTION ----
			imgui.NewLine()
			if imgui.Checkbox("Activate Taken-Damage", taken_damage) then
				dmg.takendamagemode = taken_damage.v
			end
			if taken_damage.v == true then
				if taken_damage.v == true then
					takencolor = imgui.ImFloat3(hex2rgb(dmg.takencolor[1]))
					imgui.PushItemWidth(115)
					if imgui.ColorEdit3("Color of Taken-Damage", takencolor, imgui.ColorEditFlags.HEX) then
						dmg.takencolor[1] = join_argb(255, takencolor.v[1] * 255, takencolor.v[2] * 255, takencolor.v[3] * 255)
					end
					imgui.PopItemWidth()
				end
				if imgui.Checkbox("Taken-Bell-Mode", bell_taken) then
					dmg.takenbell = bell_taken.v
				end
				imgui.SameLine()
				if imgui.Checkbox("Taken-Stacked-Damage", takendamage_stacked) then
					dmg.takendamage_stacked = takendamage_stacked.v
				end
				if bell_taken.v == true then
					imgui.NewLine()
					local bell_number_taken = imgui.ImInt(dmg.takenbell_type)
					for number = 1,4 do
						if number == 1 or number == 2 or number == 4 then
							imgui.SameLine()
						end
						imgui.RadioButton("takendamage0".. number .. ".mp3", bell_number_taken, number)
					end
					takenbell = loadAudioStream("moonloader\\resource\\montris audio\\" .. "takendamage0".. bell_number_taken.v .. ".mp3")
					Take_Bell = takenbell
					if dmg.takenbell_type ~= bell_number_taken.v then
						dmg.takenbell_type = bell_number_taken.v
						printStringNow("Taken-Bell " .. dmg.takenbell_type .. " loaded successfully!"
						, 2000)
						setAudioStreamState(takenbell, 1)
					end
				end
			end
			---- BUTTON SECTION, UNRELATED TO ANYTHING ----
			if imgui.Button("Save Config") then
				saveIni()
				printStringNow("DMG Settings have been saved.",2000)
			end
			imgui.SameLine()
			if imgui.Button("Load Config") then
				loadIni()
				printStringNow("DMG Settings have been loaded.",2000)
			end
			imgui.SameLine()
			if imgui.Button("Generate Fresh Config (GFC)") then
				blankIni()
				printStringNow("DMG Config has been regenerated.",2000)
			end
			imgui.Text("GFC Button allows you to regenerate a config, without needing to delete it for future Version updates.")
		end
		imgui.End()
	end
end

function hex2rgba(rgba)
	local a = bit.band(bit.rshift(rgba, 24),	0xFF)
	local r = bit.band(bit.rshift(rgba, 16),	0xFF)
	local g = bit.band(bit.rshift(rgba, 8),		0xFF)
	local b = bit.band(rgba, 0xFF)
	return r / 255, g / 255, b / 255, a / 255
end

function hex2rgba_int(rgba)
	local a = bit.band(bit.rshift(rgba, 24),	0xFF)
	local r = bit.band(bit.rshift(rgba, 16),	0xFF)
	local g = bit.band(bit.rshift(rgba, 8),		0xFF)
	local b = bit.band(rgba, 0xFF)
	return r, g, b, a
end

function hex2rgb(rgba)
	local a = bit.band(bit.rshift(rgba, 24),	0xFF)
	local r = bit.band(bit.rshift(rgba, 16),	0xFF)
	local g = bit.band(bit.rshift(rgba, 8),		0xFF)
	local b = bit.band(rgba, 0xFF)
	return r / 255, g / 255, b / 255
end

function hex2rgb_int(rgba)
	local a = bit.band(bit.rshift(rgba, 24),	0xFF)
	local r = bit.band(bit.rshift(rgba, 16),	0xFF)
	local g = bit.band(bit.rshift(rgba, 8),		0xFF)
	local b = bit.band(rgba, 0xFF)
	return r, g, b
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function blankIni()
	dmg = {
		cheatcode = "damage",
		power = true,
		damage_stacked = false,
		color = {-1},
		bell = true,
		belltype = 2,
		taken_damage_mode = false,
		takendamage_stacked = false,
		takencolor = {-5},
		takenbell = true,
		takenbell_type = 4,
	}
	saveIni()
end

function loadIni()
	local f = io.open(cfg, "r")
	if f then
		dmg = decodeJson(f:read("*all"))
		f:close()
	end
end

function saveIni()
	if type(dmg) == "table" then
		local f = io.open(cfg, "w")
		f:close()
		if f then
			local f = io.open(cfg, "r+")
			f:write(encodeJson(dmg))
			f:close()
		end
	end
end

function hexConvert(number)
	local hex = string.format("%x", number)
	return hex
end

function hexToDecimalConvert(hex)
	local number = tonumber(hex, 16)
	return number
end


----- BELONGINGS OF THE IMGUI MENU ---------
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	if not doesDirectoryExist(path) then createDirectory(path) end
	if doesFileExist(cfg) then loadIni() else blankIni() end
	while not isSampAvailable() do wait(100) end
	sampAddChatMessage("{FFA876}[DMGInformer] {FFFFFF}Updated by Montri.")
	while true do
		wait(0)
		updateMenuVariables()
		createGiveNumber()
		createTakeNumber()
		if testCheat(dmg.cheatcode) then
			main_window_state.v = not main_window_state.v
		end
		imgui.Process = main_window_state.v
	end
end
----- DAMAGE INFORMER RELATED ---------

function sampevents.onSendGiveDamage(targetID, damage, weapon, Bodypart)
	local result, targetPed = sampGetCharHandleBySampPlayerId(targetID)
	local tX, tY, tZ = getCharCoordinates(targetPed)
	Give_Damage = damage
	Give_Weapon = weapon
	Give_Bodypart = Bodypart
	Give_ID = targetID
	Give_Boolean = true
	lua_thread.create(startRemovingGiveTimer)
end

function sampevents.onSendTakeDamage(senderID, damage, weapon, Bodypart)
	Take_ID = senderID
	Take_Bodypart = Bodypart
	Take_Damage = damage
	Take_Weapon = weapon
	Take_Boolean = true
	lua_thread.create(startRemovingTakeTimer)
end

distance = 300
function createGiveNumber()
	if sampIsPlayerConnected(Give_ID) and dmg.power == true and Give_Boolean == true then
		Give_TextNumber = Give_TextNumber + 1
		--local x, y, z = calculateGiveNumberPos(Give_Bodypart)
		local getted, remotePlayer = sampGetCharHandleBySampPlayerId(Give_ID)
		if getted then
			local bx, by, bz = calculateGiveNumberPos(Give_Bodypart)
			local x, y, z = getCharCoordinates(remotePlayer)
			local damage = tonumber(Give_Damage)
			Give_Damage = roundDamage(damage, 2)
			Give_StackedDamage = Give_StackedDamage + Give_Damage
			Give_StackedDamage = roundDamage(Give_StackedDamage, 2)
			if dmg.damage_stacked == true then
				if Give_PreviousID == Give_ID then
					sampCreate3dTextEx(Give_TextNumber, Give_StackedDamage, dmg.color[1], x - bx, y - by, z - bz, distance, false, -1, -1)
				else
					Give_PreviousID = Give_ID
					Give_PreviousDamage = Give_Damage
					Give_StackedDamage = Give_PreviousDamage
					sampCreate3dTextEx(Give_TextNumber, Give_Damage, dmg.color[1], x - bx, y - by, z - bz, distance, false, -1, -1)
				end
			else
				sampCreate3dTextEx(Give_TextNumber, Give_Damage, dmg.color[1], x - bx, y - by, z - bz, distance, false, -1, -1)
			end
			sampDestroy3dText(Give_TextNumber - 1)
		end
		if bell_given.v == true then
			setAudioStreamState(Give_Bell, 1)
		end
		Give_Boolean = false
	end
end


function createTakeNumber()
	if dmg.takendamagemode == true and Take_Boolean == true then
		Take_TextNumber = Take_TextNumber + 1
		local x, y, z = getCharCoordinates(PLAYER_PED)
		Take_X = x
		Take_Y = y
		Take_Z = z
		--local x, y, z = calculateGiveNumberPos(Take_Bodypart)
		local take_damage = tonumber(Take_Damage)
		local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		Take_Damage = roundDamage(take_damage, 2)
		Take_StackedDamage = Take_StackedDamage + Take_Damage
		Take_StackedDamage = roundDamage(Take_StackedDamage)
		if result then
			if dmg.takendamage_stacked == true then
				if Take_PreviousID == Take_ID then
					sampCreate3dTextEx(Take_TextNumber, "-"..Take_StackedDamage, dmg.takencolor[1], x, y, z, 50, false, -1, -1)
				else
					Take_PreviousID = Take_ID
					Take_PreviousDamage = Take_Damage
					Take_StackedDamage = Take_PreviousDamage
					sampCreate3dTextEx(Take_TextNumber, "-"..Take_Damage, dmg.takencolor[1], x, y, z, 50, false, -1, -1)
				end
			else
				sampCreate3dTextEx(Take_TextNumber, "-"..Take_Damage, dmg.takencolor[1], x, y, z, 50, false, -1, -1)
				--print(id)
			end
			sampDestroy3dText(Take_TextNumber - 1)
			if bell_taken.v == true  then
				setAudioStreamState(Take_Bell, 1)
			end
			Take_Boolean = false
		end
	end
end

function getBodyPartCoordinates(Bodypart, ped)
	local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
	local result, id = sampGetPlayerIdByCharHandle(PLAYER_HANDLE)
	for name, id in pairs(moon.bone_id) do
				local bone = moon.get_char_bone(PLAYER_PED, id)
				if bone then
					local bone_pos = bone.matrix.pos
					if id == Bodypart then
						return bone_pos.x, bone_pos.y, bone_pos.z
					end
				end
	end
end

function calculateGiveNumberPos(Bodypart)
	local x = 0
	local y = 0
	local y = 0
	if Bodypart == 9 then --- HEAD
		x = 0
		y = 0
		z = 0
	elseif Bodypart == 6 then -- LEFT ARM
		x = 0
		y = -0.2
		z = -0.5
	elseif Bodypart == 5 then -- RIGHT ARM
		x = 0
		y = 0.2
		z = -0.5
	elseif Bodypart == 3 then -- Body
		x = 0
		y = 0
		z = -0.5
	elseif Bodypart == 8 then -- Left Leg
		x = 0
		y = -0.125
		z = -0.9
	elseif Bodypart == 7 then -- Right Leg
		x = 0
		y = 0.125
		z = -0.9
	end
	return x, y, z
end

function updateMenuVariables()
	if dmg.power == true then
		power.v = true
		Power_Name = "Power: On"
	end
	if dmg.takendamagemode == true then
		taken_damage.v = true
	end
	--- GIVEN MODE ---
	if dmg.damage_stacked == true then
		damage_stacked.v = true
	end
	if dmg.bell == true then
		bell_given.v = true
		if given == 0 then
			Give_Bell = loadAudioStream("moonloader\\resource\\montris audio\\" .. "givendamage0".. dmg.belltype .. ".mp3")
			given = 1
		end
	end
 	--- TAKEN MODE ----
	if dmg.takenbell == true then
		bell_taken.v = true
		if taken == 0 then
			Take_Bell = loadAudioStream("moonloader\\resource\\montris audio\\" .. "takendamage0".. dmg.takenbell_type .. ".mp3")
			taken = 1
		end
	end
	if dmg.takendamage_stacked == true then
		takendamage_stacked.v = true
	end
end


function roundDamage(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function startRemovingGiveTimer()
	local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if result then
		if sampIsPlayerPaused(id) then
			sampDestroy3dText(Give_TextNumber)
		end
	end
	wait(3000)
	sampDestroy3dText(Give_TextNumber)
end

function startRemovingTakeTimer()
	wait(3000)
	sampDestroy3dText(Take_TextNumber)
end
