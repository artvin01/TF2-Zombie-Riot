#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/soldier_negativevocalization01.mp3",
	")vo/soldier_negativevocalization02.mp3",
	")vo/soldier_negativevocalization03.mp3",
	")vo/soldier_negativevocalization04.mp3",
	")vo/soldier_negativevocalization05.mp3",
	")vo/soldier_negativevocalization06.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/compmode/cm_soldier_pregamefirst_02.mp3",
	"vo/compmode/cm_soldier_pregamefirst_01.mp3",
	"vo/compmode/cm_soldier_pregamefirst_04.mp3",
	"vo/compmode/cm_soldier_pregamefirst_05.mp3",
	"vo/compmode/cm_soldier_pregamefirst_07.mp3",
};

static const char g_hornsound[][] = {
	"weapons/battalions_backup_blue.wav",
	"weapons/buff_banner_horn_blue.wav",
};

void VictorianSignaller_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Signaller");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_signaller");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_signaller");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_hornsound);
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianSignaller(vecPos, vecAng, ally);
}

methodmap VictorianSignaller < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayHornSound() 
	{
		EmitSoundToAll(g_hornsound[GetRandomInt(0, sizeof(g_hornsound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL , _, 0.5, GetRandomInt(80,110));
	}
	
	property float m_flChangeMovement
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_fXPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_fZPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_fYPosSave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public void SaveTreePos(float VecTarget[3])
	{
		this.m_fXPosSave=VecTarget[0];
		this.m_fZPosSave=VecTarget[1];
		this.m_fYPosSave=VecTarget[2];
	}
	public void LoadTreePos(float VecTarget[3])
	{
		VecTarget[0]=this.m_fXPosSave;
		VecTarget[1]=this.m_fZPosSave;
		VecTarget[2]=this.m_fYPosSave;
	}
	
	public VictorianSignaller(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianSignaller npc = view_as<VictorianSignaller>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "6000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		func_NPCDeath[npc.index] = VictorianSignaller_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianSignaller_ClotThink;
		
		Is_a_Medic[npc.index] = true;
		npc.m_flSpeed = 200.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flChangeMovement = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		
		npc.m_iWearable7 = ParticleEffectAt_Parent(vecPos, "utaunt_aestheticlogo_teamcolor_blue", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/soldier/hardhat_tower.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec23_trench_warefarer/dec23_trench_warefarer.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2021_goalkeeper_style2/hwn2021_goalkeeper_style2_soldier.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable6, 0, 0, 0, 255);

		npc.StartPathing();
		return npc;
	}
}

static void VictorianSignaller_ClotThink(int iNPC)
{
	VictorianSignaller npc = view_as<VictorianSignaller>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(npc.m_iTargetAlly < 1)
		{
			LastHitRef[npc.index] = -1;
			SmiteNpcToDeath(npc.index);
			return;
		}
		npc.m_flGetClosestTargetTime = gameTime + 1.0;	
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
		npc.PlayHornSound();
		npc.m_flNextMeleeAttack = gameTime + 7.50;
	}

	int team = GetTeam(npc.index);
	if(team == 2)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsEntityAlive(client))
			{
				ApplyStatusEffect(npc.index, client, "Call To Victoria", 2.0);
			}
		}
	}
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == team)
			{
				ApplyStatusEffect(npc.index, entity, "Call To Victoria", 0.5);
			}
		}
	}
	if(npc.m_iTargetAlly > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VictorianSignaller_Work(npc, gameTime, flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_flSpeed = 200.0;
					npc.m_iChanged_WalkCycle = 0;
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTargetAlly);
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.StopPathing();
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 1;
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_flSpeed = 200.0;
					npc.m_iChanged_WalkCycle = 2;
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3];
					npc.LoadTreePos(vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTargetAlly);
			}
		}
	}
	npc.PlayIdleSound();
}

static void VictorianSignaller_NPCDeath(int entity)
{
	VictorianSignaller npc = view_as<VictorianSignaller>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
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

static int VictorianSignaller_Work(VictorianSignaller npc, float gameTime, float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7)
	{
		if(gameTime > npc.m_flChangeMovement)
		{
			npc.m_flChangeMovement=gameTime+GetRandomFloat(3.0, 4.0);
			float RNGPos[3];
			VictoriaSignaller_Move(npc, 200.0, 800.0, RNGPos);
			npc.SaveTreePos(RNGPos);
		}
		return (gameTime > npc.m_flChangeMovement-2.0) ? 1 : 2;
	}
	return 0;
}

static void VictoriaSignaller_Move(VictorianSignaller npc, float min, float max, float output[3])
{
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
	for(int loop = 1; loop <= 500; loop++)
	{
		CNavArea RandomArea = GetRandomNearbyArea(vecTarget, max);
		if(RandomArea == NULL_AREA)
			break;
		int NavAttribs = RandomArea.GetAttributes();
		if(NavAttribs & NAV_MESH_AVOID)
			continue;
		float vPredictedPos[3]; RandomArea.GetCenter(vPredictedPos);
		vPredictedPos[2] += 1.0;
		
		if(GetVectorDistance(vPredictedPos, vecTarget, true) < (min * min))
			continue;
		
		if(IsPointHazard(vPredictedPos))
			continue;
		if(IsPointHazard(vPredictedPos))
			continue;
			
		static float hullcheckmaxs_Player_Again[3];
		static float hullcheckmins_Player_Again[3];
		
		hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );	
		
		if(IsPointHazard(vPredictedPos))
			continue;
		
		vPredictedPos[2] += 18.0;
		if(IsPointHazard(vPredictedPos))
			continue;
		
		vPredictedPos[2] -= 18.0;
		vPredictedPos[2] -= 18.0;
		vPredictedPos[2] -= 18.0;
		if(IsPointHazard(vPredictedPos))
			continue;
		vPredictedPos[2] += 18.0;
		vPredictedPos[2] += 18.0;
		
		if(IsSpaceOccupiedIgnorePlayers(vPredictedPos, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(vPredictedPos, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
			continue;
		
		if(vPredictedPos[0])
		{
			output=vPredictedPos;
			break;
		}
	}
}