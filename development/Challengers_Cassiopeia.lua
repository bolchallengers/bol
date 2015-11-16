--[[
		   ________          ____                               
		  / ____/ /_  ____ _/ / /__  ____  ____ ____  __________
		 / /   / __ \/ __ `/ / / _ \/ __ \/ __ `/ _ \/ ___/ ___/
		/ /___/ / / / /_/ / / /  __/ / / / /_/ /  __/ /  (__  ) 
		\____/_/ /_/\__,_/_/_/\___/_/ /_/\__, /\___/_/  /____/  
		                                /____/                                               
									Cassiopeia
	========================================================================

	Changelog!
	Version: 1.0
		* Costomizable Key Settings.
		* Costomizable Harass, use Q, W, E (if target have poison).
		* Customizable Full combo. with R if enemy killable.
		* Customizable farm with Q, W.
]]-- 

if myHero.charName ~= "Cassiopeia" then
	return
end

-- HELPERS
local HELPERS = {
	E = {last = 0, delay = 0, canuse = true},
	R = {using  = false, last = 0}
}

--Spell Data
local Ranges = {[_Q] = 850, [_W] = 850, [_E] = 700, [_R] = 825}
local Widths = {[_Q] = 75, [_W] = 106, [_R] = 80 * math.pi / 180}
local Delays = {[_Q] = 0.6, [_W] = 0.5, [_R] = 0.3}
local Speeds = {[_Q] = math.huge, [_W] = 2500, [_R] = math.huge}

-- Ignite
local ignite = nil

-- Using Items
local ITEMS = {
	zhonyaslot = nil,
	zhonyaready = false
}

-- Kill Steal
local enemyhealth = 0

-- Updater
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/bolchallengers/bol/master/scripts/Challengers_Cassiopeia.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local UPDATE_SCRIPT = false
local version = 1.0

function InfoMessage(msg)
	print("<font color=\"#FF9A00\"><b>Challengers Cassiopeia:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>")
end

function UpdateScript()
	if UPDATE_SCRIPT then
		local ServerData = GetWebResult(UPDATE_HOST, "/bolchallengers/bol/master/scripts/Challengers_Cassiopeia.version")
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


-- Load Libs
if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
	require("SxOrbWalk")
end

if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
end

if FileExist(LIB_PATH .. "/SourceLib.lua") then
	require("SourceLib")
end

function OnLoad()
	-- Load Libs
	VP = VPrediction()

	-- Check Update
	UpdateScript()

	-- Fix item casting issue
	fixItems()

	-- Load Menu
	Menu = scriptConfig("Challengers Cassiopeia", "Cassiopeia")

	Menu:addSubMenu("["..myHero.charName.."] - Orbwalk Settings", "orbwalk")
		SxOrb:LoadToMenu(Menu.orbwalk)

	Menu:addSubMenu("["..myHero.charName.."] - Key Settings", "Keys")
		Menu.Keys:addParam("comboKey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Keys:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("z"))

	Menu:addSubMenu("["..myHero.charName.."] - Harass Settings", "Harass")
		Menu.Harass:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
		Menu.Harass:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Combo Settings", "Combo")
		Menu.Combo:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
		Menu.Combo:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addSubMenu("["..myHero.charName.."] - Ultimate Settings", "ultimate") 
			Menu.Combo.ultimate:addParam("useR", "Use (R) if enemy killable", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - KS Settings", "KS")
		Menu.KS:addParam("useKS", "Use Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Menu.KS:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Farm Settings", "Farm")
		Menu.Farm:addParam("useQ",  "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freeze", "LaneClear", "Both" })
		Menu.Farm:addParam("useW",  "Use W", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" })
		Menu.Farm:addParam("useE",  "Use E", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" })
		Menu.Farm:addParam("useFreeze", "Farm freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
		Menu.Farm:addParam("useLaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))

	Menu:addSubMenu("["..myHero.charName.."] - Misc Settings", "Misc")
		Menu.Misc:addSubMenu("["..myHero.charName.."] - Humanizer Settings", "humanizer")
			Menu.Misc.humanizer:addParam("useDelay", "Use Delay on (E)", SCRIPT_PARAM_ONOFF, true)
			Menu.Misc.humanizer:addParam("delay", "Delay (E)", SCRIPT_PARAM_SLICE, 0.5, 0, 3, 1)
		Menu.Misc:addSubMenu("["..myHero.charName.."] - Items Settings", "Items") 
			Menu.Misc.Items:addParam("useZhonya", "Use Zhonya", SCRIPT_PARAM_ONOFF, true)
			Menu.Misc.Items:addParam("zhonyaHp", "% hp to Zhonya", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.."] - Draw Settings", "Draw")
		Menu.Draw:addParam("drawQ", "Draw (Q)", SCRIPT_PARAM_ONOFF, false)
		Menu.Draw:addParam("drawW", "Draw (W)", SCRIPT_PARAM_ONOFF, false)
		Menu.Draw:addParam("drawE", "Draw (E)", SCRIPT_PARAM_ONOFF, false)

	-- Perma Shows
	Menu.Keys:permaShow("comboKey")
	Menu.Keys:permaShow("harassKey")

	-- Spell Data
	Q = Spell(_Q, Ranges[_Q])
	W = Spell(_W, Ranges[_W])
	E = Spell(_E, Ranges[_E])
	R = Spell(_R, Ranges[_R])

	Q:SetSkillshot(VP, SKILLSHOT_LINEAR, Widths[_Q], Delays[_Q], Speeds[_Q], false)
	W:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Widths[_W], Delays[_W], Speeds[_R], false)
	R:SetSkillshot(VP, SKILLSHOT_CONE, Widths[_R], Delays[_R], Speeds[_R], false)

	Q:SetAOE(true)
	W:SetAOE(true)
	R:SetAOE(true, R.width, 0)

	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, Ranges[_E], DAMAGE_MAGIC, true)
	ts.name = "[Cassiopeia]"
	Menu:addTS(ts)

	-- Minions
	enemyMinions = minionManager(MINION_ENEMY,  Ranges[__W], myHero, MINION_SORT_MAXHEALTH_DEC)

	-- Ignite check
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
		ignite = SUMMONER_2
	end

	InfoMessage("Version: ".. version .. " loaded!")
end

function OnTick()
	ts:update()
	target = ts.target

	ITEMS.zhonyaslot = GetInventorySlotItem(3157)
	ITEMS.zhonyaready = (ITEMS.zhonyaslot ~= nil and myHero:CanUseSpell(ITEMS.zhonyaslot) == READY)

	if Menu.Misc.Items.useZhonya then
		CheckZhonya()
	end

	if Menu.Keys.comboKey then
		Combo()
	end

	if Menu.KS.useKS and Menu.KS.ignite and ignite ~= nil then
		AutoIgnite()
	end

	if Menu.Keys.harassKey then
		Harass()
	end
	
	if Menu.Farm.LaneClear or Menu.Farm.Freeze then
		Farm()
	end

	if Menu.Keys.clearKey then
		LaneClear()
	end

	if Menu.Misc.humanizer.useDelay then
		if not HELPERS.E.canuse then
			if (os.clock() - HELPERS.E.last) > HELPERS.E.delay then
				HELPERS.E.canuse = true
			end
		end
	end
end

function isTargetPoisoned(uint)
	for i = 1, uint.buffCount do
		local tBuff = uint:getBuff(i)
		if BuffIsValid(tBuff) and tBuff.name:find("poison") and (tBuff.endT - (math.min(GetDistance(myHero.visionPos, uint.visionPos), 700)/1900 + 0.25 + GetLatency()/2000) - GetGameTimer() > 0) then
			return true
		end
	end

	return false
end

function Combo()
	if ValidTarget(target) then
		if Q:IsReady() and Menu.Combo.useQ then 
			if GetDistance(target) <= Ranges[_Q] then
				Q:Cast(target)
			end
		end

		if W:IsReady() and Menu.Combo.useW then
			if GetDistance(target) <= Ranges[_Q] then
				W:Cast(target)
			end
		end

		if E:IsReady() and Menu.Combo.useE then
			if GetDistance(target) <=  Ranges[_E] and isTargetPoisoned(target) then
				E:Cast(target)
			end
		end

		if R:IsReady() and Menu.Combo.ultimate.useR then
			if GetDistance(target) <= Ranges[_R] then
				local dmgR = getDmg("R", unit, myHero)
				if unit.health <= dmgR then
					R:SetAOE(true, R.width, CountObjectsNearPos(Vector(target), 500, 500, SelectUnits(GetEnemyHeroes(), function(t) return ValidTarget(t) end)))
					R:Cast(target)
					R:SetAOE(true)
				end
			end
		end
	end
end

function AutoIgnite()
	if myHero:CanUseSpell(ignite) == READY then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 600) and enemy.health <= getDmg("IGNITE", enemy, myHero) then
				CastSpell(ignite, enemy)
			end
		end
	end
end

function Harass()
	if ValidTarget(target) then
		if Q:IsReady() and Menu.Harass.useQ then 
			if GetDistance(target) <= Ranges[_Q] then
				Q:Cast(target)
			end
		end

		if W:IsReady() and Menu.Harass.useW then
			if GetDistance(target) <= Ranges[_Q] then
				W:Cast(target)
			end
		end

		if E:IsReady() and Menu.Harass.useE then
			if GetDistance(target) <=  Ranges[_E] and isTargetPoisoned(target) then
				E:Cast(target)
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	local useQ = Menu.Farm.LaneClear and (Menu.Farm.useQ >= 3) or (Menu.Farm.useQ == 2)
	local useW = Menu.Farm.LaneClear and (Menu.Farm.useW >= 3) or (Menu.Farm.useW == 2)
	local useE = Menu.Farm.LaneClear and (Menu.Farm.useE >= 3) or (Menu.Farm.useE == 2)

	if useQ then
		if Menu.Farm.Freeze then
			for i, minion in ipairs(enemyMinions.objects) do
				if VP:GetPredictedHealth(minion, Delays[_Q] + 0.25) - 50 < 0 and Q:IsReady() then
					CastSpell(_Q, minion.visionPos.x, minion.visionPos.z)
					break
				end
			end
		end

		if Menu.Farm.LaneClear then
			local AllMinions = SelectUnits(enemyMinions.objects, function(t) return ValidTarget(t) end)
			AllMinions = GetPredictedPositionsTable(VP, AllMinions, Delays[_Q], Widths[_Q], Ranges[_Q] + Widths[_Q], math.huge, myHero, false)
			local BestPos, BestHit = GetBestCircularFarmPosition(Ranges[_Q] + Widths[_Q], Widths[_Q], AllMinions)

			if BestPos and Q:IsReady() then
				CastSpell(_Q, BestPos.x, BestPos.z)
			end
		end
	end

	if useW then
		local CasterMinions = SelectUnits(enemyMinions.objects, function(t) return (t.charName:lower():find("wizard") or t.charName:lower():find("caster")) and ValidTarget(t) end)
		CasterMinions = GetPredictedPositionsTable(VP, CasterMinions, Delays[_W], Widths[_W], Ranges[_W], Speeds[_W], myHero, false)

		local BestPos, BestHit = GetBestCircularFarmPosition(Ranges[_W], Widths[_W]*1.5, CasterMinions)
		if BestHit > 2 and W:IsReady() then
			CastSpell(_W, BestPos.x, BestPos.z)
			do return end
		end
	end

	if useE then
		local PoisonedMinions = SelectUnits(enemyMinions.objects, function(t) return ValidTarget(t) and isTargetPoisoned(t) end)
		for i, minion in ipairs(PoisonedMinions) do
			local time = 0.25 + 1900 / GetDistance(minion.visionPos, myHero.visionPos) + 0.1
			if VP:GetPredictedHealth(minion, time) - DLib:CalcSpellDamage(minion, _E) < 0 and E:IsReady() then
				CastSpell(_E, minion)
				break
			end
		end
	end
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
	if Menu.Draw.drawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, RANGE.Q, ARGB(255, 51, 153, 255))
	end

	if Menu.Draw.drawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, RANGE.W, ARGB(255, 102, 178 , 0 ))
	end

	if Menu.Draw.drawE then
		DrawCircle(myHero.x, myHero.y, myHero.z,  Ranges[_E], ARGB(255, 178, 0 , 0 ))
	end

end

function random(min, max, precision)
	local precision = precision or 0
	local num = math.random()
	local range = math.abs(max - min)
	local offset = range * num
	local randomnum = min + offset
	return math.floor(randomnum * math.pow(10, precision) + 0.5) / math.pow(10, precision)
end

function GetSlotItem(id, unit)
	unit = unit or myHero

	if (not ItemNames[id]) then
		return ___GetInventorySlotItem(id, unit)
	end

	local name = ItemNames[id]
	for slot = ITEM_1, ITEM_7 do
		local item = unit:GetSpellData(slot).name
		if ((#item > 0) and (item:lower() == name:lower())) then
			return slot
		end
	end
end