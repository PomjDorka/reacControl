local turbines = {}

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

function turbines.setOne(turbine, active)
    call(turbine.device, "setActive", active)
    call(turbine.device, "setInductorEngaged", active)
    turbine.active = active

    if not active then
        turbine.flow = 0
        call(turbine.device, "setFluidRateMax", 0)
    end
end

function turbines.setAll(list, active)
    for _, turbine in ipairs(list) do
        turbines.setOne(turbine, active)
    end
end

function turbines.regulate(list, config)
    for _, turbine in ipairs(list) do
        if turbine.active then
            local rpm = call(turbine.device, "getRotorSpeed") or 0
            local difference = config.rpmTarget - rpm

            if math.abs(difference) > config.rpmDeadband then
                if difference > 0 then
                    turbine.flow = turbine.flow + config.flowStep
                else
                    turbine.flow = turbine.flow - config.flowStep
                end

                turbine.flow = clamp(turbine.flow, 0, config.maxFlow)
                call(turbine.device, "setFluidRateMax", turbine.flow)
            end
        end
    end
end

function turbines.read(list)
    local result = {}

    for index, turbine in ipairs(list) do
        local active = call(turbine.device, "getActive")
        local coils = call(turbine.device, "getInductorEngaged")
        result[index] = {
            name = turbine.name,
            rpm = call(turbine.device, "getRotorSpeed") or 0,
            input = call(turbine.device, "getInputAmount") or 0,
            energy = call(turbine.device, "getEnergyStored") or 0,
            flow = turbine.flow,
            active = type(active) == "boolean" and active or turbine.active,
            coils = type(coils) == "boolean" and coils or false
        }

        turbine.active = result[index].active
    end

    return result
end

return turbines
