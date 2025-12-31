--items

items = {}
ixp = agent:new()

function drop_xp(pos, num)
    for i = 1, num do
        local xp = ixp:new({
            pos = pos,
            maxspd = mid(2, 1 + rnd(i), 3),
            maxfrc = max(.2, .5 - rnd()),
            behavior = "seek",
            frame = 1,
            tgl = false,
            tgt = vector(rnd(128), 0)
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
    if (self.frame == 15) self.tgt = vector(p.midx, p.midy)
    self:update_pos()
    if col(self.pos, vector(p.midx, p.midy), 6) then
        addxp(1)
        sfx(sfxt.ixp)
        del(items, self)
    end
end

function ixp:draw()
    if (self.frame % 5 == 0) self.tgl = not self.tgl
    if (self.tgl) circfill(self.pos.x, self.pos.y, 1, 11)
    pset(self.pos.x, self.pos.y, 7)
end