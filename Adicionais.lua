local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- POSIÇÕES DOS GOLS
local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

-- VARIÁVEIS DE CONTROLE
local segurandoM2 = false
local tempoM2 = 0
local disparoPendente = false
local DELAY_DISPARO = 0.01

-- MOBILE SETUP
local MobileFrame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport"):WaitForChild("Frame")
local ShootBtn = MobileFrame:WaitForChild("ShootButton")
local TackleBtn = MobileFrame:WaitForChild("TackleButton")
local PassBtn = MobileFrame:WaitForChild("PassCallButton")

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- ==========================================
-- AUTO STEAL DINÂMICO + SPAM TACKLE (50x)
-- ==========================================
local function executarAutoSteal()
    local ball = getBall()
    local hrp = getHRP()
    
    if not ball or ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then return end

    local posicaoOriginal = hrp.CFrame 
    local pegouABola = false
    
    -- Listener instantâneo
    local conexao
    conexao = ball:GetAttributeChangedSignal("State"):Connect(function()
        local s = ball:GetAttribute("State")
        if s == player.Name or s == "UNTOUCHABLE" then
            pegouABola = true
            conexao:Disconnect()
        end
    end)

    -- Loop de SPAM do Remote (Tackle) em paralelo (50 vezes em ~3s)
    task.spawn(function()
        for i = 1, 50 do
            if pegouABola or not ball.Parent then break end
            Tackle:FireServer()
            task.wait(0.06) -- 50 * 0.06 = 3 segundos de spam
        end
    end)

    local startTime = tick()

    -- Loop de Perseguição com TP Dinâmico
    while ball and ball.Parent and (tick() - startTime < 3.0) and not pegouABola do
        local velBola = ball.AssemblyLinearVelocity
        local speed = velBola.Magnitude
        local posAlvo = ball.Position + Vector3.new(0, 1.8, 0)

        -- Antecipação Dinâmica (Mínimo 0.5, Máximo 4 studs)
        if speed > 5 then
            local fator = math.clamp(speed / 45, 0.5, 4) 
            posAlvo = posAlvo + (velBola.Unit * fator)
        end
        
        tpSeguro(posAlvo)
        task.wait(0.02)
    end

    if conexao then conexao:Disconnect() end
    
    if pegouABola then 
        tpSeguro(posicaoOriginal) 
    end
end

-- ==========================================
-- SISTEMA DE CHUTES E PODERES (MANTIDO)
-- ==========================================
local function chuteForte()
    local hrp = getHRP()
    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000).Unit
    Shoot:FireServer(forcaUI, dir, dir, hrp.Position, true, true)
end

local function chuteAutoGol()
    local hrp = getHRP()
    local alvo1, alvo2 = (player.Team and player.Team.Name == "Red") and {TRAVE_BLUE_1, TRAVE_BLUE_2} or {TRAVE_RED_1, TRAVE_RED_2}
    local p1, p2 = alvo1[1], alvo1[2]
    local centro = (p1 + p2) / 2
    local ladoGol = (p2 - p1).Unit
    local dot = (hrp.Position - centro):Dot(ladoGol)
    local alvoFinal = (dot > 0) and p1 or p2
    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude
    local horizontal = Vector3.new(delta.X, 0, delta.Z).Unit
    local mult = 0.14 + (math.floor((dist - 60) / 20) * 0.01)
    local altura = dist * mult
    local dir = (horizontal + Vector3.new(0, altura / dist, 0)).Unit
    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

local function M2Action(_, state)
    if not getgenv().RRR_Configs.States["PowerValue"] then return Enum.ContextActionResult.Pass end
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true; tempoM2 = tick()
    elseif state == Enum.UserInputState.End then
        if segurandoM2 then
            segurandoM2 = false
            local holdReq = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.47
            if (tick() - tempoM2) >= holdReq then
                if disparoPendente then return end
                disparoPendente = true
                task.delay(DELAY_DISPARO, function()
                    for i = 1, 4 do chuteForte(); task.wait() end
                    disparoPendente = false
                end)
            end
        end
    end
    return Enum.ContextActionResult.Pass
end

CAS:BindActionAtPriority("M2ChuteForte", M2Action, false, 3000, Enum.UserInputType.MouseButton2)

-- BINDINGS
ShootBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then segurandoM2 = true tempoM2 = tick() end end)
ShootBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then M2Action(nil, Enum.UserInputState.End) end end)
TackleBtn.MouseButton1Click:Connect(function() if getgenv().RRR_Configs.States["KeySteal"] then executarAutoSteal() end end)
PassBtn.MouseButton1Click:Connect(chuteAutoGol)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local configs = getgenv().RRR_Configs
    if configs.States["KeySteal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeySteal"]:upper()] then executarAutoSteal() end
    if configs.States["KeyAutoGoal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyAutoGoal"]:upper()] then
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
    if configs.States["KeyTackle"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyTackle"]:upper()] then Tackle:FireServer() end
end)

-- LOOP BUFFS
task.spawn(function()
    while true do
        local hum = getChar():FindFirstChild("Humanoid")
        local configs = getgenv().RRR_Configs
        if configs.States["KeyTackle"] and hum then
            hum.WalkSpeed = 40; hum.JumpPower = 63
        end
        if configs.States["Flow"] then player:SetAttribute("Flow", true) end
        if configs.States["Meta"] then player:SetAttribute("Metavision", true) end
        task.wait(0.5)
    end
end)
