--[[
    Скрипт: Быстрое вращение персонажа
    Управление: Клавиша X (Вкл/Выкл)
--]]

-- Проверяем, существует ли сервис ввода (для Roblox)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Игрок и его персонаж
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Статус вращения (выкл)
local isSpinning = false

-- Скорость вращения (30 оборотов в секунду = 10800 градусов/сек)
local ROTATION_SPEED = 300 -- оборотов в секунду

-- Функция для остановки вращения (сбрасываем соединение с RunService)
local spinConnection = nil

local function stopSpin()
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    isSpinning = false
end

local function startSpin()
    -- Если уже крутимся, сначала остановим старый поток, чтобы не было 2х потоков сразу
    if spinConnection then stopSpin() end
    
    isSpinning = true
    
    -- Запускаем вращение через Heartbeat (привязано к частоте кадров)
    spinConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isSpinning then return end
        
        -- Проверяем, существует ли персонаж и его часть
        local currentChar = player.Character
        if not currentChar then return end
        
        local rootPart = currentChar:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Вычисляем угол поворота за этот кадр
        -- deltaTime - время между кадрами (обычно ~0.016 сек)
        local rotationAngle = ROTATION_SPEED * deltaTime * 360 -- в градусах
        local rotationRadians = math.rad(rotationAngle)
        
        -- Применяем вращение (ось Y - вертикальная, чтобы крутиться вокруг своей оси)
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, rotationRadians, 0)
    end)
end

-- Обработка нажатия клавиши X
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Игнорируем, если чат открыт или игра обрабатывает ввод
    if gameProcessed then return end
    
    -- Проверяем клавишу X
    if input.KeyCode == Enum.KeyCode.X then
        if isSpinning then
            stopSpin()
            print("Вращение ОСТАНОВЛЕНО")
        else
            startSpin()
            print("Вращение ЗАПУЩЕНО (Скорость: 30 об/сек)")
        end
    end
end)

-- Если персонаж умирает или пересоздается, сбрасываем вращение
player.CharacterAdded:Connect(function(newCharacter)
    stopSpin()
    isSpinning = false
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

print("Скрипт загружен! Нажми X, чтобы начать бешено крутиться.")
