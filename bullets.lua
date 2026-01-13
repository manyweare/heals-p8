--bullets

bullets = {}
bullet = object:new({
    x = 0,
    y = 0,
    ix = 0,
    iy = 0,
    tx = 0,
    ty = 0,
    r = 4,
    spd = 1,
    frame = 1,
    lifetime = 150,
    tgl = false,
    friendly = false
})

function update_bullets()
    for b in all(bullets) do
        b:update()
    end
end

function draw_bullets()
    for b in all(bullets) do
        b:draw()
    end
end

function bullet:update()
    self.frame += 1
    --caching for token saving
    local tgtm = self.tgt
    --enemies move as player moves for scrolling map
    --so we calculate the difference between initial pos
    --and current pos to maintain direction of shot
    local diff_x, diff_y = self.ix - self.x, self.iy - self.x
    local dir = get_dir(self.tx, self.ty, self.ix, self.iy)
    self.dx, self.dy = cos(dir), sin(dir)
    self.x -= self.dx * self.spd
    self.y -= self.dy * self.spd
    self.spd += .1
    sync_pos(self)
    if self.frame > self.lifetime then
        self:die()
    end
    if self.friendly then
        for en in all(enemies) do
            if col(self, vector(en.x, en.y), 6) then
                en:take_dmg(self.dmg)
                self:die()
            end
        end
    else
        if col(self, vector(p.x, p.y), 8) then
            p:take_dmg(self.dmg)
            self:die()
        else
            for e in all(entities) do
                if col(self, vector(e.x, e.y), 6) then
                    e:take_dmg(self.dmg)
                    self:die()
                end
            end
        end
    end
end

function bullet:draw()
    local c, x, y = 8, self.x, self.y
    if (self.friendly) c = 10
    if (self.frame % 3 == 0) self.tgl = not self.tgl
    if self.tgl then
        circfill(x, y, 2, 1)
        -- circfill(x, y, 1, 7)
    end
    -- circfill(x, y, 1, c)
    line(x, y, x + self.dx * self.spd, y + self.dy * self.spd, c)
    -- pset(x, y, 7)
end

function bullet:die()
    -- sfx
    bulletfx(self.x, self.y)
    del(bullets, self)
end