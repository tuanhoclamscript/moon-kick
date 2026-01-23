local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Theme = {
	Background = Color3.fromRGB(25, 25, 35),
	CardBackground = Color3.fromRGB(35, 35, 45),
	TextTitle = Color3.fromRGB(180, 180, 180),
	TextValueNormal = Color3.fromRGB(255, 255, 255),
	AccentGood = Color3.fromRGB(0, 255, 128), -- Xanh lá neon
	AccentWarning = Color3.fromRGB(255, 180, 50), -- Cam neon
	AccentDanger = Color3.fromRGB(255, 50, 80),   -- Đỏ neon
	AccentInfo = Color3.fromRGB(50, 150, 255),    -- Xanh dương neon
}

local Icons = {
	Moon = "rbxassetid://6031247509", -- Icon mặt trăng khuyết
	Gear = "rbxassetid://3926307971", -- Icon bánh răng
	Time = "rbxassetid://3926305904", -- Icon đồng hồ
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonGearMonitorV3"
if pcall(function() return CoreGui:FindFirstChild("RobloxGui") end) then
	ScreenGui.Parent = CoreGui
else
	ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- 1. Khung Chính (Main Container)
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 280, 0, 220) -- Kích thước vừa đủ
MainContainer.Position = UDim2.new(0.02, 0, 0.65, 0)
MainContainer.BackgroundColor3 = Theme.Background
MainContainer.BorderSizePixel = 0
MainContainer.Parent = ScreenGui

-- Bo góc mềm mại
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainContainer

-- Hiệu ứng viền sáng Neon (Glow Stroke)
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 3
MainStroke.Color = Theme.AccentInfo
MainStroke.Transparency = 0.3
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainContainer

-- Padding bên trong để nội dung không dính sát viền
local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingTop = UDim.new(0, 15)
MainPadding.PaddingBottom = UDim.new(0, 15)
MainPadding.PaddingLeft = UDim.new(0, 15)
MainPadding.PaddingRight = UDim.new(0, 15)
MainPadding.Parent = MainContainer

-- Layout tự động sắp xếp các dòng
local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10) -- Khoảng cách giữa các dòng
ListLayout.Parent = MainContainer

-- 2. Tiêu đề (Header)
local Header = Instance.new("TextLabel")
Header.Name = "HeaderTitle"
Header.Text = "FM Kick - Gear Checking (Btuan)"
Header.Size = UDim2.new(1, 0, 0, 20)
Header.BackgroundTransparency = 1
Header.TextColor3 = Theme.AccentInfo
Header.Font = Enum.Font.GothamBlack
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.LayoutOrder = 0
Header.Parent = MainContainer

-- Hàm hỗ trợ tạo dòng thông tin (Data Row Helper)
local function createDataRow(order, iconId, titleText)
	local RowFrame = Instance.new("Frame")
	RowFrame.Name = titleText .. "Row"
	RowFrame.Size = UDim2.new(1, 0, 0, 45)
	RowFrame.BackgroundColor3 = Theme.CardBackground
	RowFrame.LayoutOrder = order
	RowFrame.Parent = MainContainer

	local RowCorner = Instance.new("UICorner")
	RowCorner.CornerRadius = UDim.new(0, 10)
	RowCorner.Parent = RowFrame

	-- Icon
	local IconImage = Instance.new("ImageLabel")
	IconImage.Image = iconId
	IconImage.Size = UDim2.new(0, 24, 0, 24)
	IconImage.Position = UDim2.new(0, 10, 0.5, -12)
	IconImage.BackgroundTransparency = 1
	IconImage.ImageColor3 = Theme.TextTitle
	IconImage.Parent = RowFrame

	-- Title Label (Nhãn nhỏ)
	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Text = titleText:upper()
	TitleLbl.Size = UDim2.new(1, -50, 0, 15)
	TitleLbl.Position = UDim2.new(0, 45, 0, 5)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.TextColor3 = Theme.TextTitle
	TitleLbl.Font = Enum.Font.GothamSemibold
	TitleLbl.TextSize = 10
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.Parent = RowFrame

	-- Value Label (Giá trị lớn)
	local ValueLbl = Instance.new("TextLabel")
	ValueLbl.Name = "ValueLabel" -- Để dễ tìm sau này
	ValueLbl.Text = "Checking..."
	ValueLbl.Size = UDim2.new(1, -50, 0, 20)
	ValueLbl.Position = UDim2.new(0, 45, 0, 20)
	ValueLbl.BackgroundTransparency = 1
	ValueLbl.TextColor3 = Theme.TextValueNormal
	ValueLbl.Font = Enum.Font.GothamBold
	ValueLbl.TextSize = 16
	ValueLbl.TextXAlignment = Enum.TextXAlignment.Left
	ValueLbl.TextScaled = true -- Tự co giãn nếu chữ quá dài
	ValueLbl.Parent = RowFrame
    
    -- Padding cho Value Label để textscaled không bị tràn
    local vPad = Instance.new("UIPadding")
    vPad.PaddingRight = UDim.new(0, 5)
    vPad.Parent = ValueLbl

	return ValueLbl, RowFrame, IconImage
end

-- Tạo 3 dòng thông tin
local MoonValueLbl, MoonRow, MoonIcon = createDataRow(1, Icons.Moon, "Moon Phase")
local GearValueLbl, GearRow, GearIcon = createDataRow(2, Icons.Gear, "Race Gear")
local TimeValueLbl, TimeRow, TimeIcon = createDataRow(3, Icons.Time, "Server Time")

-- Tăng kích thước dòng thời gian một chút cho nổi bật
TimeValueLbl.TextSize = 22
TimeValueLbl.Parent.Size = UDim2.new(1, 0, 0, 50)
TimeIcon.ImageColor3 = Theme.AccentInfo -- Icon đồng hồ màu xanh

local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	-- Sử dụng Tween để kéo mượt hơn
	TweenService:Create(MainContainer, TweenInfo.new(0.1), {Position = targetPos}):Play()
end

MainContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainContainer.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
MainContainer.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

function getServerTime()
	local realTime = Lighting.ClockTime
	local minute = math.floor(realTime) 
	local second = math.floor((realTime - minute) * 60)
	return minute, second
end

function MoonTextureId()
	local success, id = pcall(function()
		if game.PlaceId == 2753915549 or game.PlaceId == 4442272183 then
			return Lighting.FantasySky.MoonTextureId
		elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
			return Lighting.Sky.MoonTextureId
		end
	end)
	return success and id or nil
end

function getMoonState()
	local moon0 = "http://www.roblox.com/asset/?id=9709149680"
	local moon1 = "http://www.roblox.com/asset/?id=9709150401"
	local moon5 = "http://www.roblox.com/asset/?id=9709149431"
	local moonTexture = MoonTextureId()
	if moonTexture == moon5 then return "Full Moon Now"
	elseif moonTexture == moon0 then return "Moon0"
	elseif moonTexture == moon1 then return "Moon1"
	else return "Other/Normal" end
end

function checkGearStatus()
	local success, result = pcall(function()
		if not ReplicatedStorage:WaitForChild("Remotes", 5) or not ReplicatedStorage.Remotes:WaitForChild("CommF_", 5) then return "Connection Weak..." end
		local v229, v228, v227 = ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")
		if v229 == 1 then return "Train More (Resat)"
		elseif v229 == 2 or v229 == 4 or v229 == 7 then return "Ready to Buy (" .. v227 .. "F)"
		elseif v229 == 3 then return "Train More"
		elseif v229 == 5 then return "V4 Fully Awakened!"
		elseif v229 == 6 then return "Upgrade: " .. (v228 - 2) .. "/3 Done" end
		if v229 ~= 8 then return "Ready for Trial!" end
		return "Sessions Left: " .. (6 - v228)
	end)
	return success and result or "Loading/Error"
end

task.spawn(function()
	while true do
		-- 1. Cập nhật Thời gian
		local h, m = getServerTime()
		TimeValueLbl.Text = string.format("%02d : %02d", h, m)

		-- 2. Cập nhật Moon & Hiệu ứng
		local moonState = getMoonState()
		MoonValueLbl.Text = moonState

		if string.find(moonState, "Moon5") then
			MoonValueLbl.TextColor3 = Theme.AccentDanger
			MoonIcon.ImageColor3 = Theme.AccentDanger
			-- Đổi màu viền chính sang đỏ khi có Moon5
			TweenService:Create(MainStroke, TweenInfo.new(0.5), {Color = Theme.AccentDanger}):Play()
		elseif string.find(moonState, "Moon0") or string.find(moonState, "Moon1") then
			MoonValueLbl.TextColor3 = Theme.AccentWarning
			MoonIcon.ImageColor3 = Theme.AccentWarning
            TweenService:Create(MainStroke, TweenInfo.new(0.5), {Color = Theme.AccentWarning}):Play()
		else
			MoonValueLbl.TextColor3 = Theme.AccentInfo
			MoonIcon.ImageColor3 = Theme.AccentInfo
			-- Trả lại màu viền xanh mặc định
			TweenService:Create(MainStroke, TweenInfo.new(0.5), {Color = Theme.AccentInfo}):Play()
		end

		-- 3. Cập nhật Gear & Màu sắc
		local gearStatus = checkGearStatus()
		GearValueLbl.Text = gearStatus

		if string.find(gearStatus, "Ready") or string.find(gearStatus, "Buy") then
			GearValueLbl.TextColor3 = Theme.AccentGood
			GearIcon.ImageColor3 = Theme.AccentGood
		elseif string.find(gearStatus, "Train") or string.find(gearStatus, "Session") or string.find(gearStatus, "Left") then
			GearValueLbl.TextColor3 = Theme.AccentWarning
			GearIcon.ImageColor3 = Theme.AccentWarning
		elseif string.find(gearStatus, "Awakened") or string.find(gearStatus, "Done") then
			GearValueLbl.TextColor3 = Theme.AccentInfo
			GearIcon.ImageColor3 = Theme.AccentInfo
		else
			GearValueLbl.TextColor3 = Theme.TextTitle
			GearIcon.ImageColor3 = Theme.TextTitle
		end

		-- 4. Logic Kick (Giữ nguyên)
		if (string.find(moonState, "Moon5") and h == 6 and m == 0) or string.find(moonState, "Moon0") or string.find(moonState, "Moon1") then
			Players.LocalPlayer:Kick("Moon 0 And Moon 1 Cút Khỏi Server !!!")
			break
		end

		task.wait(1)
	end
end)

-- Thông báo khởi động
game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Ntramcutii=)))", Text = "Loaded Script !!", Duration = 10})

