// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/custom_wings_1_4_test1.mdl"

$bodygroup "fusion_wings"			//1
{
	blank
	studio "fusion_wings.smd"
}
$bodygroup "lancelot_wings"			//2
{
	blank
	studio "lancelot_wings.smd"
}
$bodygroup "ruliana_wings"			//4
{
	blank
	studio "ruliana_wings.smd"
}
$bodygroup "twirl_wings"			//8
{
	blank
	studio "twirl_wings.smd"
}
$bodygroup "helia_wings"			//16
{
	blank
	studio "helia_wings.smd"
}
$bodygroup "stella_wings"			//32
{
	blank
	studio "stella_wings.smd"
}
$bodygroup "wings_karlas"			//64
{
	blank
	studio "wings_karlas.smd"
}




$surfaceprop "metal"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$mostlyopaque

$cdmaterials "models\custom_weaponry\"
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

//../qc/
//D:\J's Stuff\Github Desktop\TF2-Zombie-Riot\devsrc\blender_files\jdeivid\ruina

$cbox 0 0 0 0 0 0

$bbox -1.784 -1.784 -2.533 1.77 1.773 29.017


$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}