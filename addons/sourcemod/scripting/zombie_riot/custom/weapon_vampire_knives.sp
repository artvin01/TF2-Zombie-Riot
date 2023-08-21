#pragma semicolon 1
#pragma newdecls required

#define SND_THROW_CLEAVER	"misc/halloween/strongman_fast_whoosh_01.wav"
#define SND_THROW_KNIFE		"weapons/cleaver_throw.wav"
#define SND_BLOODLUST_CLEAVER	"weapons/halloween_boss/knight_axe_hit.wav"
#define SND_BLOODLUST_KNIFE	"weapons/cleaver_hit_02.wav"
#define SND_KNIFE_MISS		"weapons/cleaver_hit_world.wav"

#define MODEL_KNIFE		"models/weapons/c_models/c_knife/c_knife.mdl"
#define MODEL_CLEAVER	"models/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl"

public void Vampire_Knives_Precache()
{
	PrecacheSound(SND_THROW_CLEAVER);
	PrecacheSound(SND_THROW_KNIFE);
	PrecacheSound(SND_BLOODLUST_CLEAVER);
	PrecacheSound(SND_BLOODLUST_KNIFE);
	PrecacheSound(SND_KNIFE_MISS);
	
	PrecacheModel(MODEL_KNIFE);
	PrecacheModel(MODEL_CLEAVER);
}

//Arrays are used for stats for each pap so I don't have to type ten million different variables. Example:
//static float My_Attribute[3] = { Value_For_Pap_0, Value_For_Pap_1, Value_For_Pap_2 };

//Both pap paps inflict X stacks of Bloodlust on hit. Each stack of Bloodlust deals some bleed damage per Y seconds, then heals the user for a portion of
//that damage, up to a cap.
static float Vamp_BleedDMGMax[4] = { 99999.0, 99999.0, 99999.0, 99999.0 };	//The absolute maximum damage a single Bloodlust tick can inflict.
static float Vamp_BleedRate[4] = { 0.33, 0.275, 0.25, 0.2 }; //The rate at which Bloodlust deals damage.
static float Vamp_BleedHeal[4] = { 0.17, 0.085, 0.0475, 0.0475 };	//Portion of Bloodlust damage to heal the user for.
static float Vamp_HealRadius[4] = { 300.0, 330.0, 360.0, 390.0 };	//Max distance from the victim to heal the user in.
static float Vamp_HealMultIfHurt[4] = { 0.25, 0.25, 0.25, 0.25 };	//Amount to multiply healing received by Bloodlust if recently harmed.

//Default + Pap Route 1 - Vampire Knives: Fast melee swing speed, low melee damage, M2 throws X knives in a fan pattern which inflict Y* your melee damage.
static float Vamp_MaxHeal_Normal[4] = { 3.0, 2.5, 2.0, 1.8 };	//Max heal per tick.
static float Vamp_MinHeal_Normal[4] = { 1.5, 1.25, 1.1, 1.0 };	//Minimum healing received per Bloodlust tick.
static float Vamp_BleedDMG_Normal[4] = { 5.0, 6.5, 7.0, 8.5 }; //The base damage dealt per Bloodlust tick.
static int Vamp_BleedStacksOnMelee_Normal[4] = { 7, 10, 12, 14 }; //Number of Bloodlust stacks applied on a melee hit.
static int Vamp_BleedStacksOnThrow_Normal[4] = { 5, 7, 10, 12 }; //Number of Bloodlust stacks applied on a throw hit.
static float Vamp_ThrowMultiplier_Normal[4] = { 2.0, 3.0, 3.75, 4.25 }; //Amount to multiply damage dealt by thrown knives.
static float Vamp_ThrowCD_Normal[4] = { 6.0, 9.0, 14.0, 14.0 }; //Knife throw cooldown.
static int Vamp_ThrowKnives_Normal[4] = { 1, 3, 5, 6 }; //Number of knives thrown by M2.
static int Vamp_ThrowWaves_Normal[4] = { 2, 2, 4, 4 }; //Number of times to throw knives with M2.
static float Vamp_ThrowRate_Normal[4] = { 0.15, 0.1, 0.05, 0.05 }; //Time between throws if more than one wave in M2.
static float Vamp_ThrowSpread_Normal[4] = { 0.0, 30.0, 30.0, 30.0 }; //Degree of fan throw when throwing knives.
static float Vamp_ThrowVelocity_Normal[4] = { 1800.0, 2200.0, 2600.0, 2600.0 };	//Velocity of thrown knives.w 

//Pap Route 2 - Bloody Butcher: Becomes a slow but deadly cleaver which inflicts heavy damage and gibs zombies on kill. Inflicts more Bloodlust on hit to balance out the
//slower swing speed. M2 has a longer cooldown and throws fewer knives, but knives become extremely powerful cleavers which keep flying if they kill the
//zombie they hit.

static float Vamp_MaxHeal_Cleaver[4] = { 4.0, 4.0, 4.0, 4.0 };	//Max heal per tick.
static float Vamp_MinHeal_Cleaver[4] = { 2.0, 2.0, 2.0, 2.0 };	//Minimum healing received per Bloodlust tick.
static float Vamp_BleedDMG_Cleaver[4] = { 7.5, 20.0, 25.0, 30.0 }; //The base damage dealt per Bloodlust tick.
static int Vamp_BleedStacksOnMelee_Cleaver[4] = { 12, 16, 20, 24 }; //Same as pap route 1, but for pap route 2.
static int Vamp_BleedStacksOnThrow_Cleaver[4] = { 16, 20, 24, 28 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowMultiplier_Cleaver[4] = { 2.0, 1.33, 1.15, 1.0 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowCD_Cleaver[4] = { 10.0, 9.0, 12.0, 12.0 }; //Same as pap route 1, but for pap route 2.
static int Vamp_ThrowKnives_Cleaver[4] = { 1, 1, 2, 3 }; //Same as pap route 1, but for pap route 2.
static int Vamp_ThrowWaves_Cleaver[4] = { 1, 2, 2, 2 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowRate_Cleaver[4] = { 0.0, 0.66, 0.4, 0.3 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowSpread_Cleaver[4] = { 0.0, 0.0, 20.0, 20.0 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowVelocity_Cleaver[4] = { 1800.0, 2200.0, 2600.0, 2600.0 }; //Same as pap route 1, but for pap route 2.
static float Vamp_ThrowDMGMultPerKill[4] = { 0.0, 0.66, 0.8, 0.8 }; //Amount to multiply the damage dealt by thrown cleavers every time they kill a zombie.

int i_VampThrowType[MAXENTITIES] = { 0, ... };
int i_VampThrowProp[MAXENTITIES] = { 0, ... };
static float f_CleaverMultOnKill[MAXENTITIES] = { 0.0, ... };
static int i_VampKnivesMelee[MAXPLAYERS + 1] = { 0, ... };

static float f_VampNextHitSound[MAXPLAYERS + 1] = { 0.0, ... };

/*
	WEAPON_VAMPKNIVES_1 = 29,
	WEAPON_VAMPKNIVES_2 = 30,
	WEAPON_VAMPKNIVES_2_CLEAVER = 31,
	WEAPON_VAMPKNIVES_3 = 32,
	WEAPON_VAMPKNIVES_3_CLEAVER = 33
*/
void Vampire_KnifesDmgMulti(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_VAMPKNIVES_1
	|| i_CustomWeaponEquipLogic[weapon] == WEAPON_VAMPKNIVES_2
	|| i_CustomWeaponEquipLogic[weapon] == WEAPON_VAMPKNIVES_2_CLEAVER
	|| i_CustomWeaponEquipLogic[weapon] == WEAPON_VAMPKNIVES_3
	|| i_CustomWeaponEquipLogic[weapon] == WEAPON_VAMPKNIVES_3_CLEAVER
	|| i_CustomWeaponEquipLogic[weapon] == WEAPON_VAMPKNIVES_4
	|| i_CustomWeaponEquipLogic[weapon] == WEAPON_VAMPKNIVES_4_CLEAVER) 
	{
		i_VampKnivesMelee[client] = EntIndexToEntRef(weapon);
	}
}
public void Vampire_Knives_Throw(int client, int weapon, bool crit, int slot)
{
	Vamp_ActivateThrow(client, weapon, 0, false);
}

public void Vampire_Knives_Throw_2(int client, int weapon, bool crit, int slot)
{
	Vamp_ActivateThrow(client, weapon, 1, false);
}

public void Vampire_Knives_Throw_2_Cleaver(int client, int weapon, bool crit, int slot)
{
	Vamp_ActivateThrow(client, weapon, 1, true);
}

public void Vampire_Knives_Throw_3(int client, int weapon, bool crit, int slot)
{
	Vamp_ActivateThrow(client, weapon, 2, false);
}

public void Vampire_Knives_Throw_3_Cleaver(int client, int weapon, bool crit, int slot)
{
	Vamp_ActivateThrow(client, weapon, 2, true);
}

public void Vampire_Knives_Throw_4(int client, int weapon, bool crit, int slot)
{
	Vamp_ActivateThrow(client, weapon, 3, false);
}

public void Vampire_Knives_Throw_4_Cleaver(int client, int weapon, bool crit, int slot)
{
	Vamp_ActivateThrow(client, weapon, 3, true);
}

public void Vampire_Knives_Big_Swing(int client, int weapon, bool crit, int slot)
{
	EmitSoundToClient(client, SND_THROW_CLEAVER, _, _, _, _, _, GetRandomInt(80, 110));
}

public void Vamp_ActivateThrow(int client, int weapon, int pap, bool cleaver)
{
	if (!IsValidClient(client) || !IsValidEntity(weapon))
		return;
		
	if (Ability_Check_Cooldown(client, 2) < 0.0)
	{
		Ability_Apply_Cooldown(client, 2, cleaver ? Vamp_ThrowCD_Cleaver[pap] : Vamp_ThrowCD_Normal[pap]);
		
		int BleedStacks = cleaver ? Vamp_BleedStacksOnThrow_Cleaver[pap] : Vamp_BleedStacksOnThrow_Normal[pap];
		float DMGMult = cleaver ? Vamp_ThrowMultiplier_Cleaver[pap] : Vamp_ThrowMultiplier_Normal[pap];
		int NumKnives = cleaver ? Vamp_ThrowKnives_Cleaver[pap] : Vamp_ThrowKnives_Normal[pap];
		int NumWaves = cleaver ? Vamp_ThrowWaves_Cleaver[pap] : Vamp_ThrowWaves_Normal[pap];
		
		if (NumWaves < 1)
			return;
		
		float Rate = cleaver ? Vamp_ThrowRate_Cleaver[pap] : Vamp_ThrowRate_Normal[pap];
		float Spread = cleaver ? Vamp_ThrowSpread_Cleaver[pap] : Vamp_ThrowSpread_Normal[pap];
		float Velocity = cleaver ? Vamp_ThrowVelocity_Cleaver[pap] : Vamp_ThrowVelocity_Normal[pap];
		float CleaverMult = Vamp_ThrowDMGMultPerKill[pap];
	
		float DMG_Final = 65 * DMGMult;
		DMG_Final *= Attributes_Get(weapon, 1, 1.0);
		DMG_Final *= Attributes_Get(weapon, 2, 1.0);
		DMG_Final *= Attributes_Get(weapon, 476, 1.0);
		
		Vamp_ThrowKnives(client, weapon, BleedStacks, DMG_Final, NumKnives, NumWaves, Rate, Spread, Velocity, 0, cleaver, pap, CleaverMult);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public void Vamp_ThrowKnives(int client, int weapon, int BleedStacks, float DMG_Final, int NumKnives, int NumWaves, float Rate, float Spread, float Velocity, int CurrentThrowWave, bool cleaver, int pap, float CleaverMult)
{
	if (!IsValidClient(client) || !IsValidEntity(weapon))
		return;
		
	float eyePos[3], eyeAng[3];
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);

	float spreadIncrement = Spread / float(NumKnives);
	
	float ang;
	
	if (NumKnives % 2 == 0)
	{
		ang = eyeAng[1] - (0.5 * (spreadIncrement * (NumKnives / 2)));
	}
	else
	{
		ang = eyeAng[1] - (spreadIncrement * (NumKnives / 2));
	}
	
	for (int TimesThrown = 0 ; TimesThrown < NumKnives; ang += spreadIncrement)
	{
		float Angles[3];
		Angles = eyeAng;
		Angles[1] = ang;
			
		int index = cleaver ? 21 : 20;
		char ParticleName[255];
		//ParticleName = cleaver ? "blood_trail_red_01_goop" : "peejar_trail_red_glow";
		ParticleName = cleaver ? "peejar_trail_red_glow" : "stunballtrail_red_crit";
		int projectile = Wand_Projectile_Spawn(client, Velocity, 0.0, DMG_Final, index, weapon, ParticleName, Angles);
		CreateTimer(0.4, Vamp_ApplyGravity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
		
		if (cleaver)
		{
			SetEntityCollisionGroup(projectile, 1); //Do not collide.
			f_CleaverMultOnKill[projectile] = CleaverMult;
		}
		
		int prop = CreateEntityByName("prop_physics_override");
		if (IsValidEntity(prop))
		{
			char modelName[255];
			modelName = cleaver ? MODEL_CLEAVER : MODEL_KNIFE;
			
			if (!cleaver)
			{
				Angles[0] += 90.0;
			}
			else
			{
				CreateTimer(0.1, Cleaver_Spin, EntIndexToEntRef(prop), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
			
			float loc[3];
			GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", loc);
			
			DispatchKeyValue(prop, "targetname", "knifeModel"); 
			DispatchKeyValue(prop, "spawnflags", "2"); 
			DispatchKeyValue(prop, "model", modelName);
			DispatchKeyValue(prop, "modelscale", "2.0"); //comically large cleaver :)
			DispatchSpawn(prop);
			SetEntityCollisionGroup(prop, 1); //Do not collide. //0 doesnt work, use 1
			SetEntProp(prop, Prop_Send, "m_usSolidFlags", 12); 
			SetEntProp(prop, Prop_Data, "m_nSolidType", 6); 
			
			TeleportEntity(prop, loc, Angles, NULL_VECTOR);
			SetParent(projectile, prop);
		}
		
		
		i_VampThrowType[projectile] = pap + 1;
		i_VampThrowProp[projectile] = EntIndexToEntRef(prop);
		
		TimesThrown++;
	}
	
	EmitSoundToClient(client, cleaver ? SND_THROW_CLEAVER : SND_THROW_KNIFE, _, _, _, _, _, GetRandomInt(80, 110));
	
	CurrentThrowWave++;
	if (CurrentThrowWave < NumWaves)
	{
		Handle pack;
		CreateDataTimer(Rate, Vamp_NextWave, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, EntIndexToEntRef(weapon));
		WritePackCell(pack, BleedStacks);
		WritePackFloat(pack, DMG_Final);
		WritePackCell(pack, NumKnives);
		WritePackCell(pack, NumWaves);
		WritePackFloat(pack, Rate);
		WritePackFloat(pack, Spread);
		WritePackFloat(pack, Velocity);
		WritePackCell(pack, CurrentThrowWave);
		WritePackCell(pack, view_as<int>(cleaver));
		WritePackCell(pack, pap);
		WritePackFloat(pack, CleaverMult);
	}
}

public Action Cleaver_Spin(Handle spin, int ref)
{
	int projectile = EntRefToEntIndex(ref);
	if (IsValidEntity(projectile))
	{
		float ang[3];
		GetEntPropVector(projectile, Prop_Data, "m_angRotation", ang);
		ang[0] += 80.0;
		TeleportEntity(projectile, NULL_VECTOR, ang, NULL_VECTOR);
		
		return Plugin_Continue;
	}
	
	return Plugin_Stop;
}

public Action Vamp_ApplyGravity(Handle grav, int ref)
{
	int projectile = EntRefToEntIndex(ref);
	if (IsValidEntity(projectile))
	{
		SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(projectile, 1.0);
	}
	
	return Plugin_Continue;
}

public Action Vamp_NextWave(Handle next, any pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int weapon = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidClient(client) || !IsValidEntity(weapon))
		return Plugin_Continue;
		
	int BleedStacks = ReadPackCell(pack);
	float DMG_Final = ReadPackFloat(pack);
	int NumKnives = ReadPackCell(pack);
	int NumWaves = ReadPackCell(pack);
	float Rate = ReadPackFloat(pack);
	float Spread = ReadPackFloat(pack);
	float Velocity = ReadPackFloat(pack);
	int CurrentThrowWave = ReadPackCell(pack);
	bool cleaver = view_as<bool>(ReadPackCell(pack));
	int pap = ReadPackCell(pack);
	float CleaverMult = ReadPackFloat(pack);
	
	Vamp_ThrowKnives(client, weapon, BleedStacks, DMG_Final, NumKnives, NumWaves, Rate, Spread, Velocity, CurrentThrowWave, cleaver, pap, CleaverMult);
	return Plugin_Continue;
}

public void Vamp_ApplyBloodlust(int attacker, int victim, int VampType, bool IsCleaver, bool IsThrow)
{
	int NumStacks = IsCleaver ? Vamp_BleedStacksOnMelee_Cleaver[VampType - 1] : Vamp_BleedStacksOnMelee_Normal[VampType - 1];
	float BleedDmg = IsCleaver? Vamp_BleedDMG_Cleaver[VampType - 1] : Vamp_BleedDMG_Normal[VampType - 1];
	float BleedRate = Vamp_BleedRate[VampType - 1];
	float BleedHeal = Vamp_BleedHeal[VampType - 1];
	float Radius = Vamp_HealRadius[VampType - 1];
	float HealMultIfHurt = Vamp_HealMultIfHurt[VampType - 1];
	float MaxHeal = IsCleaver? Vamp_MaxHeal_Cleaver[VampType - 1] : Vamp_MaxHeal_Normal[VampType - 1];
	float MinHeal = IsCleaver? Vamp_MinHeal_Cleaver[VampType - 1] : Vamp_MinHeal_Normal[VampType - 1];
	float MaxDMG = Vamp_BleedDMGMax[VampType - 1];
	
	if (IsThrow)
	{
		NumStacks = IsCleaver ? Vamp_BleedStacksOnThrow_Cleaver[VampType - 1] : Vamp_BleedStacksOnThrow_Normal[VampType - 1];
	}
	
	if ((IsThrow || IsCleaver) && GetGameTime() >= f_VampNextHitSound[attacker])
	{
		EmitSoundToClient(attacker, IsCleaver ? SND_BLOODLUST_CLEAVER : SND_BLOODLUST_KNIFE, _, _, _, _, _, GetRandomInt(80, 110));
		f_VampNextHitSound[attacker] = GetGameTime() + 0.1;
	}
	
	BleedAmountCountStack[victim] += 1;
	Handle pack;
	CreateDataTimer(BleedRate, Vamp_BloodlustTick, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(attacker));
	WritePackCell(pack, EntIndexToEntRef(victim));
	WritePackCell(pack, victim);
	WritePackCell(pack, 0);
	WritePackCell(pack, NumStacks);
	WritePackCell(pack, MaxHeal);
	WritePackFloat(pack, BleedDmg);
	WritePackFloat(pack, BleedRate);
	WritePackFloat(pack, BleedHeal);
	WritePackFloat(pack, Radius);
	WritePackFloat(pack, HealMultIfHurt);
	WritePackCell(pack, MinHeal);
	WritePackFloat(pack, MaxDMG);
}

public Action Vamp_BloodlustTick(Handle bloodlust, any pack)
{
	ResetPack(pack);
	int attacker = GetClientOfUserId(ReadPackCell(pack));
	int victim = EntRefToEntIndex(ReadPackCell(pack));
	int victimOriginalId = ReadPackCell(pack);
	
	if (!IsValidClient(attacker) || !IsValidEntity(victim))
	{
		BleedAmountCountStack[victimOriginalId] -= 1;
		return Plugin_Continue;
	}
		
	if (b_NpcIsInvulnerable[victim]) //If the NPC is invulnerable, stop all bleeding.
	{
		BleedAmountCountStack[victim] -= 1;
		return Plugin_Continue;
	}	
	
	if (b_NpcHasDied[victim]) //Npc died, stop bleed and stop life leech
	{
		BleedAmountCountStack[victim] -= 1;
		return Plugin_Continue;
	}
	
	int NumHits = ReadPackCell(pack);
	int HitQuota = ReadPackCell(pack);
	float MaxHeal = ReadPackCell(pack);
	float DMG = ReadPackFloat(pack);
	float Rate = ReadPackFloat(pack);
	float HealMult = ReadPackFloat(pack);
	float Radius = ReadPackFloat(pack);
	float HealMultIfHurt = ReadPackFloat(pack);
	float MinHeal = ReadPackCell(pack);
	float MaxDMG = ReadPackFloat(pack);
	
	float DMG_Final = DMG;
	
	int weapon = EntRefToEntIndex(i_VampKnivesMelee[attacker]);
	if (IsValidEntity(weapon))
	{
		DMG_Final *= Attributes_Get(weapon, 2, 1.0);
		DMG_Final *= Attributes_Get(weapon, 476, 1.0);
	}
	
	if (DMG_Final > MaxDMG)
		DMG_Final = MaxDMG;
	
	float loc[3], vicloc[3], dist;
	GetClientAbsOrigin(attacker, loc);
	vicloc = WorldSpaceCenter(victim);
	dist = GetVectorDistance(loc, vicloc);
	
	for (int i = 0; i < 3; i++)
	{
		vicloc[i] += GetRandomFloat(-45.0, 45.0);
	}
	
	SDKHooks_TakeDamage(victim, attacker, attacker, DMG_Final, DMG_CLUB, _, _, vicloc, false, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
	
	if (dist <= Radius && dieingstate[attacker] == 0)
	{
		float mult = HealMult;
		float heal = DMG_Final * mult;
		

		if (heal > MaxHeal)
		{
			heal = MaxHeal;
		}
		
		if (heal < MinHeal)
		{
			heal = MinHeal;
		}
		
		if(f_TimeUntillNormalHeal[attacker] > GetGameTime())
		{
			heal *= HealMultIfHurt;
		}

		int healingdone = HealEntityViaFloat(attacker, heal, 1.0);
		if(healingdone > 0)
			ApplyHealEvent(attacker, healingdone);
	}
	
	NumHits++;
	if (NumHits >= HitQuota)
	{
		BleedAmountCountStack[victim] -= 1;
		return Plugin_Continue;
	}
	Handle pack2;
	CreateDataTimer(Rate, Vamp_BloodlustTick, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, GetClientUserId(attacker));
	WritePackCell(pack2, EntIndexToEntRef(victim));
	WritePackCell(pack2, victim);
	WritePackCell(pack2, NumHits);
	WritePackCell(pack2, HitQuota);
	WritePackCell(pack2, MaxHeal);
	WritePackFloat(pack2, DMG);
	WritePackFloat(pack2, Rate);
	WritePackFloat(pack2, HealMult);
	WritePackFloat(pack2, Radius);
	WritePackFloat(pack2, HealMultIfHurt);
	WritePackCell(pack2, MinHeal);
	WritePackFloat(pack2, MaxDMG);
	
	return Plugin_Continue;
}

public void Vamp_Cleaver_Touch_World(int entity, int other)
{
	if (other == 0)	
	{
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		EmitSoundToAll(SND_KNIFE_MISS, entity, SNDCHAN_STATIC, 80, _, 1.0);
		ParticleEffectAt(position, "ExplosionCore_buildings", 1.0);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}

public void Vamp_Knife_Touch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		//Code to do damage position and ragdolls
		
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float position[3];
	
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, "blood_trail_red_01_goop", 1.0);
		
		Vamp_ApplyBloodlust(owner, target, i_VampThrowType[entity], false, true);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		EmitSoundToAll(SND_KNIFE_MISS, entity, SNDCHAN_STATIC, 80, _, 1.0);
		ParticleEffectAt(position, "bullet_scattergun_impact01", 1.0);
		RemoveEntity(entity);
	}
}

public bool Vamp_CleaverHit(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	
	if (target <= 0)
		return true;
		
	//Code to do damage position and ragdolls
	static float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	float vecForward[3];
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	static float Entity_Position[3];
	Entity_Position = WorldSpaceCenter(target);
	//Code to do damage position and ragdolls
		
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

	float dmg = f_WandDamage[entity];
	int hp = GetEntProp(target, Prop_Data, "m_iHealth");

	if (dmg >= hp)
	{
		SDKHooks_TakeDamage(target, owner, owner, dmg, DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position, false, ZR_DAMAGE_GIB_REGARDLESS);	// 2048 is DMG_NOGIB?
		f_WandDamage[entity] *= f_CleaverMultOnKill[entity];
		return false;
	}
	else
	{
		SDKHooks_TakeDamage(target, owner, owner, dmg, DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		float position[3];
		
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, "blood_trail_red_01_goop", 1.0);
			
		Vamp_ApplyBloodlust(owner, target, i_VampThrowType[entity], true, true);
		RemoveEntity(entity);
		return true;
	}
}

public void Vamp_EntityDestroyed(int ent)
{
	if (!IsValidEdict(ent))
		return;
		
	i_VampThrowType[ent] = 0;
	i_VampThrowProp[ent] = 0;
	f_CleaverMultOnKill[ent] = 0.0;
	f_VampNextHitSound[ent] = 0.0;
}