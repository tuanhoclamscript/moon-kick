local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--------------------------------------------------------------------------------
-- PHẦN 1: TẠO GIAO DIỆN (UI) ĐẸP MẮT & MỞ RỘNG
--------------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonGearMonitor"

if pcall(function() return CoreGui:FindFirstChild("RobloxGui") end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Khung chính (Tăng chiều cao để chứa thêm Gear)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 170) -- Cao hơn bản cũ (130 -> 170)
MainFrame.Position = UDim2.new(0.05, 0, 0.70, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Bo góc
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Viền sáng
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 180, 255)
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

-- Tiêu đề
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "MOON & GEAR TOOL"
TitleLabel.Size = UDim2.new(1, 0, 0, 25)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = MainFrame

-- Thanh gạch ngang
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.8, 0, 0, 1)
Line.Position = UDim2.new(0.1, 0, 0.18, 0)
Line.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- 1. Hiển thị Trạng Thái Moon
local MoonLabel = Instance.new("TextLabel")
MoonLabel.Name = "MoonLabel"
MoonLabel.Text = "Moon: Checking..."
MoonLabel.Size = UDim2.new(1, 0, 0, 25)
MoonLabel.Position = UDim2.new(0, 0, 0.25, 0)
MoonLabel.BackgroundTransparency = 1
MoonLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
MoonLabel.Font = Enum.Font.GothamSemibold
MoonLabel.TextSize = 14
MoonLabel.Parent = MainFrame

-- 2. Hiển thị Trạng Thái Gear (MỚI)
local GearLabel = Instance.new("TextLabel")
GearLabel.Name = "GearLabel"
GearLabel.Text = "Gear: Checking..."
GearLabel.Size = UDim2.new(1, 0, 0, 40) -- Kích thước lớn hơn chút để hiện dòng dài
GearLabel.Position = UDim2.new(0, 0, 0.42, 0)
GearLabel.BackgroundTransparency = 1
GearLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
GearLabel.Font = Enum.Font.GothamSemibold
GearLabel.TextScaled = true -- Tự chỉnh size chữ cho vừa khung
GearLabel.Parent = MainFrame
-- Thêm padding để TextScaled không bị sát lề
local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = GearLabel

-- 3. Hiển thị Thời Gian
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Text = "--:--"
TimeLabel.Size = UDim2.new(1, 0, 0, 40)
TimeLabel.Position = UDim2.new(0, 0, 0.72, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
TimeLabel.Font = Enum.Font.GothamBold
TimeLabel.TextSize = 28
TimeLabel.Parent = MainFrame

--------------------------------------------------------------------------------
-- PHẦN 2: CHỨC NĂNG KÉO THẢ (DRAGGABLE)
--------------------------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

--------------------------------------------------------------------------------
-- PHẦN 3: CÁC HÀM LOGIC (MOON + GEAR)
--------------------------------------------------------------------------------

-- Hàm lấy thời gian
function getServerTime()
    local realTime = Lighting.ClockTime
    local minute = math.floor(realTime) 
    local second = math.floor((realTime - minute) * 60)
    return minute, second
end

-- Hàm lấy ID Moon
function MoonTextureId()
    if game.PlaceId == 2753915549 or game.PlaceId == 4442272183 then
        return Lighting:FindFirstChild("FantasySky") and Lighting.FantasySky.MoonTextureId
    elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
        return Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId
    end
    return nil
end

-- Hàm check trạng thái Moon
function getMoonState()
    local moon0 = "http://www.roblox.com/asset/?id=9709149680"
    local moon1 = "http://www.roblox.com/asset/?id=9709150401"
    local moon5 = "http://www.roblox.com/asset/?id=9709149431"
    local moonTexture = MoonTextureId()

    if moonTexture == moon5 then return "Moon5"
    elseif moonTexture == moon0 then return "Moon0"
    elseif moonTexture == moon1 then return "Moon1"
    else return "Other"
    end
end

-- Hàm Check Gear (Của bạn - Đã thêm pcall để tránh lỗi game khác)
function checkGearStatus()
    local success, result = pcall(function()
        -- Kiểm tra xem Remote có tồn tại không trước khi gọi
        if not ReplicatedStorage:FindFirstChild("Remotes") or not ReplicatedStorage.Remotes:FindFirstChild("CommF_") then
            return "No Remote"
        end
        
        local v229, v228, v227 = ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")
        
        if v229 == 1 then
            return "Train More (Resat)"
        elseif v229 == 2 or v229 == 4 or v229 == 7 then
            return "Buy Gear (" .. v227 .. " F)"
        elseif v229 == 3 then
            return "Luyen them di nhin con cac"
        elseif v229 == 5 then
            return "xong roi do dit me may"
        elseif v229 == 6 then
            return "Upgrade: " .. (v228 - 2) .. "/3"
        end
        if v229 ~= 8 then
            return "Đang đợi trials dit me may"
        end
        return "Session Left: " .. (6 - v228)
    end)

    if success then
        return result
    else
        return "Error/Wait" -- Trả về nếu gặp lỗi mạng hoặc chưa load
    end
end

--------------------------------------------------------------------------------
-- PHẦN 4: VÒNG LẶP CHÍNH
--------------------------------------------------------------------------------

local function mainLoop()
    task.spawn(function()
        while true do
            -- 1. Xử lý Moon và Time
            local moonState = getMoonState()
            local h, m = getServerTime()
            TimeLabel.Text = string.format("%02d:%02d", h, m)
            MoonLabel.Text = "Moon: " .. moonState

            -- Màu sắc Moon
            if moonState == "Moon5" then
                MoonLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Đỏ báo động
                UIStroke.Color = Color3.fromRGB(255, 0, 0)
            else
                MoonLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
                UIStroke.Color = Color3.fromRGB(80, 180, 255)
            end

            -- 2. Xử lý Gear Status
            local gearStatus = checkGearStatus()
            GearLabel.Text = gearStatus

            -- Màu sắc Gear logic
            if string.find(gearStatus, "Ready") or string.find(gearStatus, "Buy") then
                GearLabel.TextColor3 = Color3.fromRGB(0, 255, 100) -- Xanh lá (Sẵn sàng/Mua được)
            elseif string.find(gearStatus, "Train") or string.find(gearStatus, "Session") then
                GearLabel.TextColor3 = Color3.fromRGB(255, 170, 0) -- Cam (Cần cày thêm)
            elseif string.find(gearStatus, "Done") then
                GearLabel.TextColor3 = Color3.fromRGB(0, 200, 255) -- Xanh dương (Hoàn thành)
            else
                GearLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Màu xám (Khác)
            end

            -- 3. Logic Kick (Giữ nguyên của bạn)
            if moonState == "Moon5" and h == 6 and m == 0 then
                Players.LocalPlayer:Kick("End FullMoon Dev : Btuan")
                break
            elseif moonState == "Moon0" or moonState == "Moon1" then
                Players.LocalPlayer:Kick("Moon 0 hoặc Moon 1")
                break
            end

            task.wait(1) 
        end
    end)
end

mainLoop()

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NtramCute=))";
    Text = "Script Check Is Loaded";
    Duration = 10;
})
