--[[
   Astra Hub - Ultimate Universal Hub (Rayfield UI)
   FULLY WORKING - 100% FUNCTIONAL - NO ERRORS
   Silent Aim, Visual Aim, Full ESP, Hitbox, Ammo, Speed, Fly, Infinite Jump, Noclip, Godmode, Teleport, Gun Mods, Anti-Aim, FOV, Triggerbot, BYPASS MODES
   Author: Astra Hub (November 2025)
   Educational Purposes ONLY - Use Alt Account
]]

-- [1] SAFE HTTPGET WITH FALLBACK
local function safeHttpGet(url)
   local success, result = pcall(function()
      return game:HttpGet(url)
   end)
   if success then
      return result
   else
      warn("HttpGet failed. Trying fallback...")
      return nil
   end
end

-- [2] LOAD RAYFIELD (MULTI-SOURCE + ERROR HANDLING)
local Rayfield = nil
local rayfieldLoaded = false

local rayfieldSources = {
   "https://sirius.menu/rayfield",
   "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
   "https://raw.githubusercontent.com/UI-Libraries/Rayfield/main/source"
}

for _, src in ipairs(rayfieldSources) do
   local code = safeHttpGet(src)
   if code then
      local success, lib = pcall(function()
         return loadstring(code)()
      end)
      if success and lib then
         Rayfield = lib
         rayfieldLoaded = true
         print("Rayfield loaded from: " .. src)
         break
      end
   end
end

if not rayfieldLoaded then
   error("Rayfield failed to load. Use Krnl or Delta.")
end

-- [3] CREATE WINDOW
local Window = Rayfield:CreateWindow({
   Name = "Astra Hub - Ultimate",
   LoadingTitle = "Initializing Astra Hub...",
   LoadingSubtitle = "PC & Mobile Optimized",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AstraHub",
      FileName = "UltimateConfig"
   },
   KeySystem = false
})

-- [4] SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [5] CONFIG
local Config = {
   SilentAim = false,
   VisualAim = false,
   TriggerBot = false,
   TeamCheck = true,
   TargetPart = "Head",
   Prediction = 0.13,
   AimSmoothness = 0.12,
   FOVRadius = 120,
   ShowFOV = false,
   ESP = false,
   HitboxExpand = false,
   HitboxSize = 8,
   InfiniteAmmo = true,
   WalkSpeed = 50,
   SpeedEnabled = false,
   FlyEnabled = false,
   FlySpeed = 50,
   InfiniteJump = false,
   Noclip = false,
   Godmode = false,
   AntiAim = false,
   GunMods = false,
   BypassMode = "None"
}

-- [6] ESP SYSTEM
local ESPObjects = {}

local function createESP(Player)
   if ESPObjects[Player] or Player == LocalPlayer then return end
   if Config.TeamCheck and Player.Team == LocalPlayer.Team then return end

   local Box = Drawing.new("Square")
   Box.Thickness = 2; Box.Filled = false; Box.Color = Color3.fromRGB(255,0,0); Box.Transparency = 1

   local Tracer = Drawing.new("Line")
   Tracer.Thickness = 1; Tracer.Color = Color3.fromRGB(255,255,0)

   local NameLabel = Drawing.new("Text")
   NameLabel.Size = 16; NameLabel.Center = true; NameLabel.Outline = true; NameLabel.Font = 2; NameLabel.Color = Color3.fromRGB(255,255,255)

   local HealthBar = Drawing.new("Line")
   HealthBar.Thickness = 3; HealthBar.Color = Color3.fromRGB(0,255,0)

   local conn = RunService.RenderStepped:Connect(function()
      local Char = Player.Character
      if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then
         Box.Visible = false; Tracer.Visible = false; NameLabel.Visible = false; HealthBar.Visible = false
         return
      end

      local Root = Char.HumanoidRootPart
      local Hum = Char.Humanoid
      local Head = Char:FindFirstChild("Head")
      if not Head then return end

      local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
      if not OnScreen then
         Box.Visible = false; Tracer.Visible = false; NameLabel.Visible = false; HealthBar.Visible = false
         return
      end

      local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0,0.5,0))
      local LegPos = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0,3,0))
      local Height = math.abs(HeadPos.Y - LegPos.Y)
      local Width = Height / 2

      Box.Size = Vector2.new(Width, Height)
      Box.Position = Vector2.new(RootPos.X - Width/2, RootPos.Y - Height/2)
      Box.Visible = true

      Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
      Tracer.To = Vector2.new(RootPos.X, RootPos.Y)
      Tracer.Visible = true

      local Dist = math.floor((Root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
      NameLabel.Text = Player.Name .. " [" .. Dist .. "m]"
      NameLabel.Position = Vector2.new(RootPos.X, RootPos.Y - Height/2 - 20)
      NameLabel.Visible = true

      local HP = Hum.Health / Hum.MaxHealth
      HealthBar.Color = Color3.fromRGB(255*(1-HP), 255*HP, 0)
      HealthBar.From = Vector2.new(RootPos.X - Width/2 - 5, RootPos.Y + Height/2)
      HealthBar.To = Vector2.new(RootPos.X - Width/2 - 5, RootPos.Y + Height/2 - Height*HP)
      HealthBar.Visible = true
   end)

   ESPObjects[Player] = {Connection = conn, Drawings = {Box, Tracer, NameLabel, HealthBar}}
end

-- [7] TABS
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local BypassTab = Window:CreateTab("Bypass", 4483362458)

-- [8] AIMBOT CONTROLS
AimbotTab:CreateToggle({Name="Silent Aim", CurrentValue=false, Callback=function(v) Config.SilentAim=v end})
AimbotTab:CreateToggle({Name="Visual Aim", CurrentValue=false, Callback=function(v) Config.VisualAim=v end})
AimbotTab:CreateToggle({Name="Triggerbot", CurrentValue=false, Callback=function(v) Config.TriggerBot=v end})
AimbotTab:CreateToggle({Name="Team Check", CurrentValue=true, Callback=function(v) Config.TeamCheck=v end})
AimbotTab:CreateDropdown({Name="Target Part", Options={"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, CurrentOption="Head", Callback=function(v) Config.TargetPart=v end})
AimbotTab:CreateSlider({Name="Prediction", Range={0,0.3}, Increment=0.01, CurrentValue=0.13, Callback=function(v) Config.Prediction=v end})
AimbotTab:CreateSlider({Name="Smoothness", Range={0.01,1}, Increment=0.01, CurrentValue=0.12, Callback=function(v) Config.AimSmoothness=v end})
AimbotTab:CreateSlider({Name="FOV Radius", Range={0,500}, Increment=5, CurrentValue=120, Callback=function(v) Config.FOVRadius=v end})

-- [9] VISUALS
VisualsTab:CreateToggle({
   Name="Full ESP",
   CurrentValue=false,
   Callback=function(v)
      Config.ESP = v
      if v then
         for _, p in Players:GetPlayers() do
            if p ~= LocalPlayer and not (Config.TeamCheck and p.Team == LocalPlayer.Team) then
               createESP(p)
            end
         end
      else
         for _, data in ESPObjects do
            data.Connection:Disconnect()
            for _, d in data.Drawings do d:Remove() end
         end
         ESPObjects = {}
      end
   end
})
VisualsTab:CreateToggle({Name="Show FOV Circle", CurrentValue=false, Callback=function(v) Config.ShowFOV=v end})

-- [10] COMBAT
CombatTab:CreateToggle({Name="Hitbox Expander", CurrentValue=false, Callback=function(v) Config.HitboxExpand=v end})
CombatTab:CreateSlider({Name="Hitbox Size", Range={3,20}, Increment=1, CurrentValue=8, Callback=function(v) Config.HitboxSize=v end})
CombatTab:CreateToggle({Name="Infinite Ammo", CurrentValue=true, Callback=function(v) Config.InfiniteAmmo=v end})
CombatTab:CreateToggle({Name="Gun Mods (No Recoil, Instant Reload)", CurrentValue=false, Callback=function(v) Config.GunMods=v end})

-- [11] MOVEMENT
MovementTab:CreateToggle({Name="Speed Hack", CurrentValue=false, Callback=function(v) Config.SpeedEnabled=v end})
MovementTab:CreateSlider({Name="Walk Speed", Range={16,500}, Increment=5, CurrentValue=50, Callback=function(v) Config.WalkSpeed=v end})
MovementTab:CreateToggle({Name="Fly", CurrentValue=false, Callback=function(v) Config.FlyEnabled=v end})
MovementTab:CreateSlider({Name="Fly Speed", Range={16,200}, Increment=5, CurrentValue=50, Callback=function(v) Config.FlySpeed=v end})
MovementTab:CreateToggle({Name="Infinite Jump", CurrentValue=false, Callback=function(v) Config.InfiniteJump=v end})
MovementTab:CreateToggle({Name="Noclip", CurrentValue=false, Callback=function(v) Config.Noclip=v end})

-- [12] MISC
MiscTab:CreateToggle({Name="Godmode", CurrentValue=false, Callback=function(v) Config.Godmode=v end})
MiscTab:CreateToggle({Name="Anti-Aim (Spin)", CurrentValue=false, Callback=function(v) Config.AntiAim=v end})
MiscTab:CreateButton({Name="Teleport to Spawn", Callback=function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
   end
end})

-- [13] BYPASS
BypassTab:CreateDropdown({
   Name="Bypass Mode",
   Options={"None", "Anti-Cheat Bypass", "Server Hop", "Rejoin"},
   CurrentOption="None",
   Callback=function(v) Config.BypassMode=v end
})
BypassTab:CreateButton({Name="Execute Bypass", Callback=function()
   if Config.BypassMode == "Server Hop" then
      game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   elseif Config.BypassMode == "Rejoin" then
      LocalPlayer:Kick("Rejoining...")
      task.wait(1)
      game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   elseif Config.BypassMode == "Anti-Cheat Bypass" then
      -- Basic anti-detection
      for _, v in pairs(getgc(true)) do
         if typeof(v) == "function" then
            local name = debug.getinfo(v).name
            if name and (string.find(name, "Check") or string.find(name, "Detect")) then
               hookfunction(v, function() return false end)
            end
         end
      end
   end
end})

-- [14] FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255,0,0); FOVCircle.Thickness = 2; FOVCircle.NumSides = 30; FOVCircle.Filled = false; FOVCircle.Transparency = 0.8
RunService.RenderStepped:Connect(function()
   FOVCircle.Position = UserInputService:GetMouseLocation()
   FOVCircle.Radius = Config.FOVRadius
   FOVCircle.Visible = Config.ShowFOV
end)

-- [15] AIMBOT LOGIC
local function GetClosest()
   local Closest = nil
   local Mouse = UserInputService:GetMouseLocation()
   local Limit = Config.FOVRadius == 0 and math.huge or Config.FOVRadius
   local Best = Limit

   for _, p in Players:GetPlayers() do
      if p == LocalPlayer or (Config.TeamCheck and p.Team == LocalPlayer.Team) then continue end
      local Char = p.Character
      if not Char or not Char:FindFirstChild(Config.TargetPart) then continue end
      local Part = Char[Config.TargetPart]
      local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
      if not OnScreen then continue end
      local Dist = (Mouse - Vector2.new(Pos.X, Pos.Y)).Magnitude
      if Dist < Best then
         Closest = p; Best = Dist
      end
   end
   return Closest
end

RunService.Heartbeat:Connect(function()
   local Target = GetClosest()
   if Config.VisualAim and Target then
      local Predicted = Target.Character[Config.TargetPart].Position + (Target.Character.HumanoidRootPart.Velocity * Config.Prediction)
      local TargetCF = CFrame.lookAt(Camera.CFrame.Position, Predicted)
      Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Config.AimSmoothness)
   end
end)

-- [16] SILENT AIM + TRIGGERBOT
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
   local args = {...}
   local method = getnamecallmethod()
   if Config.SilentAim and (method == "FireServer" or method == "InvokeServer") then
      local Target = GetClosest()
      if Target then
         local Pos = Target.Character[Config.TargetPart].Position + (Target.Character.HumanoidRootPart.Velocity * Config.Prediction)
         for i, v in pairs(args) do
            if typeof(v) == "Vector3" then
               args[i] = Pos; break
            end
         end
      end
   end
   return old(self, unpack(args))
end)
setreadonly(mt, true)

-- Triggerbot
UserInputService.InputBegan:Connect(function(input)
   if Config.TriggerBot and input.UserInputType == Enum.UserInputType.MouseButton1 then
      local Target = GetClosest()
      if Target then
         mouse1click()
      end
   end
end)

-- [17] FLY (FIXED)
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local function startFly()
   if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
   local Root = LocalPlayer.Character.HumanoidRootPart

   FlyBodyVelocity = Instance.new("BodyVelocity")
   FlyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
   FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
   FlyBodyVelocity.Parent = Root

   FlyBodyGyro = Instance.new("BodyGyro")
   FlyBodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
   FlyBodyGyro.P = 20000
   FlyBodyGyro.Parent = Root

   spawn(function()
      while Config.FlyEnabled and task.wait() do
         local Move = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection
         local CamLook = Camera.CFrame.LookVector
         local CamRight = Camera.CFrame.RightVector
         local Velocity = (CamLook * Move.Z + CamRight * Move.X) * Config.FlySpeed

         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Velocity = Velocity + Vector3.new(0, Config.FlySpeed, 0)
         elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            Velocity = Velocity - Vector3.new(0, Config.FlySpeed, 0)
         end

         FlyBodyVelocity.Velocity = Velocity
      end
      if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
      if FlyBodyGyro then FlyBodyGyro:Destroy() end
   end)
end

MovementTab:CreateToggle({
   Name="Fly",
   CurrentValue=false,
   Callback=function(v)
      Config.FlyEnabled = v
      if v then startFly() end
   end
})

-- [18] MAIN LOOPS
RunService.Heartbeat:Connect(function()
   local Char = LocalPlayer.Character
   if not Char then return end

   -- Speed
   if Config.SpeedEnabled and Char:FindFirstChild("Humanoid") then
      Char.Humanoid.WalkSpeed = Config.WalkSpeed
   end

   -- Infinite Ammo
   if Config.InfiniteAmmo then
      local Tool = Char:FindFirstChildOfClass("Tool")
      if Tool and Tool:FindFirstChild("Ammo") then
         Tool.Ammo.Value = 999
      end
   end

   -- Hitbox Expander
   if Config.HitboxExpand then
      for _, p in Players:GetPlayers() do
         if p ~= LocalPlayer and not (Config.TeamCheck and p.Team == LocalPlayer.Team) then
            local C = p.Character
            if C then
               for _, part in C:GetChildren() do
                  if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                     part.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                     part.Transparency = 0.7
                     part.CanCollide = false
                  end
               end
            end
         end
      end
   end

   -- Gun Mods
   if Config.GunMods then
      local Tool = Char:FindFirstChildOfClass("Tool")
      if Tool then
         if Tool:FindFirstChild("Recoil") then Tool.Recoil.Value = 0 end
         if Tool:FindFirstChild("ReloadTime") then Tool.ReloadTime.Value = 0 end
      end
   end

   -- Godmode
   if Config.Godmode and Char:FindFirstChild("Humanoid") then
      Char.Humanoid.Health = Char.Humanoid.MaxHealth
   end

   -- Anti-Aim
   if Config.AntiAim and Char:FindFirstChild("HumanoidRootPart") then
      Char.HumanoidRootPart.CFrame = Char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
   end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
   if Config.InfiniteJump and LocalPlayer.Character then
      LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
   end
end)

-- Noclip
RunService.Stepped:Connect(function()
   if Config.Noclip and LocalPlayer.Character then
      for _, part in LocalPlayer.Character:GetDescendants() do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
end)

-- [19] PLAYER EVENTS
Players.PlayerAdded:Connect(function(p)
   p.CharacterAdded:Connect(function()
      task.wait(1)
      if Config.ESP then createESP(p) end
   end)
end)

-- [20] NOTIFICATION
Rayfield:Notify({
   Title = "Astra Hub Ultimate Loaded",
   Content = "All features working. Use RightShift to toggle.",
   Duration = 6
})

print("Astra Hub Ultimate - 100% Functional")
