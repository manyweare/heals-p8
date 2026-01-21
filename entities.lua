--entities

entities, spawning_es, dead_es = {}, {}, {}

--entity class--
entity = unit:new()
quickset(
	entity,
	"name,state,xp,decay_amount,attframe,hitframe,tgl,attack_sfx,die_sfx,healed_sfx",
	"entity,spawning,1,0,0,0,true,6,7,2"
)

--entity types--
e_melee = entity:new({
	ss = split("32,33,34,35,36,37,38,39")
})
quickset(
	e_melee,
	"type,dmg,base_dmg,hpmax,spd,attspd,search_range,sprite",
	"melee,.5,.5,8,.4,15,64,33"
)

e_turret = entity:new({
	ss = split("32,33,34,35,36,37,38,39")
})
quickset(
	e_turret,
	"type,dmg,base_dmg,hpmax,spd,attspd,search_range,sprite",
	"turret,1,1,2,.5,30,76,33"
)

function init_entities()
	entities, spawning_es, dead_es = {}, {}, {}
end

function update_entities()
	local all_es = { entities, spawning_es, dead_es }
	for k, v in inext, all_es do
		for i, e in inext, v do
			e:update()
		end
	end
end

function draw_entities()
	local all_es = { entities, spawning_es }
	for i, v in inext, all_es do
		for i, e in inext, v do
			e:draw()
		end
	end
end

--separate function to be drawn in different z-index
function draw_dead_es()
	for i, e in inext, dead_es do
		e:draw()
	end
end

function entity:update_decaying()
	local _ENV = self
	if hp < hpmax then
		decay_amount += 1
		if decay_amount == 150 then
			self:take_dmg(hpmax / 4)
			decay_amount = 0
		end
		self:tgl_anim(30, 33, 34)
		if frame % 30 == 0 then
			for i = 1, 12 do
				aoe_fx_fill(x, y, 10, split("15,1,1,2"))
				aoe_fx_fill(x, y, 12, split("1,1,2,2"))
				aoe_fx_fill(x, y, 16, split("1,2,2,2"))
			end
		end
	else
		frame = 0
		sfx(healed_sfx)
		for i = 1, 8 do
			aoe_fx_fill(x, y, 10, split("9,7,15,1"))
			aoe_fx_fill(x, y, 12, split("10,11,15,1"))
			aoe_fx_fill(x, y, 16, split("3,11,15,1"))
		end
		splatfx(x, y, split("10,11,7,7"))
		drop_xp(vector(x, y), xp)
		_G.healed_es_c += 1
		sprite = 35
		state = "alive"
	end
end

function entity:update_alive()
	local _ENV = self
	local tgt = p
	local dist = approx_dist(self, tgt)
	if not is_empty(_G.enemies) and dist < 64 then
		local c = find_closest(self, _G.enemies, search_range)
		if not is_empty(c) then
			tgt = c
			dist = approx_dist(self, tgt)
		end
	end
	if type == "turret" then
		if approx_dist(self, p) > 24 then
			self:move_to(px, py)
		end
		if tgt == p then
			attframe = 0
			self:anim_move(35, 36)
		else
			if (approx_dist(self, tgt) < search_range) self:attack(tgt, 37, 38, true)
		end
	else
		if tgt == p then
			attframe = 0
			if dist > 24 then
				self:move_to(px, py)
				self:anim_move(35, 36)
			end
		else
			if dist < 12 then
				self:attack(tgt, 37, 38, true)
			elseif dist > 4 then
				self:move_to(tgt.x, tgt.y)
				self:anim_move(35, 36)
			elseif dist > 12 then
				attframe = 0
			end
		end
	end
	self:move_apart(_G.entities, 10)
	self:flip_spr(tgt.x)
end

function entity:heal(hpwr)
	local _ENV = self
	hp = min(hpmax, hp + hpwr)
	decay_amount = 0
	frame = 0
end

function entity:update_dead()
	self.sprite = self.ss[1]
	if (self.frame > 360) del(dead_es, self)
end

function entity:come_alive()
	self.tgl_tentacles = true
	live_es_c += 1
	add(entities, self)
	del(spawning_es, self)
	self.state = "decaying"
end

function entity:destroy()
	local x, y = self.x, self.y
	for i = 1, 10 do
		aoe_fx_fill(x, y, 10, split("8,8,12,14"))
		aoe_fx_fill(x, y, 12, split("12,8,12,14"))
		aoe_fx_fill(x, y, 16, split("12,12,14,14"))
	end
	live_es_c -= 1
	dead_es_c += 1
	del(entities, self)
	add(dead_es, self)
end