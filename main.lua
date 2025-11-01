--main

--TODOS:
--adjust xp max increase curve

function _init()
	version = "0.1"
	pi = 3.14

	--color palette--
	poke(0x5f2e, 1)
	pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 138, 139, 11, 141, 13, 130, 131 }, 1)
	--switch to a more NES palette
	--this isn't it but better than the above
	--pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 9, 135, 141, 12, 142, 11, 138 }, 1)

	--manager--
	game = {
		--current xp max
		xpmax = 3,
		--current xp modifier
		xpmod = 1,
		--current live enemies
		live_ens = 0,
		--total dead enemies
		dead_ens = 0,
		--current live entities
		live_es = 0,
		--total dead entities
		dead_es = 0,
		--total healed entities
		healed_es = 0
	}

	--lvl anim frame
	lvlanim = 0

	--easing vars--
	lt = time()
	te = 0
	dt = 0

	--setup--
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
	--easing var
	t = time()

	--update funcs--
	update_heals()
	update_entities()
	u_enemies()
	update_player()
	update_hud()
	update_fx()
	update_cam()
end

function _draw()
	cls()
	draw_map()
	draw_range()
	draw_fx()
	draw_player()
	draw_heals()
	draw_entities()
	d_enemies()
	draw_hud()
	draw_lvlup()
	draw_cam()
end

--manager functions--
function addxp(n)
	local ovrxp = 0
	n *= game.xpmod
	--check for lvl up and overflow
	if p.curxp + n >= game.xpmax then
		ovrxp = (p.curxp + n) - game.xpmax
		p.curxp = ovrxp
		--TODO: adjust leveling curve
		lvlup()
	else
		p.curxp += n * game.xpmod
	end
	p.totalxp += n * game.xpmod
end

function lvlup()
	--log scaling
	--value = steepness * log_b(level + 1) + offset
	p.lvl += 1
	lvlanim = 1
	--TODO: adjust xp max increase curve
	game.xpmax = flr(game.xpmax * 1.5)
	aoe.range = flr(10 * log10(p.lvl + 1) + 24)
	sfx(-1)
	sfx(sfxt.lvlup)
end

function draw_lvlup()
	if lvlanim > 0 then
		lvlup_fx()
		--print("lvl up!", p.x - 8, p.y + 10, 7)
		lvlanim += 1
		if (lvlanim > 60) lvlanim = 0
	end
end

--misc--
function draw_range()
	local c = 2
	fillp(0x7fdf)
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange + 16, c)
	fillp(0x7ada)
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange + 8, c)
	fillp()
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange, c)
end