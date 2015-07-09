if myHero.charName ~= "Katarina" then return end

-- Ult Helper
local lastAnimation = ""
local ultActive = false
local deathLothusTime = 0

-- Ranges
local wRange = 375
local eRange = 700
local qRange = 675
local rRange = 550

-- Ignite
local ignite = nil
local igniteDMG = 0

-- Checks
local QREADY, WREADY, EREADY, RREADY = false

function OnLoad()
	Config = scriptConfig("Katarina Master", "Katarina")

	Config:addSubMenu(myHero.charName.." Key Settings", "Keys")
	Config.Keys:addParam("comboKey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config.Keys:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("M"))
	Config.Keys:addParam("FarmKey", "Farm On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("N"))

	Config:addSubMenu(myHero.charName.." Haras Settings", "Haras")
	Config.Haras:addParam("useQHarass", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
	Config.Haras:addParam("useWHarass", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
	Config.Haras:addParam("useEHarass", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Config:addSubMenu(myHero.charName.." Combo Settings", "Combo")
	Config.Combo:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
	Config.Combo:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
	Config.Combo:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true) 
	Config.Combo:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, true)

	Config:addSubMenu(myHero.charName.." KS Settings", "KS")
	Config.KS:addParam("ksWithQ", "KS with Q", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksWithW", "KS with W", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksWithE", "KS with E", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksWithIgnite", "KS with ignite", SCRIPT_PARAM_ONOFF, true)

	Config:addSubMenu(myHero.charName.." Farm", "Farm")
	Config.Farm:addParam("useQFarm", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.Farm:addParam("useWFarm", "Use W", SCRIPT_PARAM_ONOFF, true)

	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, eRange)
	ts.name = "Katarina"
	Config:addTS(ts)
	enemyMinions = minionManager(MINION_ENEMY, qRange, myHero, MINION_SORT_MAXHEALTH_DEC)

	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
		ignite = SUMMONER_1 
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
		ignite = SUMMONER_2 
	end

	PrintChat(">> Katarina Master by Challengers loaded!")
end

function OnTick()
	Checks()
	IgniteKS()

	if Config.Keys.comboKey then
		Combo()
	end

	if Config.Keys.harassKey then
		Harass()
	end

	if Config.Keys.FarmKey then
		Farm()
	end
end

function Checks()
	ts:update()
	target = ts.target

	ultActive = GetTickCount() <= deathLothusTime + GetLatency() + 50 or lastAnimation == "Spell4"

	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY) 
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY) 
end

function Combo()
	if ValidTarget(target) then
		if EREADY and Config.Combo.useE then
			if GetDistance(target) <= eRange then
				CastSpell(_E, target)
			end
		end

		if QREADY and Config.Combo.useQ then 
			if GetDistance(target) <= qRange then
				CastSpell(_Q, target) 
			end
		end

		if WREADY and Config.Combo.useW then
			if GetDistance(target) <= wRange then
				CastSpell(_W)
			end
		end

		if RREADY and not QREADY and not WREADY and not EREADY and Config.Combo.useR then
			if GetDistance(target) <= rRange then
				deathLothusTime = GetTickCount()
				CastSpell(_R)
			end
		end
	end
end


function AutoIgnite(enemy)
	igniteDMG = ((IREADY and getDmg("IGNITE", enemy, myHero)) or 0)
	if enemy.health <= igniteDMG and GetDistance(enemy) <= 600 and ignite ~= nil then
		if IREADY then
			CastSpell(ignite, enemy)
		end 
	end
end

function IgniteKS()
	if ValidTarget(target) then
		if Config.KS.ksWithIgnite then
			AutoIgnite(target)
		end
	end
end

function KillSteal()
	for i, enemy in ipairs(e) do
		if ValidTarget(enemy) and GetDistance(enemy) < 700 then
		if Config.KS.ksWithQ then
			if QReady and getDmg("Q", enemy, myHero) > enemy.health then
				CastSpell(_Q, enemy)
				end
			end

			if Config.KS.ksWithW then
				if WReady and getDmg("W", enemy, myHero) > enemy.health then
					CastSpell(_W)
				end
			end
			
			if Config.KS.ksWithE then
				if EReady and getDmg("E", enemy, myHero) > enemy.health then
					CastSpell(_E, enemy)
				end
			end
		end
	end
end


function OnAnimation(unit, animationName)
	if unit.isMe and lastAnimation ~= animationName then
		lastAnimation = animationName
	end
end

function Harass()
	if not target then
		return
	end

	if ValidTarget(target) then
		if EREADY and Config.Haras.useEHarass then
			if GetDistance(target) <= eRange then
				CastSpell(_E, target)
			end
		end

		if QREADY and Config.Haras.useQHarass then 
			if GetDistance(target) <= qRange then
				CastSpell(_Q, target) 
			end
		end

		if WREADY and Config.Haras.useWHarass then
			if GetDistance(target) <= wRange then
				CastSpell(_W)
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in ipairs(enemyMinions.objects) do
		if Config.Farm.useQFarm then
			if ValidTarget(minion) and GetDistance(minion) <= qRange and QREADY and getDmg("Q", minion, myHero) > minion.health then
				CastSpell(_Q, minion)
			end
		end
	end
	
	for i, minion in ipairs(enemyMinions.objects) do
		if Config.Farm.useWFarm then
			if ValidTarget(minion) and GetDistance(minion) <= wRange and WREADY and getDmg("W", minion, myHero) > minion.health then
				CastSpell(_W)
			end
		end
	end
end