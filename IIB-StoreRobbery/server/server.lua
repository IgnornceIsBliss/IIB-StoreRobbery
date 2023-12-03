local QBCore = exports['qb-core']:GetCoreObject()
local currentlyRobbing = {}
local unlockedSafes = {}
local cooldownSafes = {}
local cooldownRegisters = {}

RegisterNetEvent('IIB-StoreRobbery:StartRobbery')
AddEventHandler('IIB-StoreRobbery:StartRobbery', function(safeName, safeLoc)
    local src = source

    TriggerClientEvent('QBCore:Notify', src, 'The Safe Code Is Being Decrypted You Must Wait '.. Config.SafeUnlockTime .. ' Minutes')

    table.insert(currentlyRobbing,safeName)

    Citizen.SetTimeout(Config.SafeUnlockTime * (1000 * 60), function()
        TriggerClientEvent('QBCore:Notify', src, 'The Safe Has Been Opened You Can Now Loot It!')

        for k,v in pairs(currentlyRobbing) do
            if v == safeName then
                table.remove(currentlyRobbing, k)
            end
        end
        table.insert(unlockedSafes,safeName)
    end)
end)

lib.callback.register('IIB-StoreRobbery:GetSafeState', function(source, safeName)
    local value = 'locked'
    for k,v in pairs(currentlyRobbing) do
        if v == safeName then
            value = 'robbing'
        end
    end
    for k,v in pairs(unlockedSafes) do
        if v == safeName then
            value = 'unlocked'
        end
    end
    for k,v in pairs(cooldownSafes) do
        if v == safeName then
            value = 'cooldown'
        end
    end

    return value
end)

lib.callback.register('IIB-StoreRobbery:GetRegisterStatus', function(source, registerName)
    local value = 'locked'
    for k,v in pairs(cooldownRegisters) do
        if v == registerName then
            value = 'cooldown'
        end
    end

    return value
end)

RegisterNetEvent('IIB-StoreRobbery:RegisterLoot')
AddEventHandler('IIB-StoreRobbery:RegisterLoot', function(registerName)
    local src = source

	local pData = QBCore.Functions.GetPlayer(src)
    local amount = math.random(Config.RegisterValue.min, Config.RegisterValue.max)
    pData.Functions.AddItem('dirtymoney', amount) -- Assuming 'dirtymoney' is the item name
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["dirtymoney"], "add", amount)

    table.insert(cooldownRegisters,registerName)

    Citizen.SetTimeout(Config.StoreResetTime * (1000 * 60), function()
        for k,v in pairs(cooldownRegisters) do
            if v == safeName then
                table.remove(cooldownRegisters, k)
            end
        end
    end)
end)


RegisterNetEvent('IIB-StoreRobbery:SafeLoot')
AddEventHandler('IIB-StoreRobbery:SafeLoot', function(safeName)
    local src = source
	local pData = QBCore.Functions.GetPlayer(src)
    local amount = math.random(Config.SafeTable.min, Config.SafeTable.max)
    pData.Functions.AddItem('dirtymoney', amount) -- Assuming 'dirtymoney' is the item name
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["dirtymoney"], "add", amount)

    pData.Functions.AddItem('deliverylist', 1) -- Assuming 'dirtymoney' is the item name
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["deliverylist"], "add", 1)

    pData.Functions.AddItem('bcssecuritycard', 1) -- Assuming 'dirtymoney' is the item name
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["bcssecuritycard"], "add", 1)

    table.insert(cooldownSafes,safeName)

    for k,v in pairs(unlockedSafes) do
        if v == safeName then
            table.remove(unlockedSafes, k)
        end
    end

    Citizen.SetTimeout(Config.StoreResetTime * (1000 * 60), function()
        for k,v in pairs(cooldownSafes) do
            if v == safeName then
                table.remove(cooldownSafes, k)
            end
        end
    end)

end)


RegisterNetEvent('IIB-StoreRobbery:SecureSafe')
AddEventHandler('IIB-StoreRobbery:SecureSafe', function(safeName)
    table.insert(cooldownSafes,safeName)

    for k,v in pairs(unlockedSafes) do
        if v == safeName then
            table.remove(unlockedSafes, k)
        end
    end

    Citizen.SetTimeout(Config.StoreResetTime * (1000 * 60), function()
        for k,v in pairs(cooldownSafes) do
            if v == safeName then
                table.remove(cooldownSafes, k)
            end
        end
    end)

end)

lib.callback.register('IIB-StoreRobbery:GetCopCount', function(source)
    local count = 0
    local src = source
    local xPlayers = QBCore.Functions.GetPlayers()

    for i = 1, #xPlayers do
        local player = QBCore.Functions.GetPlayer(xPlayers[i])
        
        if player and player.PlayerData.job and player.PlayerData.job.name == 'police' then
            count = count + 1
        end
    end

    return count
end)

RegisterNetEvent('IIB-StoreRobbery:RemoveItem')
AddEventHandler('IIB-StoreRobbery:RemoveItem', function(itemName, amount)
    local src = source

	local pData = QBCore.Functions.GetPlayer(src)
    pData.Functions.RemoveItem(itemName, amount) -- Assuming 'dirtymoney' is the item name
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove", amount)
end)