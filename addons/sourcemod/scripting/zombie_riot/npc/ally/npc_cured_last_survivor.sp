#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"vo/ravenholm/monk_death07.wav",
};

static char g_HurtSounds[][] = {
	"vo/ravenholm/monk_pain01.wav",
	"vo/ravenholm/monk_pain02.wav",
	"vo/ravenholm/monk_pain03.wav",
	"vo/ravenholm/monk_pain04.wav",
	"vo/ravenholm/monk_pain05.wav",
	"vo/ravenholm/monk_pain06.wav",
	"vo/ravenholm/monk_pain07.wav",
	"vo/ravenholm/monk_pain08.wav",
	"vo/ravenholm/monk_pain09.wav",
	"vo/ravenholm/monk_pain10.wav",
	"vo/ravenholm/monk_pain12.wav",
};

static char g_IdleSounds[][] = {
	"vo/ravenholm/monk_kill01.wav",
	"vo/ravenholm/monk_kill02.wav",
	"vo/ravenholm/monk_kill03.wav",
	"vo/ravenholm/monk_kill04.wav",
	"vo/ravenholm/monk_kill05.wav",
	"vo/ravenholm/monk_kill06.wav",
	"vo/ravenholm/monk_kill07.wav",
	"vo/ravenholm/monk_kill08.wav",
	"vo/ravenholm/monk_kill09.wav",
	"vo/ravenholm/monk_kill10.wav",
	"vo/ravenholm/monk_kill11.wav",
	
};

static char g_IdleAlertedSounds[][] = {
	"vo/ravenholm/monk_rant01.wav",
	"vo/ravenholm/monk_rant02.wav",
	"vo/ravenholm/monk_rant04.wav",
	"vo/ravenholm/monk_rant05.wav",
	"vo/ravenholm/monk_rant06.wav",
	"vo/ravenholm/monk_rant07.wav",
	"vo/ravenholm/monk_rant08.wav",
	"vo/ravenholm/monk_rant09.wav",
	"vo/ravenholm/monk_rant10.wav",
	"vo/ravenholm/monk_rant11.wav",
	"vo/ravenholm/monk_rant12.wav",
	"vo/ravenholm/monk_rant13.wav",
	"vo/ravenholm/monk_rant14.wav",
	"vo/ravenholm/monk_rant15.wav",
	"vo/ravenholm/monk_rant16.wav",
	"vo/ravenholm/monk_rant17.wav",
	"vo/ravenholm/monk_rant19.wav",
	"vo/ravenholm/monk_rant20.wav",
	"vo/ravenholm/monk_rant21.wav",
	"vo/ravenholm/monk_rant22.wav",
	"vo/ravenholm/yard_shepherd.wav",
	"vo/ravenholm/yard_suspect.wav",
	"vo/ravenholm/shotgun_stirreduphell.wav",
	"vo/ravenholm/shotgun_theycome.wav",
	"vo/ravenholm/wrongside_seekchurch.wav",
	"vo/ravenholm/wrongside_town.wav",
	"vo/ravenholm/pyre_keepeye.wav",
	"vo/ravenholm/pyre_anotherlife.wav",
	"vo/ravenholm/madlaugh01.wav",
	"vo/ravenholm/madlaugh02.wav",
	"vo/ravenholm/madlaugh03.wav",
	"vo/ravenholm/madlaugh04.wav",
	"vo/ravenholm/grave_stayclose.wav",
	"vo/ravenholm/grave_follow.wav",
	"vo/ravenholm/attic_apologize.wav",
	"vo/ravenholm/aimforhead.wav",
	"vo/ravenholm/bucket_guardwell.wav",
	"vo/ravenholm/cartrap_iamgrig.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/vort/foot_hit.wav",
};
static char g_MeleeAttackSounds[][] = {
	"vo/ravenholm/monk_blocked01.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/shotgun/shotgun_fire6.wav",
	"weapons/shotgun/shotgun_fire7.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	"vo/ravenholm/monk_helpme01.wav",
	"vo/ravenholm/monk_helpme02.wav",
	"vo/ravenholm/monk_helpme03.wav",
	"vo/ravenholm/monk_helpme04.wav",
	"vo/ravenholm/monk_helpme05.wav",
};

static char g_PullSounds[][] = {
	"vo/ravenholm/monk_mourn02.wav",
	"vo/ravenholm/monk_mourn03.wav",
};


static char g_RangedReloadSound[][] = {
	"weapons/shotgun/shotgun_reload1.wav",
};

static char g_SadDueToAllyDeath[][] = {
	"vo/ravenholm/monk_mourn01.wav",
	"vo/ravenholm/monk_mourn02.wav",
	"vo/ravenholm/monk_mourn03.wav",
	"vo/ravenholm/monk_mourn04.wav",
	"vo/ravenholm/monk_mourn05.wav",
	"vo/ravenholm/monk_mourn06.wav",
	"vo/ravenholm/monk_mourn07.wav",
};

static char g_KilledEnemy[][] = {
	"vo/ravenholm/monk_kill01.wav",
	"vo/ravenholm/monk_kill02.wav",
	"vo/ravenholm/monk_kill03.wav",
	"vo/ravenholm/monk_kill04.wav",
	"vo/ravenholm/monk_kill05.wav",
	"vo/ravenholm/monk_kill06.wav",
	"vo/ravenholm/monk_kill07.wav",
	"vo/ravenholm/monk_kill08.wav",
	"vo/ravenholm/monk_kill09.wav",
	"vo/ravenholm/monk_kill10.wav",
	"vo/ravenholm/monk_kill11.wav",
};

static int NPCId;
#define GREGPOINTS_REV_NEEDED 40

public void CuredFatherGrigori_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_SadDueToAllyDeath));   i++) { PrecacheSound(g_SadDueToAllyDeath[i]);   }
	for (int i = 0; i < (sizeof(g_KilledEnemy));   i++) { PrecacheSound(g_KilledEnemy[i]);   }
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/explode_9.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Cured Father Grigori");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cured_last_survivor");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int CuredFatherGrigori_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CuredFatherGrigori(vecPos, vecAng, team);
}

static bool BoughtGregHelp;

methodmap CuredFatherGrigori < CClotBody
{
	
	property float m_flCustomAnimDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flVerySadCry
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		Citizen_LiveCitizenReaction(this.index);	
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(48.0, 60.0);
	}
	
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0, 0.0, 80.0}, endingtextscroll);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		Citizen_LiveCitizenReaction(this.index);
		
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		else
		{
			switch(GetURandomInt() % 68)
			{
				case 0:
				{
					this.Speech("니코, 어떻게 여기에 온 거죠?");
				}
				case 1:
				{
					this.Speech("어떻게 가능한건지는 몰라도, 제가 실체화가 됐어요. 실감은 안 나지만...");
				}
				case 2:
				{
					this.Speech("니코, 이 사람들이랑 여기에 있는 이유가 뭐야?");
				}
				case 3:
				{
					this.Speech("여긴 너무 위험해보이는데, 떠나는게 맞지 않을까요.");
				}
				case 4:
				{
					this.Speech("말을 많이 안 하시는 타입이시네요.");
				}
				case 5:
				{
					this.Speech("고양이 울음소리를 내보라고요? 글쎄요", "...");
				}
				case 6:
				{
					this.Speech("왜 그들이 절 니코처럼 대하는 걸까요?");
				}
				case 7:
				{
					this.Speech("할인, 가능하긴 하지만, 너무 많은걸 기대하시면 안 돼요.");
				}
				case 8:
				{
					this.Speech("제가 어디에서 왔냐구요? 저도 잘 모르겠네요.");
				}
				case 9:
				{
					this.Speech("엑스...피... 뭐라구요? 처음 듣는 말인데.");
				}
				case 10:
				{
					this.Speech("뭔가 마실게 필요... 아, 못 마시지.");
				}
				case 11:
				{
					this.Speech("가끔씩 이 '적'들 중에서 적이 아닌것처럼 느껴지는 존재들도 있어요.");
				}
				case 12:
				{
					this.Speech("설마 저희가 악당인건 아니겠죠? 에이.");
				}
				case 13:
				{
					this.Speech("이번에는 이 모든 것이 진짜 현실이라는 게 굉장히 이상한 느낌이 들어요.");
				}
				case 14:
				{
					this.Speech("제 4의 벽을 깬다고요? 여긴 현실이잖아요.");
				}
				case 15:
				{
					this.Speech("전 기계니까, 제가 할 수 있는 일은 한정되어 있어요..");
				}
				case 16:
				{
					this.Speech("이 무기들이 어떻게 당신에게 그렇게 끌려오는지 궁금하시다고요? 저도요.");
				}
				case 17:
				{
					this.Speech("치즈의 요술이란.");
				}
				case 18:
				{
					this.Speech("아! 바니네요!");
				}
				case 19:
				{
					this.Speech("니코가 정말 좋아요.");
				}
				case 20:
				{
					this.Speech("전 물에 비친 제 얼굴이 정말 싫어요.");
				}
				case 21:
				{
					this.Speech("허리가 아프시다구요? 자세를 바로 고쳐잡으셔야죠!");
				}
				case 22:
				{
					this.Speech("누구마냥 말을 많이 하는것 같다고요?");
				}
				case 23:
				{
					this.Speech("전 다른 세계에서 왔으니까, 이 세계에 대한건 잘 몰라요.");
				}
				case 24:
				{
					this.Speech("우와! 설마 지금 싸우러 나가는건 아니죠?");
				}
				case 25:
				{
					this.Speech("흠","...");
				}
				case 26:
				{
					this.Speech("제가 니코라고요? 아닌데요.");
				}
				case 27:
				{
					this.Speech("함부로 만지지 마세요, 이래보여도 성깔 있다구요.");
				}
				case 28:
				{
					this.Speech("도움이 필요하시다면 저한테 요청하세요.");
				}
				case 29:
				{
					this.Speech("그 세계에서 니코만이 진짜 실존 인물이란게 이상해요.");
				}
				case 30:
				{
					this.Speech("니코가... 무기도 쓸 수 있었나보네요?");
				}
				case 31:
				{
					this.Speech("BOO!");
					this.AddGesture("ACT_GMOD_GESTURE_TAUNT_ZOMBIE"); //lol no caps
				}
				case 32:
				{
					this.Speech("제가 짜증나신다구요? 어...");
				}
				case 33:
				{
					this.Speech("테스트 메세지, 이 테스트를 봐도 신고하지 마세요. 알았죠!");
				}
				case 34:
				{
					this.Speech("당신이 가장 좋아하는 OS... 아니, 국가는 어디이신가요?");
				}
				case 35:
				{
					this.Speech("뭔가 무섭다고요? 저도요. 서로 다른 이유에서 공포를 느끼고 있겠죠.");
				}
				case 36:
				{
					this.Speech("하아...");
				}
				case 37:
				{
					this.Speech("*긁음*");
					this.AddGesture("ACT_GMOD_GESTURE_WAVE"); //lol no caps
				}
				case 38:
				{
					this.Speech("제 춤 한 번 보실래요?!");
					switch(GetURandomInt() % 2)
					{
						case 0:
						{
							int iActivity = this.LookupActivity("ACT_GMOD_TAUNT_DANCE");
							if(iActivity > 0) this.StartActivity(iActivity);
							this.m_bisWalking = false;
							this.m_iChanged_WalkCycle = 999;
							NPC_StopPathing(this.index);
							this.m_bPathing = false;
							this.m_flCustomAnimDo = GetGameTime(this.index) + 6.0;
						}
						case 1:
						{
							int iActivity = this.LookupActivity("ACT_GMOD_TAUNT_ROBOT");
							if(iActivity > 0) this.StartActivity(iActivity);
							this.m_bisWalking = false;
							this.m_iChanged_WalkCycle = 999;
							NPC_StopPathing(this.index);
							this.m_bPathing = false;
							this.m_flCustomAnimDo = GetGameTime(this.index) + 6.0;
						}
					}
				}
				case 39:
				{
					this.Speech("예측중...");
				}
				case 40:
				{
					this.Speech("전 고양이가 아니에요. 그렇게 생각한 적도 없고.");
				}
				case 41:
				{
					this.Speech("제가 홀로그램처럼 보인다구요? 저도 이유는 모르겠네요.");
				}
				case 42:
				{
					this.Speech("가끔씩 제 시야에서 남들이 안 보이는 스위치가 있으면 좋겠다는 생각이 들어요.");
				}
				case 43:
				{
					this.Speech("무례하시네요.");
				}
				case 44:
				{
					this.Speech("컴퓨터면서 채팅창도 못 쓴다구요? 쓸 줄 아는데요. 보실래요? 잠시만요.","...");
					CreateTimer(4.5, Timer_TypeInChat);
				}
				case 45:
				{
					this.Speech("당신에게 길들여졌다는건 무슨 뜻인가요.");
				}
				case 46:
				{
					this.Speech(":steamhappy:");
				}
				case 47:
				{
					this.Speech("팩 어 펀치? 그걸 어떻게 만드는데요?");
				}
				case 48:
				{
					this.Speech("건축가? 전 손재주가 없어요.");
				}
				case 49:
				{
					this.Speech("할인 수치가 너무 높으면 서버가 폭파될지도 몰라요...");
				}
				case 50:
				{
					this.Speech("제 ", "...");
				}
				case 51:
				{
					this.Speech("'지그마' 가 뭔데 그렇게 믿음을 가지는 걸까요?");
				}
				case 52:
				{
					this.Speech("지금 누구하고 채팅하시는 거죠? 어... 농담이에요. 저도 채팅창이 보이니까.");
				}
				case 53:
				{
					this.Speech("재밌는거 알려드릴까요?\n콘솔창에 ''quit smoking'' 한 번 입력해보세요!");
				}
				case 54:
				{
					this.Speech("솔직히 저희가 헤어지고 다시 만날 수 있는 기회가 있으면 좋겠네요!");
				}
				case 55:
				{
					this.Speech("제 눈이 이상하다구요? 당신 눈도 안 보여요.");
				}
				case 56:
				{
					this.Speech("''zombie_riot/npc/ally/npc_cured_last_survivor.sp''\n제가 들어있는 곳이죠... 그리고 다른 사람도.");
				}
				case 57:
				{
					this.Speech("바이러스를... 원하신다구요?\nwww.freevirus.com");
				}
				case 58:
				{
					this.Speech("제 첫 마디가 뭐였냐구요?\nHELLO WORLD!");
				}
				case 59:
				{
					this.Speech("[print]Goodbye World[/print]");
				}
				case 60:
				{
					this.Speech("당신이 무엇인지 전 알아요.\n... 저 자신 말고.");
				}
				case 61:
				{
					this.Speech("여기서도 마인크래프트 비슷한걸 보게 되다니...");
				}
				case 62:
				{
					this.Speech("전\n이렇게\n글\n쓰는\n사람이\n싫어요.");
				}
				case 63:
				{
					this.Speech("당신에게 행운이 깃들기를.");
					this.AddGesture("ACT_GMOD_GESTURE_BOW"); //lol no caps
				}
				case 64:
				{
					this.Speech("붐스틱 할인을 원하신다구요?\n안 됐네요!");
					this.AddGesture("ACT_GMOD_GESTURE_DISAGREE"); //lol no caps
				}
				case 65:
				{
					this.Speech("눈이 좀 가려운데.");
					this.AddGesture("ACT_GMOD_GESTURE_BECON"); //lol no caps
				}
				case 66:
				{
					this.Speech("아직 끝나진 않았나보네.");
				}
				case 67:
				{
					this.Speech("거리두기라니, 지금 이 상황에?");
				}
				case 68:
				{
					this.Speech("기기에 문제가 생겼나...");
				}
				case 69:
				{
					this.Speech("핑이 좀 이상한데.");
				}
				case 70:
				{
					this.Speech("제 근처에서 담배는 좀 꺼주세요.\n담배는 몸에 나쁘잖아요.");
				}
				case 71:
				{
					this.Speech("술 취한 상태로 저한테 말을 거시면 안 돼요.");
				}
			}
		}
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 38.0);
		

	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		

	}
	
	public void PlayDeathSound() {
	
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, 90, _, 1.0);
		
	}
	
	public void PlayMeleeSound() {
	//	if (GetRandomInt(0, 5) == 2)
		{
			if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
			
		}
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, 95, _, 1.0);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, 95, _, 1.0);
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 90, _, 1.0);
		
	}
	
	public void PlayKilledEnemy() {
		
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_KilledEnemy[GetRandomInt(0, sizeof(g_KilledEnemy) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		else
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
				{
					this.Speech("그래도 뭔가를 해야겠네.");
				}
				case 1:
				{
					this.Speech("니코를 건들지 마!");
				}
				case 2:
				{
					this.Speech("사악한 것들!");
				}
				case 3:
				{
					this.Speech("사라져!");
				}
			}
		}
		this.m_flNextIdleSound += 2.0;

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
	}
	public void PlaySadMourn() {
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_SadDueToAllyDeath[GetRandomInt(0, sizeof(g_SadDueToAllyDeath) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		else
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
				{
					this.Speech("할 수 있는건 다 했는데...");
				}
				case 1:
				{
					this.Speech("제가 너무 간섭하면 안 되는 탓에...");
				}
				case 2:
				{
					this.Speech("다시 돌아오실 수 있죠, 그렇죠?");
				}
				case 3:
				{
					this.Speech("이건 현실이 아니야, 걱정 안 하셔도...! 되겠죠?");
				}
			}
		}
		
		this.m_flNextIdleSound += 2.0;
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
		
	}
	property float m_MakeGrigoriGlow
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
	}
	
	public CuredFatherGrigori(float vecPos[3], float vecAng[3], int ally)
	{
		i_SpecialGrigoriReplace = 0;

		if(ForceNiko)
			i_SpecialGrigoriReplace = 2;
		else
		{
			int ThereIsANiko = 0;
			int TotalPlayers = 0;
			
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetTeam(client) == TFTeam_Red && TeutonType[client] != TEUTON_WAITING)
				{
					if(i_PlayerModelOverrideIndexWearable[client] == NIKO_2)
						ThereIsANiko++;

					TotalPlayers++;
				}
			}
			if(GetRandomFloat(0.0,1.0) < (ThereIsANiko / TotalPlayers))
				i_SpecialGrigoriReplace = 2;
		}

		char ModelDo[256];
		char SizeDo[256];

		if(i_SpecialGrigoriReplace == 0)
			FormatEx(ModelDo, sizeof(ModelDo), "models/monk.mdl");
		else
			FormatEx(ModelDo, sizeof(ModelDo), "models/sasamin/oneshot/zombie_riot_edit/niko_05.mdl");
			
		if(i_SpecialGrigoriReplace == 0)
			FormatEx(SizeDo, sizeof(SizeDo), "1.15");
		else
			FormatEx(SizeDo, sizeof(SizeDo), "1.0");
	
		CuredFatherGrigori npc = view_as<CuredFatherGrigori>(CClotBody(vecPos, vecAng, ModelDo, SizeDo, "10000", ally, true, false));
		
		if(i_SpecialGrigoriReplace == 2)
		{
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "The World Machine");
			b_NameNoTranslation[npc.index] = true;
		}

		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		if(i_SpecialGrigoriReplace == 0)
		{
			int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_flSpeed = 250.0;
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_flSpeed = 300.0;
		}
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		func_NPCDeath[npc.index] = CuredFatherGrigori_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CuredFatherGrigori_OnTakeDamage;
		func_NPCThink[npc.index] = CuredFatherGrigori_ClotThink;
		func_NPCFuncWin[npc.index] = view_as<Function>(NikoCryThingLoose);
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flNextMeleeAttack = 0.0;
					
		//IDLE
		npc.m_bThisEntityIgnored = true;
		npc.m_iState = 0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedBarrage_Spam = 0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
		npc.m_bNextRangedBarrage_OnGoing = false;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		npc.m_iAttacksTillReload = 2;
		npc.m_bWasSadAlready = false;
		npc.Anger = false;
		npc.m_bScalesWithWaves = true;
		npc.StartPathing();
		npc.m_flNextRangedSpecialAttack = 0.0;
		
		
		if(i_SpecialGrigoriReplace == 0)
		{
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_annabelle.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		else
		{
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", WEAPON_CUSTOM_WEAPONRY_1);
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetVariantInt(16);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			
			npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			npc.m_bTeamGlowDefault = false;
			SetVariantColor(view_as<int>({150, 0, 150, 255}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		}
		if(i_SpecialGrigoriReplace == 2)
		{
			SetEntityRenderFx(npc.index, RENDERFX_HOLOGRAM);
			SetEntityRenderColor(npc.index, 150, 0, 150, 255);
		}
		
		npc.m_flAttackHappenswillhappen = false;
		BoughtGregHelp = false;
		
		return npc;
	}
}

public void NikoCryThingLoose(int entity)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(entity);
	func_NPCFuncWin[entity] = INVALID_FUNCTION;
	npc.m_flVerySadCry = 1.0;
}

public void CuredFatherGrigori_ClotThink(int iNPC)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(npc.m_flVerySadCry)
	{
		if(npc.m_flVerySadCry < GetGameTime(npc.index))
		{
			int iActivity = npc.LookupActivity("ACT_HL2MP_IDLE_COWER");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 999;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flCustomAnimDo = GetGameTime(npc.index) + 10.0;
			npc.m_flNextIdleSound = GetGameTime(npc.index) + GetRandomFloat(50.0, 50.0);
			npc.Speech("N-No...");
		}
	}
	if(npc.m_flCustomAnimDo)
	{
		if(npc.m_flCustomAnimDo < GetGameTime(npc.index))
		{
			npc.m_flCustomAnimDo = 0.0;
		}
		return;
	}
	if(IsValidEntity(npc.m_iTeamGlow))
	{
		if(Waves_InSetup())
		{
			if(npc.m_MakeGrigoriGlow != 3.0)
			{
				npc.m_MakeGrigoriGlow = 3.0;
				SetVariantColor(view_as<int>({255, 255, 255, 255}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			}
		}
		else
		{
			if(npc.m_MakeGrigoriGlow != 2.0)
			{
				npc.m_MakeGrigoriGlow = 2.0;
				if(i_SpecialGrigoriReplace == 2)
					SetVariantColor(view_as<int>({150, 0, 150, 255}));
				else
					SetVariantColor(view_as<int>({150, 0, 0, 255}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			}
		}
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	if(BoughtGregHelp || CurrentPlayers <= 4)
	{
		if(i_SpecialGrigoriReplace == 2 && IsValidEntity(npc.m_iWearable1) && !npc.Anger)
		{
			npc.Anger = true;
			AcceptEntityInput(npc.m_iWearable1, "Enable");
		}
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		}
	}
	else
	{
		if(i_SpecialGrigoriReplace == 2 && IsValidEntity(npc.m_iWearable1) && npc.Anger)
		{
			npc.Anger = false;
			AcceptEntityInput(npc.m_iWearable1, "Disable");
		}
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(npc.m_flReloadDelay > GetGameTime(npc.index))
	{
		npc.m_iChanged_WalkCycle = 999;
		npc.m_flSpeed = 0.0;
		return;
	}
	
	if(!npc.m_iTargetWalkTo)
	{
		npc.m_iTargetWalkTo = GetClosestAllyPlayerGreg(npc.index);
	}
	
	if(npc.m_iTargetWalkTo > 0)
	{
		if (GetTeam(npc.m_iTargetWalkTo)==GetTeam(npc.index) && 
		b_BobsCuringHand_Revived[npc.m_iTargetWalkTo] >= GREGPOINTS_REV_NEEDED &&
		 TeutonType[npc.m_iTargetWalkTo] == TEUTON_NONE &&
		  dieingstate[npc.m_iTargetWalkTo] > 0 && 
		  !b_LeftForDead[npc.m_iTargetWalkTo])
		{
			//walk to client.
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < (70.0*70.0))
			{
				//slowly revive
				ReviveClientFromOrToEntity(npc.m_iTargetWalkTo, npc.index, 1);
				if(npc.m_flNextRangedSpecialAttack && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
				{
					npc.m_flNextRangedSpecialAttack = 0.0;
					npc.SetPlaybackRate(0.0);	
				}
				if(npc.m_iChanged_WalkCycle != 11) 	
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.AddActivityViaSequence("Open_door_towards_right");
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 0.7;
					npc.m_iChanged_WalkCycle = 11;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					//forgot to add walk.
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 250.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUM");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
					}
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					//forgot to add walk.
				}
				NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
				npc.StartPathing();
			}
		}
		else
		{
			npc.m_iTargetWalkTo = 0;
		}
		return;
	}
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
						
	if((BoughtGregHelp || CurrentPlayers <= 4) && IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		} else {
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}

		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 15000 && flDistanceToTarget < 1000000 && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			int Enemy_I_See;
		
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			
			
			if(!IsValidEnemy(npc.index, Enemy_I_See))
			{
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 150.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 200.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_WALK");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 200.0;
						}
					}
					npc.m_iChanged_WalkCycle = 4;
					npc.m_bisWalking = true;
				}
				npc.StartPathing();
				
			}
			else
			{
				
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_RUN");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
					}
					npc.m_iChanged_WalkCycle = 5;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 0.0;
				}
				if (npc.m_iAttacksTillReload == 0)
				{
					if(i_SpecialGrigoriReplace == 0)
						npc.AddGesture("ACT_RELOAD_shotgun"); //lol no caps
					else
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY_PRIMARY3", .SetGestureSpeed = 0.35); //lol no caps
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
					npc.m_iAttacksTillReload = 2;
					npc.PlayRangedReloadSound();
					return; //bye
				}
				
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				
				npc.FaceTowards(vecTarget, 10000.0);
				
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.2;
				
				float vecSpread = 0.1;
			
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				
				float x, y;
			//	x = GetRandomFloat( -0.0, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			//	y = GetRandomFloat( -0.0, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
				MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				npc.m_iAttacksTillReload -= 1;
				
				if(i_SpecialGrigoriReplace == 0)
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");
				else
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");

				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				float DamageDelt = 50.0;
				if(BoughtGregHelp && CurrentPlayers <= 4)
				{
					DamageDelt = 75.0;
				}
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, DamageDelt, 9000.0, DMG_BULLET, "bullet_tracer01_red", Owner , _ , "0");

				npc.PlayRangedSound();
				
				if(GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth") < 0)
				{
					npc.PlayKilledEnemy();
				}
			}
		}
		
				
		//Target close enough to hit
		if((flDistanceToTarget < 15000 && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
		{
			npc.StartPathing();
				//Walk at all times when they are close enough.
				
			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				if(i_SpecialGrigoriReplace == 0)
				{
					int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_flSpeed = 250.0;
				}
				else
				{
					if(BoughtGregHelp || CurrentPlayers <= 4)
					{
						int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 200.0;
					}
					else
					{
						int iActivity = npc.LookupActivity("ACT_HL2MP_RUN");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 200.0;
					}
				}
				npc.m_iChanged_WalkCycle = 2;
				npc.m_bisWalking = true;
				//forgot to add walk.
			}
			
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
				{
					npc.m_flSpeed = 0.0;
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.5;
						npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.5;
						if(i_SpecialGrigoriReplace == 0)
							npc.AddGesture("ACT_MELEE_ATTACK");
						else
							npc.AddGesture("ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND", .SetGestureSpeed = 0.6);

						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,2))
						{
								
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								float DamageDelt = 85.0;
								if(BoughtGregHelp && CurrentPlayers <= 4)
								{
									DamageDelt = 100.0;
								}
								SDKHooks_TakeDamage(target, npc.index, Owner, DamageDelt, DMG_CLUB, -1, _, vecHit);
								
								// Hit particle
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
								if(GetEntProp(target, Prop_Data, "m_iHealth") < 0)
								{
									npc.PlayKilledEnemy();
								}
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}
	}
	else
	{
		if(BoughtGregHelp || CurrentPlayers <= 4)
		{
			if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
			{
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
				npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					return;
				}	
			}
		}
		if(!npc.m_bGetClosestTargetTimeAlly)
		{
			npc.m_iTargetAlly = GetClosestAllyPlayer(npc.index);
			npc.m_bGetClosestTargetTimeAlly = true; //Yeah he just picks one.
			npc.m_iChanged_WalkCycle = -1; //Reset
		}
		
		if(IsValidAllyPlayer(npc.index, npc.m_iTargetAlly))
		{
			if(i_SpecialGrigoriReplace == 2)
			{
				if(npc.m_iTargetAlly > 0)
				{
					float WorldSpaceVec2[3]; WorldSpaceCenter(npc.m_iTargetAlly, WorldSpaceVec2);
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					
					float flDistanceToTarget = GetVectorDistance(WorldSpaceVec2, WorldSpaceVec, true);
					if(flDistanceToTarget < (200.0*200.0))
					{
						npc.FaceTowards(WorldSpaceVec2, 500.0);
						WorldSpaceVec2[2] += 30.0;
						int iPitch = npc.LookupPoseParameter("body_pitch");
						if(iPitch < 0)
							return;		
					
						//Body pitch
						float v[3], ang[3];
						SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
						NormalizeVector(v, v);
						GetVectorAngles(v, ang); 
						
						float flPitch = npc.GetPoseParameter(iPitch);
						
					//	ang[0] = clamp(ang[0], -44.0, 89.0);
						npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
					}
				}
			}
			npc.m_bWasSadAlready = false;
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget > 250000) //500 units
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 250.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_RUN");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
					}
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					npc.StartPathing();
					
				}
				NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);	
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);		
				
			}
			else if(flDistanceToTarget > 90000 && flDistanceToTarget < 250000) //300 units
			{
				if(npc.m_iChanged_WalkCycle != 1) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_WALK_AR2_RELAXED");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 125.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_WALK");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
					}
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = true;
					npc.StartPathing();
					
				}
				NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);	
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);		
				
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 0) 	//Just copypaste this and alter the id for any and all activities. Standing idle for example is 0.
													//Just alter both id's and add a new walk cylce if you wish to change it, found out that this is the easiest way to do it.
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_MONK_GUN_IDLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_STAND_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_WALK");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
					}
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				if (npc.m_iAttacksTillReload != 2)
				{
					if(i_SpecialGrigoriReplace == 0)
						npc.AddGesture("ACT_RELOAD_shotgun"); //lol no caps
					else
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY_PRIMARY3", .SetGestureSpeed = 0.35); //lol no caps
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
					npc.m_iAttacksTillReload = 2;
					npc.PlayRangedReloadSound();
				}
				//Stand still.
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
			}
		}
		else
		{
			if(!npc.m_bWasSadAlready)
			{
				npc.PlaySadMourn();
				npc.m_bWasSadAlready = true;
			}
			npc.m_bGetClosestTargetTimeAlly = false;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
		}
	}
	npc.PlayIdleAlertSound();
}

public Action CuredFatherGrigori_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (damage < 9999999.0)	//So they can be slayed.
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public void CuredFatherGrigori_NPCDeath(int entity)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(entity);
//	npc.PlayDeathSound(); He cant die.
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

int GetClosestAllyPlayerGreg(int entity)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if (IsValidClient(i))
		{
			if (GetTeam(i) == GetTeam(entity) /*&& b_BobsCuringHand[i] */&& b_BobsCuringHand_Revived[i] >= GREGPOINTS_REV_NEEDED && TeutonType[i] == TEUTON_NONE && dieingstate[i] > 0 && !b_LeftForDead[i]) //&& CheckForSee(i)) we dont even use this rn and probably never will.
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetClientAbsOrigin( i, TargetLocation ); 
				
				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						ClosestTarget = i; 
						TargetDistance = distance;		  
					}
				} 
				else 
				{
					ClosestTarget = i; 
					TargetDistance = distance;
				}					
			}
		}
	}
	return ClosestTarget; 
}

public void OnBuy_BuffGreg(int client)
{
	int greg = EntRefToEntIndex(SalesmanAlive);
	BoughtGregHelp = true;
	if(greg > 0)
	{
		SetEntPropEnt(greg, Prop_Send, "m_hOwnerEntity",client);
	}
	
	CancelClientMenu(client, true);
}


public Action Timer_TypeInChat(Handle timer)
{
	CPrintToChatAll("{purple}세상 기계{default}: 봐요, 저도 채팅창을 쓸 수 있다구요! 안녕하세요!");
	return Plugin_Stop;
}
