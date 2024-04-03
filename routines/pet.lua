local mq = require('mq')
local state = require('utils.state')
local queueAbility = require('utils.queue')

local function getpetspells()
    return {
    summon = mq.TLO.Spell(state.config.Spells.PetSum).Name(),
    buff1 = mq.TLO.Spell(state.config.Spells.PetBuff1).Name(),
    buff2 = mq.TLO.Spell(state.config.Spells.PetBuff2).Name(),
    shrink = mq.TLO.Spell(state.config.Spells.PetShrink).Name()
}
end

local function handlePet()
    local petspells = getpetspells()
    if tostring(state.config.Pet.PetHold) == 'On' and not mq.TLO.Pet.GHold() then mq.cmd('/pet ghold on') end
    if tostring(state.config.Pet.PetHold) == 'Off' and mq.TLO.Pet.GHold() then mq.cmd('/pet ghold off') end
    if mq.TLO.Pet.ID() == 0 and petspells.summon then
        queueAbility(petspells.summon,'spell')
    elseif mq.TLO.Pet.ID() and not mq.TLO.Pet.Buff(tostring(state.config.Spells.PetBuff1))() and petspells.buff1 then
        queueAbility(petspells.buff1,'spell')
    elseif mq.TLO.Pet.ID() and not mq.TLO.Pet.Buff(tostring(state.config.Spells.PetBuff2))() and petspells.buff2 then
        queueAbility(petspells.buff2,'spell')
    elseif mq.TLO.Pet.ID() and (mq.TLO.Pet.Height() or 0) > 1.4 and (petspells.shrink or false) and tostring(state.config.Pet.PetShrink) == 'On' then
        queueAbility(petspells.shrink,'spell')
    end
end

return handlePet