local mg_2048 = {}

--Mini game array
local array_mg = {}
local array_only_zero = {} -- Need to add numbers on move
local every_row_size = {}

--For Randomize
math.randomseed(os.time())

--Menu 
local mg_2048_b = Menu.AddOptionBool({ "Mini Games", "2048" }, "Enabled", true)

-- Font
local font = Renderer.LoadFont("Verdana",  64, Enum.FontCreate.FONTFLAG_ANTIALIAS, 2)
local font2 = Renderer.LoadFont("Verdana",  20, Enum.FontCreate.FONTFLAG_ANTIALIAS, 2)
local font3 = Renderer.LoadFont("Verdana",  20, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)
local font4 = Renderer.LoadFont("Verdana",  48, Enum.FontCreate.FONTFLAG_ANTIALIAS, 2)
local font5 = Renderer.LoadFont("Verdana",  40, Enum.FontCreate.FONTFLAG_ANTIALIAS, 2)
local font6 = Renderer.LoadFont("Verdana",  30, Enum.FontCreate.FONTFLAG_ANTIALIAS, 2)
local font7 = Renderer.LoadFont("Verdana",  24, Enum.FontCreate.FONTFLAG_ANTIALIAS, 2)

--config variables
local score = 0 -- score var
local best_score = Config.ReadInt("mini_games", "best_score", 0) -- best score
local menu_posx = Config.ReadInt("mini_games", "menu_posx", 400) -- x position for menu
local menu_posy = Config.ReadInt("mini_games", "menu_posy", 250) -- y position for menu

--local vars
local game_over_b = false


-- direction: 1 - left, 2 - right
function can_move_hor(game_array, direction)
	if direction == 1 then
		for i = 1, 4 do
			for j = 1, 3 do
				if game_array[j][i] == game_array[j+1][i] and game_array[j][i] ~= 0 then
					return true
				elseif game_array[j][i] == 0 and game_array[j+1][i] ~=0 then
					return true
				end
			end
		end
	elseif direction == 2 then
		for i = 1, 4 do
			for j = 4,2,-1 do
				if game_array[j][i] == game_array[j-1][i] and game_array[j][i] ~= 0 then
					return true
				elseif game_array[j][i] == 0 and game_array[j-1][i] ~=0 then
					return true
				end
			end
		end
	end

	return false
end

-- direction: 1 - up, 2 - down
function can_move_vert(game_array, direction)
	if direction == 2 then
		for i = 1, 4 do
			for j = 1, 3 do
				if game_array[i][j] == game_array[i][j+1] and game_array[i][j] ~= 0 then
					return true
				elseif game_array[i][j] == 0 and game_array[i][j+1] ~=0 then
					return true
				end
			end
		end
	elseif direction == 1 then
		for i = 1, 4 do
			for j = 4, 2,-1 do
				if game_array[i][j] == game_array[i][j-1] and game_array[i][j] ~= 0 then
					return true
				elseif game_array[i][j] == 0 and game_array[i][j-1] ~=0 then
					return true
				end
			end
		end
	end
	return false
end

function can_move(game_array)
	if can_move_vert(game_array, 1) or can_move_hor(game_array, 1) or can_move_vert(game_array, 2) or can_move_hor(game_array, 2)then
		return true
	else 
		return false
	end
end

function game_over()
	game_over_b = true
end


-- Create new vars on game table
function create_new_var_in_game(game_array)

	local var_pos_x = math.random(1,4)
	local var_pos_y = math.random(1,4)

	while game_array[var_pos_x][var_pos_y] > 0 do 

		if not can_move(game_array) then
			game_over()
			break
		end
		
		var_pos_x = math.random(1,4)
		var_pos_y = math.random(1,4)
	end
	if math.random(1,10) ~= 1 and not game_over_b then
		game_array[var_pos_x][var_pos_y] = 2
	elseif not game_over_b then
		game_array[var_pos_x][var_pos_y] = 4
	end
end

function fill_array_with_zero(array)
		for i = 1, 4 do
	    array[i] = {}
	
	    for j = 1, 4 do
	        array[i][j] = 0 -- Fill the values here
	    end
	end
end

-- Foo for init new game
function init_new_game(row, column)
	game_over_b = false
	fill_array_with_zero(array_mg) -- creates new array with zeroes
	create_new_var_in_game(array_mg) -- crates value with chance 2(90%) or 4(10%) 
	create_new_var_in_game(array_mg)
end

init_new_game(4,4)


-- Function for new game step 
function game_step(array)
	if not can_move(array) then
		game_over()
		return
	end
	if Input.IsKeyDownOnce(Enum.ButtonCode.KEY_LEFT) and not game_over_b then -- if key left pressed

		if not can_move_hor(array, 1) then
			return
		end

		fill_array_with_zero(array_only_zero)
		
		for i = 1, 4 do
			local t = 1
			for j = 1, 4 do 
				if array_mg[j][i] ~= 0 then
					array_only_zero[t][i] = array_mg[j][i]
					t = t + 1
				end
			end
		end

		for i = 1, 4 do
			for j = 1, 3 do
				if j == 1 and  array_only_zero[j][i] == array_only_zero[j+1][i] and  array_only_zero[j+2][i] == array_only_zero[j+3][i] then
					array_only_zero[j][i] = array_only_zero[j][i] * 2
					array_only_zero[j+1][i] = array_only_zero[j+2][i] * 2
					array_only_zero[j+2][i] = 0
					array_only_zero[j+3][i] = 0
					score = score + array_only_zero[j][i] + array_only_zero[j+2][i]
					break
				elseif array_only_zero[j][i] > 0 then
					if array_only_zero[j][i] == array_only_zero[j+1][i] then
						array_only_zero[j][i] = array_only_zero[j][i] * 2
						array_only_zero[j+1][i] = 0
						score = score + array_only_zero[j][i]
					end
				else
					array_only_zero[j][i] = array_only_zero[j+1][i]
					array_only_zero[j+1][i] = 0
				end

			end
		end

		for i = 1, 4 do
			for j = 1, 4 do
				array_mg[j][i] = array_only_zero[j][i]
			end
		end
		
		create_new_var_in_game(array_mg)

	elseif Input.IsKeyDownOnce(Enum.ButtonCode.KEY_RIGHT) and not game_over_b then --if key right pressed

		if not can_move_hor(array, 2) then
			return
		end

		fill_array_with_zero(array_only_zero)

		for i = 1, 4 do
			local t = 4
			for j = 4, 1, -1 do 
				if array_mg[j][i] ~= 0 then
					array_only_zero[t][i] = array_mg[j][i]
					t = t - 1
				end
			end
		end

		for i = 1, 4 do
			for j = 4, 2, -1 do
				if j == 4 and  array_only_zero[j][i] == array_only_zero[j-1][i] and  array_only_zero[j-2][i] == array_only_zero[j-3][i] then
					array_only_zero[j][i] = array_only_zero[j][i] * 2
					array_only_zero[j-1][i] = array_only_zero[j-2][i] * 2
					array_only_zero[j-2][i] = 0
					array_only_zero[j-3][i] = 0
					score = score + array_only_zero[j][i]  + array_only_zero[j-2][i] 
					break
				elseif array_only_zero[j][i] > 0 then
					if array_only_zero[j][i] == array_only_zero[j-1][i] then
						array_only_zero[j][i] = array_only_zero[j][i] * 2
						array_only_zero[j-1][i] = 0
						score = score + array_only_zero[j][i] 
					end
				else
					array_only_zero[j][i] = array_only_zero[j-1][i]
					array_only_zero[j-1][i] = 0
				end

			end
		end

		for i = 1, 4 do
			for j = 1, 4 do
				array_mg[j][i] = array_only_zero[j][i]
			end
		end


		create_new_var_in_game(array_mg)

	elseif Input.IsKeyDownOnce(Enum.ButtonCode.KEY_DOWN) and not game_over_b then -- if key down

		if not can_move_vert(array, 1) then
			return
		end

		fill_array_with_zero(array_only_zero)

		for i = 1, 4 do
			local t = 4
			for j = 4, 1, -1 do 
				if array_mg[i][j] ~= 0 then
					array_only_zero[i][t] = array_mg[i][j]
					t = t - 1
				end
			end
		end

		for i = 1, 4 do
			for j = 4, 2, -1 do
				if j == 4 and  array_only_zero[i][j] == array_only_zero[i][j-1] and  array_only_zero[i][j-2] == array_only_zero[i][j-3] then
					array_only_zero[i][j] = array_only_zero[i][j] * 2
					array_only_zero[i][j-1] = array_only_zero[i][j-2] * 2
					array_only_zero[i][j-2] = 0
					array_only_zero[i][j-3] = 0
					score = score + array_only_zero[i][j]  + array_only_zero[i][j-2] 
					break
				elseif array_only_zero[i][j] > 0 then
					if array_only_zero[i][j] == array_only_zero[i][j-1] then
						array_only_zero[i][j] = array_only_zero[i][j] * 2
						array_only_zero[i][j-1] = 0
						score = score + array_only_zero[i][j] 
					end
				else
					array_only_zero[i][j] = array_only_zero[i][j-1]
					array_only_zero[i][j-1] = 0
				end

			end
		end

		for i = 1, 4 do
			for j = 1, 4 do
				array_mg[j][i] = array_only_zero[j][i]
			end
		end

		create_new_var_in_game(array_mg)

	elseif Input.IsKeyDownOnce(Enum.ButtonCode.KEY_UP) and not game_over_b then -- if keyup pressed

		if not can_move_vert(array, 2) then
			return
		end

		fill_array_with_zero(array_only_zero)

		for i = 1, 4 do
			local t = 1
			for j = 1,4 do 
				if array_mg[i][j] ~= 0 then
					array_only_zero[i][t] = array_mg[i][j]
					t = t + 1
				end
			end
		end

		for i = 1, 4 do
			for j = 1,3 do
				if j == 1 and  array_only_zero[i][j] == array_only_zero[i][j+1] and  array_only_zero[i][j+2] == array_only_zero[i][j+3] then
					array_only_zero[i][j] = array_only_zero[i][j] * 2
					array_only_zero[i][j+1] = array_only_zero[i][j+2] * 2
					array_only_zero[i][j+2] = 0
					array_only_zero[i][j+3] = 0
					score = score + array_only_zero[i][j]  + array_only_zero[i][j+2] 
					break
				elseif array_only_zero[i][j] > 0 then
					if array_only_zero[i][j] == array_only_zero[i][j+1] then
						array_only_zero[i][j] = array_only_zero[i][j] * 2
						array_only_zero[i][j+1] = 0
						score = score + array_only_zero[i][j] 
					end
				else
					array_only_zero[i][j] = array_only_zero[i][j+1]
					array_only_zero[i][j+1] = 0
				end

			end
		end

		for i = 1, 4 do
			for j = 1, 4 do
				array_mg[j][i] = array_only_zero[j][i]
			end
		end

		create_new_var_in_game(array_mg)
	elseif Input.IsKeyDownOnce(Enum.ButtonCode.KEY_J) then
		array_mg[4][4] = 999999
	end
	if score > best_score then
		best_score = score
		Config.WriteInt("mini_games", "best_score", best_score)
	end
end

function is_button_pressed_once(x, y, width, height)

	if Input.IsCursorInRect(x, y, width, height) and Input.IsKeyDownOnce(Enum.ButtonCode.KEY_MOUSE1) then
		return true
	end

	return false
end

function is_button_down(x, y, width, height)

	if Input.IsCursorInRect(x, y, width, height) and Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1) then
		return true
	end

	return false
end

function draw_game_table()

	-- draw game table
	Renderer.SetDrawColor(196, 173, 157, 255)
	Renderer.DrawFilledRect(menu_posx, menu_posy, 400, 550)-- first sloy

	--best Score
	Renderer.SetDrawColor(119, 173, 160, 255)
	Renderer.DrawFilledRect(menu_posx + 20,menu_posy + 30, 100, 60) 

	Renderer.SetDrawColor(249, 246, 242, 255)
	Renderer.DrawText(font2, menu_posx + 22, menu_posy + 32 , "Best Score") 

	Renderer.SetDrawColor(249, 246, 242, 255)
	Renderer.DrawText(font2, menu_posx + 22,  menu_posy + 60 , best_score) 

	--  Score
	Renderer.SetDrawColor(119, 173, 160, 255)
	Renderer.DrawFilledRect(menu_posx + 130, menu_posy + 30, 90, 60) 

	Renderer.SetDrawColor(249, 246, 242, 255)
	Renderer.DrawText(font2, menu_posx + 150 ,menu_posy + 32 , "Score") 

	Renderer.SetDrawColor(249, 246, 242, 255)
	Renderer.DrawText(font2, menu_posx + 150 ,menu_posy + 60  , score) 

	--Draw exit button
	Renderer.SetDrawColor(0, 0, 0, 255)
	Renderer.DrawText(font3, menu_posx + 380, menu_posy + 5 , "X")
	if is_button_pressed_once(menu_posx + 380, menu_posy + 10,12,12) then
		Menu.SetEnabled(mg_2048_b, false, false)
	end

	-- Draw change pos button
	Renderer.SetDrawColor(0, 0, 0, 255)
	Renderer.DrawOutlineRect(menu_posx + 1, menu_posy + 1, 24, 24)
	Renderer.DrawOutlineRect(menu_posx + 4,  menu_posy + 4, 18, 18)
	Renderer.DrawOutlineRect(menu_posx + 7, menu_posy + 7, 12, 12)
	Renderer.DrawOutlineRect(menu_posx + 10, menu_posy + 10, 6, 6)

	if is_button_down(menu_posx, menu_posy, 24, 24) then
		menu_posx, menu_posy = Input.GetCursorPos()
		menu_posx = menu_posx - 10
		menu_posy = menu_posy - 10
		Config.WriteInt("mini_games", "menu_posx", menu_posx)
		Config.WriteInt("mini_games", "menu_posy", menu_posy)
	end

	-- new game button
	Renderer.SetDrawColor(143, 122, 102, 255)
	Renderer.DrawFilledRect(menu_posx + 280, menu_posy + 90, 100, 40)

	Renderer.SetDrawColor(249, 246, 242, 255)
	Renderer.DrawText(font2, menu_posx + 283 , menu_posy + 100 , "New Game") 

	if is_button_pressed_once(menu_posx + 280,menu_posy + 90,100,40) then
		init_new_game(4,4)
		score = 0
	end
	

	 -- second sloy
	Renderer.SetDrawColor(185, 173, 157, 255)
	Renderer.DrawFilledRect(menu_posx, menu_posy + 150, 400, 400)




	-- draw number boxes
	for i = 1, 4 do
		for j = 1, 4 do
			if array_mg[j][i] == 2 then
				Renderer.SetDrawColor(238, 228, 218, 255)
			elseif array_mg[j][i] == 4 then
				Renderer.SetDrawColor(238, 225, 201, 255)
			elseif array_mg[j][i] == 8 then
				Renderer.SetDrawColor(243, 178, 122, 255)
			elseif array_mg[j][i] == 16 then
				Renderer.SetDrawColor(246, 151, 100, 255)
			elseif array_mg[j][i] == 32 then
				Renderer.SetDrawColor(246, 126, 95, 255)
			elseif array_mg[j][i] == 64 then
				Renderer.SetDrawColor(247, 95, 59, 255)
			elseif array_mg[j][i] == 128 then
				Renderer.SetDrawColor(237, 208, 115, 255)
			elseif array_mg[j][i] == 256 then
				Renderer.SetDrawColor(237, 204, 97, 255)
			elseif array_mg[j][i] == 512 then
				Renderer.SetDrawColor(237, 200, 80, 255)
			elseif array_mg[j][i] == 1024 then
				Renderer.SetDrawColor(237, 197, 63, 255)
			elseif array_mg[j][i] == 2048 then
				Renderer.SetDrawColor(237, 194, 46, 255)
			elseif array_mg[j][i] > 2048 then
				Renderer.SetDrawColor(170, 96, 166, 255)
			else
				Renderer.SetDrawColor(205, 193, 180, 255)
			end
			
			Renderer.DrawFilledRect(menu_posx-80+j*80+j*16, menu_posy + 70 + i*16 + i*80, 80, 80)
		end
	end

-- draw numbers  on game table
	for i = 1, 4 do
	    for j = 1, 4 do
	        if array_mg[j][i] <= 4 then
	            Renderer.SetDrawColor(119, 110, 101, 255)
	        else
	            Renderer.SetDrawColor(249, 246, 242, 255)
	        end
	
	        
	        local w_rect = 80
	        local h_rect = 80
	        local x_rect = menu_posx-80+j*80+j*16 + w_rect*0.5
	        local y_rect = menu_posy+70+i*16+i*80 + h_rect*0.5
	        
	       
			if array_mg[j][i] < 100 and array_mg[j][i] ~= 0 then
				local w,h = Renderer.GetTextSize(font, array_mg[j][i])
				Renderer.DrawText(font, x_rect - w*0.5, y_rect - h*0.5, array_mg[j][i])
			elseif array_mg[j][i] < 1000 and array_mg[j][i] ~= 0 then
				local w,h = Renderer.GetTextSize(font4, array_mg[j][i])
				Renderer.DrawText(font4, x_rect - w*0.5, y_rect - h*0.5, array_mg[j][i])
			elseif array_mg[j][i] < 10000 and array_mg[j][i] ~= 0 then
				local w,h = Renderer.GetTextSize(font5, array_mg[j][i])
				Renderer.DrawText(font5, x_rect - w*0.5, y_rect - h*0.5, array_mg[j][i])
			elseif array_mg[j][i] < 100000 and array_mg[j][i] ~= 0 then
				local w,h = Renderer.GetTextSize(font6, array_mg[j][i])
				Renderer.DrawText(font6, x_rect - w*0.5, y_rect - h*0.5, array_mg[j][i])
			elseif array_mg[j][i] < 1000000 and array_mg[j][i] ~= 0 then
				local w,h = Renderer.GetTextSize(font7, array_mg[j][i])
				Renderer.DrawText(font7, x_rect - w*0.5, y_rect - h*0.5, array_mg[j][i])
			end
	    end
	end

	--game over render window
	if game_over_b then 
		Renderer.SetDrawColor(54, 122, 249, 150)
		Renderer.DrawFilledRect(menu_posx + 50 , menu_posy + 200, 300, 150)
		Renderer.SetDrawColor(0, 0, 0, 255)
		Renderer.DrawText(font, menu_posx + 50 , menu_posy + 240 , "Game Over")
	end

end


function mg_2048.OnFrame()

	if not Menu.IsEnabled(mg_2048_b) then
		return
	end
	
	--draw game table
	draw_game_table()
	-- game steps (is button down)
	game_step(array_mg)

end



return mg_2048