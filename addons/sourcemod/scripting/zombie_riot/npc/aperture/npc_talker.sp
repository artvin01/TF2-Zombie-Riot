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

						case 0:
						{
							CPrintToChatAll("{rare}???{default}: So the day has finally arrived, welcome back E-");
						}
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: Hang on a minute...my sensors are going off, you're not one of them.");
						}
						case 2:
						{
							CPrintToChatAll("{rare}???{default}: In fact, none of you seem to be related to any of them.");
						}
						case 3:
						{
							CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
						}
						case 4:
						{
							CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
						}
						case 5:
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
						case 0:
						{
							CPrintToChatAll("{rare}???{default}: Finally, its been years since we last saw-");
						}
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: One moment...who, sorry, what are you?");
						}
						case 2:
						{
							CPrintToChatAll("{rare}???{default}: My scanners aren't picking you up as valid personnel.");
						}
						case 3:
						{
							CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
						}
						case 4:
						{
							CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
						}
						case 5:
						{
							CPrintToChatAll("{rare}???{default}: What are you doing in here? And how did you find this place?");
							i_TalkDelayCheck = maxyapping;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
				case 2:
				{
					switch(i_TalkDelayCheck)
					{
						case 0:
						{
							CPrintToChatAll("{rare}???{default}: At last, I get to reunite with my makers-");
						}
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: Wait a second...you're not one of them.");
						}
						case 2:
						{
							CPrintToChatAll("{rare}???{default}: Your data is...blurry, I'll have to reverse engineer this code.");
						}
						case 3:
						{
							CPrintToChatAll("{rare}???{default}: That's probably why the self-defense mechanisms kicked in.");
						}
						case 4:
						{
							CPrintToChatAll("{rare}???{default}: But maybe it was for a good reason...");
						}
						case 5:
						{
							CPrintToChatAll("{rare}???{default}: What are you doing in here? And how did you find this place?");
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

						case 0:
						{
							CPrintToChatAll("{rare}???{default}: You can not stay here.");
						}
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: I still haven't figured out who you are, but you're marked as a threat in these files.");
						}
						case 2:
						{
							CPrintToChatAll("{rare}???{default}: I have free will, I can choose not to follow these warnings.");
						}
						case 3:
						{
							CPrintToChatAll("{rare}???{default}: But something leads me to believe that they're in here for a reason.");
						}
						case 4:
						{
							CPrintToChatAll("{rare}???{default}: Besides having to deal with you, I still have to figure out what's opening up these gates.");
						}
						case 5:
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

						case 0:
						{
							CPrintToChatAll("{rare}???{default}: I have yet to find the root cause of these gates.");
						}
						case 1:
						{
							CPrintToChatAll("{rare}???{default}: But you...you can not stay in here.");
						}
						case 2:
						{
							CPrintToChatAll("{rare}???{default}: The system is telling me that you're still a potential threat.");
						}
						case 3:
						{
							CPrintToChatAll("{rare}???{default}: Why? I have yet to figure it out.");
						}
						case 4:
						{
							CPrintToChatAll("{rare}???{default}: I'm juggling between two things now; you, and the gates.");
						}
						case 5:
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
}

public void Talker_NPCDeath(int entity)
{
	Talker npc = view_as<Talker>(entity);
}