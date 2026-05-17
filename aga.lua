-- Solara Script: Бег лицом назад (Backward Runner)
-- Работает в любых Roblox играх

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local isRunningBackwards = false
local originalWalkSpeed = 16

-- Функция для обновления персонажа (если он респавнится)
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
end)

-- Отслеживание нажатия клавиши W (код Enum.KeyCode.W)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        isRunningBackwards = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        isRunningBackwards = false
        -- Возвращаем нормальную скорость и снимаем принудительный поворот
        if humanoid then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end)

-- Основной цикл (каждый кадр)
RunService.RenderStepped:Connect(function()
    if not character or not humanoid then return end
    
    local isMoving = humanoid.MoveDirection.Magnitude > 0
    
    if isRunningBackwards and isMoving then
        -- Поворачиваем персонажа на 180 градусов
        local currentCFrame = character:GetPivot()
        local _, currentYaw = currentCFrame:ToOrientation()
        
        -- Получаем направление движения и разворачиваем
        local moveDirection = humanoid.MoveDirection
        local targetAngle = math.atan2(moveDirection.X, moveDirection.Z)
        
        character:SetPrimaryPartCFrame(CFrame.new(
            currentCFrame.Position,
            currentCFrame.Position + Vector3.new(math.sin(targetAngle), 0, math.cos(targetAngle))
        ) * CFrame.Angles(0, math.pi, 0))
        
        -- Устанавливаем скорость бега
        humanoid.WalkSpeed = originalWalkSpeed
    end
end)

print("✅ Скрипт загружен! Нажми W, чтобы бежать лицом назад")
