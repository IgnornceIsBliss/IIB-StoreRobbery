local QBCore = exports['qb-core']:GetCoreObject()
local registeredBoxZones = {}
local activeStore = false

Citizen.CreateThread(function()

    Wait(1000)
    for k,v in pairs(Config.Stores) do
        local storeName = k
        local safeName = storeName.. ' Safe'

        table.insert(registeredBoxZones, safeName)
        exports['qb-target']:AddBoxZone(safeName, vector3(v.safeCoords.xyz), 1.0, 1.0, { -- The name has to be unique, the coords a vector3 as shown and the 1.5 is the radius which has to be a float value
                name = safeName, -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
                debugPoly = false, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
                minZ = v.safeCoords.z -0.5, -- This is the bottom of the boxzone, this can be different from the Z value in the coords, this has to be a float value
                maxZ = v.safeCoords.z +0.5,
                heading = v.safeCoords.w
            },
            {
                options = { -- This is your options table, in this table all the options will be specified for the target to accept
                    { -- This is the first table with options, you can make as many options inside the options table as you want
                        num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                        icon = 'fas fa-screwdriver', -- This is the icon that will display next to this trigger option
                        label = 'Tamper With The Safe', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                        targeticon = 'fas fa-vault', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                        item = 'hack_laptop', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONAL
                        action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL 
                            local safeLoc = v.safeCoords
                            SafeFunction(safeName, safeLoc, storeName)
                        end,
                        canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                            local value = lib.callback.await('IIB-StoreRobbery:GetSafeState',false,safeName)
                            if value == 'robbing' then
                                return false
                            elseif value == 'unlocked' then
                                return false
                            elseif value == 'cooldown' then
                                return false
                            else
                                return true
                            end
                        end,
                    },
                    { -- This is the first table with options, you can make as many options inside the options table as you want
                        num = 2, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                        icon = 'fas fa-clock', -- This is the icon that will display next to this trigger option
                        label = 'Safe Is Being Unlocked', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                        targeticon = 'fas fa-vault', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                        action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL 

                        end,
                        canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                            local value = lib.callback.await('IIB-StoreRobbery:GetSafeState',false,safeName)
                            if value == 'robbing' then
                                return true
                            else
                                return false
                            end
                        end,
                    },
                    { -- This is the first table with options, you can make as many options inside the options table as you want
                        num = 3, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                        icon = 'fas fa-money-bill', -- This is the icon that will display next to this trigger option
                        label = 'Loot The Safe', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                        targeticon = 'fas fa-vault', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                        action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL 
                            SafeLoot(safeName)
                        end,
                        canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                            local value = lib.callback.await('IIB-StoreRobbery:GetSafeState',false,safeName)
                            if value == 'unlocked' then
                                return true
                            else
                                return false
                            end
                        end,
                    },
                    { -- This is the first table with options, you can make as many options inside the options table as you want
                        num = 4, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                        icon = 'fas fa-xmark', -- This is the icon that will display next to this trigger option
                        label = 'Safe Has Been Looted Recently', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                        targeticon = 'fas fa-vault', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                        action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL 
                     
                        end,
                        canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                            local value = lib.callback.await('IIB-StoreRobbery:GetSafeState',false,safeName)
                            if value == 'cooldown' then
                                return true
                            else
                                return false
                            end
                        end,
                    },
                    { -- This is the first table with options, you can make as many options inside the options table as you want
                        num = 5, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                        icon = 'fas fa-money-bill', -- This is the icon that will display next to this trigger option
                        label = 'Secure The Safe', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                        targeticon = 'fas fa-vault', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                        action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL 
                            SecureSafe(safeName)
                        end,
                        job = 'police',
                        canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                            local value = lib.callback.await('IIB-StoreRobbery:GetSafeState',false,safeName)
                            if value == 'unlocked' then
                                return true
                            else
                                return false
                            end
                        end,
                    },
                },
                distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
            }
        )

        for i,x in pairs(v.registerLocations) do
            local registerName = k.. ' Register '.. i
            table.insert(registeredBoxZones, registerName)
            exports['qb-target']:AddBoxZone(registerName, vector3(x.xyz), 0.5, 0.5, { -- The name has to be unique, the coords a vector3 as shown and the 1.5 is the radius which has to be a float value
                    name = registerName, -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
                    heading = x.w,
                    debugPoly = false, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
                    minZ = x.z -0.25, -- This is the bottom of the boxzone, this can be different from the Z value in the coords, this has to be a float value
                    maxZ = x.z +0.25,
                }, 
                {
                    options = { -- This is your options table, in this table all the options will be specified for the target to accept
                        { -- This is the first table with options, you can make as many options inside the options table as you want
                            num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                            icon = 'fas fa-hammer', -- This is the icon that will display next to this trigger option
                            label = 'Tamper With The Register', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                            targeticon = 'fas fa-cash-register', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                            item = 'advancedlockpick', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONAL
                            action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL 
                                CashRegisterFunction(registerName, storeName)
                            end,
                            canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                                local value = lib.callback.await('IIB-StoreRobbery:GetRegisterStatus',false,registerName)
                                if value == 'cooldown' then
                                    return false
                                else
                                    return true
                                end
                            end,
                        },
                        { -- This is the first table with options, you can make as many options inside the options table as you want
                            num = 2, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                            icon = 'fas fa-xmark', -- This is the icon that will display next to this trigger option
                            label = 'Register Has Been Emptied', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                            targeticon = 'fas fa-cash-register', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                            action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL 

                            end,
                            canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                                local value = lib.callback.await('IIB-StoreRobbery:GetRegisterStatus',false,registerName)
                                if value == 'cooldown' then
                                    return true
                                else
                                    return false
                                end
                            end,
                        }
                    },
                    distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
                }
            )
        end
    end
end)

function SafeFunction(safeName, safeLoc, storeName)

    local copCount = lib.callback.await('IIB-StoreRobbery:GetCopCount')
    print(copCount)
    if copCount >= Config.CopCount then
        local success = exports['SN-Hacking']:ColorPicker(3, 7000, 3000)--ColorPicker(icons(number), typeTime(milliseconds), viewTime(milliseconds))
        if success then
            TriggerServerEvent('IIB-StoreRobbery:RemoveItem','hack_laptop',1)
            if activeStore then else activeStore = true exports['ps-dispatch']:StoreRobbery() DispatchTimer() end
            TriggerServerEvent('IIB-StoreRobbery:StartRobbery',safeName, safeLoc, storeName)
        else
            print("fail")
        end
    else
        QBCore.Functions.Notify('Not Enough Cops Available!', 'error', 5000)
    end
end

function CashRegisterFunction(registerName, storeName)

    local copCount = lib.callback.await('IIB-StoreRobbery:GetCopCount')
    print(copCount)
    if copCount >= Config.CopCount then


        local ped = PlayerPedId()
        lib.requestAnimDict('veh@break_in@0h@p_m_one@')
        FreezeEntityPosition(ped, true)
        TaskPlayAnim(ped, 'veh@break_in@0h@p_m_one@', 'low_force_entry_ds', 8.0, 8.0, 5000, 17, 0, true, true, true)
        local success = exports['SN-Hacking']:SkillBar(5000, 10, 5) --SkillBar(duration(milliseconds or table{min(milliseconds), max(milliseconds)}), width%(number), rounds(number))
        if success then
            FreezeEntityPosition(ped, false)
            ClearPedTasksImmediately(ped)

            TriggerServerEvent('IIB-StoreRobbery:RemoveItem','advancedlockpick',1)

            if activeStore then else activeStore = true exports['ps-dispatch']:StoreRobbery() DispatchTimer() end

            lib.progressCircle({
                duration = 25000,
                label = 'Looting The Register',
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    combat = true,
                },
                anim = {
                    dict = 'oddjobs@shop_robbery@rob_till',
                    clip = 'loop',
                    flag = 17,
                },
            })

            TriggerServerEvent('IIB-StoreRobbery:RegisterLoot',registerName, storeName)
        else
            FreezeEntityPosition(ped, false)
            ClearPedTasksImmediately(ped)
        end
    else
        QBCore.Functions.Notify('Not Enough Cops Available!', 'error', 5000)
    end        
end

function DispatchTimer()
    Citizen.SetTimeout(Config.StoreResetTime * (1000 * 60), function()
        activeStore = false 
    end)
end

function SafeLoot(safeName)
    local ped = PlayerPedId()

    lib.progressCircle({
        duration = 5000,
        label = 'Looting The Safe',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@idle_b',
            clip = 'idle_d',
            flag = 17,
        },
    })

    TriggerServerEvent('IIB-StoreRobbery:SafeLoot',safeName)    
end

function SecureSafe(safeName)
    local ped = PlayerPedId()

    lib.progressCircle({
        duration = 5000,
        label = 'Securing The Safe',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@idle_b',
            clip = 'idle_d',
            flag = 17,
        },
    })

    TriggerServerEvent('IIB-StoreRobbery:SecureSafe',safeName)    
end


AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == 'IIB-StoreRobbery' then
        for k,v in pairs(registeredBoxZones) do
            exports['qb-target']:RemoveZone(v)
            registeredBoxZones = {}
        end
    end
end)