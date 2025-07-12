#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/sniper_taunts17.mp3",
	"vo/sniper_domination02.mp3",
	"vo/sniper_domination07.mp3",
	"vo/sniper_domination09.mp3",
	"vo/sniper_domination21.mp3",
	"vo/sniper_domination23.mp3",
	"vo/sniper_domination24.mp3",
	"vo/sniper_meleedare02.mp3",
	"vo/sniper_meleedare05.mp3",
	"vo/sniper_meleedare09.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"player/taunt_yeti_standee_demo_swing.wav",
	"player/taunt_yeti_standee_engineer_kick.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/revolver_shoot.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

void AgentBen_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/player/sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Agent Ben");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_agent_ben");
	strcopy(data.Icon, sizeof(data.Icon), "matrix_sniper_haste");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Matrix;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return AgentBen(vecPos, vecAng, ally);
}

methodmap AgentBen < CClotBody
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
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
	}
	
	public AgentBen(float vecPos[3], float vecAng[3], int ally)
	{
		AgentBen npc = view_as<AgentBen>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 9;

		npc.m_fbGunout = false;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(AgentBen_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AgentBen_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AgentBen_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 280.0;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/riflemans_rallycap/riflemans_rallycap_sniper.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/jul13_sweet_shades_s1/jul13_sweet_shades_s1_sniper.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/spr17_down_under_duster/spr17_down_under_duster.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum21_manndatory_attire_style3/sum21_manndatory_attire_style3_sniper.mdl");

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 255);
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		
		return npc;
	}
}

public void AgentBen_ClotThink(int iNPC)
{
	AgentBen npc = view_as<AgentBen>(iNPC);
	
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
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		if (npc.m_fbGunout == false && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			if (!npc.m_bmovedelay)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay = true;
			}

			AcceptEntityInput(npc.m_iWearable1, "Disable");
		}
		else if (npc.m_fbGunout == true && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			npc.m_bmovedelay = false;
			AcceptEntityInput(npc.m_iWearable1, "Enable");
		//	npc.FaceTowards(vecTarget, 1000.0);
			npc.StopPathing();
			
		}
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 62500 && flDistanceToTarget < 122500 && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			int Enemy_I_See;
		
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			
			if(!IsValidEnemy(npc.index, Enemy_I_See))
			{
				if (!npc.m_bmovedelay)
				{
					int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay = true;
				}

				AcceptEntityInput(npc.m_iWearable1, "Disable");
				npc.StartPathing();
				
				npc.m_fbGunout = false;
			}
			else
			{
				npc.m_fbGunout = true;
				
				npc.m_bmovedelay = false;
				
				npc.FaceTowards(vecTarget, 10000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.5;
				npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
			
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
				MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if (npc.m_iAttacksTillReload == 0)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.4;
					npc.m_iAttacksTillReload = 12;
					npc.PlayRangedReloadSound();
				}
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				

				FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 30.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
				
				npc.PlayRangedSound();
			}
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
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index) + AgentHealthSpeedMulti(npc);
					//npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + AgentHealthSpeedMulti(npc);
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
					{
						int target = TR_GetEntityIndex(swingTrace);
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(IsValidEnemy(npc.index, target))
						{
							float damage = 65.0;
							if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
							if(target > 0) 
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);

								Elemental_AddCorruptionDamage(target, npc.index, npc.index ? 35 : 10);
								// Hit sound
								npc.PlayMeleeHitSound();
							}
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + AgentHealthSpeedMulti(npc);
					npc.m_flAttackHappenswillhappen = false;
				}
				//shit code
				/*else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					PrintToChatAll("uh not suppose to be happening");
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + AgentHealthSpeedMulti(npc);
				}*/
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

public Action AgentBen_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AgentBen npc = view_as<AgentBen>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static float AgentHealthSpeedMulti(CClotBody npc)
{
	float flNextMeleeAttack = 0.40;
	float maxhealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float ratio = health / maxhealth;
	float flPos[3]; // original
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
	if(ratio <= 0.85)
	{
		flNextMeleeAttack = 0.35;
		if(!IsValidEntity(npc.m_iWearable8))
		{
			float flAng[3]; // dummy thats needed
			npc.GetAttachment("effect_hand_R", flPos, flAng);
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "superrare_burning2", npc.index, "effect_hand_R", {0.0, 0.0, 0.0});
		}
	}
	if(ratio <= 0.50)
	{
		flNextMeleeAttack = 0.30;
		if(!IsValidEntity(npc.m_iWearable8))
		{
			float flAng[3]; // dummy thats needed
			npc.GetAttachment("effect_hand_R", flPos, flAng);
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "superrare_burning2", npc.index, "effect_hand_R", {0.0, 0.0, 0.0});
		}
	}
	if(ratio <= 0.25)
	{
		flNextMeleeAttack = 0.25;
	}
	return flNextMeleeAttack;
}

public void AgentBen_NPCDeath(int entity)
{
	AgentBen npc = view_as<AgentBen>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
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