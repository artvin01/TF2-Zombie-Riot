#pragma semicolon 1
#pragma newdecls required

static Handle h_Red_Mist_Timer[MAXPLAYERS] = {null, ...};
static Handle RM_Lastman_Timer[MAXPLAYERS] = {null, ...};
static bool counter_timer_exists[MAXPLAYERS];
static bool savagery_timer_exists[MAXPLAYERS];
static bool Ego_Active[MAXPLAYERS];
static bool Special_Active[MAXPLAYERS];
static bool strength_active_1[MAXPLAYERS] = false;
static bool strength_active_2[MAXPLAYERS] = false;
static bool strength_active_3[MAXPLAYERS] = false;
static bool lms_buffs_given[MAXPLAYERS] = false;
static bool Prey_Mark_Cooldown[MAXPLAYERS];
static bool Ego_Cooldown_given[MAXPLAYERS];
static bool Onrush_Is_In_Dash[MAXPLAYERS];
static bool RM_Lastman_Buffs_applied[MAXPLAYERS] = false;
static int WeaponLevel[MAXPLAYERS];
static int ref_MeleeWeapon[MAXPLAYERS];
static int last_recorded_pap[MAXPLAYERS] = {0, ...};
static int current_card_selection[MAXPLAYERS] = {0, ...};
static int current_abno_card_selection[MAXPLAYERS] = {0, ...};
static int counter_dice_amount[MAXPLAYERS] = {15, ...};
static int absorption_counter[MAXPLAYERS] = {0, ...};
static int Strenght_Amount[MAXPLAYERS];
//static int Endurance_Amount[MAXPLAYERS]; only a single card gives this, not worth it making it its own thing
static int Abno_Pages[MAXPLAYERS];
static int Deep_Wound_Counter[MAXPLAYERS];
static int Ego_Energy[MAXPLAYERS];
static int redashes[MAXPLAYERS];
static float redash_cooldown[MAXPLAYERS];
static float Special_Cooldowns[MAXPLAYERS][4]; //IT WORKS :D, who needs premade cooldowns when you can make your own
static float Strenght_boost[MAXPLAYERS];
static float Burst_Damage_Taken[MAXPLAYERS];
static float Onrush_Redash_Window[MAXPLAYERS];
//flags or smth, black magic if you ask me
#define ABNORMPAGE_PREY             (1 << 0)
#define ABNORMPAGE_VENGEANCE        (1 << 1)
#define ABNORMPAGE_SAVAGERY         (1 << 2)
#define ABNORMPAGE_ROLE_OF_WOLF     (1 << 3)
#define ABNORMPAGE_ABSORPTION       (1 << 4)
#define ABNORMPAGE_MOSB             (1 << 5)
#define ABNORMPAGE_VAMPIRISM        (1 << 6)
#define ABNORMPAGE_DEEP_WOUND       (1 << 7)

public void Enable_Red_Mist(int client, int weapon)
{
	DataPack pack = new DataPack();
	if(h_Red_Mist_Timer[client] != null)
	{
		if(IsValidHandle(h_Red_Mist_Timer[client]))
			delete h_Red_Mist_Timer[client];
		h_Red_Mist_Timer[client] = null;
	}
	WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
	ref_MeleeWeapon[client] = EntIndexToEntRef(weapon);
	h_Red_Mist_Timer[client] = CreateDataTimer(0.1, Timer_Red_Mist, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	PrecacheRedMistMusic();
	counter_dice_amount[client] = 15;
	savagery_timer_exists[client] = false;
	Prey_Mark_Cooldown[client] = true;
	Ego_Cooldown_given[client] = false;
	//Heartbroken_ApplyCoffinBack(client, false);
}

static Action Timer_Red_Mist(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientindx = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	if(Abno_Pages[client] & ABNORMPAGE_VENGEANCE)
	{
		Vengeance_Logic(client);
	}
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		//Heartbroken_ApplyCoffinBack(clientindx, true);
		h_Red_Mist_Timer[clientindx] = null;
		return Plugin_Stop;
	}
	if(Ego_Active[client])
	{
		PrintToChatAll("ego energy [%d]", Ego_Energy[client]);
		Ego_Energy[client] -= 10;
	}
	if(Ego_Energy[client] <= 0)//if ego isnt active
	{
		Ego_Active[client] = false;
		Ego_Energy[client] = 0;
		if(!Ego_Cooldown_given[client])//give cooldown only once after it ends
		{
			RemoveSpecificBuff(client, "Ego Manifestation");
			Special_Cooldowns[client][2] = GetGameTime() + 15.00;
			ClientCommand(client, "playgamesound weapons/buffed_off.wav");
			Ego_Cooldown_given[client] = true;
			current_card_selection[client] = 2;
			Special_Active[client] = false;
		}
	}
	if(Onrush_Redash_Window[client] < GetGameTime() && redashes[client] > 0)
	{
		redashes[client] = 0;
		redash_cooldown[client] = GetGameTime() + 7.5;
		//Ability_Apply_Cooldown(client, 2, 7.5);
		Onrush_Is_In_Dash[client] = false;
		PrintToChatAll("redash window expired");
	}
	if(LastMann)
	{
		if(!RM_Lastman_Buffs_applied[client])
		{
			Strenght_Amount[client] += 10;
			RM_Lastman_Timer[client] = CreateTimer(15.0, MOSB_Lastman_Execution, client);
			RM_Lastman_Buffs_applied[client] = true;
		}
	}
	if(!LastMann)
	{
		if(RM_Lastman_Buffs_applied[client])
		{
			Strenght_Amount[client] -= 10; //if it isnt lms but buffs were applied. aka lms ended, remove buffs and kill death timer
			delete RM_Lastman_Timer[client];
			RM_Lastman_Buffs_applied[client] = false;
		}
	}
	
	b_IsCannibal[client] = true;
	//HeartBroken_HUD(client);
	return Plugin_Continue;

}

void Red_Mist_Horizontal_Slash_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	if(Special_Active[client] && current_card_selection[client] == 3)
	{
		CustomMeleeRange = MELEE_RANGE * 1.8;
		CustomMeleeWide = MELEE_BOUNDS * 5.0;
		enemies_hit_aoe = 25; //lol
		ignore_walls = false;
	}
	else
	{
		CustomMeleeRange = MELEE_RANGE;
		CustomMeleeWide = MELEE_BOUNDS;
		enemies_hit_aoe = 1;
		ignore_walls = false;
	}
	
}

public void Red_Mist_OnMapStart()
{
    //precache stuff
	Zero(Abno_Pages);
	Zero2(Special_Cooldowns);
	Zero(strength_active_1);
	Zero(strength_active_2);
	Zero(strength_active_3);
	Zero(Strenght_Amount);
	Zero(absorption_counter);
	Zero(Deep_Wound_Counter);
	Zero(Burst_Damage_Taken);
	Zero(current_abno_card_selection);
	Zero(current_card_selection);
	Zero(last_recorded_pap);
	Zero(counter_timer_exists);
	Zero(savagery_timer_exists);
	Zero(lms_buffs_given);
	Zero(Ego_Active);
	Zero(Special_Active);
	Zero(Prey_Mark_Cooldown);
	Zero(redashes);
	Zero(Onrush_Is_In_Dash);
	Zero(Onrush_Redash_Window);
}

public void Vengeance_Logic(int client)
{
	
	float MaxHealth = float(SDKCall_GetMaxHealth(client));
	int Health = GetEntProp(client, Prop_Send, "m_iHealth");
	
	if(Health < MaxHealth / 2 && !strength_active_1[client])
	{
		Strenght_Amount[client] += 1;
		strength_active_1[client] = true;
	}
	if(Health < MaxHealth / 3 && !strength_active_2[client])
	{
		Strenght_Amount[client] += 2;
		strength_active_2[client] = true;
	}
	if(Health < MaxHealth / 4 && !strength_active_3[client])
	{
		Strenght_Amount[client] += 4;
		strength_active_3[client] = true;
	}

	if(Health > MaxHealth / 2 && strength_active_1[client])
	{
		Strenght_Amount[client] -= 1;
		strength_active_1[client] = false;
	}
	if(Health > MaxHealth / 3 && strength_active_2[client])
	{
		Strenght_Amount[client] -= 2;
		strength_active_2[client] = false;
	}
	if(Health > MaxHealth / 4 && strength_active_3[client])
	{
		Strenght_Amount[client] -= 4;
		strength_active_3[client] = false;
	}

	//a bit convoluted but with this each boost can only trigger once, same with removal of it, soooo it should never go above the cap or below 0(hopefully)
}

void PrecacheRedMistMusic()
{
	if(!Precached)
	{
        //TODO
		PrecacheSoundCustom("#zombiesurvival/red_mist.mp3",_,1);
		Precached = true;
	}
}

public void Red_Mist_OnTakeDamage_Take(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	
	if(Abno_Pages[victim] & ABNORMPAGE_SAVAGERY)
	{
		float MaxHealth = float(SDKCall_GetMaxHealth(victim));
		Burst_Damage_Taken[victim] += damage;
		PrintToChat(victim, "damage taken: [%.1f]", Burst_Damage_Taken[victim]);
		if(Burst_Damage_Taken[victim] > MaxHealth / 2)
		{
			ApplyTempAttrib(equipped_weapon, 206, 0.5, 4.0);
			ApplyTempAttrib(equipped_weapon, 205, 0.5, 4.0);
			PrintToChat(victim, "damage res activated");
			//resistance for both melee and ranged for 4 seconds if you took more than 50% max hp in 2 seconds
			//give it a nice sound
		}
		if(!savagery_timer_exists[victim])
		{
			CreateTimer(2.0, Savagery_Reset_damage, victim);
			PrintToChat(victim, "dmg timer started");
			savagery_timer_exists[victim] = true;
		}
	}
	

	int buttons = GetClientButtons(victim);
	float RMC_damage_cap = 0.0;
	if(!(buttons & IN_ATTACK)) //only counter if not attacking
	{
		if(Abno_Pages[victim] & ABNORMPAGE_ROLE_OF_WOLF)
		{
			RMC_damage_cap = 100.0 * (WeaponLevel[victim] + 1);
		}
		else
		{
			RMC_damage_cap = 50.0 * (WeaponLevel[victim] + 1);
		}
		
		if(damage > RMC_damage_cap || counter_dice_amount[victim] <= 0)
		{
			if(!counter_timer_exists[victim])
			{
				CreateTimer(10.0, Timer_RM_CD_Restore, victim);
				counter_dice_amount[victim] = 0;
				PrintToChat(victim, "damage taken: [%.1f]", damage);
				PrintToChatAll("dice broke");
				counter_timer_exists[victim] = true;
				//break counter dice
				//give it some nice breaking sound
			}
		}
		else //counter normally
		{
			float CounterDamage = 65.0;
			CounterDamage *= WeaponDamageAttributeMultipliers(equipped_weapon,_,victim);
			CounterDamage *= 0.5; //1-1 swing damage is too strong
			static float angles[3];
			GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			static float Entity_Position[3];
			WorldSpaceCenter(attacker, Entity_Position );
			float ReflectPosVec[3]; CalculateDamageForce(vecForward, 10000.0, ReflectPosVec);
			DataPack pack = new DataPack();
			pack.WriteCell(EntIndexToEntRef(attacker));
			pack.WriteCell(EntIndexToEntRef(victim));
			pack.WriteCell(EntIndexToEntRef(victim));
			pack.WriteFloat(CounterDamage);
			pack.WriteCell(DMG_CLUB);
			pack.WriteCell(EntIndexToEntRef(equipped_weapon));
			pack.WriteFloat(ReflectPosVec[0]);
			pack.WriteFloat(ReflectPosVec[1]);
			pack.WriteFloat(ReflectPosVec[2]);
			pack.WriteFloat(Entity_Position[0]);
			pack.WriteFloat(Entity_Position[1]);
			pack.WriteFloat(Entity_Position[2]);
			pack.WriteCell(ZR_DAMAGE_REFLECT_LOGIC);
			RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
			damage *= 0.5;
			PrintToChatAll("countered");
			counter_dice_amount[victim] -= 1;
		}	
	}
	if(LastMann)
	{
		if(Abno_Pages[victim] & ABNORMPAGE_MOSB)
		{
			damage *= 0.5;
		}
	}

}

public Action Timer_RM_CD_Restore(Handle timer, int client)
{
	if(Abno_Pages[client] & ABNORMPAGE_ROLE_OF_WOLF)
	{
		counter_dice_amount[client] = 30;
	}
	else
	{
		counter_dice_amount[client] = 15;
	}
	counter_timer_exists[client] = false;
	PrintToChatAll("dice Recovered");
	return Plugin_Handled;
}
public Action Savagery_Reset_damage(Handle timer, int client)
{
	PrintToChat(client, "dmg burst timer");
	Burst_Damage_Taken[client] = 0.0;
	savagery_timer_exists[client] = false;
	return Plugin_Handled;
}
public Action Absorption_Remove_Strength(Handle timer, int client)
{
	Strenght_Amount[client] -= 1;
	PrintToChat(client, "Absorption strenght removed");
	return Plugin_Handled;
}
public Action RM_Prey_Cooldown(Handle timer, int client)
{
	Prey_Mark_Cooldown[client] = true;
	return Plugin_Handled;
}
public Action UnFreeze_Onrush(Handle timer, int client)
{
	SetEntityMoveType(client, MOVETYPE_WALK);
	return Plugin_Handled;
}
public Action MOSB_Lastman_Execution(Handle timer, int client)
{
	//kill client
	return Plugin_Handled;
}

public void Red_Mist_OnTakeDamage_Deal(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	if(Onrush_Is_In_Dash[attacker])
	{
		Onrush_Is_In_Dash[attacker] = false;
		SetEntityMoveType(attacker, MOVETYPE_NONE);
		CreateTimer(0.5, UnFreeze_Onrush, attacker);
		ApplyTempAttrib(attacker, 206, 0.5, 0.5);
		ApplyTempAttrib(attacker, 205, 0.5, 0.5);
	}
	Strenght_boost[attacker] = 1.0 + (0.05 * Strenght_Amount[attacker]);
	damage *= Strenght_boost[attacker];

	if(Abno_Pages[attacker] & ABNORMPAGE_DEEP_WOUND)
	{
		Deep_Wound_Counter[attacker] += 1;
		if(Deep_Wound_Counter[attacker] >= 5)
		{
			StartBleedingTimer(victim, attacker, damage / 8, 20, weapon, DMG_CLUB);
			Deep_Wound_Counter[attacker] = 0;
		}
	}
	if(Abno_Pages[attacker] & ABNORMPAGE_VAMPIRISM)
	{
		float HealByThis = (7.5 * WeaponLevel[attacker]);
		HealEntityGlobal(attacker, attacker, HealByThis, 1.0, 2.0, HEAL_SELFHEAL);
	}
	if(Abno_Pages[attacker] & ABNORMPAGE_PREY)
	{
		PrintToChatAll("prey code works");
		if(Prey_Mark_Cooldown[attacker])//if cooldown is over
		{
			PrintToChatAll("applied mark");
			ApplyStatusEffect(attacker, victim, "Mark Of Prey", 30.0);
			Prey_Mark_Cooldown[attacker] = false;
			EmitSoundToClient(attacker, "weapons/samurai/tf_marked_for_death_indicator.wav", attacker, _, 70, _, 1.0, 60);
			//ClientCommand(attacker, "playgamesound weapons/samurai/tf_marked_for_death_indicator.wav");
			CreateTimer(15.0, RM_Prey_Cooldown, attacker);
		}
		if(HasSpecificBuff(victim, "Mark Of Prey"))
		{
			EmitSoundToClient(attacker, "playgamesound weapons/samurai/tf_marked_for_death_impact_03.wav", attacker, _, 70, _, 1.0, 60);
			//ClientCommand(attacker, "playgamesound weapons/samurai/tf_marked_for_death_impact_03.wav");
			PrintToChatAll("enemy debuffed");
			if(b_thisNpcIsABoss[victim])
			{
				damage *= 1.35;
			}	
			else if(b_thisNpcIsARaid[victim])
			{
				damage *= 1.25;
			}
			else
			{
				damage *= 1.5;
			}	
		}
	}
	
	if(Special_Active[attacker])
	{
		if(current_card_selection[attacker] == 1)//vertical slash
		{
			damage *= 25.0;
			Special_Active[attacker] = false;
			Special_Cooldowns[attacker][1] = GetGameTime() + 5.00;
			return;
		}
		if(current_card_selection[attacker] == 3)//horizontal slash
		{
			damage *= 5.0;
			//just temp stuff so compiler doesn't bitch, actual values are in the void above
			//float RangeDo;
			//float RangeDo2;
			//bool invalid1;
			//int invalid2;
			//Red_Mist_Horizontal_Slash_DoSwingTrace(attacker, RangeDo, RangeDo2, invalid1, invalid2);
			//Special_Active[attacker] = false;
			//Special_Cooldowns[attacker][3] = GetGameTime() + 10.00;
			return;
		}
	}
	if(Ego_Active[attacker])
	{
		Ego_Energy[attacker] += 75;
		if(Ego_Energy[attacker] > 1000)
		{
			Ego_Energy[attacker] = 1000;
		}	
	}

}

public void Red_Mist_On_Kill(int victim, int killer, int weapon)
{
	if(Abno_Pages[killer] & ABNORMPAGE_ABSORPTION)
	{
		PrintToChatAll("absorption works");
		float MaxHealth = float(SDKCall_GetMaxHealth(killer));
		float HealByThis = (MaxHealth * 0.05);
		HealEntityGlobal(killer, killer, HealByThis, 1.0, 2.0, HEAL_SELFHEAL);
		absorption_counter[killer] += 1;
		PrintToChat(killer, "Absorption heal triggered");
		if(absorption_counter[killer] >= 4)
		{
			absorption_counter[killer] = 0;
			Strenght_Amount[killer] += 1;
			PrintToChat(killer, "Absorption strenght trigered");
			CreateTimer(15.0, Absorption_Remove_Strength, killer);
		}
	}
	if(HasSpecificBuff(victim, "Mark Of Prey"))
	{
		float MaxHealth = float(SDKCall_GetMaxHealth(killer));
		HealEntityGlobal(killer, killer, MaxHealth * 0.2, 1.0, 2.0, HEAL_SELFHEAL);
		PrintToChatAll("Marked Enemy Died");
	}
}

public void Red_Mist_Main_Attack(int client, int weapon)
{
	if(Special_Active[client])
	{
		PrintToChatAll("Special attack");
		if(current_card_selection[client] == 1)//vertical
		{
			//animation here
		}
		if(current_card_selection[client] == 2)//ego
		{
			if(!Ego_Active[client])
			{
				Ego_Energy[client] = 1000;
				Ego_Active[client] = true;
				Ego_Cooldown_given[client] = false;
				Special_Cooldowns[client][2] = GetGameTime() + 999.00;
				ApplyStatusEffect(client, client, "Ego Manifestation", 9999.0);
				ClientCommand(client, "playgamesound weapons/buffed_on.wav");
				ClientCommand(client, "playgamesound weapons/debris4.wav");
				Special_Active[client] = false;
			}
			//Special_Cooldowns[client][2] = GetGameTime() + 20.00;
		}
		if(current_card_selection[client] == 3)//horizontal
		{
			
			Special_Active[client] = false;
			Special_Cooldowns[client][3] = GetGameTime() + 10.00;
		}
	}
	else
	{
		float attackspeed = Attributes_Get(weapon, 6, 1.0); //thanks judgement of iberia :D
		if(!b_WeaponAttackSpeedModified[weapon]) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
		{
			b_WeaponAttackSpeedModified[weapon] = true;
			attackspeed = (attackspeed * 0.25);
			Attributes_Set(weapon, 6, attackspeed);
		}
		else
		{
			b_WeaponAttackSpeedModified[weapon] = false;
			attackspeed = (attackspeed / 0.25);
			Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
		}
		PrintToChatAll("Strength Amount [%d]", Strenght_Amount[client]);
	}
	float RangeDo;
	float RangeDo2;
	bool invalid1;
	int invalid2;
	Red_Mist_Horizontal_Slash_DoSwingTrace(client, RangeDo, RangeDo2, invalid1, invalid2);//here so it checks the attack type each attack, so after using 3rd special attack it resets back to base attacks
}

public void Red_Mist_Onrush(int client, int weapon)
{
	if(redashes[client] >= 5)//allow for 3 dashes
	{
		redash_cooldown[client] = GetGameTime() + 7.5;
		Ability_Apply_Cooldown(client, 2, 7.5);
		PrintToChatAll("too many redashes");
		redashes[client] = 0;
		Onrush_Is_In_Dash[client] = false;
		return;
	}
	if(redash_cooldown[client] > GetGameTime())
	//if(Ability_Check_Cooldown(client, 2) > 0.0)
	{
		float Ability_CD = redash_cooldown[client] - GetGameTime();

		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	if(Onrush_Is_In_Dash[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}

	Handle swingTrace;
	b_LagCompNPC_No_Layers = true;
	float vecSwingForward[3];
	StartLagCompensation_Base_Boss(client);
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 250.0, false, 35.0, true); //infinite range, and ignore walls!
	FinishLagCompensation_Base_boss();

	int target = TR_GetEntityIndex(swingTrace);
	delete swingTrace;
	if(!IsValidEnemy(client, target, true))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	if(redashes[client] < 5)
	{
		redashes[client] += 1;
	}
	Onrush_Is_In_Dash[client] = true;
	Onrush_Redash_Window[client] = GetGameTime() + 2.5;
	SetEntityMoveType(client, MOVETYPE_WALK);
	TF2_AddCondition(client, TFCond_LostFooting, 0.35);
	TF2_AddCondition(client, TFCond_AirCurrent, 0.35);
	ApplyStatusEffect(client, client, "Intangible", 0.3);
	//ApplyStatusEffect(client, client, "Touch Ingored", 0.3);

	float MePos[3];
	WorldSpaceCenter(client, MePos);
	float TargPos[3];
	WorldSpaceCenter(target, TargPos);
	float flPos[3];
	MakeVectorFromPoints(MePos, TargPos, flPos);
	GetVectorAngles(flPos, flPos);
	static float velocity[3];
	GetAngleVectors(flPos, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 900.0;
	ScaleVector(velocity, knockback);
	velocity[2] += 150.0;    // a little boost to alleviate arcing issues

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}

public void Red_Mist_Special_Cycle(int client, int weapon)//for cycling through all the special attacks
{
	//for pap buffs, only trigger once a pap and then never again until new pap
	if(last_recorded_pap[client] < WeaponLevel[client])
    {
		if(current_abno_card_selection[client] == 0 || current_abno_card_selection[client] == 2 )
		{
			if(last_recorded_pap[client] == 1)
			{
				PrintToChat(client, "%t", "Prey");
			}
			if(last_recorded_pap[client] == 2)
			{
				PrintToChat(client, "%t", "Claws of Savagery");
			}
			if(last_recorded_pap[client] == 3)
			{
				PrintToChat(client, "%t", "Absorption");
			}
			if(last_recorded_pap[client] == 4)
			{
				PrintToChat(client, "%t", "Vampirism");
			}
			current_abno_card_selection[client] = 1;

		}
		else if(current_abno_card_selection[client] == 1)
		{
			current_abno_card_selection[client] = 2;
			if(last_recorded_pap[client] == 1)
			{
				PrintToChat(client, "%t", "Vengeance");
			}
			if(last_recorded_pap[client] == 2)
			{
				PrintToChat(client, "%t", "The Role of the Wolf");
			}
			if(last_recorded_pap[client] == 3)
			{
				PrintToChat(client, "%t", "Mountain of Corpses");
			}
			if(last_recorded_pap[client] == 4)
			{
				PrintToChat(client, "%t", "Deep Wound");
			}
		}
		PrintToChat(client, "Current abno Card [%d]", current_abno_card_selection[client]);
			
	}
	else //normal function
	{
		if(Special_Active[client])
		{
			return;
		}
		else
		{
			if(current_card_selection[client] == 0) //could be done better but there is only gonna be 3 options so it should be fine
			{
				current_card_selection[client] = 1;// vertical slash
			}
			else if(current_card_selection[client] == 1) //if ego active skip 2 and go to 3, else stay go to 2
			{
				if(!Ego_Active[client] && WeaponLevel[client] >= 3)
				{
					current_card_selection[client] = 2;//ego
				}
				else if(Ego_Active[client] && WeaponLevel[client] >= 3)
				{
					current_card_selection[client] = 3;//horizontal slash
				}
			}
			else if(current_card_selection[client] == 2) // if ego active go to 3, otherwise skip it and go back to 1
			{
				if(Ego_Active[client] && WeaponLevel[client] >= 3)
				{
					current_card_selection[client] = 3;
				}
				else
				{
					current_card_selection[client] = 1;
				}
			}
			else if(current_card_selection[client] == 3)
			{
				current_card_selection[client] = 1;
			}	
			PrintToChat(client, "Current Card [%d]", current_card_selection[client]);
		}
		
	}
	
	//PrintToChatAll("sub weapon usage m2");
}

public void Red_Mist_Special(int client, int weapon)//for activating currently selected special
{
    if(last_recorded_pap[client] < WeaponLevel[client]) //abno page picking
    {
		switch (last_recorded_pap[client])//checks current pap
		{
			case 0://abno pages for 1st pap
			{
				if(current_abno_card_selection[client] == 1)
				{
					Abno_Pages[client] |= ABNORMPAGE_PREY;
					PrintToChatAll("pray 1");
				}
				else if(current_abno_card_selection[client] == 2)
				{
					Abno_Pages[client] |= ABNORMPAGE_VENGEANCE;
					PrintToChatAll("vengeance 2");
				}
				if(current_abno_card_selection[client] != 0)
				{
					last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
					current_abno_card_selection[client] = 0; //reset to 0 so you have to cycle atleast once before picking a card
				}
			}
			case 1://abno pages for 2nd pap
			{
				if(current_abno_card_selection[client] == 1)
				{
					Abno_Pages[client] |= ABNORMPAGE_SAVAGERY;
					PrintToChatAll("savagery 1");
				}
				else if(current_abno_card_selection[client] == 2)
				{
					Abno_Pages[client] |= ABNORMPAGE_ROLE_OF_WOLF;
					PrintToChatAll("wolf 2");
				}
				if(current_abno_card_selection[client] != 0)
				{
					last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
					current_abno_card_selection[client] = 0; //reset to 0 so you have to cycle atleast once before picking a card
				}
			}
			case 2://abno pages for 3rd pap
			{
				if(current_abno_card_selection[client] == 1)
				{
					Abno_Pages[client] |= ABNORMPAGE_ABSORPTION;
					PrintToChatAll("absorption 1");
				}
				else if(current_abno_card_selection[client] == 2)
				{
					Abno_Pages[client] |= ABNORMPAGE_MOSB;
					PrintToChatAll("mosb 2");
				}
				if(current_abno_card_selection[client] != 0)
				{
					last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
					current_abno_card_selection[client] = 0; //reset to 0 so you have to cycle atleast once before picking a card
				}
			}
			case 3://abno pages for 4th pap
			{
				if(current_abno_card_selection[client] == 1)
				{
					Abno_Pages[client] |= ABNORMPAGE_VAMPIRISM;
					PrintToChatAll("vampirism 1");
				}
				else if(current_abno_card_selection[client] == 2)
				{
					Abno_Pages[client] |= ABNORMPAGE_DEEP_WOUND;
					PrintToChatAll("deep wound 2");
				}
				if(current_abno_card_selection[client] != 0)
				{
					last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
					current_abno_card_selection[client] = 0; //reset to 0 so you have to cycle atleast once before picking a card
				}
			}
		}
		PrintToChat(client, "Current abno Card [%d]", current_abno_card_selection[client]);
        //do card picking code here
        //ABNORMPAGE[entity] |= ABNORMPAGE_PREY;
        //ABNORMPAGE[entity] |= ABNORM_PAGE_2;
        
        //last_recorded_pap[client] = WeaponLevel[client];
    }
	else //normal function
	{
		if(Special_Active[client])
		{
			Special_Active[client] = false; //disable special attack
			PrintToChatAll("Special off");
		}
		else
		{
			if(current_card_selection[client] == 1 && Special_Cooldowns[client][1] < GetGameTime())
			{
				Special_Active[client] = true;
				PrintToChatAll("Special 1 on");
			}
			else
			{
				float Ability_CD = Special_Cooldowns[client][1] - GetGameTime();
				if(Ability_CD < 0.0)
					Ability_CD = 0.0;
				ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			}
			if(current_card_selection[client] == 2 && Special_Cooldowns[client][2] < GetGameTime())
			{
				Special_Active[client] = true;
				PrintToChatAll("Special 2 on");
			}
			else
			{
				float Ability_CD = Special_Cooldowns[client][2] - GetGameTime();
				if(Ability_CD < 0.0)
					Ability_CD = 0.0;
				ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			}
			if(current_card_selection[client] == 3 && Special_Cooldowns[client][3] < GetGameTime())
			{
				Special_Active[client] = true;
				PrintToChatAll("Special 3 on");
			}
			else
			{
				float Ability_CD = Special_Cooldowns[client][3] - GetGameTime();
				if(Ability_CD < 0.0)
					Ability_CD = 0.0;
				ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			}
			
			
		}
		

		PrintToChat(client, "Current Card [%d]", current_card_selection[client]);
	}
}