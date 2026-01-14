--heals

--range for non aura heals
base_hrange, hrange = 36, 36

-- heal class
heal = object:new({ lvl = 1, lt = 12, heal_sfx = 4 })

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
		src = p,
		func = new_beam_heal
	})
	quickset(
		beam,
		"type,name,pwr,freq,spd,tmr",
		"beam,beam,1,15,15,1"
	)

	-- CHAIN --
	chain = heal:new({
		range = hrange * 1.5,
		clrs = split("11, 10, 3, 15"),
		src = {},
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
		range = min(hrange, 128) / 10,
		clrs = hclrs,
		func = new_orb_heal
	})
	quickset(
		orb,
		"type,name,pwr,freq,tmr,spd,hitrange,orb_index,size",
		"orb,orbs,2,90,90,.33,16,1,1"
	)

	-- player abilities
	all_heals = { beam, aoe, proj, chain, orb }
	curr_heals = { chain }
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
			x = px,
			y = py,
			tx = c.x,
			ty = c.y,
			pwr = beam.pwr
		})
		add(heals, h)
		h:fire_heal()
		cast_glow()
	end
end

function new_chain_heal()
	local range, pwr = chain.range, chain.pwr
	--source starts with player and changes from chain to chain
	local _src, _tgt, chains = p, {}, {}
	--table to hold subset of entities minus last heal target
	local _entities = cat(entities, spawning_es)
	--create all heals in the chain
	for i = 1, chain.num_chains do
		_tgt = closest_hurt(_src, _entities)
		if not is_empty(_tgt) and is_in_range(_src, _tgt, max(16, range)) then
			local h = chain:new({
				src = _src,
				tgt = _tgt,
				x = _src.x,
				y = _src.y,
				tx = _tgt.x,
				ty = _tgt.y,
				pwr = pwr
			})
			add(chains, h)
			del(_entities, _tgt)
			_src = _tgt
			--range reduced with each jump
			range *= .75
			pwr /= 2
		end
	end
	--fire off heals added to chain
	--TODO: add delay between each jump?
	for h in all(chains) do
		add(heals, h)
		h:fire_heal()
	end
	if (not is_empty(chain)) cast_glow()
end

function new_aoe_heal()
	local t = all_hurt(entities)
	for e in all(t) do
		if is_in_range(p, e, aoe.range) then
			local h = aoe:new({
				tgt = e,
				type = "aoe",
				x = px,
				y = py,
				tx = e.x,
				ty = e.y,
				pwr = aoe.pwr
			})
			add(heals, h)
			h:fire_heal()
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
			x = px,
			y = py,
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
		x = px,
		y = py,
		pwr = orb.pwr,
		spd = orb.spd,
		lt = 600,
		orb_index = rnd(max_h_orbs) + 1
	})
	add(heals, h)
	cast_glow()
end

function heal:fire_heal()
	local _ENV = self
	tgt:heal(pwr)
	heal_fx(tx, ty)
	if (type != "aoe") then
		sfx(heal_sfx)
	end
end

function heal:burst_heal(t)
	local _ENV = self
	t = t or all_hurt(entities)
	explode(x, y, hitrange, clrs, 1)
	sfx(sfxt.explode)
	for e in all(t) do
		if is_in_range(self, e, hitrange) then
			tgt, tx, ty = e, e.x, e.y
			self:fire_heal()
		end
	end
	del(heals, self)
end

function draw_heals()
	for i, h in pairs(heals) do
		-- eye orb glow for all but aoe
		if (h.type != "aoe") then d_cast_fx() end
		if h.type == "beam" then
			h:d_beam_heal()
		elseif h.type == "chain" then
			h:d_chain_heal()
		elseif h.type == "projectile" then
			h:d_proj_heal()
		elseif h.type == "orb" then
			h:d_orb_heal()
		end
	end
	--out of for loop because it isn't drawn
	--when heals are fired, but constantly
	if (count(curr_heals, aoe) == 1) d_aoe_heal()
end

function animate_heals()
	for h in all(heals) do
		h:animate()
	end
end

function heal:animate()
	local _ENV = self
	if type == "projectile" then
		local dir = get_dir(x, y, tx, ty)
		local dx, dy = cos(dir), sin(dir)
		x += dx * spd
		y += dy * spd
		spd += .2
		if (col(self, vector(tx, ty), 4)) self:burst_heal()
	elseif type == "orb" then
		local d = orb_index / _G.max_h_orbs
		x = px + (range + (orb_index * 2)) * cos(d * t() * spd)
		y = py + (range + (orb_index * 2)) * sin(d * t() * spd)
		range = min(hrange, range + .05)
		size = min(2, size + .001)
		local t = all_hurt(_G.entities)
		for e in all(t) do
			if col(self, e, 8) then
				self:burst_heal()
				_G.h_orbs -= 1
			end
		end
	end
	lt -= 1
	if lt < 0 then
		if type == "orb" then
			_G.h_orbs -= 1
		end
		del(_G.heals, self)
	end
end

--eye cast glow
function cast_glow()
	cast_lt = 12
end

function d_cast_fx()
	local eyex = px
	if (p.flipx) eyex -= 1
	if (cast_lt > 10) then
		circfill(eyex, py, 3, _G.hclrs[2])
		circ(eyex, py, 2, hclrs[1])
	elseif (cast_lt > 6) then
		circfill(eyex, py, 1, _G.hclrs[2])
	end
	cast_lt -= 1
end

function heal:d_beam_heal()
	local _ENV, clr = self, 15
	if (lt > 10) then
		clr = clrs[1]
	elseif (lt > 3) then
		clr = clrs[2]
	else
		clr = clrs[3]
	end
	line(src.x, src.y, tgt.x, tgt.y, clr)
end

function heal:d_chain_heal()
	self:d_beam_heal()
end

function d_aoe_heal()
	aoe_fx(px, py, aoe.range, aoe.clrs)
end

function heal:d_proj_heal()
	local _ENV = self
	sync_screen_pos(x, y)
	sync_screen_pos(tx, ty)
	circfill(x, y, 2, _G.hclrs[1])
	proj_fx(x, y)
end

function heal:d_orb_heal(h)
	local _ENV = self
	sync_pos(self)
	circfill(x, y, size, _G.hclrs[1])
	orb_fx(x, y)
end