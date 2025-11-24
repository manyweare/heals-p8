-- map

--TODO:
--vertical scrolling -DONE
--map art
--props art
--draw props

function init_map()
    s_map = { x = 0, y = 0 }
    flags = {
        wall = 0,
        entity = 1,
        pickup = 2,
        enemy = 3
    }
    seg_h = 16
    mid_segs = 2
    seg_sy = {}
    for i = 0, mid_segs + 1 do
        add(seg_sy, -128 * i)
    end
end

function update_map()
    s_map.x += p.sx
    s_map.y += p.sy
end

function draw_map()
    --draw scrolling map
    for i = 0, 2 do
        for j = 0, 2 do
            map(
                0, 0,
                s_map.x % 128 + 128 * i - 128,
                s_map.y % 128 + 128 * j - 128
            )
        end
    end
end

function draw_map_f()
    --segment the player is on based on the cam y pos
    local s = flr(abs(cam.y) / 128) + 1
    --which segments to draw
    --clamped to 2 (bottom and mid) in the map editor
    --these values start at 1,2
    --stick to 2,2 until we get to the top
    local segs = { mid(s, 0, 2), min(s + 1, 2) }
    --if we're at the top, clamp the 2nd to 3 (top)
    if (s == #seg_sy - 1) segs[2] = 3
    map((segs[1] - 1) * seg_h, 0, cam.x, seg_sy[s])
    map((segs[2] - 1) * seg_h, 0, cam.x, seg_sy[s + 1])
    --debug
    -- print(tostr(seg), ui.x + 2, ui.y + 116, 7)
    -- print(tostr(i) .. "," .. tostr(j), ui.x + 2, ui.y + 122, 7)
    -- for i = 0, #seg_sy - 1 do
    --     print(seg_sy[i + 1], ui.x + 2 + i * 18, ui.y + 110, 7)
    -- end
end