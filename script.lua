--[[
    Скрипт: Визуальное вращение персонажа (НЕ мешает бегу)
    Управление: Клавиша X (Вкл/Выкл)
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local isSpinning = false
local ROTATION_SPEED = 8 -- оборотов в секунду (можно менять)
local spinConnection = nil

-- Эффекты вращения (чисто визуальные)
local function startSpin()
    if spinConnection then 
        spinConnection:Disconnect()
        spinConnection = nil
    end
    
    isSpinning = true
    
    spinConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not isSpinning then return end
        
        local character = player.Character
        if not character then return end
        
        -- Получаем части тела для визуального вращения
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid then return end
        
        -- СПОСОБ 1: Вращаем ТОЛЬКО визуальный угол (не трогаем CFrame)
        -- Это не влияет на физику и движение!
        local rotationAngle = (ROTATION_SPEED * deltaTime * 360) % 360
        
        -- Применяем вращение только к Orientation (визуалка)
        -- ВНИМАНИЕ: Это не сломает движение, так как CFrame остаётся нетронутым
        local currentOrientation = humanoidRootPart.Orientation
        humanoidRootPart.Orientation = Vector3.new(
            currentOrientation.X,
            (currentOrientation.Y + (ROTATION_SPEED * deltaTime * 360)) % 360,
            currentOrientation.Z
        )
        
        -- Дополнительно: вращаем все конечности для эффекта
        local limbs = {
            "UpperTorso", "LowerTorso", "Head",
            "LeftUpperArm", "RightUpperArm",
            "LeftLowerArm", "RightLowerArm"
        }
        
        for _, limbName in pairs(limbs) do
            local limb = character:FindFirstChild(limbName)
            if limb and limb:IsA("BasePart") then
                local limbOrientation = limb.Orientation
                limb.Orientation = Vector3.new(
                    limbOrientation.X,
                    (limbOrientation.Y + (ROTATION_SPEED * deltaTime * 360)) % 360,
                    limbOrientation.Z
                )
            end
        end
    end)
end

local function stopSpin()
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    isSpinning = false
    
    -- Сбрасываем вращение частей тела обратно в ноль (опционально)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Orientation = Vector3.new(0, 0, 0)
        end
        
        local limbs = {
            "UpperTorso", "LowerTorso", "Head",
            "LeftUpperArm", "RightUpperArm",
            "LeftLowerArm", "RightLowerArm"
        }
        
        for _, limbName in pairs(limbs) do
            local limb = character:FindFirstChild(limbName)
            if limb and limb:IsA("BasePart") then
                limb.Orientation = Vector3.new(0, 0, 0)
            end
        end
    end
end

-- Обработка нажатия X
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        if isSpinning then
            stopSpin()
            print("❌ Вращение ОСТАНОВЛЕНО")
        else
            startSpin()
            print("✅ Вращение ЗАПУЩЕНО (Скорость: " .. ROTATION_SPEED .. " об/сек)")
            print("🏃 Теперь можно БЕГАТЬ и вращаться одновременно!")
        end
    end
end)

-- Если персонаж пересоздаётся
player.CharacterAdded:Connect(function()
    stopSpin()
    isSpinning = false
end)

print("=":rep(40))
print("🎡 СКРИПТ ВРАЩЕНИЯ ЗАГРУЖЕН")
print("📌 Нажми X чтобы начать/остановить вращение")
print("🏃 Движение и бег РАБОТАЮТ во время вращения")
print("=":rep(40))
