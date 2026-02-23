// Created by Crowbar 0.71

$modelname "weapons/c_models/urinejar.mdl"

$bodygroup "body"
{
	studio "c_urinejar_reference.smd"
}

$lod 7
{
	replacemodel "c_urinejar_reference.smd" "c_urinejar_reference_lod1.smd"
	nofacial
}
$lod 14
{
	replacemodel "c_urinejar_reference.smd" "c_urinejar_reference_lod2.smd"
	nofacial
}

$surfaceprop "default"

$contents "solid"

$illumposition 0 0.028 1.604

$mostlyopaque

$cdmaterials "models\weapons\c_items"
$cdmaterials ""

$attachment "icon_camera" "weapon_bone" 10.64 -9.14 -12.39 rotate -48.84 123.41 50.9
$attachment "pedestal_0" "weapon_bone" 3.95 0.06 0 rotate 0 -89.1 -90

$cbox 0 0 0 0 0 0

$bbox -2.972 -2.972 -3.364 2.972 2.972 6.678

$definebone "weapon_bone" "" 0 -2.917602 0 -0.903091 90.000003 -90.000003 0 0 0 0 0 0
$definebone "weapon_bone_1" "weapon_bone" 4.967917 0.077819 0 -0.000003 0 -0.000002 0 0 0 0 0 0
$definebone "weapon_bone_2" "weapon_bone" 4.967917 0.10649 2.484285 -0.000003 0 -0.000002 0 0 0 0 0 0
$definebone "weapon_bone_3" "weapon_bone" 4.967917 0.10649 -2.473891 -0.000003 0 -0.000002 0 0 0 0 0 0


$sequence "idle" {
	"urinejar_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "urinejar_physics.smd"
{
	$mass 6.067674
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
