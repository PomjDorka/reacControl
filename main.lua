local config = require("config")
local storage = require("storage")
local devices = require("devices")
local matrix = require("matrix")
local reactorModule = require("reactor")
local turbinesModule = require("turbines")
local ui = require("ui")

config = storage.load(config)
local hardware = devices.discover(config)
local reactor = reactorModule.new(hardware.reactor)
local message = "READY"
local nextAuto = 0

local function setReactor(active)
    reactorModule.setActive(reactor, active)
end

local function setTurbines(active)
    turbinesModule.setAll(hardware.turbines, active)
end

local function save()
    storage.save(config)
end

local function autoControl(matrixState)
    if config.mode == "EMERGENCY" then
        setReactor(false)
        setTurbines(false)
        return
    end

    if config.mode ~= "AUTO" then
        return
    end

    if matrixState.percent <= config.matrixStart then
        setReactor(true)
        setTurbines(true)
    elseif matrixState.percent >= config.matrixStop then
        setReactor(false)
        setTurbines(false)
    end
end

if not hardware.monitor then
    error("Monitor not found")
end

hardware.monitor.setTextScale(0.5)

local function draw()
    local matrixState = matrix.read(hardware.matrix)
    local reactorState = reactorModule.read(reactor)
    local turbineState = turbinesModule.read(hardware.turbines)
    ui.draw(hardware.monitor, config, matrixState, reactorState, turbineState, message)
end

local function update()
    reactorModule.updateRate(reactor)
    local matrixState = matrix.read(hardware.matrix)
    local turbineState = turbinesModule.read(hardware.turbines)
    local measuredSteam = 0
    for _, turbine in ipairs(turbineState) do
        measuredSteam = measuredSteam + turbine.input
    end
    reactor.steamRate = measuredSteam
    autoControl(matrixState)
    reactorModule.regulate(reactor, config, measuredSteam)
    turbinesModule.regulate(hardware.turbines, config)
    draw()
end

draw()
local timer = os.startTimer(config.updateInterval)

while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "monitor_touch" and p1 == config.monitorName then
        local result = ui.handleTouch(
            p2,
            p3,
            #hardware.turbines,
            config,
            reactor,
            setReactor,
            setTurbines,
            save
        )
        if result then
            message = result
            draw()
        end
    elseif event == "timer" and p1 == timer then
        update()
        timer = os.startTimer(config.updateInterval)
    end
end
