local mq = require('mq')
local state = require('utils.state')
local timer = require('utils.timer')
local M = {}

function M.inControl()
    return not (mq.TLO.Me.Dead() or mq.TLO.Me.Charmed() or mq.TLO.Me.Stunned() or mq.TLO.Me.Silenced() or mq.TLO.Me.Mezzed() or mq.TLO.Me.Invulnerable() or mq.TLO.Me.Hovering())
end

function M.isBlockingWindowOpen()
    -- check blocking windows -- BigBankWnd, MerchantWnd, GiveWnd, TradeWnd
    return mq.TLO.Window('BigBankWnd').Open() or mq.TLO.Window('MerchantWnd').Open() or mq.TLO.Window('GiveWnd').Open() or mq.TLO.Window('TradeWnd').Open() or mq.TLO.Window('LootWnd').Open() or mq.TLO.Window('SpellBookWnd').Open()
end

function M.amiready()
    return not mq.TLO.Me.Invis() and mq.TLO.Melee.Immobilize() and not mq.TLO.Me.Moving() and M.inControl() and not M.isBlockingWindowOpen()
end

local pzoneIds = {151, 202, 203, 219, 344, 345, 463, 737, 33480, 33113}
function M.passiveZone(id)
    for _, zoneId in ipairs(pzoneIds) do
        if id == zoneId then
            return true
        end
    end
    return false
end


function M.debugxtars()
    local xtarheals = tonumber(state.config.General.XTarHealList)
    print('\ay[\amSHM\ag420\ay]\am:\at Debugging XTarget...')
    mq.cmd('/squelch /assist off')
    mq.cmd('/squelch /melee plugin=0')
    for i = 1,20 - xtarheals do
        mq.cmdf('/xtar set %s ah',i)
        mq.delay(20)
    end
end

function M.aggroCount()
    local count = 0
    for i = 1,20 do
        if mq.TLO.Me.XTarget(i).ID() ~= 0 and mq.TLO.Me.XTarget(i).TargetType() == 'Auto Hater' then
            count = count + 1
        end
        mq.delay(10)
    end
    return count
end



function M.checkFD()
    if mq.TLO.Me.Feigning() and (not state.didFD) then
        mq.cmd('/stand')
    end
    if mq.TLO.Me.Ducking() then 
        mq.cmd('/keypress x')
    end
end

local autoInventoryTimer = timer:new(15000)
---Autoinventory an item if it has been on the cursor for 15 seconds.
function M.checkCursor()
    if mq.TLO.Cursor() then
        if autoInventoryTimer.start_time == 0 then
            autoInventoryTimer:reset()
            print('\ay[\amSHM\ag420\ay]\am:\at Dropping cursor item into inventory in 15 seconds')
        elseif autoInventoryTimer:timerExpired() then
            mq.cmd('/autoinventory')
            autoInventoryTimer:reset(0)
        end
    elseif autoInventoryTimer.start_time ~= 0 then
        autoInventoryTimer:reset(0)
    end
end

function M.determineTank()
    local tank = mq.TLO.Group.MainTank
    if not tank then
        tank = mq.TLO.Group.MainAssist
    end
    return tank
end

function M.checkSlowTargets(spawn)
    return spawn.Type() == 'NPC' and spawn.Aggressive()
end

function M.initObservers()

    mq.cmd('/squelch /plugin dannet unload')
    mq.delay(500)
    mq.cmd('/squelch /plugin dannet load')
    mq.delay(500)

    for i = 1, mq.TLO.Me.GroupSize() - 1 do
        M.initToon(mq.TLO.Group.Member(i).Name())
    end

    local tank = M.determineTank()
    mq.cmdf('/dobserve %s -q "%s"',tank.Name(),string.format('Me.Buff[%s]',mq.TLO.Spell(tostring(state.config.Buffs.Sloth)).RankName()))
    mq.delay(20)

end

function M.initToon(toon)
    print('\ay[\amSHM\ag420\ay]\am:\at Initializing DanNet Observers for ' .. toon .. '...')
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Sunset\'s Shadow]')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Discordant Detritus]')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Frenzied Venom]')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Shadowed Venom]')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Viscous Venom]')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Curator\'s Revenge]')
    mq.delay(20)

    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.CountersDisease')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.CountersPoison')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.CountersCurse')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.CountersCorruption')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Debuff.Detrimentals')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Resurrection Sickness]')
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),'Me.Buff[Revival Sickness]')
    mq.delay(20)

    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),string.format('Me.Buff[%s]',mq.TLO.Spell(tostring(state.config.Buffs.FocusBuff)).RankName()))
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),string.format('Me.Buff[%s]',mq.TLO.Spell(tostring(state.config.Buffs.SoW)).RankName()))
    mq.delay(20)
    mq.cmdf('/dobserve %s -q "%s"',mq.TLO.NearestSpawn(string.format('pc %s',toon)).Name(),string.format('Me.Buff[%s]',mq.TLO.Spell(tostring(state.config.Buffs.Regen)).RankName()))
    mq.delay(20)
end




return M