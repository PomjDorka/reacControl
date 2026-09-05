local baseUrl = "https://raw.githubusercontent.com/USERNAME/REPOSITORY/main"

local files = {
    "config.lua",
    "storage.lua",
    "devices.lua",
    "matrix.lua",
    "reactor.lua",
    "turbines.lua",
    "ui.lua",
    "main.lua"
}

local backupDir = "reactor_backup"

if not fs.exists(backupDir) then
    fs.makeDir(backupDir)
end

if not http then
    error("HTTP is disabled. Enable it in the computer config.")
end

for _, name in ipairs(files) do
    local url = baseUrl .. "/" .. name
    local response, errorMessage = http.get(url)

    if not response then
        error("Download failed: " .. name .. " " .. tostring(errorMessage))
    end

    local text = response.readAll()
    response.close()

    if fs.exists(name) then
        fs.copy(name, backupDir .. "/" .. name .. ".bak")
        print("Backed up " .. name)
    end

    local file = fs.open(name, "w")
    file.write(text)
    file.close()

    print("Downloaded " .. name)
end

print("Install complete")
print("Run: main")