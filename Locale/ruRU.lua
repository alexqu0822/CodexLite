--[[--
	by ALA
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local CT = __private.CT;

if CT.LOCALE ~= "ruRU" then
	return;
end
local uil10n = CT.l10n.ui;
uil10n.LOCALE = "ruRU";


uil10n.LOC_PATTERN = {
	name = "<имя>",
	race = "<раса>",
	class = "<класс>",
};

--	tip
uil10n.TIP_WAYPOINT = "Исследование";
uil10n.TIP_QUEST_LVL = "Ур: ";
uil10n.TIP_QUEST_MIN = "Мин: ";
uil10n.QUEST_TAG = {
	[1] = "+",				--	Group
	[41] = "Г",				--	PVP
	[64] = "Р",				--	Raid
	[81] = "С",				--	Dungeon
	[83] = "Легендарный",
	[85] = "Героический",
	[98] = "Сценарий",
	[102] = "Аккаунт",
	[117] = "Локальное задание Кожевничество",
};
uil10n.COMPLETED = "ЗАВЕРШЕННО";
uil10n.IN_PROGRESS = "Прогресс";
--	setting
uil10n.TAG_SETTING = "перевод Hubbottu@github";
uil10n['tab.general'] = "General";
uil10n['tab.map'] = "Map";
uil10n['tab.worldmap'] = "WorldMap";
uil10n['tab.minimap'] = "MiniMap";
uil10n['tab.interact'] = "Interact";
uil10n['tab.misc'] = "Misc";
uil10n['tab.blocked'] = "Blocked";
uil10n.TAIL_SETTING = "by |cff00ff00ALA|r. Text Data Provided by |cff00ff00EKK|r & |cff00ff00qqyt|r";
--	general
uil10n.show_db_icon = "Показать иконку на мини-карте";
uil10n.show_buttons_in_log = "Show buttons in questlog";
uil10n.show_id_in_tooltip = "Show ID in tooltip";
uil10n.show_quest_starter = "Показать квестодателя";
uil10n.show_quest_ender = "Показать здачу задания";
uil10n.quest_lvl_lowest_ofs = "Смещение к минимальному уровню задания";
uil10n.quest_lvl_highest_ofs = "Смещение к макимальному уровню задания";
uil10n.limit_item_starter_drop = "Show items quest giver only if the drop rate is above 10%";
uil10n.limit_item_starter_drop_num_coords  = "Show items quest giver with no more than 5 coords";
uil10n.node_menu_modifier = "Modifier of poping menu of pin";
--	map
uil10n.min_rate = "Минимальный шанс выпадения";
--	worldmap
uil10n.worldmap_alpha = "Alpha of icons on world map";
uil10n.worldmap_normal_size = "Размер большинства контактов";
uil10n.worldmap_large_size = "Размер отображения босса";
uil10n.worldmap_varied_size = "Размер отображения квестовых NPC";
uil10n.worldmap_pin_scale_max = "Максимальный размер шкалы";
uil10n.show_in_continent = "Show pins in continents";
--	minimap
uil10n.minimap_alpha = "Alpha of icons on minimap";
uil10n.minimap_normal_size = "Размер большинства контактов";
uil10n.minimap_large_size = "Размер отображения босса";
uil10n.minimap_varied_size = "Размер отображения квестовых NPC";
uil10n.minimap_node_inset = "Hide pin on the border of minimap";
uil10n.minimap_player_arrow_on_top = "Player arrow on the top of minimap";
--	interact
uil10n.auto_accept = "Авто принятие задания";
uil10n.auto_complete = "Автозаполнение задания";
uil10n.quest_auto_inverse_modifier = "Отключить автоматическую сдачу";
uil10n.objective_tooltip_info = "Информация в подсказке";
--	questlogframe
uil10n.show_quest = "Показать";
uil10n.hide_quest = "Скрыть";
uil10n.reset_filter = "Обновить";
--	pin-onmenu
uil10n.pin_menu_hide_quest = "|cffff3f00Скрыть|r ";
uil10n.pin_menu_show_quest = "|cff00ff00Показать|r ";
uil10n.pin_menu_send_quest = "|cffff7f00Send|r";
--
uil10n.CODEX_LITE_CONFLICTS = "Отключить ClassicCodex и Questie, а затем перезагрузить интерфейс?";
