--enemies

--TODO:
--OOP system
--use quickset to save tokens
--add different types
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

-- enemy class
enemy = object:new()

en_spw_tmr = 0
enemies = {}
dead_enemies = {}
--enemy search range
en_s_range = 128

-- TODO: subclasses
-- en_type_1 = enemy:new()
-- en_type_2 = enemy:new()
-- en_type_n = enemy:new()

function enemy:update()
	--update colision position
	self:update_col()
	--default tgt is player
	local tgt = p
	--if there are entities ready
	--find closest, make it the target
	if not is_empty(heroes) then
		local c = find_closest(self, heroes, en_s_range)
		if (not is_empty(c)) tgt = c
	end
	--check for collision and attack or just anim
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
		local e = enemy:new({
			x = flr(rnd(120)),
			y = flr(rnd(120)),
			h = 8,
			w = 8,
			dx = 0,
			dy = 0,
			ss = { 64, 65, 66, 67, 68 }, --spritesheet
			spr = 64, --current sprite
			hp = 5,
			dmg = .5,
			spd = .25,
			tgt = {},
			attspd = 15,
			attframe = 1,
			animspd = 30,
			hit = false,
			frame = 1, --current frame
			flip = false, --flip sprite
			col = {},
			att_sfx = 5,
			state = "alive",
			alive_table = enemies,
			dead_table = dead_enemies,
			alive_counter = game.live_ens,
			dead_counter = game.dead_ens
		})
		--collision rect offsets relative to e
		-- e.col_offset = { 1, 1, -2, -3 }
		-- --collision rect
		-- e.col = {
		-- 	x = e.x + e.col_offset[1],
		-- 	y = e.y + e.col_offset[2],
		-- 	w = e.w + e.col_offset[3],
		-- 	h = e.h + e.col_offset[4]
		-- }
		e:setup_col({ 1, 1, -2, -3 })
		add(enemies, e)
		game.live_ens += 1
	end
end

function update_enemies()
	en_spw_tmr += 1
	if (en_spw_tmr % 90 == 0) then
		en_spw_tmr = 0
		spawn_enemies(1 + flr(rnd(p.lvl / 3)))
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
	-- if is_moving(e) then
	-- 	if e.frame > e.animspd then
	-- 		e.spr = e.ss[2]
	-- 		if (e.frame == e.animspd) e.frame = 0
	-- 	else
	-- 		e.spr = e.ss[1]
	-- 	end
	-- end
end

function enemy:anim_dead()
	self.frame += 1
	-- sprite for dead unit is the last in sprite sheet
	self.spr = self.ss[count(self.ss)]
	if (self.frame > 600) del(dead_enemies, self)
end

-- function enemy:take_dmg(dmg)
-- 	self.hit = true
-- 	self.hp -= dmg
-- 	if (self.hp <= 0) self:kill()
-- end

function enemy:attack(tgt)
	if self.attframe < self.attspd / 2 then
		if (self.attframe == 1) then
			sfx(self.att_sfx, 2)
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

-- function enemy:die()
-- 	-- self.frame = 0
-- 	-- self.state = "dead"
-- 	-- add(dead_enemies, self)
-- 	-- del(enemies, self)
-- 	-- sfx(sfxt.thud, 2)
-- 	game.dead_ens += 1
-- 	game.live_ens -= 1
-- 	self:die(enemies, dead_enemies)
-- end