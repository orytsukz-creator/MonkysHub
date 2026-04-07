-- // HubRRR.lua
-- // Interface com Bloqueio de Teclas Duplicadas e Salvamento JSON

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ConfigFile = "RRR_Settings.json"

-- // 1. CONFIGURAÇÕES E PERSISTÊNCIA
local DefaultConfig = {
    Misc = {
        AutoGoal = {Enabled = false, Key = "G"},
        AutoSteal = {Enabled = false, Key = "F"},
        PowerShot = {Enabled = false, Power = "230", Effect = false, Effect2 = false, HoldTime = "0.47"}
    },
    Player = {
        CancelCutscene = {Enabled = false, Key = "C"},
        FakeFlow = false,
        FakeMetavision = false
    }
}

if not getgenv().RRR_Config then
    getgenv().RRR_Config = DefaultConfig
end

local BlacklistedKeys = {
    ["W"] = true, ["A"] = true, ["S"] = true, ["D"] = true,
    ["Space"] = true, ["One"] = true, ["Two"] = true, 
    ["Three"] = true, ["Four"] = true, ["Unknown"] = true
}

local function Save()
    if writefile then 
        writefile(ConfigFile, HttpService:JSONEncode(getgenv().RRR_Config)) 
    end
end

local function Load()
    if isfile and isfile(ConfigFile) then
        local s, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if s then
            for cat, content in pairs(decoded) do
                if getgenv().RRR_Config[cat] then
                    for key, val in pairs(content) do 
                        getgenv().RRR_Config[cat][key] = val 
                    end
                end
            end
        end
    end
end
Load()

-- // 2. ESTRUTURA DA INTERFACE
local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR_Hub"
RRR.ResetOnSpawn = false
pcall(function() RRR.Parent = CoreGui end)
if not RRR.Parent then RRR.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
    pg.ScrollBarThickness = 2
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Main
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 8)
    return pg
end

local MiscPage = CreatePage()
local PlayerPage = CreatePage()
MiscPage.Visible = true

-- // 3. FUNÇÃO DE CHEAT (COM BLOQUEIO DE KEY REPETIDA)
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
    label.TextSize = 17
    label.Font = Enum.Font.SourceSansBold
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 25)
    btn.Position = UDim2.new(0.85, 0, 0.22, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = frame
    Instance.new("UICorner", btn)

    local function update()
        local data = getgenv().RRR_Config[category][configKey]
        local active = (type(data) == "table") and data.Enabled or data
        btn.Text = active and "ON" or "OFF"
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    end

    btn.MouseButton1Click:Connect(function()
        local data = getgenv().RRR_Config[category][configKey]
        if type(data) == "table" then data.Enabled = not data.Enabled else getgenv().RRR_Config[category][configKey] = not data end
        update()
        Save()
    end)

    if hasBind then
        local bBtn = Instance.new("TextButton")
        bBtn.Size = UDim2.new(0, 70, 0, 25)
        bBtn.Position = UDim2.new(0.55, 0, 0.22, 0)
        bBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        bBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bBtn.Text = getgenv().RRR_Config[category][configKey].Key or "NONE"
        bBtn.Parent = frame
        Instance.new("UICorner", bBtn)

        bBtn.MouseButton1Click:Connect(function()
            local old = bBtn.Text
            bBtn.Text = "..."
            local input = UserInputService.InputBegan:Wait()
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local newKey = input.KeyCode.Name
                
                -- Verificação de Duplicata
                local emUso = false
                for _, cat in pairs(getgenv().RRR_Config) do
                    if type(cat) == "table" then
                        for _, feat in pairs(cat) do
                            if type(feat) == "table" and feat.Key == newKey then emUso = true break end
                        end
                    end
                end

                if BlacklistedKeys[newKey] then
                    bBtn.Text = "BLOQUEADA"; task.wait(0.8); bBtn.Text = old
                elseif emUso then
                    bBtn.Text = "EM USO"; task.wait(0.8); bBtn.Text = old
                else
                    getgenv().RRR_Config[category][configKey].Key = newKey
                    bBtn.Text = newKey
                    Save()
                end
            else bBtn.Text = old end
        end)
    end
    update()
end

local function AddPowerShot(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 145)
    frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    Instance.new("UICorner", frame)

    local cheatLabel = Instance.new("TextLabel")
    cheatLabel.Text = "  Power Shot (Hold M2)"
    cheatLabel.Size = UDim2.new(0, 200, 0, 35)
    cheatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cheatLabel.BackgroundTransparency = 1
    cheatLabel.Font = Enum.Font.SourceSansBold
    cheatLabel.TextSize = 19
    cheatLabel.TextXAlignment = Enum.TextXAlignment.Left
    cheatLabel.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 40, 0, 22)
    box.Position = UDim2.new(0.7, 0, 0.05, 0)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    box.Text = getgenv().RRR_Config.Misc.PowerShot.Power
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = frame
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() getgenv().RRR_Config.Misc.PowerShot.Power = box.Text; Save() end)

    local box2 = Instance.new("TextBox")
    box2.Size = UDim2.new(0, 40, 0, 22)
    box2.Position = UDim2.new(0.85, 0, 0.05, 0)
    box2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    box2.Text = getgenv().RRR_Config.Misc.PowerShot.HoldTime
    box2.TextColor3 = Color3.fromRGB(255, 255, 255)
    box2.Parent = frame
    Instance.new("UICorner", box2)
    box2.FocusLost:Connect(function() getgenv().RRR_Config.Misc.PowerShot.HoldTime = box2.Text; Save() end)

    local function CreateRow(txt, y, key)
        local r = Instance.new("Frame")
        r.Size = UDim2.new(1, 0, 0, 30); r.Position = UDim2.new(0, 0, 0, y); r.BackgroundTransparency = 1; r.Parent = frame
        local l = Instance.new("TextLabel"); l.Text = "    " .. txt; l.Size = UDim2.new(0.5, 0, 1, 0); l.TextColor3 = Color3.fromRGB(220, 220, 220); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = r
        local function MkB(name, val, x)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 55, 0, 22); b.Position = UDim2.new(x, 0, 0.1, 0); b.Text = name; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Parent = r; Instance.new("UICorner", b)
            local function up() 
                local isSel = (getgenv().RRR_Config.Misc.PowerShot[key] == val)
                b.BackgroundColor3 = val and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
                b.BackgroundTransparency = isSel and 0 or 0.6
            end
            up()
            b.MouseButton1Click:Connect(function() getgenv().RRR_Config.Misc.PowerShot[key] = val; Save(); for _,v in pairs(r:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.6 end end; b.BackgroundTransparency = 0 end)
        end
        MkB("TRUE", true, 0.65); MkB("FALSE", false, 0.82)
    end
    CreateRow("Enabled Status:", 40, "Enabled")
    CreateRow("Apply Effect 1:", 75, "Effect")
    CreateRow("Apply Effect 2:", 110, "Effect2")
end

-- // 4. MONTAGEM
AddPowerShot(MiscPage)
AddCheat(MiscPage, "Auto Goal", "Misc", "AutoGoal", true)
AddCheat(MiscPage, "Auto Steal", "Misc", "AutoSteal", true)
AddCheat(PlayerPage, "Cancel Cutscene", "Player", "CancelCutscene", true)
AddCheat(PlayerPage, "Fake Flow", "Player", "FakeFlow", false)
AddCheat(PlayerPage, "Fake Metavision", "Player", "FakeMetavision", false)

-- // 5. SIDEBAR E TABS
local Side = Instance.new("Frame", Drag); Side.Size = UDim2.new(0.15, 0, 0.5, 0); Side.Position = UDim2.new(0.02, 0, 0.18, 0); Side.BackgroundTransparency = 1
Instance.new("UIListLayout", Side).Padding = UDim.new(0, 10)
local function MakeTab(t, p)
    local b = Instance.new("TextButton", Side); b.Size = UDim2.new(1, 0, 0, 30); b.Text = t; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.SourceSansBold; b.TextSize = 18; b.BackgroundTransparency = 0.8; b.BackgroundColor3 = Color3.fromRGB(255,255,255); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() MiscPage.Visible = (p == MiscPage); PlayerPage.Visible = (p == PlayerPage) end)
end
MakeTab("Misc", MiscPage); MakeTab("Player", PlayerPage)

-- // 6. DRAG E TOGGLE (Z)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Z then Drag.Visible = not Drag.Visible end end)
local dS, sP, dragging
Drag.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dS = i.Position; sP = Drag.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - dS; Drag.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

print("✅ RRR Hub Completa: Bloqueio de duplicatas e JSON salvando!")
