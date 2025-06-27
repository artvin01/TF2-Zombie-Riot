#pragma semicolon 1
#pragma newdecls required

static const char g_ChargeExplodeIn[][] = {
	"weapons/dragon_gun_motor_start.wav",
};
static const char g_DoExplodeSound[][] = {
	"weapons/cow_mangler_explosion_normal_01.wav",
	"weapons/cow_mangler_explosion_normal_02.wav",
	"weapons/cow_mangler_explosion_normal_03.wav",
};

void OnMapStartCombine_Guarder()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Guarder");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_guarder");
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheSoundArray(g_ChargeExplodeIn);
	PrecacheSoundArray(g_DoExplodeSound);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Combine_Guarder(vecPos, vecAng, team);
}

methodmap Combine_Guarder < CombineWarrior
{
	public void PlayChargeExplode()
	{
		EmitSoundToAll(g_ChargeExplodeIn[GetRandomInt(0, sizeof(g_ChargeExplodeIn) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	public void PlayExplodeSound()
	{
		EmitSoundToAll(g_DoExplodeSound[GetRandomInt(0, sizeof(g_DoExplodeSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	property float m_flSayLineCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTimeTillSelfExplode
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flTimeTillSelfExplodeCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flTimeTillAllowAction
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	public void PlayKilledEnemySound(int target) 
	{
		if(!IsValidEntity(target))
			return;

		int Health = GetEntProp(target, Prop_Data, "m_iHealth");
		
		if(Health <= 0)
		{
			if(target <= MaxClients)
			{
				static Race race;
				Races_GetClientInfo(target, race);
				if(StrEqual(race.Name, "Iberian"))
				{
					switch(GetRandomInt(0,2))
					{
						case 0:
							NpcSpeechBubble(this.index, "Ew, i hate birds.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
						case 1:
							NpcSpeechBubble(this.index, "I thought we cleansed this bird infestation?", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
						case 2:
							NpcSpeechBubble(this.index, "Flying dirtbags.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
					}
					return;
				}
			}

			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "Oh well.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "Pahahhahah..", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "Weak.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
		}
	}
	public Combine_Guarder(float vecPos[3], float vecAng[3], int ally)
	{
		Combine_Guarder npc = view_as<Combine_Guarder>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", ally, false));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;

		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Combine_Guarder_TakeDamagePost);

		func_NPCDeath[npc.index] = Combine_Guarder_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = BaseSquad_TakeDamage;
		func_NPCThink[npc.index] = Combine_Guarder_ClotThink;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/all_class/voodoojuju_hat_heavy.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		return npc;
	}
}

public void Combine_Guarder_ClotThink(int iNPC)
{
	Combine_Guarder npc = view_as<Combine_Guarder>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurt();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	npc.PlayKilledEnemySound(npc.m_iTargetAttack);

	if(npc.m_flTimeTillSelfExplode)
	{
		float NpcLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", NpcLoc);
		spawnRing_Vectors(NpcLoc, 300.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 50, 50, 200, 1, 0.3, 5.0, 8.0, 3);	
		spawnRing_Vectors(NpcLoc, 300.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 200, 50, 50, 200, 1, 0.3, 5.0, 8.0, 3);	
		if(npc.m_flTimeTillSelfExplode < gameTime)
		{
			npc.m_flTimeTillSelfExplode = 0.0;
			SpawnSmallExplosionNotRandom(NpcLoc);
			npc.PlayExplodeSound();
			//kabomm
			float damageDealt = 2500000.0;
			Explode_Logic_Custom(damageDealt, 0, npc.index, -1, _, 300.0, 1.0, _, true, 20);
			npc.m_flTimeTillAllowAction = gameTime + 1.0;
			if(npc.m_iChanged_WalkCycle != 9)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 9;
				npc.AddActivityViaSequence("Crouch_to_stand");
				npc.SetPlaybackRate(0.0);	
				npc.StopPathing();
				
			}
			//Do kaboom
		}
		return;
	}
	
	if(npc.m_flTimeTillAllowAction)
	{
		if(npc.m_flTimeTillAllowAction < gameTime)
		{
			npc.m_flTimeTillAllowAction = 0.0;
		}
		return;
	}

	float vecMe[3];
	WorldSpaceCenter(npc.index, vecMe);

	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = true;
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTargetAttack, vecTarget);

		// We're on standby, check if we should attack
		if(npc.m_bRanged)
		{
			bool shouldCharge = true;

			if(!b_NpcIsInADungeon[npc.index])
			{
				int count = i_MaxcountNpcTotal;

				for(int i; i < count; i++)
				{
					BaseSquad ally = view_as<BaseSquad>(EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]));
					if(ally.index != -1 && ally.index != npc.index)
					{
						if(ally.m_bIsSquad && ally.m_iTargetAttack == npc.m_iTargetAttack && !ally.m_bRanged && GetTeam(npc.index) == GetTeam(ally.index))
						{
							shouldCharge = false;	// An ally already attacking with melee, let them 1v1 em
							break;
						}
					}
				}
			}

			if(shouldCharge)
				npc.m_bRanged = false;	// Attack now
		}

		if(npc.m_flSayLineCD < gameTime)
		{
			npc.m_flSayLineCD = gameTime + 10.0;
			if(npc.m_bRanged)
			{
				// Passive
				switch(GetRandomInt(0,2))
				{
					case 0:
						NpcSpeechBubble(npc.index, "Ill give you a chance.", 7, {255,255,255,255}, {0.0,0.0,120.0}, "");
					case 1:
						NpcSpeechBubble(npc.index, "Looking cool.", 7, {255,255,255,255}, {0.0,0.0,120.0}, "");
					case 2:
						NpcSpeechBubble(npc.index, "I only do this for your sanity's sake.", 7, {255,255,255,255}, {0.0,0.0,120.0}, "");
				}
			}
			else
			{
				
				switch(GetRandomInt(0,2))
				{
					case 0:
						NpcSpeechBubble(npc.index, "My turn.", 7, {255,125,125,255}, {0.0,0.0,120.0}, "");
					case 1:
						NpcSpeechBubble(npc.index, "Come here.", 7, {255,125,125,255}, {0.0,0.0,120.0}, "");
					case 2:
						NpcSpeechBubble(npc.index, "I dont care anymore, fight me.", 7, {255,125,125,255}, {0.0,0.0,120.0}, "");
				}
			}
		}


		float distance = GetVectorDistance(vecTarget, vecMe, true);

		if(!npc.m_bRanged)
		{
			//This means i attack.
			if(npc.m_flTimeTillSelfExplodeCD < gameTime)
			{
				if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
				{
					npc.PlayChargeExplode();
					npc.m_flTimeTillSelfExplode = gameTime + 1.0;
					npc.m_flTimeTillSelfExplodeCD = gameTime + 13.0;
					if(npc.m_iChanged_WalkCycle != 8)
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 8;
						npc.AddActivityViaSequence("Stand_to_crouch");
					//	npc.SetCycle(0.62);
						npc.SetPlaybackRate(0.0);	
						npc.StopPathing();
						
					}
				}
			}
		}
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				npc.FaceTowards(vecTarget, 20000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						// E2 L15 = 157.5, E2 L20 = 175
						KillFeed_SetKillIcon(npc.index, "sword");
						SDKHooks_TakeDamage(target, npc.index, npc.index, 650000.0, DMG_CLUB, -1, _, vecTarget);
						npc.PlaySwordHit();
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextRangedAttackHappening)
		{
			canWalk = false;

			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				
				npc.FaceTowards(vecTarget, 20000.0);

				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				npc.PlaySwordSpecial();

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						// E2 L15 = 225, E2 L20 = 250
						KillFeed_SetKillIcon(npc.index, "taunt_pyro");
						SDKHooks_TakeDamage(target, npc.index, npc.index, 800000.0, DMG_BULLET, -1, _, vecTarget);
					}
				}

				delete swingTrace;
			}
			else if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
			{
				npc.FaceTowards(vecTarget, 2000.0);
			}
		}
		else if(npc.m_flNextRangedSpecialAttackHappens)
		{
			canWalk = false;
			if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				npc.FaceTowards(vecTarget, 2000.0);
			
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				npc.m_flNextRangedSpecialAttackHappens = 0.0;
				npc.m_flRangedArmor = 0.0001;

				npc.m_iWearable5 = npc.SpawnShield(3.0, "models/props_mvm/mvm_player_shield.mdl",80.0);
				npc.PlaySwordDeploy();
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
				npc.PlaySwordFire();

				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{
			if(npc.m_flNextRangedAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_PUSH_PLAYER");

				npc.m_flNextRangedAttackHappening = gameTime + 0.35;
				npc.m_flNextRangedAttack = gameTime + 4.45;
				npc.m_flNextRangedSpecialAttack = gameTime + 0.95;
			}
		}

		// No moving when ranged mode or on special cooldown
		if(canWalk && (npc.m_flNextRangedSpecialAttack > gameTime || npc.m_bRanged))
		{
			canWalk = false;
			if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				npc.FaceTowards(vecTarget, 2000.0);
		}
	}

	if(canWalk)
	{
		int attacker = npc.m_iTargetAttack;
		if(!npc.m_iTargetWalk)
			npc.m_iTargetAttack = 0;
		
		BaseSquad_BaseWalking(npc, vecMe, true);

		if(!npc.m_iTargetWalk)
			npc.m_iTargetAttack = attacker;
	}
	else
	{
		npc.StopPathing();
	}

	bool anger = BaseSquad_BaseAnim(npc, 80.0, "ACT_IDLE", "ACT_WALK", 330.0, "ACT_IDLE_ANGRY_MELEE", "ACT_RUN");
	npc.PlayIdle(anger);

	if(!anger)
		npc.m_bRanged = true;
}

public void Combine_Guarder_TakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Combine_Guarder npc = view_as<Combine_Guarder>(victim);

	float gameTime = GetGameTime(npc.index);
	if(attacker > 0 && attacker <= MaxClients)
	{
		if(npc.m_bRanged && npc.m_iTargetAttack)
		{
			npc.m_flSayLineCD = gameTime + 10.0;
			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(npc.index, "Youre an idiot.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(npc.index, "You really want to fight me aswell?", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(npc.index, "Ahahahahaha!", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
		}
		// He hit me, no 1v1 honor
		npc.m_bRanged = false;
	}
	/*
	if(!npc.m_iTargetWalk && npc.m_iTargetAttack)
	{
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.AddGesture("ACT_METROPOLICE_DEPLOY_MANHACK");
			
			npc.m_flNextMeleeAttack = gameTime + 1.15;
			npc.m_flNextRangedAttack = gameTime + 1.15;
			npc.m_flNextRangedSpecialAttackHappens = gameTime + 0.75;
			npc.m_flNextRangedSpecialAttack = gameTime + 3.75;
		}
	}
	*/
}

void Combine_Guarder_NPCDeath(int entity)
{
	Combine_Guarder npc = view_as<Combine_Guarder>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Combine_Guarder_TakeDamagePost);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}
