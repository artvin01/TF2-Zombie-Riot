#pragma semicolon 1
#pragma newdecls required

public bool Plots_SkinSwap_7(int entity, BuildEnum build, int client)
{
	return SkinSwap(entity, build, client, 7);
}

public bool Plots_SkinSwap_11(int entity, BuildEnum build, int client)
{
	return SkinSwap(entity, build, client, 11);
}

static bool SkinSwap(int entity, BuildEnum build, int client, int cap)
{
	if(client)
	{
		if(!Plots_CanInteractHere(client))
			return false;
		
		build.Flags++;
		if(build.Flags >= cap)
			build.Flags = 0;
	}

	SetEntProp(entity, Prop_Send, "m_nSkin", build.Flags);
	return true;
}