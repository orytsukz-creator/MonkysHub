local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ConfigFile = "RRR_Settings.json"

-- // 1. CONFIGURAÇÃO INICIAL (Sincronizada com Comandos.lua)
local DefaultConfig = {
    Misc = {
        AutoGoal = {Enabled = false, Key = "G"},
        AutoSteal = {Enabled = false, Key = "F"},
        PowerShot = {Enabled = false, Power = "230", Effect = true, Effect2 = true, HoldTime = "0.47"}
    },
    Player = {
        FakeFlow = false,
        FakeMetavision = false
    }
}
getgenv().RRR_Config = DefaultConfig

local function Save()
    if writefile then writefile(ConfigFile, HttpService:JSONEncode(getgenv().RRR_Config)) end
end

local function Load()
    if isfile and isfile(ConfigFile) then
        local s, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if s then
            for cat, content in pairs(decoded) do
                if getgenv().RRR_Config[cat] then
                    for key, val in pairs(content) do getgenv().RRR_Config[cat][key] = val end
                end
            end
        end
    end
end
Load()

-- // 2. INTERFACE PRINCIPAL
local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR_Hub"
RRR.Parent = CoreGui

local Drag = Instance.new("ImageLabel")
Drag.Size = UDim2.new(0, 520, 0, 350)
Drag.Position = UDim2.new(0.5, -260, 0.5, -175)
Drag.Image = "rbxassetid://132146341566959" -- Sua asset de fundo
Drag.BackgroundTransparency = 1
Drag.Active = true
Drag.Draggable = true
Drag.Parent = RRR

local Main = Instance.new("ImageLabel")
Main.Size = UDim2.new(0.78, 0, 0.82, 0)
Main.Position = UDim2.new(0.18, 0, 0.14, 0)
Main.Image = "rbxassetid://116118555895648"
Main.BackgroundTransparency = 1
Main.Parent = Drag

-- // 3. SISTEMA DE ABAS
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -10, 1, -10)
Content.Position = UDim2.new(0, 5, 0, 5)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreatePage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.Visible = false
    pg.ScrollBarThickness = 2
    pg.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    pg.Parent = Content
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 5)
    return pg
end

local MiscPage = CreatePage()
local PlayerPage = CreatePage()
MiscPage.Visible = true

-- // 4. COMPONENTES DE UI
local function AddToggle(parent, text, category, configKey, hasBind)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel")
    label.Text = "  " .. text
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.Position = UDim2.new(0.85, 0, 0.2, 0)
    btn.Parent = frame
    Instance.new("UICorner", btn)

    if hasBind then
        local bBtn = Instance.new("TextButton")
        bBtn.Size = UDim2.new(0, 50, 0, 25)
        bBtn.Position = UDim2.new(0.7, 0, 0.2, 0)
        bBtn.Text = getgenv().RRR_Config[category][configKey].Key
        bBtn.Parent = frame
        bBtn.MouseButton1Click:Connect(function()
            bBtn.Text = "..."
            local input = UIS.InputBegan:Wait()
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                getgenv().RRR_Config[category][configKey].Key = input.KeyCode.Name
                bBtn.Text = input.KeyCode.Name; Save()
            end
        end)
    end

    local function update()
        local enabled = getgenv().RRR_Config[category][configKey].Enabled
        btn.Text = enabled and "ON" or "OFF"
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    end

    btn.MouseButton1Click:Connect(function()
        getgenv().RRR_Config[category][configKey].Enabled = not getgenv().RRR_Config[category][configKey].Enabled
        update(); Save()
    end)
    update()
end

local function AddInput(parent, text, category, configKey, subKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = "  " .. text
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 80, 0, 25)
    box.Position = UDim2.new(0.8, 0, 0.2, 0)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    box.Text = getgenv().RRR_Config[category][configKey][subKey]
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = frame
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() 
        getgenv().RRR_Config[category][configKey][subKey] = box.Text; Save() 
    end)
end

-- // 5. MONTAGEM DAS PÁGINAS
-- MISC
AddToggle(MiscPage, "Auto Goal", "Misc", "AutoGoal", true)
AddToggle(MiscPage, "Auto Steal", "Misc", "AutoSteal", true)
AddToggle(MiscPage, "Power Shot (M2)", "Misc", "PowerShot", false)
AddInput(MiscPage, "Shoot Power:", "Misc", "PowerShot", "Power")
AddInput(MiscPage, "Hold Time (M2):", "Misc", "PowerShot", "HoldTime")

-- PLAYER
AddToggle(PlayerPage, "Fake Flow", "Player", "FakeFlow", false) -- Aqui simplifiquei o toggle para Player
AddToggle(PlayerPage, "Fake Metavision", "Player", "FakeMetavision", false)

-- // 6. BOTÕES DE ABA (LATERAL)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0.15, 0, 0.8, 0)
Sidebar.Position = UDim2.new(0.02, 0, 0.15, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Drag
local layout = Instance.new("UIListLayout", Sidebar)
layout.Padding = UDim.new(0, 10)

local function TabBtn(txt, page)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Parent = Sidebar
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        MiscPage.Visible = false
        PlayerPage.Visible = false
        page.Visible = true
    end)
end
TabBtn("Misc", MiscPage)
TabBtn("Player", PlayerPage)

print("RRR HUB: Interface Completa carregada!")
