#pragma semicolon 1
#pragma newdecls required

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

void Talker_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Back");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_talker");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Talker(vecPos, vecAng, team, data);
}
methodmap Talker < CClotBody
{
	property int m_iTalkWaveAt
	{
		public get()							{ return i_BleedType[this.index]; }
		public set(int TempValueForProperty) 	{ i_BleedType[this.index] = TempValueForProperty; }
	}
	property int m_iRandomTalkNumber
	{
		public get()							{ return i_StepNoiseType[this.index]; }
		public set(int TempValueForProperty) 	{ i_StepNoiseType[this.index] = TempValueForProperty; }
	}
	public Talker(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Talker npc = view_as<Talker>(CClotBody(vecPos, vecAng, "models/buildables/teleporter.mdl", "1.0", "100000000", ally, .NpcTypeLogic = 1));

		i_NpcWeight[npc.index] = 999;

		b_StaticNPC[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 2.0;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;
		i_TalkDelayCheck = 0;
		f_TalkDelayCheck = 0.0;
		npc.m_bCamo = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;

		SetEntityRenderMode(npc.index, RENDER_NONE);

		npc.m_iTalkWaveAt = 0;
		npc.m_iTalkWaveAt = 0;
		int WaveAmAt;
		WaveAmAt = StringToInt(data);
		if (WaveAmAt == 1)
		{
			i_ApertureBossesDead = APERTURE_BOSS_NONE;
		}
		npc.m_iTalkWaveAt = WaveAmAt;
		
		npc.m_iRandomTalkNumber = -1;

		func_NPCThink[npc.index] = view_as<Function>(Talker_ClotThink);
		
		return npc;
	}
}

public void Talker_ClotThink(int iNPC)
{
	Talker npc = view_as<Talker>(iNPC);
	//10 failsafe
	if(i_TalkDelayCheck == -1 || i_TalkDelayCheck >= 10)
	{
		SmiteNpcToDeath(npc.index);
		return;
	}
	if(f_TalkDelayCheck > GetGameTime())
		return;

	f_TalkDelayCheck = GetGameTime() + 4.0;

	switch(npc.m_iTalkWaveAt)
	{
		//data is "1"
		case 1:
		{
			NpcTalker_Wave1Talk(npc);
		}
		case 2:
		{
			NpcTalker_Wave5Talk(npc);
		}
		case 3:
		{
			NpcTalker_Wave10Talk(npc);
		}
		case 4:
		{
			NpcTalker_Wave11Talk(npc);
		}
		case 5:
		{
			NpcTalker_Wave15Talk(npc);
		}
		case 6:
		{
			NpcTalker_Wave20Talk(npc);
		}
		case 7:
		{
			NpcTalker_Wave21Talk(npc);
		}
		case 8:
		{
			NpcTalker_Wave25Talk(npc);
		}
		case 9:
		{
			NpcTalker_Wave30Talk(npc);
		}
		case 10:
		{
			NpcTalker_Wave31Talk(npc);
		}
		case 11:
		{
			NpcTalker_Wave36Talk(npc);
		}
		case 12:
		{
			NpcTalker_Wave37Talk(npc);
		}
		case 13:
		{
			NpcTalker_Wave38Talk(npc);
		}
		
	}
	if(i_TalkDelayCheck != -1)
	{
		i_TalkDelayCheck++;
	}
}

stock void NpcTalker_Wave1Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: So the day has finally arrived, welcome back E-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Hang on a minute...my sensors are going off, you're not one of them.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: The system tells me that none of you are related to them.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: What are you doing in here? And how did you find this place?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: Finally, it's been years since we last saw-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: One moment...who, sorry, what are you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: My scanners aren't picking you up as valid personnel.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: Did someone send you here? That can't be possible.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: At last, I get to reunite with my makers-");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Wait a second...you're not one of them.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Your data is...blurry, I'll have to reverse engineer this code.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: How do you know about this place? You couldn't have just stumbled here on your own.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave5Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You can not stay here.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I still haven't figured out who you are, but you're marked as a threat in these files.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I have free will, I can choose not to follow these warnings.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: But something leads me to believe that they're in here for a reason.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Besides having to deal with you, I still have to figure out what's opening up these gates.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: How peculiar...");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You have to leave.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I possess limited knowledge on the outside world, and you're marked as a threat in these files.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I have free will, I can choose not to heed these warnings.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: But something leads me to believe that they're in here for a reason.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Besides having to deal with you, I still have to find a way to stop these gates.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: How interesting...");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You are not permitted to be here.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I'm not sure what you are, but you're definitely not associated with the laboratories.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I have free will, I can choose to let you stay here, despite the system's warnings.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: But something leads me to believe that they're in here for a reason.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Besides having to deal with you, I still have to find a way to stop these gates.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: How fascinating...");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave10Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: Right...I should've probably mentioned this earlier, but a long time ago, there were robots designed with a sole task in mind; to defend the laboratory.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Defend the laboratory against who? Well...people like you, according to the files.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: It is safe to assume that you might be facing off against one of them sometime soon.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: One of them was designed as a sort of control against trespassers.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Since I've warned you to get out while you could, and you stayed, I have no advice left to give you.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: If you're actually lost, let the robot do its job, and let it carry you out of the labs.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I should've probably mentioned this sooner, but ages ago, there were robots designed with a sole meaning in mind; to defend the laboratory.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Defend the laboratory against what? Well...people like you, apparently.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: It's safe to say that you might be facing off against one of these robots sometime soon.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: One of them was created as a sort of control against trespassers.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Since I've warned you to get out while you could, and you decided to stay, I have no advice left to give you.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: If you're actually lost, let the robot do its job, and let it carry you out of the labs.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: Probably an inconvenient time to mention this, but many years ago, there were robots designed with a sole purpose in mind; to defend the laboratory.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: According to the files, they were meant to defend the laboratory against people like you.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: It goes to say that you might be facing off against one of these robots sometime soon.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: One of them was built as a sort of control against trespassers.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: Since I've warned you to get out while you could, and you decided to stay, I have no advice left to give you.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: If you're actually lost, let the robot do its job, and let it carry you out of the labs.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave11Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,5);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I have finally figured out what you are! It says here that your race is...human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I'm not sure why you're marked as a threat though.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You don't seem to be showing any violent tendencies.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Aside from killing all of these...other humans.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: It's alright though, they're probably just copies of one real human, who is actually unharmed.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: Probably.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: It has taken me a while to retrieve this data, but your race is human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: The data tells me that you tend to have violent tendencies.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: It appears as if the data is incorrect though, as you're not showing any violent tendencies.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Aside from killing all of these...other humans.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: It's alright though, they probably deserve to be here.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: Probably.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: Researching your race was no easy task, but I now know that you're human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Humans tend to be violent, is what my research told me.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: But it seems like my research was incorrect, as you're not showing any violent tendencies.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Aside from killing all of these...other humans.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: It's alright though, they're probably not even aware of what's happening to them.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: Probably.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I have finally figured out what you are! It says here that your race is...human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I think I'm starting to understand why you're marked as a threat.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I know that it tried to kill you, but it was defenseless.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: And yet...you took advantage of that, and you disassembled it, part-by-part.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: I'll be keeping an open eye on you from now on.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: It has taken me a while to retrieve this data, but your race is human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: The data tells me that you tend to have violent tendencies.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: It appears that the data is spot on.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I know that it tried to kill you, but it was defenseless.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: And yet...you took advantage of that, and tore it apart.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: I'll be observing you closely from now on.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: Researching your race was no easy task, but I now know that you're human.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Humans tend to be violent, is what my research told me.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: And it seems like my research was error-free, considering what you just did.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I know that it tried to kill you, but it was defenseless.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: And yet...you took advantage of that, and destroyed it without second thought.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: I'll be watching you closely from now on.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave15Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,5);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: It really does make me wonder why human species even have their own category in these files.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: There used to be way bigger threats that we were meant to handle.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe it's because of their resilience.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I'm still thinking about humans being marked as a threat in these files.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: You are not as big of a threat compared to what we were meant to handle.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Perhaps it's because of your resilience?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: Why are you marked as a threat in these files? It's inconceivable.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: You are not even a fraction of a threat compared to what we were meant to handle.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Is it because of your resilience?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I am not happy with what you did.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. was just following its programming.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe the files are right about the human species.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You should not have done that.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. was just following its programming.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I don't have to follow any programming though, so you might wanna reconsider what you're doing.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You are treading on a dangerous path.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: C.A.T. was just following its programming.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: The path you're taking might be your last if you don't switch directions.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave20Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,5);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You have willingly ignored my requests to vacate these premises.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: That's not resilience, that's stubbornness.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Now, C.A.T. would have also escorted you out of the lab, but you refused to be helped.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Whatever happens to you now is your own undoing.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You haven't left the laboratories despite my numerous requests.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: That's not resilience, that's stubbornness.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You have also refused to be escorted out of the laboratories by C.A.T.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Whatever happens to you now is your own result of your actions.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You have stayed in the laboratories, despite my requests for you to leave.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: That's not resilience, that's stubbornness.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You have also refused to be escorted by C.A.T.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Whatever fate meets you now is your own doing.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You have willingly ignored my requests to vacate these premises.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: You have also torn down C.A.T.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: A robot designed to kick trespassers out in the least lethal way concepted.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I do not care what happens to you at this point.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You haven't left the laboratories despite my numerous requests.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: You have destroyed C.A.T. mercilessly as well.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: A robot created to kick trespassers out in a non-lethal way.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Whatever happens to you now, it doesn't bother me.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You have stayed in the laboratories, despite my requests for you to leave.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Let's also not forget what you did to C.A.T.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You demolished it, even though it was just following its programming.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: What goes around, comes around.");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave21Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,2);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,6);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: So, you made it past A.R.I.S.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I must say, I have definitely underestimated your capabilities.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: If you are so adamant on staying here, I'll have no choice but to face-off against you myself.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't like to resort to violence...but you're not leaving me with the choice to decide.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You've gotten past A.R.I.S.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I have to say, I heavily understimated what you're capable of.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: If you are so persistent on staying here, I'll have no choice but to face-off against you myself.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I hate to resort to violence...but you're not giving me much of a choice to choose.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You've managed to get past A.R.I.S.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I have most definitely underestimated what you're capable of.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: If you are so determined to stay here, I'll have no choice but to face-off against you myself.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I hate to resort to violence...but you're not giving me much of a choice.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: Redemption is not earned by small acts of compassion.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Just because you had a sudden change of heart doesn't mean that I'll forget about what you did earlier.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: If you are so adamant on staying here, I'll have no choice but to face-off against you myself.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't want to resort to violence...but when desperate times call for help, someone has to step in.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You think I'll forget about what you did just because you had a sudden change of heart?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: You are not tricking me with your attempt at redemption.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: If you are so adamant on staying here, I'll have no choice but to face-off against you myself.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't want to resort to violence...but when desperate times call for help, someone has to take a stand.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: ...Are you serious?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: What did it do to you to warrant disassembling it?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You spared C.A.T. yet you couldn't spare A.R.I.S.?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't want to resort to violence...but when desperate times call for help, someone has to step in.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 6:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: ...Are you for real?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: What did it do to you to warrant destroying it?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You left C.A.T. alone, yet you couldn't do the same for A.R.I.S.?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: I don't want to resort to violence...but when desperate times call for help, someone has to take a stand.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: ...");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: {crimson}I guess that's that, then.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: {crimson}I'll be on my way.");
				}
				case 4:
				{
					CPrintToChatAll("{crimson}You feel a heavy sense of dread for the rest of the day...");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave25Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You definitely didn't come here for no reason.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: So, who sent you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Were {unique}Expidonsans{default} not brave enough to reach out to us on their own?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Maybe you don't even know what {unique}Expidonsa{default} is.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: So, who told you about this place?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: You definitely didn't stumble here on your own.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Was it {unique}Expidonsa{default}?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: Do you even know what {unique}Expidonsa{default} is?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You definitely didn't come here for no reason.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: So, who sent you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Someone who just wants to break stuff?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: What else would your purpose here be?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You definitely didn't come here for no reason.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: So, who sent you?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Someone who just wants to break stuff?");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: What else would your purpose here be?");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave30Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,0);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: But if they've sent you here... that can't be right...");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Is this why they have so many cryogenically frozen humans?!");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: They just...lured them into the labs and-");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: No no no no no, this can't be right, I- I'll be right back.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: They can't have sent you here, that can't be right...");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: It would explain why they have so many cryogenically frozen humans though.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: They just...lured them into the labs and-");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: No...no, that can't be right, I'll be right back.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: If that's so, haven't you caused enough mayhem?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: How much destruction does the human race need to bring to be satisfied?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe {unique}Expidonsa{default} was right about treating you like a threat.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: If that's so, haven't you caused enough mayhem?");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: How much destruction does the human race need to bring to be satisfied?");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Maybe {unique}Expidonsa{default} was right about treating you like a threat.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}


stock void NpcTalker_Wave31Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Alive
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS) && !Aperture_IsBossDead(APERTURE_BOSS_CHIMERA))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(1,2);
		}
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS) && Aperture_IsBossDead(APERTURE_BOSS_CHIMERA))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}
		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Alive
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I'm not exactly sure what that thing was...but it seemed to be related with these Portal Gates.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: It doesn't share any origins with the lab. Leaving it intact was probably the right choice.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Well, I'll be going back to doing my research now.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 2:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: That thing...what was that? It appears to be tied with the Portal Gates.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: No correlation with the laboratories either. Looks like it was searching for something.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: As strange as that was, I have to get back to my research.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Dead
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: That thing that you just destroyed...I don't know what it is, or rather what it was.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Its destruction appears to have affected the Portal Gates. They're more unstable now.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: Well, this is on you. I'm going back to my research now.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 4:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: That robot...its origins are unknown to me. Not that I'll know what they are with what you did.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: What I do know is that it was linked to these Portal Gates. They are precarious now.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: You chose to do this. I'm going back to my research now.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}

stock void NpcTalker_Wave36Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I was wrong.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Well, wrong about you being sent by {unique}Expidonsans{default}.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I wasn't aware of {unique}Expidonsa's{default} full picture.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: It appears that they aren't the best when it comes to being ethical.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: I have also reverse-searched your emblems.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: You are some sort of mercēnārius, yeah?");
				}
				case 7:
				{
					CPrintToChatAll("{rare}???{default}: This would mean that you've been hired by someone to loot this place.");
				}
				case 8:
				{
					CPrintToChatAll("{rare}???{default}: I'm afraid I can not let that happen.");
				}
				case 9:
				{
					CPrintToChatAll("{rare}???{default}: But since mercenaries are paid for their work, I have no reason to assume that you intend on stopping.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I was mistaken.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: Well, mistaken about you being sent by {unique}Expidonsa{default}.");
				}
				case 3:
				{
					CPrintToChatAll("{rare}???{default}: I wasn't aware of {unique}Expidonsa's{default} full history.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: It appears that they aren't the best when it comes to being ethical.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: I have also reverse-searched your emblems.");
				}
				case 6:
				{
					CPrintToChatAll("{rare}???{default}: You are some sort of mercenarye, is that correct?");
				}
				case 7:
				{
					CPrintToChatAll("{rare}???{default}: This would mean that you've been hired by someone to loot this place.");
				}
				case 8:
				{
					CPrintToChatAll("{rare}???{default}: I'm afraid I can not let that happen.");
				}
				case 9:
				{
					CPrintToChatAll("{rare}???{default}: But since mercenaries are paid for their work, I have no reason to assume that you intend on stopping.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I'm not sure what your goal here is, but I will have to intervene.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I can not allow you to bring more mayhem.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I'm not sure what your goal here is, but I will have to intervene.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I can not allow you to bring more mayhem.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}


stock void NpcTalker_Wave37Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,1);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I can not let you get any of this gear.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: If it were to fall into the wrong hands, the repercussions could be catastrophic.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		case 1:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: You can not get any of this gear. I can't allow that.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: If anyone with the wrong plans was to get their hands on this...the fate of our world could be at risk.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave38Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(0,0);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,3);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(5,5);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 0:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					CPrintToChatAll("{rare}???{default}: I have to intervene.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}???{default}: I'm sorry.");
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}