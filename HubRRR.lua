-- Gui to Lua
-- Version: 3.2

-- Instances:
getgenv().Menu = getgenv().Menu or {}
local Menu = getgenv().Menu

local RRR = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local Drag = Instance.new("ImageLabel")
local Main = Instance.new("ImageLabel")
local Misc = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local M = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local CheatName = Instance.new("TextLabel")
local PowerValue = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local PowerShot = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")
local M_2 = Instance.new("Frame")
local CheatName_2 = Instance.new("TextLabel")
local KeySteal = Instance.new("TextBox")
local UICorner_4 = Instance.new("UICorner")
local AutoSteal = Instance.new("TextButton")
local UICorner_5 = Instance.new("UICorner")
local UICorner_6 = Instance.new("UICorner")
local M_3 = Instance.new("Frame")
local CheatName_3 = Instance.new("TextLabel")
local KeyAutoGoal = Instance.new("TextBox")
local UICorner_7 = Instance.new("UICorner")
local AutoGoal = Instance.new("TextButton")
local UICorner_8 = Instance.new("UICorner")
local UICorner_9 = Instance.new("UICorner")
local M_4 = Instance.new("Frame")
local CheatName_4 = Instance.new("TextLabel")
local KeyTackle = Instance.new("TextBox")
local UICorner_10 = Instance.new("UICorner")
local SpamTackle = Instance.new("TextButton")
local UICorner_11 = Instance.new("UICorner")
local UICorner_12 = Instance.new("UICorner")
local Player = Instance.new("ScrollingFrame")
local UIListLayout_2 = Instance.new("UIListLayout")
local P = Instance.new("Frame")
local UICorner_13 = Instance.new("UICorner")
local CheatName_5 = Instance.new("TextLabel")
local Metavision = Instance.new("TextButton")
local UICorner_14 = Instance.new("UICorner")
local P_2 = Instance.new("Frame")
local UICorner_15 = Instance.new("UICorner")
local CheatName_6 = Instance.new("TextLabel")
local FakeFlow = Instance.new("TextButton")
local UICorner_16 = Instance.new("UICorner")
local P_3 = Instance.new("Frame")
local UICorner_17 = Instance.new("UICorner")
local CheatName_7 = Instance.new("TextLabel")
local NoStun = Instance.new("TextButton")
local UICorner_18 = Instance.new("UICorner")
local NoStun_2 = Instance.new("TextButton")
local UICorner_19 = Instance.new("UICorner")
local Options = Instance.new("ImageLabel")
local UIListLayout_3 = Instance.new("UIListLayout")
local Misc_2 = Instance.new("TextButton")
local Player_2 = Instance.new("TextButton")
local Other = Instance.new("TextButton")
local UpBar = Instance.new("ImageLabel")
local GameTitle = Instance.new("TextLabel")
local Title = Instance.new("TextLabel")
local Minimize = Instance.new("ImageButton")

--Properties:

RRR.Name = "RRR"
RRR.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Menu.Gui = RRR
RRR.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Container.Name = "Container"
Container.Parent = RRR
Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Container.BackgroundTransparency = 1.000
Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
Container.Size = UDim2.new(1, 0, 1, 0)

Drag.Name = "Drag"
Drag.Parent = Container
Drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Drag.BackgroundTransparency = 1.000
Drag.BorderColor3 = Color3.fromRGB(0, 0, 0)
Drag.BorderSizePixel = 0
Drag.Position = UDim2.new(0.263565898, 0, 0.276972622, 0)
Drag.Size = UDim2.new(0.470284224, 0, 0.465378433, 0)
Drag.Image = "rbxassetid://132146341566959"
Drag.Active = true
Drag.Draggable = true

Main.Name = "Main"
Main.Parent = Drag
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BackgroundTransparency = 1.000
Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.152497351, 0, 0.118264891, 0)
Main.Size = UDim2.new(0.807692289, 0, 0.852507353, 0)
Main.Image = "rbxassetid://116118555895648"
Main.ImageTransparency = 0.200

Misc.Name = "Misc"
Misc.Parent = Main
Misc.Active = true
Misc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Misc.BackgroundTransparency = 1.000
Misc.BorderColor3 = Color3.fromRGB(0, 0, 0)
Misc.BorderSizePixel = 0
Misc.Position = UDim2.new(0, 0, -1.2386657e-07, 0)
Misc.Size = UDim2.new(1, 0, 0.986302912, 0)
Misc.Visible = false
Misc.CanvasSize = UDim2.new(0, 0, 0, 0)
Misc.ScrollBarThickness = 5

UIListLayout.Parent = Misc
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0.00999999978, 0)

M.Name = "M"
M.Parent = Misc
M.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
M.BackgroundTransparency = 0.800
M.BorderColor3 = Color3.fromRGB(0, 0, 0)
M.BorderSizePixel = 0
M.Size = UDim2.new(1, 0, 0.273341566, 0)

UICorner.CornerRadius = UDim.new(0.349999994, 0)
UICorner.Parent = M

CheatName.Name = "CheatName"
CheatName.Parent = M
CheatName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheatName.BackgroundTransparency = 12.000
CheatName.BorderColor3 = Color3.fromRGB(0, 0, 0)
CheatName.BorderSizePixel = 0
CheatName.Position = UDim2.new(0.0119047621, 0, 0, 0)
CheatName.Size = UDim2.new(0.239455923, 0, 1, 0)
CheatName.Font = Enum.Font.SourceSans
CheatName.Text = "PowerShot"
CheatName.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatName.TextScaled = true
CheatName.TextSize = 14.000
CheatName.TextWrapped = true

PowerValue.Name = "PowerValue"
PowerValue.Parent = M
PowerValue.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PowerValue.BackgroundTransparency = 0.800
PowerValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
PowerValue.BorderSizePixel = 0
PowerValue.Position = UDim2.new(0.278911561, 0, 0.199296623, 0)
PowerValue.Size = UDim2.new(0.340136051, 0, 0.586166561, 0)
PowerValue.Font = Enum.Font.SourceSans
PowerValue.PlaceholderColor3 = Color3.fromRGB(207, 207, 207)
PowerValue.PlaceholderText = "170-230"
PowerValue.Text = ""
PowerValue.TextColor3 = Color3.fromRGB(255, 0, 4)
PowerValue.TextScaled = true
PowerValue.TextSize = 14.000
PowerValue.TextWrapped = true

UICorner_2.CornerRadius = UDim.new(0.349999994, 0)
UICorner_2.Parent = PowerValue

PowerShot.Name = "PowerShot"
PowerShot.Parent = M
PowerShot.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
PowerShot.BorderColor3 = Color3.fromRGB(0, 0, 0)
PowerShot.BorderSizePixel = 0
PowerShot.Position = UDim2.new(0.736394584, 0, 0.257913291, 0)
PowerShot.Size = UDim2.new(0.180272102, 0, 0.480656564, 0)
PowerShot.Font = Enum.Font.SourceSans
PowerShot.Text = "OFF"
PowerShot.TextColor3 = Color3.fromRGB(255, 255, 255)
PowerShot.TextScaled = true
PowerShot.TextSize = 14.000
PowerShot.TextWrapped = true

UICorner_3.CornerRadius = UDim.new(5, 0)
UICorner_3.Parent = PowerShot

M_2.Name = "M"
M_2.Parent = Misc
M_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
M_2.BackgroundTransparency = 0.800
M_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
M_2.BorderSizePixel = 0
M_2.Size = UDim2.new(1, 0, 0.273341566, 0)

CheatName_2.Name = "CheatName"
CheatName_2.Parent = M_2
CheatName_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheatName_2.BackgroundTransparency = 12.000
CheatName_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
CheatName_2.BorderSizePixel = 0
CheatName_2.Position = UDim2.new(0.0119047621, 0, -0.0150552532, 0)
CheatName_2.Size = UDim2.new(0.239455923, 0, 1, 0)
CheatName_2.Font = Enum.Font.SourceSans
CheatName_2.Text = "AutoSteal"
CheatName_2.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatName_2.TextScaled = true
CheatName_2.TextSize = 14.000
CheatName_2.TextWrapped = true

KeySteal.Name = "KeySteal"
KeySteal.Parent = M_2
KeySteal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeySteal.BackgroundTransparency = 0.800
KeySteal.BorderColor3 = Color3.fromRGB(0, 0, 0)
KeySteal.BorderSizePixel = 0
KeySteal.Position = UDim2.new(0.278911561, 0, 0.199296623, 0)
KeySteal.Size = UDim2.new(0.340136051, 0, 0.586166561, 0)
KeySteal.Font = Enum.Font.SourceSans
KeySteal.PlaceholderColor3 = Color3.fromRGB(207, 207, 207)
KeySteal.PlaceholderText = "KEY"
KeySteal.Text = ""
KeySteal.TextColor3 = Color3.fromRGB(255, 0, 4)
KeySteal.TextScaled = true
KeySteal.TextSize = 14.000
KeySteal.TextWrapped = true

UICorner_4.CornerRadius = UDim.new(0.349999994, 0)
UICorner_4.Parent = KeySteal

AutoSteal.Name = "AutoSteal"
AutoSteal.Parent = M_2
AutoSteal.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
AutoSteal.BorderColor3 = Color3.fromRGB(0, 0, 0)
AutoSteal.BorderSizePixel = 0
AutoSteal.Position = UDim2.new(0.736394584, 0, 0.257913291, 0)
AutoSteal.Size = UDim2.new(0.180272102, 0, 0.480656564, 0)
AutoSteal.Font = Enum.Font.SourceSans
AutoSteal.Text = "OFF"
AutoSteal.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoSteal.TextScaled = true
AutoSteal.TextSize = 14.000
AutoSteal.TextWrapped = true

UICorner_5.CornerRadius = UDim.new(5, 0)
UICorner_5.Parent = AutoSteal

UICorner_6.CornerRadius = UDim.new(0.349999994, 0)
UICorner_6.Parent = M_2

M_3.Name = "M"
M_3.Parent = Misc
M_3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
M_3.BackgroundTransparency = 0.800
M_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
M_3.BorderSizePixel = 0
M_3.Size = UDim2.new(1, 0, 0.273341566, 0)

CheatName_3.Name = "CheatName"
CheatName_3.Parent = M_3
CheatName_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheatName_3.BackgroundTransparency = 12.000
CheatName_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
CheatName_3.BorderSizePixel = 0
CheatName_3.Position = UDim2.new(0.0119047621, 0, -0.0150552532, 0)
CheatName_3.Size = UDim2.new(0.239455923, 0, 1, 0)
CheatName_3.Font = Enum.Font.SourceSans
CheatName_3.Text = "AutoGoal"
CheatName_3.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatName_3.TextScaled = true
CheatName_3.TextSize = 14.000
CheatName_3.TextWrapped = true

KeyAutoGoal.Name = "KeyAutoGoal"
KeyAutoGoal.Parent = M_3
KeyAutoGoal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeyAutoGoal.BackgroundTransparency = 0.800
KeyAutoGoal.BorderColor3 = Color3.fromRGB(0, 0, 0)
KeyAutoGoal.BorderSizePixel = 0
KeyAutoGoal.Position = UDim2.new(0.278911561, 0, 0.199296623, 0)
KeyAutoGoal.Size = UDim2.new(0.340136051, 0, 0.586166561, 0)
KeyAutoGoal.Font = Enum.Font.SourceSans
KeyAutoGoal.PlaceholderColor3 = Color3.fromRGB(207, 207, 207)
KeyAutoGoal.PlaceholderText = "KEY"
KeyAutoGoal.Text = ""
KeyAutoGoal.TextColor3 = Color3.fromRGB(255, 0, 4)
KeyAutoGoal.TextScaled = true
KeyAutoGoal.TextSize = 14.000
KeyAutoGoal.TextWrapped = true

UICorner_7.CornerRadius = UDim.new(0.349999994, 0)
UICorner_7.Parent = KeyAutoGoal

AutoGoal.Name = "AutoGoal"
AutoGoal.Parent = M_3
AutoGoal.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
AutoGoal.BorderColor3 = Color3.fromRGB(0, 0, 0)
AutoGoal.BorderSizePixel = 0
AutoGoal.Position = UDim2.new(0.736394584, 0, 0.257913291, 0)
AutoGoal.Size = UDim2.new(0.180272102, 0, 0.480656564, 0)
AutoGoal.Font = Enum.Font.SourceSans
AutoGoal.Text = "OFF"
AutoGoal.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoGoal.TextScaled = true
AutoGoal.TextSize = 14.000
AutoGoal.TextWrapped = true

UICorner_8.CornerRadius = UDim.new(5, 0)
UICorner_8.Parent = AutoGoal

UICorner_9.CornerRadius = UDim.new(0.349999994, 0)
UICorner_9.Parent = M_3

M_4.Name = "M"
M_4.Parent = Misc
M_4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
M_4.BackgroundTransparency = 0.800
M_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
M_4.BorderSizePixel = 0
M_4.Size = UDim2.new(1, 0, 0.273341566, 0)

CheatName_4.Name = "CheatName"
CheatName_4.Parent = M_4
CheatName_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheatName_4.BackgroundTransparency = 12.000
CheatName_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
CheatName_4.BorderSizePixel = 0
CheatName_4.Position = UDim2.new(0.0119047621, 0, -0.0150552532, 0)
CheatName_4.Size = UDim2.new(0.239455923, 0, 1, 0)
CheatName_4.Font = Enum.Font.SourceSans
CheatName_4.Text = "SpamTackle"
CheatName_4.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatName_4.TextScaled = true
CheatName_4.TextSize = 14.000
CheatName_4.TextWrapped = true

KeyTackle.Name = "KeyTackle"
KeyTackle.Parent = M_4
KeyTackle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeyTackle.BackgroundTransparency = 0.800
KeyTackle.BorderColor3 = Color3.fromRGB(0, 0, 0)
KeyTackle.BorderSizePixel = 0
KeyTackle.Position = UDim2.new(0.278911561, 0, 0.199296623, 0)
KeyTackle.Size = UDim2.new(0.340136051, 0, 0.586166561, 0)
KeyTackle.Font = Enum.Font.SourceSans
KeyTackle.PlaceholderColor3 = Color3.fromRGB(207, 207, 207)
KeyTackle.PlaceholderText = "KEY"
KeyTackle.Text = ""
KeyTackle.TextColor3 = Color3.fromRGB(255, 0, 4)
KeyTackle.TextScaled = true
KeyTackle.TextSize = 14.000
KeyTackle.TextWrapped = true

UICorner_10.CornerRadius = UDim.new(0.349999994, 0)
UICorner_10.Parent = KeyTackle

SpamTackle.Name = "SpamTackle"
SpamTackle.Parent = M_4
SpamTackle.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
SpamTackle.BorderColor3 = Color3.fromRGB(0, 0, 0)
SpamTackle.BorderSizePixel = 0
SpamTackle.Position = UDim2.new(0.736394584, 0, 0.257913291, 0)
SpamTackle.Size = UDim2.new(0.180272102, 0, 0.480656564, 0)
SpamTackle.Font = Enum.Font.SourceSans
SpamTackle.Text = "OFF"
SpamTackle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamTackle.TextScaled = true
SpamTackle.TextSize = 14.000
SpamTackle.TextWrapped = true

UICorner_11.CornerRadius = UDim.new(5, 0)
UICorner_11.Parent = SpamTackle

UICorner_12.CornerRadius = UDim.new(0.349999994, 0)
UICorner_12.Parent = M_4

Player.Name = "Player"
Player.Parent = Main
Player.Active = true
Player.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Player.BackgroundTransparency = 1.000
Player.BorderColor3 = Color3.fromRGB(0, 0, 0)
Player.BorderSizePixel = 0
Player.Position = UDim2.new(0, 0, -1.2386657e-07, 0)
Player.Size = UDim2.new(1, 0, 0.986302912, 0)
Player.CanvasSize = UDim2.new(0, 0, 0, 0)
Player.ScrollBarThickness = 5

UIListLayout_2.Parent = Player
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_2.Padding = UDim.new(0.00999999978, 0)

P.Name = "P"
P.Parent = Player
P.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
P.BackgroundTransparency = 0.800
P.BorderColor3 = Color3.fromRGB(0, 0, 0)
P.BorderSizePixel = 0
P.Size = UDim2.new(1, 0, 0.273341566, 0)

UICorner_13.CornerRadius = UDim.new(0.349999994, 0)
UICorner_13.Parent = P

CheatName_5.Name = "CheatName"
CheatName_5.Parent = P
CheatName_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheatName_5.BackgroundTransparency = 12.000
CheatName_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
CheatName_5.BorderSizePixel = 0
CheatName_5.Position = UDim2.new(0.0102040814, 0, 0.120442025, 0)
CheatName_5.Size = UDim2.new(0.526870906, 0, 0.738569796, 0)
CheatName_5.Font = Enum.Font.SourceSans
CheatName_5.Text = "Fake Metavision"
CheatName_5.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatName_5.TextScaled = true
CheatName_5.TextSize = 14.000
CheatName_5.TextWrapped = true
CheatName_5.TextXAlignment = Enum.TextXAlignment.Left

Metavision.Name = "Metavision"
Metavision.Parent = P
Metavision.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
Metavision.BorderColor3 = Color3.fromRGB(0, 0, 0)
Metavision.BorderSizePixel = 0
Metavision.Position = UDim2.new(0.736394584, 0, 0.257913291, 0)
Metavision.Size = UDim2.new(0.180272102, 0, 0.480656564, 0)
Metavision.Font = Enum.Font.SourceSans
Metavision.Text = "OFF"
Metavision.TextColor3 = Color3.fromRGB(255, 255, 255)
Metavision.TextScaled = true
Metavision.TextSize = 14.000
Metavision.TextWrapped = true

UICorner_14.CornerRadius = UDim.new(5, 0)
UICorner_14.Parent = Metavision

P_2.Name = "P"
P_2.Parent = Player
P_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
P_2.BackgroundTransparency = 0.800
P_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
P_2.BorderSizePixel = 0
P_2.Size = UDim2.new(1, 0, 0.273341566, 0)

UICorner_15.CornerRadius = UDim.new(0.349999994, 0)
UICorner_15.Parent = P_2

CheatName_6.Name = "CheatName"
CheatName_6.Parent = P_2
CheatName_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheatName_6.BackgroundTransparency = 12.000
CheatName_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
CheatName_6.BorderSizePixel = 0
CheatName_6.Position = UDim2.new(0.0102040814, 0, 0.120442025, 0)
CheatName_6.Size = UDim2.new(0.526870906, 0, 0.738569796, 0)
CheatName_6.Font = Enum.Font.SourceSans
CheatName_6.Text = "Fake Flow"
CheatName_6.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatName_6.TextScaled = true
CheatName_6.TextSize = 14.000
CheatName_6.TextWrapped = true
CheatName_6.TextXAlignment = Enum.TextXAlignment.Left

FakeFlow.Name = "FakeFlow"
FakeFlow.Parent = P_2
FakeFlow.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
FakeFlow.BorderColor3 = Color3.fromRGB(0, 0, 0)
FakeFlow.BorderSizePixel = 0
FakeFlow.Position = UDim2.new(0.736394584, 0, 0.257913291, 0)
FakeFlow.Size = UDim2.new(0.180272102, 0, 0.480656564, 0)
FakeFlow.Font = Enum.Font.SourceSans
FakeFlow.Text = "OFF"
FakeFlow.TextColor3 = Color3.fromRGB(255, 255, 255)
FakeFlow.TextScaled = true
FakeFlow.TextSize = 14.000
FakeFlow.TextWrapped = true

UICorner_16.CornerRadius = UDim.new(5, 0)
UICorner_16.Parent = FakeFlow

P_3.Name = "P"
P_3.Parent = Player
P_3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
P_3.BackgroundTransparency = 0.800
P_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
P_3.BorderSizePixel = 0
P_3.Size = UDim2.new(1, 0, 0.273341566, 0)

UICorner_17.CornerRadius = UDim.new(0.349999994, 0)
UICorner_17.Parent = P_3

CheatName_7.Name = "CheatName"
CheatName_7.Parent = P_3
CheatName_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheatName_7.BackgroundTransparency = 12.000
CheatName_7.BorderColor3 = Color3.fromRGB(0, 0, 0)
CheatName_7.BorderSizePixel = 0
CheatName_7.Position = UDim2.new(0.0102040814, 0, 0.120442025, 0)
CheatName_7.Size = UDim2.new(0.526870906, 0, 0.738569796, 0)
CheatName_7.Font = Enum.Font.SourceSans
CheatName_7.Text = "NoStun"
CheatName_7.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatName_7.TextScaled = true
CheatName_7.TextSize = 14.000
CheatName_7.TextWrapped = true
CheatName_7.TextXAlignment = Enum.TextXAlignment.Left

NoStun.Name = "NoStun"
NoStun.Parent = P_3
NoStun.BackgroundColor3 = Color3.fromRGB(229, 0, 4)
NoStun.BorderColor3 = Color3.fromRGB(0, 0, 0)
NoStun.BorderSizePixel = 0
NoStun.Position = UDim2.new(0.736394584, 0, 0.257913291, 0)
NoStun.Size = UDim2.new(0.180272102, 0, 0.480656564, 0)
NoStun.Font = Enum.Font.SourceSans
NoStun.Text = "OFF"
NoStun.TextColor3 = Color3.fromRGB(255, 255, 255)
NoStun.TextScaled = true
NoStun.TextSize = 14.000
NoStun.TextWrapped = true

UICorner_18.CornerRadius = UDim.new(5, 0)
UICorner_18.Parent = NoStun

NoStun_2.Name = "NoStun"
NoStun_2.Parent = Player
NoStun_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
NoStun_2.BackgroundTransparency = 0.700
NoStun_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
NoStun_2.BorderSizePixel = 0
NoStun_2.Position = UDim2.new(0, 0, 0.528193593, 0)
NoStun_2.Size = UDim2.new(1, 0, 0.163784161, 0)
NoStun_2.Font = Enum.Font.SourceSans
NoStun_2.Text = "TeamSelect"
NoStun_2.TextColor3 = Color3.fromRGB(255, 255, 255)
NoStun_2.TextScaled = true
NoStun_2.TextSize = 14.000
NoStun_2.TextWrapped = true

UICorner_19.CornerRadius = UDim.new(5, 0)
UICorner_19.Parent = NoStun_2

Options.Name = "Options"
Options.Parent = Drag
Options.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Options.BackgroundTransparency = 1.000
Options.BorderColor3 = Color3.fromRGB(0, 0, 0)
Options.BorderSizePixel = 0
Options.ClipsDescendants = true
Options.Position = UDim2.new(0.00976445153, 0, 0.130605787, 0)
Options.Size = UDim2.new(0.119505495, 0, 0.831858397, 0)
Options.Image = "rbxassetid://78746999303808"

UIListLayout_3.Parent = Options
UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_3.Padding = UDim.new(0, 5)

Misc_2.Name = "Misc"
Misc_2.Parent = Options
Misc_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Misc_2.BackgroundTransparency = 1.000
Misc_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Misc_2.BorderSizePixel = 0
Misc_2.Size = UDim2.new(1, 0, 0.109929077, 0)
Misc_2.Font = Enum.Font.DenkOne
Misc_2.Text = "Misc"
Misc_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Misc_2.TextScaled = true
Misc_2.TextSize = 14.000
Misc_2.TextWrapped = true

Player_2.Name = "Player"
Player_2.Parent = Options
Player_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Player_2.BackgroundTransparency = 1.000
Player_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Player_2.BorderSizePixel = 0
Player_2.Size = UDim2.new(1, 0, 0.109929077, 0)
Player_2.Font = Enum.Font.DenkOne
Player_2.Text = "Player"
Player_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Player_2.TextScaled = true
Player_2.TextSize = 14.000
Player_2.TextWrapped = true

Other.Name = "Other"
Other.Parent = Options
Other.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Other.BackgroundTransparency = 1.000
Other.BorderColor3 = Color3.fromRGB(0, 0, 0)
Other.BorderSizePixel = 0
Other.Size = UDim2.new(1, 0, 0.109929077, 0)
Other.Font = Enum.Font.DenkOne
Other.Text = "Others"
Other.TextColor3 = Color3.fromRGB(255, 255, 255)
Other.TextScaled = true
Other.TextSize = 14.000
Other.TextWrapped = true

UpBar.Name = "UpBar"
UpBar.Parent = Drag
UpBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
UpBar.BackgroundTransparency = 1.000
UpBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
UpBar.BorderSizePixel = 0
UpBar.Position = UDim2.new(-0.000653109688, 0, -0.092589803, 0)
UpBar.Size = UDim2.new(1.00065315, 0, 0.20840925, 0)
UpBar.Image = "rbxassetid://74857124519074"

GameTitle.Name = "GameTitle"
GameTitle.Parent = UpBar
GameTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.BackgroundTransparency = 1.000
GameTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
GameTitle.BorderSizePixel = 0
GameTitle.Position = UDim2.new(0.418132603, 0, 0.250000566, 0)
GameTitle.Size = UDim2.new(0.274695545, 0, 0.449999988, 0)
GameTitle.Font = Enum.Font.Unknown
GameTitle.Text = "· Meta Lock"
GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.TextScaled = true
GameTitle.TextSize = 14.000
GameTitle.TextWrapped = true

Title.Name = "Title"
Title.Parent = UpBar
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.0175913405, 0, 0.200000569, 0)
Title.Size = UDim2.new(0.289580524, 0, 0.550000012, 0)
Title.Font = Enum.Font.Unknown
Title.Text = "R.R.R HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.TextSize = 14.000
Title.TextWrapped = true

Minimize.Name = "Minimize"
Minimize.Parent = UpBar
Minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Minimize.BackgroundTransparency = 1.000
Minimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.886378288, 0, 0.369766414, 0)
Minimize.Size = UDim2.new(0.0947225988, 0, 0.25, 0)
Minimize.Image = "rbxassetid://138567149317610"

Menu.Main = Main
Menu.Drag = Drag

Menu.Buttons = {
    PowerShot = PowerShot,
    AutoSteal = AutoSteal,
    AutoGoal = AutoGoal,
    SpamTackle = SpamTackle,
    Metavision = Metavision,
    FakeFlow = FakeFlow,
    NoStun = NoStun
}

Menu.Inputs = {
    PowerValue = PowerValue,
    KeySteal = KeySteal,
    KeyAutoGoal = KeyAutoGoal,
    KeyTackle = KeyTackle
}
