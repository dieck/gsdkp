local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)


-- import priorities 
function GoogleSheetDKP:Import(info, value)

	GoogleSheetDKP.db.profile.current = {}
	GoogleSheetDKP.db.profile.history = {}
	
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
				GoogleSheetDKP:Print("Incorrect IMPORT format. Did you copy the headers? Please try again.")
				return nil
			end
			for hnum in string.gmatch(sumhd, "%d+") do
				GoogleSheetDKP.db.profile.nexthistory = tonumber(hnum)+1
			end	
			GoogleSheetDKP:Debug("Next History entry will be " .. GoogleSheetDKP.db.profile.nexthistory)
			
		else
			-- handle all following lines as content
			if not (line == nil or strtrim(line) == '') then
				GoogleSheetDKP:Debug("Importing... " .. line) 
				GoogleSheetDKP:ImportLine(line)
			end	
		end
	
	end
	
end


function GoogleSheetDKP:ImportLine(line)
	-- It seems the import field does change tabs to multiple spaces. 
	-- So, resorting to replacing all multi space (and tabs, while we're at it) by &, and splitting by that
	-- ugly, but working...
	
	local linetsv = string.gsub(line, "[\t]+", "&")
	linetsv = string.gsub(linetsv, "%s%s+", "&")

	-- will only need user and dkp
	local user, _, dkp, _, _ = strsplit("&", linetsv)		

	GoogleSheetDKP.db.profile.current[user] = tonumber(dkp)
end


function GoogleSheetDKP:Export()
	local r = ""

	for hnum,h in pairsByKeys(GoogleSheetDKP.db.profile.history) do
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

	if r == "" then r = "-no history data-" end

	return r
end

function GoogleSheetDKP:Output(msg)
	if UnitInRaid("player") then
		SendChatMessage(msg, "RAID")
	else
		if UnitInParty("player") then
			SendChatMessage(msg, "PARTY")
		else
			GoogleSheetDKP:Print(msg)
		end
	end
end


-- add history entry for an Item
function GoogleSheetDKP:Item(name, change, itemLink)
	if itemLink == nil then
		GoogleSheetDKP:Debug("No Itemlink given for item dkp")
		return nil 
	end
	
	-- itemLink looks like |cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r
	local id = itemLink:match("|Hitem:(%d+):")
	if id then
		return GoogleSheetDKP:Change(name, change, "Item", id .. ": " .. itemLink)
	else
		GoogleSheetDKP:Debug("Could not identify Item ID")
		return nil
	end
end

-- add history entry for all raid members
function GoogleSheetDKP:RaidChange(change, cause, comment)
	if GetNumGroupMembers() == 0 then 
		GoogleSheetDKP:Print("Not in a group.") 
		return nil
	end
	local names = {}
	
	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		table.insert(names, name)
	end
	-- alphabetical order
	table.sort(names)
	local changes = true
	for i,name in ipairs(names) do	
		-- silent Change
		local change = GoogleSheetDKP:Change(name, change, cause, comment, true)
		changes = changes and change
	end
	chg = "DKP change for the whole raid: " .. change .. " for " .. cause
	if comment then chg = chg .. " / " .. comment end
	SendChatMessage(chg, "RAID")
	return changes
end

-- add initial DKP for new players
function GoogleSheetDKP:RaidInit()
	if GetNumGroupMembers() == 0 then 
		GoogleSheetDKP:Print("Not in a group.") 
		return nil
	end
	local names = {}
	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		if GoogleSheetDKP.db.profile.current[name] == nil then
			table.insert(names, name)
		end
	end
	-- alphabetical order
	table.sort(names)
	local changes = true
	for i,name in ipairs(names) do
		GoogleSheetDKP.db.profile.current[name] = 0
		GoogleSheetDKP:Print("New user " .. name .. " added.")
		-- silent Change
		local change = GoogleSheetDKP:Change(name, GoogleSheetDKP.db.profile.create_new_dkp, "Initial", "Initial DKP from GoogleSheetDKP creation", true)
		changes = changes and change
	end
	chg = "Initialized new characters in raid with Start DKP (" .. GoogleSheetDKP.db.profile.create_new_dkp .. "DKP): " .. table.concat(names, ", ")
	SendChatMessage(chg, "RAID")
	return changes
end


-- add single history entry
function GoogleSheetDKP:Change(name, change, cause, comment, silent)
	-- enable Chat Log for these actions
	local isLogging = LoggingChat()
	if GoogleSheetDKP.db.profile.chatlog and not isLogging then LoggingChat(1) end

	if name == nil then
		GoogleSheetDKP:Debug("No user given for Change request")
		return nil
	end
	
	-- check if user exists
	if GoogleSheetDKP.db.profile.current[name] == nil then
		
		if GoogleSheetDKP.db.profile.create_new_users then
			GoogleSheetDKP.db.profile.current[name] = 0
			GoogleSheetDKP:Print("New user " .. name .. " added.")
			GoogleSheetDKP:Change(name, GoogleSheetDKP.db.profile.create_new_dkp, "Initial", "Initial DKP from GoogleSheetDKP creation", silent)
		else
			GoogleSheetDKP:Print("User " .. name .. " unknown and new user creation is not allowed.")
			return nil
		end
		
	end

	if cause == nil then
		GoogleSheetDKP:Debug("No cause given for Change request")
		return nil
	end

	if change == nil or not tonumber(change) then
		GoogleSheetDKP:Debug("Could not determine value for DKP change")
		return nil
	end

	GoogleSheetDKP.db.profile.history[GoogleSheetDKP.db.profile.nexthistory] = {
		name = name,
		date = date("%d.%m.%Y"),
		time = date("%H:%M:%S"),
		change = change,
		cause = cause,
		comment = comment
	}
	
	newdkp = GoogleSheetDKP.db.profile.current[name] + tonumber(change)
	if newdkp < 0 and not GoogleSheetDKP.db.profile.negative_allowed then newdkp = 0 end
	GoogleSheetDKP.db.profile.current[name] = newdkp
	
	hist = "New DKP entry [" .. GoogleSheetDKP.db.profile.nexthistory .. "]: " .. change .. "DKP to " .. name .. " for " .. cause
	if comment then hist = hist .. " / " .. comment end
	hist = hist .. " (has now " .. newdkp .. "DKP)"
		
	GoogleSheetDKP:Print(hist)
	
	
	if not silent and GoogleSheetDKP.db.profile.output_raid then
		SendChatMessage(hist, "RAID")
	end
	if not silent and GoogleSheetDKP.db.profile.output_user then
		SendChatMessage(hist, "WHISPER", nil, name)
	end
	
	GoogleSheetDKP.db.profile.nexthistory = GoogleSheetDKP.db.profile.nexthistory + 1

	-- set timer to remind to reload, to store data (3min after last change)
	if GoogleSheetDKP.reminderTimer ~= nil then
		GoogleSheetDKP:CancelTimer(GoogleSheetDKP.reminderTimer)
	end
	GoogleSheetDKP.reminderTimer = GoogleSheetDKP:ScheduleTimer("ReloadReminder", 180)	

	return true
end

function GoogleSheetDKP:GetDKP(name)
	return GoogleSheetDKP.db.profile.current[name]
end


function GoogleSheetDKP:ReloadReminder()
	-- print reminder
	GoogleSheetDKP:Print("REMINDER: You may want to consider doing a /reload, to store history DKP data into the saved variables, in case your WoW crashes.")
	
	-- and remind again every 5min, until reloaded
	if GoogleSheetDKP.reminderTimer ~= nil then
		GoogleSheetDKP:CancelTimer(GoogleSheetDKP.reminderTimer)
	end
	GoogleSheetDKP.reminderTimer = GoogleSheetDKP:ScheduleTimer("ReloadReminder", 300)	
	
end


function GoogleSheetDKP:CHAT_MSG_WHISPER(event, text, sender)
	
	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)
	
	if GoogleSheetDKP.db.profile.query_external then

		if text == "dkp" then 
		
			if GoogleSheetDKP.db.profile.current[sender] then
				SendChatMessage("You got " .. GoogleSheetDKP.db.profile.current[sender] .. " DKP.", "WHISPER", nil, sender)
			else
				SendChatMessage("Found no DKP for your character.", "WHISPER", nil, sender)
			end
			
		end
		-- no current bidding
		return nil
	end
	
end




