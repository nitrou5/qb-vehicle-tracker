local utils = {}

---@return string
function utils.getRandomSerialNumber()
    return lib.string.random('...........')
end

---@param plate string
---@return string
function utils.trim(plate)
    return (plate:gsub("^%s*(.-)%s*$", "%1"))
end

---@param vehiclePlate string
---@return number?
function utils.getVehicleNetworkIdByPlate(vehiclePlate)
    local vehicles = GetAllVehicles()

    for _, vehicle in ipairs(vehicles) do
        if utils.trim(GetVehicleNumberPlateText(vehicle)) == utils.trim(vehiclePlate) then
            return NetworkGetNetworkIdFromEntity(vehicle)
        end
    end

    return nil
end

---@param playerCoords vector3
---@param vehiclePlate string
---@return boolean
function utils.isPlayerNearVehicle(playerCoords, vehiclePlate)
    local vehicle = lib.getClosestVehicle(playerCoords, 3.0, true)

    if not vehicle or not DoesEntityExist(vehicle) or GetVehicleNumberPlateText(vehicle) ~= vehiclePlate then
        return false
    end

    return true
end

return utils