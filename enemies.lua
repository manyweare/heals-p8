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
--enemy search range
en_s_range = 86

--enemy class
enemy = object:new({
	col = {},
	tgt = {},
	state = "alive",
	alive_table = enemies,
	dead_table = dead_enemies,
	alive_counter = game.live_ens,
	dead_counter = game.dead_ens
})
quickset(
	enemy,
	"name,x,y,w,h,midx,midy,dx,dy,frame,attframe,hit,flip",
	"enemy,0,0,8,8,0,0,0,0,1,1,false,false"
)

--enemy types
en_small = enemy:new({ ss = split("64, 65, 66, 67, 68") })
quickset(
	en_small,
	"hp,dmg,spd,xp,spr,attspd,animspd",
	"5,.5,.25,3,64,15,30"
)

en_medium = enemy:new({ ss = split("80, 81, 82, 83, 68") })
quickset(
	en_medium,
	"hp,dmg,spd,xp,spr,attspd,animspd",
	"10,1,.25,5,80,20,30"
)

-- TODO: subclasses
-- en_type_1 = enemy:new()
-- en_type_2 = enemy:new()
-- en_type_n = enemy:new()

function enemy:update()
	self:update_col()
	self:update_mid()
	sync_pos(self)
end

function enemy:draw()
	spr(self.spr, self.x, self.y, 1, 1, self.flip)
end

function init_enemies()
	-- spawn_enemies(1)
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
		add(e.alive_table, e)
		game.live_ens += 1
	end
end

function update_enemies()
	en_spw_tmr += 1
	if (en_spw_tmr % 120 == 0) then
		en_spw_tmr = 0
		--TODO: better spawn curve
		spawn_enemies(2 + flr(rnd(p.lvl / 3)))
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
	if not is_empty(entities) then
		local c = find_closest(self, entities, en_s_range)
		if (not is_empty(c)) tgt = c
	end
	if rect_rect_collision(self.col, tgt.col) then
		self.frame = 0
		self:attack(tgt)
	else
		self.attframe = 0
		self:move_anim()
	end
	self:move_to(tgt)
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
	bloodfx(self.midx, self.midy)
	drop_xp(vector(self.midx, self.midy), self.xp)
	die(self)
end