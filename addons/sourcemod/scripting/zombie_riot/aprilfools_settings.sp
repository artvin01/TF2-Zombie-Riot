

#define STEAM_HAPPY 1

int AprilFoolsMode = 0;

void CheckAprilFools()
{
	char buffer[128];
	zr_tagwhitelist.GetString(buffer, sizeof(buffer));
	if(StrContains(buffer, "fools24", false) != -1)
	{
		AprilFoolsMode = 1;
	}
}

void AprilFoolsSoundDo(int client,
				 const char[] sample,
				 int entity = SOUND_FROM_PLAYER,
				 int channel = SNDCHAN_AUTO,
				 int level = SNDLEVEL_NORMAL,
				 int flags = SND_NOFLAGS,
				 float volume = SNDVOL_NORMAL,
				 int pitch = SNDPITCH_NORMAL,
				 int speakerentity = -1,
				 const float origin[3] = NULL_VECTOR,
				 const float dir[3] = NULL_VECTOR,
				 bool updatePos = true,
				 float soundtime = 0.0)
{
	if(AprilFoolsMode <= 0)
		return false;
		
	int team = GetTeam(iNpc);

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
bool ModelReplaceDo(int iNpc)
{
	if(AprilFoolsMode <= 0)
		return false;
	int team = GetTeam(iNpc);

	//Dont touch red team
	if(team == 2)
		return false;
		
	switch(AprilFoolsMode)
	{
		case 1:
		{
			DispatchKeyValue(iNpc, "model",	 iNpc);
			view_as<CBaseCombatCharacter>(iNpc).SetModel(iNpc);
		}
	}
	return true;
}

void ModelHideWearables(int iNpc)
{
	if(AprilFoolsMode <= 0)
		return;
		
	int team = GetTeam(iNpc);

	//Dont touch red team
	if(team == 2)
		return;

	if(f_AprilFoolsSetStuff[iNpc])
		return;

	f_AprilFoolsSetStuff[iNpc] = true;
	
	CClotBody npc = view_as<CClotBody>(iNpc);
	
	if(IsValidEntity(npc.m_iWearable1))
	{
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable2))
	{
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable3))
	{
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable4))
	{
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable5))
	{
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable6))
	{
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable7))
	{
		SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable7, 0, 0, 0, 0);
	}
	if(IsValidEntity(npc.m_iWearable8))
	{
		SetEntityRenderMode(npc.m_iWearable8, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable8, 0, 0, 0, 0);
	}

	SetEntProp(iNPC, Prop_Send, "m_nSkin", 1);
	SetEntityRenderColor(iNPC, GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);
	SetEntPropFloat(iNPC, Prop_Send, "m_flModelScale", GetRandomFloat(1.2, 2.5));
	strcopy(c_NpcName[iNPC], sizeof(c_NpcName[]), "Steam Happy");
}