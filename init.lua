local binds = require('utils.binds')
local events = require('utils.events')
local chase = require('routines.campchase')
local cures = require('routines.cure')
local heals = require('routines.heal')
local lib = require('utils.lib')
local mq = require('mq')
local state = require('utils.state')
local write = require('utils.Write')
local handlePet = require('routines.pet')
local buffs = require('routines.buffs')
local queueAbility = require('utils.queue')
local debuff = require('routines.debuff')
local combat = require('routines.combat')
local config = state.config
local dps = require('routines.dps')
local ui = require('interface.gui')


state.updateLoopState()

mq.bind('/test',binds.testbind)
mq.bind('/state',binds.var)
mq.bind('/reload',binds.configreload)

write.prefix = '\ar\a-g'


write.Info('Test... lua started')
mq.imgui.init('SHM420', ui.main)



mq.bind('/shm',binds.shmbind)

local function checkMemQueue()
    if state.memqueue and state.recastTimer ~= nil and state.recastTimer:timerExpired() then
        write.Debug('Checking mem queue')
        local abilityData = state.memqueue
        local id, t, ta, ca = abilityData.abilID, abilityData.abiltype, abilityData.abiltarget, abilityData.category
        queueAbility(id,t,ta,ca)
        state.canmem = true
        state.recastTimer = nil
        state.memqueue = nil
    end
end

local function main()
    if mq.TLO.Me.Class() ~= 'Shaman' then
        print('\ay[\amSHM\ag420\ay]\am:\at You high as hell boy you ain\'t a shaman')
        print('\ay[\amSHM\ag420\ay]\am:\at Pinching the joint...')
        mq.exit()
    end
    events.init()
    if tostring(state.config.General.UseDNet) == 'On' then lib.initObservers() end
    if tostring(state.config.General.ReturnToCamp) == 'On' then state.campxloc, state.campyloc, state.campzloc = chase.setcamp() end
    while true do
        state.updateLoopState()
        write.Trace('New Loop')
        if state.dead == true then 
            mq.doevents('zoned')
            mq.delay(100)
            mq.doevents('rezzed')
            mq.delay(100)
        end
        if not state.paused and lib.inControl() and not mq.TLO.Me.Shrouded() then
            if not state.loop.Invis and not lib.isBlockingWindowOpen() then
                write.Trace('\apasdfasdfadsfasdf')
                -- do active combat assist things when not paused and not invis
                lib.checkFD()
                lib.checkCursor()
                if lib.amiready() then
                    chase.chaseorcamp()
                    heals.doheals()
                    cures.doCures()
                    combat.handlePowerSource()
                    buffs.checkCanni()
                    if mq.TLO.Me.CombatState() ~= 'COMBAT' and lib.aggroCount() == 0 then
                        handlePet()
                        checkMemQueue()
                        buffs.checkBuffQueue()
                        chase.doMed()
                        if #state.dpsqueue > 0 then 
                            state.dpsqueue = {}
                            state.canmem = true 
                        end
                    elseif mq.TLO.Me.CombatState() == 'COMBAT' or lib.aggroCount() > 0 then
                        combat.checkMelee()
                        debuff()
                        buffs.checkShortBuffs()
                        dps.dodps()
                        if tostring(state.config.General.MedCombat) == 'On' and not mq.TLO.Melee.Combat() then
                            chase.doMed()
                        end
                    end
                end
            elseif state.loop.Invis == true then
                lib.checkFD()
                lib.checkCursor()
                chase.chaseorcamp()
                mq.delay(1000)
                chase.doMed()
                mq.delay(1000)
            end
        end
    end
end

main()

--[[

local binds = require('utils.binds')
local chase = require('routines.campchase')
local config = require('config.getconfig')
local cures = require('routines.cure')
local events = require('utils.events')
local heals = require('routines.heal')
local lib = require('utils.lib')
local mq = require('mq')
local state = require('utils.state')
local timer = require('utils.timer')
local queueAbility = require('utils.queue')
local handlePet = require('routines.pet')
local doDebuffs = require('routines.debuff')
local buffs = require('routines.buffs')
local combat = require('routines.combat')


mq.bind('/shm',binds.shmbind)

local function main()
    if mq.TLO.Me.Class() ~= 'Shaman' then
        print('\ay[\amSHM\ag420\ay]\am:\at You high as hell boy you ain\'t a shaman')
        print('\ay[\amSHM\ag420\ay]\am:\at Pinching the joint...')
        mq.exit()
    end
    lib.debugxtars()
    if tostring(config.General.UseDNet) == 'On' then lib.initObservers() end
    state.campxloc, state.campyloc, state.campzloc = chase.setcamp()
    while not mq.TLO.Me.Shrouded() do
        state.updateLoopState()
        if not state.paused and lib.inControl() then
            if not state.loop.Invis and not lib.isBlockingWindowOpen() then
                -- do active combat assist things when not paused and not invis
                lib.checkFD()
                lib.checkCursor()
                if lib.amiready() then
                    chase.chaseorcamp()
                    heals.doheals()
                    cures.doCures()
                    combat.handlePowerSource()
                    if mq.TLO.Me.CombatState() ~= 'COMBAT' and not (mq.TLO.SpawnCount("npc radius 100 zradius 10")() > 0 and mq.TLO.Me.XTarget() > 0) then
                        if mq.TLO.Me.CombatState() == 'COOLDOWN' or mq.TLO.Me.CombatState() == 'ACTIVE' then mq.cmd('/attack off') end
                        handlePet()
                        buffs.checkLongBuffs()
                        chase.doMed()
                    elseif mq.TLO.Me.CombatState() == 'COMBAT' or (mq.TLO.SpawnCount("npc radius 100 zradius 10")() > 0 and mq.TLO.Me.XTarget() > 0) then
                        combat.initCombat()
                        if tostring(config.General.MedCombat) == 'On' and not mq.TLO.Melee.Combat() then
                            chase.doMed()
                        end
                    end
                end
            elseif state.loop.Invis == true then
                lib.checkFD()
                lib.checkCursor()
                chase.chaseorcamp()
                mq.delay(1000)
                chase.doMed()
                mq.delay(1000)
            end
        end
    end
end

main()


mq.delay(5000)
print('STARTING')
queueAbility(heals.healsreg[1],'spell')
queueAbility(heals.healsreg[1],'spell')
queueAbility(debuffs.cripple,"spell")
queueAbility(mq.TLO.Spell(mq.TLO.Spell(config.CurrentSpellLines.Panther).RankName()).ID(),'spell')
queueAbility(debuffs.cripple,"spell")
printf('BREAK ___________________________')




            else
                -- stay in camp or stay chasing chase target if not paused but invis
                local pet_target_id = mq.TLO.Pet.Target.ID() or 0
                if mq.TLO.Pet.ID() > 0 and pet_target_id > 0 then mq.cmd('/pet back') end
                aqo.camp.mobRadar()
                if (mode:isTankMode() and state.mobCount > 0) or (mode:isAssistMode() and aqo.assist.shouldAssist()) or mode:getName() == 'huntertank' then mq.cmd('/makemevis') end
                aqo.camp.checkCamp()
                common.checkChase()
                common.rest()
                mq.delay(50)
            end
        else
            if state.loop.Invis then
                -- if paused and invis, back pet off, otherwise let it keep doing its thing if we just paused mid-combat for something
                local pet_target_id = mq.TLO.Pet.Target.ID() or 0
                if mq.TLO.Pet.ID() > 0 and pet_target_id > 0 then mq.cmd('/pet back') end
            end
            if config.get('CHASEPAUSED') then
                common.checkChase()
            end
            mq.delay(500)
        end
        -- broadcast some buff and poison/disease/curse state around netbots style
        aqo.buff.broadcast()
    end
end


--]]


