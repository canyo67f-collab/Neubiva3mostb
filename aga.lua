-- Solara Script: Evade - Бег задом (постоянный режим, без сброса)

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
            humanoid.AutoRotate = false -- Отключаем авто-поворот навсегда
        end
    end
end

player.CharacterAdded:Connect(updateCharacter)
updateCharacter()

-- Постоянный режим бега задом
RunService.RenderStepped:Connect(function()
    if not character or not humanoid or not rootPart then
        updateCharacter()
        return
    end
    
    local moveDir = humanoid.MoveDirection
    
    if moveDir.Magnitude > 0.1 then
        -- Разворачиваем модель на 180° от направления движения
        local angle = math.atan2(moveDir.X, moveDir.Z)
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, angle + math.pi, 0)
    end
end)

print("✅ Режим 'бег задом' активирован навсегда!")
print("📌 Нажимай W/A/S/D - персонаж всегда бежит спиной вперёд, камера не двигается!!!!!!")
