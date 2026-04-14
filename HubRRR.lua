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
        AutoGoal = {Enabled = false, Key = "G"},
        AutoSteal = {Enabled = false, Key = "F"},
        PowerShot = {Enabled = false, Power = "230", Effect = false, Effect2 = false, HoldTime = "0.47"}
    },
    Player = {
        CancelCutscene = {Enabled = false, Key = "C"},
        FakeFlow = false,
        FakeMetavision = false
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
    btn.Size = UDim2.new(0, 70, 0.7, 0); btn.Position = UDim2.new(0.82, 0, 0.15, 0); btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    if hasBind then
        local bBtn = Instance.new("TextButton")
        bBtn.Size = UDim2.new(0, 75, 0, 25); bBtn.Position = UDim2.new(0.53, 0, 0.22, 0)
        bBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bBtn.Text = tostring(getgenv().RRR_Config[category][configKey].Key):gsub("Button", "")
        bBtn.Parent = frame; Instance.new("UICorner", bBtn)

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

if _G.RadarLoop then
	_G.RadarLoop:Disconnect()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local INDICATOR_SIZE = UDim2.new(0,40,0,40)
local RADIUS_SCALE = 0.38
local SPREAD_DISTANCE = 55

-- RESET
local old = player.PlayerGui:FindFirstChild("RadarFinal")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadarFinal"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = player.PlayerGui

local holder = Instance.new("Folder")
holder.Name = "Icons"
holder.Parent = screenGui

-- GUARDA OS ICONES
local indicators = {}

local function getPlayerImage(plr)
	local ok,img = pcall(function()
		return Players:GetUserThumbnailAsync(
			plr.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)

	return ok and img or "rbxassetid://0"
end

local function createIndicator(target)
	local frame = Instance.new("Frame")
	frame.Name = tostring(target.UserId)
	frame.Size = INDICATOR_SIZE
	frame.AnchorPoint = Vector2.new(0.5,0.5)
	frame.BackgroundTransparency = 1
	frame.Parent = holder

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromScale(1,1)
	img.BackgroundTransparency = 1
	img.Image = getPlayerImage(target)
	img.Parent = frame

	Instance.new("UICorner",img).CornerRadius = UDim.new(1,0)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Parent = img

	local txt = Instance.new("TextLabel")
	txt.Name = "Distance"
	txt.Size = UDim2.new(1,40,0,15)
	txt.Position = UDim2.new(0.5,0,1,2)
	txt.AnchorPoint = Vector2.new(0.5,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextStrokeTransparency = 0
	txt.Font = Enum.Font.GothamBold
	txt.TextSize = 11
	txt.Parent = frame

	return frame
end

_G.RadarLoop = RunService.RenderStepped:Connect(function()

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hrp or not player.Team then
		for _,v in pairs(indicators) do
			v:Destroy()
		end
		table.clear(indicators)
		return
	end

	local viewport = camera.ViewportSize
	local center = viewport / 2

	local currentPositions = {}
	local used = {}

	for _,target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Team == player.Team then

			local tch = target.Character
			local thrp = tch and tch:FindFirstChild("HumanoidRootPart")

			if thrp then
				local id = target.UserId

				if not indicators[id] then
					indicators[id] = createIndicator(target)
				end

				local gui = indicators[id]
				used[id] = true

				local pos,onScreen = camera:WorldToViewportPoint(thrp.Position)

				if not onScreen then
					local dx = pos.X - center.X
					local dy = pos.Y - center.Y

					if pos.Z < 0 then
						dx = -dx
						dy = -dy
					end

					local dir = Vector2.new(dx,dy).Unit

					local finalPos = Vector2.new(
						center.X + dir.X * viewport.Y * RADIUS_SCALE,
						center.Y + dir.Y * viewport.Y * RADIUS_SCALE
					)

					for _,p in pairs(currentPositions) do
						if (finalPos - p).Magnitude < SPREAD_DISTANCE then
							finalPos += Vector2.new(-dir.Y,dir.X) * SPREAD_DISTANCE
						end
					end

					table.insert(currentPositions,finalPos)

					gui.Position = UDim2.new(0,finalPos.X,0,finalPos.Y)
					gui.Distance.Text = math.floor((hrp.Position-thrp.Position).Magnitude).."s"
					gui.Visible = true
				else
					gui.Visible = false
				end
			end
		end
	end

	-- remove quem saiu
	for id,obj in pairs(indicators) do
		if not used[id] then
			obj:Destroy()
			indicators[id] = nil
		end
	end

end)
