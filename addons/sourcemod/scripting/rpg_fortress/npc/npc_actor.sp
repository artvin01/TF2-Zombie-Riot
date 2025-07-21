#pragma semicolon 1
#pragma newdecls required

static char IdleAnim[MAXENTITIES][32];
static char TalkAnim[MAXENTITIES][32];
static char LeaveAnim[MAXENTITIES][32];
static int NPCIndex;

void NPCActor_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_actor");
	data.Func = ClotSummon;
	NPCIndex = NPC_Add(data);
}

int NPCActor_ID()
{
	return NPCIndex;
}

static any ClotSummon(int client, const float vecPos[3], const float vecAng[3], int team, const char[] data)
{
	return NPCActor(client, vecPos, vecAng, Actor_KV());
}

methodmap NPCActor < CClotBody
{
	public void AddGesture(const char[] name, bool cancel_animation = true)
	{
		if(name[0])
		{

		}
		else if(StrContains(name, "ACT") == 0)
		{
			view_as<CClotBody>(this).AddGesture(name, cancel_animation);
		}
		else
		{
			view_as<CClotBody>(this).AddGestureViaSequence(name);
		}
	}
	public void SetActivity(const char[] name)
	{
		if(name[0])
			view_as<CClotBody>(this).SetActivity(name, StrContains(name, "ACT") != 0);
	}
	public NPCActor(int client, const float vecPos[3], const float vecAng[3], KeyValues kv)
	{
		if(!kv)
			return view_as<NPCActor>(-1);
		
		char buffer1[PLATFORM_MAX_PATH], buffer2[16], buffer3[16];
		kv.GetString("model", buffer1, sizeof(buffer1), COMBINE_CUSTOM_MODEL);
		kv.GetString("scale", buffer2, sizeof(buffer2), "1.0");
		kv.GetString("health", buffer3, sizeof(buffer3), "300");

		NPCActor npc = view_as<NPCActor>(CClotBody(vecPos, vecAng, buffer1, buffer2, buffer3, TFTeam_Red, true, .Ally_Collideeachother = true));
		
		kv.GetSectionName(c_NpcName[npc.index], sizeof(c_NpcName[]));

		kv.GetString("anim_idle", IdleAnim[npc.index], sizeof(IdleAnim[]));
		npc.SetActivity(IdleAnim[npc.index]);
		
		kv.GetString("anim_walk", c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]));
		kv.GetString("anim_talk", TalkAnim[npc.index], sizeof(TalkAnim[]));
		kv.GetString("anim_leave", LeaveAnim[npc.index], sizeof(LeaveAnim[]));

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.m_flAttackHappens = kv.GetFloat("walk_delay");
		if(npc.m_flAttackHappens > 0.0)
		{
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + npc.m_flAttackHappens;
			npc.m_flAttackHappens_bullshit = kv.GetFloat("walk_range") / 2.0;
			npc.m_flSpeed = kv.GetFloat("walk_speed");
		}
		else
		{
			npc.m_flNextMeleeAttack = FAR_FUTURE;
			npc.m_flSpeed = 0.0;
		}
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = kv.GetNum("stepsound", STEPSOUND_NORMAL);	
		npc.m_iNpcStepVariation = kv.GetNum("steptype", STEPTYPE_NORMAL);
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NpcIsInvulnerable[npc.index] = true;
		npc.m_bisWalking = false;
		npc.Anger = false;
		b_DoNotUnStuck[npc.index] = true;
		int skin = kv.GetNum("skin");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		kv.GetString("wear1", buffer1, sizeof(buffer1));
		if(buffer1[0])
		{
			npc.m_iWearable1 = npc.EquipItem("head", buffer1, _, skin, kv.GetFloat("wear1_size", 1.0));
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", kv.GetNum("wear1_skin", 0));
		}

		kv.GetString("wear2", buffer1, sizeof(buffer1));
		if(buffer1[0])
		{
			npc.m_iWearable2 = npc.EquipItem("head", buffer1, _, skin, kv.GetFloat("wear2_size", 1.0));
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", kv.GetNum("wear2_skin", 0));
		}

		kv.GetString("wear3", buffer1, sizeof(buffer1));
		if(buffer1[0])
		{
			npc.m_iWearable3 = npc.EquipItem("head", buffer1, _, skin, kv.GetFloat("wear3_size", 1.0));
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", kv.GetNum("wear3_skin", 0));
		}

		SetVariantInt(kv.GetNum("bodygroup"));
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;

		return npc;
	}
}

void NPCActor_TalkStart(int iNPC, int client, float time = 60.0)
{
	NPCActor npc = view_as<NPCActor>(iNPC);
	npc.m_iTargetAlly = client;
	npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + time;

	if(TalkAnim[npc.index][0])
		npc.SetActivity(TalkAnim[npc.index]);
}

void NPCActor_TalkEnd(int iNPC)
{
	NPCActor npc = view_as<NPCActor>(iNPC);
	npc.m_iTargetAlly = -1;
	
	if(LeaveAnim[npc.index][0])
		npc.SetActivity(LeaveAnim[npc.index]);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextMeleeAttack < gameTime)
		npc.m_flNextMeleeAttack = gameTime + (npc.m_flAttackHappens * GetRandomFloat(0.85, 1.15));
}

static void ClotThink(int iNPC)
{
	NPCActor npc = view_as<NPCActor>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	//Give actors a way bigger delay, they arent important at all.
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	int target = npc.m_flGetClosestTargetTime > gameTime ? npc.m_iTargetAlly : 0;

	if(target > 0)
	{
		WorldSpaceCenter(target, f3_PositionArrival[npc.index]);
		npc.FaceTowards(f3_PositionArrival[npc.index], 1000.0);
	}
	else if(npc.m_flNextRangedAttack > gameTime)
	{
		npc.FaceTowards(f3_PositionArrival[npc.index], 1000.0);
	}
	else if(npc.m_flNextMeleeAttack < gameTime)
	{
		f3_PositionArrival[npc.index][0] = f3_SpawnPosition[npc.index][0];
		f3_PositionArrival[npc.index][1] = f3_SpawnPosition[npc.index][1];
		f3_PositionArrival[npc.index][2] = f3_SpawnPosition[npc.index][2];

		f3_PositionArrival[npc.index][0] += GetRandomFloat(-npc.m_flAttackHappens_bullshit, npc.m_flAttackHappens_bullshit);
		f3_PositionArrival[npc.index][1] += GetRandomFloat(-npc.m_flAttackHappens_bullshit, npc.m_flAttackHappens_bullshit);
		f3_PositionArrival[npc.index][2] += 40.0;
		
		Handle ToGroundTrace = TR_TraceRayFilterEx(f3_PositionArrival[npc.index], view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		TR_GetEndPosition(f3_PositionArrival[npc.index], ToGroundTrace);
		delete ToGroundTrace;
		f3_PositionArrival[npc.index][2] += 20.0;

		npc.m_bisWalking = true;
		npc.SetActivity(c_HeadPlaceAttachmentGibName[npc.index]);
		/*
		int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
		float Pos[3];
		Pos = f3_PositionArrival[npc.index];
		Pos[2] += 20.0;
		TE_SetupBeamPoints(f3_PositionArrival[npc.index], Pos, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
		TE_SendToAll();
		*/
		
		npc.StartPathing();
		npc.SetGoalVector(f3_PositionArrival[npc.index]);
	//	PrintToChatAll("npc.m_flSpeed %f",npc.m_flSpeed);

		npc.m_flNextMeleeAttack = gameTime + (npc.m_flAttackHappens * GetRandomFloat(0.85, 1.15));
	}
	else if(npc.m_bisWalking)
	{
		float pos[3];
		WorldSpaceCenter(npc.index, pos);
		if(GetVectorDistance(pos, f3_PositionArrival[npc.index], true) < 6500.0)
		{
			npc.m_bisWalking = false;
			npc.SetActivity(IdleAnim[npc.index]);
			npc.StopPathing();

			f3_PositionArrival[npc.index][0] += GetRandomFloat(-20.0, 20.0);
			f3_PositionArrival[npc.index][1] += GetRandomFloat(-20.0, 20.0);
			npc.m_flNextRangedAttack = gameTime + GetRandomFloat(0.5, 1.5);
		}
	}
}

static void ClotDeath(int entity)
{
	NPCActor npc = view_as<NPCActor>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


