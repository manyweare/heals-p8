--object

_G = _ENV
_G.__index = _G

------------ class constructor ------------

class = setmetatable({}, { __index = _ENV })

function class:new(o)
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

function class:move_to(tx, ty)
	local _ENV = self
	local dir = get_dir(tx, ty, x, y)
	--dx,dy needed for other checks
	dx, dy = cos(dir), sin(dir)
	x -= dx * spd
	y -= dy * spd
end

function class:move_apart(t, d)
	local _ENV = self
	if (#t < 2) return
	local dist, dir, diff
	for i = 1, #t do
		if t[i] != self then
			if col(self, d / 2, t[i], d / 2) then
				dist = approx_dist(self, t[i])
				dir = get_dir(x, y, t[i].x, t[i].y)
				diff = d - dist
				t[i].x += cos(dir) * diff
				t[i].y += sin(dir) * diff
			end
		end
	end
end

function class:flip_spr(tx)
	self.flip = self.x > tx
end

function class:tgl_anim(spd, f1, f2, counter)
	local _ENV = self
	counter = counter or frame
	if (counter % spd < spd / 2) then
		sprite = f1
	else
		sprite = f2
	end
end

------------ unit class ------------

unit = class:new()
quickset(
	unit,
	"x,y,dx,dy,r,hp,frame,flip",
	"0,0,0,0,4,0,0,false"
)

function unit:update()
	local _ENV = self
	frame += 1
	sync_pos(self)
	self:reset_pos()
	if (tentacles) update_tentacles(self)
	if state == "dead" then
		self:update_dead()
	elseif state == "spawning" then
		self:update_spawning()
	elseif state == "decaying" then
		self:update_decaying()
	elseif state == "alive" then
		self:update_alive()
	end
end

function unit:update_spawning()
	local _ENV = self
	--blink when spawning
	if frame < 45 then
		if (frame % 5 < 2.5) then
			sprite = 1
			tgl_tentacles = false
		else
			sprite = ss[2]
			tgl_tentacles = true
		end
	else
		--come alive once done blinking
		frame = 0
		self:come_alive()
	end
end

function unit:draw()
	local _ENV = self
	if state != "dead" and hitframe > 0 then
		if hitframe <= 3 then
			hitframe += 1
			sprite = ss[#ss]
		else
			hitframe = 0
		end
	end
	if (tentacles and tgl_tentacles) draw_tentacles(tentacles, main_clrs, state)
	spr(sprite, x - 4, y - 4, 1, 1, flip)
	-- print(state, x - 10, y + 10, 2)
end

--reset pos when out of map bounds
function unit:reset_pos(new_r)
	local _ENV = self
	if (state == "dead" or state == "decaying") return
	new_r = new_r or 64
	if x > 172 or x < -44 or y > 172 or y < -44 then
		local pos = rand_in_circle(px, py, new_r)
		x, y = pos.x, pos.y
	end
end

function unit:anim_move(f1, f2)
	self:tgl_anim(30, f1, f2)
end

function unit:attack(tgt, f1, f2, is_friendly)
	local _ENV = self
	is_friendly = is_friendly or false
	frame = 0
	attframe += 1
	self:tgl_anim(attspd, f1, f2, attframe)
	if attframe == attspd then
		attframe = 0
		sfx(attack_sfx, 2)
		self:shoot(tgt, is_friendly)
	end
end

function unit:shoot(tgt, is_friendly)
	local _ENV = self
	local b = bullet:new({
		x = x,
		y = y,
		ix = x,
		iy = y,
		tx = tgt.x,
		ty = tgt.y,
		dmg = dmg,
		tgt = tgt,
		friendly = is_friendly
	})
	add(bullets, b)
end

function unit:take_dmg(dmg)
	local _ENV = self
	hitframe = 1
	hp -= dmg
	if (hp <= 0) self:die()
end

function unit:level_up()
	local _ENV = self
	hpmax = round(level_up_stat(10, plvl, hpmax))
	dmg = max(base_dmg, level_up_stat(5, plvl, base_dmg) / 3)
	xp = plvl
end

function unit:die()
	local _ENV = self
	state = "dead"
	frame = 0
	splatfx(x, y)
	sfx(die_sfx)
	self:destroy(x, y)
end

------------ agent class ------------

--adapted from Daniel Shiffman's Nature of Code
agent = class:new({
	pos = vector(),
	vel = vector(),
	accel = vector(),
	maxspd = 1,
	maxfrc = .1,
	tgt = vector()
})

function agent:update_pos()
	local _ENV = self
	if behavior == "seek" then
		self:seek(tgt)
	elseif behavior == "arrive" then
		self:arrive(tgt, 12)
	end
	self:move()
end

function agent:apply_force(f)
	local _ENV = self
	accel = v_add(accel, f)
end

function agent:move()
	local _ENV = self
	accel = v_limit(accel, maxfrc)
	vel = v_add(vel, accel)
	vel = v_limit(vel, maxspd)
	pos = v_add(pos, vel)
	--update pos relative to player
	pos = v_add(pos, vector(psx, psy))
end

function agent:seek(tgt)
	local _ENV = self
	local d = v_sub(tgt, pos)
	d = v_setmag(d, maxspd)
	local s = v_sub(d, vel)
	self:apply_force(s)
	return s
end

function agent:arrive(tgt, r)
	local _ENV = self
	local d, dist = v_sub(tgt, pos), v_mag(d)
	if dist < r then
		local mag = map_value(dist, 0, r, 0, maxspd)
		d = v_setmag(d, mag)
	else
		d = v_setmag(d, maxspd)
	end
	local s = v_sub(d, vel)
	self:apply_force(s)
end