-- script gui for roblox, including fly script, speedhack, infinite jump, noclip, and a built-in script loader
-- made by danny contreras 2/20/26

print("[DEBUG] Script starting...")

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[DEBUG] PlayerGui found: " .. tostring(playerGui))
print("[DEBUG] Player name: " .. player.Name)

-- config
local GUI_CONFIG = {
	toggleKey = Enum.KeyCode.U,
	primaryColor = Color3.fromRGB(25, 25, 25),
	accentColor = Color3.fromRGB(0, 150, 255),
	textColor = Color3.fromRGB(255, 255, 255),
	cornerRadius = UDim.new(0, 8)
}

-- flight config
local FLIGHT_CONFIG = {
	speed = 50,
	acceleration = 2,
	rotationSpeed = 0.1
}

-- noclip config
local NOCLIP_CONFIG = {
	speed = 50
}

-- state variables
local flyingActive = false
local noclipActive = false
local speedActive = false
local flySpeed = 0
local flyVelocity = Vector3.new(0, 0, 0)
local bodyVelocity = nil
local bodyGyro = nil

-- create main gui container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

print("[DEBUG] ScreenGui created and parented")

-- create background panel
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 350, 0, 500)
mainPanel.Position = UDim2.new(0.5, -175, 0.5, -250)
mainPanel.BackgroundColor3 = GUI_CONFIG.primaryColor
mainPanel.BorderSizePixel = 0
mainPanel.Parent = screenGui

-- add corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = GUI_CONFIG.cornerRadius
corner.Parent = mainPanel

-- add subtle border
local stroke = Instance.new("UIStroke")
stroke.Color = GUI_CONFIG.accentColor
stroke.Thickness = 2
stroke.Parent = mainPanel

-- title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = GUI_CONFIG.accentColor
titleBar.BorderSizePixel = 0
titleBar.Parent = mainPanel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = GUI_CONFIG.cornerRadius
titleCorner.Parent = titleBar

-- title text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = GUI_CONFIG.textColor
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.Text = "Tool Kit"
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local titlePadding = Instance.new("UIPadding")
titlePadding.PaddingLeft = UDim.new(0, 15)
titlePadding.Parent = titleText

-- close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.TextColor3 = GUI_CONFIG.textColor
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 5)
closeBtnCorner.Parent = closeBtn

-- content scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -50)
scrollFrame.Position = UDim2.new(0, 0, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = GUI_CONFIG.accentColor
scrollFrame.Parent = mainPanel

-- content layout
local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)
contentLayout.Parent = scrollFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.Parent = scrollFrame

-- tool buttons data
local tools = {
	{name = "Speed", color = Color3.fromRGB(255, 100, 100), action = "speed"},
	{name = "Jump", color = Color3.fromRGB(100, 200, 255), action = "jump"},
	{name = "Fly", color = Color3.fromRGB(200, 100, 255), action = "fly"},
	{name = "Noclip", color = Color3.fromRGB(100, 255, 150), action = "noclip"},
	{name = "Teleport", color = Color3.fromRGB(255, 200, 100), action = "teleport"},
	{name = "Script Loader", color = Color3.fromRGB(150, 100, 255), action = "scriptloader"},
}

-- create tool buttons
local buttons = {}
for i, tool in ipairs(tools) do
	local button = Instance.new("TextButton")
	button.Name = tool.name .. "Button"
	button.Size = UDim2.new(1, -20, 0, 45)
	button.BackgroundColor3 = tool.color
	button.TextColor3 = GUI_CONFIG.textColor
	button.TextSize = 16
	button.Font = Enum.Font.GothamBold
	button.Text = tool.name
	button.BorderSizePixel = 0
	button.Parent = scrollFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = button

	-- button click handler
	button.MouseButton1Click:Connect(function()
		print("[DEBUG] Button clicked: " .. tool.name)
		executeTool(tool.action)
	end)

	-- hover effects
	button.MouseEnter:Connect(function()
		button:TweenSize(UDim2.new(1, -20, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
	end)

	button.MouseLeave:Connect(function()
		button:TweenSize(UDim2.new(1, -20, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
	end)

	table.insert(buttons, button)
end

-- ==================== script loader ====================
local scriptLoaderVisible = false

print("[DEBUG] Creating script loader panel...")

-- create script loader panel (hidden by default)
local scriptLoaderPanel = Instance.new("Frame")
scriptLoaderPanel.Name = "ScriptLoaderPanel"
scriptLoaderPanel.Size = UDim2.new(1, 0, 0, 200)
scriptLoaderPanel.Position = UDim2.new(0, 0, 1, 0)
scriptLoaderPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scriptLoaderPanel.BorderSizePixel = 0
scriptLoaderPanel.Visible = false
scriptLoaderPanel.Parent = mainPanel

print("[DEBUG] Script loader panel created")

-- ==================== cleanup ====================
-- stop flying/noclip when player respawns
player.CharacterAdded:Connect(function(newCharacter)
	if flyingActive then
		stopFlying()
	end
	if noclipActive then
		stopNoclip()
	end
end)