ESX = exports["es_extended"]:getSharedObject()

local isMenuOpen = false
local pendingPickups = {}

-- Open coin shop
RegisterNetEvent('coinshop:openShop')
AddEventHandler('coinshop:openShop', function()
    if isMenuOpen then return end
    
    ESX.TriggerServerCallback('coinshop:getCoins', function(coins)
        ESX.TriggerServerCallback('coinshop:getProducts', function(products)
            isMenuOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'openShop',
                coins = coins,
                products = products
            })
        end)
    end)
end)

-- Open admin panel
RegisterNetEvent('coinshop:openAdmin')
AddEventHandler('coinshop:openAdmin', function()
    if isMenuOpen then return end
    
    ESX.TriggerServerCallback('coinshop:getProducts', function(products)
        isMenuOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openAdmin',
            products = products
        })
    end)
end)

-- Add pending pickup
RegisterNetEvent('coinshop:addPendingPickup')
AddEventHandler('coinshop:addPendingPickup', function(product)
    table.insert(pendingPickups, product)
    
    -- Add GPS blip
    local blip = AddBlipForCoord(Config.PickupNPC.coords.x, Config.PickupNPC.coords.y, Config.PickupNPC.coords.z)
    SetBlipSprite(blip, Config.PickupBlip.sprite)
    SetBlipColour(blip, Config.PickupBlip.color)
    SetBlipScale(blip, Config.PickupBlip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.PickupBlip.name)
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)
    
    product.blip = blip
end)

-- Remove pickup blip
RegisterNetEvent('coinshop:removePickupBlip')
AddEventHandler('coinshop:removePickupBlip', function()
    for i, pickup in pairs(pendingPickups) do
        if pickup.blip then
            RemoveBlip(pickup.blip)
        end
        table.remove(pendingPickups, i)
        break
    end
end)

-- Refresh products in admin panel
RegisterNetEvent('coinshop:refreshProducts')
AddEventHandler('coinshop:refreshProducts', function(products)
    SendNUIMessage({
        type = 'refreshProducts',
        products = products
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('purchaseItem', function(data, cb)
    TriggerServerEvent('coinshop:purchaseItem', data.productId)
    cb('ok')
end)

RegisterNUICallback('addProduct', function(data, cb)
    TriggerServerEvent('coinshop:addProduct', data)
    cb('ok')
end)

RegisterNUICallback('updateProduct', function(data, cb)
    TriggerServerEvent('coinshop:updateProduct', data.id, data)
    cb('ok')
end)

RegisterNUICallback('deleteProduct', function(data, cb)
    TriggerServerEvent('coinshop:deleteProduct', data.productId)
    cb('ok')
end)

-- Handle item pickup interaction
function HandlePickupInteraction()
    if #pendingPickups == 0 then
        ESX.ShowNotification('Du har inga varor att hämta.')
        return
    end
    
    local playerPed = PlayerPedId()
    local animDict = Config.PickupAnimation.dict
    local animName = Config.PickupAnimation.anim
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(1)
    end
    
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, Config.PickupAnimation.duration, 0, 0, false, false, false)
    
    Wait(Config.PickupAnimation.duration)
    
    -- Give the item
    local pickup = pendingPickups[1]
    TriggerServerEvent('coinshop:pickupItem', pickup)
end

-- Export for NPC script
exports('HandlePickupInteraction', HandlePickupInteraction)
