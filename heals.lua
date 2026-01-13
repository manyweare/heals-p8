--heals

--range for non aura heals
base_hrange, hrange = 36, 36

-- heal class
heal = object:new({ lvl = 1, lt = 12 })

function init_heals()
	--current heals in the queue
	heals = {}
	--heals color palette
	hclrs = split("9, 11, 10, 3")
	--eye orb glow lt
	cast_lt = 12
	--keep track of orb heals
	h_orbs, max_h_orbs = 0, 3

	--sub-classes

	-- BEAM --
	beam = heal:new({
		range = hrange,
		clrs = hclrs,
		func = new_beam_heal
	})
	quickset(
		beam,
		"type,name,pwr,freq,spd,tmr",
		"beam,beam,1,15,15,1"
	)

	-- CHAIN --
	chain = heal:new({
		range = round(hrange * 1.5),
		clrs = split("15, 10, 9, 7"),
		func = new_chain_heal
	})
	quickset(
		chain,
		"type,name,pwr,freq,tmr,spd,num_chains",
		"chain,chain,1,30,30,1,3"
	)

	-- AURA --
	aoe = heal:new({
		range = hrange,
		clrs = split("10, 3, 15"),
		func = new_aoe_heal
	})
	quickset(
		aoe,
		"type,name,pwr,freq,tmr,spd",
		"aoe,aura,.25,30,30,1"
	)

	-- BOMB --
	proj = heal:new({
		range = min(hrange * 2, 72),
		clrs = hclrs,
		func = new_proj_heal
	})
	quickset(
		proj,
		"type,name,pwr,freq,tmr,spd,spr,hitrange",
		"projectile,bomb,3,60,60,.5,53,20"
	)

	-- ORBS --
	orb = heal:new({
		range = min(hrange, 128) / 2,
		clrs = hclrs,
		func = new_orb_heal
	})
	quickset(
		orb,
		"type,name,pwr,freq,tmr,spd,hitrange,orb_index",
		"orb,orbs,2,90,90,.33,16,1"
	)

	-- player abilities
	all_heals = { beam, aoe, proj, chain, orb }
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
		if h.tmr >= h.freq then
			h.tmr = 0
			h.func()
		end
	end
end

function new_beam_heal()
	-- must find a closest hurt entity
	local c = closest_hurt(p, entities, spawning_es)
	if not is_empty(c) and is_in_range(p, c, beam.range) then
		local h = beam:new({
			tgt = c,
			x = p.x,
			y = p.y,
			tx = c.x,
			ty = c.y,
			pwr = beam.pwr
		})
		add(heals, h)
		fire_heal(h)
		cast_glow()
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
		c = closest_hurt(src, entities, spawning_es)
		if not is_empty(c) and is_in_range(src, c, max(16, range / 2)) then
			local h = chain:new({
				tgt = c,
				x = src.x,
				y = src.y,
				tx = c.x,
				ty = c.y,
				pwr = beam.pwr
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
		cast_glow()
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
				pwr = aoe.pwr
			})
			add(heals, h)
			fire_heal(h)
		end
	end
end

function new_proj_heal()
	-- must find hurt entity
	local t = all_hurt(entities, spawning_es)
	local r = rnd(t)
	if not is_empty(r) and is_in_range(p, r, proj.range) then
		local h = proj:new({
			tgt = r,
			x = p.x,
			y = p.y,
			tx = r.x,
			ty = r.y,
			pwr = proj.pwr,
			spd = proj.spd,
			lt = 60
		})
		add(heals, h)
		cast_glow()
	end
end

function new_orb_heal()
	if (h_orbs == max_h_orbs) return
	h_orbs += 1
	local h = orb:new({
		tgt = orb.range,
		x = p.x,
		y = p.y,
		pwr = orb.pwr,
		spd = orb.spd,
		lt = 600,
		orb_index = rnd(max_h_orbs) + 1
	})
	add(heals, h)
	cast_glow()
end

function fire_heal(h)
	h.tgt:heal(h.pwr)
	heal_fx(h.tx, h.ty)
	if (h.type != "aoe") then
		sfx(sfxt.heal)
	end
end

function burst_heal(h, t)
	t = t or all_hurt(entities)
	explode(h.x, h.y, h.hitrange, h.clrs, 1)
	sfx(sfxt.explode)
	for e in all(t) do
		if is_in_range(h, e, h.hitrange) then
			h.tgt, h.tx, h.ty = e, e.x, e.y
			fire_heal(h)
		end
	end
	del(heals, h)
end

function draw_heals()
	for i, h in pairs(heals) do
		-- eye orb glow for all but aoe
		if (h.type != "aoe") then d_cast_fx() end
		if h.type == "beam" then
			d_beam_heal(h)
		elseif h.type == "chain" then
			d_chain_heal(h)
		elseif h.type == "projectile" then
			d_proj_heal(h)
		elseif h.type == "orb" then
			d_orb_heal(h)
		end
	end
	--out of for loop because it isn't drawn
	--when heals are fired, but constantly
	if (count(curr_heals, aoe) == 1) d_aoe_heal()
end

function animate_heals()
	for h in all(heals) do
		if h.type == "projectile" then
			local dir = get_dir(h.x, h.y, h.tx, h.ty)
			local dx, dy = cos(dir), sin(dir)
			h.x += dx * h.spd
			h.y += dy * h.spd
			h.spd += .2
			if (col(h, vector(h.tx, h.ty), 4)) burst_heal(h)
		elseif h.type == "orb" then
			local d = h.orb_index / max_h_orbs
			h.x = p.x + (h.range + (h.orb_index * 2)) * cos(d * t() * h.spd)
			h.y = p.y + (h.range + (h.orb_index * 2)) * sin(d * t() * h.spd)
			local t = all_hurt(entities)
			for e in all(t) do
				if col(h, e, 8) then
					burst_heal(h)
					h_orbs -= 1
				end
			end
		else
			h.tx += psx
			h.ty += psy
		end
		--updates h pos in relation to player
		sync_pos(h)
		h.lt -= 1
		--clear heal once lt over
		if h.lt == 0 then
			del(heals, h)
			if (h.type == "orb") h_orbs -= 1
		end
	end
end

--eye cast glow
function cast_glow()
	cast_lt = 12
end

function d_cast_fx()
	local eyex = p.x
	if (p.flipx) eyex -= 1
	if (cast_lt > 10) then
		circfill(eyex, p.y, 3, hclrs[2])
		circ(eyex, p.y, 2, hclrs[1])
	elseif (cast_lt > 6) then
		circfill(eyex, p.y, 1, hclrs[2])
	end
	cast_lt -= 1
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
	circfill(h.x, h.y, 2, hclrs[1])
	proj_fx(h.x, h.y)
end

function d_orb_heal(h)
	sync_pos(h)
	circfill(h.x, h.y, 1, hclrs[1])
	orb_fx(h.x, h.y)
end