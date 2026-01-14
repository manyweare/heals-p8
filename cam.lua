--cam

function init_cam()
    camx, camy, shkx, shky, shake = 0, 0, 0, 0, 0
end

function update_cam()
    -- cam.x = p.x + flr(p.w / 2) - 63 - shk.x
    -- cam.y = mid(0, p.y + flr(p.w / 2) - 63, seg_sy[#seg_sy] + 64) - shk.y
    camx, camy = shkx, shky
    update_shake()
end

function add_shake(n)
    shake = n
end

function update_shake()
    local mod = .5
    --increase shake if player hp is under 25%
    if (p.hp <= ceil(p.hpmax / 25)) mod = 1.5
    shake = max(shake - 1, 0) * mod
    shkx, shky = (rnd(2) - 1) * shake, (rnd(2) - 1) * shake
end