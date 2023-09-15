#pragma semicolon 1
#pragma newdecls required

static const char SoundMoabHit[][] =
{
	"zombie_riot/btd/hitmoab01.wav",
	"zombie_riot/btd/hitmoab02.wav",
	"zombie_riot/btd/hitmoab03.wav",
	"zombie_riot/btd/hitmoab04.wav"
};

static const char SoundMoabPop[][] =
{
	"zombie_riot/btd/moabdestroyed01.wav",
	"zombie_riot/btd/moabdestroyed02.wav",
	"zombie_riot/btd/moabdestroyed03.wav",
	"zombie_riot/btd/moabdestroyed04.wav"
};

static float MoabSpeed()
{
	if(CurrentRound < 80)
		return 200.0;
	
	if(CurrentRound < 100)
		return 200.0 * (1.0 + (CurrentRound - 79) * 0.02);
	
	return 200.0 * (1.0 + (CurrentRound - 70) * 0.02);
}

static int MoabHealth(bool fortified)
{
	float value = 130000.0;	// 200x3 + 700 RGB
	value *= 0.5;
	
	if(fortified)
		value *= 2.0;
	
	if(CurrentRound > 123)
	{
		value *= 1.05 + (CurrentRound - 106) * 0.15;
	}
	else if(CurrentRound > 99)
	{
		value *= 1.0 + (CurrentRound - 71) * 0.05;
	}
	else if(CurrentRound > 79)
	{
		value *= 1.0 + (CurrentRound - 79) * 0.02;
	}
	
	return RoundFloat(value) + (Bloon_Health(fortified, Bloon_Ceramic) * 9);	// 104x3x3 RGB
}

void Bfb_MapStart()
{
	PrecacheModel("models/zombie_riot/btd/bfb.mdl");
}

methodmap BFB < CClotBody
{
	property bool m_bFortified
	{
		public get()
		{
			return this.m_bLostHalfHealth;
		}
		public set(bool value)
		{
			this.m_bLostHalfHealth = value;
		}
	}
	public void PlayHitSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundMoabHit) - 1);
		EmitCustomToAll(SoundMoabHit[sound], this.index, SNDCHAN_VOICE, 80, _, 2.0);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundMoabPop) - 1);
		EmitCustomToAll(SoundMoabPop[sound], this.index, SNDCHAN_AUTO, 80, _, 2.0);
	}
	public int UpdateBloonOnDamage()
	{
		int type = 4 - (GetEntProp(this.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
		if(type == -1)
			type = 0;
		
		SetEntProp(this.index, Prop_Send, "m_nSkin", type);
	}
	public BFB(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool fortified = StrContains(data, "f") != -1;
		
		char buffer[16];
		IntToString(MoabHealth(fortified), buffer, sizeof(buffer));
		
		BFB npc = view_as<BFB>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bfb.mdl", "1.0", buffer, ally, false, true));
		
		i_NpcInternalId[npc.index] = BTD_BFB;
		i_NpcWeight[npc.index] = 3;
		KillFeed_SetKillIcon(npc.index, "vehicle");
		
		int iActivity = npc.LookupActivity("ACT_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = NOTHING;	
		npc.m_iNpcStepVariation = NOTHING;	
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = false;
		
		npc.m_flSpeed = MoabSpeed();
		npc.m_bFortified = fortified;
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bfb_ClotDamagedPost);
		SDKHook(npc.index, SDKHook_Think, Bfb_ClotThink);
		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Bfb_ClotThink(int iNPC)
{
	BFB npc = view_as<BFB>(iNPC);
	
	if(npc.m_bFortified)
	{
		SetVariantInt(1);
		AcceptEntityInput(iNPC, "SetBodyGroup");
	}
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
													
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			//float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			NPC_SetGoalVector(npc.index, PredictSubjectPosition(npc, PrimaryThreatIndex));
		}
		else
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < 20000)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				
				Handle swingTrace;
				if(npc.DoAimbotTrace(swingTrace, PrimaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(npc.m_bFortified)
						{
							if(!ShouldNpcDealBonusDamage(target))
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 20.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0 * 2.0, DMG_CLUB, -1, _, vecHit);
							}
						}
						else
						{
							if(!ShouldNpcDealBonusDamage(target))
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 30.0, DMG_CLUB, -1, _, vecHit);
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0 * 2.0, DMG_CLUB, -1, _, vecHit);
							}
						}
					}
					
					delete swingTrace;
				}
			}
		}
		
		npc.StartPathing();
		
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Bfb_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	BFB npc = view_as<BFB>(victim);
	npc.PlayHitSound();
	return Plugin_Changed;
}

public void Bfb_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	BFB npc = view_as<BFB>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bfb_NPCDeath(int entity)
{
	BFB npc = view_as<BFB>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bfb_ClotDamagedPost);
	
	SDKUnhook(npc.index, SDKHook_Think, Bfb_ClotThink);
	
	float pos[3], angles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	int spawn_index = Npc_Create(BTD_MOAB, -1, pos, angles, GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2, npc.m_bFortified ? "f" : "");
	if(spawn_index > MaxClients)
		Zombies_Currently_Still_Ongoing += 1;
}