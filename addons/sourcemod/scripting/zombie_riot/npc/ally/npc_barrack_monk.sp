#pragma semicolon 1
#pragma newdecls required

static const char g_RangedAttackSounds[][] =
{
	"items/halloween/witch01.wav",
	"items/halloween/witch02.wav",
	"items/halloween/witch03.wav",
};

public void BarrackMonkOnMapStart()
{
	PrecacheSoundArray(g_RangedAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Monk");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_monk");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackMonk(client, vecPos, vecAng);
}

methodmap BarrackMonk < BarrackBody
{
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	property float m_flHealCheckCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flHealCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public BarrackMonk(int client, float vecPos[3], float vecAng[3])
	{
		BarrackMonk npc = view_as<BarrackMonk>(BarrackBody(client, vecPos, vecAng, "750",_,_,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "armageddon");
		
		npc.m_flHealCheckCD = 0.0;	// How often to check for who to heal
		npc.m_flHealCD = 0.0;	// How often the monk should heal
		npc.m_flNextMeleeAttack = 0.0;	//	Basic attack
		npc.m_flNextRangedAttack = 0.0;	//	Mass Hex
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackMonk_NPCDeath;
		func_NPCThink[npc.index] = BarrackMonk_ClotThink;
		npc.m_flSpeed = 175.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/pyro/pyro_pyromancers_mask.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		return npc;
	}
}

public void BarrackMonk_ClotThink(int iNPC)
{
	BarrackMonk npc = view_as<BarrackMonk>(iNPC);
	float GameTime = GetGameTime(npc.index);
	if(BarrackBody_ThinkStart(npc.index,GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		
		if(npc.m_flHealCheckCD < GameTime && npc.m_flHealCD < GameTime)
		{
			BarrackMonk_TryHealAlly(npc.index);
		}
		int PrimaryThreatIndex = npc.m_iTarget;
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 200000.0 && npc.m_flNextRangedAttack < GameTime)	// Need to be in range and cooldown of the Mass Hex has to be 0
			{
				//Target close enough to hit
				if(IsValidEnemy(npc.index, PrimaryThreatIndex))
				{	
					npc.AddGesture("ACT_MONK_ATTACK", false);
					npc.FaceTowards(vecTarget, 300000.0);
					npc.PlayRangedSound();
					
					float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
					int projectile = npc.FireRocket(vPredictedPos, Barracks_UnitExtraDamageCalc(npc.index, client, 1000.0, 1), 1300.0, "models/props_mvm/mvm_human_skull_collide.mdl",0.5, _, _,client);
					
					WandProjectile_ApplyFunctionToEntity(projectile, Monk_Rocket_Particle_StartTouch);
					Monk_CurseEffect(npc, 1, PrimaryThreatIndex);
					
					npc.m_flNextRangedAttack = GameTime + (30.0 * npc.BonusFireRate);
					npc.m_flNextMeleeAttack = GameTime + (5.0 * npc.BonusFireRate);
				}
			}
			if(flDistanceToTarget < 200000.0 && npc.m_flNextMeleeAttack < GameTime)	// Need to be in range and cooldown of the basic attack has to be 0
			{
				//Target close enough to hit
				if(IsValidEnemy(npc.index, PrimaryThreatIndex))
				{	
					npc.AddGesture("ACT_MONK_ATTACK", false);
					npc.FaceTowards(vecTarget, 300000.0);
					npc.PlayRangedSound();
					
					float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
					npc.FireRocket(vPredictedPos, Barracks_UnitExtraDamageCalc(npc.index, client, 1000.0, 1), 1300.0, "models/props_mvm/mvm_human_skull_collide.mdl",0.5, _, _,client);
					Monk_CurseEffect(npc, 2, PrimaryThreatIndex);
					
					ApplyStatusEffect(client, PrimaryThreatIndex, "Small Hex", 3.0);
					
					npc.m_flNextMeleeAttack = GameTime + (5.0 * npc.BonusFireRate);
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 175.0, "ACT_MONK_IDLE", "ACT_MONK_WALK", 90000.0);
	}
}

void BarrackMonk_NPCDeath(int entity)
{
	BarrackMonk npc = view_as<BarrackMonk>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackMonk_ClotThink);
}

public void Monk_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		int client = 0;

		if(owner > 0 && owner <= MaxClients)
		{
			client = owner;
		}
		else if(owner > MaxClients && IsValidEntity(owner))
		{
			BarrackMonk npc = view_as<BarrackMonk>(owner);
			client = GetClientOfUserId(npc.OwnerUserId);
		}

		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

		Explode_Logic_Custom(1000.0, client, entity, -1, ProjectileLoc, 450.0, 1.0, _, true, .FunctionToCallBeforeHit = Skull_Effect);
				
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}
static int Monk_GetOwnerClient(int projectile)	// Something i realized i unfortunately need if i want to be able to give "credit" to the player for applying the status effect and seeing what it does in chat, downside of having it aoe...
{
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");
	if(owner > 0 && owner <= MaxClients)
		return owner;

	if(owner > MaxClients && IsValidEntity(owner))
		return GetClientOfUserId(view_as<BarrackMonk>(owner).OwnerUserId);

	return 0;
}
static float Skull_Effect(int entity, int victim, float &damage, int weapon)
{
	int client = Monk_GetOwnerClient(entity);

	switch(GetRandomInt(1, 2))
	{
		case 1:
			ApplyStatusEffect(client, victim, "Weakening Hex", 10.0);
		case 2:
			ApplyStatusEffect(client, victim, "Vulnerability Hex", 10.0);
	}
	return 0.0;
}
public void BarrackMonk_TryHealAlly(int iNPC)
{
	if(iNPC <= 0 || iNPC >= MAXENTITIES)
		return;

	BarrackMonk npc = view_as<BarrackMonk>(iNPC);
	float GameTime = GetGameTime(iNPC);

	float npcPos[3];
	WorldSpaceCenter(iNPC, npcPos);

	for(int client = 1; client <= MaxClients; client++)	// Yes, this abomination of a code basically looks for a valid ally in 60.000 range and if they're below 60% hp they get healed (checks also for valid target, not dying etc)
	{
		if(!IsValidClient(client) || !IsPlayerAlive(client))
			continue;

		if(dieingstate[client] > 0)
			continue;
		if(b_NpcIsInvulnerable[client])
			continue;

		float clPos[3];
		WorldSpaceCenter(client, clPos);
		float dist = GetVectorDistance(npcPos, clPos, true);

		if(dist > 60000.0)
			continue;

		float curHealth = float(GetEntProp(client, Prop_Data, "m_iHealth"));
		float maxHealth = float(ReturnEntityMaxHealth(client));

		if(maxHealth <= 0.0)
			continue;

		float healthPct = (curHealth / maxHealth) * 100.0;

		if(healthPct > 60.0)
			continue;

		int owner = GetClientOfUserId(npc.OwnerUserId);
		float healAmount = maxHealth * 0.15;

		if (owner > 0 && (i_CurrentEquippedPerk[owner] & PERK_REGENE))	// 33% more healing if the owner of the monk has Regen perk
		{
			healAmount = maxHealth * 0.20;
		}

		HealEntityGlobal(iNPC, client, healAmount, 1.0, 0.5, 0);
		
		int BeamIndex = ConnectWithBeam(iNPC, client, 0, 255, 100, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");
		SetEntityRenderFx(BeamIndex, RENDERFX_FADE_SLOW);
		CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);

		int roll = GetRandomInt(1, 100);

		if (roll == 1)
		{
			ApplyStatusEffect(iNPC, client, "Depressed", 0.1);

			SetHudTextParams(-1.0, 0.75, 3.0, 255, 50, 50, 255);
			ShowHudText(client, -1, "An unfriendly Monk flipped you off!\nYou feel depressed despite the healing.");
		}
		else
		{
			SetHudTextParams(-1.0, 0.75, 3.0, 100, 255, 100, 255);
			ShowHudText(client, -1, "You have been healed by a friendly Monk");
		}

		npc.m_flHealCD = GameTime + 30.0;
		npc.m_flHealCheckCD = GameTime + 30.0;

		return;
	}

	npc.m_flHealCheckCD = GameTime + 2.0;
}
static void Monk_CurseEffect(BarrackMonk npc, int type, int target = -1)	// Had to be a little more creative with this one, otherwise the merasmus_zap ALWAYS went for the origin spot making it a bit weird and misleading
{
	float pos[3], ang[3], endPos[3];
	WorldSpaceCenter(npc.index, pos);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

	switch(type)
	{
		case 1:
			npc.DispatchParticleEffect(npc.index, "spell_cast_wheel_blue", pos, ang, pos, 0, PATTACH_ABSORIGIN_FOLLOW);
		case 2:
		{
			if(target > 0)
				WorldSpaceCenter(target, endPos);
			else
				endPos = pos;

			ShootLaser(npc.index, "merasmus_zap", pos, endPos);
		}
	}
}