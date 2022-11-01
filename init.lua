--[[--
	by ALA @ 163UI/网易有爱, http://wowui.w.163.com/163ui/
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local MT = {  }; __private.MT = MT;		--	method
local CT = {  }; __private.CT = CT;		--	constant
local VT = {  }; __private.VT = VT;		--	variables
local DT = {  }; __private.DT = DT;		--	data

-->		upvalue
	local setfenv = setfenv;
	local loadstring, pcall, xpcall = loadstring, pcall, xpcall;
	local geterrorhandler = geterrorhandler;
	local print, date = print, date;
	local type = type;
	local tostring = tostring;
	local select = select;
	local setmetatable = setmetatable;
	local rawset, rawget = rawset, rawget;
	local next = next;
	local unpack = unpack;
	local tconcat = table.concat;
	local format = string.format;
	local band = bit.band;
	local ipairs = ipairs;
	local tremove = table.remove;
	local UnitLevel = UnitLevel;
	local IsLoggedIn = IsLoggedIn;
	local UnitPosition = UnitPosition;
	local C_Map = C_Map;
	local CreateVector2D = CreateVector2D;
	local CreateFrame = CreateFrame;
	local _G = _G;

-->
	local __ala_meta__ = _G.__ala_meta__;
	__ala_meta__.quest = __private;
	VT.__autostyle = __ala_meta__.autostyle;
	VT.__menulib = __ala_meta__.__menulib;
	VT.__scrolllib = _G.alaScrollList;

-->		Dev
	local _GlobalRef = {  };
	local _GlobalAssign = {  };
	function MT.BuildEnv(category)
		local _G = _G;
		local Ref = _GlobalRef[category] or {  };
		local Assign = _GlobalAssign[category] or {  };
		setfenv(2, setmetatable(
			{  },
			{
				__index = function(tbl, key, val)
					Ref[key] = (Ref[key] or 0) + 1;
					_GlobalRef[category] = Ref;
					return _G[key];
				end,
				__newindex = function(tbl, key, value)
					rawset(tbl, key, value);
					Assign[key] = (Assign[key] or 0) + 1;
					_GlobalAssign[category] = Assign;
					return value;
				end,
			}
		));
	end
	function MT.MergeGlobal(DB)
		local _Ref = DB._GlobalRef;
		if _Ref ~= nil then
			for category, db in next, _Ref do
				local to = _GlobalRef[category];
				if to == nil then
					_GlobalRef[category] = db;
				else
					for key, val in next, db do
						to[key] = (to[key] or 0) + val;
					end
				end
			end
		end
		DB._GlobalRef = _GlobalRef;
		local _Assign = DB._GlobalAssign;
		if _Assign ~= nil then
			for category, db in next, _Assign do
				local to = _GlobalAssign[category];
				if to == nil then
					_GlobalAssign[category] = db;
				else
					for key, val in next, db do
						to[key] = (to[key] or 0) + val;
					end
				end
			end
		end
		DB._GlobalAssign = _GlobalAssign;
	end

-->		constant
	CT.BNTAG = select(2, BNGetInfo());
	CT.PATCHVERSION, CT.BUILDNUMBER, CT.BUILDDATE, CT.TOC = GetBuildInfo();
	CT.MAXLEVEL = GetMaxLevelForExpansionLevel(GetExpansionLevel());
	CT.LOCALE = GetLocale();
	CT.SELFGUID = UnitGUID('player');
	CT.SELFNAME = UnitName('player');
	CT.SELFRACE, CT.SELFRACEFILE, CT.SELFRACEID = UnitRace('player');
	CT.SELFCLASS = UnitClassBase('player');
	CT.SELFFACTION = UnitFactionGroup('player');

	CT.TAG_DEFAULT = '__pin_tag_default';
	CT.TAG_WM_COMMON = '__pin_tag_wm_common';
	CT.TAG_WM_LARGE = '__pin_tag_wm_large';
	CT.TAG_WM_VARIED = '__pin_tag_wm_varied';
	CT.TAG_MM_COMMON = '__pin_tag_mm_common';
	CT.TAG_MM_LARGE = '__pin_tag_mm_large';
	CT.TAG_MM_VARIED = '__pin_tag_mm_varied';

	CT.BIT2RACE = {
		["Human"] = 1,
		["Orc"] = 2,
		["Dwarf"] = 4,
		["NightElf"] = 8,
		["Scourge"] = 16,
		["Tauren"] = 32,
		["Gnome"] = 64,
		["Troll"] = 128,
		["Goblin"] = 256,
		["BloodElf"] = 512,
		["Draenei"] = 1024,
	};
	CT.RACE2BIT = {  }; for _race, _bit in next, CT.BIT2RACE do CT.RACE2BIT[_bit] = _race; end
	CT.BIT2CLASS = {
		["WARRIOR"] = 1,
		["PALADIN"] = 2,
		["HUNTER"] = 4,
		["ROGUE"] = 8,
		["PRIEST"] = 16,
		["SHAMAN"] = 64,
		["MAGE"] = 128,
		["WARLOCK"] = 256,
		["DRUID"] = 1024,
		["DEATHKNIGHT"] = 2048,
	};
	CT.CLASS2BIT = {  }; for _class, _bit in next, CT.BIT2CLASS do CT.CLASS2BIT[_bit] = _class; end
	CT.SELFRACEBIT = CT.BIT2RACE[CT.SELFRACEFILE];
	CT.SELFCLASSBIT = CT.BIT2CLASS[CT.SELFCLASS];

	CT.IMG_PATH = "Interface\\AddOns\\CodexLite\\img\\";
	CT.IMG_INDEX = {
		IMG_DEF = 1,
		IMG_S_HIGH_LEVEL = 2,
		IMG_S_COMMING = 3,
		IMG_S_LOW_LEVEL = 4,
		IMG_S_REPEATABLE = 5,
		IMG_E_UNCOMPLETED = 6,
		IMG_S_VERY_HARD = 7,
		IMG_S_EASY = 8,
		IMG_S_HARD = 9,
		IMG_S_NORMAL = 10,
		IMG_E_COMPLETED = 11,
	};
	CT.IMG_PATH_PIN = CT.IMG_PATH .. "PIN";
	CT.IMG_PATH_AVL = CT.IMG_PATH .. "AVL";
	CT.IMG_PATH_CPL = CT.IMG_PATH .. "CPL";
	CT.IMG_LIST = {
		[CT.IMG_INDEX.IMG_DEF] 			= { CT.IMG_PATH_PIN,  nil,  nil,  nil, "ffffffff", 0, 0, },
		[CT.IMG_INDEX.IMG_S_HIGH_LEVEL] 	= { CT.IMG_PATH_AVL, 1.00, 0.10, 0.10, "ffffffff", 1, 1, },
		[CT.IMG_INDEX.IMG_S_COMMING] 		= { CT.IMG_PATH_AVL, 1.00, 0.25, 0.25, "ffffffff", 2, 2, },
		[CT.IMG_INDEX.IMG_S_LOW_LEVEL] 	= { CT.IMG_PATH_AVL, 0.65, 0.65, 0.65, "ffffffff", 3, 3, },
		[CT.IMG_INDEX.IMG_S_REPEATABLE] 	= { CT.IMG_PATH_AVL, 0.25, 0.50, 0.75, "ffffffff", 4, 4, },
		[CT.IMG_INDEX.IMG_E_UNCOMPLETED] 	= { CT.IMG_PATH_CPL, 0.65, 0.65, 0.65, "ffffffff", 5, 5, },
		[CT.IMG_INDEX.IMG_S_VERY_HARD]		= { CT.IMG_PATH_AVL, 1.00, 0.25, 0.00, "ffffffff", 6, 6, },
		[CT.IMG_INDEX.IMG_S_EASY] 			= { CT.IMG_PATH_AVL, 0.25, 0.75, 0.25, "ffffffff", 7, 7, },
		[CT.IMG_INDEX.IMG_S_HARD] 			= { CT.IMG_PATH_AVL, 1.00, 0.60, 0.00, "ffffffff", 8, 8, },
		[CT.IMG_INDEX.IMG_S_NORMAL] 		= { CT.IMG_PATH_AVL, 1.00, 1.00, 0.00, "ffffffff", 9, 9, },
		[CT.IMG_INDEX.IMG_E_COMPLETED] 	= { CT.IMG_PATH_CPL, 1.00, 0.90, 0.00, "ffffffff", 10, 10, },
	};
	for _, texture in next, CT.IMG_LIST do
		if texture[2] ~= nil and texture[3] ~= nil and texture[4] ~= nil then
			texture[5] = format("ff%.2x%.2x%.2x", texture[2] * 255, texture[3] * 255, texture[4] * 255);
		end
	end
	CT.TIP_IMG_LIST = {  };
	for index, info in next, CT.IMG_LIST do
		if (info[2] ~= nil and info[3] ~= nil and info[4] ~= nil) and (info[2] ~= 1.0 or info[3] ~= 1.0 or info[4] ~= 1.0) then
			CT.TIP_IMG_LIST[index] = format("|T%s:0:0:0:0:1:1:0:1:0:1:%d:%d:%d|t", info[1], info[2] * 255, info[3] * 255, info[4] * 255);
		else
			CT.TIP_IMG_LIST[index] = format("|T%s:0|t", info[1]);
		end
	end

	CT.l10nDB = setmetatable(
		{
			--	Prevent to destroy /tinspect
			GetParent = false,
			SetShown = false,
			GetDebugName = false,
			IsObjectType = false,
			GetChildren = false,
			GetRegions = false,
		},
		{
			__index = function(tbl, key)
				local T = {
					ui = setmetatable(
						{
							--	Prevent to destroy /tinspect
							GetParent = false,
							SetShown = false,
							GetDebugName = false,
							IsObjectType = false,
							GetChildren = false,
							GetRegions = false,
						},
						{
							__newindex = function(tbl, key, val)
								if val == true then
									rawset(tbl, key, key);
								else
									rawset(tbl, key, val);
								end
							end,
							__index = function(tbl, key)
								return key;
							end,
							__call = function(tbl, key)
								return rawget(tbl, key) or key;
							end,
						}
					),
				};
				tbl[key] = T;
				return T;
			end,
		}
	);

-->		control
	VT.__is_dev = CT.BNTAG == 'alex#516722';

-->
MT.BuildEnv('Init');
-->		predef
	MT.GetUnifiedTime = _G.GetTimePreciseSec;
	MT.After = _G.C_Timer.After;
	
	MT.Print = print;
	function MT.Error(...)
		return MT.Print(date('|cff00ff00%H:%M:%S|r'), ...);
	end
	function MT.DebugDev(...)
		return MT.Print(date('|cff00ff00%H:%M:%S|r'), ...);
	end
	function MT.DebugRelease(...)
	end
	function MT.Notice(...)
		MT.Print(date('|cffff0000%H:%M:%S|r'), ...);
	end

	local _TimerPrivate = {  };		--	[callback] = { periodic, int, running, halting, limit, };
	function MT._TimerStart(callback, int, limit)
		if callback ~= nil and type(callback) == 'function' then
			local P = _TimerPrivate[callback];
			if P == nil then
				P = {
					[1] = function()	--	periodic
						if P[4] then
							P[3] = false;
						elseif P[5] == nil then
							MT.After(P[2], P[1]);
							callback();
						elseif P[5] > 1 then
							P[5] = P[5] - 1;
							MT.After(P[2], P[1]);
							callback();
						elseif P[5] > 0 then
							P[3] = false;
							callback();
						else
							P[3] = false;
						end
					end,
					[2] = int or 1.0,	--	int
					[3] = true,			--	isrunning
					[4] = false,		--	ishalting
					[5] = limit,
				};
				_TimerPrivate[callback] = P;
				return MT.After(P[2], P[1]);
			elseif not P[3] then
				P[2] = int or 1.0;
				P[3] = true;
				P[4] = false;
				P[5] = limit;
				return MT.After(P[2], P[1]);
			else
				P[2] = int or P[2];
				P[4] = false;
				P[5] = limit;
			end
		end
	end
	function MT._TimerHalt(callback)
		local P = _TimerPrivate[callback];
		if P ~= nil and P[3] then
			P[4] = true;
		end
	end

	function MT.CheckSelfRace(_b)
		return band(_b, CT.SELFRACEBIT) ~= 0;
	end
	function MT.CheckSelfClass(_b)
		return band(_b, CT.SELFCLASSBIT) ~= 0;
	end

	function MT.GetQuestStartTexture(info)
		local TEXTURE = CT.IMG_INDEX.IMG_S_NORMAL;
		local min = info.min;
		local diff = min < 0 and 0 or (min - VT.PlayerLevel);
		if diff > 0 then
			if diff > 1 then
				TEXTURE = CT.IMG_INDEX.IMG_S_HIGH_LEVEL;
			else
				TEXTURE = CT.IMG_INDEX.IMG_S_COMMING;
			end
		else
			local flag = info.flag;
			local exflag = info.exflag;
			if (exflag ~= nil and band(exflag, 1) ~= 0) or (flag ~= nil and band(flag, 4096) ~= 0) then
				TEXTURE = CT.IMG_INDEX.IMG_S_REPEATABLE;
			else
				local lvl = info.lvl;
				lvl = lvl >= 0 and lvl or VT.PlayerLevel;
				if lvl >= VT.QuestLvRed then
					TEXTURE = CT.IMG_INDEX.IMG_S_VERY_HARD;
				elseif lvl >= VT.QuestLvOrange then
					TEXTURE = CT.IMG_INDEX.IMG_S_HARD;
				elseif lvl >= VT.QuestLvYellow then
					TEXTURE = CT.IMG_INDEX.IMG_S_NORMAL;
				elseif lvl >= VT.QuestLvGreen then
					TEXTURE = CT.IMG_INDEX.IMG_S_EASY;
				else
					TEXTURE = CT.IMG_INDEX.IMG_S_LOW_LEVEL;
				end
			end
		end
		return TEXTURE;
	end

-->
	VT.PlayerLevel = UnitLevel('player');
	VT.QuestLvGreen = -1;
	VT.QuestLvYellow = -1;
	VT.QuestLvOrange = -1;
	VT.QuestLvRed = -1;
	VT.IsUnitFacFriend = { AH = 1, };
	if CT.SELFFACTION == "Alliance" then
		VT.IsUnitFacFriend.A = 1;
	else
		VT.IsUnitFacFriend.H = 1;
	end
	DT.DB = {  };
	
-->		Main
	local __beforeinit = {  };
	local __oninit = {  };
	local __afterinit = {  };
	local __onlogin = {  };
	local __onquit = {  };
	function MT.RegisterBeforeInit(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__beforeinit[#__beforeinit + 1] = key;
			__beforeinit[key] = method;
		end
	end
	function MT.RegisterOnInit(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__oninit[#__oninit + 1] = key;
			__oninit[key] = method;
		end
	end
	function MT.CallOnInit(key)
		local method = __oninit[key];
		if method ~= nil then
			return method();
		end
	end
	function MT.RegisterAfterInit(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__afterinit[#__afterinit + 1] = key;
			__afterinit[key] = method;
		end
	end
	function MT.RegisterOnLogin(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__onlogin[#__onlogin + 1] = key;
			__onlogin[key] = method;
		end
	end
	function MT.RegisterOnQuit(key, method)
		if type(key) == 'string' and type(method) == 'function' then
			__onquit[#__onquit + 1] = key;
			__onquit[key] = method;
		end
	end

	MT.GetUnifiedTime();		--	initialized after call once
	local Driver = CreateFrame('FRAME');
	Driver:RegisterEvent("ADDON_LOADED");
	Driver:RegisterEvent("PLAYER_LOGOUT");
	Driver:RegisterEvent("PLAYER_LOGIN");
	Driver:SetScript("OnEvent", function(Driver, event, addon)
		if event == "ADDON_LOADED" then
			if addon == __addon then
				Driver:UnregisterEvent("ADDON_LOADED");
				VT.__is_loggedin = IsLoggedIn();
				--
				for index = 1, #__beforeinit do
					local key = __beforeinit[index];
					local method = __beforeinit[key];
					xpcall(method, MT.ErrorHandler, VT.__is_loggedin);
				end
				for index = 1, #__oninit do
					local key = __oninit[index];
					local method = __oninit[key];
					xpcall(method, MT.ErrorHandler, VT.__is_loggedin);
					--[==[local success, message = pcall(method);
					if not success then
						MT.ErrorHandler(message or (__addon .. " INIT SCRIPT [[" .. key .. "]] ERROR."));
					end]==]
				end
				for index = 1, #__afterinit do
					local key = __afterinit[index];
					local method = __afterinit[key];
					xpcall(method, MT.ErrorHandler, VT.__is_loggedin);
				end
				if VT.__is_loggedin then
					return Driver:GetScript("OnEvent")(Driver, "PLAYER_LOGIN");
				end
			end
		elseif event == "PLAYER_LOGIN" then
			Driver:UnregisterEvent("PLAYER_LOGIN");
			VT.__is_loggedin = true;
			for index = 1, #__onlogin do
				local key = __onlogin[index];
				local method = __onlogin[key];
				xpcall(method, MT.ErrorHandler, true);
			end
		elseif event == "PLAYER_LOGOUT" then
			for index = 1, #__onquit do
				local key = __onquit[index];
				local method = __onquit[key];
				xpcall(method, MT.ErrorHandler);
			end
		end
	end);

	VT.__is_loggedin = IsLoggedIn();

	if VT.__is_dev then
		MT.Debug = MT.DebugDev;
	else
		MT.Debug = MT.DebugRelease;
	end

-->

-->		EventHandler
	local EventAgent = CreateFrame('FRAME');
	VT.EventAgent = EventAgent;
	local function OnEvent(self, event, ...)
		return EventAgent[event](...);
	end
	function EventAgent:RegEvent(event, func)
		func = func or EventAgent[event];
		if func ~= nil then
			EventAgent[event] = func;
			self:RegisterEvent(event);
			self:SetScript("OnEvent", OnEvent);
		end
	end
	function EventAgent:UnregEvent(event)
		self:UnregisterEvent(event);
	end
	function MT.FireEvent(event, ...)
		local func = EventAgent[event];
		if func ~= nil then
			return func(...);
		end
	end
-->
