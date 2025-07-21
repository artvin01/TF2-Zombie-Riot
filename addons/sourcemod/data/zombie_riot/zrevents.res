"ZR_Events"
{
	//taken from Risk fortress 2
	"player_hurt"
	{
		"userid" "short"
		"health" "short"
		"attacker" "short"
		"damageamount" "long" // short -> long fixes damage overflow
		"custom" "short"
		"showdisguisedcrit" "bool"	// if our attribute specifically crits disguised enemies we need to show it on the client
		"crit" "bool"
		"minicrit" "bool"
		"allseecrit" "bool"
		"weaponid" "short"
		"bonuseffect" "byte"
	}   
	 
	"npc_hurt"
	{
		"entindex" "short"
		"health" "short"
		"attacker_player" "short"
		"weaponid" "short"
		"damageamount" "long" // short -> long fixes damage overflow
		"crit" "bool"
		"boss"	"short"		// 1=HHH 2=Monoculus 3=Merasmus
	}

	"player_bonuspoints"
	{
		"points" "long" // short -> long fixes damage overflow
		"player_entindex" "short"
		"source_entindex" "short"
	}
}