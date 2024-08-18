#pragma semicolon 1
#pragma newdecls required

#define IBERIA_LIGHTHOUSE_MODEL_1 "models/props_sunshine/lighthouse_blu_bottom.mdl"
#define IBERIA_LIGHTHOUSE_MODEL_2 "models/props_sunshine/lighthouse_top_skybox.mdl"

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
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
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.Flags = -1;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	LighthouseID = NPC_Add(data);
	PrecacheModel(IBERIA_LIGHTHOUSE_MODEL_1);
	PrecacheModel(IBERIA_LIGHTHOUSE_MODEL_2);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return IberiaLighthouse(client, vecPos, vecAng, ally);
}
methodmap IberiaLighthouse < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	public IberiaLighthouse(int client, float vecPos[3], float vecAng[3], int ally)
	{
		IberiaLighthouse npc = view_as<IberiaLighthouse>(CClotBody(vecPos, vecAng, TOWER_MODEL, TOWER_SIZE, GetBuildingHealth(), ally, false,true,_,_,{30.0,30.0,200.0}));
		
		SetEntityRenderMode(npc.index, RENDER_NONE);
		i_NpcWeight[npc.index] = 999;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", IBERIA_LIGHTHOUSE_MODEL_1);
		SetVariantString("0.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItemSeperate("partyhat", IBERIA_LIGHTHOUSE_MODEL_2,_,_,_,170.0);
		SetVariantString("2.7");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;
		float wave = float(ZR_GetWaveCount()+1);
		
		wave *= 0.1;
	
		npc.m_flWaveScale = wave;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		Is_a_Medic[npc.index] = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;
		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;
		b_thisNpcIsABoss[npc.index] = true;


		SetMoraleDoIberia(npc.index, 1.0);

		func_NPCDeath[npc.index] = view_as<Function>(IberiaLighthouse_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(IberiaLighthouse_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(IberiaLighthouse_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		NPC_StopPathing(npc.index);

		int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 1000.0);
		switch(Decicion)
		{
			case 2:
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 1000.0, 750.0);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 500.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 500.0, 0.0);
					}
				}
			}
			case 3:
			{
				//todo code on what to do if random teleport is disabled
			}
		}
		for(int i; i < ZR_MAX_SPAWNERS; i++)
		{
			if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
			{
				Spawns_AddToArray(npc.index, true);
				i_ObjectsSpawners[i] = npc.index;
				break;
			}
		}

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
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.05;
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
	
	return Plugin_Changed;
}

public void IberiaLighthouse_NPCDeath(int entity)
{
	IberiaLighthouse npc = view_as<IberiaLighthouse>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, -1, pos, "", 0, 0);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}




static char[] GetBuildingHealth()
{
	int health = 220;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(ZR_GetWaveCount()+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.20));
	}
	else if(ZR_GetWaveCount()+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	
	
	health = RoundToCeil(float(health) * 1.2);
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
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
	float origin[3], angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", origin);
	origin[2] += 200.0;
	if(npc.m_flNextRangedBarrage_Spam > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
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
			/*
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			*/
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
			TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 10.0, 10.0, 0, 0.0, {255,255,255,255}, 3);
			TE_SendToAll(0.0);
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayMeleeSound();
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 12.0 * npc.m_flWaveScale;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 5.5;

				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				NpcStats_IberiaMarkEnemy(target, 10.0);
			} 
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.m_flAttackHappens = gameTime + 1.25;
		npc.m_flNextRangedBarrage_Spam = gameTime + 0.65;
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
	float origin[3], angles[3];
	
	WorldSpaceCenter(npc.index, origin);
	if(npc.m_flLighthouseShortAttackHappeningAnim > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo))
		{
			WorldSpaceCenter(npc.m_iTargetWalkTo, ThrowPos[npc.index]);
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
			int Traced_Target = TR_GetEntityIndex(hTrace);
			/*
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			*/
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
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayMeleeSoundShort();
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 3.0 * npc.m_flWaveScale;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 5.5;

				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				NpcStats_IberiaMarkEnemy(target, 1.0);
			} 
			npc.m_iTargetWalkTo = 0;
		}
	}

	if(gameTime > npc.m_flLighthouseShortAttackHappeningNext)
	{
		npc.m_flLighthouseShortAttackHappening = gameTime + 0.15;
		npc.m_flLighthouseShortAttackHappeningAnim = gameTime + 0.1;
		npc.m_flLighthouseShortAttackHappeningNext = gameTime + 0.2;
	}
	return 1;
}