-- main
function _init()
	version = "0.1"
	pi = 3.14
	-- color pal
	poke(0x5f2e, 1)
	pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 138, 139, 11, 141, 13, 130, 131 }, 1)
	--switch to a more NES palette
	--this isn't it but better than the above
	-- pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 9, 135, 141, 12, 142, 11, 138 }, 1)
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
	s_enemies()
	setup_fx()
	setup_cam()
end

function _update()
	-- easing var
	t = time()
	-- update funcs
	update_heals()
	update_entities()
	u_enemies()
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
	d_enemies()
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
	--log leveling scaling
	--value = steepness * log_b(level + 1) + offset
	p.lvl += 1
	lvlanim = 1
	xpmax = flr(xpmax * 1.5)
	aoe.range = flr(10 * log10(p.lvl + 1) + 24)
	sfx(-1)
	sfx(sfxt.lvlup)
end

function draw_lvlup()
	if lvlanim > 0 then
		lvlup_fx()
		-- print("lvl up!", p.x - 8, p.y + 10, 7)
		lvlanim += 1
		if (lvlanim > 60) lvlanim = 0
	end
end