local mq = require('mq')
local state = require('utils.state')
local write = require('utils.Write')
local M = {}
local config = state.config

function M.checkMelee()
    if tostring(state.config.Combat.Melee) == 'On' then
        if mq.TLO.Target.ID() ~= mq.TLO.Me.GroupAssistTarget.ID() then
            mq.cmdf('/squelch /mqt id %s',mq.TLO.Me.GroupAssistTarget.ID())
            mq.delay(750)
        end
        mq.cmd('/squelch /face')
        if mq.TLO.Target.ID() ~= 0 and not mq.TLO.Target.Dead() and mq.TLO.Target.PctHPs() <= tonumber(state.config.Combat.AttackAt) and mq.TLO.Target.Aggressive() and mq.TLO.Target.Distance3D() <= tonumber(config.Combat.AttackRange) then
            if not mq.TLO.Me.Combat() then 
                mq.cmd('/squelch /multiline ; /stick 10 hold uw ; /timed 5 /face ; /attack on')
                mq.delay(500)
            end
            if mq.TLO.Target.ID() ~= 0 and mq.TLO.Target.Distance3D() > 11 then
                mq.cmd('/nav target 10')
                mq.delay(500)
            end
        end
        M.checkPet()
    end
end

function M.checkPet()
    if not mq.TLO.Me.GroupAssistTarget.ID() then return end
    if state.burning and not mq.TLO.Me.TributeActive() and tostring(state.config.Burn.UseTribute) == 'On' then mq.cmd('/tribute personal on') end
    if not state.burning and mq.TLO.Me.TributeActive() and tostring(state.config.Burn.UseTribute) == 'On' then mq.cmd('/tribute personal off') end

    if mq.TLO.Me.Pet() and mq.TLO.Me.GroupAssistTarget.ID ~= 0 and mq.TLO.Me.GroupAssistTarget.Aggressive() and (mq.TLO.Me.GroupAssistTarget.PctHPs() or 100) <= tonumber(state.config.Pet.PetAssist) and (not mq.TLO.Pet.Combat() or mq.TLO.Pet.Target.ID() ~= mq.TLO.Me.GroupAssistTarget.ID()) and (mq.TLO.Me.GroupAssistTarget.Distance3D() or 500) <= tonumber(state.config.Pet.PetRange) then
        mq.cmdf('/squelch /pet attack %s', mq.TLO.Me.GroupAssistTarget.ID())
    end

end

function M.handlePowerSource()
    write.Debug('\arHandling Power Source')
    if tostring(state.config.Powersource.PsEnabled) ~= 'On' then return end
    if mq.TLO.Me.CombatState() ~= 'COMBAT' and not (mq.TLO.SpawnCount("npc radius 100 zradius 10")() > 0 and mq.TLO.Me.XTarget() > 0) then
        if mq.TLO.Me.Inventory("powersource").PctPower() == 0 and not mq.TLO.Cursor.ID() and mq.TLO.Me.Inventory("powersource").Name() == tostring(state.config.Powersource.GoodPS) then
            mq.cmd('/itemnotify powersource leftmouseup')
            mq.delay(200)
            if mq.TLO.Cursor.Name() == tostring(state.config.Powersource.GoodPS) then
                mq.cmd('/destroy')
            end
        elseif mq.TLO.Me.Inventory("powersource").Name() ~= tostring(state.config.Powersource.DrainedPS) then
            mq.cmdf('/exchange "%s" powersource',tostring(state.config.Powersource.DrainedPS))
            mq.delay(50)
        end
    elseif mq.TLO.Me.CombatState() == 'COMBAT' or (mq.TLO.SpawnCount("npc radius 100 zradius 10")() >= tonumber(state.config.Powersource.GoodPSAggroMin) and mq.TLO.Me.XTarget() >= tonumber(state.config.Powersource.GoodPSAggroMin)) then
        if mq.TLO.Me.Inventory("powersource").Name() ~= tostring(state.config.Powersource.GoodPS) then
            mq.cmdf('/exchange "%s" powersource',tostring(state.config.Powersource.GoodPS))
            mq.delay(50)
        end
    end
end


return M
