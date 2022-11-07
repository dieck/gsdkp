local L = {}

L["DKP change for the whole raid: change for cause"] = function(change, cause, comment)
	local chg = "DKP-Eintrag für den ganzen Raid: " .. change .. " für " .. cause
	if comment then chg = chg .. " / " .. comment end
	return chg
end

L["Initialized new characters in raid with Start DKP"] = function(newdkp, names)
	local chg = "Initialisiere neue Spieler im Raid mit Start-DKP (" .. newdkp .. "DKP): " .. table.concat(names, ", ")
	return chg
end

L["New DKP entry [id]: change DKP to name for cause / comment (has now newdkp DKP)"] = function(nexthistory, change, name, cause, comment, newdkp)
	local hist = "Neuer DKP-Eintrag [" .. nexthistory .. "]: " .. change .. "DKP für " .. name .. " wegen " .. cause
	if comment then hist = hist .. " / " .. comment end
	hist = hist .. " (hat jetzt " .. newdkp .. "DKP)"
	return hist
end

L["(by API from commSender)"] = function(commSender) return "(per API von " .. commSender .. ")" end


-- end
GoogleSheetDKP.outputLocales["deDE"] = L
