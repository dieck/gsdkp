local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)
local deformat = LibStub("LibDeformat-3.0")

function GoogleSheetDKP:OnCommReceived(prefix, message, distribution, sender)
	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)

	-- ignore own messages
	if sender == UnitName("player") then return end

	-- d = deserialized
	local success, d = GoogleSheetDKP:Deserialize(message);

	-- every thing else get handled if (if not disabled)
	if not success then
		GoogleSheetDKP:Debug("ERROR: " .. distribution .. " message from " .. sender .. ": cannot be deserialized")
		return
	end

	if GoogleSheetDKP.commUUIDseen[d["uuid"]] then
		GoogleSheetDKP:Debug("received comm " .. d["uuid"] .. ": already seen, ignoring " .. d["command"] .. " from " .. sender)
		return
	end
	GoogleSheetDKP.commUUIDseen[d["uuid"]] = time()
	
	GoogleSheetDKP:Debug("received comm " .. d["uuid"] .. ": " .. d["command"] .. " from " .. sender)


	local fourhoursago = time() - 4*60*60

	-- remove entries that are too old
	if GoogleSheetDKP.db.profile.ignoreSender[sender] and GoogleSheetDKP.db.profile.ignoreSender[sender] < fourhoursago then
		GoogleSheetDKP.db.profile.ignoreSender[sender] = nil
	end
	if GoogleSheetDKP.db.profile.acceptSender[sender] and GoogleSheetDKP.db.profile.acceptSender[sender] < fourhoursago then
		GoogleSheetDKP.db.profile.acceptSender[sender] = nil
	end


	if d["command"] == "SYNC_REQUEST" then
		GoogleSheetDKP.latestSeenRemoteData = d["historytimestamp"]

		-- send offer if my data is newer
		if GoogleSheetDKP.db.profile.historytimestamp > d["historytimestamp"] or GoogleSheetDKP.db.profile.nexthistory > d["nexthistory"] then
			GoogleSheetDKP:sendSyncOffer()

		else
			GoogleSheetDKP:Debug("Got SYNC_REQUEST, but my data is not newer, so I won't answer. "
				.. tostring(GoogleSheetDKP.db.profile.historytimestamp) .. " vs. " .. tostring(d["historytimestamp"]) .. " // "
				.. tostring(GoogleSheetDKP.db.profile.nexthistory) .. " vs. " .. tostring(d["nexthistory"]) )

			--debug GoogleSheetDKP:sendSyncOffer()


			-- if I don't find an even newer OFFER during the next 10sec, I should ask my user if they want to get this offer from the original sender
			if not GoogleSheetDKP.syncRequestTimer then
				GoogleSheetDKP.syncRequestTimer = GoogleSheetDKP:ScheduleTimer(function()
					local yes = function() GoogleSheetDKP:sendSyncRequest() GoogleSheetDKP.resyncFrame:Hide() GoogleSheetDKP.syncRequestTimer = nil end
					local no = function() GoogleSheetDKP.resyncFrame:Hide() end
					if GoogleSheetDKP.latestSeenRemoteData < GoogleSheetDKP.db.profile.historytimestamp then
						GoogleSheetDKP.resyncFrame = GoogleSheetDKP:createTwoDialogFrame(L["Newer data"], L["Newer data is available at other users. Request sync?"], L["Yes"], yes, L["No"], no)
						GoogleSheetDKP.resyncFrame:Show()
					end
				end, 10)
			end
		end
		return
	end


	if d["command"] == "SYNC_OFFER" then
		GoogleSheetDKP.latestSeenRemoteData = d["historytimestamp"]

		-- if sender is already ignore: do nothing
		if GoogleSheetDKP.db.profile.ignoreSender[sender] then return end

		-- if sender is whitelisted or not seen before:
		-- wait for 10 seconds for other incoming offers, and present the newest one to accept
		if d["historytimestamp"] > GoogleSheetDKP.latestSyncOfferTime then
			GoogleSheetDKP.latestSyncOfferTime = d["historytimestamp"]
			GoogleSheetDKP.latestSyncOffer = { d = d, sender = sender }
		end

		if not GoogleSheetDKP.syncOfferTimer then
			GoogleSheetDKP.syncOfferTimer = GoogleSheetDKP:ScheduleTimer(GoogleSheetDKP.handleSyncOffer, 10)
		end

	end

	if d["command"] == "CHANGE" then
		-- if sender is already ignore: do nothing
		if GoogleSheetDKP.db.profile.ignoreSender[sender] then return end

		-- if sender is already whitelisted: accept and store
		if GoogleSheetDKP.db.profile.acceptSender[sender] then
			GoogleSheetDKP:Debug("Received CHANGE from accepted users, will enter.")
			local data = d["data"]
			GoogleSheetDKP:Change(data["name"], data["change"], data["cause"], data["comment"], data["silent"], data["date"], data["time"], sender)
			return
		end

		-- else request and handle later
		local accept = function(widget)
			GoogleSheetDKP.db.profile.acceptSender[widget.parent.paramSender] = time()
			GoogleSheetDKP:OnCommReceived(widget.parent.paramPrefix, widget.parent.paramMessage, widget.parent.paramDistribution, widget.parent.paramSender)
		end
		local ignore = function(widget)
			GoogleSheetDKP.db.profile.ignoreSender[widget.parent.paramSender] = time()
		end

		local f = GoogleSheetDKP:createTwoDialogFrame(L["Incoming Data"], L["sender has send a dkp change."](sender), L["Accept Sender for 4 hours"], accept, L["Ignore Sender for 4 hours"], ignore)
		f.paramPrefix = prefix
		f.paramMessage = message
		f.paramDistribution = distribution
		f.paramSender = sender
		f:Show()
	end

end

function GoogleSheetDKP:handleSyncOffer()
	local storedata = false
	local sender = GoogleSheetDKP.latestSyncOffer["sender"]
	local d = GoogleSheetDKP.latestSyncOffer["d"]

	-- if sender is whitelisted and offered data is newer: take it
	if GoogleSheetDKP.db.profile.acceptSender[sender] and GoogleSheetDKP.db.profile.historytimestamp < d["historytimestamp"] then
		GoogleSheetDKP:Debug("Received SYNC_OFFER from accepted sender " .. sender .. " with newer data. Will overwrite existing data.")
		storedata = true
	end

	if GoogleSheetDKP.latestSyncOfferAccept[sender] then
		GoogleSheetDKP:Debug("Received SYNC_OFFER from unknown sender " .. sender .. " that was accepted. Will overwrite existing data.")
		storedata = true
	end

	if storedata then
		-- I am keeping backups... Will be cleaned up when doing a normal manual import
		-- currently, no options to recover from gui. Use "/dump GoogleSheetDKP.db.profile.backups" and dig in ;)
		local curtime = time()
		if not GoogleSheetDKP.db.profile.backups then GoogleSheetDKP.db.profile.backups = {} end
		GoogleSheetDKP.db.profile.backups[curtime] = {
			current = GoogleSheetDKP.db.profile.current,
			history = GoogleSheetDKP.db.profile.history,
			historytimestamp = GoogleSheetDKP.db.profile.historytimestamp,
			nexthistory = GoogleSheetDKP.db.profile.nexthistory,
		}
		-- so, let's overwrite
		GoogleSheetDKP.db.profile.current = d["current"]
		GoogleSheetDKP.db.profile.history = d["history"]
		GoogleSheetDKP.db.profile.historytimestamp = d["historytimestamp"]
		GoogleSheetDKP.db.profile.nexthistory = d["nexthistory"]

	else

		GoogleSheetDKP.latestSyncOfferAccept = {}

		-- else request and handle later
		local accept = function(widget)
			GoogleSheetDKP.latestSyncOfferAccept[widget.parent.paramSender] = time()
			GoogleSheetDKP:handleSyncOffer()
			widget.parent:Hide()
		end
		local decline = function(widget)
			-- do nothing
			widget.parent:Hide()
		end

		local txt = L["sender has offered full DKP list."](sender)

		if GoogleSheetDKP.db.profile.historytimestamp > d["historytimestamp"] then
			txt = txt .. " " .. L["WARNING: DATA IS OLDER THAN EXISTING."]
		end

		local f = GoogleSheetDKP:createTwoDialogFrame(L["Incoming Data"], txt, L["Accept"], accept, L["Decline"], decline)
		f.paramSender = sender
		f:Show()
	end


end

-- send out "new" loot to other CheeseSLSLootTracker

function GoogleSheetDKP:sendSyncRequest()
	local commmsg = {
		command = "SYNC_REQUEST",
		version = GoogleSheetDKP.commVersion,
		uuid = GoogleSheetDKP:UUID(),
		nexthistory = GoogleSheetDKP.db.profile.nexthistory,
		historytimestamp = GoogleSheetDKP.db.profile.historytimestamp,
	}
	GoogleSheetDKP:Debug("send sync request " .. commmsg["uuid"])
	GoogleSheetDKP:SendCommMessage(GoogleSheetDKP.commPrefix, GoogleSheetDKP:Serialize(commmsg), "RAID", nil, "NORMAL")
	if GoogleSheetDKP.db.profile.debug then GoogleSheetDKP:SendCommMessage(GoogleSheetDKP.commPrefix, GoogleSheetDKP:Serialize(commmsg), "GUILD", nil, "NORMAL") end
end

function GoogleSheetDKP:sendSyncOffer()
	local commmsg = {
		command = "SYNC_OFFER",
		version = GoogleSheetDKP.commVersion,
		uuid = GoogleSheetDKP:UUID(),
		nexthistory = GoogleSheetDKP.db.profile.nexthistory,
		historytimestamp = GoogleSheetDKP.db.profile.historytimestamp,
		history = GoogleSheetDKP.db.profile.history,
		current = GoogleSheetDKP.db.profile.current,
	}
	GoogleSheetDKP:Debug("send sync offer " .. commmsg["uuid"])
	GoogleSheetDKP:SendCommMessage(GoogleSheetDKP.commPrefix, GoogleSheetDKP:Serialize(commmsg), "RAID", nil, "NORMAL")
	if GoogleSheetDKP.db.profile.debug then GoogleSheetDKP:SendCommMessage(GoogleSheetDKP.commPrefix, GoogleSheetDKP:Serialize(commmsg), "GUILD", nil, "NORMAL") end
end

function GoogleSheetDKP:sendChange(data)
	local latestEntryId = GoogleSheetDKP.db.profile.nexthistory or 0
	local commmsg = {
		command = "CHANGE",
		version = GoogleSheetDKP.commVersion,
		uuid = GoogleSheetDKP:UUID(),
		data = data,
		timestamp = time()
	}
	GoogleSheetDKP:Debug("send sync change " .. commmsg["uuid"])
	GoogleSheetDKP:SendCommMessage(GoogleSheetDKP.commPrefix, GoogleSheetDKP:Serialize(commmsg), "RAID", nil, "NORMAL")
	if GoogleSheetDKP.db.profile.debug then GoogleSheetDKP:SendCommMessage(GoogleSheetDKP.commPrefix, GoogleSheetDKP:Serialize(commmsg), "GUILD", nil, "NORMAL") end
end
