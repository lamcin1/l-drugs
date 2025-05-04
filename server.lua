ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent("l-drugs:collectItem")
AddEventHandler("l-drugs:collectItem", function(item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local currentWeight = exports.inventory:getPlayerWeight(xPlayer.source)

    if currentWeight < xPlayer.getMaxWeight() then
        xPlayer.addInventoryItem(item, amount)
    else
        TriggerClientEvent('esx:showNotification', source, 'Du hast nicht genug Platz im Inventar.')
    end
end)


for itemName, itemData in pairs(Config.Drugs) do
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(itemName, 1)
        TriggerClientEvent('l-drugs:useDrugItem', source, itemData)
    end)
end
