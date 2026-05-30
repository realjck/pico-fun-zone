pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--chip-off
--by real

local
	--current flavor
	flavor

local flavor_colors = {
	{ 0, 2 }, { 0, 4 }, { 9, 10 }, { 8, 9 },
	{ 2, 14 }, { 6, 7 }, { 12, 7 }
}

local bet = 10

local cards = {
	"ah", "2h", "3h", "4h",
	"5h", "6h", "7h", "8h",
	"9h", "10h", "jh", "qh", "kh",
	"ad", "2d", "3d", "4d",
	"5d", "6d", "7d", "8d",
	"9d", "10d", "jd", "qd", "kd",
	"as", "2s", "3s", "4s",
	"5s", "6s", "7s", "8s",
	"9s", "10s", "js", "qs", "ks",
	"ac", "2c", "3c", "4c",
	"5c", "6c", "7c", "8c",
	"9c", "10c", "jc", "qc", "kc"
}
local player_cards = {}
local adv_cards = {}

local state =
	--0:title
	0
--1:hairmenu, 2:game, 3:credits
local game_state
local player_money
local adv_money
local pot_money
local
	--current flavor
	flavor
local
	--0->5
	unlocked
local
	--0/1
	is_music

local title_state, title_t
local girl_eyes_t =
	--eyes timer
	0
local girl_eyes_left = false
local girl_talking_t = 0
local
	--0,1,2
	girl_talking_s
local girl_talking_txt
local hairmenu_t, game_t, step

local girl_state = 0

function _init()
	cartdata("chip_off_1")
	unlocked = dget(0)
	-- slot 1: 0=unset (default on), 1=on, 2=off
	is_music = (dget(1) == 2) and 0 or 1
	if is_music == 1 then music(0) end
	if not flavor then
		flavor = 1
	end
	-----
	if state == 0 then
		title_init()
	elseif state == 2 then
		game_init()
	end
end

function _update60()
	if state == 0 then
		title_update()
	elseif state == 1 then
		hairmenu_update()
	elseif state == 2 then
		game_update()
	elseif state == 3 then
		info_update()
	end
end

function _draw()
	if state == 0 then
		title_draw()
	elseif state == 1 then
		hairmenu_draw()
	elseif state == 2 then
		game_draw()
	elseif state == 3 then
		info_draw()
	end
end
-->8
--utils

--print with black outline
function print_o(txt, x, y, col)
	print(txt, x - 1, y, 0)
	print(txt, x + 1, y, 0)
	print(txt, x, y - 1, 0)
	print(txt, x, y + 1, 0)

	print(txt, x - 1, y - 1, 0)
	print(txt, x - 1, y + 1, 0)
	print(txt, x + 1, y - 1, 0)
	print(txt, x + 1, y + 1, 0)

	print(txt, x, y, col)
end

--print centered
function print_c(txt, y, col, outline)
	local posx = 64 - #txt * 2
	if outline then
		print_o(txt, posx, y, col)
	else
		print(txt, posx, y, col)
	end
end

--shuffle table
function shuffle(t)
	for i = #t, 2, -1 do
		local j = flr(rnd(i)) + 1
		t[i], t[j] = t[j], t[i]
	end
end

--anim_ease_out
function anim_ease_out(current_time, total_time)
	local t = current_time / total_time
	local eased = 1 - (1 - t) ^ 2
	return flr(30 * eased)
end

--card value to number
function card_val(card)
	local v = sub(card, 1, -2)
	if v == "a" then
		return 14
	elseif v == "k" then
		return 13
	elseif v == "q" then
		return 12
	elseif v == "j" then
		return 11
	else
		return tonum(v)
	end
end

--card suit
function card_suit(card)
	return sub(card, -1, -1)
end

--eval hand: returns rank,value
--9=straight flush
--8=four of a kind
--7=full house
--6=flush, 5=straight
--4=three of a kind
--3=two pair, 2=pair
--1=high card
function eval_hand(hand)
	local vals = {}
	local suits = {}
	for i = 1, 5 do
		add(vals, card_val(hand[i]))
		add(suits, card_suit(hand[i]))
	end

	--sort values
	for i = 1, 4 do
		for j = i + 1, 5 do
			if vals[j] > vals[i] then
				vals[i], vals[j] = vals[j], vals[i]
			end
		end
	end

	--check flush
	local is_flush = true
	for i = 2, 5 do
		if suits[i] != suits[1] then
			is_flush = false
		end
	end

	--check straight
	local is_straight = true
	for i = 2, 5 do
		if vals[i] != vals[i - 1] - 1 then
			is_straight = false
		end
	end

	--count pairs/trips/quads
	local counts = {}
	for i = 1, 5 do
		local found = false
		for j = 1, #counts do
			if counts[j][1] == vals[i] then
				counts[j][2] += 1
				found = true
			end
		end
		if not found then
			add(counts, { vals[i], 1 })
		end
	end

	--sort by count then value
	for i = 1, #counts - 1 do
		for j = i + 1, #counts do
			if counts[j][2] > counts[i][2]
					or (counts[j][2] == counts[i][2] and counts[j][1] > counts[i][1]) then
				counts[i], counts[j] = counts[j], counts[i]
			end
		end
	end

	--determine rank
	if is_straight and is_flush then
		return 9, vals[1]
	elseif counts[1][2] == 4 then
		return 8, counts[1][1]
	elseif counts[1][2] == 3 and counts[2][2] == 2 then
		return 7, counts[1][1]
	elseif is_flush then
		return 6, vals[1]
	elseif is_straight then
		return 5, vals[1]
	elseif counts[1][2] == 3 then
		return 4, counts[1][1]
	elseif counts[1][2] == 2 and counts[2][2] == 2 then
		return 3, counts[1][1]
	elseif counts[1][2] == 2 then
		return 2, counts[1][1]
	else
		return 1, vals[1]
	end
end

--ai decision making
--returns: "call","raise","fold"
function ai_decide_bet()
	local rank, val = eval_hand(adv_cards)

	--strong hand: raise
	if rank >= 4 then
		return "raise"
		--medium hand: call
	elseif rank >= 2 then
		return "call"
		--weak hand: fold or bluff
	else
		if rnd() < 0.2 then
			return "call"
		else
			return "fold"
		end
	end
end

--ai draw decision
--returns array of card indices to exchange
function ai_decide_draw()
	local vals = {}
	local suits = {}
	for i = 1, 5 do
		add(vals, card_val(adv_cards[i]))
		add(suits, card_suit(adv_cards[i]))
	end

	local rank, val = eval_hand(adv_cards)
	local to_exchange = {}

	--keep strong hands
	if rank >= 4 then
		return {}
	end

	--try to improve pairs
	if rank == 2 then
		for i = 1, 5 do
			if card_val(adv_cards[i]) != val then
				add(to_exchange, i)
			end
		end
		if #to_exchange > 3 then
			to_exchange = { to_exchange[1], to_exchange[2], to_exchange[3] }
		end
		return to_exchange
	end

	--exchange all low cards
	for i = 1, 5 do
		if card_val(adv_cards[i]) < 10 then
			add(to_exchange, i)
		end
	end

	if #to_exchange > 3 then
		to_exchange = { to_exchange[1], to_exchange[2], to_exchange[3] }
	end
	return to_exchange
end
-->8
--title

title_choices = {
	"start game", "music on/off",
	"info"
}

function title_init()
	title_state = 1
	title_t = 1
end

--update title
function title_update()
	if title_t < 200 then
		title_t += 1
	else
		title_t = 100
	end

	update_girl_eyes()

	if btnp(⬆️) then
		title_state -= 1
		if title_state == 0 then
			title_state = 1
		else
			sfx(1)
		end
	end
	if btnp(⬇️) then
		title_state += 1
		if title_state > #title_choices then
			title_state = #title_choices
		else
			sfx(1)
		end
	end
	--action
	if btnp(🅾️) then
		sfx(1)
		if title_state == 1 then
			--start game
			hairmenu_init()
			state = 1
		elseif title_state == 2 then
			--toggle music
			if is_music == 1 then
				is_music = 0
				music(-1)
				dset(1, 2)
			else
				is_music = 1
				music(0)
				dset(1, 1)
			end
		elseif title_state == 3 then
			--credits
			state = 3
		end
	end
end

--draw title
function title_draw()
	cls(3)
	palt(11, true)
	palt(0, false)
	--girl
	draw_girl_medal()
	--title
	if title_t < 50 then
		sspr(
			0, 0, 74, 16,
			26, 9 - (25 - title_t / 2)
		)
	else
		sspr(0, 0, 74, 16, 26, 9)
	end
	--menu
	local posy = 82
	for i = 1, #title_choices do
		txt = title_choices[i]
		posx = 64 - #txt * 2
		if title_state == i then
			print_o(txt, posx, posy, 7)
		else
			print(txt, posx, posy, 0)
		end
		posy += 8
	end
	--music on/off
	sspr(
		is_music == 1 and 0 or 11,
		31, 11, 11, 113, 3
	)
	--warning nsfw
	if title_t % 100 < 50 then
		print(
			"spicy stuff ahead",
			30, 110, 7
		)
		print("16+ only!", 48, 118, 7)
	end
end

function update_girl_eyes()
	if girl_eyes_t == 0 then
		if rnd() < 1 / 200 then
			girl_eyes_t = 20
		end
	else
		girl_eyes_t -= 1
	end
end

function draw_girl_medal()
	pal(12, flavor_colors[flavor][1])
	pal(13, flavor_colors[flavor][2])
	sspr(62, 0, 63, 63, 34, 15)
	rectfill(34, 15, 45, 32, 1)
	if girl_eyes_t > 0 then
		sspr(107, 80, 16, 4, 52, 40)
	end
	--medal circle
	local crad = 31.5
	local ly = 15
	for lx = 0, 128 do
		local cval = lx - (64 - crad)
		cval = cval / (crad * 2)
		cval = cval * 2 - 1
		cval = 1 - sqrt(1 - cval * cval)
		local lh = cval * crad + 0.01
		line(lx, ly, lx, ly + lh, 3)
		line(
			lx, ly + crad * 2 - lh,
			lx, ly + crad * 2, 3
		)
	end
	rectfill(0, 0, 128, ly, 3)
	rectfill(0, ly + crad * 2, 128, 128, 3)
	circ(64, ly + crad, crad, 0)
end

-->8
--hair menu

function hairmenu_init()
	hairmenu_t = 1
end

function hairmenu_update()
	update_girl_eyes()

	hairmenu_t += 1
	if hairmenu_t >= 100 then
		hairmenu_t = 0
	end

	if btnp(❎) then
		title_init()
		state = 0
	end

	if btnp(⬅️) then
		flavor -= 1
		if flavor == 0 then
			flavor = 1
		else
			sfx(1)
		end
	end

	if btnp(➡️) then
		flavor += 1
		if flavor > 2 + unlocked then
			flavor = 2 + unlocked
		else
			sfx(1)
		end
	end

	if btnp(⬇️) then
		local fl = flavor
		if flavor <= 3 then
			fl = flavor + 4
			sfx(1)
		elseif flavor == 4 then
			fl = flavor + 3
			sfx(1)
		end
		if fl <= 2 + unlocked then
			flavor = fl
		end
	end

	if btnp(⬆️) then
		if flavor >= 5 then
			flavor -= 4
			sfx(1)
		end
	end

	if btnp(🅾️) then
		sfx(1)
		game_init()
		state = 2
	end
end

function hairmenu_draw()
	cls(3)
	palt(11, true)
	palt(0, false)
	--girl
	draw_girl_medal()
	--text
	print(
		"what's your flavor?",
		24, 82, 7
	)
	--buttons
	local posx = 29
	local posy = 91
	for i = 1, 4 do
		local act = flavor == i
		local avail = i <= 2 + unlocked
		draw_hair_bt(
			posx, posy, i,
			act, avail
		)
		posx += 18
	end
	posx, posy = 38, 107
	for i = 5, 7 do
		local act = flavor == i
		local avail = i <= 2 + unlocked
		draw_hair_bt(
			posx, posy, i,
			act, avail
		)
		posx += 18
	end
	--arrows
	if hairmenu_t < 50 then
		pal()
		palt(0, false)
		palt(11, true)
		pal(0, 7)
		sspr(14, 17, 7, 6, 13, 104)
		sspr(
			14, 17, 7, 6, 105, 104,
			7, 6, true
		)
		pal()
	end
end

function draw_hair_bt(x, y, fl, active, available)
	palt(0, false)
	palt(11, true)
	if active then
		pal(0, 0)
	else
		pal(0, 3)
	end
	pal(1, flavor_colors[fl][1])
	pal(3, flavor_colors[fl][1])
	pal(2, flavor_colors[fl][2])
	pal(4, flavor_colors[fl][2])
	if not available then
		pal(3, 0)
		pal(4, 0)
	end
	sspr(0, 17, 14, 14, x, y)
	pal()
end
-->8
--game & girl

local win_p = {
	"nice hand.",
	"it's yours.", "you got it.",
	"well played.", "take it down.",
	"fair enough.", "lucky dog.",
	"nice play.", "got me."
}
local fold_i = {
	"i'm out.", "fold.",
	"i'm done.", "too rich for me.",
	"no thanks.", "i'll wait."
}
local win_i = {
	"that's mine.", "i'll take that.",
	"gotcha.", "not today.", "nice try.",
	"pay up.", "all mine."
}

function rand_phrase(t)
	return t[flr(rnd(#t)) + 1]
end

local player_cards_x = { 4, 21, 38, 55, 72 }
local player_cards_y = { 128, 128, 128, 128, 128 }
local deal_cards_anim_t

local player_bet_choice
local player_raised
local player_draw_choice
local player_draw_selection = {}
local ai_timer
local ai_choice_result
local next_card_index
local showdown_result = false

--returns which cards form the best hand
function get_winning_indices(hand)
	local vals = {}
	for i = 1, 5 do
		add(vals, card_val(hand[i]))
	end
	local rank, val = eval_hand(hand)
	local r = {false,false,false,false,false}
	if rank==9 or rank==7 or rank==6 or rank==5 then
		return {true,true,true,true,true}
	elseif rank==8 or rank==4 or rank==2 then
		for i=1,5 do
			if vals[i]==val then r[i]=true end
		end
	elseif rank==3 then
		local cnt={}
		for i=1,5 do
			cnt[vals[i]]=(cnt[vals[i]] or 0)+1
		end
		for i=1,5 do
			if cnt[vals[i]]==2 then r[i]=true end
		end
	else
		for i=1,5 do
			if vals[i]==val then r[i]=true break end
		end
	end
	return r
end

function game_init()
	game_t = 0
	player_money = 100
	adv_money = 100
	pot_money = 0
	girl_state = 0
	game_state = "deal_cards"
	ai_timer = 0
	ai_choice_result = ""
	next_card_index = 11
end

-------------
--game update
-------------
function game_update()
	girl_update()
	--deal_cards
	if game_state == "deal_cards" then
		showdown_result = false
		shuffle(cards)
		player_cards = {}
		adv_cards = {}
		for i = 1, 5 do
			add(player_cards, cards[i])
		end
		for i = 6, 10 do
			add(adv_cards, cards[i])
		end
		player_draw_selection = { false, false, false, false, false }
		next_card_index = 11
		deal_cards_anim_t = 0
		player_cards_y = { 128, 128, 128, 128, 128 }
		game_state = "deal_cards_anim"
		--deal_cards_anim
		--deal_cards_anim
	elseif game_state == "deal_cards_anim" then
		deal_cards_anim_t += 1
		local c_index = flr(deal_cards_anim_t / 30) + 1
		if c_index <= 5 then
			player_cards_y[c_index] = flr(130 - anim_ease_out(deal_cards_anim_t % 30, 30))
		end
		if deal_cards_anim_t == 150 then
			player_money -= bet
			adv_money -= bet
			pot_money += bet * 2
			player_bet_choice = 1
			player_raised = false
			game_state = "player_bet"
		end
		--player_bet
	elseif game_state == "player_bet" then
		if btnp(⬅️) then
			if player_bet_choice > 1 then
				player_bet_choice -= 1
				if player_money == 0 and player_bet_choice == 2 then
					player_bet_choice = 1
				end
				sfx(1)
			end
		elseif btnp(➡️) then
			if player_bet_choice < 3 then
				player_bet_choice += 1
				if player_money == 0 and player_bet_choice == 2 then
					player_bet_choice = 3
				end
				sfx(1)
			end
		elseif btnp(🅾️) then
			sfx(1)
			if player_bet_choice == 1 then
				--call
				player_draw_choice = 1
				player_draw_selection = { false, false, false, false, false }
				game_state = "player_draw"
			elseif player_bet_choice == 2 then
				--raise
				player_money -= bet
				pot_money += bet
				player_raised = true
				player_draw_choice = 1
				player_draw_selection = { false, false, false, false, false }
				game_state = "player_draw"
			elseif player_bet_choice == 3 then
				--drop
				girl_talk(rand_phrase(win_i))
				adv_money += pot_money
				pot_money = 0
				game_state = "end_round"
			end
		end
		--player draw
	elseif game_state == "player_draw" then
		if btnp(⬅️) then
			if player_draw_choice > 1 then
				player_draw_choice -= 1
				sfx(1)
			end
		elseif btnp(➡️) then
			if player_draw_choice < 5 then
				player_draw_choice += 1
				sfx(1)
			end
		elseif btnp(❎) then
			if player_draw_selection[player_draw_choice] then
				player_draw_selection[player_draw_choice] = false
				sfx(2)
			else
				local count = 0
				for i = 1, 5 do
					if player_draw_selection[i] then count += 1 end
				end
				if count < 3 then
					player_draw_selection[player_draw_choice] = true
					sfx(2)
				end
			end
		elseif btnp(🅾️) then
			sfx(1)
			--exchange player cards
			for i = 1, 5 do
				if player_draw_selection[i] then
					player_cards[i] = cards[next_card_index]
					next_card_index += 1
					player_cards_y[i] = 128
				end
			end
			ai_timer = 60
			game_state = "draw_wait"
		end
		--draw_wait: 0.5s anim + 0.5s pause
	elseif game_state == "draw_wait" then
		ai_timer -= 1
		if ai_timer >= 30 then
			local anim_t = 60 - ai_timer
			for i = 1, 5 do
				if player_draw_selection[i] then
					player_cards_y[i] = flr(131 - anim_ease_out(anim_t, 30))
				end
			end
		end
		if ai_timer == 0 then
			game_state = "ai_bet"
		end
		--ai bet
	elseif game_state == "ai_bet" then
		if ai_timer == 0 then
			ai_timer = 60
			ai_choice_result = ai_decide_bet()
			if adv_money == 0 then
				if player_raised then
					ai_choice_result = "fold"
				else
					ai_choice_result = "call"
				end
			end
			if ai_choice_result == "fold" then
				girl_talk(rand_phrase(fold_i))
				player_money += pot_money
				pot_money = 0
			elseif ai_choice_result == "raise" then
				girl_talk("i raise!")
				local amount = player_raised and bet * 2 or bet
				adv_money -= amount
				pot_money += amount
			else
				girl_talk("i call!")
				if player_raised then
					adv_money -= bet
					pot_money += bet
				end
			end
		else
			ai_timer -= 1
			if ai_timer == 0 then
				if ai_choice_result == "fold" then
					game_state = "end_round"
				else
					game_state = "ai_draw"
				end
			end
		end
		--ai draw
	elseif game_state == "ai_draw" then
		if ai_timer == 0 then
			local to_exchange = ai_decide_draw()
			for i = 1, #to_exchange do
				adv_cards[to_exchange[i]] = cards[next_card_index]
				next_card_index += 1
			end
			ai_timer = 30
		else
			ai_timer -= 1
			if ai_timer == 0 then
				game_state = "showdown"
			end
		end
		--showdown
	elseif game_state == "showdown" then
		if btnp(🅾️) then
			sfx(1)
			local p_rank, p_val = eval_hand(player_cards)
			local a_rank, a_val = eval_hand(adv_cards)

			if p_rank > a_rank or (p_rank == a_rank and p_val > a_val) then
				girl_talk(rand_phrase(win_p))
				player_money += pot_money
			elseif p_rank < a_rank or (p_rank == a_rank and p_val < a_val) then
				girl_talk(rand_phrase(win_i))
				adv_money += pot_money
			else
				girl_talk("tie!")
				player_money += pot_money / 2
				adv_money += pot_money / 2
			end
			pot_money = 0
			showdown_result = true
			game_state = "end_round"
		end
		--end_round
	elseif game_state == "end_round" then
		if btnp(🅾️) then
			sfx(1)
			if player_money <= 0 then
				game_state = "game_over"
			elseif adv_money <= 0 then
				adv_money += 100
				player_money -= 100--reset money
				girl_state += 1
				sfx(3)
				if girl_state >= 4 then
					adv_money = 0
					if unlocked < 5 then
						unlocked += 1
						dset(0, unlocked)
					end
					game_state = "game_win"
				else
					game_state = "deal_cards"
				end
			else
				game_state = "deal_cards"
			end
		end
		--game_over
	elseif game_state == "game_over" then
		if btnp(🅾️) then
			sfx(1)
			title_init()
			state = 0
		end
		--game_win
	elseif game_state == "game_win" then
		if btnp(🅾️) then
			sfx(1)
			title_init()
			state = 0
		end
	end
end

function girl_update()
	game_t += 1
	if game_t >= 11000 then
		game_t = 1000
	end

	if game_t == 25 then
		girl_talk("let's play!")
	end

	update_girl_eyes()
	if rnd() < 1 / 300 then
		girl_eyes_left = not girl_eyes_left
	end

	if girl_talking_t > 0 then
		if girl_talking_t % 8 == 0 then
			local s = girl_talking_s
			repeat
				girl_talking_s = flr(rnd(3))
			until girl_talking_s != s
			sfx(0)
		end
		girl_talking_t -= 1
		girl_eyes_left = false
	end
end

function girl_talk(txt)
	girl_talking_txt = txt
	girl_talking_t = #txt * 12
end

-----------
--game draw
-----------
function game_draw()
	cls(3)
	palt(0, false)
	draw_girl()

	line(0, 71, 128, 71, 0)
	money_draw()

	if game_state == "player_bet" then
		draw_player_cards()
		print_o("call", 12, 75, 7)
		if player_money == 0 then
			print("raise", 36, 75, 5)
		else
			print_o("raise", 36, 75, 7)
		end
		print_o("drop", 64, 75, 7)
		palt(11, true)
		palt(0, false)
		pal(0, 10)
		local cursor_x = { 17, 43, 69 }
		sspr(14, 23, 5, 3, cursor_x[player_bet_choice], 82)
		pal()
	elseif game_state == "player_draw" then
		draw_player_cards()
		print_o("press ❎ to select", 8, 75, 7)
		print_o("cards to swap", 20, 83, 7)
		local cursor_x = { 9, 26, 43, 60, 77 }
		palt(11, true)
		palt(0, false)
		pal(0, 10)
		sspr(14, 23, 5, 3, cursor_x[player_draw_choice], 122)
		pal()
	elseif game_state == "showdown" or game_state == "end_round" then
		draw_adv_cards(true)
		draw_player_cards()

		local pr, pv = eval_hand(player_cards)
		local ar, av = eval_hand(adv_cards)
		local hnames = { "high card", "pair", "two pair", "3 of kind", "straight", "flush", "full house", "4 of kind", "str. flush" }

		print_o("me: " .. hnames[ar], 4, 70, 15)
		print_o("you: " .. hnames[pr], 4, 96, 10)

		if game_state == "showdown" then
			print_o("press 🅾️ to see results", 4, 122, 7)
		else
			print_o("press 🅾️ for next round", 4, 122, 7)
		end
	elseif game_state == "game_over" then
		print_o("game over!", 26, 90, 8)
		print_o("press 🅾️ to quit", 14, 99, 7)
	elseif game_state == "game_win" then
		print_o("you win!", 30, 90, 10)
		print_o("press 🅾️ to quit", 14, 99, 7)
	else
		draw_player_cards()
	end
end

--girl draw
function draw_girl()
	pal(12, flavor_colors[flavor][1])
	pal(13, flavor_colors[flavor][2])
	sspr(0, 0, 128, 71, 0, 0)
	rectfill(0, 0, 73, 16, 1)
	rectfill(0, 0, 21, 41, 1)
	--states
	if girl_state>=1 then
		sspr(0,71,50,32,51,39)--boobs
		if girl_state<3 then
			sspr(51,71,39,32,60,39)--top
		end
		if girl_state==1 then
			sspr(50,59,7,12,50,59)--bottom fix
		end
	end
	if girl_state>=2 then
		sspr(0,103,49,25,0,46)--legs
		if girl_state<4 then
			sspr(50,103,31,25,15,46)--string
		end
	end
	--eyes
	if girl_eyes_left
	and game_state!="game_over"
	and game_state!="game_win"
	then
		sspr(90, 80, 16, 4, 80, 25)
	end
	if girl_eyes_t > 0 then
		sspr(107, 80, 16, 4, 80, 25)
	end
	--girl text
	if girl_talking_t > 0 then
		if girl_talking_s == 1 then
			sspr(90, 84, 7, 4, 84, 36)
		elseif girl_talking_s == 2 then
			sspr(98, 84, 7, 4, 84, 36)
		end
		local posx = 74 - #girl_talking_txt * 4
		print(girl_talking_txt, posx, 2, 6)
		line(posx, 8, 72, 8, 6)
		line(72, 8, 75, 11, 6)
	end
end

--draw_player_cards
function draw_player_cards()
	local hl_idx = nil
	if game_state == "showdown"
	or (game_state == "end_round") then
		hl_idx = get_winning_indices(player_cards)
	end
	for i = 1, 5 do
		local turned = false
		if player_draw_selection[i]
		and game_state == "player_draw"
		then
			turned = true
		end
		local hl = hl_idx and hl_idx[i] and (game_t%40<20)
		card(
			player_cards[i],
			player_cards_x[i],
			player_cards_y[i],
			turned, hl
		)
	end
end

--draw_adv_cards
function draw_adv_cards(show_face)
	local adv_x = { 4, 21, 38, 55, 72 }
	local adv_y = 75
	local hl_idx = nil
	if game_state == "showdown"
	or (game_state == "end_round") then
		hl_idx = get_winning_indices(adv_cards)
	end
	for i = 1, 5 do
		local hl = hl_idx and hl_idx[i] and (game_t%40<20)
		card(show_face and adv_cards[i] or false, adv_x[i], adv_y, false, hl)
	end
end

function card(val, x, y, turned, hl)
	pal()
	palt(11, true)
	palt(0, false)
	if hl then
		pal(5, 6)
	end
	--sprite for card base
	sspr(81, 103, 16, 22, x, y)

	if not turned then
		rectfill(x + 1, y + 1, x + 13, y + 19, 7)
		local value = sub(val, 1, -2)
		local suit = sub(val, -1, -1)
		local col = 0
		if suit == "h" or suit == "d" then
			col = 8
		end
		print(value, x + 2, y + 2, col)
		local spx
		if suit == "d" then
			spx = 90
		elseif suit == "h" then
			spx = 117
		elseif suit == "s" then
			spx = 99
		elseif suit == "c" then
			spx = 108
		end
		sspr(spx, 71, 9, 9, x + 3, y + 9)
	end
	pal()
end

--money draw
function money_draw()
	pal()
	rectfill(93, 74, 125, 125, 1)
	rect(93, 74, 125, 125, 0)
	print("me", 106, 77, 15)
	print(
		adv_money,
		110 - #tostr(adv_money) * 2, 85, 7
	)
	print("you", 104, 110, 10)
	print(
		player_money,
		110 - #tostr(player_money) * 2, 118, 7
	)
	local potx = 110 - #("pot:" .. pot_money) * 2
	print("pot:" .. pot_money, potx, 98, 7)
	print("pot:", potx, 98, 12)
end

-->8
--info

function info_update()
	if title_t < 200 then
		title_t += 1
	else
		title_t = 100
	end
	if btnp(🅾️) then
		state=0
	end
end

function info_draw()
	pal()
	cls(3)
	print_c("about chip-off", 11, 10, true)
	print_c("a simplified poker showdown", 21, 14, true)
	print_c("use call to stay in,", 31, 7)
	print_c("raise to push your luck,", 38, 7)
	print_c("or drop if the heat", 45, 7)
	print_c("is too much.", 52, 7)
	print_c("win to reveal it all", 62, 15, true)
	print_c("and unlock new hair colors", 70, 15, true)
	line(30,83,98,83,0)
	print_c("made in 2026 by real burger", 91, 12, true)
	print_c("free music by fettuccini", 99, 12, true)
	if title_t<150 then
		print_c("press 🅾️ to continue", 112, 7, true)
	end
end
__gfx__
bb00000000b0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000bbb000000000bb00000000b111111111111111111111111111111111111111111111111111111
b0dddddddd0dddd0bbbbbb000bbbbbbbbbbbbbbbbbb0ddddddd0b0ddddddddd00dddddddd0111111111111111111111111111111111111111111111111111111
0ddddddddd0dddd0bbbbb0ddd0bbbbbbbbbbbbbbbb0ddddddddd0dddddddddd0ddddddddd0111111111111111111111111111111111111111111111111111111
0dddd000000dddd0bbbbb0ddd0bbbbbbbbbbbbbbbb0dddd00ddd0dddd0000000ddd00000001111111111111111cccccccc111111111111111111111111111111
0eeee000000eeee00000b00000000000000bbbbbbb0eeee00eee0eeee0000000eee000000b1111111111111ccccddddcccccc111111111111111111111111111
0eeee0bbbb0eeeeeeeee00eee0eeeeeeeee0b000000eeee00eee0eeee0000000eee000000b11111111111cccddddddccdccccc11111111111111111111111111
0eeee0bbbb0eeeeeeeeee0eee0eeeeeeeeee0eeeee0eeee00eee0eeeeeeeeee0eeeeeeeee0111111111ccccddddddccdcccccccc111111111111111111111111
0ffff0bbbb0ffff00ffff0fff0ffff00ffff0fffff0ffff00fff0ffffffffff0fffffffff01111111cccccddddddcddcccccccdcc11111111111111111111111
0ffff0bbbb0ffff00ffff0fff0ffff00ffff0000000ffff00fff0ffff0000000fff0000000111111ccccccddddddcdcccccccdcdcc1111111111111111111111
0ffff000000ffff00ffff0fff0ffff00ffff0000000ffff00fff0ffff0000000fff000000b11111cccccddcddddcdccccdddddccdcc111111111111111111111
0777777777077770077770777077777777770bbbbb0777777777077770bbbbb07770bbbbbb1111ccccdddddccddcdcccdddccccccccc11111111111111111111
0077777777077770077770777077777777700bbbbb0077777770077770bbbbb07770bbbbbb1111cdddcccdddccdcdccccdccdccccccc11111111111111111111
b00000000000000000000000007777000000bbbbbbb000000000000000bbbbb00000bbbbbb111cddcccccccdccdccccccccdccccccccc1111111111111111111
bb00000000b0000bb0000b0000777700000bbbbbbbbb0000000bb0000bbbbbbb000bbbbbbb11ccccccccccccccccccccdddccccccccccc111111111111111111
bbbbbbbbbbbbbbbbbbbbbbbbb077770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11cccccccccccccccfcccdddcdddcccccccc111111111111111111
bbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11ccccccccffffffffffcccddcddddcccccc111111111111111111
bbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1cccccccffffffffffffcccccccdccddccccc11111111111111111
bbbbb0000bbbbbbb0bbbb111111111111111111111111111111111111111111111111111111ccccccfffffffffffffccccdddcdcccdcccc11111111111111111
bbb00111100bbbb00bbbb111111111111111111111111111111111111111111111111111111ccccccffffffffffffffcccccddddcccdccc11111111111111111
bb0111111110bb0000000111111112442244224411111111111111111111111111111111111cccccffffffffffffffffcccccdddccccdcc11111111111111111
b011113311110b00000001111111442244224411442211111111111111111111111111111111ccc0fffffffffffffffffccccccdddccccc11111111111111111
b011131131110bb00bbbb1111111442244224122442244211111111111111111111111111111ccc0000fffffffffffffffcccccccccccccc1111111111111111
01111311311110bb0bbbb1111111224422442144224422411111111111111111111111111c111cc04400ffffff000000fffccccccccccccc1111111111111111
01113333331110bb0bb11111111122442244214422442241111111111111111111111111c1111cc044440ffff00444440ffccccccccccccc1111111111111111
02224444442220b000b11111111144224422412244224421411111111111111111111111c111ccc000004fffff44444444ffccccdcccccdc1111111111111111
022244444422200000011111111144224422142244224412442111111111111111111111cc1cccc007000ffffff0000044ffccccddccccdc1111111111111111
b022444444220b11111111111111224422441244224421442244211111111111111111111cccccc077000fffff07700000fffccccddcccdc1111111111111111
b022222222220b111111111111112244224412442244214422442211111111111111111111cccc0ff700fffffff77000fffffcccccddccdc1111111111111111
bb0222222220bb11111111111111442244221422442214224422442111111111111111cccccccc0fffffffffffff700ffffffcccccddcccdc111111111111111
bbb00222200bbb1111111111111144224421442244221422442244211111111111111cddcccccc0fffffffffffffffffffffeccccccdcccdc111111111111111
bbbbb0000bbbbb111111111111112244224122442241224422442211111111111111cddccccccc0ffff2ffffffffffffefffeccfcccdcccccc11111111111111
bb0000000bbbb0000000bb1111112244224122442241224422442211111111111111cdcccccccc0ffff2ffffffffffffffffeceecccdccccccc1111111111111
b00bbbbb00bb00bbbbb00b1111114422442144224412442244224111111111111111ccccccccccc0fff2244ffffffffffffeecaccccdccccdccc111111111111
00bbbbbbb0000bbbbb000011111144224412400000024422442241111111111111100000ccccccc0ffff24fffffffffffffecccccccccdcccdcc111111111111
0bbb0000bb00bbb0000bb0111111224422100ffffff022442244111111111111100ffff000ccccc0ffffffffffffffffffeeccccccdccdccccdcc11111111111
0bbb0bb0bb00bbb0000bb01111112244220fffffff00224422411111111111100ffffffff000cccc0fffffffffffffffffeecccccccccdccccccc11111111111
0bbb0bb0bb00bbb00b0bb0111111442240ffffff00224422442111111111110ffffffffffff0cccc0fff8888ff8ffffffee0cccccdcccdccccccc11111111111
0bb00b00bb00bb00b00bb011111114220ffff0001422442244111111111110fffffffffffff00cccc0fff88888ffffffee0ccccccdccdcccccccc11111111111
0bb00b00bb00b000b00bb01111111110ffff0fff004422442211111111110fffffffffffffff00ccc0fff8888ffffffee00cccccdcccdccccccc111111111111
00bbbbbbb00000bbbbbb001111111110fff0fffff00422442111111111110fffffffffffffff080ccc0fffffffffffee002ccccddccdccccccc1111111111111
b00bbbbb00bb00bbbbb00b1111111110ffffff000f024422111111111110fffffffffffffff088000220ffffffffff00222ccccdccdcccccccc1111111111111
bb0000000bbbb0000000bb1111111110fffff0fff0f04422111111111100ffffffffffffff08800222220ffffffff0ee22cccccdccdcccccccc1111111111111
11111111111111111111111111111110ffff0ffff0f0124111111111110fffffffffffffff088002222220ffff000ee222cccccdcdccccccccc111c111111111
111111111111111111111111111111110ffffff000f0111111111111100ffffffffffffff0880ff022222e0000eeeee222ccccccdccccccccccc11c111111111
111111111111111111111111111111110fffff0fff0111111111111110fffffffffffffff0880fff02222eeeeeeeee22220cccccccccccccccccccc111111111
1111111111111111111111111100000000ffffffff011111111111110ffffffffff4ffff08880ffff2222eeeeeeeee22200000cccdccccccccccccc111111111
1111111111111111111111100088888880ffffffff011111111111110fffffffff4fffe08880ffffff222eeeeeeee22200888000ccdccccccccccc1111111111
11111111111111111111100888888888880fffffff01111111111110ffffffffff4ffe088880ffffffff2eeeeeee222208880f000ccdccccccccc11111111111
11111111111111111110088888888888880fffffff00111111111110fffffffff44fe088880ffffffffffeeeeee222f20880ffff000cdccccccc111111111111
111111111111111110088888888888888880ffffff0000011111110ffffffffee4400888880fffffffffeeeeeeeefff08880ffffff00cdccccccc11111111111
111111111111111108888888888888888880ffffff088000111110ffffffffee20088888880ffffffffffffeeffffff0880ffffffff00ccccccccc1111111111
111111111111111088888888888888888880ffffff08880000010ffffffffee20888888880ffffffffffffffffffff08880fffffffff00cccccccc1111111111
1111111111111108888888888888888888880fffff08888000000ffffffeee208888888880ffffffffffffffffffff08880fffffffff00ccccccccc111111111
1111111111111088888888888888888888880fffff0888800000ffffffeee2088888888880fffffffffffffffffff08880fffffffffff0ccccccccc111111111
1111111111110efffff888888888888888880fffff008888000fffffffeee2088888888880fffffffffffffffffff08880fffffffffff0ccccccccc111111111
111111111110ffffffff88888888888888880ffffff08888200fffffffee40888888888880ffffffffffffffffff088880fffffffffff0cccccc1cc111111111
11111111110ffffffffff8888888888888880ffffff0888880fffffffeee40888888888880ffffffffffffffffff08880ffffffffffff0cccccc1cc111111111
1111111110ffffffffffff888888888888880ffffff088880ffffffffeee008888888888880effeefffffffffff088880ffffffffffff0ccccc11cc111111111
111111110fffffffffffffe88888888888880fffffff0880ffffffffeeee008888888888880eeeeeefffffffff0888880ffffffffffff0cccc11cc1111111111
11111110ffffffffffffffe88888888888280fffffff0880fffffffeeee00088888888888880eeeefffffffff08888804ffffffffffff0ccc11cc11111111111
1111110fffffffffffffffee8888888888820ffffffff00ffffffffeeee020888888888888880eeeffffffff0888888044fffffffffff0cc1111111111111111
111110ffffffffffffffffee8888888888820ffffffff04fffffffeeee02208888888888888880eeefffff0088888880444fffffffffe0ccc111111111111111
11110ffffffffffffffffeeee888888888820fffffffff4ffffffeeee082200888888888888888000000008888888800400efffffffee0ccc11c111111111111
1110fffffffffffffffffeeee888888888820ffffffffff44effeeee0282220888888888888888888888888888888804000eefffffeee0cccccc111111111111
110ffffffffffffffffffeeee888828828820ffffffffffeeeeeeee02282222088888888888888888888888888888800000eeeefeeeee0ccccc1111111111111
10fffffffffffffffffffeeeee88882882820ffffffffffeeeeeee022888822208888288888888888888888888888800000eeeeeeeeee01ccc11111111111111
0fffffffffffffffffffeeeeee888822882220ffffffffffeeeee0222888822220028228828888888888888888888800000eeeeeeeeeee011111111111111111
ffffffffffffffffffeeeeeeee888822888220fffffffffeeeee00222888822222202222288888888888888888888000010eeeeeeeeeee011111111111111111
ffffffffffffffffeeeeeeeeee888822288220ffffffffeeeee0022222888822222222222288888888888888888220011110eeeeeeeeee011111111111111111
fffffffffffffffeeeeeeeeee08888222288220ffffffeeeee00222222288822222222222222888888888888888200011110eeeeeeeeee011111111111111111
ffffffffffffffeeeeeeeeee008888822222220fffffeeeee002222222228222222222222222282888888888888000111110eeeeeeeeee011111111111111111
1111111110fffffffffffffffff00000fffffffffffee00200b0fffffffffffffff0000000fffffffffffee002bbbb8bbbbbbbb0bbbbbbb000bbbb888b888bbb
111111110ffffffffffffffffff000220ffffffffff0022200bfffffffffffffff00f000220ffffffffff00222bbb888bbbbbb000bbbbb00000bb888888888bb
111111100ffffffffffffffffff0222220ffffffff0ee22000bffffffffffffff00ff0222220ffffffff0ee220bb88888bbbb00000bbbb00000bb888888888bb
11111110fffffffffffffffffff02222220ffff000ee222000bfffffffffffff00fff02222220ffff000ee2220b8888888bb0000000bb0b000b0b888888888bb
11111100ffffffffffffffffffff022222e0000eeeee222000bffffffffffff00fffff022222e0000eeeee2220888888888000000000000b0b000888888888bb
1111110ffffffffffffffffffffff02222eeeeeeeee2222000bfffffffffff00fffffff02222eeeeeeeee22220b8888888b000000000000000000b8888888bbb
111110ffffffffff4ffff0ffffffff2222eeeeeeeee2220000bfffffff4fff0fffffffff2222eeeeeeeee22200bb88888bbb00b0b00bb00b0b00bbb88888bbbb
111110fffffffff4fffe0ffffffffff222eeeeeeee222fffffbffffff4fff00ffffffffff222eeeeeeee220fffbbb888bbbbbbb0bbbbbbbb0bbbbbbb888bbbbb
11110ffffffffff4ffe0fffffffffffff2eeeeeee2222fffffbffffff4ff00fffffffffffff2eeeeeee2220fffbbbb8bbbbbbb000bbbbbb000bbbbbbb8bbbbbb
11110fffffffff44fe0fffffffffffffffeeeeee222f2fffffbfffff44f00fffffffffffffffeeeeee222f0fff00070ffffff00000b02200ffffff00000bbbbb
1110ffffffffee4400fffffffffffffffeeeeeeeefffffffffbfffee4400fffffffffffffffeeeeeeeefff0fff00077fffff000077b02220fffff022222bbbbb
110ffffffffee200ffffffffffffffffffffeeffffffffffffbffee2000fffffffffffffffffffeeffffff0ffff007fffffff00077bf000fffffff02220bbbbb
10ffffffffee20ffffffffffffffffffffffffffffffffffffbfee2000ffffffffffffffffffffffffffff0fffffffffffffff007fbffffffffffff000fbbbbb
00ffffffeee2ffffffffffffffffffffffffffffffffffffffbee200000fffffffffffffffffffffffffff0fff8888fffbf888fffbbbbbbbbbbbbbbbbbbbbbbb
0ffffffeee2fffffffffffffffffffffffffffffffffffffffbe20f0f0f00fffffffffffffffffffffffff0ffff87788fbf8778ffbbbbbbbbbbbbbbbbbbbbbbb
fffffffee2fffeefffffffffffffffffffffffffffffffffffb00f0f0f0f00ffffffffffffffffffffffff0ffff8888ffbf8008ffbbbbbbbbbbbbbbbbbbbbbbb
fffffffe0fffe2eeffffffffffffffffffffffffffffffffffb000000000f00fffffffffffffffffffffff0ffffffffffbff88fffbbbbbbbbbbbbbbbbbbbbbbb
ffffffee0fffe22effffffffffffffffffffffffffffffffffb0000000000f00ffffffffffffffffffffff0fff0000000000000000bbbbbbbbbbbbbbb000000b
ffffffee0ffffeefffffffffeffeefffffffffffffffffffffb00000000000f00feffeefffffffffffffff0fff066660666606666000000bbbbbbbbbb066660b
fffffeee0ffffffffffffffffee2eefffffffffffffff0ffffb000000000000f00fee2eeffffffffffffff00ff066660666606666066660bbbbbbbbbb066660b
ffffeeee0ffffffffffffffffe2effffffffffffffff04ffffb0000000000000f00e2ef000000000ffffff00ff066660666606666066660bbbbbbbbbb066660b
ffffeeee0ffffffffffffffff2efffffffffffffffff044fffb00000000000000f020000f0f0f0f0000fff004f0666606666066660000000000000000066660b
fffeeee00fffffffffffffff22ffffffffffffffffff0444ffb000000000000000200f0f0f0f0f0f0f00ff00440666606666066660666600666666660066660b
ffeeee0e0ffffffffffffffe2ffffffffffffffffff00400efb0000000000000000000000000000000000000400666606666066660666606666666666066660b
feeee02e20fffffffffffff2fffffffffffffffffff04000eeb0000000000000000000000000000000000000000666606666066660666606666006666066660b
eeee022e220fffffffffffe2fffffffffffffffffff00000eeb2000000000000020000000000000000000000000666606666066660666606666006666066660b
eee022effe00ffffffffff22fffffffffffffffffff00000eebe000000000000220000000000000000000000000666606666066660666606666006666066660b
ee0222efff2000fffffffe22ffffffffffeefffffff00000eebf200000000000220000000000000000000000000666606666066660666606666006666000000b
e0022effffe2200000002222fffffffffeeeefffff000010eebfe22000000022220000000000000000000000100666666666666660666606666006666066660b
0022effffffe222222222222ffffffffee2eeeffff0011110ebffe2222222222222000000000000000000011110066666666666600666606666006666066660b
0222efffffffee2222222222ffffffffee22eeffff0011110ebfffee2222222222220000000000000000001111b000000000000000000000000000000000000b
222effffffffffeeeee222222ffffffffeeeeffff00111110ebfffffeeeee22222220000000000000000011111bbbbbbbeeeeeeeee22200000bbbbbbbbbbbbbb
11111111111111111111111000fffffff0ffffffff0111111b1111111100000000000ffffffff0111b5555555555555bbeeeeeeee220fffff00bbbbbbbbbbbbb
11111111111111111111100fffffffffff0fffffff0111111b11111100000000000000fffffff0111544224422442245beeeeeee2220ffffff000bbbbbbbbbbb
111111111111111111100fffffffffffff0fffffff0011111b11110000000000000000fffffff00115442244224422450eeeeee222f0ffffffff000bbbbbbbbb
1111111111111111100ffffffffffffffff0ffffff0000011b1100f0f0f0f0f00000000ffffff00005224422442244250eeeeeeefff0ffffffffff00bbbbbbbb
11111111111111110ffffffffffffffffff0ffffff0ffe001b100f0f0f0f0f0f0000000ffffff0ffe5224422442244250ffeeffffff0fffffffffff00bbbbbbb
1111111111111110fffffffffffffffffff0ffffff0fffe00b00000000000000f000000ffffff0fff5442244224422450ffffffffff0ffffffffffff00bbbbbb
111111111111110fffffffffffffffffffff0fffff0fffe00b0ffffffffff0000f000000fffff00ff5442244224422450ffffffffff0ffffffffffff00bbbbbb
11111111111110ffffffffffffffffffffff0fffff0ffffe0bfffffffffffff000f00000fffff000f5224422442244250ffffffffff0fffffffffffff0bbbbbb
1111111111110fffffffffffffffffffffff0fffff00fffe0bffffffffffffff000f0000fffff000f5224422442244250ffffffffff0fffffffffffff0bbbbbb
111111111110ffffffffffffffffffffffff0ffffff0ffffebfffffffffffffff000f000ffffff00f5442244224422450ffffffffff0fffffffffffff0bbbbbb
11111111110fffffffffffffffffffffffff0ffffff0ffffebffffffffffffffff000f00ffffff00f5442244224422450ffffffffff0fffffffffffff0bbbbbb
1111111110ffffffffffffffffffffffffff0ffffff0ffff0bfffffffffffffffff000f0ffffff0005224422442244250ffffffffff0fffffffffffff0bbbbbb
111111110fffffffffffffffffffffffffff0fffffff0ff0fbffffffffffffffffff0f00fffffff005224422442244250ffffffffff00ffffffffffff0bbbbbb
11111110ffffffffffffffffffffffffffff0fffffff0ff0fbffffffffffffffffff00f0fffffff005442244224422450ffffffffff00ffffffffffff0bbbbbb
1111110ffffffffffffffffffffffffffff20ffffffff00ffbfffffffffffffffffff000ffffffff05442244224422450ffffffffff004fffffffffff0bbbbbb
111110fffffffffffffffffffffffffffff20ffffffff04ffbfffffffffffffffffff000ffffffff0522442244224425000000000ff0044fffffffffe0bbbbbb
11110ffffffffffffffffffffffffffffff20fffffffff4ffbfffffffffffffffffff000fffffffff52244224422442500000000000000000000000000bbbbbb
1110fffffffffffffffffffffffffffffff20ffffffffff44bfffffffffffffffffff200fffffffff54422442244224508888888888888888888888880bbbbbb
110fffffffffffffffffffffffffffffffe20ffffffffffeebfffffffffffffffffff200fffffffff54422442244224508888888888888888888888880bbbbbb
10fffffffffffffffffffffffffffffffee20ffffffffffeebffffffffffffffffffe200fffffffff52244224422442508888888888888888888888880bbbbbb
0fffffffffffffffffffffffffffffffeee220ffffffffffebfffffffffffffffffee2000ffffffffb55555555555550088888888888888888888888880bbbbb
fffffffffffffffffffffffffffffffeeee220fffffffffeebffffffffffffffffeee2000ffffffffbb0000000000000b88888888000010222222222220bbbbb
ffffffffffffffffffffffffffffffeeeee220ffffffffeeebfffffffffffffffeee20000ffffffffbbbbbbbbbbbbbbbb88888822001111022eeeeeeee0bbbbb
ffffffffffffffffffffffffffffeeeeeee2220ffffffeeeebfffffffffffffeeeee200000ffffffebbbbbbbbbbbbbbbb8888882000111102eeeeeeeee0bbbbb
fffffffffffffffffffffffffffeeeeeee22220fffffeeeeebffffffffffffeeeee2200000fffffeebbbbbbbbbbbbbbbb888888000111110eeeeeeeeee0bbbbb
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111100002222000000111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111110002222220020000011111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111000022222200200000000111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111100000222222022000000020011111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111000000222222020000000202001111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111110000022022220200002222200200111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111100002222200220200022200000000011111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111102220002220020200002002000000011111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111022000000020020000000020000000001111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000022200000000000111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000f000222022200000000111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111100000000ffffffffff0002202222000000111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111110000000ffffffffffff0000000200220000011111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111000000fffffffffffff0000222020002000011111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111000000ffffffffffffff000002222000200011111111111111111
11111111111111111111111111111244224422441111111111111111111111111111111111100000ffffffffffffffff00000222000020011111111111111111
11111111111111111111111111114422442244114422111111111111111111111111111111110000fffffffffffffffff0000002220000011111111111111111
11111111111111111111111111114422442241224422442111111111111111111111111111110000000fffffffffffffff000000000000001111111111111111
111111111111111111111111111122442244214422442241111111111111111111111111101110004400ffffff000000fff00000000000001111111111111111
1111111111111111111111111111224422442144224422411111111111111111111111110111100044440ffff00444440ff00000000000001111111111111111
1111111111111111111111111111442244224122442244214111111111111111111111110111000000004fffff44444444ff0000200000201111111111111111
1111111111111111111111111111442244221422442244124421111111111111111111110010000007000ffffff0000044ff0000220000201111111111111111
1111111111111111111111111111224422441244224421442244211111111111111111111000000077000fffff07700000fff000022000201111111111111111
1111111111111111111111111111224422441244224421442244221111111111111111111100000ff700fffffff77000fffff000002200201111111111111111
1111111111111111111111111111442244221422442214224422442111111111111111000000000fffffffffffff700ffffff000002200020111111111111111
1111111111111111111111111111442244214422442214224422442111111111111110220000000fffffffffffffffffffffe000000200020111111111111111
1111111111111111111111111111224422412244224122442244221111111111111102200000000ffff2ffffffffffffefffe00f000200000011111111111111
1111111111111111111111111111224422412244224122442244221111111111111102000000000ffff2ffffffffffffffffe0ee000200000001111111111111
11111111111111111111111111114422442144224412442244224111111111111111000000000000fff2244ffffffffffffee0a0000200002000111111111111
11111111111111111111111111114422441240000002442244224111111111111110000000000000ffff24fffffffffffffe0000000002000200111111111111
1111111111111111111111111111224422100ffffff022442244111111111111100ffff000000000ffffffffffffffffffee0000002002000020011111111111
11111111111111111111111111112244220fffffff00224422411111111111100ffffffff00000000fffffffffffffffffee0000000002000000011111111111
1111111111111111111111111111442240ffffff00224422442111111111110ffffffffffff000000fff8888ff8ffffffee00000020002000000011111111111
111111111111111111111111111114220ffff0001422442244111111111110fffffffffffff0000000fff88888ffffffee000000020020000000011111111111
11111111111111111111111111111110ffff0fff004422442211111111110fffffffffffffff000000fff8888ffffffee0000000200020000000111111111111
11111111111111111111111111111110fff0fffff00422442111111111110fffffffffffffff0000000fffffffffffee00200002200200000001111111111111
11111111111111111111111111111110ffffff000f024422111111111110fffffffffffffff00f000220ffffffffff0022200002002000000001111111111111
11111111111111111111111111111110fffff0fff0f04422111111111100ffffffffffffff00ff0222220ffffffff0ee22000002002000000001111111111111
11111111111111111111111111111110ffff0ffff0f0124111111111110ffffffffffffff00fff02222220ffff000ee222000002020000000001110111111111
111111111111111111111111111111110ffffff000f0111111111111100fffffffffffff00fffff022222e0000eeeee222000000200000000000110111111111
111111111111111111111111111111110fffff0fff0111111111111110fffffffffffff00fffffff02222eeeeeeeee2222000000000000000000000111111111
1111111111111111111111111100000000ffffffff011111111111110ffffffffff4fff0fffffffff2222eeeeeeeee2220000000020000000000000111111111
1111111111111111111111100000000000ffffffff011111111111110fffffffff4fff00ffffffffff222eeeeeeee220fffff000002000000000001111111111
11111111111111111111100000000000000fffffff01111111111110ffffffffff4ff00fffffffffffff2eeeeeee2220ffffff00000200000000011111111111
11111111111111111110000000000000000fffffff00111111111110fffffffff44f00fffffffffffffffeeeeee222f0ffffffff000020000000111111111111
1111111111111111100f0f0f0f0f00000000ffffff0000011111110ffffffffee4400fffffffffffffffeeeeeeeefff0ffffffffff0002000000011111111111
111111111111111100f0f0f0f0f0f0000000ffffff0ffe00111110ffffffffee2000fffffffffffffffffffeeffffff0fffffffffff000000000001111111111
11111111111111100000000000000f000000ffffff0fffe000010ffffffffee2000ffffffffffffffffffffffffffff0ffffffffffff00000000001111111111
1111111111111100ffffffffff0000f000000fffff00ffe000000ffffffeee200000fffffffffffffffffffffffffff0ffffffffffff00000000000111111111
11111111111110ffffffffffffff000f00000fffff000ffe0000ffffffeee20f0f0f00fffffffffffffffffffffffff0fffffffffffff0000000000111111111
1111111111110ffffffffffffffff000f0000fffff000ffe000fffffffee00f0f0f0f00ffffffffffffffffffffffff0fffffffffffff0000000000111111111
111111111110ffffffffffffffffff000f000ffffff00fffe00fffffffe0000000000f00fffffffffffffffffffffff0fffffffffffff0000000100111111111
11111111110ffffffffffffffffffff000f00ffffff00fffe0fffffffee00000000000f00ffffffffffffffffffffff0fffffffffffff0000000100111111111
1111111110ffffffffffffffffffffff000f0ffffff000ff0ffffffffee000000000000f00feffeefffffffffffffff0fffffffffffff0000001100111111111
111111110ffffffffffffffffffffffff0f00fffffff00f0ffffffffeee0000000000000f00fee2eeffffffffffffff00ffffffffffff0000011001111111111
11111110fffffffffffffffffffffffff00f0fffffff00f0fffffffeeee00000000000000f00e2ef000000000ffffff00ffffffffffff0000110011111111111
1111110fffffffffffffffffffffffffff000ffffffff00ffffffffeeee000000000000000f020000f0f0f0f0000fff004fffffffffff0001111111111111111
111110ffffffffffffffffffffffffffff000ffffffff04fffffffeeee00000000000000000200f0f0f0f0f0f0f00ff0044fffffffffe0000111111111111111
11110fffffffffffffffffffffffffffff000fffffffff4ffffffeeee0e0000000000000000000000000000000000000040efffffffee0000110111111111111
1110ffffffffffffffffffffffffffffff200ffffffffff44effeeee02e2000000000000000000000000000000000000000eefffffeee0000000111111111111
110fffffffffffffffffffffffffffffff200ffffffffffeeeeeeee022e2200000000000002000000000000000000000000eeeefeeeee0000001111111111111
10fffffffffffffffffffffffffffffffe200ffffffffffeeeeeee022effe00000000000022000000000000000000000000eeeeeeeeee0100011111111111111
0fffffffffffffffffffffffffffffffee2000ffffffffffeeeee0222efff20000000000022000000000000000000000000eeeeeeeeeee011111111111111111
fffffffffffffffffffffffffffffffeee2000fffffffffeeeee0022effffe2200000002222000000000000000000000010eeeeeeeeeee011111111111111111
ffffffffffffffffffffffffffffffeee20000ffffffffeeeee0022effffffe2222222222222000000000000000000011110eeeeeeeeee011111111111111111
ffffffffffffffffffffffffffffeeeee200000ffffffeeeee00222efffffffee22222222222200000000000000000011110eeeeeeeeee011111111111111111
fffffffffffffffffffffffffffeeeee2200000fffffeeeee00222effffffffffeeeee222222200000000000000000111110eeeeeeeeee011111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333300000000003000333333333000000000000000000000333333300000000000000000333333333333300000000000000000000000000000000033
33333333333007707770703070333333333077707770777007707770333333307700777007707770333333333333301111111111111111111111111111111033
33333333333070007070703070333333333070707070070070007000333333307070707070707070333333333333301111111111111111111111111111111033
3333333333307030777070307033333333307700777007007770770333333330707077007070777033333333333330111111111111fff1fff111111111111033
3333333333307000707070007000333333307070707007000070700033333330707070707070700033333333333330111111111111fff1f11111111111111033
3333333333300770707077707770333333307070707077707700777033333330777070707700703333333333333330111111111111f1f1ff1111111111111033
3333333333330000000000000000333333300000000000000000000033333330000000000000003333333333333330111111111111f1f1f11111111111111033
3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333330111111111111f1f1fff111111111111033
3333333333333333333a333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
333333333333333333aaa33333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333aaaaa3333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111117771777111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111117171717111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111117771717111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111171717111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111171777111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111ccc11cc1ccc1111177717771111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111c1c1c1c11c111c1111717171111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111ccc1c1c11c11111177717171111033
33333555555555555533335555555555555333355555555555553333555555555555533335555555555555333333301111c111c1c11c111c1171117171111033
33335777777777777753357777777777777533577777777777775335777777777777753357777777777777533333301111c111cc111c11111177717771111033
33335700077777777750357000777777777503570007777777775035700077777777750357070777777777503333301111111111111111111111111111111033
33335777077777777750357077777777777503577707777777775035707077777777750357070777777777503333301111111111111111111111111111111033
33335770077777777750357000777777777503570007777777775035700077777777750357007777777777503333301111111111111111111111111111111033
33335777077777777750357770777777777503570777777777775035707077777777750357070777777777503333301111111111111111111111111111111033
33335700077777777750357000777777777503570007777777775035700077777777750357070777777777503333301111111111111111111111111111111033
33335777777777777750357777777777777503577777777777775035777777777777750357777777777777503333301111111111111111111111111111111033
33335777777777777750357777777777777503577777777777775035777777777777750357777777777777503333301111111111111111111111111111111033
33335777777077777750357777700077777503577777707777775035777770007777750357777700077777503333301111111111a1a11aa1a1a1111111111033
33335777770007777750357777000007777503577777000777775035777700000777750357777000007777503333301111111111a1a1a1a1a1a1111111111033
33335777700000777750357777000007777503577770000077775035777700000777750357777000007777503333301111111111aaa1a1a1a1a1111111111033
3333577700000007775035777070007077750357770000000777503577707000707775035777070007077750333330111111111111a1a1a1a1a1111111111033
33335770000000007750357700070700077503577000000000775035770007070007750357700070700077503333301111111111aaa1aa111aa1111111111033
33335770000000007750357700000000077503577000000000775035770000000007750357700000000077503333301111111111111111111111111111111033
33335777007070077750357770070700777503577700707007775035777007070077750357770070700777503333301111111111111111111111111111111033
33335777777077777750357777770777777503577777707777775035777777077777750357777770777777503333301111111111111111111111111111111033
33335777770007777750357777700077777503577777000777775035777770007777750357777700077777503333301111111111117771777111111111111033
33335777777777777750357777777777777503577777777777775035777777777777750357777777777777503333301111111111117171717111111111111033
33335777777777777750357777777777777503577777777777775035777777777777750357777777777777503333301111111111117771717111111111111033
33333555555555555500335555555555555003355555555555550033555555555555500335555555555555003333301111111111111171717111111111111033
33333300000000000003333000000000000033330000000000000333300000000000003333000000000000033333301111111111111171777111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333301111111111111111111111111111111033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333

__sfx__
000300001d070000001a0760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001507023070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000226402c640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011f2014070130701507016070190701c0701f07020070210702107022070230702407025070260702707028070290702a0702a0502a0402b0002c0002d0002e0001c000160001000009000040000000000000
15100000160430c0300c0350c035356130c0000e0300e030160430e0300e0300e032356130e0350e0350e03516043100301003510035356130c0000e0300e030160430e0300e0300e032356130e0320e0320e032
0d1000001c0341c0301c0351c0350c0000c0001d0301d0301d0341d0301d0301d0321d0341d0351d0351d0351f0341f0301f0351f0350c0000c0001d0301d0301d0341d0301d0301d0321d0341d0321d0321d032
15100000160430c0300c0350c035356130c0000e0300e030160430e0300e0300e032356130e0350e0350e03516043100301003510035356130c0000f0300f035160430e0300e0300e032356130e0320e0320e032
0d1000001c0341c0301c0351c0350c0000c0001d0301d0301d0341d0301d0301d0321d0341d0351d0351d0351f0341f0301f0351f0350c0001e0001e0301e0351d0341d0301d0301d0321d0341d0321d0321d032
051000002874428743007002a7002b7402b7432b7002b7002474424740247402474026741267422674226745287412874026740267402474024745217451f7401f7401f7401f7421f7421f7351f7352174524755
05100000007000070028740287432a7002b7412b7402b74024744247402474024743267402674026740267452874128740267402674024740247452d7452b7402b7402b7422b7422b7422b743000001f0001f000
15100000160430c0300c0350c035356130c0000e0300e030160430e0300e0300e032356130e0350e0350e03516043100301003510035356130c0000f0300f035160430e0300e0300e03235613100351003210033
0d1000001c0341c0301c0351c0350c0000c0001d0301d0301d0341d0301d0301d0321d0341d0351d0351d0351f0341f0301f0351f0350c0001e0001e0301e0351d0341d0301d0301d0321f0341f0352003220033
1510000016043110301103511035356130c0001303013030160431303013030130303561313035130351303516043100301003510035356130c00015030150301604315030150301503235613150321503215032
0d100000210342103021035210350c0000c0001c0301c0301a0341a0301a0301c0311c0341c0351a0351a0351f0341f0301f0351f0350c0000c00018030180301803418030180301803218034180321803218032
0510000024700187002b7402b7432d7402174528741287402b7412b7402b7402d7412d7402d7402b7402b74300700007002b740297402874029740260002874128740267402674224742247421f7451f7421f743
0510000024700247002474426740267402674028740287402b7412b7402b7401f7452b74529740287402674524730267302b7402d7402b74028740267302874228733247302673224722217221f732217551f755
0510000024744247402474326741267402674528740287432b7442b7402b7402d7412d7402d7402b7402b74300700007002b7402b7432d7402f74000000307403074030730307323072230722307123074532745
15100000160430e0300e0330e00035613100401003510000160431104011043110003561312040120431303016043130301303513035356131303213032130321604313022130221302235613130121301213015
151000001d0341d0321d0331d0001c0441c0421c0351c000150341504215043000001a0311a0321a0331803018032180321803218032180321803218032180321802218022180221802218012180121801218015
051000003573435730357332670034734347303473328700307343073030733217002d7312d7302d7352b7302b7302b7302b7302b7302b7322b7222b7222b7222b7222b7222b7222b7122b7122b7122b7122b715
151000000c0340c0300c0350c0353c6000c0000e0300e0300e0340e0300e0300e0320e0340e0350e0350e035100341003010035100353c6000c0000e0300e0300e0340e0300e0300e0320e0340e0320e0320e032
151000000c0340c0300c0350c0353c6000c0000e0300e0300e0340e0300e0300e0320e0340e0350e0350e035100341003010035100353c6000c0000f0300f0350e0340e0300e0300e0320e0340e0320e0320e032
151000000c0340c0300c0350c0353c6000c0000e0300e0300e0340e0300e0300e0320e0320e0350e0350e035100341003010035100353c6000c0000f0300f0350e0340e0300e0300e0320e034100351003210033
15100000110341103011035110353c6000c00013030130301303413030130301303013034130351303513035100341003010035100353c6000c00015030150301503415030150301503215034150321503215032
151000000e0340e0320e0330e00010044100421003510000110441104211043110001204112042120431303013032130321303513035130321303213032130321302213022130221302213012130121301213015
__music__
01 04055355
00 06075353
00 04050854
00 06070955
00 04050854
00 0a0b0955
00 0c0d0e55
00 0c0d0f55
00 0c0d1055
02 11121355
01 14055355
00 15075353
00 14050854
00 15070955
00 14050854
00 160b0955
00 170d0e55
00 170d0f55
00 170d1055
02 18121355

