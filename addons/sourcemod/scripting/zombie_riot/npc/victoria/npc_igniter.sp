#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] = {
	"vo/pyro_painsharp01.mp3",
	"vo/pyro_painsharp02.mp3",
	"vo/pyro_painsharp03.mp3",
	"vo/pyro_painsharp04.mp3",
	"vo/pyro_painsharp05.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/pyro_taunts01.mp3",
	"vo/taunts/pyro_taunts02.mp3",
	"vo/taunts/pyro_taunts03.mp3"
};

static const char g_DeathSounds[] = ")vo/pyro_negativevocalization01.mp3";

static const char g_RangeAttackSounds[] = "weapons/flaregun_shoot.wav";

void VictorianIgniter_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victorian Igniter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_igniter");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_igniter");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/pyro.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaIgniter(vecPos, vecAng, ally);
}

methodmap VictoriaIgniter < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public VictoriaIgniter(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaIgniter npc = view_as<VictoriaIgniter>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.35", "3500", ally, .isGiant = true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(5);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = VictoriaIgniter_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaIgniter_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaIgniter_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "flaregun");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 220.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/invasion_phobos_filter/invasion_phobos_filter.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum19_spawn_camper_jacket/sum19_spawn_camper_jacket.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum24_brand_loyalist/sum24_brand_loyalist_pyro.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

static void VictoriaIgniter_ClotThink(int iNPC)
{
	VictoriaIgniter npc = view_as<VictoriaIgniter>(iNPC);
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VictoriaIgniterSelfDefense(npc,GetGameTime(npc.index),flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_ITEM1");
					npc.m_flSpeed = 250.0;
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
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_MP_STAND_ITEM1");
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

static Action VictoriaIgniter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaIgniter npc = view_as<VictoriaIgniter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictoriaIgniter_NPCDeath(int entity)
{
	VictoriaIgniter npc = view_as<VictoriaIgniter>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static int VictoriaIgniterSelfDefense(VictoriaIgniter npc, float gameTime, float distance)
{
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
				{	
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.25;
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1", false);
					npc.PlayRangeSound();
					npc.FaceTowards(vecTarget, 20000.0);
					int projectile = npc.FireParticleRocket(vecTarget, 20.0, 1000.0, 200.0, "drg_cow_rockettrail_fire_charged_blue", true);
					SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
					int particle = EntRefToEntIndex(i_rocket_particle[projectile]);
					CreateTimer(8.0, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(8.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
					
					SDKHook(projectile, SDKHook_StartTouch, VictoriaIgniter_Rocket_Particle_StartTouch);
					return 1;
				}
			}
		}
	}
	return (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*10.0 && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) ? 1 : 0;
}

static void VictoriaIgniter_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)
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

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		
		if(NpcStats_VictorianCallToArms(owner))
		{
			NPC_Ignite(target, owner, 7.5, -1, 4.0);
		}
		else
		{
			NPC_Ignite(target, owner, 5.0, -1, 4.0);
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
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}