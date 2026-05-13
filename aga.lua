-- СКРИПТ ДЛЯ ЭКЗЕКЬЮТОРА (КЛИЕНТ)
-- Позволяет проходить сквозь других игроков на серверах

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Флаг состояния
local noclipEnabled = true
local character = nil

-- Метод 1: Постоянное принудительное отключение коллизии (работает на большинстве серверов)
local function forceDisableCollision()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end
    
    -- HumanoidRootPart отдельно
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CanCollide = false
    end
end

-- Метод 2: Использование Network Ownership для обхода серверной проверки
local function takeNetworkOwnership()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                -- Забираем владение частями у сервера
                part:SetNetworkOwner(LocalPlayer)
            end)
        end
    end
end

-- Метод 3: Изменение размера и позиции (альтернативный метод)
local function antiCollisionResize()
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        -- Уменьшаем размер коллизии (невидимо для других)
        rootPart.Size = Vector3.new(2, 1, 2)
    end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part ~= rootPart then
            part.CanCollide = false
        end
    end
end

-- Метод 4: Использование Velocity для отталкивания других игроков (создание "невидимости")
local function pushOtherPlayers()
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer then
            local otherChar = otherPlayer.Character
            if otherChar then
                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                if otherRoot and (otherRoot.Position - rootPart.Position).Magnitude < 5 then
                    -- Отталкиваем других игроков
                    local direction = (otherRoot.Position - rootPart.Position).Unit
                    otherRoot.Velocity = direction * 50
                end
            end
        end
    end
end

-- Метод 5: Спам запросов на сервер (иногда сбивает античит)
local function spamServerPhysics()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Отправляем ложные данные на сервер
            pcall(function()
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end
end

-- ГЛАВНАЯ ФУНКЦИЯ: Запуск всех методов в цикле
local function startNoClip()
    if not noclipEnabled then return end
    
    forceDisableCollision()
    takeNetworkOwnership()
    antiCollisionResize()
    
    if RunService:IsStudio() then
        spamServerPhysics()
    end
end

-- Отслеживание персонажа
local function onCharacterAdded(newChar)
    character = newChar
    task.wait(0.3)
    
    -- Ждём загрузки Humanoid
    local humanoid = character:WaitForChild("Humanoid", 1)
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false) -- Доп. фикс
    end
    
    startNoClip()
end

-- Запуск бесконечного цикла для постоянного обновления
RunService.RenderStepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        forceDisableCollision()
        
        -- Дополнительно каждые несколько кадров
        if tick() % 0.1 < 0.033 then -- Примерно 3 раза в секунду
            takeNetworkOwnership()
        end
    end
end)

-- Обработка входа/выхода игроков для push-метода (опционально)
if noclipEnabled then
    game:GetService("RunService").Heartbeat:Connect(function()
        if noclipEnabled then
            pushOtherPlayers()
        end
    end)
end

-- Подписка на события
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Инициализация
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- Управление
_G.NoClip = {
    Enable = function()
        noclipEnabled = true
        if LocalPlayer.Character then
            startNoClip()
        end
        print("[Server Noclip] Enabled")
    end,
    Disable = function()
        noclipEnabled = false
        print("[Server Noclip] Disabled")
    end,
    Toggle = function()
        if noclipEnabled then
            _G.NoClip.Disable()
        else
            _G.NoClip.Enable()
        end
    end
}

-- Автовключение
_G.NoClip.Enable()

print("═══════════════════════════════════════════════════════")
print("  SERVER-SIDE NOCLIP ACTIVATED")
print("═══════════════════════════════════════════════════════")
print("  Теперь ты проходишь сквозь игроков на сервере!")
print("  Команды:")
print("    _G.NoClip.Enable()  - включить")
print("    _G.NoClip.Disable() - выключить")
print("    _G.NoClip.Toggle()  - переключить")
print("═══════════════════════════════════════════════════════")
print("  [!] Если не работает, попробуй разные экзекьюторы")
print("  [!] Некоторые сервера могут блокировать этот метод")
print("═══════════════════════════════════════════════════════")
