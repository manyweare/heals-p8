--hud

--TODO:
--use quickset to save tokens

function setup_hud()
	hud = {
		xp = 0,
		spr = { 5, 6 },
		x = 0,
		y = 0,
		h = 8,
		w = 127
	}
end

function update_hud()
	hud.x = cam.x
	hud.y = cam.y
	--hud.dead = dead
	--hud.healed = healed
	hud.xp = flr(p.curxp / game.xpmax) * hud.w
	hud.hp = flr(p.hp / p.hpmax) * hud.w
end

function draw_hud()
	--bg
	rectfill(hud.x, hud.y, hud.x + hud.w, hud.y + hud.h, 1)
	--current live entities
	spr(hud.spr[2], hud.x + 1, hud.y + 0)
	print(":" .. tostr(game.live_es), hud.x + 9, hud.y + 2, 7)
	--current live enemies
	spr(hud.spr[1], hud.x + 26, hud.y + 0)
	print(":" .. tostr(game.live_ens), hud.x + 34, hud.y + 2, 7)
	--border
	--rect(hud.x, hud.y, hud.x + 127, hud.y + 127, 1)
	--text
	print("lvl:" .. tostr(p.lvl), hud.x + 50, hud.y + 2, 7)
	print("xp:" .. tostr(p.curxp) .. "/" .. tostr(game.xpmax) .. " (" .. tostr(p.totalxp) .. ")", hud.x + 78, hud.y + 2, 7)
	--d_xp_bar()
	--d_hp_bar()
	print(version, hud.x + 114, hud.y + 122, 1)
	--debug
	-- print(tostr(p.dx), hud.x, hud.y + 12, 7)
	-- print(tostr(p.dy), hud.x, hud.y + 18, 7)
	-- print(tostr(p.x), hud.x, hud.y + 24, 7)
	-- print(tostr(p.y), hud.x, hud.y + 30, 7)
	-- print(tostr(cam.x), hud.x, hud.y + 36, 7)
	-- print(tostr(cam.y), hud.x, hud.y + 42, 7)
end

--TODO: fix bars

function d_xp_bar()
	line(hud.x, hud.y + hud.h + 1, hud.x + hud.w, hud.y + hud.h + 1, 13)
	line(hud.x, hud.y + hud.h + 1, hud.x + hud.xp, hud.y + hud.h + 1, 11)
end

function d_hp_bar()
	line(hud.x, hud.y + hud.h + 2, hud.x + hud.w, hud.y + hud.h + 2, 13)
	line(hud.x, hud.y + hud.h + 2, hud.x + hud.hp, hud.y + hud.h + 2, 8)
end