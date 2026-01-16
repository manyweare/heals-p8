--heals

--range for non aura heals
base_hrange, hrange = 36, 36

-- heal class
heal = object:new()
quickset(heal, "lvl,lt,tmr,clrs,heal_sfx", "1,8,0,{9|11|10|3},4")

-- sub-classes --

-- BEAM --
beam = heal:new({
	range = hrange,
	src = p,
	new_heal = function() new_beam_heal() end,
	draw = function(self) self:d_beam_heal() end
})
quickset(beam, "type,name,pwr,freq", "beam,beam,1,15")

-- CHAIN --
chain = heal:new({
	range = hrange * 2,
	new_heal = function() new_chain_heal() end,
	draw = function(self) self:d_chain_heal() end
})
quickset(chain, "type,name,pwr,freq,src,num_chains,lt", "chain,chain,1.5,45,{},3,20")

-- AURA --
aoe = heal:new({
	range = hrange,
	new_heal = function() new_aoe_heal() end
})
quickset(aoe, "type,name,pwr,freq,clrs", "aoe,aura,.25,30,{10|3|15}")

-- BOMB --
proj = heal:new({
	range = min(hrange * 1.5, 86),
	new_heal = function() new_proj_heal() end,
	draw = function(self) self:d_proj_heal() end
})
quickset(proj, "type,name,pwr,freq,spd,spr,lt,range,burst_range", "projectile,bomb,3,90,.2,53,90,128,24")

-- ORBS --
orb = heal:new({
	range = min(hrange, 128) / 10,
	new_heal = function() new_orb_heal() end,
	draw = function(self) self:d_orb_heal() end
})
quickset(orb, "type,name,pwr,freq,spd,lt,burst_range,orb_index,size", "orb,orbs,2,90,.33,600,16,1,1")

function init_heals()
	-- player abilities
	all_heals = { beam, aoe, proj, chain, orb }
	curr_heals = { chain }

	--current heals in the queue
	heals = {}

	--eye orb glow lt
	cast_lt = 12
	--orb heals
	h_orbs, max_h_orbs = 0, 3
end

function update_heals()
	-- update timer and check ellapsed
	-- if ellapsed, fire off a heal
	for h in all(curr_heals) do
		h.tmr += 1
		if h.tmr >= h.freq then
			h.tmr = 0
			h.new_heal()
		end
	end
	for h in all(heals) do
		h:animate()
	end
end

function draw_heals()
	for i, h in pairs(heals) do
		if (h.type != "aoe") then
			d_cast_fx()
			h:draw()
		end
	end
	--out of for loop because it isn't drawn
	--when heals are fired, but constantly
	if (count(curr_heals, aoe) == 1) aoe_fx(px, py, aoe.range, aoe.clrs)
end

function new_beam_heal()
	-- must find a closest hurt entity
	local c = closest_hurt(p, entities)
	if not is_empty(c) and is_in_range(p, c, beam.range) then
		local h = beam:new({
			tgt = c,
			x = px,
			y = py,
			tx = c.x,
			ty = c.y,
			pwr = beam.pwr,
			tmr = beam.freq
		})
		add(heals, h)
		h:fire_heal()
		cast_glow()
	end
end

function new_chain_heal()
	local range, pwr = chain.range, chain.pwr
	--source starts with player, changes chain to chain
	local _src, _tgt, chains = p, {}, {}
	--subset of entities minus last heal target
	local _entities = cat(_entities, entities)
	--create all heals in the chain
	for i = 1, chain.num_chains do
		_tgt = closest_hurt(_src, entities)
		if not is_empty(_tgt) and is_in_range(_src, _tgt, max(16, range)) then
			local h = chain:new({
				src = _src,
				tgt = _tgt,
				x = _src.x,
				y = _src.y,
				tx = _tgt.x,
				ty = _tgt.y,
				pwr = pwr,
				tmr = beam.freq
			})
			add(chains, h)
			del(_entities, _tgt)
			_src = _tgt
			--range and power reduced with each jump
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
				pwr = aoe.pwr,
				tmr = beam.freq
			})
			add(heals, h)
			h:fire_heal()
		end
	end
end

function new_proj_heal()
	--fires at most hurt entity or random if none found
	local _tgt = most_hurt(entities, spawning_es)
	if is_empty(_tgt) then
		local _t = cat(entities, spawning_es)
		_tgt = rnd(_t)
	end
	if not is_empty(_tgt) and is_in_range(p, _tgt, proj.range) then
		local h = proj:new({
			tgt = _tgt,
			x = px,
			y = py,
			tx = _tgt.x,
			ty = _tgt.y,
			pwr = proj.pwr,
			spd = proj.spd,
			tmr = proj.freq
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
		orb_index = rnd(max_h_orbs) + 1,
		tmr = orb.freq
	})
	add(heals, h)
	cast_glow()
end

function heal:fire_heal()
	local _ENV = self
	tgt:heal(pwr)
	heal_fx(tx, ty)
	if (type != "aoe") sfx(heal_sfx)
end

function heal:burst_heal(t)
	local _ENV = self
	t = t or all_hurt(entities)
	explode(x, y, burst_range, clrs, 1)
	sfx(sfxt.explode)
	for e in all(t) do
		if is_in_range(self, e, burst_range) then
			tgt, tx, ty = e, e.x, e.y
			self:fire_heal()
		end
	end
	del(heals, self)
end

function heal:animate()
	local _ENV = self
	if type == "projectile" then
		local dir = get_dir(x, y, tx, ty)
		local dx, dy = cos(dir), sin(dir)
		x += dx * spd
		y += dy * spd
		spd *= 1.05
		tx += psx
		ty += psy
		if (col(self, vector(tx, ty), 4)) self:burst_heal()
	elseif type == "orb" then
		local d = orb_index / max_h_orbs
		x = px + (range + (orb_index * 2)) * cos(d * t() * spd)
		y = py + (range + (orb_index * 2)) * sin(d * t() * spd)
		range = min(hrange, range + .05)
		size = min(2, size + .001)
		local t = all_hurt(entities)
		for e in all(t) do
			if col(self, e, 8) then
				self:burst_heal(t)
				h_orbs -= 1
			end
		end
	end
	lt -= 1
	if lt < 0 then
		del(heals, self)
		if (type == "orb") h_orbs -= 1
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
		circ(eyex, py, 4, heal.clrs[2])
		circ(eyex, py, 2, heal.clrs[1])
	elseif (cast_lt > 6) then
		circfill(eyex, py, 1, heal.clrs[2])
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
	local _ENV = self
	-- self:d_beam_heal()
	local start, target = src, tgt
	local seg = { x0 = src.x, y0 = src.y, x1 = 0, y1 = 0 }
	local clr, segs = 15, 4
	for i = 1, segs do
		seg.x1 = start.x + ((target.x - start.x) * (i / segs)) + rnd(2) - 1
		seg.y1 = start.y + ((target.y - start.y) * (i / segs)) + rnd(2) - 1
		seg.x0, seg.y0 = start.x, start.y
		-- add(points, seg)
		if (lt > 10) then
			clr = clrs[2]
		elseif (lt > 3) then
			clr = clrs[3]
		else
			clr = clrs[4]
		end
		line(seg.x0, seg.y0, seg.x1, seg.y1, clr)
		start = vector(seg.x1, seg.y1)
	end
end

function heal:d_proj_heal()
	local _ENV = self
	sync_pos(self)
	circfill(x, y, 2, clrs[1])
	proj_fx(x, y)
end

function heal:d_orb_heal(h)
	local _ENV = self
	sync_pos(self)
	circfill(x, y, size, clrs[1])
	orb_fx(x, y)
end