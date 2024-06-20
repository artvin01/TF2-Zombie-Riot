// Created by Crowbar 0.71

$modelname "zombie_riot/ruina/ruina_models_1.mdl"

$bodygroup "ruina_icbm"	//done
{
	blank
	studio "ruina_projectile.smd"
}
$bodygroup "halo_1"	//Create a spinning animation for the rings.
{
	blank
	studio "halo_1"
}
$bodygroup "quincy_bow"		//done
{
	blank
	studio "ruina_bow.smd"
}
$bodygroup "ruina_blade"	//done
{
	blank
	studio "ruina_blade.smd"
}
$bodygroup "ruina_magi_gun"	//done
{
	blank
	studio "ruina_magi_gun.smd"
}
$bodygroup "ruina_staff_1"	//todo: more detailing, and paint. has holes.
{							//ALSO: REDUCE THE DETALING, HOLY SHIT THIS THING IS 40K LINES OF MODEL, AND 2500KB, HOLY SHIT
	blank
	studio "ruina_staff_1.smd"
}





$surfaceprop "metal"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$mostlyopaque

$cdmaterials "models\custom_weaponry\"
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

$sequence "icbm_idle" {
	"custom_weaponry_1_anims\icbm_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "quincy_idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}
$sequence "blade_idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}