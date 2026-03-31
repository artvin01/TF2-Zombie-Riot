#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] = {
	"npc/fast_zombie/fz_scream1.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/strider/striderx_alert5.wav",
	"npc/stalker/go_alert2.wav",
	"npc/metropolice/takedown.wav",
	"npc/headcrab_poison/ph_talk3.wav",
	"npc/headcrab/attack3.wav",
	"npc/dog/dog_playfull1.wav",
	"npc/antlion/fly1.wav",
	"npc/attack_helicopter/aheli_megabomb_siren1.wav",
	"npc/combine_soldier/vo/overwatchrequestreinforcement.wav",
	"npc/zombie_poison/pz_pain1.wav",
	"vo/scout_mvm_loot_rare05.mp3",
	"vo/sniper_mvm_loot_rare01.mp3",
	"vo/soldier_mvm_loot_rare04.mp3",
	"vo/spy_mvm_loot_rare02.mp3",
	"vo/demoman_mvm_loot_godlike01.mp3",
	"vo/engineer_mvm_loot_godlike01.mp3",
	"vo/heavy_mvm_loot_godlike03.mp3",
	"vo/medic_mvm_loot_godlike03.mp3",
	"vo/pyro_autodejectedtie01.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/stunstick/stunstick_fleshhit1.wav",
	"npc/fast_zombie/claw_strike1.wav",
	"npc/vort/foot_hit.wav",
	"physics/body/body_medium_impact_hard4.wav",
	"weapons/3rd_degree_hit_04.wav",
	"weapons/axe_hit_flesh3.wav",
	"weapons/bottle_hit_flesh2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/cbar_hitbod1.wav",
	"weapons/slap_hit3.wav",
	"npc/antlion_guard/shove1.wav",
	"npc/dog/dog_footstep_run4.wav",
	"npc/headcrab/headbite.wav",
	"npc/vort/foot_hit.wav",
};

void RTDMedic_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DefaultMedic_DeathSounds));	   i++) { PrecacheSound(g_DefaultMedic_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Roll The Dice");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_rtd_medic");
	strcopy(data.Icon, sizeof(data.Icon), "rtd_medic");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return RTDMedic(vecPos, vecAng, ally);
}

methodmap RTDMedic < CClotBody
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
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	property float m_flRandomSkin
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	
	
	public RTDMedic(float vecPos[3], float vecAng[3], int ally)
	{
		RTDMedic npc = view_as<RTDMedic>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 3;

		npc.m_fbGunout = false;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(RTDMedic_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(RTDMedic_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(RTDMedic_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 260.0;
		npc.m_flRandomSkin = GetGameTime(npc.index) + 1.0;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/editor/scriptedsequence.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void RTDMedic_ClotThink(int iNPC)
{
	RTDMedic npc = view_as<RTDMedic>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}

	if(npc.m_flRandomSkin < GetGameTime())
	{
		int skin = (GetRandomInt(0,5));
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_flRandomSkin = GetGameTime(npc.index) + 1.0;
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
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		if (npc.m_fbGunout == false && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			if (!npc.m_bmovedelay)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay = true;
			}
			//	npc.FaceTowards(vecTarget);
		}
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
		/*	int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
		
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
		
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
			
			npc.SetGoalVector(vPredictedPos);
		} else {
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		if((flDistanceToTarget < 62500 || flDistanceToTarget > 122500) && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			npc.StartPathing();
			
			npc.m_fbGunout = false;
			//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 500.0);
			
			if((npc.m_flNextMeleeAttack < GetGameTime(npc.index) && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) || npc.m_flAttackHappenswillhappen)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
					{
						
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							
							SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB, -1, _, vecHit);
							
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
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

public Action RTDMedic_OnTakeDamage(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	RTDMedic npc = view_as<RTDMedic>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void RTDMedic_NPCDeath(int entity)
{
	RTDMedic npc = view_as<RTDMedic>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	float flPosDeath[3];
	WorldSpaceCenter(npc.index, flPosDeath);
	ParticleEffectAt(flPosDeath, "ping_circle", 1.0);
	switch(GetRandomInt(0,35))
	{
		case 0: //HASTE PREFIX
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;

							ApplyStatusEffect(npc.index, entitycount, "The Haste", 999.0);
						}
					}
				}
			}
		}
		case 1: //THE BIG
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Big", 999.0);
						}
					}
				}
			}
		}
		case 2: //THE STRONG
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Strong", 999.0);
						}
					}
				}
			}
		}
		case 3: //THE TINY
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Tiny", 999.0);
						}
					}
				}
			}
		}
		case 4: //THE BLEEDER
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Bleeder", 999.0);
						}
					}
				}
			}
		}
		case 5: //THE VAMPIRE
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Vampire", 999.0);
						}
					}
				}
			}
		}
		case 6: //THE ANTI SEA
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Anti Sea", 999.0);
						}
					}
				}
			}
		}
		case 7: //THE SPRAYER
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Sprayer", 999.0);
						}
					}
				}
			}
		}
		case 8: //THE GRAVITATIONAL
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The Gravitational", 999.0);
						}
					}
				}
			}
		}
		case 9: //1 UP
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "1 UP", 999.0);
						}
					}
				}
			}
		}
		case 10: //REGENERATING
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Regenerating", 999.0);
						}
					}
				}
			}
		}
		case 11: //LAGGY
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Laggy", 999.0);
						}
					}
				}
			}
		}
		case 12: //VERDE
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Verde", 999.0);
						}
					}
				}
			}
		}
		case 13: //VOID AFFLICTED
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Void Afflicted", 999.0);
						}
					}
				}
			}
		}
		case 14: //THE FIRST
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "The First", 999.0);
						}
					}
				}
			}
		}
		case 15: //PERFECTED INSTINCT
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Perfected Instinct", 999.0);
						}
					}
				}
			}
		}
		case 16: //ARMORING
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Armoring Prefix", 999.0);
						}
					}
				}
			}
		}
		case 17: //MOTIVATING
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Motivating Prefix", 999.0);
						}
					}
				}
			}
		}
		case 18: //INVISIBLE
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Invisible Prefix", 999.0);
						}
					}
				}
			}
		}
		case 19: //ASEXUAL
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Asexual Prefix", 999.0);
						}
					}
				}
			}
		}
		case 20: //GLUG INFESTED
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Glug Infested Prefix", 999.0);
						}
					}
				}
			}
		}
		case 21: //EXPLOSIVE
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Explosive Prefix", 999.0);
						}
					}
				}
			}
		}
		case 22: //DISCO
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Disco Prefix", 999.0);
						}
					}
				}
			}
		}
		case 23: //TOXIC
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Toxic Prefix", 999.0);
						}
					}
				}
			}
		}
		case 24: //BOING
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Boing Prefix", 999.0);
						}
					}
				}
			}
		}
		case 25: //KNOCKBACK
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Knockback Prefix", 999.0);
						}
					}
				}
			}
		}
		case 26: //LOUD
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Loud Prefix", 999.0);
						}
					}
				}
			}
		}
		case 27: //LEGENDARY
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Legendary Prefix", 999.0);
						}
					}
				}
			}
		}
		case 28: //RAGEBAITER
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Ragebaiter Prefix", 999.0);
						}
					}
				}
			}
		}
		case 29: //SEMI HEALTHY
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Semi Healthy Prefix", 999.0);
						}
					}
				}
			}
		}
		case 30: //FAT
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Fat Prefix", 999.0);
						}
					}
				}
			}
		}
		case 31: //MODIFIER+
		{
			for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
			{
				if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
				{
					if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
					{
						float pos1[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
						static float pos2[3];
						GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < (500 * 500))
						{
							if(!Can_I_See_Ally(npc.index, entitycount))
								continue;
								
							ApplyStatusEffect(npc.index, entitycount, "Modifier+ Prefix", 999.0);
						}
					}
				}
			}
		}
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}