--tools

function print_align(t, x, y, c, u, v)
	local ox, oy = print(t, 0, 128)
	print(t, x - ox * u, y - (oy - 128) * (v or 0), c)
end

-- vector library by @thacuber2a03
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

--OOP implementation by kevinthompson
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

function object:update()
	self:update_col()
	self:update_mid()
	sync_pos(self)
	self:reset_pos()
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

function object:move_to(x, y)
	local dir = get_dir(x, y, self.midx, self.midy)
	self.dx, self.dy = cos(dir), sin(dir)
	self.x -= self.dx * self.spd
	self.y -= self.dy * self.spd
end

function object:move_apart(t, r)
	if (#t < 2) return
	local dist, dir, dif
	for i = 1, #t do
		if t[i] != self then
			if rect_rect_collision(self, t[i]) then
				dist = approx_dist(self.midx, self.midy, t[i].midx, t[i].midy)
				dir = get_dir(self.midx, self.midy, t[i].midx, t[i].midy)
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

--reset pos when out of map bounds
function object:reset_pos()
	if self.x > 128 or self.y > 128 then
		local pos = rand_in_circle(p.midx, p.midy, 32)
		self.x, self.y = pos.x, pos.y
	end
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

function die(o)
	o.frame = 0
	o.state = "dead"
	add(o.dead_table, o)
	del(o.alive_table, o)
	o.dead_counter += 1
	o.alive_counter -= 1
end

-- update position relative to player
-- needed for scrolling map with player in center
function sync_pos(a)
	a.x += psx
	a.y += psy
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

--ease library by:
--https://www.lexaloffle.com/bbs/?tid=40577
function easeinquart(t)
	return t * t * t * t
end

function easeoutquart(t)
	t -= 1
	return 1 - t * t * t * t
end

function easeinoutquart(t)
	if t < .5 then
		return 8 * t * t * t * t
	else
		t -= 1
		return (1 - 8 * t * t * t * t)
	end
end

function lerp(a, b, t)
	return a + (b - a) * t
end

--by magic_chopstick on bbs
function quickset(obj, keys, vals)
	local v, k = split(vals), split(keys)
	-- remove/comment out below before publication
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

--from bbs (TODO: find op and credit)
function is_empty(t)
	for _, _ in pairs(t) do
		return false
	end
	return true
end

function get_dir(x1, y1, x2, y2)
	return atan2(x2 - x1, y2 - y1)
end

--used by projectiles
function angle_move(x, y, tx, ty, spd)
	local dir = get_dir(x, y, tx, ty)
	return { x = cos(dir) * spd, y = sin(dir) * spd }
end

function is_moving(e)
	if ((e.dx != 0) or (e.dy != 0)) return true
	return false
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

--adapted from musurca
--https://www.lexaloffle.com/bbs/?tid=36059
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
		if e != o then
			d = approx_dist(o.x, o.y, e.x, e.y)
			if (d < c) and (d < r) then
				c = d
				ce = e
			end
		end
	end
	return ce
end

--adapted from @aioobe via stackoverflow
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

--tentacle functions
function create_tentacles(n, sx, sy, r1, r2, l, c)
	local t = {}
	local rnd_l, rnd_lmax, ex, ey
	for i = 0, n - 1 do
		--random length
		rnd_l = l + rnd(l / 2)
		--random max length
		rnd_lmax = rnd_l + rnd(l / 2)
		--end point of tentacles on random points
		--in a circle around start coords
		ex = sx + l * cos(rnd())
		ey = sy + l * sin(rnd())
		add(
			t, {
				sx = sx,
				sy = sy,
				ex = ex,
				ey = ey,
				tx = ex,
				ty = ey,
				r1 = r1,
				r2 = r2,
				length = rnd_l,
				max_length = rnd_lmax,
				colors = c,
				start_time = time()
			}
		)
	end
	return t
end

function draw_tentacle(t)
	local s = round(t.length * 1.5)
	local x, y, r, c
	for i = 0, s do
		x = t.sx + ((t.ex - t.sx) * i / s)
		y = t.sy + ((t.ey - t.sy) * i / s)
		r = t.r1 + ((t.r2 - t.r1) * i / s)
		c = 1 + round((count(t.colors) - 1) * i / s)
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

function update_tentacles(o)
	local timer, d_center, d_move
	for t in all(o.tentacles) do
		t.sx, t.sy = o.midx, o.midy
		t.tx += psx
		t.ty += psy
		d_center = approx_dist(t.ex, t.ey, t.sx, t.sy)
		d_move = approx_dist(t.ex, t.ey, t.tx, t.ty)
		if d_center > t.max_length and d_move < 0.01 then
			--(o.dx * t.length / 2) = moves the target pos (tx,ty)
			--to direction obj is headed (dx,dy)
			t.tx = t.sx + t.length * cos(rnd()) - o.dx * t.length / 2
			t.ty = t.sy + t.length * sin(rnd()) - o.dy * t.length / 2
			--restart timer for lerp anim
			t.start_time = time()
		end
		--animation speed = ((time() - t.start_time) % 1) * 2
		timer = mid(0, ((time() - t.start_time) % 1) * 2.25, 1)
		t.ex = lerp(t.ex, t.tx, easeoutquart(timer)) + psx
		t.ey = lerp(t.ey, t.ty, easeoutquart(timer)) + psy
	end
end