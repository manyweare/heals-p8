--ui

--TODO:
--use quickset to save tokens
--fix xp/hp bars
--level up menu art

function init_ui()
	ui = {
		xp = 0,
		spr = { 5, 6 },
		x = 0,
		y = 0,
		h = 8,
		w = 127
	}
	--current ui selection
	sel = 1
	--lvl anim frame counter
	lvlanim = 0
	--anim tgl var
	lvlanim_tgl = true
	--anim clr
	lvlup_clr = 7
end

function update_ui()
	ui.x = cam.x
	ui.y = cam.y
	ui.xp = flr(p.curxp / game.xpmax) * ui.w
	ui.hp = flr(p.hp / p.hpmax) * ui.w
end

function update_lvlup()
	if (lvlanim > 0) lvlanim += 1
	if (lvlanim > 30) lvlanim = 0
	--up
	if (btnp(2)) sel = max(sel - 1, 1)
	--down
	if (btnp(3)) sel = min(sel + 1, 3)
	--x
	if btn(5) then
		if not is_empty(lvlup_options) then
			--if heal already acquired, increase lvl
			--otherwise add it to currrent heals
			if count(curr_heals, lvlup_options[sel]) > 0 then
				heal_upgrade(lvlup_options[sel])
			else
				add(curr_heals, lvlup_options[sel])
			end
		end
		_update = update_game
		_draw = draw_game
	end
end

function draw_ui()
	print(version, ui.x + 114, ui.y + 121, 1)
end

function draw_hud()
	--bg
	rectfill(ui.x, ui.y, ui.x + ui.w, ui.y + ui.h, 0)
	--current live entities
	spr(ui.spr[2], ui.x + 1, ui.y + 0)
	print(":" .. tostr(game.live_es), ui.x + 9, ui.y + 2, 7)
	--current live enemies
	spr(ui.spr[1], ui.x + 26, ui.y + 0)
	print(":" .. tostr(game.live_ens), ui.x + 34, ui.y + 2, 7)
	--text
	print("lvl:" .. tostr(p.lvl), ui.x + 52, ui.y + 2, 7)
	print("xp:" .. tostr(p.curxp) .. "/" .. tostr(game.xpmax), ui.x + 84, ui.y + 2, 7)
	--d_xp_bar()
	--d_hp_bar()
	-- border
	rect(ui.x, ui.y, ui.x + 127, ui.y + 127, 1)
end

function draw_lvlup()
	if lvlanim > 0 then
		lvlup_fx()
		if lvlanim_tgl then
			lvlup_clr = 11
		else
			lvlup_clr = 7
		end
		print("lvl up!", p.x - 8, p.y - 5 - (lvlanim / 2), lvlup_clr)
		if (lvlanim % 3 == 0) lvlanim_tgl = not lvlanim_tgl
	end
	--bg
	rectfill(ui.x, ui.y + 42, ui.x + 48, ui.y + 84, 0)
	print("select:", ui.x + 4, ui.y + 46, 7)
	for i = 1, #lvlup_options do
		local l = 1
		local c = 7
		--if player already has this heal,
		--show the next level of the heal
		if count(curr_heals, lvlup_options[i]) > 0 then
			l = lvlup_options[i].lvl + 1
		end
		if (i == sel) then c = 11 end
		print(
			lvlup_options[i].name .. " " .. tostr(l),
			ui.x + 4, ui.y + 48 + i * 8, c
		)
	end
	print(tostr(sel))
end

function draw_gameover()
	rectfill(ui.x, ui.y + 42, ui.x + 128, ui.y + 84, 0)
	print("you died", ui.x + 4, ui.y + 46, 7)
end

function d_xp_bar()
	line(ui.x, ui.y + ui.h + 1, ui.x + ui.w, ui.y + ui.h + 1, 13)
	line(ui.x, ui.y + ui.h + 1, ui.x + ui.xp, ui.y + ui.h + 1, 11)
end

function d_hp_bar()
	line(ui.x, ui.y + ui.h + 2, ui.x + ui.w, ui.y + ui.h + 2, 13)
	line(ui.x, ui.y + ui.h + 2, ui.x + ui.hp, ui.y + ui.h + 2, 8)
end

function draw_debug()
	for i = 1, #curr_heals do
		print(
			curr_heals[i].name .. " " .. tostr(curr_heals[i].lvl),
			ui.x + 2, ui.y + 8 + i * 6, 2
		)
	end
	-- print("p.dx:" .. tostr(p.dx), ui.x, ui.y + 12, 7)
	-- print("p.dy:" .. tostr(p.dy), ui.x, ui.y + 18, 7)
	-- print("p.x:" .. tostr(p.x), ui.x, ui.y + 24, 7)
	-- print("p.y:" .. tostr(p.y), ui.x, ui.y + 30, 7)
	-- print("cam.x:" .. tostr(cam.x), ui.x, ui.y + 36, 7)
	-- print("cam.y:" .. tostr(cam.y), ui.x, ui.y + 42, 7)
	-- print("cpu:" .. tostr(stat(1)), ui.x, ui.y + 48, 7)
end