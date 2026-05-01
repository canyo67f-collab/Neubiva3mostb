-- Solara Optimized: Red highlight for players under 20% HP
-- Works with Solara V3 executor (keyless, full Lua support)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local THRESHOLD = 0.2 -- 20%

-- Store original colors to restore them later
local originalColors = {}

-- Get the main visual part of a character
local function getVisualPart(character)
    return character:FindFirstChild("Head") 
        or character:FindFirstChild("UpperTorso") 
        or character:FindFirstChild("Torso")
end

-- Save original color if not already saved
local function saveOriginalColor(character, part)
    if part and not originalColors[character] then
        originalColors[character] = part.Color
    end
end

-- Update a single player's color based on their HP
local function updatePlayerColor(player)
    if player == LocalPlayer then return end -- Don't color yourself
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local visualPart = getVisualPart(character)
    if not visualPart then return end
    
    local maxHealth = humanoid.MaxHealth
    local currentHealth = humanoid.Health
    local healthPercent = currentHealth / maxHealth
    
    -- Save original color first time we see this character
    saveOriginalColor(character, visualPart)
    
    -- Apply color based on health
    if healthPercent < THRESHOLD and currentHealth > 0 then
        visualPart.Color = Color3.new(1, 0, 0) -- Red
    else
        -- Restore original color if we have it saved
        if originalColors[character] then
            visualPart.Color = originalColors[character]
        else
            visualPart.Color = Color3.new(1, 1, 1) -- Default white
        end
    end
end

-- Update all players
local function updateAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerColor(player)
    end
end

-- Watch for health changes on a character
local function watchHealthChanges(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Use attribute to avoid duplicate connections (Solara supports attributes)
    if humanoid:GetAttribute("HPWatcherAttached") then
        return
    end
    humanoid:SetAttribute("HPWatcherAttached", true)
    
    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        updateAllPlayers()
    end)
end

-- Watch for new characters from existing players
local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        -- Wait for character to fully load
        character:WaitForChild("Humanoid", 5)
        task.wait(0.3)
        updateAllPlayers()
        watchHealthChanges(character)
    end)
    
    -- If player already has a character, set it up too
    if player.Character then
        local character = player.Character
        if character:FindFirstChild("Humanoid") then
            task.wait(0.3)
            updateAllPlayers()
            watchHealthChanges(character)
        end
    end
end

-- Setup all current players
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- Listen for new players joining
Players.PlayerAdded:Connect(setupPlayer)

-- Periodic update as a fallback (every 2 seconds)
spawn(function()
    while task.wait(2) do
        updateAllPlayers()
    end
end)

-- Initial update
updateAllPlayers()

print("Solara HP Highlighter loaded! Players under 20% HP will turn red.")
