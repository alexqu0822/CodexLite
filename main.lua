--[[--
	by ALA @ 163UI/网易有爱, http://wowui.w.163.com/163ui/
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;

-->		upvalue
	local select = select;
	local next = next;
	local wipe = table.wipe;
	local strfind, gsub = string.find, string.gsub;
	local floor, random = math.floor, math.random;
	local bit_band = bit.band;
	local IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown = IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown;
	local GetQuestDifficultyColor = GetQuestDifficultyColor;
	local GetNumQuestLogEntries = GetNumQuestLogEntries;
	local GetQuestLogTitle = GetQuestLogTitle;
	local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards;
	local GetQuestLogQuestText = GetQuestLogQuestText;
	local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard;
	local GetQuestObjectives = C_QuestLog.GetQuestObjectives;	--	(quest_id)	returns { [line(1, 2, 3, ...)] = { [type], [finished], [numRequired], [numFulfilled], [text] } }
	local GetQuestsCompleted = GetQuestsCompleted;				--	({  } or nil)	return { [quest_id] = completed(true/nil), }
	--	IsQuestComplete(qid)
	--	IsQuestFlaggedCompleted(qid)
	local GetFactionInfoByID = GetFactionInfoByID;
	local GetNumSkillLines = GetNumSkillLines;
	local GetSkillLineInfo = GetSkillLineInfo;
	local _G = _G;

-->
	local DataAgent = DT.DB;
	local l10n = CT.l10n;

	local EventAgent = VT.EventAgent;

-->
MT.BuildEnv("main");
-->		MAIN
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
			},
		}
	]]
	local OBJ_LOOKUP = { ["*"] = {  }, };
	local QUESTS_COMPLETED = {  };
	local QUESTS_CONFILCTED = {  };
	VT.MAIN_META = META;
	VT.MAIN_OBJ_LOOKUP = OBJ_LOOKUP;
	VT.MAIN_QUESTS_COMPLETED = QUESTS_COMPLETED;
	-->		function predef
		local GetColor3, RelColor3, GetColor3NextIndex, ResetColor3;
		local CoreAddUUID, CoreSubUUID, CoreGetUUID, CoreResetUUID;
		local GetVariedNodeTexture, AddCommonNodes, DelCommonNodes, AddLargeNodes, DelLargeNodes, AddVariedNodes, DelVariedNodes;
		local AddObjectLookup;
		local AddSpawn, DelSpawn, AddUnit, DelUnit, AddObject, DelObject, AddRefloot, DelRefloot, AddItem, DelItem, AddEvent, DelEvent;
		local AddQuester_VariedTexture, DelQuester_VariedTexture, AddQuestStart, DelQuestStart, AddQuestEnd, DelQuestEnd;
		local AddLine, DelLine;
		local AddExtra, DelExtra;
		local UpdateQuests;
		local AddConfilct, DelConfilct;
		local UpdateQuestGivers;
		local CalcQuestColor;
		--	setting
		local SetQuestStarterShown, SetQuestEnderShown;
		local SetLimitItemStarter, SetLimitItemStarterNumCoords;
		--	setup
		local SetupCompleted;
	-->
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
		function GetColor3NextIndex(index)
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
		function ResetColor3()
			for color3, _ in next, COLOR3 do
				COLOR3[color3] = 0;
			end
		end
		MT.GetColor3 = GetColor3;
		MT.RelColor3 = RelColor3;
		MT.GetColor3NextIndex = GetColor3NextIndex;
	-->
	-->		--	uuid:{ 1type, 2id, 3color3(run-time), 4{ [quest] = { [line] = TEXTURE, }, }, 5TEXTURE, 6MANUAL_CHANGED_COLOR, }
	-->		--	TEXTURE = 0 for invalid value	--	TEXTURE = -9999 for large pin	--	TEXTURE = -9998 for normal pin
	-->		--	line:	'start', 'end', >=1:line_quest_leader, 'extra'
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
		function CoreResetUUID()
			wipe(UUID.event);
			wipe(UUID.item);
			wipe(UUID.object);
			wipe(UUID.quest);
			wipe(UUID.unit);
		end
		MT.CoreAddUUID = CoreAddUUID;
		MT.CoreSubUUID = CoreSubUUID;
		MT.CoreGetUUID = CoreGetUUID;

		if VT.__is_dev then
			VT.CORE_UUID = UUID;
		end
	-->
	-->		send data to ui
		local COMMON_UUID_FLAG = {  };
		local LARGE_UUID_FLAG = {  };
		local VARIED_UUID_FLAG = {  };
		function GetVariedNodeTexture(texture_list)
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
					MT.MapAddCommonNodes(uuid, coords_table);
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
				MT.MapDelCommonNodes(uuid);
				COMMON_UUID_FLAG[uuid] = nil;
			elseif del == false then
				MT.MapUpdCommonNodes(uuid);
			end
		end
		--	large_objective pin
		function AddLargeNodes(_T, _id, _quest, _line, coords_table)
			local uuid = CoreAddUUID(_T, _id, _quest, _line, -9999);
			if LARGE_UUID_FLAG[uuid] == nil then
				if coords_table ~= nil then
					MT.MapAddLargeNodes(uuid, coords_table);
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
				MT.MapDelLargeNodes(uuid);
				LARGE_UUID_FLAG[uuid] = nil;
			elseif del == false then
				MT.MapUpdLargeNodes(uuid);
			end
		end
		--	varied_objective pin
		function AddVariedNodes(_T, _id, _quest, _line, coords_table, varied_texture)
			local uuid = CoreAddUUID(_T, _id, _quest, _line, varied_texture);
			local TEXTURE = GetVariedNodeTexture(uuid[4]);
			if uuid[5] ~= TEXTURE then
				uuid[5] = TEXTURE;
				MT.MapAddVariedNodes(uuid, coords_table, VARIED_UUID_FLAG[uuid]);
				VARIED_UUID_FLAG[uuid] = coords_table;
			end
		end
		function DelVariedNodes(_T, _id, _quest, _line)
			local uuid, del = CoreSubUUID(_T, _id, _quest, _line, true);
			if del == true then
				uuid[5] = nil;
				if VARIED_UUID_FLAG[uuid] ~= nil then
					MT.MapDelVariedNodes(uuid);
					VARIED_UUID_FLAG[uuid] = nil;
				end
			elseif del == false then
				local TEXTURE = GetVariedNodeTexture(uuid[4]);
				if uuid[5] ~= TEXTURE then
					uuid[5] = TEXTURE;
					if VARIED_UUID_FLAG[uuid] ~= nil then
						MT.MapAddVariedNodes(uuid, nil, true);
					end
				end
			end
		end
	-->
	function AddObjectLookup(oid)
		local name = l10n.object[oid];
		if name ~= nil then
			OBJ_LOOKUP["*"][name] = oid;
			local info = DataAgent.object[oid];
			if info ~= nil and info.coords ~= nil then
				local coords = info.coords;
				for i = 1, #coords do
					local map = coords[i][3];
					OBJ_LOOKUP[map] = OBJ_LOOKUP[map] or {  };
					OBJ_LOOKUP[map][name] = oid;
				end
			end
		end
	end
	-->		send quest data
		function AddSpawn(quest, line, spawn, show_coords, showFriend)
			if spawn.U ~= nil then
				for unit, _ in next, spawn.U do
					local large_pin = DataAgent.large_pin:Check(quest, 'unit', unit);
					AddUnit(quest, line, unit, show_coords, large_pin, showFriend);
				end
			end
			if spawn.O ~= nil then
				for object, _ in next, spawn.O do
					local large_pin = DataAgent.large_pin:Check(quest, 'object', object);
					AddObject(quest, line, object, show_coords, large_pin);
				end
			end
			if spawn.I ~= nil then
				for item, num in next, spawn.I do
					local large_pin = DataAgent.large_pin:Check(quest, 'item', item);
					AddItem(quest, line, item, show_coords, large_pin);
				end
			end
		end
		function DelSpawn(quest, line, spawn, total_del)
			if spawn.U ~= nil then
				for unit, _ in next, spawn.U do
					local large_pin = DataAgent.large_pin:Check(quest, 'unit', unit);
					DelUnit(quest, line, unit, total_del, large_pin);
				end
			end
			if spawn.O ~= nil then
				for object, _ in next, spawn.O do
					local large_pin = DataAgent.large_pin:Check(quest, 'object', object);
					DelObject(quest, line, object, total_del, large_pin);
				end
			end
			if spawn.I ~= nil then
				for item, num in next, spawn.I do
					local large_pin = DataAgent.large_pin:Check(quest, 'item', item);
					DelItem(quest, line, item, total_del, large_pin);
				end
			end
		end
		function AddUnit(quest, line, uid, show_coords, large_pin, showFriend)
			local info = DataAgent.unit[uid];
			if info ~= nil then
				local draw = true;
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
						isFriend = VT.IsUnitFacFriend[info.fac];
					end
					if not showFriend ~= not isFriend then
						draw = false;
					end
				end
				if info.waypoints ~= nil then
					large_pin = false;
				end
				if draw then
					MT.PreloadCoords(info);
					local coords = show_coords and (info.waypoints or info.coords) or nil;
					if large_pin and info.waypoints == nil then
						AddLargeNodes('unit', uid, quest, line, coords);
					else
						AddCommonNodes('unit', uid, quest, line, coords);
					end
				end
				local spawn = info.spawn;
				if spawn ~= nil then
					AddSpawn(quest, line, spawn, show_coords, showFriend);
				end
			end
		end
		function DelUnit(quest, line, uid, total_del, large_pin)
			local info = DataAgent.unit[uid];
			if info ~= nil then
				if info.waypoints ~= nil then
					large_pin = false;
				end
				if large_pin then
					DelLargeNodes('unit', uid, quest, line, total_del);
				else
					DelCommonNodes('unit', uid, quest, line, total_del);
				end
				local spawn = info.spawn;
				if spawn ~= nil then
					DelSpawn(quest, line, spawn, total_del);
				end
			end
		end
		function AddObject(quest, line, oid, show_coords, large_pin)
			local info = DataAgent.object[oid];
			if info ~= nil then
				-- if show_coords then
					MT.PreloadCoords(info);
					local coords = show_coords and info.coords or nil;
					if large_pin then
						AddLargeNodes('object', oid, quest, line, coords);
					else
						AddCommonNodes('object', oid, quest, line, coords);
					end
				-- end
				local spawn = info.spawn;
				if spawn ~= nil then
					AddSpawn(quest, line, spawn, show_coords);
				end
			end
			AddObjectLookup(oid);
		end
		function DelObject(quest, line, oid, total_del, large_pin)
			local info = DataAgent.object[oid];
			if info ~= nil then
				if large_pin then
					DelLargeNodes('object', oid, quest, line, total_del);
				else
					DelCommonNodes('object', oid, quest, line, total_del);
				end
				local spawn = info.spawn;
				if spawn ~= nil then
					DelSpawn(quest, line, spawn, total_del);
				end
			end
		end
		function AddRefloot(quest, line, rid, show_coords, large_pin)
			local info = DataAgent.refloot[rid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, _ in next, info.U do
						AddUnit(quest, line, uid, show_coords, large_pin, nil);
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
			local info = DataAgent.refloot[rid];
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
			if DataAgent.blacklist_item[iid] ~= nil then
				return;
			end
			local info = DataAgent.item[iid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, rate in next, info.U do
						if rate >= VT.SETTING.min_rate then
							AddUnit(quest, line, uid, show_coords, large_pin, nil);
						end
					end
				end
				if info.O ~= nil then
					for oid, rate in next, info.O do
						if rate >= VT.SETTING.min_rate then
							AddObject(quest, line, oid, show_coords, large_pin);
						end
					end
				end
				if info.R ~= nil then
					for rid, rate in next, info.R do
						if rate >= VT.SETTING.min_rate then
							AddRefloot(quest, line, rid, show_coords, large_pin);
						end
					end
				end
				if info.V ~= nil then
					for vid, _ in next, info.V do
						AddUnit(quest, line, vid, show_coords, large_pin);
					end
				end
				if info.I ~= nil then
					for iid2, _ in next, info.I do
						local large_pin = DataAgent.large_pin:Check(quest, 'item', iid2);
						AddItem(quest, line, iid2, show_coords, large_pin);
					end
				end
			end
		end
		function DelItem(quest, line, iid, total_del, large_pin)
			if DataAgent.blacklist_item[iid] ~= nil then
				return;
			end
			local info = DataAgent.item[iid];
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
					for iid2, _ in next, info.I do
						local large_pin = DataAgent.large_pin:Check(quest, 'item', iid2);
						DelItem(quest, line, iid2, total_del, large_pin);
					end
				end
			end
		end
		function AddEvent(quest, line, eid, show_coords, large_pin)
			local info = DataAgent.event[eid];
			if info ~= nil then
				MT.PreloadCoords(info);
				local coords = show_coords and info.coords or nil;
				if large_pin then
					AddLargeNodes('event', eid, quest, line, coords);
				else
					AddCommonNodes('event', eid, quest, line, coords);
				end
				local spawn = info.spawn;
				if spawn ~= nil then
					AddSpawn(quest, line, spawn, show_coords);
				end
			end
		end
		function DelEvent(quest, line, eid, total_del, large_pin)
			local info = DataAgent.event[eid];
			if info ~= nil then
				if large_pin then
					DelLargeNodes('event', eid, quest, line, total_del);
				else
					DelCommonNodes('event', eid, quest, line, total_del);
				end
				local spawn = info.spawn;
				if spawn ~= nil then
					DelSpawn(quest, line, spawn, total_del);
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
						local info = DataAgent.object[oid];
						if info ~= nil then
							MT.PreloadCoords(info);
							local coords = info.coords;
							AddVariedNodes('object', oid, quest, which, coords, TEXTURE);
						end
						AddObjectLookup(oid);
					end
				end
				local U = info.U;
				if U ~= nil then
					for index = 1, #U do
						local uid = U[index];
						local info = DataAgent.unit[uid];
						if info ~= nil then
							MT.PreloadCoords(info);
							local coords = info.coords;
							AddVariedNodes('unit', uid, quest, which, coords, TEXTURE);
						end
					end
				end
				local I = info.I;
				if I ~= nil then
					for index = 1, #I do
						local info = DataAgent.item[I[index]];
						if info ~= nil then
							local O = info.O;
							if O ~= nil then
								for oid, rate in next, O do
									if rate > 10 or not VT.SETTING.limit_item_starter_drop then
										local info = DataAgent.object[oid];
										if info ~= nil then
											MT.PreloadCoords(info);
											local wcoords = info.wcoords;
											if wcoords == nil or #wcoords <= 5 or not VT.SETTING.limit_item_starter_drop_num_coords then
												AddVariedNodes('object', oid, quest, which, info.coords, TEXTURE);
											else
												DelVariedNodes('object', oid, quest, which);
											end
										end
										AddObjectLookup(oid);
									else
										DelVariedNodes('object', oid, quest, which);
									end
								end
							end
							local U = info.U;
							if U ~= nil then
								for uid, rate in next, U do
									if rate > 10 or not VT.SETTING.limit_item_starter_drop then
										local info = DataAgent.unit[uid];
										if info ~= nil then
											MT.PreloadCoords(info);
											local wcoords = info.wcoords;
											if wcoords == nil or #wcoords <= 5 or not VT.SETTING.limit_item_starter_drop_num_coords then
												AddVariedNodes('unit', uid, quest, which, info.coords, TEXTURE);
											else
												DelVariedNodes('unit', uid, quest, which);
											end
										end
									else
										DelVariedNodes('unit', uid, quest, which);
									end
								end
							end
							local V = info.V;
							if V ~= nil then
								for uid, val in next, V do
									local info = DataAgent.unit[uid];
									if info ~= nil then
										MT.PreloadCoords(info);
										local wcoords = info.wcoords;
										if wcoords == nil or #wcoords <= 5 or not VT.SETTING.limit_item_starter_drop_num_coords then
											AddVariedNodes('unit', uid, quest, which, info.coords, TEXTURE);
										else
											DelVariedNodes('unit', uid, quest, which);
										end
									end
								end
							end
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
				local I = info.I;
				if I ~= nil then
					for index = 1, #I do
						local info = DataAgent.item[I[index]];
						if info ~= nil then
							local O = info.O;
							if O ~= nil then
								for oid, rate in next, O do
									DelVariedNodes('object', oid, quest, which);
								end
							end
							local U = info.U;
							if U ~= nil then
								for uid, rate in next, U do
									DelVariedNodes('unit', uid, quest, which);
								end
							end
							local V = info.V;
							if V ~= nil then
								for uid, val in next, V do
									DelVariedNodes('unit', uid, quest, which);
								end
							end
						end
					end
				end
			end
		end
		function AddQuestStart(quest, info, TEXTURE)
			AddQuester_VariedTexture(quest, info.start, 'start', TEXTURE or MT.GetQuestStartTexture(info));
		end
		function DelQuestStart(quest, info)
			DelQuester_VariedTexture(quest, info.start, 'start');
		end
		function AddQuestEnd(quest, info, TEXTURE)
			AddQuester_VariedTexture(quest, info["end"], 'end', TEXTURE);
		end
		function DelQuestEnd(quest, info)
			DelQuester_VariedTexture(quest, info["end"], 'end');
		end
	-->
	-->		process quest log
		function AddLine(quest_id, index, objective_type, _id, finished)
			if objective_type == 'monster' then
				local large_pin = DataAgent.large_pin:Check(quest_id, 'unit', _id);
				AddUnit(quest_id, index, _id, not finished, large_pin, nil);
				return large_pin;
			elseif objective_type == 'item' then
				local large_pin = DataAgent.large_pin:Check(quest_id, 'item', _id);
				AddItem(quest_id, index, _id, not finished, large_pin);
				return large_pin;
			elseif objective_type == 'object' then
				AddObjectLookup(_id);
				local large_pin = DataAgent.large_pin:Check(quest_id, 'object', _id);
				AddObject(quest_id, index, _id, not finished, large_pin);
				return large_pin;
			elseif objective_type == 'event' or objective_type == 'log' then
				AddEvent(quest_id, index, _id, not finished, true);
				return true;
			elseif objective_type == 'reputation' then
			elseif objective_type == 'player' or objective_type == 'progressbar' then
			else
				MT.Debug('comm_objective_type', quest_id, finished, objective_type);
			end
			return nil;
		end
		function DelLine(quest_id, index, objective_type, objective_id, total_del, large_pin)
			local info = DataAgent.quest[quest_id];
			local obj = info.obj;
			if obj then
				if objective_type == 'monster' then
					DelUnit(quest_id, index, objective_id, total_del, large_pin);
				elseif objective_type == 'item' then
					DelItem(quest_id, index, objective_id, total_del, large_pin);
				elseif objective_type == 'object' then
					DelObject(quest_id, index, objective_id, total_del, large_pin);
				elseif objective_type == 'event' or objective_type == 'log' then
					local events = obj.E;
					if events ~= nil then
						for i = 1, #events do
							local event = events[i];
							DelEvent(quest_id, index, event, total_del, true);
						end
					end
				elseif objective_type == 'reputation' then
				elseif objective_type == 'player' or objective_type == 'progressbar' then
				else
					MT.Debug('objective_type', quest_id, index, objective_type, objective_id);
				end
			else
				MT.Debug('obj', quest_id, index, objective_type, objective_id)
			end
		end
		function AddExtra(quest_id, extra, text, completed)
			if extra.U ~= nil then
				for uid, check in next, extra.U do
					local large_pin = DataAgent.large_pin:Check(quest_id, 'unit', uid);
					if check == completed or check == 'always' then
						AddUnit(quest_id, 'extra', uid, true, large_pin);
					else
						DelUnit(quest_id, 'extra', uid, false, large_pin);
					end
				end
			end
			if extra.I ~= nil then
				for iid, check in next, extra.I do
					local large_pin = DataAgent.large_pin:Check(quest_id, 'unit', iid);
					if check == completed or check == 'always' then
						AddItem(quest_id, 'extra', iid, true, large_pin);
					else
						DelItem(quest_id, 'extra', iid, false, large_pin);
					end
				end
			end
			if extra.O ~= nil then
				for oid, check in next, extra.O do
					AddObjectLookup(oid);
					local large_pin = DataAgent.large_pin:Check(quest_id, 'object', oid);
					if check == completed or check == 'always' then
						AddObject(quest_id, 'extra', oid, true, large_pin);
					else
						DelObject(quest_id, 'extra', oid, false, large_pin);
					end
				end
			end
			if extra.E ~= nil then
				for eid, check in next, extra.E do
					if check == completed or check == 'always' then
						AddEvent(quest_id, 'extra', eid, true, true);
					else
						DelEvent(quest_id, 'extra', eid, false, true);
					end
				end
			end
		end
		function DelExtra(quest_id, extra)
			if extra.U ~= nil then
				for uid, check in next, extra.U do
					local large_pin = DataAgent.large_pin:Check(quest_id, 'unit', uid);
					DelUnit(quest_id, 'extra', uid, true, large_pin);
				end
			end
			if extra.I ~= nil then
				for iid, check in next, extra.I do
					local large_pin = DataAgent.large_pin:Check(quest_id, 'unit', iid);
					DelItem(quest_id, 'extra', iid, true, large_pin);
				end
			end
			if extra.O ~= nil then
				for oid, check in next, extra.O do
					local large_pin = DataAgent.large_pin:Check(quest_id, 'object', oid);
					DelObject(quest_id, 'extra', oid, true, large_pin);
				end
			end
			if extra.E ~= nil then
				for eid, check in next, extra.E do
					DelEvent(quest_id, 'extra', eid, true, true);
				end
			end
		end
		function AddConfilct(quest_id)
			--	QUESTS_CONFILCTED
			local info = DataAgent.quest[quest_id];
			if info ~= nil then
				local _excl = info.excl;
				if _excl ~= nil then
					for index = 1, #_excl do
						local ex = _excl[index];
						if QUESTS_CONFILCTED[ex] == nil then
							QUESTS_CONFILCTED[ex] = true;
							AddConfilct(ex);
						end
					end
				end
				local _next = info.next;
				if _next ~= nil then
					if QUESTS_CONFILCTED[_next] == nil then
						QUESTS_CONFILCTED[_next] = true;
						AddConfilct(_next);
					end
				end
				-- local _pres = info.preSingle;
				-- if _pres ~= nil then
				-- 	for index = 1, #_pres do
				-- 		local ps = _pres[index];
				-- 		if QUESTS_CONFILCTED[ps] == nil then
				-- 			QUESTS_CONFILCTED[ps] = true;
				-- 			AddConfilct(ps);
				-- 		end
				-- 	end
				-- end
				-- local _preg = info.preGroup;
				-- if _preg ~= nil then
				-- 	for index = 1, #_preg do
				-- 		local pg = _preg[index];
				-- 		if QUESTS_CONFILCTED[pg] == nil then
				-- 			QUESTS_CONFILCTED[pg] = true;
				-- 			AddConfilct(pg);
				-- 		end
				-- 	end
				-- end
			end
		end
		function DelConfilct(quest_id)
		end
		function UpdateQuests()
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
						local info = DataAgent.quest[quest_id];
						if info ~= nil then
							local num_lines = GetNumQuestLeaderBoards(index);
							if completed ~= -1 and num_lines == 0 then
								completed = 1;
							elseif completed ~= 1 and completed ~= -1 and completed ~= 0 then
								completed = 0;
							end
							local meta = META[quest_id];
							if meta == nil then									--	建表，读取缓存，删除任务起始点
								meta = { title = title, sdesc = select(2, GetQuestLogQuestText(index)), };
								META[quest_id] = meta;
								DelQuestStart(quest_id, info);
								quest_changed = true;
								MT.PushAddQuest(quest_id, completed, title, num_lines);
							end
							--
							-- local details = GetQuestObjectives(quest_id);
							-- local detail = details[line];
							-- local objective_type, finished, numRequired, numFulfilled, description = detail.type, detail.finished, detail.numRequired, detail.numFulfilled, detail.text;
							--
							local obj = info.obj;
							if obj ~= nil then
								local i_u, i_o, i_i, i_e = 1, 1, 1, 1;
								if completed == 1 or completed == -1 then			--	第一次检测到任务成功或失败时，隐藏已显示的任务目标
									for line = 1, num_lines do
										local description, objective_type, finished = GetQuestLogLeaderBoard(line, index);
										local objective_id = nil;
										if objective_type == 'monster' then
											if obj.U ~= nil then
												objective_id = obj.U[i_u];
												i_u = i_u + 1;
											end
										elseif objective_type == 'item' then
											if obj.I ~= nil then
												objective_id = obj.I[i_i];
												i_i = i_i + 1;
											end
										elseif objective_type == 'object' then
											if obj.O ~= nil then
												objective_id = obj.O[i_o];
												i_o = i_o + 1;
											end
										elseif objective_type == 'event' or objective_type == 'log' then
											if obj.E ~= nil then
												objective_id = obj.E[i_e];
												i_e = i_e + 1;
											end
										elseif objective_type == 'reputation' then
										elseif objective_type == 'player' or objective_type == 'progressbar' then
										else
										end
										if objective_id ~= nil then
											local meta_line = meta[line];
											local push_line = false;
											if meta_line == nil then
												push_line = true;
												meta_line = { false, objective_type, objective_id, description, finished, nil, };
												meta[line] = meta_line;
												local large_pin = AddLine(quest_id, line, objective_type, objective_id, true);
												MT.Debug('AddLine-TTT', nil, objective_type, objective_id, large_pin);
												meta_line[6] = large_pin;
											else
												if meta_line[4] ~= description or meta_line[5] ~= finished then
													push_line = true;
												end
												meta_line[4] = description;
												meta_line[5] = finished;
												if meta.completed == 0 then		--	从【未完成】状态变成【完成】或【失败】
													if meta_line[1] then
														DelLine(quest_id, line, meta_line[2], meta_line[3], false, meta_line[6]);
														MT.Debug('DelLine-TTT', nil, objective_type, meta_line[3]);
													end
													meta_line[1] = false;
												end
											end
											if push_line and objective_id ~= nil then
												MT.PushAddLine(quest_id, line, finished, objective_type, objective_id, description);
											end
										else
										end
									end
								else												--	检查任务进度
									for line = 1, num_lines do
										local description, objective_type, finished = GetQuestLogLeaderBoard(line, index);
										local objective_id = nil;
										if objective_type == 'monster' then
											if obj.U ~= nil then
												objective_id = obj.U[i_u];
												i_u = i_u + 1;
											end
										elseif objective_type == 'item' then
											if obj.I ~= nil then
												objective_id = obj.I[i_i];
												i_i = i_i + 1;
											end
										elseif objective_type == 'object' then
											if obj.O ~= nil then
												objective_id = obj.O[i_o];
												i_o = i_o + 1;
											end
										elseif objective_type == 'event' or objective_type == 'log' then
											if obj.E ~= nil then
												objective_id = obj.E[i_e];
												i_e = i_e + 1;
											end
										elseif objective_type == 'reputation' then
										elseif objective_type == 'player' or objective_type == 'progressbar' then
										else
										end
										if objective_id ~= nil then
											local meta_line = meta[line];
											local push_line = false;
											if meta_line == nil then
												push_line = true;
												meta_line = { false, objective_type, objective_id, description, finished, nil, };
												meta[line] = meta_line;
												if finished then
													local large_pin = AddLine(quest_id, line, objective_type, objective_id, true);
													MT.Debug('AddLine-TFT', nil, objective_type, objective_id, large_pin, large_pin);
													meta_line[6] = large_pin;
												else
													local large_pin =  AddLine(quest_id, line, objective_type, objective_id, false);
													MT.Debug('AddLine-TFF', nil, objective_type, objective_id, large_pin, large_pin);
													meta_line[1] = true;
													meta_line[6] = large_pin;
													need_re_draw = true;
												end
											else
												if meta_line[4] ~= description or meta_line[5] ~= finished then
													push_line = true;
												end
												meta_line[4] = description;
												meta_line[5] = finished;
												if finished then
													if meta_line[1] then
														DelLine(quest_id, line, objective_type, objective_id, false, meta_line[6]);
														MT.Debug('DelLine-TFT', nil, objective_type, objective_id);
													end
													meta_line[1] = false;
												else
													if not meta_line[1] then
														local large_pin =  AddLine(quest_id, line, objective_type, objective_id, false);
														MT.Debug('AddLine-TFF', nil, objective_type, objective_id, large_pin);
														meta_line[1] = true;
														meta_line[6] = large_pin;
														need_re_draw = true;
													end
												end
											end
											--	objective_type:		'item', 'object', 'monster', 'reputation', 'log', 'event', 'player', 'progressbar'
											if push_line and objective_id ~= nil then
												MT.PushAddLine(quest_id, line, finished, objective_type, objective_id, description);
											end
										else
										end
									end
								end
							end
							local extra = info.extra;
							if extra ~= nil then
								if meta.completed ~= completed then
									AddExtra(quest_id, extra, title, completed);
								else
									AddExtra(quest_id, extra, title, completed);
								end
							end
							--
							if meta.completed ~= completed then
								meta.completed = completed;
								if completed == -1 then							--	失败时，添加起始点
									if VT.SETTING.show_quest_starter then
										AddQuestStart(quest_id, info);
									end
									need_re_draw = true;
								elseif completed == 1 then						--	成功时，添加结束点，删除起始点
									DelQuestStart(quest_id, info);
									if VT.SETTING.show_quest_ender then
										AddQuestEnd(quest_id, info, CT.IMG_INDEX.IMG_E_COMPLETED);
									end
									need_re_draw = true;
								elseif completed == 0 then						--	未完成时，添加结束点，删除起始点
									DelQuestStart(quest_id, info);
									if VT.SETTING.show_quest_ender then
										AddQuestEnd(quest_id, info, CT.IMG_INDEX.IMG_E_UNCOMPLETED);
									end
									need_re_draw = true;
								end
							end
							--
							meta.flag = 1;
							meta.num_lines = num_lines;
							--
							local start = info.start;
							if start ~= nil and start.O ~= nil then
								local O = start.O;
								for i = 1, #O do
									AddObjectLookup(O[i]);
								end
							end
						else
							MT.Debug('Missing Quest', quest_id, title);
						end
						num = num - 1;
						if num <= 0 then
							break;
						end
					end
				end
			end
			-- QUESTS_CONFILCTED = {  };
			for quest_id, meta in next, META do
				if meta.flag == -1 then
					local info = DataAgent.quest[quest_id];
					if meta.num_lines ~= nil then
						for line = 1, meta.num_lines do
							local meta_line = meta[line];
							if meta_line ~= nil then
								DelLine(quest_id, line, meta_line[2], meta_line[3], true, meta_line[6]);
								MT.Debug('DelLine-F__', nil, meta_line[2], meta_line[3]);
							end
						end
					end
					if info ~= nil then
						DelQuestEnd(quest_id, info);
						if not QUESTS_COMPLETED[quest_id] and VT.SETTING.show_quest_starter then
							AddQuestStart(quest_id, info);
						end
						if info.extra ~= nil then
							DelExtra(quest_id, info.extra);
						end
					end
					META[quest_id] = nil;
					quest_changed = true;
					need_re_draw = true;
					MT.PushDelQuest(quest_id, meta.completed);
				-- else
					-- AddConfilct(quest_id);
				end
			end
			if quest_changed then
				QUESTS_CONFILCTED = {  };
				for quest_id, meta in next, META do
					AddConfilct(quest_id);
				end
				MT._TimerStart(UpdateQuestGivers, 0.2, 1);
			end
			if need_re_draw then
				MT._TimerStart(MT.MapDrawNodes, 0.2, 1);
			end
			MT.PushFlushBuffer();
		end
	-->
	-->		avl quest giver
		local QUEST_WATCH_REP = {  };
		local QUEST_WATCH_SKILL = {  };
		function UpdateQuestGivers()
			local lowest = VT.PlayerLevel + VT.SETTING.quest_lvl_lowest_ofs;
			local highest = VT.PlayerLevel + VT.SETTING.quest_lvl_highest_ofs;
			for _, quest_id in next, DataAgent.avl_quest_list do
				local info = DataAgent.quest[quest_id];
				if META[quest_id] == nil and QUESTS_COMPLETED[quest_id] == nil and QUESTS_CONFILCTED[quest_id] == nil then
					local acceptable = info.lvl < 0 or (info.lvl >= lowest and info.min <= highest);
					if acceptable then		--	parent
						local parent = info.parent;
						if parent ~= nil then
							if META[parent] == nil then
								acceptable = false;
							end
						end
					if acceptable then		--	next
						local _next = info.next;
						if _next ~= nil then
							if META[_next] ~= nil or QUESTS_COMPLETED[_next] then
								acceptable = false;
							end
						end
					if acceptable then		--	preSingle
						local preSingle = info.preSingle;
						if preSingle ~= nil then
							acceptable = false;
							for index2 = 1, #preSingle do
								local id = preSingle[index2];
								if QUESTS_COMPLETED[id] then
									acceptable = true;
									break;
								end
							end
						end
					if acceptable then		--	preWeak
						local preWeak = info.preWeak;
						if preWeak ~= nil then
							if META[id] == nil and QUESTS_COMPLETED[id] == nil then
								acceptable = false;
							end
						end
					if acceptable then		--	excl
						local excl = info.excl;
						if excl ~= nil then
							for index2 = 1, #excl do
								local id = excl[index2];
								if META[id] ~= nil or QUESTS_COMPLETED[id] ~= nil then
									acceptable = false;
									break;
								end
							end
						end
					if acceptable then		--	preGroup
						local preGroup = info.preGroup;
						if preGroup ~= nil then
							for index2 = 1, #preGroup do
								local id = preGroup[index2];
								if QUESTS_COMPLETED[id] == nil then
									acceptable = false;
									break;
								end
							end
						end
					if acceptable then		--	rep & skill
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
							local _name = l10n.profession[skill[1]];
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
					end
					if acceptable and VT.SETTING.show_quest_starter then
						AddQuestStart(quest_id, info);
					else
						DelQuestStart(quest_id, info);
					end
				else
					DelQuestStart(quest_id, info);
				end
			end
			MT._TimerStart(MT.MapDrawNodes, 0.2, 1);
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
							VT.QuestLvGreen = level;
							changed = changed + 1;
						else
						end
					elseif prev == "QuestDifficulty_Standard" then
						if font == "QuestDifficulty_Difficult" then
							VT.QuestLvYellow = level;
							changed = changed + 1;
						else
						end
					elseif prev == "QuestDifficulty_Difficult" then
						if font == "QuestDifficulty_VeryDifficult" then
							VT.QuestLvOrange = level;
							changed = changed + 1;
						else
						end
					elseif prev == "QuestDifficulty_VeryDifficult" then
						if font == "QuestDifficulty_Impossible" then
							VT.QuestLvRed = level;
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
				MT.Debug('color:1', VT.QuestLvGreen, VT.QuestLvYellow, VT.QuestLvOrange, VT.QuestLvRed, 'count', CalcQuestColorCount);
				UpdateQuestGivers();
			else
				MT._TimerStart(CalcQuestColor, 0.2, 1);
			end
		end
	-->
	-->		setting
		function SetQuestStarterShown(shown)
			UpdateQuestGivers();
			if VT.SETTING.show_quest_starter then
				for quest_id, meta in next, META do
					local info = DataAgent.quest[quest_id];
					if info ~= nil then
						if meta.completed == -1 then
							AddQuestStart(quest_id, info);
						end
					end
				end
			end
			MT._TimerStart(MT.MapDrawNodes, 0.2, 1);
		end
		function SetQuestEnderShown(shown)
			for quest_id, meta in next, META do
				local info = DataAgent.quest[quest_id];
				if info ~= nil then
					if VT.SETTING.show_quest_ender then
						if meta.completed == 1 then
							AddQuestEnd(quest_id, info, CT.IMG_INDEX.IMG_E_COMPLETED);
						elseif meta.completed == 0 then
							AddQuestEnd(quest_id, info, CT.IMG_INDEX.IMG_E_UNCOMPLETED);
						end
					else
						DelQuestEnd(quest_id, info);
					end
				end
			end
			MT._TimerStart(MT.MapDrawNodes, 0.2, 1);
		end
		function SetLimitItemStarter(limit)
			UpdateQuestGivers();
		end
		function SetLimitItemStarterNumCoords(limit)
			UpdateQuestGivers();
		end
	-->
	-->		extern method
		MT.SetQuestStarterShown = SetQuestStarterShown;
		MT.SetQuestEnderShown = SetQuestEnderShown;
		MT.SetLimitItemStarter = SetLimitItemStarter;
		MT.SetLimitItemStarterNumCoords = SetLimitItemStarterNumCoords;
		--
		MT.UpdateQuests = UpdateQuests;
		MT.UpdateQuestGivers = UpdateQuestGivers;
		MT.AddObject = AddObject;
		MT.DelObject = DelObject;
		MT.AddUnit = AddUnit;
		MT.DelUnit = DelUnit;
		MT.AddRefloot = AddRefloot;
		MT.DelRefloot = DelRefloot;
		MT.AddItem = AddItem;
		MT.DelItem = DelItem;
		MT.AddEvent = AddEvent;
		MT.DelEvent = DelEvent;
		function MT.ResetCore()
			wipe(META);
			ResetColor3();
			CoreResetUUID();
			wipe(COMMON_UUID_FLAG);
			wipe(LARGE_UUID_FLAG);
			wipe(VARIED_UUID_FLAG);
			SetupCompleted();
		end
	-->
	-->		events and hooks
		--
		function EventAgent.PLAYER_LEVEL_CHANGED(oldLevel, newLevel)
		end
		function EventAgent.PLAYER_LEVEL_UP(level)
			MT.Debug('PLAYER_LEVEL_UP', level);
			local cur_level = level;
			VT.PlayerLevel = cur_level;
			MT._TimerStart(UpdateQuests, 0.2, 1);
			MT._TimerStart(CalcQuestColor, 0.2, 1);
			CalcQuestColorCount = 0;
			MT.Debug('color:0', VT.QuestLvGreen, VT.QuestLvYellow, VT.QuestLvOrange, VT.QuestLvRed);
			-- MT._TimerStart(UpdateQuestGivers, 0.2, 1);
		end
		function EventAgent.QUEST_LOG_UPDATE()
			MT.Debug('QUEST_LOG_UPDATE');
			MT._TimerStart(UpdateQuests, 0.2, 1);
		end
		function EventAgent.UNIT_QUEST_LOG_CHANGED(unit, ...)
			MT.Debug('UNIT_QUEST_LOG_CHANGED', unit, ...);
			MT._TimerStart(UpdateQuests, 0.2, 1);
		end
		function EventAgent.QUEST_ACCEPTED(index, quest_id)
			MT.Debug('QUEST_ACCEPTED', index, quest_id);
			MT._TimerStart(UpdateQuests, 0.2, 1);
			MT._TimerStart(UpdateQuestGivers, 0.2, 1);
		end
		local function QUEST_TURNED_IN()
			GetQuestsCompleted(QUESTS_COMPLETED);
			MT._TimerStart(UpdateQuests, 0.2, 1);
			MT._TimerStart(UpdateQuestGivers, 0.2, 1);
		end
		function EventAgent.QUEST_TURNED_IN(quest_id, xp, money)
			MT.Debug('QUEST_TURNED_IN', quest_id, xp, money);
			QUESTS_COMPLETED[quest_id] = true;
			QUEST_TURNED_IN();
			-- MT.After(0.5, QUEST_TURNED_IN);
			MT.After(1.0, QUEST_TURNED_IN);
			-- MT.After(1.5, QUEST_TURNED_IN);
			-- MT.After(2.0, QUEST_TURNED_IN);
			-- MT.After(2.5, QUEST_TURNED_IN);
			-- MT.After(3.0, QUEST_TURNED_IN);
			local info = DataAgent.quest[quest_id];
			if info ~= nil then
				DelQuestEnd(quest_id, info);
				local flag = info.flag;
				local exflag = info.exflag;
				if exflag ~= nil and bit_band(exflag, 1) ~= 0 and (flag == nil or bit_band(flag, 4096) == 0) then
					AddQuestStart(quest_id, info, CT.IMG_INDEX.IMG_S_REPEATABLE);
				else
					DelQuestStart(quest_id, info);
					-- QUESTS_COMPLETED[quest_id] = 1;
					-- local info = DataAgent.quest[quest_id];
					-- if info ~= nil then
					-- 	local _excl = info.excl;
					-- 	if _excl ~= nil then
					-- 		for _, val in next, _excl do
					-- 			QUESTS_COMPLETED[val] = -1;
					-- 		end
					-- 	end
					-- end
					local _prev = DataAgent.chain_prev_quest[quest_id];
					if _prev ~= nil and QUESTS_COMPLETED[_prev] ~= 1 then
						QUESTS_COMPLETED[_prev] = 2;
					end
				end
			end
		end
		function EventAgent.QUEST_REMOVED(quest_id)
			MT.Debug('QUEST_REMOVED', quest_id);
			MT._TimerStart(UpdateQuests, 0.2, 1);
			MT._TimerStart(UpdateQuestGivers, 0.2, 1);
		end
	-->
	function SetupCompleted()
		GetQuestsCompleted(QUESTS_COMPLETED);
		-- wipe(QUESTS_COMPLETED);
		-- local temp = GetQuestsCompleted();
		-- for quest, _ in next, temp do
		-- 	QUESTS_COMPLETED[quest] = 1;
		-- 	local info = DataAgent.quest[quest];
		-- 	if info ~= nil then
		-- 		local _excl = info.excl;
		-- 		if _excl ~= nil then
		-- 			for _, val in next, _excl do
		-- 				QUESTS_COMPLETED[val] = -1;
		-- 			end
		-- 		end
		-- 	end
		-- 	local _prev = DataAgent.chain_prev_quest[quest];
		-- 	if _prev ~= nil and QUESTS_COMPLETED[_prev] ~= 1 then
		-- 		QUESTS_COMPLETED[_prev] = 2;
		-- 	end
		-- end
	end
	MT.RegisterOnLogin("main", function(LoggedIn)
		SetupCompleted();
		-- EventAgent:RegEvent("ADDON_LOADED");
		-- EventAgent:RegEvent("PLAYER_ENTERING_WORLD");
		-- EventAgent:RegEvent("SKILL_LINES_CHANGED");

		-- EventAgent:RegEvent("QUEST_FINISHED");
		-- EventAgent:RegEvent("QUEST_REMOVED");
		--
		-- EventAgent:RegEvent("QUEST_WATCH_UPDATE");
		--
		-- EventAgent:RegEvent("QUEST_AUTOCOMPLETE");	--	quest_id
		-- EventAgent:RegEvent("QUEST_LOG_CRITERIA_UPDATE");	--	inexistant
				--	quest_id, specificTreeID, description, numFulfilled, numRequired	
		--
		EventAgent:RegEvent("PLAYER_LEVEL_UP");
		--
		EventAgent:RegEvent("QUEST_LOG_UPDATE");
		-- EventAgent:RegEvent("UNIT_QUEST_LOG_CHANGED");
		EventAgent:RegEvent("QUEST_ACCEPTED");			--	questIndex, questId
		EventAgent:RegEvent("QUEST_TURNED_IN");			--	quest_id, xpReward, moneyReward
		EventAgent:RegEvent("QUEST_REMOVED");			--	quest_id, wasReplayQuest
		--
		EventAgent:RegEvent("NAME_PLATE_UNIT_ADDED");
		EventAgent:RegEvent("NAME_PLATE_UNIT_REMOVED");
		--
		MT._TimerStart(UpdateQuests, 0.2, 1);
		MT._TimerStart(CalcQuestColor, 0.2, 1);
		-- MT._TimerStart(UpdateQuestGivers, 0.2, 1);
	end);

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

