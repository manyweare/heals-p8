--main

--TODOS:
--check token count
--adjust xp max increase curve
--improve state machine (change init upd draw)
--leveling system

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
		--game states
		state = "game",
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
	lvlanim = 1

	--easing vars--
	lt = time()
	te = 0
	dt = 0

	--setup--
	init_state(game.state)
end

function _update()
	--for easing
	t = time()
	update_state(game.state)
end

function _draw()
	cls()
	draw_state(game.state)
end

--game states--

function init_state(s)
	if s == "start" then
	elseif s == "game" then
		init_map()
		init_ui()
		init_player()
		init_heals()
		init_entities()
		init_enemies()
		init_fx()
		init_cam()
	elseif s == "lvlup" then
	elseif s == "gameover" then
	end
end

function update_state(s)
	if s == "start" then
		update_ui()
	elseif s == "game" then
		update_heals()
		update_entities()
		update_enemies()
		update_player()
		update_ui()
		update_fx()
		update_cam()
	elseif s == "lvlup" then
		update_ui()
	elseif s == "gameover" then
		update_ui()
	end
end

function draw_state(s)
	if s == "start" then
		draw_ui()
	elseif s == "game" then
		draw_map()
		draw_range()
		draw_fx()
		draw_enemies()
		draw_entities()
		draw_player()
		draw_heals()
		draw_ui()
		draw_lvlup()
		draw_cam()
	elseif s == "lvlup" then
		draw_ui()
		draw_lvlup()
	elseif s == "gameover" then
		draw_ui()
	end
end

--manager functions--
function addxp(n)
	local ovrxp = 0
	n *= game.xpmod
	--check for lvl up and overflow
	if p.curxp + n >= game.xpmax then
		ovrxp = (p.curxp + n) - game.xpmax
		p.curxp = ovrxp
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
	aoe.range = flr(10 * log10(p.lvl + 1) + hrange / 2)
	beam.range = flr(10 * log10(p.lvl + 1) + hrange)
	sfx(-1)
	sfx(sfxt.lvlup)
end

function draw_lvlup()
	if lvlanim > 0 then
		lvlup_fx()
		print("lvl up!", p.x - 8, p.y - 5 - (lvlanim / 2), 7)
		lvlanim += 1
		if (lvlanim > 30) lvlanim = 0
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