--object

-- object constructor --
object = {}
function object:new(o)
    o = o or {}
    local a = {}
    -- copy defaults
    for k, v in pairs(self) do
        a[k] = v
    end
    -- extra parameters
    for k, v in pairs(o) do
        a[k] = v
    end
    setmetatable(a, self)
    self.__index = self
    return a
end

function object:update()
    if (self.tentacles) update_tentacles(self)
    self.frame += 1
    self:reset_pos()
    sync_pos(self)
end

function object:move_to(x, y)
    local dir = get_dir(x, y, self.x, self.y)
    self.dx, self.dy = cos(dir), sin(dir)
    self.x -= self.dx * self.spd
    self.y -= self.dy * self.spd
end

function object:move_apart(t, r)
    if (#t < 2) return
    local dist, dir, dif
    for i = 1, #t do
        if t[i] != self then
            if col(self, t[i], 8) then
                dist = approx_dist(self.x, self.y, t[i].x, t[i].y)
                dir = get_dir(self.x, self.y, t[i].x, t[i].y)
                dif = r - dist
                t[i].x += cos(dir) * dif
                t[i].y += sin(dir) * dif
            end
        end
    end
end

function object:flip_spr(tx)
    self.flip = self.x > tx
end

function object:tgl_anim(spd, f1, f2, counter)
    counter = counter or self.frame
    if (counter % spd < spd / 2) then
        self.spr = f1
    else
        self.spr = f2
    end
end

--reset pos when out of map bounds
function object:reset_pos()
    if self.x > 170 or self.y > 170 then
        local pos = rand_in_circle(p.x, p.y, 64)
        self.x, self.y = pos.x, pos.y
    end
end

function object:take_dmg(dmg)
    self.hitframe = 1
    self.hp -= dmg
    printh("--- " .. self.name .. " damaged ---", "log.p8l", true)
    if (self.hp <= 0) then
        self:die()
    end
end

function object:shoot(tgt, is_friendly)
    is_friendly = is_friendly or false
    local b = bullet:new({
        x = self.x,
        y = self.y,
        ix = self.x,
        iy = self.y,
        tx = tgt.x,
        ty = tgt.y,
        dmg = self.dmg,
        tgt = tgt,
        friendly = is_friendly
    })
    add(bullets, b)
end

--agent functions
--adapted from Daniel Shiffman's Nature of Code
agent = object:new({
    pos = vector(),
    vel = vector(),
    accel = vector(),
    maxspd = 1,
    maxfrc = .1,
    tgt = vector()
})

function agent:update_pos()
    if self.behavior == "seek" then
        self:seek(self.tgt)
    elseif self.behavior == "arrive" then
        self:arrive(self.tgt, 12)
    end
    -- self:separate(nearby)
    self:move()
end

function agent:apply_force(f)
    self.accel = v_add(self.accel, f)
end

function agent:move()
    self.accel = v_limit(self.accel, self.maxfrc)
    self.vel = v_add(self.vel, self.accel)
    self.vel = v_limit(self.vel, self.maxspd)
    self.pos = v_add(self.pos, self.vel)
    --update pos relative to player
    self.pos = v_add(self.pos, vector(psx, psy))
end

function agent:seek(tgt)
    local d = v_sub(tgt, self.pos)
    d = v_setmag(d, self.maxspd)
    local s = v_sub(d, self.vel)
    self:apply_force(s)
    return s
end

function agent:arrive(tgt, r)
    local d = v_sub(tgt, self.pos)
    local dist = v_mag(d)
    if dist < r then
        local mag = map_value(dist, 0, r, 0, self.maxspd)
        d = v_setmag(d, mag)
    else
        d = v_setmag(d, self.maxspd)
    end
    local s = v_sub(d, self.vel)
    self:apply_force(s)
end