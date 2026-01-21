#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerExploARWeaponManagement[MAXPLAYERS] = {null, ...};

static int i_VictoriaParticle_1[MAXPLAYERS];
static int ExploAR_ZoomLaser[MAXPLAYERS];
static int ExploAR_VictoriaNuke[MAXPLAYERS];

static int ExploAR_AirStrikeActivated[MAXPLAYERS];
static int ExploAR_AirStrikeActivatedMAX[MAXPLAYERS];

static int ExploAR_WeaponPap[MAXPLAYERS+1] = {0, ...};
static int ExploAR_WeaponID[MAXPLAYERS];
static int ExploAR_BurstNum[MAXPLAYERS];
static int ExploAR_OverHit[MAXPLAYERS];
static int ExploAR_Charging[MAXPLAYERS];

static float ExploAR_OverHeatDelay[MAXPLAYERS];
static float ExploAR_HUDDelay[MAXPLAYERS];
static bool Can_I_Fire[MAXPLAYERS] = {false, ...};
static bool IsDeploy[MAXPLAYERS] = {false, ...};
static bool Zoom_Active[MAXPLAYERS] = {false, ...};

static int g_LaserIndex;

void ResetMapStartExploARWeapon()
{
	PrecacheSound("weapons/stickybomblauncher_det.wav");
	PrecacheSound("weapons/flare_detonator_launch.wav");
	PrecacheSound("weapons/gunslinger_three_hit.wav");
	PrecacheSound("beams/beamstart5.wav");
	PrecacheModel("models/props_farm/vent001.mdl");
	PrecacheModel("models/weapons/w_models/w_drg_ball.mdl");
	g_LaserIndex = PrecacheModel(LASERBEAM);
	Zero(Can_I_Fire);
	Zero(ExploAR_OverHit);
	Zero(ExploAR_HUDDelay);
	Zero(ExploAR_OverHeatDelay);
	Zero(ExploAR_Charging);
	Zero(ExploAR_AirStrikeActivated);
	Zero(ExploAR_AirStrikeActivatedMAX);
}

public void BombAR_M1_Attack(int client, int weapon, bool crit, int slot)
{
	if(ExploAR_AirStrikeActivated[client]>64)
	{
		VictoriaNukeSetUp(client, weapon);
		return;
	}

	ExploAR_OverHit[client]+=2;
	switch(ExploAR_WeaponPap[client])
	{
		case 2:{if(ExploAR_OverHit[client]>150)ExploAR_OverHit[client]=150;ExploAR_OverHit[client]++;}
		case 3, 4:
		{
			if(ExploAR_OverHit[client]>100)ExploAR_OverHit[client]=100;
			if(Zoom_Active[client])
			{
				ExploAR_OverHit[client]+=ExploAR_Charging[client];
				int GetClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
				if(!GetClip || GetClip < 3)
					return;
			}
		}
		default:{if(ExploAR_OverHit[client]>100)ExploAR_OverHit[client]=100;}
	}
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
			if(GetEntProp(weapon, Prop_Send, "m_nKillComboCount") && Zoom_Active[client])
			{
				SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", gameTime + ((burstRate * 2.5) * attackTime));
				SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			}
			else if(GetEntProp(weapon, Prop_Send, "m_nKillComboCount")>=ExploAR_BurstNum[client])
			{
				SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", gameTime + (burstRate * attackTime));
				SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			}
		}
		else
		{
			SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", gameTime + ((burstRate * (Zoom_Active[client] ? 0.5 : 1.0)) * attackTime));
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

public void BombAR_Zoom_n_Laser(int client, int weapon, bool crit, int slot)
{
	Weapon_Railcannon_Pap2_Zoom(client, -1, false, -1);
	SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
	if(Zoom_Active[client] == false)
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
			Attributes_Set(weapon, 298, (ExploAR_AirStrikeActivated[client] ? 1.0 : 3.0));
			Zoom_Active[client] = true;
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
		Zoom_Active[client] = false;
		Attributes_Set(weapon, 298, 1.0);
	}
}

static void BombAR_Laser_PreThink(int client)
{
	int weapon = EntRefToEntIndex(ExploAR_WeaponID[client]);
	int Prop = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
	if(Zoom_Active[client] && h_TimerExploARWeaponManagement[client] != null && IsValidEntity(weapon) && IsValidEntity(Prop))
	{
		Attributes_Set(weapon, 298, (ExploAR_AirStrikeActivated[client] ? 1.0 : 3.0));
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
			//b_Anger[Projectile]=false;
			if(ExploAR_WeaponPap[client]==2)
				b_Anger[Projectile]=true;
				//b_angered_twice[Projectile]=true;
			fl_Dead_Ringer_Invis[Projectile]=range;
			WandProjectile_ApplyFunctionToEntity(Projectile, VentTouch);
			/*DataPack pack = new DataPack();
			pack.WriteCell(EntIndexToEntRef(Projectile));
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteCell(GetClientUserId(client));
			pack.WriteFloat(damage/2.0);
			RequestFrame(Timer_Pushback, pack);*/
			
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

/*static void Timer_Pushback(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int owner = GetClientOfUserId(pack.ReadCell());
	float damage = pack.ReadFloat();
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(!IsValidEntity(owner))
			return;
		static float EntLoc[3], EntAng[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", EntLoc);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", EntAng);
		//Explode_Logic_Custom(0.0, entity, entity, weapon, EntLoc, _, _, _, _, _, _, _, CloseGetNPC);

		float vecForward[3];
		GetAngleVectors(EntAng, vecForward, NULL_VECTOR, NULL_VECTOR);
		EntAng[0] = fixAngle(EntAng[0]);
		EntAng[1] = fixAngle(EntAng[1]);
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(owner);
		ArrayList targetList = new ArrayList();
		targetList.Push(owner);
		TR_EnumerateEntitiesSphere(EntLoc, 250.0, PARTITION_NON_STATIC_EDICTS, CloseGetNPC, targetList);
		FinishLagCompensation_Base_boss();
		int length = targetList.Length;
		targetList.SwapAt(0, length - 1);
		targetList.Erase(--length);
		for (int i; i < length; i++)
		{
			static float targetang[3];
			
			int target = targetList.Get(i);
			
			float targetpos[3];
			WorldSpaceCenter(target, targetpos);
			GetVectorAnglesTwoPoints(EntLoc, targetpos, targetang);
			
			targetang[0] = fixAngle(targetang[0]);
			targetang[1] = fixAngle(targetang[1]);

			if(!(fabs(EntAng[0] - targetang[0]) <= 90.0 || (fabs(EntAng[0] - targetang[0]) >= (360.0-90.0))))
				continue;

			if(!(fabs(EntAng[1] - targetang[1]) <= 90.0 || (fabs(EntAng[1] - targetang[1]) >= (360.0-90.0))))
				continue;
			
			if(Can_I_See_Enemy_Only(entity, target))
			{
				if(!b_Anger[entity]||b_angered_twice[entity])
				{
					if(b_angered_twice[entity])
					{
						damage/=2.0;
						NPC_Ignite(target, owner, 3.0, weapon);
					}
					float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
					SDKHooks_TakeDamage(target, owner, owner, damage, DMG_CLUB, weapon, damage_force, targetpos);
					b_Anger[entity]=true;
				}
				if(!HasSpecificBuff(target, "Solid Stance"))
				{
					float TempKnockback=10000.0;
					targetang=EntAng;
					CClotBody npc = view_as<CClotBody>(target);
					if(TheNPCs.IsValidNPC(npc.GetBaseNPC()) && !npc.IsOnGround())
						TempKnockback=25.0;
					else
						targetang[0]=1.0;
					Custom_Knockback(entity, target, TempKnockback, true, true, true, .OverrideLookAng=targetang);
				}
			}
		}
		delete targetList;
		
		delete pack;
		DataPack pack2 = new DataPack();
		pack2.WriteCell(EntIndexToEntRef(entity));
		pack2.WriteCell(EntIndexToEntRef(weapon));
		pack2.WriteCell(GetClientUserId(owner));
		pack2.WriteFloat(damage);
		float Throttle = 0.04;
		int frames_offset = RoundToCeil(66.0*Throttle);
		if(frames_offset < 0)
			frames_offset = 1;
		RequestFrames(Timer_Pushback, frames_offset, pack2);
	}
	return;
}*/

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
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 50.0);
			int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
			int GetClip=GetEntData(weapon, iAmmoTable, 4);
			SetAmmo(client, 18, SMGAmmo+GetClip-SMGAmmoMAX);
			SetEntData(weapon, iAmmoTable, SMGAmmoMAX);
			ExploAR_AirStrikeActivated[client]=SMGAmmoMAX+64;
			ExploAR_AirStrikeActivatedMAX[client]=SMGAmmoMAX;
			SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", GetGameTime() + 1.0);
			SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			SetEntProp(weapon, Prop_Send, "m_nKillComboClass", SMGAmmoMAX);
			Can_I_Fire[client]=false;
			SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
			int Prop = EntRefToEntIndex(ExploAR_VictoriaNuke[client]);
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
				
				ExploAR_VictoriaNuke[client]=EntIndexToEntRef(Prop);
				SetVariantString("1.5");
				AcceptEntityInput(Prop, "SetModelScale");
				SetEntPropEnt(Prop, Prop_Data, "m_hOwnerEntity", client);
				SetEntityRenderMode(Prop, RENDER_TRANSCOLOR);
				SetEntityRenderColor(Prop, 255, 255, 255, 1);
				SetEntPropFloat(Prop, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(Prop, Prop_Send, "m_fadeMaxDist", 1.0);
				SetParent(client, Prop);
			}
			Attributes_Set(weapon, 303, 0.04/ClipAttributes);//Only One
		}
	}
}

public void Enable_ExploARWeapon(int client, int weapon)
{
	if(h_TimerExploARWeaponManagement[client] != null)
	{
		ExploAR_WeaponPap[client] = ExplosiveAR_Get_Pap(weapon);
		ExploAR_BurstNum[client] = RoundToCeil(Attributes_Get(weapon, 401, 1.0));
		Can_I_Fire[client]=false;
		ExploAR_AirStrikeActivated[client]=0;
		ExploAR_WeaponID[client]=EntIndexToEntRef(weapon);
		delete h_TimerExploARWeaponManagement[client];
		h_TimerExploARWeaponManagement[client] = null;
		DataPack pack;
		h_TimerExploARWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ExploAR, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
	else
	{
		ExploAR_WeaponPap[client] = ExplosiveAR_Get_Pap(weapon);
		ExploAR_BurstNum[client] = RoundToCeil(Attributes_Get(weapon, 401, 1.0));
		Can_I_Fire[client]=false;
		ExploAR_AirStrikeActivated[client]=0;
		ExploAR_WeaponID[client]=EntIndexToEntRef(weapon);
		DataPack pack;
		h_TimerExploARWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ExploAR, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public void Deploy_ExploARWeapon(int client, int weapon)
{
	CreateExploAREffect(client);
	IsDeploy[client]=true;
	if(Store_IsWeaponFaction(client, weapon, Faction_Victoria))	// Victoria
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
public void Holster_ExploARWeapon(int client)
{
	if(ExploAR_WeaponPap[client]>2)
	{
		SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
		int Prop = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
		if(IsValidEntity(Prop))
		{
			RemovePorps(Prop);
			RemoveEntity(Prop);
		}
		Zoom_Active[client] = false;
		Weapon_Railcannon_Pap2_Holster(client, -1, false, -1);
	}
	if(ExploAR_AirStrikeActivated[client])
	{
		int Prop = EntRefToEntIndex(ExploAR_VictoriaNuke[client]);
		if(IsValidEntity(Prop))
		{
			RemovePorps(Prop);
			RemoveEntity(Prop);
		}
		ExploAR_AirStrikeActivated[client]=0;
	}

	IsDeploy[client]=false;
	DestroyExploAREffect(client);
}

static Action Timer_Management_ExploAR(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerExploARWeaponManagement[client] = null;
		SDKUnhook(client, SDKHook_PreThink, BombAR_Laser_PreThink);
		SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
		return Plugin_Stop;
	}	
	float GameTime = GetGameTime();
	if(ExploAR_OverHeatDelay[client] < GameTime)
	{
		ExploAR_OverHit[client]-=4;
		if(ExploAR_OverHit[client]<0)ExploAR_OverHit[client]=0;
	}
	
	if(IsDeploy[client])
		ExploARWork(client, weapon, GameTime);

	return Plugin_Continue;
}

static void ExploARWork(int client, int weapon, float GameTime)
{
	int SaveClip = GetEntProp(weapon, Prop_Send, "m_nKillComboClass");
	int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
	if(SaveClip>clip)
	{
		SetEntProp(weapon, Prop_Send, "m_nKillComboClass", clip);
	}
	else if(SaveClip<clip)
	{
		if(ExploAR_AirStrikeActivated[client])
		{
			VictoriaNukeEngage(client, weapon);
			ExploAR_AirStrikeActivated[client]=0;
		}
		else
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
		}
		SetEntProp(weapon, Prop_Send, "m_nKillComboClass", clip);
	}
	
	if(ExploAR_AirStrikeActivated[client])
	{
		int Prop = EntRefToEntIndex(ExploAR_VictoriaNuke[client]);
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
		if(ExploAR_WeaponPap[client]>2)
		{
			if(ExploAR_AirStrikeActivated[client] && ExploAR_AirStrikeActivated[client]>64)
			{
				Format(C_point_hints, sizeof(C_point_hints),
				"%t\n", "ExploAR_BarrageMode", ExploAR_AirStrikeActivated[client]-64, ExploAR_AirStrikeActivatedMAX[client]);
			}
			else if(Zoom_Active[client])
			{
				if(ExploAR_Charging[client]<20)
				{
					ExploAR_Charging[client]++;
					if(ExploAR_Charging[client]==20)
					{
						ClientCommand(client, "playgamesound \"player/recharged.wav\"");
						ExploAR_Charging[client]=21;
					}
					Format(C_point_hints, sizeof(C_point_hints),
					"%t\n", "ExploAR_FocusMode", RoundToCeil((float(ExploAR_Charging[client])/21.0)*100.0));
				}
				else
					Format(C_point_hints, sizeof(C_point_hints),
					"%t\n", "ExploAR_FocusMode_Max");
				int LaserPointent = EntRefToEntIndex(ExploAR_ZoomLaser[client]);
				if(IsValidEntity(LaserPointent))
				{
					int laser = view_as<CClotBody>(LaserPointent).m_iWearable1;
					if(IsValidEntity(laser))
						SetEntityRenderColor(laser, RoundToCeil((float(ExploAR_Charging[client])/21.0)*50.0), 0, 0, 255);
				}
			}
			else
				Format(C_point_hints, sizeof(C_point_hints),
				"%t\n", "ExploAR_RapidMode");
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
			
		if(ExploAR_WeaponPap[client]>2)
		{
		
		
		}
		PrintHintText(client,"%s", C_point_hints);
		ExploAR_HUDDelay[client] = GameTime + 0.5;
	}
	if(ExploAR_OverHit[client]>65)
	{
		/*int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				GetAttachment(entity, "effect_hand_R", flPos, NULL_VECTOR);
				int particle = ParticleEffectAt(flPos, "drg_pipe_smoke", 0.0);
				AddEntityToThirdPersonTransitMode(client, particle);
				SetParent(entity, particle, "effect_hand_R");
				i_VictoriaParticle[client] = EntIndexToEntRef(particle);
			}
		}*/
	}
	else
	{
		/*int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;*/
	}
}

static void VictoriaNukeSetUp(int client, int weapon)
{
	int Prop = EntRefToEntIndex(ExploAR_VictoriaNuke[client]);
	if(IsValidEntity(Prop))
	{
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
		fl_Charge_delay[Props] = 750.0*Attributes_Get(weapon, 2, 1.0)*1.15;
		fl_Charge_Duration[Props] = 3.0/Attributes_Get(weapon, 103, 1.0);
		fl_Dead_Ringer[Props] = EXPLOSION_RADIUS*Attributes_Get(weapon, 99, 1.0);
		XYZ.m_iAttacksTillMegahit++;
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
		ExploAR_AirStrikeActivated[client]--;
		SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
	}
	else
	{
		RemovePorps(Prop);
		RemoveEntity(Prop);
		ExploAR_AirStrikeActivated[client]=0;
	}
}

static void VictoriaNukeEngage(int client, int weapon)
{
	int Prop = EntRefToEntIndex(ExploAR_VictoriaNuke[client]);
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
				RemoveEntity(Props);
			}
		}
		TeleportEntity(Props, vOrigin, NULL_VECTOR, NULL_VECTOR);
		ExploAR_AirStrikeActivated[client]--;
	}
	else
	{
		RemovePorps(Prop);
		RemoveEntity(Prop);
		ExploAR_AirStrikeActivated[client]=0;
	}
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
	float speed = 3500.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	if(Overheat<90 && GetPap>2 && Zoom_Active[client])
	{
		float TempBuff = (float(ExploAR_Charging[client])/21.0)*6.0;
		if(TempBuff<1.0)TempBuff=1.0;
		damage *= TempBuff;
	}
	if(Overheat>64)
		damage -= (float(Overheat)/(GetPap==2 ? 130.0 : 100.0))*(damage/2.0);

	float time = 5000.0/speed;
	int Projectile;
	if(Overheat>64)
		Projectile=Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_red_trail");
	else
		Projectile=Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "raygun_projectile_blue_trail");
	
	i_AttacksTillReload[Projectile]=0;
	if(GetPap>2 && Zoom_Active[client])
	{
		i_AttacksTillReload[Projectile]=RoundToCeil((float(ExploAR_Charging[client])/21.0)*7.0);
		static float EntLoc[3];
		GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", EntLoc);
		int particle = EntRefToEntIndex(i_WandParticle[Projectile]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		if(ExploAR_Charging[client]>=20)
			particle = ParticleEffectAt(EntLoc, "raygun_projectile_blue_crit", time);
		else
			particle = ParticleEffectAt(EntLoc, "raygun_projectile_blue", time);
		SetParent(Projectile, particle);
		i_WandParticle[Projectile] = EntIndexToEntRef(particle);
	}
	
	WandProjectile_ApplyFunctionToEntity(Projectile, Gun_BombARTouch);
}

static int ExplosiveAR_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
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
					SDKHooks_TakeDamage(AoE, owner, owner, f_WandDamage[entity]*0.25, DMG_BULLET, weapon, Dmg_Force, targetpos, _ , ZR_DAMAGE_LASER_NO_BLAST);	
				}
				if(!b_NoKnockbackFromSources[AoE])
				{
					bool Canthandlethis=false;
					float TempKnockback=3000.0;
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
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?

		if(!b_NpcIsInvulnerable[target])
		{
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

static void CreateExploAREffect(int client)
{
	DestroyExploAREffect(client);
	if(!Items_HasNamedItem(client, "A copy of Truthful Evidence"))
		return;
	int entity = EntRefToEntIndex(i_VictoriaParticle_1[client]);
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
			i_VictoriaParticle_1[client] = EntIndexToEntRef(particle);
		}
	}
}
static void DestroyExploAREffect(int client)
{
	int entity = EntRefToEntIndex(i_VictoriaParticle_1[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_VictoriaParticle_1[client] = INVALID_ENT_REFERENCE;
}

static void SniperLaserSpawn(int ent)
{
	int client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(IsValidClient(client))
	{
		CClotBody npc = view_as<CClotBody>(ent);
		float flPos[3];
		int eyelevel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(eyelevel))
		{
			GetAttachment(eyelevel, "eyeglow_l", flPos, NULL_VECTOR);
			npc.m_iWearable2 = npc.EquipItemSeperate("models/weapons/w_models/w_drg_ball.mdl",_,1,1.001,_,true);
			SetParent(eyelevel, npc.m_iWearable2, "eyeglow_l");
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
			MakeObjectIntangeable(npc.m_iWearable2);
		}
		int laser = ConnectWithBeam(npc.m_iWearable2, ent, 1, 0, 0, 3.0, 0.1, 0.0, LASERBEAM);
		AddEntityToOwnerTransitMode(client, laser);
		npc.m_iWearable1 = laser;
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