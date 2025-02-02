--[[--
	by ALA
	CREDIT shagu/pfQuest(MIT LICENSE) @ https://github.com/shagu
--]]--
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;

-->		upvalue
	local setmetatable = setmetatable;
	local type = type;
	local select = select;
	local next = next;
	local tinsert = table.insert;
	local strlower, strfind, gsub = string.lower, string.find, string.gsub;
	local min, max = math.min, math.max;
	local tonumber = tonumber;
	local CreateFrame = CreateFrame;
	local GameTooltip = GameTooltip;
	local UIParent = UIParent;
	local UISpecialFrames = UISpecialFrames;
	local SlashCmdList = SlashCmdList;
	local _G = _G;

-->
	local DataAgent = DT.DB;
	local l10n = CT.l10n;

	local IMG_CLOSE = CT.TEXTUREPATH .. "close";
	local _font, _fontsize = SystemFont_Shadow_Med1:GetFont(), min(select(2, SystemFont_Shadow_Med1:GetFont()) + 1, 15);

-->
MT.BuildEnv("setting");
-->		MAIN
	local SettingUI = CreateFrame('FRAME', "CODEX_LITE_SETTING_UI", UIParent);
	VT.SettingUI = SettingUI;
	local tab_entries = { };
	local set_entries = { };
	SettingUI.tab_number = 0;
	SettingUI.tab_entries = tab_entries;
	SettingUI.set_entries = set_entries;
	local LineHeight = 15;
	local function RefreshSettingWidget(key)
		if SettingUI:IsShown() then
			local widget = set_entries[key];
			if widget ~= nil then
				widget:SetVal(VT.SETTING[key]);
			end
		end
	end
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
		--	[key] = { type, func, range, mod, tab, }
		local setting_metas = {
			--	tab.general
				show_db_icon = {
					'boolean',
					function(val)
						VT.SETTING['show_db_icon'] = val;
						local LDI = _G.LibStub("LibDBIcon-1.0", true);
						if val then
							LDI:Show(__addon);
						else
							LDI:Hide(__addon);
						end
						RefreshSettingWidget('show_db_icon');
					end,
					nil,
					boolean_func,
					'tab.general',
				},
				show_buttons_in_log = {
					'boolean',
					function(val)
						VT.SETTING['show_buttons_in_log'] = val;
						MT.SetQuestLogFrameButtonShown(val);
						RefreshSettingWidget('show_buttons_in_log');
					end,
					nil,
					boolean_func,
					'tab.general',
				},
				show_id_in_tooltip = {
					'boolean',
					function(val)
						VT.SETTING['show_id_in_tooltip'] = val;
						RefreshSettingWidget('show_id_in_tooltip');
					end,
					nil,
					boolean_func,
					'tab.general',
				},
				show_quest_starter = {
					'boolean',
					function(val)
						VT.SETTING['show_quest_starter'] = val;
						MT.SetQuestStarterShown();
						RefreshSettingWidget('show_quest_starter');
						return true;
					end,
					nil,
					boolean_func,
					'tab.general',
				},
				show_quest_ender = {
					'boolean',
					function(val)
						VT.SETTING['show_quest_ender'] = val;
						MT.SetQuestEnderShown();
						RefreshSettingWidget('show_quest_ender');
						return true;
					end,
					nil,
					boolean_func,
					'tab.general',
				},
				quest_lvl_lowest_ofs = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['quest_lvl_lowest_ofs'] = val;
							MT.UpdateQuestGivers();
							RefreshSettingWidget('quest_lvl_lowest_ofs');
							return true;
						end
					end,
					{ -CT.MAXLEVEL - 10, 0, 1, },
					round_func_table[0],
					'tab.general',
				},
				quest_lvl_highest_ofs = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['quest_lvl_highest_ofs'] = val;
							MT.UpdateQuestGivers();
							RefreshSettingWidget('quest_lvl_highest_ofs');
							return true;
						end
					end,
					{ 0, CT.MAXLEVEL + 10, 1, },
					round_func_table[0],
					'tab.general',
				},
				limit_item_starter_drop = {
					'boolean',
					function(val)
						VT.SETTING['limit_item_starter_drop'] = val;
						MT.SetLimitItemStarter();
						return true;
					end,
					nil,
					boolean_func,
					'tab.general',
				},
				limit_item_starter_drop_num_coords = {
					'boolean',
					function(val)
						VT.SETTING['limit_item_starter_drop_num_coords'] = val;
						MT.SetLimitItemStarterNumCoords();
						return true;
					end,
					nil,
					boolean_func,
					'tab.general',
				},
				node_menu_modifier = {
					'list',
					function(val)
						VT.SETTING['node_menu_modifier'] = val;
						MT.SetNodeMenuModifier();
						RefreshSettingWidget('node_menu_modifier');
					end,
					{ "SHIFT", "CTRL", "ALT", },
					nil,
					'tab.general',
				},
			--	tab.map
			--	tab.worldmap
				worldmap_alpha = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['worldmap_alpha'] = val;
							MT.SetWorldmapAlpha();
							RefreshSettingWidget('worldmap_alpha');
							return true;
						end
					end,
					{ 0.0, 1.0, 0.05, },
					round_func_table[2],
					'tab.worldmap',
				},
				worldmap_normal_size = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['worldmap_normal_size'] = val;
							MT.SetWorldmapCommonPinSize();
							RefreshSettingWidget('worldmap_normal_size');
							return true;
						end
					end,
					{ 8, 32, 1, },
					round_func_table[0],
					'tab.worldmap',
				},
				worldmap_large_size = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['worldmap_large_size'] = val;
							MT.SetWorldmapLargePinSize();
							RefreshSettingWidget('worldmap_large_size');
							return true;
						end
					end,
					{ 8, 64, 1, },
					round_func_table[0],
					'tab.worldmap',
				},
				worldmap_varied_size = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['worldmap_varied_size'] = val;
							MT.SetWorldmapVariedPinSize();
							RefreshSettingWidget('worldmap_varied_size');
							return true;
						end
					end,
					{ 8, 32, 1, },
					round_func_table[0],
					'tab.worldmap',
				},
				worldmap_pin_scale_max = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['worldmap_pin_scale_max'] = val;
							MT.SetWorldmapCommonPinSize();
							MT.SetWorldmapLargePinSize();
							MT.SetWorldmapVariedPinSize();
							RefreshSettingWidget('worldmap_pin_scale_max');
							return true;
						end
					end,
					{ 1.0, 2.0, 0.05, },
					round_func_table[2],
					'tab.worldmap',
				},
				show_in_continent = {
					'boolean',
					function(val)
						VT.SETTING['show_in_continent'] = val;
						MT.SetShowPinInContinent();
						RefreshSettingWidget('show_in_continent');
						return true;
					end,
					nil,
					boolean_func,
					'tab.worldmap',
				},
			--	tab.minimap
				minimap_alpha = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['minimap_alpha'] = val;
							MT.SetMinimapAlpha();
							RefreshSettingWidget('minimap_alpha');
							return true;
						end
					end,
					{ 0.0, 1.0, 0.05, },
					round_func_table[2],
					'tab.minimap',
				},
				minimap_normal_size = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['minimap_normal_size'] = val;
							MT.SetMinimapCommonPinSize();
							RefreshSettingWidget('minimap_normal_size');
							return true;
						end
					end,
					{ 8, 32, 1, },
					round_func_table[0],
					'tab.minimap',
				},
				minimap_large_size = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['minimap_large_size'] = val;
							MT.SetMinimapLargePinSize();
							RefreshSettingWidget('minimap_large_size');
							return true;
						end
					end,
					{ 8, 64, 1, },
					round_func_table[0],
					'tab.minimap',
				},
				minimap_varied_size = {
					'number',
					function(val)
						val = tonumber(val);
						if val ~= nil then
							VT.SETTING['minimap_varied_size'] = val;
							MT.SetMinimapVariedPinSize();
							RefreshSettingWidget('minimap_varied_size');
							return true;
						end
					end,
					{ 8, 32, 1, },
					round_func_table[0],
					'tab.minimap',
				},
				minimap_node_inset = {
					'boolean',
					function(val)
						VT.SETTING['minimap_node_inset'] = val;
						MT.SetMinimapNodeInset();
						return true;
					end,
					nil,
					boolean_func,
					'tab.minimap',
				},
				minimap_player_arrow_on_top = {
					'boolean',
					function(val)
						VT.SETTING['minimap_player_arrow_on_top'] = val;
						MT.SetMinimapPlayerArrowOnTop();
						return true;
					end,
					nil,
					boolean_func,
					'tab.minimap',
				},
			--	tab.interact
				auto_accept = {
					'boolean',
					function(val)
						VT.SETTING['auto_accept'] = val;
						RefreshSettingWidget('auto_accept');
					end,
					nil,
					boolean_func,
					'tab.interact',
				},
				auto_complete = {
					'boolean',
					function(val)
						VT.SETTING['auto_complete'] = val;
						RefreshSettingWidget('auto_complete');
					end,
					nil,
					boolean_func,
					'tab.interact',
				},
				quest_auto_inverse_modifier = {
					'list',
					function(val)
						VT.SETTING['quest_auto_inverse_modifier'] = val;
						MT.SetQuestAutoInverseModifier(val);
						RefreshSettingWidget('quest_auto_inverse_modifier');
					end,
					{ "SHIFT", "CTRL", "ALT", },
					nil,
					'tab.interact',
				},
				objective_tooltip_info = {
					'boolean',
					function(val)
						VT.SETTING['objective_tooltip_info'] = val;
						RefreshSettingWidget('objective_tooltip_info');
					end,
					nil,
					boolean_func,
					'tab.interact',
				},
			--	tab.misc
		};
		local function ResetAll()
			MT.ResetCore();
			MT.ResetMap();
			MT.UpdateQuests();
			MT.UpdateQuestGivers();
			MT.MapHideNodes();
		end
		function MT.SetSetting(key, val)
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
							print("VT.SETTING", key, val);
							local widget = set_entries[key];
							if widget ~= nil then
								widget:SetVal(val);
							end
						end
					elseif meta[1] == 'boolean' then
						if meta[4] ~= nil then
							val = meta[4](val);
						end
						if meta[2](val) then
							print("VT.SETTING", key, val);
						end
					end
				end
			end
		end
	-->		extern method
		_G.CodexLiteSetting = MT.SetSetting;
		--	/run CodexLiteSetting('quest_lvl_lowest_ofs', -20)
		--	/run CodexLiteSetting('reset')
	-->		events and hooks
	-->
	local def = {
		--	general
			show_db_icon = true,
			show_buttons_in_log = true,
			show_id_in_tooltip = true,
			show_quest_starter = true,
			show_quest_ender = true,
			quest_lvl_lowest_ofs = -6,		--	>=
			quest_lvl_highest_ofs = 1,		--	<=
			limit_item_starter_drop = true,
			limit_item_starter_drop_num_coords = false,
			node_menu_modifier = "SHIFT",
		--	map
			min_rate = 1.0,
		--	worldmap
			worldmap_alpha = 1.0,
			worldmap_normal_size = 15,
			worldmap_large_size = 24,
			worldmap_varied_size = 20,
			worldmap_pin_scale_max = 1.25,
			show_in_continent = false,
		--	minimap
			minimap_alpha = 1.0,
			minimap_normal_size = 15,
			minimap_large_size = 24,
			minimap_varied_size = 20,
			minimap_node_inset = true,
			minimap_player_arrow_on_top = true,
		--	interact
			auto_accept = false,
			auto_complete = false,
			quest_auto_inverse_modifier = "SHIFT",
			objective_tooltip_info = true,
		--	misc
			show_minimappin = true,
			show_worldmappin = true,
	};
	local setting_keys = {
		--	general
			"show_db_icon",
			"show_buttons_in_log",
			"show_id_in_tooltip",
			"show_quest_starter",
			"show_quest_ender",
			"quest_lvl_lowest_ofs",
			"quest_lvl_highest_ofs",
			"limit_item_starter_drop",
			"limit_item_starter_drop_num_coords",
			"node_menu_modifier",
		--	map
			-- "min_rate",
		--	worldmap
			"worldmap_alpha",
			"worldmap_normal_size",
			"worldmap_large_size",
			"worldmap_varied_size",
			"worldmap_pin_scale_max",
			"show_in_continent",
		--	minimap
			"minimap_alpha",
			"minimap_normal_size",
			"minimap_large_size",
			"minimap_varied_size",
			"minimap_node_inset",
			"minimap_player_arrow_on_top",
		--	interact
			"auto_accept",
			"auto_complete",
			"quest_auto_inverse_modifier",
			"objective_tooltip_info",
		--	misc
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
		local function Tab_OnClick(Tab)
			local SelectedTab = SettingUI.SelectedTab;
			if SelectedTab ~= Tab then
				if SelectedTab ~= nil then
					SelectedTab.Sel:Hide();
					SelectedTab.Panel:Hide();
				end
				Tab.Sel:Show();
				Tab.Panel:Show();
				SettingUI.SelectedTab = Tab;
			end
		end
		local function AddTab(tab)
			tab = tab or 'tab.general';
			local Tab = tab_entries[tab];
			if Tab == nil then
				Tab = CreateFrame('BUTTON', nil, SettingUI);
				tab_entries[tab] = Tab;
				local Panel = CreateFrame('FRAME', nil, SettingUI);
				Panel:SetPoint("BOTTOMLEFT", 6, 32);
				Panel:SetPoint("TOPRIGHT", -6, -64);
				Panel:Hide();
				Tab.Panel = Panel;
				Tab:SetSize(64, 24);
				local Text = Tab:CreateFontString(nil, "OVERLAY", "GameFontNormal");
				Text:SetPoint("CENTER");
				Tab.Text = Text;
				local Sel = Tab:CreateTexture(nil, "OVERLAY");
				Sel:SetAllPoints();
				Sel:SetBlendMode("ADD");
				Sel:SetColorTexture(0.25, 0.5, 0.5, 0.5);
				Sel:Hide();
				Tab.Sel = Sel;
				local NTex = Tab:CreateTexture(nil, "ARTWORK");
				Tab:SetNormalTexture(NTex);
				NTex:SetAllPoints();
				NTex:SetColorTexture(0.25, 0.25, 0.25, 0.5);
				local PTex = Tab:CreateTexture(nil, "ARTWORK");
				Tab:SetPushedTexture(PTex);
				PTex:SetAllPoints();
				PTex:SetColorTexture(0.15, 0.25, 0.25, 0.5);
				local HTex = Tab:CreateTexture(nil, "ARTWORK");
				Tab:SetHighlightTexture(HTex);
				HTex:SetAllPoints();
				HTex:SetColorTexture(0.25, 0.25, 0.25, 1.0);
				Tab:SetPoint("TOPLEFT", SettingUI, "TOPLEFT", 4 + 68 * SettingUI.tab_number, -32);
				SettingUI.tab_number = SettingUI.tab_number + 1;
				SettingUI:SetWidth(min(max(SettingUI:GetWidth(), 4 + 68 * SettingUI.tab_number), 1024));
				--
				Tab:SetScript("OnClick", Tab_OnClick);
				Panel.pos = 0;
				Tab.Text:SetText(l10n.ui[tab] or tab);
			end
			return Tab, Tab.Panel;
		end
		local function AddSetting(key)
			local meta = setting_metas[key];
			local Tab, Panel = AddTab(meta[5]);
			if meta[1] == 'number' then
				local bound = meta[3];
				local head = Panel:CreateTexture(nil, "ARTWORK");
				head:SetSize(24, 24);
				local label = Panel:CreateFontString(nil, "ARTWORK");
				label:SetFont(_font, _fontsize, "NORMAL");
				label:SetText(gsub(l10n.ui[key], "%%[a-z]", ""));
				label:SetPoint("LEFT", head, "RIGHT", 2, 0);
				local slider = CreateFrame('SLIDER', nil, Panel);
				slider:SetOrientation("HORIZONTAL");
				slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]]);
				local Thumb = slider:GetThumbTexture();
				Thumb:SetWidth(1);
				Thumb:SetHeight(12);
				Thumb:SetColorTexture(0.6, 1.0, 0.8, 1.0);
				slider:SetWidth(240);
				slider:SetHeight(15);
				slider:SetMinMaxValues(bound[1], bound[2])
				slider:SetValueStep(bound[3]);
				slider:SetObeyStepOnDrag(true);
				slider:SetPoint("LEFT", head, "CENTER", 10, -LineHeight - 2);
				slider.BG = slider:CreateTexture(nil, "BACKGROUND");
				slider.BG:SetPoint("LEFT");
				slider.BG:SetPoint("RIGHT");
				slider.BG:SetHeight(8);
				slider.BG:SetColorTexture(0.0, 0.0, 0.0, 0.5);
				slider.Text = slider:CreateFontString(nil, "ARTWORK");
				slider.Text:SetFont(_font, _fontsize, "");
				slider.Text:SetPoint("TOP", slider, "BOTTOM", 0, 3);
				slider.Low = slider:CreateFontString(nil, "ARTWORK");
				slider.Low:SetFont(_font, _fontsize, "");
				slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 4, 3);
				slider.Low:SetVertexColor(0.5, 1.0, 0.5);
				slider.Low:SetText(bound[1]);
				slider.High = slider:CreateFontString(nil, "ARTWORK");
				slider.High:SetFont(_font, _fontsize, "");
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
					local diff = val - def[key];
					if diff > 0.0000001 then
						self.Text:SetVertexColor(1.0, 0.25, 0.25);
					elseif diff < -0.0000001 then
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
				head:SetPoint("CENTER", Panel, "TOPLEFT", 32, -10 - Panel.pos * LineHeight);
				Panel.pos = Panel.pos + 3;
			elseif meta[1] == 'boolean' then
				local check = CreateFrame('CHECKBUTTON', nil, Panel, "OptionsBaseCheckButtonTemplate");
				check:SetSize(24, 24);
				check:SetHitRectInsets(0, 0, 0, 0);
				check:Show();
				check.func = meta[2];
				check.mod = meta[4];
				check:SetScript("OnClick", Check_OnClick);
				function check:SetVal(val)
					self:SetChecked(val);
				end
				local label = Panel:CreateFontString(nil, "ARTWORK");
				label:SetFont(_font, _fontsize, "NORMAL");
				label:SetText(gsub(l10n.ui[key], "%%[a-z]", ""));
				label:SetPoint("LEFT", check, "RIGHT", 2, 0);
				set_entries[key] = check;
				check:SetPoint("CENTER", Panel, "TOPLEFT", 32, -10 - Panel.pos * LineHeight);
				Panel.pos = Panel.pos + 1.5;
			elseif meta[1] == 'list' then
				local head = Panel:CreateTexture(nil, "ARTWORK");
				head:SetSize(24, 24);
				local label = Panel:CreateFontString(nil, "ARTWORK");
				label:SetFont(_font, _fontsize, "NORMAL");
				label:SetText(gsub(l10n.ui[key], "%%[a-z]", ""));
				label:SetPoint("LEFT", head, "RIGHT", 2, 0);
				local list = {  };
				local vals = meta[3];
				for index, val in next, vals do
					local check = CreateFrame('CHECKBUTTON', nil, Panel, "OptionsBaseCheckButtonTemplate");
					check:SetSize(24, 24);
					check:SetPoint("LEFT", head, "CENTER", 18 + (index - 1) * 80, -LineHeight * 1.5);
					check:SetHitRectInsets(0, 0, 0, 0);
					check:Show();
					check.func = meta[2];
					check.mod = meta[4];
					check:SetScript("OnClick", ListCheck_OnClick);
					check.list = list;
					check.index = index;
					check.val = val;
					list[index] = check;
					local text = Panel:CreateFontString(nil, "ARTWORK");
					text:SetFont(_font, _fontsize, "NORMAL");
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
				head:SetPoint("CENTER", Panel, "TOPLEFT", 32, -10 - Panel.pos * LineHeight);
				Panel.pos = Panel.pos + 3;
			end
			SettingUI:SetHeight(min(max(SettingUI:GetHeight(), 64 + Panel.pos * LineHeight + 32), 1024));
		end
		local function ButtonDeleteOnClick(Delete)
			local quest = VT.QUEST_PREMANENTLY_BL_LIST[Delete:GetParent().__data_index];
			if quest ~= nil then
				MT.MapPermanentlyShowQuestNodes(quest);
				SettingUI.BlockedList:SetNumValue(#VT.QUEST_PREMANENTLY_BL_LIST);
			end
		end
		local function funcToCreateButton(parent, index, height)
			local Button = CreateFrame('BUTTON', nil, parent);
			Button:SetHeight(height);
			local Delete = CreateFrame('BUTTON', nil, Button);
			Delete:SetNormalTexture(IMG_CLOSE);
			Delete:SetPushedTexture(IMG_CLOSE);
			Delete:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
			Delete:SetHighlightTexture(IMG_CLOSE);
			Delete:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
			Delete:SetSize(height - 4, height - 4);
			Delete:SetPoint("LEFT", 4, 0);
			Delete:SetScript("OnClick", ButtonDeleteOnClick);
			Button.Delete = Delete;
			Button.Text = Button:CreateFontString(nil, "ARTWORK", "GameFontNormal");
			Button.Text:SetPoint("LEFT", Delete, "RIGHT", 4, 0);
			return Button;
		end
		local function functToSetButton(Button, data_index)
			Button.__data_index = data_index;
			local quest = VT.QUEST_PREMANENTLY_BL_LIST[data_index];
			if quest ~= nil then
				Button.Text:SetText(MT.GetQuestTitle(quest, true));
				Button:Show();
			else
				Button:Hide();
			end
		end
		function MT.RefreshBlockedList()
			if SettingUI:IsShown() then
				SettingUI.BlockedList:SetNumValue(#VT.QUEST_PREMANENTLY_BL_LIST);
			end
		end
		function MT.InitSettingUI()
			tinsert(UISpecialFrames, "CODEX_LITE_SETTING_UI");
			SettingUI:SetSize(320, 360);
			SettingUI:SetFrameStrata("DIALOG");
			SettingUI:SetPoint("CENTER");
			SettingUI:EnableMouse(true);
			SettingUI:SetMovable(true);
			SettingUI:RegisterForDrag("LeftButton");
			SettingUI:SetScript("OnDragStart", function(self)
				self:StartMoving();
			end);
			SettingUI:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing();
			end);
			SettingUI:Hide();
			--
			local BG = SettingUI:CreateTexture(nil, "BACKGROUND");
			BG:SetAllPoints();
			BG:SetColorTexture(0.0, 0.0, 0.0, 0.9);
			SettingUI.BG = BG;
			--
			local Title = SettingUI:CreateFontString(nil, "ARTWORK", "GameFontNormal");
			Title:SetPoint("CENTER", SettingUI, "TOP", 0, -16);
			Title:SetText(l10n.ui.TAG_SETTING or __addon);
			--
			local close = CreateFrame('BUTTON', nil, SettingUI);
			close:SetSize(16, 16);
			close:SetNormalTexture(IMG_CLOSE);
			-- close:GetNormalTexture():SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32);
			close:SetPushedTexture(IMG_CLOSE);
			-- close:GetPushedTexture():SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32);
			close:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
			close:SetHighlightTexture(IMG_CLOSE);
			-- close:GetHighlightTexture():SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32);
			close:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
			close:SetPoint("TOPRIGHT", SettingUI, "TOPRIGHT", -4, -4);
			close:SetScript("OnClick", function(self)
				self.SettingUI:Hide();
			end);
			close.SettingUI = SettingUI;
			SettingUI.close = close;
			--
			for _, key in next, setting_keys do
				AddSetting(key);
			end
			local Tab, Panel = AddTab('tab.blocked');
			Panel.Scr = VT.__scrolllib.CreateScrollFrame(Panel, Panel:GetWidth(), Panel:GetHeight(), LineHeight, funcToCreateButton, functToSetButton);
			Panel.Scr:SetPoint("CENTER");
			Panel.Scr:SetMouseClickEnabled(false);
			SettingUI.BlockedList = Panel.Scr;
			--
			SettingUI:SetScript("OnShow", function()
				for key, widget in next, set_entries do
					widget:SetVal(VT.SETTING[key]);
				end
				SettingUI.BlockedList:SetNumValue(#VT.QUEST_PREMANENTLY_BL_LIST);
			end);
			Tab_OnClick(tab_entries['tab.general'] or select(2, next(tab_entries)));
			--
			local Tail = SettingUI:CreateFontString(nil, "ARTWORK", "GameFontNormal");
			Tail:SetTextColor(1.0, 1.0, 1.0, 1.0);
			Tail:SetPoint("CENTER", SettingUI, "BOTTOM", 0, 16);
			Tail:SetText(l10n.ui.TAIL_SETTING or "by ALA. Big thx to EKK & qqyt");
		end
	-->
	MT.RegisterOnInit("setting", function(LoggedIn)
		local GUID = CT.SELFGUID;
		local SV = _G.CodexLiteSV;
		if SV == nil or SV.__version == nil or SV.__version < 20210529.0 then
			SV = {
				setting = def,
				minimap = {
					minimapPos = 0.0,
				},
				quest_temporarily_blocked = {
					[GUID] = {  },
				},
				quest_permanently_blocked = {
					[GUID] = {  },
				},
				quest_permanently_bl_list = {
					[GUID] = {  },
				},
				__version = 20210612.0,
			};
			_G.CodexLiteSV = SV;
		else
			if SV.__version < 20210610.0 then
				SV.__version = 20210610.0;
				SV.quest_temporarily_blocked = SV.mapquestblocked;
				SV.mapquestblocked = nil;
			end
			if SV.__version < 20210612.0 then
				SV.__version = 20210612.0;
				SV.quest_permanently_blocked = {  };
				SV.quest_permanently_bl_list = {  };
				SV.setting.objective_tooltip_info = SV.setting.tip_info;
			end
			if SV.__version < 20221031.0 then
				SV.__version = 20221031.0;
				SV.setting.node_menu_modifier = SV.setting.hide_node_modifier;
				SV.setting.worldmap_pin_scale_max = SV.setting.pin_scale_max;
				SV.setting.worldmap_normal_size = SV.setting.pin_size;
				SV.setting.worldmap_large_size = SV.setting.large_size;
				SV.setting.worldmap_varied_size = SV.setting.varied_size;
				SV.setting.minimap_normal_size = SV.setting.pin_size;
				SV.setting.minimap_large_size = SV.setting.large_size;
				SV.setting.minimap_varied_size = SV.setting.varied_size;
				--
				SV.setting.hide_node_modifier = nil;
				SV.setting.pin_scale_max = nil;
				SV.setting.pin_size = nil;
				SV.setting.large_size = nil;
				SV.setting.varied_size = nil;
				SV.setting.pin_size = nil;
				SV.setting.large_size = nil;
				SV.setting.varied_size = nil;
			end
			for key, val in next, def do
				if SV.setting[key] == nil then
					SV.setting[key] = val;
				end
			end
			SV.quest_temporarily_blocked[GUID] = SV.quest_temporarily_blocked[GUID] or {  };
			SV.quest_permanently_blocked[GUID] = SV.quest_permanently_blocked[GUID] or {  };
			SV.quest_permanently_bl_list[GUID] = SV.quest_permanently_bl_list[GUID] or {  };
		end
		if SV.__overridedev == false then
			VT.__is_dev = false;
		end
		VT.SVAR = SV;
		VT.SETTING = SV.setting;
		VT.QUEST_TEMPORARILY_BLOCKED = SV.quest_temporarily_blocked[GUID];
		VT.QUEST_PREMANENTLY_BLOCKED = SV.quest_permanently_blocked[GUID];
		VT.QUEST_PREMANENTLY_BL_LIST = SV.quest_permanently_bl_list[GUID];
		MT.InitSettingUI();
		MT.MergeGlobal(VT.SVAR);
	end);
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
		VT.SettingUI:Show();
	end
-->
