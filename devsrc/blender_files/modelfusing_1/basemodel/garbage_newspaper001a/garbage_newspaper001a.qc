// Created by Crowbar 0.71

$modelname "props_junk/garbage_newspaper001a.mdl"

$staticprop

$bodygroup "Body"
{
	studio "garbage_newspaper001a_reference.smd"
}


$surfaceprop "paper"

$contents "solid"

$illumposition 0 0.034 0.092

$cdmaterials "models\props_junk\"

$cbox 0 0 0 0 0 0

$bbox -12.326 -11.989 -2.131 12.164 12.032 2.045

$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"garbage_newspaper001a_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "garbage_newspaper001a_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 1

}

$keyvalues
{
	prop_data 
	{
		"base"		"cardboard.Small"
	}
}
