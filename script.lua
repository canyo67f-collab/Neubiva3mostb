local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ORANGE_THRESHOLD = 0.50
local RED_THRESHOLD = 0.25

local function addHighlight(character, color, transparency)
    local oldHighlight = character:FindFirstChild("LowHpHighlight")
    if oldHighlight then
        oldHighlight:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "LowHpHighlight"
    highlight.FillColor = color
    highlight.FillTransparency = transparency or 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.3
    highlight.Parent = character
end

local function getColorForHealth(healthPercent)
    if healthPercent < RED_THRESHOLD then
        return Color3.new(1, 0, 0), 0.6
    elseif healthPercent < ORANGE_THRESHOLD then
        return Color3.new(1, 1, 0), 0.5
    else
        return nil, nil
    end
end

local function updateHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            goto continue
        end
        
        local character = player.Character
        if not character then
            goto continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then
            goto continue
        end
        
        if humanoid.Health <= 0 then
            local highlight = character:FindFirstChild("LowHpHighlight")
            if highlight then
                highlight:Destroy()
            end
            goto continue
        end
        
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local color, transparency = getColorForHealth(healthPercent)
        
        if color then
            addHighlight(character, color, transparency)
        else
            local highlight = character:FindFirstChild("LowHpHighlight")
            if highlight then
                highlight:Destroy()
            end
        end
        
        ::continue::
    end
end

local function setupPlayer(player)
    if player == LocalPlayer then
        return
    end
    
    player.CharacterAdded:Connect(function(character)
        local success, err = pcall(function()
            character:WaitForChild("Humanoid", 5)
        end)
        if not success then
            return
        end
        task.wait(0.2)
        updateHighlights()
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                updateHighlights()
            end)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

spawn(function()
    while task.wait(1) do
        updateHighlights()
    end
end)

updateHighlights()

print("HP Highlighter loaded! 25-50% = Yellow, <25% = Red")
