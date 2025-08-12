#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/soldier_mvm_standonthepoint01.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint02.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint03.mp3",
};

static const char g_HalfHealthSounds[][] = {
	"vo/mvm/norm/soldier_mvm_robot_see_ghost01.mp3",
	"vo/mvm/norm/soldier_mvm_robot_see_ghost02.mp3",
};

static const char g_SwitchWeaponSounds[][] = {
	"vo/mvm/norm/soldier_mvm_robot10.mp3",
	"vo/mvm/norm/soldier_mvm_robot11.mp3",
	"vo/mvm/norm/soldier_mvm_robot12.mp3",
	"vo/mvm/norm/soldier_mvm_robot15.mp3",
	"vo/mvm/norm/soldier_mvm_robot20.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_draw.wav",
};
static const char g_MeleeAttackSounds_Hand[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"ambient/sawblade_impact1.wav",
	"ambient/sawblade_impact2.wav",
};
static const char g_MeleeHitSounds_Hand[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/shotgun_shoot.wav",
};

static const char g_ShotgunReloadingSounds[][] = {
	")weapons/shotgun_cock_back.wav",
	")weapons/shotgun_cock_forward.wav",
};

static const char g_MalfunctionSounds[][] = {
	"weapons/sentry_damage1.wav",
	"weapons/sentry_damage2.wav",
	"weapons/sentry_damage3.wav",
	"weapons/sentry_damage4.wav",
};
static const char g_PassiveSound[][] = {
	"mvm/giant_heavy/giant_heavy_loop.wav",
};
static const char g_BatteryBladeEmpty[][] = {
	"weapons/cow_mangler_explosion_normal_04.wav",
	"weapons/cow_mangler_explosion_normal_05.wav",
	"weapons/cow_mangler_explosion_normal_06.wav",
};
void CHIMERA_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds_Hand)); i++) { PrecacheSound(g_MeleeAttackSounds_Hand[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds_Hand)); i++) { PrecacheSound(g_MeleeHitSounds_Hand[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ShotgunReloadingSounds));   i++) { PrecacheSound(g_ShotgunReloadingSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MalfunctionSounds));   i++) { PrecacheSound(g_MalfunctionSounds[i]);   }
	for (int i = 0; i < (sizeof(g_HalfHealthSounds));   i++) { PrecacheSound(g_HalfHealthSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	for (int i = 0; i < (sizeof(g_BatteryBladeEmpty));   i++) { PrecacheSound(g_BatteryBladeEmpty[i]);   }
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "C.H.I.M.E.R.A");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chimera");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_robot_nys");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return CHIMERA(vecPos, vecAng, ally, data);
}

methodmap CHIMERA < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}

	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		if(this.m_flBatteryLeftBlade)
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
		}
		else
		{
			EmitSoundToAll(g_MeleeAttackSounds_Hand[GetRandomInt(0, sizeof(g_MeleeAttackSounds_Hand) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		}
	}
	public void PlayMeleeHitSound() 
	{
		if(this.m_flBatteryLeftBlade)
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_MeleeHitSounds_Hand[GetRandomInt(0, sizeof(g_MeleeHitSounds_Hand) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
	}
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	public void PlayBatteryEmpty()
	{
		EmitSoundToAll(g_BatteryBladeEmpty[GetRandomInt(0, sizeof(g_BatteryBladeEmpty) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 80);
		EmitSoundToAll(g_BatteryBladeEmpty[GetRandomInt(0, sizeof(g_BatteryBladeEmpty) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 80);
	}

	property float m_flBatteryLeftBlade
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	public CHIMERA(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		CHIMERA npc = view_as<CHIMERA>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.50", "700", ally, false, true, true, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		func_NPCDeath[npc.index] = CHIMERA_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CHIMERA_OnTakeDamage;
		func_NPCThink[npc.index] = CHIMERA_ClotThink;

		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		npc.PlayPassiveSound();
		
		float RaidTimeDo = 160.0;
		npc.m_flBatteryLeftBlade = GetGameTime(npc.index) + (RaidTimeDo * 0.5);
		RaidModeTime = GetGameTime(npc.index) + RaidTimeDo;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "A.R.I.S. arrives");
			}
		}
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
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
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/matrix/furiousangels.mp3");
		music.Time = 161;
		music.Volume = 1.7;
		music.Custom = false;
		strcopy(music.Name, sizeof(music.Name), "Furious Angels (Instrumental)");
		strcopy(music.Artist, sizeof(music.Artist), "Rob Dougan");
		Music_SetRaidMusic(music);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = -1;	
		npc.m_iNpcStepVariation = -1;
		
		npc.m_flSpeed = 300.0;
		npc.m_flMeleeArmor = 1.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		Citizen_MiniBossSpawn();
		npc.StartPathing();

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/tw_medibot_chariot/tw_medibot_chariot.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sum24_hazardous_vest/sum24_hazardous_vest.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec24_polar_charger_style4/dec24_polar_charger_style4.mdl", _, skin);

		float flPos[3];
		float flAng[3];
		npc.GetAttachment("flag", flPos, flAng);
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "projectile_fireball_smoke", npc.index, "flag", {0.0,0.0,0.0});

		npc.m_iWearable5 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetVariantInt(8192);
		AcceptEntityInput(npc.m_iWearable5, "SetBodyGroup");
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 8);

		return npc;
	}
}

public void CHIMERA_ClotThink(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	float gameTime = GetGameTime(iNPC);
	
	if(CHIMERA_LoseConditions(iNPC))
		return;
	if(CHIMERA_timeBased(iNPC))
		return;

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
		
	npc.m_flNextThinkTime = gameTime + 0.1;

	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int EnemyTarget = npc.m_iTarget;
	if (IsValidEnemy(npc.index, EnemyTarget))
	{
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(npc.index, vecPos);
		WorldSpaceCenter(EnemyTarget, vecTargetPos);
		
		float distance = GetVectorDistance(vecPos, vecTargetPos, true);
	
		// Predict their pos when not loading our gun
		if (distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, EnemyTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(EnemyTarget);
		}
		
		CHIMERA_SelfDefense(npc, gameTime, EnemyTarget, distance);
	}
	else
	{
		//no valid target, do stuff.
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void CHIMERA_SelfDefense(CHIMERA npc, float gameTime, int target, float distance)
{
	if (npc.m_flAttackHappens && npc.m_flAttackHappens < GetGameTime(npc.index))
	{
		npc.m_flAttackHappens = 0.0;
		
		if(IsValidEnemy(npc.index, target))
		{
			int HowManyEnemeisAoeMelee = 64;
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
			delete swingTrace;
			bool PlaySound = false;
			float damage = 35.0;
			damage *= RaidModeScaling;
			if(npc.m_flBatteryLeftBlade)
			{
				damage *= 2.0;
			}
			bool silenced = NpcStats_IsEnemySilenced(npc.index);
			for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
			{
				if(i_EntitiesHitAoeSwing_NpcSwing[counter] <= 0)
					continue;
				if(!IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
					continue;

				int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
				float vecHit[3];
				
				WorldSpaceCenter(targetTrace, vecHit);

				SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);

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
					Custom_Knockback(npc.index, targetTrace, 450.0, true); 
			}
			if(PlaySound)
			{
				npc.PlayMeleeHitSound();
			}
		}
	}

	if (gameTime > npc.m_flNextMeleeAttack)
	{
		if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}

public Action CHIMERA_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CHIMERA npc = view_as<CHIMERA>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void CHIMERA_NPCDeath(int entity)
{
	CHIMERA npc = view_as<CHIMERA>(entity);
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
	npc.StopPassiveSound();

}

bool CHIMERA_timeBased(int iNPC)
{

	CHIMERA npc = view_as<CHIMERA>(iNPC);
	//idk it never was in a bracket
	if(npc.m_flBatteryLeftBlade && npc.m_flBatteryLeftBlade < GetGameTime())
	{
		npc.m_flBatteryLeftBlade = 0.0;
		CPrintToChatAll("{crimson}C.H.I.M.E.R.A. 's Expidonsan blade ran out of battery.");
		float flPos[3];
		float flAng[3];
		int Particle_1;
		npc.GetAttachment("flag", flPos, flAng);
		Particle_1 = ParticleEffectAt_Parent(flPos, "drg_cow_explosion_sparkles_blue", npc.index, "flag", {0.0,0.0,0.0});
		CreateTimer(0.75, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
		npc.PlayBatteryEmpty();
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
	}
}
bool CHIMERA_LoseConditions(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{blue}C.A.T{default}: Intruders taken care of.");
		return true;
	}
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{blue}C.A.T{default}: We hope your stay at Aperture was pleasant!");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return true;
	}

	return false;
}