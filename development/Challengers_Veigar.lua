--[[
		   ________          ____                               
		  / ____/ /_  ____ _/ / /__  ____  ____ ____  __________
		 / /   / __ \/ __ `/ / / _ \/ __ \/ __ `/ _ \/ ___/ ___/
		/ /___/ / / / /_/ / / /  __/ / / / /_/ /  __/ /  (__  ) 
		\____/_/ /_/\__,_/_/_/\___/_/ /_/\__, /\___/_/  /____/  
		                                /____/                                               
									Veigar
	========================================================================

	Changelog!
	Version: 1.0
		* Costomizable Key Settings.
		* Costomizable Harass, use Q, W, E.
		* Customizable Full combo. change "QEWR", "EQWR.
		* Customizable KS settings using skills and ignite.
		* Customizable farm with Q, W.
]]-- 

if myHero.charName ~= "Veigar" then
	return
end

-- Load Libs
local VP = nil
require("VPrediction")

-- Ranges
local RANGE = {
	Q = 675,
	W = 375,
	E = 700,
	R = 550
}

-- Ignite
local ignite = nil
local iDamage = 0
local iReady = false

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

-- Updater
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/bolchallengers/bol/master/scripts/Challengers_Veigar.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local UPDATE_SCRIPT = false
local version = 1.0

function InfoMessage(msg)
	print("<font color=\"#FF9A00\"><b>Challengers Veigar:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>")
end

function UpdateScript()
	if UPDATE_SCRIPT then
		local ServerData = GetWebResult(UPDATE_HOST, "/bolchallengers/bol/master/scripts/Challengers_Veigar.version")
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
	else
		InfoMessage("Auto Update Disabled!")
	end
end

function OnLoad()
	-- Check Update
	UpdateScript()

	-- Load Menu
	Menu = scriptConfig("Challengers Veigar", "Veigar")

	Menu:addSubMenu("["..myHero.charName.."] - Key Settings", "Keys")
		Menu.Keys:addParam("comboKey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Keys:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("M"))
		Menu.Keys:addParam("farmKey", "Farm On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("N"))
		Menu.Keys:addParam("clearKey", "Lane Clear On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))

	Menu:addSubMenu("["..myHero.charName.."] - Harass Settings", "Harass")
		Menu.Harass:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
		Menu.Harass:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Combo Settings", "Combo")
		Menu.Combo:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
		Menu.Combo:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addSubMenu("["..myHero.charName.."] - Ultimate Settings", "ultimate") 
			Menu.Combo.ultimate:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, true)
			Menu.Combo.ultimate:addParam("ultMode", "Ultimate Mode", SCRIPT_PARAM_LIST, 2, {"Aways", "If Killable"})

	Menu:addSubMenu("["..myHero.charName.."] - KS Settings", "KS")
		Menu.KS:addParam("useKS", "Use Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Menu.KS:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.KS:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.KS:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Farm Settings", "Farm")
		Menu.Farm:addParam("useQFarm", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Farm:addParam("useWFarm", "Use (W)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "LaneClear")
		Menu.LaneClear:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.LaneClear:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.LaneClear:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.."] - Misc Settings", "Misc")
		Menu.Misc:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
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
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, RANGE.Q, DAMAGE_MAGIC, true)
	ts.name = "[Veigar]"
	Menu:addTS(ts)

	-- Minions
	enemyMinions = minionManager(MINION_ENEMY, RANGE.Q, myHero, MINION_SORT_MAXHEALTH_DEC)
	allyMinions = minionManager(MINION_ALLY, RANGE.Q, myHero, MINION_SORT_MAXHEALTH_DEC)
	jungleMinions = minionManager(MINION_JUNGLE, RANGE.Q, myHero, MINION_SORT_MAXHEALTH_DEC)
	otherMinions = minionManager(MINION_OTHER, RANGE.Q, myHero, MINION_SORT_MAXHEALTH_DEC)

	-- Ignite check
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
		ignite = SUMMONER_2
	end

	-- Load Libs
	VP = VPrediction()

	InfoMessage("Version: ".. version .. " loaded!")
end

function OnTick()
	ts:update()
	target = ts.target

	CHECKS.Q = (myHero:CanUseSpell(_Q) == READY)
	CHECKS.W = (myHero:CanUseSpell(_W) == READY) 
	CHECKS.E = (myHero:CanUseSpell(_E) == READY)
	CHECKS.R = (myHero:CanUseSpell(_R) == READY)

	ITEMS.zhonyaslot = GetInventorySlotItem(3157)
	ITEMS.zhonyaready = (ITEMS.zhonyaslot ~= nil and myHero:CanUseSpell(ITEMS.zhonyaslot) == READY)

	iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

	if Menu.Misc.Items.useZhonya then
		CheckZhonya()
		return
	end

	if Menu.Keys.comboKey then
		Combo()
		return
	end

	if Menu.Keys.harassKey then
		Harass()
		return
	end

	if Menu.Misc.ignite then
		AutoIgnite(target)
		return
	end

	if Menu.Keys.farmKey then
		Farm()
		return
	end

	if Menu.Keys.clearKey then
		LaneClear()
		return
	end

	if Menu.KS.useKS then
		KillSteal()
		return
	end
end

function Combo()
	if ValidTarget(target) then
		if Menu.Combo.ultimate.ultMode == 1 then
			if Menu.Combo.useE then
				if GetDistance(target) <= RANGE.E and CHECKS.E then
					CastSpell(_E, target.x, target.z)
				end
			end

			if Menu.Combo.useQ then 
				local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, SPELLS.Q.delay, SPELLS.Q.width, SPELLS.Q.range, SPELLS.Q.speed, myHero, false)
				if HitChance >= 2 and CHECKS.Q and GetDistance(CastPosition) <= RANGE.Q then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end

			if Menu.Combo.useW then
				local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, SPELLS.W.delay, SPELLS.W.width, SPELLS.W.range, SPELLS.W.speed, myHero, false)
				if HitChance >= 2 and CHECKS.W and GetDistance(CastPosition) <= RANGE.W then
					CastSpell(_W, CastPosition.x, CastPosition.z)
				end
			end

			if Menu.Combo.ultimate.useR then
				if GetDistance(target) <= RANGE.R then
					CastSpell(_R, target)
				end
			end
		elseif Menu.Combo.ultimate.ultMode == 2 then
			if Menu.Combo.useE then
				if CHECKS.E and GetDistance(target) <= RANGE.E then
					CastSpell(_E, target.x, target.z)
				end
			end

			if Menu.Combo.useQ then 
				local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, SPELLS.Q.delay, SPELLS.Q.width, SPELLS.Q.range, SPELLS.Q.speed, myHero, false)
				if HitChance >= 2 and CHECKS.Q and GetDistance(CastPosition) <= RANGE.Q then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end

			if Menu.Combo.useW then
				local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, SPELLS.W.delay, SPELLS.W.width, SPELLS.W.range, SPELLS.W.speed, myHero, false)
				if HitChance >= 2 and CHECKS.W and GetDistance(CastPosition) <= RANGE.W then
					CastSpell(_W, CastPosition.x, CastPosition.z)
				end
			end

			if Menu.Combo.ultimate.useR then
				if CHECKS.R and GetDistance(target) <= RANGE.R and target.health < getDmg("R", target, myHero) then
					CastSpell(_R, target)
				end
			end
		end
	end
end

function AutoIgnite(enemy)
  	iDamage = ((iReady and getDmg("IGNITE", enemy, myHero)) or 0) 
	if enemy.health <= iDamage and GetDistance(enemy) <= 600 and ignite ~= nil then
		if iReady then
			CastSpell(ignite, enemy)
		end
	end
end

function KillSteal()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) and GetDistance(enemy) < 700 then
			if Menu.KS.useQ then
				if CHECKS.Q and getDmg("Q", enemy, myHero) > enemy.health then
					CastSpell(_Q, enemy)
				end
			end

			if Menu.KS.useW then
				if CHECKS.W and getDmg("W", enemy, myHero) > enemy.health then
					CastSpell(_W)
				end
			end
			
			if Menu.KS.useE then
				if CHECKS.E and getDmg("E", enemy, myHero) > enemy.health then
					CastSpell(_E, enemy)
				end
			end

			if Menu.KS.ignite and ignite ~= nil then
				AutoIgnite()
			end
		end
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