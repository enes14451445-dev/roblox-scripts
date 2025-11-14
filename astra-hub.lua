--[[
   Astra Hub - Universal ESP & Aimbot (Rayfield UI)
   Works in EVERY Roblox Game (Client-Side Only)
   Silent Aim (Universal Hook), Visual Aimbot, ESP (No Teammates)
   Author: Astra Hub (2025 Edition)
   Educational Purposes ONLY - Use Alt Account
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Globals (Synced with UI Callbacks)
local SilentEnabled = false
local VisualEnabled = false
local TeamCheckEnabled = true
local TargetPart = "Head"
local Prediction = 0.13
local FOVRadius = 100
local ShowFOV = false
local ESPEnabled = false

-- Load Rayfield UI (Proven Working)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Astra Hub - Universal",
   LoadingTitle = "Loading ESP & Aimbot...",
   LoadingSubtitle = "Every Game Compatible",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AstraHub",
      FileName = "UniversalConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinv",
      RememberJoins = true
   },
   KeySystem = false
})

-- Tabs
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)

-- Aimbot Controls
AimbotTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Flag = "SilentAim",
   Callback = function(Value)
      SilentEnabled = Value
   end
})

AimbotTab:CreateToggle({
   Name = "Visual Aimbot",
   CurrentValue = false,
   Flag = "VisualAimbot",
   Callback = function(Value)
      VisualEnabled = Value
   end
})

AimbotTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Flag = "TeamCheck",
   Callback = function(Value)
      TeamCheckEnabled = Value
   end
})

AimbotTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
   CurrentOption = "Head",
   Flag = "TargetPart",
   Callback = function(Option)
      TargetPart = Option
   end
})

AimbotTab:CreateSlider({
   Name = "Prediction",
   Range = {0, 1},
   Increment = 0.01,
   CurrentValue = 0.13,
   Flag = "Prediction",
   Callback = function(Value)
      Prediction = Value
   end
})

AimbotTab:CreateSlider({
   Name = "FOV Radius",
   Range = {0, 500},
   Increment = 5,
   CurrentValue = 100,
   Flag = "FOVRadius",
   Callback = function(Value)
      FOVRadius = Value
   end
})

AimbotTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Flag = "ShowFOV",
   Callback = function(Value)
      ShowFOV = Value
   end
})

-- ESP Control
ESPTab:CreateToggle({
   Name = "Player ESP (No Teammates)",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      ESPEnabled = Value
      if Value then
         -- Apply to current players (exclude local & teammates)
         for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not (plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team) then
               if plr.Character then
                  local highlight = Instance.new("Highlight")
                  highlight.Name = "AstraESP"
                  highlight.FillColor = Color3.fromRGB(255, 0, 0)
                  highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                  highlight.FillTransparency = 0.5
                  highlight.OutlineTransparency = 0
                  highlight.Parent = plr.Character
               end
            end
         end
      else
         -- Destroy all ESP highlights
         for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("AstraESP") then
               plr.Character.AstraESP:Destroy()
            end
         end
      end
   end,
})

-- Core Functions
local function getClosestPlayer()
   local closestPlayer = nil
   local mousePos = UserInputService:GetMouseLocation()
   local fovLimit = (FOVRadius == 0) and math.huge or FOVRadius
   local shortestDistance = fovLimit

   for _, Player in pairs(Players:GetPlayers()) do
      if Player == LocalPlayer then continue end
      if TeamCheckEnabled and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then continue end
      local char = Player.Character
      if not char then continue end
      local hitPart = char:FindFirstChild(TargetPart)
      if not hitPart then continue end

      local targetPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
      if not onScreen then continue end

      local magnitude = (mousePos - Vector2.new(targetPos.X, targetPos.Y)).Magnitude
      if magnitude < shortestDistance then
         closestPlayer = Player
         shortestDistance = magnitude
      end
   end
   return closestPlayer
end

local function getPredictedPosition(targetPlayer)
   local char = targetPlayer.Character
   if not char then return Vector3.new() end
   local rootPart = char:FindFirstChild("HumanoidRootPart")
   local hitPart = char:FindFirstChild(TargetPart)
   if rootPart and hitPart then
      return hitPart.Position + (rootPart.Velocity * Prediction)
   end
   return Vector3.new()
end

-- Visual Aimbot Loop
RunService.Heartbeat:Connect(function()
   if not VisualEnabled then return end
   local closestPlayer = getClosestPlayer()
   if closestPlayer then
      local predictedPos = getPredictedPosition(closestPlayer)
      Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
   end
end)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Thickness = 2
fovCircle.NumSides = 30
fovCircle.Radius = FOVRadius
fovCircle.Filled = false
fovCircle.Transparency = 0.8
fovCircle.Visible = ShowFOV

RunService.RenderStepped:Connect(function()
   fovCircle.Position = UserInputService:GetMouseLocation()
   fovCircle.Radius = FOVRadius
   fovCircle.Visible = ShowFOV
end)

-- Universal Silent Aim Hook (FireServer & InvokeServer)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
   local args = {...}
   local method = getnamecallmethod()
   if (method == "FireServer" or method == "InvokeServer") and SilentEnabled then
      local closestPlayer = getClosestPlayer()
      if closestPlayer then
         local predictedPos = getPredictedPosition(closestPlayer)
         for i = 1, #args do
            if typeof(args[i]) == "Vector3" then
               args[i] = predictedPos
               break
            end
         end
      end
   end
   return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Auto-ESP for New Players (No Teammates)
Players.PlayerAdded:Connect(function(plr)
   plr.CharacterAdded:Connect(function(char)
      if ESPEnabled and plr ~= LocalPlayer and not (plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team) then
         task.wait(0.1)
         local highlight = Instance.new("Highlight")
         highlight.Name = "AstraESP"
         highlight.FillColor = Color3.fromRGB(255, 0, 0)
         highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
         highlight.FillTransparency = 0.5
         highlight.OutlineTransparency = 0
         highlight.Parent = char
      end
   end)
end)

-- Initial ESP Load (Safe)
task.spawn(function()
   task.wait(1)
   if ESPEnabled then
      ESPTab.Flags.ESP.CurrentValue = true  -- Trigger callback if needed
   end
end)

-- Notification
Rayfield:Notify({
   Title = "Astra Hub Loaded",
   Content = "Universal ESP & Aimbot Ready",
   Duration = 4,
   Image = 4483362458,
})

print("Astra Hub Universal - ESP & Aimbot Loaded Successfully")
