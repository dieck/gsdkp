local L = LibStub("AceLocale-3.0"):NewLocale("GoogleSheetDKP", "deDE", false)

if L then

L["Language"] = "Sprache"
L["Language for outputs"] = "Ausgabesprache"

L["Debug"] = "Debug"

-- multiple

L["Yes"] = "Ja"
L["Later"] = "Später"
L["No"] = "Nein"
L["Accept"] = "Akzeptieren"
L["Decline"] = "Ablehnen"


-- core / configs

L["Raid"] = "Raid"
L["Accept queries for current DKP and list from Raid members"] = "Accept queries for current DKP and list from Raid members"
L["External"] = "External"
L["Accept queries for current DKP and list from all users"] = "Accept queries for current DKP and list from all users"
L["Raid"] = "Raid"
L["Output DKP changes to Raid"] = "Output DKP changes to Raid"
L["User"] = "User"
L["Output DKP changes to User"] = "Output DKP changes to User"
L["Language"] = "Language"
L["Language for outputs"] = "Language for outputs"
L["Create users"] = "Create users"
L["Accept changes for users without current DKP import"] = "Accept changes for users without current DKP import"
L["Start DKP"] = "Start DKP"
L["For new users, set this start DKP"] = "For new users, set this start DKP"
L["Start DKP: Please enter a number"] = "Start DKP: Please enter a number"
L["Allow negative"] = "Allow negative"
L["Allow DKP to go negative (otherwise stay at zero)"] = "Allow DKP to go negative (otherwise stay at zero)"
L["Chatlog"] = "Chatlog"
L["Starts chatlog with first change action"] = "Starts chatlog with first change action"
L["Capture Chat log for easier resolve of disputes and discussions about DKP after a raid"] = "Capture Chat log for easier resolve of disputes and discussions about DKP after a raid"
L["Attendence reminder"] = "Attendence reminder"
L["Remind to store attendance for later Raid DKP assignment"] = "Remind to store attendance for later Raid DKP assignment"
L["Copy & paste full Current DKP Tab from Google Doc here, including headers"] = "Copy & paste full Current DKP Tab from Google Doc here, including headers"
L["Import String"] = "Import String"
L["Copy & paste full Current DKP Tab from Google Doc here, including headers"] = "Copy & paste full Current DKP Tab from Google Doc here, including headers"
L["Be aware that the DKP table will be OVERWRITTEN and existing changes DELETED!"] = "Be aware that the DKP table will be OVERWRITTEN and existing changes DELETED!"
L["Export first, if you have current data!"] = "Export first, if you have current data!"
L["Export String"] = "Export String"
L["Copy full content and paste to Google Doc History tab, adding at the end"] = "Copy full content and paste to Google Doc History tab, adding at the end"
L["Sync"] = "Sync"
L["Always accept from"] = "Always accept from"
L["user (valid until date)"] = function(user, valid) return tostring(user) .. " (valid until " .. tostring(valid) .. ")" end
L["Clear accepted"] = "Clear accepted"
L["Always ignore from"] = "Always ignore from"
L["Clear ignored"] = "Clear ignored"
L["Request Sync (pull)"] = "Request Sync (pull)"
L["Offer Data (push)"] = "Offer Data (push)"
L["Help"] = "Help"
L["Quickstart:"] = "Quickstart:"
L["Copy Template https://bit.ly/GoogleSheetDKP"] = "Copy Template https://bit.ly/GoogleSheetDKP"
L["Import from Current DKP tab, Export to History Tab"] = "Import from Current DKP tab, Export to History Tab"
L["Usage:"] = "Usage:"
L["/gsdkp: opens overview GUI"] = "/gsdkp: opens overview GUI"
L["/gsdkp config: opens configuration view with Import/Export/Help"] = "/gsdkp config: opens configuration view with Import/Export/Help"
L["/gsdkp action: opens action menu for simplified usage of the next options:"] = "/gsdkp action: opens action menu for simplified usage of the next options:"
L["/gsdkp change NAME VALUE CAUSE [COMMENT]: commits manual DKP change"] = "/gsdkp change NAME VALUE CAUSE [COMMENT]: commits manual DKP change"
L["/gsdkp item NAME VALUE ITEMLINK: commits manual DKP change for Item awards. Value will *not* be negated! (Use e.g. -10 for costs)"] = "/gsdkp item NAME VALUE ITEMLINK: commits manual DKP change for Item awards. Value will *not* be negated! (Use e.g. -10 for costs)"
L["/gsdkp raidchange VALUE CAUSE [COMMENT]: commits DKP change to all current raid members (also /gsdkp raid)"] = "/gsdkp raidchange VALUE CAUSE [COMMENT]: commits DKP change to all current raid members (also /gsdkp raid)"
L["/gsdkp raidinit VALUE CAUSE [COMMENT]: commits DKP change to all current raid members (also /gsdkp init)"] = "/gsdkp raidinit VALUE CAUSE [COMMENT]: commits DKP change to all current raid members (also /gsdkp init)"
L["Please note: CAUSE can only be a single word, e.g. 'Item', 'Bonus', 'Participation', 'FirstKill'"] = "Please note: CAUSE can only be a single word, e.g. 'Item', 'Bonus', 'Participation', 'FirstKill'"
L["/gsdkp raidattendance: takes raid attendance to be used for next raidchange"] = "/gsdkp raidattendance: takes raid attendance to be used for next raidchange"
L["/gsdkp raidattendance delete: deletes stored raid attendance"] = "/gsdkp raidattendance delete: deletes stored raid attendance"
L["API:"] = "API:"
L["Google Sheet DKP can be used by other addons to manage DKP:"] = "Google Sheet DKP can be used by other addons to manage DKP:"
L["GoogleSheetDKP:GetDKP(name)"] = "GoogleSheetDKP:GetDKP(name)"
L["GoogleSheetDKP:Change(name, value, cause, comment)"] = "GoogleSheetDKP:Change(name, value, cause, comment)"
L["GoogleSheetDKP:RaidChange(value, cause, comment)"] = "GoogleSheetDKP:RaidChange(value, cause, comment)"
L["GoogleSheetDKP:RaidInit()"] = "GoogleSheetDKP:RaidInit()"
L["GoogleSheetDKP:Item(name, value, itemLink)"] = "GoogleSheetDKP:Item(name, value, itemLink)"
L["GoogleSheetDKP:RaidAttendance(['delete'])"] = "GoogleSheetDKP:RaidAttendance(['delete'])"


-- dkp

L["Incorrect IMPORT format. Did you copy the headers? Please try again."] = "Incorrect IMPORT format. Did you copy the headers? Please try again."
L["-no history data-"] = "-no history data-"

L["Not in a group."] = "Not in a group."
L["Removed raid attendance list"] = "Removed raid attendance list"

L["New user name added."] = function(name) return "New user " .. name .. " added." end

L["User name unknown and new user creation is not allowed."] = function(name) return "User " .. name .. " unknown and new user creation is not allowed." end

L["REMINDER: You may want to consider doing a /reload, to store history DKP data into the saved variables, in case your WoW crashes."] = "REMINDER: You may want to consider doing a /reload, to store history DKP data into the saved variables, in case your WoW crashes."

L["You got current DKP."] = function(current) return "You got " .. current .. " DKP." end
L["Found no DKP for your character."] = "Found no DKP for your character."


-- gui

L["No current DKP information."] = "No current DKP information."
L["Conf / Imp&Exp / Help"] = "Conf / Imp&Exp / Help"
L["Actions"] = "Actions"
L["Current DKP"] = "Current DKP"
L["Name"] = "Name"
L["DKP"] = "DKP"

L["Local History Information"] = "Local History Information"
L["ID"] = "ID"
L["Change"] = "Change"
L["Cause / Ref"] = "Cause / Ref"
L["DKP Overview"] = "DKP Overview"

L["Execute group action"] = function(group) return "Execute " .. group .. " action" end

L["/gsdkp item PLAYER DKP ITEM"] = "/gsdkp item PLAYER DKP ITEM"
L["API: GoogleSheetDKP:Item(player,dkp,item)"] = "API: GoogleSheetDKP:Item(player,dkp,item)"
L["For Item, DKP normally is negative"] = "For Item, DKP normally is negative"

L["/gsdkp raidchange DKP CAUSE [COMMENT]"] = "/gsdkp raidchange DKP CAUSE [COMMENT]"
L["Alternative: /gsdkp raid DKP CAUSE [COMMENT]"] = "Alternative: /gsdkp raid DKP CAUSE [COMMENT]"
L["API: GoogleSheetDKP:RaidChange(dkp,cause,comment)"] = "API: GoogleSheetDKP:RaidChange(dkp,cause,comment)"
L["You may use negative or positive DKP for changes"] = "You may use negative or positive DKP for changes"
L["*ALL raid members*"] = "*ALL raid members*"

L["/gsdkp raidinit"] = "/gsdkp raidinit"
L["Alternative: /gsdkp init"] = "Alternative: /gsdkp init"
L["API: GoogleSheetDKP:RaidInit()"] = "API: GoogleSheetDKP:RaidInit()"
L["*NEW raid members*"] = "*NEW raid members*"
L["See configuration"] = "See configuration"
L["Initial"] = "Initial"
L["Initial DKP from GoogleSheetDKP creation"] = "Initial DKP from GoogleSheetDKP creation"

L["/gsdkp change PLAYER DKP CAUSE [COMMENT]"] = "/gsdkp change PLAYER DKP CAUSE [COMMENT]"
L["API: GoogleSheetDKP:Change(player,dkp,cause,comment)"] = "API: GoogleSheetDKP:Change(player,dkp,cause,comment)"
L["You may use negative or positive DKP for changes"] = "You may use negative or positive DKP for changes"

L["/gsdkp attendance ['delete']"] = "/gsdkp attendance ['delete']"
L["Alternative: /gsdkp attend ['delete']"] = "Alternative: /gsdkp attend ['delete']"
L["API: GoogleSheetDKP:Attendance(['delete'])"] = "API: GoogleSheetDKP:Attendance(['delete'])"
L["delete"] = "delete"
L["Execute Action"] = "Execute Action"
L["User"] = "User"
L["You have to give a username"] = "You have to give a username"
L["-choose manually-"] = "-choose manually-"
L["Character"] = "Character"
L["DKP charge"] = "DKP charge"
L["Can only set numeric values for DKP"] = "Can only set numeric values for DKP"
L["Cause"] = "Cause"
L["You have to give a cause"] = "You have to give a cause"
L["Cause can only be one word"] = "Cause can only be one word"
L["Comment (optional)"] = "Comment (optional)"
L["You have to enter a value"] = "You have to enter a value"


-- yesno

L["Attendance"] = "Attendance"
L["Shall I take Raid Attendance now?"] = "Shall I take Raid Attendance now?"
L["Not this session"] = "Not this session"
L["Addon crashed"] = "Addon crashed"
L["It seems the addon has crashed. Request sync from other users?"] = "It seems the addon has crashed. Request sync from other users?"


-- comms

L["Newer data"] = "Newer data"
L["Newer data is available at other users. Request sync?"] = "Newer data is available at other users. Request sync?"

L["Incoming Data"] = "Incoming Data"
L["sender has send a dkp change."] = function(sender) return tostring(sender) .. " has send a dkp change." end
L["Accept Sender for 4 hours"] = "Accept Sender for 4 hours"
L["Ignore Sender for 4 hours"] = "Ignore Sender for 4 hours"

L["sender has offered full DKP list."] = function(sender) return tostring(sender) .. " has offered full DKP list." end
L["WARNING: DATA IS OLDER THAN EXISTING."] = "WARNING: DATA IS OLDER THAN EXISTING."

L["Incoming Data"] = "Incoming Data"



-- load default outputs
for k,v in pairs(GoogleSheetDKP.outputLocales["deDE"]) do L[k] = v end

end -- if L then
