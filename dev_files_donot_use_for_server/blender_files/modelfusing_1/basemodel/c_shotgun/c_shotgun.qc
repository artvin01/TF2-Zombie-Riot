// Created by Crowbar 0.71

$modelname "weapons/c_models/c_shotgun/c_shotgun.mdl"

$bodygroup "body"
{
	studio "c_shotgun_reference.smd"
}

$lod 10
{
	replacemodel "c_shotgun_reference.smd" "c_shotgun_reference_lod1.smd"
	replacebone "c_weapon_stattrack" "weapon_bone"
	nofacial
}
$lod 22
{
	replacemodel "c_shotgun_reference.smd" "c_shotgun_reference_lod2.smd"
	replacebone "c_weapon_stattrack" "weapon_bone"
	nofacial
}

$surfaceprop "metal"

$contents "solid"

$illumposition 0 -15.297 0.564

$cdmaterials "models\weapons\c_models\c_shotgun"
$cdmaterials ""

$attachment "muzzle" "weapon_bone" 0 3.73 34.92 rotate -90 0 0
$attachment "pedestal_0" "weapon_bone" 0 3.08 13.42 rotate -90 -90 0
$attachment "eject_brass" "weapon_bone" -0.8 3.25 10.76 rotate -11.66 162.02 -167.64
$attachment "unusual_0" "weapon_bone" 0 3.74 34.96 rotate -90 0 0
$attachment "unusual_1" "weapon_bone" 0 3.74 27.44 rotate -90 0 0
$attachment "unusual_2" "weapon_bone" 0 3.74 19.91 rotate -90 0 0
$attachment "unusual_3" "weapon_bone" 0 3.74 12.38 rotate -90 0 0
$attachment "unusual_4" "weapon_bone" 0 2.41 3.45 rotate -68.96 90 -90
$attachment "unusual_5" "weapon_bone" 0 -3.19 -3.36 rotate -31.89 90 -90
$attachment "icon_camera" "weapon_bone" 35.08 -8.06 25.24 rotate 12.48 164.98 69.37

$cbox 0 0 0 0 0 0

$bbox -4.538 -2.253 -4.071 35.21 2.212 5.221

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0
$definebone "weapon_bone_1" "weapon_bone" 0 1.394091 25.96583 0 0 0 0 0 0 0 0 0
$definebone "vm_weapon_bone" "weapon_bone" 0.109113 2.60987 5.588908 0 0 0 0 0 0 0 0 0
$definebone "vm_weapon_bone_1" "weapon_bone" 1.207144 3.102086 8.741431 0 0 0 0 0 0 0 0 0
$definebone "c_weapon_stattrack" "weapon_bone" 1.494824 1.86367 7.836205 -0.012627 -1.347838 -87.262551 0 0 0 0 0 0

$bonemerge "weapon_bone"
$bonemerge "c_weapon_stattrack"


$sequence "idle" {
	"c_shotgun_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "c_shotgun_physics.smd"
{
	$mass 2.625185
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
