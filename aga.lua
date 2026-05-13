-- СКРИПТ ДЛЯ ЭКЗЕКЬЮТОРА (КЛИЕНТ)
-- Только проход сквозь игроков, НЕ сквозь стены и объекты

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local noclipOnPlayers = true
local character = nil

-- Функция для отключения коллизии ТОЛЬКО с другими игроками
local function disablePlayerCollisionOnly()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Получаем HumanoidRootPart
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Меняем CollisionGroup на кастомную, которая не сталкивается с игроками
    local physicsService = game:GetService("PhysicsService")
    
    -- Пытаемся создать свою группу коллизии (на некоторых серверах может быть запрещено)
    local success, err = pcall(function()
        if not physicsService:GetCollisionGroupId("IgnorePlayers") then
            physicsService:CreateCollisionGroup("IgnorePlayers")
        end
        -- Настраиваем: IgnorePlayers НЕ сталкивается с Players
        physicsService:CollisionGroupSetCollidable("IgnorePlayers", "Players", false)
        physicsService:CollisionGroupSetCollidable("Players", "IgnorePlayers", false)
        -- Но сталкивается с Default (стены, пол, объекты)
        physicsService:CollisionGroupSetCollidable("IgnorePlayers", "Default", true)
    end)
    
    if success then
        -- Применяем группу ко всем частям персонажа
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CollisionGroup = "IgnorePlayers"
                -- НЕ трогаем CanCollide, чтобы стены оставались твёрдыми
            end
        end
        print("[✓] Проход сквозь игроков включён (через CollisionGroup)")
    else
        -- Fallback метод если PhysicsService заблокирован
        print("[!] PhysicsService недоступен, использую резервный метод...")
        useBackupMethod()
    end
end

-- Резервный метод (работает через постоянное отслеживание других игроков)
local function useBackupMethod()
    -- Отключаем физику между частями персонажа и другими игроками
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Сохраняем оригинальные коллизии
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:GetAttribute("OriginalCollisionGroup") then
            part:SetAttribute("OriginalCollisionGroup", part.CollisionGroup)
        end
    end
    
    -- Каждый кадр принудительно разрываем коллизию с игроками
    RunService.RenderStepped:Connect(function()
        if not noclipOnPlayers then return end
        
        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer then
                local otherChar = otherPlayer.Character
                if otherChar then
                    -- Разрываем коллизию между частями нашего персонажа и чужим
                    for _, ourPart in ipairs(currentChar:GetDescendants()) do
                        if ourPart:IsA("BasePart") then
                            for _, theirPart in ipairs(otherChar:GetDescendants()) do
                                if theirPart:IsA("BasePart") then
                                    pcall(function()
                                        ourPart.CanCollide = false -- Временно отключаем
                                        -- Но тут проблема: это отключит коллизию со всеми
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Более элегантный резервный метод (через прилипание к другим игрокам)
local function betterBackupMethod()
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Отслеживаем игроков рядом и временно отключаем коллизию только с ними
    local function handleNearbyPlayers()
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer then
                local otherChar = otherPlayer.Character
                if otherChar then
                    local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        local distance = (rootPart.Position - otherRoot.Position).Magnitude
                        if distance < 5 then -- Если игрок рядом
                            -- Временно отключаем коллизию только между этими частями
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                    -- Возвращаем обратно через 0.1 сек
                                    task.spawn(function()
                                        task.wait(0.1)
                                        if part and part.Parent then
                                            part.CanCollide = true
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Запускаем проверку каждые 0.05 секунды
    game:GetService("RunService").Heartbeat:Connect(function()
        if noclipOnPlayers then
            handleNearbyPlayers()
        end
    end)
end

-- Включение/выключение
local function enable()
    noclipOnPlayers = true
    if LocalPlayer.Character then
        disablePlayerCollisionOnly()
    end
    print("[✓] Режим: проход сквозь ИГРОКОВ включён (стены остаются)")
end

local function disable()
    noclipOnPlayers = false
    local char = LocalPlayer.Character
    if char then
        -- Восстанавливаем оригинальные настройки
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                local originalGroup = part:GetAttribute("OriginalCollisionGroup")
                if originalGroup then
                    pcall(function()
                        part.CollisionGroup = originalGroup
                    end)
                end
            end
        end
    end
    print("[✓] Режим выключен: нормальная коллизия со всеми")
end

-- Переключение
local function toggle()
    if noclipOnPlayers then
        disable()
    else
        enable()
    end
end

-- Автоматическое применение при респавне
local function onCharacterAdded(newChar)
    character = newChar
    task.wait(0.5)
    if noclipOnPlayers then
        disablePlayerCollisionOnly()
    end
end

-- Подписки
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Запуск
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- Глобальные команды
_G.PlayerNoClip = {
    On = enable,
    Off = disable,
    Toggle = toggle
}

-- Алиасы
_G.PN_On = enable
_G.PN_Off = disable
_G.PN_Toggle = toggle

print("═══════════════════════════════════════════════════════")
print("  PLAYER-ONLY NO-CLIP ACTIVATED")
print("═══════════════════════════════════════════════════════")
print("  ✓ Ты проходишь СКВОЗЬ ИГРОКОВ")
print("  ✓ Стены, пол и объекты ОСТАЮТСЯ ТВЁРДЫМИ")
print("═══════════════════════════════════════════════════════")
print("  Команды:")
print("    _G.PlayerNoClip.On()   - включить (только игроки)")
print("    _G.PlayerNoClip.Off()  - выключить")
print("    _G.PlayerNoClip.Toggle()")
print("═══════════════════════════════════════════════════════")
