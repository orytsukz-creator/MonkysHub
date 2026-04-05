local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = game.Players.LocalPlayer

-- Espera a GUI ser criada pelo loadstring
local RRR = CoreGui:WaitForChild("RRR", 10)
if not RRR then warn("RRR HUB: Interface não encontrada!") return end

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Drag = RRR:FindFirstChild("Drag")

-------------------------------------------------------------------------------
-- 1. TRAVAS DE SEGURANÇA (APLICADAS NA GUI EXISTENTE)
-------------------------------------------------------------------------------
local function AplicarTravas()
    for _, v in pairs(RRR:GetDescendants()) do
        if v:IsA("TextBox") then
            -- Trava de 1 Caractere (Exceto Power)
            if v.Name ~= "PowerValue" and v.PlaceholderText ~= "230" then
                v:GetPropertyChangedSignal("Text"):Connect(function()
                    if #v.Text > 1 then v.Text = v.Text:sub(1,1) end
                end)
            end

            -- Trava do Power (170 - 230)
            if v.Name == "PowerValue" or v.PlaceholderText == "230" then
                v.FocusLost:Connect(function()
                    local val = tonumber(v.Text)
                    if not val or val > 230 then v.Text = "230" 
                    elseif val < 170 then v.Text = "170" end
                    getgenv().RRR_Configs.Keys["PowerValue"] = v.Text
                end)
            end

            -- Trava do Hold Time (Min .2 / Reset .47)
            if v.Name == "HoldValue" or v.PlaceholderText == "0.5" then
                v.FocusLost:Connect(function()
                    local val = tonumber(v.Text)
                    -- Se não tiver número ou tiver apenas '.', reseta pra .47
                    if v.Text == "" or v.Text == "." or not val then 
                        v.Text = "0.47" 
                    elseif val < 0.2 then 
                        v.Text = "0.2" 
                    end
                    getgenv().RRR_Configs.Keys["HoldValue"] = v.Text
                end)
            end
        end
    end
end

task.spawn(AplicarTravas)

-------------------------------------------------------------------------------
-- 2. FUNÇÕES PRINCIPAIS
-------------------------------------------------------------------------------

-- AUTO GOAL (ÂNGULO 0.14)
local function executarAutoGoal()
    if not getgenv().RRR_Configs.States["AutoGoalState"] then return end
    local ball = workspace:FindFirstChild("Ball")
    if not ball or ball:GetAttribute("State") ~= player.Name then return end
    
    local goal = workspace:FindFirstChild("Goal") 
    if goal then
        local pwr = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
        local direcao = (goal.Position - ball.Position).Unit + Vector3.new(0, 0.14, 0)
        
        Shoot:FireServer(
            pwr, 
            direcao, 
            direcao, 
            player.Character.HumanoidRootPart.Position, 
            getgenv().RRR_Configs.States["PowerOption1"], 
            getgenv().RRR_Configs.States["PowerOption2"]
        )
    end
end

-- AUTO STEAL SECO + TP BACK
local function executarAutoSteal()
    if not getgenv().RRR_Configs.States["AutoStealState"] then return end
    local b = workspace:FindFirstChild("Ball")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not b or not hrp or b:GetAttribute("State") == player.Name then return end
    
    local posO = hrp.CFrame
    local start = tick()
    
    while (tick() - start < 3) do
        if not getgenv().RRR_Configs then break end
        hrp.CFrame = CFrame.new(b.Position.X, b.Position.Y + 2.1, b.Position.Z)
        hrp.Velocity = Vector3.zero
        
        pcall(function()
            ReplicatedStorage.Remotes.Tackle:FireServer()
        end)
        
        task.wait()
        if b:GetAttribute("State") == player.Name then break end
    end
    hrp.CFrame = posO
end

-------------------------------------------------------------------------------
-- 3. INPUTS E PANIC BUTTON (P)
-------------------------------------------------------------------------------

local function SelfDestruct()
    RRR:Destroy() -- Deleta a GUI do loadstring
    getgenv().RRR_Configs = nil -- Limpa as configs
    script:Destroy() -- Para este script
    warn("RRR HUB: Script e Interface encerrados.")
end

UIS.InputBegan:Connect(function(i, g)
    -- Tecla P mata tudo, independente de estar digitando ou não
    if i.KeyCode == Enum.KeyCode.P then
        SelfDestruct()
        return
    end

    if g then return end
    
    -- Atalho para esconder/mostrar (Z)
    if i.KeyCode == Enum.KeyCode.Z and Drag then
        Drag.Visible = not Drag.Visible
    end

    -- Binds de Jogo
    local k = getgenv().RRR_Configs.Keys
    if k["KeySteal"] and i.KeyCode == Enum.KeyCode[k["KeySteal"]:upper()] then 
        executarAutoSteal() 
    end
    if k["KeyAutoGoal"] and i.KeyCode == Enum.KeyCode[k["KeyAutoGoal"]:upper()] then 
        executarAutoGoal() 
    end
end)
