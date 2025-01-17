#pragma semicolon 1
#pragma newdecls required
#define PURNELL_MAX_TARGETS		5
#define PURNELL_KNOCKBACK		200.0
#define PURNELL_KNOCKBACK_PAP2	300.0
#define PURNELL_KNOCKBACK_PAP3	400.0
#define PURNELL_KNOCKBACK_PAP4	450.0
#define PURNELL_KNOCKBACK_PAP5	500.0
#define PURNELL_KNOCKBACK_PAP6	600.0

/*
Passives:
None

Melee:
Push (M1) - Plays the "passtime" animation. Every time the kit gets papped, it increases the knockback of the push.
At a certain point, when papped, it will give the enemy you pushed a random debuff, the more the kit is papped the longer
the debuff lasts.

Buff (M2) - Choose a teammate to buff, you can't select the buff, it is purely random. Doesn't last long to not make someone
super op.

Primary:
Taurus Revolver - 5 Rounds. Extremely slow reload, but extremely strong damage. Later paps add a "weapon slap" ability which deals melee damage, nothing else.
No buffs.

*/

static int LaserIndex;
static bool Precached;
static int i_Pap_Level[MAXTF2PLAYERS];
static int ParticleRef[MAXTF2PLAYERS] = {-1, ...};
static int i_Current_Pap[MAXTF2PLAYERS] = {0, ...};
Handle Timer_Purnell_Management[MAXTF2PLAYERS] = {null, ...};
static int EnemiesHit[PURNELL_MAX_TARGETS];
static bool b_PushSound[MAXTF2PLAYERS];
static bool b_ShoveSound[MAXTF2PLAYERS];
static float fl_Push_Knockback[MAXTF2PLAYERS];
static bool b_PurnellLastMann;

static const char g_MeleeHitSounds[][] = {
	"cof/purnell/meleehit.mp3",
};

static int Fantasy_Blade_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}

void Purnell_MapStart()
{
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	Precached = false;
	PrecacheSoundArray(g_MeleeHitSounds);
	Zero(i_Current_Pap);
	Zero(b_PushSound);
	Zero(b_ShoveSound);
	Zero(fl_Push_Knockback);
	Zero(i_Pap_Level);
}

bool Purnell_Lastman(int client)
{
	bool Purnell_Went_Nuts = false;
	if(Timer_Purnell_Management[client] != null)
		Purnell_Went_Nuts = true;
	
	return Purnell_Went_Nuts;
}
static void Purnell_LastMann_Check()
{
	if(LastMann)
	{
		if(!b_PurnellLastMann)
			b_PurnellLastMann = true;
	}
	else
	{
		if(b_PurnellLastMann)
		{
			b_PurnellLastMann = false;
		}
	}
}
/*
void Purnell_LastMann(int client, bool b_On)
{
	b_PurnellLastMann=b_On;
}*/

void Purnell_Enable(int client, int weapon)
{
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_PURNELL_PRIMARY:
		{
			if(Timer_Purnell_Management[client] != null)//if it isn't null, wipe it.
			{
				delete Timer_Purnell_Management[client];
				Timer_Purnell_Management[client] = null;
			}
			i_Pap_Level[client] = Fantasy_Blade_Get_Pap(weapon);
			
			DataPack pack;
			Timer_Purnell_Management[client] = CreateDataTimer(0.1, Purnell_Timer_Management, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
			if(!Precached)
			{
				PrecacheSoundCustom("#zombiesurvival/purnell_lastman.mp3", _, 1);
				Precached = true;
			}
			//pack.WriteCell(EntIndexToEntRef(weapon));
		}
		/*case WEAPON_PURNELL_BUFF:
		{
			DataPack pack;
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
			CreateDataTimer(0.1, Purnell_HealerTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}*/
		case WEAPON_PURNELL_MELEE:
		{
			i_Pap_Level[client] = Fantasy_Blade_Get_Pap(weapon);
			/*i_Purnell_Melee[client] = EntIndexToEntRef(weapon);*/
			DataPack pack;
			CreateDataTimer(0.1, Purnell_HealerTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

public Action Purnell_Timer_Management(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientOriginal = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client) && IsValidEntity(weapon))
	{
		int weaponActve = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weaponActve))
		{
			switch(i_CustomWeaponEquipLogic[weaponActve])
			{
				case WEAPON_PURNELL_MELEE, WEAPON_PURNELL_PRIMARY:
				{
					Purnell_LastMann_Check();
					//Purnell_Buff_Loc(client);

					Particle_Add(client);
					
					return Plugin_Continue;
				}
				/*case WEAPON_PURNELL_PRIMARY:
				{
					Purnell_LastMann_Check();

					Particle_Add(client);
					
					return Plugin_Continue;
				}*/
			}
		}
		
		Particle_Removal(client);

		return Plugin_Continue;
	}
		
	Particle_Removal(clientOriginal);

	Timer_Purnell_Management[clientOriginal] = null;
	return Plugin_Stop;
}

static void Particle_Add(int client)
{
	if(ParticleRef[client] == -1)
	{
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 1.0;

		int entity = ParticleEffectAt(pos, "utaunt_hands_floor2_red", -1.0);
		if(entity > MaxClients)
		{
			SetParent(client, entity);
			ParticleRef[client] = EntIndexToEntRef(entity);
		}
	}
}
static void Particle_Removal(int client)
{
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}

		ParticleRef[client] = -1;
	}
}

public bool Purnell_DoSwingTrace(int entity, int contentsMask, int client)
{
	static char classname[64];
	if(IsValidEntity(entity))
	{
		GetEntityClassname(entity, classname, sizeof(classname));
		if(((!StrContains(classname, "zr_base_npc", true) && !b_NpcHasDied[entity]) || !StrContains(classname, "func_breakable", true)) && (GetTeam(entity) != GetTeam(client)))
		{
			for(int i; i < sizeof(EnemiesHit); i++)
			{
				if(!EnemiesHit[i])
				{
					EnemiesHit[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}

public void Purnell_PrimaryShove(int client, int weapon, bool crit, int slot) // "Purnell" Smack
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Ability_Apply_Cooldown(client, slot, 2.0);
		float damage = 35.0;
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= Attributes_Get(weapon, 476, 1.0);
		Explode_Logic_Custom(damage, client, client, weapon, _, 75.0, _, _, _, 1, _, _, _, Purnell_Shove_Primary);
		//Explode_Logic_Custom(damage, client, client, weapon, _, 30.0);
		if(b_ShoveSound[client])
		{
			//Add Sound
			b_ShoveSound[client] = false;
			EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], client, SNDCHAN_AUTO, 70, _, 0.55, 100);
		}
		else
		{
			//failed?
		}
	}
	else
	{
		float cooldown = Ability_Check_Cooldown(client, slot);
		{
			if(cooldown <= 0.0)
				cooldown = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
		}
	}
	
}

void Purnell_Shove_Primary(int client, int victim, float damage, int weapon)
{
	if(!b_ShoveSound[client])
		b_ShoveSound[client] = true;
}

//Pack-a-Punch 1

public void Purnell_MeleeShove(int client, int weapon, bool crit, int slot) // "Purnell" Smack
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Ability_Apply_Cooldown(client, slot, 5.0);
		int pap_level = i_Pap_Level[client];
		float knockback = PURNELL_KNOCKBACK;
		float damage = 25.0;
		switch(pap_level)
		{
			case 2:
			{
				knockback = PURNELL_KNOCKBACK_PAP2;
			}
			case 3:
			{
				knockback = PURNELL_KNOCKBACK_PAP3;
			}
			case 4:
			{
				knockback = PURNELL_KNOCKBACK_PAP4;
			}
			case 5:
			{
				knockback = PURNELL_KNOCKBACK_PAP5;
			}
			case 6:
			{
				knockback = PURNELL_KNOCKBACK_PAP6;
			}
			default:
			{
				knockback = PURNELL_KNOCKBACK;
			}
		}
		fl_Push_Knockback[client] = knockback;
		
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= Attributes_Get(weapon, 476, 1.0);
		int amount = 2;
		float cooldown = b_PurnellLastMann ? 5.0 : 10.0;
		Explode_Logic_Custom(damage, client, client, weapon, _, 75.0, _, _, _, amount, _, _, _, Purnell_Shove_Melee_Kb);
		//Explode_Logic_Custom(0.0, client, client, weapon, _, 50.0, _, _, _, amount, _, _, _, Logic_Purnell_Debuff);
		//Explode_Logic_Custom(25.0, client, client, weapon, _, 50.0, _, _, _, amount, _, _, _, Purnell_DebuffApply);
		if(b_PushSound[client])
		{
			//Add Sound
			b_PushSound[client] = false;
			Ability_Apply_Cooldown(client, slot, cooldown);
			ClientCommand(client, "playgamesound npc/combine_gunship/ping_search.wav");

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], client, SNDCHAN_AUTO, 70, _, 0.55, 100);
		}
		else
		{
			//failed?
		}
	}
	else
	{
		float cooldown = Ability_Check_Cooldown(client, slot);
		{
			if(cooldown <= 0.0)
				cooldown = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
		}
	}
}

void Purnell_Shove_Melee_Kb(int client, int victim, float damage, int weapon)
{
	float knockback = fl_Push_Knockback[client];
	SensalCauseKnockback(client, victim, (knockback / 900.0), false);
	Logic_Purnell_Debuff(client, victim, damage, weapon);
	if(!b_PushSound[client])
		b_PushSound[client] = true;
}

public Action Purnell_HealerTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(IsValidEntity(weapon))
		{
			if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
			{
				Purnell_Buff_Loc(client);
			}

			return Plugin_Continue;
		}
	}
	
	return Plugin_Stop;
}
bool PurnellDeathsound(int client)
{
	if(Timer_Purnell_Management[client] != null)
	{
		EmitCustomToAll("cof/purnell/death.mp3", client, _, _, _, 2.0);
		return true;
	}
	return false;
}
static void Purnell_Buff_Loc(int client)
{
	float pos[3];
	StartPlayerOnlyLagComp(client, true);
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false);
	EndPlayerOnlyLagComp(client);

	bool validAlly;

	if(target < 1)
	{

	}
	else if(target <= MaxClients)
	{
		if(dieingstate[target] < 1 && TeutonType[target] == TEUTON_NONE)
			validAlly = true;
	}
	else if(!b_NpcHasDied[target])
	{
		if(GetTeam(target) == 2 && !Citizen_ThatIsDowned(target))
		{
			validAlly = true;
		}
	}

	static int color[4] = {255, 255, 255, 200};
	color[0] = validAlly ? 255 : 200;

	if(validAlly)
		GetAbsOrigin(target, pos );
	
	pos[2] += 10.0;

	TE_SetupBeamRingPoint(pos, 100.0, 101.0, LaserIndex, LaserIndex, 0, 1, 0.1, 6.0, 0.1, color, 1, 0);
	TE_SendToClient(client);
}
//buff applies, my usual style - fish
public void Weapon_PurnellBuff_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/suitchargeno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	float cooldown = b_PurnellLastMann ? 5.0 : 15.0;
	float DurationGive = 4.0;
	int buff_apply = GetRandomInt(0, 3);
	Purnell_Configure_Buffs(i_Pap_Level[client], cooldown, DurationGive, buff_apply);
	
	b_LagCompNPC_No_Layers = true;
	StartPlayerOnlyLagComp(client, true);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false);
	EndPlayerOnlyLagComp(client);	

	bool validAlly;

	if(target < 1)
	{
		
	}
	else if(target <= MaxClients)
	{
		if(dieingstate[target] < 1 && TeutonType[target] == TEUTON_NONE)
			validAlly = true;
	}
	else if(!b_NpcHasDied[target])
	{
		if(GetTeam(target) == 2 && !b_NpcIsInvulnerable[target] && !Citizen_ThatIsDowned(target))
		{
			validAlly = true;
		}
	}

	if(validAlly)
	{
		Purnell_AllyBuffApply(client, target, buff_apply, DurationGive, cooldown);

		int BeamIndex = ConnectWithBeam(client, target, 100, 250, 100, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");
		CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
		float HealedAlly[3];
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", HealedAlly);
		HealedAlly[2] += 70.0;
		float HealedAllyRand[3];
		for(int Repeat; Repeat < 10; Repeat++)
		{
			HealedAllyRand = HealedAlly;
			HealedAllyRand[0] += GetRandomFloat(-10.0, 10.0);
			HealedAllyRand[1] += GetRandomFloat(-10.0, 10.0);
			HealedAllyRand[2] += GetRandomFloat(-10.0, 10.0);
			TE_Particle("vortigaunt_hand_glow", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
		}
		
		ClientCommand(client, "playgamesound items/suitchargeok1.wav");
		if(target < MaxClients)
			ClientCommand(target, "playgamesound items/gift_drop.wav");
		
		Ability_Apply_Cooldown(client, slot, cooldown);

		return;
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

static void Purnell_Configure_Buffs(int level, float &cooldown, float &DurationGive, int &buff_apply)
{
	switch(level)
	{
		case 0, 1:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 6.0 : 4.0;
			//buff_apply = ;
		}
		case 2:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 7.0 : 5.0;
			buff_apply = GetRandomInt(0, 3);
		}
		case 3:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 8.0 : 6.0;
			buff_apply = GetRandomInt(0, 4);
		}
		case 4:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 9.0 : 7.0;
			buff_apply = GetRandomInt(0, 5);
		}
		case 5:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 10.0 : 8.0;
			buff_apply = GetRandomInt(0, 7);
		}
		case 6, 7, 8:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 12.0 : 10.0;
			buff_apply = GetRandomInt(0, 9);
		}
	}
}
static void Purnell_AllyBuffApply(int client, int target, int overdose, float DurationGive, float cooldown)
{
	bool validAlly;
	char text[255];
	switch(overdose)
	{
		case 0:
		{
			ApplyStatusEffect(validAlly, target, "Ancient Banner", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Ancient Banner!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Ancient Banner!", target);
			}
		}
		case 1:
		{
			ApplyStatusEffect(validAlly, target, "Buff Banner", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Buff Banner!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Buff Banner!", target);
			}
		}
		case 2:
		{
			ApplyStatusEffect(validAlly, target, "Battilons Backup", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Battalion's Backup!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Battalion's Backup!", target);
			}
		}
		case 3:
		{
			ApplyStatusEffect(validAlly, target, "Combine Command", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Combine Command!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Combine Command!", target);
			}
		}
		case 4:
		{
			ApplyStatusEffect(validAlly, target, "Self Empowerment", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Self Empowerment!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Self Empowerment!", target);
			}
		}
		case 5:
		{
			ApplyStatusEffect(validAlly, target, "Call To Victoria", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Call To Victoria!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Call To Victoria!", target);
			}
		}
		case 6:
		{
			ApplyStatusEffect(validAlly, target, "Caffinated", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Caffeine!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Caffeine!", target);
			}
		}
		case 7:
		{
			ApplyStatusEffect(validAlly, target, "Void Strength I", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Void Strength I!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Void Strength I!", target);
			}
		}
		case 8:
		{
			ApplyStatusEffect(validAlly, target, "False Therapy", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with False Therapy!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with False Therapy!", target);
			}
		}
		case 9:
		{
			ApplyStatusEffect(validAlly, target, "Squad Leader", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You buffed an ally with Squad Leader!");
			}
			else
			{
				FormatEx(text, sizeof(text), "You buffed %N with Squad Leader!", target);
			}
		}
	}
	FormatEx(text, sizeof(text), "%s\nYou gain a %.0f second cooldown!", text, cooldown);
	PrintHintText(client, "%s", text);
}

//public void Weapon_Purnell_Debuff(int client, int victim, int weapon, bool crit, int slot)
public void Logic_Purnell_Debuff(int client, int victim, float damage, int weapon)
{
	float cooldown = b_PurnellLastMann ? 5.0 : 10.0;
	float DurationGive = 4.0;
	int debuff_apply = GetRandomInt(0, 3);
	Purnell_Configure_Debuffs(i_Pap_Level[client], cooldown, DurationGive, debuff_apply);
	Purnell_DebuffApply(client, victim, debuff_apply, DurationGive, cooldown);
}

static void Purnell_Configure_Debuffs(int level, float &cooldown, float &DurationGive, int &debuff_apply)
{
	switch(level)
	{
		case 0, 1:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 6.0 : 4.0;
			//debuff_apply = ;
		}
		case 2:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 7.0 : 5.0;
			debuff_apply = GetRandomInt(0, 3);
		}
		case 3:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 8.0 : 6.0;
			debuff_apply = GetRandomInt(0, 4);
		}
		case 4:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 9.0 : 7.0;
			debuff_apply = GetRandomInt(0, 5);
		}
		case 5:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 10.0 : 8.0;
			debuff_apply = GetRandomInt(0, 7);
		}
		case 6, 7, 8:
		{
			//cooldown = ;
			DurationGive = b_PurnellLastMann ? 12.0 : 10.0;
			debuff_apply = GetRandomInt(0, 9);
		}
	}
}
static void Purnell_DebuffApply(int client, int target, int overdose, float DurationGive, float cooldown)
{
	bool validAlly;
	char text[255];
	switch(overdose)
	{
		case 0:
		{
			ApplyStatusEffect(validAlly, target, "Cryo", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Cryo!");
			}
		}
		case 1:
		{
			ApplyStatusEffect(validAlly, target, "Iberia's Anti Raid", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Iberia's Anti Raid!");
			}
		}
		case 2:
		{
			ApplyStatusEffect(validAlly, target, "Prosperity II", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Prosperity II!");
			}
		}
		case 3:
		{
			ApplyStatusEffect(validAlly, target, "Near Zero", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Near Zero!");
			}
		}
		case 4:
		{
			ApplyStatusEffect(validAlly, target, "Golden Curse", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Golden Curse!");
			}
		}
		case 5:
		{
			ApplyStatusEffect(validAlly, target, "Cudgelled", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Cudgelled!");
			}
		}
		case 6:
		{
			ApplyStatusEffect(validAlly, target, "Teslar Shock", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Teslar Shock!");
			}
		}
		case 7:
		{
			ApplyStatusEffect(validAlly, target, "Specter's Aura", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Specter's Aura!");
			}
		}
		case 8:
		{
			ApplyStatusEffect(validAlly, target, "Teslar Electricution", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Teslar Electricution!");
			}
		}
		case 9:
		{
			ApplyStatusEffect(validAlly, target, "Caffinated Drain", DurationGive);
			if(target > MaxClients)
			{
				FormatEx(text, sizeof(text), "You debuffed an enemy with Caffinated Drain!");
			}
		}
	}
	FormatEx(text, sizeof(text), "%s\nYou gain a %.0f second cooldown!", text, cooldown);
	PrintHintText(client, "%s", text);
}