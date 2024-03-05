// Created by Crowbar 0.71

$modelname "zombie_riot/weapons/custom_weaponry_2.mdl"

$bodygroup "scythe"
{
	blank
	studio "scythe_model.smd"
}
$bodygroup "scythe_throw"
{
	blank
	studio "scythe_model_throw.smd"
}
$bodygroup "ruina_icbm"
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

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"custom_weaponry_1_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "scythe_spin" {
	"custom_weaponry_1_anims\scythe_spin.smd"
	fadein 0
	fadeout 0
	fps 24
	loop
}

$sequence "icbm_idle" {
	"custom_weaponry_1_anims\icbm_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}