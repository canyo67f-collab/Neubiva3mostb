-- Solara Script: Evade - Бег задом с переключением (без сброса)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = nil
local humanoid = nil
local rootPart = nil
local reverseMode = true -- По умолчанию включен

local function updateCharacter()
    character = player.Character
    if character then
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.AutoRotate = not reverseMode -- Включить/выключить авто-поворот
        end
    end
end

player.CharacterAdded:Connect(updateCharacter)
updateCharacter()

-- Переключение режима по R (не сбрасывается от других клавиш)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        reverseMode = not reverseMode
        if humanoid then
            humanoid.AutoRotate = not reverseMode
        end
        
        if reverseMode then
            print("✅ Режим бега задом ВКЛЮЧЁН")
        else
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
        local moveDir = humanoid.MoveDirection
        
        if moveDir.Magnitude > 0.1 then
            local angle = math.atan2(moveDir.X, moveDir.Z)
            rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, angle + math.pi, 0)
        end
    end
end)

print("🎮 Нажми R - включить/выключить режим бега задом")
print("📌 Режим НЕ сбрасывается при нажатии других клавиш")
