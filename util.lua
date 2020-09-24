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

-->		variables
	local type = type;
	local next = next;
	local tonumber = tonumber;
	local strsplit = strsplit;
	local GetItemInfoInstant = GetItemInfoInstant;
	local UnitGUID = UnitGUID;
	local UnitIsPlayer = UnitIsPlayer;
	local IsAltKeyDown = IsAltKeyDown;
	local IsControlKeyDown = IsControlKeyDown;
	local IsShiftKeyDown = IsShiftKeyDown;
	local GetItemCount = GetItemCount;
	local GetMouseFocus = GetMouseFocus;
	local GameTooltip = GameTooltip;

	local __db = __ns.db;
	local __db_quest = __db.quest;
	local __db_unit = __db.unit;
	local __db_item = __db.item;
	local __db_object = __db.object;
	local __db_refloot = __db.refloot;
	local __db_event = __db.event;
	local __db_level_quest_list = __db.level_quest_list;
	local __db_avl_quest_hash = __db.avl_quest_hash;
	local __db_blacklist_item = __db.blacklist_item;
	local __db_large_pin = __db.large_pin;
	local __db_item_related_quest = __db.item_related_quest;

	local __loc = __ns.L;
	local __loc_quest = __loc.quest;
	local __loc_unit = __loc.unit;
	local __loc_item = __loc.item;
	local __loc_object = __loc.object;
	local __loc_profession = __loc.profession;
	local __UILOC = __ns.UILOC;

	local __safeCall = __ns.core.__safeCall;
	local __eventHandler = __ns.core.__eventHandler;
	local __const = __ns.core.__const;
	local IMG_INDEX = __ns.core.IMG_INDEX;
	local IMG_LIST = __ns.core.IMG_LIST;
	local TIP_IMG_LIST = __ns.core.TIP_IMG_LIST;
	local GetQuestStartTexture = __ns.core.GetQuestStartTexture;

	local __core_meta = __ns.__core_meta;
	local __obj_lookup = __ns.__obj_lookup;
	local __core_quests_completed = __ns.__core_quests_completed;
	local __map_meta = __ns.__map_meta;
	local __comm_meta = __ns.__comm_meta;
	local __comm_obj_lookup = __ns.__comm_obj_lookup;

	local _log_ = __ns._log_;

	local TIP_IMG_S_NORMAL = TIP_IMG_LIST[IMG_INDEX.IMG_S_NORMAL];
	local IMG_TAG_CPL = "\124T" .. __ns.core.IMG_PATH .. "TAG_CPL" .. ":0\124t";
	local IMG_TAG_PRG = "\124T" .. __ns.core.IMG_PATH .. "TAG_PRG" .. ":0\124t";
	local IMG_TAG_UNCPL = "\124T" .. __ns.core.IMG_PATH .. "TAG_UNCPL" .. ":0\124t";

	local SET = nil;
-->		MAIN
	-->		methods
		-->
		-->
	-->		performance board
		--	display
		local function Create()
			local frame = CreateFrame("FRAME", nil, UIParent);
			frame:SetSize(256, 512);
			frame:SetPoint("CENTER");
		end
	-->		events and hooks
		local function GetLevelTag(quest, info, modifier)
			local lvl_str = "[";
				local tag = __ns.GetQuestTagInfo(quest);
				if tag ~= nil then
					tag = __UILOC.QUEST_TAG[tag];
				end
				local lvl = info.lvl;
				if lvl >= SET.quest_lvl_red then
					lvl_str = lvl_str .. "\124cffff0000" .. (tag ~= nil and (lvl .. tag) or lvl) .. "\124r";
				elseif lvl >= SET.quest_lvl_orange then
					lvl_str = lvl_str .. "\124cffff7f7f" .. (tag ~= nil and (lvl .. tag) or lvl) .. "\124r";
				elseif lvl >= SET.quest_lvl_yellow then
					lvl_str = lvl_str .. "\124cffffff00" .. (tag ~= nil and (lvl .. tag) or lvl) .. "\124r";
				elseif lvl >= SET.quest_lvl_green then
					lvl_str = lvl_str .. "\124cff7fbf3f" .. (tag ~= nil and (lvl .. tag) or lvl) .. "\124r";
				else
					lvl_str = lvl_str .. "\124cff7f7f7f" .. (tag ~= nil and (lvl .. tag) or lvl) .. "\124r";
				end
				if modifier then
					local min = info.min;
					lvl_str = lvl_str .. "/";
					local diff = min - __ns.__player_level;
					if diff > 0 then
						if diff > 1 then
							lvl_str = lvl_str .. "\124cffff3f3f" .. min .. "\124r";
						else
							lvl_str = lvl_str .. "\124cffff0f0f" .. min .. "\124r";
						end
					else
						if min >= SET.quest_lvl_red then
							lvl_str = lvl_str .. "\124cffff0000" .. min .. "\124r";
						elseif min >= SET.quest_lvl_orange then
							lvl_str = lvl_str .. "\124cffff7f7f" .. min .. "\124r";
						elseif min >= SET.quest_lvl_yellow then
							lvl_str = lvl_str .. "\124cffffff00" .. min .. "\124r";
						elseif min >= SET.quest_lvl_green then
							lvl_str = lvl_str .. "\124cff7fbf3f" .. min .. "\124r";
						else
							lvl_str = lvl_str .. "\124cff7f7f7f" .. min .. "\124r";
						end
					end
				end
				lvl_str = lvl_str .. "]";
			return lvl_str;
		end
		local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
		local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS;
		local function GetPlayerTag(name, class)
			if class == nil then
				return " > " .. name;
			else
				local color = RAID_CLASS_COLORS[class];
				local coord = CLASS_ICON_TCOORDS[class];
				return format(" > \124TInterface\\TargetingFrame\\UI-Classes-Circles:0:0:0:0:256:256:%d:%d:%d:%d\124t \124cff%.2x%.2x%.2x%s\124r",
							coord[1] * 256, coord[2] * 256, coord[3] * 256, coord[4] * 256,
							color.r * 255, color.g * 255, color.b * 255, name
						);
			end
		end
		local function GameTooltipSetQuestTip(tip, uuid, META)
			local modifier = IsShiftKeyDown();
			local refs = uuid[4];
			if next(refs) ~= nil then
				for quest, ref in next, refs do
					if META == nil then
						META = __core_meta;
					end
					local meta = META[quest];
					local info = __db_quest[quest];
					local color = IMG_LIST[GetQuestStartTexture(info)];
					--[[
						local lvl_str = "\124cff000000**\124r[ ";
							local lvl = info.lvl;
							local min = info.min;
							lvl_str = lvl_str .. __UILOC.TIP_QUEST_LVL;
							if lvl >= SET.quest_lvl_red then
								lvl_str = lvl_str .. "\124cffff0000" .. lvl .. "\124r ";
							elseif lvl >= SET.quest_lvl_orange then
								lvl_str = lvl_str .. "\124cffff7f7f" .. lvl .. "\124r ";
							elseif lvl >= SET.quest_lvl_yellow then
								lvl_str = lvl_str .. "\124cffffff00" .. lvl .. "\124r ";
							elseif lvl >= SET.quest_lvl_green then
								lvl_str = lvl_str .. "\124cff7fbf3f" .. lvl .. "\124r ";
							else
								lvl_str = lvl_str .. "\124cff7f7f7f" .. lvl .. "\124r ";
							end
							lvl_str = lvl_str .. __UILOC.TIP_QUEST_MIN;
							if min >= SET.quest_lvl_red then
								lvl_str = lvl_str .. "\124cffff0000" .. min .. "\124r ]\124cff000000**\124r";
							elseif min >= SET.quest_lvl_orange then
								lvl_str = lvl_str .. "\124cffff7f7f" .. min .. "\124r ]\124cff000000**\124r";
							elseif min >= SET.quest_lvl_yellow then
								lvl_str = lvl_str .. "\124cffffff00" .. min .. "\124r ]\124cff000000**\124r";
							elseif min >= SET.quest_lvl_green then
								lvl_str = lvl_str .. "\124cff7fbf3f" .. min .. "\124r ]\124cff000000**\124r";
							else
								lvl_str = lvl_str .. "\124cff7f7f7f" .. min .. "\124r ]\124cff000000**\124r";
							end
						if meta ~= nil then
							if line == 'start' then
								tip:AddLine(TIP_IMG_S_NORMAL .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								if modifier then
									local loc = __loc_quest[quest];
									if loc ~= nil and loc[3] ~= nil then
										for _, text in next, loc[3] do
											tip:AddLine("\124cff000000**\124r" .. text, 1.0, 0.75, 0.0);
										end
									end
								end
							elseif line == 'end' then
								if meta.completed == 1 then
									tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_COMPLETED] .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
									tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								elseif meta.completed == 0 then
									tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_UNCOMPLETED] .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
									tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								end
								if modifier then
									local loc = __loc_quest[quest];
									if loc ~= nil and loc[3] ~= nil then
										for _, text in next, loc[3] do
											tip:AddLine("\124cff000000**\124r" .. text, 1.0, 0.75, 0.0);
										end
									end
								end
							elseif line == 'event' then
								tip:AddLine(TIP_IMG_S_NORMAL .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								for index = 1, #meta do
									local meta_line = meta[index];
									if meta_line[2] == 'event' or meta_line[2] == 'log' then
										tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
									end
								end
							else
								tip:AddLine(TIP_IMG_S_NORMAL .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								if line > 0 then
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								else
									line = - line;
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								end
							end
						else
							local loc = __loc_quest[quest];
							if loc ~= nil then
								tip:AddLine(TIP_IMG_S_NORMAL .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
								if modifier and loc[3] then
									for _, text in next, loc[3] do
										tip:AddLine("\124cff000000**\124r" .. text, 1.0, 0.75, 0.0);
									end
								end
							else
								tip:AddLine(TIP_IMG_S_NORMAL .. "quest:" .. quest, color[2], color[3], color[4]);
							end
							tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
						end
					--]]
					local lvl_str = GetLevelTag(quest, info, modifier);
					if meta ~= nil then
						if ref['end'] then
							if meta.completed == 1 then
								tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_COMPLETED] .. lvl_str .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
							elseif meta.completed == 0 then
								tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_UNCOMPLETED] .. lvl_str .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
							end
						else
							tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
						end
						for line, _ in next, ref do
							if line == 'start' or line == 'end' then
								if modifier then
									local loc = __loc_quest[quest];
									if loc ~= nil and loc[3] ~= nil then
										for _, text in next, loc[3] do
											tip:AddLine("\124cff000000**\124r" .. text, 1.0, 0.75, 0.0);
										end
									end
								end
							elseif line == 'event' then
								for index = 1, #meta do
									local meta_line = meta[index];
									if meta_line[2] == 'event' or meta_line[2] == 'log' then
										tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
									end
								end
							else
								if line > 0 then
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								else
									line = - line;
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								end
							end
						end
					else
						local loc = __loc_quest[quest];
						if loc ~= nil then
							tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
							if modifier and loc[3] then
								for _, text in next, loc[3] do
									tip:AddLine("\124cff000000**\124r" .. text, 1.0, 0.75, 0.0);
								end
							end
						else
							tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. "quest:" .. quest, color[2], color[3], color[4]);
						end
					end
				end
				tip:Show();
			end
		end
		local function OnTooltipSetUnit(self)
			local _, unit = self:GetUnit();
			if unit and not UnitIsPlayer(unit) then
				local GUID = UnitGUID(unit);
				if GUID ~= nil then
					-- local _, _, _id = strfind(GUID, "Creature%-0%-%d+%-%d+%-%d+%-(%d+)%-%x+");
					local _type, _, _, _, _, _id = strsplit("-", GUID);
					if _type == "Creature" and _id ~= nil then
						_id = tonumber(_id);
						if _id ~= nil then
							local uuid = __ns.CoreGetUUID('unit', _id);
							if uuid ~= nil then
								GameTooltipSetQuestTip(GameTooltip, uuid);
							end
							for name, val in next, __ns.__group_members do
								local meta_table = __comm_meta[name];
								if meta_table ~= nil then
									local uuid = __ns.CommGetUUID(name, 'unit', _id);
									if uuid ~= nil then
										local _name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(val);
										GameTooltip:AddLine(GetPlayerTag(name, fileName));
										GameTooltipSetQuestTip(GameTooltip, uuid, meta_table);
									end
								end
							end
						end
					end
				end
			end
		end
		local function OnTooltipSetItem(tip)
			local name, link = tip:GetItem();
			if link ~= nil then
				local id = GetItemInfoInstant(link);
				if id ~= nil then
					local QUESTS = __db_item_related_quest[id];
					if QUESTS ~= nil and #QUESTS > 0 then
						local modifier = IsShiftKeyDown();
						for _, quest in next, QUESTS do
							local meta = __core_meta[quest];
							if meta ~= nil then
								local qinfo = __db_quest[quest];
								local color = IMG_LIST[GetQuestStartTexture(qinfo)];
								local lvl_str = GetLevelTag(quest, qinfo, modifier);
								if modifier then
									if meta.completed == 1 then
										tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_COMPLETED] .. IMG_TAG_PRG .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
									elseif meta.completed == 0 then
										tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_UNCOMPLETED] .. IMG_TAG_PRG .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
									end
								else
									if meta.completed == 1 then
										tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_COMPLETED] ..  lvl_str .. meta.title, 1.0, 0.9, 0.0);
									elseif meta.completed == 0 then
										tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_UNCOMPLETED] .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
									end
								end
								for index = 1, #meta do
									local meta_line = meta[index];
									if meta_line[2] == 'item' and meta_line[3] == id then
										if meta_line[5] then
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
										break;
									end
								end
								tip:Show();
							end
						end
						if modifier then
							for _, quest in next, QUESTS do
								if __core_meta[quest] == nil and __db_avl_quest_hash[quest] ~= nil then
									local qinfo = __db_quest[quest];
									local color = IMG_LIST[GetQuestStartTexture(qinfo)];
									local lvl_str = GetLevelTag(quest, qinfo, true);
									local loc = __loc_quest[quest];
									if loc ~= nil then
										if __core_quests_completed[quest] ~= nil then
											tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_CPL .. lvl_str .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
										else
											tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_UNCPL .. lvl_str .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
										end
									else
										if __core_quests_completed[quest] ~= nil then
											tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_CPL .. lvl_str .. "quest:" .. quest, color[2], color[3], color[4]);
										else
											tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_UNCPL .. lvl_str .. "quest:" .. quest, color[2], color[3], color[4]);
										end
									end
									tip:Show();
								end
							end
						end
						for name, val in next, __ns.__group_members do
							local meta_table = __comm_meta[name];
							if meta_table ~= nil then
								local first_line_of_partner = true;
								for _, quest in next, QUESTS do
									local meta = meta_table[quest];
									if meta ~= nil then
										if first_line_of_partner then
											first_line_of_partner = false;
											local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(val);
											GameTooltip:AddLine(GetPlayerTag(name, fileName));
										end
										local qinfo = __db_quest[quest];
										local color = IMG_LIST[GetQuestStartTexture(qinfo)];
										local lvl_str = GetLevelTag(quest, qinfo, modifier);
										if meta.completed == 1 then
											tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_COMPLETED] ..  lvl_str .. meta.title, 1.0, 0.9, 0.0);
										elseif meta.completed == 0 then
											tip:AddLine(TIP_IMG_LIST[IMG_INDEX.IMG_E_UNCOMPLETED] .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
										end
										for index = 1, #meta do
											local meta_line = meta[index];
											if meta_line[2] == 'item' and meta_line[3] == id then
												if meta_line[5] then
													tip:AddLine("\124cff000000**\124r" .. meta_line[4], 0.5, 1.0, 0.0);
												else
													tip:AddLine("\124cff000000**\124r" .. meta_line[4], 1.0, 0.5, 0.0);
												end
												break;
											end
										end
										tip:Show();
									end
								end
							end
						end
					end
				end
			end
		end
		__ns.GameTooltipSetQuestTip = GameTooltipSetQuestTip;
		--	object
		local GameTooltipTextLeft1Text = nil;
		local updateTimer = 0.0;
		local function GameTooltipOnUpdate(self, elasped)
			if updateTimer <= 0.0 then
				updateTimer = 0.1;
				local uname, unit = self:GetUnit();
				local iname, link = self:GetItem();
				if uname == nil and unit == nil and iname == nil and link == nil then
					local text = GameTooltipTextLeft1:GetText();
					if text ~= nil and text ~= GameTooltipTextLeft1Text then
						GameTooltipTextLeft1Text = text;
						local oid = __obj_lookup[text];
						if oid ~= nil then
							local uuid = __ns.CoreGetUUID('object', oid);
							if uuid ~= nil then
								GameTooltipSetQuestTip(GameTooltip, uuid);
							end
							for name, val in next, __ns.__group_members do
								local meta_table = __comm_meta[name];
								if meta_table ~= nil then
									local uuid = __ns.CommGetUUID(name, 'object', oid);
									if uuid ~= nil then
										local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(val);
										GameTooltip:AddLine(GetPlayerTag(name, fileName));
										GameTooltipSetQuestTip(GameTooltip, uuid, meta_table);
									end
								end
							end
						end
						local oid = __comm_obj_lookup[text];
						if oid ~= nil then
						end
					end
				end
			else
				updateTimer = updateTimer - elasped;
			end
		end
		function __ns.MODIFIER_STATE_CHANGED()
			local focus = GetMouseFocus();
			if focus ~= nil and focus.__PIN_TAG ~= nil then
				__ns.Pin_OnEnter(focus);
			end
			if GameTooltip:IsShown() then
			end
		end
	-->
	function __ns.util_setup()
		SET = __ns.__sv;
		GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit);
		GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem);
		ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem);
		GameTooltip:HookScript("OnShow", function()
			GameTooltipTextLeft1Text = nil;
			updateTimer = 0.0;
		end);
		GameTooltip:HookScript("OnHide", function()
			GameTooltipTextLeft1Text = nil;
			updateTimer = 0.0;
		end);
		GameTooltip:HookScript("OnUpdate", GameTooltipOnUpdate);
		__eventHandler:RegEvent("MODIFIER_STATE_CHANGED");
	end
-->

-->		Private
	function __ala_meta__.____OnMapPositionReceived(sender, map, x, y)
		if map > 0 then
			map, x, y = __ns.core.GetZonePositionFromWorldPosition(map, x, y);
		end
		if map ~= nil then
			if map > 0 then
				x = x - x % 0.0001;
				y = y - y % 0.0001;
				print(Ambiguate(sender, 'none'), __ns.L.map[map], x * 100, y * 100);
			else
				print(Ambiguate(sender, 'none'), "副本中");
			end
		end
	end
	local __pull_position_ticker = nil;
	local __listen_name = nil;
	local function __ticker_func_listen_position()
		__ala_meta__.__rt.PullPosition(__listen_name);
	end
	local function ListenPosition(name, period)
		__listen_name = Ambiguate(name, 'none');print('ListenPosition', name, __listen_name)
		if __pull_position_ticker == nil then
			__pull_position_ticker = C_Timer.NewTicker(period or 0.5, __ticker_func_listen_position);
		end
	end
	local function StopListeningPosition()
		if __pull_position_ticker ~= nil then
			__pull_position_ticker:Cancel();
			__pull_position_ticker = nil;
		end
	end
	__ala_meta__.____ListenPosition = ListenPosition;
	__ala_meta__.____StopListeningPosition = StopListeningPosition;
	local B_ERR_CHAT_PLAYER_NOT_FOUND_S = ERR_CHAT_PLAYER_NOT_FOUND_S;
	local P_ERR_CHAT_PLAYER_NOT_FOUND_S = gsub(B_ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", "(.+)");
	local function __listen_position_filter(self, event, msg, ...)
		if __pull_position_ticker ~= nil then
			if B_ERR_CHAT_PLAYER_NOT_FOUND_S ~= ERR_CHAT_PLAYER_NOT_FOUND_S then
				B_ERR_CHAT_PLAYER_NOT_FOUND_S = ERR_CHAT_PLAYER_NOT_FOUND_S;
				P_ERR_CHAT_PLAYER_NOT_FOUND_S = gsub(B_ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", "(.+)");
			end
			local _, _, name = strfind(msg, P_ERR_CHAT_PLAYER_NOT_FOUND_S);
			if name ~= nil then
				if name == __listen_name or Ambiguate(name, 'none') == __listen_name then
					StopListeningPosition();
					print("Cancel tracking ", __listen_name, "[\124cffff0000OFFLINE\124r]");
					return true, msg, ...;
				end
			end
		end
		return false, msg, ...;
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", __listen_position_filter);
-->

--[=[dev]=]	if __ns.__dev then __ns.__performance_log('module.util'); end
