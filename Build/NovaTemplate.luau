-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    [2] = function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...)--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local isSilentAimActive = false
local isFovCircleActive = true
local fov = 200
local targetPart = "Head"
local isTriggerBotActive = false
local isAimbotActive = false
local aimbotSmoothness = 5
local aimbotKey = "RMB"
local aimbotMode = "Hold"
local aimbotEnabled = false
local menuKey = Enum.KeyCode.Insert
local menuVisible = true
local flickFuckerUsers = {}
local textChatService = game:GetService("TextChatService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lastResponseTime = 0
local RESPONSE_COOLDOWN = 3

local savedConfigs = {}
if isfile and readfile and isfile("flick_fucker_configs.json") then
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile("flick_fucker_configs.json"))
    end)
    if success then
        savedConfigs = result
    end
end

if not savedConfigs["Legit"] then
    savedConfigs["Legit"] = {
        isSilentAimActive = false,
        isAimbotActive = true,
        aimbotSmoothness = 7,
        aimbotKey = "RMB",
        aimbotMode = "Hold",
        isTriggerBotActive = false,
        isFovCircleActive = true,
        fov = 67,
        targetPart = "Head",
        isEspActive = true,
        espSettings = {
            box = true,
            boxType = "corners",
            name = true,
            distance = true,
            health = true,
            skeleton = true,
            tracers = true,
            healthBarStyle = "side"
        },
        isRadarActive = false,
        isFovArrowsActive = false,
        isHitboxExpanderActive = false,
        hitboxSize = 10
    }
end

if not savedConfigs["Rage"] then
    savedConfigs["Rage"] = {
        isSilentAimActive = true,
        isAimbotActive = false,
        aimbotSmoothness = 1,
        aimbotKey = "RMB",
        aimbotMode = "Hold",
        isTriggerBotActive = false,
        isFovCircleActive = true,
        fov = 500,
        targetPart = "Head",
        isEspActive = true,
        espSettings = {
            box = true,
            boxType = "full",
            name = true,
            distance = true,
            health = true,
            skeleton = true,
            tracers = true,
            healthBarStyle = "side"
        },
        isRadarActive = false,
        isFovArrowsActive = false,
        isHitboxExpanderActive = true,
        hitboxSize = 25
    }
end

local isEspActive = false
local espSettings = {
    box = true,
    boxType = "corners",
    name = true,
    distance = true,
    health = true,
    skeleton = true,
    tracers = false,
    healthBarStyle = "side"
}

local isHitboxExpanderActive = false
local hitboxSize = 10

local isRadarActive = false
local radarScale = 1
local isFovArrowsActive = false

local theme = {
    primary = Color3.fromRGB(255, 50, 100),
    secondary = Color3.fromRGB(150, 50, 255),
    accent = Color3.fromRGB(50, 200, 255),
    background = Color3.fromRGB(15, 15, 20),
    surface = Color3.fromRGB(25, 25, 32),
    surfaceLight = Color3.fromRGB(35, 35, 45),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(160, 160, 180),
    success = Color3.fromRGB(50, 255, 150),
    danger = Color3.fromRGB(255, 70, 70)
}

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = fov
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 50, 100)
fovCircle.Transparency = 0.8
fovCircle.Visible = isFovCircleActive

local espObjects = {}
local radarDots = {}
local fovArrows = {}

local radarBackground = Drawing.new("Circle")
radarBackground.Thickness = 2
radarBackground.NumSides = 50
radarBackground.Radius = 100
radarBackground.Filled = true
radarBackground.Color = Color3.fromRGB(15, 15, 20)
radarBackground.Transparency = 0.7
radarBackground.Visible = false

local radarBorder = Drawing.new("Circle")
radarBorder.Thickness = 3
radarBorder.NumSides = 50
radarBorder.Radius = 100
radarBorder.Filled = false
radarBorder.Color = theme.primary
radarBorder.Transparency = 0.8
radarBorder.Visible = false

local radarPlayerArrow = {
    line1 = Drawing.new("Line"),
    line2 = Drawing.new("Line"),
    line3 = Drawing.new("Line")
}

for _, line in pairs(radarPlayerArrow) do
    line.Thickness = 2
    line.Color = theme.success
    line.Transparency = 1
    line.Visible = false
end

local currentPage = "Aim"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PremiumExploitHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game.Lighting

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 550, 0, 450)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
mainFrame.BackgroundColor3 = theme.background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local glowFrame = Instance.new("ImageLabel")
glowFrame.Size = UDim2.new(1, 40, 1, 40)
glowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
glowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
glowFrame.BackgroundTransparency = 1
glowFrame.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
glowFrame.ImageColor3 = theme.primary
glowFrame.ImageTransparency = 0.8
glowFrame.ZIndex = 0
glowFrame.Parent = mainFrame

local gradientBG = Instance.new("Frame")
gradientBG.Size = UDim2.new(1, 0, 1, 0)
gradientBG.BackgroundColor3 = theme.surface
gradientBG.BackgroundTransparency = 0.95
gradientBG.BorderSizePixel = 0
gradientBG.ZIndex = 1
gradientBG.Parent = mainFrame

local gradientBGCorner = Instance.new("UICorner")
gradientBGCorner.CornerRadius = UDim.new(0, 16)
gradientBGCorner.Parent = gradientBG

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, theme.primary),
    ColorSequenceKeypoint.new(0.5, theme.secondary),
    ColorSequenceKeypoint.new(1, theme.accent)
}
gradient.Rotation = 45
gradient.Parent = gradientBG

spawn(function()
    while wait(0.05) do
        if gradient and gradient.Parent then
            gradient.Rotation = gradient.Rotation + 0.5
            if gradient.Rotation >= 360 then
                gradient.Rotation = 0
            end
        end
    end
end)

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1, 0, 0, 4)
accentBar.Position = UDim2.new(0, 0, 0, 60)
accentBar.BackgroundColor3 = theme.primary
accentBar.BorderSizePixel = 0
accentBar.ZIndex = 3
accentBar.Parent = mainFrame

local accentGradient = Instance.new("UIGradient")
accentGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, theme.primary),
    ColorSequenceKeypoint.new(0.5, theme.secondary),
    ColorSequenceKeypoint.new(1, theme.accent)
}
accentGradient.Parent = accentBar

spawn(function()
    while wait(0.03) do
        if accentGradient and accentGradient.Parent then
            accentGradient.Offset = Vector2.new(accentGradient.Offset.X + 0.01, 0)
            if accentGradient.Offset.X >= 1 then
                accentGradient.Offset = Vector2.new(-1, 0)
            end
        end
    end
end)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundTransparency = 1
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = mainFrame

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 40, 0, 40)
logo.Position = UDim2.new(0, 15, 0, 10)
logo.BackgroundColor3 = theme.primary
logo.BorderSizePixel = 0
logo.ZIndex = 3
logo.Parent = titleBar

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 10)
logoCorner.Parent = logo

local logoGradient = Instance.new("UIGradient")
logoGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, theme.primary),
    ColorSequenceKeypoint.new(1, theme.secondary)
}
logoGradient.Rotation = 45
logoGradient.Parent = logo

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "⚡"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.TextSize = 24
logoText.Font = Enum.Font.GothamBold
logoText.ZIndex = 4
logoText.Parent = logo

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 0, 25)
title.Position = UDim2.new(0, 65, 0, 8)
title.BackgroundTransparency = 1
title.Text = "flick fucker made by @.9177"
title.TextColor3 = theme.text
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = titleBar

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, theme.primary),
    ColorSequenceKeypoint.new(1, theme.accent)
}
titleGradient.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 300, 0, 20)
subtitle.Position = UDim2.new(0, 65, 0, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "flick fucker made by @.9177 "
subtitle.TextColor3 = theme.textDim
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 3
subtitle.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 38, 0, 38)
closeButton.Position = UDim2.new(1, -50, 0, 11)
closeButton.BackgroundColor3 = theme.danger
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 22
closeButton.Font = Enum.Font.GothamBold
closeButton.ZIndex = 3
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

closeButton.MouseEnter:Connect(function()
    tweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    tweenService:Create(closeButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 42, 0, 42)}):Play()
end)

closeButton.MouseLeave:Connect(function()
    tweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.danger}):Play()
    tweenService:Create(closeButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 38, 0, 38)}):Play()
end)

local sidebarContainer = Instance.new("Frame")
sidebarContainer.Size = UDim2.new(0, 150, 1, -64)
sidebarContainer.Position = UDim2.new(0, 0, 0, 64)
sidebarContainer.BackgroundColor3 = theme.surface
sidebarContainer.BackgroundTransparency = 0.3
sidebarContainer.BorderSizePixel = 0
sidebarContainer.ZIndex = 2
sidebarContainer.Parent = mainFrame

local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Size = UDim2.new(1, -160, 1, -74)
contentContainer.Position = UDim2.new(0, 155, 0, 69)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ClipsDescendants = true
contentContainer.ZIndex = 2
contentContainer.ScrollBarThickness = 4
contentContainer.ScrollBarImageColor3 = theme.primary
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.Parent = mainFrame

local pageIndicator = Instance.new("Frame")
pageIndicator.Size = UDim2.new(0, 4, 0, 45)
pageIndicator.Position = UDim2.new(0, 0, 0, 10)
pageIndicator.BackgroundColor3 = theme.primary
pageIndicator.BorderSizePixel = 0
pageIndicator.ZIndex = 4
pageIndicator.Parent = sidebarContainer

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = pageIndicator

local pageButtons = {}
local pages = {
    {name = "Aim", icon = "🎯"},
    {name = "Visuals", icon = "👁"},
    {name = "Misc", icon = "✨"},
    {name = "Settings", icon = "⚙️"}
}

for i, pageData in ipairs(pages) do
    local pageButton = Instance.new("TextButton")
    pageButton.Size = UDim2.new(1, -15, 0, 45)
    pageButton.Position = UDim2.new(0, 7, 0, 5 + (i - 1) * 55)
    pageButton.BackgroundColor3 = theme.surface
    pageButton.BackgroundTransparency = 1
    pageButton.BorderSizePixel = 0
    pageButton.Text = ""
    pageButton.ZIndex = 3
    pageButton.Parent = sidebarContainer
    
    local buttonIcon = Instance.new("TextLabel")
    buttonIcon.Size = UDim2.new(0, 30, 1, 0)
    buttonIcon.Position = UDim2.new(0, 10, 0, 0)
    buttonIcon.BackgroundTransparency = 1
    buttonIcon.Text = pageData.icon
    buttonIcon.TextColor3 = theme.textDim
    buttonIcon.TextSize = 18
    buttonIcon.Font = Enum.Font.GothamBold
    buttonIcon.ZIndex = 4
    buttonIcon.Parent = pageButton
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Size = UDim2.new(1, -45, 1, 0)
    buttonLabel.Position = UDim2.new(0, 40, 0, 0)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Text = pageData.name
    buttonLabel.TextColor3 = theme.textDim
    buttonLabel.TextSize = 13
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonLabel.ZIndex = 4
    buttonLabel.Parent = pageButton
    
    pageButtons[pageData.name] = {
        button = pageButton,
        icon = buttonIcon,
        label = buttonLabel
    }
    
    pageButton.MouseEnter:Connect(function()
        if currentPage ~= pageData.name then
            tweenService:Create(buttonIcon, TweenInfo.new(0.2), {TextColor3 = theme.text}):Play()
            tweenService:Create(buttonLabel, TweenInfo.new(0.2), {TextColor3 = theme.text}):Play()
        end
    end)
    
    pageButton.MouseLeave:Connect(function()
        if currentPage ~= pageData.name then
            tweenService:Create(buttonIcon, TweenInfo.new(0.2), {TextColor3 = theme.textDim}):Play()
            tweenService:Create(buttonLabel, TweenInfo.new(0.2), {TextColor3 = theme.textDim}):Play()
        end
    end)
end

local function createToggle(name, position, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 45)
    toggleFrame.Position = position
    toggleFrame.BackgroundColor3 = theme.surface
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 3
    toggleFrame.Parent = contentContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = toggleFrame
    
    local toggleBG = Instance.new("Frame")
    toggleBG.Size = UDim2.new(0, 50, 0, 26)
    toggleBG.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBG.BackgroundColor3 = defaultState and theme.success or theme.surfaceLight
    toggleBG.BorderSizePixel = 0
    toggleBG.ZIndex = 4
    toggleBG.Parent = toggleFrame
    
    local toggleBGCorner = Instance.new("UICorner")
    toggleBGCorner.CornerRadius = UDim.new(1, 0)
    toggleBGCorner.Parent = toggleBG
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = defaultState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 5
    toggleCircle.Parent = toggleBG
    
    local toggleCircleCorner = Instance.new("UICorner")
    toggleCircleCorner.CornerRadius = UDim.new(1, 0)
    toggleCircleCorner.Parent = toggleCircle
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.ZIndex = 6
    toggleButton.Parent = toggleFrame
    
    local state = defaultState
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        tweenService:Create(toggleBG, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and theme.success or theme.surfaceLight
        }):Play()
        
        tweenService:Create(toggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }):Play()
    end)
    
    return toggleFrame
end

local function createTextInput(name, position, defaultValue, callback)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, 0, 0, 45)
    inputFrame.Position = position
    inputFrame.BackgroundColor3 = theme.surface
    inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 3
    inputFrame.Parent = contentContainer
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 80, 0, 30)
    textBox.Position = UDim2.new(1, -90, 0.5, -15)
    textBox.BackgroundColor3 = theme.surfaceLight
    textBox.BorderSizePixel = 0
    textBox.Text = tostring(defaultValue)
    textBox.TextColor3 = theme.primary
    textBox.TextSize = 13
    textBox.Font = Enum.Font.GothamBold
    textBox.PlaceholderText = "Enter size"
    textBox.PlaceholderColor3 = theme.textDim
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 4
    textBox.Parent = inputFrame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 8)
    textBoxCorner.Parent = textBox
    
    textBox.FocusLost:Connect(function(enterPressed)
        local value = tonumber(textBox.Text)
        if value then
            value = math.clamp(value, 1, 100)
            textBox.Text = tostring(value)
            callback(value)
            
            tweenService:Create(textBox, TweenInfo.new(0.2), {BackgroundColor3 = theme.success}):Play()
            wait(0.2)
            tweenService:Create(textBox, TweenInfo.new(0.3), {BackgroundColor3 = theme.surfaceLight}):Play()
        else
            textBox.Text = tostring(defaultValue)
            
            tweenService:Create(textBox, TweenInfo.new(0.2), {BackgroundColor3 = theme.danger}):Play()
            wait(0.2)
            tweenService:Create(textBox, TweenInfo.new(0.3), {BackgroundColor3 = theme.surfaceLight}):Play()
        end
    end)
    
    return inputFrame
end

local function createSlider(name, position, min, max, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 70)
    sliderFrame.Position = position
    sliderFrame.BackgroundColor3 = theme.surface
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = 3
    sliderFrame.Parent = contentContainer
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 25)
    label.Position = UDim2.new(0, 15, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 25)
    valueLabel.Position = UDim2.new(1, -70, 0, 8)
    valueLabel.BackgroundColor3 = theme.surfaceLight
    valueLabel.BorderSizePixel = 0
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = theme.primary
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.ZIndex = 4
    valueLabel.Parent = sliderFrame
    
    local valueLabelCorner = Instance.new("UICorner")
    valueLabelCorner.CornerRadius = UDim.new(0, 6)
    valueLabelCorner.Parent = valueLabel
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, -30, 0, 6)
    sliderBG.Position = UDim2.new(0, 15, 1, -20)
    sliderBG.BackgroundColor3 = theme.surfaceLight
    sliderBG.BorderSizePixel = 0
    sliderBG.ZIndex = 4
    sliderBG.Parent = sliderFrame
    
    local sliderBGCorner = Instance.new("UICorner")
    sliderBGCorner.CornerRadius = UDim.new(1, 0)
    sliderBGCorner.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = theme.primary
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 5
    sliderFill.Parent = sliderBG
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local sliderGradient = Instance.new("UIGradient")
    sliderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.primary),
        ColorSequenceKeypoint.new(1, theme.secondary)
    }
    sliderGradient.Parent = sliderFill
    
    local sliderButton = Instance.new("Frame")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.ZIndex = 6
    sliderButton.Parent = sliderBG
    
    local sliderButtonCorner = Instance.new("UICorner")
    sliderButtonCorner.CornerRadius = UDim.new(1, 0)
    sliderButtonCorner.Parent = sliderButton
    
    local dragging = false
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = userInputService:GetMouseLocation().X
            local sliderPos = sliderBG.AbsolutePosition.X
            local sliderSize = sliderBG.AbsoluteSize.X
            
            local value = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local actualValue = math.floor(min + (max - min) * value)
            
            valueLabel.Text = tostring(actualValue)
            callback(actualValue)
            
            tweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(value, 0, 1, 0)}):Play()
            tweenService:Create(sliderButton, TweenInfo.new(0.1), {Position = UDim2.new(value, -8, 0.5, -8)}):Play()
        end
    end)
    
    return sliderFrame
end

local function createDropdown(name, position, options, defaultOption, callback)
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, 45)
    dropFrame.Position = position
    dropFrame.BackgroundColor3 = theme.surface
    dropFrame.BorderSizePixel = 0
    dropFrame.ZIndex = 3
    dropFrame.Parent = contentContainer
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 10)
    dropCorner.Parent = dropFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = dropFrame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.52, 0, 0, 30)
    dropdown.Position = UDim2.new(0.48, -5, 0.5, -15)
    dropdown.BackgroundColor3 = theme.surfaceLight
    dropdown.BorderSizePixel = 0
    dropdown.Text = defaultOption .. " ▼"
    dropdown.TextColor3 = theme.text
    dropdown.TextSize = 12
    dropdown.Font = Enum.Font.Gotham
    dropdown.ZIndex = 4
    dropdown.Parent = dropFrame
    
    local dropCorner2 = Instance.new("UICorner")
    dropCorner2.CornerRadius = UDim.new(0, 8)
    dropCorner2.Parent = dropdown
    
    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == defaultOption then
            currentIndex = i
            break
        end
    end
    
    dropdown.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        dropdown.Text = options[currentIndex] .. " ▼"
        callback(options[currentIndex])
        
        tweenService:Create(dropdown, TweenInfo.new(0.1), {BackgroundColor3 = theme.primary}):Play()
        wait(0.1)
        tweenService:Create(dropdown, TweenInfo.new(0.2), {BackgroundColor3 = theme.surfaceLight}):Play()
    end)
    
    return dropFrame
end

local function updateCanvasSize()
    local contentHeight = 0
    for _, child in pairs(contentContainer:GetChildren()) do
        if child:IsA("Frame") then
            contentHeight = math.max(contentHeight, child.Position.Y.Offset + child.Size.Y.Offset)
        end
    end
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
end

local pageContent = {}

local function saveCurrentConfig(name)
    savedConfigs[name] = {
        isSilentAimActive = isSilentAimActive,
        isAimbotActive = isAimbotActive,
        aimbotSmoothness = aimbotSmoothness,
        aimbotKey = aimbotKey,
        aimbotMode = aimbotMode,
        isTriggerBotActive = isTriggerBotActive,
        isFovCircleActive = isFovCircleActive,
        fov = fov,
        targetPart = targetPart,
        isEspActive = isEspActive,
        espSettings = {
            box = espSettings.box,
            boxType = espSettings.boxType,
            name = espSettings.name,
            distance = espSettings.distance,
            health = espSettings.health,
            skeleton = espSettings.skeleton,
            tracers = espSettings.tracers,
            healthBarStyle = espSettings.healthBarStyle
        },
        isRadarActive = isRadarActive,
        isFovArrowsActive = isFovArrowsActive,
        isHitboxExpanderActive = isHitboxExpanderActive,
        hitboxSize = hitboxSize
    }
    
    if writefile then
        local success, err = pcall(function()
            writefile("flick_fucker_configs.json", game:GetService("HttpService"):JSONEncode(savedConfigs))
        end)
        if success then
            print("Config '" .. name .. "' saved successfully!")
        else
            warn("Failed to save config: " .. tostring(err))
        end
    end
end

local function deleteConfig(name)
    if savedConfigs[name] then
        savedConfigs[name] = nil
        
        if writefile then
            local success, err = pcall(function()
                writefile("flick_fucker_configs.json", game:GetService("HttpService"):JSONEncode(savedConfigs))
            end)
            if success then
                print("Config '" .. name .. "' deleted successfully!")
                return true
            else
                warn("Failed to delete config: " .. tostring(err))
                return false
            end
        end
    end
    return false
end

local function loadConfig(name)
    if savedConfigs[name] then
        local config = savedConfigs[name]
        
        isSilentAimActive = config.isSilentAimActive
        isAimbotActive = config.isAimbotActive
        aimbotSmoothness = config.aimbotSmoothness
        aimbotKey = config.aimbotKey
        aimbotMode = config.aimbotMode
        isTriggerBotActive = config.isTriggerBotActive
        isFovCircleActive = config.isFovCircleActive
        fov = config.fov
        targetPart = config.targetPart
        isEspActive = config.isEspActive
        
        for k, v in pairs(config.espSettings) do
            espSettings[k] = v
        end
        
        isRadarActive = config.isRadarActive
        isFovArrowsActive = config.isFovArrowsActive
        isHitboxExpanderActive = config.isHitboxExpanderActive
        hitboxSize = config.hitboxSize
        
        fovCircle.Radius = fov
        fovCircle.Visible = isFovCircleActive
        radarBackground.Visible = isRadarActive
        radarBorder.Visible = isRadarActive
        
        for _, line in pairs(radarPlayerArrow) do
            line.Visible = isRadarActive
        end
        
        if isEspActive then
            for _, plr in pairs(game.Players:GetPlayers()) do
                if not espObjects[plr] and plr ~= player then
                    createESP(plr)
                end
            end
        end
        
        return true
    end
    return false
end

pageContent["Aim"] = function()
    contentContainer:ClearAllChildren()
    
    local yPos = 0
    
    createToggle("Silent Aim", UDim2.new(0, 5, 0, yPos), isSilentAimActive, function(state)
        isSilentAimActive = state
    end)
    yPos = yPos + 52
    
    createToggle("Aimbot", UDim2.new(0, 5, 0, yPos), isAimbotActive, function(state)
        isAimbotActive = state
    end)
    yPos = yPos + 52
    
    createSlider("Aimbot Smoothness", UDim2.new(0, 5, 0, yPos), 1, 20, aimbotSmoothness, function(value)
        aimbotSmoothness = value
    end)
    yPos = yPos + 77
    
    createDropdown("Aimbot Key", UDim2.new(0, 5, 0, yPos), {"RMB", "X", "C", "Z", "V", "B", "N", "M"}, aimbotKey, function(value)
        aimbotKey = value
    end)
    yPos = yPos + 52
    
    createDropdown("Aimbot Mode", UDim2.new(0, 5, 0, yPos), {"Hold", "Toggle"}, aimbotMode, function(value)
        aimbotMode = value
        if aimbotMode == "Toggle" then
            aimbotEnabled = false
        end
    end)
    yPos = yPos + 52
    
    createToggle("Trigger Bot", UDim2.new(0, 5, 0, yPos), isTriggerBotActive, function(state)
        isTriggerBotActive = state
    end)
    yPos = yPos + 52
    
    createToggle("FOV Circle", UDim2.new(0, 5, 0, yPos), isFovCircleActive, function(state)
        isFovCircleActive = state
        fovCircle.Visible = state
    end)
    yPos = yPos + 52
    
    createSlider("FOV Radius", UDim2.new(0, 5, 0, yPos), 50, 500, fov, function(value)
        fov = value
        fovCircle.Radius = value
    end)
    yPos = yPos + 77
    
    createDropdown("Target Part", UDim2.new(0, 5, 0, yPos), {"Head", "Torso", "HumanoidRootPart"}, targetPart, function(value)
        targetPart = value
    end)
    
    updateCanvasSize()
end

pageContent["Visuals"] = function()
    contentContainer:ClearAllChildren()
    
    local yPos = 0
    
    createToggle("ESP", UDim2.new(0, 5, 0, yPos), isEspActive, function(state)
        isEspActive = state
        if state then
            for _, plr in pairs(game.Players:GetPlayers()) do
                if not espObjects[plr] and plr ~= player then
                    createESP(plr)
                end
            end
        end
    end)
    yPos = yPos + 52
    
    createDropdown("Box Style", UDim2.new(0, 5, 0, yPos), {"corners", "full"}, espSettings.boxType, function(value)
        espSettings.boxType = value
    end)
    yPos = yPos + 52
    
    createToggle("Show Box", UDim2.new(0, 5, 0, yPos), espSettings.box, function(state)
        espSettings.box = state
    end)
    yPos = yPos + 52
    
    createToggle("Show Name", UDim2.new(0, 5, 0, yPos), espSettings.name, function(state)
        espSettings.name = state
    end)
    yPos = yPos + 52
    
    createToggle("Show Distance", UDim2.new(0, 5, 0, yPos), espSettings.distance, function(state)
        espSettings.distance = state
    end)
    yPos = yPos + 52
    
    createToggle("Show Health", UDim2.new(0, 5, 0, yPos), espSettings.health, function(state)
        espSettings.health = state
    end)
    yPos = yPos + 52
    
    createToggle("Show Skeleton", UDim2.new(0, 5, 0, yPos), espSettings.skeleton, function(state)
        espSettings.skeleton = state
    end)
    yPos = yPos + 52
    
    createToggle("Show Tracers", UDim2.new(0, 5, 0, yPos), espSettings.tracers, function(state)
        espSettings.tracers = state
    end)
    yPos = yPos + 52
    
    createToggle("Radar Map - pretty shitty", UDim2.new(0, 5, 0, yPos), isRadarActive, function(state)
        isRadarActive = state
        radarBackground.Visible = state
        radarBorder.Visible = state
        for _, line in pairs(radarPlayerArrow) do
            line.Visible = state
        end
    end)
    yPos = yPos + 52
    
    createSlider("Radar Scale", UDim2.new(0, 5, 0, yPos), 1, 3, radarScale, function(value)
        radarScale = value
    end)
    yPos = yPos + 77
    
    createToggle("FOV Arrows - also pretty shitty", UDim2.new(0, 5, 0, yPos), isFovArrowsActive, function(state)
        isFovArrowsActive = state
    end)
    
    updateCanvasSize()
end

pageContent["Misc"] = function()
    contentContainer:ClearAllChildren()
    
    local yPos = 5
    
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, 0, 0, 120)
    infoFrame.Position = UDim2.new(0, 5, 0, yPos)
    infoFrame.BackgroundColor3 = theme.surface
    infoFrame.BorderSizePixel = 0
    infoFrame.ZIndex = 3
    infoFrame.Parent = contentContainer
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 10)
    infoCorner.Parent = infoFrame
    
    local infoGradient = Instance.new("UIGradient")
    infoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.primary),
        ColorSequenceKeypoint.new(1, theme.secondary)
    }
    infoGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(1, 0.95)
    }
    infoGradient.Rotation = 45
    infoGradient.Parent = infoFrame
    
    local infoTitle = Instance.new("TextLabel")
    infoTitle.Size = UDim2.new(1, -30, 0, 30)
    infoTitle.Position = UDim2.new(0, 15, 0, 10)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "flick fucker made by @.9177"
    infoTitle.TextColor3 = theme.text
    infoTitle.TextSize = 16
    infoTitle.Font = Enum.Font.GothamBold
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left
    infoTitle.ZIndex = 4
    infoTitle.Parent = infoFrame
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -30, 0, 70)
    infoText.Position = UDim2.new(0, 15, 0, 40)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Version: Free\nStatus: Working\nFeatures: Aimbot, Silent Aim, Trigger Bot, ESP\nDeveloper: @.9177 on cord, period at the start btw"
    infoText.TextColor3 = theme.textDim
    infoText.TextSize = 11
    infoText.Font = Enum.Font.Gotham
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.ZIndex = 4
    infoText.Parent = infoFrame
    
    yPos = yPos + 130
    
    createToggle("Hitbox Expander", UDim2.new(0, 5, 0, yPos), isHitboxExpanderActive, function(state)
        isHitboxExpanderActive = state
    end)
    yPos = yPos + 52
    
    createTextInput("Hitbox Size", UDim2.new(0, 5, 0, yPos), hitboxSize, function(value)
        hitboxSize = value
    end)
    yPos = yPos + 52

    local bypassButton = Instance.new("TextButton")
    bypassButton.Size = UDim2.new(1, 0, 0, 45)
    bypassButton.Position = UDim2.new(0, 5, 0, yPos)
    bypassButton.BackgroundColor3 = theme.surface
    bypassButton.BorderSizePixel = 0
    bypassButton.Text = ""
    bypassButton.ZIndex = 3
    bypassButton.Parent = contentContainer

    local bypassCorner = Instance.new("UICorner")
    bypassCorner.CornerRadius = UDim.new(0, 10)
    bypassCorner.Parent = bypassButton

    local bypassLabel = Instance.new("TextLabel")
    bypassLabel.Size = UDim2.new(0.6, 0, 1, 0)
    bypassLabel.Position = UDim2.new(0, 15, 0, 0)
    bypassLabel.BackgroundTransparency = 1
    bypassLabel.Text = "delete anticheat lol - optional"
    bypassLabel.TextColor3 = theme.text
    bypassLabel.TextSize = 13
    bypassLabel.Font = Enum.Font.GothamSemibold
    bypassLabel.TextXAlignment = Enum.TextXAlignment.Left
    bypassLabel.ZIndex = 4
    bypassLabel.Parent = bypassButton

    local bypassClickButton = Instance.new("TextButton")
    bypassClickButton.Size = UDim2.new(0, 80, 0, 30)
    bypassClickButton.Position = UDim2.new(1, -90, 0.5, -15)
    bypassClickButton.BackgroundColor3 = theme.primary
    bypassClickButton.BorderSizePixel = 0
    bypassClickButton.Text = "Execute"
    bypassClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    bypassClickButton.TextSize = 12
    bypassClickButton.Font = Enum.Font.GothamBold
    bypassClickButton.ZIndex = 4
    bypassClickButton.Parent = bypassButton

    local bypassClickCorner = Instance.new("UICorner")
    bypassClickCorner.CornerRadius = UDim.new(0, 8)
    bypassClickCorner.Parent = bypassClickButton

    bypassClickButton.MouseButton1Click:Connect(function()
        tweenService:Create(bypassClickButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.success}):Play()
        bypassClickButton.Text = "Loading..."
        
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua"))()
        end)
        
        wait(0.5)
        bypassClickButton.Text = "Done!"
        wait(0.3)
        bypassClickButton.Text = "Execute"
        tweenService:Create(bypassClickButton, TweenInfo.new(0.3), {BackgroundColor3 = theme.primary}):Play()
    end)

    bypassClickButton.MouseEnter:Connect(function()
        tweenService:Create(bypassClickButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 120)}):Play()
    end)

    bypassClickButton.MouseLeave:Connect(function()
        tweenService:Create(bypassClickButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.primary}):Play()
    end)

    yPos = yPos + 52

    local crosshairToggle = createToggle("Crosshair", UDim2.new(0, 5, 0, yPos), false, function(state)
        if state then
            _G.Crosshair = Drawing.new("Circle")
            _G.Crosshair.Thickness = 2
            _G.Crosshair.NumSides = 20
            _G.Crosshair.Radius = 8
            _G.Crosshair.Filled = false
            _G.Crosshair.Color = Color3.fromRGB(255, 255, 255)
            _G.Crosshair.Transparency = 1
            _G.Crosshair.Visible = true
            
            _G.CrosshairLine1 = Drawing.new("Line")
            _G.CrosshairLine1.Thickness = 2
            _G.CrosshairLine1.Color = Color3.fromRGB(255, 255, 255)
            _G.CrosshairLine1.Transparency = 1
            _G.CrosshairLine1.Visible = true
            
            _G.CrosshairLine2 = Drawing.new("Line")
            _G.CrosshairLine2.Thickness = 2
            _G.CrosshairLine2.Color = Color3.fromRGB(255, 255, 255)
            _G.CrosshairLine2.Transparency = 1
            _G.CrosshairLine2.Visible = true
            
            _G.CrosshairLine3 = Drawing.new("Line")
            _G.CrosshairLine3.Thickness = 2
            _G.CrosshairLine3.Color = Color3.fromRGB(255, 255, 255)
            _G.CrosshairLine3.Transparency = 1
            _G.CrosshairLine3.Visible = true
            
            _G.CrosshairLine4 = Drawing.new("Line")
            _G.CrosshairLine4.Thickness = 2
            _G.CrosshairLine4.Color = Color3.fromRGB(255, 255, 255)
            _G.CrosshairLine4.Transparency = 1
            _G.CrosshairLine4.Visible = true
            
            _G.CrosshairConnection = runService.RenderStepped:Connect(function()
                local centerX = camera.ViewportSize.X / 2
                local centerY = camera.ViewportSize.Y / 2
                
                _G.Crosshair.Position = Vector2.new(centerX, centerY)
                
                local gap = 12
                local length = 8
                
                _G.CrosshairLine1.From = Vector2.new(centerX, centerY - gap)
                _G.CrosshairLine1.To = Vector2.new(centerX, centerY - gap - length)
                
                _G.CrosshairLine2.From = Vector2.new(centerX, centerY + gap)
                _G.CrosshairLine2.To = Vector2.new(centerX, centerY + gap + length)
                
                _G.CrosshairLine3.From = Vector2.new(centerX - gap, centerY)
                _G.CrosshairLine3.To = Vector2.new(centerX - gap - length, centerY)
                
                _G.CrosshairLine4.From = Vector2.new(centerX + gap, centerY)
                _G.CrosshairLine4.To = Vector2.new(centerX + gap + length, centerY)
            end)
        else
            if _G.Crosshair then
                _G.Crosshair:Remove()
                _G.Crosshair = nil
            end
            if _G.CrosshairLine1 then
                _G.CrosshairLine1:Remove()
                _G.CrosshairLine1 = nil
            end
            if _G.CrosshairLine2 then
                _G.CrosshairLine2:Remove()
                _G.CrosshairLine2 = nil
            end
            if _G.CrosshairLine3 then
                _G.CrosshairLine3:Remove()
                _G.CrosshairLine3 = nil
            end
            if _G.CrosshairLine4 then
                _G.CrosshairLine4:Remove()
                _G.CrosshairLine4 = nil
            end
            if _G.CrosshairConnection then
                _G.CrosshairConnection:Disconnect()
                _G.CrosshairConnection = nil
            end
        end
    end)
    yPos = yPos + 52

    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 100)
    statusFrame.Position = UDim2.new(0, 5, 0, yPos)
    statusFrame.BackgroundColor3 = theme.surface
    statusFrame.BorderSizePixel = 0
    statusFrame.ZIndex = 3
    statusFrame.Parent = contentContainer
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Size = UDim2.new(1, -30, 0, 25)
    statusTitle.Position = UDim2.new(0, 15, 0, 10)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Text = "stuff"
    statusTitle.TextColor3 = theme.text
    statusTitle.TextSize = 13
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.ZIndex = 4
    statusTitle.Parent = statusFrame
    
    local function createStatusDot(text, yOffset, active)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0, 15, 0, yOffset)
        dot.BackgroundColor3 = active and theme.success or theme.danger
        dot.BorderSizePixel = 0
        dot.ZIndex = 4
        dot.Parent = statusFrame
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -35, 0, 20)
        statusLabel.Position = UDim2.new(0, 28, 0, yOffset - 6)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = text
        statusLabel.TextColor3 = theme.textDim
        statusLabel.TextSize = 11
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.ZIndex = 4
        statusLabel.Parent = statusFrame
        
        return dot
    end
    
    createStatusDot("Aimbot", 45, true)
    createStatusDot("Silent Aim", 65, true)
    createStatusDot("Trigger Bot", 85, true)
    
    updateCanvasSize()
end

pageContent["Settings"] = function()
    contentContainer:ClearAllChildren()
    
    local yPos = 5
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 0, 80)
    keybindFrame.Position = UDim2.new(0, 5, 0, yPos)
    keybindFrame.BackgroundColor3 = theme.surface
    keybindFrame.BorderSizePixel = 0
    keybindFrame.ZIndex = 3
    keybindFrame.Parent = contentContainer
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 10)
    keybindCorner.Parent = keybindFrame
    
    local keybindTitle = Instance.new("TextLabel")
    keybindTitle.Size = UDim2.new(1, -30, 0, 25)
    keybindTitle.Position = UDim2.new(0, 15, 0, 10)
    keybindTitle.BackgroundTransparency = 1
    keybindTitle.Text = "Menu Keybind"
    keybindTitle.TextColor3 = theme.text
    keybindTitle.TextSize = 14
    keybindTitle.Font = Enum.Font.GothamBold
    keybindTitle.TextXAlignment = Enum.TextXAlignment.Left
    keybindTitle.ZIndex = 4
    keybindTitle.Parent = keybindFrame
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(1, -30, 0, 32)
    keybindButton.Position = UDim2.new(0, 15, 0, 40)
    keybindButton.BackgroundColor3 = theme.surfaceLight
    keybindButton.BorderSizePixel = 0
    keybindButton.Text = menuKey.Name
    keybindButton.TextColor3 = theme.primary
    keybindButton.TextSize = 13
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.ZIndex = 4
    keybindButton.Parent = keybindFrame
    
    local keybindCorner2 = Instance.new("UICorner")
    keybindCorner2.CornerRadius = UDim.new(0, 8)
    keybindCorner2.Parent = keybindButton
    
    local waitingForKey = false
    keybindButton.MouseButton1Click:Connect(function()
        waitingForKey = true
        keybindButton.Text = "Press any key..."
        keybindButton.TextColor3 = theme.accent
    end)
    
    userInputService.InputBegan:Connect(function(input, gameProcessed)
        if waitingForKey and input.KeyCode ~= Enum.KeyCode.Unknown then
            menuKey = input.KeyCode
            keybindButton.Text = input.KeyCode.Name
            keybindButton.TextColor3 = theme.primary
            waitingForKey = false
        end
    end)
    
    yPos = yPos + 90
    
    local configListFrame = Instance.new("Frame")
    configListFrame.Size = UDim2.new(1, 0, 0, 145)
    configListFrame.Position = UDim2.new(0, 5, 0, yPos)
    configListFrame.BackgroundColor3 = theme.surface
    configListFrame.BorderSizePixel = 0
    configListFrame.ZIndex = 3
    configListFrame.Parent = contentContainer
    
    local configListCorner = Instance.new("UICorner")
    configListCorner.CornerRadius = UDim.new(0, 10)
    configListCorner.Parent = configListFrame
    
    local configTitle = Instance.new("TextLabel")
    configTitle.Size = UDim2.new(1, -30, 0, 25)
    configTitle.Position = UDim2.new(0, 15, 0, 10)
    configTitle.BackgroundTransparency = 1
    configTitle.Text = "Preloaded Configs"
    configTitle.TextColor3 = theme.text
    configTitle.TextSize = 14
    configTitle.Font = Enum.Font.GothamBold
    configTitle.TextXAlignment = Enum.TextXAlignment.Left
    configTitle.ZIndex = 4
    configTitle.Parent = configListFrame
    
    local function createConfigButton(configName, yOffset, parent)
        local configBtn = Instance.new("TextButton")
        configBtn.Size = UDim2.new(1, -30, 0, 35)
        configBtn.Position = UDim2.new(0, 15, 0, yOffset)
        configBtn.BackgroundColor3 = theme.surfaceLight
        configBtn.BorderSizePixel = 0
        configBtn.Text = ""
        configBtn.ZIndex = 4
        configBtn.Parent = parent
        
        local configBtnCorner = Instance.new("UICorner")
        configBtnCorner.CornerRadius = UDim.new(0, 8)
        configBtnCorner.Parent = configBtn
        
        local configNameLabel = Instance.new("TextLabel")
        configNameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        configNameLabel.Position = UDim2.new(0, 10, 0, 0)
        configNameLabel.BackgroundTransparency = 1
        configNameLabel.Text = configName
        configNameLabel.TextColor3 = theme.text
        configNameLabel.TextSize = 12
        configNameLabel.Font = Enum.Font.GothamSemibold
        configNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        configNameLabel.ZIndex = 5
        configNameLabel.Parent = configBtn
        
        local loadBtn = Instance.new("TextButton")
        loadBtn.Size = UDim2.new(0, 60, 0, 25)
        loadBtn.Position = UDim2.new(1, -70, 0.5, -12.5)
        loadBtn.BackgroundColor3 = theme.success
        loadBtn.BorderSizePixel = 0
        loadBtn.Text = "Load"
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadBtn.TextSize = 11
        loadBtn.Font = Enum.Font.GothamBold
        loadBtn.ZIndex = 5
        loadBtn.Parent = configBtn
        
        local loadBtnCorner = Instance.new("UICorner")
        loadBtnCorner.CornerRadius = UDim.new(0, 6)
        loadBtnCorner.Parent = loadBtn
        
        loadBtn.MouseButton1Click:Connect(function()
            local success = loadConfig(configName)
            if success then
                tweenService:Create(loadBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 255, 150)}):Play()
                wait(0.2)
                tweenService:Create(loadBtn, TweenInfo.new(0.3), {BackgroundColor3 = theme.success}):Play()
            else
                tweenService:Create(loadBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.danger}):Play()
                wait(0.2)
                tweenService:Create(loadBtn, TweenInfo.new(0.3), {BackgroundColor3 = theme.success}):Play()
            end
        end)
        
        loadBtn.MouseEnter:Connect(function()
            tweenService:Create(loadBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 255, 170)}):Play()
        end)
        
        loadBtn.MouseLeave:Connect(function()
            tweenService:Create(loadBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.success}):Play()
        end)
    end
    
    createConfigButton("Legit", 45, configListFrame)
    createConfigButton("Rage", 88, configListFrame)
    
    yPos = yPos + 155
    
    local savedConfigsList = {}
    for name, _ in pairs(savedConfigs) do
        if name ~= "Legit" and name ~= "Rage" then
            table.insert(savedConfigsList, name)
        end
    end
    
    local savedConfigsHeight = math.max(100, 45 + (#savedConfigsList * 43))
    
    local savedConfigsFrame = Instance.new("Frame")
    savedConfigsFrame.Size = UDim2.new(1, 0, 0, savedConfigsHeight)
    savedConfigsFrame.Position = UDim2.new(0, 5, 0, yPos)
    savedConfigsFrame.BackgroundColor3 = theme.surface
    savedConfigsFrame.BorderSizePixel = 0
    savedConfigsFrame.ZIndex = 3
    savedConfigsFrame.Parent = contentContainer
    
    local savedConfigsCorner = Instance.new("UICorner")
    savedConfigsCorner.CornerRadius = UDim.new(0, 10)
    savedConfigsCorner.Parent = savedConfigsFrame
    
    local savedConfigsTitle = Instance.new("TextLabel")
    savedConfigsTitle.Size = UDim2.new(1, -30, 0, 25)
    savedConfigsTitle.Position = UDim2.new(0, 15, 0, 10)
    savedConfigsTitle.BackgroundTransparency = 1
    savedConfigsTitle.Text = "Saved Configs (" .. #savedConfigsList .. ")"
    savedConfigsTitle.TextColor3 = theme.text
    savedConfigsTitle.TextSize = 14
    savedConfigsTitle.Font = Enum.Font.GothamBold
    savedConfigsTitle.TextXAlignment = Enum.TextXAlignment.Left
    savedConfigsTitle.ZIndex = 4
    savedConfigsTitle.Parent = savedConfigsFrame
    
    if #savedConfigsList == 0 then
        local noConfigsLabel = Instance.new("TextLabel")
        noConfigsLabel.Size = UDim2.new(1, -30, 0, 40)
        noConfigsLabel.Position = UDim2.new(0, 15, 0, 45)
        noConfigsLabel.BackgroundTransparency = 1
        noConfigsLabel.Text = "No saved configs yet.\nCreate one below!"
        noConfigsLabel.TextColor3 = theme.textDim
        noConfigsLabel.TextSize = 11
        noConfigsLabel.Font = Enum.Font.Gotham
        noConfigsLabel.TextXAlignment = Enum.TextXAlignment.Center
        noConfigsLabel.ZIndex = 4
        noConfigsLabel.Parent = savedConfigsFrame
    else
        for i, configName in ipairs(savedConfigsList) do
            local configBtn = Instance.new("TextButton")
            configBtn.Size = UDim2.new(1, -30, 0, 35)
            configBtn.Position = UDim2.new(0, 15, 0, 40 + (i - 1) * 43)
            configBtn.BackgroundColor3 = theme.surfaceLight
            configBtn.BorderSizePixel = 0
            configBtn.Text = ""
            configBtn.ZIndex = 4
            configBtn.Parent = savedConfigsFrame
            
            local configBtnCorner = Instance.new("UICorner")
            configBtnCorner.CornerRadius = UDim.new(0, 8)
            configBtnCorner.Parent = configBtn
            
            local configNameLabel = Instance.new("TextLabel")
            configNameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            configNameLabel.Position = UDim2.new(0, 10, 0, 0)
            configNameLabel.BackgroundTransparency = 1
            configNameLabel.Text = configName
            configNameLabel.TextColor3 = theme.text
            configNameLabel.TextSize = 12
            configNameLabel.Font = Enum.Font.GothamSemibold
            configNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            configNameLabel.ZIndex = 5
            configNameLabel.Parent = configBtn
            
            local loadBtn = Instance.new("TextButton")
            loadBtn.Size = UDim2.new(0, 60, 0, 25)
            loadBtn.Position = UDim2.new(1, -70, 0.5, -12.5)
            loadBtn.BackgroundColor3 = theme.success
            loadBtn.BorderSizePixel = 0
            loadBtn.Text = "Load"
            loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            loadBtn.TextSize = 11
            loadBtn.Font = Enum.Font.GothamBold
            loadBtn.ZIndex = 5
            loadBtn.Parent = configBtn
            
            local loadBtnCorner = Instance.new("UICorner")
            loadBtnCorner.CornerRadius = UDim.new(0, 6)
            loadBtnCorner.Parent = loadBtn
            
            local deleteBtn = Instance.new("TextButton")
            deleteBtn.Size = UDim2.new(0, 60, 0, 25)
            deleteBtn.Position = UDim2.new(1, -138, 0.5, -12.5)
            deleteBtn.BackgroundColor3 = theme.danger
            deleteBtn.BorderSizePixel = 0
            deleteBtn.Text = "Delete"
            deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            deleteBtn.TextSize = 11
            deleteBtn.Font = Enum.Font.GothamBold
            deleteBtn.ZIndex = 5
            deleteBtn.Parent = configBtn
            
            local deleteBtnCorner = Instance.new("UICorner")
            deleteBtnCorner.CornerRadius = UDim.new(0, 6)
            deleteBtnCorner.Parent = deleteBtn
            
            loadBtn.MouseButton1Click:Connect(function()
                local success = loadConfig(configName)
                if success then
                    tweenService:Create(loadBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 255, 150)}):Play()
                    wait(0.2)
                    tweenService:Create(loadBtn, TweenInfo.new(0.3), {BackgroundColor3 = theme.success}):Play()
                end
            end)
            
            deleteBtn.MouseButton1Click:Connect(function()
                local success = deleteConfig(configName)
                if success then
                    tweenService:Create(deleteBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 255, 150)}):Play()
                    wait(0.3)
                    pageContent["Settings"]()
                end
            end)
            
            loadBtn.MouseEnter:Connect(function()
                tweenService:Create(loadBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 255, 170)}):Play()
            end)
            
            loadBtn.MouseLeave:Connect(function()
                tweenService:Create(loadBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.success}):Play()
            end)
            
            deleteBtn.MouseEnter:Connect(function()
                tweenService:Create(deleteBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
            end)
            
            deleteBtn.MouseLeave:Connect(function()
                tweenService:Create(deleteBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.danger}):Play()
            end)
        end
    end
    
    yPos = yPos + savedConfigsHeight + 10
    
    local customConfigFrame = Instance.new("Frame")
    customConfigFrame.Size = UDim2.new(1, 0, 0, 120)
    customConfigFrame.Position = UDim2.new(0, 5, 0, yPos)
    customConfigFrame.BackgroundColor3 = theme.surface
    customConfigFrame.BorderSizePixel = 0
    customConfigFrame.ZIndex = 3
    customConfigFrame.Parent = contentContainer
    
    local customConfigCorner = Instance.new("UICorner")
    customConfigCorner.CornerRadius = UDim.new(0, 10)
    customConfigCorner.Parent = customConfigFrame
    
    local customTitle = Instance.new("TextLabel")
    customTitle.Size = UDim2.new(1, -30, 0, 25)
    customTitle.Position = UDim2.new(0, 15, 0, 10)
    customTitle.BackgroundTransparency = 1
    customTitle.Text = "Create New Config"
    customTitle.TextColor3 = theme.text
    customTitle.TextSize = 14
    customTitle.Font = Enum.Font.GothamBold
    customTitle.TextXAlignment = Enum.TextXAlignment.Left
    customTitle.ZIndex = 4
    customTitle.Parent = customConfigFrame
    
    local configNameBox = Instance.new("TextBox")
    configNameBox.Size = UDim2.new(1, -30, 0, 32)
    configNameBox.Position = UDim2.new(0, 15, 0, 45)
    configNameBox.BackgroundColor3 = theme.surfaceLight
    configNameBox.BorderSizePixel = 0
    configNameBox.Text = ""
    configNameBox.PlaceholderText = "Config Name"
    configNameBox.PlaceholderColor3 = theme.textDim
    configNameBox.TextColor3 = theme.text
    configNameBox.TextSize = 12
    configNameBox.Font = Enum.Font.Gotham
    configNameBox.ClearTextOnFocus = false
    configNameBox.ZIndex = 4
    configNameBox.Parent = customConfigFrame
    
    local configNameBoxCorner = Instance.new("UICorner")
    configNameBoxCorner.CornerRadius = UDim.new(0, 8)
    configNameBoxCorner.Parent = configNameBox
    
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(1, -30, 0, 35)
    saveButton.Position = UDim2.new(0, 15, 0, 85)
    saveButton.BackgroundColor3 = theme.primary
    saveButton.BorderSizePixel = 0
    saveButton.Text = "💾 Save Current Settings"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 12
    saveButton.Font = Enum.Font.GothamBold
    saveButton.ZIndex = 4
    saveButton.Parent = customConfigFrame
    
    local saveButtonCorner = Instance.new("UICorner")
    saveButtonCorner.CornerRadius = UDim.new(0, 8)
    saveButtonCorner.Parent = saveButton
    
    saveButton.MouseButton1Click:Connect(function()
        local configName = configNameBox.Text
        if configName ~= "" then
            saveCurrentConfig(configName)
            tweenService:Create(saveButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.success}):Play()
            configNameBox.Text = ""
            wait(0.3)
            tweenService:Create(saveButton, TweenInfo.new(0.3), {BackgroundColor3 = theme.primary}):Play()
            wait(0.2)
            pageContent["Settings"]()
        end
    end)
    
    saveButton.MouseEnter:Connect(function()
        tweenService:Create(saveButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 120)}):Play()
    end)
    
    saveButton.MouseLeave:Connect(function()
        tweenService:Create(saveButton, TweenInfo.new(0.2), {BackgroundColor3 = theme.primary}):Play()
    end)
    
    updateCanvasSize()
end

local function switchPage(pageName)
    currentPage = pageName
    
    local targetY = 10 + (({Aim = 0, Visuals = 1, Misc = 2, Settings = 3})[pageName] or 0) * 55
    tweenService:Create(pageIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0, 0, 0, targetY)
    }):Play()
    
    for name, buttonData in pairs(pageButtons) do
        if name == pageName then
            tweenService:Create(buttonData.icon, TweenInfo.new(0.3), {TextColor3 = theme.primary}):Play()
            tweenService:Create(buttonData.label, TweenInfo.new(0.3), {TextColor3 = theme.text}):Play()
        else
            tweenService:Create(buttonData.icon, TweenInfo.new(0.3), {TextColor3 = theme.textDim}):Play()
            tweenService:Create(buttonData.label, TweenInfo.new(0.3), {TextColor3 = theme.textDim}):Play()
        end
    end
    
    for _, child in pairs(contentContainer:GetChildren()) do
        tweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        for _, subChild in pairs(child:GetChildren()) do
            if subChild:IsA("TextLabel") or subChild:IsA("TextButton") then
                tweenService:Create(subChild, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            end
        end
    end
    
    wait(0.25)
    if pageContent[pageName] then
        pageContent[pageName]()
    end
    
    for _, child in pairs(contentContainer:GetChildren()) do
        child.BackgroundTransparency = 1
        tweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        for _, subChild in pairs(child:GetChildren()) do
            if subChild:IsA("TextLabel") or subChild:IsA("TextButton") then
                subChild.TextTransparency = 1
                tweenService:Create(subChild, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            end
        end
    end
end

for name, buttonData in pairs(pageButtons) do
    buttonData.button.MouseButton1Click:Connect(function()
        switchPage(name)
    end)
end

switchPage("Aim")

local function isVisible(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local origin = camera.CFrame.Position
    local direction = (targetChar.HumanoidRootPart.Position - origin).Unit * 500
    
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character, camera})
    
    if hit and hit:IsDescendantOf(targetChar) then
        return true
    end
    
    return false
end

local function createESP(plr)
    if plr == player then return end
    
    local corners = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = theme.primary
        line.Thickness = 2
        line.Transparency = 1
        table.insert(corners, line)
    end
    
    local espBox = Drawing.new("Square")
    espBox.Visible = false
    espBox.Color = theme.primary
    espBox.Thickness = 2
    espBox.Transparency = 1
    espBox.Filled = false
    
    local espName = Drawing.new("Text")
    espName.Visible = false
    espName.Color = Color3.fromRGB(255, 255, 255)
    espName.Text = plr.Name
    espName.Size = 14
    espName.Center = true
    espName.Outline = true
    espName.Font = 2
    
    local espDistance = Drawing.new("Text")
    espDistance.Visible = false
    espDistance.Color = theme.accent
    espDistance.Size = 12
    espDistance.Center = true
    espDistance.Outline = true
    espDistance.Font = 2
    
    local espHealth = Drawing.new("Text")
    espHealth.Visible = false
    espHealth.Color = theme.success
    espHealth.Size = 12
    espHealth.Center = true
    espHealth.Outline = true
    espHealth.Font = 2
    
    local espHealthBar = Drawing.new("Square")
    espHealthBar.Visible = false
    espHealthBar.Color = theme.success
    espHealthBar.Thickness = 1
    espHealthBar.Transparency = 1
    espHealthBar.Filled = true
    
    local espHealthBarBG = Drawing.new("Square")
    espHealthBarBG.Visible = false
    espHealthBarBG.Color = Color3.fromRGB(20, 20, 25)
    espHealthBarBG.Thickness = 1
    espHealthBarBG.Transparency = 0.7
    espHealthBarBG.Filled = true
    
    local espHealthBarOutline = Drawing.new("Square")
    espHealthBarOutline.Visible = false
    espHealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    espHealthBarOutline.Thickness = 1
    espHealthBarOutline.Transparency = 1
    espHealthBarOutline.Filled = false
    
    local skeletonLines = {}
    for i = 1, 6 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = theme.secondary
        line.Thickness = 2
        line.Transparency = 0.8
        table.insert(skeletonLines, line)
    end
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = theme.accent
    tracer.Thickness = 1
    tracer.Transparency = 0.6

    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = 2
    nameTag.Text = "Flick Fucker User"
    
    espObjects[plr] = {
        box = espBox,
        corners = corners,
        name = espName,
        distance = espDistance,
        health = espHealth,
        healthBar = espHealthBar,
        healthBarBG = espHealthBarBG,
        healthBarOutline = espHealthBarOutline,
        skeleton = skeletonLines,
        tracer = tracer,
        nameTag = nameTag
    }
end

local function removeESP(plr)
    if espObjects[plr] then
        espObjects[plr].box:Remove()
        for _, corner in pairs(espObjects[plr].corners) do
            corner:Remove()
        end
        espObjects[plr].name:Remove()
        espObjects[plr].distance:Remove()
        espObjects[plr].health:Remove()
        espObjects[plr].healthBar:Remove()
        espObjects[plr].healthBarBG:Remove()
        espObjects[plr].healthBarOutline:Remove()
        for _, line in pairs(espObjects[plr].skeleton) do
            line:Remove()
        end
        espObjects[plr].tracer:Remove()
        if espObjects[plr].nameTag then
            espObjects[plr].nameTag:Remove()
        end
        espObjects[plr] = nil
    end
end

local function updateRadar()
    if not isRadarActive or not character or not character:FindFirstChild("HumanoidRootPart") then
        for _, line in pairs(radarPlayerArrow) do
            line.Visible = false
        end
        return
    end
    
    local radarSize = 100
    local radarX = 120
    local radarY = camera.ViewportSize.Y - 120
    
    radarBackground.Position = Vector2.new(radarX, radarY)
    radarBackground.Radius = radarSize
    radarBorder.Position = Vector2.new(radarX, radarY)
    radarBorder.Radius = radarSize
    
    local lookVector = character.HumanoidRootPart.CFrame.LookVector
    local angle = math.atan2(lookVector.Z, lookVector.X)
    
    local baseX = radarX
    local baseY = radarY
    
    local arrowLength = 15
    local tipX = baseX + math.cos(angle) * arrowLength
    local tipY = baseY + math.sin(angle) * arrowLength
    
    local wingLength = 8
    local wingAngle1 = angle + math.rad(150)
    local wingAngle2 = angle - math.rad(150)
    
    local wing1X = baseX + math.cos(wingAngle1) * wingLength
    local wing1Y = baseY + math.sin(wingAngle1) * wingLength
    
    local wing2X = baseX + math.cos(wingAngle2) * wingLength
    local wing2Y = baseY + math.sin(wingAngle2) * wingLength
    
    radarPlayerArrow.line1.From = Vector2.new(baseX, baseY)
    radarPlayerArrow.line1.To = Vector2.new(tipX, tipY)
    radarPlayerArrow.line1.Visible = true
    
    radarPlayerArrow.line2.From = Vector2.new(tipX, tipY)
    radarPlayerArrow.line2.To = Vector2.new(wing1X, wing1Y)
    radarPlayerArrow.line2.Visible = true
    
    radarPlayerArrow.line3.From = Vector2.new(tipX, tipY)
    radarPlayerArrow.line3.To = Vector2.new(wing2X, wing2Y)
    radarPlayerArrow.line3.Visible = true
    
    for plr, dot in pairs(radarDots) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local myHRP = character.HumanoidRootPart
            local theirHRP = plr.Character.HumanoidRootPart
            
            local offset = theirHRP.Position - myHRP.Position
            local distance = offset.Magnitude
            
            if distance < 500 * radarScale then
                local worldAngle = math.atan2(offset.Z, offset.X)
                local relativeAngle = worldAngle - angle
                local scale = math.min(distance / (5 * radarScale), radarSize - 10)
                
                local x = radarX + math.cos(relativeAngle) * scale
                local y = radarY + math.sin(relativeAngle) * scale
                
                dot.Position = Vector2.new(x, y)
                dot.Visible = true
            else
                dot.Visible = false
            end
        else
            dot.Visible = false
        end
    end
end

local function updateFovArrows()
    if not isFovArrowsActive then
        for _, arrow in pairs(fovArrows) do
            arrow.Visible = false
        end
        return
    end
    
    local centerX = camera.ViewportSize.X / 2
    local centerY = camera.ViewportSize.Y / 2
    
    local arrowIndex = 1
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            
            if not onScreen or (Vector2.new(pos.X, pos.Y) - Vector2.new(centerX, centerY)).Magnitude > fov then
                local angle = math.atan2(pos.Y - centerY, pos.X - centerX)
                local arrowDist = fov + 20
                
                local arrowX = centerX + math.cos(angle) * arrowDist
                local arrowY = centerY + math.sin(angle) * arrowDist
                
                if not fovArrows[arrowIndex] then
                    local arrow = Drawing.new("Triangle")
                    arrow.Thickness = 2
                    arrow.Filled = true
                    arrow.Color = theme.danger
                    arrow.Transparency = 0.8
                    fovArrows[arrowIndex] = arrow
                end
                
                local arrow = fovArrows[arrowIndex]
                local arrowSize = 12
                local tipX = arrowX + math.cos(angle) * arrowSize
                local tipY = arrowY + math.sin(angle) * arrowSize
                local baseAngle1 = angle + math.rad(150)
                local baseAngle2 = angle - math.rad(150)
                
                arrow.PointA = Vector2.new(tipX, tipY)
                arrow.PointB = Vector2.new(arrowX + math.cos(baseAngle1) * arrowSize, arrowY + math.sin(baseAngle1) * arrowSize)
                arrow.PointC = Vector2.new(arrowX + math.cos(baseAngle2) * arrowSize, arrowY + math.sin(baseAngle2) * arrowSize)
                arrow.Visible = true
                
                arrowIndex = arrowIndex + 1
            end
        end
    end
    
    for i = arrowIndex, #fovArrows do
        fovArrows[i].Visible = false
    end
end

local function updateESP()
    for plr, esp in pairs(espObjects) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local humanoid = plr.Character.Humanoid
            
            local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)
            local visible = isVisible(plr.Character)
            
            if onScreen and isEspActive then
                local hrpVector = camera:WorldToViewportPoint(hrp.Position)
                local headVector = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legVector = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(headVector.Y - legVector.Y)
                local width = height / 2
                
                local boxColor = visible and theme.success or theme.danger
                
                if espSettings.box then
                    if espSettings.boxType == "corners" then
                        esp.box.Visible = false
                        
                        local cornerLength = math.min(width, height) * 0.25
                        local topLeft = Vector2.new(hrpVector.X - width / 2, hrpVector.Y - height / 2)
                        local topRight = Vector2.new(hrpVector.X + width / 2, hrpVector.Y - height / 2)
                        local bottomLeft = Vector2.new(hrpVector.X - width / 2, hrpVector.Y + height / 2)
                        local bottomRight = Vector2.new(hrpVector.X + width / 2, hrpVector.Y + height / 2)
                        
                        esp.corners[1].From = topLeft
                        esp.corners[1].To = Vector2.new(topLeft.X + cornerLength, topLeft.Y)
                        esp.corners[1].Color = boxColor
                        esp.corners[1].Visible = true
                        
                        esp.corners[2].From = topLeft
                        esp.corners[2].To = Vector2.new(topLeft.X, topLeft.Y + cornerLength)
                        esp.corners[2].Color = boxColor
                        esp.corners[2].Visible = true
                        
                        esp.corners[3].From = topRight
                        esp.corners[3].To = Vector2.new(topRight.X - cornerLength, topRight.Y)
                        esp.corners[3].Color = boxColor
                        esp.corners[3].Visible = true
                        
                        esp.corners[4].From = topRight
                        esp.corners[4].To = Vector2.new(topRight.X, topRight.Y + cornerLength)
                        esp.corners[4].Color = boxColor
                        esp.corners[4].Visible = true
                        
                        esp.corners[5].From = bottomLeft
                        esp.corners[5].To = Vector2.new(bottomLeft.X + cornerLength, bottomLeft.Y)
                        esp.corners[5].Color = boxColor
                        esp.corners[5].Visible = true
                        
                        esp.corners[6].From = bottomLeft
                        esp.corners[6].To = Vector2.new(bottomLeft.X, bottomLeft.Y - cornerLength)
                        esp.corners[6].Color = boxColor
                        esp.corners[6].Visible = true
                        
                        esp.corners[7].From = bottomRight
                        esp.corners[7].To = Vector2.new(bottomRight.X - cornerLength, bottomRight.Y)
                        esp.corners[7].Color = boxColor
                        esp.corners[7].Visible = true
                        
                        esp.corners[8].From = bottomRight
                        esp.corners[8].To = Vector2.new(bottomRight.X, bottomRight.Y - cornerLength)
                        esp.corners[8].Color = boxColor
                        esp.corners[8].Visible = true
                    else
                        for _, corner in pairs(esp.corners) do
                            corner.Visible = false
                        end
                        
                        esp.box.Color = boxColor
                        esp.box.Size = Vector2.new(width, height)
                        esp.box.Position = Vector2.new(hrpVector.X - width / 2, hrpVector.Y - height / 2)
                        esp.box.Visible = true
                    end
                else
                    esp.box.Visible = false
                    for _, corner in pairs(esp.corners) do
                        corner.Visible = false
                    end
                end
                
                if espSettings.name then
                    esp.name.Position = Vector2.new(hrpVector.X, headVector.Y - 18)
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end
                
                if espSettings.distance then
                    local distance = math.floor((camera.CFrame.Position - hrp.Position).Magnitude)
                    esp.distance.Text = distance .. "m"
                    esp.distance.Position = Vector2.new(hrpVector.X, legVector.Y + 8)
                    esp.distance.Visible = true
                else
                    esp.distance.Visible = false
                end
                
                if espSettings.health then
                    local healthPercentage = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    
                    local barHeight = height
                    local barWidth = 4
                    local barX = hrpVector.X - width / 2 - 8
                    local barY = hrpVector.Y - height / 2
                    
                    esp.healthBarBG.Size = Vector2.new(barWidth, barHeight)
                    esp.healthBarBG.Position = Vector2.new(barX, barY)
                    esp.healthBarBG.Visible = true
                    
                    esp.healthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                    esp.healthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
                    esp.healthBarOutline.Visible = true
                    
                    local currentHealthHeight = barHeight * (humanoid.Health / humanoid.MaxHealth)
                    esp.healthBar.Size = Vector2.new(barWidth, currentHealthHeight)
                    esp.healthBar.Position = Vector2.new(barX, barY + (barHeight - currentHealthHeight))
                    
                    if healthPercentage > 75 then
                        esp.healthBar.Color = theme.success
                    elseif healthPercentage > 50 then
                        esp.healthBar.Color = Color3.fromRGB(255, 255, 0)
                    elseif healthPercentage > 25 then
                        esp.healthBar.Color = Color3.fromRGB(255, 165, 0)
                    else
                        esp.healthBar.Color = theme.danger
                    end
                    esp.healthBar.Visible = true
                    
                    esp.health.Text = healthPercentage .. "%"
                    esp.health.Position = Vector2.new(barX + 2, barY - 15)
                    esp.health.Color = esp.healthBar.Color
                    esp.health.Visible = true
                else
                    esp.health.Visible = false
                    esp.healthBar.Visible = false
                    esp.healthBarBG.Visible = false
                    esp.healthBarOutline.Visible = false
                end
                
                if espSettings.skeleton then
                    local torso = plr.Character:FindFirstChild("Torso")
                    local leftArm = plr.Character:FindFirstChild("Left Arm")
                    local rightArm = plr.Character:FindFirstChild("Right Arm")
                    local leftLeg = plr.Character:FindFirstChild("Left Leg")
                    local rightLeg = plr.Character:FindFirstChild("Right Leg")
                    
                    if torso and head and leftArm and rightArm and leftLeg and rightLeg then
                        local connections = {
                            {head.Position, torso.Position},
                            {torso.Position, leftArm.Position},
                            {torso.Position, rightArm.Position},
                            {torso.Position, leftLeg.Position},
                            {torso.Position, rightLeg.Position},
                            {leftArm.Position, rightArm.Position}
                        }
                        
                        for i, connection in ipairs(connections) do
                            local startPos, startOnScreen = camera:WorldToViewportPoint(connection[1])
                            local endPos, endOnScreen = camera:WorldToViewportPoint(connection[2])
                            
                            if startOnScreen and endOnScreen and esp.skeleton[i] then
                                esp.skeleton[i].From = Vector2.new(startPos.X, startPos.Y)
                                esp.skeleton[i].To = Vector2.new(endPos.X, endPos.Y)
                                esp.skeleton[i].Visible = true
                            elseif esp.skeleton[i] then
                                esp.skeleton[i].Visible = false
                            end
                        end
                    end
                else
                    for _, line in pairs(esp.skeleton) do
                        line.Visible = false
                    end
                end
                
                if espSettings.tracers then
                    esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(hrpVector.X, legVector.Y)
                    esp.tracer.Color = boxColor
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
                if flickFuckerUsers[plr.UserId] then
                    for _, part in pairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Color = Color3.fromRGB(255, 255, 0)
                            part.Material = Enum.Material.Neon
                        end
                    end
                    
                    local time = tick() * 3
                    local r = math.floor(math.sin(time) * 127 + 128)
                    local g = math.floor(math.sin(time + 2.1) * 127 + 128)
                    local b = math.floor(math.sin(time + 4.2) * 127 + 128)
                    
                    esp.nameTag.Color = Color3.fromRGB(r, g, b)
                    esp.nameTag.Position = Vector2.new(hrpVector.X, headVector.Y - 35)
                    esp.nameTag.Visible = true
                else
                    if esp.nameTag then
                        esp.nameTag.Visible = false
                    end
                end
            else
                esp.box.Visible = false
                for _, corner in pairs(esp.corners) do
                    corner.Visible = false
                end
                esp.name.Visible = false
                esp.distance.Visible = false
                esp.health.Visible = false
                esp.healthBar.Visible = false
                esp.healthBarBG.Visible = false
                esp.healthBarOutline.Visible = false
                for _, line in pairs(esp.skeleton) do
                    line.Visible = false
                end
                esp.tracer.Visible = false
            end
        else
            esp.box.Visible = false
            for _, corner in pairs(esp.corners) do
                corner.Visible = false
            end
            esp.name.Visible = false
            esp.distance.Visible = false
            esp.health.Visible = false
            esp.healthBar.Visible = false
            esp.healthBarBG.Visible = false
            esp.healthBarOutline.Visible = false
            for _, line in pairs(esp.skeleton) do
                line.Visible = false
            end
            esp.tracer.Visible = false
            if esp.nameTag then
                esp.nameTag.Visible = false
            end
        end
    end
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = fov
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild(targetPart) and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(v.Character[targetPart].Position)
                if onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                    
                    if magnitude < shortestDistance then
                        closestPlayer = v
                        shortestDistance = magnitude
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function updateHitboxes()
    if isHitboxExpanderActive then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 0.8
                hrp.CanCollide = false
            end
        end
    else
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = false
            end
        end
    end
end

closeButton.MouseButton1Click:Connect(function()
    tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    tweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
    
    wait(0.3)
    screenGui:Destroy()
    fovCircle:Remove()
    blur:Remove()
    radarBackground:Remove()
    radarBorder:Remove()
    for _, line in pairs(radarPlayerArrow) do
        line:Remove()
    end
    for _, dot in pairs(radarDots) do
        dot:Remove()
    end
    for _, arrow in pairs(fovArrows) do
        arrow:Remove()
    end
    for plr, _ in pairs(espObjects) do
        removeESP(plr)
    end
end)

mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 550, 0, 450)
}):Play()

tweenService:Create(blur, TweenInfo.new(0.3), {Size = 5}):Play()

runService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    updateHitboxes()
    updateRadar()
    updateFovArrows()
end)

runService.RenderStepped:Connect(function()
    if isAimbotActive and aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(targetPart) then
            if isVisible(target.Character) then
                local targetPartObj = target.Character[targetPart]
                local targetPos = targetPartObj.Position
                local currentCFrame = camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / aimbotSmoothness)
            end
        end
    end
end)

local currentTarget = nil
local lastShotTime = 0
local triggerBotDelay = 0.1

runService.RenderStepped:Connect(function()
    if isSilentAimActive then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(targetPart) then
            currentTarget = target.Character[targetPart]
        else
            currentTarget = nil
        end
    else
        currentTarget = nil
    end
    
    if isTriggerBotActive then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(targetPart) then
            if isVisible(target.Character) then
                local currentTime = tick()
                if currentTime - lastShotTime >= triggerBotDelay then
                    local targetPart = target.Character[targetPart]
                    local oldCFrame = camera.CFrame
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                    
                    wait(0.05)
                    
                    mouse1press()
                    wait(0.02)
                    mouse1release()
                    
                    wait(0.03)
                    camera.CFrame = oldCFrame
                    
                    lastShotTime = currentTime
                end
            end
        end
    end
end)

mouse.Button1Down:Connect(function()
    if isSilentAimActive and currentTarget then
        local oldCFrame = camera.CFrame
        camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
        wait()
        camera.CFrame = oldCFrame
    end
end)

local keyMap = {
    ["RMB"] = Enum.UserInputType.MouseButton2,
    ["X"] = Enum.KeyCode.X,
    ["C"] = Enum.KeyCode.C,
    ["Z"] = Enum.KeyCode.Z,
    ["V"] = Enum.KeyCode.V,
    ["B"] = Enum.KeyCode.B,
    ["N"] = Enum.KeyCode.N,
    ["M"] = Enum.KeyCode.M
}

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and isAimbotActive then
        local currentKey = keyMap[aimbotKey]
        
        if currentKey then
            if (input.UserInputType == currentKey) or (input.KeyCode == currentKey) then
                if aimbotMode == "Hold" then
                    aimbotEnabled = true
                elseif aimbotMode == "Toggle" then
                    aimbotEnabled = not aimbotEnabled
                end
            end
        end
    end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
    if isAimbotActive and aimbotMode == "Hold" then
        local currentKey = keyMap[aimbotKey]
        
        if currentKey then
            if (input.UserInputType == currentKey) or (input.KeyCode == currentKey) then
                aimbotEnabled = false
            end
        end
    end
end)

runService.RenderStepped:Connect(function()
    updateESP()
end)

runService.RenderStepped:Connect(function()
    for userId, _ in pairs(flickFuckerUsers) do
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.UserId == userId and plr ~= player and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Color = Color3.fromRGB(255, 255, 0)
                        part.Material = Enum.Material.Neon
                    end
                end
                
                if espObjects[plr] and espObjects[plr].nameTag then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local head = plr.Character:FindFirstChild("Head")
                    
                    if hrp and head then
                        local hrpVector, onScreen = camera:WorldToViewportPoint(hrp.Position)
                        local headVector = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        
                        if onScreen then
                            local time = tick() * 3
                            local r = math.floor(math.sin(time) * 127 + 128)
                            local g = math.floor(math.sin(time + 2.1) * 127 + 128)
                            local b = math.floor(math.sin(time + 4.2) * 127 + 128)
                            
                            espObjects[plr].nameTag.Color = Color3.fromRGB(r, g, b)
                            espObjects[plr].nameTag.Position = Vector2.new(hrpVector.X, headVector.Y - 35)
                            espObjects[plr].nameTag.Visible = true
                        else
                            espObjects[plr].nameTag.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

game.Players.PlayerAdded:Connect(function(plr)
    createESP(plr)
    
    local radarDot = Drawing.new("Circle")
    radarDot.Thickness = 1
    radarDot.NumSides = 20
    radarDot.Radius = 4
    radarDot.Filled = true
    radarDot.Color = theme.danger
    radarDot.Transparency = 1
    radarDot.Visible = false
    radarDots[plr] = radarDot
end)

game.Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
    
    if radarDots[plr] then
        radarDots[plr]:Remove()
        radarDots[plr] = nil
    end
end)

for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= player then
        createESP(plr)
        
        local radarDot = Drawing.new("Circle")
        radarDot.Thickness = 1
        radarDot.NumSides = 20
        radarDot.Radius = 4
        radarDot.Filled = true
        radarDot.Color = theme.danger
        radarDot.Transparency = 1
        radarDot.Visible = false
        radarDots[plr] = radarDot
    end
end

player.CharacterAdded:Connect(function(char)
    character = char
    wait(0.3)
end)

local flickFuckerUsers = {}
local textChatService = game:GetService("TextChatService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local function markFlickFuckerUser(userId)
    if not flickFuckerUsers[userId] then
        flickFuckerUsers[userId] = true
        print("🔥 DETECTED FLICK FUCKER USER: " .. userId)
        
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.UserId == userId and not espObjects[plr] and plr ~= player then
                createESP(plr)
            end
        end
    end
end

markFlickFuckerUser(player.UserId)

local function sendDetectionMessage()
    pcall(function()
        if textChatService:FindFirstChild("TextChannels") then
            local generalChannel = textChatService.TextChannels:FindFirstChild("RBXGeneral")
            if generalChannel then
                generalChannel:SendAsync(".")
            end
        end
        
        pcall(function()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(".", "All")
        end)
        
        local marker = Instance.new("StringValue")
        marker.Name = "FF_User_" .. player.UserId
        marker.Value = "ACTIVE"
        marker.Parent = replicatedStorage
        
        game:GetService("Debris"):AddItem(marker, 5)
    end)
end

local function detectViaStorage()
    for _, obj in pairs(replicatedStorage:GetChildren()) do
        if obj:IsA("StringValue") and string.match(obj.Name, "FF_User_") then
            local userId = tonumber(string.match(obj.Name, "%d+"))
            if userId and userId ~= player.UserId then
                markFlickFuckerUser(userId)
            end
        end
    end
end

replicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA("StringValue") and string.match(child.Name, "FF_User_") then
        local userId = tonumber(string.match(child.Name, "%d+"))
        if userId and userId ~= player.UserId then
            markFlickFuckerUser(userId)
        end
    end
end)

pcall(function()
    textChatService.MessageReceived:Connect(function(message)
        if message.Text == "." and message.TextSource then
            local userId = message.TextSource.UserId
            if userId ~= player.UserId then
                print("🔍 Detected '.' from UserID: " .. userId)
                markFlickFuckerUser(userId)
            end
        end
    end)
end)

pcall(function()
    local chatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local onMessageDoneFiltering = chatEvents:FindFirstChild("OnMessageDoneFiltering")
        if onMessageDoneFiltering then
            onMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
                if messageData and messageData.Message == "." then
                    local speaker = game.Players:FindFirstChild(messageData.FromSpeaker)
                    if speaker and speaker ~= player then
                        print("🔍 Detected '.' from: " .. speaker.Name)
                        markFlickFuckerUser(speaker.UserId)
                    end
                end
            end)
        end
    end
end)

spawn(function()
    wait(3)
    pcall(function()
        if textChatService:FindFirstChild("TextChannels") then
            local generalChannel = textChatService.TextChannels:FindFirstChild("RBXGeneral")
            if generalChannel then
                for _, message in pairs(generalChannel:GetChildren()) do
                    if message:IsA("TextChatMessage") and message.Text == "." and message.TextSource then
                        local userId = message.TextSource.UserId
                        if userId ~= player.UserId then
                            print("📜 Found old '.' from UserID: " .. userId)
                            markFlickFuckerUser(userId)
                        end
                    end
                end
            end
        end
    end)
end)

spawn(function()
    wait(3)
    pcall(function()
        local chatService = game:GetService("Chat")
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player then
            end
        end
    end)
end)

local hasSentInitial = false
spawn(function()
    wait(2)
    if not hasSentInitial then
        hasSentInitial = true
        print("📡 Sending initial detection message...")
        sendDetectionMessage()
        wait(1)
        detectViaStorage()
    end
end)

local playersAlreadyHere = {}
for _, plr in pairs(game.Players:GetPlayers()) do
    playersAlreadyHere[plr.UserId] = true
end

print("loading 1%")
print("loading 2%")
print("loading 3%")
print("loading anticheat bypass LITERALLY")
print("loading extra loading%")
print("loading done%")
print("loaded flick fucker enjoy! ( made by @.9177) ")

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == menuKey then
        menuVisible = not menuVisible
        if menuVisible then
            mainFrame.Visible = true
            tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 550, 0, 450)
            }):Play()
            tweenService:Create(blur, TweenInfo.new(0.3), {Size = 5}):Play()
        else
            tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            tweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
            wait(0.3)
            mainFrame.Visible = false
        end
    end
end)

print(".9177")
print(".9177")

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        1,
        {
            "Flick"
        },
        {
            {
                2,
                4,
                {
                    "Src"
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    [2] = 8
}

-- Misc AOT variable imports
local WaxVersion = "0.4.2"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == "." then
                    RealIndex = ""
                elseif PathMatch == ".." then
                    CurrentRefPointer = CurrentRefPointer.Parent
                    RealIndex = ""
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end
