local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- CONFIGURAÇÕES DE POSIÇÃO (GOL)
local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

-- VARIÁVEIS DE CONTROLE
local segurando, tempoInicio = false, 0
local ultimoChute = 0
local COOLDOWN_TIME = 0.3

-- MOBILE BUTTONS
local MobileFrame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport"):WaitForChild("Frame")
local ShootBtn = MobileFrame:WaitForChild("ShootButton")
local TackleBtn = MobileFrame:WaitForChild("TackleButton")
local TalentBtn = MobileFrame:WaitForChild("TalentButton")

-- FUNÇÕES BASE
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- ==========================================
-- 1. CHUTE FORTE (POWERSHOT - MIRA NA CAMERA)
-- ==========================================
local function chuteForte()
    if tick() - ultimoChute < COOLDOWN_TIME then return end
    ultimoChute = tick()
    
    local hrp = getHRP()
    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000).Unit
    Shoot:FireServer(forcaUI, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- 2. CHUTE AUTO GOL (MIRA NO GOL INIMIGO)
-- ==========================================
local function chuteAutoGol()
    local hrp = getHRP()
    local alvo1, alvo2 = (player.Team and player.Team.Name == "Red") and {TRAVE_BLUE_1, TRAVE_BLUE_2} or {TRAVE_RED_1, TRAVE_RED_2}
    local alvo1, alvo2 = alvo1[1], alvo1[2]
    local centro = (alvo1 + alvo2) / 2
    local ladoGol = (alvo2 - alvo1).Unit
    local dot = (hrp.Position - centro):Dot(ladoGol)
    local alvoFinal = (dot > 0) and alvo1 or alvo2
    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude
    local horizontal = Vector3.new(delta.X, 0, delta.Z).Unit

    local mult = 0.14 + (math.floor((dist - 60) / 20) * 0.01)
    local altura = dist * mult
    local dir = (horizontal + Vector3.new(0, altura / dist, 0)).Unit

    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- 3. AUTO STEAL (TP + TACKLE + BACKTP)
-- ==========================================
local function executarAutoSteal()
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then return end

    local oldPos = hrp.CFrame
    Tackle:FireServer()
    local startTime = tick()
    local sucesso = false

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        if ball:GetAttribute("State") == "UNTOUCHABLE" then sucesso = true break end
        tpSeguro(ball.Position + Vector3.new(0, 2, 0))
        task.wait(0.03)
    end
    if sucesso then task.wait(0.05) tpSeguro(oldPos) end
end

-- ==========================================
-- LÓGICA DE INPUT (HOLD / CLICK)
-- ==========================================
local function startHold() if getgenv().RRR_Configs.States["PowerValue"] then segurando = true tempoInicio = tick() end end
local function endHold()
    if not segurando then return end
    segurando = false
    local holdReq = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.47
    if (tick() - tempoInicio) >= holdReq then
        for i = 1, 4 do chuteForte() task.wait(0.01) end
    end
end

-- EVENTOS DE TECLADO / MOUSE
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local configs = getgenv().RRR_Configs
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then startHold() end
    
    -- Auto Steal Key
    if configs.States["KeySteal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeySteal"]:upper()] then
        executarAutoSteal()
    end
    -- Auto Gol Key (Combo U do seu script original)
    if configs.States["KeyAutoGoal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyAutoGoal"]:upper()] then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end
            tpSeguro(ball.Position + Vector3.new(0, 2, 0))
            Tackle:FireServer()
            task.wait(0.2)
            tpSeguro((player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED)
            task.wait(1)
            chuteAutoGol()
        end)
    end
    -- Spam Tackle Key
    if configs.States["KeyTackle"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyTackle"]:upper()] then
        Tackle:FireServer()
    end
end)

UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then endHold() end end)

-- MOBILE CLICKS
ShootBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then startHold() end end)
ShootBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then endHold() end end)
TackleBtn.MouseButton1Click:Connect(function() if getgenv().RRR_Configs.States["KeySteal"] then executarAutoSteal() end end)
TalentBtn.MouseButton1Click:Connect(chuteAutoGol)

-- ==========================================
-- LOOPS (ATRIBUTOS E BUFFS)
-- ==========================================
task.spawn(function()
    while true do
        local hum = getChar():FindFirstChild("Humanoid")
        local configs = getgenv().RRR_Configs
        
        -- Spam Tackle Buffs (WalkSpeed 40 / Jump 63)
        if hum then
            if configs.States["KeyTackle"] then
                hum.WalkSpeed = 40
                hum.JumpPower = 63
            end
        end

        -- Atributos
        if configs.States["Flow"] then player:SetAttribute("Flow", true) end
        if configs.States["Meta"] then player:SetAttribute("Metavision", true) end
        
        task.wait(1) -- Loop de buffs mais rápido (1s) para não resetar
    end
end)

print("RRR Adicionais Finalizado: Tudo Restaurado e Buffs Ativos!")
