local L = LibStub("AceLocale-3.0"):NewLocale("GoogleSheetDKP", "deDE", false)

if L then

L["Language"] = "Sprache"
L["Language for outputs"] = "Ausgabesprache"

L["Debug"] = "Debug"

-- notifications

L["Usage: |cFF00CCFF/gsdkp |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"] = "Benutzung: |cFF00CCFF/dmb |cFFA335EE[Schwert der 1000 Wahrheiten]|r startet die Gebote"
L["Usage: |cFF00CCFF/gsdkp|r to open the configuration window, including import and export functions"] = "Benutzung: |cFF00CCFF/dmb config|r öffnet das Konfigurationsmenü inkl. Import und Export"

-- load default outputs 
for k,v in pairs(GoogleSheetDKP.outputLocales["deDE"]) do L[k] = v end

end -- if L then
