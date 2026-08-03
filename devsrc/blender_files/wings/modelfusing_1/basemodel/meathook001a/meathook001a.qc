// Created by Crowbar 0.71

$modelname "props_junk\meathook001a.mdl"

$staticprop

$bodygroup "Body"
{
	studio "meathook001a_reference.smd"
}

$lod 20
{
	replacemodel "meathook001a_reference.smd" "meathook001a_reference_lod1.smd"
	nofacial
}
$lod 35
{
	replacemodel "meathook001a_reference.smd" "meathook001a_reference_lod2.smd"
	nofacial
}

$surfaceprop "metal"

$contents "solid"

$illumposition 0 0 0

$cdmaterials "models\props_junk\"

$cbox 0 0 0 0 0 0

$bbox -2.15 -8.534 -22.313 2.158 8.326 22.106

$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"meathook001a_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "meathook001a_physics.smd"
{
	$mass 30
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 4

}

$keyvalues
{
	prop_data 
	{
		"base"		"Metal.Small"
	}
}
