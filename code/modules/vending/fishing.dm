/obj/machinery/vending/fishing
	name = "\improper Tackle Box 2000"	
	desc = "Fishing peaked in 2000!"
	icon = 'yogstation/icons/obj/vending.dmi'
	icon_state = "fishing"
	icon_deny = "fishing-deny"
	product_slogans = "Don't tell my wife which bank I went to!;Fish fear me. Women love me.;If you want me to listen to you... talk about FISHING!;Good things come to those who bait.;Why did the lizard cross the road?"
	vend_reply = "Go get 'em, tiger!"
	products = list(/obj/item/reagent_containers/food/snacks/bait/apprentice = 15,
					/obj/item/reagent_containers/food/snacks/bait/journeyman = 10,
					)
	contraband = list(/obj/item/reagent_containers/food/snacks/bait/type = 3)
	premium = list(/obj/item/reagent_containers/food/snacks/bait/master = 5)

	default_price = 50
	extra_price = 75
	payment_department = ACCOUNT_SRV

/obj/item/clothing/fishing
	name = "fishing"
	desc = "damn"
	slot_flags = ITEM_SLOT_EARS
	var/bonus_fishing_power
	var/mob/living/carbon/human/fisher
	var/obj/item/twohanded/fishingrod/rod
	var/fishingslot = SLOT_EARS

/obj/item/clothing/fishing/cap
	name = "fishing cap"
	desc = "damn"
	icon_state = "fishing_cap"
	item_state = "fishing_cap"
	alternate_worn_icon = 'yogstation/icons/mob/head.dmi'
	icon = 'yogstation/icons/obj/clothing/hats.dmi'
	slot_flags = ITEM_SLOT_HEAD
	fishingslot = SLOT_HEAD
	bonus_fishing_power = 5

/obj/item/clothing/fishing/vest
	name = "fishing vest"
	desc = "damn"
	icon_state = "fishing_vest"
	item_state = "fishing_vest"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi' //idk why this isn't working
	slot_flags =  ITEM_SLOT_OCLOTHING
	fishingslot = SLOT_W_UNIFORM
	bonus_fishing_power = 10

/obj/item/clothing/fishing/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == fishingslot)
		START_PROCESSING(SSprocessing, src)
		fisher = user

/obj/item/clothing/fishing/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(fishingslot	) == src)
		STOP_PROCESSING(SSprocessing, src)
		fisher = null
		rod.fishing_power = initial(rod.fishing_power)
		rod.recalculate_power()

/obj/item/clothing/fishing/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/item/clothing/fishing/process() //could be on equipped but then you'd need to reequip
	if(!fisher)
		return
	var/obj/item/held_item = fisher.get_active_held_item()
	if(!istype(held_item))
		held_item = fisher.get_inactive_held_item()
	if(held_item == rod)
		rod.fishing_power += bonus_fishing_power
		rod.recalculate_power()
		return PROCESS_KILL
	

		