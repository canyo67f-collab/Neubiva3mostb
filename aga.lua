-- Скрипт для отключения коллизии персонажа с другими игроками в Roblox
-- Вставьте в экзекьютор и выполните

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция для отключения коллизии
local function disableCollision()
    local character = LocalPlayer.Character
    if not character or not character.Parent then return end
    
    -- Получаем HumanoidRootPart игрока
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Изменяем CanCollide и другие свойства для прохода сквозь игроков
    rootPart.CanCollide = false
    
    -- Проходим по всем частям тела
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            -- Дополнительно отключаем масс-коллизию с другими игроками
            part.CollisionGroup = "Debris"
        end
    end
    
    -- Настройка CollisionGroup для прохода сквозь игроков
    -- Проверяем существует ли группа, если нет - создаём
    local success, collisionGroup = pcall(function()
        return game:GetService("PhysicsService"):GetCollisionGroupId("NoPlayerCollision") 
    end)
    
    if not success then
        game:GetService("PhysicsService"):CreateCollisionGroup("NoPlayerCollision")
    end
    
    -- Устанавливаем, что группа NoPlayerCollision не сталкивается с группой Players
    local physicsService = game:GetService("PhysicsService")
    pcall(function()
        physicsService:CollisionGroupSetCollidable("NoPlayerCollision", "Players", false)
        physicsService:CollisionGroupSetCollidable("Players", "NoPlayerCollision", false)
    end)
    
    -- Применяем группу ко всем частям персонажа
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CollisionGroup = "NoPlayerCollision"
        end
    end
    
    print("Коллизия отключена! Ты можешь проходить сквозь других игроков.")
end

-- Функция для включения обратно (опционально)
local function enableCollision()
    local character = LocalPlayer.Character
    if not character or not character.Parent then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            part.CollisionGroup = "Players"
        end
    end
    
    print("Коллизия восстановлена.")
end

-- Следим за пересозданием персонажа (при смерти и т.д.)
local function onCharacterAdded(character)
    -- Небольшая задержка для корректной загрузки персонажа
    task.wait(0.5)
    disableCollision()
end

-- Если персонаж уже существует, применяем сразу
if LocalPlayer.Character then
    disableCollision()
end

-- Подписываемся на событие появления нового персонажа
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

print("Скрипт активирован! Персонаж проходит сквозь других игроков.")
print("Для восстановления коллизии используйте команду: enableCollision()")

-- Глобальные функции для управления из консоли экзекьютора
_G.DisableNoClip = enableCollision
_G.EnableNoClip = disableCollision
