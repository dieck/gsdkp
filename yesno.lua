local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)

function GoogleSheetDKP:createTwoDialogFrame(title, text, onetxt, one, twotxt, two)
	if not GoogleSheetDKP.frameCounter then GoogleSheetDKP.frameCounter = 0 end
    GoogleSheetDKP.frameCounter = GoogleSheetDKP.frameCounter + 1

	local AceGUI = LibStub("AceGUI-3.0")

	local f = AceGUI:Create("Window")
	f:SetTitle(title)
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(400)
	f:SetHeight(100)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- close on escape
	_G["GoogleSheetDKPGoogleSheetDKP.twodialogframe" .. tostring(GoogleSheetDKP.frameCounter)] = f.frame
	tinsert(UISpecialFrames, "GoogleSheetDKPGoogleSheetDKP.twodialogframe" .. tostring(GoogleSheetDKP.frameCounter))

	local txt = AceGUI:Create("Label")
	txt:SetText(text)
	txt:SetRelativeWidth(1)
	f:AddChild(txt)

	local button1 = AceGUI:Create("Button")
	button1:SetText(onetxt)
	button1:SetRelativeWidth(0.5)
	button1:SetCallback("OnClick", one)
	f:AddChild(button1)

	local button2 = AceGUI:Create("Button")
	button2:SetText(twotxt)
	button2:SetRelativeWidth(0.5)
	button2:SetCallback("OnClick", two)
	f:AddChild(button2)

	return f
end


function GoogleSheetDKP:createThreeDialogFrame(title, text, onetxt, one, twotxt, two, threetxt, three)
	if not GoogleSheetDKP.frameCounter then GoogleSheetDKP.frameCounter = 0 end
    GoogleSheetDKP.frameCounter = GoogleSheetDKP.frameCounter + 1

	local AceGUI = LibStub("AceGUI-3.0")

	local f = AceGUI:Create("Window")
	f:SetTitle(title)
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(400)
	f:SetHeight(150)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- close on escape
	_G["GoogleSheetDKPGoogleSheetDKP.threedialogframe" .. tostring(GoogleSheetDKP.frameCounter)] = f.frame
	tinsert(UISpecialFrames, "GoogleSheetDKPGoogleSheetDKP.threedialogframe" .. tostring(GoogleSheetDKP.frameCounter))

	local txt = AceGUI:Create("Label")
	txt:SetText(text)
	txt:SetRelativeWidth(1)
	f:AddChild(txt)

	local button1 = AceGUI:Create("Button")
	button1:SetText(onetxt)
	button1:SetRelativeWidth(0.33)
	button1:SetCallback("OnClick", function(widget)
		one(widget)
	end)
	f:AddChild(button1)

	local button2 = AceGUI:Create("Button")
	button2:SetText(twotxt)
	button2:SetRelativeWidth(0.33)
	button2:SetCallback("OnClick", function(widget)
		two(widget)
	end)
	f:AddChild(button2)

	local button3 = AceGUI:Create("Button")
	button3:SetText(threetxt)
	button3:SetRelativeWidth(0.33)
	button3:SetCallback("OnClick", function(widget)
		three(widget)
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

	-- only if not already shown
	if GoogleSheetDKP.attendanceframe then
		return nil
	end

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

	GoogleSheetDKP.attendanceframe = GoogleSheetDKP:createThreeDialogFrame(L["Attendance"], L["Shall I take Raid Attendance now?"], L["Yes"], yes, L["Later"], later, L["Not this session"], no)
	GoogleSheetDKP.attendanceframe:Show()
end

function GoogleSheetDKP:askToRequestSyncCrash()
	-- need to do this by timer. There seems to be no Event for "Interface is fully loaded and ready to handle GUI"
	GoogleSheetDKP:ScheduleTimer(function()
		local yes = function() GoogleSheetDKP:sendSyncRequest() GoogleSheetDKP.resyncFrame:Hide() end
		local no = function() GoogleSheetDKP.resyncFrame:Hide() end
		GoogleSheetDKP.resyncFrame = GoogleSheetDKP:createTwoDialogFrame(L["Addon crashed"], L["It seems the addon has crashed. Request sync from other users?"], L["Yes"], yes, L["No"], no)
		GoogleSheetDKP.resyncFrame:Show()
	end, 10)
end
