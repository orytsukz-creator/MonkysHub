-- // comandos.lua
-- // SINCRONIZADO COM RRR_HUB (UI)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Verifica se a config da UI existe
local function getCfg()
    return getgenv().RRR_Config
end

-- ==========================================
-- REMOTES E CONFIGS
-- ==========================================
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

local TRAVE_RED_1 = Vector3.new(-2907, -25, 1010)
local TRAVE_RED_2 = Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1 = Vector3.new(-2202, -25, 1010)
local TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

-- ==========================================
-- FUNÇÕES BASE
-- ==========================================
local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getBall()
    return workspace:FindFirstChild("Ball")
end

local function tpSeguro(pos)
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- ==========================================
-- LÓGICA DE CHUTE (DIR ABSURDO)
-- ==========================================
local function chuteForte()
    local hrp = getHRP()
    local cfg = getCfg()
    if not hrp or not cfg then return end

    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
    local eff1 = cfg.Misc.PowerShot.Effect
    local eff2 = cfg.Misc.PowerShot.Effect2

    local dir = (
        camera.CFrame.LookVector * 310000 +
        (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000
    ).Unit

    Shoot:FireServer(pwr, dir, dir, hrp.Position, eff1, eff2)
end

-- ==========================================
-- AUTO GOL (ALTURA PROGRESSIVA)
-- ==========================================
local function chuteAutoGol()
    local hrp = getHRP()
    local cfg = getCfg()
    if not hrp or not cfg then return end

    local alvo1, alvo2
    if player.Team and player.Team.Name == "Red" then
        alvo1, alvo2 = TRAVE_BLUE_1, TRAVE_BLUE_2
    else
        alvo1, alvo2 = TRAVE_RED_1, TRAVE_RED_2
    end

    local centro = (alvo1 + alvo2) / 2
    local ladoGol = (alvo2 - alvo1).Unit
    local relative = hrp.Position - centro
    local dot = relative:Dot(ladoGol)
    local alvoFinal = (dot > 0) and alvo1 or alvo2

    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude
    local horizontal = Vector3.new(delta.X, 0, delta.Z).Unit

    local altura
    if dist < 60 then
        altura = -1
    else
        local step20 = math.floor((dist - 60) / 20)
        local bonus80 = math.floor((dist - 60) / 80)
        local bonus160 = math.floor((dist - 60) / 160)
        local mult = 0.14 + (step20 * 0.01) + (bonus80 * 0.01) + (bonus160 * 0.01)
        altura = dist * mult
    end

    local dir = (horizontal + Vector3.new(0, altura / dist, 0)).Unit
    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230

    Shoot:FireServer(pwr, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

-- ==========================================
-- INPUTS (Sincronizado com Binds da UI)
-- ==========================================
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local cfg = getCfg()
    if not cfg then return end

    local hrp = getHRP()
    if not hrp then return end

    -- AUTO STEAL (Bind da UI)
    if input.KeyCode == Enum.KeyCode[cfg.Misc.AutoSteal.Key:upper()] and cfg.Misc.AutoSteal.Enabled then
        task.spawn(function()
            local ball = getBall()
            if not ball or ball:GetAttribute("State") == player.Name then return end

            local oldPos = hrp.CFrame
            Tackle:FireServer()
            local start = tick()
            local deuTackle = false

            while ball and ball.Parent and tick() - start < 1.2 do
                local state = ball:GetAttribute("State")
                if state == "UNTOUCHABLE" then deuTackle = true; break end
                if state == player.Name then break end

                tpSeguro(ball.Position + Vector3.new(0, 2, 0))
                if ball.AssemblyLinearVelocity.Magnitude > 5 then
                    hrp.AssemblyLinearVelocity = ball.AssemblyLinearVelocity.Unit * 90
                end
                task.wait(0.03)
            end
            if deuTackle then task.wait(0.05); tpSeguro(oldPos.Position) end
        end)
    end

    -- AUTO GOAL COMBO (Bind da UI)
    if input.KeyCode == Enum.KeyCode[cfg.Misc.AutoGoal.Key:upper()] and cfg.Misc.AutoGoal.Enabled then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            tpSeguro(ball.Position + Vector3.new(0, 2, 0))
            Tackle:FireServer()
            task.wait(0.2)
            local alvoTP = (player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
            tpSeguro(alvoTP)
            task.wait(0.8)
            chuteAutoGol()
        end)
    end
end)

-- ==========================================
-- SISTEMA M2 (HOLD DA UI)
-- ==========================================
local segurandoM2 = false
local tempoM2 = 0
local disparoPendente = false

CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local cfg = getCfg()
    if not cfg or not cfg.Misc.PowerShot.Enabled then return Enum.ContextActionResult.Pass end

    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local holdReq = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47
        
        if (tick() - tempoM2) >= holdReq then
            if disparoPendente then return end
            disparoPendente = true
            task.delay(0.01, function()
                for i = 1, 4 do chuteForte(); task.wait() end
                disparoPendente = false
            end)
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- LOOP FLOW / METAVISION
-- ==========================================
task.spawn(function()
    while true do
        task.wait(1)
        local cfg = getCfg()
        if cfg then
            if cfg.Player.FakeFlow then player:SetAttribute("Flow", true) end
            if cfg.Player.FakeMetavision then player:SetAttribute("Metavision", true) end
        end
    end
end)

print("✅ RRR_Comandos: Sincronizado com a UI!")
