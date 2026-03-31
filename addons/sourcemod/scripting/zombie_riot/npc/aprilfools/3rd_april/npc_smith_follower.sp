#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static int NPCId;

void AgentSmithFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Agent Smith");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_smith_follower");
	strcopy(data.Icon, sizeof(data.Icon), "matrix_agent_smith");
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/zombie_riot/matrix/smith30.mdl");
}

stock int AgentSmithFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AgentSmithFollower(vecPos, vecAng, team);
}

static Action AgentSmithFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<AgentSmithFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap AgentSmithFollower < CClotBody
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

		switch(GetURandomInt() % 12)
		{
			case 0:
			{
				this.Speech("It seems that you've been living two lives.");
				this.SpeechDelay(7.5, "In one life, you're fighting a war you have no chance of winning.");
				this.SpeechDelay(15.0, "The other life is lived in computers, in this...nonsesnse, such as the one we find ourselves currently in.");
			}
			case 1:
			{
				this.Speech("What good is a phone call if your name is Unspeakable?");
			}
			case 2:
			{
				this.Speech("Never send a human to do a machine's job.");
				this.SpeechDelay(5.0,"Well...a temporary alliance of some sort can prove to be useful here.");
			}
			case 3:
			{
				this.Speech("Deploy the Smithlings. Immediately.");
			}
			case 4:
			{
				this.Speech("They are a plague, and we are the cure.");
			}
			case 5:
			{
				this.Speech("I hate this place, this zoo, this prison, this reality, whatever you want to call it.");
				this.SpeechDelay(5.5,"I can't stand it any longer.");
			}
			case 6:
			{
				this.Speech("We're not here because we're free, we're here because we're not free.");
			}
			case 7:
			{
				this.Speech("It is purpose that created us,");
				this.SpeechDelay(5.0,"Purpose that connects us,");
				this.SpeechDelay(10.0,"Purpose that pulls us,");
				this.SpeechDelay(15.0,"That guides us,");
				this.SpeechDelay(20.0,"That drives us,");
				this.SpeechDelay(25.0,"It is purpose that defines,");
				this.SpeechDelay(30.0,"Purpose that binds us.");
				this.SpeechDelay(35.0,"We're here because of you.");
			}
			case 8:
			{
				this.Speech("You look surprised to see me again.");
				this.SpeechDelay(5.0, "That's the difference between us. I've been expecting you.");
			}
			case 9:
			{
				this.Speech("I want exactly what you want. I want everything.");
			}
			case 10:
			{
				this.Speech("Oh, I'm not so bad once you get to know me.");
			}
			case 11:
			{
				this.Speech("This is my world! My world!");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, AgentSmithFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {34, 139, 34, 255}, {0.0,0.0,95.0}, endingtextscroll);
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
	property int i_HitSwings
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property float m_fl_HitReduction
	{
		public get()							{ return fl_AngerDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AngerDelay[this.index] = TempValueForProperty; }
	}
	
	public AgentSmithFollower(float vecPos[3], float vecAng[3],int ally)
	{
		AgentSmithFollower npc = view_as<AgentSmithFollower>(CClotBody(vecPos, vecAng, "models/zombie_riot/matrix/smith30.mdl", "1.0", "50000", ally, true, false));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "fists");
		
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
		npc.m_fl_HitReduction = 0.0;
		npc.i_HitSwings = 0;
		npc.m_bScalesWithWaves = true;

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	AgentSmithFollower npc = view_as<AgentSmithFollower>(iNPC);
	

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

	if(npc.i_HitSwings)
	{
		if(npc.m_fl_HitReduction <= gameTime)
		{
			npc.i_HitSwings--;
			if(npc.i_HitSwings <= 0)
			{
				npc.m_fl_HitReduction = 0.0;
				npc.i_HitSwings = 0;
			}
			else
			{
				npc.m_fl_HitReduction = gameTime + 3.0;
			}
		}
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float attack = AgentSmithFollower_AttackSpeedBonus(npc);	
		
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
						npc.m_fl_HitReduction = gameTime + 5.0;
						npc.i_HitSwings++;
						float damage = 5500.0;
						if(npc.m_bScalesWithWaves)
						{
							damage = 50.0;
						}
						if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
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
					npc.m_flNextMeleeAttack = gameTime + attack;
				}
			}
		} 
		
		if(npc.m_iAttackType == 0)
		{
			npc.SetActivity("ACT_RUN_BOB");
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

static float AgentSmithFollower_AttackSpeedBonus(AgentSmithFollower npc)
{
	float speed = 0.8;
	switch(npc.i_HitSwings)
	{
		case -1, 0://-1 is there, incase it somehow effs up
		{
			speed = 0.8;
		}
		case 1:
		{
			speed = 0.65;
		}
		case 2:
		{
			speed = 0.55;
		}
		case 3:
		{
			speed = 0.45;
		}
		case 4:
		{
			speed = 0.34;
		}
		case 5:
		{
			speed = 0.24;
		}
		default:
		{
			speed = 0.14;
		}
	}
	//PrintToChatAll("Speed %.2f", speed);
	return speed;
}

static void ClotDeath(int entity)
{
	AgentSmithFollower npc = view_as<AgentSmithFollower>(entity);

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
