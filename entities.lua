-- entities
function setup_entities()
	spw_tmr = 0
	decay_rate = 120
	entities = {}
	spawning = {}
	spawn_entities(1)
end

function spawn_entities(i)
	for i = 1, i do
		e = {
			hp = 1 + flr(rnd(3)),
			maxhp = 4,
			x = flr(rnd(120)),
			y = flr(rnd(120)) + hud.h,
			w = 7,
			h = 7,
			ss = { 32, 33, 34, 35, 36, 37, 38, 39 },
			spr = 33,
			dist = 0,
			decay = 0,
			frame = 0,
			flip = rnd() < .5,
			tgl = true,
			dead = false
		}
		e.dist = approx_dist(p.x, p.y, e.x, e.y)
		add(spawning, e)
	end
end

function update_entities()
	spw_tmr += 1
	if (spw_tmr % 60 == 0) then
		spw_tmr = 0
		spawn_entities(1 + rnd(2))
	end
	for e in all(spawning) do
		e.frame += 1
		anim_spawn(e)
	end
	for e in all(entities) do
		e.frame += 1
		if not e.dead then
			if e.hp < e.maxhp then
				decay_entity(e)
				anim_entity(e)
			else
				anim_healed(e)
			end
		else
			anim_dead(e)
		end
	end
end

function decay_entity(e)
	e.decay += 1
	if (e.hp > 0) and (e.decay >= decay_rate) then
		e.hp -= 1
		e.decay = 0
	end
	if (e.hp <= 0) kill_entity(e)
end

function kill_entity(e)
	e.frame = 0
	e.dead = true
	hud.dead += 1
	sfx(sfxt.thud)
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
		healed += 1
		addxp(1)
		sfx(sfxt.healed)
	end
	if e.frame <= 45 then
		if (e.frame % 5 == 0) then
			e.tgl = not e.tgl
		end
		if e.tgl then
			e.spr = 36
		else
			e.spr = 37
		end
	elseif e.frame > 45 then
		e.spr = 38
		e.y -= 7
	elseif e.frame > 60 then
		del(entities, e)
	end
end

function anim_dead(e)
	if e.frame < 600 then
		e.spr = e.ss[1]
		-- elseif e.frame >= 150 and e.frame < 600 then
		-- 	e.spr = e.ss[8]
	elseif e.frame >= 600 then
		del(entities, e)
	end
end

function draw_entities()
	for e in all(spawning) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
	for e in all(entities) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end