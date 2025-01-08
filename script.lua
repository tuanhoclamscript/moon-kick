-- Hàm lấy thời gian trong game
function getServerTime()
    local realTime = game.Lighting.ClockTime -- Lấy ClockTime từ Lighting
    local minute = math.floor(realTime) -- Lấy phần nguyên làm phút
    local second = math.floor((realTime - minute) * 60) -- Chuyển phần thập phân thành giây
    return minute, second
end

-- Hàm lấy ID của texture mặt trăng dựa trên PlaceId
function MoonTextureId()
    local lighting = game:GetService("Lighting")
    if game.PlaceId == 2753915549 or game.PlaceId == 4442272183 then
        return lighting:FindFirstChild("FantasySky") and lighting.FantasySky.MoonTextureId
    elseif game.PlaceId == 7449423635 then
        return lighting:FindFirstChild("Sky") and lighting.Sky.MoonTextureId
    end
    return nil -- Trả về nil nếu không khớp PlaceId
end

-- Hàm kiểm tra trạng thái mặt trăng
function getMoonState()
    local moon0 = "http://www.roblox.com/asset/?id=9709149680"
    local moon1 = "http://www.roblox.com/asset/?id=9709150401"
    local moon5 = "http://www.roblox.com/asset/?id=9709149431" -- ID Moon 5
    local moonTexture = MoonTextureId() -- Lấy ID mặt trăng hiện tại

    if moonTexture == moon5 then
        return "Moon5"
    elseif moonTexture == moon0 then
        return "Moon0"
    elseif moonTexture == moon1 then
        return "Moon1"
    else
        return "Other"
    end
end

-- Hàm kiểm tra và đá người chơi nếu Moon là Moon5, Moon0 hoặc Moon1 vào thời điểm cụ thể
function kickPlayerOnMoonCondition()
    local player = game.Players.LocalPlayer

    if not player then
        warn("Không tìm thấy LocalPlayer.")
        return
    end

    -- Chạy vòng lặp để liên tục kiểm tra trạng thái mặt trăng và thời gian
    while true do
        local moonState = getMoonState() -- Lấy trạng thái mặt trăng hiện tại
        local currentMinute, currentSecond = getServerTime() -- Lấy thời gian hiện tại

        -- Kiểm tra các điều kiện và đá người chơi
        if moonState == "Moon5" and currentMinute == 6 and currentSecond == 0 then
          game.Players.LocalPlayer:Kick("HẾT FM R TK BÉO:))")
            break
        elseif moonState == "Moon0" or moonState == "Moon1" then
          game.Players.LocalPlayer:Kick("Moon 0 or mooon1")
            break
        end

        -- In ra thông tin trạng thái
        print("MADE BY BTUAN")
        print("Thời gian: ", currentMinute, "phút", currentSecond, "giây")
        print("Trạng thái Moon: ", moonState)

        wait(1) -- Chờ 1 giây trước khi kiểm tra lại
    end
end

-- Gọi hàm kiểm tra và đá người chơi
kickPlayerOnMoonCondition()
