// Created by Crowbar 0.71

$modelname "workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl"

$bodygroup "body"
{
	studio "c_invasion_bat.smd"
}

$lod 11
{
	replacemodel "c_invasion_bat.smd" "c_invasion_bat_lod1.smd"
	nofacial
}
$lod 18
{
	replacemodel "c_invasion_bat.smd" "c_invasion_bat_lod2.smd"
	replacemodel "c_invasion_bat.smd" "c_invasion_bat_lod3.smd"
	nofacial
}

$surfaceprop "metal"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$cdmaterials "models\workshop\weapons\c_models\c_invasion_bat\"
$cdmaterials ""

$texturegroup "skinfamilies"
{
	{ "c_invasion_bat"      "c_invasion_bat_laser"      }
	{ "c_invasion_bat_blue" "c_invasion_bat_laser_blue" }
}

$attachment "pedestal_0" "weapon_bone" 0 13.74 0 rotate -90 -90 0

$cbox 0 0 0 0 0 0

$bbox -1.784 -1.784 -2.533 1.77 1.773 29.017

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"c_invasion_bat_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "c_invasion_bat_physics.smd"
{
	$mass 1.063022
	$inertia 1
	$damping 0
	$rotdamping 4
	$rootbone " "

}
