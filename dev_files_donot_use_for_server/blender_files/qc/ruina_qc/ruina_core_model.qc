// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/ruina_models_1_2_2.mdl"	//current one on the server: "_1_2_2"

$bodygroup "ruina_icbm"	//done
{
	blank
	studio "v1/ruina_projectile.smd"
}
$bodygroup "halo_1"	//Create a spinning animation for the rings.
{
	blank
	studio "v1/halo_1"
}
$bodygroup "quincy_bow"		//done
{
	blank
	studio "v1/ruina_bow.smd"
}
$bodygroup "ruina_blade"	//done
{
	blank
	studio "v1/ruina_blade.smd"
}
$bodygroup "ruina_magi_gun"	//done
{
	blank
	studio "v1/ruina_magi_gun.smd"
}
$bodygroup "ruina_staff_1"	//done
{							
	blank
	studio "v1/ruina_staff_1.smd"
}
$bodygroup "hand_crest_v1"	
{							
	blank
	studio "v1/hand_crest_v1.smd"
}
$bodygroup "lan_sword_v1"	
{							
	blank
	studio "v1/lan_sword_v1.smd"
}
$bodygroup "eur_staff_v1"	
{							
	blank
	studio "v1/eur_staff_v1.smd"
}
$bodygroup "dagger_v1"	
{							
	blank
	studio "v1/dagger_v1.smd"
}
$bodygroup "radar_gun_v1"	
{							
	blank
	studio "v1/radar_gun_v1.smd"
}
$bodygroup "healing_staff_1"	
{							
	blank
	studio "v1/healing_staff_1.smd"
}
$bodygroup "w30_boss_crest"	
{							
	blank
	studio "v1/w30_boss_crest.smd"
}
$bodygroup "iana_blade"	
{							
	blank
	studio "v1/iana_blade.smd"
}




$surfaceprop "metal"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$mostlyopaque

$cdmaterials "models\custom_weaponry\"
$cdmaterials "models\weapons\w_wrench\"				//it has gold!		w_wrench01_gold
$cdmaterials "models\weapons\c_items\"				//MORE GOLD 		c_saxxy.vmt		//EVEN MORE GOLD 	c_frying_pan_gold.vmt 
$cdmaterials "passtime\neons\"	
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