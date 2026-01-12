#pragma semicolon 1
#pragma newdecls required

#define IBERIA_LIGHTHOUSE_MODEL_1 "models/props_sunshine/lighthouse_blu_bottom.mdl"
#define IBERIA_LIGHTHOUSE_MODEL_2 "models/props_sunshine/lighthouse_top_skybox.mdl"

static const char g_DeathSounds[][] = {
	"ambient/explosions/explode_3.wav",
	"ambient/explosions/explode_4.wav",
	"ambient/explosions/explode_9.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/csgo_awp_shoot.wav",
};
static const char g_MeleeAttackShortSounds[][] = {
	"weapons/sniper_rifle_classic_shoot.wav",
};

int LighthouseID;

int LighthouseGlobaID()
{
	return LighthouseID;
}


void Iberia_Lighthouse_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackShortSounds)); i++) { PrecacheSound(g_MeleeAttackShortSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Iberia Lighthouse");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_iberia_lighthouse");
	strcopy(data.Icon, sizeof(data.Icon), "lighthouse_1");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	LighthouseID = NPC_Add(data);
	PrecacheModel(IBERIA_LIGHTHOUSE_MODEL_1);
	PrecacheModel(IBERIA_LIGHTHOUSE_MODEL_2);
}

static void ClotPrecache()
{
	NPC_GetByPlugin("npc_huirgrajo");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return IberiaLighthouse(vecPos, vecAng, team);
}
methodmap IberiaLighthouse < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.3);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSoundShort()
	{
		EmitSoundToAll(g_MeleeAttackShortSounds[GetRandomInt(0, sizeof(g_MeleeAttackShortSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}

	property float m_flLighthouseShortAttackHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flLighthouseShortAttackHappeningNext
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flLighthouseShortAttackHappeningAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flLighthouseDyingAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flNemalSummonSilvesterCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flLighthouseBuffEffect
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	public IberiaLighthouse(float vecPos[3], float vecAng[3], int ally)
	{
		IberiaLighthouse npc = view_as<IberiaLighthouse>(CClotBody(vecPos, vecAng, TOWER_MODEL, TOWER_SIZE, MinibossHealthScaling(100.0), ally, false,true,_,_,{30.0,30.0,200.0}, .NpcTypeLogic = 1));
		
		SetEntityRenderMode(npc.index, RENDER_NONE);
		i_NpcWeight[npc.index] = 999;
		b_NpcUnableToDie[npc.index] = true;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		npc.m_iWearable1 = npc.EquipItemSeperate(IBERIA_LIGHTHOUSE_MODEL_1);
		SetVariantString("0.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItemSeperate(IBERIA_LIGHTHOUSE_MODEL_2,_,_,_,170.0);
		SetVariantString("2.7");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;
		float wave = float(Waves_GetRoundScale()+1);
		
		wave *= 0.133333;
	
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		Is_a_Medic[npc.index] = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 200.0;
		i_NpcIsABuilding[npc.index] = true;
		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;
		b_thisNpcIsABoss[npc.index] = true;
		if(!IsValidEntity(RaidBossActive))
		{
			RaidModeScaling = 0.0;	//just a safety net
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
		}


		SetMoraleDoIberia(npc.index, 1.0);

		func_NPCDeath[npc.index] = view_as<Function>(IberiaLighthouse_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(IberiaLighthouse_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(IberiaLighthouse_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		npc.m_flNemalSummonSilvesterCD = GetGameTime() + 25.0;

		int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 1000.0, .NeedLOSPlayer = true);
		switch(Decicion)
		{
			case 2:
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0, .NeedLOSPlayer = true);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 250.0, .NeedLOSPlayer = true);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0, .NeedLOSPlayer = true);
						if(Decicion == 2)
						{
							//damn, cant find any.... guess we'll just not care about LOS.
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0);
						}
					}
				}
			}
			case 3:
			{
				//todo code on what to do if random teleport is disabled
			}
		}
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "Iberian Lighthouse Teleported in!");
			}
		}
		EmitSoundToAll("weapons/rescue_ranger_teleport_receive_01.wav", npc.index, SNDCHAN_STATIC, 120, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		EmitSoundToAll("weapons/rescue_ranger_teleport_receive_01.wav", npc.index, SNDCHAN_STATIC, 120, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		VecSelfNpcabs[2] += 200.0;
		Event event = CreateEvent("show_annotation");
		if(event)
		{
			event.SetFloat("worldPosX", VecSelfNpcabs[0]);
			event.SetFloat("worldPosY", VecSelfNpcabs[1]);
			event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
		//	event.SetInt("follow_entindex", 0);
			event.SetFloat("lifetime", 7.0);
		//	event.SetInt("visibilityBitfield", (1<<client));
			//event.SetBool("show_effect", effect);
			event.SetString("text", "Iberian Lighthouse!");
			event.SetString("play_sound", "vo/null.mp3");
			IdRef++;
			event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
			event.Fire();
		}
		VecSelfNpcabs[2] -= 200.0;
		TE_Particle("teleported_mvm_bot", VecSelfNpcabs, _, _, npc.index, 1, 0);
		return npc;
	}
}

public void IberiaLighthouse_ClotThink(int iNPC)
{
	IberiaLighthouse npc = view_as<IberiaLighthouse>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	if(npc.m_flLighthouseBuffEffect < GetGameTime(npc.index) && !npc.m_flLighthouseDyingAnim)
	{
		npc.m_flLighthouseBuffEffect = GetGameTime(npc.index) + 3.0;
		float ProjectileLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		ProjectileLoc[2] += 200.0;
		float range = 2000.0;
		spawnRing_Vectors(ProjectileLoc, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 200, 125, 100, 1, 10.0, 20.0, 1.0, 2, range * 2.0);	
	}
	if(npc.m_flNemalSummonSilvesterCD < GetGameTime(npc.index))
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int maxhealth;
		maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		maxhealth = (maxhealth / 6);
		npc.m_flNemalSummonSilvesterCD = FAR_FUTURE;
		int spawn_index = NPC_CreateByName("npc_huirgrajo", -1, pos, ang, GetTeam(npc.index));
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			CClotBody npc1 = view_as<CClotBody>(spawn_index);
			npc1.m_iTargetAlly = npc.index;
			b_thisNpcIsABoss[spawn_index] = true;
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.05;
	if(npc.m_flLighthouseDyingAnim)
	{
		float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		pos[0] += GetRandomFloat(-30.0,30.0);
		pos[1] += GetRandomFloat(-30.0,30.0);
		pos[2] += GetRandomFloat(15.0,180.0);
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(pos[0]);
		pack_boom.WriteFloat(pos[1]);
		pack_boom.WriteFloat(pos[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		npc.PlayDeathSound();
		if(npc.m_flLighthouseDyingAnim < GetGameTime(npc.index))
		{
			for(int LoopExplode; LoopExplode <= 10; LoopExplode++)
			{
				float pos1[3];
				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos1);
				pos1[0] += GetRandomFloat(-30.0,30.0);
				pos1[1] += GetRandomFloat(-30.0,30.0);
				pos1[2] += GetRandomFloat(15.0,180.0);
				DataPack pack_boom1 = new DataPack();
				pack_boom1.WriteFloat(pos1[0]);
				pack_boom1.WriteFloat(pos1[1]);
				pack_boom1.WriteFloat(pos1[2]);
				pack_boom1.WriteCell(0);
				RequestFrame(MakeExplosionFrameLater, pack_boom1);
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				func_NPCThink[npc.index] = INVALID_FUNCTION;
			}
			for(int LoopExplode; LoopExplode <= 2; LoopExplode++)
			{
				npc.PlayDeathSound();
			}
		}
		return;
	}
	if(!IsValidEntity(RaidBossActive))
	{
		RaidModeScaling = 0.0;	//just a safety net
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidModeTime = GetGameTime(npc.index) + 9000.0;
		RaidAllowsBuildings = true;
	}
	//global range.
	npc.m_flNextRangedSpecialAttack = 0.0;
	IberiaMoraleGivingDo(npc.index, GetGameTime(npc.index), false, 9999.0);
	IberiaLighthouseCloseDefense(npc, GetGameTime(npc.index));
	IberiaLighthouseDefense(npc, GetGameTime(npc.index));
}

public Action IberiaLighthouse_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	IberiaLighthouse npc = view_as<IberiaLighthouse>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(((ReturnEntityMaxHealth(npc.index) * 3)/4) >= (GetEntProp(npc.index, Prop_Data, "m_iHealth") - damage)) //npc.Anger after half hp/400 hp
	{
		if(npc.m_flNemalSummonSilvesterCD != FAR_FUTURE)
			npc.m_flNemalSummonSilvesterCD = 0.0;
	}
	if(!npc.m_flLighthouseDyingAnim && RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //npc.Anger after half hp/400 hp
	{
		if(RaidBossActive == EntIndexToEntRef(npc.index))
			RaidBossActive = INVALID_ENT_REFERENCE;

		npc.m_flLighthouseDyingAnim = GetGameTime(npc.index) + 3.0;
	}
	
	return Plugin_Changed;
}

public void IberiaLighthouse_NPCDeath(int entity)
{
	IberiaLighthouse npc = view_as<IberiaLighthouse>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}



int IberiaLighthouseDefense(IberiaLighthouse npc, float gameTime)
{
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,npc.m_iTargetWalkTo,_,true,_,_,true);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,npc.m_iTargetWalkTo,_,true,_,_,true);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
			{
				return 0;
			}		
		}
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			return 0;
		}
	}

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", origin);
	origin[2] += 200.0;
	if(npc.m_flNextRangedBarrage_Spam > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 10.0, 10.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
			
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			//re-Adjust hits and target 
			TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 10.0, 10.0, 0, 0.0, {255,255,255,255}, 3);
			TE_SendToAll(0.0);

			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
			
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayMeleeSound();
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 210.0 * npc.m_flWaveScale;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 5.5;

				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				ApplyStatusEffect(npc.index, target, "Marked", 10.0);
			} 
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.m_flAttackHappens = gameTime + 1.25;
		npc.m_flNextRangedBarrage_Spam = gameTime + 0.95;
		npc.m_flNextMeleeAttack = gameTime + 2.5;
	}
	return 1;
}

int IberiaLighthouseCloseDefense(IberiaLighthouse npc, float gameTime)
{
	float DistanceCheckMax = (NORMAL_ENEMY_MELEE_RANGE_FLOAT * 4.0);
	
	if(!npc.m_flLighthouseShortAttackHappening)
	{
		if(IsValidEnemy(npc.index,npc.m_iTargetWalkTo))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo))
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index,_,DistanceCheckMax,_,_,_,_,true,_,_,true);
			}
		}
		else
		{
			npc.m_iTargetWalkTo = GetClosestTarget(npc.index,_,DistanceCheckMax,_,_,_,_,true,_,_,true);
			if(!IsValidEnemy(npc.index,npc.m_iTargetWalkTo))
			{
				npc.m_iTargetWalkTo = 0;
				return 0;
			}		
		}
		if(!IsValidEnemy(npc.index,npc.m_iTargetWalkTo))
		{
			npc.m_iTargetWalkTo = 0;
			return 0;
		}
	}

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3];
	
	WorldSpaceCenter(npc.index, origin);
	if(npc.m_flLighthouseShortAttackHappeningAnim > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo))
		{
			WorldSpaceCenter(npc.m_iTargetWalkTo, ThrowPos[npc.index]);
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	else
	{	
		if(npc.m_flLighthouseShortAttackHappening)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flLighthouseShortAttackHappening)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 4.0, 4.0, 0, 0.0, {50,50,125,255}, 3);
		TE_SendToAll(0.0);
	}
			
	if(npc.m_flLighthouseShortAttackHappening)
	{
		if(npc.m_flLighthouseShortAttackHappening < gameTime)
		{
			npc.m_flLighthouseShortAttackHappening = 0.0;
			TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 4.0, 4.0, 0, 0.0, {255,255,255,255}, 3);
			TE_SendToAll(0.0);
			npc.PlayMeleeSoundShort();
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 25.0 * npc.m_flWaveScale;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 5.5;

				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				ApplyStatusEffect(npc.index, target, "Marked", 1.0);
			} 
			npc.m_iTargetWalkTo = 0;
		}
	}

	if(gameTime > npc.m_flLighthouseShortAttackHappeningNext)
	{
		npc.m_flLighthouseShortAttackHappening = gameTime + 0.1;
		npc.m_flLighthouseShortAttackHappeningAnim = gameTime + 0.1;
		npc.m_flLighthouseShortAttackHappeningNext = gameTime + 0.2;
	}
	return 1;
}