-- // comandos.lua
-- // VERSÃO FINAL: SINCRONIA TOTAL COM RRR_HUB

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // Função mestre de sincronia
local function getCfg()
    return getgenv().RRR_Config
end

-- ==========================================
-- REMOTES E POSIÇÕES (ESTÁTICO)
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
-- FUNÇÕES DE UTILIDADE
-- ==========================================
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
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
-- LÓGICA DE CHUTE (POWER SHOT)
-- ==========================================
local function executarChuteForte()
    local hrp = getHRP()
    local cfg = getCfg()
    if not hrp or not cfg then return end

    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
    local eff1 = cfg.Misc.PowerShot.Effect
    local eff2 = cfg.Misc.PowerShot.Effect2

    -- Direção "Absurda" solicitada
    local dir = (
        camera.CFrame.LookVector * 310000 +
        (camera.CFrame.LookVector + Vector3.new(0, 0.14, 0)) * 10000000
    ).Unit

    Shoot:FireServer(pwr, dir, dir, hrp.Position, eff1, eff2)
end

-- ==========================================
-- AUTO GOL (ALTURA PROGRESSIVA + CORREÇÃO)
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

    -- Cálculo de Altura Progressiva
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

    -- Correção de altura se estiver no ar
    local alturaDoChao = hrp.Position.Y + 25
    if alturaDoChao > 0 then
        local reducao = 1 - math.clamp((alturaDoChao / 20), 0, 0.7)
        local fatorDist = math.clamp(dist / 100, 0.3, 1)
        altura = altura * reducao * fatorDist
    end

    local dir = (horizontal + Vector3.new(0, altura / dist, 0)).Unit
    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230

    Shoot:FireServer(pwr, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

-- ==========================================
-- GERENCIADOR DE TECLAS (BINDS DINÂMICOS)
-- ==========================================
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local cfg = getCfg()
    if not cfg then return end

    local hrp = getHRP()

    -- AUTO STEAL
    local keySteal = cfg.Misc.AutoSteal.Key:upper()
    if input.KeyCode == Enum.KeyCode[keySteal] and cfg.Misc.AutoSteal.Enabled then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            
            local state = ball:GetAttribute("State")
            if state == "UNTOUCHABLE" or state == player.Name then return end

            local oldPos = hrp.CFrame
            Tackle:FireServer()

            local startTime = tick()
            local pegouBola = false

            while ball and ball.Parent and (tick() - startTime) < 1.2 do
                local currentState = ball:GetAttribute("State")
                if currentState == "UNTOUCHABLE" then pegouBola = true; break end
                if currentState == player.Name then break end

                tpSeguro(ball.Position + Vector3.new(0, 2, 0))
                
                if ball.AssemblyLinearVelocity.Magnitude > 5 then
                    hrp.AssemblyLinearVelocity = ball.AssemblyLinearVelocity.Unit * 90
                end
                task.wait(0.03)
            end

            if pegouBola then
                task.wait(0.05)
                tpSeguro(oldPos.Position)
            end
        end)
    end

    -- AUTO GOAL COMBO (TP + CHUTE)
    local keyGoal = cfg.Misc.AutoGoal.Key:upper()
    if input.KeyCode == Enum.KeyCode[keyGoal] and cfg.Misc.AutoGoal.Enabled then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end

            tpSeguro(ball.Position + Vector3.new(0, 2, 0))
            Tackle:FireServer()
            task.wait(0.2)

            local alvoTP = (player.Team and player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
            tpSeguro(alvoTP)

            task.wait(0.8)
            chuteAutoGol()
        end)
    end
end)

-- ==========================================
-- SISTEMA MOUSE 2 (HOLD TIME)
-- ==========================================
local segurandoM2 = false
local tempoM2 = 0
local disparoPendente = false

CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local cfg = getCfg()
    -- Verifica se o Power Shot está ligado na UI
    if not cfg or not cfg.Misc.PowerShot.Enabled then 
        segurandoM2 = false
        return Enum.ContextActionResult.Pass 
    end

    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local holdNecessario = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47
        
        if (tick() - tempoM2) >= holdNecessario then
            if disparoPendente then return end
            disparoPendente = true
            task.delay(0.01, function()
                for i = 1, 4 do
                    executarChuteForte()
                    task.wait()
                end
                disparoPendente = false
            end)
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- LOOP DE ATRIBUTOS (FLOW / METAVISION)
-- ==========================================
task.spawn(function()
    while true do
        local cfg = getCfg()
        if cfg then
            -- Aplica os atributos conforme o estado na UI
            if cfg.Player.FakeFlow then 
                player:SetAttribute("Flow", true) 
            else
                player:SetAttribute("Flow", false)
            end

            if cfg.Player.FakeMetavision then 
                player:SetAttribute("Metavision", true) 
            else
                player:SetAttribute("Metavision", false)
            end
        end
        task.wait(0.5)
    end
end)

print("🚀 RRR Comandos: Sistema Carregado e Sincronizado!")
