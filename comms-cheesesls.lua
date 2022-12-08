
-- share information between GoogleSheetDKP and CheeseSLS Client

function GoogleSheetDKP:OnCommReceivedCSLS(prefix, message, distribution, sender)
	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)

	local success, d = GoogleSheetDKP:Deserialize(message);

	-- every thing else get handled if (if not disabled)
	if not success then
		GoogleSheetDKP:Debug("ERROR: " .. distribution .. " message from " .. sender .. ": cannot be deserialized")
		return
	end

	if d["command"] == "DKP_REQUEST" then
		-- if querying allowed, answer to user
		if GoogleSheetDKP.db.profile.query_raid or GoogleSheetDKP.db.profile.query_external then
			GoogleSheetDKP:sendDKPResult(sender)
		end
	end
end

-- send out "new" loot to other CheeseSLSLootTracker

function GoogleSheetDKP:sendDKPResult(player)
	local commmsg = { command = "DKP_RESULT", playerName = player, dkp = GoogleSheetDKP.db.profile.current[player] }
	-- we might want to use this in near-realtime. so, let's go for QoS for a quick turnaround
	GoogleSheetDKP:SendCommMessage(GoogleSheetDKP.commPrefixCSLS, GoogleSheetDKP:Serialize(commmsg), "RAID", nil, "ALERT")
end
