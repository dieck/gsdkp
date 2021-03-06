local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)

function GoogleSheetDKP:createTwoDialogFrame(title, text, onetxt, one, twotxt, two)
	local AceGUI = LibStub("AceGUI-3.0")

	local f = AceGUI:Create("Window")
	f:SetTitle(title)
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(400)
	f:SetHeight(100)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- close on escape
	_G["GoogleSheetDKPGoogleSheetDKP.twodialogframe"] = f.frame
	tinsert(UISpecialFrames, "GoogleSheetDKPGoogleSheetDKP.twodialogframe")

	local txt = AceGUI:Create("Label")
	txt:SetText(text)
	txt:SetRelativeWidth(1)
	f:AddChild(txt)

	local button1 = AceGUI:Create("Button")
	button1:SetText(onetxt)
	button1:SetRelativeWidth(0.5)
	button1:SetCallback("OnClick", function()
		one()
	end)
	f:AddChild(button1)

	local button2 = AceGUI:Create("Button")
	button2:SetText(twotxt)
	button2:SetRelativeWidth(0.5)
	button2:SetCallback("OnClick", function()
		two()
	end)
	f:AddChild(button2)

	return f
end


function GoogleSheetDKP:createThreeDialogFrame(title, text, onetxt, one, twotxt, two, threetxt, three)
	local AceGUI = LibStub("AceGUI-3.0")

	local f = AceGUI:Create("Window")
	f:SetTitle(title)
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(400)
	f:SetHeight(150)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- close on escape
	_G["GoogleSheetDKPGoogleSheetDKP.threedialogframe"] = f.frame
	tinsert(UISpecialFrames, "GoogleSheetDKPGoogleSheetDKP.threedialogframe")

	local txt = AceGUI:Create("Label")
	txt:SetText(text)
	txt:SetRelativeWidth(1)
	f:AddChild(txt)

	local button1 = AceGUI:Create("Button")
	button1:SetText(onetxt)
	button1:SetRelativeWidth(0.33)
	button1:SetCallback("OnClick", function()
		one()
	end)
	f:AddChild(button1)

	local button2 = AceGUI:Create("Button")
	button2:SetText(twotxt)
	button2:SetRelativeWidth(0.33)
	button2:SetCallback("OnClick", function()
		two()
	end)
	f:AddChild(button2)

	local button3 = AceGUI:Create("Button")
	button3:SetText(threetxt)
	button3:SetRelativeWidth(0.33)
	button3:SetCallback("OnClick", function()
		three()
	end)
	f:AddChild(button3)


	return f
end


function GoogleSheetDKP:askToTakeAttendance()
	-- not now
	if GoogleSheetDKP.attendancereminder > time() then
		return nil
	end

	-- only if enabled
	if not GoogleSheetDKP.db.profile.remind_attendance then
		return nil
	end

	-- only if no attendance stored
	if GoogleSheetDKP.db.profile.raidattendance ~= nil then
		return nil
	end

	GoogleSheetDKP.attendanceframe = nil

	local yes = function()
		GoogleSheetDKP.attendanceframe:Hide()
		GoogleSheetDKP.attendancereminder = time() + 24*60*60; -- ask again next day (or after reload)
		GoogleSheetDKP:Attendance()
	end

	local later = function()
		GoogleSheetDKP.attendanceframe:Hide()
		GoogleSheetDKP.attendancereminder = time() + 5*60; -- ask again in 5 minutes (on next change)
	end

	local no = function()
		GoogleSheetDKP.attendanceframe:Hide()
		GoogleSheetDKP.attendancereminder = time() + 24*60*60; -- ask again maybe next day (or after reload)
		-- do nothing
	end

	GoogleSheetDKP.attendanceframe = GoogleSheetDKP:createThreeDialogFrame("Attendance", "Shall I take Raid Attendance now?", "Yes", yes, "Later", later, "Not this session", no)
	GoogleSheetDKP.attendanceframe:Show()
end
