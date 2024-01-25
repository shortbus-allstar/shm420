local mq = require('mq')
local state = require('utils.state')
local write = require('utils.Write')
local chase = require('routines.campchase')

local events = {}

function events.init()
    mq.event('interrupted', '#*#Your #1#spell is interrupted#*#', events.interruptcallback)
    mq.event('fizzle', '#*#Your #1#spell fizzles#*#', events.interruptcallback)
    mq.event('eventCannotRez', '#*#This corpse cannot be resurrected#*#', events.cannotRez)
    mq.event('eventDead', 'You died.', events.eventDead)
    mq.event('eventDeadSlain', 'You have been slain by#*#', events.eventDead)
    mq.event('zoned', '#*#Returning to Bind Location#*#', events.notDead)
    mq.event('rezzed', 'You regain some experience from resurrection.', events.notDead)
    local keywordal = string.format('#1# tells you, \'%s\'',state.config.Buffs.KeywordAll)
    mq.event('keyworda',keywordal, events.keywordall)

end

events.interruptcallback = function(line, arg1)
    write.Debug('Interrup Event')
    state.interrupted = true
end

function events.keywordall(line, arg1)
    write.Debug('\apkeyword callback Arg1: %s',arg1)
    local data1 = {
        buffid = mq.TLO.Spell(state.config.Buffs.Focus).RankName.ID(),
        tarid = mq.TLO.Spawn(arg1).ID()
    }

    local data2 = {
        buffid = mq.TLO.Spell(state.config.Buffs.SoW).RankName.ID(),
        tarid = mq.TLO.Spawn(arg1).ID()
    }

    local data3 = {
        buffid = mq.TLO.Spell(state.config.Buffs.Regen).RankName.ID(),
        tarid = mq.TLO.Spawn(arg1).ID()
    }

    table.insert(state.buffqueue,data1)
    table.insert(state.buffqueue,data2)
    table.insert(state.buffqueue,data3)
end

function events.notDead()
    state.dead = false
    mq.delay(500)
    state.paused = false
    mq.flushevents()
    print('\ay[\amSHM\ag420\ay]\am:\atUnpausing...')
end

function events.eventDead()
    state.dead = true
    print('\ay[\amSHM\ag420\ay]\am:\atYou greened out dawg. Pausing your shit')
    state.campxloc, state.campyloc, state.campzloc = chase.clearCamp()
    mq.flushevents()
end

function events.cannotRez()
    state.cannotRez = true
end

function events.testcallback(line, arg1, arg2)
    print(arg1)
    print(arg2)
end

        
return events


