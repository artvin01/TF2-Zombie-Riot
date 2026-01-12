#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

void Isharmla_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ishar'mla, Heart of Corruption");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_isharmla");
	strcopy(data.Icon, sizeof(data.Icon), "ds_isharmla");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Isharmla(vecPos, vecAng, team);
}

methodmap Isharmla < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public Isharmla(float vecPos[3], float vecAng[3], int ally)
	{
		Isharmla npc = view_as<Isharmla>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "90000", ally, false));
		// 90000 x 1.0

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 6;
		npc.SetActivity("ACT_SKADI_WALK");
		npc.m_bisWalking = true;
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = Isharmla_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Isharmla_OnTakeDamage;
		func_NPCThink[npc.index] = Isharmla_ClotThink;
		
		npc.m_flSpeed = 150.0;	// 0.6 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;
		i_TargetAlly[npc.index] = -1;
		npc.m_iPoints = 0;
		npc.m_bSpeed = false;

		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", FAR_FUTURE);	
		Is_a_Medic[npc.index] = true;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/workshop_partner/player/items/all_class/brutal_hair/brutal_hair_demo.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		
		SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 255, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.m_iWearable3, 100, 100, 255, 255);

		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSALPHA);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSALPHA);
		npc.m_bTeamGlowDefault = true;

		if(ally != TFTeam_Red)
		{
			if(!IsValidEntity(RaidBossActive))
			{
				RaidBossActive = EntIndexToEntRef(npc.index);
				RaidModeTime = GetGameTime() + 9000.0;
				RaidModeScaling = 0.0;
				RaidAllowsBuildings = true;
			}
		}

		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		vecMe[2] += 500.0;
		npc.m_iWearable2 = ParticleEffectAt(vecMe, "env_rain_512", -1.0);
		SetParent(npc.index, npc.m_iWearable2);


		return npc;
	}
	property int m_iPoints
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property bool m_bSpeed
	{
		public get()		{	return view_as<bool>(this.m_iMedkitAnnoyance);	}
		public set(bool value) 	{	this.m_iMedkitAnnoyance = value ? 1 : 0;	}
	}
}

public void Isharmla_ClotThink(int iNPC)
{
	Isharmla npc = view_as<Isharmla>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	if(i_TargetAlly[npc.index] == -1)
		npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	if(i_TargetAlly[npc.index] != -1)
	{
		if(IsValidEntity(i_TargetAlly[npc.index]))
			return;
		
		if(i_TargetAlly[npc.index] == RaidBossActive)
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}

		i_TargetAlly[npc.index] = -1;
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 255, 255);
		SetEntityRenderColor(npc.m_iWearable3, 100, 100, 255, 255);

		npc.SetActivity("ACT_SKADI_REVERT");
		npc.SetCycle(0.95);
		npc.SetPlaybackRate(-1.0);
		npc.m_bisWalking = false;
		npc.m_flNextThinkTime = gameTime + 1.25;
		npc.m_bTeamGlowDefault = true;
		b_IsEntityNeverTranmitted[npc.index] = false;
		GiveNpcOutLineLastOrBoss(npc.index, true);
		SetEntityCollisionGroup(npc.index, 9);
		SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 16);
		SetEntProp(npc.index, Prop_Data, "m_nSolidType", 2);
		i_RaidGrantExtra[npc.index] = -1;
		b_DoNotUnStuck[npc.index] = false;
		b_NoKnockbackFromSources[npc.index] = false;
		b_ThisEntityIgnored[npc.index] = false;
		
		// Recover 2% HP
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + (ReturnEntityMaxHealth(npc.index) / 50));
		return;
	}

	bool isRaid = RaidBossActive == EntIndexToEntRef(npc.index);

	// Passive +1 SP
	// Touching Nethersea +25 SP per 3 sec
	// First Anger +50 SP per 3 sec
	npc.m_iPoints += /*SeaFounder_TouchingNethersea(npc.index) ? ((GetURandomInt() % 2) ? 9 : 10) : */1;
	if(npc.m_bSpeed)
		npc.m_iPoints += ((GetURandomInt() % 2) ? 17 : 16);
	
	if(npc.m_iPoints > 99998)
	{
		if(isRaid)
			RaidModeScaling = 1.0;
		
		npc.m_iPoints = 0;
		npc.SetActivity("ACT_SKADI_WALK");
		npc.m_bisWalking = true;
		
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int maxhealth = ReturnEntityMaxHealth(npc.index) / 3;
		
		int entity = NPC_CreateByName("npc_isharmla_trans", -1, pos, ang, GetTeam(npc.index));
		if(entity > MaxClients)
		{
			b_IsEntityNeverTranmitted[npc.index] = true;
			npc.m_bTeamGlowDefault = true;
			GiveNpcOutLineLastOrBoss(npc.index, false);
			npc.m_bTeamGlowDefault = false;
			
			SetEntityCollisionGroup(npc.index, 1); //Dont Touch Anything.
			SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12); 
			SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6);
			i_RaidGrantExtra[npc.index] = -1;
			b_DoNotUnStuck[npc.index] = true;
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			view_as<CClotBody>(entity).m_bThisNpcIsABoss = npc.m_bThisNpcIsABoss;
			view_as<CClotBody>(entity).Anger = npc.Anger;

			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(entity, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", maxhealth);
			
			fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
			
			if(isRaid)
				RaidBossActive = EntIndexToEntRef(entity);
			
			npc.m_bSpeed = false;
			i_TargetAlly[npc.index] = EntIndexToEntRef(entity);
			b_NpcIsInvulnerable[npc.index] = true;
			SetEntityRenderColor(npc.index, 255, 255, 255, 1);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
			SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 1);
			return;
		}
	}
	else if(npc.m_iPoints > 1200)
	{
		npc.m_iPoints = 99999;
		npc.SetActivity("ACT_SKADI_TRANSFORM");
		npc.SetCycle(0.05);
		npc.m_bisWalking = false;
		npc.m_flNextThinkTime = gameTime + 1.25;

		npc.m_iTarget = 0;
		npc.StopPathing();
		return;
	}
	else if(isRaid)
	{
		RaidModeScaling = float(npc.m_iPoints) / 1200.0;
	}
	
	b_NpcIsInvulnerable[npc.index] = false;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidAlly(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;

	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestAlly(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 6.0;

		if(npc.m_iTarget < 1)
			npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	if(npc.m_iTarget > 0)
	{
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				npc.PlayMeleeSound();
				
				float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

				if(IsValidAlly(npc.index, npc.m_iTarget))
				{
					float vecAlly[3]; WorldSpaceCenter(npc.m_iTarget, vecAlly);

					int healing = npc.Anger ? 24000 : 16000;

					if(!HasSpecificBuff(npc.m_iTarget, "Growth Blocker"))
						healing -= 16000;
					
					if(healing > 0)
					{
						int maxhealth = GetEntProp(npc.m_iTarget, Prop_Data, "m_iMaxHealth");
						int health = GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") + healing;
						if(health > maxhealth)
							health = maxhealth;
						
						SetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth", health);
					}

					spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
					spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
					spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, vecAlly, vecMe);
					
					GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", vecAlly);

					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 60.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);

					NPCStats_RemoveAllDebuffs(npc.m_iTarget);
					ApplyStatusEffect(npc.index, npc.m_iTarget, "Godly Motivation", 7.0);
				}
				
				int ally = GetClosestAlly(npc.index, _, npc.m_iTarget);
				if(ally > 0)
				{
					float vecAlly[3]; WorldSpaceCenter(ally, vecAlly);

					int healing = npc.Anger ? 24000 : 16000;

					if(HasSpecificBuff(npc.m_iTarget, "Growth Blocker"))
						healing -= 16000;
					
					if(healing > 0)
					{
						int maxhealth = ReturnEntityMaxHealth(ally);
						int health = GetEntProp(ally, Prop_Data, "m_iHealth") + healing;
						if(health > maxhealth)
							health = maxhealth;
						
						SetEntProp(ally, Prop_Data, "m_iHealth", health);
					}

					spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
					spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
					spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, vecAlly, vecMe);
					
					GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", vecAlly);
					
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 60.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
					spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);

					NPCStats_RemoveAllDebuffs(ally);
					ApplyStatusEffect(npc.index, ally, "Godly Motivation", 7.0);
				}
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_flNextMeleeAttack = gameTime + 6.0;

			npc.AddGesture("ACT_SKADI_ATTACK");
			npc.m_flAttackHappens = gameTime + 1.25;
			npc.m_flDoingAnimation = gameTime + 1.75;
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
			npc.SetActivity("ACT_SKADI_WALK");
			npc.m_bisWalking = true;
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
			npc.StartPathing();
			npc.SetActivity("ACT_SKADI_WALK");
			npc.m_bisWalking = true;
		}
	}
	else
	{
		npc.StopPathing();
		npc.SetActivity("ACT_SKADI_WALK");
		npc.m_bisWalking = true;
	}
}

void Isharmla_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Isharmla npc = view_as<Isharmla>(victim);

	if(attacker < 1)
		return;

	if(b_NpcIsInvulnerable[npc.index])
	{
		damage = 0.0;
		return;
	}

	if(!npc.Anger)
	{
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < (ReturnEntityMaxHealth(npc.index) / 2))
		{
			npc.Anger = true;
			npc.m_bSpeed = true;
			SetEntityRenderColor(npc.index, 100, 100, 255, 200);
		}
	}
}

void Isharmla_NPCDeath(int entity)
{
	Isharmla npc = view_as<Isharmla>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}
