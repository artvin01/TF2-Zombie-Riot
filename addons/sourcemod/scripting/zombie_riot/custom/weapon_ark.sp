#pragma semicolon 1
#pragma newdecls required

//no idea how those work but they are needed from what i see
static float RMR_HomingPerSecond[MAXENTITIES];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_HasTargeted[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static float RMR_RocketVelocity[MAXENTITIES];
static int weapon_id[MAXPLAYERS+1]={0, ...};
static int Ark_Hits[MAXPLAYERS+1]={0, ...};
static int Ark_AlreadyParried[MAXPLAYERS+1]={0, ...};
static float Ark_ParryTiming[MAXPLAYERS+1];

static int Ark_Level[MAXPLAYERS+1]={0, ...};

static float f_AniSoundSpam[MAXPLAYERS+1]={0.0, ...};


#define SOUND_QUIBAI_SHOT 	"weapons/stunstick/alyx_stunner2.wav"
#define SOUND_LAPPLAND_SHOT 	"weapons/fx/nearmiss/dragons_fury_nearmiss.wav"
#define SOUND_LAPPLAND_ABILITY 	"items/powerup_pickup_plague.wav"

#define LAPPLAND_SILENCE_DUR_NORMAL 3.0
#define LAPPLAND_SILENCE_DUR_ABILITY 6.0
#define QUIBAI_SILENCE_DUR_NORMAL 4.0
#define QUIBAI_SILENCE_DUR_ABILITY 8.0

Handle h_TimerWeaponArkManagement[MAXPLAYERS+1] = {null, ...};
static float f_WeaponArkhuddelay[MAXPLAYERS+1]={0.0, ...};


//This shitshow of a weapon is basicly the combination of bad wand/homing wand along with some abilities and a sword

#define LAPPLAND_MAX_HITS_NEEDED 84 //Double the amount because we do double hits.
#define LAPPLAND_AOE_SILENCE_RANGE 200.0
#define LAPPLAND_AOE_SILENCE_RANGE_SQUARED 40000.0
Handle h_TimerLappLandManagement[MAXPLAYERS+1] = {null, ...};
static int i_LappLandHitsDone[MAXPLAYERS+1]={0, ...};
static float f_LappLandAbilityActive[MAXPLAYERS+1]={0.0, ...};
static float f_LappLandhuddelay[MAXPLAYERS+1]={0.0, ...};
static int i_QuibaiAttacksMade[MAXPLAYERS+1]={0, ...};

//final pap new ability thingies
static float Duration[MAXPLAYERS];

void Ark_autoaim_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM);
	PrecacheSound(SOUND_WAND_SHOT_AUTOAIM_ABILITY);
	PrecacheSound(SOUND_AUTOAIM_IMPACT);
	PrecacheModel(ENERGY_BALL_MODEL);
	PrecacheSound(SOUND_WAND_SHOT);
	PrecacheSound(SOUND_ZAP);
	PrecacheSound(SOUND_LAPPLAND_SHOT);
	PrecacheSound(SOUND_QUIBAI_SHOT);
	PrecacheSound(SOUND_LAPPLAND_ABILITY);
	PrecacheSound("weapons/bombinomicon_explode1.wav");
	PrecacheSound("weapons/tf2_back_scatter.wav");
	Zero(f_AniSoundSpam);
	Zero(h_TimerLappLandManagement);
	Zero(i_LappLandHitsDone);
	Zero(f_LappLandAbilityActive);
	Zero(f_LappLandhuddelay);
	Zero(h_TimerWeaponArkManagement);
	Zero(f_WeaponArkhuddelay);
	Zero(Ark_ParryTiming);
}

void Reset_stats_LappLand_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerLappLandManagement[client] != null)
	{
		delete h_TimerLappLandManagement[client];
	}	
	h_TimerLappLandManagement[client] = null;
	i_LappLandHitsDone[client] = 0;
}

public void Ark_empower_ability(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		if(HasSpecificBuff(client, "Empowering Domain"))
			Ability_Apply_Cooldown(client, slot, 15.0 * 0.4);
		else
			Ability_Apply_Cooldown(client, slot, 15.0);

		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");
		Ark_ParryTiming[client] = GetGameTime() + 1.0;

		Ark_Level[client] = 0;
		
		weapon_id[client] = weapon;

		Ark_Hits[client] = 6;
				
		ApplyTempAttrib(weapon, 6, 0.75, 3.0);

		float flPos[3]; // original
		float flAng[3]; // original	
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 1.0);
				
		SetParent(client, particler, "effect_hand_r");

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
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public void Ark_empower_ability_2(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		if(HasSpecificBuff(client, "Empowering Domain"))
			Ability_Apply_Cooldown(client, slot, 15.0 * 0.4);
		else
			Ability_Apply_Cooldown(client, slot, 15.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");
		Ark_ParryTiming[client] = GetGameTime() + 1.0;

		Ark_Level[client] = 1;
		
		weapon_id[client] = weapon;

		Ark_Hits[client] = 10;
				

		ApplyTempAttrib(weapon, 6, 0.75, 3.0);
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		GetAttachment(client, "effect_hand_r", flPos, flAng);
				
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 1.0);
				
		SetParent(client, particler, "effect_hand_r");

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
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public void Ark_empower_ability_3(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		if(HasSpecificBuff(client, "Empowering Domain"))
			Ability_Apply_Cooldown(client, slot, 15.0 * 0.4);
		else
			Ability_Apply_Cooldown(client, slot, 15.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");
		Ark_ParryTiming[client] = GetGameTime() + 1.0;

		Ark_Level[client] = 2;
		
		weapon_id[client] = weapon;

		Ark_Hits[client] = 10;
				
				
		ApplyTempAttrib(weapon, 6, 0.75, 3.0);

		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
			
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 1.0);
				
		SetParent(client, particler, "effect_hand_r");
				

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
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}
public void Ark_empower_ability_4(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		if(HasSpecificBuff(client, "Empowering Domain"))
			Ability_Apply_Cooldown(client, slot, 15.0 * 0.4);
		else
			Ability_Apply_Cooldown(client, slot, 15.0);
		ClientCommand(client, "playgamesound weapons/samurai/tf_katana_draw_02.wav");
		Ark_ParryTiming[client] = GetGameTime() + 1.0;

		Ark_Level[client] = 3;
		
		weapon_id[client] = weapon;

		Ark_Hits[client] = 15;
		Ark_AlreadyParried[client] = 0;
				
				
		ApplyTempAttrib(weapon, 6, 0.75, 5.0);

		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
			
		int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 1.0);
				
		SetParent(client, particler, "effect_hand_r");
				

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
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public void Ark_attack0(int client, int weapon, bool crit, int slot) // stats for the base version of the weapon
{       
	if(Ark_Hits[client] >= 1)
	{
		Ark_Hits[client] -= 1;
		float damage = 25.0;

		damage *= Attributes_Get(weapon, 2, 1.0);
			
		float speed = 500.0;

		speed *= Attributes_Get(weapon, 103, 1.0);
	
		speed *= Attributes_Get(weapon, 104, 1.0);
	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 1000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);

		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);

		Ark_Lauch_projectile(client, weapon, false, speed, time, damage);
	}
}
public void Ark_attack1(int client, int weapon, bool crit, int slot) //first pap version
{
	if(Ark_Hits[client] >= 1)
	{
		Ark_Hits[client] -= 1;
		float damage = 50.0;
			
		float speed = 1100.0;
		damage *= Attributes_Get(weapon, 2, 1.0);

		speed *= Attributes_Get(weapon, 103, 1.0);
	
		speed *= Attributes_Get(weapon, 104, 1.0);
	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 1000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);

		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		Ark_Lauch_projectile(client, weapon, false, speed, time, damage);
	}
}

public void Ark_attack2(int client, int weapon, bool crit, int slot) //second pap version
{

	if(Ark_Hits[client] >= 1)
	{

		Ark_Hits[client] -= 1;

		float damage = 50.0;
			
		float speed = 1100.0;
		damage *= Attributes_Get(weapon, 2, 1.0);

		speed *= Attributes_Get(weapon, 103, 1.0);
	
		speed *= Attributes_Get(weapon, 104, 1.0);
	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 1000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);
			
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		Ark_Lauch_projectile(client, weapon, false, speed, time, damage);
		Ark_Lauch_projectile(client, weapon, true, speed, time, damage);
	}
}
public void Ark_attack3(int client, int weapon, bool crit, int slot) //second pap version
{

	if(Ark_Hits[client] >= 1)
	{

		Ark_Hits[client] -= 1;

		float damage = 50.0;
			
		float speed = 1100.0;
		damage *= Attributes_Get(weapon, 2, 1.0);

		speed *= Attributes_Get(weapon, 103, 1.0);
	
		speed *= Attributes_Get(weapon, 104, 1.0);
	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
	
		float time = 1000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);
	
		time *= Attributes_Get(weapon, 102, 1.0);
			
		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		Ark_Lauch_projectile(client, weapon, false, speed, time, damage);
		Ark_Lauch_projectile(client, weapon, true, speed, time, damage);
	}
}


void Ark_Lauch_projectile(int client, int weapon, bool multi, float speed, float time, float damage)
{
	char Particle[36];

	if(multi)
	{	
		damage *= 0.40;
		float Angles[3];
		GetClientEyeAngles(client, Angles);
		Format(Particle, sizeof(Particle), "%s", "unusual_robot_radioactive2");
		for (int i = 1; i <= 2; i++)
		{
			
			for (int spread = 0; spread < 3; spread++)
			{
				Angles[spread] += GetRandomFloat(-5.0, 5.0);
			}
			int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 15/*ark*/, weapon, Particle, Angles);
				

			float fAng[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", fAng);
			Initiate_HomingProjectile(projectile,
			client,
				180.0,			// float lockonAngleMax,
				90.0,				//float homingaSec,
				true,				// bool LockOnlyOnce,
				true,				// bool changeAngles,
				fAng,
				_);			// float AnglesInitiate[3]);
		}
	}
	else
	{
		Format(Particle, sizeof(Particle), "%s", "unusual_robot_radioactive");
		Wand_Projectile_Spawn(client, speed, time, damage, 15/*ark*/, weapon, Particle);
	}
}
public Action Event_Ark_OnHatTouch(int entity, int other)// code responsible for doing damage to the enemy
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);
		//Code to do damage position and ragdolls

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(other, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle) && particle != 0)
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}


//stuff that gets activated upon taking damage
public float Player_OnTakeDamage_Ark(int victim, float &damage, int attacker, int weapon, float damagePosition[3], int damagetype)
{
	//if (Ability_Check_Cooldown(victim, 2) >= 14.0 && Ability_Check_Cooldown(victim, 2) < 16.0)
	if (Ark_ParryTiming[victim] > GetGameTime())
	{
		if(!CheckInHud())
		{
			float damage_reflected = damage;
			if(Ark_AlreadyParried[victim] == 0 && Ark_Level[victim] == 3)
			{
				if(damage_reflected >= 500.0)
				{
					damage_reflected = 500.0;
					//ClientCommand(victim, "playgamesound weapons/tf2_back_scatter.wav");
					EmitSoundToClient(victim, "weapons/tf2_back_scatter.wav", victim, SNDCHAN_AUTO, 80, _, 1.0, 110);
				}
				damage_reflected = damage_reflected * 5;
				Ark_AlreadyParried[victim] = 1;
			}
			else
			{
				if(damage_reflected >= 300.0)
				{
					damage_reflected = 300.0;
				}
			}
			//PrintToChatAll("parry worked");
			if(Ark_Level[victim] == 3)
			{
				damage_reflected *= 40.0;
				
				if(Ark_Hits[victim] < 25)
				{
					Ark_Hits[victim] = 25;
				}
				Ark_Hits[victim] += 1;
			}
			else if(Ark_Level[victim] == 2)
			{
				damage_reflected *= 30.0;
				
				if(Ark_Hits[victim] < 20)
				{
					Ark_Hits[victim] = 20;
				}
				Ark_Hits[victim] += 1;		
			}
			else if(Ark_Level[victim] == 1)
			{
				damage_reflected *= 15.0;
				
				if(Ark_Hits[victim] < 12)
				{
					Ark_Hits[victim] = 12;
				}
				Ark_Hits[victim] += 1;		
			}
			else
			{
				damage_reflected *= 6.0;
				
				if(Ark_Hits[victim] < 6)
				{
					Ark_Hits[victim] = 6;
				}
				Ark_Hits[victim] += 1;	
			}
			
			if(f_AniSoundSpam[victim] < GetGameTime())
			{
				f_AniSoundSpam[victim] = GetGameTime() + 0.2;
				ClientCommand(victim, "playgamesound weapons/samurai/tf_katana_impact_object_02.wav");
			}
			
			static float angles[3];
			GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			static float Entity_Position[3];
			WorldSpaceCenter(attacker, Entity_Position );
			
			float flPos[3]; // original
			float flAng[3]; // original
			
			GetAttachment(victim, "effect_hand_r", flPos, flAng);

		//	TE_Particle("mvm_soldier_shockwave", damagePosition, NULL_VECTOR, flAng, -1, _, _, _, _, _, _, _, _, _, 0.0);
			float diameter = float(4 * 2);
			int r = 200;
			int g = 125;
			int b = 125;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 60);
			TE_SetupBeamPoints(flPos, Entity_Position, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(flPos, Entity_Position, g_Ruina_BEAM_Combine_Black, 0, 0, 66, 0.22, ClampBeamWidth(diameter * 0.4 * 1.28), ClampBeamWidth(diameter * 0.4 * 1.28), 0, 1.0,  {255,255,255,125}, 3);
			TE_SendToAll(0.0);

			TE_SetupBeamPoints(flPos, Entity_Position, Shared_BEAM_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, colorLayer4, 1);
			TE_SendToAll(0.0);
			float ReflectPosVec[3];
			CalculateDamageForce(vecForward, 10000.0, ReflectPosVec);

			DataPack packdmg = new DataPack();
			packdmg.WriteCell(EntIndexToEntRef(attacker));
			packdmg.WriteCell(EntIndexToEntRef(victim));
			packdmg.WriteCell(EntIndexToEntRef(victim));
			packdmg.WriteFloat(damage_reflected);
			packdmg.WriteCell(DMG_CLUB);
			packdmg.WriteCell(EntIndexToEntRef(weapon));
			packdmg.WriteFloat(ReflectPosVec[0]);
			packdmg.WriteFloat(ReflectPosVec[1]);
			packdmg.WriteFloat(ReflectPosVec[2]);
			packdmg.WriteFloat(Entity_Position[0]);
			packdmg.WriteFloat(Entity_Position[1]);
			packdmg.WriteFloat(Entity_Position[2]);
			packdmg.WriteCell(ZR_DAMAGE_REFLECT_LOGIC);
			RequestFrame(CauseDamageLaterSDKHooks_Takedamage, packdmg);
				
		}
		if(!(damagetype & DMG_TRUEDAMAGE))
			return damage * 0.1;

		return damage;
	}
	else 
	{
		 //PrintToChatAll("parry failed");
		return damage;
	}
}



public void WeaponArk_Cooldown_Logic(int client, int weapon)
{
	if(f_WeaponArkhuddelay[client] < GetGameTime())
	{
		f_WeaponArkhuddelay[client] = GetGameTime() + 0.5;
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			PrintHintText(client, "Ark Energy [%d]", Ark_Hits[client]);
			
		}
	}
}

public Action Timer_Management_WeaponArk(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerWeaponArkManagement[client] = null;
		return Plugin_Stop;
	}	
	
	WeaponArk_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}

public void Enable_WeaponArk(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerWeaponArkManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ARK)
		{
			delete h_TimerWeaponArkManagement[client];
			h_TimerWeaponArkManagement[client] = null;
			DataPack pack;
			h_TimerWeaponArkManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponArk, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ARK)
	{
		DataPack pack;
		h_TimerWeaponArkManagement[client] = CreateDataTimer(0.1, Timer_Management_WeaponArk, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}




public void Arkoftheelements_Explosion(int client, int weapon, bool crit, int slot)
{
	if(Ark_Hits[client] >= 10)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Ark_Hits[client] -= 10;
			//float fPos[3];
			//bool RaidActive = false;//normally we assume there isnt a raid boss alive
			float damage = 500.0;
			/*
			if(RaidbossIgnoreBuildingsLogic(1))//checks if a raid boss is alive
			{
				//RaidActive = true;
				damage = 750.0;
			}
			*/

			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 15.0);
			
			damage *= Attributes_Get(weapon, 2, 1.0);

			i_ExplosiveProjectileHexArray[weapon] = 0;
			i_ExplosiveProjectileHexArray[weapon] |= EP_DEALS_CLUB_DAMAGE;

			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);

			//Explode_Logic_Custom(damage, client, client, weapon, fPos, Explosion radious, _, _, _, 15);
			Explode_Logic_Custom(damage, client, client, weapon, _, 500.0, _, _, false, 15);
			FinishLagCompensation_Base_boss();

			//float EnemyPos[3];
			float UserLoc[3];
			GetClientAbsOrigin(client, UserLoc);
			//spawn location, particle name, particle duration
			ParticleEffectAt(UserLoc, "Explosion_ShockWave_01", 1.0);
			ParticleEffectAt(UserLoc, "eyeboss_tp_escape", 1.0);
			EmitSoundToAll("weapons/bombinomicon_explode1.wav", client, _, 75, _, 0.55, 100);
			
			/*	stun on ability would be funny but arvan would skin me alive so sadly no		
			for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)//cycles through all npcs
			{
				int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
				if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
				{
					GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", EnemyPos);
					if (GetVectorDistance(EnemyPos, UserLoc, true) <= (NEARL_STUN_RANGE * NEARL_STUN_RANGE))//check if the npc is close enough to the caster
					{
						if(!b_thisNpcIsABoss[baseboss_index] && !RaidActive)//stun :D
						{
							FreezeNpcInTime(baseboss_index,Duration_Stun);
						}
						else
						{
							FreezeNpcInTime(baseboss_index,Duration_Stun_Boss);
						}
					}
				}
			}
			*/
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
	}
	else
	{			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not enough charge");
	}
}



public bool Weapon_ark_LappLand_Attack_InAbility(int client) //second pap version
{
	if(f_LappLandAbilityActive[client] < GetGameTime())
	{
		return false;
	}
	return true;
}

void Weapon_ark_LapplandRangedAttack(int client, int weapon)
{
	//woopsies!
	//no need for lag comp, we are already in one.
	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	
	EmitSoundToAll(SOUND_LAPPLAND_SHOT, client, _, 75, _, 0.55, GetRandomInt(90, 110));

	float damage = 65.0;
	damage *= 0.6; //Reduction
	if(f_LappLandAbilityActive[client] > GetGameTime())
	{
		damage *= 2.0;
	}
			
	float speed = 1100.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 2000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	if(IsValidEnemy(client, target))
	{
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LAPPLAND, weapon, "manmelter_projectile_trail");
		

		float fAng[3];
		GetEntPropVector(projectile, Prop_Send, "m_angRotation", fAng);
		Initiate_HomingProjectile(projectile,
		client,
			180.0,			// float lockonAngleMax,
			90.0,				//float homingaSec,
			true,				// bool LockOnlyOnce,
			true,				// bool changeAngles,
			fAng,
			target);			// float AnglesInitiate[3]);
		TriggerTimerHoming(projectile);
	}
	else
	{
		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LAPPLAND, weapon, "manmelter_projectile_trail");
		//no enemy, fire projectile blindly!, maybe itll hit an enemy!
	}
}

public void Melee_LapplandArkTouch(int entity, int target)
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
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		if(f_LappLandAbilityActive[owner] < GetGameTime())
		{
			ApplyStatusEffect(owner, target, "Silenced", LAPPLAND_SILENCE_DUR_NORMAL);
			i_LappLandHitsDone[owner] += 1;
			if(i_LappLandHitsDone[owner] >= LAPPLAND_MAX_HITS_NEEDED) //We do not go above this, no double charge.
			{
				float flPos[3]; // original
				float flAng[3]; // original
				EmitSoundToAll(SOUND_LAPPLAND_ABILITY, owner, _, 90, _, 1.0);
				GetAttachment(owner, "effect_hand_r", flPos, flAng);				
				int particle_Hand = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 20.0);
				SetParent(owner, particle_Hand, "effect_hand_r");
				Weapon_Ark_SilenceAOE(target, LAPPLAND_SILENCE_DUR_ABILITY); //lag comp or not, doesnt matter.
				i_LappLandHitsDone[owner] = 0;
				
				MakePlayerGiveResponseVoice(owner, 1); //haha!
				f_LappLandAbilityActive[owner] = GetGameTime() + 20.0;
				f_WandDamage[entity] *= 2.0;
			}
		}
		else
		{
			Weapon_Ark_SilenceAOE(target, LAPPLAND_SILENCE_DUR_ABILITY); //lag comp or not, doesnt matter.
		}

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, entity, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		
		
		
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		RemoveEntity(entity);
	}
}

public void Enable_LappLand(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerLappLandManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LAPPLAND)
		{
			//Is the weapon it again?
			//Yes?

			delete h_TimerLappLandManagement[client];
			h_TimerLappLandManagement[client] = null;
			DataPack pack;
			h_TimerLappLandManagement[client] = CreateDataTimer(0.1, Timer_Management_LappLand, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LAPPLAND)
	{
		DataPack pack;
		h_TimerLappLandManagement[client] = CreateDataTimer(0.1, Timer_Management_LappLand, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public void LappLand_Cooldown_Logic(int client, int weapon)
{
	if(f_LappLandhuddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(f_LappLandAbilityActive[client] < GetGameTime())
			{
				PrintHintText(client,"Wolf Spirit [%i%/%i]", i_LappLandHitsDone[client], LAPPLAND_MAX_HITS_NEEDED);
			}
			else
			{
				float TimeLeft = f_LappLandAbilityActive[client] - GetGameTime();
				PrintHintText(client,"Raging Wolf Spirit [%.1f]",TimeLeft);
			}
			
			
			f_LappLandhuddelay[client] = GetGameTime() + 0.5;
		}
	}
}

public Action Timer_Management_LappLand(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerLappLandManagement[client] = null;
		return Plugin_Stop;
	}	

	LappLand_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}

float Npc_OnTakeDamage_LappLand(float damage ,int attacker, int damagetype, int inflictor, int victim)
{
	if(inflictor == attacker) //make sure it doesnt gain things here if the projectile hit.
	{
		if((damagetype & DMG_CLUB) || (damagetype & DMG_PLASMA)) //We only count normal melee hits.
		{
			if(f_LappLandAbilityActive[attacker] < GetGameTime())
			{
				ApplyStatusEffect(attacker, victim, "Silenced", LAPPLAND_SILENCE_DUR_NORMAL);
				i_LappLandHitsDone[attacker] += 2;
				if(i_LappLandHitsDone[attacker] >= LAPPLAND_MAX_HITS_NEEDED) //We do not go above this, no double charge.
				{
					EmitSoundToAll(SOUND_LAPPLAND_ABILITY, attacker, _, 90, _, 1.0);
					float flPos[3]; // original
					float flAng[3]; // original

					GetAttachment(attacker, "effect_hand_r", flPos, flAng);				
					int particle_Hand = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 20.0);
					SetParent(attacker, particle_Hand, "effect_hand_r");

					i_LappLandHitsDone[attacker] = 0;
					f_LappLandAbilityActive[attacker] = GetGameTime() + 20.0;
					MakePlayerGiveResponseVoice(attacker, 1); //haha!
					Weapon_Ark_SilenceAOE(victim, LAPPLAND_SILENCE_DUR_ABILITY); //lag comp or not, doesnt matter.
					damage *= 2.0; //2x dmg
				}
			}
			else
			{
				Weapon_Ark_SilenceAOE(victim, LAPPLAND_SILENCE_DUR_ABILITY); //lag comp or not, doesnt matter.
				damage *= 2.0; //2x dmg
			}
		}
	}
	return damage;
}

void Weapon_Ark_SilenceAOE(int enemyStruck, float duration)
{
	float VictimPos[3];
	float EnemyPos[3];
	GetEntPropVector(enemyStruck, Prop_Data, "m_vecAbsOrigin", VictimPos);
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
		if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", EnemyPos);
			if (GetVectorDistance(EnemyPos, VictimPos, true) <= (LAPPLAND_AOE_SILENCE_RANGE_SQUARED))
			{
				ApplyStatusEffect(entity, entity, "Silenced", duration);
			}
		}
	}
}




public void Enable_Quibai(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerLappLandManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_QUIBAI)
		{
			//Is the weapon it again?
			//Yes?

			delete h_TimerLappLandManagement[client];
			h_TimerLappLandManagement[client] = null;
			DataPack pack;
			h_TimerLappLandManagement[client] = CreateDataTimer(0.1, Timer_Management_Quibai, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_QUIBAI)
	{
		DataPack pack;
		h_TimerLappLandManagement[client] = CreateDataTimer(0.1, Timer_Management_Quibai, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


// use the same h_TimerLappLandManagement manager because theres no reason to have 2, there is only ever 1 of each as its 1 pap line.
public Action Timer_Management_Quibai(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerLappLandManagement[client] = null;
		return Plugin_Stop;
	}	

	Quibai_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}

#define QUIBAI_MAX_HITS_NEEDED 100 //Double the amount because we do double hits.

public void Quibai_Cooldown_Logic(int client, int weapon)
{
	if(f_LappLandhuddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(f_LappLandAbilityActive[client] < GetGameTime())
			{
				PrintHintText(client,"Questioning Snow [%i%/%i]", i_LappLandHitsDone[client], QUIBAI_MAX_HITS_NEEDED);
			}
			else
			{
				float TimeLeft = f_LappLandAbilityActive[client] - GetGameTime();
				PrintHintText(client,"Raging Snow [%.1f]",TimeLeft);
			}
			
			
			f_LappLandhuddelay[client] = GetGameTime() + 0.5;
		}
	}
}


float Npc_OnTakeDamage_Quibai(float damage ,int attacker, int damagetype, int inflictor, int victim, int weapon)
{
	if(inflictor == attacker) //make sure it doesnt gain things here if the projectile hit.
	{
		if(damagetype & DMG_CLUB) //We only count normal melee hits.
		{
			ChangeAttackspeedQuibai(attacker,weapon);
			if(f_LappLandAbilityActive[attacker] < GetGameTime())
			{
				ApplyStatusEffect(attacker, victim, "Silenced", QUIBAI_SILENCE_DUR_NORMAL);
				i_LappLandHitsDone[attacker] += 2;
				if(i_LappLandHitsDone[attacker] >= QUIBAI_MAX_HITS_NEEDED) //We do not go above this, no double charge.
				{
					i_LappLandHitsDone[attacker] = QUIBAI_MAX_HITS_NEEDED;
				}
			}
			else
			{
				Weapon_Ark_SilenceAOE(victim, QUIBAI_SILENCE_DUR_ABILITY); //lag comp or not, doesnt matter.
				damage *= 2.0; //2x dmg
			}
		}
	}
	return damage;
}


public void Melee_QuibaiArkTouch(int entity, int target)
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
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		if(f_LappLandAbilityActive[owner] < GetGameTime())
		{
			ApplyStatusEffect(owner, target, "Silenced", QUIBAI_SILENCE_DUR_NORMAL);
			i_LappLandHitsDone[owner] += 1;
			if(i_LappLandHitsDone[owner] >= QUIBAI_MAX_HITS_NEEDED) //We do not go above this, no double charge.
			{
				i_LappLandHitsDone[owner] = QUIBAI_MAX_HITS_NEEDED;
			}
		}
		else
		{
			Weapon_Ark_SilenceAOE(target, QUIBAI_SILENCE_DUR_ABILITY); //lag comp or not, doesnt matter.
		}
		ChangeAttackspeedQuibai(owner,weapon);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, entity, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		
		
		
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		RemoveEntity(entity);
	}
}



void Weapon_ark_QuibaiRangedAttack(int client, int weapon, bool Firedshotalready = false)
{
	ChangeAttackspeedQuibai(client,weapon);
	//woopsies!
	//no need for lag comp, we are already in one.
	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	
	EmitSoundToAll(SOUND_QUIBAI_SHOT, client, _, 75, _, 0.25, GetRandomInt(90, 110));

	float damage = 65.0;
	damage *= 0.6; //Reduction
	if(f_LappLandAbilityActive[client] > GetGameTime())
	{
		if(!Firedshotalready)
		{
			DataPack pack;
			CreateDataTimer(0.2, FireAnotherShotQuibai, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(client)); 
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		damage *= 1.35;
	}
			
	float speed = 1100.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	damage *= Attributes_Get(weapon, 1, 1.0);
	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 2000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	if(IsValidEnemy(client, target))
	{

		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_QUIBAI, weapon, "rockettrail_airstrike_line");
		


		float fAng[3];
		GetEntPropVector(projectile, Prop_Send, "m_angRotation", fAng);
		Initiate_HomingProjectile(projectile,
		client,
			180.0,			// float lockonAngleMax,
			90.0,				//float homingaSec,
			true,				// bool LockOnlyOnce,
			true,				// bool changeAngles,
			fAng,
			target);			// float AnglesInitiate[3]);
		TriggerTimerHoming(projectile);
	}
	else
	{
		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_QUIBAI, weapon, "rockettrail_airstrike_line");
		//no enemy, fire projectile blindly!, maybe itll hit an enemy!
	}
}
public Action FireAnotherShotQuibai(Handle timer, DataPack pack)
{
	pack.Reset();
	int Client = EntRefToEntIndex(pack.ReadCell());
	int Weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Client) && IsValidEntity(Weapon))
	{
		Weapon_ark_QuibaiRangedAttack(Client, Weapon, true);
	}
	return Plugin_Stop;
}
public void Weapon_Quibai_Ability(int client, int weapon, bool crit, int slot)
{
	QuibaiAbilityM2(client, weapon, slot);
}

static void QuibaiAbilityM2(int client, int weapon, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
	}
	else
	{
		if(i_LappLandHitsDone[client] >= QUIBAI_MAX_HITS_NEEDED)
		{
			float flPos[3]; // original
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			
					
			int particler = ParticleEffectAt(flPos, "utaunt_snowring_space_parent", 25.0);
					
			SetParent(client, particler);
			EmitSoundToAll(SOUND_LAPPLAND_ABILITY, client, _, 90, _, 1.0);
			i_LappLandHitsDone[client] = 0;
			MakePlayerGiveResponseVoice(client, 1); //haha!
			f_LappLandAbilityActive[client] = GetGameTime() + 25.0;
			i_QuibaiAttacksMade[client] = 0;
			ChangeAttackspeedQuibai(client,weapon);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
	}
}

void ChangeAttackspeedQuibai(int client, int weapon)
{
	if(weapon < 1)
		return;

	if(f_LappLandAbilityActive[client] > GetGameTime())
	{
		i_QuibaiAttacksMade[client]++;
		if(i_QuibaiAttacksMade[client] > 15)
		{
			i_QuibaiAttacksMade[client] = 15;
		}
		//too much attackspeed....
		Attributes_Set(weapon, 396, QuibaiAttackSpeed(i_QuibaiAttacksMade[client]));
		Attributes_Set(weapon, 1, QuibaiAttackSpeed(i_QuibaiAttacksMade[client] / 2));
	}
	else
	{
		i_QuibaiAttacksMade[client] = 0;
		Attributes_Set(weapon, 396, QuibaiAttackSpeed(i_QuibaiAttacksMade[client]));
		Attributes_Set(weapon, 1, QuibaiAttackSpeed(i_QuibaiAttacksMade[client] / 2));
	}
}



float QuibaiAttackSpeed(int number_bef)
{
	float Number = 1.0;
	if(number_bef == 0)
	{
		return Number;
	}
	Number -= (0.03 * number_bef);

	return Number;
}


public void Ark_Melee_Empower_State(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		if(Ark_Hits[client] >= 15)
		{
			Ark_Hits[client] -= 15;
			Rogue_OnAbilityUse(client, weapon);
			//duration of the domain should be included.
			Ability_Apply_Cooldown(client, slot, 60.0 + 15.0); //Semi long cooldown, this is a strong buff.
			Ability_Apply_Cooldown(client, 2, 1.0);

			Duration[client] = GetGameTime() + 15.0; //Just a test.
			GetClientAbsOrigin(client, fl_AbilityVectorData[client]);

			//EmitSoundToAll(EMPOWER_SOUND, client, SNDCHAN_STATIC, 90, _, 0.6);
			weapon_id[client] = EntIndexToEntRef(weapon);
			CreateTimer(0.4, ArkDomainLogic, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			spawnRing_Vectors(fl_AbilityVectorData[client], 300.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", /*R*/204, /*G*/0, /*B*/255, /*alpha*/50, 1, /*duration*/ 0.5, 20.0, 5.0, 1, _,client);
			TE_Particle("merasmus_object_spawn", fl_AbilityVectorData[client], NULL_VECTOR, NULL_VECTOR, client, _, _, _, _, _, _, _, _, _, 0.0, client);
			ClientCommand(client, "playgamesound misc/outer_space_transition_01.wav");
			ClientCommand(client, "playgamesound mvm/mvm_deploy_giant.wav");
			ApplyStatusEffect(client, client, "Empowering Domain Hidden", 0.5);
			ApplyStatusEffect(client, client, "Empowering Domain", 0.5);
			
			spawnRing(client, EMPOWER_RANGE * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, /*R*/0, /*G*/255, /*B*/255, 125, 30, 0.51, EMPOWER_WIDTH, 6.0, 10);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not enough charge");
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}


static Action ArkDomainLogic(Handle ringTracker, int client)
{
	if (IsValidClient(client) && Duration[client] > GetGameTime())
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(EntRefToEntIndex(weapon_id[client]) == ActiveWeapon)
		{
			spawnRing_Vectors(fl_AbilityVectorData[client], 300.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", /*R*/204, /*G*/0, /*B*/255, /*alpha*/50, 1, /*duration*/ 0.5, 20.0, 5.0, 1, _,client);
			b_NpcIsTeamkiller[client] = true;
			b_AllowSelfTarget[client] = true;
			Explode_Logic_Custom(0.0, client, client, ActiveWeapon, fl_AbilityVectorData[client], 300.0, _, _, false, 99, _, _, ArkAreaBuffAbility);
			b_NpcIsTeamkiller[client] = false;
			b_AllowSelfTarget[client] = false;
		}
		else
		{
			return Plugin_Stop;
		}

	}
	else
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

void ArkAreaBuffAbility(int attacker, int victim, float &damage, int weapon)
{
	if(attacker == victim)
	{
		ApplyStatusEffect(attacker, attacker, "Empowering Domain Hidden", 0.5);
		ApplyStatusEffect(attacker, attacker, "Empowering Domain", 0.5);
	}
}