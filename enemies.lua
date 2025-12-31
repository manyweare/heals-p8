--enemies

--TODO:
--OOP system -INPROGRESS
--use quickset to save tokens -DONE
--add different types -INPROGRESS
--anim taking damage
--spawn scheduler
--don't spawn on invalid tiles
--[[
enemy state machine: -INPROGRESS
	enemies look for healthy entity in range -DONE
	enemies move to and attack it -DONE
	when entity dies, resume looking -DONE
	if none, attack player -DONE
	if dead, anim dead -DONE
	if nothing in range, wander
]]

en_spw_tmr = 0
enemies = {}
dead_enemies = {}
en_wave_count = 0
--enemy search range
en_s_range = 86 --2/3 of screen

--enemy class
enemy = object:new({
	col = {},
	tgt = {},
	state = "alive",
	alive_table = enemies,
	dead_table = dead_enemies,
	alive_counter = live_ens,
	dead_counter = dead_ens
})
quickset(
	enemy,
	"name,x,y,w,h,midx,midy,dx,dy,frame,attframe,hit,flip",
	"enemy,0,0,8,8,0,0,0,0,1,1,false,false"
)

--enemy types
en_small = enemy:new({
	class = "small",
	ss = split("64, 65, 66, 67, 68")
})
quickset(
	en_small,
	"hp,dmg,spd,xp,spr,attspd,animspd",
	"5,.5,.25,3,64,15,30"
)

en_medium = enemy:new({
	class = "medium",
	ss = split("80, 81, 82, 83, 68")
})
quickset(
	en_medium,
	"hp,dmg,spd,xp,spr,attspd,animspd",
	"10,1,.25,5,80,20,30"
)

en_turret = enemy:new({
	class = "turret",
	ss = split("80, 81, 82, 83, 68"),
	bullets = {}
})
quickset(
	en_turret,
	"hp,dmg,spd,xp,spr,attspd,animspd",
	"5,.5,0,5,80,30,30"
)

function enemy:update()
	self:update_col()
	self:update_mid()
	sync_pos(self)
	self:reset_pos()
end

function enemy:draw()
	spr(self.spr, self.x, self.y, 1, 1, self.flip)
end

function init_enemies()
	-- enemies = {}
	-- dead_enemies = {}
	-- en_wave_count = 0
	-- spawn_enemies()
end

function update_enemies()
	-- en_spw_tmr += 1
	if playtime % 3 == 0 then
		-- en_spw_tmr = 0
		en_wave_count += 1
		if en_wave_count % 5 == 0 then
			spawn_enemies("m")
		elseif en_wave_count % 3 == 0 then
			spawn_enemies("t")
		else
			spawn_enemies("s")
		end
	end
	for e in all(enemies) do
		e:update()
		e:anim_alive()
	end
	for e in all(dead_enemies) do
		e:update()
		e:anim_dead()
	end
end

function draw_enemies()
	for e in all(enemies) do
		e:draw()
	end
end

function draw_dead_ens()
	for e in all(dead_enemies) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end

function spawn_enemies(type)
	-- 	value = steepness * log_b(level + 1) + offset
	local num = 10 * round(log10(p.lvl + 1)) + 1
	for i = 1, num do
		local e = {}
		local pos = rand_in_circle(p.midx, p.midy, 64)
		if type == "s" then
			e = en_small:new(vector(pos.x, pos.y))
		elseif type == "m" then
			e = en_medium:new(vector(pos.x, pos.y))
		elseif type == "t" then
			e = en_turret:new(vector(pos.x, pos.y))
		end
		e:setup_col(split("0, 0, 0, 0"))
		add(e.alive_table, e)
		live_ens += 1
	end
end

function enemy:move_anim()
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

function enemy:anim_alive()
	--default tgt is player
	local tgt = p
	if self.class == "turret" then
		if col(self, tgt, 64) then
			self.frame = 0
			self:attack(tgt)
		else
			self.attframe = 0
			self:move_anim()
		end
		self:flip_spr(tgt.x)
		return
	end
	if not is_empty(entities) then
		local c = find_closest(self, entities, en_s_range)
		if (not is_empty(c)) tgt = c
	end
	if rect_rect_collision(self.col, tgt.col) then
		self.frame = 0
		self:attack(tgt)
	else
		self.attframe = 0
		self:move_to(tgt.midx, tgt.midy)
		self:move_anim()
	end
	self:move_apart(self.alive_table, max(self.h, self.w) + 2)
	self:flip_spr(tgt.x)
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
			if self.class == "turret" then
				local b = bullet:new({
					x = self.midx,
					y = self.midy,
					dmg = self.dmg,
					tgt = tgt
				})
				b.ix, b.iy = b.x, b.y
				b:setup_col(split("0, 0, 0, 0"))
				add(bullets, b)
				-- printh("shot", log, true)
			else
				if tgt == p then
					p:take_dmg(self.dmg, true)
				else
					tgt:take_dmg(self.dmg)
				end
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
	bloodfx(self.midx, self.midy)
	drop_xp(vector(self.midx, self.midy), self.xp)
	die(self)
end