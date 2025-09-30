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
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_ZapAttackSounds[][] = {
	"npc/assassin/ball_zap1.wav",
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

int i_DiversioAntiCheese_PreviousEnemy[MAXENTITIES];
int i_DiversioAntiCheese_Tolerance[MAXENTITIES];

float LastSpawnDiversio;

static int NPCId;

void Diversionistico_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ZapAttackSounds)); i++) { PrecacheSound(g_ZapAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackBackstabSounds)); i++) { PrecacheSound(g_MeleeAttackBackstabSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/spy.mdl");
	LastSpawnDiversio = 0.0;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Diversionistico");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_diversionistico");
	strcopy(data.Icon, sizeof(data.Icon), "diversionistico");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int DiversionisticoID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Diversionistico(vecPos, vecAng, team, data);
}

void DiversionSpawnNpcReset(int index)
{
	i_DiversioAntiCheese_PreviousEnemy[index] = 0;
	i_DiversioAntiCheese_Tolerance[index] = 0;
}

methodmap Diversionistico < CClotBody
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
	public void PlayZapSound()
	{
		EmitSoundToAll(g_ZapAttackSounds[GetRandomInt(0, sizeof(g_ZapAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeBackstabSound(int target)
	{
		EmitSoundToAll(g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		if(target <= MaxClients)
		{
			EmitSoundToClient(target, g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], target, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public Diversionistico(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Diversionistico npc = view_as<Diversionistico>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "750", ally, false, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 1.0, Element_Chaos);
		

		func_NPCDeath[npc.index] = Diversionistico_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Diversionistico_OnTakeDamage;
		func_NPCThink[npc.index] = Diversionistico_ClotThink;
		
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		b_TryToAvoidTraverse[npc.index] = true;
		DiversionSpawnNpcReset(npc.index);
		
		bool final = StrContains(data, "spy_duel") != -1;
		
		if(final)
		{
			b_FaceStabber[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 1;
		}

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/dec15_chicago_overcoat/dec15_chicago_overcoat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);


		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 500.0);

		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 500.0);

		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 500.0);

		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 500.0);
		
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 500.0);

		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("player/spy_uncloak_feigndeath.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("player/spy_uncloak_feigndeath.wav", _, _, _, _, 1.0);	
				for(int client_check=1; client_check<=MaxClients; client_check++)
				{
					if(IsClientInGame(client_check) && !IsFakeClient(client_check))
					{
						SetGlobalTransTarget(client_check);
						ShowGameText(client_check, "voice_player", 1, "%t", "Diversionistico Spawn");
					}
				}
			}
			LastSpawnDiversio = GetGameTime() + 20.0;
			TeleportDiversioToRandLocation(npc.index);
		}
		return npc;
	}
}

public void Diversionistico_ClotThink(int iNPC)
{
	Diversionistico npc = view_as<Diversionistico>(iNPC);
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
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		int AntiCheeseReply = 0;

		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			b_TryToAvoidTraverse[npc.index] = false;
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			vPredictedPos = GetBehindTarget(npc.m_iTarget, 40.0 ,vPredictedPos);
			AntiCheeseReply = DiversionAntiCheese(npc.m_iTarget, npc.index, vPredictedPos);
			b_TryToAvoidTraverse[npc.index] = true;
			if(AntiCheeseReply == 0)
			{
				if(!npc.m_bPathing)
					npc.StartPathing();

				npc.SetGoalVector(vPredictedPos, true);
			}
			else if(AntiCheeseReply == 1)
			{
				if(npc.m_bPathing)
					npc.StopPathing();
			}
		}
		else 
		{
			DiversionCalmDownCheese(npc.index);
			if(!npc.m_bPathing)
				npc.StartPathing();

			npc.SetGoalEntity(npc.m_iTarget);
		}
		switch(AntiCheeseReply)
		{
			case 0:
			{
				DiversionisticoSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
			}
			case 1:
			{
				npc.m_flAttackHappens = 0.0;
				DiversionisticoSelfDefenseRanged(npc,GetGameTime(npc.index), npc.m_iTarget); 
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	npc.PlayIdleAlertSound();
}

public Action Diversionistico_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Diversionistico npc = view_as<Diversionistico>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if(i_RaidGrantExtra[victim])
	{
		if(!i_HasBeenBackstabbed[victim])
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	
	return Plugin_Changed;
}

public void Diversionistico_NPCDeath(int entity)
{
	Diversionistico npc = view_as<Diversionistico>(entity);
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
void DiversionisticoSelfDefenseRanged(Diversionistico npc, float gameTime, int target)
{
	float WorldSpaceVec[3]; WorldSpaceCenter(target, WorldSpaceVec);
	npc.FaceTowards(WorldSpaceVec, 15000.0);
	if(gameTime > npc.m_flNextRangedAttack)
	{
		npc.PlayZapSound();
		npc.AddGesture("ACT_MP_THROW");
		npc.m_flDoingAnimation = gameTime + 0.25;
		npc.m_flNextRangedAttack = gameTime + 1.2;
		float damageDealt = 85.0;
		SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, WorldSpaceVec);
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);

		npc.m_iWearable5 = ConnectWithBeam(npc.m_iWearable1, target, 100, 100, 250, 3.0, 3.0, 1.35, LASERBEAM);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iWearable5), TIMER_FLAG_NO_MAPCHANGE);
	}
}
void DiversionisticoSelfDefense(Diversionistico npc, float gameTime, int target, float distance)
{
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
				if(BackstabDone || IsBehindAndFacingTarget(npc.index, npc.m_iTarget) && !NpcStats_IsEnemySilenced(npc.index))
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
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_, _, _, 1)) //Ignore barricades
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 50.0;

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
						damageDealt *= 3.0;
					}
					else if(i_RaidGrantExtra[npc.index])
					{
						damageDealt *= 0.5;
					}

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}
}



int TeleportDiversioToRandLocation(int iNPC, bool RespectOutOfBounds = false, float MaxSpawnDist = 1250.0, float MinSpawnDist = 500.0, bool forceSpawn = false, bool NeedLOSPlayer = false, float VectorSave[3] = {0.0,0.0,0.0})
{
	if(!forceSpawn && zr_disablerandomvillagerspawn.BoolValue && !DisableRandomSpawns)
		return 3;
	float f3_VecAbs[3];
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", f3_VecAbs);
	Diversionistico npc = view_as<Diversionistico>(iNPC);
	for( int loop = 1; loop <= 150; loop++ ) 
	{
		float AproxRandomSpaceToWalkTo[3];
		CNavArea RandomArea;
		
		if(!Rogue_Mode())
		{
			RandomArea = PickRandomArea();	
		}
		else
		{
			RandomArea = GetRandomNearbyArea(f3_VecAbs, DomeRadiusGlobal());
			NeedLOSPlayer = true;
			//it sucks but its needed so nothing breaks.
		}
			
		if(RandomArea == NULL_AREA) 
			break; //No nav?

		int NavAttribs = RandomArea.GetAttributes();
		if(NavAttribs & NAV_MESH_AVOID)
		{
			continue;
		}

		RandomArea.GetCenter(AproxRandomSpaceToWalkTo);

		//for rouge2 and 3
		if(Dome_PointOutside(AproxRandomSpaceToWalkTo))
			continue;

		bool DoNotTeleport = false;
		int WasTooFarAway = 0;
		int PlayersCount = 0;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && IsPlayerAlive(client_check) && GetClientTeam(client_check)==2 && TeutonType[client_check] == TEUTON_NONE && dieingstate[client_check] == 0)
			{		
				PlayersCount += 1;
				float f3_PositionTemp[3];
				GetEntPropVector(client_check, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
				float flDistanceToTarget = GetVectorDistance(AproxRandomSpaceToWalkTo, f3_PositionTemp, true);	
				if(flDistanceToTarget > (MaxSpawnDist * MaxSpawnDist))
				{
					WasTooFarAway += 1;
				}
				if(flDistanceToTarget < (MinSpawnDist * MinSpawnDist))
				{
					DoNotTeleport = true;
					break;
				}
			}
		}
		if(DoNotTeleport)
			continue;

		if(WasTooFarAway >= PlayersCount) //they arent even near to being close to anyone.
			continue;

		if(RespectOutOfBounds && IsPointOutsideMap(AproxRandomSpaceToWalkTo))
			continue;
		static float hullcheckmaxs_Player_Again[3];
		static float hullcheckmins_Player_Again[3];
		if(b_IsGiant[npc.index])
		{
			hullcheckmaxs_Player_Again = view_as<float>( { 30.0, 30.0, 120.0 } );
			hullcheckmins_Player_Again = view_as<float>( { -30.0, -30.0, 0.0 } );	
		}			
		else
		{
			hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );		
		}
		if(IsBoxHazard(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again)) //Retry.
			continue;

		AproxRandomSpaceToWalkTo[2] += 1.0;
		if(IsSpaceOccupiedIgnorePlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
			continue;
			
		if(IsBoxHazard(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again)) //Retry.
			continue;

		if(NeedLOSPlayer)
		{
			DoNotTeleport = true;
			float f3_PositionTemp[3];
			f3_PositionTemp = AproxRandomSpaceToWalkTo;
			f3_PositionTemp[2] += 40.0;
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && IsPlayerAlive(client_check) && GetClientTeam(client_check)==2 && TeutonType[client_check] == TEUTON_NONE && dieingstate[client_check] == 0)
				{		
					if(Can_I_See_Enemy_Only(client_check,client_check, f3_PositionTemp))
					{
						DoNotTeleport = false;
						break;
					}
				}
			}
			//fail, try again.
			if(DoNotTeleport)
				continue;
		}
		
		//everything is valid, now we check if we are too close to the enemy, or too far away.
		if(VectorSave[1] == 0.0)
			TeleportEntity(npc.index, AproxRandomSpaceToWalkTo);

		VectorSave = AproxRandomSpaceToWalkTo;
		RemoveSpawnProtectionLogic(npc.index, true);
		return 1;
	}
	return 2;
}

void DiversionCalmDownCheese(int npcindex)
{
	i_DiversioAntiCheese_Tolerance[npcindex] -= 2;

	if(i_DiversioAntiCheese_Tolerance[npcindex] < 0)
		i_DiversioAntiCheese_Tolerance[npcindex] = 0;
}
int DiversionAntiCheese(int enemy, int npcindex, float vPredictedPos[3])
{
	int oldEnemy = EntRefToEntIndex(i_DiversioAntiCheese_PreviousEnemy[npcindex]);
	if(oldEnemy != enemy)
	{
		i_DiversioAntiCheese_PreviousEnemy[npcindex] = EntIndexToEntRef(enemy);
		i_DiversioAntiCheese_Tolerance[npcindex] = 0;
	}

	static float hullcheckmaxs_Player_Again[3];
	static float hullcheckmins_Player_Again[3];
	hullcheckmaxs_Player_Again = view_as<float>( { 10.0, 10.0, 40.0 } ); //Is the players back inside a wall? Most realistic check i could find.
	hullcheckmins_Player_Again = view_as<float>( { -10.0, -10.0, 20.0 } );	
	if(IsSpaceOccupiedIgnorePlayers(vPredictedPos, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npcindex))
	{
		i_DiversioAntiCheese_Tolerance[npcindex] += 1;
	}
	else
	{
		i_DiversioAntiCheese_Tolerance[npcindex] -= 2;
	}

	if(i_DiversioAntiCheese_Tolerance[npcindex] > 15)
		i_DiversioAntiCheese_Tolerance[npcindex] = 15;

	if(i_DiversioAntiCheese_Tolerance[npcindex] < 0)
		i_DiversioAntiCheese_Tolerance[npcindex] = 0;

	if(i_DiversioAntiCheese_Tolerance[npcindex] > 10)
	{
		return 1;
	}
	return 0;
}