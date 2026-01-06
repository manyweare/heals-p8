--heals

--TODOS:
--chain heal
--player heal fx
--better heal "movement"

--range for non aura heals
base_hrange, hrange = 36, 36

-- heal class
heal = object:new()

function init_heals()
	--current heals in the queue
	heals = {}
	--heals color palette
	hclrs = split("9, 11, 10, 3")
	--eye orb glow lt
	orb_lt = 12

	--sub-classes
	--TODO: better names
	beam = heal:new({
		name = "beam",
		lvl = 1,
		pwr = 1,
		freq = 15,
		spd = 1,
		tmr = 0,
		range = hrange,
		clrs = hclrs,
		func = new_beam_heal
	})

	chain = heal:new({
		name = "chain",
		lvl = 1,
		pwr = 1,
		freq = 30,
		spd = 1,
		tmr = 0,
		num_chains = 3,
		range = round(hrange * 1.5),
		clrs = split("15, 10, 9, 7"),
		func = new_chain_heal
	})

	aoe = heal:new({
		name = "aura",
		lvl = 1,
		pwr = .25,
		freq = 30,
		spd = 1,
		tmr = 0,
		range = hrange,
		clrs = split("10, 3, 15"),
		func = new_aoe_heal
	})

	proj = heal:new({
		name = "bomb",
		lvl = 1,
		pwr = 3,
		freq = 60,
		spd = 2,
		tmr = 0,
		spr = 53,
		range = min(hrange * 2, 128),
		clrs = split("10, 3, 15"),
		hitrange = 16,
		func = new_proj_heal
	})

	-- player abilities
	all_heals = { beam, aoe, proj, chain }
	curr_heals = { beam }
end

function update_heals()
	update_h_timers()
	animate_heals()
end

-- updates timer and check ellapsed
-- if ellapsed, fire off a heal
function update_h_timers()
	for h in all(curr_heals) do
		h.tmr += 1
		if h.tmr == h.freq then
			h.tmr = 0
			h.func()
		end
	end
end

function new_beam_heal()
	-- must find a closest hurt entity
	local c = closest_hurt(p, entities)
	if not is_empty(c) and is_in_range(p, c, beam.range) then
		local h = beam:new({
			tgt = c,
			type = "beam",
			x = p.x,
			y = p.y,
			tx = c.x,
			ty = c.y,
			pwr = beam.pwr,
			lt = 12
		})
		add(heals, h)
		fire_heal(h)
		orb_glow()
	end
end

function new_chain_heal()
	local chains = {}
	--range is halved with every chain
	--so we start with it doubled
	local range = chain.range * 2
	--source starts with player and
	--changes from chain to chain
	local src = p
	local c = {}
	--create all heals in the chain
	for i = 1, chain.num_chains do
		c = closest_hurt(src, entities)
		if not is_empty(c) and is_in_range(src, c, max(16, range / 2)) then
			local h = chain:new({
				tgt = c,
				type = "chain",
				x = src.x,
				y = src.y,
				tx = c.x,
				ty = c.y,
				pwr = beam.pwr,
				lt = 12
			})
			add(chains, h)
			src = c
		end
	end
	--fire off heals added to chain
	--TODO: add delay between each jump?
	for h in all(chains) do
		add(heals, h)
		fire_heal(h)
		orb_glow()
	end
end

function new_aoe_heal()
	local t = all_hurt(entities)
	for e in all(t) do
		if is_in_range(p, e, aoe.range) then
			local h = aoe:new({
				tgt = e,
				type = "aoe",
				x = p.x,
				y = p.y,
				tx = e.x,
				ty = e.y,
				pwr = aoe.pwr,
				lt = 12
			})
			add(heals, h)
			fire_heal(h)
		end
	end
end

function new_proj_heal()
	-- must find hurt entity
	local t = all_hurt(entities)
	local r = rnd(t)
	if not is_empty(r) and is_in_range(p, r, proj.range) then
		local h = proj:new({
			tgt = r,
			type = "projectile",
			x = p.x,
			y = p.y,
			tx = r.x,
			ty = r.y,
			pwr = proj.pwr,
			spd = proj.spd,
			lt = 60
		})
		add(heals, h)
		orb_glow()
	end
end

function fire_heal(h)
	h.tgt:heal(h.pwr)
	heal_fx(h.tx, h.ty)
	if (h.type != "aoe") then
		sfx(sfxt.heal)
	end
end

function draw_heals()
	for i, h in pairs(heals) do
		-- eye orb glow for all but aoe
		if (h.type != "aoe") then d_orb_fx() end
		if (h.type == "beam") then
			d_beam_heal(h)
		elseif (h.type == "chain") then
			d_chain_heal(h)
		elseif (h.type == "projectile") then
			d_proj_heal(h)
		end
	end
	--out of for loop because it isn't drawn
	--when heals are fired, but constantly
	if (count(curr_heals, aoe) == 1) d_aoe_heal()
end

function animate_heals()
	for h in all(heals) do
		if h.type == "projectile" then
			--MAYBE: better projectile movement
			local dir = angle_move(h.x, h.y, h.tx, h.ty, h.spd)
			h.x += dir.x
			h.y += dir.y
			sync_pos(h)
			if col(h, vector(h.tx, h.ty), 2) then
				explode(h.x, h.y, h.hitrange, h.clrs, 1)
				sfx(sfxt.explode)
				local t = all_hurt(entities)
				for e in all(t) do
					if (is_in_range(h, e, h.hitrange)) fire_heal(h)
				end
				del(heals, h)
			end
		else
			--updates h pos in relation to player
			sync_pos(h)
			h.tx += psx
			h.ty += psy
		end
		h.lt -= 1
		--clear heal once lt over
		if (h.lt == 0) then del(heals, h) end
	end
end

--eye glow
function orb_glow()
	orb_lt = 12
end

function d_orb_fx()
	local eyex = p.x
	if (p.flipx) eyex -= 1
	if (orb_lt > 10) then
		circfill(eyex, p.y, 3, hclrs[2])
		circ(eyex, p.y, 2, hclrs[1])
	elseif (orb_lt > 6) then
		circfill(eyex, p.y, 1, hclrs[2])
	end
	orb_lt -= 1
end

function d_beam_heal(h)
	local c
	if (h.lt > 10) then
		c = h.clrs[1]
	elseif (h.lt > 3) then
		c = h.clrs[2]
	else
		c = h.clrs[3]
	end
	line(h.x, h.y, h.tx, h.ty, c)
end

function d_chain_heal(h)
	d_beam_heal(h)
end

function d_aoe_heal()
	aoe_fx(p.x, p.y, aoe.range, aoe.clrs)
end

function d_proj_heal(h)
	sync_pos(h)
	h.tx += psx
	h.ty += psy
	circfill(h.x, h.y, 2, 10)
	proj_fx(h.x, h.y)
end

function is_in_range(a, b, r)
	return approx_dist(a.x, a.y, b.x, b.y) < r
end

function is_hurt(e)
	return (e.hp > 0) and (e.hp < e.hpmax)
end

function closest_hurt(e, t)
	return find_closest(e, all_hurt(t))
end

function all_hurt(t)
	local ah = {}
	for e in all(t) do
		if (is_hurt(e)) add(ah, e)
	end
	return ah
end