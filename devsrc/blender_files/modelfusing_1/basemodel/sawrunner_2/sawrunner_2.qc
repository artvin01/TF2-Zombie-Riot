// Created by Crowbar 0.71

$modelname "zombie_riot\cof\sawrunner_2.mdl"

$bodygroup "body"
{
	studio "ref1.smd"
}


$surfaceprop "flesh"

$contents "solid"

$illumposition -0.571 -11.403 39.906

$eyeposition 0 0 55

$cdmaterials "models\zombie_riot\cof\sawrunner\"

$cbox -13 -13 0 13 13 72

$bbox -13 -13 0 13 13 72

$hboxset "default"
$hbox 0 "Bip01 Pelvis" -6.65 -6.36 -4.08 1.42 4.63 4.82
$hbox 0 "Bip01 L Leg" 0 -6.38 -4.66 21.969999 4.27 2.95
$hbox 0 "Bip01 L Leg1" 0 -4.59 -4.68 19.360001 2.6 2.02
$hbox 0 "Bip01 L Foot" 0 -4.08 -3.63 4.39 9.38 1.52
$hbox 0 "Bip01 R Leg" 0 -6.4 -4 21.99 4.26 3.94
$hbox 0 "Bip01 R Leg1" 0 -4.59 -3.43 19.4 2.6 3.37
$hbox 0 "Bip01 R Foot" 0 -4.08 -2.96 4.39 9.38 2.2
$hbox 0 "Bip01 Spine" -0.71 -7.12 -7.82 5.84 4.04 8.92
$hbox 0 "Bip01 Spine1" 0 -5.8 -7.05 5.31 3.5 8.38
$hbox 0 "Bip01 Spine2" -1.25 -6.46 -7.42 6.37 3.45 6.89
$hbox 0 "Bip01 Spine3" 0 0 -3.45 7.33 3.28 4.8
$hbox 0 "Bip01 Neck" -7.42 -3.49 -7.41 -1.75 3.93 8.93
$hbox 0 "Bip01 L Arm" 0 -2.41 -4.87 8.36 3.71 3.51
$hbox 0 "Bip01 L Arm1" 0 -1.63 -1.5 12.25 5.15 5.01
$hbox 0 "Bip01 L Arm2" 0 -2.45 -1.48 11.35 2.58 4.08
$hbox 0 "Bip01 L Hand" -0.07 -3.4 -2.91 4.71 1.32 2.7
$hbox 0 "Bip01 R Arm" 0 -2.25 -2.24 5.47 4.69 0.61
$hbox 0 "Bip01 R Arm1" 0 -2.49 -2.99 12.74 4.8 3.49
$hbox 0 "Bip01 R Arm2" -1.37 -2.53 -2.79 11.14 2.78 2.5
$hbox 0 "Bip01 R Hand" -1.43 -7.61 -2.61 3.73 3.02 8.17
$hbox 1 "Bip01 Head" -2.63 -8.47 -5.08 10.87 5.44 5.85
$skipboneinbbox

$definebone "Bip01" "" 0.257234 0.40498 43.478733 0 -89.999921 0 0 0 0 0 0 0
$definebone "Bip01 Pelvis" "Bip01" 0 0 0 -89.999982 -89.999921 0 0 0 0 0 0 0
$definebone "Bip01 L Leg" "Bip01 Pelvis" -0.000008 0.000008 4.08458 1.494732 178.76971 -179.882335 0 0 0 0 0 0
$definebone "Bip01 L Leg1" "Bip01 L Leg" 19.850286 0 0 0 -6.961495 0 0 0 0 0 0 0
$definebone "Bip01 L Foot" "Bip01 L Leg1" 19.357357 0 0 1.491753 5.727687 -0.149714 0 0 0 0 0 0
$definebone "Bip01 R Leg" "Bip01 Pelvis" 0.000008 -0.000003 -4.08458 -0.994368 178.599202 179.85541 0 0 0 0 0 0
$definebone "Bip01 R Leg1" "Bip01 R Leg" 19.850304 0 0 0 -7.308138 0 0 0 0 0 0 0
$definebone "Bip01 R Foot" "Bip01 R Leg1" 19.357349 0 0 -0.990587 5.904614 0.169023 0 0 0 0 0 0
$definebone "Bip01 Spine" "Bip01 Pelvis" 1.423038 0.752926 -0.000001 -0.000057 6.542319 -0.000229 0 0 0 0 0 0
$definebone "Bip01 Spine1" "Bip01 Spine" 5.840652 -0.004218 0 0 -3.997985 0 0 0 0 0 0 0
$definebone "Bip01 Spine2" "Bip01 Spine1" 5.309464 -0.00505 0 0 -5.497187 0 0 0 0 0 0 0
$definebone "Bip01 Spine3" "Bip01 Spine2" 6.37204 -0.005834 0 0 0.999467 0 0 0 0 0 0 0
$definebone "Bip01 Neck" "Bip01 Spine3" 7.328545 -0.001598 0 -0.000057 26.986311 0 0 0 0 0 0 0
$definebone "Bip01 L Arm" "Bip01 Neck" -3.423218 1.668976 4.776102 -78.540885 152.968862 -0.000802 0 0 0 0 0 0
$definebone "Bip01 L Arm1" "Bip01 L Arm" 5.309952 0 0.000008 72.200072 6.513275 6.420957 0 0 0 0 0 0
$definebone "Bip01 L Arm2" "Bip01 L Arm1" 12.253735 0 0 -0.000003 -11.459152 0 0 0 0 0 0 0
$definebone "Bip01 L Hand" "Bip01 L Arm2" 11.346054 0.000003 0 -0.000001 -3.997982 -89.954377 0 0 0 0 0 0
$definebone "Bip01 R Arm" "Bip01 Neck" -3.156883 1.539629 -4.554437 78.540769 152.967305 -0.000745 0 0 0 0 0 0
$definebone "Bip01 R Arm1" "Bip01 R Arm" 5.469254 0 0 -72.696599 6.701143 -6.600123 0 0 0 0 0 0
$definebone "Bip01 R Arm2" "Bip01 R Arm1" 12.743889 0 -0.000002 0.000002 -11.459151 0 0 0 0 0 0 0
$definebone "Bip01 R Hand" "Bip01 R Arm2" 11.139755 0 0 0.000002 -3.99798 89.940163 0 0 0 0 0 0
$definebone "Bip01 Head" "Bip01 Neck" 2.251686 0.000002 0 0 -9.041156 0 0 0 0 0 0 0


$poseparameter "move_y" -1 1 loop 0
$poseparameter "move_x" -1 1 loop 0

$ikchain "rfoot" "Bip01 R Foot" knee 0.447 0.894 -0.025
$ikchain "lfoot" "Bip01 L Foot" knee 0.457 0.888 0.056

$weightlist "weights_melee_1" {
	 "Bip01" 0
	 "Bip01 Pelvis" 0
	 "Bip01 L Leg" 0
	 "Bip01 L Leg1" 0
	 "Bip01 L Foot" 0
	 "Bip01 R Leg" 0
	 "Bip01 R Leg1" 0
	 "Bip01 R Foot" 0
	 "Bip01 Spine" 0
	 "Bip01 Spine1" 0
	 "Bip01 Spine2" 0
	 "Bip01 Spine3" 0
	 "Bip01 Neck" 0
	 "Bip01 L Arm" 0
	 "Bip01 L Arm1" 0
	 "Bip01 L Arm2" 0
	 "Bip01 L Hand" 0
	 "Bip01 R Arm" 0
	 "Bip01 R Arm1" 0
	 "Bip01 R Arm2" 0
	 "Bip01 R Hand" 0
	 "Bip01 Head" 0
}

$weightlist "weights_hurt" {
	 "Bip01" 0
	 "Bip01 Pelvis" 0
	 "Bip01 L Leg" 0
	 "Bip01 L Leg1" 0
	 "Bip01 L Foot" 0
	 "Bip01 R Leg" 0
	 "Bip01 R Leg1" 0
	 "Bip01 R Foot" 0
	 "Bip01 Spine" 0
	 "Bip01 Spine1" 1
	 "Bip01 Spine2" 1
	 "Bip01 Spine3" 1
	 "Bip01 Neck" 0
	 "Bip01 L Arm" 0
	 "Bip01 L Arm1" 0
	 "Bip01 L Arm2" 0
	 "Bip01 L Hand" 0
	 "Bip01 R Arm" 0
	 "Bip01 R Arm1" 0
	 "Bip01 R Arm2" 0
	 "Bip01 R Hand" 0
	 "Bip01 Head" 1
}

$sequence "idle" {
	"sawrunner_2_anims\idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.1
	fadeout 0.2
	fps 30
	loop
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 60 60 target 0
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 60 60 target 1
}

$sequence "RUN" {
	"sawrunner_2_anims\RUN.smd"
	"sawrunner_2_anims\RUN_2.smd"
	"sawrunner_2_anims\RUN_3.smd"
	"sawrunner_2_anims\RUN_4.smd"
	"sawrunner_2_anims\RUN_5.smd"
	"sawrunner_2_anims\RUN_6.smd"
	"sawrunner_2_anims\RUN_7.smd"
	"sawrunner_2_anims\RUN_8.smd"
	"sawrunner_2_anims\RUN_9.smd"
	activity "ACT_RUN" 1
	blend "move_y" -1 1
	blend "move_x" -1 1
	{ event 7001 4 "rfoot" }
	{ event 7001 15 "lfoot" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 0 usesequence 
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 1 usesequence 
	walkframe 20 LX LY
}

$sequence "melee_1" {
	"sawrunner_2_anims\melee_1.smd"
	activity "ACT_MELEE_1" 1
	fadein 0.2
	fadeout 0.2
	iklock "rfoot" 1 0
	blendlayer "melee_smooth_1" 0 3 17 20
	fps 30
	weightlist "weights_melee_1"
}

$sequence "melee_smooth_1" {
	"sawrunner_2_anims\melee_smooth_1.smd"
	fadein 0.2
	fadeout 0.2
	hidden
	iklock "rfoot" 1 0
	fps 60
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 0
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 1
}

$sequence "melee_2" {
	"sawrunner_2_anims\melee_2.smd"
	activity "ACT_MELEE_2" 1
	fadein 0.2
	fadeout 0.2
	blendlayer "melee_smooth_2" 0 3 17 20
	fps 30
	weightlist "weights_melee_1"
}

$sequence "melee_smooth_2" {
	"sawrunner_2_anims\melee_smooth_2.smd"
	fadein 0.2
	fadeout 0.2
	hidden
	fps 60
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 0
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 1
}

$sequence "melee_3" {
	"sawrunner_2_anims\melee_3.smd"
	activity "ACT_MELEE_3" 1
	fadein 0.2
	fadeout 0.2
	iklock "rfoot" 1 0
	iklock "lfoot" 1 0
	blendlayer "melee_smooth_3" 0 3 17 20
	fps 30
	weightlist "weights_melee_1"
}

$sequence "melee_smooth_3" {
	"sawrunner_2_anims\melee_smooth_3.smd"
	fadein 0.2
	fadeout 0.2
	hidden
	iklock "rfoot" 1 0
	iklock "lfoot" 1 0
	fps 60
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 0
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 20 20 target 1
}

$sequence "hurt" {
	"sawrunner_2_anims\hurt.smd"
	activity "ACT_HURT" 1
	fadein 0.2
	fadeout 0.2
	iklock "rfoot" 1 0
	iklock "lfoot" 1 0
	fps 30
	weightlist "weights_hurt"
}

$sequence "death" {
	"sawrunner_2_anims\death.smd"
	activity "ACT_DEATH" 1
	fadein 0.1
	fadeout 0.2
	fps 30
	loop
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 63 63 target 0
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 63 63 target 1
}

$sequence "spawn" {
	"sawrunner_2_anims\spawn.smd"
	activity "ACT_SPAWN" 1
	fadein 0.1
	fadeout 0.2
	fps 30
	loop
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 60 60 target 0
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 60 60 target 1
}

$sequence "spawn_special" {
	"sawrunner_2_anims\spawn_special.smd"
	activity "ACT_SPAWN_SPECIAL" 1
	fadein 0.1
	fadeout 0.2
	iklock "rfoot" 1 0
	fps 30
	loop
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 60 60 target 0
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 60 60 target 1
}
