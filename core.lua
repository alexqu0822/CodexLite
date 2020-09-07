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

	local __safeCall = __ns.core.__safeCall;
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
	-->		methods
		local META = {  };	--	[quest_id] = { [flag_whether_nodes_added], [completed], [num_lines], [line(1, 2, 3, ...)] = { shown, objective_type, objective_id, description, finished, is_large_pin, progress, required, }, }
		local CACHE = {  };	--	如果META初始不为空（从保存变量中加载），需要根据META表初始化
		local OBJ_LOOKUP = {  };
		local QUESTS_COMPLETED = {  };
		__ns.__core_meta = META;
		__ns.__obj_lookup = OBJ_LOOKUP;
		__ns.__core_quests_completed = QUESTS_COMPLETED;
		-->		function predef
		local AddUnit, DelUnit, AddObject, DelObject, AddRefloot, DelRefloot, AddItem, DelItem, AddEvent, DelEvent;
		local AddQuester_VariedTexture, DelQuester_VariedTexture, AddQuestStart, DelQuestStart, AddQuestEnd, DelQuestEnd;
		local AddLine, DelLine, LoadQuestCache, UpdateQuests;
		local UpdateQuestGivers;
		local CalcQuestColor;
		-->		line	-1 = Quest Giver	-2 = Quest Completer	0 = event
		-->		send quest data to ui
			function AddUnit(quest, line, uid, show_coords, large_pin, showFriend)
				local info = __db_unit[uid];
				if info ~= nil then
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
					if not showFriend == not isFriend then
						-- if show_coords then
							PreloadCoords(info);
							local coords = show_coords and info.coords or nil;
							if large_pin then
								__ns.AddLargeNodes('unit', uid, quest, line, coords);
							else
								__ns.AddCommonNodes('unit', uid, quest, line, coords);
							end
						-- end
					end
				end
			end
			function DelUnit(quest, line, uid, total_del, large_pin)
				if large_pin then
					__ns.DelLargeNodes('unit', uid, quest, line, total_del);
				else
					__ns.DelCommonNodes('unit', uid, quest, line, total_del);
				end
			end
			function AddObject(quest, line, oid, show_coords, large_pin)
				local info = __db_object[oid];
				if info ~= nil then
					-- if show_coords then
						PreloadCoords(info);
						local coords = show_coords and info.coords or nil;
						if large_pin then
							__ns.AddLargeNodes('object', oid, quest, line, coords);
						else
							__ns.AddCommonNodes('object', oid, quest, line, coords);
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
					__ns.DelLargeNodes('object', oid, quest, line, total_del);
				else
					__ns.DelCommonNodes('object', oid, quest, line, total_del);
				end
			end
			function AddRefloot(quest, line, rid, show_coords, large_pin)
				local info = __db_refloot[rid];
				if info ~= nil then
					if info.U ~= nil then
						for uid, _ in next, info.U do
							AddUnit(quest, line, uid, show_coords, large_pin);
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
								AddUnit(quest, line, uid, show_coords, large_pin);
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
							DelItem(quest, line, iid, total_del, large_pin);
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
									if cs ~= nil and #cs > 0 then
										for j = 1, #cs do
											tinsert(coords, cs[j]);
										end
									end
								end
							end
							E.coords = coords;
							PreloadCoords(E);
						end
						if #coords > 0 then
							__ns.AddLargeNodes('event', quest, quest, 'event', coords);
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
						if coords ~= nil then
							__ns.DelLargeNodes('event', quest, quest, 'event');
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
								-- if coords ~= nil and #coords > 0 then
									__ns.AddVariedNodes('object', oid, quest, which, coords, TEXTURE);
								-- end
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
								-- if coords ~= nil and #coords > 0 then
									__ns.AddVariedNodes('unit', uid, quest, which, coords, TEXTURE);
								-- end
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
							__ns.DelVariedNodes('object', O[index], quest, which);
						end
					end
					local U = info.U;
					if U ~= nil then
						for index = 1, #U do
							__ns.DelVariedNodes('unit', U[index], quest, which);
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
								AddUnit(quest_id, index, uid, not finished, large_pin);
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
								local large_pin = __db_large_pin:Check(quest_id, 'obj', oid);
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
				--[=[dev]=]	if __ns.__dev then debugprofilestart(); end
				local _, num = GetNumQuestLogEntries();
				local quest_changed = false;
				local need_re_draw = false;
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
								meta.flag = 1;
								meta.num_lines = num_lines;
								local has_unfinished_event = false;
								if completed == 1 or completed == -1 then			--	第一次检测到任务成功或失败时，隐藏已显示的任务目标
									for index2 = 1, num_lines do
										local description, objective_type, finished = GetQuestLogLeaderBoard(index2, index);
										local meta_line = meta[index2];
										if meta_line == nil then
											meta_line = { false, objective_type, nil, description, finished, nil, };
											meta[index2] = meta_line;
										else
											meta_line[2] = objective_type;
											meta_line[4] = description;
											meta_line[5] = finished;
											if meta.completed == 0 then
												if meta_line[1] then
													DelLine(quest_id, index2, meta_line[2], meta_line[3], false, meta_line[6]);
												end
												meta_line[1] = false;
											end
										end
										if meta_line[3] == nil then
											local valid, objective_id, large_pin = AddLine(quest_id, index2, objective_type, description, true);
											if objective_id ~= nil then
												meta_line[3] = objective_id;
												meta_line[6] = large_pin;
											end
										end
									end
									if meta.event_shown == true then
										DelEvent(quest_id);
									end
								else												--	检查任务进度
									-- local details = GetQuestObjectives(quest_id);
									for index2 = 1, num_lines do
										local description, objective_type, finished = GetQuestLogLeaderBoard(index2, index);
										-- local detail = details[index2];
										-- local objective_type, finished, numRequired, numFulfilled, description = detail.type, detail.finished, detail.numRequired, detail.numFulfilled, detail.text;
										local meta_line = meta[index2];
										if meta_line == nil then
											meta_line = { false, objective_type, nil, description, finished, nil, };
											meta[index2] = meta_line;
										else
											meta_line[2] = objective_type;
											meta_line[4] = description;
											meta_line[5] = finished;
										end
										--	objective_type:		'item', 'object', 'monster', 'reputation', 'log', 'event', 'player', 'progressbar'
										if finished then
											if meta_line[1] then
												DelLine(quest_id, index2, objective_type, meta_line[3], false, meta_line[6]);
											end
											meta_line[1] = false;
											if meta_line[3] == nil then
												local valid, objective_id, large_pin = AddLine(quest_id, index2, objective_type, description, true);
												if objective_id ~= nil then
													meta_line[3] = objective_id;
													meta_line[6] = large_pin;
												end
											end
										else
											if not meta_line[1] then
												local valid, objective_id, large_pin = AddLine(quest_id, index2, objective_type, description, false);
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
									end
									if has_unfinished_event then
										if meta.event_shown ~= true then
											AddEvent(quest_id);
											meta.event_shown = true;
										end
									else
										if meta.event_shown == true then
											DelEvent(quest_id);
											meta.event_shown = false;
										end
									end
								end
								if meta.completed ~= completed then
									meta.completed = completed;
									if completed == -1 then							--	失败时，添加起始点
										AddQuestStart(quest_id, info);
										need_re_draw = true;
									elseif completed == 1 then						--	成功时，添加结束点，删除起始点
										DelQuestStart(quest_id, info);
										AddQuestEnd(quest_id, info, IMG_INDEX.IMG_E_COMPLETED);
										need_re_draw = true;
									elseif completed == 0 then						--	未完成时，添加结束点，删除起始点
										DelQuestStart(quest_id, info);
										AddQuestEnd(quest_id, info, IMG_INDEX.IMG_E_UNCOMPLETED);
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
						if meta.num_lines ~= nil then
							for index2 = 1, meta.num_lines do
								local meta_line = meta[index2];
								if meta_line ~= nil then
									DelLine(quest_id, index2, meta_line[2], meta_line[3], true, meta_line[6]);
								end
							end
						end
						local info = __db_quest[quest_id];
						if info ~= nil then
							DelQuestEnd(quest_id, info);
							if not QUESTS_COMPLETED[quest_id] then
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
					end
				end
				for quest_id, meta in next, META do
					meta.flag = -1;
				end
				if quest_changed then
					__eventHandler:run_on_next_tick(__ns.UpdateQuestGivers);
				end
				if need_re_draw then
					__eventHandler:run_on_next_tick(__ns.DrawNodes);
				end
				--[=[dev]=]	if __ns.__dev then __ns.__performance_log('module.core.UpdateQuests'); end
			end
		-->		avl quest giver
			local QUEST_WATCH_REP = {  };
			local QUEST_WATCH_SKILL = {  };
			function UpdateQuestGivers()
				--[=[dev]=]	if __ns.__dev then debugprofilestart(); end
				local lowest = __ns.__player_level + SET.quest_lvl_lowest_ofs;
				local highest = __ns.__player_level + SET.quest_lvl_highest_ofs;
				for _, quest_id in next, __db_avl_quest_list do
					local info = __db_quest[quest_id];
					if META[quest_id] == nil and QUESTS_COMPLETED[quest_id] == nil then
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
												if rep ~= nil and #rep > 0 then
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
						if acceptable then
							AddQuestStart(quest_id, info);
						else
							DelQuestStart(quest_id, info);
						end
					end
				end
				__eventHandler:run_on_next_tick(__ns.DrawNodes);
				--[=[dev]=]	if __ns.__dev then __ns.__performance_log('module.core.UpdateQuestGivers'); end
			end
		-->		misc
			local CalcQuestColorCount = 0;
			function CalcQuestColor()
				local changed = false;
				local prev = GetQuestDifficultyColor(2).font;
				for level = 2, 72 do
					local color1, color2 = GetQuestDifficultyColor(level);
					local font = color1.font;
					if prev ~= font then
						if prev == "QuestDifficulty_Trivial" then
							if font == "QuestDifficulty_Standard" then
								if SET.quest_lvl_green ~= level then
									SET.quest_lvl_green = level;
									changed = true;
								end
							else
							end
						elseif prev == "QuestDifficulty_Standard" then
							if font == "QuestDifficulty_Difficult" then
								if SET.quest_lvl_yellow ~= level then
									SET.quest_lvl_yellow = level;
									changed = true;
								end
							else
							end
						elseif prev == "QuestDifficulty_Difficult" then
							if font == "QuestDifficulty_VeryDifficult" then
								if SET.quest_lvl_orange ~= level then
									SET.quest_lvl_orange = level;
									changed = true;
								end
							else
							end
						elseif prev == "QuestDifficulty_VeryDifficult" then
							if font == "QuestDifficulty_Impossible" then
								if SET.quest_lvl_red ~= level then
									SET.quest_lvl_red = level;
									changed = true;
									break;
								end
							else
							end
						end
						prev = font;
					end
				end
				CalcQuestColorCount = CalcQuestColorCount + 1;
				if changed or CalcQuestColorCount > 20 then
					_log_('color:1', SET.quest_lvl_green, SET.quest_lvl_yellow, SET.quest_lvl_orange, SET.quest_lvl_red, 'count', CalcQuestColorCount);
					UpdateQuestGivers();
				else
					__eventHandler:run_on_next_tick(CalcQuestColor);
				end
			end
		-->		extern method
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
				QUESTS_COMPLETED = GetQuestsCompleted();
			end
		-->
	-->		events and hooks
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
	-->
	function __ns.core_setup()
		SET = __ns.__sv;
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

		-- __eventHandler:RegEvent("GOSSIP_SHOW");
		-- __eventHandler:RegEvent("QUEST_GREETING");
		-- __eventHandler:RegEvent("QUEST_DETAIL");
		-- __eventHandler:RegEvent("QUEST_PROGRESS");
		-- __eventHandler:RegEvent("QUEST_COMPLETE");
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
		__eventHandler:RegEvent("UNIT_QUEST_LOG_CHANGED");
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

--[=[dev]=]	if __ns.__dev then __ns.__performance_log('module.core'); end
