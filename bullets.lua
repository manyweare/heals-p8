--bullets

bullets = {}

bullet = object:new()
quickset(
    bullet,
    "x,y,ix,iy,tx,ty,r,spd,frame,lifetime,tgl,friendly",
    "0,0,0,0,0,0,4,1,1,150,false,false"
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
            if col(self, vector(en.x, en.y), 6) then
                en:take_dmg(dmg)
                self:die()
            end
        end
    else
        if col(self, vector(px, py), 8) then
            p:take_dmg(dmg)
            self:die()
        else
            for e in all(entities) do
                if col(self, vector(e.x, e.y), 6) then
                    e:take_dmg(dmg)
                    self:die()
                end
            end
        end
    end
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