local mq = require('mq')
local state = require('utils.state')
local heals = require('routines.heal')
local lib = require('utils.lib')
local write = require('utils.Write')
local queueAbility = require('utils.queue')

local function getdebuffs()
    return {
    aamalo = mq.TLO.Me.AltAbility("Malaise").ID(),
    singleturgurs = mq.TLO.Me.AltAbility("Turgur's Swarm").ID(),
    aemalo = mq.TLO.Spell(state.config.Combat.AEMalo).Name(),
    aeslow = mq.TLO.Spell(state.config.Combat.AESlow).Name(),
    aeturgurs = mq.TLO.Me.AltAbility("Turgur's Virulent Swarm").ID(),
    cripple = mq.TLO.Spell(state.config.Combat.Cripple).Name(),
    feralize = mq.TLO.Spell(state.config.Combat.Feralize).Name(),
    malo = mq.TLO.Spell(state.config.Combat.Malo).Name(),
    slow = mq.TLO.Spell(state.config.Combat.Slow).Name(),
    unresmalo = mq.TLO.Spell(state.config.Combat.UnresMalo).Name()
    }

end



local function getdebufftargets()
    local list = mq.getFilteredSpawns(function(s)
    return s.Aggressive() and s.Type() == 'NPC' and not s.Dead() and s.Targetable() and s.LineOfSight() and s.PctHPs() >= tonumber(state.config.Combat.DebuffStop) and s.PctHPs() <= tonumber(state.config.Combat.DebuffAt)
    end)
    return list
end


local function doDebuffs()
    local debuffs = getdebuffs()
    local aeslowtarmin = tonumber(string.match(state.config.Shaman.AESlow, "%d+"))
    local aemalotarmin = tonumber(string.match(state.config.Shaman.AEMalo, "%d+"))
    local hasmalo = mq.TLO.Target.Maloed.ID()
    local hascripple = mq.TLO.Target.Crippled.ID()
    write.Debug('debuff routine')
    local debufflist = getdebufftargets()
    local tar = debufflist[tonumber(state.debuffindex)]
    if state.debuffindex > #debufflist then state.debuffindex = 1 end
    local type = 'other'
    local aggroCount = #debufflist
    if not tar then write.Info('no debuffs needed') return end
    if mq.TLO.Target.ID() ~= tar.ID() and tar.ID() ~= nil then
        if not state.paused then mq.cmdf('/squelch /mqt id %s',tar.ID()) end
        write.Info('Targeting %s',mq.TLO.Spawn(tostring(tar.ID())).CleanName())
        mq.delay(350)
    end

    if not mq.TLO.Target.Buff("Turgur's Insects")() then type = 'slow' state.debuffing = true end

    local npccount = mq.TLO.SpawnCount("npc radius 100 zradius 10")()


    if type == 'slow' and tostring(state.config.Shaman.Slow) == 'On' then
        if string.match(tostring(state.config.Shaman.AESlow), "On|%d+") and aggroCount >= npccount and npccount >= aeslowtarmin then
            if mq.TLO.Me.AltAbilityReady("Turgur's Virulent Swarm")() then
                queueAbility(debuffs.aeturgurs,'alt',tar.ID(),'debuff')
                state.debuffindex = tonumber(state.debuffindex) + 1
                return
            elseif mq.TLO.Cast.Ready(debuffs.aeslow)() then
                queueAbility(debuffs.aeslow,'spell',tar.ID(),'debuff')
                state.debuffindex = tonumber(state.debuffindex) + 1
                return
            end
        elseif mq.TLO.Me.AltAbilityReady(debuffs.singleturgurs)() and tostring(state.config.Shaman.AASingleTurgurs) == 'On' then
            queueAbility(debuffs.singleturgurs,'alt',tar.ID(),'debuff')
            state.debuffindex = tonumber(state.debuffindex) + 1
            return
        elseif mq.TLO.Cast.Ready(debuffs.slow)() then
            queueAbility(debuffs.slow,'spell',tar.ID(),'debuff')
            state.debuffindex = tonumber(state.debuffindex) + 1
            return
        elseif mq.TLO.Cast.Ready("Time's Antithesis")() and tostring(state.config.Combat.TimeAntithesis) == 'On' then
            queueAbility("Time's Antithesis","item",tar.ID(),'debuff')
            state.debuffindex = tonumber(state.debuffindex) + 1
            return
        end
    end

    if type == 'other' and tostring(state.config.Shaman.Malo) == 'On' or (tar.Named() and tostring(state.config.Shaman.Malo) == 'Named') then
        state.debuffing = false
        if string.match(tostring(state.config.Shaman.AEMalo), "On|%d+") and aggroCount >= npccount and npccount >= aemalotarmin and not hasmalo then

            if string.match(tostring(state.config.Shaman.AEMaloAA), "On") and mq.TLO.Me.AltAbilityReady("Wind of Malaise")() then
                queueAbility(mq.TLO.AltAbility('Wind of Malaise').ID(),'alt',tar.ID(),'debuff')
                return
            elseif mq.TLO.Me.Gem(debuffs.aemalo)() or state.canmem == true then 
                queueAbility(debuffs.aemalo,'spell',tar.ID(),'debuff')
                return
            end

        elseif tostring(state.config.Shaman.AAMalo) == 'On' and mq.TLO.Cast.Ready("Malaise")() and not hasmalo then
            queueAbility(debuffs.aamalo,'alt',tar.ID(),'debuff')
            return

        elseif tostring(state.config.Shaman.UnresMalo) == 'On' or (tostring(state.config.Shaman.UnresMalo) == 'Named' and mq.TLO.Target.Named()) and not hasmalo then
            queueAbility(debuffs.unresmalo,"spell",tar.ID(),'debuff')
            return

        elseif not hasmalo or hasmalo and mq.TLO.Target.Maloed.ID() ~= mq.TLO.Spell(mq.TLO.Spell(debuffs.malo).RankName()).ID() then 
            queueAbility(debuffs.malo,"spell",tar.ID(),'debuff')
            return
        end
    elseif not hascripple then
        if (not hascripple or (hascripple and mq.TLO.Target.Crippled.ID() ~= mq.TLO.Spell(mq.TLO.Spell(debuffs.feralize).RankName()).ID())) and ((tostring(state.config.Shaman.Feralize) == 'On' or (tostring(state.config.Shaman.Feralize) == 'Named' and tar.Named()))) and (tar.Body.ID() == 1 or tar.Body.Name() == 'Giant' or tar.Body.Name() == 'Animal') then
            queueAbility(debuffs.feralize,"spell",tar.ID(),'debuff')
            return

        elseif (tostring(state.config.Shaman.Cripple) == 'On' or (tostring(state.config.Shaman.Cripple) == 'Named' and mq.TLO.Target.Named())) then
            queueAbility(debuffs.cripple,"spell",tar.ID(),'debuff')
            return

        end

    end

end

--[[

local function doDebffs()

    state.debuffing = true

    if aggroCount > 0 then
        
        for i = 1,20 do
            if mq.TLO.Me.XTarget(i).ID() ~= 0 and mq.TLO.Me.XTarget(i).TargetType() == 'Auto Hater' and mq.TLO.Me.XTarget(i).Type() == 'NPC' then
                local tar = mq.TLO.Me.XTarget(i).ID()
                write.Trace('Debuff Target: %s',tar)
                write.Trace('Debuff XTar: %s',i)
                
                local haslongslow = mq.TLO.Target.Buff("Turgur's Insects")()
                
                local slowtarget = mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.Aggressive() and mq.TLO.Target.PctHPs() >= tonumber(state.config.Combat.DebuffStop) and mq.TLO.Target.LineOfSight() and mq.TLO.Target.PctHPs() <= tonumber(state.config.Combat.DebuffAt)
                local hasmalo = mq.TLO.Target.Maloed.ID()
                local hascripple = mq.TLO.Target.Crippled.ID()
                if string.match(tostring(state.config.Shaman.AESlow), "On|%d+") and aggroCount >= npccount and npccount >= aeslowtarmin and not haslongslow and (mq.TLO.Cast.Ready(debuffs.aeslow)() or mq.TLO.Me.AltAbilityReady("Turgur's Virulent Swarm")()) and slowtarget then
                    if string.match(tostring(state.config.Shaman.AETurgurs), "On") and mq.TLO.Me.AltAbilityReady("Turgur's Virulent Swarm")() then
                        write.Debug('\apI AM AESLOWING> THERE ARE %s MOBS ON MY XTAR AND %s MOBS IN RANGE AE RANGE. I SHOULD ONLY BE CASTING IF %s > %s and %s > 3',aggroCount,npccount,aggroCount,npcount,npccount)
                        queueAbility(debuffs.aeturgurs,'alt',tar,'debuff')
                        mq.delay(50)
                        heals.doheals()
                        while state.needheal == true do 
                            heals.doheals()
                            write.Trace('Need Heal: %s',state.needheal)
                            if state.paused then return end
                        end
                    elseif mq.TLO.Cast.Ready(debuffs.aeslow)() then
                        queueAbility(debuffs.aeslow,'spell',tar,'debuff')
                        mq.delay(50)
                        heals.doheals()
                        while state.needheal == true do 
                            heals.doheals() 
                            write.Trace('Need Heal: %s',state.needheal)
                            if state.paused then return end
                        end
                    end
                elseif tostring(state.config.Shaman.Slow) == 'On' and not haslongslow and mq.TLO.Me.AltAbilityReady(debuffs.singleturgurs)() and slowtarget and tostring(state.config.Shaman.AASingleTurgurs) == 'On' then
                    
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif tostring(state.config.Shaman.Slow) == 'On' and not haslongslow and mq.TLO.Cast.Ready(debuffs.slow)() and slowtarget then
                    queueAbility(debuffs.slow,'spell',tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif tostring(state.config.Shaman.Slow) == 'On' and not haslongslow and mq.TLO.Cast.Ready("Time's Antithesis")() and slowtarget then
                    queueAbility("Time's Antithesis","item",tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end
                elseif string.match(tostring(state.config.Shaman.AEMalo), "On|%d+") and aggroCount >= npccount and npccount >= aemalotarmin and slowtarget and not hasmalo and (mq.TLO.Me.AltAbilityReady("Wind of Malaise")() or mq.TLO.Me.Gem(debuffs.aemalo)() or state.canmem == true) then
                    if string.match(tostring(state.config.Shaman.AEMaloAA), "On") and mq.TLO.Me.AltAbilityReady("Wind of Malaise")() then
                        queueAbility(mq.TLO.AltAbility('Wind of Malaise').ID(),'alt',tar,'debuff')
                        mq.delay(50)
                        heals.doheals()
                        while state.needheal == true do 
                            heals.doheals()
                            write.Trace('Need Heal: %s',state.needheal)
                            if state.paused then return end
                        end
                    elseif mq.TLO.Me.Gem(debuffs.aemalo)() or state.canmem == true then 
                        queueAbility(debuffs.aemalo,'spell',tar,'debuff')
                        mq.delay(50)
                        heals.doheals()
                        while state.needheal == true do 
                            heals.doheals() 
                            write.Trace('Need Heal: %s',state.needheal)
                            if state.paused then return end
                        end
                    end        

                elseif not hasmalo and tostring(state.config.Shaman.AAMalo) == 'On' and mq.TLO.Cast.Ready("Malaise")() and slowtarget and tostring(state.config.Shaman.Malo) == 'On' or (tostring(state.config.Shaman.Malo) == 'Named' and mq.TLO.Target.Named()) then
                    queueAbility(debuffs.aamalo,'alt',tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif (not hasmalo or (hasmalo and hasmalo ~= mq.TLO.Spell(mq.TLO.Spell(debuffs.malo).RankName()).ID())) and tostring(state.config.Shaman.Malo) == 'On' or (tostring(state.config.Shaman.Malo) == 'Named' and mq.TLO.Target.Named()) and slowtarget then
                    queueAbility(debuffs.malo,"spell",tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif not hasmalo and tostring(state.config.Shaman.UnresMalo) == 'On' or (tostring(state.config.Shaman.UnresMalo) == 'Named' and mq.TLO.Target.Named()) and slowtarget then
                    queueAbility(debuffs.unresmalo,"spell",tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                if (not hascripple or hascripple ~= mq.TLO.Spell(mq.TLO.Spell(debuffs.feralize).RankName()).ID()) and (tostring(state.config.Shaman.Feralize) == 'On' or (tostring(state.config.Shaman.Feralize) == 'Named' and mq.TLO.Target.Named())) and (mq.TLO.Target.Body.ID() == 1 or mq.TLO.Target.Body.Name() == 'Giant' or mq.TLO.Target.Body.Name() == 'Animal') and slowtarget then
                    queueAbility(debuffs.feralize,"spell",tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif not hascripple and (tostring(state.config.Shaman.Cripple) == 'On' or (tostring(state.config.Shaman.Cripple) == 'Named' and mq.TLO.Target.Named())) and slowtarget then
                    queueAbility(debuffs.cripple,"spell",tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                end
            end
        end
    end
end

]]--

return doDebuffs






























