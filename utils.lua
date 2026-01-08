--tools

-- function print_align(t, x, y, c, u, v)
-- 	local ox, oy = print(t, 0, 128)
-- 	print(t, x - ox * u, y - (oy - 128) * (v or 0), c)
-- end

-- function indexof(o, t)
-- 	for i, v in ipairs(t) do
-- 		if (v == o) return i
-- 	end
-- 	return nil
-- end

pi = 3.14

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

function round(n)
	return (n % 1 < 0.5) and flr(n) or ceil(n)
end

--https://pico-8.fandom.com/wiki/Math
function log2(n)
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
	return t / 0.69314
end

--map a value from one range to another
--similar to p5.js map
function map_value(n, min1, max1, min2, max2)
	return (((n - min1) * (max2 - min2)) / (max1 - min1)) + min2
end

--adapted from @shiftalow (https://www.lexaloffle.com/bbs/?tid=32411)
function cat(...)
	local c = {}
	for i, s in pairs({ ... }) do
		for k, v in pairs(s) do
			if tonum(k) then
				add(c, v)
			else
				c[k] = v
			end
		end
	end
	return c
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

-- update position relative to player for scrolling map
function sync_pos(a)
	a.x += psx
	a.y += psy
end

function find_orbit_pos(o, i, r, t)
	r = r or 18
	local d = i / #t
	local x, y = o.x + r * cos(d), o.y + r * sin(d)
	return vector(x, y)
end

function col(a, b, r)
	local x = abs(a.x - b.x)
	if x > r then return false end
	local y = abs(a.y - b.y)
	if y > r then return false end
	return (x * x + y * y) < r * r
end

--rect rect AABB collision
function rect_rect_collision(r1, r2)
	return r1.x < r2.x + r2.w
			and r1.x + r1.w > r2.x
			and r1.y < r2.y + r2.h
			and r1.y + r1.h > r2.y
end

--adapted from musurca
--https://www.lexaloffle.com/bbs/?tid=36059
function approx_dist(x1, y1, x2, y2)
	local dx, dy = abs(x2 - x1), abs(y2 - y1)
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

function offscreen(t)
	local o = {}
	for e in all(t) do
		if (e.x > 128 or e.x < 0 or e.y > 128 or e.y < 0) add(o, e)
	end
	return o
end

function find_closest(o, t, r)
	-- c = initial range check
	-- ce = closest entity
	-- 32767 is the largest num p8 supports
	local c, d, ce = 32767, 0, {}
	r = r or c
	for e in all(t) do
		if e != o then
			d = approx_dist(o.x, o.y, e.x, e.y)
			if (d < c) and (d < r) then
				c, ce = d, e
			end
		end
	end
	return ce
end

function closest_offscreen(o, t)
	local ot = offscreen(t)
	local c = find_closest(o, ot)
	return c
end

function rand_in_circle(x, y, r)
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