CREATE TABLE IF NOT EXISTS `vehicle_trackers` (
    `serialNumber` varchar(11) NOT NULL,
    `vehiclePlate` varchar(11) NOT NULL,
    `startedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `serialNumber` (`serialNumber`),
    KEY `vehiclePlate` (`vehiclePlate`)
);