// Created by Crowbar 0.71

$modelname "zombie_riot/ruina/ruina_models_1.mdl"

$bodygroup "ruina_icbm"
{
	blank
	studio "ruina_projectile.smd"
}
$bodygroup "halo_1.smd"	//Create a spinning animation for the rings.
{
	blank
	studio "ruina_projectile.smd"
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