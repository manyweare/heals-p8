--ui

--TODO:
--use quickset to save tokens
--fix xp/hp bars -DONE
--level up menu art
--level up bg scales with text length
--heal numbers using sprites or p8scii

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
	--lvl anim tgl var
	lvlanim_tgl = true
	--lvl anim clr
	lvlup_clr = 7
	--heal and dmg numbers
	nums = {}
	--ui frame for anims
	ui_f = 1
end

function update_ui()
	--for ui anim
	ui_f += 1
	if (ui_f > 30) ui_f = 1
	ui.x, ui.y = cam.x, cam.y
	ui.xp = min((p.curxp / game.xpmax) * ui.w, ui.w)
	-- animate numbers
	for n in all(nums) do
		n.f += 1
		n.y -= .25
		sync_pos(n)
		if (n.f > n.lt) del(nums, n)
	end
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
	print(version, ui.x + 117, ui.y + 122, 0)
	print(version, ui.x + 116, ui.y + 121, 2)
	-- numbers animation
	for n in all(nums) do
		--shadow
		-- print(n.txt, n.x - 5, n.y - 7, 0)
		local i = 1
		local j = n.lt / 4
		if n.f < j then
			i = 1
		elseif n.f >= j and n.f < j * 3 then
			i = 3
		elseif n.f >= j * 3 then
			i = 4
		end
		print("+", n.x - 2, n.y - 8, hclrs[i])
	end
end

function draw_hud()
	--bg
	-- rectfill(ui.x, ui.y, ui.x + ui.w, ui.y + ui.h, 2)
	--current live entities
	spr(ui.spr[2], ui.x + 10, ui.y + 1)
	print(":" .. tostr(game.live_es), ui.x + 18, ui.y + 3, 7)
	--current live enemies
	-- spr(ui.spr[1], ui.x + 33, ui.y + 1)
	-- print(":" .. tostr(game.live_ens), ui.x + 41, ui.y + 3, 7)
	--text
	print("lvl:" .. tostr(p.lvl), ui.x + 92, ui.y + 3, 7)
	-- print("xp:" .. tostr(p.curxp) .. "/" .. tostr(game.xpmax), ui.x + 90, ui.y + 3, 7)
	d_xp_bar()
	d_hp_bar(p)
	for h in all(entities) do
		d_hp_bar(h)
	end
	line()
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
	local bgc = 1
	local bgx, bgy = ui.x + 2, ui.y + 42
	local bgw, bgh = ui.x + 42, ui.y + 78
	-- fillp(0x7ada)
	rectfill(bgx + 1, bgy + 1, bgw + 1, bgh + 1, bgc)
	-- fillp()
	rectfill(bgx, bgy, bgw, bgh, 0)
	rect(bgx, bgy, bgw, bgh, bgc)
	--text
	print("select:", bgx + 4, bgy + 4, 7)
	for i = 1, #lvlup_options do
		local l = 1
		local c = 7
		--if player already has this heal,
		--show the next level of the heal
		if count(curr_heals, lvlup_options[i]) > 0 then
			l = lvlup_options[i].lvl + 1
		end
		if (i == sel) then
			c = 11
			print(
				lvlup_options[i].name .. " " .. tostr(l),
				bgx + 5, bgy + 5 + (i * 8), bgc
			)
		end
		print(
			lvlup_options[i].name .. " " .. tostr(l),
			bgx + 4, bgy + 4 + (i * 8), c
		)
	end
end

function d_xp_bar()
	line(ui.x, ui.y, ui.x + ui.w, ui.y, 2)
	line(ui.x, ui.y, ui.x + ui.xp, ui.y, 11)
end

function d_hp_bar(a)
	if (a == p and a.hp >= a.hpmax) return
	local hp = min((a.hp / a.hpmax) * a.w, a.w)
	line(a.x, a.y - 4, a.x + a.w, a.y - 4, 1)
	local c = 8
	--flash bar if hp < 10%
	if (a.hp <= ceil(a.hpmax / 10) and ui_f % 7 < 3.5) c = 7
	line(a.x, a.y - 4, a.x + hp, a.y - 4, c)
end

function add_h_num(h)
	n = {
		txt = h.pwr,
		x = h.tx,
		y = h.ty,
		f = 0,
		lt = 20
	}
	add(nums, n)
end

function draw_log()
	-- for i = 1, #curr_heals do
	-- 	print(
	-- 		curr_heals[i].name .. " " .. tostr(curr_heals[i].lvl),
	-- 		ui.x + 10, ui.y + 8 + i * 6, 7
	-- 	)
	-- end
	-- print("p.dx:" .. tostr(p.dx), ui.x, ui.y + 12, 7)
	-- print("p.dy:" .. tostr(p.dy), ui.x, ui.y + 18, 7)
	-- print("p.x:" .. tostr(p.x), ui.x, ui.y + 24, 7)
	-- print("p.y:" .. tostr(p.y), ui.x, ui.y + 30, 7)
	-- print("cam.x:" .. tostr(cam.x), ui.x, ui.y + 36, 7)
	-- print("cam.y:" .. tostr(cam.y), ui.x, ui.y + 42, 7)
	-- print("cpu:" .. tostr(stat(1)), ui.x, ui.y + 48, 7)
	-- print("hp:" .. tostr(p.hp), ui.x, ui.y + 48, 7)
end