/turf/open/openspace/ocean
	name = "ocean"
	planetary_atmos = TRUE
	baseturfs = /turf/open/openspace/ocean
	var/replacement_turf = /turf/open/floor/plating/ocean

/turf/open/openspace/ocean/Initialize(mapload)
	. = ..()

	for(var/obj/structure/flora/plant in contents)
		qdel(plant)
	var/turf/T = GET_TURF_BELOW(src)
	if(T)
		if(T.turf_flags & NO_RUINS)
			ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)
			return
		if(!ismineralturf(T))
			return
		var/turf/closed/mineral/M = T
		M.mineralAmt = 0
		M.gets_drilled()
		baseturfs = /turf/open/openspace/ocean //This is to ensure that IF random turf generation produces a openturf, there won't be other turfs assigned other than openspace.

/turf/open/openspace/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)

/turf/open/floor/plating/ocean
	gender = PLURAL
	name = "ocean sand"
	baseturfs = /turf/open/floor/plating/ocean
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	planetary_atmos = TRUE
	var/rand_variants = 12
	var/rand_chance = 30
	var/liquid_type = /obj/effect/abstract/liquid_turf/immutable/ocean

/turf/open/floor/plating/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(liquid_type)
	new_immmutable.add_turf(src)

	if(rand_variants && prob(rand_chance))
		var/random = rand(1,rand_variants)
		icon_state = "[base_icon_state][random]"
		base_icon_state = "[base_icon_state][random]"

/turf/open/floor/plating/ocean_plating
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/ocean_plating

/turf/open/floor/plating/ocean_plating/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)
