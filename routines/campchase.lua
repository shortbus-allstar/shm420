local mq = require('mq')
local state = require('utils.state')
local write = require('utils.Write')
local M = {}

function M.doMed()
    write.Trace('Checking if i need to med')
    if tostring(state.config.General.Med) == 'On' and mq.TLO.Me.PctMana() < tonumber(state.config.General.MedStart) and not mq.TLO.Me.Sitting() and not mq.TLO.Me.Moving() and mq.TLO.Cast.Timing() == 0 then
        mq.cmd('/sit')
        print('\ay[\amSHM\ag420\ay]\am:\at Sitting down to med. Take another hit.')
        state.medding = true
    elseif state.medding == true and mq.TLO.Me.PctMana() < tonumber(state.config.General.MedStop) and not mq.TLO.Me.Sitting() and not mq.TLO.Me.Moving() and mq.TLO.Cast.Timing() == 0 then
        mq.cmd('/sit')
        print('\ay[\amSHM\ag420\ay]\am:\at Sitting down to med. Take another hit.')
    elseif state.medding == true and mq.TLO.Me.PctMana() >= tonumber(state.config.General.MedStop) and not mq.TLO.Me.Standing() then
        mq.cmd('/stand')
        print('\ay[\amSHM\ag420\ay]\am:\at Standing up. Pinching the joint.')
        state.medding = false
    end
end

function M.setcamp()
    local xloc = tonumber(mq.TLO.Me.LocYXZ.Token("2,,")())
    local yloc = tonumber(mq.TLO.Me.LocYXZ.Token("1,,")())
    local zloc = tonumber(mq.TLO.Me.LocYXZ.Token("3,,")())
    return xloc, yloc, zloc
end


function M.clearCamp()
    state.config.General.ReturnToCamp = 'Off'
    return nil, nil, nil
end

function M.needToNav()
    local mexloc = tonumber(mq.TLO.Me.LocYXZ.Token("2,,")())
    local meyloc = tonumber(mq.TLO.Me.LocYXZ.Token("1,,")())
    local mezloc = tonumber(mq.TLO.Me.LocYXZ.Token("3,,")())
    if state.campxloc and state.campyloc and state.campzloc and (state.campxloc - 10 < mexloc and mexloc < state.campxloc + 10) and (state.campyloc - 10 < meyloc and meyloc < state.campyloc + 10) and (state.campzloc - 5 < mezloc and mezloc < state.campzloc + 5) then
        return false
    elseif mq.TLO.Melee.Combat() then
        return false
    else 
        return true
    end
end

function M.chaseorcamp()
    if tostring(state.config.General.ChaseAssist) == 'On' then
        local MA = mq.TLO.Group.MainAssist.ID()
        local needchase = mq.TLO.SpawnCount(string.format(("id %s radius %s"), MA, tonumber(state.config.General.ChaseDistance)))()
        if needchase < 1 and MA then
            mq.cmdf('/squelch /nav id %s dist=%s',MA,state.config.General.ChaseDistance)
        end
    elseif tostring(state.config.General.ReturnToCamp) == 'On' and M.needToNav() and mq.TLO.Me.CombatState() ~= 'COMBAT' then
        if not state.campxloc then state.campxloc, state.campyloc, state.campzloc = M.setcamp() end
        mq.cmdf('/nav loc %s %s %s',state.campyloc,state.campxloc,state.campzloc)
    end
end

return M

