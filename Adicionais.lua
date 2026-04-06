-- // comandos.lua
-- // SINCRONIZADO: M2 ATIVO (HOLD DA UI) | SEM TECLA T

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getCfg()
    return getgenv().RRR_Config
end

-- ==========================================
-- CONFIG GOL E REMOTES
-- ==========================================
local TRAVE_RED_1 = Vector3.new(-2907, -25, 1010)
local TRAVE_RED_2 = Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1 = Vector3.new(-2202, -25, 1010)
local TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- ==========================================
-- FUNÇÕES DE APOIO
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
        hrp.CFrame = CFrame.new(pos)
    end
end

-- ==========================================
-- LÓGICA DE CHUTE (USA POWER DA UI)
-- ==========================================
local function executarChute()
    local hrp = getHRP()
    local cfg = getCfg()
    if not hrp or not cfg then return end

    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
    local dir = (
        camera.CFrame.LookVector * 310000 +
        (camera.CFrame.LookVector + Vector3.new(0, 0.14, 0)) * 10000000
    ).Unit

    Shoot:FireServer(pwr, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

local function chuteAutoGol()
    local hrp = getHRP()
    local cfg = getCfg()
    if not hrp or not cfg then return end

    local alvo1, alvo2 = (player.Team and player.Team.Name == "Red") and (TRAVE_BLUE_1, TRAVE_BLUE_2) or (TRAVE_RED_1, TRAVE_RED_2)
    local centro = (alvo1 + alvo2) / 2
    local alvoFinal = ((hrp.Position - centro):Dot((alvo2 - alvo1).Unit) > 0) and alvo1 or alvo2

    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude
    local horizontal = Vector3.new(delta.X, 0, delta.Z).Unit

    local altura = (dist < 60) and -1 or (dist * (0.14 + (math.floor((dist-60)/20)*0.01) + (math.floor((dist-60)/80)*0.01) + (math.floor((dist-60)/160)*0.01)))
    local dir = (horizontal + Vector3.new(0, altura / dist, 0)).Unit
    
    Shoot:FireServer(tonumber(cfg.Misc.PowerShot.Power) or 230, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

-- ==========================================
-- INPUTS E BINDS
-- ==========================================
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local cfg = getCfg()
    if not cfg then return end

    -- Auto Steal (Key da UI)
    if input.KeyCode == Enum.KeyCode[cfg.Misc.AutoSteal.Key:upper()] and cfg.Misc.AutoSteal.Enabled then
        task.spawn(function()
            local ball = getBall()
            if not ball or ball:GetAttribute("State") == player.Name then return end
            local oldPos = getHRP().CFrame
            Tackle:FireServer()
            local start = tick()
            while ball and tick() - start < 1.2 do
                if ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then break end
                tpSeguro(ball.Position + Vector3.new(0, 2, 0))
                task.wait(0.03)
            end
            tpSeguro(oldPos.Position)
        end)
    end

    -- Auto Goal Combo (Key da UI)
    if input.KeyCode == Enum.KeyCode[cfg.Misc.AutoGoal.Key:upper()] and cfg.Misc.AutoGoal.Enabled then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            tpSeguro(ball.Position + Vector3.new(0, 2, 0))
            Tackle:FireServer()
            task.wait(0.2)
            tpSeguro((player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED)
            task.wait(0.8)
            chuteAutoGol()
        end)
    end
end)

-- ==========================================
-- SISTEMA M2 (HOLD TIME DA UI)
-- ==========================================
local segurandoM2, tempoM2 = false, 0

CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local cfg = getCfg()
    if not cfg or not cfg.Misc.PowerShot.Enabled then return Enum.ContextActionResult.Pass end

    if state == Enum.UserInputState.Begin then
        segurandoM2, tempoM2 = true, tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        if (tick() - tempoM2) >= (tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47) then
            for i = 1, 4 do executarChute(); task.wait() end
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- Loop Flow/Meta
task.spawn(function()
    while task.wait(1) do
        local cfg = getCfg()
        if cfg then
            if cfg.Player.FakeFlow then player:SetAttribute("Flow", true) end
            if cfg.Player.FakeMetavision then player:SetAttribute("Metavision", true) end
        end
    end
end)

print("RRR Commands: M2 Sincronizado | Tecla T removida.")
