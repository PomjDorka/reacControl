-- Reactor / Turbine Control
-- (c) 2025 SeekerOfHonjo
-- Version 2.0

local DraconicEvolutionEnergyStorage = {
    name = "",
    id = {},
    side = "",
    type = "",
    
    energy = function(self)
        return self.id.getEnergy()
    end,
    capacity = function(self)
        return self.id.getEnergyCapacity()
    end,
    percentage = function(self)
        return math.floor(self:energy()/self:capacity()*100)
    end,
    percentagePrecise = function(self)
        return self:energy()/self:capacity()*100
    end
}

function _G.newDraconicEvolutionEnergyStorage(name,id, side, type)
    print("Creating new Draconic Evolution Energy Storage")
    local storage = {}
    setmetatable(storage,{__index=DraconicEvolutionEnergyStorage})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    storage.name = name
    storage.id = id
    storage.side = side
    storage.type = type

    return storage
end








