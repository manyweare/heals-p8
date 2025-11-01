--tools

function log_to_terminal(text)
	printh(text, "log", true)
end

--count or reset
function c_or_r(c, n)
	if c > n then
		return 0
	else
		return c + 1
	end
end

-- from pico-8 wiki math
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

--by magic_chopstick
--sets multiple values on an object, less token intensive
function quickset(obj, keys, vals)
	local v, k = split(vals), split(keys)
	-- remove/comment out the assert below before publication
	assert(#v == #k, "quickset() error: key/val count mismatch (" .. #k .. " keys, " .. #v .. " values)")
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

-- function angle_move(x, y, targetx, targety, speed)
-- 	local a = atan2(x - targetx, y - targety)
-- 	return { x = -speed * cos(a), y = -speed * sin(a) }
-- end

function is_moving(e)
	if ((e.dx != 0) or (e.dy != 0)) return true
	return false
end

function move_to_plr(e)
	local a = get_dir(p.x - (p.w / 2), p.y - (p.h / 2), e.x, e.y)
	local dx = cos(a)
	local dy = sin(a)
	if not rect_rect_collision(e.col, p.col) then
		--update the direction vars to allow is_moving check
		e.dx = dx
		e.dy = dy
		e.x -= e.dx * e.spd
		e.y -= e.dy * e.spd
	end
end

function move_to(e, t)
	local a = get_dir(t.x - (t.w / 2), t.y - (t.h / 2), e.x, e.y)
	local dx = cos(a)
	local dy = sin(a)
	if not rect_rect_collision(e.col, t.col) then
		--update the direction vars to allow is_moving check
		e.dx = dx
		e.dy = dy
		e.x -= e.dx * e.spd
		e.y -= e.dy * e.spd
	end
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

function flip_spr(e, t)
	if (e.x < t.x) then
		return false
	else
		return true
	end
end

function u_col(e)
	e.col.x = e.x + e.col_offset[1]
	e.col.y = e.y + e.col_offset[2]
end

function col(a, b, r)
	local x = abs(a.x - b.x)
	if x > r then return false end
	local y = abs(a.y - b.y)
	if y > r then return false end
	return (x * x + y * y) < r * r
end

function player_col(e)
	if p.inv_c < 1 then
		if col(p, e, 4) then
			add_shake(8)
			p_take_damage(e.dmg, true)
			return true
		end
	end
	return false
end

function reset_pos(e)
	e.x, e.y = rpd(128, 32)
end

function get_dir(x1, y1, x2, y2)
	return atan2(x2 - x1, y2 - y1)
end

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

function find_closest(o, t)
	-- setting the initial dist check to 32767 (a large num)
	-- because it is the highest int p8 supports
	local c, d = 32767, 0
	local ce = {}
	for e in all(t) do
		d = approx_dist(o.x, o.y, e.x, e.y)
		if (d < c) then
			c = d
			ce = e
		end
	end
	return ce
end

function rpd(d, rd)
	local _dir = rnd(1)
	local _rad = d + flr(rnd(rd))
	local x = 64 + cos(_dir) * _rad
	local y = 64 + sin(_dir) * _rad
	return unpack({ x, y })
end

function is_empty(t)
	for _, _ in pairs(t) do
		return false
	end
	return true
end

-- easing functions
function ease_out_quad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
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

--draw collision
function d_col(e)
	line(e.col.x, e.col.y, e.col.w, e.col.h, 8)
end