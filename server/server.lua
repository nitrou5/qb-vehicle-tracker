local QBCore = exports['qb-core']:GetCoreObject()
local config = require 'config'

-- Functions
local function GetRandomSerialNumber()
    return lib.string.random('...........')
end

local function GetVehicleNetworkIdByPlate(vehiclePlate)
    local vehicles = GetAllVehicles()

    for _, vehicle in ipairs(vehicles) do
        if GetVehicleNumberPlateText(vehicle) == vehiclePlate then
            return NetworkGetNetworkIdFromEntity(vehicle)
        end
    end

    return nil
end

-- Usable Items
QBCore.Functions.CreateUseableItem(config.trackerItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:placeTracker', source, item.slot, GetRandomSerialNumber())
end)

QBCore.Functions.CreateUseableItem(config.trackerTabletItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:manageTracker', source, item.info.serialNumber)
end)

QBCore.Functions.CreateUseableItem(config.trackerScannerItem, function(source, item)
    TriggerClientEvent('qb_vehicle_tracker:client:scanTracker', source, item.slot)
end)

-- Events
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        MySQL.query.await('DELETE FROM `vehicle_trackers` WHERE startedAt < (NOW() - INTERVAL 7 DAY)')
    end
end)

RegisterNetEvent('qb_vehicle_tracker:server:placeTracker', function(vehicleNetID, vehiclePlate, slot, serialNumber)
    if not vehiclePlate or not vehicleNetID or not serialNumber then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.AddItem(config.trackerTabletItem, 1, false, { plate = vehiclePlate, serialNumber = serialNumber }) then
        Player.Functions.RemoveItem(config.trackerItem, 1, slot)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[config.trackerTabletItem], 'add')
    end

    MySQL.prepare.await('INSERT INTO `vehicle_trackers` (`serialNumber`, `vehiclePlate`) VALUES (?, ?)', {serialNumber, vehiclePlate})
end)

RegisterNetEvent('qb_vehicle_tracker:server:removeTracker', function(vehiclePlate, slot)
    if not vehiclePlate then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    MySQL.prepare.await('DELETE FROM `vehicle_trackers` WHERE `vehiclePlate` = ?', {vehiclePlate})

    if Player.Functions.RemoveItem(config.trackerScannerItem, 1, slot) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[config.trackerScannerItem], 'remove')
    end
end)

-- Callbacks
lib.callback.register('qb_vehicle_tracker:server:getTrackedVehicleBySerial', function(source, serialNumber)
    if not serialNumber then return end

    local tracker = MySQL.single.await('SELECT `serialNumber`, `vehiclePlate` FROM `vehicle_trackers` WHERE `serialNumber` = ? LIMIT 1', {serialNumber})

    if not tracker then return end

    local vehicleNetworkID = GetVehicleNetworkIdByPlate(tracker.vehiclePlate)

    if not vehicleNetworkID then return end

    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetworkID)

    if not DoesEntityExist(vehicleEntity) then return end

    local vehCoords = GetEntityCoords(vehicleEntity)

    return tracker.vehiclePlate, vector2(vehCoords.x, vehCoords.y)
end)

lib.callback.register('qb_vehicle_tracker:server:isVehicleTracked', function(source, vehiclePlate)
    if not vehiclePlate then return end

    return MySQL.single.await('SELECT `serialNumber` FROM `vehicle_trackers` WHERE `vehiclePlate` = ? LIMIT 1', { vehiclePlate })
end)