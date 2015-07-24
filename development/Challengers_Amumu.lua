--[[
		   ________          ____                               
		  / ____/ /_  ____ _/ / /__  ____  ____ ____  __________
		 / /   / __ \/ __ `/ / / _ \/ __ \/ __ `/ _ \/ ___/ ___/
		/ /___/ / / / /_/ / / /  __/ / / / /_/ /  __/ /  (__  ) 
		\____/_/ /_/\__,_/_/_/\___/_/ /_/\__, /\___/_/  /____/  
		                                /____/                                               
									   Amumu
	========================================================================

	Changelog!
	Version: 1.1
		* Fix Auto Smite.

	Version: 1.0
		* Costomizable Key Settings.
		* Customizable Full combo. With R if killable enemy.
		* Customizable KS settings using skills.
		* Lane clear with W.
		* Jungle cleaning.
		* Jungle Steal on Dragon/Baron.
		* Auto zhonyas.
]]-- 

if myHero.charName ~= "Amumu" then
	return
end

-- Load Libs
if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
end

-- Info
local version = 1.1

-- Updater
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/bolchallengers/bol/master/scripts/Challengers_Amumu.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function InfoMessage(msg)
	print("<font color=\"#6699ff\"><b>Challengers Amumu:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>")
end

local ServerData = GetWebResult(UPDATE_HOST, "/bolchallengers/bol/master/scripts/Challengers_Amumu.version")
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

-- Variables
local VARS = {
	despair = false,
	inRange = false
}

-- Ranges
local RANGE = {
	Q = 1100,
	W = 300,
	E = 250,
	R = 550
}

-- Summoner Spells
local smiteslot = nil
local SMITEREADY
local smiterange = 500

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

-- Target selector
local ts = nil

function OnLoad()
	-- Load Menu
	Menu = scriptConfig("Challengers Amumu", "Amumu")
	Menu:addSubMenu("["..myHero.charName.."] - Key Settings", "Keys")
		Menu.Keys:addParam("comboKey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Keys:addParam("clearKey", "Lane / Jungle Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("L"))

	Menu:addSubMenu("["..myHero.charName.."] - Combo Settings", "Combo")
		Menu.Combo:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
		Menu.Combo:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useR", "Use R if killable", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - KS Settings", "KS")
		Menu.KS:addParam("useQ", "KS with (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.KS:addParam("useW", "KS with (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.KS:addParam("useE", "KS with (E)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Lane / Jungle Clear Settings", "LaneClear")
		Menu.LaneClear:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.LaneClear:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.LaneClear:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Jungle clear Settings", "JungleSettings")
		Menu.JungleSettings:addParam("finishSmite", "Finish with Smite", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Misc Settings", "Misc")
		Menu.Misc:addParam("ManaManager", "Do not use W under Mana %",SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
		Menu.Misc:addSubMenu("["..myHero.charName.."] - Items Settings", "Items") 
			Menu.Misc.Items:addParam("useZhonya", "Use Zhonya", SCRIPT_PARAM_ONOFF, true)
			Menu.Misc.Items:addParam("zhonyaHp", "% hp to Zhonya", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.."] - Draw Settings", "Draw")
		Menu.Draw:addParam("drawQ", "Draw (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Draw:addParam("drawW", "Draw (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.Draw:addParam("drawE", "Draw (E)", SCRIPT_PARAM_ONOFF, true)

	-- Perma Shows
	Menu.Keys:permaShow("comboKey")
	Menu.Keys:permaShow("clearKey")

	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, RANGE.Q, DAMAGE_MAGIC, true)
	ts.name = "[Amumu]"
	Menu:addTS(ts)

	-- Load predict
	VP = VPrediction()

	-- Minions
	enemyMinions = minionManager(MINION_ENEMY, RANGE.Q, myHero, MINION_SORT_MAXHEALTH_DEC)
	jungleMinions = minionManager(MINION_JUNGLE, RANGE.Q, myHero, MINION_SORT_MAXHEALTH_DEC)

	-- Check Spells Slots
	if myHero:GetSpellData(SUMMONER_1).name:lower():find("smite") then
		smiteslot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("smite") then
		smiteslot = SUMMONER_2
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
	end

	if Menu.Keys.clearKey and Menu.JungleSettings.steal then
		RANGE.Q = 1100
		if smiteslot ~= nil then
			JungleSteal()
		end
	end

	if Menu.Keys.clearKey then
		LaneClear()
	end

	KillSteal()
end

function Checks()
	ts:update()
	target = ts.target

	CHECKS.Q = (myHero:CanUseSpell(_Q) == READY)
	CHECKS.W = (myHero:CanUseSpell(_W) == READY) 
	CHECKS.E = (myHero:CanUseSpell(_E) == READY)
	CHECKS.R = (myHero:CanUseSpell(_R) == READY)

	ITEMS.zhonyaslot = GetInventorySlotItem(3157)
	ITEMS.zhonyaready = (ITEMS.zhonyaslot ~= nil and myHero:CanUseSpell(ITEMS.zhonyaslot) == READY)

	VARS.inRange = false

	if smiteslot ~= nil then
		SMITEREADY = (myHero:CanUseSpell(smiteslot) == READY)
	end
end

function ObjectInArea(range, objects)
	for i, object in ipairs(objects) do
		if ValidTarget(object, range) then
			return true
		end
	end
	return false
end

function CheckW()
	if target and ValidTarget(target) and not target.dead and (myHero.mana / myHero.maxMana > Menu.Misc.ManaManager / 100) then
		VARS.inRange = true
	else
		VARS.inRange = false
	end

	if CHECKS.W and not VARS.despair and VARS.inRange then
		CastSpell(_W)
		VARS.despair = true
	end
end

function FinishDespair(myTarget)
	if myTarget == nil or GetDistance(myTarget) > RANGE.W then
		if VARS.despair then
			CastSpell(_W)
		end
	end
end

function GetSmiteDamage()
	if not SMITEREADY then
		return 0
	end

	return math.max(20 * myHero.level + 370, 30 * myHero.level + 330, 40 * myHero.level + 240, 50 * myHero.level + 100)
end

function JungleSteal()
	jungleMinions:update()
	target = nil
	for i, minion in pairs(jungleMinions.objects) do
		if ValidTarget(minion) and minion.visible and minion.health > 0 and minion.charName:lower():find("dragon") then
			target = minion
		elseif ValidTarget(minion) and minion.visible and minion.health > 0 and minion.charName:lower():find("worm") then
			target = minion
		end
	end

	if target ~= nil and ValidTarget(target) then
		local smiteDmg = 0
		local qDmg = 0
		local totalDamage = 0
		if CHECKS.Q then
			qDmg = getDmg("Q", target, myHero) end
			if SMITEREADY then
				smiteDmg = GetSmiteDamage()
			end
			
		totalDamage = smiteDmg + qDmg
		if totalDamage >= target.health then
			if ValidTarget(target, RANGE.Q) then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.25, 80, RANGE.Q, 2000, myHero, true)
				if HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end

		if ValidTarget(target, smiterange) then
			CastSpell(smiteslot, target)
			return
		end
	end

	-- Steal Big Minions
	if Menu.JungleSettings.finishSmite and smiteslot ~= nil and ValidTarget(target, smiterange) and CheckBigMinion(target) and target.health < smiteDmg then
		CastSpell(smiteslot, target)
		return
	end
end


function CheckBigMinion(minion)
	if minion and ValidTarget(minion, RANGE.W) then
		if minion.charName:lower():find("blue") and not minion.charName:lower():find("mini") then return true end
		if minion.charName:lower():find("red") and not minion.charName:lower():find("mini") then return true end
		if minion.charName:lower():find("murkwolf") and not minion.charName:lower():find("mini") then return true end
		if minion.charName:lower():find("razorbeak") and not minion.charName:lower():find("mini") then return true end
		if minion.charName:lower():find("krug") and not minion.charName:lower():find("mini") then return true end
		if minion.charName:lower():find("gromp") then return true end
		if minion.charName:lower():find("crab") then return true end
		if minion.charName:lower():find("dragon") then return true end
		if minion.charName:lower():find("baron") then return true end
	end
	return false
end

function Combo()
	if myHero.dead and not target then
		return
	end

	if target and ValidTarget(target) and not target.dead and target.visible  then
		if CHECKS.Q and Menu.Combo.useQ and GetDistance(target) <= RANGE.Q then 
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.25, 80, RANGE.Q, 2000, myHero, true)
			if HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end

		if CHECKS.W and Menu.Combo.useW and ObjectInArea(RANGE.W, GetEnemyHeroes()) then
			CheckW()
		end

		if CHECKS.E and Menu.Combo.useE and GetDistance(target) <= RANGE.E then
			CastSpell(_E)
		end

		if CHECKS.R and Menu.Combo.useR  and ValidTarget(target, RANGE.R) then
			if GetDistance(target) <= RANGE.R then
				if target.health < getDmg("R", target, myHero) then
					CastSpell(_R)
				end
			end
		end
	end
end

function KillSteal()
	if myHero.dead then
		return
	end

	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) and enemy.visible then
			if Menu.KS.useQ then
				if CHECKS.Q and getDmg("Q", enemy, myHero) > enemy.health then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(enemy, 0.25, 80, RANGE.Q, 2000, myHero, true)
					if HitChance >= 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
					end
				end
			end

			if Menu.KS.useW then
				if CHECKS.W and getDmg("W", enemy, myHero) > enemy.health and ObjectInArea(RANGE.W, GetEnemyHeroes()) then
					CheckW()
				end
			end
			
			if Menu.KS.useE then
				if CHECKS.E and getDmg("E", enemy, myHero) > enemy.health then
					CastSpell(_E, enemy)
				end
			end
		end
	end
end

function LaneClear()
	target = nil
	jungleMinions:update()
	
	for i, minion in ipairs(jungleMinions.objects) do
		if ValidTarget(minion, 600) and (target == nil or not ValidTarget(target)) then
			target = minion
		end
	end

	if target ~= nil and ValidTarget(target) then
		local smiteDmg = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
		if Menu.JungleSettings.finishSmite and smiteslot ~= nil and SMITEREADY and ValidTarget(target, smiterange) and CheckBigMinion(target) and target.health < smiteDmg then
			CastSpell(smiteslot, target)
			return
		end


		if Menu.LaneClear.useQ and CHECKS.Q then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.25, 80, RANGE.Q, 2000, myHero, true)
			if HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end

		if Menu.LaneClear.useW and CHECKS.W and ObjectInArea(RANGE.W, jungleMinions.objects) then
			CheckW()
		end

		if Menu.LaneClear.useE then
			CastSpell(_E, target)
		end
	end


	target = nil
	enemyMinions:update()
	for i, minion in ipairs(enemyMinions.objects) do
		if ValidTarget(minion, 600) and (target == nil or not ValidTarget(target)) then
			target = minion
		end
	end

	if target ~= nil then
		if Menu.LaneClear.useQ and CHECKS.Q then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.25, 80, RANGE.Q, 2000, myHero, true)
			if HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end

		if Menu.LaneClear.useW and CHECKS.W and ObjectInArea(RANGE.W, enemyMinions.objects) then
			CheckW()
		end

		if Menu.LaneClear.useE then
			CastSpell(_E, target)
		end
	end

	FinishDespair(target)
end

function OnDeleteObj(obj)
	if obj.name == "Despair_buf.troy" then
		VARS.despair = false
	end
end

function CheckZhonya()
	if Menu.Misc.Items.useZhonya then
		if ITEMS.zhonyaready and ((myHero.health/myHero.maxHealth)*100) <= Menu.Misc.Items.zhonyaHp then
			CastSpell(ITEMS.zhonyaslot)
		end
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

function Round(number)
	if number >= 0 then 
		return math.floor(number+.5) 
	else 
		return math.ceil(number-.5) 
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