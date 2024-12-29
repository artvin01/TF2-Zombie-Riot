#pragma semicolon 1
#pragma newdecls required

/*
	
*/

void Manipulation_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_manipulation");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), ""); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, char[] data)
{
	return Manipulation(vecPos, vecAng, team, data);
}
methodmap Manipulation < CClotBody
{
	public Manipulation(float vecPos[3], float vecAng[3], int ally, char[] data)
	{
		Manipulation npc = view_as<Manipulation>(CClotBody(vecPos, vecAng, data, "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		/*
			


		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		npc.m_flSpeed = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;

		b_NoGravity[npc.index] = true;
		
		npc.Anger = false;

		Ruina_Set_Heirarchy(npc.index, RUINA_GLOBAL_NPC);

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 99999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 99999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 99999.0);	

		return npc;
	}
}
static void ClotThink(int iNPC)
{
	Manipulation npc = view_as<Manipulation>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flDoingAnimation > GameTime)
		return;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))	//a final final failsafe
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		return;
	}
	//float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	//float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	//float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);	

}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Manipulation npc = view_as<Manipulation>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Manipulation npc = view_as<Manipulation>(entity);
	
	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
}