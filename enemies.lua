function s_enemies()
	enemies = {}
	spawn_enemies(3)
end

function u_enemies()
	for e in all(enemies) do
		e.frame += 1
		move_to_plr(e)
		if e.frame > e.attspd - e.attspd / 3 then
			e.spr = e.ss[2]
			if (e.frame == e.attspd) e.frame = 0
		else
			e.spr = e.ss[1]
		end
	end
end

function d_enemies()
	for e in all(enemies) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
end

function spawn_enemies(i)
	for i = 1, i do
		e = {
			x = flr(rnd(120)),
			y = flr(rnd(120)) + hud.h,
			ss = { 64, 65 },
			spr = 64,
			hp = 10,
			att = 1,
			spd = 1,
			attspd = 30,
			frame = 1,
			flip = rnd() < .5
		}
		add(enemies, e)
	end
end