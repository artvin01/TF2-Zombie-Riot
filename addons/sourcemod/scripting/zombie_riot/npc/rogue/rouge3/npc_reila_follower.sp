#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void ReilaFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Reila");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_reila_follower");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}


int ReilaFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ReilaFollower(vecPos, vecAng);
}

static Action ReilaFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<ReilaFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap ReilaFollower < CClotBody
{
	public void SpeechTalk(int client)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 26)
		{
			case 0:
			{
				this.Speech("Good thing I was able to get this speech translator working.");
				this.SpeechDelay(5.0, "Our language is quite... unique.");
			}
			case 1:
			{
				this.Speech("About what happened before... sorry for attacking you guys.");
				this.SpeechDelay(7.0, "I was too stubborn to see the consequences of what I was trying to do.");
				this.SpeechDelay(12.0, "Oh, and the language barrier definitely didn't help.");
			}
			case 2:
			{
				this.Speech("I never got to see if my construct actually worked.");
				this.SpeechDelay(5.0, "Although that's probably for the best...");
			}
			case 3:
			{
				this.Speech("The Almagest Corporation...");
				this.SpeechDelay(5.0, "They're obsessed with this place, and harnessing the power of the Void by any means.");
				this.SpeechDelay(12.0, "I have no idea what use they'd have for such a power, but whatever it is, it can't be good.");
			}
			case 4:
			{
				this.Speech("I used to work for Almagest as a researcher.");
				this.SpeechDelay(5.0, "Without my work, they never would've had the means to get here...");
				this.SpeechDelay(10.0, "I should've realized what they were up to sooner...");
			}
			case 5:
			{
				this.Speech("I ran as soon as I realized Almagest were trying to harness the Void.");
				this.SpeechDelay(5.0, "To try and exploit a power like that... what a foolish endeavor.");
				this.SpeechDelay(10.0, "But I won't allow them. I'm going to stop them, no matter what.");
			}
			case 6:
			{
				this.Speech("A split dimension, and the bridge between dimensions being the birthplace of Void...");
				this.SpeechDelay(9.0, "Trust me, I was just as surprised as you lot once I found out.");
			}
			case 7:
			{
				this.Speech("You want to know more about my world..?");
				this.SpeechDelay(5.0, "To be quite honest, it isn't a whole lot better than the plight your world's in.");
			}
			case 8:
			{
				this.Speech("Just a band of mercenaries risking their lives to set things right, huh?");
				this.SpeechDelay(7.0, "Or... is there something else you're looking for inside this forsaken place?");
			}
			case 9:
			{
				this.Speech("What happened to my arm and face?");
				this.SpeechDelay(5.0, "I don't really like to talk about it...");
			}
			case 10:
			{
				this.Speech("Call me a robot again and I'll manually rewire your brain.");
			}
			case 11:
			{
				this.Speech("Beep boop.");
			}
			case 12:
			{
				this.Speech("Those Voidstones... they're the purest form of Void we've ever seen.");
				this.SpeechDelay(7.0, "Make sure you use them wisely.");
			}
			case 13:
			{
				this.Speech("The one leading Almagest into the Curtain... his name is Jkei.");
				this.SpeechDelay(5.0, "He's a cold-blooded warrior, and he won't give in until his job is complete.");
				this.SpeechDelay(12.0, "Do not underestimate his strength.");
			}
			case 14:
			{
				this.Speech("The Umbrals aren't mindless. They demonstrate some aspect of free will.");
				this.SpeechDelay(7.0, "Although, something is forcing them to blind hostility...");
				this.SpeechDelay(12.0, "Whatever it is, we need to put an end to it.");
			}
			case 15:
			{
				this.Speech("A being made of impure Void invaded your world?");
				this.SpeechDelay(5.0, "So even before the rifts opened, the Void fought to set itself free...");
			}
			case 16:
			{
				this.Speech("Almagest tried to set up a lab within the Curtain's outskirts.");
				this.SpeechDelay(7.0, "It ended up abandoned, it's personnel either having died or ran away.");
			}
			case 17:
			{
				this.Speech("Jkei and his forces stationed themselves within the depths of the palace.");
				this.SpeechDelay(7.0, "Seems like they already found the source of this place's power...");
			}
			case 18:
			{
				this.Speech("Bob... he seems like he's been through a lot.");
				this.SpeechDelay(5.0, "I admire his will to continue fighting.");
			}
			case 19:
			{
				this.Speech("Twirl has certainly demonstrated her mastery in magic.");
				this.SpeechDelay(5.0, "Although... don't you think she should be taking things a bit more seriously?");
			}
			case 20:
			{
				this.Speech("The one you call Vhxis, he has some control over Void...");
				this.SpeechDelay(5.0, "What a terrifying power, let's be glad he's on our side.");
				this.SpeechDelay(12.0, "...wait, you're saying you've FOUGHT him before!?");
			}
			case 21:
			{
				this.Speech("The one you call Whiteflower, he seems to be behind a lot of the troubles your group ends up in.");
				this.SpeechDelay(9.0, "Let's hope his influence didn't spread to the Curtain...");
			}
			case 22:
			{
				this.Speech("I'd like to see more of your world someday.");
				this.SpeechDelay(5.0, "All the different places and cultures... it's a nice change of pace.");
			}
			case 23:
			{
				this.Speech("My cybernetic arm is equipped with dozens of different weapons.");
				this.SpeechDelay(5.0, "Trust me, I can hold my own here.");
			}
			case 24:
			{
				this.Speech("My favorite drink..?");
				this.SpeechDelay(5.0, "Strawberry lemonade.");
			}
			case 25:
			{
				this.Speech("That bald man with a shotgun...");
				this.SpeechDelay(5.0, "How'd he manage to get inside the Curtain unharmed AND set up a store?");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void SpeechRevive()
	{
		if((this.m_flNextIdleSound + 14.0) > GetGameTime(this.index))
			return;
		
		switch(GetURandomInt() % 5)
		{
			case 0:
			{
				this.Speech("Get up. We still need to set things right.");	
			}
			case 1:
			{
				this.Speech("I won't let it end like this.");	
			}
			case 2:
			{
				this.Speech("You beat me, I'm sure you can manage these guys.");	
			}
			case 3:
			{
				this.Speech("It's not over yet, come on.");	
			}
			case 4:
			{
				this.Speech("For our sake I hope that was just warm-up.");	
			}
		}

		this.m_flNextIdleSound = GetGameTime(this.index) + 35.0;
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, ReilaFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		static int color[4] = {255, 200, 255, 255};
		NpcSpeechBubble(this.index, speechtext, 5, color, {0.0,0.0,100.0}, endingtextscroll);
	}
	
	public ReilaFollower(float vecPos[3], float vecAng[3])
	{
		ReilaFollower npc = view_as<ReilaFollower>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "50000", TFTeam_Red, true, false));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_STAND_ITEM2");
		KillFeed_SetKillIcon(npc.index, "short_circuit");
		
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

		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec23_boarders_beanie_style2/dec23_boarders_beanie_style2_engineer.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_zipper_suit/sbox2014_zipper_suit_engineer.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_delldozer_style3/hwn2024_delldozer_style3.mdl");
		SetEntityRenderColor(npc.m_iWearable4, 120, 55, 100, 255);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/robotarm_silver/robotarm_silver_gem.mdl");
		SetEntityRenderColor(npc.m_iWearable5, 100, 55, 190, 255);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/fall2013_the_special_eyes_style1/fall2013_the_special_eyes_style1_engineer.mdl");
		SetEntityRenderColor(npc.m_iWearable6, 120, 55, 100, 255);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;
		//npc.Speech("Thanks for helping me.");
		
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	ReilaFollower npc = view_as<ReilaFollower>(iNPC);

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
	{
		i_Target[npc.index] = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index, _, 2000.0, true, _, _, _, true, 150.0, true, true);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		ally = GetClosestAllyPlayerGreg(npc.index);
		if(!ally)
		{
			ally = GetClosestAllyPlayer(npc.index);
			npc.m_iTargetWalkTo = ally;
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
		
		BossReilaSelfDefense(view_as<BossReila>(npc), gameTime, target, GetVectorDistance(vecSelf, vecTarget, true));
	}
	else
	{
		npc.m_flAttackHappens = 0.0;
	}

	if(npc.m_bPathing)
	{
		npc.m_flSpeed = 320.0;
		npc.SetActivity("ACT_MP_RUN_ITEM2");
	}
	else
	{
		npc.m_flSpeed = 1.0;

		if(crouching)
		{
			npc.SetActivity("ACT_MP_CROUCH_ITEM2");
		}
		else
		{
			npc.SetActivity("ACT_MP_STAND_ITEM2");
		}
	}
}

static void ClotDeath(int entity)
{
	ReilaFollower npc = view_as<ReilaFollower>(entity);

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
