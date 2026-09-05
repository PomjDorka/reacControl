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

local function writeAt(monitor, x, y, text, color)
    monitor.setCursorPos(x, y)
    if color then
        monitor.setTextColor(color)
    end
    monitor.write(text)
    monitor.setTextColor(colors.white)
end

local function header(monitor, page)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.clear()
    writeAt(monitor, 1, 1, "REACTOR CTRL", colors.cyan)
    writeAt(monitor, 1, 2, page == "STATUS" and "STATUS" or "SETTINGS", colors.yellow)
    writeAt(monitor, 10, 2, page == "STATUS" and "[SET]" or "[BACK]", colors.lime)
end

function ui.draw(monitor, config, matrixState, reactorState, turbineState, message, page)
    page = page or "STATUS"
    header(monitor, page)

    if page == "SETTINGS" then
        writeAt(monitor, 1, 4, "MATRIX MIN", colors.lightBlue)
        writeAt(monitor, 20, 4, string.format("%5.1f%%", config.matrixStart))
        button(monitor, 1, 5, "-")
        button(monitor, 6, 5, "+")

        writeAt(monitor, 1, 7, "MATRIX MAX", colors.lightBlue)
        writeAt(monitor, 20, 7, string.format("%5.1f%%", config.matrixStop))
        button(monitor, 1, 8, "-")
        button(monitor, 6, 8, "+")

        writeAt(monitor, 1, 10, "RPM TARGET", colors.lightBlue)
        writeAt(monitor, 20, 10, tostring(config.rpmTarget))
        button(monitor, 1, 11, "-")
        button(monitor, 6, 11, "+")

        writeAt(monitor, 1, 14, message or "READY", colors.gray)
        button(monitor, 1, 16, "BACK", colors.lime)
        return
    end

    writeAt(monitor, 1, 4, "MATRIX", colors.lightBlue)
    writeAt(monitor, 12, 4, string.format("%5.1f%%", matrixState.percent))
    writeAt(monitor, 1, 5, "AUTO", colors.lightBlue)
    writeAt(monitor, 12, 5, config.mode)
    writeAt(monitor, 1, 6, "REACTOR", colors.lightBlue)
    writeAt(monitor, 12, 6, reactorState.active and "ON" or "OFF", reactorState.active and colors.lime or colors.red)
    writeAt(monitor, 1, 7, "RODS", colors.lightBlue)
    writeAt(monitor, 12, 7, string.format("%6.2f%%", reactorState.rods))
    writeAt(monitor, 1, 8, "TEMP", colors.lightBlue)
    writeAt(monitor, 12, 8, string.format("%6.1f", reactorState.temperature))
    writeAt(monitor, 1, 9, "FUEL/S", colors.lightBlue)
    writeAt(monitor, 12, 9, string.format("%6.2f", reactorState.fuelUsed * 20))
    writeAt(monitor, 1, 10, "RPM", colors.lightBlue)
    writeAt(monitor, 12, 10, tostring(config.rpmTarget))

    local row = 12
    for index, turbine in ipairs(turbineState) do
        writeAt(monitor, 1, row, string.format("T%-2d", index), colors.lightBlue)
        writeAt(monitor, 6, row, string.format("%4d", turbine.rpm))
        writeAt(monitor, 13, row, turbine.active and "ON" or "OFF", turbine.active and colors.lime or colors.red)
        row = row + 1
        if row > 18 then
            break
        end
    end

    button(monitor, 1, 20, "AUTO", colors.lime)
    button(monitor, 9, 20, "MAN", colors.yellow)
    button(monitor, 17, 20, "START", colors.lime)
    button(monitor, 27, 20, "STOP", colors.red)
    button(monitor, 1, 22, "SET", colors.cyan)
    writeAt(monitor, 10, 22, message or "READY", colors.gray)
end

function ui.handleTouch(x, y, turbineCount, config, setReactor, setTurbines, save, page)
    if page == "SETTINGS" then
        if y == 2 and x >= 10 then
            return "STATUS"
        elseif y == 5 then
            if x <= 4 then
                config.matrixStart = math.max(0, config.matrixStart - 1)
            elseif x <= 10 then
                config.matrixStart = math.min(config.matrixStop - 1, config.matrixStart + 1)
            end
        elseif y == 8 then
            if x <= 4 then
                config.matrixStop = math.max(config.matrixStart + 1, config.matrixStop - 1)
            elseif x <= 10 then
                config.matrixStop = math.min(100, config.matrixStop + 1)
            end
        elseif y == 11 then
            if x <= 4 then
                config.rpmTarget = math.max(0, config.rpmTarget - 50)
            elseif x <= 10 then
                config.rpmTarget = config.rpmTarget + 50
            end
        elseif y == 16 then
            save()
            return "STATUS"
        end
        save()
        return nil
    end

    if y == 2 and x >= 10 then
        return "SETTINGS"
    elseif y == 20 then
        if x <= 8 then
            config.mode = "AUTO"
        elseif x <= 16 then
            config.mode = "MANUAL"
        elseif x <= 26 then
            config.mode = "MANUAL"
            setReactor(true)
            setTurbines(true)
        else
            config.mode = "EMERGENCY"
            setReactor(false)
            setTurbines(false)
        end
        save()
    end

    return nil
end
return ui
