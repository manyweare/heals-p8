--cam

function init_cam()
    cam, shk = vector(), vector()
    shake = 0
end

function update_cam()
    -- cam.x = p.x + flr(p.w / 2) - 63 - shk.x
    cam.x = shk.x
    cam.y = mid(0, p.y + flr(p.w / 2) - 63, seg_sy[#seg_sy] + 64) - shk.y
    update_shake()
end

function draw_cam()
    camera(cam.x, cam.y)
end

function add_shake(n)
    shake = n
end

function update_shake()
    local mod = .5
    if (p.hp <= ceil(p.hpmax / 10)) mod = 1.5
    shake = max(shake - 1, 0)
    shk.x = (rnd(2) - 1) * shake * mod
    shk.y = (rnd(2) - 1) * shake * mod
end