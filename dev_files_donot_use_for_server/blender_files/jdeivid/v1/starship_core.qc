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
$bodygroup "primary_weapons"
{
	blank
	studio "primary_weapons.smd"
}
$bodygroup "under_weapons"
{
	blank
	studio "under_weapons.smd"
}
$bodygroup "shield_bubble"
{
	blank
	studio "shield_bubble.smd"
}

$texturegroup "skinfamilies"
{
	{ "c_invasion_bat_laser" 		"c_frying_pan_gold"		"painted_wood_01"	"rally_call_2017_purple"	}	//almagest
	{ "c_invasion_bat_laser_blue" 	"c_frying_pan_gold"		"painted_wood_01"	"gold_player"				}	//ruina.
	{ "australium_container_glass"	"invulnfx_red" 			"invulnfx_red" 		"invulnfx_red"				}
	{ "australium_container_glass"	"invulnfx_blue" 		"invulnfx_blue"		"invulnfx_blue"				}
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
$cdmaterials "models\effects\"

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

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0

//WEAPON POINTS:
//Forward Lances (part of forwrad weapons)
$attachment "forward_lance_left_end" 			"weapon_bone" -143.702 432.962 0.0 rotate 0.0 0.0 0.0
$attachment "forward_lance_left_start" 			"weapon_bone" -143.702 314.649 0.0 rotate 0.0 0.0 0.0

$attachment "forward_lance_right_end" 			"weapon_bone" 143.702 432.962 0.0 rotate 0.0 0.0 0.0
$attachment "forward_lance_right_start" 		"weapon_bone" 143.702 314.649 0.0 rotate 0.0 0.0 0.0

//Central Weapons ports (part of core decorations)
$attachment "central_weapons_port_left_top" 	"weapon_bone" -132.512 213.092 61.3638 rotate 0.0 0.0 0.0
$attachment "central_weapons_port_left_bottom" 	"weapon_bone" -132.512 213.092 -61.3638 rotate 0.0 0.0 0.0

$attachment "central_weapons_port_right_top" 	"weapon_bone" 132.512 213.092 61.3638 rotate 0.0 0.0 0.0
$attachment "central_weapons_port_right_bottom" "weapon_bone" 132.512 213.092 -61.3638 rotate 0.0 0.0 0.0

//Underside weapons (part of under_weapons)
$attachment "underside_weapons_left_outer" 		"weapon_bone" -133.459 -1.1523 -79.5816 rotate 0.0 0.0 0.0
$attachment "underside_weapons_left_inner" 		"weapon_bone" -92.7812 -1.1523 -79.5816 rotate 0.0 0.0 0.0

$attachment "underside_weapons_right_outer" 	"weapon_bone" 133.459 -1.1523 -79.5816 rotate 0.0 0.0 0.0
$attachment "underside_weapons_right_inner" 	"weapon_bone" 92.7812 -1.1523 -79.5816 rotate 0.0 0.0 0.0



$sequence "idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}