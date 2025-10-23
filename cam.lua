-- cam
function setup_cam()
    cam = {
        x = 0,
        y = 0
    }
end

function update_cam()
    cam.x = flr(p.x + (p.w / 2) - 63)
    cam.y = flr(p.y - (p.h / 2) - 63)
end

function draw_cam()
    camera(cam.x, cam.y)
end