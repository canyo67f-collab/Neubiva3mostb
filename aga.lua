-- Solara Script: Reverse Runner для Evade
-- Персонаж бежит спиной вперёд, сохраняя нормальную скорость

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = nil
local humanoid = nil
local rootPart = nil

-- Функция обновления персонажа
local function updateCharacter()
    character = player.Character
    if character then
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
    end
end

player.CharacterAdded:Connect(function()
    updateCharacter()
end)
updateCharacter()

-- Включаем/выключаем режим (клавиша R)
local reverseMode = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        reverseMode = not reverseMode
        if reverseMode then
            -- Отключаем авто-поворот, который мешает
            if humanoid then
                humanoid.AutoRotate = false
            end
            print("✅ Режим бега задом ВКЛЮЧЕН")
        else
            if humanoid then
                humanoid.AutoRotate = true
            end
            print("❌ Режим бега задом ВЫКЛЮЧЕН")
        end
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    if not character or not humanoid or not rootPart then
        updateCharacter()
        return
    end
    
    if reverseMode then
        local moveDirection = humanoid.MoveDirection
        
        if moveDirection.Magnitude > 0.1 then
            -- Получаем угол движения и разворачиваем на 180°
            local targetAngle = math.atan2(moveDirection.X, moveDirection.Z)
            local reversedAngle = targetAngle + math.pi
            
            -- Применяем поворот
            rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, reversedAngle, 0)
            
            -- Сбрасываем скорость, если Evade её меняет
            if humanoid.WalkSpeed < 16 then
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

print("🎮 Evade Reverse Runner загружен! Нажми R для включения/выключения")
