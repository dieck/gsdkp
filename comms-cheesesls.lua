
-- share information between GoogleSheetDKP and CheeseSLS Client

function GoogleSheetDKP:OnCommReceivedCSLS(prefix, message, distribution, sender)
	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)

	local success, d = self:Deserialize(message);

	-- every thing else get handled if (if not disabled)
	if not success then
		self:Debug("ERROR: " .. distribution .. " message from " .. sender .. ": cannot be deserialized")
		return
	end

	if d["command"] == "DKP_REQUEST" then
		-- if querying allowed, answer to user
		if self.db.profile.query_raid or self.db.profile.query_external then
			self:sendDKPResult(sender)
		end
	end
end

-- send out "new" loot to other CheeseSLSLootTracker

function GoogleSheetDKP:sendDKPResult(player)
	local commmsg = { command = "DKP_RESULT", playerName = player, dkp = self.db.profile.current[player] }
	-- we might want to use this in near-realtime. so, let's go for QoS for a quick turnaround
	self:SendCommMessage(self.commPrefixCSLS, self:Serialize(commmsg), "RAID", nil, "ALERT")
end
