-- Скрипт для отключения коллизии персонажа с другими игроками в Roblox (КЛИЕНТСКАЯ ВЕРСИЯ)
-- Вставьте в экзекьютор и выполните

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Переменные для отслеживания состояния
local isNoClipEnabled = false
local currentCharacter = nil

-- Функция для отключения коллизии (простой метод через CanCollide)
local function disableCollision()
    local character = LocalPlayer.Character
    if not character or not character.Parent then 
        warn("Персонаж не найден!")
        return false 
    end
    
    currentCharacter = character
    
    -- Проходим по всем частям тела и отключаем CanCollide
    local partsCount = 0
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Сохраняем оригинальное состояние если нужно (опционально)
            if part:GetAttribute("OriginalCanCollide") == nil then
                part:SetAttribute("OriginalCanCollide", part.CanCollide)
            end
            part.CanCollide = false
            partsCount = partsCount + 1
        end
    end
    
    isNoClipEnabled = true
    print("[✓] Коллизия отключена! Ты проходишь сквозь других игроков. (обработано частей: " .. partsCount .. ")")
    return true
end

-- Функция для включения коллизии обратно
local function enableCollision()
    if not currentCharacter or not currentCharacter.Parent then
        currentCharacter = LocalPlayer.Character
        if not currentCharacter then
            warn("Персонаж не найден!")
            return false
        end
    end
    
    local partsCount = 0
    for _, part in ipairs(currentCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            local originalValue = part:GetAttribute("OriginalCanCollide")
            if originalValue ~= nil then
                part.CanCollide = originalValue
            else
                part.CanCollide = true  -- Значение по умолчанию
            end
            partsCount = partsCount + 1
        end
    end
    
    isNoClipEnabled = false
    print("[✓] Коллизия восстановлена! (обработано частей: " .. partsCount .. ")")
    return true
end

-- Автоматическое применение при появлении персонажа (после смерти/респавна)
local function onCharacterAdded(character)
    -- Ждём, пока персонаж полностью загрузится
    task.wait(0.5)
    
    -- Если ноклип был включён, применяем к новому персонажу
    if isNoClipEnabled then
        task.wait(0.2) -- Небольшая дополнительная задержка
        disableCollision()
    else
        currentCharacter = character
    end
end

-- Обработчик изменения персонажа (для случаев, когда персонаж удаляется)
local function onCharacterRemoving(character)
    if character == currentCharacter then
        currentCharacter = nil
    end
end

-- Подписываемся на события
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)

-- Если персонаж уже существует, применяем
if LocalPlayer.Character then
    task.wait(0.5)
    disableCollision()
else
    -- Если персонажа ещё нет, ждём его появления
    LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
    disableCollision()
end

-- Глобальные функции для управления
_G.Noclip = {
    On = disableCollision,
    Off = enableCollision,
    Toggle = function()
        if isNoClipEnabled then
            enableCollision()
        else
            disableCollision()
        end
    end,
    IsEnabled = function() return isNoClipEnabled end
}

-- Удобные алиасы
_G.NoClipOn = disableCollision
_G.NoClipOff = enableCollision
_G.NoClipToggle = function()
    if isNoClipEnabled then enableCollision() else disableCollision() end
end

print("═══════════════════════════════════════════════════════")
print("  NOCLIP SCRIPT ACTIVATED (Client Version)")
print("═══════════════════════════════════════════════════════")
print("  Команды:")
print("    _G.NoClipOn()     - включить проход сквозь игроков")
print("    _G.NoClipOff()    - выключить проход сквозь игроков")
print("    _G.NoClipToggle() - переключить режим")
print("═══════════════════════════════════════════════════════")
