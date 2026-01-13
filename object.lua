--object

-- different oop approach --
--by @Stompy, https://www.lexaloffle.com/bbs/?pid=79601

-- _G = _ENV -- just a new name to distinguish this as the original global scope
-- _G.__index = _G -- if _G is used as a metatable, it will look itself for unfound properties

-- local class do
-- 	local mt = setmetatable(
-- 		{
-- 			--defaults
-- 			update = function(_ENV)
-- 			end,
-- 			draw = function(_ENV)
-- 			end,
-- 			init = function(_ENV)
-- 			end,
-- 			-- takes a table of nondefault values
-- 			__call = function(self, o)
-- 				o = o or {}
-- 				-- each instance sets itself as the new prototype
-- 				setmetatable(o, self)
-- 				-- looks in itself for unfound properties
-- 				self.__index = self
-- 				-- sugar to allow calling class like a function
-- 				self.__call = getmetatable(self).__call
-- 				-- call an init/constructor function if given
-- 				o:init(self)
-- 				-- return the new instance
-- 				return o
-- 			end
-- 		}, _G
-- 	)
-- 	-- the class mt is the global _G scope !IMPORTANT
-- 	-- if you don't keep this reference to _G you're going to run into trouble later
-- 	mt.__index = mt -- this class mt indexes itself if child doesn't have a property
-- 	class = setmetatable({}, mt) -- set the classes metatable
-- end

-- dog = class {
-- 	x = 10,
-- 	update = function(_ENV)
-- 		if (x < 127) x += 1
-- 	end
-- }

-- object constructor --
object = {}
function object:new(o)
	o = o or {}
	local a = {}
	-- copy defaults
	for k, v in pairs(self) do
		a[k] = v
	end
	-- extra parameters
	for k, v in pairs(o) do
		a[k] = v
	end
	setmetatable(a, self)
	self.__index = self
	return a
end

function object:move_to(x, y)
	local dir = get_dir(x, y, self.x, self.y)
	self.dx, self.dy = cos(dir), sin(dir)
	self.x -= self.dx * self.spd
	self.y -= self.dy * self.spd
end

function object:move_apart(t, r)
	if (#t < 2) return
	local dist, dir, dif
	for i = 1, #t do
		if t[i] != self then
			if col(self, t[i], 8) then
				dist = approx_dist(self.x, self.y, t[i].x, t[i].y)
				dir = get_dir(self.x, self.y, t[i].x, t[i].y)
				dif = r - dist
				t[i].x += cos(dir) * dif
				t[i].y += sin(dir) * dif
			end
		end
	end
end

function object:flip_spr(tx)
	self.flip = self.x > tx
end

function object:tgl_anim(spd, f1, f2, counter)
	counter = counter or self.frame
	if (counter % spd < spd / 2) then
		self.spr = f1
	else
		self.spr = f2
	end
end

----- unit class -----

unit = object:new()

function unit:update()
	if (self.tentacles) update_tentacles(self)
	self.frame += 1
	self:reset_pos()
	sync_pos(self)
	if self.state == "dead" then
		self:update_dead()
	elseif self.state == "spawning" then
		self:update_spawning()
	elseif self.state == "decaying" then
		self:update_decaying()
	elseif self.state == "alive" then
		self:update_alive()
	end
end

function unit:update_spawning()
	--blink
	if self.frame < 45 then
		self:tgl_anim(5, self.ss[2], 1)
		if (self.frame % 5 < 2.5) then
			self.tgl_tentacles = true
		else
			self.tgl_tentacles = false
		end
	else
		--come alive once done blinking
		self.frame = 0
		self.tgl_tentacles = true
		if self.name == "entity" then
			self.state = "decaying"
			add(entities, self)
			del(spawning_es, self)
			live_es_c += 1
		else
			self.state = "alive"
			add(enemies, self)
			del(spawning_ens, self)
			live_ens_c += 1
		end
	end
end

function unit:update_dead()
	self.spr = self.ss[1]
	if self.frame > 300 then
		if self.name == "entity" then
			del(dead_es, self)
		else
			del(dead_ens, self)
		end
	end
end

function unit:draw()
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
	if (self.tentacles and self.tgl_tentacles) draw_tentacles(self.tentacles, self.main_clrs, self.state)
	spr(self.spr, self.x - 4, self.y - 4, 1, 1, self.flip)
	-- print(self.state, self.x - 10, self.y + 10, 2)
end

--reset pos when out of map bounds
function unit:reset_pos(new_r)
	if (self.state == "dead" or self.state == "decaying") return
	new_r = new_r or 64
	if self.x > 172 or self.x < -44 or self.y > 172 or self.y < -44 then
		local pos = rand_in_circle(p.x, p.y, new_r)
		self.x, self.y = pos.x, pos.y
	end
end

function unit:attack(tgt, f1, f2, is_friendly)
	is_friendly = is_friendly or false
	self.frame = 0
	self:tgl_anim(self.attspd, f1, f2, self.attframe)
	self.attframe += 1
	if self.attframe >= self.attspd then
		self.attframe = 0
		sfx(sfxt.entity_atk, 2)
		self:shoot(tgt, is_friendly)
	end
end

function unit:shoot(tgt, is_friendly)
	local b = bullet:new({
		x = self.x,
		y = self.y,
		ix = self.x,
		iy = self.y,
		tx = tgt.x,
		ty = tgt.y,
		dmg = self.dmg,
		tgt = tgt,
		friendly = is_friendly
	})
	add(bullets, b)
end

function unit:take_dmg(dmg)
	self.hitframe = 1
	self.hp -= dmg
	if (self.hp <= 0) self:die()
end

function unit:die()
	self:destroy()
	self.frame = 1
	self.state = "dead"
	--visuals
	if self.name == "entity" then
		for i = 1, 10 do
			aoe_fx_fill(self.x, self.y, 6, split("8,8,12,14"))
			aoe_fx_fill(self.x, self.y, 10, split("12,8,12,14"))
			aoe_fx_fill(self.x, self.y, 12, split("12,12,14,14"))
		end
	end
	splatfx(self.x, self.y)
	sfx(self.die_sfx)
	--counters
	self.dead_counter += 1
	self.live_counter = max(0, live_es_c - 1)
end

--agent functions
--adapted from Daniel Shiffman's Nature of Code
agent = object:new({
	pos = vector(),
	vel = vector(),
	accel = vector(),
	maxspd = 1,
	maxfrc = .1,
	tgt = vector()
})

function agent:update_pos()
	if self.behavior == "seek" then
		self:seek(self.tgt)
	elseif self.behavior == "arrive" then
		self:arrive(self.tgt, 12)
	end
	-- self:separate(nearby)
	self:move()
end

function agent:apply_force(f)
	self.accel = v_add(self.accel, f)
end

function agent:move()
	self.accel = v_limit(self.accel, self.maxfrc)
	self.vel = v_add(self.vel, self.accel)
	self.vel = v_limit(self.vel, self.maxspd)
	self.pos = v_add(self.pos, self.vel)
	--update pos relative to player
	self.pos = v_add(self.pos, vector(psx, psy))
end

function agent:seek(tgt)
	local d = v_sub(tgt, self.pos)
	d = v_setmag(d, self.maxspd)
	local s = v_sub(d, self.vel)
	self:apply_force(s)
	return s
end

function agent:arrive(tgt, r)
	local d = v_sub(tgt, self.pos)
	local dist = v_mag(d)
	if dist < r then
		local mag = map_value(dist, 0, r, 0, self.maxspd)
		d = v_setmag(d, mag)
	else
		d = v_setmag(d, self.maxspd)
	end
	local s = v_sub(d, self.vel)
	self:apply_force(s)
end