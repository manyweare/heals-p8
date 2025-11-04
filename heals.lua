--heals

--TODOS:
--chain heal
--projectile heal

function init_heals()
	--current heals in the queue
	heals = {}
	-- each heal must have: x,y,tx,ty,pwr,lt
	--tx, ty = target x, y
	--pwr = heals power
	--lt = heals anim lifetime

	--base range for non aura heals
	hrange = 32
	--heals color palette
	hclrs = { 11, 10, 3, 15 }
	--staff orb glow lt
	orb_lt = 12

	curr_heals = {}

	--heal archetypes
	beam = {
		lvl = 1,
		pwr = .5,
		freq = 15,
		spd = 1,
		range = hrange,
		tmr = 0,
		clrs = hclrs,
		chains = 3
	}
	aoe = {
		lvl = 1,
		pwr = .25,
		freq = 20,
		spd = 1,
		range = hrange / 2,
		tmr = 0,
		clrs = { 10, 3, 15 }
	}
	proj = {
		lvl = 1,
		pwr = 1,
		freq = 30,
		spd = 2,
		range = min(hrange * 2, 128),
		tmr = 0,
		spr = 53
	}
end

function update_heals()
	update_h_timers()
	if beam.tmr == beam.freq then
		beam.tmr = 0
		new_beam_heal()
	end
	if aoe.tmr == aoe.freq then
		aoe.tmr = 0
		new_aoe_heal()
	end
	if proj.tmr == proj.freq then
		proj.tmr = 0
		new_proj_heal()
	end
	animate_heals()
end

function update_h_timers()
	beam.tmr += 1
	aoe.tmr += 1
	proj.tmr += 1
end

function new_beam_heal()
	--must find a closest hurt entity
	local c = closest_hurt(p, entities)
	if not is_empty(c) and is_in_range(c, beam.range) then
		local h = {
			tgt = c,
			type = "beam",
			x = p.x + flr(p.w / 2),
			y = p.y + flr(p.h / 2),
			tx = c.x + flr(c.w / 2),
			ty = c.y + flr(c.h / 2),
			pwr = beam.pwr,
			lt = 12
		}
		add(heals, h)
		fire_heal(h)
		orb_glow()
	end
end

function new_aoe_heal()
	local t = all_hurt(entities)
	for e in all(t) do
		if is_in_range(e, aoe.range) then
			local h = {
				tgt = e,
				type = "aoe",
				x = p.x + flr(p.w / 2),
				y = p.y + flr(p.h / 2),
				tx = e.x + flr(e.w / 2),
				ty = e.y + flr(e.h / 2),
				pwr = aoe.pwr,
				lt = 12
			}
			add(heals, h)
			fire_heal(h)
		end
	end
end

function new_proj_heal()
	--must find hurt entity
	local t = all_hurt(entities)
	local r = rnd(t)
	if not is_empty(r) and is_in_range(r, proj.range) then
		local h = {
			tgt = r,
			type = "projectile",
			x = p.x + p.w,
			y = p.y,
			tx = r.x + flr(r.w / 2),
			ty = r.y + flr(r.h / 2),
			pwr = proj.pwr,
			spd = proj.spd,
			lt = 60
		}
		add(heals, h)
		orb_glow()
	end
end

function fire_heal(h)
	e_heal(h.tgt, h.pwr)
	heal_fx(h.tx, h.ty)
	--play heal sfx unless aoe
	if (h.type != "aoe") sfx(sfxt.heal)
end

-- TODO: chain heal
-- going from player to all closest instead of chain
-- function chain_heals(c)
-- 	-- find all chainable entities
-- 	local cts = {}
-- 	for i = 1, hchains do
-- 		-- find closest to last target
-- 		local nc = closest_hurt(c, entities)
-- 		if not is_empty(nc) then
-- 			-- nc.dist = approx_dist(c, nc)
-- 			if (nc.dist < hrange) then
-- 				add(cts, nc)
-- 				c = nc
-- 			end
-- 		end
-- 	end
-- 	for i = 1, #cts - 1 do
-- 		fire_heals(cts[i], cts[i + 1])
-- 	end
-- end

function draw_heals()
	for h in all(heals) do
		-- staff orb glow for all but aoe
		if (h.type != "aoe") then d_orb_fx() end
		if (h.type == "beam") then
			d_beam_heal(h)
		elseif (h.type == "projectile") then
			d_proj_heal(h)
		end
	end
	d_aoe_heal()
end

function animate_heals()
	--for the easing functions
	dt = t - lt
	lt = t
	te += dt
	for h in all(heals) do
		if h.type == "projectile" then
			--TODO: ease in
			local pos = angle_move(h.x, h.y, h.tx, h.ty, h.spd)
			h.x += pos.x
			h.y += pos.y
			--replace with colision?
			local d = approx_dist(h.x, h.y, h.tx, h.ty)
			if d < 1 then
				fire_heal(h)
				explode(h.x, h.y, 3, { 7, 11, 15 }, 7)
				del(heals, h)
			end
		else
			-- updates h pos in relation to player
			h.x = p.x + flr(p.w / 2)
			h.y = p.y + flr(p.h / 2)
			-- places heal on tip of staff
			if not p.flipx then
				h.x += (p.w / 2) - 1
			else
				h.x -= p.w / 2
			end
			h.y -= p.h / 2
		end
		h.lt -= 1
		--clear heal once lt over
		if (h.lt == 0) then del(heals, h) end
	end
end

--orb glow on tip of staff
function orb_glow()
	orb_lt = 12
end

function d_orb_fx()
	local staffx, staffy
	if not p.flipx then
		staffx = p.x + p.w - 1
	else
		staffx = p.x
	end
	staffy = p.y - 1
	if (orb_lt > 10) then
		circfill(staffx, staffy, 2, hclrs[2])
		circ(staffx, staffy, 2, hclrs[1])
	elseif (orb_lt > 6) then
		circfill(staffx, staffy, 1, hclrs[2])
	end
	orb_lt -= 1
end

function d_beam_heal(h)
	if (h.lt > 10) then
		line(h.x, h.y, h.tx, h.ty, beam.clrs[1])
	elseif (h.lt > 3) then
		line(h.x, h.y, h.tx, h.ty, beam.clrs[2])
	else
		line(h.x, h.y, h.tx, h.ty, beam.clrs[3])
	end
end

function d_aoe_heal()
	local d = aoe.freq / 10
	local c = -3
	local x = p.x + flr(p.w / 2)
	local y = p.y + flr(p.h / 2)
	-- local r = ease_out_quad(te, aoe.range + c, -c, d)
	local r = aoe.range
	-- fillp(0x8124)
	-- circ(x, y, r, 15)
	-- fillp()
	if (te > d) then
		te = 0
		-- circ(x, y, hrange, 15)
	end
	aoe_fx(x, y, r, aoe.clrs)
end

function d_proj_heal(h)
	circfill(h.x, h.y, 2, 10)
	proj_fx(h.x, h.y)
end

function is_in_range(e, r)
	local d = approx_dist(p.x, p.y, e.x, e.y)
	return d < r
end

function is_hurt(e)
	return (e.hp > 0) and (e.hp < e.maxhp)
end

function closest_hurt(e, t)
	local ht = all_hurt(t)
	return find_closest(e, ht)
end

function all_hurt(t)
	local ah = {}
	for e in all(t) do
		if (is_hurt(e)) add(ah, e)
	end
	return ah
end