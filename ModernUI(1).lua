local ModernUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function MakeDraggable(topbar, target)
	dragging = false
	dragInput = nil
	dragStart = nil
	startPos = nil
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function Create(instanceType, properties)
	local instance = Instance.new(instanceType)
	for prop, value in pairs(properties or {}) do
		instance[prop] = value
	end
	return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection, delay)
	TweenService:Create(instance, TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out, 0, false, delay or 0), properties):Play()
end

local function Corner(parent, radius)
	return Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 8)})
end

local function Stroke(parent, color, thickness)
	return Create("UIStroke", {Parent = parent, Color = color or Color3.fromRGB(60, 60, 60), Thickness = thickness or 1, Transparency = 0.5})
end

local function Padding(parent, top, bottom, left, right)
	return Create("UIPadding", {Parent = parent, PaddingTop = UDim.new(0, top or 0), PaddingBottom = UDim.new(0, bottom or 0), PaddingLeft = UDim.new(0, left or 0), PaddingRight = UDim.new(0, right or 0)})
end

local function Gradient(parent, colorSequence, rotation, offset)
	local grad = Create("UIGradient", {Parent = parent, Rotation = rotation or 0, Offset = offset or Vector2.new(0, 0)})
	if colorSequence then grad.Color = colorSequence end
	return grad
end

local function Shadow(parent, size, transparency)
	local sh = Create("ImageLabel", {Parent = parent, Name = "Shadow", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 3), Size = UDim2.new(1, size or 24, 1, size or 24), ZIndex = -1, Image = "rbxassetid://5554236805", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = transparency or 0.6, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(23, 23, 277, 277)})
	return sh
end

local function Ripple(parent, x, y)
	local ripple = Create("Frame", {Parent = parent, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, x, 0, y), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8, ZIndex = parent.ZIndex + 1, BorderSizePixel = 0})
	Corner(ripple, 999)
	local targetSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
	Tween(ripple, {Size = UDim2.new(0, targetSize, 0, targetSize), BackgroundTransparency = 1}, 0.6)
	task.delay(0.6, function() ripple:Destroy() end)
end

local Icons = {
	home = "rbxassetid://7733960981",
	settings = "rbxassetid://7734053495",
	search = "rbxassetid://7734057828",
	user = "rbxassetid://7733920763",
	star = "rbxassetid://7734043302",
	moon = "rbxassetid://7733993311",
	sun = "rbxassetid://7734184195",
	code = "rbxassetid://7733749837",
	game = "rbxassetid://7733777166",
	edit = "rbxassetid://7733752637",
	trash = "rbxassetid://7734044907",
	copy = "rbxassetid://7733764083",
	check = "rbxassetid://7733715400",
	close = "rbxassetid://7733717447",
	add = "rbxassetid://7733701625",
	menu = "rbxassetid://7733992424",
	info = "rbxassetid://7733956085",
	warn = "rbxassetid://7734111114",
}

function ModernUI:MakeWindow(config)
	config = config or {}
	local windowName = config.Name or "ModernUI"
	local subTitle = config.SubTitle or ""

	local gui = Create("ScreenGui", {Name = HttpService:GenerateGUID(false), Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false})

	local mainFrame = Create("Frame", {Parent = gui, Name = "Main", Size = UDim2.new(0, 640, 0, 420), Position = UDim2.new(0.5, -320, 0.5, -210), BackgroundColor3 = Color3.fromRGB(13, 13, 18), BorderSizePixel = 0, ClipsDescendants = true})
	Corner(mainFrame, 16)
	Shadow(mainFrame, 32, 0.75)

	local topbar = Create("Frame", {Parent = mainFrame, Name = "Topbar", Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(18, 18, 25), BorderSizePixel = 0})
	Corner(topbar, 16)

	local topbarFix = Create("Frame", {Parent = topbar, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16), BackgroundColor3 = topbar.BackgroundColor3, BorderSizePixel = 0, ZIndex = 0})

	local titleLabel = Create("TextLabel", {Parent = topbar, Name = "Title", Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(0, 56, 0, 0), BackgroundTransparency = 1, Text = windowName, TextColor3 = Color3.fromRGB(240, 240, 255), TextSize = 16, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left})

	if subTitle ~= "" then
		titleLabel.Text = windowName
		titleLabel.Size = UDim2.new(0, 300, 0, 28)
		titleLabel.Position = UDim2.new(0, 56, 0, 2)
		local subLabel = Create("TextLabel", {Parent = topbar, Name = "SubTitle", Size = UDim2.new(0, 300, 0, 18), Position = UDim2.new(0, 56, 0, 28), BackgroundTransparency = 1, Text = subTitle, TextColor3 = Color3.fromRGB(130, 130, 150), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
	end

	local logo = Create("ImageLabel", {Parent = topbar, Name = "Logo", Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 16, 0, 10), BackgroundColor3 = Color3.fromRGB(35, 35, 55), BorderSizePixel = 0, Image = Icons.star, ImageColor3 = Color3.fromRGB(160, 130, 255)})
	Corner(logo, 8)

	local logoGrad = Gradient(logo, ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))}), 135)

	local closeBtn = Create("TextButton", {Parent = topbar, Name = "Close", Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -40, 0, 8), BackgroundColor3 = Color3.fromRGB(30, 30, 40), Text = "", BorderSizePixel = 0})
	Corner(closeBtn, 8)
	local closeIcon = Create("ImageLabel", {Parent = closeBtn, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7), BackgroundTransparency = 1, Image = Icons.close, ImageColor3 = Color3.fromRGB(180, 180, 200)})
	Stroke(closeBtn, Color3.fromRGB(60, 60, 80), 1)

	closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 60)}, 0.2) closeIcon.ImageColor3 = Color3.new(1, 1, 1) end)
	closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, 0.2) closeIcon.ImageColor3 = Color3.fromRGB(180, 180, 200) end)
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

	local minimizeBtn = Create("TextButton", {Parent = topbar, Name = "Minimize", Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -78, 0, 8), BackgroundColor3 = Color3.fromRGB(30, 30, 40), Text = "", BorderSizePixel = 0})
	Corner(minimizeBtn, 8)
	local minIcon = Create("ImageLabel", {Parent = minimizeBtn, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7), BackgroundTransparency = 1, Image = Icons.menu, ImageColor3 = Color3.fromRGB(180, 180, 200)})
	Stroke(minimizeBtn, Color3.fromRGB(60, 60, 80), 1)

	local minimized = false
	minimizeBtn.MouseEnter:Connect(function() Tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}, 0.2) end)
	minimizeBtn.MouseLeave:Connect(function() Tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, 0.2) end)
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			Tween(mainFrame, {Size = UDim2.new(0, 640, 0, 48)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			Tween(contentContainer, {ImageTransparency = 1}, 0.2)
			tabBar.Visible = false
			contentContainer.Visible = false
		else
			Tween(mainFrame, {Size = UDim2.new(0, 640, 0, 420)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			contentContainer.Visible = true
			tabBar.Visible = true
		end
	end)

	local tabBar = Create("Frame", {Parent = mainFrame, Name = "TabBar", Size = UDim2.new(0, 150, 1, -48), Position = UDim2.new(0, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(16, 16, 22), BorderSizePixel = 0})
	Padding(tabBar, 8, 8, 8, 8)

	local tabList = Create("ScrollingFrame", {Parent = tabBar, Name = "TabList", Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(80, 80, 110), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y})
	local tabListLayout = Create("UIListLayout", {Parent = tabList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})

	local creditLabel = Create("TextLabel", {Parent = tabBar, Name = "Credit", Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0, 4, 1, -26), BackgroundTransparency = 1, Text = "YG Script", TextColor3 = Color3.fromRGB(70, 70, 90), TextSize = 11, Font = Enum.Font.GothamMedium})

	local contentContainer = Create("Frame", {Parent = mainFrame, Name = "Content", Size = UDim2.new(1, -150, 1, -48), Position = UDim2.new(0, 150, 0, 48), BackgroundColor3 = Color3.fromRGB(13, 13, 18), BorderSizePixel = 0, ClipsDescendants = true})

	local contentAccent = Create("Frame", {Parent = contentContainer, Name = "AccentLine", Size = UDim2.new(0, 3, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(140, 100, 255), BorderSizePixel = 0})
	Gradient(contentAccent, ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 150, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 100, 255))}), 90)

	local pagesFolder = Instance.new("Folder")
	pagesFolder.Name = "Pages"
	pagesFolder.Parent = contentContainer

	local tabButtons = {}
	local tabs = {}
	local activeTab = nil

	MakeDraggable(topbar, mainFrame)

	function ModernUI:SelectTab(tabObj)
		if activeTab == tabObj then return end
		if activeTab then
			Tween(activeTab.Button.Frame.Indicator, {BackgroundTransparency = 1, Size = UDim2.new(0, 4, 0, 0)}, 0.25)
			Tween(activeTab.Button, {BackgroundColor3 = Color3.fromRGB(16, 16, 22)}, 0.25)
			Tween(activeTab.Button.Title, {TextColor3 = Color3.fromRGB(150, 150, 170)}, 0.25)
			Tween(activeTab.Button.Icon, {ImageColor3 = Color3.fromRGB(120, 120, 140)}, 0.25)
			Tween(activeTab.Page, {Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0)}, 0.2)
			Tween(activeTab.Page, {BackgroundTransparency = 1}, 0.2)
			for _, child in ipairs(activeTab.Page:GetDescendants()) do
				if child:IsA("GuiObject") and child.Name ~= "SectionTitle" then
					Tween(child, {BackgroundTransparency = child.BackgroundTransparency < 0.5 and 1 or child.BackgroundTransparency, TextTransparency = child:IsA("TextLabel") and 1 or child.TextTransparency or 0}, 0.15)
				end
			end
			task.delay(0.2, function()
				if activeTab ~= tabObj then
					activeTab.Page.Visible = false
				end
			end)
		end
		activeTab = tabObj
		activeTab.Page.Visible = true
		Tween(activeTab.Button, {BackgroundColor3 = Color3.fromRGB(35, 30, 55)}, 0.3)
		Tween(activeTab.Button.Title, {TextColor3 = Color3.fromRGB(220, 210, 255)}, 0.3)
		Tween(activeTab.Button.Icon, {ImageColor3 = Color3.fromRGB(160, 130, 255)}, 0.3)
		Tween(activeTab.Button.Frame.Indicator, {BackgroundTransparency = 0, Size = UDim2.new(0, 4, 0, 24)}, 0.3)
		Tween(activeTab.Page, {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		Tween(activeTab.Page, {BackgroundTransparency = 1}, 0.35)
		for _, child in ipairs(activeTab.Page:GetDescendants()) do
			if child:IsA("GuiObject") and child.Name ~= "SectionTitle" then
				if child:IsA("TextLabel") or child:IsA("TextBox") then
					Tween(child, {TextTransparency = 0}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0.05)
				elseif child:IsA("ImageLabel") then
					Tween(child, {ImageTransparency = 0}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0.05)
				end
			end
		end
	end

	function ModernUI:MakeTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabTitle = tabConfig.Title or "Tab"
		local tabIcon = tabConfig.Icon or ""
		if Icons[tabIcon:lower()] then tabIcon = Icons[tabIcon:lower()] elseif tabIcon == "" then tabIcon = Icons.star end

		local tabBtn = Create("TextButton", {Parent = tabList, Name = tabTitle, Size = UDim2.new(1, -4, 0, 38), BackgroundColor3 = Color3.fromRGB(16, 16, 22), Text = "", BorderSizePixel = 0, AutoButtonColor = false})
		Corner(tabBtn, 10)

		local tabBtnFrame = Create("Frame", {Parent = tabBtn, Name = "Frame", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true})
		Corner(tabBtnFrame, 10)

		local indicator = Create("Frame", {Parent = tabBtnFrame, Name = "Indicator", Size = UDim2.new(0, 4, 0, 0), Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(160, 130, 255), BorderSizePixel = 0, BackgroundTransparency = 1})
		Corner(indicator, 4)
		Gradient(indicator, ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))}), 90)

		local icon = Create("ImageLabel", {Parent = tabBtn, Name = "Icon", Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 16, 0, 10), BackgroundTransparency = 1, Image = tabIcon, ImageColor3 = Color3.fromRGB(120, 120, 140)})
		local title = Create("TextLabel", {Parent = tabBtn, Name = "Title", Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 40, 0, 0), BackgroundTransparency = 1, Text = tabTitle, TextColor3 = Color3.fromRGB(150, 150, 170), TextSize = 13, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left})

		local page = Create("ScrollingFrame", {Parent = pagesFolder, Name = tabTitle .. "Page", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, ClipsDescendants = true})
		local pageLayout = Create("UIListLayout", {Parent = page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center})
		Create("UIPadding", {Parent = page, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})

		local tabObj = {Button = tabBtn, Page = page, Title = tabTitle}
		table.insert(tabButtons, tabBtn)
		table.insert(tabs, tabObj)

		pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 24)
		end)

		tabBtn.MouseEnter:Connect(function()
			if activeTab ~= tabObj then
				Tween(tabBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}, 0.2)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if activeTab ~= tabObj then
				Tween(tabBtn, {BackgroundColor3 = Color3.fromRGB(16, 16, 22)}, 0.2)
			end
		end)
		tabBtn.MouseButton1Click:Connect(function()
			ModernUI:SelectTab(tabObj)
		end)

		if #tabs == 1 then
			task.spawn(function() ModernUI:SelectTab(tabObj) end)
		end

		local TabAPI = {}

		function TabAPI:AddSection(sectionName)
			sectionName = sectionName or "Section"
			local section = Create("Frame", {Parent = page, Name = "Section", Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = #page:GetChildren()})
			local title = Create("TextLabel", {Parent = section, Name = "SectionTitle", Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = sectionName, TextColor3 = Color3.fromRGB(200, 195, 255), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left})
			local underline = Create("Frame", {Parent = section, Name = "Underline", Size = UDim2.new(0.3, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = Color3.fromRGB(140, 100, 255), BorderSizePixel = 0})
			Corner(underline, 2)
			Gradient(underline, ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))}), 0)
			return section
		end

		function TabAPI:AddButton(btnConfig)
			btnConfig = btnConfig or {}
			local btnName = btnConfig.Name or "Button"
			local btnDesc = btnConfig.Description or ""
			local btnCallback = btnConfig.Callback or function() end

			local container = Create("Frame", {Parent = page, Name = btnName, Size = UDim2.new(1, 0, 0, btnDesc ~= "" and 56 or 42), BackgroundColor3 = Color3.fromRGB(22, 22, 30), BorderSizePixel = 0, LayoutOrder = #page:GetChildren()})
			Corner(container, 12)
			Stroke(container, Color3.fromRGB(40, 40, 55), 1)
			Padding(container, 0, 0, 14, 14)

			local title = Create("TextLabel", {Parent = container, Name = "Title", Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 0, 0, btnDesc ~= "" and 6 or 11), BackgroundTransparency = 1, Text = btnName, TextColor3 = Color3.fromRGB(210, 210, 230), TextSize = 13, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left})

			if btnDesc ~= "" then
				local desc = Create("TextLabel", {Parent = container, Name = "Desc", Size = UDim2.new(1, -80, 0, 18), Position = UDim2.new(0, 0, 0, 28), BackgroundTransparency = 1, Text = btnDesc, TextColor3 = Color3.fromRGB(110, 110, 130), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
			end

			local btn = Create("TextButton", {Parent = container, Name = "ClickArea", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "", BorderSizePixel = 0, ZIndex = 2})

			local actionBtn = Create("Frame", {Parent = container, Name = "ActionBtn", Size = UDim2.new(0, 64, 0, 28), Position = UDim2.new(1, -74, 0.5, -14), BackgroundColor3 = Color3.fromRGB(140, 100, 255), BorderSizePixel = 0})
			Corner(actionBtn, 8)
			Gradient(actionBtn, ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))}), 135)
			local actionLabel = Create("TextLabel", {Parent = actionBtn, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "点击", TextColor3 = Color3.new(1, 1, 1), TextSize = 12, Font = Enum.Font.GothamBold})

			btn.MouseEnter:Connect(function() Tween(container, {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}, 0.2) end)
			btn.MouseLeave:Connect(function() Tween(container, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.2) end)
			btn.MouseButton1Click:Connect(function(x, y)
				local absPos = container.AbsolutePosition
				local relX = Mouse.X - absPos.X
				local relY = Mouse.Y - absPos.Y
				Ripple(container, relX, relY)
				Tween(actionBtn, {Size = UDim2.new(0, 58, 0, 24), Position = UDim2.new(1, -71, 0.5, -12)}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				task.delay(0.1, function() Tween(actionBtn, {Size = UDim2.new(0, 64, 0, 28), Position = UDim2.new(1, -74, 0.5, -14)}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end)
				btnCallback()
			end)

			return container
		end

		function TabAPI:AddToggle(tglConfig)
			tglConfig = tglConfig or {}
			local tglName = tglConfig.Name or "Toggle"
			local tglDesc = tglConfig.Description or ""
			local tglDefault = tglConfig.Default or false
			local tglCallback = tglConfig.Callback or function() end

			local container = Create("Frame", {Parent = page, Name = tglName, Size = UDim2.new(1, 0, 0, tglDesc ~= "" and 56 or 42), BackgroundColor3 = Color3.fromRGB(22, 22, 30), BorderSizePixel = 0, LayoutOrder = #page:GetChildren()})
			Corner(container, 12)
			Stroke(container, Color3.fromRGB(40, 40, 55), 1)
			Padding(container, 0, 0, 14, 14)

			local title = Create("TextLabel", {Parent = container, Name = "Title", Size = UDim2.new(1, -70, 0, 20), Position = UDim2.new(0, 0, 0, tglDesc ~= "" and 6 or 11), BackgroundTransparency = 1, Text = tglName, TextColor3 = Color3.fromRGB(210, 210, 230), TextSize = 13, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left})

			if tglDesc ~= "" then
				local desc = Create("TextLabel", {Parent = container, Name = "Desc", Size = UDim2.new(1, -70, 0, 18), Position = UDim2.new(0, 0, 0, 28), BackgroundTransparency = 1, Text = tglDesc, TextColor3 = Color3.fromRGB(110, 110, 130), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
			end

			local toggleBtn = Create("TextButton", {Parent = container, Name = "ToggleBtn", Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -56, 0.5, -12), BackgroundColor3 = Color3.fromRGB(45, 45, 60), Text = "", BorderSizePixel = 0, AutoButtonColor = false})
			Corner(toggleBtn, 12)
			Stroke(toggleBtn, Color3.fromRGB(55, 55, 75), 1)

			local knob = Create("Frame", {Parent = toggleBtn, Name = "Knob", Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(120, 120, 140), BorderSizePixel = 0})
			Corner(knob, 9)
			Shadow(knob, 6, 0.8)

			local enabled = tglDefault
			local function UpdateToggle()
				if enabled then
					Tween(toggleBtn, {BackgroundColor3 = Color3.fromRGB(100, 70, 200)}, 0.25)
					Tween(knob, {Position = UDim2.new(0, 25, 0.5, -9), BackgroundColor3 = Color3.new(1, 1, 1)}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					Stroke(toggleBtn, Color3.fromRGB(130, 100, 230), 1)
				else
					Tween(toggleBtn, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.25)
					Tween(knob, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(120, 120, 140)}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					Stroke(toggleBtn, Color3.fromRGB(55, 55, 75), 1)
				end
				tglCallback(enabled)
			end

			if enabled then UpdateToggle() end

			toggleBtn.MouseEnter:Connect(function() Tween(container, {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}, 0.2) end)
			toggleBtn.MouseLeave:Connect(function() Tween(container, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.2) end)
			toggleBtn.MouseButton1Click:Connect(function()
				enabled = not enabled
				UpdateToggle()
			end)

			return {Instance = container, Set = function(v) enabled = v UpdateToggle() end, Get = function() return enabled end}
		end

		function TabAPI:AddSlider(sldConfig)
			sldConfig = sldConfig or {}
			local sldName = sldConfig.Name or "Slider"
			local sldDesc = sldConfig.Description or ""
			local sldMin = sldConfig.MinValue or 0
			local sldMax = sldConfig.MaxValue or 100
			local sldDefault = sldConfig.Default or sldMin
			local sldCallback = sldConfig.Callback or function() end
			sldDefault = math.clamp(sldDefault, sldMin, sldMax)

			local container = Create("Frame", {Parent = page, Name = sldName, Size = UDim2.new(1, 0, 0, sldDesc ~= "" and 72 or 58), BackgroundColor3 = Color3.fromRGB(22, 22, 30), BorderSizePixel = 0, LayoutOrder = #page:GetChildren()})
			Corner(container, 12)
			Stroke(container, Color3.fromRGB(40, 40, 55), 1)
			Padding(container, 0, 0, 14, 14)

			local title = Create("TextLabel", {Parent = container, Name = "Title", Size = UDim2.new(0.6, 0, 0, 20), Position = UDim2.new(0, 0, 0, sldDesc ~= "" and 6 or 8), BackgroundTransparency = 1, Text = sldName, TextColor3 = Color3.fromRGB(210, 210, 230), TextSize = 13, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left})

			if sldDesc ~= "" then
				local desc = Create("TextLabel", {Parent = container, Name = "Desc", Size = UDim2.new(0.6, 0, 0, 18), Position = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1, Text = sldDesc, TextColor3 = Color3.fromRGB(110, 110, 130), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
			end

			local valueLabel = Create("TextLabel", {Parent = container, Name = "Value", Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -60, 0, sldDesc ~= "" and 4 or 6), BackgroundColor3 = Color3.fromRGB(30, 30, 42), Text = tostring(sldDefault), TextColor3 = Color3.fromRGB(180, 170, 255), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center})
			Corner(valueLabel, 6)
			Stroke(valueLabel, Color3.fromRGB(50, 50, 70), 1)

			local track = Create("Frame", {Parent = container, Name = "Track", Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 1, -18), BackgroundColor3 = Color3.fromRGB(35, 35, 50), BorderSizePixel = 0})
			Corner(track, 3)

			local fill = Create("Frame", {Parent = track, Name = "Fill", Size = UDim2.new((sldDefault - sldMin) / (sldMax - sldMin), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(140, 100, 255), BorderSizePixel = 0})
			Corner(fill, 3)
			Gradient(fill, ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))}), 0)

			local knob = Create("Frame", {Parent = track, Name = "Knob", Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((sldDefault - sldMin) / (sldMax - sldMin), -7, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2})
			Corner(knob, 7)
			Shadow(knob, 8, 0.7)

			local dragging = false
			local function SetValue(v)
				local val = math.clamp(v, sldMin, sldMax)
				local scale = (val - sldMin) / (sldMax - sldMin)
				Tween(fill, {Size = UDim2.new(scale, 0, 1, 0)}, 0.1)
				Tween(knob, {Position = UDim2.new(scale, -7, 0.5, -7)}, 0.1)
				valueLabel.Text = string.format("%.0f", val)
				sldCallback(val)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					local relX = input.Position.X - track.AbsolutePosition.X
					local scale = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
					SetValue(sldMin + scale * (sldMax - sldMin))
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local relX = input.Position.X - track.AbsolutePosition.X
					local scale = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
					SetValue(sldMin + scale * (sldMax - sldMin))
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			return {Instance = container, Set = SetValue, Get = function() return tonumber(valueLabel.Text) end}
		end

		function TabAPI:AddDropdown(ddConfig)
			ddConfig = ddConfig or {}
			local ddName = ddConfig.Name or "Dropdown"
			local ddDesc = ddConfig.Description or ""
			local ddOptions = ddConfig.Options or {}
			local ddDefault = ddConfig.Default or (ddOptions[1] or "")
			local ddCallback = ddConfig.Callback or function() end

			local container = Create("Frame", {Parent = page, Name = ddName, Size = UDim2.new(1, 0, 0, ddDesc ~= "" and 66 or 52), BackgroundColor3 = Color3.fromRGB(22, 22, 30), BorderSizePixel = 0, LayoutOrder = #page:GetChildren(), ClipsDescendants = false})
			Corner(container, 12)
			Stroke(container, Color3.fromRGB(40, 40, 55), 1)
			Padding(container, 0, 0, 14, 14)

			local title = Create("TextLabel", {Parent = container, Name = "Title", Size = UDim2.new(0.5, 0, 0, 20), Position = UDim2.new(0, 0, 0, ddDesc ~= "" and 6 or 10), BackgroundTransparency = 1, Text = ddName, TextColor3 = Color3.fromRGB(210, 210, 230), TextSize = 13, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left})

			if ddDesc ~= "" then
				local desc = Create("TextLabel", {Parent = container, Name = "Desc", Size = UDim2.new(0.5, 0, 0, 18), Position = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1, Text = ddDesc, TextColor3 = Color3.fromRGB(110, 110, 130), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
			end

			local ddBtn = Create("TextButton", {Parent = container, Name = "DropdownBtn", Size = UDim2.new(0, 160, 0, 30), Position = UDim2.new(1, -170, 0.5, -15), BackgroundColor3 = Color3.fromRGB(30, 30, 42), Text = "", BorderSizePixel = 0})
			Corner(ddBtn, 8)
			Stroke(ddBtn, Color3.fromRGB(50, 50, 70), 1)
			Padding(ddBtn, 0, 0, 10, 32)

			local selectedLabel = Create("TextLabel", {Parent = ddBtn, Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = ddDefault, TextColor3 = Color3.fromRGB(200, 190, 255), TextSize = 12, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
			local arrow = Create("ImageLabel", {Parent = ddBtn, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7), BackgroundTransparency = 1, Image = "rbxassetid://7733717759", ImageColor3 = Color3.fromRGB(140, 140, 160)})

			local dropFrame = Create("Frame", {Parent = container, Name = "DropdownMenu", Size = UDim2.new(0, 160, 0, 0), Position = UDim2.new(1, -170, 0, ddDesc ~= "" and 64 or 50), BackgroundColor3 = Color3.fromRGB(28, 28, 40), BorderSizePixel = 0, Visible = false, ClipsDescendants = true, ZIndex = 50})
			Corner(dropFrame, 10)
			Stroke(dropFrame, Color3.fromRGB(55, 55, 80), 1)
			Shadow(dropFrame, 16, 0.6)

			local dropList = Create("ScrollingFrame", {Parent = dropFrame, Name = "List", Size = UDim2.new(1, 0, 1, -8), Position = UDim2.new(0, 0, 0, 4), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 51})
			Create("UIListLayout", {Parent = dropList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
			Padding(dropList, 0, 0, 4, 4)

			local isOpen = false
			for _, opt in ipairs(ddOptions) do
				local optBtn = Create("TextButton", {Parent = dropList, Name = opt, Size = UDim2.new(1, -8, 0, 28), BackgroundColor3 = Color3.fromRGB(28, 28, 40), Text = "", BorderSizePixel = 0, LayoutOrder = #dropList:GetChildren(), ZIndex = 52})
				Corner(optBtn, 6)
				local optLabel = Create("TextLabel", {Parent = optBtn, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, Text = opt, TextColor3 = Color3.fromRGB(180, 180, 200), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 53})

				optBtn.MouseEnter:Connect(function()
					Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(45, 40, 70)}, 0.15)
					optLabel.TextColor3 = Color3.fromRGB(220, 210, 255)
				end)
				optBtn.MouseLeave:Connect(function()
					Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}, 0.15)
					optLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
				end)
				optBtn.MouseButton1Click:Connect(function()
					selectedLabel.Text = opt
					isOpen = false
					Tween(dropFrame, {Size = UDim2.new(0, 160, 0, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
					Tween(arrow, {Rotation = 0}, 0.2)
					task.delay(0.2, function() dropFrame.Visible = false end)
					ddCallback(opt)
				end)
			end

			ddBtn.MouseEnter:Connect(function() Tween(container, {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}, 0.2) end)
			ddBtn.MouseLeave:Connect(function() Tween(container, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.2) end)
			ddBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				if isOpen then
					dropFrame.Visible = true
					local count = math.min(#ddOptions, 6)
					Tween(dropFrame, {Size = UDim2.new(0, 160, 0, count * 30 + 8)}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					Tween(arrow, {Rotation = 180}, 0.2)
				else
					Tween(dropFrame, {Size = UDim2.new(0, 160, 0, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
					Tween(arrow, {Rotation = 0}, 0.2)
					task.delay(0.2, function() dropFrame.Visible = false end)
				end
			end)

			return {Instance = container, Set = function(v) selectedLabel.Text = v ddCallback(v) end, Get = function() return selectedLabel.Text end}
		end

		function TabAPI:AddTextBox(tbConfig)
			tbConfig = tbConfig or {}
			local tbName = tbConfig.Name or "TextBox"
			local tbDesc = tbConfig.Description or ""
			local tbPlaceholder = tbConfig.PlaceholderText or "..."
			local tbCallback = tbConfig.Callback or function() end

			local container = Create("Frame", {Parent = page, Name = tbName, Size = UDim2.new(1, 0, 0, tbDesc ~= "" and 74 or 60), BackgroundColor3 = Color3.fromRGB(22, 22, 30), BorderSizePixel = 0, LayoutOrder = #page:GetChildren()})
			Corner(container, 12)
			Stroke(container, Color3.fromRGB(40, 40, 55), 1)
			Padding(container, 0, 0, 14, 14)

			local title = Create("TextLabel", {Parent = container, Name = "Title", Size = UDim2.new(0.5, 0, 0, 20), Position = UDim2.new(0, 0, 0, tbDesc ~= "" and 6 or 8), BackgroundTransparency = 1, Text = tbName, TextColor3 = Color3.fromRGB(210, 210, 230), TextSize = 13, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left})

			if tbDesc ~= "" then
				local desc = Create("TextLabel", {Parent = container, Name = "Desc", Size = UDim2.new(0.5, 0, 0, 18), Position = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1, Text = tbDesc, TextColor3 = Color3.fromRGB(110, 110, 130), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left})
			end

			local inputFrame = Create("Frame", {Parent = container, Name = "Input", Size = UDim2.new(0.5, -6, 0, 30), Position = UDim2.new(0.5, 0, 0.5, -15), BackgroundColor3 = Color3.fromRGB(18, 18, 26), BorderSizePixel = 0})
			Corner(inputFrame, 8)
			Stroke(inputFrame, Color3.fromRGB(45, 45, 65), 1)
			Padding(inputFrame, 0, 0, 10, 10)

			local textBox = Create("TextBox", {Parent = inputFrame, Name = "TextBox", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = tbPlaceholder, PlaceholderColor3 = Color3.fromRGB(80, 80, 100), TextColor3 = Color3.fromRGB(210, 205, 255), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})

			textBox.Focused:Connect(function()
				Tween(inputFrame, {BackgroundColor3 = Color3.fromRGB(25, 22, 40)}, 0.2)
				Tween(inputFrame:FindFirstChildOfClass("UIStroke"), {Color = Color3.fromRGB(120, 90, 220)}, 0.2)
			end)
			textBox.FocusLost:Connect(function()
				Tween(inputFrame, {BackgroundColor3 = Color3.fromRGB(18, 18, 26)}, 0.2)
				Tween(inputFrame:FindFirstChildOfClass("UIStroke"), {Color = Color3.fromRGB(45, 45, 65)}, 0.2)
				if textBox.Text ~= "" then
					tbCallback(textBox.Text)
				end
			end)

			return {Instance = container, Set = function(v) textBox.Text = v end, Get = function() return textBox.Text end}
		end

		return TabAPI
	end

	return ModernUI
end

return ModernUI
