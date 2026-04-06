--- ==========================================
-- SERVICES
-- ==========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ativo = true
local usandoU = false

-- M2 CONFIG
local segurandoM2 = false
local tempoM2 = 0
local HOLD_TIME = 0.47
local DELAY_DISPARO = 0.01
local disparoPendente = false

-- REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- ==========================================
-- CONFIG GOL
-- ==========================================

local TRAVE_RED_1 = Vector3.new(-2907, -25, 1010)
local TRAVE_RED_2 = Vector3.new(-2907, -25, 1047)

local TRAVE_BLUE_1 = Vector3.new(-2202, -25, 1010)
local TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1047)

local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

-- ==========================================
-- BASE
-- ==========================================

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart")
end

local function getBall()
    return workspace:FindFirstChild("Ball")
end

-- ==========================================
-- CHUTE FORTE (DIR ABSURDO)
-- ==========================================

local function chuteForte()
    local hrp = getHRP()

    local dir = (
        camera.CFrame.LookVector * 310000 +
        (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000
    ).Unit

    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- AUTO GOL
-- ==========================================

-- 🎯 AUTO GOL (SISTEMA FINAL)
local function chuteAutoGol()
    local hrp = getHRP()

    local alvo1, alvo2
    if player.Team and player.Team.Name == "Red" then
        alvo1, alvo2 = TRAVE_BLUE_1, TRAVE_BLUE_2
    else
        alvo1, alvo2 = TRAVE_RED_1, TRAVE_RED_2
    end

    local centro = (alvo1 + alvo2) / 2

    -- anti goleiro
    local ladoGol = (alvo2 - alvo1).Unit
    local relative = hrp.Position - centro
    local dot = relative:Dot(ladoGol)

    local alvoFinal = (dot > 0) and alvo1 or alvo2

    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude

    local horizontal = Vector3.new(delta.X, 0, delta.Z).Unit

    -- 🔥 ALTURA PROGRESSIVA (20 + 80 + 160)
    local altura

    if dist < 60 then
        altura = -1
    else
        local step20 = math.floor((dist - 60) / 20)
        local bonus80 = math.floor((dist - 60) / 80)
        local bonus160 = math.floor((dist - 60) / 160)

        local mult = 0.14 + (step20 * 0.01)
        mult = mult + (bonus80 * 0.01)
        mult = mult + (bonus160 * 0.01)

        altura = dist * mult
    end

    -- 🔥 CORREÇÃO NO AR
    local alturaDoChao = hrp.Position.Y + 25
    if alturaDoChao > 0 then
        local reducao = 1 - math.clamp((alturaDoChao / 20), 0, 0.7)
        local fatorDist = math.clamp(dist / 100, 0.3, 1)
        altura = altura * reducao * fatorDist
    end

    local dir = (horizontal + Vector3.new(0, altura / dist, 0)).Unit

    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- TP
-- ==========================================

local function tpSeguro(pos)
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
    hrp.CFrame = CFrame.new(pos)
end

-- ==========================================
-- INPUT
-- ==========================================

UIS.InputBegan:Connect(function(input, processed)
    if processed or not ativo then return end

    local hrp = getHRP()

    if input.KeyCode == Enum.KeyCode.Zero then
        ativo = false
        return
    end

    if input.KeyCode == Enum.KeyCode.Y then
        hrp.AssemblyLinearVelocity = Vector3.new(0,100,0)
    end

    if input.KeyCode == Enum.KeyCode.Q then
        task.wait()

        local dir
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            dir = hrp.CFrame.RightVector
        elseif UIS:IsKeyDown(Enum.KeyCode.A) then
            dir = -hrp.CFrame.RightVector
        elseif UIS:IsKeyDown(Enum.KeyCode.S) then
            dir = -hrp.CFrame.LookVector
        else
            dir = hrp.CFrame.LookVector
        end

        hrp.AssemblyLinearVelocity = dir * 150
    end

    if input.KeyCode == Enum.KeyCode.V then
        if player.Team then
            player.Team = (player.Team.Name == "Red")
                and Teams:FindFirstChild("Blue")
                or Teams:FindFirstChild("Red")
        end
    end

    if input.KeyCode == Enum.KeyCode.M then
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name:lower():find("team") then
                gui.Enabled = not gui.Enabled
            end
        end
    end

    if input.KeyCode == Enum.KeyCode.T then
        chuteForte()
    end

    if input.KeyCode == Enum.KeyCode.P then
        local ball = getBall()
        if ball then
            tpSeguro(ball.Position + Vector3.new(0,2,0))
        end
    end

    -- ==========================================
    -- J (TP + BACKTP CORRETO)
    -- ==========================================

    if input.KeyCode == Enum.KeyCode.J then
        task.spawn(function()
            local ball = getBall()
            if not ball then return end

            local initialState = ball:GetAttribute("State")
            if initialState == "UNTOUCHABLE" then return end
            if initialState == player.Name then return end

            local oldPos = hrp.CFrame
            Tackle:FireServer()

            local startTime = tick()
            local deuTackle = false

            while ball and ball.Parent do
                if tick() - startTime >= 1.2 then break end

                local state = ball:GetAttribute("State")

                if state == "UNTOUCHABLE" then
                    deuTackle = true
                    break
                end

                tpSeguro(ball.Position + Vector3.new(0,2,0))

                local vel = ball.AssemblyLinearVelocity
                if vel.Magnitude > 5 then
                    hrp.AssemblyLinearVelocity = vel.Unit * 90
                end

                task.wait(0.03)
            end

            if deuTackle then
                task.wait(0.05)
                tpSeguro(oldPos.Position)
            end
        end)
    end

    -- ==========================================
    -- U (COMBO GOL)
    -- ==========================================

    if input.KeyCode == Enum.KeyCode.U and not usandoU then
        usandoU = true

        task.spawn(function()
            local ball = getBall()
            if not ball then usandoU = false return end

            tpSeguro(ball.Position + Vector3.new(0, 2, 0))
            Tackle:FireServer()

            task.wait(0.2)

            local alvoTP = (player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
            tpSeguro(alvoTP)

            task.wait(1)

            chuteAutoGol()

            task.wait(1)
            usandoU = false
        end)
    end
end)

-- ==========================================
-- M2
-- ==========================================

local function M2Action(_, state)
    if not ativo then return Enum.ContextActionResult.Pass end

    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoM2 = tick()

    elseif state == Enum.UserInputState.End then
        if segurandoM2 then
            segurandoM2 = false

            if (tick() - tempoM2) >= HOLD_TIME then
                if disparoPendente then return end
                disparoPendente = true

                task.delay(DELAY_DISPARO, function()
                    for i = 1, 4 do
                        if ativo then
                            chuteForte()
                        end
                        task.wait()
                    end
                    disparoPendente = false
                end)
            end
        end
    end

    return Enum.ContextActionResult.Pass
end

CAS:BindActionAtPriority(
    "M2ChuteForte",
    M2Action,
    false,
    3000,
    Enum.UserInputType.MouseButton2
)
--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

--// PLAYER
local player = Players.LocalPlayer

--// POSIÇÕES
local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

--// FUNÇÃO PRA PEGAR GOL INIMIGO
local function getEnemyGoal()
    local team = player.Team
    
    if not team then return nil end

    -- Ajusta aqui se os nomes dos times forem diferentes
    if team.Name:lower():find("red") then
        return GOAL_TP_BLUE
    elseif team.Name:lower():find("blue") then
        return GOAL_TP_RED
    end

    return nil
end

--// TELEPORT
local function teleportToGoal()
    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = getEnemyGoal()
    if not targetPos then return end

    hrp.CFrame = CFrame.new(targetPos)
end

--// KEYBIND (Z)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Z then
        teleportToGoal()
    end
end)

while true do 
task.wait()
player:SetAttribute("Flow",true)
end

CAS:BindActionAtPriority(
    "M2ChuteForte",
    M2Action,
    false,
    3000,
    Enum.UserInputType.MouseButton2
)
