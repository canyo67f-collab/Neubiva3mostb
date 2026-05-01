local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local THRESHOLD = 0.2

local function addHighlight(character, color)
    -- Удаляем старый Highlight если есть
    local oldHighlight = character:FindFirstChild("LowHpHighlight")
    if oldHighlight then oldHighlight:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "LowHpHighlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.3
    highlight.Parent = character
end

local function updateHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then continue end
        
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        
        if healthPercent < THRESHOLD and humanoid.Health > 0 then
            addHighlight(character, Color3.new(1, 0, 0))
        else
            local highlight = character:FindFirstChild("LowHpHighlight")
            if highlight then highlight:Destroy() end
        end
    end
end

-- Обновляем каждую секунду
while task.wait(1) do
    updateHighlights()
end
