--ui

--TODO:
--use quickset to save tokens
--fix xp/hp bars

function init_ui()
	lvlup_ui = {}
	ui = {
		xp = 0,
		spr = { 5, 6 },
		x = 0,
		y = 0,
		h = 8,
		w = 127
	}
end

function update_ui()
	ui.x = cam.x
	ui.y = cam.y
	ui.xp = flr(p.curxp / game.xpmax) * ui.w
	ui.hp = flr(p.hp / p.hpmax) * ui.w
end

function draw_ui()
	if game.state == "start" then
		draw_start()
	elseif game.state == "game" then
		draw_hud(false)
	elseif game.state == "lvlup" then
		draw_lvlup()
	elseif game.state == "gameover" then
	end
	print(version, ui.x + 114, ui.y + 122, 1)
end

function draw_start()
end

function draw_hud(draw_debug)
	--bg
	rectfill(ui.x, ui.y, ui.x + ui.w, ui.y + ui.h, 0)
	--current live entities
	spr(ui.spr[2], ui.x + 1, ui.y + 0)
	print(":" .. tostr(game.live_es), ui.x + 9, ui.y + 2, 7)
	--current live enemies
	spr(ui.spr[1], ui.x + 26, ui.y + 0)
	print(":" .. tostr(game.live_ens), ui.x + 34, ui.y + 2, 7)
	--border
	--rect(ui.x, ui.y, ui.x + 127, ui.y + 127, 1)
	--text
	print("lvl:" .. tostr(p.lvl), ui.x + 50, ui.y + 2, 7)
	print("xp:" .. tostr(p.curxp) .. "/" .. tostr(game.xpmax) .. " (" .. tostr(p.totalxp) .. ")", ui.x + 78, ui.y + 2, 7)
	--d_xp_bar()
	--d_hp_bar()
	--debug
	if draw_debug then
		print(tostr(p.dx), ui.x, ui.y + 12, 7)
		print(tostr(p.dy), ui.x, ui.y + 18, 7)
		print(tostr(p.x), ui.x, ui.y + 24, 7)
		print(tostr(p.y), ui.x, ui.y + 30, 7)
		print(tostr(cam.x), ui.x, ui.y + 36, 7)
		print(tostr(cam.y), ui.x, ui.y + 42, 7)
	end
end

function draw_lvlup_menu()
end

function d_xp_bar()
	line(ui.x, ui.y + ui.h + 1, ui.x + ui.w, ui.y + ui.h + 1, 13)
	line(ui.x, ui.y + ui.h + 1, ui.x + ui.xp, ui.y + ui.h + 1, 11)
end

function d_hp_bar()
	line(ui.x, ui.y + ui.h + 2, ui.x + ui.w, ui.y + ui.h + 2, 13)
	line(ui.x, ui.y + ui.h + 2, ui.x + ui.hp, ui.y + ui.h + 2, 8)
end