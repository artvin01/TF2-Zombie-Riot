// Created by Crowbar 0.71

$modelname "zombie_riot/starship_1.mdl"

$bodygroup "starship"
{
	blank
	studio "starship.smd"
}
$bodygroup "bridge"
{
	blank
	studio "bridge.smd"
}
$bodygroup "main_drive"
{
	blank
	studio "main_drive.smd"
}
$bodygroup "top_decorations"
{
	blank
	studio "top_decorations.smd"
}
$bodygroup "bottom_decorations"
{
	blank
	studio "bottom_decorations.smd"
}
$bodygroup "core_decorations"
{
	blank
	studio "core_decorations.smd"
}


$surfaceprop "metal"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$mostlyopaque

$cdmaterials "models\custom_weaponry\"
$cdmaterials "models\weapons\c_items\"	
$cdmaterials "models\items\"
$cdmaterials "models/player/shared/"	//gold_player
$cdmaterials "models\props_mvm\"		//painted_wood_01
$cdmaterials "models\player\medic\"
$cdmaterials "models\player\items\all_class\"
$cdmaterials "passtime\neons\"	

$cdmaterials "models\workshop\weapons\c_models\c_invasion_bat\"
//c_invasion_bat_laser_white.vmt	//glass like texture
//c_invasion_bat_laser				//red glass.
//c_invasion_bat_laser_blue			//cyan glass
//c_invasion_bat
$cdmaterials "models\props_doomsday\"				
//australium_container_glass	//its like golden glass
$cdmaterials "models\player\items\heavy\"			
//xms_colored_lights_white		//a gray like metalic finish

$cdmaterials "models\props_citizen_tech\"
//steam_engine001

$cdmaterials "models\workshop\player\items\all_class\rally_call_2017\"
//rally_call_2017_purple



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