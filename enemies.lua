--enemies

function s_enemies()
	enemies = {}
	spawn_enemies(1)
end

function spawn_enemies(i)
	for i = 1, i do
		e = {
			x = flr(rnd(120)),
			y = flr(rnd(120)),
			h = 8,
			w = 8,
			dx = 0,
			dy = 0,
			ss = { 64, 65, 66, 67 }, --spritesheet
			spr = 64, --current sprite
			hp = 10,
			dmg = 1,
			spd = .25,
			attspd = 15,
			attframe = 1,
			animspd = 30,
			frame = 1, --current frame
			flip = false, --flip sprite
			col = {},
			col_offsets = {},
			att_sfx = 5,
		}
		--collision rect offsets relative to e
		e.col_offset = {
			x = 1,
			y = 1,
			h = -3,
			w = -2
		}
		--collision rect
		e.col = {
			x = e.x + e.col_offset.x,
			y = e.y + e.col_offset.y,
			h = e.h + e.col_offset.h,
			w = e.w + e.col_offset.w
		}
		add(enemies, e)
	end
end

function u_enemies()
	for e in all(enemies) do
		u_col(e)
		move_to_plr(e)
		e.flip = flip_spr(e)
		if rect_rect_collision(e.col, p.col) then
			e.frame = 0
			e_attack(e)
		else
			e.attframe = 0
			e_anim(e)
		end
	end
end

function d_enemies()
	for e in all(enemies) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end

function e_anim(e)
	if e.frame < e.animspd / 2 then
		e.spr = e.ss[2]
	elseif e.frame == e.animspd then
		e.frame = 0
	else
		e.spr = e.ss[1]
	end
	e.frame += 1
	--TODO: only anim if moving
	-- if is_moving(e) then
	-- 	if e.frame > e.animspd then
	-- 		e.spr = e.ss[2]
	-- 		if (e.frame == e.animspd) e.frame = 0
	-- 	else
	-- 		e.spr = e.ss[1]
	-- 	end
	-- end
end

function e_attack(e)
	if e.attframe < e.attspd / 2 then
		if (e.attframe == 1) then
			-- sfx(-1, 2)
			sfx(e.att_sfx, 2)
			p_take_damage(e.dmg, true)
		end
		e.spr = e.ss[3]
	elseif e.attframe == e.attspd then
		e.attframe = 0
	else
		e.spr = e.ss[4]
	end
	e.attframe += 1
end