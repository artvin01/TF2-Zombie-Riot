#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static const char g_HurtSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/pyro_mvm_jeers01.mp3",
	"vo/mvm/norm/pyro_mvm_jeers02.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"player/taunt_yeti_standee_demo_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav",
};

static float f_OnHurtCooldown[MAXENTITIES];

void DimensionalFragment_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/pyro.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Disturbed Umbral");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_dimensionfrag");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return DimensionalFragment(vecPos, vecAng, team);
}
methodmap DimensionalFragment < CClotBody
{
	property float m_fOnHurtCooldown
	{
		public get()							{ return f_OnHurtCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ f_OnHurtCooldown[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.2;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(50, 80));
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public DimensionalFragment(float vecPos[3], float vecAng[3], int ally)
	{
		DimensionalFragment npc = view_as<DimensionalFragment>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.0", "22500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(DimensionalFragment_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(DimensionalFragment_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(DimensionalFragment_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 325.0;
		npc.m_fOnHurtCooldown = GetGameTime(npc.index) + 1.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_axtinguisher/c_axtinguisher_pyro.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/fall17_deyemonds/fall17_deyemonds.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/all_class/replay_hat_pyro.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_hw2014_robot_arm/sf14_hw2014_robot_arm.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_hw2014_robot_legg/sf14_hw2014_robot_legg.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable3, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable4, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable5, RENDERFX_HOLOGRAM);

		SetEntityRenderFx(npc.index, RENDERFX_HOLOGRAM);
		SetEntityRenderColor(npc.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));

		return npc;
	}
}

public void DimensionalFragment_ClotThink(int iNPC)
{
	DimensionalFragment npc = view_as<DimensionalFragment>(iNPC);
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
		DimensionalFragmentSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action DimensionalFragment_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	DimensionalFragment npc = view_as<DimensionalFragment>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	if(npc.m_fOnHurtCooldown < GetGameTime(npc.index))
	{
		float startPosition[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", startPosition); 
		startPosition[2] += 45.0;

		float endLoc[3];
		GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", endLoc);
		endLoc[2] += 50.0;

		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				npc.FireParticleRocket(endLoc, GetRandomFloat(100.0, 400.0), 1600.0, 125.0, "raygun_projectile_blue");
			}
			case 2:
			{
				npc.FireParticleRocket(endLoc, GetRandomFloat(50.0, 200.0), 800.0, 100.0, "raygun_projectile_red", true);
			}
			case 3:
			{
				WinterArcticMageHealRandomAlly(victim, GetRandomFloat(10000.0, 25000.0), 20);
			}
			default:
			{
				makeexplosion(victim, startPosition, GetRandomInt(25, 100), 150, _, true, true, 6.0);
			}
		}
		npc.m_fOnHurtCooldown = GetGameTime(npc.index) + 1.5;
	}
	
	return Plugin_Changed;
}

public void DimensionalFragment_NPCDeath(int entity)
{
	DimensionalFragment npc = view_as<DimensionalFragment>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void DimensionalFragmentSelfDefense(DimensionalFragment npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{	
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = GetRandomFloat(100.0, 400.0);
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				if(!NpcStats_IsEnemySilenced(npc.index))
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,2.5);
					npc.m_flAttackHappens = gameTime + 0.1;
					npc.m_flDoingAnimation = gameTime + 0.1;
					npc.m_flNextMeleeAttack = gameTime + 0.3;
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.5);
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
				}
				
			}
		}
	}
}
