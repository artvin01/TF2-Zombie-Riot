// Created by Crowbar 0.71

$modelname "weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl"

$bodygroup "body"
{
	studio "c_crusaders_crossbow.smd"
}

$lod 11
{
	replacemodel "c_crusaders_crossbow.smd" "c_crusaders_crossbow_lod1.smd"
	nofacial
}
$lod 22
{
	replacemodel "c_crusaders_crossbow.smd" "c_crusaders_crossbow_lod2.smd"
	nofacial
}

$surfaceprop "metal"

$contents "solid"

$illumposition 0 -1.683 1.694

$cdmaterials "models\weapons\c_items\"
$cdmaterials ""

$texturegroup "skinfamilies"
{
	{ "c_crusaders_crossbow"     }
	{ "c_crusaders_crossbow_blu" }
}

$cbox 0 0 0 0 0 0

$bbox -15.708 -13.572 -6.452 19.101 13.572 9.651

$hboxset "default"
$hbox 0 "weapon_bone" -2.56 0.5 -5.5 2.69 12 22.5
$skipboneinbbox

$definebone "weapon_bone" "" 0 -2.349024 -6.595456 -0.506036 0 -0.000018 0 0 0 0 0 0
$definebone "vm_weapon_bone" "weapon_bone" 0.022017 3.426732 2.49284 0 0 0 0 0 0 0 0 0
$definebone "vm_weapon_bone_1" "weapon_bone" -0.012532 9.649513 -1.418932 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"c_crusaders_crossbow_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "c_crusaders_crossbow_physics.smd"
{
	$mass 6.486715
	$inertia 1
	$damping 0
	$rotdamping 4
	$rootbone " "

}
