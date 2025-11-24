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

void VictoriaArtillerist_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victorian Artillerist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victorian_artillerist");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_mortar");
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

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaArtillerist(vecPos, vecAng, ally, data);
}

methodmap VictoriaArtillerist < CClotBody
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
	property float m_flExplosionRadius
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flInAttackDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flImpactDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public VictoriaArtillerist(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaArtillerist npc = view_as<VictoriaArtillerist>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "3000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = VictoriaArtillerist_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaArtillerist_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaArtillerist_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		npc.m_iState = 0;
		npc.m_iChanged_WalkCycle=-2;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flWeaponSwitchCooldown = 0.0;
		npc.m_flExplosionRadius = EXPLOSION_RADIUS*1.25;
		npc.m_flInAttackDelay = 1.0;
		npc.m_flImpactDelay = 3.0;
		npc.m_flSpeed = 100.0;
		npc.StartPathing();
		
		npc.m_flMeleeArmor = 1.5;
		npc.m_flRangedArmor = 0.6;
		
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "radius") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "radius", "");
				npc.m_flExplosionRadius = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "inattack") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "inattack", "");
				npc.m_flInAttackDelay = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "impact") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "impact", "");
				npc.m_flImpactDelay = StringToFloat(countext[i]);
			}
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_blackbox/c_blackbox.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_flameball/c_flameball.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/soldier_warpig_s2.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/sbox2014_antarctic_researcher/sbox2014_antarctic_researcher.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl");

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

		return npc;
	}
}

static void VictoriaArtillerist_ClotThink(int iNPC)
{
	VictoriaArtillerist npc = view_as<VictoriaArtillerist>(iNPC);
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
		switch(VictoriaArtilleristSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget))
		{
			case -1:
			{
				if(npc.m_iChanged_WalkCycle != -1)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = -1;
					npc.SetActivity("ACT_MP_CROUCH_MELEE");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
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
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 150.0;
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

static Action VictoriaArtillerist_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaArtillerist npc = view_as<VictoriaArtillerist>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictoriaArtillerist_NPCDeath(int entity)
{
	VictoriaArtillerist npc = view_as<VictoriaArtillerist>(entity);
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

static int VictoriaArtilleristSelfDefense(VictoriaArtillerist npc, float gameTime, float distance)
{
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
	if(gameTime > npc.m_flNextRangedAttack && IsValidEnemy(npc.index, Enemy_I_See))
	{
		npc.FaceTowards(vecTarget, 20000.0);
		if(!npc.m_flAttackHappenswillhappen)
		{
			npc.m_flAttackHappens = gameTime+(npc.m_iState ? npc.m_flInAttackDelay : 0.2);
			npc.m_flAttackHappenswillhappen = true;
		}
		if(npc.m_flAttackHappenswillhappen && gameTime > npc.m_flAttackHappens)
		{
			npc.m_iTarget = Enemy_I_See;
			npc.PlayRangeSound();
			float RocketDamage = 200.0;
			float RocketSpeed = 650.0;
			float CoolDown = 5.0;
			if(NpcStats_VictorianCallToArms(npc.index))
			{
				RocketDamage *= 0.5;
				CoolDown *= 0.5;
			}
			float VecStart[3]; WorldSpaceCenter(npc.index, VecStart);
			if(npc.m_iState)
			{
				float SpeedReturn[3];
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.25);
				WorldSpaceCenter(npc.m_iTarget, vecTarget);
				//Rockets do no damage
				int RocketGet = npc.FireRocket(vecTarget, 0.0, RocketSpeed,_,1.5);
				if(RocketGet != -1)
				{
					SetEntProp(RocketGet, Prop_Send, "m_bCritical", true);
					vecTarget[0] += GetRandomFloat(-200.0, 200.0);
					vecTarget[1] += GetRandomFloat(-200.0, 200.0);
					ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 5.0, 2.0);
					float ang[3]; GetVectorAngles(SpeedReturn, ang);
					SetEntPropVector(RocketGet, Prop_Data, "m_angRotation", ang);
					TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
					SetEntityMoveType(RocketGet, MOVETYPE_NOCLIP);
					WorldSpaceCenter(npc.m_iTarget, vecTarget);
					if(IsValidClient(npc.m_iTarget) && !(GetEntityFlags(npc.m_iTarget)&FL_ONGROUND))
					{
						SpeedReturn[0]=90.0;
						SpeedReturn[1]=0.0;
						SpeedReturn[2]=0.0;
						EntityLookPoint(npc.m_iTarget, SpeedReturn, vecTarget, vecTarget);
						vecTarget[2] += (b_IsGiant[npc.m_iTarget] ? 64.0 : 42.0);
					}
					//This function actually does damage
					Engage_HE_Strike(npc.index, vecTarget, RocketDamage, npc.m_flImpactDelay, npc.m_flExplosionRadius);
					CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY",_,_,_,0.75);
				//They do a direct attack, slow down the rocket and make it deal less damage.
				RocketDamage *= 0.75;
				RocketSpeed *= 0.9;
				CoolDown *= 0.9;
				WorldSpaceCenter(npc.m_iTarget, vecTarget);
				int RocketGet = npc.FireRocket(vecTarget, RocketDamage, RocketSpeed);
				if(RocketGet != -1)
				{
					fl_rocket_particle_dmg[RocketGet] = RocketDamage;
					fl_Extra_Damage[RocketGet] = fl_Extra_Damage[npc.index];
				}
			}
			npc.m_flNextRangedAttack = gameTime + CoolDown;
			npc.m_flAttackHappenswillhappen = false;
		}
		return (npc.m_iState ? -1 : 3);
	}
	else
		npc.m_flAttackHappenswillhappen = false;
	if(gameTime < npc.m_flNextRangedAttack-3.5)
		return (npc.m_iState ? -1 : 3);
	else if(gameTime < npc.m_flNextRangedAttack-3.0)
		return (npc.m_iState ? 1 : 3);
	//No can shooty.
	//Enemy is close enough.
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
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

stock void Engage_HE_Strike(int entity, float targetpos[3], float damage, float delay, float radius)
{
	DataPack HEStrike = new DataPack();
	HEStrike.WriteCell(EntIndexToEntRef(entity));
	HEStrike.WriteFloatArray(targetpos, 3);
	HEStrike.WriteFloat(damage);
	HEStrike.WriteFloat(GetGameTime()+delay);
	HEStrike.WriteFloat(delay);
	HEStrike.WriteFloat(radius);
	RequestFrame(HE_StrikeThink, HEStrike);
}

static void HE_StrikeThink(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float targetpos[3]; pack.ReadFloatArray(targetpos, 3);
	float damage = pack.ReadFloat();
	float delay = pack.ReadFloat();
	float maxdelay = pack.ReadFloat();
	float radius = pack.ReadFloat();
	if(!IsValidEntity(entity))
		return;
	if(GetGameTime() >= delay)
	{
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(targetpos[0]);
		pack_boom.WriteFloat(targetpos[1]);
		pack_boom.WriteFloat(targetpos[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		CreateEarthquake(targetpos, 1.0, radius * 2.5, 16.0, 255.0);
		KillFeed_SetKillIcon(entity, "tf_projectile_rocket");
		Explode_Logic_Custom(damage, entity, entity, -1, targetpos, radius,_,0.8, true, 100, false, 25.0);
		return;
	}
	else
	{
		spawnRing_Vectors(targetpos, radius * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 100, 50, 100, 1, 0.1, 2.0, 0.1, 3);
		spawnRing_Vectors(targetpos, ((radius)*((delay-GetGameTime())/maxdelay))* 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 100, 50, 100, 1, 0.1, 2.0, 0.1, 3);
	}
	delete pack;
	DataPack pack2 = new DataPack();
	pack2.WriteCell(EntIndexToEntRef(entity));
	pack2.WriteFloatArray(targetpos, 3);
	pack2.WriteFloat(damage);
	pack2.WriteFloat(delay);
	pack2.WriteFloat(maxdelay);
	pack2.WriteFloat(radius);
	float Throttle = 0.04;	//0.025
	int frames_offset = RoundToCeil(66.0*Throttle);	//no need to call this every frame if avoidable
	if(frames_offset < 0)
		frames_offset = 1;
	RequestFrames(HE_StrikeThink, frames_offset, pack2);
}