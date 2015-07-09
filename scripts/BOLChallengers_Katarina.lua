if myHero.charName ~= "Katarina" then return end

local e = {}
local lastAnimation = ""
local ultActive = false
local timeult = 0

lastE = 0
eDelay = 3500 -- 3,5 seconds


local Wrange = 375
local Erange = 700
local Qrange = 675
local Rrange = 550
local ignite = nil
local iDMG = 0

local ignite, iDMG = nil, 0 
local QREADY, WREADY, EREADY, RREADY = false

function OnLoad()
	Config = scriptConfig("Katarina Master", "Katarina")

	Config:addSubMenu(myHero.charName.." Key Settings", "Keys")
	Config.Keys:addParam("combokey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config.Keys:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("M"))
	Config.Keys:addParam("farmkey", "Farm On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("N"))

	Config:addSubMenu(myHero.charName.." Haras Settings", "Haras")
	Config.Haras:addParam("UseQHaras", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
	Config.Haras:addParam("UseWHaras", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
	Config.Haras:addParam("UseEHaras", "Use (E)", SCRIPT_PARAM_ONOFF, true)

	Config:addSubMenu(myHero.charName.." Combo Settings", "Combo")
	Config.Combo:addParam("UseQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
	Config.Combo:addParam("UseW", "Use (W)", SCRIPT_PARAM_ONOFF, true) 
	Config.Combo:addParam("UseE", "Use (E)", SCRIPT_PARAM_ONOFF, true) 
	Config.Combo:addParam("UseR", "Use (R)", SCRIPT_PARAM_ONOFF, true)
	Config.Combo:addParam("UseEDel", "Humanizer", SCRIPT_PARAM_ONOFF, false)

	Config:addSubMenu(myHero.charName.." Misc", "Misc")
	Config.Misc:addParam("KSQ", "Auto KS with Q", SCRIPT_PARAM_ONOFF, true)
	Config.Misc:addParam("KSW", "Auto KS with W", SCRIPT_PARAM_ONOFF, true)
	Config.Misc:addParam("KSE", "Auto KS with E", SCRIPT_PARAM_ONOFF, true)
	Config.Misc:addParam("KSIG", "Auto KS using ignite", SCRIPT_PARAM_ONOFF, true)

	Config:addSubMenu(myHero.charName.." Farm", "farm")
	Config.farm:addParam("UseQFarm", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.farm:addParam("UseWFarm", "Use W", SCRIPT_PARAM_ONOFF, true)

	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, Erange)
	ts.name = "Katarina"
	Config:addTS(ts)
	enemyMinions = minionManager(MINION_ENEMY, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)

	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
		ignite = SUMMONER_1 
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
		ignite = SUMMONER_2 
	end

	allyHeroes = GetAllyHeroes()
	enemyHeroes = GetEnemyHeroes()
	enemyMinions = minionManager(MINION_ENEMY, Erange, player, MINION_SORT_HEALTH_ASC)
	JungleMobs = {}

	for i, enemy in ipairs(GetEnemyHeroes()) do
		table.insert(e, enemy)
	end


	PrintChat(">> Katarina Master loaded!")
end

function OnTick()
	Checks()
	IgniteKS()
	Human()

	if Config.Keys.combokey then
		Combo()
	end

	if Config.Keys.harass then
		Harass()
	end

	if Config.Keys.farmkey then
		Farm()
	end
end

function Checks()
	ts:update()
	target = ts.target

	ultActive = GetTickCount() <= timeult + GetLatency() + 50 or lastAnimation == "Spell4"

	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY) 
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY) 
end

function Combo()
	if ValidTarget(target) then
		if EREADY and Config.Combo.UseE then
			if GetDistance(target) <= Erange then
				CastSpell(_E, target)
			end
		end

		if QREADY and Config.Combo.UseQ then 
			if GetDistance(target) <= Qrange then
				CastSpell(_Q, target) 
			end
		end

		if WREADY and Config.Combo.UseW then
			if GetDistance(target) <= Wrange then
				CastSpell(_W)
			end
		end

		if RREADY and not QREADY and not WREADY and not EREADY and Config.Combo.UseR then
			if GetDistance(target) <= Rrange then
				timeult = GetTickCount()
				CastSpell(_R)
			end
		end
	end
end


function AutoIgnite(enemy)
	iDmg = ((IREADY and getDmg("IGNITE", enemy, myHero)) or 0)
	if enemy.health <= iDmg and GetDistance(enemy) <= 600 and ignite ~= nil then
		if IREADY then
			CastSpell(ignite, enemy)
		end 
	end
end

function IgniteKS()
	if ValidTarget(target) then
		if Config.Misc.KSIG then
			AutoIgnite(target)
		end
	end
end

function KillSteal()
	for i, enemy in ipairs(e) do
		if ValidTarget(enemy) and GetDistance(enemy) < 700 then
		if Config.Misc.KSQ then
			if QReady and getDmg("Q", enemy, myHero) > enemy.health then
				CastSpell(_Q, enemy)
				end
			end

			if Config.Misc.KSW then
				if WReady and getDmg("W", enemy, myHero) > enemy.health then
					CastSpell(_W)
				end
			end
			
			if Config.Misc.KSE then
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
		if EREADY and Config.Haras.UseEHaras then
			if GetDistance(target) <= Erange then
				CastSpell(_E, target)
			end
		end

		if QREADY and Config.Haras.UseQHaras then 
			if GetDistance(target) <= Qrange then
				CastSpell(_Q, target) 
			end
		end

		if WREADY and Config.Haras.UseWHaras then
			if GetDistance(target) <= Wrange then
				CastSpell(_W)
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in ipairs(enemyMinions.objects) do
		if Config.farm.UseQFarm then
			if ValidTarget(minion) and GetDistance(minion) <= Qrange and QREADY and getDmg("Q", minion, myHero) > minion.health then
				CastSpell(_Q, minion)
			end
		end
	end
	
	for i, minion in ipairs(enemyMinions.objects) do
		if Config.farm.UseWFarm then
			if ValidTarget(minion) and GetDistance(minion) <= Wrange and WREADY and getDmg("W", minion, myHero) > minion.health then
				CastSpell(_W)
			end
		end
	end
end

function Human()
	if lastE + eDelay > GetTickCount() then
		lastE = GetTickCount()
		Combo()
	end
end
