#pragma semicolon 1
#pragma newdecls required
#define PURNELL_MAX_RANGE		120
#define PURNELL_MAX_BOUNDS		23.0
#define PURNELL_MAX_TARGETS		5
#define PURNELL_KNOCKBACK		200.0
#define PURNELL_KNOCKBACK_PAP2	300.0
#define PURNELL_KNOCKBACK_PAP3	400.0
#define PURNELL_KNOCKBACK_PAP4	450.0
#define PURNELL_KNOCKBACK_PAP5	500.0
#define PURNELL_KNOCKBACK_PAP6	600.0
#define PURNELL_GAMETEXTICON	"leaderboard_dominated"

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

enum struct PurnellBuff
{
	char buffName[64];
	char shortBuffDesc[64];
}

static PurnellBuff PurnellBuffs[] =
{
	{ "Hectic Therapy", "+atkspd" },
	{ "Physical Therapy", "+dmg" },
	{ "Ensuring Therapy", "+res" },
	{ "Overall Therapy", "+dmg, +res" },
	{ "Powering Therapy", "+dmg, +res" },
	{ "Calling Therapy", "+dmg, +res" },
	{ "Caffeinated Therapy", "+dmg, +res" },
	{ "Regenerating Therapy", "+dmg, +res, +hp regen" },
	{ "False Therapy", "++dmg, ++res" },
	{ "Squad Leader", "+dmg, +res" },
};

static PurnellBuff PurnellDebuffs[] =
{
	{ "Icy Dereliction", "-res, -spd" },
	{ "Raiding Dereliction", "-res" },
	{ "Degrading Dereliction", "-dmg" },
	{ "Zero Therapy", "-res, -spd" },
	{ "Debt-Causing Dereliction", "-res" },
	{ "Headache-Inducing Dereliction", "-res" },
	{ "Shocking Dereliction", "-res, -spd" },
	{ "Therapist's Aura", "--spd" },
	{ "Electric Dereliction", "-res, -spd" },
	{ "Caffeinated Dereliction", "-res" },
};

static int LaserIndex;
static bool Precached;
static int i_Pap_Level[MAXPLAYERS];
static int ParticleRef[MAXPLAYERS] = {-1, ...};
static int i_Current_Pap[MAXPLAYERS] = {0, ...};
Handle Timer_Purnell_Management[MAXPLAYERS] = {null, ...};
static int EnemiesHit[PURNELL_MAX_TARGETS];
static bool b_PushSound[MAXPLAYERS];
static bool b_ShoveSound[MAXPLAYERS];
static float fl_Push_Knockback[MAXPLAYERS];
static bool b_PurnellLastMann;
static int i_SaveWeapon_Revolv[MAXPLAYERS] = {-1, ...};

static int i_LastHealer[MAXPLAYERS];
static int i_NextBuffs[MAXPLAYERS][2];
static int i_NextDebuff[MAXPLAYERS];

static float fl_HudDelay[MAXPLAYERS];

int Purnell_ReturnRevolver(int client)
{
	return i_SaveWeapon_Revolv[client];
}
static const char g_MeleeHitSounds[][] = {
	"cof/purnell/meleehit.mp3",
};
static char g_MeleeAttackSounds[][] = {
	"cof/purnell/shove.mp3",
};

static int Fantasy_Blade_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	return pap;
}

public int Purnell_Existant(int client)
{
	if(Timer_Purnell_Management[client] != null)
	{
		int weapon = EntRefToEntIndex(i_SaveWeapon_Revolv[client]);
		return weapon;
	}
	return 0;
}
void Purnell_MapStart()
{
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	Precached = false;
	Zero(i_Current_Pap);
	Zero(b_PushSound);
	Zero(b_ShoveSound);
	Zero(fl_Push_Knockback);
	Zero(i_Pap_Level);
	Zero(fl_HudDelay);
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
			int level = Fantasy_Blade_Get_Pap(weapon);
			i_Pap_Level[client] = level;
			i_SaveWeapon_Revolv[client] = EntIndexToEntRef(weapon);
			
			DataPack pack;
			Timer_Purnell_Management[client] = CreateDataTimer(0.1, Purnell_Timer_Management, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
			PurnellMusicOst();
		}
	}
}

public void Purnell_OnBuy(int client)
{
	Purnell_Configure_Buffs(client);
	Purnell_Configure_Debuffs(client);
}

void PurnellMusicOst()
{
	if(!Precached)
	{
		PrecacheSoundCustom("#zombiesurvival/purnell_lastman_1.mp3", _, 1);
		Precached = true;
	} 
}

void Add_OneClip_Purnell(int entity, int client)
{
	int AmmoType = GetAmmoType_WeaponPrimary(entity);
	int CurrentReserveAmmo = GetAmmo(client, AmmoType);
	if(CurrentReserveAmmo < 1)
		return;
			
	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	int ammo = GetEntData(entity, iAmmoTable, 4);//Get ammo clip
	if(IsAmmoFullPurnellWeapon(entity, ammo))
		return;
	
	//use to actually subtract one.
	AddAmmoClient(client, AmmoType ,-1,1.0, true);
	ammo += 1;
	SetEntData(entity, iAmmoTable, ammo, 4, true);
	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(entity));
	Update_Ammo(pack);
	AllowWeaponFireAfterEmpty(client, entity);
}

int Purnell_RevolverFull(int weapon)
{
	return RoundFloat(6.0 * Attributes_Get(weapon, 4, 1.0));
}

bool IsAmmoFullPurnellWeapon(int weapon, int ammo)
{
	if(ammo >= Purnell_RevolverFull(weapon))
	{
		return true;
	}
	return false;
}
public Action Purnell_Timer_Management(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientOriginal = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client) && IsValidEntity(weapon) && IsPlayerAlive(client))
	{
		Purnell_LastMann_Check();
		//Purnell_Buff_Loc(client);
		Particle_Add(client);
		Purnell_Hud_Logic(client);
		
		if(i_Pap_Level[client] >= 1 && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
		{
			Purnell_Buff_Loc(client);
		}
		if(i_Pap_Level[client] >= 1)
			ApplyStatusEffect(client, client, "Expert's Mind", 0.5);
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

		int entity = ParticleEffectAt(pos, "utaunt_hands_floor2_purple", -1.0);
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
	if(IsValidEnemy(client, entity, true, true))
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
	return false;
}

public void Purnell_PrimaryShove(int client, int weapon, bool crit, int slot) // "Purnell" Smack
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int pap_level = i_Pap_Level[client];
		bool Giveinto = true;
		float knockback = PURNELL_KNOCKBACK;
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
			case 0:
			{
				fl_Push_Knockback[client] = 0.0;
				Giveinto = false;
			}
			default:
			{
				knockback = PURNELL_KNOCKBACK;
			}
		}
		knockback *= 0.5;
		fl_Push_Knockback[client] = knockback;
		Ability_Apply_Cooldown(client, slot, 2.5 * Attributes_Get(weapon, 6, 1.0));
		DataPack pack = new DataPack();
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(Giveinto);
		RequestFrames(Purnell_Delayed_MeleeAttack, 12, pack);
		EmitCustomToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], client, SNDCHAN_AUTO, 70, _, 1.85, 100);

		int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "13 ; 9999");
		Attributes_Set(client, 178, 0.25);
		FakeClientCommand(client, "use tf_weapon_spellbook");
		Attributes_Set(client, 698, 1.0);
		f_MutePlayerTalkShutUp[client] = GetGameTime() + 0.75;
		
		SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
		SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 5);	
		CreateTimer(0.5, Purnell_RemoveSpell_Primary, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.65, Fireball_Remove_Spell_Entity, EntIndexToEntRef(spellbook), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		float cooldown = Ability_Check_Cooldown(client, slot);
		{
			if(cooldown <= 0.0)
				cooldown = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			Purnell_SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
		}
	}
}

public Action Purnell_RemoveSpell_Primary(Handle Calcium_Remove_SpellHandle, int client)
{
	if (IsValidClient(client))
	{
		Attributes_Set(client, 698, 0.0);
		FakeClientCommand(client, "use tf_weapon_revolver");
		Attributes_Set(client, 178, 1.0);
		TF2_RemoveWeaponSlot(client, 5);
	}	
	return Plugin_Handled;
}

public Action Purnell_RemoveSpell_Melee(Handle Calcium_Remove_SpellHandle, int client)
{
	if (IsValidClient(client))
	{
		Attributes_Set(client, 698, 0.0);
		FakeClientCommand(client, "use tf_weapon_bonesaw");
		Attributes_Set(client, 178, 1.0);
		TF2_RemoveWeaponSlot(client, 5);
	}	
	return Plugin_Handled;
}

public void Purnell_Delayed_MeleeAttack(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int TypeOfShove = pack.ReadCell();
	if(client && weapon != -1/* && IsValidCurrentWeapon(client, weapon)*/)
	{
		float damage = 15.0;
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);


		static const float hullMin[3] = {-PURNELL_MAX_BOUNDS, -PURNELL_MAX_BOUNDS, -PURNELL_MAX_BOUNDS};
		static const float hullMax[3] = {PURNELL_MAX_BOUNDS, PURNELL_MAX_BOUNDS, PURNELL_MAX_BOUNDS};

		float fPos[3];
		float fAng[3];
		float endPoint[3];
		float fPosForward[3];
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
		
		GetAngleVectors(fAng, fPosForward, NULL_VECTOR, NULL_VECTOR);
		
		endPoint[0] = fPos[0] + fPosForward[0] * PURNELL_MAX_RANGE;
		endPoint[1] = fPos[1] + fPosForward[1] * PURNELL_MAX_RANGE;
		endPoint[2] = fPos[2] + fPosForward[2] * PURNELL_MAX_RANGE;

		Zero(EnemiesHit);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		TR_TraceHullFilter(fPos, endPoint, hullMin, hullMax, 1073741824, Purnell_DoSwingTrace, client);	// 1073741824 is CONTENTS_LADDER?
		FinishLagCompensation_Base_boss();

		
		int MaxTargetsHit = PURNELL_MAX_TARGETS;
		if(TypeOfShove == 0)
		{
			MaxTargetsHit = 2;
		}
		
		bool AdditionalBonusRaidHit= false;
		for(int i; i < MaxTargetsHit; i++)
		{
			int EnemyHit = EnemiesHit[i];
			if(!EnemyHit)
			{
				break;
			}
			if(b_thisNpcIsARaid[EnemyHit])
			{
				AdditionalBonusRaidHit = true;
			}
			b_ShoveSound[client] = true;
			static float Entity_Position[3];
			WorldSpaceCenter(EnemyHit, Entity_Position);
			if(!b_NpcIsInvulnerable[EnemyHit])
			{
				Logic_Purnell_Debuff(client, EnemyHit);
				
				switch(TypeOfShove)
				{
					case 0:
					{
						float CalcDamageForceVec[3]; CalculateDamageForce(fPosForward, 20000.0, CalcDamageForceVec);
						SDKHooks_TakeDamage(EnemyHit, client, client, damage, DMG_CLUB, weapon, CalcDamageForceVec, Entity_Position);
					}
					case 1:
					{
						float knockback = fl_Push_Knockback[client];
						if(!b_thisNpcIsARaid[EnemyHit])
							SensalCauseKnockback(client, EnemyHit, (knockback / 900.0), false);
						float CalcDamageForceVec[3]; CalculateDamageForce(fPosForward, 20000.0, CalcDamageForceVec);
						SDKHooks_TakeDamage(EnemyHit, client, client, damage, DMG_CLUB, weapon, CalcDamageForceVec, Entity_Position);
					}
					//dmg penalty
				}
			}
			damage *= 0.75;
		}
		
		
		//Explode_Logic_Custom(damage, client, client, weapon, _, 30.0);
		if(b_ShoveSound[client])
		{
			//Add Sound
			b_ShoveSound[client] = false;
			if(IsValidEntity(i_SaveWeapon_Revolv[client]))
			{
				int Reolver = EntRefToEntIndex(i_SaveWeapon_Revolv[client]);
				Add_OneClip_Purnell(Reolver, client);
				if(AdditionalBonusRaidHit)
					Add_OneClip_Purnell(Reolver, client);

				float CurrentCD = Ability_Check_Cooldown(client, 3, Reolver);
				Ability_Apply_Cooldown(client, 3, CurrentCD - 1.5, Reolver, true);
			}
			EmitCustomToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], client, SNDCHAN_AUTO, 70, _, 2.0, 100);
		}
		
	}
}

//Pack-a-Punch 1

public void Purnell_MeleeShove(int client, int weapon, bool crit, int slot) // "Purnell" Smack
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Ability_Apply_Cooldown(client, slot, 10.0 * Attributes_Get(weapon, 6, 1.0));
		int pap_level = i_Pap_Level[client];
		float knockback = PURNELL_KNOCKBACK;
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
		
		DataPack pack = new DataPack();
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(1);
		RequestFrames(Purnell_Delayed_MeleeAttack, 12, pack);
		EmitCustomToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], client, SNDCHAN_AUTO, 70, _, 1.85, 100);

		int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "13 ; 9999");
		Attributes_Set(client, 178, 0.25);
		FakeClientCommand(client, "use tf_weapon_spellbook");
		Attributes_Set(client, 698, 1.0);
		f_MutePlayerTalkShutUp[client] = GetGameTime() + 0.75;
		
		SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
		SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 5);	
		CreateTimer(0.5, Purnell_RemoveSpell_Melee, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.65, Fireball_Remove_Spell_Entity, EntIndexToEntRef(spellbook), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		float cooldown = Ability_Check_Cooldown(client, slot);
		{
			if(cooldown <= 0.0)
				cooldown = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			Purnell_SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
		}
	}
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
			if(i_Pap_Level[client] >= 1 && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
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
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false, true);
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
	
	if (LastMann && !validAlly)
	{
		// As last man, heal self if not aiming at an ally
		target = client;
		validAlly = true;
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
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/suitchargeno1.wav");
		Purnell_SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	b_LagCompNPC_No_Layers = true;
	StartPlayerOnlyLagComp(client, true);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false, true);
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
	
	if (LastMann && !validAlly)
	{
		// As last man, heal self if not aiming at an ally
		target = client;
		validAlly = true;
	}

	if(validAlly)
	{
		float MaxHealth = float(ReturnEntityMaxHealth(client));
		if(MaxHealth >= 10000.0)
			MaxHealth = 10000.0;
		MaxHealth *= 0.1;
		float MaxHealthally = float(ReturnEntityMaxHealth(target));
		if(MaxHealthally >= 10000.0)
			MaxHealthally = 10000.0;
		MaxHealthally *= 0.1;
		HealEntityGlobal(client, client, MaxHealth, 0.5, 1.0, HEAL_SELFHEAL);
		if(!LastMann)
			HealEntityGlobal(client, target, MaxHealthally, 0.5, 1.0);

		HealPointToReinforce(client, 1, 0.02);
		
		float cooldown = b_PurnellLastMann ? 5.0 : 15.0;
		
		Purnell_AllyBuffApply(client, target);
		
		// Set up the next buffs
		Purnell_Configure_Buffs(client);
		
		int BeamIndex = ConnectWithBeam(client, target, 255, 255, 100, 3.0, 3.0, 1.35, "sprites/laserbeam.vmt");
		SetEntityRenderFx(BeamIndex, RENDERFX_FADE_SLOW);
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
			TE_Particle("healhuff_red", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
		}
		
		ClientCommand(client, "playgamesound items/suitchargeok1.wav");
		if(target <= MaxClients)
			ClientCommand(target, "playgamesound items/gift_drop.wav");
		
		Ability_Apply_Cooldown(client, slot, cooldown);

		return;
	}

	ClientCommand(client, "playgamesound items/medshotno1.wav");
}

static void Purnell_Configure_Buffs(int client)
{
	int maxBuffId = 3;
	int level = i_Pap_Level[client];
	switch(level)
	{
		case 0, 1, 2:
			maxBuffId = 3;
		
		case 3:
			maxBuffId = 4;
		
		case 4:
			maxBuffId = 5;
		
		case 5:
			maxBuffId = 7;
		
		case 6, 7, 8:
			maxBuffId = 9;
	}
	
	ArrayList buffList = new ArrayList();
	for (int i = 0; i <= maxBuffId; i++)
		buffList.Push(i);
	
	buffList.Sort(Sort_Random, Sort_Integer);
	
	for (int i = 0; i < 2; i++)
		i_NextBuffs[client][i] = buffList.Get(i);
	
	delete buffList;
}

static void Purnell_AllyBuffApply(int client, int target)
{
	char textSelf[255], textOther[255], buff[64], name[128];
	Purnell_GetTargetName(target, client, name, sizeof(name));
	
	float duration = 4.0;
	int level = i_Pap_Level[client];
	switch(level)
	{
		case 0, 1:
			duration = b_PurnellLastMann ? 6.0 : 4.0;
		
		case 2:
			duration = b_PurnellLastMann ? 7.0 : 5.0;
		
		case 3:
			duration = b_PurnellLastMann ? 8.0 : 6.0;
		
		case 4:
			duration = b_PurnellLastMann ? 9.0 : 7.0;
		
		case 5:
			duration = b_PurnellLastMann ? 10.0 : 8.0;
		
		case 6, 7, 8:
			duration = b_PurnellLastMann ? 12.0 : 10.0;
	}
	
	duration *= 2.0;
	
	bool targetIsOtherClient = (target <= MaxClients && target != client);
	bool targetIsSelf = target == client;
	
	int buffAmount = 1;
	if (level >= 3)
		buffAmount = 2;
	
	if (targetIsSelf)
		Format(textSelf, sizeof(textSelf), "You have buffed yourself with:\n");
	else
		Format(textSelf, sizeof(textSelf), "You have shared buffs with %s:\n", name);
	
	if (targetIsOtherClient)
		Format(textOther, sizeof(textOther), "You have received Therapy buffs from %N:\n", client);
	
	for (int i = 0; i < buffAmount; i++)
	{
		int buffId = i_NextBuffs[client][i];
		strcopy(buff, sizeof(buff), PurnellBuffs[buffId].buffName);
		
		Format(textSelf, sizeof(textSelf), "%s%s%T (%s)", textSelf, i != 0 ? ", " : "", buff, client, PurnellBuffs[buffId].shortBuffDesc);
		
		if (targetIsOtherClient)
			Format(textOther, sizeof(textOther), "%s%s%T (%s)", textOther, i != 0 ? ", " : "", buff, target, PurnellBuffs[buffId].shortBuffDesc);
		
		ApplyStatusEffect(client, target, buff, duration);
		ApplyStatusEffect(client, client, buff, duration);
	}
	
	i_LastHealer[client] = client;
	ShowGameText(client, PURNELL_GAMETEXTICON, _, textSelf);
	
	DataPack pack;
	CreateDataTimer(2.0, Purnell_Timer_ShowBuffMessageAgain, pack);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(client);
	pack.WriteString(textSelf);
	
	if (targetIsOtherClient)
	{
		i_LastHealer[target] = client;
		ShowGameText(target, PURNELL_GAMETEXTICON, _, textOther);
		
		DataPack pack2;
		CreateDataTimer(2.0, Purnell_Timer_ShowBuffMessageAgain, pack2);
		pack2.WriteCell(GetClientUserId(target));
		pack2.WriteCell(client);
		pack2.WriteString(textOther);
	}
}

//public void Weapon_Purnell_Debuff(int client, int victim, int weapon, bool crit, int slot)
public void Logic_Purnell_Debuff(int client, int victim)
{
	Purnell_DebuffApply(client, victim);
	
	// Set up the next debuff
	Purnell_Configure_Debuffs(client);
}

static void Purnell_Configure_Debuffs(int client)
{
	int maxDebuffId = 3;
	int level = i_Pap_Level[client];
	switch(level)
	{
		case 0, 1, 2:
			maxDebuffId = 3;
		
		case 3:
			maxDebuffId = 4;
		
		case 4:
			maxDebuffId = 5;
		
		case 5:
			maxDebuffId = 7;
		
		case 6, 7, 8:
			maxDebuffId = 9;
	}
	
	i_NextDebuff[client] = GetURandomInt() % (maxDebuffId + 1);
}

static void Purnell_DebuffApply(int client, int target)
{
	float duration = 4.0;
	int level = i_Pap_Level[client];
	switch(level)
	{
		case 0, 1:
			duration = b_PurnellLastMann ? 6.0 : 4.0;
		
		case 2:
			duration = b_PurnellLastMann ? 7.0 : 5.0;
		
		case 3:
			duration = b_PurnellLastMann ? 8.0 : 6.0;
		
		case 4:
			duration = b_PurnellLastMann ? 9.0 : 7.0;
		
		case 5:
			duration = b_PurnellLastMann ? 10.0 : 8.0;
		
		case 6, 7, 8:
			duration = b_PurnellLastMann ? 12.0 : 10.0;
	}
	
	duration *= 0.75;
	//duration *= 2.0;
	
	char buff[64];
	int buffId = i_NextDebuff[client];
	strcopy(buff, sizeof(buff), PurnellDebuffs[buffId].buffName);
	
	ApplyStatusEffect(client, target, buff, duration);
	ApplyStatusEffect(client, target, "Therapy Duration", duration);
	
//	Format(text, sizeof(text), "%s\nYou gain a %.0f second cooldown!", text, cooldown);
//	PrintHintText(client, "%s", text);
}

static void Purnell_Hud_Logic(int client)
{
	if(fl_HudDelay[client] > GetGameTime())
		return;

	char text[256], buff[128];
	
	int level = i_Pap_Level[client];
	int buffAmount = 0;
	
	if (level >= 3)
		buffAmount = 2;
	else if (level >= 1)
		buffAmount = 1;
	
	if (buffAmount > 0)
	{
		Format(text, sizeof(text), "Next %s:", buffAmount == 1 ? "therapy" : "therapies");
		for (int i = 0; i < buffAmount; i++)
		{
			int buffId = i_NextBuffs[client][i];
			strcopy(buff, sizeof(buff), PurnellBuffs[buffId].buffName);
			ReplaceString(buff, sizeof(buff), " Therapy", "");
			Format(text, sizeof(text), "%s\n- %s (%s)", text, buff, PurnellBuffs[buffId].shortBuffDesc);
		}
		
		Format(text, sizeof(text), "%s\n \n", text);
	}
	
	Format(text, sizeof(text), "%sNext debuff:", text);
	
	int debuffId = i_NextDebuff[client];
	strcopy(buff, sizeof(buff), PurnellDebuffs[debuffId].buffName);
	Format(text, sizeof(text), "%s\n- %T (%s)", text, buff, client, PurnellDebuffs[debuffId].shortBuffDesc);

	fl_HudDelay[client] = GetGameTime() + 0.5;
	PrintHintText(client, "%s", text);
}

static void Purnell_GetTargetName(int target, int client, char[] buffer, int length)
{
	if (target == 0)
		return;
	
	if (target <= MaxClients)
	{
		FormatEx(buffer, length, "%N", target);
		return;
	}
	
	if (!b_NameNoTranslation[target])
		FormatEx(buffer, length, "%T", c_NpcName[target], client);
	else
		strcopy(buffer, length, c_NpcName[target]);
}

static void Purnell_Timer_ShowBuffMessageAgain(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if (client == 0)
		return;
	
	// Only show the message again if healers haven't changed so it doesn't swap back and forth between multiple recent healers
	int healer = pack.ReadCell();
	if (healer != i_LastHealer[client])
		return;
	
	char text[255];
	pack.ReadString(text, sizeof(text));
	
	ShowGameText(client, PURNELL_GAMETEXTICON, _, text);
}

static void Purnell_SetDefaultHudPosition(int client, int red = 34, int green = 139, int blue = 34, float duration = 1.01)
{
	if (f_NotifHudOffsetX[client] == 0.0 && f_NotifHudOffsetY[client] == 0.0)
	{
		// If the player hasn't changed their HUD setting, move the HUD warning up a bit so it doesn't clash with the buff/debuff element
		const float hudX = -1.0;
		const float hudY = 0.6;
		
		SetHudTextParams(hudX, hudY, duration, red, green, blue, 255);
		return;
	}
	
	SetDefaultHudPosition(client);
}