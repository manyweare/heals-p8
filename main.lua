-- main

-- TODOS:

-- ART:
-- replace warm greys in palette with more reds
-- only one sprite for hurt entities now that we have hp bars
-- boss art
-- level art
-- hurt entity offscreen ui icon
-- xp pickup sprite -DONE

-- DESIGN/CODE:
-- start screen
-- "heal thyself" intro -INPROGRESS
-- adjust growth curve
-- improve state machine -DONE
-- leveling system -INPROGRESS
-- fix cobblestoning -DONE
-- game over screen -INPROGRESS
-- boss
-- enemy types -INPROGRESS
-- enemies that shoot projectiles
-- change xp system to use pickups -DONE
-- level design
-- level progresses upwards towards bosses -CANCELED
-- boss spawns after X time or X kills or...?
-- difficulty curve -INPROGRESS
-- ui icon toward offscreen hurt entity
-- optimize token count

-- MAYBES:
-- enemies spawn from bosses, move downward
-- start with some entities
-- other entities trapped
-- entities grow stronger
-- active abilities? rez, tranq, ?

function _init()
	version = "0.2"
	pi = 3.14
	--init input lists
	p_i_last, p_inputs, p_i_data = {}, {}, {}
	-- map coords
	map_x, map_y = 0, 0
	--color palette--
	poke(0x5f2e, 1)
	pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 138, 139, 11, 141, 13, 130, 131 }, 1)
	-- pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 9, 135, 141, 12, 142, 11, 138 }, 1)
	--easing vars--
	lt = time()
	_t, te, dt = 0, 0, 0
	--setup--
	init_game()
end

function _update()
	_t = time()
	dt = _t - lt
	lt = _t
	te += dt
	update_game()
	-- update_upgrade()
	-- update_debug()
end

function _draw()
	draw_game()
	-- draw_upgrade()
	-- draw_debug()
end