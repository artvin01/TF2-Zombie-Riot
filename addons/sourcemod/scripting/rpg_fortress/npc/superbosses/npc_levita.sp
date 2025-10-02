#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSound[][] = {
	"vo/medic_standonthepoint01.mp3",
	"vo/medic_standonthepoint02.mp3",
	"vo/medic_standonthepoint03.mp3",
	"vo/medic_standonthepoint04.mp3",
	"vo/medic_standonthepoint05.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
	"vo/medic_battlecry05.mp3",
	"vo/medic_item_secop_domination01.mp3",
	"vo/medic_item_secop_idle03.mp3",
	"vo/medic_item_secop_idle01.mp3",
	"vo/medic_item_secop_idle02.mp3"
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav"
};

static const char g_RangeAttackSound[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav"
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};


//#define RUINA_LASER_LOOP_SOUND		"zombiesurvival/seaborn/loop_laser.mp3"

public void Levita_OnMapStart_NPC()
{	
	//PrecacheSoundCustom(RUINA_LASER_LOOP_SOUND);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Levita");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_levita");
	data.Func = ClotSummon;
	//data.Precache = ClotPrecache;
	ClotPrecache();
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheModel("models/player/medic.mdl");
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_RangeAttackSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Levita(vecPos, vecAng, team, data);
}

methodmap Levita < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedSound()
 	{
		EmitSoundToAll(g_RangeAttackSound[GetRandomInt(0, sizeof(g_RangeAttackSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	public void PlayRangedAttackSecondarySound() 
	{
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
	}
	public Levita(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Levita npc = view_as<Levita>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1000", ally, false));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		//KillFeed_SetKillIcon(npc.index, "warrior_spirit");

		int iActivity = npc.LookupActivity("ACT_MP_STAND_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.g_TimesSummoned = 0;
		npc.Anger = false;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.m_iAttacksTillMegahit = 0;
		
		func_NPCDeath[npc.index] = NPC_Death;
		func_NPCOnTakeDamage[npc.index] = OnTakeDamage;
		func_NPCThink[npc.index] = NPC_ClotThink;

		//temp.
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable2 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl", _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl", _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tomb_readers/tomb_readers_medic.mdl", _, skin);
		float flPos[3], flAng[3];
		npc.GetAttachment("head", flPos, flAng);	
		npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "unusual_invasion_boogaloop_2", npc.index, "head", {0.0,0.0,0.0});

		SetVariantInt(RUINA_UNUSED_2);
		AcceptEntityInput(npc.m_iWearable2, "SetBodyGroup");
		SetVariantInt(RUINA_TWIRL_CREST_4);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
	
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void NPC_ClotThink(int iNPC)
{
	Levita npc = view_as<Levita>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	if(!npc.Anger)
	{
		npc.Anger = true;

	}
	if(!b_NpcIsInADungeon[npc.index])
	{
		if(!npc.m_iAttacksTillMegahit)
		{
			return;
		}
	}
	RPGNpc_UpdateHpHud(npc.index);
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 1500.0, "ACT_MP_RUN_MELEE", "ACT_MP_STAND_MELEE", 300.0, gameTime);
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 5000.0;

					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

						int Health = GetEntProp(target, Prop_Data, "m_iHealth");
						
						if(Health <= 0)
						{
							npc.PlayKilledEnemySound();
							if(GetRandomInt(0,0) == 0)
							{
								npc.m_bisWalking = false;
								npc.m_flNextThinkTime = gameTime + 1.0; //lol taunt, only works if there are people actually around
								npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");
								//Outright taunt them.
							}
						}
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_bisWalking = true;
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_iState = 2; //Throw a projectile
		}
		else if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_RUN_MELEE");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.3;

				//	npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_bisWalking = true;
				}
			}
			case 2:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 1.2;
					npc.PlayRangedAttackSecondarySound();
					npc.FaceTowards(vecTarget, 20000.0);
					
					npc.FireParticleRocket(vecTarget, 4000.0 , 600.0 , 100.0 , "halloween_rockettrail");
					npc.AddGesture("ACT_MP_THROW");

					npc.m_iTarget = Enemy_I_See;
					npc.m_bisWalking = true;
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Levita npc = view_as<Levita>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}
public void NPC_Death(int entity)
{
	Levita npc = view_as<Levita>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
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


