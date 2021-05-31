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
--------------------------------------------------
--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.patch'); end

local tremove = tremove;
local __db = __ns.db;
local __db_quest = __db.quest;
local __db_unit = __db.unit;
local __db_item = __db.item;
local __db_object = __db.object;
local __db_refloot = __db.refloot;
local __db_event = __db.event;

-->		patch

	--[=[
	local PATCH = {
		quest = {
			--10050, preSingle = { 10143, },
			--10160, preSingle = { 10254, },
			--10141, preSingle = { 10254, },
			--10450, preSingle = { 10291, },
			--10269, E=4473
			--10275, E=4475
			--10750, E=4581
			--10772, E=4588
			--9160, E=4064
			--9193, E=4071
			--9400, E=4170
			--9607, E=4200	--	instance
			--9608, E=4201	--	instance
			--9700, E=4280
			--9701, E=4291
			--9716, E=4293
			--9731, E=4298
			--9752, E=4300
			--9786, E=4301
		},
	};
	--]=]
	local function patchDB()
	--[=[
		for key, patch in next, PATCH do
			local db = __db[key];
			if db ~= nil then
				for id, val in next, patch do
					local t = db[id];
					if t ~= nil then
						for k, v in next, val do
							if v == "_NIL" then
								t[k] = nil;
							else
								t[k] = v;
							end
						end
					end
				end
			end
		end
	--]=]
		if UnitFactionGroup('player') == "Alliance" then
			--	alliance
			__db_unit[13778].coords = {
				{ 48.5, 58.3, 1459, 0,},
				{ 50.2, 65.3, 1459, 0,},
				{ 49.3, 84.4, 1459, 0,},
				{ 48.3, 84.3, 1459, 0,},
			};
		else
			--	horde
			__db_unit[13778].coords = {
				{ 52.8, 44, 1459, 0,},
				{ 50.8, 30.8, 1459, 0,},
				{ 45.2, 14.6, 1459, 0,},
				{ 44, 18.1, 1459, 0,},
			};
		end
		__db_item[8932].U = nil;

		__ns.correct_name_hash = {
			["魔化瑟银锭"] = 12655,
			["瘟疫龙崽"] = 10678,
			["解放拉瑟莱克的仆从"] = 7668,
			["解放戈洛尔的仆从"] = 7669,
			["解放奥利斯塔的仆从"] = 7670,
			["解放瑟温妮的仆从"] = 7671,
			["Servants of Razelikh Freed"] = 7668,
			["Servants of Grol Freed"] = 7669,
			["Servants of Allistarj Freed"] = 7670,
			["Servants of Sevine Freed"] = 7671,
		};
	end
-->

-->
	local PreloadCoords = __ns.core.PreloadCoords;
	local function PreloadAllCoords()
		local DB = { obj = __db_object, unit = __db_unit, };
		for key, db in next, DB do
			for id, info in next, db do
				PreloadCoords(info);
			end
		end
	end
	__ns.core.PreloadAllCoords = PreloadAllCoords;
-->

__ns.apply_patch = patchDB;

--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.patch'); end
