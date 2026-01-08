--enemies

--TODO:
--OOP system -INPROGRESS
--use quickset to save tokens -DONE
--add different types -INPROGRESS
--anim taking damage
--[[
enemy state machine: -INPROGRESS
	enemies look for healthy entity in range -DONE
	enemies move to and attack it -DONE
	when entity dies, resume looking -DONE
	if none, attack player -DONE
	if dead, anim dead -DONE
	if nothing in range, wander
]]

all_enemies, enemies, spawning_ens, dead_ens = {}, {}, {}, {}

--enemy class
enemy = object:new({
	state = "spawning",
	tgt = {}
})
quickset(
	enemy,
	"name,x,y,w,h,dx,dy,frame,attframe,hitframe,flip",
	"enemy,0,0,8,8,0,0,1,1,0,false"
)

--enemy types
en_small = enemy:new({
	class = "small",
	ss = split("112,64,65,66,67,68")
})
quickset(
	en_small,
	"hp,hpmax,dmg,base_dmg,spd,xp,spr,attspd,animspd,search_range",
	"5,5,.5,.5,.25,1,64,15,30,86"
)

en_medium = enemy:new({
	class = "medium",
	ss = split("112,80,81,82,83,84")
})
quickset(
	en_medium,
	"hp,hpmax,dmg,base_dmg,spd,xp,spr,attspd,animspd,search_range",
	"10,10,2,2,.25,3,80,20,30,64"
)

en_turret = enemy:new({
	class = "turret",
	ss = split("112,96,97,98,99,100")
})
quickset(
	en_turret,
	"hp,hpmax,dmg,base_dmg,spd,xp,spr,attspd,animspd,search_range",
	"5,5,1,1,-0.15,3,96,30,30,86"
)

function enemy:update()
	self.frame += 1
	sync_pos(self)
	self:reset_pos()
end

function enemy:draw()
	if self.hitframe > 0 then
		if self.hitframe <= 3 then
			self.hitframe += 1
			self.spr = self.ss[count(self.ss)]
		elseif self.hitframe > 3 then
			self.hitframe = 0
		end
	end
	spr(self.spr, self.x - 4, self.y - 4, 1, 1, self.flip)
end

function init_enemies()
	all_enemies, enemies, spawning_ens, dead_ens = {}, {}, {}, {}
end

function update_enemies()
	for e in all(all_enemies) do
		e:update()
	end
	for e in all(spawning_ens) do
		e:anim_spawn()
	end
	for e in all(enemies) do
		e:anim_alive()
	end
	for e in all(dead_ens) do
		e:anim_dead()
	end
end

function draw_enemies()
	for e in all(spawning_ens) do
		e:draw()
	end
	for e in all(enemies) do
		e:draw()
	end
end

--separate function to draw on different z-index
function draw_dead_ens()
	for e in all(dead_ens) do
		e:draw()
	end
end

function enemy:anim_spawn()
	if self.frame == 30 then
		self.frame = 0
		self.state = "hurt"
		add(enemies, self)
		del(spawning_ens, self)
		return
	else
		self:tgl_anim(5, self.ss[2], 1)
	end
end

function enemy:anim_alive()
	--default tgt is player
	local tgt = p
	if not is_empty(entities) then
		local c = find_closest(self, entities, self.search_range)
		if (not is_empty(c)) tgt = c
	end
	if self.class == "turret" then
		--always moves away from tgt
		self:move_to(tgt.x, tgt.y)
		if col(self, tgt, self.search_range) then
			self.frame = 0
			self:attack(tgt)
		else
			self.attframe = 0
			self:move_anim()
		end
		self:flip_spr(tgt.x)
		return
	else
		if col(self, tgt, 8) then
			self.frame = 0
			self:attack(tgt)
		else
			self.attframe = 0
			self:move_to(tgt.x, tgt.y)
			self:move_anim()
		end
	end
	self:move_apart(enemies, 10)
	self:flip_spr(tgt.x)
end

function enemy:anim_dead()
	self.spr = self.ss[1]
	if (self.frame > 300) del(dead_ens, self)
end

function enemy:move_anim()
	self:tgl_anim(self.animspd, self.ss[2], self.ss[3])
	-- if self.frame < self.animspd / 2 then
	-- 	self.spr = self.ss[2]
	-- elseif self.frame == self.animspd then
	-- 	self.frame = 0
	-- else
	-- 	self.spr = self.ss[3]
	-- end
end

function enemy:attack(tgt)
	if self.attframe < self.attspd / 2 then
		self.spr = self.ss[4]
		if (self.attframe == 1) then
			sfx(sfxt.en_atk)
			if self.class == "turret" then
				self:shoot(tgt)
			else
				if tgt == p then
					p:take_dmg(self.dmg, true)
				else
					tgt:take_dmg(self.dmg)
				end
			end
		end
	elseif self.attframe == self.attspd then
		self.attframe = 0
	else
		self.spr = self.ss[3]
	end
	self.attframe += 1
end

function enemy:die()
	self.state = "dead"
	--visuals
	sfx(sfxt.en_die)
	bloodfx(self.x, self.y)
	drop_xp(vector(self.x, self.y), self.xp)
	--counters
	dead_ens_c += 1
	live_ens_c = max(0, live_ens_c - 1)
	--tables
	del(enemies, self)
	add(dead_ens, self)
	--
	printh("----- " .. self.name .. " DIED -----", "log.p8l", true)
	printh("ens:" .. tostr(#enemies) .. " | dead_ens:" .. tostr(#dead_ens), "log.p8l", true)
end