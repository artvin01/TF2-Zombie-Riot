#pragma semicolon 1
#pragma newdecls required

#define LOW	0
#define HIGH	1

enum struct SpawnEnum
{
	int Index;
	char Zone[32];
	float Pos[3];
	float Angle;
	int Count;
	float Time;
	
	bool Boss;
	int Level[2];
	int Health[2];
	int XP[2];
	int Cash[2];
	float DropMulti;
	
	char Item1[48];
	float Chance1;
	
	char Item2[48];
	float Chance2;
	
	char Item3[48];
	float Chance3;
	
	void DoAllDrops(int client, const float pos[3], int level)
	{
		float multi = float(level - this.Level[LOW]) / float(this.Level[HIGH] - this.Level[LOW]) * this.DropMulti;
		float addon = 0.0;//float(luck) * 0.01;
		
		if(this.Item1[0])
			RollItemDrop(this.Item1, (this.Chance1 * multi) + addon, pos);
		
		if(this.Item2[0])
			RollItemDrop(this.Item2, (this.Chance2 * multi) + addon, pos);
		
		if(this.Item3[0])
			RollItemDrop(this.Item3, (this.Chance3 * multi) + addon, pos);

	}
}

void Spawns_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Spawns"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "spawns");
		kv = new KeyValues("Spawns");
		kv.ImportFromFile(buffer);
		RequestFrame(DeleteHandle, kv);
	}
	
	
}

static void RollItemDrop(const char[] name, float chance, const float pos[3])
{
	if(chance > GetURandomFloat())
	{
		// THIN
	}
}