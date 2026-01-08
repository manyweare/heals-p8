--player

--screen-based coords
--used for scrolling map
psx, psy = 0, 0
px, py = 63, 63

-- player class
player = object:new()

p = player:new({
	ss = split("16, 17, 18, 19"),
	tentacles = {}
})
quickset(
	p,
	"lvl,curxp,totalxp,inv_f,inv_c,hp,hpmax,regen,regen_spd,x,y,dx,dy,w,h,spd,maxspd,spr,frame,animspd,flipx,flipy",
	"1,0,0,30,0,1,5,.5,30,63,63,0,0,8,8,1,1,16,0,5,false,false"
)

function init_player()
	--create_tentacles(n, sx, sy, r1, r2, l, c)
	p.tentacles = create_tentacles(8, 63, 63, 2.2, 1, 7, split("7, 7, 7, 9"))
end

function update_player()
	get_direction()
	set_direction()
	anim_player()
	update_tentacles(p)
	--invulnerability counter
	p.inv_c = max(p.inv_c - 1, 0)
	--regen
	if playtime % p.regen_spd == 0 then
		p.hp = min(p.hp + p.regen, p.hpmax)
	end
end

function draw_player()
	draw_tentacles(p.tentacles, split("7, 7, 7, 9"))
	if not (p.inv_c / 2 % 2 < 1) then
		spr(1, p.x - 4, p.y - 4, 1, 1, p.flipx, p.flipy)
	else
		spr(p.spr, p.x - 4, p.y - 4, 1, 1, p.flipx, p.flipy)
	end
end

function player:update()
end

function get_direction()
	p.dx = p_i_data[1] - p_i_data[2]
	p.dy = p_i_data[3] - p_i_data[4]
end

function set_direction()
	--get input and determine direction
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
		p.frame += 1
		p.flipx = p.dx > 0
		p.flipy = p.dy > 0
		if p.frame == p.animspd then
			p.frame = 0
			--randomize blinking speed
			if p.spr == p.ss[1] then
				p.spr += 1
			else
				p.spr += round(rnd())
			end
			if (p.spr > p.ss[#p.ss]) p.spr = p.ss[1]
		end
	else
		p.spr = 17
	end
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
	--inverted draw, visibility range
	poke(0x5f34, 0x2)
	circfill(p.x, p.y, hrange + 24, 0 | 0x1800)
end