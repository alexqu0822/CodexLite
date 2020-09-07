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
--------------------------------------------------
--[=[dev]=]	if __ns.__dev then debugprofilestart(); end

local tremove = tremove;
local __db = __ns.db;
local __db_quest = __db.quest;
local __db_unit = __db.unit;
local __db_item = __db.item;
local __db_object = __db.object;
local __db_refloot = __db.refloot;
local __db_event = __db.event;

-->		patch
	local function patch()

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
		__db_unit[5760].coords = { { 57.4, 79.6, 1443, 550, }, };
		
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

__ns.apply_patch = patch;

--[=[dev]=]	if __ns.__dev then __ns.__performance_log('module.patch'); end
