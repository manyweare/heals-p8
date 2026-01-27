--items

items = {}
ixp = agent:new({
	frame = 0,
	lt = 60,
	behavior = "seek",
	is_dormant = true
})

function drop_xp(pos, num)
	local i, xpval = 1, 1
	while i <= num do
		local x, y = pos.x, pos.y
		--set initial tgt pos away from player a random amount
		x = (x > 63) and x + rndf(4, 6) or x - rndf(4, 6)
		y = (y > 63) and y + rndf(4, 6) or y - rndf(4, 6)
		--find how many times num is divisible by an amount
		--to generate bigger xp orbs
		if i % 10 == 0 then
			xpval = 10
			i += 10
		elseif i % 5 == 0 then
			xpval = 5
			i += 5
		else
			xpval = 1
		end
		local xp = ixp:new({
			pos = pos,
			maxspd = rndf(2.5, 4.5),
			maxfrc = rndf(.25, .65),
			tgt = pos,
			val = xpval
		})
		add(items, xp)
		i += 1
	end
end

function update_items()
	for i, v in inext, items do
		v:update()
	end
end

function draw_items()
	for i, v in inext, items do
		v:draw()
	end
end

function ixp:update()
	local _ENV = self
	frame += 1
	sync_pos(pos)
	self:update_pos()
	--xp dropped and is on ground
	if is_dormant then
		--set a random pos to fly to
		local x, y = pos.x, pos.y
		x = (x > 63) and x + rndf(8, 12) or x - rnd(8, 12)
		y = (y > 63) and y + rndf(8, 12) or y - rnd(8, 12)
		tgt = vector(x, y)
		frame = 0
		is_dormant = false
	else
		--xp has flown for X frames, now change tgt to player
		if frame > 15 then
			tgt = vector(px, py)
		end
		--heading to player so check for collision again
		if col(pos, 2, p, p.r) then
			addxp(val)
			sfx(_G.sfxt.ixp)
			del(_G.items, self)
		end
	end
end

function ixp:draw()
	local _ENV = self
	circfill(pos.x, pos.y, 1, 1)
	if val == 10 then
		circfill(pos.x, pos.y, 2, 3)
		circfill(pos.x, pos.y, 1, 9)
	elseif val == 5 then
		circfill(pos.x, pos.y, 1, 9)
	else
		pset(pos.x, pos.y, 9)
	end
	-- trail_fx(pos.x, pos.y - 1)
	if (frame % 10 < 5) pset(pos.x, pos.y, 1, 7)
end