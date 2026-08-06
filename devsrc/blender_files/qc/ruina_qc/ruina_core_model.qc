// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/ruina_models_1_3_test2.mdl"	//current one on the server: "_1_2_2"

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


$cdmaterials "models\props_skybox\"					
//black							//legit just black

$cdmaterials "models\props_doomsday\"				
//australium_container_glass	//its like golden glass

$cdmaterials "models\items\"						
//crystal_ball_glass			//Emerald pulsating glass.

$cdmaterials "passtime\neons\"						
//neon_yellow_solid, neon_blue_solid

$cdmaterials "models/props_moonbase/"
//asteroid01			//can certainly work as a replacement for glow inner for large things.
//moon_gravel_crystal

$cdmaterials "models/props_halloween/"
//unlit_black		//is black

$cdmaterials "models/props_mvm/"
//painted_wood_01

$cdmaterials "models/weapons/c_items/"
//festive_lights_red

$cdmaterials ""
$cdmaterials "models/player/shared/"								//gold_player
$cdmaterials "models/workshop/weapons/c_models/c_invasion_wrangler"	//c_invasion_wrangler_laser.vm

$texturegroup "skinfamilies"
{
	{ 	"c_invasion_wrangler_laser"			"neon_red_solid"			"festive_lights_red"		}		//red
	{ 	"c_invasion_wrangler_laser_blue"		"neon_blue_solid"		"festive_lights_blue"		}		//blue
	{	"crystal_ball_glass"				"neon_green_solid"			"festive_lights_white"		}		//uber red
	{	"australium_container_glass"		"neon_yellow_solid"			"festive_lights_white"		}		//uber blue
}

$cdmaterials "passtime\neons\"	
//neon_red_solid

$cdmaterials "models\props_mvm\"
//painted_wood_01

$cdmaterials ""


$cbox 0 0 0 0 0 0

$bbox -1.784 -1.784 -2.533 1.77 1.773 29.017

//Good to know I can use these to create special points for vector getting to connect beams or TE or for effects

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}