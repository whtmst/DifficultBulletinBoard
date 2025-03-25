-- DifficultBulletinBoardOptionFrame.lua
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

-- Option Data for the timestamp format
local timeFormatDropDownOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Time_Dropdown",
    labelText = "Select Time Format:",
    labelToolTip = "Choose a time format for displaying timestamps.\n\nFixed format displays the exact time, while elapsed format shows the time since the message was posted.",
    items = {
        { text = "Fixed Time (HH:MM:SS)", value = "fixed"},
        { text = "Elapsed Time (MM:SS)", value = "elapsed"}
    }
}

-- Option Data for filtering matched messages
local filterMatchedMessagesDropDownOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_FilterMatched_Dropdown",
    labelText = "Filter Matched Messages from Chat:",
    labelToolTip = "When enabled, messages that match criteria and are added to the bulletin board will be hidden from your chat window.",
    items = {
        { text = "Enable Filtering", value = "true" },
        { text = "Disable Filtering", value = "false" }
    }
}

-- Option Data for MainFrame sound being played
local mainFrameSoundDropDownOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_MainFrame_Sound_Dropdown",
    labelText = "Play Sound for Bulletin Board:",
    labelToolTip = "Enable or disable the sound that plays when the Bulletin Board is opened and closed.",
    items = {
        { text = "Enable Sound", value = "true" },
        { text = "Disable Sound", value = "false" }
    }
}

-- Option Data for OptionFrame sound being played
local optionFrameSoundDropDownOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_OptionFrame_Sound_Dropdown",
    labelText = "Play Sound for Option Window:",
    labelToolTip = "Enable or disable the sound that plays when the Optin Window is opened and closed.",
    items = {
        { text = "Enable Sound", value = "true" },
        { text = "Disable Sound", value = "false" }
    }
}

-- Option Data for the timestamp format
local serverTimePositionDropDownOptionObject = {
    frameName = "DifficultBulletinBoardOptionFrame_Server_Time_Dropdown",
    labelText = "Select Server Time Position:",
    labelToolTip = "Choose where to display the server time or disable it:\n\n" ..
    "Disabled: Hides the server time completely.\n\n" ..
    "Top Left: Displays the server time to the left of the title, at the top of the bulletin board.\n\n" ..
    "To the Right of Tab Buttons: Displays the server time on the same level as the tab buttons, sticking to the right above where the time columns normally are.",
    items = {
        { text = "Top Left of Title", value = "top-left" },
        { text = "To the Right of Tab Buttons", value = "right-of-tabs" },
        { text = "Disable Time Display", value = "disabled" }
    }
}

local fontSizeOptionInputBox
local serverTimePositionDropDown
local timeFormatDropDown
local mainFrameSoundDropDown
local optionFrameSoundDropDown
local filterMatchedMessagesDropDown
local groupOptionInputBox
local professionOptionInputBox
local hardcoreOptionInputBox

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

-- Create a global registry to manage all dropdown menus
local dropdownMenuRegistry = {}
local currentTopMenu = nil
local MENU_BASE_LEVEL = 100

-- Function to show a dropdown menu and ensure it's on top
local function showDropdownMenu(dropdown)
    local menuFrame = dropdown.menuFrame
    
    -- Hide all other menus first
    for _, otherDropdown in ipairs(dropdownMenuRegistry) do
        if otherDropdown ~= dropdown and otherDropdown.menuFrame:IsShown() then
            otherDropdown.menuFrame:Hide()
        end
    end
    
    -- Set this as the current top menu
    currentTopMenu = dropdown
    
    -- Ensure this menu is at the highest strata and level
    menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    menuFrame:SetFrameLevel(MENU_BASE_LEVEL)
    
    -- Show the menu
    menuFrame:Show()
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

-- Create scroll frame with hidden arrows and modern styling
local function addScrollFrameToOptionFrame()
    local parentFrame = optionFrame

    -- Create the ScrollFrame with modern styling
    local optionScrollFrame = CreateFrame("ScrollFrame", "DifficultBulletinBoardOptionFrame_ScrollFrame", parentFrame, "UIPanelScrollFrameTemplate")
    optionScrollFrame:EnableMouseWheel(true)

    -- Get the scroll bar reference
    local scrollBar = getglobal(optionScrollFrame:GetName().."ScrollBar")
    
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
    
    -- Adjust scroll bar position - changed from 2 to 8 pixels for consistency
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPLEFT", optionScrollFrame, "TOPRIGHT", 8, 0)
    scrollBar:SetPoint("BOTTOMLEFT", optionScrollFrame, "BOTTOMRIGHT", 8, 0)
    
    -- Style the scroll bar to be slimmer
    scrollBar:SetWidth(8)
    
    -- Set up the thumb texture with 10% darker colors
    local thumbTexture = scrollBar:GetThumbTexture()
    thumbTexture:SetWidth(8)
    thumbTexture:SetHeight(50)
    thumbTexture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    -- 10% darker gradient (multiplied color values by 0.9)
    thumbTexture:SetGradientAlpha("VERTICAL", 0.504, 0.504, 0.576, 0.7, 0.648, 0.648, 0.72, 0.9)
    
    -- Style the scroll bar track with 10% darker background
    scrollBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = nil,
        tile = true, tileSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    scrollBar:SetBackdropColor(0.072, 0.072, 0.108, 0.3)
    
    -- FIXED: Set ScrollFrame anchors to match other panels
    optionScrollFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 15, -55)
    optionScrollFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -26, 50)
    
    -- Create the ScrollChild with proper styling
    optionScrollChild = CreateFrame("Frame", nil, optionScrollFrame)
    optionScrollChild:SetWidth(optionScrollFrame:GetWidth() - 10) -- Adjusted width calculation
    optionScrollChild:SetHeight(1)
    
    -- Set the background for better visual distinction
    local background = optionScrollChild:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    background:SetGradientAlpha("VERTICAL", 0.1, 0.1, 0.1, 0.5, 0.1, 0.1, 0.1, 0.0)
    
    -- Use both mouse wheel directions for scrolling
    optionScrollFrame:SetScript("OnMouseWheel", function()
        local scrollBar = getglobal(this:GetName().."ScrollBar")
        local currentValue = scrollBar:GetValue()
        
        if arg1 > 0 then
            scrollBar:SetValue(currentValue - (scrollBar:GetHeight() / 2))
        else
            scrollBar:SetValue(currentValue + (scrollBar:GetHeight() / 2))
        end
    end)
    
    optionScrollFrame:SetScrollChild(optionScrollChild)
end

-- Dropdown option function with proper z-ordering and dynamic width
local function addDropDownOptionToOptionFrame(options, defaultValue)
    -- Adjust vertical offset for the dropdown
    optionYOffset = optionYOffset - 30

    -- Create a frame to hold the label and enable mouse interactions
    local labelFrame = CreateFrame("Frame", nil, optionScrollChild)
    labelFrame:SetPoint("TOPLEFT", optionScrollChild, "TOPLEFT", 10, optionYOffset)
    labelFrame:SetHeight(20)

    -- Create the label (FontString) inside the frame
    local label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetAllPoints(labelFrame)
    label:SetText(options.labelText)
    label:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)
    label:SetTextColor(0.9, 0.9, 0.9, 1.0)

    -- Set labelFrame width based on the text width with padding
    labelFrame:SetWidth(label:GetStringWidth() + 20)

    -- Add a GameTooltip to the labelFrame
    labelFrame:EnableMouse(true)
    labelFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(labelFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(options.labelToolTip, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    labelFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Create temporary exact clone of the GameFontHighlight to measure text properly
    local tempFont = UIParent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    local fontPath, fontSize, fontFlags = GameFontHighlight:GetFont()
    tempFont:SetFont(fontPath, fontSize, fontFlags)
    
    -- Set extra wide width to ensure accurate measurements
    tempFont:SetWidth(500)
    
    local maxTextWidth = 0

    -- Check width of dropdown items with accurate measurement
    for _, item in ipairs(options.items) do
        tempFont:SetText(item.text)
        -- Use exact pixel measurements to avoid truncation
        local width = tempFont:GetStringWidth()
        if width > maxTextWidth then
            maxTextWidth = width
        end
    end

    -- Force a bigger width for common menu options that are known to be long
    for _, item in ipairs(options.items) do
        if item.text == "Fixed Time (HH:MM:SS)" then
            -- Hardcode a minimum width for this specific item
            if maxTextWidth < 160 then
                maxTextWidth = 160
            end
        end
    end

    -- Clean up temporary font
    tempFont:Hide()

    -- Add generous padding for the dropdown (50+ pixels rather than 36)
    local dropdownWidth = maxTextWidth + 52

    -- Ensure minimum width of 150 (increased from 133)
    if dropdownWidth < 150 then
        dropdownWidth = 150
    end

    -- Create a container frame for our custom dropdown
    local dropdownContainer = CreateFrame("Frame", options.frameName.."Container", optionScrollChild)
    dropdownContainer:SetPoint("LEFT", labelFrame, "RIGHT", 10, 0)
    dropdownContainer:SetWidth(dropdownWidth)
    dropdownContainer:SetHeight(22)
    
    -- Create the dropdown button with modern styling
    local dropdown = CreateFrame("Button", options.frameName, dropdownContainer)
    dropdown:SetPoint("TOPLEFT", dropdownContainer, "TOPLEFT", 0, 0)
    dropdown:SetPoint("BOTTOMRIGHT", dropdownContainer, "BOTTOMRIGHT", 0, 0)
    
    -- Add modern backdrop
    dropdown:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    dropdown:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    dropdown:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    
    -- Create the selected text display with more right padding for arrow
    local selectedText = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    selectedText:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
    selectedText:SetPoint("RIGHT", dropdown, "RIGHT", -28, 0) -- Increased from -24 to -28
    selectedText:SetJustifyH("LEFT")
    selectedText:SetTextColor(0.9, 0.9, 0.9, 1.0)
    
    -- Create dropdown arrow texture
    local arrow = dropdown:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    arrow:SetWidth(16)
    arrow:SetHeight(16)
    arrow:SetPoint("RIGHT", dropdown, "RIGHT", -4, 0)
    
    -- Store references to the text object and value
    dropdown.value = defaultValue
    dropdown.text = selectedText
    dropdown.arrow = arrow
    
    -- Initialize with default value
    local matchFound = false
    for _, item in ipairs(options.items) do
        if item.value == defaultValue then
            selectedText:SetText(item.text)
            matchFound = true
            break
        end
    end
    
    -- Fallback: Set to first option if no match found
    if not matchFound then
        if options.items and options.items[1] then
            selectedText:SetText(options.items[1].text)
            dropdown.value = options.items[1].value
        end
    end
    
    -- Create the menu frame with matching width
    local menuFrame = CreateFrame("Frame", options.frameName.."Menu", UIParent)
    menuFrame:SetFrameStrata("TOOLTIP")
    menuFrame:SetWidth(dropdownWidth)
    menuFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
        tile = true, tileSize = 16, edgeSize = 8, 
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    menuFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    menuFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1.0)
    menuFrame:Hide()
    
    -- Create menu items
    local menuHeight = 0
    local itemHeight = 24
    
    for i, item in ipairs(options.items) do
        local menuItem = CreateFrame("Button", options.frameName.."MenuItem"..i, menuFrame)
        menuItem:SetHeight(itemHeight)
        menuItem:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 4, -4 - (i-1)*itemHeight)
        menuItem:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -4, -4 - (i-1)*itemHeight)
        
        menuItem.value = item.value
        menuItem.text = item.text
        
        -- Normal state
        menuItem:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = nil,
            tile = true, tileSize = 16, edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        menuItem:SetBackdropColor(0.12, 0.12, 0.12, 0.0)
        
        -- Item text
        local itemText = menuItem:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        itemText:SetPoint("LEFT", menuItem, "LEFT", 8, 0)
        itemText:SetPoint("RIGHT", menuItem, "RIGHT", -8, 0)
        itemText:SetJustifyH("LEFT")
        itemText:SetText(item.text)
        itemText:SetTextColor(0.9, 0.9, 0.9, 1.0)
        
        -- Highlight state - update to match headline color
        menuItem:SetScript("OnEnter", function()
            this:SetBackdropColor(0.2, 0.2, 0.25, 1.0)
            itemText:SetTextColor(0.9, 0.9, 1.0, 1.0)
        end)
        
        menuItem:SetScript("OnLeave", function()
            this:SetBackdropColor(0.12, 0.12, 0.12, 0.0)
            itemText:SetTextColor(0.9, 0.9, 0.9, 1.0)
        end)
        
        -- Click handler
        menuItem:SetScript("OnClick", function()
            dropdown.value = this.value
            dropdown.text:SetText(this.text)
            menuFrame:Hide()
        end)
        
        menuHeight = menuHeight + itemHeight
    end
    
    -- Set menu height
    menuFrame:SetHeight(menuHeight + 8)
    
    -- Position update function
    local function updateMenuPosition()
        local dropLeft, dropBottom = dropdown:GetLeft(), dropdown:GetBottom()
        if dropLeft and dropBottom then
            menuFrame:ClearAllPoints()
            menuFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", dropLeft, dropBottom - 2)
        end
    end
    
    -- Toggle menu
    dropdown:SetScript("OnClick", function()
        if menuFrame:IsShown() then
            menuFrame:Hide()
        else
            -- Hide all other open dropdown menus first
            if DROPDOWN_MENUS_LIST then
                for _, menu in ipairs(DROPDOWN_MENUS_LIST) do
                    if menu ~= menuFrame and menu:IsShown() then
                        menu:Hide()
                    end
                end
            end
            
            updateMenuPosition()
            menuFrame:Show()
        end
    end)
    
    -- Hover effect
    dropdown:SetScript("OnEnter", function()
        this:SetBackdropColor(0.15, 0.15, 0.18, 0.8)
        this:SetBackdropBorderColor(0.4, 0.4, 0.5, 1.0)
        selectedText:SetTextColor(0.9, 0.9, 1.0, 1.0)
    end)
    
    dropdown:SetScript("OnLeave", function()
        this:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
        selectedText:SetTextColor(0.9, 0.9, 0.9, 1.0)
    end)
    
    -- Store menu reference
    dropdown.menuFrame = menuFrame
    
    -- Close menu when clicking elsewhere
    if not DROPDOWN_MENUS_LIST then
        DROPDOWN_MENUS_LIST = {}
        
        -- Global click handler
        local clickHandler = CreateFrame("Frame")
        clickHandler:SetScript("OnEvent", function()
            if event == "GLOBAL_MOUSE_DOWN" then
                for _, menu in ipairs(DROPDOWN_MENUS_LIST) do
                    if menu:IsShown() then
                        menu:Hide()
                    end
                end
            end
        end)
        clickHandler:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end
    
    table.insert(DROPDOWN_MENUS_LIST, menuFrame)
    
    -- Custom functions
    dropdown.GetSelectedValue = function(self)
        return self.value
    end
    
    dropdown.SetSelectedValue = function(self, value, text)
        self.value = value
        
        if text then
            self.text:SetText(text)
        else
            for _, item in ipairs(options.items) do
                if item.value == value then
                    self.text:SetText(item.text)
                    break
                end
            end
        end
    end
    
    dropdown.GetText = function(self)
        return self.text:GetText()
    end
    
    dropdown.SetText = function(self, text)
        self.text:SetText(text)
    end
    
    return dropdown
end

local function addInputBoxOptionToOptionFrame(option, value)
    -- Adjust Y offset for the new option
    optionYOffset = optionYOffset - 30

    -- Create a frame to hold the label and allow for mouse interactions
    local labelFrame = CreateFrame("Frame", nil, optionScrollChild)
    labelFrame:SetPoint("TOPLEFT", optionScrollChild, "TOPLEFT", 10, optionYOffset)
    labelFrame:SetHeight(20)

    -- Create the label (FontString) inside the frame
    local label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetAllPoints(labelFrame) -- Make the label take up the full frame
    label:SetText(option.labelText)
    label:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)
    label:SetTextColor(0.9, 0.9, 0.9, 1.0)

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

    -- Create a backdrop for the input box for a modern look
    local inputBackdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    }

    -- Create the input field (EditBox) with modern styling
    local inputBox = CreateFrame("EditBox", option.frameName, optionScrollChild)
    inputBox:SetPoint("LEFT", labelFrame, "RIGHT", 10, 0)
    inputBox:SetWidth(33)
    inputBox:SetHeight(20)
    inputBox:SetBackdrop(inputBackdrop)
    inputBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    inputBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    inputBox:SetText(value)
    inputBox:SetFontObject(GameFontHighlight)
    inputBox:SetTextColor(1, 1, 1, 1)
    inputBox:SetAutoFocus(false)
    inputBox:SetJustifyH("CENTER")
    
    -- Add highlight effect on focus
    inputBox:SetScript("OnEditFocusGained", function()
        this:SetBackdropBorderColor(0.9, 0.9, 1.0, 1.0)
    end)
    inputBox:SetScript("OnEditFocusLost", function()
        this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    end)

    return inputBox
end

local tempTagsTextBoxes = {}
local function addTopicListToOptionFrame(topicObject, topicList)
    local parentFrame = optionScrollChild
    local tempTags = {}

    optionYOffset = optionYOffset - 30

    -- Create a frame to hold the label and allow for mouse interactions
    local labelFrame = CreateFrame("Frame", nil, optionScrollChild)
    labelFrame:SetPoint("TOPLEFT", optionScrollChild, "TOPLEFT", 10, optionYOffset)
    labelFrame:SetHeight(20)

    -- Create the label (FontString) inside the frame
    local scrollLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scrollLabel:SetAllPoints(labelFrame) -- Make the label take up the full frame
    scrollLabel:SetText(topicObject.labelText)
    scrollLabel:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize)
    scrollLabel:SetTextColor(0.9, 0.9, 1.0, 1.0)

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

    -- Create a separator line
    local separator = parentFrame:CreateTexture(nil, "BACKGROUND")
    separator:SetHeight(1)
    separator:SetWidth(450)
    separator:SetPoint("TOPLEFT", labelFrame, "BOTTOMLEFT", -5, -5)
    separator:SetTexture(1, 1, 1, 0.2)

    for _, topic in ipairs(topicList) do
        optionYOffset = optionYOffset - 30 -- Adjust the vertical offset for the next row

        -- Create modern checkbox with background
        local checkboxBg = CreateFrame("Frame", nil, parentFrame)
        checkboxBg:SetWidth(25)
        checkboxBg:SetHeight(25)
        checkboxBg:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, optionYOffset)
        
        local checkbox = CreateFrame("CheckButton", "$parent_" .. topic.name .. "_Checkbox", checkboxBg, "UICheckButtonTemplate")
        checkbox:SetWidth(25)
        checkbox:SetHeight(25)
        checkbox:SetPoint("CENTER", checkboxBg, "CENTER")
        checkbox:SetChecked(topic.selected)

        local currentTopic = topic
        checkbox:SetScript("OnClick", function()
            currentTopic.selected = checkbox:GetChecked()
        end)

        -- Add a label next to the checkbox displaying the topic with improved styling
        local topicLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        topicLabel:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
        topicLabel:SetText(topic.name)
        topicLabel:SetFont("Fonts\\FRIZQT__.TTF", DifficultBulletinBoardVars.fontSize - 2)
        topicLabel:SetTextColor(0.9, 0.9, 0.9, 1.0)
        topicLabel:SetJustifyH("LEFT")
        topicLabel:SetWidth(175)

        -- Create a backdrop for tags textbox
        local tagsBackdrop = {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        }

        -- Add a text box next to the topic label for tags input with modern styling
        local tagsTextBox = CreateFrame("EditBox", "$parent_" .. topic.name .. "_TagsTextBox", parentFrame)
        tagsTextBox:SetPoint("LEFT", topicLabel, "RIGHT", 10, 0)
        tagsTextBox:SetWidth(200)
        tagsTextBox:SetHeight(24)
        tagsTextBox:SetBackdrop(tagsBackdrop)
        tagsTextBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        tagsTextBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
        tagsTextBox:SetText(table.concat(topic.tags, " "))
        tagsTextBox:SetFontObject(GameFontHighlight)
        tagsTextBox:SetTextColor(1, 1, 1, 1)
        tagsTextBox:SetAutoFocus(false)
        tagsTextBox:SetJustifyH("LEFT")
        
        -- Add highlight effect on focus
        tagsTextBox:SetScript("OnEditFocusGained", function()
            this:SetBackdropBorderColor(0.9, 0.9, 1.0, 1.0)
        end)
        tagsTextBox:SetScript("OnEditFocusLost", function()
            this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
        end)

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

    -- Create the dropdowns with modern styling
    serverTimePositionDropDown = addDropDownOptionToOptionFrame(serverTimePositionDropDownOptionObject, DifficultBulletinBoardVars.serverTimePosition)
    
    timeFormatDropDown = addDropDownOptionToOptionFrame(timeFormatDropDownOptionObject, DifficultBulletinBoardVars.timeFormat)

    filterMatchedMessagesDropDown = addDropDownOptionToOptionFrame(filterMatchedMessagesDropDownOptionObject, DifficultBulletinBoardVars.filterMatchedMessages)

    mainFrameSoundDropDown = addDropDownOptionToOptionFrame(mainFrameSoundDropDownOptionObject, DifficultBulletinBoardVars.mainFrameSound)

    optionFrameSoundDropDown = addDropDownOptionToOptionFrame(optionFrameSoundDropDownOptionObject, DifficultBulletinBoardVars.optionFrameSound)

    groupOptionInputBox = addInputBoxOptionToOptionFrame(groupPlaceholdersOptionObject, DifficultBulletinBoardVars.numberOfGroupPlaceholders)
    
    tempGroupTags = addTopicListToOptionFrame(groupTopicListObject, DifficultBulletinBoardVars.allGroupTopics)
    
    professionOptionInputBox = addInputBoxOptionToOptionFrame(professionPlaceholdersOptionObject, DifficultBulletinBoardVars.numberOfProfessionPlaceholders)
    
    tempProfessionTags= addTopicListToOptionFrame(professionTopicListObject, DifficultBulletinBoardVars.allProfessionTopics)
    
    hardcoreOptionInputBox = addInputBoxOptionToOptionFrame(hardcorePlaceholdersOptionObject,DifficultBulletinBoardVars.numberOfHardcorePlaceholders)
    
    tempHardcoreTags = addTopicListToOptionFrame(hardcoreTopicListObject, DifficultBulletinBoardVars.allHardcoreTopics)
    
    -- Make sure scroll frame shows everything
    local totalHeight = math.abs(optionYOffset) + 100  -- Add padding
    optionScrollChild:SetHeight(totalHeight)
end

function DifficultBulletinBoard_ResetVariablesAndReload()
    DifficultBulletinBoardSavedVariables.version = DifficultBulletinBoardDefaults.version

    DifficultBulletinBoardSavedVariables.fontSize = DifficultBulletinBoardDefaults.defaultFontSize

    DifficultBulletinBoardSavedVariables.serverTimePosition = DifficultBulletinBoardDefaults.defaultServerTimePosition

    DifficultBulletinBoardSavedVariables.timeFormat = DifficultBulletinBoardDefaults.defaultTimeFormat

    DifficultBulletinBoardSavedVariables.filterMatchedMessages = DifficultBulletinBoardDefaults.defaultFilterMatchedMessages

    DifficultBulletinBoardSavedVariables.mainFrameSound = DifficultBulletinBoardDefaults.defaultMainFrameSound
    DifficultBulletinBoardSavedVariables.optionFrameSound = DifficultBulletinBoardDefaults.defaultOptionFrameSound

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

    DifficultBulletinBoardSavedVariables.timeFormat = timeFormatDropDown:GetSelectedValue()

    DifficultBulletinBoardSavedVariables.serverTimePosition = serverTimePositionDropDown:GetSelectedValue()

    DifficultBulletinBoardSavedVariables.filterMatchedMessages = filterMatchedMessagesDropDown:GetSelectedValue()

    DifficultBulletinBoardSavedVariables.mainFrameSound = mainFrameSoundDropDown:GetSelectedValue()
    DifficultBulletinBoardSavedVariables.optionFrameSound = optionFrameSoundDropDown:GetSelectedValue()

    DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = groupOptionInputBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = professionOptionInputBox:GetText()
    DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = hardcoreOptionInputBox:GetText()
    
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allGroupTopics, tempGroupTags)
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allProfessionTopics, tempProfessionTags)
    overwriteTagsForAllTopics(DifficultBulletinBoardVars.allHardcoreTopics, tempHardcoreTags)

    ReloadUI()
end

-- Function to hide all dropdown menus
function DifficultBulletinBoardOptionFrame.HideAllDropdownMenus()
    -- Hide menus in the global list
    if DROPDOWN_MENUS_LIST then
        for _, menu in ipairs(DROPDOWN_MENUS_LIST) do
            if menu:IsShown() then
                menu:Hide()
            end
        end
    end
end

optionFrame:SetScript("OnSizeChanged", function()
    local tagsTextBoxWidth = optionFrame:GetWidth() - tagsTextBoxWidthDelta
    for _, msgFrame in ipairs(tempTagsTextBoxes) do
        msgFrame:SetWidth(tagsTextBoxWidth)
    end
end)