-- title:  Breackout
-- author: Rotfuchs-von-Vulpes
-- desc:   a litle game
-- script: lua

local score, t, num = 0, 0, 0
local bricks = {}

function newObj(x, y, w, h, color)
 
	local obj = {
	 x = x,
		y = y,
		w = w,
		h = h,
		color = color,
		draw = function(self)
		 rect(self.x, self.y, self.w, self.h, self.color)
		end,
		margin = function(self, x, y)
		
		 if
	 		x<0 or
	 		x+self.w>240 or
	 		y<0 or
	 		y+self.h>136
	 	then
	 	 return false
	 	else
		  return true
 		end
		
		end,
		collide = function(self, obj, x, y)

	 	if
	 	 x+self.w>=obj.x and
		  x<=obj.x+obj.w and
	 	 y<=obj.y+obj.h and
		  y+self.h>=obj.y
	 	then
	 	 return false
	 	else
	 	 return true
	 	end
		
	 end
	}
	return obj
	
end

local player = newObj(100, 120, 30, 2, 14)

local ball = newObj(98+player.w/2, 115, 4, 4, 13)
ball.dx, ball.dy = 1, 1
ball.fix = true
ball.brick = function(self, x, y)

 local resp = true
	
	--if self:collide(bricks[1][1], x, y) and self:collide(bricks[1][2], x, y) then resp = false end
 
	for i=1, #bricks do
  for j=1, #bricks[i] do
		 if bricks[i][j] ~= "meh" then
				if not self:collide(bricks[i][j], x, y) then
			  resp = false
				 bricks[i][j]:touch()
					break
			 end
			end
		end
	end

 return resp
	
end
ball.move = function(self)
	
	local tx, ty = self.x + self.dx, self.y + self.dy
	local dx, dy
	local lx, ly = self:collide(player, tx, self.y), self:collide(player, self.x, ty)
	local bx, by
		
	if self:brick(tx, self.y) and lx and self:margin(tx, self.y) then
		dx = true
	else
		self.dx = self.dx * -1
		dx = false
	end
	
	if self:brick(self.x, ty) and ly and self:margin(self.x, ty) then
		dy = true
	else
	 self.dy = self.dy * -1
		dy = false
	end
		
	if dx then self.x = tx else self.x = self.x + self.dx end
	if dy then self.y = ty else self.y = self.y + self.dy end
		
	if self.y >= 110 then num = 0 end
		
end

player.move = function(self, x)
	
	local tx = self.x + x
		
	if self:collide(ball, tx, self.y) and self:margin(tx, self.y) then
	 self.x = tx
		if ball.fix then
		 ball.x = ball.x + x
			if x>0 then
			 ball.dx = 1
			else
			 ball.dx = -1
			end
		end
	end
		
end

function create()
 for i=1, 7 do
	 bricks[i] = {}
	 for j=1, 7 do
		local n = math.random(11) + 1
		 bricks[i][j] = newObj((i-1)*30+15, j*10, 28, 8, n)
		 bricks[i][j].p = i
			bricks[i][j].q = j
			bricks[i][j].touch = function(self)
			 score = score + 2 ^ num
				num = num + 1
				bricks[self.p][self.q] = "meh"
			end
		end
	end
end

function empty()

 for i=1, #bricks do
	 for j=1, #bricks[i] do
	  if bricks[i][j]~="meh" then
		  return false
		 end
		end
	end
	
	gameReset()
	
	return true

end

function gameReset()

 player.x = 100
	ball.x, ball.y = 98 + player.w/2, 115
	ball.dx, ball.dy = 1, 1
	ball.fix = true
	num = 0
	create()

end

function gameOver()

 gameReset()
	score = 0
	
end

function draw()
 
	cls(16)
	player:draw()
	ball:draw()
	for i=1, #bricks do
	 for j=1, #bricks[i] do
		 if bricks[i][j]~="meh" then
			 bricks[i][j]:draw()
			end
		end
	end
	
	--[[
	for i=0, 240, 4 do
	 for j=0, 136, 4 do
		 local color = 3
		 if ball:brick(i, j) then color = 6 end
		 rect(i, j, 1, 1, color)
		end
	end
	]]
	
	print(score, 0, 0, 12)
	
end

function keyboard()

 
 if btn(2) then player:move(-2, 0) end
	if btn(3) then player:move(2, 0) end
	if btnp(4) then ball.fix = false end
 if btnp(5) then gameReset() end
 
	--[[
 if btn(0) then ball.y = ball.y - 1 end
	if btn(1) then ball.y = ball.y + 1 end
	if btn(2) then ball.x = ball.x - 1 end
 if btn(3) then ball.x = ball.x + 1 end
	ball:move()
	]]

end

gameReset()

function TIC()

 keyboard()
	draw()
	empty()
	
	if not ball.fix then ball:move() end
	
	if ball.y>130 then gameOver() end

	t=t+1
end
