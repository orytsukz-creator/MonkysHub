getgenv().Menu = getgenv().Menu or {}
getgenv().RRR_Configs = { States = {}, Keys = {} } 
local Menu = getgenv().Menu
local HttpService = game:GetService("HttpService")
local FILE_NAME = "RRR_Keybinds.json"

Menu.SavedKeys = {}

local function SaveConfig()
    if writefile then
        writefile(FILE_NAME, HttpService:JSONEncode(Menu.SavedKeys))
    end
end

if isfile and isfile(FILE_NAME) then
    pcall(function()
        Menu.SavedKeys = HttpService:JSONDecode(readfile(FILE_NAME))
    end)
end

if Menu.Gui then Menu.Gui:Destroy() end

local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR_Hub"
RRR.Parent = (gethui and gethui()) or game:GetService("CoreGui")
Menu.Gui = RRR

local Drag = Instance.new("ImageLabel", Menu.Gui)
Drag.Name = "Drag"
Drag.BackgroundTransparency = 1
Drag.Position = UDim2.new(0.3, 0, 0.3, 0)
Drag.Size = UDim2.new(0.47, 0, 0.465, 0)
Drag.Image = "rbxassetid://132146341566959"
Drag.Active = true

local Main = Instance.new("ImageLabel", Drag)
Main.Name = "Main"
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.152, 0, 0.118, 0)
Main.Size = UDim2.new(0.807, 0, 0.852, 0)
Main.Image = "rbxassetid://116118555895648"
Main.ImageTransparency = 0.2

local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Size = UDim2.new(1, 0, 0.2, 0)
UpBar.Position = UDim2.new(0, 0, -0.1, 0)
UpBar.BackgroundTransparency = 1
UpBar.Image = "rbxassetid://74857124519074"

local Title = Instance.new("TextLabel", UpBar)
Title.Size = UDim2.new(0.4, 0, 0.6, 0)
Title.Position = UDim2.new(0.05, 0, 0.2, 0)
Title.BackgroundTransparency = 1
Title.Text = "R.R.R HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.TextXAlignment = Enum.TextXAlignment.Left

local Minimize = Instance.new("ImageButton", UpBar)
Minimize.Size = UDim2.new(0.09, 0, 0.25, 0)
Minimize.Position = UDim2.new(0.88, 0, 0.36, 0)
Minimize.Image = "rbxassetid://138567149317610"
Minimize.BackgroundTransparency = 1

Minimize.MouseButton1Click:Connect(function() Drag.Visible = false end)

local Options = Instance.new("ImageLabel", Drag)
Options.Name = "Options"
Options.BackgroundTransparency = 1
Options.Position = UDim2.new(0.01, 0, 0.13, 0)
Options.Size = UDim2.new(0.12, 0, 0.83, 0)
Options.Image = "rbxassetid://78746999303808"

local UIListLayout_Opt = Instance.new("UIListLayout", Options)
UIListLayout_Opt.Padding = UDim.new(0, 5)

local Tabs = {}
local function CreateTab(name)
    local Scroller = Instance.new("ScrollingFrame", Main)
    Scroller.Name = name
    Scroller.Size = UDim2.new(1, 0, 1, 0)
    Scroller.BackgroundTransparency = 1
    Scroller.Visible = false
    Scroller.ScrollBarThickness = 2
    Scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", Scroller).Padding = UDim.new(0, 5)
    Tabs[name] = Scroller
    
    local Btn = Instance.new("TextButton", Options)
    Btn.Size = UDim2.new(1, 0, 0.1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        Scroller.Visible = true
    end)
    return Scroller
end

local MiscTab = CreateTab("Misc")
local PlayerTab = CreateTab("Player")
MiscTab.Visible = true

local function AddCheat(parent, name, placeholder, saveId, type)
    getgenv().RRR_Configs.States[saveId] = false
    getgenv().RRR_Configs.Keys[saveId] = Menu.SavedKeys[saveId] or ""

    local M = Instance.new("Frame", parent)
    M.Size = UDim2.new(0.98, 0, 0, 60)
    M.BackgroundTransparency = 0.8
    M.BackgroundColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", M)

    local Lab = Instance.new("TextLabel", M)
    Lab.Size = UDim2.new(0.35, 0, 1, 0)
    Lab.Text = name
    Lab.TextColor3 = Color3.new(1,1,1)
    Lab.BackgroundTransparency = 1
    Lab.TextScaled = true

    local Box
    if type ~= "ToggleOnly" then
        Box = Instance.new("TextBox", M)
        Box.Size = UDim2.new(0.25, 0, 0.5, 0)
        Box.Position = UDim2.new(0.4, 0, 0.25, 0)
        Box.Text = Menu.SavedKeys[saveId] or ""
        Box.PlaceholderText = placeholder
        Box.TextColor3 = Color3.fromRGB(255, 0, 0)
        Box.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        Instance.new("UICorner", Box)

        Box:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = Box.Text
            if type == "Keybind" then
                if #txt > 1 then Box.Text = txt:sub(1,1) end
                local prohibited = {"1","2","3","4","w","a","s","d"," "}
                for _, k in pairs(prohibited) do if txt:lower():find(k) then Box.Text = "" end end
            elseif type == "Number" then
                Box.Text = txt:gsub("%D", "") -- Remove tudo que não for número
                if #Box.Text > 3 then Box.Text = Box.Text:sub(1,3) end -- Máximo 3 dígitos
            end
        end)

        Box.FocusLost:Connect(function()
            Menu.SavedKeys[saveId] = Box.Text
            getgenv().RRR_Configs.Keys[saveId] = Box.Text
            SaveConfig()
        end)
    end

    local Btn = Instance.new("TextButton", M)
    Btn.Size = UDim2.new(0.2, 0, 0.5, 0)
    Btn.Position = UDim2.new(0.75, 0, 0.25, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    Btn.MouseButton1Click:Connect(function()
        Btn.Text = (Btn.Text == "OFF") and "ON" or "OFF"
        Btn.BackgroundColor3 = (Btn.Text == "ON") and Color3.new(0, 0.6, 0) or Color3.fromRGB(229, 0, 4)
        getgenv().RRR_Configs.States[saveId] = (Btn.Text == "ON")
    end)
end

-- CONFIGURAÇÃO DOS ITENS
AddCheat(MiscTab, "PowerShot", "230", "PowerValue", "Number")
AddCheat(MiscTab, "AutoSteal", "KEY", "KeySteal", "Keybind")
AddCheat(MiscTab, "AutoGoal", "KEY", "KeyAutoGoal", "Keybind")
AddCheat(MiscTab, "SpamTackle", "KEY", "KeyTackle", "Keybind")

AddCheat(PlayerTab, "Metavision", "", "Meta", "ToggleOnly")
AddCheat(PlayerTab, "Fake Flow", "", "Flow", "ToggleOnly")

local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Z then Drag.Visible = not Drag.Visible end
end)

task.spawn(function()
    local FlowButton = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport", 10):WaitForChild("Frame", 2):WaitForChild("FlowButton", 2)
    if FlowButton then
        local holdTime = 0
        FlowButton.MouseButton1Down:Connect(function() holdTime = tick() end)
        FlowButton.MouseButton1Up:Connect(function() if tick() - holdTime >= 3 then Drag.Visible = true end end)
    end
end)

-- Arrastar GUI
local dragging, dragStart, startPos
UpBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Drag.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Drag.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
