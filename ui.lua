--ui

function init_ui()
	uix, uiy, uih, uiw = 0, 0, 8, 127
	uif, uisel, uixp, uispr = 1, 1, 0, { 5, 6 }
	lvlup_f, lvlup_clr, lvlup_tgl = 0, 7, true
end

function update_ui()
	uif += 1
	if (uif > 30) uif = 1
	uix, uiy = camx, camy
	uixp = min((p.curxp / xpmax) * uiw, uiw)
end

function update_lvlup()
	if (lvlup_f > 0) lvlup_f += 1
	if (lvlup_f > 30) lvlup_f = 0
	--up
	if (btnp(2)) uisel = max(uisel - 1, 1)
	--down
	if (btnp(3)) uisel = min(uisel + 1, 3)
	--x
	if btn(5) then
		if not is_empty(lvlup_options) then
			--if heal already acquired, increase lvl
			--otherwise add it to currrent heals
			if count(curr_heals, lvlup_options[uisel]) > 0 then
				heal_upgrade(lvlup_options[uisel])
			else
				add(curr_heals, lvlup_options[uisel])
			end
		end
		resume_game()
	end
end

function draw_ui()
	print(version, uix + 112, uiy + 122, 0)
	print(version, uix + 111, uiy + 121, 2)
	print(tostr(round(playtime / 30)), uix + 1, uiy + 121, 2)
end

function draw_hud()
	--current live entities
	spr(uispr[2], uix + 10, uiy + 1)
	print(":" .. tostr(#entities), uix + 18, uiy + 3, 7)
	--text
	print("lvl:" .. tostr(p.lvl), uix + 92, uiy + 3, 7)
	d_xp_bar()
	d_hp_bar(p)
	for e in all(entities) do
		d_hp_bar(e)
		d_offscreen_marker(e.x, e.y, 4)
	end
	for e in all(spawning_es) do
		d_hp_bar(e)
		d_offscreen_marker(e.x, e.y, 4)
	end
	line()
end

function draw_lvlup()
	if lvlup_f > 0 then
		lvlup_fx()
		lvlup_clr = 7
		if lvlup_tgl then lvlup_clr = 11 end
		print("lvl up!", px - 8, py - 5 - (lvlup_f / 2), lvlup_clr)
		if (lvlup_f % 3 == 0) lvlup_tgl = not lvlup_tgl
	end
	--bg
	local bgclr, bgx, bgy, bgw, bgh = 1, uix + 2, uiy + 42, uix + 42, uiy + 78
	rectfill(bgx + 1, bgy + 1, bgw + 1, bgh + 1, bgclr)
	rectfill(bgx, bgy, bgw, bgh, 0)
	rect(bgx, bgy, bgw, bgh, bgclr)
	--text
	print("select:", bgx + 4, bgy + 4, 7)
	for i = 1, #lvlup_options do
		local lvl, clr = 1, 7
		--if player already has this heal,
		--show the next level of the heal
		if count(curr_heals, lvlup_options[i]) > 0 then
			lvl = lvlup_options[i].lvl + 1
		end
		if (i == uisel) then
			clr = 11
			print(
				lvlup_options[i].name .. " " .. tostr(lvl),
				bgx + 5, bgy + 5 + (i * 8), bgclr
			)
		end
		print(
			lvlup_options[i].name .. " " .. tostr(lvl),
			bgx + 4, bgy + 4 + (i * 8), clr
		)
	end
end

function d_xp_bar()
	line(uix, uiy, uix + uiw, uiy, 2)
	line(uix, uiy, uix + uixp, uiy, 11)
end

function d_hp_bar(a)
	local x, y, w, hp, hpmax, state = a.x, a.y, a.r * 2, a.hp, a.hpmax, a.state
	if (state == "spawning") return
	if (hp >= hpmax) return
	local _hp = min((hp / hpmax) * w, w)
	local clr = 8
	line(x - 4, y - 8, x + w - 4, y - 8, 1)
	if (state == "decaying") clr = 6
	--flash bar if hp < 20%
	if hp <= round(hpmax / 20) and uif % 10 < 5 then
		rect(x - 5, y - 9, x + w - 3, y - 7, 1)
		clr = 7
	end
	line(x - 4, y - 8, x + _hp - 4, y - 8, clr)
end

--p=padding
function d_offscreen_marker(x, y, p)
	p = p or 16
	local r = 128 - p
	local offr, offl, offt, offb = x > r, x < p, y < p, y > r
	local x, y = mid(p, x, r), mid(p + uih, y, r)
	if offr or offl or offt or offb then
		circfill(x, y, 1, 7)
		pset(x, y, 11)
	end
end