-- map

function init_map()
    mapx, mapy = 0, 0
    flags = {
        wall = 0,
        entity = 1,
        pickup = 2,
        enemy = 3
    }
    redraw_map = true
    tiles = rand_in_circlefill(63, 63, 128)
    for t in all(tiles) do
        t.spr = mid(1, ceil(rnd(4)), 4)
    end
end

function update_map()
    mapx += psx
    mapy += psy
    for t in all(tiles) do
        sync_pos(t)
        if t.x > 172 or t.x < -44 or t.y > 172 or t.y < -44 then
            local r = rand_in_circle(63, 63, 64)
            t.x, t.y = r.x, r.y
        end
    end
end

function draw_map()
    for i = 1, #tiles do
        if (i < 128) spr(tiles[i].spr, tiles[i].x, tiles[i].y)
    end
end