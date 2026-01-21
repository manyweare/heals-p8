--player

--init input tables
input_last, inputs, input_data, wasd = {}, {}, {}, split("4,7,26,22,0,40")
--perennial player position and pscreenx position change
px, py, psx, psy, pspd = 63, 63, 0, 0, 1
--player stats
plvl, curxp, totalxp = 1, 0, 0

-- player class
p = class:new()

function init_player()
	quickset(
		p,
		"x,y,dx,dy,r,hp,hpmax,inv_f,inv_c,regen,regenspd,sprite,ss,frame,animspd,flipx,flipy",
		"63,63,0,0,6,1,5,30,0,.5,15,16,{16|17},0,5,false,false"
	)
	--create_tentacles(n, sx, sy, r1, r2, l, c)
	p.tentacles = create_tentacles(8, 63, 63, 2.2, 1, 7, split("7, 7, 7, 9"))
end

function update_player()
	get_inputs()
	get_direction()
	set_direction()
	p:anim()
	p:update()
end

function draw_player()
	p:draw()
end

function p:update()
	local _ENV = self
	--invulnerability counter
	inv_c = max(inv_c - 1, 0)
	--collision dmg
	if inv_c < 1 then
		local ce = find_closest(self, _G.enemies, 16)
		if not is_empty(ce) then
			--collision dmg is half of normal dmg
			if (col(p, r, ce, ce.r)) self:take_dmg(ce.dmg / 2, true)
		end
	end
	--regen
	if (playtime % regenspd == 0) hp = min(hp + regen, hpmax)
	update_tentacles(self)
end

function p:draw()
	local _ENV = self
	draw_tentacles(tentacles, split("7, 7, 7, 9"))
	if not (inv_c / 2 % 2 < 1) then
		spr(1, 59, 59, 1, 1, flipx, flipy)
	else
		spr(sprite, 59, 59, 1, 1, flipx, flipy)
	end
end

-- from Beckon the Hellspawn
-- TODO: add author
function get_inputs()
	--register last inputs
	for x = 1, 8 do
		input_last[x] = inputs[x]
	end
	--register current inputs
	for x = 1, 6 do
		inputs[x] = btn(x - 1) or stat(28, _G.wasd[x])
	end
	--assign direction values
	for x = 1, 4 do
		if inputs[x] then
			input_data[x] = 1
		else
			input_data[x] = 0
		end
	end
end

function get_direction()
	p.dx = input_data[1] - input_data[2]
	p.dy = input_data[3] - input_data[4]
end

function set_direction()
	--get input and determine direction
	psx, psy = p.dx, p.dy
	--set speed of each
	if abs(x) == abs(y) then
		psx *= pspd * 0.7
		psy *= pspd * 0.7
	else
		psx *= pspd
		psy *= pspd
	end
end

function p:anim()
	local _ENV = self
	frame += 1
	flipx, flipy = dx > 0, dy > 0
	if frame == animspd then
		frame = 0
		--blink randomly
		if rnd() > .15 then
			sprite = ss[2]
		else
			sprite = ss[1]
		end
	end
end

--player take damage
--d is dmg
--i is boolean for iframes
function p:take_dmg(d, i)
	local _ENV = self
	add_shake(5)
	-- local _d = d
	-- if _d < ceil(d * 0.4) then
	-- 	_d = ceil(d * 0.4)
	-- end
	hp = max(0, hp - d)
	if (i) inv_c = inv_f
	if (hp <= 0) game_over()
end

--draws circle around player
function draw_range()
	-- inverted draw, visibility range
	fillp(0x5f5f)
	for i = 12, 64 - hrange do
		circ(63, 63, hrange + i, 0)
	end
	fillp()
	-- circ(62, 63, hrange, 2)
	-- circ(63, 62, hrange, 2)
	-- circ(63, 63, hrange, 2)
	poke(0x5f34, 0x2)
	circfill(63, 63, 64, 0 | 0x1800)
end