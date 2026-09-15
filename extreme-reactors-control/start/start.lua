-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Start program --

--========== Global variables for all program parts ==========

--All options
_G.CoreOptionList = {}
_G.version = 0
_G.rodLevel = 0
_G.backgroundColor = 0
_G.textColor = 0
_G.reactorOffAt = 0
_G.reactorOnAt = 0
_G.mainMenu = ""
_G.lang = ""
_G.overallMode = ""
_G.mainProgram = ""
_G.turbineTargetSpeed = 0
_G.targetSteam = 0
_G.turbineOnOff = ""
_G.debugEnabled = 0
_G.skipControlRodCheck = 0
_G.location = ""
_G.modemChannel = 0
_G.wirelessModemLocation = "top"
_G.language = {}

--TouchpointLocation (same as the monitor)
_G.touchpointLocation = {}

--========== Global functions for all program parts ==========

--===== Functions for loading and saving the options =====

local repoUrl = "https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/raw/"

function  _G.debugOutput(message) 
	if  _G.debugEnabled == 1 then
		print(message)
	end
end

--Loads the options.txt file and adds values to the global variables
function _G.loadOptionFile()
	debugOutput("Loading Option File")
	--Loads the file
	local file = fs.open("/extreme-reactors-control/config/options.txt","r")
	local list = file.readAll()
	file.close()

    --Insert Elements and assign values
    _G.CoreOptionList = textutils.unserialise(list)

	--Assign values to variables
	_G.version = _G.CoreOptionList["version"]
	_G.rodLevel = _G.CoreOptionList["rodLevel"]
	_G.backgroundColor = tonumber(_G.CoreOptionList["backgroundColor"])
	_G.textColor = tonumber(_G.CoreOptionList["textColor"])
	_G.reactorOffAt = _G.CoreOptionList["reactorOffAt"]
	_G.reactorOnAt = _G.CoreOptionList["reactorOnAt"]
	_G.mainMenu = _G.CoreOptionList["mainMenu"]
	_G.overallMode = _G.CoreOptionList["overallMode"]
	_G.mainProgram = _G.CoreOptionList["program"]
	_G.turbineTargetSpeed = _G.CoreOptionList["turbineTargetSpeed"]
	_G.targetSteam  = _G.CoreOptionList["targetSteam"]
	_G.turbineOnOff = _G.CoreOptionList["turbineOnOff"]
	_G.debugEnabled = _G.CoreOptionList["debug"]
	_G.skipControlRodCheck = _G.CoreOptionList["skipControlRodCheck"]
	_G.lang = _G.CoreOptionList["language"]
	_G.location = _G.CoreOptionList["location"]
	_G.modemChannel = _G.CoreOptionList["modemChannel"]
end

--Refreshes the options list
function _G.refreshOptionList()
	debugOutput("Refreshing Option List")
	debugOutput("Variable: version")
	_G.CoreOptionList["version"] = _G.version
	debugOutput("Variable: rodLevel")
	_G.CoreOptionList["rodLevel"] = _G.rodLevel
	debugOutput("Variable: backgroundColor".._G.backgroundColor)
	_G.CoreOptionList["backgroundColor"] = _G.backgroundColor
	debugOutput("Variable: textColor = ".._G.textColor)
	_G.CoreOptionList["textColor"] = _G.textColor
	debugOutput("Variable: reactorOffAt")
	_G.CoreOptionList["reactorOffAt"] = _G.reactorOffAt
	debugOutput("Variable: reactorOnAt")
	_G.CoreOptionList["reactorOnAt"] = _G.reactorOnAt
	debugOutput("Variable: mainMenu")
	_G.CoreOptionList["mainMenu"] = _G.mainMenu
	debugOutput("Variable: overallMode")
	_G.CoreOptionList["overallMode"] = _G.overallMode
	debugOutput("Variable: program")
	_G.CoreOptionList["program"] = _G.mainProgram
	debugOutput("Variable: turbineTargetSpeed")
	_G.CoreOptionList["turbineTargetSpeed"] = _G.turbineTargetSpeed
	debugOutput("Variable: targetSteam")
	_G.CoreOptionList["targetSteam"] = _G.targetSteam
	debugOutput("Variable: turbineOnOff")
	_G.CoreOptionList["turbineOnOff"] = _G.turbineOnOff
	debugOutput("Variable: skipControlRodCheck")
	_G.CoreOptionList["skipControlRodCheck"] = _G.skipControlRodCheck
	debugOutput("Variable: lang")
	_G.CoreOptionList["language"] = _G.lang
	debugOutput("Variable: location")
	_G.CoreOptionList["location"] = _G.location
	debugOutput("Variable: modemChannel")
	_G.CoreOptionList["modemChannel"] = _G.modemChannel
	_G.CoreOptionList["debug"] = _G.debugEnabled
end

--Saves all data back to the options.txt file
function _G.saveOptionFile()
	debugOutput("Saving Option File")
	--Refresh option list
	refreshOptionList()
    --Serialise the table
    local list = textutils.serialise(_G.CoreOptionList)
	--Save optionList to the config file
	local file = fs.open("/extreme-reactors-control/config/options.txt","w")
    file.writeLine(list)
	file.close()
	print("Saved.")
end


--===== Automatic update detection =====

--Check for updates
function _G.checkUpdates()
	print("Energy Storage Devices: "..(#capacitors + 1))
	print("localVer: "..version)
end


function _G.doUpdate(toVer,branch)

	--Set the monitor up
	local x,y = controlMonitor.getSize()
	controlMonitor.setBackgroundColor(colors.black)
	controlMonitor.clear()

	local x1 = x/2-15
	local y1 = y/2-4
	local x2 = x/2
	local y2 = y/2

	--Draw Box
	controlMonitor.setBackgroundColor(colors.gray)
	controlMonitor.setTextColor(colors.gray)
	controlMonitor.setCursorPos(x1,y1)
	for i=1,8 do
		controlMonitor.setCursorPos(x1,y1+i-1)
		controlMonitor.write("                              ") --30 chars
	end

	--Print update message
	controlMonitor.setTextColor(colors.white)

	controlMonitor.setCursorPos(x2-9,y1+1)
	controlMonitor.write(_G.language:getText("updateAvailableLineOne")) --17 chars

	controlMonitor.setCursorPos(x2-(math.ceil(string.len(toVer)/2)),y1+3)
	controlMonitor.write(toVer)

	controlMonitor.setCursorPos(x2-8,y1+5)
	controlMonitor.write(_G.language:getText("updateAvailableLineTwo")) --15 chars

	controlMonitor.setCursorPos(x2-12,y1+6)
	controlMonitor.write(_G.language:getText("updateAvailableLineThree")) --24 chars

	--Print install instructions to the terminal
	term.clear()
	term.setCursorPos(1,1)
	local tx,ty = term.getSize()

	print(_G.language:getText("updateProgram"))
	term.write("Input: ")

	--Run Counter for installation skipping
	local count = 10
	local out = false

	term.setCursorPos(tx/2-5,ty)
	term.write(" -- 10 -- ")

	while true do

		local timer1 = os.startTimer(1)

		while true do

			local event, p1 = os.pullEvent()

			if event == "key" then

				if p1 == 36 or p1 == 21 then
					shell.run("/extreme-reactors-control/install/installer.lua update "..branch)
					out = true
					break
				end

			elseif event == "timer" and p1 == timer1 then

				count = count - 1
				term.setCursorPos(tx/2-5,ty)
				term.write(" -- 0"..count.." -- ")
				break
			end
		end

		if out then break end

		if count == 0 then
			term.clear()
			term.setCursorPos(1,1)
			break
		end
	end
end

--Download Files (For Remote version file)
function _G.downloadFile(relUrl,path)
	local gotUrl = http.get(relUrl..path)
	if gotUrl == nil then
		term.clear()
		error("File not found! Please check!\nFailed at "..relUrl..path)
	else
		_G.url = gotUrl.readAll()
	end

	local file = fs.open(path,"w")
	file.write(url)
	file.close()
end


--===== Shutdown and restart the computer =====

function _G.reactorestart()
	saveOptionFile()
	controlMonitor.clear()
	controlMonitor.setCursorPos(38,8)
	controlMonitor.write("Rebooting...")
	os.reboot()
end


function initClasses()
    --Execute necessary class files
    local binPath = "/extreme-reactors-control/classes/"
    shell.run(binPath.."base/Reactor.lua")
    shell.run(binPath.."base/Turbine.lua")
    shell.run(binPath.."base/EnergyStorage.lua")
    shell.run(binPath.."bigger_reactors/Reactor.lua")
    shell.run(binPath.."bigger_reactors/Turbine.lua")
    shell.run(binPath.."mekanism/MekanismEnergyStorage.lua")
    shell.run(binPath.."thermal_expansion/ThermalExpansionEnergyStorage.lua")
    shell.run(binPath.."draconic_evolution/DraconicEvolutionEnergyStorage.lua")
    shell.run(binPath.."Peripherals.lua")
    shell.run(binPath.."Language.lua")
	shell.run(binPath.."transport/reactoronly.lua")
	shell.run(binPath.."transport/reactorTurbine.lua")
	shell.run(binPath.."transport/startup.lua")
    shell.run(binPath.."transport/wrapper.lua")
end

--=========== Run the program ==========

--Load the option file and initialize the peripherals

debugOutput("Loading Options File")
loadOptionFile()

debugOutput("Initializing Classes")
initClasses()

debugOutput("Initializing Language")
_G.language = _G.newLanguageById(_G.lang)

debugOutput("Initializing Network Devices")
_G.initPeripherals()

debugOutput("Checking for Updates")
checkUpdates()

--Run program or main menu, based on the settings
if  amountReactors < 0 then
	--this is a monitor only we do show anything with the menu
	shell.run("/extreme-reactors-control/program/monitor.lua")
elseif mainMenu then
	shell.run("/extreme-reactors-control/start/menu.lua")
	shell.completeProgram("/extreme-reactors-control/start/start.lua")
else
	if _G.mainProgram == "turbine" then
		shell.run("/extreme-reactors-control/program/turbineControl.lua")
	elseif _G.mainProgram == "reactor" then
		shell.run("/extreme-reactors-control/program/reactorControl.lua")
	elseif _G.mainProgram == "monitor" then
		shell.run("/extreme-reactors-control/program/monitor.lua")
	end
	shell.completeProgram("/extreme-reactors-control/start/start.lua")
end


--========== END OF THE START.LUA FILE ==========
