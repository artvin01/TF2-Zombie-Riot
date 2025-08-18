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
						this.Speech("Just steal it.");
					
					case 1:
						this.Speech("Let's just leave.");
				}
			}
			else
			{
				switch(GetURandomInt() % 3)
				{
					case 0:
						this.Speech("You still have to pay?");
					
					case 1:
						this.Speech("We're going to be here forever", "...");
					
					case 2:
						this.Speech("How would these items help?");
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
						this.Speech("Haha", "...");
					}
					case 1:
					{
						this.Speech("Hehe", "...");
					}
					case 2:
					{
						this.Speech("I really like spiders.");
					}
					case 3:
					{
						this.Speech("God my head hurts.");
					}
					case 4:
					{
						this.Speech("What are we doing again?");
					}
					case 5:
					{
						this.Speech("Wildingen ", "is fine.");
					}
					case 6:
					{
						this.Speech("What's making my headache flare up?");
					}
					case 7:
					{
						this.Speech("I hope you aren't doing something stupid.");
					}
					case 8:
					{
						this.Speech("Gahh", "...");
					}
					case 9:
					{
						this.Speech("Feels like something is stabbing me.");
					}
					case 10:
					{
						this.Speech("I really can't focus right now.");
					}
					case 11:
					{
						this.Speech("Shut up.");
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
						this.Speech("Good grief.");
					}
					case 15:
					{
						this.Speech("Let's take a break.");
					}
					case 16:
					{
						this.Speech("Something isn't right.");
					}
					case 17:
					{
						this.Speech("S", "ilvester");
					}
					case 18:
					{
						this.Speech("I feel like I'm going insane.");
					}
					case 19:
					{
						this.Speech("These fights are healthy.");
					}
					case 20:
					{
						if(Rogue_CurseActive())
							this.Speech("You look hot.");
					}
					case 21:
					{
						if(Rogue_CurseActive())
							this.Speech("I don't need this weather right now.");
					}
					case 22:
					{
						this.Speech("You aren't helping.");
					}
					case 23:
					{
						this.Speech("Why am I sticking with you again?");
					}
					case 24:
					{
						if(Rogue_GetIngots() > 49)
							this.Speech("Stop greeding!");
					}
					case 25:
					{
						this.Speech("Nuh-uh.");
					}
					case 26:
					{
						this.Speech("Buy something else.");
					}
					case 27:
					{
						this.Speech("You tried that before.");
					}
					case 28:
					{
						this.Speech("Do you even know where you're going?");
					}
					case 29:
					{
						this.Speech("I hate this.");
					}
					case 30:
					{
						this.Speech("Sigh", "...");
					}
					case 31:
					{
						this.Speech("Hahahaha", "hahaha");
					}
					case 32:
					{
						this.Speech("I need help, Silvester.");
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
						this.Speech("How did you even find me anyways?");
					}
					case 1:
					{
						this.Speech("Chaos right?");
						this.SpeechDelay(5.0, "I wish I knew before I left Wildingen.");
					}
					case 2:
					{
						this.Speech("Silvester is fine right now.");
					}
					case 3:
					{
						this.Speech("I'm sorry about beating up you guys before", "...");
						this.SpeechDelay(5.0, "...you know, Xeno.");
					}
					case 4:
					{
						this.Speech("Heh, you guys taking out Xeno and Seaborn.");
						this.SpeechDelay(5.0, "Chaos shouldn't be hard for you.");
					}
					case 5:
					{
						this.Speech("All this traveling makes me tired.");
					}
					case 6:
					{
						this.Speech("You know I'm a fox?");
						this.SpeechDelay(5.0, "Don't call me a furry you got cats with you.");
					}
					case 7:
					{
						this.Speech("I thought for sure Seaborn would get you back there.");
					}
					case 8:
					{
						this.Speech("Why you like spray painting everywhere?");
					}
					case 9:
					{
						if(Rogue_CurseActive())
							this.Speech("Just your normal weather out here.");
					}
					case 10:
					{
						if(Rogue_CurseActive())
							this.Speech("Red moons seems to piss everyone off, except me", "...");
					}
					case 11:
					{
						if(Rogue_GetIngots() > 49)
							this.Speech("I hope you aren't doing this for the money", "...");
					}
					case 12:
					{
						if(Rogue_GetIngots() > 99)
							this.Speech("Why are you hoarding all that australium?");
					}
					case 13:
					{
						this.Speech("How do you even get your weapons like that?");
					}
					case 14:
					{
						this.Speech("How heavy are those buildings you carry?");
					}
					case 15:
					{
						this.Speech("Does... my gun work on your", "...");
						this.SpeechDelay(5.0, "Nevermind.");
					}
					case 16:
					{
						this.Speech("You mean you can just see what enemies are out?");
					}
					case 17:
					{
						this.Speech("No I won't make Bob the Second my god.");
					}
					case 18:
					{
						this.Speech("You people are crazy", "...");
					}
					case 19:
					{
						this.Speech("So how does one just, make units out of that tower?");
					}
					case 20:
					{
						this.Speech("Funny enough, I have a phobia of water.");
						this.SpeechDelay(5.0, "and Seaborn", "...");
					}
					case 21:
					{
						this.Speech("I like seafood but can't have that anymore.");
					}
					case 22:
					{
						this.Speech("What is this 'chat' your refering to?");
					}
					case 23:
					{
						this.Speech("Discord? Is this what you call chaos?");
					}
					case 24:
					{
						this.Speech("Don't start a cult, not now.");
					}
					case 25:
					{
						this.Speech("I used to be an engineer for Wildingen.");
						this.SpeechDelay(5.0, "Those were the days", "...");
					}
					case 26:
					{
						this.Speech("Have you ever noticed there's just gold on the ground?");
					}
					case 27:
					{
						this.Speech("You really think the solution is to beat people up?");
					}
					case 28:
					{
						this.Speech("Mmm", "...");
					}
					case 29:
					{
						this.Speech("Hmm", "...");
					}
					case 30:
					{
						this.Speech("I'm cold.");
					}
					case 31:
					{
						this.Speech("I get nightmares about Wildingen", "...");
						this.SpeechDelay(5.0, "It wants me there, for the wrong reason", "...");
					}
					case 32:
					{
						this.Speech("I'm tired of fighting", "...");
					}
					case 33:
					{
						this.Speech("All this chaos stuff makes my head hurt.");
					}
					case 34:
					{
						this.Speech("I miss Silvester.");
					}
					case 35:
					{
						this.Speech("Silvester was actually the one who gave me this halo.");
					}
					case 36:
					{
						this.Speech("I worry about the Wildingen and Expidonsa alliance.");
					}
					case 37:
					{
						this.Speech("I hate those Medieval guys.");
					}
					case 38:
					{
						this.Speech("I still wonder how did Chaos get into Wildingen.");
					}
					case 39:
					{
						this.Speech("You wouldn't have happen to", "...");
						this.SpeechDelay(5.0, "Nevermind.");
					}
					case 40:
					{
						this.Speech("I remember Seaborn crawling through the water supply.");
						this.SpeechDelay(5.0, "Wildingen had to trap down all the rivers, heh.");
					}
					case 41:
					{
						this.Speech("Wildingen really likes to set up traps everywhere by the way.");
						this.SpeechDelay(5.0, "You started coming here without me you know.");
					}
					case 42:
					{
						this.Speech("You started coming here without me you know.");
					}
					case 43:
					{
						this.Speech("Luckily Xeno wasn't a problem at the time for Wildingen.");
					}
					case 44:
					{
						this.Speech("Funny that Xeno and Seaborn hated each other so much.");
					}
					case 45:
					{
						this.Speech("Funny that my grief was Seaborn and Xeno was Silvester's");
						this.SpeechDelay(5.0, "Sorry shouldn't joke like that.");
					}
					case 46:
					{
						this.Speech("I heard that chaos just stops us from leaving the planet.");
					}
					case 47:
					{
						this.Speech("How did you even wind up here in the first place?");
					}
					case 48:
					{
						this.Speech("Yeah I heard Boss vs Boss, a video game right?");
					}
					case 49:
					{
						this.Speech("You have fun fighting people?");
						this.SpeechDelay(5.0, "You guys really are insane.");
					}
					case 50:
					{
						this.Speech("I wonder what Silvester is doing now", "...");
					}
					case 51:
					{
						this.Speech("I already know the zombies are rioting.");
					}
					case 52:
					{
						this.Speech("I can read some ancient texts, probably in the desert.");
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
					this.Speech("Die later.");
				
				case 1:
					this.Speech("Enough slacking around.");
				
				case 2:
					this.Speech("I don't have time for this.");
				
				case 3:
					this.Speech("Go on, keep shooting.");
				
				case 4:
					this.Speech("You ain't living forever.");
			}
		}
		else
		{
			switch(GetURandomInt() % 6)
			{
				case 0:
					this.Speech("Don't die on me", "...");
				
				case 1:
					this.Speech("I got more people to save.");
				
				case 2:
					this.Speech("Enough dead people around.");
				
				case 3:
					this.Speech("Come on, get up.");
				
				case 4:
					this.Speech("You're going to be ok.");
				
				case 5:
					this.Speech("It's gonna be alright.");
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

				//cannot heal
				ApplyStatusEffect(npc.index, npc.index, "Anti-Waves", 999999.0);
				
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
				npc.SetGoalEntity(ally);
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
			npc.SetGoalEntity(ally);
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
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
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
		npc.Speech("It's over.");
		npc.SpeechDelay(4.0, "Chaos will not harm Wildingen anymore.");
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