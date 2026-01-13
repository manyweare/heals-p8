--enemies

enemies, spawning_ens, dead_ens = {}, {}, {}

--enemy class
enemy = unit:new({
	live_counter = live_ens_c,
	dead_counter = dead_ens_c
})
quickset(
	enemy,
	"name,state,x,y,w,h,dx,dy,frame,attframe,hitframe,flip,attack_sfx,die_sfx",
	"enemy,spawning,0,0,8,8,0,0,0,0,0,false,5,1"
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

function init_enemies()
	enemies, spawning_ens, dead_ens = {}, {}, {}
end

function update_enemies()
	local all_ens = { enemies, spawning_ens, dead_ens }
	for k, v in pairs(all_ens) do
		for e in all(v) do
			e:update()
		end
	end
end

function draw_enemies()
	local all_es = { enemies, spawning_ens }
	for k, v in pairs(all_es) do
		for e in all(v) do
			e:draw()
		end
	end
end

--separate function to draw on different z-index
function draw_dead_ens()
	for e in all(dead_ens) do
		e:draw()
	end
end

function enemy:update_alive()
	local tgt = p
	if not is_empty(entities) then
		local c = find_closest(self, entities, self.search_range)
		if (not is_empty(c)) tgt = c
	end
	if self.class == "turret" then
		--always moves away from tgt
		self:move_to(tgt.x, tgt.y)
		if col(self, tgt, self.search_range) then
			self:attack(tgt, self.ss[3], self.ss[4])
		else
			self:anim_move()
		end
		self:flip_spr(tgt.x)
		return
	else
		if col(self, tgt, 8) then
			self:attack(tgt, self.ss[3], self.ss[4])
		else
			self:move_to(tgt.x, tgt.y)
			self:anim_move()
		end
	end
	self:move_apart(enemies, 10)
	self:flip_spr(tgt.x)
end

function enemy:anim_move()
	self.attframe = 0
	self:tgl_anim(self.animspd, self.ss[2], self.ss[3])
end

function enemy:destroy()
	drop_xp(vector(self.x, self.y), self.xp)
	add(dead_ens, self)
	del(enemies, self)
end