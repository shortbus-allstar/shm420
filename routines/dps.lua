local mq = require('mq')
local state = require('utils.state')
local timer = require('utils.timer')
local heals = require('routines.heal')
local queueAbility = require('utils.queue')
local write = require('utils.Write')
local M = {}

local function getspells()

    local DDs = {
    dd1 = mq.TLO.Spell(tostring(state.config.Spells.DD1)).RankName,
    dd2 = mq.TLO.Spell(tostring(state.config.Spells.DD2)).RankName,
    dd3 = mq.TLO.Spell(tostring(state.config.Spells.DD3)).RankName
    }

    local DoTs = {
    dot1 = mq.TLO.Spell(tostring(state.config.Spells.DoT1)).RankName,
    dot2 = mq.TLO.Spell(tostring(state.config.Spells.DoT2)).RankName,
    dot3 = mq.TLO.Spell(tostring(state.config.Spells.DoT3)).RankName,
    dot4 = mq.TLO.Spell(tostring(state.config.Spells.DoT4)).RankName
    }   
    return DDs, DoTs
end

local function dpstar()
    return mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.Aggressive() and mq.TLO.Target.LineOfSight() and mq.TLO.Target.PctHPs() < 100
end

function M.ddordot() 
    if mq.TLO.Me.GroupAssistTarget() and (tostring(state.config.Combat.DoTs) == 'On' or (tostring(state.config.Combat.DoTs) == 'Named' and mq.TLO.Me.GroupAssistTarget.Named())) and mq.TLO.Me.GroupAssistTarget.PctHPs() <= tonumber(state.config.Combat.DoTAt) and mq.TLO.Me.GroupAssistTarget.PctHPs() >= tonumber(state.config.Combat.DoTStop) then
        return 'DoT'
    elseif mq.TLO.Me.GroupAssistTarget() and tostring(state.config.Combat.DDs) == 'On' or (tostring(state.config.Combat.DDs) == 'Named' and mq.TLO.Me.GroupAssistTarget.Named()) and mq.TLO.Me.GroupAssistTarget.PctHPs() <= tonumber(state.config.Combat.DDAt) and mq.TLO.Me.GroupAssistTarget.PctHPs() >= tonumber(state.config.Combat.DDStop) then
        return 'DD'
    else return false end
end

function M.addtoQueue(spell,cat)
    local data = {}
    if spell then write.Debug(spell) else write.Error('Shit went bad in your dps routine again mfker') return end
    data.MemTime = mq.TLO.Spell(spell).RecastTime() + 1000
    data.ID = mq.TLO.Spell(spell).ID()
    data.cat = cat
    mq.cmdf('/memspell %s "%s"',state.config.Spells.MiscGem,spell)
    state.recastTimer = timer:new(data.MemTime)
    state.recastTimer:reset()
    write.Trace('Adding spell to mem queue')
    state.canmem = false
    state.dpsqueue[#state.dpsqueue+1] = data
end

function M.checkdpsqueue()
    if #state.dpsqueue > 0 and state.recastTimer:timerExpired() then
        write.Trace('doing dps queue')
        mq.delay(500)
        queueAbility(state.dpsqueue[1].ID,'spell',mq.TLO.Me.GroupAssistTarget.ID(),state.dpsqueue[1].cat)
        state.dpsqueue = {}
        state.canmem = true
        state.recastTimer = nil
        return true
    else return false
    end
end

function M.whichdpsspell()
    local DDs, DoTs = getspells()
    local type = M.ddordot()
    if not type then write.Debug('Shouldn\'t dps right not') return end
    if not dpstar() then write.Debug('Not valid dps target') return end
    if M.checkdpsqueue() then return end
    if type == 'DoT' then
        mq.delay(375)
        if not dpstar() then write.Debug('Not valid dps target') return end

        if not mq.TLO.Target.MyBuff(DoTs.dot1())() and mq.TLO.Cast.Ready(DoTs.dot1())() then
            queueAbility(DoTs.dot1.ID(),'spell',mq.TLO.Me.GroupAssistTarget.ID(),'DoT')
            return
        elseif not mq.TLO.Target.MyBuff(DoTs.dot2())() and mq.TLO.Cast.Ready(DoTs.dot2())() then
            queueAbility(DoTs.dot2.ID(),'spell',mq.TLO.Me.GroupAssistTarget.ID(),'DoT')
            return
        elseif not mq.TLO.Target.MyBuff(DoTs.dot3())() and mq.TLO.Cast.Ready(DoTs.dot3())() then
            queueAbility(DoTs.dot3.ID(),'spell',mq.TLO.Me.GroupAssistTarget.ID(),'DoT')
            return
        elseif not mq.TLO.Target.MyBuff(DoTs.dot4())() and mq.TLO.Cast.Ready(DoTs.dot4())() then
            queueAbility(DoTs.dot4.ID(),'spell',mq.TLO.Me.GroupAssistTarget.ID(),'DoT')
            return
        elseif not mq.TLO.Me.Gem(DoTs.dot1())() and state.canmem == true and not mq.TLO.Target.MyBuff(DoTs.dot1())() and DoTs.dot1() then
            M.addtoQueue(DoTs.dot1(),type)
            return
        elseif not mq.TLO.Me.Gem(DoTs.dot2())() and state.canmem == true and not mq.TLO.Target.MyBuff(DoTs.dot2())() and DoTs.dot2() then
            M.addtoQueue(DoTs.dot2(),type)
            return
        elseif not mq.TLO.Me.Gem(DoTs.dot3())() and state.canmem == true and not mq.TLO.Target.MyBuff(DoTs.dot3())() and DoTs.dot3() then
            M.addtoQueue(DoTs.dot3(),type)
            return
        elseif not mq.TLO.Me.Gem(DoTs.dot4())() and state.canmem == true and not mq.TLO.Target.MyBuff(DoTs.dot4())() and DoTs.dot4() then
            M.addtoQueue(DoTs.dot4(),type)
            return
        end
    end
    if type == 'DD' then
        mq.delay(375)
        if not dpstar() then write.Debug('Not valid dps target') return end
        if mq.TLO.Cast.Ready(DDs.dd1())() then
            queueAbility(DDs.dd1.ID(),'spell',mq.TLO.Me.GroupAssistTarget.ID(),'DD')
            return
        elseif mq.TLO.Cast.Ready(DDs.dd2())() then
            queueAbility(DDs.dd2.ID(),'spell',mq.TLO.Me.GroupAssistTarget.ID(),'DD')
            return
        elseif mq.TLO.Cast.Ready(DDs.dd3())() then
            queueAbility(DDs.dd3.ID(),'spell',mq.TLO.Me.GroupAssistTarget.ID(),'DD')
            return
        elseif tostring(state.config.Spells.DD1) ~= 'NULL' and not mq.TLO.Me.Gem(DDs.dd1())() and state.canmem == true and DDs.dd1() then
            M.addtoQueue(DDs.dd1(),type)
            return
        elseif tostring(state.config.Spells.DD2) ~= 'NULL' and not mq.TLO.Me.Gem(DDs.dd2())() and state.canmem == true and DDs.dd2() then
            M.addtoQueue(DDs.dd2(),type)
            return
        elseif tostring(state.config.Spells.DD3) ~= 'NULL' and not mq.TLO.Me.Gem(DDs.dd3())() and state.canmem == true and DDs.dd3() then
            M.addtoQueue(DDs.dd3(),type)
            return
        end
    end
end

function M.dodps()
    heals.doheals()
    local assisttar = mq.TLO.Me.GroupAssistTarget.ID()
    if assisttar ~= 0 then mq.cmdf('/squelch /mqt id %s',assisttar) else return end
    mq.delay(500)
    write.Debug('DPS Pause')
    M.whichdpsspell()
end

return M
