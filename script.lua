local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ORANGE_THRESHOLD = 0.50  -- 50% - верхняя граница для жёлтого
local RED_THRESHOLD = 0.25     -- 25% - граница для красного

local function addHighlight(character, color, transparency)
    -- Удаляем старый Highlight если есть
    local oldHighlight = character:FindFirstChild("LowHpHighlight")
    if oldHighlight then oldHighlight:Destroy() end
    
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
        return Color3.new(1, 0, 0), 0.6  -- Красный, более яркий
    elseif healthPercent < ORANGE_THRESHOLD then
        return Color3.new(1, 1, 0), 0.5  -- Жёлтый
    else
        return nil, nil  -- Здоровье в норме — без подсветки
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
        
        -- Проверяем, жив ли игрок
        if humanoid.Health <= 0 then
            -- Убираем подсветку у мёртвых
            local highlight = character:FindFirstChild("LowHpHighlight")
            if highlight then highlight:Destroy() end
            goto continue
        end
        
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local color, transparency = getColorForHealth(healthPercent)
        
        if color then
            addHighlight(character, color, transparency)
        else
            local highlight = character:FindFirstChild("LowHpHighlight")
            if highlight then highlight:Destroy() end
        end
        
        ::continue::
    end
end

-- Обновляем каждую секунду
spawn(function()
    while task.wait(1) do
        updateHighlights()
    end
end)

-- Также обновляемся при изменении здоровья (более быстрое реагирование)
local function watchHealthChanges()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and not humanoid:GetAttribute("HPWatcherAttached") then
                humanoid:SetAttribute("HPWatcherAttached", true)
                humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    updateHighlights()
                end)
            end
        end
    end
end

-- Наблюдаем за новыми персонажами
local function setupPlayer(player)
    if player == LocalPlayer then return end
    
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid", 5)
        task.wait(0.2)
        updateHighlights()
        
        -- Добавляем слежение за здоровьем нового персонажа
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                updateHighlights()
            end)
        end
    end)
end

-- Настройка существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- Настройка новых игроков
Players.PlayerAdded:Connect(setupPlayer)

-- Запускаем начальное обновление
updateHighlights()
watchHealthChanges()

print("HP Highlighter загружен!")
print("Диапазоны: 25-50% = Жёлтый | <25% = Красный")
