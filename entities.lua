--entities

entities, spawning_es, dead_es = {}, {}, {}

--entity class--
entity = unit:new({
	live_counter = live_es_c,
	dead_counter = dead_es_c,
	tentacles = {}
})
quickset(
	entity,
	"name,state,hp,hpmax,decay_state,x,y,w,h,dx,dy,frame,attframe,hitframe,flip,tgl,attack_sfx,die_sfx",
	"entity,spawning,0,4,0,0,0,8,8,0,0,0,0,0,false,true,6,7"
)

--entity types--
e_melee = entity:new({
	class = "melee",
	ss = split("32,33,34,35,36,37,38,39")
})
quickset(
	e_melee,
	"dmg,base_dmg,spd,attspd,search_range,spr",
	".5,.5,.5,15,64,33"
)

e_turret = entity:new({
	class = "turret",
	ss = split("32,33,34,35,36,37,38,39")
})
quickset(
	e_turret,
	"dmg,base_dmg,spd,attspd,search_range,spr",
	"1,1,.75,30,64,33"
)

function init_entities()
	entities, spawning_es, dead_es = {}, {}, {}
end

function update_entities()
	local all_es = { entities, spawning_es, dead_es }
	for k, v in pairs(all_es) do
		for e in all(v) do
			e:update()
		end
	end
end

function draw_entities()
	local all_es = { entities, spawning_es }
	for k, v in pairs(all_es) do
		for e in all(v) do
			e:draw()
		end
	end
end

--separate function to be drawn in different z-index
function draw_dead_es()
	for e in all(dead_es) do
		e:draw()
	end
end

function entity:update_decaying()
	if self.hp < self.hpmax then
		self.decay_state += 1
		if self.decay_state == 150 then
			self:take_dmg(self.hpmax / 4)
			self.decay_state = 0
		end
		self:tgl_anim(30, 33, 34)
		aoe_fx_fill(self.x, self.y, 8, split("15,1,2"))
	else
		self.frame = 0
		self.state = "alive"
		sfx(sfxt.healed)
		splatfx(self.x, self.y, split("10,11,7,7"))
		drop_xp(vector(self.x, self.y), 1)
		healed_es_c += 1
	end
end

function entity:update_alive()
	local tgt, x, y = p, self.x, self.y
	local dist = approx_dist(x, y, tgt.x, tgt.y)
	if not is_empty(enemies) and dist < 64 then
		local c = find_closest(self, enemies, self.search_range)
		if not is_empty(c) then
			tgt = c
			dist = approx_dist(x, y, tgt.x, tgt.y)
		end
	end
	if self.class == "turret" then
		if tgt == p then
			if (dist > 16) self:anim_move(p.x, p.y)
		else
			if (dist < self.search_range) self:attack(tgt, 37, 38, true)
		end
	elseif self.class == "melee" then
		if tgt == p then
			if (dist > 24) self:anim_move(p.x, p.y)
		else
			if dist < 16 then
				self:attack(tgt, 37, 38, true)
			elseif dist > 8 then
				self:anim_move(tgt.x, tgt.y)
			end
		end
	end
	self:move_apart(entities, 10)
	self:flip_spr(tgt.x)
end

function entity:anim_move(x, y)
	self.attframe = 0
	self:tgl_anim(30, 35, 36)
	self:move_to(x, y)
end

function entity:heal(hpwr)
	self.hp = min(self.hpmax, self.hp + hpwr)
	self.decay_state = 0
	self.frame = 0
end

function entity:destroy()
	add(dead_es, self)
	del(entities, self)
end