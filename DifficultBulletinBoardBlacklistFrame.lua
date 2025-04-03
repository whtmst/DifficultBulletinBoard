-- DifficultBulletinBoardBlacklistFrame.lua
-- Handles the keyword blacklist functionality for the Difficult Bulletin Board addon

DifficultBulletinBoard = DifficultBulletinBoard or {}
DifficultBulletinBoardBlacklistFrame = DifficultBulletinBoardBlacklistFrame or {}

-- Track initialization state
DifficultBulletinBoardBlacklistFrame.initialized = false

-- Add version counter to ensure unique frame names after reload
DifficultBulletinBoardBlacklistFrame.versionCounter = (DifficultBulletinBoardBlacklistFrame.versionCounter or 0) + 1
local currentVersion = DifficultBulletinBoardBlacklistFrame.versionCounter

-- Module references
local blacklistFrame = DifficultBulletinBoardBlacklistFrame
DifficultBulletinBoardBlacklistFrame.scrollFrame = nil
DifficultBulletinBoardBlacklistFrame.scrollChild = nil

-- Constants - modified for new layout
local FOOTER_HEIGHT = 160  -- Increased to accommodate the taller input box
local FOOTER_TOP_PADDING = 25  -- Padding between scroll content and footer

-- Track the keyword filter input field (changed to make it part of the frame)
DifficultBulletinBoardBlacklistFrame.keywordFilterInput = nil
local keywordFilterInput = nil  -- Keep local reference for internal use

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

-- Pre-initialization check and setup
function DifficultBulletinBoardBlacklistFrame.EnsureInitialized()
    -- Update version counter for this initialization session
    DifficultBulletinBoardBlacklistFrame.versionCounter = 
        (DifficultBulletinBoardBlacklistFrame.versionCounter or 0) + 1
    currentVersion = DifficultBulletinBoardBlacklistFrame.versionCounter
    
    -- Reset initialization after reload
    DifficultBulletinBoardBlacklistFrame.initialized = false
    
    -- Check if blacklist frame exists
    if not DifficultBulletinBoardBlacklistFrame then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[DBB]|r Error: BlacklistFrame module not found")
        return false
    end
    
    -- Initialize proper defaults
    if not DifficultBulletinBoardSavedVariables.messageBlacklist then
        DifficultBulletinBoardSavedVariables.messageBlacklist = {}
    end
    
    if not DifficultBulletinBoardSavedVariables.keywordBlacklist then
        DifficultBulletinBoardSavedVariables.keywordBlacklist = ""
    end
    
    -- Run initialization
    DifficultBulletinBoardBlacklistFrame.InitializeBlacklistFrame()
    
    return DifficultBulletinBoardBlacklistFrame.initialized
end

-- Create a footer with keyword filter input
local function createKeywordFilterFooter()
    -- Create footer frame with version in name
    local footerName = "DBB_KeywordFilterFooter_" .. currentVersion
    local footer = CreateFrame("Frame", footerName, blacklistFrame)
    footer:SetHeight(FOOTER_HEIGHT)
    footer:SetPoint("BOTTOMLEFT", blacklistFrame, "BOTTOMLEFT", 15, 10)
    footer:SetPoint("BOTTOMRIGHT", blacklistFrame, "BOTTOMRIGHT", -26, 10)
    
    -- Create title heading matching the Message Blacklist style
    local titleLabel = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    -- Repositioned to top of footer since separator is gone
    titleLabel:SetPoint("TOP", footer, "TOP", 0, 0)
    titleLabel:SetText("Keyword Blacklist")
    titleLabel:SetTextColor(0.9, 0.9, 1.0, 1.0)
    
    -- Create help text below the title
    local helpLabel = footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    helpLabel:SetPoint("TOP", titleLabel, "BOTTOM", 0, -3)
    helpLabel:SetWidth(400)
    helpLabel:SetJustifyH("CENTER")
    helpLabel:SetText("Keywords to filter from chat (separate with commas)")
    helpLabel:SetTextColor(0.8, 0.8, 0.8, 1.0)
    
    -- Create backdrop for the input box - matching main panel style
    local searchBackdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, 
        tileSize = 16, 
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    
    -- Create a ScrollFrame to contain the EditBox - with versioned name
    local scrollFrameName = "DBB_KeywordScrollFrame_" .. currentVersion
    local scrollFrame = CreateFrame("ScrollFrame", scrollFrameName, footer, "UIPanelScrollFrameTemplate")
    
    -- IMPORTANT: Use consistent margins with other scrollframes
    scrollFrame:SetPoint("TOPLEFT", footer, "TOPLEFT", 0, -40)
    scrollFrame:SetPoint("RIGHT", footer, "RIGHT", 0, 0) -- Match footer right edge exactly
    scrollFrame:SetHeight(104)
    scrollFrame:SetBackdrop(searchBackdrop)
    scrollFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    scrollFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    
    -- Style the scrollbar to match other scrollbars in the addon
    local scrollBar = getglobal(scrollFrame:GetName().."ScrollBar")
    
    -- Get references to the scroll buttons
    local upButton = getglobal(scrollBar:GetName().."ScrollUpButton")
    local downButton = getglobal(scrollBar:GetName().."ScrollDownButton")
    
    -- Hide the scroll buttons
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
    
    -- IMPORTANT: Consistent scrollbar positioning to match all other scrollbars
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 8, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 8, 0)
    
    -- Style the scroll bar to be slimmer
    scrollBar:SetWidth(8)
    
    -- Set up the thumb texture
    local thumbTexture = scrollBar:GetThumbTexture()
    thumbTexture:SetWidth(8)
    thumbTexture:SetHeight(50)
    thumbTexture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    thumbTexture:SetGradientAlpha("VERTICAL", 0.504, 0.504, 0.576, 0.7, 0.648, 0.648, 0.72, 0.9)
    
    -- Style the scroll bar track
    scrollBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = nil,
        tile = true, tileSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    scrollBar:SetBackdropColor(0.072, 0.072, 0.108, 0.3)
    
    -- Create input EditBox within the ScrollFrame with proper padding - with versioned name
    local inputName = "DBB_KeywordFilterInput_" .. currentVersion
    local input = CreateFrame("EditBox", inputName, scrollFrame)
    
    -- Account for scrollbar width in the EditBox width calculation
    local HORIZONTAL_PADDING = 16  -- 8px on each side (left/right)
    input:SetWidth(scrollFrame:GetWidth() - HORIZONTAL_PADDING)
    
    input:SetHeight(200)  -- Make it taller than visible area to enable scrolling
    input:SetFontObject(GameFontHighlight)
    input:SetTextColor(0.8, 0.8, 0.8, 1.0)
    input:SetAutoFocus(false)
    input:SetJustifyH("LEFT")
    input:SetMultiLine(true)
    input:SetMaxLetters(1000)
    input:EnableMouse(true)
    
    -- Define text insets for consistent appearance
    local TEXT_INSET_LEFT = 8
    local TEXT_INSET_RIGHT = 8
    local TEXT_INSET_TOP = 8
    local TEXT_INSET_BOTTOM = 8
    
    -- Add text insets to ensure there's padding inside the EditBox itself
    input:SetTextInsets(TEXT_INSET_LEFT, TEXT_INSET_RIGHT, TEXT_INSET_TOP, TEXT_INSET_BOTTOM)
    
    -- Position the EditBox centered in the ScrollFrame with proper padding
    input:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 8, -8)
    
    -- Set the EditBox as the ScrollFrame's scrollchild
    scrollFrame:SetScrollChild(input)
    
    -- Create placeholder text BEFORE using it
    local placeholderText = input:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    placeholderText:SetPoint("LEFT", input, "LEFT", 8, 0)  -- Adjusted left position for larger insets
    placeholderText:SetText("Filter (separate terms with commas)...")
    placeholderText:SetTextColor(0.5, 0.5, 0.5, 0.7)
    
    -- Track focus state
    input.hasFocus = false
    
    -- Load saved keywords
    if DifficultBulletinBoardSavedVariables and DifficultBulletinBoardSavedVariables.keywordBlacklist then
        input:SetText(DifficultBulletinBoardSavedVariables.keywordBlacklist)
        -- Hide placeholder if there's text
        if input:GetText() ~= "" then
            placeholderText:Hide()
        end
    else
        input:SetText("")
    end
    
    -- Handle text changes
    input:SetScript("OnTextChanged", function()
        local text = this:GetText()
        if DifficultBulletinBoardSavedVariables then
            DifficultBulletinBoardSavedVariables.keywordBlacklist = text
        end
        
        -- Sync with the main frame's input
        DifficultBulletinBoard_SyncKeywordBlacklist(text, this)
        
        -- Update placeholder visibility
        if this:GetText() == "" and not this.hasFocus then
            placeholderText:Show()
        else
            placeholderText:Hide()
        end
    end)
    
    -- Handle focus with subtle highlight effect matching main panel theme
    input:SetScript("OnEditFocusGained", function()
        this:SetBackdropBorderColor(0.4, 0.4, 0.5, 1.0)  -- Subtle highlight that fits theme
        this.hasFocus = true
        placeholderText:Hide()  -- Always hide on focus
    end)
    
    input:SetScript("OnEditFocusLost", function()
        this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)  -- Back to main panel border color
        this.hasFocus = false
        -- Show placeholder only if text is empty
        if this:GetText() == "" then
            placeholderText:Show()
        end
    end)
    
    -- Handle enter and escape keys
    input:SetScript("OnEnterPressed", function()
        this:ClearFocus()
    end)
    
    input:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    -- Store the input reference for global access
    DifficultBulletinBoardBlacklistFrame.keywordFilterInput = input
    keywordFilterInput = input  -- Local reference for internal use
    
    return footer
end

-- Create a scroll frame for the blacklist panel
local function createBlacklistScrollFrame()
    -- Create the ScrollFrame with versioned name
    local scrollFrameName = "DBB_BlacklistScrollFrame_" .. currentVersion
    local scrollFrame = CreateFrame("ScrollFrame", scrollFrameName, blacklistFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:EnableMouseWheel(true)

    -- Set ScrollFrame anchors - now using the FOOTER_TOP_PADDING constant
    scrollFrame:SetPoint("TOPLEFT", blacklistFrame, "TOPLEFT", 15, -55)
    scrollFrame:SetPoint("BOTTOMRIGHT", blacklistFrame, "BOTTOMRIGHT", -26, FOOTER_HEIGHT + FOOTER_TOP_PADDING)

    -- Get the scroll bar reference
    local scrollBar = getglobal(scrollFrame:GetName().."ScrollBar")
    
    -- Get references to the scroll buttons
    local upButton = getglobal(scrollBar:GetName().."ScrollUpButton")
    local downButton = getglobal(scrollBar:GetName().."ScrollDownButton")
    
    -- Hide the scroll buttons
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
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 8, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 8, 0)
    
    -- Style the scroll bar to be slimmer
    scrollBar:SetWidth(8)
    
    -- Set up the thumb texture
    local thumbTexture = scrollBar:GetThumbTexture()
    thumbTexture:SetWidth(8)
    thumbTexture:SetHeight(50)
    thumbTexture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    thumbTexture:SetGradientAlpha("VERTICAL", 0.504, 0.504, 0.576, 0.7, 0.648, 0.648, 0.72, 0.9)
    
    -- Style the scroll bar track
    scrollBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = nil,
        tile = true, tileSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    scrollBar:SetBackdropColor(0.072, 0.072, 0.108, 0.3)

    -- Create the ScrollChild with versioned name
    local scrollChildName = "DBB_BlacklistScrollChild_" .. currentVersion
	local scrollChild = CreateFrame("Frame", scrollChildName, scrollFrame)
	scrollChild:SetHeight(1)
	-- Change the fixed width value (400) to calculate from parent frame width
	local parentWidth = blacklistFrame:GetWidth()
	scrollChild:SetWidth(parentWidth - 40) -- Use same margin (40) as in UpdateInitialSizes

    -- Attach the ScrollChild to the ScrollFrame
    scrollFrame:SetScrollChild(scrollChild)

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

    -- Save references in the module table for global access
    DifficultBulletinBoardBlacklistFrame.scrollFrame = scrollFrame
    DifficultBulletinBoardBlacklistFrame.scrollChild = scrollChild

    return scrollFrame, scrollChild
end

-- Initialize the blacklist frame
function DifficultBulletinBoardBlacklistFrame.InitializeBlacklistFrame()
    -- Update version counter to ensure unique names after reload
    DifficultBulletinBoardBlacklistFrame.versionCounter = 
        (DifficultBulletinBoardBlacklistFrame.versionCounter or 0) + 1
    currentVersion = DifficultBulletinBoardBlacklistFrame.versionCounter
    
    -- Reset initialization flag
    DifficultBulletinBoardBlacklistFrame.initialized = false
    
    -- Create the scroll frame and child with versioned names
    local scrollFrame, scrollChild = createBlacklistScrollFrame()
    
    -- Store references in the module
    DifficultBulletinBoardBlacklistFrame.scrollFrame = scrollFrame
    DifficultBulletinBoardBlacklistFrame.scrollChild = scrollChild
    
    -- Create the keyword filter footer with versioned name
    local footer = createKeywordFilterFooter()
    
    -- Mark as initialized
    DifficultBulletinBoardBlacklistFrame.initialized = true
    
    return true
end

function DifficultBulletinBoardBlacklistFrame.UpdateInitialSizes()
    local blacklistScrollChild = DifficultBulletinBoardBlacklistFrame.scrollChild
    local blacklistScrollFrame = DifficultBulletinBoardBlacklistFrame.scrollFrame
    
    if not blacklistScrollChild or not blacklistFrame:IsShown() then return end
    
    -- Apply the same sizing logic as in OnSizeChanged
	local TOTAL_HORIZONTAL_MARGIN = 40
	blacklistScrollChild:SetWidth(blacklistFrame:GetWidth() - TOTAL_HORIZONTAL_MARGIN)
    
    -- Set the initial scrollChild width based on current frame width
    blacklistScrollChild:SetWidth(blacklistFrame:GetWidth() - TOTAL_HORIZONTAL_MARGIN)
    
    -- Make sure scrollFrame is properly positioned
    if blacklistScrollFrame then
        blacklistScrollFrame:ClearAllPoints()
        blacklistScrollFrame:SetPoint("TOPLEFT", blacklistFrame, "TOPLEFT", 15, -55)
        blacklistScrollFrame:SetPoint("BOTTOMRIGHT", blacklistFrame, "BOTTOMRIGHT", -26, FOOTER_HEIGHT + FOOTER_TOP_PADDING)
        blacklistScrollFrame:UpdateScrollChildRect()
    end
end

-- Toggle blacklist frame visibility with proper error handling
function DifficultBulletinBoard_ToggleBlacklistFrame()
    -- Make sure blacklist frame exists
    if not DifficultBulletinBoardBlacklistFrame then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[DBB]|r Error: BlacklistFrame not found")
        return
    end
    
    if DifficultBulletinBoardBlacklistFrame:IsShown() then
        DifficultBulletinBoardBlacklistFrame:Hide()
    else
        -- Reset initialization state to force recreation with new version
        DifficultBulletinBoardBlacklistFrame.initialized = false
        
        -- Create all frames with new version names
        if not DifficultBulletinBoardBlacklistFrame.InitializeBlacklistFrame() then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[DBB]|r Error: Could not initialize blacklist frame")
            return
        end
        
        -- Show the fully initialized frame
        DifficultBulletinBoardBlacklistFrame:Show()
        
        -- Force initial size updates
        DifficultBulletinBoardBlacklistFrame.UpdateInitialSizes()
    end
end

-- OnSizeChanged script - update scroll child and entries in real-time
blacklistFrame:SetScript("OnSizeChanged", function()
    -- Make sure we have required frames
    local blacklistScrollChild = DifficultBulletinBoardBlacklistFrame.scrollChild
    local blacklistScrollFrame = DifficultBulletinBoardBlacklistFrame.scrollFrame
    
    -- Get the title element and ensure it stays centered
    local titleLabel = getglobal(blacklistFrame:GetName().."_TitleLabel")
    if titleLabel then
        -- Account for the close button (22px wide + 4px margin)
        local closeButtonWidth = 26
        
        -- Calculate frame width excluding close button area
        local effectiveWidth = blacklistFrame:GetWidth() - closeButtonWidth
        
        -- Adjust position to center title in available space
        titleLabel:ClearAllPoints()
        titleLabel:SetPoint("TOP", blacklistFrame, "TOP", -closeButtonWidth/2 - -7, -10)
        titleLabel:SetWidth(effectiveWidth)
        titleLabel:SetJustifyH("CENTER") -- Ensure centering is enforced
    end
    
    -- Get the info label and ensure it stays centered
    local infoLabel = getglobal(blacklistFrame:GetName().."_InfoLabel")
    if infoLabel then
        infoLabel:SetWidth(blacklistFrame:GetWidth() - 50) -- Less width for proper wrapping
    end
    
    -- Find the keyword blacklist title and center it
    local footer = getglobal("DifficultBulletinBoardKeywordFilterFooter")
    if footer then
        for _, region in ipairs({footer:GetRegions()}) do
            -- Find the title font string (first font string with the text "Keyword Blacklist")
            if region:GetObjectType() == "FontString" and region:GetText() == "Keyword Blacklist" then
                region:ClearAllPoints()
                region:SetPoint("TOP", footer, "TOP", 0, 0)
                region:SetWidth(footer:GetWidth())
                region:SetJustifyH("CENTER") -- Ensure centering is enforced
                break
            end
        end
    end
    
    if not blacklistScrollChild then return end
    
    -- Set equal margins on left and right sides
    local TOTAL_HORIZONTAL_MARGIN = 40
    DifficultBulletinBoardBlacklistFrame.scrollChild:SetWidth(blacklistFrame:GetWidth() - TOTAL_HORIZONTAL_MARGIN)
    
    -- Update the scrollChild width
    blacklistScrollChild:SetWidth(blacklistFrame:GetWidth() - TOTAL_HORIZONTAL_MARGIN)
    
    -- Update scrollFrame size and position with FOOTER_TOP_PADDING
    if blacklistScrollFrame then
        blacklistScrollFrame:ClearAllPoints()
        blacklistScrollFrame:SetPoint("TOPLEFT", blacklistFrame, "TOPLEFT", 15, -55)
        blacklistScrollFrame:SetPoint("BOTTOMRIGHT", blacklistFrame, "BOTTOMRIGHT", -26, FOOTER_HEIGHT + FOOTER_TOP_PADDING)
    end
    
    -- Update the keyword filter footer to match the main frame width
    if footer then
        -- Update footer anchors to match the main frame
        footer:ClearAllPoints()
        footer:SetPoint("BOTTOMLEFT", blacklistFrame, "BOTTOMLEFT", 15, 10)
        footer:SetPoint("BOTTOMRIGHT", blacklistFrame, "BOTTOMRIGHT", -26, 10)
        
        -- Find and update keyword scrollframe
        local keywordScrollFrame = getglobal("DifficultBulletinBoardKeywordScrollFrame")
        if keywordScrollFrame then
            -- KEY FIX: Use consistent margins but don't double-apply the right margin
            -- The footer already has -26px right margin applied
            keywordScrollFrame:ClearAllPoints()
            keywordScrollFrame:SetPoint("TOPLEFT", footer, "TOPLEFT", 0, -40)
            -- Don't add another right margin, use 0 to match footer's edge exactly
            keywordScrollFrame:SetPoint("RIGHT", footer, "RIGHT", 0, 0)
            
            -- Update the EditBox width and ensure proper scrolling
            local editBox = DifficultBulletinBoardBlacklistFrame.keywordFilterInput
            if editBox then
                -- Ensure EditBox has enough height to justify scrolling
                editBox:SetHeight(200)
                
                -- Update EditBox width with consistent padding
                local HORIZONTAL_PADDING = 16
                editBox:SetWidth(keywordScrollFrame:GetWidth() - HORIZONTAL_PADDING)
                
                -- Make sure the EditBox is properly set as scroll child
                keywordScrollFrame:SetScrollChild(editBox)
            end
        end
    end

    -- Force a size update to ensure proper widths
    DifficultBulletinBoardBlacklistFrame.UpdateInitialSizes()

    -- Force an immediate refresh of the scrollbars
    if blacklistScrollFrame then
        local scrollBar = getglobal(blacklistScrollFrame:GetName().."ScrollBar")
        if scrollBar then
            -- Reposition scrollbar explicitly
            scrollBar:ClearAllPoints()
            scrollBar:SetPoint("TOPLEFT", blacklistScrollFrame, "TOPRIGHT", 8, 0)
            scrollBar:SetPoint("BOTTOMLEFT", blacklistScrollFrame, "BOTTOMRIGHT", 8, 0)
            
            -- Ensure consistent width
            scrollBar:SetWidth(8)
            
            -- Force scrollbar to show during resize if we have content
            if blacklistScrollChild:GetHeight() > blacklistScrollFrame:GetHeight() then
                scrollBar:Show()
                scrollBar:EnableMouse(true)
            end
        end
    end
    
    -- Also update keyword scrollbar explicitly
    local keywordScrollFrame = getglobal("DifficultBulletinBoardKeywordScrollFrame")
    if keywordScrollFrame then
        local kwScrollBar = getglobal(keywordScrollFrame:GetName().."ScrollBar")
        if kwScrollBar then
            -- Reposition scrollbar explicitly
            kwScrollBar:ClearAllPoints()
            kwScrollBar:SetPoint("TOPLEFT", keywordScrollFrame, "TOPRIGHT", 8, 0)
            kwScrollBar:SetPoint("BOTTOMLEFT", keywordScrollFrame, "BOTTOMRIGHT", 8, 0)
            
            -- Ensure consistent width
            kwScrollBar:SetWidth(8)
            
            -- Force scrollbar to always show during resize operations
            kwScrollBar:Show()
            kwScrollBar:EnableMouse(true)
            
            -- Get an EditBox reference
            local editBox = DifficultBulletinBoardBlacklistFrame.keywordFilterInput
            if editBox then
                -- Force minimum height to ensure scrolling is needed
                editBox:SetHeight(200)
                
                -- Ensure width is properly set for text wrapping
                local HORIZONTAL_PADDING = 16
                editBox:SetWidth(keywordScrollFrame:GetWidth() - HORIZONTAL_PADDING)
                
                -- Ensure proper scroll child relationship is maintained
                keywordScrollFrame:SetScrollChild(editBox)
            end
            
            -- Ensure thumb texture is visible and properly configured
            local thumbTexture = kwScrollBar:GetThumbTexture()
            if thumbTexture then
                thumbTexture:Show()
            end
        end
    end
    
    -- Force an update of all scroll frames
    if blacklistScrollFrame then
        blacklistScrollFrame:UpdateScrollChildRect()
    end
    
    if keywordScrollFrame then
        keywordScrollFrame:UpdateScrollChildRect()
    end
end)

-- Global function for syncing keyword blacklist inputs
function DifficultBulletinBoard_SyncKeywordBlacklist(text, sourceInput)
    -- Update the saved variable
    DifficultBulletinBoardSavedVariables.keywordBlacklist = text
    
    -- Update the main frame's input if it exists and isn't the source
    if DifficultBulletinBoardMainFrameKeywordInput and
       DifficultBulletinBoardMainFrameKeywordInput ~= sourceInput then
        DifficultBulletinBoardMainFrameKeywordInput:SetText(text)
    end
    
    -- Update the blacklist frame's input if it exists and isn't the source
    if DifficultBulletinBoardBlacklistFrame.keywordFilterInput and 
       DifficultBulletinBoardBlacklistFrame.keywordFilterInput ~= sourceInput then
        DifficultBulletinBoardBlacklistFrame.keywordFilterInput:SetText(text)
    end
end