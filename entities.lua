--entities

entities, spawning_es, dead_es = {}, {}, {}

--entity class--
entity = unit:new({
	live_counter = live_es_c,
	dead_counter = dead_es_c
})
quickset(
	entity,
	"name,state,hp,hpmax,decay_state,x,y,w,h,dx,dy,frame,attframe,hitframe,flip,tgl,attack_sfx,die_sfx",
	"entity,spawning,0,4,0,0,0,8,8,0,0,0,0,0,false,true,6,7"
)

--entity types--
e_melee = entity:new({
	ss = split("32,33,34,35,36,37,38,39")
})
quickset(
	e_melee,
	"type,dmg,base_dmg,hpmax,spd,attspd,search_range,sprite",
	"melee,.5,.5,4,.5,15,64,33"
)

e_turret = entity:new({
	ss = split("32,33,34,35,36,37,38,39")
})
quickset(
	e_turret,
	"type,dmg,base_dmg,hpmax,spd,attspd,search_range,sprite",
	"turret,.5,.5,3,.75,30,64,33"
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
	local _ENV = self
	if hp < hpmax then
		decay_state += 1
		if decay_state == 150 then
			self:take_dmg(hpmax / 4)
			decay_state = 0
		end
		self:tgl_anim(30, 33, 34)
		aoe_fx_fill(x, y, 8 + rnd(6), split("15,1,2"))
	else
		frame = 0
		state = "alive"
		sfx(_G.sfxt.healed)
		for i = 1, 8 do
			aoe_fx_fill(x, y, 6, split("9,7,15,1"))
			aoe_fx_fill(x, y, 8, split("10,11,15,1"))
			aoe_fx_fill(x, y, 12, split("3,11,15,1"))
		end
		-- splatfx(x, y, split("10,11,7,7"))
		drop_xp(vector(x, y), 1)
		_G.healed_es_c += 1
	end
end

function entity:update_alive()
	local _ENV = self
	local tgt = _G.p
	local dist = approx_dist(x, y, tgt.x, tgt.y)
	if not is_empty(_G.enemies) and dist < 64 then
		local c = find_closest(self, _G.enemies, search_range)
		if not is_empty(c) then
			tgt = c
			dist = approx_dist(x, y, tgt.x, tgt.y)
		end
	end
	if type == "turret" then
		if tgt == _G.p then
			if dist > 16 then
				attframe = 0
				self:anim_move(px, py)
			end
		else
			if (dist < search_range) self:attack(tgt, 37, 38, true)
		end
	elseif type == "melee" then
		if tgt == _G.p then
			if dist > 24 then
				attframe = 0
				self:anim_move(px, py)
			end
		else
			if dist < 12 then
				self:attack(tgt, 37, 38, true)
			elseif dist > 4 then
				self:anim_move(tgt.x, tgt.y)
			elseif dist > 12 then
				attframe = 0
			end
		end
	end
	self:move_apart(_G.entities, 10)
	self:flip_spr(tgt.x)
end

function entity:anim_move(x, y)
	self:tgl_anim(30, 35, 36)
	self:move_to(x, y)
end

function entity:heal(hpwr)
	local _ENV = self
	hp = min(hpmax, hp + hpwr)
	decay_state = 0
	frame = 0
end

function entity:destroy()
	add(dead_es, self)
	del(entities, self)
end