-- RRR HUB V1.6 - REVISÃO TOTAL
getgenv().RRR_Configs = { 
    States = {
        ["PowerShotState"] = false,
        ["PowerOption1"] = false,
        ["PowerOption2"] = false,
        ["KeySteal"] = false,
        ["KeyAutoGoal"] = false,
        ["KeyCancelAnim"] = false,
        ["KeyTackle"] = false,
        ["Meta"] = false,
        ["Flow"] = false
    }, 
    Keys = {
        ["PowerValue"] = "230",
        ["HoldValue"] = "0.5",
        ["KeySteal"] = "",
        ["KeyAutoGoal"] = "",
        ["KeyCancelAnim"] = "",
        ["KeyTackle"] = ""
    } 
}
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
Title.Size = UDim2.new(0.5, 0, 0.6, 0); Title.Position = UDim2.new(0.05, 0, 0.2, 0); Title.BackgroundTransparency = 1; Title.Text = "R.R.R HUB - v1.6"; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextScaled = true; Title.TextXAlignment = 0

local MinimizeBtn = Instance.new("TextButton", UpBar)
MinimizeBtn.Size = UDim2.new(0.08, 0, 0.6, 0); MinimizeBtn.Position = UDim2.new(0.88, 0, 0.2, 0); MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); MinimizeBtn.Text = "-"; MinimizeBtn.TextColor3 = Color3.new(1,1,1); MinimizeBtn.TextScaled = true; Instance.new("UICorner", MinimizeBtn)

local Main = Instance.new("ImageLabel", Drag)
Main.BackgroundTransparency = 1; Main.Position = UDim2.new(0.152, 0, 0.118, 0); Main.Size = UDim2.new(0.807, 0, 0.852, 0); Main.Image = "rbxassetid://116118555895648"

local Options = Instance.new("ImageLabel", Drag)
Options.BackgroundTransparency = 1; Options.Position = UDim2.new(0.01, 0, 0.13, 0); Options.Size = UDim2.new(0.12, 0, 0.83, 0); Options.Image = "rbxassetid://78746999303808"
Instance.new("UIListLayout", Options).Padding = UDim.new(0, 5)

MinimizeBtn.MouseButton1Click:Connect(function()
    local target = not Main.Visible
    Main.Visible = target; Options.Visible = target
    MinimizeBtn.Text = target and "-" or "+"
end)

-- Sistema de Abas
local Tabs = {}
local function CreateTab(name)
    local Scroller = Instance.new("ScrollingFrame", Main)
    Scroller.Size = UDim2.new(1, 0, 1, 0); Scroller.BackgroundTransparency = 1; Scroller.Visible = false; Scroller.AutomaticCanvasSize = 2; Scroller.ScrollBarThickness = 2
    Instance.new("UIListLayout", Scroller).Padding = UDim.new(0, 5)
    Tabs[name] = Scroller
    local btn = Instance.new("TextButton", Options)
    btn.Size = UDim2.new(1, 0, 0.1, 0); btn.BackgroundTransparency = 1; btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.TextScaled = true
    btn.MouseButton1Click:Connect(function() for _,t in pairs(Tabs) do t.Visible = false end Scroller.Visible = true end)
    return Scroller
end

local function AddCheat(parent, name, placeholder, saveId, type, callback)
    local M = Instance.new("Frame", parent)
    M.Size = UDim2.new(0.95, 0, 0, 55); M.BackgroundTransparency = 0.8; M.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UICorner", M)
    
    local Lab = Instance.new("TextLabel", M)
    Lab.Size = UDim2.new(0.4, 0, 1, 0); Lab.Position = UDim2.new(0.02, 0, 0, 0); Lab.Text = name; Lab.TextColor3 = Color3.new(1,1,1); Lab.BackgroundTransparency = 1; Lab.TextScaled = true; Lab.TextXAlignment = 0

    if type == "PowerWithHold" then
        local B1 = Instance.new("TextBox", M)
        B1.Size = UDim2.new(0.12, 0, 0.5, 0); B1.Position = UDim2.new(0.38, 0, 0.25, 0); B1.PlaceholderText = "Pwr"; B1.Text = "230"; B1.BackgroundColor3 = Color3.new(0.1,0.1,0.1); B1.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", B1)
        B1.FocusLost:Connect(function() getgenv().RRR_Configs.Keys["PowerValue"] = B1.Text end)
        
        local B2 = Instance.new("TextBox", M)
        B2.Size = UDim2.new(0.12, 0, 0.5, 0); B2.Position = UDim2.new(0.52, 0, 0.25, 0); B2.PlaceholderText = "Hold"; B2.Text = "0.5"; B2.BackgroundColor3 = Color3.new(0.1,0.1,0.1); B2.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", B2)
        B2.FocusLost:Connect(function() getgenv().RRR_Configs.Keys["HoldValue"] = B2.Text end)

        for i=1,2 do
            local optId = "PowerOption"..i
            local Opt = Instance.new("TextButton", M)
            Opt.Size = UDim2.new(0.06, 0, 0.4, 0); Opt.Position = UDim2.new(0.66 + (i*0.07), 0, 0.3, 0); Opt.Text = ""
            Opt.BackgroundColor3 = Color3.new(0.2,0.2,0.2); Instance.new("UICorner", Opt)
            Opt.MouseButton1Click:Connect(function()
                getgenv().RRR_Configs.States[optId] = not getgenv().RRR_Configs.States[optId]
                Opt.BackgroundColor3 = getgenv().RRR_Configs.States[optId] and Color3.new(0,0.7,0) or Color3.new(0.2,0.2,0.2)
            end)
        end
    elseif type == "Keybind" then
        local Box = Instance.new("TextBox", M)
        Box.Size = UDim2.new(0.2, 0, 0.6, 0); Box.Position = UDim2.new(0.5, 0, 0.2, 0); Box.PlaceholderText = placeholder; Box.BackgroundColor3 = Color3.new(0.1,0.1,0.1); Box.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", Box)
        Box.FocusLost:Connect(function() getgenv().RRR_Configs.Keys[saveId] = Box.Text end)
    elseif type == "ButtonOnly" then
        local B = Instance.new("TextButton", M)
        B.Size = UDim2.new(0.3, 0, 0.7, 0); B.Position = UDim2.new(0.5, 0, 0.15, 0); B.Text = "EXEC"; B.BackgroundColor3 = Color3.new(0.2,0.2,0.2); B.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", B)
        B.MouseButton1Click:Connect(callback)
    end

    if type ~= "ButtonOnly" then
        local Btn = Instance.new("TextButton", M)
        Btn.Size = UDim2.new(0.12, 0, 0.6, 0); Btn.Position = UDim2.new(0.85, 0, 0.2, 0); Btn.BackgroundColor3 = Color3.fromRGB(180,0,0); Btn.Text = "OFF"; Btn.TextColor3 = Color3.new(1,1,1); Btn.TextScaled = true; Instance.new("UICorner", Btn)
        Btn.MouseButton1Click:Connect(function()
            getgenv().RRR_Configs.States[saveId] = not getgenv().RRR_Configs.States[saveId]
            Btn.Text = getgenv().RRR_Configs.States[saveId] and "ON" or "OFF"
            Btn.BackgroundColor3 = getgenv().RRR_Configs.States[saveId] and Color3.new(0,0.6,0) or Color3.fromRGB(180,0,0)
        end)
    end
end

-- CRIAÇÃO DAS ABAS E TODOS OS BOTÕES
local Misc = CreateTab("Misc")
local PlayerTab = CreateTab("Player")
Misc.Visible = true

AddCheat(Misc, "PowerShot", "Pwr", "PowerShotState", "PowerWithHold")
AddCheat(Misc, "AutoSteal", "KEY", "KeySteal", "Keybind")
AddCheat(Misc, "AutoGoal", "KEY", "KeyAutoGoal", "Keybind")
AddCheat(Misc, "Cancel Anim", "KEY", "KeyCancelAnim", "Keybind")
AddCheat(Misc, "SpamTackle", "KEY", "KeyTackle", "Keybind")

AddCheat(PlayerTab, "Team Select", "", "TS", "ButtonOnly", function() player.PlayerGui.TeamSelect.Enabled = true end)
AddCheat(PlayerTab, "Fix Cam", "", "FC", "ButtonOnly", function() camera.CameraSubject = player.Character.Humanoid; camera.CameraType = 4 end)
AddCheat(PlayerTab, "Metavision", "", "Meta", "ToggleOnly")
AddCheat(PlayerTab, "Fake Flow", "", "Flow", "ToggleOnly")

-- LÓGICAS (STEAL E CHUTE)
local function dispararForte()
    local c = getgenv().RRR_Configs; local pwr = tonumber(c.Keys.PowerValue) or 230
    local dir = (camera.CFrame.LookVector * 1000 + Vector3.new(0, 0.15, 0)).Unit
    Shoot:FireServer(pwr, dir, dir, player.Character.HumanoidRootPart.Position, c.States.PowerOption1, c.States.PowerOption2)
end

local function executarSteal()
    local ball = workspace:FindFirstChild("Ball"); local hrp = player.Character.HumanoidRootPart
    if not ball or ball:GetAttribute("State") == player.Name then return end
    while getgenv().RRR_Configs.States.KeySteal do
        local vel = ball.AssemblyLinearVelocity; local pos = (vel.Magnitude > 10) and (ball.Position + (vel * 0.12)) or ball.Position
        hrp.CFrame = CFrame.new(pos.X, pos.Y + 2.2, pos.Z); hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
        Tackle:FireServer(); task.wait()
        if ball:GetAttribute("State") == player.Name then break end
    end
end

-- INPUTS (M2, Z, KEYBINDS)
CAS:BindActionAtPriority("RRR_Shoot", function(_, state)
    if state == 2 and getgenv().RRR_Configs.States.PowerShotState then
        local hold = tonumber(getgenv().RRR_Configs.Keys.HoldValue) or 0.5
        task.wait(hold); dispararForte()
    end
    return 2
end, false, 3000, 2)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then Drag.Visible = not Drag.Visible end
    local kS = getgenv().RRR_Configs.Keys.KeySteal
    if kS ~= "" and input.KeyCode == Enum.KeyCode[kS:upper()] then executarSteal() end
end)

-- Drag System
local dragIn, dragS, startP
UpBar.InputBegan:Connect(function(i) if i.UserInputType.Value == 0 or i.UserInputType.Value == 7 then dragIn = true; dragS = i.Position; startP = Drag.Position end end)
UIS.InputChanged:Connect(function(i) if dragIn and (i.UserInputType.Value == 4 or i.UserInputType.Value == 7) then 
    local delta = i.Position - dragS; Drag.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y)
end end)
UIS.InputEnded:Connect(function() dragIn = false end)
