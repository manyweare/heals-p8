--player

--screen-based coords
--used for scrolling map
psx, psy = 0, 0

-- player class
player = object:new()

p = player:new({
	ss = split("16, 17, 18, 19"),
	col = {},
	tentacles = {}
})
quickset(
	p,
	"lvl,curxp,totalxp,inv_f,inv_c,hp,hpmax,regen,regen_spd,x,y,dx,dy,w,h,spd,maxspd,spr,f,animspd,flipx,flipy",
	"1,0,0,30,0,10,10,.5,1,59,59,0,0,8,8,1,1,16,0,5,false,false"
)

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
	--create_tentacles(n, sx, sy, r1, r2, l, c)
	p.tentacles = create_tentacles(12, 59, 59, 2.2, 1, 10, split("7, 7, 7, 9"))
	--trail fx colors
	tclrs = { 7, 11, -13 }
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
	get_direction()
	set_direction()
	-- p:update_col()
	-- p:update_mid()
	update_tentacles(p)
	anim_player()
	--invulnerability counter
	p.inv_c = max(p.inv_c - 1, 0)
	--regen
	if time() % p.regen_spd <= .02 then
		p.hp = min(p.hp + p.regen, p.hpmax)
	end
end

function get_direction()
	p.dx = p_i_data[1] - p_i_data[2]
	p.dy = p_i_data[3] - p_i_data[4]
end

function set_direction()
	--get input and determine
	--direction
	psx, psy = p.dx, p.dy
	--set speed of each
	if abs(p.x) == abs(p.y) then
		psx *= p.spd * 0.7
		psy *= p.spd * 0.7
	else
		psx *= p.spd
		psy *= p.spd
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
	local r = hrange + 18
	--inverted draw, visibility range
	poke(0x5f34, 0x2)
	circfill(p.midx, p.midy, r, 0 | 0x1800)
end