-- DifficultBulletinBoardBlacklistFrame.lua
-- Handles the blacklist functionality for the Difficult Bulletin Board addon
-- Allows players to manage blacklisted messages

DifficultBulletinBoard = DifficultBulletinBoard or {}
DifficultBulletinBoardBlacklistFrame = DifficultBulletinBoardBlacklistFrame or {}

local blacklistFrame = DifficultBulletinBoardBlacklistFrame
local blacklistScrollFrame
local blacklistScrollChild

local BLACKLIST_ENTRY_HEIGHT = 35
local BLACKLIST_ENTRY_PADDING = 5
local FOOTER_HEIGHT = 30
local FOOTER_TOP_PADDING = 25  -- Padding between scroll content and footer

-- Array to track all blacklist entry frames for resize handling
local blacklistEntryFrames = {}

-- Global tracker for pending removals
local pendingMessageRemoval = nil

-- Track the keyword filter input field
local keywordFilterInput = nil

-- Helper frame for scheduling updates
local updateFrame = CreateFrame("Frame")
updateFrame:Hide()
updateFrame:SetScript("OnUpdate", function()
    -- Process any pending message removal
    if pendingMessageRemoval then
        -- Remove from saved variables
        DifficultBulletinBoardSavedVariables.messageBlacklist[pendingMessageRemoval] = nil
        
        -- Clear the pending removal
        local messageRemoved = pendingMessageRemoval
        pendingMessageRemoval = nil
        
        -- Stop the update frame
        updateFrame:Hide()
        
        -- Refresh the list
        DifficultBulletinBoardBlacklistFrame.RefreshBlacklist()
        
        -- Notify user
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[DBB]|r Removed: " .. messageRemoved)
    end
end)

local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

-- Create a footer with keyword filter input
local function createKeywordFilterFooter()
    -- Create footer frame
    local footer = CreateFrame("Frame", "DifficultBulletinBoardKeywordFilterFooter", blacklistFrame)
    footer:SetHeight(FOOTER_HEIGHT)
    footer:SetPoint("BOTTOMLEFT", blacklistFrame, "BOTTOMLEFT", 15, 10)
    footer:SetPoint("BOTTOMRIGHT", blacklistFrame, "BOTTOMRIGHT", -26, 10)
    
    -- Create separator line at the top of footer
    local separator = footer:CreateTexture(nil, "BACKGROUND")
    separator:SetHeight(1)
    separator:SetPoint("TOPLEFT", footer, "TOPLEFT", 0, 0)  -- Anchor to top of footer
    separator:SetPoint("TOPRIGHT", footer, "TOPRIGHT", 0, 0)  -- Anchor to top of footer
    separator:SetTexture(1, 1, 1, 0.2)  -- Match options panel style
    
    -- Create label with spacing from the separator
    local label = footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", separator, "BOTTOMLEFT", 5, -7)  -- 7px below separator
    label:SetText("Keyword Filter (comma separated):")
    label:SetTextColor(0.9, 0.9, 0.9, 1.0)
    
    -- Create backdrop for the input
    local inputBackdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    }
    
    -- Create input field - fixed height
    local input = CreateFrame("EditBox", "DifficultBulletinBoardKeywordFilterInput", footer)
    input:SetPoint("TOPLEFT", label, "TOPRIGHT", 10, 3)
    input:SetPoint("RIGHT", footer, "RIGHT", -5, 0)  -- Only anchor right side horizontally
    input:SetHeight(18)  -- Explicitly set height to 18px
    input:SetBackdrop(inputBackdrop)
    input:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    input:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    input:SetFontObject(GameFontHighlight)
    input:SetTextColor(1, 1, 1, 1)
    input:SetAutoFocus(false)
    input:SetJustifyH("LEFT")
    input:SetJustifyV("CENTER")
    input:SetTextInsets(8, 8, 0, 0)
    
    -- Load saved keywords
    if DifficultBulletinBoardSavedVariables.keywordBlacklist then
        input:SetText(DifficultBulletinBoardSavedVariables.keywordBlacklist)
    else
        input:SetText("")
    end
    
    -- Handle text changes
    input:SetScript("OnTextChanged", function()
        local text = this:GetText()
        DifficultBulletinBoardSavedVariables.keywordBlacklist = text
    end)
    
    -- Handle focus
    input:SetScript("OnEditFocusGained", function()
        this:SetBackdropBorderColor(0.9, 0.9, 1.0, 1.0)
    end)
    
    input:SetScript("OnEditFocusLost", function()
        this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
    end)
    
    -- Handle enter and escape keys
    input:SetScript("OnEnterPressed", function()
        this:ClearFocus()
    end)
    
    input:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    -- Store reference
    keywordFilterInput = input
    
    return footer
end

-- Create a scroll frame for the blacklist panel
local function createBlacklistScrollFrame()
    -- Create the ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "DifficultBulletinBoardBlacklistScrollFrame", blacklistFrame, "UIPanelScrollFrameTemplate")
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

    -- Create the ScrollChild
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetHeight(1)
    scrollChild:SetWidth(400)

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

    return scrollFrame, scrollChild
end

-- Create an entry for a blacklisted message
local function createBlacklistEntry(message, index)
    local entry = CreateFrame(
        "Frame",
        "DifficultBulletinBoardBlacklistEntry" .. index,
        blacklistScrollChild
    )
    entry:SetHeight(BLACKLIST_ENTRY_HEIGHT)
    
    -- Calculate width based on current scrollChild width
    local entryWidth = blacklistScrollChild:GetWidth()
    entry:SetWidth(entryWidth)
    
    entry:SetPoint(
        "TOPLEFT",
        blacklistScrollChild,
        "TOPLEFT",
        0,
        -((index - 1) * (BLACKLIST_ENTRY_HEIGHT + BLACKLIST_ENTRY_PADDING))
    )

    -- Create backdrop
    entry:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    entry:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    entry:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    -- Create message text with proper width calculation
    local messageText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    messageText:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -5)
    messageText:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT", -30, 5)
    messageText:SetWidth(entryWidth - 40) -- Explicit width setting for vanilla WoW
    messageText:SetJustifyH("LEFT")
    messageText:SetJustifyV("TOP")
    messageText:SetTextColor(1, 1, 1, 1)
    messageText:SetText(message)
    
    -- Critical: Store messageText in entry for updates
    entry.messageText = messageText
    
    -- Create remove button
    local removeButton = CreateFrame("Button", nil, entry)
    removeButton:SetWidth(12)
    removeButton:SetHeight(12)
    removeButton:SetPoint("RIGHT", entry, "RIGHT", -8, 0)

    -- Style the remove button
    removeButton:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    removeButton:SetBackdropColor(0.2, 0.1, 0.1, 1.0)
    removeButton:SetBackdropBorderColor(0.4, 0.3, 0.3, 1.0)

    -- Add X texture to remove button
    local removeTexture = removeButton:CreateTexture(nil, "OVERLAY")
    removeTexture:SetTexture("Interface\\Buttons\\UI-Panel-ExitButton-Up")
    removeTexture:SetWidth(8)
    removeTexture:SetHeight(8)
    removeTexture:SetPoint("CENTER", removeButton, "CENTER", 0, 0)

    -- Store properties in the button
    removeButton.messageToRemove = message
    removeButton.textureObj = removeTexture
    removeButton.entry = entry

    -- Button hover effects
    removeButton:SetScript("OnEnter", function()
        this:SetBackdropColor(0.3, 0.1, 0.1, 1.0)
        this.textureObj:SetVertexColor(1.0, 0.8, 0.8)
    end)

    removeButton:SetScript("OnLeave", function()
        this:SetBackdropColor(0.2, 0.1, 0.1, 1.0)
        this.textureObj:SetVertexColor(1.0, 1.0, 1.0)
    end)

    -- Remove button click handler - FIXED to work in vanilla with deferred processing
    removeButton:SetScript("OnClick", function()
        -- Schedule removal for next frame update
        pendingMessageRemoval = this.messageToRemove
        updateFrame:Show() -- Start the update process
    end)

    -- Button visual feedback 
    removeButton:SetScript("OnMouseDown", function()
        this.textureObj:SetPoint("CENTER", removeButton, "CENTER", 1, -1)
    end)

    removeButton:SetScript("OnMouseUp", function()
        this.textureObj:SetPoint("CENTER", removeButton, "CENTER", 0, 0)
    end)

    -- Track this entry for resize updates
    table.insert(blacklistEntryFrames, entry)

    return entry
end

-- Update all blacklist entries when frame size changes
local function updateBlacklistEntries()
    if not blacklistScrollChild then return end
    
    -- Get new width for entries
    local newEntryWidth = blacklistScrollChild:GetWidth()
    local newTextWidth = newEntryWidth - 40
    
    -- Update each entry in the tracking array
    for i = 1, table.getn(blacklistEntryFrames) do
        local entry = blacklistEntryFrames[i]
        if entry and entry:IsShown() then
            -- Update entry width
            entry:SetWidth(newEntryWidth)
            
            -- Update text width - critical for wrapping
            if entry.messageText then
                entry.messageText:SetWidth(newTextWidth)
            end
        end
    end
end

-- Refresh the blacklist entries with stable sorting
function DifficultBulletinBoardBlacklistFrame.RefreshBlacklist()
    -- Clean up existing entries from screen
    if blacklistScrollChild then
        -- Remove any existing "no entries" message first
        local noEntriesText = getglobal("DifficultBulletinBoardNoEntriesText")
        if noEntriesText then
            noEntriesText:Hide()
            noEntriesText:SetParent(nil)
        end
        
        -- First destroy all children we're tracking
        for i = table.getn(blacklistEntryFrames), 1, -1 do
            local entry = blacklistEntryFrames[i]
            if entry then
                entry:Hide()
                entry:ClearAllPoints()
                entry:SetParent(nil)
                blacklistEntryFrames[i] = nil
            end
        end
        
        -- Then clean up by name for any stragglers
        for i = 1, 100 do
            local childName = "DifficultBulletinBoardBlacklistEntry"..i
            local child = getglobal(childName)
            if child then
                child:Hide()
                child:ClearAllPoints()
                child:SetParent(nil)
            end
        end
    end
    
    -- Clear the tracking array completely (redundant but thorough)
    while table.getn(blacklistEntryFrames) > 0 do
        table.remove(blacklistEntryFrames)
    end
    
    -- Reset scroll child height
    blacklistScrollChild:SetHeight(1)
    
    -- Sort blacklisted messages into a stable array for consistent display order
    local sortedMessages = {}
    for message, _ in pairs(DifficultBulletinBoardSavedVariables.messageBlacklist) do
        table.insert(sortedMessages, message)
    end
    table.sort(sortedMessages) -- Sort alphabetically for consistent order
    
    -- Add entries in sorted order
    local index = 1
    local totalHeight = 10 -- Initial padding
    local hasEntries = false
    
    -- Create new entries from the sorted messages
    for _, message in ipairs(sortedMessages) do
        local entry = createBlacklistEntry(message, index)
        totalHeight = totalHeight + BLACKLIST_ENTRY_HEIGHT + BLACKLIST_ENTRY_PADDING
        index = index + 1
        hasEntries = true
    end
    
    -- Update scroll child height
    blacklistScrollChild:SetHeight(totalHeight + 10)
    
    -- Show "no entries" message if needed - with a unique global name for tracking
    if not hasEntries then
        local noEntriesText = blacklistScrollChild:CreateFontString("DifficultBulletinBoardNoEntriesText", "OVERLAY", "GameFontNormal")
        noEntriesText:SetPoint("CENTER", blacklistScrollChild, "CENTER")
        noEntriesText:SetText("No blacklisted messages")
        noEntriesText:SetTextColor(0.7, 0.7, 0.7, 1)
    end
    
    -- Force update the entry widths
    updateBlacklistEntries()
end

-- Initialize the blacklist frame
function DifficultBulletinBoardBlacklistFrame.InitializeBlacklistFrame()
    -- Create the scroll frame and child
    blacklistScrollFrame, blacklistScrollChild = createBlacklistScrollFrame()
    
    -- Create the keyword filter footer
    local footer = createKeywordFilterFooter()
    
    -- Populate with initial blacklisted messages
    DifficultBulletinBoardBlacklistFrame.RefreshBlacklist()
end

-- Toggle blacklist frame visibility
function DifficultBulletinBoard_ToggleBlacklistFrame()
    if blacklistFrame:IsShown() then
        blacklistFrame:Hide()
    else
        -- Initialize if needed
        if not blacklistScrollFrame then
            DifficultBulletinBoardBlacklistFrame.InitializeBlacklistFrame()
        else
            -- Refresh to show latest blacklisted messages
            DifficultBulletinBoardBlacklistFrame.RefreshBlacklist()
        end
        
        blacklistFrame:Show()
    end
end

-- OnSizeChanged script - update scroll child and entries in real-time
blacklistFrame:SetScript("OnSizeChanged", function()
    -- Make sure we have required frames
    if not blacklistScrollChild then return end
    
    -- Set equal margins on left and right sides
    local TOTAL_HORIZONTAL_MARGIN = 40
    
    -- Update the scrollChild width
    blacklistScrollChild:SetWidth(blacklistFrame:GetWidth() - TOTAL_HORIZONTAL_MARGIN)
    
    -- Update scrollFrame size and position with FOOTER_TOP_PADDING
    if blacklistScrollFrame then
        blacklistScrollFrame:ClearAllPoints()
        blacklistScrollFrame:SetPoint("TOPLEFT", blacklistFrame, "TOPLEFT", 15, -55)
        blacklistScrollFrame:SetPoint("BOTTOMRIGHT", blacklistFrame, "BOTTOMRIGHT", -26, FOOTER_HEIGHT + FOOTER_TOP_PADDING)
        
        -- Reposition the scrollbar
        local scrollBar = getglobal(blacklistScrollFrame:GetName().."ScrollBar")
        if scrollBar then
            scrollBar:ClearAllPoints()
            scrollBar:SetPoint("TOPLEFT", blacklistScrollFrame, "TOPRIGHT", 8, 0)
            scrollBar:SetPoint("BOTTOMLEFT", blacklistScrollFrame, "BOTTOMRIGHT", 8, 0)
        end
    end
    
    -- Update all entries immediately
    updateBlacklistEntries()
end)