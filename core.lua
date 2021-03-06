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
--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.core'); end

-->		variables
	local strfind = strfind;
	local next = next;
	local bit_band = bit.band;
	local GetNumQuestLogEntries = GetNumQuestLogEntries;
	local GetQuestLogTitle = GetQuestLogTitle;
	local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards;
	local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard;
	local GetQuestObjectives = C_QuestLog.GetQuestObjectives;	--	(quest_id)	returns { [line(1, 2, 3, ...)] = { [type], [finished], [numRequired], [numFulfilled], [text] } }
	local GetQuestsCompleted = GetQuestsCompleted;				--	({  } or nil)	return { [quest_id] = completed(true/nil), }
	--	IsQuestComplete(qid)
	--	IsQuestFlaggedCompleted(qid)
	local GetFactionInfoByID = GetFactionInfoByID;
	local GetNumSkillLines = GetNumSkillLines;
	local GetSkillLineInfo = GetSkillLineInfo;

	local __db = __ns.db;
	local __db_quest = __db.quest;
	local __db_unit = __db.unit;
	local __db_item = __db.item;
	local __db_object = __db.object;
	local __db_refloot = __db.refloot;
	local __db_event = __db.event;
	local __db_avl_quest_list = __db.avl_quest_list;
	local __db_avl_quest_hash = __db.avl_quest_hash;
	local __db_blacklist_item = __db.blacklist_item;
	local __db_large_pin = __db.large_pin;
	local __db_chain_prev_quest = __db.chain_prev_quest;

	local __loc = __ns.L;
	local __loc_quest = __loc.quest;
	local __loc_unit = __loc.unit;
	local __loc_item = __loc.item;
	local __loc_object = __loc.object;
	local __loc_profession = __loc.profession;

	local _F_SafeCall = __ns.core._F_SafeCall;
	local __eventHandler = __ns.core.__eventHandler;
	local __const = __ns.core.__const;
	local __L_QUEST_MONSTERS_KILLED = __ns.core.__L_QUEST_MONSTERS_KILLED;
	local __L_QUEST_ITEMS_NEEDED = __ns.core.__L_QUEST_ITEMS_NEEDED;
	local __L_QUEST_OBJECTS_FOUND = __ns.core.__L_QUEST_OBJECTS_FOUND;
	local __L_QUEST_DEFAULT_PATTERN = __ns.core.__L_QUEST_DEFAULT_PATTERN;
	local FindMinLevenshteinDistance = __ns.core.FindMinLevenshteinDistance;
	local PreloadCoords = __ns.core.PreloadCoords;
	local IMG_INDEX = __ns.core.IMG_INDEX;
	local GetQuestStartTexture = __ns.core.GetQuestStartTexture;

	local UnitHelpFac = __ns.core.UnitHelpFac;
	local _log_ = __ns._log_;

	local SET = nil;

	__ns.__player_level = UnitLevel('player');
-->		MAIN
	local show_starter, show_ender = false, false;
	local quest_auto_inverse_modifier = IsShiftKeyDown;
	local META = {  };
	--[[
		[quest_id] = {
			[title],
			[flag]:whether_nodes_added,
			[completed],
			[num_lines],
			[line(1, 2, 3, ...)] = {
				[1] = shown,
				[2] = objective_type,
				[3] = objective_id,
				[4] = description,
				[5] = finished,
				[6] = is_large_pin,
				[7] = one_monster_add_all,
			},
		}
	]]
	local CACHE = {  };	--	如果META初始不为空（从保存变量中加载），需要根据META表初始化
	local OBJ_LOOKUP = {  };
	local QUESTS_COMPLETED = {  };
	__ns.__core_meta = META;
	__ns.__obj_lookup = OBJ_LOOKUP;
	__ns.__core_quests_completed = QUESTS_COMPLETED;
	-->		function predef
		local GetColor3, RelColor3
		local CoreAddUUID, CoreSubUUID, CoreGetUUID;
		local AddCommonNodes, DelCommonNodes, AddLargeNodes, DelLargeNodes, AddVariedNodes, DelVariedNodes;
		local AddUnit, DelUnit, AddObject, DelObject, AddRefloot, DelRefloot, AddItem, DelItem, AddEvent, DelEvent;
		local AddQuester_VariedTexture, DelQuester_VariedTexture, AddQuestStart, DelQuestStart, AddQuestEnd, DelQuestEnd;
		local AddLine, AddLineByID, DelLine, LoadQuestCache, UpdateQuests;
		local UpdateQuestGivers;
		local CalcQuestColor;
	-->		--	color
		local COLOR3 = {  };
		local PALLET = {  };
		do
			PALLET[1] = { 192, 192, 0, };
			PALLET[2] = { 192, 0, 192, };
			PALLET[3] = { 0, 192, 192, };
			for color = 128, 0, -64 do
				for index2 = 1, 3 do
					for index = 1, 3 do
						local color3 = PALLET[index];
						if color3[index2] > 0 then
							PALLET[#PALLET + 1] = {
								index2 == 1 and color or color3[1],
								index2 == 2 and color or color3[2],
								index2 == 3 and color or color3[3],
							};
						end
					end
				end
			end
			PALLET[#PALLET + 1] = { 255, 0, 0, };
			PALLET[#PALLET + 1] = { 0, 255, 0, };
			PALLET[#PALLET + 1] = { 0, 0, 255, };
			PALLET[#PALLET + 1] = { 255, 255, 0, };
			PALLET[#PALLET + 1] = { 255, 0, 255, };
			PALLET[#PALLET + 1] = { 0, 255, 255, };
			PALLET[#PALLET + 1] = { 63, 63, 63, };
			PALLET[#PALLET + 1] = { 191, 191, 191, };
			for index = 1, #PALLET do
				local color3 = PALLET[index];
				color3[1] = color3[1] / 255;
				color3[2] = color3[2] / 255;
				color3[3] = color3[3] / 255;
			end
			for index = 1, #PALLET do
				COLOR3[PALLET[index]] = 0;
			end
		end
		function GetColor3()
			local a = 99999;
			local c = nil;
			for color3, i in next, COLOR3 do
				if i < a then
					a = i;
					c = color3;
				end
			end
			if c == nil then
				c = next(COLOR3);
			end
			COLOR3[c] = COLOR3[c] + 1;
			return c;
		end
		function RelColor3(color3)
			if COLOR3[color3] ~= nil then
				COLOR3[color3] = COLOR3[color3] - 1;
			end
		end
		local floor = floor;
		local function GetColor3NextIndex(index)
			local num = #PALLET;
			if index == nil then
				index = (random() * 10000 * num) % (num - 1);
				index = index - index % 1.0 + 1;
				-- index = floor((random() * 10000 * num)) % (num - 1) + 1;
			else
				index = index + 1;
				if index > num then
					index = 1;
				end
			end
			local color3 = PALLET[index];
			COLOR3[color3] = COLOR3[color3] + 1;
			return color3, index;
		end
		local function ResetColor3()
			for color3, _ in next, COLOR3 do
				COLOR3[color3] = 0;
			end
		end
		__ns.GetColor3 = GetColor3;
		__ns.RelColor3 = RelColor3;
		__ns.GetColor3NextIndex = GetColor3NextIndex;
	-->
	-->		--	uuid:{ 1type, 2id, 3color3(run-time), 4{ [quest] = { [line] = TEXTURE, }, }, 5TEXTURE, 6MANUAL_CHANGED_COLOR, }
	-->		--	TEXTURE = 0 for invalid value	--	TEXTURE = -9999 for large pin	--	TEXTURE = -9998 for normal pin
	-->		--	line:	'start', 'end', >=1:line_quest_leader, 'event'
	-->		--	uuid 对应单位/对象类型，储存任务-行信息，对应META_COMMON表坐标设置一次即可
		local UUID = { event = {  }, item = {  }, object = {  }, quest = {  }, unit = {  }, };
		function CoreAddUUID(_T, _id, _quest, _line, _val)
			local uuid = UUID[_T][_id];
			if uuid == nil then
				uuid = { _T, _id, GetColor3(), {  }, };
				UUID[_T][_id] = uuid;
			elseif uuid[3] == nil then
				uuid[3] = GetColor3();
			end
			local ref = uuid[4][_quest];
			if ref == nil then
				ref = { [_line] = _val or 1, };
				uuid[4][_quest] = ref;
			else
				ref[_line] = _val or 1;
			end
			return uuid;
		end
		function CoreSubUUID(_T, _id, _quest, _line, total_del)
			local uuid = UUID[_T][_id];
			if uuid ~= nil then
				local ref = uuid[4][_quest];
				if ref ~= nil then
					local val = ref[_line];
					if val ~= nil then
						ref[_line] = nil;
						if next(ref) == nil then
							uuid[4][_quest] = nil;
						end
						if next(uuid[4]) == nil then
							RelColor3(uuid[3]);
							uuid[3] = nil;
							if not total_del then
								ref[_line] = 0;
								uuid[4][_quest] = ref;
							end
							return uuid, true;
						else
							if not total_del then
								ref[_line] = 0;
								uuid[4][_quest] = ref;
							end
							return uuid, false;
						end
					else
						if next(ref) == nil then
							uuid[4][_quest] = nil;
						end
						if next(uuid[4]) == nil then
							RelColor3(uuid[3]);
							uuid[3] = nil;
							return uuid, true;
						else
							return uuid, false;
						end
					end
				else
					if next(uuid[4]) == nil then
						RelColor3(uuid[3]);
						uuid[3] = nil;
						return uuid, true;
					else
						return uuid, false;
					end
				end
			end
			return uuid;
		end
		function CoreGetUUID(_T, _id)
			return UUID[_T][_id];
		end
		local function ResetUUID()
			wipe(UUID.event);
			wipe(UUID.item);
			wipe(UUID.object);
			wipe(UUID.quest);
			wipe(UUID.unit);
		end
		__ns.CoreAddUUID = CoreAddUUID;
		__ns.CoreSubUUID = CoreSubUUID;
		__ns.CoreGetUUID = CoreGetUUID;
	-->
	-->		send data to ui
		local COMMON_UUID_FLAG = {  };
		local LARGE_UUID_FLAG = {  };
		local VARIED_UUID_FLAG = {  };
		local function GetVariedNodeTexture(texture_list)
			local TEXTURE = 0;
			for quest, list in next, texture_list do
				for _, texture in next, list do
					if texture > TEXTURE then
						TEXTURE = texture;
					end
				end
			end
			return TEXTURE ~= 0 and TEXTURE or nil;
		end
		--	common_objective pin
		function AddCommonNodes(_T, _id, _quest, _line, coords_table)
			local uuid = CoreAddUUID(_T, _id, _quest, _line, -9998);
			if COMMON_UUID_FLAG[uuid] == nil then
				if coords_table ~= nil then
					__ns.MapAddCommonNodes(uuid, coords_table);
				end
				COMMON_UUID_FLAG[uuid] = coords_table;
			end
		end
		function DelCommonNodes(_T, _id, _quest, _line, total_del)
			local uuid, del = CoreSubUUID(_T, _id, _quest, _line, total_del);
			if del == false then
				del = true;
				for _, ref in next, uuid[4] do
					for line, val in next, ref do
						if val == -9998 then
							del = false;
							break;
						end
					end
				end
			end
			if del == true then
				__ns.MapDelCommonNodes(uuid);
				COMMON_UUID_FLAG[uuid] = nil;
			end
		end
		--	large_objective pin
		function AddLargeNodes(_T, _id, _quest, _line, coords_table)
			local uuid = CoreAddUUID(_T, _id, _quest, _line, -9999);
			if LARGE_UUID_FLAG[uuid] == nil then
				if coords_table ~= nil then
					__ns.MapAddLargeNodes(uuid, coords_table);
				end
				LARGE_UUID_FLAG[uuid] = coords_table;
			end
		end
		function DelLargeNodes(_T, _id, _quest, _line, total_del)
			local uuid, del = CoreSubUUID(_T, _id, _quest, _line, total_del);
			if del == false then
				del = true;
				for _, ref in next, uuid[4] do
					for line, val in next, ref do
						if val == -9999 then
							del = false;
							break;
						end
					end
				end
			end
			if del == true then
				__ns.MapDelLargeNodes(uuid);
				LARGE_UUID_FLAG[uuid] = nil;
			end
		end
		--	varied_objective pin
		function AddVariedNodes(_T, _id, _quest, _line, coords_table, varied_texture)
			local uuid = CoreAddUUID(_T, _id, _quest, _line, varied_texture);
			local TEXTURE = GetVariedNodeTexture(uuid[4]);
			if uuid[5] ~= TEXTURE then
				uuid[5] = TEXTURE;
				__ns.MapAddVariedNodes(uuid, coords_table, VARIED_UUID_FLAG[uuid]);
				VARIED_UUID_FLAG[uuid] = coords_table;
			end
		end
		function DelVariedNodes(_T, _id, _quest, _line)
			local uuid, del = CoreSubUUID(_T, _id, _quest, _line, true);
			if del == true then
				uuid[5] = nil;
				if VARIED_UUID_FLAG[uuid] ~= nil then
					__ns.MapDelVariedNodes(uuid);
					VARIED_UUID_FLAG[uuid] = nil;
				end
			elseif del == false then
				local TEXTURE = GetVariedNodeTexture(uuid[4]);
				if uuid[5] ~= TEXTURE then
					uuid[5] = TEXTURE;
					if VARIED_UUID_FLAG[uuid] ~= nil then
						__ns.MapAddVariedNodes(uuid, nil, true);
					end
				end
			end
		end
	-->
	-->		send quest data
		function AddUnit(quest, line, uid, show_coords, large_pin, showFriend)
			local info = __db_unit[uid];
			if info ~= nil then
				if showFriend ~= nil then
					local isFriend = nil;
					if info.fac == nil then
						if info.facId ~= nil then
							local _, _, standing_rank, _, _, val = GetFactionInfoByID(info.facId);
							if val > 0 then
								isFriend = true;
							else		--	if val <= -3000 then	--	冷淡不会招致主动攻击，敌对开始主动攻击
								isFriend = false;
							end
						else
							isFriend = false;
						end
					else
						isFriend = UnitHelpFac[info.fac];
					end
					if not showFriend ~= not isFriend then
						return;
					end
				end
				PreloadCoords(info);
				local coords = show_coords and info.coords or nil;
				if large_pin then
					AddLargeNodes('unit', uid, quest, line, coords);
				else
					AddCommonNodes('unit', uid, quest, line, coords);
				end
			end
		end
		function DelUnit(quest, line, uid, total_del, large_pin)
			if large_pin then
				DelLargeNodes('unit', uid, quest, line, total_del);
			else
				DelCommonNodes('unit', uid, quest, line, total_del);
			end
		end
		function AddObject(quest, line, oid, show_coords, large_pin)
			local info = __db_object[oid];
			if info ~= nil then
				-- if show_coords then
					PreloadCoords(info);
					local coords = show_coords and info.coords or nil;
					if large_pin then
						AddLargeNodes('object', oid, quest, line, coords);
					else
						AddCommonNodes('object', oid, quest, line, coords);
					end
				-- end
			end
			local name = __loc_object[oid];
			if name ~= nil then
				OBJ_LOOKUP[name] = oid;
			end
		end
		function DelObject(quest, line, oid, total_del, large_pin)
			if large_pin then
				DelLargeNodes('object', oid, quest, line, total_del);
			else
				DelCommonNodes('object', oid, quest, line, total_del);
			end
		end
		function AddRefloot(quest, line, rid, show_coords, large_pin)
			local info = __db_refloot[rid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, _ in next, info.U do
						AddUnit(quest, line, uid, show_coords, large_pin, false);
					end
				end
				if info.O ~= nil then
					for oid, _ in next, info.O do
						AddObject(quest, line, oid, show_coords, large_pin);
					end
				end
			end
		end
		function DelRefloot(quest, line, rid, total_del, large_pin)
			local info = __db_refloot[rid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, _ in next, info.U do
						DelUnit(quest, line, uid, total_del, large_pin);
					end
				end
				if info.O ~= nil then
					for oid, _ in next, info.O do
						DelObject(quest, line, oid, total_del, large_pin);
					end
				end
			end
		end
		function AddItem(quest, line, iid, show_coords, large_pin)
			if __db_blacklist_item[iid] ~= nil then
				return;
			end
			local info = __db_item[iid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, rate in next, info.U do
						if rate >= SET.min_rate then
							AddUnit(quest, line, uid, show_coords, large_pin, false);
						end
					end
				end
				if info.O ~= nil then
					for oid, rate in next, info.O do
						if rate >= SET.min_rate then
							AddObject(quest, line, oid, show_coords, large_pin);
						end
					end
				end
				if info.R ~= nil then
					for rid, rate in next, info.R do
						if rate >= SET.min_rate then
							AddRefloot(quest, line, rid, show_coords, large_pin);
						end
					end
				end
				if info.V ~= nil then
					for vid, _ in next, info.V do
						AddUnit(quest, line, vid, show_coords, large_pin, true);
					end
				end
				if info.I ~= nil then
					local line2 = line > 0 and -line or line;
					for iid2, _ in next, info.I do
						AddItem(quest, line2, iid2, show_coords, large_pin);
					end
				end
			end
		end
		function DelItem(quest, line, iid, total_del, large_pin)
			if __db_blacklist_item[iid] ~= nil then
				return;
			end
			local info = __db_item[iid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, rate in next, info.U do
						DelUnit(quest, line, uid, total_del, large_pin);
					end
				end
				if info.O ~= nil then
					for oid, rate in next, info.O do
						DelObject(quest, line, oid, total_del, large_pin);
					end
				end
				if info.R ~= nil then
					for rid, _ in next, info.R do
						DelRefloot(quest, line, rid, total_del, large_pin);
					end
				end
				if info.V ~= nil then
					for vid, _ in next, info.V do
						DelUnit(quest, line, vid, total_del, large_pin);
					end
				end
				if info.I ~= nil then
					local line2 = line > 0 and -line or line;
					for iid2, _ in next, info.I do
						DelItem(quest, line2, iid2, total_del, large_pin);
					end
				end
			end
		end
		function AddEvent(quest)
			local info = __db_quest[quest];
			local obj = info.obj;
			if obj ~= nil then
				local E = obj.E;
				if E ~= nil then
					local coords = E.coords;
					if coords == nil then
						coords = {  };
						for index = 1, #E do
							local event = __db_event[E[index]];
							if event ~= nil then
								local cs = event.coords;
								if cs ~= nil and cs[1] ~= nil then
									for j = 1, #cs do
										coords[#coords + 1] = cs[j];
									end
								end
							end
						end
						E.coords = coords;
						PreloadCoords(E);
					end
					if coords ~= nil and coords[1] ~= nil then
						AddLargeNodes('event', quest, quest, 'event', coords);
					end
				end
			end
		end
		function DelEvent(quest)
			local info = __db_quest[quest];
			local obj = info.obj;
			if obj ~= nil then
				local E = obj.E;
				if E ~= nil then
					local coords = E.coords;
					if coords ~= nil and coords[1] ~= nil then
						DelLargeNodes('event', quest, quest, 'event');
					end
				end
			end
		end
		--
		function AddQuester_VariedTexture(quest, info, which, TEXTURE)
			if info ~= nil then
				local O = info.O;
				if O ~= nil then
					for index = 1, #O do
						local oid = O[index];
						local info = __db_object[oid];
						if info ~= nil then
							PreloadCoords(info);
							local coords = info.coords;
							AddVariedNodes('object', oid, quest, which, coords, TEXTURE);
						end
						local name = __loc_object[oid];
						if name ~= nil then
							OBJ_LOOKUP[name] = oid;
						end
					end
				end
				local U = info.U;
				if U ~= nil then
					for index = 1, #U do
						local uid = U[index];
						local info = __db_unit[uid];
						if info ~= nil then
							PreloadCoords(info);
							local coords = info.coords;
							AddVariedNodes('unit', uid, quest, which, coords, TEXTURE);
						end
					end
				end
			end
		end
		function DelQuester_VariedTexture(quest, info, which)
			if info ~= nil then
				local O = info.O;
				if O ~= nil then
					for index = 1, #O do
						DelVariedNodes('object', O[index], quest, which);
					end
				end
				local U = info.U;
				if U ~= nil then
					for index = 1, #U do
						DelVariedNodes('unit', U[index], quest, which);
					end
				end
			end
		end
		function AddQuestStart(quest_id, info, TEXTURE)
			AddQuester_VariedTexture(quest_id, info.start, 'start', TEXTURE or GetQuestStartTexture(info));
		end
		function DelQuestStart(quest_id, info)
			DelQuester_VariedTexture(quest_id, info.start, 'start');
		end
		function AddQuestEnd(quest_id, info, TEXTURE)
			AddQuester_VariedTexture(quest_id, info["end"], 'end', TEXTURE);
		end
		function DelQuestEnd(quest_id, info)
			DelQuester_VariedTexture(quest_id, info["end"], 'end');
		end
	-->
	-->		process quest log
		function AddLine(quest_id, index, objective_type, text, finished)
			local info = __db_quest[quest_id];
			local obj = info.obj;
			if obj ~= nil then
				local cache = CACHE[quest_id];
				if objective_type == 'monster' then
					local _, _, name = strfind(text, __L_QUEST_MONSTERS_KILLED);
					if name == nil then
						_, _, name = strfind(text, __L_QUEST_DEFAULT_PATTERN);
					end
					if name == "" or name == " " then
						return false;
					end
					local U = obj.U;
					if U ~= nil then
						local uid = #U == 1 and U[1] or cache[name] or FindMinLevenshteinDistance(name, __loc_unit, U);
						if uid then
							local large_pin = __db_large_pin:Check(quest_id, 'unit', uid);
							AddUnit(quest_id, index, uid, not finished, large_pin, nil);
							return true, uid, large_pin;
						else
							_log_('Missing Obj', objective_type, name, text, quest_id);
							return false;
						end
					end
				elseif objective_type == 'item' then
					local _, _, name = strfind(text, __L_QUEST_ITEMS_NEEDED);
					if name == nil then
						_, _, name = strfind(text, __L_QUEST_DEFAULT_PATTERN);
					end
					if name == "" or name == " " then
						return false;
					end
					local I = obj.I;
					if I ~= nil then
						local iid = #I == 1 and I[1] or cache[name] or FindMinLevenshteinDistance(name, __loc_item, I);
						if iid then
							local large_pin = __db_large_pin:Check(quest_id, 'item', iid);
							AddItem(quest_id, index, iid, not finished, large_pin);
							return true, iid, large_pin;
						else
							_log_('Missing Obj', objective_type, name, text, quest_id);
							return false;
						end
					end
				elseif objective_type == 'object' then
					local _, _, name = strfind(text, __L_QUEST_OBJECTS_FOUND);
					if name == nil then
						_, _, name = strfind(text, __L_QUEST_DEFAULT_PATTERN);
					end
					if name == "" or name == " " then
						return false;
					end
					local O = obj.O;
					if O ~= nil then
						local oid = #O == 1 and O[1] or cache[name] or FindMinLevenshteinDistance(name, __loc_object, O);
						if oid then
							OBJ_LOOKUP[__loc_object[oid]] = oid;
							local large_pin = __db_large_pin:Check(quest_id, 'object', oid);
							AddObject(quest_id, index, oid, not finished, large_pin);
							return true, oid, large_pin;
						else
							_log_('Missing Obj', objective_type, name, text, quest_id);
							return false;
						end
					end
				elseif objective_type == 'event' or objective_type == 'log' then
				elseif objective_type == 'reputation' then
				elseif objective_type == 'player' or objective_type == 'progressbar' then
				else
					_log_('objective_type', quest_id, index, objective_type, text);
				end
			else
				_log_('obj', quest_id, index, objective_type, text);
			end
			return true;
		end
		function AddLineByID(quest_id, index, objective_type, _id, finished)
			if objective_type == 'monster' then
				local large_pin = __db_large_pin:Check(quest_id, 'unit', _id);
				AddUnit(quest_id, index, _id, not finished, large_pin, nil);
				return true, _id, large_pin;
			elseif objective_type == 'item' then
				local large_pin = __db_large_pin:Check(quest_id, 'item', _id);
				AddItem(quest_id, index, _id, not finished, large_pin);
				return true, _id, large_pin;
			elseif objective_type == 'object' then
				local large_pin = __db_large_pin:Check(quest_id, 'object', _id);
				AddObject(quest_id, index, _id, not finished, large_pin);
				return true, _id, large_pin;
			elseif objective_type == 'event' or objective_type == 'log' then
			elseif objective_type == 'reputation' then
			elseif objective_type == 'player' or objective_type == 'progressbar' then
			else
				_log_('comm_objective_type', quest_id, finished, objective_type);
			end
			return true;
		end
		function DelLine(quest_id, index, objective_type, objective_id, total_del, large_pin)
			local info = __db_quest[quest_id];
			local obj = info.obj;
			if obj then
				local cache = CACHE[quest_id];
				if objective_type == 'monster' then
					DelUnit(quest_id, index, objective_id, total_del, large_pin);
				elseif objective_type == 'item' then
					DelItem(quest_id, index, objective_id, total_del, large_pin);
				elseif objective_type == 'object' then
					DelObject(quest_id, index, objective_id, total_del, large_pin);
				elseif objective_type == 'event' or objective_type == 'log' then
				elseif objective_type == 'reputation' then
				elseif objective_type == 'player' or objective_type == 'progressbar' then
				else
					_log_('objective_type', quest_id, index, objective_type, objective_id);
				end
			else
				_log_('obj', quest_id, index, objective_type, objective_id)
			end
		end
		function LoadQuestCache(quest_id, completed)
			local info = __db_quest[quest_id];
			if completed == -1 then
			end
			local cache = CACHE[quest_id];
			if cache == nil then
				cache = {  };
				CACHE[quest_id] = cache;
			end
			local obj = info.obj;
			if obj ~= nil then		--	hash objectives' name to id
				local I = obj.I;
				if I ~= nil then
					for index = 1, #I do
						local iid = I[index];
						local loc = __loc_item[iid];
						if loc then
							cache[loc] = iid;
						end
					end
				end
				local O = obj.O;
				if O ~= nil then
					for index = 1, #O do
						local oid = O[index];
						local loc = __loc_object[oid];
						if loc then
							cache[loc] = oid;
						end
					end
				end
				local U = obj.U;
				if U ~= nil then
					for index = 1, #U do
						local uid = U[index];
						local loc = __loc_unit[uid];
						if loc then
							cache[loc] = uid;
						end
					end
				end
			end
		end
		function UpdateQuests()
			--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.core.|cffff0000UpdateQuests|r'); end
			local _, num = GetNumQuestLogEntries();
			local quest_changed = false;
			local need_re_draw = false;
			for quest_id, meta in next, META do
				meta.flag = -1;
			end
			if num > 0 then
				for index = 1, 40 do
					local title, level, group, header, collapsed, completed, frequency, quest_id = GetQuestLogTitle(index);
						-->	completed:	1 = completed, nil = not completed, -1 = failed		>>	0 = not completed
					if not header and quest_id then
						local info = __db_quest[quest_id];
						if info ~= nil then
							local num_lines = GetNumQuestLeaderBoards(index);
							if completed ~= -1 and num_lines == 0 then
								completed = 1;
							elseif completed == nil then
								completed = 0;
							end
							local meta = META[quest_id];
							if meta == nil then									--	建表，读取缓存，删除任务起始点
								meta = { title = title, };
								META[quest_id] = meta;
								LoadQuestCache(quest_id, completed);
								DelQuestStart(quest_id, info);
								quest_changed = true;
							end
							__ns.PushAddQuest(quest_id, completed, title, num_lines);
							meta.flag = 1;
							meta.num_lines = num_lines;
							local has_unfinished_event = false;
							-- local details = GetQuestObjectives(quest_id);
							-- local detail = details[line];
							-- local objective_type, finished, numRequired, numFulfilled, description = detail.type, detail.finished, detail.numRequired, detail.numFulfilled, detail.text;
							local obj = info.obj;
							if obj ~= nil then
								local num_monster_lines = 0;
								local monster_line = -1;
								local U2 = obj.U2;
								if completed == 1 or completed == -1 then			--	第一次检测到任务成功或失败时，隐藏已显示的任务目标
									for line = 1, num_lines do
										local description, objective_type, finished = GetQuestLogLeaderBoard(line, index);
										local meta_line = meta[line];
										local push_line = false;
										if meta_line == nil then
											push_line = true;
											meta_line = { false, objective_type, nil, description, finished, nil, };
											meta[line] = meta_line;
										else
											if meta_line[4] ~= description then
												push_line = true;
											end
											meta_line[2] = objective_type;
											meta_line[4] = description;
											meta_line[5] = finished;
											if meta.completed == 0 then
												if meta_line[1] then
													DelLine(quest_id, line, meta_line[2], meta_line[3], false, meta_line[6]);
													_log_('DelLine-TTT', nil, objective_type, objective_id);
												end
												meta_line[1] = false;
											end
										end
										local valid, objective_id, large_pin = nil, meta_line[3], nil;
										if objective_id == nil then
											valid, objective_id, large_pin = AddLine(quest_id, line, objective_type, description, true);
											_log_('AddLine-TTT', nil, objective_type, objective_id);
											if objective_id ~= nil then
												meta_line[3] = objective_id;
												meta_line[6] = large_pin;
											end
										end
										if objective_type == 'monster' and (objective_id == nil or U2 == nil or U2[objective_id] ~= true) then
											num_monster_lines = num_monster_lines + 1;
											monster_line = line;
										end
										if push_line and objective_id ~= nil then
											__ns.PushAddLine(quest_id, line, finished, objective_type, objective_id, description);
										end
									end
									if meta.event_shown == true then
										DelEvent(quest_id);
									end
								else												--	检查任务进度
									for line = 1, num_lines do
										local description, objective_type, finished = GetQuestLogLeaderBoard(line, index);
										local meta_line = meta[line];
										local push_line = false;
										if meta_line == nil then
											push_line = true;
											meta_line = { false, objective_type, nil, description, finished, nil, };
											meta[line] = meta_line;
										else
											if meta_line[4] ~= description then
												push_line = true;
											end
											meta_line[2] = objective_type;
											meta_line[4] = description;
											meta_line[5] = finished;
										end
										--	objective_type:		'item', 'object', 'monster', 'reputation', 'log', 'event', 'player', 'progressbar'
										local valid, objective_id, large_pin = nil, meta_line[3], nil;
										if finished then
											if meta_line[1] then
												DelLine(quest_id, line, objective_type, objective_id, false, meta_line[6]);
												_log_('DelLine-TFT', valid, objective_type, objective_id);
											end
											meta_line[1] = false;
											if objective_id == nil then
												valid, objective_id, large_pin = AddLine(quest_id, line, objective_type, description, true);
												_log_('AddLine-TFT', nil, objective_type, objective_id);
												if objective_id ~= nil then
													meta_line[3] = objective_id;
													meta_line[6] = large_pin;
												end
											end
										else
											if not meta_line[1] then
												valid, objective_id, large_pin = AddLine(quest_id, line, objective_type, description, false);
												_log_('AddLine-TFF', valid, objective_type, objective_id);
												if valid then
													meta_line[1] = true;
													if objective_id ~= nil then
														meta_line[3] = objective_id;
														meta_line[6] = large_pin;
														need_re_draw = true;
													end
												end
											end
											if objective_type == 'event' or objective_type == 'log' then
												has_unfinished_event = true;
											end
										end
										if objective_type == 'monster' and (objective_id == nil or U2 == nil or U2[objective_id] ~= true) then
											num_monster_lines = num_monster_lines + 1;
											monster_line = line;
										end
										if push_line and objective_id ~= nil then
											__ns.PushAddLine(quest_id, line, finished, objective_type, objective_id, description);
										end
									end
									if has_unfinished_event then
										if meta.event_shown ~= true then
											AddEvent(quest_id);
											meta.event_shown = true;
											__ns.PushAddLine(quest_id, 'event', finished, 'event', quest_id, 'event');
										end
									else
										if meta.event_shown == true then
											DelEvent(quest_id);
											meta.event_shown = false;
										end
									end
								end
								if num_monster_lines == 1 then
									local U = obj.U2 or obj.U;
									if U ~= nil and #U > 1 then
										local meta_line = meta[monster_line];
										if meta_line[1] and meta_line[3] ~= nil and meta_line[7] == nil then
											--	DelLine
											DelLine(quest_id, monster_line, meta_line[2], meta_line[3], false, meta_line[6]);
										end
										if completed == 1 or completed == -1 or meta_line[5] then
											if meta_line[7] == nil then
												meta_line[7] = -1;
												--	AddAllHidden
												for index = 1, #U do
													local uid = U[index];
													local large_pin = __db_large_pin:Check(quest_id, 'unit', uid);
													AddUnit(quest_id, monster_line, uid, false, large_pin, nil);
												end
											elseif meta_line[7] == 1 then
												meta_line[7] = -1;
												--	HalfDel
												--	= DelAllShown + AddAllHidden
												for index = 1, #U do
													local uid = U[index];
													local large_pin = __db_large_pin:Check(quest_id, 'unit', uid);
													DelUnit(quest_id, monster_line, uid, false, large_pin);
													-- AddUnit(quest_id, monster_line, uid, false, large_pin, nil);
												end
											end
										else
											if meta_line[7] ~= 1 then
												meta_line[7] = 1;
												--	AddAllShown
												for index = 1, #U do
													local uid = U[index];
													local large_pin = __db_large_pin:Check(quest_id, 'unit', uid);
													AddUnit(quest_id, monster_line, uid, true, large_pin, nil);
												end
											end
										end
									end
								end
							end
							if meta.completed ~= completed then
								meta.completed = completed;
								if completed == -1 then							--	失败时，添加起始点
									if show_starter then
										AddQuestStart(quest_id, info);
									end
									need_re_draw = true;
								elseif completed == 1 then						--	成功时，添加结束点，删除起始点
									DelQuestStart(quest_id, info);
									if show_ender then
										AddQuestEnd(quest_id, info, IMG_INDEX.IMG_E_COMPLETED);
									end
									need_re_draw = true;
								elseif completed == 0 then						--	未完成时，添加结束点，删除起始点
									DelQuestStart(quest_id, info);
									if show_ender then
										AddQuestEnd(quest_id, info, IMG_INDEX.IMG_E_UNCOMPLETED);
									end
									need_re_draw = true;
								end
							end
						else
							_log_('Missing Quest', quest_id, title);
						end
						num = num - 1;
						if num <= 0 then
							break;
						end
					end
				end
			end
			for quest_id, meta in next, META do
				if meta.flag == -1 then
					CACHE[quest_id] = nil;
					local info = __db_quest[quest_id];
					if meta.num_lines ~= nil then
						for line = 1, meta.num_lines do
							local meta_line = meta[line];
							if meta_line ~= nil then
								if meta_line[7] ~= nil then
									local obj = info.obj;
									if obj ~= nil then
										local U = obj.U;
										if U ~= nil and #U > 1 then
											for index = 1, #U do
												local uid = U[index];
												local large_pin = __db_large_pin:Check(quest_id, 'unit', uid);
												DelUnit(quest_id, line, uid, true, large_pin);
											end
										end
									end
								elseif meta_line[3] ~= nil then
									DelLine(quest_id, line, meta_line[2], meta_line[3], true, meta_line[6]);
									_log_('DelLine-F__', nil, meta_line[2], meta_line[3]);
								end
							end
						end
					end
					if info ~= nil then
						DelQuestEnd(quest_id, info);
						if not QUESTS_COMPLETED[quest_id] and show_starter then
							AddQuestStart(quest_id, info);
						end
					end
					if meta.event_shown == true then
						DelEvent(quest_id);
						meta.event_shown = false;
					end
					META[quest_id] = nil;
					quest_changed = true;
					need_re_draw = true;
					__ns.PushDelQuest(quest_id, meta.completed);
				end
			end
			if quest_changed then
				__eventHandler:run_on_next_tick(__ns.UpdateQuestGivers);
			end
			if need_re_draw then
				__eventHandler:run_on_next_tick(__ns.MapDrawNodes);
			end
			--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.core.|cffff0000UpdateQuests|r'); end
		end
	-->
	-->		avl quest giver
		local QUEST_WATCH_REP = {  };
		local QUEST_WATCH_SKILL = {  };
		function UpdateQuestGivers()
			--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart("module.core.UpdateQuestGivers"); end
			local lowest = __ns.__player_level + SET.quest_lvl_lowest_ofs;
			local highest = __ns.__player_level + SET.quest_lvl_highest_ofs;
			for _, quest_id in next, __db_avl_quest_list do
				local info = __db_quest[quest_id];
				if META[quest_id] == nil and QUESTS_COMPLETED[quest_id] == nil then
					if info.lvl == nil or info.min == nil then print(quest_id, info.lvl, info.min); end
					local acceptable = info.lvl >= lowest and info.min <= highest;
					if acceptable then
						local parent = info.parent;
						if parent ~= nil then
							if META[parent] ~= nil then
								acceptable = true;
							else
								acceptable = false;
							end
						else
							acceptable = true;
						end
						if acceptable then
							local _next = info.next;
							if _next ~= nil then
								if QUESTS_COMPLETED[_next] == 1 then
									acceptable = false;
								end
							end
							if acceptable then
								local preSingle = info.preSingle;
								if preSingle ~= nil then
									acceptable = false;
									for index2 = 1, #preSingle do
										local id = preSingle[index2];
										if QUESTS_COMPLETED[id] == 1 then
											acceptable = true;
											break;
										end
									end
								end
								if acceptable then
									local excl = info.excl;
									if excl ~= nil then
										for index2 = 1, #excl do
											local id = excl[index2];
											if META[id] ~= nil or QUESTS_COMPLETED[id] == 1 then
												acceptable = false;
												break;
											end
										end
									end
									if acceptable then
										local preGroup = info.preGroup;
										if preGroup ~= nil then
											for index2 = 1, #preGroup do
												local id = preGroup[index2];
												if QUESTS_COMPLETED[id] ~= 1 then
													acceptable = false;
													break;
												end
											end
										end
										if acceptable then
											local acceptable_rep = true;
											local rep = info.rep;
											if rep ~= nil and rep[1] ~= nil then
												for index2 = 1, #rep do
													local r = rep[index2];
													local _, _, standing_rank, _, _, val = GetFactionInfoByID(r[1]);
													if val < r[2] or val > r[3] then
														acceptable_rep = false;
														break;
													end
												end
												QUEST_WATCH_REP[quest_id] = { acceptable_rep, rep, };
											end
											local acceptable_skill = true;
											local skill = info.skill;
											if skill ~= nil then
												acceptable_skill = false;
												local _name = __loc_profession[skill[1]];
												for index2 = 1, GetNumSkillLines() do
													local name, _, _, rank = GetSkillLineInfo(index2);
													if name == _name then
														if rank >= skill[2] then
															acceptable_skill = true;
														end
													end
												end
												QUEST_WATCH_SKILL[quest_id] = { acceptable_skill, skill, };
											end
											acceptable = acceptable_rep and acceptable_skill;
										end
									end
								end
							end
						end
					end
					if acceptable and show_starter then
						AddQuestStart(quest_id, info);
					else
						DelQuestStart(quest_id, info);
					end
				elseif not show_starter then
					DelQuestStart(quest_id, info);
				end
			end
			__eventHandler:run_on_next_tick(__ns.MapDrawNodes);
			--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.core.UpdateQuestGivers'); end
		end
	-->
	-->		misc
		local CalcQuestColorCount = 0;
		function CalcQuestColor()
			local changed = 0;
			local prev = GetQuestDifficultyColor(1).font;
			for level = 2, 999 do
				local color1, color2 = GetQuestDifficultyColor(level);
				local font = color1.font;
				if prev ~= font then
					if prev == "QuestDifficulty_Trivial" then
						if font == "QuestDifficulty_Standard" then
							SET.quest_lvl_green = level;
							changed = changed + 1;
						else
						end
					elseif prev == "QuestDifficulty_Standard" then
						if font == "QuestDifficulty_Difficult" then
							SET.quest_lvl_yellow = level;
							changed = changed + 1;
						else
						end
					elseif prev == "QuestDifficulty_Difficult" then
						if font == "QuestDifficulty_VeryDifficult" then
							SET.quest_lvl_orange = level;
							changed = changed + 1;
						else
						end
					elseif prev == "QuestDifficulty_VeryDifficult" then
						if font == "QuestDifficulty_Impossible" then
							SET.quest_lvl_red = level;
							changed = changed + 1;
							break;
						else
						end
					end
					prev = font;
				end
			end
			CalcQuestColorCount = CalcQuestColorCount + 1;
			if changed >= 4 or CalcQuestColorCount > 20 then
				_log_('color:1', SET.quest_lvl_green, SET.quest_lvl_yellow, SET.quest_lvl_orange, SET.quest_lvl_red, 'count', CalcQuestColorCount);
				UpdateQuestGivers();
			else
				__eventHandler:run_on_next_tick(CalcQuestColor);
			end
		end
	-->
	-->		interface
		local function SetQuestStarterShown(shown)
			show_starter = SET.show_quest_starter;
			UpdateQuestGivers();
			if show_starter then
				for quest_id, meta in next, META do
					local info = __db_quest[quest_id];
					if info ~= nil then
						if meta.completed == -1 then
							AddQuestStart(quest_id, info);
						end
					end
				end
			end
			__eventHandler:run_on_next_tick(__ns.MapDrawNodes);
		end
		local function SetQuestEnderShown(shown)
			show_ender = SET.show_quest_ender;
			for quest_id, meta in next, META do
				local info = __db_quest[quest_id];
				if info ~= nil then
					if show_ender then
						if meta.completed == 1 then
							AddQuestEnd(quest_id, info, IMG_INDEX.IMG_E_COMPLETED);
						elseif meta.completed == 0 then
							AddQuestEnd(quest_id, info, IMG_INDEX.IMG_E_UNCOMPLETED);
						end
					else
						DelQuestEnd(quest_id, info);
					end
				end
			end
			__eventHandler:run_on_next_tick(__ns.MapDrawNodes);
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
	-->
	-->		extern method
		__ns.SetQuestStarterShown = SetQuestStarterShown;
		__ns.SetQuestEnderShown = SetQuestEnderShown;
		__ns.SetQuestAutoInverseModifier = SetQuestAutoInverseModifier;
		--
		__ns.UpdateQuests = UpdateQuests;
		__ns.UpdateQuestGivers = UpdateQuestGivers;
		__ns.AddObject = AddObject;
		__ns.DelObject = DelObject;
		__ns.AddUnit = AddUnit;
		__ns.DelUnit = DelUnit;
		__ns.AddRefloot = AddRefloot;
		__ns.DelRefloot = DelRefloot;
		__ns.AddItem = AddItem;
		__ns.DelItem = DelItem;
		__ns.AddEvent = AddEvent;
		__ns.DelEvent = DelEvent;
		function __ns.core_reset()
			wipe(META);
			wipe(CACHE);
			ResetColor3();
			ResetUUID();
			wipe(COMMON_UUID_FLAG);
			wipe(LARGE_UUID_FLAG);
			wipe(VARIED_UUID_FLAG);
			QUESTS_COMPLETED = GetQuestsCompleted();
		end
	-->
	-->		events and hooks
		local GetNumGossipActiveQuests = GetNumGossipActiveQuests;
		local GetGossipActiveQuests = GetGossipActiveQuests;
		local SelectGossipActiveQuest = SelectGossipActiveQuest;
		local GetNumGossipAvailableQuests = GetNumGossipAvailableQuests;
		local GetGossipAvailableQuests = GetGossipAvailableQuests;
		local SelectGossipAvailableQuest = SelectGossipAvailableQuest;
		local GetNumActiveQuests = GetNumActiveQuests;
		local GetActiveTitle = GetActiveTitle;
		local SelectActiveQuest = SelectActiveQuest;
		local GetNumAvailableQuests = GetNumAvailableQuests;
		local GetAvailableTitle = GetAvailableTitle;
		local SelectAvailableQuest = SelectAvailableQuest;
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
		--
		function __ns.PLAYER_LEVEL_CHANGED(oldLevel, newLevel)
		end
		function __ns.PLAYER_LEVEL_UP(level)
			_log_('PLAYER_LEVEL_UP', level);
			local cur_level = level;
			__ns.__player_level = cur_level;
			__eventHandler:run_on_next_tick(UpdateQuests);
			__eventHandler:run_on_next_tick(CalcQuestColor);
			CalcQuestColorCount = 0;
			_log_('color:0', SET.quest_lvl_green, SET.quest_lvl_yellow, SET.quest_lvl_orange, SET.quest_lvl_red);
			-- __eventHandler:run_on_next_tick(UpdateQuestGivers);
		end
		function __ns.QUEST_LOG_UPDATE()
			_log_('QUEST_LOG_UPDATE');
			__eventHandler:run_on_next_tick(UpdateQuests);
		end
		function __ns.UNIT_QUEST_LOG_CHANGED(unit, ...)
			_log_('UNIT_QUEST_LOG_CHANGED', unit, ...);
			__eventHandler:run_on_next_tick(UpdateQuests);
		end
		function __ns.QUEST_ACCEPTED(index, quest_id)
			_log_('QUEST_ACCEPTED', index, quest_id);
			__eventHandler:run_on_next_tick(UpdateQuests);
			__eventHandler:run_on_next_tick(UpdateQuestGivers);
		end
		function __ns.QUEST_TURNED_IN(quest_id, xp, money)
			_log_('QUEST_TURNED_IN', quest_id, xp, money);
			__eventHandler:run_on_next_tick(UpdateQuests);
			__eventHandler:run_on_next_tick(UpdateQuestGivers);
			local info = __db_quest[quest_id];
			if info ~= nil then
				DelQuestEnd(quest_id, info);
				local exflag = info.exflag;
				if exflag ~= nil and bit_band(exflag, 1) ~= 0 then
					AddQuestStart(quest_id, info, IMG_INDEX.IMG_S_REPEATABLE);
				else
					DelQuestStart(quest_id, info);
					QUESTS_COMPLETED[quest_id] = 1;
					local info = __db_quest[quest_id];
					if info ~= nil then
						local _excl = info.excl;
						if _excl ~= nil then
							for _, val in next, _excl do
								QUESTS_COMPLETED[val] = -1;
							end
						end
					end
					local _prev = __db_chain_prev_quest[quest_id];
					if _prev ~= nil then
						QUESTS_COMPLETED[_prev] = -2;
					end
				end
			end
		end
		function __ns.QUEST_REMOVED(quest_id)
			_log_('QUEST_REMOVED', quest_id);
			__eventHandler:run_on_next_tick(UpdateQuests);
			__eventHandler:run_on_next_tick(UpdateQuestGivers);
		end
		--	Auto Accept and Turnin
		function __ns.GOSSIP_SHOW()
			local modstate = not quest_auto_inverse_modifier();
			if not SET.auto_complete ~= modstate then
				for i = 1, GetNumGossipActiveQuests() do
					local title, level, isTrivial, isComplete, isLegendary, isIgnored = select(i * 6 - 5, GetGossipActiveQuests());
					if title and isComplete then
						return SelectGossipActiveQuest(i);
					end
				end
			end
			if not SET.auto_accept ~= modstate then
				for i = 1, GetNumGossipAvailableQuests() do
					local title, level, isTrivial, isDaily, isRepeatable, isLegendary, isIgnored = select(i * 7 - 6, GetGossipAvailableQuests());
					if title then
						return SelectGossipAvailableQuest(i);
					end
				end
			end
			-- if SET.auto_accept then
			-- 	for i = 1, GetNumAvailableQuests() do
			-- 		local titleText, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = GetGossipAvailableQuests(i);
			-- 		if title then
			-- 			return SelectAvailableQuest(i);
			-- 		end
			-- 	end
			-- end
		end
		function __ns.QUEST_GREETING()
			local modstate = not quest_auto_inverse_modifier();
			if not SET.auto_complete ~= modstate then
				for i = 1, GetNumActiveQuests() do
					local title, isComplete = GetActiveTitle(i);
					if title and isComplete then
						return SelectActiveQuest(i);
					end
				end
			end
			if not SET.auto_accept ~= modstate then
				for i = 1, GetNumAvailableQuests() do
					local title, isComplete = GetAvailableTitle(i);
					if title then
						return SelectAvailableQuest(i);
					end
				end
			end
		end
		function __ns.QUEST_DETAIL()
			local modstate = not quest_auto_inverse_modifier();
			if not SET.auto_accept ~= modstate then
				AcceptQuest();
				QuestFrame:Hide();
			end
		end
		function __ns.QUEST_PROGRESS()
			local modstate = not quest_auto_inverse_modifier();
			if not SET.auto_complete ~= modstate then
				if IsQuestCompletable() then
					CompleteQuest();
				end
			end
		end
		function __ns.QUEST_COMPLETE()
			local modstate = not quest_auto_inverse_modifier();
			if not SET.auto_complete ~= modstate then
				local _NumChoices = GetNumQuestChoices();
				if _NumChoices <= 1 then
					GetQuestReward(_NumChoices);
				end
			end
		end
		function __ns.QUEST_ACCEPT_CONFIRM()
			local modstate = not quest_auto_inverse_modifier();
			if not SET.auto_accept ~= modstate then
				ConfirmAcceptQuest() ;
				StaticPopup_Hide("QUEST_ACCEPT");
			end
		end
		function __ns.QUEST_AUTOCOMPLETE(id)
			local modstate = not quest_auto_inverse_modifier();
			if not SET.auto_complete ~= modstate then
				local index = GetQuestLogIndexByID(id);
				if GetQuestLogIsAutoComplete(index) then
					ShowQuestComplete(index);
				end
			end
		end
	-->
	function __ns.core_setup()
		SET = __ns.__setting;
		local temp = GetQuestsCompleted();
		for quest, _ in next, temp do
			QUESTS_COMPLETED[quest] = 1;
			local info = __db_quest[quest];
			if info ~= nil then
				local _excl = info.excl;
				if _excl ~= nil then
					for _, val in next, _excl do
						QUESTS_COMPLETED[val] = -1;
					end
				end
			end
			local _prev = __db_chain_prev_quest[quest];
			if _prev ~= nil then
				QUESTS_COMPLETED[_prev] = -2;
			end
		end
		-- __eventHandler:RegEvent("ADDON_LOADED");
		-- __eventHandler:RegEvent("PLAYER_ENTERING_WORLD");
		--__eventHandler:RegEvent("SKILL_LINES_CHANGED");

		__eventHandler:RegEvent("GOSSIP_SHOW");
		__eventHandler:RegEvent("QUEST_GREETING");
		__eventHandler:RegEvent("QUEST_DETAIL");
		__eventHandler:RegEvent("QUEST_PROGRESS");
		__eventHandler:RegEvent("QUEST_COMPLETE");
		__eventHandler:RegEvent("QUEST_ACCEPT_CONFIRM");
		__eventHandler:RegEvent("QUEST_AUTOCOMPLETE");
		-- __eventHandler:RegEvent("QUEST_FINISHED");
		-- __eventHandler:RegEvent("QUEST_REMOVED");
		--
		-- __eventHandler:RegEvent("QUEST_WATCH_UPDATE");
		--
		-- __eventHandler:RegEvent("QUEST_AUTOCOMPLETE");	--	quest_id
		-- __eventHandler:RegEvent("QUEST_LOG_CRITERIA_UPDATE");	--	inexistant
				--	quest_id, specificTreeID, description, numFulfilled, numRequired	
		--
		__eventHandler:RegEvent("PLAYER_LEVEL_UP");
		--
		__eventHandler:RegEvent("QUEST_LOG_UPDATE");
		-- __eventHandler:RegEvent("UNIT_QUEST_LOG_CHANGED");
		__eventHandler:RegEvent("QUEST_ACCEPTED");			--	questIndex, questId
		__eventHandler:RegEvent("QUEST_TURNED_IN");			--	quest_id, xpReward, moneyReward
		__eventHandler:RegEvent("QUEST_REMOVED");			--	quest_id, wasReplayQuest
		--
		__eventHandler:RegEvent("NAME_PLATE_UNIT_ADDED");
		__eventHandler:RegEvent("NAME_PLATE_UNIT_REMOVED");
		--
		__eventHandler:run_on_next_tick(UpdateQuests);
		__eventHandler:run_on_next_tick(CalcQuestColor);
		-- __eventHandler:run_on_next_tick(UpdateQuestGivers);
		--
		show_starter = SET.show_quest_starter;
		show_ender = SET.show_quest_ender;
		SetQuestAutoInverseModifier(SET.quest_auto_inverse_modifier);
	end
-->

-->		note
	-->
		-->		QUEST_WATCH_UPDATE		
		-->		QUEST_LOG_UPDATE			
		-->		PLAYER_LEVEL_UP			
		-->		PLAYER_ENTERING_WORLD	
		-->		SKILL_LINES_CHANGED		
		-->
		-->		GOSSIP_SHOW				GossipFrame-GossipFrameGreetingPanel	NPC对话
		-->		QUEST_GREETING			QuestFrame-QuestFrameGreetingPanel		多个任务选择
		-->	接任务
		-->		QUEST_DETAIL			QuestFrame-QuestFrameDetailPanel		任务描述
		-->	交任务
		-->		QUEST_PROGRESS			QuestFrame-QuestFrameProgressPanel		任务进度(完成和未完成)
		-->		QUEST_COMPLETE			QuestFrame-QuestFrameRewardPanel		完成任务
		-->
		-->		QUEST_FINISHED													QuestFrame改变
		-->		QUEST_REMOVED													完成任务或放弃任务
		-->
		-->		NAME_PLATE_UNIT_ADDED	
		-->		NAME_PLATE_UNIT_REMOVED	
-->

--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.core'); end
