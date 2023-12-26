#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerRedBladeWeaponManagement[MAXPLAYERS+1] = {null, ...};
static float f_RedBladehuddelay[MAXPLAYERS+1]={0.0, ...};
static bool HALFORNO[MAXPLAYERS];
static int i_RedBladeFireParticle[MAXPLAYERS+1][2];

void ResetMapStartRedBladeWeapon()
{
	Zero(f_RedBladehuddelay);
	RedBlade_Map_Precache();
}

void RedBlade_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("ambient/cp_harbor/furnace_1_shot_02.wav");
	PrecacheSound("items/powerup_pickup_supernova_active.wav");

}

public void Red_charge_ability(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 20.0);
		ClientCommand(client, "playgamesound items/powerup_pickup_supernova_active.wav");
		
		ApplyTempAttrib(weapon, 852, 0.5, 5.0);
		TF2_AddCondition(client, TF_COND_SHIELD_CHARGE, 5.0, client);
	
		//PrintToChatAll("test empower");

	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability on cooldown", Ability_CD);
	}
}
public void Enable_RedBladeWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerRedBladeWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RED_BLADE)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerRedBladeWeaponManagement[client];
			h_TimerRedBladeWeaponManagement[client] = null;
			DataPack pack;
			h_TimerRedBladeWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_RedBlade, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RED_BLADE)
	{
		DataPack pack;
		h_TimerRedBladeWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_RedBlade, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_RedBlade(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		DestroyRedBladeEffect(client);
		h_TimerRedBladeWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		RedBladeHudShow(client, weapon);
	}
	else
	{
		DestroyRedBladeEffect(client);
	}
		
	return Plugin_Continue;
}

void RedBladeHudShow(int client, int weapon)
{
	if(f_RedBladehuddelay[client] < GetGameTime())
	{
		f_RedBladehuddelay[client] = GetGameTime() + 0.5;
		float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
		float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(client);
		if(TF2_IsPlayerInCondition(client, TF_COND_SHIELD_CHARGE))
		{
			LookAtTarget(client, npc.index);
		}
		if (flpercenthpfrommax <= 0.5 && !HALFORNO[client])
		{
			EmitSoundToAll("ambient/cp_harbor/furnace_1_shot_02.wav", client, SNDCHAN_STATIC, 70, _, 0.35);
			HALFORNO[client] = true;
		}
		if (flpercenthpfrommax <= 0.5)
		{
			PrintHintText(client,"Rage Activated",0.5);
			if(!IsRedBladeEffectSpawned(client))
			{
				CreateRedBladeEffect(client);
			}
		}
		else if (HALFORNO[client])
		{
			PrintHintText(client,"Rage Deactivated",0.5);
			HALFORNO[client]=false;
			DestroyRedBladeEffect(client);
		}
	}
}

void WeaponRedBlade_OnTakeDamage(int attacker, float &damage, int weapon, int zr_damage_custom)
{
	float flHealth = float(GetEntProp(attacker, Prop_Send, "m_iHealth"));
	float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(attacker);

	if (flpercenthpfrommax <= 0.5)
	{
		damage *= 2.0;
	}
}


void CreateRedBladeEffect(int client)
{
	//effects below.
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(viewmodelModel))
		return;
	
	DestroyRedBladeEffect(client);
	
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);

	
	int particle = ParticleEffectAt(flPos, "utaunt_hellpit_middlebase", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(viewmodelModel, particle);
	i_RedBladeFireParticle[client][0] = EntIndexToEntRef(particle);

	particle = ParticleEffectAt(flPos, "utaunt_tarotcard_red_glow", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(viewmodelModel, particle);
	i_RedBladeFireParticle[client][1] = EntIndexToEntRef(particle);
}

bool IsRedBladeEffectSpawned(int client)
{
	for(int loop = 0; loop<2; loop++)
	{
		int entity = EntRefToEntIndex(i_RedBladeFireParticle[client][loop]);
		if(!IsValidEntity(entity))
		{
			return true;
		}
	}
	return false;
}

void DestroyRedBladeEffect(int client)
{
	for(int loop = 0; loop<2; loop++)
	{
		int entity = EntRefToEntIndex(i_RedBladeFireParticle[client][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_RedBladeFireParticle[client][loop] = INVALID_ENT_REFERENCE;
	}
}
