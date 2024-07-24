// Created by Crowbar 0.71
// Warp_Ruina_Model

$modelname "zombie_riot/weapons/ruina_models_3_1.mdl"	//current one on the server: null

$bodygroup "sword_v4"		
{
	blank
	studio "v3/sword_v4.smd"
}
$bodygroup "lan_sword_v3"		
{
	blank
	studio "v3/lan_sword_v3.smd"
}
$bodygroup "laser_cannon_v2"		//this was extremely painfull to make due to the normals being ass. likely due to my inexperience, but holy shit this was painfull
{
	blank
	studio "v3/laser_cannon_v2.smd"
}





$surfaceprop "metal"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$mostlyopaque

$cdmaterials "models\custom_weaponry\"
$cdmaterials "models\weapons\w_wrench\"				
//it has gold!		w_wrench01_gold

$cdmaterials "models\weapons\c_items\"					
//c_saxxy					//gold
//c_frying_pan_gold 		//gold
//festive_lights_white		//gray metal?

$cdmaterials "models\workshop_partner\weapons\c_models\c_ai_flamethrower\"
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