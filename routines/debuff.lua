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
    aemalo = mq.TLO.Me.AltAbility("Wind of Malaise").ID(),
    aeslow = mq.TLO.Spell(state.config.Combat.AESlow).Name(),
    aeturgurs = mq.TLO.Me.AltAbility("Turgur's Virulent Swarm").ID(),
    cripple = mq.TLO.Spell(state.config.Combat.Cripple).Name(),
    feralize = mq.TLO.Spell(state.config.Combat.Feralize).Name(),
    malo = mq.TLO.Spell(state.config.Combat.Malo).Name(),
    slow = mq.TLO.Spell(state.config.Combat.Slow).Name(),
    unresmalo = mq.TLO.Spell(state.config.Combat.UnresMalo).Name()
    }

end

local function doDebuffs()
    local debuffs = getdebuffs()
    state.debuffing = true
    local aggroCount = lib.aggroCount()
    local aeslowtarmin = tonumber(string.match(state.config.Shaman.AESlow, "%d+"))
    if aggroCount > 0 then
        write.Debug('debuff routine')
        for i = 1,20 do
            if mq.TLO.Me.XTarget(i).ID() ~= 0 and mq.TLO.Me.XTarget(i).TargetType() == 'Auto Hater' and mq.TLO.Me.XTarget(i).Type() == 'NPC' then
                local tar = mq.TLO.Me.XTarget(i).ID()
                write.Trace('Debuff Target: %s',tar)
                write.Trace('Debuff XTar: %s',i)
                if mq.TLO.Target.ID() ~= tar and tar ~= nil then
                    mq.cmdf('/squelch /mqt id %s',tar)
                    write.Info('Targeting %s',mq.TLO.Spawn(tar).CleanName())
                    mq.delay(550)
                end
                local haslongslow = mq.TLO.Target.Buff("Turgur's Insects")()
                local npccount = mq.TLO.SpawnCount("npc radius 100 zradius 10")()
                local hasmalo = mq.TLO.Target.Maloed.ID()
                local hascripple = mq.TLO.Target.Crippled.ID()
                local slowtarget = mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.Aggressive() and mq.TLO.Target.PctHPs() >= tonumber(state.config.Combat.DebuffStop) and mq.TLO.Target.LineOfSight() and mq.TLO.Target.PctHPs() <= tonumber(state.config.Combat.DebuffAt)
                if string.match(tostring(state.config.Shaman.AESlow), "On|%d+") and aggroCount >= npccount and npccount >= aeslowtarmin and not haslongslow and (mq.TLO.Cast.Ready(debuffs.aeslow)() or mq.TLO.Me.AltAbilityReady("Turgur's Virulent Swarm")()) and slowtarget then
                    lib.debug('aeslow')
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
                        lib.debug(debuffs.aeslow)
                        mq.delay(50)
                        heals.doheals()
                        while state.needheal == true do 
                            heals.doheals() 
                            write.Trace('Need Heal: %s',state.needheal)
                            if state.paused then return end
                        end
                    end
                elseif string.match(tostring(state.config.Shaman.Slow), "On") and not haslongslow and mq.TLO.Me.AltAbilityReady(debuffs.singleturgurs)() and slowtarget and tostring(state.config.Shaman.AASingleTurgurs) == 'On' then
                    queueAbility(debuffs.singleturgurs,'alt',tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif string.match(tostring(state.config.Shaman.Slow), "On") and not haslongslow and mq.TLO.Cast.Ready(debuffs.slow)() and slowtarget then
                    queueAbility(debuffs.slow,'spell',tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif string.match(tostring(state.config.Shaman.Slow), "On") and not haslongslow and mq.TLO.Cast.Ready("Time's Antithesis")() and slowtarget then
                    queueAbility("Time's Antithesis","item",tar,'debuff')
                    mq.delay(50)
                    heals.doheals()
                    while state.needheal == true do 
                        heals.doheals()
                        write.Trace('Need Heal: %s',state.needheal)
                        if state.paused then return end
                    end

                elseif not hasmalo and tostring(state.config.Shaman.AAMalo) == 'On' and mq.TLO.Cast.Ready("Malaise")() and slowtarget then
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

                elseif (not hascripple or hascripple ~= mq.TLO.Spell(mq.TLO.Spell(debuffs.feralize).RankName()).ID()) and (tostring(state.config.Shaman.Feralize) == 'On' or (tostring(state.config.Shaman.Feralize) == 'Named' and mq.TLO.Target.Named())) and (mq.TLO.Target.Body.ID() == 1 or mq.TLO.Target.Body.Name() == 'Giant' or mq.TLO.Target.Body.Name() == 'Animal') and slowtarget then
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

return doDebuffs






























