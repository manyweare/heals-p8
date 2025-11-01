-- heals
function heals_setup()
	heals = {}
	beam = {
		pwr = .5,
		freq = 15,
		spd = 1,
		range = 48,
		tmr = 0,
		clrs = { 11, 3, 15 },
		chains = 3
	}
	aoe = {
		pwr = .25,
		freq = 10,
		spd = 1,
		range = 24,
		tmr = 0,
		clrs = { 10, 3, 15 }
	}
	timers = {
		beam.tmr,
		aoe.tmr
	}
	hspr = 48
	hfreq = 15
	htimer = 0
	hspd = 1
	hrange = 48
	hchains = 3
	-- heals color palette
	hclr = { 9, 11, -13 }
	-- each heal {} has: x,y,tx,ty,pwr,lt
	-- pwr = heals power
	-- lt = heals anim lifetime
end

function update_heals()
	-- for the easing functions
	dt = t - lt
	lt = t
	te += dt
	-- htimer += 1
	beam.tmr += 1
	aoe.tmr += 1
	if beam.tmr == beam.freq then
		beam.tmr = 0
		beam_heals()
	end
	if aoe.tmr == aoe.freq then
		aoe.tmr = 0
		aoe_heals()
	end
	animate_heals()
end

function beam_heals()
	-- must find a closest hurt entity
	local c = closest_hurt(p, entities)
	if not is_empty(c) and is_in_range(c, beam.range) then
		queue_beam_heal(p, c)
		-- chain_heals(c)
	end
end

function queue_beam_heal(o, tgt)
	local h = {
		tgt = tgt,
		type = "beam",
		x = o.x + flr(o.w / 2),
		y = o.y + flr(o.h / 2),
		tx = tgt.x + flr(tgt.w / 2),
		ty = tgt.y + flr(tgt.h / 2),
		pwr = beam.pwr,
		lt = 12
	}
	fire_heal(h)
end

function aoe_heals()
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
			fire_heal(h)
		end
	end
end

function fire_heal(h)
	add(heals, h)
	heal_entity(h.tgt, h.pwr)
	heal_fx(h.tx, h.ty, hclr, 3)
	if (h.type != "aoe") sfx(sfxt.heal)
end

function heal_entity(e, hpwr)
	e.hp += hpwr
	if (e.hp > e.maxhp) e.hp = e.maxhp
	e.decay = 0
	e.frame = 0
end

-- TODO: fix the chaining
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
		-- TODO: animate different types of heals
		if (h.type == "beam") then
			-- staff orb glow
			d_orb(h)
			d_beam_heal(h)
		end
	end
	d_aoe_heal()
end

function animate_heals()
	for h in all(heals) do
		-- for projectile heals:
		--local pos = angle_move(h.x, h.y, h.tx, h.ty, hspd)
		--h.x += pos.x
		--h.y += pos.y
		--if (flr(h.x) == flr(h.tx)) or (flr(h.y) == flr(h.ty)) then
		--	del(heals, h)
		--end
		h.lt -= 1
		if (h.lt == 0) then del(heals, h) end
		-- updates p in relation to player
		h.x = p.x + flr(p.w / 2)
		h.y = p.y + flr(p.h / 2)
		-- places heal on tip of staff
		if not p.flipx then
			h.x += 3
		else
			h.x += -4
		end
		h.y += -4
	end
end

function d_orb(h)
	if (h.lt > 10) then
		circfill(h.x, h.y, 2, hclr[2])
		circ(h.x, h.y, 2, hclr[1])
	elseif (h.lt > 6) then
		circfill(h.x, h.y, 1, hclr[2])
	end
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
	local d = aoe.freq / 30
	local c = -2
	local x = p.x + flr(p.w / 2)
	local y = p.y + flr(p.h / 2)
	local r = ease_out_quad(te, aoe.range + c, -c, d)
	-- fillp(0x8124)
	-- circ(x, y, r, 15)
	-- fillp()
	if (te > d) then
		te = 0
		-- circ(x, y, hrange, 15)
	end
	aoe_fx(x, y, r, aoe.clrs)
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