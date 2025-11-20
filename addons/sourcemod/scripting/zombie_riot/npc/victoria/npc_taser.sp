#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_jeers01.mp3",
	"vo/spy_jeers02.mp3",
	"vo/spy_jeers03.mp3",
	"vo/spy_jeers04.mp3",
	"vo/spy_jeers05.mp3",
	"vo/spy_jeers06.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_helpmedefend01.mp3",
	"vo/spy_helpmedefend02.mp3",
	"vo/spy_helpmedefend03.mp3"
};

static const char g_ReloadSound[] = "weapons/ar2/npc_ar2_reload.wav";

static const char g_RangeAttackSounds[] = "weapons/capper_shoot.wav";

void VictoriaTaser_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Taser");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_taser");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_taser");
	data.IconCustom = true;
	data.Flags = 0;
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
	PrecacheSound(g_ReloadSound);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/spy.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaTaser(vecPos, vecAng, ally, data);
}

methodmap VictoriaTaser < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, 60, _, 0.5, 80);
	}
	
	property float m_flCustomProjectileSpeed
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flCustomSlowDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flCustomDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}

	public VictoriaTaser(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaTaser npc = view_as<VictoriaTaser>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = VictoriaTaser_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaTaser_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaTaser_ClotThink;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "short_circuit");
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flSpeed = 310.0;
		
		npc.m_iMaxAmmo = 1;
		npc.m_flCustomProjectileSpeed = 600.0;
		npc.m_flCustomSlowDown = 0.8;
		npc.m_flCustomDuration = 1.0;
		
		npc.m_flSpeed = 310.0;
		npc.m_flSpeed = 310.0;
		npc.m_flSpeed = 310.0;
		
		npc.StartPathing();
		
		//Maybe used for special waves
		static char countext[5][512];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "speed") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "speed", "");
				npc.m_flCustomProjectileSpeed = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "slowdown") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "slowdown", "");
				npc.m_flCustomSlowDown = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "duration") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "duration", "");
				npc.m_flCustomDuration = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "maxclip") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "maxclip", "");
				npc.m_iMaxAmmo = StringToInt(countext[i]);
			}
		}
		npc.m_iAmmo = npc.m_iMaxAmmo;
		
		ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/scout/hwn2015_death_racer_helmet/hwn2015_death_racer_helmet.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_spy.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/sum20_smoking_jacket/sum20_smoking_jacket.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 255, 215, 0, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 50, 150, 150, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable3, 80, 50, 50, 255);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		return npc;
	}
}

static void VictoriaTaser_ClotThink(int iNPC)
{
	VictoriaTaser npc = view_as<VictoriaTaser>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index))
	{
		return;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VictoriaTaserSelfDefense(npc, GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 310.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictoriaTaser_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaTaser npc = view_as<VictoriaTaser>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void VictoriaTaser_NPCDeath(int entity)
{
	VictoriaTaser npc = view_as<VictoriaTaser>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
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

static int VictoriaTaserSelfDefense(VictoriaTaser npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens || !npc.m_iAmmo)
	{
		if(!npc.m_flAttackHappens)
		{
			npc.m_flAttackHappens=gameTime+(NpcStats_VictorianCallToArms(npc.index) ? 1.5 : 2.0);
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true);
			npc.PlayReloadSound();
			
		}
		if(gameTime > npc.m_flAttackHappens)
		{
			npc.m_iAmmo=npc.m_iMaxAmmo;
			npc.m_flAttackHappens=0.0;
		}
		return 1;
	}
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(gameTime > npc.m_flNextRangedAttack && IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", true);
			npc.PlayRangeSound();
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			float projectile_speed = npc.m_flCustomProjectileSpeed;
			
			int projectile = npc.FireParticleRocket(vecTarget, 75.0 , projectile_speed, 100.0 , "raygun_projectile_blue_crit");
			SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
			SDKHook(projectile, SDKHook_StartTouch, VictoriaTaser_Rocket_Particle_StartTouch);

			npc.m_flNextRangedAttack=gameTime+(NpcStats_VictorianCallToArms(npc.index) ? 0.75 : 1.0);
			npc.m_iAmmo--;
			return 1;
		}
	}
	return(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.0 && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) ? 1 : 0;
}

static void VictoriaTaser_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	
		if(!IsInvuln(target))
		{
			if(NpcStats_VictorianCallToArms(entity))
			{
				ApplyStatusEffect(owner, target, "Teslar Electricution", 4.0);
				if(!HasSpecificBuff(target, "Fluid Movement") && target <= MaxClients)
					TF2_StunPlayer(target, fl_AbilityOrAttack[owner][2], fl_AbilityOrAttack[owner][1], TF_STUNFLAG_SLOWDOWN);
			}
			else
			{
				ApplyStatusEffect(owner, target, "Teslar Electricution", 3.0);	
				if(!HasSpecificBuff(target, "Fluid Movement") && target <= MaxClients)
					TF2_StunPlayer(target, fl_AbilityOrAttack[owner][2], fl_AbilityOrAttack[owner][1], TF_STUNFLAG_SLOWDOWN);
			}
		}

		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}