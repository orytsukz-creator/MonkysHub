-- ==========================================
-- SERVICES
-- ==========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================
-- CONFIG
-- ==========================================

repeat task.wait() until getgenv().RRR_Config and getgenv().RRR_Config.Misc

local function getCfg()
    return getgenv().RRR_Config
end

-- ==========================================
-- ESTADO
-- ==========================================

local ativo = true

local segurandoM2 = false
local tempoM2 = 0
local disparoPendente = false

-- ==========================================
-- REMOTES
-- ==========================================

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- ==========================================
-- BASE
-- ==========================================

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart")
end

local function getBall()
    return workspace:FindFirstChild("Ball")
end

local function tpSeguro(pos)
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(pos)
end

-- ==========================================
-- MOBILE CACHE (SÓ BUTTON)
-- ==========================================

local MobileButtons = {}

task.spawn(function()
    task.wait(2)

    local pg = player:FindFirstChild("PlayerGui")
    local ms = pg and pg:FindFirstChild("MobileSupport")
    local frame = ms and ms:FindFirstChild("Frame")

    if frame then
        for _,v in pairs(frame:GetChildren()) do
            if v:IsA("GuiButton") and v.Name:sub(-6) == "Button" then
                MobileButtons[v.Name] = v
            end
        end
    end
end)

-- ==========================================
-- CHECK BIND (PC + MOBILE)
-- ==========================================

local function checkBind(input, action)
    local cfg = getCfg()
    if not (cfg and cfg.Misc and cfg.Misc[action] and cfg.Misc[action].Enabled) then
        return false
    end

    local key = tostring(cfg.Misc[action].Key)

    -- PC
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name == key
    end

    -- MOBILE
    if input.UserInputType == Enum.UserInputType.Touch then
        local objects = player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        for _,obj in pairs(objects) do
            if obj:IsA("GuiButton") and obj.Name == key then
                return true
            end
        end
    end

    return false
end

-- ==========================================
-- AUTO STEAL (FINAL FIX)
-- ==========================================

local function autoSteal()
    local hrp = getHRP()
    local ball = getBall()
    if not (hrp and ball) then return end

    local stateInicial = ball:GetAttribute("State")

    if stateInicial == player.Name then return end
    if stateInicial == "UNTOUCHABLE" then return end

    local oldPos = hrp.CFrame
    local startTime = tick()
    local deuTackle = false

    local function getPred()
        return ball.Position + (ball.AssemblyLinearVelocity * 0.15)
    end

    while ball and ball.Parent do
        if tick() - startTime > 1.2 then break end

        local stateAtual = ball:GetAttribute("State")

        if stateAtual == "UNTOUCHABLE" then
            deuTackle = true
            break
        end

        if stateAtual == player.Name then
            break
        end

        tpSeguro(getPred() + Vector3.new(0,2,0))
        Tackle:FireServer()

        local vel = ball.AssemblyLinearVelocity
        if vel.Magnitude > 5 then
            hrp.AssemblyLinearVelocity = vel.Unit * 90
        end

        task.wait(0.03)
    end

    if deuTackle then
        task.wait(0.05)
        if getHRP() then
            tpSeguro(oldPos.Position)
        end
    end
end

-- ==========================================
-- CHUTE FORTE
-- ==========================================

local function chuteForte()
    local hrp = getHRP()

    local dir = (
        camera.CFrame.LookVector * 310000 +
        (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000
    ).Unit

    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- AUTO GOL
-- ==========================================

local function chuteAutoGol()
    local hrp = getHRP()
    local ball = getBall()

    if not ball or ball:GetAttribute("State") ~= player.Name then return end

    local alvo = (player.Team and player.Team.Name == "Red")
        and Vector3.new(-2261, -25, 1030)
        or Vector3.new(-2848, -25, 1030)

    local dir = (alvo - hrp.Position).Unit

    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- POWERSHOT
-- ==========================================

local function startHold()
    local cfg = getCfg()
    if not (cfg.Misc.PowerShot and cfg.Misc.PowerShot.Enabled) then return end

    segurandoM2 = true
    tempoM2 = tick()
end

local function endHold()
    local cfg = getCfg()
    if not (segurandoM2 and cfg.Misc.PowerShot.Enabled) then return end

    local holdTime = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47

    if (tick() - tempoM2) >= holdTime then
        if disparoPendente then return end
        disparoPendente = true

        task.delay(0.01, function()
            for i = 1, 4 do
                chuteForte()
                task.wait(0.03)
            end
            disparoPendente = false
        end)
    end

    segurandoM2 = false
end

-- ==========================================
-- INPUT
-- ==========================================

UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not ativo then return end

    if checkBind(input, "AutoSteal") then
        autoSteal()
    end

    if checkBind(input, "AutoGoal") then
        chuteAutoGol()
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        startHold()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        endHold()
    end
end)

-- MOBILE SHOOT BUTTON (GARANTIDO)
task.spawn(function()
    task.wait(2)

    local btn = MobileButtons["ShootButton"]
    if btn then
        btn.MouseButton1Down:Connect(startHold)
        btn.MouseButton1Up:Connect(endHold)
    end
end)

-- ==========================================
-- LOOP
-- ==========================================

task.spawn(function()
    while task.wait(1) do
        local cfg = getCfg()
        if cfg and cfg.Player then
            pcall(function()
                player:SetAttribute("Flow", cfg.Player.FakeFlow)
                player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
            end)
        end
    end
end)

print(">> [RRR] MOBILE BUTTON FILTER ATIVO 🔥")
