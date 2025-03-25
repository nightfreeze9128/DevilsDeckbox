function add_joker_to_game(arg_key, arg_loc, arg_joker)
	arg_joker.key = arg_key
	arg_joker.order = #G.P_CENTER_POOLS["Joker"] + 1

	G.P_CENTERS[arg_key] = arg_joker
	table.insert(G.P_CENTER_POOLS["Joker"], arg_joker)
	table.insert(G.P_JOKER_RARITY_POOLS[arg_joker.rarity], arg_joker)

	G.localization.descriptions.Joker[arg_key] = arg_loc
end

local card_calculate_joker_ref = Card.calculate_joker
function Card.calculate_joker(self, context)
	local calculate_joker_ref = card_calculate_joker_ref(self, context)

	return calculate_joker_ref
end

-- clueless deck card update
local function clueless_card_update(card)
	if card.ability.set ~= "Enhanced" then
		card:start_dissolve(nil, true)
	end
end

local Back_apply_to_run_ref = Back.apply_to_run
function Back:apply_to_run(...)
	Back_apply_to_run_ref(self, ...)

	-- treasure deck start of run effect
	if self.effect.config.treasure then
		G.E_MANAGER:add_event(Event({
			func = function()
				local card = create_card("Tarot", G.consumeables, false, nil, nil, nil, "c_temperance", "deck")
				card:add_to_deck()
				G.consumeables:emplace(card)

				local card = create_card("Tarot", G.consumeables, false, nil, nil, nil, "c_temperance", "deck")
				card:add_to_deck()
				G.consumeables:emplace(card)

				return true
			end,
		}))
	end

	-- clueless deck start of run effect
	if self.effect.config.clueless then
		G.E_MANAGER:add_event(Event({
			func = function()
				local card = create_card("Tarot", G.consumeables, false, nil, nil, nil, "c_fool", "deck")
				card:add_to_deck()
				card:set_edition('e_negative')
				G.consumeables:emplace(card)

				local card = create_card("Tarot", G.consumeables, false, nil, nil, nil, "c_fool", "deck")
				card:add_to_deck()
				card:set_edition('e_negative')
				G.consumeables:emplace(card)

				local card = create_card("Tarot", G.consumeables, false, nil, nil, nil, "c_fool", "deck")
				card:add_to_deck()
				card:set_edition('e_negative')
				G.consumeables:emplace(card)

				local card = create_card("Tarot", G.consumeables, false, nil, nil, nil, "c_fool", "deck")
				card:add_to_deck()
				card:set_edition('e_negative')
				G.consumeables:emplace(card)

				local card = create_card("Tarot", G.consumeables, false, nil, nil, nil, "c_fool", "deck")
				card:add_to_deck()
				card:set_edition('e_negative')
				G.consumeables:emplace(card)

				return true
			end,
		}))
	end

	-- scourge deck start of run effect
	if self.effect.config.scourge then
		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.add_card({set = 'Joker', area = G.jokers, rarity = 'Common', no_edition = true})
				SMODS.add_card({set = 'Joker', area = G.jokers, rarity = 'Common', no_edition = true})
				SMODS.add_card({set = 'Joker', area = G.jokers, rarity = 'Common', no_edition = true})
				SMODS.add_card({set = 'Joker', area = G.jokers, rarity = 'Common', no_edition = true})
				SMODS.add_card({set = 'Joker', area = G.jokers, rarity = 'Common', no_edition = true})
				return true
			end,
		}))
	end
end

-- code for trigger events for decks
local Back_trigger_effect_ref = Back.trigger_effect
function Back:trigger_effect(args, ...)
	Back_trigger_effect_ref(self, args, ...)

	if not args then return end

	-- general statement to check if ante 1 boss blind has just been defeated
	if G.GAME.round_resets.blind_ante == 1 and args.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
		-- treasure deck "price" event
		if self.effect.config.treasure then
			G.E_MANAGER:add_event(Event({
				func = function()
					ease_ante(6)
					G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
					G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante+6
					return true
				end,
			}))
		end
		
		-- chortle deck "price" event
		if self.effect.config.chortle then
			G.E_MANAGER:add_event(Event({
				func = function()
					G.GAME.joker_rate = 0
					return true
				end,
			}))
		end

		-- clueless deck "price" event
		if self.effect.config.clueless then
			G.E_MANAGER:add_event(Event({
				func = function()
					for idx = #G.playing_cards, 1, -1 do
						clueless_card_update(G.playing_cards[idx])
					end
					return true
				end,
			}))
		end

		-- scourge deck "price" event
		if self.effect.config.scourge then
			G.E_MANAGER:add_event(Event({
				func = function()
					SMODS.add_card({set = 'Joker', area = G.jokers, key = "j_madness", edition = 'e_negative', stickers = {'eternal'}})
					
					-- sets the sell value of all jokers to $-10 (shoutout paperback)
					for _, v in ipairs(G.jokers.cards) do
						v.sell_cost = -10
					end
					
					self.effect.config.scourge_price = true

					return true
				end,
			}))
		end
	end
end

-- atlas
SMODS.Atlas({
	key = "devils_deckbox",
	path = "devils_deckbox.png",
	px = 71,
	py = 95,
})

-- treasure deck
SMODS.Back({
	atlas = "devils_deckbox",
	config = {
		dollars = 196,
		treasure = true,
	},
	key = "treasure",
	loc_txt = {
		name = "Treasure Deck",
		text = {
			"Start with {C:money}$200{} and",
			"{C:attention}2{} copies of {C:tarot,T:c_temperance}Temperance{}",
			"{C:inactive}at a price...{}",
		},
	},
	name = "Treasure Deck",
	pos = { x = 0, y = 0 },

})

-- chortle deck
SMODS.Back({
	atlas = "devils_deckbox",
	config = {
		joker_slot = 2,
		chortle = true,
	},
	key = "chortle",
	loc_txt = {
		name = "Chortle Deck",
		text = {
			"{C:attention}+2{} Joker slots",
			"{C:inactive}at a price...{}",
		},
	},
	name = "Chortle Deck",
	pos = { x = 1, y = 0 },

})

-- clueless deck
SMODS.Back({
	atlas = "devils_deckbox",
	config = {
		vouchers = {
			"v_tarot_merchant",
			"v_tarot_tycoon",
		},
		clueless = true,
	},
	key = "clueless",
	loc_txt = {
		name = "Clueless Deck",
		text = {
			"Start with {C:tarot,T:v_tarot_tycoon}Tarot Tycoon{}",
			"and {C:attention}5{} {C:dark_edition,T:e_negative}Negative{} copies",
			"of {C:tarot,T:c_fool}The Fool{}",
			"{C:inactive}at a price...{}",
		},
	},
	name = "Clueless Deck",
	pos = { x = 2, y = 0 },

})

-- scourge deck
SMODS.Back({
	atlas = "devils_deckbox",
	config = {
		scourge = true,
		scourge_price = false,
	},
	key = "scourge",
	loc_txt = {
		name = "Scourge Deck",
		text = {
			"Start with {C:attention}5{}", 
			"random {C:common}Common{} Jokers",
			"{C:inactive}at a price...{}",
		},
	},
	name = "Scourge Deck",
	pos = { x = 3, y = 0 },

	-- while scourge deck "price" is active, set all new joker sell values to $-10
	-- triggers whenever any card is added, still a bit redundant but shouldnt lag anymore
	calculate = function(self, back, context)
		if context.buying_card and back.effect.config.scourge_price then
			-- sets the sell value of all jokers to $-10 (shoutout paperback)
			for _, v in ipairs(G.jokers.cards) do
				v.sell_cost = -10
			end

			return {
				cardarea = G.jokers, 
				buying_card = true,
				back = back
			}
		end
	end
})

-- contrarilogue deck
SMODS.Back({
	atlas = "devils_deckbox",
	config = {
		dollars = 196,
		treasure = true,
		joker_slot = 2,
		chortle = true,
		vouchers = {
			"v_tarot_merchant",
			"v_tarot_tycoon",
		},
		clueless = true,
		scourge = true,
		scourge_price = false,
	},
	key = "contrarilogue",
	loc_txt = {
		name = "Contrarilogue Deck",
		text = {
			"{C:dark_edition}Make a deal with the devil{}",
			"{C:dark_edition}at your own peril...{}",
		},
	},
	name = "Contrarilogue Deck",
	pos = { x = 0, y = 1 },

	-- while scourge deck "price" is active, set all new joker sell values to $-10
	calculate = function(self, back, context)
		if context.buying_card and back.effect.config.scourge_price then
			-- sets the sell value of all jokers to $-10 (shoutout paperback)
			for _, v in ipairs(G.jokers.cards) do
				v.sell_cost = -10
			end

			return {
				cardarea = G.jokers, 
				buying_card = true,
				back = back
			}
		end
	end
})
