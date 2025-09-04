#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_jaratehit03.mp3",
	"vo/spy_laughevil02.mp3",
	"vo/spy_laughshort06.mp3",
	"vo/spy_specialcompleted04.mp3",
	"vo/spy_specialcompleted11.mp3",
	"vo/taunts/spy_taunts13.mp3",
	"vo/taunts/spy_taunts15.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeAttackBackstabSounds[][] = {
	"player/spy_shield_break.wav",
};

static const char g_RageSounds[][] = {
	"vo/spy_stabtaunt02.mp3",
	"vo/spy_stabtaunt06.mp3",
	"vo/taunts/spy_highfive05.mp3"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/ambassador_shoot.wav"
};

static const char g_SpawnSounds[][] = {
	"vo/spy_cloakedspy01.mp3",
	"vo/spy_mvm_resurrect01.mp3"
};

static bool cloaked;
static bool PlaySound;

void GentleSpy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackBackstabSounds)); i++) { PrecacheSound(g_MeleeAttackBackstabSounds[i]); }
	for (int i = 0; i < (sizeof(g_RageSounds)); i++) { PrecacheSound(g_RageSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSounds)); i++) { PrecacheSound(g_SpawnSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Gentle Spy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_gentlespy");
	strcopy(data.Icon, sizeof(data.Icon), "spy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/rogue3/gentle_theme.mp3");
	PrecacheModel("models/bots/headless_hatman.mdl");
	PrecacheModel("models/props_halloween/ghost_no_hat.mdl");
	PrecacheSound("ui/holiday/gamestartup_halloween.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return GentleSpy(vecPos, vecAng, team);
}
methodmap GentleSpy < CClotBody
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
	
	public void PlaySpawnSound() 
	{
		EmitSoundToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)]);
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
	public void PlayMeleeBackstabSound(int target)
	{
		EmitSoundToAll(g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		if(target <= MaxClients)
		{
			EmitSoundToClient(target, g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], target, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayRangedSound() 
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRageSound()
	{
		EmitSoundToAll(g_RageSounds[GetRandomInt(0, sizeof(g_RageSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	property float f_CaptinoAgentusTeleport
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	
	
	public GentleSpy(float vecPos[3], float vecAng[3], int ally)
	{
		GentleSpy npc = view_as<GentleSpy>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}
		func_NPCDeath[npc.index] = view_as<Function>(GentleSpy_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(GentleSpy_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(GentleSpy_ClotThink);

		//Gentle Music (STRAIGHT BANGIN!!!)
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/rogue3/gentle_theme.mp3");
		music.Time = 147; //no loop usually 43 loop tho
		music.Volume = 1.25;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "{redsunsecond}The Blue Wrath");
		strcopy(music.Artist, sizeof(music.Artist), "{redsunsecond}I Monster");
		Music_SetRaidMusic(music);

		b_NoHealthbar[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;
		npc.m_iAttacksTillReload = 0;

		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 7.0;	//Go invis
		npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 10.0; //Teleport behind someone
		npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 12.0; //Play warning sound
		npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + 13.0; //Go for the stab
		
		cloaked = false;
		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_hat.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.PlaySpawnSound();
		
		return npc;
	}
}

public void GentleSpy_ClotThink(int iNPC)
{
	GentleSpy npc = view_as<GentleSpy>(iNPC);
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

	if(cloaked)
	{
		NPCStats_RemoveAllDebuffs(npc.index);
	}
	//Go invis
	if(npc.m_flAbilityOrAttack0)
	{
		if(npc.m_flAbilityOrAttack0 < GetGameTime(npc.index))
		{
			SetEntityCollisionGroup(npc.index, 1);
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 255, 255, 0);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 0);
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 0);
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 999.0; //so they cant instastab you!
			cloaked = true;
		}
	}

	//Teleport until playsound is stopped
	if(npc.m_flAbilityOrAttack1)
	{
		if(npc.m_flAbilityOrAttack1 < GetGameTime(npc.index))
		{
			PlaySound = false;
			if(!PlaySound)
			{
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 72.0, 72.0, 82.0 } );
				hullcheckmins = view_as<float>( { -72.0, -72.0, 0.0 } );
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				vPredictedPos = GetBehindTarget(npc.m_iTarget, 250.0 ,vPredictedPos);
				float PreviousPos[3];
				WorldSpaceCenter(npc.index, PreviousPos);
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
				bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
				if(Succeed)
				{
					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
					npc.FaceTowards(VecEnemy, 15000.0);
					npc.f_CaptinoAgentusTeleport = GetGameTime(npc.index) + 1.5;
					//npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 999.0; //so they cant instastab you!
				}
				//PlaySound = true;
			}
		}
	}

	//Stop trying to find best backstabbing place
	if(npc.m_flAbilityOrAttack2)
	{
		if(npc.m_flAbilityOrAttack2 < GetGameTime(npc.index))
		{
			PlaySound = true;
		}
	}

	//Go visible, head for the backstab
	if(npc.m_flAbilityOrAttack3)
	{
		if(npc.m_flAbilityOrAttack3 < GetGameTime(npc.index))
		{
			SetEntityCollisionGroup(npc.index, 24);
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
			SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
			npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 7.0;	//Go invis
			npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 10.0; //Teleport behind someone
			npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 12.0; //Play warning sound
			npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + 13.0; //Go for the stab
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.5;
			cloaked = false;
		}
	}

	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(!cloaked)
		{
			if(flDistanceToTarget < (200.0 * 200.0) && npc.m_iTargetWalkTo < (100.0 * 100.0)) //get close to ally but not too close
			{
				npc.m_iTargetWalkTo = npc.m_iTarget;
			}
		}
		if(cloaked)
		{
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		GentleSpySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action GentleSpy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	GentleSpy npc = view_as<GentleSpy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	//Gentle Spy rages, gives him 4 bullets in his epic ass gun and holy fucking shit what is that resistance
	if((ReturnEntityMaxHealth(npc.index)/1.25) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger)
	{
		npc.Anger = true; //	>:(
		npc.m_iAttacksTillReload = 4;
		ApplyStatusEffect(npc.index, npc.index, "Last Stand",	8.0);
		npc.PlayRageSound();
	}
	if((ReturnEntityMaxHealth(npc.index)/1.60) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bWasSadAlready) 
	{
		npc.m_bWasSadAlready = true;
		npc.m_iAttacksTillReload = 4;
		ApplyStatusEffect(npc.index, npc.index, "Last Stand",	8.0);
		npc.PlayRageSound();
	}
	if((ReturnEntityMaxHealth(npc.index)/3.2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bFUCKYOU)
	{
		npc.m_bFUCKYOU = true;
		npc.m_iAttacksTillReload = 4;
		ApplyStatusEffect(npc.index, npc.index, "Last Stand",	8.0);
		npc.PlayRageSound();
	}
	if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bFUCKYOU_move_anim) 
	{
		npc.m_bFUCKYOU_move_anim = true;
		npc.m_iAttacksTillReload = 4;
		ApplyStatusEffect(npc.index, npc.index, "Last Stand",	8.0);
		npc.PlayRageSound();
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void GentleSpy_NPCDeath(int entity)
{
	GentleSpy npc = view_as<GentleSpy>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void GentleSpySelfDefense(GentleSpy npc, float gameTime, int target, float distance)
{
	if(npc.m_iAttacksTillReload == 0)
	{
		if(npc.m_iChanged_WalkCycle != 0)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 0;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
		}
		bool BackstabDone = false;
		if(gameTime > npc.m_flNextMeleeAttack)
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;					
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.PlayMeleeSound();
					if(i_RaidGrantExtra[npc.index])
					{
						if(Enemy_I_See <= MaxClients && b_FaceStabber[Enemy_I_See])
						{
							BackstabDone = true;
						}
					}
					if(BackstabDone || IsBehindAndFacingTarget(npc.index, npc.m_iTarget))
					{
						BackstabDone = true;
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");	
					}
					else
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					}
					npc.m_flAttackHappens = 1.0;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
				}
			}
		}
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Ignore barricades
				{
					target = TR_GetEntityIndex(swingTrace);	

					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 2000.0;

						if(BackstabDone)
						{
							if(i_RaidGrantExtra[npc.index])
							{
								if(target <= MaxClients && b_FaceStabber[target])
								{
									damageDealt *= 0.5;
								}
							}
							npc.PlayMeleeBackstabSound(target);
							damageDealt *= 10.0;
						}
						else if(i_RaidGrantExtra[npc.index])
						{
							damageDealt *= 0.5;
						}
						
						KillFeed_SetKillIcon(npc.index, BackstabDone ? "backstab" : "eternal_reward");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

						// Hit sound
						npc.PlayMeleeHitSound();
					} 
				}
				delete swingTrace;
			}
		}
	}
	if(npc.m_iAttacksTillReload >= 1)
	{

		if(npc.m_iChanged_WalkCycle != 1)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.StartPathing();
			
			KillFeed_SetKillIcon(npc.index, "ambassador");
		}	
		
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.50))
		{
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
					npc.m_iTarget = Enemy_I_See;
					npc.PlayRangedSound();
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
						ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
						npc.m_flNextMeleeAttack = gameTime + 0.35;
						npc.m_iAttacksTillReload--;

						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 1000.0;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 5.0;

							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						}
					}
					delete swingTrace;
				}
			}
		}
	}
}