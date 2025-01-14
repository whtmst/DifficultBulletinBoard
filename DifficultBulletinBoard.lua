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
            optionFrame:Hide()
        else
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
            mainFrame:Hide()
        else
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

local function updateServerTime()
    local serverTimeString = date("%H:%M:%S")
    DifficultBulletinBoardMainFrame_ServerTime:SetText("Time: " .. serverTimeString)
end

-- Function to handle the update every second
mainFrame:SetScript("OnUpdate", function()
    updateServerTime()
end)

mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("CHAT_MSG_CHANNEL")
mainFrame:RegisterEvent("CHAT_MSG_HARDCORE")
mainFrame:RegisterEvent("CHAT_MSG_SYSTEM");
mainFrame:SetScript("OnEvent", handleEvent)