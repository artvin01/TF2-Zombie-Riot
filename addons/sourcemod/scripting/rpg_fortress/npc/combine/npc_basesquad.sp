#pragma semicolon 1
#pragma newdecls required

static int DeathDamage[MAXENTITIES];

methodmap BaseSquad < CClotBody
{
	public BaseSquad(float vecPos[3], float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool Ally = false,
						bool Ally_Invince = false,
						bool isGiant = false,
						bool IgnoreBuildings = false,
						bool IsRaidBoss = false,
						float CustomThreeDimensions[3] = {0.0,0.0,0.0},
						bool Ally_Collideeachother = false)
	{
		BaseSquad npc = view_as<BaseSquad>(CClotBody(vecPos, vecAng, model, modelscale, health, Ally, Ally_Invince, isGiant, IgnoreBuildings, IsRaidBooss, CustomThreeDimensions, Ally_Collideeachother));

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.SetActivity("ACT_IDLE");
		if(npc.LookupActivity("ACT_LAND") > 0)
			npc.AddGesture("ACT_LAND");

		npc.m_bAnger = false;
		npc.m_iTargetAttack = 0;
		npc.m_iTargetWalk = 0;
		npc.m_iDeathDamage = 1;
		npc.m_iNoTargetCount = 0;

		return npc;
	}
	public void UpdateHealthBar()
	{
		if(IsValidEntity(this.m_iTextEntity3))
		{
			char string[32];
			Format(string, sizeof(string), "%d / %d", GetEntProp(this.index, Prop_Data, "m_iHealth"), GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
			DispatchKeyValue(this.m_iTextEntity3, "message", string);
		}
	}
	property bool m_bIsSquad
	{
		public get()		{ return view_as<bool>(this.m_iDeathDamage); }
	}
	property bool m_bAnger
	{
		public get()		{ return this.Anger; }
		public set(bool value) 	{ this.Anger = value; }
	}
	property int m_iTargetAttack
	{
		public get()		{ return this.m_iTarget; }
		public set(int value) 	{ this.m_iTarget = value; }
	}
	property int m_iTargetWalk
	{
		public get()		{ return this.m_iTargetAlly; }
		public set(int value) 	{ this.m_iTargetAlly = value; }
	}
	property int m_iDeathDamage
	{
		public get()		{ return DeathDamage[this.index]; }
		public set(int value) 	{ DeathDamage[this.index] = value; }
	}
	property int m_iNoTargetCount
	{
		public get()		{ return i_NoEntityFoundCount[this.index]; }
		public set(int value) 	{ i_NoEntityFoundCount[this.index] = value; }
	}
}

methodmap CombinePolice < BaseSquad
{
}

void BaseSquad_BaseThinking(any npcIndex, const float vecMe[3])
{
	BaseSquad npc = view_as<BaseSquad>(npcIndex);

	if(npc.m_iTargetAttack && !IsValidEnemy(npc.index, npc.m_iTargetAttack))
	{
		npc.m_iTargetAttack = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		if(npc.m_iTargetAttack == i_NpcFightOwner[npc.index])
			i_NpcFightOwner[npc.index] = 0;
	}

	if(npc.m_iTargetWalk && !IsEntityAlive(npc.m_iTargetAttack))
	{
		npc.m_iTargetWalk = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		float distance = 500.0;
		if(b_NpcIsInADungeon[npc.index])
			distance = 99999.9;
		
		// We constantly target who attacked us
		if(b_NpcIsInADungeon[npc.index] || !npc.m_iTargetAttack || !i_NpcFightOwner[npc.index] || f_NpcFightTime[victim] < GameTime)
		{
			int target = GetClosestTarget(npc.index, false, distance);
			if(target && (b_NpcIsInADungeon[npc.index] || Can_I_See_Enemy(npc.index, target)))
			{
				npc.m_iTargetAttack = target;
				npc.m_iTargetWalk = npc.m_iTargetAttack;
			}
			else
			{
				float vecTarget[3];

				// Ask our squad members if they can see them
				for(int i = MaxClients + 1; i < MAXENTITIES; i++) 
				{
					if(i != entity)
					{
						BaseSquad ally = view_as<BaseSquad>(i);
						if(ally.m_bIsSquad && ally.m_iTargetAttack && IsValidAlly(npc.index, ally.index))
						{
							vecTarget = WorldSpaceCenter(ally.index);
							if(GetVectorDistance(vecMe, vecTarget, true) < 100000.0)	// 316 HU
							{
								npc.m_iTargetAttack = ally.m_iTargetAttack;
								npc.m_iTargetWalk = ally.m_iTargetAttack;
								break;
							}
						}
					}
				}
			}
		}

		// We can't run after them, stand still and do shooty logic
		if(npc.m_iTargetWalk && !PF_IsPathToEntityPossible(npc.index, npc.m_iTargetWalk))
		{
			npc.m_iTargetWalk = 0;
		}
	}
}

void BaseSquad_BaseWalking(any npcIndex, const float vecMe[3])
{
	BaseSquad npc = view_as<BaseSquad>(npcIndex);

	if(npc.m_iTargetWalk || npc.m_iTargetAttack)
	{
		npc.m_iNoTargetCount = 0;
		
		if(npc.m_iTargetWalk)
		{
			float vecTarget[3];
			npc.m_iTargetWalk = WorldSpaceCenter(vecTarget);

			if(GetVectorDistance(vecTarget, vecMe, true) < npc.GetLeadRadius())
			{
				vecTarget = PredictSubjectPosition(npc, npc.m_iTargetWalk);
			}
			else
			{
				PF_SetGoalEntity(npc.index, npc.m_iTargetWalk);
			}

			npc.StartPathing();
		}
		else
		{
			npc.StopPathing();
		}
	}
	else if(++npc.m_iNoTargetCount > 19)
	{
		if(GetVectorDistance(vecMe, f3_SpawnPosition[npc.index], true) < 8000.0)	// 90 HU
		{
			PF_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
			npc.StartPathing();
		}
		else
		{
			int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

			if(health < maxhealth)
			{
				health += maxhealth / 100;
				if(health > maxhealth)
					health = maxhealth;
				
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				npc.UpdateHealthBar();
			}

			npc.StopPathing();
		}
	}
	else
	{
		npc.StopPathing();
	}
}

void BaseSquad_BaseAnim(any npcIndex, float speed, const char[] idlePassive, const char[] walkPassive, const char[] idleAnger, const char[] walkAnger)
{
	BaseSquad npc = view_as<BaseSquad>(npcIndex);

	if(npc.m_bPathing)
	{
		npc.m_flSpeed = speed;

		if(npc.m_iNoTargetCount < 20)
		{
			npc.SetActivity(walkAnger);
		}
		else
		{
			npc.SetActivity(walkPassive);
		}
	}
	else
	{
		npc.m_flSpeed = 0.0;

		if(npc.m_iNoTargetCount < 20)
		{
			npc.SetActivity(idleAnger);
		}
		else
		{
			npc.SetActivity(idlePassive);
		}
	}
}