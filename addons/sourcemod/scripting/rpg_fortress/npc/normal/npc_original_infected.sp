#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

#define BING_BANG_SOUND "npc/attack_helicopter/aheli_charge_up.wav"
#define BING_BANG_BOOM_SOUND "weapons/stinger_fire1.wav"

static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSound[][] = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};

static const char g_IdleSound[][] = {
	"vo/npc/male01/strider_run.wav",
	"vo/npc/male01/zombies01.wav",
	"vo/npc/male01/zombies02.wav",
	"vo/npc/male01/gethellout.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/npc/male01/strider_run.wav",
	"vo/npc/male01/zombies01.wav",
	"vo/npc/male01/zombies02.wav",
	"vo/npc/male01/gethellout.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


static const char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedSpecialAttackSoundsSecondary[][] = {
	"weapons/medi_shield_deploy.wav",
};
static const char g_TauntEnemy[][] = {
	"vo/npc/male01/likethat.wav",
	"vo/npc/male01/ammo04.wav",
	"vo/npc/male01/ammo03.wav",
};

static const char g_HalfHealth[][] = {
	"vo/npc/male01/thislldonicely01.wav",
	"vo/npc/male01/watchwhat.wav",
	"vo/npc/male01/youdbetterreload01.wav",
};


static char gLaser1;
static char gLaser2;
static char gLaser3;
public void OriginalInfected_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));	i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RangedSpecialAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedSpecialAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_TauntEnemy));	i++) { PrecacheSound(g_TauntEnemy[i]);	}
	for (int i = 0; i < (sizeof(g_HalfHealth));	i++) { PrecacheSound(g_HalfHealth[i]);	}

	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gLaser2 = PrecacheModel("materials/sprites/heatwave.vmt");
	gLaser3 = PrecacheModel("materials/sprites/laserbeam.vmt");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Original Infected, Junal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_original_infected");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return OriginalInfected(vecPos, vecAng, team, data);
}

methodmap OriginalInfected < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	public void PlayTauntSound()
	{
		EmitSoundToAll(g_TauntEnemy[GetRandomInt(0, sizeof(g_TauntEnemy) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	public void PlayHalfHealthSound()
	{
		EmitSoundToAll(g_HalfHealth[GetRandomInt(0, sizeof(g_HalfHealth) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}

	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,70);	
	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayRangedSpecialAttackSecondarySound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedSpecialAttackSoundsSecondary) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public OriginalInfected(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		OriginalInfected npc = view_as<OriginalInfected>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "300", ally, false, true));
		
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		func_NPCDeath[npc.index] = OriginalInfected_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = OriginalInfected_OnTakeDamage;
		func_NPCThink[npc.index] = OriginalInfected_ClotThink;
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, OriginalInfected_OnTakeDamagePost);
		npc.m_iOverlordComboAttack = 0;

		bool HardBattle = StrContains(data, "hardmode") != -1;
		if(HardBattle)
		{
			npc.m_iOverlordComboAttack = 1;
		}
		SetEntityRenderColor(npc.index, 125, 0, 125, 255);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_skullbat/c_skullbat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/medic_mask/medic_mask.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/sniper/desert_marauder.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/hw2013_the_parasight/hw2013_the_parasight.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable1, 125, 0, 125, 255);

		SetEntityRenderColor(npc.m_iWearable2, 125, 0, 125, 255);

		SetEntityRenderColor(npc.m_iWearable3, 125, 0, 125, 255);

		SetEntityRenderColor(npc.m_iWearable5, 125, 0, 125, 255);
		npc.StopPathing();
			
		npc.Anger = false;
		
		return npc;
	}
	
}


public void OriginalInfected_ClotThink(int iNPC)
{
	OriginalInfected npc = view_as<OriginalInfected>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 250.0, "ACT_RUN", "ACT_IDLE", 300.0, gameTime);

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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 250000.0;

					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						KillFeed_SetKillIcon(npc.index, "sword");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

						int Health = GetEntProp(target, Prop_Data, "m_iHealth");
						
						if(Health <= 0)
						{
							npc.PlayKilledEnemySound();
						}
					}
				}
				delete swingTrace;
			}
		}
	}

	if(npc.m_flNextRangedSpecialAttackHappens)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3];
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				npc.SpawnShield(3.0, "models/props_mvm/mvm_player_shield.mdl",80.0,false);
				npc.PlayRangedSpecialAttackSecondarySound();
				npc.m_flNextRangedSpecialAttackHappens = 0.0;
			}
		}
	}

	if(npc.m_flNextRangedAttackHappening)
	{
		//dont suck them in if its the final bit
		if(npc.m_flNextRangedAttackHappening - 0.25 > gameTime)
		{
			Bing_BangVisualiser(npc.index, 200.0, 350.0, 550.0);
		}
		if(npc.m_flNextRangedAttackHappening < gameTime)
		{
			npc.m_flNextRangedAttackHappening = 0.0;
			//Big TE OR PARTICLE that explodes
			//Make it purple too
			BingBangExplosion(npc.index, 600000.0, 350.0, 200.0, 1.0);
			npc.PlayTauntSound();
		}
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
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
		else if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_iState = 2; //Throw a Shield.
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5) && npc.m_flNextRangedAttack < gameTime)
		{
			npc.m_iState = 3; //Engage in Close Range Destruction.
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
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
					npc.SetActivity("ACT_RUN");
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

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.4;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
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
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_METROPOLICE_DEPLOY_MANHACK");

				//	npc.PlayMeleeSound();
					
					npc.m_flNextRangedSpecialAttackHappens = gameTime + 0.8;

					npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flNextRangedSpecialAttack = gameTime + 10.5;
					npc.m_bisWalking = false;
					npc.StopPathing();
					
				}
				else
				{
					npc.m_flNextRangedSpecialAttack = gameTime + 0.4; //Recheck later.
				}
			}
			case 3:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					//Enemy pulls everyone in heavily, then releases a huge wave of energy into the sky from his point, AOE boom basically.
					//damamges ppl ofc if too close
					//pull stops right before damage happens
					//enemy has high res while doing it.

					npc.AddActivityViaSequence("shootflare");
					//npc.AddGesture("ACT_MP_RUN_MELEE");
					npc.SetPlaybackRate(0.35);	
					npc.m_iChanged_WalkCycle = 1;
					EmitSoundToAll(BING_BANG_SOUND, npc.index, SNDCHAN_AUTO, 80, _, 1.0, 100);

					npc.m_flNextRangedAttackHappening = gameTime + 1.5;

					npc.m_flDoingAnimation = gameTime + 2.0;
					npc.m_flNextRangedAttack = gameTime + 7.5;

					npc.m_bisWalking = false;
					npc.StopPathing();
					
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action OriginalInfected_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	OriginalInfected npc = view_as<OriginalInfected>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void OriginalInfected_NPCDeath(int entity)
{
	OriginalInfected npc = view_as<OriginalInfected>(entity);
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
}

//put it on a delay, a sizeable one
void Bing_BangVisualiser(int entity, float range = 250.0, float Suckpower = 0.0, float Suckrange = 0.0)
{
	static int RepeatTillVisualiser[MAXENTITIES];

	RepeatTillVisualiser[entity] += 1;
	if(RepeatTillVisualiser[entity] >= 3)
	{
		RepeatTillVisualiser[entity] = 0;
		int r = 125;
		int g = 0;
		int b = 125;
		int a = 200;
		
		spawnRing(entity, range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 3.1, 1);
		spawnRing(entity, range * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 3.1, 1);
		spawnRing(entity, range * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 3.1, 1);
		float vecabsorigin[3];
		GetAbsOrigin(entity, vecabsorigin);
		spawnRing_Vectors(vecabsorigin, /*RANGE*/ 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, /*DURATION*/ 0.3, 6.0, 3.1, 1, range * 2.0);
	}
	
	if(Suckpower == 0.0)
		return;

	float partnerPos[3];
	float victimPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", partnerPos); 
	for(int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && IsValidEnemy(entity, client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", victimPos); 
			//from 
			//https://github.com/Batfoxkid/FF2-Library/blob/edited/addons/sourcemod/scripting/freaks/ff2_sarysamods9.sp
			float Distance = GetVectorDistance(victimPos, partnerPos);
			if(Distance < Suckrange)
			{
				static float angles[3];
				GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

				static float velocity[3];
				GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(velocity, Suckpower);
				
				float SubjectAbsVelocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
				velocity[0] += SubjectAbsVelocity[0];
				velocity[1] += SubjectAbsVelocity[1];
				velocity[2] += SubjectAbsVelocity[2];
								
				// apply velocity
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);       
			}
		}
	}	
	
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int enemyidx = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if(IsValidEnemy(entity, enemyidx))
		{	
			if(b_NoKnockbackFromSources[enemyidx])	
				continue;

			GetEntPropVector(enemyidx, Prop_Data, "m_vecAbsOrigin", victimPos); 
			float Distance = GetVectorDistance(victimPos, partnerPos);
			if(Distance < Suckrange)
			{			
				static float angles[3];
				GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

				static float velocity[3];
				GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(velocity, Suckpower);
				
				float SubjectAbsVelocity[3];
				GetEntPropVector(enemyidx, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
				velocity[0] += SubjectAbsVelocity[0];
				velocity[1] += SubjectAbsVelocity[1];
				velocity[2] += SubjectAbsVelocity[2];
								
				// apply velocity
				CClotBody npc = view_as<CClotBody>(enemyidx);
				npc.Jump();
				npc.SetVelocity(velocity);    
			}
		}
	}
}

void BingBangExplosion(int entity, float damage, float knockup, float Radius, float damagefalloff)
{
		
	EmitSoundToAll(BING_BANG_BOOM_SOUND, entity, SNDCHAN_AUTO, 80, _, 1.0, 100);
	EmitSoundToAll(BING_BANG_BOOM_SOUND, entity, SNDCHAN_AUTO, 80, _, 1.0, 100);
	float partnerPos[3];
	float partnerPos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", partnerPos);
	ParticleEffectAt(partnerPos, "moon_miasma_purple01", 0.5); //This is a permanent particle, gotta delete it manually...
	CreateEarthquake(partnerPos, 0.5, 350.0, 16.0, 255.0);
	partnerPos2 = partnerPos;
	partnerPos2[2] += 500.0;
	/*
	TE_SetupBeamPoints(const float start[3], const float end[3], int ModelIndex, int HaloIndex, int StartFrame, int FrameRate, float Life, float Width, 
	float EndWidth, int FadeLength, float Amplitude, const int Color[4], int Speed)
	*/
	//White middle beam
	TE_SetupBeamPoints(partnerPos, partnerPos2, gLaser1, 0, 0, 0, 1.0, 30.0, 30.0, 0, 1.0, {255, 255, 255, 255}, 3);
	TE_SendToAll();
	//Fainter more inner circle, heat, just makes it look hot
	TE_SetupBeamPoints(partnerPos, partnerPos2, gLaser2, 0, 0, 0, 0.8, 150.0, 150.0, 0, 4.0, {100, 0, 200, 255}, 3);
	TE_SendToAll();
	//Fainter more inner circle
	TE_SetupBeamPoints(partnerPos, partnerPos2, gLaser3, 0, 0, 0, 0.8, 150.0, 150.0, 0, 4.0, {100, 0, 200, 255}, 3);
	TE_SendToAll();
	//Fainter more inner circle
	TE_SetupBeamPoints(partnerPos, partnerPos2, gLaser1, 0, 0, 0, 0.7, 80.0, 80.0, 0, 1.0, {90, 0, 90, 255}, 3);
	TE_SendToAll();
	//issue: we cannot use normal explosion logic, as this explosion goes in a cirlce straight up, so its way more vertical targetability.
	partnerPos[2] -= 60.0;
	//the attack goes down abit.
	
	for(int enemyidx = 1; enemyidx <= MaxClients; enemyidx++)
	{
		if (IsValidEnemy(entity, enemyidx))
		{
			BingBangExplosionInternal(entity, enemyidx, partnerPos, damage, knockup, Radius, damagefalloff);
		}
	}
	
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int enemyidx = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if(IsValidEnemy(entity, enemyidx))
		{
			BingBangExplosionInternal(entity, enemyidx, partnerPos, damage, knockup, Radius, damagefalloff);
		}
	}
}

void BingBangExplosionInternal(int attacker, int victim, float SelfVec[3], float &damage, float knockup, float Radius, float damagefalloff)
{
	float victimPos[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", victimPos);

	float VictimPos2;
	float AttackerPos2;
	AttackerPos2 = SelfVec[2];
	VictimPos2 = victimPos[2];
	victimPos[2] = SelfVec[2];

	float Distance = GetVectorDistance(victimPos, SelfVec);
	if(Distance > Radius)
		return;

	//they are in the range, non dioagnially

	if(AttackerPos2 > VictimPos2)
		return;
	//they are above the player atleast

	AttackerPos2 -= 60.0;
	float HeightDifference = VictimPos2 - AttackerPos2;
	if(HeightDifference < 0.0)
		HeightDifference *= -1.0;

	if(HeightDifference > 560.0)
		return;

	if(!Can_I_See_Enemy_Only(attacker, victim))
		return;

	//all checks done, now damage the enemy
	int DamageCreditor = attacker;
	if(IsValidClient(GetEntPropEnt(attacker, Prop_Data, "m_hOwnerEntity")))
		DamageCreditor = GetEntPropEnt(attacker, Prop_Data, "m_hOwnerEntity");

	float WorldSpaceCenterVec[3]; 
	WorldSpaceCenter(victim, WorldSpaceCenterVec);
	SDKHooks_TakeDamage(victim, DamageCreditor, DamageCreditor, damage, DMG_CLUB, -1, {0.0,0.0, 30000.0}, WorldSpaceCenterVec);
	damage /= damagefalloff;
	//idealy you want no falloff 
	if(knockup > 0.0)
	{
		if(victim <= MaxClients)
		{
			float SubjectAbsVelocity[3];
			SubjectAbsVelocity[2] += knockup;
							
			// apply velocity
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, SubjectAbsVelocity); 	
		}
		else
		{
			if(!b_NoKnockbackFromSources[victim])	
			{
				float SubjectAbsVelocity[3];
				SubjectAbsVelocity[2] += knockup;
				CClotBody npc = view_as<CClotBody>(victim);
				npc.Jump();
				npc.SetVelocity(SubjectAbsVelocity);
			}
		}
	}
}


public void OriginalInfected_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	OriginalInfected npc = view_as<OriginalInfected>(victim);

	int maxHealth = ReturnEntityMaxHealth(npc.index);
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	if(maxHealth/2 >= Health && !npc.Anger) //Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(
		//This doesnt do anything except say words
		npc.PlayHalfHealthSound();
		if(npc.m_iOverlordComboAttack == 1)
		{
			fl_Extra_Damage[victim] *= 2.0;
			fl_Extra_Speed[victim] *= 1.1;
			SetEntityRenderColor(npc.index, 255, 0, 0, 255);

			SetEntityRenderColor(npc.m_iWearable1, 255, 0, 0, 255);

			SetEntityRenderColor(npc.m_iWearable2, 255, 0, 0, 255);

			SetEntityRenderColor(npc.m_iWearable3, 255, 0, 0, 255);

			SetEntityRenderColor(npc.m_iWearable5, 255, 0, 0, 255);
			IgniteTargetEffect(npc.m_iWearable1);
		}
	}
}