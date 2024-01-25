local mq = require('mq')
local timer = require('utils.timer')
local state = require('utils.state')
local lib = require('utils.lib')
local write = require('utils.Write')
local timeSinceHot = timer:new(43000)

local heals = {}
local heallist = {}

function heals.getheals()
    return {
    panic = {
        soothsayer = mq.TLO.Me.AltAbility("Soothsayer's Intervention").ID(),
        union = mq.TLO.Me.AltAbility("Union of Spirits").ID(),
        ancguard = mq.TLO.Me.AltAbility("Ancestral Guard").ID(),
        ancaid = mq.TLO.Me.AltAbility("Ancestral Aid").ID(),
        healward = mq.TLO.Me.AltAbility("Call of the Ancients").ID(),
        panic1 = mq.TLO.Spell(tostring(state.config.Heals.Panic1)).RankName.ID(),
        panic2 = mq.TLO.Spell(tostring(state.config.Heals.Panic2)).RankName.ID(),
        panic3 = mq.TLO.Spell(tostring(state.config.Heals.Panic3)).RankName.ID(),
        panic4 = mq.TLO.Spell(tostring(state.config.Heals.Panic4)).RankName.ID(),
        panic5 = mq.TLO.Spell(tostring(state.config.Heals.Panic5)).RankName.ID(),
        panic6 = tostring(state.config.Heals.PanicClick1),
        panic7 = tostring(state.config.Heals.PanicClick2)
    },

    HoT = mq.TLO.Spell(tostring(state.config.Heals.HoT)).RankName.ID(),

    regular = {
        regular1 = mq.TLO.Spell(tostring(state.config.Heals.Heal1)).RankName.ID(),
        regular2 = mq.TLO.Spell(tostring(state.config.Heals.Heal2)).RankName.ID(),
        regular3 = mq.TLO.Spell(tostring(state.config.Heals.Heal3)).RankName.ID(),
        regular4 = mq.TLO.Spell(tostring(state.config.Heals.Heal4)).RankName.ID(),
        regular5 = mq.TLO.Spell(tostring(state.config.Heals.Heal5)).RankName.ID(),
        regular6 = tostring(state.config.Heals.HealClicky1),
        regular7 = tostring(state.config.Heals.HealClicky2),
        regular8 = tostring(state.config.Heals.HealClicky3)
    },

    groupheals = {
        group1 = mq.TLO.Spell(tostring(state.config.Heals.GroupHeal1)).RankName.ID(),
        group2 = mq.TLO.Spell(tostring(state.config.Heals.GroupHeal2)).RankName.ID(),
        group3 = tostring(state.config.Heals.GroupClick1),
        group4 = tostring(state.config.Heals.GroupClick2)
    },
}
end

function heals.getHurt()
    heallist = heals.getheals()
    state.updateLoopState()
    local numHurt = 0
    local mostHurtName = nil
    local mostHurtID = 0
    local mostHurtPct = 100
    local mostHurtDistance = 300
    local myHP = state.loop.PctHPs

    if myHP < tonumber(state.config.Heals.HealPanicAt) then
        write.Trace('Self Panic')
        return state.loop.ID, heallist.panic
    elseif myHP < tonumber(state.config.Heals.GroupHealAt) then
        mostHurtName = mq.TLO.Me.CleanName()
        mostHurtID = state.loop.ID
        mostHurtPct = myHP
        mostHurtDistance = 0
        numHurt = numHurt + 1
    end

    local tank = lib.determineTank()

    if tank and not tank.Dead() then
        local tankHP = tank.PctHPs() or 100
        local distance = tank.Distance3D() or 300
        if tankHP < tonumber(state.config.Heals.HealPanicAt) and distance < 200 then 
            write.Trace('Tank Panic') 
            return tank.ID(), heallist.panic 
        end
    end
    
    if state.config.Shaman.HealGroupPets == 'On' and mq.TLO.Pet.ID() ~= 0 then
        local myPetHP = mq.TLO.Pet.PctHPs() or 100
        local myPetDistance = mq.TLO.Pet.Distance3D() or 300
        if myPetHP < tonumber(state.config.Heals.HealRegularAt) and myPetDistance < 200 and myPetHP < mostHurtPct and mostHurtID ~= state.loop.ID then
            mostHurtName = mq.TLO.Pet.CleanName()
            mostHurtID = mq.TLO.Pet.ID()
            mostHurtPct = myPetHP
            mostHurtDistance = myPetDistance
        end
    end

    local groupSize = mq.TLO.Group.GroupSize()
    if groupSize then
        for i=1,groupSize-1 do

            local member = mq.TLO.Group.Member(i)
            if not member.Dead() then
                local memberHP = member.PctHPs() or 100
                local distance = member.Distance3D() or 300
                if memberHP < 100 and distance < 200 then
                    if memberHP < mostHurtPct then
                        mostHurtName = member.CleanName()
                        mostHurtID = member.ID()
                        mostHurtPct = memberHP
                        mostHurtDistance = distance
                    end
                    if memberHP < tonumber(state.config.Heals.GroupHealAt) and distance < 80 then numHurt = numHurt + 1 end
                    if memberHP < tonumber(state.config.Heals.HealPanicAt) and distance < 200 then
                        write.Trace('Group Member: %s Panic',member.CleanName())
                        return member.ID(), heallist.panic
                    end
                end

                if state.config.Shaman.HealGroupPets == 'On' then
                    local memberPetHP = member.Pet.PctHPs() or 100
                    local memberPetDistance = member.Pet.Distance3D() or 300
                    if memberPetHP < tonumber(state.config.Heals.HealTankAt) and memberPetDistance < 200 and memberPetHP < mostHurtPct then
                        mostHurtName = member.Pet.CleanName()
                        mostHurtID = member.Pet.ID()
                        mostHurtPct = memberPetHP
                        mostHurtDistance = memberPetDistance
                    end
                end
            end
        end
    end

    if tank and not tank.Dead() then
        local tankHP = tank.PctHPs() or 100
        local distance = tank.Distance3D() or 300
        if tankHP < tonumber(state.config.Heals.HealTankAt) and distance < 200 then 
            write.Trace('Tank Regular') 
            return tank.ID(), heallist.regular
        end
    end

    if numHurt >= tonumber(state.config.Heals.GroupHealTarCountMin) then
        write.Trace('Group Heals')
        return mostHurtID, heallist.groupheals
    elseif state.loop.PctHPs < tonumber(state.config.Heals.HealRegularAt) then
        write.Trace('Self Regular')
        return state.loop.ID, heallist.regular
    elseif mostHurtPct < tonumber(state.config.Heals.HealRegularAt) and mostHurtDistance < 200 then
        write.Trace('Group Member: %s Regular',mostHurtName)
        return mostHurtID, heallist.regular
    elseif mostHurtPct < tonumber(state.config.Heals.HoTAt) and tostring(state.config.Shaman.HoTTank) == "On" and timeSinceHot:timerExpired() and mostHurtName == tank.Name() then
        timeSinceHot:reset()
        write.Trace('Group Member: %s TankHoT',mostHurtName)
        return mostHurtID, heallist.HoT
    end

    if tostring(state.config.General.XTarHeal) == "On" then
        mostHurtPct = 100
        local start = 21 - tonumber(state.config.General.XTarHealList)
        for i=start,20 do
            local xtarSpawn = mq.TLO.Me.XTarget(i)
            local xtarType = xtarSpawn.Type()
            if xtarType == 'PC' or xtarType == 'Pet' then
                local xtargetHP = xtarSpawn.PctHPs() or 100
                local xtarDistance = xtarSpawn.Distance3D() or 300
                if xtargetHP < tonumber(state.config.Heals.HealRegularAt) and xtarDistance < 200 then
                    if xtargetHP < mostHurtPct then
                        mostHurtName = xtarSpawn.CleanName()
                        mostHurtID = xtarSpawn.ID()
                        mostHurtPct = xtargetHP
                        mostHurtDistance = xtarDistance
                    end
                end
            end
        end
        if mostHurtPct < tonumber(state.config.Heals.HealPanicAt) then
            write.Trace('XTarget: %s Panic',mostHurtName)
            return mostHurtID, heallist.regular
        elseif mostHurtPct < tonumber(state.config.Heals.HealRegularAt) and mostHurtDistance < 200 then
            write.Trace('XTarget: %s Regular',mostHurtName)
            return mostHurtID, heallist.regular
        end
    end
    return nil, nil
end

function heals.doheals()
    heallist = heals.getheals()

    write.Debug('Entering Heal')

    local tank = lib.determineTank()
    local queueAbility = require('utils.queue')
    local healtarid, healtype = heals.getHurt()

    if healtarid then write.Debug('Entering Heal Routine on %s',mq.TLO.Spawn(healtarid).CleanName()) end
    if healtype then write.Trace('ID: %s, Type: %s',healtarid,healtype) end

    if state.rezTimer:timerExpired() and healtype ~= heallist.panic and (mq.TLO.SpawnCount('pccorpse group radius 100 zradius 10 noalert')() > 0 or mq.TLO.SpawnCount('pccorpse raid radius 100 zradius 10 noalert')() > 0 or mq.TLO.SpawnCount(string.format('pccorpse %s radius 100 zradius 10 noalert',mq.TLO.Me.Name()))() > 0) and ((tostring(state.config.Shaman.RezStick) == 'On' and mq.TLO.Cast.Ready("Staff of Forbidden Rites")()) or (tostring(state.config.Shaman.RezOOC) == 'On' and mq.TLO.Me.CombatState() ~= 'COMBAT' and mq.TLO.Me.CurrentMana()) or (tostring(state.config.Shaman.CallOfWild) == 'On' and mq.TLO.Me.AltAbilityReady("Call of the Wild")() and mq.TLO.Me.CombatState() == 'COMBAT')) then
        write.Debug('Entering Rez Routine')
        local corpsetable = mq.getFilteredSpawns(function(s) 
            return s.ID() == mq.TLO.Spawn(string.format('pccorpse group radius 100 zradius 10 id %s noalert',s.ID())).ID() or s.ID() == mq.TLO.Spawn(string.format('pccorpse raid radius 100 zradius 10 id %s noalert',s.ID())).ID() or s.ID() == mq.TLO.Spawn(string.format('pccorpse %s radius 100 zradius 10 id %s noalert',mq.TLO.Me.Name(),s.ID())).ID() 
        end)
        local corpse = corpsetable[1]
        if corpse then write.Info('Corpse: %s ID: %s',mq.TLO.Spawn(corpse.ID()).CleanName(),corpse.ID()) end
        if not corpse then state.needrez = false write.Info('all corpses on alert list or spawn search failed') return end
        if tostring(state.config.Shaman.RezStick) == 'On' and mq.TLO.Cast.Ready("Staff of Forbidden Rites")() then
            write.Info('Using Staff')
            state.needrez = true
            state.rezTimer:reset()
            state.clearRezTimer:reset()
            mq.cmdf('/squelch /alert add 0 id %s',corpse.ID())
            mq.delay(100)
            queueAbility('Staff of Forbidden Rites','item',corpse.ID(),'rez') 
            return
        elseif tostring(state.config.Shaman.RezOOC) == 'On' and mq.TLO.Me.CombatState() ~= 'COMBAT' and mq.TLO.Me.CurrentMana() > 800 then
            state.needrez = true
            state.rezTimer:reset()
            state.clearRezTimer:reset()
            mq.cmdf('/squelch /alert add 0 id %s',corpse.ID())
            mq.delay(100)
            queueAbility(mq.TLO.Spell("Incarnate Anew").ID(),'spell',corpse.ID(),'rez') 
            return
        elseif tostring(state.config.Shaman.CallOfWild) == 'On' and mq.TLO.Me.AltAbilityReady("Call of the Wild")() and mq.TLO.Me.CombatState() == 'COMBAT' then
            state.needrez = true 
            state.rezTimer:reset()
            state.clearRezTimer:reset()
            mq.cmdf('/squelch /alert add 0 id %s',corpse.ID())
            mq.delay(100)
            queueAbility(mq.TLO.Me.AltAbility("Call of the Wild").ID(),'alt',corpse.ID(),'rez')  
            return
        else 
            return
        end
    elseif state.clearRezTimer:timerExpired() then
        state.needrez = false
        if mq.TLO.Alert(0)() then mq.cmd('/squelch /alert clear 0') end
    end

    if healtype then
        write.Trace('Healtype Exists')
        state.needheal = true

        if healtarid == mq.TLO.Me.ID() and mq.TLO.Me.AltAbilityReady("Ancestral Guard")() and mq.TLO.Me.PctHPs() < tonumber(state.config.Shaman.AncGuardAt) and lib.inControl() then
            mq.cmdf('/alt act %s',heallist.panic.ancguard)
            printf('\ay[\amSHM\ag420\ay]\am:\at Activating \amAncestral Guard\aw on \ar%s',mq.TLO.Me.Name())
            return
        end

        if healtype == heallist.panic then
            write.Trace('Healtype is Panic')
            if mq.TLO.Spawn(healtarid).PctHPs() < tonumber(state.config.Shaman.SoothsayersAt) and mq.TLO.Me.AltAbilityReady("Soothsayer's Intervention")() and mq.TLO.Spawn(healtarid).Type() == 'PC' then
                queueAbility(heallist.panic.soothsayer,'alt',healtarid,'heal')
                return
            elseif heallist.panic.panic1 and heallist.panic.panic1 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.panic.panic1))() then
                queueAbility(heallist.panic.panic1,'spell',healtarid,'heal')
                return
            elseif heallist.panic.panic2 and heallist.panic.panic2 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.panic.panic2))() then
                queueAbility(heallist.panic.panic2,'spell',healtarid,'heal')
                return
            elseif heallist.panic.panic3 and heallist.panic.panic3 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.panic.panic3))() then
                queueAbility(heallist.panic.panic3,'spell',healtarid,'heal')
                return
            elseif heallist.panic.panic4 and heallist.panic.panic4 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.panic.panic4))() then
                queueAbility(heallist.panic.panic4,'spell',healtarid,'heal')
                return
            elseif heallist.panic.panic5 and heallist.panic.panic5 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.panic.panic5))() then
                queueAbility(heallist.panic.panic5,'spell',healtarid,'heal')
                return
            elseif heallist.panic.panic6 and heallist.panic.panic6 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.panic.panic6))() then
                queueAbility(heallist.panic.panic6,'item',healtarid,'heal')
                return
            elseif heallist.panic.panic7 and heallist.panic.panic7 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.panic.panic7))() then
                queueAbility(heallist.panic.panic7,'item',healtarid,'heal')
                return
            else
                if heallist.regular.regular6 and heallist.regular.regular6 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular6))() then
                    queueAbility(heallist.regular.regular6,'item',healtarid,'heal')
                    return
                elseif heallist.regular.regular7 and heallist.regular.regular7 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular7))() then
                    queueAbility(heallist.regular.regular7,'item',healtarid,'heal')
                    return
                elseif heallist.regular.regular8 and heallist.regular.regular8 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular8))() then
                    queueAbility(heallist.regular.regular8,'item',healtarid,'heal')
                    return
                elseif heallist.regular.regular1 and heallist.regular.regular1 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular1))() then
                    queueAbility(heallist.regular.regular1,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular2 and heallist.regular.regular2 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular2))() then
                    queueAbility(heallist.regular.regular2,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular3 and heallist.regular.regular3 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular3))() then
                    queueAbility(heallist.regular.regular3,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular4 and heallist.regular.regular4 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular4))() then
                    queueAbility(heallist.regular.regular4,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular5 and heallist.regular.regular5 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular5))() then
                    queueAbility(heallist.regular.regular5,'spell',healtarid,'heal')
                    return
                end
            end

        elseif healtype == heallist.regular then
            write.Trace('Healtype is Regular')
            if mq.TLO.Spawn(healtarid).PctHPs() and mq.TLO.Spawn(healtarid).PctHPs() < tonumber(state.config.Shaman.UnionAt) and mq.TLO.Me.AltAbilityReady("Union of Spirits")() and mq.TLO.Spawn(healtarid).Type() == 'PC' then
                queueAbility(heallist.panic.union,'alt',healtarid,'heal')
                return
            elseif heallist.regular.regular6 and heallist.regular.regular6 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular6))() then
                queueAbility(heallist.regular.regular6,'item',healtarid,'heal')
                return
            elseif heallist.regular.regular7 and heallist.regular.regular7 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular7))() then
                queueAbility(heallist.regular.regular7,'item',healtarid,'heal')
                return
            elseif heallist.regular.regular8 and heallist.regular.regular8 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular8))() then
                queueAbility(heallist.regular.regular8,'item',healtarid,'heal')
                return
            elseif heallist.regular.regular1 and heallist.regular.regular1 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular1))() then
                queueAbility(heallist.regular.regular1,'spell',healtarid,'heal')
                return
            elseif heallist.regular.regular2 and heallist.regular.regular2 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular2))() then
                queueAbility(heallist.regular.regular2,'spell',healtarid,'heal')
                return
            elseif heallist.regular.regular3 and heallist.regular.regular3 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular3))() then
                queueAbility(heallist.regular.regular3,'spell',healtarid,'heal')
                return
            elseif heallist.regular.regular4 and heallist.regular.regular4 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular4))() then
                queueAbility(heallist.regular.regular4,'spell',healtarid,'heal')
                return
            elseif heallist.regular.regular5 and heallist.regular.regular5 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular5))() then
                queueAbility(heallist.regular.regular5,'spell',healtarid,'heal')
                return
            end

        elseif healtype == heallist.groupheals then
            write.Trace('Healtype is Group')
            if healtarid and mq.TLO.Spawn(healtarid).PctHPs() < tonumber(state.config.Shaman.AncAidAt) and mq.TLO.Me.AltAbilityReady("Ancestral Aid")() then
                queueAbility(heallist.panic.ancaid,'alt',state.loop.ID,'groupheal')
                return
            elseif healtarid and mq.TLO.Spawn(healtarid).PctHPs() < tonumber(state.config.Shaman.HealWardAt) and mq.TLO.Me.AltAbilityReady("Call of the Ancients")() then
                queueAbility(heallist.panic.healward,'alt',state.loop.ID,'groupheal')
                return
            elseif heallist.groupheals.group1 and heallist.groupheals.group1 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.groupheals.group1))() then
                queueAbility(heallist.groupheals.group1,'spell',state.loop.ID,'groupheal')
                return
            elseif heallist.groupheals.group2 and heallist.groupheals.group1 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.groupheals.group2))() then
                queueAbility(heallist.groupheals.group2,'spell',state.loop.ID,'groupheal')
                return
            elseif heallist.groupheals.group3 and heallist.groupheals.group3 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.groupheals.group3))() then
                queueAbility(heallist.groupheals.group3,'item',state.loop.ID,'groupheal')
                return
            elseif heallist.groupheals.group4 and heallist.groupheals.group4 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.groupheals.group4))() then
                queueAbility(heallist.groupheals.group4,'item',state.loop.ID,'groupheal')
                return
            else
                if heallist.regular.regular6 and heallist.regular.regular6 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular6))() then
                    queueAbility(heallist.regular.regular6,'item',healtarid,'heal')
                    return
                elseif heallist.regular.regular7 and heallist.regular.regular7 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular7))() then
                    queueAbility(heallist.regular.regular7,'item',healtarid,'heal')
                    return
                elseif heallist.regular.regular8 and heallist.regular.regular8 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular8))() then
                    queueAbility(heallist.regular.regular8,'item',healtarid,'heal')
                    return
                elseif heallist.regular.regular1 and heallist.regular.regular1 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular1))() then
                    queueAbility(heallist.regular.regular1,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular2 and heallist.regular.regular2 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular2))() then
                    queueAbility(heallist.regular.regular2,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular3 and heallist.regular.regular3 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular3))() then
                    queueAbility(heallist.regular.regular3,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular4 and heallist.regular.regular4 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular4))() then
                    queueAbility(heallist.regular.regular4,'spell',healtarid,'heal')
                    return
                elseif heallist.regular.regular5 and heallist.regular.regular5 ~= 'NULL' and mq.TLO.Cast.Ready(tostring(heallist.regular.regular5))() then
                    queueAbility(heallist.regular.regular5,'spell',healtarid,'heal')
                    return
                end
            end

        elseif healtype == heallist.HoT then
            write.Trace('Healtype is HoT')
            queueAbility(heallist.HoT,'spell',tank.ID(),'HoT')
            return
        end
    end
    if healtype == nil and healtarid == nil then 
        state.needheal = false 
        if mq.TLO.Me.GroupAssistTarget.ID() and mq.TLO.NearestSpawn(string.format('id %s',mq.TLO.Me.GroupAssistTarget.ID())).ID() then
            if mq.TLO.Group.MainAssist() and mq.TLO.Group.MainAssist.ID() ~= 0 and mq.TLO.Cast.Ready(mq.TLO.Spell(tostring(state.config.Spells.Gift)).RankName())() and mq.TLO.Me.GroupAssistTarget.ID() ~= 0 and mq.TLO.Me.GroupAssistTarget.Aggressive() and mq.TLO.Me.GroupAssistTarget.PctHPs() < 100 and mq.TLO.Me.GroupAssistTarget.LineOfSight() and mq.TLO.Me.GroupAssistTarget.Distance3D() < 250 and mq.TLO.Group.MainAssist.Type() ~= 'Corpse' then queueAbility(mq.TLO.Spell(tostring(state.config.Spells.Gift)).RankName.ID(),'spell',mq.TLO.Group.MainAssist.ID(),'DD') return end
        end
    end
end

return heals