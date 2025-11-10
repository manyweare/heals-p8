--entities

--TODO:
--use quickset to save tokens
--add different types
--fix being hit anim: use a color change instead of spr change
--fix attack anim not running -DONE
--create more complex movement
--don't overlap player
--don't spawn on invalid tiles
--spawn scheduler

function init_entities()
	spw_tmr = 0
	decay_rate = 120
	e_s_range = 128
	entities = {}
	spawning = {}
	dead = {}
	spawn_entities(1)
end

function spawn_entities(i)
	for i = 1, i do
		e = {
			hp = 1 + flr(rnd(3)),
			maxhp = 4,
			dmg = .5,
			spd = .25,
			attspd = 15,
			attframe = 1,
			att_sfx = 5,
			x = flr(rnd(120)),
			y = flr(rnd(120)) + ui.h,
			w = 8,
			h = 8,
			ss = { 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42 },
			spr = 33,
			dist = 0,
			decay = 0,
			frame = 0,
			flip = rnd() < .5,
			tgl = true, --controls toggle-based animations
			hit = false, --controls being hit animation
			state = "spawning"
		}
		e.dist = approx_dist(p.x, p.y, e.x, e.y)
		--collision rect offsets relative to e
		-- x,y,w,h
		e.col_offset = { 0, 0, -1, -2 }
		--collision rect
		e.col = {
			x = e.x + e.col_offset[1],
			y = e.y + e.col_offset[2],
			w = e.w + e.col_offset[3],
			h = e.h + e.col_offset[4]
		}
		add(spawning, e)
		game.live_es += 1
	end
end

function update_entities()
	spw_tmr += 1
	if (spw_tmr % 120 == 0) then
		spw_tmr = 0
		spawn_entities(1 + flr(rnd(p.lvl / 3)))
	end
	for e in all(spawning) do
		e.frame += 1
		anim_spawn(e)
	end
	for e in all(dead) do
		e.frame += 1
		anim_dead(e)
	end
	for e in all(entities) do
		e.frame += 1
		if e.state == "hurt" then
			if e.hp < e.maxhp then
				decay_entity(e)
				anim_entity(e)
			else
				anim_healed(e)
			end
		elseif e.state == "ready" then
			u_col(e)
			local tgt = p
			if not is_empty(enemies) then
				tgt = find_closest(e, enemies, e_s_range)
				e.flip = flip_spr(e, tgt)
				if rect_rect_collision(e.col, tgt.col) then
					e.frame = 0
					attack(e, tgt)
				else
					e.attframe = 0
					move_to(e, tgt)
					anim_ready(e)
				end
			end
		end
	end
	move_apart(entities, 8)
end

function decay_entity(e)
	e.decay += 1
	if (e.hp > 0) and (e.decay >= decay_rate) then
		e.hp -= 1
		e.decay = 0
	elseif e.hp <= 0 then
		e_kill(e)
	end
end

function attack(e, tgt)
	if e.attframe < e.attspd / 2 then
		if (e.attframe == 1) then
			-- sfx(e.att_sfx, 2)
			take_dmg(tgt, e.dmg)
		end
		e.spr = 41 --hardcoded attack sprite
	elseif e.attframe == e.attspd then
		e.attframe = 0
	else
		e.spr = 42 --hardcoded idle frame
	end
	e.attframe += 1
end

function e_take_dmg(e, dmg)
	e.hit = true
	e.hp -= dmg
	if (e.hp <= 0) e_kill(e)
end

function e_heal(e, hpwr)
	e.hp = max(e.maxhp, e.hp + hpwr)
	e.decay = 0
	e.frame = 0
end

function e_kill(e)
	e.frame = 0
	e.state = "dead"
	add(dead, e)
	del(entities, e)
	sfx(sfxt.thud)
	game.dead_es += 1
	game.live_es -= 1
end

function toggle_entity(e)
	e.spr = 1
end

function anim_entity(e)
	e.spr = e.ss[flr(e.hp + 1)]
end

function anim_spawn(e)
	--if animated for 30 frames
	--set it to the right spr and move e to entities
	--otherwise blink
	if e.frame == 30 then
		e.frame = 0
		e.tgl = true
		e.state = "hurt"
		anim_entity(e)
		add(entities, e)
		del(spawning, e)
		return
	end
	if (e.frame % 3 == 0) e.tgl = not e.tgl
	if e.tgl then
		anim_entity(e)
	else
		toggle_entity(e)
	end
end

function anim_healed(e)
	if e.frame == 1 then
		addxp(1)
		sfx(sfxt.healed)
		game.healed_es += 1
	end
	if e.frame <= 15 then
		if (e.frame % 5 == 0) then e.tgl = not e.tgl end
		if e.tgl then
			e.spr = 36
		else
			e.spr = 37
		end
	elseif e.frame > 15 then
		e.frame = 0
		e.state = "ready"
	end
end

function anim_ready(e)
	if (e.frame % 5 == 0) e.tgl = not e.tgl
	if e.tgl then
		e.spr = 38
	else
		e.spr = 39
	end
	--TODO: getting hit animation
	-- --flash to hit sprite instead of reg sprite if hit
	-- if e.hit then
	-- 	e.spr = 40
	-- else
	-- 	e.spr = 39
	-- end
	-- end
	--reset to avoid hit flash more than once
	-- if (e.frame > 10) then
	-- 	e.hit = false
	-- 	e.frame = 0
	-- end
end

function anim_dead(e)
	e.spr = e.ss[1]
	if (e.frame > 600) del(dead, e)
end

function draw_entities()
	for e in all(spawning) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
	for e in all(entities) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end

function draw_dead_es()
	for e in all(dead) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end