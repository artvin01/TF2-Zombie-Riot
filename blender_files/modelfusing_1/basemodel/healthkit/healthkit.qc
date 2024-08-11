// Created by Crowbar 0.71

$modelname "Items\healthKit.mdl"

$staticprop

$bodygroup "Body"
{
	studio "healthKit_reference.smd"
}

$lod 10
{
	replacemodel "healthKit_reference.smd" "healthKit_reference_lod1.smd"
	nofacial
}
$lod 15
{
	replacemodel "healthKit_reference.smd" "healthKit_reference_lod2.smd"
	nofacial
}
$lod 25
{
	replacemodel "healthKit_reference.smd" "healthKit_reference_lod3.smd"
	nofacial
}
$lod 35
{
	replacemodel "healthKit_reference.smd" "healthKit_reference_lod4.smd"
	nofacial
}

$surfaceprop "item"

$contents "solid"

$illumposition 0.234 -5.298 3.063

$cdmaterials "models\items\"

$cbox 0 0 0 0 0 0

$bbox -3.61 -7.314 -0.281 14.201 7.374 6.132

$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"healthkit_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "healthkit_physics.smd"
{
	$mass 10
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
		"base"		"Item.Small"
	}
}
