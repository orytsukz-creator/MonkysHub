-- RRR HUB V1.3 - COMPLETO
getgenv().Menu = getgenv().Menu or {}
getgenv().RRR_Configs = { States = {}, Keys = {} } 
getgenv().ScriptAtivoRRR = true -- Variável mestre de controle

local Menu = getgenv().Menu
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = game.Players.LocalPlayer
local FILE_NAME = "RRR_Keybinds.json"

Menu.SavedKeys = {}

-- Funções de Persistência
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

-- Limpeza de execução anterior
if Menu.Gui then Menu.Gui:Destroy() end

-- Criar a ScreenGui no CoreGui
local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR" 
RRR.Parent = (gethui and gethui()) or CoreGui
Menu.Gui = RRR

-- Estrutura Principal
local Drag = Instance.new("ImageLabel", RRR)
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

local Options = Instance.new("ImageLabel", Drag)
Options.Name = "Options"
Options.BackgroundTransparency = 1
Options.Position = UDim2.new(0.01, 0, 0.13, 0)
Options.Size = UDim2.new(0.12, 0, 0.83, 0)
Options.Image = "rbxassetid://78746999303808"

local UIListLayout_Opt = Instance.new("UIListLayout", Options)
UIListLayout_Opt.Padding = UDim.new(0, 5)

-- Gerenciador de Abas
local Tabs = {}
local function CreateTab(name)
    local Scroller = Instance.new("ScrollingFrame", Main)
    Scroller.Name = name
    Scroller.Size = UDim2.new(1, 0, 1, 0)
    Scroller.BackgroundTransparency = 1
    Scroller.Visible = false
    Scroller.ScrollBarThickness = 2
    Scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local Layout = Instance.new("UIListLayout", Scroller)
    Layout.Padding = UDim.new(0, 5)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
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

-- Função para criar os Cheats
local function AddCheat(parent, name, placeholder, saveId, type)
    getgenv().RRR_Configs.States[saveId] = false
    
    local M = Instance.new("Frame", parent)
    M.Size = UDim2.new(0.95, 0, 0, 60)
    M.BackgroundTransparency = 0.8
    M.BackgroundColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", M)

    local Lab = Instance.new("TextLabel", M)
    Lab.Size = UDim2.new(0.3, 0, 1, 0)
    Lab.Text = name
    Lab.TextColor3 = Color3.new(1,1,1)
    Lab.BackgroundTransparency = 1
    Lab.TextScaled = true

    -- Criação de TextBox (Power, Hold, Keybinds)
    local function CreateBox(posX, sizeX, pHolder, sId, isKey)
        local Box = Instance.new("TextBox", M)
        Box.Size = UDim2.new(sizeX, 0, 0.5, 0)
        Box.Position = UDim2.new(posX, 0, 0.25, 0)
        Box.Text = Menu.SavedKeys[sId] or ""
        Box.PlaceholderText = pHolder
        Box.TextColor3 = Color3.fromRGB(255, 0, 0)
        Box.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        Instance.new("UICorner", Box)

        Box:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = Box.Text
            if isKey == "Keybind" then
                if #txt > 1 then Box.Text = txt:sub(1,1) end
                local prohibited = {"1","2","3","4","w","a","s","d","p"," "} -- P agora é proibido no bind
                for _, k in pairs(prohibited) do if txt:lower():find(k) then Box.Text = "" end end
            else
                Box.Text = txt:gsub("[^%d%.]", "")
            end
        end)

        Box.FocusLost:Connect(function()
            Menu.SavedKeys[sId] = Box.Text
            getgenv().RRR_Configs.Keys[sId] = Box.Text
            SaveConfig()
        end)
        -- Inicializa a config global
        getgenv().RRR_Configs.Keys[sId] = Box.Text
    end

    -- Criação de Toggles de Opção (True/False do Shoot)
    local function CreateOption(posX, sId)
        local Opt = Instance.new("TextButton", M)
        Opt.Size = UDim2.new(0.08, 0, 0.4, 0)
        Opt.Position = UDim2.new(posX, 0, 0.3, 0)
        local savedState = Menu.SavedKeys[sId] or false
        getgenv().RRR_Configs.States[sId] = savedState
        
        Opt.BackgroundColor3 = savedState and Color3.new(0, 0.6, 0) or Color3.new(0.2, 0.2, 0.2)
        Opt.Text = ""
        Instance.new("UICorner", Opt)

        Opt.MouseButton1Click:Connect(function()
            local newState = not getgenv().RRR_Configs.States[sId]
            getgenv().RRR_Configs.States[sId] = newState
            Menu.SavedKeys[sId] = newState
            Opt.BackgroundColor3 = newState and Color3.new(0, 0.6, 0) or Color3.new(0.2, 0.2, 0.2)
            SaveConfig()
        end)
    end

    if type == "PowerWithHold" then
        CreateBox(0.32, 0.14, "Pwr", "PowerValue")
        CreateBox(0.48, 0.14, "Hold", "HoldValue")
        CreateOption(0.64, "PowerOption1") 
        CreateOption(0.73, "PowerOption2")
    elseif type == "Keybind" then
        CreateBox(0.4, 0.25, placeholder, saveId, "Keybind")
    end

    -- Botão ON/OFF Lateral
    local Btn = Instance.new("TextButton", M)
    Btn.Size = UDim2.new(0.15, 0, 0.5, 0)
    Btn.Position = UDim2.new(0.83, 0, 0.25, 0)
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

-- Adicionando os Itens
AddCheat(MiscTab, "PowerShot", "", "PowerShotState", "PowerWithHold")
AddCheat(MiscTab, "AutoSteal", "KEY", "KeySteal", "Keybind")
AddCheat(MiscTab, "AutoGoal", "KEY", "KeyAutoGoal", "Keybind")
AddCheat(MiscTab, "SpamTackle", "KEY", "KeyTackle", "Keybind")
AddCheat(PlayerTab, "Metavision", "", "Meta", "ToggleOnly")
AddCheat(PlayerTab, "Fake Flow", "", "Flow", "ToggleOnly")

-- Função de Parada Total (Tecla P)
local function FinalizarScript()
    getgenv().ScriptAtivoRRR = false
    if Menu.Gui then Menu.Gui:Destroy() end
    -- Reseta humanoide e atributos (Adicionais.lua fará o mesmo via variável global)
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 16 hum.JumpPower = 50 end
    player:SetAttribute("Flow", false)
    player:SetAttribute("Metavision", false)
    print("RRR HUB DESATIVADO.")
end

-- Inputs de Sistema (Z e P)
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then
        FinalizarScript()
    elseif not gpe and input.KeyCode == Enum.KeyCode.Z then
        Drag.Visible = not Drag.Visible
    end
end)

-- Sistema de Arrastar
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
