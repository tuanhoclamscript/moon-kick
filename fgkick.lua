do
    repeat
        local player = game:GetService("Players").LocalPlayer
        local mainGui = player.PlayerGui:FindFirstChild("Main (minimal)")
        if mainGui then
            local ChooseTeam = mainGui:FindFirstChild("ChooseTeam", true)
            if ChooseTeam and ChooseTeam.Visible then
                for i, v in pairs(getgc()) do
                    if type(v) == "function" then
                        local success, constants = pcall(getconstants, v)
                        if success and constants and table.find(constants, "Marines") then
                            pcall(function()
                                v(shared.Team or "Marines")
                            end)
                        end
                    end
                end
            end
        end
        wait(1)
    until game.Players.LocalPlayer.Team
    repeat wait() until game.Players.LocalPlayer.Character
end
local v229, v228, v227 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")
while true do
    if v229 == 8 then
        game:GetService("Players").LocalPlayer:Kick("fg r beo béo :D made by btuan dzaii")
    end
    wait(50)
end
