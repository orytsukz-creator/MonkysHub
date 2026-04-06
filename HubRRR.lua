local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local ConfigFile = "RRR_Settings.json"

-- // 1. ESTRUTURA DE DADOS (Exatamente como o Comandos.lua lê)
getgenv().RRR_Config = {
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

local function Save()
    if writefile then writefile(ConfigFile, HttpService:JSONEncode(getgenv().RRR_Config)) end
end

-- // 2. INTERFACE VISUAL (VOLTANDO AO SEU DESIGN)
local RRR = Instance.new("ScreenGui", CoreGui)
RRR.Name = "RRR_Hub"

local Drag = Instance.new("ImageLabel", RRR)
Drag.Size = UDim2.new(0, 520, 0, 350)
Drag.Position = UDim2.new(0.5, -260, 0.5, -175)
Drag.Image = "rbxassetid://132146341566959" -- Seu fundo original
Drag.BackgroundTransparency = 1
Drag.Active = true
Drag.Draggable = true

local Main = Instance.new("ImageLabel", Drag)
Main.Size = UDim2.new(0.78, 0, 0.82, 0)
Main.Position = UDim2.new(0.18, 0, 0.14, 0)
Main.Image = "rbxassetid://116118555895648" -- Sua moldura original
Main.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -20)
Scroll.Position = UDim2.new(0, 10, 0, 10)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 0
local layout = Instance.new("UIListLayout", Scroll)
layout.Padding = UDim.new(0, 10)

-- // 3. FUNÇÃO DE CRIAÇÃO (MANTENDO SEU ESTILO)
local function AddCheat(name, category, key, hasBind)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Text = name
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = "Left"
    lbl.Font = Enum.Font.GothamBold

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(0.85, 0, 0.2, 0)
    
    if hasBind then
        local bind = Instance.new("TextButton", frame)
        bind.Size = UDim2.new(0, 40, 0, 22)
        bind.Position = UDim2.new(0.7, 0, 0.2, 0)
        bind.Text = getgenv().RRR_Config[category][key].Key
        bind.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        bind.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        bind.MouseButton1Click:Connect(function()
            bind.Text = "..."
            local input = UIS.InputBegan:Wait()
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                getgenv().RRR_Config[category][key].Key = input.KeyCode.Name
                bind.Text = input.KeyCode.Name; Save()
            end
        end)
    end

    local function refresh()
        local state = getgenv().RRR_Config[category][key].Enabled
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    end

    btn.MouseButton1Click:Connect(function()
        getgenv().RRR_Config[category][key].Enabled = not getgenv().RRR_Config[category][key].Enabled
        refresh(); Save()
    end)
    refresh()
end

-- // 4. INPUTS DE TEXTO (PARA PODER MUDAR O POWER)
local function AddInput(name, category, key, subkey)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Text = name
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = "Left"

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0, 70, 0, 22)
    box.Position = UDim2.new(0.8, 0, 0.2, 0)
    box.Text = getgenv().RRR_Config[category][key][subkey]
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    box.FocusLost:Connect(function()
        getgenv().RRR_Config[category][key][subkey] = box.Text; Save()
    end)
end

-- // 5. RECONSTRUINDO OS BOTÕES NA ORDEM CERTA
AddCheat("Auto Goal", "Misc", "AutoGoal", true)
AddCheat("Auto Steal", "Misc", "AutoSteal", true)
AddCheat("Power Shot (M2)", "Misc", "PowerShot", false)
AddInput("Set Power:", "Misc", "PowerShot", "Power")
AddInput("M2 Hold Time:", "Misc", "PowerShot", "HoldTime")

-- // BOTÕES DE FLOW/META (SIMPLIFICADOS)
local function AddSimpleToggle(name, category, key)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().RRR_Config[category][key] = not getgenv().RRR_Config[category][key]
        btn.Text = name .. (getgenv().RRR_Config[category][key] and ": ON" or ": OFF")
        Save()
    end)
end

AddSimpleToggle("Fake Flow", "Player", "FakeFlow")
AddSimpleToggle("Fake Metavision", "Player", "FakeMetavision")

print("RRR Hub: Visual antigo restaurado e sincronizado!")
