#define SAGA_ABILITY_1	"npc/waste_scanner/grenade_fire.wav"
#define SAGA_ABILITY_2	"npc/waste_scanner/grenade_fire.wav"
#define SAGA_ABILITY_3	"npc/waste_scanner/grenade_fire.wav"

//NA GO GOHOM
static Handle WeaponTimer[MAXPLAYERS];
static int WeaponRef[MAXPLAYERS];
static int WeaponCharge[MAXPLAYERS];
static float SagaCrippled[MAXENTITIES + 1];
static int SagaCrippler[MAXENTITIES + 1];
static bool SagaRegen[MAXENTITIES];

static const char g_MeleeHitSounds[][] =
{
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};

void Saga_MapStart()
{
	PrecacheSound(SAGA_ABILITY_1);
	PrecacheSound(SAGA_ABILITY_2);
	PrecacheSound(SAGA_ABILITY_3);
	Zero(SagaCrippled);
	Zero(WeaponCharge);
	Zero(SagaRegen);
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
}

void Saga_EntityCreated(int entity)
{
	SagaCrippled[entity] = 0.0;
	SagaCrippler[entity] = 0;
}

bool Saga_EnemyDoomed(int entity)
{
	return view_as<bool>(SagaCrippled[entity]);
}

int Saga_EnemyDoomedBy(int entity)
{
	return SagaCrippler[entity];
}

bool Saga_RegenHealth(int entity)
{
	return SagaRegen[entity];
}

void Saga_DeadEffects(int victim, int attacker, int weapon)
{
	if(SagaCrippled[victim])
		Saga_ChargeReduction(attacker, weapon, SagaCrippled[victim]);
}

public bool Saga_ChargeValidityFunction(int provider, int entity)
{
	if(entity <= MaxClients)
	{
		int i, weapon;
		while(TF2_GetItem(entity, weapon, i))
		{
			if(Saga_IsChargeWeapon(entity, weapon))
				return true;
		}
	}

	return false;
}

bool Saga_IsChargeWeapon(int client, int weapon)
{
	if(!IsValidEntity(weapon))
		return false;

	//if(f_UberOnHitWeapon[weapon] > 0.01)
	//	return true;
	
	if(Passanger_HasCharge(client))
		return true;
	
	if(Gladiia_HasCharge(client, weapon))
		return true;
	
	if(WeaponTimer[client] && EntRefToEntIndex(WeaponRef[client]) == weapon)
		return true;
	
	for(int i = 1; i < 4; i++)
	{
		float cooldown = Ability_Check_Cooldown(client, i, weapon);
		if(cooldown > 0.0)
			return true;
	}

	return false;
}

void Saga_ChargeReduction(int client, int weapon, float time)
{
	Passanger_ChargeReduced(client, time);
	Gladiia_ChargeReduction(client, weapon, time);

	if(WeaponTimer[client] && EntRefToEntIndex(WeaponRef[client]) == weapon)
	{
		WeaponCharge[client] += Int_CooldownReductionDo(client, RoundToNearest(time)) + 1;
		TriggerTimer(WeaponTimer[client], false);
	}
	
	for(int i = 1; i < 4; i++)
	{
		float cooldown = Ability_Check_Cooldown(client, i, weapon);
		if(cooldown > 0.0)
		{
			Ability_Apply_Cooldown(client, i, cooldown - time, weapon, true);
			break;
		}
	}
}

void Saga_Enable(int client, int weapon)
{
	SagaRegen[client] = false;

	if(i_CustomWeaponEquipLogic[weapon] == 19)
	{
		WeaponRef[client] = EntIndexToEntRef(weapon);
		delete WeaponTimer[client];

		float value = Attributes_Get(weapon, 868, -1.0);
		if(value == -1.0)
		{
			// Elite 0 Special 1
			WeaponTimer[client] = CreateTimer(3.5 / ResourceRegenMulti, Saga_Timer1, client, TIMER_REPEAT);
		}
		else if(value == 0.0)
		{
			// Elite 1 Special 2
			WeaponTimer[client] = CreateTimer(1.0, Saga_Timer2, client, TIMER_REPEAT);
		}
		else
		{
			// Elite 1 Special 3
			WeaponTimer[client] = CreateTimer(1.0, Saga_Timer3, client, TIMER_REPEAT);
		}
	}
}

public Action Saga_Timer1(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(!Waves_InSetup() && weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") && AllowMaxCashgainWaveCustom(client))
			{
				int amount = 2;
				/*
				 + (WeaponCharge[client] * 7 / 2);

				if(amount > 1)
					WeaponCharge[client] -= amount + 1;
				
				if(amount < 0)
					amount = 1; //dont give shit.
				*/
				
				CashRecievedNonWave[client] += amount;
				CashSpent[client] -= amount;
				AddCustomCashMadeThisWave(client, amount);
			}
			
			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public Action Saga_Timer2(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				if(++WeaponCharge[client] > Int_CooldownReductionDo(client, 32))
					WeaponCharge[client] = Int_CooldownReductionDo(client, 32);
				
				int ValueCD = Int_CooldownReductionDo(client, 16);
				PrintHintText(client, "Cleansing Evil [%d / 2] {%ds}", WeaponCharge[client] / ValueCD, ValueCD - (WeaponCharge[client] % ValueCD));
				
			}

			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public Action Saga_Timer3(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				SagaRegen[client] = true;
				if(++WeaponCharge[client] > Int_CooldownReductionDo(client, 39))
					WeaponCharge[client] = Int_CooldownReductionDo(client, 39);
				
				int ValueCD = Int_CooldownReductionDo(client, 13);
				PrintHintText(client, "Cleansing Evil [%d / 3] {%ds}", WeaponCharge[client] / ValueCD, ValueCD - (WeaponCharge[client] % ValueCD));
				
			}
			else
			{
				SagaRegen[client] = false;
			}

			return Plugin_Continue;
		}
	}

	SagaRegen[client] = false;
	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_SagaE1_M2(int client, int weapon, bool crit, int slot)
{
	Weapon_Saga_M2(client, weapon, false);
}

public void Weapon_SagaE2_M2(int client, int weapon, bool crit, int slot)
{
	Weapon_Saga_M2(client, weapon, true);
}

static void Weapon_Saga_M2(int client, int weapon, bool mastery)
{
	int cost = mastery ? 13 : 16;
	cost = Int_CooldownReductionDo(client, cost);
	if(CvarInfiniteCash.BoolValue)
	{
		WeaponCharge[client] = 999;
	}
	if(WeaponCharge[client] < cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", float(cost - WeaponCharge[client]));
	}
	else
	{
		Rogue_OnAbilityUse(client, weapon);
		MakePlayerGiveResponseVoice(client, 4); //haha!
		WeaponCharge[client] -= cost;

		//cus we call the timer
		WeaponCharge[client] -= 1;
		if(!Waves_InSetup() && AllowMaxCashgainWaveCustom(client))
		{
			int cash = RoundFloat(6.0 * ResourceRegenMulti);
			CashRecievedNonWave[client] += cash;
			CashSpent[client] -= cash;
			AddCustomCashMadeThisWave(client, cash);
		}
		
		float damage = mastery ? 260.0 : 208.0;	// 400%, 320%
		damage *= Attributes_Get(weapon, 2, 1.0);
		
		int value = i_ExplosiveProjectileHexArray[client];
		i_ExplosiveProjectileHexArray[client] = EP_DEALS_CLUB_DAMAGE;

		float UserLoc[3];
		GetClientAbsOrigin(client, UserLoc);

		float Range = 400.0;
		spawnRing_Vectors(UserLoc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.25, 12.0, 6.1, 1, Range * 2.0);	
		spawnRing_Vectors(UserLoc, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.25, 12.0, 6.1, 1, 0.0);	
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);				
		Explode_Logic_Custom(damage, client, client, weapon, _, Range, _, _, false, 6,_,_,SagaCutFirst);
		FinishLagCompensation_Base_boss();
		
		i_ExplosiveProjectileHexArray[client] = value;
		TF2_AddCondition(client, TFCond_DefenseBuffed, 1.0);

		CreateTimer(0.2, Saga_DelayedExplode, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

		int rand = GetURandomInt() % 3;
		EmitSoundToAll(rand == 0 ? SAGA_ABILITY_1 : (rand == 1 ? SAGA_ABILITY_2 : SAGA_ABILITY_3), client, SNDCHAN_AUTO, 75,_,0.6);

		TriggerTimer(WeaponTimer[client], true);
	}
}

public Action Saga_DelayedExplode(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			float damage = 0.1;
			damage *= Attributes_Get(weapon, 2, 1.0);
			
			int value = i_ExplosiveProjectileHexArray[client];
			i_ExplosiveProjectileHexArray[client] = EP_DEALS_CLUB_DAMAGE;

			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);						
			Explode_Logic_Custom(damage, client, client, weapon, _, 400.0, _, _, false, 99,_,_,SagaCutLast);
			FinishLagCompensation_Base_boss();			
			i_ExplosiveProjectileHexArray[client] = value;
		}
	}
	return Plugin_Continue;
}

void Saga_OnTakeDamage(int victim, int &attacker, float &damage, int &weapon, int damagetype)
{
	if(damagetype & DMG_TRUEDAMAGE)
	{
		return;
	}
	if(SagaCrippled[victim])
	{
		damage = 0.0;
	}
	else if(RoundToFloor(damage) >= GetEntProp(victim, Prop_Data, "m_iHealth"))
	{
		damage = float(GetEntProp(victim, Prop_Data, "m_iHealth") - 1);

		SagaCrippler[victim] = attacker;
		SagaCrippled[victim] = Attributes_Get(weapon, 868, -1.0) == -1.0 ? 1.0 : 2.0;
		CreateTimer(10.0, Saga_ExcuteTarget, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		FreezeNpcInTime(victim, 10.2);
		SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
		SetEntityRenderColor(victim, 255, 65, 65, 125);
		b_ThisEntityIgnoredByOtherNpcsAggro[victim] = true;
		//counts as a static npc, means it wont count towards NPC limit.
		//thisd is so they dont hog.
		AddNpcToAliveList(victim, 1);

		SetEntityCollisionGroup(victim, 17);
		b_DoNotUnStuck[victim] = true;
		CClotBody npc = view_as<CClotBody>(victim);
		Npc_DebuffWorldTextUpdate(npc);
		Attributes_OnKill(victim, attacker, weapon);
		//so using this sword against a raid doesnt result in an auto lose.
		if(EntRefToEntIndex(RaidBossActive) == victim)
		{
			RaidModeTime += 11.0;
		}
	}
}

public Action Saga_ExcuteTarget(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
		SDKHooks_TakeDamage(entity, 0, 0, 9999.9, DMG_TRUEDAMAGE);
	
	return Plugin_Continue;
}



void SagaCutFirst(int entity, int victim, float damage, int weapon)
{
	FreezeNpcInTime(victim, 0.2);
	float Range = 150.0;
	float Pos[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", Pos);
	spawnRing_Vectors(Pos, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.25, 12.0, 6.1, 1, 0.0);	
}


void SagaCutLast(int entity, int victim, float damage, int weapon)
{
	if(SagaCrippled[victim])
	{
		float VicLoc[3];
		WorldSpaceCenter(victim, VicLoc);

		float Pos1[3];
		float Pos2[3];
		float PosRand[3];

		Pos1 = VicLoc;
		Pos2 = VicLoc;

		PosRand[2] = GetRandomFloat(50.0,75.0);
		PosRand[0] = GetRandomFloat(-25.0,25.0);
		PosRand[1] = GetRandomFloat(-25.0,25.0);

		if(b_IsGiant[victim])
		{
			PosRand[0] *= 1.5;
			PosRand[1] *= 1.5;
			PosRand[2] *= 1.5;
		}

		Pos1[0] += PosRand[0];
		Pos1[1] += PosRand[1];
		Pos1[2] += PosRand[2];

		Pos2[0] -= PosRand[0];
		Pos2[1] -= PosRand[1];
		Pos2[2] -= PosRand[2];

		int red = 255;
		int green = 65;
		int blue = 65;
		int Alpha = 65;

		int colorLayer4[4];
		float diameter = float(10);
		SetColorRGBA(colorLayer4, red, green, blue, Alpha);
		//we set colours of the differnet laser effects to give it more of an effect
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
		int glowColor[4];
		SetColorRGBA(glowColor, red, green, blue, Alpha);
		TE_SetupBeamPoints(Pos1, Pos2, Shared_BEAM_Laser, 0, 0, 0, 0.25, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 0.5, glowColor, 0);
		TE_SendToAll(0.0);

		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);


		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], 0, SNDCHAN_AUTO, 90, _,_,GetRandomInt(80,110),-1,VicLoc);
		float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
		SDKHooks_TakeDamage(victim, weapon, entity, 10.0, DMG_TRUEDAMAGE, weapon, damage_force, VicLoc, _, _);
	}
}

void SagaAttackBeforeSwing(int client)
{
	SagaCrippled[client] = 1.0;
}
void SagaAttackAfterSwing(int client)
{
	SagaCrippled[client] = 0.0;
}



int Int_CooldownReductionDo(int client, int OriginalValue)
{
	return RoundToNearest(float(OriginalValue) * CooldownReductionAmount(client));
}