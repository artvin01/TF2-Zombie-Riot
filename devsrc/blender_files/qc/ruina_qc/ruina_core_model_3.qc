// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/ruina_models_3_3_test1.mdl"	//current one on the server:

$bodygroup "tower_1"		//Converted
{
	blank
	studio "v3/tower_1.smd"
}
$bodygroup "tower_2"		//Converted
{
	blank
	studio "v3/tower_2.smd"
}
$bodygroup "tower_3"		//Converted
{
	blank
	studio "v3/tower_3.smd"
}
$bodygroup "tower_4"		//Converted
{
	blank
	studio "v3/tower_4.smd"
}
$bodygroup "twirl_melee_1"	
{
	blank
	studio "v3/twirl_melee_1.smd"
}
$bodygroup "twirl_crest_1"	
{
	blank
	studio "v3/twirl_crest_1.smd"
}
$bodygroup "twirl_melee_2"	
{
	blank
	studio "v3/twirl_melee_2.smd"
}
$bodygroup "twirl_crest_2"	
{
	blank
	studio "v3/twirl_crest_2.smd"
}
$bodygroup "twirl_crest_3"	
{
	blank
	studio "v3/twirl_crest_3.smd"
}
$bodygroup "twirl_melee_3"	
{
	blank
	studio "v3/twirl_melee_3.smd"
}
$bodygroup "twirl_melee_4"	
{
	blank
	studio "v3/twirl_melee_4.smd"
}
$bodygroup "twirl_crest_4"	
{
	blank
	studio "v3/twirl_crest_4.smd"
}
$bodygroup "ruina_bow_3"	
{
	blank
	studio "v3/ruina_bow_3.smd"
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

$cdmaterials "models\player\items\heavy\"			
//xms_colored_lights_white		//a gray like metalic finish

$cdmaterials "models\props_moonbase\"
//asteroid01			//can certainly work as a replacement for glow inner for large things.
//moon_gravel_crystal

$cdmaterials "models\props_mvm\"
//painted_wood_01

$cdmaterials "models\props_halloween\"
//unlit_black		//is black

$cdmaterials ""
//../../../qc/ruina_qc/v3/
//D:\J's Stuff\Github Desktop\TF2-Zombie-Riot\devsrc\blender_files\jdeivid\ruina
$cdmaterials "models/player/shared/"								//gold_player
$cdmaterials "models/workshop/weapons/c_models/c_invasion_wrangler"	//c_invasion_wrangler_laser.vm

//

$texturegroup "skinfamilies"
{
	{ "c_invasion_wrangler_laser"			"neon_red_solid"			}		//red
	{ "c_invasion_wrangler_laser_blue"		"neon_blue_solid"			}		//blue
	//{	"australium_container_glass"		"neon_red_solid"		}		//uber red
	//{	"australium_container_glass"		"neon_blue_solid"		}		//uber blue
}

$cbox 0 0 0 0 0 0

$bbox -1.784 -1.784 -2.533 1.77 1.773 29.017

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}