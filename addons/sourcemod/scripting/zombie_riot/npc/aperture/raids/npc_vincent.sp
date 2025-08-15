#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/soldier_mvm_standonthepoint01.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint02.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint03.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};

static const char g_OilModel[] = "models/props_farm/haypile001.mdl";

#define VINCENT_OIL_MODEL_DEFAULT_RADIUS 140.0
#define VINCENT_OIL_MODEL_SCALE 1.5

#define VINCENT_OIL_MODEL_OFFSET_Z -4.0

void Vincent_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	
	PrecacheSound("mvm/giant_heavy/giant_heavy_entrance.wav");
	
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	PrecacheModel(g_OilModel);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vincent");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vincent");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_robot_nys");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Vincent(vecPos, vecAng, ally, data);
}

methodmap Vincent < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}

	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property float m_flNextOilPouring
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property bool m_bDoingOilPouring
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
	}
	
	public Vincent(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Vincent npc = view_as<Vincent>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl" /*"models/bots/heavy/bot_heavy.mdl"*/, "1.50", "700", ally, false, true, true, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_LOSERSTATE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		func_NPCDeath[npc.index] = Vincent_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Vincent_OnTakeDamage;
		func_NPCThink[npc.index] = Vincent_ClotThink;

		EmitSoundToAll("mvm/giant_heavy/giant_heavy_entrance.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("mvm/giant_heavy/giant_heavy_entrance.wav", _, _, _, _, 1.0, 100);	
		
		RaidModeTime = GetGameTime(npc.index) + 160.0;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "Vincent arrives");
			}
		}
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		float amount_of_people = float(CountPlayersOnRed());
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.15;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/matrix/furiousangels.mp3");
		music.Time = 161;
		music.Volume = 1.7;
		music.Custom = false;
		strcopy(music.Name, sizeof(music.Name), "Furious Angels (Instrumental)");
		strcopy(music.Artist, sizeof(music.Artist), "Rob Dougan");
		Music_SetRaidMusic(music);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
		npc.m_flSpeed = 300.0;
		npc.m_flMeleeArmor = 1.0;
		
		npc.m_flNextOilPouring = GetGameTime(npc.index) + 3.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		Citizen_MiniBossSpawn();
		npc.StartPathing();
		
		// Make him invisible so we can use human heavy anims
		SetEntityRenderColor(npc.index, .a = 0);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		npc.m_iWearable1 = npc.EquipItem("head", "models/bots/heavy/bot_heavy.mdl", _, skin);

		return npc;
	}
	
	public void PourOilAbility(float duration, float delayToIgnite)
	{
		this.m_bDoingOilPouring = true;
		this.m_flNextOilPouring = GetGameTime(this.index) + delayToIgnite + 0.5;
		
		float vecPos[3], vecTargetPos[3], vecAng[3], vecNormal[3], vecForward[3];
		GetAbsOrigin(this.index, vecPos);
		
		float radius = VINCENT_OIL_MODEL_DEFAULT_RADIUS * VINCENT_OIL_MODEL_SCALE * 1.5;
		
		this.PourOil(vecPos, radius, duration, delayToIgnite, true);
		
		vecPos[2] += 3.0;
		
		float ringRadius = radius * 2.0;
		spawnRing_Vectors(vecPos, ringRadius, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 104, 207, 255, 255, 1, duration + delayToIgnite, 1.0, 0.1, 1);
		
		vecPos[2] += 77.0;
		
		for (int i = 0; i < 8; i++)
		{
			vecAng[1] = i * (360.0 / 8.0);
			GetAngleVectors(vecAng, vecForward, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(vecForward, vecForward);
			ScaleVector(vecForward, VINCENT_OIL_MODEL_DEFAULT_RADIUS * VINCENT_OIL_MODEL_SCALE);
			AddVectors(vecPos, vecForward, vecTargetPos);
			
			Handle trace = TR_TraceRayFilterEx(vecPos, vecTargetPos, MASK_SOLID, RayType_EndPoint, TraceEntityFilter_Vincent_OnlyWorld);
			if (!TR_DidHit(trace))
			{
				Handle trace2 = TR_TraceRayFilterEx(vecTargetPos, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID, RayType_Infinite, TraceEntityFilter_Vincent_OnlyWorld);
				TR_GetEndPosition(vecTargetPos, trace);
				delete trace2;
			}
			
			delete trace;
			
			vecTargetPos[2] -= 16.0;
			this.PourOil(vecTargetPos, radius, duration, delayToIgnite, false);
		}
	}
	
	public void PourOil(float vecPos[3], float radius, float duration, float delayToIgnite, bool think)
	{
		int prop = CreateEntityByName("prop_dynamic_override");
		if (!IsValidEntity(prop))
			return;
		
		Handle trace = TR_TraceRayFilterEx(vecPos, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID, RayType_Infinite, TraceEntityFilter_Vincent_OnlyWorld);
		TR_GetEndPosition(vecPos, trace);
		delete trace;
		
		TeleportEntity(prop, vecPos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(prop, "model", g_OilModel);
		DispatchKeyValue(prop, "disablereceiveshadows", "1");
		DispatchKeyValue(prop, "disableshadows", "1");
		DispatchSpawn(prop);
		
		SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", this.index);
		SetTeam(prop, GetTeam(this.index));
		SetEntPropFloat(prop, Prop_Send, "m_flModelScale", VINCENT_OIL_MODEL_SCALE);
		
		SetEntityCollisionGroup(prop, TFCOLLISION_GROUP_ROCKETS);
		SetEntityRenderColor(prop, 0, 0, 0, 255);
		
		DataPack pack;
		CreateDataTimer(delayToIgnite, Timer_Vincent_IgniteOil, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(prop));
		pack.WriteCell(this.index);
		pack.WriteFloat(radius);
		
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Vincent_ClotThink(int iNPC)
{
	Vincent npc = view_as<Vincent>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(Vincent_LoseConditions(iNPC))
		return;

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
		
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_bDoingOilPouring)
	{
		if (npc.m_flNextOilPouring < gameTime)
		{
			npc.m_bDoingOilPouring = false;
			npc.m_flNextOilPouring = gameTime + 15.0;
			npc.StartPathing();
		}
		else
		{
			return;
		}
	}
	
	if (npc.m_flNextOilPouring < gameTime)
	{
		npc.StopPathing();
		npc.PourOilAbility(30.0, 2.0);
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target))
	{
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(npc.index, vecPos);
		WorldSpaceCenter(target, vecTargetPos);
		
		float distance = GetVectorDistance(vecPos, vecTargetPos, true);
	
		// Predict their pos when not loading our gun
		if (distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(target);
		}
		
		Vincent_SelfDefense(npc, gameTime, target, distance);
	}
	else
	{
		//no valid target, do stuff.
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void Vincent_SelfDefense(Vincent npc, float gameTime, int target, float distance)
{
	if (npc.m_flAttackHappens && npc.m_flAttackHappens < GetGameTime(npc.index))
	{
		npc.m_flAttackHappens = 0.0;
		
		if(IsValidEnemy(npc.index, target))
		{
			int HowManyEnemeisAoeMelee = 64;
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
			delete swingTrace;
			bool PlaySound = false;
			float damage = 35.0;
			damage *= RaidModeScaling;
			bool silenced = NpcStats_IsEnemySilenced(npc.index);
			for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
			{
				if(i_EntitiesHitAoeSwing_NpcSwing[counter] <= 0)
					continue;
				if(!IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
					continue;

				int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
				float vecHit[3];
				
				WorldSpaceCenter(targetTrace, vecHit);

				SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);

				bool Knocked = false;
				if(!PlaySound)
				{
					PlaySound = true;
				}
				
				if(IsValidClient(targetTrace))
				{
					if (IsInvuln(targetTrace))
					{
						Knocked = true;
						Custom_Knockback(npc.index, targetTrace, 180.0, true);
						if(!silenced)
						{
							TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
						}
					}
					else
					{
						if(!silenced)
						{
							TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
						}
					}
				}			
				if(!Knocked)
					Custom_Knockback(npc.index, targetTrace, 450.0, true); 
			}
			if(PlaySound)
			{
				npc.PlayMeleeHitSound();
			}
		}
	}

	if (gameTime > npc.m_flNextMeleeAttack)
	{
		if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				npc.m_flAttackHappens = gameTime + 0.1;
				float attack = 1.0;
				npc.m_flNextMeleeAttack = gameTime + attack;
				return;
			}
		}
	}
}

public Action Vincent_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Vincent npc = view_as<Vincent>(victim);
	/*
	if (damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && Aperture_ShouldDoLastStand())
	{
		npc.m_iState = APERTURE_BOSS_VINCENT; // This will store the boss's "type"
		Aperture_Shared_LastStandSequence_Starting(view_as<CClotBody>(npc));
		
		damage = 0.0;
		return Plugin_Handled;
	}
	*/
	if (!npc.m_bLostHalfHealth && (ReturnEntityMaxHealth(npc.index) / 2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		npc.m_bLostHalfHealth = true;
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Vincent_NPCDeath(int entity)
{
	Vincent npc = view_as<Vincent>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

static bool Vincent_LoseConditions(int iNPC)
{
	Vincent npc = view_as<Vincent>(iNPC);
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{blue}C.A.T{default}: Intruders taken care of.");
		return true;
	}
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{blue}C.A.T{default}: We hope your stay at Aperture was pleasant!");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return true;
	}
	
	return false;
}

static bool TraceEntityFilter_Vincent_OnlyWorld(int entity, int mask)
{
	return entity == 0 || entity > MAXENTITIES;
}

static void Timer_Vincent_IgniteOil(Handle timer, DataPack pack)
{
	pack.Reset();
	int ref = pack.ReadCell();
	int entity = EntRefToEntIndex(ref);
	if (entity == INVALID_ENT_REFERENCE)
		return;
	
	int owner = pack.ReadCell();
	float radius = pack.ReadFloat();
	
	if (radius > 0.0)
	{
		DataPack pack2;
		CreateDataTimer(0.3, Timer_Vincent_OilBurning, pack2, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack2.WriteCell(ref);
		pack2.WriteCell(owner);
		pack2.WriteFloat(radius);
	}
	
	SetEntityRenderMode(entity, RENDER_NONE);
	IgniteTargetEffect(entity);
}

static Action Timer_Vincent_OilBurning(Handle timer, DataPack pack)
{
	pack.Reset();
	int ref = pack.ReadCell();
	int entity = EntRefToEntIndex(ref);
	if (entity == INVALID_ENT_REFERENCE)
		return Plugin_Stop;
	
	int owner = pack.ReadCell();
	float radius = pack.ReadFloat();
	
	float vecPos[3];
	GetAbsOrigin(entity, vecPos);
	
	DataPack pack2 = new DataPack();
	pack2.WriteCell(entity);
	pack2.WriteCell(owner); // TODO: RADIUS IS SLIGHTLY BIGGER THAN INTENDED / STREAMLINE RADIUS USAGE
	TR_EnumerateEntitiesSphere(vecPos, radius / 2.0, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_Vincent_Oil, pack2);
	
	delete pack2;
	//CBaseCombatCharacter(entity).SetNextThink(GetGameTime() + 0.1);
	
	return Plugin_Continue;
}

static bool TraceEntityEnumerator_Vincent_Oil(int entity, DataPack pack)
{
	if (entity <= 0 || entity > MAXENTITIES)
		return true;
	
	if (entity > MaxClients && !b_ThisWasAnNpc[entity])
		return true;
	
	if (GetTeam(entity) == 0)
		return true;
	
	pack.Reset();
	int self = pack.ReadCell();
	int owner = pack.ReadCell();
	// TODO: USE OWNER REF
	if (!IsValidEntity(owner))
		return true;
	
	if (entity == owner)
	{
		// do some stuff
	}
	
	if (!IsValidEnemy(entity, owner))
		return true;
	
	float vecPos[3], vecTargetPos[3];
	GetAbsOrigin(self, vecPos);
	GetAbsOrigin(entity, vecTargetPos);
	
	float difference = fabs(vecPos[2] - vecTargetPos[2]);
	if (difference > 150.0)
		return true;
	
	SDKHooks_TakeDamage(entity, owner, owner, 3.0, DMG_PLASMA, -1);
	//NPC_Ignite(entity, owner, 7.0, -1);
	return true;
}
/*
int CreateBonemerge(int iClient)
{
	int iProp = CreateEntityByName("tf_taunt_prop");
	
	int iTeam = GetTeam(iClient);
	SetEntProp(iProp, Prop_Data, "m_iInitialTeamNum", iTeam);
	SetEntProp(iProp, Prop_Send, "m_iTeamNum", iTeam);
	
	char sModel[PLATFORM_MAX_PATH];
	sModel = "models/bots/heavy/bot_heavy.mdl";
	GetEntPropString(iClient, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	SetEntityModel(iProp, sModel);
	
	// The entity has to be teleported to the client because, if it isn't,
	// the particle effect will fail to stop sometimes
	float vecClientOrigin[3];
	GetAbsOrigin(iClient, vecClientOrigin);
	TeleportEntity(iProp, vecClientOrigin);
	
	DispatchSpawn(iProp);
	SetEntPropEnt(iProp, Prop_Data, "m_hEffectEntity", iClient);
	SetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity", iClient);
	SetEntProp(iProp, Prop_Send, "m_fEffects", GetEntProp(iProp, Prop_Send, "m_fEffects")|EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW);
	
	SetVariantString("!activator");
	AcceptEntityInput(iProp, "SetParent", iClient);
	
	//SetEntityRenderMode(iProp, RENDER_NONE);
	
	return iProp;
}*/