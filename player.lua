-- player

-- l, r, u, d, lu, ru, rd, ld
-- dir_bit = { 1, 2, 4, 8, 5, 6, 10, 9 }
-- dirx = { -1, 1, 0, 0, -1, 1, 1, -1 }
-- diry = { 0, 0, -1, 1, -1, -1, 1, 1 }

function player_setup()
	p = {
		lvl = 1,
		curxp = 0,
		totalxp = 0,
		inv_f = 30, --invulnerability frames
		inv_c = 0, --inv count
		hp = 100,
		hpmax = 100,
		regen = .1,
		x = 60,
		y = 60,
		dx = 0,
		dy = 0,
		w = 8,
		h = 8,
		xspd = 1,
		yspd = 1,
		a = 1,
		drg = .8,
		spr = 16,
		ss = { 16, 17, 18, 19 },
		f = 0,
		animspd = 3,
		flipx = false,
		flipy = false,
		col = {},
		col_offset = {}
	}
	--player collision rect offsets
	p.col_offset = {
		x = 1,
		y = 2,
		h = -2,
		w = -3
	}
	--collision rect
	p.col = {
		x = p.x + p.col_offset.x,
		y = p.y + p.col_offset.y,
		h = p.h + p.col_offset.h,
		w = p.w + p.col_offset.w
	}
	-- trail fx colors
	tclrs = { 7, 11, -13 }
end

function draw_player()
	if not (p.inv_c / 2 % 2 < 1) then
		spr(0, p.x, p.y, 1, 1, p.flipx, p.flipy)
	else
		spr(p.spr, p.x, p.y, 1, 1, p.flipx, p.flipy)
	end
end

function draw_range()
	fillp(0x7fdf)
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange + 16, 2)
	fillp(0x7ada)
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange + 8, 2)
	fillp()
	circfill(p.x + flr(p.w / 2), p.y + flr(p.h / 2), hrange, 2)
end

function update_player()
	move_player()
	anim_player()
	--update player's collision rect coords
	u_col(p)
	--invulnerability counters
    p.inv_c = max(p.inv_c - 1, 0)
end

function anim_player()
	if is_moving(p) then
		p.f += 1
		p.flipx = p.dx < 0
		if p.f == p.animspd then
			p.f = 0
			p.spr += 1
			-- 4 is hardcoded, length of ss table
			if (p.spr > p.ss[4]) p.spr = p.ss[1]
		end
	else
		-- temp idle spr
		p.spr = 17
	end
	-- flip trail if player is flipped
	local xo = p.w
	if (p.flipx) xo += -7
	-- fire fx
	trail_fx(p.x + xo, p.y, tclrs, 1)
end

function move_player()
	-- bitmask to remove triple presses
	local btnm = btn() & 0b1111
	-- normalized diag coef
	local ndiag = 0.2
	-- left
	if (btnm == 1) then
		p.dx -= p.a
		p.dy = 0
		-- right
	elseif (btnm == 2) then
		p.dx += p.a
		p.dy = 0
		-- up
	elseif (btnm == 4) then
		p.dx = 0
		p.dy -= p.a
		-- down
	elseif (btnm == 8) then
		p.dx = 0
		p.dy += p.a
		-- left + up
	elseif (btnm == 5) then
		p.dx -= p.a * ndiag
		p.dy -= p.a * ndiag
		-- right + up
	elseif (btnm == 6) then
		p.dx += p.a * ndiag
		p.dy -= p.a * ndiag
		-- right + down
	elseif (btnm == 10) then
		p.dx += p.a * ndiag
		p.dy += p.a * ndiag
		-- left + down
	elseif (btnm == 9) then
		p.dx -= p.a * ndiag
		p.dy += p.a * ndiag
	else
		p.dx = 0
		p.dy = 0
	end
	p.dx = mid(-p.xspd, p.dx, p.xspd)
	p.dy = mid(-p.yspd, p.dy, p.yspd)

	wall_check(p)

	if can_move(p, p.dx, p.dy) then
		p.x += p.dx
		p.y += p.dy
	else
		tdx = p.dx
		tdy = p.dy
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

	if (abs(p.dx) > 0) p.dx *= p.drg
	if (abs(p.dy) > 0) p.dy *= p.drg
	if (abs(p.dx) < 0.02) p.dx = 0
	if (abs(p.dy) < 0.02) p.dy = 0
end

--player take damage
---d is dmg
---i is boolean for iframes
function p_take_damage(d, i)
	add_shake(3)
    local _d = d
    if _d < ceil(d * 0.4) then
        _d = ceil(d * 0.4)
    end
    p.hp = max(p.hp - max(1, d), 0)
    if (i) p.inv_c = p.inv_f
end