local L = LibStub("AceLocale-3.0"):GetLocale("GoogleSheetDKP", true)

GoogleSheetDKP.commPrefix = "GSDKP-1.0-"
GoogleSheetDKP.commVersion = 20221107

GoogleSheetDKP.commPrefixCSLS = "GSDKPCSLS-1"

local defaults = {
  profile = {
    debug = false,
	chatlog = true,
	query_raid = true,
	query_external = true,
	output_raid = false,
	output_user = true,
	outputlanguage = GetLocale(),
	negative_allowed = false,
	create_new_users = true,
	create_new_dkp = 100,
	remind_attendance = true,
  }
}

GoogleSheetDKP.gsdkpOptionsTable = {
	type = "group",
	args = {
		grpconfig = {
			type = "group",
			name = "Config",
			args = {

				hdrquery = { type = "header", name = "Queries", order = 100 },

				qryraid = {
					name = L["Raid"],
					desc = L["Accept queries for current DKP and list from Raid members"],
					type = "toggle",
					order = 110,
					set = function(info,val) GoogleSheetDKP.db.profile.query_raid = val end,
					get = function(info) return GoogleSheetDKP.db.profile.query_raid end,
				},
				newline111 = { name="", type="description", order=111 },

				qryext = {
					name = L["External"],
					desc = L["Accept queries for current DKP and list from all users"],
					type = "toggle",
					order = 120,
					set = function(info,val) GoogleSheetDKP.db.profile.query_external = val end,
					get = function(info) return GoogleSheetDKP.db.profile.query_external end,
				},
				newline121 = { name="", type="description", order=121 },

				hdroutput = { type = "header", name = "Output", order = 200 },

				outraid = {
					name = L["Raid"],
					desc = L["Output DKP changes to Raid"],
					type = "toggle",
					order = 210,
					set = function(info,val) GoogleSheetDKP.db.profile.output_raid = val end,
					get = function(info) return GoogleSheetDKP.db.profile.output_raid end,
				},
				newline211 = { name="", type="description", order=211 },

				outuser = {
					name = L["User"],
					desc = L["Output DKP changes to User"],
					type = "toggle",
					order = 220,
					set = function(info,val) GoogleSheetDKP.db.profile.output_user = val end,
					get = function(info) return GoogleSheetDKP.db.profile.output_user end,
				},
				newline221 = { name="", type="description", order=221 },

				outputlanguage = {
					name = L["Language"],
					desc = L["Language for outputs"],
					type = "select",
					order = 230,
					values = function()
						local r = {}
						for k,v in pairs(GoogleSheetDKP.outputLocales) do r[k] = k end
						return r
					end,
					set = function(info,val)
						GoogleSheetDKP.db.profile.outputlanguage = val
						for k,v in pairs(GoogleSheetDKP.outputLocales[val]) do L[k] = v end
					end,
					get = function(info) return GoogleSheetDKP.db.profile.outputlanguage end,
				},
				newline231 = { name="", type="description", order=231 },


				hdrconf = { type = "header", name = "Configuration", order = 300 },

				newuser = {
					name = L["Create users"],
					desc = L["Accept changes for users without current DKP import"],
					type = "toggle",
					order = 310,
					set = function(info,val) GoogleSheetDKP.db.profile.create_new_users = val end,
					get = function(info) return GoogleSheetDKP.db.profile.create_new_users end,
				},
				newdkp = {
					name = L["Start DKP"],
					desc = L["For new users, set this start DKP"],
					type = "input",
					order = 315,
					validate = function(info,v) if tonumber(v) == nil then return L["Start DKP: Please enter a number"] else return true end end,
					set = function(info,val) GoogleSheetDKP.db.profile.create_new_dkp = val end,
					get = function(info) return GoogleSheetDKP.db.profile.create_new_dkp end,
				},
				newline319 = { name="", type="description", order=319 },

				negative = {
					name = L["Allow negative"],
					desc = L["Allow DKP to go negative (otherwise stay at zero)"],
					type = "toggle",
					order = 320,
					set = function(info,val) GoogleSheetDKP.db.profile.negative_allowed = val end,
					get = function(info) return GoogleSheetDKP.db.profile.negative_allowed end,
				},
				newline321 = { name="", type="description", order=321 },

				chatlog = {
					name = L["Chatlog"],
					desc = L["Starts chatlog with first change action"],
					type = "toggle",
					order = 330,
					set = function(info,val) GoogleSheetDKP.db.profile.chatlog = val end,
					get = function(info) return GoogleSheetDKP.db.profile.chatlog end,
				},
				newline331 = { name="", type="description", order=331 },
				note332 = { name=L["Capture Chat log for easier resolve of disputes and discussions about DKP after a raid"], type="description", order=332 },

				attendance = {
					name = L["Attendence reminder"],
					desc = L["Remind to store attendance for later Raid DKP assignment"],
					type = "toggle",
					order = 340,
					set = function(info,val) GoogleSheetDKP.db.profile.remind_attendance = val end,
					get = function(info) return GoogleSheetDKP.db.profile.remind_attendance end,
				},
				newline341 = { name="", type="description", order=341 },
			},
		},

		grpimport = {
			type = "group",
			name = "Import",
			args = {

				note108 = { name=L["Copy & paste full Current DKP Tab from Google Doc here, including headers"], type="description", order=108 },
				newline109 = { name="", type="description", order=109 },
				import = {
					name = L["Import String"],
					type = "input",
					order = 110,
					confirm = true,
					width = 3.0,
					multiline = true,
					set = function(info, value) GoogleSheetDKP:Import(info, value)  end,
					usage = L["Copy & paste full Current DKP Tab from Google Doc here, including headers"],
					cmdHidden = true,
				},
				newline111 = { name="", type="description", order=51 },
				note112 = { name=L["Be aware that the DKP table will be OVERWRITTEN and existing changes DELETED!"], type="description", order=112 },
				note113 = { name=L["Export first, if you have current data!"], type="description", order=113 },

			}
		},

		grpexport = {
			type = "group",
			name = "Export",
			args = {

				import = {
					name = L["Export String"],
					type = "input",
					order = 210,
					confirm = true,
					width = 3.0,
					multiline = true,
					get = function (info) return GoogleSheetDKP:Export() end,
					cmdHidden = true,
				},
				newline211 = { name="", type="description", order=211 },
				note212 = { name=L["Copy full content and paste to Google Doc History tab, adding at the end"], type="description", order=212 },

			}
		},

		grpsyncs = {
			type = "group",
			name = L["Sync"],
			args = {

				allowed = {
					name = L["Always accept from"],
					type = "input",
					order = 310,
					width = 3.0,
					multiline = true,
					get = function (info)
						local s = ""
						for k,v in pairs(GoogleSheetDKP.db.profile.acceptSender) do
							local valid = date("%H:%M", v + 4*60*60)
							s = s .. L["user (valid until date)"](k, valid) .. "\r\n"
						end
						return s
					end,
					cmdHidden = true,
				},
				newline311 = { name="", type="description", order=311 },

				clearallowed = {
					order = 315,
					name = L["Clear accepted"],
					type = "execute",
					confirm = true,
					func = function(info) GoogleSheetDKP.db.profile.acceptSender = {} end,
				},
				newline316 = { name="", type="description", order=316 },

				ignored = {
					name = L["Always ignore from"],
					type = "input",
					order = 320,
					width = 3.0,
					multiline = true,
					get = function (info)
						local s = ""
						for k,v in pairs(GoogleSheetDKP.db.profile.ignoreSender) do
							local valid = date("%H:%M", v + 4*60*60)
							s = s .. L["user (valid until date)"](k, valid) .. "\r\n"
						end
						return s
					end,
					cmdHidden = true,
				},
				newline321 = { name="", type="description", order=321 },

				clearignored = {
					order = 325,
					name = L["Clear ignored"],
					type = "execute",
					confirm = true,
					func = function(info) GoogleSheetDKP.db.profile.ignoreSender = {} end,
				},
				newline326 = { name="", type="description", order=326 },

				requestsync = {
					order = 330,
					name = L["Request Sync (pull)"],
					type = "execute",
					confirm = true,
					func = function(info) GoogleSheetDKP:sendSyncRequest() end,
				},

				senddata = {
					order = 335,
					name = L["Offer Data (push)"],
					type = "execute",
					confirm = true,
					func = function(info) GoogleSheetDKP:sendSyncOffer() end,
				},

			},
		},

		grphelp = {
			type = "group",
			name = L["Help"],
			order = 800,
			args = {

				n01 = { order=01, type="description", name=L["Quickstart:"] },
				n02 = { order=02, type="description", name=L["Copy Template https://bit.ly/GoogleSheetDKP"] },
				n03 = { order=03, type="description", name=L["Import from Current DKP tab, Export to History Tab"] },
				n04 = { order=04, type="description", name="" },
				n05 = { order=05, type="description", name=L["Usage:"] },
				n06 = { order=06, type="description", name=L["/gsdkp: opens overview GUI"] },
				n07 = { order=07, type="description", name=L["/gsdkp config: opens configuration view with Import/Export/Help"] },
				n08 = { order=08, type="description", name=L["/gsdkp action: opens action menu for simplified usage of the next options:"] },
				n09 = { order=09, type="description", name="" },
				n10 = { order=10, type="description", name=L["/gsdkp change NAME VALUE CAUSE [COMMENT]: commits manual DKP change"] },
				n11 = { order=11, type="description", name=L["/gsdkp item NAME VALUE ITEMLINK: commits manual DKP change for Item awards. Value will *not* be negated! (Use e.g. -10 for costs)"] },
				n12 = { order=12, type="description", name=L["/gsdkp raidchange VALUE CAUSE [COMMENT]: commits DKP change to all current raid members (also /gsdkp raid)"] },
				n12 = { order=12, type="description", name=L["/gsdkp raidinit VALUE CAUSE [COMMENT]: commits DKP change to all current raid members (also /gsdkp init)"] },
				n13 = { order=13, type="description", name=L["Please note: CAUSE can only be a single word, e.g. 'Item', 'Bonus', 'Participation', 'FirstKill'"] },
				n14 = { order=14, type="description", name="" },
				n15 = { order=15, type="description", name=L["/gsdkp raidattendance: takes raid attendance to be used for next raidchange"] },
				n16 = { order=16, type="description", name=L["/gsdkp raidattendance delete: deletes stored raid attendance"] },
				n17 = { order=17, type="description", name="" },
				n18 = { order=18, type="description", name=L["API:"] },
				n19 = { order=19, type="description", name=L["Google Sheet DKP can be used by other addons to manage DKP:"] },
				n20 = { order=20, type="description", name=L["GoogleSheetDKP:GetDKP(name)"] },
				n21 = { order=21, type="description", name=L["GoogleSheetDKP:Change(name, value, cause, comment)"] },
				n22 = { order=22, type="description", name=L["GoogleSheetDKP:RaidChange(value, cause, comment)"] },
				n23 = { order=23, type="description", name=L["GoogleSheetDKP:RaidInit()"] },
				n24 = { order=24, type="description", name=L["GoogleSheetDKP:Item(name, value, itemLink)"] },
				n25 = { order=25, type="description", name=L["GoogleSheetDKP:RaidAttendance(['delete'])"] },
			}
		},

		debugging = {
		  name = L["Debug"],
		  type = "toggle",
		  order = 990,
		  set = function(info,val) GoogleSheetDKP.db.profile.debug = val end,
		  get = function(info) return GoogleSheetDKP.db.profile.debug end,
		},
		newline991 = { name="", type="description", order=991 },
	}
}

function GoogleSheetDKP:OnInitialize()
	-- Code that you want to run when the addon is first loaded goes here.
	GoogleSheetDKP.db = LibStub("AceDB-3.0"):New("GoogleSheetDKPDB", defaults)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("GoogleSheetDKP", GoogleSheetDKP.gsdkpOptionsTable)
	GoogleSheetDKP.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GoogleSheetDKP", "GoogleSheetDKP")

	GoogleSheetDKP.onetimes = {}

	-- change default output language if configured
	if GoogleSheetDKP.outputLocales[GoogleSheetDKP.db.profile.outputlanguage] ~= nil then
		for k,v in pairs(GoogleSheetDKP.outputLocales[GoogleSheetDKP.db.profile.outputlanguage]) do L[k] = v end
	end

	if GoogleSheetDKP.db.profile.nexthistory == nil then GoogleSheetDKP.db.profile.nexthistory = 1 end
	if GoogleSheetDKP.db.profile.historytimestamp == nil then GoogleSheetDKP.db.profile.historytimestamp = 0 end
	if GoogleSheetDKP.db.profile.history == nil then GoogleSheetDKP.db.profile.history = {} end
	if GoogleSheetDKP.db.profile.current == nil then GoogleSheetDKP.db.profile.current = {} end

	-- for "later" option, will be compared against time()
	GoogleSheetDKP.attendancereminder = 0

	if GoogleSheetDKP.db.profile.raidattendance_taken == nil then GoogleSheetDKP.db.profile.raidattendance_taken = 0 end

	-- remove stored attendance if older than 12 hours
	if GoogleSheetDKP.db.profile.raidattendance_taken + 12*60*60 < time() then
		GoogleSheetDKP.db.profile.raidattendance = nil
		GoogleSheetDKP.db.profile.raidattendance_taken = 0
	end

	if not GoogleSheetDKP.db.profile.ignoreSender then GoogleSheetDKP.db.profile.ignoreSender = {} end
	if not GoogleSheetDKP.db.profile.acceptSender then GoogleSheetDKP.db.profile.acceptSender = {} end

	GoogleSheetDKP.latestSyncOfferTime = 0
	GoogleSheetDKP.latestSyncOfferAccept = {}

	GoogleSheetDKP.commUUIDseen = {}
end

function GoogleSheetDKP:OnEnable()
	-- Called when the addon is enabled

	-- interaction from raid members
	GoogleSheetDKP:RegisterEvent("CHAT_MSG_WHISPER")
	GoogleSheetDKP:RegisterEvent("PLAYER_LOGOUT")

	GoogleSheetDKP:RegisterChatCommand("gsdkp", "ChatCommand")

	GoogleSheetDKP:RegisterComm(GoogleSheetDKP.commPrefix, "OnCommReceived")
	GoogleSheetDKP:RegisterComm(GoogleSheetDKP.commPrefixCSLS, "OnCommReceivedCSLS")

	if not GoogleSheetDKP.db.profiles.properlyEnded then
		GoogleSheetDKP:Debug("Error: not properly ended. Will request information")
		GoogleSheetDKP:askToRequestSyncCrash()
	end
	GoogleSheetDKP.db.profiles.properlyEnded = false
end

function GoogleSheetDKP:OnDisable()
    -- Called when the addon is disabled
	GoogleSheetDKP:UnregisterEvent("CHAT_MSG_WHISPER")
	GoogleSheetDKP:UnregisterEvent("PLAYER_LOGOUT")
	GoogleSheetDKP:UnregisterAllComm()
end

function GoogleSheetDKP:PLAYER_LOGOUT()
	-- event is called just before variables are saved
	-- and we need this variable to be saved ;)
	GoogleSheetDKP.db.profiles.properlyEnded = true
end

function GoogleSheetDKP:ChatCommand(inc)

	if strtrim(inc) == "config" or strtrim(inc) == "conf" then
		LibStub("AceConfigDialog-3.0"):Open("GoogleSheetDKP")
		return true

	elseif strtrim(inc) == "" then
		GoogleSheetDKP.dkpframe = GoogleSheetDKP:createDKPFrame()
		return true

	else
		-- condense multiple spaces
		local incs = string.gsub(strtrim(inc), "%s%s+", " ")
		local cmd = strsplit(" ", incs)

		if cmd == nil then
			-- do nothing
			return false

		elseif cmd == "action" then
			GoogleSheetDKP.actionframe = GoogleSheetDKP:createActionFrame()
			return true

		elseif cmd == "item" then
			local _, name, change, item = strsplit(" ", incs, 4)
			GoogleSheetDKP:Item(name, change, item)
			return true

		elseif cmd == "init" or cmd == "raidinit" then
			GoogleSheetDKP:RaidInit()
			return true

		elseif cmd == "raid" or cmd == "raidchange" then
			local _, change, cause, comment = strsplit(" ", incs, 4)
			GoogleSheetDKP:RaidChange(change, cause, comment)
			return true

		elseif cmd == "attendance" or cmd == "attend" then
			local _, deletion = strsplit(" ", incs, 2)
			GoogleSheetDKP:Attendance(deletion)
			return true

		elseif cmd == "change" then
			local _, name, change, cause, comment = strsplit(" ", incs, 5)
			GoogleSheetDKP:Change(name, change, cause, comment)
			return true

		end

	end

	return false
end


function GoogleSheetDKP:Debug(t)
	if (GoogleSheetDKP.db.profile.debug) then
		GoogleSheetDKP:Print("GoogleSheetDKP DEBUG: " .. t)
	end
end

