-- DifficultBulletinBoardVersionCheck.lua
-- Version check system with player sync capabilities for WoW 1.12.1
-- Notifies users at login if a newer version exists

-- Constants
local UPDATE_URL = "https://github.com/DeterminedPanda/DifficultBulletinBoard"
local ADDON_PREFIX = "DBBVERSION"  -- For addon communication
local hasNotified = false
local hasCheckedThisSession = false

-- ONLY UPDATE THIS NUMBER when a new version is available
-- Everyone with an older installed version will be notified
DifficultBulletinBoardDefaults.latestVersion = 10

-- Register addon communication
local versionCheckFrame = CreateFrame("Frame")
versionCheckFrame:RegisterEvent("PLAYER_LOGIN")
versionCheckFrame:RegisterEvent("CHAT_MSG_ADDON")
versionCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Broadcast version to other players
local function BroadcastVersion()
    local latestVersion = DifficultBulletinBoardDefaults.latestVersion
    
    -- Send our version in all available channels
    if GetNumRaidMembers() > 0 then
        SendAddonMessage(ADDON_PREFIX, tostring(latestVersion), "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage(ADDON_PREFIX, tostring(latestVersion), "PARTY")
    end
    
    -- Also send in guild chat if in a guild
    if IsInGuild() then
        SendAddonMessage(ADDON_PREFIX, tostring(latestVersion), "GUILD")
    end
end

-- Update known latest version without showing notification
local function UpdateLatestVersionSilently(newVersion)
    -- Store the highest known version in saved variables
    if not DifficultBulletinBoardSavedVariables.knownLatestVersion or
       DifficultBulletinBoardSavedVariables.knownLatestVersion < newVersion then
        DifficultBulletinBoardSavedVariables.knownLatestVersion = newVersion
    end
end

-- Check if addon version is outdated and show notification if needed
local function CheckVersion()
    -- Skip if already notified this session (only notify once per login)
    if hasNotified or hasCheckedThisSession then
        return
    end
    
    -- Initialize saved variables if they don't exist
    DifficultBulletinBoardSavedVariables.installedVersion = 
        DifficultBulletinBoardSavedVariables.installedVersion or DifficultBulletinBoardDefaults.latestVersion
    
    DifficultBulletinBoardSavedVariables.knownLatestVersion = 
        DifficultBulletinBoardSavedVariables.knownLatestVersion or DifficultBulletinBoardDefaults.latestVersion
    
    -- Get installed version and the highest known version
    local installedVersion = DifficultBulletinBoardSavedVariables.installedVersion
    local knownLatestVersion = DifficultBulletinBoardSavedVariables.knownLatestVersion
    
    -- Determine the highest version available (local, saved, or default)
    local highestVersion = DifficultBulletinBoardDefaults.latestVersion
    if knownLatestVersion > highestVersion then
        highestVersion = knownLatestVersion
    end
    
    -- Display notification only at login and only if user has an older version
    if installedVersion < highestVersion then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Difficult Bulletin Board:|r Version " .. 
            highestVersion .. " is now available at " .. UPDATE_URL)
        hasNotified = true
    else
        -- If user has latest version, update their saved version number
        DifficultBulletinBoardSavedVariables.installedVersion = highestVersion
    end
    
    -- Mark that we've performed the check this session
    hasCheckedThisSession = true
end

-- Process addon sync messages
local function ProcessAddonMessage(prefix, message, channel, sender)
    -- Ignore our own messages
    if sender == UnitName("player") then return end
    
    -- Check if it's a version message
    if prefix == ADDON_PREFIX then
        local syncedVersion = tonumber(message)
        if syncedVersion and syncedVersion > 0 then
            -- Found a version from another player, silently update our known version
            UpdateLatestVersionSilently(syncedVersion)
        end
    end
end

-- Event handler
versionCheckFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        -- Do login check after short delay
        versionCheckFrame:SetScript("OnUpdate", function()
            if not this.delay then
                this.delay = 0
            end
            
            this.delay = this.delay + arg1
            
            if this.delay >= 2 then
                -- Check version at login
                CheckVersion()
                
                -- Initial broadcast of our version
                BroadcastVersion()
                
                -- Stop the update timer
                this:SetScript("OnUpdate", nil)
            end
        end)
    elseif event == "CHAT_MSG_ADDON" then
        -- Process addon messages for version checking
        ProcessAddonMessage(arg1, arg2, arg3, arg4)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Broadcast our version when entering world or changing zones
        BroadcastVersion()
    end
end)