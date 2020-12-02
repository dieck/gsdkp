local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)

GoogleSheetDKP.dkpframe = nil

function GoogleSheetDKP:createDKPFrame()
	local AceGUI = LibStub("AceGUI-3.0")

	if GoogleSheetDKP.db.profile.current == nil then 
		GoogleSheetDKP:Print("No current DKP information.")
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
	btCfg:SetText("Config / Import / Export / Help")
	btCfg:SetRelativeWidth(0.99)
	btCfg:SetCallback("OnClick", function()
		GoogleSheetDKP.dkpframe:Hide()
		LibStub("AceConfigDialog-3.0"):Open("GoogleSheetDKP")
	end)
	f:AddChild(btCfg)
	
	
	scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!

	f:AddChild(scrollcontainer)

	s = AceGUI:Create("ScrollFrame")
	s:SetLayout("Flow") -- probably?
	scrollcontainer:AddChild(s)

	local lbHeaderTitle = AceGUI:Create("Label")
	lbHeaderTitle:SetText("Current DKP")
	lbHeaderTitle:SetRelativeWidth(0.99)
	lbHeaderTitle:SetColor(128,0,128)
	s:AddChild(lbHeaderTitle)

	local lbHeaderName = AceGUI:Create("Label")
	lbHeaderName:SetText("Name")
	lbHeaderName:SetRelativeWidth(0.49)
	lbHeaderName:SetColor(128,0,128)
	s:AddChild(lbHeaderName)

	local lbHeaderDKP = AceGUI:Create("Label")
	lbHeaderDKP:SetText("DKP")
	lbHeaderDKP:SetRelativeWidth(0.49)
	lbHeaderDKP:SetColor(128,0,128)
	s:AddChild(lbHeaderDKP)

	
	local i = 1
	for name,dkp in pairsByKeys(GoogleSheetDKP.db.profile.current) do

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

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("-----------------------------")
	lbHR:SetColor(128,128,0)
	lbHR:SetRelativeWidth(0.49)
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText(" ")
	lbHR:SetRelativeWidth(0.99)
	s:AddChild(lbHR)

	local lbHeaderTitle = AceGUI:Create("Label")
	lbHeaderTitle:SetText("Local History Information")
	lbHeaderTitle:SetRelativeWidth(0.99)
	lbHeaderTitle:SetColor(128,0,128)
	s:AddChild(lbHeaderTitle)

	local lbHeaderID = AceGUI:Create("Label")
	lbHeaderID:SetText("ID")
	lbHeaderID:SetRelativeWidth(0.10)
	lbHeaderID:SetColor(128,0,128)
	s:AddChild(lbHeaderID)

	local lbHeaderName = AceGUI:Create("Label")
	lbHeaderName:SetText("Name")
	lbHeaderName:SetRelativeWidth(0.25)
	lbHeaderName:SetColor(128,0,128)
	s:AddChild(lbHeaderName)

	local lbHeaderDKP = AceGUI:Create("Label")
	lbHeaderDKP:SetText("Change")
	lbHeaderDKP:SetRelativeWidth(0.15)
	lbHeaderDKP:SetColor(128,0,128)
	s:AddChild(lbHeaderDKP)

	local lbHeaderCause = AceGUI:Create("Label")
	lbHeaderCause:SetText("Cause / Ref")
	lbHeaderCause:SetRelativeWidth(0.49)
	lbHeaderCause:SetColor(128,0,128)
	s:AddChild(lbHeaderCause)

	local i = 1
	for hnum,h in pairsByKeys(GoogleSheetDKP.db.profile.history) do

		local lbID = AceGUI:Create("Label")
		lbID:SetText(hnum)
		if i % 2 == 0 then lbID:SetColor(0,128,128) end
		lbID:SetRelativeWidth(0.10)
		s:AddChild(lbID)

		local lbName = AceGUI:Create("Label")
		lbName:SetText(h["name"])
		if i % 2 == 0 then lbName:SetColor(0,128,128) end
		lbName:SetRelativeWidth(0.25)
		s:AddChild(lbName)

		local lbDKP = AceGUI:Create("Label")
		lbDKP:SetText(h["change"])
		if i % 2 == 0 then lbDKP:SetColor(0,128,128) end
		lbDKP:SetRelativeWidth(0.15)
		s:AddChild(lbDKP)
		
		local lbCause = AceGUI:Create("Label")
		local c = h["cause"]
		if h["comment"] then c = c .. " / " .. h["comment"] end
		lbCause:SetText(c)
		if i % 2 == 0 then lbCause:SetColor(0,128,128) end
		lbCause:SetRelativeWidth(0.49)
		s:AddChild(lbCause)

		i = i+1
	end
	
	return f
end
