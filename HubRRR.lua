-- // HubRRR.lua (REVISADO E SINCRONIZADO)
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ConfigFile = "RRR_Settings.json"

-- // 1. CONFIGURAÇÕES INICIAIS (ORDEM CRITICA)
getgenv().RRR_Config = {
    Misc = {
        AutoGoal = {
			Enabled = false, 
			Key = "G",
			Type = "New"
		},
        AutoSteal = {
			Enabled = false,
			Key = "F"
		},
        PowerShot = {
			Enabled = false,
			Power = "230",
			Effect = false,
			Effect2 = false,
			HoldTime = "0.47"
		}
    },
    Player = {
        CancelCutscene = {
			Enabled = false,
			Key = "C"
		},
        FakeFlow = false,
        FakeMetavision = false,
		SkillOnGkBox = false
    }
}

local BlacklistedKeys = {["W"]=true,["A"]=true,["S"]=true,["D"]=true,["Space"]=true}

local function Save()
    if writefile then 
        pcall(function() 
            writefile(ConfigFile, HttpService:JSONEncode(getgenv().RRR_Config)) 
        end) 
    end
end

local function Load()
    if isfile and isfile(ConfigFile) then
        local s, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if s and type(decoded) == "table" then
            -- Merge seguro das tabelas
            for cat, content in pairs(decoded) do
                if getgenv().RRR_Config[cat] then
                    for key, val in pairs(content) do 
                        getgenv().RRR_Config[cat][key] = val 
                    end
                end
            end
        end
    end
end
Load()

-- // 2. ESTRUTURA DA UI
local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR_Hub"
RRR.ResetOnSpawn = false
pcall(function() RRR.Parent = CoreGui end)
if not RRR.Parent then RRR.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local AlertLabel = Instance.new("TextLabel")
AlertLabel.Size = UDim2.new(1, 0, 0, 50)
AlertLabel.Position = UDim2.new(0, 0, 0.1, 0)
AlertLabel.BackgroundTransparency = 1
AlertLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AlertLabel.TextStrokeTransparency = 0
AlertLabel.TextSize = 22
AlertLabel.Font = Enum.Font.SourceSansBold
AlertLabel.Text = "CLIQUE EM UM BOTAO DO MOBILE PARA CONFIGURAR"
AlertLabel.Visible = false
AlertLabel.Parent = RRR

local Drag = Instance.new("ImageLabel")
Drag.Name = "MainFrame"
Drag.Size = UDim2.new(0, 520, 0, 350)
Drag.Position = UDim2.new(0.5, -260, 0.5, -175)
Drag.Image = "rbxassetid://132146341566959"
Drag.BackgroundTransparency = 1
Drag.Active = true
Drag.Parent = RRR

-- // 3. LOGICA DE BIND (MOBILE VS PC)
local function GetBind(currentBtn)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    
    if isMobile then
        local Chosen = nil
        local MobileSupport = LocalPlayer.PlayerGui:FindFirstChild("MobileSupport")
        local MobileFrame = MobileSupport and MobileSupport:FindFirstChild("Frame")
        
        if not MobileFrame then 
            warn("MobileSupport Frame não encontrado!")
            return nil 
        end
        
        local OriginalPos = Drag.Position
        Drag.Position = UDim2.new(0, -9999, 0, -9999)
        AlertLabel.Visible = true
        
        local Connections = {}
        for _, obj in pairs(MobileFrame:GetChildren()) do
            if obj:IsA("GuiButton") then
                local c = obj.MouseButton1Click:Connect(function() Chosen = obj.Name end)
                table.insert(Connections, c)
            end
        end
        
        local start = tick()
        repeat task.wait() until Chosen or (tick() - start > 10)
        
        for _, v in pairs(Connections) do v:Disconnect() end
        AlertLabel.Visible = false
        Drag.Position = OriginalPos
        return Chosen
    else
        currentBtn.Text = "..."
        local input = UserInputService.InputBegan:Wait()
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local kn = input.KeyCode.Name
            if not BlacklistedKeys[kn] then return kn end
        end
        return nil
    end
end

-- // 4. COMPONENTES
local Main = Instance.new("ImageLabel")
Main.Size = UDim2.new(0.78, 0, 0.82, 0)
Main.Position = UDim2.new(0.18, 0, 0.14, 0)
Main.Image = "rbxassetid://116118555895648"
Main.BackgroundTransparency = 1
Main.Parent = Drag

local function CreatePage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -10)
    pg.BackgroundTransparency = 1; pg.BorderSizePixel = 0; pg.ScrollBarThickness = 3
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y; pg.Visible = false; pg.Parent = Main
    local layout = Instance.new("UIListLayout", pg)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return pg
end

local MiscPage = CreatePage()
local PlayerPage = CreatePage()
MiscPage.Visible = true

local function AddCheat(parent, text, category, configKey, hasBind)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110); frame.BackgroundTransparency = 0.3; frame.Parent = parent
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel")
    label.Text = "  " .. text; label.Size = UDim2.new(0.4, 0, 1, 0); label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextSize = 18; label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.16,0,0.62,0); btn.Position = UDim2.new(0.81,0,0.18,0); btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    if hasBind then
        local bBtn = Instance.new("TextButton")
        bBtn.Size = UDim2.new(0.18,0,0.55,0); bBtn.Position = UDim2.new(0.58,0,0.22,0)
        bBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bBtn.Text = tostring(getgenv().RRR_Config[category][configKey].Key):gsub("Button", "")
        bBtn.Parent = frame; Instance.new("UICorner", bBtn)

if category == "Misc" and configKey == "AutoGoal" then

    -- KEYBIND
    bBtn.Size = UDim2.new(0.16,0,0.55,0)
    bBtn.Position = UDim2.new(0.50,0,0.22,0)

    -- TYPE
    local typeBtn = Instance.new("TextButton")
    typeBtn.Size = UDim2.new(0.16,0,0.55,0)
    typeBtn.Position = UDim2.new(0.68,0,0.22,0)
    typeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    typeBtn.TextScaled = true
    typeBtn.Parent = frame
    Instance.new("UICorner", typeBtn)

    -- ON OFF
    btn.Size = UDim2.new(0.14,0,0.62,0)
    btn.Position = UDim2.new(0.85,0,0.18,0)

  local function UpdateType()
    local t = getgenv().RRR_Config.Misc.AutoGoal.Type or "Old"

    typeBtn.Text = t

    -- fundo fixo roxo/azulado da hub
    typeBtn.BackgroundColor3 = Color3.fromRGB(45,65,110)

    if t == "Old" then
        -- old = cinza
        typeBtn.TextColor3 = Color3.fromRGB(170,170,170)
    else
        -- new = verde
        typeBtn.TextColor3 = Color3.fromRGB(0,255,120)
    end
end
    typeBtn.MouseButton1Click:Connect(function()
        local t = getgenv().RRR_Config.Misc.AutoGoal.Type or "Old"

        if t == "Old" then
            getgenv().RRR_Config.Misc.AutoGoal.Type = "New"
        else
            getgenv().RRR_Config.Misc.AutoGoal.Type = "Old"
        end

        Save()
        UpdateType()
    end)

    UpdateType()
end

        bBtn.MouseButton1Click:Connect(function()
            local res = GetBind(bBtn)
            if res then
                getgenv().RRR_Config[category][configKey].Key = res
                bBtn.Text = res:gsub("Button", "")
                Save()
            else
                bBtn.Text = tostring(getgenv().RRR_Config[category][configKey].Key):gsub("Button", "")
            end
        end)
    end

    local function update()
        local val = getgenv().RRR_Config[category][configKey]
        if type(val) == "table" then val = val.Enabled end
        btn.Text = val and "ON" or "OFF"
        btn.BackgroundColor3 = val and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end
    
    update()
    btn.MouseButton1Click:Connect(function()
        local d = getgenv().RRR_Config[category][configKey]
        if type(d) == "table" then d.Enabled = not d.Enabled else getgenv().RRR_Config[category][configKey] = not d end
        update(); Save()
    end)
end

local function AddPowerShot(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 145); frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110); frame.BackgroundTransparency = 0.3; frame.Parent = parent
    Instance.new("UICorner", frame)
    local title = Instance.new("TextLabel"); title.Text = "  Power Shot"; title.Size = UDim2.new(0, 150, 0, 35); title.TextColor3 = Color3.fromRGB(255, 255, 255); title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold; title.TextSize = 20; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = frame
    
    local box = Instance.new("TextBox"); box.Size = UDim2.new(0, 45, 0, 25); box.Position = UDim2.new(0.65, 0, 0.05, 0); box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.Text = tostring(getgenv().RRR_Config.Misc.PowerShot.Power); box.TextColor3 = Color3.fromRGB(255, 255, 255); box.Parent = frame; Instance.new("UICorner", box)
    box.FocusLost:Connect(function() getgenv().RRR_Config.Misc.PowerShot.Power = box.Text; Save() end)
    
    local box2 = Instance.new("TextBox"); box2.Size = UDim2.new(0, 45, 0, 25); box2.Position = UDim2.new(0.85, 0, 0.05, 0); box2.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box2.Text = tostring(getgenv().RRR_Config.Misc.PowerShot.HoldTime); box2.TextColor3 = Color3.fromRGB(255, 255, 255); box2.Parent = frame; Instance.new("UICorner", box2)
    box2.FocusLost:Connect(function() getgenv().RRR_Config.Misc.PowerShot.HoldTime = box2.Text; Save() end)
    
    local function CreateRow(txt, y, key)
        local r = Instance.new("Frame"); r.Size = UDim2.new(1, 0, 0, 30); r.Position = UDim2.new(0, 0, 0, y); r.BackgroundTransparency = 1; r.Parent = frame
        local l = Instance.new("TextLabel"); l.Text = "    " .. txt; l.Size = UDim2.new(0.5, 0, 1, 0); l.TextColor3 = Color3.fromRGB(220, 220, 220); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = r
        
        local function MkB(name, value, x)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 60, 0, 25); b.Position = UDim2.new(x, 0, 0.1, 0); b.Text = name; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Parent = r; Instance.new("UICorner", b)
            
            local function up() 
                local isActive = (getgenv().RRR_Config.Misc.PowerShot[key] == value)
                b.BackgroundColor3 = value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
                b.BackgroundTransparency = isActive and 0 or 0.7 
            end
            
            up()
            b.MouseButton1Click:Connect(function() 
                getgenv().RRR_Config.Misc.PowerShot[key] = value
                Save()
                for _,v in pairs(r:GetChildren()) do 
                    if v:IsA("TextButton") then
                        local isNowActive = (getgenv().RRR_Config.Misc.PowerShot[key] == (v.Text == "TRUE"))
                        v.BackgroundTransparency = isNowActive and 0 or 0.7 
                    end 
                end
            end)
        end
        MkB("TRUE", true, 0.65); MkB("FALSE", false, 0.82)
    end
    CreateRow("Enabled Status:", 40, "Enabled"); CreateRow("Apply Effect 1:", 75, "Effect"); CreateRow("Apply Effect 2:", 110, "Effect2")
end

-- // SIDEBAR E TABS
local UpBar = Instance.new("ImageLabel", Drag); UpBar.Size = UDim2.new(1, 0, 0.22, 0); UpBar.Position = UDim2.new(0, 0, -0.08, 0); UpBar.Image = "rbxassetid://74857124519074"; UpBar.BackgroundTransparency = 1
local Title = Instance.new("TextLabel", UpBar); Title.Text = "R.R.R HUB · Meta Lock"; Title.Position = UDim2.new(0.05, 0, 0.2, 0); Title.Size = UDim2.new(0.8, 0, 0.6, 0); Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 25; Title.TextXAlignment = Enum.TextXAlignment.Left
local CloseBtn = Instance.new("ImageButton", UpBar); CloseBtn.Size = UDim2.new(0, 30, 0, 25); CloseBtn.Position = UDim2.new(0.9, 0, 0.3, 0); CloseBtn.Image = "rbxassetid://138567149317610"; CloseBtn.BackgroundTransparency = 1; CloseBtn.MouseButton1Click:Connect(function() Drag.Visible = false end)
local Side = Instance.new("Frame", Drag); Side.Size = UDim2.new(0.15, 0, 0.5, 0); Side.Position = UDim2.new(0.02, 0, 0.18, 0); Side.BackgroundTransparency = 1
Instance.new("UIListLayout", Side).Padding = UDim.new(0, 10)

local function MakeTab(t, p)
    local b = Instance.new("TextButton", Side); b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundTransparency = 1; b.Text = t; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.SourceSansBold; b.TextSize = 22
    b.MouseButton1Click:Connect(function() 
        MiscPage.Visible = (p == MiscPage)
        PlayerPage.Visible = (p == PlayerPage) 
    end)
end

MakeTab("Misc", MiscPage)
MakeTab("Player", PlayerPage)

AddPowerShot(MiscPage)
AddCheat(MiscPage, "Auto Goal", "Misc", "AutoGoal", true)
AddCheat(MiscPage, "Auto Steal", "Misc", "AutoSteal", true)
AddCheat(PlayerPage, "Cancel Cutscene", "Player", "CancelCutscene", true)
AddCheat(PlayerPage, "Fake Flow", "Player", "FakeFlow", false)
AddCheat(PlayerPage, "Fake Metavision", "Player", "FakeMetavision", false)
AddCheat(PlayerPage, "Skill On Gk Box", "Player", "SkillOnGkBox", false)
-- // DRAG E TOGGLE (MOBILE COMPATIBLE)
local dS, sP, dragging
Drag.InputBegan:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        dragging = true; dS = i.Position; sP = Drag.Position 
    end 
end)
UserInputService.InputChanged:Connect(function(i) 
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dS
        Drag.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
    end 
end)
UserInputService.InputEnded:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false 
    end
end)

-- Tecla Z para abrir/fechar
UserInputService.InputBegan:Connect(function(i, g) 
    if not g and i.KeyCode == Enum.KeyCode.Z then 
        Drag.Visible = not Drag.Visible 
    end 
end)

-- // LÓGICA PARA ABRIR/FECHAR GUI SEGURANDO O FLOW BUTTON (MOBILE)
task.spawn(function()
    local MobileSupport = LocalPlayer.PlayerGui:WaitForChild("MobileSupport", 10)
    local FlowBtn = MobileSupport and MobileSupport:WaitForChild("Frame", 5):WaitForChild("FlowButton", 5)
    
    if not FlowBtn then 
        warn("FlowButton não encontrado para o atalho da GUI.")
        return 
    end

    local pressStartTime = 0
    local isHolding = false

    FlowBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressStartTime = tick()
            isHolding = true
        end
    end)

    FlowBtn.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and isHolding then
            isHolding = false
            local duration = tick() - pressStartTime
            
            -- Se segurar por mais de 1 segundo, alterna a GUI
            if duration >= 1 then
                Drag.Visible = not Drag.Visible
            end
        end
    end)
end)

--//====================================================
--// TEAM RADAR FINAL FIX
--// testado / simples / funcionando
--//====================================================

if _G.RadarConnection then
	_G.RadarConnection:Disconnect()
end

if _G.RadarUI then
	_G.RadarUI:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")

task.wait(2)

--====================================================
-- GUI
--====================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "RadarUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 99999
GUI.Parent = PG

_G.RadarUI = GUI

local Holder = Instance.new("Folder")
Holder.Parent = GUI

--====================================================
-- CONFIG
--====================================================

local SIZE = 34
local BORDER = 50

--====================================================
-- FUNÇÃO FOTO
--====================================================

local cache = {}

local function getThumb(plr)
	if cache[plr.UserId] then
		return cache[plr.UserId]
	end

	local ok,img = pcall(function()
		return Players:GetUserThumbnailAsync(
			plr.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)

	cache[plr.UserId] = ok and img or "rbxassetid://0"
	return cache[plr.UserId]
end

--====================================================
-- CRIAR ICONE
--====================================================

local function createIcon(plr,pos,dist)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(SIZE,SIZE)
	frame.AnchorPoint = Vector2.new(0.5,0.5)
	frame.Position = UDim2.fromOffset(pos.X,pos.Y)
	frame.BackgroundTransparency = 1
	frame.Parent = Holder

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromScale(1,1)
	img.BackgroundTransparency = 1
	img.Image = getThumb(plr)
	img.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1,0)
	corner.Parent = img

	--========================================
	-- VERIFICA QUEM ESTÁ COM A BOLA
	-- workspace.Ball atributo: State
	--========================================

	local hasBall = false

	local ball = workspace:FindFirstChild("Ball")

	if ball then
		local state = ball:GetAttribute("State")

		if tostring(state) == plr.Name then
			hasBall = true
		end
	end

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2

	if hasBall then
		stroke.Color = Color3.fromRGB(0,255,0) -- verde
	else
		stroke.Color = Color3.new(0,0,0) -- preto
	end

	stroke.Parent = img

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(2,0,0,14)
	txt.Position = UDim2.new(0.5,0,1,0)
	txt.AnchorPoint = Vector2.new(0.5,0)
	txt.BackgroundTransparency = 1
	txt.TextScaled = true
	txt.Font = Enum.Font.GothamBold
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextStrokeTransparency = 0
	txt.Text = tostring(dist).."s"
	txt.Parent = frame
end

--====================================================
-- PEGAR POSIÇÃO BORDA
--====================================================

local function getEdge(worldPos)

	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X/2,vp.Y/2)

	local p,visible = Camera:WorldToViewportPoint(worldPos)

	if visible and p.Z > 0
	and p.X >= 0 and p.X <= vp.X
	and p.Y >= 0 and p.Y <= vp.Y then
		return nil
	end

	local dir = Vector2.new(
		p.X-center.X,
		p.Y-center.Y
	)

	if p.Z < 0 then
		dir = -dir
	end

	if dir.Magnitude == 0 then
		dir = Vector2.new(0,-1)
	else
		dir = dir.Unit
	end

	local x = math.clamp(
		center.X + dir.X*(center.X-BORDER),
		BORDER,
		vp.X-BORDER
	)

	local y = math.clamp(
		center.Y + dir.Y*(center.Y-BORDER),
		BORDER,
		vp.Y-BORDER
	)

	return Vector2.new(x,y)
end

--====================================================
-- LOOP
--====================================================

_G.RadarConnection = RunService.RenderStepped:Connect(function()

	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local myTeam = LP.Team

	if not hrp or not myTeam then
		Holder:ClearAllChildren()
		return
	end

	-- limpa tudo e recria
	Holder:ClearAllChildren()

	for _,plr in ipairs(Players:GetPlayers()) do

		if plr ~= LP and plr.Team == myTeam then

			local c = plr.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")

			if r then
				local pos = getEdge(r.Position)

				if pos then
					local dist = math.floor(
						(hrp.Position-r.Position).Magnitude
					)

					createIcon(plr,pos,dist)
				end
			end
		end
	end

end)
