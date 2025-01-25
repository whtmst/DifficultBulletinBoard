
DifficultBulletinBoardSavedVariables = DifficultBulletinBoardSavedVariables or {}
DifficultBulletinBoardVars = DifficultBulletinBoardVars or {}
DifficultBulletinBoardDefaults = DifficultBulletinBoardDefaults or {}

DifficultBulletinBoardVars.version = DifficultBulletinBoardDefaults.version

DifficultBulletinBoardVars.fontSize = DifficultBulletinBoardDefaults.defaultFontSize

DifficultBulletinBoardVars.serverTimePosition = DifficultBulletinBoardDefaults.defaultServerTimePosition

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


local function setSavedVariable(savedVar, defaultVar, savedName)
    print("Checking saved variable for: " .. savedName)  -- Debug: Log when the function is called

    if savedVar and savedVar ~= "" then
        print("Found saved variable for " .. savedName .. ": " .. tostring(savedVar))  -- Debug: Log when saved variable is found
        return savedVar
    else
        print("Saved variable for " .. savedName .. " is missing or empty. Using default: " .. tostring(defaultVar))  -- Debug: Log when the default is used
        DifficultBulletinBoardSavedVariables[savedName] = defaultVar
        return defaultVar
    end
end


-- Function to load saved variables
function DifficultBulletinBoardVars.LoadSavedVariables()
    print("Start Loading DifficultBulletinBoardVars")

    -- Ensure the root and playerList tables exist
    DifficultBulletinBoardSavedVariables = DifficultBulletinBoardSavedVariables or {}
    DifficultBulletinBoardSavedVariables.playerList = DifficultBulletinBoardSavedVariables.playerList or {}
    local realmName = GetRealmName()
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

    -- Set the saved or default variables for different settings
    DifficultBulletinBoardVars.serverTimePosition = setSavedVariable(DifficultBulletinBoardSavedVariables.serverTimePosition, DifficultBulletinBoardDefaults.defaultServerTimePosition, "serverTimePosition")
    DifficultBulletinBoardVars.fontSize = setSavedVariable(DifficultBulletinBoardSavedVariables.fontSize, DifficultBulletinBoardDefaults.defaultFontSize, "fontSize")
    DifficultBulletinBoardVars.timeFormat = setSavedVariable(DifficultBulletinBoardSavedVariables.timeFormat, DifficultBulletinBoardDefaults.defaultTimeFormat, "timeFormat")
    DifficultBulletinBoardVars.mainFrameSound = setSavedVariable(DifficultBulletinBoardSavedVariables.mainFrameSound, DifficultBulletinBoardDefaults.defaultMainFrameSound, "mainFrameSound")
    DifficultBulletinBoardVars.optionFrameSound = setSavedVariable(DifficultBulletinBoardSavedVariables.optionFrameSound, DifficultBulletinBoardDefaults.defaultOptionFrameSound, "optionFrameSound")

    -- Set placeholders variables
    DifficultBulletinBoardVars.numberOfGroupPlaceholders = setSavedVariable(DifficultBulletinBoardSavedVariables.numberOfGroupPlaceholders, DifficultBulletinBoardDefaults.defaultNumberOfGroupPlaceholders, "numberOfGroupPlaceholders")
    DifficultBulletinBoardVars.numberOfProfessionPlaceholders = setSavedVariable(DifficultBulletinBoardSavedVariables.numberOfProfessionPlaceholders, DifficultBulletinBoardDefaults.defaultNumberOfProfessionPlaceholders, "numberOfProfessionPlaceholders")
    DifficultBulletinBoardVars.numberOfHardcorePlaceholders = setSavedVariable(DifficultBulletinBoardSavedVariables.numberOfHardcorePlaceholders, DifficultBulletinBoardDefaults.defaultNumberOfHardcorePlaceholders, "numberOfHardcorePlaceholders")

    -- Set active topics, or default if not found
    DifficultBulletinBoardVars.allGroupTopics = setSavedVariable(DifficultBulletinBoardSavedVariables.activeGroupTopics, DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultGroupTopics), "activeGroupTopics")
    DifficultBulletinBoardVars.allProfessionTopics = setSavedVariable(DifficultBulletinBoardSavedVariables.activeProfessionTopics, DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultProfessionTopics), "activeProfessionTopics")
    DifficultBulletinBoardVars.allHardcoreTopics = setSavedVariable(DifficultBulletinBoardSavedVariables.activeHardcoreTopics, DifficultBulletinBoardDefaults.deepCopy(DifficultBulletinBoardDefaults.defaultHardcoreTopics), "activeHardcoreTopics")

    print("Finished Loading DifficultBulletinBoardVars")
end