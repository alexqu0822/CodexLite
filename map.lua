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
--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.map'); end

local GameTooltip = GameTooltip;
local function button_info_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local info_lines = self.info_lines;
	if info_lines then
		for index = 1, #info_lines do
			GameTooltip:AddLine(info_lines[index]);
		end
	end
	GameTooltip:Show();
end
local function button_info_OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide();
	end
end


-->		variables
	local next = next;
	local _radius_sin, _radius_cos = math.cos, math.sin;
	local CreateFrame = CreateFrame;
	local WorldMapFrame = WorldMapFrame;	-->		WorldMapFrame:WorldMapFrameTemplate	interiting	MapCanvasFrameTemplate:MapCanvasMixin
	local mapCanvas = WorldMapFrame:GetCanvas();	-->		equal WorldMapFrame.ScrollContainer.Child	--	not implementation of MapCanvasMixin!!!
	local Minimap = Minimap;

	local __db = __ns.db;
	local __db_quest = __db.quest;
	local __db_unit = __db.unit;
	local __db_item = __db.item;
	local __db_object = __db.object;
	local __db_refloot = __db.refloot;
	local __db_event = __db.event;

	local __loc = __ns.L;
	local __loc_quest = __loc.quest;
	local __loc_unit = __loc.unit;
	local __loc_item = __loc.item;
	local __loc_object = __loc.object;
	local __loc_profession = __loc.profession;
	local __UILOC = __ns.UILOC;

	local _F_SafeCall = __ns.core._F_SafeCall;
	local __eventHandler = __ns.core.__eventHandler;
	local __const = __ns.core.__const;
	local __core_meta = __ns.__core_meta;

	local UnitHelpFac = __ns.core.UnitHelpFac;
	local _log_ = __ns._log_;

	local IMG_INDEX = __ns.core.IMG_INDEX;
	local IMG_PATH_PIN = __ns.core.IMG_PATH_PIN;
	local IMG_LIST = __ns.core.IMG_LIST;

	-- local pinFrameLevel = WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	local wm_wrap = CreateFrame("FRAME", nil, mapCanvas); wm_wrap:SetSize(1, 1); wm_wrap:SetFrameLevel(9999); wm_wrap:SetPoint("CENTER");
	local mm_wrap = CreateFrame("FRAME", nil, Minimap); mm_wrap:SetSize(1, 1); mm_wrap:SetFrameLevel(9999); mm_wrap:SetPoint("CENTER");

	local SET = nil;
-->		MAIN
	-->		--	count
		local __popt = { 0, 0, 0, 0, };
		local function __opt_prompt()
			__ns.__opt_log('map.opt', __popt[1], __popt[2], __popt[3], __popt[4]);
		end
		function __popt:count(index, count)
			__popt[index] = __popt[index] + count;
			if __ns.__dev then __eventHandler:run_on_next_tick(__opt_prompt); end
		end
		function __popt:reset(index)
			__popt[index] = 0;
			if __ns.__dev then __eventHandler:run_on_next_tick(__opt_prompt); end
		end
		function __popt:echo(index)
			return __popt[index];
		end
	-->
	local wm_map = WorldMapFrame:GetMapID();
	local mm_map = C_Map.GetBestMapForUnit('player');
	local map_canvas_scale = mapCanvas:GetScale();
	local pin_size, large_size, varied_size = nil, nil, nil;
	local META_COMMON = {  };				-->		[map] =	{ [uuid] = { 1{ coord }, 2{ pin }, 3nil, 4nil, }, }
	local META_LARGE = {  };				-->		[map] =	{ [uuid] = { 1{ coord }, 2{ pin }, 3nil, 4nil, }, }
	local META_VARIED = {  };				-->		[map] =	{ [uuid] = { 1{ coord }, 2{ pin }, 3nil, 4nil, }, }
	local MM_COMMON_PINS = {  };			-->		[map] = { coord = pin, }
	local MM_LARGE_PINS = {  };				-->		[map] = { coord = pin, }
	local MM_VARIED_PINS = {  };			-->		[map] = { coord = pin, }
	__ns.__map_meta = { META_COMMON, META_LARGE, META_VARIED, };
	local MAP_QUEST_BLOCKED = {  };
	-->		--	Pre-Defined
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
	local SetCommonPinSize, SetLargePinSize, SetVariedPinSize;
	local MapAddCommonNodes, MapDelCommonNodes, MapAddLargeNodes, MapDelLargeNodes, MapAddVariedNodes, MapDelVariedNodes;
	local MapShowQuestNodes, MapHideQuestNodes, MapResetQuestNodesFilter, MapHideNodes, MapDrawNodes;
	-->		--	Pin Handler
		local GameTooltip = GameTooltip;
		local GetFactionInfoByID = GetFactionInfoByID;
		function Pin_OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			local uuid = self.uuid;
			local refs = uuid[4];
			local _type = uuid[1];
			local _id = uuid[2];
			if _type == 'event' then
				GameTooltip:AddLine(__UILOC.TIP_WAYPOINT, 0.0, 1.0, 0.0);
			else
				local _loc = __loc[_type];
				if _loc ~= nil then
					if _type == 'unit' then
						local info = __db_unit[_id];
						if info ~= nil then
							if UnitHelpFac[info.fac] then
								GameTooltip:AddLine(_loc[_id] .. "(" .. _id .. ")", 0.0, 1.0, 0.0);
							else
								local facId = info.facId;
								if facId ~= nil then
									local _, _, standing_rank, _, _, val = GetFactionInfoByID(facId);
									if standing_rank == nil then
										GameTooltip:AddLine(_loc[_id] .. "(" .. _id .. ")", 1.0, 0.0, 0.0);
									elseif standing_rank == 4 then
										GameTooltip:AddLine(_loc[_id] .. "(" .. _id .. ")", 1.0, 1.0, 0.0);
									elseif standing_rank < 4 then
										GameTooltip:AddLine(_loc[_id] .. "(" .. _id .. ")", 1.0, (standing_rank - 1) * 0.25, 0.0);
									else
										GameTooltip:AddLine(_loc[_id] .. "(" .. _id .. ")", 0.5 - (standing_rank - 4) * 0.125, 1.0, 0.0);
									end
								else
									GameTooltip:AddLine(_loc[_id] .. "(" .. _id .. ")", 1.0, 0.0, 0.0);
								end
							end
						end
					else
						GameTooltip:AddLine(_loc[_id] .. "(" .. _id .. ")", 1.0, 1.0, 1.0);
					end
				end
			end
			local uuid = __ns.CoreGetUUID(_type, _id);
			if uuid ~= nil then
				__ns.GameTooltipSetQuestTip(GameTooltip, uuid);
			end
			GameTooltip:Show();
		end
		function Pin_OnClick(self)
			local uuid = self.uuid;
			if uuid ~= nil then
				__ns.RelColor3(uuid[3]);
				uuid[3], uuid[6] = __ns.GetColor3NextIndex(uuid[6]);
				WorldMap_ChangeCommonLargeNodesMapUUID(wm_map, uuid);
				Minimap_ChangeCommonLargeNodesMapUUID(mm_map, uuid);
			end
		end
	-->
	-->		--	WorldMapFrame Pin
		function NewWorldMapPin(__PIN_TAG, pool_inuse, pool_unused, size, Release, frameLevel)
			local pin = next(pool_unused);
			if pin == nil then
				pin = CreateFrame("BUTTON", nil, wm_wrap);
				pin:SetNormalTexture(IMG_PATH_PIN);
				pin:SetScript("OnEnter", Pin_OnEnter);
				pin:SetScript("OnLeave", button_info_OnLeave);
				pin:SetScript("OnClick", Pin_OnClick);
				pin:SetFrameLevel(frameLevel or 9999);
				pin.Release = Release;
				pin.__PIN_TAG = __PIN_TAG;
				pin.__NORMAL_TEXTURE = pin:GetNormalTexture();
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
			local pin = NewWorldMapPin(__const.TAG_WM_COMMON, pool_worldmap_common_pin_inuse, pool_worldmap_common_pin_unused, pin_size, RelWorldMapCommonPin, 9000);
			--		MapCanvasPinMixin:SetPosition(x, y)
			--	>>	MapCanvasMixin:SetPinPosition(pin, x, y)
			--	>>	MapCanvasMixin:ApplyPinPosition(pin, x, y) mainly implemented below
			--	and lots of bullshit about 'nudge'
			local rscale = 0.01 / pin:GetScale();
			pin:SetPoint("CENTER", mapCanvas, "TOPLEFT", mapCanvas:GetWidth() * x * rscale, -mapCanvas:GetHeight() * y * rscale);
			pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
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
			local pin = NewWorldMapPin(__const.TAG_WM_LARGE, pool_worldmap_large_pin_inuse, pool_worldmap_large_pin_unused, large_size, RelWorldMapLargePin, 9001);
			--		MapCanvasPinMixin:SetPosition(x, y)
			--	>>	MapCanvasMixin:SetPinPosition(pin, x, y)
			--	>>	MapCanvasMixin:ApplyPinPosition(pin, x, y) mainly implemented below
			--	and lots of bullshit about 'nudge'
			local rscale = 0.01 / pin:GetScale();
			pin:SetPoint("CENTER", mapCanvas, "TOPLEFT", mapCanvas:GetWidth() * x * rscale, -mapCanvas:GetHeight() * y * rscale);
			pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
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
			local texture = IMG_LIST[TEXTURE] or IMG_LIST[IMG_INDEX.IMG_DEF];
			local pin = NewWorldMapPin(__const.TAG_WM_VARIED, pool_worldmap_varied_pin_inuse, pool_worldmap_varied_pin_unused, varied_size, RelWorldMapVariedPin, texture[5]);
			pin:SetFrameLevel(texture[5]);
			--		MapCanvasPinMixin:SetPosition(x, y)
			--	>>	MapCanvasMixin:SetPinPosition(pin, x, y)
			--	>>	MapCanvasMixin:ApplyPinPosition(pin, x, y) mainly implemented below
			--	and lots of bullshit about 'nudge'
			local rscale = 0.01 / pin:GetScale();
			pin:SetPoint("CENTER", mapCanvas, "TOPLEFT", mapCanvas:GetWidth() * x * rscale, -mapCanvas:GetHeight() * y * rscale);
			pin:SetNormalTexture(texture[1]);
			pin.__NORMAL_TEXTURE:SetVertexColor(texture[2] or color3[1] or 1.0, texture[3] or color3[2] or 1.0, texture[4] or color3[3] or 1.0);
			-- if color3 ~= nil then
			-- 	pin.__NORMAL_TEXTURE:SetVertexColor(color3[1] or 1.0, color3[2] or 1.0, color3[3] or 1.0);
			-- else
			-- 	pin.__NORMAL_TEXTURE:SetVertexColor(texture[2] or 1.0, texture[3] or 1.0, texture[4] or 1.0);
			-- end
			pin:Show();
			return pin;
		end
		--
		function IterateWorldMapPinSetSize()
			for pin, _ in next, pool_worldmap_common_pin_inuse do
				pin:SetSize(pin_size, pin_size);
			end
			for pin, _ in next, pool_worldmap_large_pin_inuse do
				pin:SetSize(large_size, large_size);
			end
			for pin, _ in next, pool_worldmap_varied_pin_inuse do
				pin:SetSize(varied_size, varied_size);
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
							pins[index].__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
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
							pins[index].__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
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
						local texture = IMG_LIST[TEXTURE] or IMG_LIST[IMG_INDEX.IMG_DEF];
						pin:SetNormalTexture(texture[1]);
						pin.__NORMAL_TEXTURE:SetVertexColor(texture[2], texture[3], texture[4]);
						pin:SetFrameLevel(texture[5]);
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
								local val = coords[index];
								local pin = AddWorldMapCommonPin(val[1], val[2], color3);
								pins[index] = pin;
								pin.uuid = uuid;
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
								local val = coords[index];
								local pin = AddWorldMapLargePin(val[1], val[2], color3);
								pins[index] = pin;
								pin.uuid = uuid;
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
								local val = coords[index];
								local pin = AddWorldMapVariedPin(val[1], val[2], color3, TEXTURE);
								pins[index] = pin;
								pin.uuid = uuid;
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
					local blocked = true;
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
							blocked = false;
							break;
						end
					end
					if blocked then
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
					local blocked = true;
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
							blocked = false;
							break;
						end
					end
					if blocked then
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
					local blocked = true;
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
							blocked = false;
							break;
						end
					end
					if blocked then
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
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
							local coords = data[1];
							local pins = data[2];
							local color3 = uuid[3];
							local num_coords = #coords;
							local num_pins = #pins;
							if num_pins < num_coords then
								for index = num_pins + 1, num_coords do
									local val = coords[index];
									local pin = AddWorldMapCommonPin(val[1], val[2], color3);
									pins[index] = pin;
									pin.uuid = uuid;
								end
								__popt:count(1, num_coords - num_pins);
							end
							break;
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
							local coords = data[1];
							local pins = data[2];
							local color3 = uuid[3];
							local num_coords = #coords;
							local num_pins = #pins;
							if num_pins < num_coords then
								for index = num_pins + 1, num_coords do
									local val = coords[index];
									local pin = AddWorldMapLargePin(val[1], val[2], color3);
									pins[index] = pin;
									pin.uuid = uuid;
								end
								__popt:count(2, num_coords - num_pins);
							end
							break;
						end
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
							local coords = data[1];
							local pins = data[2];
							local color3 = uuid[3];
							local TEXTURE = uuid[5];
							local num_coords = #coords;
							local num_pins = #pins;
							if num_pins < num_coords then
								for index = num_pins + 1, num_coords do
									local val = coords[index];
									local pin = AddWorldMapVariedPin(val[1], val[2], color3, TEXTURE);
									pins[index] = pin;
									pin.uuid = uuid;
								end
								__popt:count(3, num_coords - num_pins);
							end
							break;
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
				pin = CreateFrame("BUTTON", nil, mm_wrap);
				pin:SetNormalTexture(IMG_PATH_PIN);
				pin:SetScript("OnEnter", Pin_OnEnter);
				pin:SetScript("OnLeave", button_info_OnLeave);
				pin:SetScript("OnClick", Pin_OnClick);
				pin.Release = Release;
				pin.__PIN_TAG = __PIN_TAG;
				pin.__NORMAL_TEXTURE = pin:GetNormalTexture();
			else
				pool_unused[pin] = nil;
			end
			pin:SetSize(size, size);
			pin:SetFrameLevel(frameLevel or 9999);
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
			pin:SetNormalTexture(img);
			pin.__NORMAL_TEXTURE:SetVertexColor(r, g, b);
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
			local GetCVar = GetCVar;
			local UnitPosition = UnitPosition;
			local GetPlayerFacing = GetPlayerFacing;
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
			local mm_player_y, mm_player_x = UnitPosition('player');
			if mm_player_y == nil then mm_player_y = 0.0; end
			if mm_player_x == nil then mm_player_x = 0.0; end
			local mm_dynamic_update_interval = 0.05;
		--
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
							pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
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
							pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
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
						local texture = IMG_LIST[TEXTURE] or IMG_LIST[IMG_INDEX.IMG_DEF];
						local pin = MM_VARIED_PINS[coord];
						if pin ~= nil then
							pin:SetNormalTexture(texture[1]);
							pin.__NORMAL_TEXTURE:SetVertexColor(texture[2], texture[3], texture[4]);
							pin:SetFrameLevel(texture[5]);
						end
					end
				end
			end
		end
		function Minimap_ShowNodesMapQuest(map, quest)
			__ns._F_devDebugProfileStart('module.map.Minimap_DrawNodesMap');
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
									pin = AddMinimapPin(__const.TAG_MM_COMMON, IMG_PATH_PIN, color3[1], color3[2], color3[3], SET.pin_size, 9000);
									MM_COMMON_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin:SetNormalTexture(IMG_PATH_PIN);
									pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
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
									pin = AddMinimapPin(__const.TAG_MM_LARGE, IMG_PATH_PIN, color3[1], color3[2], color3[3], SET.large_size, 9001);
									MM_LARGE_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin:SetNormalTexture(IMG_PATH_PIN);
									pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
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
								local texture = IMG_LIST[TEXTURE] or IMG_LIST[IMG_INDEX.IMG_DEF];
								if pin == nil then
									pin = AddMinimapPin(__const.TAG_MM_VARIED, texture[1], texture[2] or color3[1], texture[3] or color3[2], texture[4] or color3[3], SET.pin_size, texture[5]);
									MM_VARIED_PINS[coord] = pin;
									num_changed = num_changed + 1;
								else
									pin:SetNormalTexture(texture[1]);
									pin.__NORMAL_TEXTURE:SetVertexColor(texture[2], texture[3], texture[4]);
								end
								pin:ClearAllPoints();
								if mm_is_rotate then
									dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
								end
								pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
								--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
								pin.uuid = uuid;
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
			local cost = __ns._F_devDebugProfileTick('module.map.Minimap_DrawNodesMap');
			mm_dynamic_update_interval = cost * 0.2;
			--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.map.Minimap_DrawNodesMap', mm_dynamic_update_interval); end
		end
		function Minimap_HideNodesQuest(quest)
			local num_pins = 0;
			for coord, pin in next, MM_COMMON_PINS do
				local blocked = true;
				for quest, refs in next, pin.uuid[4] do
					if MAP_QUEST_BLOCKED[quest] ~= true then
						blocked = false;
						break;
					end
				end
				if blocked then
					pin:Release();
					MM_COMMON_PINS[coord] = nil;
					num_pins = num_pins - 1;
				end
			end
			for coord, pin in next, MM_LARGE_PINS do
				for quest, refs in next, pin.uuid[4] do
					if MAP_QUEST_BLOCKED[quest] ~= true then
						blocked = false;
						break;
					end
				end
				if blocked then
					pin:Release();
					MM_LARGE_PINS[coord] = nil;
					num_pins = num_pins - 1;
				end
			end
			for coord, pin in next, MM_VARIED_PINS do
				for quest, refs in next, pin.uuid[4] do
					if MAP_QUEST_BLOCKED[quest] ~= true then
						blocked = false;
						break;
					end
				end
				if blocked then
					pin:Release();
					MM_VARIED_PINS[coord] = nil;
					num_pins = num_pins - 1;
				end
			end
			__popt:count(4, num_pins);
		end
		function Minimap_DrawNodesMap(map)
			__ns._F_devDebugProfileStart('module.map.Minimap_DrawNodesMap');
			local num_changed = 0;
			local meta = META_COMMON[map];
			if meta ~= nil then
				for uuid, data in next, meta do
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
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
										pin = AddMinimapPin(__const.TAG_MM_COMMON, IMG_PATH_PIN, color3[1], color3[2], color3[3], SET.pin_size, 9000);
										MM_COMMON_PINS[coord] = pin;
										num_changed = num_changed + 1;
									else
										pin:SetNormalTexture(IMG_PATH_PIN);
										pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
									end
									pin:ClearAllPoints();
									if mm_is_rotate then
										dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
									end
									pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
									--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
									pin.uuid = uuid;
								else
									local pin = MM_COMMON_PINS[coord];
									if pin ~= nil then
										pin:Release();
										MM_COMMON_PINS[coord] = nil;
										num_changed = num_changed - 1;
									end
								end
							end
							break;
						end
					end
				end
			end
			local large = META_LARGE[map];
			if large ~= nil then
				for uuid, data in next, large do
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
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
										pin = AddMinimapPin(__const.TAG_MM_LARGE, IMG_PATH_PIN, color3[1], color3[2], color3[3], SET.large_size, 9001);
										MM_LARGE_PINS[coord] = pin;
										num_changed = num_changed + 1;
									else
										pin:SetNormalTexture(IMG_PATH_PIN);
										pin.__NORMAL_TEXTURE:SetVertexColor(color3[1], color3[2], color3[3]);
									end
									pin:ClearAllPoints();
									if mm_is_rotate then
										dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
									end
									pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
									--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
									pin.uuid = uuid;
								else
									local pin = MM_LARGE_PINS[coord];
									if pin ~= nil then
										pin:Release();
										MM_LARGE_PINS[coord] = nil;
										num_changed = num_changed - 1;
									end
								end
							end
							break;
						end
					end
				end
			end
			local varied = META_VARIED[map];
			if varied ~= nil then
				for uuid, data in next, varied do
					for quest, refs in next, uuid[4] do
						if MAP_QUEST_BLOCKED[quest] ~= true then
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
									local texture = IMG_LIST[TEXTURE] or IMG_LIST[IMG_INDEX.IMG_DEF];
									if pin == nil then
										pin = AddMinimapPin(__const.TAG_MM_VARIED, texture[1], texture[2] or color3[1], texture[3] or color3[2], texture[4] or color3[3], SET.pin_size, texture[5]);
										MM_VARIED_PINS[coord] = pin;
										num_changed = num_changed + 1;
									else
										pin:SetNormalTexture(texture[1]);
										pin.__NORMAL_TEXTURE:SetVertexColor(texture[2], texture[3], texture[4]);
									end
									pin:ClearAllPoints();
									if mm_is_rotate then
										dx, dy = dx * mm_rotate_sin - dy * mm_rotate_cos, dx * mm_rotate_cos + dy * mm_rotate_sin;
									end
									pin:SetPoint("CENTER", Minimap, "CENTER", - mm_hwidth * dx / mm_hsize, mm_hheight * dy / mm_hsize);
									--	transform from world-coord[bottomleft->topright] to UI-coord[bottomleft->topright]
									pin.uuid = uuid;
								else
									local pin = MM_VARIED_PINS[coord];
									if pin ~= nil then
										pin:Release();
										MM_VARIED_PINS[coord] = nil;
										num_changed = num_changed - 1;
									end
								end
							end
							break;
						end
					end
				end
			end
			if num_changed ~= 0 then
				__popt:count(4, num_changed);
			end
			local cost = __ns._F_devDebugProfileTick('module.map.Minimap_DrawNodesMap');
			mm_dynamic_update_interval = cost * 0.2;
			--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.map.Minimap_DrawNodesMap', mm_dynamic_update_interval); end
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
			local now = GetTime();
			if __mm_prev_update + mm_dynamic_update_interval <= now then
				local map = mm_map;
				if map ~= nil then
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
					if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
						Minimap:SetZoom(zoom < 2 and zoom + 1 or zoom - 1);
					end
					local indoor = GetCVar("minimapZoom") + 0 == Minimap:GetZoom() and "outdoor" or "indoor";
					Minimap:SetZoom(zoom);
					local facing = GetPlayerFacing();
					if facing ~= nil then
						local is_rotate = GetCVar("rotateMinimap") == "1";
						local y, x = UnitPosition('player');
						if mm_force_update or (mm_player_x ~= x or mm_player_y ~= y or zoom ~= mm_zoom or indoor ~= mm_indoor or ((mm_is_rotate and facing ~= mm_rotate) or mm_is_rotate ~= is_rotate)) then
							mm_player_x = x;
							mm_player_y = y;
							mm_indoor = indoor;
							mm_zoom = zoom;
							mm_is_rotate = is_rotate;
							mm_rotate = facing;
							mm_rotate_sin = _radius_sin(facing);
							mm_rotate_cos = _radius_cos(facing);
							mm_hsize = minimap_size[indoor][zoom] * 0.5;
							mm_hheight = Minimap:GetHeight() * 0.5;
							mm_hwidth = Minimap:GetWidth() * 0.5;
							Minimap_DrawNodesMap(map);
							mm_force_update = false;
						end
						__mm_prev_update = now;
					end
				end
			end
		end
		function __ns.MINIMAP_UPDATE_ZOOM()
			-- __eventHandler:run_on_next_tick(Minimap_DrawNodes);
			-- _log_('MINIMAP_UPDATE_ZOOM', GetCVar("minimapZoom") + 0 == Minimap:GetZoom(), GetCVar("minimapZoom") == Minimap:GetZoom(), GetCVar("minimapZoom"), Minimap:GetZoom())
		end
	-->
	-->		--	interface
		--	set pin
		function SetCommonPinSize()
			--	pool_worldmap_common_pin_inuse, pool_worldmap_common_pin_unused, MM_COMMON_PINS
			pin_size = SET.pin_size;
			for _, pin in next, MM_COMMON_PINS do
				pin:SetSize(pin_size, pin_size);
			end
			local scale = map_canvas_scale;
			local pin_scale_max = SET.pin_scale_max;
			if scale > pin_scale_max then
				pin_size = pin_size * pin_scale_max / scale;
			end
			for pin, _ in next, pool_worldmap_common_pin_inuse do
				pin:SetSize(pin_size, pin_size);
			end
		end
		function SetLargePinSize()
			--	pool_worldmap_large_pin_inuse, pool_worldmap_large_pin_unused, MM_LARGE_PINS
			large_size = SET.large_size;
			for _, pin in next, MM_LARGE_PINS do
				pin:SetSize(large_size, large_size);
			end
			local scale = map_canvas_scale;
			local pin_scale_max = SET.pin_scale_max;
			if scale > pin_scale_max then
				large_size = large_size * pin_scale_max / scale;
			end
			for pin, _ in next, pool_worldmap_large_pin_inuse do
				pin:SetSize(large_size, large_size);
			end
		end
		function SetVariedPinSize()
			--	pool_worldmap_varied_pin_inuse, pool_worldmap_varied_pin_unused, MM_VARIED_PINS
			varied_size = SET.varied_size;
			for _, pin in next, MM_VARIED_PINS do
				pin:SetSize(varied_size, varied_size);
			end
			local scale = map_canvas_scale;
			local pin_scale_max = SET.pin_scale_max;
			if scale > pin_scale_max then
				varied_size = varied_size * pin_scale_max / scale;
			end
			for pin, _ in next, pool_worldmap_varied_pin_inuse do
				pin:SetSize(varied_size, varied_size);
			end
		end
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
				WorldMap_ChangeVariedNodesMapUUID(wm_map, uuid);
				Minimap_ChangeVariedNodesMapUUID(mm_map, uuid);
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
		--
		function MapShowQuestNodes(quest)
			if MAP_QUEST_BLOCKED[quest] == true then
				MAP_QUEST_BLOCKED[quest] = nil;
				WorldMap_ShowNodesQuest(wm_map, quest);
				Minimap_ShowNodesMapQuest(mm_map, quest);
			end
		end
		function MapHideQuestNodes(quest)
			if MAP_QUEST_BLOCKED[quest] ~= true then
				MAP_QUEST_BLOCKED[quest] = true;
				WorldMap_HideNodesQuest(wm_map, quest);
				Minimap_HideNodesQuest(quest);
			end
		end
		function MapResetQuestNodesFilter()
			wipe(MAP_QUEST_BLOCKED);
			MapDrawNodes();
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
	-->		--	extern method
		--
		__ns.SetCommonPinSize = SetCommonPinSize;
		__ns.SetLargePinSize = SetLargePinSize;
		__ns.SetVariedPinSize = SetVariedPinSize;
		--
		__ns.MapAddCommonNodes = MapAddCommonNodes;
		__ns.MapDelCommonNodes = MapDelCommonNodes;
		__ns.MapAddLargeNodes = MapAddLargeNodes;
		__ns.MapDelLargeNodes = MapDelLargeNodes;
		__ns.MapAddVariedNodes = MapAddVariedNodes;
		__ns.MapDelVariedNodes = MapDelVariedNodes;
		__ns.MapShowQuestNodes = MapShowQuestNodes;
		__ns.MapHideQuestNodes = MapHideQuestNodes;
		__ns.MapResetQuestNodesFilter = MapResetQuestNodesFilter;
		--
		__ns.MapDrawNodes = MapDrawNodes;
		__ns.MapHideNodes = MapHideNodes;
		__ns.Pin_OnEnter = Pin_OnEnter;
		--
		function __ns.map_reset()
			wipe(META_COMMON);
			wipe(META_LARGE);
			wipe(META_VARIED);
			ResetWMPin();
			wipe(MM_COMMON_PINS);
			wipe(MM_LARGE_PINS);
			wipe(MM_VARIED_PINS);
			ResetMMPin();
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
				--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.map.mapCallback:OnMapChanged'); end
				local uiMapID = WorldMapFrame:GetMapID();
				if uiMapID ~= wm_map then
					WorldMap_HideNodesMap(wm_map);
					wm_map = uiMapID;
					WorldMap_DrawNodesMap(uiMapID);
				end
				--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.map.mapCallback:OnMapChanged'); end
			end
			function mapCallback:OnCanvasScaleChanged()
				local scale = mapCanvas:GetScale();
				if map_canvas_scale ~= scale then
					--[=[dev]=]	if __ns.__dev then __ns._F_devDebugProfileStart('module.map.mapCallback:OnCanvasScaleChanged'); end
					map_canvas_scale = scale;
					local pin_scale_max = SET.pin_scale_max;
					--
					pin_size = SET.pin_size;
					if scale > pin_scale_max then
						pin_size = pin_size * pin_scale_max / scale;
					end
					--
					large_size = SET.large_size;
					if scale > pin_scale_max then
						large_size = large_size * pin_scale_max / scale;
					end
					--
					varied_size = SET.varied_size;
					if scale > pin_scale_max then
						varied_size = varied_size * pin_scale_max / scale;
					end
					IterateWorldMapPinSetSize();
					--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.map.mapCallback:OnCanvasScaleChanged'); end
				end
			end
			function mapCallback:OnCanvasSizeChanged()
			end
		-->
		function __ns.__PLAYER_ZONE_CHANGED(map)
			mm_map = map;
			Minimap_HideNodes();
			Minimap_DrawNodesMap(map);
		end
	-->
	function __ns.map_setup()
		SET = __ns.__setting;
		MAP_QUEST_BLOCKED = __ns.__mapquestblocked;
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
		-- 		_log_("rehash map");
		-- 		break;
		-- 	end
		-- end
		-- __ns.HDB = HDB;
		-- __ns.mapData = mapData;
		-- function __ns.GetWorldCoordinatesFromZone(zone, x, y)
		-- 	local data = mapData[zone];
		-- 	if data then
		-- 		x, y = data[3] - data[1] * x, data[4] - data[2] * y;
		-- 		return x, y, data.instance;
		-- 	end
		-- end
		WorldMapFrame:AddDataProvider(mapCallback);
		wm_map = -1;
		mapCallback:OnMapChanged();
		__eventHandler:RegEvent("MINIMAP_UPDATE_ZOOM");
		Minimap:HookScript("OnUpdate", Minimap_OnUpdate);
		--
		local pin_scale_max = SET.pin_scale_max;
		pin_size = SET.pin_size;
		if map_canvas_scale > pin_scale_max then
			pin_size = pin_size * pin_scale_max / map_canvas_scale;
		end
		large_size = SET.large_size;
		if map_canvas_scale > pin_scale_max then
			large_size = large_size * pin_scale_max / map_canvas_scale;
		end
		varied_size = SET.varied_size;
		if map_canvas_scale > pin_scale_max then
			varied_size = varied_size * pin_scale_max / map_canvas_scale;
		end
	end
-->

-->		dev
-->

--[=[dev]=]	if __ns.__dev then __ns.__performance_log_tick('module.map'); end
