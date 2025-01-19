
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


local function print(string) 
    --DEFAULT_CHAT_FRAME:AddMessage(string) 
end

function DifficultBulletinBoardVars.LoadSavedVariables()
    print("Start Loading DifficultBulletinBoardVars")

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