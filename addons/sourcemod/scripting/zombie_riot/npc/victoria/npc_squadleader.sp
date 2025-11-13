#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/demoman_sf13_magic_reac03.mp3",
	"vo/demoman_sf13_magic_reac05.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/demoman_sf13_midnight02.mp3",
	"vo/demoman_sf13_midnight04.mp3",
	"vo/demoman_sf13_midnight05.mp3",
	"vo/demoman_sf13_midnight06.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_RangedAttackSounds[] = "weapons/doom_scout_shotgun.wav";
static const char g_WarCry[] = "mvm/mvm_warning.wav";

static float f_GlobalSoundCD;

void VictorianSquadleader_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victorian ScoutSquad Leader");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_squadleader");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_squadleaders");
	data.IconCustom = true;
	data.Flags = 0;
	f_GlobalSoundCD = 0.0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSound(g_RangedAttackSounds);
	PrecacheSound(g_WarCry);
	PrecacheModel("models/player/demo.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianSquadleader(vecPos, vecAng, ally);
}

#define LEADER_BUFF_MAXRANGE 250.0 		

methodmap VictorianSquadleader < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
	}
	public void PlayMeleeWarCry() 
	{
		if(f_GlobalSoundCD > GetGameTime())
			return;
		EmitSoundToAll(g_WarCry, this.index, _, 80, _, 0.8, 100);
		f_GlobalSoundCD = GetGameTime() + 5.0;
	}
	
	public VictorianSquadleader(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianSquadleader npc = view_as<VictorianSquadleader>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.35", "15000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = VictorianSquadleader_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianSquadleader_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianSquadleader_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "family_business");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		npc.m_flAttackHappens_bullshit = GetGameTime() + 10.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		npc.m_iOverlordComboAttack = 10;
		npc.m_iChanged_WalkCycle = 1;

		npc.m_iWearable6 = ParticleEffectAt_Parent(vecPos, "utaunt_pedalfly_blue_spins", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_russian_riot/c_russian_riot.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/sum19_unforgiven_glory/sum19_unforgiven_glory.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/jul13_ol_jack/jul13_ol_jack.mdl");
		SetVariantString("1.05");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/demolitionists_dustcatcher/demolitionists_dustcatcher.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/sum19_dynamite_abs/sum19_dynamite_abs.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void VictorianSquadleader_ClotThink(int iNPC)
{
	VictorianSquadleader npc = view_as<VictorianSquadleader>(iNPC);
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
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = VictorianSquadleaderSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
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
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
	VictorianSquadleaderAOEbuff(npc,GetGameTime(npc.index));
}

static void VictorianSquadleader_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianSquadleader npc = view_as<VictorianSquadleader>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

static void VictorianSquadleader_NPCDeath(int entity)
{
	VictorianSquadleader npc = view_as<VictorianSquadleader>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
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

static int VictorianSquadleaderSelfDefense(VictorianSquadleader npc, float gameTime, int target, float distance)
{

	if(npc.m_iOverlordComboAttack <= 0)
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.SetActivity("ACT_MP_RUN_ITEM1");
			npc.m_iChanged_WalkCycle = 2;
			npc.m_bisWalking = true;
			npc.m_flSpeed = 310.0;
			npc.StartPathing();	
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}		
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl");
			KillFeed_SetKillIcon(npc.index, "battleaxe");
		}
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 50.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 2.5;

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
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
				}
			}
		}		
		return 0;
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangedSound();
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					if(!NpcStats_VictorianCallToArms(npc.index))
						npc.m_iOverlordComboAttack--;
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
					npc.m_flNextMeleeAttack = gameTime + 1.0;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 40.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 8.0;


						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						IncreaseEntityDamageTakenBy(target, 0.1, 3.5, true);
					}
				}
				delete swingTrace;
			}
			if(distance > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
			return 0;
		}
		else
		{
			if(distance > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else
	{
		if(distance > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	return 0;
}

void VictorianSquadleaderAOEbuff(VictorianSquadleader npc, float gameTime, bool mute = false)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flAttackHappens_bullshit < gameTime)
	{
		bool buffed_anyone;
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (entitycount <= MaxClients || !b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (LEADER_BUFF_MAXRANGE * LEADER_BUFF_MAXRANGE))
					{
						ApplyStatusEffect(npc.index, entitycount, "Squad Leader", 15.0);
						//Buff this entity.
						buffed_anyone = true;
					}
				}
			}
		}
		if(buffed_anyone)
		{
			float bufftime = 25.0;
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
			if(NpcStats_VictorianCallToArms(npc.index))
				bufftime -= 10.0;
			npc.m_flAttackHappens_bullshit = gameTime + bufftime;
			static int r;
			static int g;
			static int b ;
			static int a = 255;
			if(GetTeam(npc.index) != TFTeam_Red)
			{
				r = 7;
				g = 255;
				b = 255;
			}
			else
			{
				r = 255;
				g = 255;
				b = 7;
			}
			static float UserLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", UserLoc);
			spawnRing(npc.index, LEADER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, LEADER_BUFF_MAXRANGE * 2.0);		
			if(!mute)
			{
				spawnRing(npc.index, LEADER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
				spawnRing(npc.index, LEADER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
				npc.PlayMeleeWarCry();
			}
		}
		else
		{
			npc.m_flAttackHappens_bullshit = gameTime + 1.0; //Try again in a second.
		}
	}
}