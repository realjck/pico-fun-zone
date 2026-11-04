pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--ben's quest
--by real

--musics:
--intro:24 main:0 end:32
--sfx: 59 to 63

local debug

local is_title=0-- -1:game

local dialitems={
	
	{x=20,y=13,
	t={"\"welcome to west beach\""}},
	
	{x=13,y=14,id="religion",
	t={"* knock knock *",
	"- \"no thank you, i already\n  have a religion.\"",
	"..."},
	coins={"* knock knock *",
	"- \"oh! you look... wealthy.\"",
	"\"have you heard about\n our lord?\"",
	"\"he accepts donations.\"",
	"\"coins, mostly.\""}},

	--col gauche
	
	{x=6,y=39,
	t={"* dring *", "- ...","no one lives here."}},
	
	{x=6,y=31,id="disturb",
	t={"\"away,please don't disturb\"","..."},
	coins2={"\"away,please don't disturb\"",
	"* knock knock *","- \"what?!\"",
	"- \"oh, my parcel! finally.\"",
	"\"a rubber duck. 300 coins.\n worth it.\"",
	"\"want a real treasure?\n call 76321.\"",
	"\"the house for sale\n in the forest.\""},
	coins3={"\"away,please don't disturb\"",
	"- \"i said, don't disturb!\""}},
	
	{x=6,y=23,
	t={"\"for rent,contact lucy\""}},
	
	--col milieu
	
	{x=21,y=46,
	t={"\"port aurora.\n this way ⬆️\""}},
	
	{x=19,y=33,
	t={"\"welcome to port aurora\""}},
	
	{x=15,y=31,
	t={"* toc toc *","- ..."}},
	
	{x=15,y=23,id="dogdoor",
	t={"* dring *","- \"woof!\"","..."},
	pure2={"* dring *","- \"woof!\"",
	"- \"you want my dog?\n  take him, please!\"",
	"\"he eats my socks.\n all of them.\"",
	"* the dog follows you *"},
	pure3={"* dring *",
	"- \"no more socks eaten.\n  i'm so happy.\""},
	pure4={"* dring *",
	"- \"my dog got a job?\n  guarding coins?\"",
	"\"he can't even guard\n a sandwich.\""}},
	
	--col droite
	
	{x=30,y=31,
	t={"\"sequoia school\""}},
	
	{x=25,y=23,id="armory",
	t={"\"armory shop\"","weird."},
	pure1={"\"armory shop\"",
	"- \"a resignation letter?\"",
	"\"from my best guardian?\n 40 years without a break!\"",
	"\"fine. find me someone\n loyal and cheap.\"",
	"\"and not afraid of souls.\""},
	pure2={"\"loyal. cheap. no fear.\n off you go.\""}},
	
	{x=31,y=15,id="hotel",
	t={"\"port aurora grand hotel\"",
	"\"dogs not allowed\"","\"fully booked\""},
	coins1={"\"port aurora grand hotel\"",
	"- \"mister ben! such shiny\n  pockets!\"",
	"\"for you sir, the\n presidential suite.\"",
	"\"our bellboy has a little\n favor to ask.\"",
	"\"he's waiting for you on\n the hotel beach, out back.\""},
	coins={"\"port aurora grand hotel\"",
	"- \"welcome back, sir!\n  your suite is ready.\""},
	pure3={"\"port aurora grand hotel\"",
	"\"dogs not allowed\"",
	"* the dog looks at you *",
	"\"...especially that one.\""}},
	
	{x=40,y=8,id="port",
	t={"\"aurora ferry pier\"\n\"closed in summer\"",
	"too bad."},
	pure4={"\"aurora ferry pier\"\n\"open at last!\"",
	"someone scribbled:\n\"the captain is back\""},
	coins4={"\"aurora ferry pier\"\n\"closed in summer\"",
	"but a shiny boat is\nwaiting just for you."}},
	
	--foret
	
	{x=62,y=32,id="forestsign",
	t={"\"beware of the coins\n in the forest\"",
	"\"if you find one,\n don't touch it\"",
	"\"it could steal your soul\"","...",
	"i don't really\nbelieve it."}},
	
	{x=68,y=52,id="forsale",
	t={"\"for sale, call 76321\""},
	coins3={"\"for sale, call 76321\"",
	"* ben calls. a phone rings\n  inside *",
	"- \"a buyer? a buyer!!\"",
	"\"no house for you, but i\n have a boat.\"",
	"\"it's a bit... cursed.\n you'll love it.\"",
	"\"all your coins? deal!\"",
	"\"it's waiting at the port.\""},
	coins4={"\"sold!\"","\"no refunds.\""}},
	
	{x=102,y=39,
	t={"* toc toc *","that sounds empty."}},
	
	--coin s/e
	
	{x=123,y=58,
	t={"\"nothing more here\"","\"signed dev\"",
	"..."}},
	
}

function _init()
	palt(0,false)
	palt(11,true)
	input_init()
	cartdata("realburger_bensquest")
	music_load()
	play_music(24)
	player_init()
	trees_init()
	roofs_init()
end

--holding a button never repeats
--btnp (no runaway dialog or ending)
function input_init()
	poke(0x5f5c,255)
end

--sfx 59: click, 60: coin, 61: all coins,
--62: coin timer ran out
function input_sfx()
	if (btnp(❎)) sfx(59)
end

music_on=true

--saved slot 0: 0 = music on
--(fresh save), 1 = off
function music_load()
	music_on=dget(0)==0
end

--remember the track so 🅾️ can
--bring it back after muting
function play_music(n)
	cur_music=n
	if (music_on) music(n)
end

function music_toggle()
	if (not btnp(🅾️)) return
	music_on=not music_on
	dset(0,music_on and 0 or 1)
	music(music_on and cur_music or -1)
end

function _update60()
	input_sfx()
	music_toggle()
	if ending then
		ending_update()
	elseif is_title > -1 then
		update_title()
	else
		game_update()
	end
end

--move first: a coin taken on the
--timer's last frame still wins
function game_update()
	player_move()
	coins_update()
end

function _draw()
	if ending then
		ending_draw()
	elseif is_title > -1 then
		draw_title()
 else
		cls(12)
		camera(p.x-56,p.y-56)
		rectfill(0,0,1023,511,3)
		map()
		coins_draw()
		world_draw()
		if (p.is_dialog) draw_dialog()
		hud_draw()
	end
end
-->8
--player

function player_init()
	p={
		x=22*8,
		y=56*8,
		dir=3,--1:up 2:rt 3:dw 4:lt
		anim_t=0,
		is_moving=false,
		is_dialog=false,
		is_interact=false,
		dialog_texts={},--[...]
		dialog_current=1
	}
	trail={}
	
	oldpos={
		x=p.x,
		y=p.y
	}	
end

function player_move()
	--input
	local x=p.x
	local y=p.y
	
	oldpos.x=x
	oldpos.y=y
	
	if p.is_dialog then
		if (btnp(❎)) dialog_next()
		--forced texts (death) need ❎
		if (p.is_forced) return
	end
	
	p.is_moving=false
	if btn(➡️) then
		p.is_moving=true
		if not p.is_dialog then
			p.dir=2
			x+=1
		elseif p.dir!=2 then
			p.is_dialog=false
			p.dir=2
			x+=1
		end
	end
	if btn(⬅️) then
		p.is_moving=true
		if not p.is_dialog then
			p.dir=4
			x-=1
		elseif p.dir!=4 then
			p.is_dialog=false
			p.dir=4
			x-=1
		end
	end
	if btn(⬆️) then
		p.is_moving=true
		if not p.is_dialog then
			p.dir=1
			y-=1
		elseif p.dir!=1 then
			p.is_dialog=false
		end
	end
	if btn(⬇️) then
		p.is_moving=true
		if not p.is_dialog then
			p.dir=3
			y+=1
		elseif p.dir!=3 then
			p.is_dialog=false
		end
	end
	
	if (p.is_dialog) return
	
	--collisions
	local n=npc_hit(x,y)
	if n then
		dialog_open(n,true)
		return
	end
	local col=test_coll(x,y,1)
	if col then
		dialog_open(find_item(col),true)
		return
	end
	
	if not test_coll(x,y,0) then
	 p.x=x
	 p.y=y
	 coins_pickup(x,y)
	 follow_update()
	end
	
	--anim
	if not p.is_moving then
		p.anim_t=0
	else
		p.anim_t+=1
	end
	
	if (p.anim_t==32) p.anim_t=0
	
end

--collisions
function test_coll(x,y,f)
	if fget(mget(x/8,(y+8)/8),f) then
		return {x=flr(x/8),y=flr((y+8)/8)}
	end
	if fget(mget(x/8+1,(y+8)/8),f)	then
		return {x=flr(x/8+1),y=flr((y+8)/8)}
	end
	if fget(mget(x/8+2,(y+8)/8),f) then
		return {x=flr(x/8+2),y=flr((y+8)/8)}
	end
	if fget(mget(x/8,(y+8)/8+1),f) then
		return {x=flr(x/8),y=flr((y+8)/8+1)}
	end
	if fget(mget(x/8+1,(y+8)/8+1),f) then
		return {x=flr(x/8+1),y=flr((y+8)/8+1)}
	end
	if fget(mget(x/8+2,(y+8)/8+1),f) then
		return {x=flr(x/8+2),y=flr((y+8)/8+1)}
	end
	return false
end


--draw
function player_draw()

	local s--sprite
	local t=flr(p.anim_t/8)
	local m=false
	
	if p.dir==1 then
		if t==0 or t==2 or p.is_dialog then
		 s=64
		else
			s=66
		end
		if (t==3) m=true
	end
	
	if p.dir==2 or p.dir==4 then
		if t==0 or t==2 or p.is_dialog then
			s=0
		elseif t==1 then
			s=2
		else
			s=4
		end
	end
	
	if (p.dir==4) m=true
	
	if p.dir==3 then
		if t==0 or t==2 or p.is_dialog then
			s=32
		else
			s=34
		end
		if (t==3) m=true
	end
	
	spr(s,p.x,p.y,2,2,m)
	
	--print(tostr(debug),p.x,p.y+20,7)
	
	--if (p.is_dialog) draw_dialog()
	
end
-->8
--dialog

function find_item(coord)
	for d in all(dialitems) do
		if d.x==coord.x
		and d.y==coord.y then
			return d
		end
	end
	return {t={"..."}}
end

--e: dialitem, npc or {t=texts}
function dialog_open(e,prompt)
	p.is_dialog=true
	p.is_interact=prompt
	p.is_forced=not prompt
	p.dialog_e=e
	p.dialog_texts=qtexts(e)
	p.dialog_current=1
end

function dialog_next()
	if p.is_interact then
		p.is_interact=false
		return
	end
	p.dialog_current+=1
	if p.dialog_current>#p.dialog_texts then
		p.is_interact=true
		p.dialog_current=1
		local e=p.dialog_e
		quest_on_talk(e.id)
		p.dialog_texts=qtexts(e)
		--close forced texts and npcs
		--that just left
		if p.is_forced
		or e.vis and not e.vis() then
			p.is_dialog=false
			p.is_forced=false
		end
	end
end

function draw_dialog()

	if p.is_interact then
		print("❎",p.x+9,p.y-6,0)
		print("❎",p.x+11,p.y-6,0)
		print("❎",p.x+10,p.y-5,0)
		print("❎",p.x+10,p.y-7,0)
		print("❎",p.x+10,p.y-6,7)
		return
	end

	camera(0,0)
	rectfill(0,104,128,128,0)
	
	rect(3,107,124,126,7)
	print(p.dialog_texts[p.dialog_current],6,111,7)

	if p.dialog_current<#p.dialog_texts then
		print("❎",114,118,7)
	end
	
	camera(p.x-56,p.y-56)
end
-->8
--title

title_t=0

--title letters' y at frame f:
--rises from behind the sea view,
--eases out, settles at 14
function title_y(f)
	local q=1-min(f/90,1)
	return 14+flr(50*q*q*q)
end

function update_title()
	title_t+=1
	is_title+=1
	if is_title==16 then
		is_title=0
	end
	if btnp(❎) then
		is_title=-1
		play_music(0)
		quest_reset()
		coins_init()
	end
end

function draw_title()
	--sky, sun, drifting clouds
	cls(12)
	--haze: 25% then 50% white
	fillp(0xa0a0)
	rectfill(0,34,127,39,0x7c)
	fillp(0x5a5a)
	rectfill(0,40,127,43,0x7c)
	fillp()
	circfill(104,40,9,9)
	circfill(104,40,7,10)
	--clouds stay clear of the subtitle
	cloud((t()*3)%170-30,6)
	cloud((t()*2+90)%170-30,38)

	--title, drawn behind the sea view
	--studio name; uppercase in code
	--prints as small letters
	print("rEAL bURGER'S",38,3,1)

	local ty=title_y(title_t)
	--white outline: letters in solid
	--white shifted 1px each way first
	for i=0,15 do pal(i,7) end
	for d in all({{-1,0},{1,0},{0,-1},{0,1}}) do
		title_letters(d[1],ty+d[2])
	end
	pal() palt(0,false) palt(11,true)
	title_letters(0,ty)
	--dark outline keeps it readable
	for d in all({{-1,0},{1,0},{0,-1},{0,1},{1,1}}) do
		print("a hero's dream",37+d[1],ty+12+d[2],1)
	end
	print("a hero's dream",37,ty+12,7)

	title_sea()

	--scrolling hedge; its orange is
	--see-through to show the sand
	palt(9,true)
	for i=0,16 do
		spr(42,i*8-is_title/2,84)
	end
	palt(9,false)
	rectfill(0,92,127,127,3)
	if title_t>90 and title_t\30%2==0 then
		print("press ❎ to start",31,100,7)
	end
	--centered: the glyph is 8px wide
	local m="🅾️ music: "..(music_on and "on" or "off")
	print(m,62-#m*2,110,11)
end

--"ben's quest" letter sprites
function title_letters(ox,y)
	local x=18+ox
	for s in all({88,89,90,91,92,
	0,93,94,89,92,95}) do
		if (s>0) spr(s,x,y)
		x+=s>0 and 9 or 6
	end
end

--leaning trunk from (x,y) up h px,
--fronds at the top
function palm(x,y,lean,h)
	local tx,ty
	--wood first, then the stripes:
	--each circle would hide the last
	for p=0,1 do
		for i=0,h do
			local k=i/h
			tx=x+lean*k*k
			ty=y-i
			if p==0 then
				circfill(tx,ty,2,4)
			elseif i%3==1 then
				line(tx-1,ty,tx+1,ty,2)
				pset(tx-2,ty-1,2)
				pset(tx+2,ty-1,2)
			end
		end
	end
	--{dx,dy,length,droop}: a spine
	--with leaflets hanging under it
	for f in all({{-1.1,-.6,14,.07},
	{-.8,-1,12,.1},{-.1,-1.1,8,.14},
	{.6,-1,12,.1},{1.1,-.5,14,.07},
	{-1,-.1,12,.1},{1,0,12,.1},
	{-.5,.2,9,.1},{.5,.2,9,.1}}) do
		local dx,dy,n,d=unpack(f)
		for j=1,n do
			local fx=tx+dx*j
			local fy=ty+dy*j+d*j*j
			local l=1-sin(j/n/2)*3
			line(fx,fy,fx-dx*2,fy+l,3)
			line(fx,fy,fx+dx,fy+l,3)
			if (j<n/3) circfill(fx,fy,1,3)
			pset(fx,fy,11)
		end
	end
	circfill(tx,ty,2,3)
	pset(tx,ty-2,11)
end

--hull s*8 px wide narrowing to the
--keel, sail above
function sailboat(x,y,s)
	for r=0,s do
		line(x+r,y+r,x+8*s-1-r,y+r,4)
	end
	for i=0,6*s-1 do
		line(x+3*s,y-6*s+i,
			x+3*s+i\2,y-6*s+i,7)
	end
end

--sea up to the shore, boats passing,
--ben on the sand facing us
function title_sea()
	rectfill(0,44,127,51,1)
	rectfill(0,52,127,71,12)
	line(0,44,127,44,13)
	--sparkles get longer and
	--slower as the sea comes closer
	for i=0,20 do
		local r=i%6
		local wy=({46,48,51,55,60,66})[r+1]
		local wx=(i*29+t()*(2+r))%140-6
		line(wx,wy,wx+1+r\2,wy,7)
	end
	sailboat((t()*2)%160-16,43,1)
	sailboat(140-(t()*4)%180,58,2)
	--sand and foam that breathes
	rectfill(0,72,127,91,15)
	for x=0,127 do
		local fy=70+flr(sin(x/48+t()/3)*1.5)
		line(x,fy,x,72,12)
		pset(x,fy,7)
	end
	for i=0,20 do
		pset(i*37%128,74+i*7%11,9)
	end
	fillp(0x5a5a)
	ovalfill(56,77,70,81,0x9f)
	fillp()
	spr(32,56,64,2,2)
end

-->8
--coins

coin_n=25
coin_time=90*60
--ben's spot after dying
respawn={x=60*8,y=33*8}

death_texts={
	"* ben wakes up by the sign *",
	"\"told you so.\"\n  - the sign",
	"your soul was returned.\nslightly used.",
	"the coins are back.\nso is the temptation."}

--coin tile under feet at x,y
function under_feet(x,y,cx,cy)
	return abs(x-cx)<16
		and abs(y+8-cy)<8
end

--some spot lets ben's feet touch it
function coin_standable(cx,cy)
	for x=cx-12,cx+4,4 do
		for y=cy-12,cy-4,4 do
			if not test_coll(x,y,0)
			and not test_coll(x,y,1) then
				return true
			end
		end
	end
	return false
end

function coin_free(cx,cy)
	if (mget(cx/8,cy/8)!=8) return false
	if (not coin_standable(cx,cy)) return false
	if (under_feet(respawn.x,respawn.y,cx,cy)) return false
	for n in all(npcs) do
		if (under_feet(n.x,n.y,cx,cy)) return false
	end
	for c in all(coins) do
		if (c.x==cx and c.y==cy) return false
	end
	return true
end

function coins_init()
	coins={}
	coin_timer=nil
	for i=1,coin_n do
		local x,y
		repeat
			x=(64+flr(rnd(64)))*8
			y=flr(rnd(64))*8
		until coin_free(x,y)
		add(coins,{x=x,y=y,t=flr(rnd(40))})
	end
end

--collect coins touching ben's feet
function coins_pickup(x,y)
	if not (branch=="none"
	or branch=="coins" and step==0) then
		return
	end
	for c in all(coins) do
		if c.x>x-8 and c.x<x+16
		and c.y>y and c.y<y+16 then
			del(coins,c)
			--the last one gets the fanfare
			if (#coins>0) sfx(60)
			if branch=="none" then
				branch="coins"
				step=0
				coin_timer=coin_time
			end
		end
	end
end

function coins_update()
	for c in all (coins) do
		c.t+=1
		if (c.t>40) c.t=0
	end
	if (not coin_timer) return
	if #coins==0 then
		step=1
		coin_timer=nil
		sfx(61)
		return
	end
	coin_timer-=1
	if (coin_timer<=0) coins_fail()
end

function coins_fail()
	sfx(62)
	quest_reset()
	coins_init()
	p.x=respawn.x
	p.y=respawn.y
	oldpos.x=p.x
	oldpos.y=p.y
	dialog_open({t=death_texts},false)
end

function hud_draw()
	if (not coin_timer) return
	camera(0,0)
	rectfill(0,0,127,8,0)
	print("time "..ceil(coin_timer/60),2,2,7)
	print("coins "..(coin_n-#coins)
		.."/"..coin_n,80,2,10)
	camera(p.x-56,p.y-56)
end

function coins_draw()
	for c in all (coins) do
		local s=72
		if c.t>30 then
			s=73
		elseif c.t>20 then
			s=74
		elseif c.t>10 then
			s=73
		end
		spr(s,c.x,c.y)
	end
end
-->8
--trees

function trees_init()
	trees={}
	local x,y,t
	for x=0,127 do
		for y=0,63 do
			t=mget(x,y)
			if t==6 or t==38 then
				add(trees,{
					x=x*8,
					y=y*8,
					t=t})
			end
		end
	end
end
-->8
--roofs

function roofs_init()
	roofs={}
	local x,y,t
	for x=0,127 do
		for y=0,63 do
			t=mget(x,y)
			if t==40 then
				add(roofs,{
					x=x*8,
					y=y*8
				})
			end
		end
	end
end
-->8
--quest

function quest_reset()
	branch="none"
	step=0
end

--texts for the current state:
--e[branch..step], e[branch], e.t
function qtexts(e)
	return e[branch..step]
		or e[branch] or e.t
end

function quest_on_talk(id)
	if id=="captain" and branch=="pure"
	and step==4 then
		ending_start("a")
	elseif id=="port" and branch=="coins"
	and step==4 then
		ending_start("b")
	elseif id=="guardian"
	and branch=="none" then
		branch="pure"
		step=1
		coins={}
	elseif branch=="pure" then
		if id=="armory" and step==1
		or id=="dogdoor" and step==2
		or id=="guardian" and step==3 then
			step+=1
		end
	elseif branch=="coins" then
		if id=="bellboy" and step==1
		or id=="disturb" and step==2
		or id=="forsale" and step==3 then
			step+=1
		end
	end
end

--max 2 lines of 112px per page
function text_ok(s)
	local lines=split(s,"\n",false)
	if (#lines>2) return false
	for l in all(lines) do
		local w=0
		for i=1,#l do
			w+=ord(l,i)>=128 and 8 or 4
		end
		if (w>112) return false
	end
	return true
end

function all_texts()
	local out={}
	local function add_list(l)
		for s in all(l) do
			if (type(s)=="string") add(out,s)
		end
	end
	local function add_entry(e)
		for k,v in pairs(e) do
			if (type(v)=="table") add_list(v)
		end
	end
	foreach(dialitems,add_entry)
	foreach(npcs,add_entry)
	add_list(death_texts)
	for k,l in pairs(ending_pages) do
		for pg in all(l) do add(out,pg.t) end
	end
	return out
end
-->8
--npcs

--x,y: pixels, top-left of 16x16
--pl: pal pairs applied to s
npcs={

	{id="guardian",x=107*8,y=50*8,
	s=32,pl={9,6,4,5,3,13,5,6},
	vis=function()
		return branch=="none"
			or branch=="pure" and step<4
	end,
	t={"* an old knight sighs *",
	"- \"40 years guarding these\n  coins. 40 years!\"",
	"\"nobody ever touched one.\n not even a kid. not once.\"",
	"\"you know what? they're\n not even real.\"",
	"\"just an illusion of your\n imagination, kid.\"",
	"* the coins fade away *",
	"\"i quit. take my letter\n to my boss, the armorer.\""},
	pure1={"\"the armory shop, in town.\n go on, i'll wait. again.\""},
	pure2={"\"a replacement? me?\n good luck with that.\""},
	pure3={"* the knight stares\n  at the dog *",
	"\"...loyal. cheap. fearless.\"",
	"\"you're hired, buddy.\"",
	"\"now i can go back\n to my real job.\"",
	"\"i'm the harbor captain!\"",
	"\"why do you think the port\n was closed?\"",
	"\"meet me at the port, kid.\""}},

	{id="dog",x=107*8,y=50*8,
	s=68,pl={},
	vis=function()
		return branch=="pure" and step==4
	end,
	t={"* the dog guards the coins *",
	"he takes his job\nvery seriously."}},

	{id="captain",x=44*8,y=9*8,
	s=32,pl={9,6,4,5,3,13,5,6},
	vis=function()
		return branch=="pure" and step==4
	end,
	t={"\"all aboard, kid!\"",
	"\"next stop: the mainland.\""}},

	{id="bellboy",x=29*8,y=6*8,
	s=32,pl={9,8,4,2,3,8,5,2},
	vis=function()
		return branch=="coins" and step==1
	end,
	t={"\"sir! deliver this parcel\n to the west side house.\"",
	"\"the one that says\n 'please don't disturb'.\"",
	"\"they love being disturbed.\"",
	"* ben gets a heavy parcel *"}},

}

function npc(id)
	for n in all(npcs) do
		if (n.id==id) return n
	end
end

--visible npc whose feet overlap
--ben's feet at x,y
function npc_hit(x,y)
	for n in all(npcs) do
		if n.vis()
		and abs(n.x-x)<16
		and abs(n.y-y)<8 then
			return n
		end
	end
end

function npc_draw(n)
	for i=1,#n.pl,2 do
		pal(n.pl[i],n.pl[i+1])
	end
	if n.id=="dog" then
		dog_draw(n.x,n.y,false,false)
	else
		spr(n.s,n.x,n.y,2,2)
	end
	pal()
	palt(0,false)
	palt(11,true)
end

function follower_draw()
	local d=trail[1]
	local moving=p.x!=oldpos.x
		or p.y!=oldpos.y
	dog_draw(d.x,d.y,moving,p.x<d.x)
end

--ben, visible npcs and the follower
--dog, back to front (by y)
function actors()
	local l={{id="ben",x=p.x,y=p.y,
		draw=player_draw}}
	for n in all(npcs) do
		if n.vis() then
			add(l,{id=n.id,x=n.x,y=n.y,
				draw=function() npc_draw(n) end})
		end
	end
	if branch=="pure" and step==3
	and #trail>0 then
		add(l,{id="dog",x=trail[1].x,
			y=trail[1].y,draw=follower_draw})
	end
	for i=2,#l do
		local j=i
		while j>1 and l[j-1].y>l[j].y do
			l[j],l[j-1]=l[j-1],l[j]
			j-=1
		end
	end
	return l
end

--tree and roof tiles standing in
--front of someone at x,y
function covers(x,y)
	local l={}
	local function near(t)
		return t.y>y and t.y<y+16
			and abs(t.x-x)<16
	end
	for t in all(trees) do
		if (near(t)) add(l,{s=t.t,x=t.x,y=t.y,w=2})
	end
	for r in all(roofs) do
		if (near(r)) add(l,{s=40,x=r.x,y=r.y,w=1})
	end
	return l
end

function world_draw()
	for a in all(actors()) do
		a.draw()
		for c in all(covers(a.x,a.y)) do
			spr(c.s,c.x,c.y,c.w,c.w)
		end
	end
end

--left half: tail, wags every
--4 frames while moving
function dog_left(moving,f)
	if (not moving) return 71
	return f\4%2==0 and 68 or 70
end

--right half (head) is always 69/85
function dog_draw(x,y,moving,flip)
	local l=dog_left(moving,flr(t()*60))
	local lx,rx=x,x+8
	if (flip) lx,rx=x+8,x
	spr(l,lx,y,1,1,flip)
	spr(l+16,lx,y+8,1,1,flip)
	spr(69,rx,y,1,1,flip)
	spr(85,rx,y+8,1,1,flip)
end

--remember ben's last 16 spots
function follow_update()
	local l=trail[#trail]
	if l and l.x==p.x and l.y==p.y then
		return
	end
	add(trail,{x=p.x,y=p.y})
	if (#trail>16) deli(trail,1)
end
-->8
--ending

ending_pages={
	a={
	{scene="sea",t="* the boat leaves the port *"},
	{scene="sea",t="\"adventure awaits, kid!\n and no more coins.\""},
	{scene="sea",t="ben feels like a real hero."},
	{scene="bed",t="* slurp slurp *"},
	{scene="bed",t="ben wakes up. his dog is\nlicking his face."},
	{scene="bed",t="it was all a dream.\n...and his socks are gone."}},
	b={
	{scene="sea",t="* ben sails away, rich *"},
	{scene="sea",t="* blub *"},
	{scene="sea",t="the cursed boat is\nslowly sinking."},
	{scene="sea",t="\"no refunds.\"\n  - the seller, probably"},
	{scene="bed",t="ben wakes up, sticky."},
	{scene="bed",t="chocolate all over\nhis face."},
	{scene="bed",t="the coins were chocolate.\nit was all a dream."}}
}

--{text, gap below in px}
function credits_for(name)
	return {{"\^w\^tthe end",20},
	{"thank you for playing!",16},
	{name,18},
	{"a game by"},{"real burger",16},
	{"made with pico-8"},{"aseprite",16},
	{"musics by claude",16},
	{"see you on the mainland!",30},
	{"press ❎ to play again"}}
end

credits={
	a=credits_for("ending 1/2: good boy"),
	b=credits_for("ending 2/2: chocolate dream")}

--frames for one full roll: every
--line goes from below to above
function credits_period()
	local h=0
	for l in all(credits[ending]) do
		h+=l[2] or 10
	end
	return (136+h)*4
end

--rolls up 15px/s, then loops
function credits_scroll(f)
	return f%credits_period()/4
end

function credits_ys(s)
	local ys,y={},128-s
	for l in all(credits[ending]) do
		add(ys,y)
		y+=l[2] or 10
	end
	return ys
end

function ending_start(k)
	ending=k
	ending_page=1
	end_t=0
	play_music(32)
end

function ending_update()
	if (ending_page>#ending_pages[ending]) end_t+=1
	if (not btnp(❎)) return
	ending_page+=1
	if ending_page>#ending_pages[ending]+1 then
		run()
	end
end

function ending_draw()
	camera(0,0)
	local l=ending_pages[ending]
	local pg=l[ending_page]
	if not pg then
		draw_credits()
		return
	end
	if pg.scene=="sea" then
		--boat b sinks page after page
		draw_sea(ending=="b"
			and ending_page*3 or 0)
	else
		draw_room()
	end
	rectfill(0,104,128,128,0)
	rect(3,107,124,126,7)
	print(pg.t,6,111,7)
	print("❎",114,118,7)
end

--ben resting on a tiny island
function end_scene()
	cls(12)
	circfill(20,24,7,10)
	cloud((t()*3)%170-30,14)
	cloud((t()*2+70)%170-30,44)
	rectfill(0,100,127,127,1)
	for i=0,12 do
		local wx=(i*37+t()*(3+i%3))%140-8
		local wy=103+i*7%22
		line(wx,wy,wx+3,wy,12)
	end
	--two foam rings leave the shore,
	--grow and fade, then start over
	clip(0,100,128,28)
	for i=0,1 do
		local r=(t()*6+i*8)%16
		oval(52-r,95-r/3,116+r,111+r/3,
			r<6 and 7 or r<11 and 12 or 13)
	end
	clip()
	--foam ring: white disc, sand
	--inset 1px so no sea shows between
	ovalfill(52,95,116,111,7)
	ovalfill(53,96,115,110,15)
	ovalfill(60,104,108,110,9)
	palm(98,102,-6,34)
	spr(32,64,88,2,2)
	if ending=="a" then
		dog_draw(80,90,false,true)
	else
		circfill(86,100,2,10)
		circ(86,100,2,9)
	end
end

--white text, blue outline, rolling up
function draw_credits()
	end_scene()
	local c=credits[ending]
	local ys=credits_ys(credits_scroll(end_t))
	for i=1,#c do
		local s=c[i][1]
		local x=64-print(s,0,-100)\2
		for d in all({{-1,0},{1,0},{0,-1},{0,1}}) do
			print(s,x+d[1],ys[i]+d[2],1)
		end
		print(s,x,ys[i],7)
	end
end

function cloud(x,y)
	circfill(x,y,4,7)
	circfill(x+6,y-3,5,7)
	circfill(x+13,y,4,7)
	rectfill(x,y,x+13,y+4,7)
	line(x-1,y+4,x+14,y+4,6)
end

--sea from row y0 down (redrawn
--over the boat to sink it)
function sea_draw(y0)
	local function band(a,b,c)
		if (b>=y0) rectfill(0,max(a,y0),127,b,c)
	end
	band(58,61,13)
	band(62,77,12)
	band(78,103,1)
	--sun glitter
	for y=60,76,2 do
		local w=(76-y)\3
		if (y>=y0) line(100-w,y,100+w,y,10)
	end
	--waves drifting slowly
	local tt=t()*6
	for i=0,34 do
		local wy=60+(i*13)%44
		local wx=(i*37+tt*(1+i%3))%140-8
		if wy>=y0 then
			line(wx,wy,wx+2+i%3,wy,
				wy<78 and 7 or 12)
		end
	end
end

function draw_sea(d)
	cls(12)
	circfill(100,24,10,9)
	circfill(100,24,8,10)
	cloud((t()*3)%170-30,16)
	cloud((t()*2+80)%170-30,36)
	--gulls
	for g in all({{20,22},{30,28}}) do
		line(g[1],g[2],g[1]+2,g[2]+2,5)
		line(g[1]+2,g[2]+2,g[1]+4,g[2],5)
	end
	--ben's island, far away
	circfill(14,62,13,3)
	circfill(24,62,8,3)
	rectfill(12,40,15,50,7)
	line(12,43,15,43,8)
	line(12,47,15,47,8)
	rectfill(11,37,16,39,10)
	line(13,36,14,36,8)
	sea_draw(58)

	local bx,by=36,62+d
	--mast, flag
	line(bx+24,by-42,bx+24,by+8,4)
	rectfill(bx+25,by-42,bx+31,by-39,8)
	--main sail, above the crew
	for i=0,26 do
		local w=i*22\26
		line(bx+25,by-36+i,bx+25+w,by-36+i,7)
		pset(bx+25+w,by-36+i,6)
	end
	line(bx+25,by-10,bx+47,by-10,4)
	--jib
	for i=0,22 do
		local w=i*16\22
		line(bx+23-w,by-32+i,bx+23,by-32+i,6)
		pset(bx+23-w,by-32+i,13)
	end
	--crew sunk into the hull: only
	--heads and shoulders show
	spr(32,bx+6,by-6,2,2)
	if ending=="a" then
		--the captain at the helm
		pal(9,6) pal(4,5) pal(3,13) pal(5,6)
		spr(32,bx+34,by-6,2,2)
		pal() palt(0,false) palt(11,true)
	end
	--hull: trim, wood, dark keel
	for i=0,10 do
		local c=i<2 and 9 or i<7 and 4 or 2
		line(bx+i*8\10,by+8+i,
			bx+56-i*6\10,by+8+i,c)
	end
	line(bx-2,by+7,bx+57,by+7,5)
	for x=bx+12,bx+44,10 do
		circfill(x,by+12,1,12)
		circ(x,by+12,1,5)
	end
	sea_draw(80)
	--foam along the hull
	for i=0,12 do
		pset(bx-4+i*5+(t()*8+i)%3,80,7)
	end
end

function draw_room()
	--wallpaper
	cls(15)
	for x=2,127,8 do
		for y=4,74,8 do
			pset(x,y,14)
			pset(x+4,y+4,9)
		end
	end
	rectfill(0,0,127,2,4)
	--skirting board and floor
	rectfill(0,78,127,81,7)
	line(0,81,127,81,6)
	rectfill(0,82,127,103,4)
	for y=86,103,5 do
		line(0,y,127,y,2)
		local o=(y*7)%24
		for x=o,127,24 do
			line(x,y-4,x,y,2)
		end
	end
	--rug
	ovalfill(52,88,112,101,8)
	oval(52,88,112,101,14)
	oval(57,90,107,99,2)

	--window with the sea outside
	line(72,7,122,7,5)
	rectfill(80,10,114,46,7)
	rectfill(82,12,112,44,12)
	circfill(106,20,4,10)
	cloud(86,22)
	rectfill(82,36,112,44,1)
	line(82,36,112,36,13)
	circfill(88,38,3,3)
	line(97,12,97,44,7)
	line(82,28,112,28,7)
	rectfill(78,46,116,48,6)
	--curtains with folds
	rectfill(74,8,81,52,8)
	rectfill(113,8,120,52,8)
	for x in all({76,79,115,118}) do
		line(x,9,x,52,2)
	end
	pset(81,30,9) pset(113,30,9)

	--clock and framed boat
	circfill(30,18,6,7)
	circ(30,18,6,5)
	line(30,18,30,14,0)
	line(30,18,33,18,8)
	rect(44,12,66,30,4)
	rect(45,13,65,29,9)
	rectfill(46,14,64,28,12)
	rectfill(46,25,64,28,1)
	line(50,24,60,24,4)
	line(51,25,59,25,4)
	line(55,16,55,23,4)
	for i=0,6 do line(56,17+i,56+i,17+i,7) end

	--bedside table and lamp
	rectfill(70,64,88,84,4)
	rectfill(69,62,89,64,9)
	line(71,73,87,73,2)
	pset(79,68,10) pset(79,78,10)
	rectfill(76,56,80,61,6)
	for i=0,7 do
		line(74-i\2,46+i,82+i\2,46+i,10)
	end
	line(70,53,86,53,9)

	--bed: posts, frame, sheet
	rectfill(3,40,9,86,4)
	circfill(6,39,3,9)
	line(4,42,4,86,9)
	rectfill(60,58,66,86,4)
	circfill(63,57,3,9)
	rectfill(9,62,60,74,7)
	rectfill(9,75,60,79,4)
	line(9,75,60,75,2)
	--pillow
	rectfill(10,48,28,60,7)
	rect(10,48,28,60,6)
	spr(32,12,46,2,2)
	--blanket up to ben's chin
	rectfill(10,56,59,58,7)
	line(10,58,59,58,6)
	rectfill(10,59,59,80,8)
	fillp(0x5a5a)
	rectfill(10,63,59,80,0x82)
	fillp()
	line(10,59,59,59,14)
	--ben's feet under the blanket
	ovalfill(46,58,56,63,8)

	if ending=="a" then
		dog_draw(28,46,true,true)
		pset(27,52,14)
		--a tiny heart
		line(20,39,21,39,8) line(23,39,24,39,8)
		line(20,40,24,40,8) line(21,41,23,41,8)
		pset(22,42,8)
	else
		--chocolate on ben's face
		--on skin pixels only: cheeks, chin
		for c in all({{16,53},{17,54},
		{19,55},{20,55},{22,54},{22,52}}) do
			pset(c[1],c[2],4)
		end
		line(11,50,12,51,4)
		line(26,49,27,50,4)
		--gold wrappers everywhere
		for c in all({{36,70},{48,66},{40,92},
		{30,97},{92,94},{100,88},{84,60}}) do
			circfill(c[1],c[2],2,10)
			pset(c[1]+1,c[2]-1,7)
			circ(c[1],c[2],2,9)
		end
	end
end
__gfx__
bbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbbbb3333333355555555cccccccc6ddd5666333333333333333333333333511d111d
bbbb0999994000bbbbbb00000000bbbbbbbbb000000bbbbbbbbbb03030bbbbbb3333333355555555ccccccccdddd56dd30333333333393333337773351d111dd
bbb04949949440bbbbb0494999440bbbbbbb0494994000bbbbbb0303030bbbbb3333333355555555ccc6ccccdddd5ddd300330333c333033377a99775d111dd1
bb049494940400bbbb049449449440bbbbb04949449440bbbbb034303030bbbb3333333355555555cc6ccccc555555553003003333033333377999775111dd1d
bb09449400f00bbbbb09499494040bbbbb049494940400bbbb04030400000bbb3333333355555555cccccc6c56666ddd330300333333383333377733511dd1d1
bb090000ff0f0bbbbb09494400f00bbbbb09449400f00bbbb0333330303000bb3333333355555555cccccccc56dddddd3333033333338a833300300351dd1d11
bb0404f0ff0f0bbbbb090000ff0f0bbbbb090000ff0f0bbbbb0000030300000b3333333355555555cccc6ccc5ddddddd33333333333338033330003366666666
bb00044fffff0bbbbb0404f0ff0f0bbbbb0404f0ff0f0bbbbbbb0030300bbbbb3333333355555555cccccccc5555555533333333333333333333333355555555
bbb00004fff0bbbbbb00044fffff0bbbbb00044fffff0bbbbbb043430000bbbb55555555333333353333333353333333cccccccc3333333c33333333c3333333
bbbbb000000bbbbbbbb00004fff0bbbbbbb00004fff0bbbbbb03333030300bbb3355553333333335333333335333333333cccc333333333c33333333c3333333
bbbb065330bbbbbbbbbb0600000bbbbbbbbb0000000bbbbbb0334303030000bb33355333333333553333333355333333333cc333333333cc33333333cc333333
bbbb065330bbbbbbbbbb0650330bbbbbbbbb0533030bbbbb034330000000000b333333333333355533333333555333333333333333333ccc33333333ccc33333
bbbb00dff50bbbbbbbbbb5555ff00bbbbbbb0f3055000bbb000000445000000b333333333333355533333333555333333333333333333ccc33333333ccc33333
bbbbb0dd500bbbbbbbbb0dd005570bbbbbbb00005dd70bbbbbbbbbb45bbbbbbb3333333333333355333553335533333333333333333333cc333cc333cc333333
bbbbb077770bbbbbbbbb07700770bbbbbbbb07700770bbbbbbbbbbb450000bbb33333333333333353355553353333333333333333333333c33cccc33c3333333
bbbbb000000bbbbbbbbbb000000bbbbbbbbb0000b00bbbbbbbbb0000000000bb33333333333333355555555553333333333333333333333cccccccccc3333333
bbbbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000bbbbb2222222299999999999999999999999924422442866886683555555358888888
bbbb0099990bbbbbbbbbbb0000bbbbbbbbbbbbbbbbbbbbbbbbb0030303000bbb8228822899999999339999339699999924422442866886685444444058888888
bbb0949949900bbbbbbb00999900bbbbbbbbbbbbbbbbbbbbbb033030303000bb2882288299999999333993337659999924422442668866885466464058888888
bb094949449490bbbbb0949449990bbbbbbbbbbbbbbbbbbbb0330803000000bb2222222299999999333333339599969924422442668866885444444058758888
bb049444444940bbbb094949449490bbbbbbbbbbbbbbbbbbb08333303000000b2222222299999999333333339996965924422442688668863000000358558888
bb004004400400bbbb044494494440bbbbbbbbbbbbbbbbbbb00303030000000b8228822899999999333333339976599924422442688668863334533358888888
bb0f0ff00ff0f0bbbb004004400400bbbbbbbbbbbbbbbbbbb03340303080000b2882288299999999333333339995599924422442886688663334500077777777
bb04ff0ff0f040bbbb0f0ff00ff0f0bbbbbbbbbbbbbbbbbbb03804030004400b2222222299999999333333339999999924422442886688663334500355555555
bbb04f0ff0f40bbbbb04ff0ff0f040bbbbbbbbbbbbbbbbbbbb0333400045000b5333333355555555555555553333333533333333ccccccc33ccccccc33333333
bbbb04ffff40bbbbbbb04f0ff0f40bbbbbbbbbbbbbbbbbbbbb0308044450000b55333333555555533555555533333355c3333333cccccc3333cccccc3333333c
bbb0300000030bbbbbbb04ffff400bbbbbbbbbbbbbbbbbbbbbb00400450000bb55533333555555333355555533333555cc333333ccccc333333ccccc333333cc
bb0356d33d6530bbbbb030000000f0bbbbbbbbbbbbbbbbbbbbbb004444440bbb55553333555553333335555533335555ccc33333cccc33333333cccc33333ccc
bb0f05555550f0bbbbb053f03d6000bbbbbbbbbbbbbbbbbbbbbbbb445000bbbb55555333555533333333555533355555cccc3333ccc3333333333ccc3333cccc
bbb00dd00dd00bbbbbbb0dd00550bbbbbbbbbbbbbbbbbbbbbbbbbbb45bbbbbbb55555533555333333333355533555555ccccc333cc333333333333cc333ccccc
bbbb07700770bbbbbbbbb0000770bbbbbbbbbbbbbbbbbbbbbbbbbbb450000bbb55555553553333333333335535555555cccccc33c33333333333333c33cccccc
bbbbb000000bbbbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbbbb0000000000bb55555555533333333333333555555555ccccccc333333333333333333ccccccc
bbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccc999999999999999999ccccccc
bbbb04999940bbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccc99399999999999999399cccccc
bbb0499999990bbbbbbb04999940bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb666bbbbbb6bbbbbbb6bbbbbbbbbbbbccccc9993399999999999933999ccccc
bb049494949440bbbbb0499999990bbbbbbbbbbbbb000bbbbbbbbbbbbbbbbbbbb677a6bbbb676bbbbbb6bbbbbbbbbbbbcccc999933399999999993339999cccc
bb049494944940bbbb049499999440bbbbbbbbbbb02440bbbbbbbbbbbbbbbbbbb679a5bbbb695bbbbbb6bbbbbbbbbbbbccc99999333399999999333399999ccc
bb044494494490bbbb044494949940bbbbbbbbbb0240420bbbbbbbbbbbbbbbbbb6aaa5bbbb6a5bbbbbb6bbbbbbbbbbbbcc9999993333399999933333999999cc
bb044949449440bbbb049994449490bbbbbbbbbb02444400bbb0bbbbbbbbbbbbbb555bbbbbb5bbbbbbb5bbbbbbbbbbbbc999999933333399993333339999999c
bb044444944440bbbb044949449440bbb0bbbbbb02444440bb04bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb99999999333333399333333399999999
bbb0044444400bbbbb044449494440bb040bbbbb0244000bb040bbbbbbb000000000000bb000000b000b0000bb0000bbb000000bb000000b000b00000000000b
bbbb00000000bbbbbbb0044444400bbbb0400000024440bbb0400000bb0244440000000000000000b00bb000bbb000bb0000000000000000000b000000000000
bbb0656666560bbbbbbb000000000bbbbb04444444440bbbbb044444b0244444b11bb11111bbb111b111bb11bbbb11bbb111bb11111bbb11111bb11111b111b1
bb036d6776d630bbbbb06566665630bbbb04444444440bbbbb044444b0244444b11111bb1111bbb111111b11bbb11bbbbb111bb111bb1b11b11bb11b1bb11bbb
bb0f00dddd00f0bbbbb03d6776d600bbbb04200000240bbbbb042000b020420011b1111bb1111bbb11b11111bbbbbbbb1bb111bb11b11111b11bb11bbbb11bbb
bbb0000000000bbbbbb0f0dddd00bbbbbb0400bbb0040bbbbb0400bbb02400bb22bbb222222bbb2222bb2222bbbbbbbb22bb222b22bb222bb222b22bbbb22bbb
bbbb05500550bbbbbbbb00000550bbbbbb000bbbbb000bbbbb000bbbbb00440b2222222222222222222bb222bbbbbbbb2222222222222222b222222bbb222bbb
bbbbb000000bbbbbbbbbb0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00bb2222222bb222222b2222bb22bbbbbbbbb222222bb2222b22bb2222bbb22222bb
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
a0808080e08080809190909080808080808080809090908380c0a1e0c080a180d0b3909090838080a18080a18080a1808080b0b0b0b0b080a18080a18080e280
8080808080808080d08080808080808080c0808080808080808060708080c0808080808080808080808080808080808080808080808080808080808080a0a0a0
a080808080808080d090909080c08080808080e29090909090909090909090909090909090909090909090909090909090909090909090909090909090b18080
808080808080808080808080808060708080808080808080d080617180808080d080806272808080808080808080808080808080808080808080808080a0a0a0
a0f1c08080d0808080909090b180808080c080809090909090909090909090909090909090909090909090909090909090909090909090909090909090b18080
607080808080c08080808080808061718080808060708080808080808080808080808063738080808080808080627280808080808080c0808080808080a0a0a0
a0808080808080c080909090808080808080d0809090909090909090909090909090909090909090909090909090909090909090909090909090909090b18080
617180808080808080808080c0808080808080806171808080808080808080808080808080808080c08080d080637380806070808080808080d0808080a0a0a0
a080828282828282919090908080e08080808080909090909381808081808081808081808080818080808180808081808080b0b0b0b0b0808180818081808080
808080808080808060708080808080808080808080808080808080627280808080808082828282828080808080808080806171808080808080808080f3a0a0a0
a0f18282828282828090909080808080c080808090909093d080c0e180e1c0808080808080808080c08080e080d08080808080a0a0a0f1808080808080808060
7080808080808080617180808080806070808080808080808080806373808080c08080828282828280808080c08080c0808080808080808080808080a0a0a0a0
a0c0b0b0f0b0b0b080909090b180d08080808080909090808080f3a0a0a0c380d080808080808080808080808080808080c0d1a0a0a08080808080808080c061
718080c0808080808080808080808061718080d08080808080d0808080808080808080b0f0b0b0b080808080e180e18080e180808080808080808080a0a0a0a0
a080b0b0b0b0f2b0919090908080808080e080809090908080d1a0a0a0a0a0f180808080c08080d08080808080808080808080a0a0a08080808080d080808080
8080808080808080808080808080808080808080808060708080808080808080808080b0b0b0f2b0806272f3a0a0a0a0a0a08080d080627280808080a0a0a0a0
a0f1c0d080e080c08090909080c0808080808080909090b18080e3a0a0a0a0c08080808080e0808080808080c0808080808080a0a0a0f1808080808080808080
808080808080808080c080808080c08080808080808061718080808080808080808080d0d0e080d0806373a0a0a0a0a0a0a0f1808080637380808080a0a0a0a0
a08080808080808080909090b18080e0808080919090908080d080c1e3a0a0f180d0808080808080808080808080d080808080a0a0a080808080808080808080
627280808060708080808080808080808080808080808080808080c08080806070808080808080808080d1a0a0a0a0a0a0d380808080808080808080a0a0a0a0
a08080c08080c0809190909080d0808080d08080909090838080e08080c0c180808080808080d080808080808080808080c0d1a0a0a080808080607080808080
6373808080617180808080627280808080808080c0808080808080806070806171808080806070808080d1a0a0a0a0d3c18080808080808080808080a0a0a0a0
a0f180808080808080909090808080c0808080b39090909083808080808080808080c0808080808080c080d0808080e0808080a0a0a0f1808080617180808080
8080808080808080d080806373808080808080808080808080808080617180808080808080617180808080c180c162728080808080808080c0808080a0a0a0a0
a080808080c080809190909083a18080a180b39090909090908380808080808080808080808080e18080e18080e18080e180f3a0a0a080808080808080c08080
808080808080808080808080808080806070808080808080627280808080808080808080808080808080c080808063738080d0808080808080808080a0a0a0a0
a080d080808080c08090909090909090909090909381a3909090808080d080808080808080f3a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a080808080808080808080
8080c0808080808080808080808080806171808080808080637380808080d08080808080808080808080808080808080808080808080808080808080a0a0a0a0
a080808080808080919090909090909090909090b1e29190909080c0808080e08080d08080a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0f18080d0808080808080
808080808080808080c0808080808080808080808080d08080808080808080808080c08080808080d080808080808080808080808080808080808080a0a0a0a0
a080c08080d0808080a39090909090909090909083a1b3909090b180808080808080808080a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0d380808080808080808080
c080808080607080808080627280c0808080808080808080808080808080808080808080808080808080806070808080808080808062728080808080a0a0a0a0
a080808080808080c08080818080818080a39090909090909093808080808080808080c0d1a0a0a0a0a0a0a0a0a0a0a0d38080c1808080808080806272808080
8080808080617180808080637380808080d0808080808080808080808060708080808080808080808080806171808080808080808063738080808080a0a0a0a0
a0f180808080808080808080808080c08080a3909090909093808080d080f3a0c3d08080f3a0a0a0a0a0a0a0a0a0a0a080808080c08080627280806373808080
82828282828280808080c0808080808080808080806272808080c0808061718080808080627280808080808080808080808080d08080808080c08080e3a0a0a0
a08080c08080c08080d0808080c08080808080a3909090938080808080d1a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a08080d0808080806373e180e18080c080
82828282828280808080808080808080808080808063738080808080808080808080808063738080808080808080808060708080808080808080808080a0a0a0
a080808080808080808080808080808080c0808081808180808080c08080e3a0a0a0d3e0a0a0a0a0a0a0a0a0a0a0a0a0f180808080c0d1a0a0a0a0a0c3808080
b0b0f0b0b0b0808080d0808080627280808080808080808080808080808080808080808080808080808080808080808061718080808080808080808080a0a0a0
a0f1d080c0808080f3a0a0c3e08080c080808080808080808080808080808080c18080d1a0a0a0a0a0a0a0a0a0a0a0a08080c0808080d1a0a0a0a0a0a0808080
b0b0b0b0f2b080c080808080806373808080c08080808080808080d08080808080c080808080d080c0808080808080808080808080c080808080808080e3a0a0
a08080808080d080a0a0a0a0a0a0c380d080808080808080808060708080d0808080d080a0a0a0a0a0a0a0a0a0a0a0a080808080806272a0a0a0a0a0a0f18080
d0c0e0d080d080808080c0808080808080808080808080806070808080808080808080808080808080808060708080808080808080806272808080808080a0a0
a080c08080808080a0a0a0a0a0a0a0c380808060708080c0808061718080808080808080a0a0a0a0a0a0a0a0a0a0a0a0f1c08080806373c1e3a0a0a0d3808080
8080808080808062728080808080808080d08080808080806171808080607080808080808080808080808061718080808080808080806373808080c080d1a0a0
a0f180e08080c080e3a0a0a0a0a0a0a08080806171808080808080808080c0808080c080a0a0a0a0a0a0a0a0a0a0a0a08080808080808080c0c180c180c08080
8080808080c080637380808080808080808080806272808080808080806171808080808060708080808080808080808080806272808080808080808080d0a0a0
a0c380808080808080e3a0a0a0a0a0a08080808080808080808080808080808080808080a0a0a0a0a0a0a0a0a0a0a0d380808080808080808080607080808080
80808080808080808080806070808080808080806373808080c0808080808080808080806171808080808080808080808080637380808080d08080808080a0a0
a0a0c380c080808080808080e3a0a0d380607080808080808080627280808080808080e0e3a0a0a0a0a0a0a0a0a0d3808080808080808080808061718080c080
808080806070808080c0806171808080c080808080808080808080808080808080808080808080808080808080808080d0808080808080808080808080d1a0a0
a0a0a0c3808080c0808080d08080808080617180808080808080637380808080c080808080e3a0a0a0a0a0d380c1808080806070808080c08080808080808060
708080806171808080808080808080808060708080808080808080806070808080808080808080808080c080808080808080808080627280808080e280c0a0a0
a0a0a0a0c3808080808080808080808080808080806272808080808080d0808080d080c080d1a0a0a0a0a0f1808080c080806171808080808080808080808061
7180808080808080808080808080808080617180808080c060708080617180c0808080808080c08080808060708080c0808080808063738080808080d0f3a0a0
a0a0a0a0a0c38080c08080c0808080d0808080808063738080c08080808080808080808080e0a0a0a0a0a0f180c08080808080808080d0808080808080808080
808080808080808080808080d080c0808080808080808080617180c08080808080808080808080808080806171808080808080808080808080c08080f3a0a0a0
a0a0a0a0a0a0c38080808080808080808080c0808080808080808080c08080c08080e180e1f3a0a0a0a0a0808080808080808080808080808080c08080808080
80c0808080808080c08080808080808080808080c08080808080808080808080808080c08080808080c08080808080808080808080c08080808080f3a0a0a0a0
a0a0a0a0a0a0a0c38080e18080e18080e18080e18080e18080e18080e18080e1f3a0a0a0a0a0a0a0a0a0a0c38080e18080e1808080e1808080e1808080e18080
e18080e18080e18080e18080e18080e18080e18080e18080e18080e18080e18080e18080e18080e18080f3a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
__gff__
0000000000000000000001010000000100000000000000000000000000000000000000000000000000000000010103030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c2929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929294f0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2929292b2929292929292929292b29292929292929292929292b292929292929292929292929292b292929292929292929294f0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c292929292929292929292929292929292b292929292b2929292929292929292929292929292929292929292b2929292b2929294f0a0a0a0a
0a0a4c29292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929294f0a0a0a4c292929292929292929292929292929292929292929292929292b2929292929292929292929292929292929292929292929292b2929292929292929292929292929292929294f0a0a0a
0a4c29292b29292929292929292929292b29292929292929292b2929292929292b29292929292d2d2d2d2d2d2d2d2d292b29290a0a0a292929292929292b29292929292b2929292929292929292929292929292b2929292929292929292929292929292b292929292929292929292b29292929292929292929292929290a0a0a
0a2929292929292b2929292929292929292929292b2929292929292929292929292929292b292c0f2c0f2c0f2c0f2c29292b290a0a0a29292929292929292929292929292929292b2929292b292929292929292929292929292929292929292b29292929292929292929292929292929292929292b29292b2929292b290a0a0a
0a292b2929292929292929292b2929292929292929292b2929292929292b29292929292b29292c2c2f2c2c2c2c2c2c2b2929290a0a0a2929292b2929292929292929292929292929292929292929292929292929292b29292b2929292b29292929292929292929292929292b29292929292929292929292929292929290a0a0a
0a29292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929290a0a0a292929292929292929292b2929292929292929292929292929292b29292929292929292929292929292929292929292929292929292929292929292929292929292929292929290a0a0a
0a2a080808082a2a080808082a2a2a080808082a0808090908082a0808082a08082a2a2a08082a2a2a0808082a082a2a08082a0a0a0a2929292929292929292929292929292b292929292929292b2929292929292929292929292929292929292929292b2929292b2929292929292929292b29292929292929292929290a0a0a
0a08080d08080808080828282828282828080d08081909090808282828282828282808080d0808080808080c08080d0808080c0a0a0a292929292929292b2929292929292929292929292b2929292929292929292929292b29292929292929292b29292929292929292929292b29292929292929292b292929292929290a0a0a
0a08080808080c08080828282828282828080808080809091b082828282828282828080808080808080808080808080808081d0a0a0a29292b29292929292929292b292929292b29292929292929292929292b2929292929292929292b292929292929292929292929292929292929292929292929292929292b2929290a0a0a
0a1f08080808080808080b0f0b0b0b0f0b0808082e0809090d080b0b0b0b0b0b0b0b0808080808080c080d08080808080c081d0a0a0a29292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929290a0a0a
0a08080c0808080d08080b0b0b2f0b0b0b08081a083b090908080b0f0b0f0b0b0f0b080808080d080808080808080e080808080a0a0a08082a082a2a08082a082a08082a082a082a08082a082a082a2a08082a082a08082a2a08082a082a082a08082a08082a082a08082a082a082a2a082a082a082a082a082a082a080a0a0a
0a0808080808080808080d0808080e0808081909090909091b080b0b0b0b0b2f0b0b0c080808080808080808080d080808081d0a0a0a08080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080a0a0a
0a1f080808080808080c081a0c081a0c08083b090909090938080e081a0d08081a08081a08080808080c1e080c1e08080808080a0a0a1f08080c08080808080607080808080808080806070c08082627080808080607080808080d08080808080808080808080808080808080808080808080c080808080826270808080a0a0a
0a080d0808080d08083b0909090909090909090939083a09090909090909090909090909380d083f0a0a0a0a0a0a3c0c080d080a0a0a1f080808080808080816170808080806070808161708080836370808080816170808080808080808080808262708080607080808080808060708080808080808080836370808080a0a0a
0a3c08080c080808080909090909090909090909080d08090909090909090909090909090908080a0a0a0a0a0a0a0a1f08081d0a0a0a1f08080d080808080808080808080816170808080808080808080808080d08080808080808080826270808363708081617080808080808161708080808080808080808080808080a0a0a
0a0a1f080808080808090909090909090909090938083b09090909090909090909090909091b0e0a0a0a0a0a0a0a0a080c081d0a0a0a0808080808080808080c080808080808080808080808080808080808080808080607080808080836370808080808080808080808080808080808080808080d08080808080808080a0a0a
0a0a08282828282808090909390828282828083a090909392828282828282828283a090909081d0a0a0a0a0a0a0a0a1f0808080a0a0a08080808080607080808080808080808080d0808080808080808060708080808161708080808080808080808080808080808080c080808080808080808080808080808080808080a0a0a
0a0a1f282828282819090909080828282828080809090908282828282828282828080909090d080a0a0a0a0a0a0a0a0c0e08080a0a0a1f08060708161708080d08080808080808080806070808080c0816170808080808080808080808080808080808080808080d0808262708080808080808080808080c08080808080a0a0a
0a0a080b0f0b0b0b080909091b080b0b0f0b0808090909080b0b0f0b0f0b0f0b0b080909091b1d0a0a0a0a0a0a0a0a08080c080a0a0a08081617080808080808080826270808080808161708080808080808080808080808080808080808080808082627080808080808363708080808080806070808080808080d08080a0a0a
0a0a080b0b0b2f0b0809090908080b2f0b0b0808090909080b2f0b0b0b0b0b0b0b19090909080c0a0a0a0a0a0a0a0a1f08081d0a0a0a08080808080808080808080836370808060708080808080808080826270808080808080808080c080808080836370808080808080808080c0808080816170808080808080808080a0a0a
0a0a1f0d0d0d080d0809090908080808080e08080909090808080808080c0808080809090908080a0a0a0a0a0a0a3d080808080a0a0a1f080808080808080c080808080808081617080808080d0808080836370808080806070808080808080d08080808080808080808080808080808080808080808080808080808080a0a0a
0a0a08080808080c080909091b080d0808080808090909080808080808080d0808080909091b080a0a0a0a3d081c0808080d080a0a0a080808080607080808080808080808080808080808080808080808080808080d0816170808080808080808080808080808080607080808080808080808080808080808080808080a0a0a
0a3d080c080808081909090908080808080c0808090909080d080c08080808080e1909090908083e0a0a0a1f080d08080808080a0a0a1f08080816170808080607080808080c08080607080808080c08080808080808080808080808080808080808080808080808161708080808082627080808080d082627080808080a0a0a
0a080808080c0808080909090808080808080808090909082828282828282828280809090908080c3e0a3d0c0808080808081d0a0a0a08080808080808080816170808080808080816170808080808080808080808080808080808080808080808080607080808080808080808080c36370808080808083637080808080a0a0a
0a0c082828282828080909091b0828282828080809090908282828282828282828080909091b0d08080808080808080c0808080a0a0a1f08080d08080808080808080d08080808080808080808080808080808060708080808080d082627080808081617080808080808080808080808080808080808080808080808080a0a0a
0a1f082828282828190909090808282828280808090909080b0b0b0b0b0b0b0b0b0c09090908080808080808080d0808080d080a0a0a08080808080808080c0808080808080808080808080808262708080d081617080808080808083637080808080808080808080808080808080808080808080c08080808080808080a0a0a
0a080c0b0f0f0b0b0809090908080b0b0f0b08080909090d0b0f0b0f0b0f0b0f0b080909090808080c0808080808080808081d0a0a0a0808080808080808080808080806070808080808080808363708080808080808080c0808080808080808262708080808080c0808060708080808060708080808080808080808080a0a0a
0a1f080b0b0b2f0b080909091b080b2f0b0b0808090909080b0b0b0b0b0b2f0b0b080909091b080d0808080c080808080c08080a0a0a1f0808080c0808080808080808161708080808080c0808080808080808080808080808080808080808083637080808080808080816170808080816170808080808080c080808080a0a0a
__sfx__
000d00002135021350213502135021350213502135021350213502135021350213551c3501c3501c3501c3551d3501d3501d3501d3501d3501d3501d3501d3552135021350213502135021350213502135021355
000d000015320183201c3201832015320183201c3201832015320183201c3201832015320183201c3201832011320153201832015320113201532018320153201132015320183201532011320153201832015320
000d00000924009245152401524509240092451524015245092400924515240152450924009245152401524505240052451124011245052400524511240112450524005245112401124505240052451124011245
000d00003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c625000003c62500000
000d00001f3501f3501f3501f3501f3501f3501f3501f3501f3501f3501f3501f3551c3501c3501c3501c3551a3501a3501a3501a3501a3501a3501a3501a3551f3501f3501f3501f35523350233502335023355
000d0000183201c3201f3201c320183201c3201f3201c320183201c3201f3201c320183201c3201f3201c32013320173201a3201732013320173201a3201732013320173201a3201732013320173201a32017320
000d000000240002450c2400c24500240002450c2400c24500240002450c2400c24500240002450c2400c24507240072451324013245072400724513240132450724007245132401324507240072451324013245
000d00002845028450284502845521450214552445024455284502845028450284552645026455244502445524450244502445024455214502145524450244552945029450294502945029450294552845028455
000d00000c073000003c6250000028655000000c073000000c073000003c6250000028655000003c625000000c073000003c6250000028655000000c073000000c073000003c6250000028655000003c62500000
000d0000284502845028450284551f4501f455244502445528450284552b4502b4502b4502b455294502945526450264502645026450264502645523450234551f4501f4501f4501f4501f4501f4501f4501f455
000d00002845028450284502845521450214552445024455284502845028450284552d4502d4502d4502d4552b4502b4552945029455284502845529450294552d4502d4502d4502d4502d4502d4502d4502d455
000d00002b4502b4502b4502b45529450294552845028455264502645026450264552345023450234502345523450234502345023455204502045020450204552845028450284502845028450284502845028455
000d000013320173201a3201732013320173201a3201732013320173201a3201732013320173201a3201732010320143201732014320103201432017320143201032014320173201432010320143201732014320
000d00000724007245132401324507240072451324013245072400724513240132450724007245132401324504240042451024010245042400424510240102450424004245102401024504240042451024010245
000d00002d3502d3502d3502d3502d3502d3552b3502b35529350293502935029355243502435024350243552635026350263502635026350263552835028355293502935029350293552b3502b3502b3502b355
000d00001132015320183201532011320153201832015320113201532018320153201132015320183201532013320173201a3201732013320173201a3201732013320173201a3201732013320173201a32017320
000d00000524005245112401124505240052451124011245052400524511240112450524005245112401124507240072451324013245072400724513240132450724007245132401324507240072451324013245
000d00002835028350283502835028350283552635026355233502335023350233551f3501f3501f3501f35521350213502135021350213502135021350213502135021350213502135500000000000000000000
000d00001032013320173201332010320133201732013320103201332017320133201032013320173201332015320183201c3201832015320183201c3201832015320183201c3201832015320183201c32018320
000d00000424004245102401024504240042451024010245042400424510240102450424004245102401024509240092451524015245092400924515240152450924009245152401524509240092451524015245
000d00002935029350293502935029350293552835028355263502635026350263552135021350213502135523350233502335023355263502635026350263552b3502b3502b3502b35529350293502935029355
000d00000e3201132015320113200e3201132015320113200e3201132015320113200e32011320153201132013320173201a3201732013320173201a3201732013320173201a3201732013320173201a32017320
000d000002240022450e2400e24502240022450e2400e24502240022450e2400e24502240022450e2400e24507240072451324013245072400724513240132450724007245132401324507240072451324013245
000d00002835028350283502835028350283552635026355243502435024350243551f3501f3501f3501f35520350203502035020355233502335023350233552635026350263502635528350283502835028355
000d0000183201c3201f3201c320183201c3201f3201c320183201c3201f3201c320183201c3201f3201c32010320143201732014320103201432017320143201032014320173201432010320143201732014320
000d000000240002450c2400c24500240002450c2400c24500240002450c2400c24500240002450c2400c24504240042451024010245042400424510240102450424004245102401024504240042451024010245
000d00002445024450244502445024450244502445024455214502145021450214502145021450214502145523450234502345023450234502345023450234552645026450264502645026450264502645026455
000d00002045020450204502045020450204502045020455234502345023450234502345023450234502345521450214502145021450214502145021450214502145021450214502145021450214502145021455
000d00001032014320173201432010320143201732014320103201432017320143201032014320173201432015320183201c3201832015320183201c3201832015320183201c3201832015320183201c32018320
001000001f4501f4501f4501f455234502345526450264552b4502b4502b4502b4502b4502b4552a4502a4552d4502d4502d4502d4502d4502d4552a4502a4552645026450264502645026450264502645026455
0010000013320173201a3201732013320173201a3201732013320173201a3201732013320173201a320173200e3201232015320123200e3201232015320123200e3201232015320123200e320123201532012320
001000000724007245132401324507240072451324013245072400724513240132450724007245132401324502240022450e2400e24502240022450e2400e24502240022450e2400e24502240022450e2400e245
001000000c073000003c6250000028655000000c073000000c073000003c6250000028655000003c625000000c073000003c6250000028655000000c073000000c073000003c6250000028655000003c62500000
00100000284502845028450284552b4502b4552f4502f4552d4502d4502d4502d4552b4502b4502b4502b4552b4502b4502b4502b4502b4502b45528450284552445024450244502445024450244502445024455
00100000103201332017320133201032013320173201332010320133201732013320103201332017320133200c3201032013320103200c3201032013320103200c3201032013320103200c320103201332010320
001000000424004245102401024504240042451024010245042400424510240102450424004245102401024500240002450c2400c24500240002450c2400c24500240002450c2400c24500240002450c2400c245
00100000264502645026450264552b4502b4502b4502b4552f4502f4502f4502f4502f4502f4552d4502d4552d4502d4502d4502d4502d4502d4552a4502a4552645026450264502645521450214502145021455
0010000024450244502445024455284502845028450284552b4502b4502b4502b455284502845028450284552a4502a4502a4502a4502a4502a4502a4502a4502a4502a4502a4502a45500000000000000000000
001000000c3201032013320103200c3201032013320103200c3201032013320103200c3201032013320103200e3201232015320123200e3201232015320123200e3201232015320123200e320123201532012320
0010000000240002450c2400c24500240002450c2400c24500240002450c2400c24500240002450c2400c24502240022450e2400e24502240022450e2400e24502240022450e2400e24502240022450e2400e245
001000002b4502b4502b4502b4502b4502b4552a4502a455284502845028450284552345023450234502345524450244502445024455284502845028450284552b4502b4502b4502b4502b4502b4502b4502b455
001000002f4502f4502f4502f4502f4502f4552d4502d4552b4502b4502b4502b455264502645026450264552a4502a4502a4502a4552d4502d4502d4502d4553245032450324503245032450324503245032455
001000003045030450304503045030450304552f4502f4552d4502d4502d4502d4552b4502b4502b4502b4552a4502a4502a4502a4502a4502a4552b4502b4552d4502d4502d4502d4502d4502d4502d4502d455
001000002b4502b4502b4502b4552f4502f4502f4502f45532450324503245032450324503245032450324552b4502b4502b4502b4502b4502b4502b4502b4502b4502b4502b4502b45500000000000000000000
0010000013320173201a3201732013320173201a3201732013320173201a3201732013320173201a3201732013320173201a3201732013320173201a3201732013320173201a3201732013320173201a32017320
001000000724007245132401324507240072451324013245072400724513240132450724007245132401324507240072451324013245072400724513240132450724007245132401324507240072451324013245
000f00002645026450264502645026450264552145021455264502645528450284552a4502a4552b4502b4552d4502d4502d4502d4502d4502d4502d4502d4552845028450284502845525450254502545025455
000f000012320153201a3201532012320153201a3201532012320153201a3201532012320153201a3201532010320153201932015320103201532019320153201032015320193201532010320153201932015320
000f000002240022450e2400e24502240022450e2400e24502240022450e2400e24502240022450e2400e24509240092451524015245092400924515240152450924009245152401524509240092451524015245
000f00000c073000003c6250000028655000003c625000000c073000003c62500000286550000028655286550c073000003c6250000028655000003c625000000c073000003c6250000028655000002865528655
000f00002f4502f4502f4502f4502f4502f4552d4502d4552b4502b4502b4502b455264502645026450264552a4502a4502a4502a4502a4502a4502a4502a4502a4502a4502a4502a45500000000002645026455
000f000013320173201a3201732013320173201a3201732013320173201a3201732013320173201a3201732012320153201a3201532012320153201a3201532012320153201a3201532012320153201a32015320
000f00000724007245132401324507240072451324013245072400724513240132450724007245132401324502240022450e2400e24502240022450e2400e24502240022450e2400e24502240022450e2400e245
000f00002645026450264502645026450264552545025455234502345023450234552a4502a4502a4502a4552b4502b4502b4502b4502b4502b4552a4502a4552845028450284502845526450264502645026455
000f000012320173201a3201732012320173201a3201732012320173201a3201732012320173201a3201732013320173201a3201732013320173201a3201732013320173201a3201732013320173201a32017320
000f00000b2400b24517240172450b2400b24517240172450b2400b24517240172450b2400b245172401724507240072451324013245072400724513240132450724007245132401324507240072451324013245
000f000025450254502545025455284502845028450284552d4502d4502d4502d4552b4502b4502b4502b45528450284502845028450284502845028450284502845028450284502845500000000000000000000
000f00001032015320193201532010320153201932015320103201532019320153201032015320193201532010320153201932015320103201532019320153201032015320193201532010320153201932015320
000f00000924009245152401524509240092451524015245092400924515240152450924009245152401524509240092451524015245092400924515240152450924009245152401524509240092451524015245
000200002a37022350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002f46034460344403442500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001e36022360253602a360253502a3622a3622a345000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001f1501f1501e1501e1501d1501d1501c1521c1521c1521c1521c1421c1350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00010203
00 04050603
01 07010208
00 09050608
00 0a010208
00 0b0c0d08
00 0e0f1008
00 11121308
00 14151608
00 17181908
00 07010208
00 09050608
00 0a010208
00 0b0c0d08
00 0e0f1008
00 11121308
00 14151608
00 17181908
00 07010208
00 09050608
00 0a010208
00 0b0c0d08
00 1a0f1003
02 1b1c1303
01 1d1e1f20
00 21222320
00 241e1f20
00 25262720
00 28222320
00 291e1f20
00 2a262720
02 2b2c2d20
01 2e2f3031
00 32333431
00 35363731
02 38393a31

