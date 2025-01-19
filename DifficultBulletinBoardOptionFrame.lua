DifficultBulletinBoard = DifficultBulletinBoard or {}
DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}
DifficultBulletinBoardDefaults = DifficultBulletinBoardDefaults or {}
DifficultBulletinBoardSavedVariables = DifficultBulletinBoardSavedVariables or {}

local optionFrame = DifficultBulletinBoardOptionFrame

local optionYOffset = 30 -- Starting vertical offset for the first option

local optionScrollChild

local tagsTextBoxWidthDelta = 260

local tempGroupTags = {}
local tempProfessionTags = {}
local tempHardcoreTags = {}

-- Option Data for Base Font Size
local baseFontSizeOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Font_Size_Input",
    labelText = "Base Font Size:",
    labelToolTip = "Adjusts the base font size for text. Other font sizes (e.g., titles) are calculated relative to this value. For example, if the base font size is 14, titles may be set 2 points higher.",
}

-- Option Data for Placeholders per Group Topic
local groupPlaceholdersOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Group_Placeholder_Input",
    labelText = "Entries per Group Topic:",
    labelToolTip = "Defines the number of entries displayed for each group topic entry.",
}

-- Option Data for Placeholders per Profession Topic
local professionPlaceholdersOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Profession_Placeholder_Input",
    labelText = "Entries per Profession Topic:",
    labelToolTip = "Specifies the number of entries displayed for each profession topic entry.",
}

-- Option Data for Placeholders per Hardcore Topic
local hardcorePlaceholdersOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Hardcore_Placeholder_Input",
    labelText = "Entries per Hardcore Topic:",
    labelToolTip = "Sets the number of entries displayed for each hardcore topic entry.",
}

local groupTopicListObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Group_TopicList",
    labelText = "Select the Group Topics to Observe:",
    labelToolTip = "Check to enable scanning for messages related to this group topic in chat. Uncheck to stop searching.\n\nTags should be separated by spaces, and only the first match will be searched. Once a match is found, the message will be added to the bulletin board.",
}

local professionTopicListObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Profession_TopicList",
    labelText = "Select the Profession Topics to Observe:",
    labelToolTip = "Check to enable scanning for messages related to this profession topic in chat. Uncheck to stop searching.\n\nTags should be separated by spaces, and only the first match will be searched. Once a match is found, the message will be added to the bulletin board.",
}

local hardcoreTopicListObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Hardcore_TopicList",
    labelText = "Select the Hardcore Topics to Observe:",
    labelToolTip = "Check to enable scanning for messages related to this hardcore topic in chat. Uncheck to stop searching.\n\nTags should be separated by spaces, and only the first match will be searched. Once a match is found, the message will be added to the bulletin board.",
}

local timeFormatDropDownItems = {
    { text = "Fixed Time (HH:MM:SS)", value = "fixed"},
    { text = "Elapsed Time (MM:SS)", value = "elapsed"}
}

local fontSizeOptionInputBox
local timeFormatDropDown
local groupOptionInputBox
local professionOptionInputBox
local hardcoreOptionInputBox

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
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

local function addScrollFrameToOptionFrame()
    local parentFrame = optionFrame

    -- Create the ScrollFrame
    local optionScrollFrame = CreateFrame("ScrollFrame", "DifficultBulletinBoardOptionFrame_ScrollFrame", parentFrame, "UIPanelScrollFrameTemplate")
    optionScrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors
    optionScrollFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -50)
    optionScrollFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -27, 75)
    optionScrollFrame:SetWidth(460)
    optionScrollFrame:SetHeight(1)

    -- Create the ScrollChild
    optionScrollChild = CreateFrame("Frame", nil, optionScrollFrame)
    optionScrollChild:SetWidth(480)
    optionScrollChild:SetHeight(1)
    optionScrollFrame:SetScrollChild(optionScrollChild)
end

local function addDropDownOptionToOptionFrame(dropdownItems)
    -- Adjust vertical offset for the dropdown
    optionYOffset = optionYOffset - 50

    -- Create a frame to hold the label and enable mouse interactions
    local labelFrame = CreateFrame("Frame", nil, optionScrollChild)
    labelFrame:SetPoint("TOPLEFT", optionScrollChild, "TOPLEFT", 0, optionYOffset)
    labelFrame:SetHeight(20)

    -- Create the label (FontString) inside the frame
    local label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetAllPoints(labelFrame)
    label:SetText("Select Time Format:")
    label:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)

    -- Set labelFrame width based on the text width with padding
    labelFrame:SetWidth(label:GetStringWidth() + 20)

    -- Add a GameTooltip to the labelFrame
    labelFrame:EnableMouse(true)
    labelFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(labelFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Choose a time format for displaying timestamps.\n\n", nil, nil, nil, nil, true)
        GameTooltip:AddLine("Fixed format displays the exact time, while elapsed format shows the time since the message was posted.", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    labelFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Create the dropdown menu
    local dropdown = CreateFrame("Frame", "ExampleDropdown", optionScrollChild, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", labelFrame, "RIGHT", 0, 0)
    
    
    local maxWidth = 0
    -- Initialize the dropdown menu
    UIDropDownMenu_Initialize(dropdown, function()
        for id, item in ipairs(dropdownItems) do
            local info = {}
            info.text = item.text
            info.value = item.value

            -- Create a hidden FontString so we can get the width of the string (this sucks I know...)
            local fontString = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fontString:SetText(info.text)
            fontString:Hide()
            
            local textWidth = fontString:GetStringWidth()

            if textWidth > maxWidth then
                maxWidth = textWidth
            end

            info.func = function()
                UIDropDownMenu_SetSelectedValue(dropdown, info.value, false)
                print("Selected: " .. info.value .. " " .. info.text)
                print(UIDropDownMenu_GetText(dropdown))
                print(UIDropDownMenu_GetSelectedValue(dropdown))
            end

            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetWidth(maxWidth + 20, dropdown)

    -- Set the default value
    UIDropDownMenu_SetSelectedValue(dropdown, DifficultBulletinBoardVars.timeFormat, false)

    return dropdown
end




local function addInputBoxOptionToOptionFrame(option, value)
    -- Adjust Y offset for the new option
    optionYOffset = optionYOffset - 50

    -- Create a frame to hold the label and allow for mouse interactions
    local labelFrame = CreateFrame("Frame", nil, optionScrollChild)
    labelFrame:SetPoint("TOPLEFT", optionScrollChild, "TOPLEFT", 0, optionYOffset)
    labelFrame:SetHeight(20)

    -- Create the label (FontString) inside the frame
    local label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetAllPoints(labelFrame) -- Make the label take up the full frame
    label:SetText(option.labelText)
    label:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)

    --set labelFrame width afterwards with padding so the label is not cut off
    labelFrame:SetWidth(label:GetStringWidth() + 20)

    -- Add a GameTooltip to the labelFrame
    labelFrame:EnableMouse(true) -- Enable mouse interactions for the frame
    labelFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(labelFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(option.labelToolTip, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    labelFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Create the input field (EditBox)
    local inputBox = CreateFrame("EditBox", option.frameName, optionScrollChild, "InputBoxTemplate")
    inputBox:SetPoint("LEFT", labelFrame, "RIGHT", 10, 0)
    inputBox:SetWidth(30)
    inputBox:SetHeight(20)
    inputBox:SetText(value)
    inputBox:EnableMouse(true)
    inputBox:SetAutoFocus(false)

    return inputBox
end

local tempTagsTextBoxes = {}
local function addTopicListToOptionFrame(topicObject, topicList)
    local parentFrame = optionScrollChild
    local tempTags = {}

    optionYOffset = optionYOffset - 30

    -- Create a frame to hold the label and allow for mouse interactions
    local labelFrame = CreateFrame("Frame", nil, optionScrollChild)
    labelFrame:SetPoint("TOPLEFT", optionScrollChild, "TOPLEFT", 0, optionYOffset)
    labelFrame:SetHeight(20)


    -- Create the label (FontString) inside the frame
    local scrollLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scrollLabel:SetAllPoints(labelFrame) -- Make the label take up the full frame
    scrollLabel:SetText(topicObject.labelText)
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)

    --set labelFrame width afterwards with padding so the label is not cut off
    labelFrame:SetWidth(scrollLabel:GetStringWidth() + 20)

    -- Add a GameTooltip to the labelFrame
    labelFrame:EnableMouse(true) -- Enable mouse interactions for the frame
    labelFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(labelFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(topicObject.labelToolTip, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    labelFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    for _, topic in ipairs(topicList) do
        optionYOffset = optionYOffset - 30 -- Adjust the vertical offset for the next row

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
        topicLabel:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
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
            tempTags[topicName] = DifficultBulletinBoard.SplitIntoLowerWords(enteredText)
        end)

        table.insert(tempTagsTextBoxes, tagsTextBox)

    end

    return tempTags
end

function DifficultBulletinBoardOptionFrame.InitializeOptionFrame()
    addScrollFrameToOptionFrame()

    fontSizeOptionInputBox = addInputBoxOptionToOptionFrame(baseFontSizeOptionObject, DifficultBulletinBoardVars.fontSize)
    
    timeFormatDropDown = addDropDownOptionToOptionFrame(timeFormatDropDownItems)

    groupOptionInputBox = addInputBoxOptionToOptionFrame(groupPlaceholdersOptionObject, DifficultBulletinBoardVars.numberOfGroupPlaceholders)
    
    tempGroupTags = addTopicListToOptionFrame(groupTopicListObject, DifficultBulletinBoardVars.allGroupTopics)
    
    professionOptionInputBox = addInputBoxOptionToOptionFrame(professionPlaceholdersOptionObject, DifficultBulletinBoardVars.numberOfProfessionPlaceholders)
    
    tempProfessionTags= addTopicListToOptionFrame(professionTopicListObject, DifficultBulletinBoardVars.allProfessionTopics)
    
    hardcoreOptionInputBox = addInputBoxOptionToOptionFrame(hardcorePlaceholdersOptionObject,DifficultBulletinBoardVars.numberOfHardcorePlaceholders)
    
    tempHardcoreTags = addTopicListToOptionFrame(hardcoreTopicListObject, DifficultBulletinBoardVars.allHardcoreTopics)
end

function DifficultBulletinBoard_ResetVariablesAndReload()
    DifficultBulletinBoardSavedVariables.version = DifficultBulletinBoardDefaults.version

    DifficultBulletinBoardSavedVariables.fontSize = DifficultBulletinBoardDefaults.defaultFontSize

    DifficultBulletinBoardSavedVariables.timeFormat = DifficultBulletinBoardDefaults.defaultTimeFormat

    DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfGroupPlaceholders
    DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfProfessionPlaceholders
    DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfHardcorePlaceholders

    DifficultBulletinBoardSavedVariables.activeGroupTopics = DifficultBulletinBoardDefaults.defaultGroupTopics
    DifficultBulletinBoardSavedVariables.activeProfessionTopics = DifficultBulletinBoardDefaults.defaultProfessionTopics
    DifficultBulletinBoardSavedVariables.activeHardcoreTopics = DifficultBulletinBoardDefaults.defaultHardcoreTopics

    ReloadUI();
end

function DifficultBulletinBoard_SaveVariablesAndReload()
    DifficultBulletinBoardSavedVariables.fontSize = fontSizeOptionInputBox:GetText()

    DifficultBulletinBoardSavedVariables.timeFormat = UIDropDownMenu_GetSelectedValue(timeFormatDropDown)

    DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = groupOptionInputBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = professionOptionInputBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = hardcoreOptionInputBox:GetText()
    
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allGroupTopics, tempGroupTags); 
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allProfessionTopics, tempProfessionTags); 
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allHardcoreTopics, tempHardcoreTags); 

    ReloadUI();
end

optionFrame:SetScript("OnSizeChanged", function()
    local tagsTextBoxWidth = optionFrame:GetWidth() - tagsTextBoxWidthDelta
    for _, msgFrame in ipairs(tempTagsTextBoxes) do
        msgFrame:SetWidth(tagsTextBoxWidth)
    end
end)