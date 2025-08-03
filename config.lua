Config = {}

-- Admin Steam Hex IDs (add your admin Steam Hex here)
Config.AdminSteamHex = {
    "steam:110000000000000", -- Replace with actual Steam Hex
    "steam:110000000000001"  -- Add more as needed
}

-- NPC Locations and Models
Config.ShopNPC = {
    coords = vector4(221.1801, 2800.9355, 45.8399, 97.9855),
    model = "a_m_m_soucent_03",
    label = "COIN butik"
}

Config.PickupNPC = {
    coords = vector4(166.7342, 2228.9272, 90.7741, 75.3422),
    model = "a_m_y_beach_03",
    label = "Hämta vara"
}

-- Blip Settings
Config.ShopBlip = {
    sprite = 52,
    color = 3,
    scale = 0.8,
    name = "Coin Shop"
}

Config.PickupBlip = {
    sprite = 478,
    color = 2,
    scale = 0.8,
    name = "Hämta vara"
}

-- Animation for pickup
Config.PickupAnimation = {
    dict = "mp_common",
    anim = "givetake1_a",
    duration = 3000
}

-- Database table name for coins
Config.CoinsTable = "user_coins"
