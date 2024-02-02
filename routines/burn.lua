local mq = require('mq')
local state = require('utils.state')
local write = require('utils.Write')
local M = {}

local function parseUserInput(input)
    write.Trace('parse user input')
    -- Define a pattern to capture two strings separated by '|'
    local pattern = "([^|]+)|([^|]+)"

    -- Use string.match to capture the substrings
    local abil, abilType = string.match(input, pattern)

    -- Check if both substrings were captured
    if abil and abilType then
        return tostring(abil), tostring(abilType)
    else
        -- Return nil or handle the case where the input doesn't match the expected pattern
        return nil, nil
    end
end

function M.getBurns()
    write.Trace('getting burns')
    local bburn1abil, bburn1type = parseUserInput(tostring(state.config.Burn.BBurn1))
    local bburn2abil, bburn2type = parseUserInput(tostring(state.config.Burn.BBurn2))
    local bburn3abil, bburn3type = parseUserInput(tostring(state.config.Burn.BBurn3))
    local bburn4abil, bburn4type = parseUserInput(tostring(state.config.Burn.BBurn4))
    local bburn5abil, bburn5type = parseUserInput(tostring(state.config.Burn.BBurn5))
    local bburn6abil, bburn6type = parseUserInput(tostring(state.config.Burn.BBurn6))
    local bburn7abil, bburn7type = parseUserInput(tostring(state.config.Burn.BBurn7))
    local bburn8abil, bburn8type = parseUserInput(tostring(state.config.Burn.BBurn8))
    
    local sburn1abil, sburn1type = parseUserInput(tostring(state.config.Burn.SBurn1))
    local sburn2abil, sburn2type = parseUserInput(tostring(state.config.Burn.SBurn2))
    local sburn3abil, sburn3type = parseUserInput(tostring(state.config.Burn.SBurn3))
    local sburn4abil, sburn4type = parseUserInput(tostring(state.config.Burn.SBurn4))
    local sburn5abil, sburn5type = parseUserInput(tostring(state.config.Burn.SBurn5))
    local sburn6abil, sburn6type = parseUserInput(tostring(state.config.Burn.SBurn6))
    local sburn7abil, sburn7type = parseUserInput(tostring(state.config.Burn.SBurn7))
    local sburn8abil, sburn8type = parseUserInput(tostring(state.config.Burn.SBurn8))

    local burns = {
        BBIf = mq.parse(state.config.Burn.BigBurnIf),
        SBIf = mq.parse(state.config.Burn.SmallBurnIf),
        bburn1 = {
            bburn1abil, bburn1type
        },
        bburn2 = {
            bburn2abil, bburn2type
        },
        bburn3 = {
            bburn3abil, bburn3type
        },
        bburn4 = {
            bburn4abil, bburn4type
        },
        bburn5 = {
            bburn5abil, bburn5type
        },
        bburn6 = {
            bburn6abil, bburn6type
        },
        bburn7 = {
            bburn7abil, bburn7type
        },
        bburn8 = {
            bburn8abil, bburn8type
        },
        sburn1 = {
            sburn1abil, sburn1type
        },
        sburn2 = {
            sburn2abil, sburn2type
        },
        sburn3 = {
            sburn3abil, sburn3type
        },
        sburn4 = {
            sburn4abil, sburn4type
        },
        sburn5 = {
            sburn5abil, sburn5type
        },
        sburn6 = {
            sburn6abil, sburn6type
        },
        sburn7 = {
            sburn7abil, sburn7type
        },
        sburn8 = {
            sburn8abil, sburn8type
        }
    }

    return burns
end

function M.addtoBurnQueue(name, typee)
    local data = {}
    local altready = mq.TLO.Me.AltAbilityReady(tostring(name))()
    local spellready = mq.TLO.Cast.Ready(tostring(name))()
    
    if name then
        write.Debug(name)
    else
        write.Error('Shit went bad in your burn routine again mfker')
        return
    end
    
    -- Check if alt ability is not ready
    if typee == 'item' and spellready == false then
        write.Info('Alt ability not ready')
        return
    end
    
    -- Check if spell is not ready
    if typee == 'alt' and altready == false then
        write.Info('Spell not ready')
        return
    end
    
    data.name = tostring(name)
    data.type = typee
    state.burnqueue[#state.burnqueue + 1] = data
end



function M.doBigBurns()
    local burns = M.getBurns()
    if burns.bburn1[1] then
        M.addtoBurnQueue(burns.bburn1[1],burns.bburn1[2])
    end
    if burns.bburn2[1] then
        M.addtoBurnQueue(burns.bburn2[1],burns.bburn2[2])
    end
    if burns.bburn3[1] then
        M.addtoBurnQueue(burns.bburn3[1], burns.bburn3[2])
    end
    if burns.bburn4[1] then
        M.addtoBurnQueue(burns.bburn4[1], burns.bburn4[2])
    end
    if burns.bburn5[1] then
        M.addtoBurnQueue(burns.bburn5[1], burns.bburn5[2])
    end
    if burns.bburn6[1] then
        M.addtoBurnQueue(burns.bburn6[1], burns.bburn6[2])
    end
    if burns.bburn7[1] then
        M.addtoBurnQueue(burns.bburn7[1], burns.bburn7[2])
    end
    if burns.bburn8[1] then
        M.addtoBurnQueue(burns.bburn8[1], burns.bburn8[2])
    end 
    if tostring(state.config.Burn.SmallWithBig) == 'On' then M.doSmallBurns() end
end

function M.doSmallBurns()
    local burns = M.getBurns()
    if burns.sburn1[1] then
        M.addtoBurnQueue(burns.sburn1[1], burns.sburn1[2])
    end
    if burns.sburn2[1] then
        M.addtoBurnQueue(burns.sburn2[1], burns.sburn2[2])
    end
    if burns.sburn3[1] then
        M.addtoBurnQueue(burns.sburn3[1], burns.sburn3[2])
    end
    if burns.sburn4[1] then
        M.addtoBurnQueue(burns.sburn4[1], burns.sburn4[2])
    end
    if burns.sburn5[1] then
        M.addtoBurnQueue(burns.sburn5[1], burns.sburn5[2])
    end
    if burns.sburn6[1] then
        M.addtoBurnQueue(burns.sburn6[1], burns.sburn6[2])
    end
    if burns.sburn7[1] then
        M.addtoBurnQueue(burns.sburn7[1], burns.sburn7[2])
    end
    if burns.sburn8[1] then
        M.addtoBurnQueue(burns.sburn8[1], burns.sburn8[2])
    end
end

return M
