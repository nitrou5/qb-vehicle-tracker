local QBCore = exports['qb-core']:GetCoreObject()
local config = require 'config'
local activeTrackers = {}

-- Usable Items
QBCore.Functions.CreateUseableItem(config.trackerItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:placeTracker', source, item.slot)
end)

QBCore.Functions.CreateUseableItem(config.trackerTabletItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:manageTracker', source, item.info.plate)
end)

QBCore.Functions.CreateUseableItem(config.trackerScannerItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:scanTracker', source, item.slot)
end)

-- Events
RegisterNetEvent('qb_vehicle_tracker:server:placeTracker', function(vehNetID, vehPlate, slot)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(config.trackerItem, 1, slot)

    if Player.Functions.AddItem(config.trackerTabletItem, 1, false, { plate = vehPlate }) then
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[config.trackerTabletItem], 'add')
    end

    activeTrackers[vehPlate] = vehNetID
end)

RegisterNetEvent('qb_vehicle_tracker:server:removeTracker', function(vehPlate, slot)
    if activeTrackers[vehPlate] == nil then return end

    local Player = QBCore.Functions.GetPlayer(source)

    if Player.Functions.RemoveItem(config.trackerScannerItem, 1, slot) then 
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[config.trackerScannerItem], 'remove')        
    end

    activeTrackers[vehPlate] = nil
end)

-- Callback
lib.callback.register('qb_vehicle_tracker:server:getTrackedVehicle', function(_, vehPlate)
    local veh = NetworkGetEntityFromNetworkId(activeTrackers[vehPlate])

    if not DoesEntityExist(veh) then return end

    local vehCoords = GetEntityCoords(veh)

    return activeTrackers[vehPlate], vector2(vehCoords.x, vehCoords.y)
end)