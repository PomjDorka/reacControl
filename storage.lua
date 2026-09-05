local storage = {}

function storage.load(config)
    if not fs.exists("reactor.cfg") then
        return config
    end

    local file = fs.open("reactor.cfg", "r")
    local text = file.readAll()
    file.close()

    local saved = textutils.unserialize(text)
    if type(saved) == "table" then
        for key, value in pairs(saved) do
            if config[key] ~= nil then
                config[key] = value
            end
        end
    end

    if config.mode == "EMERGENCY" then
        config.mode = "MANUAL"
    end

    if type(config.rodStep) ~= "number" or config.rodStep >= 1 then
        config.rodStep = 0.1
    end

    return config
end

function storage.save(config)
    local copy = {}
    for key, value in pairs(config) do
        if key ~= "mode" then
            copy[key] = value
        end
    end

    local file = fs.open("reactor.cfg", "w")
    file.write(textutils.serialize(copy))
    file.close()
end

return storage
