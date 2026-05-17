-- Solara Script: Evade - Бег задом (работает в прыжке и на земле)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
            humanoid.AutoRotate = false
        end
    end
end

player.CharacterAdded:Connect(updateCharacter)
updateCharacter()

-- Постоянный бег задом (даже в воздухе)
RunService.Heartbeat:Connect(function() -- Heartbeat лучше чем RenderStepped для физики
    if not character or not humanoid or not rootPart then
        updateCharacter()
        return
    end
    
    local moveDir = humanoid.MoveDirection
    
    -- Проверяем, двигается ли персонаж (даже в воздухе)
    if moveDir.Magnitude > 0.1 then
        -- Получаем угол движения
        local angle = math.atan2(moveDir.X, moveDir.Z)
        -- Разворачиваем на 180 градусов
        local newAngle = angle + math.pi
        
        -- Применяем поворот (каждый кадр, чтобы игра не сбросила)
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, newAngle, 0)
    end
end)

print("✅ Режим 'бег задом' активен")
print("📌 Работает постоянно, даже при прыжках и приземлениях")
