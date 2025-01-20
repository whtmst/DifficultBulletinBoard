
DifficultBulletinBoardSavedVariables = DifficultBulletinBoardSavedVariables or {}
DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}
DifficultBulletinBoardDefaults = DifficultBulletinBoardDefaults or {}

DifficultBulletinBoardVars.version = DifficultBulletinBoardDefaults.version

DifficultBulletinBoardVars.fontSize = DifficultBulletinBoardDefaults.defaultFontSize

DifficultBulletinBoardVars.timeFormat = DifficultBulletinBoardDefaults.defaultTimeFormat

DifficultBulletinBoardVars.numberOfGroupPlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfGroupPlaceholders
DifficultBulletinBoardVars.numberOfProfessionPlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfProfessionPlaceholders
DifficultBulletinBoardVars.numberOfHardcorePlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfHardcorePlaceholders

DifficultBulletinBoardVars.allGroupTopics = {}
DifficultBulletinBoardVars.allProfessionTopics = {}
DifficultBulletinBoardVars.allHardcoreTopics = {}

DifficultBulletinBoardSavedVariables.playerList = DifficultBulletinBoardSavedVariables.playerList or {}


local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

-- Function to add a player to the database
function DifficultBulletinBoardVars.GetPlayerClassFromDatabase(name)
    local realmName = GetRealmName()

    -- Add or update the player entry
    print("Getting Class for: " .. name)
    if DifficultBulletinBoardSavedVariables.playerList[realmName][name] then
        return DifficultBulletinBoardSavedVariables.playerList[realmName][name].class
    else
        return nil
    end
end

-- Function to add a player to the database
function DifficultBulletinBoardVars.AddPlayerToDatabase(name, class)
    local realmName = GetRealmName()

    -- Add or update the player entry
    print("Adding: " .. name .. " " .. class)
    DifficultBulletinBoardSavedVariables.playerList[realmName][name] = {
        class = class
    }

    -- Debugging: Print the players table to verify
    --print("Players data:")
    --local index = 0
    --for realm, realmPlayers in pairs(DifficultBulletinBoardSavedVariables.playerList) do
    --    print("Realm:", realm)
    --    for name, data in pairs(realmPlayers) do
    --       print(index .. ": " .. name .. " Class:" .. data.class)
    --       index = index + 1
    --    end
    --end
end


-- Function to load saved variables
function DifficultBulletinBoardVars.LoadSavedVariables()
    print("Start Loading DifficultBulletinBoardVars")

    -- Ensure the root table exists
    DifficultBulletinBoardSavedVariables = DifficultBulletinBoardSavedVariables or {}

    -- Ensure the playerList table exists
    DifficultBulletinBoardSavedVariables.playerList = DifficultBulletinBoardSavedVariables.playerList or {}

    -- Helper to get the current realm name
    local realmName = GetRealmName()

    -- Ensure the realm-specific table exists
    DifficultBulletinBoardSavedVariables.playerList[realmName] = DifficultBulletinBoardSavedVariables.playerList[realmName] or {}


    if DifficultBulletinBoardSavedVariables.version then
        local savedVersion = DifficultBulletinBoardSavedVariables.version
        
        print("version did exist " .. savedVersion)

        -- update the saved activeTopics if a new version of the topic list was released
        if savedVersion < DifficultBulletinBoardVars.version then
            print("version is older than the current version. overwriting activeTopics")

            DifficultBulletinBoardVars.allGroupTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultGroupTopics)
            DifficultBulletinBoardSavedVariables.activeGroupTopics = DifficultBulletinBoardVars.allGroupTopics

            DifficultBulletinBoardVars.allProfessionTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultProfessionTopics)
            DifficultBulletinBoardSavedVariables.activeProfessionTopics = DifficultBulletinBoardVars.allProfessionTopics

            DifficultBulletinBoardVars.allHardcoreTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultHardcoreTopics)
            DifficultBulletinBoardSavedVariables.activeHardcoreTopics = DifficultBulletinBoardVars.allHardcoreTopics

            DifficultBulletinBoardSavedVariables.version = DifficultBulletinBoardVars.version

            print("version is now " .. DifficultBulletinBoardVars.version)
        end
    else
        print("version did not exist. overwriting version")
        DifficultBulletinBoardSavedVariables.version = DifficultBulletinBoardVars.version

        print("overwriting activeTopics")
        DifficultBulletinBoardVars.allGroupTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultGroupTopics)
        DifficultBulletinBoardSavedVariables.activeGroupTopics = DifficultBulletinBoardVars.allGroupTopics

        DifficultBulletinBoardVars.allProfessionTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultProfessionTopics)
        DifficultBulletinBoardSavedVariables.activeProfessionTopics = DifficultBulletinBoardVars.allProfessionTopics

        DifficultBulletinBoardVars.allHardcoreTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultHardcoreTopics)
        DifficultBulletinBoardSavedVariables.activeHardcoreTopics = DifficultBulletinBoardVars.allHardcoreTopics
    end

    if DifficultBulletinBoardSavedVariables.fontSize and DifficultBulletinBoardSavedVariables.fontSize ~= "" then
        DifficultBulletinBoardVars.fontSize = DifficultBulletinBoardSavedVariables.fontSize
    else
        DifficultBulletinBoardVars.fontSize = DifficultBulletinBoardDefaults.defaultFontSize
        DifficultBulletinBoardSavedVariables.fontSize = DifficultBulletinBoardVars.fontSize
    end

    if DifficultBulletinBoardSavedVariables.timeFormat and DifficultBulletinBoardSavedVariables.timeFormat ~= "" then
        DifficultBulletinBoardVars.timeFormat = DifficultBulletinBoardSavedVariables.timeFormat
    else
        DifficultBulletinBoardVars.timeFormat = DifficultBulletinBoardDefaults.defaultTimeFormat
        DifficultBulletinBoardSavedVariables.timeFormat = DifficultBulletinBoardVars.timeFormat
    end

    if DifficultBulletinBoardSavedVariables.mainFrameSound and DifficultBulletinBoardSavedVariables.mainFrameSound ~= "" then
        DifficultBulletinBoardVars.mainFrameSound = DifficultBulletinBoardSavedVariables.mainFrameSound
    else
        DifficultBulletinBoardVars.mainFrameSound = DifficultBulletinBoardDefaults.defaultMainFrameSound
        DifficultBulletinBoardSavedVariables.mainFrameSound = DifficultBulletinBoardVars.mainFrameSound
    end

    if DifficultBulletinBoardSavedVariables.optionFrameSound and DifficultBulletinBoardSavedVariables.optionFrameSound ~= "" then
        DifficultBulletinBoardVars.optionFrameSound = DifficultBulletinBoardSavedVariables.optionFrameSound
    else
        DifficultBulletinBoardVars.optionFrameSound = DifficultBulletinBoardDefaults.defaultOptionFrameSound
        DifficultBulletinBoardSavedVariables.optionFrameSound = DifficultBulletinBoardVars.optionFrameSound
    end

    if DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders and DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders ~= "" then
        DifficultBulletinBoardVars.numberOfGroupPlaceholders = DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders
    else
        DifficultBulletinBoardVars.numberOfGroupPlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfGroupPlaceholders
        DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders = DifficultBulletinBoardVars.numberOfGroupPlaceholders
    end

    if DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders and DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders ~= "" then
        DifficultBulletinBoardVars.numberOfProfessionPlaceholders = DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders
    else
        DifficultBulletinBoardVars.numberOfProfessionPlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfProfessionPlaceholders
        DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders = DifficultBulletinBoardVars.numberOfProfessionPlaceholders
    end

    if DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders and DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders ~= "" then
        DifficultBulletinBoardVars.numberOfHardcorePlaceholders = DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders
    else
        DifficultBulletinBoardVars.numberOfHardcorePlaceholders = DifficultBulletinBoardDefaults.defaultNumberOfHardcorePlaceholders
        DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders = DifficultBulletinBoardVars.numberOfHardcorePlaceholders
    end

    if DifficultBulletinBoardSavedVariables.activeGroupTopics then 
        DifficultBulletinBoardVars.allGroupTopics = DifficultBulletinBoardSavedVariables.activeGroupTopics
    else
        DifficultBulletinBoardVars.allGroupTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultGroupTopics)
        DifficultBulletinBoardSavedVariables.activeGroupTopics = DifficultBulletinBoardVars.allGroupTopics
    end

    if DifficultBulletinBoardSavedVariables.activeProfessionTopics then
        DifficultBulletinBoardVars.allProfessionTopics = DifficultBulletinBoardSavedVariables.activeProfessionTopics
    else
        DifficultBulletinBoardVars.allProfessionTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultProfessionTopics)
        DifficultBulletinBoardSavedVariables.activeProfessionTopics = DifficultBulletinBoardVars.allProfessionTopics
    end

    if DifficultBulletinBoardSavedVariables.activeHardcoreTopics then
        DifficultBulletinBoardVars.allHardcoreTopics = DifficultBulletinBoardSavedVariables.activeHardcoreTopics
    else
        DifficultBulletinBoardVars.allHardcoreTopics = DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultHardcoreTopics)
        DifficultBulletinBoardSavedVariables.activeHardcoreTopics = DifficultBulletinBoardVars.allHardcoreTopics
    end

    print("Finished Loading DifficultBulletinBoardVars")
end