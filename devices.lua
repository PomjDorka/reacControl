local devices = {}

local function findByType(fragment)
    for _, name in ipairs(peripheral.getNames()) do
        local ptype = peripheral.getType(name) or ""
        if string.find(ptype, fragment, 1, true) then
            return peripheral.wrap(name), name
        end
    end
    return nil, nil
end

function devices.discover(config)
    local result = {}

    result.reactor = peripheral.wrap(config.reactorName)
    result.matrix = peripheral.wrap(config.matrixName)
    result.monitor = peripheral.wrap(config.monitorName)
    result.turbines = {}

    for _, name in ipairs(peripheral.getNames()) do
        local ptype = peripheral.getType(name) or ""
        if string.find(ptype, "Turbine", 1, true) then
            table.insert(result.turbines, {
                name = name,
                device = peripheral.wrap(name),
                flow = 0,
                active = false
            })
        end
    end

    table.sort(result.turbines, function(a, b)
        return a.name < b.name
    end)

    if not result.reactor then
        result.reactor, result.reactorName = findByType("Reactor")
    else
        result.reactorName = config.reactorName
    end

    if not result.matrix then
        result.matrix, result.matrixName = findByType("induction")
    else
        result.matrixName = config.matrixName
    end

    if not result.monitor then
        result.monitor, result.monitorName = findByType("monitor")
    else
        result.monitorName = config.monitorName
    end

    return result
end

return devices
