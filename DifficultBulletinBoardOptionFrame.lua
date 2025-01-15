DifficultBulletinBoard = DifficultBulletinBoard or {}
DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}
DifficultBulletinBoardDefaults = DifficultBulletinBoardDefaults or {}
DifficultBulletinBoardSavedVariables = DifficultBulletinBoardSavedVariables or {}

local optionFrame = DifficultBulletinBoardOptionFrame

local optionYOffset = 25 -- Starting vertical offset for the first option

local optionScrollChild

local tempGroupTags = {}
local tempProfessionTags = {}
local tempHardcoreTags = {}

local fontSizeOptionInputBox
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

local function addPlaceholderOptionToOptionFrame(inputLabel, labelText, defaultValue)
    -- Adjust Y offset for the new option
    optionYOffset = optionYOffset - 30

    -- Create the label (FontString)
    local label = optionScrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", optionScrollChild, "TOPLEFT", 10, optionYOffset)
    label:SetText(labelText)
    label:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)

    -- Create the input field (EditBox)
    local inputBox = CreateFrame("EditBox", inputLabel, optionScrollChild, "InputBoxTemplate")
    inputBox:SetPoint("LEFT", label, "RIGHT", 10, 0)
    inputBox:SetWidth(30)
    inputBox:SetHeight(20)
    inputBox:SetText(defaultValue)
    inputBox:EnableMouse(true)
    inputBox:SetAutoFocus(false)

    -- Adjust Y offset for the new option
    optionYOffset = optionYOffset - 30

    return inputBox
end

local function addTopicListToFrame(title, topicList, tempTags)
    local parentFrame = optionScrollChild

    -- create fontstring
    local scrollLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scrollLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
    scrollLabel:SetText("Select the " .. title .. " Topics you want to observe:")
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)

    optionYOffset = optionYOffset - 30

    for _, topic in ipairs(topicList) do
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

        optionYOffset = optionYOffset - 30 -- Adjust the vertical offset for the next row
    end
end

function DifficultBulletinBoardOptionFrame.InitializeOptionFrame()
    addScrollFrameToOptionFrame()
    fontSizeOptionInputBox = addPlaceholderOptionToOptionFrame("DifficultBulletinBoardOptionFrame_Font_Size_Placeholder_Option", "Define the base Font Size:", DifficultBulletinBoardVars.fontSize)
    groupOptionInputBox = addPlaceholderOptionToOptionFrame("DifficultBulletinBoardOptionFrame_Group_Placeholder_Option", "Number of Placeholders per Group Topic:", DifficultBulletinBoardVars.numberOfGroupPlaceholders)
    addTopicListToFrame("Group", DifficultBulletinBoardVars.allGroupTopics, tempGroupTags)
    professionOptionInputBox = addPlaceholderOptionToOptionFrame("DifficultBulletinBoardOptionFrame_Profession_Placeholder_Option", "Number of Placeholders per Profession Topic:", DifficultBulletinBoardVars.numberOfProfessionPlaceholders)
    addTopicListToFrame("Profession", DifficultBulletinBoardVars.allProfessionTopics, tempProfessionTags)
    hardcoreOptionInputBox = addPlaceholderOptionToOptionFrame("DifficultBulletinBoardOptionFrame_Hardcore_Placeholder_Option", "Number of Placeholders per Hardcore Topic:", DifficultBulletinBoardVars.numberOfHardcorePlaceholders)
    addTopicListToFrame("Hardcore", DifficultBulletinBoardVars.allHardcoreTopics, tempHardcoreTags)
end

function DifficultBulletinBoard_ResetVariablesAndReload()
    DifficultBulletinBoardSavedVariables.version = DifficultBulletinBoardDefaults.version

    DifficultBulletinBoardSavedVariables.fontSize = DifficultBulletinBoardDefaults.defaultFontSize

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

    DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = groupOptionInputBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = professionOptionInputBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = hardcoreOptionInputBox:GetText()
    
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allGroupTopics, tempGroupTags); 
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allProfessionTopics, tempProfessionTags); 
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allHardcoreTopics, tempHardcoreTags); 

    ReloadUI();
end