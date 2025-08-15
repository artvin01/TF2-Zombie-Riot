#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/scout_paincrticialdeath01.mp3",
	"vo/scout_paincrticialdeath02.mp3",
	"vo/scout_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/scout_battlecry01.mp3",
	"vo/scout_battlecry02.mp3",
	"vo/scout_battlecry03.mp3",
	"vo/scout_battlecry04.mp3",
	"vo/scout_battlecry05.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav"
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bat_hit.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/scatter_gun_double_shoot.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/scatter_gun_reload.wav",
};

void KevinMery_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/player/scout.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "kevinmery2009");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_kevinmery2009");
	strcopy(data.Icon, sizeof(data.Icon), "kevinmery");
	data.Precache = ClotPrecache;
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/aprilfools/kevinmery.mp3");
	PrecacheSoundCustom("#zombiesurvival/aprilfools/plead.mp3");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return KevinMery(vecPos, vecAng, ally);
}
methodmap KevinMery < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	property float m_flSwitchCooldown	// Delay between switching weapons
	{
		public get()			{	return this.m_flGrappleCooldown;	}
		public set(float value) 	{	this.m_flGrappleCooldown = value;	}
	}
	
	
	public KevinMery(float vecPos[3], float vecAng[3], int ally)
	{
		KevinMery npc = view_as<KevinMery>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.50", "700", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 999;

		npc.m_fbGunout = false;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(KevinMery_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(KevinMery_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(KevinMery_ClotThink);

		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 110);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 110);	

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "!shop");
			}
		}
		
		RaidModeScaling = float(Waves_GetRoundScale()+1);
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		float amount_of_people = float(CountPlayersOnRed());
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.15;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/kevinmery.mp3");
		music.Time = 277;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Rock and Awe");
		strcopy(music.Artist, sizeof(music.Artist), "Tim Wynn");
		Music_SetRaidMusic(music);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 310.0;
		npc.m_flSwitchCooldown = GetGameTime(npc.index) + 10.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + GetRandomFloat(11.0, 12.5);
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
				
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_bat.mdl");
		SetVariantString("1.50");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_double_barrel.mdl");
		SetVariantString("1.50");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/all_class/all_domination_2009_scout.mdl");
		SetVariantString("1.50");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum23_close_quarters_style4/sum23_close_quarters_style4.mdl");
		SetVariantString("1.50");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		return npc;
	}
}

public void KevinMery_ClotThink(int iNPC)
{
	KevinMery npc = view_as<KevinMery>(iNPC);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;

			for(int client1 = 1; client1 <= MaxClients; client1++)
			{
				if(!b_IsPlayerABot[client1] && IsClientInGame(client1) && !IsFakeClient(client1))
				{
					SetMusicTimer(client1, GetTime() + 1); //This is here beacuse of raid music.
					Music_Stop_All(client1);
					Music_EndLastmann(true);
				}
			}
			switch(GetRandomInt(0,1))
			{
				case 0:
				{
					CPrintToChatAll("{collectors}kevinmery2009{default}: there's only one more left!!");
					MusicEnum music;
					strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/plead.mp3");
					music.Time = 90; //no loop usually 43 loop tho
					music.Volume = 1.8;
					music.Custom = true;
					strcopy(music.Name, sizeof(music.Name), "Plead");
					strcopy(music.Artist, sizeof(music.Artist), "Key After Key");
					Music_SetRaidMusic(music);
					RaidModeTime = GetGameTime(npc.index) + 91.5;
				}
				case 1:
				{
					CPrintToChatAll("{collectors}kevinmery2009{default}: artvin pls nerf");
					MusicEnum music;
					strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/plead.mp3");
					music.Time = 90; //no loop usually 43 loop tho
					music.Volume = 1.8;
					music.Custom = true;
					strcopy(music.Name, sizeof(music.Name), "Plead");
					strcopy(music.Artist, sizeof(music.Artist), "Key After Key");
					Music_SetRaidMusic(music);
					RaidModeTime = GetGameTime(npc.index) + 91.5;
				}
			}
		}
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{collectors}kevinmery2009{default}: !hop");
		return;
	}

	//idk it never was in a bracket
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		if(RaidModeTime < GetGameTime())
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			CPrintToChatAll("{collectors}kevinmery2009{default}: {default}gg{default}");
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			return;
		}
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}

	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		if(npc.m_flSwitchCooldown)
		{
			if(npc.m_flSwitchCooldown < gameTime)
			{
				//AcceptEntityInput(npc.m_iWearable1, "Disable");
				//AcceptEntityInput(npc.m_iWearable2, "Enable");
				KevinMery_WeaponSwaps(npc, 2);
				npc.m_flSwitchCooldown = 0.0;
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 2.0;
				//int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
				//if(iActivity > 0) npc.StartActivity(iActivity);
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{collectors}kevinmery2009{default}: {default}my dad gave me this gun{default}");
					}
					case 1:
					{
						CPrintToChatAll("{collectors}kevinmery2009{default}: {default}i miss my dad :({default}");
					}
					case 2:
					{
						CPrintToChatAll("{collectors}kevinmery2009{default}: {default}this is so much fun :){default}");
					}
				}
			}
			else
			{
				//AcceptEntityInput(npc.m_iWearable1, "Enable");
				//AcceptEntityInput(npc.m_iWearable2, "Disable");
				KevinMery_WeaponSwaps(npc, 1);
			}
		}
		else
		{
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

				float vecDirShooting[3], vecRight[3], vecUp[3];
				float vecSpread = 0.1;
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				WorldSpaceCenter(npc.index, VecSelfNpc);
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{collectors}kevinmery2009{default}: {default}fire!!!{default}");
					}
					case 1:
					{
						CPrintToChatAll("{collectors}kevinmery2009{default}: {default}pow!!!{default}");
					}
					case 2:
					{
						CPrintToChatAll("{collectors}kevinmery2009{default}: {default}boom!!!{default}");
					}
				}
				npc.m_flSwitchCooldown = gameTime + 10.0;
				npc.m_flNextRangedSpecialAttack = 0.0;
				
				float damage = 15.0;
				damage *= RaidModeScaling;

				int PrimaryThreatIndex = npc.m_iTarget;
				FireBullet(npc.index, npc.m_iWearable2, VecSelfNpc, vecDir, damage, 9000.0, DMG_BULLET, "bullet_tracer01_red");
				Custom_Knockback(npc.index, PrimaryThreatIndex, 10000.0, true, true);
				
				npc.PlayRangedSound();
			}
			else
			{
				return;
			}
		}
		
		KevinMery_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void KevinMery_SelfDefense(KevinMery npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				//KevinMery_WeaponSwaps(npc, 1);
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				float damage = 20.0;
				damage *= RaidModeScaling;
				bool silenced = NpcStats_IsEnemySilenced(npc.index);
				for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if(i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							
							WorldSpaceCenter(targetTrace, vecHit);

							if(damage <= 1.0)
							{
								damage = 1.0;
							}
							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							//Reduce damage after dealing
							damage *= 0.92;
							// On Hit stuff
							bool Knocked = false;
							if(!PlaySound)
							{
								PlaySound = true;
							}
							
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 180.0, true);
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								else
								{
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 225.0, true); 
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iOverlordComboAttack++;
				KevinMery_WeaponSwaps(npc, 1);
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				npc.m_flAttackHappens = gameTime + 0.2;
				float attack = 1.0;
				npc.m_flNextMeleeAttack = gameTime + attack;
			}
		}
		if(npc.m_iOverlordComboAttack >= 10)
		{
			float flPos[3];
			if(!IsValidEntity(npc.m_iWearable9))
			{
				float flAng[3];
				npc.GetAttachment("hand_R", flPos, flAng);
				npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "buildingdamage_fire3", npc.index, "hand_R", {0.0, 0.0, 0.0});
			}
			float attack2 = 0.35;
			npc.m_flNextMeleeAttack = gameTime + attack2;
		}
		if(npc.m_iOverlordComboAttack >= 20)
		{
			npc.m_iOverlordComboAttack = 0;
		}
		if(npc.m_iOverlordComboAttack <= 1)
		{
			if(IsValidEntity(npc.m_iWearable9))
			RemoveEntity(npc.m_iWearable9);
		}
	}
}
static void KevinMery_WeaponSwaps(KevinMery npc, int number = 1)
{
	switch(number)
	{
		case 1:
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				AcceptEntityInput(npc.m_iWearable2, "Disable");
				npc.m_iChanged_WalkCycle = 3;
			}
		}
		case 2:
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				npc.m_iChanged_WalkCycle = 4;
			}
		}
	}
}

static Action KevinMery_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	KevinMery npc = view_as<KevinMery>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	
	}
	return Plugin_Changed;
}

public void KevinMery_NPCDeath(int entity)
{
	KevinMery npc = view_as<KevinMery>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	Music_SetRaidMusicSimple("vo/null.mp3", 60, false, 0.5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}