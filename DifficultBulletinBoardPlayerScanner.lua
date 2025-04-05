DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}

local playerScannerFrame = CreateFrame("Frame")

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end


playerScannerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
playerScannerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
playerScannerFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
playerScannerFrame:RegisterEvent("WHO_LIST_UPDATE")
playerScannerFrame:RegisterEvent("CHAT_MSG_SYSTEM")
playerScannerFrame:SetScript("OnEvent", function()

    if event == "PLAYER_ENTERING_WORLD" then
        local playerName = UnitName("player")
        local localizedClass, englishClass = UnitClass("player")

        DifficultBulletinBoardVars.AddPlayerToDatabase(playerName, localizedClass)
    end

    if event == "WHO_LIST_UPDATE" then
        for index = 1, GetNumWhoResults() do
            local playerName, guild, level, race, class, zone, classFileName = GetWhoInfo(index)

            DifficultBulletinBoardVars.AddPlayerToDatabase(playerName, class)
        end
    end

    if event == "UPDATE_MOUSEOVER_UNIT" then
        if UnitIsPlayer("mouseover") then
            local playerName = UnitName("mouseover")
            local localizedClass, englishClass = UnitClass("mouseover")
            
            DifficultBulletinBoardVars.AddPlayerToDatabase(playerName, localizedClass)
        end
    end

    if event == "PLAYER_TARGET_CHANGED" then
        if UnitIsPlayer("target") then
            local playerName = UnitName("target")
            local localizedClass, englishClass = UnitClass("target")
            
            DifficultBulletinBoardVars.AddPlayerToDatabase(playerName, localizedClass)
        end
    end

    -- for /who results
    if event == "CHAT_MSG_SYSTEM" then
        for i = 1, GetNumWhoResults() do
            local playerName, _, _, _, localizedClass, _ = GetWhoInfo(i)
            DifficultBulletinBoardVars.AddPlayerToDatabase(playerName, localizedClass)
        end
    end
end)