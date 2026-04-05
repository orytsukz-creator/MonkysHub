-- RRR HUB V1.6 - FINAL (Title & Minimize Fix)
getgenv().RRR_Configs = getgenv().RRR_Configs or { States = {}, Keys = {} }
getgenv().ScriptAtivoRRR = true

local Menu = { Gui = nil, SavedKeys = {} }
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local FILE_NAME = "RRR_Keybinds.json"

-- Save/Load
if isfile and isfile(FILE_NAME) then
    pcall(function() Menu.SavedKeys = HttpService:JSONDecode(readfile(FILE_NAME)) end)
end
local function SaveConfig()
    if writefile then writefile(FILE_NAME, HttpService:JSONEncode(Menu.SavedKeys)) end
end

if CoreGui:FindFirstChild("RRR") then CoreGui.RRR:Destroy() end

local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR" 
RRR.Parent = (gethui and gethui()) or CoreGui
Menu.Gui = RRR

-- Container Principal (Drag)
local Drag = Instance.new("ImageLabel", RRR)
Drag.Name = "Drag"
Drag.BackgroundTransparency = 1
Drag.Position = UDim2.new(0.3, 0, 0.3, 0)
Drag.Size = UDim2.new(0.47, 0, 0.465, 0)
Drag.Image = "rbxassetid://132146341566959"
Drag.Active = true

-- Barra Superior (UpBar)
local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Name = "UpBar"
UpBar.Size = UDim2.new(1, 0, 0.2, 0)
UpBar.Position = UDim2.new(0, 0, -0.1, 0)
UpBar.BackgroundTransparency = 1
UpBar.Image = "rbxassetid://74857124519074"

-- TÍTULO DA HUB
local Title = Instance.new("TextLabel", UpBar)
Title.Name = "Title"
Title.Size = UDim2.new(0.5, 0, 0.6, 0)
Title.Position = UDim2.new(0.05, 0, 0.2, 0)
Title.BackgroundTransparency = 1
Title.Text = "R.R.R HUB - v1.6"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.TextXAlignment = Enum.TextXAlignment.Left

-- BOTÃO MINIMIZAR
local MinimizeBtn = Instance.new("TextButton", UpBar)
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0.08, 0, 0.6, 0)
MinimizeBtn.Position = UDim2.new(0.88, 0, 0.2, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.TextScaled = true
Instance.new("UICorner", MinimizeBtn)

-- Conteúdo Principal (Main e Options)
local Main = Instance.new("ImageLabel", Drag)
Main.Name = "Main"
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.152, 0, 0.118, 0)
Main.Size = UDim2.new(0.807, 0, 0.852, 0)
Main.Image = "rbxassetid://116118555895648"
Main.ImageTransparency = 0.2

local Options = Instance.new("ImageLabel", Drag)
Options.Name = "Options"
Options.BackgroundTransparency = 1
Options.Position = UDim2.new(0.01, 0, 0.13, 0)
Options.Size = UDim2.new(0.12, 0, 0.83, 0)
Options.Image = "rbxassetid://78746999303808"
Instance.new("UIListLayout", Options).Padding = UDim.new(0, 5)

-- Lógica do Botão Minimizar
MinimizeBtn.MouseButton1Click:Connect(function()
    local targetVisible = not Main.Visible
    Main.Visible = targetVisible
    Options.Visible = targetVisible
    MinimizeBtn.Text = targetVisible and "-" or "+"
end)

-- [Restante das funções: CreateTab e AddCheat seguem iguais à V1.5]
-- ... (Aqui você insere o código das abas e cheats que mandei anteriormente) ...

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

-- Re-adicionando as abas e botões
local MiscTab = CreateTab("Misc")
local PlayerTab = CreateTab("Player")
MiscTab.Visible = true

-- [A função AddCheat (V1.5) deve vir aqui antes das chamadas abaixo]

-- (Exemplo rápido da chamada do AddCheat para confirmar que o Título/Minimizar não quebrou nada)
-- AddCheat(MiscTab, "PowerShot", "", "PowerShotState", "PowerWithHold")
-- ... (Continue com seus AddCheats aqui) ...

-- DRAG SYSTEM (Mouse & Touch)
local dragging, dragStart, startPos
UpBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Drag.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Drag.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function() dragging = false end)

-- Teclas de Pânico
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then
        getgenv().ScriptAtivoRRR = false
        if Menu.Gui then Menu.Gui:Destroy() end
    elseif not gpe and input.KeyCode == Enum.KeyCode.Z then
        Drag.Visible = not Drag.Visible
    end
end)
