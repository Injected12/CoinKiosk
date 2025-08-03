ESX = exports["es_extended"]:getSharedObject()

local shopNPC = nil
local pickupNPC = nil

-- Create NPCs
CreateThread(function()
    -- Create shop NPC
    RequestModel(Config.ShopNPC.model)
    while not HasModelLoaded(Config.ShopNPC.model) do
        Wait(1)
    end
    
    shopNPC = CreatePed(4, Config.ShopNPC.model, Config.ShopNPC.coords.x, Config.ShopNPC.coords.y, Config.ShopNPC.coords.z - 1.0, Config.ShopNPC.coords.w, false, true)
    FreezeEntityPosition(shopNPC, true)
    SetEntityInvincible(shopNPC, true)
    SetBlockingOfNonTemporaryEvents(shopNPC, true)
    
    -- Create pickup NPC
    RequestModel(Config.PickupNPC.model)
    while not HasModelLoaded(Config.PickupNPC.model) do
        Wait(1)
    end
    
    pickupNPC = CreatePed(4, Config.PickupNPC.model, Config.PickupNPC.coords.x, Config.PickupNPC.coords.y, Config.PickupNPC.coords.z - 1.0, Config.PickupNPC.coords.w, false, true)
    FreezeEntityPosition(pickupNPC, true)
    SetEntityInvincible(pickupNPC, true)
    SetBlockingOfNonTemporaryEvents(pickupNPC, true)
    
    -- Create shop blip
    local blip = AddBlipForCoord(Config.ShopNPC.coords.x, Config.ShopNPC.coords.y, Config.ShopNPC.coords.z)
    SetBlipSprite(blip, Config.ShopBlip.sprite)
    SetBlipColour(blip, Config.ShopBlip.color)
    SetBlipScale(blip, Config.ShopBlip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.ShopBlip.name)
    EndTextCommandSetBlipName(blip)
end)

-- Handle NPC interactions
CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Shop NPC interaction
        local shopDistance = #(playerCoords - vector3(Config.ShopNPC.coords.x, Config.ShopNPC.coords.y, Config.ShopNPC.coords.z))
        if shopDistance < 2.0 then
            sleep = 0
            DrawText3D(Config.ShopNPC.coords.x, Config.ShopNPC.coords.y, Config.ShopNPC.coords.z + 1.0, Config.ShopNPC.label)
            
            if shopDistance < 1.5 then
                ESX.ShowHelpNotification('Tryck ~INPUT_CONTEXT~ för att öppna coin butiken')
                if IsControlJustReleased(0, 38) then -- E key
                    TriggerEvent('coinshop:openShop')
                end
            end
        end
        
        -- Pickup NPC interaction
        local pickupDistance = #(playerCoords - vector3(Config.PickupNPC.coords.x, Config.PickupNPC.coords.y, Config.PickupNPC.coords.z))
        if pickupDistance < 2.0 then
            sleep = 0
            DrawText3D(Config.PickupNPC.coords.x, Config.PickupNPC.coords.y, Config.PickupNPC.coords.z + 1.0, Config.PickupNPC.label)
            
            if pickupDistance < 1.5 then
                ESX.ShowHelpNotification('Tryck ~INPUT_CONTEXT~ för att hämta din vara')
                if IsControlJustReleased(0, 38) then -- E key
                    exports[GetCurrentResourceName()]:HandlePickupInteraction()
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Draw 3D text function
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 68)
end
