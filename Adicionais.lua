local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")

-- AUTO GOAL (ÂNGULO 0.14)
local function executarAutoGoal()
    local ball = workspace:FindFirstChild("Ball")
    if not ball or ball:GetAttribute("State") ~= player.Name then return end
    
    -- Tenta achar o gol adversário (ajuste o nome se necessário no seu jogo)
    local goal = workspace:FindFirstChild("Goal") 
    if goal then
        local pwr = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
        -- A mágica do 0.14 na subida
        local direcao = (goal.Position - ball.Position).Unit + Vector3.new(0, 0.14, 0)
        
        Shoot:FireServer(pwr, direcao, direcao, player.Character.HumanoidRootPart.Position, getgenv().RRR_Configs.States["PowerOption1"], getgenv().RRR_Configs.States["PowerOption2"])
    end
end

-- AUTO STEAL SECO + TP BACK
local function executarAutoSteal()
    local b = workspace:FindFirstChild("Ball")
    local hrp = player.Character.HumanoidRootPart
    if not b or b:GetAttribute("State") == player.Name then return end
    local posO = hrp.CFrame
    local start = tick()
    while (tick() - start < 3) do
        hrp.CFrame = CFrame.new(b.Position.X, b.Position.Y + 2.1, b.Position.Z)
        hrp.Velocity = Vector3.zero
        ReplicatedStorage.Remotes.Tackle:FireServer()
        task.wait()
        if b:GetAttribute("State") == player.Name then break end
    end
    hrp.CFrame = posO
end

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    local k = getgenv().RRR_Configs.Keys
    if k["KeySteal"] and i.KeyCode == Enum.KeyCode[k["KeySteal"]:upper()] then executarAutoSteal() end
    if k["KeyAutoGoal"] and i.KeyCode == Enum.KeyCode[k["KeyAutoGoal"]:upper()] then executarAutoGoal() end
end)
