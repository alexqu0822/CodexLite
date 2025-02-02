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
	local hooksecurefunc = hooksecurefunc;
	local next = next;
	local tremove, wipe = table.remove, table.wipe;
	local _radius_sin, _radius_cos = math.cos, math.sin;
	local GetCVar = GetCVar;
	local GetTime = GetTime;
	local IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown = IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown;
	local GetPlayerFacing = GetPlayerFacing;
	local C_Map = C_Map;
	local CreateFrame = CreateFrame;
	local WorldMapFrame = WorldMapFrame;	-->		WorldMapFrame:WorldMapFrameTemplate	interiting	MapCanvasFrameTemplate:MapCanvasMixin
	local mapCanvas = WorldMapFrame:GetCanvas();	-->		equal WorldMapFrame.ScrollContainer.Child	--	not implementation of MapCanvasMixin!!!
	local CreateFromMixins, MapCanvasDataProviderMixin = CreateFromMixins, MapCanvasDataProviderMixin;
	local Minimap = Minimap;
	local GameTooltip = GameTooltip;
	local _G = _G;

-->
	local DataAgent = DT.DB;
	local l10n = CT.l10n;

	local EventAgent = VT.EventAgent;

	local __MAIN_META = VT.MAIN_META;


	-- local pinFrameLevel = WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	local wm_wrap = CreateFrame('FRAME', nil, mapCanvas);
		wm_wrap:SetSize(1, 1);
		wm_wrap:SetPoint("CENTER");
	local mm_wrap = CreateFrame('FRAME', nil, Minimap);
		mm_wrap:SetSize(1, 1);
		mm_wrap:SetPoint("CENTER");
	local CommonPinFrameLevel, LargePinFrameLevel = 1, 1;
	local function ReCalcFrameLevel(pinFrameLevelsManager)
		local base = pinFrameLevelsManager:GetValidFrameLevel("PIN_FRAME_LEVEL_AREA_POI", 9999);
		wm_wrap:SetFrameLevel(base);
		mm_wrap:SetFrameLevel(base);
		CommonPinFrameLevel = base;
		LargePinFrameLevel = base + 1;
		for index, texture in next, CT.IMG_LIST do
			texture[7] = base + texture[6];
		end
	end
	local pinFrameLevelsManager = WorldMapFrame:GetPinFrameLevelsManager();	--	WorldMapFrame.pinFrameLevelsManager;
	hooksecurefunc(pinFrameLevelsManager, "AddFrameLevel", ReCalcFrameLevel);
	ReCalcFrameLevel(pinFrameLevelsManager);

-->
MT.BuildEnv("map");
-->		MAP
	-->		--	count
		local __popt = { 0, 0, 0, 0, };
		local function __opt_prompt()
			MT.Debug('map.opt', __popt[1], __popt[2], __popt[3], __popt[4]);
		end
		function __popt:count(index, count)
			__popt[index] = __popt[index] + count;
			if VT.__is_dev then MT._TimerStart(__opt_prompt, 0.2, 1); end
		end
		function __popt:reset(index)
			__popt[index] = 0;
			if VT.__is_dev then MT._TimerStart(__opt_prompt, 0.2, 1); end
		end
		function __popt:echo(index)
			return __popt[index];
		end
	-->
	local wm_map = WorldMapFrame:GetMapID();
	local mm_map = C_Map.GetBestMapForUnit('player');
	local map_canvas_scale = mapCanvas:GetScale();
	local wm_normal_size, wm_large_size, wm_varied_size = nil, nil, nil;
	local mm_normal_size, mm_large_size, mm_varied_size = nil, nil, nil;
	local node_menu_modifier = IsShiftKeyDown;
	local META_COMMON = {  };				-->		[map] =	{ [uuid] = { 1{ coord }, 2{ pin }, 3nil, 4nil, }, }
	local META_LARGE = {  };				-->		[map] =	{ [uuid] = { 1{ coord }, 2{ pin }, 3nil, 4nil, }, }
	local META_VARIED = {  };				-->		[map] =	{ [uuid] = { 1{ coord }, 2{ pin }, 3nil, 4nil, }, }
	local MM_COMMON_PINS = {  };			-->		[map] = { coord = pin, }
	local MM_LARGE_PINS = {  };				-->		[map] = { coord = pin, }
	local MM_VARIED_PINS = {  };			-->		[map] = { coord = pin, }
	VT.MAP_META = { META_COMMON, META_LARGE, META_VARIED, };
	local QUEST_TEMPORARILY_BLOCKED = {  };
	local QUEST_PERMANENTLY_BLOCKED = {  };
	local QUEST_PERMANENTLY_BL_LIST = {  };
	-->		function predef
		local Pin_OnEnter, Pin_OnClick;
		local NewWorldMapPin, RelWorldMapCommonPin, AddWorldMapCommonPin, RelWorldMapLargePin, AddWorldMapLargePin, RelWorldMapVariedPin, AddWorldMapVariedPin;
		local IterateWorldMapPinSetSize, ResetWMPin;
		local WorldMap_HideCommonNodesMapUUID, WorldMap_HideLargeNodesMapUUID, WorldMap_HideVariedNodesMapUUID;
		local WorldMap_ChangeCommonLargeNodesMapUUID, WorldMap_ChangeVariedNodesMapUUID;
		local WorldMap_ShowNodesQuest, WorldMap_HideNodesQuest;
		local WorldMap_DrawNodesMap, WorldMap_HideNodesMap;
		local NewMinimapPin, RelMinimapPin, AddMinimapPin, ResetMMPin;
		local Minimap_HideCommonNodesMapUUID, Minimap_HideLargeNodesMapUUID, Minimap_HideVariedNodesMapUUID;
		local Minimap_ChangeCommonLargeNodesMapUUID, Minimap_ChangeVariedNodesMapUUID;
		local Minimap_ShowNodesMapQuest, Minimap_HideNodesQuest;
		local Minimap_DrawNodesMap, Minimap_HideNodes, Minimap_OnUpdate;
		local MapAddCommonNodes, MapDelCommonNodes, MapUpdCommonNodes;
		local MapAddLargeNodes, MapDelLargeNodes, MapUpdLargeNodes;
		local MapAddVariedNodes, MapDelVariedNodes, MapUpdVariedNodes;
		local MapTemporarilyShowQuestNodes, MapTemporarilyHideQuestNodes, MapResetTemporarilyQuestNodesFilter;
		local MapPermanentlyShowQuestNodes, MapPermanentlyHideQuestNodes, MapPermanentlyToggleQuestNodes;
		local MapHideNodes, MapDrawNodes;
		--	setting
		local SetShowPinInContinent, SetNodeMenuModifier;
		local SetWorldmapAlpha;
		local SetWorldmapCommonPinSize, SetWorldmapLargePinSize, SetWorldmapVariedPinSize;
		local SetMinimapAlpha;
		local SetMinimapCommonPinSize, SetMinimapLargePinSize, SetMinimapVariedPinSize;
		local SetMinimapNodeInset, SetMinimapPlayerArrowOnTop;
	-->
	-->		--	Pin Handler
		function Pin_OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			local uuid = self.uuid;
			local _type = uuid[1];
			local _id = uuid[2];
			MT.TooltipSetInfo(GameTooltip, _type, _id);
			GameTooltip:Show();
		end
		local TomTom = nil;
		function Pin_OnClick(self, button)
			local uuid = self.uuid;
			if uuid ~= nil then
				if button == "RightButton" then
					TomTom = TomTom or _G.TomTom;
					local coord = self.coord;
					if coord ~= nil and TomTom ~= nil then
						local _type = uuid[1];
						local _id = uuid[2];
						local _loc = l10n[_type];
						local uid = TomTom:AddWaypoint(coord[3], coord[1] * 0.01, coord[2] * 0.01, {
							title = _loc ~= nil and _loc[_id] or (_type .. ":" .. _id),
							persistent = false,
							minimap = true,
							world = true,
							from = "CodexLite",
						});
						return TomTom:SetCrazyArrow(uid, TomTom.profile.arrow.arrival, uid.title or "TomTom waypoint");
					end
				end
				if node_menu_modifier() then
					if MT.NodeOnModifiedClick(self, uuid) then
						return;
					end
				end
				MT.RelColor3(uuid[3]);
				uuid[3], uuid[6] = MT.GetColor3NextIndex(uuid[6]);
				WorldMap_ChangeCommonLargeNodesMapUUID(wm_map, uuid);
				Minimap_ChangeCommonLargeNodesMapUUID(mm_map, uuid);
			end
		end
	-->
	-->		--	WorldMapFrame Pin
		function NewWorldMapPin(__PIN_TAG, pool_inuse, pool_unused, size, Release, frameLevel)
			local pin = next(pool_unused);
			if pin == nil then
				pin = CreateFrame('FRAME', nil, wm_wrap);
				pin:SetScript("OnEnter", Pin_OnEnter);
				pin:SetScript("OnLeave", MT.OnLeave);
				pin:SetScript("OnMouseUp", Pin_OnClick);
				pin:SetFrameLevel(frameLevel or CommonPinFrameLevel);
				pin.Release = Release;
				pin.__PIN_TAG = __PIN_TAG;
				local icon = pin:CreateTexture(nil, "ARTWORK");
				icon:SetAllPoints();
				icon:SetTexture(CT.IMG_PATH_PIN);
				pin.icon = icon;
			else
				pool_unused[pin] = nil;
			end
			pin:SetSize(size, size);
			pool_inuse[pin] = 1;
			return pin;
		end
		--
		local pool_worldmap_common_pin_inuse = {  };
		local pool_worldmap_common_pin_unused = {  };
		function RelWorldMapCommonPin(pin)
			pool_worldmap_common_pin_unused[pin] = 1;
			pool_worldmap_common_pin_inuse[pin] = nil;
			pin:Hide();
		end
		function AddWorldMapCommonPin(x, y, color3)
			local pin = NewWorldMapPin(CT.TAG_WM_COMMON, pool_worldmap_common_pin_inuse, pool_worldmap_common_pin_unused, wm_normal_size, RelWorldMapCommonPin, CommonPinFrameLevel);
			--		MapCanvasPinMixin:SetPosition(x, y)
			--	>>	MapCanvasMixin:SetPinPosition(pin, x, y)
			--	>>	MapCanvasMixin:ApplyPinPosition(pin, x, y) mainly implemented below
			--	and lots of bullshit about 'nudge'
			local rscale = 0.01 / pin:GetScale();
			pin:SetPoint("CENTER", mapCanvas, "TOPLEFT", mapCanvas:GetWidth() * x * rscale, -mapCanvas:GetHeight() * y * rscale);
			pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
			pin:Show();
			return pin;
		end
		--
		local pool_worldmap_large_pin_inuse = {  };
		local pool_worldmap_large_pin_unused = {  };
		function RelWorldMapLargePin(pin)
			pool_worldmap_large_pin_unused[pin] = 1;
			pool_worldmap_large_pin_inuse[pin] = nil;
			pin:Hide();
		end
		function AddWorldMapLargePin(x, y, color3)
			local pin = NewWorldMapPin(CT.TAG_WM_LARGE, pool_worldmap_large_pin_inuse, pool_worldmap_large_pin_unused, wm_large_size, RelWorldMapLargePin, LargePinFrameLevel);
			--		MapCanvasPinMixin:SetPosition(x, y)
			--	>>	MapCanvasMixin:SetPinPosition(pin, x, y)
			--	>>	MapCanvasMixin:ApplyPinPosition(pin, x, y) mainly implemented below
			--	and lots of bullshit about 'nudge'
			local rscale = 0.01 / pin:GetScale();
			pin:SetPoint("CENTER", mapCanvas, "TOPLEFT", mapCanvas:GetWidth() * x * rscale, -mapCanvas:GetHeight() * y * rscale);
			pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
			pin:Show();
			return pin;
		end
		--
		local pool_worldmap_varied_pin_inuse = {  };
		local pool_worldmap_varied_pin_unused = {  };
		function RelWorldMapVariedPin(pin)
			pool_worldmap_varied_pin_unused[pin] = 1;
			pool_worldmap_varied_pin_inuse[pin] = nil;
			pin:Hide();
		end
		function AddWorldMapVariedPin(x, y, color3, TEXTURE)
			local texture = CT.IMG_LIST[TEXTURE] or CT.IMG_LIST[CT.IMG_INDEX.IMG_DEF];
			local pin = NewWorldMapPin(CT.TAG_WM_VARIED, pool_worldmap_varied_pin_inuse, pool_worldmap_varied_pin_unused, wm_varied_size, RelWorldMapVariedPin, texture[7]);
			pin:SetFrameLevel(texture[7]);
			--		MapCanvasPinMixin:SetPosition(x, y)
			--	>>	MapCanvasMixin:SetPinPosition(pin, x, y)
			--	>>	MapCanvasMixin:ApplyPinPosition(pin, x, y) mainly implemented below
			--	and lots of bullshit about 'nudge'
			local rscale = 0.01 / pin:GetScale();
			pin:SetPoint("CENTER", mapCanvas, "TOPLEFT", mapCanvas:GetWidth() * x * rscale, -mapCanvas:GetHeight() * y * rscale);
			pin.icon:SetTexture(texture[1]);
			pin.icon:SetVertexColor(texture[2] or color3[1] or 1.0, texture[3] or color3[2] or 1.0, texture[4] or color3[3] or 1.0);
			-- if color3 ~= nil then
			-- 	pin.icon:SetVertexColor(color3[1] or 1.0, color3[2] or 1.0, color3[3] or 1.0);
			-- else
			-- 	pin.icon:SetVertexColor(texture[2] or 1.0, texture[3] or 1.0, texture[4] or 1.0);
			-- end
			pin:Show();
			return pin;
		end
		--
		function IterateWorldMapPinSetSize()
			for pin, _ in next, pool_worldmap_common_pin_inuse do
				pin:SetSize(wm_normal_size, wm_normal_size);
			end
			for pin, _ in next, pool_worldmap_large_pin_inuse do
				pin:SetSize(wm_large_size, wm_large_size);
			end
			for pin, _ in next, pool_worldmap_varied_pin_inuse do
				pin:SetSize(wm_varied_size, wm_varied_size);
			end
		end
		--
		function ResetWMPin()
			for pin, _ in next, pool_worldmap_common_pin_inuse do
				pin:Release();
			end
			for pin, _ in next, pool_worldmap_large_pin_inuse do
				pin:Release();
			end
			for pin, _ in next, pool_worldmap_varied_pin_inuse do
				pin:Release();
			end
			__popt:reset(1);
			__popt:reset(2);
			__popt:reset(3);
		end
	-->
	local function UUIDCheckState(uuid, val)
		for quest, refs in next, uuid[4] do
			local meta = __MAIN_META[quest];
			if meta ~= nil and QUEST_TEMPORARILY_BLOCKED[quest] ~= true and QUEST_PERMANENTLY_BLOCKED[quest] ~= true then
				for line, texture in next, refs do
					if line == 'extra' then
						return true;
					end
					local meta_line = meta[line];
					if meta_line ~= nil and not meta_line[5] and texture == val then
						return true;
					end
				end
			end
		end
		return false;
	end
	local function UUIDCheckStateVaried(uuid)
		for quest, refs in next, uuid[4] do
			if QUEST_TEMPORARILY_BLOCKED[quest] ~= true and QUEST_PERMANENTLY_BLOCKED[quest] ~= true then
				if refs['start'] ~= nil or refs['end'] ~= nil then
					return true;
				end
			end
		end
		return false;
	end
	-->		--	draw on WorldMap		--	当前地图每个点都要显示，所以大地图标记表存储为为数据元表的子表与coord一一对应
		function WorldMap_HideCommonNodesMapUUID(map, uuid)
			local meta = META_COMMON[map];
			if meta ~= nil then
				local data = meta[uuid];
				if data ~= nil then
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index]:Release();
						end
						data[2] = {  };
						__popt:count(1, -num_pins);
					end
				end
			end
		end
		function WorldMap_HideLargeNodesMapUUID(map, uuid)
			local large = META_LARGE[map];
			if large ~= nil then
				local data = large[uuid];
				if data ~= nil then
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index]:Release();
						end
						data[2] = {  };
						__popt:count(2, -num_pins);
					end
				end
			end
		end
		function WorldMap_HideVariedNodesMapUUID(map, uuid)
			local varied = META_VARIED[map];
			if varied ~= nil then
				local data = varied[uuid];
				if data ~= nil then
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index]:Release();
						end
						data[2] = {  };
						__popt:count(3, -num_pins);
					end
				end
			end
		end
		function WorldMap_ChangeCommonLargeNodesMapUUID(map, uuid)
			local color3 = uuid[3];
			local meta = META_COMMON[map];
			if meta ~= nil then
				local data = meta[uuid];
				if data ~= nil then
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index].icon:SetVertexColor(color3[1], color3[2], color3[3]);
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				local data = large[uuid];
				if data ~= nil then
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index].icon:SetVertexColor(color3[1], color3[2], color3[3]);
						end
					end
				end
			end
		end
		function WorldMap_ChangeVariedNodesMapUUID(map, uuid)
			local varied = META_VARIED[map];
			if varied ~= nil then
				local data = varied[uuid];
				if data ~= nil then
					local TEXTURE = uuid[5];
					local pins = data[2];
					for index = 1, #pins do
						local pin = pins[index];
						local texture = CT.IMG_LIST[TEXTURE] or CT.IMG_LIST[CT.IMG_INDEX.IMG_DEF];
						pin.icon:SetTexture(texture[1]);
						pin.icon:SetVertexColor(texture[2], texture[3], texture[4]);
						pin:SetFrameLevel(texture[7]);
					end
				end
			end
		end
		function WorldMap_ShowNodesQuest(map, quest)
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					if uuid[4][quest] ~= nil then
						local coords = data[1];
						local pins = data[2];
						local color3 = uuid[3];
						local num_coords = #coords;
						local num_pins = #pins;
						if num_pins < num_coords then
							for index = num_pins + 1, num_coords do
								local coord = coords[index];
								local pin = AddWorldMapCommonPin(coord[1], coord[2], color3);
								pins[index] = pin;
								pin.uuid = uuid;
								pin.coord = coord;
							end
							__popt:count(1, num_coords - num_pins);
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					if uuid[4][quest] ~= nil then
						local coords = data[1];
						local pins = data[2];
						local color3 = uuid[3];
						local num_coords = #coords;
						local num_pins = #pins;
						if num_pins < num_coords then
							for index = num_pins + 1, num_coords do
								local coord = coords[index];
								local pin = AddWorldMapLargePin(coord[1], coord[2], color3);
								pins[index] = pin;
								pin.uuid = uuid;
								pin.coord = coord;
							end
							__popt:count(2, num_coords - num_pins);
						end
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					if uuid[4][quest] ~= nil then
						local coords = data[1];
						local pins = data[2];
						local color3 = uuid[3];
						local TEXTURE = uuid[5];
						local num_coords = #coords;
						local num_pins = #pins;
						if num_pins < num_coords then
							for index = num_pins + 1, num_coords do
								local coord = coords[index];
								local pin = AddWorldMapVariedPin(coord[1], coord[2], color3, TEXTURE);
								pins[index] = pin;
								pin.uuid = uuid;
								pin.coord = coord;
							end
							__popt:count(3, num_coords - num_pins);
						end
					end
				end
			end
		end
		function WorldMap_HideNodesQuest(map, quest)
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					if not UUIDCheckState(uuid, -9998) then
						local pins = data[2];
						local num_pins = #pins;
						if num_pins > 0 then
							for index = 1, num_pins do
								pins[index]:Release();
							end
							data[2] = {  };
							__popt:count(1, -num_pins);
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					if not UUIDCheckState(uuid, -9999) then
						local pins = data[2];
						local num_pins = #pins;
						if num_pins > 0 then
							for index = 1, num_pins do
								pins[index]:Release();
							end
							data[2] = {  };
							__popt:count(2, -num_pins);
						end
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					if not UUIDCheckStateVaried(uuid) then
						local pins = data[2];
						local num_pins = #pins;
						if num_pins > 0 then
							for index = 1, num_pins do
								pins[index]:Release();
							end
							data[2] = {  };
							__popt:count(3, -num_pins);
						end
					end
				end
			end
		end
		function WorldMap_DrawNodesMap(map)
			if not VT.SETTING.show_in_continent and CT.ContinentMapID[map] ~= nil then
				return;
			end
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					if UUIDCheckState(uuid, -9998) then
						local coords = data[1];
						local pins = data[2];
						local color3 = uuid[3];
						local num_coords = #coords;
						local num_pins = #pins;
						if num_pins < num_coords then
							for index = num_pins + 1, num_coords do
								local coord = coords[index];
								local pin = AddWorldMapCommonPin(coord[1], coord[2], color3);
								pins[index] = pin;
								pin.uuid = uuid;
								pin.coord = coord;
							end
							__popt:count(1, num_coords - num_pins);
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					if UUIDCheckState(uuid, -9999) then
						local coords = data[1];
						local pins = data[2];
						local color3 = uuid[3];
						local num_coords = #coords;
						local num_pins = #pins;
						if num_pins < num_coords then
							for index = num_pins + 1, num_coords do
								local coord = coords[index];
								local pin = AddWorldMapLargePin(coord[1], coord[2], color3);
								pins[index] = pin;
								pin.uuid = uuid;
								pin.coord = coord;
							end
							__popt:count(2, num_coords - num_pins);
						end
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					if UUIDCheckStateVaried(uuid) then
						local coords = data[1];
						local pins = data[2];
						local color3 = uuid[3];
						local TEXTURE = uuid[5];
						local num_coords = #coords;
						local num_pins = #pins;
						if num_pins < num_coords then
							for index = num_pins + 1, num_coords do
								local coord = coords[index];
								local pin = AddWorldMapVariedPin(coord[1], coord[2], color3, TEXTURE);
								pins[index] = pin;
								pin.uuid = uuid;
								pin.coord = coord;
							end
							__popt:count(3, num_coords - num_pins);
						end
					end
				end
			end
		end
		function WorldMap_HideNodesMap(map)
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index]:Release();
						end
						data[2] = {  };
						__popt:count(1, -num_pins);
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index]:Release();
						end
						data[2] = {  };
						__popt:count(2, -num_pins);
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					local pins = data[2];
					local num_pins = #pins;
					if num_pins > 0 then
						for index = 1, num_pins do
							pins[index]:Release();
						end
						data[2] = {  };
						__popt:count(3, -num_pins);
					end
				end
			end
		end
	-->
	-->		--	Minimap Pin
		function NewMinimapPin(__PIN_TAG, pool_inuse, pool_unused, size, Release, frameLevel)
			local pin = next(pool_unused);
			if pin == nil then
				pin = CreateFrame('FRAME', nil, mm_wrap);
				pin:SetScript("OnEnter", Pin_OnEnter);
				pin:SetScript("OnLeave", MT.OnLeave);
				pin:SetScript("OnMouseUp", Pin_OnClick);
				pin.Release = Release;
				pin.__PIN_TAG = __PIN_TAG;
				local icon = pin:CreateTexture(nil, "ARTWORK");
				icon:SetAllPoints();
				icon:SetTexture(CT.IMG_PATH_PIN);
				pin.icon = icon;
			else
				pool_unused[pin] = nil;
			end
			pin:SetSize(size, size);
			pin:SetFrameLevel(frameLevel or CommonPinFrameLevel);
			pool_inuse[pin] = 1;
			return pin;
		end
		--
		local pool_minimap_pin_inuse = {  };
		local pool_minimap_pin_unused = {  };
		function RelMinimapPin(pin)
			pool_minimap_pin_unused[pin] = 1;
			pool_minimap_pin_inuse[pin] = nil;
			pin:Hide();
		end
		function AddMinimapPin(__PIN_TAG, img, r, g, b, size, frameLevel)
			local pin = NewMinimapPin(__PIN_TAG, pool_minimap_pin_inuse, pool_minimap_pin_unused, size, RelMinimapPin, frameLevel);
			--		MapCanvasPinMixin:SetPosition(x, y)
			--	>>	MapCanvasMixin:SetPinPosition(pin, x, y)
			--	>>	MapCanvasMixin:ApplyPinPosition(pin, x, y) mainly implemented below
			--	and lots of bullshit about 'nudge'
			pin.icon:SetTexture(img);
			pin.icon:SetVertexColor(r, g, b);
			pin:Show();
			return pin;
		end
		--
		function ResetMMPin()
			for pin, _ in next, pool_minimap_pin_inuse do
				pin:Release();
			end
			__popt:reset(4);
		end
	-->
	-->		--	draw on Minimap			--	只有少部分点显示在小地图，所以单独建表
		--	variables
			local minimap_size = {
				indoor = {
					[0] = 300, -- scale
					[1] = 240, -- 1.25
					[2] = 180, -- 5/3
					[3] = 120, -- 2.5
					[4] = 80,  -- 3.75
					[5] = 50,  -- 6
				},
				outdoor = {
					[0] = 466 + 2/3, -- scale
					[1] = 400,       -- 7/6
					[2] = 333 + 1/3, -- 1.4
					[3] = 266 + 2/6, -- 1.75
					[4] = 200,       -- 7/3
					[5] = 133 + 1/3, -- 3.5
				},
			};
			local mm_check_func_table = {
				CIRCLE = function(dx, dy, range)
					return dx * dx + dy * dy < range * range;
				end,
			};
			local mm_shape = "CIRCLE";
			local GetMinimapShape = _G.GetMinimapShape;
			if GetMinimapShape ~= nil then
				mm_shape = GetMinimapShape() or "CIRCLE";
			else
				mm_shape = "CIRCLE";
			end
			local mm_indoor = GetCVar("minimapZoom") + 0 == Minimap:GetZoom() and "outdoor" or "indoor";
			local mm_zoom = Minimap:GetZoom();
			local mm_hsize = minimap_size[mm_indoor][mm_zoom] * 0.5;
			local mm_hheight = Minimap:GetHeight() * 0.5;
			local mm_hwidth = Minimap:GetWidth() * 0.5;
			local mm_is_rotate = GetCVar("rotateMinimap") == "1";
			local mm_rotate = GetPlayerFacing();
			local mm_rotate_sin = mm_rotate ~= nil and _radius_sin(mm_rotate) or nil;
			local mm_rotate_cos = mm_rotate ~= nil and _radius_cos(mm_rotate) or nil;
			local mm_check_func = mm_check_func_table[mm_shape];
			local mm_force_update = false;
			local mm_player_map, mm_player_x, mm_player_y = MT.GetUnitPosition('player');
			if mm_player_y == nil then mm_player_y = 0.0; end
			if mm_player_x == nil then mm_player_x = 0.0; end
			local mm_dynamic_update_interval = 0.05;
		--
		local mm_arrow_wrap = CreateFrame('FRAME', nil, Minimap);
			mm_arrow_wrap:SetSize(1, 1);
			mm_arrow_wrap:SetPoint("CENTER");
			mm_arrow_wrap:EnableMouse(false);
			mm_arrow_wrap:SetFrameLevel(9999);
		local mm_arrow = mm_arrow_wrap:CreateTexture(nil, "OVERLAY", nil, 7);
			mm_arrow:SetSize(24, 24);
			mm_arrow:SetPoint("CENTER");
			mm_arrow:SetTexture([[Interface\Minimap\MinimapArrow]]);
			hooksecurefunc(Minimap, "SetPlayerTexture", function(_, Texture)
				mm_arrow:SetTexture(Texture);
			end);
		mm_arrow_wrap:SetScript("OnUpdate", function()
			if mm_is_rotate then
				mm_arrow:SetTexCoord(0.0, 1.0, 0.0, 1.0);
			else
				local facing = GetPlayerFacing();
				if facing ~= nil then
					mm_arrow:Show();
					local r = facing - 0.78539816339745;			--	rad(45)
					local c = _radius_cos(r) * 0.70710678118655;	--	sqrt(0.5)
					local s = _radius_sin(r) * 0.70710678118655;	--	sqrt(0.5)
					mm_arrow:SetTexCoord(
						0.5 + c, 0.5 - s,
						0.5 - s, 0.5 - c,
						0.5 + s, 0.5 + c,
						0.5 - c, 0.5 + s
					);
				else
					mm_arrow:Hide();
				end
			end
		end);
		function Minimap_HideCommonNodesMapUUID(map, uuid)
			local num_changed = 0;
			local meta = META_COMMON[map];
			if meta ~= nil then
				local data = meta[uuid];
				if data ~= nil then
					local coords = data[1];
					for index = 1, #coords do
						local coord = coords[index];
						local pin = MM_COMMON_PINS[coord];
						if pin ~= nil then
							pin:Release();
							MM_COMMON_PINS[coord] = nil;
							num_changed = num_changed - 1;
						end
					end
				end
			end
			if num_changed ~= 0 then
				__popt:count(4, num_changed);
			end
		end
		function Minimap_HideLargeNodesMapUUID(map, uuid)
			local num_changed = 0;
			local large = META_LARGE[map];
			if large ~= nil then
				local data = large[uuid];
				if data ~= nil then
					local coords = data[1];
					for index = 1, #coords do
						local coord = coords[index];
						local pin = MM_LARGE_PINS[coord];
						if pin ~= nil then
							pin:Release();
							MM_LARGE_PINS[coord] = nil;
							num_changed = num_changed - 1;
						end
					end
				end
			end
			if num_changed ~= 0 then
				__popt:count(4, num_changed);
			end
		end
		function Minimap_HideVariedNodesMapUUID(map, uuid)
			local num_changed = 0;
			local varied = META_VARIED[map];
			if varied ~= nil then
				local data = varied[uuid];
				if data ~= nil then
					local coords = data[1];
					for index = 1, #coords do
						local coord = coords[index];
						local pin = MM_VARIED_PINS[coord];
						if pin ~= nil then
							pin:Release();
							MM_VARIED_PINS[coord] = nil;
							num_changed = num_changed - 1;
						end
					end
				end
			end
			if num_changed ~= 0 then
				__popt:count(4, num_changed);
			end
		end
		function Minimap_ChangeCommonLargeNodesMapUUID(map, uuid)
			local color3 = uuid[3];
			local meta = META_COMMON[map];
			if meta ~= nil then
				local data = meta[uuid];
				if data ~= nil then
					local coords = data[1];
					for index = 1, #coords do
						local pin = MM_COMMON_PINS[coords[index]];
						if pin ~= nil then
							pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				local data = large[uuid];
				if data ~= nil then
					local coords = data[1];
					for index = 1, #coords do
						local pin = MM_LARGE_PINS[coords[index]];
						if pin ~= nil then
							pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
						end
					end
				end
			end
		end
		function Minimap_ChangeVariedNodesMapUUID(map, uuid)
			local varied = META_VARIED[mm_map];
			if varied ~= nil then
				local data = varied[uuid];
				if data ~= nil then
					local TEXTURE = uuid[5];
					local coords = data[1];
					for index = 1, #coords do
						local coord = coords[index];
						local texture = CT.IMG_LIST[TEXTURE] or CT.IMG_LIST[CT.IMG_INDEX.IMG_DEF];
						local pin = MM_VARIED_PINS[coord];
						if pin ~= nil then
							pin.icon:SetTexture(texture[1]);
							pin.icon:SetVertexColor(texture[2], texture[3], texture[4]);
							pin:SetFrameLevel(texture[7]);
						end
					end
				end
			end
		end
		function Minimap_ShowNodesMapQuest(map, quest)
			local Tick = MT.GetUnifiedTime();
			local num_changed = 0;
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					if uuid[4][quest] ~= nil then
						local color3 = uuid[3];
						local coords = data[1];
						for index = 1, #coords do
							local coord = coords[index];
							local val = coord[5];	--	world
							local dx = val[1] - mm_player_x;
							local dy = val[2] - mm_player_y;
							if dx > -mm_hsize and dx < mm_hsize and dy > -mm_hsize and dy < mm_hsize and (mm_check_func == nil or mm_check_func(dx, dy, mm_hsize)) then
								local pin = MM_COMMON_PINS[coord];
								if pin == nil then
									pin = AddMinimapPin(CT.TAG_MM_COMMON, CT.IMG_PATH_PIN, color3[1], color3[2], color3[3], mm_normal_size, CommonPinFrameLevel);
									MM_COMMON_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin.icon:SetTexture(CT.IMG_PATH_PIN);
									pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
								-- pin.coord = coord;
							else
								local pin = MM_COMMON_PINS[coord];
								if pin ~= nil then
									pin:Release();
									MM_COMMON_PINS[coord] = nil;
									num_changed = num_changed - 1;
								end
							end
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					if uuid[4][quest] ~= nil then
						local color3 = uuid[3];
						local coords = data[1];
						for index = 1, #coords do
							local coord = coords[index];
							local val = coord[5];	--	world
							local dx = val[1] - mm_player_x;
							local dy = val[2] - mm_player_y;
							if dx > -mm_hsize and dx < mm_hsize and dy > -mm_hsize and dy < mm_hsize and (mm_check_func == nil or mm_check_func(dx, dy, mm_hsize)) then
								local pin = MM_LARGE_PINS[coord];
								if pin == nil then
									pin = AddMinimapPin(CT.TAG_MM_LARGE, CT.IMG_PATH_PIN, color3[1], color3[2], color3[3], mm_large_size, LargePinFrameLevel);
									MM_LARGE_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin.icon:SetTexture(CT.IMG_PATH_PIN);
									pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
								-- pin.coord = coord;
							else
								local pin = MM_LARGE_PINS[coord];
								if pin ~= nil then
									pin:Release();
									MM_LARGE_PINS[coord] = nil;
									num_changed = num_changed - 1;
								end
							end
						end
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					if uuid[4][quest] ~= nil then
						local color3 = uuid[3];
						local TEXTURE = uuid[5];
						local coords = data[1];
						for index = 1, #coords do
							local coord = coords[index];
							local val = coord[5];	--	world
							local dx = val[1] - mm_player_x;
							local dy = val[2] - mm_player_y;
							if dx > -mm_hsize and dx < mm_hsize and dy > -mm_hsize and dy < mm_hsize and (mm_check_func == nil or mm_check_func(dx, dy, mm_hsize)) then
								local pin = MM_VARIED_PINS[coord];
								local texture = CT.IMG_LIST[TEXTURE] or CT.IMG_LIST[CT.IMG_INDEX.IMG_DEF];
								if pin == nil then
									pin = AddMinimapPin(CT.TAG_MM_VARIED, texture[1], texture[2] or color3[1], texture[3] or color3[2], texture[4] or color3[3], mm_varied_size, texture[7]);
									MM_VARIED_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin.icon:SetTexture(texture[1]);
									pin.icon:SetVertexColor(texture[2], texture[3], texture[4]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
								-- pin.coord = coord;
							else
								local pin = MM_VARIED_PINS[coord];
								if pin ~= nil then
									pin:Release();
									MM_VARIED_PINS[coord] = nil;
									num_changed = num_changed - 1;
								end
							end
						end
					end
				end
			end
			if num_changed ~= 0 then
				__popt:count(4, num_changed);
			end
			mm_dynamic_update_interval = (MT.GetUnifiedTime() - Tick) * 0.2;
		end
		function Minimap_HideNodesQuest(quest)
			local num_pins = 0;
			for coord, pin in next, MM_COMMON_PINS do
				if not UUIDCheckState(pin.uuid, -9998) then
					pin:Release();
					MM_COMMON_PINS[coord] = nil;
					num_pins = num_pins - 1;
				end
			end
			for coord, pin in next, MM_LARGE_PINS do
				if not UUIDCheckState(pin.uuid, -9999) then
					pin:Release();
					MM_LARGE_PINS[coord] = nil;
					num_pins = num_pins - 1;
				end
			end
			for coord, pin in next, MM_VARIED_PINS do
				if not UUIDCheckStateVaried(pin.uuid) then
					pin:Release();
					MM_VARIED_PINS[coord] = nil;
					num_pins = num_pins - 1;
				end
			end
			__popt:count(4, num_pins);
		end
		function Minimap_DrawNodesMap(map)
			local Tick = MT.GetUnifiedTime();
			local mm_check_range = VT.SETTING.minimap_node_inset and mm_hsize * 0.9 or mm_hsize;
			local num_changed = 0;
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					if UUIDCheckState(uuid, -9998) then
						local color3 = uuid[3];
						local coords = data[1];
						for index = 1, #coords do
							local coord = coords[index];
							local val = coord[5];	--	world
							local dx = val[1] - mm_player_x;
							local dy = val[2] - mm_player_y;
							if dx > -mm_check_range and dx < mm_check_range and dy > -mm_check_range and dy < mm_check_range and (mm_check_func == nil or mm_check_func(dx, dy, mm_check_range)) then
								local pin = MM_COMMON_PINS[coord];
								if pin == nil then
									pin = AddMinimapPin(CT.TAG_MM_COMMON, CT.IMG_PATH_PIN, color3[1], color3[2], color3[3], mm_normal_size, CommonPinFrameLevel);
									MM_COMMON_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin.icon:SetTexture(CT.IMG_PATH_PIN);
									pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
								-- pin.coord = coord;
							else
								local pin = MM_COMMON_PINS[coord];
								if pin ~= nil then
									pin:Release();
									MM_COMMON_PINS[coord] = nil;
									num_changed = num_changed - 1;
								end
							end
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					if UUIDCheckState(uuid, -9999) then
						local color3 = uuid[3];
						local coords = data[1];
						for index = 1, #coords do
							local coord = coords[index];
							local val = coord[5];	--	world
							local dx = val[1] - mm_player_x;
							local dy = val[2] - mm_player_y;
							if dx > -mm_check_range and dx < mm_check_range and dy > -mm_check_range and dy < mm_check_range and (mm_check_func == nil or mm_check_func(dx, dy, mm_check_range)) then
								local pin = MM_LARGE_PINS[coord];
								if pin == nil then
									pin = AddMinimapPin(CT.TAG_MM_LARGE, CT.IMG_PATH_PIN, color3[1], color3[2], color3[3], mm_large_size, LargePinFrameLevel);
									MM_LARGE_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin.icon:SetTexture(CT.IMG_PATH_PIN);
									pin.icon:SetVertexColor(color3[1], color3[2], color3[3]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
								-- pin.coord = coord;
							else
								local pin = MM_LARGE_PINS[coord];
								if pin ~= nil then
									pin:Release();
									MM_LARGE_PINS[coord] = nil;
									num_changed = num_changed - 1;
								end
							end
						end
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					if UUIDCheckStateVaried(uuid) then
						local color3 = uuid[3];
						local TEXTURE = uuid[5];
						local coords = data[1];
						for index = 1, #coords do
							local coord = coords[index];
							local val = coord[5];	--	world
							local dx = val[1] - mm_player_x;
							local dy = val[2] - mm_player_y;
							if dx > -mm_check_range and dx < mm_check_range and dy > -mm_check_range and dy < mm_check_range and (mm_check_func == nil or mm_check_func(dx, dy, mm_check_range)) then
								local pin = MM_VARIED_PINS[coord];
								local texture = CT.IMG_LIST[TEXTURE] or CT.IMG_LIST[CT.IMG_INDEX.IMG_DEF];
								if pin == nil then
									pin = AddMinimapPin(CT.TAG_MM_VARIED, texture[1], texture[2] or color3[1], texture[3] or color3[2], texture[4] or color3[3], mm_varied_size, texture[7]);
									MM_VARIED_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin.icon:SetTexture(texture[1]);
									pin.icon:SetVertexColor(texture[2], texture[3], texture[4]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
								-- pin.coord = coord;
							else
								local pin = MM_VARIED_PINS[coord];
								if pin ~= nil then
									pin:Release();
									MM_VARIED_PINS[coord] = nil;
									num_changed = num_changed - 1;
								end
							end
						end
					end
				end
			end
			if num_changed ~= 0 then
				__popt:count(4, num_changed);
			end
			mm_dynamic_update_interval = (MT.GetUnifiedTime() - Tick) * 0.2;
		end
		function Minimap_HideNodes()
			local num_pins = 0;
			for coord, pin in next, MM_COMMON_PINS do
				pin:Release();
				MM_COMMON_PINS[coord] = nil;
				num_pins = num_pins - 1;
			end
			for coord, pin in next, MM_LARGE_PINS do
				pin:Release();
				MM_LARGE_PINS[coord] = nil;
				num_pins = num_pins - 1;
			end
			for coord, pin in next, MM_VARIED_PINS do
				pin:Release();
				MM_VARIED_PINS[coord] = nil;
				num_pins = num_pins - 1;
			end
			__popt:count(4, num_pins);
		end
		local __mm_prev_update = GetTime();
		function Minimap_OnUpdate(self, elasped)
			if mm_map ~= nil then
				local facing = GetPlayerFacing();
				if facing ~= nil then
					local now = GetTime();
					if __mm_prev_update + mm_dynamic_update_interval <= now then
						local GetMinimapShape = _G.GetMinimapShape;
						if GetMinimapShape ~= nil then
							local shape = GetMinimapShape() or "CIRCLE";
							if mm_shape ~= shape then
								mm_shape = shape;
								mm_force_update = true;
							end
						else
							if mm_shape ~= "CIRCLE" then
								mm_shape = "CIRCLE";
								mm_force_update = true;
							end
						end
						local zoom = Minimap:GetZoom();
						local map, x, y = MT.GetUnitPosition('player');
						if mm_force_update or (mm_player_x ~= x or mm_player_y ~= y or zoom ~= mm_zoom or (mm_is_rotate and facing ~= mm_rotate)) then
							mm_player_x = x;
							mm_player_y = y;
							mm_zoom = zoom;
							mm_rotate = facing;
							mm_rotate_sin = _radius_sin(facing);
							mm_rotate_cos = _radius_cos(facing);
							mm_hsize = minimap_size[mm_indoor][mm_zoom] * 0.5;
							mm_hheight = Minimap:GetHeight() * 0.5;
							mm_hwidth = Minimap:GetWidth() * 0.5;
							Minimap_DrawNodesMap(mm_map);
							mm_force_update = false;
						end
						__mm_prev_update = now;
					end
					return;
				end
			end
			mm_arrow:Hide();
		end
		function EventAgent.MINIMAP_UPDATE_ZOOM()
			-- MT._TimerStart(Minimap_DrawNodes, 0.2, 1);
			-- MT.Debug('MINIMAP_UPDATE_ZOOM', GetCVar("minimapZoom") + 0 == Minimap:GetZoom(), GetCVar("minimapZoom") == Minimap:GetZoom(), GetCVar("minimapZoom"), Minimap:GetZoom())
			local indoor;
			local zoom = Minimap:GetZoom();
			local ozoom = GetCVar("minimapZoom");
			local izoom = GetCVar("minimapInsideZoom");
			if ozoom == izoom then
				Minimap:SetZoom(zoom < 2 and zoom + 1 or zoom - 1);
				indoor = GetCVar("minimapZoom") + 0 == Minimap:GetZoom() and "outdoor" or "indoor";
				Minimap:SetZoom(zoom);
			else
				indoor = ozoom + 0 == zoom and "outdoor" or "indoor";
			end
			if zoom ~= mm_zoom or indoor ~= mm_indoor then
				mm_indoor = indoor;
				mm_zoom = zoom;
				mm_force_update = true;
				Minimap_OnUpdate(Minimap, 0.0);
			end
		end
		function EventAgent.CVAR_UPDATE()
			local is_rotate = GetCVar("rotateMinimap") == "1";
			if mm_is_rotate ~= is_rotate then
				mm_is_rotate = is_rotate;
				mm_force_update = true;
			end
		end
	-->
	-->		--	interface
		--	common_objective pin
		function MapAddCommonNodes(uuid, coords_table)
			if coords_table ~= nil then
				for index = 1, #coords_table do
					local coord = coords_table[index];
					local map = coord[3];
					local meta = META_COMMON[map];
					if meta == nil then
						meta = {  };
						META_COMMON[map] = meta;
					end
					local data = meta[uuid];
					if data == nil then
						data = { {  }, {  }, };
						meta[uuid] = data;
					end
					local coords = data[1];
					coords[#coords + 1] = coord;
					if map == mm_map then
						mm_force_update = true;
					end
				end
			end
		end
		function MapDelCommonNodes(uuid)
			WorldMap_HideCommonNodesMapUUID(wm_map, uuid);
			Minimap_HideCommonNodesMapUUID(mm_map, uuid);
			for map, meta in next, META_COMMON do
				meta[uuid] = nil;
			end
		end
		function MapUpdCommonNodes(uuid)
			if not UUIDCheckState(uuid, -9998) then
				WorldMap_HideCommonNodesMapUUID(wm_map, uuid);
				Minimap_HideCommonNodesMapUUID(mm_map, uuid);
			end
		end
		--	large_objective pin
		function MapAddLargeNodes(uuid, coords_table)
			if coords_table ~= nil then
				for index = 1, #coords_table do
					local coord = coords_table[index];
					local map = coord[3];
					local meta = META_LARGE[map];
					if meta == nil then
						meta = {  };
						META_LARGE[map] = meta;
					end
					local data = meta[uuid];
					if data == nil then
						data = { {  }, {  }, };
						meta[uuid] = data;
					end
					local coords = data[1];
					coords[#coords + 1] = coord;
					if map == mm_map then
						mm_force_update = true;
					end
				end
			end
		end
		function MapDelLargeNodes(uuid)
			WorldMap_HideLargeNodesMapUUID(wm_map, uuid);
			Minimap_HideLargeNodesMapUUID(mm_map, uuid);
			for map, meta in next, META_LARGE do
				meta[uuid] = nil;
			end
		end
		function MapUpdLargeNodes(uuid)
			if not UUIDCheckState(uuid, -9999) then
				WorldMap_HideLargeNodesMapUUID(wm_map, uuid);
				Minimap_HideLargeNodesMapUUID(mm_map, uuid);
			end
		end
		--	varied_objective pin
		function MapAddVariedNodes(uuid, coords_table, flag)
			if flag == nil then
				if coords_table ~= nil then
					for index = 1, #coords_table do
						local coord = coords_table[index];
						local map = coord[3];
						local varied = META_VARIED[map];
						if varied == nil then
							varied = {  };
							META_VARIED[map] = varied;
						end
						local data = varied[uuid];
						if data == nil then
							data = { {  }, {  }, };
							varied[uuid] = data;
						end
						local coords = data[1];
						coords[#coords + 1] = coord;
						if map == mm_map then
							mm_force_update = true;
						end
					end
				end
			else
				if UUIDCheckStateVaried(uuid) then
					WorldMap_ChangeVariedNodesMapUUID(wm_map, uuid);
					Minimap_ChangeVariedNodesMapUUID(mm_map, uuid);
				else
					WorldMap_HideVariedNodesMapUUID(wm_map, uuid);
					Minimap_HideVariedNodesMapUUID(mm_map, uuid);
				end
			end
		end
		function MapDelVariedNodes(uuid, del, flag)
			WorldMap_HideVariedNodesMapUUID(wm_map, uuid);
			Minimap_HideVariedNodesMapUUID(mm_map, uuid);
			for map, varied in next, META_VARIED do
				local data = varied[uuid];
				if data ~= nil then
					varied[uuid] = nil;
				end
			end
		end
		function MapUpdVariedNodes(uuid)
			if not UUIDCheckStateVaried(uuid) then
				WorldMap_HideVariedNodesMapUUID(wm_map, uuid);
				Minimap_HideVariedNodesMapUUID(mm_map, uuid);
			end
		end
		--
		function MapTemporarilyShowQuestNodes(quest)
			if QUEST_TEMPORARILY_BLOCKED[quest] == true then
				QUEST_TEMPORARILY_BLOCKED[quest] = nil;
				WorldMap_ShowNodesQuest(wm_map, quest);
				Minimap_ShowNodesMapQuest(mm_map, quest);
			end
		end
		function MapTemporarilyHideQuestNodes(quest)
			if QUEST_TEMPORARILY_BLOCKED[quest] ~= true then
				QUEST_TEMPORARILY_BLOCKED[quest] = true;
				WorldMap_HideNodesQuest(wm_map, quest);
				Minimap_HideNodesQuest(quest);
			end
		end
		function MapResetTemporarilyQuestNodesFilter()
			wipe(QUEST_TEMPORARILY_BLOCKED);
			MapDrawNodes();
		end
		function MapPermanentlyShowQuestNodes(quest)
			if QUEST_PERMANENTLY_BLOCKED[quest] == true then
				QUEST_PERMANENTLY_BLOCKED[quest] = nil;
				for index = #QUEST_PERMANENTLY_BL_LIST, 1, -1 do
					if QUEST_PERMANENTLY_BL_LIST[index] == quest then
						tremove(QUEST_PERMANENTLY_BL_LIST, index);
						break;
					end
				end
				WorldMap_ShowNodesQuest(wm_map, quest);
				Minimap_ShowNodesMapQuest(mm_map, quest);
				MT.RefreshBlockedList();
			end
		end
		function MapPermanentlyHideQuestNodes(quest)
			if QUEST_PERMANENTLY_BLOCKED[quest] ~= true then
				QUEST_PERMANENTLY_BLOCKED[quest] = true;
				QUEST_PERMANENTLY_BL_LIST[#QUEST_PERMANENTLY_BL_LIST + 1] = quest;
				WorldMap_HideNodesQuest(wm_map, quest);
				Minimap_HideNodesQuest(quest);
				MT.RefreshBlockedList();
			end
		end
		function MapPermanentlyToggleQuestNodes(quest)
			if QUEST_PERMANENTLY_BLOCKED[quest] == true then
				QUEST_PERMANENTLY_BLOCKED[quest] = nil;
				for index = #QUEST_PERMANENTLY_BL_LIST, 1, -1 do
					if QUEST_PERMANENTLY_BL_LIST[index] == quest then
						tremove(QUEST_PERMANENTLY_BL_LIST, index);
						break;
					end
				end
				WorldMap_ShowNodesQuest(wm_map, quest);
				Minimap_ShowNodesMapQuest(mm_map, quest);
			else
				QUEST_PERMANENTLY_BLOCKED[quest] = true;
				QUEST_PERMANENTLY_BL_LIST[#QUEST_PERMANENTLY_BL_LIST + 1] = quest;
				WorldMap_HideNodesQuest(wm_map, quest);
				Minimap_HideNodesQuest(quest);
			end
			MT.RefreshBlockedList();
		end
		--
		function MapDrawNodes()
			WorldMap_DrawNodesMap(wm_map);
			Minimap_DrawNodesMap(mm_map);
		end
		function MapHideNodes()
			WorldMap_HideNodesMap(wm_map);
			Minimap_HideNodes();
		end
		--
	-->
	-->		--	setting
		--	set pin
		function SetShowPinInContinent()
			if CT.ContinentMapID[wm_map] ~= nil then
				if VT.SETTING.show_in_continent then
					WorldMap_DrawNodesMap(wm_map);
				else
					WorldMap_HideNodesMap(wm_map);
				end
			end
		end
		function SetNodeMenuModifier()
			local modifier = VT.SETTING.node_menu_modifier;
			if modifier == "SHIFT" then
				node_menu_modifier = IsShiftKeyDown;
			elseif modifier == "CTRL" then
				node_menu_modifier = IsControlKeyDown;
			elseif modifier == "ALT" then
				node_menu_modifier = IsAltKeyDown;
			end
		end
		function SetWorldmapAlpha()
			wm_wrap:SetAlpha(VT.SETTING.worldmap_alpha);
		end
		function SetWorldmapCommonPinSize()
			--	pool_worldmap_common_pin_inuse, pool_worldmap_common_pin_unused
			wm_normal_size = VT.SETTING.worldmap_normal_size;
			local scale = map_canvas_scale;
			local worldmap_pin_scale_max = VT.SETTING.worldmap_pin_scale_max;
			if scale > worldmap_pin_scale_max then
				wm_normal_size = wm_normal_size * worldmap_pin_scale_max / scale;
			end
			for pin, _ in next, pool_worldmap_common_pin_inuse do
				pin:SetSize(wm_normal_size, wm_normal_size);
			end
		end
		function SetWorldmapLargePinSize()
			--	pool_worldmap_large_pin_inuse, pool_worldmap_large_pin_unused
			wm_large_size = VT.SETTING.worldmap_large_size;
			local scale = map_canvas_scale;
			local worldmap_pin_scale_max = VT.SETTING.worldmap_pin_scale_max;
			if scale > worldmap_pin_scale_max then
				wm_large_size = wm_large_size * worldmap_pin_scale_max / scale;
			end
			for pin, _ in next, pool_worldmap_large_pin_inuse do
				pin:SetSize(wm_large_size, wm_large_size);
			end
		end
		function SetWorldmapVariedPinSize()
			--	pool_worldmap_varied_pin_inuse, pool_worldmap_varied_pin_unused
			wm_varied_size = VT.SETTING.worldmap_varied_size;
			local scale = map_canvas_scale;
			local worldmap_pin_scale_max = VT.SETTING.worldmap_pin_scale_max;
			if scale > worldmap_pin_scale_max then
				wm_varied_size = wm_varied_size * worldmap_pin_scale_max / scale;
			end
			for pin, _ in next, pool_worldmap_varied_pin_inuse do
				pin:SetSize(wm_varied_size, wm_varied_size);
			end
		end
		function SetMinimapAlpha()
			mm_wrap:SetAlpha(VT.SETTING.minimap_alpha);
		end
		function SetMinimapCommonPinSize()
			mm_normal_size = VT.SETTING.minimap_normal_size;
			for _, pin in next, MM_COMMON_PINS do
				pin:SetSize(mm_normal_size, mm_normal_size);
			end
		end
		function SetMinimapLargePinSize()
			mm_large_size = VT.SETTING.minimap_large_size;
			for _, pin in next, MM_LARGE_PINS do
				pin:SetSize(mm_large_size, mm_large_size);
			end
		end
		function SetMinimapVariedPinSize()
			mm_varied_size = VT.SETTING.minimap_varied_size;
			for _, pin in next, MM_VARIED_PINS do
				pin:SetSize(mm_varied_size, mm_varied_size);
			end
		end
		function SetMinimapNodeInset()
			Minimap_HideNodes();
			Minimap_DrawNodesMap(mm_map);
		end
		function SetMinimapPlayerArrowOnTop()
			mm_arrow_wrap:SetShown(VT.SETTING.minimap_player_arrow_on_top);
		end
	-->
	-->		--	extern method
		--
		MT.SetShowPinInContinent = SetShowPinInContinent;
		MT.SetNodeMenuModifier = SetNodeMenuModifier;
		MT.SetWorldmapAlpha = SetWorldmapAlpha;
		MT.SetWorldmapCommonPinSize = SetWorldmapCommonPinSize;
		MT.SetWorldmapLargePinSize = SetWorldmapLargePinSize;
		MT.SetWorldmapVariedPinSize = SetWorldmapVariedPinSize;
		MT.SetMinimapAlpha = SetMinimapAlpha;
		MT.SetMinimapCommonPinSize = SetMinimapCommonPinSize;
		MT.SetMinimapLargePinSize = SetMinimapLargePinSize;
		MT.SetMinimapVariedPinSize = SetMinimapVariedPinSize;
		MT.SetMinimapNodeInset = SetMinimapNodeInset;
		MT.SetMinimapPlayerArrowOnTop = SetMinimapPlayerArrowOnTop;
		--
		MT.MapAddCommonNodes = MapAddCommonNodes;
		MT.MapDelCommonNodes = MapDelCommonNodes;
		MT.MapUpdCommonNodes = MapUpdCommonNodes;
		MT.MapAddLargeNodes = MapAddLargeNodes;
		MT.MapDelLargeNodes = MapDelLargeNodes;
		MT.MapUpdLargeNodes = MapUpdLargeNodes;
		MT.MapAddVariedNodes = MapAddVariedNodes;
		MT.MapDelVariedNodes = MapDelVariedNodes;
		MT.MapUpdVariedNodes = MapUpdVariedNodes;
		MT.MapTemporarilyShowQuestNodes = MapTemporarilyShowQuestNodes;
		MT.MapTemporarilyHideQuestNodes = MapTemporarilyHideQuestNodes;
		MT.MapResetTemporarilyQuestNodesFilter = MapResetTemporarilyQuestNodesFilter;
		MT.MapPermanentlyShowQuestNodes = MapPermanentlyShowQuestNodes;
		MT.MapPermanentlyHideQuestNodes = MapPermanentlyHideQuestNodes;
		MT.MapPermanentlyToggleQuestNodes = MapPermanentlyToggleQuestNodes;
		--
		MT.MapDrawNodes = MapDrawNodes;
		MT.MapHideNodes = MapHideNodes;
		MT.Pin_OnEnter = Pin_OnEnter;
		--
		function MT.ResetMap()
			wipe(META_COMMON);
			wipe(META_LARGE);
			wipe(META_VARIED);
			ResetWMPin();
			wipe(MM_COMMON_PINS);
			wipe(MM_LARGE_PINS);
			wipe(MM_VARIED_PINS);
			ResetMMPin();
		end
		function MT.MapToggleWorldMapPin(shown)
			wm_wrap:SetShown(shown ~= false);
		end
		function MT.MapToggleMinimapPin(shown)
			mm_wrap:SetShown(shown ~= false);
		end
	-->
	-->		--	events and hooks
		-->		--	MapCanvasDataProvider
			local mapCallback = CreateFromMixins(MapCanvasDataProviderMixin);
			function mapCallback:RemoveAllData()
				-- Override in your mixin, this method should remove everything that has been added to the map
			end
			function mapCallback:RefreshAllData(fromOnShow)
				-- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
			end
			function mapCallback:OnShow()
				-- Override in your mixin, called when the map canvas is shown
			end
			function mapCallback:OnHide()
				-- Override in your mixin, called when the map canvas is closed
			end
			function mapCallback:OnMapChanged()
				--  Optionally override in your mixin, called when map ID changes
				-- self:RefreshAllData();
				local uiMapID = WorldMapFrame:GetMapID();
				if uiMapID ~= wm_map then
					WorldMap_HideNodesMap(wm_map);
					wm_map = uiMapID;
					WorldMap_DrawNodesMap(uiMapID);
				end
			end
			function mapCallback:OnCanvasScaleChanged()
				local scale = mapCanvas:GetScale();
				if map_canvas_scale ~= scale then
					map_canvas_scale = scale;
					local worldmap_pin_scale_max = VT.SETTING.worldmap_pin_scale_max;
					--
					wm_normal_size = VT.SETTING.worldmap_normal_size;
					if scale > worldmap_pin_scale_max then
						wm_normal_size = wm_normal_size * worldmap_pin_scale_max / scale;
					end
					--
					wm_large_size = VT.SETTING.worldmap_large_size;
					if scale > worldmap_pin_scale_max then
						wm_large_size = wm_large_size * worldmap_pin_scale_max / scale;
					end
					--
					wm_varied_size = VT.SETTING.worldmap_varied_size;
					if scale > worldmap_pin_scale_max then
						wm_varied_size = wm_varied_size * worldmap_pin_scale_max / scale;
					end
					IterateWorldMapPinSetSize();
				end
			end
			function mapCallback:OnCanvasSizeChanged()
			end
		-->
		function EventAgent.__PLAYER_ZONE_CHANGED(map)
			mm_map = map;
			Minimap_HideNodes();
			Minimap_DrawNodesMap(map);
		end
	-->
	MT.RegisterOnLogin("map", function(LoggedIn)
		QUEST_TEMPORARILY_BLOCKED = VT.QUEST_TEMPORARILY_BLOCKED;
		QUEST_PERMANENTLY_BLOCKED = VT.QUEST_PREMANENTLY_BLOCKED;
		QUEST_PERMANENTLY_BL_LIST = VT.QUEST_PREMANENTLY_BL_LIST;
		-- local HBD = LibStub("HereBeDragons-2.0");
		-- local mapData = HBD.mapData;
		-- --	{ width, height, left, top, instance = instance, name = name, mapType = mapType, parent = parent }
		-- for id, data in next, mapData do
		-- 	if data[1] == 0 or data[2] == 0 then
		-- 		local newData = {  };
		-- 		for id, data in next, mapData do
		-- 			if data[1] ~= 0 and data[2] ~= 0 then
		-- 				newData[id] = data;
		-- 			end
		-- 		end
		-- 		mapData = newData;
		-- 		MT.Debug("rehash map");
		-- 		break;
		-- 	end
		-- end
		-- VT.HDB = HDB;
		-- VT.mapData = mapData;
		-- function MT.GetWorldCoordinatesFromZone(zone, x, y)
		-- 	local data = mapData[zone];
		-- 	if data then
		-- 		x, y = data[3] - data[1] * x, data[4] - data[2] * y;
		-- 		return x, y, data.instance;
		-- 	end
		-- end
		WorldMapFrame:AddDataProvider(mapCallback);
		wm_map = -1;
		mapCallback:OnMapChanged();
		EventAgent:RegEvent("MINIMAP_UPDATE_ZOOM");
		EventAgent:RegEvent("CVAR_UPDATE");
		mm_is_rotate = GetCVar("rotateMinimap") == "1";
		Minimap:HookScript("OnUpdate", Minimap_OnUpdate);
		--
		SetWorldmapAlpha();
		SetMinimapAlpha();
		local worldmap_pin_scale_max = VT.SETTING.worldmap_pin_scale_max;
		wm_normal_size = VT.SETTING.worldmap_normal_size;
		if map_canvas_scale > worldmap_pin_scale_max then
			wm_normal_size = wm_normal_size * worldmap_pin_scale_max / map_canvas_scale;
		end
		wm_large_size = VT.SETTING.worldmap_large_size;
		if map_canvas_scale > worldmap_pin_scale_max then
			wm_large_size = wm_large_size * worldmap_pin_scale_max / map_canvas_scale;
		end
		wm_varied_size = VT.SETTING.worldmap_varied_size;
		if map_canvas_scale > worldmap_pin_scale_max then
			wm_varied_size = wm_varied_size * worldmap_pin_scale_max / map_canvas_scale;
		end
		mm_normal_size = VT.SETTING.minimap_normal_size;
		mm_large_size = VT.SETTING.minimap_large_size;
		mm_varied_size = VT.SETTING.minimap_varied_size;
		SetNodeMenuModifier();
		SetMinimapPlayerArrowOnTop();
	end);

-->
