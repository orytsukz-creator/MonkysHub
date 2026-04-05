-- CONFIGURAÇÕES E TRAVAS
getgenv().RRR_Configs = { 
    States = { ["PowerOption1"] = true, ["PowerOption2"] = true }, 
    Keys = { ["PowerValue"] = "230", ["HoldValue"] = "0.5", ["KeySteal"] = "V", ["KeyAutoGoal"] = "G" } 
}

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = game.Players.LocalPlayer

-- DIRETÓRIO MOBILE (FLOWBUTTON)
local PlayerGui = player:WaitForChild("PlayerGui")
local MobileFrame = PlayerGui:WaitForChild("MobileSupport"):WaitForChild("Frame")
local FlowBtn = MobileFrame:WaitForChild("FlowButton")

if CoreGui:FindFirstChild("RRR") then CoreGui.RRR:Destroy() end
local RRR = Instance.new("ScreenGui", CoreGui); RRR.Name = "RRR"

-- FUNÇÃO PANIC (TECLA P)
local function SelfDestruct()
    RRR:Destroy()
    getgenv().RRR_Configs = nil
    warn("RRR HUB: Script encerrado.")
end

-- FRAME PRINCIPAL
local Drag = Instance.new("ImageLabel", RRR)
Drag.Name = "Drag"; Drag.BackgroundTransparency = 1; Drag.Position = UDim2.new(0.3, 0, 0.3, 0); Drag.Size = UDim2.new(0.47, 0, 0.465, 0); Drag.Image = "rbxassetid://132146341566959"; Drag.Active = true

local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Size = UDim2.new(1, 0, 0.2, 0); UpBar.Position = UDim2.new(0, 0, -0.1, 0); UpBar.BackgroundTransparency = 1; UpBar.Image = "rbxassetid://74857124519074"

local MinimizeBtn = Instance.new("ImageButton", UpBar)
MinimizeBtn.Size = UDim2.new(0.06, 0, 0.5, 0); MinimizeBtn.Position = UDim2.new(0.9, 0, 0.25, 0); MinimizeBtn.BackgroundTransparency = 1; MinimizeBtn.Image = "rbxassetid://11432624331"
MinimizeBtn.MouseButton1Click:Connect(function() Drag.Visible = false end)

local Main = Instance.new("ImageLabel", Drag)
Main.BackgroundTransparency = 1; Main.Position = UDim2.new(0.152, 0, 0.118, 0); Main.Size = UDim2.new(0.807, 0, 0.852, 0); Main.Image = "rbxassetid://116118555895648"

local Options = Instance.new("ImageLabel", Drag)
Options.BackgroundTransparency = 1; Options.Position = UDim2.new(0.01, 0, 0.13, 0); Options.Size = UDim2.new(0.12, 0, 0.83, 0); Options.Image = "rbxassetid://78746999303808"
Instance.new("UIListLayout", Options).Padding = UDim.new(0, 5)

-- SISTEMA DE ABAS
local Tabs = {}
local function CreateTab(name)
    local S = Instance.new("ScrollingFrame", Main); S.Size = UDim2.new(1, 0, 1, 0); S.BackgroundTransparency = 1; S.Visible = false; S.AutomaticCanvasSize = 2; S.ScrollBarThickness = 2
    Instance.new("UIListLayout", S).Padding = UDim.new(0, 5)
    Tabs[name] = S
    local b = Instance.new("TextButton", Options); b.Size = UDim2.new(1, 0, 0.1, 0); b.BackgroundTransparency = 1; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.TextScaled = true
    b.MouseButton1Click:Connect(function() for _,v in pairs(Tabs) do v.Visible = false end S.Visible = true end)
    return S
end

-- ADD CHEAT COM TODAS AS TRAVAS
local function AddCheat(parent, name, placeholder, saveId, type, callback)
    local M = Instance.new("Frame", parent); M.Size = UDim2.new(0.95, 0, 0, 50); M.BackgroundTransparency = 0.8; M.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UICorner", M)
    local Lab = Instance.new("TextLabel", M); Lab.Size = UDim2.new(0.4, 0, 1, 0); Lab.Text = name; Lab.TextColor3 = Color3.new(1,1,1); Lab.BackgroundTransparency = 1; Lab.TextScaled = true; Lab.TextXAlignment = 0

    if type == "PowerWithHold" then
        -- Trava Power (170-230)
        local pB = Instance.new("TextBox", M); pB.Size = UDim2.new(0.14, 0, 0.6, 0); pB.Position = UDim2.new(0.42, 0, 0.2, 0); pB.Text = "230"; pB.BackgroundColor3 = Color3.new(0.1,0.1,0.1); pB.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", pB)
        pB.FocusLost:Connect(function()
            local v = tonumber(pB.Text)
            if not v then pB.Text = "230" elseif v > 230 then pB.Text = "230" elseif v < 170 then pB.Text = "170" end
            getgenv().RRR_Configs.Keys["PowerValue"] = pB.Text
        end)
        -- Trava Hold (Reset 0.47)
        local hB = Instance.new("TextBox", M); hB.Size = UDim2.new(0.14, 0, 0.6, 0); hB.Position = UDim2.new(0.57, 0, 0.2, 0); hB.Text = "0.5"; hB.BackgroundColor3 = Color3.new(0.1,0.1,0.1); hB.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", hB)
        hB.FocusLost:Connect(function()
            local v = tonumber(hB.Text)
            if hB.Text == "" or hB.Text == "." or not v then hB.Text = "0.47" elseif v < 0.2 then hB.Text = "0.2" end
            getgenv().RRR_Configs.Keys["HoldValue"] = hB.Text
        end)
        -- Botões True Padrão
        for i=1,2 do
            local sid = "PowerOption"..i
            local opt = Instance.new("TextButton", M); opt.Size = UDim2.new(0.06,0,0.4,0); opt.Position = UDim2.new(0.72 + (i*0.07), 0, 0.3, 0); opt.Text = ""; opt.BackgroundColor3 = Color3.new(0, 0.8, 0); Instance.new("UICorner", opt)
            opt.MouseButton1Click:Connect(function() getgenv().RRR_Configs.States[sid] = not getgenv().RRR_Configs.States[sid] opt.BackgroundColor3 = getgenv().RRR_Configs.States[sid] and Color3.new(0,0.8,0) or Color3.new(0.2,0.2,0.2) end)
        end
    elseif type == "Keybind" then
        -- Trava 1 Caracter
        local b = Instance.new("TextBox", M); b.Size = UDim2.new(0.2, 0, 0.6, 0); b.Position = UDim2.new(0.5, 0, 0.2, 0); b.Text = getgenv().RRR_Configs.Keys[saveId] or ""; b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", b)
        b:GetPropertyChangedSignal("Text"):Connect(function() if #b.Text > 1 then b.Text = b.Text:sub(1,1) end end)
        b.FocusLost:Connect(function() getgenv().RRR_Configs.Keys[saveId] = b.Text:upper() end)
    elseif type == "ButtonOnly" then
        local b = Instance.new("TextButton", M); b.Size = UDim2.new(0.3,0,0.7,0); b.Position = UDim2.new(0.55,0,0.15,0); b.Text = "EXEC"; b.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(callback)
    end

    if type ~= "ButtonOnly" then
        local sw = Instance.new("TextButton", M); sw.Size = UDim2.new(0.1,0,0.6,0); sw.Position = UDim2.new(0.88,0,0.2,0); sw.Text = "OFF"; sw.BackgroundColor3 = Color3.new(0.7,0,0); sw.TextColor3 = Color3.new(1,1,1); sw.TextScaled = true; Instance.new("UICorner", sw)
        sw.MouseButton1Click:Connect(function()
            local sid = (type == "PowerWithHold") and "PowerShotState" or (saveId.."State")
            getgenv().RRR_Configs.States[sid] = not getgenv().RRR_Configs.States[sid]
            sw.Text = getgenv().RRR_Configs.States[sid] and "ON" or "OFF"
            sw.BackgroundColor3 = getgenv().RRR_Configs.States[sid] and Color3.new(0,0.6,0) or Color3.new(0.7,0,0)
            if callback then callback(getgenv().RRR_Configs.States[sid]) end
        end)
    end
end

-- MONTAGEM ABAS
local Misc = CreateTab("Misc"); local PlayerTab = CreateTab("Player"); Misc.Visible = true
AddCheat(Misc, "PowerShot", "230", "PowerShot", "PowerWithHold")
AddCheat(Misc, "Auto Steal", "V", "KeySteal", "Keybind")
AddCheat(Misc, "Auto Goal", "G", "KeyAutoGoal", "Keybind")
AddCheat(PlayerTab, "Fake Flow", "", "Flow", "Toggle", function(s) player:SetAttribute("Flow", s) end)
AddCheat(PlayerTab, "Fake Meta", "", "Meta", "Toggle", function(s) player:SetAttribute("Metavision", s) end)
AddCheat(PlayerTab, "Team Select", "", "TS", "ButtonOnly", function() player.PlayerGui.TeamSelect.Enabled = true end)
AddCheat(PlayerTab, "CancelCutscene", "", "CC", "ButtonOnly", function()
    workspace.CurrentCamera.CameraSubject = player.Character.Humanoid; workspace.CurrentCamera.CameraType = 4
    for _, v in pairs(game.Players:GetPlayers()) do pcall(function() v.Character.Humanoid.Animator:GetPlayingAnimationTracks()[1]:Stop() end) end
end)

-- LÓGICA MOBILE (SEGURAR FLOWBUTTON 1S)
local hold = 0
FlowBtn.InputBegan:Connect(function(i) if i.UserInputType.Value == 8 or i.UserInputType.Value == 0 then hold = tick() end end)
FlowBtn.InputEnded:Connect(function() if tick() - hold >= 1 then Drag.Visible = not Drag.Visible end end)

-- INPUTS PC (Z, P)
UIS.InputBegan:Connect(function(i, g)
    if i.KeyCode == Enum.KeyCode.P then SelfDestruct() end 
    if not g and i.KeyCode == Enum.KeyCode.Z then Drag.Visible = not Drag.Visible end
end)

-- ARRASTE
local dIn, dS, sP
UpBar.InputBegan:Connect(function(i) if i.UserInputType.Value == 0 or i.UserInputType.Value == 7 then dIn = true; dS = i.Position; sP = Drag.Position end end)
UIS.InputChanged:Connect(function(i) if dIn and (i.UserInputType.Value == 4 or i.UserInputType.Value == 7) then 
    local delta = i.Position - dS; Drag.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
end end)
UIS.InputEnded:Connect(function() dIn = false end)
