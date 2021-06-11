--[[--
	by ALA @ 163UI/网易有爱, http://wowui.w.163.com/163ui/
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
--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.locale'); end

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
	--	setting
	UILOC.TAG_SETTING = "";
	UILOC.show_quest_starter = "显示任务给与者";
	UILOC.show_quest_ender = "显示任务交还者";
	UILOC.show_db_icon = "显示小地图按钮";
	UILOC.min_rate = "最低物品掉率";
	UILOC.pin_size = "普通标记点大小";
	UILOC.large_size = "boss标记点大小";
	UILOC.varied_size = "交接npc标记点大小";
	UILOC.pin_scale_max = "地图缩放时标记点的最大缩放";
	UILOC.quest_lvl_lowest_ofs = "最低任务等级偏差";
	UILOC.quest_lvl_highest_ofs = "最高任务等级偏差";
	UILOC.auto_accept = "自动接任务";
	UILOC.auto_complete = "自动交任务";
	UILOC.quest_auto_inverse_modifier = "自动交接反向按键";
	UILOC.tip_info = "显示鼠标提示";
	UILOC.show_buttons_in_log = "显示任务日志按钮";
	UILOC.hide_node_modifier = "隐藏任务NPC按键";
	--	questlogframe
	UILOC.show_quest = "显示";
	UILOC.hide_quest = "隐藏";
	UILOC.reset_filter = "重置";
	--
	UILOC.CODEX_LITE_CONFLICTS = "是否关闭功能重复的插件ClassicCodex和Questie，并重载？";
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
	--	setting
	UILOC.TAG_SETTING = "";
	UILOC.show_quest_starter = "顯示任務給與者";
	UILOC.show_quest_ender = "顯示任務交還者";
	UILOC.show_db_icon = "顯示小地圖按鈕";
	UILOC.min_rate = "最低物品掉率";
	UILOC.pin_size = "普通標記點大小";
	UILOC.large_size = "boss標記點大小";
	UILOC.varied_size = "交接npc標記點大小";
	UILOC.pin_scale_max = "地圖縮放時標記點的最大縮放";
	UILOC.quest_lvl_lowest_ofs = "最低任務等級偏差";
	UILOC.quest_lvl_highest_ofs = "最高任務等級偏差";
	UILOC.auto_accept = "自動接任務";
	UILOC.auto_complete = "自動交任務";
	UILOC.quest_auto_inverse_modifier = "自動交接反向按鍵";
	UILOC.tip_info = "顯示鼠標提示";
	UILOC.show_buttons_in_log = "顯示任務日志按鈕";
	UILOC.hide_node_modifier = "隱藏任務NPC按鍵";
	--	questlogframe
	UILOC.show_quest = "顯示";
	UILOC.hide_quest = "隱藏";
	UILOC.reset_filter = "重置";
	--
	UILOC.CODEX_LITE_CONFLICTS = "是否关闭功能重复的插件ClassicCodex和Questie，并重载？";
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
	--	setting
	UILOC.TAG_SETTING = "";
	UILOC.show_quest_starter = "Show Quest Giver";
	UILOC.show_quest_ender = "Show Quest Turn In";
	UILOC.show_db_icon = "Show DBIcon around minimap";
	UILOC.min_rate = "Minium Drop Rate";
	UILOC.pin_size = "Size of normal pins";
	UILOC.large_size = "Size of BOSS pins";
	UILOC.varied_size = "Size of NPC pins";
	UILOC.pin_scale_max = "Maxium scale size";
	UILOC.quest_lvl_lowest_ofs = "Lowest Level Offset";
	UILOC.quest_lvl_highest_ofs = "Highest Level Offset";
	UILOC.auto_accept = "Quest Auto Accept";
	UILOC.auto_complete = "Quest Auto Complete";
	UILOC.quest_auto_inverse_modifier = "Auto-Turn-In inverse modifier";
	UILOC.tip_info = "Info in tip";
	UILOC.show_buttons_in_log = "Show buttons in questlog";
	UILOC.hide_node_modifier = "Modifier of hiding quest giver";
	--	questlogframe
	UILOC.show_quest = "Show";
	UILOC.hide_quest = "Hide";
	UILOC.reset_filter = "Reset";
	--
	UILOC.CODEX_LITE_CONFLICTS = "Disable ClassicCodex and Questie, then reload UI?";
end

--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.locale'); end
