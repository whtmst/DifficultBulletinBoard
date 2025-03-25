-- DifficultBulletinBoardMainFrame.lua
-- Main frame implementation for Difficult Bulletin Board
-- Handles all UI display, filtering, and message processing for the main window

DifficultBulletinBoard = DifficultBulletinBoard or {}
DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}
DifficultBulletinBoardMainFrame = DifficultBulletinBoardMainFrame or {}

local debugMode = false  -- Default to false
local function debugPrint(string)
    if debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("[DBB] " .. string, 1, 0.7, 0.2)
    end
end

local string_gfind = string.gmatch or string.gfind

local mainFrame = DifficultBulletinBoardMainFrame

local chatMessageWidthDelta = 200
local systemMessageWidthDelta = 155

local groupScrollFrame
local groupScrollChild
local groupsLogsScrollFrame
local groupsLogsScrollChild
local professionScrollFrame
local professionScrollChild
local hardcoreScrollFrame
local hardcoreScrollChild

local groupsButton = DifficultBulletinBoardMainFrameGroupsButton
local groupsLogsButton = DifficultBulletinBoardMainFrameGroupsLogsButton
local professionsButton = DifficultBulletinBoardMainFrameProfessionsButton
local hcMessagesButton = DifficultBulletinBoardMainFrameHCMessagesButton

local groupTopicPlaceholders = {}
local groupsLogsPlaceholders = {} -- New container for Groups Logs entries
local professionTopicPlaceholders = {}
local hardcoreTopicPlaceholders = {}

-- Store current filter text globally
local currentGroupsLogsFilter = ""

-- Add global reference to the search frame
local groupsLogsSearchFrame = nil

-- Number of entries to show in the Groups Logs tab
local MAX_GROUPS_LOGS_ENTRIES = 50

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

-- Apply filter to Groups Logs entries
local function applyGroupsLogsFilter(searchText)
    -- Only filter if we have entries to filter
    if groupsLogsPlaceholders and groupsLogsPlaceholders["Group Logs"] then
        -- Process each entry
        for _, entry in ipairs(groupsLogsPlaceholders["Group Logs"]) do
            -- Check if this is a valid entry with name and message
            if entry and entry.nameButton and entry.messageFontString then
                local name = entry.nameButton:GetText() or ""
                local message = entry.messageFontString:GetText() or ""
                
                -- Skip placeholders
                if name == "-" or message == "-" then
                    -- Do nothing for placeholder entries
                else
                    -- If no search text, show everything
                    if searchText == "" then
                        entry.nameButton:SetAlpha(1.0)
                        entry.messageFontString:SetAlpha(1.0)
                        entry.timeFontString:SetAlpha(1.0)
                        if entry.icon then entry.icon:SetAlpha(1.0) end
                    else
                        -- Prepare terms for comma-separated search
                        local terms = {}
                        for term in string_gfind(searchText, "[^,]+") do
                            term = string.gsub(term, "^%s*(.-)%s*$", "%1") -- Trim whitespace
                            table.insert(terms, term)
                        end
                        
                        -- Convert entry text to lowercase
                        local lowerName = string.lower(name)
                        local lowerMessage = string.lower(message)
                        
                        -- Check all search terms
                        local matches = false
                        for _, term in ipairs(terms) do
                            if term ~= "" and 
                              (string.find(lowerName, term, 1, true) or 
                               string.find(lowerMessage, term, 1, true)) then
                                matches = true
                                break
                            end
                        end
                        
                        -- Set visibility based on match result
                        if matches then
                            entry.nameButton:SetAlpha(1.0)
                            entry.messageFontString:SetAlpha(1.0)
                            entry.timeFontString:SetAlpha(1.0)
                            if entry.icon then entry.icon:SetAlpha(1.0) end
                        else
                            entry.nameButton:SetAlpha(0.25)
                            entry.messageFontString:SetAlpha(0.25)
                            entry.timeFontString:SetAlpha(0.25)
                            if entry.icon then entry.icon:SetAlpha(0.25) end
                        end
                    end
                end
            end
        end
    end
end

-- Function to reduce noise in messages and making matching easier
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
    -- Add this line to update hit rect for updated name
    topicData[1].nameButton:SetHitRectInsets(0, -45, 0, 0)
    
    topicData[1].messageFontString:SetText("[" .. channelName .. "] " .. message or "No Message")
    topicData[1].timeFontString:SetText(timestamp)
    topicData[1].creationTimestamp = date("%H:%M:%S")
    local class = DifficultBulletinBoardVars.GetPlayerClassFromDatabase(name)
    print(class)
    topicData[1].icon:SetTexture(getClassIconFromClassName(class))

    -- Update the GameTooltip
    for i = numberOfPlaceholders, 1, -1 do
        local currentFontString = topicData[i]
        local messageFrame = currentFontString.messageFrame
        local messageFontString = currentFontString.messageFontString

        -- Always get the current message text when the tooltip is shown
        messageFrame:SetScript("OnEnter", function()
            local currentMessage = messageFontString:GetText()
            if currentMessage ~= nil and currentMessage ~= "-" then
                GameTooltip:SetOwner(messageFrame, "ANCHOR_CURSOR")
                GameTooltip:SetText(currentMessage, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)

        messageFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    -- Apply filter if this is a Groups Logs entry
    if topic == "Group Logs" and topicPlaceholders == groupsLogsPlaceholders then
        applyGroupsLogsFilter(currentGroupsLogsFilter)
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
    -- Add this line to update hit rect for the new name
    firstFontString.nameButton:SetHitRectInsets(0, -45, 0, 0)
    
    firstFontString.messageFontString:SetText("[" .. channelName .. "] " .. message)
    firstFontString.timeFontString:SetText(timestamp)
    firstFontString.creationTimestamp = date("%H:%M:%S")
    local class = DifficultBulletinBoardVars.GetPlayerClassFromDatabase(name)
    print(class)
    firstFontString.icon:SetTexture(getClassIconFromClassName(class))

    -- Update the GameTooltip
    for i = numberOfPlaceholders, 1, -1 do
        local currentFontString = topicData[i]
        local messageFrame = currentFontString.messageFrame
        local messageFontString = currentFontString.messageFontString

        -- Always get the current message text when the tooltip is shown
        messageFrame:SetScript("OnEnter", function()
            local currentMessage = messageFontString:GetText()
            if currentMessage ~= nil and currentMessage ~= "-" then
                GameTooltip:SetOwner(messageFrame, "ANCHOR_CURSOR")
                GameTooltip:SetText(currentMessage, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)

        messageFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    -- Apply filter if this is a Groups Logs entry
    if topic == "Group Logs" and topicPlaceholders == groupsLogsPlaceholders then
        applyGroupsLogsFilter(currentGroupsLogsFilter)
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
        local messageFrame = fontString.messageFrame
        local messageFontString = fontString.messageFontString

        -- Always get the current message text when the tooltip is shown
        messageFrame:SetScript("OnEnter", function()
            local currentMessage = messageFontString:GetText()
            if currentMessage ~= nil and currentMessage ~= "-" then
                GameTooltip:SetOwner(messageFrame, "ANCHOR_CURSOR")
                GameTooltip:SetText(currentMessage, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)

        messageFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
end

-- Function to check if a character name already exists in the Groups Logs
local function groupsLogsContainsCharacterName(characterName)
    if not groupsLogsPlaceholders["Group Logs"] then
        return false, nil
    end
    
    local entries = groupsLogsPlaceholders["Group Logs"]
    for index, entry in ipairs(entries) do
        if entry.nameButton and entry.nameButton:GetText() == characterName then
            return true, index
        end
    end
    
    return false, nil
end

-- Searches the passed topicList for the passed words. If a match is found the topicPlaceholders will be updated
local function analyzeChatMessage(channelName, characterName, chatMessage, words, topicList, topicPlaceholders, numberOfPlaceholders)
    local isAnyMatch = false
    local isGroupMatch = false
    
    for _, topic in ipairs(topicList) do
        if topic.selected then
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
                        isAnyMatch = true -- Set the outer function result
                        
                        -- If this is a group topic, mark it
                        if topicList == DifficultBulletinBoardVars.allGroupTopics then
                            isGroupMatch = true
                        end
                        
                        break
                    end
                end

                if matchFound then break end
            end
            
            if matchFound then break end
        end
    end
    
    return isGroupMatch == true and isGroupMatch or isAnyMatch
end

-- Searches the passed topicList for the passed words. If a match is found the topicPlaceholders will be updated
local function analyzeSystemMessage(chatMessage, words, topicList, topicPlaceholders)
    local isAnyMatch = false
    
    for _, topic in ipairs(topicList) do
        if topic.selected then
            local matchFound = false -- Flag to control breaking out of nested loops

            for _, tag in ipairs(topic.tags) do
                for _, word in ipairs(words) do
                    if word == string.lower(tag) then
                        print("Tag '" .. tag .. "' matches Topic: " .. topic.name)
                        print("Creating one...")
                        AddNewSystemTopicEntryAndShiftOthers(topicPlaceholders, topic.name, chatMessage)

                        matchFound = true -- Set the flag to true to break out of loops
                        isAnyMatch = true -- Set the outer function result
                        break
                    end
                end

                if matchFound then break end
            end
            
            if matchFound then break end
        end
    end
    
    return isAnyMatch
end

-- Process chat messages and add matched content to the appropriate sections
function DifficultBulletinBoard.OnChatMessage(arg1, arg2, arg9)
    local chatMessage = arg1
    local characterName = arg2
    local channelName = arg9
    
    -- Check if message is in the blacklist
    if DifficultBulletinBoardSavedVariables.messageBlacklist and 
       DifficultBulletinBoardSavedVariables.messageBlacklist[chatMessage] then
        debugPrint("Filtering blacklisted message: " .. string.sub(chatMessage, 1, 40) .. "...")
        return true -- Skip this message as it's blacklisted
    end  -- Fixed: changed closing curly brace '}' to proper 'end' statement
    
    local stringWithoutNoise = replaceSymbolsWithSpace(chatMessage)

    print(characterName .. ": " .. stringWithoutNoise)

    local words = DifficultBulletinBoard.SplitIntoLowerWords(stringWithoutNoise)

    -- Process group topics and check if it's a group-related message
    local isGroupMessage = analyzeChatMessage(channelName, characterName, chatMessage, words, 
                         DifficultBulletinBoardVars.allGroupTopics, 
                         groupTopicPlaceholders, 
                         DifficultBulletinBoardVars.numberOfGroupPlaceholders)
    
    -- If it's a group message, add it to the Groups Logs with duplicate checking
    if isGroupMessage then
        local found, index = groupsLogsContainsCharacterName(characterName)
        if found then
            -- Update the existing entry and move it to the top
            local entries = groupsLogsPlaceholders["Group Logs"]
            
            -- Get timestamp
            local timestamp
            if DifficultBulletinBoardVars.timeFormat == "elapsed" then
                timestamp = "00:00"
            else 
                timestamp = date("%H:%M:%S")
            end
            
            -- Shift entries down from index to top
            for i = index, 2, -1 do
                entries[i].nameButton:SetText(entries[i-1].nameButton:GetText())
                entries[i].messageFontString:SetText(entries[i-1].messageFontString:GetText())
                entries[i].timeFontString:SetText(entries[i-1].timeFontString:GetText())
                entries[i].creationTimestamp = entries[i-1].creationTimestamp
                entries[i].icon:SetTexture(entries[i-1].icon:GetTexture())
            end
            
            -- Update top entry
            entries[1].nameButton:SetText(characterName)
            entries[1].messageFontString:SetText("[" .. channelName .. "] " .. chatMessage)
            entries[1].timeFontString:SetText(timestamp)
            entries[1].creationTimestamp = date("%H:%M:%S")
            local class = DifficultBulletinBoardVars.GetPlayerClassFromDatabase(characterName)
            entries[1].icon:SetTexture(getClassIconFromClassName(class))
            
            -- Apply the current filter to the updated entries
            applyGroupsLogsFilter(currentGroupsLogsFilter)
        else
            -- Add as new entry
            AddNewTopicEntryAndShiftOthers(groupsLogsPlaceholders, "Group Logs", MAX_GROUPS_LOGS_ENTRIES, channelName, characterName, chatMessage)
        end
    end

    -- Process profession topics as usual
    local isProfessionMessage = analyzeChatMessage(channelName, characterName, chatMessage, words, 
                      DifficultBulletinBoardVars.allProfessionTopics, 
                      professionTopicPlaceholders, 
                      DifficultBulletinBoardVars.numberOfProfessionPlaceholders)
    
    -- Return true if any match was found
    return isGroupMessage or isProfessionMessage
end

function DifficultBulletinBoard.OnSystemMessage(arg1)
    local systemMessage = arg1

    local stringWithoutNoise = replaceSymbolsWithSpace(systemMessage)

    local words = DifficultBulletinBoard.SplitIntoLowerWords(stringWithoutNoise)

    local isMatched = analyzeSystemMessage(systemMessage, words, DifficultBulletinBoardVars.allHardcoreTopics, hardcoreTopicPlaceholders)
    
    return isMatched
end

-- This function configures the tab switching behavior for the main frame
local function configureTabSwitching()
    -- Define all tabs with their buttons and scroll frames
    local tabs = {
        { button = groupsButton, frame = groupScrollFrame, isActive = true },
        { button = groupsLogsButton, frame = groupsLogsScrollFrame, isActive = false },
        { button = professionsButton, frame = professionScrollFrame, isActive = false },
        { button = hcMessagesButton, frame = hardcoreScrollFrame, isActive = false },
    }

    local function UpdateButtonState(tab)
        local button = tab.button
        local textElement = getglobal(button:GetName().."_Text")
        
        if tab.isActive then
            button:SetBackdropColor(0.25, 0.25, 0.3, 1.0) -- Darker color for active tab
            textElement:SetTextColor(1.0, 1.0, 1.0, 1.0) -- Brighter text for active tab
        elseif tab.isHovered then
            button:SetBackdropColor(0.18, 0.18, 0.2, 1.0) -- Hover color
            textElement:SetTextColor(0.9, 0.9, 1.0, 1.0) -- Hover text color
        else
            button:SetBackdropColor(0.15, 0.15, 0.15, 1.0) -- Normal color
            textElement:SetTextColor(0.9, 0.9, 0.9, 1.0) -- Normal text color
        end
    end

    local function ResetButtonStates()
        for _, tab in ipairs(tabs) do
            tab.isActive = false
            tab.frame:Hide()
            UpdateButtonState(tab)
        end
    end

    local function ActivateTab(activeTab)
        activeTab.isActive = true
        activeTab.frame:Show()
        UpdateButtonState(activeTab)
    end

    for _, tab in ipairs(tabs) do
        local currentTab = tab
        tab.isHovered = false

        -- Set up hover effects
        tab.button:SetScript("OnEnter", function()
            currentTab.isHovered = true
            UpdateButtonState(currentTab)
        end)

        tab.button:SetScript("OnLeave", function()
            currentTab.isHovered = false
            UpdateButtonState(currentTab)
        end)

        -- Set up click handler
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

-- Create topic list with name, message, and date columns
local function createTopicListWithNameMessageDateColumns(
  contentFrame,
  topicList,
  topicPlaceholders,
  numberOfPlaceholders
)
  local yOffset = 0

  local chatMessageWidth = mainFrame:GetWidth() - chatMessageWidthDelta

  for _, topic in ipairs(topicList) do
   if topic.selected then
    local header =
     contentFrame:CreateFontString(
      "$parent_" .. topic.name .. "Header",
      "OVERLAY",
      "GameFontNormal"
     )
    header:SetText(topic.name)
    header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, yOffset)
    header:SetWidth(mainFrame:GetWidth())
    header:SetJustifyH("LEFT")
    header:SetTextColor(0.9, 0.9, 1.0, 1.0)
    header:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

    local topicYOffset = yOffset - 20
    yOffset = topicYOffset - 110

    topicPlaceholders[topic.name] = topicPlaceholders[topic.name] or {
     FontStrings = {},
    }

    for i = 1, numberOfPlaceholders do
     local icon = contentFrame:CreateTexture("$parent_Icon", "ARTWORK")
     icon:SetHeight(14)
     icon:SetWidth(14)
     icon:SetPoint("LEFT", contentFrame, "LEFT", 0, topicYOffset - 4)

     local nameButton =
      CreateFrame(
       "Button",
       "$parent_" .. topic.name .. "Placeholder" .. i .. "_Name",
       contentFrame,
       nil
      )
     nameButton:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, topicYOffset)
     nameButton:SetWidth(40)
     nameButton:SetHeight(10)
     
     -- Add this line to extend clickable area to the right
     nameButton:SetHitRectInsets(0, -45, 0, 0)

     local buttonText = nameButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
     buttonText:SetText("-")
     buttonText:SetPoint("LEFT", nameButton, "LEFT", 5, 0)
     buttonText:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
     buttonText:SetTextColor(1, 1, 1)
     nameButton:SetFontString(buttonText)

     nameButton:SetScript("OnEnter", function()
      buttonText:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
      buttonText:SetTextColor(0.9, 0.9, 1.0)
     end)

     nameButton:SetScript("OnLeave", function()
      buttonText:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
      buttonText:SetTextColor(1, 1, 1)
     end)

     local messageFrame =
      CreateFrame(
       "Button",
       "$parent_" .. topic.name .. "Placeholder" .. i .. "_MessageFrame",
       contentFrame
      )
     messageFrame:SetPoint("TOPLEFT", nameButton, "TOPLEFT", 90, 0)
     messageFrame:SetWidth(chatMessageWidth)
     messageFrame:SetHeight(10)
     messageFrame:EnableMouse(true)

     local messageColumn =
      contentFrame:CreateFontString(
       "$parent_" .. topic.name .. "Placeholder" .. i .. "_Message",
       "OVERLAY",
       "GameFontNormal"
      )
     messageColumn:SetText("-")
     messageColumn:SetPoint("TOPLEFT", nameButton, "TOPRIGHT", 50, 0)
     messageColumn:SetWidth(chatMessageWidth)
     messageColumn:SetHeight(10)
     messageColumn:SetJustifyH("LEFT")
     messageColumn:SetTextColor(1, 1, 1)
     messageColumn:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

     local timeColumn =
      contentFrame:CreateFontString(
       "$parent_" .. topic.name .. "Placeholder" .. i .. "_Time",
       "OVERLAY",
       "GameFontNormal"
      )
     timeColumn:SetText("-")
     timeColumn:SetPoint("TOPLEFT", messageColumn, "TOPRIGHT", 20, 0)
     timeColumn:SetWidth(100)
     timeColumn:SetJustifyH("LEFT")
     timeColumn:SetTextColor(1, 1, 1)
     timeColumn:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

     -- Store reference to message column directly in the button for easy access
     nameButton.messageFontString = messageColumn

     nameButton:SetScript("OnClick", function()
      print("Clicked on: " .. nameButton:GetText())
      local pressedButton = arg1
      local targetName = nameButton:GetText()

      -- dont do anything when its a placeholder
      if targetName == "-" then
       return
      end

      if pressedButton == "LeftButton" then
       if IsControlKeyDown() then
        -- Get the message text using the direct reference
        local messageText = this.messageFontString:GetText()
        if messageText and messageText ~= "-" then
         -- Extract the raw message by removing the channel prefix
         -- Using string.find and string.sub instead of string.match
         local rawMessage = messageText
         local startPos, endPos = string.find(messageText, "%[.*%] ")
         if startPos and endPos then
            rawMessage = string.sub(messageText, endPos + 1)
         end
         
         DifficultBulletinBoardSavedVariables.messageBlacklist[rawMessage] = true

         -- Truncate message for display
         local truncatedMessage =
          string.sub(rawMessage, 1, 40) ..
          (string.len(rawMessage) > 40 and "..." or "")

         DEFAULT_CHAT_FRAME:AddMessage(
          "|cFFFFCC00[DBB]|r Added: " .. truncatedMessage .. " to blacklist."
         )

         -- Refresh the blacklist panel if it's open
         if DifficultBulletinBoardBlacklistFrame:IsShown() then
          DifficultBulletinBoardBlacklistFrame.RefreshBlacklist()
         end
        end
       elseif IsShiftKeyDown() then
        print("who")
        SendWho(targetName)
       else
        print("whisp")
        ChatFrame_OpenChat("/w " .. targetName)
       end
      end
     end)

     -- OnClick doesnt support right clicking... so lets just check OnMouseDown
     -- instead
     nameButton:SetScript("OnMouseDown", function()
      local pressedButton = arg1
      local targetName = nameButton:GetText()

      -- dont do anything when its a placeholder
      if targetName == "-" then
       return
      end

      if pressedButton == "RightButton" then
       ChatFrame_OpenChat("/invite " .. targetName)
      end
     end)

     table.insert(
      topicPlaceholders[topic.name],
      {
       icon = icon,
       nameButton = nameButton,
       messageFontString = messageColumn,
       timeFontString = timeColumn,
       messageFrame = messageFrame,
       creationTimestamp = nil,
      }
     )

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

-- Function to create the placeholders and font strings for a topic
local function createTopicListWithMessageDateColumns(contentFrame, topicList, topicPlaceholders, numberOfPlaceholders)
    -- initial Y-offset for the first header and placeholder
    local yOffset = 0

    local systemMessageWidth = mainFrame:GetWidth() - systemMessageWidthDelta

    for _, topic in ipairs(topicList) do
        if topic.selected then
            local header = contentFrame:CreateFontString("$parent_" .. topic.name ..  "Header", "OVERLAY", "GameFontNormal")
            header:SetText(topic.name)
            header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, yOffset)  -- Changed from 10 to 5
            header:SetWidth(mainFrame:GetWidth())
            header:SetJustifyH("LEFT")
            header:SetTextColor(0.9, 0.9, 1.0, 1.0)
            header:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)

            -- Store the header Y offset for the current topic
            local topicYOffset = yOffset - 20 -- space between header and first placeholder
            yOffset = topicYOffset - 110 -- space between headers

            topicPlaceholders[topic.name] = topicPlaceholders[topic.name] or {FontStrings = {}}

            for i = 1, numberOfPlaceholders do

                -- Create an invisible button to act as a parent
                local messageFrame = CreateFrame("Button", "$parent_" .. topic.name .. "Placeholder" .. i .. "_MessageFrame", contentFrame)
                messageFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, topicYOffset)  -- Changed from 15 to 8
                messageFrame:SetWidth(846)
                messageFrame:SetHeight(10)
                messageFrame:EnableMouse(true)

                -- create Message column
                local messageColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Message", "OVERLAY", "GameFontNormal")
                messageColumn:SetText("-")
                messageColumn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, topicYOffset)  -- Changed from 15 to 8
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

                table.insert(topicPlaceholders[topic.name], {nameButton = nil, messageFontString = messageColumn, timeFontString = timeColumn, messageFrame = messageFrame, creationTimestamp = nil})

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

-- Create scroll frame with hidden arrows and modern styling
local function createScrollFrameForMainFrame(scrollFrameName)
    -- Create the ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", scrollFrameName, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors with reduced left margin (50% less)
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -55)  -- Changed from 30 to 15
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -26, 20)

    -- Get the scroll bar reference
    local scrollBar = getglobal(scrollFrame:GetName().."ScrollBar")
    
    -- Get references to the scroll buttons
    local upButton = getglobal(scrollBar:GetName().."ScrollUpButton")
    local downButton = getglobal(scrollBar:GetName().."ScrollDownButton")
    
    -- Completely remove the scroll buttons from the layout
    upButton:SetHeight(0.001)
    upButton:SetWidth(0.001)
    upButton:SetAlpha(0)
    upButton:EnableMouse(false)
    upButton:ClearAllPoints()
    upButton:SetPoint("TOP", scrollBar, "TOP", 0, 1000)
    
    -- Same for down button
    downButton:SetHeight(0.001)
    downButton:SetWidth(0.001)
    downButton:SetAlpha(0)
    downButton:EnableMouse(false)
    downButton:ClearAllPoints()
    downButton:SetPoint("BOTTOM", scrollBar, "BOTTOM", 0, -1000)
    
    -- Adjust scroll bar position
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 16, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 16, 0)
    
    -- Style the scroll bar to be slimmer
    scrollBar:SetWidth(8)
    
    -- Set up the thumb texture with slightly blue-tinted colors
    local thumbTexture = scrollBar:GetThumbTexture()
    thumbTexture:SetWidth(8)
    thumbTexture:SetHeight(50)
    thumbTexture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    thumbTexture:SetGradientAlpha("VERTICAL", 0.504, 0.504, 0.576, 0.7, 0.648, 0.648, 0.72, 0.9)
    
    -- Style the scroll bar track with darker background
    scrollBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = nil,
        tile = true, tileSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    scrollBar:SetBackdropColor(0.072, 0.072, 0.108, 0.3)

    -- Create the ScrollChild (content frame)
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetHeight(1)
    scrollChild:SetWidth(980)

    -- Attach the ScrollChild to the ScrollFrame
    scrollFrame:SetScrollChild(scrollChild)

    -- Default Hide, because the default tab shows the correct frame later
    scrollFrame:Hide()

    -- Use both mouse wheel directions for scrolling
    scrollFrame:SetScript("OnMouseWheel", function()
        local scrollBar = getglobal(this:GetName().."ScrollBar")
        local currentValue = scrollBar:GetValue()
        
        if arg1 > 0 then
            scrollBar:SetValue(currentValue - (scrollBar:GetHeight() / 2))
        else
            scrollBar:SetValue(currentValue + (scrollBar:GetHeight() / 2))
        end
    end)

    return scrollFrame, scrollChild
end

-- Function to create a search box for the Groups Logs tab
-- Places the search box next to the "Group Logs" headline with dynamic sizing
local function createGroupsLogsSearchBox()
    -- Wait until the Groups Logs scroll frame exists
    if not groupsLogsScrollFrame then
        return nil
    end
    
    -- Create a temporary font string to calculate the width of "Group Logs"
    -- with the current font size
    local tempFontString = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tempFontString:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
    tempFontString:SetText("Group Logs")
    local headerWidth = tempFontString:GetStringWidth()
    tempFontString:Hide()
    
    -- Position settings
    local xOffset = headerWidth + 20  -- Horizontal position after header
    local yOffset = 1                -- Vertical position (negative moves down)
    
    -- Create a frame to hold the search box
    local frame = CreateFrame("Frame", "DifficultBulletinBoardMainFrame_GroupsLogs_SearchFrame", groupsLogsScrollChild)
    
    -- Position based on calculated width and anchor right side with 30px margin
    frame:SetPoint("TOPLEFT", groupsLogsScrollChild, "TOPLEFT", xOffset, yOffset)
    frame:SetPoint("RIGHT", groupsLogsScrollFrame, "RIGHT", 0, 0)
    frame:SetHeight(16)
    
    -- Ensure the frame is visible above the scroll content
    frame:SetFrameLevel(groupsLogsScrollChild:GetFrameLevel() + 5)

    -- Create a backdrop for the search box
    local searchBackdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    }

    -- Create the search box
    local searchBox = CreateFrame("EditBox", "DifficultBulletinBoardMainFrame_GroupsLogs_SearchBox", frame)
    searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    searchBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    searchBox:SetBackdrop(searchBackdrop)
    searchBox:SetBackdropColor(0.9, 0.9, 1.0, 0.07)
    -- Set border color to a dimmer version of the headline color
    searchBox:SetBackdropBorderColor(0.9, 0.9, 1.0, 1.0)
    searchBox:SetText("")
    searchBox:SetFontObject(GameFontHighlight)
    searchBox:SetTextColor(0.9, 0.9, 1.0, 1.0)
    searchBox:SetAutoFocus(false)
    searchBox:SetJustifyH("LEFT")
    
    -- Add 3px padding on the left side of text
    searchBox:SetTextInsets(3, 0, 0, 0)

    -- Add placeholder text
    local placeholderText = searchBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    placeholderText:SetPoint("LEFT", searchBox, "LEFT", 6, 0)
    placeholderText:SetText("Filter (separate terms with commas)...")
    placeholderText:SetTextColor(0.5, 0.5, 0.5, 0.7)

    -- Track focus state with a variable
    searchBox.hasFocus = false

    -- Add placeholder handlers
    searchBox:SetScript("OnEditFocusGained", function()
        this:SetBackdropBorderColor(0.9, 0.9, 1.0, 1.0) -- Headline color
        this.hasFocus = true
        placeholderText:Hide() -- Always hide on focus
    end)

    searchBox:SetScript("OnEditFocusLost", function()
        this:SetBackdropBorderColor(0.5, 0.5, 0.6, 1.0) -- Dimmer version of headline color
        this.hasFocus = false
        -- Show placeholder only if text is empty
        if this:GetText() == "" then
            placeholderText:Show()
        end
    end)

    -- Fix: Make sure to call applyGroupsLogsFilter when text changes
    searchBox:SetScript("OnTextChanged", function()
        -- Get text and convert to lowercase for case-insensitive search
        currentGroupsLogsFilter = string.lower(this:GetText() or "")
        
        -- Update placeholder visibility based on text content and our tracked focus state
        if this:GetText() == "" and not this.hasFocus then
            placeholderText:Show()
        else
            placeholderText:Hide()
        end
        
        -- Apply the filter on text change
        applyGroupsLogsFilter(currentGroupsLogsFilter)
    end)
    
    -- Add Escape key handler to clear focus and apply filter
    searchBox:SetScript("OnEscapePressed", function()
        -- Update filter before clearing focus
        currentGroupsLogsFilter = string.lower(this:GetText() or "")
        applyGroupsLogsFilter(currentGroupsLogsFilter)
        
        this:ClearFocus()
        return true -- Indicates the escape was handled
    end)
    
    -- Add Enter key handler to clear focus and apply filter
    searchBox:SetScript("OnEnterPressed", function()
        -- Update filter before clearing focus
        currentGroupsLogsFilter = string.lower(this:GetText() or "")
        applyGroupsLogsFilter(currentGroupsLogsFilter)
        
        this:ClearFocus()
        return true -- Indicates the enter was handled
    end)

    -- Initialize placeholder - assume not focused initially
    if searchBox:GetText() == "" then
        placeholderText:Show()
    else
        placeholderText:Hide()
    end
    
    -- Store the frame reference
    groupsLogsSearchFrame = frame

    return frame
end

function DifficultBulletinBoardMainFrame.InitializeMainFrame()
    --call it once before OnUpdate so the time doesnt just magically appear
    DifficultBulletinBoardMainFrame.UpdateServerTime()

    groupScrollFrame, groupScrollChild = createScrollFrameForMainFrame("DifficultBulletinBoardMainFrame_Group_ScrollFrame")
    createTopicListWithNameMessageDateColumns(groupScrollChild, DifficultBulletinBoardVars.allGroupTopics, groupTopicPlaceholders, DifficultBulletinBoardVars.numberOfGroupPlaceholders)
    
    -- Create the Groups Logs scroll frame using the same function as other tabs
    groupsLogsScrollFrame, groupsLogsScrollChild = createScrollFrameForMainFrame("DifficultBulletinBoardMainFrame_GroupsLogs_ScrollFrame")
    -- Use the same function to create content as for group topics
    createTopicListWithNameMessageDateColumns(groupsLogsScrollChild, {{name = "Group Logs", selected = true, tags = {}}}, groupsLogsPlaceholders, MAX_GROUPS_LOGS_ENTRIES)
    
    professionScrollFrame, professionScrollChild = createScrollFrameForMainFrame("DifficultBulletinBoardMainFrame_Profession_ScrollFrame")
    createTopicListWithNameMessageDateColumns(professionScrollChild, DifficultBulletinBoardVars.allProfessionTopics, professionTopicPlaceholders, DifficultBulletinBoardVars.numberOfProfessionPlaceholders)
    
    hardcoreScrollFrame, hardcoreScrollChild = createScrollFrameForMainFrame("DifficultBulletinBoardMainFrame_Hardcore_ScrollFrame")
    createTopicListWithMessageDateColumns(hardcoreScrollChild, DifficultBulletinBoardVars.allHardcoreTopics, hardcoreTopicPlaceholders, DifficultBulletinBoardVars.numberOfHardcorePlaceholders)

    -- Add topic group tab switching
    configureTabSwitching()
    
    -- Create the search box after all scroll frames are created
    createGroupsLogsSearchBox()
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

-- Modified to also update times in the Groups Logs tab
function DifficultBulletinBoardMainFrame.UpdateElapsedTimes()
    for topicName, entries in pairs(groupTopicPlaceholders) do
        for _, entry in ipairs(entries) do
            if entry and entry.timeFontString and entry.timeFontString:GetText() ~= "-" and entry.creationTimestamp then
                local delta = calculateDelta(entry.creationTimestamp, date("%H:%M:%S"))
                entry.timeFontString:SetText(delta)
            end
        end
    end
    
    -- Update Groups Logs times
    if groupsLogsPlaceholders["Group Logs"] then
        for _, entry in ipairs(groupsLogsPlaceholders["Group Logs"]) do
            if entry and entry.timeFontString and entry.timeFontString:GetText() ~= "-" and entry.creationTimestamp then
                local delta = calculateDelta(entry.creationTimestamp, date("%H:%M:%S"))
                entry.timeFontString:SetText(delta)
            end
        end
    end

    for topicName, entries in pairs(professionTopicPlaceholders) do
        for _, entry in ipairs(entries) do
            if entry and entry.timeFontString and entry.timeFontString:GetText() ~= "-" and entry.creationTimestamp then
                local delta = calculateDelta(entry.creationTimestamp, date("%H:%M:%S"))
                entry.timeFontString:SetText(delta)
            end
        end
    end

    for topicName, entries in pairs(hardcoreTopicPlaceholders) do
        for _, entry in ipairs(entries) do
            if entry and entry.timeFontString and entry.timeFontString:GetText() ~= "-" and entry.creationTimestamp then
                local delta = calculateDelta(entry.creationTimestamp, date("%H:%M:%S"))
                entry.timeFontString:SetText(delta)
            end
        end
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