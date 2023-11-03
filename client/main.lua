local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

local QBCore = exports['qb-core']:GetCoreObject()

local HasKey = false
local LastVehicle = nil
local IsHotwiring = false
local IsRobbing = false
local isLoggedIn = true
local requiredItemsShowed = false
local AlertSend = false
local lockpicked = false
local lockpickedPlate = nil
local hacked = false
local hackedPlate = nil
VehicleClass = {
    [0] = 'compacts',
    [1] = 'sedans',
    [2] = 'suvs',
    [3] = 'coupes',
    [4] = 'muscle',
    [5] = 'sportclassics',
    [6] = 'sports',
    [7] = 'super',
    [8] = 'motorcycles',
    [9] = 'offroad',
    [10] = 'industrial',
    [11] = 'utility',
    [12] = 'vans',
    [13] = 'bicycles',
    [14] = 'boats',
    [15] = 'helicopters',
    [16] = 'planes',
    [17] = 'services',
    [18] = 'emergency',
    [19] = 'military',
    [20] = 'commercial',
    [21] = 'trains',
}

CreateThread(function()
    while true do
        Wait(50)
        if IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), true), -1) == PlayerPedId() and QBCore ~= nil then
            local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true)):gsub("%s+", "")
            if LastVehicle ~= GetVehiclePedIsIn(PlayerPedId(), false) then
                QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
                    if result then
                        HasKey = true
                        SetVehicleEngineOn(veh, true, false, true)
                    else
                        HasKey = false
                        SetVehicleEngineOn(veh, false, false, true)
                    end
                    LastVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                end, plate)
            end
        end

        if not HasKey and IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() and QBCore ~= nil and not IsHotwiring then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            SetVehicleEngineOn(veh, false, false, true)
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            local vehpos = GetOffsetFromEntityInWorldCoords(veh, 0, 0, 0)
            SetVehicleEngineOn(veh, false, false, true)
        end
        Wait(250)
    end
    
end)

RegisterKeyMapping('togglelocks', 'Toggle Vehicle Locks', 'keyboard', 'L')
RegisterCommand('togglelocks', function()
    LockVehicle()
end)

CreateThread(function()
    while true do
        Wait(50)
        if not IsRobbing and isLoggedIn and QBCore ~= nil then
            if GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= nil and GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= 0 then
                local vehicle = GetVehiclePedIsTryingToEnter(PlayerPedId())
                local driver = GetPedInVehicleSeat(vehicle, -1)
                if driver ~= 0 and not IsPedAPlayer(driver) then
                    if IsEntityDead(driver) then
                        IsRobbing = true
                        QBCore.Functions.Progressbar("rob_keys", "Taking keys.", 2000, false, true, {}, {}, {}, {}, function() -- Done
                            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
                            HasKey = true
                            IsRobbing = false
                        end)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('vehiclekeys:client:SetOwner')
AddEventHandler('vehiclekeys:client:SetOwner', function(plate)
    local VehPlate = plate
    if VehPlate == nil then
        VehPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true))
    end
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwner', VehPlate)
    if IsPedInAnyVehicle(PlayerPedId()) and plate == GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true)) then
        SetVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), true), true, false, true)
    end
    HasKey = true
    --QBCore.Functions.Notify('You picked the keys of the vehicle', 'success', 3500)
end)

RegisterNetEvent('vehiclekeys:client:GiveKeys')
AddEventHandler('vehiclekeys:client:GiveKeys', function(target)
    local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true)):gsub("%s+", "")
    TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', plate, target)
end)

-- RegisterNetEvent('vehiclekeys:client:GiveKeysClosest')
-- AddEventHandler('vehiclekeys:client:GiveKeysClosest', function()
--     local player, distance = QBCore.Functions.GetClosestPlayer()
--     local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true))
--     local plycoords = GetEntityCoords(PlayerPedId())
--     if player and plate and distance then
--         if GetDistanceBetweenCoords(distance.x, distance.y, distance.z, plycoords.x, plycoords.y, plycoords.z, false) < 3.0 then
--             TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', plate, GetPlayerServerId(player))
--         end
--     end
-- end)

-- RegisterNetEvent('vehiclekeys:client:GiveKeysClosest')
-- AddEventHandler('vehiclekeys:client:GiveKeysClosest', function()
--     local player, distance = QBCore.Functions.GetClosestPlayer()
--     if player ~= -1 then
--         if distance < 5.0 then
--             TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', plate, GetPlayerServerId(player))
--         else
--             QBCore.Functions.Notify("You are too far away")
--         end
--     else
--         QBCore.Functions.Notify("No one nearby")
--     end
-- end)

RegisterNetEvent('vehiclekeys:client:GiveKeysClosest')
AddEventHandler('vehiclekeys:client:GiveKeysClosest', function()
    local player = PlayerPedId()
    local veh = GetVehiclePedIsIn(player, false)
    if veh == nil then
        QBCore.Functions.Notify("You are not in a vehicle")
        return
    end
    for i=-1, GetVehicleMaxNumberOfPassengers(veh)-1 do
        local ped = GetPedInVehicleSeat(veh, i)
        if ped ~= player then
            for k, v in pairs(GetActivePlayers()) do
                if GetPlayerPed(v) == ped then
                    TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', GetVehicleNumberPlateText(veh), GetPlayerServerId(v))
                end
            end
        end
    end
end)



RegisterNetEvent('vehiclekeys:client:ToggleEngine')
AddEventHandler('vehiclekeys:client:ToggleEngine', function()
    local EngineOn = IsVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId()))
    local veh = GetVehiclePedIsIn(PlayerPedId(), true)
    if HasKey then
        if EngineOn then
            SetVehicleEngineOn(veh, false, false, true)
        else
            SetVehicleEngineOn(veh, true, false, true)
        end
    end
end)

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function(isAdvanced)    
    if (IsPedInAnyVehicle(PlayerPedId())) then
        if not HasKey then
            LockpickIgnition(isAdvanced)
        end
    else
        LockpickDoor(isAdvanced)
    end
end)

RegisterNetEvent('qb-vehiclekeys:client:useSecuritySystem', function ()
    local ped = PlayerPedId()
    print("key")
    if IsPedInAnyVehicle(ped, false) and lockpicked and not IsHotwiring and not HasVehicleKey then
        local veh = GetVehiclePedIsIn(ped)
        if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
            SetVehicleEngineOn(veh, false, false, true)
            HackVeh()
        end
    else
        Hack()
    end
end)

function isAuthorized(vehicle)
    local authorized = true
    local vehClass = VehicleClass[GetVehicleClass(vehicle)]
    local vehModel = GetEntityModel(vehicle)
    local vehName2 = GetDisplayNameFromVehicleModel(vehModel)
    local vehName = vehName2:lower()
    for i = 1, #Config.Vehicle['name'], 1 do
        if vehName == Config.Vehicle['name'][i] then
            authorized = false
            return authorized
        end
    end
    for i = 1, #Config.Vehicle['vehicle_class'], 1 do
        if vehClass == Config.Vehicle['vehicle_class'][i] then
            authorized = false
            return authorized
        end
    end
    for i = 1, #Config.Vehicle['brand'], 1 do
        if QBCore.Shared.Vehicles[vehName]['brand']:lower() == Config.Vehicle['brand'][i]:lower() then
            authorized = false
            return authorized
        end
    end
    return authorized
end

local function LockpickMinigame()
    local authorized
    local finished = exports['qb-lock']:StartLockPickCircle(7, 20)
    if finished then
        authorized = true
    else
        authorized = false
    end
    return authorized
end

function RobVehicle(target)
    IsRobbing = true
    Citizen.CreateThread(function()
        while IsRobbing do
            local RandWait = math.random(4000, 6000)
            loadAnimDict("random@mugging3")

            TaskLeaveVehicle(target, GetVehiclePedIsIn(target, true), 256)
            Citizen.Wait(1000)
            ClearPedTasksImmediately(target)

            TaskStandStill(target, RandWait)
            TaskHandsUp(target, RandWait, PlayerPedId(), 0, false)

            Citizen.Wait(RandWait)

            --TaskReactAndFleePed(target, PlayerPedId())
            IsRobbing = false
        end
    end)
end

function LockVehicle()
    local veh = QBCore.Functions.GetClosestVehicle()
    local coordA = GetEntityCoords(PlayerPedId(), true)
    local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 255.0, 0.0)
    -- local veh = GetClosestVehicleInDirection(coordA, coordB)
    local pos = GetEntityCoords(PlayerPedId(), true)
    if IsPedInAnyVehicle(PlayerPedId()) then
        veh = GetVehiclePedIsIn(PlayerPedId())
    end
    local plate = GetVehicleNumberPlateText(veh):gsub("%s+", "")
    local vehpos = GetEntityCoords(veh, false)
    if veh ~= nil and #(pos - vehpos) < 7.5 then
        QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
            if result then
                if HasKey then
                    local vehLockStatus = GetVehicleDoorLockStatus(veh)
                    loadAnimDict("anim@mp_player_intmenu@key_fob@")
                    TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click' ,3.0, 3.0, -1, 49, 0, false, false, false)
        
                    if vehLockStatus == 1 then
                        Wait(300)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "lock", 0.3)
                        SetVehicleDoorsLocked(veh, 2)
                        if(GetVehicleDoorLockStatus(veh) == 2)then
                            QBCore.Functions.Notify("Vehicle locked!")
                        else
                            QBCore.Functions.Notify("Something went wrong whit the locking system!")
                        end
                    else
                        Wait(300)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "unlock", 0.3)
                        SetVehicleDoorsLocked(veh, 1)
                        if(GetVehicleDoorLockStatus(veh) == 1)then
                            QBCore.Functions.Notify("Vehicle unlocked!")
                        else
                            QBCore.Functions.Notify("Something went wrong whit the locking system!")
                        end
                    end
        
                    if not IsPedInAnyVehicle(PlayerPedId()) then
                        SetVehicleInteriorlight(veh, true)
                        SetVehicleIndicatorLights(veh, 0, true)
                        SetVehicleIndicatorLights(veh, 1, true)
                        Wait(450)
                        SetVehicleIndicatorLights(veh, 0, false)
                        SetVehicleIndicatorLights(veh, 1, false)
                        Wait(450)
                        SetVehicleInteriorlight(veh, true)
                        SetVehicleIndicatorLights(veh, 0, true)
                        SetVehicleIndicatorLights(veh, 1, true)
                        Wait(450)
                        SetVehicleInteriorlight(veh, false)
                        SetVehicleIndicatorLights(veh, 0, false)
                        SetVehicleIndicatorLights(veh, 1, false)
                    end
                end
            else
                QBCore.Functions.Notify('You dont have the keys of the vehicle..', 'error')
            end
        end, plate)
    end
end

local openingDoor = false
function LockpickDoor(isAdvanced)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if vehicle ~= nil and vehicle ~= 0 then
        local vehpos = GetEntityCoords(vehicle)
        local pos = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, vehpos.x, vehpos.y, vehpos.z, true) < 2.0 then
            local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
            local vehicleClass = GetVehicleClass(vehicle)
            if (vehLockStatus > 1) then
                usingAdvanced = isAdvanced
                -- LockpickDoorAnim(lockpickTime)
                -- PoliceCall()
                local authorized = isAuthorized(vehicle)
                if not authorized then 
                    return QBCore.Functions.Notify("You are not authorized to lockpick this vehicle..", "error")
                end
                IsHotwiring = true
                SetVehicleAlarm(vehicle, true)
                -- SetVehicleAlarmTimeLeft(vehicle, lockpickTime)
                openingDoor = true
                loadAnimDict("veh@break_in@0h@p_m_one@")
                Citizen.CreateThread(function()
                    while openingDoor do
                        TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
                        Citizen.Wait(3000)
                    end
                end)
                    local time = math.random(55,120)
                    local circles = math.random(1,1)
                    local success = LockpickMinigame()
                    if success then
                        openingDoor = false
                        StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                        IsHotwiring = false
                        QBCore.Functions.Notify("Door Unlocked!")
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "unlock", 0.3)
                        SetVehicleDoorsLocked(vehicle, 0)
                        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                        SetVehicleAlarm(vehicle, false)
                    else
                        openingDoor = false
                        StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                        QBCore.Functions.Notify("Your lockpick bent out of shape!", "error")
                        IsHotwiring = false
                        SetVehicleAlarm(vehicle, false)
                end
            end
        end
    end
end

function LockpickDoorAnim(time)
    time = time / 1000
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(1000)
            time = time - 1
            if time <= 0 then
                openingDoor = false
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
    end)
end

function LockpickIgnition(isAdvanced)
    if not HasKey then   
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, true)
        if vehicle ~= nil and vehicle ~= 0 then
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                usingAdvanced = isAdvanced
                -- LockpickDoorAnim(lockpickTime)
                -- PoliceCall()
                local authorized = isAuthorized(vehicle)
                if not authorized then 
                    return QBCore.Functions.Notify("You are not authorized to lockpick this vehicle..", "error")
                end

                loadAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                TaskPlayAnim(PlayerPedId(), 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer' ,3.0, 3.0, -1, 16, 0, false, false, false)
            if usingAdvanced then
                local seconds = math.random(7, 20)
                local circles = math.random(3,5)
                local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                if success then
                    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                    IsHotwiring = false
                    QBCore.Functions.Notify("Lockpick successful!")
                    HasKey = true
                    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
                else
                    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                    HasKey = false
                    SetVehicleEngineOn(veh, false, false, true)
                    QBCore.Functions.Notify("Lockpick bent out of shape", "error")
                    IsHotwiring = false
                end
            else
                local seconds = math.random(7,10)
                local circles = math.random(2,4)
                local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                    if success then
                        StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                        StopAnimTask(ped, dict, "machinic_loop_mechandplayer", 1.0)
                        QBCore.Functions.Notify("Lockpicking succeeded!")
                        HasKey = true
                        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
                        IsHotwiring = false
                    else
                        QBCore.Functions.Notify("Lockpicking failed!", "error")
                    end
                end
            end
        end
    end
end

function lockpickFinish(success)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    local chance = math.random()
    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify('Opened Door!', 'success')
        SetVehicleDoorsLocked(vehicle, 1)
        lockpicked = true
        lockpickedPlate = QBCore.Functions.GetPlate(vehicle)
    else
        PoliceCall()
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
		lockpicked = false
		lockpickedPlate = QBCore.Functions.GetPlate(vehicle)
    end
    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
            exports['qb-inventory']:toggleItem(0, "advancedlockpick", 1)
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
            exports['qb-inventory']:toggleItem(0, "lockpick", 1)
        end
    end
end

function PoliceCall()
    local pos = GetEntityCoords(PlayerPedId())
    local chance = 25
    if GetClockHours() >= 1 and GetClockHours() <= 6 then
        chance = 3
    end
    if math.random(1, 100) <= chance then
        local closestPed = GetNearbyPed()
        if closestPed ~= nil then
            if IsPedInAnyVehicle(PlayerPedId()) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                exports['ps-dispatch']:StolenVehicle(vehicle)
            else
                local vehicle = QBCore.Functions.GetClosestVehicle()
                exports['ps-dispatch']:StolenVehicle(vehicle)
            end
        else
            if math.random(1, 100) <= 10 then
                if IsPedInAnyVehicle(PlayerPedId()) then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    exports['ps-dispatch']:StolenVehicle(vehicle)
                else
                    local vehicle = QBCore.Functions.GetClosestVehicle()
                    exports['ps-dispatch']:StolenVehicle(vehicle)
                end
            end
        end
    end
end

function HackVeh()
    if not HasKey then
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, true)
        if vehicle then   
            local authorized = isAuthorized(vehicle)
            if authorized then
                return QBCore.Functions.Notify("You don't need high tech stuff to unlock this vehicle, go get a lockpick", 'error')
            end
            IsHotwiring = true
            lockpickedPlate = nil
            loadAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
            TaskPlayAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, -8.0, -1, 16, 0, false, false, false)
            local success = exports['boostinghack']:StartHack()
            if success then
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
                QBCore.Functions.Notify('You Got The Keys!', 'success')
                SetVehicleEngineOn(vehicle, false, false, true)
            else
                QBCore.Functions.Notify('You Failed To Get The Keys!', 'error')
                exports['ps-dispatch']:VehicleTheft(vehicle)
            end
            IsHotwiring = false
            StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        end
    end
end

function Hack()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    if vehicle ~= nil and vehicle ~= 0 then
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 2.5 then
            local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
            if(vehLockStatus >= 0) then
                local authorized = isAuthorized(vehicle)
                if authorized then
                    return QBCore.Functions.Notify("You don't need high tech stuff to unlock this vehicle, go get a lockpick", 'error')
                end
                local dict = "amb@medic@standing@kneel@idle_a"
                local anim = "idle_c"
                loadAnimDict(dict)
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 1, 0)
                local success = exports['boostinghack']:StartHack()
                if success then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                    QBCore.Functions.Notify('You just unlocked the door', 'success')
                    SetVehicleDoorsLocked(vehicle, 1)
                    lockpicked = true
                    lockpickedPlate = QBCore.Functions.GetPlate(vehicle)
                end
                StopAnimTask(PlayerPedId(), dict, anim, 1.0)
            end
        end
    end
end

function GetClosestVehicleInDirection(coordFrom, coordTo)
	local offset = 0
	local rayHandle
	local vehicle

	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)	
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		
		offset = offset - 1

		if vehicle ~= 0 then break end
	end
	
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
	
	if distance > 250 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function GetNearbyPed()
	local retval = nil
	local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert(PlayerPeds, ped)
    end
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
	local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)
	if not IsEntityDead(closestPed) and closestDistance < 30.0 then
		retval = closestPed
	end
	return retval
end

function IsBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    if weapon ~= nil then
        for _, v in pairs(Config.NoRobWeapons) do
            if weapon == GetHashKey(v) then
                return true
            end
        end
    end
    return false
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 0 )
    end
end


local recentRobs = {}
local LastGive = {}
local LastGiveCash = {}

Citizen.CreateThread(function()
    while true do
        Wait(1)
        aiming, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if aiming then
            local pedCrds = GetEntityCoords(PlayerPedId())
            local entCrds = GetEntityCoords(ent)

            local pedType = GetPedType(ent)
            local animalped = false
            if pedType == 6 or pedType == 27 or pedType == 29 or pedType == 28 then
                animalped = true
            end

            if not animalped and #(pedCrds - entCrds) < 5.0 and not recentRobs["rob"..ent] and not IsPedAPlayer(ent) and not IsEntityDead(ent) and not IsPedDeadOrDying(ent, 1) and IsPedArmed(PlayerPedId(), 6) and not IsPedArmed(ent, 7) and not IsEntityPlayingAnim(ent, "missfbi5ig_22", "hands_up_anxious_scientist", 3) then
                local veh = 0
                if IsPedInAnyVehicle(ent, false) and GetEntitySpeed(veh) < 1.5 then
                    ClearPedTasks(ent)
                    Citizen.Wait(100)
                    veh = GetVehiclePedIsIn(ent,false)
                    TaskLeaveVehicle(ent, veh, 0)
                    Citizen.Wait(1500)
                    TriggerEvent("robEntity", ent, veh)
                    recentRobs["rob"..ent] = true
                    Citizen.Wait(10000)
                end

                if not IsPedInAnyVehicle(ent, false) then
                    TriggerEvent("robEntity",ent,veh)
                    recentRobs["rob"..ent] = true
                    Citizen.Wait(1000)
                end

            end

        else
            Wait(1000)
        end
    end
end)


-- 303280717 safe hash
local RobbedRegisters = {}
RegisterNetEvent("robEntity")
AddEventHandler("robEntity", function(entityRobbed,veh)

    local robbingEntity = true
    local startCrds = GetEntityCoords(PlayerPedId())
    local entCrds = GetEntityCoords(PlayerPedId())
    local pedCrds = GetEntityCoords(PlayerPedId())

    TaskLeaveVehicle(entityRobbed, veh, 0)
    SetPedFleeAttributes(entityRobbed, 0, 0)
    SetPedDropsWeaponsWhenDead(entityRobbed,false)
    ClearPedTasks(entityRobbed)
    ClearPedSecondaryTask(entityRobbed)
    TaskTurnPedToFaceEntity(entityRobbed, PlayerPedId(), 3.0)
    TaskSetBlockingOfNonTemporaryEvents(entityRobbed, true)
    SetPedCombatAttributes(entityRobbed, 17, 1)
    SetPedSeeingRange(entityRobbed, 0.0)
    SetPedHearingRange(entityRobbed, 0.0)
    SetPedAlertness(entityRobbed, 0)
    SetPedKeepTask(entityRobbed, true)
    SetVehicleCanBeUsedByFleeingPeds(veh, false)
    ResetPedLastVehicle(entityRobbed)
    Citizen.Wait(10)

    RequestAnimDict("missfbi5ig_22")
    while not HasAnimDictLoaded("missfbi5ig_22") do
        Citizen.Wait(0)
    end

    local storeRobbery = false
    local alerted = false
    local robberySuccessful = true

    while robbingEntity do
        Wait(10)
        if not IsEntityPlayingAnim(entityRobbed, "missfbi5ig_22", "hands_up_anxious_scientist", 3) then
            TaskPlayAnim(entityRobbed, "missfbi5ig_22", "hands_up_anxious_scientist", 5.0, 1.0, -1, 1, 0, 0, 0, 0)
            Wait(1000)
        end

        pedCrds = GetEntityCoords(PlayerPedId())
        entCrds = GetEntityCoords(entityRobbed)

        if #(pedCrds - entCrds) > 15.0 then
            robbingEntity = false
            robberySuccessful = false
        end
        
        if math.random(1000) < 15 and #(pedCrds - entCrds) < 7.0 then
            --TriggerEvent("traps:luck:ai")

            if veh ~= 0 and LastGive[veh] ~= true then
                TriggerEvent("notification","They handed you the keys!")
                local plate = GetVehicleNumberPlateText(veh, false)
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                Citizen.Wait(7000)
                QBCore.Functions.Notify( "Person gave you his keys!","success")
                HasKey = true
                TriggerEvent("vehiclekeys:client:SetOwner", plate)
                robbingEntity = false
                LastGive[veh] = true
            end

            if veh ~= 0 and LastGiveCash[veh] ~= true then
            if(robberySuccessful) then

            end
        end
            robbingEntity = false
            RequestAnimDict("mp_common")
            while not HasAnimDictLoaded("mp_common") do
                Citizen.Wait(0)
            end			
            TaskPlayAnim( entityRobbed, "mp_common", "givetake1_a", 1.0, 1.0, -1, 1, 0, 0, 0, 0 )
            Citizen.Wait(2200)
        end
    end
    ClearPedTasks(entityRobbed)
    Citizen.Wait(10)
    TaskReactAndFleePed(entityRobbed, PlayerPedId())
    --TaskWanderStandard(entityRobbed, 10.0, 10)

    Citizen.Wait(math.random(1000,30000))	
    if veh ~= 0 then
        PoliceCall()
    else
        PoliceCall()
    end
    if #recentRobs > 20 then
        recentRobs = {}
    end
end)

CreateThread(function()
    while true do
        Wait(50)
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
            local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local lock = GetVehicleDoorLockStatus(veh)
            if lock == 7 then
                SetVehicleDoorsLocked(veh, 2)
            end
                
            local ped = GetPedInVehicleSeat(veh, -1)
    
            if ped then                   
                SetPedCanBeDraggedOut(ped, false)
            end             
        end     						
    end     
end)

    
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterCommand("slimjim", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.name == "police" or PlayerData.job.name == "sasp" or PlayerData.job.name == "fbi" or PlayerData.job.name == "sapr" or PlayerData.job.name == "bcso" then
            local seconds = math.random(7, 20)
            local circles = math.random(3,5)
            local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
            if success then
                StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                IsHotwiring = false
                QBCore.Functions.Notify("Lockpick successful!")
                HasKey = true
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "unlock", 0.3)
                SetVehicleDoorsLocked(vehicle, 0)
                SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                SetVehicleAlarm(vehicle, false)
                TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
            else
                StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                HasKey = false
                SetVehicleEngineOn(vehicle, false, false, true)
                QBCore.Functions.Notify("Lockpick bent out of shape", "error")
                IsHotwiring = false
            end
        else 
            QBCore.Functions.Notify("You are not a cop!", "error")
        end
    end)
end)
