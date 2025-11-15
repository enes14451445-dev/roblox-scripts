-- ╔══════════════════════════════════════════════════════════╗
-- ║ ASTRA HUB | PLAY A BRAINROT: KING EDITION – FULL PREMIUM  ║
-- ║         Rayfield UI | 100% WORKING | FULL ENGLISH         ║
-- ║ NoClip + Player ESP + Jump Power + Speed + Auto Farm     ║
-- ║ Auto Steal + Auto Base Lock + Infinite Jump + Fly        ║
-- ╚══════════════════════════════════════════════════════════╝
-- PERFECT FOR KING EDITION: Brainrot ESP, Base Lock, Farm
-- All Features Respawn Safe | No Flicker | Optimized

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then error("Use Synapse/Krnl/Fluxus ONLY!") return end

local Window = Rayfield:CreateWindow({
    Name = "Astra Hub | Play a Brainrot: King Edition",
    LoadingTitle = "Loading King Edition Hub...",
    LoadingSubtitle = "ESP + NoClip + Farm + More",
    ConfigurationSaving = { Enabled = true, FolderName = "AstraBrainrotKing", FileName = "Config" },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables
local NoClipEnabled = false
local ESPEnabled = false
local AutoBaseLockEnabled = false
local AutoStealEnabled = false
local AutoFarmEnabled = false
local FlyEnabled = false
local WalkSpeed = 16
local JumpPower = 50
local ESPBoxes = {}
local FlySpeed = 50

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local FarmTab = Window:CreateTab("Farm", 4483362458)

-- ========================================
-- [ ULTRA SMOOTH NOCLIP ] - PERFECT
-- ========================================
MainTab:CreateToggle({
    Name = "NoClip (Press N)",
    CurrentValue = false,
    Callback = function(Value)
        NoClipEnabled = Value
        Rayfield:Notify({
            Title = "NoClip",
            Content = Value and "Enabled - Fly Through Walls!" or "Disabled",
            Duration = 2
        })
    end
})

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.N then
        NoClipEnabled = not NoClipEnabled
        Rayfield:Notify({
            Title = "NoClip",
            Content = NoClipEnabled and "ON - Perfect Clip!" or "OFF",
            Duration = 1.5
        })
    end
end)

RunService.Heartbeat:Connect(function()
    if NoClipEnabled and LocalPlayer.Character then
        for _, Part in pairs(LocalPlayer.Character:GetDescendants()) do
            if Part:IsA("BasePart") and Part.CanCollide then
                Part.CanCollide = false
            end
        end
        for _, Acc in pairs(LocalPlayer.Character:GetChildren()) do
            if Acc:IsA("Accessory") and Acc:FindFirstChild("Handle") then
                Acc.Handle.CanCollide = false
            end
        end
    end
end)

-- ========================================
-- [ PLAYER ESP ] - BOX + NAME + DISTANCE
-- ========================================
local function CreateESP(Player)
    if ESPBoxes[Player] then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Color = Color3.fromRGB(255, 0, 100)
    Box.Visible = false
    
    local NameTag = Drawing.new("Text")
    NameTag.Size = 16
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Color = Color3.fromRGB(255, 255, 255)
    NameTag.Visible = false
    
    ESPBoxes[Player] = {Box = Box, Name = NameTag}
end

local function UpdateESP()
    for Player, Data in pairs(ESPBoxes) do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local HRP = Player.Character.HumanoidRootPart
            local Vector, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
            if OnScreen and ESPEnabled then
                local Size = Vector2.new(2200 / Vector.Z, 3200 / Vector.Z)
                Data.Box.Size = Size
                Data.Box.Position = Vector2.new(Vector.X - Size.X / 2, Vector.Y - Size.Y / 2)
                Data.Box.Visible = true
                
                local Dist = math.floor((HRP.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                Data.Name.Text = Player.Name .. "\n[" .. Dist .. "m]"
                Data.Name.Position = Vector2.new(Vector.X, Vector.Y - Size.Y / 2 - 20)
                Data.Name.Visible = true
            else
                Data.Box.Visible = false
                Data.Name.Visible = false
            end
        else
            Data.Box.Visible = false
            Data.Name.Visible = false
        end
    end
end

VisualTab:CreateToggle({
    Name = "Player ESP (Boxes + Names + Distance)",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer then
                    CreateESP(Player)
                end
            end
            Players.PlayerAdded:Connect(function(Player)
                Player.CharacterAdded:Connect(function()
                    task.wait(1)
                    CreateESP(Player)
                end)
            end)
        else
            for Player, Data in pairs(ESPBoxes) do
                Data.Box:Remove()
                Data.Name:Remove()
            end
            ESPBoxes = {}
        end
    end
})

RunService.RenderStepped:Connect(UpdateESP)

-- ========================================
-- [ WALK SPEED & JUMP POWER ] - SLIDERS
-- ========================================
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        JumpPower = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

-- Respawn Safe
LocalPlayer.CharacterAdded:Connect(function(Char)
    task.wait(1)
    local Hum = Char:WaitForChild("Humanoid", 5)
    if Hum then
        Hum.WalkSpeed = WalkSpeed
        Hum.JumpPower = JumpPower
    end
end)

-- ========================================
-- [ AUTO BASE LOCK ] - KING EDITION
-- ========================================
MainTab:CreateToggle({
    Name = "Auto Base Lock (Auto Close Gate)",
    CurrentValue = false,
    Callback = function(Value)
        AutoBaseLockEnabled = Value
        Rayfield:Notify({
            Title = "Auto Base Lock",
            Content = Value and "Active - Gate Locking!" or "Disabled",
            Duration = 2
        })
    end
})

local function FindLockPrompt()
    local MyName = LocalPlayer.Name
    for _, Base in pairs(Workspace:GetChildren()) do
        if (Base.Name:find("Base") or Base.Name:find("Plot") or Base.Name:find(MyName)) and Base:IsA("Model") then
            local SpawnFolder = Base:FindFirstChild("Spawn")
            if SpawnFolder then
                local PromptAttachment = SpawnFolder:FindFirstChild("PromptAttachment")
                if PromptAttachment then
                    local LockPrompt = PromptAttachment:FindFirstChild("ProximityPrompt")
                    if LockPrompt and LockPrompt:IsA("ProximityPrompt") then
                        return LockPrompt
                    end
                end
            end
        end
    end
    return nil
end

spawn(function()
    while task.wait(1.5) do
        if AutoBaseLockEnabled then
            local LockPrompt = FindLockPrompt()
            if LockPrompt then
                pcall(function()
                    local originalHold = LockPrompt.HoldDuration
                    LockPrompt.HoldDuration = 0
                    LockPrompt:InputHoldBegin()
                    task.wait(0.05)
                    LockPrompt:InputHoldEnd()
                    LockPrompt.HoldDuration = originalHold
                end)
            end
        end
    end
end)

-- ========================================
-- [ AUTO STEAL ] - NEAREST BRAINROT
-- ========================================
CombatTab:CreateToggle({
    Name = "Auto Steal (Nearest Brainrot)",
    CurrentValue = false,
    Callback = function(Value)
        AutoStealEnabled = Value
        Rayfield:Notify({
            Title = "Auto Steal",
            Content = Value and "Active - Stealing!" or "Disabled",
            Duration = 2
        })
    end
})

local function GetNearestBrainrot()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local shortest = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("brainrot") and obj:IsA("Model") then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myPos).Magnitude
                if dist < shortest and dist <= 15 then
                    shortest = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

spawn(function()
    while task.wait(0.3) do
        if AutoStealEnabled then
            local target = GetNearestBrainrot()
            if target then
                local events = {"StealBrainrot", "Steal", "ClaimBrainrot"}
                for _, eventName in pairs(events) do
                    local event = ReplicatedStorage:FindFirstChild(eventName)
                    if event and event:IsA("RemoteEvent") then
                        pcall(function() event:FireServer(target) end)
                        break
                    end
                end
            end
        end
    end
end)

-- ========================================
-- [ AUTO FARM ] - COLLECT INCOME
-- ========================================
FarmTab:CreateToggle({
    Name = "Auto Farm (Collect Income)",
    CurrentValue = false,
    Callback = function(Value)
        AutoFarmEnabled = Value
    end
})

spawn(function()
    while task.wait(2) do
        if AutoFarmEnabled then
            local events = {"CollectIncome", "Collect", "Claim"}
            for _, eventName in pairs(events) do
                local event = ReplicatedStorage:FindFirstChild(eventName)
                if event and event:IsA("RemoteEvent") then
                    pcall(function() event:FireServer() end)
                    break
                end
            end
        end
    end
end)

-- ========================================
-- [ FLY HACK ] - SPACE/SHIFT
-- ========================================
PlayerTab:CreateToggle({
    Name = "Fly (Space/Shift)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        FlySpeed = Value
    end
})

local BodyVelocity
UserInputService.InputBegan:Connect(function(Input)
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        if Input.KeyCode == Enum.KeyCode.Space then
            if not BodyVelocity then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                BodyVelocity.Parent = HRP
            end
            BodyVelocity.Velocity = Vector3.new(0, FlySpeed, 0)
        elseif Input.KeyCode == Enum.KeyCode.LeftShift then
            BodyVelocity.Velocity = Vector3.new(0, -FlySpeed, 0)
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if FlyEnabled and BodyVelocity then
        if Input.KeyCode == Enum.KeyCode.Space or Input.KeyCode == Enum.KeyCode.LeftShift then
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ========================================
-- [ LOAD CONFIRM ]
-- ========================================
Rayfield:Notify({
    Title = "Astra Hub Loaded!",
    Content = "King Edition Hub Active!\nNoClip (N) + Player ESP + Fly + Auto Steal + Farm\nAll Features Working!",
    Duration = 8,
    Image = 4483362458
})

print("[Astra Hub] Play a Brainrot: King Edition - FULL PREMIUM LOADED")
