local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Theme = {
	Background = Color3.fromRGB(20, 20, 30),
	CardBackground = Color3.fromRGB(30, 30, 40),
	TextTitle = Color3.fromRGB(150, 150, 150),
	TextValueNormal = Color3.fromRGB(255, 255, 255),
	AccentGood = Color3.fromRGB(0, 255, 128),   -- Xanh lá
	AccentWarning = Color3.fromRGB(255, 215, 0), -- Vàng chanh
	AccentDanger = Color3.fromRGB(255, 50, 80),  -- Đỏ
	AccentInfo = Color3.fromRGB(0, 190, 255),    -- Xanh dương
}

local Icons = {
	Moon = "rbxassetid://6031247509", 
	Gear = "rbxassetid://3926307971", 
	Time = "rbxassetid://3926305904", 
}

local MoonPhases = {
    ["http://www.roblox.com/asset/?id=9709135895"] = {Text = "Phase: 0/8 (New)", Color = Theme.AccentInfo},      -- moon1
    ["http://www.roblox.com/asset/?id=9709139597"] = {Text = "Phase: 1/8", Color = Theme.AccentInfo},             -- moon2
    ["http://www.roblox.com/asset/?id=9709143733"] = {Text = "Phase: 2/8", Color = Theme.AccentInfo},             -- moon3
    ["http://www.roblox.com/asset/?id=9709149052"] = {Text = "Phase: 3/8 [Next Full]", Color = Theme.AccentWarning}, -- moon4 (Sắp Full)
    ["http://www.roblox.com/asset/?id=9709149431"] = {Text = "Phase: 4/8 [FULL MOON]", Color = Theme.AccentDanger},  -- moon5 (FULL)
    ["http://www.roblox.com/asset/?id=9709149680"] = {Text = "Phase: 5/8 [Passed]", Color = Color3.fromRGB(255, 150, 50)}, -- moon6
    ["http://www.roblox.com/asset/?id=9709150086"] = {Text = "Phase: 6/8", Color = Theme.AccentInfo},             -- moon7
    ["http://www.roblox.com/asset/?id=9709150401"] = {Text = "Phase: 7/8", Color = Theme.AccentInfo},             -- moon8
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonMonitorV4"
if pcall(function() return CoreGui:FindFirstChild("RobloxGui") end) then
	ScreenGui.Parent = CoreGui
else
	ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Container
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 300, 0, 230) -- Rộng hơn chút để hiện đủ chữ Phase
MainContainer.Position = UDim2.new(0.02, 0, 0.62, 0)
MainContainer.BackgroundColor3 = Theme.Background
MainContainer.BorderSizePixel = 0
MainContainer.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainContainer

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 3
MainStroke.Color = Theme.AccentInfo
MainStroke.Transparency = 0.4
MainStroke.Parent = MainContainer

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingTop = UDim.new(0, 15)
MainPadding.PaddingBottom = UDim.new(0, 15)
MainPadding.PaddingLeft = UDim.new(0, 15)
MainPadding.PaddingRight = UDim.new(0, 15)
MainPadding.Parent = MainContainer

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.Parent = MainContainer

-- Header
local Header = Instance.new("TextLabel")
Header.Text = "FM Kick - Checking Gear (Btuann)"
Header.Size = UDim2.new(1, 0, 0, 20)
Header.BackgroundTransparency = 1
Header.TextColor3 = Theme.AccentInfo
Header.Font = Enum.Font.GothamBlack
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.LayoutOrder = 0
Header.Parent = MainContainer

-- Helper function to create rows
local function createDataRow(order, iconId, titleText)
	local RowFrame = Instance.new("Frame")
	RowFrame.Size = UDim2.new(1, 0, 0, 45)
	RowFrame.BackgroundColor3 = Theme.CardBackground
	RowFrame.LayoutOrder = order
	RowFrame.Parent = MainContainer

	local RowCorner = Instance.new("UICorner")
	RowCorner.CornerRadius = UDim.new(0, 10)
	RowCorner.Parent = RowFrame

	local IconImage = Instance.new("ImageLabel")
	IconImage.Image = iconId
	IconImage.Size = UDim2.new(0, 24, 0, 24)
	IconImage.Position = UDim2.new(0, 10, 0.5, -12)
	IconImage.BackgroundTransparency = 1
	IconImage.ImageColor3 = Theme.TextTitle
	IconImage.Parent = RowFrame

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

	local ValueLbl = Instance.new("TextLabel")
	ValueLbl.Text = "Scanning..."
	ValueLbl.Size = UDim2.new(1, -50, 0, 20)
	ValueLbl.Position = UDim2.new(0, 45, 0, 20)
	ValueLbl.BackgroundTransparency = 1
	ValueLbl.TextColor3 = Theme.TextValueNormal
	ValueLbl.Font = Enum.Font.GothamBold
	ValueLbl.TextSize = 16
	ValueLbl.TextXAlignment = Enum.TextXAlignment.Left
	ValueLbl.TextScaled = true 
	ValueLbl.Parent = RowFrame
    
    local vPad = Instance.new("UIPadding")
    vPad.PaddingRight = UDim.new(0, 5)
    vPad.Parent = ValueLbl

	return ValueLbl, RowFrame, IconImage
end

local MoonValueLbl, MoonRow, MoonIcon = createDataRow(1, Icons.Moon, "Moon Status")
local GearValueLbl, GearRow, GearIcon = createDataRow(2, Icons.Gear, "Race Gear")
local TimeValueLbl, TimeRow, TimeIcon = createDataRow(3, Icons.Time, "Server Time")

TimeValueLbl.TextSize = 22
TimeValueLbl.Parent.Size = UDim2.new(1, 0, 0, 50)
TimeIcon.ImageColor3 = Theme.AccentInfo

local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	TweenService:Create(MainContainer, TweenInfo.new(0.05), {Position = targetPos}):Play()
end
MainContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = MainContainer.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
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

function getMoonTextureId()
    -- Lấy ID texture hiện tại (Đã thêm pcall để an toàn)
	local success, result = pcall(function()
		if game.PlaceId == 2753915549 or game.PlaceId == 4442272183 then
			return Lighting:FindFirstChild("FantasySky") and Lighting.FantasySky.MoonTextureId
		elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
			return Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId
		end
	end)
    return success and result or nil
end

function checkGearStatus()
	local success, result = pcall(function()
		if not ReplicatedStorage:FindFirstChild("Remotes") then return "Loading..." end
		local v229, v228, v227 = ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")
		if v229 == 1 then return "Train More (Resat)"
		elseif v229 == 2 or v229 == 4 or v229 == 7 then return "Buy Gear (" .. v227 .. "F)"
		elseif v229 == 3 then return "Train More"
		elseif v229 == 5 then return "V4 Fully Awakened"
		elseif v229 == 6 then return "Upgrade: " .. (v228 - 2) .. "/3" end
		if v229 ~= 8 then return "Ready for Trial" end
		return "Sessions Left: " .. (6 - v228)
	end)
	return success and result or "Wait..."
end

task.spawn(function()
	while true do
        -- 1. TIME
		local h, m = getServerTime()
		TimeValueLbl.Text = string.format("%02d : %02d", h, m)

        -- 2. MOON PHASE (Logic mới)
        local currentTexture = getMoonTextureId()
        local moonInfo = MoonPhases[currentTexture]
        
        if moonInfo then
            MoonValueLbl.Text = moonInfo.Text
            MoonValueLbl.TextColor3 = moonInfo.Color
            MoonIcon.ImageColor3 = moonInfo.Color
            -- Hiệu ứng viền
            TweenService:Create(MainStroke, TweenInfo.new(0.5), {Color = moonInfo.Color}):Play()
        else
            MoonValueLbl.Text = "Unknown / Day"
            MoonValueLbl.TextColor3 = Theme.TextTitle
            MoonIcon.ImageColor3 = Theme.TextTitle
            TweenService:Create(MainStroke, TweenInfo.new(0.5), {Color = Theme.AccentInfo}):Play()
        end

        -- 3. GEAR STATUS
		local gearStatus = checkGearStatus()
		GearValueLbl.Text = gearStatus
        -- Logic màu Gear
		if string.find(gearStatus, "Ready") or string.find(gearStatus, "Buy") then
			GearValueLbl.TextColor3 = Theme.AccentGood; GearIcon.ImageColor3 = Theme.AccentGood
		elseif string.find(gearStatus, "Train") or string.find(gearStatus, "Session") then
			GearValueLbl.TextColor3 = Theme.AccentWarning; GearIcon.ImageColor3 = Theme.AccentWarning
		elseif string.find(gearStatus, "Awakened") then
			GearValueLbl.TextColor3 = Theme.AccentInfo; GearIcon.ImageColor3 = Theme.AccentInfo
		else
			GearValueLbl.TextColor3 = Theme.TextValueNormal; GearIcon.ImageColor3 = Theme.TextValueNormal
		end

        
        if currentTexture == "http://www.roblox.com/asset/?id=9709149431" and h == 6 and m == 0 then
             game.shutdown() -- Tắt game để tránh bị kick
             break
        elseif currentTexture == "http://www.roblox.com/asset/?id=9709149680" or currentTexture == "http://www.roblox.com/asset/?id=9709150401" then
             
             break
        end

		task.wait(0.5) -- Check nhanh hơn một chút (0.5s)
	end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Ntramcutii=)))"; Text = "Script Is Loaded - thắng gay !!"; Duration = 10})
