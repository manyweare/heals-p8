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

enemies, dead_enemies = {}, {}

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
	ss = split("64, 65, 66, 67, 68, 112")
})
quickset(
	en_small,
	"hp,hpmax,dmg,base_dmg,spd,xp,spr,attspd,animspd,search_range",
	"5,5,.5,.5,.25,1,64,15,30,86"
)

en_medium = enemy:new({
	class = "medium",
	ss = split("80, 81, 82, 83, 84, 112")
})
quickset(
	en_medium,
	"hp,hpmax,dmg,base_dmg,spd,xp,spr,attspd,animspd,search_range",
	"10,10,2,2,.25,3,80,20,30,64"
)

en_turret = enemy:new({
	class = "turret",
	ss = split("96, 97, 98, 99, 100, 112")
})
quickset(
	en_turret,
	"hp,hpmax,dmg,base_dmg,spd,xp,spr,attspd,animspd,search_range",
	"5,5,1,1,-0.15,3,96,30,30,86"
)

function enemy:draw()
	if self.hitframe > 0 then
		if self.hitframe <= 3 then
			self.hitframe += 1
			self.spr = self.ss[count(self.ss) - 1]
		elseif self.hitframe > 3 then
			self.hitframe = 0
		end
	end
	spr(self.spr, self.x - 4, self.y - 4, 1, 1, self.flip)
end

function init_enemies()
	-- enemies = {}
	-- dead_enemies = {}
	-- spawn_enemies()
end

function update_enemies()
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

--separate function to draw on different z-index
function draw_dead_ens()
	for e in all(dead_enemies) do
		spr(e.spr, e.x - 4, e.y - 4, 1, 1, e.flip)
	end
end

function enemy:update()
	self.frame += 1
	self:reset_pos()
	sync_pos(self)
end

function enemy:anim_alive()
	--blink when spawning
	if self.state == "spawning" and self.frame < 30 then
		if (self.frame % 5 < 2.5) then
			self.spr = self.ss[1]
		else
			self.spr = 1
		end
		return
	else
		self.state = "alive"
	end
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
	if (self.frame > 300) del(dead_enemies, self)
end

function enemy:move_anim()
	if self.frame < self.animspd / 2 then
		self.spr = self.ss[2]
	elseif self.frame == self.animspd then
		self.frame = 0
	else
		self.spr = self.ss[1]
	end
	-- self.frame += 1
end

function enemy:attack(tgt)
	if self.attframe < self.attspd / 2 then
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
		self.spr = self.ss[3]
	elseif self.attframe == self.attspd then
		self.attframe = 0
	else
		self.spr = self.ss[4]
	end
	self.attframe += 1
end

function enemy:die()
	-- sprite for dead unit is the last in sprite sheet
	self.spr = self.ss[count(self.ss)]
	sfx(sfxt.en_die)
	bloodfx(self.x, self.y)
	drop_xp(vector(self.x, self.y), self.xp)
	dead_ens_c += 1
	live_ens_c = max(0, live_ens_c - 1)
	add(dead_enemies, self)
	del(enemies, self)
end