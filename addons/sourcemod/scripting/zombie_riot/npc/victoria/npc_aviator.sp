#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/engineer_negativevocalization01.mp3",
	")vo/engineer_negativevocalization02.mp3",
	")vo/engineer_negativevocalization03.mp3",
	")vo/engineer_negativevocalization04.mp3",
	")vo/engineer_negativevocalization05.mp3",
	")vo/engineer_negativevocalization06.mp3",
	")vo/engineer_negativevocalization07.mp3",
	")vo/engineer_negativevocalization08.mp3",
	")vo/engineer_negativevocalization09.mp3",
	")vo/engineer_negativevocalization10.mp3",
	")vo/engineer_negativevocalization11.mp3",
	")vo/engineer_negativevocalization12.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_mvm_mannhattan_gate_atk01.mp3",
	"vo/engineer_mvm_mannhattan_gate_atk02.mp3",
	"vo/engineer_mvm_mannhattan_gate_atk03.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/frontier_justice_shoot.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_suitup[][] = {
	"mvm/mvm_tank_start.wav",
};
void Aviator_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_suitup)); i++) { PrecacheSound(g_suitup[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Aviator");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aviator");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_aviator");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static int I_cant_do_this_all_day[MAXENTITIES];
static float Delay_Attribute[MAXENTITIES];

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Aviator(vecPos, vecAng, team);
}
methodmap Aviator < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	
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
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlaySuitUpSound() 
	{
		EmitSoundToAll(g_suitup[GetRandomInt(0, sizeof(g_suitup) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_suitup[GetRandomInt(0, sizeof(g_suitup) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}

	
	public Aviator(float vecPos[3], float vecAng[3], int ally)
	{
		Aviator npc = view_as<Aviator>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "50000", ally));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		npc.m_iChanged_WalkCycle = 2;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Aviator_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Aviator_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Aviator_ClotThink);
		
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		I_cant_do_this_all_day[npc.index] = 0;
		Delay_Attribute[npc.index] = 0.0;
		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_frontierjustice/c_frontierjustice_xmas.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/jul13_scrap_reserve/jul13_scrap_reserve.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/sbox2014_trenchers_tunic/sbox2014_trenchers_tunic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/sbox2014_scotch_saver/sbox2014_scotch_saver.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum20_spectre_cles_style1/sum20_spectre_cles_style1_engineer.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec23_clue_hairdo_style2/dec23_clue_hairdo_style2.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/engineer/tw_engineerbot_armor/tw_engineerbot_armor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		

		return npc;
	}
}

public void Aviator_ClotThink(int iNPC)
{
	Aviator npc = view_as<Aviator>(iNPC);
	float gametime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gametime)
		return;
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gametime)
		return;
	npc.m_flNextThinkTime = gametime + 0.1;

	if(npc.m_flGetClosestTargetTime <gametime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gametime + GetRandomRetargetTime();
	}

	if(npc.m_flAngerDelay < gametime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_drg_melee");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				Delay_Attribute[npc.index] = gametime + 2.0;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gametime)
				{
					npc.PlaySuitUpSound();
					int Health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index))* 1.5);	

					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, pos, 200.0, _, _, true, _, false, _, NPC_Go_away);
					int entity = NPC_CreateByName("npc_ironshield", -1, pos, ang, GetTeam(npc.index));
					if(entity > MaxClients)
					{
						if(GetTeam(npc.index) != TFTeam_Red)
							Zombies_Currently_Still_Ongoing++;
						
						SetEntProp(entity, Prop_Data, "m_iHealth", Health);
						SetEntProp(entity, Prop_Data, "m_iMaxHealth", Health);
						
						fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index]* 0.90;
						fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index]* 0.90;
						fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
						fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index] * 1.1;
						b_StaticNPC[entity] = b_StaticNPC[npc.index];
						if(b_StaticNPC[entity])
							AddNpcToAliveList(entity, 1);
						b_thisNpcIsABoss[entity] = b_thisNpcIsABoss[npc.index];
						b_thisNpcHasAnOutline[entity] = b_thisNpcHasAnOutline[npc.index];
						view_as<CClotBody>(entity).m_iBleedType = BLEEDTYPE_METAL;
					}
					I_cant_do_this_all_day[npc.index]=0;
					b_NpcForcepowerupspawn[npc.index] = 0;
					i_RaidGrantExtra[npc.index] = 0;
					b_DissapearOnDeath[npc.index] = true;
					b_DoGibThisNpc[npc.index] = true;
					SmiteNpcToDeath(npc.index);
				}
			}
		}
		return;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = AviatorSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

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

	AviatorAnimationChange(npc);
	npc.PlayIdleAlertSound();
}

public Action Aviator_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Aviator npc = view_as<Aviator>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Aviator_NPCDeath(int entity)
{
	Aviator npc = view_as<Aviator>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
		
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
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

void AviatorAnimationChange(Aviator npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
		npc.m_iChanged_WalkCycle = -1;
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					ResetAviatorWeapon(npc, 1);
					SetVariantInt(1);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					ResetAviatorWeapon(npc, 1);
					SetVariantInt(1);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					ResetAviatorWeapon(npc, 0);
					SetVariantInt(3);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					ResetAviatorWeapon(npc, 0);
					SetVariantInt(3);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
					npc.StartPathing();
				}	
			}
		}
	}

}

int AviatorSelfDefense(Aviator npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		npc.i_GunMode = 0;
		if(gameTime > npc.m_flAttackHappens)
		{
			npc.m_flAttackHappens = 0.0;
			Handle swingTrace;
			float WorldSpaceVec[3]; WorldSpaceCenter(target, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 15000.0);
			if(npc.DoSwingTrace(swingTrace, target, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				int target_hit = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(target_hit > 0) 
				{
					float damageDealt = 100.0; //Extreme melee damage
					if(ShouldNpcDealBonusDamage(target_hit))
						damageDealt *= 10.0; //basically oneshots buildings or atleast deals heavy damage
						
					SDKHooks_TakeDamage(target_hit, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);									
							
				
					npc.PlayMeleeHitSound();
					if(target_hit <= MaxClients)
						if(!HasSpecificBuff(target, "Fluid Movement"))
							TF2_StunPlayer(target, 1.5, 0.5, TF_STUNFLAG_SLOWDOWN);
				} 
			}
			delete swingTrace;
		}
		//A melee attack is happening, lets just follow the target_hit
		return 0;
	}

	//This ranged unit is more of an intruder, so we will get whatever enemy its pathing
	if(npc.m_flNextMeleeAttack < gameTime && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
	{
		//close enough to concider as a melee range attack.
		npc.i_GunMode = 0;
		//We can melee!
		//Are we close enough?
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.35))
		{
			npc.m_flAttackHappens = gameTime + 0.25;
			npc.m_flDoingAnimation = gameTime + 0.25;
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
			npc.m_flNextMeleeAttack = gameTime + 2.00;
			npc.PlayMeleeSound();
			//We are close enough to melee attack, lets melee.
		}
		//no? Chase target
		return 0;
	}
	npc.i_GunMode = 1;
	//isnt melee anymore
	if((distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.5)) && gameTime > npc.m_flNextRangedAttack)
	{	
		if(Can_I_See_Enemy_Only(npc.index, target))
		{
			int Enemy_I_See;
									
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_pda_engineer/c_pda_engineer.mdl");
				SetVariantString("0.8");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
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

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 60.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 7.5;

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
			npc.m_flNextRangedAttack = gameTime + 1.0;
		}
	}
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
	{
		//target is too far, try to close in
		return 0;
	}
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, target))
		{
			//target is too close, try to keep distance
			return 1;
		}
	}
	//Chase target
	return 0;
}


void ResetAviatorWeapon(Aviator npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_frontierjustice/c_frontierjustice_xmas.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 0:
		{
			npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_sledgehammer/c_sledgehammer.mdl");
			SetVariantString("0.8");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
	}
}

static void NPC_Go_away(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && !IsValidClient(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		Custom_Knockback(npc.index, victim, 600.0, true);
	}
}