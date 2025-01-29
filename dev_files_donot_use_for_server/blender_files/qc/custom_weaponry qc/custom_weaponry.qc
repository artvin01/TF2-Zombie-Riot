// Created by Crowbar 0.71

$modelname "zombie_riot/weapons/custom_weaponry_1_42"

$bodygroup "scythe"					//1
{
	blank
	studio "scythe_model.smd"
}

$bodygroup "scythe_throw"			//2
{
	blank
	studio "scythe_model_throw.smd"
}

$bodygroup "crossbow"				//4
{
	blank
	studio "w_crossbow_reference.smd"
}

$bodygroup "annabelle"				//8
{
	blank
	studio "w_annabelle_reference.smd"
}

$bodygroup "Shotgun_boomstick"		//16	
{
	blank
	studio "Shotgun_reference.smd"			
}

$bodygroup "mg42"					//32
{
	blank
	studio "mg42.smd"
}

$bodygroup "chainsaw"				//64
{
	blank
	studio "chainsaw.smd"
}
$bodygroup "medikit"				//128
{
	blank
	studio "healthKit_reference.smd"
}

$bodygroup "newspaper"				//256
{
	blank
	studio "garbage_newspaper001a_reference.smd"
}

$bodygroup "scythe_rotate"			//512	
{
	blank
	studio "scythe_model_rotate.smd"
}
$bodygroup "fusion_blade1_1"		//1024
{
	blank
	studio "fusion_blade1_1.smd"
}

$bodygroup "fusion_blade2"			//2048
{
	blank
	studio "fusion_blade2.smd"
}

$bodygroup "fusion_blade_siccor"			//4096
{
	blank
	studio "fusion_blade_siccor.smd"
}

$bodygroup "fusion_blade2_erasus"			//8192
{
	blank
	studio "fusion_blade2_erasus.smd"
}
$bodygroup "fusion_blade2_dual"			//16384
{
	blank
	studio "fusion_blade2_dual.smd"
}

//the .blend files are located: "blender_files/jdeivid/test models/"

$surfaceprop "weapon"

$contents "solid"

$illumposition 0.096 -0.043 13.267

$cdmaterials "models\custom_weaponry"
$cdmaterials "models\props_junk\"
$cdmaterials "models\zombie_riot\cof\sawrunner\"
$cdmaterials "models\weapons\c_items\"
$cdmaterials "models\weapons\v_crossbow\"
$cdmaterials "models\weapons\w_annabelle\"
$cdmaterials "models\Weapons\V_shotgun\"
$cdmaterials "models\items\"
$cdmaterials ""

$attachment "duelrea_left_spike" 	"weapon_bone" -5.0 0.0 44.0 rotate 0.0 0.0 0.0
$attachment "duelrea_right_spike" 	"weapon_bone" 5.0 0.0 44.0 rotate 0.0 0.0 0.0

$cbox 0 0 0 0 0 0

$bbox -1.784 -1.784 -2.533 1.77 1.773 29.017

$definebone "weapon_bone" "" 0 0 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"c_invasion_bat_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "scythe_spin" {
	"anims\scythe_spin.smd"
	fadein 0.0
	fadeout 0.0
	fps 24
	loop
}