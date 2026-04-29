local SoundList = [
	"mvm/mvm_money_pickup.wav",
	"ambient/halloween/thunder_03.wav"
]

foreach(strValue in SoundList)
{
	PrecacheSound(strValue)
}

PrecacheModel("models/player/items/engineer/teddy_roosebelt.mdl")