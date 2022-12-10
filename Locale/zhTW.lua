--[[--
	by ALA @ 163UI/网易有爱, http://wowui.w.163.com/163ui/
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local CT = __private.CT;

if CT.LOCALE ~= "zhTW" then
	return;
end
local uil10n = CT.l10n.ui;
uil10n.LOCALE = "zhTW";


uil10n.LOC_PATTERN = {
	name = "<name>",
	race = "<race>",
	class = "<class>",
};

--	tip
uil10n.TIP_WAYPOINT = "偵察";
uil10n.TIP_QUEST_LVL = "等级: ";
uil10n.TIP_QUEST_MIN = "可接: ";
uil10n.QUEST_TAG = {
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
uil10n.COMPLETED = "已完成";
uil10n.IN_PROGRESS = "進行中";
--	setting
uil10n.TAG_SETTING = "有愛任務輔助";
uil10n['tab.general'] = "綜合";
uil10n['tab.map'] = "地圖";
uil10n['tab.worldmap'] = "世界地圖";
uil10n['tab.minimap'] = "小地圖";
uil10n['tab.interact'] = "交互";
uil10n['tab.misc'] = "雜項";
uil10n['tab.blocked'] = "已隱藏";
uil10n.TAIL_SETTING = "by |cff00ff00ALA|r 文本數據來自|cff00ff00EKK|r和|cff00ff00qqyt|r";
--	general
uil10n.show_db_icon = "顯示小地圖設置菜單按鈕";
uil10n.show_buttons_in_log = "顯示任務日志按鈕";
uil10n.show_id_in_tooltip = "在鼠標提示中顯示id";
uil10n.show_quest_starter = "顯示任務給與者";
uil10n.show_quest_ender = "顯示任務交還者";
uil10n.quest_lvl_lowest_ofs = "最低任務等級偏差";
uil10n.quest_lvl_highest_ofs = "最高任務等級偏差";
uil10n.limit_item_starter_drop = "觸發任務的物品只顯示10%以上掉落率的掉落點";
uil10n.limit_item_starter_drop_num_coords = "觸發任務的物品只顯示少於等於5個位置的掉落點";
uil10n.node_menu_modifier = "任務标记彈出菜單按鍵";
--	map
uil10n.min_rate = "最低物品掉率";
--	worldmap
uil10n.worldmap_alpha = "大地圖圖標透明度";
uil10n.worldmap_normal_size = "大地圖普通標記點大小";
uil10n.worldmap_large_size = "大地圖boss標記點大小";
uil10n.worldmap_varied_size = "大地圖交接npc標記點大小";
uil10n.worldmap_pin_scale_max = "地圖縮放時標記點的最大縮放";
uil10n.show_in_continent = "在大陸地圖上顯示標記";
--	minimap
uil10n.minimap_alpha = "小地圖圖標透明度";
uil10n.minimap_normal_size = "小地圖普通標記點大小";
uil10n.minimap_large_size = "小地圖boss標記點大小";
uil10n.minimap_varied_size = "小地圖交接npc標記點大小";
uil10n.minimap_node_inset = "不顯示小地圖邊緣上的任務圖標";
uil10n.minimap_player_arrow_on_top = "置頂小地圖玩家箭頭";
--	interact
uil10n.auto_accept = "自動接任務";
uil10n.auto_complete = "自動交任務";
uil10n.quest_auto_inverse_modifier = "自動交接反向按鍵";
uil10n.objective_tooltip_info = "顯示物件鼠標提示";
--	questlogframe
uil10n.show_quest = "顯示";
uil10n.hide_quest = "隱藏";
uil10n.reset_filter = "重置";
--	pin-onmenu
uil10n.pin_menu_hide_quest = "|cffff3f00隱藏|r ";
uil10n.pin_menu_show_quest = "|cff00ff00顯示|r ";
uil10n.pin_menu_send_quest = "|cffff7f00發送|r";
--
uil10n.CODEX_LITE_CONFLICTS = "是否关闭功能重复的插件ClassicCodex和Questie，并重载？";
