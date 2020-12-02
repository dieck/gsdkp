local L = LibStub("AceLocale-3.0"):NewLocale("GoogleSheetDKP", "enUS", true)

if L then


L["Language"] = "Language"
L["Language for outputs"] = "Language for outputs"

L["Debug"] = "Debug"

L["Usage: |cFF00CCFF/dmb |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"] = "Usage: |cFF00CCFF/dmb |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"
L["Usage: |cFF00CCFF/dmb config|r to open the configuration window"] = "Usage: |cFF00CCFF/dmb config|r to open the configuration window"

-- load default outputs 
for k,v in pairs(GoogleSheetDKP.outputLocales["enUS"]) do L[k] = v end

end -- if L then




