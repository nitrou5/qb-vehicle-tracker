local utils = {}

function utils.getRandomSerialNumber()
    return lib.string.random('...........')
end

function utils.trim(plate)
    return (plate:gsub("^%s*(.-)%s*$", "%1"))
end

function utils.getVehicleNetworkIdByPlate(vehiclePlate)
    local vehicles = GetAllVehicles()

    for _, vehicle in ipairs(vehicles) do
        if utils.trim(GetVehicleNumberPlateText(vehicle)) == utils.trim(vehiclePlate) then
            return NetworkGetNetworkIdFromEntity(vehicle)
        end
    end

    return nil
end

return utils