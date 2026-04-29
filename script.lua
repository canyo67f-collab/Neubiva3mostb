-- ФЛИНГ ДЛЯ SOLARA
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local TARGET = "ppOver910"  -- 👈 ВСТАВЬ НИК ИГРОКА

local FLING_POWER = 25000  -- Сила флинга

local function fling(plr)
    if not plr or not plr.Character then return end
    
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    local hum = plr.Character:FindFirstChild("Humanoid")
    
    if hrp and hum and hum.Health > 0 then
        hrp.AssemblyLinearVelocity = Vector3.new(
            math.random(-FLING_POWER, FLING_POWER),
            FLING_POWER,
            math.random(-FLING_POWER, FLING_POWER)
        )
    end
end

local target = Players:FindFirstChild(TARGET)
if not target then
    print("Игрок не найден! Доступные:")
    for _, v in ipairs(Players:GetPlayers()) do
        print(v.Name)
    end
    return
end

while true do
    target = Players:FindFirstChild(TARGET)
    if target then
        fling(target)
    end
    task.wait(0.3)
end
