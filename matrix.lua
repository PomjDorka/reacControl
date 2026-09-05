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
    local percent = call(device, "getEnergyFilledPercentage") or 0
    if percent <= 1 then
        percent = percent * 100
    end

    return {
        percent = math.max(0, math.min(100, percent)),
        energy = call(device, "getEnergy") or 0,
        capacity = call(device, "getMaxEnergy") or 0
    }
end

return matrix
