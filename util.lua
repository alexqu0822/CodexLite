--[[--
	by ALA @ 163UI/网易有爱, http://wowui.w.163.com/163ui/
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;

-->		variables
	local pcall = pcall;
	local type = type;
	local select = select;
	local next = next;
	local strsplit, strmatch, gsub, format = string.split, string.match, string.gsub, string.format;
	local tonumber = tonumber;
	local GetItemInfoInstant = GetItemInfoInstant;
	local UnitGUID = UnitGUID;
	local UnitIsPlayer = UnitIsPlayer;
	local GetFactionInfoByID = GetFactionInfoByID;
	local IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown = IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown;
	local GetQuestTagInfo = GetQuestTagInfo;
	local GetQuestLogTitle = GetQuestLogTitle;
	local GetQuestLogSelection = GetQuestLogSelection;
	local GetItemCount = GetItemCount;
	local GetMouseFocus = GetMouseFocus;
	local IsModifiedClick = IsModifiedClick;
	local Ambiguate = Ambiguate;

	local GetNumActiveQuests = C_GossipInfo.GetNumActiveQuests;
	local GetActiveQuests = C_GossipInfo.GetActiveQuests;
	local SelectActiveQuest = C_GossipInfo.SelectActiveQuest;
	local GetNumAvailableQuests = C_GossipInfo.GetNumAvailableQuests;
	local GetAvailableQuests = C_GossipInfo.GetAvailableQuests;
	local SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest;
	local GetActiveTitle = GetActiveTitle;
	local GetAvailableTitle = GetAvailableTitle;
	local AcceptQuest = AcceptQuest;
	local IsQuestCompletable = IsQuestCompletable;
	local CompleteQuest = CompleteQuest;
	local GetNumQuestChoices = GetNumQuestChoices;
	local GetQuestReward = GetQuestReward;
	local ConfirmAcceptQuest = ConfirmAcceptQuest;
	local GetQuestLogIndexByID = GetQuestLogIndexByID;
	local GetQuestLogIsAutoComplete = GetQuestLogIsAutoComplete;
	local ShowQuestComplete = ShowQuestComplete;
	local StaticPopup_Hide = StaticPopup_Hide;

	local CreateFrame = CreateFrame;
	local ChatEdit_GetActiveWindow = ChatEdit_GetActiveWindow;
	local ChatEdit_InsertLink = ChatEdit_InsertLink;
	local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter;
	local UIParent = UIParent;
	local GameTooltip = GameTooltip;
	local ItemRefTooltip = ItemRefTooltip;
	local WorldMapFrame = WorldMapFrame;
	local ChatFrame2 = ChatFrame2;
	local QuestFrame = QuestFrame;
	local QuestLogFrame = QuestLogFrame;
	local QuestLogListScrollFrame = QuestLogListScrollFrame;
	local QuestLogDetailScrollChildFrame = QuestLogDetailScrollChildFrame;
	local QuestLogDescriptionTitle = QuestLogDescriptionTitle or QuestInfoDescriptionHeader;
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
	local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS;
	local _G = _G;

-->
	local DataAgent = DT.DB;
	local l10n = CT.l10n;

	local EventAgent = VT.EventAgent;

	local __MAIN_META = VT.MAIN_META;
	local __MAIN_OBJ_LOOKUP = VT.MAIN_OBJ_LOOKUP;
	local __MAIN_QUESTS_COMPLETED = VT.MAIN_QUESTS_COMPLETED;
	local __COMM_META = VT.COMM_META;

	local TIP_IMG_S_NORMAL = CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_S_NORMAL];
	local IMG_TAG_CPL = "|T" .. CT.TEXTUREPATH .. "TAG_CPL" .. ":0|t";
	local IMG_TAG_PRG = "|T" .. CT.TEXTUREPATH .. "TAG_PRG" .. ":0|t";
	local IMG_TAG_UNCPL = "|T" .. CT.TEXTUREPATH .. "TAG_UNCPL" .. ":0|t";

-->
MT.BuildEnv("util");
-->		UTIL
	local quest_auto_inverse_modifier = IsShiftKeyDown;
	-->		methods
		local function GetLevelTag(quest, info, modifier, colored)
			local lvl_str = "[";
				local tag = GetQuestTagInfo(quest);
				if tag ~= nil then
					tag = l10n.ui.QUEST_TAG[tag];
				end
				local min = info.min;
				local lvl = info.lvl;
				if lvl <= 0 then
					lvl = min;
				end
				if colored ~= false then
					if lvl >= VT.QuestLvRed then
						lvl_str = lvl_str .. "|cffff0000" .. (tag ~= nil and (lvl .. tag) or lvl) .. "|r";
					elseif lvl >= VT.QuestLvOrange then
						lvl_str = lvl_str .. "|cffff7f7f" .. (tag ~= nil and (lvl .. tag) or lvl) .. "|r";
					elseif lvl >= VT.QuestLvYellow then
						lvl_str = lvl_str .. "|cffffff00" .. (tag ~= nil and (lvl .. tag) or lvl) .. "|r";
					elseif lvl >= VT.QuestLvGreen then
						lvl_str = lvl_str .. "|cff7fbf3f" .. (tag ~= nil and (lvl .. tag) or lvl) .. "|r";
					else
						lvl_str = lvl_str .. "|cff7f7f7f" .. (tag ~= nil and (lvl .. tag) or lvl) .. "|r";
					end
					if modifier then
						lvl_str = lvl_str .. "/";
						local diff = min - VT.PlayerLevel;
						if diff > 0 then
							if diff > 1 then
								lvl_str = lvl_str .. "|cffff3f3f" .. min .. "|r";
							else
								lvl_str = lvl_str .. "|cffff0f0f" .. min .. "|r";
							end
						else
							if min >= VT.QuestLvRed then
								lvl_str = lvl_str .. "|cffff0000" .. min .. "|r";
							elseif min >= VT.QuestLvOrange then
								lvl_str = lvl_str .. "|cffff7f7f" .. min .. "|r";
							elseif min >= VT.QuestLvYellow then
								lvl_str = lvl_str .. "|cffffff00" .. min .. "|r";
							elseif min >= VT.QuestLvGreen then
								lvl_str = lvl_str .. "|cff7fbf3f" .. min .. "|r";
							else
								lvl_str = lvl_str .. "|cff7f7f7f" .. min .. "|r";
							end
						end
					end
				else
					if lvl >= VT.QuestLvRed then
						lvl_str = lvl_str .. (tag ~= nil and (lvl .. tag) or lvl);
					elseif lvl >= VT.QuestLvOrange then
						lvl_str = lvl_str .. (tag ~= nil and (lvl .. tag) or lvl);
					elseif lvl >= VT.QuestLvYellow then
						lvl_str = lvl_str .. (tag ~= nil and (lvl .. tag) or lvl);
					elseif lvl >= VT.QuestLvGreen then
						lvl_str = lvl_str .. (tag ~= nil and (lvl .. tag) or lvl);
					else
						lvl_str = lvl_str .. (tag ~= nil and (lvl .. tag) or lvl);
					end
					if modifier then
						lvl_str = lvl_str .. "/";
						local diff = min - VT.PlayerLevel;
						if diff > 0 then
							if diff > 1 then
								lvl_str = lvl_str .. min;
							else
								lvl_str = lvl_str .. min;
							end
						else
							if min >= VT.QuestLvRed then
								lvl_str = lvl_str .. min;
							elseif min >= VT.QuestLvOrange then
								lvl_str = lvl_str .. min;
							elseif min >= VT.QuestLvYellow then
								lvl_str = lvl_str .. min;
							elseif min >= VT.QuestLvGreen then
								lvl_str = lvl_str .. min;
							else
								lvl_str = lvl_str .. min;
							end
						end
					end
				end
				lvl_str = lvl_str .. "]";
			return lvl_str;
		end
		local function GetPlayerTag(name, class)
			if class == nil then
				return " > " .. name;
			else
				local color = RAID_CLASS_COLORS[class];
				local coord = CLASS_ICON_TCOORDS[class];
				return format(" > |TInterface\\TargetingFrame\\UI-Classes-Circles:0:0:0:0:256:256:%d:%d:%d:%d|t |cff%.2x%.2x%.2x%s|r",
							coord[1] * 255, coord[2] * 255, coord[3] * 255, coord[4] * 255,
							color.r * 255, color.g * 255, color.b * 255, name
						);
			end
		end
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
		local function TooltipSetQuestTip(tip, uuid, META)
			local modifier = IsShiftKeyDown();
			local refs = uuid[4];
			if next(refs) ~= nil then
				META = META or __MAIN_META;
				for quest, ref in next, refs do
					local meta = META[quest];
					local info = DataAgent.quest[quest];
					local color = CT.IMG_LIST[MT.GetQuestStartTexture(info)];
					--[[
						local lvl_str = "|cff000000**|r[ ";
							local lvl = info.lvl;
							local min = info.min;
							lvl_str = lvl_str .. l10n.ui.TIP_QUEST_LVL;
							if lvl >= VT.QuestLvRed then
								lvl_str = lvl_str .. "|cffff0000" .. lvl .. "|r ";
							elseif lvl >= VT.QuestLvOrange then
								lvl_str = lvl_str .. "|cffff7f7f" .. lvl .. "|r ";
							elseif lvl >= VT.QuestLvYellow then
								lvl_str = lvl_str .. "|cffffff00" .. lvl .. "|r ";
							elseif lvl >= VT.QuestLvGreen then
								lvl_str = lvl_str .. "|cff7fbf3f" .. lvl .. "|r ";
							else
								lvl_str = lvl_str .. "|cff7f7f7f" .. lvl .. "|r ";
							end
							lvl_str = lvl_str .. l10n.ui.TIP_QUEST_MIN;
							if min >= VT.QuestLvRed then
								lvl_str = lvl_str .. "|cffff0000" .. min .. "|r ]|cff000000**|r";
							elseif min >= VT.QuestLvOrange then
								lvl_str = lvl_str .. "|cffff7f7f" .. min .. "|r ]|cff000000**|r";
							elseif min >= VT.QuestLvYellow then
								lvl_str = lvl_str .. "|cffffff00" .. min .. "|r ]|cff000000**|r";
							elseif min >= VT.QuestLvGreen then
								lvl_str = lvl_str .. "|cff7fbf3f" .. min .. "|r ]|cff000000**|r";
							else
								lvl_str = lvl_str .. "|cff7f7f7f" .. min .. "|r ]|cff000000**|r";
							end
						if meta ~= nil then
							if line == 'start' then
								tip:AddLine(TIP_IMG_S_NORMAL .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								if modifier then
									local loc = l10n.quest[quest];
									if loc ~= nil and loc[3] ~= nil then
										for _, text in next, loc[3] do
											tip:AddLine("|cff000000**|r" .. text, 1.0, 0.75, 0.0);
										end
									end
								end
							elseif line == 'end' then
								if meta.completed == 1 then
									tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_COMPLETED] .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
									tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								elseif meta.completed == 0 then
									tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_UNCOMPLETED] .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
									tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								end
								if modifier then
									local loc = l10n.quest[quest];
									if loc ~= nil and loc[3] ~= nil then
										for _, text in next, loc[3] do
											tip:AddLine("|cff000000**|r" .. text, 1.0, 0.75, 0.0);
										end
									end
								end
							elseif line == 'event' then
								tip:AddLine(TIP_IMG_S_NORMAL .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								for index = 1, #meta do
									local meta_line = meta[index];
									if meta_line[2] == 'event' or meta_line[2] == 'log' then
										tip:AddLine("|cff000000**|r" .. meta_line[4], 1.0, 0.5, 0.0);
									end
								end
							else
								tip:AddLine(TIP_IMG_S_NORMAL .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								tip:AddLine(lvl_str, 1.0, 1.0, 1.0);
								if line > 0 then
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("|cff000000**|r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("|cff000000**|r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								else
									line = - line;
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("|cff000000**|r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("|cff000000**|r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								end
							end
						else
							local loc = l10n.quest[quest];
							if loc ~= nil then
								tip:AddLine(TIP_IMG_S_NORMAL .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
								if modifier and loc[3] then
									for _, text in next, loc[3] do
										tip:AddLine("|cff000000**|r" .. text, 1.0, 0.75, 0.0);
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
						if VT.SETTING.show_id_in_tooltip then
							if ref['end'] then
								if meta.completed == 1 then
									tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_COMPLETED] .. lvl_str .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								elseif meta.completed == 0 then
									tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_UNCOMPLETED] .. lvl_str .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
								end
							else
								tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. meta.title .. "(" .. quest .. ")", color[2], color[3], color[4]);
							end
						else
							if ref['end'] then
								if meta.completed == 1 then
									tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_COMPLETED] .. lvl_str .. meta.title, color[2], color[3], color[4]);
								elseif meta.completed == 0 then
									tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_UNCOMPLETED] .. lvl_str .. meta.title, color[2], color[3], color[4]);
								end
							else
								tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. meta.title, color[2], color[3], color[4]);
							end
						end
						for line, _ in next, ref do
							if line == 'start' or line == 'end' then
								if modifier then
									local loc = l10n.quest[quest];
									if loc ~= nil and loc[3] ~= nil then
										for _, text in next, loc[3] do
											tip:AddLine("|cff000000**|r" .. text, 1.0, 0.75, 0.0);
										end
									end
								end
							elseif line == 'extra' then
							else
								if line > 0 then
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("|cff000000**|r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("|cff000000**|r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								else
									line = - line;
									local meta_line = meta[line];
									if meta_line ~= nil then
										if meta_line[5] then
											tip:AddLine("|cff000000**|r" .. meta_line[4], 0.5, 1.0, 0.0);
										else
											tip:AddLine("|cff000000**|r" .. meta_line[4], 1.0, 0.5, 0.0);
										end
									end
								end
							end
						end
					else
						local loc = l10n.quest[quest];
						if loc ~= nil and loc[1] ~= nil then
							if VT.SETTING.show_id_in_tooltip then
								tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
							else
								tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. loc[1], color[2], color[3], color[4]);
							end
							if modifier and loc[3] then
								for _, text in next, loc[3] do
									tip:AddLine("|cff000000**|r" .. text, 1.0, 0.75, 0.0);
								end
							end
						else
							tip:AddLine(TIP_IMG_S_NORMAL .. lvl_str .. "quest:" .. quest, color[2], color[3], color[4]);
						end
					end
				end
			end
		end
		local function OnTooltipSetUnit(tip)
			tip.__TextLeft1Text = nil;
			if VT.SETTING.objective_tooltip_info then
				local _, unit = tip:GetUnit();
				if unit and not UnitIsPlayer(unit) then
					local GUID = UnitGUID(unit);
					if GUID ~= nil then
						-- local _, _, _id = strfind(GUID, "Creature%-0%-%d+%-%d+%-%d+%-(%d+)%-%x+");
						local _type, _, _, _, _, _id = strsplit("-", GUID);
						if (_type == "Creature" or _type == "Vehicle") and _id ~= nil then
							_id = tonumber(_id);
							if _id ~= nil then
								local reshow = false;
								local uuid = MT.CoreGetUUID('unit', _id);
								if uuid ~= nil then
									TooltipSetQuestTip(tip, uuid);
									reshow = true;
								end
								for name, val in next, VT.COMM_GROUP_MEMBERS do
									local meta_table = __COMM_META[name];
									if meta_table ~= nil then
										local uuid = MT.CommGetUUID(name, 'unit', _id);
										if uuid ~= nil and next(uuid[4]) ~= nil then
											local info = VT.COMM_GROUP_MEMBERS_INFO[name];
											tip:AddLine(GetPlayerTag(name, info ~= nil and info[4]));
											TooltipSetQuestTip(tip, uuid, meta_table);
											reshow = true;
										end
									end
								end
								if reshow then
									tip:Show();
								end
							end
						end
					end
				end
			end
		end
		local function OnTooltipSetItem(tip)
			tip.__TextLeft1Text = nil;
			if VT.SETTING.objective_tooltip_info then
				local name, link = tip:GetItem();
				if link ~= nil then
					local id = GetItemInfoInstant(link);
					if id ~= nil then
						local QUESTS = DataAgent.item_related_quest[id];
						if QUESTS ~= nil and QUESTS[1] ~= nil then
							local reshow = false;
							local modifier = IsShiftKeyDown();
							for _, quest in next, QUESTS do
								local meta = __MAIN_META[quest];
								if meta ~= nil then
									local qinfo = DataAgent.quest[quest];
									local color = CT.IMG_LIST[MT.GetQuestStartTexture(qinfo)];
									local lvl_str = GetLevelTag(quest, qinfo, modifier);
									if modifier then
										if meta.completed == 1 then
											tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_COMPLETED] .. IMG_TAG_PRG .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
										elseif meta.completed == 0 then
											tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_UNCOMPLETED] .. IMG_TAG_PRG .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
										end
									else
										if meta.completed == 1 then
											tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_COMPLETED] ..  lvl_str .. meta.title, 1.0, 0.9, 0.0);
										elseif meta.completed == 0 then
											tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_UNCOMPLETED] .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
										end
									end
									for index = 1, #meta do
										local meta_line = meta[index];
										if meta_line[2] == 'item' and meta_line[3] == id then
											if meta_line[5] then
												tip:AddLine("|cff000000**|r" .. meta_line[4], 0.5, 1.0, 0.0);
											else
												tip:AddLine("|cff000000**|r" .. meta_line[4], 1.0, 0.5, 0.0);
											end
											break;
										end
									end
									reshow = true;
								end
							end
							if modifier then
								for _, quest in next, QUESTS do
									if __MAIN_META[quest] == nil and DataAgent.avl_quest_hash[quest] ~= nil then
										local qinfo = DataAgent.quest[quest];
										local color = CT.IMG_LIST[MT.GetQuestStartTexture(qinfo)];
										local lvl_str = GetLevelTag(quest, qinfo, true);
										local loc = l10n.quest[quest];
										if loc ~= nil then
											if VT.SETTING.show_id_in_tooltip then
												if __MAIN_QUESTS_COMPLETED[quest] ~= nil then
													tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_CPL .. lvl_str .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
												else
													tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_UNCPL .. lvl_str .. loc[1] .. "(" .. quest .. ")", color[2], color[3], color[4]);
												end
											else
												if __MAIN_QUESTS_COMPLETED[quest] ~= nil then
													tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_CPL .. lvl_str .. loc[1], color[2], color[3], color[4]);
												else
													tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_UNCPL .. lvl_str .. loc[1], color[2], color[3], color[4]);
												end
											end
										else
											if __MAIN_QUESTS_COMPLETED[quest] ~= nil then
												tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_CPL .. lvl_str .. "quest:" .. quest, color[2], color[3], color[4]);
											else
												tip:AddLine(TIP_IMG_S_NORMAL .. IMG_TAG_UNCPL .. lvl_str .. "quest:" .. quest, color[2], color[3], color[4]);
											end
										end
										reshow = true;
									end
								end
							end
							for name, val in next, VT.COMM_GROUP_MEMBERS do
								local meta_table = __COMM_META[name];
								if meta_table ~= nil then
									local first_line_of_partner = true;
									for _, quest in next, QUESTS do
										local meta = meta_table[quest];
										if meta ~= nil then
											if first_line_of_partner then
												first_line_of_partner = false;
												local info = VT.COMM_GROUP_MEMBERS_INFO[name];
												tip:AddLine(GetPlayerTag(name, info ~= nil and info[4]));
											end
											local qinfo = DataAgent.quest[quest];
											local color = CT.IMG_LIST[MT.GetQuestStartTexture(qinfo)];
											local lvl_str = GetLevelTag(quest, qinfo, modifier);
											if meta.completed == 1 then
												tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_COMPLETED] ..  lvl_str .. meta.title, 1.0, 0.9, 0.0);
											elseif meta.completed == 0 then
												tip:AddLine(CT.TIP_IMG_LIST[CT.IMG_INDEX.IMG_E_UNCOMPLETED] .. lvl_str .. meta.title, 1.0, 0.9, 0.0);
											end
											for index = 1, #meta do
												local meta_line = meta[index];
												if meta_line[2] == 'item' and meta_line[3] == id then
													if meta_line[5] then
														tip:AddLine("|cff000000**|r" .. meta_line[4], 0.5, 1.0, 0.0);
													else
														tip:AddLine("|cff000000**|r" .. meta_line[4], 1.0, 0.5, 0.0);
													end
													break;
												end
											end
										end
									end
								end
							end
							if reshow then
								tip:Show();
							end
						end
					end
				end
			end
		end
		--	object
		local updateTimer = 0.0;
		local function TooltipOnUpdate(tip, elasped)
			if VT.SETTING.objective_tooltip_info and tip:GetOwner() == UIParent then
				if updateTimer <= 0.0 then
					updateTimer = 0.1;
					if tip:GetUnit() == nil and tip:GetItem() == nil then
						tip.__TextLeft1 = tip.__TextLeft1 or _G[tip:GetName() .. "TextLeft1"];
						local text = tip.__TextLeft1:GetText();
						if text ~= nil and text ~= tip.__TextLeft1Text then
							local reshow = false;
							tip.__TextLeft1Text = text;
							local map = MT.GetPlayerZone();
							local oids = __MAIN_OBJ_LOOKUP[map] ~= nil and __MAIN_OBJ_LOOKUP[map][text] or __MAIN_OBJ_LOOKUP["*"][text];
							if oids ~= nil and #oids > 0 then
								local oid = oids[1];
								if #oids > 1 then
									local continent, x, y = MT.GetUnitPosition('player');
									local mindist2 = 4294967295;
									for i = 1, #oids do
										local id = oids[i];
										local info = DataAgent.object[id];
										if info ~= nil and info.wcoords ~= nil then
											for j = 1, #info.wcoords do
												local coords = info.wcoords[j];
												if coords[3] == continent then
													local dist2 = (coords[1] - x) * (coords[1] - x) + (coords[2] - y) * (coords[2] - y);
													if dist2 < mindist2 then
														oid = oids[i];
														mindist2 = dist2;
													end
												end
											end
										end
									end
								end
								local uuid = MT.CoreGetUUID('object', oid);
								if uuid ~= nil then
									TooltipSetQuestTip(tip, uuid);
									reshow = true;
								end
								for name, val in next, VT.COMM_GROUP_MEMBERS do
									local meta_table = __COMM_META[name];
									if meta_table ~= nil then
										local uuid = MT.CommGetUUID(name, 'object', oid);
										if uuid ~= nil and next(uuid[4]) ~= nil then
											local info = VT.COMM_GROUP_MEMBERS_INFO[name];
											tip:AddLine(GetPlayerTag(name, info ~= nil and info[4]));
											TooltipSetQuestTip(tip, uuid, meta_table);
											reshow = true;
										end
									end
								end
							end
							if reshow then
								tip:Show();
							end
						end
					end
				else
					updateTimer = updateTimer - elasped;
				end
			end
		end
		function EventAgent.MODIFIER_STATE_CHANGED()
			local focus = GetMouseFocus();
			if focus ~= nil and focus.__PIN_TAG ~= nil then
				MT.Pin_OnEnter(focus);
			elseif GameTooltip:IsShown() then
			end
		end
		function MT.TooltipSetInfo(tip, type, id)
			if type == 'event' then
				tip:AddLine(l10n.ui.TIP_WAYPOINT, 0.0, 1.0, 0.0);
			elseif type == 'extra' then
			else
				local _loc = l10n[type];
				if _loc ~= nil then
					if VT.SETTING.show_id_in_tooltip then
						if type == 'unit' then
							local info = DataAgent.unit[id];
							if info ~= nil then
								if VT.IsUnitFacFriend[info.fac] then
									tip:AddLine(_loc[id] .. "(" .. id .. ")", 0.0, 1.0, 0.0);
								else
									local facId = info.facId;
									if facId ~= nil then
										local _, _, standing_rank, _, _, val = GetFactionInfoByID(facId);
										if standing_rank == nil then
											tip:AddLine(_loc[id] .. "(" .. id .. ")", 1.0, 0.0, 0.0);
										elseif standing_rank == 4 then
											tip:AddLine(_loc[id] .. "(" .. id .. ")", 1.0, 1.0, 0.0);
										elseif standing_rank < 4 then
											tip:AddLine(_loc[id] .. "(" .. id .. ")", 1.0, (standing_rank - 1) * 0.25, 0.0);
										else
											tip:AddLine(_loc[id] .. "(" .. id .. ")", 0.5 - (standing_rank - 4) * 0.125, 1.0, 0.0);
										end
									else
										tip:AddLine(_loc[id] .. "(" .. id .. ")", 1.0, 0.0, 0.0);
									end
								end
							end
						else
							tip:AddLine(_loc[id] .. "(" .. id .. ")", 1.0, 1.0, 1.0);
						end
					else
						if type == 'unit' then
							local info = DataAgent.unit[id];
							if info ~= nil then
								if VT.IsUnitFacFriend[info.fac] then
									tip:AddLine(_loc[id], 0.0, 1.0, 0.0);
								else
									local facId = info.facId;
									if facId ~= nil then
										local _, _, standing_rank, _, _, val = GetFactionInfoByID(facId);
										if standing_rank == nil then
											tip:AddLine(_loc[id], 1.0, 0.0, 0.0);
										elseif standing_rank == 4 then
											tip:AddLine(_loc[id], 1.0, 1.0, 0.0);
										elseif standing_rank < 4 then
											tip:AddLine(_loc[id], 1.0, (standing_rank - 1) * 0.25, 0.0);
										else
											tip:AddLine(_loc[id], 0.5 - (standing_rank - 4) * 0.125, 1.0, 0.0);
										end
									else
										tip:AddLine(_loc[id], 1.0, 0.0, 0.0);
									end
								end
							end
						else
							tip:AddLine(_loc[id], 1.0, 1.0, 1.0);
						end
					end
				end
			end
			local uuid = MT.CoreGetUUID(type, id);
			if uuid ~= nil then
				TooltipSetQuestTip(tip, uuid);
			end
			for name, val in next, VT.COMM_GROUP_MEMBERS do
				local meta_table = __COMM_META[name];
				if meta_table ~= nil then
					local uuid = MT.CommGetUUID(name, type, id);
					if uuid ~= nil and next(uuid[4]) ~= nil then
						local info = VT.COMM_GROUP_MEMBERS_INFO[name];
						tip:AddLine(GetPlayerTag(name, info ~= nil and info[4]));
						TooltipSetQuestTip(tip, uuid, meta_table);
					end
				end
			end
		end
		function MT.button_info_OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			local info_lines = self.info_lines;
			if info_lines then
				for index = 1, #info_lines do
					GameTooltip:AddLine(info_lines[index]);
				end
			end
			GameTooltip:Show();
		end
		function MT.OnLeave(self)
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide();
			end
		end
		local function drop_handler_send(_, _, quest)
			local info = DataAgent.quest[quest];
			local loc = l10n.quest[quest];
			local lvl = info.lvl;
			if lvl <= 0 then
				lvl = info.min;
			end
			local activeWindow = ChatEdit_GetActiveWindow();
			if activeWindow ~= nil then
				activeWindow:Insert("[[" .. lvl .. "] " .. (loc ~= nil and loc[1] or "Quest: " .. quest) .. " (" .. quest .. ")]");
			end
			-- ChatEdit_InsertLink("[[" .. lvl .. "] " .. (loc ~= nil and loc[1] or "Quest: " .. quest) .. " (" .. quest .. ")]");
		end
		local function drop_handler_toggle(_, _, quest)
			MT.MapPermanentlyToggleQuestNodes(quest);
		end
		local function GetQuestTitle(quest, modifier)
			local info = DataAgent.quest[quest];
			local color = CT.IMG_LIST[MT.GetQuestStartTexture(info)];
			local lvl_str = GetLevelTag(quest, info, modifier);
			local loc = l10n.quest[quest];
			return lvl_str .. "|c" .. color[5] .. (loc ~= nil and (loc[1] .. "(" .. quest .. ")") or "quest: " .. quest) .. "|r";
		end
		function MT.NodeOnModifiedClick(node, uuid)
			local refs = uuid[4];
			if ChatEdit_GetActiveWindow() then
				local data = { handler = drop_handler_send, num = 0, };
				for quest, val in next, refs do
					data.num = data.num + 1;
					data[data.num] = {
						text = l10n.ui.pin_menu_send_quest .. GetQuestTitle(quest, true);
						param = quest,
					};
				end
				VT.__menulib.ShowMenu(node, "BOTTOMLEFT", data);
				return true;
			else
				for quest, val in next, refs do
					if val["start"] ~= nil then
						local data = { handler = drop_handler_toggle, num = 0, };
						for quest, val in next, refs do
							if val["start"] ~= nil then
								if VT.QUEST_PREMANENTLY_BLOCKED[quest] then
									data.num = data.num + 1;
									data[data.num] = {
										text = l10n.ui.pin_menu_show_quest .. GetQuestTitle(quest, true);
										param = quest,
									};
								else
									data.num = data.num + 1;
									data[data.num] = {
										text = l10n.ui.pin_menu_hide_quest .. GetQuestTitle(quest, true);
										param = quest,
									};
								end
							end
						end
						VT.__menulib.ShowMenu(node, "BOTTOMLEFT", data);
						return true;
					end
				end
			end
		end
	-->		Auto Accept and Turnin
		function EventAgent.GOSSIP_SHOW()
			local modstate = not quest_auto_inverse_modifier();
			if not VT.SETTING.auto_complete ~= modstate then
				local quests = GetActiveQuests();
				for i = 1, GetNumActiveQuests() do
					local quest = quests[i];
					-- local title, level, isTrivial, isComplete, isLegendary, isIgnored = select(i * 6 - 5, GetActiveQuests());
					if quest.title and quest.isComplete then
						return SelectActiveQuest(quest.questID);
					end
				end
			end
			if not VT.SETTING.auto_accept ~= modstate then
				local quests = GetAvailableQuests();
				for i = 1, GetNumAvailableQuests() do
					local quest = quests[i];
					-- local title, level, isTrivial, isDaily, isRepeatable, isLegendary, isIgnored = select(i * 7 - 6, GetAvailableQuests());
					if quest.title then
						return SelectAvailableQuest(quest.questID);
					end
				end
			end
			-- if VT.SETTING.auto_accept then
			-- 	for i = 1, GetNumAvailableQuests() do
			-- 		local titleText, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = GetAvailableQuests(i);
			-- 		if title then
			-- 			return SelectAvailableQuest(i);
			-- 		end
			-- 	end
			-- end
		end
		function EventAgent.QUEST_GREETING()
			local modstate = not quest_auto_inverse_modifier();
			if not VT.SETTING.auto_complete ~= modstate then
				for i = 1, GetNumActiveQuests() do
					local title, isComplete = GetActiveTitle(i);
					if title and isComplete then
						return SelectActiveQuest(i);
					end
				end
			end
			if not VT.SETTING.auto_accept ~= modstate then
				for i = 1, GetNumAvailableQuests() do
					local title, isComplete = GetAvailableTitle(i);
					if title then
						return SelectAvailableQuest(i);
					end
				end
			end
		end
		function EventAgent.QUEST_DETAIL()
			local modstate = not quest_auto_inverse_modifier();
			if not VT.SETTING.auto_accept ~= modstate then
				AcceptQuest();
				QuestFrame:Hide();
			end
		end
		function EventAgent.QUEST_PROGRESS()
			local modstate = not quest_auto_inverse_modifier();
			if not VT.SETTING.auto_complete ~= modstate then
				if IsQuestCompletable() then
					CompleteQuest();
				end
			end
		end
		function EventAgent.QUEST_COMPLETE()
			local modstate = not quest_auto_inverse_modifier();
			if not VT.SETTING.auto_complete ~= modstate then
				local _NumChoices = GetNumQuestChoices();
				if _NumChoices <= 1 then
					GetQuestReward(_NumChoices);
				end
			end
		end
		function EventAgent.QUEST_ACCEPT_CONFIRM()
			local modstate = not quest_auto_inverse_modifier();
			if not VT.SETTING.auto_accept ~= modstate then
				ConfirmAcceptQuest() ;
				StaticPopup_Hide("QUEST_ACCEPT");
			end
		end
		function EventAgent.QUEST_AUTOCOMPLETE(id)
			local modstate = not quest_auto_inverse_modifier();
			if not VT.SETTING.auto_complete ~= modstate then
				local index = GetQuestLogIndexByID(id);
				if GetQuestLogIsAutoComplete(index) then
					ShowQuestComplete(index);
				end
			end
		end
		local function SetQuestAutoInverseModifier(modifier)
			if modifier == "SHIFT" then
				quest_auto_inverse_modifier = IsShiftKeyDown;
			elseif modifier == "CTRL" then
				quest_auto_inverse_modifier = IsControlKeyDown;
			elseif modifier == "ALT" then
				quest_auto_inverse_modifier = IsAltKeyDown;
			end
		end
	-->		DBIcon
		local function CreateDBIcon()
			local LibStub = _G.LibStub;
			if LibStub ~= nil then
				local LDI = LibStub("LibDBIcon-1.0", true);
				if LDI then
					local D = nil;
					LDI:Register(
						"CodexLite",
						{
							icon = [[interface\icons\inv_misc_book_09]],
							OnClick = function(self, button)
								if button == "LeftButton" then
									if VT.SettingUI:IsShown() then
										VT.SettingUI:Hide();
									else
										VT.SettingUI:Show();
									end
								else
									VT.SETTING.show_minimappin = not VT.SETTING.show_minimappin;
									MT.MapToggleMinimapPin(VT.SETTING.show_minimappin);
									D:SetShown(not VT.SETTING.show_minimappin);
								end
							end,
							text = "CodexLite",
							OnTooltipShow = function(tt)
								tt:AddLine("CodexLite");
								tt:Show();
							end,
						},
						VT.SVAR.minimap
					);
					LDI:Show(__addon);
					if VT.SETTING.show_db_icon then
						LDI:Show(__addon);
					else
						LDI:Hide(__addon);
					end
					local Icon = LDI:GetMinimapButton(__addon);
					if Icon ~= nil then
						D = Icon:CreateTexture(nil, "OVERLAY");
						D:SetAllPoints(Icon.icon);
						D:SetTexture(CT.TEXTUREPATH .. "close");
						D:SetShown(not VT.SETTING.show_minimappin);
					end
				end
			end
		end
	-->		WorldMapPin Toggle
		local function CreateWorldMapPinSwitch()
			local Switch = CreateFrame('BUTTON', nil, WorldMapFrame, "UIPanelButtonTemplate");
			Switch:SetSize(30, 30);
			Switch:SetText("CL");
			Switch:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -100, -30);
			Switch:RegisterForClicks("AnyUp");
			Switch:SetScript("OnClick", function(self, button)
				if button == "LeftButton" then
					if VT.SettingUI:IsShown() then
						VT.SettingUI:Hide();
					else
						VT.SettingUI:Show();
					end
				else
					VT.SETTING.show_worldmappin = not VT.SETTING.show_worldmappin;
					MT.MapToggleWorldMapPin(VT.SETTING.show_worldmappin);
					Switch.D:SetShown(not VT.SETTING.show_worldmappin);
				end
			end);
			local D = Switch:CreateTexture(nil, "OVERLAY");
			D:SetSize(20, 20);
			D:SetPoint("CENTER");
			D:SetTexture(CT.TEXTUREPATH .. "close");
			D:SetShown(not VT.SETTING.show_worldmappin);
			Switch.D = D;
			VT.__autostyle:AddReskinObject(Switch);
		end
	-->
	-->		Chat
		--
		local function SendFilterRep(id, level, title)
			return "[[" .. gsub(level, "[^0-9]", "") .. "] " .. title .. " (" .. id .. ")]";
		end
		local function SendFilter(msg)
			--"|Hcdxl:([0-9]+)|h|c[0-9a-f]+%[%[(.+)%](.+)%]|r|h"
			return gsub(msg, "|Hcdxl:([0-9]+)|h|c[0-9a-f]+%[%[(.-)%](.-)%(.-%)%]|r|h", SendFilterRep);
		end
	
		local __SendChatMessage = nil;
		local function CdxlSendChatMessage(text, ...)
			__SendChatMessage(SendFilter(text), ...);
		end
		local __BNSendWhisper = nil;
		local function CdxlBNSendWhisper(presenceID, text, ...)
			__BNSendWhisper(presenceID, SendFilter(text), ...);
		end
		local __BNSendConversationMessage = nil;
		local function CdxlBNSendConversationMessage(target, text, ...)
			__BNSendConversationMessage(target, SendFilter(text), ...);
		end
		local function ChatFilterReplacer(body, id)
			local quest = tonumber(id);
			local info = DataAgent.quest[quest];
			local loc = l10n.quest[quest];
			if info ~= nil and loc ~= nil then
				local color = CT.IMG_LIST[MT.GetQuestStartTexture(info)];
				return "|Hcdxl:" .. id .. "|h|c" .. color[5] .. "[" .. GetLevelTag(quest, info, false, false) .. (loc ~= nil and loc[1] .. "(" .. id .. ")" or "Quest: " .. id) .. "]|r|h";
			end
			return body;
		end
		local function ChatFilter(ChatFrame, event, arg1, ...)
			if ChatFrame ~= ChatFrame2 then
				return false, gsub(arg1, "(%[%[[0-9]+%] .- %(([0-9]+)%)%])", ChatFilterReplacer), ...;
			end
			return false, arg1, ...;
		end
		local ItemRefTooltip = ItemRefTooltip;
		local _ItemRefTooltip_SetHyperlink = ItemRefTooltip.SetHyperlink;
		function ItemRefTooltip:SetHyperlink(link, ...)
			local id = strmatch(link, "cdxl:(%d+)");
			if id ~= nil then
				id = tonumber(id);
				if id ~= nil then
					local meta = __MAIN_META[id];
					local info = DataAgent.quest[id];
					if meta ~= nil then
						ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
						local color = CT.IMG_LIST[MT.GetQuestStartTexture(info)];
						ItemRefTooltip:SetText("|c" .. color[5] .. GetLevelTag(id, info, true) .. meta.title .. "|r");
						if meta.completed == 1 then
							ItemRefTooltip:AddLine(l10n.ui.IN_PROGRESS .. " (" .. l10n.ui.COMPLETED .. ")", 0.0, 1.0, 0.0);
						else
							ItemRefTooltip:AddLine(l10n.ui.IN_PROGRESS, 0.75, 1.0, 0.0);
						end
						ItemRefTooltip:AddLine(" ");
						ItemRefTooltip:AddLine(meta.sdesc, 1.0, 1.0, 1.0, true);
						local num = #meta;
						if num > 0 then
							ItemRefTooltip:AddLine(" ");
							for index = 1, num do
								local line = meta[index];
								if line[5] then
									ItemRefTooltip:AddLine(" - " .. line[4], 0.0, 1.0, 0.0);
								else
									ItemRefTooltip:AddLine(" - " .. line[4], 1.0, 0.5, 0.5);
								end
							end
						end
						ItemRefTooltip:Show();
						return;
					else
						local loc = l10n.quest[id];
						if info ~= nil and loc ~= nil then
							ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
							local color = CT.IMG_LIST[MT.GetQuestStartTexture(info)];
							ItemRefTooltip:SetText("|c" .. color[5] .. GetLevelTag(id, info, true) .. (loc ~= nil and loc[1] or "Quest: " .. id) .. "|r");
							if __MAIN_QUESTS_COMPLETED[id] then		--	1 = completed, -1 = excl completed, -2 = next completed
								ItemRefTooltip:AddLine(l10n.ui.COMPLETED, 0.0, 1.0, 0.0);
							end
							local lines = loc[3];
							if lines ~= nil then
								ItemRefTooltip:AddLine(" ");
								for index = 1, #lines do
									ItemRefTooltip:AddLine(lines[index], 1.0, 1.0, 1.0, true);
								end
							end
							ItemRefTooltip:Show();
							return;
						end
					end
				end
			end
			return _ItemRefTooltip_SetHyperlink(self, link, ...);
		end
		local Num_Hooked_QuestLogTitle = 0;
		local function HookQuestLogTitle()
			if Num_Hooked_QuestLogTitle < _G.QUESTS_DISPLAYED then
				for index = Num_Hooked_QuestLogTitle + 1, _G.QUESTS_DISPLAYED do
					local button = _G["QuestLogTitle" .. index] or _G["QuestLogListScrollFrameButton" .. index];
					local script = button:GetScript("OnClick");
					button:SetScript("OnClick", function(self, button)
						if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
							if self.isHeader then
								return;
							end
							local title, level, group, header, collapsed, completed, frequency, quest_id = GetQuestLogTitle(self:GetID());
							local activeWindow = ChatEdit_GetActiveWindow();
							if activeWindow ~= nil then
								activeWindow:Insert("[[" .. level .. "] " .. title .. " (" .. quest_id .. ")]");
								-- local info = DataAgent.quest[quest_id];
								-- if info ~= nil then
								-- 	activeWindow:Insert("|Hcdxl:" .. quest_id .. "|h|c" .. CT.IMG_LIST[MT.GetQuestStartTexture(info)][5] .. "[" .. GetLevelTag(quest_id, info, false, false) .. title .. "(" .. quest_id .. ")]|r|h");
								-- else
								-- 	activeWindow:Insert("[[" .. level .. "] " .. title .. " (" .. quest_id .. ")]");
								-- end
							end
							-- ChatEdit_InsertLink("[[" .. level .. "] " .. title .. " (" .. quest_id .. ")]");
							return;
						end
						return script(self, button);
					end);
					Num_Hooked_QuestLogTitle = index;
				end
			end
		end
		local function InitMessageFactory()
			__SendChatMessage = _G.SendChatMessage;
			_G.SendChatMessage = CdxlSendChatMessage;
			__BNSendWhisper = _G.BNSendWhisper;
			_G.BNSendWhisper = CdxlBNSendWhisper;
			__BNSendConversationMessage = _G.BNSendConversationMessage;
			_G.BNSendConversationMessage = CdxlBNSendConversationMessage;
			QuestLogFrame:HookScript("OnShow", HookQuestLogTitle);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", ChatFilter);		
			ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_BN", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ChatFilter);
			ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ChatFilter);
		end
	-->		QuestLogFrame
		local function CreateQuestLogFrameButton()
			local _ShowQuest = CreateFrame('BUTTON', nil, QuestLogDetailScrollChildFrame, "UIPanelButtonTemplate");
			_ShowQuest:SetSize(85, 21);
			_ShowQuest:SetPoint("TOPLEFT", QuestLogDescriptionTitle, "TOPLEFT", 0, 0);
			_ShowQuest:SetScript("OnClick", function()
				MT.MapTemporarilyShowQuestNodes(select(8, GetQuestLogTitle(GetQuestLogSelection())));
			end);
			_ShowQuest:SetText(l10n.ui.show_quest);
			local _HideQuest = CreateFrame('BUTTON', nil, QuestLogDetailScrollChildFrame, "UIPanelButtonTemplate");
			_HideQuest:SetSize(85, 21);
			_HideQuest:SetPoint("LEFT", _ShowQuest, "RIGHT", 0, 0);
			_HideQuest:SetScript("OnClick", function()
				MT.MapTemporarilyHideQuestNodes(select(8, GetQuestLogTitle(GetQuestLogSelection())));
			end);
			_HideQuest:SetText(l10n.ui.hide_quest);
			local _ResetButton = CreateFrame('BUTTON', nil, QuestLogDetailScrollChildFrame, "UIPanelButtonTemplate");
			_ResetButton:SetSize(85, 21);
			_ResetButton:SetPoint("LEFT", _HideQuest, "RIGHT", 0, 0);
			_ResetButton:SetScript("OnClick", function()
				MT.MapResetTemporarilyQuestNodesFilter();
			end);
			_ResetButton:SetText(l10n.ui.reset_filter);
			VT.QuestLogFrame_ShowQuestButton = _ShowQuest;
			VT.QuestLogFrame_HideQuestButton = _HideQuest;
			VT.QuestLogFrame_ResetQuestButton = _ResetButton;
			QuestLogDescriptionTitle.__defHeight = QuestLogDescriptionTitle:GetHeight();
			if VT.SETTING.show_buttons_in_log then
				QuestLogDescriptionTitle:SetHeight(QuestLogDescriptionTitle.__defHeight + 30);
				QuestLogDescriptionTitle:SetJustifyV("BOTTOM");
				_ShowQuest:Show();
				_HideQuest:Show();
				_ResetButton:Show();
			else
				_ShowQuest:Hide();
				_HideQuest:Hide();
				_ResetButton:Hide();
			end
			VT.__autostyle:AddReskinObject(_ShowQuest);
			VT.__autostyle:AddReskinObject(_HideQuest);
			VT.__autostyle:AddReskinObject(_ResetButton);
		end
		local function SetQuestLogFrameButtonShown(shown)
			if shown then
				QuestLogDescriptionTitle:SetHeight(QuestLogDescriptionTitle.__defHeight + 30);
				QuestLogDescriptionTitle:SetJustifyV("BOTTOM");
				VT.QuestLogFrame_ShowQuestButton:Show();
				VT.QuestLogFrame_HideQuestButton:Show();
				VT.QuestLogFrame_ResetQuestButton:Show();
			else
				QuestLogDescriptionTitle:SetHeight(QuestLogDescriptionTitle.__defHeight);
				VT.QuestLogFrame_ShowQuestButton:Hide();
				VT.QuestLogFrame_HideQuestButton:Hide();
				VT.QuestLogFrame_ResetQuestButton:Hide();
			end
		end
	-->
	-->		extern
		MT.GetQuestTitle = GetQuestTitle;
		MT.SetQuestAutoInverseModifier = SetQuestAutoInverseModifier;
		MT.SetQuestLogFrameButtonShown = SetQuestLogFrameButtonShown;
	-->
	MT.RegisterOnLogin("util", function(LoggedIn)
		GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit);
		GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem);
		ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem);
		GameTooltip:HookScript("OnShow", function(tip)
			tip.__TextLeft1Text = nil;
			updateTimer = 0.0;
		end);
		GameTooltip:HookScript("OnHide", function(tip)
			tip.__TextLeft1Text = nil;
			updateTimer = 0.0;
		end);
		GameTooltip:HookScript("OnUpdate", TooltipOnUpdate);
		EventAgent:RegEvent("MODIFIER_STATE_CHANGED");
		--
		EventAgent:RegEvent("GOSSIP_SHOW");
		EventAgent:RegEvent("QUEST_GREETING");
		EventAgent:RegEvent("QUEST_DETAIL");
		EventAgent:RegEvent("QUEST_PROGRESS");
		EventAgent:RegEvent("QUEST_COMPLETE");
		EventAgent:RegEvent("QUEST_ACCEPT_CONFIRM");
		EventAgent:RegEvent("QUEST_AUTOCOMPLETE");
		--
		CreateDBIcon();
		CreateWorldMapPinSwitch();
		CreateQuestLogFrameButton();
		InitMessageFactory();
		--
		MT.MapToggleWorldMapPin(VT.SETTING.show_worldmappin);
		MT.MapToggleMinimapPin(VT.SETTING.show_minimappin);
		SetQuestAutoInverseModifier(VT.SETTING.quest_auto_inverse_modifier);
	end);

-->
