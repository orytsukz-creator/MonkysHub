local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local scriptAtivo = true

-- REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- DEFINIÇÕES DOS GOLS
local GOL_AZUL = {
    TraveEsq = Vector3.new(-2202, -12, 1006),
    TraveDir = Vector3.new(-2203, -12, 1049)
}
local GOL_VERMELHO = {
    TraveEsq = Vector3.new(-2907, -12, 1049),
    TraveDir = Vector3.new(-2908, -12, 1007)
}

-- TPs DE POSICIONAMENTO RESTAURADOS
local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    if not scriptAtivo then return end
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- ==========================================
-- AUTO GOL (DIREÇÃO E ALTURA CALIBRADAS)
-- ==========================================
local function executarChuteAutoGol()
    if not scriptAtivo then return end
    local hrp = getHRP()
    local golAlvo = (player.Team and player.Team.Name == "Red") and GOL_AZUL or GOL_VERMELHO
    
    -- Mira nos cantos (20% das extremidades)
    local sorteioLado = math.random(1, 2)
    local offsetZ = (sorteioLado == 1) and (math.random(0, 20)/100) or (math.random(80, 100)/100)
    
    local pontoBase = golAlvo.TraveEsq:Lerp(golAlvo.TraveDir, offsetZ)
    
    -- Alvo vertical: -14 é uma altura segura para entrar no alto sem isolar
    local alvoFinal = Vector3.new(pontoBase.X, -14, pontoBase.Z)

    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    
    -- Ajuste fino de Y: 0.05 para uma subida leve e veloz
    local dir = (alvoFinal - hrp.Position).Unit + Vector3.new(0, 0.05, 0)

    for i = 1, 4 do
        if not scriptAtivo then break end
        Shoot:FireServer(forcaUI, dir, dir, hrp.Position, true, true)
        task.wait()
    end
end

-- ==========================================
-- AUTO STEAL (IMPULSO 3x + INTERCEPTAÇÃO)
-- ==========================================
local function executarAutoSteal()
    if not scriptAtivo then return end
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then return end

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
        for i = 1, 50 do
            if not scriptAtivo or pegouABola or not ball.Parent then break end
            Tackle:FireServer()
            task.wait(0.06)
        end
    end)

    local startTime = tick()
    while scriptAtivo and ball and ball.Parent and (tick() - startTime < 3.0) and not pegouABola do
        local velBola = ball.AssemblyLinearVelocity
        local speed = velBola.Magnitude
        
        local alturaAjustada = ball.Position.Y - 1.5
        if alturaAjustada < -25 then alturaAjustada = -24.5 end
        
        local posAlvo = Vector3.new(ball.Position.X, alturaAjustada, ball.Position.Z)

        if speed > 10 then
            local fatorPos = math.clamp(speed / 30, 1, 4)
            posAlvo = posAlvo + (velBola.Unit * fatorPos)
            hrp.AssemblyLinearVelocity = velBola.Unit * (speed * 3.0)
        end
        
        tpSeguro(posAlvo)
        task.wait(0.02)
    end

    if conexao then conexao:Disconnect() end
    if pegouABola and scriptAtivo then 
        hrp.AssemblyLinearVelocity = Vector3.zero
        tpSeguro(posicaoOriginal) 
    end
end

-- ==========================================
-- FUNÇÃO DE PARADA (TECLA P) - DELETA RRR
-- ==========================================
local function stopScript()
    scriptAtivo = false
    CAS:UnbindAction("M2ChuteForte")
    
    -- Deleta a interface RRR do CoreGui
    local rrrGui = CoreGui:FindFirstChild("RRR")
    if rrrGui then rrrGui:Destroy() end
    
    -- Reset Humanoide
    local hum = getChar():FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    
    -- Limpa Atributos
    player:SetAttribute("Flow", false)
    player:SetAttribute("Metavision", false)
end

-- ==========================================
-- INPUTS
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        stopScript()
        return
    end

    if not scriptAtivo then return end
    local configs = getgenv().RRR_Configs

    if configs.States["KeySteal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeySteal"]:upper()] then 
        executarAutoSteal() 
    end
    
    if configs.States["KeyAutoGoal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyAutoGoal"]:upper()] then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            tpSeguro(ball.Position + Vector3.new(0, 1, 0))
            Tackle:FireServer()
            task.wait(0.15)
            local posGol = (player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
            tpSeguro(posGol)
            task.wait(0.5)
            executarChuteAutoGol()
        end)
    end
end)

-- M2 CHUTE FORTE
CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    if not scriptAtivo or not getgenv().RRR_Configs.States["PowerValue"] then return Enum.ContextActionResult.Pass end
    if state == Enum.UserInputState.Begin then segurandoM2 = true tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        if (tick() - tempoM2) >= (tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.47) then
            if disparoPendente then return end
            disparoPendente = true
            task.delay(0.01, function() 
                if not scriptAtivo then return end
                local hrp = getHRP()
                local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, .14, 0)) * 10000000).Unit
                for i = 1, 4 do Shoot:FireServer(tonumber(getgenv().RRR_Configs.Keys["PowerValue"]), dir, dir, hrp.Position, true, true) task.wait() end 
                disparoPendente = false 
            end)
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- LOOP BUFFS
task.spawn(function()
    while scriptAtivo do
        local hum = getChar():FindFirstChild("Humanoid")
        local configs = getgenv().RRR_Configs
        if configs and configs.States["KeyTackle"] and hum then 
            hum.WalkSpeed = 40 
            hum.JumpPower = 63 
        end
        if configs and configs.States["Flow"] then player:SetAttribute("Flow", true) end
        if configs and configs.States["Meta"] then player:SetAttribute("Metavision", true) end
        task.wait(0.5)
    end
end)
