

#define STEAM_HAPPY 1

int AprilFoolsMode = 0;

void CheckAprilFools()
{
	AprilFoolsMode = 0;
	char buffer[128];
	zr_tagwhitelist.GetString(buffer, sizeof(buffer));
	if(StrContains(buffer, "fools24", false) != -1)
	{
		AprilFoolsMode = 1;
		PrecacheSound("zombie_riot/yippe.mp3");
		PrecacheModel("models/steamhappy.mdl");
		PrecacheModel("materials/hud/leaderboard_class_steamhappy.vtf");
		PrecacheModel("materials/hud/leaderboard_class_steamhappy.vmt");
		AddToDownloadsTable("materials/hud/leaderboard_class_steamhappy.vtf");	
		AddToDownloadsTable("materials/hud/leaderboard_class_steamhappy.vmt");		
		AddToDownloadsTable("models/steamhappy.dx80.vtx");			
		AddToDownloadsTable("models/steamhappy.dx90.vtx");			
		AddToDownloadsTable("models/steamhappy.mdl");			
		AddToDownloadsTable("models/steamhappy.vvd");			
		AddToDownloadsTable("models/steamhappy.dx90.vtx");	
		AddToDownloadsTable("materials/steamhappy/happycolors.vmt");		
		AddToDownloadsTable("materials/steamhappy/happycolorable.vmt");		
		AddToDownloadsTable("materials/steamhappy/eye.vmt");		
		AddToDownloadsTable("materials/steamhappy/happycolors.vtf");
		AddToDownloadsTable("materials/steamhappy/happycolorable.vtf");
		AddToDownloadsTable("materials/steamhappy/eye.vtf");
		AddToDownloadsTable("sound/zombie_riot/yippe.mp3");
	}
}
int AprilFoolsIconOverride()
{
	return AprilFoolsMode;
}
bool AprilFoolsSoundDo(float volumeedited, 
				 int client,
				 int entity = SOUND_FROM_PLAYER,
				 int channel = SNDCHAN_AUTO,
				 int level = SNDLEVEL_NORMAL,
				 int flags = SND_NOFLAGS,
				 int pitch = SNDPITCH_NORMAL,
				 int speakerentity = -1,
				 const float origin[3] = NULL_VECTOR,
				 const float dir[3] = NULL_VECTOR,
				 bool updatePos = true,
				 float soundtime = 0.0)
{
	if(AprilFoolsMode <= 0)
		return false;

	if(entity <= 0 || entity > MAXENTITIES)
		return false;

	if(!b_ThisWasAnNpc[entity])
		return false;
		
	int team = GetTeam(entity);

	//Dont touch red team
	if(team == 2)
		return false;

	switch(AprilFoolsMode)
	{
		case 1:
		{
			EmitSoundToClient(client, "zombie_riot/yippe.mp3",entity,channel,level,flags,volumeedited,pitch,speakerentity,origin,dir,updatePos,soundtime);
		}
	}
	return true;
}
bool ModelReplaceDo(int iNpc, int TeamIs)
{
	if(AprilFoolsMode <= 0)
		return false;
	//dont touch red
	if(TeamIs == 2)
		return false;
		
	switch(AprilFoolsMode)
	{
		case 1:
		{
			DispatchKeyValue(iNpc, "model",	 "models/steamhappy.mdl");
			view_as<CBaseCombatCharacter>(iNpc).SetModel("models/steamhappy.mdl");
		}
	}
	return true;
}

void AprilFoolsModelHideWearables(int iNpc)
{
	if(f_AprilFoolsSetStuff[iNpc])
	{
		//Reuse....
		/*
		if(!b_thisNpcIsARaid[iNpc])
		{
			//If its not a raidboss,then dont send over animation data, it really doesnt make a big difference.
			//Lets hope it wont break.
			SetEntProp(iNpc, Prop_Send, "m_bClientSideAnimation", 1);
		}
		else
			SetEntProp(iNpc, Prop_Send, "m_bClientSideAnimation", 0);
		*/

		f_AprilFoolsSetStuff[iNpc] = 1.0;
	}

	if(AprilFoolsMode <= 0)
		return;
		
	int team = GetTeam(iNpc);

	//Dont touch red team
	if(team == 2)
		return;

	f_AprilFoolsSetStuff[iNpc] = 1.0;
	
	CClotBody npc = view_as<CClotBody>(iNpc);
	
	if(IsValidEntity(npc.m_iWearable1) && !b_EntityCantBeColoured[npc.m_iWearable1])
	{
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable2) && !b_EntityCantBeColoured[npc.m_iWearable2])
	{
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable3) && !b_EntityCantBeColoured[npc.m_iWearable3])
	{
		SetEntityRenderMode(npc.m_iWearable3, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable4) && !b_EntityCantBeColoured[npc.m_iWearable4])
	{
		SetEntityRenderMode(npc.m_iWearable4, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable5) && !b_EntityCantBeColoured[npc.m_iWearable5])
	{
		SetEntityRenderMode(npc.m_iWearable5, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable6) && !b_EntityCantBeColoured[npc.m_iWearable6])
	{
		SetEntityRenderMode(npc.m_iWearable6, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable6, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable7) && !b_EntityCantBeColoured[npc.m_iWearable7])
	{
		SetEntityRenderMode(npc.m_iWearable7, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable7, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable8) && !b_EntityCantBeColoured[npc.m_iWearable8])
	{
		SetEntityRenderMode(npc.m_iWearable8, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable8, 0, 0, 0, 0);
	}

	SetEntProp(iNpc, Prop_Send, "m_nSkin", 1);
	SetEntityRenderColor(iNpc, GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);
	SetEntPropFloat(iNpc, Prop_Send, "m_flModelScale", GetRandomFloat(1.2, 2.5));
	strcopy(c_NpcName[iNpc], sizeof(c_NpcName[]), "Steam Happy");
	b_NameNoTranslation[iNpc] = true;
	npc.m_bDissapearOnDeath = true;
}