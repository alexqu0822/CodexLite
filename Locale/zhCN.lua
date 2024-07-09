--[[--
	by ALA
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local CT = __private.CT;

if CT.LOCALE ~= "zhCN" then
	return;
end
local uil10n = CT.l10n.ui;
uil10n.LOCALE = "zhCN";


uil10n.LOC_PATTERN = {
	name = "<name>",
	race = "<race>",
	class = "<class>",
};

--	tip
uil10n.TIP_WAYPOINT = "侦察";
uil10n.TIP_QUEST_LVL = "等级: ";
uil10n.TIP_QUEST_MIN = "可接: ";
uil10n.QUEST_TAG = {
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
uil10n.COMPLETED = "已完成";
uil10n.IN_PROGRESS = "进行中";
--	setting
uil10n.TAG_SETTING = "有爱任务辅助";
uil10n['tab.general'] = "综合";
uil10n['tab.map'] = "地图";
uil10n['tab.worldmap'] = "世界地图";
uil10n['tab.minimap'] = "小地图";
uil10n['tab.interact'] = "交互";
uil10n['tab.misc'] = "杂项";
uil10n['tab.blocked'] = "已隐藏";
uil10n.TAIL_SETTING = "by |cff00ff00ALA|r 文本数据来自|cff00ff00EKK|r和|cff00ff00qqyt|r";
--	general
uil10n.show_db_icon = "显示小地图设置菜单按钮";
uil10n.show_buttons_in_log = "显示任务日志按钮";
uil10n.show_id_in_tooltip = "在鼠标提示中显示id";
uil10n.show_quest_starter = "显示任务给予者";
uil10n.show_quest_ender = "显示任务交还者";
uil10n.quest_lvl_lowest_ofs = "最低任务等级偏差";
uil10n.quest_lvl_highest_ofs = "最高任务等级偏差";
uil10n.limit_item_starter_drop = "触发任务的物品只显示10%以上掉落率的掉落点";
uil10n.limit_item_starter_drop_num_coords = "触发任务的物品只显示少于等于5个位置的掉落点";
uil10n.node_menu_modifier = "任务标记弹出菜单按键";
--	map
uil10n.min_rate = "最低物品掉率";
--	worldmap
uil10n.worldmap_alpha = "大地图图标透明度";
uil10n.worldmap_normal_size = "大地图普通标记点大小";
uil10n.worldmap_large_size = "大地图boss标记点大小";
uil10n.worldmap_varied_size = "大地图交接npc标记点大小";
uil10n.worldmap_pin_scale_max = "地图缩放时标记点的最大缩放";
uil10n.show_in_continent = "在大陆地图上显示标记";
--	minimap
uil10n.minimap_alpha = "小地图图标透明度";
uil10n.minimap_normal_size = "小地图普通标记点大小";
uil10n.minimap_large_size = "小地图boss标记点大小";
uil10n.minimap_varied_size = "小地图交接npc标记点大小";
uil10n.minimap_node_inset = "不显示小地图边缘上的任务图标";
uil10n.minimap_player_arrow_on_top = "置顶小地图玩家箭头";
--	interact
uil10n.auto_accept = "自动接任务";
uil10n.auto_complete = "自动交任务";
uil10n.quest_auto_inverse_modifier = "自动交接反向按键";
uil10n.objective_tooltip_info = "显示物件鼠标提示";
--	questlogframe
uil10n.show_quest = "显示";
uil10n.hide_quest = "隐藏";
uil10n.reset_filter = "重置";
--	pin-onmenu
uil10n.pin_menu_hide_quest = "|cffff3f00隐藏|r ";
uil10n.pin_menu_show_quest = "|cff00ff00显示|r ";
uil10n.pin_menu_send_quest = "|cffff7f00发送|r";
--
uil10n.CODEX_LITE_CONFLICTS = "是否关闭功能重复的插件ClassicCodex和Questie，并重载？";
