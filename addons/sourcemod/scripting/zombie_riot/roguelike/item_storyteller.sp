#pragma semicolon 1
#pragma newdecls required

static int BrokenBlade;
static int BladeDancer;
static float BladedanceChangeOwner;
static float LastFlowerHealth;
static ArrayStack LastShadowHealth;
static bool Friendship;

void Rogue_StoryTeller_Reset()
{
	BrokenBlade = 0;
	BladedanceChangeOwner = 0.0;
	LastFlowerHealth = 1000.0;
	delete LastShadowHealth;
	Friendship = false;
}

bool Rogue_HasFriendship()
{
	return Friendship;
}

void Rogue_StoryTeller_ReviveSpeed(int &amount)
{
	if(BrokenBlade)
		amount *= BrokenBlade * 2;
}

public void Rogue_Blademace_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 1.2);
	RogueHelp_BodySpeed(entity, map, 0.9);
	RogueHelp_BodyRes(entity, map, 1.02);
	RogueHelp_BodyDamage(entity, map, 1.2);
}

public void Rogue_Blademace_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.2);
}

public void Rogue_Brokenblade_Collect()
{
	BrokenBlade++;
}

public void Rogue_Brokenblade_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;

		// -20% max health
		map.GetValue("26", value);
		map.SetValue("26", value * 0.8);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// -20% max health
			int health = ReturnEntityMaxHealth(npc.index) * 4 / 5;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
	}
}

Handle BladeDanceItemCollect;
public void Rogue_Bladedance_Collect()
{
	BladedanceChangeOwner = 0.0;
	delete BladeDanceItemCollect;
	BladeDanceItemCollect = CreateTimer(1.5, Timer_BladedancerTimer, _, TIMER_REPEAT);
}
public void Rogue_Bladedance_Remove()
{
	delete BladeDanceItemCollect;
	BladeDancer = 0;
	Rogue_Refresh_Remove();
}

float RogueBladedance_DamageBonus(int attacker, int inflictor, int victim)
{
	if(BladeDancer <= 0)
		return 1.0;
	
	int CalcsDo = -1;
	if(BladeDancer == inflictor)
		CalcsDo = inflictor;
	if(BladeDancer == attacker)
		CalcsDo = attacker;

	if(CalcsDo <= 0)
		return 1.0;

	//not same team, give 2x dmg
	if(GetTeam(CalcsDo) != GetTeam(victim))
	{
		return 2.0;
	}
	return 1.0;
}

static Action Timer_BladedancerTimer(Handle timer)
{
	if(BladeDancer > 0)
	{
		//change bladedancer if dead or smth
		//dont change if they are downed but have a self revive so to speak
		if(TeutonType[BladeDancer] != TEUTON_NONE || !IsClientInGame(BladeDancer) || !IsPlayerAlive(BladeDancer) || (dieingstate[BladeDancer] && !b_LeftForDead[BladeDancer]))
		{
			//Find new friend!
			BladedanceChangeOwner = 0.0;
		}
	}

	if(BladedanceChangeOwner > GetGameTime())
		return Plugin_Continue;
		
	//Keep bladedancer for 2 mins
	BladedanceChangeOwner = GetGameTime() + 180.0;

	int NewDancerFind = -1;
	//400 is more then enough.

	int victims;
	int[] victim = new int[MaxClients];

	for(int target = 1; target <= MaxClients; target++)
	{
		if(BladeDancer != target && TeutonType[target] == TEUTON_NONE && IsClientInGame(target) && IsPlayerAlive(target) && !dieingstate[target])
		{
			victim[victims++] = target;
		}
	}
	
	if(victims)
	{
		int winner = victim[GetURandomInt() % victims];
		NewDancerFind = winner;
	}

	//if no one was found, keep.
	if(NewDancerFind != -1)
	{
		BladeDancer = NewDancerFind;
	}
	if(IsValidClient(BladeDancer))
	{
		CPrintToChatAll("{red}%N {crimson}플레이어의 최대 체력, 공격력, 치유 속도가 +100％ 증가했습니다.", BladeDancer);
	}
	return Plugin_Continue;
}
public void Rogue_Bladedance_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		if(BladeDancer == entity)
		{
			float value;
			
			// +100% max health
			map.GetValue("26", value);
			map.SetValue("26", value * 2.0);

			// +100% Heal rate
			map.GetValue("8", value);
			map.SetValue("8", value * 2.0);
		}
	}
}

public void Rogue_Whiteflower_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float last;
		map.GetValue("26", last);
		map.SetValue("26", LastFlowerHealth);

		LastFlowerHealth = last * 1.25;
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			int last = ReturnEntityMaxHealth(npc.index);

			int health = RoundFloat(LastFlowerHealth);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);

			LastFlowerHealth = float(last) * 1.25;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				int last = ReturnEntityMaxHealth(npc.index);

				int health = RoundFloat(LastFlowerHealth);
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);

				LastFlowerHealth = float(last) * 1.25;
			}
		}
	}
}

public void Rogue_Shadow_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		if(!LastShadowHealth)
			LastShadowHealth = new ArrayStack();
		
		float last;
		map.GetValue("26", last);
		LastShadowHealth.Push(RoundFloat(last));
	}
	else if(!b_NpcHasDied[entity] && LastShadowHealth && !LastShadowHealth.Empty)	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			int health = LastShadowHealth.Pop();
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				int health = LastShadowHealth.Pop();
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
}

public void Rogue_RightNatator_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 0.95;
	fl_Extra_RangedArmor[entity] *= 1.2;
}

public void Rogue_LeftNatator_Enemy(int entity)
{
	fl_Extra_MeleeArmor[entity] *= 1.2;
	fl_Extra_RangedArmor[entity] *= 0.95;
}

public void Rogue_ProofOfFriendship_Collect()
{
	Friendship = true;
}

public void Rogue_CombineCrown_Ally(int entity, StringMap map)
{
	RogueHelp_BodyHealth(entity, map, 0.95);
}

public void Rogue_BobResearch_Ally(int entity, StringMap map)
{
	RogueHelp_BodySpeed(entity, map, 0.9);
}

public void Rogue_BobFinal_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.15);
	RogueHelp_BodySpeed(entity, map, 1.2);
}

public void Rogue_BobFinal_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.15);
}