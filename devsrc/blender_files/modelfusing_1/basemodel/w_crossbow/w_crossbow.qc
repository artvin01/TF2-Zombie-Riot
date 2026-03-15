// Created by Crowbar 0.71

$modelname "weapons/W_crossbow.mdl"

$bodygroup "studio"
{
	studio "w_crossbow_reference.smd"
}

$lod 20
{
	replacemodel "w_crossbow_reference.smd" "w_crossbow_reference_lod1.smd"
	nofacial
}
$lod 30
{
	replacemodel "w_crossbow_reference.smd" "w_crossbow_reference_lod2.smd"
	nofacial
}
$lod 40
{
	replacemodel "w_crossbow_reference.smd" "w_crossbow_reference_lod3.smd"
	nofacial
}
$shadowlod
{
	replacemodel "w_crossbow_reference.smd" "w_crossbow_reference_lod4.smd"
	nofacial
}

$surfaceprop "weapon"

$contents "solid"

$illumposition 0.094 2.38 1.478

$cdmaterials "models\weapons\v_crossbow\"

$cbox 0 0 0 0 0 0

$bbox -21.699 -15.859 -3.776 17.032 15.859 7.257

$definebone "w_crossbow_mesh" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0


$sequence "idle" {
	"w_crossbow_anims\idle.smd"
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "attack1" {
	"w_crossbow_anims\attack1.smd"
	activity "ACT_RANGE_ATTACK_PISTOL" 1
	{ event 5003 0 "2" }
	{ event 6001 0 "0" }
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "w_crossbow_physics.smd"
{
	$mass 2
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
