local db = {}

function db.deleteOldTrackers()
    return MySQL.query.await('DELETE FROM `vehicle_trackers` WHERE startedAt < (NOW() - INTERVAL 7 DAY)')
end

function db.addTracker(serialNumber, vehiclePlate)
    return MySQL.prepare.await('INSERT INTO `vehicle_trackers` (`serialNumber`, `vehiclePlate`) VALUES (?, ?)', { serialNumber, vehiclePlate })
end

function db.deleteTracker(vehiclePlate)
    return MySQL.prepare.await('DELETE FROM `vehicle_trackers` WHERE `vehiclePlate` = ?', { vehiclePlate })
end

function db.getTracker(serialNumber)
    return MySQL.single.await('SELECT `serialNumber`, `vehiclePlate` FROM `vehicle_trackers` WHERE `serialNumber` = ? LIMIT 1', { serialNumber })
end

function db.isTracked(vehiclePlate)
    return MySQL.scalar.await('SELECT `serialNumber` FROM `vehicle_trackers` WHERE `vehiclePlate` = ? LIMIT 1', { vehiclePlate })
end

return db