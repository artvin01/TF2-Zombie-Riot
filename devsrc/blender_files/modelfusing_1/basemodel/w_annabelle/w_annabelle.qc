// Created by Crowbar 0.71

$modelname "weapons/w_annabelle.mdl"

$bodygroup "studio"
{
	studio "w_annabelle_reference.smd"
}

$lod 30
{
	replacemodel "w_annabelle_reference.smd" "w_annabelle_reference_lod1.smd"
	nofacial
}

$surfaceprop "weapon"

$contents "solid"

$illumposition -7.743 -3.994 -1.786

$cdmaterials "models\weapons\w_annabelle\"

$attachment "0" "ValveBiped.Anim_Attachment_RH" -0.4 6.57 28.97 rotate -86.02 84.39 -86.34
$attachment "1" "ValveBiped.Anim_Attachment_RH" -1.11 4.37 6.93 rotate -1.04 177.83 -167.04

$cbox 0 0 0 0 0 0

$bbox -19.219 -16.719 -13.943 27.19 1.233 10.371

$definebone "ValveBiped" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Hand" "ValveBiped" 0.312503 0.282628 16.71932 77.428254 -82.471727 5.239814 0 0 0 0 0 0
$definebone "ValveBiped.Anim_Attachment_RH" "ValveBiped.Bip01_R_Hand" 2.676088 -1.71244 0 0 -89.999982 -89.999982 0 0 0 0 0 0


$sequence "idle1" {
	"w_annabelle_anims\idle1.smd"
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "fire" {
	"w_annabelle_anims\fire.smd"
	activity "ACT_RANGE_ATTACK_SHOTGUN" 1
	{ event AE_NPC_MUZZLEFLASH 0 "SHOTGUN 0" }
	{ event 6001 0 "2" }
	{ event 3004 0 "" }
	fadein 0.2
	fadeout 0.2
	fps 5
}

$sequence "draw" {
	"w_annabelle_anims\draw.smd"
	activity "ACT_VM_DRAW" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "holster" {
	"w_annabelle_anims\holster.smd"
	activity "ACT_VM_HOLSTER" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "w_annabelle_physics.smd"
{
	$mass 10
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
