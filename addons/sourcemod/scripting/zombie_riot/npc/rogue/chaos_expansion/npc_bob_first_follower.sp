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
				this.Speech("해풍등이 죽은 이후로, 난 전세계의 많은 장소를 연구해봤어.");
				this.SpeechDelay(5.0, "좋아하게 된 곳도 있었고.");
				this.SpeechDelay(10.0, "싫어하게 된 곳도 있었지.");
			}
			case 1:
			{
				this.Speech("칼춤이 날 용서해주긴 할까", "...");
			}
			case 2:
			{
				this.Speech("네가 귄에게 한 짓을 기억한다.");
				this.SpeechDelay(5.0,"나도 알아. 그게 바로 그가 원하던 것이란걸");
				this.SpeechDelay(10.0,"그렇다고 내가 널 완전히 용서할거란 생각은 하지 마라.");
			}
			case 3:
			{
				this.Speech("사람들은 날 영웅으로 여기지만, 왜인지 모르겠어.");
			}
			case 4:
			{
				this.Speech("해풍등 그 년이 도대체 왜 그랬는지 알 수가 없다.");
				this.SpeechDelay(5.0,"어쨌든간에, 절대 용서할 수 없지.");
			}
			case 5:
			{
				this.Speech("나의 친구와는 어떻게 만나냐고? 마제트를 통해서.");
			}
			case 6:
			{
				this.Speech("내 검을 원하나? 꿈 깨라.");
			}
			case 7:
			{
				this.Speech("시본 사건 이후, 너희를 인정하지 않을 수 없다.");
				this.SpeechDelay(5.0,"아니면 PTSD거나.");
			}
			case 8:
			{
				this.Speech("이게 올바른 길이겠지. 비록 모든게 위험해지더라도.");
			}
			case 9:
			{
				this.Speech("그나마 모든 것이 조금씩 나아지고 있군. 우리의 유일한 공동의 적은 공허다.");
				this.SpeechDelay(5.0, "... 아니면 다른 세력도 적으로 삼거나..");
			}
			case 10:
			{
				this.Speech("혼돈, 그것이 누군가에 의해 만들어진건지, 아니면 자연 발생의 결과물인지 알 수가 없어.");
				this.SpeechDelay(5.0, "시간이 지나면 모든게 밝혀지겠지..");
			}
			case 11:
			{
				this.Speech("내가 두려워하는게 뭐냐고?");
				this.SpeechDelay(5.0, "네 절친이 다른 절친에게 잔혹하게 살해당한걸 본 적 있나?");
				this.SpeechDelay(10.0, "바로 그거야.");
			}
			case 12:
			{
				this.Speech("난 감정이 없는게 아니다.");
				this.SpeechDelay(5.0, "그냥 만나는 자들마다 그렇게 느낄 뿐이지.");
			}
			case 13:
			{
				this.Speech("트월, 나와 생각이 동등한 자.");
				this.SpeechDelay(5.0, "라고 할 줄 알았나.");
			}
			case 14:
			{
				this.Speech("너와 내 싸움에서 내가 어떻게 클론을 만들었냐고?");
				this.SpeechDelay(5.0, "난 클론을 만드는 기술이 없다. 그냥 움직였을 뿐이지.");
			}
			case 15:
			{
				this.Speech("네가 칼춤과 날 동시에 상대할 수 있을거라 생각하나?");
			}
			case 16:
			{
				this.Speech("내가 좋아하는 음료가 뭐냐고?");
				this.SpeechDelay(5.0, "바나나 주스.");
			}
			case 17:
			{
				this.Speech("오메가? 아. 그는 믿을만한 인물이지. 특히 노바 프로스펙트 사건때부터는.");
			}
			case 18:
			{
				this.Speech("내가 널 공격한걸 사과해야한다고?");
				this.SpeechDelay(5.0, "미쳤군. 내가 아니라 네가 사과해야지. 누가 시본을 그딴식으로 다룰 생각을 해?");
			}
			case 19:
			{
				this.Speech("만약 그 밥 2세 짝퉁을 믿고 있는거라면, 전부 다 믿지는 마.");
				this.SpeechDelay(9.0, "그 놈은 꼭 마치 엑스피돈사인처럼 행동하니까.");
			}
			case 20:
			{
				this.Speech("귄이 해풍등의 죽음을 어떻게 생각하는지 보고 싶군","...");
				this.SpeechDelay(8.0, "분명 그는 극도로 분노하겠지.");
			}
			case 21:
			{
				this.Speech("네 친구들을 소중히 여겨. 특히 그들이 살아있는 동안에는.");
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
			Rogue_SetProgressTime(10.0, false);
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, target);
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
				NPC_SetGoalEntity(npc.index, ally);
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
