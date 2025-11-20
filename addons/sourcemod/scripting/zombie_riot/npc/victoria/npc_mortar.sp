#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] = {
	")vo/medic_mvm_heal_shield01.mp3",
	")vo/medic_mvm_heal_shield02.mp3",
	")vo/medic_mvm_heal_shield03.mp3",
	")vo/medic_mvm_heal_shield04.mp3",
	")vo/medic_mvm_heal_shield05.mp3"
};

static const char g_ExplosionSounds[][]= {
	"weapons/explode1.wav",
	"weapons/explode2.wav",
	"weapons/explode3.wav"
};

static const char g_RageAttackSounds[] = "weapons/doom_rocket_launcher.wav";

void VictoriaMortar_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victorian Mortar");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_mortar");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_artillerist");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_ExplosionSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RageAttackSounds);
	PrecacheModel("models/player/medic.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaMortar(vecPos, vecAng, ally);
}
methodmap VictoriaMortar < CClotBody
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
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RageAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.2);
	}
	
	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public VictoriaMortar(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaMortar npc = view_as<VictoriaMortar>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "4000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = VictoriaMortar_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaMortar_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaMortar_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "quake_rl");
		npc.m_iState = 0;
		npc.m_iChanged_WalkCycle=-1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flWeaponSwitchCooldown = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 100.0;
		
		npc.m_flMeleeArmor = 1.50;
		npc.m_flRangedArmor = 0.7;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_directhit/c_directhit.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/cloud_crasher/cloud_crasher.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2022_victorian_villainy/hwn2022_victorian_villainy.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/cc_summer2015_the_vascular_vestment/cc_summer2015_the_vascular_vestment.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/dec22_wooly_pulli_style1/dec22_wooly_pulli_style1.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 255);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

static void VictoriaMortar_ClotThink(int iNPC)
{
	VictoriaMortar npc = view_as<VictoriaMortar>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		return;
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flWeaponSwitchCooldown < GetGameTime(npc.index))
	{
		npc.m_flWeaponSwitchCooldown = GetGameTime(npc.index) + 5.0;
		static float flMyPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];

		hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
		hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );

		npc.m_iState=(IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index) ? 0 : 1);
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VictoriaMortarSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.m_flSpeed = 100.0;
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
					npc.SetActivity("ACT_MP_STAND_MELEE");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 150.0;
					npc.StopPathing();
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
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
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

static Action VictoriaMortar_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaMortar npc = view_as<VictoriaMortar>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictoriaMortar_NPCDeath(int entity)
{
	VictoriaMortar npc = view_as<VictoriaMortar>(entity);
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

static int VictoriaMortarSelfDefense(VictoriaMortar npc, float gameTime, float distance)
{
	//Direct mode
	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 125.0))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangeSound();
				float RocketDamage = 200.0;
				float RocketSpeed = 650.0;
				float CoolDown = 4.0;
				/*if(NpcStats_VictorianCallToArms(npc.index))
					RocketDamage += RocketDamage*0.5;*/
				float VecStart[3]; WorldSpaceCenter(npc.index, VecStart);
				if(npc.m_iState)
				{
					float SpeedReturn[3];
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.25);
					for(int i=0; i<2; i++)
					{
						WorldSpaceCenter(npc.m_iTarget, vecTarget);
						int RocketGet = npc.FireRocket(vecTarget, 0.0, RocketSpeed, "models/weapons/w_models/w_grenade_grenadelauncher.mdl", 1.5);
						if(RocketGet != -1)
						{
							SetEntProp(RocketGet, Prop_Send, "m_bCritical", true);
							Better_Gravity_Rocket(RocketGet, 55.0);
							vecTarget[0] += GetRandomFloat(-200.0, 200.0);
							vecTarget[1] += GetRandomFloat(-200.0, 200.0);
							ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 1.5, 1.0);
							GetEntPropVector(RocketGet, Prop_Data, "m_vecAbsOrigin", VecStart);
							i_Wearable[RocketGet][0]=ParticleEffectAt(VecStart, "rockettrail", 0.0);
							SetParent(RocketGet, i_Wearable[RocketGet][0]);
							SetEntProp(RocketGet, Prop_Send, "m_nSkin", 1);
							fl_rocket_particle_dmg[RocketGet] = RocketDamage;
							fl_Extra_Damage[RocketGet] = fl_Extra_Damage[npc.index];
							SDKHook(RocketGet, SDKHook_StartTouch, HEGrenade_StartTouch);
							TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
						}
					}
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY",_,_,_,0.75);
					//They do a direct attack, slow down the rocket and make it deal less damage.
					RocketDamage *= 0.75;
					RocketSpeed *= 0.8;
					CoolDown *= 0.9;
					for(int i=0; i<2; i++)
					{
						WorldSpaceCenter(npc.m_iTarget, vecTarget);
						vecTarget[0] += GetRandomFloat(-150.0, 150.0);
						vecTarget[1] += GetRandomFloat(-150.0, 150.0);
						int RocketGet = npc.FireRocket(vecTarget, 0.0, RocketSpeed, "models/weapons/w_models/w_grenade_grenadelauncher.mdl");
						if(RocketGet != -1)
						{
							GetEntPropVector(RocketGet, Prop_Data, "m_vecAbsOrigin", VecStart);
							i_Wearable[RocketGet][0]=ParticleEffectAt(VecStart, "rockettrail", 0.0);
							SetParent(RocketGet, i_Wearable[RocketGet][0]);
							SetEntProp(RocketGet, Prop_Send, "m_nSkin", 1);
							fl_rocket_particle_dmg[RocketGet] = RocketDamage;
							fl_Extra_Damage[RocketGet] = fl_Extra_Damage[npc.index];
							SDKHook(RocketGet, SDKHook_StartTouch, HEGrenade_StartTouch);
						}
					}
				}
				npc.m_flNextRangedAttack = gameTime + CoolDown;
				//Launch something to target, unsure if rocket or something else.
				//idea:launch fake rocket with noclip or whatever that passes through all
				//then whereever the orginal goal was, land there.
				//it should be a mortar.
			}
		}
	}
	if(gameTime < npc.m_flNextRangedAttack-3.0)
		return (npc.m_iState ? 1 : 3);
	//No can shooty.
	//Enemy is close enough.
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			return (npc.m_iState ? 1 : 3);
		return (npc.m_iState ? 0 : 2);
	}
	else
	{
		return (npc.m_iState ? 0 : 2);
	}
}

static Action HEGrenade_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

	if(inflictor == -1)
		inflictor = owner;
		
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	Explode_Logic_Custom(fl_rocket_particle_dmg[entity], owner, inflictor, -1, ProjectileLoc, EXPLOSION_RADIUS, _, _, true, _, false, _, HEGrenade, ExplodeNoDMG);
	ParticleEffectAt(ProjectileLoc, "ExplosionCore_MidAir", 1.0);
	EmitSoundToAll(g_ExplosionSounds[GetRandomInt(0, sizeof(g_ExplosionSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL - 20, _, 0.8, _, -1, ProjectileLoc);
	//SDKUnhook(entity, SDKHook_StartTouch, HEGrenade_StartTouch);
	if(IsValidEntity(i_Wearable[entity][0]))
		RemoveEntity(i_Wearable[entity][0]);
	RemoveEntity(entity);
	return Plugin_Handled;
}

static void HEGrenade(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(GetTeam(entity) != GetTeam(victim))
	{
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = entity;
		if(ShouldNpcDealBonusDamage(victim))
			damage *= 3.0;
		//wtf beep
		if(NpcStats_VictorianCallToArms(entity))
		{
			for(int i=0; i<2; i++)
				SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
		}
		else
			SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
	}
}

static float ExplodeNoDMG(int entity, int victim, float damage, int weapon)
{
	return (damage * -1.0);
}