local mq = require('mq')
local write = require('utils.Write')
local cfgpath = mq.configDir .. "\\SHM420_" .. mq.TLO.Me.CleanName() .. ".ini"


local M = {path = cfgpath}

M.defaults = {
	['Ancestral Aid'] = {
		['name'] = 'Ancestral Aid',
		['type'] = 'alt',
		['tar'] = 'None',
		['cond'] = '${If[(${Me.Song[Fierce Eye].ID}||${Target.Named}) && ${Me.CombatState.Equal[COMBAT]},1,0]}',
	},
	['Barbarian Hunting Spear'] = {
		['name'] = 'Barbarian Hunting Spear',
		['type'] = 'item',
		['tar'] = 'None',
		['cond'] = '${If[${SpawnCount[npc radius 50 zradius 10]}>=5 && ${Me.CombatState.Equal[COMBAT]},1,0]}',
	},
	['Spire of Ancestors'] = {
		['name'] = 'Spire of Ancestors',
		['type'] = 'alt',
		['tar'] = 'None',
		['cond'] = '${If[(${Me.Song[Fierce Eye].ID}||${Target.Named}) && ${Me.CombatState.Equal[COMBAT]},1,0]}',
	},
	['Pack of Wurt'] = {
		['name'] = 'Pack of Wurt',
		['type'] = 'spell',
		['tar'] = 'None',
		['cond'] = '${If[!${Me.Buff[Pack of Wurt].ID} && !${Select[${Zone.ID},151,202,203,219,344,345,463,737,33480,33113]},1,0]}',
	},
	['newcond'] = {
		['name'] = '',
		['type'] = 'spell',
		['tar'] = 'None',
		['cond'] = '',
	},
	['Rabid Bear'] = {
		['name'] = 'Rabid Bear',
		['type'] = 'alt',
		['tar'] = 'None',
		['cond'] = '${If[${SpawnCount[npc radius 50 zradius 10]}>=5 && ${Me.CombatState.Equal[COMBAT]},1,0]}',
	},
	['Spirit Call'] = {
		['name'] = 'Spirit Call',
		['type'] = 'alt',
		['tar'] = 'MA Target',
		['cond'] = '${If[(${Me.Song[Fierce Eye].ID}||${Target.Named}) && ${Me.CombatState.Equal[COMBAT]},1,0]}',
	},
	['Distillate of Celestial Healing XV'] = {
		['name'] = 'Distillate of Celestial Healing XV',
		['type'] = 'item',
		['tar'] = 'None',
		['cond'] = '${If[${Me.PctHPs}<=45,1,0]}',
	},
}

M.events = {
    newevent = {
        trig = '',
        cmd = '',
        cmddelay = 10,
        loopdelay = 0
    },

    {
        trig = '#1# tells you, #*#',
        cmd = '/echo #1# sent me a tell',
        cmddelay = '10',
        loopdelay = '0'
    },

    {
        trig = '#1# tells the group, \'Heal me\'',
        cmd = '/multiline ; /stopcast ; /timed 2 /tar #1# ; /timed 5 /cast 1',
        cmddelay = '100',
        loopdelay = '4500'
    }
}

M.iniorder = {'General', 'Buffs', 'KeywordCustom', 'Heals', 'Combat', 'Shaman', 'Pet', 'Spells', 'Powersource', 'Burn'}

function M.getConds()
    local configData, err = loadfile(mq.luaDir .. "\\shm420\\utils\\conditions.lua")
    if err then 
        write.Info('Conditions lua not found, generating defaults')
        mq.pickle(mq.luaDir .. "\\shm420\\utils\\conditions.lua", M.defaults)
    elseif configData then
        write.Info('Conditions found at %s',mq.luaDir .. "\\shm420\\utils\\conditions.lua")
        M.defaults = configData()
    end
    return M.defaults
end

function M.getEvents()
    local configData, err = loadfile(mq.luaDir .. "\\shm420\\utils\\eventcfg.lua")
    if err then 
        write.Info('Events lua not found, generating defaults')
        mq.pickle(mq.luaDir .. "\\shm420\\utils\\eventcfg.lua", M.events)
    elseif configData then
        write.Info('Events found at %s',mq.luaDir .. "\\shm420\\utils\\eventcfg.lua")
        M.events = configData()
    end
    return M.events
end

function M.initConfig(cfgpath)
    local cfgtable = {}
    local sectionOrder = {}

    local defaultConfigPath = mq.TLO.Lua.Dir().."\\SHM420\\interface\\defconfig.ini"
    local defaultConfigFile = assert(io.open(defaultConfigPath, "r"))
    local defaultConfigData = defaultConfigFile:read("*all")
    defaultConfigFile:close()

    local defaultCfgtable = {}
    local defaultSectionOrder = {}
    local currentSection = nil

    for line in defaultConfigData:gmatch("([^\r\n]*)\r?\n") do
        local section = line:match("^%[([^%]]+)%]$")
        if section then
            currentSection = section
            table.insert(defaultSectionOrder, currentSection)
            defaultCfgtable[currentSection] = { order = {} }
        else
            local key, value = line:match("^([^=]+)=(.+)$")
            if key and value and currentSection then
                table.insert(defaultCfgtable[currentSection].order, key)
                defaultCfgtable[currentSection][key] = value
            end
        end
    end

    -- Attempt to read the INI file
    local cfgfile = io.open(cfgpath, "r")
    if cfgfile then
        -- If the INI file exists, parse it into a Lua table
        printf('\ay[\amSHM\ag420\ay]\am:\at INI file found at %s. Rolling up...', cfgpath)
        currentSection = nil

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

        -- Check for missing keys and add them
        for section, keys in pairs(defaultCfgtable) do
            if not cfgtable[section] then
                cfgtable[section] = { order = {} }
            end
            for _, key in ipairs(keys.order) do
                if not cfgtable[section][key] then
                    table.insert(cfgtable[section].order, key)
                    cfgtable[section][key] = defaultCfgtable[section][key]
                end
            end
        end
    else
        -- If the INI file doesn't exist, create it from a default config
        print('\ay[\amSHM\ag420\ay]\am:\at INI file not found. Hitting the dispo...')

        -- Create the INI file using the default config data
        local newConfigFile = assert(io.open(cfgpath, "w"))
        newConfigFile:write(defaultConfigData)
        newConfigFile:close()

        -- Reload the newly created INI file to ensure all keys are captured
        return M.initConfig(cfgpath)
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
