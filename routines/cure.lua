local mq = require('mq')
local heals = require('routines.heal')
local state = require('utils.state')
local write = require('utils.Write')
local M = {}

local function getcurestable()
    return {
        radiant = mq.TLO.Me.AltAbility("Radiant Cure").ID(),
        singledis = mq.TLO.Spell(state.config.Spells.DisSing).Name(),
        grpdis = mq.TLO.Spell(state.config.Spells.DisGrp).Name(),
        singlepoi = mq.TLO.Spell(state.config.Spells.PoiSing).Name(),
        grppoi = mq.TLO.Spell(state.config.Spells.PoiGrp).Name(),
        singlecurse = mq.TLO.Spell(state.config.Spells.CurseSing).Name(),
        grpcurse = mq.TLO.Spell(state.config.Spells.CurseGrp).Name(),
        singlecorr = mq.TLO.Spell(state.config.Spells.CorrSing).Name(),
        grpcorr = mq.TLO.Spell(state.config.Spells.CorrGrp).Name()
    }

end

function M.dontcure(toon)
    if (mq.TLO.DanNet(toon).O('Me.Buff[Sunset\'s Shadow]')() ~= 'NULL' or mq.TLO.DanNet(toon).O('Me.Buff[Discordant Detritus]')() ~= 'NULL' or mq.TLO.DanNet(toon).O('Me.Buff[Frenzied Venom]')() ~= 'NULL' or mq.TLO.DanNet(toon).O('Me.Buff[Viscous Venom]')() ~= 'NULL' or mq.TLO.DanNet(toon).O('Me.Buff[Shadowed Venom]')() ~= 'NULL' or mq.TLO.DanNet(toon).O('Me.Buff[Curator\'s Revenge]')()) ~= 'NULL' then return true
    else return false
    end
end

function M.getCounts(toon)
    local diseaseCounters = 'Me.CountersDisease'
    local poisonCounters = 'Me.CountersPoison'
    local curseCounters = 'Me.CountersCurse'
    local corCounters = 'Me.CountersCorruption'
    local dcount = tonumber(mq.TLO.DanNet(toon).O(diseaseCounters)())
    local pcount = tonumber(mq.TLO.DanNet(toon).O(poisonCounters)())
    local cucount = tonumber(mq.TLO.DanNet(toon).O(curseCounters)())
    local cocount = tonumber(mq.TLO.DanNet(toon).O(corCounters)())
    return dcount, pcount, cucount, cocount
end

function M.rezSickCount(toon)
    local cnt = 0
    if mq.TLO.DanNet(toon).O('Me.Buff[Resurrection Sickness]') then
        cnt = cnt + 1
    end
    if mq.TLO.DanNet(toon).O('Me.Buff[Revival Sickness]') then
        cnt = cnt + 1
    end
    return cnt
end

function M.rezSickSelf()
    local cnt = 0
    if mq.TLO.Me.Buff('Resurrection Sickness')() then
        cnt = cnt + 1
    end
    if mq.TLO.Me.Buff('Revival Sickness')() then
        cnt = cnt + 1
    end
    return cnt
end

function M.checkGroupAil()
    if tostring(state.config.General.UseDNet) ~= 'On' or tostring(state.config.Shaman.Cures) ~= 'On' then return
    else
        local curetarget = nil
        local curetype = nil
        local groupcureok = true
        local selfcureok = true
        local tocure = {}
        local grpSize = mq.TLO.Me.GroupSize()
        if mq.TLO.Me.Buff('Sunset\'s Shadow')() or mq.TLO.Me.Buff('Discordant Detritus')() or mq.TLO.Me.Buff('Frenzied Venom')() or mq.TLO.Me.Buff('Shadowed Venom')() or mq.TLO.Me.Buff('Viscous Venom')() or mq.TLO.Me.Buff('Curator\'s Revenge')() then
            write.Debug('Cant cure self, no group')
            groupcureok = false
            selfcureok = false
        end
        for i = 1, grpSize - 1 do
            local grpMem = mq.TLO.Group.Member(i).Name()
            if mq.TLO.DanNet(grpMem).ObserveCount() then
                local insert = true
                local hasbuff = M.dontcure(grpMem)
                if hasbuff == true then
                    groupcureok = false
                    insert = false
                end
                if tonumber(mq.TLO.DanNet(grpMem).O('Debuff.Detrimentals')()) > M.rezSickCount(grpMem) then
                    curetype = 'det'
                    curetarget = mq.TLO.Group.Member(grpMem).ID()
                end
                if insert == true then table.insert(tocure,grpMem) end
            end
        end
        if selfcureok == true then
            if mq.TLO.Me.CountersDisease() > 0 then
                curetarget = mq.TLO.Me.ID()
                curetype = 'disease'
                return curetarget, curetype, groupcureok 
            end
            if mq.TLO.Me.CountersPoison() > 0 then
                curetarget = mq.TLO.Me.ID()
                curetype = 'poison'
                return curetarget, curetype, groupcureok 
            end
            if mq.TLO.Me.CountersCurse() > 0 then
                curetarget = mq.TLO.Me.ID()
                curetype = 'curse'
                return curetarget, curetype, groupcureok 
            end
            if mq.TLO.Me.CountersCorruption() > 0 then
                curetarget = mq.TLO.Me.ID()
                curetype = 'corr'
                return curetarget, curetype, groupcureok 
            end
            if mq.TLO.Debuff.Detrimentals() > M.rezSickSelf() then
                curetarget = mq.TLO.Me.ID()
                curetype = 'det'
                return curetarget, curetype, groupcureok 
            end
        end
        for _, v in pairs(tocure) do
            local grpMem = mq.TLO.Group.Member(v).Name()
            local dcount, pcount, cucount, cocount = M.getCounts(grpMem)
            write.Trace('DisCount: %s, PoiCount: %s, CoCount: %s, CuCount: %s',dcount, pcount, cocount, cucount)
            if dcount and dcount > 0 then
                curetarget = mq.TLO.Group.Member(v).ID()
                curetype = 'disease'
                if curetarget ~= nil then return curetarget, curetype, groupcureok end
            end
            if pcount and pcount > 0 then
                curetarget = mq.TLO.Group.Member(v).ID()
                curetype = 'poison'
                if curetarget ~= nil then return curetarget, curetype, groupcureok end
            end
            if cucount and cucount > 0 then
                curetarget = mq.TLO.Group.Member(v).ID()
                curetype = 'curse'
                if curetarget ~= nil then return curetarget, curetype, groupcureok end
            end
            if cocount and cocount > 0 then
                curetarget = mq.TLO.Group.Member(v).ID()
                curetype = 'corr'
                if curetarget ~= nil then return curetarget, curetype, groupcureok end
            end
        end
        return curetarget, curetype, groupcureok
    end
end

function M.doCures()
    if tostring(state.config.Shaman.Cures) ~= 'On' then return 
    else
        local tar, curetype, group = M.checkGroupAil()
        local cures = getcurestable()
        write.Debug('doing cures')
        write.Debug('CureTar: %s, Curetype: %s, Group: %s',tar,curetype,group)
        if tar ~= nil then
            local queueAbility = require('utils.queue')
            if curetype == 'disease' then
                if group == true then
                    if mq.TLO.Me.AltAbilityReady("Radiant Cure")() then
                        queueAbility(cures.radiant,'alt',tar,'cure')
                    elseif cures.grpdis ~= nil then
                        queueAbility(cures.grpdis,'spell',tar,'cure')
                    end
                elseif cures.singledis ~= nil then
                    queueAbility(cures.singledis,'spell',tar,'cure')
                end
            end
            if curetype == 'poison' then
                if group == true then
                    if mq.TLO.Me.AltAbilityReady("Radiant Cure")() then
                        queueAbility(cures.radiant,'alt',tar,'cure')
                    elseif cures.grppoi ~= nil then
                        queueAbility(cures.grppoi,'spell',tar,'cure')
                    end
                elseif cures.singlepoi ~= nil then
                    queueAbility(cures.singlepoi,'spell',tar,'cure')
                end
            end
            if curetype == 'curse' then
                if group == true then
                    if mq.TLO.Me.AltAbilityReady("Radiant Cure")() then
                        queueAbility(cures.radiant,'alt',tar,'cure')
                    elseif cures.grpcurse ~= nil then
                        queueAbility(cures.grpcurse,'spell',tar,'cure')
                    end
                elseif cures.singlecurse ~= nil then
                    queueAbility(cures.singlecurse,'spell',tar,'cure')
                end
            end
            if curetype == 'corr' then
                if group == true then
                    if mq.TLO.Me.AltAbilityReady("Radiant Cure")() then
                        queueAbility(cures.radiant,'alt',tar,'cure')
                    elseif cures.grpcor ~= nil then
                        queueAbility(cures.grpcor,'spell',tar,'cure')
                    end
                elseif cures.singlecorr ~= nil then
                    queueAbility(cures.singlecorr,'spell',tar,'cure')
                end
            end
            if curetype == 'det' then
                if group == true then
                    if mq.TLO.Me.AltAbilityReady("Radiant Cure")() then
                        queueAbility(cures.radiant,'alt',tar,'cure')
                    end
                end
            end
            mq.delay(250)
            heals.doheals()
        end
    end
end

return M