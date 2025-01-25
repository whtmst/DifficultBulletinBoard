DifficultBulletinBoard = DifficultBulletinBoard or {}
DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}
DifficultBulletinBoardMainFrame = DifficultBulletinBoardMainFrame or {}

local string_gfind = string.gmatch or string.gfind

local mainFrame = DifficultBulletinBoardMainFrame

local chatMessageWidthDelta = 350
local systemMessageWidthDelta = 155

local groupScrollFrame
local groupScrollChild
local professionScrollFrame
local professionScrollChild
local hardcoreScrollFrame
local hardcoreScrollChild

local groupsButton = DifficultBulletinBoardMainFrameGroupsButton
local professionsButton = DifficultBulletinBoardMainFrameProfessionsButton
local hcMessagesButton = DifficultBulletinBoardMainFrameHCMessagesButton

local groupTopicPlaceholders = {}
local professionTopicPlaceholders = {}
local hardcoreTopicPlaceholders = {}

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

-- function to reduce noise in messages and making matching easier
local function replaceSymbolsWithSpace(inputString)
    return string.gsub(inputString, "[,/!%?.]", " ")
end

local function topicPlaceholdersContainsCharacterName(topicPlaceholders, topicName, characterName)
    local topicData = topicPlaceholders[topicName]
    if not topicData then
        print("Nothing in here yet")
        return false, nil
    end

    for index, row in ipairs(topicData) do
        local nameColumn = row.nameButton

        if nameColumn:GetText() == characterName then
            print("Already in there!")
            return true, index
        end
    end

    return false, nil
end

local function getClassIconFromClassName(class) 
    if class == "Druid" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\druid_class_icon"
    elseif class == "Hunter" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\hunter_class_icon"
    elseif class == "Mage" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\mage_class_icon"
    elseif class == "Paladin" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\paladin_class_icon"
    elseif class == "Priest" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\priest_class_icon"
    elseif class == "Rogue" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\rogue_class_icon"
    elseif class == "Shaman" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\shaman_class_icon"
    elseif class == "Warlock" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\warlock_class_icon"
    elseif class == "Warrior" then
        return "Interface\\AddOns\\DifficultBulletinBoard\\icons\\warrior_class_icon"
    else
        return nil
    end
end

-- Updates the specified placeholder for a topic with new name, message, and timestamp,
-- then moves the updated entry to the top of the list, shifting other entries down.
local function UpdateTopicEntryAndPromoteToTop(topicPlaceholders, topic, numberOfPlaceholders, channelName, name, message, index)
    local topicData = topicPlaceholders[topic]

    local timestamp
    if DifficultBulletinBoardVars.timeFormat == "elapsed" then
        timestamp = "00:00"
    else 
        timestamp = date("%H:%M:%S")
    end

    -- Shift all entries down from index 1 to the updated entry's position
    for i = index, 2, -1 do
        topicData[i].nameButton:SetText(topicData[i - 1].nameButton:GetText())
        topicData[i].messageFontString:SetText(topicData[i - 1].messageFontString:GetText())
        topicData[i].timeFontString:SetText(topicData[i - 1].timeFontString:GetText())
        topicData[i].creationTimestamp = topicData[i - 1].creationTimestamp
        topicData[i].icon:SetTexture(topicData[i - 1].icon:GetTexture())
    end

    -- Place the updated entry's data at the top
    topicData[1].nameButton:SetText(name)
    topicData[1].messageFontString:SetText("[" .. channelName .. "] " .. message or "No Message")
    topicData[1].timeFontString:SetText(timestamp)
    topicData[1].creationTimestamp = date("%H:%M:%S")
    local class = DifficultBulletinBoardVars.GetPlayerClassFromDatabase(name)
    print(class)
    topicData[1].icon:SetTexture(getClassIconFromClassName(class))

    -- Update the GameTooltip
    for i = numberOfPlaceholders, 1, -1 do
        local currentFontString = topicData[i]
        local message = currentFontString.messageFontString:GetText()
        local messageFrame = currentFontString.messageFrame

        -- dont show a tooltip if the message equals "-"
        if message ~= nil and message ~= "-" then
            messageFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(messageFrame, "ANCHOR_CURSOR")
                GameTooltip:SetText(message, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)

            messageFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end
end

-- Calculate delta in MM:SS format
local function calculateDelta(creationTimestamp, currentTime)
    local creationInSeconds = timeToSeconds(creationTimestamp)
    local currentInSeconds = timeToSeconds(currentTime)
    local deltaSeconds = currentInSeconds - creationInSeconds

    -- Handle negative delta (e.g., crossing midnight)
    if deltaSeconds < 0 then
        -- Add a day's worth of seconds
        deltaSeconds = deltaSeconds + 86400 
    end

    return secondsToMMSS(deltaSeconds)
end
    



-- Function to add a new entry to the given topic with and shift other entries down
local function AddNewTopicEntryAndShiftOthers(topicPlaceholders, topic, numberOfPlaceholders, channelName, name, message)
    local topicData = topicPlaceholders[topic]
    if not topicData or not topicData[1] then
        print("No placeholders found for topic: " .. topic)
        return
    end

    local timestamp
    if DifficultBulletinBoardVars.timeFormat == "elapsed" then
        timestamp = "00:00"
    else 
        timestamp = date("%H:%M:%S")
    end

    for i = numberOfPlaceholders, 2, -1 do
        -- Copy the data from the previous placeholder to the current one
        local currentFontString = topicData[i]
        local previousFontString = topicData[i - 1]

        -- Update the current placeholder with the previous placeholder's data
        currentFontString.nameButton:SetText(previousFontString.nameButton:GetText())
        currentFontString.messageFontString:SetText(previousFontString.messageFontString:GetText())
        currentFontString.timeFontString:SetText(previousFontString.timeFontString:GetText())
        currentFontString.creationTimestamp = previousFontString.creationTimestamp
        currentFontString.icon:SetTexture(previousFontString.icon:GetTexture())
    end

    -- Update the first placeholder with the new data
    local firstFontString = topicData[1]
    firstFontString.nameButton:SetText(name)
    firstFontString.messageFontString:SetText("[" .. channelName .. "] " .. message)
    firstFontString.timeFontString:SetText(timestamp)
    firstFontString.creationTimestamp = date("%H:%M:%S")
    local class = DifficultBulletinBoardVars.GetPlayerClassFromDatabase(name)
    print(class)
    firstFontString.icon:SetTexture(getClassIconFromClassName(class))

    -- Update the GameTooltip
    for i = numberOfPlaceholders, 1, -1 do
        local currentFontString = topicData[i]
        local message = currentFontString.messageFontString:GetText()
        local messageFrame = currentFontString.messageFrame

        -- dont show a tooltip if the message equals "-"
        if message ~= nil and message ~= "-" then
            messageFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(messageFrame, "ANCHOR_CURSOR")
                GameTooltip:SetText(message, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)

            messageFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end
end

-- Function to update the first placeholder for a given topic with new message, and time and shift other placeholders down
local function AddNewSystemTopicEntryAndShiftOthers(topicPlaceholders, topic, message)
    local topicData = topicPlaceholders[topic]
    if not topicData or not topicData[1] then
        print("No placeholders found for topic: " .. topic)
        return
    end

    local timestamp
    if DifficultBulletinBoardVars.timeFormat == "elapsed" then
        timestamp = "00:00"
    else 
        timestamp = date("%H:%M:%S")
    end

    local index = 0
    for i, _ in ipairs(topicData) do index = i end
        for i = index, 2, -1 do
            -- Copy the data from the previous placeholder to the current one
            local currentFontString = topicData[i]
            local previousFontString = topicData[i - 1]

            -- Update the current placeholder with the previous placeholder's data
            currentFontString.messageFontString:SetText(previousFontString.messageFontString:GetText())
            currentFontString.timeFontString:SetText(previousFontString.timeFontString:GetText())
            currentFontString.creationTimestamp = previousFontString.creationTimestamp
        end

    -- Update the first placeholder with the new data
    local firstFontString = topicData[1]
    firstFontString.messageFontString:SetText(message)
    firstFontString.timeFontString:SetText(timestamp)
    firstFontString.creationTimestamp = date("%H:%M:%S")

    -- Update the GameTooltip
    for i = index, 1, -1 do
        local fontString = topicData[i]
        local currentMessage = fontString.messageFontString:GetText()
        local messageFrame = fontString.messageFrame

        -- dont show a tooltip if the message equals "-"
        if currentMessage ~= nil and currentMessage ~= "-" then
            messageFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(messageFrame, "ANCHOR_CURSOR")
                GameTooltip:SetText(currentMessage, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)

            messageFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end
end

-- Searches the passed topicList for the passed words. If a match is found the topicPlaceholders will be updated
local function analyzeChatMessage(channelName, characterName, chatMessage, words, topicList, topicPlaceholders, numberOfPlaceholders)
    for _, topic in ipairs(topicList) do
        local matchFound = false -- Flag to control breaking out of nested loops

        for _, tag in ipairs(topic.tags) do
            for _, word in ipairs(words) do
                if word == string.lower(tag) then
                    print("Tag '" .. tag .. "' matches Topic: " .. topic.name)
                    local found, index = topicPlaceholdersContainsCharacterName(topicPlaceholders, topic.name, characterName)
                    if found then
                        print("An entry for that character already exists at " .. index)
                        UpdateTopicEntryAndPromoteToTop(topicPlaceholders, topic.name, numberOfPlaceholders, channelName, characterName, chatMessage, index)
                    else
                        print("No entry for that character exists. Creating one...")
                        AddNewTopicEntryAndShiftOthers(topicPlaceholders, topic.name, numberOfPlaceholders, channelName, characterName, chatMessage)
                    end

                    matchFound = true -- Set the flag to true to break out of loops
                    break
                end
            end

            if matchFound then break end
        end
    end
end

function DifficultBulletinBoard.OnChatMessage(arg1, arg2, arg9)
    local chatMessage = arg1
    local characterName = arg2
    local channelName = arg9
    
    local stringWithoutNoise = replaceSymbolsWithSpace(chatMessage)

    print(characterName .. ": " .. stringWithoutNoise)

    local words = DifficultBulletinBoard.SplitIntoLowerWords(stringWithoutNoise)

    analyzeChatMessage(channelName, characterName, chatMessage, words, DifficultBulletinBoardVars.allGroupTopics, groupTopicPlaceholders, DifficultBulletinBoardVars.numberOfGroupPlaceholders)
    analyzeChatMessage(channelName, characterName, chatMessage, words, DifficultBulletinBoardVars.allProfessionTopics, professionTopicPlaceholders, DifficultBulletinBoardVars.numberOfProfessionPlaceholders)
end

-- Searches the passed topicList for the passed words. If a match is found the topicPlaceholders will be updated
local function analyzeSystemMessage(chatMessage, words, topicList, topicPlaceholders)
    for _, topic in ipairs(topicList) do
        local matchFound = false -- Flag to control breaking out of nested loops

        for _, tag in ipairs(topic.tags) do
            for _, word in ipairs(words) do
                if word == string.lower(tag) then
                    print("Tag '" .. tag .. "' matches Topic: " .. topic.name)
                    print("Creating one...")
                    AddNewSystemTopicEntryAndShiftOthers(topicPlaceholders,topic.name, chatMessage)

                    matchFound = true -- Set the flag to true to break out of loops
                    break
                end
            end

            if matchFound then break end
        end
    end
end

function DifficultBulletinBoard.OnSystemMessage(arg1)
    local systemMessage = arg1

    local stringWithoutNoise = replaceSymbolsWithSpace(systemMessage)

    local words = DifficultBulletinBoard.SplitIntoLowerWords(stringWithoutNoise)

    analyzeSystemMessage(systemMessage, words, DifficultBulletinBoardVars.allHardcoreTopics, hardcoreTopicPlaceholders)
end

local function configureTabSwitching()
    local tabs = {
        { button = groupsButton, frame = groupScrollFrame },
        { button = professionsButton, frame = professionScrollFrame },
        { button = hcMessagesButton, frame = hardcoreScrollFrame },
    }

    local function ResetButtonStates()
        for _, tab in ipairs(tabs) do
            tab.button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
            tab.frame:Hide()
        end
    end

    local function ActivateTab(activeTab)
        activeTab.button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Down")
        activeTab.frame:Show()
    end

    for _, tab in ipairs(tabs) do
        local currentTab = tab
        tab.button:SetScript("OnClick", function()
            ResetButtonStates()
            ActivateTab(currentTab)
        end)
    end

    -- set groups as the initial tab
    ActivateTab(tabs[1])
end


local tempChatMessageFrames = {}
local tempChatMessageColumns = {}
local function createTopicListWithNameMessageDateColumns(contentFrame, topicList, topicPlaceholders, numberOfPlaceholders)
    local yOffset = 0

    local chatMessageWidth = mainFrame:GetWidth() - chatMessageWidthDelta

    for _, topic in ipairs(topicList) do
        if topic.selected then
            local header = contentFrame:CreateFontString("$parent_" .. topic.name .. "Header", "OVERLAY", "GameFontNormal")
            header:SetText(topic.name)
            header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
            header:SetWidth(mainFrame:GetWidth())
            header:SetJustifyH("LEFT")
            header:SetTextColor(1, 1, 0)
            header:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

            local topicYOffset = yOffset - 20
            yOffset = topicYOffset - 110

            topicPlaceholders[topic.name] = topicPlaceholders[topic.name] or {FontStrings = {}}

            for i = 1, numberOfPlaceholders do

                local icon = contentFrame:CreateTexture("$parent_Icon", "ARTWORK")
                icon:SetHeight(16)
                icon:SetWidth(16)
                icon:SetPoint("LEFT", contentFrame, "LEFT", 10, topicYOffset - 4)

                local nameButton = CreateFrame("Button", "$parent_" .. topic.name .. "Placeholder" .. i .. "_Name", contentFrame, nil)
                nameButton:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 25, topicYOffset)
                nameButton:SetWidth(150)
                nameButton:SetHeight(10)

                local buttonText = nameButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                buttonText:SetText("-")
                buttonText:SetPoint("LEFT", nameButton, "LEFT", 5, 0)
                buttonText:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
                buttonText:SetTextColor(1, 1, 1)
                nameButton:SetFontString(buttonText)

                nameButton:SetScript("OnEnter", function()
                    buttonText:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
                    buttonText:SetTextColor(1, 1, 0)
                end)

                nameButton:SetScript("OnLeave", function()
                    buttonText:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
                    buttonText:SetTextColor(1, 1, 1)
                end)

                -- Add an example OnClick handler
                nameButton:SetScript("OnClick", function()
                    print("Clicked on: " .. nameButton:GetText())
                    local pressedButton = arg1
                    local targetName = nameButton:GetText()

                    -- dont do anything when its a placeholder
                    if targetName == "-" then return end

                    if pressedButton == "LeftButton" then
                        if IsShiftKeyDown() then
                            print("who")
                            SendWho(targetName)
                        else
                            print("whisp")
                            ChatFrame_OpenChat("/w " .. targetName)
                        end
                    end
                end)

                -- OnClick doesnt support right clicking... so lets just check OnMouseDown instead
                nameButton:SetScript("OnMouseDown", function()
                    local pressedButton = arg1
                    local targetName = nameButton:GetText()

                    -- dont do anything when its a placeholder
                    if targetName == "-" then return end

                    if pressedButton == "RightButton" then
                        ChatFrame_OpenChat("/invite " .. targetName)
                    end
                end)

                local messageFrame = CreateFrame("Button", "$parent_" .. topic.name .. "Placeholder" .. i .. "_MessageFrame", contentFrame)
                messageFrame:SetPoint("TOPLEFT", nameButton, "TOPLEFT", 200, 0)
                messageFrame:SetWidth(chatMessageWidth)
                messageFrame:SetHeight(10)
                messageFrame:EnableMouse(true)

                local messageColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Message", "OVERLAY", "GameFontNormal")
                messageColumn:SetText("-")
                messageColumn:SetPoint("TOPLEFT", nameButton, "TOPRIGHT", 50, 0)
                messageColumn:SetWidth(chatMessageWidth)
                messageColumn:SetHeight(10)
                messageColumn:SetJustifyH("LEFT")
                messageColumn:SetTextColor(1, 1, 1)
                messageColumn:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

                local timeColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Time", "OVERLAY", "GameFontNormal")
                timeColumn:SetText("-")
                timeColumn:SetPoint("TOPLEFT", messageColumn, "TOPRIGHT", 20, 0)
                timeColumn:SetWidth(100)
                timeColumn:SetJustifyH("LEFT")
                timeColumn:SetTextColor(1, 1, 1)
                timeColumn:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

                table.insert(topicPlaceholders[topic.name], {icon = icon, nameButton = nameButton, messageFontString = messageColumn, timeFontString = timeColumn, messageFrame = messageFrame, creationTimestamp = nil})

                table.insert(tempChatMessageFrames, messageFrame)
                table.insert(tempChatMessageColumns, messageColumn)

                topicYOffset = topicYOffset - 18
            end

            yOffset = topicYOffset - 10
        end
    end
end

local tempSystemMessageFrames = {}
local tempSystemMessageColumns = {}
-- function to create the placeholders and font strings for a topic
local function createTopicListWithMessageDateColumns(contentFrame, topicList, topicPlaceholders, numberOfPlaceholders)
    -- initial Y-offset for the first header and placeholder
    local yOffset = 0

    local systemMessageWidth = mainFrame:GetWidth() - systemMessageWidthDelta

    for _, topic in ipairs(topicList) do
        if topic.selected then
            local header = contentFrame:CreateFontString("$parent_" .. topic.name ..  "Header", "OVERLAY", "GameFontNormal")
            header:SetText(topic.name)
            header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
            header:SetWidth(mainFrame:GetWidth())
            header:SetJustifyH("LEFT")
            header:SetTextColor(1, 1, 0)
            header:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

            -- Store the header Y offset for the current topic
            local topicYOffset = yOffset - 20 -- space between header and first placeholder
            yOffset = topicYOffset - 110 -- space between headers

            topicPlaceholders[topic.name] = topicPlaceholders[topic.name] or {FontStrings = {}}

            for i = 1, numberOfPlaceholders do

                -- Create an invisible button to act as a parent
                local messageFrame = CreateFrame("Button", "$parent_" .. topic.name .. "Placeholder" .. i .. "_MessageFrame", contentFrame)
                messageFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 15, topicYOffset)
                messageFrame:SetWidth(846)
                messageFrame:SetHeight(10)
                messageFrame:EnableMouse(true)

                -- create Message column
                local messageColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Message", "OVERLAY", "GameFontNormal")
                messageColumn:SetText("-")
                messageColumn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 15, topicYOffset)
                messageColumn:SetWidth(systemMessageWidth)
                messageColumn:SetHeight(10)
                messageColumn:SetJustifyH("LEFT")
                messageColumn:SetTextColor(1, 1, 1)
                messageColumn:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

                -- Create Time column
                local timeColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Time", "OVERLAY", "GameFontNormal")
                timeColumn:SetText("-")
                timeColumn:SetPoint("TOPLEFT", messageColumn, "TOPRIGHT", 20, 0)
                timeColumn:SetWidth(100)
                timeColumn:SetJustifyH("LEFT")
                timeColumn:SetTextColor(1, 1, 1)
                timeColumn:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

                table.insert( topicPlaceholders[topic.name], {nameButton = nil, messageFontString = messageColumn, timeFontString = timeColumn, messageFrame = messageFrame, creationTimestamp = nil})

                table.insert(tempSystemMessageFrames, messageFrame)
                table.insert(tempSystemMessageColumns, messageColumn)

                -- Increment the Y-offset for the next placeholder
                topicYOffset = topicYOffset - 18 -- space between placeholders
            end

            -- After the placeholders, adjust the main yOffset for the next topic
            yOffset = topicYOffset - 10 -- space between topics
        end
    end
end

local function createScrollFrameForMainFrame(scrollFrameName)
    -- Create the ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", scrollFrameName, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -80)
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -26, 20)

    -- Create the ScrollChild (content frame)
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetHeight(1)
    scrollChild:SetWidth(980)

    -- Attach the ScrollChild to the ScrollFrame
    scrollFrame:SetScrollChild(scrollChild)

    -- Default Hide, because the default tab shows the correct frame later
    scrollFrame:Hide()

    return scrollFrame, scrollChild
end

function DifficultBulletinBoardMainFrame.InitializeMainFrame()
    --call it once before OnUpdate so the time doesnt just magically appear
    DifficultBulletinBoardMainFrame.UpdateServerTime()

    groupScrollFrame, groupScrollChild = createScrollFrameForMainFrame("DifficultBulletinBoardMainFrame_Group_ScrollFrame")
    createTopicListWithNameMessageDateColumns(groupScrollChild, DifficultBulletinBoardVars.allGroupTopics, groupTopicPlaceholders, DifficultBulletinBoardVars.numberOfGroupPlaceholders)
    professionScrollFrame, professionScrollChild = createScrollFrameForMainFrame("DifficultBulletinBoardMainFrame_Profession_ScrollFrame")
    createTopicListWithNameMessageDateColumns(professionScrollChild, DifficultBulletinBoardVars.allProfessionTopics, professionTopicPlaceholders, DifficultBulletinBoardVars.numberOfProfessionPlaceholders)
    hardcoreScrollFrame, hardcoreScrollChild = createScrollFrameForMainFrame("DifficultBulletinBoardMainFrame_Hardcore_ScrollFrame")
    createTopicListWithMessageDateColumns(hardcoreScrollChild, DifficultBulletinBoardVars.allHardcoreTopics, hardcoreTopicPlaceholders, DifficultBulletinBoardVars.numberOfHardcorePlaceholders)

    -- add topic group tab switching
    configureTabSwitching()
end

mainFrame:SetScript("OnSizeChanged", function()
    local chatMessageWidth = mainFrame:GetWidth() - chatMessageWidthDelta
    for _, msgFrame in ipairs(tempChatMessageFrames) do
        msgFrame:SetWidth(chatMessageWidth)
    end

    for _, msgColumn in ipairs(tempChatMessageColumns) do
        msgColumn:SetWidth(chatMessageWidth)
    end

    local systemMessageWidth = mainFrame:GetWidth() - systemMessageWidthDelta
    for _, msgFrame in ipairs(tempSystemMessageFrames) do
        msgFrame:SetWidth(systemMessageWidth)
    end

    for _, msgColumn in ipairs(tempSystemMessageColumns) do
        msgColumn:SetWidth(systemMessageWidth)
    end
end)


function DifficultBulletinBoardMainFrame.UpdateServerTime()
    if DifficultBulletinBoardVars.serverTimePosition == "disabled" then
        return
    end

    local serverTimeString = date("%H:%M:%S") -- Format server time

    if DifficultBulletinBoardVars.serverTimePosition == "right-of-tabs" then
        DifficultBulletinBoardMainFrameServerTimeRight:SetText("Time: " .. serverTimeString)
    end

    if DifficultBulletinBoardVars.serverTimePosition == "top-left" then
        DifficultBulletinBoardMainFrameServerTimeTopLeft:SetText("Time: " .. serverTimeString)
    end
end

-- Helper function to convert HH:MM:SS to seconds
local function timeToSeconds(timeString)
    --idk how else to do it :/ just loop over and return the first match
    for hours, minutes, seconds in string_gfind(timeString, "(%d+):(%d+):(%d+)") do
        return (tonumber(hours) * 3600) + (tonumber(minutes) * 60) + tonumber(seconds)
    end
end
    
-- Helper function to format seconds into MM:SS
local function secondsToMMSS(totalSeconds)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds - math.floor(totalSeconds / 60) * 60

    -- Return "99:59" if minutes exceed 99
    if minutes > 99 then
        return "99:59"
    end

    return string.format("%02d:%02d", minutes, seconds)
end

-- Calculate delta in MM:SS format
local function calculateDelta(creationTimestamp, currentTime)
    local creationInSeconds = timeToSeconds(creationTimestamp)
    local currentInSeconds = timeToSeconds(currentTime)
    local deltaSeconds = currentInSeconds - creationInSeconds

    -- Handle negative delta (e.g., crossing midnight)
    if deltaSeconds < 0 then
        deltaSeconds = deltaSeconds + 86400 -- Add a day's worth of seconds
    end

    return secondsToMMSS(deltaSeconds)
end

function DifficultBulletinBoardMainFrame.UpdateElapsedTimes()
    for topicName, entries in pairs(groupTopicPlaceholders) do
        for _, entry in ipairs(entries) do
            if entry and entry.timeFontString and  entry.timeFontString:GetText() ~= "-" then
                local delta = calculateDelta(entry.creationTimestamp,  date("%H:%M:%S"))
                entry.timeFontString:SetText(delta)
            end
        end
    end

    for topicName, entries in pairs(professionTopicPlaceholders) do
        for _, entry in ipairs(entries) do
            if entry and entry.timeFontString and  entry.timeFontString:GetText() ~= "-" then
                local delta = calculateDelta(entry.creationTimestamp,  date("%H:%M:%S"))
                entry.timeFontString:SetText(delta)
            end
        end
    end

    for topicName, entries in pairs(hardcoreTopicPlaceholders) do
        for _, entry in ipairs(entries) do
            if entry and entry.timeFontString and  entry.timeFontString:GetText() ~= "-" then
                local delta = calculateDelta(entry.creationTimestamp,  date("%H:%M:%S"))
                entry.timeFontString:SetText(delta)
            end
        end
    end
end