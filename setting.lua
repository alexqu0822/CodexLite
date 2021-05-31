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
--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.setting'); end

-->		variables
	local next = next;
	local tonumber = tonumber;
	local GameTooltip = GameTooltip;

	local __UILOC = __ns.UILOC;

	local _F_SafeCall = __ns.core._F_SafeCall;
	local __eventHandler = __ns.core.__eventHandler;
	local _log_ = __ns._log_;

	local SET = nil;
-->		MAIN
	-->		methods
		local round_func_table = setmetatable({  }, {
			__index = function(t, key)
				if type(key) == 'number' and key % 1 == 0 then
					local dec = 0.1 ^ key;
					local func = function(val)
						val = val + dec * 0.5;
						return val - val % dec;
					end;
					t[key] = func;
					return func;
				end
			end,
		});
		local boolean_func = function(val)
			if val == false or val == "false" or val == 0 or val == "0" or val == nil or val == "off" or val == "disabled" then
				return false;
			else
				return true;
			end
		end
		local setting_metas = {
			show_db_icon = {
				'boolean',
				function(val)
					SET['show_db_icon'] = val;
					if val then
						LibStub("LibDBIcon-1.0", true):Show(__addon);
					else
						LibStub("LibDBIcon-1.0", true):Hide(__addon);
					end
				end,
				nil,
				boolean_func,
			},
			show_quest_starter = {
				'boolean',
				function(val)
					SET['show_quest_starter'] = val;
					__ns.SetQuestStarterShown();
					return true;
				end,
				nil,
				boolean_func,
			},
			show_quest_ender = {
				'boolean',
				function(val)
					SET['show_quest_ender'] = val;
					__ns.SetQuestEnderShown();
					return true;
				end,
				nil,
				boolean_func,
			},
			pin_size = {
				'number',
				function(val)
					val = tonumber(val);
					if val ~= nil then
						SET['pin_size'] = val;
						__ns.SetCommonPinSize();
						return true;
					end
				end,
				{ 8, 32, 1, },
				round_func_table[0],
			},
			large_size = {
				'number',
				function(val)
					val = tonumber(val);
					if val ~= nil then
						SET['large_size'] = val;
						__ns.SetLargePinSize();
						return true;
					end
				end,
				{ 8, 64, 1, },
				round_func_table[0],
			},
			varied_size = {
				'number',
				function(val)
					val = tonumber(val);
					if val ~= nil then
						SET['varied_size'] = val;
						__ns.SetVariedPinSize();
						return true;
					end
				end,
				{ 8, 32, 1, },
				round_func_table[0],
			},
			pin_scale_max = {
				'number',
				function(val)
					val = tonumber(val);
					if val ~= nil then
						SET['pin_scale_max'] = val;
						return true;
					end
				end,
				{ 1.0, 2.0, 0.05, },
				round_func_table[2],
			},
			quest_lvl_lowest_ofs = {
				'number',
				function(val)
					val = tonumber(val);
					if val ~= nil then
						SET['quest_lvl_lowest_ofs'] = val;
						__ns.UpdateQuestGivers();
						return true;
					end
				end,
				{ -__ns.__maxLevel, 0, 1, },
				round_func_table[0],
			},
			quest_lvl_highest_ofs = {
				'number',
				function(val)
					val = tonumber(val);
					if val ~= nil then
						SET['quest_lvl_highest_ofs'] = val;
						__ns.UpdateQuestGivers();
						return true;
					end
				end,
				{ 0, __ns.__maxLevel, 1, },
				round_func_table[0],
			},
			auto_accept = {
				'boolean',
				function(val)
					SET['auto_accept'] = val;
				end,
				nil,
				boolean_func,
			},
			auto_complete = {
				'boolean',
				function(val)
					SET['auto_complete'] = val;
				end,
				nil,
				boolean_func,
			},
			quest_auto_inverse_modifier = {
				'list',
				function(val)
					SET['quest_auto_inverse_modifier'] = val;
					__ns.SetQuestAutoInverseModifier(val);
					__ns.__ui_setting.set_entries['quest_auto_inverse_modifier']:SetVal(val);
				end,
				{ "SHIFT", "CTRL", "ALT", },
			},
			tip_info = {
				'boolean',
				function(val)
					SET['tip_info'] = val;
				end,
				nil,
				boolean_func,
			},
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
				local meta = setting_metas[key];
				if meta ~= nil then
					if meta[1] == 'number' then
						local bound = meta[3];
						if val < bound[1] then
							val = bound[1];
						elseif val > bound[2] then
							val = bound[2];
						end
						if meta[4] ~= nil then
							val = meta[4](val);
						end
						if meta[2](val) then
							print("SET", key, val);
							local widget = __ns.__ui_setting.set_entries[key];
							if widget ~= nil then
								widget:SetVal(val);
							end
						end
					elseif meta[1] == 'boolean' then
						if meta[4] ~= nil then
							val = meta[4](val);
						end
						if meta[2](val) then
							print("SET", key, val);
						end
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
		show_db_icon = true,
		show_quest_starter = true,
		show_quest_ender = true,
		min_rate = 1.0,
		pin_size = 15,
		large_size = 24,
		varied_size = 20,
		pin_scale_max = 1.25,
		quest_lvl_lowest_ofs = -6,		--	>=
		quest_lvl_highest_ofs = 1,		--	<=
		auto_accept = false,
		auto_complete = false,
		quest_auto_inverse_modifier = "SHIFT",
		tip_info = true,
	};
	local setting_keys = {
		-- "min_rate",
		"show_db_icon",
		"show_quest_starter",
		"show_quest_ender",
		"pin_size",
		"large_size",
		"varied_size",
		"pin_scale_max",
		"quest_lvl_lowest_ofs",
		"quest_lvl_highest_ofs",
		"auto_accept",
		"auto_complete",
		"quest_auto_inverse_modifier",
		"tip_info",
	};
	-->
		local function Slider_OnValueChanged(self, val, userInput)
			if userInput and self.func then
				if self.mod ~= nil then
					val = self.mod(val);
				end
				self.func(val);
				self:SetStr(val);
			end
		end
		local function Check_OnClick(self, button)
			local val = self:GetChecked();
			if self.mod ~= nil then
				val = self.mod(val);
			end
			self.func(val);
		end
		local function ListCheck_OnClick(self, button)
			local val = self.val;
			if self.mod ~= nil then
				val = self.mod(val);
			end
			self.func(val);
		end
		function __ns.CreateSettingUI()
			local frame = CreateFrame("FRAME", "CODEX_LITE_SETTING_UI", UIParent, BackdropTemplateMixin ~= nil and "BackdropTemplate" or nil);
			tinsert(UISpecialFrames, "CODEX_LITE_SETTING_UI");
			frame:SetSize(290, 544);
			frame:SetFrameStrata("DIALOG");
			frame:SetPoint("CENTER");
			frame:SetBackdrop({
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile = false,
				tileSize = 16,
				edgeSize = 1,
				insets = { left = 0, right = 0, top = 0, bottom = 0, }
			});
			frame:SetBackdropColor(0.15, 0.15, 0.15, 0.9);
			frame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0);
			frame:EnableMouse(true);
			frame:SetMovable(true);
			frame:RegisterForDrag("LeftButton");
			frame:SetScript("OnDragStart", function(self)
				self:StartMoving();
			end);
			frame:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing();
			end);
			frame:Hide();
			--
			local close = CreateFrame("BUTTON", nil, frame);
			close:SetSize(16, 16);
			close:SetNormalTexture(__ns.core.IMG_PATH .. "close");
			-- close:GetNormalTexture():SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32);
			close:SetPushedTexture(__ns.core.IMG_PATH .. "close");
			-- close:GetPushedTexture():SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32);
			close:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
			close:SetHighlightTexture(__ns.core.IMG_PATH .. "close");
			-- close:GetHighlightTexture():SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32);
			close:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
			close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4);
			close:SetScript("OnClick", function(self)
				self.frame:Hide();
			end);
			close.frame = frame;
			frame.close = close;
			--
			local set_entries = {  };
			frame.set_entries = set_entries;
			local pos = 1;
			local linheight = 16;
			for _, key in next, setting_keys do
				local meta = setting_metas[key];
				if meta[1] == 'number' then
					local bound = meta[3];
					local head = frame:CreateTexture(nil, "ARTWORK");
					head:SetSize(24, 24);
					local label = frame:CreateFontString(nil, "ARTWORK");
					label:SetFont(SystemFont_Shadow_Med1:GetFont(), min(select(2, SystemFont_Shadow_Med1:GetFont()) + 1, 15), "NORMAL");
					label:SetText(gsub(__UILOC[key], "%%[a-z]", ""));
					label:SetPoint("LEFT", head, "RIGHT", 2, 0);
					local slider = CreateFrame("SLIDER", nil, frame, "OptionsSliderTemplate");
					slider:SetWidth(240);
					slider:SetHeight(15);
					slider:SetMinMaxValues(bound[1], bound[2])
					slider:SetValueStep(bound[3]);
					slider:SetObeyStepOnDrag(true);
					slider:SetPoint("TOPLEFT", head, "TOPLEFT", 10, -linheight - 2);
					slider.Text:ClearAllPoints();
					slider.Text:SetPoint("TOP", slider, "BOTTOM", 0, 3);
					slider.Low:ClearAllPoints();
					slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 4, 3);
					slider.Low:SetVertexColor(0.5, 1.0, 0.5);
					slider.Low:SetText(bound[1]);
					slider.High:ClearAllPoints();
					slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -4, 3);
					slider.High:SetVertexColor(1.0, 0.5, 0.5);
					slider.High:SetText(bound[2]);
					slider.key = key;
					slider.head = head;
					slider.label = label;
					slider.func = meta[2];
					slider.mod = meta[4];
					slider:HookScript("OnValueChanged", Slider_OnValueChanged);
					function slider:SetVal(val)
						self:SetValue(val);
						self:SetStr(val);
					end
					function slider:SetStr(val)
						self.Text:SetText(val);
						if val > def[key] then
							self.Text:SetVertexColor(1.0, 0.25, 0.25);
						elseif val < def[key] then
							self.Text:SetVertexColor(0.25, 1.0, 0.25);
						else
							self.Text:SetVertexColor(1.0, 1.0, 1.0);
						end
					end
					slider._SetPoint = slider.SetPoint;
					function slider:SetPoint(...)
						self.head:SetPoint(...);
					end
					set_entries[key] = slider;
					head:SetPoint("CENTER", frame, "TOPLEFT", 32, -10 - pos * linheight);
					pos = pos + 3;
				elseif meta[1] == 'boolean' then
					local check = CreateFrame('CHECKBUTTON', nil, frame, "OptionsBaseCheckButtonTemplate");
					check:SetSize(24, 24);
					check:SetHitRectInsets(0, 0, 0, 0);
					check:Show();
					check.func = meta[2];
					check.mod = meta[4];
					check:SetScript("OnClick", Check_OnClick);
					function check:SetVal(val)
						self:SetChecked(val);
					end
					local label = frame:CreateFontString(nil, "ARTWORK");
					label:SetFont(SystemFont_Shadow_Med1:GetFont(), min(select(2, SystemFont_Shadow_Med1:GetFont()) + 1, 15), "NORMAL");
					label:SetText(gsub(__UILOC[key], "%%[a-z]", ""));
					label:SetPoint("LEFT", check, "RIGHT", 2, 0);
					set_entries[key] = check;
					check:SetPoint("CENTER", frame, "TOPLEFT", 32, -10 - pos * linheight);
					pos = pos + 1.5;
				elseif meta[1] == 'list' then
					local head = frame:CreateTexture(nil, "ARTWORK");
					head:SetSize(24, 24);
					local label = frame:CreateFontString(nil, "ARTWORK");
					label:SetFont(SystemFont_Shadow_Med1:GetFont(), min(select(2, SystemFont_Shadow_Med1:GetFont()) + 1, 15), "NORMAL");
					label:SetText(gsub(__UILOC[key], "%%[a-z]", ""));
					label:SetPoint("LEFT", head, "RIGHT", 2, 0);
					local list = {  };
					local vals = meta[3];
					for index, val in next, vals do
						local check = CreateFrame('CHECKBUTTON', nil, frame, "OptionsBaseCheckButtonTemplate");
						check:SetSize(24, 24);
						check:SetPoint("TOPLEFT", head, "TOPLEFT", 36 + (index - 1) * 80, -linheight * 1.5);
						check:SetHitRectInsets(0, 0, 0, 0);
						check:Show();
						check.func = meta[2];
						check.mod = meta[4];
						check:SetScript("OnClick", ListCheck_OnClick);
						check.list = list;
						check.index = index;
						check.val = val;
						list[index] = check;
						local text = frame:CreateFontString(nil, "ARTWORK");
						text:SetFont(SystemFont_Shadow_Med1:GetFont(), min(select(2, SystemFont_Shadow_Med1:GetFont()) + 1, 15), "NORMAL");
						text:SetText(val);
						text:SetPoint("LEFT", check, "RIGHT", 2, 0);
						check.text = text;
					end
					function list:SetVal(val)
						for index, v in next, vals do
							list[index]:SetChecked(v == val);
						end
					end
					list._SetPoint = list.SetPoint;
					function list:SetPoint(...)
						self.head:SetPoint(...);
					end
					set_entries[key] = list;
					head:SetPoint("CENTER", frame, "TOPLEFT", 32, -10 - pos * linheight);
					pos = pos + 3;
				end
			end
			--
			frame:SetScript("OnShow", function()
				for key, widget in next, set_entries do
					widget:SetVal(SET[key]);
				end
			end);
			return frame;
		end
	-->
	function __ns.setting_setup()
		local GUID = UnitGUID('player');
		local SV = _G.CodexLiteSV;
		if SV == nil then
			SV = {
				setting = def,
				minimap = {
					minimapPos = 0.0,
				},
				mapquestblocked = {
					[GUID] = {  },
				},
			};
			_G.CodexLiteSV = SV;
			SET = SV.setting;
		else
			if SV.__version == nil or SV.__version < 20210529.0 then
				SET = SV;
				SV = {
					setting = SET,
					minimap = {
						minimapPos = SET.minimapPos or 0;
					},
					mapquestblocked = {  },
				};
				SET.minimapPos = nil;
				_G.CodexLiteSV = SV;
			else
				SET = SV.setting;
			end
			for key, val in next, def do
				if SET[key] == nil then
					SET[key] = val;
				end
			end
			SV.mapquestblocked[GUID] = SV.mapquestblocked[GUID] or {  };
		end
		SV.__version = 20210529.0;
		SET.quest_lvl_green = -1;
		SET.quest_lvl_yellow = -1;
		SET.quest_lvl_orange = -1;
		SET.quest_lvl_red = -1;
		__ns.__svar = SV;
		__ns.__setting = SET;
		__ns.__mapquestblocked = SV.mapquestblocked[GUID];
		__ns.__ui_setting = __ns.CreateSettingUI();
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
		__ns.__ui_setting:Show();
	end
-->


--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.setting'); end
