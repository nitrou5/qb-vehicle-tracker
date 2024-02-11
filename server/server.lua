local QBCore = exports['qb-core']:GetCoreObject()
local config = require 'config'
local utils = require 'server.utils'
local db = require 'server.db'

-- QB Usable Items
QBCore.Functions.CreateUseableItem(config.trackerItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:placeTracker', source, item.slot, utils.getRandomSerialNumber())
end)

QBCore.Functions.CreateUseableItem(config.trackerTabletItem, function(source, item)
    local serialNumber = item.info and item.info.serialNumber or item.metadata.serialNumber
    TriggerClientEvent('qb_vehicle_tracker:client:manageTracker', source, serialNumber)
end)

QBCore.Functions.CreateUseableItem(config.trackerScannerItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:scanTracker', source, item.slot)
end)

-- Event Handler
AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource == resourceName then
        db.deleteOldTrackers()
    end
end)

-- Callbacks
lib.callback.register('qb_vehicle_tracker:getTrackedVehicleBySerial', function(_, serialNumber)
    if type(serialNumber) ~= "string" or string.len(serialNumber) < 11 then return end

    local tracker = db.getTracker(serialNumber)
    if not tracker then return end

    local vehicleNetworkID = utils.getVehicleNetworkIdByPlate(tracker.vehiclePlate)
    if not vehicleNetworkID then return end

    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetworkID)
    if not DoesEntityExist(vehicleEntity) then return end

    local vehCoords = GetEntityCoords(vehicleEntity)

    return tracker.vehiclePlate, vector2(vehCoords.x, vehCoords.y)
end)

lib.callback.register('qb_vehicle_tracker:isVehicleTracked', function(source, vehiclePlate)
    if type(vehiclePlate) ~= "string" or not utils.isPlayerNearVehicle(GetEntityCoords(GetPlayerPed(source)), vehiclePlate) then
        return false
    end

    return db.isTracked(utils.trim(vehiclePlate))
end)

lib.callback.register('qb_vehicle_tracker:placeTracker', function(source, vehiclePlate, slot, serialNumber)
    if type(vehiclePlate) ~= "string" or type(serialNumber) ~= "string" or string.len(serialNumber) < 11 then return false end
    if not utils.isPlayerNearVehicle(GetEntityCoords(GetPlayerPed(source)), vehiclePlate) then return false end
    if not db.addTracker(serialNumber, utils.trim(vehiclePlate)) then return false end

    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.AddItem(config.trackerTabletItem, 1, false, { plate = utils.trim(vehiclePlate), serialNumber = serialNumber }) then
        Player.Functions.RemoveItem(config.trackerItem, 1, slot)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[config.trackerTabletItem], 'add')
    end

    return true
end)

lib.callback.register('qb_vehicle_tracker:removeTracker', function(source, vehiclePlate, slot)
    if type(vehiclePlate) ~= "string" or not utils.isPlayerNearVehicle(GetEntityCoords(GetPlayerPed(source)), vehiclePlate) then
        return false
    end

    if not db.deleteTracker(utils.trim(vehiclePlate)) then return false end

    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(config.trackerScannerItem, 1, slot) then
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[config.trackerScannerItem], 'remove')
    end

    return true
end)