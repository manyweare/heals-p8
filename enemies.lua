--enemies

--TODO:
--OOP system -INPROGRESS
--use quickset to save tokens
--add different types -INPROGRESS
--anim taking damage
--spawn scheduler
--don't spawn on invalid tiles
--[[
enemy state machine: -DONE???
	enemies look for healthy entity in range -DONE
	enemies move to and attack it -DONE
	when entity dies, resume looking -DONE
	if none, attack player -DONE
	if dead, anim dead -DONE
]]

en_spw_tmr = 0
enemies = {}
dead_enemies = {}
--enemy search range
en_s_range = 86

--enemy class
enemy = object:new({
	name = "enemy",
	x = 0,
	y = 0,
	h = 8,
	w = 8,
	dx = 0,
	dy = 0,
	tgt = {},
	attframe = 1,
	hit = false,
	frame = 1, --current frame
	flip = false, --flip sprite
	col = {},
	state = "alive",
	alive_table = enemies,
	dead_table = dead_enemies,
	alive_counter = game.live_ens,
	dead_counter = game.dead_ens
})

--enemy types
en_small = enemy:new({
	hp = 5,
	dmg = .5,
	spd = .25,
	xp = 3,
	ss = split("64, 65, 66, 67, 68"),
	spr = 64,
	attspd = 15,
	animspd = 30
})
en_medium = enemy:new({
	hp = 10,
	dmg = 1,
	spd = .25,
	xp = 5,
	ss = split("80, 81, 82, 83, 68"),
	spr = 80,
	attspd = 20,
	animspd = 30
})

-- TODO: subclasses
-- en_type_1 = enemy:new()
-- en_type_2 = enemy:new()
-- en_type_n = enemy:new()

function enemy:update()
	self:update_col()
	self:update_mid()
	--default tgt is player
	local tgt = p
	if not is_empty(heroes) then
		local c = find_closest(self, heroes, en_s_range)
		if (not is_empty(c)) tgt = c
	end
	if rect_rect_collision(self.col, tgt.col) then
		self.frame = 0
		self:attack(tgt)
	else
		self.attframe = 0
		self:anim()
	end
	self:move_to(tgt)
end

function enemy:draw()
	spr(self.spr, self.x, self.y, 1, 1, self.flip)
end

function init_enemies()
	spawn_enemies(3)
end

function spawn_enemies(num)
	for i = 1, num do
		local e = {}
		local pos = rand_in_circle(p.midx, p.midy, 64)
		--for every 3, spawn 1 medium
		if i % 3 < 1 then
			e = en_medium:new(vector(pos.x, pos.y))
		else
			e = en_small:new(vector(pos.x, pos.y))
		end
		e:setup_col(split("0, 0, 0, 0"))
		add(enemies, e)
		game.live_ens += 1
	end
end

function update_enemies()
	en_spw_tmr += 1
	if (en_spw_tmr % 90 == 0) then
		en_spw_tmr = 0
		spawn_enemies(2 + flr(rnd(p.lvl / 3)))
	end
	for e in all(enemies) do
		e:update()
	end
	for e in all(dead_enemies) do
		e:anim_dead()
	end
	if not is_empty(enemies) then
		move_apart(enemies, 8)
	end
end

function draw_enemies()
	for e in all(enemies) do
		sync_pos(e)
		e:draw()
	end
end

function draw_dead_ens()
	for e in all(dead_enemies) do
		sync_pos(e)
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end

function enemy:anim()
	if self.frame < self.animspd / 2 then
		self.spr = self.ss[2]
	elseif self.frame == self.animspd then
		self.frame = 0
	else
		self.spr = self.ss[1]
	end
	self.frame += 1
	--TODO: only anim if moving
end

function enemy:anim_dead()
	self.frame += 1
	-- sprite for dead unit is the last in sprite sheet
	self.spr = self.ss[count(self.ss)]
	if (self.frame > 600) del(dead_enemies, self)
end

function enemy:attack(tgt)
	if self.attframe < self.attspd / 2 then
		if (self.attframe == 1) then
			sfx(sfxt.en_atk)
			if tgt == p then
				p:take_dmg(self.dmg, true)
			else
				tgt:take_dmg(self.dmg)
			end
		end
		self.spr = self.ss[3]
	elseif self.attframe == self.attspd then
		self.attframe = 0
	else
		self.spr = self.ss[4]
	end
	self.attframe += 1
end

function enemy:die()
	sfx(sfxt.en_die)
	local mid = vector(self.midx, self.midy)
	sync_pos(mid)
	bloodfx(mid.x, mid.y)
	drop_xp(mid, self.xp)
	die(self)
end