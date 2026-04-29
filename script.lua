-- ========================================
-- FLING + ТЕЛЕПОРТ + АВТОКЛИКЕР ДЛЯ SOLARA
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- ===== НАСТРОЙКИ =====
local TARGET_NAME = "ppOver910"  -- 👈 ИЗМЕНИ НА НИК ЦЕЛИ (кого флинговать)
local TELEPORT_TO_PLAYER = true      -- Телепортироваться к цели?
local FLING_POWER = 10000             -- Сила флинга (чем больше, тем дальше летит)
local FLING_INTERVAL = 0.5            -- Интервал флинга (сек)

-- ===== ФЛИНГ ФУНКЦИЯ =====
local function flingPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    
    if targetHRP and targetHumanoid and targetHumanoid.Health > 0 then
        -- Сохраняем старую скорость
        local oldVel = targetHRP.AssemblyLinearVelocity
        
        -- Создаём вектор скорости для полёта
        local flingVelocity = Vector3.new(
            math.random(-FLING_POWER, FLING_POWER),
            FLING_POWER * 0.8,
            math.random(-FLING_POWER, FLING_POWER)
        )
        
        -- Применяем скорость
        targetHRP.AssemblyLinearVelocity = flingVelocity
        
        -- Добавляем импульс для усиления
        targetHRP:ApplyImpulse(flingVelocity * 50)
        
        print("💥 Флинг на " .. targetPlayer.Name .. " с силой " .. FLING_POWER)
    end
end

-- ===== ТЕЛЕПОРТ К ЦЕЛИ =====
local function teleportToTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myChar = lp.Character
    
    if targetHRP and myChar and myChar:FindFirstChild("HumanoidRootPart") then
        myChar.HumanoidRootPart.CFrame = targetHRP.CFrame + Vector3.new(0, 2, 0)
    end
end

-- ===== АВТОКЛИКЕР (ЛКМ) =====
local function autoClick()
    UserInputService:SetMouseButtonState(Enum.UserInputType.MouseButton1, true)
    task.wait(0.02)
    UserInputService:SetMouseButtonState(Enum.UserInputType.MouseButton1, false)
end

-- ===== СПАМ КЛАВИШ 1-4 =====
local keysToSpam = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
local function spamKeys()
    for _, key in ipairs(keysToSpam) do
        UserInputService:SetKeyState(key, true)
        task.wait(0.03)
        UserInputService:SetKeyState(key, false)
        task.wait(0.03)
    end
end

-- ===== ПОЛУЧАЕМ ЦЕЛЬ =====
local target = Players:FindFirstChild(TARGET_NAME)
if not target then
    warn("❌ Игрок с ником '" .. TARGET_NAME .. "' не найден!")
    print("Доступные игроки:")
    for _, v in ipairs(Players:GetPlayers()) do
        print(" - " .. v.Name)
    end
    return
end

print("✅ Цель: " .. target.Name)
print("💪 Сила флинга: " .. FLING_POWER)
print("🔄 Интервал: " .. FLING_INTERVAL .. " сек")

-- ===== ОСНОВНОЙ ЛУП =====
spawn(function()
    while true do
        -- Обновляем цель на случай, если игрок перезашёл
        target = Players:FindFirstChild(TARGET_NAME)
        
        if target and target.Character then
            -- Флинг
            flingPlayer(target)
            
            -- Телепорт к цели (если включено)
            if TELEPORT_TO_PLAYER then
                teleportToTarget(target)
            end
        end
        
        task.wait(FLING_INTERVAL)
    end
end)

-- ===== АВТОКЛИКЕР ЛУП =====
spawn(function()
    while true do
        autoClick()
        task.wait(0.1) -- 10 кликов/сек
    end
end)

-- ===== СПАМ КЛАВИШ ЛУП =====
spawn(function()
    while true do
        spamKeys()
        task.wait(0.3) -- задержка между циклами спама
    end
end)

print("""
╔══════════════════════════════════╗
║     ✅ СКРИПТ ЗАПУЩЕН ✅         ║
╠══════════════════════════════════╣
║  💥 Fling активен                ║
║  🎯 Телепорт к цели: включен     ║
║  🖱️ Автокликер ЛКМ: активен      ║
║  🔢 Спам 1-4: активен            ║
╚══════════════════════════════════╝
""")
