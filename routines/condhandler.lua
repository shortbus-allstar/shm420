local mq = require('mq')
local write = require('utils.Write')
local state = require('utils.state')

local mod = {}

function mod.checkConds()
    local conditions = {}
    for k, _ in pairs(state.config.conds) do
        if k ~= 'newcond' then
            local result = mq.parse(state.config.conds[k].cond)
            conditions[k] = result
            write.Trace('%s: %s', k, result)
        end
    end
    return conditions
end

function mod.addtoCondQueue(name, type, tar)
    local tarid = 0
    local data = {}
    local altready = mq.TLO.Me.AltAbilityReady(tostring(name))()
    local spellready = mq.TLO.Me.GemTimer(tostring(name))() == 0 or state.canmem == true
    local itemready = mq.TLO.FindItem(name).TimerReady() == 0

    if type == 'cmd' then mq.cmdf(name) return end

    if tar == 'None' then tarid = 0 end
    if tar == 'Tank' then tarid = (mq.TLO.Group.MainTank.ID() or 0) end
    if tar == 'MA Target' then tarid = (mq.TLO.Me.GroupAssistTarget.ID() or 0) end
    if tar == 'Self' then tarid = state.loop.ID end
    
    if name then
        write.Debug(name)
    else
        write.Error('Shit went bad in your burn routine again mfker')
        return
    end
    -- Check if alt ability is not ready
    if type == 'item' and itemready == false then
        write.Info('Item not ready')
        return
    end
    
    -- Check if spell is not ready
    if type == 'alt' and altready == false then
        write.Info('AA not ready')
        return
    end

    if type == 'spell' and spellready == false then
        write.Info('Spell not ready')
        return
    end
    
    data.name = tostring(name)
    data.type = type
    data.tar = tarid
    state.condqueue[#state.condqueue + 1] = data
end

function mod.checkcondTimer(table)
    write.Trace('checkCond name')
    if table.type == 'alt' and mq.TLO.Me.AltAbility(table.name).Spell.MyCastTime() then 
        if mq.TLO.Me.AltAbility(table.name).Spell.MyCastTime() ~= 0 then 
            return mq.TLO.Me.AltAbility(table.name).Spell.MyCastTime() + 1000 
        else return 10000 end
    end
    if table.type == 'spell' and mq.TLO.Spell(table.name).MyCastTime() then return mq.TLO.Spell(table.name).MyCastTime() + 5000 end
    if table.type == 'item' and mq.TLO.FindItem(table.name).CastTime() then return mq.TLO.FindItem(table.name).CastTime() + 5000 end
    if table.type == 'cmd' then return 1000 end
end

function mod.doConds()
    local conditions = mod.checkConds()
    for k, _ in pairs(state.config.conds) do
        if k ~= 'newcond' then
            if not state.condtimers[k] then state.condtimers[k] = 0 end
            if k == 'Pack of Wurt' then write.Trace(tonumber((mq.gettime() - state.condtimers[k]))) end
                if k == 'Pack of Wurt' then write.Trace(tonumber(mod.checkcondTimer(state.config.conds[k]))) end
            if tonumber(conditions[k]) == 1 and (mq.gettime() - state.condtimers[k]) >= mod.checkcondTimer(state.config.conds[k]) then
                for k2, _ in pairs(state.condqueue) do
                    if state.condqueue[k2].name == state.config.conds[k].name then write.Debug('already queued') return end
                end
                write.Debug('add to q')
                mod.addtoCondQueue(state.config.conds[k].name,state.config.conds[k].type,state.config.conds[k].tar)
                state.condtimers[k] = mq.gettime()
            end
        end    
    end
end

return mod