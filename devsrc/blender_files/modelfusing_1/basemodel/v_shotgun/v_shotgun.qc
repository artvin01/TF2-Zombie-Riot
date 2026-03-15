// Created by Crowbar 0.71

$modelname "weapons/v_shotgun.mdl"

$bodygroup "studio"
{
	studio "Shotgun_reference.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition -4.919 -28.541 -16.577

$cdmaterials "models\Weapons\V_hand\"
$cdmaterials "models\Weapons\V_shotgun\"
$cdmaterials "models\weapons\shell\"

$attachment "muzzle" "ValveBiped.Gun" -0.03 0.51 23.45 rotate -90 0 0
$attachment "1" "ValveBiped.Gun" -0.95 1.14 -5.59 rotate 0 180 -180

$cbox 0 0 0 0 0 0

$bbox 5.199 -12.665 -29.433 51.883 2.828 -3.721

$definebone "ValveBiped.Bip01" "" -5.947269 -23.90802 38.566917 0 0 89.999982 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_Spine" "ValveBiped.Bip01" 0.000005 3.345128 -2.981899 4.944225 89.999982 89.999982 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_Spine1" "ValveBiped.Bip01_Spine" 4.018333 0.000001 0 0 -1.675443 0 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_Spine2" "ValveBiped.Bip01_Spine1" 3.518567 0.000001 0 0 5.74883 0 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_Spine4" "ValveBiped.Bip01_Spine2" 8.942642 0.000001 0 0 11.120881 0 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Clavicle" "ValveBiped.Bip01_Spine4" 2.033348 1.000768 1.93766 -73.711859 168.619271 91.480542 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_UpperArm" "ValveBiped.Bip01_L_Clavicle" 6.028142 0.000002 0.000001 -59.159677 -108.662484 -25.516391 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Forearm" "ValveBiped.Bip01_L_UpperArm" 11.692554 0 0.000001 0.000004 -49.047769 0.000003 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Hand" "ValveBiped.Bip01_L_Forearm" 11.481671 -0.000001 -0.000032 11.721118 11.768664 -24.9762 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger4" "ValveBiped.Bip01_L_Hand" 3.859702 -0.142405 -1.191976 -14.030307 -76.07212 -28.807009 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger41" "ValveBiped.Bip01_L_Finger4" 1.312565 0 -0.000002 -0.000005 -15.772502 -0.000008 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger42" "ValveBiped.Bip01_L_Finger41" 0.729364 -0.000002 0 -0.000006 -5.358308 -0.000008 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger3" "ValveBiped.Bip01_L_Hand" 3.942324 0.046772 -0.431444 -8.028915 -54.111166 -14.52403 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger31" "ValveBiped.Bip01_L_Finger3" 1.539093 0 0 -0.000002 -24.224765 -0.000008 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger32" "ValveBiped.Bip01_L_Finger31" 1.196321 0 -0.000001 -0.000006 -39.289031 -0.000006 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger2" "ValveBiped.Bip01_L_Hand" 3.883687 -0.046772 0.431442 -8.563538 -32.739894 -2.790253 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger21" "ValveBiped.Bip01_L_Finger2" 1.719572 0.000001 0.000001 -0.000003 -45.242633 -0.000006 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger22" "ValveBiped.Bip01_L_Finger21" 1.209184 0 0.000001 -0.000006 -36.590399 -0.000002 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger1" "ValveBiped.Bip01_L_Hand" 3.859859 -0.137946 1.332466 -11.505562 -26.967865 13.36693 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger11" "ValveBiped.Bip01_L_Finger1" 1.719428 -0.000001 0 0.000001 -48.774354 -0.000004 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger12" "ValveBiped.Bip01_L_Finger11" 1.099664 0 0 -0.000002 -41.395109 -0.000002 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger0" "ValveBiped.Bip01_L_Hand" 0.806045 -0.34892 1.321257 -29.885312 -73.911724 -52.689032 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger01" "ValveBiped.Bip01_L_Finger0" 1.789787 0 0.000001 -0.000001 14.809127 0.000001 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger02" "ValveBiped.Bip01_L_Finger01" 1.206995 0 -0.000001 -0.000001 4.830036 0.000001 0 0 0 0 0 0
$definebone "ValveBiped.Gun" "ValveBiped.Bip01_Spine2" 11.946135 24.169962 -4.014896 -89.999982 -89.129092 0 0 0 0 0 0 0
$definebone "ValveBiped.Pump" "ValveBiped.Gun" -0.004454 -0.545139 -2.13655 0 0 0 0 0 0 0 0 0
$definebone "ValveBiped.square" "ValveBiped.Gun" 0.009659 -6.406695 -21.608532 0 0 0 0 0 0 0 0 0


$sequence "idle01" {
	"v_shotgun_anims\idle01.smd"
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	node "0"
	fps 30
	loop
}

$sequence "fire01" {
	"v_shotgun_anims\fire01.smd"
	activity "ACT_VM_PRIMARYATTACK" 1
	{ event AE_MUZZLEFLASH 0 "SHOTGUN MUZZLE" }
	fadein 0.2
	fadeout 0.2
	node "2"
	snap
	fps 30
}

$sequence "altfire" {
	"v_shotgun_anims\altfire.smd"
	activity "ACT_VM_SECONDARYATTACK" 1
	{ event AE_MUZZLEFLASH 0 "SHOTGUN MUZZLE" }
	fadein 0.2
	fadeout 0.2
	node "2"
	snap
	fps 30
}

$sequence "draw" {
	"v_shotgun_anims\draw.smd"
	activity "ACT_VM_DRAW" 1
	fadein 0.2
	fadeout 0.2
	node "0"
	snap
	fps 30
}

$sequence "holster" {
	"v_shotgun_anims\holster.smd"
	activity "ACT_VM_HOLSTER" 1
	fadein 0.2
	fadeout 0.2
	node "0"
	fps 30
}

$sequence "reload1" {
	"v_shotgun_anims\reload1.smd"
	activity "ACT_SHOTGUN_RELOAD_START" 1
	fadein 0.2
	fadeout 0.2
	node "0"
	fps 30
}

$sequence "reload2" {
	"v_shotgun_anims\reload2.smd"
	activity "ACT_VM_RELOAD" 1
	fadein 0.2
	fadeout 0.2
	node "0"
	fps 30
}

$sequence "reload3" {
	"v_shotgun_anims\reload3.smd"
	activity "ACT_SHOTGUN_RELOAD_FINISH" 1
	fadein 0.2
	fadeout 0.2
	node "0"
	fps 30
}

$sequence "pump" {
	"v_shotgun_anims\pump.smd"
	activity "ACT_SHOTGUN_PUMP" 1
	{ event 6001 5 "2" }
	fadein 0.2
	fadeout 0.2
	node "0"
	fps 30
}

$sequence "dryfire" {
	"v_shotgun_anims\dryfire.smd"
	activity "ACT_VM_DRYFIRE" 1
	fadein 0.2
	fadeout 0.2
	node "2"
	fps 30
}

$sequence "lowered" {
	"v_shotgun_anims\lowered.smd"
	activity "ACT_VM_IDLE_LOWERED" 1
	fadein 0.2
	fadeout 0.2
	node "1"
	fps 30
	loop
}

$sequence "lowered_to_idle" {
	"v_shotgun_anims\lowered_to_idle.smd"
	activity "ACT_VM_LOWERED_TO_IDLE" 1
	fadein 0.2
	fadeout 0.2
	transition "1" "0"
	fps 30
}

$sequence "idle_to_lowered" {
	"v_shotgun_anims\idle_to_lowered.smd"
	activity "ACT_VM_IDLE_TO_LOWERED" 1
	fadein 0.2
	fadeout 0.2
	transition "0" "1"
	fps 30
}

$sequence "fire" {
	"v_shotgun_anims\fire.smd"
	activity "ACT_RANGE_ATTACK_SHOTGUN" 1
	{ event AE_MUZZLEFLASH 0 "SHOTGUN MUZZLE" }
	{ event 6001 0 "3" }
	{ event 3004 0 "" }
	fadein 0.2
	fadeout 0.2
	fps 5
}
