local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ConfigFile = "RRR_Settings.json"

-- // 1. Configurações Padrão
local DefaultConfig = {
    Misc = {
        AutoGoal = {Enabled = false, Key = "G"},
        AutoSteal = {Enabled = false, Key = "F"},
        PowerShot = {Enabled = false, Power = "0.47", Effect = false, Effect2 = false}
    },
    Player = {
        CancelCutscene = {Enabled = false, Key = "C"},
        FakeFlow = false,
        FakeMetavision = false
    }
}
getgenv().RRR_Config = DefaultConfig

local BlacklistedKeys = {
    ["W"] = true, ["A"] = true, ["S"] = true, ["D"] = true,
    ["Space"] = true, ["One"] = true, ["Two"] = true, 
    ["Three"] = true, ["Four"] = true
}

-- // 2. Persistência
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

-- // 3. UI Base
local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR_Hub"
RRR.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local Drag = Instance.new("ImageLabel")
Drag.Size = UDim2.new(0, 520, 0, 350)
Drag.Position = UDim2.new(0.5, -260, 0.5, -175)
Drag.Image = "rbxassetid://132146341566959"
Drag.BackgroundTransparency = 1
Drag.Active = true
Drag.Parent = RRR

local Main = Instance.new("ImageLabel")
Main.Size = UDim2.new(0.78, 0, 0.82, 0)
Main.Position = UDim2.new(0.18, 0, 0.14, 0)
Main.Image = "rbxassetid://116118555895648"
Main.BackgroundTransparency = 1
Main.Parent = Drag

local function CreatePage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -10)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Main
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 8)
    return pg
end

local MiscPage = CreatePage()
local PlayerPage = CreatePage()
MiscPage.Visible = true

-- // 4. Componentes
local function AddCheat(parent, text, category, configKey, hasBind)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel")
    label.Text = "  " .. text
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 18
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0.7, 0)
    btn.Position = UDim2.new(0.82, 0, 0.15, 0)
    btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    if hasBind then
        local bindBtn = Instance.new("TextButton")
        bindBtn.Size = UDim2.new(0, 75, 0, 25)
        bindBtn.Position = UDim2.new(0.53, 0, 0.22, 0)
        bindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local currentKey = getgenv().RRR_Config[category][configKey].Key or "NONE"
        bindBtn.Text = tostring(currentKey)
        bindBtn.Parent = frame
        Instance.new("UICorner", bindBtn)

        bindBtn.MouseButton1Click:Connect(function()
            local old = bindBtn.Text
            bindBtn.Text = "..."
            local input = UserInputService.InputBegan:Wait()
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local kn = input.KeyCode.Name
                if BlacklistedKeys[kn] then
                    bindBtn.Text = "Bloqueado"; task.wait(1); bindBtn.Text = old
                else
                    getgenv().RRR_Config[category][configKey].Key = kn
                    bindBtn.Text = kn; Save()
                end
            end
        end)
    end

    local function update()
        local val = getgenv().RRR_Config[category][configKey]
        if type(val) == "table" then val = val.Enabled end
        btn.Text = val and "ON" or "OFF"
        btn.BackgroundColor3 = val and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end
    update()

    btn.MouseButton1Click:Connect(function()
        local d = getgenv().RRR_Config[category][configKey]
        if type(d) == "table" then d.Enabled = not d.Enabled else getgenv().RRR_Config[category][configKey] = not d end
        update(); Save()
    end)
end

-- // Módulo Power Shot (Atualizado com Nome e botões TRUE/FALSE)
local function AddPowerShot(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 145)
    frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    Instance.new("UICorner", frame)

    -- Nome do Cheat que estava faltando
    local cheatLabel = Instance.new("TextLabel")
    cheatLabel.Text = "  Power Shot"
    cheatLabel.Size = UDim2.new(0, 150, 0, 35)
    cheatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cheatLabel.BackgroundTransparency = 1
    cheatLabel.Font = Enum.Font.SourceSansBold
    cheatLabel.TextSize = 20
    cheatLabel.TextXAlignment = Enum.TextXAlignment.Left
    cheatLabel.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 65, 0, 25)
    box.Position = UDim2.new(0.82, 0, 0.05, 0)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    box.Text = getgenv().RRR_Config.Misc.PowerShot.Power
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 14
    box.Parent = frame
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() getgenv().RRR_Config.Misc.PowerShot.Power = box.Text; Save() end)

    local function CreateRow(txt, y, key)
        local r = Instance.new("Frame")
        r.Size = UDim2.new(1, 0, 0, 30)
        r.Position = UDim2.new(0, 0, 0, y)
        r.BackgroundTransparency = 1
        r.Parent = frame
        
        local l = Instance.new("TextLabel")
        l.Text = "    " .. txt
        l.Size = UDim2.new(0.5, 0, 1, 0)
        l.TextColor3 = Color3.fromRGB(220, 220, 220)
        l.BackgroundTransparency = 1
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = r
        
        local function MkB(name, value, x)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 60, 0, 25)
            b.Position = UDim2.new(x, 0, 0.1, 0)
            b.Text = name -- Aqui agora é "TRUE" ou "FALSE"
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.TextSize = 12
            b.Parent = r
            Instance.new("UICorner", b)
            
            local function up()
                local isActive = (getgenv().RRR_Config.Misc.PowerShot[key] == value)
                b.BackgroundColor3 = value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
                b.BackgroundTransparency = isActive and 0 or 0.7
            end
            up()
            b.MouseButton1Click:Connect(function() 
                getgenv().RRR_Config.Misc.PowerShot[key] = value
                Save()
                for _,v in pairs(r:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.7 end end
                b.BackgroundTransparency = 0
            end)
        end
        MkB("TRUE", true, 0.65)
        MkB("FALSE", false, 0.82)
    end

    CreateRow("Enabled Status:", 40, "Enabled")
    CreateRow("Apply Effect 1:", 75, "Effect")
    CreateRow("Apply Effect 2:", 110, "Effect2")
end

-- // 5. Montagem Final
AddPowerShot(MiscPage)
AddCheat(MiscPage, "Auto Goal", "Misc", "AutoGoal", true)
AddCheat(MiscPage, "Auto Steal", "Misc", "AutoSteal", true)
AddCheat(PlayerPage, "Cancel Cutscene", "Player", "CancelCutscene", true)
AddCheat(PlayerPage, "Fake Flow", "Player", "FakeFlow", false)
AddCheat(PlayerPage, "Fake Metavision", "Player", "FakeMetavision", false)

-- Restante da UI (Barra Superior, Tabs, Mobile Toggle, Drag) permanece igual ao anterior...
-- [Omitido para encurtar, mas use a lógica de Toggle e Drag que já enviamos]
