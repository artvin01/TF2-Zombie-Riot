#pragma semicolon 1
#pragma newdecls required
static float f_FullMoonHudCD[MAXPLAYERS];
static Handle h_TimerFullMoon[MAXPLAYERS+1] = {null, ...};
static int i_Current_Pap[MAXPLAYERS+1] = {0, ...};
static float f_FullMoonAbility[MAXPLAYERS+1] = {0.0, ...};
static bool Precached;

#define FullMoon_ABILTIY_SOUND_1	"npc/scanner/scanner_electric1.wav"

public void FullMoon_MapStart()
{
	Zero(f_FullMoonHudCD);
	PrecacheSound(FullMoon_ABILTIY_SOUND_1);
	PrecacheSound(ANGELIC_HIT_1);
	Zero(f_FullMoonAbility);
	Precached = false;
}
bool DoOverhealLogicRemove = false;
void FullmoonEarlyReset(int client)
{
	//this is needed due to 2x HP
	if (h_TimerFullMoon[client] != null)
	{
		DoOverhealLogicRemove = true;
		//if they had the weapon and had overheal, delete overheal.
		delete h_TimerFullMoon[client];
		h_TimerFullMoon[client] = null;
	}
}
bool FullMoonIs(int client)
{
	if (h_TimerFullMoon[client] != null)
	{
		return true;
	}
	return false;
}
void FullMoon_Enable(int client, int weapon)
{
	if (h_TimerFullMoon[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_FULLMOON)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerFullMoon[client];
			h_TimerFullMoon[client] = null;
			i_Current_Pap[client] = Fantasy_Blade_Get_Pap(weapon);
			DataPack pack;
			h_TimerFullMoon[client] = CreateDataTimer(0.1, Timer_Management_FullMoon, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			Attributes_SetMulti(weapon, 412, 1.8);
			//force panic attack and vulnerability
			Panic_Attack[weapon] = 0.175;
			FullmoonDownload();
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_FULLMOON)
	{
		i_Current_Pap[client] = Fantasy_Blade_Get_Pap(weapon);
		DataPack pack;
		h_TimerFullMoon[client] = CreateDataTimer(0.1, Timer_Management_FullMoon, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		Attributes_SetMulti(weapon, 412, 1.8);
		Panic_Attack[weapon] = 0.175;
		FullmoonDownload();
	}
}
void FullmoonDownload()
{
	if(!Precached)
	{
		// MASS REPLACE THIS IN ALL FILES
		PrecacheSoundCustom("zombie_riot/weapons/hellagur_attack.mp3",_,1);
		/*
		PrecacheSoundCustom("zombie_riot/weapons/hellagur_warcry1.mp3",_,1);
		PrecacheSoundCustom("zombie_riot/weapons/hellagur_warcry2.mp3",_,1);
		*/
		Precached = true;
	}
}
public void FullMoonDoubleHp(int client, StringMap map)
{
	if(map)	// Player
	{
		if(h_TimerFullMoon[client])
		{
			float value;

			// +15% max health
			map.GetValue("26", value);
			map.SetValue("26", value * 2.4);
		}
		else
		{
			if(DoOverhealLogicRemove)
			{
				DoOverhealLogicRemove = false;
				//they treid abusing the weapon, punish.
				float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
				float value;
				map.GetValue("26", value);
				float flpercenthpfrommax = flHealth / value;
				if(flpercenthpfrommax >= 1.0)
				{
					SetEntProp(client, Prop_Send, "m_iHealth", RoundToNearest(value));
				}
			}
		}
	}
}

bool FullMoonAbilityOn(int client)
{
	return (f_FullMoonAbility[client] > GetGameTime());
}
public void Weapon_FullMoon(int attacker, float &damage, int damagetype)
{
	if(damagetype & DMG_CLUB)
	{
		if(f_FullMoonAbility[attacker] > GetGameTime())
		{
			damage *= 1.65;
		}
	}
}
static int Fantasy_Blade_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	return pap;
}

void FullMoon_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	if(f_FullMoonAbility[client] > GetGameTime())
	{
		//double melee range
		//only increase wideness atinybit
		enemies_hit_aoe = 3; //hit 3 targets.
		CustomMeleeRange = MELEE_RANGE * 1.25;
		CustomMeleeWide = MELEE_BOUNDS * 1.25;
	}
}

public Action Timer_Management_FullMoon(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerFullMoon[client] = null;
		return Plugin_Stop;
	}	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		FullMoon_Cooldown_Logic(client, weapon);
		//anti safe softlock
		//and that free 10 ammo just isnt worth it lol
	}
	return Plugin_Continue;
}

bool HitAnyEnemy = false;
public void FullMoon_Cooldown_Logic(int client, int weapon)
{
	if(f_FullMoonAbility[client] > GetGameTime())
	{
		MakeBladeBloddy(client, true);
		TF2_AddCondition(client, TFCond_CritOnKill, 0.3);
		StopSound(client, SNDCHAN_STATIC, "weapons/crit_power.wav");
	}
	else
	{
		MakeBladeBloddy(client, false);
	}

	if(f_FullMoonHudCD[client] < GetGameTime() && i_Current_Pap[client] > 1)
	{
		f_FullMoonHudCD[client] = GetGameTime() + 0.25;
		
		HitAnyEnemy = false;
		float ClientPos[3];
		WorldSpaceCenter(client, ClientPos);
		TR_EnumerateEntitiesSphere(ClientPos, 150.0, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_FullMoon, client);
		if(i_Current_Pap[client] >= 3)
		{
			float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
			float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(client);
			if(flpercenthpfrommax <= 0.35)
			{
				HitAnyEnemy = false;
			}
		}
		if(!HitAnyEnemy)
		{
			if(dieingstate[client] == 0)
				HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)) * 0.0025, 1.0,_,HEAL_SELFHEAL);
		}
	}
}

public bool TraceEntityEnumerator_FullMoon(int entity, int filterentity)
{
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		HitAnyEnemy = true;
		return false;
	}
	//always keep going!
	return true;
}

void FullMoon_Meleetrace_Hit_Before(int client, float &damage, int enemy)
{
	if(!IsValidEnemy(client, enemy, true, true))
	{	
		return;
	}
	float TotalHealDoPerHit = 15.0;
	switch(i_Current_Pap[client])
	{
		case 3:
		{
			if(dieingstate[client] == 0)
			{
				TotalHealDoPerHit *= 4.0;
			}
		}
		case 2:
		{
			if(dieingstate[client] == 0)
			{
				TotalHealDoPerHit *= 2.0;
			}
		}
	}
	
	if(b_thisNpcIsARaid[enemy])
	{
		if(!FullMoonAbilityOn(client))
			TotalHealDoPerHit *= 0.5;
	}

	if(dieingstate[client] == 0)
		HealEntityGlobal(client, client, TotalHealDoPerHit, 1.0,_,HEAL_SELFHEAL);
	
	GiveArmorViaPercentage(client, 0.02, 1.0, false, true);
}


void FullMoon_Meleetrace_Hit_After(float &damage)
{
	damage *= 0.5;
}
public void FullMoonM1(int client, int weapon, bool crit, int slot)
{
	if(f_FullMoonAbility[client] > GetGameTime())
	{
		EmitCustomToAll("zombie_riot/weapons/hellagur_attack.mp3", 
		client, _, 80, _, 1.0);
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteFloat(GetGameTime() + 0.07);	
		RequestFrame(FullMoonDoM1Effect, pack);
	}
}

void FullMoonDoM1Effect(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client))
	{
		delete pack;
		return;
	}
	float TimeUntillEnd = pack.ReadFloat();
	float TimeUntillSnap = TimeUntillEnd - GetGameTime();
	TimeUntillSnap *= 20.0;
	static float belowBossEyes[3];
	belowBossEyes[0] = 0.0;
	belowBossEyes[1] = 0.0;
	belowBossEyes[2] = 0.0;
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	if(GetGameTime() >= TimeUntillEnd)
	{
		//do final slash on the floor where they look  and them delete.
		DrawGiantMoon(Angles, client, belowBossEyes, 0.0);
		delete pack;
		return;
	}
	DrawGiantMoon(Angles, client, belowBossEyes, TimeUntillSnap);
	RequestFrame(FullMoonDoM1Effect, pack);
}

void DrawGiantMoon(float Angles[3], int client, float belowBossEyes[3], float AngleDeviation = 1.0)
{
	Angles[0] -= (30.0 * AngleDeviation);
	float vecForward[3];
	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float LaserFatness = 8.0;
	
	int Colour[3];
	Colour = {255,60,60};
	float VectorTarget_2[3];
	float VectorForward = 300.0; //a really high number.
	
	GetBeamDrawStartPoint_Stock(client, belowBossEyes,{0.0,0.0,0.0}, Angles);
	VectorTarget_2[0] = belowBossEyes[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = belowBossEyes[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = belowBossEyes[2] + vecForward[2] * VectorForward;
	Passanger_Lightning_Effect(belowBossEyes, VectorTarget_2, 4, LaserFatness, Colour);
}

public void FullMoonAbilityM2(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;	
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 50.0); //Semi long cooldown, this is a strong buff.
//	MakePlayerGiveResponseVoice(client, 1); //haha!
//	EmitCustomToAll(GetRandomInt(0,1) ? "zombie_riot/weapons/hellagur_warcry1.mp3" : "zombie_riot/weapons/hellagur_warcry2.mp3", 
//	client, _, 85, _, 1.0);
	EmitSoundToAll("items/powerup_pickup_strength.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
	f_FullMoonAbility[client] = GetGameTime() + 10.0;
}



void FullMoon_SanctuaryApplyBuffs(int client, float &damage)
{
	if(i_Current_Pap[client] <= 1)
	{
		return;
	}
	float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
	float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(client);
	if(flpercenthpfrommax <= ((i_Current_Pap[client] >= 3) ? 0.35 : 0.3))
	{
		damage *= 0.75;
	}
}