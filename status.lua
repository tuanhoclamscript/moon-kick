local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local CommF = ReplicatedStorage.Remotes.CommF_

-- Load SkinController an toàn
local success, SkinController = pcall(require, ReplicatedStorage.Controllers.SkinController)

-- Danh sách các đai (Belts) theo thứ tự
local DOJO_BELTS = {
    'Dojo Belt (White)',
    'Dojo Belt (Yellow)',
    'Dojo Belt (Orange)',
    'Dojo Belt (Green)',
    'Dojo Belt (Blue)',
    'Dojo Belt (Purple)',
    'Dojo Belt (Red)',
    'Dojo Belt (Black)',
}

-- Tạo bảng tra cứu nhanh thứ tự đai
local BELT_ORDER = {}
for index, beltName in ipairs(DOJO_BELTS) do
    BELT_ORDER[beltName] = index
end

-- Bảng màu sắc hiển thị
local COLORS = {
    White = Color3.fromRGB(255, 255, 255),
    Yellow = Color3.fromRGB(255, 255, 0),
    Orange = Color3.fromRGB(255, 165, 0),
    Green = Color3.fromRGB(0, 255, 0),
    Blue = Color3.fromRGB(0, 0, 255),
    Purple = Color3.fromRGB(128, 0, 128),
    Red = Color3.fromRGB(255, 0, 0),
    Black = Color3.fromRGB(50, 50, 50),
    None = Color3.fromRGB(150, 150, 150), -- Màu xám cho chưa có
    Done = Color3.fromRGB(255, 215, 0),   -- Màu vàng kim cho hoàn thành
}

-- Hàm xóa dấu ngoặc đơn trong tên (ví dụ: "Colors (White)" -> "Colors")
local function StripParentheses(text)
    if text then
        text = text:match('%((.-)%)') or text
    end
    return text
end

-- Hàm lấy màu dựa trên tên
local function GetColor(name)
    return COLORS[name] or COLORS.White
end

-- Chuyển đổi Color3 sang mã Hex cho RichText
local function ToHex(color)
    return string.format('#%02x%02x%02x', color.R * 255, color.G * 255, color.B * 255)
end

-- Tạo chuỗi văn bản có màu
local function ColorizeText(text, color)
    return string.format('<font color="%s">%s</font>', ToHex(color), text)
end

-- Kiểm tra xem có Rainbow Saviour không
local function CheckRainbowSaviour()
    if not (success and SkinController) then return false end

    local callSuccess, inventory = pcall(SkinController.GetInventory)
    if not callSuccess or type(inventory) ~= 'table' then return false end

    for _, item in pairs(inventory) do
        if item.DisplayName == 'Rainbow Saviour' then
            return (item.Count or 0) > 0
        end
    end
    return false
end

-- Tạo hoặc lấy GUI hiển thị
local function GetOrCreateOverlay()
    local gui = LocalPlayer.PlayerGui:FindFirstChild('BeltCheckHUD')
    if not gui then
        gui = Instance.new('ScreenGui')
        gui.Name = 'BeltCheckHUD'
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = LocalPlayer.PlayerGui
    end

    local label = gui:FindFirstChild('InfoLabel')
    if not label then
        label = Instance.new('TextLabel')
        label.Name = 'InfoLabel'
        label.Size = UDim2.new(0, 550, 0, 220)
        label.Position = UDim2.new(0.5, -275, 0, -10) -- Vị trí giữa trên cùng
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 40
        label.TextColor3 = COLORS.White
        label.TextWrapped = true
        label.TextStrokeTransparency = 0.5
        label.Parent = gui
    end
    return label
end

-- Hàm chính: Cập nhật thông tin
local function UpdateStats()
    local label = GetOrCreateOverlay()
    local serverInventory = CommF:InvokeServer('getInventory')

    if type(serverInventory) == 'table' then
        local currentBeltIndex = -1
        local materials = {
            ['Dragon Scale'] = 0,
            ['Dragon Egg'] = 0,
            ['Blaze Ember'] = 0,
        }
        local currentBeltName = nil

        -- Duyệt qua inventory của người chơi
        for _, item in ipairs(serverInventory) do
            if item.Type ~= 'Wear' then
                -- Nếu không phải đồ mặc, kiểm tra xem có phải nguyên liệu không
                if materials[item.Name] then
                    materials[item.Name] = item.Count or 1
                end
            else
                -- Nếu là đồ mặc, kiểm tra xem có phải Belt không
                local beltRank = BELT_ORDER[item.Name]
                if beltRank and currentBeltIndex < beltRank then
                    currentBeltIndex = beltRank
                    currentBeltName = item.Name
                end
            end
        end

        -- Xác định Belt tiếp theo
        local nextBeltName
        if (not currentBeltIndex or currentBeltIndex < 1) then
            nextBeltName = DOJO_BELTS[1] -- Chưa có belt nào thì mục tiêu là belt đầu tiên
        else
            if #DOJO_BELTS > currentBeltIndex then
                nextBeltName = DOJO_BELTS[currentBeltIndex + 1]
            else
                nextBeltName = nil -- Đã max belt
            end
        end

        -- Format hiển thị
        local currentDisplay = currentBeltName and StripParentheses(currentBeltName) or 'None'
        local nextDisplay = nextBeltName and StripParentheses(nextBeltName) or 'Done'
        
        -- Lấy số Fragments an toàn
        local fragSuccess, fragCount = pcall(function()
            return LocalPlayer.Data.Fragments.Value
        end)
        
        local hasRainbow = CheckRainbowSaviour()

        -- Xây dựng nội dung hiển thị
        local lines = {
            string.format('Current: %s | Next: %s', 
                ColorizeText(currentDisplay, GetColor(currentDisplay)), 
                ColorizeText(nextDisplay, GetColor(nextDisplay))
            ),
            ColorizeText('Fragments: ' .. (not fragSuccess and 0 or fragCount), Color3.fromRGB(170, 85, 255)),
            string.format('Scale: %d | Egg: %d | Ember: %d', materials['Dragon Scale'], materials['Dragon Egg'], materials['Blaze Ember']),
            'Rainbow: ' .. (hasRainbow and ColorizeText('Done', COLORS.Done) or ColorizeText('No', Color3.fromRGB(255, 80, 80))),
        }

        label.Text = table.concat(lines, '\n')
        label.RichText = true
    end
end

-- Vòng lặp chạy mỗi 5 giây
task.spawn(function()
    while task.wait(5) do
        pcall(UpdateStats)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title="Ntramcutii=))"; Text="Script Is Loaded!!!"; Duration=20})
