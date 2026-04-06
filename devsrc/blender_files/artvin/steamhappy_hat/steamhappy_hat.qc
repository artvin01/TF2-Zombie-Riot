// Created by Crowbar 0.74

$modelname "zombie_riot/steamhappy_hat_8.mdl"

$bodygroup "mybody"
{
	studio "steamhappy.smd"
}


$surfaceprop "flesh"

$contents "solid"

$illumposition 0 -1.64 0.22

$cdmaterials "steamhappy\"
$cdmaterials ""

$texturegroup "skinfamilies"
{
	{ "HappyColors"    }
	{ "HappyColorable" }
}

$cbox 0 0 0 0 0 0
$attachment "head" "bip_head" 0.00 0.00 0.00 rotate 0 0 -0

$bbox -14.935 -29.909 -35.043 18.215 29.91 35.483

$sequence "idle" {
	"steamhappy_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}
