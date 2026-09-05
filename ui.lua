local ui = {}

local function center(monitor, row, text)
    local width = select(1, monitor.getSize())
    local x = math.max(1, math.floor((width - #text) / 2) + 1)
    monitor.setCursorPos(x, row)
    monitor.write(text)
end

local function button(monitor, x, row, text)
    monitor.setCursorPos(x, row)
    monitor.write("[" .. text .. "]")
end

function ui.draw(monitor, config, matrixState, reactorState, turbineState, message)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.clear()

    center(monitor, 1, "REACTOR CONTROL")
    center(monitor, 2, "----------------")

    monitor.setCursorPos(1, 4)
    monitor.write("MODE: " .. config.mode)
    monitor.setCursorPos(1, 5)
    monitor.write(string.format("MATRIX: %5.1f%%", matrixState.percent))
    monitor.setCursorPos(1, 6)
    monitor.write("STEAM: " .. reactorState.steamRate .. "/" .. config.steamTarget)
    monitor.setCursorPos(1, 7)
    monitor.write(string.format("RODS: %5.1f%%", reactorState.rods))
    monitor.setCursorPos(1, 8)
    monitor.write("REACTOR: " .. (reactorState.active and "ON" or "OFF"))
    monitor.setCursorPos(1, 9)
    monitor.write("TEMP: " .. reactorState.temperature)
    monitor.setCursorPos(1, 10)
    monitor.write("FUEL: " .. reactorState.fuel)
    monitor.setCursorPos(1, 12)
    monitor.write("RPM TARGET: " .. config.rpmTarget)

    local row = 13
    for index, turbine in ipairs(turbineState) do
        monitor.setCursorPos(1, row)
        monitor.write(string.format("T%-2d %4d RPM %s", index, turbine.rpm, turbine.active and "ON" or "OFF"))
        row = row + 1
    end

    button(monitor, 1, row + 1, "AUTO")
    button(monitor, 9, row + 1, "MANUAL")
    button(monitor, 20, row + 1, "START")
    button(monitor, 30, row + 1, "STOP")
    button(monitor, 1, row + 3, "RESET")
    button(monitor, 10, row + 3, "STEAM-")
    button(monitor, 21, row + 3, "STEAM+")
    button(monitor, 32, row + 3, "RPM-")
    button(monitor, 40, row + 3, "RPM+")

    monitor.setCursorPos(1, row + 5)
    monitor.write(message or "READY")
end

function ui.handleTouch(x, y, turbineCount, config, reactorState, setReactor, setTurbines, save)
    local row = 13 + turbineCount

    if y == row + 1 then
        if x <= 8 then
            config.mode = "AUTO"
        elseif x <= 19 then
            config.mode = "MANUAL"
        elseif x <= 29 then
            setReactor(true)
            setTurbines(true)
        else
            config.mode = "EMERGENCY"
            setReactor(false)
            setTurbines(false)
        end
        save()
        return "MODE UPDATED"
    end

    if y == row + 3 then
        if x <= 9 then
            config.mode = "MANUAL"
            setReactor(false)
            setTurbines(false)
        elseif x <= 20 then
            config.steamTarget = math.max(0, config.steamTarget - 10000)
        elseif x <= 31 then
            config.steamTarget = config.steamTarget + 10000
        elseif x <= 39 then
            config.rpmTarget = math.max(0, config.rpmTarget - 50)
        else
            config.rpmTarget = config.rpmTarget + 50
        end
        save()
        return "SETTING UPDATED"
    end

    return nil
end

return ui
