#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

#define ARISBEACON_BUILDUP_TIME 0.5

void ARISBeacon_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "A.R.I.S. Makeshift Beacon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aris_makeshift_beacon");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.Flags = -1;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	GlobalCooldownWarCry = 0.0;
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	
	PrecacheModel("models/pickups/pickup_powerup_defense.mdl");
	PrecacheModel("models/pickups/pickup_powerup_strength.mdl");
	PrecacheModel("models/pickups/pickup_powerup_agility.mdl");
	
	PrecacheParticleSystem("mvm_pow_gold_seq_wood3mid");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ARISBeacon(vecPos, vecAng, team, data);
}
methodmap ARISBeacon < CClotBody
{
	property int m_iType
	{
		public get()							{ return i_AnimationState[this.index]; }
		public set(int TempValueForProperty) 	{ i_AnimationState[this.index] = TempValueForProperty; }
	}
	
	property int m_iCharges
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	
	property float m_flFullyActiveTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flRadius
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public ARISBeacon(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ARISBeacon npc = view_as<ARISBeacon>(CClotBody(vecPos, vecAng, "models/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl", "2.0", MinibossHealthScaling(50.0, true), ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		npc.SetPlaybackRate(1.435);	
		Is_a_Medic[npc.index] = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_NoKillFeed[npc.index] = true;
		b_CantCollidie[npc.index] = true; 
		b_CantCollidieAlly[npc.index] = true; 
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		npc.m_bDissapearOnDeath = true;
		b_HideHealth[npc.index] = true;
		b_NoHealthbar[npc.index] = 1;


		//these are default settings! please redefine these when spawning!

		func_NPCDeath[npc.index] = view_as<Function>(ARISBeacon_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ARISBeacon_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ARISBeacon_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);
		
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_flFullyActiveTime = GetGameTime() + ARISBEACON_BUILDUP_TIME;
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		
		// We have to hide ourselves until we have our real model
		if (StrContains(buffers[0], "resistance") != -1)
			npc.m_iType = ARIS_MELEE_RESISTANCE;
		else if (StrContains(buffers[0], "damage") != -1)
			npc.m_iType = ARIS_MELEE_DAMAGE;
		else if (StrContains(buffers[0], "speed") != -1)
			npc.m_iType = ARIS_MELEE_SPEED;
		
		if (buffers[1][0])
		{
			int charges = StringToInt(buffers[1]);
			if (charges)
				npc.m_iCharges = charges;
		}
		
		if (npc.m_iCharges < 0)
			npc.m_iCharges = 0;
		
		float vecTargetPos[3];
		
		Handle trace = TR_TraceRayFilterEx(vecPos, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID, RayType_Infinite, TraceEntityFilter_ARISBeacon_OnlyWorld);
		TR_GetEndPosition(vecTargetPos, trace);
		delete trace;
		
		vecTargetPos[2] += 50.0;
		f3_NpcSavePos[npc.index] = vecTargetPos;
		npc.m_flRadius = 512.0 + (npc.m_iCharges * 32.0); // as of writing this comment, m_iCharges is unused by ARIS, but it'll still be left there
		b_NpcUnableToDie[npc.index] = true;
		
		char model[128], powerup[128];
		int color[4];
		
		switch (npc.m_iType)
		{
			case ARIS_MELEE_RESISTANCE:
			{
				model = "models/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl";
				color = { 125, 125, 255, 200 };
				powerup = "models/pickups/pickup_powerup_defense.mdl";
			}
			case ARIS_MELEE_DAMAGE:
			{
				model = "models/workshop/weapons/c_models/c_rr_crossing_sign/c_rr_crossing_sign.mdl";
				color = { 255, 125, 125, 200 };
				powerup = "models/pickups/pickup_powerup_strength.mdl";
			}
			case ARIS_MELEE_SPEED:
			{
				model = "models/weapons/c_models/c_picket/c_picket.mdl";
				color = { 125, 255, 125, 200 };
				powerup = "models/pickups/pickup_powerup_agility.mdl";
			}
		}
		
		if (model[0])
			SetEntityModel(npc.index, model);
		
		spawnRing_Vectors(vecTargetPos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, /*duration*/ ARISBEACON_BUILDUP_TIME + 0.05, 7.0, 2.0, 1, npc.m_flRadius * 2.0);
		
		npc.m_iWearable1 = npc.EquipItemSeperate(powerup, "spin", 2, _, 200.0);
		
		return npc;
	}
}

public void ARISBeacon_ClotThink(int iNPC)
{
	ARISBeacon npc = view_as<ARISBeacon>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
	}
	//Need to check this often sadly.
	if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
	{
		//there is no more valid ally, suicide.
		b_NpcUnableToDie[npc.index] = false;
		SmiteNpcToDeath(npc.index);
		return;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	if (npc.m_flFullyActiveTime >= gameTime)
	{
		npc.m_flNextThinkTime = gameTime + 0.1;
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.5;
	
	int color[4];
		
	switch (npc.m_iType)
	{
		case ARIS_MELEE_RESISTANCE: color = { 125, 125, 255, 200 };
		case ARIS_MELEE_DAMAGE: color = { 255, 125, 125, 200 };
		case ARIS_MELEE_SPEED: color = { 125, 255, 125, 200 };
	}
	
	spawnRing_Vectors(f3_NpcSavePos[npc.index], npc.m_flRadius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, /*duration*/ 0.6, 7.0, 2.0, 1);
	ExpidonsaGroupHeal(npc.index, npc.m_flRadius, 10, 0.0, 1.0, false, ARISBeacon_GiveArmor, .LOS = false);
}


void ARISBeacon_GiveArmor(int entity, int victim, float &healingammount)
{
	if(i_NpcIsABuilding[victim])
		return;
	ARISBeacon npc = view_as<ARISBeacon>(entity);
	switch (npc.m_iType)
	{
		case ARIS_MELEE_RESISTANCE: ApplyStatusEffect(entity, victim, "A.R.I.S. ARMOR MODE", 0.6);
		case ARIS_MELEE_DAMAGE: ApplyStatusEffect(entity, victim, "A.R.I.S. DAMAGE MODE", 0.6);
		case ARIS_MELEE_SPEED: ApplyStatusEffect(entity, victim, "A.R.I.S. SPEED MODE", 0.6);
	}
	
	int red = 100;
	int green = 255;
	int blue = 100;
	int Alpha = 125;

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	float diameter = 100.0;
	float vecPos[3];
	WorldSpaceCenter(entity, vecPos);
	float vecAlly[3];
	WorldSpaceCenter(victim, vecAlly);
	TE_SetupBeamPoints(vecPos, vecAlly, Shared_BEAM_Laser, 0, 0, 0, 0.25, ClampBeamWidth(diameter * 0.9), ClampBeamWidth(diameter * 0.9), 0, 3.0, colorLayer1, 0);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(vecPos, vecAlly, Shared_BEAM_Laser, 0, 0, 0, 0.25, ClampBeamWidth(diameter * 0.7), ClampBeamWidth(diameter * 0.7), 0, 6.0, colorLayer4, 0);
	TE_SendToAll(0.0);
}

public Action ARISBeacon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;
	
	damage = 0.0;
	return Plugin_Stop;
}

public void ARISBeacon_NPCDeath(int entity)
{
	ARISBeacon npc = view_as<ARISBeacon>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	
	ParticleEffectAt(pos, "mvm_pow_gold_seq_wood3mid");
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static bool TraceEntityFilter_ARISBeacon_OnlyWorld(int entity, int mask)
{
	return entity == 0 || entity > MAXENTITIES;
}
