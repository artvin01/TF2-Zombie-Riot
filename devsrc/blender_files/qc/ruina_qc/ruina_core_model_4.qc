// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/ruina_models_4_4_test_1.mdl"	//current one on the server: 1

$bodygroup "stella_crest_1"	
{
	blank
	studio "v4/stella_crest_1.smd"
}
$bodygroup "stella_crest_charging"	//this goes ontop of the pre existing crest.
{
	blank
	studio "v4/stella_crest_charging.smd"
}
$bodygroup "karlas_projectile"	
{
	blank
	studio "v4/karlas_projectile.smd"
}
$bodygroup "fantasy_blade"	
{
	blank
	studio "v4/fantasy_blade.smd"
}
$bodygroup "fractal_lenz"	
{
	blank
	studio "v4/fractal_lenz.smd"
}
$bodygroup "fractal_harvester"	
{
	blank
	studio "v4/fractal_harvester.smd"
}
$bodygroup "base_ring"	
{
	blank
	studio "v4/base_ring.smd"
}
//../../../qc/ruina_qc/bow_hell/
//for some unholy reason, the bow viewmodel inverts normals. like huh????
//btw, the fix I chose was to quite literally duplicate the whole model in blender, and flip normals.
//SO TECHNICALLY THERE ARE 2 BOWS IN 1 BOW. YEAH. which is why these aren't used by npc's and only players.
$bodygroup "ruina_bow_3_player"	
{
	blank
	studio "bow_hell/ruina_bow_3_player.smd"
}
$bodygroup "ruina_bow_2_player"	
{
	blank
	studio "bow_hell/ruina_bow_2_player.smd"
}
$bodygroup "quincy_bow_player"	
{
	blank
	studio "bow_hell/quincy_bow_player.smd"
}
$bodygroup "repeater_bow_1"	//90%
{
	blank
	studio "bow_hell/repeater_bow_1.smd"
}


$bodygroup "quincy_arrow"	
{
	blank
	studio "v4/quincy_arrow.smd"
}
$bodygroup "quincy_balista_handle"	
{
	blank
	studio "v4/quincy_balista_handle.smd"
}
$bodygroup "quincy_balista_head_1"	
{
	blank
	studio "v4/quincy_balista_head_1.smd"
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

//../../../qc/ruina_qc/v4/
//D:\J's Stuff\Github Desktop\TF2-Zombie-Riot\devsrc\blender_files\jdeivid\ruina

$cbox 0 0 0 0 0 0

$bbox -1.784 -1.784 -2.533 1.77 1.773 29.017

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0
#definebone "root"	"" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}