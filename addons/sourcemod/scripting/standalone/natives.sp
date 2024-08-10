#pragma semicolon 1
#pragma newdecls required

void Natives_PluginLoad()
{
	CreateNative("NPC_SpawnNPC", NPC_SpawnNPC);
}

static any NPC_SpawnNPC(Handle plugin, int numParams)
{
	int length;
	GetNativeStringLength(1, length);
	char[] name = new char[++length];
	GetNativeString(1, name, length);

	float pos[3], ang[3];
	GetNativeArray(3, pos, sizeof(pos));
	GetNativeArray(4, ang, sizeof(ang));

	GetNativeStringLength(6, length);
	char[] data = new char[++length];
	GetNativeString(6, data, length);

	return NPC_CreateByName(name, GetNativeCell(2), pos, ang, GetNativeCell(5), data);
}