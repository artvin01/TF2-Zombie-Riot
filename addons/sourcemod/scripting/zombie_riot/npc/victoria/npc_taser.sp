#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_jeers01.mp3",
	"vo/spy_jeers02.mp3",
	"vo/spy_jeers03.mp3",
	"vo/spy_jeers04.mp3",
	"vo/spy_jeers05.mp3",
	"vo/spy_jeers06.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/spy_helpmedefend01.mp3",
	"vo/spy_helpmedefend02.mp3",
	"vo/spy_helpmedefend03.mp3",
};

static const char g_ReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};


void VictoriaTaser_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ReloadSound)); i++) { PrecacheSound(g_ReloadSound[i]); }
	PrecacheModel("models/bots/soldier_boss/bot_soldier_boss.mdl");
	PrecacheModel("models/player/Soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Taser");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_taser");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_taser");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaTaser(vecPos, vecAng, ally);
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
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound[GetRandomInt(0, sizeof(g_ReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 60, _, 0.5, 80);
	}

	public VictoriaTaser(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaTaser npc = view_as<VictoriaTaser>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		func_NPCDeath[npc.index] = view_as<Function>(VictoriaTaser_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaTaser_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaTaser_ClotThink);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_iOverlordComboAttack = 1;
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 310.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2023_shortness_breath/hwn2023_shortness_breath.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/majors_mark/majors_mark.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum24_daring_dell_style4/sum24_daring_dell_style4.mdl");


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

public void VictoriaTaser_ClotThink(int iNPC)
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
	if(npc.m_iOverlordComboAttack <= 0)
	{
		if(npc.m_iChanged_WalkCycle != 6)
		{
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 2.0;
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 6;
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true);
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			npc.PlayReloadSound();
			npc.m_iOverlordComboAttack = 1;
		}
		return;
	}
	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index))
	{
		return;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
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
		VictoriaTaserSelfDefense(npc,GetGameTime(npc.index)); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VictoriaTaser_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

public void VictoriaTaser_NPCDeath(int entity)
{
	VictoriaTaser npc = view_as<VictoriaTaser>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void VictoriaTaserSelfDefense(VictoriaTaser npc, float gameTime)
{
	int target;
	//some Ranged units will behave differently.
	//not this one.
	target = npc.m_iTarget;
	if(!IsValidEnemy(npc.index,target))
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_MP_STAND_SECONDARY");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}	
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
				{	
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", true);
					npc.m_iOverlordComboAttack --;
					npc.PlayMeleeSound();
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
						npc.PlayMeleeSound();
						//after we fire, we will have a short delay beteween the actual laser, and when it happens
						//This will predict as its relatively easy to dodge
						float projectile_speed = 600.0;

						WorldSpaceCenter(target, vecTarget);

						npc.FaceTowards(vecTarget, 20000.0);
						float ShootFaster = 1.0;
						if(NpcStats_VictorianCallToArms(npc.index))
						{
							ShootFaster *= 0.75;
						}
						npc.m_flNextMeleeAttack = gameTime + ShootFaster;
						int projectile = npc.FireParticleRocket(vecTarget, 75.0 , projectile_speed , 100.0 , "raygun_projectile_blue_crit");
						SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
						npc.PlayIdleAlertSound();
						SDKHook(projectile, SDKHook_StartTouch, VictoriaTaser_Rocket_Particle_StartTouch);
					}
					delete swingTrace;
				}
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.m_flSpeed = 250.0;
				npc.StartPathing();
			}
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
	}
}

public void VictoriaTaser_Rocket_Particle_StartTouch(int entity, int target)
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
		if (!IsInvuln(target))
		{
			if(NpcStats_VictorianCallToArms(entity))
			{
				ApplyStatusEffect(owner, target, "Teslar Electricution", 4.0);
				if(!HasSpecificBuff(target, "Fluid Movement"))
					TF2_StunPlayer(target, 1.0, 0.8, TF_STUNFLAG_SLOWDOWN);
			}
			else
			{
				ApplyStatusEffect(owner, target, "Teslar Electricution", 3.0);	
				if(!HasSpecificBuff(target, "Fluid Movement"))
					TF2_StunPlayer(target, 1.0, 0.8, TF_STUNFLAG_SLOWDOWN);
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