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
-- adjust growth curve -INPROGRESS
-- improve state machine -DONE
-- leveling system -INPROGRESS
-- fix cobblestoning -DONE
-- game over screen -INPROGRESS
-- boss
-- enemy types -DONE
-- enemies that shoot projectiles -INPROGRESS
-- change xp system to use pickups -DONE
-- level design
-- level progresses upwards towards bosses -CANCELED
-- boss spawns after X time or X kills or...? -INPROGRESS
-- difficulty curve -INPROGRESS
-- ui icon toward offscreen hurt entity
-- optimize token count -INPROGRESS

-- MAYBES:
-- enemies spawn from bosses, move downward
-- start alone
-- entities spawn after X time
-- other entities trapped
-- entities grow stronger
-- active abilities? rez, tranq, ?

function _init()
	version = "V0.4"
	-- map coords
	map_x, map_y = 0, 0
	--total playtime
	playtime = 0
	--color palette--
	poke(0x5f2e, 1)
	pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 138, 139, 11, 141, 13, 130, 131 }, 1)
	-- pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 9, 135, 141, 12, 142, 11, 138 }, 1)
	--setup--
	init_game()
end

function _update()
	update_game()
end

function _draw()
	draw_game()
end