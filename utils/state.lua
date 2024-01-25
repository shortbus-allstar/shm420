local mq = require('mq')
local write = require('utils.Write')
local conf = require('interface.getconfig')
local timer = require('utils.timer')

local state = {
    buffqueue = {},
    canmem = true,
    config = conf.initConfig(conf.path),
    debug = false,
    dead = false,
    didFD = false,
    dpsqueue = {},
    paused = false,
    cannotRez = nil,
    assistMobID = 0,
    targets = {},
    mobCount = 0,
    mobCountNoPets = 0,
    memqueue = nil,
    resists = {},
    medding = false,
    needheal = false,
    loglevel = 'error',
    rezTimer = timer:new(3000),
    clearRezTimer = timer:new(15000),
    recastTimer = nil
}

function state.updateLoopState()
    if mq.TLO.MacroQuest.GameState() ~= 'INGAME' then
        print('\ay[\amSHM\ag420\ay]\am:\at Not in game, putting the lighter down...')
        mq.exit()
    end
    mq.doevents()
    write.loglevel = state.loglevel
    state.actionTaken = false
    state.loop = {
        PctHPs = mq.TLO.Me.PctHPs(),
        PctMana = mq.TLO.Me.PctMana(),
        PctEndurance = mq.TLO.Me.PctEndurance(),
        ID = mq.TLO.Me.ID(),
        Invis = mq.TLO.Me.Invis(),
        PetName = mq.TLO.Me.Pet.CleanName(),
        TargetID = mq.TLO.Target.ID(),
        TargetHP = mq.TLO.Target.PctHPs(),
        PetID = mq.TLO.Pet.ID(),
        rezTimerCheck = state.rezTimer:timeRemaining(),
        clearRezTimerCheck = state.clearRezTimer:timeRemaining()
    }
end

return state