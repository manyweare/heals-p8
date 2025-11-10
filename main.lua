-- main

-- TODOS:
-- adjust growth curve
-- improve state machine -DONE
-- leveling system (in-progress)
-- ui pointer toward offscreen hurt entity
-- fix cobblestoning
-- start screen
-- game over screen
-- bosses
-- level art + design
-- level progresses upwards towards bosses
-- difficulty curve
-- (maybe) enemies spawn from bosses, move downward
-- (maybe) start with some entities
-- (maybe) other entities trapped
-- optimize token count

function _init()
	version = "0.1"
	pi = 3.14

	--color palette--
	poke(0x5f2e, 1)
	pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 138, 139, 11, 141, 13, 130, 131 }, 1)
	-- switch to a more NES palette??
	-- this isn't it but better than the above
	-- pal({ [0] = 0, 1, 129, 3, 133, 5, 6, 7, 8, 9, 135, 141, 12, 142, 11, 138 }, 1)

	--easing vars--
	lt = time()
	te = 0
	dt = 0

	--setup--
	init_game()
end

function _update()
	update_game()
	-- update_upgrade()
	-- update_debug()
end

function _draw()
	draw_game()
	-- draw_upgrade()
	-- draw_debug()
end