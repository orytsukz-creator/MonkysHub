-- // comandos.lua (REVISADO 3X - FULL INTEGRATION)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // 1. AGUARDAR REMOTES (PROTEÇÃO CONTRA NIL)
local Shoot = ReplicatedStorage:WaitForChild("ShootRE", 15)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local Tackle = Remotes and Remotes:WaitForChild("Tackle", 5)

-- // 2. CONFIGURAÇÕES DE CAMPO (COORDENADAS)
local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

local lastMobileTackle = 0
local tackleCooldown = 2
local disparoPendente = false

-- // 3. UTILITÁRIOS
local function getCfg() return getgenv().RRR_Config end
local function getHRP() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- // 4. LÓGICAS DE EXECUÇÃO
local function executarChuteForte()
    local hrp, cfg = getHRP(), getCfg()
    if not hrp or not cfg or not Shoot then return end
    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
    -- Cálculo de direção baseado no LookVector da câmera
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, 0.14, 0)) * 10000000).Unit
    Shoot:FireServer(pwr, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

local function executarAutoSteal()
    local hrp, cfg, ball = getHRP(), getCfg(), getBall()
    if not hrp or not cfg or not ball or not Tackle then return end
    if ball:GetAttribute("State") == player.Name then return end
    
    local oldPos = hrp.CFrame
    Tackle:FireServer()
    local start = tick()
    local pegou = false
    
    -- Loop de busca da bola
    while ball and tick() - start < 1.2 do
        local st = ball:GetAttribute("State")
        if st == "UNTOUCHABLE" or st == player.Name then pegou = true; break end
        tpSeguro(ball.Position + Vector3.new(0, 2, 0))
        task.wait(0.03)
    end
    if pegou then task.wait(0.05); tpSeguro(oldPos.Position) end
end

local function executarAutoGoal()
    local hrp, cfg, ball = getHRP(), getCfg(), getBall()
    if not hrp or not cfg or not ball or not Tackle or not Shoot then return end
    
    -- Pega a bola
    tpSeguro(ball.Position + Vector3.new(0, 2, 0))
    Tackle:FireServer()
    task.wait(0.2)
    
    -- Teleporta para o lado adversário
    local timeName = player.Team and player.Team.Name or "Red"
    tpSeguro((timeName == "Red") and GOAL_TP_BLUE or GOAL_TP_RED)
    task.wait(0.8)
    
    -- Cálculo de mira na trave
    local a1, a2 = (timeName == "Red") and (TRAVE_BLUE_1, TRAVE_BLUE_2) or (TRAVE_RED_1, TRAVE_RED_2)
    local centro = (a1 + a2) / 2
    local alvoFinal = ((hrp.Position - centro):Dot((a2 - a1).Unit) > 0) and a1 or a2
    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude
    local altura = (dist < 60) and -1 or (dist * (0.13 + (math.floor((dist-60)/20)*0.01)))
    local dir = (Vector3.new(delta.X, 0, delta.Z).Unit + Vector3.new(0, altura/dist, 0)).Unit
    
    Shoot:FireServer(tonumber(cfg.Misc.PowerShot.Power) or 230, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

-- // 5. SISTEMA DE INPUT (PC & MOBILE)
-- Função auxiliar para detectar se o input veio da bind configurada
local function checkBind(input, category, key)
    local cfg = getCfg()
    if not cfg or not cfg[category][key].Enabled then return false end
    
    local savedBind = cfg[category][key].Key
    
    -- Se for teclado
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name == savedBind:upper()
    end
    
    -- Se for clique no botão (Lógica Mobile no PC)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local objects = player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        for _, obj in pairs(objects) do
            if obj.Name == savedBind then return true end
        end
    end
    
    return false
end

-- Monitor de Inputs Gerais
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if checkBind(input, "Misc", "AutoSteal") then
        executarAutoSteal()
    elseif checkBind(input, "Misc", "AutoGoal") then
        executarAutoGoal()
    elseif checkBind(input, "Player", "CancelCutscene") then
        local gui = player.PlayerGui:FindFirstChild("CutsceneGui") -- Exemplo
        if gui then gui.Enabled = false end
    end
end)

-- SISTEMA M2 / POWER SHOT (PC)
CAS:BindActionAtPriority("M2Chute", function(_, state)
    local cfg = getCfg()
    if not cfg or not cfg.Misc.PowerShot.Enabled then return Enum.ContextActionResult.Pass end
    
    static_pStart = static_pStart or 0
    if state == Enum.UserInputState.Begin then 
        static_pStart = tick()
    elseif state == Enum.UserInputState.End then
        local holdTime = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47
        if (tick() - static_pStart) >= holdTime and not disparoPendente then
            disparoPendente = true
            for i=1,4 do executarChuteForte(); task.wait() end
            disparoPendente = false
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- // 6. MOBILE SUPPORT FIXO (BOTÕES PADRÃO DO JOGO)
task.spawn(function()
    local MobileSupport = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport", 15)
    local Frame = MobileSupport and MobileSupport:WaitForChild("Frame", 5)
    
    if Frame then
        -- Chute Forte no Botão de Chute do Jogo
        local btnShoot = Frame:FindFirstChild("ShootButton")
        if btnShoot then
            local pStart = 0
            btnShoot.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then pStart = tick() end end)
            btnShoot.InputEnded:Connect(function(i)
                local cfg = getCfg()
                if cfg and cfg.Misc.PowerShot.Enabled then
                    if (tick() - pStart) >= (tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47) then
                        executarChuteForte()
                    end
                end
            end)
        end
    end
end)

-- // 7. LOOP DE ATRIBUTOS (FLOW / METAVISION)
task.spawn(function()
    while task.wait(0.5) do
        local cfg = getCfg()
        if cfg then
            -- Aplica os atributos ao player para o jogo reconhecer
            player:SetAttribute("Flow", cfg.Player.FakeFlow)
            player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
        end
    end
end)

print(">> [RRR] COMANDOS.LUA TOTALMENTE CARREGADO E REVISADO!")
