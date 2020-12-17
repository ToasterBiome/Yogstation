/mob/living/simple_animal/hostile/asteroid/plasma_wisp
	name = "plasma wisp"
	desc = "Sentient plasma that was forgotten on Lavaland long ago. It's kinda cute."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "plasma_wisp"
	icon_living = "plasma_wisp"
	icon_dead = "plasma_wisp_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 40
	friendly = "wubbs at"
	speak_emote = list("jingles")
	speed = 6
	maxHealth = 180
	health = 180
	harm_intent_damage = 0
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "scorches"
	attack_sound = 'sound/weapons/whip.ogg'
	vision_range = 5
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/stack/ore/plasma = 15)
	guaranteed_butcher_results = list(/obj/item/stack/ore/plasma = 10)
	loot = list()
	stat_attack = UNCONSCIOUS
	movement_type = FLYING
	robust_searching = 1
	light_range = 5
	light_power = 3
	light_color = LIGHT_COLOR_PURPLE
	do_footstep = TRUE

/mob/living/simple_animal/hostile/asteroid/plasma_wisp/revive(full_heal = 0, admin_revive = 0)
	if(..())
		anchored = TRUE
		. = 1

/mob/living/simple_animal/hostile/asteroid/plasma_wisp/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	light_range = 2
	light_power = 1
	..(gibbed)
