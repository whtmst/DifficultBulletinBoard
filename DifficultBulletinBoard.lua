DifficultBulletinBoard = DifficultBulletinBoard or {}
DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}
DifficultBulletinBoardDefaults = DifficultBulletinBoardDefaults or {}
DifficultBulletinBoardOptionFrame = DifficultBulletinBoardOptionFrame or {}

local string_gfind = string.gmatch or string.gfind

local mainFrame = DifficultBulletinBoardMainFrame
local optionFrame = DifficultBulletinBoardOptionFrame

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

 function DifficultBulletinBoard.SplitIntoLowerWords(input)
    local tags = {}

    -- iterate over words (separated by spaces) and insert them into the tags table
    for tag in string_gfind(input, "%S+") do
        table.insert(tags, string.lower(tag))
    end

    return tags
end

function DifficultBulletinBoard_ToggleOptionFrame()
    if optionFrame then
        if optionFrame:IsShown() then
            if DifficultBulletinBoardVars.optionFrameSound == "true" then
                PlaySound("igMainMenuClose");
            end
            optionFrame:Hide()
        else
            if DifficultBulletinBoardVars.optionFrameSound == "true" then
                PlaySound("igMainMenuClose");
            end
            optionFrame:Show()
            mainFrame:Hide()
        end
    else
        print("Option frame not found")
    end
end

function DifficultBulletinBoard_ToggleMainFrame()
    if mainFrame then
        if mainFrame:IsShown() then
            if DifficultBulletinBoardVars.mainFrameSound == "true" then
                PlaySound("igQuestLogOpen");
            end
            mainFrame:Hide()
        else
            if DifficultBulletinBoardVars.mainFrameSound == "true" then
                PlaySound("igQuestLogClose");
            end
            mainFrame:Show()
            optionFrame:Hide()
        end
    else
        print("Main frame not found")
    end
end

function DifficultBulletinBoard_DragMinimapStart()
    local button = DifficultBulletinBoard_MinimapButtonFrame

    if (IsShiftKeyDown()) and button then 
        button:StartMoving()
    end
end

function DifficultBulletinBoard_DragMinimapStop()
    local button = DifficultBulletinBoard_MinimapButtonFrame

    if button then
        button:StopMovingOrSizing()

        local x, y = button:GetCenter()
        button.db = button.db or {}
        button.db.posX = x
        button.db.posY = y
    end
end

SLASH_DIFFICULTBB1 = "/dbb"
SlashCmdList["DIFFICULTBB"] = function() DifficultBulletinBoard_ToggleMainFrame() end

local function initializeAddon(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DifficultBulletinBoard" then
        DifficultBulletinBoardVars.LoadSavedVariables()

        -- create option frame first so the user can update his options in case he put in some invalid data that might result in the addon crashing
        DifficultBulletinBoardOptionFrame.InitializeOptionFrame()

        -- create main frame afterwards
        DifficultBulletinBoardMainFrame.InitializeMainFrame()
    end
end

local function handleEvent()
    if event == "ADDON_LOADED" then 
        initializeAddon(event, arg1)
    end

    if event == "CHAT_MSG_HARDCORE" then 
        DifficultBulletinBoard.OnChatMessage(arg1, arg2, "HC")
    end

    if event == "CHAT_MSG_CHANNEL" then 
        DifficultBulletinBoard.OnChatMessage(arg1, arg2, arg9) 
    end

    if event == "CHAT_MSG_SYSTEM" then 
        DifficultBulletinBoard.OnSystemMessage(arg1) 
    end
end

-- Initialize with the current server time
local lastUpdateTime = GetTime() 
local function OnUpdate()
    local currentTime = GetTime()
    local deltaTime = currentTime - lastUpdateTime

    -- Update only if at least 1 second has passed
    if deltaTime >= 1 then
        -- Update the lastUpdateTime
        lastUpdateTime = currentTime

        DifficultBulletinBoardMainFrame.UpdateServerTime()

        if DifficultBulletinBoardVars.timeFormat == "elapsed" then
            DifficultBulletinBoardMainFrame.UpdateElapsedTimes()
        end
    end
end

mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("CHAT_MSG_CHANNEL")
mainFrame:RegisterEvent("CHAT_MSG_HARDCORE")
mainFrame:RegisterEvent("CHAT_MSG_SYSTEM")
mainFrame:SetScript("OnEvent", handleEvent)
mainFrame:SetScript("OnUpdate", OnUpdate)