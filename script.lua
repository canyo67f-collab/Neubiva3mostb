--[[
    Скрипт: Вращение персонажа (работает с Shift Lock + не мешает движению)
    Управление: Клавиша X (Вкл/Выкл)
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local isSpinning = true
local ROTATION_SPEED = 5 -- оборотов в секунду
local spinConnection = nil

-- Сохраняем исходный CFrame камеры и тела
local originalCameraCF = nil

local function stopSpin()
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    isSpinning = false
end

local function startSpin()
    if spinConnection then stopSpin() end
    isSpinning = true
    
    spinConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isSpinning then return end
        
        local character = player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not rootPart or not humanoid then return end
        
        -- Получаем текущее движение (WASD)
        local moveDirection = humanoid.MoveDirection
        local isMoving = moveDirection.Magnitude > 0.01
        
        -- Сохраняем текущую позицию
        local currentPosition = rootPart.Position
        
        -- Вычисляем угол поворота
        local rotationAngle = ROTATION_SPEED * deltaTime * 360
        local rotationRadians = math.rad(rotationAngle)
        
        -- Получаем текущий CFrame камеры для сохранения направления движения
        local cameraCF = camera.CFrame
        
        -- Вращаем корневую часть (HumanoidRootPart)
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, rotationRadians, 0)
        
        -- ВАЖНО: Сохраняем позицию, чтобы персонаж не улетал
        
        -- КОСТЫЛЬ ДЛЯ SHIFT LOCK:
        -- Принудительно обновляем направление камеры, но не даём ей сбивать вращение тела
        if isMoving then
            -- Получаем направление движения относительно камеры (как в обычной игре)
            local cameraForward = cameraCF.LookVector
            local cameraRight = cameraCF.RightVector
            
            -- Нормализуем направление движения от WASD
            local moveX = moveDirection.X
            local moveZ = moveDirection.Z
            
            -- Вычисляем новое направление движения в мировых координатах
            local worldDirection = (cameraForward * moveZ) + (cameraRight * moveX)
            worldDirection = Vector3.new(worldDirection.X, 0, worldDirection.Z).Unit
            
            if worldDirection.Magnitude > 0.01 then
                -- Поворачиваем персонажа в сторону движения (как в обычной игре)
                local targetAngle = math.atan2(worldDirection.X, worldDirection.Z)
                local currentAngle = rootPart.Orientation.Y
                
                -- Плавный поворот (опционально, можно убрать для резкого)
                -- rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, targetAngle, 0)
                
                -- Для более плавного поворота при движении:
                local newAngle = currentAngle + (rotationRadians * 180 / math.pi)
                rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(newAngle), 0)
            end
        end
        
        -- Обновляем HumanoidRootPart позицию (фикс для джиттера)
        rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
        rootPart.RotVelocity = Vector3.new(0, 0, 0)
    end)
end

-- Обработка нажатия X
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        if isSpinning then
            stopSpin()
            print("Вращение ОСТАНОВЛЕНО")
        else
            startSpin()
            print("Вращение ЗАПУЩЕНО (Скорость: " .. ROTATION_SPEED .. " об/сек)")
            print("Shift Lock не мешает, движение работает нормально")
        end
    end
end)

-- Пересоздание персонажа
player.CharacterAdded:Connect(function(newCharacter)
    stopSpin()
    isSpinning = false
end)

print("✅ Скрипт загружен! Нажми X для вращения (работает с Shift Lock)")
