ESX = exports['es_extended']:getSharedObject()

local farming = false
local currentSpot = nil
local activeEffects = {}
local hasEntered = false

CreateThread(function()

    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local inSpot = false

        for _, spot in pairs(Config.FarmSpots) do
            local dist = #(playerCoords - spot.coords)
            if dist < spot.marker.radius then
                sleep = 5 
                inSpot = true

                if not hasEntered then
                    hasEntered = true
                    TriggerEvent('l-interact:show', 'E', spot.label .. ' sammeln')
                end

                if IsControlJustReleased(0, 38) then
                    if not farming then
                        if not IsPedInAnyVehicle(PlayerPedId(), false) then
                            StartFarming(spot)
                        else
                            ESX.ShowNotification("Du kannst nicht im Fahrzeug farmen.")
                        end
                    else
                        StopFarming()
                    end
                end
            end
        end

        if not inSpot and hasEntered then
            hasEntered = false
            TriggerEvent('l-interact:hide')
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, spot in pairs(Config.FarmSpots) do
            local dist = #(playerCoords - spot.coords)
            if dist < 15.0 then
                sleep = 0
                DrawMarker(
                    1,
                    spot.coords.x, spot.coords.y, spot.coords.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    spot.marker.radius * 2.0, spot.marker.radius * 2.0, 1.0,
                    spot.marker.color.r, spot.marker.color.g, spot.marker.color.b, spot.marker.color.a,
                    false, true, 2, nil, nil, false
                )
            else

            end
        end

        Wait(sleep)
    end
end)



function StartFarming(spot)
    farming = true
    currentSpot = spot

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)

    if spot.anim then
        RequestAnimDict(spot.anim.dict)
        while not HasAnimDictLoaded(spot.anim.dict) do Wait(10) end
        TaskPlayAnim(ped, spot.anim.dict, spot.anim.name, 1.0, -1.0, -1, 1, 0, false, false, false)

        CreateThread(function()
            while farming do
                if not IsEntityPlayingAnim(ped, spot.anim.dict, spot.anim.name, 3) and farming then
                    ClearPedTasks(ped)
                    TaskPlayAnim(ped, spot.anim.dict, spot.anim.name, 1.0, -1.0, -1, 1, 0, false, false, false)
                end
                Wait(1000)
            end
        end)
        
    end

    CreateThread(function()
        while farming do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - spot.coords)
            
            if dist > spot.marker.radius then
                StopFarming()
                ESX.ShowNotification("Du hast das Farmgebiet verlassen.")
                break
            end
    
            local waitTime = spot.time
            if HasDrugEffect("farmboost") and spot.boost and spot.boost.time then
                waitTime = spot.boost.time
            end
            Wait(waitTime)
    
            if not farming then break end
    
            TriggerServerEvent("l-drugs:collectItem", spot.item, spot.amount)
        end
    end)
    
end

function StopFarming()
    farming = false
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)
    ESX.ShowNotification("Farming gestoppt.")
end

function HasDrugEffect(effectName)
    return activeEffects[effectName] ~= nil
end

RegisterNetEvent('l-drugs:useDrugItem')
AddEventHandler('l-drugs:useDrugItem', function(itemData)
    local playerPed = PlayerPedId()

    if itemData.health and itemData.health > 0 then
        local currentHealth = GetEntityHealth(playerPed)
        local maxHealth = GetEntityMaxHealth(playerPed)
        SetEntityHealth(playerPed, math.min(currentHealth + itemData.health, maxHealth))
    end

    if itemData.armor and itemData.armor > 0 then
        local currentArmor = GetPedArmour(playerPed)
        SetPedArmour(playerPed, currentArmor + itemData.armor)
    end

    if itemData.buff and itemData.buff.name and itemData.buff.time then
        local buffName = itemData.buff.name
        local buffTime = itemData.buff.time

        if activeEffects[buffName] then
            ESX.ShowNotification("Dieser Buff ist bereits aktiv.")
            return
        end

        activeEffects[buffName] = true
        ESX.ShowNotification("Du hast einen Buff erhalten: " .. buffName)

        Citizen.CreateThread(function()
            Citizen.Wait(buffTime)
            activeEffects[buffName] = nil
            ESX.ShowNotification(buffName .. " ist nun vorbei!")
        end)
    end
    ESX.ShowNotification("Du hast " .. itemData.label .. " verwendet.")
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
    if farming then
        StopFarming()
        ESX.ShowNotification("Du bist gestorben. Farming abgebrochen.")
    end
end)
