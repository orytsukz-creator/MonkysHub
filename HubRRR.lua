-- RRR HUB V1.6 - FIX TOTAL
getgenv().RRR_Configs = { States = {}, Keys = {} }
getgenv().ScriptAtivoRRR = true

local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- Interface
if CoreGui:FindFirstChild("RRR") then CoreGui.RRR:Destroy() end
local RRR = Instance.new("ScreenGui", CoreGui); RRR.Name = "RRR"

local Drag = Instance.new("ImageLabel", RRR)
Drag.Name = "Drag"; Drag.BackgroundTransparency = 1; Drag.Position = UDim2.new(0.3, 0, 0.3, 0); Drag.Size = UDim2.new(0.47, 0, 0.465, 0); Drag.Image = "rbxassetid://132146341566959"; Drag.Active = true

local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Size = UDim2.new(1, 0, 0.2, 0); UpBar.Position = UDim2.new(0, 0, -0.1, 0); UpBar.BackgroundTransparency = 1; UpBar.Image = "rbxassetid://74857124519074"

local Title = Instance.new("TextLabel", UpBar)
Title.Size = UDim2.new(0.5, 0, 0.6, 0); Title.Position = UDim2.new(0.05, 0, 0.2, 0); Title.BackgroundTransparency = 1; Title.Text = "R.R.R HUB - v1.6"; Title.TextColor3 = Color3.new(1,1,1); Title.TextScaled = true; Title.TextXAlignment = 0

-- BOTÃO MINIMIZE (Esconde tudo embaixo da barra)
local MinimizeBtn = Instance.new("TextButton", UpBar)
MinimizeBtn.Size = UDim2.new(0.08, 0, 0.6, 0); MinimizeBtn.Position = UDim2.new(0.88, 0, 0.2, 0); MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); MinimizeBtn.Text = "-"; MinimizeBtn.TextColor3 = Color3.new(1,1,1); MinimizeBtn.TextScaled = true; Instance.new("UICorner", MinimizeBtn)

local Main = Instance.new("ImageLabel", Drag)
Main.BackgroundTransparency = 1; Main.Position = UDim2.new(0.152, 0, 0.118, 0); Main.Size = UDim2.new(0.807, 0, 0.852, 0); Main.Image = "rbxassetid://116118555895648"

local Options = Instance.new("ImageLabel", Drag)
Options.BackgroundTransparency = 1; Options.Position = UDim2.new(0.01, 0, 0.13, 0); Options.Size = UDim2.new(0.12, 0, 0.83, 0); Options.Image = "rbxassetid://78746999303808"
Instance.new("UIListLayout", Options).Padding = UDim.new(0, 5)

MinimizeBtn.MouseButton1Click:Connect(function()
    local target = not Main.Visible
    Main.Visible = target
    Options.Visible = target
    MinimizeBtn.Text = target and "-" or "+"
end)

-- Sistema de Abas e Botões
local Tabs = {}
local function CreateTab(name)
    local Scroller = Instance.new("ScrollingFrame", Main)
    Scroller.Size = UDim2.new(1, 0, 1, 0); Scroller.BackgroundTransparency = 1; Scroller.Visible = false; Scroller.AutomaticCanvasSize = 2
    Instance.new("UIListLayout", Scroller).Padding = UDim.new(0, 5)
    Tabs[name] = Scroller
    local btn = Instance.new("TextButton", Options)
    btn.Size = UDim2.new(1, 0, 0.1, 0); btn.BackgroundTransparency = 1; btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.TextScaled = true
    btn.MouseButton1Click:Connect(function() for _,t in pairs(Tabs) do t.Visible = false end Scroller.Visible = true end)
    return Scroller
end

local function AddCheat(parent, name, placeholder, saveId, type, callback)
    getgenv().RRR_Configs.States[saveId] = false
    local M = Instance.new("Frame", parent)
    M.Size = UDim2.new(0.95, 0, 0, 50); M.BackgroundTransparency = 0.8; M.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UICorner", M)
    
    local Lab = Instance.new("TextLabel", M)
    Lab.Size = UDim2.new(0.4, 0, 1, 0); Lab.Position = UDim2.new(0.02, 0, 0, 0); Lab.Text = name; Lab.TextColor3 = Color3.new(1,1,1); Lab.BackgroundTransparency = 1; Lab.TextScaled = true; Lab.TextXAlignment = 0

    if type == "PowerWithHold" then
        local B1 = Instance.new("TextBox", M)
        B1.Size = UDim2.new(0.15, 0, 0.6, 0); B1.Position = UDim2.new(0.42, 0, 0.2, 0); B1.PlaceholderText = "Pwr"; B1.Text = ""; B1.BackgroundColor3 = Color3.new(0.1,0.1,0.1); B1.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", B1)
        B1.FocusLost:Connect(function() getgenv().RRR_Configs.Keys["PowerValue"] = B1.Text end)
        
        local B2 = Instance.new("TextBox", M)
        B2.Size = UDim2.new(0.15, 0, 0.6, 0); B2.Position = UDim2.new(0.58, 0, 0.2, 0); B2.PlaceholderText = "Hold"; B2.Text = ""; B2.BackgroundColor3 = Color3.new(0.1,0.1,0.1); B2.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", B2)
        B2.FocusLost:Connect(function() getgenv().RRR_Configs.Keys["HoldValue"] = B2.Text end)
    elseif type == "Keybind" then
        local Box = Instance.new("TextBox", M)
        Box.Size = UDim2.new(0.2, 0, 0.6, 0); Box.Position = UDim2.new(0.5, 0, 0.2, 0); Box.PlaceholderText = placeholder; Box.Text = ""; Box.BackgroundColor3 = Color3.new(0.1,0.1,0.1); Box.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", Box)
        Box.FocusLost:Connect(function() getgenv().RRR_Configs.Keys[saveId] = Box.Text end)
    elseif type == "ButtonOnly" then
        local B = Instance.new("TextButton", M)
        B.Size = UDim2.new(0.3, 0, 0.7, 0); B.Position = UDim2.new(0.5, 0, 0.15, 0); B.Text = "EXEC"; B.BackgroundColor3 = Color3.new(0.2,0.2,0.2); B.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", B)
        B.MouseButton1Click:Connect(callback)
    end

    if type ~= "ButtonOnly" then
        local Btn = Instance.new("TextButton", M)
        Btn.Size = UDim2.new(0.15, 0, 0.6, 0); Btn.Position = UDim2.new(0.83, 0, 0.2, 0); Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); Btn.Text = "OFF"; Btn.TextColor3 = Color3.new(1,1,1); Btn.TextScaled = true; Instance.new("UICorner", Btn)
        Btn.MouseButton1Click:Connect(function()
            getgenv().RRR_Configs.States[saveId] = not getgenv().RRR_Configs.States[saveId]
            Btn.Text = getgenv().RRR_Configs.States[saveId] and "ON" or "OFF"
            Btn.BackgroundColor3 = getgenv().RRR_Configs.States[saveId] and Color3.new(0, 0.6, 0) or Color3.fromRGB(200, 0, 0)
        end)
    end
end

-- Criando Abas e Botões
local Misc = CreateTab("Misc")
local PlayerTab = CreateTab("Player")
Misc.Visible = true

AddCheat(Misc, "PowerShot", "Pwr", "PowerShotState", "PowerWithHold")
AddCheat(Misc, "AutoSteal", "KEY", "KeySteal", "Keybind")
AddCheat(PlayerTab, "Team Select", "", "TS", "ButtonOnly", function() player.PlayerGui.TeamSelect.Enabled = true end)
AddCheat(PlayerTab, "Fix Cam", "", "FC", "ButtonOnly", function() camera.CameraSubject = player.Character.Humanoid; camera.CameraType = 4 end)

-- Lógica do Steal (No pé e Estável)
local function executarSteal()
    local ball = workspace:FindFirstChild("Ball"); local hrp = player.Character.HumanoidRootPart
    if not ball or ball:GetAttribute("State") == player.Name then return end
    local start = tick()
    while getgenv().RRR_Configs.States["KeySteal"] and (tick() - start < 3) do
        local vel = ball.AssemblyLinearVelocity
        local pos = (vel.Magnitude > 10) and (ball.Position + (vel * 0.12)) or ball.Position
        hrp.CFrame = CFrame.new(pos.X, pos.Y + 2.2, pos.Z)
        hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
        Tackle:FireServer(); task.wait()
        if ball:GetAttribute("State") == player.Name then break end
    end
end

-- Keybinds e Drag
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then Drag.Visible = not Drag.Visible end
    local key = getgenv().RRR_Configs.Keys["KeySteal"]
    if key and input.KeyCode == Enum.KeyCode[key:upper()] then executarSteal() end
end)

-- Drag System
local dragIn, dragS, startP
UpBar.InputBegan:Connect(function(i) if i.UserInputType.Value == 0 or i.UserInputType.Value == 7 then dragIn = true; dragS = i.Position; startP = Drag.Position end end)
UIS.InputChanged:Connect(function(i) if dragIn and (i.UserInputType.Value == 4 or i.UserInputType.Value == 7) then 
    local delta = i.Position - dragS
    Drag.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y)
end end)
UIS.InputEnded:Connect(function() dragIn = false end)
