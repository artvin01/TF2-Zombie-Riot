#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	"weapons/saxxy_turntogold_05.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/pickaxe_swing3.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing1.wav",
};

static const char g_BobSuperMeleeCharge_Hit[][] =
{
	"player/taunt_yeti_standee_break.wav",
};
static int NPCId;

void BobTheFirstFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob the First");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_first_follower");
	strcopy(data.Icon, sizeof(data.Icon), "");
	for (int i = 0; i < (sizeof(g_BobSuperMeleeCharge_Hit)); i++) { PrecacheSound(g_BobSuperMeleeCharge_Hit[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }

	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int BobTheFirstFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return BobTheFirstFollower(vecPos, vecAng, team);
}

static Action BobTheFirstFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<BobTheFirstFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap BobTheFirstFollower < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.3);
	}
	public void PlayBobMeleePostHit()
	{
		int pitch = GetRandomInt(70,80);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}
	public void SpeechTalk(int client)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 22)
		{
			case 0:
			{
				this.Speech("I have been studying many places across irln ever since whiteflower was killed.");
				this.SpeechDelay(5.0, "I found many things i liked.");
				this.SpeechDelay(10.0, "And many i did not.");
			}
			case 1:
			{
				this.Speech("I wonder if Bladedance will ever forgive me", "...");
			}
			case 2:
			{
				this.Speech("I know what you did to guln.");
				this.SpeechDelay(5.0,"I know it was in his wish.");
				this.SpeechDelay(10.0,"That doesnt mean ill be any less forgiving for it.");
			}
			case 3:
			{
				this.Speech("People view me as a hero, i view myself as being curious.");
			}
			case 4:
			{
				this.Speech("I have no idea why Whiteflower did what he did.");
				this.SpeechDelay(5.0,"Regardless, it is unforgiveable.");
			}
			case 5:
			{
				this.Speech("How my friendgroup met? Mazeat.");
			}
			case 6:
			{
				this.Speech("You want my sword? No chance.");
			}
			case 7:
			{
				this.Speech("Ever since the seaborn stuff happend, you all have been alot more reasonable.");
				this.SpeechDelay(5.0,"Could be PTSD.");
			}
			case 8:
			{
				this.Speech("Even if everything is going to hell, This is the right path.");
			}
			case 9:
			{
				this.Speech("Overtime i can feel everything relaxing abit, The only common big enemy is the void.");
				this.SpeechDelay(5.0, "... or whatever that is..");
			}
			case 10:
			{
				this.Speech("Chaos, i still dont know if its made by someone, or a force of nature.");
				this.SpeechDelay(5.0, "Time will tell what it is..");
			}
			case 11:
			{
				this.Speech("What freaks me out?");
				this.SpeechDelay(5.0, "Ever lost your best friend to another friend?");
				this.SpeechDelay(10.0, "That.");
			}
			case 12:
			{
				this.Speech("Im not emotionless.");
				this.SpeechDelay(5.0, "I just dont show it to everyone i meet.");
			}
			case 13:
			{
				this.Speech("Twirl, the only one to think alike me.");
				this.SpeechDelay(5.0, "If it were opposite day.");
			}
			case 14:
			{
				this.Speech("How i made clones in our battle?");
				this.SpeechDelay(5.0, "I didnt, i just moved around.");
			}
			case 15:
			{
				this.Speech("Think you'd stand a chance against me and bladedance?");
			}
			case 16:
			{
				this.Speech("My favorite drink?");
				this.SpeechDelay(5.0, "Banana Juice.");
			}
			case 17:
			{
				this.Speech("Omega? Well, after that stunt he pulled in Nova Prospekt, I trust him.");
			}
			case 18:
			{
				this.Speech("You think i'd be sorry for attacking you?");
				this.SpeechDelay(5.0, "You should be sorry for being so god damn careless with the seaborn.");
			}
			case 19:
			{
				this.Speech("If you ever think i'll trust that second bob faker, ill laugh.");
				this.SpeechDelay(9.0, "He acts like an expidonsan.");
			}
			case 20:
			{
				this.Speech("I wonder what Guln would think of whiteflowers death","...");
				this.SpeechDelay(8.0, "He'd be probably very upset.");
			}
			case 21:
			{
				this.Speech("Cherrish your friends as much as you can, while they are still here.");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, BobTheFirstFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,90.0}, endingtextscroll);
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
	
	public BobTheFirstFollower(float vecPos[3], float vecAng[3],int ally)
	{
		BobTheFirstFollower npc = view_as<BobTheFirstFollower>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "50000", ally, true, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_RUN_BOB");
		KillFeed_SetKillIcon(npc.index, "sword");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SetVariantInt(1);	// Combine Model
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 0);

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

		SetEntPropString(npc.index, Prop_Data, "m_iName", "blue_goggles");
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		IgniteTargetEffect(npc.m_iWearable1);

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		if(Rogue_Mode())
		{
			// Cutscene Here
			npc.Speech("Remember Chaos? That is serious. Come with me. Now.");
			npc.SpeechDelay(5.0, "''Bob the Second'' can come with us too, though i wouldnt trust him much.");
		//	Rogue_SetProgressTime(10.0, false);
		}

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	BobTheFirstFollower npc = view_as<BobTheFirstFollower>(iNPC);
	

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
		
		if(npc.m_flAttackHappens)
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
						IncreaseEntityDamageTakenBy(target, 0.02, 3.0, true);
					}
				}

				delete swingTrace;
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_MELEE_BOB");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.35;
			}
		}

		npc.SetActivity("ACT_RUN_BOB");
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
				npc.SetActivity("ACT_RUN_BOB");
				return;
			}
		}

		npc.StopPathing();
		npc.SetActivity("ACT_IDLE_BOBPRIME");

		if(target < 1)
			npc.SpeechTalk(ally);
	}
}

static void ClotDeath(int entity)
{
	BobTheFirstFollower npc = view_as<BobTheFirstFollower>(entity);

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
