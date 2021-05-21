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
--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.comm'); end

-->		variables
	local strfind = strfind;
	local next = next;
	local bit_band = bit.band;
	local Ambiguate = Ambiguate;
	local RegisterAddonMessagePrefix = RegisterAddonMessagePrefix or C_ChatInfo.RegisterAddonMessagePrefix;
	local IsAddonMessagePrefixRegistered = IsAddonMessagePrefixRegistered or C_ChatInfo.IsAddonMessagePrefixRegistered;
	local GetRegisteredAddonMessagePrefixes = GetRegisteredAddonMessagePrefixes or C_ChatInfo.GetRegisteredAddonMessagePrefixes;
	local SendAddonMessage = SendAddonMessage or C_ChatInfo.SendAddonMessage;
	local SendAddonMessageLogged = SendAddonMessageLogged or C_ChatInfo.SendAddonMessageLogged;

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

	local __loc_object = __ns.L.object;

	local _F_SafeCall = __ns.core._F_SafeCall;
	local __eventHandler = __ns.core.__eventHandler;
	local __const = __ns.core.__const;

	local __core_meta = __ns.__core_meta;

	local UnitHelpFac = __ns.core.UnitHelpFac;
	local _log_ = __ns._log_;

	local SET = nil;
	local PLAYER_NAME = UnitName('player');

-->		MAIN
	local ADDON_PREFIX = "CDXLT_";
	local ADDON_MSG_CONTROL_CODE_LEN = 6;
	local ADDON_MSG_CTRLCODE_PUSH = "_push_";
	local ADDON_MSG_CTRLCODE_PULL = "_pull_";
	local META = {  };	--	[quest_id] = { [flag:whether_nodes_added], [completed], [num_lines], [line(1, 2, 3, ...)] = { shown, objective_type, objective_id, description, finished, is_large_pin, progress, required, }, }
	local OBJ_LOOKUP = {  };
	__ns.__comm_meta = META;
	__ns.__comm_obj_lookup = OBJ_LOOKUP;
	local GROUP_MEMBERS = {  };
	__ns.__group_members = GROUP_MEMBERS;
	-->		function predef
		local CommAddUUID, CommSubUUID, CommGetUUID;
		local AddCommonNodes, DelCommonNodes, AddLargeNodes, DelLargeNodes, AddVariedNodes, DelVariedNodes;
		local AddUnit, DelUnit, AddObject, DelObject, AddRefloot, DelRefloot, AddItem, DelItem, AddEvent, DelEvent;
		local AddQuester_VariedTexture, DelQuester_VariedTexture, AddQuestStart, DelQuestStart, AddQuestEnd, DelQuestEnd;
		local AddLine, DelLine;
	-->
	-->		--	uuid:{ 1type, 2id, 3color3(run-time), 4{ [quest] = { [line] = TEXTURE, }, }, }
	-->		--	line:	'start', 'end', >=1:line_quest_leader, 'event'
	-->		--	uuid 对应单位/对象类型，储存任务-行信息，对应META_COMMON表坐标设置一次即可
		local _UUID = {  };
		function CommAddUUID(name, _T, _id, _quest, _line, _val)
			local UUID = _UUID[name];
			if UUID == nil then
				UUID = { event = {  }, item = {  }, object = {  }, quest = {  }, unit = {  }, };
				_UUID[name] = UUID;
			end
			local uuid = UUID[_T][_id];
			if uuid == nil then
				uuid = { _T, _id, nil, {  }, };
				UUID[_T][_id] = uuid;
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
		function CommSubUUID(name, _T, _id, _quest, _line, total_del)
			local UUID = _UUID[name];
			if UUID ~= nil then
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
								return uuid, true;
							else
								return uuid, false;
							end
						end
					else
						if next(uuid[4]) == nil then
							return uuid, true;
						else
							return uuid, false;
						end
					end
				end
				return uuid;
			end
		end
		function CommGetUUID(name, _T, _id)
			local UUID = _UUID[name];
			if UUID ~= nil then
				return UUID[_T][_id];
			end
		end
		local function ResetUUID()
			wipe(_UUID);
		end
		__ns.CommAddUUID = CommAddUUID;
		__ns.CommSubUUID = CommSubUUID;
		__ns.CommGetUUID = CommGetUUID;
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
		function AddCommonNodes(name, _T, _id, _quest, _line, coords_table)
			local uuid = CommAddUUID(name, _T, _id, _quest, _line, -9998);
			if COMMON_UUID_FLAG[uuid] == nil then
				if coords_table ~= nil then
					__ns.MapAddCommonNodes(uuid, coords_table);
				end
				COMMON_UUID_FLAG[uuid] = true;
			end
		end
		function DelCommonNodes(name, _T, _id, _quest, _line, total_del)
			local uuid, del = CommSubUUID(name, _T, _id, _quest, _line, total_del);
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
		function AddLargeNodes(name, _T, _id, _quest, _line, coords_table)
			local uuid = CommAddUUID(name, _T, _id, _quest, _line, -9999);
			if LARGE_UUID_FLAG[uuid] == nil then
				if coords_table ~= nil then
					__ns.MapAddLargeNodes(uuid, coords_table);
				end
				LARGE_UUID_FLAG[uuid] = true;
			end
		end
		function DelLargeNodes(name, _T, _id, _quest, _line, total_del)
			local uuid, del = CommSubUUID(name, _T, _id, _quest, _line, total_del);
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
		function AddVariedNodes(name, _T, _id, _quest, _line, coords_table, varied_texture)
			local uuid = CommAddUUID(name, _T, _id, _quest, _line, varied_texture);
			local TEXTURE = GetVariedNodeTexture(uuid[4]);
			if uuid[5] ~= TEXTURE then
				uuid[5] = TEXTURE;
				__ns.MapAddVariedNodes(uuid, coords_table, VARIED_UUID_FLAG[uuid]);
				VARIED_UUID_FLAG = true;
			end
		end
		function DelVariedNodes(name, _T, _id, _quest, _line)
			local uuid, del = CommSubUUID(name, _T, _id, _quest, _line, true);
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
		function AddUnit(name, quest, line, uid, show_coords, large_pin, showFriend)
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
				if large_pin then
					AddLargeNodes(name, 'unit', uid, quest, line, nil);
				else
					AddCommonNodes(name, 'unit', uid, quest, line, nil);
				end
			end
		end
		function DelUnit(name, quest, line, uid, total_del, large_pin)
			if large_pin then
				DelLargeNodes(name, 'unit', uid, quest, line, total_del);
			else
				DelCommonNodes(name, 'unit', uid, quest, line, total_del);
			end
		end
		function AddObject(name, quest, line, oid, show_coords, large_pin)
			local info = __db_object[oid];
			if info ~= nil then
				if large_pin then
					AddLargeNodes(name, 'object', oid, quest, line, nil);
				else
					AddCommonNodes(name, 'object', oid, quest, line, nil);
				end
			end
			local name = __loc_object[oid];
			if name ~= nil then
				OBJ_LOOKUP[name] = oid;
			end
		end
		function DelObject(name, quest, line, oid, total_del, large_pin)
			if large_pin then
				DelLargeNodes(name, 'object', oid, quest, line, total_del);
			else
				DelCommonNodes(name, 'object', oid, quest, line, total_del);
			end
		end
		function AddRefloot(name, quest, line, rid, show_coords, large_pin)
			local info = __db_refloot[rid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, _ in next, info.U do
						AddUnit(name, quest, line, uid, show_coords, large_pin, false);
					end
				end
				if info.O ~= nil then
					for oid, _ in next, info.O do
						AddObject(name, quest, line, oid, show_coords, large_pin);
					end
				end
			end
		end
		function DelRefloot(name, quest, line, rid, total_del, large_pin)
			local info = __db_refloot[rid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, _ in next, info.U do
						DelUnit(name, quest, line, uid, total_del, large_pin);
					end
				end
				if info.O ~= nil then
					for oid, _ in next, info.O do
						DelObject(name, quest, line, oid, total_del, large_pin);
					end
				end
			end
		end
		function AddItem(name, quest, line, iid, show_coords, large_pin)
			if __db_blacklist_item[iid] ~= nil then
				return;
			end
			local info = __db_item[iid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, rate in next, info.U do
						if rate >= SET.min_rate then
							AddUnit(name, quest, line, uid, show_coords, large_pin, false);
						end
					end
				end
				if info.O ~= nil then
					for oid, rate in next, info.O do
						if rate >= SET.min_rate then
							AddObject(name, quest, line, oid, show_coords, large_pin);
						end
					end
				end
				if info.R ~= nil then
					for rid, rate in next, info.R do
						if rate >= SET.min_rate then
							AddRefloot(name, quest, line, rid, show_coords, large_pin);
						end
					end
				end
				if info.V ~= nil then
					for vid, _ in next, info.V do
						AddUnit(name, quest, line, vid, show_coords, large_pin, true);
					end
				end
				if info.I ~= nil then
					local line2 = line > 0 and -line or line;
					for iid2, _ in next, info.I do
						AddItem(name, quest, line2, iid2, show_coords, large_pin);
					end
				end
			end
		end
		function DelItem(name, quest, line, iid, total_del, large_pin)
			if __db_blacklist_item[iid] ~= nil then
				return;
			end
			local info = __db_item[iid];
			if info ~= nil then
				if info.U ~= nil then
					for uid, rate in next, info.U do
						DelUnit(name, quest, line, uid, total_del, large_pin);
					end
				end
				if info.O ~= nil then
					for oid, rate in next, info.O do
						DelObject(name, quest, line, oid, total_del, large_pin);
					end
				end
				if info.R ~= nil then
					for rid, _ in next, info.R do
						DelRefloot(name, quest, line, rid, total_del, large_pin);
					end
				end
				if info.V ~= nil then
					for vid, _ in next, info.V do
						DelUnit(name, quest, line, vid, total_del, large_pin);
					end
				end
				if info.I ~= nil then
					local line2 = line > 0 and -line or line;
					for iid2, _ in next, info.I do
						DelItem(name, quest, line, iid, total_del, large_pin);
					end
				end
			end
		end
		function AddEvent(name, quest)
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
								if cs ~= nil and #cs > 0 then
									for j = 1, #cs do
										coords[#coords + 1] = cs[j];
									end
								end
							end
						end
						E.coords = coords;
						PreloadCoords(E);
					end
					if coords ~= nil and #coords > 0 then
						AddLargeNodes(name, 'event', quest, quest, 'event', nil);
					end
				end
			end
		end
		function DelEvent(name, quest)
			local info = __db_quest[quest];
			local obj = info.obj;
			if obj ~= nil then
				local E = obj.E;
				if E ~= nil then
					local coords = E.coords;
					if coords ~= nil and #coords > 0 then
						DelLargeNodes(name, 'event', quest, quest, 'event');
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
	-->		line	-1 = Quest Giver	-2 = Quest Completer	0 = event
		function AddLine(name, _quest, _line, _type, _id, _done)
			if _done then
				_log_('AddLine-T_T', name, _type, _id);
			else
				_log_('AddLine-T_F', name, _type, _id);
			end
			if _type == 'monster' then
				local large_pin = __db_large_pin:Check(_quest, 'unit', _id);
				AddUnit(name, _quest, _line, _id, not _done, large_pin, nil);
				return true, _id, large_pin;
			elseif _type == 'item' then
				local large_pin = __db_large_pin:Check(_quest, 'item', _id);
				AddItem(name, _quest, _line, _id, not _done, large_pin);
				return true, _id, large_pin;
			elseif _type == 'object' then
				local large_pin = __db_large_pin:Check(_quest, 'object', _id);
				AddObject(name, _quest, _line, _id, not _done, large_pin);
				return true, _id, large_pin;
			elseif _type == 'event' or _type == 'log' then
				AddEvent(name, _quest);
			elseif _type == 'reputation' then
			elseif _type == 'player' or _type == 'progressbar' then
			else
				_log_('comm_objective_type', _quest, _done, _type);
			end
			return true;
		end
		function DelLine(name, _quest, _line, _type, _id)
			if _done then
				_log_('DelLine-T_T', name, _type, _id);
			else
				_log_('DelLine-T_F', name, _type, _id);
			end
			if _type == 'monster' then
				local large_pin = __db_large_pin:Check(_quest, 'unit', _id);
				DelUnit(_quest, _line, _id, not _done, large_pin);
				return true, _id, large_pin;
			elseif _type == 'item' then
				local large_pin = __db_large_pin:Check(_quest, 'item', _id);
				DelItem(_quest, _line, _id, not _done, large_pin);
				return true, _id, large_pin;
			elseif _type == 'object' then
				local large_pin = __db_large_pin:Check(_quest, 'object', _id);
				DelObject(_quest, _line, _id, not _done, large_pin);
				return true, _id, large_pin;
			elseif _type == 'event' or _type == 'log' then
			elseif _type == 'reputation' then
			elseif _type == 'player' or _type == 'progressbar' then
			else
				_log_('comm_objective_type', _quest, _done, _type);
			end
			return true;
		end
	-->
		local function PushReset(name)
			SendAddonMessage(ADDON_PREFIX, ADDON_MSG_CTRLCODE_PUSH .. "^RESET", "WHISPER", name);
		end
		local function PushAddQuest(_quest, _done, title)
			if _done then
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^1^1^" .. title;
				for name, val in next, GROUP_MEMBERS do
					if val > 0 then
						SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
					end
				end
			else
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^0^1^" .. title;
				for name, val in next, GROUP_MEMBERS do
					if val > 0 then
						SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
					end
				end
			end
		end
		local function PushDelQuest(_quest, _done)
			if _done then
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^1^-1";
				for name, val in next, GROUP_MEMBERS do
					if val > 0 then
						SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
					end
				end
			else
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^0^-1";
				for name, val in next, GROUP_MEMBERS do
					if val > 0 then
						SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
					end
				end
			end
		end
		local function PushAddLine(_quest, _line, _done, _type, _id, _text)
			if _done then
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^LINE^" .. _quest .. "^1^" .. _line .. "^" .. _type .. "^" .. _id .. "^" .. _text;
				for name, val in next, GROUP_MEMBERS do
					if val > 0 then
						SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
					end
				end
			else
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^LINE^" .. _quest .. "^0^" .. _line .. "^" .. _type .. "^" .. _id .. "^" .. _text;
				for name, val in next, GROUP_MEMBERS do
					if val > 0 then
						SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
					end
				end
			end
		end
		--
		local function PushAddQuestSingle(_quest, _done, title, name)
			if _done then
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^1^1^" .. title;
				SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
			else
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^0^1^" .. title;
				SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
			end
		end
		local function PushDelQuestSingle(_quest, _done, name)
			if _done then
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^1^-1";
				SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
			else
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^QUEST^" .. _quest .. "^0^-1";
				SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
			end
		end
		local function PushAddLineSingle(_quest, _line, _done, _type, _id, _text, name)
			if _done then
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^LINE^" .. _quest .. "^1^" .. _line .. "^" .. _type .. "^" .. _id .. "^" .. _text;
				SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
			else
				local msg = ADDON_MSG_CTRLCODE_PUSH .. "^LINE^" .. _quest .. "^0^" .. _line .. "^" .. _type .. "^" .. _id .. "^" .. _text;
				SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", name);
			end
		end
		--
		local function Push(name)
			for quest, meta in next, __core_meta do
				PushAddQuestSingle(quest, meta.completed, meta.title, name);
				for line = 1, #meta do
					local meta_line = meta[line];
					PushAddLine(quest, line, meta_line[5], meta_line[2], meta_line[3], meta_line[4]);
				end
			end
		end
		local function PushAll()
			for name, val in next, GROUP_MEMBERS do
				if val > 0 then
					Push(name);
				end
			end
		end
		local function Pull(name)
			META[name] = {  };
			SendAddonMessage(ADDON_PREFIX, ADDON_MSG_CTRLCODE_PULL, "WHISPER", name);
		end
		local function PullAll(name)
			for name, val in next, GROUP_MEMBERS do
				if val > 0 then
					Pull(name);
				end
			end
		end
	-->
		local function UpdateGroupMembers()
			local _GROUP_MEMBERS = {  };
			for index = 1, GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) do
				local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(index);
				if name == nil then
					__eventHandler:run_on_next_tick(UpdateGroupMembers);
					return;
				end
				name = Ambiguate(name, 'none');
				if name ~= PLAYER_NAME then
					if online then
						if GROUP_MEMBERS[name] == nil or GROUP_MEMBERS[name] < 0 then
							Pull(name);
						end
						_GROUP_MEMBERS[name] = index;
						GROUP_MEMBERS[name] = nil;
					else
						_GROUP_MEMBERS[name] = -index;
						GROUP_MEMBERS[name] = nil;
					end
				end
			end
			GROUP_MEMBERS = _GROUP_MEMBERS;
			__ns.__group_members = GROUP_MEMBERS;
		end
	-->		extern method
		__ns.PushAddQuest = PushAddQuest;
		__ns.PushDelQuest = PushDelQuest;
		__ns.PushAddLine = PushAddLine;
	-->		events and hooks
		-->		QUEST^questId^completed^ act
		-->		LINE ^questId^finished ^line^type^id^text
		function __ns.CHAT_MSG_ADDON(prefix, msg, channel, sender, target, zoneChannelID, localID, name, instanceID)
			if prefix == ADDON_PREFIX then
				local name = Ambiguate(sender, 'none');
				if name ~= PLAYER_NAME then
					local control_code = strsub(msg, 1, ADDON_MSG_CONTROL_CODE_LEN);
					if control_code == ADDON_MSG_CTRLCODE_PULL then
						Push(name);
					elseif control_code == ADDON_MSG_CTRLCODE_PUSH then
						local body = strsub(msg, ADDON_MSG_CONTROL_CODE_LEN + 2, - 1);
						local _, _head, _quest, _done, _val, _type, _id, _text = strsplit("^", msg);
						if _head == "RESET" then
							META[name] = {  };
						elseif META[name] ~= nil then
							local meta_table = META[name];
							if meta_table ~= nil then
								if _head == "QUEST" then
									_quest = tonumber(_quest);
									_done = tonumber(_done);
									_val = tonumber(_val);
									if _val == -1 then
										local meta = meta_table[_quest];
										meta_table[_quest] = nil;
										for index2, meta_line in next, meta do
											DelLine(name, _quest, index2, _type, _id);
										end
									elseif _val == 1 then
										meta_table[_quest] = { completed = _done, title = _type, };
									end
								elseif _head == "LINE" then
									_quest = tonumber(_quest);
									local meta = meta_table[_quest];
									if meta ~= nil then
										if _done == "1" then
											_done = true;
										elseif _done == "0" then
											_done = false;
										else
											return;
										end
										_val = tonumber(_val) or _val;
										_id = tonumber(_id);
										local meta_line = meta[_val];
										if meta_line == nil then
											meta[_val] = { nil, _type, _id, _text, _done, };
										else
											meta_line[2] = _type;
											meta_line[3] = _id;
											meta_line[4] = _text;
											meta_line[5] = _done;
										end
										if _type == 'object' then
											OBJ_LOOKUP[__loc_object[id]] = id;
										end
										AddLine(name, _quest, _val, _type, _id, _done);
									end
								else
								end
							end
						end
					end
				end
			end
		end
		function __ns.GROUP_ROSTER_UPDATE()
			_log_('GROUP_ROSTER_UPDATE');
			__eventHandler:run_on_next_tick(UpdateGroupMembers);
		end
		function __ns.GROUP_FORMED(category, partyGUID)
			_log_('GROUP_JOINED', category, partyGUID);
		end
		function __ns.GROUP_JOINED(category, partyGUID)
			_log_('GROUP_JOINED', category, partyGUID);
		end
		function __ns.GROUP_LEFT(category, partyGUID)
			_log_('GROUP_LEFT', category, partyGUID);
		end
	-->
	function __ns.comm_setup()
		SET = __ns.__sv;
		if RegisterAddonMessagePrefix(ADDON_PREFIX) then
			__eventHandler:RegEvent("CHAT_MSG_ADDON");
			-- __eventHandler:RegEvent("CHAT_MSG_ADDON_LOGGED");
			__eventHandler:RegEvent("GROUP_ROSTER_UPDATE");
			__eventHandler:RegEvent("GROUP_FORMED");
			__eventHandler:RegEvent("GROUP_JOINED");
			__eventHandler:RegEvent("GROUP_LEFT");
			UpdateGroupMembers();
		end
	end
-->

--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.comm'); end
