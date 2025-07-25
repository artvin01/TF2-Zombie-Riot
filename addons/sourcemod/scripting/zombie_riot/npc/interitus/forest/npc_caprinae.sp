#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] =
{
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/demoman_battlecry01.mp3",
	"vo/demoman_battlecry02.mp3",
	"vo/demoman_battlecry03.mp3",
	"vo/demoman_battlecry04.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"misc/halloween/hwn_dance_howl.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav"
};

static int NPCId;

void CaprinaeOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Caprinae");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_caprinae");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int IsCaprinneId()
{
	return NPCId;
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Caprinae(vecPos, vecAng, team, data);
}

methodmap Caprinae < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	
	public Caprinae(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Caprinae npc = view_as<Caprinae>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.5", "200000", ally, _, true));
		
		if(!data[0])
		{
			npc.Anger = false;
		}
		else
		{
			npc.Anger = true;
		}
		i_NpcWeight[npc.index] = npc.Anger ? 1 : 3;
		npc.SetActivity("ACT_MP_RUN_PASSTIME");
		KillFeed_SetKillIcon(npc.index, "ullapool_caber_explosion");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetVariantInt(12);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = npc.Anger ? INVALID_FUNCTION : Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 180.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (npc.Anger ? 10.0 : 5.0);
		npc.m_flAttackHappens = 0.0;
		npc.m_bDissapearOnDeath = true;

		if(Rogue_Paradox_RedMoon())
		{
			fl_Extra_MeleeArmor[npc.index] *= 0.75;
			fl_Extra_RangedArmor[npc.index] *= 0.75;
			fl_Extra_Speed[npc.index] *= 1.2;
			fl_Extra_Damage[npc.index] *= 1.2;
		}
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_blastphomet/hwn2023_blastphomet.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/dec15_shin_shredders/dec15_shin_shredders.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/jul13_gallant_gael/jul13_gallant_gael.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		if(npc.Anger)
		{
			SetEntityRenderColor(npc.index, 0, 0, 0, 255, _, false, false);
		}

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Caprinae npc = view_as<Caprinae>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				if(npc.Anger && (EnemyNpcAlive - EnemyNpcAliveStatic) > (MaxEnemiesAllowedSpawnNext(1) - 3))
				{
					// Too many alive: Clone explodes now
					fl_Extra_Damage[npc.index] *= 3.0;
					SDKHooks_TakeDamage(npc.index, 0, 0, 1000000.0, DMG_BLAST);
				}
				else
				{
					npc.PlayMeleeHitSound();

					int health = ReturnEntityMaxHealth(npc.index) / 10;
					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
					
					int entity = NPC_CreateById(NPCId, -1, pos, ang, GetTeam(npc.index), "EX");
					if(entity > MaxClients)
					{
						if(GetTeam(npc.index) != TFTeam_Red)
							NpcAddedToZombiesLeftCurrently(entity, true);

						SetEntProp(entity, Prop_Data, "m_iHealth", health);
						SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
						
						fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
						fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
						fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index] * 1.1;
						fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index] * 0.75;
						view_as<CClotBody>(entity).m_flSpeed = npc.m_flSpeed;
					}

					if(npc.m_flSpeed < 275.0)
						npc.m_flSpeed += 10.0;
				}
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime && (!npc.Anger || !NpcStats_IsEnemySilenced(npc.index)))
		{
			npc.m_flGetClosestTargetTime = gameTime + 1.0;

			npc.AddGesture("ACT_MP_THROW");
			npc.PlayMeleeSound();
			
			npc.m_flAttackHappens = gameTime + 0.35;
			npc.m_flNextMeleeAttack = gameTime + (npc.Anger ? 30.0 : 5.0);
		}
	}
	else
	{
		npc.StopPathing();
	}

	if(!npc.Anger)
		npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	Caprinae npc = view_as<Caprinae>(entity);
	
	float startPosition[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", startPosition); 
	startPosition[2] += 45;
	
	makeexplosion(entity, startPosition, 1200, 150, _, true, true, 15.0);

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
}