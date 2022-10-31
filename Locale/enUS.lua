--[[--
	by ALA @ 163UI/网易有爱, http://wowui.w.163.com/163ui/
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local CT = __private.CT;

local uil10n = CT.l10n.ui;
if CT.LOCALE ~= "enUS" and uil10n.LOCALE ~= nil then
	return;
end
uil10n.LOCALE = "enUS";

uil10n.LOC_PATTERN = {
	name = "<name>",
	race = "<race>",
	class = "<class>",
};

--	tip
uil10n.TIP_WAYPOINT = "Explore";
uil10n.TIP_QUEST_LVL = "Lvl: ";
uil10n.TIP_QUEST_MIN = "Min: ";
uil10n.QUEST_TAG = {
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
uil10n.COMPLETED = "COMPLETED";
uil10n.IN_PROGRESS = "Progress";
--	setting
uil10n.TAG_SETTING = "CodexLite";
uil10n['tab.general'] = "General";
uil10n['tab.map'] = "Map";
uil10n['tab.worldmap'] = "WorldMap";
uil10n['tab.minimap'] = "MiniMap";
uil10n['tab.interact'] = "Interact";
uil10n['tab.misc'] = "Misc";
uil10n['tab.blocked'] = "Blocked";
uil10n.TAIL_SETTING = "by |cff00ff00ALA|r. Text Data Provided by |cff00ff00EKK|r & |cff00ff00qqyt|r";
--	general
uil10n.show_db_icon = "Show DBIcon around minimap";
uil10n.show_buttons_in_log = "Show buttons in questlog";
uil10n.show_id_in_tooltip = "Show ID in tooltip";
uil10n.show_quest_starter = "Show Quest Giver";
uil10n.show_quest_ender = "Show Quest Turn In";
uil10n.quest_lvl_lowest_ofs = "Lowest Level Offset";
uil10n.quest_lvl_highest_ofs = "Highest Level Offset";
uil10n.limit_item_starter_drop = "Show items quest giver only if the drop rate is above 10%";
uil10n.limit_item_starter_drop_num_coords  = "Show items quest giver with no more than 5 coords";
uil10n.node_menu_modifier = "Modifier of poping menu of pin";
--	map
uil10n.min_rate = "Minium Drop Rate";
--	worldmap
uil10n.worldmap_alpha = "Alpha of icons on world map";
uil10n.worldmap_normal_size = "Size of WorldMap normal pins";
uil10n.worldmap_large_size = "Size of WorldMap BOSS pins";
uil10n.worldmap_varied_size = "Size of WorldMap NPC pins";
uil10n.worldmap_pin_scale_max = "Maxium scale size";
uil10n.show_in_continent = "Show pins in continents";
--	minimap
uil10n.minimap_alpha = "Alpha of icons on minimap";
uil10n.minimap_normal_size = "Size of Minimap normal pins";
uil10n.minimap_large_size = "Size of Minimap BOSS pins";
uil10n.minimap_varied_size = "Size of Minimap NPC pins";
uil10n.minimap_node_inset = "Hide pin on the border of minimap";
uil10n.minimap_player_arrow_on_top = "Player arrow on the top of minimap";
--	interact
uil10n.auto_accept = "Quest Auto Accept";
uil10n.auto_complete = "Quest Auto Complete";
uil10n.quest_auto_inverse_modifier = "Auto-Turn-In inverse modifier";
uil10n.objective_tooltip_info = "Info in objective's tooltip";
--	questlogframe
uil10n.show_quest = "Show";
uil10n.hide_quest = "Hide";
uil10n.reset_filter = "Reset";
--	pin-onmenu
uil10n.pin_menu_hide_quest = "|cffff3f00Hide|r ";
uil10n.pin_menu_show_quest = "|cff00ff00Show|r ";
uil10n.pin_menu_send_quest = "|cffff7f00Send|r";
--
uil10n.CODEX_LITE_CONFLICTS = "Disable ClassicCodex and Questie, then reload UI?";
