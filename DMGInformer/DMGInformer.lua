---- Final 3.0 Version of Montri's Damageinformer
---- OPEN SOURCE
-----------------------------------------
---- Contains Full imgui-Support and new extra features.
---- Has a complete rescrachted Damage-Informer System, with alot of bug-fixes.
-----------------------------------------

script_author("Montri")
script_version("3.0")
script_description("Final version of this DMGInformer")

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
local lfs        = require 'lfs'


ec.default = 'CP1251'
u8 = ec.UTF8

path = getWorkingDirectory() .. '\\config\\Montris Folder\\'
cfg = path .. 'DMGInformer.ini'

--- VARIABLES ----
MenuBar_Value = 0
Power_Name = "Power: {CF2222}Off"
taken = 0
given = 0
death = 0
kill = 0
paths = {}
errorlog_messages = {[1] = "{ABB2B9}[DMGInformer]{FFFFFF} Error 1: The audiofile may be corrupted. Try redownloading or regaining it.", [2] = "{ABB2B9}[DMGInformer]{FFFFFF} Error 2: You tried saving a sound, while its respective option is turned off.",
[3] = "{ABB2B9}[DMGInformer]{FFFFFF} Error 3: You tried saving a config, while no config was opened (GUI).", [4] = "{ABB2B9}[DMGInformer]{FFFFFF} Error 4: You tried loading a config, while no config was opened (GUI).", [5] = "{ABB2B9}[DMGInformer]{FFFFFF} Error 5: Your audiofile has either been moved, removed or doesnt exist."}

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

Death_Bell = 0
Kill_Bell = 0


---- CONFIG SPECFIC ----

local fsFont = nil
function imgui.BeforeDrawFrame()
	if fsFont == nil then
        fsFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
end


local taken_damage = imgui.ImBool(false)
local takendamage_stacked = imgui.ImBool(false)
local damage_stacked = imgui.ImBool(false)
local given_lockbody = imgui.ImBool(false)

local power = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)
local given_decimalss = imgui.ImBool(false)
local taken_decimalss = imgui.ImBool(false)
local audio_manager_state = imgui.ImBool(false)
local scripttype = "Sound Select"

local child_modes = 0
local Bell_Mode = "{CF2222}Off"
local Bell_Mode2 = "{CF2222}Off"
local stack_damage = "{CF2222}Off"
local lockbody = "{CF2222}Off"
local given_decimals = "{CF2222}Off"
local taken_decimals = "{CF2222}Off"
local taken_damager = "{CF2222}Off"
local taken_stacked = "{CF2222}Off"
local searchscript    = imgui.ImBuffer(256)
local sound_selector = 0
local Bell_Mode3 = "{CF2222}Off"
local Bell_Mode4 = "{CF2222}Off"

local death_bell = imgui.ImBool(false)
local kill_bell = imgui.ImBool(false)
local bell_taken = imgui.ImBool(false)
local bell_given = imgui.ImBool(false)
function imgui.OnDrawFrame()
	if main_window_state.v then
		local sw, sh = getScreenResolution() -- Get Screenresolution to make perfect results.
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 415), imgui.Cond.FirstUseEver)
		imgui.Begin("", _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
		imgui.PushFont(fsFont) imgui.CenterTextColoredRGB('DMGInformer v3.0') imgui.PopFont()
		imgui.Hint("Made by Montri.", 1)
		imgui.BeginChild('Damage-Modes', imgui.ImVec2(170, 370), true)
		if imgui.Button("Given-Damage", imgui.ImVec2(160, 100)) then
			child_modes = 1
		end 
		if imgui.Button("Taken-Damage", imgui.ImVec2(160, 100)) then
			child_modes = 2
		end
		imgui.Text("")
		imgui.Text("")
		imgui.Text("")
		imgui.Text("")
		if imgui.Button("Load Settings", imgui.ImVec2(160, 32)) then
			if child_modes == 1 or child_modes == 2 then
				loadIni()
				printStringNow("Config has been loaded!", 2000)
			else
				sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 4 occured. Use /dmgerror 3 to gain information.")
			end 
		end 
		if imgui.Button("Save Settings", imgui.ImVec2(160, 32)) then 
			if child_modes == 1 or child_modes == 2 then
				saveIni()
				printStringNow("Config has been saved!", 2000)
			else
				sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 3 occured. Use /dmgerror 3 to gain information.")
			end 
		end 
		imgui.EndChild()
		if child_modes == 1 then
			imgui.SameLine()
			imgui.BeginChild('Given-Mode', imgui.ImVec2(405, 370), true)
			if imgui.Checkbox("", power) then
				dmg.power = power.v
				if power.v == true then
					Power_Name = "Power: {22CF31}On"
				else
					Power_Name = "Power: {CF2222}Off"
				end
			end
			imgui.SameLine() 
			imgui.TextColoredRGB(Power_Name)
			if power.v == true then
				imgui.NewLine()
				color = imgui.ImFloat3(hex2rgb(dmg.color[1]))
				imgui.PushItemWidth(90)
	            if imgui.ColorEdit3("Color of Damage", color, imgui.ColorEditFlags.HEX) then
					dmg.color[1] = join_argb(255, color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
				end
				imgui.PopItemWidth()
				if imgui.Checkbox("Stack Damage:", damage_stacked) then
					dmg.damage_stacked = damage_stacked.v
					if dmg.damage_stacked == true then
						stack_damage = "{22CF31}On"
					else 
						stack_damage = "{CF2222}Off"
					end 
				end
				imgui.SameLine() 
				imgui.TextColoredRGB(stack_damage)
				imgui.SameLine(150)
				if imgui.Checkbox("Decimals:", given_decimalss) then
					dmg.given_showdecimals = given_decimalss.v
					if dmg.given_showdecimals == true then
						given_decimals = "{22CF31}On"
					else 
						given_decimals = "{CF2222}Off"
					end 
				end 
				imgui.SameLine(0) 
				imgui.TextColoredRGB(given_decimals)
				imgui.NewLine()
				if imgui.Checkbox("Use Bell:", bell_given) then
					dmg.bell = bell_given.v
					if bell_given.v == true then
						Bell_Mode = "{22CF31}On"
					else 
						Bell_Mode = "{CF2222}Off"
					end 
				end
				imgui.SameLine(0) 
				imgui.TextColoredRGB(Bell_Mode)
				if bell_given.v == true then
					if imgui.Button("Open Audio File Manager", imgui.ImVec2(400, 75)) then
						audio_manager_state.v = not audio_manager_state.v
					end 
				end 
			end 
			imgui.EndChild()
		end 
		if child_modes == 2 then
			imgui.SameLine()
			imgui.BeginChild('Taken-Mode', imgui.ImVec2(405, 370), true)
			if imgui.Checkbox("Power:", taken_damage) then
				dmg.taken_damage_mode = taken_damage.v
				if taken_damage.v == true then
					taken_damager = "{22CF31}On"
				else
					taken_damager = "{CF2222}Off"
				end
			end
			imgui.SameLine() 
			imgui.TextColoredRGB(taken_damager)
			if taken_damage.v == true then
				imgui.NewLine()
				color2 = imgui.ImFloat3(hex2rgb(dmg.takencolor[1]))
				imgui.PushItemWidth(90)
	            if imgui.ColorEdit3("Color of Received Damage", color2, imgui.ColorEditFlags.HEX) then
					dmg.takencolor[1] = join_argb(255, color2.v[1] * 255, color2.v[2] * 255, color2.v[3] * 255)
				end
				imgui.PopItemWidth()
				if imgui.Checkbox("Stack Damage:", takendamage_stacked) then
					dmg.takendamage_stacked = takendamage_stacked.v
					if dmg.takendamage_stacked == true then
						taken_stacked = "{22CF31}On"
					else 
						taken_stacked = "{CF2222}Off"
					end 
				end
				imgui.SameLine() 
				imgui.TextColoredRGB(taken_stacked)
				imgui.SameLine(150)
				if imgui.Checkbox("Decimals:", taken_decimalss) then
					dmg.taken_showdecimals = taken_decimalss.v
					if dmg.taken_showdecimals == true then
						taken_decimals = "{22CF31}On"
					else 
						taken_decimals = "{CF2222}Off"
					end 
				end 
				imgui.SameLine(0) 
				imgui.TextColoredRGB(taken_decimals)
				imgui.NewLine()
				if imgui.Checkbox("Use Bell:", bell_taken) then
					dmg.takenbell = bell_taken.v
					if bell_taken.v == true then
						Bell_Mode2 = "{22CF31}On"
					else 
						Bell_Mode2 = "{CF2222}Off"
					end 
				end
				imgui.SameLine(0) 
				imgui.TextColoredRGB(Bell_Mode2)
				if bell_taken.v == true then
					if imgui.Button("Open Audio File Manager", imgui.ImVec2(400, 75)) then
						audio_manager_state.v = not audio_manager_state.v
					end 
				end 
			end 
			imgui.EndChild()
		end 
		imgui.End()
	end
	if audio_manager_state.v then
		local sw, sh = getScreenResolution() -- Get Screenresolution to make perfect results.
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 435), imgui.Cond.FirstUseEver)
		imgui.Begin(" ", audio_manager_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.MenuBar)
		imgui.PushFont(fsFont) imgui.CenterTextColoredRGB('Audio File Manager') imgui.PopFont()
		if imgui.Checkbox("Death-Bell: ", death_bell) then
			dmg.deathbell = death_bell.v
			if death_bell.v == true then
				Bell_Mode3 = "{22CF31}On"
			else 
				Bell_Mode3 = "{CF2222}Off"
			end 
		end 
		imgui.SameLine()
		imgui.TextColoredRGB(Bell_Mode3)
		imgui.SameLine()
		if imgui.Checkbox("Kill-Sound: ", kill_bell) then
			dmg.killbell = kill_bell.v
			if kill_bell.v == true then
				Bell_Mode4 = "{22CF31}On"
			else 
				Bell_Mode4 = "{CF2222}Off"
			end 
		end 
		imgui.SameLine()
		imgui.TextColoredRGB(Bell_Mode4)
		imgui.SameLine()
		if imgui.Checkbox("Given-Sound:", bell_given) then
			dmg.bell = bell_given.v
			if bell_given.v == true then
				Bell_Mode = "{22CF31}On"
			else 
				Bell_Mode = "{CF2222}Off"
			end 
		end
		imgui.SameLine() 
		imgui.TextColoredRGB(Bell_Mode)
		imgui.SameLine()
		if imgui.Checkbox("Taken-Sound:", bell_taken) then
			dmg.takenbell = bell_taken.v
			if bell_taken.v == true then
				Bell_Mode2 = "{22CF31}On"
			else 
				Bell_Mode2 = "{CF2222}Off"
			end 
		end
		imgui.SameLine() 
		imgui.TextColoredRGB(Bell_Mode2)
		imgui.SameLine()
		if imgui.Button("Save Settings") then
			saveIni()
			printStringNow("Sound-Settings have been saved.", 2000)
		end 
		if imgui.Button("Back to Main", imgui.ImVec2(590, 30)) then
			audio_manager_state.v = false 
		end 
		if imgui.BeginMenuBar() then
			if imgui.BeginMenu(scripttype, true) then
				if imgui.MenuItem("Given-Sound") then
					scripttype = "Given-Sound"
					sound_selector = 1 
				end 
				imgui.Separator()
				if imgui.MenuItem("Taken-Sound") then
					scripttype = "Taken-Sound"
					sound_selector = 2 
				end 
				imgui.Separator()
				if imgui.MenuItem("Death-Sound") then
					scripttype = "Death-Sound"
					sound_selector = 3
				end 
				imgui.Separator()
				if imgui.MenuItem("Kill-Sound") then
					scripttype = "Kill-Sound"
					sound_selector = 4
				end 
				imgui.EndMenu()
			end 
			imgui.EndMenuBar()
		end 
		if sound_selector == 4 then
			imgui.BeginChild('##AUDIO1', imgui.ImVec2(180, 315), true)
				for k,s in pairs(paths) do
					k = tostring(k)
					if k:match(".+%.mp3") or k:match(".+%.mp4") or k:match(".+%.wav") or k:match(".+%.m4a") or k:match(".+%.flac") or k:match(".+%.m4r") or k:match(".+%.ogg") or k:match(".+%.mp2") or
					k:match(".+%.amr") or k:match(".+%.wma") or k:match(".+%.aac") or k:match(".+%.aiff") then
						if imgui.Button(k, imgui.ImVec2(160, 25)) then
							state = k
						end 
					end 
				end 
				imgui.EndChild()
				local result, path = checkIf(state, paths)
				if result then
					imgui.SameLine()
					local music_value = 0
					imgui.BeginChild('##AUDIO2', imgui.ImVec2(400, 265), true)
					imgui.Text(string.format("Path: %s", path))
					imgui.Text(string.format("File selected: %s", state))
					local state2 = state
					state2 = string.match(state, "([^\\%.]+)$")
					state2 = "." .. state2
					if state2 == ".wav" then
						imgui.Text(string.format("File Extension: %s | or named: Waveform Audio File Format", state2))
					end 
					if state2 == ".aiff" then
						imgui.Text(string.format("File Extension: %s | or named: Audio Interchange File Format", state2))
					end 
					if state2 == ".mp3" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 3", state2))
					end 
					if state2 == ".aac" then
						imgui.Text(string.format("File Extension: %s | or named: Advanced Audio Coding", state2))
					end 
					if state2 == ".wma" then
						imgui.Text(string.format("File Extension: %s | or named: Windows Media Audio", state2))
					end 
					if state2 == ".flac" then
						imgui.Text(string.format("File Extension: %s | or named: Free Lossless Audio Codec", state2))
					end 
					if state2 == ".m4a" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Audio File", state2))
					end 
					if state2 == ".mp4" or state2 == ".m4r" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Multimedia File", state2))
					end 
					if state2 == ".ogg" then
						imgui.Text(string.format("File Extension: %s | or named: Container Dataformat", state2))
					end 
					if state2 == ".mp2" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 2", state2))
					end 
					if imgui.Button("Test the Sound", imgui.ImVec2(160, 25)) then
						music_value = loadAudioStream(path)
						if music_value == 0 then
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 1 occured. Please use /dmgerror 1 to gain information.")
						else
							setAudioStreamState(music_value, 1)
							printStringNow("Works just fine. ")
						end 
					end 
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					if imgui.Button("Add as Kill-Sound", imgui.ImVec2(160, 25)) then
						if dmg.killbell == true then
							dmg.kill_externalbell = path
							saveIni()
							printStringNow("Kill-Sound has been saved.", 2000)
							Kill_Bell = loadAudioStream(dmg.kill_externalbell)
						else 
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 2 occured. Please use /dmgerror 2 to gain information.")
						end 
					end 
					imgui.EndChild()
				end 
		end 
		if sound_selector == 3 then
			imgui.BeginChild('##AUDIO1', imgui.ImVec2(180, 315), true)
				for k,s in pairs(paths) do
					k = tostring(k)
					if k:match(".+%.mp3") or k:match(".+%.mp4") or k:match(".+%.wav") or k:match(".+%.m4a") or k:match(".+%.flac") or k:match(".+%.m4r") or k:match(".+%.ogg") or k:match(".+%.mp2") or
					k:match(".+%.amr") or k:match(".+%.wma") or k:match(".+%.aac") or k:match(".+%.aiff") then
						if imgui.Button(k, imgui.ImVec2(160, 25)) then
							state = k
						end 
					end 
				end 
				imgui.EndChild()
				local result, path = checkIf(state, paths)
				if result then
					imgui.SameLine()
					local music_value = 0
					imgui.BeginChild('##AUDIO2', imgui.ImVec2(400, 265), true)
					imgui.Text(string.format("Path: %s", path))
					imgui.Text(string.format("File selected: %s", state))
					local state2 = state
					state2 = string.match(state, "([^\\%.]+)$")
					state2 = "." .. state2
					if state2 == ".wav" then
						imgui.Text(string.format("File Extension: %s | or named: Waveform Audio File Format", state2))
					end 
					if state2 == ".aiff" then
						imgui.Text(string.format("File Extension: %s | or named: Audio Interchange File Format", state2))
					end 
					if state2 == ".mp3" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 3", state2))
					end 
					if state2 == ".aac" then
						imgui.Text(string.format("File Extension: %s | or named: Advanced Audio Coding", state2))
					end 
					if state2 == ".wma" then
						imgui.Text(string.format("File Extension: %s | or named: Windows Media Audio", state2))
					end 
					if state2 == ".flac" then
						imgui.Text(string.format("File Extension: %s | or named: Free Lossless Audio Codec", state2))
					end 
					if state2 == ".m4a" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Audio File", state2))
					end 
					if state2 == ".mp4" or state2 == ".m4r" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Multimedia File", state2))
					end 
					if state2 == ".ogg" then
						imgui.Text(string.format("File Extension: %s | or named: Container Dataformat", state2))
					end 
					if state2 == ".mp2" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 2", state2))
					end 
					if imgui.Button("Test the Sound", imgui.ImVec2(160, 25)) then
						music_value = loadAudioStream(path)
						if music_value == 0 then
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 1 occured. Please use /dmgerror 1 to gain information.")
						else
							setAudioStreamState(music_value, 1)
							printStringNow("Works just fine. ")
						end 
					end 
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					if imgui.Button("Add as Death-Sound", imgui.ImVec2(160, 25)) then
						if dmg.deathbell == true then
							dmg.death_externalbell = path
							saveIni()
							printStringNow("Death-Sound has been saved.", 2000)
							Death_Bell = loadAudioStream(dmg.death_externalbell)
						else 
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 2 occured. Please use /dmgerror 2 to gain information.")
						end 
					end 
					imgui.EndChild()
				end 
		end 
		if sound_selector == 2 then
			imgui.BeginChild('##AUDIO1', imgui.ImVec2(180, 315), true)
				for k,s in pairs(paths) do
					k = tostring(k)
					if k:match(".+%.mp3") or k:match(".+%.mp4") or k:match(".+%.wav") or k:match(".+%.m4a") or k:match(".+%.flac") or k:match(".+%.m4r") or k:match(".+%.ogg") or k:match(".+%.mp2") or
					k:match(".+%.amr") or k:match(".+%.wma") or k:match(".+%.aac") or k:match(".+%.aiff") then
						if imgui.Button(k, imgui.ImVec2(160, 25)) then
							state = k
						end 
					end 
				end 
				imgui.EndChild()
				local result, path = checkIf(state, paths)
				if result then
					imgui.SameLine()
					local music_value = 0
					imgui.BeginChild('##AUDIO2', imgui.ImVec2(400, 265), true)
					imgui.Text(string.format("Path: %s", path))
					imgui.Text(string.format("File selected: %s", state))
					local state2 = state
					state2 = string.match(state, "([^\\%.]+)$")
					state2 = "." .. state2
					if state2 == ".wav" then
						imgui.Text(string.format("File Extension: %s | or named: Waveform Audio File Format", state2))
					end 
					if state2 == ".aiff" then
						imgui.Text(string.format("File Extension: %s | or named: Audio Interchange File Format", state2))
					end 
					if state2 == ".mp3" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 3", state2))
					end 
					if state2 == ".aac" then
						imgui.Text(string.format("File Extension: %s | or named: Advanced Audio Coding", state2))
					end 
					if state2 == ".wma" then
						imgui.Text(string.format("File Extension: %s | or named: Windows Media Audio", state2))
					end 
					if state2 == ".flac" then
						imgui.Text(string.format("File Extension: %s | or named: Free Lossless Audio Codec", state2))
					end 
					if state2 == ".m4a" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Audio File", state2))
					end 
					if state2 == ".mp4" or state2 == ".m4r" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Multimedia File", state2))
					end 
					if state2 == ".ogg" then
						imgui.Text(string.format("File Extension: %s | or named: Container Dataformat", state2))
					end 
					if state2 == ".mp2" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 2", state2))
					end 
					if imgui.Button("Test the Sound", imgui.ImVec2(160, 25)) then
						music_value = loadAudioStream(path)
						if music_value == 0 then
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 1 occured. Please use /dmgerror 1 to gain information.")
						else
							setAudioStreamState(music_value, 1)
							printStringNow("Works just fine. ")
						end 
					end 
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					if imgui.Button("Add as Taken-Sound", imgui.ImVec2(160, 25)) then
						if dmg.takenbell == true then
							dmg.taken_externalbell = path
							saveIni()
							printStringNow("Taken-Sound has been saved.", 2000)
							Take_Bell = loadAudioStream(dmg.taken_externalbell)
						else 
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 2 occured. Please use /dmgerror 2 to gain information.")
						end 
					end 
					imgui.EndChild()
				end 
		end 
		if sound_selector == 1 then
			imgui.BeginChild('##AUDIO1', imgui.ImVec2(180, 315), true)
				for k,s in pairs(paths) do
					k = tostring(k)
					if k:match(".+%.mp3") or k:match(".+%.mp4") or k:match(".+%.wav") or k:match(".+%.m4a") or k:match(".+%.flac") or k:match(".+%.m4r") or k:match(".+%.ogg") or k:match(".+%.mp2") or
					k:match(".+%.amr") or k:match(".+%.wma") or k:match(".+%.aac") or k:match(".+%.aiff") then
						if imgui.Button(k, imgui.ImVec2(160, 25)) then
							state = k
						end 
					end 
				end 
				imgui.EndChild()
				local result, path = checkIf(state, paths)
				if result then
					imgui.SameLine()
					local music_value = 0
					imgui.BeginChild('##AUDIO2', imgui.ImVec2(400, 265), true)
					imgui.Text(string.format("Path: %s", path))
					imgui.Text(string.format("File selected: %s", state))
					local state2 = state
					state2 = string.match(state, "([^\\%.]+)$")
					state2 = "." .. state2
					if state2 == ".wav" then
						imgui.Text(string.format("File Extension: %s | or named: Waveform Audio File Format", state2))
					end 
					if state2 == ".aiff" then
						imgui.Text(string.format("File Extension: %s | or named: Audio Interchange File Format", state2))
					end 
					if state2 == ".mp3" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 3", state2))
					end 
					if state2 == ".aac" then
						imgui.Text(string.format("File Extension: %s | or named: Advanced Audio Coding", state2))
					end 
					if state2 == ".wma" then
						imgui.Text(string.format("File Extension: %s | or named: Windows Media Audio", state2))
					end 
					if state2 == ".flac" then
						imgui.Text(string.format("File Extension: %s | or named: Free Lossless Audio Codec", state2))
					end 
					if state2 == ".m4a" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Audio File", state2))
					end 
					if state2 == ".mp4" or state2 == ".m4r" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-4 Multimedia File", state2))
					end 
					if state2 == ".ogg" then
						imgui.Text(string.format("File Extension: %s | or named: Container Dataformat", state2))
					end 
					if state2 == ".mp2" then
						imgui.Text(string.format("File Extension: %s | or named: MPEG-1 Audio Layer 2", state2))
					end 
					if imgui.Button("Test the Sound", imgui.ImVec2(160, 25)) then
						music_value = loadAudioStream(path)
						if music_value == 0 then
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 1 occured. Please use /dmgerror 1 to gain information.")
						else
							setAudioStreamState(music_value, 1)
							printStringNow("Works just fine. ")
						end 
					end 
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					imgui.Text("")
					if imgui.Button("Add as Given-Sound", imgui.ImVec2(160, 25)) then
						if dmg.bell == true then
							dmg.given_externalbell = path
							Give_Bell = loadAudioStream(dmg.given_externalbell)
							saveIni()
							printStringNow("Given-Sound has been saved.", 2000)
						else 
							sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 2 occured. Please use /dmgerror 2 to gain information.")
						end 
					end 
					imgui.EndChild()
				end 
		end 
		imgui.End()
	end 
end

function scanGameFolder(path, tables)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'\\'..file
            --print ("\t "..f)
			--local file3 = string.gsub(file_extension, "(.+)%..+", "Test")
			local file_extension = string.match(file, "([^\\%.]+)$") -- Avoids double "extension" file names from being included and seen as "audiofile"
            if file_extension:match("mp3") or file_extension:match("mp4") or file_extension:match("wav") or file_extension:match("m4a") or file_extension:match("flac") or file_extension:match("m4r") or file_extension:match("ogg")
			or file_extension:match("mp2") or file_extension:match("amr") or file_extension:match("wma") or file_extension:match("aac") or file_extension:match("aiff") then
				table.insert(tables, file)
                tables[file] = f
            end 
            if lfs.attributes(f, "mode") == "directory" then
                tables = scanGameFolder(f, tables)
            end 
        end
    end
    return tables
end

function checkIf(input, path)
	local i = 0
	local string = ""
	for key, value in pairs(path) do
		if key == input then
			i = i + 1
			string = value
		end 
	end 
	if i > 0 then
		return true,string
	elseif i == 0 or i < 0 then
		return false,string
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
		power = true,
		damage_stacked = false,
		given_lockbody = false,
		given_showdecimals = true,
		given_externalbell = "moonloader//resource//montris audio//givendamage02.mp3",
		color = {-1},
		bell = true,
		taken_damage_mode = false,
		takendamage_stacked = false,
		takencolor = {-5},
		takenbell = true,
		taken_lockbody = false,
		taken_showdecimals = false,
		taken_externalbell = "moonloader//resource//montris audio//takendamage03.mp3",
		deathbell = false,
		death_externalbell = "moonloader//resource//montris audio//deathsound01.mp3",
		killbell = true,
		kill_externalbell = "moonloader//resource//montris audio//killsound01.mp3"
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
	paths = scanGameFolder(getGameDirectory(), paths)
	sampAddChatMessage("{ABB2B9}[DMGInformer] {FFFFFF}Final version by Montri.")
	sampRegisterChatCommand("dmg", damagecommand)
	sampRegisterChatCommand("dmgerror", errorlog)
	while true do
		wait(0)
		updateMenuVariables()
		createGiveNumber()
		createTakeNumber()
		if main_window_state.v == true then
			if wasKeyPressed(0x1B) then
				main_window_state.v = false
			end 
		end 
		imgui.Process = main_window_state.v
	end
end
function errorlog(params)
	local counter = 0
	local errors = 0
	for k,s in pairs(errorlog_messages) do
		k = tostring(k)
		params = tostring(params)
		if params == k then
			counter = counter + 1
			sampAddChatMessage(s)
		end 
		errors = errors + 1
	end 
	if counter == 0 then
		sampAddChatMessage(string.format("{ABB2B9}[DMGInformer]{FFFFFF} There are %d error explainations included.",errors))
		sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Use /dmgerror <number> to gain a detailed explaination on your error.")
	end 
end 
function damagecommand()
	main_window_state.v = not main_window_state.v
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
					if dmg.given_showdecimals == false then
						Give_StackedDamage = math.floor(Give_StackedDamage)
					end 
					sampCreate3dTextEx(Give_TextNumber, Give_StackedDamage, dmg.color[1], x - bx, y - by, z - bz, distance, false, -1, -1)
				else
					Give_PreviousID = Give_ID
					Give_PreviousDamage = Give_Damage
					Give_StackedDamage = Give_PreviousDamage
					if dmg.given_showdecimals == false then
						Give_Damage = math.floor(Give_Damage)
					end 
					sampCreate3dTextEx(Give_TextNumber, Give_Damage, dmg.color[1], x - bx, y - by, z - bz, distance, false, -1, -1)
				end
			else
				if dmg.given_showdecimals == false then
					Give_Damage = math.floor(Give_Damage)
				end 
				sampCreate3dTextEx(Give_TextNumber, Give_Damage, dmg.color[1], x - bx, y - by, z - bz, distance, false, -1, -1)
			end
			sampDestroy3dText(Give_TextNumber - 1)
		end
		if bell_given.v == true then
			if doesFileExist(dmg.given_externalbell) then
				sound_given = loadAudioStream(dmg.given_externalbell)
				setAudioStreamState(sound_given, 1)
			else 
				sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 5 occured. Please use /dmgerror 5 to gain information.")
			end 
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
			end
			sampDestroy3dText(Take_TextNumber - 1)
			if bell_taken.v == true  then
				if doesFileExist(dmg.taken_externalbell) then
					sound_taken = loadAudioStream(dmg.taken_externalbell)
					setAudioStreamState(sound_taken, 1)
				else
					sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 5 occured. Please use /dmgerror 5 to gain information.")
				end 
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
		Power_Name = "Power: {22CF31}On"
	end
	if dmg.takendamagemode == true then
		taken_damage.v = true
	end
	--- GIVEN MODE ---
	if dmg.damage_stacked == true then
		damage_stacked.v = true
		stack_damage = "{22CF31}On"
	else
		damage_stacked.v = false
		stack_damage = "{CF2222}Off"
	end 
	if dmg.bell == true then
		bell_given.v = true
		if given == 0 then
			Give_Bell = loadAudioStream(dmg.given_externalbell)
			given = 1
		end
	end
	if bell_given.v == true then
		Bell_Mode = "{22CF31}On"
	else 
		Bell_Mode = "{CF2222}Off"
	end 
	if dmg.given_lockbody == true then
		lockbody = "{22CF31}On"
		given_lockbody.v = true
	else
		lockbody = "{CF2222}Off"
		given_lockbody.v = false
	end 
	if dmg.given_showdecimals == true then
		given_decimals = "{22CF31}On"
		given_decimalss.v = true
	else 
		given_decimals = "{CF2222}Off"
		given_decimalss.v = false
	end 
 	--- TAKEN MODE ----
	if bell_taken.v == true then
		Bell_Mode2 = "{22CF31}On"
	else
		Bell_Mode2 = "{CF2222}Off"
	end 
	if dmg.taken_damage_mode == true then
		taken_damager = "{22CF31}On"
		taken_damage.v = true
	else 
		taken_damager = "{CF2222}Off"
		taken_damage.v = false
	end 
	if dmg.takenbell == true then
		bell_taken.v = true
		if taken == 0 then
			Take_Bell = loadAudioStream(dmg.taken_externalbell)
			taken = 1
		end
	end
	if dmg.deathbell == true then
		death_bell.v = true 
		if death == 0 then
			Death_Bell = loadAudioStream(dmg.death_externalbell)
			death = 1
		end 
	end 
	if dmg.killbell == true then
		kill_bell.v = true 
		if kill == 0 then
			Kill_Bell = loadAudioStream(dmg.kill_externalbell)
			kill = 1
		end 
	end 
	if dmg.takendamage_stacked == true then
		takendamage_stacked.v = true
	end
	if dmg.killbell == true then
		kill_bell.v = true
		Bell_Mode4 = "{22CF31}On"
	else 
		kill_bell.v = false 
		Bell_Mode4 = "{CF2222}Off"
	end 
	if dmg.deathbell == true then
		death_bell.v = true
		Bell_Mode3 = "{22CF31}On"
	else 
		death_bell.v = false
		Bell_Mode3 = "{CF2222}Off"
	end 
end

function sampevents.onPlayerDeathNotification(killerid, killedid, reason)
	local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if result then
		if killerid == id then
			if dmg.killbell == true then
				if doesFileExist(dmg.kill_externalbell) then
					sound_kill = loadAudioStream(dmg.kill_externalbell)
					setAudioStreamState(sound_kill, 1)
				else 
					sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 5 occured. Please use /dmgerror 5 to gain information.")
				end 
			end 
		elseif killedid == id then
			if dmg.deathbell == true then
				if doesFileExist(dmg.death_externalbell) then
					sound_death = loadAudioStream(dmg.death_externalbell)
					setAudioStreamState(sound_death, 1)
				else 
					sampAddChatMessage("{ABB2B9}[DMGInformer]{FFFFFF} Error 5 occured. Please use /dmgerror 5 to gain information.")
				end 
			end 
		end 
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



function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function imgui.TextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 --spawn rate
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextUnformatted(text)
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
        end
    end
end



function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

   	style.WindowPadding 		= imgui.ImVec2(8, 8)
    style.WindowRounding 		= 6
    style.ChildWindowRounding 	= 5
    style.FramePadding 			= imgui.ImVec2(5, 3)
    style.FrameRounding 		= 3.0
    style.ItemSpacing 			= imgui.ImVec2(5, 4)
    style.ItemInnerSpacing 		= imgui.ImVec2(4, 4)
    style.IndentSpacing 		= 21
    style.ScrollbarSize 		= 10.0
    style.ScrollbarRounding 	= 13
    style.GrabMinSize 			= 8
    style.GrabRounding			= 1
    style.WindowTitleAlign 		= imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign 		= imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                                = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]                        = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.WindowBg]                            = ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.ChildWindowBg]                       = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                             = ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[clr.ComboBg]                             = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Border]                              = ImVec4(0.43, 0.43, 0.50, 0.10)
    colors[clr.BorderShadow]                        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                             = ImVec4(0.30, 0.30, 0.30, 0.10)
    colors[clr.FrameBgHovered]                      = ImVec4(0.00, 0.53, 0.76, 0.30)
    colors[clr.FrameBgActive]                       = ImVec4(0.00, 0.53, 0.76, 0.80)
    colors[clr.TitleBg]                             = ImVec4(0.13, 0.13, 0.13, 0.99)
    colors[clr.TitleBgActive]                       = ImVec4(0.13, 0.13, 0.13, 0.99)
    colors[clr.TitleBgCollapsed]                    = ImVec4(0.05, 0.05, 0.05, 0.79)
    colors[clr.MenuBarBg]                           = ImVec4(0.13, 0.13, 0.13, 0.99)
    colors[clr.ScrollbarBg]                         = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]                       = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]                = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]                 = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark]                           = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.SliderGrab]                          = ImVec4(0.28, 0.28, 0.28, 1.00)
    colors[clr.SliderGrabActive]                    = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Button]                              = ImVec4(0.26, 0.26, 0.26, 0.30)
    colors[clr.ButtonHovered]                       = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.ButtonActive]                        = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.Header]                              = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.HeaderHovered]                       = ImVec4(0.34, 0.34, 0.35, 0.89)
    colors[clr.HeaderActive]                        = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.Separator]                           = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.SeparatorHovered]                    = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]                     = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]                          = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]                   = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]                    = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.CloseButton]                         = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]                  = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]                   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]                           = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]                    = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]                       = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]                = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]                      = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.ModalWindowDarkening]                = ImVec4(0.20, 0.20, 0.20,  0.0)
end
style()