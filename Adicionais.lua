local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- DEFINIÇÕES DOS GOLS (TRAVES E CENTRO)
local GOL_AZUL = {
    TraveEsq = Vector3.new(-2202, -12, 1006),
    TraveDir = Vector3.new(-2203, -12, 1049),
    GkCenter = Vector3.new(-2210, -25, 1026)
}
local GOL_VERMELHO = {
    TraveEsq = Vector3.new(-2907, -12, 1049),
    TraveDir = Vector3.new(-2908, -12, 1007),
    GkCenter = Vector3.new(-2903, -25, 1030)
}

-- POSIÇÕES DE TELEPORTE (ONDE VOCÊ PARA PRA CHUTAR)
local GOAL_TP_RED = Vector3.new(-2817, -25, 1029)
local GOAL_TP_BLUE = Vector3.new(-2292, -25, 1030)

-- CONTROLE
local segurandoM2 = false
local tempoM2 = 0
local disparoPendente = false

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- ==========================================
-- 1. CHUTE FORTE (POWER SHOT BASE)
-- ==========================================
local function chuteForte(alvoManual)
    local hrp = getHRP()
    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    local dir
    
    if alvoManual then
        -- Se for Auto Gol, calcula a direção para o ponto aleatório no alto
        dir = (alvoManual - hrp.Position).Unit + Vector3.new(0, 0.15, 0) -- Adiciona elevação
    else
        -- Se for M2, mira na câmera
        dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, .14, 0)) * 10000000).Unit
    end
    
    Shoot:FireServer(forcaUI, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- 2. AUTO GOL ALEATÓRIO (EVITA GK)
-- ==========================================
local function executarChuteAutoGol()
    local golAlvo = (player.Team and player.Team.Name == "Red") and GOL_AZUL or GOL_VERMELHO
    
    -- Gera um offset aleatório entre as traves (Z) e altura (Y)
    -- Evitamos o centro (GkCenter) forçando o chute para as extremidades
    local sorteioLado = math.random(1, 2)
    local offsetZ
    if sorteioLado == 1 then
        offsetZ = math.random(0, 15) / 100 -- Lado Esquerdo
    else
        offsetZ = math.random(85, 100) / 100 -- Lado Direito
    end
    
    local pontoBase = golAlvo.TraveEsq:Lerp(golAlvo.TraveDir, offsetZ)
    local alvoFinal = Vector3.new(pontoBase.X, math.random(-10, -5), pontoBase.Z) -- Sempre chuta no alto

    -- Dispara 4 vezes para ser impegável
    for i = 1, 4 do
        chuteForte(alvoFinal)
        task.wait()
    end
end

-- ==========================================
-- 3. AUTO STEAL (IMPULSO 3x + TP DINÂMICO)
-- ==========================================
local function executarAutoSteal()
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then return end

    local posicaoOriginal = hrp.CFrame 
    local pegouABola = false
    
    local conexao
    conexao = ball:GetAttributeChangedSignal("State"):Connect(function()
        if ball:GetAttribute("State") == player.Name or ball:GetAttribute("State") == "UNTOUCHABLE" then
            pegouABola = true
            conexao:Disconnect()
        end
    end)

    task.spawn(function()
        for i = 1, 50 do
            if pegouABola or not ball.Parent then break end
            Tackle:FireServer()
            task.wait(0.06)
        end
    end)

    local startTime = tick()
    while ball and ball.Parent and (tick() - startTime < 3.0) and not pegouABola do
        local velBola = ball.AssemblyLinearVelocity
        local speed = velBola.Magnitude
        local posAlvo = ball.Position + Vector3.new(0, 1.8, 0)

        if speed > 10 then
            local fatorPos = math.clamp(speed / 30, 1, 4)
            posAlvo = posAlvo + (velBola.Unit * fatorPos)
            -- [IMPULSO 3x BRUTAL]
            hrp.AssemblyLinearVelocity = velBola.Unit * (speed * 3.0)
        end
        
        tpSeguro(posAlvo)
        task.wait(0.02)
    end

    if conexao then conexao:Disconnect() end
    if pegouABola then 
        hrp.AssemblyLinearVelocity = Vector3.zero
        tpSeguro(posicaoOriginal) 
    end
end

-- ==========================================
-- INPUTS E BINDINGS
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local configs = getgenv().RRR_Configs
    
    if configs.States["KeySteal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeySteal"]:upper()] then 
        executarAutoSteal() 
    end
    
    if configs.States["KeyAutoGoal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyAutoGoal"]:upper()] then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            tpSeguro(ball.Position + Vector3.new(0, 1.5, 0))
            Tackle:FireServer()
            task.wait(0.15)
            local posGol = (player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
            tpSeguro(posGol)
            task.wait(0.6) -- Reduzi o delay para o chute ser mais rápido
            executarChuteAutoGol()
        end)
    end
    
    if configs.States["KeyTackle"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyTackle"]:upper()] then 
        Tackle:FireServer() 
    end
end)

-- M2 / SHOOT BUTTON
CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    if not getgenv().RRR_Configs.States["PowerValue"] then return Enum.ContextActionResult.Pass end
    if state == Enum.UserInputState.Begin then segurandoM2 = true tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        if (tick() - tempoM2) >= (tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.47) then
            if disparoPendente then return end
            disparoPendente = true
            task.delay(0.01, function() for i = 1, 4 do chuteForte() task.wait() end disparoPendente = false end)
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- MOBILE
local MobileFrame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport"):WaitForChild("Frame")
MobileFrame:WaitForChild("TackleButton").MouseButton1Click:Connect(function() if getgenv().RRR_Configs.States["KeySteal"] then executarAutoSteal() end end)
MobileFrame:WaitForChild("PassCallButton").MouseButton1Click:Connect(executarChuteAutoGol)

-- LOOP BUFFS
task.spawn(function()
    while true do
        local hum = getChar():FindFirstChild("Humanoid")
        local configs = getgenv().RRR_Configs
        if configs.States["KeyTackle"] and hum then hum.WalkSpeed = 40 hum.JumpPower = 63 end
        if configs.States["Flow"] then player:SetAttribute("Flow", true) end
        if configs.States["Meta"] then player:SetAttribute("Metavision", true) end
        task.wait(0.5)
    end
end)
