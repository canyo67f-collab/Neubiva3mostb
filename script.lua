-- ФЛИНГ ДЛЯ SOLARA (РАБОЧАЯ ВЕРСИЯ)
local a = "ppOver910" -- 👈 СЮДА НИК

local b = game:GetService("Players")
local c = b.LocalPlayer

while wait(0.2) do
    local d = b:FindFirstChild(a)
    if d and d.Character then
        local e = d.Character:FindFirstChild("HumanoidRootPart")
        if e then
            e.Velocity = Vector3.new(math.random(-30000,30000), 50000, math.random(-30000,30000))
        end
    end
end
