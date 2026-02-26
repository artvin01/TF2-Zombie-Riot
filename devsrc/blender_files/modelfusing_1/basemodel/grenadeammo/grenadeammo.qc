// Created by Crowbar 0.71

$modelname "items/grenadeAmmo.mdl"

$staticprop

$bodygroup "studio"
{
	studio "GrenadeAmmo_reference.smd"
}


$surfaceprop "grenade"

$contents "solid"

$illumposition 0.251 -0.002 0.704

$cdmaterials "models\items\"

$cbox 0 0 0 0 0 0

$bbox -2.089 -2.089 -4.064 2.089 2.26 5.459

$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"grenadeammo_anims\idle.smd"
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "grenadeammo_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
