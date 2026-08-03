// Created by Crowbar 0.71

$modelname "workshop/player/items/engineer/taunt_texan_trickshot/taunt_texan_trickshot.mdl"

$bodygroup "default"
{
	studio "taunt_texan_trickshot.smd"
}

$lod 11
{
	replacemodel "taunt_texan_trickshot.smd" "taunt_texan_trickshot_lod1.smd"
	nofacial
}
$lod 22
{
	replacemodel "taunt_texan_trickshot.smd" "taunt_texan_trickshot_lod2.smd"
	nofacial
}

$surfaceprop "default"

$contents "solid"

$illumposition -0.071 -4.085 0.549

$cdmaterials "models\workshop\player\items\engineer\taunt_texan_trickshot\"
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -7.785 -1.455 -4.493 15.954 1.312 5.592

$definebone "weapon_bone" "" 0 0 0 0 0 0.000004 0 0 0 0 0 0


$sequence "ref" {
	"taunt_texan_trickshot_anims\ref.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}
