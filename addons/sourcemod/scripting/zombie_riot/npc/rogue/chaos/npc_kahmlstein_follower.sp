#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};
static const char g_CoughRandom[][] = {
	"ambient/voices/cough1.wav",
	"ambient/voices/cough2.wav",
	"ambient/voices/cough3.wav",
	"ambient/voices/cough4.wav",
};


static const char g_BobSuperMeleeCharge_Hit[][] =
{
	"player/taunt_yeti_standee_break.wav",
};
static int NPCId;

void KahmlsteinFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Kahmlstein");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_kahmlstein_follower");
	strcopy(data.Icon, sizeof(data.Icon), "kahmlstein");
	for (int i = 0; i < (sizeof(g_CoughRandom)); i++) { PrecacheSound(g_CoughRandom[i]); }
	for (int i = 0; i < (sizeof(g_BobSuperMeleeCharge_Hit)); i++) { PrecacheSound(g_BobSuperMeleeCharge_Hit[i]); }

	PrecacheSound("#music/hl2_song23_suitsong3.mp3");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int KahmlsteinFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return KahmlsteinFollower(vecPos, vecAng, team, data);
}

static Action KahmlsteinFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<KahmlsteinFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap KahmlsteinFollower < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayCoughSound() 
	{
		EmitSoundToAll(g_CoughRandom[GetRandomInt(0, sizeof(g_CoughRandom) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound(int who) 
	{
		EmitSoundToAll("npc/strider/striderx_die1.wav", who, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
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

		switch(GetURandomInt() % 11)
		{
			case 0:
			{
				this.Speech("I crushed countless cities, evaporated entire armies, set whole seas ablaze.");
				this.SpeechDelay(5.0, "But I couldn't defeat a couple of mercs, crazy.");
				this.SpeechDelay(10.0, "Atleast that got me freed from the influence of this thing somehow, thanks.");
			}
			case 1:
			{
				this.Speech("I always dreamt about being a leader, just not in a way like this", "...");
			}
			case 2:
			{
				this.Speech("Have you ever heard of Hitman? It's pretty rad series, you should play it.");
				this.SpeechDelay(5.0, "OR ELSE", "...");
			}
			case 3:
			{
				this.Speech("Some time ago I had a dream about being this powerful galactic being.");
				this.SpeechDelay(5.0, "And I fought very powerful people in it too, me versus all of them at once.");
				this.SpeechDelay(10.0, "In the end everyone lost because of the time limit ", "-_-");
				this.SpeechDelay(15.0, "Woke up soon after, what a weird dream that was.");
			}
			case 4:
			{
				this.Speech("Chaos makes you crazy, but the Void takes you in and traps you forever.");
				this.SpeechDelay(5.0, "You find yourself in nothing but total darkness, unable to escape.");
				this.SpeechDelay(10.0, "I need to put a stop to it and fix my mistakes.");
			}
			case 5:
			{
				this.Speech("I do really hate goverments, they use up people for their own comfort and gains.");
				this.SpeechDelay(5.0, "I might be sane now, but if I could I would still love to crush them all.");
				this.SpeechDelay(10.0, "This time without the unnecessary casualties.");
				this.SpeechDelay(15.0, "But there are more important matters at hand now.");
			}
			case 6:
			{
				this.Speech("After my fuck ups Ziberia ain't the same anymore...");
				this.SpeechDelay(5.0, "I wish I could go back in time... To the old days", "...");
			}
			case 7:
			{
				this.Speech("After I regained my sanity, I keep having these awful nightmares at night.");
				this.SpeechDelay(5.0, "I see thousands of people being burned alive to crisps.");
				this.SpeechDelay(10.0, "Their screams of pain are awful, they are literally crying for it to stop.");
				this.SpeechDelay(15.0, "And the one that set them on fire... is me.");
				this.SpeechDelay(20.0, "I completely stopped sleeping like a week ago now.");
				this.SpeechDelay(25.0, "...");
			}
			case 8:
			{
				this.Speech("That furry friend of yours who left, he was from Wildingen right?");
				this.SpeechDelay(5.0, "I bet he hates me huh? Yeah, in his place I would do the same.");
			}
			case 9:
			{
				this.Speech("If you feel uneasy, I can give you a hug. This atmosphere is kinda tense.");
				this.SpeechDelay(5.0, "Just keep it a secret from my people, they'd think I got soft.");
			}
			case 10:
			{
				this.Speech("Why im wearing red? oh that", "...");
				this.SpeechDelay(5.0, "You all wear red, don't want you to confuse me with the enemy.");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, KahmlsteinFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,120.0}, endingtextscroll);
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
	property float m_flIsAwayOrSomething
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	
	public KahmlsteinFollower(float vecPos[3], float vecAng[3],int ally, const char[] data)
	{
		KahmlsteinFollower npc = view_as<KahmlsteinFollower>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "50000", ally, true, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "steel_fists");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 0);

		if(StrContains(data, "void_wave") != -1)
		{
			npc.m_bScalesWithWaves = true;
		}
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
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/Robo_Heavy_Chief/Robo_Heavy_Chief.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/heavy/dec22_heavy_heating_style1/dec22_heavy_heating_style1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_heavy_camopants/sbox2014_heavy_camopants.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		AlreadySaidWin = false;
		if(npc.m_bScalesWithWaves)
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 125);
		}

		

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		if(Rogue_Mode())
		{
			// Cutscene Here
			npc.Speech("This is an urgent matter, so thanks for your assistance.");
			npc.SpeechDelay(5.0, "You'll get your reward later, no time to lose now.");
			Rogue_SetProgressTime(10.0, false);
			Rogue_RemoveNamedArtifact("Waldch Assistance");

			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == GogglesFollower_ID() && IsEntityAlive(other))
				{
					view_as<CClotBody>(other).m_bDissapearOnDeath = true;
					SmiteNpcToDeath(other);
					break;
				}
			}
		}

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	KahmlsteinFollower npc = view_as<KahmlsteinFollower>(iNPC);
	
	if(npc.m_flDeathAnimation)
	{
		npc.Update();
		KahmlDeath_DeathAnimationKahml(npc, GetGameTime());
		return;
	}

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(AlreadySaidWin)
	{
		if(npc.m_flIsAwayOrSomething)
		{
			CPrintToChatAll("{darkblue}카멜슈타인은 공허와 싸워갑니다. 당신이 이미 처참하게 살해당한 것도 모른채로 말이죠....");
			npc.m_flIsAwayOrSomething = 0.0;
		}		
		return;
	}
	//Do stuff if the being is here
	if(npc.m_bScalesWithWaves)
	{
		bool stop_thinking;
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != -1 && i_NpcInternalId[other] == VoidUnspeakableNpcID() && IsEntityAlive(other))
			{
				if(i_RaidGrantExtra[other] >= 15 && i_RaidGrantExtra[other] < 888)
				{
					npc.m_flDeathAnimation = GetGameTime() + 45.0;
					npc.m_iTarget = other;
					i_RaidGrantExtra[npc.index] = 2;
					npc.StopPathing();
					
					stop_thinking = true;
					break;
				}
				else if(i_RaidGrantExtra[other] >= 1 && i_RaidGrantExtra[other] < 15)
				{
					npc.StopPathing();
					if(!npc.m_flIsAwayOrSomething)
					{
						SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
						SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
						if(IsValidEntity(npc.m_iWearable1))
						{
							SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						if(IsValidEntity(npc.m_iWearable2))
						{
							SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						if(IsValidEntity(npc.m_iWearable3))
						{
							SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						if(IsValidEntity(npc.m_iWearable4))
						{
							SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						if(IsValidEntity(npc.m_iWearable5))
						{
							SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						if(IsValidEntity(npc.m_iWearable6))
						{
							SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						if(IsValidEntity(npc.m_iWearable7))
						{
							SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						if(IsValidEntity(npc.m_iWearable8))
						{
							SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMinDist", 1.0);
							SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMaxDist", 1.0);
						}
						b_NoHealthbar[npc.index] = 1;
						if(IsValidEntity(npc.m_iTeamGlow))
							RemoveEntity(npc.m_iTeamGlow);
						switch(GetRandomInt(0,3))
						{
							case 0:
							{
								CPrintToChatAll("{darkblue}카멜슈타인{default}: 넌 저 놈과 싸워야한다! 난 게이트 속에서 아무것도 나오지 못 하게 막고 있겠다!");
							}
							case 1:
							{
								CPrintToChatAll("{darkblue}카멜슈타인{default}: 내가 공허 쪽을 막겠다. 행운을 빈다.");
							}
							case 2:
							{
								CPrintToChatAll("{darkblue}카멜슈타인{default}: 넌 할 수 있다. 난 널 믿고 게이트를 막아내겠다.");
							}
							case 3:
							{
								CPrintToChatAll("{darkblue}카멜슈타인{default}: 여기서 우리가 같이 싸울 순 없어. 곧 쏟아져나올 공허 놈들도 막아야한다! 그리고 그건 내가 담당하겠다!");
							}
						}
					}
					npc.m_flIsAwayOrSomething = 1.0;
					stop_thinking = true;
					break;
				}
			}
		}
		if(stop_thinking)
			return;
	}
	if(npc.m_flIsAwayOrSomething)
	{
		b_NoHealthbar[npc.index] = 0;
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 0.0);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		if(IsValidEntity(npc.m_iWearable2))
		{
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		if(IsValidEntity(npc.m_iWearable3))
		{
			SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		if(IsValidEntity(npc.m_iWearable4))
		{
			SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		if(IsValidEntity(npc.m_iWearable5))
		{
			SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		if(IsValidEntity(npc.m_iWearable6))
		{
			SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		if(IsValidEntity(npc.m_iWearable7))
		{
			SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		if(IsValidEntity(npc.m_iWearable8))
		{
			SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMaxDist", 0.0);
		}
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 방금 돌아왔다. 네가 무사하길 바래야겠군.");
			}
			case 1:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 놈을 처치한건가? 비록 그 놈은 얼마 지나지 않아 곧 돌아올 테지만.");
			}
			case 2:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 뭔가 이상해. 저 놈은 자신의 의지대로 움직이는것 같진 않다. 마치 무언가에 조종이라도 당하는 것처럼.");
			}
			case 3:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 공허와 싸워나갈수록 이 공허란게 감염과는 별개의 존재라는 느낌이 든다.");
			}
		}
		
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		
		SetVariantColor(view_as<int>({184, 56, 59, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		npc.m_flIsAwayOrSomething = 0.0;
	}

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

		npc.StartPathing();
		
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
						float damage = 7500.0;
						if(npc.m_bScalesWithWaves)
						{
							damage = 80.0;
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
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}

		npc.SetActivity("ACT_MP_RUN_MELEE");
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
		npc.SetActivity("ACT_MP_STAND_MELEE");

		if(target < 1)
			npc.SpeechTalk(ally);
	}
}

static void ClotDeath(int entity)
{
	KahmlsteinFollower npc = view_as<KahmlsteinFollower>(entity);

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




void KahmlDeath_DeathAnimationKahml(KahmlsteinFollower npc, float gameTime)
{
	if(npc.m_flDeathAnimationCD < gameTime)
	{
		GiveProgressDelay(5.0);
		if(IsValidEntity(npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 15000.0);
		}
		npc.m_flDeathAnimationCD = gameTime + 3.0;

		switch(i_RaidGrantExtra[npc.index])
		{
			case 2:
			{
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
				for(int LoopTryAlotAlot = 0; LoopTryAlotAlot <= 10; LoopTryAlotAlot++)
				{
					float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
						
					float PreviousPos[3];
					WorldSpaceCenter(npc.index, PreviousPos);
					//randomly around the target.
					vecTarget[0] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
					vecTarget[1] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
					
					bool Succeed = Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, false);
					if(Succeed)
					{
						ParticleEffectAt(PreviousPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
						ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						break;
					}
				}
				if(npc.m_flIsAwayOrSomething)
				{
					b_NoHealthbar[npc.index] = 0;
					SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
					SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 0.0);
					if(IsValidEntity(npc.m_iWearable1))
					{
						SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iWearable2))
					{
						SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iWearable3))
					{
						SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iWearable4))
					{
						SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iWearable5))
					{
						SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iWearable6))
					{
						SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iWearable7))
					{
						SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iWearable8))
					{
						SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMaxDist", 0.0);
					}
					if(IsValidEntity(npc.m_iTeamGlow))
						RemoveEntity(npc.m_iTeamGlow);
					npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
					
					SetVariantColor(view_as<int>({184, 56, 59, 200}));
					AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
					npc.m_flIsAwayOrSomething = 0.0;
				}
				float vecTarget2[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget2 );
				CreateEarthquake(vecTarget2, 2.5, 350.0, 16.0, 255.0);
				npc.AddActivityViaSequence("taunt_bare_knuckle_beatdown_outro");
				TE_Particle("asplode_hoodoo", vecTarget2, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.2);
				npc.SetPlaybackRate(0.50);
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 그렇겐 못 한다!");
				SetEntityRenderMode(npc.index, RENDER_NORMAL);
				SetEntityRenderColor(npc.index, 255, 255, 255, 255);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 255);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 255);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 255);
				SetEntityRenderMode(npc.m_iWearable7, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 255);
				npc.PlayBobMeleePostHit();
				npc.m_flDeathAnimationCD = gameTime + 2.0;
				CPrintToChatAll("{purple}!?!?!?!?!?!?!?");
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						Music_Stop_All(client); //This is actually more expensive then i thought.
						SetMusicTimer(client, GetTime() + 4);
					}
				}
				if(IsValidEntity(npc.m_iTarget))
				{
					float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
					npc.FaceTowards(vecTarget, 15000.0);
					npc.PlayDeathSound(npc.m_iTarget);
					RequestFrames(KillNpc, 2, EntIndexToEntRef(npc.m_iTarget));
				}
			}
			case 3:
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#music/hl2_song23_suitsong3.mp3");
				music.Time = 150;
				music.Volume = 0.6;
				music.Custom = false;
				strcopy(music.Name, sizeof(music.Name), "...");
				strcopy(music.Artist, sizeof(music.Artist), "...");
				Music_SetRaidMusic(music);

				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.AddActivityViaSequence("taunt_heavy_workout_end");
				npc.SetCycle(0.25);
				npc.SetPlaybackRate(0.0);
			}
			case 4:
			{
				npc.m_flDeathAnimationCD = gameTime + 2.0;
				CPrintToChatAll("{darkblue}카멜슈타인{default}: ..마침내 싸울만한 상대를 만나게 되었군..");
			}
			case 5:
			{
				float flPos[3];
				float flAng[3];
				npc.m_flDeathAnimationCD = gameTime + 2.0;
				CPrintToChatAll("{darkblue}카멜슈타인{default}: *기침*");
				npc.PlayCoughSound();
				npc.GetAttachment("head", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "blood_trail_red_01_goop", 4.0); //This is a permanent particle, gotta delete it manually...
				CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 6:
			{
				npc.m_flDeathAnimationCD = gameTime + 2.0;
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 오... 피가 정말 많이 나오는군.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 7:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 하지만 우리가 해냈다. 공허의 영향력은 사라지고 있다.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 8:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 다른 얼간이가 공허를 건드리지 않는 한, 다시는 돌아오지 않을 거다.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 9:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 그리고 저 놈들이 사라지면... 내 불멸 능력도 이제 사라지게 되겠지. 그리고 어쩌면 이게 더 나을 수도 있다.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 10:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 이제 난 돌아갈래야 돌아갈 수가 없기 때문이지.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 11:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: ...너무 많이 죽였거든.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 12:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 너무 많이 죽이면 뭐가 뭔지 알 수 없게 된다는 말이 있었지. 솔직히 맞는 말이었다.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 13:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 그리고 난 혼돈에 물들기 전에도 한낮 쓰레기에 불과했고.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 14:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 내가 한 짓들을 도저히 잊을 수 없다..");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 15:
			{
				float flPos[3];
				float flAng[3];
				npc.m_flDeathAnimationCD = gameTime + 2.0;
				CPrintToChatAll("{darkblue}카멜슈타인{default}: *기침*");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
				npc.GetAttachment("head", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "blood_trail_red_01_goop", 4.0); //This is a permanent particle, gotta delete it manually...
				CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
			}
			case 16:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 그래.. 지베리아가 날 데리러 오고 있다.. 저 빛줄기와 함께.");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 17:
			{
				CPrintToChatAll("{darkblue}카멜슈타인{default}: 너희들. 나와 끝까지 함께 해줘서, 정말 고맙다...");
				npc.PlayCoughSound();
				npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			}
			case 18,19,20,21,22:
			{
		//		npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
				CPrintToChatAll("{darkblue}카멜슈타인{default}: ... 공허가 다시는 돌아오지 않도록...");
				if(IsValidEntity(npc.index))
				{
					HideAllNpcCosmetics(npc.index);
					RequestFrames(KillNpc, 45, EntIndexToEntRef(npc.index));
				}
				for (int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
					{
						Items_GiveNamedItem(client, "Kahmlsteins Last Will");
						CPrintToChat(client,"{default}당신이 얻은 것은...: {red}''카멜슈타인의 유언장''{default}.");
					}
				}
			}
		}
		i_RaidGrantExtra[npc.index]++;
	}
}

void HideAllNpcCosmetics(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(npc.m_iWearable1), TIMER_FLAG_NO_MAPCHANGE);
	
	if(IsValidEntity(npc.m_iWearable2))
		CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(npc.m_iWearable2), TIMER_FLAG_NO_MAPCHANGE);
	
	if(IsValidEntity(npc.m_iWearable3))
		CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(npc.m_iWearable3), TIMER_FLAG_NO_MAPCHANGE);
	
	if(IsValidEntity(npc.m_iWearable4))
		CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(npc.m_iWearable4), TIMER_FLAG_NO_MAPCHANGE);
	
	if(IsValidEntity(npc.m_iWearable5))
		CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(npc.m_iWearable5), TIMER_FLAG_NO_MAPCHANGE);
	
	if(IsValidEntity(npc.m_iWearable6))
		CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(npc.m_iWearable6), TIMER_FLAG_NO_MAPCHANGE);
	
	if(IsValidEntity(npc.m_iWearable7))
		CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(npc.m_iWearable7), TIMER_FLAG_NO_MAPCHANGE);
	
	CreateTimer(0.1, Prop_Gib_FadeSet, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}