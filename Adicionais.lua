local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local scriptAtivo = true

-- // REMOTES (Conforme seu template)
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- // DEFINIÇÕES DOS GOLS (Coordenadas do seu mapa)
local GOL_AZUL = {
    TraveEsq = Vector3.new(-2202, -12, 1006),
    TraveDir = Vector3.new(-2203, -12, 1049)
}
local GOL_VERMELHO = {
    TraveEsq = Vector3.new(-2907, -12, 1049),
    TraveDir = Vector3.new(-2908, -12, 1007)
}
local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

-- // FUNÇÕES AUXILIARES
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    if not scriptAtivo then return end
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- // 1. AUTO GOL (Lógica de Narrowing + Sorteio de Canto)
local function executarChuteAutoGoal()
    if not scriptAtivo then return end
    local hrp = getHRP()
    local cfg = getgenv().RRR_Config
    
    -- Define o gol alvo baseado no time
    local golAlvo = (player.Team and player.Team.Name == "Red") and GOL_AZUL or GOL_VERMELHO
    
    -- Sorteio interno para evitar trave (10-30% ou 70-90%)
    local offsetZ = math.random(1, 2) == 1 and (math.random(10, 30)/100) or (math.random(70, 90)/100)
    local pontoBase = golAlvo.TraveEsq:Lerp(golAlvo.TraveDir, offsetZ)
    local alvoFinal = Vector3.new(pontoBase.X, .13.10, pontoBase.Z)

    local forcaUI = tonumber(cfg.Misc.PowerShot.Power) or 230
    local dir = (alvoFinal - hrp.Position).Unit + Vector3.new(0, 0.05, 0)

    -- Quad-Shot (4 disparos para garantir o registro)
    for i = 1, 4 do
        if not scriptAtivo then break end
        Shoot:FireServer(forcaUI, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
        task.wait()
    end
end

-- // 2. AUTO STEAL (Lógica Preditiva + TP Back)
local function executarAutoSteal()
    local cfg = getgenv().RRR_Config
    if not scriptAtivo or not cfg.Misc.AutoSteal.Enabled then return end
    
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then return end

    local distance = (ball.Position - hrp.Position).Magnitude
    local posicaoOriginal = hrp.CFrame 
    local pegouABola = false
    
    -- Se estiver MUITO perto (Magnitude < 10), apenas solta o Tackle sem dar TP
    if distance <= 10 then
        Tackle:FireServer()
        return
    end

    -- Se estiver longe (Magnitude > 10), faz o Dash Seguro
    local conexao
    conexao = ball:GetAttributeChangedSignal("State"):Connect(function()
        if ball:GetAttribute("State") == player.Name or ball:GetAttribute("State") == "UNTOUCHABLE" then
            pegouABola = true
            if conexao then conexao:Disconnect() end
        end
    end)

    -- Spam de Roubo
    task.spawn(function()
        for i = 1, 30 do -- Reduzi o loop para ser mais leve
            if not scriptAtivo or pegouABola or not ball.Parent then break end
            Tackle:FireServer()
            task.wait(0.08)
        end
    end)

    local startTime = tick()
    while scriptAtivo and ball and ball.Parent and (tick() - startTime < 1.5) and not pegouABola do
        local velBola = ball.AssemblyLinearVelocity
        -- Posição segura: Ligeiramente acima da bola (+0.5) para não enterrar o pé no chão
        local posAlvo = ball.Position + Vector3.new(0, 0.5, 0)

        -- Se a bola estiver vindo rápido, intercepta um pouco à frente dela
        if velBola.Magnitude > 15 then
            posAlvo = posAlvo + (velBola.Unit * 1.5)
        end
        
        -- TP Suave: Mantém a rotação do personagem para ele não tombar
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) -- Zera a velocidade para não "voar"
        hrp.CFrame = CFrame.new(posAlvo, Vector3.new(ball.Position.X, hrp.Position.Y, ball.Position.Z))
        
        task.wait(0.03)
        
        -- Checa magnitude de novo durante o percurso
        if (ball.Position - hrp.Position).Magnitude < 3 then break end
    end
    
    if conexao then conexao:Disconnect() end
    
    -- Volta para a posição original se configurado ou se não pegou a bola
    if not pegouABola and scriptAtivo then 
        task.wait(0.1)
        tpSeguro(posicaoOriginal) 
    end
end
-- // 3. M2 CHUTE FORTE (ContextActionService)
local segurandoM2 = false
local tempoM2 = 0
local disparoPendente = false

CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local cfg = getgenv().RRR_Config
    if not scriptAtivo or not cfg.Misc.PowerShot.Enabled then return Enum.ContextActionResult.Pass end
    
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
                if not scriptAtivo then return end
                local hrp = getHRP()
                -- Cálculo de direção baseado na câmera (LookVector)
                local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, .14, 0)) * 10000000).Unit
                
                for i = 1, 4 do 
                    Shoot:FireServer(tonumber(cfg.Misc.PowerShot.Power), dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2) 
                    task.wait() 
                end 
                disparoPendente = false 
            end)
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- // 4. INPUTS (TECLADO)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not scriptAtivo then return end
    local cfg = getgenv().RRR_Config

    -- Auto Steal Bind
    if input.KeyCode.Name == cfg.Misc.AutoSteal.Key then 
        executarAutoSteal() 
    end
    
    -- Auto Goal Bind
    if input.KeyCode.Name == cfg.Misc.AutoGoal.Key then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            -- Sequência: Pega a bola -> TP pro Gol -> Chuta
            tpSeguro(ball.Position + Vector3.new(0, 1, 0))
            Tackle:FireServer()
            task.wait(0.15)
            local posGolTP = (player.Team and player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
            tpSeguro(posGolTP)
            task.wait(0.5)
            executarChuteAutoGol()
        end)
    end
    
    -- Panic Button (P)
    if input.KeyCode == Enum.KeyCode.P then
        scriptAtivo = false
        CAS:UnbindAction("M2ChuteForte")
        if CoreGui:FindFirstChild("RRR_Hub") then CoreGui.RRR_Hub:Destroy() end
        local hum = getChar():FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 hum.JumpPower = 50 end
        print("RRR Hub: Script Encerrado.")
    end
end)

-- // 5. LOOP DE ATRIBUTOS E BUFFS (Sincronizado)
RunService.Heartbeat:Connect(function()
    if not scriptAtivo then return end
    local cfg = getgenv().RRR_Config
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if hum then
        -- Exemplo: Se o Auto Steal estiver ON, dá um buff de velocidade (opcional)
        if cfg.Misc.AutoSteal.Enabled then
            hum.WalkSpeed = 40
            hum.JumpPower = 63
        else
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end

    -- Sincroniza Atributos de Flow/Meta com o Jogo
    player:SetAttribute("Flow", cfg.Player.FakeFlow)
    player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
end)

print("--- Comandos.lua: Lógica de Elite Carregada ---")
