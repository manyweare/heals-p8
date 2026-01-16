-- main

function _init()
	version = "V0.4"
	-- map coords
	map_x, map_y, playtime = 0, 0, 0
	--color palette--
	poke(0x5f2e, 1)
	pal({ [0] = 0, unpack(split("1,129,3,133,5,6,7,8,138,139,11,141,13,130,131")) }, 1)
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