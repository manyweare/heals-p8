--manager

--entity counters
live_es_c, spawning_es_c, dead_es_c, healed_es_c = 0, 0, 0, 0
--enemy counters
live_ens_c, spawning_ens_c, dead_ens_c, en_wave_c = 0, 0, 0, 0
--manager stats
xpmax, xpmod, lvl_cap, boss_is_active = 5, 1, 25, false

function init_manager()
	lvlup_options = {}
end

function resume_game()
	_update = update_game
	_draw = draw_game
end

function cheat()
	-- if btn(4) then
	-- 	lvlup()
	-- 	_update = update_upgrade
	-- 	_draw = draw_upgrade
	-- end
end

function update_spawner()
	-- debug --
	if btnp(🅾️) then
		if rndf(0, 1) > .4 then
			spawn_es("t")
		else
			spawn_es("m")
		end
	end
	if btnp(❎) then
		local r = rndf(0, 1)
		if r > .5 then
			spawn_ens("s")
		elseif r < .5 and r > .1 then
			spawn_ens("t")
		else
			spawn_ens("m")
		end
		en_wave_c += 1
	end
	-- spawning test --
	-- if playtime % 30 == 0 and live_es_c < 5 + round(plvl / 3) and #spawning_es == 0 then
	-- 	if rnd() > .5 then
	-- 		spawn_es("t")
	-- 	else
	-- 		spawn_es("m")
	-- 	end
	-- end
	-- if playtime % 120 == 0 and live_ens_c <= live_es_c and #spawning_ens == 0 then
	-- 	local r = rnd()
	-- 	if r >= .5 then
	-- 		spawn_ens("s")
	-- 	elseif r < .5 and r > .1 then
	-- 		spawn_ens("t")
	-- 	else
	-- 		spawn_ens("m")
	-- 	end
	-- 	en_wave_c += 1
	-- end
	-- if playtime % 1800 == 0 then
	-- 	local r = round(plvl / 2)
	-- 	spawn_ens("m", 1 * r)
	-- 	spawn_ens("t", 2 * r)
	-- 	spawn_ens("s", 3 * r)
	-- end
	--start spawning bosses and entities after 2m
	--     --miniboss every 3m
	--         --spawn miniboss
	--         --spawn adds
	--     --final boss at 10m
	--         --spawn boss
	--         --spawn adds
	--     --entity spawning--
end

function spawn_ens(class, num)
	num = num or 1
	for i = 1, num do
		local e, pos = {}, rand_in_circle(px, py, 64)
		if class == "s" then
			e = en_small:new(pos)
		elseif class == "m" then
			e = en_medium:new(pos)
		elseif class == "t" then
			e = en_turret:new(pos)
		end
		e:level_up()
		add(spawning_ens, e)
	end
end

function spawn_es(class, num)
	num = num or 1
	for i = 1, num do
		if #entities < 48 then
			local pos = rand_in_circle(63, 63, 64)
			local e, _e = {}, {
				x = pos.x,
				y = pos.y,
				flip = rnd() < .5,
				main_clrs = split("7, 7, 3, 15")
			}
			if class == "m" then
				e = e_melee:new(_e)
				e.tentacles = create_tentacles(6, e.x, e.y, 2, 1, 8, e.main_clrs)
			elseif class == "t" then
				e = e_turret:new(_e)
				e.tentacles = create_tentacles(4, e.x, e.y, 1.75, 1, 5, e.main_clrs)
			end
			e:level_up()
			local n = ceil(e.hpmax * .2)
			e.hp = rndi(n, e.hpmax - n)
			add(spawning_es, e)
		end
	end
end

-- leveling functions ---------

function addxp(n)
	n = n or 1
	if (plvl == lvl_cap) return
	local ovrxp = 0
	n *= xpmod
	--check for lvl up and overflow
	if curxp + n >= xpmax then
		ovrxp = (curxp + n) - xpmax
		curxp = ovrxp
		lvlup()
	else
		curxp += n
	end
	totalxp += n
end

--increases stat using leveling curve
function level_up_stat(steepness, factor, base_stat)
	base_stat = base_stat or 1
	return (steepness * log2(factor + 1) - 10) + base_stat
end

function heal_upgrade(h, stat)
	stat = stat or h.pwr
	h.lvl += 1
	h.pwr = level_up_stat(10, h.lvl, stat)
	if (h.type == "orb") max_h_orbs += 1
	if (h.type == "aoe") h.range = min(h.range + 2, 64)
end

function lvlup()
	sfx(-1)
	sfx(sfxt.lvlup)
	lvlup_f = 1
	plvl += 1
	hrange = level_up_stat(5, plvl, hrange)
	xpmax = round(level_up_stat(10, plvl, xpmax))
	p.hpmax = round(level_up_stat(10, plvl, p.hpmax))
	p.regen = round(level_up_stat(10, plvl, p.regen))
	if (plvl % 5 == 0) then
		add(p.tentacles, create_tentacle(59, 59, 2.2, 1, 7, split("7, 7, 7, 9")))
		--lengthen tentacles
		for i, t in inext, p.tentacles do
			t.r1 += .2
			t.length += 1
			t.max_length += 1
		end
	end
	--lvl up current active entities
	for i, e in inext, entities do
		e:level_up()
	end
	--create list of random lvl up uptions
	lvlup_options = {}
	while #lvlup_options < 3 do
		local r = rnd(all_heals)
		if (count(lvlup_options, r) == 0) add(lvlup_options, r)
	end
	--change states
	_update = update_upgrade
	_draw = draw_upgrade
end

function game_over()
	_update = update_gameover
	_draw = draw_gameover
end

function update_gameover_screen()
	if btnp(5) then
		reset_game()
		_update = update_game
		_draw = draw_game
	end
end

function draw_gameover_screen()
	print("you died...", uix + 4, uiy + 46, 8)
	print("press ctrl/cmd + r to restart", uix + 4, uiy + 54, 7)
	line(uix + 4, uiy + 63, uix + 120, uiy + 63, 1)
	print("level:" .. tostr(plvl), uix + 4, uiy + 70, 13)
	print("time:" .. tostr(round(playtime / 60)) .. "s")
	print("healed:" .. tostr(healed_es_c))
	-- print("units perished: " .. tostr(dead_es_c))
end