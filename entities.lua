--entities

all_entities, entities, turrets, spawning_es, dead_es = {}, {}, {}, {}, {}

--entity class--
entity = object:new({
	--states: spawning, hurt, ready, dead
	state = "spawning",
	tentacles = {}
})
quickset(
	entity,
	"name,hp,hpmax,decay_state,x,y,dx,dy,w,h,frame,attframe,hitframe,dist,flip,tgl,hit",
	"entity,0,4,0,0,0,0,0,8,8,1,0,0,0,false,true,false"
)

--entity types--
e_melee = entity:new({
	class = "melee",
	ss = split("32,33,34,35,36,37,38,39")
})
quickset(
	e_melee,
	"dmg,base_dmg,spd,attspd,search_range,spr",
	"1,1,.5,15,64,33"
)

e_turret = entity:new({
	class = "turret",
	ss = split("32,33,34,35,36,37,38,39"),
	orbit_pos = vector()
})
quickset(
	e_turret,
	"dmg,base_dmg,spd,attspd,search_range,spr",
	"1,1,.75,30,64,33"
)

function init_entities()
	all_entities, entities, turrets, spawning_es, dead_es = {}, {}, {}, {}, {}
end

function update_entities()
	for e in all(all_entities) do
		e:update()
	end
	for e in all(spawning_es) do
		e:anim_spawn()
	end
	for e in all(dead_es) do
		e:anim_dead()
	end
	for e in all(entities) do
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
	if self.state != "dead" then
		if self.hitframe > 0 then
			if self.hitframe <= 3 then
				self.hitframe += 1
				self.spr = self.ss[count(self.ss)]
			elseif self.hitframe > 3 then
				self.hitframe = 0
			end
		end
	end
	draw_tentacles(self.tentacles, self.main_clrs, self.state)
	spr(self.spr, self.x - 4, self.y - 4, 1, 1, self.flip)
end

function entity:decay()
	self.decay_state += 1
	if (self.hp > 0) and (self.decay_state == 150) then
		self.hp -= self.hpmax / 4
		self.decay_state = 0
	elseif self.hp <= 0 then
		self:die()
	end
end

function entity:attack(tgt)
	self:tgl_anim(self.attspd, 37, 38, self.attframe)
	self.attframe += 1
	if self.attframe >= self.attspd then
		self.attframe = 0
		sfx(sfxt.entity_atk, 2)
		if self.class == "turret" then
			self:shoot(tgt, true)
		else
			tgt:take_dmg(self.dmg)
		end
	end
end

function entity:heal(hpwr)
	self.hp = min(self.hpmax, self.hp + hpwr)
	self.decay_state = 0
	self.frame = 0
end

function entity:anim_spawn()
	if self.frame == 30 then
		self.frame = 0
		self.state = "hurt"
		add(entities, self)
		del(spawning_es, self)
	else
		self:tgl_anim(5, 33, 1)
	end
end

function entity:anim_alive()
	if self.state == "hurt" then
		if self.hp < self.hpmax then
			self:decay()
			self:tgl_anim(30, 33, 34)
		else
			sfx(sfxt.healed)
			healed_es_c += 1
			drop_xp(vector(self.x, self.y), 1)
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
				and approx_dist(self.x, self.y, tgt.x, tgt.y) < 64 then
			local c = find_closest(self, enemies, self.search_range)
			if (not is_empty(c)) tgt = c
		end
		if self.class == "turret" then
			if tgt == p then
				if approx_dist(self.x, self.y, p.x, p.y) > 16 then
					self.attframe = 0
					self:move_to(p.x, p.y)
					self:anim_move()
				end
			else
				self.frame = 0
				self:attack(tgt)
			end
		elseif self.class == "melee" then
			if tgt == p then
				if approx_dist(self.x, self.y, p.x, p.y) > 22 then
					self.attframe = 0
					self:move_to(p.x, p.y)
					self:anim_move()
				end
			else
				if col(self, tgt, 8) then
					self.frame = 0
					self:attack(tgt)
				else
					self.attframe = 0
					self:move_to(tgt.x, tgt.y)
					self:anim_move()
				end
			end
		end
		self:move_apart(entities, 10)
		self:flip_spr(tgt.x)
	end
end

function entity:anim_move()
	self:tgl_anim(30, 35, 36)
end

function entity:anim_dead()
	self.spr = self.ss[1]
	if (self.frame > 300) del(dead_es, self)
end

function entity:die()
	self.state = "dead"
	--visuals
	sfx(sfxt.entity_die)
	bloodfx(self.x, self.y)
	--counters
	dead_es_c += 1
	live_es_c = max(0, live_es_c - 1)
	--tables
	del(entities, self)
	if (self.class == "turret") del(turrets, self)
	add(dead_es, self)
	--
	printh("----- " .. self.name .. " DIED -----", "log.p8l", true)
	printh("es:" .. tostr(#entities) .. " | dead_es:" .. tostr(#dead_es), "log.p8l", true)
end