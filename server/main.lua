local QBCore = exports['qb-core']:GetCoreObject()
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local VehicleList = {}

QBCore.Functions.CreateCallback('vehiclekeys:CheckHasKey', function(source, cb, plate)
    local Player = QBCore.Functions.GetPlayer(source)
    cb(CheckOwner(plate, Player.PlayerData.citizenid))
end)

-- QBCore.Functions.CreateUseableItem("weapon_nightstick", function(source, item)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
-- 	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
--         TriggerClientEvent("pull:player:out", src, item.name)
--     end
-- end)

RegisterServerEvent('vehiclekeys:server:SetVehicleOwner')
AddEventHandler('vehiclekeys:server:SetVehicleOwner', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if VehicleList ~= nil then
        if DoesPlateExist(plate) then
            for k, val in pairs(VehicleList) do
                if val.plate == plate then
                    table.insert(VehicleList[k].owners, Player.PlayerData.citizenid)
                end
            end
        else
            local vehicleId = #VehicleList+1
            VehicleList[vehicleId] = {
                plate = plate, 
                owners = {},
            }
            VehicleList[vehicleId].owners[1] = Player.PlayerData.citizenid
        end
    else
        local vehicleId = #VehicleList+1
        VehicleList[vehicleId] = {
            plate = plate, 
            owners = {},
        }
        VehicleList[vehicleId].owners[1] = Player.PlayerData.citizenid
    end
end)

RegisterServerEvent('vehiclekeys:server:GiveVehicleKeys')
AddEventHandler('vehiclekeys:server:GiveVehicleKeys', function(plate, target)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if CheckOwner(plate, Player.PlayerData.citizenid) then
        if QBCore.Functions.GetPlayer(target) ~= nil then
            TriggerClientEvent('vehiclekeys:client:SetOwner', target, plate)
            TriggerClientEvent('QBCore:Notify', src, "You gave the keys!")
            TriggerClientEvent('QBCore:Notify', target, "You got the keys!")
        else
            TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Player not online!")
        end
    else
        TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "You dont have the keys of the vehicle!")
    end
end)

-- QBCore.Commands.Add("engine", "Toggle engine On/Off of the vehicle", {}, false, function(source, args)
-- 	TriggerClientEvent('vehiclekeys:client:ToggleEngine', source)
-- end)

QBCore.Functions.CreateCallback('vehiclekeys:CheckOwnership', function(source, cb, plate)
    local Player = QBCore.Functions.GetPlayer(source)
    local check = CheckOwner(plate, Player.PlayerData.citizenid)
    local retval = check ~= nil
    cb(retval)
end)

QBCore.Functions.CreateCallback('vehiclekeys:CheckHasKey', function(source, cb, plate)
    local Player = QBCore.Functions.GetPlayer(source)
    cb(CheckOwner(plate, Player.PlayerData.citizenid))
end)

QBCore.Commands.Add("givekey", "Give keys of the vehicle", {{name = "id", help = "Speler id"}}, true, function(source, args)
	local src = source
    local target = tonumber(args[1])
    TriggerClientEvent('vehiclekeys:client:GiveKeys', src, target)
end)

QBCore.Commands.Add("givekeys", "Give keys of the vehicle to the closest person", {},true, function(source, args)
	local src = source
    TriggerClientEvent('vehiclekeys:client:GiveKeysClosest', src)
end)

function DoesPlateExist(plate)
    if VehicleList ~= nil then
        for k, val in pairs(VehicleList) do
            if val.plate == plate then
                return true
            end
        end
    end
    return false
end

function CheckOwner(_plate, identifier)
    local plate = _plate:gsub("%s+", "")
    local retval = false
    if VehicleList ~= nil then
        for k, val in pairs(VehicleList) do
            if val.plate == plate then
                for key, owner in pairs(VehicleList[k].owners) do
                    if owner == identifier then
                        retval = true
                    end
                end
            end
        end
    end
    return retval
end

-- QBCore.Functions.CreateUseableItem("lockpick", function(source, item)
--     local Player = QBCore.Functions.GetPlayer(source)                         << required items to lock pick if wanted to set to a item
--     TriggerClientEvent("lockpicks:UseLockpick", source, false)
-- end)

-- QBCore.Functions.CreateUseableItem("advancedlockpick", function(source, item)
--     local Player = QBCore.Functions.GetPlayer(source)                         << required items to lock pick if wanted to set to a item
--     TriggerClientEvent("lockpicks:UseLockpick", source, true)
-- end)

QBCore.Functions.CreateUseableItem("lockpick", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)                        
    TriggerClientEvent("lockpicks:UseLockpick", source, false)
end)

QBCore.Functions.CreateUseableItem("advancedlockpick", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)                         
    TriggerClientEvent("lockpicks:UseLockpick", source, true)
end)

-- Items
QBCore.Functions.CreateUseableItem('securitysystemdevice' , function(source, item)
    local src = source
    TriggerClientEvent('qb-vehiclekeys:client:useSecuritySystem', src)
end)