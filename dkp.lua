local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)


-- import priorities
function GoogleSheetDKP:Import(info, value)

	self.db.profile.current = {}
	self.db.profile.history = {}

	-- expected format: TAB separated values

	-- Name	Sum [5]	All Gain	Items
	-- Test	100	500	-200

	-- parse lines, and handle individually (ImportLine)
	local lines = { strsplit("\r\n", value) }
	local header = nil

	for k,line in pairs(lines) do

		if header == nil then
			-- parse first line as header
			header = strsplit("\r\n", value)
			local linetsv = string.gsub(header, "[\t]+", "&")
			linetsv = string.gsub(linetsv, "%s%s+", "&")

			-- will only need sum header to get number out of it
			local _, _, sumhd = strsplit("&", linetsv)
			if sumhd == nil then
				self:Print(L["Incorrect IMPORT format. Did you copy the headers? Please try again."])
				return nil
			end
			for hnum in string.gmatch(sumhd, "%d+") do
				self.db.profile.nexthistory = tonumber(hnum)+1
			end
			self:Debug("Next History entry will be " .. self.db.profile.nexthistory)
			self.db.profile.historytimestamp = time()

		else
			-- handle all following lines as content
			if not (line == nil or strtrim(line) == '') then
				self:Debug("Importing... " .. line)
				self:ImportLine(line)
			end
		end

	end

	self.db.profile.backups = {}
	self:sendSyncOffer()
end


function GoogleSheetDKP:ImportLine(line)
	-- It seems the import field does change tabs to multiple spaces.
	-- So, resorting to replacing all multi space (and tabs, while we're at it) by &, and splitting by that
	-- ugly, but working...

	local linetsv = string.gsub(line, "[\t]+", "&")
	linetsv = string.gsub(linetsv, "%s%s+", "&")

	-- will only need user and dkp
	local user, _, dkp, _, _ = strsplit("&", linetsv)

	self.db.profile.current[user] = tonumber(dkp)
end


function GoogleSheetDKP:Export()
	local r = ""

	for hnum,h in self:pairsByKeys(GoogleSheetDKP.db.profile.history) do
		local s = hnum .. "\t"

		s = s .. h["date"] .. "\t"
		s = s .. h["time"] .. "\t"
		s = s .. h["name"] .. "\t"
		s = s .. h["change"] .. "\t"
		s = s .. h["cause"] .. "\t"
		if h["comment"] == nil then
			s = s .. "-"
		else
			s = s .. h["comment"]
		end
		r = r .. s .. "\r\n"
	end

	if r == "" then r = L["-no history data-"] end

	return r
end

function GoogleSheetDKP:Output(msg)
	if UnitInRaid("player") then
		SendChatMessage(msg, "RAID")
	else
		if UnitInParty("player") then
			SendChatMessage(msg, "PARTY")
		else
			self:Print(msg)
		end
	end
end


-- add history entry for an Item
function GoogleSheetDKP:Item(name, change, itemLink)
	if itemLink == nil then
		self:Debug("No Itemlink given for item dkp")
		return nil
	end

	-- itemLink looks like |cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r
	local id = itemLink:match("|Hitem:(%d+):")
	if id then
		return self:Change(name, change, "Item", id .. ": " .. itemLink)
	else
		self:Debug("Could not identify Item ID")
		return nil
	end
end


-- copy table content (normal assignment will only do a pointer)
local function tcopy(src)
	local dest = {}
	for idx, val in pairs(src) do
		if type(val) == "table" then
			dest[idx] = tcopy(val)
		else
			dest[idx] = val
		end
	end
	return dest
end


-- find latest entry for an item in history
function GoogleSheetDKP:FindLastItem(itemLink)
	if itemLink == nil then
		self:Debug("No Itemlink given for requesting last item")
		return nil
	end

	local id = itemLink:match("|Hitem:(%d+):")
	if id then
		local search = id .. ": " .. itemLink
		local maxid = 0
		local maxhist = nil

		for hnum,h in self:pairsByKeys(self.db.profile.history) do

			if h.comment == search then

				if tonumber(maxid) < tonumber(hnum) then
					maxid = tonumber(hnum)
					maxhist = tcopy(h)
				end

			end

		end

		if maxid > 0 then
			return  maxhist
		end

	end

	-- no item found
	return nil
end

-- takes raid attendance, can be used later on for raidchange
function GoogleSheetDKP:Attendance(deletion)
	if GetNumGroupMembers() == 0 then
		self:Print(L["Not in a group."])
		return nil
	end

	if deletion ~= nil and deletion == "delete" then
		self:Print(L["Removed raid attendance list"])
		self.db.profile.raidattendance = nil
		return nil
	end

	local names = {}

	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		table.insert(names, name)
	end
	-- alphabetical order
	table.sort(names)

	self.db.profile.raidattendance = names
	self.db.profile.raidattendance_taken = time()
end

-- add history entry for all raid members
function GoogleSheetDKP:RaidChange(change, cause, comment)

	-- if raid attendance was not taken yet, take it now
	if self.db.profile.raidattendance == nil then
		self:Attendance()
	end

	-- still no raid attendance? then we're obviously not in a raid right now
	if self.db.profile.raidattendance == nil then
		-- RaidAttendance already printed "Not in a group"
		return nil
	end

	local changes = true
	for i,name in ipairs(self.db.profile.raidattendance) do
		-- silent Change
		local change = self:Change(name, change, cause, comment, true)
		changes = changes and change
	end
	local chg = L["DKP change for the whole raid: change for cause"](change, cause, comment)

	SendChatMessage(chg, "RAID")

	-- delete raidattendance (only used once)
	self.db.profile.raidattendance = nil

	return changes
end

-- add initial DKP for new players
function GoogleSheetDKP:RaidInit()
	if GetNumGroupMembers() == 0 then
		self:Print(L["Not in a group."])
		return nil
	end
	local names = {}
	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		if self.db.profile.current[name] == nil then
			table.insert(names, name)
		end
	end
	-- alphabetical order
	table.sort(names)
	local changes = true
	for i,name in ipairs(names) do
		self.db.profile.current[name] = 0
		self:Print(L["New user name added."](name))
		-- silent Change
		local change = self:Change(name, self.db.profile.create_new_dkp, "Initial", "Initial DKP from GoogleSheetDKP creation", true)
		changes = changes and change
	end
	local chg = L["Initialized new characters in raid with Start DKP"](self.db.profile.create_new_dkp, names)
	SendChatMessage(chg, "RAID")
	return changes
end


-- add single history entry
function GoogleSheetDKP:Change(name, change, cause, comment, silent, dt, tm, commSender)
	-- enable Chat Log for these actions
	local isLogging = LoggingChat()
	if self.db.profile.chatlog and not isLogging then LoggingChat(1) end

	if name == nil then
		self:Debug("No user given for Change request")
		return nil
	end

	-- check if user exists
	if self.db.profile.current[name] == nil then

		if self.db.profile.create_new_users then
			self.db.profile.current[name] = 0
			self:Print("New user " .. name .. " added.")
			if not commSender then
				-- do not create new users for API-incoming: first entry WILL BE INITIAL anyway!
				self:Change(name, self.db.profile.create_new_dkp, "Initial", "Initial DKP from GoogleSheetDKP creation", silent, commSender)
			end
		else
			self:Print(L["User name unknown and new user creation is not allowed."](name))
			return nil
		end

	end

	if cause == nil then
		self:Debug("No cause given for Change request")
		return nil
	end

	if change == nil or not tonumber(change) then
		self:Debug("Could not determine value for DKP change")
		return nil
	end

	local newhistory = {
		name = name,
		date = date("%d.%m.%Y"),
		time = date("%H:%M:%S"),
		change = change,
		cause = cause,
		comment = comment,
		silent = silent
	}
	if dt then newhistory["date"] = dt end
	if tm then newhistory["time"] = tm end

	self.db.profile.history[self.db.profile.nexthistory] = newhistory

	local newdkp = self.db.profile.current[name] + tonumber(change)
	if newdkp < 0 and not self.db.profile.negative_allowed then newdkp = 0 end
	self.db.profile.current[name] = newdkp

	local hist = L["New DKP entry [id]: change DKP to name for cause / comment (has now newdkp DKP)"](self.db.profile.nexthistory, change, name, cause, comment, newdkp)

	if commSender then
		self:Print(hist .. " " .. L["(by API from commSender)"](commSender))
	else
		self:Print(hist)

		if not silent and self.db.profile.output_raid then
			SendChatMessage(hist, "RAID")
		end
		if not silent and self.db.profile.output_user then
			SendChatMessage(hist, "WHISPER", nil, name)
		end

		-- if it didn't come in by comms, send out by comms
		self:sendChange(newhistory)
	end

	self.db.profile.nexthistory = self.db.profile.nexthistory + 1
	self.db.profile.historytimestamp = time()

	-- set timer to remind to reload, to store data (3min after last change)
	if self.reminderTimer ~= nil then
		self:CancelTimer(self.reminderTimer)
	end
	self.reminderTimer = self:ScheduleTimer("ReloadReminder", 180)

	self:askToTakeAttendance()

	return true
end

function GoogleSheetDKP:GetDKP(name)
	return self.db.profile.current[name]
end


function GoogleSheetDKP:ReloadReminder()
	-- print reminder
	self:Print(L["REMINDER: You may want to consider doing a /reload, to store history DKP data into the saved variables, in case your WoW crashes."])

	-- and remind again every 5min, until reloaded
	if self.reminderTimer ~= nil then
		self:CancelTimer(self.reminderTimer)
	end
	self.reminderTimer = self:ScheduleTimer("ReloadReminder", 300)

end


function GoogleSheetDKP:CHAT_MSG_WHISPER(event, text, sender)

	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)

	if self.db.profile.query_external then

		if text == "dkp" then

			if self.db.profile.current[sender] then
				SendChatMessage(L["You got current DKP."](self.db.profile.current[sender]), "WHISPER", nil, sender)
			else
				SendChatMessage(L["Found no DKP for your character."], "WHISPER", nil, sender)
			end

		end
		-- no current bidding
		return nil
	end

end




