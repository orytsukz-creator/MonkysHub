local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variável de controle mestre (Sincronizada com a UI)
getgenv().ScriptAtivoRRR = true 

-- REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- CONFIGURAÇÃO DOS GOLS (Calibrados)
local GOL_AZUL = { TraveEsq = Vector3.new(-2202, -12, 1006), TraveDir = Vector3.new(-2203, -12, 1049) }
local GOL_VERMELHO = { TraveEsq = Vector3.new(-2907, -12, 1049), TraveDir = Vector3.new(-2908, -12, 1007) }
local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    if not getgenv().ScriptAtivoRRR then return end
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- ==========================================
-- LÓGICA DE DISPARO (USA AS OPÇÕES DA UI)
-- ==========================================
local function dispararBola(forca, direcao)
    if not getgenv().ScriptAtivoRRR then return end
    local hrp = getHRP()
    local configs = getgenv().RRR_Configs
    
    -- Puxa os estados True/False dos quadradinhos da UI
    local opt1 = configs.States["PowerOption1"]
    local opt2 = configs.States["PowerOption2"]
    
    Shoot:FireServer(forca, direcao, direcao, hrp.Position, opt1, opt2)
end

-- ==========================================
-- CANCEL ANIMS & CUTSCENES
-- ==========================================
local function CancelAnimsFunc()
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function()
            local c = p.Character
            if c then
                local hum = c:FindFirstChild("Humanoid")
                if hum then
                    for _, anim in pairs(hum:GetPlayingAnimationTracks()) do anim:Stop(0) end
                end
            end
        end)
    end
    -- Fix Cam Integrado
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        camera.CameraSubject = hum
        camera.CameraType = Enum.CameraType.Custom
        camera.FieldOfView = 70
        hum.WalkSpeed = 40 
        hum.JumpPower = 63
    end
end

-- ==========================================
-- AUTO GOL (EIXO X ESTREITADO E Y TOP)
-- ==========================================
local function executarChuteAutoGol()
    if not getgenv().ScriptAtivoRRR then return end
    local hrp = getHRP()
    local golAlvo = (player.Team and player.Team.Name == "Red") and GOL_AZUL or GOL_VERMELHO
    
    -- Mira interna para não ir fora (15% a 35% das traves)
    local sorteioLado = math.random(1, 2)
    local offsetZ = (sorteioLado == 1) and (math.random(15, 35)/100) or (math.random(65, 85)/100)
    
    local pontoBase = golAlvo.TraveEsq:Lerp(golAlvo.TraveDir, offsetZ)
    local alvoFinal = Vector3.new(pontoBase.X, -14, pontoBase.Z) -- Y calibrado

    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    local dir = (alvoFinal - hrp.Position).Unit + Vector3.new(0, 0.05, 0)

    for i = 1, 4 do
        dispararBola(forcaUI, dir)
        task.wait()
    end
end

-- ==========================================
-- AUTO STEAL (IMPULSO 3x)
-- ==========================================
local function executarAutoSteal()
    if not getgenv().ScriptAtivoRRR then return end
    local ball = getBall()
    local hrp = getHRP()
    
    -- Verifica se a bola existe e se já não é nossa
    if not ball or ball:GetAttribute("State") == player.Name then return end

    local pegouABola = false
    local conexao
    
    -- Detecta o momento exato que pegamos a bola para parar o TP
    conexao = ball:GetAttributeChangedSignal("State"):Connect(function()
        if ball:GetAttribute("State") == player.Name then
            pegouABola = true
            if conexao then conexao:Disconnect() end
        end
    end)

    -- Spam de Tackle (Carrinho/Roubo)
    task.spawn(function()
        for i = 1, 60 do
            if not getgenv().ScriptAtivoRRR or pegouABola then break end
            Tackle:FireServer()
            task.wait(0.05)
        end
    end)

    local startTime = tick()
    while getgenv().ScriptAtivoRRR and not pegouABola and (tick() - startTime < 3.0) do
        -- Posição da bola com um leve ajuste para o seu pé (Y - 1.5)
        -- Se a bola estiver muito baixa, mantemos uma altura mínima para não entrar no chão
        local ballPos = ball.Position
        local targetY = ballPos.Y - 1.2
        
        -- Trava o Y para não descer do chão do mapa (ajuste conforme a altura do seu campo)
        if targetY < -25.5 then targetY = -25.2 end 

        local finalPos = Vector3.new(ballPos.X, targetY, ballPos.Z)
        
        -- Se a bola estiver correndo, damos um "leash" (atraso menor) para não varar
        if ball.AssemblyLinearVelocity.Magnitude > 10 then
            finalPos = finalPos + (ball.AssemblyLinearVelocity * 0.05)
        end

        hrp.CFrame = CFrame.new(finalPos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Evita que você saia voando por inércia
        
        task.wait(0.01)
    end
    
    if conexao then conexao:Disconnect() end
end

-- ==========================================
-- SISTEMA DE INPUTS (KEYBINDS)
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then
        getgenv().ScriptAtivoRRR = false
        return
    end

    if gpe or not getgenv().ScriptAtivoRRR then return end
    local configs = getgenv().RRR_Configs

    -- Auto Steal
    if configs.States["KeySteal"] and configs.Keys["KeySteal"] ~= "" then
        if input.KeyCode == Enum.KeyCode[configs.Keys["KeySteal"]:upper()] then executarAutoSteal() end
    end
    
    -- Auto Goal
    if configs.States["KeyAutoGoal"] and configs.Keys["KeyAutoGoal"] ~= "" then
        if input.KeyCode == Enum.KeyCode[configs.Keys["KeyAutoGoal"]:upper()] then
            task.spawn(function()
                local ball = getBall()
                if not ball then return end
                tpSeguro(ball.Position)
                Tackle:FireServer()
                task.wait(0.1)
                local posGol = (player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
                tpSeguro(posGol)
                task.wait(0.4)
                executarChuteAutoGol()
            end)
        end
    end

    -- Cancel Anims
    if configs.States["KeyCancelAnim"] and configs.Keys["KeyCancelAnim"] ~= "" then
        if input.KeyCode == Enum.KeyCode[configs.Keys["KeyCancelAnim"]:upper()] then CancelAnimsFunc() end
    end
end)

-- ==========================================
-- M2 CHUTE FORTE (POWER SHOT)
-- ==========================================
CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    if not getgenv().ScriptAtivoRRR or not getgenv().RRR_Configs.States["PowerShotState"] then 
        return Enum.ContextActionResult.Pass 
    end
    
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local holdNecessario = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.5
        if (tick() - tempoM2) >= holdNecessario then
            local forca = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
            local dir = (camera.CFrame.LookVector * 1000 + Vector3.new(0, 0.14, 0)).Unit
            for i = 1, 4 do dispararBola(forca, dir) task.wait() end 
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- LOOP DE BUFFS E STATUS
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().ScriptAtivoRRR then break end
        
        local hum = getChar():FindFirstChild("Humanoid")
        local configs = getgenv().RRR_Configs
        
        -- Spam Tackle Speed
        if configs.States["KeyTackle"] and hum then 
            hum.WalkSpeed = 40 
            hum.JumpPower = 63 
        end
        
        -- Atributos
        player:SetAttribute("Flow", configs.States["Flow"] or false)
        player:SetAttribute("Metavision", configs.States["Meta"] or false)
    end
end)
