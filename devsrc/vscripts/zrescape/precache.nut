local SoundList = [
	"mvm/mvm_money_pickup.wav"
]

foreach(strValue in SoundList)
{
	PrecacheSound(strValue)
}

PrecacheModel("models/player/items/engineer/teddy_roosebelt.mdl")