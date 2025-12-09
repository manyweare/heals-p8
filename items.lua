--items

items = {}
ixp = agent:new()

function drop_xp(pos, val)
    local i = ixp:new({
        pos = pos,
        maxspd = 2,
        maxfrc = .25,
        behavior = "seek",
        val = val
    })
    add(items, i)
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
    self:update_pos()
    if (col(self.pos, vector(p.midx, p.midy), 6)) del(items, self)
end

function ixp:draw()
    circfill(self.pos.x, self.pos.y, 1, 7)
    pset(self.pos.x, self.pos.y, 11)
end