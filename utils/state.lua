local mq = require('mq')
local write = require('utils.Write')
local conf = require('interface.getconfig')
local timer = require('utils.timer')

local https = require("ssl.https")
local ltn12 = require("ltn12")

-- Function to retrieve the latest GitHub version
local function getGitHubVersion()
    local url = "https://api.github.com/repos/shortbus-allstar/shm420/releases"
    local response = {}

    local _, status = https.request{
        url = url,
        method = "GET",
        sink = ltn12.sink.table(response),
    }

    if status == 200 then
        local responseBody = table.concat(response)

        local json = require("cjson")
        local releases = json.decode(responseBody)

        -- Check if there are releases
        if #releases > 0 then
            -- Retrieve the tag name of the latest release
            return releases[1].tag_name
        else
            return 'No releases found'
        end
    else
        return 'Request failed'
    end
end


local state = {
    buffqueue = {},
    burnqueue = {},
    burning = false,
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
    timesinceBuffed = {},
    recastTimer = nil,
    version = 'v1.0.5-beta',
    githubver = getGitHubVersion()
}


function state.updateLoopState()
    if mq.TLO.MacroQuest.GameState() ~= 'INGAME' then
        print('\ay[\amSHM\ag420\ay]\am:\at Not in game, putting the lighter down...')
        mq.exit()
    end
    write.Trace('Updating Loop State')
    mq.doevents()
    write.Trace('Events Loop State')
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