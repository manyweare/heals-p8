--entities

entities, turrets, spawning_es, dead_es = {}, {}, {}, {}
decay_rate = 150

--entity class--
entity = object:new({
	state = "spawning",
	tentacles = {}
})
quickset(
	entity,
	"hp,hpmax,decay_state,x,y,dx,dy,w,h,attframe,frame,dist,flip,tgl,hit",
	"0,4,0,0,0,0,0,8,8,1,0,0,false,true,false"
)

--entity types--
e_melee = entity:new({
	class = "melee",
	ss = split("32,33,34,35,36,37,38,39,40,41,42")
})
quickset(
	e_melee,
	"dmg,base_dmg,spd,attspd,search_range,spr",
	"1,1,.5,15,86,33"
)

e_turret = entity:new({
	class = "turret",
	ss = split("32,33,34,35,36,37,38,39,40,41,42"),
	orbit_pos = vector()
})
quickset(
	e_turret,
	"dmg,base_dmg,spd,attspd,search_range,spr",
	"1,1,.75,30,86,33"
)

function init_entities()
	-- spawn_entities(3)
end

function update_entities()
	for e in all(spawning_es) do
		e:update()
		e:anim_spawn()
	end
	for e in all(dead_es) do
		e:update()
		e:anim_dead()
	end
	for e in all(entities) do
		e:update()
		e:anim_alive()
	end
end

function draw_entities()
	for e in all(spawning_es) do
		e:draw()
	end
	for e in all(entities) do
		e:draw()
	end
end

--separate function to be drawn in different z-index
function draw_dead_es()
	for e in all(dead_es) do
		e:draw()
	end
end

function entity:draw()
	if self.state == "ready" then
		draw_tentacles(self.tentacles)
	end
	spr(self.spr, self.x, self.y, 1, 1, self.flip)
end

function entity:decay()
	self.decay_state += 1
	if (self.hp > 0) and (self.decay_state == decay_rate) then
		self.hp -= self.hpmax / 4
		self.decay_state = 0
	elseif self.hp <= 0 then
		self:die()
	end
end

function entity:attack(tgt)
	if self.attframe < self.attspd / 2 then
		if (self.attframe == 1) then
			sfx(sfxt.entity_atk, 2)
			if self.class == "turret" then
				self:shoot(tgt, true)
			else
				tgt:take_dmg(self.dmg)
			end
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
	self.state = "dead"
	self.spr = self.ss[1]
	dead_es_c += 1
	live_es_c = max(0, live_es_c - 1)
	if (self.class == "turret") del(turrets, self)
	add(dead_es, self)
	del(entities, self)
end

function entity:anim_spawn()
	--if animated for 30 frames
	--set it to the right spr and move to entities
	--otherwise blink
	if self.frame == 30 then
		self.frame = 0
		self.state = "hurt"
		add(entities, self)
		del(spawning_es, self)
		return
	end
	if (self.frame % 5 < 2.5) then
		self.spr = self.ss[mid(1, 4, ceil(4 * self.hp / self.hpmax) + 1)]
	else
		self.spr = 1
	end
end

function entity:anim_alive()
	if self.state == "hurt" then
		if self.hp < self.hpmax then
			self:decay()
			self.spr = self.ss[mid(1, 4, ceil(4 * self.hp / self.hpmax) + 1)]
		else
			sfx(sfxt.healed)
			healed_es_c += 1
			drop_xp(vector(self.midx, self.midy), 1)
			self.state = "ready"
			--index is used for orbiting behavior
			if self.class == "turret" then
				add(turrets, self)
				for i = 1, #turrets do
					turrets[i].orbit_pos = find_orbit_pos(p, i)
				end
			end
		end
	elseif self.state == "ready" then
		local tgt = p
		if not is_empty(enemies)
				and approx_dist(self.midx, self.midy, tgt.midx, tgt.midy) < 64 then
			local c = find_closest(self, enemies, self.search_range)
			if (not is_empty(c)) tgt = c
		end
		if self.class == "turret" then
			--orbit player
			self:move_to(self.orbit_pos.x, self.orbit_pos.y)
			printh("midx:" .. tostr(self.midx) .. " midy:" .. tostr(self.midy), "log.p8l", true)
			printh("dx:" .. tostr(self.dx) .. " dy:" .. tostr(self.dy), "log.p8l", true)
			if tgt == p then
				self.attframe = 0
				self:anim_move()
			else
				self.frame = 0
				self:attack(tgt)
			end
		elseif self.class == "melee" then
			if tgt == p then
				if approx_dist(self.midx, self.midy, p.midx, p.midy) > 18 then
					self.attframe = 0
					self:move_to(p.midx, p.midy)
					self:anim_move()
				end
			else
				if col(self, tgt, 8) then
					self.frame = 0
					self:attack(tgt)
				else
					self.attframe = 0
					self:move_to(tgt.midx, tgt.midy)
					self:anim_move()
				end
			end
			self:move_apart(entities, 10)
		end
		self:flip_spr(tgt.x)
	end
end

function entity:anim_move()
	if (self.frame % 5 < 2.5) then
		self.spr = 38
	else
		self.spr = 39
	end
end

function entity:anim_dead()
	if (self.frame > 300) del(self.dead_table, self)
end