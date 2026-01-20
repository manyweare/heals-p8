--items

items = {}
ixp = agent:new({
	frame = 0,
	lt = 240,
	behavior = "seek",
	state = "dormant"
})

function drop_xp(pos, num)
	for i = 1, num do
		local x, y = pos.x, pos.y
		x = (x > 63) and x + rnd(2) + 4 or x - rnd(2) - 4
		y = (y > 63) and y + rnd(2) + 4 or y - rnd(2) - 4
		local xp = ixp:new({
			pos = pos,
			maxspd = 2.5 + rnd(2),
			maxfrc = mid(.25, rnd(), .65),
			tgt = pos
		})
		add(items, xp)
	end
end

function update_items()
	for i in all(items) do
		i:update()
	end
end

function draw_items()
	for i in all(items) do
		i:draw()
	end
end

function ixp:update()
	local _ENV = self
	frame += 1
	sync_pos(pos)
	--xp dropped and is on ground
	if state == "dormant" then
		--check for col with player while on ground
		if col(pos, 10, p, pr) then
			--player picked up xp so set a random pos to fly to
			local x, y = pos.x, pos.y
			x = (x > 63) and x + rnd(4) + 8 or x - rnd(4) - 8
			y = (y > 63) and y + rnd(8) + 8 or y - rnd(8) - 8
			tgt = vector(x, y)
			state = "pickedup"
			frame = 0
		end
		--xp despawns after some time
		if (frame >= lt) del(_G.items, self)
	else
		--xp was pickedup and not dormant
		self:update_pos()
		--xp has flown for X frames, now change tgt to player
		if state == "pickedup" and (frame == 15) then
			tgt = vector(px, py)
			state = "playerbound"
			--heading to player so check for collision again
		elseif state == "playerbound" and col(pos, 2, p, pr) then
			addxp()
			sfx(_G.sfxt.ixp)
			del(_G.items, self)
		end
	end
end

function ixp:draw()
	local _ENV = self
	circfill(pos.x, pos.y, 1, 1)
	pset(pos.x, pos.y, 7)
	if state == "dormant" then
		trail_fx(pos.x, pos.y - 1)
		--blink 2s before despawn
		if frame > lt - 60 then
			if (frame % 10 < 5) circfill(pos.x, pos.y, 1, 7)
		end
	end
end