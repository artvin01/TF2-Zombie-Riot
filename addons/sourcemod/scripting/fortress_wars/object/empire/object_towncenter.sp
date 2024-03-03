#pragma semicolon 1
#pragma newdecls required

void TownCenter_Setup()
{
	PrecacheModel("models/props_foliage/deadtree01.mdl");
	
	ObjectData data;
	strcopy(data.Name, sizeof(data.Name), "Town Center");
	strcopy(data.Plugin, sizeof(data.Plugin), "object_towncenter");
	data.Func = ClotSummoned;
	Object_Add(data);
}
