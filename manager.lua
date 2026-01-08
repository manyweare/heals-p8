--manager

--entity counters
live_es_c, dead_es_c, healed_es_c = 0, 0, 0
--enemy counters
live_ens_c, dead_ens_c, en_wave_c = 0, 0, 1

xpmax, xpmod = 5, 1
boss_is_active = false

function init_manager()
	lvlup_options = {}
	boss_is_active = false
end

function resume_game()
	--change states
	_update = update_game
	_draw = draw_game
end

function update_spawner()
	--entity spawning DEBUG--
	if #entities < 1 and #spawning_es < 1 then
		local r = rnd() < .5 and spawn_es("melee") or spawn_es("turret")
	end
	if playtime % 150 == 0 then
		if #entities < 3 and #spawning_es < 1 then
			local r = rnd() < .5 and spawn_es("melee") or spawn_es("turret")
		end
	end
	--enemy spawning DEBUG--
	if #enemies < 1 and #spawning_ens < 1 then
		local r = rnd() < .5 and spawn_ens("t") or spawn_ens("m")
	end
	if playtime % 300 == 0 then
		local num = round(en_wave_c / 3)
		spawn_ens("m", round(num / 5))
		spawn_ens("t", round(num / 3))
		spawn_ens("s", num)
		en_wave_c += 1
	end
	--start spawning bosses and entities after 2m
	-- if playtime > 120 then
	--     --miniboss every 3m
	--     if playtime % 180 == 0 and not boss_is_active then
	--         --spawn miniboss
	--         --spawn adds
	--         spawn_ens("s", 6)
	--         spawn_ens("m", 2)
	--         spawn_ens("t", 3)
	--     end
	--     --final boss at 10m
	--     if playtime == 600 then
	--         boss_is_active = true
	--         --spawn boss
	--         --spawn adds
	--         spawn_ens("s", 12)
	--         spawn_ens("m", 4)
	--         spawn_ens("t", 6)
	--     end
	--     --entity spawning--
	--     if playtime % 5 == 0 then
	--         if (live_es == 0) spawn_es()
	--     end
	-- end
end

function spawn_ens(class, num)
	num = num or 1
	for i = 1, num do
		if #enemies < 32 then
			local e = {}
			local pos = rand_in_circle(p.x, p.y, 64)
			if class == "s" then
				e = en_small:new(pos)
			elseif class == "m" then
				e = en_medium:new(pos)
			elseif class == "t" then
				e = en_turret:new(pos)
			end
			e:level_up()
			add(spawning_ens, e)
			add(all_enemies, e)
			printh("----- enemy SPAWNED -----", "log.p8l", true)
			printh("ens:" .. tostr(#enemies) .. " | dead_ens:" .. tostr(#dead_ens), "log.p8l", true)
		end
	end
end

function spawn_es(class, num)
	num = num or 1
	for i = 1, num do
		if #entities < 8 then
			local pos = rand_in_circle(59, 59, 64)
			local e, _e = {}, {}
			_e = {
				hp = 1 + flr(rnd(3)),
				x = pos.x,
				y = pos.y,
				flip = rnd() < .5
			}
			if class == "melee" then
				e = e_melee:new(_e)
				e.main_clrs = split("7, 7, 7, 10")
				e.tentacles = create_tentacles(6, e.x, e.y, 1.75, 1, 5, e.main_clrs)
			elseif class == "turret" then
				e = e_turret:new(_e)
				e.main_clrs = split("7, 7, 7, 3")
				e.tentacles = create_tentacles(4, e.x, e.y, 1.75, 1, 4, e.main_clrs)
			end
			e:level_up()
			add(spawning_es, e)
			add(all_entities, e)
			printh("----- entity SPAWNED -----", "log.p8l", true)
			printh("es:" .. tostr(#entities) .. " | dead_es:" .. tostr(#dead_es), "log.p8l", true)
		end
	end
end

-- leveling functions ---------

function addxp(n)
	n = n or 1
	local ovrxp = 0
	n *= xpmod
	--check for lvl up and overflow
	if p.curxp + n >= xpmax then
		ovrxp = (p.curxp + n) - xpmax
		p.curxp = ovrxp
		lvlup()
	else
		p.curxp += n * xpmod
	end
	p.totalxp += n * xpmod
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
	-- if (h == aoe) h.range = min(h.range + 2, 48)
end

function object:level_up()
	self.hpmax = round(level_up_stat(10, p.lvl, self.hpmax))
	self.dmg = max(self.base_dmg, level_up_stat(5, p.lvl, self.base_dmg) / 3)
end

function lvlup()
	sfx(-1)
	sfx(sfxt.lvlup)
	lvlanim = 1
	p.lvl += 1
	xpmax = round(level_up_stat(10, p.lvl, xpmax))
	hrange = level_up_stat(5, p.lvl, hrange)
	p.hpmax = round(level_up_stat(10, p.lvl, p.hpmax))
	--lengthen tentacles
	for t in all(p.tentacles) do
		t.length += .1
		t.max_length += .1
	end
	if (p.lvl % 5 == 0) add(p.tentacles, create_tentacle(59, 59, 2.2, 1, 7, split("7, 7, 7, 9")))
	--lvl up entities
	for e in all(entities) do
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

function cheat()
	if btn(4) then
		lvlup()
		_update = update_upgrade
		_draw = draw_upgrade
	end
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
	print("you died!", uix + 4, uiy + 46, 8)
	print("press ❎ to restart", uix + 4, uiy + 54, 7)
end