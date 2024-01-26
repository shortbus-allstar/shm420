local mq = require('mq')
local state = require('utils.state')
local conf = require('interface.getconfig')
require('ImGui')
local ui = {}
local anim = mq.FindTextureAnimation('A_SpellIcons')
local classanim = mq.FindTextureAnimation('A_DragItem')
local icons = require('mq.icons')
local frameCounter = 0
local flashInterval = 250 

local MINIMUM_WIDTH = 430
local BUTTON_SIZE = 55

local openGUI = true
local shouldDrawGUI = true
local gentabOffset = 200 -- Adjust this value based on your layout
local spelltabOffset = 270


local CUSTOM_THEME = {
    windowbg = ImVec4(0.1, 0.2, 0.1, 0.9),
    bg = ImVec4(0, 0.3, 0, 1),
    hovered = ImVec4(0, 0.4, 0, 1),
    active = ImVec4(0, 0.5, 0, 1),
    button = ImVec4(0, 0.3, 0, 1),
    text = ImVec4(1, 0.8, 0, 1),
}

local function pushStyle(t)
    ImGui.PushStyleColor(ImGuiCol.WindowBg, t.windowbg)
    ImGui.PushStyleColor(ImGuiCol.TitleBg, t.bg)
    ImGui.PushStyleColor(ImGuiCol.TitleBgActive, t.active)
    ImGui.PushStyleColor(ImGuiCol.FrameBg, t.bg)
    ImGui.PushStyleColor(ImGuiCol.FrameBgHovered, t.hovered)
    ImGui.PushStyleColor(ImGuiCol.FrameBgActive, t.active)
    ImGui.PushStyleColor(ImGuiCol.Button, t.button)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, t.hovered)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, t.active)
    ImGui.PushStyleColor(ImGuiCol.PopupBg, t.bg)
    ImGui.PushStyleColor(ImGuiCol.Tab, 0, 0, 0, 0)
    ImGui.PushStyleColor(ImGuiCol.TabActive, t.active)
    ImGui.PushStyleColor(ImGuiCol.TabHovered, t.hovered)
    ImGui.PushStyleColor(ImGuiCol.TabUnfocused, t.bg)
    ImGui.PushStyleColor(ImGuiCol.TabUnfocusedActive, t.hovered)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, t.active)
    ImGui.PushStyleColor(ImGuiCol.Header, t.bg)
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, t.hovered)
    ImGui.PushStyleColor(ImGuiCol.TextDisabled, t.text)
    ImGui.PushStyleColor(ImGuiCol.Text, t.text)
    ImGui.PushStyleColor(ImGuiCol.CheckMark, t.text)
    ImGui.PushStyleColor(ImGuiCol.Separator, t.hovered)

    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 10)
end

local checkboxes = {}

local function initcheckboxes()
    checkboxes.ReturnToCamp = state.config.General.ReturnToCamp == 'On' and true or false
    checkboxes.ChaseAssist = state.config.General.ChaseAssist == 'On' and true or false
    checkboxes.Buffs = state.config.General.Buffs == 'On' and true or false
    checkboxes.Med = state.config.General.Med == 'On' and true or false
    checkboxes.MedCombat = state.config.General.MedCombat == 'On' and true or false
    checkboxes.UseDNet = state.config.General.UseDNet == 'On' and true or false
    checkboxes.XTarHeal = state.config.General.XTarHeal == 'On' and true or false
    checkboxes.Cures = state.config.Shaman.Cures == 'On' and true or false
    checkboxes.EpicOnCD = state.config.Shaman.EpicOnCD == 'On' and true or false
    checkboxes.EpicWithBardSK = state.config.Shaman.EpicWithBardSK == 'On' and true or false
    checkboxes.MiscGemRemem = state.config.Spells.MiscGemRemem == 'On' and true or false
    checkboxes.CastFocus = state.config.Shaman.Focus == 'On' and true or false
    checkboxes.CastChampion = state.config.Shaman.Champion == 'On' and true or false
    checkboxes.CastPanther = state.config.Shaman.Panther == 'On' and true or false
    checkboxes.CastRegen = state.config.Shaman.Regen == 'On' and true or false
    checkboxes.CastSelfDI = state.config.Shaman.SelfDI == 'On' and true or false
    checkboxes.CastSlothTank = state.config.Shaman.SlothTank == 'On' and true or false
    checkboxes.CastWard = state.config.Shaman.Ward == 'On' and true or false
    checkboxes.CastWildGrowthTank = state.config.Shaman.WildGrowthTank == 'On' and true or false
    checkboxes.CastSoW = state.config.Shaman.SoW == 'On' and true or false
    checkboxes.InterruptToHeal = state.config.Heals.InterruptToHeal == 'On' and true or false
    checkboxes.CallOfWild = state.config.Shaman.CallOfWild == 'On' and true or false
    checkboxes.HealGroupPets = state.config.Shaman.HealGroupPets == 'On' and true or false
    checkboxes.HoTTank = state.config.Shaman.HoTTank == 'On' and true or false
    checkboxes.RezOOC = state.config.Shaman.RezOOC == 'On' and true or false
    checkboxes.RezStick = state.config.Shaman.RezStick == 'On' and true or false
    checkboxes.Radiant = state.config.Spells.Radiant == 'On' and true or false
    checkboxes.useAura = state.config.Shaman.Aura == 'On' and true or false
    checkboxes.FocusWord = state.config.KeywordCustom.Focus == 'On' and true or false
    checkboxes.SoWWord = state.config.KeywordCustom.SoW == 'On' and true or false
    checkboxes.RegenWord = state.config.KeywordCustom.Regen == 'On' and true or false
    checkboxes.BurnAllNamed = state.config.Burn.BurnAllNamed == 'On' and true or false
    checkboxes.SmallWithBig = state.config.Burn.SmallWithBig == 'On' and true or false
    checkboxes.UseTribute = state.config.Burn.UseTribute == 'On' and true or false
    checkboxes.PetHold = state.config.Pet.PetHold == 'On' and true or false
    checkboxes.PetShrink = state.config.Pet.PetShrink == 'On' and true or false
    checkboxes.PsEnabled = state.config.Powersource.PsEnabled == 'On' and true or false
end

local function checkboxesCombat() 
    local boxes = {
    Melee = state.config.Combat.Melee == 'On' and true or false,
    TimeAntithesis = state.config.Combat.TimeAntithesis == 'On' and true or false,
    AAMalo = state.config.Shaman.AAMalo == 'On' and true or false,
    AASingleTurgurs = state.config.Shaman.AASingleTurgurs == 'On' and true or false,
    AEMalo = state.config.Shaman.AEMalo == 'On' and true or false,
    AETurgurs = state.config.Shaman.AETurgurs == 'On' and true or false,
    Slow = state.config.Shaman.Slow  == 'On' and true or false
    }
    return boxes
end


local function popStyles()
    ImGui.PopStyleColor(22)

    ImGui.PopStyleVar(1)
end

function ui.main()
    initcheckboxes()
    if not openGUI then return end
    pushStyle(CUSTOM_THEME)
    openGUI, shouldDrawGUI = ImGui.Begin('SHM420', openGUI, 0)
    if shouldDrawGUI then
        frameCounter = frameCounter + 1
        
        ImGui.BeginTabBar('Tabs')

        -- First tab: Control Panel
        if ImGui.BeginTabItem(icons.MD_CODE..'   Console') then
            local totalWidth, _ = ImGui.GetContentRegionAvail()
            local columnWidth = totalWidth / 2

            ImGui.Columns(2)
            ImGui.SetColumnOffset(1, spelltabOffset)
            ImGui.SetColumnWidth(1,columnWidth)
            ImGui.SetColumnWidth(2,columnWidth)

            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 15) 

            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0.8, 0.2, 0.8, 1.0))
            ImGui.SetWindowFontScale(1.7)
            ImGui.Text('SHM')
            ImGui.PopStyleColor()
            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() - 8)
            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0, 1, 0, 1.0)) 
            ImGui.Text('420')
            ImGui.PopStyleColor()
            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 15)
            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(1.0, 0.5, 0.0, 1.0)) 
            ImGui.Text(state.version)
            ImGui.SetWindowFontScale(1)
            ImGui.PopStyleColor()


            ImGui.NewLine()

            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 30) 

            classanim:SetTextureCell(696)
            ImGui.DrawTextureAnimation(classanim,200,200)

            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() - 105) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 80)
            classanim:SetTextureCell(8657)
            ImGui.DrawTextureAnimation(classanim,115,115)

            ImGui.NewLine()
            local windowHeight = ImGui.GetWindowHeight()
            local buttonPosY = windowHeight - 250  -- Adjust the spacing as needed
        
            ImGui.SetCursorPosY(buttonPosY)

            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 75) 
            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0, 1, 1, 1))

            if ImGui.Button(string.format('Update\n     ' .. icons.FA_DOWNLOAD), BUTTON_SIZE * 2, BUTTON_SIZE) then
                os.execute('powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri \'https://raw.githubusercontent.com/shortbus-allstar/shm420/main/shm420.zip\' -OutFile \'' .. mq.luaDir .. '\\shm420.zip\' -UseBasicParsing"')
             

                local zipFilePath = mq.luaDir .. "\\shm420.zip"
                local targetDir = mq.luaDir
                local extractDir = mq.luaDir .. "\\shm420"
                
                -- Construct PowerShell command with Lua variables
                local powershellCommand = 'powershell -ExecutionPolicy Bypass -File "' .. mq.luaDir .. '\\shm420\\utils\\update.ps1" ' .. '-zipFilePath "' .. zipFilePath .. '" ' .. '-targetDir "' .. targetDir .. '" ' .. '-extractDir "' .. extractDir .. '"'
                
                -- Execute the PowerShell script using os.execute
                os.execute(powershellCommand)
                
                os.execute('del "' .. zipFilePath .. '"')
            end

            ImGui.PopStyleColor()


            if state.version ~= tostring(state.githubver) then
                local alpha = 0.5 * (1 + math.sin((frameCounter % flashInterval) / flashInterval * (2 * math.pi)))  -- Use a sine function for smooth fading

                ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 75) 
                ImGui.TextColored(ImVec4(1, 0, 0, alpha), "Update Available!")
            else
                ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 70)
                ImGui.TextColored(ImVec4(0, 1, 0, 1), "Using Latest Version")
            end

            ImGui.NewLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 40) 

            ImGui.Text('GitHub Version:') 
            ImGui.SameLine()
            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(1.0, 0.5, 0.0, 1.0))
            ImGui.Text(tostring(state.githubver)) 
            ImGui.PopStyleColor()

            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 8) 

            local buttonLabel1 = "Set\nCamp"
            if ImGui.Button(buttonLabel1, BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/shm camp on')
            end
            ImGui.SameLine()

            local buttonLabel2 = "Camp\nOff"
            if ImGui.Button(buttonLabel2, BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/shm camp off')
            end
            ImGui.SameLine()

            local buttonLabel3 = "Chase\nOn"
            if ImGui.Button(buttonLabel3, BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/shm chase ofn')
            end
            ImGui.SameLine()

            local buttonLabel4 = "Chase\nOff"
            if ImGui.Button(buttonLabel4, BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/shm chase off')
            end  
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 8) 

            local buttonLabel5 = "Melee\nOn"
            if ImGui.Button(buttonLabel5, BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/shm melee on')
            end
            ImGui.SameLine()

            local buttonLabel6 = "Melee\nOff"
            if ImGui.Button(buttonLabel6, BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/shm melee off')
            end  
            ImGui.SameLine()

            

            if state.paused then
                ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0, 1, 0, 1))
                if ImGui.Button(string.format('Resume\n     ' .. icons.FA_PLAY), BUTTON_SIZE, BUTTON_SIZE) then
                    state.paused = false
                end
                ImGui.PopStyleColor()
            else
                ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(1, 0, 0, 1))
                if ImGui.Button(string.format('Pause\n    ' .. icons.FA_PAUSE), BUTTON_SIZE, BUTTON_SIZE) then
                    state.paused = true
                    mq.cmd('/stopcast')
                end
                ImGui.PopStyleColor()
            end
            ImGui.SameLine()

            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0, 1, 1, 1))

            if ImGui.Button(string.format('Reload\n     ' .. icons.FA_REFRESH), BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/multiline ; /lua stop shm420 ; /timed 5 /lua run shm420')
            end

            ImGui.PopStyleColor()

            ImGui.NextColumn()

            local function hpcolor()
                if mq.TLO.Me.PctHPs() > 75 then return ImVec4(0,1,0,1) end
                if mq.TLO.Me.PctHPs() <= 75 and mq.TLO.Me.PctHPs() > 35 then return ImVec4(1,1,0,1) end
                if mq.TLO.Me.PctHPs() <= 35 then return ImVec4(1,0,0,1) end
            end

            local function manacolor()
                if mq.TLO.Me.PctMana() > 75 then return ImVec4(0,1,0,1) end
                if mq.TLO.Me.PctMana() <= 75 and mq.TLO.Me.PctMana() > 35 then return ImVec4(1,1,0,1) end
                if mq.TLO.Me.PctMana() <= 35 then return ImVec4(1,0,0,1) end
            end

            ImGui.TextColored(ImVec4(0, 1, 1, 1),mq.TLO.Me.Name())
            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Level')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(mq.TLO.Me.Level()))
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Shaman')

            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 10) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 15) 
            anim:SetTextureCell(867)
            ImGui.DrawTextureAnimation(anim,55,55)

            ImGui.NewLine()
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 45) 

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Hitpoints %:')
            ImGui.SameLine()
            ImGui.TextColored(hpcolor(),tostring(mq.TLO.Me.PctHPs()))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Mana %:')
            ImGui.SameLine()
            ImGui.TextColored(manacolor(),tostring(mq.TLO.Me.PctMana()))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Current Zone:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(mq.TLO.Zone.Name()))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Group Main Tank:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(mq.TLO.Group.MainTank.Name()))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Players in Zone:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(mq.TLO.SpawnCount('pc')()))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Currently Casting:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(mq.TLO.Me.Casting.Name()))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Current Target:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(mq.TLO.Target.CleanName()))

            ImGui.NewLine()
            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Debug Info:')

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'# in Buff Queue:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(#state.buffqueue))
            ImGui.SameLine()
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 2) 
            ImGui.PushStyleColor(ImGuiCol.Text,ImVec4(1,0,0,1))
            if ImGui.Button('Clear',ImVec2(40,20)) then
                state.buffqueue = {}
            end
            ImGui.PopStyleColor()
            
            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'# in DPS Queue:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(#state.dpsqueue))
            ImGui.SameLine()
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 2) 
            ImGui.PushStyleColor(ImGuiCol.Text,ImVec4(1,0,0,1))
            if ImGui.Button('Clear',ImVec2(40,20)) then
                state.dpsqueue = {}
                state.canmem = true
            end
            ImGui.PopStyleColor()

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'# in Burn Queue:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(#state.burnqueue))
            ImGui.SameLine()
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 2) 
            ImGui.PushStyleColor(ImGuiCol.Text,ImVec4(1,0,0,1))
            if ImGui.Button('Clear',ImVec2(40,20)) then
                state.burnqueue = {}
            end
            ImGui.PopStyleColor()

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Can Mem:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(state.canmem))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Burning:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(state.burning))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Medding:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(state.medding))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Need to Heal:')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0, 1, 1, 1),tostring(state.needheal))

            ImGui.TextColored(ImVec4(1, 0.8, 0, 1),'Log Level:')
            ImGui.SameLine()
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 2) 

            local options = { "trace", "debug", "info", "warn", "error", "fatal", "help" }

            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0, 1, 1, 1))

            if ImGui.BeginCombo("##loglevel:", state.loglevel, ImGuiComboFlags.None) then
                for i, option in ipairs(options) do
                    local isSelected = (i == selectedOptionIndex)
            
                    ImGui.PushStyleColor(ImGuiCol.Text, isSelected and ImVec4(0, 1, 1, 1) or ImGui.GetStyleColorVec4(ImGuiCol.Text))
            
                    if ImGui.Selectable(option, isSelected) then
                        selectedOptionIndex = i
                        state.loglevel = option -- Update state.loglevel based on the selected option
                    end
            
                    ImGui.PopStyleColor()
            
                    -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
                    if isSelected then
                        ImGui.SetItemDefaultFocus()
                    end
                end
            
                ImGui.EndCombo()
            end

            ImGui.PopStyleColor()

            ImGui.Columns(1)
            ImGui.EndTabItem()
        end

        if ImGui.BeginTabItem(icons.FA_BOOK..'  Spells') then
            local totalWidth, _ = ImGui.GetContentRegionAvail()
            local columnWidth = totalWidth / 2

            if ImGui.CollapsingHeader('Buffs',ImGuiTreeNodeFlags.None) then
            anim:SetTextureCell(130)
            ImGui.SameLine()
            ImGui.DrawTextureAnimation(anim,23,23)
            ImGui.Columns(2)
            ImGui.SetColumnOffset(1, spelltabOffset)
            ImGui.SetColumnWidth(1,columnWidth)
            ImGui.SetColumnWidth(2,columnWidth)

            ImGui.Text("Canni:")
            ImGui.SameLine()
            local inputTextBufferCanni = state.config.Buffs.Canni
            local inputTextCallbackCanni = function(inputText)
                state.config.Buffs.Canni = inputText
            end
            local newTextCanni, changedCanni = ImGui.InputText("##CanniInput", inputTextBufferCanni, ImGuiInputTextFlags.None, inputTextCallbackCanni)
            if changedCanni then
                state.config.Buffs.Canni = newTextCanni
            end

            ImGui.Text("AgiBuff:")
            ImGui.SameLine()
            local inputTextBufferAgiBuff = state.config.Buffs.AgiBuff
            local inputTextCallbackAgiBuff = function(inputText)
                state.config.Buffs.AgiBuff = inputText
            end
            local newTextAgiBuff, changedAgiBuff = ImGui.InputText("##AgiBuffInput", inputTextBufferAgiBuff, ImGuiInputTextFlags.None, inputTextCallbackAgiBuff)
            if changedAgiBuff then
                state.config.Buffs.AgiBuff = newTextAgiBuff
            end
        
            ImGui.Text("Focus:")
            ImGui.SameLine()
            local inputTextBufferFocus = state.config.Buffs.Focus
            local inputTextCallbackFocus = function(inputText)
                state.config.Buffs.Focus = inputText
            end
            local newTextFocus, changedFocus = ImGui.InputText("##FocusInput", inputTextBufferFocus, ImGuiInputTextFlags.None, inputTextCallbackFocus)
            if changedFocus then
                state.config.Buffs.Focus = newTextFocus
            end
        
            ImGui.Text("SoW:")
            ImGui.SameLine()
            local inputTextBufferSoW = state.config.Buffs.SoW
            local inputTextCallbackSoW = function(inputText)
                state.config.Buffs.SoW = inputText
            end
            local newTextSoW, changedSoW = ImGui.InputText("##SoWInput", inputTextBufferSoW, ImGuiInputTextFlags.None, inputTextCallbackSoW)
            if changedSoW then
                state.config.Buffs.SoW = newTextSoW
            end
        
            ImGui.Text("Panther:")
            ImGui.SameLine()
            local inputTextBufferPanther = state.config.Buffs.Panther
            local inputTextCallbackPanther = function(inputText)
                state.config.Buffs.Panther = inputText
            end
            local newTextPanther, changedPanther = ImGui.InputText("##PantherInput", inputTextBufferPanther, ImGuiInputTextFlags.None, inputTextCallbackPanther)
            if changedPanther then
                state.config.Buffs.Panther = newTextPanther
            end

            ImGui.Text("Growth:")
            ImGui.SameLine()
            local inputTextBufferGrowth = state.config.Buffs.Growth
            local inputTextCallbackGrowth = function(inputText)
                state.config.Buffs.Growth = inputText
            end
            local newTextGrowth, changedGrowth = ImGui.InputText("##GrowthInput", inputTextBufferGrowth, ImGuiInputTextFlags.None, inputTextCallbackGrowth)
            if changedGrowth then
                state.config.Buffs.Growth = newTextGrowth
            end
        
        
            ImGui.NextColumn()  -- Move to the right column
        
            
            ImGui.Text("Sloth:")
            ImGui.SameLine()
            local inputTextBufferSloth = state.config.Buffs.Sloth
            local inputTextCallbackSloth = function(inputText)
                state.config.Buffs.Sloth = inputText
            end
            local newTextSloth, changedSloth = ImGui.InputText("##SlothInput", inputTextBufferSloth, ImGuiInputTextFlags.None, inputTextCallbackSloth)
            if changedSloth then
                state.config.Buffs.Sloth = newTextSloth
            end
        
            ImGui.Text("Regen:")
            ImGui.SameLine()
            local inputTextBufferRegen = state.config.Buffs.Regen
            local inputTextCallbackRegen = function(inputText)
                state.config.Buffs.Regen = inputText
            end
            local newTextRegen, changedRegen = ImGui.InputText("##RegenInput", inputTextBufferRegen, ImGuiInputTextFlags.None, inputTextCallbackRegen)
            if changedRegen then
                state.config.Buffs.Regen = newTextRegen
            end
        
            ImGui.Text("Ward:")
            ImGui.SameLine()
            local inputTextBufferWard = state.config.Buffs.Ward
            local inputTextCallbackWard = function(inputText)
                state.config.Buffs.Ward = inputText
            end
            local newTextWard, changedWard = ImGui.InputText("##WardInput", inputTextBufferWard, ImGuiInputTextFlags.None, inputTextCallbackWard)
            if changedWard then
                state.config.Buffs.Ward = newTextWard
            end
            -- Right Column
            ImGui.Text("FocusBuff:")
            ImGui.SameLine()
            local inputTextBufferFocusBuff = state.config.Buffs.FocusBuff
            local inputTextCallbackFocusBuff = function(inputText)
                state.config.Buffs.FocusBuff = inputText
            end
            local newTextFocusBuff, changedFocusBuff = ImGui.InputText("##FocusBuffInput", inputTextBufferFocusBuff, ImGuiInputTextFlags.None, inputTextCallbackFocusBuff)
            if changedFocusBuff then
                state.config.Buffs.FocusBuff = newTextFocusBuff
            end

            ImGui.Text("SelfDI:")
            ImGui.SameLine()
            local inputTextBufferSelfDI = state.config.Buffs.SelfDI
            local inputTextCallbackSelfDI = function(inputText)
                state.config.Buffs.SelfDI = inputText
            end
            local newTextSelfDI, changedSelfDI = ImGui.InputText("##SelfDIInput", inputTextBufferSelfDI, ImGuiInputTextFlags.None, inputTextCallbackSelfDI)
            if changedSelfDI then
                state.config.Buffs.SelfDI = newTextSelfDI
            end
        
            -- Continue adding more items for the right column...
        
            ImGui.Columns(1)  -- Reset back to a single column layout

            ImGui.EndTabItem()
        else
            anim:SetTextureCell(130)
            ImGui.SameLine()
            ImGui.DrawTextureAnimation(anim,23,23)
        end

            if ImGui.CollapsingHeader('Heals', ImGuiTreeNodeFlags.None) then
                anim:SetTextureCell(99)
                ImGui.SameLine()
                ImGui.DrawTextureAnimation(anim, 23, 23)
                ImGui.Columns(2)
                ImGui.SetColumnOffset(1, spelltabOffset)
                ImGui.SetColumnWidth(1, columnWidth)
                ImGui.SetColumnWidth(2, columnWidth)
            
                -- Entries for Panic 1 to Panic 5
                for i = 1, 5 do
                    local labelPanic = string.format("Panic %d:", i)
                    ImGui.Text(labelPanic)
                    ImGui.SameLine()
                    local inputTextBufferPanic = state.config.Heals[string.format("Panic%d", i)]
                    local inputTextCallbackPanic = function(inputText)
                        state.config.Heals[string.format("Panic%d", i)] = inputText
                    end
                    local newTextPanic, changedPanic = ImGui.InputText(string.format("##Panic%dInput", i), inputTextBufferPanic, ImGuiInputTextFlags.None, inputTextCallbackPanic)
                    if changedPanic then
                        state.config.Heals[string.format("Panic%d", i)] = newTextPanic
                    end
                end
            
                -- Entries for Heal [1-5]
                for i = 1, 5 do
                    local labelHeal = string.format("Heal %d:", i)
                    ImGui.Text(labelHeal)
                    ImGui.SameLine()
                    local inputTextBufferHeal = state.config.Heals[string.format("Heal%d", i)]
                    local inputTextCallbackHeal = function(inputText)
                        state.config.Heals[string.format("Heal%d", i)] = inputText
                    end
                    local newTextHeal, changedHeal = ImGui.InputText(string.format("##Heal%dInput", i), inputTextBufferHeal, ImGuiInputTextFlags.None, inputTextCallbackHeal)
                    if changedHeal then
                        state.config.Heals[string.format("Heal%d", i)] = newTextHeal
                    end
                end
            
                -- Entries for Heal Clicky [1-3]
                for i = 1, 3 do
                    local labelHealClicky = string.format("Heal Clicky %d:", i)
                    ImGui.Text(labelHealClicky)
                    ImGui.SameLine()
                    local inputTextBufferHealClicky = state.config.Heals[string.format("HealClicky%d", i)]
                    local inputTextCallbackHealClicky = function(inputText)
                        state.config.Heals[string.format("HealClicky%d", i)] = inputText
                    end
                    local newTextHealClicky, changedHealClicky = ImGui.InputText(string.format("##HealClicky%dInput", i), inputTextBufferHealClicky, ImGuiInputTextFlags.None, inputTextCallbackHealClicky)
                    if changedHealClicky then
                        state.config.Heals[string.format("HealClicky%d", i)] = newTextHealClicky
                    end
                end

                ImGui.Text("HoT:")
                ImGui.SameLine()
                local inputTextBufferHoT = state.config.Heals.HoT
                local inputTextCallbackHoT = function(inputText)
                    state.config.Heals.HoT = inputText
                end
                local newTextHoT, changedHoT = ImGui.InputText("##HoTInput", inputTextBufferHoT, ImGuiInputTextFlags.None, inputTextCallbackHoT)
                if changedHoT then
                    state.config.Heals.HoT = newTextHoT
                end

                ImGui.NextColumn()

                for i = 1, 2 do
                    local labelPanicClick = string.format("Panic Click %d:", i)
                    ImGui.Text(labelPanicClick)
                    ImGui.SameLine()
                    local inputTextBufferPanicClick = state.config.Heals[string.format("PanicClick%d", i)]
                    local inputTextCallbackPanicClick = function(inputText)
                        state.config.Heals[string.format("PanicClick%d", i)] = inputText
                    end
                    local newTextPanicClick, changedPanicClick = ImGui.InputText(string.format("##PanicClickl%dInput", i), inputTextBufferPanicClick, ImGuiInputTextFlags.None, inputTextCallbackPanicClick)
                    if changedPanicClick then
                        state.config.Heals[string.format("Heal%d", i)] = newTextPanicClick
                    end
                end

                for i = 1, 2 do
                    local labelGroupHeal = string.format("Group Heal %d:", i)
                    ImGui.Text(labelGroupHeal)
                    ImGui.SameLine()
                    local inputTextBufferGroupHeal = state.config.Heals[string.format("GroupHeal%d", i)]
                    local inputTextCallbackGroupHeal = function(inputText)
                        state.config.Heals[string.format("GroupHeal%d", i)] = inputText
                    end
                    local newTextGroupHeal, changedGroupHeal = ImGui.InputText(string.format("##GroupHeall%dInput", i), inputTextBufferGroupHeal, ImGuiInputTextFlags.None, inputTextCallbackGroupHeal)
                    if changedGroupHeal then
                        state.config.Heals[string.format("Heal%d", i)] = newTextGroupHeal
                    end
                end

                for i = 1, 2 do
                    local labelGroupClick = string.format("Group Click %d:", i)
                    ImGui.Text(labelGroupClick)
                    ImGui.SameLine()
                    local inputTextBufferGroupClick = state.config.Heals[string.format("GroupClick%d", i)]
                    local inputTextCallbackGroupClick = function(inputText)
                        state.config.Heals[string.format("GroupClick%d", i)] = inputText
                    end
                    local newTextGroupClick, changedGroupClick = ImGui.InputText(string.format("##GroupClickl%dInput", i), inputTextBufferGroupClick, ImGuiInputTextFlags.None, inputTextCallbackGroupClick)
                    if changedGroupClick then
                        state.config.Heals[string.format("Heal%d", i)] = newTextGroupClick
                    end
                end

                ImGui.Text("Disease Single:")
                ImGui.SameLine()
                local inputTextBufferDisSing = state.config.Spells.DisSing
                local inputTextCallbackDisSing = function(inputText)
                    state.config.Spells.DisSing = inputText
                end
                local newTextDisSing, changedDisSing = ImGui.InputText("##DisSingInput", inputTextBufferDisSing, ImGuiInputTextFlags.None, inputTextCallbackDisSing)
                if changedDisSing then
                    state.config.Spells.DisSing = newTextDisSing
                end
                
                -- Poison Single
                ImGui.Text("Poison Single:")
                ImGui.SameLine()
                local inputTextBufferPoiSing = state.config.Spells.PoiSing
                local inputTextCallbackPoiSing = function(inputText)
                    state.config.Spells.PoiSing = inputText
                end
                local newTextPoiSing, changedPoiSing = ImGui.InputText("##PoiSingInput", inputTextBufferPoiSing, ImGuiInputTextFlags.None, inputTextCallbackPoiSing)
                if changedPoiSing then
                    state.config.Spells.PoiSing = newTextPoiSing
                end
                
                -- Corruption Single
                ImGui.Text("Corruption Single:")
                ImGui.SameLine()
                local inputTextBufferCorrSing = state.config.Spells.CorrSing
                local inputTextCallbackCorrSing = function(inputText)
                    state.config.Spells.CorrSing = inputText
                end
                local newTextCorrSing, changedCorrSing = ImGui.InputText("##CorrSingInput", inputTextBufferCorrSing, ImGuiInputTextFlags.None, inputTextCallbackCorrSing)
                if changedCorrSing then
                    state.config.Spells.CorrSing = newTextCorrSing
                end
                
                -- Curse Single
                ImGui.Text("Curse Single:")
                ImGui.SameLine()
                local inputTextBufferCurseSing = state.config.Spells.CurseSing
                local inputTextCallbackCurseSing = function(inputText)
                    state.config.Spells.CurseSing = inputText
                end
                local newTextCurseSing, changedCurseSing = ImGui.InputText("##CurseSingInput", inputTextBufferCurseSing, ImGuiInputTextFlags.None, inputTextCallbackCurseSing)
                if changedCurseSing then
                    state.config.Spells.CurseSing = newTextCurseSing
                end

                ImGui.Text("Disease Group:")
                ImGui.SameLine()
                local inputTextBufferDisGroup = state.config.Spells.DisGrp
                local inputTextCallbackDisGroup = function(inputText)
                    state.config.Spells.DisGrp = inputText
                end
                local newTextDisGroup, changedDisGroup = ImGui.InputText("##DisGroupInput", inputTextBufferDisGroup, ImGuiInputTextFlags.None, inputTextCallbackDisGroup)
                if changedDisGroup then
                    state.config.Spells.PoiGrp = newTextDisGroup
                end
                
                -- Poison Group
                ImGui.Text("Poison Group:")
                ImGui.SameLine()
                local inputTextBufferPoiGroup = state.config.Spells.PoiGrp
                local inputTextCallbackPoiGroup = function(inputText)
                    state.config.Spells.PoiGrp = inputText
                end
                local newTextPoiGroup, changedPoiGroup = ImGui.InputText("##PoiGroupInput", inputTextBufferPoiGroup, ImGuiInputTextFlags.None, inputTextCallbackPoiGroup)
                if changedPoiGroup then
                    state.config.Spells.PoiGrp = newTextPoiGroup
                end
                
                -- Corruption Group
                ImGui.Text("Corruption Group:")
                ImGui.SameLine()
                local inputTextBufferCorrGroup = state.config.Spells.CorrGrp
                local inputTextCallbackCorrGroup = function(inputText)
                    state.config.Spells.CorrGrp = inputText
                end
                local newTextCorrGroup, changedCorrGroup = ImGui.InputText("##CorrGroupInput", inputTextBufferCorrGroup, ImGuiInputTextFlags.None, inputTextCallbackCorrGroup)
                if changedCorrGroup then
                    state.config.Spells.CorrGrp = newTextCorrGroup
                end
                
                -- Curse Group
                ImGui.Text("Curse Group:")
                ImGui.SameLine()
                local inputTextBufferCurseGroup = state.config.Spells.CurseGrp
                local inputTextCallbackCurseGroup = function(inputText)
                    state.config.Spells.CurseGrp = inputText
                end
                local newTextCurseGroup, changedCurseGroup = ImGui.InputText("##CurseGroupInput", inputTextBufferCurseGroup, ImGuiInputTextFlags.None, inputTextCallbackCurseGroup)
                if changedCurseGroup then
                    state.config.Spells.CurseGrp = newTextCurseGroup
                end

                
                ImGui.Columns(1)  -- Reset back to a single column layout
                ImGui.EndTabItem()
            else
            anim:SetTextureCell(99)
            ImGui.SameLine()
            ImGui.DrawTextureAnimation(anim,23,23)
            end
            if ImGui.CollapsingHeader('DPS', ImGuiTreeNodeFlags.None) then
                anim:SetTextureCell(56)
                ImGui.SameLine()
                ImGui.DrawTextureAnimation(anim, 23, 23)
                ImGui.Columns(2)
                ImGui.SetColumnOffset(1, spelltabOffset)
                ImGui.SetColumnWidth(1, columnWidth)
                ImGui.SetColumnWidth(2, columnWidth)

                ImGui.Text("Gift:")
                ImGui.SameLine()
                local inputTextBufferGift = state.config.Spells.Gift
                local inputTextCallbackGift = function(inputText)
                    state.config.Spells.Gift = inputText
                end
                local newTextGift, changedGift = ImGui.InputText("##GiftInput", inputTextBufferGift, ImGuiInputTextFlags.None, inputTextCallbackGift)
                if changedGift then
                    state.config.Spells.Gift = newTextGift
                end

                for i = 1, 3 do
                    local labelDD = string.format("Nuke %d:", i)
                    ImGui.Text(labelDD)
                    ImGui.SameLine()
                    local inputTextBufferDD = state.config.Spells[string.format("DD%d", i)]
                    local inputTextCallbackDD = function(inputText)
                        state.config.Spells[string.format("DD%d", i)] = inputText
                    end
                    local newTextDD, changedDD = ImGui.InputText(string.format("##DDl%dInput", i), inputTextBufferDD, ImGuiInputTextFlags.None, inputTextCallbackDD)
                    if changedDD then
                        state.config.Spells[string.format("Heal%d", i)] = newTextDD
                    end
                end

                ImGui.Text("DPS Click 1:")
                ImGui.SameLine()
                local inputTextBufferDPSClicky1 = state.config.Spells.DPSClicky1
                local inputTextCallbackDPSClicky1 = function(inputText)
                    state.config.Spells.DPSClicky1 = inputText
                end
                local newTextDPSClicky1, changedDPSClicky1 = ImGui.InputText("##DPSClicky1Input", inputTextBufferDPSClicky1, ImGuiInputTextFlags.None, inputTextCallbackDPSClicky1)
                if changedDPSClicky1 then
                    state.config.Spells.DPSClicky1 = newTextDPSClicky1
                end

                ImGui.NextColumn()

                for i = 1, 4 do
                    local labelDoT = string.format("DoT %d:", i)
                    ImGui.Text(labelDoT)
                    ImGui.SameLine()
                    local inputTextBufferDoT = state.config.Spells[string.format("DoT%d", i)]
                    local inputTextCallbackDoT = function(inputText)
                        state.config.Spells[string.format("DoT%d", i)] = inputText
                    end
                    local newTextDoT, changeDoTD = ImGui.InputText(string.format("##DoTl%dInput", i), inputTextBufferDoT, ImGuiInputTextFlags.None, inputTextCallbackDoT)
                    if changeDoTD then
                        state.config.Spells[string.format("Heal%d", i)] = newTextDoT
                    end
                end

                ImGui.Text("DPS Click 2:")
                ImGui.SameLine()
                local inputTextBufferDPSClicky2 = state.config.Spells.DPSClicky2
                local inputTextCallbackDPSClicky2 = function(inputText)
                    state.config.Spells.DPSClicky2 = inputText
                end
                local newTextDPSClicky2, changedDPSClicky2 = ImGui.InputText("##DPSClicky2Input", inputTextBufferDPSClicky2, ImGuiInputTextFlags.None, inputTextCallbackDPSClicky2)
                if changedDPSClicky2 then
                    state.config.Spells.DPSClicky2 = newTextDPSClicky2
                end

                ImGui.Columns(1)  -- Reset back to a single column layout
                ImGui.EndTabItem()
            else
            anim:SetTextureCell(56)
            ImGui.SameLine()
            ImGui.DrawTextureAnimation(anim,23,23)
            end
            if ImGui.CollapsingHeader('Pet', ImGuiTreeNodeFlags.None) then
                anim:SetTextureCell(38)
                ImGui.SameLine()
                ImGui.DrawTextureAnimation(anim, 23, 23)
                ImGui.Columns(2)
                ImGui.SetColumnOffset(1, spelltabOffset)
                ImGui.SetColumnWidth(1, columnWidth)
                ImGui.SetColumnWidth(2, columnWidth)

                ImGui.Text("Summon Pet:")
                ImGui.SameLine()
                local inputTextBufferPetSum = state.config.Spells.PetSum
                local inputTextCallbackPetSum = function(inputText)
                    state.config.Spells.PetSum = inputText
                end
                local newTextPetSum, changedPetSum = ImGui.InputText("##PetSumInput", inputTextBufferPetSum, ImGuiInputTextFlags.None, inputTextCallbackPetSum)
                if changedPetSum then
                    state.config.Spells.PetSum = newTextPetSum
                end

                ImGui.Text("Shrink Pet:")
                ImGui.SameLine()
                local inputTextBufferPetShrink = state.config.Spells.PetShrink
                local inputTextCallbackPetShrink = function(inputText)
                    state.config.Spells.PetShrink = inputText
                end
                local newTextPetShrink, changedPetShrink = ImGui.InputText("##PetShrinkInput", inputTextBufferPetShrink, ImGuiInputTextFlags.None, inputTextCallbackPetShrink)
                if changedPetShrink then
                    state.config.Spells.PetShrink = newTextPetShrink
                end

                ImGui.NextColumn()

                ImGui.Text("Pet Buff 1:")
                ImGui.SameLine()
                local inputTextBufferPetBuff1 = state.config.Spells.PetBuff1
                local inputTextCallbackPetBuff1 = function(inputText)
                    state.config.Spells.PetBuff1 = inputText
                end
                local newTextPetBuff1, changedPetBuff1 = ImGui.InputText("##PetBuff1Input", inputTextBufferPetBuff1, ImGuiInputTextFlags.None, inputTextCallbackPetBuff1)
                if changedPetBuff1 then
                    state.config.Spells.PetBuff1 = newTextPetBuff1
                end

                ImGui.Text("Pet Buff 2:")
                ImGui.SameLine()
                local inputTextBufferPetBuff2 = state.config.Spells.PetBuff2
                local inputTextCallbackPetBuff2 = function(inputText)
                    state.config.Spells.PetBuff2 = inputText
                end
                local newTextPetBuff2, changedPetBuff2 = ImGui.InputText("##PetBuff2Input", inputTextBufferPetBuff2, ImGuiInputTextFlags.None, inputTextCallbackPetBuff2)
                if changedPetBuff2 then
                    state.config.Spells.PetBuff2 = newTextPetBuff2
                end

                ImGui.Columns(1)  -- Reset back to a single column layout
                ImGui.EndTabItem()
            else
            anim:SetTextureCell(38)
            ImGui.SameLine()
            ImGui.DrawTextureAnimation(anim,23,23)
            end

            if ImGui.CollapsingHeader('Debuffs', ImGuiTreeNodeFlags.None) then
                anim:SetTextureCell(17)
                ImGui.SameLine()
                ImGui.DrawTextureAnimation(anim, 23, 23)
                ImGui.Columns(2)
                ImGui.SetColumnOffset(1, spelltabOffset)
                ImGui.SetColumnWidth(1, columnWidth)
                ImGui.SetColumnWidth(2, columnWidth)

                ImGui.Text("AESlow:")
                ImGui.SameLine()
                local inputTextBufferAESlow = state.config.Combat.AESlow
                local inputTextCallbackAESlow = function(inputText)
                    state.config.Combat.AESlow = inputText
                end
                local newTextAESlow, changedAESlow = ImGui.InputText("##AESlowInput", inputTextBufferAESlow, ImGuiInputTextFlags.None, inputTextCallbackAESlow)
                if changedAESlow then
                    state.config.Combat.AESlow = newTextAESlow
                end

                ImGui.Text("Cripple:")
                ImGui.SameLine()
                local inputTextBufferCripple = state.config.Combat.Cripple
                local inputTextCallbackCripple = function(inputText)
                    state.config.Combat.Cripple = inputText
                end
                local newTextCripple, changedCripple = ImGui.InputText("##CrippleInput", inputTextBufferCripple, ImGuiInputTextFlags.None, inputTextCallbackCripple)
                if changedCripple then
                    state.config.Combat.Cripple = newTextCripple
                end

                ImGui.Text("Feralize:")
                ImGui.SameLine()
                local inputTextBufferFeralize = state.config.Combat.Feralize
                local inputTextCallbackFeralize = function(inputText)
                    state.config.Combat.Feralize = inputText
                end
                local newTextFeralize, changedFeralize = ImGui.InputText("##FeralizeInput", inputTextBufferFeralize, ImGuiInputTextFlags.None, inputTextCallbackFeralize)
                if changedFeralize then
                    state.config.Combat.Feralize = newTextFeralize
                end

                ImGui.Text("AEMalo:")
                ImGui.SameLine()
                local inputTextBufferAEMalo = state.config.Combat.AEMalo
                local inputTextCallbackAEMalo = function(inputText)
                    state.config.Combat.AEMalo = inputText
                end
                local newTextAEMalo, changedAEMalo = ImGui.InputText("##AEMaloInput", inputTextBufferAEMalo, ImGuiInputTextFlags.None, inputTextCallbackAEMalo)
                if changedAEMalo then
                    state.config.Combat.AEMalo = newTextAEMalo
                end

                ImGui.NextColumn()

                ImGui.Text("Malo:")
                ImGui.SameLine()
                local inputTextBufferMalo = state.config.Combat.Malo
                local inputTextCallbackMalo = function(inputText)
                    state.config.Combat.Malo = inputText
                end
                local newTextMalo, changedMalo = ImGui.InputText("##MaloInput", inputTextBufferMalo, ImGuiInputTextFlags.None, inputTextCallbackMalo)
                if changedMalo then
                    state.config.Combat.Malo = newTextMalo
                end

                ImGui.Text("Slow:")
                ImGui.SameLine()
                local inputTextBufferSlow = state.config.Combat.Slow
                local inputTextCallbackSlow = function(inputText)
                    state.config.Combat.Slow = inputText
                end
                local newTextSlow, changedSlow = ImGui.InputText("##SlowInput", inputTextBufferSlow, ImGuiInputTextFlags.None, inputTextCallbackSlow)
                if changedSlow then
                    state.config.Combat.Slow = newTextSlow
                end

                ImGui.Text("UnresMalo:")
                ImGui.SameLine()
                local inputTextBufferUnresMalo = state.config.Combat.UnresMalo
                local inputTextCallbackUnresMalo = function(inputText)
                    state.config.Combat.UnresMalo = inputText
                end
                local newTextUnresMalo, changedUnresMalo = ImGui.InputText("##UnresMaloInput", inputTextBufferUnresMalo, ImGuiInputTextFlags.None, inputTextCallbackUnresMalo)
                if changedUnresMalo then
                    state.config.Combat.UnresMalo = newTextUnresMalo
                end
                ImGui.EndTabItem()

            else
                anim:SetTextureCell(17)
                ImGui.SameLine()
                ImGui.DrawTextureAnimation(anim,23,23)
            end

            ImGui.Columns(1)

            local windowHeight = ImGui.GetWindowHeight()
            local buttonPosY = windowHeight - BUTTON_SIZE - 10  -- Adjust the spacing as needed
        
            ImGui.SetCursorPosY(buttonPosY)

            -- Create the first button
            local buttonLabel1 = "Save\nConfig"
            if ImGui.Button(buttonLabel1, BUTTON_SIZE, BUTTON_SIZE) then
                conf.saveConfig(conf.path,state.config,conf.iniorder)
            end
            
            ImGui.SameLine()
            
            local buttonLabel2 = "Load\nConfig"
            if ImGui.Button(buttonLabel2, BUTTON_SIZE, BUTTON_SIZE) then
                state.config = conf.initConfig(conf.path)
            end

            ImGui.SameLine()

            if ImGui.Button(string.format('Reload\n     ' .. icons.FA_REFRESH), BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/multiline ; /lua stop shm420 ; /timed 5 /lua run shm420')
            end

            ImGui.EndTabItem()
            
        end

        if ImGui.BeginTabItem(icons.MD_SETTINGS..'  General') then
            -- Your General tab content goes here
            local totalWidth, _ = ImGui.GetContentRegionAvail()
            local columnWidth = totalWidth / 2

            ImGui.Columns(2)
            ImGui.SetColumnOffset(1, gentabOffset)
            ImGui.SetColumnWidth(1,columnWidth)
            ImGui.SetColumnWidth(2,columnWidth)
            -- ...
            if ImGui.Checkbox('Return To Camp', checkboxes.ReturnToCamp) then
                if tostring(state.config.General.ReturnToCamp) ~= 'On' then 
                    local chase = require('routines.campchase')
                    print('\ay[\amSHM\ag420\ay]\am:\at Camphere: On')
                    state.config.General.ReturnToCamp = 'On'
                    state.config.General.ChaseAssist = 'Off'
                    state.campxloc, state.campyloc, state.campzloc = chase.setcamp()
                end
            else
                if tostring(state.config.General.ReturnToCamp) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Camphere: Off')
                    state.config.General.ReturnToCamp = 'Off'
                end
            end
            if ImGui.Checkbox('Chase Assist', checkboxes.ChaseAssist) then
                if tostring(state.config.General.ChaseAssist) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Chase: On')
                    state.config.General.ReturnToCamp = 'Off'
                    state.config.General.ChaseAssist = 'On'
                end
            else
                if tostring(state.config.General.ChaseAssist) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Chase: Off')
                    state.config.General.ChaseAssist = 'Off'
                end
            end
            if ImGui.Checkbox('Do Buffs', checkboxes.Buffs) then
                if tostring(state.config.General.Buffs) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Buffs: On')
                    state.config.General.Buffs = 'On'
                end
            else
                if tostring(state.config.General.Buffs) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Buffs: Off')
                    state.config.General.Buffs = 'Off'
                end
            end
            if ImGui.Checkbox('Do Cures', checkboxes.Cures) then
                if tostring(state.config.Shaman.Cures) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cures: On')
                    state.config.Shaman.Cures = 'On'
                end
            else
                if tostring(state.config.Shaman.Cures) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cures: Off')
                    state.config.Shaman.Cures = 'Off'
                end
            end
            if ImGui.Checkbox('Do Medding', checkboxes.Med) then
                if tostring(state.config.General.Med) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Med: On')
                    state.config.General.Med = 'On'
                end
            else
                if tostring(state.config.General.Med) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Med: Off')
                    state.config.General.Med = 'Off'
                end
            end
            if ImGui.Checkbox('Med in Combat', checkboxes.MedCombat) then
                if tostring(state.config.General.MedCombat) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at MedCombat: On')
                    state.config.General.MedCombat = 'On'
                end
            else
                if tostring(state.config.General.MedCombat) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at MedCombat: Off')
                    state.config.General.MedCombat = 'Off'
                end
            end
            if ImGui.Checkbox('Use DanNet', checkboxes.UseDNet) then
                if tostring(state.config.General.UseDNet) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at UseDNet: On')
                    state.config.General.UseDNet = 'On'
                end
            else
                if tostring(state.config.General.UseDNet) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at UseDNet: Off')
                    state.config.General.UseDNet = 'Off'
                end
            end
            if ImGui.Checkbox('Do XTarget Healing', checkboxes.XTarHeal) then
                if tostring(state.config.General.XTarHeal) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at XTarHeal: On')
                    state.config.General.XTarHeal = 'On'
                end
            else
                if tostring(state.config.General.XTarHeal) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at XTarHeal: Off')
                    state.config.General.XTarHeal = 'Off'
                end
            end

            if ImGui.Checkbox('Epic On Cooldown', checkboxes.EpicOnCD) then
                if tostring(state.config.Shaman.EpicOnCD) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Epic on CD: On')
                    state.config.Shaman.EpicOnCD = 'On'
                end
            else
                if tostring(state.config.Shaman.EpicOnCD) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Epic on CD: Off')
                    state.config.Shaman.EpicOnCD = 'Off'
                end
            end

            if ImGui.Checkbox('Epic with Bard or SK Epic', checkboxes.EpicWithBardSK) then
                if tostring(state.config.Shaman.EpicWithBardSK) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Epic with Bard/SK : On')
                    state.config.Shaman.EpicWithBardSK = 'On'
                end
            else
                if tostring(state.config.Shaman.EpicWithBardSK) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Epic with Bard/SK : Off')
                    state.config.Shaman.EpicWithBardSK = 'Off'
                end
            end

            if ImGui.Checkbox('Remem Spells', checkboxes.MiscGemRemem) then
                if tostring(state.config.Spells.MiscGemRemem) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Remem Spells : On')
                    state.config.Spells.MiscGemRemem = 'On'
                end
            else
                if tostring(state.config.Spells.MiscGemRemem) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Remem Spells : Off')
                    state.config.Spells.MiscGemRemem = 'Off'
                end
            end

            if ImGui.Checkbox('Powersource Enabled', checkboxes.PsEnabled) then
                if tostring(state.config.Powersource.PsEnabled) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Powersource Enabled: On')
                    state.config.Powersource.PsEnabled = 'On'
                end
            else
                if tostring(state.config.Powersource.PsEnabled) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Powersource Enabled: Off')
                    state.config.Powersource.PsEnabled = 'Off'
                end
            end

            ImGui.NextColumn()

            ImGui.SetColumnOffset(2, 1000)

            ImGui.Text("Chase Distance:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferChaseDistance = tostring(state.config.General.ChaseDistance)
            local inputTextBufferTempChaseDistance = inputTextBufferChaseDistance
            local inputTextCallbackChaseDistance = function(inputText)
                inputTextBufferTempChaseDistance = inputText
            end
            local newChaseDistance, changedChaseDistance = ImGui.InputText("##ChaseDistanceInput", inputTextBufferTempChaseDistance, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackChaseDistance)
            if changedChaseDistance then
                inputTextBufferTempChaseDistance = newChaseDistance
            end
            if ImGui.IsItemDeactivated() then
                local newChaseDistanceVal = tonumber(inputTextBufferTempChaseDistance)
                if newChaseDistanceVal then
                    state.config.General.ChaseDistance = newChaseDistanceVal
                end
            end
            

            ImGui.Text("Med Start:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferMedStart = tostring(state.config.General.MedStart)
            local inputTextBufferTempMedStart = inputTextBufferMedStart
            local inputTextCallbackMedStart = function(inputText)
                inputTextBufferTempMedStart = inputText
            end
            local newMedStart, changedMedStart = ImGui.InputText("##MedStartInput", inputTextBufferTempMedStart, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackMedStart)
            if changedMedStart then
                inputTextBufferTempMedStart = newMedStart
            end
            if ImGui.IsItemDeactivated() then
                local newMedStartVal = tonumber(inputTextBufferTempMedStart)
                if newMedStartVal then
                    state.config.General.MedStart = newMedStartVal
                end
            end
            
            
            -- Med Stop
            ImGui.Text("Med Stop:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferMedStop = tostring(state.config.General.MedStop)
            local inputTextBufferTempMedStop = inputTextBufferMedStop
            local inputTextCallbackMedStop = function(inputText)
                inputTextBufferTempMedStop = inputText
            end
            local newMedStop, changedMedStop = ImGui.InputText("##MedStopInput", inputTextBufferTempMedStop, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackMedStop)
            if changedMedStop then
                inputTextBufferTempMedStop = newMedStop
            end
            if ImGui.IsItemDeactivated() then
                local newMedStopVal = tonumber(inputTextBufferTempMedStop)
                if newMedStopVal then
                    state.config.General.MedStop = newMedStopVal
                end
            end
            
            
            -- XTarget Heal List
            ImGui.Text("XTarget Heal List:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferXTarHealList = state.config.General.XTarHealList
            local inputTextBufferTempXTarHealList = inputTextBufferXTarHealList
            local inputTextCallbackXTarHealList = function(inputText)
                inputTextBufferTempXTarHealList = inputText
            end
            local newXTarHealList, changedXTarHealList = ImGui.InputText("##XTarHealListInput", inputTextBufferTempXTarHealList, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackXTarHealList)
            if changedXTarHealList then
                inputTextBufferTempXTarHealList = newXTarHealList
            end
            if ImGui.IsItemDeactivated() then
                local newVal = tonumber(inputTextBufferTempXTarHealList)
                if newVal then
                    state.config.General.XTarHealList = newVal
                    state.debugxtars = true
                end
            end
            
            
            -- Misc Gem
            ImGui.Text("Misc Gem:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferMiscGem = state.config.Spells.MiscGem
            local inputTextBufferTempMiscGem = inputTextBufferMiscGem
            local inputTextCallbackMiscGem = function(inputText)
                inputTextBufferTempMiscGem = inputText
            end
            local newMiscGem, changedMiscGem = ImGui.InputText("##MiscGemInput", inputTextBufferTempMiscGem, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackMiscGem)
            if changedMiscGem then
                inputTextBufferTempMiscGem = newMiscGem
            end
            if ImGui.IsItemDeactivated() then
                local newVal = tonumber(inputTextBufferTempMiscGem)
                if newVal then
                    state.config.Spells.MiscGem = newVal
                end
            end

            ImGui.Text("Good Powersource:")
            ImGui.SameLine()
            local goodPsBuffer = state.config.Powersource.GoodPS or ""
            local newGoodPs, changedGoodPs = ImGui.InputText("##GoodPsInput", goodPsBuffer, 256)
            if changedGoodPs then
                state.config.Powersource.GoodPS = newGoodPs
            end
        
            ImGui.Text("Drained Powersource:")
            ImGui.SameLine()
            local drainedPsBuffer = state.config.Powersource.DrainedPS or ""
            local newDrainedPs, changedDrainedPs = ImGui.InputText("##DrainedPsInput", drainedPsBuffer, 256)
            if changedDrainedPs then
                state.config.Powersource.DrainedPS = newDrainedPs
            end
        
            ImGui.Text("Good Powersource Aggro Min:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local goodPsAggroMinBuffer = tostring(state.config.Powersource.GoodPSAggroMin)
            local goodPsAggroMinTempBuffer = goodPsAggroMinBuffer
            local goodPsAggroMinCallback = function(inputText)
                goodPsAggroMinTempBuffer = inputText
            end
            local newGoodPsAggroMin, changedGoodPsAggroMin = ImGui.InputText("##GoodPsAggroMinInput", goodPsAggroMinTempBuffer, ImGuiInputTextFlags.CharsDecimal, goodPsAggroMinCallback)
            if changedGoodPsAggroMin then
                goodPsAggroMinTempBuffer = newGoodPsAggroMin
            end
            if ImGui.IsItemDeactivated() then
                local newGoodPsAggroMinVal = tonumber(goodPsAggroMinTempBuffer)
                if newGoodPsAggroMinVal then
                    state.config.Powersource.GoodPSAggroMin = newGoodPsAggroMinVal
                end
            end
            
            
            ImGui.Columns(1)

            local windowHeight = ImGui.GetWindowHeight()
            local buttonPosY = windowHeight - BUTTON_SIZE - 10  -- Adjust the spacing as needed
        
            ImGui.SetCursorPosY(buttonPosY)

            -- Create the first button
            local buttonLabel1 = "Save\nConfig"
            if ImGui.Button(buttonLabel1, BUTTON_SIZE, BUTTON_SIZE) then
                conf.saveConfig(conf.path,state.config,conf.iniorder)
            end
            
            ImGui.SameLine()
            
            local buttonLabel2 = "Load\nConfig"
            if ImGui.Button(buttonLabel2, BUTTON_SIZE, BUTTON_SIZE) then
                state.config = conf.initConfig(conf.path)
            end

            ImGui.SameLine()

            if ImGui.Button(string.format('Reload\n     ' .. icons.FA_REFRESH), BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/multiline ; /lua stop shm420 ; /timed 5 /lua run shm420')
            end
            ImGui.EndTabItem()

            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 175) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 100) 

            anim:SetTextureCell(124)
            ImGui.DrawTextureAnimation(anim,150,150)


        end

        if ImGui.BeginTabItem(icons.FA_SHIELD..'  Buffs') then
            local totalWidth, _ = ImGui.GetContentRegionAvail()
            local columnWidth = totalWidth / 2

            ImGui.Columns(2)
            ImGui.SetColumnOffset(1, gentabOffset)
            ImGui.SetColumnWidth(1,columnWidth)
            ImGui.SetColumnWidth(2,columnWidth)

            if ImGui.Checkbox('Cast Focus', checkboxes.CastFocus) then
                if tostring(state.config.Shaman.Focus) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Focus: On')
                    state.config.Shaman.Focus = 'On'
                end
            else
                if tostring(state.config.Shaman.Focus) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Focus: Off')
                    state.config.Shaman.Focus = 'Off'
                end
            end
            
            -- Cast Champion
            if ImGui.Checkbox('Cast Champion', checkboxes.CastChampion) then
                if tostring(state.config.Shaman.Champion) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Champion: On')
                    state.config.Shaman.Champion = 'On'
                end
            else
                if tostring(state.config.Shaman.Champion) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Champion: Off')
                    state.config.Shaman.Champion = 'Off'
                end
            end
            
            -- Cast Panther
            if ImGui.Checkbox('Cast Panther', checkboxes.CastPanther) then
                if tostring(state.config.Shaman.Panther) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Panther: On')
                    state.config.Shaman.Panther = 'On'
                end
            else
                if tostring(state.config.Shaman.Panther) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Panther: Off')
                    state.config.Shaman.Panther = 'Off'
                end
            end
            
            -- Cast Regen
            if ImGui.Checkbox('Cast Regen', checkboxes.CastRegen) then
                if tostring(state.config.Shaman.Regen) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Regen: On')
                    state.config.Shaman.Regen = 'On'
                end
            else
                if tostring(state.config.Shaman.Regen) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Regen: Off')
                    state.config.Shaman.Regen = 'Off'
                end
            end
            
            -- Cast Self DI
            if ImGui.Checkbox('Cast Self DI', checkboxes.CastSelfDI) then
                if tostring(state.config.Shaman.SelfDI) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Self DI: On')
                    state.config.Shaman.SelfDI = 'On'
                end
            else
                if tostring(state.config.Shaman.SelfDI) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Self DI: Off')
                    state.config.Shaman.SelfDI = 'Off'
                end
            end
            
            -- Cast Sloth on MT
            if ImGui.Checkbox('Cast Sloth on MT', checkboxes.CastSlothTank) then
                if tostring(state.config.Shaman.SlothTank) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Sloth on MT: On')
                    state.config.Shaman.SlothTank = 'On'
                end
            else
                if tostring(state.config.Shaman.SlothTank) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Sloth on MT: Off')
                    state.config.Shaman.SlothTank = 'Off'
                end
            end
            
            -- Cast Ward
            if ImGui.Checkbox('Cast Ward', checkboxes.CastWard) then
                if tostring(state.config.Shaman.Ward) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Ward: On')
                    state.config.Shaman.Ward = 'On'
                end
            else
                if tostring(state.config.Shaman.Ward) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Ward: Off')
                    state.config.Shaman.Ward = 'Off'
                end
            end
            
            -- Cast Wild Growth on MT
            if ImGui.Checkbox('Cast Wild Growth on MT', checkboxes.CastWildGrowthTank) then
                if tostring(state.config.Shaman.WildGrowthTank) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Wild Growth on MT: On')
                    state.config.Shaman.WildGrowthTank = 'On'
                end
            else
                if tostring(state.config.Shaman.WildGrowthTank) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast Wild Growth on MT: Off')
                    state.config.Shaman.WildGrowthTank = 'Off'
                end
            end
            
            -- Cast SoW
            if ImGui.Checkbox('Cast SoW', checkboxes.CastSoW) then
                if tostring(state.config.Shaman.SoW) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast SoW: On')
                    state.config.Shaman.SoW = 'On'
                end
            else
                if tostring(state.config.Shaman.SoW) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Cast SoW: Off')
                    state.config.Shaman.SoW = 'Off'
                end
            end

            if ImGui.Checkbox('Use Aura', checkboxes.useAura) then
                if tostring(state.config.Shaman.Aura) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Use Aura: On')
                    state.config.Shaman.Aura = 'On'
                end
            else
                if tostring(state.config.Shaman.Aura) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Use Aura: Off')
                    state.config.Shaman.Aura = 'Off'
                end
            end

            ImGui.NextColumn()
            ImGui.SetColumnOffset(2, 1000)

            ImGui.Text("AA Canni At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferAACanniAt = tostring(state.config.Shaman.AACanniAt)
            local inputTextBufferTempAACanniAt = inputTextBufferAACanniAt
            local inputTextCallbackAACanniAt = function(inputText)
                inputTextBufferTempAACanniAt = inputText
            end
            local newTextAACanniAt, changedAACanniAt = ImGui.InputText("##AACanniAtInput", inputTextBufferTempAACanniAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackAACanniAt)
            if changedAACanniAt then
                inputTextBufferTempAACanniAt = newTextAACanniAt
            end
            if ImGui.IsItemDeactivated() then
                local newAACanniAt = tonumber(inputTextBufferTempAACanniAt)
                if newAACanniAt then
                    state.config.Shaman.AACanniAt = newAACanniAt
                end
            end
            
            
            -- Canni At
            ImGui.Text("Canni At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferCanniAt = tostring(state.config.Shaman.CanniAt)
            local inputTextBufferTempCanniAt = inputTextBufferCanniAt
            local inputTextCallbackCanniAt = function(inputText)
                inputTextBufferTempCanniAt = inputText
            end
            local newTextCanniAt, changedCanniAt = ImGui.InputText("##CanniAtInput", inputTextBufferTempCanniAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackCanniAt)
            if changedCanniAt then
                inputTextBufferTempCanniAt = newTextCanniAt
            end
            if ImGui.IsItemDeactivated() then
                local newCanniAt = tonumber(inputTextBufferTempCanniAt)
                if newCanniAt then
                    state.config.Shaman.CanniAt = newCanniAt
                end
            end

            ImGui.Text("KeywordAll:")
            ImGui.SameLine()
            local inputTextBufferKeywordAll = state.config.Buffs.KeywordAll
            local inputTextCallbackKeywordAll = function(inputText)
                state.config.Buffs.KeywordAll = inputText
            end
            local newTextKeywordAll, changedKeywordAll = ImGui.InputText("##KeywordAllInput", inputTextBufferKeywordAll, ImGuiInputTextFlags.None, inputTextCallbackKeywordAll)
            if changedKeywordAll then
                state.config.Buffs.KeywordAll = newTextKeywordAll
            end
        
            ImGui.Text("KeywordCustom:")
            ImGui.SameLine()
            local inputTextBufferKeywordCustom = state.config.Buffs.KeywordCustom
            local inputTextCallbackKeywordCustom = function(inputText)
                state.config.Buffs.KeywordCustom = inputText
            end
            local newTextKeywordCustom, changedKeywordCustom = ImGui.InputText("##KeywordCustomInput", inputTextBufferKeywordCustom, ImGuiInputTextFlags.None, inputTextCallbackKeywordCustom)
            if changedKeywordCustom then
                state.config.Buffs.KeywordCustom = newTextKeywordCustom
            end

            if ImGui.TreeNode("Keyword Custom") then
                local selectionLabels = {"Focus", "SoW", "Regen"}
            
                for i, label in ipairs(selectionLabels) do
                    local _, clicked = ImGui.Selectable(label, state.config.KeywordCustom[label] == 'On')
            
                    if clicked then
                        state.config.KeywordCustom[label] = state.config.KeywordCustom[label] == 'On' and 'Off' or 'On'
                    end
                end
            
                ImGui.TreePop()
            end
            

            ImGui.Columns(1)

            local windowHeight = ImGui.GetWindowHeight()
            local buttonPosY = windowHeight - BUTTON_SIZE - 10  -- Adjust the spacing as needed
        
            ImGui.SetCursorPosY(buttonPosY)

            -- Create the first button
            local buttonLabel1 = "Save\nConfig"
            if ImGui.Button(buttonLabel1, BUTTON_SIZE, BUTTON_SIZE) then
                conf.saveConfig(conf.path,state.config,conf.iniorder)
            end
            
            ImGui.SameLine()
            
            local buttonLabel2 = "Load\nConfig"
            if ImGui.Button(buttonLabel2, BUTTON_SIZE, BUTTON_SIZE) then
                state.config = conf.initConfig(conf.path)
            end

            ImGui.SameLine()

            if ImGui.Button(string.format('Reload\n     ' .. icons.FA_REFRESH), BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/multiline ; /lua stop shm420 ; /timed 5 /lua run shm420')
            end
            ImGui.EndTabItem()
            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 175) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 100) 

            anim:SetTextureCell(7)
            ImGui.DrawTextureAnimation(anim,150,150)
        end

        -- Fourth tab: Heals
        if ImGui.BeginTabItem(icons.FA_HEART..'  Heals') then
            local totalWidth, _ = ImGui.GetContentRegionAvail()
            local columnWidth = totalWidth / 2

            ImGui.Columns(2)
            ImGui.SetColumnOffset(1, gentabOffset)
            ImGui.SetColumnWidth(1,columnWidth)
            ImGui.SetColumnWidth(2,columnWidth)

            if ImGui.Checkbox('Interrupt To Heal', checkboxes.InterruptToHeal) then
                if tostring(state.config.Heals.InterruptToHeal) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Interrupt To Heal: On')
                    state.config.Heals.InterruptToHeal = 'On'
                end
            else
                if tostring(state.config.Heals.InterruptToHeal) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Interrupt To Heal: Off')
                    state.config.Heals.InterruptToHeal = 'Off'
                end
            end
            
            if ImGui.Checkbox('Use Call of the Wild', checkboxes.CallOfWild) then
                if tostring(state.config.Shaman.CallOfWild) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Call Of Wild: On')
                    state.config.Shaman.CallOfWild = 'On'
                end
            else
                if tostring(state.config.Shaman.CallOfWild) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Call Of Wild: Off')
                    state.config.Shaman.CallOfWild = 'Off'
                end
            end
            
            if ImGui.Checkbox('Heal Group Pets', checkboxes.HealGroupPets) then
                if tostring(state.config.Shaman.HealGroupPets) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Heal Group Pets: On')
                    state.config.Shaman.HealGroupPets = 'On'
                end
            else
                if tostring(state.config.Shaman.HealGroupPets) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Heal Group Pets: Off')
                    state.config.Shaman.HealGroupPets = 'Off'
                end
            end

            if ImGui.Checkbox('HoT Tank', checkboxes.HoTTank) then
                if tostring(state.config.Shaman.HoTTank) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at HoT Tank: On')
                    state.config.Shaman.HoTTank = 'On'
                end
            else
                if tostring(state.config.Shaman.HoTTank) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at HoT Tank: Off')
                    state.config.Shaman.HoTTank = 'Off'
                end
            end

            if ImGui.Checkbox('Rez Out of Combat', checkboxes.RezOOC) then
                if tostring(state.config.Shaman.RezOOC) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Rez OOC: On')
                    state.config.Shaman.RezOOC = 'On'
                end
            else
                if tostring(state.config.Shaman.RezOOC) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Rez OOC: Off')
                    state.config.Shaman.RezOOC = 'Off'
                end
            end

            if ImGui.Checkbox('Rez Stick', checkboxes.RezStick) then
                if tostring(state.config.Shaman.RezStick) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Rez Stick: On')
                    state.config.Shaman.RezStick = 'On'
                end
            else
                if tostring(state.config.Shaman.RezStick) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Rez Stick: Off')
                    state.config.Shaman.RezStick = 'Off'
                end
            end

            if ImGui.Checkbox('Radiant Cure', checkboxes.Radiant) then
                if tostring(state.config.Spells.Radiant) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Radiant: On')
                    state.config.Spells.Radiant = 'On'
                end
            else
                if tostring(state.config.Spells.Radiant) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Radiant: Off')
                    state.config.Spells.Radiant = 'Off'
                end
            end
            

            ImGui.NextColumn()

            ImGui.Text("Heal Panic At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBuffer = tostring(state.config.Heals.HealPanicAt)
            local inputTextBufferTemp = inputTextBuffer  -- Temporary buffer
            local inputTextCallback = function(inputText)
                inputTextBufferTemp = inputText  -- Update the temporary buffer
            end
            local newText, changed = ImGui.InputText("##HealPanicAtInput", inputTextBufferTemp, ImGuiInputTextFlags.CharsDecimal, inputTextCallback)
            if changed then
                inputTextBufferTemp = newText
            end
            if ImGui.IsItemDeactivated() then
                local newHealPanicAt = tonumber(inputTextBufferTemp)
                if newHealPanicAt then
                    state.config.Heals.HealPanicAt = newHealPanicAt
                end
            end
            
            
            ImGui.Text("Heal Regular At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferRegularAt = tostring(state.config.Heals.HealRegularAt)
            local inputTextBufferTempRegularAt = inputTextBufferRegularAt
            local inputTextCallbackRegularAt = function(inputText)
                inputTextBufferTempRegularAt = inputText
            end
            local newTextRegularAt, changedRegularAt = ImGui.InputText("##HealRegularAtInput", inputTextBufferTempRegularAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackRegularAt)
            if changedRegularAt then
                inputTextBufferTempRegularAt = newTextRegularAt
            end
            if ImGui.IsItemDeactivated() then
                local newHealRegularAt = tonumber(inputTextBufferTempRegularAt)
                if newHealRegularAt then
                    state.config.Heals.HealRegularAt = newHealRegularAt
                end
            end

            ImGui.Text("Heal Tank At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferTankAt = tostring(state.config.Heals.HealTankAt)
            local inputTextBufferTempTankAt = inputTextBufferTankAt
            local inputTextCallbackTankAt = function(inputText)
                inputTextBufferTempTankAt = inputText
            end
            local newTextTankAt, changedTankAt = ImGui.InputText("##HealTankAtInput", inputTextBufferTempTankAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackTankAt)
            if changedTankAt then
                inputTextBufferTempTankAt = newTextTankAt
            end
            if ImGui.IsItemDeactivated() then
                local newHealTankAt = tonumber(inputTextBufferTempTankAt)
                if newHealTankAt then
                    state.config.Heals.HealTankAt = newHealTankAt
                end
            end

            
            ImGui.Text("HoT At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferHoTAt = tostring(state.config.Heals.HoTAt)
            local inputTextBufferTempHoTAt = inputTextBufferHoTAt
            local inputTextCallbackHoTAt = function(inputText)
                inputTextBufferTempHoTAt = inputText
            end
            local newTextHoTAt, changedHoTAt = ImGui.InputText("##HoTAtInput", inputTextBufferTempHoTAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackHoTAt)
            if changedHoTAt then
                inputTextBufferTempHoTAt = newTextHoTAt
            end
            if ImGui.IsItemDeactivated() then
                local newHoTAt = tonumber(inputTextBufferTempHoTAt)
                if newHoTAt then
                    state.config.Heals.HoTAt = newHoTAt
                end
            end

            ImGui.Text("Group Heal At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferGroupHealAt = tostring(state.config.Heals.GroupHealAt)
            local inputTextBufferTempGroupHealAt = inputTextBufferGroupHealAt
            local inputTextCallbackGroupHealAt = function(inputText)
                inputTextBufferTempGroupHealAt = inputText
            end
            local newTextGroupHealAt, changedGroupHealAt = ImGui.InputText("##GroupHealAtInput", inputTextBufferTempGroupHealAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackGroupHealAt)
            if changedGroupHealAt then
                inputTextBufferTempGroupHealAt = newTextGroupHealAt
            end
            if ImGui.IsItemDeactivated() then
                local newGroupHealAt = tonumber(inputTextBufferTempGroupHealAt)
                if newGroupHealAt then
                    state.config.Heals.GroupHealAt = newGroupHealAt
                end
            end

            
            ImGui.Text("Minimum Targets To Group Heal:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferGroupHealTarCountMin = tostring(state.config.Heals.GroupHealTarCountMin)
            local inputTextBufferTempGroupHealTarCountMin = inputTextBufferGroupHealTarCountMin
            local inputTextCallbackGroupHealTarCountMin = function(inputText)
                inputTextBufferTempGroupHealTarCountMin = inputText
            end
            local newTextGroupHealTarCountMin, changedGroupHealTarCountMin = ImGui.InputText("##GroupHealTarCountMinInput", inputTextBufferTempGroupHealTarCountMin, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackGroupHealTarCountMin)
            if changedGroupHealTarCountMin then
                inputTextBufferTempGroupHealTarCountMin = newTextGroupHealTarCountMin
            end
            if ImGui.IsItemDeactivated() then
                local newGroupHealTarCountMin = tonumber(inputTextBufferTempGroupHealTarCountMin)
                if newGroupHealTarCountMin then
                    state.config.Heals.GroupHealTarCountMin = newGroupHealTarCountMin
                end
            end

            ImGui.Text("Interrupt Heal At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferCancelHealAt = tostring(state.config.Heals.CancelHealAt)
            local inputTextBufferTempCancelHealAt = inputTextBufferCancelHealAt
            local inputTextCallbackCancelHealAt = function(inputText)
                inputTextBufferTempCancelHealAt = inputText
            end
            local newTextCancelHealAt, changedCancelHealAt = ImGui.InputText("##CancelHealAtInput", inputTextBufferTempCancelHealAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackCancelHealAt)
            if changedCancelHealAt then
                inputTextBufferTempCancelHealAt = newTextCancelHealAt
            end
            if ImGui.IsItemDeactivated() then
                local newCancelHealAt = tonumber(inputTextBufferTempCancelHealAt)
                if newCancelHealAt then
                    state.config.Heals.CancelHealAt = newCancelHealAt
                end
            end

            ImGui.Text("Ancestral Aid At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferAncAidAt = tostring(state.config.Shaman.AncAidAt)
            local inputTextBufferTempAncAidAt = inputTextBufferAncAidAt
            local inputTextCallbackAncAidAt = function(inputText)
                inputTextBufferTempAncAidAt = inputText
            end
            local newAncAidAt, changedAncAidAt = ImGui.InputText("##AncAidAtInput", inputTextBufferTempAncAidAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackAncAidAt)
            if changedAncAidAt then
                inputTextBufferTempAncAidAt = newAncAidAt
            end
            if ImGui.IsItemDeactivated() then
                local newAncAidAtVal = tonumber(inputTextBufferTempAncAidAt)
                if newAncAidAtVal then
                    state.config.Shaman.AncAidAt = newAncAidAtVal
                end
            end

            ImGui.Text("Ancestral Guard At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferAncGuardAt = tostring(state.config.Shaman.AncGuardAt)
            local inputTextBufferTempAncGuardAt = inputTextBufferAncGuardAt
            local inputTextCallbackAncGuardAt = function(inputText)
                inputTextBufferTempAncGuardAt = inputText
            end
            local newAncGuardAt, changedAncGuardAt = ImGui.InputText("##AncGuardAtInput", inputTextBufferTempAncGuardAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackAncGuardAt)
            if changedAncGuardAt then
                inputTextBufferTempAncGuardAt = newAncGuardAt
            end
            if ImGui.IsItemDeactivated() then
                local newAncGuardAtVal = tonumber(inputTextBufferTempAncGuardAt)
                if newAncGuardAtVal then
                    state.config.Shaman.AncGuardAt = newAncGuardAtVal
                end
            end
            
            
            ImGui.Text("Heal Ward At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferHealWardAt = tostring(state.config.Shaman.HealWardAt)
            local inputTextBufferTempHealWardAt = inputTextBufferHealWardAt
            local inputTextCallbackHealWardAt = function(inputText)
                inputTextBufferTempHealWardAt = inputText
            end
            local newHealWardAt, changedHealWardAt = ImGui.InputText("##HealWardAtInput", inputTextBufferTempHealWardAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackHealWardAt)
            if changedHealWardAt then
                inputTextBufferTempHealWardAt = newHealWardAt
            end
            if ImGui.IsItemDeactivated() then
                local newHealWardAtVal = tonumber(inputTextBufferTempHealWardAt)
                if newHealWardAtVal then
                    state.config.Shaman.HealWardAt = newHealWardAtVal
                end
            end

            ImGui.Text("Soothsayers At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferSoothsayersAt = tostring(state.config.Shaman.SoothsayersAt)
            local inputTextBufferTempSoothsayersAt = inputTextBufferSoothsayersAt
            local inputTextCallbackSoothsayersAt = function(inputText)
                inputTextBufferTempSoothsayersAt = inputText
            end
            local newSoothsayersAt, changedSoothsayersAt = ImGui.InputText("##SoothsayersAtInput", inputTextBufferTempSoothsayersAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackSoothsayersAt)
            if changedSoothsayersAt then
                inputTextBufferTempSoothsayersAt = newSoothsayersAt
            end
            if ImGui.IsItemDeactivated() then
                local newSoothsayersAtVal = tonumber(inputTextBufferTempSoothsayersAt)
                if newSoothsayersAtVal then
                    state.config.Shaman.SoothsayersAt = newSoothsayersAtVal
                end
            end

            ImGui.Text("Union At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local inputTextBufferUnionAt = tostring(state.config.Shaman.UnionAt)
            local inputTextBufferTempUnionAt = inputTextBufferUnionAt
            local inputTextCallbackUnionAt = function(inputText)
                inputTextBufferTempUnionAt = inputText
            end
            local newUnionAt, changedUnionAt = ImGui.InputText("##UnionAtInput", inputTextBufferTempUnionAt, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackUnionAt)
            if changedUnionAt then
                inputTextBufferTempUnionAt = newUnionAt
            end
            if ImGui.IsItemDeactivated() then
                local newUnionAtVal = tonumber(inputTextBufferTempUnionAt)
                if newUnionAtVal then
                    state.config.Shaman.UnionAt = newUnionAtVal
                end
            end
            
            

            ImGui.Columns(1)

            local windowHeight = ImGui.GetWindowHeight()
            local buttonPosY = windowHeight - BUTTON_SIZE - 10  -- Adjust the spacing as needed
        
            ImGui.SetCursorPosY(buttonPosY)

            -- Create the first button
            local buttonLabel1 = "Save\nConfig"
            if ImGui.Button(buttonLabel1, BUTTON_SIZE, BUTTON_SIZE) then
                conf.saveConfig(conf.path,state.config,conf.iniorder)
            end
            
            ImGui.SameLine()
            
            local buttonLabel2 = "Load\nConfig"
            if ImGui.Button(buttonLabel2, BUTTON_SIZE, BUTTON_SIZE) then
                state.config = conf.initConfig(conf.path)
            end

            ImGui.SameLine()

            if ImGui.Button(string.format('Reload\n     ' .. icons.FA_REFRESH), BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/multiline ; /lua stop shm420 ; /timed 5 /lua run shm420')
            end
            ImGui.EndTabItem()
            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 175) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 100) 

            anim:SetTextureCell(118)
            ImGui.DrawTextureAnimation(anim,150,150)
        end

        -- Fifth tab: Combat
        if ImGui.BeginTabItem(icons.FA_FIRE .. '  Combat') then
            -- Your Combat tab content goes here
            -- ...
            local totalWidth, _ = ImGui.GetContentRegionAvail()
            local columnWidth = totalWidth / 2

            ImGui.Columns(2)
            ImGui.SetColumnOffset(1, gentabOffset)
            ImGui.SetColumnWidth(1,columnWidth)
            ImGui.SetColumnWidth(2,columnWidth)

            local checkboxOrder = {
                "AASingleTurgurs",
                "AAMalo",
                "AETurgurs",
                "AEMalo",
                "Melee",
                "Slow",
                "TimeAntithesis"
            }

            local numberInputOrder = {
                "AttackAt",
                "AttackRange",
                "DebuffAt",
                "DebuffStop",
                "DDAt",
                "DDStop",
                "DoTAt",
                "DoTStop",
            }

            for _, key in ipairs(checkboxOrder) do
                local value = checkboxesCombat()[key]
                if ImGui.Checkbox(key, value) then
                    ImGui.SameLine()
                    ImGui.NewLine()
                    if tostring(state.config.Combat[key]) ~= 'On' then
                        print(string.format('\ay[\amSHM\ag420\ay]\am:\at %s: On', key))
                        state.config.Combat[key] = 'On'
                    end
                else
                    if tostring(state.config.Combat[key]) == 'On' then
                        print(string.format('\ay[\amSHM\ag420\ay]\am:\at %s: Off', key))
                        state.config.Combat[key] = 'Off'
                    end
                end
            end

            if ImGui.Checkbox('Hold Pet', checkboxes.PetHold) then
                if tostring(state.config.Pet.PetHold) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Pet Hold: On')
                    state.config.Pet.PetHold = 'On'
                end
            else
                if tostring(state.config.Pet.PetHold) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Pet Hold: Off')
                    state.config.Pet.PetHold = 'Off'
                end
            end

            if ImGui.Checkbox('Shrink Pet', checkboxes.PetShrink) then
                if tostring(state.config.Pet.PetShrink) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Pet Shrink: On')
                    state.config.Pet.PetShrink = 'On'
                end
            else
                if tostring(state.config.Pet.PetShrink) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Pet Shrink: Off')
                    state.config.Pet.PetShrink = 'Off'
                end
            end

            local dropdownOrder = {
                "DDs",
                "DoTs",
                "Cripple",
                "Feralize",
                "Malo",
                "UnresMalo",
            }
            
            -- Dropdown entries
            local dropdownOptions = { "On", "Off", "Named" }

            local function dropdowns()
                local drops = {
                DDs = state.config.Combat.DDs,
                DoTs = state.config.Combat.DoTs,
                Cripple = state.config.Shaman.Cripple,
                Feralize = state.config.Shaman.Feralize,
                Malo = state.config.Shaman.Malo,
                UnresMalo = state.config.Shaman.UnresMalo,
                }
                return drops
            end
            
            ImGui.NewLine()


            
            -- Render dropdowns
            for _, key in ipairs(dropdownOrder) do
                local value = dropdowns()[key]
            
                ImGui.Text(string.format("%s:", key))
                ImGui.SameLine()
            
                local currentIndex = 1
                for i, option in ipairs(dropdownOptions) do
                    if option == value then
                        currentIndex = i
                        break
                    end
                end
            
                local newComboIndex
                ImGui.SetNextItemWidth(100)
                newComboIndex, value = ImGui.Combo(string.format("##%sCombo", key), currentIndex, dropdownOptions, #dropdownOptions)
            
                if newComboIndex ~= currentIndex then
                    value = dropdownOptions[newComboIndex]
                    print(string.format('\ay[\am%s\ag420\ay]\am:\at %s: %s', key:upper(), key, value))
                    if key == "DDs" or key == "DoTs" then
                        state.config.Combat[key] = value
                    else
                        state.config.Shaman[key] = value
                    end
                end
        
            end

            local function numberInputsCombat() 
                local numbers = {
                AttackAt = state.config.Combat.AttackAt,
                AttackRange = state.config.Combat.AttackRange,
                DebuffAt = state.config.Combat.DebuffAt,
                DDAt = state.config.Combat.DDAt,
                DoTAt = state.config.Combat.DoTAt,
                DebuffStop = state.config.Combat.DebuffStop,
                DDStop = state.config.Combat.DDStop,
                DoTStop = state.config.Combat.DoTStop,
                }
                return numbers
            end

            ImGui.NextColumn()
            ImGui.SetColumnOffset(2, 1000)

            for _, key in ipairs(numberInputOrder) do
                local value = numberInputsCombat()[key]
                ImGui.Text(string.format("%s:", key))
                ImGui.SameLine()
                ImGui.SetNextItemWidth(35)
                
                local inputTextBuffer = tostring(value)
                local inputTextBufferTemp = inputTextBuffer
                
                local inputTextCallback = function(inputText)
                    inputTextBufferTemp = inputText
                end
                
                local newValue, changedValue = ImGui.InputText(string.format("##%sInput", key), inputTextBufferTemp, ImGuiInputTextFlags.CharsDecimal, inputTextCallback)
                
                if changedValue then
                    inputTextBufferTemp = newValue
                end
                
                if ImGui.IsItemDeactivated() then
                    local newNumericValue = tonumber(inputTextBufferTemp)
                    if newNumericValue then
                        state.config.Combat[key] = newNumericValue
                    end
                end
            end

            ImGui.Text("Pet Assist At:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local petAssistBuffer = tostring(state.config.Pet.PetAssist)
            local petAssistTempBuffer = petAssistBuffer
            local petAssistCallback = function(inputText)
                petAssistTempBuffer = inputText
            end
            local newPetAssist, changedPetAssist = ImGui.InputText("##PetAssistInput", petAssistTempBuffer, ImGuiInputTextFlags.CharsDecimal, petAssistCallback)
            if changedPetAssist then
                petAssistTempBuffer = newPetAssist
            end
            if ImGui.IsItemDeactivated() then
                local newPetAssistVal = tonumber(petAssistTempBuffer)
                if newPetAssistVal then
                    state.config.Pet.PetAssist = newPetAssistVal
                end
            end
        
            ImGui.Text("Pet Range:")
            ImGui.SameLine()
            ImGui.SetNextItemWidth(35)
            local petRangeBuffer = tostring(state.config.Pet.PetRange)
            local petRangeTempBuffer = petRangeBuffer
            local petRangeCallback = function(inputText)
                petRangeTempBuffer = inputText
            end
            local newPetRange, changedPetRange = ImGui.InputText("##PetRangeInput", petRangeTempBuffer, ImGuiInputTextFlags.CharsDecimal, petRangeCallback)
            if changedPetRange then
                petRangeTempBuffer = newPetRange
            end
            if ImGui.IsItemDeactivated() then
                local newPetRangeVal = tonumber(petRangeTempBuffer)
                if newPetRangeVal then
                    state.config.Pet.PetRange = newPetRangeVal
                end
            end

            ImGui.NewLine()

            local aeslowCheckbox = state.config.Shaman.AESlow:match('On|%d+') ~= nil
            local aeslowValue = tonumber(state.config.Shaman.AESlow:match('|(%d+)')) or 0
            
            -- Render checkbox for AESlow
            if ImGui.Checkbox("AESlow", aeslowCheckbox) then
                if state.config.Shaman.AESlow:match('On|%d+') == nil then state.config.Shaman.AESlow = string.format("On|%s",aeslowValue) end

                ImGui.SameLine()
                ImGui.Text("Min Targets")
                ImGui.SameLine()
                ImGui.SetNextItemWidth(35)
                
                local inputTextBufferAESlow = tostring(aeslowValue)
                local inputTextBufferTempAESlow = inputTextBufferAESlow
                
                local inputTextCallbackAESlow = function(inputText)
                    inputTextBufferTempAESlow = inputText
                end
                
                local newAESlowValue, changedAESlowValue = ImGui.InputText("##AESlowInput", inputTextBufferTempAESlow, ImGuiInputTextFlags.CharsDecimal, inputTextCallbackAESlow)
                
                if changedAESlowValue then
                    inputTextBufferTempAESlow = newAESlowValue
                end
                
                if ImGui.IsItemDeactivated() then
                    local newNumericValueAESlow = tonumber(inputTextBufferTempAESlow)
                    if newNumericValueAESlow then
                        state.config.Shaman.AESlow = string.format("On|%s", newNumericValueAESlow)
                    end
                end
            elseif state.config.Shaman.AESlow:match('On|%d+') ~= nil then state.config.Shaman.AESlow = string.format('Off|%s',aeslowValue) end

            ImGui.Columns(1)

            local windowHeight = ImGui.GetWindowHeight()
            local buttonPosY = windowHeight - BUTTON_SIZE - 10  -- Adjust the spacing as needed
        
            ImGui.SetCursorPosY(buttonPosY)

            -- Create the first button
            local buttonLabel1 = "Save\nConfig"
            if ImGui.Button(buttonLabel1, BUTTON_SIZE, BUTTON_SIZE) then
                conf.saveConfig(conf.path,state.config,conf.iniorder)
            end
            
            ImGui.SameLine()
            
            local buttonLabel2 = "Load\nConfig"
            if ImGui.Button(buttonLabel2, BUTTON_SIZE, BUTTON_SIZE) then
                state.config = conf.initConfig(conf.path)
            end

            ImGui.SameLine()

            if ImGui.Button(string.format('Reload\n     ' .. icons.FA_REFRESH), BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/multiline ; /lua stop shm420 ; /timed 5 /lua run shm420')
            end
            ImGui.EndTabItem()
            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 175) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 100) 

            anim:SetTextureCell(42)
            ImGui.DrawTextureAnimation(anim,150,150)
        end

        if ImGui.BeginTabItem(icons.FA_TROPHY .. '  Burn') then
            local totalWidth, _ = ImGui.GetContentRegionAvail()
            local columnWidth = totalWidth / 2

            -- Your Misc tab content goes here

            ImGui.Text("Big Burn If:")
            ImGui.SameLine()
            local bigBurnIfBuffer = state.config.Burn.BigBurnIf or ""
            local newBigBurnIf, changedBigBurnIf = ImGui.InputText("##BigBurnIfInput", bigBurnIfBuffer, 256)
            if changedBigBurnIf then
                state.config.Burn.BigBurnIf = newBigBurnIf
            end
        
        
            -- Dropdown options for BBurns and SBurns
            local burnOptions = { "alt", "spell", "item" }
        
            -- New entries for BBurns
            for i = 1, 8 do
                local burnKey = string.format("BBurn%d", i)
                ImGui.Text(burnKey .. ":")
                ImGui.SameLine()
        
                local burnBuffer = state.config.Burn[burnKey] or ""
                local newBurn, changedBurn = ImGui.InputText(string.format("##%sInput", burnKey), burnBuffer:match("^(.-)|"), 256)
        
                ImGui.SameLine()
        
                local currentIndex = 1
                for i, option in ipairs(burnOptions) do
                    if option == burnBuffer:match("|(.+)$") then
                        currentIndex = i
                        break
                    end
                end
        
                local newComboIndex
                newComboIndex, _ = ImGui.Combo(string.format("##%sCombo", burnKey), currentIndex, burnOptions, #burnOptions)
        
                if changedBurn or (newComboIndex ~= currentIndex) then
                    local newBurnValue = string.format("%s|%s", newBurn, burnOptions[newComboIndex])
                    state.config.Burn[burnKey] = newBurnValue
                end
            end

            ImGui.NewLine()
            ImGui.Text("Small Burn If:")
            ImGui.SameLine()
            local smallBurnIfBuffer = state.config.Burn.SmallBurnIf or ""
            local newSmallBurnIf, changedSmallBurnIf = ImGui.InputText("##SmallBurnIfInput", smallBurnIfBuffer, 256)
            if changedSmallBurnIf then
                state.config.Burn.SmallBurnIf = newSmallBurnIf
            end
        
            -- New entries for SBurns
            for i = 1, 8 do
                local burnKey = string.format("SBurn%d", i)
                ImGui.Text(burnKey .. ":")
                ImGui.SameLine()
        
                local burnBuffer = state.config.Burn[burnKey] or ""
                local newBurn, changedBurn = ImGui.InputText(string.format("##%sInput", burnKey), burnBuffer:match("^(.-)|"), 256)
        
                ImGui.SameLine()
        
                local currentIndex = 1
                for i, option in ipairs(burnOptions) do
                    if option == burnBuffer:match("|(.+)$") then
                        currentIndex = i
                        break
                    end
                end
        
                local newComboIndex
                newComboIndex, _ = ImGui.Combo(string.format("##%sCombo", burnKey), currentIndex, burnOptions, #burnOptions)
        
                if changedBurn or (newComboIndex ~= currentIndex) then
                    local newBurnValue = string.format("%s|%s", newBurn, burnOptions[newComboIndex])
                    state.config.Burn[burnKey] = newBurnValue
                end
            end
        
            ImGui.Columns(1)
        

            local windowHeight = ImGui.GetWindowHeight()
            local buttonPosY = windowHeight - BUTTON_SIZE - 10  -- Adjust the spacing as needed
        
            ImGui.SetCursorPosY(buttonPosY)

            -- Create the first button
            local buttonLabel1 = "Save\nConfig"
            if ImGui.Button(buttonLabel1, BUTTON_SIZE, BUTTON_SIZE) then
                conf.saveConfig(conf.path,state.config,conf.iniorder)
            end
            
            ImGui.SameLine()
            
            local buttonLabel2 = "Load\nConfig"
            if ImGui.Button(buttonLabel2, BUTTON_SIZE, BUTTON_SIZE) then
                state.config = conf.initConfig(conf.path)
            end

            ImGui.SameLine()

            if ImGui.Button(string.format('Reload\n     ' .. icons.FA_REFRESH), BUTTON_SIZE, BUTTON_SIZE) then
                mq.cmd('/multiline ; /lua stop shm420 ; /timed 5 /lua run shm420')
            end

            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 25) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 15) 

            if ImGui.Checkbox('Burn All Named', checkboxes.BurnAllNamed) then
                if tostring(state.config.Burn.BurnAllNamed) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Burn Named: On')
                    state.config.Burn.BurnAllNamed = 'On'
                end
            else
                if tostring(state.config.Burn.BurnAllNamed) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Burn Named: Off')
                    state.config.Burn.BurnAllNamed = 'Off'
                end
            end

            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() - 129) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 12) 

            if ImGui.Checkbox('Small Burn w/ Big Burn', checkboxes.SmallWithBig) then
                if tostring(state.config.Burn.SmallWithBig) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Both Burns: On')
                    state.config.Burn.SmallWithBig = 'On'
                end
            else
                if tostring(state.config.Burn.SmallWithBig) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Single Burn mode: On')
                    state.config.Burn.SmallWithBig = 'Off'
                end
            end

            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() - 178) 
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 38) 

            if ImGui.Checkbox('Use Tribute', checkboxes.UseTribute) then
                if tostring(state.config.Burn.UseTribute) ~= 'On' then 
                    print('\ay[\amSHM\ag420\ay]\am:\at Both Burns: On')
                    state.config.Burn.UseTribute = 'On'
                end
            else
                if tostring(state.config.Burn.UseTribute) == 'On' then
                    print('\ay[\amSHM\ag420\ay]\am:\at Single Burn mode: On')
                    state.config.Burn.UseTribute = 'Off'
                end
            end

            ImGui.EndTabItem()
        end


        ImGui.EndTabBar()

        local x, y = ImGui.GetWindowSize()
        if x < MINIMUM_WIDTH then ImGui.SetWindowSize(MINIMUM_WIDTH, y) end
    end
    ImGui.End()
    popStyles()
end

return ui