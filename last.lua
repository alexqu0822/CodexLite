--[[--
	by ALA @ 163UI/网易有爱, http://wowui.w.163.com/163ui/
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __private = ...;

local _G = _G;
local _ = nil;
----------------------------------------------------------------------------------------------------
--[=[dev]=]	if __private.__is_dev then __private._F_devDebugProfileStart('module.last'); end


-->		INITIALIZE
	local function init()
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.patch'); end
		__private.apply_patch();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.patch'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.extra_db'); end
		__private.load_extra_db();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.extra_db'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.setting'); end
		__private.setting_setup();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.setting'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.agent'); end
		__private.InitMapAgent();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.agent'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.map'); end
		__private.map_setup();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.map'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.comm'); end
		__private.comm_setup();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.comm'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.core'); end
		__private.core_setup();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.core'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_start('module.init.init.util'); end
		__private.util_setup();
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init.util'); end
		--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.init.init'); end

		__private:MergeGlobal(__private.__svar);
		if __ala_meta__.initpublic then __ala_meta__.initpublic(); end
	end
	local _EventHandler = __private.core.__eventHandler;
	function __private.PLAYER_ENTERING_WORLD()
		_EventHandler:UnregEvent("PLAYER_ENTERING_WORLD");
		__private.After(0.1, init);
	end
	function __private.LOADING_SCREEN_ENABLED()
		_EventHandler:UnregEvent("LOADING_SCREEN_ENABLED");
	end
	function __private.LOADING_SCREEN_DISABLED()
		_EventHandler:UnregEvent("LOADING_SCREEN_DISABLED");
		__private.After(0.1, init);
	end
	-- _EventHandler:RegEvent("PLAYER_ENTERING_WORLD");
	-- _EventHandler:RegEvent("LOADING_SCREEN_ENABLED");
	_EventHandler:RegEvent("LOADING_SCREEN_DISABLED");
-->

--[=[dev]=]	if __private.__is_dev then __private.__performance_log_tick('module.last'); end
