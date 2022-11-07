local L = {}

L["DKP change for the whole raid: change for cause"] = function(change, cause, comment)
	local chg = "DKP change for the whole raid: " .. change .. " for " .. cause
	if comment then chg = chg .. " / " .. comment end
	return chg
end

L["Initialized new characters in raid with Start DKP"] = function(newdkp, names)
	local chg = "Initialized new characters in raid with Start DKP (" .. newdkp .. "DKP): " .. table.concat(names, ", ")
	return chg
end

L["New DKP entry [id]: change DKP to name for cause / comment (has now newdkp DKP)"] = function(nexthistory, change, name, cause, comment, newdkp)
	local hist = "New DKP entry [" .. nexthistory .. "]: " .. change .. "DKP to " .. name .. " for " .. cause
	if comment then hist = hist .. " / " .. comment end
	hist = hist .. " (has now " .. newdkp .. "DKP)"
	return hist
end

L["(by API from commSender)"] = function(commSender) return "(by API from " .. commSender .. ")" end


-- end
GoogleSheetDKP.outputLocales["enUS"] = L

