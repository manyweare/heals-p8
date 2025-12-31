--entities

--TODO:
--OOP system -INPROGRESS
--use quickset to save tokens
--entity types -INPROGRESS
--fix being hit anim: use a color change instead of spr change
--create more complex movement
--return to player side if no enemies
--don't overlap player
--don't spawn on invalid tiles
--spawn scheduler

spw_tmr = 0
entities = {}
spawning = {}
dead_entities = {}
decay_rate = 120
e_s_range = 128

-- entity class
entity = object:new({
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
	tgl = true, --for toggle-based animations
	hit = false, --for being hit animation
	dist = 0,
	state = "",
	tentacles = {},
	alive_table = entities,
	dead_table = dead_entities,
	alive_counter = live_es,
	dead_counter = dead_es
})

--entity types
h_melee = entity:new({
	type = "melee",
	hpmax = 4,
	dmg = 1.5,
	spd = .5,
	attspd = 15,
	ss = split("54, 55, 56, 57, 58")
})
h_tank = entity:new({
	type = "tank",
	hpmax = 250,
	dmg = .5,
	spd = .25,
	attspd = 10,
	ss = split("38, 39, 40, 41, 42")
})
h_ranged = entity:new({
	type = "ranged",
	hpmax = 50,
	dmg = .25,
	spd = .75,
	attspd = 15,
	ss = split("22, 23, 24, 25, 26")
})

function init_entities()
	spw_tmr = 0
	entities = {}
	spawning = {}
	dead_entities = {}
	-- spawn_entities(3)
end

function spawn_entities(num)
	for i = 1, num do
		local h = h_melee:new({
			hp = 1 + flr(rnd(3)),
			attframe = 1,
			x = max(33, rnd(93)) + psx,
			y = max(33, rnd(93)) + psy,
			ss = split("32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42"),
			spr = 33,
			flip = rnd() < .5,
			state = "spawning"
		})
		-- sync_pos(h)
		h.midx = h.x + h.w / 2
		h.midy = h.y + h.h / 2
		h.dx, h.dy = h.midx, h.midy
		h.dist = approx_dist(p.x, p.y, h.midx, h.midy)
		h.tentacles = create_tentacles(8, h.midx, h.midy, 2, 1, 6, split("7, 7, 7, 9"))
		h:setup_col(split("-2, -2, 2, 2"))
		-- entities begin in spawning state
		add(spawning, h)
		live_es += 1
	end
end

function entity:update()
	self.frame += 1
	sync_pos(self)
	self:update_mid()
	self:update_col()
end

function entity:draw()
	if self.state == "ready" then
		draw_tentacles(self.tentacles)
	end
	spr(self.spr, self.x, self.y, 1, 1, self.flip)
end

function entity:decay()
	self.decay_state += 1
	if (self.hp > 0) and (self.decay_state >= decay_rate) then
		self.hp -= 1
		self.decay_state = 0
	elseif self.hp <= 0 then
		self:die()
	end
end

function entity:attack(tgt)
	if self.attframe < self.attspd / 2 then
		if (self.attframe == 1) then
			sfx(sfxt.entity_atk, 2)
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

function entity:heal(hpwr)
	self.hp = min(self.hpmax, self.hp + hpwr)
	self.decay_state = 0
	self.frame = 0
end

function entity:die()
	sfx(sfxt.entity_die)
	die(self)
end

function entity:anim()
	self.spr = self.ss[flr(self.hp + 1)]
end

function entity:anim_spawn()
	--if animated for 30 frames
	--set it to the right spr and move to entities
	--otherwise blink
	if self.frame == 30 then
		self.frame = 0
		-- self.tgl = true
		self.state = "hurt"
		self:anim()
		add(self.alive_table, self)
		del(spawning, self)
		return
	end
	if (self.frame % 5 < 2.5) then
		self:anim()
	else
		self:toggle()
	end
end

function entity:anim_healed()
	sfx(sfxt.healed)
	healed_es += 1
	self.state = "ready"
end

function entity:anim_ready()
	if (self.frame % 5 < 2.5) then
		self.spr = 38
	else
		self.spr = 39
	end
end

function entity:anim_dead()
	self.spr = self.ss[1]
	if (self.frame > 600) del(self.dead_table, self)
end

function update_entities()
	spw_tmr += 1
	if (spw_tmr % 300 == 0) then
		spw_tmr = 0
		if (live_es == 0) spawn_entities(round(rnd(p.lvl / 3)))
	end
	for e in all(spawning) do
		e:update()
		e:anim_spawn()
	end
	for e in all(dead_entities) do
		e:update()
		e:anim_dead()
	end
	for e in all(entities) do
		e:update()
		if e.state == "hurt" then
			if e.hp < e.hpmax then
				e:decay()
				e:anim()
			else
				e:anim_healed()
			end
		elseif e.state == "ready" then
			local tgt = p
			if not is_empty(enemies) then
				tgt = find_closest(e, enemies, e_s_range)
			end
			if rect_rect_collision(e.col, tgt.col) then
				e.frame = 0
				if (tgt != p) e:attack(tgt)
			else
				e.attframe = 0
				e:move_to(tgt.midx, tgt.midy)
				e:anim_ready()
			end
			e:move_apart(e.alive_table, max(e.h, e.w) + 2)
			e:flip_spr(tgt.x)
		end
		update_tentacles(e)
	end
end

function draw_entities()
	for e in all(spawning) do
		e:draw()
	end
	for e in all(entities) do
		e:draw()
	end
end

function draw_dead_es()
	for e in all(dead_entities) do
		e:draw()
	end
end