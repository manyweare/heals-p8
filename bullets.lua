--bullets

bullets = {}
bullet = object:new({
    x = 0,
    y = 0,
    midx = 0,
    midy = 0,
    ix = 0,
    iy = 0,
    w = 4,
    h = 4,
    spd = 1.5,
    frame = 1,
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
    --enemies move as player moves for scrolling map
    --so we calculate the difference between initial pos
    --and current pos to maintain direction of shot
    local diff_x, diff_y = self.ix - self.midx, self.iy - self.midx
    self:move_to(self.tgt.midx - diff_x, self.tgt.midy - diff_y)
    sync_pos(self)
    if tgt != p and col(self, vector(self.tgt.midx, self.tgt.midy), 6) then
        self.tgt:take_dmg(self.dmg)
        bulletfx(self.x, self.y)
        --sfx
        del(bullets, self)
    elseif col(self, vector(p.midx, p.midy), 8) and not self.friendly then
        p:take_dmg(self.dmg)
        bulletfx(self.x, self.y)
        --sfx
        del(bullets, self)
    end
    if self.frame == 150 then
        bulletfx(self.x, self.y)
        del(bullets, self)
    end
end

function bullet:draw()
    circfill(self.x, self.y, 1, 8)
    if (self.frame % 3 == 0) self.tgl = not self.tgl
    if self.tgl then
        circfill(self.x, self.y, 2, 1)
        circfill(self.x, self.y, 1, 7)
    end
    pset(self.x, self.y, 8)
end