--items

items = {}
ixp = agent:new()

function drop_xp(pos, num)
    for i = 1, num do
        local x, y = pos.x, pos.y
        x = (x > 63) and x + rnd(16) + 8 or x - rnd(16) - 8
        y = (y > 63) and y + rnd(16) + 8 or y - rnd(16) - 8
        local xp = ixp:new({
            pos = pos,
            maxspd = mid(2, rnd(4), 4),
            maxfrc = mid(.25, rnd(), .75),
            behavior = "seek",
            frame = 1,
            tgl = false,
            tgt = vector(x, y)
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
    self.frame += 1
    if (self.frame == 10) self.tgt = vector(p.midx, p.midy)
    self:update_pos()
    if col(self.pos, vector(p.midx, p.midy), 6) then
        addxp()
        sfx(sfxt.ixp)
        del(items, self)
    end
end

function ixp:draw()
    -- if (self.frame % 5 == 0) self.tgl = not self.tgl
    -- if (self.tgl) pset(self.pos.x, self.pos.y, 11)
    circfill(self.pos.x, self.pos.y, 1, 0)
    pset(self.pos.x, self.pos.y, 9)
end