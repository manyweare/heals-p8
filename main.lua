-- main
function _init()
	pi = 3.14
	-- color pal
	poke(0x5f2e, 1)
	pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 138, 139, 11, 141, 13, 130, 131 }, 1)
	-- manager
	healed = 0
	dead = 0
	xpmax = 3
	xpmod = 1
	lvlanim = 0
	-- easing vars
	te = 0
	lt = time()
	dt = 0
	-- setup
	map_setup()
	setup_hud()
	player_setup()
	heals_setup()
	setup_entities()
	setup_fx()
	setup_cam()
end

function _update()
	-- easing var
	t = time()
	-- update funcs
	update_heals()
	update_entities()
	update_player()
	update_fx()
	update_hud()
	update_cam()
end

function _draw()
	cls()
	draw_map()
	draw_range()
	draw_heals()
	draw_fx()
	draw_entities()
	draw_player()
	draw_hud()
	draw_lvlup()
	draw_cam()
end

-- manager
function addxp(xp)
	local ovrxp = 0
	xp *= xpmod
	-- check for lvl up and overflow
	if p.curxp + xp >= xpmax then
		ovrxp = (p.curxp + xp) - xpmax
		p.curxp = ovrxp
		-- TODO: leveling curve
		lvlup()
	else
		p.curxp += xp * xpmod
	end
	p.totalxp += xp * xpmod
end

function lvlup()
	xpmax = flr(xpmax * 1.5)
	p.lvl += 1
	lvlanim = 1
end

function draw_lvlup()
	if lvlanim > 0 then
		lvlup_fx()
		print("lvl up!", p.x - 8, p.y + 10, 7)
		lvlanim += 1
		if (lvlanim > 60) lvlanim = 0
	end
end

-- utils
function log(text)
	printh(text, "log", true)
end

function angle_move(x, y, targetx, targety, speed)
	local a = atan2(x - targetx, y - targety)
	return { x = -speed * cos(a), y = -speed * sin(a) }
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

function is_empty(t)
	for _, _ in pairs(t) do
		return false
	end
	return true
end

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