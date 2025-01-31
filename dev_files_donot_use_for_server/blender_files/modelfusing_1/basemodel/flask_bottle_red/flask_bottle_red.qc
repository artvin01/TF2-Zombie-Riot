// Created by Crowbar 0.71

$modelname "passtime/flasks/flask_bottle_red.mdl"

$staticprop

$bodygroup "body"
{
	studio "flask_bottle_red.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition 0 0 -6.959

$cdmaterials "models\passtime\flasks"
$cdmaterials "models\props_halloween"
$cdmaterials "passtime\flasks\flask_liquid_red\"
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -3.069 -3.069 -18.062 3.069 3.069 4.145

$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "ref" {
	"flask_bottle_red_anims\ref.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}
