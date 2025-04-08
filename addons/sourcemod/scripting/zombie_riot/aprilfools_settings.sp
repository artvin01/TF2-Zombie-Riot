

#define STEAM_HAPPY 1

int AprilFoolsMode = 0;

void CheckAprilFools()
{
	char buffer[128];
	zr_tagwhitelist.GetString(buffer, sizeof(buffer));
	if(StrContains(buffer, "fools24", false) != -1)
		AprilFoolsMode = 1;
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
}