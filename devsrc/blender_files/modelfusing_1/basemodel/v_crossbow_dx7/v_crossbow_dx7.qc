// Created by Crowbar 0.71

$modelname "Weapons/v_crossbow_dx7.mdl"

$bodygroup "studio"
{
	studio "Crossbow_reference_dx7.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition -5.746 -23.04 -13.339

$cdmaterials "models\weapons\v_crossbow\"
$cdmaterials "models\Weapons\V_hand\"

$texturegroup "skinfamilies"
{
	{ "crossbow dirtmap"      }
	{ "crossbow dirtmap_glow" }
}

$attachment "spark" "Crossbow_model.Spark2" 0.5 0 0 rotate -90 0 0
$attachment "bolt_start" "Crossbow_model.bolt" 0 0 16 rotate -90 0 0
$attachment "bolt_end" "Crossbow_model.bolt" 0 0 -4 rotate -90 0 0

$cbox 0 0 0 0 0 0

$bbox 1.4 -22.504 -24.607 44.68 11.011 -2.071

$definebone "Crossbow_model.Base" "" -7.172434 -3.895162 43.393295 0 0 89.999982 0 0 0 0 0 0
$definebone "Crossbow_model.HandControlRotGrandmaL" "Crossbow_model.Base" 10.362579 10.482833 10.452323 -30.153543 160.215706 55.490144 0 0 0 0 0 0
$definebone "Crossbow_model.HandControlRotParentL" "Crossbow_model.HandControlRotGrandmaL" 11.481672 0 -0.000032 -6.108473 2.532071 90.136743 0 0 0 0 0 0
$definebone "Crossbow_model.HandControlRotL" "Crossbow_model.HandControlRotParentL" -0.000002 0.000001 0.000001 28.125006 -3.375011 -131.625026 0 0 0 0 0 0
$definebone "Crossbow_model.HandControlRotL1" "Crossbow_model.HandControlRotL" 0 0 0 0.000005 -0.000003 -0.000002 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Clavicle" "Crossbow_model.Base" 8.259191 16.561514 0.226046 -0.317132 -16.285124 0.395169 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_UpperArm" "Crossbow_model.Bip01_L_Clavicle" 6.028142 0 0 -61.151039 -113.48248 0.745246 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Forearm" "Crossbow_model.Bip01_L_UpperArm" 11.692553 -0.000001 0 -0.000001 -54.244843 -0.000001 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Hand" "Crossbow_model.Bip01_L_Forearm" 11.481671 -0.000002 -0.000031 -2.47472 30.693634 -42.794339 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger4" "Crossbow_model.Bip01_L_Hand" 3.859704 -0.142403 -1.191974 -5.528185 -77.340247 -56.985583 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger41" "Crossbow_model.Bip01_L_Finger4" 1.312564 0 -0.000001 0.000002 -45.444086 0.000002 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger42" "Crossbow_model.Bip01_L_Finger41" 0.729363 0 0 0.000003 -43.24731 0.000002 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger3" "Crossbow_model.Bip01_L_Hand" 3.942325 0.046773 -0.431444 0.91736 -66.470609 -34.116484 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger31" "Crossbow_model.Bip01_L_Finger3" 1.539093 -0.000001 -0.000001 -0.000003 -40.072723 -0.000002 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger32" "Crossbow_model.Bip01_L_Finger31" 1.196322 -0.000001 0 -0.000003 -50.558136 0.000001 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger2" "Crossbow_model.Bip01_L_Hand" 3.883689 -0.04677 0.431443 2.687685 -51.635475 -17.214175 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger21" "Crossbow_model.Bip01_L_Finger2" 1.719574 0.000001 0 0.31604 -44.622647 0 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger22" "Crossbow_model.Bip01_L_Finger21" 1.209182 -0.000001 0 0.176697 -32.648854 0.000002 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger1" "Crossbow_model.Bip01_L_Hand" 3.859859 -0.137948 1.332466 -2.449396 -30.465202 20.30843 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger11" "Crossbow_model.Bip01_L_Finger1" 1.719429 0.000003 0.000001 0.23342 -20.798884 -0.000001 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger12" "Crossbow_model.Bip01_L_Finger11" 1.099666 0.000001 0 0.148737 -13.999133 -0.000001 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger0" "Crossbow_model.Bip01_L_Hand" 0.806048 -0.348921 1.321258 -38.210728 -51.058505 -66.288407 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger01" "Crossbow_model.Bip01_L_Finger0" 1.789787 0.000001 -0.000002 0.000001 15.343407 0.000002 0 0 0 0 0 0
$definebone "Crossbow_model.Bip01_L_Finger02" "Crossbow_model.Bip01_L_Finger01" 1.206996 0 0.000002 0.000001 10.665379 0.000001 0 0 0 0 0 0
$definebone "Crossbow_model.Crossbow_base" "Crossbow_model.Base" 0.203169 16.990919 17.134815 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.bowr1" "Crossbow_model.Crossbow_base" -6.401541 1.032725 18.933456 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.bowl1" "Crossbow_model.Crossbow_base" 6.119969 1.032725 18.906113 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.bowr2" "Crossbow_model.Crossbow_base" -15.076199 1.032727 11.477257 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.bowl2" "Crossbow_model.Crossbow_base" 14.494466 1.032727 11.517815 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.bowl_wheel" "Crossbow_model.bowl2" 0 0.000001 0 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.pull" "Crossbow_model.Crossbow_base" -0.014498 1.032727 0.773409 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.bolt" "Crossbow_model.Crossbow_base" 0 1.225078 6.591254 0 0 0 0 0 0 0 0 0
$definebone "Crossbow_model.Spark2" "Crossbow_model.Crossbow_base" -0.660498 1.291518 20.374771 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"v_crossbow_dx7_anims\idle.smd"
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	node "Ready"
	fps 30
	loop
}

$sequence "idle_empty" {
	"v_crossbow_dx7_anims\idle_empty.smd"
	activity "ACT_VM_FIDGET" 1
	fadein 0.2
	fadeout 0.2
	node "Ready"
	fps 30
	loop
}

$sequence "draw" {
	"v_crossbow_dx7_anims\draw.smd"
	activity "ACT_VM_DRAW" 1
	{ event 3013 14 "" }
	{ event 3016 28 "" }
	fadein 0.2
	fadeout 0.2
	node "Ready"
	snap
	fps 30
}

$sequence "fire" {
	"v_crossbow_dx7_anims\fire.smd"
	activity "ACT_VM_PRIMARYATTACK" 1
	fadein 0.2
	fadeout 0.2
	node "Ready"
	snap
	fps 30
}

$sequence "reload" {
	"v_crossbow_dx7_anims\reload.smd"
	activity "ACT_VM_RELOAD" 1
	{ event 3005 28 "" }
	{ event 3013 35 "" }
	{ event 3016 55 "" }
	fadein 0.2
	fadeout 0.2
	node "Ready"
	fps 30
}

$sequence "holster" {
	"v_crossbow_dx7_anims\holster.smd"
	activity "ACT_VM_HOLSTER" 1
	fadein 0.2
	fadeout 0.2
	node "Ready"
	fps 30
}

$sequence "idletolow" {
	"v_crossbow_dx7_anims\idletolow.smd"
	activity "ACT_VM_LOWERED_TO_IDLE" 1
	fadein 0.2
	fadeout 0.2
	transition "Ready" "Low"
	fps 30
}

$sequence "lowtoidle" {
	"v_crossbow_dx7_anims\lowtoidle.smd"
	activity "ACT_VM_IDLE_TO_LOWERED" 1
	fadein 0.2
	fadeout 0.2
	transition "Low" "Ready"
	fps 30
}

$sequence "lowidle" {
	"v_crossbow_dx7_anims\lowidle.smd"
	activity "ACT_VM_IDLE_LOWERED" 1
	fadein 0.2
	fadeout 0.2
	node "Low"
	fps 30
	loop
}
