--tools

-- function log_to_terminal(text)
-- 	printh(text, "log", true)
-- end

-- vector functions
-- @thacuber2a03's vector math library
function vector(x, y) return { x = x or 0, y = y or 0 } end

function v_polar(a, l) return vector(l * cos(a), l * sin(a)) end
function v_add(a, b) return vector(a.x + b.x, a.y + b.y) end
function v_sub(a, b) return v_add(a, v_neg(b)) end
function v_scale(v, n) return vector(v.x * n, v.y * n) end
function v_div(v, n) return v_scale(v, 1 / n) end
function v_neg(v) return v_scale(v, -1) end

function v_dot(a, b) return a.x * b.x + a.y * b.y end
function v_magsq(v) return v_dot(v, v) end
function v_mag(v) return sqrt(v_magsq(v)) end
function v_setmag(v, n) return v_scale(v_norm(v), n) end
function v_norm(v) return v_div(v, v_mag(v)) end

function v_angle(v) return atan2(v.x, v.y) end
function v_rot(v, a) return v_polar(a, v_mag(v)) end
function v_rotby(v, a) return v_rot(v, v_angle(v) + a) end
function v_lerp(a, b, t) return v_add(a, v_scale(v_sub(b, a), t)) end

function v_limit(v, n)
	if (v_magsq(v) > n * n) v = v_setmag(v, n)
	return v
end

--OOP example by kevinthompson
--https://github.com/kevinthompson/object-oriented-pico-8?tab=readme-ov-file
-- class = setmetatable(
-- 	{
-- 		new = function(_ENV, tbl)
-- 			return setmetatable(
-- 				tbl or {}, {
-- 					__index = _ENV
-- 				}
-- 			)
-- 		end
-- 	}, { __index = _ENV }
-- )

-- object constructor

object = {}
function object:new(o)
	o = o or {}
	local a = {}
	-- copy in defaults first
	for k, v in pairs(self) do
		a[k] = v
	end
	-- write in extra parameters
	for k, v in pairs(o) do
		a[k] = v
	end
	-- metatable assignment
	setmetatable(a, self)
	self.__index = self
	return a
end

function object:update_mid()
	self.midx = self.x + self.w / 2
	self.midy = self.y + self.h / 2
end

function object:setup_col(t)
	--collision rect offsets relative to self
	-- x,y,w,h
	self.col_offset = t
	--collision rect
	self.col = {
		x = self.x + self.col_offset[1],
		y = self.y + self.col_offset[2],
		w = self.w + self.col_offset[3],
		h = self.h + self.col_offset[4]
	}
end

--updates col rect position
function object:update_col()
	self.col.x = self.x + self.col_offset[1]
	self.col.y = self.y + self.col_offset[2]
end

--used for flashing anims
function object:toggle()
	self.spr = 1
end

function object:take_dmg(dmg)
	self.hit = true
	self.hp -= dmg
	if (self.hp <= 0) self:die()
end

function object:move_to(t)
	local a = get_dir(t.x, t.y, self.x, self.y)
	local dx, dy = cos(a), sin(a)
	if not rect_rect_collision(self.col, t.col) then
		--update the direction vars to allow is_moving check
		self.dx, self.dy = dx, dy
		self.x -= self.dx * self.spd
		self.y -= self.dy * self.spd
	end
	self.flip = self:flip_spr(t)
end

function object:flip_spr(t)
	return self.x > t.x
end

--agent functions
--adapted from Daniel Shiffman's Nature of Code

agent = object:new({
	pos = vector(),
	vel = vector(),
	accel = vector(),
	tgt = vector(63, 63)
})

function agent:update_pos()
	if self.behavior == "seek" then
		self:seek(self.tgt)
		--not implemented yet
		-- elseif self.behavior == "arrive" then
		-- 	self:arrive(self.tgt, 12)
		-- elseif self.behavior == "flock" then
		-- 	self:flock(nearby)
	end
	-- self:separate(nearby)
	-- basic locomotion
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
	self.pos = v_add(self.pos, vector(p.sx, p.sy))
end

function agent:seek(tgt)
	local d = v_sub(tgt, self.pos)
	d = v_setmag(d, self.maxspd)
	local s = v_sub(d, self.vel)
	self:apply_force(s)
	return s
end

function die(o)
	o.frame = 0
	o.state = "dead"
	add(o.dead_table, o)
	del(o.alive_table, o)
	o.dead_counter += 1
	o.alive_counter -= 1
end

-- update position relative to player
-- used for scrolling map
function sync_pos(a)
	a.x += p.sx
	a.y += p.sy
end

-- from Beckon the Hellspawn
-- TODO: add author
function get_inputs()
	--register last inputs
	for x = 1, 8 do
		p_i_last[x] = p_inputs[x]
	end
	local wasd = split("4,7,26,22,0,40")
	--register current inputs
	for x = 1, 6 do
		p_inputs[x] = btn(x - 1) or stat(28, wasd[x])
	end
	--assign direction values
	for x = 1, 4 do
		if p_inputs[x] then
			p_i_data[x] = 1
		else
			p_i_data[x] = 0
		end
	end
end

function round(n)
	return (n % 1 < 0.5) and flr(n) or ceil(n)
end

-- from pico-8 wiki math section
function log10(n)
	if (n <= 0) return nil
	local f, t = 0, 0
	while n < 0.5 do
		n *= 2.71828
		t -= 1
	end
	while n > 1.5 do
		n /= 2.71828
		t += 1
	end
	n -= 1
	for i = 9, 1, -1 do
		f = n * (1 / i - f)
	end
	t += f
	-- to change base, change the
	-- divisor below to ln(base)
	return t / 2.30259
end

-- map a value from one range to another
-- similar to p5.js map
function map_value(n, min1, max1, min2, max2)
	return (((n - min1) * (max2 - min2)) / (max1 - min1)) + min2
end

-- function for calculating
-- exponents to a higher degree of
-- accuracy than using the ^ operator.
-- created by samhocevar.
-- https://www.lexaloffle.com/bbs/?tid=27864
-- @param x number to apply exponent to.
-- @param a exponent to apply.
-- @return the result of the calculation.
-- function pow(x, a)
-- 	if (a == 0) return 1
-- 	if (a < 0) x, a = 1 / x, -a
-- 	local ret, a0, xn = 1, flr(a), x
-- 	a -= a0
-- 	while a0 >= 1 do
-- 		if (a0 % 2 >= 1) ret *= xn xn, a0 = xn * xn, shr(a0, 1)
-- 	end
-- 	while a > 0 do
-- 		while a < 1 do
-- 			x, a = sqrt(x), a + a
-- 		end
-- 		ret, a = ret * x, a - 1
-- 	end
-- 	return ret
-- end

-- easing functions --
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)
function ease_out_quad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

function ease_in_quad(t, b, c, d)
	return c * ((t / d) ^ 2) + b
end

--by magic_chopstick on bbs
--sets multiple values on an object, less token intensive
function quickset(obj, keys, vals)
	local v, k = split(vals), split(keys)
	-- remove/comment out the assert below before publication
	assert(#v == #k, "quickset() error: k/v count mismatch (" .. #k .. " keys, " .. #v .. " values)")
	for i = 1, #k do
		local p, o = v[i]
		if p == "false" then
			o = false
		elseif p == "true" then
			o = true
		elseif tostr(p)[1] == "{" then
			o = split(sub(p, 2, -2), "|")
		else
			o = p
		end
		obj[k[i]] = o
	end
end

--used by projectiles
function angle_move(x, y, tx, ty, spd)
	local a = atan2(x - tx, y - ty)
	return { x = -spd * cos(a), y = -spd * sin(a) }
end

function is_moving(e)
	if ((e.dx != 0) or (e.dy != 0)) return true
	return false
end

-- move entities in a table (t) apart from each other up to an r radius
-- adapted from Beckon the Hellspawn
function move_apart(t, r)
	for i = 1, #t - 1 do
		for j = i + 1, #t do
			if rect_rect_collision(t[i], t[j]) then
				local dist = approx_dist(t[i].x, t[i].y, t[j].x, t[j].y)
				local dir = get_dir(t[i].x, t[i].y, t[j].x, t[j].y)
				local dif = r - dist
				t[j].x += cos(dir) * dif
				t[j].y += sin(dir) * dif
			end
		end
	end
end

function col(a, b, r)
	local x = abs(a.x - b.x)
	if x > r then return false end
	local y = abs(a.y - b.y)
	if y > r then return false end
	return (x * x + y * y) < r * r
end

--rect rect AABB
function rect_rect_collision(r1, r2)
	return r1.x < r2.x + r2.w
			and r1.x + r1.w > r2.x
			and r1.y < r2.y + r2.h
			and r1.y + r1.h > r2.y
end

--reset pos when out of map bounds
function reset_pos(e)
	e.x, e.y = rpd(128, 32)
end

function rpd(d, rd)
	local _dir = rnd(1)
	local _rad = d + flr(rnd(rd))
	local x = 64 + cos(_dir) * _rad
	local y = 64 + sin(_dir) * _rad
	return unpack({ x, y })
end

function get_dir(x1, y1, x2, y2)
	return atan2(x2 - x1, y2 - y1)
end

--from bbs (TODO: find op and credit)
function approx_dist(x1, y1, x2, y2)
	local dx = abs(x2 - x1)
	local dy = abs(y2 - y1)
	local maskx, masky = dx >> 31, dy >> 31
	local a0, b0 = (dx + maskx) ^^ maskx, (dy + masky) ^^ masky
	if a0 > b0 then
		return a0 * 0.9609 + b0 * 0.3984
	end
	return b0 * 0.9609 + a0 * 0.3984
end

function nearby(a, t, r)
	local n = {}
	for k, v in pairs(t) do
		if (approx_dist(a.pos, v.pos) < r) add(n, v)
	end
	return n
end

function find_closest(o, t, r)
	-- set initial dist check to 32767 (a large num)
	-- because it is the largest int p8 supports
	local c, d = 32767, 0
	if (r == nil) r = c
	local ce = {}
	for e in all(t) do
		d = approx_dist(o.x, o.y, e.x, e.y)
		if (d < c) and (d < r) then
			c = d
			ce = e
		end
	end
	return ce
end

--from bbs (TODO: find op and credit)
function is_empty(t)
	for _, _ in pairs(t) do
		return false
	end
	return true
end

--adapted from aioobe via stackoverflow
function rand_in_circle(x, y, r)
	local n = r * sqrt(rnd())
	local theta = rnd() * 2 * pi
	local rx = x + r * cos(theta)
	local ry = y + r * sin(theta)
	return { x = rx, y = ry }
end

function rand_in_circlefill(x, y, r)
	local t = {}
	for i = 1, r do
		add(t, rand_in_circle(x, y, r))
	end
	return t
end

--TODO: fix / doesn't work
--draw collision
-- function d_col(e)
-- 	rect(e.col.x, e.col.y, e.col.x + e.col.w, e.col.h + e.col.h, 8)
-- end

--tentacle functions
function create_tentacles(n, start, r1, r2, l, s, c)
	local t = {}
	for i = 0, n - 1 do
		add(
			t, {
				spos = start,
				epos = rand_in_circle(start.x, start.y, l + rnd(4) - 2),
				npos = vector(63, 63),
				r1 = r1,
				r2 = r2,
				length = l,
				samples = s,
				colors = c
			}
		)
	end
	return t
end

--spos, epos, r1, r2, samples, colors
function draw_tentacle(t)
	-- t.epos = v_lerp(t.epos, t.npos, dt)
	for i = 0, t.samples do
		local x = t.spos.x + ((t.epos.x - t.spos.x) * i / t.samples)
		local y = t.spos.y + ((t.epos.y - t.spos.y) * i / t.samples)
		local r = t.r1 + ((t.r2 - t.r1) * i / t.samples)
		local c = 1 + round((count(t.colors) - 1) * i / t.samples)
		if r > 1.5 then
			circfill(x, y, r, t.colors[c])
		else
			pset(x, y, t.colors[c])
		end
	end
end

function draw_tentacles(tentacles)
	for t in all(tentacles) do
		draw_tentacle(t)
	end
end