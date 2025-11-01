--enemies

--TODO:
--use quickset to save tokens
--enemy state machine:
--enemies look for healthy entity in range -DONE
--enemies move to and attack it -DONE
--when entity dies, resume looking -DONE
--if none, attack player -DONE
--if dead, anim dead -DONE

function s_enemies()
	en_spw_tmr = 0
	enemies = {}
	dead_enemies = {}
	spawn_enemies(3)
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
			hp = 5,
			dmg = 1,
			spd = .25,
			tgt = {},
			attspd = 30,
			attframe = 1,
			animspd = 30,
			hit = false,
			frame = 1, --current frame
			flip = false, --flip sprite
			col = {},
			att_sfx = 5,
			state = "alive"
		}
		--collision rect offsets relative to e
		e.col_offset = { 1, 1, -2, -3 }
		--collision rect
		e.col = {
			x = e.x + e.col_offset[1],
			y = e.y + e.col_offset[2],
			w = e.w + e.col_offset[3],
			h = e.h + e.col_offset[4]
		}
		add(enemies, e)
	end
end

function u_enemies()
	en_spw_tmr += 1
	if (en_spw_tmr % 60 == 0) then
		en_spw_tmr = 0
		spawn_enemies(0 + flr(rnd(2)))
	end
	for e in all(enemies) do
		u_col(e)
		local tgt = p
		--if there are entities ready
		--find closest, make it the target
		if not is_empty(entities) then
			tgt = find_closest(e, entities)
			move_to(e, tgt)
			e.flip = flip_spr(e, tgt)
		else
			move_to_plr(e)
			e.flip = flip_spr(e, p)
		end
		if rect_rect_collision(e.col, tgt.col) then
			e.frame = 0
			e_attack(e, tgt)
		else
			e.attframe = 0
			e_anim(e)
		end
	end
	move_apart(enemies, 8)
end

function d_enemies()
	for e in all(enemies) do
		spr(e.spr, e.x, e.y, 1, 1, e.flip)
	end
	for e in all(dead_enemies) do
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

function take_dmg(e, dmg)
	e.hit = true
	e.hp -= dmg
	if (e.hp <= 0) kill_enemy(e)
end

function e_attack(e, tgt)
	if e.attframe < e.attspd / 2 then
		if (e.attframe == 1) then
			sfx(e.att_sfx, 2)
			if tgt == p then
				p_take_damage(e.dmg, true)
			else
				e_take_dmg(tgt, e.dmg)
			end
		end
		e.spr = e.ss[3]
	elseif e.attframe == e.attspd then
		e.attframe = 0
	else
		e.spr = e.ss[4]
	end
	e.attframe += 1
end

function kill_enemy(e)
	e.frame = 0
	e.spr = 68
	e.state = "dead"
	add(dead_enemies, e)
	del(enemies, e)
	sfx(sfxt.enemy_dead, 2)
end