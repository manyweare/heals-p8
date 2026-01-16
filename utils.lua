--tools

-- function print_align(t, x, y, c, u, v)
-- 	local ox, oy = print(t, 0, 128)
-- 	print(t, x - ox * u, y - (oy - 128) * (v or 0), c)
-- end

pi = 3.14

-- vector library by @thacuber2a03 (https://www.lexaloffle.com/bbs/?tid=50410)
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
	-- to change base, change the divisor below to ln(base)
	return t / 0.69314
end

--map a value from one range to another
function map_value(n, min1, max1, min2, max2)
	return (((n - min1) * (max2 - min2)) / (max1 - min1)) + min2
end

--by @shiftalow (https://www.lexaloffle.com/bbs/?tid=32411)
function cat(...)
	local f = {}
	for i, s in pairs({ ... }) do
		for k, v in pairs(s) do
			if tonum(k) then
				add(f, v)
			else
				f[k] = v
			end
		end
	end
	return f
end

--by @magic_chopstick (https://www.lexaloffle.com/bbs/?tid=151352)
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

function is_empty(t)
	for _, _ in pairs(t) do
		return false
	end
	return true
end

--ease library by (https://www.lexaloffle.com/bbs/?tid=40577)
function lerp(a, b, t)
	return a + (b - a) * t
end

function easeoutquart(t)
	t -= 1
	return 1 - t * t * t * t
end

-- function easeinquart(t)
-- 	return t * t * t * t
-- end

-- function easeinoutquart(t)
-- 	if t < .5 then
-- 		return 8 * t * t * t * t
-- 	else
-- 		t -= 1
-- 		return (1 - 8 * t * t * t * t)
-- 	end
-- end

function get_dir(x1, y1, x2, y2)
	return atan2(x2 - x1, y2 - y1)
end

function angle_move(x, y, tx, ty, spd)
	local dir = get_dir(x, y, tx, ty)
	return { x = cos(dir) * spd, y = sin(dir) * spd }
end

function is_moving(e)
	if ((e.dx != 0) or (e.dy != 0)) return true
	return false
end

-- update position relative to player's  for scrolling map
function sync_pos(a)
	a.x += psx
	a.y += psy
end

function sync_screen_pos(x, y)
	x += psx
	y += psy
end

function find_orbit_pos(o, i, r, t)
	r = r or 18
	local d = i / #t
	local x, y = o.x + r * cos(d), o.y + r * sin(d)
	return vector(x, y)
end

function col(a, b, r)
	local x, y = abs(a.x - b.x), abs(a.y - b.y)
	if x > r then return false end
	if y > r then return false end
	return (x * x + y * y) < r * r
end

--adapted from @musurca (https://www.lexaloffle.com/bbs/?tid=36059)
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

-- function offscreen(t)
-- 	local o = {}
-- 	for e in all(t) do
-- 		if (e.x > 128 or e.x < 0 or e.y > 128 or e.y < 0) add(o, e)
-- 	end
-- 	return o
-- end

function find_closest(u, t, r)
	-- c = initial range check
	-- ce = closest entity
	-- 32767 is the largest num p8 supports
	local c, d, ce = 32767, 0, {}
	r = r or c
	for e in all(t) do
		if e != u then
			d = approx_dist(u.x, u.y, e.x, e.y)
			if (d < c) and (d < r) then
				c, ce = d, e
			end
		end
	end
	return ce
end

function is_in_range(a, b, r)
	return approx_dist(a.x, a.y, b.x, b.y) < r
end

function is_hurt(e)
	return e.hp > 0 and e.hp < e.hpmax
end

function closest_hurt(e, ...)
	return find_closest(e, all_hurt(...))
end

function most_hurt(...)
	local m, lowhp = {}, 32767
	for k, v in pairs({ ... }) do
		for e in all(v) do
			if is_hurt(e) and e.hp < lowhp then
				m = e
				lowhp = e.hp
			end
		end
	end
	return m
end

function all_hurt(...)
	local a = {}
	for k, v in pairs({ ... }) do
		for e in all(v) do
			if (is_hurt(e)) add(a, e)
		end
	end
	return a
end

function rand_in_circle(x, y, r)
	local theta = rnd() * 2 * pi
	local rx, ry = x + r * cos(theta)
	local ry = y + r * sin(theta)
	return { x = rx, y = ry }
end

function rand_in_circlefill(x, y, r)
	local t = {}
	while r > 0 do
		add(t, rand_in_circle(x, y, r))
		r -= 1
	end
	return t
end