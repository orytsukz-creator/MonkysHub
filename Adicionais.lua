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

-- // COORDENADAS DO MAPA
local GOL_AZUL = { TraveEsq = Vector3.new(-2202, -12, 1006), TraveDir = Vector3.new(-2203, -12, 1049) }
local GOL_VERMELHO = { TraveEsq = Vector3.new(-2907, -12, 1049), TraveDir = Vector3.new(-2908, -12, 1007) }
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

-- // 1. AUTO GOL (CANTOS INTERNOS)
local function executarChuteAutoGoal()
    if not scriptAtivo then return end
    local cfg = getgenv().RRR_Config.Misc
    local hrp = getHRP()
    
    local golAlvo = (player.Team and player.Team.Name == "Red") and GOL_AZUL or GOL_VERMELHO
    local offsetZ = math.random(1, 2) == 1 and 0.2 or 0.8
    local pontoBase = golAlvo.TraveEsq:Lerp(golAlvo.TraveDir, offsetZ)
    local alvoFinal = Vector3.new(pontoBase.X, -14, pontoBase.Z)

    local forca = tonumber(cfg.PowerShot.Power) or 230
    local dir = (alvoFinal - hrp.Position).Unit + Vector3.new(0, 0.05, 0)

    for i = 1, 4 do
        Shoot:FireServer(forca, dir, dir, hrp.Position, cfg.PowerShot.Effect, cfg.PowerShot.Effect2)
        task.wait()
    end
end

-- // 2. AUTO STEAL (TRAVA MAGNITUDE 10 + SEM BUG)
local function executarAutoSteal()
    local cfg = getgenv().RRR_Config.Misc
    if not scriptAtivo or not cfg.AutoSteal.Enabled then return end
    
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == player.Name then return end

    local distance = (ball.Position - hrp.Position).Magnitude
    
    -- Se estiver perto, só rouba. Se estiver longe (>10), dá o TP.
    if distance <= 10 then
        Tackle:FireServer()
    else
        local posOriginal = hrp.CFrame 
        hrp.AssemblyLinearVelocity = Vector3.zero
        -- TP seguro 0.5 acima da bola
        hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0, 0.5, 0), Vector3.new(ball.Position.X, hrp.Position.Y, ball.Position.Z))
        Tackle:FireServer()
        task.wait(0.1)
        tpSeguro(posOriginal)
    end
end

-- // 3. MOUSE 2 (CHUTE FORTE COM HOLD TIME)
local segurandoM2 = false
local tempoM2 = 0

CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local cfg = getgenv().RRR_Config.Misc.PowerShot
    if not scriptAtivo or not cfg.Enabled then return Enum.ContextActionResult.Pass end
    
    if state == Enum.UserInputState.Begin then 
        segurandoM2 = true 
        tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local holdNecessario = tonumber(cfg.HoldTime) or 0.47
        
        if (tick() - tempoM2) >= holdNecessario then
            local hrp = getHRP()
            local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, .14, 0)) * 10000000).Unit
            for i = 1, 4 do 
                Shoot:FireServer(tonumber(cfg.Power), dir, dir, hrp.Position, cfg.Effect, cfg.Effect2) 
                task.wait() 
            end 
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- // 4. INPUTS DE TECLADO
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not scriptAtivo then return end
    local cfg = getgenv().RRR_Config.Misc

    if input.KeyCode.Name == cfg.AutoSteal.Key then 
        executarAutoSteal() 
    end
    
    if input.KeyCode.Name == cfg.AutoGoal.Key then
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

-- // 5. LOOP DE ATRIBUTOS (FLOW/META)
RunService.Heartbeat:Connect(function()
    if not scriptAtivo then return end
    local pCfg = getgenv().RRR_Config.Player
    player:SetAttribute("Flow", pCfg.FakeFlow)
    player:SetAttribute("Metavision", pCfg.FakeMetavision)
end)

print("--- Comandos Sincronizados com a Hub com Sucesso! ---")
