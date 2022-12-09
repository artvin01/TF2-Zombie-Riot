#pragma semicolon 1
#pragma newdecls required

float f_clientFoundRareRockSpot[MAXTF2PLAYERS];
float f_clientFoundRareRockSpotPos[MAXTF2PLAYERS][3];

enum struct FishingEnum
{
	char Zone[32];
	float Pos[3];
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Model, PLATFORM_MAX_PATH);
		ExplodeStringFloat(this.Model, " ", this.Pos, sizeof(this.Pos));

		kv.GetString("zone", this.Zone, 32);
	}
	
	void DespawnFish()
	{
		if(this.EntRef != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
			
			this.EntRef = INVALID_ENT_REFERENCE;
		}
	}
	
	void SpawnFish()
	{

	}

	void IsFishValid()
	{

	}
}

static ArrayList FishingList;
static int MineDamage[MAXTF2PLAYERS];

void Mining_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Fishing"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "Fishing");
		kv = new KeyValues("Fishing");
		kv.ImportFromFile(buffer);
	}
	
	delete FishingList;
	FishingList = new ArrayList(sizeof(FishingEnum));

	FishingEnum fish;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(fish.Zone, sizeof(fish.Zone));

		if(kv.GotoFirstSubKey())
		{
			do
			{
				fish.SetupEnum(kv);
				FishingList.PushArray(fish);
			}
			while(kv.GotoNextKey());
			kv.GoBack();
		}
	}
	while(kv.GotoNextKey());

	if(kv != map)
		delete kv;
}