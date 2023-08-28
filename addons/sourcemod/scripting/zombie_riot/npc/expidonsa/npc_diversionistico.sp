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

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeAttackBackstabSounds[][] = {
	"player/spy_shield_break.wav",
};


float LastSpawnDiversio;

void Diversionistico_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackBackstabSounds)); i++) { PrecacheSound(g_MeleeAttackBackstabSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/spy.mdl");
	LastSpawnDiversio = 0.0;
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

	public Diversionistico(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Diversionistico npc = view_as<Diversionistico>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "750", ally, false, false, true));
		
		i_NpcInternalId[npc.index] = EXPIDONSA_DIVERSIONISTICO;
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_Think, Diversionistico_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		b_TryToAvoidTraverse[npc.index] = true;
		
		
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
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
	
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			b_TryToAvoidTraverse[npc.index] = false;
			vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			vPredictedPos = GetBehindTarget(npc.m_iTarget, 40.0 ,vPredictedPos);
			b_TryToAvoidTraverse[npc.index] = true;
			NPC_SetGoalVector(npc.index, vPredictedPos, true);

		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		DiversionisticoSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
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
	SDKUnhook(npc.index, SDKHook_Think, Diversionistico_ClotThink);
		
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

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
			
			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.PlayMeleeSound();
				if(IsBehindAndFacingTarget(npc.index, npc.m_iTarget) && !NpcStats_IsEnemySilenced(npc.index))
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
						npc.PlayMeleeBackstabSound(target);
						damageDealt *= 3.0;
					}

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
				delete swingTrace;
			}
		}
	}
}



void TeleportDiversioToRandLocation(int iNPC)
{
	Diversionistico npc = view_as<Diversionistico>(iNPC);
	for( int loop = 1; loop <= 500; loop++ ) 
	{
		float AproxRandomSpaceToWalkTo[3];
		CNavArea RandomArea = PickRandomArea();	
			
		if(RandomArea == NULL_AREA) 
			break; //No nav?

		RandomArea.GetCenter(AproxRandomSpaceToWalkTo);
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
				if(flDistanceToTarget > (1250.0 * 1250.0))
				{
					WasTooFarAway += 1;
				}
				if(flDistanceToTarget < (500.0 * 500.0))
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

		AproxRandomSpaceToWalkTo[2] += 20.0;
		static float hullcheckmaxs_Player_Again[3];
		static float hullcheckmins_Player_Again[3];
		hullcheckmaxs_Player_Again = view_as<float>( { 30.0, 30.0, 82.0 } ); //Fat
		hullcheckmins_Player_Again = view_as<float>( { -30.0, -30.0, 0.0 } );	
		if(IsSpaceOccupiedIgnorePlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
			continue;
			
		if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
			continue;
		
		AproxRandomSpaceToWalkTo[2] += 18.0;
		if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
			continue;
		
		AproxRandomSpaceToWalkTo[2] -= 18.0;
		AproxRandomSpaceToWalkTo[2] -= 18.0;
		AproxRandomSpaceToWalkTo[2] -= 18.0;
		if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
			continue;
		
		AproxRandomSpaceToWalkTo[2] += 18.0;
		AproxRandomSpaceToWalkTo[2] += 18.0;
		//everything is valid, now we check if we are too close to the enemy, or too far away.
		TeleportEntity(npc.index, AproxRandomSpaceToWalkTo);
		break;
	}
}

float[] GetBehindTarget(int target, float Distance, float origin[3])
{
	float VecForward[3];
	float vecRight[3];
	float vecUp[3];
	
	GetVectors(target, VecForward, vecRight, vecUp); //Sorry i dont know any other way with this :(
	
	float vecSwingEnd[3];
	vecSwingEnd[0] = origin[0] - VecForward[0] * (Distance);
	vecSwingEnd[1] = origin[1] - VecForward[1] * (Distance);
	vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

	return vecSwingEnd;
}