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
			SetDefaultHudPosition(client);
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
		damage *= Attributes_Get(weapon, 476, 1.0);


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
						Logic_Purnell_Debuff(client, EnemyHit, damage, weapon);
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
			SetDefaultHudPosition(client);
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
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/suitchargeno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	float cooldown = b_PurnellLastMann ? 5.0 : 15.0;
	float DurationGive = 4.0;
	int buff_apply2;
	int buff_apply = GetRandomInt(0, 3);
	Purnell_Configure_Buffs(i_Pap_Level[client], cooldown, DurationGive, buff_apply);
	if(i_Pap_Level[client] >= 3)
	{
		buff_apply2 = GetRandomInt(0, 3);
		Purnell_Configure_Buffs(i_Pap_Level[client], cooldown, DurationGive, buff_apply2);

		while(buff_apply2 == buff_apply)
		{
			buff_apply2 = GetRandomInt(0, 3);
			Purnell_Configure_Buffs(i_Pap_Level[client], cooldown, DurationGive, buff_apply2);
		}
	}
	DurationGive *= 2.0;

	b_LagCompNPC_No_Layers = true;
	StartPlayerOnlyLagComp(client, true);
	float pos[3];
	int target = GetClientPointVisiblePlayersNPCs(client, 800.0, pos, false);
	EndPlayerOnlyLagComp(client);	

	//If lastman, heal self.
	if(LastMann)
		target = client;

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

		Purnell_AllyBuffApply(client, target, buff_apply, DurationGive);
		if(i_Pap_Level[client] >= 3)
			Purnell_AllyBuffApply(client, target, buff_apply2, DurationGive);

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
			TE_Particle("vortigaunt_hand_glow", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
		}
		
		ClientCommand(client, "playgamesound items/suitchargeok1.wav");
		if(target <= MaxClients)
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
static void Purnell_AllyBuffApply(int client, int target, int overdose, float DurationGive)
{
	char text[255];
	switch(overdose)
	{
		case 0:
		{
			if(target <= MaxClients)
			{
				if(target > MaxClients)
				{
					Format(text, sizeof(text), "대상 아군에게 정신 치료술 버프를 부여했습니다!");
				}
				else
				{
					Format(text, sizeof(text), "대상 %N 에게 정신 치료술 버프를 부여했습니다!", target);
				}
				ApplyStatusEffect(client, target, "Hectic Therapy", DurationGive);
				ApplyStatusEffect(client, client, "Hectic Therapy", DurationGive);
			}
			else
			{
				ApplyStatusEffect(client, target, "Physical Therapy", DurationGive);
				ApplyStatusEffect(client, client, "Physical Therapy", DurationGive);
				if(target > MaxClients)
				{
					Format(text, sizeof(text), "대상 아군에게 물리 치료술 버프를 부여했습니다!");
				}
				else
				{
					Format(text, sizeof(text), "대상 %N 에게 물리 치료술 버프를 부여했습니다!", target);
				}
			}
		}
		case 1:
		{
			ApplyStatusEffect(client, target, "Physical Therapy", DurationGive);
			ApplyStatusEffect(client, client, "Physical Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Physical Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Physical Therapy!", target);
			}
		}
		case 2:
		{
			ApplyStatusEffect(client, target, "Ensuring Therapy", DurationGive);
			ApplyStatusEffect(client, client, "Ensuring Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Ensuring Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Ensuring Therapy!", target);
			}
		}
		case 3:
		{
			ApplyStatusEffect(client, target, "Overall Therapy", DurationGive);
			ApplyStatusEffect(client, client, "Overall Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Overall Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Overall Therapy!", target);
			}
		}
		case 4:
		{
			ApplyStatusEffect(client, target, "Powering Therapy", DurationGive);
			ApplyStatusEffect(client, client, "Powering Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Powering Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Powering Therapy!", target);
			}
		}
		case 5:
		{
			ApplyStatusEffect(client, target, "Calling Therapy", DurationGive);
			ApplyStatusEffect(client, client, "Calling Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Calling Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Calling Therapy!", target);
			}
		}
		case 6:
		{
			ApplyStatusEffect(client, target, "Caffinated Therapy", DurationGive);
			ApplyStatusEffect(client, client, "Caffinated Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Caffinated Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Caffinated Therapy!", target);
			}
		}
		case 7:
		{
			ApplyStatusEffect(client, target, "Regenerating Therapy", DurationGive);
			ApplyStatusEffect(client, client, "Regenerating Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Regenerating Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Regenerating Therapy!", target);
			}
		}
		case 8:
		{
			ApplyStatusEffect(client, target, "False Therapy", DurationGive);
			ApplyStatusEffect(client, client, "False Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with False Therapy!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with False Therapy!", target);
			}
		}
		case 9:
		{
			ApplyStatusEffect(client, target, "Squad Leader", DurationGive);
			ApplyStatusEffect(client, client, "Squad Leader", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You buffed an ally with Squad Leader!");
			}
			else
			{
				Format(text, sizeof(text), "You buffed %N with Squad Leader!", target);
			}
		}
	}
//	Format(text, sizeof(text), "%s\nYou gain a %.0f second cooldown!", text, cooldown);
	//PrintHintText(client, "%s", text);
}

//public void Weapon_Purnell_Debuff(int client, int victim, int weapon, bool crit, int slot)
public void Logic_Purnell_Debuff(int client, int victim, float damage, int weapon)
{
	float cooldown = b_PurnellLastMann ? 5.0 : 10.0;
	float DurationGive = 4.0;
	int debuff_apply = GetRandomInt(0, 3);
	Purnell_Configure_Debuffs(i_Pap_Level[client], cooldown, DurationGive, debuff_apply);
	DurationGive *= 0.75;
//	DurationGive *= 2.0;
	Purnell_DebuffApply(client, victim, debuff_apply, DurationGive);
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
static void Purnell_DebuffApply(int client, int target, int overdose, float DurationGive)
{
	char text[255];
	switch(overdose)
	{
		case 0:
		{
			ApplyStatusEffect(client, target, "Icy Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "대상 적에게 차디찬 퇴락 디버프를 부여했습니다!");
			}
		}
		case 1:
		{
			ApplyStatusEffect(client, target, "Raiding Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Raiding Dereliction!");
			}
		}
		case 2:
		{
			ApplyStatusEffect(client, target, "Degrading Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Degrading Dereliction!");
			}
		}
		case 3:
		{
			ApplyStatusEffect(client, target, "Zero Therapy", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Zero Therapy!");
			}
		}
		case 4:
		{
			ApplyStatusEffect(client, target, "Debt Causing Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Debt Causing Dereliction!");
			}
		}
		case 5:
		{
			ApplyStatusEffect(client, target, "Headache Incuding Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Headache Incuding Dereliction!");
			}
		}
		case 6:
		{
			ApplyStatusEffect(client, target, "Shocking Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Shocking Dereliction!");
			}
		}
		case 7:
		{
			ApplyStatusEffect(client, target, "Therapists Aura", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Therapists Aura!");
			}
		}
		case 8:
		{
			ApplyStatusEffect(client, target, "Electric Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Electric Dereliction!");
			}
		}
		case 9:
		{
			ApplyStatusEffect(client, target, "Caffinated Dereliction", DurationGive);
			if(target > MaxClients)
			{
				Format(text, sizeof(text), "You debuffed an enemy with Caffinated Dereliction!");
			}
		}
	}

	//for hud
	ApplyStatusEffect(client, target, "Therapy Duration", DurationGive);
//	Format(text, sizeof(text), "%s\nYou gain a %.0f second cooldown!", text, cooldown);
//	PrintHintText(client, "%s", text);
}
