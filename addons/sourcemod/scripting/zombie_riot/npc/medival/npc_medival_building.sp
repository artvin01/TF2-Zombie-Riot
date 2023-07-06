#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_IdleSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/bow_shoot.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/draw_sword.wav",
};

#define TOWER_MODEL "models/props_urban/urban_skybuilding005a.mdl"
#define TOWER_SIZE "1.0"


static float f_PlayerScalingBuilding;
static int i_currentwave[MAXENTITIES];
static bool AllyIsBoundToVillage[MAXENTITIES];

void ResetBoundVillageAlly(int entity)
{
	AllyIsBoundToVillage[entity] = false;
}
void MedivalBuilding_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel(TOWER_MODEL);


}
methodmap MedivalBuilding < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);

	}
	
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);

	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);

	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public MedivalBuilding(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		MedivalBuilding npc = view_as<MedivalBuilding>(CClotBody(vecPos, vecAng, TOWER_MODEL, TOWER_SIZE, GetBuildingHealth(), ally, false,true,_,_,{30.0,30.0,200.0}));
		
		i_NpcInternalId[npc.index] = MEDIVAL_BUILDING;
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
//		int iActivity = npc.LookupActivity("ACT_VILLAGER_RUN");
//		if(iActivity > 0) npc.StartActivity(iActivity);
		if(data[0])
		{
			i_AttacksTillMegahit[npc.index] = StringToInt(data);

		}
		
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", "models/props_manor/clocktower_01.mdl");
		SetVariantString("0.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		if(!ally)
		{
			b_thisNpcIsABoss[npc.index] = true;
		}
		i_NpcIsABuilding[npc.index] = true;

		float wave = float(ZR_GetWaveCount()+1);
		
		wave *= 0.1;
	
		npc.m_flWaveScale = wave;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		f_PlayerScalingBuilding = float(CountPlayersOnRed());

		i_currentwave[npc.index] = (ZR_GetWaveCount()+1);

		
		SDKHook(npc.index, SDKHook_Think, MedivalBuilding_ClotThink);

		GiveNpcOutLineLastOrBoss(npc.index, true);

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;

		NPC_StopPathing(npc.index);

		return npc;
	}
}

public void MedivalBuilding_ClotThink(int iNPC)
{
	MedivalBuilding npc = view_as<MedivalBuilding>(iNPC);
/*
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
*/
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.05;
	

	if(i_AttacksTillMegahit[iNPC] >= 255)
	{
		if(i_AttacksTillMegahit[iNPC] <= 600)
		{
			i_AttacksTillMegahit[iNPC] = 601;
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		}

		if(npc.m_flAttackHappens < GetGameTime(npc.index)) //spawn enemy!
		{
			int npc_current_count;
			if(!b_IsAlliedNpc[iNPC])
			{
				for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpc; entitycount_again_2++) //Check for npcs
				{
					int entity = EntRefToEntIndex(i_ObjectsNpcs[entitycount_again_2]);
					if(IsValidEntity(entity))
					{
						npc_current_count += 1;
					}
				}
			}
			else
			{
				for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpc_Allied; entitycount_again_2++) //Check for npcs
				{
					int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again_2]);
					if(IsValidEntity(entity) && AllyIsBoundToVillage[entity])
					{
						npc_current_count += 1;
					}
				}
			}
			//emercency stop. 
			float IncreaceSpawnRates = 6.5;

			IncreaceSpawnRates /= (Pow(1.14, f_PlayerScalingBuilding));

			if((!b_IsAlliedNpc[iNPC] && npc_current_count < LimitNpcs) || (b_IsAlliedNpc[iNPC] && npc_current_count < 6))
			{
				float AproxRandomSpaceToWalkTo[3];
				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
				
				AproxRandomSpaceToWalkTo[2] += 10.0;

				int EnemyToSpawn = MEDIVAL_MILITIA;
				bool Construct = false;

				if(b_IsAlliedNpc[iNPC])
				{
					IncreaceSpawnRates *= 5.0; //way slower.
				}
				
				if(i_currentwave[iNPC] < 15)
				{
					EnemyToSpawn = MEDIVAL_MILITIA;
					IncreaceSpawnRates *= 1.2; //less swarm!
				}
				else if(i_currentwave[iNPC] < 20)
				{
					EnemyToSpawn = MEDIVAL_MAN_AT_ARMS;
				}
				else if(i_currentwave[iNPC] < 25)
				{
					EnemyToSpawn = MEDIVAL_SWORDSMAN;
				}
				else if(i_currentwave[iNPC] < 30)
				{
					EnemyToSpawn = MEDIVAL_SWORDSMAN;
					IncreaceSpawnRates *= 0.75; //Swarm.
				}
				else if(i_currentwave[iNPC] < 40)
				{
					EnemyToSpawn = MEDIVAL_TWOHANDED_SWORDSMAN;
				}
				else if(i_currentwave[iNPC] < 45)
				{
					EnemyToSpawn = MEDIVAL_TWOHANDED_SWORDSMAN;
					IncreaceSpawnRates *= 0.85; //Swarm.
				}
				else if(i_currentwave[iNPC] < 50)
				{
					EnemyToSpawn = MEDIVAL_CHAMPION;
					IncreaceSpawnRates *= 1.75; //less swarm!
				}
				else if(i_currentwave[iNPC] < 55)
				{
					EnemyToSpawn = MEDIVAL_CHAMPION;
					IncreaceSpawnRates *= 1.0;
				}
				else if(i_currentwave[iNPC] < 60)
				{
					EnemyToSpawn = MEDIVAL_CHAMPION;
					IncreaceSpawnRates *= 0.85; //Swarm.
				}
				else if(i_currentwave[iNPC] >= 60)
				{
					EnemyToSpawn = MEDIVAL_CONSTRUCT;
					IncreaceSpawnRates *= 0.70; //Swarm.
					Construct = true;
				}

				int spawn_index = Npc_Create(EnemyToSpawn, -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
				if(spawn_index > MaxClients)
				{
					npc.PlayMeleeMissSound();
					npc.PlayMeleeMissSound();
					if(!b_IsAlliedNpc[iNPC])
					{
						Zombies_Currently_Still_Ongoing += 1;
					}
					else
					{
						AllyIsBoundToVillage[spawn_index] = true;
					}
					if(Construct)
					{
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", 55000);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 55000);
						fl_Extra_Damage[spawn_index] = 1.35;
					}
				}	
			}
			else
			{
				IncreaceSpawnRates = 0.0; //Try again next frame.
			}

			npc.m_flAttackHappens = GetGameTime(npc.index) + IncreaceSpawnRates;
		}
		if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
		{
			//Shoot arrow!
			int Target;
			Target = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(IsValidEnemy(npc.index, Target))
			{
				int Enemy_I_See;
				Enemy_I_See = Can_I_See_Enemy(npc.index, Target);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					/*
					float IncreaceAttackspeed = 1.0;


					IncreaceAttackspeed *= (1.0 - ((12.0 - 1.0) * 7.0 / 110.0));
					*/
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 5.0;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + (f_PlayerScalingBuilding * 0.055);
				}
			}
		}
		if(npc.m_flAttackHappens_bullshit > GetGameTime(npc.index))
		{
			int Target;
			Target = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(IsValidEnemy(npc.index, Target))
			{
				float vecTarget[3];
				float projectile_speed = 1200.0;
			//	vecTarget = PredictSubjectPositionForProjectiles(npc, Target, projectile_speed, 75.0);
				vecTarget = WorldSpaceCenter(Target);

				npc.PlayMeleeSound();

				float damage = 20.0;	

				damage *= npc.m_flWaveScale;

				npc.FireArrow(vecTarget, damage, projectile_speed,_,_, 75.0);
			}
			else
			{
				//none...
				Target = GetClosestTarget(npc.index,_,_,_,_,_,_,false);
				if(IsValidEnemy(npc.index, Target))
				{
					float vecTarget[3];
					float projectile_speed = 1200.0;
				//	vecTarget = PredictSubjectPositionForProjectiles(npc, Target, projectile_speed, 75.0);
					vecTarget = WorldSpaceCenter(Target);

					npc.PlayMeleeSound();

					float damage = 20.0;	

					damage *= npc.m_flWaveScale;

					npc.FireArrow(vecTarget, damage, projectile_speed,_,_, 75.0);
				}
			}
		}
	}
	else
	{
		bool villagerexists = false;
		if(!b_IsAlliedNpc[iNPC])
		{
			for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpc; entitycount_again_2++) //Check for npcs
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcs[entitycount_again_2]);
				if (IsValidEntity(entity) && i_NpcInternalId[entity] == MEDIVAL_VILLAGER && !b_NpcHasDied[entity])
				{
					villagerexists = true;
				}
			}
		}
		else
		{
			for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpc_Allied; entitycount_again_2++) //Check for npcs
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again_2]);
				if (IsValidEntity(entity) && i_NpcInternalId[entity] == MEDIVAL_VILLAGER && !b_NpcHasDied[entity])
				{
					villagerexists = true;
				}
			}
		}
		if(!villagerexists)
		{
			SDKHooks_TakeDamage(iNPC, 0, 0, 99999999.0, DMG_BLAST); //Kill it so it triggers the neccecary shit.
			return;
		}

		int alpha = i_AttacksTillMegahit[iNPC];
		if(alpha > 255)
		{
			alpha = 255;
		}
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, alpha);
	}
}

public Action MedivalBuilding_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalBuilding npc = view_as<MedivalBuilding>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void MedivalBuilding_NPCDeath(int entity)
{
	MedivalBuilding npc = view_as<MedivalBuilding>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, -1, pos, "", 0, 0);

	
	SDKUnhook(npc.index, SDKHook_Think, MedivalBuilding_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


static char[] GetBuildingHealth()
{
	int health = 110;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(CurrentRound+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
	}
	else if(CurrentRound+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	
	
	health = RoundToCeil(float(health) * 1.2);
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}