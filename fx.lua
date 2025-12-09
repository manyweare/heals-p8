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
		f.t += 1
		if f.t > f.lt then
			del(fx, f)
		end
		if f.is_sw then
			f.r += f.maxr / f.lt
			if f.t / f.lt < 1 / #f.clrs then
				f.c = f.clrs[1]
			elseif f.t / f.lt < 2 / #f.clrs then
				f.c = f.clrs[2]
			elseif f.t / f.lt < 3 / #f.clrs then
				f.c = f.clrs[3]
			else
				f.c = f.clrs[4]
			end
		else
			if f.t / f.lt < 1 / #f.clrs then
				f.c = f.clrs[1]
			elseif f.t / f.lt < 2 / #f.clrs then
				f.c = f.clrs[2]
				f.r = 3 * (f.r / 4)
			elseif f.t / f.lt < 3 / #f.clrs then
				f.c = f.clrs[3]
				f.r = f.r / 2
			else
				f.c = f.clrs[4]
				f.r = f.r / 4
			end
		end
		f.x += f.dx
		f.y += f.dy
	end
end

function draw_fx()
	for f in all(fx) do
		--draw pixel for size 1, draw circle for larger
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
			p.x + p.w / 2,
			p.y + p.h / 2,
			10 + rnd(10),
			1 - rnd(2),
			1 - rnd(2),
			rnd(1) + 2,
			{ 7, 8, 9 }
		)
	end
end

function heal_fx(x, y)
	for i = 0, 5 do
		add_fx(
			x + rnd(7) - 2,
			y,
			8 + rnd(5),
			0,
			rnd(1) - 1.2,
			rnd(1) + 2,
			{ 11, 10, 15 }
		)
	end
end

function trail_fx(x, y, clrs)
	-- emit only 50% of the time
	local emit = rnd() < .5
	if emit then
		add_fx(
			x,
			y,
			4 + rnd(4),
			0,
			rnd(1) - 1.1,
			1,
			clrs
		)
	end
end

function aoe_fx(x, y, r, clrs)
	-- TODO: radiating waves
	-- for i = 0, 2 do
	-- 	local pt = rand_in_circle(x, y, r / 3)
	-- 	add_fx(
	-- 		pt.x,
	-- 		pt.y + 2,
	-- 		4 + rnd(2),
	-- 		0,
	-- 		-.3,
	-- 		1,
	-- 		clrs
	-- 	)
	-- end
	-- for i = 0, 4 do
	-- 	local pt = rand_in_circle(x, y, 2 * r / 3)
	-- 	add_fx(
	-- 		pt.x,
	-- 		pt.y + 2,
	-- 		6 + rnd(2),
	-- 		0,
	-- 		-.3,
	-- 		1,
	-- 		clrs
	-- 	)
	-- end
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
	-- aoe_fx_fill(x, y, r, clrs)
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

-- TODO: add circle shockwave
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