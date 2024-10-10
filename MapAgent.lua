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
	local next = next;
	local ipairs = ipairs;
	local tremove = table.remove;
	local UnitPosition = UnitPosition;
	local CreateVector2D = CreateVector2D;
	local C_Map = C_Map;
	local GetBestMapForUnit = C_Map.GetBestMapForUnit;
	local GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos;
	local GetMapChildrenInfo = C_Map.GetMapChildrenInfo;
	local GetMapGroupID = C_Map.GetMapGroupID;
	local GetMapGroupMembersInfo = C_Map.GetMapGroupMembersInfo;
	local GetMapInfo = C_Map.GetMapInfo;
	local GetMapInfoAtPosition = C_Map.GetMapInfoAtPosition;
	local CreateFrame = CreateFrame;
	local _G = _G;
	local MapTypeDungeon = Enum.UIMapType.Dungeon;

-->
-->		constant
	local WORLD_MAP_ID = C_Map.GetFallbackWorldMapID() or 947;		--	947
	CT.ContinentMapID = {
		[946] = "Universe",
		[947] = "Azeroth",
		[1414] = "Kalimdor",
		[1415] = "Eastern Kingdoms",
		[1945] = "Outland",
	};

-->
-- MT.BuildEnv('MapAgent');
-->		predef
-->
	VT.PlayerMapID = GetBestMapForUnit('player');

-->

-->		Map			--	坐标系转换方法，参考自HandyNotes	--	C_Map效率非常低，可能因为构建太多Mixin(CreateVector2D)
	--
	--[[
		mapType
			0 = COSMIS
			1 = WORLD
			2 = CONTINENT
			3 = ZONE
			4 = DUNGEON
			5 = MICRO
			6 = ORPHAN
	]]
	--
	local mapMeta = {  };		--	[map] = { 1width, 2height, 3left, 4top, [instance], [name], [mapType], [parent], [children], [adjoined], }
	local transformData = nil;	--	from HBD
	local worldMapData = nil;	--	[instance] = { 1width, 2height, 3left, 4top, }
	local FixedMapType = nil;
	if CT.TOCVERSION < 20000 then
		transformData = {  };
		worldMapData = {		--	[instance] = { 1width, 2height, 3left, 4top, }
			[0] = { 44688.53, 29795.11, 32601.04, 9894.93 },	--	Eastern Kingdoms
			[1] = { 44878.66, 29916.10, 8723.96, 14824.53 },	--	Kalimdor
		};
		FixedMapType = {  };
	elseif CT.TOCVERSION < 30000 then
		transformData = {
			{ 530, 0, 4800, 16000, -10133.3, -2666.67, -2400, 2662.8 },
			{ 530, 1, -6933.33, 533.33, -16000, -8000, 10339.7, 17600 },
		};
		worldMapData = {		--	[instance] = { 1width, 2height, 3left, 4top, }
			[0] = { 44688.53, 29791.24, 32681.47, 11479.44 },	--	Eastern Kingdoms
			[1] = { 44878.66, 29916.10,  8723.96, 14824.53 },	--	Kalimdor
		};
		FixedMapType = {  };
	elseif CT.TOCVERSION < 40000 then
		transformData = {
			{ 530, 0, 4800, 16000, -10133.3, -2666.67, -2400, 2662.8 },
			{ 530, 1, -6933.33, 533.33, -16000, -8000, 10339.7, 17600 },
			{ 609, 0, -10000, 10000, -10000, 10000, 0, 0 },
		};
		worldMapData = {		--	[instance] = { 1width, 2height, 3left, 4top, }
			[0] = { 48033.24, 32020.8, 36867.97, 14848.84 },	--	Eastern Kingdoms
			[1] = { 47908.72, 31935.28, 8552.61, 18467.83 },	--	Kalimdor
			[571] = { 47662.7, 31772.19, 25198.53, 11072.07 },
		};
		FixedMapType = {
			[124] = 3,	--	origin:6	--	东瘟疫之地：血色领地
			[125] = 3,	--	origin:4	--	达拉然
			[126] = 3,	--	origin:4	--	达拉然下水道
			[128] = 3,	--	origin:6	--	远古海滩
			[142] = 4,	--	origin:6	--	魔环
			[153] = 4,	--	origin:6	--	古达克
			[155] = 4,	--	origin:6	--	黑曜石圣殿
			[169] = 3,	--	origin:6	--	征服之岛
			[184] = 4,	--	origin:6	--	萨隆矿坑
			[200] = 4,	--	origin:6	--	红玉圣殿
			[219] = 4,	--	origin:6	--	祖尔法拉克
			[233] = 4,	--	origin:6	--	祖尔格拉布
			[234] = 4,	--	origin:6	--	厄运之槌
			[247] = 4,	--	origin:6	--	安其拉废墟
			[273] = 4,	--	origin:6	--	黑色沼泽
			[274] = 4,	--	origin:6	--	旧希尔斯布莱德丘陵
			[329] = 4,	--	origin:6	--	海加尔峰
			[333] = 4,	--	origin:6	--	祖阿曼
			[337] = 4,	--	origin:6	--	祖尔格拉布
		};
	else
		transformData = {
			{ 530, 1, -6933.33, 533.33, -16000, -8000, 9916, 17600 },
			{ 530, 0, 4800, 16000, -10133.3, -2666.67, -2400, 2400 },
			{ 732, 0, -3200, 533.3, -533.3, 2666.7, -611.8, 3904.3 },
			{ 1064, 870, 5391, 8148, 3518, 7655, -2134.2, -2286.6 },
			{ 1208, 1116, -2666, -2133, -2133, -1600, 10210.7, 2411.4 },
			{ 1460, 1220, -1066.7, 2133.3, 0, 3200, -2333.9, 966.7 },
			{ 1599, 1, 4800, 5866.7, -4266.7, -3200, -490.6, -0.4 },
			{ 1609, 571, 6400, 8533.3, -1600, 533.3, 512.8, 545.3 },
		};
		worldMapData = {  };
		FixedMapType = {  };
	end
	local TransformMeta = {  };
	for _, transform in next, transformData do
		local instance = transform[1];
		local meta = TransformMeta[instance]
		if TransformMeta[instance] == nil then
			meta = {
				{
					newInstanceID = transform[2],
					minY = transform[3],
					maxY = transform[4],
					minX = transform[5],
					maxX = transform[6],
					offsetY = transform[7],
					offsetX = transform[8],
				},
			};
			TransformMeta[instance] = meta;
		else
			meta[#meta + 1] = {
				newInstanceID = transform[2],
				minY = transform[3],
				maxY = transform[4],
				minX = transform[5],
				maxX = transform[6],
				offsetY = transform[7],
				offsetX = transform[8],
			};
		end
	end
	local function TransformCoord(instance, x, y)
		if TransformMeta[instance] then
			for _, data in ipairs(TransformMeta[instance]) do
				if x <= data.maxX and x >= data.minX and y <= data.maxY and y >= data.minY then
					instance = data.newInstanceID;
					x = x + data.offsetX;
					y = y + data.offsetY;
					break;
				end
			end
		end
		return instance, x, y;
	end
	local function TransformScope(instance, left, right, top, bottom)
		if TransformMeta[instance] then
			for _, data in ipairs(TransformMeta[instance]) do
				if left <= data.maxX and right >= data.minX and top <= data.maxY and bottom >= data.minY then
					instance = data.newInstanceID;
					left   = left   + data.offsetX;
					right  = right  + data.offsetX;
					top    = top    + data.offsetY;
					bottom = bottom + data.offsetY;
					break;
				end
			end
		end
		return instance, left, right, top, bottom;
	end
	--	return map, x, y
	function MT.GetUnitPosition(unit)
		local y, x, _z, map = UnitPosition(unit);
		return TransformCoord(map, x, y);
		-- return map, y, x;
	end
	--	return map, x, y	-->	bound to [0.0, 1.0]
	function MT.GetZonePositionFromWorldPosition(map, x, y)
		local data = mapMeta[map];
		if data ~= nil and data[2] ~= 0 then
			x, y = (data[3] - x) / data[1], (data[4] - y) / data[2];
			if x <= 1.0 and x >= 0.0 and y <= 1.0 and y >= 0.0 then
				return map, x, y;
			end
		end
		return nil, nil, nil;
	end
	--	return instance, x[0.0, 1.0], y[0.0, 1.0]
	function MT.GetWorldPositionFromZonePosition(map, x, y)
		local data = mapMeta[map];
		if data ~= nil then
			x, y = data[3] - data[1] * x, data[4] - data[2] * y;
			return data.instance, x, y;
		end
		return nil, nil, nil;
	end
	--	return instance, x, y
	function MT.GetWorldPositionFromAzerothWorldMapPosition(instance, x, y)
		local data = worldMapData[instance]
		if data ~= nil then
			x, y = data[3] - data[1] * x, data[4] - data[2] * y;
			return instance, x, y;
		end
		return nil, nil, nil;
	end
	--	return instance, x, y
	function MT.GetAzerothWorldMapPositionFromWorldPosition(instance, x, y)
		local data = worldMapData[instance]
		if data ~= nil then
			x, y = (data[3] - x) / data[1], (data[4] - y) / data[2];
			if x <= 1.0 and x >= 0.0 and y <= 1.0 and y >= 0.0 then
				return instance, x, y;
			end
		end
		return nil, nil, nil;
	end

	--	return map, x, y
	function MT.GetUnitZonePosition(unit)
		-- local y, x, _z, map = UnitPosition(unit);
		local map, x, y = MT.GetUnitPosition(unit);
		if x ~= nil and y ~= nil then
			return MT.GetZonePositionFromWorldPosition(GetBestMapForUnit(unit), x, y);
		end
	end
	function MT.GetPlayerZone()
		return VT.PlayerMapID;
	end
	--	return map, x, y
	function MT.GetPlayerZonePosition()
		-- local y, x, _z, map = UnitPosition('player');
		local map, x, y = MT.GetUnitPosition('player');
		if x ~= nil and y ~= nil then
			return MT.GetZonePositionFromWorldPosition(VT.PlayerMapID, x, y);
		end
	end

	function MT.GetAllMapMetas()
		return mapMeta;
	end
	function MT.GetMapMeta(map)
		return mapMeta[map];
	end
	function MT.GetMapParent(map)
		local meta = mapMeta[map];
		if meta ~= nil then
			return meta.parent;
		end
	end
	function MT.GetMapAdjoined(map)
		local meta = mapMeta[map];
		if meta ~= nil then
			return meta.adjoined;
		end
	end
	function MT.GetMapChildren(map)
		local meta = mapMeta[map];
		if meta ~= nil then
			return meta.children;
		end
	end
	function MT.GetMapContinent(map)
		local meta = mapMeta[map];
		if meta ~= nil then
			return meta.continent;
		end
	end

	--
	local function PreloadCoordsFunc(coords, wcoords)
		local num_coords = #coords;
		local index = 1;
		while index <= num_coords do
			local coord = coords[index];
			if coord[1] >= 0 or coord[2] >= 0 then
				local instance, x, y = MT.GetWorldPositionFromZonePosition(coord[3], coord[1] * 0.01, coord[2] * 0.01);
				-- local instance, v = GetWorldPosFromMapPos(coord[3], CreateVector2D(coord[1], coord[2]));	--	VERY SLOW, 90ms vs 1200ms
				-- coord[5] = x;
				-- coord[6] = y;
				-- coord[7] = instance;
				if x ~= nil and y ~= nil and instance ~= nil then
					local wcoord = { x, y, instance, coord[4], };
					wcoords[index] = wcoord;
					coord[5] = wcoord;
					index = index + 1;
				else
					tremove(coords, index);
					num_coords = num_coords - 1;
				end
			else
				tremove(coords, index);
				num_coords = num_coords - 1;
			end
		end
		local pos = num_coords + 1;
		for index = 1, num_coords do
			local coord = coords[index];
			local wcoord = wcoords[index];
			local map = coord[3];
			local amaps = MT.GetMapAdjoined(map);
			if amaps ~= nil then
				for amap, _ in next, amaps do
					local amap, x, y = MT.GetZonePositionFromWorldPosition(amap, wcoord[1], wcoord[2]);
					if amap ~= nil then
						coords[pos] = { x * 100.0, y * 100.0, amap, coord[4], wcoord, };
						pos = pos + 1;
					end
				end
			end
			local cmaps = MT.GetMapChildren(map);
			if cmaps ~= nil then
				for cmap, _ in next, cmaps do
					local cmap, x, y = MT.GetZonePositionFromWorldPosition(cmap, wcoord[1], wcoord[2]);
					if cmap ~= nil then
						coords[pos] = { x * 100.0, y * 100.0, cmap, coord[4], wcoord, };
						pos = pos + 1;
					end
				end
			end
			-- local pmap = MT.GetMapParent(map);
			-- if pmap ~= nil then
			-- 	local pmap, x, y = MT.GetZonePositionFromWorldPosition(pmap, wcoord[1], wcoord[2]);
			-- 	if pmap ~= nil then
			-- 		coords[pos] = { x * 100.0, y * 100.0, pmap, coord[4], wcoord, };
			-- 		pos = pos + 1;
			-- 	end
			-- end
			local cmap = MT.GetMapContinent(map);
			if cmap ~= nil then
				local cmap, x, y = MT.GetZonePositionFromWorldPosition(cmap, wcoord[1], wcoord[2]);
				if cmap ~= nil then
					coords[pos] = { x * 100.0, y * 100.0, cmap, coord[4], wcoord, };
					pos = pos + 1;
				end
			end
		end
	end
	function MT.PreloadCoords(info)
		local coords = info.coords;
		local wcoords = info.wcoords;
		if coords ~= nil and wcoords == nil then
			wcoords = {  };
			info.wcoords = wcoords;
			PreloadCoordsFunc(coords, wcoords);
		end
		local waypoints = info.waypoints;
		local wwaypoints = info.wwaypoints;
		if waypoints ~= nil and wwaypoints == nil then
			wwaypoints = {  };
			info.wwaypoints = wwaypoints;
			PreloadCoordsFunc(waypoints, wwaypoints);
		end
	end

	MT.RegisterOnLogin("MapAgent", function(LoggedIn)
		local mapHandler = CreateFrame('FRAME');
		mapHandler:SetScript("OnEvent", function(self, event)
			local map = GetBestMapForUnit('player');
			if VT.PlayerMapID ~= map then
				VT.PlayerMapID = map;
				MT.FireEvent("__PLAYER_ZONE_CHANGED", map);
			end
		end);
		mapHandler:UnregisterAllEvents();
		mapHandler:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		mapHandler:RegisterEvent("ZONE_CHANGED");
		mapHandler:RegisterEvent("ZONE_CHANGED_INDOORS");
		mapHandler:RegisterEvent("NEW_WMO_CHUNK");
		mapHandler:RegisterEvent("PLAYER_ENTERING_WORLD");
		--	地图坐标系【右手系，右下为0】(x, y, z) >> 地图坐标系【左手系,左上为0】(-y, -x, z)
		local vector0000 = CreateVector2D(0, 0);
		local vector0505 = CreateVector2D(0.5, 0.5);
		local processMap = nil;
		processMap = function(map)
			local meta = mapMeta[map];
			if meta == nil then
				local data = GetMapInfo(map);
				if data ~= nil then
					local mapType = FixedMapType[map] or data.mapType;
					if mapType ~= MapTypeDungeon then
						--	get two positions from the map, we use 0/0 and 0.5/0.5 to avoid issues on some maps where 1/1 is translated inaccurately
						local instance, x00y00 = GetWorldPosFromMapPos(map, vector0000);
						local _, x05y05 = GetWorldPosFromMapPos(map, vector0505);
						if x00y00 ~= nil and x05y05 ~= nil then
							local top, left = x00y00:GetXY();
							local bottom, right = x05y05:GetXY();
							bottom = top + (bottom - top) * 2;
							right = left + (right - left) * 2;
							instance, left, right, top, bottom = TransformScope(instance, left, right, top, bottom);
							meta = { left - right, top - bottom, left, top, instance = instance,       name = data.name, mapType = mapType, };
							mapMeta[map] = meta;
						else
							meta = { 0, 0, 0, 0,                            instance = instance or -1, name = data.name, mapType = mapType, };
							mapMeta[map] = meta;
						end
						local pmap = data.parentMapID;
						if pmap ~= nil then
							local pmeta = processMap(pmap);
							if pmeta ~= nil then
								meta.parent = pmap;
								local cmaps = pmeta.children;
								if cmaps == nil then
									cmaps = {  };
									pmeta.children = cmaps;
								end
								cmaps[map] = 1;
							end
						end
						local children = GetMapChildrenInfo(map);
						if children ~= nil and children[1] ~= nil then
							for index = 1, #children do
								local cmap = children[index].mapID;
								if cmap ~= nil then
									local cmeta = processMap(cmap);
									if cmeta ~= nil then
										local cmaps = meta.children;
										if cmaps == nil then
											cmaps = {  };
											meta.children = cmaps;
										end
										cmaps[cmap] = 1;
										cmeta.parent = map;
									end
								end
							end
						end
						--	process sibling maps (in the same group)
						--	in some cases these are not discovered by GetMapChildrenInfo above
						-->		Maybe classic doesnot use it.
						local groupID = GetMapGroupID(map);
						if groupID then
							local groupMembers = GetMapGroupMembersInfo(groupID);
							if groupMembers ~= nil and groupMembers[1] ~= nil then
								for index = 1, #groupMembers do
									local mmap = groupMembers[index].mapID;
									if mmap ~= nil then
										processMap(mmap);
									end
								end
							end
						end
						for x = 0.00, 1.00, 0.25 do
							for y = 0.00, 1.00, 0.25 do
								local adata = GetMapInfoAtPosition(map, x, y);
								if adata ~= nil then
									local amap = adata.mapID;
									if amap ~= nil and amap ~= map then
										local ameta = processMap(amap);
										if ameta ~= nil and ameta.parent ~= map then
											local amaps = meta.adjoined;
											if amaps == nil then
												amaps = { [amap] = 1, };
												meta.adjoined = amaps;
											else
												amaps[amap] = 1;
											end
										end
									end
								end
							end
						end
					end
				end
			end
			return meta;
		end
		--	find all maps in well known structures
		processMap(WORLD_MAP_ID);
		--	try to fill in holes in the map list
		for map = 1, 2000 do
			processMap(map);
		end
		if CT.TOCVERSION >= 20000 and CT.TOCVERSION < 40000 then
			local adjoined_fix = {
				[1438] = { 1457, },	--	泰达希尔
				[1457] = { 1438, },	--	达纳苏斯
				--
				[1944] = { 1946, 1951, 1952, },				--	地狱火半岛
				[1946] = { 1944, 1949, 1951, 1952, 1955, },	--	赞加沼泽
				[1948] = { 1952, },							--	影月谷
				[1949] = { 1946, 1953, },					--	刀锋山
				[1951] = { 1944, 1946, 1952, 1955, },		--	纳格兰
				[1952] = { 1944, 1946, 1948, 1951, 1955, },	--	泰罗卡森林
				[1953] = { 1949, },							--	虚空风暴
				[1955] = { 1946, 1951, 1952, },				--	沙塔斯城
				--
				[1947] = { 1943, },	--	埃索达
				[1950] = { 1943, },	--	秘血岛
				[1943] = { 1947, },	--	秘蓝岛
				[1941] = { 1942, 1954, },	--	永歌森林
				[1942] = { 1941, },	--	幽魂之地
				[1954] = { 1941, },	--	银月城
				--
				[118] = { 125, },	--	冰冠冰川
				[120] = { 125, },	--	风暴峭壁
				[125] = { 118, 120, 127, },	--	达拉然
				[127] = { 125, },	--	晶歌森林
				[126] = { 118, 125, 127, },	--	达拉然下水道	--	只在其他地图显示下水道任务，不在下水道显示其他地图
			};
			for map, list in next, adjoined_fix do
				local meta = mapMeta[map];
				if meta ~= nil then
					local amaps = meta.adjoined;
					for _, val in next, list do
						if mapMeta[val] ~= nil then
							if amaps == nil then
								amaps = { [val] = 1, };
								meta.adjoined = amaps;
							else
								amaps[val] = 1;
							end
						end
					end
				end
			end
		end
		--	fill in continent and planet
		local function FillInChildren(which, map, children)
			for cmap, _ in next, children do
				local cmeta = mapMeta[cmap];
				if cmeta ~= nil then
					cmeta[which] = map;
					if cmeta.children ~= nil then
						FillInChildren(which, map, cmeta.children)
					end
				end
			end
		end
		local function FillIn(which, map)
			local meta = mapMeta[map];
			if meta ~= nil and meta.children ~= nil then
				FillInChildren(which, map, meta.children);
			end
		end
		FillIn("universe", 946);
		FillIn("planet", 947);
		FillIn("planet", 1945);
		FillIn("continent", 1414);
		FillIn("continent", 1415);
		FillIn("continent", 1945);
		FillIn("continent", 113);
	end);

-->
