--bullets

bullets = {}

bullet = class:new()
quickset(
    bullet,
    "x,y,dx,dy,r,ix,iy,tx,ty,spd,frame,lifetime,tgl,friendly",
    "0,0,0,0,2,0,0,0,0,1,1,150,false,false"
)

function update_bullets()
    for i, b in inext, bullets do
        b:update()
    end
end

function draw_bullets()
    for i, b in inext, bullets do
        b:draw()
    end
end

function bullet:update()
    local _ENV = self
    frame += 1
    if frame > lifetime then
        self:die()
        return
    end
    --enemies move as player moves for scrolling map
    --so we calculate the difference between initial pos
    --and current pos to maintain direction of shot
    local dir = get_dir(tx, ty, ix, iy)
    dx, dy = cos(dir), sin(dir)
    x -= dx * spd
    y -= dy * spd
    spd += .1
    sync_pos(self)
    if friendly then
        spd += .05
        for i, en in inext, enemies do
            self:col(en)
        end
    else
        if not self:col(p) then
            for i, e in inext, entities do
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