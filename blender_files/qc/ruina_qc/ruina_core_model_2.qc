// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/ruina_models_2_1.mdl"	//current one on the server: null

$bodygroup "ruina_bow_2"	//done
{
	blank
	studio "v2/ruina_bow_2.smd"
}
$bodygroup "hand_crest_v2"	//done
{
	blank
	studio "v2/hand_crest_v2.smd"
}
$bodygroup "lan_sword_v2"	//done
{
	blank
	studio "v2/lan_sword_v2.smd"
}
$bodygroup "eur_staff_v2"	//done
{
	blank
	studio "v2/eur_staff_v2.smd"
}
$bodygroup "ruina_blade_v2"	//done
{
	blank
	studio "v2/ruina_blade_v2.smd"
}
$bodygroup "laser_cannon_v1"	//done
{
	blank
	studio "v2/laser_cannon_v1.smd"
}
$bodygroup "dagger_v2"	//done
{
	blank
	studio "v2/dagger_v2.smd"
}
$bodygroup "healing_staff_2"	//done
{
	blank
	studio "v2/healing_staff_2.smd"
}
$bodygroup "rei_launcher"		//todo: resize it, its a bit tooo big.
{
	blank
	studio "v2/rei_launcher.smd"
}





$surfaceprop "metal"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$mostlyopaque

$cdmaterials "models\custom_weaponry\"
$cdmaterials "models\weapons\w_wrench\"				//it has gold!		w_wrench01_gold
$cdmaterials "models\weapons\c_items\"				//MORE GOLD 		c_saxxy.vmt		//EVEN MORE GOLD 	c_frying_pan_gold.vmt 
$cdmaterials "models\workshop_partner\weapons\c_models\c_ai_flamethrower\"
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -1.784 -1.784 -2.533 1.77 1.773 29.017

//Good to know I can use these to create special points for vector getting to connect beams or TE or for effects

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0
#definebone "root"	"" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}