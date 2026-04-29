-- loadstring(game:HttpGet("https://pastebin.com/raw/..."))() -- можно захостить

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ
local TELEPORT_TARGET = "NicknameHere"  -- 👈 СЮДА ВСТАВЬ НИК ИГРОКА
local CLICK_SPAM_DELAY = 0.1  -- задержка между кликами (0.1 сек = 10 кликов/сек)
local TELEPORT_DELAY = 0       -- без задержки (мгновенно)

-- Функция телепортации к игроку
local function TeleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end

-- Эмуляция клика левой кнопки мыши
local function ClickMouse()
    VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, false, Vector2.new(0, 0), 0)
    task.wait(0.02)
    VirtualInput:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, false, Vector2.new(0, 0), 0)
end

-- Эмуляция нажатия клавиши 1-4
local function PressKey(key)
    local keyCode = nil
    if key == 1 then keyCode = Enum.KeyCode.One
    elseif key == 2 then keyCode = Enum.KeyCode.Two
    elseif key == 3 then keyCode = Enum.KeyCode.Three
    elseif key == 4 then keyCode = Enum.KeyCode.Four
    else return end
    
    VirtualInput:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInput:SendKeyEvent(false, keyCode, false, game)
end

-- Телепорт-луп (без кд)
spawn(function()
    while true do
        TeleportToPlayer(TELEPORT_TARGET)
        if TELEPORT_DELAY > 0 then
            task.wait(TELEPORT_DELAY)
        else
            task.wait() -- минимальная задержка, чтобы не крашить
        end
    end
end)

-- Спам кликами мыши + клавишами 1-4 (примерно 1 цикл в секунду)
spawn(function()
    local keys = {1, 2, 3, 4}
    local lastTime = tick()
    
    while true do
        -- Клик мышью
        ClickMouse()
        
        -- Нажимаем клавиши 1-4 быстрой очередью
        for _, k in ipairs(keys) do
            PressKey(k)
            task.wait(0.03)
        end
        
        -- Задержка ~1 секунда (настраивается через CLICK_SPAM_DELAY)
        local elapsed = tick() - lastTime
        local waitTime = CLICK_SPAM_DELAY - elapsed
        if waitTime > 0 then
            task.wait(waitTime)
        end
        lastTime = tick()
    end
end)

print("✅ Скрипт запущен | Телепорт к: " .. TELEPORT_TARGET .. " | Задержка кликов: " .. CLICK_SPAM_DELAY .. "с")
