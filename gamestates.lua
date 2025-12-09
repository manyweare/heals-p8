--gamestates

--init functions----------------

function init_game()
    init_manager()
    init_map()
    init_player()
    init_ui()
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
    get_inputs()
    update_ui()
end

function update_game()
    get_inputs()
    update_player()
    update_entities()
    update_enemies()
    update_heals()
    update_items()
    update_ui()
    update_fx()
    update_cam()
    update_map()
    cheat()
end

function update_upgrade()
    get_inputs()
    -- update_heals()
    update_items()
    update_ui()
    update_fx()
    -- update_cam()
    -- update_map()
    update_lvlup()
end

function update_gameover()
    get_inputs()
    -- update_ui()
    update_gameover_screen()
end

function update_debug()
    get_inputs()
    -- update_heals()
    -- update_entities()
    -- update_enemies()
    update_player()
    update_ui()
    update_items()
    -- update_fx()
    update_cam()
    update_map()
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
    draw_player()
    draw_fx()
    draw_entities()
    draw_heals()
    draw_enemies()
    draw_items()
    draw_ui()
    draw_hud()
    draw_log()
    draw_cam()
end

function draw_upgrade()
    cls()
    -- draw_map()
    -- draw_range()
    -- draw_dead()
    draw_fx()
    draw_player()
    -- draw_entities()
    -- draw_heals()
    -- draw_enemies()
    draw_items()
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
    draw_items()
    draw_ui()
    draw_hud()
    draw_log()
    draw_cam()
end