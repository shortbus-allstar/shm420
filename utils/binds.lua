local mq = require('mq')
local chase = require('routines.campchase')
local configmod = require('interface.getconfig')
local state = require('utils.state')
local heals = require('routines.heal')


local M = {}

function M.parse(arg1)
    print(mq.parse(arg1))
end

function M.shmbind(arg1,arg2)
    if arg1 == 'camp' then 
        if not arg2 then
            if tostring(state.config.General.ReturnToCamp) == 'Off' then
                print('\ay[\amSHM\ag420\ay]\am:\at Camphere: On')
                state.config.General.ReturnToCamp = 'On'
                state.config.General.ChaseAssist = 'Off'
                state.campxloc, state.campyloc, state.campzloc = chase.setcamp()
            elseif tostring(state.config.General.ReturnToCamp) == 'On' then 
                print('\ay[\amSHM\ag420\ay]\am:\at Camphere: Off')
                state.config.General.ReturnToCamp = 'Off'
            end
        elseif arg2 == 'On' or arg2 == 'on' then
            print('\ay[\amSHM\ag420\ay]\am:\at Camphere: On')
            state.config.General.ReturnToCamp = 'On'
            state.config.General.ChaseAssist = 'Off'
            state.campxloc, state.campyloc, state.campzloc = chase.setcamp()
        elseif arg2 == 'Off' or arg2 == 'off' then
            print('\ay[\amSHM\ag420\ay]\am:\at Camphere: Off')
            state.config.General.ReturnToCamp = 'Off'
        end
    end
    if arg1 == 'chase' then 
        if not arg2 then
            if tostring(state.config.General.ChaseAssist) == 'On' then
                print('\ay[\amSHM\ag420\ay]\am:\at Chase: Off')
                state.config.General.ChaseAssist = 'Off'
            elseif tostring(state.config.General.ChaseAssist) == 'Off' then 
                print('\ay[\amSHM\ag420\ay]\am:\at Chase: On')
                state.config.General.ReturnToCamp = 'Off'
                state.config.General.ChaseAssist = 'On'
            end
        elseif arg2 == 'On' or arg2 == 'on' then
            print('\ay[\amSHM\ag420\ay]\am:\at Chase: On')
            state.config.General.ReturnToCamp = 'Off'
            state.config.General.ChaseAssist = 'On'
        elseif arg2 == 'Off' or arg2 == 'off' then
            print('\ay[\amSHM\ag420\ay]\am:\at Chase: Off')
            state.config.General.ChaseAssist = 'Off'
        end
    end
    if arg1 == 'melee' then
        if not arg2 then
            if tostring(state.config.Combat.Melee) == 'On' then
                print('\ay[\amSHM\ag420\ay]\am:\at Melee: Off')
                state.config.Combat.Melee = 'Off'
            elseif tostring(state.config.Combat.Melee) == 'Off' then 
                print('\ay[\amSHM\ag420\ay]\am:\at Melee: On')
                state.config.Combat.Melee = 'On'
            end
        elseif arg2 == 'On' or arg2 == 'on' then
            print('\ay[\amSHM\ag420\ay]\am:\at Melee: On')
            state.config.Combat.Melee = 'On'
        elseif arg2 == 'Off' or arg2 == 'off' then
            print('\ay[\amSHM\ag420\ay]\am:\at Melee: Off')
            state.config.Combat.Melee = 'Off'
        end
    end
end

function M.testbind()
    for _, spawn in ipairs(mq.getFilteredSpawns(function(s) return s.Type() == 'Corpse' and s.Distance() <= 100 end)) do
        if spawn and spawn.LineOfSight() then
            local insertstatus, priority = heals.corpses(spawn)
            if insertstatus == true then 
                if priority == 'tank' then 
                    table.insert(state.rezTable,1,spawn)
                elseif priority == 'group' then
                    if not state.rezTable[1] then
                        table.insert(state.rezTable,1,spawn)
                    else
                        table.insert(state.rezTable,spawn)
                    end
                elseif priority == 'raid' then
                    if not state.rezTable[1] then
                        table.insert(state.rezTable,1,spawn)
                    else
                        table.insert(state.rezTable,spawn)
                    end
                elseif priority == 'self' then
                    table.insert(state.rezTable,#state.rezTable+1,spawn)
                end
            end
        end
    end
    for k, _ in pairs(state.rezTable) do
        print(state.rezTable[k])
    end
end

function M.var(key, newValue)
    local parts = {}
    for part in key:gmatch("[^.]+") do
        table.insert(parts, part)
    end

    local currentTable = state
    for i, part in ipairs(parts) do
        if currentTable[part] == nil then
            print("\atError: Invalid key or nested structure.")
            return
        end

        if i == #parts then
            -- Print current value
            print("\atCurrent value: \ar", currentTable[part])

            -- Update the value if a new value is provided
            if newValue then
                -- Convert newValue based on the original value's type
                local originalType = type(currentTable[part])

                if originalType == "boolean" then
                    currentTable[part] = newValue == "true"
                elseif originalType == "number" then
                    currentTable[part] = tonumber(newValue) or currentTable[part]
                else
                    currentTable[part] = newValue
                end

                print("\atValue updated to: \ar", currentTable[part])
            end
        else
            currentTable = currentTable[part]
        end
    end
end


function M.configreload()
    state.config = configmod.initConfig(configmod.path)
end

return M



