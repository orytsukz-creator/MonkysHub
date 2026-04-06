local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // 1. REFERÊNCIAS DO JOGO
local ShootRE = ReplicatedStorage:WaitForChild("ShootRE", 10)
local TackleRE = ReplicatedStorage:FindFirstChild("Tackle", true) or ReplicatedStorage:FindFirstChild("TackleRE", true)

local function IsTyping()
    return UIS:GetFocusedTextBox() ~= nil
end

-- // 2. FUNÇÃO DE CHUTE (POWER SHOT / AUTO GOAL)
local function DispararChute()
    local cfg = getgenv().RRR_Config
    if not cfg or not cfg.Misc.PowerShot.Enabled then return end

    local ball = workspace:FindFirstChild("Ball")
    if not ball or ball:GetAttribute("State") ~= LocalPlayer.Name then return end

    -- Busca o Gol (tenta achar a parte "Goal" no mapa)
    local goal = workspace:FindFirstChild("Goal", true)
    if goal and ShootRE then
        local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
        -- Direção com o ângulo de 0.14 que você pediu
        local direcao = (goal.Position - ball.Position).Unit + Vector3.new(0, 0.14, 0)
        
        ShootRE:FireServer(
            pwr, 
            direcao, 
            direcao, 
            LocalPlayer.Character.HumanoidRootPart.Position, 
            cfg.Misc.PowerShot.Effect, -- True ou False vindo da UI
            cfg.Misc.PowerShot.Effect2
        )
    end
end

-- // 3. FUNÇÃO DE ROUBO (MAGNITUDE > 10)
local function ExecutarRoubo()
    local cfg = getgenv().RRR_Config
    if not cfg or not cfg.Misc.AutoSteal.Enabled then return end

    local ball = workspace:FindFirstChild("Ball")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not ball or not hrp or ball:GetAttribute("State") == LocalPlayer.Name then return end

    local dist = (ball.Position - hrp.Position).Magnitude
    local oldPos = hrp.CFrame

    if dist > 10 then
        -- Dash/TP apenas se estiver longe
        hrp.CFrame = CFrame.new(ball.Position.X, ball.Position.Y + 2.1, ball.Position.Z)
        if TackleRE then TackleRE:FireServer() end
        task.wait(0.1)
        hrp.CFrame = oldPos
    else
        -- Roubo seco se estiver perto
        if TackleRE then TackleRE:FireServer() end
    end
end

-- // 4. EFEIT
