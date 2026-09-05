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
        steamRate = 0,
        lastHot = nil,
        lastTime = os.clock()
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

function reactor.updateRate(state)
    local hot = call(state.device, "getHotFluidAmount") or 0
    local now = os.clock()

    if state.lastHot ~= nil then
        local elapsed = now - state.lastTime
        if elapsed > 0 then
            state.steamRate = math.max(0, math.floor((hot - state.lastHot) / elapsed))
        end
    end

    state.lastHot = hot
    state.lastTime = now
end

function reactor.regulate(state, config, measuredSteam)
    if not state.active or not state.device then
        return
    end

    local current = measuredSteam or state.steamRate
    local target = config.steamTarget
    local deadband = math.max(1, target * config.steamDeadband)

    if math.abs(current - target) <= deadband then
        return
    end

    if current < target then
        state.rods = state.rods - config.rodStep
    else
        state.rods = state.rods + config.rodStep
    end

    state.rods = clamp(state.rods, 0, 100)
    call(state.device, "setAllControlRodLevels", state.rods)
end

function reactor.read(state)
    local active = call(state.device, "getActive")
    local rods = call(state.device, "getControlRodLevel")
    local temperature = call(state.device, "getFuelTemperature") or 0
    local fuel = call(state.device, "getFuelAmount") or 0
    local energy = call(state.device, "getEnergyStored") or 0

    if type(active) == "boolean" then
        state.active = active
    end

    if type(rods) == "number" then
        state.rods = clamp(rods, 0, 100)
    end

    return {
        active = state.active,
        rods = state.rods,
        steamRate = state.steamRate,
        temperature = temperature,
        fuel = fuel,
        energy = energy
    }
end

return reactor
