#pragma semicolon 1
#pragma newdecls required

static const char g_RangeAttackSounds[][] =
{
	"weapons/bow_shoot.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};

static int NPCId;

void GogglesFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Waldch");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_goggles_follower");
	strcopy(data.Icon, sizeof(data.Icon), "goggles");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int GogglesFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return GogglesFollower(vecPos, vecAng);
}

static Action GogglesFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<GogglesFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap GogglesFollower < CClotBody
{
	public void PlayRangeSound()
 	{
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public int ChaosLevel()
	{
		int chaos = Rogue_GetChaosLevel();
		if(chaos < 3 && Rogue_Paradox_RedMoon())
			chaos = 3;
		
		return chaos;
	}
	public void SpeechEncounter(const char[] name)
	{
		int lv = this.ChaosLevel();
		if(lv == 4)
			return;
		
		bool chaos = lv == 3;

		if(StrContains(name, "Shop", false) != -1)
		{
			if(chaos)
			{
				switch(GetURandomInt() % 2)
				{
					case 0:
						this.Speech("훔치는게 낫지 않나.");
					
					case 1:
						this.Speech("그냥 나가자고.");
				}
			}
			else
			{
				switch(GetURandomInt() % 3)
				{
					case 0:
						this.Speech("아직도 살 게 남았어?");
					
					case 1:
						this.Speech("언제까지 여기에 있을건데", "...");
					
					case 2:
						this.Speech("이 물품들이 정말 도움이 될까?");
				}
			}
		}

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void SpeechTalk(int client)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(this.ChaosLevel())
		{
			case 3:
			{
				switch(GetURandomInt() % 34)
				{
					case 0:
					{
						this.Speech("하하", "...");
					}
					case 1:
					{
						this.Speech("흐흐", "...");
					}
					case 2:
					{
						this.Speech("거미가 정말 좋아.");
					}
					case 3:
					{
						this.Speech("머리가 너무 아프네.");
					}
					case 4:
					{
						this.Speech("우리가 뭘 하고 있었지?");
					}
					case 5:
					{
						this.Speech("와일딩겐 ", "좋지.");
					}
					case 6:
					{
						this.Speech("두통이 왜 자꾸 심해지고 있지?");
					}
					case 7:
					{
						this.Speech("이상한 행동은 하지마.");
					}
					case 8:
					{
						this.Speech("아", "...");
					}
					case 9:
					{
						this.Speech("꼭 마치 누가 날 찌르는것 같군.");
					}
					case 10:
					{
						this.Speech("도저히 집중할 수가 없어.");
					}
					case 11:
					{
						this.Speech("좀 닥쳐봐.");
					}
					case 12:
					{
						this.Speech("...");
					}
					case 13:
					{
						this.Speech("..?");
					}
					case 14:
					{
						this.Speech("맙소사.");
					}
					case 15:
					{
						this.Speech("좀만 쉬고 가자.");
					}
					case 16:
					{
						this.Speech("뭔가 이상해.");
					}
					case 17:
					{
						this.Speech("실", "베스터");
					}
					case 18:
					{
						this.Speech("내가 미쳐가는 것 같아.");
					}
					case 19:
					{
						this.Speech("이 싸움은 좋지 않아.");
					}
					case 20:
					{
						if(Rogue_CurseActive())
							this.Speech("넌 더워보이는데.");
					}
					case 21:
					{
						if(Rogue_CurseActive())
							this.Speech("날씨가 이따위라니.");
					}
					case 22:
					{
						this.Speech("넌 도움 안 돼.");
					}
					case 23:
					{
						this.Speech("왜 내가 또 너랑 붙어다녀야되지?");
					}
					case 24:
					{
						if(Rogue_GetIngots() > 49)
							this.Speech("돈이 뭐 이리 많은거냐?");
					}
					case 25:
					{
						this.Speech("으흠.");
					}
					case 26:
					{
						this.Speech("다른걸 좀 사자고.");
					}
					case 27:
					{
						this.Speech("전에도 그랬잖아.");
					}
					case 28:
					{
						this.Speech("네가 어디로 가고 있는지 알기나 하는거냐?");
					}
					case 29:
					{
						this.Speech("정말 귀찮다.");
					}
					case 30:
					{
						this.Speech("후", "...");
					}
					case 31:
					{
						this.Speech("하하하", "하하하");
					}
					case 32:
					{
						this.Speech("실베스터, 도움이 필요해...");
					}
					case 33:
					{
						if(Rogue_GetIngots() > 99)
							this.Speech(":3");
					}
				}
			}
			case 4:
			{
				this.Speech("...");
			}
			default:
			{
				switch(GetURandomInt() % 53)
				{
					case 0:
					{
						this.Speech("도대체 난 어떻게 찾아낸거야?");
					}
					case 1:
					{
						this.Speech("혼돈, 흠?");
						this.SpeechDelay(5.0, "와일딩겐에서 빠져나오기 전에 미리 알아뒀어야했는데.");
					}
					case 2:
					{
						this.Speech("실베스터는 괜찮을거야.");
					}
					case 3:
					{
						this.Speech("이전에 너희를 공격해서 정말 미안해", "...");
						this.SpeechDelay(5.0, "...알잖아, 제노 감염 사건때.");
					}
					case 4:
					{
						this.Speech("허, 너희들이 제노 감염이랑 시본 감염을 전부 처리했다니.");
						this.SpeechDelay(5.0, "그럼 혼돈도 너희한텐 별 거 아니겠네.");
					}
					case 5:
					{
						this.Speech("이 여행이 힘들긴 하네.");
					}
					case 6:
					{
						this.Speech("혹시 내가 여우란거 알고 있어?");
						this.SpeechDelay(5.0, "퍼리라고 하지 마라... 넌 고양이 친구도 있잖아.");
					}
					case 7:
					{
						this.Speech("소식을 들었을땐 너희가 시본에 감염당할 줄 알았어. 근데 아니었지.");
					}
					case 8:
					{
						this.Speech("너 뭔가 여기저기에 스프레이를 막 뿌리고 다니는것 같지 않아?");
					}
					case 9:
					{
						if(Rogue_CurseActive())
							this.Speech("뭐... 참 평범한 날씨네.");
					}
					case 10:
					{
						if(Rogue_CurseActive())
							this.Speech("붉은 달만 보면 모두 화가 많아지더라. 난 괜찮던데", "...");
					}
					case 11:
					{
						if(Rogue_GetIngots() > 49)
							this.Speech("설마 이 일을 돈 때문에 하는건 아니겠지", "...");
					}
					case 12:
					{
						if(Rogue_GetIngots() > 99)
							this.Speech("오스트레일륨을 너무 많이 가지고 다니는거 아니야?");
					}
					case 13:
					{
						this.Speech("넌 어떻게 그런 방식으로 무기를 꺼내는거야?");
					}
					case 14:
					{
						this.Speech("네가 옮기는 이 구조물들은 얼마나 무거운거야?");
					}
					case 15:
					{
						this.Speech("혹시... 내 총이 너한테...", "...");
						this.SpeechDelay(5.0, "아냐, 됐어.");
					}
					case 16:
					{
						this.Speech("뭐? 넌 어떤 적이 나오는지 미리 알 수 있다고?");
					}
					case 17:
					{
						this.Speech("밥 2세, 어휴, 난 그런걸 신으로 모시기 싫어.");
					}
					case 18:
					{
						this.Speech("너흰 정말 이상해", "...");
					}
					case 19:
					{
						this.Speech("근데, 저런 탑이 어떻게 유닛이란걸 만드는거야?");
					}
					case 20:
					{
						this.Speech("사실 난 물 공포증이 있어.");
						this.SpeechDelay(5.0, "그리고 시본도", "...");
					}
					case 21:
					{
						this.Speech("해산물이 정말 좋은데, 더 이상 그런건 못 구하겠어.");
					}
					case 22:
					{
						this.Speech("네가 말하는 '채팅'이란건 도대체 뭐야?");
					}
					case 23:
					{
						this.Speech("디스코드? 네가 혼돈을 부르는 방식이야?");
					}
					case 24:
					{
						this.Speech("뭔가 좀 이상한데...");
					}
					case 25:
					{
						this.Speech("난 와일딩겐에서 엔지니어였었지.");
						this.SpeechDelay(5.0, "그때는 그랬어", "...");
					}
					case 26:
					{
						this.Speech("바닥에 그냥 금이 막 깔려있는거 눈치챘어?");
					}
					case 27:
					{
						this.Speech("넌 정말 해결책이 사람을 때려패는거라고 생각해?");
					}
					case 28:
					{
						this.Speech("흐으음", "...");
					}
					case 29:
					{
						this.Speech("흐으으음", "...");
					}
					case 30:
					{
						this.Speech("춥네.");
					}
					case 31:
					{
						this.Speech("가끔 와일딩겐과 관련된 악몽을 꿔", "...");
						this.SpeechDelay(5.0, "그들이 날 이상한 이유로 끌고 가려 해", "...");
					}
					case 32:
					{
						this.Speech("전투가 갈수록 지치네", "...");
					}
					case 33:
					{
						this.Speech("이 혼돈과 관련된 것만 생각하면 머리가 아파.");
					}
					case 34:
					{
						this.Speech("실베스터가 그리워.");
					}
					case 35:
					{
						this.Speech("이 헤일로는 실베스터가 준거야.");
					}
					case 36:
					{
						this.Speech("엑스피돈사랑 와일딩겐이 연합을 한다던데, 난 그게 걱정이야.");
					}
					case 37:
					{
						this.Speech("이 중세 놈들 정말 싫지 않아?");
					}
					case 38:
					{
						this.Speech("도대체 어떻게 혼돈이 와일딩겐을 잠식했는지 모르겠어.");
					}
					case 39:
					{
						this.Speech("우리 혹시 뭔가 이상한 일이", "...");
						this.SpeechDelay(5.0, "아니, 됐어.");
					}
					case 40:
					{
						this.Speech("시본이 물을 달라며 기어다니는 꼴을 본 적이 있어.");
						this.SpeechDelay(5.0, "그래서 와일딩겐은 모든 강을 뒤덮어야했지. 하하.");
					}
					case 41:
					{
						this.Speech("그나저나 와일딩겐은 여기저기에 함정을 깔아놓는걸 정말 좋아해.");
						this.SpeechDelay(5.0, "나 없이 여기에 왔으면 큰일났을걸.");
					}
					case 42:
					{
						this.Speech("나 없이 여기에 왔으면 큰일났을걸.");
					}
					case 43:
					{
						this.Speech("다행스럽게도 제노 감염이 와일딩겐을 덮치진 않았어.");
					}
					case 44:
					{
						this.Speech("진짜 웃긴게, 제노 감염이랑 시본이랑 서로를 극도로 혐오하더라.");
					}
					case 45:
					{
						this.Speech("내 트라우마는 시본이고, 실베스터는 제노 감염이란게 재밌네.");
						this.SpeechDelay(5.0, "미안, 아무리 그래도 이건 아니었다.");
					}
					case 46:
					{
						this.Speech("혼돈이 우리가 행성을 떠나는걸 막으려고 한다는 말을 들은적이 있어.");
					}
					case 47:
					{
						this.Speech("애초에 여길 처음에 어떻게 오게 된 거야?");
					}
					case 48:
					{
						this.Speech("아, Boss vs Boss? 비디오 게임 이름이잖아. 그렇지?");
					}
					case 49:
					{
						this.Speech("다른 사람이랑 싸우는걸 좋아한다고?");
						this.SpeechDelay(5.0, "역시 너흰 좀 이상하네.");
					}
					case 50:
					{
						this.Speech("실베스터는 지금 뭐하고 있으려나", "...");
					}
					case 51:
					{
						this.Speech("좀비들이 계속 모여들고 있다는 소식이 항상 들려와.");
					}
					case 52:
					{
						this.Speech("난 고대 문자를 좀 읽을줄 알아. 사막에서 좀 배운거야.");
					}
				}
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void SpeechRevive()
	{
		if((this.m_flNextIdleSound + 14.0) > GetGameTime(this.index))
			return;
		
		if(this.ChaosLevel() > 2)
		{
			switch(GetURandomInt() % 5)
			{
				case 0:
					this.Speech("나중에 죽으라고.");
				
				case 1:
					this.Speech("그만 기어다녀라.");
				
				case 2:
					this.Speech("이딴걸 내가 해줘야하나.");
				
				case 3:
					this.Speech("빨리, 계속 쏴재끼라고.");
				
				case 4:
					this.Speech("어차피 계속 살진 못 할텐데.");
			}
		}
		else
		{
			switch(GetURandomInt() % 6)
			{
				case 0:
					this.Speech("내가 보는 앞에서 죽지 마", "...");
				
				case 1:
					this.Speech("더 많은 사람을 구하고 싶어.");
				
				case 2:
					this.Speech("사람이 죽는건 그만 보고 싶어.");
				
				case 3:
					this.Speech("어서 일어나.");
				
				case 4:
					this.Speech("넌 괜찮아질거야.");
				
				case 5:
					this.Speech("이제 괜찮을거야.");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + 35.0;
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, GogglesFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		static int color[4] = {255, 255, 255, 255};
		int chaos = this.ChaosLevel();
		if(chaos < 1)
			chaos = 1;
		
		color[1] = 295 - (chaos * 40);
		color[2] = 335 - (chaos * 80);

		NpcSpeechBubble(this.index, speechtext, 5, color, {0.0,0.0,120.0}, endingtextscroll);
	}
	
	public GogglesFollower(float vecPos[3], float vecAng[3])
	{
		GogglesFollower npc = view_as<GogglesFollower>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "50000", TFTeam_Red, true, false));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_STAND_ITEM2");
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flSpeed = 320.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "blue_goggles");
		
		/*
			Cosmetics
		*/

		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr18_antarctic_eyewear/spr18_antarctic_eyewear_scout.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_bow_thief/c_bow_thief.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_wagga_wagga_wear/sum19_wagga_wagga_wear.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 255, 255);
		WaldchEarsApply(npc.index,_, 0.75);

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;
		npc.Speech("Thanks for helping me.");
		/*
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != -1 && i_NpcInternalId[other] == BobTheFirstFollower_ID() && IsEntityAlive(other))
			{
				view_as<CClotBody>(other).m_bDissapearOnDeath = true;
				SmiteNpcToDeath(other);
				break;
			}
		}
		*/

		return npc;
	}
}

void GogglesFollower_StartStage(const char[] name)
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == NPCId && IsEntityAlive(entity))
		{
			view_as<GogglesFollower>(entity).SpeechEncounter(name);
			break;
		}
	}
}

static void ClotThink(int iNPC)
{
	GogglesFollower npc = view_as<GogglesFollower>(iNPC);

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
	int chaos = npc.ChaosLevel();
	b_NpcIsTeamkiller[npc.index] = chaos == 4;

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
	{
		i_Target[npc.index] = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != -1 && i_NpcInternalId[other] == FinalHunter_ID() && IsEntityAlive(other))
			{
				npc.Speech(chaos == 4 ? "..." : "This ends now!");
				CPrintToChatAll("{darkblue}Waldch{default}: %s", chaos == 4 ? "..." : "This ends now!");
				KillFeed_SetKillIcon(npc.index, "sword");
				func_NPCThink[npc.index] = ClotFinalThink;
				b_NpcIsTeamkiller[npc.index] = false;
				
				RaidBossActive = EntIndexToEntRef(npc.index);
				RaidModeTime = GetGameTime() + 9000.0;
				RaidModeScaling = 1.0;
				RaidAllowsBuildings = true;

				ExpidonsaSword_Waldch(npc.index);
				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
				
				break;
			}
		}

		target = GetClosestTarget(npc.index, _, 2000.0, true, _, _, _, true, 150.0, true, true);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		switch(chaos)
		{
			case 3:
			{
				ally = GetClosestAllyPlayer(npc.index);
				npc.m_iTargetWalkTo = ally;
			}
			case 4:
			{
				ally = -1;
				npc.m_iTargetWalkTo = -1;
			}
			default:
			{
				ally = GetClosestAllyPlayerGreg(npc.index);
				if(!ally)
				{
					ally = GetClosestAllyPlayer(npc.index);
					npc.m_iTargetWalkTo = ally;
				}
			}
		}
	}

	float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
	bool crouching;

	if(ally > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

		if(/*b_BobsCuringHand[ally] &&*/ b_BobsCuringHand_Revived[ally] >= GREGPOINTS_REV_NEEDED && TeutonType[ally] == TEUTON_NONE && dieingstate[ally] > 0 
			&& !b_LeftForDead[ally])
		{
			//walk to client.
			if(flDistanceToTarget < 5000.0)
			{
				//slowly revive
				ReviveClientFromOrToEntity(ally, npc.index, 1);
				
				npc.SpeechRevive();
				npc.StopPathing();
				crouching = true;
			}
			else
			{
				// Run to ally target, ignore enemies
				npc.SetActivity("ACT_MP_RUN_ITEM2");
				NPC_SetGoalEntity(npc.index, ally);
				npc.StartPathing();
				target = -1;
			}
		}
		else if(flDistanceToTarget < 25000.0)
		{
			// Close enough
			npc.StopPathing();
		}
		else
		{
			// Walk to ally target
			NPC_SetGoalEntity(npc.index, ally);
			npc.StartPathing();
		}

		if(target < 1)
			npc.SpeechTalk(ally);
	}
	else
	{
		// No ally target
		npc.StopPathing();
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");

				if(chaos < 4 && !NpcStats_IsEnemySilenced(npc.index))
					PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1500.0, _, vecTarget);
				
				npc.FaceTowards(vecTarget, 30000.0);

				float damage = 10000.0;
				switch(chaos)
				{
					case 2:
					{
						damage = GetRandomFloat(5000.0, 15000.0);
					}
					case 3:
					{
						damage += GetRandomInt(-1, 1) * 5000.0;
					}
					case 4:
					{
						damage += GetRandomInt(-2, 2) * 4999.0;
					}
				}
				
				npc.PlayRangeSound();
				npc.FireArrow(vecTarget, damage, 1500.0);

				vecTarget[2] += 40.0;
				npc.FireArrow(vecTarget, damage, 1500.0);

				vecTarget[2] -= 80.0;
				npc.FireArrow(vecTarget, damage, 1500.0);
			}
			else
			{
				npc.FaceTowards(vecTarget, 3000.0);
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.FaceTowards(vecTarget, 30000.0);
			npc.m_flGetClosestTargetTime = gameTime + 1.45;
			npc.m_flAttackHappens = gameTime + 1.35;
			npc.m_flNextMeleeAttack = gameTime + 3.85;
		}
	}
	else
	{
		npc.m_flAttackHappens = 0.0;
	}

	if(npc.m_bPathing)
	{
		npc.m_bAllowBackWalking = true;

		if(npc.m_flAttackHappens)
		{
			npc.m_flSpeed = 85.0;
			npc.SetActivity("ACT_MP_DEPLOYED_ITEM2");
		}
		else
		{
			npc.m_flSpeed = 320.0;
			npc.SetActivity("ACT_MP_RUN_ITEM2");
		}
	}
	else
	{
		npc.m_flSpeed = 1.0;
		npc.m_bAllowBackWalking = false;

		if(crouching)
		{
			if(npc.m_flAttackHappens)
			{
				npc.SetActivity("ACT_MP_CROUCH_DEPLOYED_IDLE_ITEM2");
			}
			else
			{
				npc.SetActivity("ACT_MP_CROUCH_ITEM2");
			}
		}
		else if(npc.m_flAttackHappens)
		{
			npc.SetActivity("ACT_MP_DEPLOYED_IDLE_ITEM2");
		}
		else
		{
			npc.SetActivity("ACT_MP_STAND_ITEM2");
		}
	}
}

static void ClotFinalThink(int iNPC)
{
	GogglesFollower npc = view_as<GogglesFollower>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target, _, true))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = -1;

		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != -1 && i_NpcInternalId[other] == FinalHunter_ID() && IsEntityAlive(other))
			{
				target = other;
				break;
			}
		}
		
		if(target == -1)
			target = GetClosestTarget(npc.index, _, _, _, _, _, _, _, 99999.9);
		
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, target);
		}

		npc.m_flSpeed = 340.0;
		npc.m_bAllowBackWalking = false;
		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, _))
				{
					target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float damage = 10000.0;
						if(ShouldNpcDealBonusDamage(target))
							damage *= 50.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
						
						Custom_Knockback(npc.index, target, 500.0, true); 
					}
				}

				delete swingTrace;
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target, _, true))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 1.95;
			}
		}

		npc.SetActivity("ACT_MP_RUN_MELEE");
	}
	else if(npc.m_flNextMeleeAttack == 0.0)
	{
		npc.StopPathing();
		npc.SetActivity("ACT_MP_STAND_MELEE");
	}
	else
	{
		npc.Speech("끝났어.");
		npc.SpeechDelay(4.0, "혼돈은 이제 와일딩겐을 위협하지 못 할거야.");
		CPrintToChatAll("{darkblue}월드치{default}: 끝났어.");
		CPrintToChatAll("{darkblue}월드치{default}: 혼돈은 이제 와일딩겐을 위협하지 못 할거야.");
		npc.m_flNextMeleeAttack = 0.0;

		npc.StopPathing();
		npc.SetActivity("ACT_MP_STAND_MELEE");
	}
}

static void ClotDeath(int entity)
{
	GogglesFollower npc = view_as<GogglesFollower>(entity);

	ExpidonsaRemoveEffects(entity);
	
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
}

void ExpidonsaSword_Waldch(int iNpc)
{
	DualRea npc = view_as<DualRea>(iNpc);

	npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
	SetVariantString("1.0");
	AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
	SetVariantInt(16384);
	AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 0);

	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	int particle_2 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	SetParent(npc.m_iWearable1, particle_1, "duelrea_left_spike");
	SetParent(npc.m_iWearable1, particle_2, "duelrea_right_spike");

	int Laser_4_i = ConnectWithBeamClient(particle_1, particle_2, 15, 15, 125, 1.25, 1.25, 100.0, LASERBEAM);
	
	i_ExpidonsaEnergyEffect[iNpc][0] = EntIndexToEntRef(particle_1);
	i_ExpidonsaEnergyEffect[iNpc][1] = EntIndexToEntRef(particle_2);
	i_ExpidonsaEnergyEffect[iNpc][2] = EntIndexToEntRef(Laser_4_i);
}