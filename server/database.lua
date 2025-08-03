-- Initialize database table for coins
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS user_coins (
            identifier VARCHAR(50) PRIMARY KEY,
            coins INT(11) DEFAULT 0
        )
    ]], {})
end)

-- Get player coins
function GetPlayerCoins(identifier)
    local result = MySQL.Sync.fetchScalar('SELECT coins FROM user_coins WHERE identifier = ?', {identifier})
    return result or 0
end

-- Set player coins
function SetPlayerCoins(identifier, amount)
    MySQL.Async.execute('INSERT INTO user_coins (identifier, coins) VALUES (?, ?) ON DUPLICATE KEY UPDATE coins = ?', {
        identifier, amount, amount
    })
end

-- Add coins to player
function AddPlayerCoins(identifier, amount)
    local currentCoins = GetPlayerCoins(identifier)
    local newAmount = currentCoins + amount
    SetPlayerCoins(identifier, newAmount)
    return newAmount
end

-- Remove coins from player
function RemovePlayerCoins(identifier, amount)
    local currentCoins = GetPlayerCoins(identifier)
    local newAmount = math.max(0, currentCoins - amount)
    SetPlayerCoins(identifier, newAmount)
    return newAmount
end
