#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/shooting_star_shoot.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};

int SergeantIdeal_Alive = 0;
#define SEARGENT_IDEAL_RANGE 250.0

static int NPCId;

bool SergeantIdeal_Existant()
{
	if(SergeantIdeal_Alive > 0)
	{
		return true;
	}
	return false;
}

void SergeantIdeal_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/soldier.mdl");
	SergeantIdeal_Alive = 0;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sergeant Ideal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_sergeant_ideal");
	strcopy(data.Icon, sizeof(data.Icon), "seargent_ideal");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SergeantIdeal(vecPos, vecAng, team, data);
}
methodmap SergeantIdeal < CClotBody
{
	property int m_iGetSergeantProtector
	{
		public get()		 
		{ 
			int Entity_Sergeant = 0;
			float GameTimeSergeant = this.GetPropFloat(Prop_Data, "zr_fSergeantProtectTime");
			if(GameTimeSergeant > GetGameTime())
			{
				Entity_Sergeant = EntRefToEntIndex(this.GetProp(Prop_Data, "zr_iRefSergeantProtect")); 
				if(b_NpcHasDied[Entity_Sergeant])
					Entity_Sergeant = 0;
			}
			return Entity_Sergeant;
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				this.SetProp(Prop_Data, "zr_iRefSergeantProtect", INVALID_ENT_REFERENCE); 
			}
			else
			{
				if(this.m_iGetSergeantProtector == 0) //do not override the protector
					this.SetProp(Prop_Data, "zr_iRefSergeantProtect", EntIndexToEntRef(iInt)); 

				this.SetPropFloat(Prop_Data, "zr_fSergeantProtectTime", GetGameTime() + 0.25);
			}
		}
	}
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
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
	}


	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		if(this.g_TimesSummoned == 0)
			EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL - 10, _, NORMAL_ZOMBIE_VOLUME * 0.4);
	}

	public SergeantIdeal(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		SergeantIdeal npc = view_as<SergeantIdeal>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.1", "25000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextRangedAttack = 0.0;

		npc.g_TimesSummoned = 0;

		if(data[0])
			npc.g_TimesSummoned = StringToInt(data);
		
		func_NPCDeath[npc.index] = SergeantIdeal_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SergeantIdeal_OnTakeDamage;
		func_NPCThink[npc.index] = SergeantIdeal_ClotThink;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 1.0, Element_Chaos);
		
		
		npc.StartPathing();
		npc.m_flSpeed = 230.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/hw2013_demo_cape/hw2013_demo_cape.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/hw2013_galactic_gauntlets/hw2013_galactic_gauntlets.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/hw2013_jupiter_jumpers/hw2013_jupiter_jumpers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec15_patriot_peak/dec15_patriot_peak_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		NpcColourCosmetic_ViaPaint(npc.m_iWearable5, 7511618);

		if(npc.g_TimesSummoned == 0)
		{
			npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);
			SetVariantString("2.5");
			AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		}

	//	npc.m_iWearable7 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);
	//	SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_flModelScale", -2.5);



		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		if(npc.g_TimesSummoned == 0)
		{
			SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		}
	//	SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		SergeantIdeal_Alive += 1;
		return npc;
	}
}

public void SergeantIdeal_ClotThink(int iNPC)
{
	SergeantIdeal npc = view_as<SergeantIdeal>(iNPC);
	if(npc.g_TimesSummoned == 0)
	{
		if(f_TimeFrozenStill[iNPC])
		{
			if(IsValidEntity(npc.m_iWearable6))
			{
				RemoveEntity(npc.m_iWearable6);
			}
		//	if(IsValidEntity(npc.m_iWearable7))
		//	{
		//		RemoveEntity(npc.m_iWearable7);
		//	}
		}	
		else
		{
			if(!IsValidEntity(npc.m_iWearable6))
			{
				npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0,true);
				SetVariantString("2.5");
				AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
				SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
			}
			else
			{
				float vecTarget[3];
				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
				vecTarget[2] -= 100.0;
				Custom_SDKCall_SetLocalOrigin(npc.m_iWearable6, vecTarget);
			}
			/*
			if(!IsValidEntity(npc.m_iWearable7))
			{
				npc.m_iWearable7 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0,true);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_flModelScale", -2.5);
			}
			else
			{
				float vecTarget[3];
				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
				vecTarget[2] -= 100.0;
				Custom_SDKCall_SetLocalOrigin(npc.m_iWearable7, vecTarget);
			}
			*/
		}
	}

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
	
	if(npc.g_TimesSummoned == 0)
		SergeantIdealShield(npc.index);

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	SergeantIdealSelfDefense(npc, GetGameTime(npc.index));
	if(npc.m_flDoingAnimation)
	{
		npc.m_flSpeed = 0.0;
		if(npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			npc.m_flDoingAnimation = 0.0;
			npc.m_flSpeed = 230.0;
		}
	}
	else
	{
		npc.m_flSpeed = 230.0;
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

	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action SergeantIdeal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	SergeantIdeal npc = view_as<SergeantIdeal>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void SergeantIdeal_NPCDeath(int entity)
{
	SergeantIdeal npc = view_as<SergeantIdeal>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SergeantIdeal_Alive -= 1;
	SDKUnhook(npc.index, SDKHook_Think, SergeantIdeal_ClotThink);

//	if(IsValidEntity(npc.m_iWearable7))
	//	RemoveEntity(npc.m_iWearable7);
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

Action SergeantIdeal_Protect(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(i_NpcInternalId[victim] != NPCId)
	{
		if(!f_TimeFrozenStill[victim])
		{
			SergeantIdeal npc = view_as<SergeantIdeal>(victim);
			if(npc.m_iGetSergeantProtector)
			{
				SDKHooks_TakeDamage(npc.m_iGetSergeantProtector, attacker, inflictor, damage * 0.75, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
				damage = 0.0;
			}
		}
	}
	return Plugin_Continue;
}

void SergeantIdealShield(int iNpc)
{
	b_NpcIsTeamkiller[iNpc] = true;
	Explode_Logic_Custom(0.0,
	iNpc,
	iNpc,
	-1,
	_,
	SEARGENT_IDEAL_RANGE,
	_,
	_,
	false,
	99,
	false,
	_,
	SergeantIdealShieldAffected);
	b_NpcIsTeamkiller[iNpc] = false;
}


void SergeantIdealShieldAffected(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && !b_NpcHasDied[victim])
	{
		SergeantIdealShieldInternal(entity, victim);
	}
}

void SergeantIdealShieldInternal(int shielder, int victim)
{
	if(i_NpcInternalId[victim] != DiversionisticoID() && !b_NpcHasDied[victim]) //do not shield diversios.
	{
		SergeantIdeal npc = view_as<SergeantIdeal>(victim);
		npc.m_iGetSergeantProtector = shielder;
	}
}

void SergeantIdealSelfDefense(SergeantIdeal npc, float gameTime)
{
	int GetClosestEnemyToAttack;
	//Ranged units will behave differently.
	//Get the closest visible target via distance checks, not via pathing check.
	GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
	if(!IsValidEnemy(npc.index,GetClosestEnemyToAttack))
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 230.0;
			npc.StartPathing();
		}
		return;
	}
	if(npc.m_flAttackHappens)
	{
		SergeantIdealSelfDefenseMelee(npc,gameTime,GetClosestEnemyToAttack);
	}
	float vecTarget[3]; WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		if(npc.m_iChanged_WalkCycle != 5)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 5;
			npc.SetActivity("ACT_MP_STAND_PRIMARY");
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
		if(flDistanceToTarget <(NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.4))
		{
			SergeantIdealSelfDefenseMelee(npc,gameTime,GetClosestEnemyToAttack);
		}
		else
		{
			if(gameTime > npc.m_flNextRangedAttack)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
				npc.PlayRangedSound();
				//after we fire, we will have a short delay beteween the actual laser, and when it happens
				//This will predict as its relatively easy to dodge
				float projectile_speed = 800.0;
				//lets pretend we have a projectile.
				PredictSubjectPositionForProjectiles(npc, GetClosestEnemyToAttack, projectile_speed, 40.0, vecTarget);
				if(!Can_I_See_Enemy_Only(npc.index, GetClosestEnemyToAttack)) //cant see enemy in the predicted position, we will instead just attack normally
				{
					WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget );
				}
				float DamageDone = 25.0;
				if(npc.g_TimesSummoned == 0)
					npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "drg_cow_rockettrail_burst_charged_blue", false, true, false,_,_,_,10.0);
				else
					npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "drg_cow_rockettrail_normal_blue", false, true, false,_,_,_,10.0);

				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.5;
			}
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 230.0;
			npc.StartPathing();
		}
	}
}

void SergeantIdealSelfDefenseMelee(SergeantIdeal npc, float gameTime, int target)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float WorldSpaceVec[3]; WorldSpaceCenter(target, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 15000.0);
			if(npc.DoSwingTrace(swingTrace, target, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 60.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;

					Custom_Knockback(npc.index, target, 450.0);

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		int Enemy_I_See;			
		Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.m_iTarget = Enemy_I_See;
			npc.PlayMeleeSound();
			npc.AddGesture("ACT_MP_THROW");
					
			npc.m_flAttackHappens = gameTime + 0.25;
			npc.m_flDoingAnimation = gameTime + 0.35;
			npc.m_flNextMeleeAttack = gameTime + 0.9;
			npc.m_flNextRangedAttack = gameTime + 0.9;
		}
	}
}