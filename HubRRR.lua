-- RRR HUB V1.8 - FULL FIX
getgenv().RRR_Configs = { 
    States = {}, 
    Keys = {
        ["PowerValue"] = "230",
        ["HoldValue"] = "0.5",
        ["KeySteal"] = "V",
        ["KeyAutoGoal"] = "G",
        ["KeyCancelAnim"] = "X",
        ["KeyTackle"] = "C"
    } 
}

local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FILE_NAME = "RRR_V18_Save.json"

-- [SISTEMA DE SAVE]
local function Save()
    if writefile then writefile(FILE_NAME, HttpService:JSONEncode(getgenv().RRR_Configs.Keys)) end
end
if isfile and isfile(FILE_NAME) then
    pcall(function() 
        local data = HttpService:JSONDecode(readfile(FILE_NAME))
        for k,v in pairs(data) do getgenv().RRR_Configs.Keys[k] = v end
    end)
end

-- [INTERFACE VISUAL]
if CoreGui:FindFirstChild("RRR") then CoreGui.RRR:Destroy() end
local RRR = Instance.new("ScreenGui", CoreGui); RRR.Name = "RRR"

local Drag = Instance.new("ImageLabel", RRR)
Drag.Name = "Drag"; Drag.BackgroundTransparency = 1; Drag.Position = UDim2.new(0.3, 0, 0.3, 0); Drag.Size = UDim2.new(0.47, 0, 0.465, 0); Drag.Image = "rbxassetid://132146341566959"; Drag.Active = true

local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Size = UDim2.new(1, 0, 0.2, 0); UpBar.Position = UDim2.new(0, 0, -0.1, 0); UpBar.BackgroundTransparency = 1; UpBar.Image = "rbxassetid://74857124519074"

local Title = Instance.new("TextLabel", UpBar)
Title.Size = UDim2.new(0.5, 0, 0.6, 0); Title.Position = UDim2.new(0.05, 0, 0.2, 0); Title.BackgroundTransparency = 1; Title.Text = "R.R.R HUB - v1.8"; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextScaled = true; Title.TextXAlignment = 0

local MinimizeBtn = Instance.new("TextButton", UpBar)
MinimizeBtn.Size = UDim2.new(0.08, 0, 0.6, 0); MinimizeBtn.Position = UDim2.new(0.88, 0, 0.2, 0); MinimizeBtn.Text = "-"; MinimizeBtn.TextColor3 = Color3.new(1,1,1); MinimizeBtn.BackgroundColor3 = Color3.new(0.1,0.1,0.1); Instance.new("UICorner", MinimizeBtn)

local Main = Instance.new("ImageLabel", Drag)
Main.BackgroundTransparency = 1; Main.Position = UDim2.new(0.152, 0, 0.118, 0); Main.Size = UDim2.new(0.807, 0, 0.852, 0); Main.Image = "rbxassetid://116118555895648"

local Options = Instance.new("ImageLabel", Drag)
Options.BackgroundTransparency = 1; Options.Position = UDim2.new(0.01, 0, 0.13, 0); Options.Size = UDim2.new(0.12, 0, 0.83, 0); Options.Image = "rbxassetid://78746999303808"
Instance.new("UIListLayout", Options)

-- Minimize fecha tudo (Main e Options)
MinimizeBtn.MouseButton1Click:Connect(function()
    local t = not Main.Visible
    Main.Visible = t; Options.Visible = t; MinimizeBtn.Text = t and "-" or "+"
end)

-- [GERENCIADOR DE ABAS]
local Tabs = {}
local function CreateTab(name)
    local S = Instance.new("ScrollingFrame", Main)
    S.Size = UDim2.new(1, 0, 1, 0); S.BackgroundTransparency = 1; S.Visible = false; S.ScrollBarThickness = 2; S.AutomaticCanvasSize = 2
    Instance.new("UIListLayout", S).Padding = UDim.new(0, 5)
    Tabs[name] = S
    local b = Instance.new("TextButton", Options)
    b.Size = UDim2.new(1, 0, 0.1, 0); b.BackgroundTransparency = 1; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.TextScaled = true
    b.MouseButton1Click:Connect(function() for _,v in pairs(Tabs) do v.Visible = false end S.Visible = true end)
    return S
end

local function AddCheat(parent, name, placeholder, saveId, type, callback)
    getgenv().RRR_Configs.States[saveId] = false
    local M = Instance.new("Frame", parent)
    M.Size = UDim2.new(0.95, 0, 0, 50); M.BackgroundTransparency = 0.8; M.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UICorner", M)
    
    local Lab = Instance.new("TextLabel", M)
    Lab.Size = UDim2.new(0.4, 0, 1, 0); Lab.Text = name; Lab.TextColor3 = Color3.new(1,1,1); Lab.BackgroundTransparency = 1; Lab.TextScaled = true; Lab.TextXAlignment = 0

    if type == "PowerWithHold" then
        local function box(posX, sId)
            local b = Instance.new("TextBox", M)
            b.Size = UDim2.new(0.14, 0, 0.6, 0); b.Position = UDim2.new(posX, 0, 0.2, 0); b.Text = getgenv().RRR_Configs.Keys[sId] or ""
            b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", b)
            b.FocusLost:Connect(function() getgenv().RRR_Configs.Keys[sId] = b.Text Save() end)
        end
        box(0.42, "PowerValue"); box(0.57, "HoldValue")
        -- Seletor de Opções (Quadradinhos)
        for i=1,2 do
            local sId = "PowerOption"..i
            local o = Instance.new("TextButton", M)
            o.Size = UDim2.new(0.05,0,0.4,0); o.Position = UDim2.new(0.72+(i*0.06),0,0.3,0); o.Text = ""; o.BackgroundColor3 = Color3.new(0.2,0.2,0.2); Instance.new("UICorner", o)
            o.MouseButton1Click:Connect(function() getgenv().RRR_Configs.States[sId] = not getgenv().RRR_Configs.States[sId] o.BackgroundColor3 = getgenv().RRR_Configs.States[sId] and Color3.new(0,1,0) or Color3.new(0.2,0.2,0.2) end)
        end
    elseif type == "Keybind" then
        local b = Instance.new("TextBox", M)
        b.Size = UDim2.new(0.2, 0, 0.6, 0); b.Position = UDim2.new(0.5, 0, 0.2, 0); b.Text = getgenv().RRR_Configs.Keys[saveId] or ""; b.PlaceholderText = placeholder
        b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", b)
        b.FocusLost:Connect(function() getgenv().RRR_Configs.Keys[saveId] = b.Text Save() end)
    elseif type == "ButtonOnly" then
        local b = Instance.new("TextButton", M)
        b.Size = UDim2.new(0.3,0,0.7,0); b.Position = UDim2.new(0.6,0,0.15,0); b.Text = "EXEC"; b.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(callback)
    end

    if type ~= "ButtonOnly" then
        local sw = Instance.new("TextButton", M)
        sw.Size = UDim2.new(0.1,0,0.6,0); sw.Position = UDim2.new(0.88,0,0.2,0); sw.Text = "OFF"; sw.BackgroundColor3 = Color3.new(0.7,0,0); sw.TextColor3 = Color3.new(1,1,1); sw.TextScaled = true; Instance.new("UICorner", sw)
        sw.MouseButton1Click:Connect(function()
            getgenv().RRR_Configs.States[saveId] = not getgenv().RRR_Configs.States[saveId]
            sw.Text = getgenv().RRR_Configs.States[saveId] and "ON" or "OFF"
            sw.BackgroundColor3 = getgenv().RRR_Configs.States[saveId] and Color3.new(0,0.6,0) or Color3.new(0.7,0,0)
        end)
    end
end

-- [BOTÕES DA HUB]
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
AddCheat(PlayerTab, "Metavision", "", "Meta", "Toggle")
AddCheat(PlayerTab, "Fake Flow", "", "Flow", "Toggle")

-- [LÓGICA DO FLOW (SEGURAR 1S)]
task.spawn(function()
    local holdStart = 0
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F then -- Tecla padrão do Flow
            holdStart = tick()
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            if (tick() - holdStart) >= 1 then
                getgenv().RRR_Configs.States["Flow"] = not getgenv().RRR_Configs.States["Flow"]
                player:SetAttribute("Flow", getgenv().RRR_Configs.States["Flow"])
            end
        end
    end)
end)

-- [LÓGICA STEAL (VELOCIDADE > 10)]
local function doSteal()
    local b = workspace:FindFirstChild("Ball"); local hrp = player.Character.HumanoidRootPart
    if not b or not hrp then return end
    while getgenv().RRR_Configs.States.KeySteal do
        local v = b.AssemblyLinearVelocity
        local pos = (v.Magnitude > 10) and (b.Position + (v * 0.12)) or b.Position
        hrp.CFrame = CFrame.new(pos.X, pos.Y + 2.2, pos.Z); hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
        ReplicatedStorage.Remotes.Tackle:FireServer(); task.wait()
        if b:GetAttribute("State") == player.Name then break end
    end
end

-- [ARRASTE]
local dragIn, dragS, startP
UpBar.InputBegan:Connect(function(i) if i.UserInputType.Value == 0 or i.UserInputType.Value == 7 then dragIn = true; dragS = i.Position; startP = Drag.Position end end)
UIS.InputChanged:Connect(function(i) if dragIn and (i.UserInputType.Value == 4 or i.UserInputType.Value == 7) then 
    local delta = i.Position - dragS; Drag.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y)
end end)
UIS.InputEnded:Connect(function() dragIn = false end)

-- [BINDS FINAIS]
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Z then Drag.Visible = not Drag.Visible end
    local kS = getgenv().RRR_Configs.Keys.KeySteal
    if kS and kS ~= "" and i.KeyCode == Enum.KeyCode[kS:upper()] then doSteal() end
end)
