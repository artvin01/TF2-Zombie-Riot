#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerExploARWeaponManagement[MAXPLAYERS] = {null, ...};

static int i_WindowsVistaParticle_1[MAXPLAYERS]; 
static int ExploAR_ZoomLaser[MAXPLAYERS];
static int ExploAR_WindowsVistaNuke[MAXPLAYERS];
static int ExploAR_Robot[MAXPLAYERS];

static int ExploAR_AirStrikeActivated[MAXPLAYERS];
static int ExploAR_AirStrikeActivatedMAX[MAXPLAYERS];

static int ExploAR_WeaponPap[MAXPLAYERS+1] = {0, ...};
static int ExploAR_WeaponID[MAXPLAYERS];
static int ExploAR_TargetingRemoteID[MAXPLAYERS];
static int ExploAR_BurstNum[MAXPLAYERS];
static int ExploAR_OverHit[MAXPLAYERS];
static int ExploAR_Charging[MAXPLAYERS];
static int ExploAR_Battery[MAXPLAYERS];

static float ExploAR_OverHeatDelay[MAXPLAYERS];
static float ExploAR_HUDDelay[MAXPLAYERS];
static bool Can_I_Fire[MAXPLAYERS] = {false, ...};
static bool IsDeploy[MAXPLAYERS] = {false, ...};
static bool IsOverride[MAXPLAYERS] = {false, ...};
static bool IsExtraDesc_1[MAXPLAYERS] = {false, ...};
static bool IsExtraDesc_2[MAXPLAYERS] = {false, ...};
static bool IsExtraDesc_3[MAXPLAYERS] = {false, ...};

static int g_LaserIndex;

public void ResetMapStartExploARWeapon()
{
	PrecacheSound("weapons/stickybomblauncher_det.wav");
	PrecacheSound("weapons/flare_detonator_launch.wav");
	PrecacheSound("weapons/gunslinger_three_hit.wav");
	PrecacheSound("beams/beamstart5.wav");
	PrecacheSound("weapons/drg_pomson_drain_01.wav");
	PrecacheModel("models/props_farm/vent001.mdl");
	PrecacheModel("models/weapons/w_models/w_drg_ball.mdl");
	g_LaserIndex = PrecacheModel(LASERBEAM);
	Zero(Can_I_Fire);
	Zero(ExploAR_OverHit);
	Zero(ExploAR_HUDDelay);
	Zero(ExploAR_OverHeatDelay);
	Zero(ExploAR_Charging);
	Zero(ExploAR_Battery);
	Zero(ExploAR_AirStrikeActivated);
	Zero(ExploAR_AirStrikeActivatedMAX);
}

public void BombAR_M1_Attack(int client, int weapon, bool crit, int slot)
{
	int OverHit_Increase=ExploAR_OverHit[client]+2;
	if(HasSpecificBuff(client, "Burn"))
		OverHit_Increase++;
	if(HasSpecificBuff(client, "Freeze")||HasSpecificBuff(client, "Cryo")
	||HasSpecificBuff(client, "Near Zero")||HasSpecificBuff(client, "Frozen"))
		OverHit_Increase--;
	switch(ExploAR_WeaponPap[client])
	{
		case 2:{if(OverHit_Increase>150)OverHit_Increase=150;OverHit_Increase++;}
		default:{if(OverHit_Increase>100)OverHit_Increase=100;}
	}
	ExploAR_OverHit[client]=OverHit_Increase;
	ExploAR_OverHeatDelay[client]=GetGameTime()+1.62;
	ExploAR_HUDDelay[client] = 0.0;
	SetEntProp(weapon, Prop_Send, "m_nKillComboCount", GetEntProp(weapon, Prop_Send, "m_nKillComboCount") + 1);
	Firebullet(client, weapon, ExploAR_OverHit[client], ExploAR_WeaponPap[client]);
	if(!Can_I_Fire[client])
	{
		Can_I_Fire[client]=true;
		SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
		SDKHook(client, SDKHook_PreThink, BombAR_M1_PreThink);
	}
}

static void BombAR_M1_PreThink(int client)
{
	int weapon = EntRefToEntIndex(ExploAR_WeaponID[client]);
	if(h_TimerExploARWeaponManagement[client] != null && IsValidEntity(weapon))
	{
		float gameTime = GetGameTime();
		float attackTime = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack")- gameTime;
		float burstRate = Attributes_Get(weapon, 394, 1.0);
		if(GetClientButtons(client) & IN_ATTACK && GetEntProp(weapon, Prop_Send, "m_iClip1") != 0)
		{
			if(GetEntProp(weapon, Prop_Send, "m_nKillComboCount")>=ExploAR_BurstNum[client])
			{
				SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", gameTime + (burstRate * attackTime));
				SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			}
		}
		else
		{
			SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", gameTime + (burstRate * attackTime));
			SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			Can_I_Fire[client]=false;
			SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
			return;
		}
	}
	else
	{
		Can_I_Fire[client]=false;
		SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
		return;
	}
}

/*public void BombAR_Zoom_n_Laser(int client, int weapon, bool crit, int slot)
{
	//Weapon_Railcannon_Pap2_Zoom(client, -1, false, -1);
	SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
	if(Capacitor_Active[client] == false)
	{
		int Prop = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
		if(IsValidEntity(Prop))
		{
			RemovePorps(Prop);
			RemoveEntity(Prop);
		}
		Prop = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(Prop))
		{
			static float vAngles[3], vOrigin[3];
			GetClientEyePosition(client, vOrigin);
			GetClientEyeAngles(client, vAngles);
			LaserPoint(client, vAngles, vOrigin, vOrigin);
			DispatchKeyValue(Prop, "model", "models/weapons/w_models/w_drg_ball.mdl");
			DispatchKeyValue(Prop, "solid", "0");
			TeleportEntity(Prop, vOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(Prop);
			
			AddEntityToOwnerTransitMode(client, Prop);
			ExploAR_ZoomLaser[client]=EntIndexToEntRef(Prop);
			SetVariantString("1.5");
			AcceptEntityInput(Prop, "SetModelScale");
			SetEntPropEnt(Prop, Prop_Data, "m_hOwnerEntity", client);
			SetEntityRenderMode(Prop, RENDER_TRANSCOLOR);
			SetEntityRenderColor(Prop, 255, 0, 0, 254);
			RequestFrame(SniperLaserSpawn, Prop);
			SDKHook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
			Attributes_Set(weapon, 298, (ExploAR_AirStrikeActivated[client] ? 1.0 : 5.0));
			Capacitor_Active[client] = true;
		}
	}
	else
	{
		int Prop = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
		if(IsValidEntity(Prop))
		{
			RemovePorps(Prop);
			RemoveEntity(Prop);
		}
		ExploAR_Charging[client]=0;
		Capacitor_Active[client] = false;
		Attributes_Set(weapon, 298, 1.0);
	}
}*/

static void BombAR_Laser_PreThink(int client)
{
	int weapon = EntRefToEntIndex(ExploAR_WeaponID[client]);
	int Prop = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
	if(ExploAR_AirStrikeActivated[client]>64 && h_TimerExploARWeaponManagement[client] != null && IsValidEntity(weapon) && IsValidEntity(Prop))
	{
		static float vAngles[3], vOrigin[3];
		GetClientEyePosition(client, vOrigin);
		GetClientEyeAngles(client, vAngles);
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		LaserPoint(client, vAngles, vOrigin, vOrigin);
		FinishLagCompensation_Base_boss();
		TeleportEntity(Prop, vOrigin, NULL_VECTOR, NULL_VECTOR);
	}
	else
	{
		SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
		return;
	}
}

static bool LaserPoint(int entity, float flAng[3], float flPos[3], float pos[3])
{
	Handle trace = TR_TraceRayFilterEx(flPos, flAng, MASK_SHOT, RayType_Infinite, AnyHit, entity);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

static bool AnyHit(int entity, int contentsMask, any data)
{
	return entity!=data;
}

public void BombAR_ICE_Inject(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		if(Ability_CD <= 0.0 || CvarInfiniteCash.BoolValue)
			Ability_CD = 0.0;
		if(Ability_CD)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		if(ExploAR_OverHit[client]>64)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 15.0);
			EmitSoundToAll("weapons/flare_detonator_launch.wav", client, SNDCHAN_AUTO, 70, _, 1.0);
			EmitSoundToAll("weapons/gunslinger_three_hit.wav", client, SNDCHAN_AUTO, 70, _, 1.0);
			float range = (ExploAR_WeaponPap[client]==2 ? 130.0 : 65.0);
			float damage = 500.0;
			damage *= Attributes_Get(weapon, 2, 1.0);
			damage += (float(ExploAR_OverHit[client])/65.0)*(damage/2.0);
			if(ExploAR_WeaponPap[client]==2 && ExploAR_OverHit[client]>99)
			{
				range *= 1.5;
				damage *= (float(ExploAR_OverHit[client])/75.0);
			}
			float speed = 3000.0;
			speed *= Attributes_Get(weapon, 103, 1.0);

			float time = 5000.0/speed;
			int Projectile=Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "rockettrail_RocketJumper");
			if(ExploAR_WeaponPap[client]==2)
				b_Anger[Projectile]=true;
			fl_Dead_Ringer_Invis[Projectile]=range;
			WandProjectile_ApplyFunctionToEntity(Projectile, VentTouch);
			
			Projectile=ApplyCustomModelToWandProjectile(Projectile, "models/props_farm/vent001.mdl", 0.3, "");
			TeleportEntity(Projectile, NULL_VECTOR, {-90.0, 0.0, 0.0}, NULL_VECTOR);
			int RColor = 100+RoundFloat((float(ExploAR_OverHit[client])/65.0)*101.0);
			if(RColor>255)RColor=255;
			SetEntityRenderColor(Projectile, RColor, 60, 5, 255);
			IgniteTargetEffect(Projectile);
			ExploAR_OverHit[client]=0;
			return;
		}
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "ExploAR_Not_Enough_OverHeat", 65);
	}
}

static bool CloseGetNPC(int entity, ArrayList list)
{
	if(IsValidEnemy(list.Get(0), entity, true, true))
	{
		list.Push(entity);
		if (list.Length >= 15) {
			return false;
		}
	}
	return true;
}

public void BombAR_AirStrike_Beacon(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		if(Ability_CD <= 0.0 || CvarInfiniteCash.BoolValue)
			Ability_CD = 0.0;
		if(Ability_CD)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		if(ExploAR_Battery[client]<90)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not enough charge");
			return;
		}
		int Robot = EntRefToEntIndex(ExploAR_Robot[client]);
		if(!IsValidEntity(Robot))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "ExploAR_NeedRobo");
			return;
		}
		if(IsValidEntity(weapon))
		{
			float ClipAttributes = Attributes_Get(weapon, 4, 1.0);
			int SMGAmmo=GetAmmo(client, 18);
			int SMGAmmoMAX=RoundToCeil(2.5*ClipAttributes);
			if(SMGAmmoMAX>9)SMGAmmoMAX=9;//No no no... Too much...
			if(SMGAmmo<SMGAmmoMAX)
			{
				SMGAmmoMAX-=SMGAmmo;
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Ammo", SMGAmmoMAX);
				return;
			}
			ClientCommand(client, "playgamesound ui/cyoa_map_open.wav");
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 50.0);
			
			ExploAR_AirStrikeActivated[client]=SMGAmmoMAX+64;
			ExploAR_AirStrikeActivatedMAX[client]=SMGAmmoMAX;
			
			SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", GetGameTime() + 1.0);
			SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			SetEntProp(weapon, Prop_Send, "m_nKillComboClass", SMGAmmoMAX);
			Can_I_Fire[client]=false;
			SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
			int Prop = EntRefToEntIndex(ExploAR_WindowsVistaNuke[client]);
			if(IsValidEntity(Prop))
			{
				RemovePorps(Prop);
				RemoveEntity(Prop);
			}
			Prop = CreateEntityByName("prop_dynamic");
			if(IsValidEntity(Prop))
			{
				static float vOrigin[3];
				GetClientEyePosition(client, vOrigin);
				DispatchKeyValue(Prop, "model", "models/weapons/w_models/w_drg_ball.mdl");
				DispatchKeyValue(Prop, "solid", "0");
				TeleportEntity(Prop, vOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(Prop);
				
				ExploAR_WindowsVistaNuke[client]=EntIndexToEntRef(Prop);
				SetVariantString("1.5");
				AcceptEntityInput(Prop, "SetModelScale");
				SetEntPropEnt(Prop, Prop_Data, "m_hOwnerEntity", client);
				SetEntityRenderMode(Prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(Prop, 255, 255, 255, 1);
				SetEntPropFloat(Prop, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(Prop, Prop_Send, "m_fadeMaxDist", 1.0);
				SetParent(client, Prop);
			}
			SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
			Prop = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
			if(IsValidEntity(Prop))
			{
				RemovePorps(Prop);
				RemoveEntity(Prop);
			}
			Prop = CreateEntityByName("prop_dynamic");
			if(IsValidEntity(Prop))
			{
				static float vAngles[3], vOrigin[3];
				GetClientEyePosition(client, vOrigin);
				GetClientEyeAngles(client, vAngles);
				LaserPoint(client, vAngles, vOrigin, vOrigin);
				DispatchKeyValue(Prop, "model", "models/weapons/w_models/w_drg_ball.mdl");
				DispatchKeyValue(Prop, "solid", "0");
				TeleportEntity(Prop, vOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(Prop);
				
				AddEntityToOwnerTransitMode(client, Prop);
				ExploAR_ZoomLaser[client]=EntIndexToEntRef(Prop);
				SetVariantString("1.5");
				AcceptEntityInput(Prop, "SetModelScale");
				SetEntPropEnt(Prop, Prop_Data, "m_hOwnerEntity", client);
				SetEntityRenderMode(Prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(Prop, 255, 0, 0, 254);
				Robot = ConnectWithBeam(Robot, Prop, 50, 0, 0, 3.0, 0.1, 0.0, LASERBEAM);
				SetEntityRenderColor(Robot, 50, 0, 0, 255);
				AddEntityToOwnerTransitMode(client, Robot);
				view_as<CClotBody>(Prop).m_iWearable1 = Robot;
				SDKHook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
			}
			IsOverride[client]=true;
			Prop = Store_GiveSpecificItem(client, "ER Targeting Remote");
			ResetClipOfWeaponStore(Prop, client, SMGAmmoMAX);
			SetEntData(Prop, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), SMGAmmoMAX);
			ExploAR_TargetingRemoteID[client]=EntIndexToEntRef(Prop);
			ExploAR_Battery[client]=0;
		}
	}
}

public void Enable_ExploARWeapon(int client, int weapon)
{
	IsOverride[client]=false;
	fl_Charge_delay[weapon] = 1.0;
	if(h_TimerExploARWeaponManagement[client] != null)
	{
		delete h_TimerExploARWeaponManagement[client];
		h_TimerExploARWeaponManagement[client] = null;
		DataPack pack;
		h_TimerExploARWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ExploAR, pack, TIMER_REPEAT);
		pack.WriteCell(client);
	}
	else
	{
		DataPack pack;
		h_TimerExploARWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ExploAR, pack, TIMER_REPEAT);
		pack.WriteCell(client);
	}
	if(Store_IsWeaponFaction(client, weapon, Faction_Vesta))	// Vesta
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(h_TimerExploARWeaponManagement[i])
			{
				ApplyStatusEffect(weapon, weapon, "Explosault Rifle Buff", 9999999.0);
				Attributes_SetMulti(weapon, 4013, 1.1);
			}
		}
	}
}

public void Deploy_ExploARWeapon(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon]!=WEAPON_BOMB_AR)
		return;
	if(IsValidEntity(weapon))
	{
		ExploAR_WeaponPap[client] = ExplosiveAR_Get_Pap(weapon);
		ExploAR_BurstNum[client] = RoundToCeil(Attributes_Get(weapon, 401, 1.0));
		ExploAR_WeaponID[client]=EntIndexToEntRef(weapon);
		fl_Charge_delay[weapon] = 0.0;
		fl_JumpCooldown[weapon] = 0.0;
	}
	Can_I_Fire[client]=false;
	if(ExploAR_AirStrikeActivated[client])
	{
		WindowsVistaNukeEngage(client, weapon);
		SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
		int Prop = EntRefToEntIndex(ExploAR_WindowsVistaNuke[client]);
		if(IsValidEntity(Prop))
		{
			RemovePorps(Prop);
			RemoveEntity(Prop);
		}
		ExploAR_AirStrikeActivated[client]=0;
		Store_RemoveSpecificItem(client, "ER Targeting Remote");
		DestroyExploAREffect(client);
	}
	CreateExploAREffect(client);
	IsDeploy[client]=true;
	if(!IsExtraDesc_1[client] && ExploAR_WeaponPap[client]==3)
	{
		SetGlobalTransTarget(client);
		CPrintToChat(client, "%s%t", STORE_COLOR, "Explosault Rifle AB 1 Desc Extra");
		IsExtraDesc_1[client]=true;
	}
	if(!IsExtraDesc_2[client] && ExploAR_WeaponPap[client]==4)
	{
		SetGlobalTransTarget(client);
		CPrintToChat(client, "%s%t", STORE_COLOR, "Explosault Rifle AB 2 Desc Extra");
		IsExtraDesc_2[client]=true;
	}
	if(!IsExtraDesc_3[client] && ExploAR_WeaponPap[client]==5)
	{
		SetGlobalTransTarget(client);
		CPrintToChat(client, "%s%t", STORE_COLOR, "Explosault Rifle AB 3 Desc Extra");
		IsExtraDesc_3[client]=true;
	}
}
public void Holster_ExploARWeapon(int client)
{
	int entity = EntRefToEntIndex(ExploAR_WeaponID[client]);
	if(IsValidEntity(entity) && IsOverride[client])
	{
		IsOverride[client]=false;
		return;
	}
	
	entity = EntRefToEntIndex(ExploAR_Robot[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	if(ExploAR_AirStrikeActivated[client])
	{
		entity = EntRefToEntIndex(ExploAR_WindowsVistaNuke[client]);
		if(IsValidEntity(entity))
		{
			RemovePorps(entity);
			RemoveEntity(entity);
		}
		ExploAR_AirStrikeActivated[client]=0;
	}
	Store_RemoveSpecificItem(client, "ER Targeting Remote");
	entity = EntRefToEntIndex(ExploAR_TargetingRemoteID[client]);
	if(IsValidEntity(entity))
	{
		Store_RemoveSpecificItem(client, "", false, StoreWeapon[entity]);
		TF2_RemoveItem(client, entity);
		entity = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
		if(IsValidEntity(entity))
		{
			RemovePorps(entity);
			RemoveEntity(entity);
		}
		TF2_AutoSetActiveWeapon(client);
	}

	IsDeploy[client]=false;
	DestroyExploAREffect(client);
}

static Action Timer_Management_ExploAR(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(ExploAR_WeaponID[client]);
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerExploARWeaponManagement[client] = null;
		IsOverride[client]=false;
		IsExtraDesc_1[client]=false;
		IsExtraDesc_2[client]=false;
		IsExtraDesc_3[client]=false;
		Holster_ExploARWeapon(client);
		//SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
		SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
		return Plugin_Stop;
	}	
	float GameTime = GetGameTime();
	if(ExploAR_OverHeatDelay[client] < GameTime)
	{
		int OverHit_Decrease=(ExploAR_WeaponPap[client]>2 ? 2 : 4);
		if(HasSpecificBuff(client, "Burn"))
			OverHit_Decrease--;
		if(HasSpecificBuff(client, "Freeze")||HasSpecificBuff(client, "Cryo")
		||HasSpecificBuff(client, "Near Zero")||HasSpecificBuff(client, "Frozen"))
			OverHit_Decrease++;
		ExploAR_OverHit[client]-=OverHit_Decrease;
		if(ExploAR_OverHit[client]<0)ExploAR_OverHit[client]=0;
	}
	
	if(IsDeploy[client])
	{
		ExploARWork(client, weapon, GameTime);
	
		if(ExploAR_WeaponPap[client]>3)
		{
			int Robot = EntRefToEntIndex(ExploAR_Robot[client]);
			if(!IsValidEntity(Robot))
			{
				if(!fl_Charge_delay[weapon])
					fl_Charge_delay[weapon] = GameTime + 10.0;
				else if(fl_Charge_delay[weapon] < GameTime)
				{
					Robot = Wand_Projectile_Spawn(client, 0.0, 0.0, 0.0, 0, weapon, "rockettrail_RocketJumper");
					int particle = EntRefToEntIndex(i_WandParticle[Robot]);
					if(IsValidEntity(particle))
						RemoveEntity(particle);
					WandProjectile_ApplyFunctionToEntity(Robot, NoClipRobotFunction);
					SetEntityMoveType(Robot, MOVETYPE_NOCLIP);
					ExploAR_Robot[client]=EntIndexToEntRef(Robot);
					TeleportEntity(Robot, NULL_VECTOR, {0.0, 0.0, 0.0}, NULL_VECTOR);
					i_State[Robot]=0;
					Robot = ApplyCustomModelToWandProjectile(Robot, "models/player/items/all_class/pet_robro.mdl", 2.0, "");
					TeleportEntity(Robot, NULL_VECTOR, {0.0, 0.0, 0.0}, NULL_VECTOR);
					ClientCommand(client, "playgamesound ui/cyoa_key_minimize.wav");
					fl_Charge_delay[weapon] = 0.0;
				}
			}
			else
			{
				if(ExploAR_Charging[client]>(ExploAR_WeaponPap[client]>4 ? 31 : 39))
				{
					int target = EntRefToEntIndex(i_Target[Robot]);
					if(IsValidEnemy(client, target))
					{
						switch(i_State[Robot])
						{
							case 5:
							{
								i_State[Robot]=0;
								ExploAR_Charging[client]=0;
								i_Target[Robot] = INVALID_ENT_REFERENCE;
							}
							default:
							{
								if(fl_NextRangedAttack[Robot] < GameTime)
								{
									float RobotPos[3], vecTarget[3], vecDest[3];
									GetAbsOrigin(Robot, RobotPos);
									WorldSpaceCenter(target, vecTarget);
									vecDest = vecTarget;
									vecDest[0] += GetRandomFloat(-25.0, 25.0);
									vecDest[1] += GetRandomFloat(-25.0, 25.0);
									vecDest[2] += GetRandomFloat(-25.0, 25.0);
									int DronShot = view_as<CClotBody>(Robot).FireParticleRocket(vecDest, 0.0, 1200.0, 0.0, "raygun_projectile_red_crit", true,_, true, RobotPos);
									i_WandOwner[DronShot]=EntIndexToEntRef(client);
									i_WandWeapon[DronShot]=EntIndexToEntRef(weapon);
									f_WandDamage[DronShot]=750.0*Attributes_Get(weapon, 2, 1.0);
									WandProjectile_ApplyFunctionToEntity(DronShot, Dron_BombARTouch);	
									fl_NextRangedAttack[Robot] = GameTime + 0.2;
									i_State[Robot]++;
								}
							}
						}
					}
				}
				if(fl_JumpCooldown[weapon] < GameTime)
				{
					float Robotvec[3], Pathing[3], RobotAng[3];
					bool TooFal;
					GetAbsOrigin(Robot, Robotvec);
					WorldSpaceCenter(client, RobotAng);
					float Dist = GetVectorDistance(RobotAng, Robotvec, true);
					if(Dist > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 22.0))
						TeleportEntity(Robot, RobotAng, NULL_VECTOR, NULL_VECTOR);
					else
					{
						TooFal=(Dist > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0));
						SubtractVectors(RobotAng, Robotvec, Pathing);
						NormalizeVector(Pathing, Pathing);
						GetVectorAngles(Pathing, RobotAng);
						GetAngleVectors(RobotAng, Pathing, NULL_VECTOR, NULL_VECTOR);
						RobotAng[2]=0.0;
						RobotAng[0]=0.0;
						SetEntPropVector(Robot, Prop_Data, "m_angRotation", RobotAng);
						Robotvec[0]=Pathing[0]*(TooFal ? 300.0 : 50.0);
						Robotvec[1]=Pathing[1]*(TooFal ? 300.0 : 50.0);
						Robotvec[2]=Pathing[2]*(TooFal ? 300.0 : 50.0);
						SetEntPropVector(Robot, Prop_Data, "m_vInitialVelocity", Robotvec);
						Custom_SetAbsVelocity(Robot, Robotvec);	
						fl_JumpCooldown[weapon] = GameTime + 1.0;
					}
				}
			}
		}
		//This is Very expensive.
		/*for(int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{
				int active = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
				if(Store_IsWeaponFaction(i, active, Faction_Vesta) && !HasSpecificBuff(active, "Explosault Rifle Buff"))
				{
					ApplyStatusEffect(active, active, "Explosault Rifle Buff", 9999999.0);
					Attributes_SetMulti(active, 4013, 1.1);
				}
			}
		}*/
	}
	else
	{
		int Robot = EntRefToEntIndex(ExploAR_Robot[client]);
		if(IsValidEntity(Robot))
			RemoveEntity(Robot);
	}

	return Plugin_Continue;
}

static void ExploARWork(int client, int weapon, float GameTime)
{
	int SaveClip = GetEntProp(weapon, Prop_Send, "m_nKillComboClass");
	int clip=GetEntProp(weapon, Prop_Send, "m_iClip1");
	if(SaveClip>clip)
	{
		SetEntProp(weapon, Prop_Send, "m_nKillComboClass", clip);
	}
	else if(SaveClip<clip)
	{
		bool WhoExplode;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int npc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if (IsValidEntity(npc) && !b_NpcHasDied[npc] && GetTeam(npc) != TFTeam_Red)
			{
				if(i_HowManyBombsOnThisEntity[npc][client] > 0)
				{
					Cause_Terroriser_Explosion(client, npc, true);
					WhoExplode=true;
				}
			}
		}
		if(WhoExplode)
			EmitSoundToAll("weapons/stickybomblauncher_det.wav", client);
		SetEntProp(weapon, Prop_Send, "m_nKillComboClass", clip);
	}
	
	if(ExploAR_AirStrikeActivated[client])
	{
		int Prop = EntRefToEntIndex(ExploAR_WindowsVistaNuke[client]);
		if(IsValidEntity(Prop))
		{
			int Props;
			static float vOrigin[3];
			CClotBody XYZ = view_as<CClotBody>(Prop);
			for(int i = 1; i <= XYZ.m_iAttacksTillMegahit; i++)
			{
				switch(i)
				{
					case 1:Props = XYZ.m_iWearable1;
					case 2:Props = XYZ.m_iWearable2;
					case 3:Props = XYZ.m_iWearable3;
					case 4:Props = XYZ.m_iWearable4;
					case 5:Props = XYZ.m_iWearable5;
					case 6:Props = XYZ.m_iWearable6;
					case 7:Props = XYZ.m_iWearable7;
					case 8:Props = XYZ.m_iWearable8;
					case 9:Props = XYZ.m_iWearable9;
					default:Props = XYZ.m_iWearable9;
				}
				if(IsValidEntity(Props))
				{
					GetAbsOrigin(Props, vOrigin);
					static int color[4] = {200, 255, 50, 200};
					float Radius = fl_Dead_Ringer[Props] * 2.0;
					TE_SetupBeamRingPoint(vOrigin, Radius, Radius+0.1, g_LaserIndex, g_LaserIndex, 0, 1, 0.1, 6.0, 0.1, color, 1, 0);
					TE_SendToClient(client);
				}
			}
		}
	}
	
	if(ExploAR_HUDDelay[client] < GameTime)
	{
		char C_point_hints[512]="";
		SetGlobalTransTarget(client);
		if(ExploAR_WeaponPap[client]>3)
		{
			int Robot = EntRefToEntIndex(ExploAR_Robot[client]);
			if(!IsValidEntity(Robot))
			{
				Robot=RoundToCeil(GameTime-fl_Charge_delay[weapon]);
				Format(C_point_hints, sizeof(C_point_hints), "%t\n", "ExploAR_LostRobo", ((Robot ^ (Robot >> 31)) - (Robot >> 31)));
			}
			else if(ExploAR_AirStrikeActivated[client] && ExploAR_AirStrikeActivated[client]>64)
			{
				Format(C_point_hints, sizeof(C_point_hints),
				"%t\n", "ExploAR_BarrageMode", ExploAR_AirStrikeActivated[client]-64, ExploAR_AirStrikeActivatedMAX[client]);
			}
			else
			{
				if(ExploAR_Charging[client]<(ExploAR_WeaponPap[client]>4 ? 32 : 40))
				{
					Format(C_point_hints, sizeof(C_point_hints),
					"%t\n", "ExploAR_Capacitor", RoundToCeil((float(ExploAR_Charging[client])/(ExploAR_WeaponPap[client]>4 ? 32.0 : 40.0))*100.0));
				}
				else
				{
					Format(C_point_hints, sizeof(C_point_hints),
					"%t\n", "ExploAR_Capacitor_Max");
				}
				if(ExploAR_WeaponPap[client]>4)
				{
					if(ExploAR_Battery[client]<90)
					{
						Format(C_point_hints, sizeof(C_point_hints),
						"%s%t\n", C_point_hints, "ExploAR_BarrageEnergy", RoundToCeil((float(ExploAR_Battery[client])/90.0)*100.0));
					}
					else
					{
						Format(C_point_hints, sizeof(C_point_hints),
						"%s%t\n", C_point_hints, "ExploAR_BarrageEnergy_Max");
					}
				}
			}
		}
		
		if(ExploAR_OverHit[client]>=100)
			Format(C_point_hints, sizeof(C_point_hints),
			"%s!!! %t !!!", C_point_hints, "ExploAR_OverHeated", ExploAR_OverHit[client]);
		else if(ExploAR_OverHit[client]>80)
			Format(C_point_hints, sizeof(C_point_hints),
			"%s!! %t !!", C_point_hints, "ExploAR_OverHeated", ExploAR_OverHit[client]);
		else if(ExploAR_OverHit[client]>65)
			Format(C_point_hints, sizeof(C_point_hints),
			"%s! %t ! ", C_point_hints, "ExploAR_OverHeated", ExploAR_OverHit[client]);
		else
			Format(C_point_hints, sizeof(C_point_hints),
			"%s%t", C_point_hints, "ExploAR_OverHeated", ExploAR_OverHit[client]);
		PrintHintText(client,"%s", C_point_hints);
		ExploAR_HUDDelay[client] = GameTime + 0.5;
	}
	if(ExploAR_WeaponPap[client]>2 && ExploAR_OverHit[client]>=100)
	{
		int MaxArmor = MaxArmorCalculation(Armor_Level[client], client, 0.2);
		int Armor=Armor_Charge[client];
		if(Armor < 1)
		{
			if(dieingstate[client] > 0)
				ForcePlayerSuicide(client);
			else
			{
				float Health = float(GetClientHealth(client));
				SDKHooks_TakeDamage(client, 0, 0, (Health>125.0 ? Health/2.0: Health*3.0), DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			}
		}
		else
		{
			Armor-=MaxArmor;
			if(Armor<0)
				Armor=0;
			Armor_Charge[client]=Armor;
			f_Armor_BreakSoundDelay[client] = GetGameTime() + 5.0;	
			EmitSoundToClient(client, "npc/assassin/ball_zap1.wav", client, SNDCHAN_STATIC, 60, _, 1.0, GetRandomInt(95,105));
		}
		float position[3];
		WorldSpaceCenter(client, position);
		Explode_Logic_Custom(((float(SDKCall_GetMaxHealth(client))+125.0)*Attributes_Get(weapon, 2, 1.0)), client, client, weapon, position, _, Attributes_Get(weapon, 117, 1.0));
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(position[0]);
		pack_boom.WriteFloat(position[1]);
		pack_boom.WriteFloat(position[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		float fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = 500.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		ResetClipOfWeaponStore(weapon, client, 0);
		SetEntData(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 0);
		ExploAR_OverHit[client]=0;
	}
}

static void WindowsVistaNukeEngage(int client, int weapon)
{
	Store_RemoveSpecificItem(client, "ER Targeting Remote");
	int Prop = EntRefToEntIndex(ExploAR_WindowsVistaNuke[client]);
	if(IsValidEntity(Prop))
	{
		int Props;
		static float vOrigin[3];
		CClotBody XYZ = view_as<CClotBody>(Prop);
		for(int i = 1; i <= XYZ.m_iAttacksTillMegahit; i++)
		{
			switch(i)
			{
				case 1:Props = XYZ.m_iWearable1;
				case 2:Props = XYZ.m_iWearable2;
				case 3:Props = XYZ.m_iWearable3;
				case 4:Props = XYZ.m_iWearable4;
				case 5:Props = XYZ.m_iWearable5;
				case 6:Props = XYZ.m_iWearable6;
				case 7:Props = XYZ.m_iWearable7;
				case 8:Props = XYZ.m_iWearable8;
				case 9:Props = XYZ.m_iWearable9;
				default:Props = XYZ.m_iWearable9;
			}
			if(IsValidEntity(Props))
			{
				GetAbsOrigin(Props, vOrigin);
				if(CountPlayersOnRed(0) <= 20)
				{
					int Robot = EntRefToEntIndex(ExploAR_Robot[client]);
					if(IsValidEntity(Robot))
					{
						float SpeedReturn[3];
						int RocketGet = view_as<CClotBody>(Robot).FireRocket(vOrigin, 0.0, 650.0,_,1.5);
						SetEntProp(RocketGet, Prop_Send, "m_bCritical", true);
						ArcToLocationViaSpeedProjectile(Robot, vOrigin, SpeedReturn, 5.0, 2.0);
						float ang[3]; GetVectorAngles(SpeedReturn, ang);
						SetEntPropVector(RocketGet, Prop_Data, "m_angRotation", ang);
						TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
						SetEntityMoveType(RocketGet, MOVETYPE_NOCLIP);
						CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
					}
					vOrigin[2] += 3000.0;
					int particle = ParticleEffectAt(vOrigin, "kartimpacttrail", fl_Charge_Duration[Props]);
					SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));
					CreateTimer(fl_Charge_Duration[Props]-0.3, MortarFire_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);	
					vOrigin[2] -= 3000.0;
				}
				
				DataPack HEStrike = new DataPack();
				HEStrike.WriteCell(client);
				HEStrike.WriteCell(EntIndexToEntRef(weapon));
				HEStrike.WriteFloatArray(vOrigin, 3);
				HEStrike.WriteFloat(fl_Charge_delay[Props]);
				HEStrike.WriteFloat(GetGameTime()+fl_Charge_Duration[Props]);
				HEStrike.WriteFloat(fl_Charge_Duration[Props]);
				HEStrike.WriteFloat(fl_Dead_Ringer[Props]);
				HEStrike.WriteFloat(Attributes_Get(weapon, 117, 1.0));
				RequestFrame(HE_StrikeThink, HEStrike);
				RemovePorps(Prop);
				RemoveEntity(Props);
			}
		}
		//TeleportEntity(Props, vOrigin, NULL_VECTOR, NULL_VECTOR);
		ExploAR_AirStrikeActivated[client]--;
	}
	else ExploAR_AirStrikeActivated[client]=0;
}

static void HE_StrikeThink(DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float targetpos[3]; pack.ReadFloatArray(targetpos, 3);
	float damage = pack.ReadFloat();
	float delay = pack.ReadFloat();
	float maxdelay = pack.ReadFloat();
	float radius = pack.ReadFloat();
	float falloff = pack.ReadFloat();
	if(!IsValidClient(client) || !IsValidEntity(weapon))
		return;
	if(GetGameTime() >= delay)
	{
		ParticleEffectAt(targetpos, "rd_robot_explosion", 1.0);
		CreateEarthquake(targetpos, 0.5, radius*0.8, 16.0, 255.0);
		Explode_Logic_Custom(damage, client, client, weapon, targetpos, radius, falloff);
		EmitSoundToAll("beams/beamstart5.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, targetpos);
		return;
	}
	else
	{
		static int color[4] = {200, 255, 50, 200};
		TE_SetupBeamRingPoint(targetpos, radius * 2.0, (radius * 2.0)+0.1, g_LaserIndex, g_LaserIndex, 0, 1, 0.1, 6.0, 0.1, color, 1, 0);
		TE_SendToClient(client);
		TE_SetupBeamRingPoint(targetpos, ((radius)*((delay-GetGameTime())/maxdelay))* 2.0, (((radius)*((delay-GetGameTime())/maxdelay))* 2.0)+0.1, g_LaserIndex, g_LaserIndex, 0, 1, 0.1, 6.0, 0.1, color, 1, 0);
		TE_SendToClient(client);
	}
	delete pack;
	DataPack pack2 = new DataPack();
	pack2.WriteCell(client);
	pack2.WriteCell(EntIndexToEntRef(weapon));
	pack2.WriteFloatArray(targetpos, 3);
	pack2.WriteFloat(damage);
	pack2.WriteFloat(delay);
	pack2.WriteFloat(maxdelay);
	pack2.WriteFloat(radius);
	pack2.WriteFloat(falloff);
	float Throttle = 0.04;	//0.025
	int frames_offset = RoundToCeil(66.0*Throttle);
	if(frames_offset < 0)
		frames_offset = 1;
	RequestFrames(HE_StrikeThink, frames_offset, pack2);
}

static void Firebullet(int client, int weapon, int Overheat, int GetPap)
{
	float damage = 500.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	float speed = 3000.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	if(Overheat>64)
		damage -= (float(Overheat)/(GetPap==2 ? 130.0 : 100.0))*(damage/2.4);

	float time = 5000.0/speed;
	int Projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_blue_trail");
	
	i_AttacksTillReload[Projectile]=0;	
	static float EntLoc[3];
	GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", EntLoc);
	if(Overheat>64)
	{
		int particle = EntRefToEntIndex(i_WandParticle[Projectile]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		particle = ParticleEffectAt(EntLoc, "raygun_projectile_red_trail", time);
		SetParent(Projectile, particle);
		i_WandParticle[Projectile] = EntIndexToEntRef(particle);
	}
	int Robot = EntRefToEntIndex(ExploAR_Robot[client]);
	if(ExploAR_WeaponPap[client]>3 && IsValidEntity(Robot))
		ExploAR_Charging[client]++;
	WandProjectile_ApplyFunctionToEntity(Projectile, Gun_BombARTouch);
}

static int ExplosiveAR_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}

static void NoClipRobotFunction(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(!IsValidClient(owner)||!IsValidEntity(weapon))
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		RemoveEntity(entity);
	}
	
	if(target > 0 && target < MAXENTITIES)
		Set_HitDetectionCooldown(entity, target, FAR_FUTURE);
}

static void VentTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(target > 0 && target < MAXENTITIES)
	{
		NPC_Ignite(target, owner, 3.0, weapon);
		float vecForward[3];
		static float EntLoc[3], EntAng[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", EntLoc);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", EntAng);
		GetAngleVectors(EntAng, vecForward, NULL_VECTOR, NULL_VECTOR);
		EntAng[0] = fixAngle(EntAng[0]);
		EntAng[1] = fixAngle(EntAng[1]);
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(owner);
		ArrayList targetList = new ArrayList();
		targetList.Push(owner);
		TR_EnumerateEntitiesSphere(EntLoc, fl_Dead_Ringer_Invis[entity], PARTITION_NON_STATIC_EDICTS, CloseGetNPC, targetList);
		FinishLagCompensation_Base_boss();
		int length = targetList.Length;
		targetList.SwapAt(0, length - 1);
		targetList.Erase(--length);
		for (int i; i < length; i++)
		{
			static float targetang[3];
			
			int AoE = targetList.Get(i);
			
			float targetpos[3];
			WorldSpaceCenter(AoE, targetpos);
			GetVectorAnglesTwoPoints(EntLoc, targetpos, targetang);
			
			targetang[0] = fixAngle(targetang[0]);
			targetang[1] = fixAngle(targetang[1]);

			if(!(fabs(EntAng[0] - targetang[0]) <= 90.0 || (fabs(EntAng[0] - targetang[0]) >= (360.0-90.0))))
				continue;

			if(!(fabs(EntAng[1] - targetang[1]) <= 90.0 || (fabs(EntAng[1] - targetang[1]) >= (360.0-90.0))))
				continue;
			
			if(Can_I_See_Enemy_Only(entity, AoE) && !HasSpecificBuff(AoE, "Solid Stance"))
			{
				if(!IsIn_HitDetectionCooldown(entity,AoE))
				{
					float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
					SDKHooks_TakeDamage(AoE, owner, owner, f_WandDamage[entity]*0.25, DMG_BULLET, weapon, Dmg_Force, targetpos, _ , ZR_DAMAGE_NONE);	
				}
				if(!b_NoKnockbackFromSources[AoE])
				{
					bool Canthandlethis=false;
					float TempKnockback=5000.0;
					switch(i_NpcWeight[AoE])
					{
						case 0:
						{
							//None
						}
						case 1:TempKnockback*=0.9;
						case 2:TempKnockback*=0.75;
						case 3:TempKnockback*=0.6;
						case 4:{TempKnockback*=1.0;Canthandlethis=true;}
						default:{TempKnockback=0.0;Canthandlethis=true;}
					}
					if(TempKnockback)
					{
						targetang=EntAng;
						CClotBody npc = view_as<CClotBody>(AoE);
						if(TheNPCs.IsValidNPC(npc.GetBaseNPC()) && !npc.IsOnGround())
							TempKnockback=25.0;
						else
							targetang[0]=1.0;
						Custom_Knockback(entity, AoE, TempKnockback, true, true, true, .OverrideLookAng=targetang);
					}
					if(Canthandlethis)
					{
						float ProjectilePos[3];GetAbsOrigin(entity, ProjectilePos);
						makeexplosion(entity, ProjectilePos, 0, 0);
						Explode_Logic_Custom(f_WandDamage[entity], owner, owner, weapon, ProjectilePos, _, Attributes_Get(weapon, 117, 1.0), _, _, _, _, _, IM_ON_FIREEEEE);
						if(IsValidEntity(particle))
							RemoveEntity(particle);
						RemoveEntity(entity);
					}
				}
				Set_HitDetectionCooldown(entity,AoE, FAR_FUTURE);
			}
		}
		delete targetList;
	}
	else
	{
		float ProjectilePos[3];GetAbsOrigin(entity, ProjectilePos);
		makeexplosion(entity, ProjectilePos, 0, 0);
		Explode_Logic_Custom(f_WandDamage[entity], owner, owner, weapon, ProjectilePos, _, Attributes_Get(weapon, 117, 1.0), _, _, _, _, _, IM_ON_FIREEEEE);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		RemoveEntity(entity);
	}
	/*if(target > 0 && target < MAXENTITIES)
		return;*/
}

static void IM_ON_FIREEEEE(int entity, int victim, float damage, int weapon)
{
	NPC_Ignite(victim, entity, 3.0, weapon);
}

static void Gun_BombARTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_NONE);	// 2048 is DMG_NOGIB?

		if(!b_NpcIsInvulnerable[target])
		{
			int Robot = EntRefToEntIndex(ExploAR_Robot[owner]);
			if(IsValidEntity(Robot))
			{
				if(ExploAR_WeaponPap[owner]>3 && ExploAR_Charging[owner]>(ExploAR_WeaponPap[owner]>4 ? 31 : 39) && IsValidEnemy(owner, target))
					i_Target[Robot]=EntIndexToEntRef(target);
				if(ExploAR_WeaponPap[owner]>4)
					ExploAR_Battery[owner]++;
			}
			f_BombEntityWeaponDamageApplied[target][owner] += f_WandDamage[entity] / 12.0;
			i_HowManyBombsOnThisEntity[target][owner]+=i_AttacksTillReload[entity]+1;
			i_HowManyBombsHud[target]+=i_AttacksTillReload[entity]+1;
			Apply_Particle_Teroriser_Indicator(target);
		}
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
}

static Action Dron_BombARTouch(int entity, int target)
{
	static float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	static float Entity_Position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Entity_Position);

	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	float Attrib = 1.0;
	if(IsValidEntity(weapon))
		Attrib = Attributes_Get(weapon, 117, 1.0);
	Explode_Logic_Custom(f_WandDamage[entity], owner, owner, weapon, Entity_Position, _,Attrib);
	if(CountPlayersOnRed(0) <= 12)
		TE_Particle("mvm_soldier_shockwave", Entity_Position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = owner);
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	EmitSoundToAll("weapons/drg_pomson_drain_01.wav", entity, SNDCHAN_STATIC, 65, _, 0.65);
	RemoveEntity(entity);
	return Plugin_Handled;
}

static void CreateExploAREffect(int client)
{
	DestroyExploAREffect(client);
	if(!Items_HasNamedItem(client, "A copy of Truthful Evidence"))
		return;
	int entity = EntRefToEntIndex(i_WindowsVistaParticle_1[client]);
	if(!IsValidEntity(entity))
	{
		entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(entity))
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(entity, "eyeglow_l", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "eye_powerup_blue_lvl_3", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(entity, particle, "eyeglow_l");
			i_WindowsVistaParticle_1[client] = EntIndexToEntRef(particle);
		}
	}
}
static void DestroyExploAREffect(int client)
{
	int entity = EntRefToEntIndex(i_WindowsVistaParticle_1[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_WindowsVistaParticle_1[client] = INVALID_ENT_REFERENCE;
}

//ER_TargetingRemote
public void ERTargetingRemote_M1_Attack(int client, int weapon, bool crit, int slot)
{
	slot = EntRefToEntIndex(ExploAR_WeaponID[client]);
	int Robot = EntRefToEntIndex(ExploAR_Robot[client]);
	int Prop = EntRefToEntIndex(ExploAR_WindowsVistaNuke[client]);
	if(IsValidEntity(Prop) && IsValidEntity(Robot) && IsValidEntity(slot))
	{
		if(crit)
			StopSound(client, SNDCHAN_WEAPON, "weapon/ambassador_shoot_crit.wav");
		else
			StopSound(client, SNDCHAN_WEAPON, "weapon/ambassador_shoot.wav");
		static float vAngles[3], vOrigin[3];
		int Props;
		GetClientEyePosition(client, vOrigin);
		GetClientEyeAngles(client, vAngles);
		LaserPoint(client, vAngles, vOrigin, vOrigin);
		CClotBody XYZ = view_as<CClotBody>(Prop);
		Props = XYZ.EquipItemSeperate("models/weapons/w_models/w_drg_ball.mdl",_,1,1.001,_,true);
		SetEntityRenderMode(Props, RENDER_TRANSCOLOR);
		SetEntityRenderColor(Props, 255, 255, 255, 1);
		SetEntPropFloat(Props, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(Props, Prop_Send, "m_fadeMaxDist", 1.0);
		MakeObjectIntangeable(Props);
		fl_Charge_delay[Props] = 925.0*Attributes_Get(slot, 2, 1.0)*1.15;
		fl_Charge_Duration[Props] = 3.0/Attributes_Get(slot, 103, 1.0);
		fl_Dead_Ringer[Props] = EXPLOSION_RADIUS*Attributes_Get(slot, 99, 1.0);
		XYZ.m_iAttacksTillMegahit++;
		ExploAR_AirStrikeActivated[client]--;
		switch(XYZ.m_iAttacksTillMegahit)
		{
			case 1:XYZ.m_iWearable1 = Props;
			case 2:XYZ.m_iWearable2 = Props;
			case 3:XYZ.m_iWearable3 = Props;
			case 4:XYZ.m_iWearable4 = Props;
			case 5:XYZ.m_iWearable5 = Props;
			case 6:XYZ.m_iWearable6 = Props;
			case 7:XYZ.m_iWearable7 = Props;
			case 8:XYZ.m_iWearable8 = Props;
			case 9:XYZ.m_iWearable9 = Props;
			default:
			{
				RemovePorps(Prop);
				RemoveEntity(Prop);
				ExploAR_AirStrikeActivated[client]=0;
			}
		}
		TeleportEntity(Props, vOrigin, NULL_VECTOR, NULL_VECTOR);
		if(ExploAR_AirStrikeActivated[client]-64<=0)
		{
			WindowsVistaNukeEngage(client, slot);
			Store_RemoveSpecificItem(client, "", false, StoreWeapon[weapon]);
			TF2_RemoveItem(client, weapon);
			FakeClientCommand(client, "use tf_weapon_smg");
			ExploAR_AirStrikeActivated[client]=0;
			SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
			slot = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
			if(IsValidEntity(slot))
			{
				RemovePorps(slot);
				RemoveEntity(slot);
			}
		}
	}
	else
	{
		Store_RemoveSpecificItem(client, "", false, StoreWeapon[weapon]);
		TF2_RemoveItem(client, weapon);
		FakeClientCommand(client, "use tf_weapon_smg");
		ExploAR_AirStrikeActivated[client]=0;
	}
}

static void AddEntityToOwnerTransitMode(int client, int entity)
{
	i_OwnerEntityEnvLaser[entity] = EntIndexToEntRef(client);
	SDKHook(entity, SDKHook_SetTransmit, OwerTransmitEnvLaser);
}

static Action OwerTransmitEnvLaser(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		int owner = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);
		if(owner == client)
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

static void RemovePorps(int entity)
{
	CClotBody XYZ = view_as<CClotBody>(entity);
	int XYZ_Prop = XYZ.m_iWearable1;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable2;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable3;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable4;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable5;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable6;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable7;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable8;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
	XYZ_Prop = XYZ.m_iWearable9;
	if(IsValidEntity(XYZ_Prop))
		RemoveEntity(XYZ_Prop);
}

stock void TF2_AutoSetActiveWeapon(int client, bool NoPrimary=false, bool NoSecondary=false)
{
	int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	
	if(!NoPrimary && (primary>1 || IsValidEntity(primary)))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", primary);
	}
	else if(!NoSecondary && (secondary>1 || IsValidEntity(secondary)))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", secondary);
	}
	else if(melee>1 || IsValidEntity(melee))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", melee);
	}
}