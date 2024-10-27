#pragma semicolon 1
#pragma newdecls required

public bool Plots_Crafting_Smithing1(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Smelting Tier 1");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Smithing2(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Smelting Tier 1");
	list.PushString("Smelting Tier 2");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Cooking1(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Cooking Tier 1");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Cooking2(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Cooking Tier 1");
	list.PushString("Cooking Tier 2");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Smelting1(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Smelting Tier 1");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Smelting2(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Smelting Tier 1");
	list.PushString("Smelting Tier 2");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Proofer1(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Proofing Blocks");
	list.PushString("Proofing Tier 1");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Proofer2(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Proofing Blocks");
	list.PushString("Proofing Tier 1");
	list.PushString("Proofing Tier 2");
	Crafting_SetCustomMenu(client, list);
	return true;
}

public bool Plots_Crafting_Proofer3(int entity, BuildEnum build, int client)
{
	if(!client)
		return false;
	
	ArrayList list = new ArrayList(ByteCountToCells(64));
	list.PushString("Proofing Blocks");
	list.PushString("Proofing Tier 1");
	list.PushString("Proofing Tier 2");
	list.PushString("Proofing Tier 3");
	Crafting_SetCustomMenu(client, list);
	return true;
}