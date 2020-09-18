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
	local next = next;
	local tonumber = tonumber;
	local GameTooltip = GameTooltip;

	local __UILOC = __ns.UILOC;

	local __safeCall = __ns.core.__safeCall;
	local __eventHandler = __ns.core.__eventHandler;
	local _log_ = __ns._log_;

	local SET = nil;
-->		MAIN
	-->		methods
		local set_handlers = {
			pin_size = function(val)
				val = tonumber(val);
				if val ~= nil then
					CodexLiteSV['pin_size'] = val;
					__ns.SetCommonPinSize();
					return true;
				end
			end,
			large_size = function(val)
				val = tonumber(val);
				if val ~= nil then
					CodexLiteSV['large_size'] = val;
					__ns.SetLargePinSize();
					return true;
				end
			end,
			varied_size = function(val)
				val = tonumber(val);
				if val ~= nil then
					CodexLiteSV['varied_size'] = val;
					__ns.SetVariedPinSize();
					return true;
				end
			end,
			pin_scale_max = function(val)
				val = tonumber(val);
				if val ~= nil then
					CodexLiteSV['pin_scale_max'] = val;
					return true;
				end
			end,
			quest_lvl_lowest_ofs = function(val)
				val = tonumber(val);
				if val ~= nil then
					CodexLiteSV['quest_lvl_lowest_ofs'] = val;
					__ns.UpdateQuestGivers();
					return true;
				end
			end,
			quest_lvl_highest_ofs = function(val)
				val = tonumber(val);
				if val ~= nil then
					CodexLiteSV['quest_lvl_highest_ofs'] = val;
					__ns.UpdateQuestGivers();
					return true;
				end
			end,
		};
		local function ResetAll()
			__ns.core_reset();
			__ns.map_reset();
			__ns.UpdateQuests();
			__ns.UpdateQuestGivers();
			__ns.MapHideNodes();
		end
		function __ns.Setting(key, val)
			if key == 'reset' then
				ResetAll();
			else
				local handler = set_handlers[key];
				if handler ~= nil then
					if handler(val) then
						print("SET", key, val);
					end
				end
			end
		end
	-->		extern method
		_G.CodexLiteSetting = __ns.Setting;
		--	/run CodexLiteSetting('quest_lvl_lowest_ofs', -20)
		--	/run CodexLiteSetting('reset')
	-->		events and hooks
	-->
	local def = {
		min_rate = 1.0,
		pin_size = 15,
		large_size = 24,
		varied_size = 20,
		pin_scale_max = 1.25,
		quest_lvl_lowest_ofs = -6,		--	>=
		quest_lvl_highest_ofs = 1,		--	<=
		quest_lvl_green = -1,
		quest_lvl_yellow = -1,
		quest_lvl_orange = -1,
		quest_lvl_red = -1,
	};
	function __ns.setting_setup()
		_G.CodexLiteSV = _G.CodexLiteSV or {  };
		local SV = _G.CodexLiteSV;
		for key, val in next, def do
			if SV[key] == nil then
				SV[key] = val;
			end
		end
		SV.quest_lvl_green = -1;
		SV.quest_lvl_yellow = -1;
		SV.quest_lvl_orange = -1;
		SV.quest_lvl_red = -1;
		__ns.__sv = SV;
	end
-->

-->		SLASH
	local strfind, strlower = strfind, strlower;
	_G.SLASH_ALAQUEST1 = "/alaquest";
	_G.SLASH_ALAQUEST2 = "/alaq";
	_G.SLASH_ALAQUEST3 = "/codexlite";
	_G.SLASH_ALAQUEST4 = "/cdxl";
	local SEPARATOR = "[ %`%~%!%@%#%$%%%^%&%*%(%)%-%_%=%+%[%{%]%}%\\%|%;%:%\'%\"%,%<%.%>%/%?]*";
	local SET_PATTERN = "^" .. SEPARATOR .. "set" .. SEPARATOR .. "(.+)" .. SEPARATOR .. "$";
	local UI_PATTERN = "^" .. SEPARATOR .. "ui" .. SEPARATOR .. "(.+)" .. SEPARATOR .. "$";
	SlashCmdList["ALAQUEST"] = function(msg)
		msg = strlower(msg);
		--	set
		local _, pattern;
		_, _, pattern = strfind(msg, SET_PATTERN);
		if pattern then
			return;
		end
		_, _, pattern = strfind(msg, UI_PATTERN);
		if pattern then
			return;
		end
		--	default
		if strfind(msg, "[A-Za-z0-9]+" ) then
		else
		end
	end
-->


--[=[dev]=]	if __ns.__dev then __ns.__performance_log('module.util'); end
