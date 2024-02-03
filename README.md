# QB Vehicle Tracker

a simple Vehicle GPS Tracker resource for QBCore.

## Dependencies
### [qb-core](https://github.com/qbcore-framework/qb-core)
### [ox_lib](https://github.com/overextended/ox_lib)

## Installation
1) Add the following items into your qb-core/shared/items.lua:
```
vehicletracker              = { name = 'vehicletracker', label = 'Vehicle GPS Tracker', weight = 1000, type = 'item', image = 'vehicletracker.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'A device placed to track a vehicle\'s location.'},
vehicletrackertablet        = { name = 'vehicletrackertablet', label = 'Vehicle Tracker Tablet', weight = 1000, type = 'item', image = 'vehicletrackertablet.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'Connects to a vehicle tracker to show it\'s location.'},
vehicletrackerscanner       = { name = 'vehicletrackerscanner', label = 'Vehicle Tracker Scanner', weight = 1000, type = 'item', image = 'vehicletrackerscanner.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'Scans a vehicle for existence of GPS tracker.'},
```

2) Move all images from img/ folder to your inventory image folder. example qb-inventory/html/images

## Usage 
- You must be near a vehicle and **USE** the **vehicletracker** item.
- After using the vehicletracker **USE** the **vehicletrackertablet** you will receive to check its Location.
- **vehicletrackerscanner** can be used to scan and remove a tracker from a vehicle.
