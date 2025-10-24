-- map
function map_setup()
    flags = {
        wall = 0,
        entity = 1,
        pickup = 2,
        enemy = 3
    }
    w = 128
    h = 128
end

function draw_map()
    -- fillp(0x7fff)
    -- rectfill(0, 0, 128, 128, 2)
    -- fillp()
    map(0, 0, 0, 0, w, h)
end