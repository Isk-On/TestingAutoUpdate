script_author("Jack_Richmond")
script_name("HelperTools")

require('lib.moonloader')
local dlstatus = require('moonloader').download_status

local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local inicfg = require('inicfg')
local iniFileName = 'HelperTools.ini'
local ini = inicfg.load({
    main = {
        need_ask_value = 0,
        time_wait = 0,
        first_day = 0,
        start_Pos_asks = 0,
        hask_state = false,
        auto_greetings = true,
        text_greetings = "������������",
        auto_login = false,
        password = "",
        key_open_hask = true,
        pincode = 0,
        auto_leave = false,
        line_break = true,
        receive_updates = true,
        nick_name = "Test_Testov"
    }
}, iniFileName)
inicfg.save(ini, iniFileName)

local sampev = require 'lib.samp.events'

local buttonSize = imgui.ImVec2(101.5, 30)

local helpMenu = imgui.ImBool(false)
local warn_menu = imgui.ImBool(false)
local update_menu = imgui.ImBool(false)
local other_help_menu = imgui.ImBool(false)
local command_help_menu = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)
local hask_window_state = imgui.ImBool(false)
local auto_login_settings = imgui.ImBool(false)
local helpers_online_menu = imgui.ImBool(false)
local command_help_menu_filter = imgui.ImBool(false)

local update_state = false
local updating_true = false
local script_vers = 1
local script_vers_text = "1.0"
local update_url = 'https://raw.githubusercontent.com/Isk-On/TestingAutoUpdate/main/updateTestFile.ini'
local update_path = getWorkingDirectory() .. "/updateIni.ini"
local script_url = 'https://raw.githubusercontent.com/Isk-On/TestingAutoUpdate/main/helperTools.lua'
local script_path = thisScript().path

local auto_login = imgui.ImBool(ini.main.auto_login)
local line_break = imgui.ImBool(ini.main.line_break)
local receive_updates = imgui.ImBool(ini.main.receive_updates)
local hask_state = imgui.ImBool(ini.main.hask_state)
local key_open_hask = imgui.ImBool(ini.main.key_open_hask)
local state_greetings = imgui.ImBool(ini.main.auto_greetings)
local auto_leave_from_game = imgui.ImBool(ini.main.auto_leave)
local question_buffer = imgui.ImBuffer(256)
local password = imgui.ImBuffer(256)
local pincode = imgui.ImBuffer(256)
local first_day = imgui.ImBuffer(256)
local text_greetings = imgui.ImBuffer(256)
local need_ask = imgui.ImBuffer(256)
local timeWait = imgui.ImBuffer(256)
local sw, sh = getScreenResolution()
local question = "nil"
local tag = "{1E90FF}[HelperTools]: {FFFFFF}"
local mute_state = false
local endOfHelperListTrue = false
local css = false
local HelpersStopState = false
local HelpersArray = {}
local helpersCheckState = false
text_greetings.v = u8:encode(ini.main.text_greetings)
password.v = u8:encode(ini.main.password)
pincode.v = u8:encode(ini.main.pincode)
local filtet = imgui.ImGuiTextFilter()

local filter_btns = {
    '��������', '��', '���������', '�����', '�������', '�������', '��', '���',
    '���', '��', '�����', '�����', '�������������'
}

local commands = {
    "/menu (/mm) - �������� ����.",
    "/myid - ������ ���� id.",
    "/myhistory - ������� ���������.",
    "/online (/onl) - ������ ������� ������ ������� �� �������.",
    "/id - ������ id ������ �� ��� ����.",
    "/setspawn (/ms) - �������� ����� ���������.",
    "/phone - �������.",
    "/phonebook (/pb) - ���������� ������.",
    "/sellbitcoins - ������� �������� ������.",
    "/speedlimit (/sl) - �������� ����� ��������.",
    "/race - ������� �����.",
    "/smoke - ������.",
    "/racelist - ������ �����.",
    "/blacklist - �������� ������� � ������ ������.",
    "/showblacklist - �������� ������� ������.",
    "/invsmall - ������ ������ ��������� ���������.",
    "/pick - ������� ������� �� �����.",
    "/skill - ���������� ���� ������.",
    "/pame - ���������� �������� ���������.",
    "/pwalk - ����� ����� �������������� ������.",
    "/asport - �������� ���������� ����������.",
    "/wext - �������� ������� �� ����.",
    "/sellcarbit - ������� ���������� �� �������.",
    "/tradecar - ���������� ������������.",
    "/invc - ������� ��������� ��������� ����������.",
    "/trunk - ��������.",
    "/hradio - ���������� ������������� ����.",
    "/hlock - �������/������� ���.",
    "/invh - ������� ��������� ����.",
    "/sellhouse - ������� ���.",
    "/findhouse(/fh) - ����� ���.",
    "/mhmenu - ���� ���� �� �������.",
    "/invmh - ��������� ���� �� �������.",
    "/mhinfo - ���������� � ���� �� �������.",
    "f/mhenter - ����� � ��� �� �������.ff",
    "/mhexit - ����� �� ���� �� �������.",
    "/bmenu (/bm) - ������� ���� �������.",
    "/sellbiz [id] [����] - ������� ������ ������.",
    "/buybiz - ������ ������� c ����.",
    "/fontsize - ���������� ������ ������. [������ ��� ������� � ��]",
    "/pagesize - ���������� ���������� ����� � ����. [������ ��� ������� � ��]",
    "/timestamp - �������� ������� ����� ����� ����������� � ����. [������ ��� ������� � ��]",
    "/headmove - ������������� �������� �������. [������ ��� ������� � ��]",
    "/r - IC ����� �������.",
    "/rn - OOC ����� �������.",
    "/d - IC ����� ������������.",
    "/dn - OOC ����� ������������.",
    "/gnews - ���. �������.",
    "/heal [ID] - ������ ������. [��������]",
    "/givemed [ID] - ������ �������� [��������]",
    "/changesex [ID] - ������� ��� ������. [��������]",
    "/gopatrule - ������ ��������������. [��������]",
    "/offpatrule - ���������� ��������������. [��������]",
    "/udo - �������� �������������.",
    "/wpanel - ����������� ����������.",
    "/members - ������ �������.",
    "/salelic - ������� ��������. [���������]",
    "/f - IC ����� �����.",
    "/fn - OOC ����� �����.",
    "/capture - ������ ������ ����������. [�����]",
    "/sellgun - ������� ������. [�����]",
    "/selldrugs - ������� ���������. [�����]",
    "/orderdrugs - �������� ���������. [�����]",
    "/band - ������ �������. [�����]",
    "/clotheskin - ������ ������� �����. [�����]",
    "/orderlist - ������ ����������. [�������]",
    "/load - ������ �������� ����������� � ����. [�������]",
    "/cload - ������ �������� ����� � ����. [�������]",
    "/cwar - �������� ����� �� ���������. [�������]",
    "/darknet - ������ �����. [�������]",
    "/bind - ������� ������. [�������/�������]",
    "/unbind - ��������� ������. [�������/�������]",
    "/gag - �������� ������ ����. [�������/�������]",
    "/ungag - �������� ���� � ������. [�������/�������]",
    "/bag - ����� ����� �� ������. [�������/�������]",
    "/unbag - ����� ����� � ������. [�������/�������]",
    "/cput - �������� ������ � ������. [�������/�������]",
    "/cout - �������� ������ � ������. [�������/�������]",
    "/sellkey - ������� �������. [�������]",
    "/convoy - ����� ������ ��� ������/��������� ������. [�������/�������]",
    "/stealcar - �������� ���������. [�������]",
    "/sellweapon - ������� ������ � �����. [�������]",
    "/udost (/ud) - �������� �������������. [��/���]",
    "/m - ��������� �������. [��/���]",
    "/frisk - ��������. [��/���]",
    "/take - ������ ��������. [��/���]",
    "/ticket - �������� �����. [��/���]",
    "/cput - ��������� ������ � ����. [��/���]",
    "/cout - �������� ������ � ����������� �������. [��/���]",
    "/cuff - ����� ���������. [��/���]",
    "/uncuff - ����� ���������. [��/���]",
    "/clear - ����� ������. [��/���]",
    "/su - ������ � ������. [��/���]",
    "/wanted - ������ �������������. [��/���]",
    "/convoy - ����� ������ ��� ������. [��/���]",
    "/arrest - �������� �����. [��/���]",
    "/carnumber (/cn) - ������ ����� ����������. [��/���]",
    "/pfine - ��������� ��������� �� ������������. [��/���]",
    "/break - ������ ����� ����. [��/���]",
    "/watchsafe - ���������� ���������� �����. [��/���]",
    "/gopatrule - ������ ��������������. [��/���]",
    "/offpatrule - ���������� ��������������. [��/���]",
    "/ctrunk - ������� �������� �/�. [��/���]",
    "/zap - ��������� ����� �� ����. [��/���]",
    "/chsafe - ������� ���� � �������� ����. [��/���]",
    "/pull - �������� ������ �� ����������. [��/���]",
    "/giveorder - ������ �����. [��/���]",
    "/setbarricade - ���������� �����������. [��/���]",
    "/delbarricade - ������ �����������. [��/���]",
    "/delallbarricade - ������ ��� �����������. [��/���]",
    "/strob - �������� ����������� � ���������� ����������. [��/���]",
    "/givepass - ������ �������. [���]",
    "/setlegend - ������ ���. [���]",
    "/stoplegend - ������� ���. [���]",
    "/dial - ���� ������. [���]",
    "/edit - ���� ����������. [���]",
    "/ammolist - ������ �������. [��]",
    "/banish - ������� �� ����������. [��]",
    "/gopatrule - ������ ��������������. [��]",
    "/offpatrule - ���������� ��������������. [��]",
    "/free - ���������� ������������. [�����]",
    "/salelic - ������� ���������� �� ��. [�����]",
    "/lots - ������ ������ �� ���������� � �������� ��������. [�����]",
    "/kickout - ������� �� �����. [�����]",
    "/lpanel (/lp) - ������ ������. [�����]",
    "/invite - ������� ������. [�����]",
    "/rc - ���������� ����������� ���������. [�����]",
    "/uninvite - ������� ������. [�����]",
    "/rank - �������� ���� ������. [�����]",
    "/vig - ������ ������� ������. [�����]",
    "/unvig - ����� ������� ������. [�����]",
    "/givedress - ������ ������������ �����. [�����]",
    "/addvacancy - ������� ��������. ",
    "/giveprize - ������ ������. [�����]",
    "/loweprize - �������� ��������. [�����]",
    "/unloweprize - �������� ��������� ��������. [�����]",
    "/offloweprize - �������� �������� (Offline). [�����]",
    "/offunloweprize - �������� ��������� �������� (Offline). [�����]",
    "/pp - ������ �������������. [�������������]",
    "/pmembers - ����� ������������� � ����. [�������������]",
    "/pinvite - ���������� ����� ������� � �������������. [�������������]",
    "/puninvite - ������� ����� ������� �� �������������. [�������������]",
}

function main()
    while not isSampAvailable() do wait(0) end

    sampRegisterChatCommand("update", function()
        if update_state then
            updating_true = true
        end
    end)

    sampRegisterChatCommand("aboutUpdate", function()
        if update_state then
            local updated_list = table.concat(update_list)
            local updated_list_with_linebreak = updated_list:gsub("|", "\n")
            sampShowDialog(8008, "about update", updated_list_with_linebreak,
                "�����", "�����", DIALOG_STYLE_MSGBOX)
        end
    end)

    sampRegisterChatCommand("checkhask", function()
        check_hask()
    end)

    sampRegisterChatCommand("tquest", function()
        hask_window_state.v = not hask_window_state.v
        imgui.Process = hask_window_state.v
    end)

    while true do
        wait(0)
        if wasKeyPressed(VK_F2) and mute_state then
            sampSendChat("/b /hmute " .. mute_id .. " " .. mute_quantity .. " " .. mute_reason)
            mute_state = false
        end
        if imgui.Process then
            sampSetChatInputEnabled(false)
        end
        if wasKeyPressed(VK_Q) and not sampIsCursorActive() and ini.main.key_open_hask then
            sampSendChat('/ha')
        end
        if isKeyDown(VK_LCONTROL) and isKeyJustPressed(VK_X) and not sampIsCursorActive() then
            if not imgui.Process then
                main_window_state.v = true
                imgui.Process = true
            end
        end
        if wasKeyPressed(VK_LMENU) and not sampIsCursorActive() then
            sampSendChat('/use')
        end
    end
end

function CloseAllWindows()
    helpMenu.v = false
    warn_menu.v = false
    update_menu.v = false
    other_help_menu.v = false
    command_help_menu.v = false
    auto_login_settings.v = false
    helpers_online_menu.v = false
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(600)
        imgui.TextUnformatted(description)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function check_hask()
    sampSendChat("/hpanel")
    sampSendDialogResponse(799, 1, 1, _)
    checkState = true
end

function Theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 6.0
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0

    colors[clr.Separator] = ImVec4(0.76, 0.31, 0.00, 1.00)
    colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.Border] = ImVec4(0.76, 0.31, 0.00, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
    colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
    colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
    colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
    colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
    colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

Theme()

function sampGetPlayerIdByNickname(nick)
    nick = tostring(nick)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nick == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1003 do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick .. "[M]" or sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick .. "[PC]" then
            return i
        end
    end
end

function sampev.onShowDialog(id, style, title, b1, b2, text)
    -- sampAddChatMessage(id, -1)
    if css and id == 802 and not helpersCheckState then
        lua_thread.create(function()
            for i = 0, 30 do
                helpersCheckState = true
                wait(300)
                while not sampGetCurrentDialogId() == 802 do wait(0) end
                wait(30)
                if i > 19 then
                    sampSendDialogResponse(802, 1, i - 20, _)
                else
                    sampSendDialogResponse(802, 1, (i > 9) and i - 10 or i, _)
                end
                wait(400)
                if sampGetCurrentDialogId() == 802 and endOfHelperListTrue then
                    if not i == 19 or not i == 9 then
                        sampAddChatMessage(
                            tag .. "���������, ��� ���-�� �������� � ������ ������������� ���-�� �������� � /hpanel.",
                            -1)
                        css = false
                        break
                    end
                end
                wait(400)
                while not sampGetCurrentDialogId() == 803 do wait(0) end
                wait(30)
                sampSendDialogResponse(803, 1, 0, _)
                wait(400)
                while not sampGetCurrentDialogId() == 804 do wait(0) end
                wait(30)
                sampSendDialogResponse(804, 1, 0, _)
                wait(700)
                sampSendChat("/hpanel")
                wait(700)
                while not sampGetCurrentDialogId() == 799 do wait(0) end
                wait(30)
                sampSendDialogResponse(799, 1, 2, _)
                wait(400)
                while not sampGetCurrentDialogId() == 802 do wait(0) end
                wait(30)
                if i >= 9 then
                    sampSendDialogResponse(802, 1, 10, _)
                    if i >= 19 then
                        wait(400)
                        while not sampGetCurrentDialogId() == 802 do wait(0) end
                        wait(30)
                        sampSendDialogResponse(802, 1, 10, _)
                    end
                    wait(400)
                end
                if HelpersStopState then
                    css = false
                    break
                end
            end
        end)
        HelpersStopState = false
        endOfHelperListTrue = false
    end

    if css and id == 802 and text:find("�����") then
        endOfHelperListTrue = true
    end


    if id == 804 and css then
        local name = text:match("%{FFFFFF%}���������� ������� %{f9b820%}(%w+_%w+)")
        local online = text:match("%{FFFFFF%}��������� �����: %{f9b820%}(.+)")
        local isDuplicate = false

        for _, v in pairs(HelpersArray) do
            if v == name .. " " .. online then
                isDuplicate = true
                HelpersStopState = true
                sampAddChatMessage(
                    tag .. "���������, ��� ���-�� �������� � ������ ������������� ���-�� �������� � /hpanel.",
                    -1)
            end
        end

        if not isDuplicate then
            HelpersArray[#HelpersArray + 1] = name .. " " .. online
        end
    end

    if checkState then
        if id == 804 then
            local ask = text:match("%{FFFFFF%}����� �������: %{f9b820%}(%d+)")
            local nick_name = text:match("%{FFFFFF%}���������� ������� %{f9b820%}(%w+_%w+)")
            ini.main.start_Pos_asks = ask
            ini.main.nick_name = nick_name
            sampSendDialogResponse(804, 0, 0, _)
            inicfg.save(ini, iniFileName)
            sampAddChatMessage(
                tag .. "��������� ���-�� �������. �������� ���-��: %{f9b820%}" ..
                ini.main.start_Pos_asks .. ".", -1)
            checkState = false
        end
    end
    if id == 774 then
        name, surname = text:match("%{FFFFFF%}���: %{f9b820%}(%w+)_(%w+)")
        nick = name .. "_" .. surname
        question = text:match("%{FFFFFF%}������: %{f9b820%}(.-){bcbcbc}")
        return false
    end
    if auto_login.v then
        if id == 43 then
            sampSendDialogResponse(43, 1, 0, -1)
            return false
        end
        if id == 40 then
            sampSendDialogResponse(40, 1, 0, -1)
            return false
        end
        if id == 41 then
            sampSendDialogResponse(41, 1, 0, ini.main.password) -- Password
            return false
        end
        if id == 42 then
            sampSendDialogResponse(42, 1, 0, ini.main.pincode) -- PinCode
            return false
        end
    end
end

function sampev.onSendDialogResponse(id, button, list, input)
    if id == 773 and button == 1 and list == 0 then
        hask_window_state.v = true
        imgui.Process = hask_window_state.v
    end
end

function imgui.OnDrawFrame()
    name = (name == nil) and "Name" or name
    nick = (nick == nil) and "Vasya_Pupkin" or nick

    if not main_window_state.v and not hask_window_state.v then
        imgui.Process = false
        CloseAllWindows()
    end

    if hask_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(700, (#u8:encode(question) > 115) and 260 or 240))
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        local id = sampGetPlayerIdByNickname(nick)
        local playerOnline = sampIsPlayerConnected((id == nil) and 9999 or id)
        local playerOnlineState = playerOnline and "����� � ����" or "����� � ��������"

        imgui.LockPlayer = true
        imgui.Begin(u8 "�����c �� ������ " .. nick .. " | " .. u8:encode(playerOnlineState), _,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)
        if #u8:encode(question) > 115 then
            local middle = #u8:encode(question) / 2
            imgui.TextColored(
                (playerOnline) and imgui.ImVec4(0.0, 255.0, 0.0, 1.0) or imgui.ImVec4(255.0, 0.0, 0.0, 4.0), u8 '������:')
            imgui.SameLine(65)
            imgui.Text(u8:encode(question):sub(1, middle) .. "...")
            imgui.Text(u8 "..." .. u8:encode(question):sub(middle + 1, #u8:encode(question)))
        else
            imgui.TextColored(
                (playerOnline) and imgui.ImVec4(0.0, 255.0, 0.0, 1.0) or imgui.ImVec4(255.0, 0.0, 0.0, 4.0), u8 '������:')
            imgui.SameLine(65)
            imgui.Text(u8:encode(question))
        end
        imgui.PushItemWidth(670)
        imgui.InputText("dfd", question_buffer)
        if imgui.Button(u8 "������", buttonSize) then
            question_buffer.v = u8 "�� ���������. �������� ����."
        end
        imgui.SameLine()
        if imgui.Button(u8 "��� ���", buttonSize) then
            question_buffer.v = u8 "�� �� ��������������, ��� � /rep"
        end
        imgui.SameLine()
        if imgui.Button(u8 "��������", buttonSize) then
            question_buffer.v = u8 "�������� ���� ������. �������� ����."
        end
        imgui.SameLine()
        if imgui.Button(u8 "���", buttonSize) then
            question_buffer.v = u8 "��� - ������������� ����������� ��������(����)."
        end
        imgui.SameLine()
        if imgui.Button(u8 "��������", buttonSize) then
            question_buffer.v = u8 "/en - ������� �������� (���� � ������), ����� /invc (���� � ���������)."
        end
        imgui.SameLine()
        if imgui.Button(u8 "��������", buttonSize) then
            question_buffer.v = u8 "/en - ������� ����� (���� � ������), ����� /usetools (���� � ������)."
        end
        if imgui.Button(u8 "�������� ����", buttonSize) then
            question_buffer.v = u8 "�������� ���� �� ��������� Mordor Role Play 03."
        end
        imgui.SameLine()
        if imgui.Button(u8 "��� �����", buttonSize) then
            question_buffer.v = u8 "���, �� ����� ������ ����������. �������� ����."
        end
        imgui.SameLine()
        if imgui.Button(u8 "�����", buttonSize) then
            sampSendDialogResponse(774, 1, 0, "!C����� � ��� �������� �����.")
            hask_window_state.v = false
            question_buffer.v = ""
        end
        imgui.SameLine()
        if imgui.Button(u8 "������", buttonSize) then
            other_help_menu.v = not other_help_menu.v
        end
        imgui.SameLine()
        if imgui.Button(u8 "�������", buttonSize) then
            command_help_menu.v = not command_help_menu.v
        end
        imgui.SameLine()
        if imgui.Button(u8 "�� �������", buttonSize) then
            helpMenu.v = not helpMenu.v
        end
        imgui.Separator()
        if imgui.Button(u8 "�������", imgui.ImVec2(300, 50)) then
            sampSendDialogResponse(774, 0, 0, _)
            hask_window_state.v = false
            question_buffer.v = ""
        end
        imgui.SameLine()
        imgui.SetCursorPosX(385)
        if imgui.Button(u8 "��������", imgui.ImVec2(300, 50)) then
            greetings = ini.main.text_greetings .. " " .. name .. ", " .. u8:decode(question_buffer.v)
            if question_buffer.v == "" then
                sampAddChatMessage(tag .. "�� �� ����� �����.", -1)
            else
                if state_greetings.v then
                    if #greetings >= 80 and line_break.v then
                        local id = sampGetPlayerIdByNickname(nick)
                        local middle = #greetings / 2
                        sampSendDialogResponse(774, 1, 0, greetings:sub(1, middle) .. "...")
                        sampSendChat("/ans " .. id .. " ..." .. greetings:sub(middle + 1, #greetings))
                    else
                        sampSendDialogResponse(774, 1, 0, greetings)
                    end
                else
                    if #u8:decode(question_buffer.v) >= 80 and line_break.v then
                        local id = sampGetPlayerIdByNickname(nick)
                        local middle = #u8:decode(question_buffer.v) / 2
                        sampSendDialogResponse(774, 1, 0, u8:decode(question_buffer.v):sub(1, middle) .. "...")
                        sampSendChat(
                            "/ans " ..
                            id .. " ..." .. u8:decode(question_buffer.v):sub(middle + 1, #u8:decode(question_buffer.v)))
                    else
                        sampSendDialogResponse(774, 1, 0, u8:decode(question_buffer.v))
                    end
                end
                hask_window_state.v = false
                question_buffer.v = ""
            end
        end
        imgui.End()
    end


    if other_help_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(130, 515), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 4.75), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8 "�����", _,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders + imgui.WindowFlags.NoTitleBar)

        if imgui.Button(u8 "�� ������ �� ���", buttonSize) then
            question_buffer.v = u8 "�� ������ �� ��������� ������. �������� ����."
        end
        if imgui.Button(u8 "��������", buttonSize) then
            question_buffer.v = u8 "����������: #Naumov , ��������: #vknm #startvk #RPBauto"
        end

        imgui.End()
    end

    if command_help_menu_filter.v then
        imgui.SetNextWindowSize(imgui.ImVec2(130, 515), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.25), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8 "����", _,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders + imgui.WindowFlags.NoTitleBar)

        for i = 1, #filter_btns do
            if imgui.Button(u8:encode(filter_btns[i]), buttonSize) then
                filtet = imgui.ImGuiTextFilter(u8:encode(filter_btns[i]))
            end
        end
        imgui.End()
    end

    if command_help_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(650, 240), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 1.25), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))


        imgui.Begin(u8 "�������", command_help_menu,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)
        filtet:Draw(u8 "�����", 580)

        for i = 1, #commands do
            if filtet:PassFilter(u8(commands[i])) then
                imgui.Text(u8(commands[i]))
                if filtet:IsActive() then
                    imgui.SameLine()
                    if imgui.Button(u8 "�����������##" .. i) then
                        question_buffer.v = u8:encode(commands[i])
                    end
                end
            end
        end

        lua_thread.create(function()
            while command_help_menu.v do
                wait(0)
                command_help_menu_filter.v = command_help_menu.v
            end
        end)
        imgui.End()
    end

    if main_window_state.v then
        imgui.LockPlayer = true
        imgui.SetNextWindowSize(imgui.ImVec2(780, 180), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 1.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8 "��������� HelperTools", main_window_state,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)
        if imgui.Checkbox(u8 '����.�����������', state_greetings) then
            ini.main.auto_greetings = state_greetings.v
            inicfg.save(ini, iniFileName)
        end
        imgui.SameLine()
        if imgui.Checkbox(u8 '����.�����������', auto_login) then
            if ini.main.password ~= "" and ini.main.pincode ~= "" then
                ini.main.auto_login = auto_login.v
                inicfg.save(ini, iniFileName)
            else
                sampAddChatMessage(tag .. '�� �� ����� ���� ������ ��� ���-���.', -1)
                auto_login.v = false
            end
        end
        imgui.SameLine()
        if imgui.Checkbox(u8 '����.�������', line_break) then
            ini.main.line_break = line_break.v
            inicfg.save(ini, iniFileName)
        end
        imgui.SameLine()
        imgui.TextQuestion("( ? )",
            u8 "���� ����� �������� ������� 80-�� ��������, �� ������ ������������� ������� ����� �� 2, � ������ ����� �������� � /ans ������.")
        imgui.SameLine()
        if imgui.Checkbox(u8 '����.���', auto_leave_from_game) then
            ini.main.auto_leave = auto_leave_from_game.v
            inicfg.save(ini, iniFileName)
        end
        imgui.SameLine()
        imgui.TextQuestion("( ? )",
            u8 "�������������� ����� �� ������ � �� ���� ����� /hc off")
        imgui.SameLine()
        if imgui.Checkbox(u8 '������ �������� �� Q', key_open_hask) then
            ini.main.key_open_hask = key_open_hask.v
            inicfg.save(ini, iniFileName)
        end
        if imgui.Button(u8 "����.�����") then
            auto_login_settings.v = not auto_login_settings.v
        end
        imgui.SameLine()
        if imgui.Button(u8 "��������� ������ ��������������") then
            warn_menu.v = not warn_menu.v
        end
        imgui.SameLine()
        imgui.TextQuestion("( ? )",
            u8 "� ��������� ����� ������ ������� ��� ����� �������� �� ��������, ��� ������ ��������������.")
        imgui.SameLine()
        if imgui.Button(u8 "������ ��������") then
            helpers_online_menu.v = not helpers_online_menu.v
        end
        imgui.SameLine()
        imgui.TextQuestion("( ? )",
            u8 "� ������� '������ ��������' ����� ������ ������ ������ ���� ��������. ������ ��� ������ �������� ������ ������� ������� � /hpanel. � ����� ������� ������� � �����������.")

        imgui.SameLine()
        if imgui.Button(u8 "��������� ����������") then
            update_menu.v = not update_menu.v
        end
        imgui.PushItemWidth(120)
        imgui.InputText(u8 "���� �����������", text_greetings)
        imgui.SameLine()
        if imgui.Button(u8 "��������� �����������") then
            ini.main.text_greetings = u8:decode(text_greetings.v)
            inicfg.save(ini, iniFileName)
        end

        if imgui.Button(u8 '������� ���������', imgui.ImVec2(750, 30)) then
            main_window_state.v = false
        end
        imgui.End()
    end

    if helpers_online_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(500, 350), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 1.4, sh / 3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8 "������ ��������", helpers_online_menu,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)

        if not css then
            if imgui.Button(u8 "���������", imgui.ImVec2(470, 30)) then
                if not sampIsDialogActive() then
                    css = true
                    helpersCheckState = false
                    sampSendChat('/hpanel')
                    sampSendDialogResponse(799, 1, 2, _)
                else
                    sampAddChatMessage(tag .. "�������� ���������� ����.", -1)
                end
            end
        else
            if imgui.Button(u8 "����������", imgui.ImVec2(470, 30)) then
                HelpersStopState = true
                css = false
            end
        end

        if imgui.Button(u8 "����������� � ����� ������", imgui.ImVec2(229, 30)) then
            local allHelpers = table.concat(HelpersArray, ", ")
            setClipboardText(allHelpers)
            sampAddChatMessage(tag .. "�� ����������� ������ �������� � ����� ������.",
                -1)
        end
        imgui.SameLine()
        if imgui.Button(u8 "��������", imgui.ImVec2(229, 30)) then
            HelpersArray = {}
        end
        imgui.Text(u8 "����������: ")

        for _, v in pairs(HelpersArray) do
            local nick, online = v:match("(%w+_%w+) (.+)")

            if online:find("(%d+):(%d+):(%d+)|(%d+):(%d+):(%d+)") then
                ThisHours, ThisMinutes, ThisSeconds, LastHours, LastMinutes, LastSeconds = online:match(
                    "(%d+):(%d+):(%d+)|(%d+):(%d+):(%d+)")
            elseif not online:find("(%d+):(%d+):(%d+)|(%d+):(%d+):(%d+)") then
                ThisHours = 0
            end


            imgui.Text(_ .. ". " .. v)
            imgui.SameLine()
            if tonumber(ThisHours) >= 12 then
                imgui.TextColored(imgui.ImVec4(0.0, 255.0, 0.0, 1.0), u8 '��������')
            else
                imgui.TextColored(imgui.ImVec4(255.0, 0.0, 0.0, 4.0), u8 '�� ��������')
            end
        end

        imgui.End()
    end

    if update_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 150), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8 "��������� ����������. ������ �������: " .. script_vers_text,
            update_menu,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)
        if imgui.Button(u8 "��������� ������� ����������") then
            CheckUpdates()
        end
        if imgui.Checkbox(u8 '�������� ���������', receive_updates) then
            ini.main.receive_updates = receive_updates.v
            inicfg.save(ini, iniFileName)
        end
        imgui.End()
    end

    if auto_login_settings.v then
        imgui.SetNextWindowSize(imgui.ImVec2(300, 150), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8 "����.�����", auto_login_settings,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)
        imgui.InputText(u8 "��� ������", password, imgui.InputTextFlags.Password)
        imgui.InputText(u8 "��� ���-���", pincode, imgui.InputTextFlags.Password)
        if imgui.Button(u8 "��������� ������ � ���-���") then
            if password.v ~= "" and pincode.v ~= "" then
                ini.main.password = password.v
                ini.main.pincode = pincode.v
                inicfg.save(ini, iniFileName)
                sampAddChatMessage(tag .. "������� ���������.", -1)
            else
                sampAddChatMessage(tag .. "�� �� ����� ������ ��� ���-���.", -1)
            end
        end
        imgui.End()
    end

    if warn_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(230, 270), imgui.Cond.FirstUseEver)

        imgui.Begin(u8 "���������", warn_menu,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)
        imgui.PushItemWidth(50)
        imgui.InputText(u8 "������ ����", first_day, imgui.InputTextFlags.CharsDecimal)
        imgui.SameLine()
        imgui.TextQuestion("( ? )", u8 "�������� ���������� ��������, ������� � ��� ���� � ������ ���� ������.")
        imgui.PushItemWidth(50)
        imgui.InputText(u8 "���-�� ��������", need_ask, imgui.InputTextFlags.CharsDecimal)
        imgui.SameLine()
        imgui.TextQuestion("( ? )",
            u8 "�������� ���������� ��������, �� ������� �� ������ �������� ��� ������ ��������������.")
        if imgui.Button(u8 "���������") then
            if need_ask.v ~= "" and first_day.v ~= "" then
                ini.main.need_ask_value = need_ask.v
                ini.main.first_day = first_day.v
                inicfg.save(ini, iniFileName)
            end
        end
        imgui.Text(u8 "������� ������ �����!!!")
        imgui.Separator()
        imgui.Text(u8 "������ ���� " .. ini.main.first_day)
        imgui.Text(u8 "�������� ���-�� " .. ini.main.start_Pos_asks)
        local answered = ini.main.start_Pos_asks - ini.main.first_day
        imgui.Text(u8 "�������� ��: " .. answered)
        imgui.Text(u8 "��� ����� �������� ��: " .. ini.main.need_ask_value - answered)
        imgui.End()
    end

    if helpMenu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(470, 235), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 1.25), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8 "�� �������", helpMenu,
            imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse +
            imgui.WindowFlags.ShowBorders)
        if imgui.Button(u8 "MG", buttonSize) then
            question_buffer.v = u8 "MG - MetaGaming. ������������� ���������� �� ��������� ���� � ��(IC) ���."
        end
        imgui.SameLine()
        if imgui.Button(u8 "SK", buttonSize) then
            question_buffer.v = u8 "SK - SpawnKill. �������� ������ �� ��� ������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "DB", buttonSize) then
            question_buffer.v = u8 "DB - DriveBy. �������� ������� ���� ������ ��� RP �������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "PG", buttonSize) then
            question_buffer.v = u8 "PG � PowerGaming. ������������� ����������, ���������, ����������� ������������ ������ ��������� ��� �� �������� � �����."
        end
        if imgui.Button(u8 "DM", buttonSize) then
            question_buffer.v = u8 "DM - DeathMatch. �������� ��� ��������� ����� ������ ��� RP �������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "TK", buttonSize) then
            question_buffer.v = u8 "TK - Team Kill. �������� ����� ������ �����������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "RP", buttonSize) then
            question_buffer.v = u8 "RP - Role Play. ���� �� �����, ����������� ���� ������ ���������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "nRP", buttonSize) then
            question_buffer.v = u8 "NRP - Non Role Play. �� ���������� ����������� ����� ����."
        end
        if imgui.Button(u8 "RK1", buttonSize) then
            question_buffer.v = u8 "RK - Revenge Kill. �������� ������ �� ��, ��� �� ���� ���."
        end
        imgui.SameLine()
        if imgui.Button(u8 "RK2", buttonSize) then
            question_buffer.v = u8 "RK - Repeat Kill. �������� ������ � ���� �� ������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "CK", buttonSize) then
            question_buffer.v = u8 "CK - �haracter Kill. RP �������� � ����� ������ ���������� RP ���������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "FG", buttonSize) then
            question_buffer.v = u8 "FG - Fun Gaming. ���� �� ����, �� �������� ������� ������� � RP ���������."
        end
        if imgui.Button(u8 "IC", buttonSize) then
            question_buffer.v = u8 "IC - In Character. ���������� �� ����������� �����, �� ��� ������� ������������ ����."
        end
        imgui.SameLine()
        if imgui.Button(u8 "OOC", buttonSize) then
            question_buffer.v = u8 "OOC - Out Of Character. ���������� �� �������� �����, �� ��� ������� ��������� ����."
        end
        imgui.SameLine()
        if imgui.Button(u8 "FM", buttonSize) then
            question_buffer.v = u8 "FM - fast moving. ������� ������������ � ������� ����."
        end
        imgui.SameLine()
        if imgui.Button(u8 "����", buttonSize) then
            question_buffer.v = u8 "���� - ��������� ������ ������ ��������."
        end
        if imgui.Button(u8 "BH", buttonSize) then
            question_buffer.v = u8 "BH - Bunny Hop. NonRP ��� � �������� � ����� �������� �������� ������������."
        end
        imgui.SameLine()
        if imgui.Button(u8 "����", buttonSize) then
            question_buffer.v = u8 "���� - ��������� ����������� �����������."
        end
        imgui.End()
    end
end

function sampev.onServerMessage(color, text)
    lua_thread.create(function()
        if text:find('��� ������� ������� ����������, �������� ����!') then
            wait(1000)
            sampSendChat("/hduty")
            check_hask()
            wait(600)
            sampSendChat("/helpers")
            wait(600)
            if ini.main.receive_updates then
                CheckUpdates()
            end
        end

        if text:find("off") and text:find(ini.main.nick_name) and ini.main.auto_leave then
            if text:find("H") then
                wait(1)
                sampSendChat("/hduty")
                wait(500)
                sampProcessChatInput('/q')
            end
        end
    end)

    if text:find('%[������%] ����� (%w+_%w+)%[(%d+)%] ����� ������ ������� %{f9b820%}/hask %(/ha%) %{33CCFF%}����� ��������. ����� ��������: (%d+)') then
        local nick, id, v = text:match(
            '%[������%] ����� (%w+_%w+)%[(%d+)%] ����� ������ ������� %{f9b820%}/hask %(/ha%) %{33CCFF%}����� ��������. ����� ��������: (%d+)')
        sampAddChatMessage('{33CCFF}����� � ����� {FFFF00}"' ..
            nick ..
            '"{33CCFF} � � id {FFFF00}"' ..
            id .. '"{33CCFF} ����� ������. ����� ��������: {FFFF00}' .. v .. '{33CCFF}.', -1)
        lua_thread.create(function()
            if ini.main.hask_state then
                wait(ini.main.time_wait)
                sampSendChat('/ha')
                sampSendDialogResponse(772, 1, v - 1, _)
            end
        end)
        return false
    end
    if text:find("������ " .. ini.main.nick_name .. "%[(%d+)%] ���") then
        ini.main.start_Pos_asks = ini.main.start_Pos_asks + 1
        inicfg.save(ini, iniFileName)
    end
    if text:find("(%w+_%w+)%[(%d+)%]: /hmute (%d+) (%d+) (.+)") then
        hname, hid, mute_id, mute_quantity, mute_reason = text:match("(%w+_%w+)%[(%d+)%]: /hmute (%d+) (%d+) (.+)")
        local name = sampGetPlayerNickname(mute_id)
        sampAddChatMessage(tag .. "������� ����� ��� ����. ��� ����������: {8B0000}" ..
            name .. "{FFFFFF}. ��������...", -1)
        sampAddChatMessage(
            tag .. "...����� ������: {FFFF00}" ..
            hname .. "{FFFFFF}. ��� ������ ������� ��  ������� {00FF00}'F2'.", -1)
        local author_reason_name, author_reason_surname = hname:match("(%w+)_(%w+)")
        mute_reason = mute_reason .. " || " .. author_reason_name:sub(1, 1) .. "." .. author_reason_surname
        mute_state = true
    end
end

function CheckUpdates()
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            local updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.versInfo.vers) > script_vers then
                update_list = { u8:decode(updateIni.versInfo.whatsNew) }
                sampAddChatMessage(tag ..
                    "{FFFFFF}������� {32CD32}����� {FFFFFF}������ �������. ������: {32CD32}" ..
                    updateIni.versInfo.vers_text:gsub('"', "") .. "{FFFFFF}...", -1)
                    sampAddChatMessage(tag .. "...{FFFFFF}������� /aboutUpdate ����� ������� ������ ������������.", -1)
                update_state = true
            else
                sampAddChatMessage(
                    tag .. "���������� �� �������. ������: {32CD32}" ..
                    updateIni.versInfo.vers_text:gsub('"', ""), -1)
            end
            os.remove(update_path)
        end
    end)
end

lua_thread.create(function()
    while true do
        wait(0)
        if update_state and updating_true then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(tag .. "{FFFFFF}������ {32CD32}������� {FFFFFF}�������.",
                        0xFF0000)
                end
            end)
            break
        end
    end
end)
