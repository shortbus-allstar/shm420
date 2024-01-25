local mq = require('mq')
local state = require('utils.state')
local timer = require('utils.timer')
local queueAbility = require('utils.queue')
local lib = require('utils.lib')
local Write = require('utils.Write')
local M = {}

local starttime = mq.gettime() - 60000

local function constructLongBuffsTable()
    return {
        focus = mq.TLO.Spell(state.config.Buffs.Focus).RankName(),
        focusbuff = mq.TLO.Spell(state.config.Buffs.FocusBuff).RankName(),
        selfdi = mq.TLO.Spell(state.config.Buffs.SelfDI).RankName(),
        regen = mq.TLO.Spell(state.config.Buffs.Regen).RankName(),
        sow = mq.TLO.Spell(state.config.Buffs.SoW).RankName(),
    }
end

local checktimer = timer:new(600000)
checktimer:reset(0)

local slothTimer = timer:new(60000)
slothTimer:reset(0)

function M.checkCanni()
    if mq.TLO.Me.PctMana() < tonumber(state.config.Shaman.AACanniAt) and mq.TLO.Me.AltAbilityReady("Cannibalization")() then
        queueAbility(mq.TLO.Me.AltAbility("Cannibalization").ID(),'alt',nil,'canni')
        return
    elseif mq.TLO.Me.PctMana() < tonumber(state.config.Shaman.CanniAt) and mq.TLO.Cast.Ready(mq.TLO.Spell(state.config.Buffs.Canni).RankName())() then
        queueAbility(mq.TLO.Spell(mq.TLO.Spell(state.config.Buffs.Canni).RankName()).ID(),'spell',nil,'canni')
        return
    end
end

function M.checkShortBuffs()
    local tank = lib.determineTank()
    local sloth = string.format('Me.Buff[%s]',mq.TLO.Spell(tostring(state.config.Buffs.Sloth)).RankName())
    M.checkCanni()
    if tostring(state.config.Shaman.EpicOnCD) == 'On' and mq.TLO.Cast.Ready("Blessed Spiritstaff of the Heyokah")() and not mq.TLO.Me.Song("Prophet's Gift of the Ruchu").ID() then
        queueAbility('Blessed Spiritstaff of the Heyokah','item')
        return
    elseif tostring(state.config.Shaman.EpicWithBardSK) == 'On' and mq.TLO.Cast.Ready("Blessed Spiritstaff of the Heyokah")() and (mq.TLO.Me.Song("Spirit of Vesagran").ID() or mq.TLO.Me.Song("Lich Sting").ID()) and not mq.TLO.Me.Song("Prophet's Gift of the Ruchu").ID() then
        queueAbility('Blessed Spiritstaff of the Heyokah','item')
        return
    elseif not mq.TLO.Me.Buff(tostring(state.config.Buffs.Ward))() and mq.TLO.Cast.Ready(mq.TLO.Spell(mq.TLO.Spell(state.config.Buffs.Ward).RankName()).ID())() and tostring(state.config.Shaman.Ward) == 'On' then
        queueAbility(mq.TLO.Spell(mq.TLO.Spell(state.config.Buffs.Ward).RankName()).ID(),'spell')
        return
    elseif not mq.TLO.Me.Buff("Champion")() and mq.TLO.Cast.Ready("Champion")() and tostring(state.config.Shaman.Champion) == 'On' then
        queueAbility(mq.TLO.Spell("Champion").ID(),'spell')
        return
    elseif tostring(tank) ~= 'NULL' and mq.TLO.DanNet(tank.Name()).O(sloth)() and mq.TLO.DanNet(tank.Name()).O(sloth)() == 'NULL' and tostring(state.config.Shaman.SlothTank) == 'On' and tank.ID() ~= 0 and tank.Type() ~= 'Corpse' and tank.Distance3D() < 100 then
        queueAbility(mq.TLO.Spell(mq.TLO.Spell(state.config.Buffs.Sloth).RankName()).ID(),'spell',tank.ID(),'buff')
        return
    elseif tostring(tank) ~= 'NULL' and tostring(state.config.Shaman.WildGrowthTank) == 'On' and mq.TLO.Cast.Ready(mq.TLO.Spell(tostring(state.config.Buffs.Growth)).RankName())() and tank.ID() ~= 0 and tank.Distance3D() < 100 and tank.Type() ~= 'Corpse' then
        queueAbility(mq.TLO.Spell(mq.TLO.Spell(state.config.Buffs.Growth).RankName()).ID(),'spell',tank.ID(),'buff')
        return
    elseif tostring(tank) ~= 'NULL' and not mq.TLO.DanNet(tank.Name()).O(sloth)() and tostring(state.config.Shaman.SlothTank) == 'On' and (mq.gettime() - starttime) > 60000 and tank.ID() ~= 0  and tank.Type() ~= 'Corpse' and tank.Distance3D() < 100 then 
        mq.cmdf('/squelch /mqt id %s',tank.ID())
        mq.delay(400)
        if not mq.TLO.Target.Buff(mq.TLO.Spell(tostring(state.config.Buffs.Sloth)).RankName())() then
            queueAbility(mq.TLO.Spell(mq.TLO.Spell(state.config.Buffs.Sloth).RankName()).ID(),'spell',tank.ID(),'buff')
        end
        starttime = mq.gettime()
        return
    elseif not mq.TLO.Me.Buff(tostring(state.config.Buffs.Panther))() and tostring(state.config.Shaman.Panther) == 'On' and mq.TLO.Me.CombatState() == 'COMBAT' then
        queueAbility(mq.TLO.Spell(state.config.Buffs.Panther).RankName.ID(),'spell')
    end
end

function M.doBuffQueue()
    local buffData = state.buffqueue[1]
    table.remove(state.buffqueue, 1)
    queueAbility(buffData.buffid,'spell',buffData.tarid,'buff')
end

function M.checkBuffQueue()
    Write.Debug('Entering Buff Routine')
    local longbuffs = constructLongBuffsTable()

    if longbuffs.selfdi and not mq.TLO.Me.Buff(longbuffs.selfdi)() and tostring(state.config.Shaman.SelfDI) == 'On' then
        queueAbility(longbuffs.selfdi,'spell',nil,'buff')
        return
    end

    if longbuffs.focus and not mq.TLO.Me.Buff(longbuffs.focusbuff)() and tostring(state.config.Shaman.Focus) == 'On' then
        queueAbility(longbuffs.focus,'spell',state.loop.ID,'buff')
        return
    end

    if longbuffs.sow and not mq.TLO.Me.Buff(longbuffs.sow)() and tostring(state.config.Shaman.SoW) == 'On' then
        queueAbility(longbuffs.sow,'spell',state.loop.ID,'buff')
        return
    end

    if longbuffs.regen and not mq.TLO.Me.Buff(longbuffs.regen)() and tostring(state.config.Shaman.Regen) == 'On' then
        queueAbility(longbuffs.regen,'spell',state.loop.ID,'buff')
        return
    end

    local grpSize = mq.TLO.Me.GroupSize()

    local function getFocusBuffString()
        return string.format('Me.Buff[%s]', mq.TLO.Spell(tostring(state.config.Buffs.FocusBuff)).RankName())
    end
    
    local function getSoWString()
        return string.format('Me.Buff[%s]', mq.TLO.Spell(tostring(state.config.Buffs.SoW)).RankName())
    end
    
    local function getRegenString()
        return string.format('Me.Buff[%s]', mq.TLO.Spell(tostring(state.config.Buffs.Regen)).RankName())
    end
    
    -- Usage example:
    local focus = getFocusBuffString()
    local sow = getSoWString()
    local regen = getRegenString()

    for i = 1, grpSize do
        local toon = mq.TLO.Group.Member(i).Name()
        if mq.TLO.DanNet(toon).O(focus)() and mq.TLO.DanNet(toon).O(focus)() == 'NULL' and tostring(state.config.Shaman.Focus) == 'On' and mq.TLO.Group.Member(i).ID() ~= 0 and mq.TLO.Group.Member(i).Class.ShortName() ~= 'CLR' and mq.TLO.Group.Member(i).Class.ShortName() ~= 'WIZ' and mq.TLO.Group.Member(i).Distance3D() < 100 and mq.TLO.Group.Member(i).Type() ~= 'Corpse' then
            queueAbility(longbuffs.focus,'spell',mq.TLO.Group.Member(i).ID(),'buff')
            return
        elseif mq.TLO.DanNet(toon).O(focus)() and mq.TLO.DanNet(toon).O(focus)() == 'NULL' and tostring(state.config.Shaman.Focus) == 'On' and mq.TLO.Group.Member(i).ID() ~= 0 and (mq.TLO.Group.Member(i).Class.ShortName() == 'CLR' or mq.TLO.Group.Member(i).Class.ShortName() == 'WIZ') and mq.TLO.Group.Member(i).Distance3D() < 100 and mq.TLO.Group.Member(i).Type() ~= 'Corpse' then
            mq.cmd('/squelch /mqt id %s',mq.TLO.Group.Member(i).ID())
            mq.delay(500)
            if not mq.TLO.Target.Buff(mq.TLO.Spell(tostring(state.config.Buffs.AgiBuff)).RankName()) then
                queueAbility(longbuffs.focus,'spell',mq.TLO.Group.Member(i).ID(),'buff')
                return
            end
        elseif mq.TLO.DanNet(toon).O(sow)() and mq.TLO.DanNet(toon).O(sow)() == 'NULL' and tostring(state.config.Shaman.SoW) == 'On' and mq.TLO.Group.Member(i).ID() ~= 0 and mq.TLO.Group.Member(i).Distance3D() < 100 and mq.TLO.Group.Member(i).Type() ~= 'Corpse' then
            queueAbility(longbuffs.sow,'spell',mq.TLO.Group.Member(i).ID(),'buff')
            return
        elseif mq.TLO.DanNet(toon).O(regen)() and mq.TLO.DanNet(toon).O(regen)() == 'NULL' and tostring(state.config.Shaman.Regen) == 'On' and mq.TLO.Group.Member(i).ID() ~= 0 and mq.TLO.Group.Member(i).Distance3D() < 100 and mq.TLO.Group.Member(i).Type() ~= 'Corpse' then
            queueAbility(longbuffs.regen,'spell',mq.TLO.Group.Member(i).ID(),'buff')
            return
        end
    end

    if #state.buffqueue > 0 then
        M.doBuffQueue()
    else
        M.checkShortBuffs()
    end
end
    

return M