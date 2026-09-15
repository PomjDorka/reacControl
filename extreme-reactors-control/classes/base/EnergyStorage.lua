-- Reactor / Turbine Control
-- (c) 2025 SeekerOfHonjo
-- Version 2.0

local EnergyStorage = {
    name = "",
    id = {},
    side = "",
    type = "",
    
    energy = function(self)
        if self.id.getEnergy then
            return self.id.getEnergy()
        end
        return self.id.getEnergyStored()
    end,
    capacity = function(self)
        local max = (self.id.getMaxEnergyStored ~= nil) and self.id.getMaxEnergyStored() or 0
        local cap = (self.id.getEnergyCapacity ~= nil) and self.id.getEnergyCapacity() or 0

        if max > cap then
            return max
        else
            return cap
        end
    end,
    percentage = function(self)
        return math.floor(self:energy()/self:capacity()*100)
    end,
    percentagePrecise = function(self)
        return self:energy()/self:capacity()*100
    end
}

function _G.newEnergyStorage(name,id, side, type)
    print("Creating new Base Energy Storage")
    local storage = {}
    setmetatable(storage,{__index=EnergyStorage})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    storage.name = name
    storage.id = id
    storage.side = side
    storage.type = type

    return storage
end

function _G.printEnergyStorageData(storage)
    print("Name: "..storage.name)
    print("ID: "..tostring(storage.id))
    print("Energy: "..storage:energy())
    print("Capacity: "..storage:capacity())
    print("Fill: "..storage:percentage().."%")
end







