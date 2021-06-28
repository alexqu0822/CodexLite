local __addon, __ns = ...;

if __ns.__dev then
	setfenv(1, __ns.__fenv);
end
local _G = _G;
local _ = nil;
--------------------------------------------------
local __db = __ns.db;

--	Use Questie BL
local blacklist_quest = {
	[7462] = true, -- Duplicate of 7877. See #1583
	[5663] = true, -- Touch of Weakness of Dark Cleric Beryl - Fixing #730
	[5658] = true, -- Touch of Weakness of Father Lankester -- See #1603
	[2358] = true, -- Horns of Nez'ra is not in the game at this point. See #921
	[787] = true, -- The New Horde is not in the game. See #830
	[6606] = true, -- Quest is not in the game. See #1338
	[6072] = true, -- Ayanna Everstride doesn't start "Hunter's Path" (this quest is most likely simply not in the game) #700
	[614] = true, -- Duplicate of 8551
	[615] = true, -- Duplicate of 8553. See #2215
	[618] = true, -- Duplicate of 8554
	[934] = true, -- Duplicate of 7383. See #2386
	[960] = true, -- Duplicate of 961
	[9378] = true, -- Naxxramas quest which doesn't seem to be in the game
	[1318] = true, -- Duplicate of 7703 and not in the game
	[7704] = true, -- Not in the game
	[7668] = true, -- Not in the game (yet) Replaced with 8258 in Ph 4-- #1805
	[636] = true, -- Not in the game - #1900
	[6066] = true, -- Not in the game - #1957
	[4603] = true, -- Duplicate of 2953
	[4604] = true, -- Duplicate of 2953
	[8856] = true, -- Duplicate of 8497
	[9177] = true, -- Duplicate of 9180
	-- Welcome! quests (Collectors Edition)
	[5805] = true,
	[5841] = true,
	[5842] = true,
	[5843] = true,
	[5844] = true,
	[5847] = true,
	--Stray quests
	[3861] = true, --CLUCK!
	--World event quests
	--Fetched from https://classic.wowhead.com/world-event-quests
	[7904] = true,
	[8571] = true,
	[7930] = true,
	[7931] = true,
	[7935] = true,
	[7932] = true,
	[7933] = true,
	[7934] = true,
	[7936] = true,
	[7981] = true,
	[7940] = true,
	[8744] = true,
	[8803] = true,
	[8768] = true,
	[8788] = true,
	[8767] = true,
	[9319] = true,
	[9386] = true,
	[7045] = true,
	[6984] = true,
	[9365] = true,
	[9339] = true,
	[8769] = true,
	[171] = true,
	[5502] = true,
	[7885] = true,
	[8647] = true,
	[7892] = true,
	[8715] = true,
	[8719] = true,
	[8718] = true,
	[8673] = true,
	[8726] = true,
	[8866] = true,
	[925] = true,
	[7881] = true,
	[7882] = true,
	[8353] = true,
	[8354] = true,
	[172] = true,
	[1468] = true,
	[8882] = true,
	[8880] = true,
	[7889] = true,
	[7894] = true,
	[1658] = true,
	[7884] = true,
	[8357] = true,
	[8360] = true,
	[8648] = true,
	[8677] = true,
	[7907] = true,
	[7906] = true,
	[7929] = true,
	[7927] = true,
	[7928] = true,
	[8683] = true,
	[910] = true,
	[8684] = true,
	[8868] = true,
	[8862] = true,
	[7903] = true,
	[8727] = true,
	[8863] = true,
	[8864] = true,
	[8865] = true,
	[8878] = true,
	[8877] = true,
	[8356] = true,
	[8359] = true,
	[9388] = true,
	[9389] = true,
	[911] = true,
	[8222] = true,
	[8653] = true,
	[8652] = true,
	[6961] = true,
	[7021] = true,
	[7024] = true,
	[7022] = true,
	[7023] = true,
	[7896] = true,
	[7891] = true,
	[8679] = true,
	[8311] = true,
	[8312] = true,
	[8646] = true,
	[7890] = true,
	[8686] = true,
	[8643] = true,
	[8149] = true,
	[8150] = true,
	[8355] = true,
	[8358] = true,
	[8651] = true,
	[558] = true,
	[8881] = true,
	[8879] = true,
	[1800] = true,
	[8867] = true,
	[8722] = true,
	[7897] = true,
	[8762] = true,
	[8746] = true,
	[8685] = true,
	[8714] = true,
	[8717] = true,
	[7941] = true,
	[7943] = true,
	[7939] = true,
	[8223] = true,
	[7942] = true,
	[8619] = true,
	[8724] = true,
	[8861] = true,
	[8860] = true,
	[8723] = true,
	[8645] = true,
	[8654] = true,
	[8678] = true,
	[8671] = true,
	[7893] = true,
	[8725] = true,
	[8322] = true,
	[8409] = true,
	[8636] = true,
	[8670] = true,
	[8642] = true,
	[8675] = true,
	[8720] = true,
	[8682] = true,
	[7899] = true,
	[8876] = true,
	[8650] = true,
	[7901] = true,
	[7946] = true,
	[8635] = true,
	[1687] = true,
	[8716] = true,
	[8713] = true,
	[8721] = true,
	[9332] = true,
	[9331] = true,
	[9324] = true,
	[9330] = true,
	[9326] = true,
	[9325] = true,
	[1657] = true,
	[7042] = true,
	[6963] = true,
	[8644] = true,
	[8672] = true,
	[8649] = true,
	[1479] = true,
	[7063] = true,
	[7061] = true,
	[9368] = true,
	[9367] = true,
	[8763] = true,
	[8799] = true,
	[8873] = true,
	[8874] = true,
	[8875] = true,
	[8870] = true,
	[8871] = true,
	[8872] = true,
	[8373] = true,
	[7062] = true,
	[6964] = true,
	[1558] = true,
	[7883] = true,
	[7898] = true,
	[8681] = true,
	[7900] = true,
	[6962] = true,
	[7025] = true,
	[8883] = true,
	[7902] = true,
	[7895] = true,
	[9322] = true,
	[9323] = true,
	[8676] = true,
	[8688] = true,
	[8680] = true,
	[8828] = true,
	[8827] = true,
	[8674] = true,
	[915] = true,
	[4822] = true,
	[7043] = true,
	[6983] = true,
	[7937] = true,
	[7938] = true,
	[7944] = true,
	[7945] = true,
	[8857] = true,
	[8858] = true,
	[8859] = true,
	--Rocknot's Ale instance quest shown in SG/BS at lvl 1
	[4295] = true,
	--mount exchange/replacement
	[7678] = true,
	[7677] = true,
	[7673] = true,
	[7674] = true,
	[7671] = true,
	[7665] = true,
	[7675] = true,
	[7664] = true,
	[7672] = true,
	[7676] = true,
	--fishing tournament
	[8194] = true,
	[8221] = true,
	[8224] = true,
	[8225] = true,
	[8193] = true,
	[8226] = true,
	[8228] = true,
	[8229] = true,
	--love is in the air
	[8903] = true,
	[8904] = true,
	[8897] = true,
	[8898] = true,
	[8899] = true,
	[9029] = true,
	[8981] = true,
	[8993] = true,
	[8900] = true,
	[8901] = true,
	[8902] = true,
	[9024] = true,
	[9025] = true,
	[9026] = true,
	[9027] = true,
	[9028] = true,
	[8971] = true,
	[8972] = true,
	[8973] = true,
	[8974] = true,
	[8975] = true,
	[8976] = true,
	[8979] = true,
	[8980] = true,
	[8982] = true,
	[8983] = true,
	[8984] = true,
	-- TBC event quests
	[9249] = true,
	[10938] = true,
	[10939] = true,
	[10940] = true,
	[10941] = true,
	[10942] = true,
	[10943] = true,
	[11117] = true,
	[11118] = true,
	[11120] = true,
	[11127] = true,
	[11131] = true,
	[11135] = true,
	[11219] = true,
	[11220] = true,
	[11318] = true,
	[11320] = true,
	[11356] = true,
	[11357] = true,
	[11360] = true,
	[11361] = true,
	[11392] = true,
	[11400] = true,
	[11401] = true,
	[11404] = true,
	[11405] = true,
	[11409] = true,
	[11437] = true,
	[11438] = true,
	[11439] = true,
	[11440] = true,
	[11441] = true,
	[11442] = true,
	[11446] = true,
	[11447] = true,
	[11449] = true,
	[11450] = true,
	[11454] = true,
	[11528] = true,
	[11580] = true,
	[11581] = true,
	[11583] = true,
	[11691] = true,
	[11696] = true,
	[11731] = true,
	[11732] = true,
	[11734] = true,
	[11735] = true,
	[11736] = true,
	[11737] = true,
	[11738] = true,
	[11739] = true,
	[11740] = true,
	[11741] = true,
	[11742] = true,
	[11743] = true,
	[11744] = true,
	[11745] = true,
	[11746] = true,
	[11747] = true,
	[11748] = true,
	[11749] = true,
	[11750] = true,
	[11751] = true,
	[11752] = true,
	[11753] = true,
	[11754] = true,
	[11755] = true,
	[11756] = true,
	[11757] = true,
	[11758] = true,
	[11759] = true,
	[11760] = true,
	[11761] = true,
	[11762] = true,
	[11763] = true,
	[11764] = true,
	[11765] = true,
	[11766] = true,
	[11767] = true,
	[11768] = true,
	[11769] = true,
	[11770] = true,
	[11771] = true,
	[11772] = true,
	[11773] = true,
	[11774] = true,
	[11775] = true,
	[11776] = true,
	[11777] = true,
	[11778] = true,
	[11779] = true,
	[11780] = true,
	[11781] = true,
	[11782] = true,
	[11783] = true,
	[11784] = true,
	[11785] = true,
	[11786] = true,
	[11787] = true,
	[11799] = true,
	[11800] = true,
	[11801] = true,
	[11802] = true,
	[11803] = true,
	[11804] = true,
	[11805] = true,
	[11806] = true,
	[11807] = true,
	[11808] = true,
	[11809] = true,
	[11810] = true,
	[11811] = true,
	[11812] = true,
	[11813] = true,
	[11814] = true,
	[11815] = true,
	[11816] = true,
	[11817] = true,
	[11818] = true,
	[11819] = true,
	[11820] = true,
	[11821] = true,
	[11822] = true,
	[11823] = true,
	[11824] = true,
	[11825] = true,
	[11826] = true,
	[11827] = true,
	[11828] = true,
	[11829] = true,
	[11830] = true,
	[11831] = true,
	[11832] = true,
	[11833] = true,
	[11834] = true,
	[11882] = true,
	[11886] = true,
	[11915] = true,
	[11933] = true,
	[11935] = true,
	[11964] = true,
	[11966] = true,
	[11970] = true,
	[11971] = true,
	[12020] = true,
	[12022] = true,
	[12133] = true,
	[12191] = true,
	[12194] = true,
	[12278] = true,
	[12286] = true,
	[12331] = true,
	[12332] = true,
	[12333] = true,
	[12334] = true,
	[12335] = true,
	[12336] = true,
	[12337] = true,
	[12338] = true,
	[12339] = true,
	[12340] = true,
	[12341] = true,
	[12342] = true,
	[12343] = true,
	[12344] = true,
	[12345] = true,
	[12346] = true,
	[12347] = true,
	[12348] = true,
	[12349] = true,
	[12350] = true,
	[12351] = true,
	[12352] = true,
	[12353] = true,
	[12354] = true,
	[12355] = true,
	[12356] = true,
	[12357] = true,
	[12358] = true,
	[12359] = true,
	[12360] = true,
	[12396] = true,
	[12397] = true,
	[12398] = true,
	[12399] = true,
	[12400] = true,
	[12401] = true,
	[12402] = true,
	[12403] = true,
	[12404] = true,
	[12405] = true,
	[12406] = true,
	[12407] = true,
	[12408] = true,
	[12409] = true,
	[12410] = true,
	[12420] = true,
	----------------

	--mount replacement
	[7662] = true,
	[7663] = true,
	[7660] = true,
	[7661] = true,
	-- PvP Quests which are not in the game anymore
	-----------------------------------------------
	-- Vanquish the Invaders
	[7788] = true,
	[7871] = true,
	[7872] = true,
	[7873] = true,
	[8290] = true,
	[8291] = true,
	-- Talisman of Merit
	[7886] = true,
	[7887] = true,
	[7888] = true,
	[7921] = true,
	[8567] = true,
	[8289] = true,
	[8292] = true,
	[8001] = true,
	-- Quell the Silverwing Usurpers
	[7789] = true,
	[7874] = true,
	[7875] = true,
	[7876] = true,
	[8294] = true,
	[8295] = true,
	-- Warsong Mark of Honor
	[7922] = true,
	[7923] = true,
	[7924] = true,
	[7925] = true,
	[8293] = true,
	[8296] = true,
	[8568] = true,
	[8002] = true,
	-- Arathi Basin
	[8081] = true,
	[8124] = true,
	[8157] = true,
	[8158] = true,
	[8159] = true,
	[8163] = true,
	[8164] = true,
	[8165] = true,
	[8298] = true,
	[8300] = true,
	[8565] = true,
	[8566] = true,
	[8123] = true,
	[8160] = true,
	[8161] = true,
	[8162] = true,
	[8299] = true,
	[8080] = true,
	[8154] = true,
	[8155] = true,
	[8156] = true,
	[8297] = true,
	-- Alterac Valley
	[7221] = true,
	[7222] = true,
	[7367] = true,
	[7368] = true,
	-- Master Ryson's All Seeing Eye
	[6847] = true,
	[6848] = true,
	-- WANTED: Orcs and WANTED: Dwarves
	[7402] = true,
	[7428] = true,
	[7401] = true,
	[7427] = true,
	-- Ribbons of Sacrifice
	[8266] = true,
	[8267] = true,
	[8268] = true,
	[8269] = true,
	[8569] = true,
	[8570] = true,
	-----------------------------------------------

	-- corrupted windblossom
	[2523] = true,
	[2878] = true,
	[3363] = true,
	[4113] = true,
	[4114] = true,
	[4116] = true,
	[4118] = true,
	[4401] = true,
	[4464] = true,
	[4465] = true,
	[996] = true,
	[998] = true,
	[1514] = true,
	[4115] = true,
	[4221] = true,
	[4222] = true,
	[4343] = true,
	[4403] = true,
	[4466] = true,
	[4467] = true,
	[4117] = true,
	[4443] = true,
	[4444] = true,
	[4445] = true,
	[4446] = true,
	[4461] = true,
	[4119] = true,
	[4447] = true,
	[4448] = true,
	[4462] = true,

	--Darkmoon Faire
	[7905] = true,
	[7926] = true,

	[8743] = true, -- Bang a Gong! (AQ40 opening quest)

	-- Phase 6 Invasion quests
	-- Investigate the Scourge of X
	[9260] = true,
	[9261] = true,
	[9262] = true,
	[9263] = true,
	[9264] = true,
	[9265] = true,
	--
	[9085] = true,
	[9153] = true,
	[9154] = true,
	--

	----- TBC -------------- TBC quests --------------- TBC -----
	----- TBC ------------- starting here -------------- TBC -----

	-- [BETA] quests
	[402] = true, -- Sirra is Busy
	[785] = true, -- A Strategic Alliance
	[999] = true, -- When Dreams Turn to Nightmares
	[1005] = true, -- What Lurks Beyond
	[1006] = true, -- What Lies Beyond
	[1099] = true, -- Goblins Win!
	[1263] = true, -- The Burning Inn <CHANGE TO GOSSIP>
	[1272] = true, -- Finding Reethe <CHANGE INTO GOSSIP>
	[1281] = true, -- Jim's Song <CHANGE TO GOSSIP>
	[1289] = true, -- Vimes's Report
	[1500] = true, -- Waking Naralex
	[7961] = true, -- Waskily Wabbits!
	[8478] = true, -- Choose Your Weapon
	[8489] = true, -- An Intact Converter
	[8896] = true, -- The Dwarven Spy
	[9168] = true, -- Heart of Deatholme
	[9342] = true, -- Marauding Crust Bursters
	[9344] = true, -- A Hasty Departure
	[9346] = true, -- When Helboars Fly
	[9357] = true, -- Report to Aeldon Sunbrand
	[9382] = true, -- The Fate of the Clefthoof
	[9408] = true, -- Forgotten Heroes
	[9511] = true, -- Kargath's Battle Plans
	[9568] = true, -- On the Offensive
	[9749] = true, -- They're Alive! Maybe...
	[9929] = true, -- The Missing Merchant
	[9930] = true, -- The Missing Merchant
	[9941] = true, -- Tracking Down the Culprits
	[9942] = true, -- Tracking Down the Culprits
	[9943] = true, -- Return to Thander
	[9947] = true, -- Return to Rokag
	[9949] = true, -- A Bird's-Eye View
	[9950] = true, -- A Bird's-Eye View
	[9952] = true, -- Prospector Balmoral
	[9953] = true, -- Lookout Nodak
	[9958] = true, -- Scouting the Defenses
	[9959] = true, -- Scouting the Defenses
	[9963] = true, -- Seeking Help from the Source
	[9964] = true, -- Seeking Help from the Source
	[9965] = true, -- A Show of Good Faith
	[9966] = true, -- A Show of Good Faith
	[9969] = true, -- The Final Reagents
	[9974] = true, -- The Final Reagents
	[9975] = true, -- Primal Magic
	[9976] = true, -- Primal Magic
	[9980] = true, -- Rescue Deirom!
	[9981] = true, -- Rescue Dugar!
	[9984] = true, -- Host of the Hidden City
	[9985] = true, -- Host of the Hidden City
	[9988] = true, -- A Dandy's Best Friend
	[9989] = true, -- Alien Spirits
	[10014] = true, -- The Firewing Point Project
	[10015] = true, -- The Firewing Point Project
	[10029] = true, -- The Spirits Are Calling
	[10046] = true, -- Through the Dark Portal
	[10053] = true, -- Dealing with Zeth'Gor
	[10054] = true, -- Impending Doom
	[10056] = true, -- Bleeding Hollow Supplies
	[10059] = true, -- Dealing With Zeth'Gor
	[10060] = true, -- Impending Doom
	[10061] = true, -- The Unyielding
	[10062] = true, -- Looking to the Leadership
	[10084] = true, -- Assault on Mageddon
	[10088] = true, -- When This Mine's a-Rockin'
	[10089] = true, -- Forge Camps of the Legion
	[10092] = true, -- Assault on Mageddon
	[10100] = true, -- The Mastermind
	[10122] = true, -- The Citadel's Reach
	[10125] = true, -- Mission: Disrupt Communications
	[10126] = true, -- Warboss Nekrogg's Orders
	[10127] = true, -- Mission: Sever the Tie
	[10128] = true, -- Saving Private Imarion
	[10130] = true, -- The Western Flank
	[10131] = true, -- Planning the Escape
	[10133] = true, -- Mission: Kill the Messenger
	[10135] = true, -- Mission: Be the Messenger
	[10137] = true, -- Provoking the Warboss
	[10138] = true, -- Under Whose Orders?
	[10139] = true, -- Dispatching the Commander
	[10145] = true, -- Mission: Sever the Tie UNUSED
	[10147] = true, -- Mission: Kill the Messenger
	[10148] = true, -- Mission: Be the Messenger
	[10149] = true, -- Mission: End All, Be All
	[10150] = true, -- The Citadel's Reach
	[10151] = true, -- Warboss Nekrogg's Orders
	[10152] = true, -- The Western Flank
	[10153] = true, -- Saving Scout Makha
	[10154] = true, -- Planning the Escape
	[10155] = true, -- Provoking the Warboss
	[10156] = true, -- Under Whose Orders?
	[10157] = true, -- Dispatching the Commander
	[10158] = true, -- Bleeding Hollow Supplies
	[10179] = true, -- The Custodian of Kirin'Var
	[10187] = true, -- A Message for the Archmage
	[10195] = true, -- Mercenary See, Mercenary Do
	[10196] = true, -- More Arakkoa Feathers
	[10207] = true, -- Forward Base: Reaver's Fall REUSE
	[10214] = true, -- When This Mine's a-Rockin'
	[10244] = true, -- R.T.F.R.C.M.
	[10260] = true, -- Netherologist Coppernickels
	[10292] = true, -- More Power!
	[10370] = true, -- Nazgrel's Command <TXT>
	[10375] = true, -- Obsidian Warbeads
	[10386] = true, -- The Fel Reaver Slayer
	[10387] = true, -- The Fel Reaver Slayer
	[10398] = true, -- Return to Honor Hold
	[10401] = true, -- Mission: End All, Be All
	[10404] = true, -- Against the Legion
	[10441] = true, -- Peddling the Goods
	[10716] = true, -- Test Flight: Raven's Wood <needs reward>
	[10815] = true, -- The Journal of Val'zareq: Portends of War
	[10841] = true, -- The Vengeful Harbringer
	[10844] = true, -- Forge Camp: Anger
	[10871] = true, -- Ally of the Netherwing
	[10872] = true, -- Zuluhed the Whacked
	[10925] = true, -- Evil Draws Near

	-- <NYI> quests
	[3482] = true, -- <NYI> <TXT> The Pocked Black Box
	[7741] = true, -- Praise from the Emerald Circle <NYI> <TXT>
	[8339] = true, -- Royalty of the Council <NYI> <TXT> UNUSED
	[8340] = true, -- Twilight Signet Ring <NYI> <TXT>

	-- [Not Used] quests
	[620] = true, -- UNUSED The Monogrammed Sash
	[1390] = true, -- BETA Oops, We Killed Them Again.
	[2019] = true, -- Tools of the Trade
	[5383] = true, -- Krastinov's Bag of Horrors
	[8530] = true, -- The Alliance Needs Singed Corestones!
	[8618] = true, -- The Horde Needs More Singed Corestones!
	[9380] = true, -- BETA Hounded for More
	[9510] = true, -- BETA Bristlehide Clefthoof Hides
	[9599] = true, -- <UNUSED>
	[9750] = true, -- UNUSED Urgent Delivery
	[9767] = true, -- Know Your Enemy
	[9955] = true, -- A Show of Good Faith
	[10090] = true, -- BETA The Legion's Plans

	[1] = true, -- Unavailable quest "The "Chow" Quest (123)aa"
	[2881] = true, -- Wildhammer faction removed in TBC. Repeatable to gain rep
	[8329] = true, -- Warrior Training / Not in the game
	[8547] = true, -- Welcome!
	[9065] = true, -- Unavailable quest "The "Chow" Quest (123)aa"
	[9278] = true, -- Welcome!
	[9681] = true, -- Replaced with [A Study in Power (64319)]
	[9684] = true, -- Replaced with [Claiming the Light (63866)]
	[9721] = true, -- Replaced with [A Summons from Lady Liadrin (64139)]
	[9722] = true, -- Replaced with [The Master's Path (64140)]
	[9723] = true, -- Replaced with [A Gesture of Commitment (64141)]
	[9725] = true, -- Replaced with [A Demonstration of Loyalty (64142)]
	[9735] = true, -- Replaced with [True Masters of the Light (64143)]
	[9736] = true, -- Replaced with [True Masters of the Light (64144)]
	[9737] = true, -- Replaced with [True Masters of the Light  (64145)]
	[9926] = true, -- FLAG Shadow Council/Warmaul Questline
	[10048] = true, -- A Handful of Magic Dust BETA
	[10049] = true, -- A Handful of Magic Dust BETA
	[10169] = true, -- Losing Gracefully (removed with 2.4.0)
	[10259] = true, -- Into the Breach (TBC Pre patch event)
	[10364] = true, -- Caedmos (Unavailable Priest quest)
	[10379] = true, -- Touch of Weakness (Followup of NOT A QUEST)
	[10534] = true, -- Returning Home (Unavailable Priest quest)
	[10539] = true, -- Returning Home (Unavailable Priest quest)
	[10561] = true, -- Revered Among the Keepers of Time
	[10638] = true, -- NOT A QUEST (Unavailable Priest quest)
	[10779] = true, -- The Hunter's Path (Unused)
	[10931] = true, -- Level 0 Priest quest
	[10932] = true, -- Level 0 Priest quest
	[10933] = true, -- Level 0 Priest quest
	[10934] = true, -- Level 0 Priest quest
	[64028] = true, -- First quest for boosted characters. Blocked to not show for others
	[64037] = true, -- Boosted character quest
	[64038] = true, -- Boosted character quest
	[64046] = true, -- First quest for boosted characters. Blocked to not show for others
	[64047] = true, -- First quest for boosted characters. Blocked to not show for others
	[64063] = true, -- Boosted character quest
	[64064] = true, -- Boosted character quest
	[64128] = true, -- Boosted character quest
	[64217] = true, -- Boosted character quest

	[11497] = true, -- Learning to Fly (requires NOT to have flying skill, which can't be handled atm)
	[11498] = true, -- Learning to Fly (requires NOT to have flying skill, which can't be handled atm)

	-- [OLD] quests. Classic quests deprecated in TBC
	[708] = true,
	[909] = true,
	[1288] = true,
	[1661] = true,
	[3366] = true,
	[3381] = true,
	[3631] = true,
	[4487] = true,
	[4488] = true,
	[4489] = true,
	[4490] = true,
	[5627] = true,
	[5641] = true,
	[5645] = true,
	[5647] = true,
	[6131] = true,
	[6221] = true,
	[6241] = true,
	[7364] = true,
	[7365] = true,
	[7421] = true,
	[7422] = true,
	[7423] = true,
	[7425] = true,
	[7426] = true,
	[7521] = true,
	[8368] = true,
	[8369] = true,
	[8370] = true,
	[8372] = true,
	[8374] = true,
	[8375] = true,
	[8383] = true,
	[8384] = true,
	[8386] = true,
	[8387] = true,
	[8389] = true,
	[8390] = true,
	[8391] = true,
	[8392] = true,
	[8393] = true,
	[8394] = true,
	[8395] = true,
	[8396] = true,
	[8397] = true,
	[8398] = true,
	[8399] = true,
	[8400] = true,
	[8401] = true,
	[8402] = true,
	[8403] = true,
	[8404] = true,
	[8405] = true,
	[8406] = true,
	[8407] = true,
	[8408] = true,
	[8411] = true,
	[8426] = true,
	[8427] = true,
	[8428] = true,
	[8429] = true,
	[8430] = true,
	[8431] = true,
	[8432] = true,
	[8433] = true,
	[8434] = true,
	[8435] = true,
	[8436] = true,
	[8437] = true,
	[8438] = true,
	[8439] = true,
	[8440] = true,
	[8441] = true,
	[8442] = true,
	[8443] = true,
	[9712] = true,
	[10377] = true,
	[10459] = true,
	[10558] = true,
	[11052] = true,

	-- Phase 2 - Serpentshrine Cavern, Tempest Keep
	[11007] = true,

	-- Druid Swift Flight Form
	[10955] = true,
	[10961] = true,
	[10964] = true,
	[10965] = true,
	[10978] = true,
	[10979] = true,
	[10980] = true,
	[10986] = true,
	[10987] = true,
	[10988] = true,
	[10990] = true,
	[10991] = true,
	[10992] = true,
	[10993] = true,
	[10994] = true,
	[11001] = true,
	[11011] = true,

	-- Ogri'la & Sha'tari Skyguard
	[11004] = true,
	[11005] = true,
	[11006] = true,
	[11008] = true,
	[11009] = true,
	[11010] = true,
	[11021] = true,
	[11023] = true,
	[11024] = true,
	[11025] = true,
	[11026] = true,
	[11027] = true,
	[11028] = true,
	[11029] = true,
	[11030] = true,
	[11051] = true,
	[11056] = true,
	[11057] = true,
	[11058] = true,
	[11059] = true,
	[11060] = true,
	[11061] = true,
	[11062] = true,
	[11065] = true,
	[11066] = true,
	[11072] = true,
	[11073] = true,
	[11074] = true,
	[11078] = true,
	[11079] = true,
	[11080] = true,
	[11085] = true,
	[11091] = true,
	[11093] = true,
	[11096] = true,
	[11098] = true,
	[11102] = true,
	[11119] = true,
	[11885] = true,

	-- Netherwing
	[11012] = true,
	[11013] = true,
	[11015] = true,
	[11016] = true,
	[11017] = true,
	[11018] = true,
	[11020] = true,
	[11035] = true,
	[11041] = true,
	[11049] = true,
	[11050] = true,
	[11053] = true,
	[11054] = true,
	[11055] = true,
	[11064] = true,
	[11067] = true,
	[11068] = true,
	[11069] = true,
	[11070] = true,
	[11071] = true,
	[11075] = true,
	[11076] = true,
	[11077] = true,
	[11081] = true,
	[11082] = true,
	[11083] = true,
	[11084] = true,
	[11086] = true,
	[11089] = true,
	[11090] = true,
	[11092] = true,
	[11094] = true,
	[11097] = true,
	[11099] = true,
	[11101] = true,
	[11108] = true,

	-- Phase 3 - Hyjal, Black Temple
	[10445] = true,
	[10460] = true,
	[10461] = true,
	[10462] = true,
	[10463] = true,
	[10464] = true,
	[10465] = true,
	[10466] = true,
	[10467] = true,
	[10468] = true,
	[10469] = true,
	[10470] = true,
	[10471] = true,
	[10472] = true,
	[10473] = true,
	[10474] = true,
	[10475] = true,
	[10560] = true,
	[10944] = true,
	[10946] = true,
	[10947] = true,
	[10948] = true,
	[10949] = true,
	[10957] = true,
	[10958] = true,
	[10959] = true,
	[10985] = true,

	-- Phase 4 Zul'Aman
	[11130] = true,
	[11132] = true,
	[11163] = true,
	[11164] = true,
	[11178] = true,
	[11196] = true,

	-- Phase 5 Sunwell and Isle of Quel'Danas
	[11481] = true,
	[11482] = true,
	[11488] = true,
	[11496] = true,
	[11513] = true,
	[11514] = true,
	[11515] = true,
	[11516] = true,
	[11517] = true,
	[11520] = true,
	[11521] = true,
	[11523] = true,
	[11524] = true,
	[11525] = true,
	[11526] = true,
	[11532] = true,
	[11533] = true,
	[11534] = true,
	[11535] = true,
	[11536] = true,
	[11537] = true,
	[11538] = true,
	[11539] = true,
	[11540] = true,
	[11541] = true,
	[11542] = true,
	[11543] = true,
	[11544] = true,
	[11545] = true,
	[11546] = true,
	[11547] = true,
	[11548] = true,
	[11549] = true,
	[11550] = true,
	[11554] = true,
	[11555] = true,
	[11556] = true,
	[11557] = true,
	[11875] = true,
	[11880] = true,
	[11877] = true,
	--	AQWarEffortQuests
	-- Commendation Signet
	[8811] = true,
	[8812] = true,
	[8813] = true,
	[8814] = true,
	[8815] = true,
	[8816] = true,
	[8817] = true,
	[8818] = true,
	[8819] = true,
	[8820] = true,
	[8821] = true,
	[8822] = true,
	[8823] = true,
	[8824] = true,
	[8825] = true,
	[8826] = true,
	[8830] = true,
	[8831] = true,
	[8832] = true,
	[8833] = true,
	[8834] = true,
	[8835] = true,
	[8836] = true,
	[8837] = true,
	[8838] = true,
	[8839] = true,
	[8840] = true,
	[8841] = true,
	[8842] = true,
	[8843] = true,
	[8844] = true,
	[8845] = true,
	[8846] = true,
	[8847] = true,
	[8848] = true,
	[8849] = true,
	[8850] = true,
	[8851] = true,
	[8852] = true,
	[8853] = true,
	[8854] = true,
	[8855] = true,
	-- War Effort
	[8492] = true,
	[8493] = true,
	[8494] = true,
	[8495] = true,
	[8499] = true,
	[8500] = true,
	[8503] = true,
	[8504] = true,
	[8505] = true,
	[8506] = true,
	[8509] = true,
	[8510] = true,
	[8511] = true,
	[8512] = true,
	[8513] = true,
	[8514] = true,
	[8515] = true,
	[8516] = true,
	[8517] = true,
	[8518] = true,
	[8520] = true,
	[8521] = true,
	[8522] = true,
	[8523] = true,
	[8524] = true,
	[8525] = true,
	[8526] = true,
	[8527] = true,
	[8528] = true,
	[8529] = true,
	[8532] = true,
	[8533] = true,
	[8542] = true,
	[8543] = true,
	[8545] = true,
	[8546] = true,
	[8549] = true,
	[8550] = true,
	[8580] = true,
	[8581] = true,
	[8582] = true,
	[8583] = true,
	[8588] = true,
	[8589] = true,
	[8590] = true,
	[8591] = true,
	[8600] = true,
	[8601] = true,
	[8604] = true,
	[8605] = true,
	[8607] = true,
	[8608] = true,
	[8609] = true,
	[8610] = true,
	[8611] = true,
	[8612] = true,
	[8613] = true,
	[8614] = true,
	[8615] = true,
	[8616] = true,
	[8792] = true,
	[8793] = true,
	[8794] = true,
	[8795] = true,
	[8796] = true,
	[8797] = true,
	[10501] = true,	
};
__db.blacklist_quest = blacklist_quest;

local blacklist_item = {
	[765] = true, -- silverleaf
	[774] = true, -- malachite
	[785] = true, -- mageroyal
	[929] = true, -- Healing Potion
	[1206] = true, -- moss agate
	[1210] = true, -- shadowgem
	[1529] = true, -- jade
	[1705] = true, -- lesser moonstone
	[2447] = true, -- peacebloom
	[2449] = true, -- earthroot
	[2450] = true, -- briarthorn
	[2452] = true, -- swiftthistle
	[2453] = true, -- bruiseweed
	[2455] = true, -- Minor Mana Potion
	[2589] = true, -- linen cloth
	[2592] = true, -- wool cloth
	[2842] = true, -- Silver Bar
	[2997] = true, -- bolt of wool
	[3355] = true, -- wild steelbloom
	[3356] = true, -- kingsblood
	[3357] = true, -- liferoot
	[3358] = true, -- khadgar's whisker
	[3369] = true, -- grave moss
	[3818] = true, -- fadeleaf
	[3819] = true, -- wintersbite
	[3820] = true, -- stranglekelp
	[3821] = true, -- goldthorn
	[3864] = true, -- citrine
	[4306] = true, -- silk cloth
	[4338] = true, -- mageweave
	[4625] = true, -- firebloom
	[5056] = true, -- root sample
	[7079] = true, -- globe of water
	[7909] = true, -- aquamarine
	[7910] = true, -- star ruby
	[8153] = true, -- wildvine
	[8244] = true, -- flawless-draenethyst-sphere
	[8831] = true, -- purple lotus
	[8836] = true, -- arthas tears
	[8838] = true, -- sungrass
	[8839] = true, -- blindweed
	[8845] = true, -- ghost mushroom
	[8846] = true, -- gromsblood
	[8932] = true, -- Alterac Swiss
	[10561] = true, -- Mithril Casing
	[10593] = true, -- imperfect-draenethyst-fragment
	[12207] = true, -- giant egg
	[12361] = true, -- blue sapphire
	[12363] = true, -- arcane crystal
	[12364] = true, -- huge emerald
	[12799] = true, -- large opal
	[12800] = true, -- azerothian diamond
	[13422] = true, -- stonescale-eel
	[13444] = true, -- major mana potion
	[13446] = true, -- Major Healing Potion
	[13463] = true, -- dreamfoil
	[13464] = true, -- golden sansam
	[13465] = true, -- mountain silversage
	[13466] = true, -- plaguebloom
	[13467] = true, -- icecap
	[13468] = true, -- black lotus
	[14047] = true, -- runecloth
	[14048] = true, -- bolt of runecloth
	[14344] = true, -- large brilliant shard
	[18335] = true, -- Pristine Black Diamond

	-- stranglethorn pages
	[2725] = true,
	[2728] = true,
	[2730] = true,
	[2732] = true,
	[2734] = true,
	[2735] = true,
	[2738] = true,
	[2740] = true,
	[2742] = true,
	[2744] = true,
	[2745] = true,
	[2748] = true,
	[2749] = true,
	[2750] = true,
	[2751] = true,

	-- shredder operating manual
	[16645] = true,
	[16646] = true,
	[16647] = true,
	[16648] = true,
	[16649] = true,
	[16650] = true,
	[16651] = true,
	[16652] = true,
	[16653] = true,
	[16654] = true,
	[16655] = true,
	[16656] = true,

	--zul'gurub coins and bijous
	[19698] = true,
	[19699] = true,
	[19700] = true,
	[19701] = true,
	[19702] = true,
	[19703] = true,
	[19704] = true,
	[19705] = true,
	[19706] = true,
	[19707] = true,
	[19708] = true,
	[19709] = true,
	[19710] = true,
	[19711] = true,
	[19712] = true,
	[19713] = true,
	[19714] = true,
	[19715] = true,

	--ahn'qiraj scarabs and idols
	[20858] = true,
	[20859] = true,
	[20860] = true,
	[20861] = true,
	[20862] = true,
	[20863] = true,
	[20864] = true,
	[20865] = true,
	[20866] = true,
	[20867] = true,
	[20868] = true,
	[20869] = true,
	[20870] = true,
	[20871] = true,
	[20872] = true,
	[20873] = true,
	[20874] = true,
	[20875] = true,
	[20876] = true,
	[20877] = true,
	[20878] = true,
	[20879] = true,
	[20889] = true,

	--Tier 0.5 & Phase 5
	[4265] = true, -- heavy-armor-kit
	[15564] = true, -- rugged-armor-kit
	[16671] = true, -- bindings-of-elements
	[16673] = true, -- cord-of-elements
	[16680] = true, -- beaststalkers-belt
	[16681] = true, -- beaststalkers-bindings
	[16683] = true, -- magisters-bindings
	[16685] = true, -- magisters-belt
	[16696] = true, -- devout-belt
	[16697] = true, -- devout-bracers
	[16702] = true, -- dreadmist-belt
	[16703] = true, -- dreadmist-bracers
	[16705] = true, -- dreadmist-wraps
	[16710] = true, -- shadowcraft-bracers
	[16713] = true, -- shadowcraft-belt
	[16714] = true, -- wildheart-bracers
	[16716] = true, -- wildheart-belt
	[16722] = true, -- lightforge-bracers
	[16723] = true, -- lightforge-belt
	[16735] = true, -- bracers-of-valor
	[16736] = true, -- belt-of-valor
	[20520] = true, -- dark-rune
	
	-- Phase 6
	[12811] = true, -- righteous orb
	[22525] = true, -- crypt fiend parts
	[22526] = true, -- bone fragments
	[22527] = true, -- core of elements
	[22528] = true, -- dark iron scraps
	[22529] = true, -- savage frond
	
	-- TBC Phase 1
	[21887] = true, -- Knothide Leather
	[22572] = true, -- Mote of Air
	[22573] = true, -- Mote of Earth
	[22574] = true, -- Mote of Fire
	[22575] = true, -- Mote of Life
	[22576] = true, -- Mote of Mana
	[22577] = true, -- Mote of Shadow
	[22578] = true, -- Mote of Water
	[22829] = true, -- Super Healing Potion
	[22832] = true, -- Super Mana Potion
	[23445] = true, -- Fel Iron Bar
	[23793] = true, -- Heavy Knothide Leather
	[24246] = true, -- Sanguine Hibiscus
	[24401] = true, -- Unidentified Plant Parts
	[26042] = true, -- Oshu'gun Crystal Powder Sample
	[26043] = true, -- Oshu'gun Crystal Powder Sample
};
__db.blacklist_item = blacklist_item;

local large_pin = {
	[2] = {
		["item"] = {
			[16305] = 1,
		},
	},
	[6] = {
		["item"] = {
			[182] = 1,
		},
	},
	[10] = {
		["item"] = {
			[8593] = 1,
		},
	},
	[19] = {
		["item"] = {
			[1260] = 1,
		},
	},
	[23] = {
		["item"] = {
			[16303] = 1,
		},
	},
	[24] = {
		["item"] = {
			[16304] = 1,
		},
	},
	[28] = {
		["object"] = {
			[300142] = 1,
		},
	},
	[29] = {
		["object"] = {
			[300142] = 1,
		},
	},
	[30] = {
		["object"] = {
			[300142] = 1,
		},
	},
	[34] = {
		["item"] = {
			[3631] = 1,
		},
	},
	[48] = {
		["item"] = {
			[737] = 1,
		},
	},
	[49] = {
		["item"] = {
			[740] = 1,
			[739] = 1,
			[738] = 1,
		},
	},
	[51] = {
		["item"] = {
			[742] = 1,
		},
	},
	[53] = {
		["item"] = {
			[743] = 1,
		},
	},
	[55] = {
		["unit"] = {
			[1200] = 1,
		},
	},
	[63] = {
		["item"] = {
			[7812] = 1,
		},
	},
	[64] = {
		["item"] = {
			[841] = 1,
		},
	},
	[70] = {
		["item"] = {
			[910] = 1,
		},
	},
	[75] = {
		["item"] = {
			[921] = 1,
		},
	},
	[78] = {
		["item"] = {
			[921] = 1,
		},
	},
	[87] = {
		["item"] = {
			[981] = 1,
		},
	},
	[88] = {
		["item"] = {
			[1006] = 1,
		},
	},
	[90] = {
		["item"] = {
			[2665] = 1,
		},
	},
	[98] = {
		["item"] = {
			[3629] = 1,
		},
	},
	[104] = {
		["item"] = {
			[3636] = 1,
		},
	},
	[105] = {
		["item"] = {
			[17114] = 1,
		},
	},
	[116] = {
		["item"] = {
			[1941] = 1,
			[1939] = 1,
			[1262] = 1,
			[1942] = 1,
		},
	},
	[125] = {
		["item"] = {
			[1309] = 1,
		},
	},
	[126] = {
		["item"] = {
			[3614] = 1,
		},
	},
	[142] = {
		["item"] = {
			[1381] = 1,
		},
	},
	[147] = {
		["item"] = {
			[2239] = 1,
		},
	},
	[167] = {
		["item"] = {
			[1875] = 1,
		},
	},
	[169] = {
		["item"] = {
			[3633] = 1,
		},
	},
	[172] = {
		["item"] = {
			[1923] = 1,
		},
	},
	[176] = {
		["item"] = {
			[1931] = 1,
		},
	},
	[177] = {
		["item"] = {
			[1946] = 1,
		},
	},
	[180] = {
		["item"] = {
			[3632] = 1,
		},
	},
	[181] = {
		["item"] = {
			[1968] = 1,
		},
	},
	[188] = {
		["item"] = {
			[3879] = 1,
		},
	},
	[193] = {
		["item"] = {
			[3876] = 1,
		},
	},
	[197] = {
		["item"] = {
			[3877] = 1,
		},
	},
	[202] = {
		["item"] = {
			[3615] = 1,
		},
	},
	[206] = {
		["item"] = {
			[3616] = 1,
		},
	},
	[207] = {
		["item"] = {
			[2007] = 1,
			[2005] = 1,
			[2006] = 1,
			[2008] = 1,
		},
	},
	[208] = {
		["item"] = {
			[3880] = 1,
		},
	},
	[211] = {
		["item"] = {
			[17114] = 1,
		},
	},
	[217] = {
		["unit"] = {
			[1206] = 1,
			[1207] = 1,
			[1205] = 1,
		},
	},
	[218] = {
		["item"] = {
			[2004] = 1,
		},
	},
	[228] = {
		["item"] = {
			[3514] = 1,
		},
	},
	[238] = {
		["item"] = {
			[8523] = 1,
		},
	},
	[243] = {
		["item"] = {
			[8523] = 1,
		},
	},
	[249] = {
		["item"] = {
			[3617] = 1,
		},
	},
	[253] = {
		["item"] = {
			[2382] = 1,
		},
	},
	[256] = {
		["item"] = {
			[2561] = 1,
		},
	},
	[271] = {
		["item"] = {
			[2713] = 1,
		},
	},
	[272] = {
		["object"] = {
			[300142] = 1,
		},
	},
	[279] = {
		["item"] = {
			[3618] = 1,
		},
	},
	[288] = {
		["item"] = {
			[2594] = 1,
		},
	},
	[289] = {
		["item"] = {
			[3619] = 1,
		},
	},
	[290] = {
		["item"] = {
			[2629] = 1,
		},
	},
	[296] = {
		["item"] = {
			[3638] = 1,
		},
	},
	[304] = {
		["item"] = {
			[3639] = 1,
		},
	},
	[312] = {
		["item"] = {
			[2667] = 1,
		},
	},
	[314] = {
		["item"] = {
			[3627] = 1,
		},
	},
	[335] = {
		["item"] = {
			[2779] = 1,
			[2784] = 1,
		},
	},
	[348] = {
		["item"] = {
			[2797] = 1,
		},
	},
	[354] = {
		["item"] = {
			[2830] = 1,
			[2829] = 1,
			[2828] = 1,
		},
	},
	[357] = {
		["item"] = {
			[2833] = 1,
		},
	},
	[362] = {
		["item"] = {
			[2831] = 1,
		},
	},
	[370] = {
		["unit"] = {
			[1662] = 1,
		},
	},
	[371] = {
		["unit"] = {
			[1664] = 1,
		},
	},
	[372] = {
		["unit"] = {
			[1665] = 1,
		},
	},
	[382] = {
		["item"] = {
			[2885] = 1,
		},
	},
	[383] = {
		["item"] = {
			[2885] = 1,
		},
	},
	[398] = {
		["item"] = {
			[3635] = 1,
		},
	},
	[399] = {
		["item"] = {
			[2998] = 1,
		},
	},
	[408] = {
		["item"] = {
			[3082] = 1,
		},
	},
	[409] = {
		["unit"] = {
			[1946] = 1,
		},
	},
	[410] = {
		["item"] = {
			[3080] = 1,
		},
	},
	[417] = {
		["item"] = {
			[3183] = 1,
		},
	},
	[422] = {
		["item"] = {
			[3155] = 1,
		},
	},
	[424] = {
		["item"] = {
			[3634] = 1,
		},
	},
	[425] = {
		["item"] = {
			[3621] = 1,
		},
	},
	[434] = {
		["unit"] = {
			[1754] = 1,
			[1755] = 1,
		},
	},
	[442] = {
		["item"] = {
			[3623] = 1,
		},
	},
	[450] = {
		["item"] = {
			[3255] = 1,
		},
	},
	[465] = {
		["item"] = {
			[3339] = 1,
		},
	},
	[474] = {
		["item"] = {
			[3625] = 1,
		},
	},
	[480] = {
		["item"] = {
			[3515] = 1,
		},
	},
	[483] = {
		["item"] = {
			[3406] = 1,
			[3405] = 1,
			[3407] = 1,
			[3408] = 1,
		},
	},
	[486] = {
		["unit"] = {
			[2039] = 1,
		},
	},
	[498] = {
		["item"] = {
			[3467] = 1,
			[3499] = 1,
		},
		["object"] = {
			[1721] = 1,
			[1722] = 1,
		},
	},
	[503] = {
		["item"] = {
			[3704] = 1,
		},
	},
	[507] = {
		["unit"] = {
			[2423] = 1,
		},
	},
	[517] = {
		["item"] = {
			[3517] = 1,
		},
	},
	[519] = {
		["item"] = {
			[3550] = 1,
			[3552] = 1,
			[3551] = 1,
		},
	},
	[520] = {
		["item"] = {
			[3553] = 1,
			[3554] = 1,
		},
	},
	[521] = {
		["item"] = {
			[3554] = 1,
		},
	},
	[523] = {
		["item"] = {
			[3626] = 1,
		},
	},
	[527] = {
		["unit"] = {
			[232] = 1,
			[2403] = 1,
		},
	},
	[529] = {
		["item"] = {
			[3564] = 1,
		},
		["unit"] = {
			[2404] = 1,
		},
	},
	[530] = {
		["item"] = {
			[3613] = 1,
		},
	},
	[531] = {
		["item"] = {
			[2713] = 1,
		},
	},
	[532] = {
		["object"] = {
			[1761] = 1,
		},
		["item"] = {
			[3657] = 1,
		},
		["unit"] = {
			[2335] = 1,
		},
	},
	[537] = {
		["item"] = {
			[3672] = 1,
		},
	},
	[539] = {
		["unit"] = {
			[2305] = 1,
		},
	},
	[540] = {
		["item"] = {
			[3659] = 1,
		},
	},
	[541] = {
		["unit"] = {
			[2304] = 1,
		},
	},
	[543] = {
		["item"] = {
			[3684] = 1,
		},
	},
	[544] = {
		["item"] = {
			[3688] = 1,
			[3690] = 1,
			[3689] = 1,
			[3691] = 1,
		},
	},
	[551] = {
		["item"] = {
			[3706] = 1,
		},
	},
	[553] = {
		["object"] = {
			[1770] = 1,
			[1768] = 1,
			[1769] = 1,
		},
	},
	[554] = {
		["item"] = {
			[3706] = 1,
		},
	},
	[566] = {
		["item"] = {
			[3626] = 1,
		},
	},
	[567] = {
		["unit"] = {
			[2449] = 1,
			[2448] = 1,
			[2450] = 1,
			[2451] = 1,
		},
	},
	[573] = {
		["item"] = {
			[737] = 1,
		},
	},
	[584] = {
		["item"] = {
			[3904] = 1,
			[3905] = 1,
		},
	},
	[585] = {
		["item"] = {
			[3907] = 1,
			[3906] = 1,
			[3908] = 1,
		},
	},
	[586] = {
		["item"] = {
			[3909] = 1,
		},
	},
	[591] = {
		["item"] = {
			[3616] = 1,
		},
	},
	[592] = {
		["item"] = {
			[3913] = 1,
		},
	},
	[604] = {
		["item"] = {
			[3920] = 1,
		},
	},
	[608] = {
		["unit"] = {
			[2548] = 1,
			[2550] = 1,
			[2546] = 1,
		},
	},
	[609] = {
		["item"] = {
			[3925] = 1,
			[3924] = 1,
			[3926] = 1,
		},
	},
	[610] = {
		["item"] = {
			[4027] = 1,
		},
	},
	[611] = {
		["item"] = {
			[4027] = 1,
			[4034] = 1,
		},
	},
	[614] = {
		["item"] = {
			[3932] = 1,
		},
	},
	[618] = {
		["item"] = {
			[3935] = 1,
		},
	},
	[619] = {
		["item"] = {
			[4595] = 1,
		},
	},
	[629] = {
		["item"] = {
			[4094] = 1,
		},
	},
	[630] = {
		["item"] = {
			[4103] = 1,
		},
	},
	[633] = {
		["object"] = {
			[2704] = 1,
		},
	},
	[643] = {
		["item"] = {
			[4458] = 1,
		},
	},
	[644] = {
		["item"] = {
			[4466] = 1,
		},
	},
	[651] = {
		["item"] = {
			[4483] = 1,
			[4484] = 1,
			[4485] = 1,
		},
	},
	[652] = {
		["item"] = {
			[4469] = 1,
		},
	},
	[654] = {
		["item"] = {
			[8523] = 1,
		},
	},
	[656] = {
		["item"] = {
			[4473] = 1,
		},
		["object"] = {
			[300139] = 1,
		},
	},
	[662] = {
		["item"] = {
			[4489] = 1,
			[4487] = 1,
			[4488] = 1,
			[4490] = 1,
		},
	},
	[673] = {
		["item"] = {
			[4510] = 1,
		},
	},
	[680] = {
		["item"] = {
			[4551] = 1,
		},
	},
	[684] = {
		["item"] = {
			[4515] = 1,
		},
	},
	[685] = {
		["item"] = {
			[4516] = 1,
			[4517] = 1,
		},
	},
	[693] = {
		["item"] = {
			[4525] = 1,
		},
	},
	[696] = {
		["item"] = {
			[4531] = 1,
			[4532] = 1,
			[4530] = 1,
		},
	},
	[708] = {
		["item"] = {
			[4613] = 1,
		},
	},
	[709] = {
		["item"] = {
			[4631] = 1,
		},
	},
	[717] = {
		["item"] = {
			[4615] = 1,
			[4645] = 1,
			[4843] = 1,
			[4845] = 1,
			[4844] = 1,
		},
	},
	[718] = {
		["item"] = {
			[4629] = 1,
		},
	},
	[722] = {
		["item"] = {
			[4635] = 1,
		},
	},
	[723] = {
		["item"] = {
			[4635] = 1,
		},
	},
	[724] = {
		["item"] = {
			[4635] = 1,
		},
	},
	[732] = {
		["item"] = {
			[4640] = 1,
		},
	},
	[735] = {
		["item"] = {
			[4646] = 1,
			[4644] = 1,
			[4641] = 1,
		},
	},
	[736] = {
		["item"] = {
			[4646] = 1,
			[4644] = 1,
			[4641] = 1,
		},
	},
	[739] = {
		["unit"] = {
			[2945] = 1,
		},
	},
	[746] = {
		["object"] = {
			[2728] = 1,
			[138317] = 1,
			[1896] = 1,
			[141838] = 1,
			[171716] = 1,
			[1743] = 1,
			[180913] = 1,
			[173063] = 1,
			[152045] = 1,
			[175851] = 1,
			[2015] = 1,
			[173095] = 1,
			[179844] = 1,
			[2573] = 1,
			[169969] = 1,
			[173064] = 1,
			[178684] = 1,
			[130668] = 1,
			[2575] = 1,
			[144133] = 1,
			[52175] = 1,
			[1797] = 1,
			[179924] = 1,
			[175144] = 1,
			[152042] = 1,
			[152034] = 1,
			[141841] = 1,
			[23304] = 1,
			[24745] = 1,
			[24746] = 1,
			[1749] = 1,
			[181130] = 1,
			[142078] = 1,
			[17190] = 1,
			[176895] = 1,
			[176509] = 1,
			[19902] = 1,
			[23305] = 1,
			[34571] = 1,
			[21679] = 1,
			[51949] = 1,
			[50831] = 1,
			[1745] = 1,
			[92490] = 1,
			[113754] = 1,
			[153459] = 1,
			[179863] = 1,
			[3223] = 1,
			[2727] = 1,
			[20986] = 1,
			[56897] = 1,
			[179886] = 1,
			[52176] = 1,
			[20738] = 1,
			[50469] = 1,
			[50985] = 1,
			[171717] = 1,
		},
	},
	[754] = {
		["object"] = {
			[2913] = 1,
		},
	},
	[758] = {
		["object"] = {
			[2911] = 1,
		},
	},
	[760] = {
		["object"] = {
			[2909] = 1,
		},
	},
	[762] = {
		["item"] = {
			[4621] = 1,
		},
	},
	[765] = {
		["item"] = {
			[4819] = 1,
		},
	},
	[772] = {
		["object"] = {
			[2914] = 1,
		},
	},
	[776] = {
		["item"] = {
			[4841] = 1,
		},
	},
	[778] = {
		["item"] = {
			[4847] = 1,
		},
	},
	[779] = {
		["item"] = {
			[4843] = 1,
			[4844] = 1,
			[4845] = 1,
		},
	},
	[782] = {
		["item"] = {
			[4640] = 1,
		},
	},
	[784] = {
		["unit"] = {
			[3192] = 1,
		},
	},
	[786] = {
		["object"] = {
			[3190] = 1,
			[3189] = 1,
			[3192] = 1,
		},
	},
	[790] = {
		["item"] = {
			[4905] = 1,
		},
	},
	[793] = {
		["item"] = {
			[4615] = 1,
			[4645] = 1,
			[4843] = 1,
			[4845] = 1,
			[4844] = 1,
		},
	},
	[794] = {
		["item"] = {
			[4859] = 1,
		},
	},
	[795] = {
		["item"] = {
			[4843] = 1,
			[4844] = 1,
			[4845] = 1,
		},
	},
	[806] = {
		["item"] = {
			[4869] = 1,
		},
	},
	[812] = {
		["item"] = {
			[4904] = 1,
		},
	},
	[824] = {
		["item"] = {
			[16408] = 1,
		},
	},
	[826] = {
		["item"] = {
			[4866] = 1,
		},
	},
	[832] = {
		["item"] = {
			[4903] = 1,
		},
	},
	[843] = {
		["item"] = {
			[5006] = 1,
		},
	},
	[849] = {
		["object"] = {
			[3644] = 1,
		},
	},
	[850] = {
		["item"] = {
			[5022] = 1,
		},
	},
	[851] = {
		["item"] = {
			[5023] = 1,
		},
	},
	[852] = {
		["item"] = {
			[5025] = 1,
		},
	},
	[857] = {
		["item"] = {
			[5038] = 1,
		},
	},
	[858] = {
		["item"] = {
			[5050] = 1,
		},
	},
	[872] = {
		["item"] = {
			[5063] = 1,
		},
	},
	[873] = {
		["item"] = {
			[5104] = 1,
		},
	},
	[876] = {
		["item"] = {
			[5067] = 1,
		},
	},
	[877] = {
		["object"] = {
			[3737] = 1,
		},
	},
	[879] = {
		["item"] = {
			[5074] = 1,
			[5072] = 1,
			[5073] = 1,
		},
	},
	[881] = {
		["item"] = {
			[5100] = 1,
		},
	},
	[882] = {
		["item"] = {
			[5101] = 1,
		},
		["object"] = {
			[164644] = 1,
		},
	},
	[883] = {
		["item"] = {
			[5099] = 1,
		},
	},
	[884] = {
		["item"] = {
			[5102] = 1,
		},
	},
	[885] = {
		["item"] = {
			[5103] = 1,
		},
	},
	[888] = {
		["item"] = {
			[5076] = 1,
			[5077] = 1,
		},
	},
	[891] = {
		["unit"] = {
			[3454] = 1,
			[3393] = 1,
			[3455] = 1,
		},
	},
	[895] = {
		["item"] = {
			[5084] = 1,
		},
	},
	[897] = {
		["item"] = {
			[5138] = 1,
		},
	},
	[900] = {
		["object"] = {
			[4072] = 1,
			[61936] = 1,
			[61935] = 1,
		},
	},
	[901] = {
		["item"] = {
			[5089] = 1,
		},
	},
	[905] = {
		["object"] = {
			[6907] = 1,
			[6908] = 1,
			[6906] = 1,
		},
	},
	[906] = {
		["item"] = {
			[5072] = 1,
		},
	},
	[921] = {
		["item"] = {
			[5184] = 1,
		},
		["object"] = {
			[19549] = 1,
		},
	},
	[924] = {
		["object"] = {
			[3525] = 1,
		},
	},
	[927] = {
		["item"] = {
			[5179] = 1,
		},
	},
	[929] = {
		["item"] = {
			[5639] = 1,
		},
		["object"] = {
			[19550] = 1,
		},
	},
	[932] = {
		["item"] = {
			[5221] = 1,
		},
	},
	[933] = {
		["item"] = {
			[5645] = 1,
		},
		["object"] = {
			[19551] = 1,
		},
	},
	[934] = {
		["item"] = {
			[5646] = 1,
		},
		["object"] = {
			[19552] = 1,
		},
	},
	[939] = {
		["item"] = {
			[11668] = 1,
		},
	},
	[943] = {
		["item"] = {
			[5234] = 1,
		},
	},
	[953] = {
		["object"] = {
			[17188] = 1,
			[17189] = 1,
		},
	},
	[957] = {
		["object"] = {
			[16393] = 1,
		},
	},
	[959] = {
		["item"] = {
			[5334] = 1,
		},
	},
	[963] = {
		["item"] = {
			[5382] = 1,
		},
	},
	[971] = {
		["item"] = {
			[5359] = 1,
		},
	},
	[973] = {
		["item"] = {
			[5533] = 1,
		},
	},
	[974] = {
		["unit"] = {
			[10541] = 1,
		},
	},
	[982] = {
		["item"] = {
			[12191] = 1,
			[12192] = 1,
		},
	},
	[992] = {
		["item"] = {
			[8585] = 1,
		},
		["object"] = {
			[174796] = 1,
		},
	},
	[1007] = {
		["item"] = {
			[5424] = 1,
		},
	},
	[1009] = {
		["item"] = {
			[5445] = 1,
		},
	},
	[1012] = {
		["unit"] = {
			[3940] = 1,
			[3942] = 1,
			[3941] = 1,
		},
	},
	[1017] = {
		["item"] = {
			[5537] = 1,
		},
	},
	[1022] = {
		["object"] = {
			[19027] = 1,
		},
	},
	[1023] = {
		["item"] = {
			[5505] = 1,
		},
	},
	[1026] = {
		["item"] = {
			[5464] = 1,
		},
	},
	[1031] = {
		["item"] = {
			[5461] = 1,
		},
	},
	[1035] = {
		["item"] = {
			[5508] = 1,
		},
	},
	[1038] = {
		["item"] = {
			[5520] = 1,
		},
	},
	[1043] = {
		["object"] = {
			[19030] = 1,
		},
	},
	[1045] = {
		["item"] = {
			[5388] = 1,
		},
		["unit"] = {
			[3696] = 1,
		},
	},
	[1046] = {
		["item"] = {
			[5388] = 1,
		},
	},
	[1051] = {
		["item"] = {
			[5538] = 1,
		},
	},
	[1054] = {
		["item"] = {
			[5544] = 1,
		},
	},
	[1068] = {
		["unit"] = {
			[4073] = 1,
			[4074] = 1,
		},
	},
	[1079] = {
		["item"] = {
			[5718] = 1,
		},
		["object"] = {
			[19591] = 1,
			[19600] = 1,
		},
	},
	[1080] = {
		["item"] = {
			[5717] = 1,
		},
	},
	[1088] = {
		["item"] = {
			[5686] = 1,
		},
	},
	[1089] = {
		["item"] = {
			[5689] = 1,
			[5687] = 1,
			[5691] = 1,
			[5690] = 1,
		},
	},
	[1091] = {
		["item"] = {
			[5717] = 1,
		},
	},
	[1096] = {
		["item"] = {
			[5736] = 1,
		},
	},
	[1126] = {
		["item"] = {
			[17345] = 1,
		},
	},
	[1131] = {
		["item"] = {
			[5837] = 1,
		},
	},
	[1136] = {
		["item"] = {
			[5811] = 1,
		},
		["object"] = {
			[19876] = 1,
		},
	},
	[1140] = {
		["object"] = {
			[19901] = 1,
			[20352] = 1,
		},
	},
	[1143] = {
		["item"] = {
			[5383] = 1,
		},
	},
	[1150] = {
		["item"] = {
			[5843] = 1,
		},
	},
	[1151] = {
		["item"] = {
			[5844] = 1,
		},
	},
	[1154] = {
		["item"] = {
			[5860] = 1,
		},
	},
	[1164] = {
		["item"] = {
			[5830] = 1,
			[5831] = 1,
			[5832] = 1,
		},
	},
	[1166] = {
		["item"] = {
			[5836] = 1,
			[5834] = 1,
			[5835] = 1,
		},
	},
	[1182] = {
		["item"] = {
			[5851] = 1,
			[5852] = 1,
		},
	},
	[1183] = {
		["item"] = {
			[5852] = 1,
		},
	},
	[1187] = {
		["item"] = {
			[5862] = 1,
		},
	},
	[1188] = {
		["item"] = {
			[5862] = 1,
		},
	},
	[1195] = {
		["item"] = {
			[5868] = 1,
		},
		["object"] = {
			[20806] = 1,
		},
	},
	[1196] = {
		["item"] = {
			[5868] = 1,
		},
	},
	[1197] = {
		["item"] = {
			[5868] = 1,
			[5869] = 1,
		},
	},
	[1202] = {
		["item"] = {
			[5882] = 1,
		},
	},
	[1203] = {
		["item"] = {
			[33110] = 1,
		},
	},
	[1205] = {
		["item"] = {
			[5945] = 1,
		},
	},
	[1221] = {
		["item"] = {
			[5897] = 1,
			[5880] = 1,
			[6684] = 1,
		},
	},
	[1244] = {
		["item"] = {
			[5947] = 1,
		},
	},
	[1245] = {
		["item"] = {
			[5947] = 1,
		},
	},
	[1360] = {
		["item"] = {
			[8027] = 1,
		},
	},
	[1365] = {
		["item"] = {
			[6066] = 1,
		},
	},
	[1373] = {
		["item"] = {
			[6190] = 1,
		},
	},
	[1374] = {
		["item"] = {
			[6072] = 1,
		},
	},
	[1375] = {
		["item"] = {
			[6073] = 1,
		},
	},
	[1380] = {
		["item"] = {
			[6077] = 1,
		},
	},
	[1381] = {
		["item"] = {
			[6077] = 1,
		},
	},
	[1383] = {
		["item"] = {
			[6081] = 1,
		},
	},
	[1392] = {
		["item"] = {
			[6196] = 1,
		},
	},
	[1421] = {
		["item"] = {
			[6170] = 1,
		},
	},
	[1439] = {
		["item"] = {
			[6767] = 1,
		},
	},
	[1473] = {
		["item"] = {
			[6285] = 1,
		},
	},
	[1476] = {
		["item"] = {
			[6312] = 1,
			[6313] = 1,
		},
	},
	[1488] = {
		["unit"] = {
			[5771] = 1,
			[5760] = 1,
		},
	},
	[1501] = {
		["item"] = {
			[6535] = 1,
		},
	},
	[1503] = {
		["item"] = {
			[6534] = 1,
		},
	},
	[1504] = {
		["object"] = {
			[105576] = 1,
		},
	},
	[1513] = {
		["object"] = {
			[105576] = 1,
		},
	},
	[1526] = {
		["item"] = {
			[6655] = 1,
		},
	},
	[1534] = {
		["object"] = {
			[300148] = 1,
		},
	},
	[1535] = {
		["object"] = {
			[300146] = 1,
		},
	},
	[1536] = {
		["object"] = {
			[300147] = 1,
		},
	},
	[1598] = {
		["item"] = {
			[6785] = 1,
		},
	},
	[1655] = {
		["item"] = {
			[6992] = 1,
		},
	},
	[1657] = {
		["object"] = {
			[300054] = 1,
		},
		["unit"] = {
			[15415] = 1,
		},
	},
	[1667] = {
		["item"] = {
			[6782] = 1,
			[6783] = 1,
		},
	},
	[1678] = {
		["item"] = {
			[6799] = 1,
		},
	},
	[1681] = {
		["item"] = {
			[6800] = 1,
		},
	},
	[1683] = {
		["item"] = {
			[6805] = 1,
		},
	},
	[1686] = {
		["item"] = {
			[6809] = 1,
		},
	},
	[1688] = {
		["item"] = {
			[6810] = 1,
		},
	},
	[1689] = {
		["object"] = {
			[92015] = 1,
		},
	},
	[1701] = {
		["item"] = {
			[6840] = 1,
		},
	},
	[1705] = {
		["item"] = {
			[6845] = 1,
		},
	},
	[1713] = {
		["item"] = {
			[6894] = 1,
		},
	},
	[1719] = {
		["unit"] = {
			[6238] = 1,
		},
	},
	[1738] = {
		["item"] = {
			[6912] = 1,
		},
	},
	[1739] = {
		["object"] = {
			[92015] = 1,
		},
	},
	[1783] = {
		["unit"] = {
			[6177] = 1,
		},
	},
	[1786] = {
		["unit"] = {
			[6172] = 1,
		},
	},
	[1795] = {
		["object"] = {
			[92388] = 1,
		},
		["unit"] = {
			[6268] = 1,
		},
	},
	[1802] = {
		["item"] = {
			[6931] = 1,
			[6997] = 1,
		},
		["object"] = {
			[92388] = 1,
		},
	},
	[1803] = {
		["item"] = {
			[6931] = 1,
			[6997] = 1,
		},
		["object"] = {
			[92388] = 1,
		},
	},
	[1819] = {
		["unit"] = {
			[6390] = 1,
		},
	},
	[1821] = {
		["item"] = {
			[7567] = 1,
			[7568] = 1,
			[7566] = 1,
			[7569] = 1,
		},
	},
	[1844] = {
		["item"] = {
			[6840] = 1,
		},
	},
	[1858] = {
		["item"] = {
			[7208] = 1,
			[7209] = 1,
		},
	},
	[1861] = {
		["item"] = {
			[7206] = 1,
		},
		["object"] = {
			[174794] = 1,
		},
	},
	[1880] = {
		["item"] = {
			[7226] = 1,
		},
	},
	[1886] = {
		["item"] = {
			[7231] = 1,
		},
	},
	[1898] = {
		["item"] = {
			[7231] = 1,
		},
	},
	[1899] = {
		["item"] = {
			[7294] = 1,
		},
	},
	[1918] = {
		["item"] = {
			[16408] = 1,
		},
	},
	[1920] = {
		["object"] = {
			[300013] = 1,
		},
	},
	[1938] = {
		["item"] = {
			[7266] = 1,
		},
	},
	[1944] = {
		["item"] = {
			[7268] = 1,
		},
		["object"] = {
			[174797] = 1,
		},
	},
	[1948] = {
		["item"] = {
			[7272] = 1,
		},
		["object"] = {
			[300012] = 1,
		},
	},
	[1955] = {
		["unit"] = {
			[6549] = 1,
		},
	},
	[1957] = {
		["unit"] = {
			[6550] = 1,
		},
	},
	[1960] = {
		["object"] = {
			[300013] = 1,
		},
	},
	[1963] = {
		["item"] = {
			[7209] = 1,
		},
	},
	[1978] = {
		["item"] = {
			[7294] = 1,
		},
	},
	[1998] = {
		["item"] = {
			[7306] = 1,
		},
	},
	[1999] = {
		["item"] = {
			[7309] = 1,
		},
	},
	[2038] = {
		["item"] = {
			[7345] = 1,
			[7343] = 1,
			[7376] = 1,
			[7346] = 1,
		},
	},
	[2078] = {
		["unit"] = {
			[6669] = 1,
		},
	},
	[2139] = {
		["unit"] = {
			[6788] = 1,
		},
	},
	[2206] = {
		["item"] = {
			[7675] = 1,
		},
	},
	[2242] = {
		["item"] = {
			[7737] = 1,
		},
	},
	[2282] = {
		["item"] = {
			[7871] = 1,
		},
	},
	[2342] = {
		["item"] = {
			[8026] = 1,
		},
	},
	[2359] = {
		["item"] = {
			[7908] = 1,
			[7923] = 1,
		},
	},
	[2381] = {
		["item"] = {
			[7968] = 1,
		},
	},
	[2438] = {
		["item"] = {
			[8048] = 1,
		},
	},
	[2459] = {
		["item"] = {
			[8049] = 1,
		},
	},
	[2478] = {
		["item"] = {
			[8074] = 1,
			[8072] = 1,
			[8073] = 1,
		},
	},
	[2499] = {
		["item"] = {
			[8136] = 1,
		},
	},
	[2520] = {
		["object"] = {
			[138498] = 1,
		},
	},
	[2561] = {
		["item"] = {
			[8149] = 1,
		},
		["unit"] = {
			[7318] = 1,
		},
	},
	[2623] = {
		["item"] = {
			[8463] = 1,
		},
	},
	[2746] = {
		["item"] = {
			[8683] = 1,
		},
	},
	[2781] = {
		["item"] = {
			[8723] = 1,
		},
	},
	[2845] = {
		["item"] = {
			[9189] = 1,
		},
	},
	[2870] = {
		["item"] = {
			[9248] = 1,
		},
	},
	[2871] = {
		["item"] = {
			[9248] = 1,
		},
	},
	[2875] = {
		["item"] = {
			[9246] = 1,
		},
	},
	[2879] = {
		["item"] = {
			[9256] = 1,
			[9257] = 1,
			[9258] = 1,
			[9255] = 1,
			[9306] = 1,
		},
		["object"] = {
			[300138] = 1,
		},
	},
	[2922] = {
		["item"] = {
			[9277] = 1,
		},
	},
	[2937] = {
		["item"] = {
			[9324] = 1,
		},
		["object"] = {
			[300017] = 1,
		},
	},
	[2942] = {
		["item"] = {
			[9306] = 1,
		},
	},
	[2944] = {
		["item"] = {
			[9330] = 1,
		},
	},
	[2988] = {
		["object"] = {
			[144067] = 1,
			[144066] = 1,
			[144068] = 1,
		},
	},
	[2994] = {
		["item"] = {
			[9472] = 1,
		},
		["object"] = {
			[144070] = 1,
		},
	},
	[2995] = {
		["object"] = {
			[144073] = 1,
			[144072] = 1,
			[144071] = 1,
		},
	},
	[3062] = {
		["item"] = {
			[9528] = 1,
		},
		["object"] = {
			[300018] = 1,
		},
	},
	[3281] = {
		["item"] = {
			[5061] = 1,
		},
	},
	[3361] = {
		["item"] = {
			[16314] = 1,
			[16313] = 1,
			[10438] = 1,
		},
	},
	[3372] = {
		["item"] = {
			[10442] = 1,
		},
	},
	[3374] = {
		["item"] = {
			[10589] = 1,
		},
	},
	[3376] = {
		["item"] = {
			[10459] = 1,
		},
	},
	[3385] = {
		["item"] = {
			[10467] = 1,
		},
		["unit"] = {
			[8444] = 1,
			[8447] = 1,
		},
	},
	[3444] = {
		["item"] = {
			[10556] = 1,
		},
	},
	[3449] = {
		["item"] = {
			[10563] = 1,
			[10565] = 1,
			[10564] = 1,
			[10566] = 1,
		},
	},
	[3463] = {
		["object"] = {
			[149032] = 1,
			[149025] = 1,
			[149030] = 1,
			[149031] = 1,
		},
	},
	[3506] = {
		["item"] = {
			[10597] = 1,
		},
	},
	[3507] = {
		["item"] = {
			[10597] = 1,
		},
	},
	[3510] = {
		["item"] = {
			[10599] = 1,
			[10598] = 1,
			[10600] = 1,
		},
	},
	[3513] = {
		["item"] = {
			[10621] = 1,
		},
	},
	[3514] = {
		["unit"] = {
			[8518] = 1,
		},
	},
	[3524] = {
		["item"] = {
			[12242] = 1,
		},
	},
	[3566] = {
		["item"] = {
			[10446] = 1,
			[10447] = 1,
		},
	},
	[3627] = {
		["item"] = {
			[10755] = 1,
			[10754] = 1,
			[10753] = 1,
		},
	},
	[3628] = {
		["item"] = {
			[10759] = 1,
		},
	},
	[3822] = {
		["item"] = {
			[11058] = 1,
		},
	},
	[3824] = {
		["item"] = {
			[11080] = 1,
		},
	},
	[3825] = {
		["object"] = {
			[160840] = 1,
		},
	},
	[3861] = {
		["item"] = {
			[11109] = 1,
		},
	},
	[3881] = {
		["item"] = {
			[11112] = 1,
			[11113] = 1,
		},
	},
	[3883] = {
		["item"] = {
			[11131] = 1,
		},
		["object"] = {
			[174793] = 1,
		},
	},
	[3906] = {
		["unit"] = {
			[9026] = 1,
		},
	},
	[3909] = {
		["object"] = {
			[300021] = 1,
		},
	},
	[3924] = {
		["item"] = {
			[11147] = 1,
		},
	},
	[3961] = {
		["item"] = {
			[11522] = 1,
		},
	},
	[3962] = {
		["item"] = {
			[11179] = 1,
			[11522] = 1,
		},
		["unit"] = {
			[9376] = 1,
		},
	},
	[4005] = {
		["item"] = {
			[11522] = 1,
		},
		["object"] = {
			[148507] = 1,
		},
	},
	[4201] = {
		["object"] = {
			[300023] = 1,
		},
	},
	[4262] = {
		["unit"] = {
			[9026] = 1,
		},
	},
	[4290] = {
		["item"] = {
			[11504] = 1,
		},
	},
	[4292] = {
		["item"] = {
			[11510] = 1,
		},
	},
	[4293] = {
		["item"] = {
			[12234] = 1,
		},
	},
	[4294] = {
		["item"] = {
			[12236] = 1,
		},
	},
	[4295] = {
		["item"] = {
			[11325] = 1,
		},
	},
	[4296] = {
		["item"] = {
			[11470] = 1,
		},
	},
	[4301] = {
		["item"] = {
			[11476] = 1,
		},
	},
	[4421] = {
		["unit"] = {
			[9454] = 1,
		},
	},
	[4441] = {
		["item"] = {
			[5646] = 1,
		},
		["object"] = {
			[138498] = 1,
		},
	},
	[4450] = {
		["item"] = {
			[11727] = 1,
			[11723] = 1,
			[11724] = 1,
		},
	},
	[4505] = {
		["object"] = {
			[300025] = 1,
		},
	},
	[4506] = {
		["object"] = {
			[300025] = 1,
		},
	},
	[4507] = {
		["item"] = {
			[11835] = 1,
		},
		["object"] = {
			[174792] = 1,
		},
	},
	[4621] = {
		["unit"] = {
			[2487] = 1,
			[2496] = 1,
		},
	},
	[4681] = {
		["item"] = {
			[12289] = 1,
		},
	},
	[4722] = {
		["item"] = {
			[12289] = 1,
		},
	},
	[4723] = {
		["item"] = {
			[12242] = 1,
		},
	},
	[4727] = {
		["item"] = {
			[12289] = 1,
		},
	},
	[4728] = {
		["item"] = {
			[12242] = 1,
		},
	},
	[4730] = {
		["item"] = {
			[12242] = 1,
		},
	},
	[4732] = {
		["item"] = {
			[12289] = 1,
		},
	},
	[4733] = {
		["item"] = {
			[12242] = 1,
		},
	},
	[4740] = {
		["unit"] = {
			[10323] = 1,
		},
	},
	[4743] = {
		["item"] = {
			[12324] = 1,
		},
	},
	[4762] = {
		["object"] = {
			[300132] = 1,
		},
	},
	[4763] = {
		["item"] = {
			[12342] = 1,
			[12341] = 1,
			[12343] = 1,
		},
		["object"] = {
			[174795] = 1,
		},
	},
	[4784] = {
		["item"] = {
			[12293] = 1,
		},
	},
	[4787] = {
		["item"] = {
			[12402] = 1,
		},
	},
	[4812] = {
		["item"] = {
			[14339] = 1,
		},
		["object"] = {
			[174795] = 1,
		},
	},
	[4881] = {
		["item"] = {
			[12564] = 1,
		},
	},
	[4903] = {
		["item"] = {
			[12562] = 1,
		},
	},
	[4906] = {
		["unit"] = {
			[10648] = 1,
		},
	},
	[4921] = {
		["unit"] = {
			[10668] = 1,
		},
	},
	[4961] = {
		["unit"] = {
			[6549] = 1,
		},
	},
	[5051] = {
		["item"] = {
			[12722] = 1,
		},
	},
	[5054] = {
		["unit"] = {
			[10806] = 1,
		},
	},
	[5055] = {
		["unit"] = {
			[10807] = 1,
		},
	},
	[5056] = {
		["object"] = {
			[300027] = 1,
		},
		["unit"] = {
			[10737] = 1,
		},
	},
	[5059] = {
		["item"] = {
			[12738] = 1,
		},
	},
	[5060] = {
		["item"] = {
			[12739] = 1,
		},
	},
	[5064] = {
		["item"] = {
			[12765] = 1,
			[12766] = 1,
			[12768] = 1,
		},
	},
	[5065] = {
		["item"] = {
			[12411] = 1,
			[12412] = 1,
		},
	},
	[5088] = {
		["item"] = {
			[12925] = 1,
		},
	},
	[5096] = {
		["item"] = {
			[12814] = 1,
		},
		["object"] = {
			[300029] = 1,
		},
	},
	[5097] = {
		["unit"] = {
			[10902] = 1,
			[10904] = 1,
			[10903] = 1,
			[10905] = 1,
		},
	},
	[5098] = {
		["unit"] = {
			[10902] = 1,
			[10904] = 1,
			[10903] = 1,
			[10905] = 1,
		},
	},
	[5121] = {
		["unit"] = {
			[10738] = 1,
		},
	},
	[5123] = {
		["item"] = {
			[12842] = 1,
		},
	},
	[5128] = {
		["item"] = {
			[12842] = 1,
		},
	},
	[5147] = {
		["item"] = {
			[12884] = 1,
		},
	},
	[5151] = {
		["item"] = {
			[12946] = 1,
		},
	},
	[5153] = {
		["item"] = {
			[12894] = 1,
		},
	},
	[5154] = {
		["item"] = {
			[12900] = 1,
		},
	},
	[5157] = {
		["item"] = {
			[12907] = 1,
		},
		["object"] = {
			[176184] = 1,
		},
	},
	[5158] = {
		["item"] = {
			[12907] = 1,
		},
	},
	[5163] = {
		["unit"] = {
			[10977] = 1,
			[7583] = 1,
			[10978] = 1,
		},
	},
	[5165] = {
		["object"] = {
			[176158] = 1,
			[176160] = 1,
			[176159] = 1,
			[176161] = 1,
		},
	},
	[5168] = {
		["item"] = {
			[12954] = 1,
			[12955] = 1,
		},
	},
	[5181] = {
		["item"] = {
			[12956] = 1,
			[12957] = 1,
		},
	},
	[5204] = {
		["unit"] = {
			[9518] = 1,
		},
	},
	[5216] = {
		["item"] = {
			[13194] = 1,
		},
	},
	[5219] = {
		["item"] = {
			[13195] = 1,
		},
	},
	[5222] = {
		["item"] = {
			[13197] = 1,
		},
	},
	[5225] = {
		["item"] = {
			[13196] = 1,
		},
	},
	[5229] = {
		["item"] = {
			[13194] = 1,
		},
	},
	[5231] = {
		["item"] = {
			[13195] = 1,
		},
	},
	[5233] = {
		["item"] = {
			[13197] = 1,
		},
	},
	[5235] = {
		["item"] = {
			[13196] = 1,
		},
	},
	[5242] = {
		["item"] = {
			[13207] = 1,
		},
		["unit"] = {
			[9860] = 1,
			[9861] = 1,
		},
	},
	[5245] = {
		["item"] = {
			[12897] = 1,
			[12896] = 1,
			[12898] = 1,
			[12899] = 1,
		},
	},
	[5246] = {
		["item"] = {
			[13313] = 1,
		},
	},
	[5247] = {
		["item"] = {
			[16973] = 1,
		},
	},
	[5321] = {
		["item"] = {
			[13536] = 1,
		},
	},
	[5342] = {
		["item"] = {
			[13469] = 1,
		},
	},
	[5344] = {
		["item"] = {
			[13470] = 1,
		},
	},
	[5381] = {
		["item"] = {
			[13542] = 1,
		},
	},
	[5386] = {
		["item"] = {
			[13546] = 1,
		},
	},
	[5461] = {
		["item"] = {
			[13585] = 1,
		},
	},
	[5462] = {
		["item"] = {
			[13585] = 1,
		},
	},
	[5463] = {
		["item"] = {
			[13585] = 1,
		},
	},
	[5527] = {
		["item"] = {
			[22201] = 1,
		},
	},
	[5541] = {
		["item"] = {
			[13850] = 1,
		},
	},
	[5621] = {
		["unit"] = {
			[12429] = 1,
		},
	},
	[5624] = {
		["unit"] = {
			[12423] = 1,
		},
	},
	[5625] = {
		["unit"] = {
			[12427] = 1,
		},
	},
	[5648] = {
		["unit"] = {
			[12430] = 1,
		},
	},
	[5650] = {
		["unit"] = {
			[12428] = 1,
		},
	},
	[5721] = {
		["object"] = {
			[944] = 1,
			[300034] = 1,
		},
		["unit"] = {
			[10936] = 1,
		},
	},
	[5741] = {
		["item"] = {
			[15750] = 1,
		},
	},
	[5781] = {
		["item"] = {
			[14613] = 1,
		},
	},
	[5801] = {
		["item"] = {
			[14645] = 1,
		},
		["object"] = {
			[4004] = 1,
		},
	},
	[5802] = {
		["item"] = {
			[14645] = 1,
		},
		["object"] = {
			[4004] = 1,
		},
	},
	[5803] = {
		["item"] = {
			[14610] = 1,
		},
	},
	[5804] = {
		["item"] = {
			[14610] = 1,
		},
	},
	[5845] = {
		["item"] = {
			[14625] = 1,
		},
	},
	[5863] = {
		["unit"] = {
			[12046] = 1,
		},
	},
	[6021] = {
		["item"] = {
			[15785] = 1,
		},
	},
	[6023] = {
		["unit"] = {
			[11611] = 1,
			[11613] = 1,
		},
	},
	[6024] = {
		["item"] = {
			[15767] = 1,
		},
	},
	[6027] = {
		["item"] = {
			[15803] = 1,
		},
	},
	[6122] = {
		["item"] = {
			[15845] = 1,
		},
		["object"] = {
			[19463] = 1,
		},
	},
	[6127] = {
		["item"] = {
			[15843] = 1,
		},
		["object"] = {
			[19464] = 1,
		},
	},
	[6133] = {
		["item"] = {
			[15847] = 1,
		},
	},
	[6134] = {
		["item"] = {
			[15849] = 1,
		},
		["object"] = {
			[300036] = 1,
		},
	},
	[6135] = {
		["item"] = {
			[15850] = 1,
		},
	},
	[6136] = {
		["unit"] = {
			[11896] = 1,
		},
	},
	[6145] = {
		["item"] = {
			[15868] = 1,
		},
	},
	[6162] = {
		["item"] = {
			[15879] = 1,
		},
	},
	[6164] = {
		["item"] = {
			[15884] = 1,
		},
	},
	[6185] = {
		["item"] = {
			[16002] = 1,
			[16001] = 1,
			[16003] = 1,
		},
	},
	[6187] = {
		["unit"] = {
			[11878] = 1,
		},
	},
	[6283] = {
		["item"] = {
			[16190] = 1,
		},
	},
	[6394] = {
		["item"] = {
			[16332] = 1,
		},
	},
	[6395] = {
		["item"] = {
			[16333] = 1,
		},
		["object"] = {
			[178090] = 1,
		},
	},
	[6481] = {
		["unit"] = {
			[11920] = 1,
		},
	},
	[6564] = {
		["item"] = {
			[16790] = 1,
		},
	},
	[6571] = {
		["item"] = {
			[16745] = 1,
		},
	},
	[6582] = {
		["item"] = {
			[16869] = 1,
		},
	},
	[6583] = {
		["item"] = {
			[16870] = 1,
		},
	},
	[6584] = {
		["item"] = {
			[16871] = 1,
		},
	},
	[6585] = {
		["item"] = {
			[16872] = 1,
		},
	},
	[6621] = {
		["item"] = {
			[16976] = 1,
		},
		["object"] = {
			[300131] = 1,
		},
	},
	[6629] = {
		["unit"] = {
			[11858] = 1,
		},
	},
	[6681] = {
		["unit"] = {
			[13936] = 1,
		},
	},
	[6825] = {
		["item"] = {
			[17326] = 1,
		},
	},
	[6826] = {
		["item"] = {
			[17327] = 1,
		},
	},
	[6827] = {
		["item"] = {
			[17328] = 1,
		},
	},
	[6861] = {
		["item"] = {
			[17411] = 1,
		},
	},
	[6862] = {
		["item"] = {
			[17411] = 1,
		},
	},
	[6941] = {
		["item"] = {
			[17503] = 1,
		},
	},
	[6942] = {
		["item"] = {
			[17502] = 1,
		},
	},
	[6943] = {
		["item"] = {
			[17504] = 1,
		},
	},
	[7029] = {
		["object"] = {
			[300048] = 1,
		},
	},
	[7041] = {
		["object"] = {
			[300048] = 1,
		},
	},
	[7067] = {
		["item"] = {
			[17757] = 1,
		},
	},
	[7161] = {
		["item"] = {
			[17850] = 1,
		},
	},
	[7162] = {
		["item"] = {
			[17849] = 1,
		},
	},
	[7181] = {
		["unit"] = {
			[12159] = 1,
		},
	},
	[7202] = {
		["unit"] = {
			[12159] = 1,
		},
	},
	[7281] = {
		["unit"] = {
			[13320] = 1,
		},
	},
	[7282] = {
		["unit"] = {
			[13154] = 1,
		},
	},
	[7301] = {
		["unit"] = {
			[14031] = 1,
			[14030] = 1,
			[14029] = 1,
		},
	},
	[7302] = {
		["unit"] = {
			[14028] = 1,
			[14027] = 1,
			[14026] = 1,
		},
	},
	[7367] = {
		["unit"] = {
			[13597] = 1,
		},
	},
	[7368] = {
		["unit"] = {
			[13598] = 1,
		},
	},
	[7381] = {
		["item"] = {
			[18148] = 1,
		},
	},
	[7382] = {
		["item"] = {
			[18148] = 1,
		},
	},
	[7383] = {
		["item"] = {
			[18151] = 1,
		},
		["object"] = {
			[19552] = 1,
		},
	},
	[7603] = {
		["item"] = {
			[18625] = 1,
		},
		["object"] = {
			[300049] = 1,
		},
	},
	[7624] = {
		["item"] = {
			[18719] = 1,
		},
	},
	[7625] = {
		["item"] = {
			[18687] = 1,
		},
	},
	[7660] = {
		["item"] = {
			[12351] = 1,
		},
	},
	[7661] = {
		["item"] = {
			[12330] = 1,
		},
	},
	[7662] = {
		["item"] = {
			[15293] = 1,
		},
	},
	[7663] = {
		["item"] = {
			[15292] = 1,
		},
	},
	[7664] = {
		["item"] = {
			[13317] = 1,
		},
	},
	[7665] = {
		["item"] = {
			[8586] = 1,
		},
	},
	[7671] = {
		["item"] = {
			[12302] = 1,
		},
	},
	[7672] = {
		["item"] = {
			[12303] = 1,
		},
	},
	[7673] = {
		["item"] = {
			[13329] = 1,
		},
	},
	[7674] = {
		["item"] = {
			[13328] = 1,
		},
	},
	[7675] = {
		["item"] = {
			[13327] = 1,
		},
	},
	[7676] = {
		["item"] = {
			[13326] = 1,
		},
	},
	[7701] = {
		["item"] = {
			[18946] = 1,
		},
	},
	[7722] = {
		["item"] = {
			[18922] = 1,
		},
	},
	[7731] = {
		["item"] = {
			[18962] = 1,
		},
	},
	[7810] = {
		["item"] = {
			[18706] = 1,
		},
	},
	[7816] = {
		["item"] = {
			[19023] = 1,
		},
	},
	[7838] = {
		["item"] = {
			[18706] = 1,
		},
	},
	[7840] = {
		["item"] = {
			[19034] = 1,
		},
	},
	[7843] = {
		["object"] = {
			[179912] = 1,
		},
	},
	[7846] = {
		["item"] = {
			[19064] = 1,
		},
	},
	[7849] = {
		["item"] = {
			[19069] = 1,
			[19070] = 1,
		},
	},
	[7861] = {
		["unit"] = {
			[7995] = 1,
		},
	},
	[7946] = {
		["item"] = {
			[11325] = 1,
		},
	},
	[8066] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8067] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8068] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8069] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8070] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8071] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8072] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8073] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8074] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8075] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8076] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8077] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8078] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8079] = {
		["object"] = {
			[300053] = 1,
		},
	},
	[8105] = {
		["unit"] = {
			[15003] = 1,
			[15002] = 1,
			[15004] = 1,
			[15005] = 1,
		},
	},
	[8120] = {
		["unit"] = {
			[15004] = 1,
			[15005] = 1,
			[15001] = 1,
			[15002] = 1,
		},
	},
	[8166] = {
		["unit"] = {
			[15003] = 1,
			[15002] = 1,
			[15004] = 1,
			[15005] = 1,
		},
	},
	[8167] = {
		["unit"] = {
			[15003] = 1,
			[15002] = 1,
			[15004] = 1,
			[15005] = 1,
		},
	},
	[8168] = {
		["unit"] = {
			[15003] = 1,
			[15002] = 1,
			[15004] = 1,
			[15005] = 1,
		},
	},
	[8169] = {
		["unit"] = {
			[15004] = 1,
			[15005] = 1,
			[15001] = 1,
			[15002] = 1,
		},
	},
	[8170] = {
		["unit"] = {
			[15004] = 1,
			[15005] = 1,
			[15001] = 1,
			[15002] = 1,
		},
	},
	[8171] = {
		["unit"] = {
			[15004] = 1,
			[15005] = 1,
			[15001] = 1,
			[15002] = 1,
		},
	},
	[8185] = {
		["item"] = {
			[19815] = 1,
		},
	},
	[8279] = {
		["item"] = {
			[20396] = 1,
			[20394] = 1,
			[20395] = 1,
		},
	},
	[8282] = {
		["item"] = {
			[20379] = 1,
		},
	},
	[8283] = {
		["item"] = {
			[20385] = 1,
		},
	},
	[8304] = {
		["unit"] = {
			[15221] = 1,
			[15222] = 1,
		},
	},
	[8306] = {
		["unit"] = {
			[15215] = 1,
		},
	},
	[8309] = {
		["item"] = {
			[20456] = 1,
			[20454] = 1,
			[20455] = 1,
		},
	},
	[8315] = {
		["item"] = {
			[20465] = 1,
		},
		["object"] = {
			[300055] = 1,
		},
	},
	[8321] = {
		["item"] = {
			[20466] = 1,
		},
	},
	[8330] = {
		["item"] = {
			[20471] = 1,
			[20472] = 1,
			[20470] = 1,
		},
	},
	[8335] = {
		["item"] = {
			[20799] = 1,
		},
	},
	[8345] = {
		["object"] = {
			[180516] = 1,
		},
	},
	[8346] = {
		["unit"] = {
			[15468] = 1,
		},
	},
	[8373] = {
		["item"] = {
			[20604] = 1,
		},
	},
	[8468] = {
		["item"] = {
			[21781] = 1,
		},
	},
	[8477] = {
		["item"] = {
			[20759] = 1,
		},
	},
	[8479] = {
		["item"] = {
			[20760] = 1,
		},
	},
	[8481] = {
		["object"] = {
			[300141] = 1,
		},
		["item"] = {
			[21145] = 1,
		},
	},
	[8483] = {
		["item"] = {
			[20764] = 1,
		},
	},
	[8534] = {
		["item"] = {
			[21158] = 1,
		},
	},
	[8538] = {
		["unit"] = {
			[15220] = 1,
		},
	},
	[8551] = {
		["item"] = {
			[3932] = 1,
		},
	},
	[8552] = {
		["item"] = {
			[3985] = 1,
		},
	},
	[8554] = {
		["item"] = {
			[3935] = 1,
		},
	},
	[8556] = {
		["item"] = {
			[20884] = 1,
		},
	},
	[8557] = {
		["item"] = {
			[20885] = 1,
		},
	},
	[8585] = {
		["item"] = {
			[21027] = 1,
		},
	},
	[8606] = {
		["unit"] = {
			[15554] = 1,
		},
	},
	[8689] = {
		["item"] = {
			[20885] = 1,
		},
	},
	[8690] = {
		["item"] = {
			[20889] = 1,
		},
	},
	[8691] = {
		["item"] = {
			[20885] = 1,
		},
	},
	[8692] = {
		["item"] = {
			[20889] = 1,
		},
	},
	[8693] = {
		["item"] = {
			[20885] = 1,
		},
	},
	[8694] = {
		["item"] = {
			[20889] = 1,
		},
	},
	[8695] = {
		["item"] = {
			[20889] = 1,
		},
	},
	[8696] = {
		["item"] = {
			[20889] = 1,
		},
	},
	[8697] = {
		["item"] = {
			[20888] = 1,
		},
	},
	[8698] = {
		["item"] = {
			[20884] = 1,
		},
	},
	[8699] = {
		["item"] = {
			[20884] = 1,
		},
	},
	[8700] = {
		["item"] = {
			[20884] = 1,
		},
	},
	[8701] = {
		["item"] = {
			[20888] = 1,
		},
	},
	[8702] = {
		["item"] = {
			[20888] = 1,
		},
	},
	[8703] = {
		["item"] = {
			[20884] = 1,
		},
	},
	[8704] = {
		["item"] = {
			[20888] = 1,
		},
	},
	[8729] = {
		["item"] = {
			[21137] = 1,
		},
		["object"] = {
			[300057] = 1,
		},
	},
	[8735] = {
		["item"] = {
			[21149] = 1,
		},
	},
	[8738] = {
		["item"] = {
			[21160] = 1,
		},
	},
	[8739] = {
		["item"] = {
			[21161] = 1,
		},
	},
	[8740] = {
		["unit"] = {
			[15541] = 1,
		},
	},
	[8770] = {
		["item"] = {
			[21749] = 1,
		},
	},
	[8867] = {
		["unit"] = {
			[15893] = 1,
			[15894] = 1,
		},
	},
	[8885] = {
		["item"] = {
			[21770] = 1,
		},
	},
	[8889] = {
		["object"] = {
			[180919] = 1,
			[180920] = 1,
			[180916] = 1,
		},
	},
	[8910] = {
		["item"] = {
			[16710] = 1,
		},
	},
	[8911] = {
		["item"] = {
			[16703] = 1,
		},
	},
	[8917] = {
		["item"] = {
			[16710] = 1,
		},
	},
	[8919] = {
		["item"] = {
			[16703] = 1,
		},
	},
	[8925] = {
		["item"] = {
			[21938] = 1,
		},
	},
	[8928] = {
		["item"] = {
			[21939] = 1,
		},
	},
	[8933] = {
		["item"] = {
			[16723] = 1,
		},
	},
	[8935] = {
		["item"] = {
			[16713] = 1,
		},
	},
	[8941] = {
		["item"] = {
			[16713] = 1,
		},
	},
	[8942] = {
		["item"] = {
			[16673] = 1,
		},
	},
	[8951] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8952] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8953] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8954] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8955] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8956] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8957] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8958] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[8959] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9015] = {
		["item"] = {
			[22047] = 1,
		},
		["unit"] = {
			[16059] = 1,
		},
	},
	[9016] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9017] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9018] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9019] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9020] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9021] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9022] = {
		["item"] = {
			[22047] = 1,
		},
	},
	[9062] = {
		["item"] = {
			[22414] = 1,
		},
	},
	[9066] = {
		["unit"] = {
			[15941] = 1,
			[15945] = 1,
		},
	},
	[9067] = {
		["item"] = {
			[22775] = 1,
			[22776] = 1,
			[22777] = 1,
		},
	},
	[9076] = {
		["item"] = {
			[22487] = 1,
		},
	},
	[9085] = {
		["unit"] = {
			[16143] = 1,
		},
	},
	[9094] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9152] = {
		["item"] = {
			[22583] = 1,
		},
	},
	[9153] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9156] = {
		["item"] = {
			[22893] = 1,
			[22894] = 1,
		},
	},
	[9163] = {
		["item"] = {
			[22591] = 1,
			[22592] = 1,
		},
	},
	[9164] = {
		["unit"] = {
			[16206] = 1,
			[16208] = 1,
			[16209] = 1,
		},
	},
	[9167] = {
		["item"] = {
			[22653] = 1,
		},
	},
	[9169] = {
		["object"] = {
			[181359] = 1,
		},
	},
	[9170] = {
		["unit"] = {
			[16248] = 1,
			[16250] = 1,
		},
	},
	[9174] = {
		["unit"] = {
			[16292] = 1,
		},
	},
	[9176] = {
		["item"] = {
			[22598] = 1,
			[22599] = 1,
		},
	},
	[9206] = {
		["item"] = {
			[22624] = 1,
		},
	},
	[9215] = {
		["item"] = {
			[22640] = 1,
		},
	},
	[9268] = {
		["item"] = {
			[3466] = 1,
		},
	},
	[9275] = {
		["object"] = {
			[181252] = 1,
			[181251] = 1,
			[181250] = 1,
		},
	},
	[9294] = {
		["object"] = {
			[181433] = 1,
		},
	},
	[9311] = {
		["unit"] = {
			[16522] = 1,
		},
	},
	[9315] = {
		["unit"] = {
			[16357] = 1,
		},
	},
	[9317] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9318] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9320] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9321] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9324] = {
		["item"] = {
			[23179] = 1,
		},
	},
	[9325] = {
		["item"] = {
			[23180] = 1,
		},
	},
	[9326] = {
		["item"] = {
			[23181] = 1,
		},
	},
	[9330] = {
		["item"] = {
			[23182] = 1,
		},
	},
	[9331] = {
		["item"] = {
			[23183] = 1,
		},
	},
	[9332] = {
		["item"] = {
			[23184] = 1,
		},
	},
	[9333] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9334] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9335] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9336] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9337] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9341] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9343] = {
		["item"] = {
			[22484] = 1,
		},
	},
	[9362] = {
		["item"] = {
			[23250] = 1,
		},
	},
	[9364] = {
		["item"] = {
			[23250] = 1,
		},
	},
	[9367] = {
		["object"] = {
			[181333] = 1,
			[181332] = 1,
			[181334] = 1,
		},
	},
	[9368] = {
		["object"] = {
			[181336] = 1,
			[181335] = 1,
			[181337] = 1,
		},
	},
	[9370] = {
		["unit"] = {
			[16994] = 1,
		},
	},
	[9376] = {
		["item"] = {
			[23343] = 1,
		},
	},
	[9391] = {
		["object"] = {
			[181579] = 1,
			[181581] = 1,
			[181580] = 1,
		},
	},
	[9403] = {
		["item"] = {
			[23552] = 1,
		},
	},
	[9419] = {
		["unit"] = {
			[17090] = 1,
		},
	},
	[9422] = {
		["unit"] = {
			[18199] = 1,
		},
	},
	[9427] = {
		["unit"] = {
			[17000] = 1,
		},
	},
	[9433] = {
		["item"] = {
			[23670] = 1,
		},
	},
	[9435] = {
		["item"] = {
			[23646] = 1,
		},
	},
	[9437] = {
		["unit"] = {
			[17119] = 1,
		},
	},
	[9439] = {
		["item"] = {
			[23658] = 1,
			[23660] = 1,
		},
	},
	[9440] = {
		["unit"] = {
			[17111] = 1,
			[17112] = 1,
			[17113] = 1,
		},
	},
	[9443] = {
		["item"] = {
			[23661] = 1,
		},
	},
	[9444] = {
		["object"] = {
			[1323] = 1,
			[181653] = 1,
		},
	},
	[9457] = {
		["item"] = {
			[23681] = 1,
		},
	},
	[9466] = {
		["item"] = {
			[23687] = 1,
		},
	},
	[9467] = {
		["item"] = {
			[23688] = 1,
		},
	},
	[9470] = {
		["unit"] = {
			[17235] = 1,
			[17236] = 1,
		},
	},
	[9472] = {
		["unit"] = {
			[17226] = 1,
		},
	},
	[9474] = {
		["item"] = {
			[23661] = 1,
		},
	},
	[9483] = {
		["item"] = {
			[29112] = 1,
		},
	},
	[9490] = {
		["item"] = {
			[23687] = 1,
		},
	},
	[9504] = {
		["item"] = {
			[23750] = 1,
		},
	},
	[9506] = {
		["item"] = {
			[23738] = 1,
			[23739] = 1,
		},
	},
	[9508] = {
		["item"] = {
			[23997] = 1,
		},
	},
	[9515] = {
		["unit"] = {
			[17298] = 1,
		},
	},
	[9518] = {
		["unit"] = {
			[17304] = 1,
		},
	},
	[9519] = {
		["item"] = {
			[23760] = 1,
		},
	},
	[9522] = {
		["unit"] = {
			[17300] = 1,
			[6072] = 1,
		},
	},
	[9531] = {
		["unit"] = {
			[17318] = 1,
		},
	},
	[9536] = {
		["unit"] = {
			[17300] = 1,
			[6072] = 1,
		},
	},
	[9545] = {
		["unit"] = {
			[17413] = 1,
			[16852] = 1,
		},
	},
	[9548] = {
		["item"] = {
			[23830] = 1,
		},
	},
	[9563] = {
		["item"] = {
			[23848] = 1,
		},
	},
	[9567] = {
		["item"] = {
			[23859] = 1,
		},
	},
	[9569] = {
		["unit"] = {
			[17494] = 1,
		},
	},
	[9570] = {
		["item"] = {
			[23860] = 1,
		},
	},
	[9573] = {
		["unit"] = {
			[17448] = 1,
		},
	},
	[9581] = {
		["item"] = {
			[23878] = 1,
		},
	},
	[9582] = {
		["unit"] = {
			[17556] = 1,
		},
	},
	[9584] = {
		["item"] = {
			[23879] = 1,
		},
	},
	[9585] = {
		["item"] = {
			[23880] = 1,
		},
	},
	[9586] = {
		["unit"] = {
			[17551] = 1,
		},
	},
	[9600] = {
		["unit"] = {
			[17542] = 1,
		},
	},
	[9637] = {
		["item"] = {
			[25461] = 1,
		},
	},
	[9646] = {
		["item"] = {
			[24025] = 1,
		},
	},
	[9663] = {
		["unit"] = {
			[17240] = 1,
			[17116] = 1,
			[17440] = 1,
		},
	},
	[9664] = {
		["unit"] = {
			[17690] = 1,
			[17689] = 1,
			[17698] = 1,
			[17696] = 1,
		},
	},
	[9665] = {
		["unit"] = {
			[17690] = 1,
			[17689] = 1,
			[17698] = 1,
			[17696] = 1,
		},
	},
	[9666] = {
		["unit"] = {
			[17701] = 1,
		},
	},
	[9667] = {
		["object"] = {
			[181928] = 1,
		},
		["item"] = {
			[24099] = 1,
		},
		["unit"] = {
			[17682] = 1,
		},
	},
	[9669] = {
		["unit"] = {
			[17683] = 1,
		},
	},
	[9680] = {
		["item"] = {
			[24152] = 1,
		},
	},
	[9683] = {
		["unit"] = {
			[17715] = 1,
		},
	},
	[9684] = {
		["item"] = {
			[24156] = 1,
		},
	},
	[9685] = {
		["unit"] = {
			[17768] = 1,
		},
	},
	[9689] = {
		["unit"] = {
			[17592] = 1,
		},
	},
	[9692] = {
		["item"] = {
			[24226] = 1,
		},
	},
	[9714] = {
		["item"] = {
			[24246] = 1,
		},
	},
	[9715] = {
		["item"] = {
			[24246] = 1,
		},
	},
	[9717] = {
		["item"] = {
			[24247] = 1,
		},
	},
	[9720] = {
		["unit"] = {
			[17999] = 1,
			[18000] = 1,
			[17998] = 1,
			[18002] = 1,
		},
	},
	[9730] = {
		["unit"] = {
			[18046] = 1,
		},
	},
	[9735] = {
		["item"] = {
			[24284] = 1,
		},
	},
	[9736] = {
		["item"] = {
			[24285] = 1,
			[24286] = 1,
		},
	},
	[9740] = {
		["object"] = {
			[182026] = 1,
		},
	},
	[9747] = {
		["unit"] = {
			[18080] = 1,
		},
	},
	[9748] = {
		["item"] = {
			[24317] = 1,
		},
	},
	[9756] = {
		["unit"] = {
			[17974] = 1,
			[17824] = 1,
		},
	},
	[9785] = {
		["unit"] = {
			[17900] = 1,
			[17901] = 1,
		},
	},
	[9788] = {
		["item"] = {
			[24411] = 1,
		},
	},
	[9803] = {
		["item"] = {
			[24573] = 1,
		},
	},
	[9805] = {
		["object"] = {
			[182140] = 1,
			[182142] = 1,
			[182141] = 1,
			[182143] = 1,
		},
		["unit"] = {
			[18110] = 1,
			[18144] = 1,
			[18142] = 1,
			[18143] = 1,
		},
	},
	[9810] = {
		["unit"] = {
			[18145] = 1,
		},
	},
	[9816] = {
		["unit"] = {
			[18152] = 1,
		},
	},
	[9817] = {
		["unit"] = {
			[18044] = 1,
		},
	},
	[9820] = {
		["item"] = {
			[24472] = 1,
		},
	},
	[9822] = {
		["item"] = {
			[24471] = 1,
		},
	},
	[9823] = {
		["unit"] = {
			[18160] = 1,
		},
	},
	[9824] = {
		["unit"] = {
			[18162] = 1,
			[18161] = 1,
		},
	},
	[9839] = {
		["unit"] = {
			[18160] = 1,
		},
	},
	[9847] = {
		["unit"] = {
			[18185] = 1,
		},
	},
	[9848] = {
		["item"] = {
			[24499] = 1,
		},
	},
	[9851] = {
		["item"] = {
			[24496] = 1,
		},
	},
	[9852] = {
		["item"] = {
			[24505] = 1,
		},
	},
	[9853] = {
		["item"] = {
			[24503] = 1,
		},
	},
	[9856] = {
		["item"] = {
			[24513] = 1,
		},
	},
	[9859] = {
		["item"] = {
			[24523] = 1,
		},
	},
	[9867] = {
		["item"] = {
			[24543] = 1,
		},
	},
	[9873] = {
		["unit"] = {
			[18204] = 1,
		},
	},
	[9894] = {
		["unit"] = {
			[18282] = 1,
		},
	},
	[9895] = {
		["unit"] = {
			[18281] = 1,
		},
	},
	[9896] = {
		["item"] = {
			[25448] = 1,
		},
	},
	[9898] = {
		["item"] = {
			[25448] = 1,
		},
	},
	[9899] = {
		["unit"] = {
			[18280] = 1,
		},
	},
	[9900] = {
		["unit"] = {
			[18298] = 1,
		},
	},
	[9901] = {
		["unit"] = {
			[18280] = 1,
		},
	},
	[9902] = {
		["unit"] = {
			[20477] = 1,
		},
	},
	[9903] = {
		["unit"] = {
			[18286] = 1,
		},
	},
	[9904] = {
		["unit"] = {
			[20477] = 1,
		},
	},
	[9905] = {
		["unit"] = {
			[18286] = 1,
		},
	},
	[9910] = {
		["unit"] = {
			[18305] = 1,
			[18306] = 1,
			[18307] = 1,
		},
	},
	[9918] = {
		["unit"] = {
			[18354] = 1,
		},
	},
	[9923] = {
		["unit"] = {
			[18369] = 1,
		},
	},
	[9924] = {
		["unit"] = {
			[20812] = 1,
		},
	},
	[9931] = {
		["unit"] = {
			[18393] = 1,
		},
	},
	[9932] = {
		["unit"] = {
			[18395] = 1,
		},
	},
	[9935] = {
		["unit"] = {
			[18391] = 1,
		},
	},
	[9936] = {
		["unit"] = {
			[18391] = 1,
		},
	},
	[9937] = {
		["unit"] = {
			[18411] = 1,
		},
	},
	[9938] = {
		["unit"] = {
			[18411] = 1,
		},
	},
	[9939] = {
		["unit"] = {
			[18413] = 1,
		},
	},
	[9940] = {
		["unit"] = {
			[18413] = 1,
		},
	},
	[9946] = {
		["item"] = {
			[25590] = 1,
		},
	},
	[9949] = {
		["item"] = {
			[25638] = 1,
			[25642] = 1,
		},
	},
	[9950] = {
		["item"] = {
			[25638] = 1,
			[25642] = 1,
		},
	},
	[9951] = {
		["unit"] = {
			[18438] = 1,
		},
	},
	[9955] = {
		["unit"] = {
			[18444] = 1,
		},
	},
	[9965] = {
		["item"] = {
			[25666] = 1,
		},
	},
	[9966] = {
		["item"] = {
			[25666] = 1,
		},
	},
	[9971] = {
		["object"] = {
			[183789] = 1,
		},
	},
	[9977] = {
		["unit"] = {
			[18069] = 1,
		},
	},
	[9986] = {
		["unit"] = {
			[18539] = 1,
			[18540] = 1,
			[18541] = 1,
		},
	},
	[9987] = {
		["unit"] = {
			[18539] = 1,
			[18540] = 1,
			[18541] = 1,
		},
	},
	[9990] = {
		["item"] = {
			[25727] = 1,
		},
	},
	[10002] = {
		["unit"] = {
			[18583] = 1,
		},
	},
	[10003] = {
		["unit"] = {
			[18583] = 1,
		},
	},
	[10009] = {
		["item"] = {
			[25769] = 1,
			[25767] = 1,
			[25768] = 1,
		},
	},
	[10011] = {
		["item"] = {
			[25770] = 1,
			[25771] = 1,
		},
		["unit"] = {
			[19067] = 1,
			[19210] = 1,
		},
	},
	[10020] = {
		["item"] = {
			[25815] = 1,
		},
	},
	[10021] = {
		["object"] = {
			[182563] = 1,
			[182565] = 1,
			[182566] = 1,
		},
	},
	[10022] = {
		["item"] = {
			[25837] = 1,
		},
	},
	[10023] = {
		["item"] = {
			[25837] = 1,
		},
	},
	[10035] = {
		["item"] = {
			[25852] = 1,
			[30618] = 1,
		},
	},
	[10036] = {
		["item"] = {
			[25852] = 1,
			[30618] = 1,
		},
	},
	[10040] = {
		["unit"] = {
			[18716] = 1,
			[18719] = 1,
		},
	},
	[10041] = {
		["unit"] = {
			[18716] = 1,
			[18719] = 1,
		},
	},
	[10042] = {
		["unit"] = {
			[18720] = 1,
		},
	},
	[10043] = {
		["unit"] = {
			[18720] = 1,
		},
	},
	[10053] = {
		["unit"] = {
			[19457] = 1,
		},
	},
	[10054] = {
		["unit"] = {
			[16964] = 1,
		},
	},
	[10057] = {
		["unit"] = {
			[16977] = 1,
			[16978] = 1,
		},
	},
	[10058] = {
		["item"] = {
			[25938] = 1,
		},
	},
	[10059] = {
		["unit"] = {
			[19457] = 1,
		},
	},
	[10060] = {
		["unit"] = {
			[16964] = 1,
		},
	},
	[10062] = {
		["unit"] = {
			[16977] = 1,
			[16978] = 1,
		},
	},
	[10078] = {
		["unit"] = {
			[18818] = 1,
			[21237] = 1,
			[19009] = 1,
			[21236] = 1,
		},
	},
	[10085] = {
		["unit"] = {
			[18842] = 1,
			[18840] = 1,
			[18841] = 1,
			[18843] = 1,
		},
	},
	[10087] = {
		["object"] = {
			[183122] = 1,
			[185122] = 1,
		},
	},
	[10091] = {
		["item"] = {
			[27480] = 1,
		},
	},
	[10097] = {
		["unit"] = {
			[18472] = 1,
		},
	},
	[10098] = {
		["item"] = {
			[27632] = 1,
			[27633] = 1,
			[27634] = 1,
		},
	},
	[10099] = {
		["unit"] = {
			[18974] = 1,
		},
	},
	[10100] = {
		["unit"] = {
			[18976] = 1,
		},
	},
	[10106] = {
		["unit"] = {
			[19028] = 1,
			[19029] = 1,
			[19032] = 1,
		},
	},
	[10110] = {
		["unit"] = {
			[19028] = 1,
			[19029] = 1,
			[19032] = 1,
		},
	},
	[10111] = {
		["item"] = {
			[27841] = 1,
		},
		["object"] = {
			[183147] = 1,
		},
	},
	[10116] = {
		["item"] = {
			[27943] = 1,
		},
	},
	[10117] = {
		["item"] = {
			[27943] = 1,
		},
	},
	[10125] = {
		["unit"] = {
			[19277] = 1,
			[19278] = 1,
			[19276] = 1,
			[19279] = 1,
		},
	},
	[10127] = {
		["unit"] = {
			[19282] = 1,
		},
	},
	[10129] = {
		["unit"] = {
			[19291] = 1,
			[19292] = 1,
		},
	},
	[10136] = {
		["unit"] = {
			[19191] = 1,
		},
	},
	[10137] = {
		["unit"] = {
			[19266] = 1,
		},
	},
	[10138] = {
		["item"] = {
			[28099] = 1,
		},
	},
	[10139] = {
		["unit"] = {
			[19264] = 1,
		},
	},
	[10142] = {
		["unit"] = {
			[19434] = 1,
		},
	},
	[10144] = {
		["object"] = {
			[184414] = 1,
			[184415] = 1,
		},
	},
	[10145] = {
		["unit"] = {
			[19335] = 1,
		},
	},
	[10146] = {
		["unit"] = {
			[19291] = 1,
			[19292] = 1,
		},
	},
	[10149] = {
		["unit"] = {
			[19191] = 1,
		},
	},
	[10155] = {
		["unit"] = {
			[19265] = 1,
		},
	},
	[10156] = {
		["item"] = {
			[28099] = 1,
		},
	},
	[10157] = {
		["unit"] = {
			[19264] = 1,
		},
	},
	[10168] = {
		["item"] = {
			[28283] = 1,
		},
	},
	[10173] = {
		["item"] = {
			[28292] = 1,
		},
	},
	[10176] = {
		["unit"] = {
			[19494] = 1,
		},
	},
	[10182] = {
		["unit"] = {
			[19549] = 1,
		},
	},
	[10188] = {
		["item"] = {
			[28368] = 1,
		},
	},
	[10189] = {
		["item"] = {
			[28376] = 1,
		},
	},
	[10192] = {
		["item"] = {
			[28472] = 1,
			[28473] = 1,
			[28474] = 1,
		},
	},
	[10201] = {
		["unit"] = {
			[19606] = 1,
		},
	},
	[10203] = {
		["object"] = {
			[183805] = 1,
			[183807] = 1,
			[183806] = 1,
			[183808] = 1,
		},
	},
	[10205] = {
		["unit"] = {
			[19641] = 1,
		},
	},
	[10208] = {
		["object"] = {
			[184289] = 1,
			[184290] = 1,
		},
	},
	[10209] = {
		["item"] = {
			[28479] = 1,
		},
	},
	[10221] = {
		["unit"] = {
			[20284] = 1,
		},
	},
	[10223] = {
		["unit"] = {
			[19705] = 1,
		},
	},
	[10230] = {
		["item"] = {
			[28562] = 1,
		},
	},
	[10235] = {
		["item"] = {
			[28563] = 1,
		},
	},
	[10238] = {
		["object"] = {
			[183940] = 1,
			[183936] = 1,
			[183941] = 1,
		},
	},
	[10240] = {
		["unit"] = {
			[19868] = 1,
			[19866] = 1,
			[19867] = 1,
		},
	},
	[10248] = {
		["unit"] = {
			[19851] = 1,
		},
	},
	[10250] = {
		["unit"] = {
			[19862] = 1,
		},
	},
	[10253] = {
		["item"] = {
			[28677] = 1,
		},
	},
	[10256] = {
		["object"] = {
			[183507] = 1,
		},
		["item"] = {
			[28786] = 1,
		},
		["unit"] = {
			[19938] = 1,
		},
	},
	[10261] = {
		[28787] = 1,
	},
	[10265] = {
		["item"] = {
			[28829] = 1,
		},
	},
	[10270] = {
		["item"] = {
			[28969] = 1,
		},
	},
	[10273] = {
		["unit"] = {
			[20071] = 1,
		},
	},
	[10274] = {
		["unit"] = {
			[18544] = 1,
		},
	},
	[10276] = {
		["item"] = {
			[29026] = 1,
		},
	},
	[10293] = {
		["item"] = {
			[29164] = 1,
		},
	},
	[10295] = {
		["item"] = {
			[29162] = 1,
		},
	},
	[10299] = {
		["item"] = {
			[29366] = 1,
		},
	},
	[10301] = {
		["item"] = {
			[28475] = 1,
		},
	},
	[10305] = {
		["unit"] = {
			[19547] = 1,
		},
	},
	[10306] = {
		["unit"] = {
			[19548] = 1,
		},
	},
	[10307] = {
		["unit"] = {
			[19550] = 1,
		},
	},
	[10309] = {
		["item"] = {
			[29260] = 1,
		},
	},
	[10312] = {
		["item"] = {
			[29331] = 1,
		},
	},
	[10313] = {
		["unit"] = {
			[20336] = 1,
			[20337] = 1,
			[20338] = 1,
			[20333] = 1,
		},
	},
	[10318] = {
		["unit"] = {
			[20803] = 1,
		},
	},
	[10319] = {
		["item"] = {
			[29361] = 1,
		},
	},
	[10320] = {
		["unit"] = {
			[20483] = 1,
		},
	},
	[10321] = {
		["item"] = {
			[29396] = 1,
		},
	},
	[10322] = {
		["item"] = {
			[29397] = 1,
		},
	},
	[10323] = {
		["item"] = {
			[29411] = 1,
		},
		["unit"] = {
			[20440] = 1,
		},
	},
	[10329] = {
		["item"] = {
			[29366] = 1,
		},
	},
	[10330] = {
		["item"] = {
			[29396] = 1,
		},
	},
	[10332] = {
		["unit"] = {
			[20410] = 1,
		},
	},
	[10335] = {
		["unit"] = {
			[20475] = 1,
			[20473] = 1,
			[20476] = 1,
		},
	},
	[10338] = {
		["item"] = {
			[29397] = 1,
		},
	},
	[10339] = {
		["unit"] = {
			[20727] = 1,
		},
	},
	[10343] = {
		["item"] = {
			[29461] = 1,
		},
	},
	[10351] = {
		["unit"] = {
			[19305] = 1,
		},
	},
	[10353] = {
		["unit"] = {
			[20554] = 1,
		},
	},
	[10365] = {
		["item"] = {
			[29411] = 1,
		},
		["unit"] = {
			[20440] = 1,
		},
	},
	[10367] = {
		["item"] = {
			[29501] = 1,
		},
	},
	[10368] = {
		["unit"] = {
			[20678] = 1,
			[20679] = 1,
			[20677] = 1,
		},
	},
	[10369] = {
		["unit"] = {
			[20680] = 1,
		},
	},
	[10384] = {
		["item"] = {
			[29582] = 1,
		},
	},
	[10390] = {
		["item"] = {
			[29586] = 1,
		},
	},
	[10392] = {
		["item"] = {
			[29795] = 1,
		},
		["object"] = {
			[182935] = 1,
		},
		["unit"] = {
			[19298] = 1,
		},
	},
	[10394] = {
		["unit"] = {
			[20798] = 1,
		},
	},
	[10397] = {
		["item"] = {
			[29795] = 1,
		},
		["object"] = {
			[182935] = 1,
		},
		["unit"] = {
			[19298] = 1,
		},
	},
	[10400] = {
		["unit"] = {
			[19191] = 1,
		},
	},
	[10401] = {
		["unit"] = {
			[19191] = 1,
		},
	},
	[10407] = {
		["item"] = {
			[29624] = 1,
			[29625] = 1,
		},
	},
	[10408] = {
		["unit"] = {
			[20454] = 1,
		},
	},
	[10417] = {
		["item"] = {
			[29741] = 1,
		},
	},
	[10422] = {
		["item"] = {
			[29742] = 1,
		},
		["object"] = {
			[184588] = 1,
		},
	},
	[10426] = {
		["unit"] = {
			[20983] = 1,
		},
	},
	[10427] = {
		["unit"] = {
			[20982] = 1,
		},
	},
	[10429] = {
		["item"] = {
			[29768] = 1,
		},
	},
	[10438] = {
		["unit"] = {
			[20899] = 1,
		},
	},
	[10439] = {
		["unit"] = {
			[19554] = 1,
			[20985] = 1,
		},
	},
	[10446] = {
		["item"] = {
			[29912] = 1,
		},
		["unit"] = {
			[21039] = 1,
		},
	},
	[10447] = {
		["item"] = {
			[29912] = 1,
		},
		["unit"] = {
			[21039] = 1,
		},
	},
	[10458] = {
		["unit"] = {
			[21092] = 1,
			[21094] = 1,
		},
	},
	[10480] = {
		["unit"] = {
			[21095] = 1,
		},
	},
	[10481] = {
		["unit"] = {
			[21096] = 1,
		},
	},
	[10485] = {
		["item"] = {
			[30158] = 1,
		},
	},
	[10488] = {
		["unit"] = {
			[21142] = 1,
		},
	},
	[10489] = {
		["item"] = {
			[30177] = 1,
		},
	},
	[10494] = {
		["item"] = {
			[16673] = 1,
		},
	},
	[10495] = {
		["item"] = {
			[16723] = 1,
		},
	},
	[10502] = {
		["unit"] = {
			[20095] = 1,
			[21294] = 1,
			[21319] = 1,
			[20116] = 1,
		},
	},
	[10503] = {
		["unit"] = {
			[20723] = 1,
			[20731] = 1,
			[20732] = 1,
			[20726] = 1,
			[20730] = 1,
		},
	},
	[10504] = {
		["unit"] = {
			[20723] = 1,
			[20731] = 1,
			[20732] = 1,
			[20726] = 1,
			[20730] = 1,
		},
	},
	[10505] = {
		["unit"] = {
			[20095] = 1,
			[21294] = 1,
			[21319] = 1,
			[20116] = 1,
		},
	},
	[10506] = {
		["unit"] = {
			[21176] = 1,
		},
	},
	[10507] = {
		["unit"] = {
			[20132] = 1,
		},
	},
	[10508] = {
		["item"] = {
			[29624] = 1,
			[29625] = 1,
		},
	},
	[10512] = {
		["unit"] = {
			[20723] = 1,
			[20731] = 1,
			[20732] = 1,
			[20726] = 1,
			[20730] = 1,
		},
	},
	[10516] = {
		["item"] = {
			[30413] = 1,
			[30415] = 1,
		},
	},
	[10517] = {
		["unit"] = {
			[20732] = 1,
		},
	},
	[10518] = {
		["item"] = {
			[30417] = 1,
		},
	},
	[10524] = {
		["item"] = {
			[30434] = 1,
			[30432] = 1,
			[30433] = 1,
		},
	},
	[10526] = {
		["item"] = {
			[30435] = 1,
		},
	},
	[10528] = {
		["item"] = {
			[30442] = 1,
		},
	},
	[10531] = {
		["unit"] = {
			[15003] = 1,
			[15002] = 1,
			[15004] = 1,
			[15005] = 1,
		},
	},
	[10538] = {
		["item"] = {
			[30430] = 1,
		},
	},
	[10542] = {
		["item"] = {
			[30468] = 1,
		},
	},
	[10543] = {
		["unit"] = {
			[20095] = 1,
			[20723] = 1,
		},
	},
	[10545] = {
		["unit"] = {
			[20723] = 1,
			[20731] = 1,
			[20732] = 1,
			[20726] = 1,
			[20730] = 1,
		},
	},
	[10564] = {
		["unit"] = {
			[21512] = 1,
		},
	},
	[10567] = {
		["item"] = {
			[30706] = 1,
		},
	},
	[10570] = {
		["item"] = {
			[30617] = 1,
		},
	},
	[10571] = {
		["item"] = {
			[30649] = 1,
		},
	},
	[10572] = {
		["item"] = {
			[30628] = 1,
			[30631] = 1,
		},
	},
	[10574] = {
		["item"] = {
			[30692] = 1,
			[30693] = 1,
			[30691] = 1,
			[30694] = 1,
		},
	},
	[10578] = {
		["item"] = {
			[30645] = 1,
		},
	},
	[10583] = {
		["item"] = {
			[30658] = 1,
		},
	},
	[10585] = {
		["unit"] = {
			[21735] = 1,
		},
	},
	[10586] = {
		["item"] = {
			[30689] = 1,
		},
		["unit"] = {
			[21287] = 1,
		},
	},
	[10588] = {
		["unit"] = {
			[21181] = 1,
		},
	},
	[10597] = {
		["item"] = {
			[30628] = 1,
			[30631] = 1,
		},
	},
	[10598] = {
		["unit"] = {
			[21512] = 1,
		},
	},
	[10603] = {
		["item"] = {
			[30689] = 1,
		},
		["unit"] = {
			[21287] = 1,
		},
	},
	[10607] = {
		["unit"] = {
			[22799] = 1,
			[22800] = 1,
			[22798] = 1,
			[22801] = 1,
		},
	},
	[10622] = {
		["unit"] = {
			[21827] = 1,
		},
	},
	[10626] = {
		["item"] = {
			[30785] = 1,
			[30786] = 1,
		},
	},
	[10627] = {
		["item"] = {
			[30785] = 1,
			[30786] = 1,
		},
	},
	[10630] = {
		["unit"] = {
			[18976] = 1,
		},
	},
	[10634] = {
		["item"] = {
			[30797] = 1,
		},
	},
	[10637] = {
		["unit"] = {
			[21892] = 1,
		},
	},
	[10647] = {
		["item"] = {
			[30807] = 1,
		},
	},
	[10648] = {
		["item"] = {
			[30807] = 1,
		},
	},
	[10651] = {
		["unit"] = {
			[21164] = 1,
			[21168] = 1,
			[21178] = 1,
			[21171] = 1,
		},
	},
	[10668] = {
		["unit"] = {
			[21928] = 1,
		},
	},
	[10672] = {
		["unit"] = {
			[21924] = 1,
		},
	},
	[10673] = {
		["item"] = {
			[30851] = 1,
		},
	},
	[10678] = {
		["item"] = {
			[30851] = 1,
		},
	},
	[10679] = {
		["item"] = {
			[30876] = 1,
		},
	},
	[10684] = {
		["item"] = {
			[30649] = 1,
		},
	},
	[10685] = {
		["item"] = {
			[30692] = 1,
			[30693] = 1,
			[30691] = 1,
			[30694] = 1,
		},
	},
	[10688] = {
		["unit"] = {
			[21892] = 1,
		},
	},
	[10690] = {
		["unit"] = {
			[21956] = 1,
		},
	},
	[10692] = {
		["unit"] = {
			[21164] = 1,
			[21168] = 1,
			[21178] = 1,
			[21171] = 1,
		},
	},
	[10701] = {
		["unit"] = {
			[20772] = 1,
		},
	},
	[10707] = {
		["item"] = {
			[31307] = 1,
		},
	},
	[10720] = {
		["unit"] = {
			[22367] = 1,
			[22356] = 1,
			[22368] = 1,
		},
	},
	[10721] = {
		["item"] = {
			[31349] = 1,
		},
	},
	[10723] = {
		["unit"] = {
			[22434] = 1,
		},
	},
	[10748] = {
		["unit"] = {
			[21389] = 1,
		},
	},
	[10765] = {
		["item"] = {
			[31271] = 1,
		},
		["unit"] = {
			[22011] = 1,
			[22012] = 1,
		},
	},
	[10771] = {
		["object"] = {
			[185124] = 1,
			[185147] = 1,
			[185148] = 1,
		},
	},
	[10774] = {
		["item"] = {
			[31271] = 1,
		},
		["unit"] = {
			[22011] = 1,
			[22012] = 1,
		},
	},
	[10777] = {
		["item"] = {
			[31169] = 1,
		},
	},
	[10778] = {
		["item"] = {
			[31317] = 1,
		},
	},
	[10782] = {
		["item"] = {
			[31365] = 1,
		},
	},
	[10791] = {
		["unit"] = {
			[18384] = 1,
		},
	},
	[10795] = {
		["unit"] = {
			[20753] = 1,
		},
	},
	[10800] = {
		["item"] = {
			[31349] = 1,
		},
	},
	[10802] = {
		["unit"] = {
			[22434] = 1,
		},
	},
	[10805] = {
		["unit"] = {
			[20757] = 1,
		},
	},
	[10808] = {
		["object"] = {
			[184750] = 1,
		},
		["unit"] = {
			[22137] = 1,
		},
	},
	[10809] = {
		["item"] = {
			[31374] = 1,
		},
	},
	[10813] = {
		["unit"] = {
			[22177] = 1,
		},
	},
	[10833] = {
		["unit"] = {
			[22395] = 1,
		},
	},
	[10834] = {
		["item"] = {
			[31529] = 1,
		},
	},
	[10842] = {
		["unit"] = {
			[21638] = 1,
		},
	},
	[10843] = {
		["unit"] = {
			[20768] = 1,
		},
	},
	[10845] = {
		["unit"] = {
			[21032] = 1,
		},
	},
	[10846] = {
		["unit"] = {
			[22305] = 1,
		},
	},
	[10847] = {
		["item"] = {
			[25638] = 1,
			[25642] = 1,
		},
	},
	[10857] = {
		["unit"] = {
			[22350] = 1,
			[22348] = 1,
			[22351] = 1,
		},
	},
	[10864] = {
		["unit"] = {
			[19312] = 1,
		},
	},
	[10866] = {
		["object"] = {
			[185156] = 1,
		},
		["item"] = {
			[31664] = 1,
		},
		["unit"] = {
			[11980] = 1,
		},
	},
	[10872] = {
		["unit"] = {
			[22112] = 1,
			[11980] = 1,
		},
	},
	[10874] = {
		["object"] = {
			[185218] = 1,
			[185217] = 1,
			[185216] = 1,
			[185219] = 1,
		},
	},
	[10876] = {
		["item"] = {
			[31706] = 1,
		},
	},
	[10877] = {
		["item"] = {
			[31697] = 1,
		},
	},
	[10881] = {
		["item"] = {
			[31709] = 1,
			[31710] = 1,
			[31708] = 1,
		},
	},
	[10893] = {
		["unit"] = {
			[22396] = 1,
		},
	},
	[10895] = {
		["unit"] = {
			[21182] = 1,
			[22401] = 1,
			[22402] = 1,
			[22403] = 1,
		},
	},
	[10912] = {
		["unit"] = {
			[19747] = 1,
		},
	},
	[10915] = {
		["unit"] = {
			[22452] = 1,
		},
	},
	[10916] = {
		["item"] = {
			[31795] = 1,
		},
	},
	[10921] = {
		["unit"] = {
			[20682] = 1,
		},
	},
	[10923] = {
		["unit"] = {
			[22441] = 1,
		},
	},
	[10925] = {
		["unit"] = {
			[22441] = 1,
		},
	},
	[10935] = {
		["unit"] = {
			[22432] = 1,
		},
	},
	[10937] = {
		["unit"] = {
			[19312] = 1,
		},
	},
	[10965] = {
		["unit"] = {
			[22916] = 1,
		},
	},
	[10974] = {
		["item"] = {
			[32061] = 1,
		},
	},
	[10980] = {
		["unit"] = {
			[22932] = 1,
		},
	},
	[10995] = {
		["item"] = {
			[32379] = 1,
		},
	},
	[10996] = {
		["item"] = {
			[32380] = 1,
		},
	},
	[10997] = {
		["item"] = {
			[32382] = 1,
		},
	},
	[11005] = {
		["unit"] = {
			[23066] = 1,
			[23067] = 1,
			[23068] = 1,
		},
	},
	[11029] = {
		["item"] = {
			[32742] = 1,
		},
	},
	[11041] = {
		["unit"] = {
			[23269] = 1,
		},
	},
	[11054] = {
		["item"] = {
			[32666] = 1,
		},
	},
	[11056] = {
		["item"] = {
			[32687] = 1,
		},
	},
	[11128] = {
		["item"] = {
			[33008] = 1,
		},
	},
	[11129] = {
		["unit"] = {
			[23616] = 1,
		},
	},
	[11134] = {
		["unit"] = {
			[23941] = 1,
		},
	},
	[11137] = {
		["item"] = {
			[33037] = 1,
		},
	},
	[11139] = {
		["item"] = {
			[33038] = 1,
			[33039] = 1,
		},
	},
	[11147] = {
		["unit"] = {
			[23727] = 1,
		},
	},
	[11150] = {
		["unit"] = {
			[23753] = 1,
			[23751] = 1,
			[23752] = 1,
		},
	},
	[11152] = {
		["unit"] = {
			[23768] = 1,
		},
	},
	[11162] = {
		["unit"] = {
			[23789] = 1,
		},
	},
	[11174] = {
		["unit"] = {
			[23797] = 1,
		},
	},
	[11184] = {
		["unit"] = {
			[23873] = 1,
		},
	},
	[11205] = {
		["unit"] = {
			[23753] = 1,
			[23751] = 1,
			[23752] = 1,
		},
	},
	[11381] = {
		["item"] = {
			[33850] = 1,
		},
	},
	[11383] = {
		["unit"] = {
			[24429] = 1,
		},
	},
	[11524] = {
		["unit"] = {
			[24991] = 1,
		},
	},
	[11525] = {
		["unit"] = {
			[24991] = 1,
		},
	},
	[11547] = {
		["unit"] = {
			[25154] = 1,
			[25156] = 1,
			[25157] = 1,
		},
	},
};
__db.large_pin = large_pin;
function large_pin:Check(_quest, _type, _id)
	local info = self[_quest];
	if info ~= nil then
		info = info[_type];
		if info ~= nil then
			return info[_id] ~= nil;
		end
	end
end

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
	["捕获土之魂"] = 21050,
	["捕获火之魂"] = 21061,
};

__db.fix = {
	quest = {
		[9955] = {
			obj = {
				U = { 18423, },		--	fake
			},
		},
		[9849] = {
			obj = {
				U = { 18181, 17157, },	--	对17157使用道具产生18181
			},
		},
		[9927] = {
			obj = {
				U = { 18388, 17146, 17147, 17148, 18397, 18658, 21276, },	--	对17146, 17147, 17148, 18397, 18658, 21276的尸体用道具
			},
		},
		[9931] = {
			obj = {
				U = { 18393, 18064, 17138, },	--	对18064, 17138的尸体用道具
			},
		},
		[10458] = {
			obj = {
				U = { 21050, 21061, },
			},
		},
		[10480] = {
			obj = {
				U = { 21059, },
			},
		},
		[10481] = {
			obj = {
				U = { 21060, },
			},
		},
	},
	unit = {
		[18585] = {
			fac = "_NIL",
			facA = 0,
			facH = 0,
		},
		[18586] = {
			fac = "_NIL",
			facA = 0,
			facH = 0,
		},
		[18588] = {
			fac = "_NIL",
			facA = 0,
			facH = 0,
		},
		[21727]= {
			fac = "_NIL",
			facA = 0,
		},
		[21815] = {
			facId = "_NIL",
			fac = "_NIL",
			facA = 0,
			facH = 0,
		},
	},
	item = {
		[31365] = {
			["Q"] = { 10782, },
			["O"] = {
				[401001] = 1,
			},
		},
		[33850] = {
			["O"] = {
				[401002] = 1,
			}
		}
	},
	object = {
		[401001] = {
			["coords"] = {
				{ 43.0, 44.9, 1948, 0, },
			},
		},
		[401002] = {
			["coords"] = {
				{ 25.8, 59.5, 1951, 0, },
			},
		},
	},
};
__db.fix_alliance = {
	unit = {
		[13778] = {
			coords = {
				{ 48.5, 58.3, 1459, 0,},
				{ 50.2, 65.3, 1459, 0,},
				{ 49.3, 84.4, 1459, 0,},
				{ 48.3, 84.3, 1459, 0,},
			},
		},
	},
};
__db.fix_horde = {
	unit = {
		[13778] = {
			coords = {
				{ 52.8, 44, 1459, 0,},
				{ 50.8, 30.8, 1459, 0,},
				{ 45.2, 14.6, 1459, 0,},
				{ 44, 18.1, 1459, 0,},
			},
		},
	},
};

large_pin[9955].unit = { [18423] = 1, };

__ns.L.object[401001] = __ns.L.object[401001] or (__ns.L.quest[10782] ~= nil and __ns.L.quest[10782][1]) or "401001";
__ns.L.object[401002] = __ns.L.object[401002] or (__ns.L.quest[11381] ~= nil and __ns.L.quest[11381][1]) or "401002";
