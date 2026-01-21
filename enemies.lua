--enemies

enemies, spawning_ens, dead_ens = {}, {}, {}

--enemy class
enemy = unit:new()
quickset(
	enemy,
	"name,state,attframe,hitframe,attack_sfx,die_sfx",
	"enemy,spawning,0,0,5,1"
)

--enemy types
en_small = enemy:new({
	ss = split("112,64,65,66,67,68")
})
quickset(
	en_small,
	"type,hp,hpmax,dmg,base_dmg,spd,xp,sprite,attspd,animspd,search_range",
	"small,5,5,.5,.5,.5,1,64,15,30,64"
)

en_medium = enemy:new({
	ss = split("112,80,81,82,83,84")
})
quickset(
	en_medium,
	"type,hp,hpmax,dmg,base_dmg,spd,xp,sprite,attspd,animspd,search_range",
	"medium,10,10,2,2,.33,3,80,20,30,64"
)

en_turret = enemy:new({
	ss = split("112,96,97,98,99,100")
})
quickset(
	en_turret,
	"type,hp,hpmax,dmg,base_dmg,spd,xp,sprite,attspd,animspd,search_range",
	"turret,5,5,1.25,1.25,-0.15,3,96,30,30,86"
)

function init_enemies()
	enemies, spawning_ens, dead_ens = {}, {}, {}
end

function update_enemies()
	local all_ens = { enemies, spawning_ens, dead_ens }
	for i, v in inext, all_ens do
		for i, en in inext, v do
			en:update()
		end
	end
end

function draw_enemies()
	local all_ens = { enemies, spawning_ens }
	for i, v in inext, all_ens do
		for i, en in inext, v do
			en:draw()
		end
	end
end

--separate function to draw on different z-index
function draw_dead_ens()
	for i, en in inext, dead_ens do
		en:draw()
	end
end

function enemy:update_alive()
	local _ENV = self
	local tgt = p
	if not is_empty(_G.entities) then
		local c = find_closest(self, _G.entities, search_range)
		if (not is_empty(c)) tgt = c
	end
	local tx, ty = tgt.x, tgt.y
	if type == "turret" then
		--always moves away from tgt
		self:move_to(tx, ty)
		if col(self, search_range, tgt, tgt.r) then
			self:attack(tgt, ss[4], ss[5])
		else
			attframe = 0
			self:anim_move(ss[2], ss[3])
		end
	else
		if col(self, r, tgt, tgt.r) then
			self:attack(tgt, ss[4], ss[5])
		else
			attframe = 0
			self:move_to(tx, ty)
			self:anim_move(ss[2], ss[3])
		end
	end
	self:move_apart(_G.enemies, 8)
	self:flip_spr(tx)
end

function enemy:update_dead()
	self.sprite = self.ss[1]
	if (self.frame > 120) del(dead_ens, self)
end

function enemy:come_alive()
	self.tgl_tentacles = true
	live_ens_c += 1
	add(enemies, self)
	del(spawning_ens, self)
	self.state = "alive"
end

function enemy:destroy()
	local _ENV = self
	self.sprite = self.ss[1]
	drop_xp(vector(self.x, self.y), self.xp)
	live_ens_c -= 1
	dead_ens_c += 1
	add(dead_ens, self)
	del(enemies, self)
end