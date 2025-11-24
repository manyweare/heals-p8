--tools

--TODOS:
--fix draw_col function to help debug

function log_to_terminal(text)
	printh(text, "log", true)
end

-- constructor
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

-- functions used by all objects --

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

function object:die()
	self.frame = 0
	self.state = "dead"
	add(self.dead_table, self)
	del(self.alive_table, self)
	sfx(sfxt.thud)
	self.dead_counter += 1
	self.alive_counter -= 1
end

function object:move_to(t)
	local a = get_dir(t.x, t.y, self.x, self.y)
	local dx = cos(a)
	local dy = sin(a)
	if not rect_rect_collision(self.col, t.col) then
		--update the direction vars to allow is_moving check
		self.dx = dx
		self.dy = dy
		self.x -= self.dx * self.spd
		self.y -= self.dy * self.spd
	end
	self.flip = self:flip_spr(t)
end

function object:flip_spr(t)
	return self.x > t.x
end

-- update position relative to player's
-- used for scrolling map
function sync_pos(a)
	a.x += p.sx
	a.y += p.sy
end

-- from Beckon the Hellspawn
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

function find_closest(o, t, r)
	-- setting the initial dist check to 32767 (a large num)
	-- because it is the highest int p8 supports
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
function d_col(e)
	line(e.col.x, e.col.y, e.col.w, e.col.h, 8)
end