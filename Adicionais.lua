-- // comandos.lua (CLEAN ASCII - MAGNITUDE > 10)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // 1. AGUARDAR DEPENDENCIAS
local Shoot = ReplicatedStorage:WaitForChild("ShootRE", 20)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 20)
local Tackle = Remotes and Remotes:WaitForChild("Tackle", 10)

-- Espera a Hub carregar para nao dar erro de Nil Value
repeat task.wait() until getgenv().RRR_Config

-- // 2. POSICOES
local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

local disparoPendente = false
local function getCfg() return getgenv().RRR_Config end
local function getHRP() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- // 3. FUNCOES DE EXECUCAO
local function executarChuteForte()
    local hrp, cfg = getHRP(), getCfg()
    if not hrp or not cfg or not Shoot then return end
    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, 0.14, 0)) * 10000000).Unit
    Shoot:FireServer(pwr, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

local function executarAutoSteal()
    local hrp, cfg, ball = getHRP(), getCfg(), getBall()
    if not hrp or not cfg or not ball or not Tackle then return end
    if ball:GetAttribute("State") == player.Name then return end
    
    -- [MELHORIA: DASH APENAS SE DISTANCIA > 10]
    local distancia = (hrp.Position - ball.Position).Magnitude
    
    if distancia > 10 then
        local oldPos = hrp.CFrame
        Tackle:FireServer()
        local start = tick()
        local pegou = false
        
        while ball and tick() - start < 1.2 do
            local st = ball:GetAttribute("State")
            if st == "UNTOUCHABLE" or st == player.Name then pegou = true; break end
            tpSeguro(ball.Position + Vector3.new(0, 2, 0))
            task.wait(0.03)
        end
        if pegou then task.wait(0.05); tpSeguro(oldPos.Position) end
    else
        -- Se estiver perto, apenas solta o Tackle normal sem dar o TP
        Tackle:FireServer()
    end
end

local function executarAutoGoal()
    local hrp, cfg, ball = getHRP(), getCfg(), getBall()
    if not hrp or not cfg or not ball or not Tackle or not Shoot then return end
    
    tpSeguro(ball.Position + Vector3.new(0, 2, 0))
    Tackle:FireServer()
    task.wait(0.2)
    
    local timeName = (player.Team and player.Team.Name) or "Red"
    tpSeguro((timeName == "Red") and GOAL_TP_BLUE or GOAL_TP_RED)
    task.wait(0.8)
    
    local a1, a2 = (timeName == "Red") and (TRAVE_BLUE_1, TRAVE_BLUE_2) or (TRAVE_RED_1, TRAVE_RED_2)
    local centro = (a1 + a2) / 2
    local alvoFinal = ((hrp.Position - centro):Dot((a2 - a1).Unit) > 0) and a1 or a2
    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude
    local altura = (dist < 60) and -1 or (dist * (0.14 + (math.floor((dist-60)/20)*0.01)))
    local dir = (Vector3.new(delta.X, 0, delta.Z).Unit + Vector3.new(0, altura/dist, 0)).Unit
    Shoot:FireServer(tonumber(cfg.Misc.PowerShot.Power) or 230, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

-- // 4. SISTEMA DINAMICO (MOBILE & PC)
local function checkBind(input, category, key)
    local cfg = getCfg()
    if not cfg or not cfg[category] or not cfg[category][key] or not cfg[category][key].Enabled then return false end
    
    local bind = tostring(cfg[category][key].Key)
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name:upper() == bind:upper()
    end
    
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local objects = player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        for _, obj in pairs(objects) do
            if obj.Name == bind then return true end
        end
    end
    return false
end

-- // 5. EVENTOS
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if checkBind(input, "Misc", "AutoSteal") then executarAutoSteal()
    elseif checkBind(input, "Misc", "AutoGoal") then executarAutoGoal() end
end)

local pStart = 0
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if checkBind(input, "Misc", "PowerShot") or input.UserInputType == Enum.UserInputType.MouseButton2 then
        pStart = tick()
    end
end)

UIS.InputEnded:Connect(function(input)
    if checkBind(input, "Misc", "PowerShot") or input.UserInputType == Enum.UserInputType.MouseButton2 then
        local cfg = getCfg()
        if cfg and cfg.Misc.PowerShot.Enabled then
            local holdReq = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47
            if (tick() - pStart) >= holdReq and not disparoPendente then
                disparoPendente = true
                executarChuteForte()
                task.wait(0.1)
                disparoPendente = false
            end
        end
    end
end)

-- // 6. LOOP ATRIBUTOS
task.spawn(function()
    while task.wait(0.5) do
        local cfg = getCfg()
        if cfg then
            pcall(function()
                player:SetAttribute("Flow", cfg.Player.FakeFlow)
                player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
            end)
        end
    end
end)
