--bullets

bullets = {}

bullet = object:new()
quickset(
    bullet,
    "x,y,r,ix,iy,tx,ty,spd,frame,lifetime,tgl,friendly",
    "0,0,2,0,0,0,0,1,1,150,false,false"
)

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
    local _ENV = self
    frame += 1
    --enemies move as player moves for scrolling map
    --so we calculate the difference between initial pos
    --and current pos to maintain direction of shot
    local dir = get_dir(tx, ty, ix, iy)
    dx, dy = cos(dir), sin(dir)
    x -= dx * spd
    y -= dy * spd
    spd += .1
    sync_pos(self)
    if frame > lifetime then
        self:die()
    end
    if friendly then
        for en in all(enemies) do
            self:col(en)
        end
    else
        if not self:col(p) then
            for e in all(entities) do
                self:col(e)
            end
        end
    end
end

function bullet:col(a)
    if col(self, self.r, a, a.r) then
        a:take_dmg(self.dmg)
        self:die()
        return true
    end
    return false
end

function bullet:draw()
    local _ENV = self
    local c = 8
    if (friendly) c = 10
    line(x, y, x + dx * spd, y + dy * spd, c)
end

function bullet:die()
    -- sfx
    bulletfx(self.x, self.y)
    del(bullets, self)
end