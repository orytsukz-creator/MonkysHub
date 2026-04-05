
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ativo = true

-- Remotes e Cooldown
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")
local ultimoChute = 0
local COOLDOWN_TIME = 0.3

-- Mobile Setup (Conforme seu diretório)
local MobileFrame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport"):WaitForChild("Frame")
local ShootBtn = MobileFrame:WaitForChild("ShootButton")
local TackleBtn = MobileFrame:WaitForChild("TackleButton")
local TalentBtn = MobileFrame:WaitForChild("TalentButton")

-- Funções Base
local function getHRP() return player.Character:WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
end

-- Lógica do Power Shot
local function chutePower()
    if tick() - ultimoChute < COOLDOWN_TIME then return end
    ultimoChute = tick()
    
    local hrp = getHRP()
    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000).Unit
    Shoot:FireServer(forcaUI, dir, dir, hrp.Position, true, true)
end

-- Sistema de Hold (Unificado PC/Mobile)
local segurando, tempoInicio = false, 0

local function startHold()
    if not getgenv().RRR_Configs.States["PowerValue"] then return end
    segurando = true
    tempoInicio = tick()
end

local function endHold()
    if not segurando then return end
    segurando = false
    -- Pega o Hold Time direto da UI (ex: 0.47)
    local holdConfig = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.47
    if (tick() - tempoInicio) >= holdConfig then
        for i = 1, 4 do chutePower() task.wait() end
    end
end

-- Binds PowerShot (M2 no PC / ShootButton no Mobile)
CAS:BindActionAtPriority("M2PowerShot", function(_, state)
    if state == Enum.UserInputState.Begin then startHold() elseif state == Enum.UserInputState.End then endHold() end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

ShootBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then startHold() end end)
ShootBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then endHold() end end)

-- Auto Tackle (Função com Back-TP)
local function executarAutoTackle()
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

-- Inputs (Keybinds e Mobile Buttons)
UIS.InputBegan:Connect(function(input, processed)
    if processed or not ativo then return end
    local configs = getgenv().RRR_Configs

    -- Auto Steal
    local keySteal = configs.Keys["KeySteal"]
    if configs.States["KeySteal"] and keySteal ~= "" and input.KeyCode == Enum.KeyCode[keySteal:upper()] then
        executarAutoTackle()
    end

    -- Spam Tackle
    local keySpam = configs.Keys["KeyTackle"]
    if configs.States["KeyTackle"] and keySpam ~= "" and input.KeyCode == Enum.KeyCode[keySpam:upper()] then
        Tackle:FireServer()
    end
end)

-- Mobile Clicks (Steal e Spam no mesmo botão / Goal no Talent)
TackleBtn.MouseButton1Click:Connect(function()
    if getgenv().RRR_Configs.States["KeySteal"] then executarAutoTackle() end
    if getgenv().RRR_Configs.States["KeyTackle"] then Tackle:FireServer() end
end)

TalentBtn.MouseButton1Click:Connect(function()
    -- Aqui você chamaria a sua função de AutoGol (chuteAutoGol) se ela estiver definida
    print("Auto Gol acionado via Mobile")
end)

-- Loop de Atributos (Player Tab)
task.spawn(function()
    while true do
        if getgenv().RRR_Configs.States["Flow"] then player:SetAttribute("Flow", true) end
        if getgenv().RRR_Configs.States["Meta"] then player:SetAttribute("Metavision", true) end
        task.wait(10)
    end
end)

print("RRR Hub: Tudo pronto! Mobile, Hold editável e Cooldown ativos.")
