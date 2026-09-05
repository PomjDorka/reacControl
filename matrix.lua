local matrix = {}

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

function matrix.read(device)
    local energy = call(device, "getEnergy") or 0
    local capacity = call(device, "getEnergyCapacity")

    if type(capacity) ~= "number" or capacity <= 0 then
        capacity = call(device, "getMaxEnergy") or 0
    end

    local percent = 0
    if capacity > 0 then
        percent = (energy / capacity) * 100
    end

    return {
        percent = math.max(0, math.min(100, percent)),
        energy = energy,
        capacity = capacity
    }
end

return matrix
