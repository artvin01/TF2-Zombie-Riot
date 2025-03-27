// Created by Crowbar 0.71

$modelname "weapons/w_grenade.mdl"

$staticprop

$bodygroup "studio"
{
	studio "Grenade_reference.smd"
}


$surfaceprop "grenade"

$contents "solid"

$illumposition -0.032 -0.002 0.085

$cdmaterials "models\weapons\w_grenade\"

$attachment "fuse" "static_prop" 0 0 4.5 rotate 0 90 0

$cbox 0 0 0 0 0 0

$bbox -2.089 -2.089 -4.684 2.089 2.089 4.839

$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"w_grenade_anims\idle.smd"
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "w_grenade_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
