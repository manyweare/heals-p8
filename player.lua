--player

--TODO:
--use quickset to save tokens
--tentacles -DONE

-- player class
player = object:new()

p = player:new({
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
	sx = 0,
	sy = 0,
	dx = 0,
	dy = 0,
	w = 8,
	h = 8,
	spd = 1,
	maxspd = 1,
	spr = 16,
	ss = split("16, 17, 18, 19"),
	f = 0,
	animspd = 5,
	flipx = false,
	flipy = false,
	col = {},
	tentacles = {}
})

function init_player()
	p.midx = p.x + p.w / 2
	p.midy = p.y + p.h / 2
	--player collision rect offsets
	p.col_offset = split("1, 2, -3, -2")
	--collision rect
	p.col = {
		x = p.x + p.col_offset[1],
		y = p.y + p.col_offset[2],
		w = p.w + p.col_offset[3],
		h = p.h + p.col_offset[4]
	}
	--trail fx colors
	tclrs = { 7, 11, -13 }
	-- function create_tentacles(n, start, r1, r2, l, s, c)
	p.tentacles = create_tentacles(
		12,
		vector(63, 63),
		2, 1, 16, 12,
		split("7, 7, 7, 9")
	)
end

function draw_player()
	draw_tentacles(p.tentacles)
	if not (p.inv_c / 2 % 2 < 1) then
		spr(1, p.x, p.y, 1, 1, p.flipx, p.flipy)
	else
		spr(p.spr, p.x, p.y, 1, 1, p.flipx, p.flipy)
	end
end

function update_player()
	-- move_player()
	get_direction()
	set_direction()
	anim_player()
	--update player's collision rect coords
	p:update_col()
	--invulnerability counters
	p.inv_c = max(p.inv_c - 1, 0)
	--regen
	if time() % p.regen_spd <= .02 then
		p.hp = min(p.hp + p.regen, p.hpmax)
	end
	--tentacles
	for t in all(p.tentacles) do
		local r = 12
		sync_pos(t.epos)
		if approx_dist(t.epos.x, t.epos.y, 63, 63) > r + 1 then
			t.epos = rand_in_circle(63, 63, r)
		end
	end
end

function get_direction()
	p.dx = p_i_data[1] - p_i_data[2]
	p.dy = p_i_data[3] - p_i_data[4]
end

function set_direction()
	--get input and determine
	--direction
	p.sx, p.sy = p.dx, p.dy
	--set speed of each
	if abs(p.x) == abs(p.y) then
		p.sx *= p.spd * 0.7
		p.sy *= p.spd * 0.7
	else
		p.sx *= p.spd
		p.sy *= p.spd
	end
end

function anim_player()
	if is_moving(p) then
		p.f += 1
		p.flipx = p.dx > 0
		if p.f == p.animspd then
			p.f = 0
			p.spr += 1
			if (p.spr > p.ss[#p.ss]) p.spr = p.ss[1]
		end
	else
		--idle spr
		p.spr = 17
	end
	--flip trail if player is flipped
	local xo = p.midx
	if (p.flipx) xo -= 1
	trail_fx(xo, p.midy, tclrs, 1)
end

--player take damage
--d is dmg
--i is boolean for iframes
function p:take_dmg(d, i)
	add_shake(3)
	local _d = d
	if _d < ceil(d * 0.4) then
		_d = ceil(d * 0.4)
	end
	self.hp = max(self.hp - max(1, d), 0)
	if (i) self.inv_c = self.inv_f
	if (self.hp <= 0) game_over()
end

function player_col(e)
	if p.inv_c < 1 then
		if col(p, e, 4) then
			add_shake(8)
			p:take_dmg(e.dmg, true)
			return true
		end
	end
	return false
end

--draws circle around player
function draw_range()
	local r = hrange + 16
	--inverted draw
	poke(0x5f34, 0x2)
	-- fillp(0x7fdf)
	-- circfill(p.midx, p.midy, r + rnd(2), 2 | 0x1800)
	-- fillp(0x7ada)
	-- circfill(p.midx, p.midy, r + 12 + rnd(2), 2 | 0x1800)
	-- fillp()
	circfill(p.midx, p.midy, r, 0 | 0x1800)
	-- fillp()
end