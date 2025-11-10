--player

--l, r, u, d, lu, ru, rd, ld
--dir_bit = { 1, 2, 4, 8, 5, 6, 10, 9 }
--dirx = { -1, 1, 0, 0, -1, 1, 1, -1 }
--diry = { 0, 0, -1, 1, -1, -1, 1, 1 }

--TODO:
--use quickset to save tokens

function init_player()
	p = {
		lvl = 1,
		curxp = 0,
		totalxp = 0,
		inv_f = 30, --invulnerability frames
		inv_c = 0, --inv count
		hp = 10,
		hpmax = 10,
		regen = .5,
		regen_spd = 1,
		x = 59, --63 - p.w / 2
		y = 59, --63 - p.h / 2
		dx = 0,
		dy = 0,
		w = 8,
		h = 8,
		spd = 1,
		maxspd = 1,
		spr = 16,
		ss = { 16, 17, 18, 19 },
		f = 0,
		animspd = 3,
		flipx = false,
		flipy = false,
		col = {}
	}
	--player collision rect offsets
	p.col_offset = { 1, 2, -3, -2 }
	--collision rect
	p.col = {
		x = p.x + p.col_offset[1],
		y = p.y + p.col_offset[2],
		w = p.w + p.col_offset[3],
		h = p.h + p.col_offset[4]
	}
	--trail fx colors
	tclrs = { 7, 11, -13 }
end

function draw_player()
	if not (p.inv_c / 2 % 2 < 1) then
		spr(1, p.x, p.y, 1, 1, p.flipx, p.flipy)
	else
		spr(p.spr, p.x, p.y, 1, 1, p.flipx, p.flipy)
	end
end

function update_player()
	move_player()
	anim_player()
	--update player's collision rect coords
	u_col(p)
	--invulnerability counters
	p.inv_c = max(p.inv_c - 1, 0)
	--regen
	if time() % p.regen_spd <= .02 then
		p.hp = min(p.hp + p.regen, p.hpmax)
	end
end

function anim_player()
	if is_moving(p) then
		p.f += 1
		p.flipx = p.dx < 0
		if p.f == p.animspd then
			p.f = 0
			p.spr += 1
			if (p.spr > p.ss[#p.ss]) p.spr = p.ss[1]
		end
	else
		--temp idle spr
		p.spr = 17
	end
	--flip trail if player is flipped
	local xo = p.w
	if (p.flipx) xo -= p.w - 1
	--fire fx
	trail_fx(p.x + xo, p.y, tclrs, 1)
end

function move_player()
	local dx, dy = 0, 0
	--drag coeficient
	local drg = .8
	--uses a bitmask to remove triple presses
	local btnm = btn() & 0b1111
	--normalized diagonal coeficient
	local n = .7
	--input code
	if (btnm == 1) then
		--left
		dx -= 1
		dy = 0
	elseif (btnm == 2) then
		--right
		dx += 1
		dy = 0
	elseif (btnm == 4) then
		--up
		dx = 0
		dy -= 1
	elseif (btnm == 8) then
		--down
		dx = 0
		dy += 1
	elseif (btnm == 5) then
		--left + up
		dx -= 1
		dy -= 1
	elseif (btnm == 6) then
		--right + up
		dx += 1
		dy -= 1
	elseif (btnm == 10) then
		--right + down
		dx += 1
		dy += 1
	elseif (btnm == 9) then
		--left + down
		dx -= 1
		dy += 1
	else
		dx = 0
		dy = 0
	end
	dx = mid(-p.maxspd, dx, p.maxspd)
	dy = mid(-p.maxspd, dy, p.maxspd)
	--normalize diagonals
	if abs(dx) == abs(dy) then
		dx *= n
		dy *= n
	end
	wall_check(p)
	if can_move(p, dx, dy) then
		p.x += dx
		p.y += dy
	else
		tdx, tdy = dx, dy
		while not can_move(p, tdx, tdy) do
			if (abs(tdx) <= 0.1) then
				tdx = 0
			else
				tdx *= 0.9
			end
			if (abs(tdy) <= 0.1) then
				tdy = 0
			else
				tdy *= 0.9
			end
		end
		p.x += tdx
		p.y += tdy
	end
	p.dx, p.dy = dx, dy
	--TODO: FIX COBBLESTONING
	-- anti-cobblestone
	-- if (p.dx != dx) and (p.dy != dy) and (dx == dy) then
	-- 	p.x = flr(p.x) + .5
	-- 	p.y = flr(p.y) + .5
	-- end
	-- drag
	if (abs(dx) > 0) dx *= drg
	if (abs(dy) > 0) dy *= drg
	if (abs(dx) < 0.02) dx = 0
	if (abs(dy) < 0.02) dy = 0
end

--player take damage
--d is dmg
--i is boolean for iframes
function p_take_damage(d, i)
	add_shake(3)
	local _d = d
	if _d < ceil(d * 0.4) then
		_d = ceil(d * 0.4)
	end
	p.hp = max(p.hp - max(1, d), 0)
	if (i) p.inv_c = p.inv_f
	if (p.hp <= 0) game_over()
end

--draws circle around player
function draw_range()
	fillp(0x7fdf)
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange + 16, 2)
	fillp(0x7ada)
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange + 8, 2)
	fillp()
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange, 2)
end