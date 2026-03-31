#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	"weapons/bat_hit.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav",
};

static int NPCId;

void KevinmeryFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "kevinmery2009");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_kevin_follower");
	strcopy(data.Icon, sizeof(data.Icon), "scout");
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	PrecacheModel("models/player/scout.mdl");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int KevinmeryFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return KevinmeryFollower(vecPos, vecAng, team);
}

static Action KevinmeryFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<KevinmeryFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap KevinmeryFollower < CClotBody
{
	property int m_iAttackType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.3);
	}
	public void SpeechTalk(int client)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 21)
		{
			case 0:
			{
				this.Speech("i think if we win to easy we should remach");
			}
			case 1:
			{
				this.Speech("best server stability today vs best server stability of history");
			}
			case 2:
			{
				this.Speech("why always im getting stronger so easy");
				this.SpeechDelay(5.0,"power of the protagonist");
			}
			case 3:
			{
				this.Speech("hey artvin fix pumking farm y encounter another ncp and boss stuck zone");
			}
			case 4:
			{
				this.Speech("we have an army fr");
			}
			case 5:
			{
				this.Speech("im eating some bean right now");
			}
			case 6:
			{
				this.Speech("this map need more space blut");
			}
			case 7:
			{
				this.Speech("fish test the gambler blut");
			}
			case 8:
			{
				this.Speech("you gonna gain enough money trough the wave");
			}
			case 9:
			{
				this.Speech("time changes man");
			}
			case 10:
			{
				this.Speech("windows 12 will fix this!!");
			}
			case 11:
			{
				this.Speech("do a suggestion bruh");
			}
			case 12:
			{
				this.Speech("went kfc as a raid fr");
			}
			case 13:
			{
				this.Speech("ngl eno have a femboy voice fr");
			}
			case 14:
			{
				this.Speech("KEVIN MERY CEO OF SUMMER CAMP AND IM GONNA BONK THIS PLACE TO THE GROUND");
			}
			case 15:
			{
				this.Speech("yo artvin these enemies need a nerf on damage bruh");
			}
			case 16:
			{
				this.Speech("went you are gonna make kfc a raid");
			}
			case 17:
			{
				this.Speech("bg = ww3");
			}
			case 18:
			{
				this.Speech("omg they are here");
				this.SpeechDelay(5.0,"the steamhappies");
				this.SpeechDelay(10.0,"it a infectcion");
			}
			case 19:
			{
				this.Speech("bug are features");
			}
			case 20:
			{
				this.Speech("i not gonna sleep for 3 days whit those smithings");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, KevinmeryFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {210, 0, 45, 255}, {0.0,0.0,95.0}, endingtextscroll);
	}
	property float m_flDeathAnimation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flDeathAnimationCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flCheckItemDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	
	public KevinmeryFollower(float vecPos[3], float vecAng[3],int ally)
	{
		KevinmeryFollower npc = view_as<KevinmeryFollower>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", "50000", ally, true, false));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "bat");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flSpeed = 310.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;
		npc.m_flDeathAnimation = 0.0;
		npc.m_bScalesWithWaves = true;

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	KevinmeryFollower npc = view_as<KevinmeryFollower>(iNPC);
	

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	int ally = npc.m_iTargetWalkTo;

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, _, 99999.9);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		ally = GetClosestAllyPlayer(npc.index);
		npc.m_iTargetWalkTo = ally;
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
		if(npc.m_flAttackHappens)
		{
			npc.StopPathing();
		}
		else
		{
			npc.StartPathing();
		}
		if(npc.m_iAttackType == -1 && npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.SetActivity("ACT_MP_RUN_MELEE");
				npc.m_bisWalking = true;
				npc.StartPathing();
				npc.m_iAttackType = 0;
			}
		}
		else if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target,_,_,_,2))
				{
					target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float damage = 5500.0;
						if(npc.m_bScalesWithWaves)
						{
							damage = 50.0;
						}
						if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
						if(!b_thisNpcIsARaid[target] && !b_thisNpcIsABoss[target])
							Custom_Knockback(npc.index, target, 250.0, true);
					}
				}

				delete swingTrace;
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 1.0;

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.15;
					npc.m_flNextMeleeAttack = gameTime + 0.75;
				}
			}
		} 
		
		if(npc.m_iAttackType == 0)
		{
			npc.SetActivity("ACT_MP_RUN_MELEE");
		}
	}
	else
	{
		if(ally > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

			if(flDistanceToTarget > 25000.0)
			{
				npc.SetGoalEntity(ally);
				npc.StartPathing();
				npc.SetActivity("ACT_MP_RUN_MELEE");
				return;
			}
		}

		npc.StopPathing();
		npc.SetActivity("ACT_MP_RUN_MELEE");

		if(target < 1)
			npc.SpeechTalk(ally);
	}
}

static void ClotDeath(int entity)
{
	KevinmeryFollower npc = view_as<KevinmeryFollower>(entity);

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
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}
