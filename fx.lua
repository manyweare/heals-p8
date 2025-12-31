--fx

function init_fx()
	fx = {}
	-- fx settings
	hfx_size = 2
	hfx_clr = { 7, 11, -13 }
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
			p.midx,
			p.midy,
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
	for i = 0, 6 do
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
	for i = 8, r do
		local pt = rand_in_circle(x, y, i)
		add_fx(
			pt.x,
			pt.y,
			30 + rnd(30),
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
			{ 10, 11, 9 }
		)
	end
end

-- add_fx(x, y, lt, dx, dy, r, clrs)

function explode(x, y, r, t, num)
	for i = 0, num do
		add_fx(
			x,
			y,
			5 + rnd(10),
			rnd(2) - 1,
			rnd(2) - 1,
			r,
			t
		)
	end
	--shockwave
	add_fx(
		x,
		y,
		7,
		0,
		0,
		16,
		{ 7, 9, 3, 2 },
		true
	)
end

-- add_fx(x, y, lt, dx, dy, r, clrs)

function bloodfx(x, y)
	for i = 0, 32 do
		add_fx(
			x,
			y,
			7 + rnd(8),
			rnd(2) - 1,
			rnd(2) - 1,
			2,
			{ 8, 8, 12, 14 }
		)
	end
end