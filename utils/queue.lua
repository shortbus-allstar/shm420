local mq = require('mq')
local state = require('utils.state')
local write = require('utils.Write')
local timer = require('utils.timer')
local abilityQueue = {}

local function processQueue()
    write.Debug('Entering ProcessQueue')
    state.updateLoopState()
    write.Trace('Past Update State')
    if state.paused then return end
    if state.loop.Invis and mq.TLO.Me.CombatState() ~= 'COMBAT' then return end
    write.Trace('Past pause and invis check')
    if #abilityQueue == 0 then
        write.Debug('Queue Empty')
        return
    end

    local function checkHeal()
        local heals = require('routines.heal')
        local _, healtype = heals.getHurt()
        if healtype == 'panic' and tostring(state.config.Heals.InterruptToHeal) == 'On' then heals.doheals() return end
    end


    
    write.Trace('Ability Queue past')



    if state.dead == true then 
        abilityQueue = {}
        state.paused = true
        return
    end

    write.Trace('past dead check')

    local abilityData = abilityQueue[1]
    write.Trace('ability data set')
    if not abilityData then write.Error('shit #1') return end
    local abilID, abiltype, abiltarget, category = abilityData.abilID, abilityData.abiltype, abilityData.abiltarget, abilityData.category
    state.interrupted = false

    if category ~= 'heal' then checkHeal() end

    if category ~= 'heal' and category ~= 'rez'and #state.condqueue > 0 then
        write.Warn('Changing ability to %s',state.condqueue[1].name)
        abiltype = state.condqueue[1].type
        abiltarget = state.condqueue[1].target
        if abiltype == 'alt' then abilID = mq.TLO.Me.AltAbility(state.condqueue[1].name).ID() end
        if abiltype == 'spell' then abilID = mq.TLO.Spell(state.condqueue[1].name).ID() end
        if abiltype == 'item' then abilID = tostring(state.condqueue[1].name) end
        category = 'cond'
        table.remove(state.condqueue,1)
    end

    if state.canmem == false and state.memqueue and state.memqueue.abilID == abilityData.abilID then
        write.Info('already attempting to mem this spell, exiting')
        abilityQueue = {}
        return
    end


    if category ~= 'heal' and category ~= 'groupheal' and category ~= 'rez' and tostring(state.config.Heals.InterruptToHeal) == 'On' then
        checkHeal()
    end
    
    write.Trace('Abil ID = %s, Abil Type = %s, Target = %s, Category = %s',abilID,abiltype,abiltarget,category)

    local combat = require('routines.combat')

    if mq.TLO.Me.CombatState() == 'COMBAT' then 
        combat.checkMelee() 
    end

    if abiltarget ~= mq.TLO.Target.ID() and state.config.Combat.Melee == 'On' and category == 'debuff' then
        mq.cmd('/attack off')
    end

    if mq.TLO.Target.ID() ~= abiltarget and abiltarget ~= nil then
        mq.cmdf('/squelch /mqt id %s',abiltarget)
        write.Info('Targeting %s',mq.TLO.Spawn(abiltarget).CleanName())
        mq.delay(250)
    end

    if abiltarget == nil and category == 'DD' or category == 'DoT' then
        abiltarget = mq.TLO.Me.GroupAssistTarget.ID()
    end

    if abiltarget == nil then
        abiltarget = mq.TLO.Target.ID()
    end

    local cmdMsg = nil
    local printMsg = nil
    local memmed = true

    if abiltype == 'alt' then
        cmdMsg = string.format('/alt act %s',abilID)
        printMsg = string.format('\ay[\amSHM\ag420\ay]\am:\at Activating \am%s\aw on \ar%s',mq.TLO.AltAbility(abilID).Name(),mq.TLO.Spawn(abiltarget).CleanName())

    elseif abiltype == 'item' then
        cmdMsg = string.format('/useitem %s',abilID)
        printMsg = string.format('\ay[\amSHM\ag420\ay]\am:\at Using \am%s\aw on \ar%s',abilID,mq.TLO.Spawn(abiltarget).CleanName())

    elseif abiltype == 'spell' and mq.TLO.Spell(abilID).Mana() and mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(abilID).Mana() then
        cmdMsg = string.format('/casting "%s" gem%s',mq.TLO.Spell(abilID).RankName(),state.config.Spells.MiscGem)
        printMsg = string.format('\ay[\amSHM\ag420\ay]\am:\at Casting \am%s\aw on \ar%s',mq.TLO.Spell(abilID).RankName(),mq.TLO.Spawn(abiltarget).CleanName())
        if not mq.TLO.Me.Gem(mq.TLO.Spell(abilID).RankName())() then
            write.Trace('Spell Not Memmed')
            memmed = false
        end
    elseif mq.TLO.Me.CurrentMana() < mq.TLO.Spell(abilID).Mana() then
        write.Info('Not enough mana for that, clearing queue...')
        table.remove(abilityQueue, 1)
        local buffs = require('routines.buffs')
        abilityQueue = {}
        buffs.checkCanni()
        return
    end

    if category == 'heal' or category == 'rez' or category == 'HoT' and tostring(state.config.General.UseDNet) == 'On' then mq.cmdf('/dgtell %s',printMsg) end

    if memmed == false and tostring(state.config.Spells.MiscGemRemem) == 'On' and state.canmem == true then
        local recastTime = mq.TLO.Spell(abilID).RecastTime()
        if recastTime < 1600 then
            mq.cmdf('/memspell %s "%s"',state.config.Spells.MiscGem,mq.TLO.Spell(abilID).RankName())
            combat.checkPet()
            write.Trace('Delaying, recast time < 1600')
            mq.delay(recastTime)
            combat.checkPet()
            mq.delay(100)
            mq.delay(recastTime)
            combat.checkPet()
        else
            mq.cmdf('/memspell %s "%s"',state.config.Spells.MiscGem,mq.TLO.Spell(abilID).RankName())
            state.recastTimer = timer:new(recastTime)
            state.recastTimer:reset()
            table.remove(abilityQueue, 1)
            write.Trace('Adding spell to mem queue')
            state.canmem = false
            state.memqueue = abilityData
            return
        end
        
    elseif tostring(state.config.Spells.MiscGemRemem) ~= 'On' and memmed == false then
        write.Warn('Misc Gem Remem is not on. Can\'t mem spell, clearing queue...')
        abilityQueue = {}
        return
    elseif state.canmem == false and memmed == false then
        write.Warn('Already waiting for spell to mem, clearing queue...')
        abilityQueue = {}
        return
    end

    if category == 'rez' then
        mq.cmd('/corpse')
    end
    write.Trace('Cmd: %s',cmdMsg)
    if not cmdMsg then
        write.Error('Command was never declared. Relevent debug info: abilid(%s), abiltype(%s)',abilID,abiltype)
        return
    end

    mq.cmd(cmdMsg)
    print(printMsg)
    write.Trace('Activating Ability %s',abilID)
    combat.checkPet()
    mq.doevents()


    if state.dead == true then 
        abilityQueue = {}
        state.paused = true
        return
    end

    local stopTime = 0
    local starttime = mq.gettime()

    if abiltype == 'spell' then stopTime = mq.TLO.Spell(abilID).MyCastTime() end
    if abiltype == 'item' then stopTime = mq.TLO.FindItem(abilID).CastTime() end
    if abiltype == 'alt' then 
        mq.delay(500) 
        write.Trace('\ar%s',mq.TLO.Cast.Timing() )
        stopTime = mq.TLO.Cast.Timing() 
    end

    if stopTime == 0 then
        table.remove(abilityQueue, 1)
        local heals = require('routines.heal')
        if state.needheal then
            heals.doheals()
        end
        local rezcheck = 0
        if rezcheck <= (mq.gettime() - 5000) then
            heals.checkRezes()
            write.Info('checking rezes')
            rezcheck = mq.gettime()
        end
        processQueue() 
        return
    end
    write.Trace(mq.gettime())
    write.Trace(starttime)
    write.Trace(stopTime)


    while (mq.gettime() - starttime) < stopTime + 100 do
        local heals = require('routines.heal')
        local _, healtype = heals.getHurt()
        write.Trace('Cast Timing Left: %s',stopTime)
        if healtype == 'panic' and category ~= 'heal' and (mq.gettime() - starttime) > 200 and tostring(state.config.Heals.InterruptToHeal) == 'On' and not (mq.TLO.Me.PctMana() < 10 and category =='canni') then
            mq.cmd('/stopcast')
            write.Info('Stopping cast, need to heal...')
            return
        end

        if category == 'heal' and mq.TLO.Target.ID() ~= 0 and mq.TLO.Target.Type() ~= 'Corpse' and mq.TLO.Target.PctHPs() > tonumber(state.config.Heals.CancelHealAt) then
            mq.cmd('/stopcast')
            write.Info('Stopping cast, targets hp is > 95')
            return
        end

        if (category == 'debuff' or category == 'heal' or category == 'DD' or category == 'HoT') and (mq.TLO.Target.Type() == 'Corpse' or mq.TLO.Target.ID() == 0) then
            mq.cmd('/stopcast')
            write.Info('Stopping cast, target dead')
            return
        end

        if state.dead == true then 
            abilityQueue = {}
            state.paused = true
            return
        end
        
        combat.checkPet()
        mq.doevents()
        write.Trace('Interrupted?: %s',state.interrupted)
        if state.interrupted == true then table.remove(abilityQueue, 1) return end
        state.updateLoopState()
        mq.delay(50)
    end

    if abiltype == 'spell' then mq.delay(1250) 
    else mq.delay(200)
    end

    table.remove(abilityQueue, 1)
    local heals = require('routines.heal')
    if state.needheal then
        heals.doheals()
    end
    local rezcheck = 0
    if rezcheck <= (mq.gettime() - 5000) then
        heals.checkRezes()
        write.Info('checking rezes')
        rezcheck = mq.gettime()
    end
    processQueue()
end

local function queue(abilID,abiltype,abiltarget,category)
    write.Trace('Queueing ability %s',mq.TLO.Spell(abilID).Name())
    table.insert(abilityQueue, { abilID = abilID, abiltype = abiltype, abiltarget = abiltarget, category = category})
    write.Trace('\atAbility Queue: %s',#abilityQueue)
    write.Trace('\atAbility Info: #in Queue: %s ID: %s, Type: %s, Target: %s, Cat: %s',#abilityQueue,abilityQueue[1].abilID,abilityQueue[1].abiltype,abilityQueue[1].abiltarget,abilityQueue[1].category)
    if #abilityQueue == 1 then
        processQueue()
    end
    if #abilityQueue > 1 then
        write.Warn('Error: Queue has more than one ability. Clearing queue...')
        abilityQueue = {}
    end
end

return queue