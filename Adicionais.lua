local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local scriptAtivo = true

-- // REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- // COORDENADAS DO MAPA (Sincronizado com seu Template)
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
    hrp.AssemblyLinearVelocity = Vector3.zero -- Zera inércia para não bugar
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- // 1. AUTO GOL (CANTOS INTERNOS)
local function executarChuteAutoGoal()
    if not scriptAtivo then return end
    local hrp = getHRP()
    local cfg = getgenv().RRR_Config
    
    local golAlvo = (player.Team and player.Team.Name == "Red") and GOL_AZUL or GOL_VERMELHO
    
    local offsetZ = math.random(1, 2) == 1 and (math.random(10, 30)/100) or (math.random(70, 90)/100)
    local pontoBase = golAlvo.TraveEsq:Lerp(golAlvo.TraveDir, offsetZ)
    local alvoFinal = Vector3.new(pontoBase.X, -14, pontoBase.Z)

    local forcaUI = tonumber(cfg.Misc.PowerShot.Power) or 230
    local dir = (alvoFinal - hrp.Position).Unit + Vector3.new(0, 0.05, 0)

    for i = 1, 4 do
        if not scriptAtivo then break end
        Shoot:FireServer(forcaUI, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
        task.wait()
    end
end

-- // 2. AUTO STEAL (LIMPO - SEM CAPOTAR)
local function executarAutoSteal()
    local cfg = getgenv().RRR_Config
    if not scriptAtivo or not cfg.Misc.AutoSteal.Enabled then return end
    
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then return end

    local distance = (ball.Position - hrp.Position).Magnitude
    
    -- TRAVA: Se tiver perto (<= 10), só aperta o botão de roubo, sem dar TP
    if distance <= 10 then
        Tackle:FireServer()
        return
    end

    -- Se tiver longe (> 10), faz o Dash Seguro
    local posicaoOriginal = hrp.CFrame 
    local pegouABola = false
    
    local conexao
    conexao = ball:GetAttributeChangedSignal("State"):Connect(function()
        if ball:GetAttribute("State") == player.Name or ball:GetAttribute("State") == "UNTOUCHABLE" then
            pegouABola = true
            if conexao then conexao:Disconnect() end
        end
    end)

    task.spawn(function()
        for i = 1, 25 do -- Loop de Tackle
            if not scriptAtivo or pegouABola or not ball.Parent then break end
            Tackle:FireServer()
            task.wait(0.1)
        end
    end)

    local startTime = tick()
    while scriptAtivo and ball and ball.Parent and (tick() - startTime < 1.2) and not pegouABola do
        -- TP 0.5 acima da bola para não colidir com o chão e bugar a física
        local posAlvo = ball.Position + Vector3.new(0, 0.5, 0)
        
        hrp.AssemblyLinearVelocity = Vector3.zero -- Trava a física para não capotar
        -- Mantém o corpo reto e olha para a bola
        hrp.CFrame = CFrame.new(posAlvo, Vector3.new(ball.Position.X, hrp.Position.Y, ball.Position.Z))
        
        task.wait(0.05)
        if (ball.Position - hrp.Position).Magnitude < 3 then break end
    end
    
    if conexao then conexao:Disconnect() end
    if not pegouABola and scriptAtivo then 
        task.wait(0.1)
        tpSeguro(posicaoOriginal) 
    end
end

-- // 3. CHUTE MANUAL (M2)
CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local cfg = getgenv().RRR_Config
    if not scriptAtivo or not cfg.Misc.PowerShot.Enabled then return Enum.ContextActionResult.Pass end
    
    if state == Enum.UserInputState.Begin then
        local hrp = getHRP()
        local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, .14, 0)) * 10000000).Unit
        for i = 1, 4 do 
            Shoot:FireServer(tonumber(cfg.Misc.PowerShot.Power), dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2) 
            task.wait() 
        end 
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- // 4. INPUTS (TECLADO)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not scriptAtivo then return end
    local cfg = getgenv().RRR_Config

    if input.KeyCode.Name == cfg.Misc.AutoSteal.Key then 
        executarAutoSteal() 
    end
    
    if input.KeyCode.Name == cfg.Misc.AutoGoal.Key then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            tpSeguro(ball.Position + Vector3.new(0, 1, 0))
            Tackle:FireServer()
            task.wait(0.15)
            local posGolTP = (player.Team and player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
            tpSeguro(posGolTP)
            task.wait(0.5)
            executarChuteAutoGoal()
        end)
    end
end)

-- // 5. LOOP DE STATUS (FLOW/META)
RunService.Heartbeat:Connect(function()
    if not scriptAtivo then return end
    local cfg = getgenv().RRR_Config
    player:SetAttribute("Flow", cfg.Player.FakeFlow)
    player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
end)
