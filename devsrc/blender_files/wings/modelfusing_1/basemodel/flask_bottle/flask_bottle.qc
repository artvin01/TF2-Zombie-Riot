// Created by Crowbar 0.71

$modelname "props_halloween/flask_bottle.mdl"

$staticprop

$bodygroup "body"
{
	studio "flask_bottle.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition 0 0 -6.959

$cdmaterials "models\props_halloween"
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -3.069 -3.069 -18.062 3.069 3.069 4.145

$definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "ref" {
	"flask_bottle_anims\ref.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}
