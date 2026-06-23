// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/ruina_models_1_3_test1.mdl"	//current one on the server: "_1_2_2"

$bodygroup "ruina_projectile"	///Converted
{
	blank
	studio "v1/ruina_projectile.smd"
}
$bodygroup "halo_1"				//Converted
{
	blank
	studio "v1/halo_1"
}
$bodygroup "quincy_bow"			//Converted
{
	blank
	studio "v1/quincy_bow.smd"
}
$bodygroup "ruina_blade"		//Converted
{
	blank
	studio "v1/ruina_blade.smd"	
}
$bodygroup "ruina_magi_gun"		//Converted
{
	blank
	studio "v1/ruina_magi_gun.smd"
}
$bodygroup "ruina_staff_1"		//Converted
{							
	blank
	studio "v1/ruina_staff_1.smd"
}
$bodygroup "hand_crest_v1"		//Converted
{							
	blank
	studio "v1/hand_crest_v1.smd"
}
$bodygroup "lan_sword_v1"		//Converted
{							
	blank
	studio "v1/lan_sword_v1.smd"
}
$bodygroup "eur_staff_v1"		//Converted
{							
	blank
	studio "v1/eur_staff_v1.smd"
}
$bodygroup "dagger_v1"			//Converted
{							
	blank
	studio "v1/dagger_v1.smd"
}
$bodygroup "radar_gun_v1"		//Converted
{							
	blank
	studio "v1/radar_gun_v1.smd"
}
$bodygroup "healing_staff_1"	//Converted
{							
	blank
	studio "v1/healing_staff_1.smd"
}
$bodygroup "w30_boss_crest"		//Converted
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
$cdmaterials "models\weapons\c_items\"					
//c_saxxy					//gold
//c_frying_pan_gold 		//gold

$cdmaterials "passtime\neons\"	
//neon_red_solid

$cdmaterials "models\props_mvm\"
//painted_wood_01

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