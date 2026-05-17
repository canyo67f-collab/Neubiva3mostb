-- Solara Script: Evade - Бег спиной вперёд (камера не трогается)
-- Нажимаешь W - персонаж бежит вперёд, но развёрнут лицом к тебе

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = nil
local humanoid = nil
local rootPart = nil

-- Обновление персонажа
local function updateCharacter()
    character = player.Character
    if character then
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.AutoRotate = false -- Отключаем авто-поворот
        end
    end
end

player.CharacterAdded:Connect(updateCharacter)
updateCharacter()

local reverseMode = true -- Режим бега задом (поставь false чтобы выключить)

-- Запоминаем направление движения
local moveDirection = Vector3.zero

-- Получаем направление от клавиш
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        moveDirection = Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirection = Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirection = Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirection = Vector3.new(1, 0, 0)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W or 
       input.KeyCode == Enum.KeyCode.S or 
       input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.D then
        moveDirection = Vector3.zero
    end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
    if not character or not humanoid or not rootPart then
        updateCharacter()
        return
    end
    
    if reverseMode and moveDirection.Magnitude > 0 then
        -- Получаем направление камеры
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        
        -- Поворачиваем направление движения относительно камеры
        local forwardDirection = cameraCFrame.LookVector
        local rightDirection = cameraCFrame.RightVector
        
        local moveDir = (forwardDirection * -moveDirection.Z) + (rightDirection * moveDirection.X)
        moveDir = moveDir.Unit
        
        -- Двигаем персонажа в этом направлении
        humanoid:Move(moveDir, true)
        
        -- Разворачиваем модель строго против движения (спиной вперёд)
        local targetAngle = math.atan2(moveDir.X, moveDir.Z)
        local reversedAngle = targetAngle + math.pi -- +180 градусов
        
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, reversedAngle, 0)
        
        -- Скорость бега
        humanoid.WalkSpeed = 20
    else
        -- Обычный режим
        humanoid.AutoRotate = true
    end
end)

print("🎮 Режим активен! Персонаж бежит спиной вперёд, камера не поворачивается")
print("📌 W/A/S/D работают как обычно, но модель развёрнута к тебе лицом")
