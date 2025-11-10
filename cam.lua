--cam

function init_cam()
    cam = { x = 0, y = 0 }
    shk = { x = 0, y = 0 }
    shake = 0
end

function update_cam()
    -- cam.x = p.x + flr(p.w / 2) - 63 - shk.x
    cam.x = shk.x
    cam.y = mid(0, p.y + flr(p.w / 2) - 63, seg_sy[#seg_sy] + 64) - shk.y
    u_shake()
end

function draw_cam()
    camera(cam.x, cam.y)
end

function add_shake(n)
    shake = n
end

function u_shake()
    shake = max(shake - 1, 0)
    shk.x = (rnd(2) - 1) * shake * 0.5
    shk.y = (rnd(2) - 1) * shake * 0.5
end