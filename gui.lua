local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)
local AceGUI = LibStub("AceGUI-3.0")

GoogleSheetDKP.dkpframe = nil

function GoogleSheetDKP:createDKPFrame()
	if GoogleSheetDKP.db.profile.current == nil then
		GoogleSheetDKP:Print(L["No current DKP information."])
		return;
	end

	local f = AceGUI:Create("Window")
	f:SetTitle("GS DKP")
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(400)
	f:SetHeight(500)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- close on escape
	_G["GoogleSheetDKP.dkpframe"] = f.frame
	tinsert(UISpecialFrames, "GoogleSheetDKP.dkpframe")


	local btCfg = AceGUI:Create("Button")
	btCfg:SetText(L["Conf / Imp&Exp / Help"])
	btCfg:SetRelativeWidth(0.5)
	btCfg:SetCallback("OnClick", function(widget)
		widget.parent:Hide()
		LibStub("AceConfigDialog-3.0"):Open("GoogleSheetDKP")
	end)
	f:AddChild(btCfg)

	local btAction = AceGUI:Create("Button")
	btAction:SetText(L["Actions"])
	btAction:SetRelativeWidth(0.5)
	btAction:SetCallback("OnClick", function(widget)
		widget.parent:Hide()
		GoogleSheetDKP.actionframe = GoogleSheetDKP:createActionFrame()
	end)
	f:AddChild(btAction)

	local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!

	f:AddChild(scrollcontainer)

	local s = AceGUI:Create("ScrollFrame")
	s:SetLayout("Flow") -- probably?
	scrollcontainer:AddChild(s)

	local lbHeaderTitle = AceGUI:Create("Label")
	lbHeaderTitle:SetText(L["Current DKP"])
	lbHeaderTitle:SetRelativeWidth(0.99)
	lbHeaderTitle:SetColor(128,0,128)
	s:AddChild(lbHeaderTitle)

	local lbHeaderName = AceGUI:Create("Label")
	lbHeaderName:SetText(L["Name"])
	lbHeaderName:SetRelativeWidth(0.49)
	lbHeaderName:SetColor(128,0,128)
	s:AddChild(lbHeaderName)

	local lbHeaderDKP = AceGUI:Create("Label")
	lbHeaderDKP:SetText(L["DKP"])
	lbHeaderDKP:SetRelativeWidth(0.49)
	lbHeaderDKP:SetColor(128,0,128)
	s:AddChild(lbHeaderDKP)


	local i = 1
	for name,dkp in GoogleSheetDKP:pairsByKeys(GoogleSheetDKP.db.profile.current) do

		local lbName = AceGUI:Create("Label")
		lbName:SetText(name)
		lbName:SetRelativeWidth(0.49)
		if i % 2 == 0 then lbName:SetColor(0,128,128) end
		s:AddChild(lbName)

		local lbDKP = AceGUI:Create("Label")
		lbDKP:SetText(dkp)
		lbDKP:SetRelativeWidth(0.49)
		if i % 2 == 0 then lbDKP:SetColor(0,128,128) end
		s:AddChild(lbDKP)

		i = i+1
	end

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("-----------------------------")
	lbHR:SetColor(128,128,0)
	lbHR:SetRelativeWidth(0.49)
	s:AddChild(lbHR)

	local lbHR2 = AceGUI:Create("Label")
	lbHR2:SetText("-----------------------------")
	lbHR2:SetColor(128,128,0)
	lbHR2:SetRelativeWidth(0.49)
	s:AddChild(lbHR2)

	local lbHR3 = AceGUI:Create("Label")
	lbHR3:SetText(" ")
	lbHR3:SetRelativeWidth(0.99)
	s:AddChild(lbHR3)

	local lbHistoryTitle = AceGUI:Create("Label")
	lbHistoryTitle:SetText(L["Local History Information"])
	lbHistoryTitle:SetRelativeWidth(0.99)
	lbHistoryTitle:SetColor(128,0,128)
	s:AddChild(lbHistoryTitle)

	local lbHeaderID = AceGUI:Create("Label")
	lbHeaderID:SetText(L["ID"])
	lbHeaderID:SetRelativeWidth(0.10)
	lbHeaderID:SetColor(128,0,128)
	s:AddChild(lbHeaderID)

	local lbHeaderName2 = AceGUI:Create("Label")
	lbHeaderName2:SetText(L["Name"])
	lbHeaderName2:SetRelativeWidth(0.25)
	lbHeaderName2:SetColor(128,0,128)
	s:AddChild(lbHeaderName2)

	local lbHeaderChange = AceGUI:Create("Label")
	lbHeaderChange:SetText(L["Change"])
	lbHeaderChange:SetRelativeWidth(0.15)
	lbHeaderChange:SetColor(128,0,128)
	s:AddChild(lbHeaderChange)

	local lbHeaderCause = AceGUI:Create("Label")
	lbHeaderCause:SetText(L["Cause / Ref"])
	lbHeaderCause:SetRelativeWidth(0.49)
	lbHeaderCause:SetColor(128,0,128)
	s:AddChild(lbHeaderCause)

	local j = 1
	for hnum,h in GoogleSheetDKP:pairsByKeys(GoogleSheetDKP.db.profile.history) do

		local lbID = AceGUI:Create("Label")
		lbID:SetText(hnum)
		if j % 2 == 0 then lbID:SetColor(0,128,128) end
		lbID:SetRelativeWidth(0.10)
		s:AddChild(lbID)

		local lbName = AceGUI:Create("Label")
		lbName:SetText(h["name"])
		if j % 2 == 0 then lbName:SetColor(0,128,128) end
		lbName:SetRelativeWidth(0.25)
		s:AddChild(lbName)

		local lbDKP = AceGUI:Create("Label")
		lbDKP:SetText(h["change"])
		if j % 2 == 0 then lbDKP:SetColor(0,128,128) end
		lbDKP:SetRelativeWidth(0.15)
		s:AddChild(lbDKP)

		local lbCause = AceGUI:Create("Label")
		local c = h["cause"]
		if h["comment"] then c = c .. " / " .. h["comment"] end
		lbCause:SetText(c)
		if j % 2 == 0 then lbCause:SetColor(0,128,128) end
		lbCause:SetRelativeWidth(0.49)
		s:AddChild(lbCause)

		j = j+1
	end

	return f
end

function GoogleSheetDKP:createActionFrame()

	local f = AceGUI:Create("Window")
	f:SetTitle("GS DKP")
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(400)
	f:SetHeight(500)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- close on escape
	_G["GoogleSheetDKP.actionframe"] = f.frame
	tinsert(UISpecialFrames, "GoogleSheetDKP.actionframe")



	local btCfg = AceGUI:Create("Button")
	btCfg:SetText(L["Conf / Imp&Exp / Help"])
	btCfg:SetRelativeWidth(0.5)
	btCfg:SetCallback("OnClick", function()
		GoogleSheetDKP.actionframe:Hide()
		LibStub("AceConfigDialog-3.0"):Open("GoogleSheetDKP")
	end)
	f:AddChild(btCfg)

	local btDKP = AceGUI:Create("Button")
	btDKP:SetText(L["DKP Overview"])
	btDKP:SetRelativeWidth(0.5)
	btDKP:SetCallback("OnClick", function()
		GoogleSheetDKP.actionframe:Hide()
		GoogleSheetDKP.dkpframe = GoogleSheetDKP:createDKPFrame()
	end)
	f:AddChild(btDKP)


--	scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
--	scrollcontainer:SetFullWidth(true)
--	scrollcontainer:SetFullHeight(true) -- probably?
--	scrollcontainer:SetLayout("Fill") -- important!
--	f:AddChild(scrollcontainer)

	local tabGroup = AceGUI:Create("TabGroup")
	tabGroup:SetFullWidth(true)
	tabGroup:SetFullHeight(true)
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({
		{ value = "item", text = "item" },
		{ value = "change", text = "change" },
		{ value = "raidchange", text = "raidchange" },
		{ value = "raidinit", text = "raidinit" },
		{ value = "attendance", text = "attendance" },
	})
	tabGroup:SetCallback("OnGroupSelected", function(widget, event, group) GoogleSheetDKP:ActionFrameTabChange(widget, event, group) end)
	tabGroup:SelectTab("item")
	f:AddChild(tabGroup)

	return f

end

local actionFrameAction = ""
local actionFrameUser = ""
local actionFrameDKP = 0
local actionFrameCause = ""
local actionFrameComment = ""
local actionFrameDeletion = false

function GoogleSheetDKP:ActionFrameTabChange(container, event, group)
    container:ReleaseChildren()

	local s = AceGUI:Create("ScrollFrame")
	s:SetLayout("Flow") -- probably?
	container:AddChild(s)

	if group == "attendance" then
		actionFrameAction = group
		local children = GoogleSheetDKP:ActionFrameTab_attendance()
		s:AddChild(children["lbHeader"])
		s:AddChild(children["lbAlt1"])
		s:AddChild(children["lbAlt2"])
		s:AddChild(children["cbDeletion"])
		s:AddChild(children["btExecute"])
		return s
	end
	-- "else"


	local children = GoogleSheetDKP:ActionFrameTab_master()
	children["btExecute"]:SetText(L["Execute group action"](group))

	actionFrameAction = group

    if group == "item" then
		children["lbHeader"]:SetText(L["/gsdkp item PLAYER DKP ITEM"])
		children["lbAlt1"]:SetText(L["API: GoogleSheetDKP:Item(player,dkp,item)"])
		children["lbDKP"]:SetText("  " .. L["For Item, DKP normally is negative"])

		actionFrameCause = "Item"
		children["edCause"]:SetText("Item")
		children["edCause"]:SetDisabled(true)

		children["edComment"]:SetLabel("ItemLink:")
		local itemid = actionFrameComment:match("|Hitem:(%d+):")
		if not itemid then
			children["edComment"]:SetText("")
			actionFrameComment = ""
		end

    elseif group == "raidchange" then
		children["lbHeader"]:SetText(L["/gsdkp raidchange DKP CAUSE [COMMENT]"])
		children["lbAlt1"]:SetText(L["Alternative: /gsdkp raid DKP CAUSE [COMMENT]"])
		children["lbAlt2"]:SetText(L["API: GoogleSheetDKP:RaidChange(dkp,cause,comment)"])
		children["lbDKP"]:SetText("  " .. L["You may use negative or positive DKP for changes"])

		children["edChar"]:SetText(L["*ALL raid members*"])
		children["edChar"]:SetDisabled(true)
		children["ddChar"]:SetDisabled(true)

    elseif group == "raidinit" then
		children["lbHeader"]:SetText(L["/gsdkp raidinit"])
		children["lbAlt1"]:SetText(L["Alternative: /gsdkp init"])
		children["lbAlt2"]:SetText(L["API: GoogleSheetDKP:RaidInit()"])

		children["edChar"]:SetText(L["*NEW raid members*"])
		children["edChar"]:SetDisabled(true)
		children["ddChar"]:SetDisabled(true)

		actionFrameDKP = GoogleSheetDKP.db.profile.create_new_dkp
		children["edDKP"]:SetText(actionFrameDKP)
		children["edDKP"]:SetDisabled(true)
		children["lbDKP"]:SetText("  " .. L["See configuration"])

		actionFrameCause = L["Initial"]
		children["edCause"]:SetText(actionFrameCause)
		children["edCause"]:SetDisabled(true)

		actionFrameComment = L["Initial DKP from GoogleSheetDKP creation"]
		children["edComment"]:SetText(actionFrameComment)
		children["edComment"]:SetDisabled(true)

	else -- should only be: elseif group == "change" then
		children["lbHeader"]:SetText(L["/gsdkp change PLAYER DKP CAUSE [COMMENT]"])
		children["lbAlt1"]:SetText(L["API: GoogleSheetDKP:Change(player,dkp,cause,comment)"])
		children["lbDKP"]:SetText("  " .. L["You may use negative or positive DKP for changes"])

    end

	s:AddChild(children["lbHeader"])
	s:AddChild(children["lbAlt1"])
	s:AddChild(children["lbAlt2"])
	s:AddChild(children["edChar"])
	s:AddChild(children["ddChar"])
	s:AddChild(children["edDKP"])
	s:AddChild(children["lbDKP"])
	s:AddChild(children["edCause"])
	s:AddChild(children["edComment"])
	s:AddChild(children["btExecute"])
end


function GoogleSheetDKP:ActionFrameTab_attendance(container)
	local children = {}

	local lbHeader = AceGUI:Create("Heading")
	lbHeader:SetText(L["/gsdkp attendance ['delete']"])
	lbHeader:SetRelativeWidth(1.0)
	children["lbHeader"] = lbHeader

	local lbAlt1 = AceGUI:Create("Label")
	lbAlt1:SetText(L["Alternative: /gsdkp attend ['delete']"])
	lbAlt1:SetRelativeWidth(1.0)
	children["lbAlt1"] = lbAlt1

	local lbAlt2 = AceGUI:Create("Label")
	lbAlt2:SetText(L["API: GoogleSheetDKP:Attendance(['delete'])"])
	lbAlt2:SetRelativeWidth(1.0)
	children["lbAlt2"] = lbAlt2

	local cbDeletion = AceGUI:Create("CheckBox")
	cbDeletion:SetType("checkbox")
	cbDeletion:SetValue(actionFrameDeletion)
	cbDeletion:SetLabel(L["delete"])
	cbDeletion:SetRelativeWidth(1.0)
	cbDeletion:SetCallback("OnValueChanged", function(widget, event, value)
		actionFrameDeletion = widget:GetValue()
	end)
	children["cbDeletion"] = cbDeletion

	local btExecute = AceGUI:Create("Button")
	btExecute:SetText(L["Execute Action"])
	btExecute:SetRelativeWidth(1.0)
	btExecute:SetCallback("OnClick", function()
		GoogleSheetDKP:executeActionFrameAction()
	end)
	children["btExecute"] = btExecute

	return children
end

function GoogleSheetDKP:ActionFrameTab_master(container)
	local children = {}

	local lbHeader = AceGUI:Create("Heading")
	lbHeader:SetText("")
	lbHeader:SetRelativeWidth(1.0)
	children["lbHeader"] = lbHeader

	local lbAlt1 = AceGUI:Create("Label")
	lbAlt1:SetText("")
	lbAlt1:SetRelativeWidth(1.0)
	children["lbAlt1"] = lbAlt1

	local lbAlt2 = AceGUI:Create("Label")
	lbAlt2:SetText("")
	lbAlt2:SetRelativeWidth(1.0)
	children["lbAlt2"] = lbAlt2

	local edChar = AceGUI:Create("EditBox")
	edChar:SetText(actionFrameUser)
	edChar:SetLabel(L["User"])
	edChar:SetRelativeWidth(0.5)
	edChar:SetCallback("OnEnterPressed", function(widget)
		if widget:GetText() == nil or widget:GetText() == "" then
			GoogleSheetDKP:Print(L["You have to give a username"])
			widget:SetText(actionFrameUser)
			widget:ClearFocus()
			return nil
		end
		actionFrameUser = widget:GetText()
		widget:ClearFocus()
	end)
	children["edChar"] = edChar


	local raiderlist = { manual_select = L["-choose manually-"] }
	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		raiderlist[name] = name

		if GoogleSheetDKP.db.profile.current[name] then
			raiderlist[name] = name .. " (" .. GoogleSheetDKP.db.profile.current[name] .. ")"
		end
	end

	local preselect = "manual_select"
	if actionFrameUser and raiderlist[actionFrameUser] then preselect = actionFrameUser end


	local ddChar = AceGUI:Create("Dropdown")
	ddChar.edChar = edChar
	ddChar:SetList(raiderlist)
	ddChar:SetValue(preselect)
	ddChar:SetText(raiderlist[preselect])
	ddChar:SetLabel(L["Character"])
	ddChar:SetRelativeWidth(0.5)
	ddChar:SetCallback("OnValueChanged", function(widget, event, key)
		if key ~= "manual_select" then
			actionFrameUser = key
			widget.edChar:SetText(actionFrameUser)
		end
		widget:ClearFocus()
	end)
	children["ddChar"] = ddChar

	local edDKP = AceGUI:Create("EditBox")
	edDKP:SetText(actionFrameDKP)
	edDKP:SetLabel(L["DKP charge"])
	edDKP:SetRelativeWidth(0.5)
	edDKP:SetCallback("OnEnterPressed", function(widget)
		local newdkp = widget:GetText()

		if newdkp == nil then
			GoogleSheetDKP:Print(L["Can only set numeric values for DKP"])
			widget:SetText(actionFrameDKP)
			widget:ClearFocus()
			return nil
		end

		newdkp = tonumber(newdkp)
		if newdkp == nil then
			GoogleSheetDKP:Print(L["Can only set numeric values for DKP"])
			widget:SetText(actionFrameDKP)
			widget:ClearFocus()
			return nil
		end

		actionFrameDKP = newdkp
		widget:ClearFocus()
	end)
	children["edDKP"] = edDKP

	local lbDKP = AceGUI:Create("Label")
	lbDKP:SetText("")
	lbDKP:SetRelativeWidth(0.5)
	children["lbDKP"] = lbDKP

	local edCause = AceGUI:Create("EditBox")
	edCause:SetText(actionFrameCause)
	edCause:SetLabel(L["Cause"])
	edCause:SetRelativeWidth(1.0)
	edCause:SetCallback("OnEnterPressed", function(widget)
		local newcause = widget:GetText()
		if newcause == nil or newcause == "" then
			GoogleSheetDKP:Print(L["You have to give a cause"])
			widget:SetText(actionFrameCause)
			widget:ClearFocus()
			return nil
		end
		if strfind(newcause, "%s") then
			GoogleSheetDKP:Print(L["Cause can only be one word"])
			widget:SetText(actionFrameCause)
			widget:ClearFocus()
			return nil
		end
		actionFrameCause = newcause
		widget:ClearFocus()
	end)
	children["edCause"] = edCause

	local edComment = AceGUI:Create("EditBox")
	edComment.optional = true
	edComment:SetText(actionFrameComment)
	edComment:SetLabel(L["Comment (optional)"])
	edComment:SetRelativeWidth(1.0)
	edComment:SetCallback("OnEnterPressed", function(widget)
		local newcomment = widget:GetText()
		if (not widget.optional) and (newcomment == nil or newcomment == "") then
			GoogleSheetDKP:Print(L["You have to enter a value"])
			widget:SetText(actionFrameComment)
			widget:ClearFocus()
		end
		actionFrameComment = newcomment
		widget:ClearFocus()
	end)
	children["edComment"] = edComment

	local btExecute = AceGUI:Create("Button")
	btExecute:SetText(L["Execute Action"])
	btExecute:SetRelativeWidth(1.0)
	btExecute:SetCallback("OnClick", function()
		GoogleSheetDKP:executeActionFrameAction()
	end)
	children["btExecute"] = btExecute

	return children
end

function GoogleSheetDKP:executeActionFrameAction()

	local res = nil

	if actionFrameAction == 'raidinit' then
		res = GoogleSheetDKP:RaidInit()
	elseif actionFrameAction == 'raidchange' then
		res = GoogleSheetDKP:RaidChange(actionFrameDKP, actionFrameCause, actionFrameComment)
	elseif actionFrameAction == 'item' then
		res = GoogleSheetDKP:Item(actionFrameUser, actionFrameDKP, actionFrameComment)
	elseif actionFrameAction == 'attendance' then
		if actionFrameDeletion then
			res = GoogleSheetDKP:Attendance("delete")
		else
			res = GoogleSheetDKP:Attendance()
		end
	else --elseif actionFrameAction == 'change' then
		res = GoogleSheetDKP:Change(actionFrameUser, actionFrameDKP, actionFrameCause, actionFrameComment)
	end

	if res then GoogleSheetDKP.actionframe:Hide() end
end

