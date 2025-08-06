#pragma semicolon 1
#pragma newdecls required

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

void Talker_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_talker");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Aperture; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Talker(vecPos, vecAng, team);
}
methodmap Talker < CClotBody
{

	public Talker(float vecPos[3], float vecAng[3], int ally)
	{
		Talker npc = view_as<Talker>(CClotBody(vecPos, vecAng, "models/buildables/teleporter.mdl", "1.0", "100000000", ally, .NpcTypeLogic = 1));

		i_NpcWeight[npc.index] = 999;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 2.0;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;
		i_TalkDelayCheck = 0;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);

		

		func_NPCDeath[npc.index] = view_as<Function>(Talker_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(Talker_ClotThink);
		
		return npc;
	}
}

public void Talker_ClotThink(Talker npc, int iNPC)
{
	float gameTime = GetGameTime(npc.index);
	int wave = (Waves_GetRoundScale() + 1);
	//Wave 1-5
	if(wave >= 1 && wave <= 5)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
			switch(GetRandomInt(0,2))
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
				case 1:
				{
					switch(i_TalkDelayCheck)
					{
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: Finally, its been years since we last saw-");
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
			}
		}
		//return false;
	}
	//Wave 5-10
	if(wave >= 5 && wave <= 10)
	{
		int maxyapping2 = 6;
		if(i_TalkDelayCheck == maxyapping2)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
			switch(GetRandomInt(0,1))
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
							i_TalkDelayCheck = maxyapping2;
							SmiteNpcToDeath(npc.index);
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
							i_TalkDelayCheck = maxyapping2;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
			}
		}
		//return false;
	}
	//Wave 10
	if(wave >= 9 && wave <= 11)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
			switch(GetRandomInt(0,1))
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
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
				case 1:
				{
					switch(i_TalkDelayCheck)
					{
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: I should've probably mentioned this sooner, but ages ago, there were robots designed with a sole task in mind; to defend the laboratory.");
						}
						case 2:
						{
							CPrintToChatAll("{rare}???{default}: Defend the laboratory against who? Well...people like you, apparently.");
						}
						case 3:
						{
							CPrintToChatAll("{rare}???{default}: It's safe to say that you might be facing off against one of the robots sometime soon.");
						}
						case 4:
						{
							CPrintToChatAll("{rare}???{default}: One of them was designed as a sort of control against trespassers.");
						}
						case 5:
						{
							CPrintToChatAll("{rare}???{default}: Since I've warned you to get out while you could, and you decided to stay, I have no advice left to give you.");
						}
						case 6:
						{
							CPrintToChatAll("{rare}???{default}: If you're actually lost, let the robot do its job, and let it carry you out of the labs.");
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
			}
		}
		//return false;
	}
	//Wave 11 - Spared CAT
	if(wave >= 10 && wave <= 12)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
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
					i_TalkDelayCheck = maxyapping;
					SmiteNpcToDeath(npc.index);
				}
			}
		}
	}
	//Wave 11 - Killed CAT
/*	if(wave >= 10 && wave <= 12)
	{
		int maxyapping = 6;
		if(i_TalkDelayCheck == maxyapping)
		{
			SmiteNpcToDeath(npc.index);
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 5.0;
			i_TalkDelayCheck++;
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
					CPrintToChatAll("{rare}???{default}: I know that he tried to kill you, but he was defenseless.");
				}
				case 4:
				{
					CPrintToChatAll("{rare}???{default}: And yet...you took advantage of that and you disassembled him, part-by-part.");
				}
				case 5:
				{
					CPrintToChatAll("{rare}???{default}: I'll be keeping an open eye on you from now on.");
					i_TalkDelayCheck = maxyapping;
					SmiteNpcToDeath(npc.index);
				}
			}
		}
	}
	*/
}

public void Talker_NPCDeath(int entity)
{
	Talker npc = view_as<Talker>(entity);
}