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
    local diff_x, diff_y = self.ix - self.x, self.iy - self.x
    -- self:move_to(self.tgt.x - diff_x, self.tgt.y - diff_y)
    local dir = get_dir(self.tx, self.ty, self.ix, self.iy)
    self.dx, self.dy = cos(dir), sin(dir)
    self.x -= self.dx * self.spd
    self.y -= self.dy * self.spd
    sync_pos(self)
    if tgt != p and col(self, vector(self.tgt.x, self.tgt.y), 6) then
        self.tgt:take_dmg(self.dmg)
        bulletfx(self.x, self.y)
        --sfx
        del(bullets, self)
    elseif col(self, vector(p.x, p.y), 8) and not self.friendly then
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
    local c = 8
    if (self.friendly) c = 10
    if (self.frame % 3 == 0) self.tgl = not self.tgl
    if self.tgl then
        circfill(self.x, self.y, 2, 1)
        -- circfill(self.x, self.y, 1, 7)
    end
    circfill(self.x, self.y, 1, c)
    pset(self.x, self.y, c)
end