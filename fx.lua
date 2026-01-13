--fx

function init_fx()
	fx = {}
	-- fx settings
	hfx_size = 2
	hfx_clr = split("7,11,-13")
	hfx_amt = 4
end

function update_fx()
	for f in all(fx) do
		local c, r, ft, flt = f.c, f.r, f.t, f.lt
		local fclrs = f.clrs
		ft += 1
		if ft > flt then
			del(fx, f)
		end
		if f.is_sw then
			r += f.maxr / flt
			if ft / flt < 1 / #fclrs then
				c = fclrs[1]
			elseif ft / flt < 2 / #fclrs then
				c = fclrs[2]
			elseif ft / flt < 3 / #fclrs then
				c = fclrs[3]
			else
				c = fclrs[4]
			end
		else
			if ft / flt < 1 / #fclrs then
				c = fclrs[1]
			elseif ft / flt < 2 / #fclrs then
				c = fclrs[2]
				r = 3 * (r / 4)
			elseif ft / flt < 3 / #fclrs then
				c = fclrs[3]
				r = r / 2
			else
				c = fclrs[4]
				r = r / 4
			end
		end
		f.r, f.c, f.t = r, c, ft
		f.x += f.dx
		f.y += f.dy
	end
end

function draw_fx()
	for f in all(fx) do
		if f.r <= 1 then
			pset(f.x, f.y, f.c)
		else
			circfill(f.x, f.y, f.r, f.c)
		end
		sync_pos(f)
	end
end

function add_fx(x, y, lt, dx, dy, r, clrs, is_sw)
	is_sw = is_sw or false
	local f = {
		x = x,
		y = y,
		t = 0,
		lt = lt,
		dx = dx,
		dy = dy,
		r = r,
		c = 0,
		clrs = clrs
	}
	if is_sw then
		f.is_sw = true
		f.maxr = f.r
		f.r = 0
	end
	add(fx, f)
end

function lvlup_fx()
	for i = 0, 1 do
		add_fx(
			p.x,
			p.y,
			15 + rnd(15),
			1 - rnd(2),
			1 - rnd(2),
			rnd(1) + 2,
			split("7, 10, 9, 2")
		)
	end
end

function heal_fx(x, y)
	for i = 0, 5 do
		add_fx(
			x + rnd(7) - 4,
			y,
			8 + rnd(5),
			0,
			rnd(1) - 1.2,
			rnd(1) + 2,
			split("11, 10, 15")
		)
	end
end

function trail_fx(x, y, clrs)
	-- emit only 25% of the time
	local emit = rnd() < .25
	if emit then
		add_fx(
			x,
			y,
			8 + rnd(6),
			0,
			rnd(1) - 1.1,
			1,
			split("9, 11, 10")
		)
	end
end

function aoe_fx(x, y, r, clrs)
	for i = 0, 4 do
		local pt = rand_in_circle(x, y, r)
		add_fx(
			pt.x,
			pt.y + 2,
			6 + rnd(4),
			0,
			-.3,
			1,
			clrs
		)
	end
end

function aoe_fx_fill(x, y, r, clrs)
	for i = 1, r do
		local pt = rand_in_circle(x, y, i)
		add_fx(
			pt.x,
			pt.y - 1,
			16 + rnd(16),
			0,
			0,
			1,
			clrs
		)
	end
end

function proj_fx(x, y)
	for i = 0, 2 do
		add_fx(
			x + rnd(4) - 2,
			y + rnd(4) - 2,
			6 + rnd(4),
			0,
			0,
			rnd(1) + 1,
			split("10,3,15,2")
		)
	end
end

-- add_fx(x, y, lt, dx, dy, r, clrs)

function explode(x, y, r, t, num)
	for i = 0, num do
		add_fx(
			x,
			y,
			12,
			rnd(2) - 1,
			rnd(2) - 1,
			3,
			t
		)
	end
	--shockwave
	add_fx(
		x,
		y,
		5,
		0,
		0,
		r,
		split("10,3,15,2"),
		true
	)
end

-- add_fx(x, y, lt, dx, dy, r, clrs)

function splatfx(x, y, t)
	t = t or split("8,8,12,14")
	for i = 0, 24 do
		add_fx(
			x,
			y,
			8 + rnd(8),
			rnd(2) - 1,
			rnd(2) - 1,
			2,
			t
		)
	end
end

function bulletfx(x, y)
	for i = 0, 16 do
		add_fx(
			x,
			y,
			7 + rnd(8),
			rnd(2) - 1,
			rnd(2) - 1,
			2,
			split("7,8,12,14")
		)
	end
	--shockwave
	add_fx(
		x,
		y,
		10,
		0,
		0,
		4,
		split("7,8,12,14"),
		true
	)
end