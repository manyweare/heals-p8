--manager

--TODO:
--more level up choices
--better gameover screen

game = {
    --current xp max
    xpmax = 3,
    --current xp modifier
    xpmod = 1,
    --current live enemies
    live_ens = 0,
    --total dead enemies
    dead_ens = 0,
    --current live entities
    live_es = 0,
    --total dead entities
    dead_es = 0,
    --total healed entities
    healed_es = 0
}

lvlup_options = {}

function init_manager()
    -- game = {
    --     --current xp max
    --     xpmax = 3,
    --     --current xp modifier
    --     xpmod = 1,
    --     --current live enemies
    --     live_ens = 0,
    --     --total dead enemies
    --     dead_ens = 0,
    --     --current live entities
    --     live_es = 0,
    --     --total dead entities
    --     dead_es = 0,
    --     --total healed entities
    --     healed_es = 0
    -- }
    -- lvlup_options = {}
end

-- leveling functions --

function addxp(n)
    local ovrxp = 0
    n *= game.xpmod
    --check for lvl up and overflow
    if p.curxp + n >= game.xpmax then
        ovrxp = (p.curxp + n) - game.xpmax
        p.curxp = ovrxp
        lvlup()
    else
        p.curxp += n * game.xpmod
    end
    p.totalxp += n * game.xpmod
end

function lvlup()
    sfx(-1)
    sfx(sfxt.lvlup)
    p.lvl += 1
    lvlanim = 1
    --log scaling
    --value = steepness * log_b(level + 1) + offset
    --TODO: adjust xp max increase curve
    game.xpmax = flr(game.xpmax * 1.5)
    --create list of random lvl up uptions
    lvlup_options = {}
    while #lvlup_options < 3 do
        local r = rnd(all_heals)
        if (count(lvlup_options, r) == 0) add(lvlup_options, r)
    end
    --change state
    _update = update_upgrade
    _draw = draw_upgrade
end

function cheat()
    if btn(4) then
        lvlup()
        _update = update_upgrade
        _draw = draw_upgrade
    end
end

function draw_dead()
    draw_dead_ens()
    draw_dead_es()
end

function game_over()
    _update = update_gameover
    _draw = draw_gameover
end

function update_gameover_screen()
    if btnp(5) then
        reset_game()
        _update = update_game
        _draw = draw_game
    end
end

function draw_gameover_screen()
    print("you died!", ui.x + 4, ui.y + 46, 8)
    print("press ❎ to restart", ui.x + 4, ui.y + 54, 7)
end