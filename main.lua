grid_size_x = 80
grid_size_y = 60
speed = 0.1

grid = {}
dtotal = 0
cell_size_x = love.graphics.getWidth() / grid_size_x
cell_size_y = love.graphics.getHeight() / grid_size_y
speed_off = 0
gen_number = 0

function make_grid()
	g = {}
	
	for i = 1, grid_size_x, 1 do
		g[i] = {}
		for j = 1, grid_size_y, 1 do
			g[i][j] = 0
		end
	end
	
	return g
end

-- Returns 1 if the specified cell exists and is alive
function check_cell(g, x, y)
	cell = 0
	
	if (g[x] ~= nil) and (g[x][y] ~= nil) and (g[x][y] == 1) then
		return 1
	end
	
	return cell
end

function grid_count_neighbours(g, x, y)
	neighbours = 0
	
	neighbours = neighbours + check_cell(g, x-1, y)
	neighbours = neighbours + check_cell(g, x+1, y)
	neighbours = neighbours + check_cell(g, x, y-1)
	neighbours = neighbours + check_cell(g, x, y+1)
	
	neighbours = neighbours + check_cell(g, x-1, y-1)
	neighbours = neighbours + check_cell(g, x-1, y+1)
	neighbours = neighbours + check_cell(g, x+1, y-1)
	neighbours = neighbours + check_cell(g, x+1, y+1)
	
	return neighbours
end

function love.load()
	-- Create a screen-sized grid
	grid = make_grid()
	
	-- Make a bar (always alive)
	grid[30][30] = 1
	grid[31][30] = 1
	grid[32][30] = 1
	
	-- Make a glider
	grid[30][40] = 1
	grid[31][40] = 1
	grid[32][40] = 1
	grid[30][41] = 1
	grid[31][42] = 1
end

function update_grid(g)
	newgrid = make_grid()
	
	for i = 1, grid_size_x, 1 do
		for j = 1, grid_size_y, 1 do
			neighbours = grid_count_neighbours(g, i, j)
			
			if g[i][j] == 1 then
				-- Any live cell with fewer than two live neighbours dies, as if caused by under-population.
				-- Any live cell with two or three live neighbours lives on to the next generation.
				-- Any live cell with more than three live neighbours dies, as if by over-population.
				if neighbours == 2 or neighbours == 3 then
					newgrid[i][j] = 1
				end
			else
				-- Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
				if neighbours == 3 then
					newgrid[i][j] = 1
				end
			end
		end
	end
	
	gen_number = gen_number + 1
	
	return newgrid
end

function love.update(dt)
	dtotal = dtotal + dt
	
	if dtotal >= speed  and speed > 0 then
		grid = update_grid(grid)
		dtotal = dtotal - speed
	end
	
	if love.mouse.isDown(1) then
		local x = math.floor(love.mouse.getX()/cell_size_x)+1
		local y = math.floor(love.mouse.getY()/cell_size_y)+1
		grid[x][y] = 1
	end
end

function love.draw()
	for i = 1, grid_size_x, 1 do
		for j = 1, grid_size_y, 1 do
			if grid[i][j] == 1 then
				-- Cool color gradient!
				love.graphics.setColor(150*i/grid_size_x+155, 150*(1-j)/grid_size_y+155, 0)
				
				love.graphics.rectangle("fill", (i-1)*cell_size_x, (j-1)*cell_size_y, cell_size_x-1, cell_size_y-1)
			end
		end
	end
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Generation " .. gen_number, 16, 16)
	
	if speed ~= 0 then
		love.graphics.print("Speed: " .. 1/speed .. " generation/s", 16, 32)
	else
		love.graphics.print("Paused", 16, 32)
	end
end

function love.keyreleased(key)
	if key == "space" then
		speed, speed_off = speed_off, speed
		dtotal = 0
	end
end
