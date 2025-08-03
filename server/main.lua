ESX = exports["es_extended"]:getSharedObject()

-- Load products from JSON file
local products = {}

function LoadProducts()
    local file = LoadResourceFile(GetCurrentResourceName(), 'data/products.json')
    if file then
        products = json.decode(file) or {}
    end
end

function SaveProducts()
    SaveResourceFile(GetCurrentResourceName(), 'data/products.json', json.encode(products, {indent = true}), -1)
end

-- Initialize
CreateThread(function()
    LoadProducts()
end)

-- Check if player is admin
function IsPlayerAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local steamHex = xPlayer.identifier
    print("Checking admin status for: " .. steamHex) -- Debug
    
    for _, adminHex in pairs(Config.AdminSteamHex) do
        print("Comparing with admin: " .. adminHex) -- Debug
        if steamHex == adminHex then
            return true
        end
    end
    return false
end

-- Check if player is ESX admin
function IsPlayerESXAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local playerGroup = xPlayer.getGroup()
    print("Player group: " .. tostring(playerGroup)) -- Debug
    
    return playerGroup == 'admin' or playerGroup == 'superadmin'
end

-- ESX Admin command to set coin admin
RegisterCommand('setcoinadmin', function(source, args, rawCommand)
    if not IsPlayerESXAdmin(source) then
        TriggerClientEvent('esx:showNotification', source, 'Du har inte behörighet för detta kommando. (Kräver admin grupp)')
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('esx:showNotification', source, 'Användning: /setcoinadmin [id]')
        return
    end
    
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('esx:showNotification', source, 'Spelaren hittades inte.')
        return
    end
    
    local targetSteamHex = targetPlayer.identifier
    
    -- Check if already admin
    for _, adminHex in pairs(Config.AdminSteamHex) do
        if adminHex == targetSteamHex then
            TriggerClientEvent('esx:showNotification', source, targetPlayer.getName() .. ' är redan coin admin.')
            return
        end
    end
    
    -- Add to admin list
    table.insert(Config.AdminSteamHex, targetSteamHex)
    
    TriggerClientEvent('esx:showNotification', source, targetPlayer.getName() .. ' har blivit coin admin.')
    TriggerClientEvent('esx:showNotification', targetId, 'Du har blivit coin admin!')
    
    print("Added coin admin: " .. targetSteamHex .. " (" .. targetPlayer.getName() .. ")")
end, false)

-- ESX Admin command to remove coin admin
RegisterCommand('removecoinadmin', function(source, args, rawCommand)
    if not IsPlayerESXAdmin(source) then
        TriggerClientEvent('esx:showNotification', source, 'Du har inte behörighet för detta kommando. (Kräver admin grupp)')
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('esx:showNotification', source, 'Användning: /removecoinadmin [id]')
        return
    end
    
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('esx:showNotification', source, 'Spelaren hittades inte.')
        return
    end
    
    local targetSteamHex = targetPlayer.identifier
    
    -- Remove from admin list
    for i, adminHex in pairs(Config.AdminSteamHex) do
        if adminHex == targetSteamHex then
            table.remove(Config.AdminSteamHex, i)
            TriggerClientEvent('esx:showNotification', source, targetPlayer.getName() .. ' är inte längre coin admin.')
            TriggerClientEvent('esx:showNotification', targetId, 'Du är inte längre coin admin.')
            print("Removed coin admin: " .. targetSteamHex .. " (" .. targetPlayer.getName() .. ")")
            return
        end
    end
    
    TriggerClientEvent('esx:showNotification', source, targetPlayer.getName() .. ' var inte coin admin.')
end, false)

-- Debug command to check admin status
RegisterCommand('checkcoinadmin', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local steamHex = xPlayer.identifier
    local playerGroup = xPlayer.getGroup()
    
    print("=== COIN ADMIN DEBUG ===")
    print("Player Steam Hex: " .. steamHex)
    print("Player ESX Group: " .. tostring(playerGroup))
    print("Is Coin Admin: " .. tostring(IsPlayerAdmin(source)))
    print("Is ESX Admin: " .. tostring(IsPlayerESXAdmin(source)))
    print("Current Coin Admins:")
    for i, adminHex in pairs(Config.AdminSteamHex) do
        print("  " .. i .. ": " .. adminHex)
    end
    print("========================")
    
    TriggerClientEvent('esx:showNotification', source, 'ESX Group: ' .. tostring(playerGroup) .. ' | Coin Admin: ' .. tostring(IsPlayerAdmin(source)))
end, false)

-- Admin command to give coins
RegisterCommand('givecoins', function(source, args, rawCommand)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('esx:showNotification', source, 'Du har inte behörighet för detta kommando.')
        return
    end
    
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount then
        TriggerClientEvent('esx:showNotification', source, 'Användning: /givecoins [id] [antal]')
        return
    end
    
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent('esx:showNotification', source, 'Spelaren hittades inte.')
        return
    end
    
    local newAmount = AddPlayerCoins(targetPlayer.identifier, amount)
    TriggerClientEvent('esx:showNotification', source, string.format('Gav %d coins till %s. Nytt saldo: %d', amount, targetPlayer.getName(), newAmount))
    TriggerClientEvent('esx:showNotification', targetId, string.format('Du fick %d coins! Nytt saldo: %d', amount, newAmount))
end, false)

-- Player command to check coin status
RegisterCommand('coinstatus', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local coins = GetPlayerCoins(xPlayer.identifier)
    TriggerClientEvent('esx:showNotification', source, string.format('Du har %d coins.', coins))
end, false)

-- Command to open admin panel (available to everyone)
RegisterCommand('coinadmin', function(source, args, rawCommand)
    TriggerClientEvent('coinshop:openAdmin', source)
end, false)

-- Get player coins (callback)
ESX.RegisterServerCallback('coinshop:getCoins', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(0)
        return
    end
    
    local coins = GetPlayerCoins(xPlayer.identifier)
    cb(coins)
end)

-- Get products (callback)
ESX.RegisterServerCallback('coinshop:getProducts', function(source, cb)
    cb(products)
end)

-- Purchase item
RegisterNetEvent('coinshop:purchaseItem')
AddEventHandler('coinshop:purchaseItem', function(productId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local product = nil
    for _, p in pairs(products) do
        if p.id == productId then
            product = p
            break
        end
    end
    
    if not product then
        TriggerClientEvent('esx:showNotification', source, 'Produkten hittades inte.')
        return
    end
    
    local playerCoins = GetPlayerCoins(xPlayer.identifier)
    if playerCoins < product.price then
        TriggerClientEvent('esx:showNotification', source, 'Du har inte tillräckligt med coins.')
        return
    end
    
    -- Remove coins
    RemovePlayerCoins(xPlayer.identifier, product.price)
    
    -- Add to pending pickups
    TriggerClientEvent('coinshop:addPendingPickup', source, product)
    TriggerClientEvent('esx:showNotification', source, 'Ta dig till den markerade platsen på din GPS för att hämta din vara.')
end)

-- Admin: Add product
RegisterNetEvent('coinshop:addProduct')
AddEventHandler('coinshop:addProduct', function(productData)
    local source = source
    if not IsPlayerAdmin(source) then return end
    
    -- Generate unique ID
    productData.id = #products + 1
    table.insert(products, productData)
    SaveProducts()
    
    TriggerClientEvent('esx:showNotification', source, 'Produkt tillagd!')
    TriggerClientEvent('coinshop:refreshProducts', source, products)
end)

-- Admin: Update product
RegisterNetEvent('coinshop:updateProduct')
AddEventHandler('coinshop:updateProduct', function(productId, productData)
    local source = source
    if not IsPlayerAdmin(source) then return end
    
    for i, product in pairs(products) do
        if product.id == productId then
            products[i] = productData
            products[i].id = productId
            break
        end
    end
    
    SaveProducts()
    TriggerClientEvent('esx:showNotification', source, 'Produkt uppdaterad!')
    TriggerClientEvent('coinshop:refreshProducts', source, products)
end)

-- Admin: Delete product
RegisterNetEvent('coinshop:deleteProduct')
AddEventHandler('coinshop:deleteProduct', function(productId)
    local source = source
    if not IsPlayerAdmin(source) then return end
    
    for i, product in pairs(products) do
        if product.id == productId then
            table.remove(products, i)
            break
        end
    end
    
    SaveProducts()
    TriggerClientEvent('esx:showNotification', source, 'Produkt borttagen!')
    TriggerClientEvent('coinshop:refreshProducts', source, products)
end)

-- Handle item pickup
RegisterNetEvent('coinshop:pickupItem')
AddEventHandler('coinshop:pickupItem', function(product)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Add item to inventory using OX Inventory
    if exports.ox_inventory:CanCarryItem(source, product.itemName, 1) then
        exports.ox_inventory:AddItem(source, product.itemName, 1)
        TriggerClientEvent('esx:showNotification', source, string.format('Du fick %s!', product.displayName))
        TriggerClientEvent('coinshop:removePickupBlip', source)
    else
        TriggerClientEvent('esx:showNotification', source, 'Du kan inte bära fler föremål.')
    end
end)
