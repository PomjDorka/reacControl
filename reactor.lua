local reactor = {}

local function call(device, method, ...)
    if not device or type(device[method]) ~= "function" then
        return nil
    end

    local ok, value = pcall(device[method], ...)
    if ok then
        return value
    end

    return nil
end

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

function reactor.new(device)
    return {
        device = device,
        active = false,
        rods = 100,
        fuelUsed = 0
    }
end

function reactor.setActive(state, active)
    if not state.device then
        return
    end

    call(state.device, "setActive", active)
    state.active = active

    if not active then
        state.rods = 100
        call(state.device, "setAllControlRodLevels", 100)
    end
end

function reactor.read(state)
    local active = call(state.device, "getActive")
    local rods = call(state.device, "getControlRodLevel", 0)
    local temperature = call(state.device, "getFuelTemperature") or 0
    local fuel = call(state.device, "getFuelAmount") or 0
    local energy = call(state.device, "getEnergyStored") or 0
    local fuelUsed = call(state.device, "getFuelConsumedLastTick") or 0

    if type(active) == "boolean" then
        state.active = active
    end

    if type(rods) == "number" then
        state.rods = clamp(rods, 0, 100)
    end

    if type(fuelUsed) == "number" then
        state.fuelUsed = fuelUsed
    end

    return {
        active = state.active,
        rods = state.rods,
        temperature = temperature,
        fuel = fuel,
        energy = energy,
        fuelUsed = state.fuelUsed
    }
end

return reactor
