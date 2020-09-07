--[[--
	ALL RIGHTS RESERVCED by ALA @ 163UI/网易有爱
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __ns = ...;

if __ns.__dev then
	setfenv(1, __ns.__fenv);
end
local _G = _G;
local _ = nil;
----------------------------------------------------------------------------------------------------
--[=[dev]=]	if __ns.__dev then debugprofilestart(); end

local UILOC = {  };
__ns.UILOC = UILOC;

local LOCALE = GetLocale();

local LOC_PATTERN_LIST = {
	deDE = {
		name = "<name>",
		race = "<völker>",
		class = "<klasse>",
	},
	enUS = {
		name = "<name>",
		race = "<race>",
		class = "<class>",
	},
	esES = {
		name = "<nombre>",
		race = "<raza>",
		class = "<clase>",
	},
	esMX = {
		name = "<nombre>",
		race = "<raza>",
		class = "<clase>",
	},
	frFR = {
		name = "<nom>",
		race = "<race>",
		class = "<classe>",
	},
	koKR = {
		name = "<name>",
		race = "<race>",
		class = "<class>",
	},
	ptBR = {
		name = "<nome>",
		race = "<Raça>",
		class = "<class>",
	},
	ruRU = {
		name = "<имя>",
		race = "<раса>",
		class = "<класс>",
	},
	zhCN = {
		name = "<name>",
		race = "<race>",
		class = "<class>",
	},
	zhTW = {
		name = "<name>",
		race = "<race>",
		class = "<class>",
	},
};
UILOC.LOC_PATTERN_LIST = LOC_PATTERN_LIST;
UILOC.LOC_PATTERN = LOC_PATTERN_LIST[LOCALE];
if LOCALE == 'zhCN' then
	--	tip
	UILOC.TIP_WAYPOINT = "侦察";
	UILOC.TIP_QUEST_LVL = "等级: ";
	UILOC.TIP_QUEST_MIN = "可接: ";
	UILOC.QUEST_TAG = {
		[1] = "+",				--	Group
		[41] = "P",				--	PVP
		[64] = "团",			--	Raid
		[81] = "地",			--	Dungeon
		[83] = "Legendary",
		[85] = "Heroic",
		[98] = "Scenario",
		[102] = "Account",
		[117] = "Leatherworking World Quest",
	};
	UILOC.COMPLETED = "已完成";
	UILOC.IN_PROGRESS = "进行中";
elseif LOCALE == 'zhTW' then
	--	tip
	UILOC.TIP_WAYPOINT = "偵察";
	UILOC.TIP_QUEST_LVL = "等级: ";
	UILOC.TIP_QUEST_MIN = "可接: ";
	UILOC.QUEST_TAG = {
		[1] = "+",				--	Group
		[41] = "P",				--	PVP
		[64] = "團",			--	Raid
		[81] = "地",			--	Dungeon
		[83] = "Legendary",
		[85] = "Heroic",
		[98] = "Scenario",
		[102] = "Account",
		[117] = "Leatherworking World Quest",
	};
	UILOC.COMPLETED = "已完成";
	UILOC.IN_PROGRESS = "進行中";
else
	--	tip
	UILOC.TIP_WAYPOINT = "Explore";
	UILOC.TIP_QUEST_LVL = "Lvl: ";
	UILOC.TIP_QUEST_MIN = "Min: ";
	UILOC.QUEST_TAG = {
		[1] = "+",				--	Group
		[41] = "P",				--	PVP
		[64] = "R",				--	Raid
		[81] = "D",				--	Dungeon
		[83] = "Legendary",
		[85] = "Heroic",
		[98] = "Scenario",
		[102] = "Account",
		[117] = "Leatherworking World Quest",
	};
	UILOC.COMPLETED = "COMPLETED";
	UILOC.IN_PROGRESS = "Progress";
end

--[=[dev]=]	if __ns.__dev then __ns.__performance_log('module.util'); end
