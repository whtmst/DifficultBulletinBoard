local version = DifficultBulletinBoard.version
local defaultGroupTopics = DifficultBulletinBoard.defaultGroupTopics
local defaultProfessionTopics = DifficultBulletinBoard.defaultProfessionTopics
local defaultHardcoreTopics = DifficultBulletinBoard.defaultHardcoreTopics
local defaultNumberOfGroupPlaceholders = DifficultBulletinBoard.defaultNumberOfGroupPlaceholders
local defaultNumberOfProfessionPlaceholders = DifficultBulletinBoard.defaultNumberOfProfessionPlaceholders
local defaultNumberOfHardcorePlaceholders = DifficultBulletinBoard.defaultNumberOfHardcorePlaceholders
local allGroupTopics = {}
local allProfessionTopics = {}
local allHardcoreTopics = {}
local mainFrame = DifficultBulletinBoardMainFrame
local groupsButton = DifficultBulletinBoardMainFrameGroupsButton
local professionsButton = DifficultBulletinBoardMainFrameProfessionsButton
local hcMessagesButton = DifficultBulletinBoardMainFrameHCMessagesButton
local optionFrame = DifficultBulletinBoardOptionFrame
local string_gfind = string.gmatch or string.gfind

local numberOfGroupPlaceholders = defaultNumberOfGroupPlaceholders
local numberOfProfessionPlaceholders = defaultNumberOfProfessionPlaceholders
local numberOfHardcorePlaceholders = defaultNumberOfHardcorePlaceholders
local groupTopicPlaceholders = {}
local professionTopicPlaceholders = {}
local hardcoreTopicPlaceholders = {}

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

local function splitIntoLowerWords(input)
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
            print("Hiding frame")
            optionFrame:Hide()
        else
            print("Showing frame")
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
            print("Hiding frame")
            mainFrame:Hide()
        else
            print("Showing frame")
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

local scrollFrame = nil
local function addGroupScrollFrameToMainFrame()
    local parentFrame = mainFrame

    -- Create the ScrollFrame
    scrollFrame = CreateFrame("ScrollFrame", parentFrame:GetName() ..
                                  "DifficultBulletinBoardMainFrame_ScrollFrame",
                              parentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors
    scrollFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -80)
    scrollFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -26, 10)

    -- Create the ScrollChild (content frame)
    local scrollChild = CreateFrame("Frame",
                                    "DifficultBulletinBoardMainFrame_ScrollFrame_ScrollChild",
                                    scrollFrame)
    scrollChild:SetHeight(1)
    scrollChild:SetWidth(980)

    -- Attach the ScrollChild to the ScrollFrame
    scrollFrame:SetScrollChild(scrollChild)
end

-- function to create the placeholders and font strings for a topic
local function createNameMessageDateTopicList(contentFrame, topicList, topicPlaceholders, numberOfPlaceholders)
    -- initial Y-offset for the first header and placeholder
    local yOffset = 0

    for _, topic in ipairs(topicList) do
        if topic.selected then
            local header = contentFrame:CreateFontString("$parent_" .. topic.name .. "Header", "OVERLAY", "GameFontNormal")
            header:SetText(topic.name)
            header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
            header:SetWidth(200)
            header:SetJustifyH("LEFT")
            header:SetTextColor(1, 1, 0)
            header:SetFont("Fonts\\FRIZQT__.TTF", 12)

            -- Store the header Y offset for the current topic
            local topicYOffset = yOffset - 20 -- space between header and first placeholder
            yOffset = topicYOffset - 110 -- space between headers

            topicPlaceholders[topic.name] = topicPlaceholders[topic.name] or {FontStrings = {}}

            for i = 1, numberOfPlaceholders do
                -- create Name column as a button
                local nameButton = CreateFrame("Button", "$parent_" .. topic.name .. "Placeholder" .. i .. "_Name", contentFrame, nil)
                nameButton:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, topicYOffset)
                nameButton:SetWidth(150)
                nameButton:SetHeight(14)

                -- Set the text of the button
                local buttonText = nameButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                buttonText:SetText("-")
                buttonText:SetPoint("LEFT", nameButton, "LEFT", 5, 0)
                buttonText:SetFont("Fonts\\FRIZQT__.TTF", 12)
                buttonText:SetTextColor(1, 1, 1)
                nameButton:SetFontString(buttonText)

                -- Set scripts for hover behavior
                nameButton:SetScript("OnEnter", function()
                    buttonText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Highlight font
                    buttonText:SetTextColor(1, 1, 0) -- Highlight color (e.g., yellow)
                end)

                nameButton:SetScript("OnLeave", function()
                    buttonText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Normal font
                    buttonText:SetTextColor(1, 1, 1) -- Normal color (e.g., white)
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

                -- create Message column
                local messageColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Message", "OVERLAY", "GameFontNormal")
                messageColumn:SetText("-")
                messageColumn:SetPoint("TOPLEFT", nameButton, "TOPRIGHT", 50, 0)
                messageColumn:SetWidth(650)
                messageColumn:SetHeight(10)
                messageColumn:SetJustifyH("LEFT")
                messageColumn:SetTextColor(1, 1, 1)
                messageColumn:SetFont("Fonts\\FRIZQT__.TTF", 12)

                -- create Time column
                local timeColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Time", "OVERLAY", "GameFontNormal")
                timeColumn:SetText("-")
                timeColumn:SetPoint("TOPLEFT", messageColumn, "TOPRIGHT", 20, 0)
                timeColumn:SetWidth(100)
                timeColumn:SetJustifyH("LEFT")
                timeColumn:SetTextColor(1, 1, 1)
                timeColumn:SetFont("Fonts\\FRIZQT__.TTF", 12)

                table.insert(topicPlaceholders[topic.name].FontStrings, {nameButton, messageColumn, timeColumn})

                -- Increment the Y-offset for the next placeholder
                topicYOffset = topicYOffset - 18 -- space between placeholders
            end

            -- After the placeholders, adjust the main yOffset for the next topic
            yOffset = topicYOffset - 10 -- space between topics
        end
    end
end

local professionScrollFrame
local function addProfessionScrollFrameToMainFrame()
    local parentFrame = mainFrame

    -- Create the ScrollFrame
    professionScrollFrame = CreateFrame("ScrollFrame", parentFrame:GetName() .. "DifficultBulletinBoardMainFrame_Profession_ScrollFrame", parentFrame, "UIPanelScrollFrameTemplate")
    professionScrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors
    professionScrollFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -80)
    professionScrollFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -26, 10)

    -- Create the ScrollChild (content frame)
    local scrollChild = CreateFrame("Frame", "DifficultBulletinBoardMainFrame_Profession_ScrollFrame_ScrollChild", professionScrollFrame)
    scrollChild:SetHeight(1)
    scrollChild:SetWidth(980)

    -- Attach the ScrollChild to the ScrollFrame
    professionScrollFrame:SetScrollChild(scrollChild)

    -- Default Hide, because the groups tab is shown
    professionScrollFrame:Hide()
end

local hardcoreScrollFrame
local function addHardcoreScrollFrameToMainFrame()
    local parentFrame = mainFrame

    -- Create the ScrollFrame
    hardcoreScrollFrame = CreateFrame("ScrollFrame", parentFrame:GetName() .. "DifficultBulletinBoardMainFrame_Hardcore_ScrollFrame", parentFrame, "UIPanelScrollFrameTemplate")
    hardcoreScrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors
    hardcoreScrollFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -80)
    hardcoreScrollFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -26, 10)

    -- Create the ScrollChild (content frame)
    local scrollChild = CreateFrame("Frame", "DifficultBulletinBoardMainFrame_Hardcore_ScrollFrame_ScrollChild", hardcoreScrollFrame)
    scrollChild:SetHeight(1)
    scrollChild:SetWidth(980)

    -- Attach the ScrollChild to the ScrollFrame
    hardcoreScrollFrame:SetScrollChild(scrollChild)

    -- Default Hide, because the groups tab is shown
    hardcoreScrollFrame:Hide()
end

-- function to create the placeholders and font strings for a topic
local function createHardcoreTopicList()
    -- initial Y-offset for the first header and placeholder
    local yOffset = 0

    local contentFrame = DifficultBulletinBoardMainFrame_Hardcore_ScrollFrame_ScrollChild

    for _, topic in ipairs(allHardcoreTopics) do
        if topic.selected then
            local header = contentFrame:CreateFontString("$parent_" .. topic.name ..  "Header", "OVERLAY", "GameFontNormal")
            header:SetText(topic.name)
            header:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
            header:SetWidth(200)
            header:SetJustifyH("LEFT")
            header:SetTextColor(1, 1, 0)
            header:SetFont("Fonts\\FRIZQT__.TTF", 12)

            -- Store the header Y offset for the current topic
            local topicYOffset = yOffset - 20 -- space between header and first placeholder
            yOffset = topicYOffset - 110 -- space between headers

            hardcoreTopicPlaceholders[topic.name] = hardcoreTopicPlaceholders[topic.name] or {FontStrings = {}}

            for i = 1, numberOfHardcorePlaceholders do

                -- create Message column
                local messageColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Message", "OVERLAY", "GameFontNormal")
                messageColumn:SetText("-")
                messageColumn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 14, topicYOffset)
                messageColumn:SetWidth(846)
                messageColumn:SetHeight(14)
                messageColumn:SetJustifyH("LEFT")
                messageColumn:SetTextColor(1, 1, 1)
                messageColumn:SetFont("Fonts\\FRIZQT__.TTF", 12)

                -- create Time column
                local timeColumn = contentFrame:CreateFontString("$parent_" .. topic.name .. "Placeholder" .. i .. "_Time", "OVERLAY", "GameFontNormal")
                timeColumn:SetText("-")
                timeColumn:SetPoint("TOPLEFT", messageColumn, "TOPRIGHT", 20, 0)
                timeColumn:SetWidth(100)
                timeColumn:SetJustifyH("LEFT")
                timeColumn:SetTextColor(1, 1, 1)
                timeColumn:SetFont("Fonts\\FRIZQT__.TTF", 12)

                table.insert( hardcoreTopicPlaceholders[topic.name].FontStrings, {nil, messageColumn, timeColumn})

                -- Increment the Y-offset for the next placeholder
                topicYOffset = topicYOffset - 18 -- space between placeholders
            end

            -- After the placeholders, adjust the main yOffset for the next topic
            yOffset = topicYOffset - 10 -- space between topics
        end
    end
end

-- Function to update the first placeholder for a given topic with new name, message, and time and shift other placeholders down
local function UpdateFirstPlaceholderAndShiftDown(topicPlaceholders, topic, channelName, name, message)
    local topicData = topicPlaceholders[topic]
    if not topicData or not topicData.FontStrings or not topicData.FontStrings[1] then
        print("No placeholders found for topic: " .. topic)
        return
    end

    local currentTime = date("%H:%M:%S")

    local index = 0
    for i, _ in ipairs(topicData.FontStrings) do index = i end

    for i = index, 2, -1 do
        -- Copy the data from the previous placeholder to the current one
        local currentFontString = topicData.FontStrings[i]
        local previousFontString = topicData.FontStrings[i - 1]

        -- Update the current placeholder with the previous placeholder's data
        currentFontString[1]:SetText(previousFontString[1]:GetText())
        currentFontString[2]:SetText(previousFontString[2]:GetText())
        currentFontString[3]:SetText(previousFontString[3]:GetText())
    end

    -- Update the first placeholder with the new data
    local firstFontString = topicData.FontStrings[1]
    firstFontString[1]:SetText(name or "No Name")
    firstFontString[2]:SetText("[" .. channelName .. "] " .. message or "No Message")
    firstFontString[3]:SetText(currentTime or "No Time")
end

-- Function to update the first placeholder for a given topic with new name, message, and time and shift other placeholders down
local function UpdateFirstSystemPlaceholderAndShiftDown(topicPlaceholders, topic, message)
    local topicData = topicPlaceholders[topic]
    if not topicData or not topicData.FontStrings or not topicData.FontStrings[1] then
        print("No placeholders found for topic: " .. topic)
        return
    end

    local currentTime = date("%H:%M:%S")

    local index = 0
    for i, _ in ipairs(topicData.FontStrings) do index = i end
        for i = index, 2, -1 do
            -- Copy the data from the previous placeholder to the current one
            local currentFontString = topicData.FontStrings[i]
            local previousFontString = topicData.FontStrings[i - 1]

            -- Update the current placeholder with the previous placeholder's data
            currentFontString[2]:SetText(previousFontString[2]:GetText())
            currentFontString[3]:SetText(previousFontString[3]:GetText())
        end

    -- Update the first placeholder with the new data
    local firstFontString = topicData.FontStrings[1]
    firstFontString[2]:SetText(message or "No Message")
    firstFontString[3]:SetText(currentTime or "No Time")
end

-- Updates the specified placeholder for a topic with new name, message, and timestamp,
-- then moves the updated entry to the top of the list, shifting other entries down.
local function UpdateTopicPlaceholderWithShift(topicPlaceholders, topic, channelName, name, message, index)
    local topicData = topicPlaceholders[topic]
    local FontStringsList = {}

    if not topicData or not topicData.FontStrings then
        print("No FontStrings found for topic:", topic)
        return nil
    end

    for i, row in ipairs(topicData.FontStrings) do
        local entryList = {}

        for j, fontString in ipairs(row) do
            local text = fontString:GetText()
            table.insert(entryList, text)
        end

        table.insert(FontStringsList, entryList)
    end

    local currentTime = date("%H:%M:%S")
    FontStringsList[index][1] = name
    FontStringsList[index][2] = "[" .. channelName .. "] " .. message
    FontStringsList[index][3] = currentTime

    local tempFontStringsList = table.remove(FontStringsList, index)
    table.insert(FontStringsList, 1, tempFontStringsList)

    for i = 1, numberOfGroupPlaceholders, 1 do
        local currentFontString = topicData.FontStrings[i]

        currentFontString[1]:SetText(FontStringsList[i][1])
        currentFontString[2]:SetText(FontStringsList[i][2])
        currentFontString[3]:SetText(FontStringsList[i][3])
    end
end

SLASH_DIFFICULTBB1 = "/dbb"
SlashCmdList["DIFFICULTBB"] =
    function() DifficultBulletinBoard_ToggleMainFrame() end

local function loadSavedVariables()
    DifficultBulletinBoardSavedVariables = DifficultBulletinBoardSavedVariables or {}

    if DifficultBulletinBoardSavedVariables.version then
        print("version did exist " .. DifficultBulletinBoardSavedVariables.version)
        local savedVersion = DifficultBulletinBoardSavedVariables.version

        -- update the saved activeTopics if a new version of the topic list was released
        if savedVersion < version then
            print("version is older than the current version. overwriting activeTopics")

            allGroupTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultGroupTopics)
            DifficultBulletinBoardSavedVariables.activeGroupTopics = allGroupTopics

            allProfessionTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultProfessionTopics)
            DifficultBulletinBoardSavedVariables.activeProfessionTopics = allProfessionTopics

            allHardcoreTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultHardcoreTopics)
            DifficultBulletinBoardSavedVariables.activeHardcoreTopics = allHardcoreTopics

            DifficultBulletinBoardSavedVariables.version = version
            print("version is now " .. version)
        end
    else
        print("version did not exist. overwriting version")
        DifficultBulletinBoardSavedVariables.version = version

        print("overwriting activeTopics")
        allGroupTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultGroupTopics)
        DifficultBulletinBoardSavedVariables.activeGroupTopics = allGroupTopics

        allProfessionTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultProfessionTopics)
        DifficultBulletinBoardSavedVariables.activeProfessionTopics = allProfessionTopics

        allHardcoreTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultHardcoreTopics)
        DifficultBulletinBoardSavedVariables.activeHardcoreTopics = allHardcoreTopics
    end

    if DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders and DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders ~= "" then
        numberOfGroupPlaceholders = DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders
    else
        numberOfGroupPlaceholders = DifficultBulletinBoard.defaultNumberOfGroupPlaceholders
        DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = numberOfGroupPlaceholders
    end

    if DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders and DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders ~= "" then
        numberOfProfessionPlaceholders = DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders
    else
        numberOfProfessionPlaceholders = DifficultBulletinBoard.defaultNumberOfProfessionPlaceholders
        DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = numberOfProfessionPlaceholders
    end

    if DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders and DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders ~= "" then
        numberOfHardcorePlaceholders = DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders
    else
        numberOfHardcorePlaceholders = DifficultBulletinBoard.defaultNumberOfHardcorePlaceholders
        DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = numberOfHardcorePlaceholders
    end

    if DifficultBulletinBoardSavedVariables.activeGroupTopics then 
        allGroupTopics = DifficultBulletinBoardSavedVariables.activeGroupTopics
    else
        allGroupTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultGroupTopics)
        DifficultBulletinBoardSavedVariables.activeGroupTopics = allGroupTopics
    end

    if DifficultBulletinBoardSavedVariables.activeProfessionTopics then
        allProfessionTopics = DifficultBulletinBoardSavedVariables.activeProfessionTopics
    else
        allProfessionTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultProfessionTopics)
        DifficultBulletinBoardSavedVariables.activeProfessionTopics = allProfessionTopics
    end

    if DifficultBulletinBoardSavedVariables.activeHardcoreTopics then
        allHardcoreTopics = DifficultBulletinBoardSavedVariables.activeHardcoreTopics
    else
        allHardcoreTopics = DifficultBulletinBoard.deepCopy(DifficultBulletinBoard.defaultHardcoreTopics)
        DifficultBulletinBoardSavedVariables.activeHardcoreTopics = allHardcoreTopics
    end
end

local optionScrollChild = nil
local function addScrollFrameToOptionFrame()
    local parentFrame = optionFrame

    -- Create the ScrollFrame
    scrollFrame = CreateFrame("ScrollFrame", parentFrame:GetName() .. "_ScrollFrame", parentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors
    scrollFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -27, 75)
    scrollFrame:SetWidth(460)
    scrollFrame:SetHeight(520)

    -- Create the ScrollChild
    optionScrollChild = CreateFrame("Frame", parentFrame:GetName() .. "_ScrollChild", scrollFrame)
    optionScrollChild:SetWidth(480)
    optionScrollChild:SetHeight(2000)
    scrollFrame:SetScrollChild(optionScrollChild)
end

local function addGroupPlaceholderOptionToOptionFrame()
    local parentFrame = optionScrollChild

    -- Create the first FontString (label) above the scroll frame
    local scrollLabel = parentFrame:CreateFontString("DifficultBulletinBoard_Option_PlaceholderOption_FontString", "OVERLAY", "GameFontHighlight")
    scrollLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, 0)
    scrollLabel:SetText("Number of Placeholders per Group Topic:")
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)

    local placeholderOptionTextBox = CreateFrame("EditBox", "DifficultBulletinBoard_Option_Group_PlaceholderOption_TextBox", parentFrame, "InputBoxTemplate")
    placeholderOptionTextBox:SetPoint("RIGHT", scrollLabel, "RIGHT", 30, -0)
    placeholderOptionTextBox:SetWidth(20)
    placeholderOptionTextBox:SetHeight(20)
    placeholderOptionTextBox:SetText(numberOfGroupPlaceholders)
    placeholderOptionTextBox:EnableMouse(true)
    placeholderOptionTextBox:SetAutoFocus(false)
end

local tempGroupTags = {}
local optionYOffset = -35 -- Starting vertical offset for the first option
local function addGroupTopicOptions()
    local parentFrame = optionScrollChild

    -- create fontstring
    local scrollLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scrollLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
    scrollLabel:SetText("Select the Group Topics you want to observe:")
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)

    optionYOffset = optionYOffset - 30

    for _, topic in ipairs(allGroupTopics) do
        local checkbox = CreateFrame("CheckButton", "$parent_" .. topic.name .. "_Checkbox", parentFrame, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
        checkbox:SetWidth(25)
        checkbox:SetHeight(25)
        checkbox:SetChecked(topic.selected)

        local currentTopic = topic
        checkbox:SetScript("OnClick", function()
            currentTopic.selected = checkbox:GetChecked()
        end)

        -- Add a label next to the checkbox displaying the topic
        local topicLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        topicLabel:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
        topicLabel:SetText(topic.name)
        topicLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
        topicLabel:SetJustifyH("LEFT")
        topicLabel:SetWidth(175)

        -- Add a text box next to the topic label for tags input
        local tagsTextBox = CreateFrame("EditBox", "$parent_" .. topic.name .. "_TagsTextBox", parentFrame, "InputBoxTemplate")
        tagsTextBox:SetPoint("LEFT", topicLabel, "RIGHT", 10, 0)
        tagsTextBox:SetWidth(200)
        tagsTextBox:SetHeight(20)
        tagsTextBox:SetText(table.concat(topic.tags, " "))
        tagsTextBox:EnableMouse(true)
        tagsTextBox:SetAutoFocus(false)

        local topicName = topic.name -- save a reference for the onTextChanged event
        tagsTextBox:SetScript("OnTextChanged", function()
            local enteredText = this:GetText()
            tempGroupTags[topicName] = splitIntoLowerWords(enteredText)
        end)

        optionYOffset = optionYOffset - 30 -- Adjust the vertical offset for the next row
    end
end

local function addProfessionPlaceholderOptionToOptionFrame()
    local parentFrame = optionScrollChild

    optionYOffset = optionYOffset - 30

    -- Create the first FontString (label) above the scroll frame
    local scrollLabel = parentFrame:CreateFontString("DifficultBulletinBoard_Option_Profession_PlaceholderOption_FontString", "OVERLAY", "GameFontHighlight")
    scrollLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
    scrollLabel:SetText("Number of Placeholders per Profession Topic:")
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)

    local placeholderOptionTextBox = CreateFrame("EditBox", "DifficultBulletinBoard_Option_Profession_PlaceholderOption_TextBox", parentFrame, "InputBoxTemplate")
    placeholderOptionTextBox:SetPoint("RIGHT", scrollLabel, "RIGHT", 30, -0)
    placeholderOptionTextBox:SetWidth(20)
    placeholderOptionTextBox:SetHeight(20)
    placeholderOptionTextBox:SetText(numberOfProfessionPlaceholders)
    placeholderOptionTextBox:EnableMouse(true)
    placeholderOptionTextBox:SetAutoFocus(false)
end

local tempProfessionTags = {}
local function addProfessionTopicOptions()
    local parentFrame = optionScrollChild

    optionYOffset = optionYOffset - 35

    -- create fontstring
    local scrollLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scrollLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
    scrollLabel:SetText("Select the Profession Topics you want to observe:")
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)

    optionYOffset = optionYOffset - 30

    for _, topic in ipairs(allProfessionTopics) do
        local checkbox = CreateFrame("CheckButton", "$parent_" .. topic.name .. "_Checkbox", parentFrame, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
        checkbox:SetWidth(25)
        checkbox:SetHeight(25)
        checkbox:SetChecked(topic.selected)

        local currentTopic = topic
        checkbox:SetScript("OnClick", function()
            currentTopic.selected = checkbox:GetChecked()
        end)

        -- Add a label next to the checkbox displaying the topic
        local topicLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        topicLabel:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
        topicLabel:SetText(topic.name)
        topicLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
        topicLabel:SetJustifyH("LEFT")
        topicLabel:SetWidth(175)

        -- Add a text box next to the topic label for tags input
        local tagsTextBox = CreateFrame("EditBox", "$parent_" .. topic.name .. "_TagsTextBox", parentFrame, "InputBoxTemplate")
        tagsTextBox:SetPoint("LEFT", topicLabel, "RIGHT", 10, 0)
        tagsTextBox:SetWidth(200)
        tagsTextBox:SetHeight(20)
        tagsTextBox:SetText(table.concat(topic.tags, " "))
        tagsTextBox:EnableMouse(true)
        tagsTextBox:SetAutoFocus(false)

        local topicName = topic.name -- save a reference for the onTextChanged event
        tagsTextBox:SetScript("OnTextChanged", function()
            local enteredText = this:GetText()
            tempProfessionTags[topicName] = splitIntoLowerWords(enteredText)
            print(enteredText)
            print(topicName)
        end)

        optionYOffset = optionYOffset - 30 -- Adjust the vertical offset for the next row
    end
end

local function addHardcorePlaceholderOptionToOptionFrame()
    local parentFrame = optionScrollChild

    optionYOffset = optionYOffset - 30

    -- Create the first FontString (label) above the scroll frame
    local scrollLabel = parentFrame:CreateFontString("DifficultBulletinBoard_Option_Hardcore_PlaceholderOption_FontString", "OVERLAY", "GameFontHighlight")
    scrollLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
    scrollLabel:SetText("Number of Placeholders per Hardcore Topic:")
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)

    local placeholderOptionTextBox = CreateFrame("EditBox", "DifficultBulletinBoard_Option_Hardcore_PlaceholderOption_TextBox", parentFrame, "InputBoxTemplate")
    placeholderOptionTextBox:SetPoint("RIGHT", scrollLabel, "RIGHT", 30, -0)
    placeholderOptionTextBox:SetWidth(20)
    placeholderOptionTextBox:SetHeight(20)
    placeholderOptionTextBox:SetText(numberOfHardcorePlaceholders)
    placeholderOptionTextBox:EnableMouse(true)
    placeholderOptionTextBox:SetAutoFocus(false)
end

local tempHardcoreTags = {}
local function addHardcoreTopicOptions()
    local parentFrame = optionScrollChild

    optionYOffset = optionYOffset - 35

    -- create fontstring
    local scrollLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scrollLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
    scrollLabel:SetText("Select the Hardcore Topics you want to observe:")
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)

    optionYOffset = optionYOffset - 30

    for _, topic in ipairs(allHardcoreTopics) do
        print("hardcore" .. topic.name)
        local checkbox = CreateFrame("CheckButton", "$parent_" .. topic.name .. "_Checkbox", parentFrame, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
        checkbox:SetWidth(25)
        checkbox:SetHeight(25)
        checkbox:SetChecked(topic.selected)

        local currentTopic = topic
        checkbox:SetScript("OnClick", function()
            currentTopic.selected = checkbox:GetChecked()
        end)

        -- Add a label next to the checkbox displaying the topic
        local topicLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        topicLabel:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
        topicLabel:SetText(topic.name)
        topicLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
        topicLabel:SetJustifyH("LEFT")
        topicLabel:SetWidth(175)

        -- Add a text box next to the topic label for tags input
        local tagsTextBox = CreateFrame("EditBox", "$parent_" .. topic.name .. "_TagsTextBox", parentFrame, "InputBoxTemplate")
        tagsTextBox:SetPoint("LEFT", topicLabel, "RIGHT", 10, 0)
        tagsTextBox:SetWidth(200)
        tagsTextBox:SetHeight(20)
        tagsTextBox:SetText(table.concat(topic.tags, " "))
        tagsTextBox:EnableMouse(true)
        tagsTextBox:SetAutoFocus(false)

        local topicName = topic.name -- save a reference for the onTextChanged event
        tagsTextBox:SetScript("OnTextChanged", function()
            local enteredText = this:GetText()
            tempHardcoreTags[topicName] = splitIntoLowerWords(enteredText)
        end)

        optionYOffset = optionYOffset - 30 -- Adjust the vertical offset for the next row
    end
end

local function configureTabSwitching()
    -- Helper function to reset button states visually
    local function ResetButtonStates()
        groupsButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
        professionsButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
        hcMessagesButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    end

    -- Set initial active button
    ResetButtonStates()
    groupsButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Down")

    groupsButton:SetScript("OnClick", function()
        print("Clicked on groupsButton")

        ResetButtonStates()
        groupsButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Down")

        scrollFrame:Show()
        professionScrollFrame:Hide()
        hardcoreScrollFrame:Hide()
    end)

    professionsButton:SetScript("OnClick", function()
        print("Clicked on professionsButton")

        ResetButtonStates()
        professionsButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Down")

        scrollFrame:Hide()
        professionScrollFrame:Show()
        hardcoreScrollFrame:Hide()
    end)

    hcMessagesButton:SetScript("OnClick", function()
        print("Clicked on hcMessagesButton")

        ResetButtonStates()
        hcMessagesButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Down")

        scrollFrame:Hide()
        professionScrollFrame:Hide()
        hardcoreScrollFrame:Show()
    end)
end

local function initializeAddon(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DifficultBulletinBoard" then
        loadSavedVariables()

        -- create option frame first so the user can update his options in case he put in some invalid data that might result in the addon crashing
        addScrollFrameToOptionFrame()
        addGroupPlaceholderOptionToOptionFrame()
        addGroupTopicOptions()
        addProfessionPlaceholderOptionToOptionFrame()
        addProfessionTopicOptions()
        addHardcorePlaceholderOptionToOptionFrame()
        addHardcoreTopicOptions()

        -- create main frame afterwards
        addGroupScrollFrameToMainFrame()
        createNameMessageDateTopicList(DifficultBulletinBoardMainFrame_ScrollFrame_ScrollChild, allGroupTopics, groupTopicPlaceholders, numberOfGroupPlaceholders)
        addProfessionScrollFrameToMainFrame()
        createNameMessageDateTopicList(DifficultBulletinBoardMainFrame_Profession_ScrollFrame_ScrollChild, allProfessionTopics, professionTopicPlaceholders, numberOfProfessionPlaceholders)
        addHardcoreScrollFrameToMainFrame()
        createNameMessageDateTopicList(DifficultBulletinBoardMainFrame_Hardcore_ScrollFrame_ScrollChild, allHardcoreTopics, hardcoreTopicPlaceholders, numberOfHardcorePlaceholders)

        -- add topic group tab switching
        configureTabSwitching()

    end
end

local function overwriteTagsForAllTopics(allTopics, tempTags)
    for _, topic in ipairs(allTopics) do
        if tempTags[topic.name] then
            local newTags = tempTags[topic.name]
            topic.tags = newTags
            print("Tags for topic '" .. topic.name .. "' have been updated:")
            for _, tag in ipairs(newTags) do print("- " .. tag) end
        else
            print("No tags found for topic '" .. topic.name .. "' in tempTags.")
        end
    end
end

function DifficultBulletinBoard_ResetVariablesAndReload()
    DifficultBulletinBoardSavedVariables.version = version

    DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = defaultNumberOfGroupPlaceholders
    DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = defaultNumberOfProfessionPlaceholders
    DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = defaultNumberOfHardcorePlaceholders

    DifficultBulletinBoardSavedVariables.activeGroupTopics = defaultGroupTopics
    DifficultBulletinBoardSavedVariables.activeProfessionTopics = defaultProfessionTopics
    DifficultBulletinBoardSavedVariables.activeHardcoreTopics = defaultHardcoreTopics

    ReloadUI();
end

function DifficultBulletinBoard_SaveVariablesAndReload()
    DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = DifficultBulletinBoard_Option_Group_PlaceholderOption_TextBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = DifficultBulletinBoard_Option_Profession_PlaceholderOption_TextBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = DifficultBulletinBoard_Option_Hardcore_PlaceholderOption_TextBox:GetText()
    
    overwriteTagsForAllTopics(allGroupTopics, tempGroupTags); 
    overwriteTagsForAllTopics(allProfessionTopics, tempProfessionTags); 
    overwriteTagsForAllTopics(allHardcoreTopics, tempHardcoreTags); 

    ReloadUI();
end

local function topicPlaceholdersContainsCharacterName(topicPlaceholders, topicName, characterName)
    local topicData = topicPlaceholders[topicName]
    if not topicData or not topicData.FontStrings then
        print("Nothing in here yet")
        return false, nil
    end

    for index, row in ipairs(topicData.FontStrings) do
        local nameColumn = row[1]

        if nameColumn:GetText() == characterName then
            print("Already in there!")
            return true, index
        end
    end

    return false, nil
end

-- Searches the passed topicList for the passed words. If a match is found the topicPlaceholders will be updated
local function analyzeChatMessage(channelName, characterName, chatMessage, words, topicList, topicPlaceholders)
    for _, topic in ipairs(topicList) do
        local matchFound = false -- Flag to control breaking out of nested loops

        for _, tag in ipairs(topic.tags) do
            for _, word in ipairs(words) do
                if word == string.lower(tag) then
                    print("Tag '" .. tag .. "' matches Topic: " .. topic.name)
                    local found, index =
                        topicPlaceholdersContainsCharacterName(
                            topicPlaceholders, topic.name, characterName)
                    if found then
                        print("An entry for that character already exists at " .. index)
                        UpdateTopicPlaceholderWithShift(topicPlaceholders, topic.name, channelName, characterName, chatMessage, index)
                    else
                        print("No entry for that character exists. Creating one...")
                        UpdateFirstPlaceholderAndShiftDown(topicPlaceholders, topic.name, channelName, characterName, chatMessage)
                    end

                    matchFound = true -- Set the flag to true to break out of loops
                    break
                end
            end

            if matchFound then break end
        end
    end
end

-- function to reduce noise in messages and making matching easier
local function replaceSymbolsWithSpace(inputString)
    inputString = string.gsub(inputString, "[,/!%?]", " ")

    return inputString
end

local function OnChatMessage(arg1, arg2, arg9)
    local chatMessage = arg1
    local characterName = arg2
    local channelName = arg9
    
    print(chatMessage)
    print(channelName)

    local stringWithoutNoise = replaceSymbolsWithSpace(chatMessage)

    print(stringWithoutNoise)

    local words = splitIntoLowerWords(stringWithoutNoise)

    analyzeChatMessage(channelName, characterName, chatMessage, words, allGroupTopics, groupTopicPlaceholders)
    analyzeChatMessage(channelName, characterName, chatMessage, words, allProfessionTopics, professionTopicPlaceholders)
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
                    UpdateFirstSystemPlaceholderAndShiftDown(topicPlaceholders,topic.name, chatMessage)

                    matchFound = true -- Set the flag to true to break out of loops
                    break
                end
            end

            if matchFound then break end
        end
    end
end

local function OnSystemMessage(arg1)
    local systemMessage = arg1

    local stringWithoutNoise = replaceSymbolsWithSpace(systemMessage)

    local words = splitIntoLowerWords(stringWithoutNoise)

    analyzeSystemMessage(systemMessage, words, allHardcoreTopics, hardcoreTopicPlaceholders)
end

function handleEvent()
    if event == "ADDON_LOADED" then 
        initializeAddon(event, arg1)
    end

    if event == "CHAT_MSG_HARDCORE" then 
        OnChatMessage(arg1, arg2, "HC")
    end

    if event == "CHAT_MSG_CHANNEL" then 
        OnChatMessage(arg1, arg2, arg9) 
    end

    if event == "CHAT_MSG_SYSTEM" then 
        OnSystemMessage(arg1) 
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
