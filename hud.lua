-- hud
function setup_hud()
	hud = {
		dead = 0,
		healed = 0,
		xp = 0,
		spr = { 5, 6 },
		x = 0,
		y = 0,
		h = 8
	}
end

function update_hud()
	hud.x = cam.x
	hud.y = cam.y
	hud.dead = dead
	hud.healed = healed
	hud.xpw = 50
	hud.xp = (p.curxp / xpmax) * hud.xpw
end

function draw_hud()
	--bg
	rectfill(hud.x, hud.y, hud.x + 127, hud.y + hud.h, 1)
	--healed
	spr(hud.spr[2], hud.x + 1, hud.y + 0)
	print(":" .. tostr(hud.healed), hud.x + 9, hud.y + 2, 7)
	-- --dead
	spr(hud.spr[1], hud.x + 26, hud.y + 0)
	print(":" .. tostr(hud.dead), hud.x + 34, hud.y + 2, 7)
	d_xp_bar()
	-- --border
	rect(hud.x, hud.y, hud.x + 127, hud.y + 127, 1)
	print("xp:" .. tostr(p.curxp) .. "/" .. tostr(xpmax) .. " (" .. tostr(p.totalxp) .. ")", hud.x + 2, hud.y + 121, 1)
	-- print("t:" .. tostr(p.totalxp), hud.x + 2 + 32, 115, 7)
end

function d_xp_bar()
	rectfill(hud.x + 76, hud.y + 3, hud.x + 76 + hud.xpw, hud.y + 5, 15)
	rectfill(hud.x + 76, hud.y + 3, hud.x + 76 + hud.xp, hud.y + 5, 11)
	rrect(hud.x + 76, hud.y + 2, hud.xpw, 5, 1, 7)
end