#pragma semicolon 1
#pragma newdecls required

void Invisible_TRIGGER_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "0h No it's Not Fair");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_invisible_trigger");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Invisible_TRIGGER(vecPos, vecAng, ally, data);
}

methodmap Invisible_TRIGGER < CClotBody
{
	property int i_NPCStats
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property int i_GetWave
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}

	public Invisible_TRIGGER(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ally = TFTeam_Stalkers;
		Invisible_TRIGGER npc = view_as<Invisible_TRIGGER>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "12000", ally));
		
		b_NoKillFeed[npc.index] = true;
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.i_NPCStats=0;
		
		bool fVerify=false;
		func_NPCDeath[npc.index] = view_as<Function>(Invisible_TRIGGER_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
		func_NPCThink[npc.index] = view_as<Function>(Invisible_TRIGGER_ClotThink);
		if(!StrContains(data, "factory_emergency_extraction"))
		{
			npc.i_NPCStats=1;
			fVerify=true;
		}
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flNextMeleeAttack = GetGameTime() + 2.0;
		npc.m_flNextRangedAttack = 0.0;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_NoHealthbar[npc.index]=true;
		npc.m_bTeamGlowDefault = false;
		if(IsValidEntity(i_InvincibleParticle[npc.index]))
		{
			int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
			SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
			SetEntityRenderColor(particle, 255, 255, 255, 1);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
		}
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
			
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		
		if(!fVerify || npc.i_NPCStats==0)
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			SmiteNpcToDeath(npc.index);
		}
		
		return npc;
	}
}

static void Invisible_TRIGGER_ClotThink(int iNPC)
{
	Invisible_TRIGGER npc = view_as<Invisible_TRIGGER>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;

	switch(npc.i_NPCStats)
	{
		case 1:
		{
			bool bExtraction=false;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if (IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianFactory_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == TFTeam_Blue)
				{
					VictorianFactory vFactory = view_as<VictorianFactory>(entity);
					vFactory.m_flNextRangedAttack = GetGameTime(vFactory.index) + 10.0;
					if(f_DelaySpawnsForVariousReasons < GetGameTime() + 21.0)
					{
						i_AttacksTillMegahit[vFactory.index] = 608;
						bExtraction=true;
					}
				}
			}
			if(bExtraction)
			{
				EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
				EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
				SmiteNpcToDeath(npc.index);
			}
		}
		default:SmiteNpcToDeath(npc.index);//WTF HOW???
	}
}

static void Invisible_TRIGGER_NPCDeath(int entity)
{
	Invisible_TRIGGER npc = view_as<Invisible_TRIGGER>(entity);

	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}