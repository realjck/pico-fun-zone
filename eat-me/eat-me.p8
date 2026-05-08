pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--eat-me
--by real

local state=0
--0:title, 1:game, 2:interlevel
--3:end

local m_size=960--map size
--multiple of 48,40,32

local level--game level 1-5

local colors={
{11,3},{10,9},{8,2},
{12,5},{9,4},{13,2}
}


local levels_count
={4,8,12,14,16,18,20}

local player, balls,
dust, game_win_t, game_lose_t,
title_select, end_t, game_total_t,
game_total_eaten

function _init()
	if state==0 then
		title_init()
	elseif state==1 then
		level=1
		game_init()
	elseif state==2 then
		level=0
		game_init()
		interlevel_init()
	elseif state==3 then
		level=0
		game_init()
		end_init()
	end
end

function _update60()
	if state==0 then
		title_update()
	elseif state==1 then
		game_update()
	elseif state==2 then
		interlevel_update()
	elseif state==3 then
		end_update()
	end
end

function _draw()
	if state==0 then
		title_draw()
	elseif state==1 then
		game_draw()
	elseif state==2 then
		interlevel_draw()
	elseif state==3 then
		end_draw()
	end
end
-->8
--title

local title_t
local title_eye_t

function title_init()
	stars_init()
	title_t=0
	title_eye_t=0
	title_select=1
end

function title_update()
	stars_update()
	if title_t<=80 then
		title_t+=1
	end
	if title_eye_t==0 then
		if rnd()<1/200 then
			title_eye_t=20
		end
	else
		title_eye_t-=1
	end
	if btnp(❎) or btnp(🅾️) then
		if title_select==1 then
			level=0
			game_total_t=0
			game_total_eaten=0
			game_init()
			interlevel_init()
			player.lifes=3
			state=2
		else
			
		end
	end
	if btnp(⬆️) or btnp(⬇️) then
		sfx(0)
		if title_select==1 then
			title_select=2
		else
			title_select=1
		end
	end
end

function title_draw()
	cls(0)
	stars_draw()
	draw_ball_single(64,170+80-title_t,
	120,1)
	--title
	palt(11,true)
	palt(0,false)
	if title_select==1 then
		sspr(0,0,85,73,24,4-(80-title_t))
	else
		sspr(1,73,101,55,14,12-(80-title_t))
	end
	if title_t>=80 and title_eye_t>0 then
		rectfill(0,92,128,128,11)
	end
	--texts
	if title_select==1 then
		print_o("start game",46,84,7)
		print("about",56,94,2)
	else
		print("start game",46,84,2)
		print_o("about",56,94,7)
	end
end
-->8
--game

local game_t

function game_init()
	game_t=0
	game_win_t=0
	game_lose_t=0
	--dust
	dust={}
	--player
	if not player then
		player={
			x=0,
			y=0,
			sx=0,--speed x
			sy=0,--speed y
			et=0,--eyes timer
			r=8,--radius
			coli=1+flr(rnd()*#colors),--colorindex
			collision_t=0,--collision timer
			life=100,
			lifes=3
		}
	else
		player.x=0
		player.y=0
		player.sx=0
		player.sy=0
		player.r=8
		player.collision_t=0
		player.life=100
	end
	--other balls
	balls={}
	for i=1,100 do
		local ball={
			x=64+rnd()*(m_size-128),
			y=64+rnd()*(m_size-128),
			sx=-1.5+rnd()*3,
			sy=-1.5+rnd()*3,
			et=0,
			coli=1+flr(rnd()*#colors),
			r=4+rnd(4)
		}
		add(balls,ball)
	end
end

--update
--------------------------
function game_update()
	game_total_t+=0.1
	game_t+=1
	--win timer
	if game_win_t>0 then
		game_win_t-=1
		if game_win_t==0 then
			if count_size()==100 then
				end_init()
				state=3
			else
				interlevel_init()
				state=2
			end
			return--quit the function
		end
	end
	--lose timer
	if game_lose_t>0 then
		game_lose_t-=1
		if player.lifes==0
		and game_lose_t==1 then
			--game over
			end_init()
			state=3
			return--quit the function
		elseif game_lose_t==1 then
			player.collision_t=0
			player.life=100
		end
	end
	--dust
	for d in all(dust) do
		d:update()
	end
	--player life decrease automatic
	player.life-=0.025
	if player.life<0 then
		lose_game()
	end
	--close eyes
	if player.et==0 then
		if rnd()<1/200 then
			player.et=20
		end
	end
	if player.et>0 then
		player.et-=1
	end
	for b in all (balls) do
		if b.et==0 then
			if rnd()<1/200 then
				b.et=20
				--grow by itself randomly here
				b.r+=1
			end
		end
		if b.et>0 then
			b.et-=1
		end
	end
	--collision_t
	if player.collision_t>0 then
		player.collision_t-=1
	end
	--movement
	if game_lose_t==0 and game_win_t==0 then
		local inc=0.2
		local vmax=1.5
		local is_press=false
		if btn(⬅️) then
			player.sx-=inc
			is_press=true
			if player.sx<=-vmax then
				player.sx=-vmax
			end
		end
		if btn(➡️) then
			player.sx+=inc
			is_press=true
			if player.sx>=vmax then
				player.sx=vmax
			end
		end
		if btn(⬆️) then
			player.sy-=inc
			is_press=true
			if player.sy<=-vmax then
				player.sy=-vmax
			end
		end
		if btn(⬇️) then
			player.sy+=inc
			is_press=true
			if player.sy>=vmax then
				player.sy=vmax
			end
		end
	end
	--player
	player.x+=player.sx
	player.y+=player.sy
	if not is_press then
		player.sx=player.sx/1.05
		player.sy=player.sy/1.05
		--life decrease when not moving
		player.life-=0.075
		if player.life<0 then
			lose_game()
		end
	end
	if player.x<0 then
		player.x=m_size
	elseif player.x>m_size then
		player.x=0
	end
	if player.y<0 then
		player.y=m_size
	elseif player.y>m_size then
		player.y=0
	end
	--balls
	if game_win_t==0 then
		for ball in all (balls) do
			ball.x+=ball.sx
			ball.y+=ball.sy
			--speed at 2 max
			if ball.sx<-2 then
				ball.sx+=0.02
			elseif ball.sx>2 then
				ball.sx-=0.02
			end
			if ball.sy<-2 then
				ball.sy+=0.02
			elseif ball.sy>2 then
				ball.sy-=0.02
			end
			--ball position
			if ball.x<0 then
				ball.x=m_size
			elseif ball.x>m_size then
				ball.x=0
			end
			if ball.y<0 then
				ball.y=m_size
			elseif ball.y>m_size then
				ball.y=0
			end
			--collisions
			if game_win_t==0 and game_lose_t==0 then
				for x=-m_size+ball.x,m_size+ball.x,m_size do
					for y=-m_size+ball.y,m_size+ball.y,m_size do
						if distance(player.x,player.y,x,y)
						<player.r+ball.r then
							--if smaller, collision
							if ball.r<player.r then
								sfx(0)
								player.sx,player.sy,ball.sx,ball.sy
								=collision_response(
									player.x,player.y,
									player.sx,player.sy,
									x,y,
									ball.sx,ball.sy,
									player.r,
									ball.r
								)
								if player.collision_t==0 then
									ball.r+=3
									--player.r+=0.1
									player.collision_t=20
									player.life-=17
									if player.life<0 then
										lose_game()
									end
								end
							else
								--if bigger, be eaten
								if player.collision_t==0 then
								
									for j=0,100 do
										add_new_dust(player.x,player.y,
										rnd(4)-2,rnd(4)-2,25,rnd(player.r)+1,0,
									{
									colors[player.coli][2],
									colors[player.coli][1]},7)
									end
								
									player.coli=ball.coli
									player.r=ball.r
									del(balls,ball)
									sfx(1)
									player.life=100
									game_total_eaten+=1
									
									if player.r>=8+levels_count[level] then
										--win level
										player.r=8+levels_count[level]
										--interlevel_init()
										--state=2
										game_win_t=60--timer before interlevel
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function lose_game()
	if game_lose_t==0 then
		sfx(4)
		game_lose_t=120
		player.lifes-=1
		for j=0,100 do
			add_new_dust(player.x,player.y,
			rnd(4)-2,rnd(4)-2,25,rnd(player.r)+1,0,
			{colors[player.coli][2],
				colors[player.coli][1]},7)
		end
	end
end

function distance(x1, y1, x2, y2)
	local dx = abs(x2 - x1)
	local dy = abs(y2 - y1)
	return max(dx, dy) + min(dx, dy) * 0.4142
end

function collision_response(ax, ay, asx, asy, bx, by, bsx, bsy, ma, mb)
 local nx, ny = bx - ax, by - ay
 local distance=distance(ax,ay,bx,by)
 
 if distance == 0 then return asx, asy, bsx, bsy end
 nx, ny = nx/distance, ny/distance

 --relative speed
 local relative_velocity = (bsx - asx) * nx + (bsy - asy) * ny

 if relative_velocity < 0 then
  --coefficient (0.0-1.0)
  local restitution = 1.0
  local power = 1.5
  local impulse = power * -(1 + restitution) * relative_velocity / (ma + mb)
  asx = asx - impulse * mb * nx
  asy = asy - impulse * mb * ny
  bsx = bsx + impulse * ma * nx
  bsy = bsy + impulse * ma * ny
 end

 return asx, asy, bsx, bsy
end

--draw
--------------------------
function game_draw()
	cls(0)
	camera(player.x-64+player.sx*4,
	player.y-64+player.sy*4)
	--damier
	local dam_res=96-(level-1)*16
	if level==6 then
		dam_res=16
	elseif level==7 then
		dam_res=8
	end
	for i=player.x-80 - player.x%dam_res,
	player.x+80,dam_res do
		for j=player.y-80 - player.y%dam_res,
		player.y+80,dam_res do
			rectfill(i, j, i+dam_res/2-1, j+dam_res/2-1,
			1)
			rectfill(i+dam_res/2, j+dam_res/2,
			i+dam_res-1, j+dam_res-1,
			1)
		end
	end
	--balls
	for ball in all (balls) do
		if distance(player.x,player.y,
		ball.x-m_size,ball.y-m_size) < 100
		or distance(player.x,player.y,
		ball.x-m_size,ball.y) < 100
		or distance(player.x,player.y,
		ball.x-m_size,ball.y+m_size) < 100
		
		or distance(player.x,player.y,
		ball.x,ball.y-m_size) < 100
		or distance(player.x,player.y,
		ball.x,ball.y) < 100
		or distance(player.x,player.y,
		ball.x,ball.y+m_size) < 100
		
		or distance(player.x,player.y,
		ball.x+m_size,ball.y-m_size) < 100
		or distance(player.x,player.y,
		ball.x+m_size,ball.y) < 100
		or distance(player.x,player.y,
		ball.x+m_size,ball.y+m_size) < 100
	
		then
			draw_ball(ball)
		end
	end
	
	--player
	if game_lose_t==0 then
		draw_ball(player)
	end
	
	--dust
	for d in all(dust) do
		d:draw()
	end
	
	--goal
	if game_t<250 then
		if game_t%50<25 then
			print_o("goal: size "
			..count_size()+levels_count[level]
			.."%",player.x-26+player.sx*4,
			player.y+30+player.sy*4,7)
		end
	end
	
	--ui
	camera(0,0)
	rectfill(0,119,127,127,
	colors[player.coli][1])
	print("life",2,121,
	colors[player.coli][2])
	print("size",96,121,
	colors[player.coli][2])
	local end_life=19+0.75*player.life
	if player.life>0 then
		rectfill(19,122,end_life,124,0)
	end
	print(count_size().."%",114,121,0)
	--lifes
	local posx=112
	for i=1,player.lifes do
		spr(11,posx,3,2,2)
		posx-=14
	end
end

--return the size + levels points
function count_size()
	local i
	local s=0
	for i=1,level-1 do
		s+=levels_count[i]
	end
	s+=player.r
	return flr(s)
end

--draw ball()
function draw_ball(ball)
	--draw x9
	function draw_one(x,y)
		--shadow
		circfill(x,y+2,ball.r,0)
		--ball
		circfill(x,y,ball.r,
		colors[ball.coli][1])
		circ(x,y,ball.r,
		colors[ball.coli][2])
		--eyes
		if ball.et==0 then
			circfill(x-ball.r/3,
			y-ball.r/3,ball.r/4,7)
			circfill(x+ball.r/3,
			y-ball.r/3,ball.r/4,7)
			circfill(x-ball.r/3,
			y-ball.r/3,ball.r/8,5)
			circfill(x+ball.r/3,
			y-ball.r/3,ball.r/8,5)
		end
	end
	--draw x9
	draw_one(ball.x-m_size,ball.y-m_size)
	draw_one(ball.x-m_size,ball.y)
	draw_one(ball.x-m_size,ball.y+m_size)
	
	draw_one(ball.x,ball.y-m_size)
	draw_one(ball.x,ball.y)
	draw_one(ball.x,ball.y+m_size)
	
	draw_one(ball.x+m_size,ball.y-m_size)
	draw_one(ball.x+m_size,ball.y)
	draw_one(ball.x+m_size,ball.y+m_size)
end

function draw_ball_single(x,y,r,coli)
	--shadow
		circfill(x,y+2,r,0)
		--ball
		circfill(x,y,r,
		colors[coli][1])
		circ(x,y,r,
		colors[coli][2])
		--eyes
		circfill(x-r/3,
		y-r/3,r/4,7)
		circfill(x+r/3,
		y-r/3,r/4,7)
		circfill(x-r/3,
		y-r/3,r/8,5)
		circfill(x+r/3,
		y-r/3,r/8,5)
end
-->8
--interlevel

local interlevel_t--timer

function interlevel_init()
	music(0)
	interlevel_t=200
	stars_init()
end

function interlevel_update()
	stars_update()
	interlevel_t-=1
	if interlevel_t==0 then
		--increase level & back to game
		level+=1
		game_init()
		state=1
	end
end

function interlevel_draw()
	cls(0)
	camera()
	if level==0 then
		stars_draw()
	else
		--damier
		local dam_res=96-(level-1)*16
		if level==6 then
			dam_res=16
		elseif level==7 then
			dam_res=8
		end
		for i=64-80 - 64%dam_res,
		64+80,dam_res do
			for j=64-80 - 64%dam_res,
			64+80,dam_res do
				rectfill(i, j, i+dam_res/2-1, j+dam_res/2-1,
				1)
				rectfill(i+dam_res/2, j+dam_res/2,
				i+dam_res-1, j+dam_res-1,
				1)
			end
		end
	end
	draw_ball_single(64,64,
	8+(175-interlevel_t),
	player.coli)
	if level==0 then
		print_o("you enter level "
		..level+1,32,80,7)
	else
		print_o("you reached level "
		..level+1,28,80,7)
	end
	
	local txt_size="size "
	..count_size().."%"
	print_o(txt_size,
	64-#txt_size*2,92,
	colors[player.coli][1])
end
-->8
--stars

local stars
local max_stars=30

function stars_init()
	stars={}
	for i=1,max_stars do
		add_star()
	end
end

function add_star()
	local star={
		x=flr(rnd(128)),
		y=flr(rnd(128)),
		speed=rnd()<0.5 and 1 or 2
	}
	add(stars,star)
end

function stars_update()
	for star in all(stars) do
		star.y+=star.speed
		if (star.y>127) then
			star.x=flr(rnd(128))
			star.y=0
			star.speed=rnd()<0.5 and 1 or 2
		end
	end
end

function stars_draw()
	for star in all(stars) do
		pset(star.x,star.y,
		rnd()<0.5 and 5 or 6)
	end
end
-->8
--print with black outline

function print_o(txt,x,y,col)
	print(txt,x-1,y,0)
	print(txt,x+1,y,0)
	print(txt,x,y-1,0)
	print(txt,x,y+1,0)
	
	print(txt,x-1,y-1,0)
	print(txt,x-1,y+1,0)
	print(txt,x+1,y-1,0)
	print(txt,x+1,y+1,0)
	
	print(txt,x,y,col)
end
-->8
--particles system
--fully commentated version

function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
	add(dust, {
		fade=_f,
 	x=_x,
 	y=_y,
 	dx=_dx,
 	dy=_dy,
 	life=_l,
 	orig_life=_l,
 	rad=_s,
		col=0, --set to color
 	grav=_g,
 	draw=function(self)
 		--this function takes care
 		--of drawing the particle
 		
 		--clear the palette
 		--pal()
 		--palt(11)
 		
 		--draw the particle
 		circfill(self.x,self.y,self.rad,self.col)
 	end,
 	update=function(self)
 		--this is the update function
 		
 		--move the particle based on
 		--the speed
 		self.x+=self.dx
 		self.y+=self.dy
 		--and gravity
 		self.dy+=self.grav
 		
 		--reduce the radius
 		--this is set to 90%, but
 		--could be altered
 		self.rad*=0.9
 		
 		--reduce the life
 		self.life-=1
 		
 		--set the color
 		if type(self.fade)=="table" then
 			--assign color from fade
 			--this code works out how
 			--far through the lifespan
 			--the particle is and then
 			--selects the color from the
 			--table
		 	self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]
			else
				--just use a fixed color
				self.col=self.fade		 	
		 end
		 
		 --if the dust has exceeded
		 --its lifespan, delete it
		 --from the table
	 	if self.life<0 then
 			del(dust,self)
 		end
 	end
 })
end
-->8
--end

function end_init()
	stars_init()
	end_t=0
	if count_size()==100 then
		sfx(6)
	else
		sfx(5)
	end
end

function end_update()
	stars_update()
	end_t+=1
	if btnp(❎) or btn(🅾️) then
		title_init()
		state=0
	end
end

function end_draw()
	local iswin=count_size()==100
	and true or false
	
	if iswin then
		cls(1)
	else
		cls(0)
	end
	stars_draw()
	
	if end_t<120 then
		draw_ball_single(64,64,
		(120-end_t),
		player.coli)
	else
		if iswin then
			print_o("congratulations!",36,38,12)
		else
			--print_o("game over",48,38,12)
			palt(11,true)
			spr(43,30,34,5,2)
			spr(75,70,34,5,2)
		end
		print_o("statistics:",46,56,10)
		print_o("size:",32,66,14)
		print_o("time:",32,76,14)
		print_o("eaten:",32,86,14)
		print("....",52,66,2)
		print_o(count_size().."%",70,66,7)
		print("....",52,76,2)
		print_o(format_time(game_total_t),
		70,76,7)
		print("...",56,86,2)
		print_o(game_total_eaten.."x",
		70,86,7)
	end
	if iswin then
		if end_t%50 < 25 then
			print_o("thank you for playing!",
			25,104,12)
		end
	end
end

function format_time(counter)
  local total = flr(counter + 0.001)
  local minutes = flr(total / 600)
  local seconds = flr((total % 600) / 10)
  local ms = (total % 10) * 10

  return pad(minutes)..":"..pad(seconds)..":"..pad(ms)
end

function pad(n)
  if n < 10 then
    return "0"..n
  else
    return ""..n
  end
end
__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000bbb0000000000000bbbbbbbbbbbbbbbbbbbbbbbbb0000b0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb0000000000bbbbbb0aaaaaaaaaaaaaa00bb0aaaaaaaa000000000000bbbbbbbbbbbbbbbb00e80008800bbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb00000000000000aaaaaaaa0bbbbb00a777777777777a20bb0a77777777aaaaaaaa0000000000bbbbbbbb00e7e80888200bbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb0aaaaaaaaaa7777a7a77aa20bbbb0a7aaaaaaaaaaaaaa00b0a7aaaaaaaaaa77aa7aaaaaaaaa00bbbbbbb07ee888888820bbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb0a777777aaaaaaaaaaa7a2200bbb0a7aaaaaaaaaaaaaa2000a7aaaaaaaaaaaaaaaaaa7aaa7a00bbbbbbb07e8888888820bbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb0a7aaaaaaaaaaaaaaaaaa2220bb00a7aaaaaaaaaaaaaa2200a7aaaaaaaaaaaaaaaaaaaaaaaa200bbbbbb0ee8888888820bbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb0a7aaaaaaaaaaaaaaaaaa22200b0a7aaaaaaaaaaaaaaa2200aaaaaaaaaaaaaaaaaaaaaaaaaa220bbbbbb08e8888888820bbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb00a7aaaaaaaaaaaaaaaaaa22200b0a7aaaaaaaaaaaaaaaa200aaaaaaaaaaaaaaaaaaaaaaaaaa2200bbbbb0088888888200bbbbbbbbbbbbbbbbbbbbbbbbbbb
bb000aaaaaaaaaaaaaaaaaaa222200b0a7aaaaaaaaaaaaaaaa220aaaaaaaaaaaaaaaaaaaaaaaaaa2200bbbbbb00888888200bbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00a7aaaaaaaa22222222222222000a7aaaaaaaaaaaaaaaaa22002222222aaaaaaaaaaaaaaaaaa2200bbbbbbb008888200bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00a7aaaaaaaa22222222222222000aaaaaaaaa0aaaaaaaaa22202222222aaaaaaaaaa222aaaaa2200bbbbbbbb0088200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00aaaaaaaaaa22222222222222000aaaaaaaaa0aaaaaaaaaa2202222222aaaaaaaaaa222222222200bbbbbbbbb00200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00aaaaaaaaaa2220000000000000a7aaaaaaa000aaaaaaaaa22000000000aaaaaaaaa222222222200bbbbbbbbbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00aaaaaaaaa22000000000000000aaaaaaaaa0b0aaaaaaaaa22000000000aaaaaaaaa222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00aaaaaaaaaaaaaaaaaa20000000a7aaaaaaa0b0aaaaaaaaa2220b000000aaaaaaaaa222000222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00aaaaaaaaaaaaaaaaaa22000000aaaaaaaa00b0aaaaaaaaaa2200bbbb00aaaaaaaaaa22000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00aaaaaaaaaaaaaaaaaa220bbb0aaaaaaaaa0bb00aaaaaaaaa2200bbbbb0aaaaaaaaaa22000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000aaaaaaaaaaaaaaaaaa2200bb0aaaaaaaaa0b000aaaaaaaaa2200bbbbb0aaaaaaaaaa22000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00aaaaaaaaaaaaaaaaaaa22000b0aaaaaaaaa00000aaaaaaaaa2220bbbbb0aaaaaaaaaa22200000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00aaaaaaaaaaaaaaaaaa2220000aaaaaaaaaaaaaaaaaaaaaaaaa220bbbbb0aaaaaaaaaa22200bbbbbbbbbbbbbcccccc1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00aaaaaaaaaaa22222222220000aaaaaaaaaaaaaaaaaaaaaaaaa220bbbbb0aaaaaaaaaa22200bbbbbbbbbbbbccc1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00aaaaaaaaa2222222222220000aaaaaaaaaaaaaaaaaaaaaaaaa2200bbbb0aaaaaaaaaa22200bbbbbbbbbbbbccc1bbbbbcccccc1cccccccccc1bbccccc1bbbb
b00aaaaaaaaa222222222222000aaaaaaaaaaaaaaaaaaaaaaaaaa2220bbbb0aaaaaaaaaa22200bbbbbbbbbbbbccc1ccc1ccc1ccc1ccc1ccc1ccc1ccc1ccc1bbb
b00aaaaaaaaa222200000000000aaaaaaaaaaaaaaaaaaaaaaaaaaa220bbbb0aaaaaaaaaa22200bbbbbbbbbbbbccc1ccc1ccc1ccc1ccc1ccc1ccc1ccccccc1bbb
000aaaaaaaaa222000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaa2200bbb0aaaaaaaaaa22200bbbbbbbbbbbbccc1ccc1ccc1ccc1ccc1ccc1ccc1ccc1bbbbbbb
000aaaaaaaaa2000aaaaaaaa000aaaaaaaaaaaaaaaaaaaaaaaaaaa2220bbb0aaaaaaaaaa22200bbbbbbbbbbbbbcccccc1bcccccc1ccc1ccc1ccc1bcccccc1bbb
00aaaaaaaaaaaaaaaaaaaaaa20aaaaaaaaaa222222222aaaaaaaaa2220bbb0aaaaaaaaaa222000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaaaaaaaaaaaaaaaaaaa220aaaaaaaaa2222222222aaaaaaaaaa220bbb0aaaaaaaaaaa22000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaaaaaaaaaaaaaaaaaaa220aaaaaaaaa2222222222aaaaaaaaaa2200bb0aaaaaaaaaaa22000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaaaaaaaaaaaaaaaaaaa20aaaaaaaaaa22200000000aaaaaaaaa2220bb0aaaaaaaaaaa22000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaaaaaaaaaaaaaaaaaaa20aaaaaaaaaa22200000000aaaaaaaaaa220bb0aaaaaaaaaaa22000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaaaaaaaaaaaaaaaa222200222222222222000000002222222222220bb0aaaaaaaaaaa22000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaaaaaaaaaa2222222222200222222222220000000002222222222200b002222aaaaaa22000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00aaaaa2222222222222222222002222222222000bbbbbb0222222222200bb0222222222222000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00222222222222222222222222200222222220000bbbbbb0000000022220bbb022222222222000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0002222222222222222000000000000000000000000000bbb00000000000000000222222222000bbbbbbbbbbbbccccc1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000222222220000000000000000000000aaaaaaaaaaa00bb0aaaaaaaaa5000000000000000000bbbbbbbbbbbccc1ccc1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000000000000000aaaaaaaa000000000a77aaaaaaaaa20bb0a7777a7aaaaaaaaaaaaa00000000bbbbbbbbbbbccc1ccc1ccc1ccc1bccccc1bbccccc1bbbbbbbb
bbb0000000000aa77777777a00bbbbbb0a7aaaaaaaaaa200b0a7aaaaaaaaaaaaaaaaaa20000000bbbbbbbbbbbccc1ccc1ccc1ccc1ccc1ccc1ccc1bbbbbbbbbbb
bbbb000000000a7aaaaaaa7aa00bbbb0a7aaaaaaaaaaa220b0a7aaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbccc1ccc1ccc1ccc1ccccccc1ccc1bbbbbbbbbbb
bbbbb000000b07aaaaaaaaa7a20bbb00a7aaaaaaaaaaa22000a7aaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbccc1ccc1ccc1ccc1ccc1bbbbccc1bbbbbbbbbbb
bbbbbbbbbbb0a7aaaaaaaaa7aa20bb0a7aaaaaaaaaaaa22200aaaaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbccccc1bbccccc1bbcccccc1ccc1bbbbbbbbbbb
bbbbbbbbbbb0a7aaaaaaaaaaaa20000a7aaaaaaaaaaaa22200a7aaaaaaaaaaaaaaaaaa22000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb0a7aaaaaaaaaa7a2200a7aaaaaaaaaaaaa22200aaaaaaaaaa22aaaaaaaa22200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb0a7aaaaaaaaaaa7a200a7aaaaaaaaaaaaa22200aaaaaaaaaa222222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb0aaaaaaaaaaaaaaa20aaaaaaaaaaaaaaaa22200aaaaaaaaaa222222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb0a7aaaaaaaaaaaaaaa0aaaaaaaaaaaaaaaa22200aaaaaaaaaa222222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22200aaaaaaaaaa220000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22200aaaaaaaaaaaaaa00000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2200aaaaaaaaaaaaaaaaaa000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2200aaaaaaaaaaaaaaaaaa200000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb0aaaaaaaaaaaaaaaaaaaaaaaaa0aaaaaaaaaa2200aaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb0aaaaaaaaaaaaaaaaaaaaaaaa00aaaaaaaaaa2200aaaaaaaaaaaaaaaaaa22200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb0aaaaaaaaaa0aaaaaaaaaaaaa20aaaaaaaaaa2200aaaaaaaaaaaaaaaaaa22200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb00aaaaaaaaa20aaaaaaaaaaaa220aaaaaaaaaa2200aaaaaaaaaa2222aaaa22200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb00aaaaaaaaa200aaaaaaaaaaa222aaaaaaaaaa2200aaaaaaaaaa2222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb00aaaaaaaaa220aaaaaaaaaa2222aaaaaaaaaa2200aaaaaaaaaa2222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb00aaaaaaaaa2200aaaaaaaaa2220aaaaaaaaaa2200aaaaaaaaaa2200022222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0aaaaaaaaaa2220aaaaaaaa22220aaaaaaaaaa2200aaaaaaaaaa2220000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb00aaaaaaaaaa22000aaaaaa222200aaaaaaaaaa2200aaaaaaaaaaaaaa000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb00aaaaaaaaa222000aaaaaa222200aaaaaaaaaa2200aaaaaaaaaaaaaaaaaaaaaa0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb00aaaaaaaaa2220000aaaa2222000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb00aaaaaaaaa2220000aaaa2220000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa2000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb00aaaaaaaaaa22200000aa22220000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb00aaaaaaaaaa222000b0aa22200000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb00aaaaaaaaaa22200bbb022220000022222222222220aaaaaaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb00aaaaaaaaaa22200bbb022200000002222222222220022222222222aaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb00aaaaa2222222200bbbb0220000bb002222222222200022222222222222222aaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb0022222222222200bbbbb0000000bbb002222222222000022222222222222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb0022222222222200bbbbb000000bbbbb00000000000000000000022222222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb002222222200000bbbbbb0000bbbbbbb000000000000bb00000000000022222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0000000000000bbbbbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbb00000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa20bbbbbbbbbbbbbbbbbbbbbbbbbbbb
b0aa7777777aa7777777777777777777777777777777777777777777777777777777777777777777777777777777777777a20bbbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111177717771111177717771777177717711111177711771111117717171777171717771717177711111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111171717111111171117171171171117171111117117171111171117171717171711711717171111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111177117711111177117771171177117171111117117171111177717171771171711711717177111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111171717111111171117171171171117171111117117171111111717171717177711711777171111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111177717771111177717171171177717171111117117711111177111771717117117771171177711111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111aaa1aaa1aaa11aa1a1a11111aa11aaa1aaa1a1a111111aa1aaa1aaa1aaa1111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111a1a1a111a1a1a111a1a111111a11a1a1a1a111a11111a1111a1111a1a111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111aa11aa11aaa1a111aaa111111a11a1a1a1a11a111111aaa11a111a11aa11111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111a1a1a111a1a1a111a1a111111a11a1a1a1a1a111111111a11a11a111a111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111a1a1aaa1a1a11aa1a1a11111aaa1aaa1aaa1a1a11111aa11aaa1aaa1aaa1111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111eee111111ee1eee1eee1eee11111eee1e1e11111eee1eee1eee1e1111111eee1e1e1eee11ee1eee1eee1111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111e1e11111e111e1e1eee1e1111111e1e1e1e11111e1e1e111e1e1e1111111e1e1e1e1e1e1e111e111e1e1111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111eee11111e111eee1e1e1ee111111ee11eee11111ee11ee11eee1e1111111ee11e1e1ee11e111ee11ee11111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111e1e11111e1e1e1e1e1e1e1111111e1e111e11111e1e1e111e1e1e1111111e1e1e1e1e1e1e1e1e111e1e1111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111e1e11111eee1e1e1e1e1eee11111eee1eee11111e1e1eee1e1e1eee11111eee11ee1e1e1eee1eee1e1e1111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a111111eee11ee1eee11111eee1e1e1eee11111eee1eee1ee11eee11111eee1eee1eee11111ee11eee1e111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a111111e111e1e1e1e111111e11e1e1e1111111eee11e11e1e11e1111111e11e1e1eee111111e11e1e1e1111e1111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a111111ee11e1e1ee1111111e11eee1ee111111e1e11e11e1e11e1111111e11eee1e1e111111e11eee1eee1111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a111111e111e1e1e1e111111e11e1e1e1111111e1e11e11e1e11e1111111e11e1e1e1e111111e11e1e1e1e11e1111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a111111e111ee11e1e111111e11e1e1eee11111e1e1eee1e1e1eee11111ee11e1e1e1e11111eee1eee1eee1111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a1111111111111111111111111111eee1e1e11ee1e111e1e1eee1eee11ee1ee111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a1111111111111111111111111111e111e1e1e1e1e111e1e11e111e11e1e1e1e11111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a1111dddddddddddddddddddddd11ee11e1e1e1e1e111e1e11e111e11e1e1e1e11dddddddddddddddddddddd11111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a1111111111111111111111111111e111eee1e1e1e111e1e11e111e11e1e1e1e11111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a1111111111111111111111111111eee11e11ee11eee11ee11e11eee1ee11e1e11111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a1111c1c1ccc1ccc1ccc1c111c1c1ccc1ccc11111ccc11cc11111ccc1ccc11cc11cc1ccc1ccc11cc11cc1c1c11111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a1111c1c1c111c1c11c11c111c1c1c1c1c11111111c11c1111111c1c1c1c1c1c1c111c1c1c111c111c111c1c11111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111cc11ccc11c11c111c1c1cc11cc1111111c11ccc11111ccc1cc11c1c1c111cc11cc11ccc1ccc111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111c111c1c11c11c111c1c1c1c1c11111111c1111c11111c111c1c1c1c1c1c1c1c1c11111c111c111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111c111c1c1ccc1ccc11cc1c1c1ccc11111ccc1cc111111c111c1c1cc11ccc1c1c1ccc1cc11cc1111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7a11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0a7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa200bbbbbbbbbbbbbbbbbbbbbbbbbb
b0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa200bbbbbbbbbbbbbbbbbbbbbbbbbb
bb0222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222000bbbbbbbbbbbbbbbbbbbbbbbbbb
bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbb
__label__
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa00000aaaaaaaa00000000000000000000000000000000000000000000000
00000000000000000000000000000000000000aaaaaaaa00000000a777777777777a20000a77777777aaaaaaaa00000000000000000000000000000000000000
0000000000000000000000000aaaaaaaaaa7777a7a77aa2000000a7aaaaaaaaaaaaaa0000a7aaaaaaaaaa77aa7aaaaaaaaa00000000000000600000000000000
0000000000000000000000000a777777aaaaaaaaaaa7a22000000a7aaaaaaaaaaaaaa2000a7aaaaaaaaaaaaaaaaaa7aaa7a00000000000000000000000000000
0000000000000000000000000a7aaaaaaaaaaaaaaaaaa22200000a7aaaaaaaaaaaaaa2200a7aaaaaaaaaaaaaaaaaaaaaaaa20000000000000000000000000000
0000000000000000000000000a7aaaaaaaaaaaaaaaaaa2220000a7aaaaaaaaaaaaaaa2200aaaaaaaaaaaaaaaaaaaaaaaaaa22000000000000000000000000000
0000000000000000000000000a7aaaaaaaaaaaaaaaaaa2220000a7aaaaaaaaaaaaaaaa200aaaaaaaaaaaaaaaaaaaaaaaaaa22000000000000000000000000000
0000000000000000000000000aaaaaaaaaaaaaaaaaaa22220000a7aaaaaaaaaaaaaaaa220aaaaaaaaaaaaaaaaaaaaaaaaaa22000000000000000000000000000
000000000000000000000000a7aaaaaaaa22222222222222000a7aaaaaaaaaaaaaaaaa22002222222aaaaaaaaaaaaaaaaaa22000000000000000000000000000
000000000000000000000000a7aaaaaaaa22222222222222000aaaaaaaaa0aaaaaaaaa22202222222aaaaaaaaaa222aaaaa22000000000000000000000000000
000000000000000000000000aaaaaaaaaa22222222222222000aaaaaaaaa0aaaaaaaaaa2202222222aaaaaaaaaa2222222222000000000000000000000000000
000000000000000000000000aaaaaaaaaa2220000000000000a7aaaaaaa000aaaaaaaaa22000000000aaaaaaaaa2222222222000000000000000000000000000
000000000000000000000000aaaaaaaaa22000000000000000aaaaaaaaa000aaaaaaaaa22000000000aaaaaaaaa2222222222000000000000000000000000000
000000000000000000000000aaaaaaaaaaaaaaaaaa20000000a7aaaaaaa000aaaaaaaaa22200000000aaaaaaaaa2220002222000000000000000000000000000
000000000000000000000000aaaaaaaaaaaaaaaaaa22000000aaaaaaaa0000aaaaaaaaaa2200000000aaaaaaaaaa220000000000000000000000000000000000
000000000000000000000000aaaaaaaaaaaaaaaaaa2200000aaaaaaaaa00000aaaaaaaaa2200000000aaaaaaaaaa220000000000000000000006000000000000
000000000000000000000000aaaaaaaaaaaaaaaaaa2200000aaaaaaaaa00000aaaaaaaaa2200000000aaaaaaaaaa220000000000000000000000000000000000
00000000000000000000000aaaaaaaaaaaaaaaaaaa2200000aaaaaaaaa00000aaaaaaaaa2220000000aaaaaaaaaa222000000000000000000000000000000000
00000000000000000000000aaaaaaaaaaaaaaaaaa2220000aaaaaaaaaaaaaaaaaaaaaaaaa220000000aaaaaaaaaa222000000000000000000000000000000000
00000000000000000000000aaaaaaaaaaa22222222220000aaaaaaaaaaaaaaaaaaaaaaaaa220000000aaaaaaaaaa222000000000000000000000000000000000
00000000000000000000000aaaaaaaaa2222222222220000aaaaaaaaaaaaaaaaaaaaaaaaa220000000aaaaaaaaaa222000000000000000000000000000000000
00000000000000000000000aaaaaaaaa222222222222000aaaaaaaaaaaaaaaaaaaaaaaaaa222000000aaaaaaaaaa222000000000000000000000000000000000
00000000000000000000000aaaaaaaaa222200000000000aaaaaaaaaaaaaaaaaaaaaaaaaaa22000000aaaaaaaaaa222000000000000000000000000000000000
00000000000000000000000aaaaaaaaa222000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaa22000000aaaaaaaaaa222000000000000000000000000000000000
00000050000000000000000aaaaaaaaa2000aaaaaaaa000aaaaaaaaaaaaaaaaaaaaaaaaaaa22200000aaaaaaaaaa222000000000000000000000000000000000
0000000000000000000000aaaaaaaaaaaaaaaaaaaaaa20aaaaaaaaaa222222222aaaaaaaaa22200000aaaaaaaaaa222000000000000000000000000000000000
0000000000000000000000aaaaaaaaaaaaaaaaaaaaa220aaaaaaaaa2222222222aaaaaaaaaa2200000aaaaaaaaaaa22000000000000000000000000000000000
0000000000000000000000aaaaaaaaaaaaaaaaaaaaa220aaaaaaaaa2222222222aaaaaaaaaa2200000aaaaaaaaaaa22000000000000000000000000000000000
0000000000000000000000aaaaaaaaaaaaaaaaaaaaa20aaaaaaaaaa22200000000aaaaaaaaa2220000aaaaaaaaaaa22000000000000000000000000000000000
0000000000000000000000aaaaaaaaaaaaaaaaaaaaa20aaaaaaaaaa22200000000aaaaaaaaaa220000aaaaaaaaaaa22000000000000000000000000000000000
0000000000000000000000aaaaaaaaaaaaaaaaaa222200222222222222000000002222222222220000aaaaaaaaaaa22000000000000000000000000000000000
0000000000000000000000aaaaaaaaaaaa22222222222002222222222200000000022222222222000002222aaaaaa22000000000000000000000000000000000
0000000000000000000000aaaaa22222222222222222220022222222220000000000222222222200000222222222222000000000000000000000000000000000
00000000000000000000002222222222222222222222222002222222200000000000000000022220000022222222222000000000000000000000000000000000
00000000000000000000000222222222222222200000000000000000000000000000000000000000000000222222222000000000000000000000000000000000
000000000000000000000000222222220000000000000000000000aaaaaaaaaaa00000aaaaaaaaa5000000000000000000000000000000000000000000000000
000006000000000000000000000000000000aaaaaaaa000000000a77aaaaaaaaa20000a7777a7aaaaaaaaaaaaa00000000000000000000000000000000000000
000000000000000000000000000000000aa77777777a000000000a7aaaaaaaaaa20000a7aaaaaaaaaaaaaaaaaa20000000000000000000000000000000000000
000000000000000000000000000000000a7aaaaaaa7aa0000000a7aaaaaaaaaaa22000a7aaaaaaaaaaaaaaaaaa22000000000000000000000000000000000000
0000000000000000000000000000000007aaaaaaaaa7a2000000a7aaaaaaaaaaa22000a7aaaaaaaaaaaaaaaaaa22000000000000000000000000000000000000
00000000000000000000000000000000a7aaaaaaaaa7aa20000a7aaaaaaaaaaaa22200aaaaaaaaaaaaaaaaaaaa22000000000000000000000000000000000000
00000000000000000000000000000000a7aaaaaaaaaaaa20000a7aaaaaaaaaaaa22200a7aaaaaaaaaaaaaaaaaa22000000000000000000000000000000000000
00000000000000000000000000000000a7aaaaaaaaaa7a2200a7aaaaaaaaaaaaa22200aaaaaaaaaa22aaaaaaaa22200000000000000000000000000000000000
00000000000000000000000000000000a7aaaaaaaaaaa7a200a7aaaaaaaaaaaaa22200aaaaaaaaaa222222222222200000000000000000000000000000000000
00000000000000000000000000000000aaaaaaaaaaaaaaa20aaaaaaaaaaaaaaaa22200aaaaaaaaaa222222222222200000000000000000000000000000000000
0000000000000000000000000000000a7aaaaaaaaaaaaaaa0aaaaaaaaaaaaaaaa22200aaaaaaaaaa222222222222200000000000000000000000000000000000
0000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22200aaaaaaaaaa220000000000000000000000000000000000000000000000
0000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22200aaaaaaaaaaaaaa00000000000330000000000000000000000000000000
0000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2200aaaaaaaaaaaaaaaaaa000000bbb3330000000000000000000000000000
0000000000000000000000000033300aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2200aaaaaaaaaaaaaaaaaa200000bbbbbb3330000000000000000000000000
00000000000000000000000333bbb0aaaaaaaaaaaaaaaaaaaaaaaaa0aaaaaaaaaa2200aaaaaaaaaaaaaaaaaa2200bbbbbbbbbbb3330000000000000000000000
00000000000000000000333bbbbbb0aaaaaaaaaaaaaaaaaaaaaaaa00aaaaaaaaaa2200aaaaaaaaaaaaaaaaaa22200bbbbbbbbbbbbb3330000000000000000000
00000000000000000033bbbbbbbbb0aaaaaaaaaa0aaaaaaaaaaaaa20aaaaaaaaaa2200aaaaaaaaaaaaaaaaaa22200bbbbbbbbbbbbbbbb3300000000000000000
000000000000000333bbbbbbbbbb00aaaaaaaaa20aaaaaaaaaaaa220aaaaaaaaaa2200aaaaaaaaaa2222aaaa22200bbbbbbbbbbbbbbbbbb33300000000000000
000000000000033bbbbbbbbbbbbb00aaaaaaaaa200aaaaaaaaaaa222aaaaaaaaaa2200aaaaaaaaaa2222222222200bbbbbbbbbbbbbbbbbbbbb33000000000000
0000000000033bbbbbbbbbbbbbbb00aaaaaaaaa220aaaaaaaaaa2222aaaaaaaaaa2200aaaaaaaaaa2222222222200bbbbbbbbbbbbbbbbbbbbbbb330000000000
00000000033bbbbbbbbbbbbbbbbb00aaaaaaaaa2200aaaaaaaaa2220aaaaaaaaaa2200aaaaaaaaaa2200022222200bbbbbbbbbbbbbbbbbbbbbbbbb3300000000
000000033bbbbbbbbbbbbbbbbbbb0aaaaaaaaaa2220aaaaaaaa22220aaaaaaaaaa2200aaaaaaaaaa2220000000000bbbbbbbbbbbbbbbbbbbbbbbbbbb33000000
0000003bbbbbbbbbbbbbbbbbbbb00aaaaaaaaaa22000aaaaaa222200aaaaaaaaaa2200aaaaaaaaaaaaaa000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000
000033bbbbbbbbbbbbbbbbbbbbb00aaaaaaaaa222000aaaaaa222200aaaaaaaaaa2200aaaaaaaaaaaaaaaaaaaaaa0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33000
0033bbbbbbbbbbbbbbbbbbbbbbb00aaaaaaaaa2220000aaaa2222000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb330
33bbbbbbbbbbbbbbbbbbbbbbbbb00aaaaaaaaa2220000aaaa2220000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa2000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3
bbbbbbbbbbbbbbbbbbbbbbbbbb00aaaaaaaaaa22200000aa22220000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb00aaaaaaaaaa222000b0aa22200000aaaaaaaaaa2220aaaaaaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb00aaaaaaaaaa22200bbb022220000022222222222220aaaaaaaaaaaaaaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb00aaaaaaaaaa22200bbb022200000002222222222220022222222222aaaaaaaaaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb00aaaaa2222222200bbbb0220000bb002222222222200022222222222222222aaa2200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb0022222222222200bbbbb0000000bbb002222222222000022222222222222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb0022222222222200bbbbb000000bbbbb00000000000000000000022222222222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbb002222222200000bbbbbb0000bbbbbbb000000000000bb00000000000022222222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000bbbbbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbb00000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbb77777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777bbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbb7777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777777777777777777bbbbbbbbbbbbbb
bbbbbbbbbbbbb77777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777777777777777bbbbbbbbbbbb
bbbbbbbbbb77777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777777777777777777777bbbbbbbbb
bbbbbbbbb7777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777777777777777777777777777777bbbbbbbb
bbbbbbb77777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777777777777777777777777777bbbbbb
bbbbbb7777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777777777777777777777777777777777777bbbbb
bbbbb777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777777777777777777777bbbb
bbbb77777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777777777777777777777777777777777bbb
bbb7777777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777777777777777777777777777777777777777777bb
bb777777777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777777777777777777777777777b
b77777777777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777777777777777777777777777777777777777
7777777777777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777777777777777777777777777777777777777777777777
777777777777777777777555555577777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777777777777777555555577777777777777777777
7777777777777777775555555555555777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777555555555555577777777777777777
7777777777777777555555555555555557777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777755555555555555555777777777777777
7777777777777775555555555555555555777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777555555555555555555577777777777777
77777777777777555555555555555555555777777777777777777bbbbbbbbbbbbbbbbbbbbbbb7777777777777777775555555555555555555557777777777777
77777777777775555555555555555555555577777777777777777bbbbbbbbbbbbbbbbbbbbbbb7777777777777777755555555555555555555555777777777777
777777777777555555555555555555555555577777777777777777bbbbbbbbbbbbbbbbbbbbb77777777777777777555555555555555555555555577777777777
777777777775555555555555555555555555557777777777777777bbbbbbbbbbbbbbbbbbbbb77777777777777775555555555555555555555555557777777777
777777777775555555555555555555555555557777777777777777bbbbbbbbbbbbbbbbbbbbb77777777777777775555555555555555555555555557777777777
777777777755555555555555555555555555555777777777777777bbbbbbbbbbbbbbbbbbbbb77777777777777755555555555555555555555555555777777777
7777777777555555555555555555555555555557777777777777777bbbbbbbbbbbbbbbbbbb777777777777777755555555555555555555555555555777777777
7777777777555555555555555555555555555557777777777777777bbbbbbbbbbbbbbbbbbb777777777777777755555555555555555555555555555777777777
7777777775555555555555555555555555555555777777777777777bbbbbbbbbbbbbbbbbbb777777777777777555555555555555555555555555555577777777
7777777775555555555555555555555555555555777777777777777bbbbbbbbbbbbbbbbbbb777777777777777555555555555555555555555555555577777777

__sfx__
000100001305012050110501105011050120501205014050170501a0501905016050120500e050080500605007050080500805008050060500305000050000000000000000000000000000000000000000000000
010200002305026040280402a0402c0402d0402f0402f040300403004030040300402f0302d0302b0302a0202702024020210201e0201a01017010130100f0100b01006010000100000000000000000100000000
001000001d0302003023030200301c0301c0301803018030210302103021030210300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001103011030100301003008030080301003010030110301103011030110300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003325032250302502f2502c2502b2502925027250242502325021250202501e2501c2501b250192501825016250152501325012250102500f2500d2500b2500a250092500725006250042500325001250
001000000e2500e2501225015250122500c2500c2500c250102501025010240102301023010220102101020000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000102501425015250162501b2501b2501b2501b250222502225014250162502425024250272502725022250222402224022240222302223022220222100000000000000000000000000000000000000000
__music__
04 02034344

