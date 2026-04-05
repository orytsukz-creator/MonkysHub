local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- Variáveis Power Shot
local segurandoM2 = false
local tempoM2 = 0
local disparoPendente = false
local DELAY_DISPARO = 0.01

-- Mobile Setup
local MobileFrame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport"):WaitForChild("Frame")
local ShootBtn = MobileFrame:WaitForChild("ShootButton")
local TackleBtn = MobileFrame:WaitForChild("TackleButton")
local TalentBtn = MobileFrame:WaitForChild("TalentButton")

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

-- ==========================================
-- FUNÇÃO CHUTE FORTE (REPETE 4X)
-- ==========================================
local function chuteForte()
    local hrp = getHRP()
    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000).Unit
    Shoot:FireServer(forcaUI, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- LÓGICA M2 / HOLD (POWER SHOT)
-- ==========================================
local function M2Action(_, state)
    if not getgenv().RRR_Configs.States["PowerValue"] then return Enum.ContextActionResult.Pass end

    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoM2 = tick()
    elseif state == Enum.UserInputState.End then
        if segurandoM2 then
            segurandoM2 = false
            -- Pega o tempo que o player configurou na UI
            local HOLD_CONFIG = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.47
            
            if (tick() - tempoM2) >= HOLD_CONFIG then
                if disparoPendente then return end
                disparoPendente = true

                task.delay(DELAY_DISPARO, function()
                    for i = 1, 4 do
                        chuteForte()
                        task.wait()
                    end
                    disparoPendente = false
                end)
            end
        end
    end
    return Enum.ContextActionResult.Pass
end

-- Bind do M2 com prioridade alta para tirar o delay
CAS:BindActionAtPriority("M2ChuteForte", M2Action, false, 3000, Enum.UserInputType.MouseButton2)

-- Suporte Mobile para o mesmo sistema de Hold
ShootBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        segurandoM2 = true
        tempoM2 = tick()
    end
end)

ShootBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        M2Action(nil, Enum.UserInputState.End)
    end
end)

-- ==========================================
-- AUTO STEAL / AUTO GOL / BUFFS (RESTANTE)
-- ==========================================

-- Função Auto Steal (Original)
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
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0, 2, 0))
        task.wait(0.03)
    end
    if sucesso then task.wait(0.05) hrp.CFrame = oldPos end
end

-- Eventos de Teclado
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local configs = getgenv().RRR_Configs
    
    if configs.States["KeySteal"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeySteal"]:upper()] then
        executarAutoSteal()
    end
    
    if configs.States["KeyTackle"] and input.KeyCode == Enum.KeyCode[configs.Keys["KeyTackle"]:upper()] then
        Tackle:FireServer()
    end
end)

-- Mobile Steal
TackleBtn.MouseButton1Click:Connect(function()
    if getgenv().RRR_Configs.States["KeySteal"] then executarAutoSteal() end
end)

-- Loop de Atributos e Buffs de Velocidade
task.spawn(function()
    while true do
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local configs = getgenv().RRR_Configs
        
        if configs.States["KeyTackle"] and hum then
            hum.WalkSpeed = 40
            hum.JumpPower = 63
        end

        if configs.States["Flow"] then player:SetAttribute("Flow", true) end
        if configs.States["Meta"] then player:SetAttribute("Metavision", true) end
        
        task.wait(0.5)
    end
end)

print("RRR Adicionais: Power Shot 4x e Hold Time ajustados!")
