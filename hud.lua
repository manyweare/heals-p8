-- hud

function setup_hud()
	hud = {
		dead = 0,
		healed = 0,
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
	-- hud.dead = dead
	-- hud.healed = healed
	hud.xp = flr(p.curxp / xpmax) * hud.w
	hud.hp = flr(p.hp / p.hpmax) * hud.w
end

function draw_hud()
	-- bg
	rectfill(hud.x, hud.y, hud.x + hud.w, hud.y + hud.h, 1)
	-- healed
	spr(hud.spr[2], hud.x, hud.y + 0)
	print(":" .. tostr(hud.healed), hud.x + 9, hud.y + 2, 7)
	-- dead
	spr(hud.spr[1], hud.x + 26, hud.y + 0)
	print(":" .. tostr(hud.dead), hud.x + 34, hud.y + 2, 7)
	-- border
	-- rect(hud.x, hud.y, hud.x + 127, hud.y + 127, 1)
	-- text
	print("lvl:" .. tostr(p.lvl), hud.x + 50, hud.y + 2, 7)
	print("xp:" .. tostr(p.curxp) .. "/" .. tostr(xpmax) .. " (" .. tostr(p.totalxp) .. ")", hud.x + 78, hud.y + 2, 7)
	d_xp_bar()
	d_hp_bar()
	print(version, hud.x, hud.y + 122, 1)
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