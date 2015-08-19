--[[
		   ________          ____                               
		  / ____/ /_  ____ _/ / /__  ____  ____ ____  __________
		 / /   / __ \/ __ `/ / / _ \/ __ \/ __ `/ _ \/ ___/ ___/
		/ /___/ / / / /_/ / / /  __/ / / / /_/ /  __/ /  (__  ) 
		\____/_/ /_/\__,_/_/_/\___/_/ /_/\__, /\___/_/  /____/  
		                                /____/                                               
									Katarina 
	========================================================================

	Changelog!
	Version: 1.3
		* Rework Kill Steal code.
		* Ignite work (It have some bugs)
		* AaAdd Item casting fix to fix zhonyas casting.

	Version: 1.2
		* Rework range code.
		* Fix kill steal usage.
		* Add draw ranges for skills.
		* Fix a ward jump bug.

	Version: 1.1
		* Added Ward Jump (Credits to Skeem).
		* Add auto Zhonyas.
		* Rewaork ignite.

	Version: 1.0
		* Costomizable Key Settings.
		* Costomizable Harass, use Q, W, E.
		* Customizable Full combo. change "QEWR", "EQWR.
		* Customizable KS settings using skills and ignite.
		* Customizable farm with Q, W.
]]-- 

if myHero.charName ~= "Katarina" then
	return
end

-- HELPERS
local itemCastingFix = true -- CHANGE THIS TRUE OR FALSE IF BOL IS SUPPORTING ITEMS OR NOT

-- Ult Helper
local ULT = {
	using  = false,
	last = 0
}

-- Ranges
local RANGE = {
	Q = 675,
	W = 375,
	E = 700,
	R = 550
}

-- Ignite
local ignite = nil
local dmgIgnite = 0
local igniteReady= false

-- Ward Jump by Skeem
local lastJump = 0
local wards = {
	SightStone = "itemghostward",
	SightWard = "sightward",
	VisionWard = "visionward",
	Trinket1 = "trinkettotemlvl1",
	Trinket2 = "trinkettotemlvl2",
	Trinket3 = "trinkettotemlvl3",
	Trinket4 = "trinkettotemlvl3b"
}

-- Using Items
local ITEMS = {
	zhonyaslot = nil,
	zhonyaready = false
}

-- Checks
local CHECKS = {
	Q = false,
	W = false,
	E = false,
	R = false
}

-- Kill Steal
local enemyhealth = 0

-- Updater
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/bolchallengers/bol/master/scripts/Challengers_Katarina.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local UPDATE_SCRIPT = true
local version = 1.3

function InfoMessage(msg)
	print("<font color=\"#FF9A00\"><b>Challengers Katarina:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>")
end

function UpdateScript()
	if UPDATE_SCRIPT then
		local ServerData = GetWebResult(UPDATE_HOST, "/bolchallengers/bol/master/scripts/Challengers_Katarina.version")
		if ServerData then
			ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
			if ServerVersion then
				if tonumber(version) < ServerVersion then
					InfoMessage("New version available ("..ServerVersion..")")
					InfoMessage("Updating, please don't press F9")
					DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () InfoMessage("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
				else
					InfoMessage("You have got the latest version ("..ServerVersion..")")
				end
			end
		else
			InfoMessage("Error downloading version info")
		end
	end
end

function fixItems()
	if itemCastingFix then
		ItemNames = {
			[3303]	= "ArchAngelsDummySpell",
			[3007]	= "ArchAngelsDummySpell",
			[3144]	= "BilgewaterCutlass",
			[3188]	= "ItemBlackfireTorch",
			[3153]	= "ItemSwordOfFeastAndFamine",
			[3405]	= "TrinketSweeperLvl1",
			[3411]	= "TrinketOrbLvl1",
			[3166]	= "TrinketTotemLvl1",
			[3450]	= "OdinTrinketRevive",
			[2041]	= "ItemCrystalFlask",
			[2054]	= "ItemKingPoroSnack",
			[2138]	= "ElixirOfIron",
			[2137]	= "ElixirOfRuin",
			[2139]	= "ElixirOfSorcery",
			[2140]	= "ElixirOfWrath",
			[3184]	= "OdinEntropicClaymore",
			[2050]	= "ItemMiniWard",
			[3401]	= "HealthBomb",
			[3363]	= "TrinketOrbLvl3",
			[3092]	= "ItemGlacialSpikeCast",
			[3460]	= "AscWarp",
			[3361]	= "TrinketTotemLvl3",
			[3362]	= "TrinketTotemLvl4",
			[3159]	= "HextechSweeper",
			[2051]	= "ItemHorn",
			--[2003] = "RegenerationPotion",
			[3146]	= "HextechGunblade",
			[3187]	= "HextechSweeper",
			[3190]	= "IronStylus",
			[2004]	= "FlaskOfCrystalWater",
			[3139]	= "ItemMercurial",
			[3222]	= "ItemMorellosBane",
			[3042]	= "Muramana",
			[3043]	= "Muramana",
			[3180]	= "OdynsVeil",
			[3056]	= "ItemFaithShaker",
			[2047]	= "OracleExtractSight",
			[3364]	= "TrinketSweeperLvl3",
			[2052]	= "ItemPoroSnack",
			[3140]	= "QuicksilverSash",
			[3143]	= "RanduinsOmen",
			[3074]	= "ItemTiamatCleave",
			[3800]	= "ItemRighteousGlory",
			[2045]	= "ItemGhostWard",
			[3342]	= "TrinketOrbLvl1",
			[3040]	= "ItemSeraphsEmbrace",
			[3048]	= "ItemSeraphsEmbrace",
			[2049]	= "ItemGhostWard",
			[3345]	= "OdinTrinketRevive",
			[2044]	= "SightWard",
			[3341]	= "TrinketSweeperLvl1",
			[3069]	= "shurelyascrest",
			[3599]	= "KalistaPSpellCast",
			[3185]	= "HextechSweeper",
			[3077]	= "ItemTiamatCleave",
			[2009]	= "ItemMiniRegenPotion",
			[2010]	= "ItemMiniRegenPotion",
			[3023]	= "ItemWraithCollar",
			[3290]	= "ItemWraithCollar",
			[2043]	= "VisionWard",
			[3340]	= "TrinketTotemLvl1",
			[3090]	= "ZhonyasHourglass",
			[3154]	= "wrigglelantern",
			[3142]	= "YoumusBlade",
			[3157]	= "ZhonyasHourglass",
			[3512]	= "ItemVoidGate",
			[3131]	= "ItemSoTD",
			[3137]	= "ItemDervishBlade",
			[3352]	= "RelicSpotter",
			[3350]	= "TrinketTotemLvl2",
		}
	
		_G.ITEM_1	= 06
		_G.ITEM_2	= 07
		_G.ITEM_3	= 08
		_G.ITEM_4	= 09
		_G.ITEM_5	= 10
		_G.ITEM_6	= 11
		_G.ITEM_7	= 12
	
		___GetInventorySlotItem	= rawget(_G, "GetInventorySlotItem")
		_G.GetInventorySlotItem	= GetSlotItem
	end
end

function OnLoad()
	-- Check Update
	UpdateScript()

	-- Fix item casting issue
	fixItems()

	-- Load Menu
	Menu = scriptConfig("Challengers Katarina", "Katarina")

	Menu:addSubMenu("["..myHero.charName.."] - Key Settings", "Keys")
		Menu.Keys:addParam("comboKey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Keys:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("M"))
		Menu.Keys:addParam("farmKey", "Farm On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("N"))
		Menu.Keys:addParam("clearKey", "Lane Clear On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))

	Menu:addSubMenu("["..myHero.charName.."] - Harass Settings", "Harass")
		Menu.Harass:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, false) 
		Menu.Harass:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("["..myHero.charName.."] - Combo Settings", "Combo")
		Menu.Combo:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
		Menu.Combo:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addSubMenu("["..myHero.charName.."] - Ultimate Settings", "ultimate") 
			Menu.Combo.ultimate:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, true)
			Menu.Combo.ultimate:addParam("stopclick",  "Stop (R) With Right Click", SCRIPT_PARAM_ONOFF, false)
			Menu.Combo.ultimate:addParam("ultMode", "Ultimate Mode", SCRIPT_PARAM_LIST, 2, {"QEWR", "EQWR"})

	Menu:addSubMenu("["..myHero.charName.."] - KS Settings", "KS")
		Menu.KS:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Farm Settings", "Farm")
		Menu.Farm:addParam("useQFarm", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Farm:addParam("useWFarm", "Use (W)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "LaneClear")
		Menu.LaneClear:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.LaneClear:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.LaneClear:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Misc Settings", "Misc")
		Menu.Misc:addSubMenu("["..myHero.charName.."] - Ward Jump Settings", "WardJump") 
			Menu.Misc.WardJump:addParam('wardjumpKey', 'Ward Jump Key',  SCRIPT_PARAM_ONKEYDOWN, false, string.byte("H"))
			Menu.Misc.WardJump:addParam("maxjump", "Always Ward Jump at Max Range", SCRIPT_PARAM_ONOFF, true)
		Menu.Misc:addSubMenu("["..myHero.charName.."] - Items Settings", "Items") 
			Menu.Misc.Items:addParam("useZhonya", "Use Zhonya", SCRIPT_PARAM_ONOFF, true)
			Menu.Misc.Items:addParam("zhonyaHp", "% hp to Zhonya", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.."] - Draw Settings", "Draw")
		Menu.Draw:addParam("drawQ", "Draw (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Draw:addParam("drawW", "Draw (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.Draw:addParam("drawE", "Draw (E)", SCRIPT_PARAM_ONOFF, true)

	-- Perma Shows
	Menu.Keys:permaShow("comboKey")
	Menu.Keys:permaShow("harassKey")
	Menu.Keys:permaShow("clearKey")
	Menu.Keys:permaShow("farmKey")

	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, RANGE.E)
	ts.name = "[Katarina]"
	Menu:addTS(ts)

	-- Minions
	enemyMinions = minionManager(MINION_ENEMY, RANGE.E, myHero, MINION_SORT_MAXHEALTH_DEC)
	allyMinions = minionManager(MINION_ALLY, RANGE.E, myHero, MINION_SORT_MAXHEALTH_DEC)
	jungleMinions = minionManager(MINION_JUNGLE, RANGE.E, myHero, MINION_SORT_MAXHEALTH_DEC)
	otherMinions = minionManager(MINION_OTHER, RANGE.E, myHero, MINION_SORT_MAXHEALTH_DEC)

	-- Ignite check
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
		ignite = SUMMONER_2
	end

	-- Override Globals Credits to Aroc :3
	_G.myHero.SaveMove = _G.myHero.MoveTo
	_G.myHero.SaveAttack = _G.myHero.Attack
	_G.myHero.MoveTo = function(...) if not ULT.using then _G.myHero.SaveMove(...) end end
	_G.myHero.Attack = function(...) if not ULT.using then _G.myHero.SaveAttack(...) end end

	-- Callbacks
	AddCastSpellCallback(function(iSpell, startPos, endPos, targetUnit) 	OnCastSpell(iSpell,startPos,endPos,targetUnit) end)

	-- Wards
	wardsTable = {}
	for i = 0, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj and obj.valid and (string.find(obj.name, "Ward") ~= nil or string.find(obj.name, "Wriggle") ~= nil or string.find(obj.name, "Trinket")) then
			table.insert(wardsTable, obj)
		end
	end

	InfoMessage("Version: ".. version .. " loaded!")
end

function OnTick()
	Checks()

	if Menu.Misc.Items.useZhonya then
		CheckZhonya()
	end

	if Menu.Keys.comboKey then
		Combo()
		return
	end

	if Menu.Keys.harassKey then
		Harass()
		return
	end

	if Menu.Keys.farmKey then
		Farm()
	end

	if Menu.Keys.clearKey then
		LaneClear()
	end

	if ValidTarget(target) then
		KillSteal(target)
	end

	if Menu.Misc.WardJump.wardjumpKey then
    		local WardPos = (GetDistanceSqr(mousePos) <= 600 * 600 and mousePos) or (Menu.Misc.WardJump.maxjump and myHero + (Vector(mousePos) - myHero):normalized()*590)
		if WardPos then
			WardJump(WardPos.x, WardPos.z)
		end
	end
end

function Checks()
	ts:update()
	target = ts.target

	CHECKS.Q = (myHero:CanUseSpell(_Q) == READY)
	CHECKS.W = (myHero:CanUseSpell(_W) == READY) 
	CHECKS.E = (myHero:CanUseSpell(_E) == READY)
	CHECKS.R = (myHero:CanUseSpell(_R) == READY)

	igniteReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

	ITEMS.zhonyaslot = GetInventorySlotItem(3157)
	ITEMS.zhonyaready = (ITEMS.zhonyaslot ~= nil and myHero:CanUseSpell(ITEMS.zhonyaslot) == READY)

	if ULT.using then
		if (os.clock() - ULT.last) > 2.5 then
			ULT.using = false
			ULT.last  = 0
		end
	end
end

function Combo()
	if ValidTarget(target) then
		if Menu.Combo.ultimate.ultMode == 1 then
			if CHECKS.Q and Menu.Combo.useQ then 
				if GetDistance(target) <= RANGE.Q then
					CastSpell(_Q, target) 
				end
			end

			if CHECKS.E and Menu.Combo.useE then
				if GetDistance(target) <= RANGE.E then
					CastSpell(_E, target)
				end
			end


			if CHECKS.W and Menu.Combo.useW then
				if GetDistance(target) <= RANGE.W then
					CastSpell(_W)
				end
			end

			if CHECKS.R and not CHECKS.Q and not CHECKS.W and not CHECKS.E and Menu.Combo.ultimate.useR then
				if GetDistance(target) <= RANGE.R then
					CastSpell(_R)
				end
			end
		elseif Menu.Combo.ultimate.ultMode == 2 then
			if CHECKS.E and Menu.Combo.useE then
				if GetDistance(target) <= RANGE.E then
					CastSpell(_E, target)
				end
			end

			if CHECKS.Q and Menu.Combo.useQ then 
				if GetDistance(target) <= RANGE.Q then
					CastSpell(_Q, target)
				end
			end

			if CHECKS.W and Menu.Combo.useW then
				if GetDistance(target) <= RANGE.W then
					CastSpell(_W)
				end
			end

			if CHECKS.R and not CHECKS.Q and not CHECKS.W and not CHECKS.E and Menu.Combo.ultimate.useR then
				if GetDistance(target) <= RANGE.R then
					CastSpell(_R)
				end
			end
		end
	end
end

function OnWndMsg(msg, key)
	if Menu.Combo.ultimate.stopclick then
		if msg == WM_RBUTTONDOWN and ULT.using then 
			ULT.using = false
		end
	end
end


function OnCastSpell(iSpell,startPos,endPos,targetUnit)
	if iSpell == 3 then
		ULT.using = true
		ULT.last  = os.clock()
	end
end

function OnRemoveBuff(unit, buff)
	if unit.isMe and buff.name == "katarinarsound" then
		ULT.using = false
		ULT.last  = 0
	end
end

function AutoIgnite(enemy)
  	dmgIgnite = ((igniteReady  and getDmg("IGNITE", enemy, myHero)) or 0) 
	if enemy.health <= dmgIgnite and GetDistance(enemy) <= 600 and ignite ~= nil then
		if igniteReady then
			CastSpell(ignite, enemy)
		end
	end
end

function KillSteal(enemy)
	if GetDistance(enemy) < 700 and ValidTarget(enemy) and not TargetHaveBuff("willrevive", enemy) and not TargetHaveBuff("UndyingRage", enemy) then
		enemyhealth = enemy.health
		local eDmg = myHero:CalcMagicDamage(enemy, 25 * (myHero:GetSpellData(_E).level - 1) + 60 + (.4 * myHero.ap))
		local wDmg = myHero:CalcMagicDamage(enemy, 35 * (myHero:GetSpellData(_W).level - 1) + 40 + (.25 * myHero.ap) + (.6 * myHero.addDamage))
		local qDmg = myHero:CalcMagicDamage(enemy, 25 * (myHero:GetSpellData(_Q).level - 1) + 60 + (.45 * myHero.ap))

		if enemyhealth < qDmg and GetDistance(enemy) < RANGE.Q and CHECKS.Q then
			CastSpell(_Q, enemy)
			CastSpell(_W)
		elseif enemyhealth < eDmg and GetDistance(enemy) < RANGE.E and CHECKS.E then
			CastSpell(_E, enemy)
		elseif enemyhealth < wDmg + eDmg and GetDistance(enemy) < 700 and CHECKS.E and CHECKS.W then
			CastSpell(_E, enemy)
			CastSpell(_W)
		elseif enemyhealth < wDmg and GetDistance(enemy) < RANGE.W and CHECKS.W then
			CastSpell(_W)
		elseif GetDistance(enemy) < 300 and enemyhealth < qDmg + wDmg and CHECKS.Q and CHECKS.W then
			CastSpell(_Q, enemy)
			CastSpell(_W)
		elseif GetDistance(enemy) < 375 and GetDistance(enemy) > 300 and enemyhealth < qDmg + wDmg and CHECKS.Q and CHECKS.W then 
			CastSpell(_W)
			CastSpell(_Q, enemy)
		elseif GetDistance(enemy) < 700 and GetDistance(enemy) > 600 and enemyhealth < qDmg + eDmg and CHECKS.Q and CHECKS.E then 
			CastSpell(_E, enemy)
			CastSpell(_Q, enemy)
		elseif GetDistance(enemy) < 600 and enemyhealth < qDmg + eDmg and CHECKS.Q and CHECKS.E then 
			CastSpell(_Q, enemy)
			CastSpell(_E, enemy)
		elseif GetDistance(enemy) < 700 and GetDistance(enemy) > 600 and enemyhealth < wDmg + eDmg + qDmg and CHECKS.Q and CHECKS.E and CHECKS.W then
			CastSpell(_E, enemy)
			CastSpell(_Q, enemy)	
			CastSpell(_W)
		elseif GetDistance(enemy) < 600 and enemyhealth < wDmg + eDmg + qDmg and CHECKS.Q and CHECKS.E and CHECKS.W then
			CastSpell(_Q, enemy)
			CastSpell(_E, enemy)
			CastSpell(_W)
		end

		if Menu.KS.ignite then
			AutoIgnite(enemy)
		end
		enemy = nil
	end
end

function Harass()
	if not target then
		return
	end

	if ValidTarget(target) then
		if CHECKS.E and Menu.Harass.useE then
			if GetDistance(target) <= RANGE.E then
				CastSpell(_E, target)
			end
		end

		if CHECKS.Q and Menu.Harass.useQ then 
			if GetDistance(target) <= RANGE.Q then
				CastSpell(_Q, target) 
			end
		end

		if CHECKS.W and Menu.Harass.useW then
			if GetDistance(target) <= RANGE.W then
				CastSpell(_W)
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in ipairs(enemyMinions.objects) do
		if Menu.Farm.useQFarm then
			if ValidTarget(minion) and GetDistance(minion) <= RANGE.Q and CHECKS.Q and getDmg("Q", minion, myHero) > minion.health then
				CastSpell(_Q, minion)
			end
		end
	end
	
	for i, minion in ipairs(enemyMinions.objects) do
		if Menu.Farm.useWFarm then
			if ValidTarget(minion) and GetDistance(minion) <= RANGE.W and CHECKS.W and getDmg("W", minion, myHero) > minion.health then
				CastSpell(_W)
			end
		end
	end
end

function LaneClear()
	local cleartarget = nil
	enemyMinions:update()
	otherMinions:update()
	jungleMinions:update()

	for i, minion in ipairs(enemyMinions.objects) do
		if ValidTarget(minion, 600) and (cleartarget == nil or not ValidTarget(cleartarget)) then
			cleartarget = minion
		end
	end

	for i, jungleminion in ipairs(jungleMinions.objects) do
		if ValidTarget(jungleminion, 600) and (cleartarget == nil or not ValidTarget(cleartarget)) then
			cleartarget = jungleminion
		end
	end

	for i, otherminion in ipairs(otherMinions.objects) do
		if ValidTarget(otherminion, 600) and (cleartarget == nil or not ValidTarget(cleartarget)) then
			cleartarget = otherminion
		end
	end

	if cleartarget ~= nil then
		if Menu.LaneClear.useQ then
			CastSpell(_Q, cleartarget)
		end

		if Menu.LaneClear.useW then
			CastSpell(_W, cleartarget)
		end

		if Menu.LaneClear.useE then
			CastSpell(_E, cleartarget)
		end
	end
end

function OnCreateObj(obj)
	if obj.valid and (string.find(obj.name, "Ward") ~= nil or string.find(obj.name, "Wriggle") ~= nil or string.find(obj.name, "Trinket")) then
		table.insert(wardsTable, obj)
	end
end

function OnDeleteObj(obj)
	if obj then
		for i, ward in pairs(wardsTable) do
			if not ward.valid or obj.name == ward.name then
				table.remove(wardsTable, i)
			end
		end
	end
end

function WardJump(x, y, enemy)
	if GetDistance(mousePos) and not enemy then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end	

	if CHECKS.E then
		local Jumped = false
		local WardDistance = 300

		--Ally jump
		for i, ally in ipairs(GetAllyHeroes()) do
			if ValidTarget(ally, RANGE.E, false) then
				if GetDistanceSqr(ally, mousePos) <= WardDistance*WardDistance then
					CastSpell(_E, ally)
					Jumped = true
					lastJump = GetTickCount() + 2000
				end
			end
		end

		-- Minions jump
		allyMinions:update()
		for i, minion in pairs(allyMinions.objects) do
			if ValidTarget(minion, RANGE.E, false) then
				if GetDistanceSqr(minion, mousePos) <= WardDistance*WardDistance then
					CastSpell(_E, minion)
					Jumped = true
					lastJump = GetTickCount() + 2000
				end
			end
		end

		-- Ward Jump
		for i, myWard in pairs(wardsTable) do
			if GetDistanceSqr(mousePos) < 600 * 600 then
				if GetDistanceSqr(myWard, mousePos) < WardDistance*WardDistance then
					CastSpell(_E, myWard)
					Jumped = true
					lastJump = GetTickCount() + 2000
				end
			else
				if GetDistanceSqr(myWard) < RANGE.E * RANGE.E then
					CastSpell(_E, myWard)
				end
			end
		end

		if not Jumped and GetTickCount() >= lastJump then
			local Slot = GetWardSlot()
			if Slot ~= nil then
				CastSpell(Slot, x, y)
				Jumped = true
				lastJump = GetTickCount() + 2000
			end
		end
	end
end

function GetWardSlot()
	-- Gets Slot of Available Wards --
	local function getReadySlot(itemName)
		for slot = 6, 12 do
			if string.lower(myHero:GetSpellData(slot).name) == itemName and myHero:CanUseSpell(slot) then
				return slot
			end
		end
		return nil
	end

	-- Ward Priorities --
	if getReadySlot(wards.Trinket1) ~= nil then
		return getReadySlot(wards.Trinket1)
	elseif getReadySlot(wards.Trinket2) ~= nil then
		return getReadySlot(wards.Trinket2)
	elseif getReadySlot(wards.Trinket3) ~= nil then
		return getReadySlot(wards.Trinket3)
	elseif getReadySlot(wards.Trinket4) ~= nil then
		return getReadySlot(wards.Trinket4)
	elseif getReadySlot(wards.SightWard) ~= nil then
		return getReadySlot(wards.SightWard)
	elseif getReadySlot(wards.VisionWard) ~= nil then
		return getReadySlot(wards.VisionWard)
	elseif getReadySlot(wards.SightStone) ~= nil then
		return getReadySlot(wards.SightStone)
	end

	return nil
end

function CheckZhonya()
	if Menu.Misc.Items.useZhonya then
		if ITEMS.zhonyaready and ((myHero.health/myHero.maxHealth)*100) <= Menu.Misc.Items.zhonyaHp then
			CastSpell(ITEMS.zhonyaslot)
		end
	end
end

function Round(number)
	if number >= 0 then 
		return math.floor(number+.5) 
	else 
		return math.ceil(number-.5) 
	end
end

function DrawCircle(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
		
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
		DrawCircleNextLvl(x, y, z, radius, 1, color, 300) 
	end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8, Round(180 / math.deg((math.asin((chordlength / (2 * radius)))))))
	quality = 2 * math.pi / quality
	radius = radius * .92
	local points = {}
		
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function OnDraw()
	if Menu.Draw.drawQ and CHECKS.Q then
		DrawCircle(myHero.x, myHero.y, myHero.z, RANGE.Q, ARGB(255, 51, 153, 255))
	end

	if Menu.Draw.drawW and CHECKS.W then
		DrawCircle(myHero.x, myHero.y, myHero.z, RANGE.W, ARGB(255, 102, 178 , 0 ))
	end

	if Menu.Draw.drawE and CHECKS.E then
		DrawCircle(myHero.x, myHero.y, myHero.z, RANGE.E, ARGB(255, 178, 0 , 0 ))
	end

end

function GetSlotItem(id, unit)
	unit = unit or myHero

	if (not ItemNames[id]) then
		return ___GetInventorySlotItem(id, unit)
	end

	local name	= ItemNames[id]
	for slot = ITEM_1, ITEM_7 do
		local item = unit:GetSpellData(slot).name
		if ((#item > 0) and (item:lower() == name:lower())) then
			return slot
		end
	end
end