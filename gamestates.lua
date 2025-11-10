--gamestates

--init functions----------------

function init_game()
    init_manager()
    init_map()
    init_ui()
    init_player()
    init_heals()
    init_entities()
    init_enemies()
    init_fx()
    init_cam()
end

function reset_game()
    init_manager()
    init_map()
    init_player()
    -- init_heals()
    init_entities()
    init_enemies()
    -- init_ui()
    init_fx()
    init_cam()
end

--update states----------------

function update_start()
    --for easing functions
    t = time()
    update_ui()
end

function update_game()
    --for easing functions
    t = time()
    update_heals()
    update_entities()
    update_enemies()
    update_player()
    update_ui()
    update_fx()
    update_cam()
    cheat()
end

function update_upgrade()
    --for easing functions
    t = time()
    update_heals()
    update_ui()
    update_fx()
    update_cam()
    update_lvlup()
end

function update_gameover()
    -- update_ui()
    update_gameover_screen()
end

function update_debug()
    -- update_heals()
    -- update_entities()
    -- update_enemies()
    update_player()
    update_ui()
    -- update_fx()
    update_cam()
    cheat()
end

--draw states------------------

function draw_start()
    cls()
    draw_ui()
end

function draw_game()
    cls()
    draw_map()
    -- draw_range()
    draw_dead()
    draw_fx()
    draw_player()
    draw_entities()
    draw_heals()
    draw_enemies()
    draw_ui()
    draw_hud()
    draw_log()
    draw_cam()
end

function draw_upgrade()
    cls()
    draw_map()
    -- draw_range()
    draw_dead()
    draw_fx()
    draw_player()
    draw_entities()
    draw_heals()
    draw_enemies()
    draw_ui()
    draw_cam()
    draw_lvlup()
end

function draw_gameover()
    cls()
    -- draw_ui()
    draw_gameover_screen()
end

function draw_debug()
    cls()
    draw_map()
    -- draw_range()
    -- draw_dead()
    -- draw_fx()
    draw_player()
    -- draw_entities()
    -- draw_heals()
    -- draw_enemies()
    draw_ui()
    draw_hud()
    draw_log()
    draw_cam()
end