local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)
local deformat = LibStub("LibDeformat-3.0")

function GoogleSheetDKP:OnCommReceived(prefix, message, distribution, sender)
	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)

	-- ignore own messages
	if sender == UnitName("player") then return end

	-- d = deserialized
	local success, d = self:Deserialize(message);

	-- every thing else get handled if (if not disabled)
	if not success then
		self:Debug("ERROR: " .. distribution .. " message from " .. sender .. ": cannot be deserialized")
		return
	end

	if self.commUUIDseen[d["uuid"]] then
		self:Debug("received comm " .. d["uuid"] .. ": already seen, ignoring " .. d["command"] .. " from " .. sender)
		return
	end
	self.commUUIDseen[d["uuid"]] = time()

	self:Debug("received comm " .. d["uuid"] .. ": " .. d["command"] .. " from " .. sender)


	local fourhoursago = time() - 4*60*60

	-- remove entries that are too old
	if self.db.profile.ignoreSender[sender] and self.db.profile.ignoreSender[sender] < fourhoursago then
		self.db.profile.ignoreSender[sender] = nil
	end
	if self.db.profile.acceptSender[sender] and self.db.profile.acceptSender[sender] < fourhoursago then
		self.db.profile.acceptSender[sender] = nil
	end


	if d["command"] == "SYNC_REQUEST" then
		self.latestSeenRemoteData = d["historytimestamp"]

		-- send offer if my data is newer
		if self.db.profile.historytimestamp > d["historytimestamp"] or self.db.profile.nexthistory > d["nexthistory"] then
			self:sendSyncOffer()

		else
			self:Debug("Got SYNC_REQUEST, but my data is not newer, so I won't answer. "
				.. tostring(self.db.profile.historytimestamp) .. " vs. " .. tostring(d["historytimestamp"]) .. " // "
				.. tostring(self.db.profile.nexthistory) .. " vs. " .. tostring(d["nexthistory"]) )

			--debug self:sendSyncOffer()


			-- if I don't find an even newer OFFER during the next 10sec, I should ask my user if they want to get this offer from the original sender
			if not self.syncRequestTimer then
				self.syncRequestTimer = self:ScheduleTimer(function()
					local yes = function() GoogleSheetDKP:sendSyncRequest() GoogleSheetDKP.resyncFrame:Hide() GoogleSheetDKP.syncRequestTimer = nil end
					local no = function() GoogleSheetDKP.resyncFrame:Hide() end
					if GoogleSheetDKP.latestSeenRemoteData < GoogleSheetDKP.db.profile.historytimestamp then
						GoogleSheetDKP.resyncFrame = GoogleSheetDKP:createTwoDialogFrame(L["Newer data"], L["Newer data is available at other users. Request sync?"], L["Yes"], yes, L["No"], no)
					end
				end, 10)
			end
		end
		return
	end


	if d["command"] == "SYNC_OFFER" then
		self.latestSeenRemoteData = d["historytimestamp"]

		-- if sender is already ignore: do nothing
		if self.db.profile.ignoreSender[sender] then return end

		-- if sender is whitelisted or not seen before:
		-- wait for 10 seconds for other incoming offers, and present the newest one to accept
		if d["historytimestamp"] > self.latestSyncOfferTime then
			self.latestSyncOfferTime = d["historytimestamp"]
			self.latestSyncOffer = { d = d, sender = sender }
		end

		if not self.syncOfferTimer then
			self.syncOfferTimer = self:ScheduleTimer(self.handleSyncOffer, 10)
		end

	end

	if d["command"] == "CHANGE" then
		-- if sender is already ignore: do nothing
		if self.db.profile.ignoreSender[sender] then return end

		-- if sender is already whitelisted: accept and store
		if self.db.profile.acceptSender[sender] then
			self:Debug("Received CHANGE from accepted users, will enter.")
			local data = d["data"]
			self:Change(data["name"], data["change"], data["cause"], data["comment"], data["silent"], data["date"], data["time"], sender)
			return
		end

		-- else request and handle later
		local accept = function(widget)
			self.db.profile.acceptSender[widget.parent:GetUserData("sender")] = time()
			local data = widget.parent:GetUserData("data")
			self:Change(data["name"], data["change"], data["cause"], data["comment"], data["silent"], data["date"], data["time"], widget.parent:GetUserData("sender"))
		end
		local ignore = function(widget)
			self.db.profile.ignoreSender[widget.parent:GetUserData("sender")] = time()
		end

		local f = self:createTwoDialogFrame(L["Incoming Data"], L["sender has send a dkp change."](sender), L["Accept Sender for 4 hours"], accept, L["Ignore Sender for 4 hours"], ignore)
		f:SetUserData("data", d["data"])
		f:SetUserData("prefix", prefix)
		f:SetUserData("message", message)
		f:SetUserData("distribution", distribution)
		f:SetUserData("sender", sender)
	end

end

function GoogleSheetDKP:handleSyncOffer()
	local storedata = false
	local sender = self.latestSyncOffer["sender"]
	local d = self.latestSyncOffer["d"]

	-- if sender is whitelisted and offered data is newer: take it
	if self.db.profile.acceptSender[sender] and self.db.profile.historytimestamp < d["historytimestamp"] then
		self:Debug("Received SYNC_OFFER from accepted sender " .. sender .. " with newer data. Will overwrite existing data.")
		storedata = true
	end

	if self.latestSyncOfferAccept[sender] then
		self:Debug("Received SYNC_OFFER from unknown sender " .. sender .. " that was accepted. Will overwrite existing data.")
		storedata = true
	end

	if storedata then
		-- I am keeping backups... Will be cleaned up when doing a normal manual import
		-- currently, no options to recover from gui. Use "/dump GoogleSheetDKP.db.profile.backups" and dig in ;)
		local curtime = time()
		if not self.db.profile.backups then self.db.profile.backups = {} end
		self.db.profile.backups[curtime] = {
			current = self.db.profile.current,
			history = self.db.profile.history,
			historytimestamp = self.db.profile.historytimestamp,
			nexthistory = self.db.profile.nexthistory,
		}
		-- so, let's overwrite
		self.db.profile.current = d["current"]
		self.db.profile.history = d["history"]
		self.db.profile.historytimestamp = d["historytimestamp"]
		self.db.profile.nexthistory = d["nexthistory"]

	else

		self.latestSyncOfferAccept = {}

		-- else request and handle later
		local accept = function(widget)
			self.latestSyncOfferAccept[widget.parent:GetUserData("sender")] = time()
			self:handleSyncOffer()
			widget.parent:Hide()
		end
		local decline = function(widget)
			-- do nothing
			widget.parent:Hide()
		end

		local txt = L["sender has offered full DKP list."](sender)

		if self.db.profile.historytimestamp > d["historytimestamp"] then
			txt = txt .. " " .. L["WARNING: DATA IS OLDER THAN EXISTING."]
		end

		local f = self:createTwoDialogFrame(L["Incoming Data"], txt, L["Accept"], accept, L["Decline"], decline)
		f:SetUserData("sender", sender)
	end


end

-- send out "new" loot to other CheeseSLSLootTracker

function GoogleSheetDKP:sendSyncRequest()
	local commmsg = {
		command = "SYNC_REQUEST",
		version = self.commVersion,
		uuid = self:UUID(),
		nexthistory = self.db.profile.nexthistory,
		historytimestamp = self.db.profile.historytimestamp,
	}
	self:Debug("send sync request " .. commmsg["uuid"])
	self:SendCommMessage(self.commPrefix, self:Serialize(commmsg), "RAID", nil, "NORMAL")
end

function GoogleSheetDKP:sendSyncOffer()
	local commmsg = {
		command = "SYNC_OFFER",
		version = self.commVersion,
		uuid = self:UUID(),
		nexthistory = self.db.profile.nexthistory,
		historytimestamp = self.db.profile.historytimestamp,
		history = self.db.profile.history,
		current = self.db.profile.current,
	}
	self:Debug("send sync offer " .. commmsg["uuid"])
	self:SendCommMessage(self.commPrefix, self:Serialize(commmsg), "RAID", nil, "NORMAL")
end

function GoogleSheetDKP:sendChange(data)
	local latestEntryId = self.db.profile.nexthistory or 0
	local commmsg = {
		command = "CHANGE",
		version = self.commVersion,
		uuid = self:UUID(),
		data = data,
		timestamp = time()
	}
	self:Debug("send sync change " .. commmsg["uuid"])
	self:SendCommMessage(self.commPrefix, self:Serialize(commmsg), "RAID", nil, "NORMAL")
end
