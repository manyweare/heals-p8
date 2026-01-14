--tentacles

function create_tentacle(sx, sy, r1, r2, l, c)
    --random length
    local r = round(rnd(l / 2))
    local rl = l + r
    local rlmax = rl + r
    r = rand_in_circle(sx, sy, rl)
    local t = {
        sx = sx,
        sy = sy,
        ex = r.x,
        ey = r.y,
        tx = r.x,
        ty = r.y,
        r1 = r1,
        r2 = r2,
        length = rl,
        max_length = rlmax,
        colors = c,
        start_time = 0
    }
    return t
end

function create_tentacles(n, sx, sy, r1, r2, l, c)
    local t = {}
    for i = 1, n do
        local _t = create_tentacle(sx, sy, r1, r2, l, c)
        add(t, _t)
    end
    return t
end

function draw_tentacle(t, clrs)
    --s=samples
    local s = round(t.length * 1.5)
    local x, y, r, c, ratio
    for i = 0, s do
        ratio = i / s
        x = t.sx + ((t.ex - t.sx) * ratio)
        y = t.sy + ((t.ey - t.sy) * ratio)
        r = t.r1 + ((t.r2 - t.r1) * ratio)
        c = 1 + round((count(clrs) - 1) * ratio)
        if r > 1.5 then
            circfill(x, y, r, clrs[c])
        else
            pset(x, y, clrs[c])
        end
    end
end

function draw_tentacles(tentacles, main_clrs, state)
    state = state or "alive"
    --color tentacles based on state/sprite clrs
    --default to spawning/hurt colors
    local clrs = split("13, 13, 13, 1")
    if state == "alive" then
        clrs = main_clrs
    elseif state == "dead" then
        clrs = split("1, 1, 2, 2")
    end
    for t in all(tentacles) do
        draw_tentacle(t, clrs)
    end
end

function update_tentacles(o)
    local timer, d_center, d_move
    for t in all(o.tentacles) do
        t.tx += psx
        t.ty += psy
        d_center = approx_dist(o.x, o.y, t.ex, t.ey)
        d_move = approx_dist(t.ex, t.ey, t.tx, t.ty)
        if d_center >= t.max_length and d_move < 0.01 then
            --(o.dx * t.length / 2) = moves the target pos (tx,ty)
            --to direction obj is headed (dx,dy)
            local r = rand_in_circle(o.x, o.y, t.length)
            t.tx = r.x - o.dx * (t.length / 2)
            t.ty = r.y - o.dy * (t.length / 2)
            t.start_time = time()
        end
        --animation speed = ((time() - start_time) % 1) * modifier
        timer = mid(0, ((time() - t.start_time) % 1) * 2.25, 1)
        t.ex = lerp(t.ex, t.tx, easeoutquart(timer)) + psx
        t.ey = lerp(t.ey, t.ty, easeoutquart(timer)) + psy
        t.sx, t.sy = o.x, o.y
    end
end