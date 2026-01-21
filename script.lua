local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

--------------------------------------------------------------------------------
-- PHẦN 1: TẠO GIAO DIỆN (UI) ĐẸP MẮT
--------------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonMonitorUI"
-- Nếu chạy trên Executor thì dùng CoreGui cho an toàn, nếu Studio thì dùng PlayerGui
if pcall(function() return CoreGui:FindFirstChild("RobloxGui") end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Khung chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 130)
MainFrame.Position = UDim2.new(0.05, 0, 0.75, 0) -- Vị trí mặc định góc trái dưới
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Bo góc cho khung
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Viền sáng (Stroke)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 180, 255)
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

-- Tiêu đề
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "MOON MONITOR"
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = MainFrame

-- Thanh gạch ngang
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.8, 0, 0, 1)
Line.Position = UDim2.new(0.1, 0, 0.25, 0)
Line.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Hiển thị Trạng Thái Moon
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Text = "Status: Checking..."
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.35, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Màu đỏ nhạt mặc định
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Hiển thị Thời Gian
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Text = "Time: --:--"
TimeLabel.Size = UDim2.new(1, 0, 0, 40)
TimeLabel.Position = UDim2.new(0, 0, 0.6, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.fromRGB(100, 255, 150) -- Màu xanh lá
TimeLabel.Font = Enum.Font.GothamBold
TimeLabel.TextSize = 24
TimeLabel.Parent = MainFrame

-- Chức năng Kéo Thả (Draggable)
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
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--------------------------------------------------------------------------------
-- PHẦN 2: LOGIC CỦA BẠN (Đã tối ưu hóa)
--------------------------------------------------------------------------------

-- Hàm lấy thời gian
function getServerTime()
    local realTime = Lighting.ClockTime
    local minute = math.floor(realTime) -- Đây thực tế là Giờ trong game (Hour)
    local second = math.floor((realTime - minute) * 60) -- Đây là Phút trong game
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

-- Hàm check trạng thái
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

--------------------------------------------------------------------------------
-- PHẦN 3: VÒNG LẶP KIỂM TRA & CẬP NHẬT GUI
--------------------------------------------------------------------------------

local function mainLoop()
    task.spawn(function()
        while true do
            local moonState = getMoonState()
            local h, m = getServerTime() -- h: giờ (minute cũ), m: phút (second cũ)

            -- Format số đẹp (ví dụ 6:5 thành 06:05)
            local timeString = string.format("%02d:%02d", h, m)

            -- Cập nhật GUI
            TimeLabel.Text = timeString
            StatusLabel.Text = "Moon Phase: " .. moonState

            -- Đổi màu chữ dựa trên MoonState để dễ nhìn
            if moonState == "Moon5" then
                StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Đỏ đậm cảnh báo
                UIStroke.Color = Color3.fromRGB(255, 50, 50) -- Viền đỏ
            elseif moonState == "Moon0" or moonState == "Moon1" then
                 StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0) -- Cam
            else
                StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255) -- Xanh dương
                UIStroke.Color = Color3.fromRGB(80, 180, 255)
            end

            -- Logic Kick Của Bạn
            if moonState == "Moon5" and h == 6 and m == 0 then
                Players.LocalPlayer:Kick("End FullMoon Dev : Btuan")
                break
            elseif moonState == "Moon0" or moonState == "Moon1" then
                Players.LocalPlayer:Kick("Moon 0 hoặc Moon 1")
                break
            end

            task.wait(1) -- Dùng task.wait tối ưu hơn wait
        end
    end)
end

-- Bắt đầu chạy
mainLoop()

-- Thông báo đã load
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Check Moon ??? Phong Gay ";
    Text = "UI Loaded! Made by Btuan";
    Duration = 5;
})
