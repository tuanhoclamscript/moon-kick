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
        return lighting.FantasySky.MoonTextureId
    elseif game.PlaceId == 7449423635 then
        return lighting.Sky.MoonTextureId
    end
    return nil -- Trả về nil nếu không khớp PlaceId
end

-- Hàm kiểm tra trạng thái mặt trăng
function checkMoon()
    local moon5 = "http://www.roblox.com/asset/?id=9709149431" -- ID Moon 5
    local moonTexture = MoonTextureId() -- Lấy ID mặt trăng hiện tại

    if moonTexture == moon5 then
        return true -- Đang trong Moon 5
    else
        return false -- Không phải Moon 5
    end
end

-- Hàm kiểm tra và đá người chơi khi Moon 5 và 6h sáng
function kickPlayerOnMoon5At6AM()
    local wasInMoon5 = checkMoon() -- Kiểm tra nếu ban đầu là Moon 5

    -- Chạy vòng lặp để liên tục kiểm tra trạng thái mặt trăng và thời gian
    while true do
        local currentInMoon5 = checkMoon() -- Lấy trạng thái hiện tại của mặt trăng
        local currentMinute, currentSecond = getServerTime() -- Lấy thời gian hiện tại

        -- Kiểm tra nếu mặt trăng là Moon 5 và thời gian là 6:00 AM (6 giờ sáng)
        if currentInMoon5 and currentMinute == 6 and currentSecond == 0 then
            -- Khi Moon 5 và 6:00 AM, đá người chơi
            game.Players.LocalPlayer:Kick("HẾT FM R TK BÉO:))")
            break -- Thoát khỏi vòng lặp sau khi đá người chơi
        end

        -- In ra thời gian và trạng thái mặt trăng
        print("MADE BY BTUAN")
        print("Thời gian: ", currentMinute, "phút", currentSecond, "giây")
        print("Trạng thái Moon: ", currentInMoon5 and "Moon 5" or "Không phải Moon 5")

        wait(1) -- Chờ 1 giây trước khi kiểm tra lại
    end
end

-- Gọi hàm kickPlayerOnMoon5At6AM
kickPlayerOnMoon5At6AM()
