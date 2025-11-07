#pragma semicolon 1
#pragma newdecls required

//If i see any of you using this on any bvb hale i will kill you and turn you into a kebab.
//This shit is so fucking unfair for the targeted.


#define IRENE_JUDGEMENT_MAX_HITS_NEEDED 42 	//Double the amount because we do double hits.
#define IRENE_JUDGEMENT_MAXRANGE 350.0 		
#define IRENE_JUDGEMENT_MAXRANGE_SQUARED 122500.0 		
#define IRENE_JUDGEMENT_EXPLOSION_RANGE 75.0 		

#define IRENE_BOSS_AIRTIME 0.75		
#define IRENE_AIRTIME 1.75		

#define IRENE_MAX_HITUP 10

#define IRENE_EXPLOSION_1 "mvm/giant_common/giant_common_explodes_01.wav"
#define IRENE_EXPLOSION_2 "mvm/giant_common/giant_common_explodes_02.wav"

#define IRENE_KICKUP_1 "mvm/giant_soldier/giant_soldier_rocket_shoot.wav"

Handle h_TimerIreneManagement[MAXPLAYERS+1] = {null, ...};
static float f_Irenehuddelay[MAXPLAYERS];
static int i_IreneHitsDone[MAXPLAYERS];
static bool b_WeaponAttackSpeedModifiedSeaborn[MAXENTITIES];
static int i_IreneTargetsAirborn[MAXPLAYERS][IRENE_MAX_HITUP];
static float f_TargetAirtime[MAXENTITIES];
static float f_TargetAirtimeDelayHit[MAXENTITIES];
static float f_TimeSinceLastStunHit[MAXENTITIES];
static bool b_IreneNpcWasShotUp[MAXENTITIES];
static int i_RefWeaponDelete[MAXPLAYERS];
static float f_WeaponDamageCalculated[MAXPLAYERS];
static bool b_SeabornDetected;

static int LaserSprite;

int IreneReturnLaserSprite()
{
	return LaserSprite;	
}

void Npc_OnTakeDamage_Iberia(int attacker, int damagetype)
{
	if(damagetype & DMG_CLUB) //We only count normal melee hits.
	{
		i_IreneHitsDone[attacker] += 1;
		if(i_IreneHitsDone[attacker] > IRENE_JUDGEMENT_MAX_HITS_NEEDED) //We do not go above this, no double charge.
		{
			i_IreneHitsDone[attacker] = IRENE_JUDGEMENT_MAX_HITS_NEEDED;
		}
	}
}

void SetAirtimeNpc(int entity, float Duration)
{
	f_TargetAirtime[entity] = GetGameTime() + Duration;
}
bool Npc_Is_Targeted_In_Air(int entity) //Anything that needs to be precaced like sounds or something.
{
	if(f_TargetAirtime[entity] > GetGameTime())
	{
		return true;
	}
	return false;
}

void Irene_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound(IRENE_KICKUP_1);
	PrecacheSound(IRENE_EXPLOSION_1);
	PrecacheSound(IRENE_EXPLOSION_2);

	LaserSprite = PrecacheModel(SPRITE_SPRITE, false);
}

void Reset_stats_Irene_Global()
{
	Zero(f_TimeSinceLastStunHit);
	Zero(h_TimerIreneManagement);
	Zero(f_Irenehuddelay); //Only needs to get reset on map change, not disconnect.
	Zero(i_IreneHitsDone); //This only ever gets reset on map change or player reset
	Zero(f_TargetAirtime); //what.
}

void Reset_stats_Irene_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerIreneManagement[client] != null)
	{
		delete h_TimerIreneManagement[client];
	}	
	h_TimerIreneManagement[client] = null;
	i_IreneHitsDone[client] = 0;
}

void Reset_stats_Irene_Singular_Weapon(int weapon) //This is on weapon remake. cannot set to 0 outright.
{
	b_WeaponAttackSpeedModified[weapon] = false;
	b_WeaponAttackSpeedModifiedSeaborn[weapon] = false;
	i_NextAttackDoubleHit[weapon] = 0;
}

public void Weapon_Irene_DoubleStrike(int client, int weapon, bool crit, int slot)
{
	float attackspeed = Attributes_Get(weapon, 6, 1.0);
	if(!b_WeaponAttackSpeedModified[weapon]) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
	{
		b_WeaponAttackSpeedModified[weapon] = true;
		attackspeed = (attackspeed * 0.15);
		Attributes_Set(weapon, 6, attackspeed);
	}
	else
	{
		b_WeaponAttackSpeedModified[weapon] = false;
		attackspeed = (attackspeed / 0.15);
		Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
	}

	//todo: If needed, add a delay so it doesnt happen on every swing
	bool ThereWasSeaborn = false;
	if(!StrContains(WhatDifficultySetting_Internal, "Stella & Karlas") || !StrContains(WhatDifficultySetting, "You."))
	{
		ThereWasSeaborn = true;
	}
	if(!ThereWasSeaborn)
	{
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && i_BleedType[entity] == BLEEDTYPE_SEABORN)
			{
				ThereWasSeaborn = true;
				break;
			}
		}
	}
	if(!ThereWasSeaborn)
	{
		for(int clientloop=1; clientloop<=MaxClients; clientloop++)
		{
			if(!b_IsPlayerABot[clientloop] && IsClientInGame(clientloop) && IsPlayerAlive(clientloop))
			{
				int Active_weapon = GetEntPropEnt(clientloop, Prop_Send, "m_hActiveWeapon");
				if(Active_weapon > 1)
				{
					switch(i_CustomWeaponEquipLogic[Active_weapon])
					{
						case WEAPON_SEABORNMELEE, WEAPON_SEABORN_MISC, WEAPON_OCEAN, WEAPON_OCEAN_PAP, WEAPON_SPECTER, WEAPON_GLADIIA, WEAPON_ULPIANUS, WEAPON_SKADI:
						{
							ThereWasSeaborn = true;
							break;
						}
					}
				}
			}
		}
	}

	b_SeabornDetected = ThereWasSeaborn;

	if(b_WeaponAttackSpeedModifiedSeaborn[weapon] && !ThereWasSeaborn)
	{
		attackspeed = (attackspeed / 0.85);
		Attributes_Set(weapon, 6, attackspeed);
		b_WeaponAttackSpeedModifiedSeaborn[weapon] = false;
	}
	else if(!b_WeaponAttackSpeedModifiedSeaborn[weapon] && ThereWasSeaborn)
	{
		attackspeed = (attackspeed * 0.85);
		Attributes_Set(weapon, 6, attackspeed);
		b_WeaponAttackSpeedModifiedSeaborn[weapon] = true;
	}
}

public void Enable_Irene(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerIreneManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == 6) //6 Is for Passanger
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerIreneManagement[client];
			h_TimerIreneManagement[client] = null;
			DataPack pack;
			h_TimerIreneManagement[client] = CreateDataTimer(0.1, Timer_Management_Irene, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == 6) //6 is for irene.
	{
		DataPack pack;
		h_TimerIreneManagement[client] = CreateDataTimer(0.1, Timer_Management_Irene, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_Irene(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerIreneManagement[client] = null;
		return Plugin_Stop;
	}	
	Irene_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}


public void Irene_Cooldown_Logic(int client, int weapon)
{
	if(f_Irenehuddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(b_SeabornDetected)
			{
				if(i_IreneHitsDone[client] < IRENE_JUDGEMENT_MAX_HITS_NEEDED)
				{
					PrintHintText(client,"Seaborn Detected.\nJudgement Of Iberia [%i%/%i]", i_IreneHitsDone[client], IRENE_JUDGEMENT_MAX_HITS_NEEDED);
				}
				else
				{
					PrintHintText(client,"Seaborn Detected.\nJudgement Of Iberia [READY!]");
				}
			}
			else
			{	
				if(i_IreneHitsDone[client] < IRENE_JUDGEMENT_MAX_HITS_NEEDED)
				{
					PrintHintText(client,"Judgement Of Iberia [%i%/%i]", i_IreneHitsDone[client], IRENE_JUDGEMENT_MAX_HITS_NEEDED);
				}
				else
				{
					PrintHintText(client,"Judgement Of Iberia [READY!]");
				}
			}
			
			
			f_Irenehuddelay[client] = GetGameTime() + 0.5;
		}
	}
}

public void Weapon_Irene_Judgement(int client, int weapon, bool crit, int slot)
{
	//This ability has no cooldown in itself, it just relies on hits you do.
	if(i_IreneHitsDone[client] >= IRENE_JUDGEMENT_MAX_HITS_NEEDED || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(client, weapon);
		i_IreneHitsDone[client] = 0;
		//Sucess! You have enough charges.
		//Heavy logic incomming.
		float UserLoc[3], VicLoc[3];
		GetClientAbsOrigin(client, UserLoc);


		//Attackspeed wont affect this calculation.

		float damage = 40.0;
		damage *= Attributes_Get(weapon, 2, 1.0);

		f_WeaponDamageCalculated[client] = damage;

		bool raidboss_active = false;
		if(RaidbossIgnoreBuildingsLogic(1))
		{
			raidboss_active = true;
		}
		//Reset all airborn targets.
		for (int enemy = 1; enemy < IRENE_MAX_HITUP; enemy++)
		{
			i_IreneTargetsAirborn[client][enemy] = false;
		}

		int weapon_new = Store_GiveSpecificItem(client, "Irene's Handcannon");
		if(IsValidEntity(weapon_new))
		{
			float f_AttributeSet = Attributes_Get(weapon, 180, 0.0);
			if(f_AttributeSet > 0.0)
			{
				Attributes_Set(weapon_new, 180, f_AttributeSet);
			}

			f_AttributeSet = Attributes_Get(weapon, 206, 1.0);
			if(f_AttributeSet < 1.0)
			{
				Attributes_SetMulti(weapon_new, 206, f_AttributeSet);
			}

			i_RefWeaponDelete[client] = EntIndexToEntRef(weapon_new);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon_new);

			ViewChange_Switch(client, weapon_new, "tf_weapon_revolver");
		}

		//We want to lag compensate this.
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);

		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int target = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEnemy(client, target, true, false))
			{
				WorldSpaceCenter(target, VicLoc);
				
				if (GetVectorDistance(UserLoc, VicLoc,true) <= IRENE_JUDGEMENT_MAXRANGE_SQUARED)
				{
					bool Hitlimit = true;
					for(int i=0; i < (MAX_TARGETS_HIT ); i++)
					{
						if(!i_IreneTargetsAirborn[client][i])
						{
							i_IreneTargetsAirborn[client][i] = target;
							Hitlimit = false;
							break;
						}
					}
					if(Hitlimit)
					{
						break;
					}
					if(GetGameTime() > f_TargetAirtime[target]) //Do not shoot up again once already dome.
					{
						b_IreneNpcWasShotUp[target] = true;
					}

					if (b_thisNpcIsABoss[target] || raidboss_active)
					{
						f_TankGrabbedStandStill[target] = GetGameTime() + IRENE_BOSS_AIRTIME;
						f_TargetAirtime[target] = GetGameTime() + IRENE_BOSS_AIRTIME; //Kick up for way less time.
						FreezeNpcInTime(target,IRENE_BOSS_AIRTIME);
					}
					else
					{
						f_TankGrabbedStandStill[target] = GetGameTime() + IRENE_AIRTIME;
						f_TargetAirtime[target] = GetGameTime() + IRENE_AIRTIME; //Kick up for the full skill duration.
						FreezeNpcInTime(target,IRENE_AIRTIME);
					}
					spawnRing_Vectors(VicLoc, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 6.0, 2.1, 1, IRENE_JUDGEMENT_EXPLOSION_RANGE * 0.5);	
					SDKUnhook(target, SDKHook_Think, Npc_Irene_Launch);
					if(!HasSpecificBuff(target, "Solid Stance"))
						SDKHook(target, SDKHook_Think, Npc_Irene_Launch);
					//For now, there is no limit.
				}
			}
		}
		FinishLagCompensation_Base_boss();
		EmitSoundToAll(IRENE_KICKUP_1, client, _, 75, _, 0.60);

		spawnRing(client, IRENE_JUDGEMENT_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 255, 1, 0.25, 6.0, 6.1, 1);
		spawnRing(client, IRENE_JUDGEMENT_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 255, 1, 0.17, 6.0, 6.1, 1);
		spawnRing(client, IRENE_JUDGEMENT_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 255, 1, 0.11, 6.0, 6.1, 1);
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1, IRENE_JUDGEMENT_MAXRANGE * 2.0);	
		MakePlayerGiveResponseVoice(client, 1); //haha!
		f_TargetAirtime[client] = GetGameTime() + 2.0;
		f_TargetAirtimeDelayHit[client] = GetGameTime() + 0.25;
		SDKHook(client, SDKHook_PreThink, Npc_Irene_Launch_client);
		//End of logic, everything done regarding getting all enemies effected by this effect.
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
	}
}
public void Npc_Irene_Launch_client(int client)
{
	if(GetGameTime() > f_TargetAirtime[client])
	{
		Store_RemoveSpecificItem(client, "Irene's Handcannon");
		//We are Done, kill think.
		int TemomaryGun = EntRefToEntIndex(i_RefWeaponDelete[client]);
		if(IsValidEntity(TemomaryGun))
		{
			TF2_RemoveItem(client, TemomaryGun);
			FakeClientCommand(client, "use tf_weapon_knife");
		}
		SDKUnhook(client, SDKHook_PreThink, Npc_Irene_Launch_client);
		return;
	}	
	else if(GetGameTime() > f_TargetAirtimeDelayHit[client])
	{
		int TemomaryGun = EntRefToEntIndex(i_RefWeaponDelete[client]);
		if(!IsValidEntity(TemomaryGun))
		{
			Store_RemoveSpecificItem(client, "Irene's Handcannon");
			SDKUnhook(client, SDKHook_PreThink, Npc_Irene_Launch_client);
			return;
		}
		i_ExplosiveProjectileHexArray[TemomaryGun] = EP_DEALS_CLUB_DAMAGE;

		f_TargetAirtimeDelayHit[client] = GetGameTime() + 0.15;

		//Gather all allive airborn-ed entities.
		int count;
		int targets[MAX_TARGETS_HIT];
		for(int i=0; i < (MAX_TARGETS_HIT ); i++)
		{
			// Check if it's a valid target
			if(i_IreneTargetsAirborn[client][i] && IsValidEntity(i_IreneTargetsAirborn[client][i]) && !b_NpcHasDied[i_IreneTargetsAirborn[client][i]])
			{
				// Add it to our list, increase count by 1
				targets[count++] = i_IreneTargetsAirborn[client][i];
			}
		}
		
		//All have died, we now shoot random stuff instead.
		if(!count)
		{
			float UserLoc[3], VicLoc[3];
			GetClientAbsOrigin(client, UserLoc);
			//We want to lag compensate this.
			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);	

			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int enemy = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEnemy(client, enemy, true, false))
				{
					WorldSpaceCenter(enemy, VicLoc);
					
					if (GetVectorDistance(UserLoc, VicLoc,true) <= IRENE_JUDGEMENT_MAXRANGE_SQUARED) //respect max range.
					{
						if(count < MAX_TARGETS_HIT)
						{
							targets[count++] = enemy;
						}
						else
						{
							break;
						}
					}
				}
			}
			FinishLagCompensation_Base_boss();
		}

		if(count)
		{
			// Choosen a random one in our list
			int target = targets[GetRandomInt(0, count - 1)];

			float VicLoc[3];

			//poisition of the enemy we random decide to shoot.
			WorldSpaceCenter(target, VicLoc);

			LookAtTarget(client, target);

			//This can hit upto 10 targets in range.
			//We dont do more otherwise it will be super god damn op.
			//Damage will be multiplied by 2 because it can double hit, and 50% more extra because its an ability.
			float damage = (f_WeaponDamageCalculated[client] * 3.0);

			damage *= 1.1; //Abit extra.
			
			CClotBody npc = view_as<CClotBody>(target);
			if(!npc.IsOnGround())
			{
				damage *= 1.5; //if the enemy is in the air, then we will do 50% more damage. This will apply to any surrounding targets too beacuse im lazy.
			}

			SpawnSmallExplosion(VicLoc);
			//Reuse terroriser stuff for now.
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					EmitSoundToAll(IRENE_EXPLOSION_1, target, _, 85, _, 0.5);
				}
				case 2:
				{
					EmitSoundToAll(IRENE_EXPLOSION_2, target, _, 85, _, 0.5);
				}
			}

			//Cause a bunch of effects on the targeted enemy.

			int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 255;
			color[3] = 255;
			float amp = 0.3;
			float life = 0.1;			
			float GunPos[3];
			float GunAng[3];
			GetAttachment(client, "effect_hand_R", GunPos, GunAng);
			TE_Particle("wrenchmotron_teleport_glow_big", GunPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_SetupBeamPoints(GunPos, VicLoc, LaserSprite, 0, 0, 0, life, 1.0, 1.2, 1, amp, color, 0);
			TE_SendToAll();

			spawnRing_Vectors(VicLoc, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1, IRENE_JUDGEMENT_EXPLOSION_RANGE);	
			Explode_Logic_Custom(damage, client, TemomaryGun, TemomaryGun, VicLoc, IRENE_JUDGEMENT_EXPLOSION_RANGE,_,_,false);
		}
		else
		{
			//Do nothing. Just look into random directions?
		}
	}
}

public void Npc_Irene_Launch(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	//Do their fly logic.

	if(b_IreneNpcWasShotUp[iNPC])
	{
		float VicLoc[3];
		WorldSpaceCenter(iNPC, VicLoc);
		VicLoc[2] += 250.0; //Jump up.
		PluginBot_Jump(iNPC, VicLoc);
	}
	b_IreneNpcWasShotUp[iNPC] = false;
	
	bool raidboss_active = false;
	float time_stay_In_sky;
	if(RaidbossIgnoreBuildingsLogic(1))
	{
		raidboss_active = true;
	}
	if (b_thisNpcIsABoss[iNPC] || raidboss_active)
	{
		time_stay_In_sky = 0.55;
	}
	else
	{
		time_stay_In_sky = 1.55;
	}

	if(GetGameTime() > f_TargetAirtime[iNPC])
	{
		//We are Done, kill think.
		SDKUnhook(iNPC, SDKHook_Think, Npc_Irene_Launch);
	}	
	else if(GetGameTime() + time_stay_In_sky > f_TargetAirtime[iNPC])
	{
		//After 0.5 seconds they stop accending to heaven, we also reset their velocity ontop of resetting their gravtiy
		npc.SetVelocity({ 0.0, 0.0, 0.0 });
	}
}