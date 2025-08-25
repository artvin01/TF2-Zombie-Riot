#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_domination02.mp3",
	"vo/sniper_domination03.mp3",
	"vo/sniper_domination06.mp3",
	"vo/sniper_domination07.mp3",
	"vo/sniper_domination08.mp3",
	"vo/sniper_domination09.mp3",
	"vo/sniper_domination10.mp3",
	"vo/sniper_domination16.mp3",
	"vo/sniper_domination21.mp3",
	"vo/sniper_domination23.mp3",
	"vo/sniper_domination24.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_MeleeSwitchSounds[][] = {
	"vo/sniper_meleedare01.mp3",
	"vo/sniper_meleedare02.mp3",
	"vo/sniper_meleedare03.mp3",
	"vo/sniper_meleedare04.mp3",
	"vo/sniper_meleedare05.mp3",
	"vo/sniper_meleedare06.mp3",
	"vo/sniper_meleedare07.mp3",
	"vo/sniper_meleedare08.mp3",
	"vo/sniper_meleedare09.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/bow_shoot.wav"
};

static const char g_SuperJumpSounds[][] = {
	"vo/sniper_jaratetoss01.mp3",
	"vo/sniper_jaratetoss02.mp3",
	"vo/sniper_specialcompleted11.mp3",
	"vo/sniper_specialcompleted19.mp3"
};

static bool Melee_Kukri;
static bool Melee_Shiv;
static bool Melee_Bushwacka;

void ChristianBrutalSniper_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeSwitchSounds)); i++) { PrecacheSound(g_MeleeSwitchSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSounds)); i++) { PrecacheSound(g_SuperJumpSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Christian Brutal Sniper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_christianbrutalsniper");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheSoundCustom("#zombiesurvival/rogue3/cbs_theme.mp3");
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChristianBrutalSniper(vecPos, vecAng, team);
}
methodmap ChristianBrutalSniper < CClotBody
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
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayMeleeSwitchSound() 
	{
		EmitSoundToAll(g_MeleeSwitchSounds[GetRandomInt(0, sizeof(g_MeleeSwitchSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound() 
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlaySuperJumpSound() 
	{
		EmitSoundToAll(g_SuperJumpSounds[GetRandomInt(0, sizeof(g_SuperJumpSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	
	public ChristianBrutalSniper(float vecPos[3], float vecAng[3], int ally)
	{
		ChristianBrutalSniper npc = view_as<ChristianBrutalSniper>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "5000", ally));
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ChristianBrutalSniper_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ChristianBrutalSniper_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ChristianBrutalSniper_ClotThink);

		//CBS Music (STRAIGHT BANGIN!!!)
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/rogue3/cbs_theme.mp3");
		music.Time = 131; //no loop usually 43 loop tho
		music.Volume = 1.25;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "{redsunsecond}The Millionaire's Holiday");
		strcopy(music.Artist, sizeof(music.Artist), "{redsunsecond}Combustible Edison");
		Music_SetRaidMusic(music);
		
		Melee_Kukri = true;
		Melee_Shiv = false;
		Melee_Bushwacka = false;
		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;

		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 10.0;	//Switch to Shiv
		npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 20.0; 	//Switch to Bushwacka
		npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 30.0; 	//Switch back to Kukri
		npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + GetRandomFloat(15.0, 25.0); 	//Switch to bow randomly
		npc.m_flAbilityOrAttack5 = GetGameTime(npc.index) + GetRandomFloat(20.0, 30.0); 	//Superjump
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_machete/c_machete.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/sniper/hwn_sniper_hat.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/sniper/hwn_sniper_misc1.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/fall2013_kyoto_rider/fall2013_kyoto_rider.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/xms2013_sniper_beard/xms2013_sniper_beard.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void ChristianBrutalSniper_ClotThink(int iNPC)
{
	ChristianBrutalSniper npc = view_as<ChristianBrutalSniper>(iNPC);
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

	//Swtich to Shiv
	if(npc.m_flAbilityOrAttack0)
	{
		if(npc.m_flAbilityOrAttack0 < GetGameTime(npc.index))
		{
			if(!IsValidEntity(npc.m_iWearable1))
			{
				if(Melee_Kukri && !Melee_Bushwacka)
				{
					npc.PlayMeleeSwitchSound();
				}
			}
			Melee_Kukri = false;
			Melee_Shiv = true;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_wood_machete/c_wood_machete.mdl");
		}
	}
	//Swtich to Peniswacka
	if(npc.m_flAbilityOrAttack1)
	{
		if(npc.m_flAbilityOrAttack1 < GetGameTime(npc.index))
		{
			if(!IsValidEntity(npc.m_iWearable1))
			{
				if(Melee_Shiv && !Melee_Kukri)
				{
					npc.PlayMeleeSwitchSound();
				}
			}
			Melee_Kukri = false;
			Melee_Shiv = false;
			Melee_Bushwacka = true;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.SetActivity("ACT_MP_RUN_MELEE");			
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
		}
	}
	//Switch back to Kukri
	if(npc.m_flAbilityOrAttack2)
	{
		if(npc.m_flAbilityOrAttack2 < GetGameTime(npc.index))
		{
			/*
			if(!IsValidEntity(npc.m_iWearable1))
			{
				if(Melee_Bushwacka && !Melee_Kukri && !Melee_Shiv)
				{
					npc.PlayMeleeSwitchSound();
				}
			}
			*/
			Melee_Kukri = true;
			Melee_Shiv = false;
			Melee_Bushwacka = false;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_machete/c_machete.mdl");

			npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 10.0;	//Reset cooldowns
			npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 20.0; 	//Reset cooldowns
			npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 30.0; 	//Reset cooldowns
		}
	}
	//Switch to Bow at random
	if(npc.m_flAbilityOrAttack3)
	{
		if(npc.m_flAbilityOrAttack3 < GetGameTime(npc.index))
		{
			Melee_Kukri = false;
			Melee_Shiv = false;
			Melee_Bushwacka = false;
			npc.m_iAttacksTillReload = 6;
			npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + GetRandomFloat(15.0, 25.0);
		}
	}
	//Superjump
	if(npc.m_flAbilityOrAttack5)
	{
		if(npc.m_flAbilityOrAttack5 < GetGameTime(npc.index))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			vecTarget[2] += 300.0;
			PluginBot_Jump(npc.index, vecTarget);
			npc.m_flAbilityOrAttack5 = GetGameTime(npc.index) + GetRandomFloat(20.0, 30.0);
			npc.PlaySuperJumpSound();
		}
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
		ChristianBrutalSniperSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ChristianBrutalSniper_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChristianBrutalSniper npc = view_as<ChristianBrutalSniper>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ChristianBrutalSniper_NPCDeath(int entity)
{
	ChristianBrutalSniper npc = view_as<ChristianBrutalSniper>(entity);
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

void ChristianBrutalSniperSelfDefense(ChristianBrutalSniper npc, float gameTime, int target, float distance)
{
	if(npc.m_iAttacksTillReload == 0)
	{
		if(npc.m_iChanged_WalkCycle != 0)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_machete/c_machete.mdl");
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 0;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
		}
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
						float damageDealt = 1000.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 5.0;


						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

						if(Melee_Kukri)
						{
							npc.PlayMeleeHitSound(); //Need to play melee sound manually in these booleans
							npc.m_iOverlordComboAttack++;
							if(npc.m_iOverlordComboAttack >= 1)
							{
								f_AttackSpeedNpcIncrease[npc.index] = 0.80;
							}
							if(npc.m_iOverlordComboAttack >= 2)
							{
								f_AttackSpeedNpcIncrease[npc.index] = 0.60;
							}
							if(npc.m_iOverlordComboAttack >= 3)
							{
								f_AttackSpeedNpcIncrease[npc.index] = 0.40;
							}
							if(npc.m_iOverlordComboAttack >= 4)
							{
								f_AttackSpeedNpcIncrease[npc.index] = 0.20;
							}
							if(npc.m_iOverlordComboAttack >= 5)
							{
								f_AttackSpeedNpcIncrease[npc.index] = 0.05;
							}
						}
						else
						{
							f_AttackSpeedNpcIncrease[npc.index] = 1.0;
						}

						if(Melee_Shiv)
						{
							npc.PlayMeleeHitSound();	//Need to play melee sound manually in these booleans
							StartBleedingTimer(target, npc.index, 10.0, 50, -1, DMG_TRUEDAMAGE, 0);
						}

						if(Melee_Bushwacka)
						{
							npc.PlayMeleeHitSound();	//Need to play melee sound manually in these booleans
							ApplyStatusEffect(npc.index, target, "Archo's Posion", 5.0);
						}

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
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
				}
			}
		}
	}
	if(npc.m_iAttacksTillReload >= 1)
	{

		if(npc.m_iChanged_WalkCycle != 1)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_bow/c_bow.mdl");
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_ITEM2");
			npc.StartPathing();
		}	

		for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
		{
			if(IsValidEntity(EnemyLoop) && b_IsAProjectile[EnemyLoop] && GetTeam(npc.index) != GetTeam(EnemyLoop))
			{
				float vecTarget[3]; WorldSpaceCenter(EnemyLoop, vecTarget );
			
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
				{
					RemoveEntity(EnemyLoop);
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", false);
					npc.PlayRangedSound();
					npc.FaceTowards(vecTarget, 20000.0);
					int projectile = npc.FireArrow(vecTarget, 750.0, 1200.0);
					float ang_Look[3];
					GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
					Initiate_HomingProjectile(projectile,
					npc.index,
					200.0,			// float lockonAngleMax,
					100.0,				//float homingaSec,
					false,				// bool LockOnlyOnce,
					true,				// bool changeAngles,
					ang_Look);// float AnglesInitiate[3]);
					npc.m_iAttacksTillReload--;

				}
			}
		}

		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", false);
					npc.m_iTarget = Enemy_I_See;
					npc.PlayRangedSound();
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						int projectile = npc.FireArrow(vecTarget, 750.0, 1200.0);
						float ang_Look[3];
						GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
						Initiate_HomingProjectile(projectile,
						npc.index,
						200.0,			// float lockonAngleMax,
						100.0,				//float homingaSec,
						false,				// bool LockOnlyOnce,
						true,				// bool changeAngles,
						ang_Look);// float AnglesInitiate[3]);
						npc.m_iAttacksTillReload--;

					}
					delete swingTrace;
				}
			}
		}
	}
}