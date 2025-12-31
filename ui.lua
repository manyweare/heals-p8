--ui

--TODO:
--use quickset to save tokens
--fix xp/hp bars -DONE
--level up menu art
--level up bg scales with text length
--heal numbers using sprites or p8scii

function init_ui()
	uix, uiy, uih, uiw = 0, 0, 8, 127
	uixp = 0
	uispr = { 5, 6 }
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
	uif = 1
end

function update_ui()
	--for ui anim
	uif += 1
	if (uif > 30) uif = 1
	uix, uiy = cam.x, cam.y
	uixp = min((p.curxp / xpmax) * uiw, uiw)
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
		resume_game()
	end
end

function draw_ui()
	print(version, uix + 117, uiy + 122, 0)
	print(version, uix + 116, uiy + 121, 2)
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
	-- rectfill(uix, uiy, uix + uiw, uiy + uih, 2)
	--current live entities
	spr(uispr[2], uix + 10, uiy + 1)
	print(":" .. tostr(live_es), uix + 18, uiy + 3, 7)
	--current live enemies
	-- spr(uispr[1], uix + 33, uiy + 1)
	-- print(":" .. tostr(live_ens), uix + 41, uiy + 3, 7)
	--text
	print("lvl:" .. tostr(p.lvl), uix + 92, uiy + 3, 7)
	-- print("xp:" .. tostr(p.curxp) .. "/" .. tostr(xpmax), uix + 90, uiy + 3, 7)
	d_xp_bar()
	d_hp_bar(p)
	for h in all(entities) do
		d_hp_bar(h)
	end
	print(round(playtime), uix + 1, uiy + 121, 7)
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
	local bgx, bgy = uix + 2, uiy + 42
	local bgw, bgh = uix + 42, uiy + 78
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
	line(uix, uiy, uix + uiw, uiy, 2)
	line(uix, uiy, uix + uixp, uiy, 11)
end

function d_hp_bar(a)
	if (a == p and a.hp >= a.hpmax) return
	local hp = min((a.hp / a.hpmax) * a.w, a.w)
	line(a.x, a.y - 4, a.x + a.w, a.y - 4, 1)
	local c = 8
	--flash bar if hp < 10%
	if (a.hp <= ceil(a.hpmax / 10) and uif % 7 < 3.5) c = 7
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
	-- 		uix + 10, uiy + 8 + i * 6, 7
	-- 	)
	-- end
end