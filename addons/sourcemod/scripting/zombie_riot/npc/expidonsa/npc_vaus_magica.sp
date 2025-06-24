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
	"weapons/shooting_star_shoot.wav",
};
static const char g_ShieldAttackSounds[][] = {
	"weapons/medi_shield_deploy.wav",
};


void VausMagica_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ShieldAttackSounds)); i++) { PrecacheSound(g_ShieldAttackSounds[i]); }
	PrecacheModel("models/player/soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vaus Magica");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vaus_magica");
	strcopy(data.Icon, sizeof(data.Icon), "scout_stun_armored");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VausMagica(vecPos, vecAng, team);
}

methodmap VausMagica < CClotBody
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
	public void PlayShieldSound()
	{
		EmitSoundToAll(g_ShieldAttackSounds[GetRandomInt(0, sizeof(g_ShieldAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public VausMagica(float vecPos[3], float vecAng[3], int ally)
	{
		VausMagica npc = view_as<VausMagica>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.1", "5000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		func_NPCDeath[npc.index] = VausMagica_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VausMagica_OnTakeDamage;
		func_NPCThink[npc.index] = VausMagica_ClotThink;
		
		npc.m_flNextMeleeAttack = 0.0;
		VausMagicaShieldGiving(npc, GetGameTime()); //Give shield on spawn
		npc.m_flNextRangedSpecialAttack = GetGameTime() + GetRandomFloat(0.0, 15.0);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		npc.StartPathing();
		npc.m_flSpeed = 150.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_crossing_guard/c_crossing_guard.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/sf14_the_supernatural_stalker/sf14_the_supernatural_stalker.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/all_class/all_halo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/fall17_crit_cloak/fall17_crit_cloak.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void VausMagica_ClotThink(int iNPC)
{
	VausMagica npc = view_as<VausMagica>(iNPC);
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
	
	if(npc.m_flDoingAnimation)
	{
		npc.m_flSpeed = 0.0;
		if(npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			npc.m_flDoingAnimation = 0.0;

			npc.m_flSpeed = 150.0;
			npc.StartPathing();
		}
	}
	else
	{
		npc.m_flSpeed = 150.0;
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
	VausMagicaShieldGiving(npc,GetGameTime(npc.index)); 
	
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
		VausMagicaSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VausMagica_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VausMagica npc = view_as<VausMagica>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VausMagica_NPCDeath(int entity)
{
	VausMagica npc = view_as<VausMagica>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(npc.index, SDKHook_Think, VausMagica_ClotThink);
		
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void VausMagicaShieldGiving(VausMagica npc, float gameTime)
{
	if(gameTime < npc.m_flDoingAnimation)
	{
		return;
	}
	if(npc.m_flNextRangedSpecialAttack == FAR_FUTURE)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 15.0;
		float flPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		flPos[2] += 5.0;
		spawnRing_Vectors(flPos, /*RANGE start*/ 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 125, 125, 200, 1, /*DURATION*/ 0.5, 6.0, 0.1, 1,  /*RANGE END*/300 * 2.0);
		npc.PlayShieldSound();
	}

	if(gameTime > npc.m_flNextRangedSpecialAttack)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 1.0; //Retry in 1 second.
		b_NpcIsTeamkiller[npc.index] = true;
		Explode_Logic_Custom(0.0,
		npc.index,
		npc.index,
		-1,
		_,
		300.0,
		_,
		_,
		true,
		99,
		false,
		_,
		VausMagicaShield);
		b_NpcIsTeamkiller[npc.index] = false;
	}
}

void VausMagicaSelfDefense(VausMagica npc, float gameTime, int target, float distance)
{
	if(gameTime < npc.m_flDoingAnimation)
	{
		return;
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			npc.m_flAttackHappens = 0.0;
			
			npc.FaceTowards(vecTarget, 15000.0);
			npc.FireParticleRocket(vecTarget, 50.0 , 1000.0 , 100.0 , "raygun_projectile_blue");
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 2.0;
				npc.StopPathing();
			}
		}
	}
}
void VausMagicaShield(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && !b_NpcHasDied[victim])
	{
		VausMagicaShieldInternal(entity,victim);
	}
}

void VausMagicaShieldInternal(int shielder, int victim)
{
	VausMagica npc = view_as<VausMagica>(shielder);
	npc.m_flNextRangedSpecialAttack = FAR_FUTURE;
	VausMagicaGiveShield(victim, 3);
}
