#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_MeleeAttackSounds[] = "weapons/sentry_rocket.wav";
static const char g_ActivationSounds[] = "mvm/mvm_tank_horn.wav";

static const char g_HurtSounds[][] = {
	"weapons/sentry_damage1.wav",
	"weapons/sentry_damage2.wav",
	"weapons/sentry_damage3.wav",
	"weapons/sentry_damage4.wav"
};
static int NPCId;

void VictorianOfflineAvangard_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Avangard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_avangard");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_avangard");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_ActivationSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheModel("models/bots/soldier_boss/bot_soldier_boss.mdl");
}

int VictorianAvangard_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianOfflineAvangard(vecPos, vecAng, ally, data);
}

methodmap VictorianOfflineAvangard < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL-20, _, BOSS_ZOMBIE_VOLUME, _);
	}
	public void PlayActivationSound()
 	{
		EmitSoundToAll(g_ActivationSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,110));
		
	}
	
	public VictorianOfflineAvangard(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianOfflineAvangard npc = view_as<VictorianOfflineAvangard>(CClotBody(vecPos, vecAng, "models/bots/soldier_boss/bot_soldier_boss.mdl", "1.75", "100000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 100.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 0.90;

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		
		if(!StrContains(data, "only"))
		{
			i_AttacksTillMegahit[npc.index]=600;
			npc.m_bFUCKYOU = true;
		}

		SetEntityRenderColor(npc.index, 80, 50, 50, 255);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2022_alcoholic_automaton/hwn2022_alcoholic_automaton.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable4, 100, 100, 100, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_armor/tw_soldierbot_armor.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);
		
		if(!npc.m_bFUCKYOU)
		{
			float flPos[3];
			float flAng[3];
					
			npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);

			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "teleporter_mvm_bot_persist", npc.index, "", {0.0,0.0,0.0});
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iWearable8), TIMER_FLAG_NO_MAPCHANGE);
		}
		return npc;
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianWelder npc = view_as<VictorianWelder>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ClotThink(int iNPC)
{
	VictorianOfflineAvangard npc = view_as<VictorianOfflineAvangard>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(i_AttacksTillMegahit[iNPC] >= 255)
	{
		if(i_AttacksTillMegahit[iNPC] <= 600)
		{
			if(!npc.m_bFUCKYOU)
			{
				npc.PlayActivationSound();
				IncreaseEntityDamageTakenBy(npc.index, 0.000001, 1.0);
			}
			i_AttacksTillMegahit[iNPC] = 601;
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_blackbox/c_blackbox.mdl");
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetEntityRenderColor(npc.m_iWearable1, 100, 100, 100, 255);

			npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");
			SetEntityRenderColor(npc.m_iWearable2, 100, 100, 100, 255);
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}

		int target = npc.m_iTarget;
		if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		{
			i_Target[npc.index] = -1;
			npc.m_flAttackHappens = 0.0;
		}
		
		if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
		{
			target = GetClosestTarget(npc.index);
			npc.m_iTarget = target;
			npc.m_flGetClosestTargetTime = gameTime + 1.0;
		}

		if(target > 0)
		{
			npc.SetActivity("ACT_MP_RUN_PRIMARY");

			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
			
			if(distance < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else 
			{
				npc.SetGoalEntity(target);
			}

			npc.StartPathing();
			
			if(npc.m_flAttackHappens)
			{
				if(npc.m_flAttackHappens < gameTime)
				{

					float damageDeal = 150.0;
					float ProjectileSpeed = 700.0;

					PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _,vecTarget);

					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
					npc.PlayMeleeSound();

					int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,"models/buildables/sentry3_rockets.mdl",_,_,60.0);
					if(entity != -1)
					{
						//max duration of 4 seconds beacuse of simply how fast they fire
						CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					}

					npc.m_iOverlordComboAttack--;

					if(npc.m_iOverlordComboAttack < 1)
					{
						npc.m_flAttackHappens = 0.0;
					}
					else
					{
						npc.m_flAttackHappens = gameTime + 0.5;
					}
				}
			}
			else if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_iOverlordComboAttack += 2;
				npc.m_flNextMeleeAttack = gameTime + 0.45;
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");

				if(npc.m_iOverlordComboAttack > 4)
				{
					target = Can_I_See_Enemy(npc.index, target);
					if(IsValidEnemy(npc.index, target))
					{
						npc.m_iTarget = target;
						npc.m_flGetClosestTargetTime = gameTime + 2.45;
						npc.m_flAttackHappens = gameTime + 0.5;
					}
				}
			}
		}
		else
		{
			npc.StopPathing();
		}
	}
	else
	{
		bool villagerexists = false;
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
			if (IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianMechanist_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(iNPC))
			{
				villagerexists = true;
			}
		}
		if(!villagerexists)
		{
			SmiteNpcToDeath(iNPC);
			return;
		}
	}
}

static void ClotDeath(int entity)
{
	VictorianOfflineAvangard npc = view_as<VictorianOfflineAvangard>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}
