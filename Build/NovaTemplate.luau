-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)--[[
	Icons Module - Template
	Fetches and manages Lucide icons for the UI.
	Uses deividcomsono's lucide-roblox-direct for icon spritesheet.
	
	Usage:
		local Icons = require(path.to.Icons)
		
		-- Apply icon to ImageLabel
		Icons.ApplyIcon(imageLabel, "settings")
		Icons.ApplyIcon(imageLabel, "home")
		
		-- Get icon data
		local iconData = Icons.GetIcon("user")
		if iconData then
			print(iconData.Url, iconData.ImageRectOffset, iconData.ImageRectSize)
		end
]]

local Icons = {}

export type IconData = {
	Url: string,
	Id: number,
	IconName: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
}

-- Try to load the icons module
local Success, IconsModule = pcall(function()
	local IconFetchSuccess, IconModuleSource = pcall(request, {
		Url = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",
		Method = "GET",
	})

	assert(
		IconFetchSuccess and IconModuleSource.Success or IconModuleSource.StatusCode >= 200 and IconModuleSource.StatusCode < 300,
		"Failed to fetch lucide icons direct module source"
	)
	return (loadstring(IconModuleSource.Body) :: () -> { Icons: { string }, GetAsset: (Name: string) -> IconData? })()
end)

if not Success then
	warn("[Icons] Failed to load Lucide icons module. Icons will not be available.")
end

--[[
	Get icon data by name
	@param iconName The name of the Lucide icon
	@return IconData or nil if not found
]]
function Icons.GetIcon(iconName: string): IconData?
	if not Success or not IconsModule then
		return nil
	end

	local success, icon = pcall(IconsModule.GetAsset, iconName)
	if not success then
		return nil
	end

	return icon
end

--[[
	Apply icon to an ImageLabel
	@param imageLabel The ImageLabel to apply the icon to
	@param iconName The name of the Lucide icon
	@return boolean indicating success
]]
function Icons.ApplyIcon(imageLabel: ImageLabel, iconName: string): boolean
	local icon = Icons.GetIcon(iconName)
	if not icon then
		return false
	end

	imageLabel.Image = icon.Url
	imageLabel.ImageRectOffset = icon.ImageRectOffset
	imageLabel.ImageRectSize = icon.ImageRectSize
	return true
end

--[[
	Check if icons are available
	@return boolean
]]
function Icons.IsAvailable(): boolean
	return Success and IconsModule ~= nil
end

--[[
	Get list of all available icon names
	@return Array of icon names or empty array if not loaded
]]
function Icons.GetAllIconNames(): { string }
	if not Success or not IconsModule or not IconsModule.Icons then
		return {}
	end
	return IconsModule.Icons
end

return Icons

end)() end,
    [2] = function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...)--[[
Flick - built on Nova UI Library
Features: Silent Aim, Aimbot, Trigger Bot, ESP, FOV Circle,
          Radar, FOV Arrows, Hitbox Expander, Crosshair,
          Config system, Flick user detection
Flick
]]

-- UI Modules
local UI = script.UI
local Theme = require(UI.Theme)
local Interface = require(UI.Interface)
local Helper = require(UI.Helper)
local Resize = require(UI.Resize)
local Drag = require(UI.Drag)
local Sonner = require(UI.Sonner)
local Icons = require(UI.Icons)

-- Services
for _, Service in pairs({
"CoreGui",
"TweenService",
"Players",
"UserInputService",
}) do
wax.shared[Service] = cloneref(game:GetService(Service))
end

local TweenService = wax.shared.TweenService
local UserInputService = wax.shared.UserInputService
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

-- Default tween info
local DefaultTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ============================================================
-- LIBRARY STATE
-- ============================================================

local Library = {}
Library.Categories = {}
Library.CategoryOrder = {}
Library.ActiveCategory = nil
Library.SettingsVisible = false

-- ============================================================
-- SCREEN GUI
-- ============================================================

local ScreenGui = Interface.CreateScreenGui("FlickUI")

local ScreenDPIScale = Interface.New("UIScale", {
Scale = 1,
Parent = ScreenGui,
})

Sonner.Initialize(ScreenGui, Icons)

-- ============================================================
-- MAIN FRAME
-- ============================================================

local MainFrame = Interface.New("Frame", {
BackgroundColor3 = Theme.Background,
Size = UDim2.fromOffset(620, 450),
Position = UDim2.new(0.5, -310, 0.5, -225),
BorderSizePixel = 0,
Parent = ScreenGui,
["UICorner"] = { CornerRadius = UDim.new(0, 8) },
["UIStroke"] = { Color = Theme.Border, Thickness = 1 },
})

-- ============================================================
-- TITLE BAR
-- ============================================================

local TitleBar = Interface.New("Frame", {
BackgroundColor3 = Theme.Surface,
Size = UDim2.new(1, 0, 0, 36),
BorderSizePixel = 0,
Parent = MainFrame,
["UICorner"] = { CornerRadius = UDim.new(0, 8) },
})

Interface.New("Frame", {
BackgroundColor3 = Theme.Surface,
Size = UDim2.new(1, 0, 0, 10),
Position = UDim2.new(0, 0, 1, -10),
BorderSizePixel = 0,
Parent = TitleBar,
})

Drag.new(MainFrame, TitleBar, function() return ScreenDPIScale.Scale end)

local TitleIcon = Interface.New("ImageLabel", {
BackgroundTransparency = 1,
Size = UDim2.fromOffset(18, 18),
Position = UDim2.new(0, 12, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
ImageColor3 = Theme.Accent,
Parent = TitleBar,
})
Icons.ApplyIcon(TitleIcon, "radar")

Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(0, 200, 1, 0),
Position = UDim2.new(0, 36, 0, 0),
Text = "Nova",
TextColor3 = Theme.Text,
TextSize = 16,
Font = Enum.Font.GothamBold,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = TitleBar,
})

Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(0, 80, 0, 18),
Position = UDim2.new(0, 72, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
Text = "Flick",
TextColor3 = Theme.TextMuted,
TextSize = 11,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = TitleBar,
})

-- Window buttons container
local WindowButtons = Interface.New("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(0, 110, 1, 0),
Position = UDim2.new(1, -110, 0, 0),
Parent = TitleBar,
["UIListLayout"] = {
FillDirection = Enum.FillDirection.Horizontal,
HorizontalAlignment = Enum.HorizontalAlignment.Right,
VerticalAlignment = Enum.VerticalAlignment.Center,
Padding = UDim.new(0, 4),
},
["UIPadding"] = { PaddingRight = UDim.new(0, 8) },
})

local function CreateWindowButton(iconName, callback)
local btn = Interface.New("TextButton", {
Text = "",
BackgroundColor3 = Theme.SurfaceHover,
BackgroundTransparency = 0.5,
Size = UDim2.fromOffset(28, 28),
Parent = WindowButtons,
AutoButtonColor = false,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
})
local icon = Interface.New("ImageLabel", {
BackgroundTransparency = 1,
Size = UDim2.fromOffset(14, 14),
Position = UDim2.fromScale(0.5, 0.5),
AnchorPoint = Vector2.new(0.5, 0.5),
ImageColor3 = Theme.TextMuted,
Parent = btn,
})
Icons.ApplyIcon(icon, iconName)
Helper.HoverEffect(btn, Theme.SurfaceHover, Theme.Surface)
btn.MouseButton1Click:Connect(callback)
return btn
end

CreateWindowButton("settings", function() Library:ToggleSettings() end)
Interface.New("Frame", {
BackgroundColor3 = Color3.fromRGB(50, 50, 50),
Size = UDim2.fromOffset(4, 4),
Parent = WindowButtons,
["UICorner"] = { CornerRadius = UDim.new(1, 0) },
})
CreateWindowButton("minus", function() MainFrame.Visible = not MainFrame.Visible end)
CreateWindowButton("x", function() ScreenGui:Destroy() end)

-- ============================================================
-- LEFT SIDEBAR
-- ============================================================

local Sidebar = Interface.New("Frame", {
BackgroundColor3 = Theme.Surface,
Size = UDim2.new(0, 160, 1, -36),
Position = UDim2.new(0, 0, 0, 36),
BorderSizePixel = 0,
Parent = MainFrame,
})

local SidebarScroll = Interface.New("ScrollingFrame", {
BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1),
BorderSizePixel = 0,
ScrollBarThickness = 2,
ScrollBarImageColor3 = Theme.Border,
AutomaticCanvasSize = Enum.AutomaticSize.Y,
CanvasSize = UDim2.fromScale(0, 0),
Parent = Sidebar,
["UIListLayout"] = {
FillDirection = Enum.FillDirection.Vertical,
Padding = UDim.new(0, 2),
SortOrder = Enum.SortOrder.LayoutOrder,
},
["UIPadding"] = {
PaddingLeft = UDim.new(0, 6),
PaddingRight = UDim.new(0, 6),
PaddingTop = UDim.new(0, 6),
PaddingBottom = UDim.new(0, 6),
},
})

-- ============================================================
-- SIDEBAR DIVIDER
-- ============================================================

local SidebarDivider = Interface.New("Frame", {
BackgroundColor3 = Color3.fromRGB(25, 25, 25),
Size = UDim2.new(0, 2, 1, -36),
Position = UDim2.new(0, 160, 0, 36),
ZIndex = 5,
Parent = MainFrame,
})

local DividerHandle = Interface.New("TextButton", {
Text = "",
BackgroundTransparency = 1,
Size = UDim2.new(0, 8, 1, 0),
Position = UDim2.new(0.5, 0, 0, 0),
AnchorPoint = Vector2.new(0.5, 0),
AutoButtonColor = false,
ZIndex = 6,
Parent = SidebarDivider,
})

local isDraggingDivider = false
local dividerDragStart = nil
local dividerStartWidth = 160
local ContentWrapper

DividerHandle.MouseEnter:Connect(function() SidebarDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
DividerHandle.MouseLeave:Connect(function() if not isDraggingDivider then SidebarDivider.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end end)
DividerHandle.MouseButton1Down:Connect(function()
isDraggingDivider = true
dividerDragStart = UserInputService:GetMouseLocation().X
dividerStartWidth = Sidebar.Size.X.Offset
end)

UserInputService.InputChanged:Connect(function(input)
if isDraggingDivider and input.UserInputType == Enum.UserInputType.MouseMovement then
local scale = ScreenDPIScale.Scale
local delta = (input.Position.X - dividerDragStart) / scale
local newWidth = math.clamp(dividerStartWidth + delta, 120, math.floor(MainFrame.AbsoluteSize.X / 2))
Sidebar.Size = UDim2.new(0, newWidth, 1, -36)
SidebarDivider.Position = UDim2.new(0, newWidth, 0, 36)
if ContentWrapper then
ContentWrapper.Size = UDim2.new(1, -(newWidth + 2), 1, -36)
end
end
end)

UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
isDraggingDivider = false
SidebarDivider.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
end
end)

-- ============================================================
-- CONTENT AREA
-- ============================================================

ContentWrapper = Interface.New("Frame", {
AnchorPoint = Vector2.one,
BackgroundTransparency = 1,
Position = UDim2.fromScale(1, 1),
Size = UDim2.new(1, -162, 1, -36),
Parent = MainFrame,
["UIPadding"] = {
PaddingLeft = UDim.new(0, 8),
PaddingRight = UDim.new(0, 8),
PaddingTop = UDim.new(0, 8),
PaddingBottom = UDim.new(0, 8),
},
})
-- ============================================================
-- SETTINGS PANEL
-- ============================================================

local SettingsFrame = Interface.New("Frame", {
BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1),
Visible = false,
Parent = ContentWrapper,
["UIPadding"] = { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4) },
})

local SettingsScroll = Interface.New("ScrollingFrame", {
BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
CanvasSize = UDim2.fromScale(0, 0),
ScrollBarThickness = 3,
ScrollBarImageColor3 = Theme.Border,
BorderSizePixel = 0,
Parent = SettingsFrame,
["UIListLayout"] = { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8) },
})

local function CreateSettingsSection(title)
local wrapper = Interface.New("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
Parent = SettingsScroll,
["UIListLayout"] = { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) },
})
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 20),
LayoutOrder = 0,
Text = string.upper(title),
TextColor3 = Theme.TextMuted,
TextSize = 11,
Font = Enum.Font.GothamBold,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = wrapper,
})
local section = Interface.New("Frame", {
BackgroundColor3 = Theme.Surface,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
LayoutOrder = 1,
Parent = wrapper,
["UICorner"] = { CornerRadius = UDim.new(0, 8) },
["UIStroke"] = { Color = Theme.Border, Thickness = 1, Transparency = 0.5 },
["UIListLayout"] = { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) },
["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) },
})
return section
end

local settingsRowOrder = 0
local function CreateSettingsRow(section)
settingsRowOrder += 1
return Interface.New("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 36),
LayoutOrder = settingsRowOrder,
Parent = section,
})
end

local function CreateSettingsDropdown(section, text, values, default, callback)
local row = CreateSettingsRow(section)
local currentIndex = table.find(values, default) or 1
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(0.55, 0, 1, 0),
Text = text,
TextColor3 = Theme.Text,
TextSize = 13,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = row,
})
local valueLabel = Interface.New("TextButton", {
Text = default,
TextColor3 = Theme.TextMuted,
TextSize = 12,
Font = Enum.Font.GothamMedium,
BackgroundColor3 = Theme.SurfaceHover,
BorderSizePixel = 0,
Size = UDim2.new(0, 100, 0, 26),
Position = UDim2.new(1, 0, 0.5, 0),
AnchorPoint = Vector2.new(1, 0.5),
AutoButtonColor = false,
Parent = row,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
})
valueLabel.MouseButton1Click:Connect(function()
currentIndex = (currentIndex % #values) + 1
local newValue = values[currentIndex]
valueLabel.Text = newValue
if callback then callback(newValue) end
end)
end

local ToggleKey = Enum.KeyCode.Insert

local GeneralSection = CreateSettingsSection("General")
CreateSettingsDropdown(GeneralSection, "DPI Scale", { "50%", "75%", "100%", "125%", "150%" }, "100%", function(value)
local scaleNumber = tonumber(string.match(value, "%d+"))
ScreenDPIScale.Scale = (scaleNumber or 100) / 100
end)

local KeybindSection = CreateSettingsSection("Keybinds")
local toggleKeyRow = CreateSettingsRow(KeybindSection)
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -90, 1, 0),
Text = "Toggle GUI Key",
TextColor3 = Theme.Text,
TextSize = 13,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = toggleKeyRow,
})
local toggleKeyBtn = Interface.New("TextButton", {
Text = ToggleKey.Name,
TextColor3 = Theme.TextMuted,
TextSize = 11,
Font = Enum.Font.GothamBold,
BackgroundColor3 = Theme.SurfaceHover,
BorderSizePixel = 0,
Size = UDim2.new(0, 80, 0, 24),
Position = UDim2.new(1, -80, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
AutoButtonColor = false,
Parent = toggleKeyRow,
["UICorner"] = { CornerRadius = UDim.new(0, 4) },
})
local isListeningToggleKey = false
toggleKeyBtn.MouseButton1Click:Connect(function()
isListeningToggleKey = true
toggleKeyBtn.Text = "..."
toggleKeyBtn.TextColor3 = Theme.Accent
end)
UserInputService.InputBegan:Connect(function(input)
if not isListeningToggleKey then return end
if input.UserInputType == Enum.UserInputType.Keyboard then
isListeningToggleKey = false
ToggleKey = input.KeyCode
toggleKeyBtn.Text = ToggleKey.Name
toggleKeyBtn.TextColor3 = Theme.TextMuted
end
end)

local DangerSection = CreateSettingsSection("Danger Zone")
local unloadRow = CreateSettingsRow(DangerSection)
local unloadBtn = Interface.New("TextButton", {
Text = "",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, -8),
Position = UDim2.new(0, 0, 0, 4),
AutoButtonColor = false,
ClipsDescendants = true,
Parent = unloadRow,
})
local unloadIcon = Interface.New("ImageLabel", {
BackgroundTransparency = 1,
Size = UDim2.fromOffset(14, 14),
Position = UDim2.new(0, 10, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
ImageColor3 = Theme.Error,
Parent = unloadBtn,
})
Icons.ApplyIcon(unloadIcon, "power")
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -34, 1, 0),
Position = UDim2.new(0, 30, 0, 0),
Text = "Unload Flick",
TextColor3 = Theme.Error,
TextSize = 13,
Font = Enum.Font.GothamBold,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = unloadBtn,
})
unloadBtn.MouseEnter:Connect(function()
unloadBtn.BackgroundTransparency = 0.85
unloadBtn.BackgroundColor3 = Theme.Error
end)
unloadBtn.MouseLeave:Connect(function()
unloadBtn.BackgroundTransparency = 1
end)

local AboutSection = CreateSettingsSection("About")
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 24),
Text = "<b>Nova</b> Flick",
TextColor3 = Theme.TextMuted,
TextSize = 12,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
RichText = true,
Parent = AboutSection,
})
-- ============================================================
-- OPTION ELEMENT BUILDERS
-- ============================================================

local optionOrder = 0
local function NextOrder()
optionOrder += 1
return optionOrder
end

local function CreateToggle(parent, text, default, callback)
local value = default or false
local container = Interface.New("Frame", {
BackgroundColor3 = Color3.fromRGB(25, 25, 25),
Size = UDim2.new(1, 0, 0, 38),
LayoutOrder = NextOrder(),
Parent = parent,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
})
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -52, 1, 0),
Text = text,
TextColor3 = Theme.Text,
TextSize = 13,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = container,
})
local toggleTrack = Interface.New("TextButton", {
Text = "",
BackgroundColor3 = value and Theme.Accent or Theme.SurfaceHover,
Size = UDim2.fromOffset(40, 22),
Position = UDim2.new(1, -44, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
AutoButtonColor = false,
Parent = container,
["UICorner"] = { CornerRadius = UDim.new(1, 0) },
})
local toggleKnob = Interface.New("Frame", {
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
Size = UDim2.fromOffset(16, 16),
Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
Parent = toggleTrack,
["UICorner"] = { CornerRadius = UDim.new(1, 0) },
})
local element = {
Type = "Toggle",
Value = value,
Set = function(self, newValue)
self.Value = newValue
TweenService:Create(toggleTrack, DefaultTweenInfo, { BackgroundColor3 = newValue and Theme.Accent or Theme.SurfaceHover }):Play()
TweenService:Create(toggleKnob, DefaultTweenInfo, { Position = newValue and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }):Play()
end,
}
toggleTrack.MouseButton1Click:Connect(function()
element.Value = not element.Value
element:Set(element.Value)
if callback then callback(element.Value) end
end)
return element
end

local function CreateSlider(parent, text, default, min, max, callback)
local value = math.clamp(default or min, min, max)
local container = Interface.New("Frame", {
BackgroundColor3 = Color3.fromRGB(25, 25, 25),
Size = UDim2.new(1, 0, 0, 50),
LayoutOrder = NextOrder(),
Parent = parent,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
})
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -60, 0, 20),
Position = UDim2.new(0, 0, 0, 6),
Text = text,
TextColor3 = Theme.Text,
TextSize = 13,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = container,
})
local valueLabel = Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(0, 50, 0, 20),
Position = UDim2.new(1, -50, 0, 6),
Text = tostring(math.floor(value)),
TextColor3 = Theme.Accent,
TextSize = 13,
Font = Enum.Font.GothamBold,
TextXAlignment = Enum.TextXAlignment.Right,
Parent = container,
})
local sliderBg = Interface.New("Frame", {
BackgroundColor3 = Theme.SurfaceHover,
Size = UDim2.new(1, 0, 0, 6),
Position = UDim2.new(0, 0, 0, 34),
Parent = container,
["UICorner"] = { CornerRadius = UDim.new(1, 0) },
})
local sliderFill = Interface.New("Frame", {
BackgroundColor3 = Theme.Accent,
Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
Parent = sliderBg,
["UICorner"] = { CornerRadius = UDim.new(1, 0) },
})
local sliderKnob = Interface.New("Frame", {
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
Size = UDim2.fromOffset(12, 12),
Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
AnchorPoint = Vector2.new(0.5, 0.5),
ZIndex = 2,
Parent = sliderBg,
["UICorner"] = { CornerRadius = UDim.new(1, 0) },
})
local isDragging = false
local function UpdateSlider(inputX)
local relativeX = (inputX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
relativeX = math.clamp(relativeX, 0, 1)
value = math.floor(min + (max - min) * relativeX)
valueLabel.Text = tostring(value)
sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
sliderKnob.Position = UDim2.new(relativeX, 0, 0.5, 0)
if callback then callback(value) end
end
sliderBg.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
isDragging = true
UpdateSlider(input.Position.X)
end
end)
sliderKnob.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end
end)
UserInputService.InputChanged:Connect(function(input)
if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input.Position.X) end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
end)
return { Type = "Slider", Value = value, Set = function(self, newValue)
value = math.clamp(math.floor(newValue), min, max)
self.Value = value
local pct = (value - min) / (max - min)
valueLabel.Text = tostring(value)
sliderFill.Size = UDim2.new(pct, 0, 1, 0)
sliderKnob.Position = UDim2.new(pct, 0, 0.5, 0)
end }
end

local function CreateDropdown(parent, text, options, default, callback)
local currentIndex = table.find(options, default) or 1
local value = options[currentIndex]
local container = Interface.New("Frame", {
BackgroundColor3 = Color3.fromRGB(25, 25, 25),
Size = UDim2.new(1, 0, 0, 38),
LayoutOrder = NextOrder(),
Parent = parent,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
})
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -120, 1, 0),
Text = text,
TextColor3 = Theme.Text,
TextSize = 13,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = container,
})
local dropdownBtn = Interface.New("TextButton", {
Text = value,
TextColor3 = Theme.TextMuted,
TextSize = 12,
Font = Enum.Font.GothamMedium,
BackgroundColor3 = Theme.SurfaceHover,
BorderSizePixel = 0,
Size = UDim2.new(0, 110, 0, 26),
Position = UDim2.new(1, -110, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
AutoButtonColor = false,
Parent = container,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
})
local arrowIcon = Interface.New("ImageLabel", {
BackgroundTransparency = 1,
Size = UDim2.fromOffset(10, 10),
Position = UDim2.new(1, -14, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
ImageColor3 = Theme.TextMuted,
Parent = dropdownBtn,
})
Icons.ApplyIcon(arrowIcon, "chevron-down")
dropdownBtn.MouseButton1Click:Connect(function()
currentIndex = (currentIndex % #options) + 1
value = options[currentIndex]
dropdownBtn.Text = value
if callback then callback(value) end
end)
Helper.HoverEffect(dropdownBtn, Theme.Border, Theme.SurfaceHover)
return { Type = "Dropdown", Value = value, Set = function(self, newValue)
local idx = table.find(options, newValue)
if idx then currentIndex = idx; value = newValue; self.Value = value; dropdownBtn.Text = value end
end }
end

local function CreateButton(parent, text, callback)
local container = Interface.New("TextButton", {
Text = "",
BackgroundColor3 = Color3.fromRGB(25, 25, 25),
Size = UDim2.new(1, 0, 0, 38),
LayoutOrder = NextOrder(),
AutoButtonColor = false,
ClipsDescendants = true,
Parent = parent,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
})
local btnIcon = Interface.New("ImageLabel", {
BackgroundTransparency = 1,
Size = UDim2.fromOffset(14, 14),
Position = UDim2.new(0, 0, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
ImageColor3 = Theme.Accent,
Parent = container,
})
Icons.ApplyIcon(btnIcon, "play")
Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -24, 1, 0),
Position = UDim2.new(0, 20, 0, 0),
Text = text,
TextColor3 = Theme.Text,
TextSize = 13,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = container,
})
Helper.HoverEffect(container, Color3.fromRGB(30, 30, 30), Color3.fromRGB(25, 25, 25))
container.MouseButton1Click:Connect(function()
Helper.Ripple(container)
if callback then callback() end
end)
return { Type = "Button" }
end

local function CreateLabel(parent, text)
local label = Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 24),
LayoutOrder = NextOrder(),
Text = text,
TextColor3 = Theme.TextMuted,
TextSize = 12,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = parent,
["UIPadding"] = { PaddingLeft = UDim.new(0, 4) },
})
return { Type = "Label", Set = function(_, newText) label.Text = newText end }
end

local function CreateSeparator(parent)
Interface.New("Frame", {
BackgroundColor3 = Theme.Border,
Size = UDim2.new(1, 0, 0, 1),
LayoutOrder = NextOrder(),
Parent = parent,
})
end
-- ============================================================
-- CATEGORY CLASS
-- ============================================================

local Category = {}
Category.__index = Category

function Category.new(name, iconName, contentParent)
local self = setmetatable({}, Category)
self.Name = name
self.IconName = iconName
self.ContentFrame = Interface.New("Frame", {
BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1),
Visible = false,
Parent = contentParent,
})
local categoryScroll = Interface.New("ScrollingFrame", {
BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
CanvasSize = UDim2.fromScale(0, 0),
ScrollBarThickness = 3,
ScrollBarImageColor3 = Theme.Border,
BorderSizePixel = 0,
Parent = self.ContentFrame,
["UIListLayout"] = { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder },
})
self.Scroll = categoryScroll
self.Elements = {}
return self
end

function Category:AddToggle(text, default, callback)
local elem = CreateToggle(self.Scroll, text, default, callback)
table.insert(self.Elements, elem)
return elem
end

function Category:AddSlider(text, default, min, max, callback)
local elem = CreateSlider(self.Scroll, text, default, min, max, callback)
table.insert(self.Elements, elem)
return elem
end

function Category:AddDropdown(text, options, default, callback)
local elem = CreateDropdown(self.Scroll, text, options, default, callback)
table.insert(self.Elements, elem)
return elem
end

function Category:AddButton(text, callback)
local elem = CreateButton(self.Scroll, text, callback)
table.insert(self.Elements, elem)
return elem
end

function Category:AddLabel(text)
local elem = CreateLabel(self.Scroll, text)
table.insert(self.Elements, elem)
return elem
end

function Category:AddSeparator()
CreateSeparator(self.Scroll)
end

-- ============================================================
-- LIBRARY API
-- ============================================================

function Library:AddCategory(name, iconName)
local category = Category.new(name, iconName or "folder", ContentWrapper)
local order = #self.CategoryOrder + 1
local btn = Interface.New("TextButton", {
Text = "",
BackgroundColor3 = Theme.Surface,
Size = UDim2.new(1, 0, 0, 36),
LayoutOrder = order,
AutoButtonColor = false,
Parent = SidebarScroll,
["UICorner"] = { CornerRadius = UDim.new(0, 6) },
})
local btnIcon = Interface.New("ImageLabel", {
BackgroundTransparency = 1,
Size = UDim2.fromOffset(14, 14),
Position = UDim2.new(0, 10, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
ImageColor3 = Theme.TextMuted,
Parent = btn,
})
Icons.ApplyIcon(btnIcon, iconName or "folder")
local btnLabel = Interface.New("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -36, 1, 0),
Position = UDim2.new(0, 30, 0, 0),
Text = name,
TextColor3 = Theme.TextMuted,
TextSize = 13,
Font = Enum.Font.GothamMedium,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = btn,
})
Helper.HoverEffect(btn, Theme.SurfaceHover, Theme.Surface)
category.SidebarButton = btn
category.SidebarIcon = btnIcon
category.SidebarLabel = btnLabel
self.Categories[name] = category
table.insert(self.CategoryOrder, name)
btn.MouseButton1Click:Connect(function() self:SelectCategory(name) end)
if #self.CategoryOrder == 1 then self:SelectCategory(name) end
return category
end

function Library:SelectCategory(name)
self.ActiveCategory = name
self.SettingsVisible = false
for catName, cat in pairs(self.Categories) do
local isActive = (catName == name)
cat.SidebarButton.BackgroundColor3 = isActive and Theme.Accent or Theme.Surface
cat.SidebarLabel.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.TextMuted
cat.SidebarIcon.ImageColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.TextMuted
cat.ContentFrame.Visible = isActive
end
SettingsFrame.Visible = false
end

function Library:ToggleSettings()
self.SettingsVisible = not self.SettingsVisible
if self.SettingsVisible then
for _, cat in pairs(self.Categories) do
cat.SidebarButton.BackgroundColor3 = Theme.Surface
cat.SidebarLabel.TextColor3 = Theme.TextMuted
cat.SidebarIcon.ImageColor3 = Theme.TextMuted
cat.ContentFrame.Visible = false
end
SettingsFrame.Visible = true
else
if self.ActiveCategory and self.Categories[self.ActiveCategory] then
self:SelectCategory(self.ActiveCategory)
end
end
end

function Library:Notify(text, notifType)
if notifType == "success" then Sonner.success(text)
elseif notifType == "error" then Sonner.error(text)
elseif notifType == "warning" then Sonner.warning(text)
else Sonner.info(text) end
end

function Library:Toggle()
MainFrame.Visible = not MainFrame.Visible
end

-- Toggle keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.KeyCode == ToggleKey then Library:Toggle() end
end)
-- ============================================================
-- FLICK STATE
-- ============================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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

local isEspActive = false
local espSettings = {
box = true, boxType = "corners", name = true, distance = true,
health = true, skeleton = true, tracers = false, healthBarStyle = "side"
}

local isHitboxExpanderActive = false
local hitboxSize = 10
local isRadarActive = false
local radarScale = 1
local isFovArrowsActive = false
local crosshairEnabled = false

local flickUsers = {}
local espObjects = {}
local radarDots = {}
local fovArrows = {}

-- ============================================================
-- DRAWING OBJECTS
-- ============================================================

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = fov
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(138, 43, 226)
fovCircle.Transparency = 0.8
fovCircle.Visible = isFovCircleActive

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
radarBorder.Color = Color3.fromRGB(138, 43, 226)
radarBorder.Transparency = 0.8
radarBorder.Visible = false

local radarPlayerArrow = {
line1 = Drawing.new("Line"),
line2 = Drawing.new("Line"),
line3 = Drawing.new("Line")
}
for _, line in pairs(radarPlayerArrow) do
line.Thickness = 2
line.Color = Color3.fromRGB(50, 255, 150)
line.Transparency = 1
line.Visible = false
end

-- ============================================================
-- ESP FUNCTIONS
-- ============================================================

local function isVisible(targetChar)
if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then return false end
local origin = camera.CFrame.Position
local direction = (targetChar.HumanoidRootPart.Position - origin).Unit * 500
local ray = Ray.new(origin, direction)
local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {character, camera})
return hit and hit:IsDescendantOf(targetChar)
end

local function createESP(plr)
if plr == LocalPlayer then return end
local corners = {}
for i = 1, 8 do
local line = Drawing.new("Line")
line.Visible = false
line.Color = Color3.fromRGB(138, 43, 226)
line.Thickness = 2
line.Transparency = 1
table.insert(corners, line)
end
local espBox = Drawing.new("Square")
espBox.Visible = false
espBox.Color = Color3.fromRGB(138, 43, 226)
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
espDistance.Color = Color3.fromRGB(50, 200, 255)
espDistance.Size = 12
espDistance.Center = true
espDistance.Outline = true
espDistance.Font = 2
local espHealth = Drawing.new("Text")
espHealth.Visible = false
espHealth.Color = Color3.fromRGB(50, 255, 150)
espHealth.Size = 12
espHealth.Center = true
espHealth.Outline = true
espHealth.Font = 2
local espHealthBar = Drawing.new("Square")
espHealthBar.Visible = false
espHealthBar.Color = Color3.fromRGB(50, 255, 150)
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
line.Color = Color3.fromRGB(150, 50, 255)
line.Thickness = 2
line.Transparency = 0.8
table.insert(skeletonLines, line)
end
local tracer = Drawing.new("Line")
tracer.Visible = false
tracer.Color = Color3.fromRGB(50, 200, 255)
tracer.Thickness = 1
tracer.Transparency = 0.6
local nameTag = Drawing.new("Text")
nameTag.Visible = false
nameTag.Size = 16
nameTag.Center = true
nameTag.Outline = true
nameTag.Font = 2
nameTag.Text = "Flick User"

espObjects[plr] = {
box = espBox, corners = corners, name = espName, distance = espDistance,
health = espHealth, healthBar = espHealthBar, healthBarBG = espHealthBarBG,
healthBarOutline = espHealthBarOutline, skeleton = skeletonLines, tracer = tracer, nameTag = nameTag
}
end

local function removeESP(plr)
if espObjects[plr] then
espObjects[plr].box:Remove()
for _, c in pairs(espObjects[plr].corners) do c:Remove() end
espObjects[plr].name:Remove()
espObjects[plr].distance:Remove()
espObjects[plr].health:Remove()
espObjects[plr].healthBar:Remove()
espObjects[plr].healthBarBG:Remove()
espObjects[plr].healthBarOutline:Remove()
for _, l in pairs(espObjects[plr].skeleton) do l:Remove() end
espObjects[plr].tracer:Remove()
if espObjects[plr].nameTag then espObjects[plr].nameTag:Remove() end
espObjects[plr] = nil
end
end
-- ============================================================
-- TARGET FINDING
-- ============================================================

local function getClosestPlayer()
local closestPlayer = nil
local shortestDistance = fov
for _, v in pairs(Players:GetPlayers()) do
if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(targetPart) and v.Character:FindFirstChild("Humanoid") then
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

-- ============================================================
-- CATEGORIES -- AIM
-- ============================================================

local AimCat = Library:AddCategory("Aim", "crosshair")
AimCat:AddToggle("Silent Aim", false, function(v)
isSilentAimActive = v
Library:Notify("Silent Aim: " .. (v and "ON" or "OFF"), v and "success" or "error")
end)
AimCat:AddSeparator()
AimCat:AddToggle("Aimbot", false, function(v)
isAimbotActive = v
Library:Notify("Aimbot: " .. (v and "ON" or "OFF"), v and "success" or "error")
end)
AimCat:AddSlider("Aimbot Smoothness", 5, 1, 20, function(v) aimbotSmoothness = v end)
AimCat:AddDropdown("Aimbot Key", {"RMB", "X", "C", "Z", "V", "B", "N", "M"}, "RMB", function(v) aimbotKey = v end)
AimCat:AddDropdown("Aimbot Mode", {"Hold", "Toggle"}, "Hold", function(v)
aimbotMode = v
if v == "Toggle" then aimbotEnabled = false end
end)
AimCat:AddSeparator()
AimCat:AddToggle("Trigger Bot", false, function(v)
isTriggerBotActive = v
Library:Notify("Trigger Bot: " .. (v and "ON" or "OFF"), v and "success" or "error")
end)
AimCat:AddSeparator()
AimCat:AddToggle("FOV Circle", true, function(v)
isFovCircleActive = v
fovCircle.Visible = v
end)
AimCat:AddSlider("FOV Radius", 200, 50, 500, function(v)
fov = v
fovCircle.Radius = v
end)
AimCat:AddDropdown("Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(v)
targetPart = v
end)

-- ============================================================
-- CATEGORIES -- VISUALS
-- ============================================================

local VisCat = Library:AddCategory("Visuals", "eye")
VisCat:AddToggle("ESP", false, function(v)
isEspActive = v
if v then
for _, plr in pairs(Players:GetPlayers()) do
if not espObjects[plr] and plr ~= LocalPlayer then createESP(plr) end
end
end
Library:Notify("ESP: " .. (v and "ON" or "OFF"), v and "success" or "error")
end)
VisCat:AddDropdown("Box Style", {"corners", "full"}, "corners", function(v) espSettings.boxType = v end)
VisCat:AddToggle("Show Box", true, function(v) espSettings.box = v end)
VisCat:AddToggle("Show Name", true, function(v) espSettings.name = v end)
VisCat:AddToggle("Show Distance", true, function(v) espSettings.distance = v end)
VisCat:AddToggle("Show Health", true, function(v) espSettings.health = v end)
VisCat:AddToggle("Show Skeleton", true, function(v) espSettings.skeleton = v end)
VisCat:AddToggle("Show Tracers", false, function(v) espSettings.tracers = v end)
VisCat:AddSeparator()
VisCat:AddToggle("Radar Map", false, function(v)
isRadarActive = v
radarBackground.Visible = v
radarBorder.Visible = v
for _, line in pairs(radarPlayerArrow) do line.Visible = v end
end)
VisCat:AddSlider("Radar Scale", 1, 1, 3, function(v) radarScale = v end)
VisCat:AddToggle("FOV Arrows", false, function(v) isFovArrowsActive = v end)

-- ============================================================
-- CATEGORIES -- MISC
-- ============================================================

local MiscCat = Library:AddCategory("Misc", "wrench")
MiscCat:AddToggle("Hitbox Expander", false, function(v)
isHitboxExpanderActive = v
Library:Notify("Hitbox Expander: " .. (v and "ON" or "OFF"), v and "success" or "error")
end)
MiscCat:AddSlider("Hitbox Size", 10, 1, 100, function(v) hitboxSize = v end)
MiscCat:AddSeparator()
MiscCat:AddToggle("Crosshair", false, function(v)
crosshairEnabled = v
if v then
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
_G.CrosshairConnection = RunService.RenderStepped:Connect(function()
local cx = camera.ViewportSize.X / 2
local cy = camera.ViewportSize.Y / 2
_G.Crosshair.Position = Vector2.new(cx, cy)
local gap = 12
local length = 8
_G.CrosshairLine1.From = Vector2.new(cx, cy - gap)
_G.CrosshairLine1.To = Vector2.new(cx, cy - gap - length)
_G.CrosshairLine2.From = Vector2.new(cx, cy + gap)
_G.CrosshairLine2.To = Vector2.new(cx, cy + gap + length)
_G.CrosshairLine3.From = Vector2.new(cx - gap, cy)
_G.CrosshairLine3.To = Vector2.new(cx - gap - length, cy)
_G.CrosshairLine4.From = Vector2.new(cx + gap, cy)
_G.CrosshairLine4.To = Vector2.new(cx + gap + length, cy)
end)
else
if _G.Crosshair then _G.Crosshair:Remove(); _G.Crosshair = nil end
if _G.CrosshairLine1 then _G.CrosshairLine1:Remove(); _G.CrosshairLine1 = nil end
if _G.CrosshairLine2 then _G.CrosshairLine2:Remove(); _G.CrosshairLine2 = nil end
if _G.CrosshairLine3 then _G.CrosshairLine3:Remove(); _G.CrosshairLine3 = nil end
if _G.CrosshairLine4 then _G.CrosshairLine4:Remove(); _G.CrosshairLine4 = nil end
if _G.CrosshairConnection then _G.CrosshairConnection:Disconnect(); _G.CrosshairConnection = nil end
end
end)
MiscCat:AddSeparator()
MiscCat:AddButton("Anti-Cheat Bypass", function()
pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua"))()
end)
Library:Notify("Anti-cheat bypass executed!", "success")
end)
MiscCat:AddSeparator()
MiscCat:AddButton("Rejoin", function()
TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
Library:Notify("Rejoining...", "warning")
end)
MiscCat:AddButton("Server Hop", function()
pcall(function()
local url = "https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?sortOrder=Asc&limit=100"
local data = HttpService:JSONDecode(game:HttpGet(url))
if data and data.data then
for _, s in pairs(data.data) do
if s.id ~= game.JobId and s.playing < s.maxPlayers then
TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
Library:Notify("Server hopping...", "warning")
return
end
end
end
Library:Notify("No available servers!", "error")
end)
end)
MiscCat:AddButton("Copy Job ID", function()
if setclipboard then
setclipboard(game.JobId)
Library:Notify("Job ID copied!", "success")
else
Library:Notify("Clipboard not supported!", "error")
end
end)
-- ============================================================
-- GAME LOGIC -- ESP UPDATE
-- ============================================================

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
local boxColor = visible and Color3.fromRGB(50, 255, 150) or Color3.fromRGB(255, 70, 70)

if espSettings.box then
if espSettings.boxType == "corners" then
esp.box.Visible = false
local cornerLength = math.min(width, height) * 0.25
local tl = Vector2.new(hrpVector.X - width/2, hrpVector.Y - height/2)
local tr = Vector2.new(hrpVector.X + width/2, hrpVector.Y - height/2)
local bl = Vector2.new(hrpVector.X - width/2, hrpVector.Y + height/2)
local br = Vector2.new(hrpVector.X + width/2, hrpVector.Y + height/2)
esp.corners[1].From = tl; esp.corners[1].To = Vector2.new(tl.X + cornerLength, tl.Y); esp.corners[1].Color = boxColor; esp.corners[1].Visible = true
esp.corners[2].From = tl; esp.corners[2].To = Vector2.new(tl.X, tl.Y + cornerLength); esp.corners[2].Color = boxColor; esp.corners[2].Visible = true
esp.corners[3].From = tr; esp.corners[3].To = Vector2.new(tr.X - cornerLength, tr.Y); esp.corners[3].Color = boxColor; esp.corners[3].Visible = true
esp.corners[4].From = tr; esp.corners[4].To = Vector2.new(tr.X, tr.Y + cornerLength); esp.corners[4].Color = boxColor; esp.corners[4].Visible = true
esp.corners[5].From = bl; esp.corners[5].To = Vector2.new(bl.X + cornerLength, bl.Y); esp.corners[5].Color = boxColor; esp.corners[5].Visible = true
esp.corners[6].From = bl; esp.corners[6].To = Vector2.new(bl.X, bl.Y - cornerLength); esp.corners[6].Color = boxColor; esp.corners[6].Visible = true
esp.corners[7].From = br; esp.corners[7].To = Vector2.new(br.X - cornerLength, br.Y); esp.corners[7].Color = boxColor; esp.corners[7].Visible = true
esp.corners[8].From = br; esp.corners[8].To = Vector2.new(br.X, br.Y - cornerLength); esp.corners[8].Color = boxColor; esp.corners[8].Visible = true
else
for _, c in pairs(esp.corners) do c.Visible = false end
esp.box.Color = boxColor
esp.box.Size = Vector2.new(width, height)
esp.box.Position = Vector2.new(hrpVector.X - width/2, hrpVector.Y - height/2)
esp.box.Visible = true
end
else
esp.box.Visible = false
for _, c in pairs(esp.corners) do c.Visible = false end
end

if espSettings.name then
esp.name.Position = Vector2.new(hrpVector.X, headVector.Y - 18)
esp.name.Visible = true
else esp.name.Visible = false end

if espSettings.distance then
local dist = math.floor((camera.CFrame.Position - hrp.Position).Magnitude)
esp.distance.Text = dist .. "m"
esp.distance.Position = Vector2.new(hrpVector.X, legVector.Y + 8)
esp.distance.Visible = true
else esp.distance.Visible = false end

if espSettings.health then
local hp = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
local barH = height
local barW = 4
local barX = hrpVector.X - width/2 - 8
local barY = hrpVector.Y - height/2
esp.healthBarBG.Size = Vector2.new(barW, barH)
esp.healthBarBG.Position = Vector2.new(barX, barY)
esp.healthBarBG.Visible = true
esp.healthBarOutline.Size = Vector2.new(barW + 2, barH + 2)
esp.healthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
esp.healthBarOutline.Visible = true
local curH = barH * (humanoid.Health / humanoid.MaxHealth)
esp.healthBar.Size = Vector2.new(barW, curH)
esp.healthBar.Position = Vector2.new(barX, barY + (barH - curH))
if hp > 75 then esp.healthBar.Color = Color3.fromRGB(50, 255, 150)
elseif hp > 50 then esp.healthBar.Color = Color3.fromRGB(255, 255, 0)
elseif hp > 25 then esp.healthBar.Color = Color3.fromRGB(255, 165, 0)
else esp.healthBar.Color = Color3.fromRGB(255, 70, 70) end
esp.healthBar.Visible = true
esp.health.Text = hp .. "%"
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
local la = plr.Character:FindFirstChild("Left Arm")
local ra = plr.Character:FindFirstChild("Right Arm")
local ll = plr.Character:FindFirstChild("Left Leg")
local rl = plr.Character:FindFirstChild("Right Leg")
if torso and head and la and ra and ll and rl then
local conns = {
{head.Position, torso.Position},
{torso.Position, la.Position},
{torso.Position, ra.Position},
{torso.Position, ll.Position},
{torso.Position, rl.Position},
{la.Position, ra.Position}
}
for i, conn in ipairs(conns) do
local sp, sOn = camera:WorldToViewportPoint(conn[1])
local ep, eOn = camera:WorldToViewportPoint(conn[2])
if sOn and eOn and esp.skeleton[i] then
esp.skeleton[i].From = Vector2.new(sp.X, sp.Y)
esp.skeleton[i].To = Vector2.new(ep.X, ep.Y)
esp.skeleton[i].Visible = true
elseif esp.skeleton[i] then
esp.skeleton[i].Visible = false
end
end
end
else
for _, l in pairs(esp.skeleton) do l.Visible = false end
end

if espSettings.tracers then
esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
esp.tracer.To = Vector2.new(hrpVector.X, legVector.Y)
esp.tracer.Color = boxColor
esp.tracer.Visible = true
else esp.tracer.Visible = false end

if flickUsers[plr.UserId] then
local t = tick() * 3
local r = math.floor(math.sin(t) * 127 + 128)
local g = math.floor(math.sin(t + 2.1) * 127 + 128)
local b = math.floor(math.sin(t + 4.2) * 127 + 128)
esp.nameTag.Color = Color3.fromRGB(r, g, b)
esp.nameTag.Position = Vector2.new(hrpVector.X, headVector.Y - 35)
esp.nameTag.Visible = true
else
if esp.nameTag then esp.nameTag.Visible = false end
end
else
esp.box.Visible = false
for _, c in pairs(esp.corners) do c.Visible = false end
esp.name.Visible = false
esp.distance.Visible = false
esp.health.Visible = false
esp.healthBar.Visible = false
esp.healthBarBG.Visible = false
esp.healthBarOutline.Visible = false
for _, l in pairs(esp.skeleton) do l.Visible = false end
esp.tracer.Visible = false
if esp.nameTag then esp.nameTag.Visible = false end
end
else
esp.box.Visible = false
for _, c in pairs(esp.corners) do c.Visible = false end
esp.name.Visible = false
esp.distance.Visible = false
esp.health.Visible = false
esp.healthBar.Visible = false
esp.healthBarBG.Visible = false
esp.healthBarOutline.Visible = false
for _, l in pairs(esp.skeleton) do l.Visible = false end
esp.tracer.Visible = false
if esp.nameTag then esp.nameTag.Visible = false end
end
end
end
-- ============================================================
-- GAME LOGIC -- RADAR
-- ============================================================

local function updateRadar()
if not isRadarActive or not character or not character:FindFirstChild("HumanoidRootPart") then
for _, line in pairs(radarPlayerArrow) do line.Visible = false end
return
end
local radarSize = 100
local radarX = 120
local radarY = camera.ViewportSize.Y - 120
radarBackground.Position = Vector2.new(radarX, radarY)
radarBackground.Radius = radarSize
radarBorder.Position = Vector2.new(radarX, radarY)
radarBorder.Radius = radarSize
local lv = character.HumanoidRootPart.CFrame.LookVector
local angle = math.atan2(lv.Z, lv.X)
local bx = radarX
local by = radarY
local al = 15
local tipX = bx + math.cos(angle) * al
local tipY = by + math.sin(angle) * al
local wa1 = angle + math.rad(150)
local wa2 = angle - math.rad(150)
local wl = 8
radarPlayerArrow.line1.From = Vector2.new(bx, by)
radarPlayerArrow.line1.To = Vector2.new(tipX, tipY)
radarPlayerArrow.line1.Visible = true
radarPlayerArrow.line2.From = Vector2.new(tipX, tipY)
radarPlayerArrow.line2.To = Vector2.new(bx + math.cos(wa1) * wl, by + math.sin(wa1) * wl)
radarPlayerArrow.line2.Visible = true
radarPlayerArrow.line3.From = Vector2.new(tipX, tipY)
radarPlayerArrow.line3.To = Vector2.new(bx + math.cos(wa2) * wl, by + math.sin(wa2) * wl)
radarPlayerArrow.line3.Visible = true
for plr, dot in pairs(radarDots) do
if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
local offset = plr.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position
local dist = offset.Magnitude
if dist < 500 * radarScale then
local wa = math.atan2(offset.Z, offset.X)
local ra = wa - angle
local scale = math.min(dist / (5 * radarScale), radarSize - 10)
dot.Position = Vector2.new(radarX + math.cos(ra) * scale, radarY + math.sin(ra) * scale)
dot.Visible = true
else
dot.Visible = false
end
else
dot.Visible = false
end
end
end

-- ============================================================
-- GAME LOGIC -- FOV ARROWS
-- ============================================================

local function updateFovArrows()
if not isFovArrowsActive then
for _, a in pairs(fovArrows) do a.Visible = false end
return
end
local cx = camera.ViewportSize.X / 2
local cy = camera.ViewportSize.Y / 2
local idx = 1
for _, plr in pairs(Players:GetPlayers()) do
if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
local pos, onScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
if not onScreen or (Vector2.new(pos.X, pos.Y) - Vector2.new(cx, cy)).Magnitude > fov then
local a = math.atan2(pos.Y - cy, pos.X - cx)
local ad = fov + 20
local ax = cx + math.cos(a) * ad
local ay = cy + math.sin(a) * ad
if not fovArrows[idx] then
local arrow = Drawing.new("Triangle")
arrow.Thickness = 2
arrow.Filled = true
arrow.Color = Color3.fromRGB(255, 70, 70)
arrow.Transparency = 0.8
fovArrows[idx] = arrow
end
local arrow = fovArrows[idx]
local sz = 12
local ba1 = a + math.rad(150)
local ba2 = a - math.rad(150)
arrow.PointA = Vector2.new(ax + math.cos(a) * sz, ay + math.sin(a) * sz)
arrow.PointB = Vector2.new(ax + math.cos(ba1) * sz, ay + math.sin(ba1) * sz)
arrow.PointC = Vector2.new(ax + math.cos(ba2) * sz, ay + math.sin(ba2) * sz)
arrow.Visible = true
idx = idx + 1
end
end
end
for i = idx, #fovArrows do fovArrows[i].Visible = false end
end

-- ============================================================
-- GAME LOGIC -- HITBOX EXPANDER
-- ============================================================

local function updateHitboxes()
for _, v in pairs(Players:GetPlayers()) do
if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
local hrp = v.Character.HumanoidRootPart
if isHitboxExpanderActive then
hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
hrp.Transparency = 0.8
hrp.CanCollide = false
else
hrp.Size = Vector3.new(2, 2, 1)
hrp.Transparency = 1
hrp.CanCollide = false
end
end
end
end

-- ============================================================
-- GAME LOGIC -- AIMBOT KEY MAP
-- ============================================================

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
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

UserInputService.InputEnded:Connect(function(input)
if isAimbotActive and aimbotMode == "Hold" then
local currentKey = keyMap[aimbotKey]
if currentKey then
if (input.UserInputType == currentKey) or (input.KeyCode == currentKey) then
aimbotEnabled = false
end
end
end
end)

-- ============================================================
-- GAME LOGIC -- SILENT AIM
-- ============================================================

local currentTarget = nil

mouse.Button1Down:Connect(function()
if isSilentAimActive and currentTarget then
local oldCFrame = camera.CFrame
camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
task.wait()
camera.CFrame = oldCFrame
end
end)
-- ============================================================
-- GAME LOGIC -- RENDER STEPPED LOOPS
-- ============================================================

local lastShotTime = 0
local triggerBotDelay = 0.1

RunService.RenderStepped:Connect(function()
-- FOV circle
fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

-- Hitboxes
updateHitboxes()

-- Radar
updateRadar()

-- FOV Arrows
updateFovArrows()

-- ESP
updateESP()

-- Silent aim target
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

-- Aimbot
if isAimbotActive and aimbotEnabled then
local target = getClosestPlayer()
if target and target.Character and target.Character:FindFirstChild(targetPart) then
if isVisible(target.Character) then
local tPos = target.Character[targetPart].Position
local curCF = camera.CFrame
local tCF = CFrame.new(curCF.Position, tPos)
camera.CFrame = curCF:Lerp(tCF, 1 / aimbotSmoothness)
end
end
end

-- Trigger bot
if isTriggerBotActive then
local target = getClosestPlayer()
if target and target.Character and target.Character:FindFirstChild(targetPart) then
if isVisible(target.Character) then
local ct = tick()
if ct - lastShotTime >= triggerBotDelay then
local tp = target.Character[targetPart]
local oldCF = camera.CFrame
camera.CFrame = CFrame.new(camera.CFrame.Position, tp.Position)
task.wait(0.05)
mouse1press()
task.wait(0.02)
mouse1release()
task.wait(0.03)
camera.CFrame = oldCF
lastShotTime = ct
end
end
end
end
end)

-- ============================================================
-- FLICK USER DETECTION
-- ============================================================

local function markFlickUser(userId)
if not flickUsers[userId] then
flickUsers[userId] = true
for _, plr in pairs(Players:GetPlayers()) do
if plr.UserId == userId and not espObjects[plr] and plr ~= LocalPlayer then
createESP(plr)
end
end
end
end

markFlickUser(LocalPlayer.UserId)

local function sendDetectionMessage()
pcall(function()
if TextChatService:FindFirstChild("TextChannels") then
local gc = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
if gc then gc:SendAsync(".") end
end
pcall(function()
ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(".", "All")
end)
local marker = Instance.new("StringValue")
marker.Name = "FF_User_" .. LocalPlayer.UserId
marker.Value = "ACTIVE"
marker.Parent = ReplicatedStorage
game:GetService("Debris"):AddItem(marker, 5)
end)
end

local function detectViaStorage()
for _, obj in pairs(ReplicatedStorage:GetChildren()) do
if obj:IsA("StringValue") and string.match(obj.Name, "FF_User_") then
local uid = tonumber(string.match(obj.Name, "%d+"))
if uid and uid ~= LocalPlayer.UserId then markFlickUser(uid) end
end
end
end

ReplicatedStorage.ChildAdded:Connect(function(child)
if child:IsA("StringValue") and string.match(child.Name, "FF_User_") then
local uid = tonumber(string.match(child.Name, "%d+"))
if uid and uid ~= LocalPlayer.UserId then markFlickUser(uid) end
end
end)

pcall(function()
TextChatService.MessageReceived:Connect(function(message)
if message.Text == "." and message.TextSource then
local uid = message.TextSource.UserId
if uid ~= LocalPlayer.UserId then markFlickUser(uid) end
end
end)
end)

pcall(function()
local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
if chatEvents then
local omdf = chatEvents:FindFirstChild("OnMessageDoneFiltering")
if omdf then
omdf.OnClientEvent:Connect(function(messageData)
if messageData and messageData.Message == "." then
local speaker = Players:FindFirstChild(messageData.FromSpeaker)
if speaker and speaker ~= LocalPlayer then markFlickUser(speaker.UserId) end
end
end)
end
end
end)

task.spawn(function()
task.wait(2)
sendDetectionMessage()
task.wait(1)
detectViaStorage()
end)

-- ============================================================
-- PLAYER CONNECTIONS
-- ============================================================

Players.PlayerAdded:Connect(function(plr)
createESP(plr)
local dot = Drawing.new("Circle")
dot.Thickness = 1
dot.NumSides = 20
dot.Radius = 4
dot.Filled = true
dot.Color = Color3.fromRGB(255, 70, 70)
dot.Transparency = 1
dot.Visible = false
radarDots[plr] = dot
end)

Players.PlayerRemoving:Connect(function(plr)
removeESP(plr)
if radarDots[plr] then radarDots[plr]:Remove(); radarDots[plr] = nil end
end)

for _, plr in pairs(Players:GetPlayers()) do
if plr ~= LocalPlayer then
createESP(plr)
local dot = Drawing.new("Circle")
dot.Thickness = 1
dot.NumSides = 20
dot.Radius = 4
dot.Filled = true
dot.Color = Color3.fromRGB(255, 70, 70)
dot.Transparency = 1
dot.Visible = false
radarDots[plr] = dot
end
end

LocalPlayer.CharacterAdded:Connect(function(char)
character = char
task.wait(0.3)
end)

-- Flick user highlight loop
RunService.RenderStepped:Connect(function()
for userId, _ in pairs(flickUsers) do
for _, plr in pairs(Players:GetPlayers()) do
if plr.UserId == userId and plr ~= LocalPlayer and plr.Character then
for _, part in pairs(plr.Character:GetDescendants()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
part.Color = Color3.fromRGB(255, 255, 0)
part.Material = Enum.Material.Neon
end
end
end
end
end
end)

-- Unload button handler (deferred to here so variables are in scope)
unloadBtn.MouseButton1Click:Connect(function()
pcall(function() fovCircle:Remove() end)
pcall(function() radarBackground:Remove() end)
pcall(function() radarBorder:Remove() end)
for _, line in pairs(radarPlayerArrow) do pcall(function() line:Remove() end) end
for _, dot in pairs(radarDots) do pcall(function() dot:Remove() end) end
for _, arrow in pairs(fovArrows) do pcall(function() arrow:Remove() end) end
for plr, _ in pairs(espObjects) do removeESP(plr) end
pcall(function() if _G.Crosshair then _G.Crosshair:Remove() end end)
pcall(function() if _G.CrosshairLine1 then _G.CrosshairLine1:Remove() end end)
pcall(function() if _G.CrosshairLine2 then _G.CrosshairLine2:Remove() end end)
pcall(function() if _G.CrosshairLine3 then _G.CrosshairLine3:Remove() end end)
pcall(function() if _G.CrosshairLine4 then _G.CrosshairLine4:Remove() end end)
pcall(function() if _G.CrosshairConnection then _G.CrosshairConnection:Disconnect() end end)
ScreenGui:Destroy()
end)

Library:Notify("Flick loaded!", "success")

return Library
end)() end,
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)--[[
	Theme Module - Template (Based on Nova)
	Centralized color definitions for consistent UI theming.
	
	Usage:
		local Theme = require(path.to.Theme)
		frame.BackgroundColor3 = Theme.Background
]]

local Theme = {
	-- Base colors
	Background = Color3.fromRGB(15, 15, 15),
	Surface = Color3.fromRGB(20, 20, 20),
	SurfaceHover = Color3.fromRGB(28, 28, 28),
	
	-- Border colors
	Border = Color3.fromRGB(40, 40, 40),
	BorderLight = Color3.fromRGB(55, 55, 55),
	
	-- Text colors
	Text = Color3.fromRGB(220, 220, 220),
	TextMuted = Color3.fromRGB(140, 140, 140),
	
	-- Accent colors
	Accent = Color3.fromRGB(88, 101, 242),
	AccentHover = Color3.fromRGB(98, 111, 252),
	
	-- Status colors
	Success = Color3.fromRGB(63, 185, 80),
	Warning = Color3.fromRGB(210, 153, 34),
	Error = Color3.fromRGB(248, 81, 73),
	Info = Color3.fromRGB(88, 166, 255),
	
	-- Direction colors (from Nova's Incoming/Outgoing)
	Primary = Color3.fromRGB(63, 185, 80),
	Secondary = Color3.fromRGB(247, 129, 102),
}

-- Utility function to lighten a color
function Theme.Lighten(color: Color3, amount: number): Color3
	return Color3.new(
		math.min(color.R + amount, 1),
		math.min(color.G + amount, 1),
		math.min(color.B + amount, 1)
	)
end

-- Utility function to darken a color
function Theme.Darken(color: Color3, amount: number): Color3
	return Color3.new(
		math.max(color.R - amount, 0),
		math.max(color.G - amount, 0),
		math.max(color.B - amount, 0)
	)
end

return Theme

end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)--[[
	Interface Module - Template
	Utility for creating UI elements with properties applied automatically.
	
	Usage:
		local Interface = require(path.to.Interface)
		
		local frame = Interface.New("Frame", {
			Size = UDim2.fromOffset(200, 100),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			Parent = screenGui,
			
			["UICorner"] = { CornerRadius = UDim.new(0, 8) },
			["UIStroke"] = { Color = Color3.fromRGB(50, 50, 50), Thickness = 1 },
		})
]]

local Interface = {}

-- Special UI components that can be created inline
local SpecialProperties = {
	["UICorner"] = true,
	["UIStroke"] = true,
	["UIPadding"] = true,
	["UIListLayout"] = true,
	["UIGridLayout"] = true,
	["UITableLayout"] = true,
	["UIPageLayout"] = true,
	["UIFlexItem"] = true,
	["UISizeConstraint"] = true,
	["UITextSizeConstraint"] = true,
	["UIAspectRatioConstraint"] = true,
	["UIGradient"] = true,
	["UIScale"] = true,
}

--[[
	Create a new instance with properties
	@param className The class name of the instance to create
	@param properties Table of properties to apply (supports nested UI components)
	@return The created instance
]]
function Interface.New(className: string, properties: { [string]: any }?): Instance
	local instance = Instance.new(className)

	if properties then
		for key, value in pairs(properties) do
			if SpecialProperties[key] then
				-- Create UI component as child
				local uiComponent = Instance.new(key)
				if type(value) == "table" then
					for prop, val in pairs(value) do
						uiComponent[prop] = val
					end
				end
				uiComponent.Parent = instance
			else
				instance[key] = value
			end
		end
	end

	return instance
end

--[[
	Create a ScreenGui with common settings
	@param name The name of the ScreenGui
	@param parent Optional parent (defaults to CoreGui/PlayerGui)
	@return The created ScreenGui
]]
function Interface.CreateScreenGui(name: string, parent: Instance?): ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999999

	if parent then
		screenGui.Parent = parent
	else
		-- Try gethui first, then CoreGui
		local success, _ = pcall(function()
			if gethui then
				screenGui.Parent = gethui()
			else
				screenGui.Parent = wax.shared.CoreGui
			end
		end)

		if not success then
			pcall(function()
				screenGui.Parent = wax.shared.Players.LocalPlayer:WaitForChild("PlayerGui")
			end)
		end
	end

	return screenGui
end

--[[
	Create a TextLabel with sensible defaults
]]
function Interface.CreateTextLabel(properties: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("TextLabel", properties) :: TextLabel
end

--[[
	Create a TextButton with sensible defaults
]]
function Interface.CreateTextButton(properties: { [string]: any }): TextButton
	local defaults = {
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("TextButton", properties) :: TextButton
end

--[[
	Create an ImageLabel with sensible defaults
]]
function Interface.CreateImageLabel(properties: { [string]: any }): ImageLabel
	local defaults = {
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("ImageLabel", properties) :: ImageLabel
end

--[[
	Create an ImageButton with sensible defaults
]]
function Interface.CreateImageButton(properties: { [string]: any }): ImageButton
	local defaults = {
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("ImageButton", properties) :: ImageButton
end

--[[
	Create a ScrollingFrame with sensible defaults
]]
function Interface.CreateScrollingFrame(properties: { [string]: any }): ScrollingFrame
	local defaults = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("ScrollingFrame", properties) :: ScrollingFrame
end

return Interface

end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)--[[
	Resize Module - Template
	Enables resize functionality on UI frames.
	
	Usage:
		local Resize = require(path.to.Resize)
		
		Resize.new({
			MainFrame = mainFrame,
			MinimumSize = Vector2.new(300, 200),
			MaximumSize = UDim2.fromOffset(800, 600),
		})
]]

local Resize = {}
Resize.__index = Resize

local UserInputService = game:GetService("UserInputService")

local HANDLE_SIZE = 6
local CORNER_HANDLE_SIZE = 20

export type ResizeOptions = {
	MainFrame: Frame,
	MinimumSize: Vector2? | UDim2?,
	MaximumSize: UDim2?,
	HandleSize: number?,
	CornerHandleSize: number?,
	Mirrored: boolean?,
}

export type ResizeObject = {
	MainFrame: Frame,
	ResizeHandle: TextButton,
	Enabled: boolean,
	SetEnabled: (self: ResizeObject, enabled: boolean) -> (),
	Destroy: (self: ResizeObject) -> (),
}

--[[
	Create a new resizable frame
	@param options Configuration options
	@return ResizeObject
]]
function Resize.new(options: ResizeOptions): ResizeObject
	local MainFrame = options.MainFrame
	local HandleSize = options.HandleSize or HANDLE_SIZE
	local CornerHandleSize = options.CornerHandleSize or CORNER_HANDLE_SIZE
	local Mirrored = options.Mirrored or false

	local MinimumSize
	if typeof(options.MinimumSize) == "Vector2" then
		MinimumSize = UDim2.fromOffset(options.MinimumSize.X, options.MinimumSize.Y)
	elseif typeof(options.MinimumSize) == "UDim2" then
		MinimumSize = options.MinimumSize
	else
		MinimumSize = UDim2.fromOffset(200, 150)
	end

	local MaximumSize = options.MaximumSize or UDim2.fromOffset(9999, 9999)

	local self = setmetatable({}, Resize)
	self.MainFrame = MainFrame
	self.Enabled = true

	-- Bottom-right corner resize handle
	local ResizeHandle = Instance.new("TextButton")
	ResizeHandle.Text = ""
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.Size = UDim2.fromOffset(CornerHandleSize, CornerHandleSize)
	ResizeHandle.Position = UDim2.new(1, -CornerHandleSize, 1, -CornerHandleSize)
	ResizeHandle.ZIndex = 100
	ResizeHandle.Parent = MainFrame

	self.ResizeHandle = ResizeHandle

	local dragging = false
	local dragStart = nil
	local startSize = nil
	local connections = {}

	table.insert(connections, ResizeHandle.InputBegan:Connect(function(input)
		if not self.Enabled then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startSize = MainFrame.Size

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not self.Enabled then return end
		
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local newWidth = math.clamp(
				startSize.X.Offset + (Mirrored and -delta.X or delta.X),
				MinimumSize.X.Offset,
				MaximumSize.X.Offset
			)
			local newHeight = math.clamp(
				startSize.Y.Offset + (Mirrored and -delta.Y or delta.Y),
				MinimumSize.Y.Offset,
				MaximumSize.Y.Offset
			)

			MainFrame.Size = UDim2.fromOffset(newWidth, newHeight)
		end
	end))

	function self:SetEnabled(enabled: boolean)
		self.Enabled = enabled
		ResizeHandle.Visible = enabled
		if not enabled then
			dragging = false
		end
	end

	function self:Destroy()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		connections = {}
		ResizeHandle:Destroy()
	end

	return self
end

return Resize

end)() end,
    [9] = function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)--[[
	Sonner Module - Template
	Toast notification system inspired by Emil Kowalski's Sonner.
	
	Usage:
		local Sonner = require(path.to.Sonner)
		
		-- Initialize with parent ScreenGui
		Sonner.Initialize(screenGui)
		
		-- Show notifications
		Sonner.info("Information message")
		Sonner.success("Operation successful!")
		Sonner.warning("Warning message")
		Sonner.error("Something went wrong")
		Sonner.toast("Simple toast message")
]]

local Sonner = {
	Queue = {},
	TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
	Wrapper = nil,
	PendingQueue = {},
	Processing = false,
}

local TweenService = game:GetService("TweenService")

-- Default notification icons (Lucide icon names)
local NotificationIcons = {
	info = "info",
	success = "circle-check",
	warning = "triangle-alert",
	error = "circle-alert",
	loading = "loader-circle",
}

-- Optional Icons module reference (set via Initialize)
local Icons = nil

local function CreateNotificationObject(zindex: number, iconName: string?, text: string)
	-- Main notification container
	local notification = Instance.new("CanvasGroup")
	notification.BorderSizePixel = 0
	notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	notification.AnchorPoint = Vector2.new(0.5, 1)
	notification.Size = UDim2.new(1, 0, 0, 42)
	notification.GroupTransparency = 1
	notification.ZIndex = zindex
	notification.Position = UDim2.new(0.5, 0, 1, 50)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(40, 40, 40)
	stroke.Thickness = 1
	stroke.Parent = notification

	-- Icon (if provided and Icons module available)
	local hasIcon = iconName and Icons
	if hasIcon then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.BackgroundTransparency = 1
		iconLabel.Size = UDim2.fromOffset(16, 16)
		iconLabel.Position = UDim2.new(0, 12, 0.5, 0)
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.ImageColor3 = Color3.fromRGB(200, 200, 200)
		iconLabel.Parent = notification

		if Icons.ApplyIcon then
			Icons.ApplyIcon(iconLabel, iconName)
		end
	end

	-- Text
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -44, 1, 0)
	textLabel.Position = UDim2.new(0, hasIcon and 36 or 12, 0, 0)
	textLabel.Text = text
	textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	textLabel.TextSize = 13
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = notification

	return notification
end

local function ProcessQueue()
	if Sonner.Processing then
		return
	end
	Sonner.Processing = true

	while #Sonner.PendingQueue > 0 do
		local entry = table.remove(Sonner.PendingQueue, 1)
		local notif = entry.notif
		local duration = entry.duration or 4.5

		if Sonner.Wrapper then
			notif.Parent = Sonner.Wrapper

			-- Animate in
			TweenService:Create(notif, Sonner.TweenInfo, {
				Position = UDim2.new(0.5, 0, 1, -8),
				GroupTransparency = 0,
			}):Play()

			-- Auto dismiss
			task.delay(duration, function()
				local tween = TweenService:Create(notif, Sonner.TweenInfo, {
					Position = UDim2.new(0.5, 0, 1, 50),
					GroupTransparency = 1,
				})
				tween:Play()
				tween.Completed:Connect(function()
					notif:Destroy()

					-- Remove from queue
					local index = table.find(Sonner.Queue, notif)
					if index then
						table.remove(Sonner.Queue, index)
					end
				end)
			end)
		end
	end

	Sonner.Processing = false
end

local function ShowToast(iconName: string?, text: string, duration: number?)
	if not Sonner.Wrapper then
		return
	end

	local zindex = #Sonner.Queue + 1
	local notif = CreateNotificationObject(zindex, iconName, text)

	table.insert(Sonner.Queue, notif)
	table.insert(Sonner.PendingQueue, {
		notif = notif,
		duration = duration or 4.5,
	})

	task.spawn(ProcessQueue)
end

--[[
	Initialize Sonner with a parent ScreenGui
	@param parent The ScreenGui to parent notifications to
	@param iconsModule Optional Icons module for displaying icons
]]
function Sonner.Initialize(parent: ScreenGui, iconsModule: any?)
	Icons = iconsModule

	Sonner.Wrapper = Instance.new("Frame")
	Sonner.Wrapper.BackgroundTransparency = 1
	Sonner.Wrapper.Size = UDim2.new(0, 360, 0, 200)
	Sonner.Wrapper.Position = UDim2.new(0.5, 0, 1, -20)
	Sonner.Wrapper.AnchorPoint = Vector2.new(0.5, 1)
	Sonner.Wrapper.ZIndex = 100000
	Sonner.Wrapper.Parent = parent
end

--[[
	Show an info notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.info(text: string, duration: number?)
	ShowToast(NotificationIcons.info, text, duration)
end

--[[
	Show a success notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.success(text: string, duration: number?)
	ShowToast(NotificationIcons.success, text, duration)
end

--[[
	Show a warning notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.warning(text: string, duration: number?)
	ShowToast(NotificationIcons.warning, text, duration)
end

--[[
	Show an error notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.error(text: string, duration: number?)
	ShowToast(NotificationIcons.error, text, duration)
end

--[[
	Show a simple toast without icon
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.toast(text: string, duration: number?)
	ShowToast(nil, text, duration)
end

--[[
	Clear all active notifications
]]
function Sonner.clear()
	for _, notif in ipairs(Sonner.Queue) do
		notif:Destroy()
	end
	Sonner.Queue = {}
	Sonner.PendingQueue = {}
end

return Sonner

end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)--[[
	Helper Module - Template
	Various UI utility functions for common interactions.
	
	Usage:
		local Helper = require(path.to.Helper)
		Helper.HoverEffect(button, hoverColor, normalColor)
		Helper.Ripple(button)
]]

local Helper = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--[[
	Add ripple effect to a button on click
	@param button The button to add ripple effect to
	@param color Optional ripple color (default: white)
]]
function Helper.Ripple(button: TextButton | ImageButton, color: Color3?)
	color = color or Color3.fromRGB(255, 255, 255)
	button.ClipsDescendants = true

	button.MouseButton1Click:Connect(function()
		local mouse = UserInputService:GetMouseLocation()
		local absolutePos = button.AbsolutePosition
		local relativeX = mouse.X - absolutePos.X
		local relativeY = mouse.Y - absolutePos.Y

		local circle = Instance.new("Frame")
		circle.BackgroundColor3 = color
		circle.BackgroundTransparency = 0.7
		circle.Position = UDim2.fromOffset(relativeX, relativeY)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Size = UDim2.fromOffset(0, 0)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = circle

		circle.Parent = button

		local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
		local tween = TweenService:Create(circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = 1,
		})

		tween:Play()
		tween.Completed:Connect(function()
			circle:Destroy()
		end)
	end)
end

--[[
	Add hover effect to a UI element
	@param element The UI element to add hover effect to
	@param hoverColor Color when hovered
	@param normalColor Color when not hovered (defaults to current BackgroundColor3)
]]
function Helper.HoverEffect(element: GuiObject, hoverColor: Color3?, normalColor: Color3?)
	normalColor = normalColor or element.BackgroundColor3
	hoverColor = hoverColor or Color3.fromRGB(
		math.min(normalColor.R * 255 + 20, 255) / 255,
		math.min(normalColor.G * 255 + 20, 255) / 255,
		math.min(normalColor.B * 255 + 20, 255) / 255
	)

	element.MouseEnter:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundColor3 = hoverColor,
		}):Play()
	end)

	element.MouseLeave:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundColor3 = normalColor,
		}):Play()
	end)
end

--[[
	Add hover transparency effect to a UI element
	@param element The UI element
	@param hoverTransparency Transparency when hovered
	@param normalTransparency Transparency when not hovered
]]
function Helper.HoverTransparency(element: GuiObject, hoverTransparency: number?, normalTransparency: number?)
	normalTransparency = normalTransparency or element.BackgroundTransparency
	hoverTransparency = hoverTransparency or math.max(normalTransparency - 0.2, 0)

	element.MouseEnter:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundTransparency = hoverTransparency,
		}):Play()
	end)

	element.MouseLeave:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundTransparency = normalTransparency,
		}):Play()
	end)
end

--[[
	Truncate text to a maximum length
	@param text The text to truncate
	@param maxLength Maximum length before truncation
	@return Truncated text with "..." if needed
]]
function Helper.Truncate(text: string, maxLength: number): string
	if #text <= maxLength then
		return text
	end
	return string.sub(text, 1, maxLength - 3) .. "..."
end

--[[
	Format a large number to a readable string (e.g., 1.5K, 2.3M)
	@param num The number to format
	@return Formatted string
]]
function Helper.FormatNumber(num: number): string
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	end
	return tostring(num)
end

--[[
	Format seconds to HH:MM:SS timestamp
	@param timestamp Time in seconds
	@return Formatted timestamp string
]]
function Helper.FormatTimestamp(timestamp: number): string
	local seconds = math.floor(timestamp) % 60
	local minutes = math.floor(timestamp / 60) % 60
	local hours = math.floor(timestamp / 3600) % 24
	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

--[[
	Create a debounced version of a function
	@param func The function to debounce
	@param wait Wait time in seconds
	@return Debounced function
]]
function Helper.Debounce(func: (...any) -> (), wait: number): (...any) -> ()
	local lastCall = 0
	return function(...)
		local now = tick()
		if now - lastCall >= wait then
			lastCall = now
			func(...)
		end
	end
end

--[[
	Tween a UI element with default settings
	@param element The UI element to tween
	@param properties Properties to tween to
	@param duration Optional duration (default: 0.2)
	@return The Tween object
]]
function Helper.Tween(element: Instance, properties: { [string]: any }, duration: number?): Tween
	local tween = TweenService:Create(
		element,
		TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		properties
	)
	tween:Play()
	return tween
end

return Helper

end)() end,
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)--[[
	Drag Module - Template
	Enables drag functionality on UI frames.
	Supports UIScale by dividing delta by a scale factor.
	
	Usage:
		local Drag = require(path.to.Drag)
		
		-- Basic usage
		Drag.new(mainFrame, titleBar)
		
		-- With DPI/UIScale support
		Drag.new(mainFrame, titleBar, function()
			return uiScale.Scale
		end)
]]

local Drag = {}
Drag.__index = Drag

local UserInputService = game:GetService("UserInputService")

export type DragObject = {
	Frame: Frame,
	Handle: Frame,
	Enabled: boolean,
	SetEnabled: (self: DragObject, enabled: boolean) -> (),
	Destroy: (self: DragObject) -> (),
}

--[[
	Create a new draggable frame
	@param frame The main frame to move
	@param handle The frame to use as drag handle (defaults to frame itself)
	@param getScale Optional function returning the current UI scale
	@return DragObject
]]
function Drag.new(frame: Frame, handle: Frame?, getScale: (() -> number)?): DragObject
	handle = handle or frame
	getScale = getScale or function() return 1 end

	local self = setmetatable({}, Drag)
	self.Frame = frame
	self.Handle = handle
	self.Enabled = true

	local dragging = false
	local dragStart = nil
	local startPos = nil
	local connections = {}

	table.insert(connections, handle.InputBegan:Connect(function(input)
		if not self.Enabled then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not self.Enabled then return end
		
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local scale = getScale()
			local delta = input.Position - dragStart
			local newPosition = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X / scale,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y / scale
			)
			frame.Position = newPosition
		end
	end))

	function self:SetEnabled(enabled: boolean)
		self.Enabled = enabled
		if not enabled then
			dragging = false
		end
	end

	function self:Destroy()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		connections = {}
	end

	return self
end

return Drag

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
                },
                {
                    {
                        3,
                        1,
                        {
                            "UI"
                        },
                        {
                            {
                                4,
                                2,
                                {
                                    "Drag"
                                }
                            },
                            {
                                10,
                                2,
                                {
                                    "Theme"
                                }
                            },
                            {
                                6,
                                2,
                                {
                                    "Icons"
                                }
                            },
                            {
                                9,
                                2,
                                {
                                    "Sonner"
                                }
                            },
                            {
                                8,
                                2,
                                {
                                    "Resize"
                                }
                            },
                            {
                                7,
                                2,
                                {
                                    "Interface"
                                }
                            },
                            {
                                5,
                                2,
                                {
                                    "Helper"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    [10] = 2012,
    [2] = 113,
    [7] = 2071,
    [6] = 8,
    [8] = 2275,
    [9] = 2414,
    [5] = 2642,
    [4] = 2824
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
