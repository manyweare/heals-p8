--gamestates

--init--------------------------

function init_game()
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

--update------------------------

function update_start()
    get_inputs()
    update_ui()
end

function update_game()
    playtime += 1
    get_inputs()
    update_player()
    update_spawner()
    update_entities()
    update_enemies()
    update_heals()
    update_items()
    update_bullets()
    update_ui()
    update_fx()
    update_cam()
    update_map()
    cheat()
end

function update_upgrade()
    get_inputs()
    -- update_items()
    update_ui()
    update_fx()
    update_lvlup()
end

function update_gameover()
    get_inputs()
    -- update_ui()
    update_gameover_screen()
end

--draw-----------------------------

function draw_start()
    cls()
    draw_ui()
end

function draw_game()
    cls()
    draw_map()
    draw_dead_ens()
    draw_dead_es()
    draw_player()
    draw_fx()
    draw_entities()
    draw_enemies()
    draw_heals()
    draw_items()
    draw_bullets()
    draw_range()
    draw_ui()
    draw_hud()
    draw_cam()
end

function draw_upgrade()
    cls()
    draw_fx()
    draw_player()
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