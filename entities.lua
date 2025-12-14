--entities

--TODO:
--OOP system
--use quickset to save tokens
--hero types
--fix being hit anim: use a color change instead of spr change
--fix attack anim not running -DONE
--create more complex movement
--return to player side if no enemies
--don't overlap player
--don't spawn on invalid tiles
--spawn scheduler

-- hero class
-- hero = object:new()

spw_tmr = 0
decay_rate = 120
e_s_range = 128
heroes = {}
spawning = {}
dead_heroes = {}

-- class definition
hero = object:new({
	hp = 0,
	decay_state = 0,
	x = 0,
	y = 0,
	w = 8,
	h = 8,
	spr = 0,
	att_frame = 1,
	frame = 0,
	col = {},
	flip = false, --sprite flip x
	tgl = true, --controls toggle-based animations
	hit = false, --controls being hit animation
	dist = 0,
	state = "",
	tentacles = {},
	alive_table = heroes,
	dead_table = dead_heroes,
	alive_counter = game.live_es,
	dead_counter = game.dead_es
})

--hero types
h_melee = hero:new({
	type = "melee",
	hpmax = 4,
	dmg = 1.5,
	spd = .5,
	attspd = 15,
	ss = split("54, 55, 56, 57, 58")
})
h_tank = hero:new({
	type = "tank",
	hpmax = 250,
	dmg = .5,
	spd = .25,
	attspd = 10,
	ss = split("38, 39, 40, 41, 42")
})
h_ranged = hero:new({
	type = "ranged",
	hpmax = 50,
	dmg = .25,
	spd = .75,
	attspd = 15,
	ss = split("22, 23, 24, 25, 26")
})

function init_entities()
	spawn_entities(3)
end

function spawn_entities(num)
	for i = 1, num do
		local h = h_melee:new({
			hp = 1 + flr(rnd(3)),
			-- hpmax = 4,
			-- dmg = 1,
			-- spd = .5,
			-- attspd = 15,
			attframe = 1,
			x = max(33, rnd(93)),
			y = max(33, rnd(93)),
			-- w = 8,
			-- h = 8,
			ss = split("32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42"),
			spr = 33,
			-- dist = 0,
			-- decay_state = 0,
			-- frame = 0,
			flip = rnd() < .5,
			-- tgl = true, --controls toggle-based animations
			-- hit = false, --controls being hit animation
			state = "spawning"
		})
		h.midx = h.x + h.w / 2
		h.midy = h.y + h.h / 2
		h.dist = approx_dist(p.x, p.y, h.x, h.y)
		-- function create_tentacles(n, start, r1, r2, l, s, c)
		h.tentacles = create_tentacles(
			8,
			vector(h.x, h.y),
			2, 1, 6, 8,
			{ 7, 7, 7, 9 }
		)
		h:setup_col({ -2, -2, 2, 2 })
		-- heroes begin in spawning state
		add(spawning, h)
		game.live_es += 1
	end
end

function hero:decay()
	self.decay_state += 1
	if (self.hp > 0) and (self.decay_state >= decay_rate) then
		self.hp -= 1
		self.decay_state = 0
	elseif self.hp <= 0 then
		self:die()
	end
end

function hero:attack(tgt)
	if self.attframe < self.attspd / 2 then
		if (self.attframe == 1) then
			sfx(sfxt.hero_atk, 2)
			tgt:take_dmg(self.dmg)
		end
		self.spr = 41 --hardcoded attack sprite
	elseif self.attframe == self.attspd then
		self.attframe = 0
	else
		self.spr = 42 --hardcoded idle frame
	end
	self.attframe += 1
end

-- function hero:take_dmg(dmg)
-- 	self.hit = true
-- 	self.hp -= dmg
-- 	if (self.hp <= 0) self:die()
-- end

function hero:heal(hpwr)
	self.hp = min(self.hpmax, self.hp + hpwr)
	self.decay_state = 0
	self.frame = 0
end

function hero:die()
	sfx(sfxt.hero_die)
	die(self)
end

function hero:anim()
	self.spr = self.ss[flr(self.hp + 1)]
end

function hero:anim_spawn()
	--if animated for 30 frames
	--set it to the right spr and move e to heroes
	--otherwise blink
	if self.frame == 30 then
		self.frame = 0
		self.tgl = true
		self.state = "hurt"
		self:anim()
		add(heroes, self)
		del(spawning, self)
		return
	end
	if (self.frame % 3 == 0) self.tgl = not self.tgl
	if self.tgl then
		self:anim()
	else
		self:toggle()
	end
end

function hero:anim_healed()
	sfx(sfxt.healed)
	game.healed_es += 1
	self.state = "ready"
end

function hero:anim_ready()
	if (self.frame % 5 == 0) self.tgl = not self.tgl
	if self.tgl then
		self.spr = 38
	else
		self.spr = 39
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

function hero:anim_tentacles()
	for t in all(self.tentacles) do
		local cx, cy = self.x + self.w / 2, self.y + self.h / 2
		t.spos = vector(cx, cy)
		sync_pos(t.epos)
		if (t.epos.x < cx - t.length) or (t.epos.x > cx + t.length)
				or (t.epos.y < cy - t.length) or (t.epos.y > cy + t.length) then
			t.epos = rand_in_circle(cx, cy, t.length)
		end
	end
end

function hero:anim_dead()
	self.spr = self.ss[1]
	if (self.frame > 600) del(dead_heroes, self)
end

function update_entities()
	spw_tmr += 1
	if (spw_tmr % 150 == 0) then
		spw_tmr = 0
		spawn_entities(flr(rnd(p.lvl / 3)))
	end
	for e in all(spawning) do
		e.frame += 1
		e:anim_spawn()
	end
	for e in all(dead_heroes) do
		e.frame += 1
		e:anim_dead()
	end
	for e in all(heroes) do
		e.frame += 1
		if e.state == "hurt" then
			if e.hp < e.hpmax then
				e:decay()
				e:anim()
			else
				e:anim_healed()
			end
		elseif e.state == "ready" then
			e:update_col()
			e:anim_tentacles()
			local tgt = p
			if not is_empty(enemies) then
				tgt = find_closest(e, enemies, e_s_range)
				e.flip = e:flip_spr(tgt)
				if rect_rect_collision(e.col, tgt.col) then
					e.frame = 0
					e:attack(tgt)
				else
					e.attframe = 0
					e:move_to(tgt)
					e:anim_ready()
				end
			end
		end
	end
	move_apart(heroes, 8)
end

function draw_entities()
	for e in all(spawning) do
		sync_pos(e)
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
	for e in all(heroes) do
		sync_pos(e)
		if e.state == "ready" then
			draw_tentacles(e.tentacles)
		end
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end

function draw_dead_es()
	for e in all(dead_heroes) do
		sync_pos(e)
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end