local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local noclipOnPlayers = true
local character = nil

local function disablePlayerCollisionOnly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local physicsService = game:GetService("PhysicsService")

    local success, err = pcall(function()
        if not physicsService:GetCollisionGroupId("IgnorePlayers") then
            physicsService:CreateCollisionGroup("IgnorePlayers")
        end
        physicsService:CollisionGroupSetCollidable("IgnorePlayers", "Players", false)
        physicsService:CollisionGroupSetCollidable("Players", "IgnorePlayers", false)
        physicsService:CollisionGroupSetCollidable("IgnorePlayers", "Default", true)
    end)
    
    if success then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CollisionGroup = "IgnorePlayers"
            end
        end
        print("[✓] Проход сквозь игроков включён (через CollisionGroup)")
    else
        print("[!] PhysicsService недоступен, использую резервный метод...")
        useBackupMethod()
    end
end

local function useBackupMethod()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:GetAttribute("OriginalCollisionGroup") then
            part:SetAttribute("OriginalCollisionGroup", part.CollisionGroup)
        end
    end
    
    RunService.RenderStepped:Connect(function()
        if not noclipOnPlayers then return end
        
        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer then
                local otherChar = otherPlayer.Character
                if otherChar then
                    for _, ourPart in ipairs(currentChar:GetDescendants()) do
                        if ourPart:IsA("BasePart") then
                            for _, theirPart in ipairs(otherChar:GetDescendants()) do
                                if theirPart:IsA("BasePart") then
                                    pcall(function()
                                        ourPart.CanCollide = false
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

local function betterBackupMethod()
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local function handleNearbyPlayers()
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer then
                local otherChar = otherPlayer.Character
                if otherChar then
                    local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        local distance = (rootPart.Position - otherRoot.Position).Magnitude
                        if distance < 5 then 
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
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
    
    game:GetService("RunService").Heartbeat:Connect(function()
        if noclipOnPlayers then
            handleNearbyPlayers()
        end
    end)
end

local function enable()
    noclipOnPlayers = true
    if LocalPlayer.Character then
        disablePlayerCollisionOnly()
    end
end

local function disable()
    noclipOnPlayers = false
    local char = LocalPlayer.Character
    if char then
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
end

local function toggle()
    if noclipOnPlayers then
        disable()
    else
        enable()
    end
end

local function onCharacterAdded(newChar)
    character = newChar
    task.wait(0.5)
    if noclipOnPlayers then
        disablePlayerCollisionOnly()
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

_G.PlayerNoClip = {
    On = enable,
    Off = disable,
    Toggle = toggle
}

_G.PN_On = enable
_G.PN_Off = disable
_G.PN_Toggle = toggle

print("Проверка нахуй")
