-- RRR HUB V1 - PADRÃO TRUE NAS OPÇÕES
getgenv().RRR_Configs = { 
    States = {
        ["PowerOption1"] = true, -- Padrão True
        ["PowerOption2"] = true  -- Padrão True
    }, 
    Keys = {["PowerValue"] = "230", ["HoldValue"] = "0.47"} 
}

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local FILE_NAME = "RRR_V1_Save.json"

local function Save() if writefile then writefile(FILE_NAME, HttpService:JSONEncode(getgenv().RRR_Configs.Keys)) end end
if isfile and isfile(FILE_NAME) then pcall(function() local data = HttpService:JSONDecode(readfile(FILE_NAME)) for k,v in pairs(data) do getgenv().RRR_Configs.Keys[k] = v end end) end

if CoreGui:FindFirstChild("RRR") then CoreGui.RRR:Destroy() end
local RRR = Instance.new("ScreenGui", CoreGui); RRR.Name = "RRR"

local Drag = Instance.new("ImageLabel", RRR)
Drag.Name = "Drag"; Drag.BackgroundTransparency = 1; Drag.Position = UDim2.new(0.3, 0, 0.3, 0); Drag.Size = UDim2.new(0.47, 0, 0.465, 0); Drag.Image = "rbxassetid://132146341566959"; Drag.Active = true

local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Size = UDim2.new(1, 0, 0.2, 0); UpBar.Position = UDim2.new(0, 0, -0.1, 0); UpBar.BackgroundTransparency = 1; UpBar.Image = "rbxassetid://74857124519074"

local Title = Instance.new("TextLabel", UpBar)
Title.Size = UDim2.new(0.5, 0, 0.6, 0); Title.Position = UDim2.new(0.05, 0, 0.2, 0); Title.BackgroundTransparency = 1; Title.Text = "R.R.R HUB - V1"; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextScaled = true; Title.TextXAlignment = 0

local Main = Instance.new("ImageLabel", Drag)
Main.BackgroundTransparency = 1; Main.Position = UDim2.new(0.152, 0, 0.118, 0); Main.Size = UDim2.new(0.807, 0, 0.852, 0); Main.Image = "rbxassetid://116118555895648"

local Options = Instance.new("ImageLabel", Drag)
Options.BackgroundTransparency = 1; Options.Position = UDim2.new(0.01, 0, 0.13, 0); Options.Size = UDim2.new(0.12, 0, 0.83, 0); Options.Image = "rbxassetid://78746999303808"
Instance.new("UIListLayout", Options)

local Tabs = {}
local function CreateTab(name)
    local S = Instance.new("ScrollingFrame", Main); S.Size = UDim2.new(1, 0, 1, 0); S.BackgroundTransparency = 1; S.Visible = false; S.AutomaticCanvasSize = 2
    Instance.new("UIListLayout", S).Padding = UDim.new(0, 5)
    Tabs[name] = S
    local b = Instance.new("TextButton", Options); b.Size = UDim2.new(1, 0, 0.1, 0); b.BackgroundTransparency = 1; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.TextScaled = true
    b.MouseButton1Click:Connect(function() for _,v in pairs(Tabs) do v.Visible = false end S.Visible = true end)
    return S
end

local function AddCheat(parent, name, placeholder, saveId, type, callback)
    local M = Instance.new("Frame", parent); M.Size = UDim2.new(0.95, 0, 0, 50); M.BackgroundTransparency = 0.8; M.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UICorner", M)
    local Lab = Instance.new("TextLabel", M); Lab.Size = UDim2.new(0.4, 0, 1, 0); Lab.Text = name; Lab.TextColor3 = Color3.new(1,1,1); Lab.BackgroundTransparency = 1; Lab.TextScaled = true; Lab.TextXAlignment = 0

    if type == "PowerWithHold" then
        local function box(posX, sId)
            local b = Instance.new("TextBox", M); b.Size = UDim2.new(0.14, 0, 0.6, 0); b.Position = UDim2.new(posX, 0, 0.2, 0); b.Text = getgenv().RRR_Configs.Keys[sId] or ""
            b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", b)
            b.FocusLost:Connect(function() getgenv().RRR_Configs.Keys[sId] = b.Text Save() end)
        end
        box(0.42, "PowerValue"); box(0.57, "HoldValue")
        
        -- OS DOIS BOTÕES QUE COMEÇAM TRUE
        for i=1,2 do
            local sId = "PowerOption"..i
            local opt = Instance.new("TextButton", M)
            opt.Size = UDim2.new(0.06,0,0.4,0); opt.Position = UDim2.new(0.72 + (i*0.07), 0, 0.3, 0); opt.Text = ""
            opt.BackgroundColor3 = Color3.new(0, 0.8, 0) -- Verde (True)
            Instance.new("UICorner", opt)
            opt.MouseButton1Click:Connect(function()
                getgenv().RRR_Configs.States[sId] = not getgenv().RRR_Configs.States[sId]
                opt.BackgroundColor3 = getgenv().RRR_Configs.States[sId] and Color3.new(0,0.8,0) or Color3.new(0.2,0.2,0.2)
            end)
        end
    elseif type == "Keybind" then
        local b = Instance.new("TextBox", M); b.Size = UDim2.new(0.2, 0, 0.6, 0); b.Position = UDim2.new(0.5, 0, 0.2, 0); b.Text = getgenv().RRR_Configs.Keys[saveId] or ""; b.PlaceholderText = placeholder
        b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", b)
        b.FocusLost:Connect(function() getgenv().RRR_Configs.Keys[saveId] = b.Text Save() end)
    end

    if type ~= "ButtonOnly" then
        local sw = Instance.new("TextButton", M); sw.Size = UDim2.new(0.1,0,0.6,0); sw.Position = UDim2.new(0.88,0,0.2,0); sw.Text = "OFF"; sw.BackgroundColor3 = Color3.new(0.7,0,0); sw.TextColor3 = Color3.new(1,1,1); sw.TextScaled = true; Instance.new("UICorner", sw)
        sw.MouseButton1Click:Connect(function()
            getgenv().RRR_Configs.States[saveId] = not getgenv().RRR_Configs.States[saveId]
            sw.Text = getgenv().RRR_Configs.States[saveId] and "ON" or "OFF"
            sw.BackgroundColor3 = getgenv().RRR_Configs.States[saveId] and Color3.new(0,0.6,0) or Color3.new(0.7,0,0)
        end)
    end
end

local Misc = CreateTab("Misc"); Misc.Visible = true
AddCheat(Misc, "PowerShot", "Pwr", "PowerShotState", "PowerWithHold")
AddCheat(Misc, "AutoSteal", "KEY", "KeySteal", "Keybind")
AddCheat(Misc, "AutoGoal", "KEY", "KeyAutoGoal", "Keybind")

-- Drag
local dragIn, dragS, startP
UpBar.InputBegan:Connect(function(i) if i.UserInputType.Value == 0 or i.UserInputType.Value == 7 then dragIn = true; dragS = i.Position; startP = Drag.Position end end)
UIS.InputChanged:Connect(function(i) if dragIn and (i.UserInputType.Value == 4 or i.UserInputType.Value == 7) then 
    local delta = i.Position - dragS; Drag.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y)
end end)
UIS.InputEnded:Connect(function() dragIn = false end)
