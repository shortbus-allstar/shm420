local mq = require('mq')
local cfgpath = mq.configDir .. "\\SHM420_" .. mq.TLO.Me.CleanName() .. ".ini"

local M = {path = cfgpath}

M.iniorder = {'General', 'Buffs', 'KeywordCustom', 'Heals', 'Combat', 'Shaman', 'Pet', 'Spells', 'Powersource', 'Burn'}

function M.initConfig(cfgpath)
    local cfgtable = {}
    local sectionOrder = {}

    -- Attempt to read the INI file
    local cfgfile = io.open(cfgpath, "r")
    if cfgfile then
        -- If the INI file exists, parse it into a Lua table
        printf('\ay[\amSHM\ag420\ay]\am:\at INI file found at %s. Rolling up...', cfgpath)
        local currentSection = nil

        for line in cfgfile:lines() do
            local section = line:match("^%[([^%]]+)%]$")
            if section then
                currentSection = section
                table.insert(sectionOrder, currentSection)
                cfgtable[currentSection] = { order = {} }
            else
                local key, value = line:match("^([^=]+)=(.+)$")
                if key and value and currentSection then
                    table.insert(cfgtable[currentSection].order, key)
                    cfgtable[currentSection][key] = value
                end
            end
        end
        cfgfile:close()
    else
        -- If the INI file doesn't exist, create it from a default config
        print('\ay[\amSHM\ag420\ay]\am:\at INI file not found. Hitting the dispo...')
        local defaultConfigPath = mq.TLO.Lua.Dir().."\\SHM420\\interface\\defconfig.ini"
        local defaultConfigFile = assert(io.open(defaultConfigPath, "r"))
        local defaultConfigData = defaultConfigFile:read("*all")
        defaultConfigFile:close()

        -- Create the INI file using the default config data
        local newConfigFile = assert(io.open(cfgpath, "w"))
        newConfigFile:write(defaultConfigData)
        newConfigFile:close()

        -- Parse the newly created INI file into a Lua table
        local currentSection = nil

        local cfgfile = io.open(cfgpath, "r")
        if cfgfile then
            for line in cfgfile:lines() do
                local section = line:match("^%[([^%]]+)%]$")
                if section then
                    currentSection = section
                    cfgtable[currentSection] = {}
                else
                    local key, value = line:match("^([^=]+)=(.+)$")
                    if key and value and currentSection then
                        cfgtable[currentSection][key] = value
                    end
                end
            end
            cfgfile:close()
        end
    end

    local iniOrder = {}
    for _, section in ipairs(sectionOrder) do
        table.insert(iniOrder, section)
        table.insert(iniOrder, " ")  -- Add a space between sections
    end

    return cfgtable
end



function M.saveConfig(cfgpath, cfgtable, sectionOrder)
    -- Open the INI file for writing
    local cfgfile = io.open(cfgpath, "w")
    if cfgfile then
        for _, section in ipairs(sectionOrder) do
            local sectionData = cfgtable[section]
            if sectionData then
                -- Write the section header
                cfgfile:write(string.format("[%s]\n", section))

                -- Write the key-value pairs
                for _, key in ipairs(sectionData.order) do
                    local value = sectionData[key]
                    cfgfile:write(string.format("%s=%s\n", key, value))
                end

                -- Add a space between sections
                cfgfile:write("\n")
            end
        end
        cfgfile:close()

        printf('\ay[\amSHM\ag420\ay]\am:\at Lua table saved to INI file at %s', cfgpath)
    else
        printf('\ay[\amSHM\ag420\ay]\am:\at Unable to open file for writing: %s', cfgpath)
    end
end


return M
