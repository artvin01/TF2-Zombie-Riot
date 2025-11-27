#pragma semicolon 1
#pragma newdecls required

static Handle h_KitOmega_Timer[MAXPLAYERS] = {null, ...};
static float f_KitOmega_HUDDelay[MAXPLAYERS];
static int i_KitOmega_GunType[MAXPLAYERS];
static int i_KitOmega_GunTypeNextPredict[MAXPLAYERS];
static int i_KitOmega_GunRef[MAXPLAYERS];
static int i_KitOmega_MeleeRef[MAXPLAYERS];
static int i_KitOmega_WeaponPap[MAXPLAYERS];
static bool b_KitOmega_Toggle[MAXPLAYERS];
static float OMEGA_ENERGY[MAXPLAYERS];
static float OMEGA_MAXENERGY = 100.0;
static float OMEGA_MAXENERGY_PAP = 200.0;
static float OMEGA_PREHITGAIN = 10.0;

static bool b_KitOmega_Using_Gauss[MAXPLAYERS];

//static bool b_KitOmega_Using_Guns[MAXPLAYERS];

#define WEAPON_PICKUP_SOUND "common/wpn_hudoff.wav"
#define WEAPON_DROPSOUND 	"common/warning.wav"
#define WEAPON_SELECTSOUND 	"common/wpn_moveselect.wav"

public float OmegaWeaponCosts(int WeaponType)
{
	switch(WeaponType)
	{
		case 1:
			return 4.0;
		case 2:
			return 10.0;
		case 3:
			return 2.0;
		case 4:
			return 12.5;
	}

	return 0.0;
}
public void KitOmega_OnMapStart()
{
	Zero(f_KitOmega_HUDDelay);
	Zero(i_KitOmega_WeaponPap);
	//Zero(i_KitOmega_GunType);
	for (int i = 0; i <= MaxClients; i++)
	{
		i_KitOmega_GunRef[i] = -1;
		i_KitOmega_MeleeRef[i] = -1;
		i_KitOmega_GunType[i] = 1;
		i_KitOmega_GunTypeNextPredict[i] = 1;
	}
	Zero(b_KitOmega_Toggle);
	Zero(OMEGA_ENERGY);
	
	for (int i = 0; i <= MaxClients; i++)
		b_KitOmega_Using_Gauss[i] = false;
	/*
	for (int i = 0; i <= MaxClients; i++)
		b_KitOmega_Using_Guns[i] = false;*/
	
	//PrecacheModel("models/baka/weapons/entropyzero2/c_pulsepistol.mdl");
	PrecacheSound(WEAPON_PICKUP_SOUND);
	PrecacheSound(WEAPON_DROPSOUND);
	PrecacheSound(WEAPON_SELECTSOUND);
	PrecacheSoundCustom("#zombiesurvival/combinehell/escalationP2.mp3",_,1);
}

public void Enable_KitOmega(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_OMEGA || i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_OMEGA_GAUSS)
	{
		//this is a weapon attached to omega, we want to delay getting the stats of the base weapon, 
		//and then apply any and all changes we need.
		int WhatTypeDo = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		if(WhatTypeDo == 999)
		{
			KitOmegaGiveAttributes(client, weapon);
			return;
		}
		
	}
	DataPack pack = new DataPack();
	if(h_KitOmega_Timer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_OMEGA)
		{
			i_KitOmega_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			b_KitOmega_Toggle[client] = false;
			if(IsValidHandle(h_KitOmega_Timer[client]))
				delete h_KitOmega_Timer[client];
			h_KitOmega_Timer[client] = null;
			
			h_KitOmega_Timer[client] = CreateDataTimer(0.1, Timer_KitOmega, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			i_KitOmega_MeleeRef[client] = EntIndexToEntRef(weapon);
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_OMEGA)
		{
			i_KitOmega_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			b_KitOmega_Toggle[client] = false;
			
			h_KitOmega_Timer[client] = CreateDataTimer(0.1, Timer_KitOmega, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			i_KitOmega_MeleeRef[client] = EntIndexToEntRef(weapon);
		}
	}
}

static Action Timer_KitOmega(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		/*
		if(!IsValidClient(client))
			PrintToConsoleAll("IsValidClient(client)");
		if(!IsClientInGame(client))
			PrintToConsoleAll("IsClientInGame(client)");
		if(!IsPlayerAlive(client))
			PrintToConsoleAll("IsPlayerAlive(client)");
		if(!IsValidEntity(weapon))
			PrintToConsoleAll("IsValidEntity(weapon)");*/
			
		KitOmega_Weapon_Remove_All(client);
		
		//SetDefaultHudPosition(client);
		//SetGlobalTransTarget(client);
		//ShowSyncHudText(client, SyncHud_Notifaction, "BRUH");
		
		int DeleteThisGun = EntRefToEntIndex(i_KitOmega_GunRef[client]);
		if(IsValidEntity(DeleteThisGun))
		{
			TF2_RemoveItem(client, DeleteThisGun);
			//KitOmega_Weapon_Remove_All(client);
				
		}
		if(b_KitOmega_Using_Gauss[client])
			b_KitOmega_Using_Gauss[client] = false;
		h_KitOmega_Timer[client] = null;
		return Plugin_Stop;
	}
/*
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	bool holding;
	if(weapon_holding == weapon)
	{
		holding = true;
	}
	else
		holding = false;
	KitOmega_Function(client, weapon, holding);*/
	KitOmega_HUD(client);

	if(LastMann)
	{
		float maxhealth = 1.0;
		float health = float(GetEntProp(client, Prop_Data, "m_iHealth"));
		maxhealth = float(ReturnEntityMaxHealth(client));

		if(health <= maxhealth * 0.45)
		{
			ApplyStatusEffect(client, client, "Mazeat Command", 2.0);
		}
	}
	
	if(OMEGA_ENERGY[client] <= 0.0 /*&& i_KitOmega_WeaponPap[client] > 0*/)
	{
		OMEGA_ENERGY[client] = 0.0;
		
		KitOmega_Weapon_Remove_All(client);
		
		int DeleteThisGun = EntRefToEntIndex(i_KitOmega_GunRef[client]);
		//PrintToConsoleAll(" 0E DeleteThisGun: %d", DeleteThisGun);
		if(IsValidEntity(DeleteThisGun))
		{
			i_KitOmega_GunRef[client] = -1;
			if(b_KitOmega_Using_Gauss[client])
				b_KitOmega_Using_Gauss[client] = false;
			
			EmitSoundToAll(WEAPON_DROPSOUND, client, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 1.0, 100);
			EmitSoundToAll(WEAPON_DROPSOUND, client, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 1.0, 100);
			//SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
			FakeClientCommandEx(client, "use tf_weapon_shovel");
			CreateTimer(0.5, KitOmega_Weapon_Remove_Later, EntIndexToEntRef(DeleteThisGun), TIMER_FLAG_NO_MAPCHANGE);
			//TF2_RemoveItem(client, DeleteThisGun);
		}
	}

	return Plugin_Continue;
}

public Action KitOmega_Weapon_Remove_Later(Handle h, int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (IsValidEntity(weapon))
	{
		int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
		if(IsValidClient(owner))
		{
			int weapon_holding = GetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
			{
				FakeClientCommand(owner, "use tf_weapon_shovel");
			}
			TF2_RemoveItem(owner, weapon);
		}
	}	
	return Plugin_Handled;
}

//void KitOmega_Weapon_Remove_All(DataPack pack)
void KitOmega_Weapon_Remove_All(int client)
{
	Store_RemoveSpecificItem(client, "KitOmega GaussPistol");
	Store_RemoveSpecificItem(client, "KitOmega Shotgun");
	Store_RemoveSpecificItem(client, "KitOmega AR2");
	Store_RemoveSpecificItem(client, "KitOmega RPG");
	
	//SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
}
/*
static void KitOmega_Function(int client, int weapon, bool holding)
{

}*/

public void KitOmega_RKey(int client, int weapon, bool crit, int slot)//按下r键(press R)
{
	//KitOmega_GUN_Selector_Function(client);
	EmitSoundToAll(WEAPON_SELECTSOUND, client, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 1.0, 100);
	KitOmega_GUN_Swap_Select(client);//开始切换(Start switch)

	//update hud instantly
	f_KitOmega_HUDDelay[client] = 0.0;
	KitOmega_HUD(client);
}

static void KitOmega_GUN_Swap_Select(int client, bool CheckIfValid = false)//切换选择的武器(Switch the weapon)
{
	//int weapon_new = -1;
	//float Time = GetGameTime(client);
	//bool WeaponSwap = false;
	int MaxLoopDo = i_KitOmega_WeaponPap[client] + 1;

	if(MaxLoopDo >= 4)
		MaxLoopDo = 4;

	if(!CheckIfValid)
		i_KitOmega_GunType[client]++;//按下r键后切换选择下一把(press r to next one)
	if(i_KitOmega_GunType[client] > MaxLoopDo)//从1-4循环(loop from 1-4)
	{
		i_KitOmega_GunType[client] = 1;
	}

	//pretend we go 1 further
	if(!CheckIfValid)
	{
		i_KitOmega_GunTypeNextPredict[client] = i_KitOmega_GunType[client];
		i_KitOmega_GunTypeNextPredict[client]++;
	}
	if(i_KitOmega_GunTypeNextPredict[client] > MaxLoopDo)//从1-4循环(loop from 1-4)
	{
		i_KitOmega_GunTypeNextPredict[client] = 1;
	}
}

public void KitOmega_M2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) >0.0)
		return;

	//absolute CD
	Ability_Apply_Cooldown(client, slot, 0.5, _, true);
	if(OMEGA_ENERGY[client] >= 100.0)
	{
		//b_KitOmega_Using_Guns[client] = true;
		KitOmega_GUN_Selector_Function(client, i_KitOmega_GunType[client]);//切换到选择的武器(select picked weapon)
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "You need full energy to take out another weapon!");
	}
}

static void KitOmega_GUN_Selector_Function(int client, int OverrideGunType=-1)
{
	int weapon_new = -1;
	float Time = GetGameTime(client);
	//bool WeaponSwap = false;
	if(OverrideGunType < 1)
		i_KitOmega_GunType[client]++;
	else
		i_KitOmega_GunType[client] = OverrideGunType;
	
	//if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))
	//	WeaponSwap = true;//玩家刚刚拿的 是 拳头，需要自动切换武器(you using fists,need auto switch to weapon)
	
	KitOmega_Weapon_Remove_All(client);
	
	int DeleteThisGun = EntRefToEntIndex(i_KitOmega_GunRef[client]);//获取之前拿出的武器(get previous weapon)
	
	//PrintToConsoleAll(" Out DeleteThisGun: %d", DeleteThisGun);
	
	if(IsValidEntity(DeleteThisGun))//如果存在之前拿出的武器(if previous weapon 'alive')
	{
		TF2_RemoveItem(client, DeleteThisGun);//删掉，防止玩家拿一堆武器(killed)
	}

	switch(i_KitOmega_GunType[client])
	{
		case 1:
		{
			weapon_new = Store_GiveSpecificItem(client, "KitOmega GaussPistol");
			b_KitOmega_Using_Gauss[client] = true;
		}
		case 2:
		{
			weapon_new = Store_GiveSpecificItem(client, "KitOmega Shotgun");
		}
		case 3:
		{
			weapon_new = Store_GiveSpecificItem(client, "KitOmega AR2");
		}
		case 4:
		{
			weapon_new = Store_GiveSpecificItem(client, "KitOmega RPG");
		}
		default:
		{
			weapon_new = Store_GiveSpecificItem(client, "KitOmega GaussPistol");
			b_KitOmega_Using_Gauss[client] = true;
			i_KitOmega_GunType[client] = 1;
		}
	}
		
	if(IsValidEntity(weapon_new))//如果获得的新武器有效(防止因为某些原因武器没有成功生成)[if new eapon effective,to prevent for somereason weapon didn't spawn]
	{
		EmitSoundToAll(WEAPON_PICKUP_SOUND, client, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 1.0, 100);
		//if(WeaponSwap)//玩家需要自动切换武器(if auto swap weapon)
		SetPlayerActiveWeapon(client, weapon_new);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon_new);
		//else
		//	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
		if(i_KitOmega_GunType[client] != 1)
			b_KitOmega_Using_Gauss[client] = false;
		SetEntPropFloat(weapon_new, Prop_Send, "m_flNextPrimaryAttack", Time+0.7);//1.5秒后允许进行攻击(allow to attack after 1.5s)
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", Time+0.7);//1.5秒后允许进行攻击(allow to attack after 1.5s)
		i_KitOmega_GunRef[client] = EntIndexToEntRef(weapon_new);//存储刚刚拿出的武器(save weapon you just took out)
	//	Attributes_Set(weapon_new, 2, multi);
	//	Attributes_Set(weapon_new, 6, firingRate);
		int AmmoLeft = RoundToCeil(OMEGA_ENERGY[client] / OmegaWeaponCosts(i_KitOmega_GunType[client]));
		AmmoLeft += 1000;
		ResetClipOfWeaponStore(weapon_new, client, AmmoLeft);
		//emergency add 1000 over limit hehe
		SetEntData(weapon_new, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), AmmoLeft);
	}
}

public void KitOmega_AddCharge(int client, float amount)
{
	if(amount)
	{
		OMEGA_ENERGY[client] += amount;

		if(OMEGA_ENERGY[client] < 0.0)
		{
			OMEGA_ENERGY[client] = 0.0;
		}
		else
		{
			if(i_KitOmega_WeaponPap[client] >= 5)
			{
				if(OMEGA_ENERGY[client] > OMEGA_MAXENERGY_PAP)
					OMEGA_ENERGY[client] = OMEGA_MAXENERGY_PAP;

			}
			else
			{
				if(OMEGA_ENERGY[client] > OMEGA_MAXENERGY)
					OMEGA_ENERGY[client] = OMEGA_MAXENERGY;

			}
		}
	}

	//TriggerTimer(WeaponTimer[client], true);
}

public void KitOmega_NPCTakeDamage_Gauss(int attacker, int victim, float &damage, int weapon)
{
	//unlock debuffs at pap 5 and above
	if(i_KitOmega_WeaponPap[attacker] <= 3)
	{
		return;
	}
	if(GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon") != GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) && b_KitOmega_Using_Gauss[attacker])
	{
		float duration = 5.0;
		if(b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim])
              duration = 2.0;
		switch(GetRandomInt(0, 3))
		{
			case 0:
				ApplyStatusEffect(attacker, victim, "Maimed", duration);//减速，weapon_sniper_monkey.sp
			case 1:
				ApplyStatusEffect(attacker,victim,"Cryo",duration);
			case 2:
				ApplyStatusEffect(attacker,victim,"Silenced",duration);
			case 3:
				ApplyStatusEffect(attacker,victim,"Enfeeble",duration);
		}
	}
}

public void KitOmega_NPCTakeDamage_Melee(int attacker, int victim, float &damage, int weapon,int damagetype)
{
	if(!(damagetype & (DMG_CLUB | DMG_TRUEDAMAGE)))
		return;
	float energy;
	energy = OMEGA_PREHITGAIN;
	
	if(b_thisNpcIsARaid[victim])//击中的是raidboss(if is raid)
		energy *= 1.25;
	if(LastMann)//最后一人状态(last manm buff)
		energy *= 1.25;
	int Gun = EntRefToEntIndex(i_KitOmega_GunRef[attacker]);
	if(IsValidEntity(Gun))
	{
		switch(i_KitOmega_GunType[attacker])
		{
			default:
				energy *= 0.0;
		}
	}
	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_OMEGA)
	{
		KitOmega_AddCharge(attacker, energy);
		if(OMEGA_ENERGY[attacker] >= 100.0)
			KitOmega_Melee_Extra_OnHit(attacker, victim, weapon);
	}
}

static void KitOmega_HUD(int client)
{
	char weapon_hint[50];
	char weapon_hintNext[50];
	if(f_KitOmega_HUDDelay[client] < GetGameTime())
	{
		KitOmega_GUN_Swap_Select(client, true);
   		switch(i_KitOmega_GunType[client])
		{
			case 1:
			{
				weapon_hint = "GaussPistol";
			}
			case 2:
			{
				weapon_hint = "Shotgun";
			}
			case 3:
			{
				weapon_hint = "AR2";
			}
			case 4:
			{
				weapon_hint = "RapidRPG";
			}
		}
   		switch(i_KitOmega_GunTypeNextPredict[client])
		{
			case 1:
			{
				weapon_hintNext = "GaussPistol";
			}
			case 2:
			{
				weapon_hintNext = "Shotgun";
			}
			case 3:
			{
				weapon_hintNext = "AR2";
			}
			case 4:
			{
				weapon_hintNext = "RapidRPG";
			}
		}
		if(i_KitOmega_WeaponPap[client] <= 0)
		{
			PrintHintText(client,"Energy:%.1f\n[%s]", OMEGA_ENERGY[client], weapon_hint);
		}
		else
		{
			PrintHintText(client,"Energy:%.1f\n[%s] -> [%s]", OMEGA_ENERGY[client], weapon_hint, weapon_hintNext);
		}
		f_KitOmega_HUDDelay[client] = GetGameTime() + 0.5;
	}
}

public void KitOmega_Pistol(int client, int weapon, bool crit, int slot)
{
	KitOmega_Weapon_Fire(client, weapon, crit, slot, 1);
}

public void KitOmega_ShotGun(int client, int weapon, bool crit, int slot)
{
	KitOmega_Weapon_Fire(client, weapon, crit, slot, 2);
}

public void KitOmega_AR2(int client, int weapon, bool crit, int slot)
{
	KitOmega_Weapon_Fire(client, weapon, crit, slot, 3);
}

public void KitOmega_RPG(int client, int weapon, bool crit, int slot)
{
	KitOmega_Weapon_Fire(client, weapon, crit, slot, 4);
}

public void KitOmega_Weapon_Fire(int client, int weapon, bool crit, int slot, int type)
{
	switch(type)
	{
		case 1:
			KitOmega_AddCharge(client, -OmegaWeaponCosts(1));
		case 2:
			KitOmega_AddCharge(client, -OmegaWeaponCosts(2));
		case 3:
			KitOmega_AddCharge(client, -OmegaWeaponCosts(3));
		case 4:
			KitOmega_AddCharge(client, -OmegaWeaponCosts(4));
	}
	if(h_KitOmega_Timer[client] == null)
	{
		//DELETE MYSELF
		Store_RemoveSpecificItem(client, "", false, StoreWeapon[weapon]);
		TF2_RemoveItem(client, weapon);
	}
}

public void KitOmega_Melee(int client, int weapon, bool crit, int slot)
{
	/*
	if(OMEGA_ENERGY[client] >= 99900.0)//unused
	{
		DataPack pack = new DataPack();
		CreateDataTimer(0.15, KitOmega_Melee_Extra, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}*/
}
/*
Action KitOmega_Melee_Extra(Handle timer, DataPack pack)//unused
{
	
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float clientEyePos[3], clientEyeAngle[3], clientEyeDir[3], meleeEnd[3], hullMin[3], hullMax[3];
	GetClientEyePosition(client, clientEyePos);
	GetClientEyeAngles(client, clientEyeAngle);
	GetAngleVectors(clientEyeAngle, clientEyeDir, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(clientEyeDir, clientEyeAngle);
	ScaleVector(clientEyeDir, MELEE_RANGE * 1.5);
	AddVectors(clientEyePos, clientEyeDir, meleeEnd);
	hullMin[0] = -30.0;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	Handle trace = TR_TraceHullFilterEx(clientEyePos, meleeEnd, hullMin, hullMax, MASK_SHOT, BulletAndMeleeTrace, client);
	int victim = TR_GetEntityIndex(trace);
	PrintToConsoleAll("trace found: %d", victim);
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	damage *= 0.5;
	PrintToConsoleAll("damage: %f", damage);
	if(IsValidEnemy(client, victim))
	{
		float vecHit[3];
		TR_GetEndPosition(vecHit, trace);
		SDKHooks_TakeDamage(victim, client, client, damage, DMG_TRUEDAMAGE, -1, _, vecHit);
	}
	delete trace;
	return Plugin_Continue;
}*/

void KitOmega_Melee_Extra_OnHit(int client, int victim, int weapon)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	damage *= Attributes_Get(weapon, 1, 1.0);
	damage *= 0.3;
	if(IsValidEnemy(client, victim))
	{
		float vecHit[3];
		WorldSpaceCenter(victim, vecHit);
		SDKHooks_TakeDamage(victim, client, client, damage, DMG_BULLET, -1, _, vecHit);
	}
}

bool Wkit_Omega_LastMann(int client)
{
	return h_KitOmega_Timer[client] != null;	
}


void KitOmegaGiveAttributes(int client, int weapon)
{
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	RequestFrame(KitOmegaGiveAttributesData, pack);
	//well sucks to suck
	
}


void KitOmegaGiveAttributesData(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	delete pack;
	if(!IsValidEntity(weapon) || !IsValidClient(client))
		return;

	int MeleeKitWeaponMain = EntRefToEntIndex(i_KitOmega_MeleeRef[client]);
	if(!IsValidEntity(MeleeKitWeaponMain))
		return;

	//we get and use attribute 1 for damage, we dont use 2
	//we dont want tinkers and other buffs to affect it.
	float MeleeWeaponMulti = Attributes_Get(MeleeKitWeaponMain, 1, 1.0);
	Attributes_SetMulti(weapon, 2, MeleeWeaponMulti);
	float firingRate = 1.0;
	firingRate *= 1.0 - (float(i_KitOmega_WeaponPap[client]) / 14.0);
	i_KitOmega_GunRef[client] = EntIndexToEntRef(weapon);//存储刚刚拿出的武器(save weapon you just took out)
	Attributes_SetMulti(weapon, 6, firingRate);
}
