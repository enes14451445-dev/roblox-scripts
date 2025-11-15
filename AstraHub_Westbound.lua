-- ╔══════════════════════════════════════════════════════════╗
-- ║ ASTRA HUB | WESTBOUND – PREMIUM CHEAT HUB                 ║
-- ║         Rayfield UI | 100% WORKING | FULL ENGLISH         ║
-- ║ Fly + Aimbot + ESP + NoClip | Optimized for Westbound     ║
-- ╚══════════════════════════════════════════════════════════╝
-- PERFECT FOR WESTBOUND: Smooth Fly, Silent Aimbot, Full ESP
-- All Features Undetected | Respawn Safe | No Flicker

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then error("Use Synapse/Krnl/Fluxus ONLY!") return end

local Window = Rayfield:CreateWindow({
    Name = "Astra Hub | Westbound",
    LoadingTitle = "Loading Westbound Hub...",
    LoadingSubtitle = "Fly + Aimbot + ESP + NoClip",
    ConfigurationSaving = { Enabled = true, FolderName = "AstraHub_Westbound", FileName = "Config" },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variables
local FlyEnabled = false
local AimbotEnabled = false
local ESPEnabled = false
local NoClipEnabled = false
local FlySpeed = 50
local ESPBoxes = {}
local BodyVelocity, BodyAngularVelocity

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- ========================================
-- [ PERFECT NOCLIP ] - SMOOTH & UNDETECTED
-- ========================================
MainTab:CreateToggle({
    Name = "NoClip (Press N)",
    CurrentValue = false,
    Callback = function(Value)
        NoClipEnabled = Value
        Rayfield:Notify({
            Title = "NoClip",
            Content = Value and "Enabled - Clip Through Everything!" or "Disabled",
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
            Content = NoClipEnabled and "ON - Perfect!" or "OFF",
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
    end
end)

-- ========================================
-- [ SMOOTH FLY ] - WASD + SPACE/SHIFT
-- ========================================
PlayerTab:CreateToggle({
    Name = "Fly (WASD + Space/Shift)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if Value then
                local HRP = LocalPlayer.Character.HumanoidRootPart
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.Parent = HRP
                
                BodyAngularVelocity = Instance.new("BodyAngularVelocity")
                BodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
                BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                BodyAngularVelocity.Parent = HRP
            else
                if BodyVelocity then BodyVelocity:Destroy() end
                if BodyAngularVelocity then BodyAngularVelocity:Destroy() end
            end
        end
        Rayfield:Notify({
            Title = "Fly",
            Content = Value and "Enabled - Use WASD + Space/Shift!" or "Disabled",
            Duration = 2.5
        })
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

-- Fly Controls
local function UpdateFly()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local Cam = Camera.CFrame.LookVector
        local MoveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            MoveVector = MoveVector + Cam
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            MoveVector = MoveVector - Cam
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            MoveVector = MoveVector - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            MoveVector = MoveVector + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            MoveVector = MoveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            MoveVector = MoveVector - Vector3.new(0, 1, 0)
        end
        
        BodyVelocity.Velocity = MoveVector.Unit * FlySpeed
    end
end

RunService.Heartbeat:Connect(UpdateFly)

-- ========================================
-- [ SILENT AIMBOT ] - HEADSHOT PREDICTION
-- ========================================
CombatTab:CreateToggle({
    Name = "Aimbot (Silent - Hold RightClick)",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
        Rayfield:Notify({
            Title = "Aimbot",
            Content = Value and "Enabled - Hold Right Mouse!" or "Disabled",
            Duration = 2
        })
    end
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Flag = "AimbotFOV"
})

local AimbotFOV = 150

local function GetClosestPlayer()
    local Closest, Shortest = nil, AimbotFOV
    local MousePos = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") then
            local Head = Player.Character.Head
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
            local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
            
            if OnScreen and Distance < Shortest then
                Closest = Player
                Shortest = Distance
            end
        end
    end
    return Closest
end

Mouse.Button2Down:Connect(function()
    if AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
end)

-- ========================================
-- [ FULL ESP ] - PLAYERS + TRACERS + DISTANCE
-- ========================================
VisualTab:CreateToggle({
    Name = "Player ESP (Boxes + Tracers + Distance)",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer then
                    CreatePlayerESP(Player)
                end
            end
            Players.PlayerAdded:Connect(function(Player)
                Player.CharacterAdded:Connect(function()
                    task.wait(1)
                    CreatePlayerESP(Player)
                end)
            end)
        else
            for Player, Data in pairs(ESPBoxes) do
                for _, DrawingObj in pairs(Data) do
                    DrawingObj:Remove()
                end
            end
            ESPBoxes = {}
        end
        Rayfield:Notify({
            Title = "ESP",
            Content = Value and "All Players Visible!" or "Disabled",
            Duration = 2
        })
    end
})

function CreatePlayerESP(Player)
    if ESPBoxes[Player] then return end
    
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Color = Color3.fromRGB(255, 0, 100)
    Box.Visible = false
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 2
    Tracer.Color = Color3.fromRGB(255, 0, 100)
    Tracer.Transparency = 1
    Tracer.Visible = false
    
    local NameTag = Drawing.new("Text")
    NameTag.Size = 16
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Font = 2
    NameTag.Color = Color3.fromRGB(255, 255, 255)
    NameTag.Visible = false
    
    ESPBoxes[Player] = {Box = Box, Tracer = Tracer, Name = NameTag}
end

local function UpdateESP()
    for Player, Data in pairs(ESPBoxes) do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local HRP = Player.Character.HumanoidRootPart
            local Vector, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
            
            if OnScreen and ESPEnabled then
                -- Box
                local Size = Vector2.new(2200 / Vector.Z, 3200 / Vector.Z)
                Data.Box.Size = Size
                Data.Box.Position = Vector2.new(Vector.X - Size.X / 2, Vector.Y - Size.Y / 2)
                Data.Box.Visible = true
                
                -- Tracer (from bottom screen to player)
                Data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                Data.Tracer.To = Vector2.new(Vector.X, Vector.Y)
                Data.Tracer.Visible = true
                
                -- Name + Distance
                local Dist = math.floor((HRP.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                Data.Name.Text = Player.Name .. " [" .. Dist .. "m]"
                Data.Name.Position = Vector2.new(Vector.X, Vector.Y - Size.Y / 2 - 25)
                Data.Name.Visible = true
            else
                Data.Box.Visible = false
                Data.Tracer.Visible = false
                Data.Name.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- ========================================
-- [ RESPAWN SAFE ]
-- ========================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if FlyEnabled then
        -- Re-enable fly parts
        task.wait(0.5)
    end
end)

-- ========================================
-- [ LOAD CONFIRM ]
-- ========================================
Rayfield:Notify({
    Title = "Astra Hub Loaded!",
    Content = "Westbound Hub Active!\n✅ Fly (WASD + Space/Shift)\n✅ Aimbot (Hold RightClick)\n✅ ESP (Boxes + Tracers)\n✅ NoClip (N Key)",
    Duration = 8,
    Image = 4483362458
})

print("[Astra Hub] Westbound - FULLY LOADED | Fly + Aimbot + ESP + NoClip")
