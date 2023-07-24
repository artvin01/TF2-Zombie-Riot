#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <tf2_stocks>

static const char ComboName[][] =
{
	"L",
	"R",
	"L'",
	"R'",
	"L,",
	"R,"
};

#define NL	0	// Netural M1
#define NR	1	// Netural M2
#define UL	2	// Air M1
#define UR	3	// Air M2
#define DL	4	// Ducking M1
#define DR	5	// Ducking M2

#define NL_1	0
#define NR_1	1
#define UL_1	2
#define UR_1	3
#define DL_1	4
#define DR_1	5

#define NL_2	0
#define NR_2	6
#define UL_2	12
#define UR_2	18
#define DL_2	24
#define DR_2	30

#define NL_3	0
#define NR_3	36
#define UL_3	72
#define UR_3	108
#define DL_3	144
#define DR_3	180

static PrivateForward ComboList;  
static int CurrentCombo[MAXTF2PLAYERS];
static int ComboCount[MAXTF2PLAYERS];
static int LastCombos[MAXTF2PLAYERS][10];
static Handle ComboTimer[MAXTF2PLAYERS];
static bool ComboBlockM1[MAXTF2PLAYERS];

static void ShowCombo(int client)
{
	if(ComboCount[client] > 1)
	{
		PrintCenterText(client, "%s + %s +", ComboName[CurrentCombo[client] % NR_2], ComboName[CurrentCombo[client] / NR_2]);
	}
	else
	{
		PrintCenterText(client, "%s +   +", ComboName[CurrentCombo[client]]);
	}
}

static int GetStaleAmount(int client, int combo)
{
	int amount;
	for(int i; i < sizeof(LastCombos[]); i++)
	{
		if(LastCombos[client][i] == combo)
			amount++;
	}
	return amount;
}

static int GetComboType(int buttons, bool right)
{
	bool air = view_as<bool>(buttons & IN_JUMP);
	bool duck = view_as<bool>(buttons & IN_DUCK);

	if(!(air ^ duck))
		return right ? NR : NL;

	if(air)
		return right ? UR : UL;
	
	return right ? DR : DL;
}

public void Weapon_StreetFighter(int client, int weapon, bool crit, int slot)
{
	if(!ComboBlockM1[client] || slot != 1)
	{
		StreetFighter(client, weapon, slot, 0, 0);
	}
	if(slot == 1)
	{	
		ComboBlockM1[client] = true;
	}
}

public void Weapon_StreetFighterAllowM1(int client, int weapon, bool crit, int slot)
{
	StreetFighter(client, weapon, slot, 0, 1);
	ComboBlockM1[client] = false;
}

public void Weapon_StreetFighterAllowM1Pap(int client, int weapon, bool crit, int slot)
{
	StreetFighter(client, weapon, slot, GetClientButtons(client), 1);
	ComboBlockM1[client] = false;
}

public void Weapon_StreetFighterPap(int client, int weapon, bool crit, int slot)
{
	if(!ComboBlockM1[client] || slot != 1)
	{
		StreetFighter(client, weapon, slot, GetClientButtons(client), 0);
	}
	if(slot == 1)
	{	
		ComboBlockM1[client] = true;
	}
}

static void StreetFighter(int client, int weapon, int slot, int buttons, int CD)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		float cooldown = 0.8 * Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);

		if(ComboCount[client] == 0)
		{
			f_DelayLookingAtHud[client] = GetGameTime() + 2.1;
			if(slot != 1 || !CD)
			{
				CurrentCombo[client] = GetComboType(buttons, slot != 1);
				ComboCount[client] = 1;
				ComboTimer[client] = CreateTimer(2.1, StreetFighter_Timer, client);
			}
			ShowCombo(client);
		}
		else if(ComboCount[client] == 1)
		{
			if(slot != 1 || !CD)
			{
				CurrentCombo[client] += GetComboType(buttons, slot != 1) * NR_2;
				ComboCount[client] = 2;
			}
			ShowCombo(client);
		}
		else if(ComboCount[client] == 2)
		{
			f_DelayLookingAtHud[client] = GetGameTime() + 1.5;
			
			int first = CurrentCombo[client] % NR_2;
			int second = (CurrentCombo[client] % NR_3) / NR_2;
			int third = GetComboType(buttons, slot != 1);
			if(slot != 1 || !CD)
			{
				CurrentCombo[client] += third * NR_3;
				ComboCount[client] = 3;
			}
			if(((slot != 1 || !ComboBlockM1[client]) || CD) && ComboCount[client] == 3)
			{
				if(!ComboList)
				{
					ComboList = new PrivateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_FloatByRef);
					SetupList(ComboList);
				}

				Action action;
				Call_StartForward(ComboList);
				Call_PushCell(client);
				Call_PushCell(weapon);
				Call_PushCell(first);
				Call_PushCell(second);
				Call_PushCell(third);
				Call_PushFloatRef(cooldown);
				Call_Finish(action);
				if(action == Plugin_Continue)
				{
					PrintCenterText(client, "No Effect...");
					ClientCommand(client, "playgamesound ui/message_update.wav");
				}
				else
				{
					Rogue_OnAbilityUse(weapon);
				}

				for(int i = sizeof(LastCombos[]) - 1; i > 0; i--)
				{
					LastCombos[client][i] = LastCombos[client][i - 1];
				}
				LastCombos[client][0] = CurrentCombo[client];

				delete ComboTimer[client];
				CurrentCombo[client] = 0;
				ComboCount[client] = 0;

				Ability_Apply_Cooldown(client, 1, cooldown);
				Ability_Apply_Cooldown(client, 2, cooldown);
				if(slot != 1 || CD)
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + cooldown);
					SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + cooldown);
				}				
			}
		}
	}
}

public Action StreetFighter_Timer(Handle timer, int client)
{
	CurrentCombo[client] = 0;
	ComboCount[client] = 0;
	ComboTimer[client] = null;

	if(IsClientInGame(client))
		PrintCenterText(client, "");
	
	return Plugin_Stop;
}


static void SetupList(PrivateForward pf)
{
	pf.AddFunction(null, SF_TripleAttack);
	pf.AddFunction(null, SF_Block);
	pf.AddFunction(null, SF_MultiAttack);
	pf.AddFunction(null, SF_ToeSmash);
	pf.AddFunction(null, SF_SpeedUp);
	pf.AddFunction(null, SF_JawBreaker);
	pf.AddFunction(null, SF_Charge);
	pf.AddFunction(null, SF_Random);
	pf.AddFunction(null, SF_Stack);
	pf.AddFunction(null, SF_Leach);
	pf.AddFunction(null, SF_HealthShare);
	pf.AddFunction(null, SF_Knockup);
	pf.AddFunction(null, SF_Knockdown);
	pf.AddFunction(null, SF_Ultra);
	pf.AddFunction(null, SF_AOE);
	pf.AddFunction(null, SF_Slap);
}

// L L L
public Action SF_TripleAttack(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == NL && second == NL && third == NL)
	{
		ApplyTempAttrib(entity, 2, 2.0);
		PrintCenterText(client, "Triple Punch!");
		ClientCommand(client, "playgamesound ui/hitsound_retro%d.wav", (GetURandomInt() % 5) + 1);
		cooldown += 0.5;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// X R R
// X R, R
// X R R,
public Action SF_Block(int client, int entity, int first, int second, int third, float &cooldown)
{
	if((second == NR || second == DR) && (third == NR || third == DR) && !(second == DR && third == DR))
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Block...");
			TF2_AddCondition(client, TFCond_DefenseBuffed, 2.0 - (stale * 0.2));
		}
		else
		{
			PrintCenterText(client, "Block!");
			TF2_AddCondition(client, TFCond_DefenseBuffed, 3.0);
		}

		cooldown = 1.5;
		ClientCommand(client, "playgamesound ui/hitsound_vortex%d.wav", (GetURandomInt() % 5) + 1);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// R R L
// R R, L
// R, R L
// R, R, L
public Action SF_MultiAttack(int client, int entity, int first, int second, int third, float &cooldown)
{
	if((first == NR || first == DR) && (second == NR || second == DR) && third == NL)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(LastCombos[client][sizeof(LastCombos[]) - 1] == CurrentCombo[client])
		{
			PrintCenterText(client, "Sugar Coat...");
			ApplyTempAttrib(entity, 2, 1.25);

			ClientCommand(client, "playgamesound ui/hitsound_menu_note7b.wav");
		}
		else if(stale == 9)
		{
			PrintCenterText(client, "Sugar Coat!", stale + 1);
			ApplyTempAttrib(entity, 2, 6.0);

			ClientCommand(client, "playgamesound items/powerup_pickup_knockout_melee_hit.wav");
		}
		else
		{
			PrintCenterText(client, "Sugar Coat");
			ApplyTempAttrib(entity, 2, 1.1 + (0.15 * stale));

			ClientCommand(client, "playgamesound ui/hitsound_menu_note%d.wav", stale + 1);
		}

		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L L L,
// L L, L,
// L' L L,
// L' L, L,
public Action SF_ToeSmash(int client, int entity, int first, int second, int third, float &cooldown)
{
	if((first == UL || first == NL) && (second == NL || second == DL) && third == DL)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale > 1)
		{
			PrintCenterText(client, "Toe Smash...");
			ApplyTempAttrib(entity, 2, 2.0);
			cooldown += 0.5;
		}
		else if(stale)
		{
			PrintCenterText(client, "Toe Smash!");
			ApplyTempAttrib(entity, 2, 3.25);
			cooldown += 0.5;
		}
		else
		{
			PrintCenterText(client, "Toe Smash");
			ApplyTempAttrib(entity, 2, 2.75);
		}

		ClientCommand(client, "playgamesound ui/hitsound_squasher.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L R L
// L' R L
// L R' L
// L' R' L
// L R, L
// L' R, L
public Action SF_SpeedUp(int client, int entity, int first, int second, int third, float &cooldown)
{
	if((first == NL || first == UL) && (second == NR || second == DR || second == UR) && third == NL)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale > 4)
		{
			PrintCenterText(client, "Speed...");
			ApplyTempAttrib(entity, 6, 0.9, 2.0);
		}
		else if(stale)
		{
			PrintCenterText(client, "Speed");
			ApplyTempAttrib(entity, 6, 0.8, 3.0);
		}
		else
		{
			PrintCenterText(client, "Speed!");
			ApplyTempAttrib(entity, 6, 0.75, 6.0);
			
		}

		cooldown = 0.5;
		ClientCommand(client, "playgamesound ui/hitsound_percussion%d.wav", (stale % 5) + 1);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L L L'
// L L' L'
public Action SF_JawBreaker(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == NL && (second == NL || second == UL) && third == UL)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Jaw Breaker...");
			ApplyTempAttrib(entity, 2, 2.0);
		}
		else
		{
			PrintCenterText(client, "Jaw Breaker!");
			ApplyTempAttrib(entity, 2, 3.5);
		}

		cooldown += 0.5;
		ClientCommand(client, "playgamesound ui/item_as_parasite_pickup.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L' L' R
// L L R
// L, L, R
// L' L' R,
// L L R,
// L, L, R,
public Action SF_Charge(int client, int entity, int first, int second, int third, float &cooldown)
{
	if((first == UL || first == NL || first == DL) && first == second && (third == NR || third == DR))
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale > 2)
		{
			PrintCenterText(client, "Battery Charge...");
			ApplyTempAttrib(entity, 2, 1.333, 3.0);
			ClientCommand(client, "playgamesound ui/itemcrate_smash_common.wav");
		}
		else if(stale == 2)
		{
			PrintCenterText(client, "Battery Charge");
			ApplyTempAttrib(entity, 2, 1.5, 3.0);
			ClientCommand(client, "playgamesound ui/itemcrate_smash_common.wav");
		}
		else if(stale == 1)
		{
			PrintCenterText(client, "Battery Charge");
			ApplyTempAttrib(entity, 2, 1.667, 4.0);
			ClientCommand(client, "playgamesound ui/itemcrate_smash_rare.wav");
		}
		else
		{
			PrintCenterText(client, "Battery Charge!");
			ApplyTempAttrib(entity, 2, 2.0, 5.0);
			ClientCommand(client, "playgamesound ui/itemcrate_smash_ultrarare_short.wav");
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// R L L
public Action SF_Random(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == NR && second == NL && third == NL)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Random");
			ApplyTempAttrib(entity, 2, GetURandomFloat() * 4.0);
			cooldown += GetURandomFloat();
		}
		else
		{
			PrintCenterText(client, "Random!");
			ApplyTempAttrib(entity, 2, GetURandomFloat() * 6.0);
			cooldown += GetURandomFloat() - 0.5;
			StartHealingTimer(client, GetURandomFloat(), 2.0, GetURandomInt() % 50);
		}

		ClientCommand(client, "playgamesound ui/killsound_percussion.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// R L R
public Action SF_Stack(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == NR && second == NL && third == NR)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Stack...");
		}
		else
		{
			PrintCenterText(client, "Stack!");

			Attributes_SetMulti(entity, 2, 1.1);
			
			ClientCommand(client, "playgamesound items/powerup_pickup_resistance.wav");
			cooldown += 1.0;
		}

		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L, R' R'
public Action SF_Leach(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == DL && second == UR && third == UR)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Health...");
			StartHealingTimer(client, 0.5, 1.0, 2);
		}
		else
		{
			PrintCenterText(client, "Health!");
			StartHealingTimer(client, 0.1, 1.0, 50, false);
		}

		cooldown += 1.0;
		ClientCommand(client, "playgamesound items/powerup_pickup_vampire.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// R, R' R'
public Action SF_HealthShare(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == DR && second == UR && third == UR)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Rule...");
		}
		else
		{
			PrintCenterText(client, "Rule!");
			TF2_AddCondition(client, TFCond_RadiusHealOnDamage, 3.0);
		}

		cooldown = 3.5;
		TF2_AddCondition(client, TFCond_NoHealingDamageBuff, 3.0);
		ClientCommand(client, "playgamesound items/powerup_pickup_king.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L' R, L'
// L' R L'
public Action SF_Knockup(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == UL && (second == NR || second == DR) && third == UL)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Uppercut...");
		}
		else
		{
			PrintCenterText(client, "Uppercut!");

			Handle swingTrace;
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward);
			
			int target = TR_GetEntityIndex(swingTrace);

			delete swingTrace;
			FinishLagCompensation_Base_boss();
			
			if(target > MaxClients && !b_CannotBeKnockedUp[target])
				SDKHook(target, SDKHook_Think, SF_KnockupThink);
		}

		ClientCommand(client, "playgamesound ui/killsound_beepo.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void SF_KnockupThink(int target)
{
	SDKUnhook(target, SDKHook_Think, SF_KnockupThink);

	float pos[3];
	pos = WorldSpaceCenter(target);
	pos[2] += 100.0;
	PluginBot_Jump(target, pos);
}

// R' R' L
// R' R' L'
// R' R L
// R' R L'
public Action SF_Knockdown(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == UR && (second == UR || second == NR) && (third == NL || third == UL))
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Knock down...");

			Handle swingTrace;
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward);
			
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);

			GetClientEyePosition(client, vecSwingForward);
			if(vecHit[2] > vecSwingForward[2])
			{
				ApplyTempAttrib(entity, 2, 3.0);
				cooldown += 0.5;
			}

			delete swingTrace;
			FinishLagCompensation_Base_boss();
		}
		else
		{
			PrintCenterText(client, "Knock down!");

			Handle swingTrace;
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward);
			
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);

			GetClientEyePosition(client, vecSwingForward);
			if(vecHit[2] > vecSwingForward[2])
			{
				ApplyTempAttrib(entity, 2, 5.0, 2.0);
			}

			delete swingTrace;
			FinishLagCompensation_Base_boss();
		}

		ClientCommand(client, "playgamesound ui/killsound_squasher.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L' L, R'
public Action SF_Ultra(int client, int entity, int first, int second, int third, float &cooldown)
{
	if(first == UL && second == DL && third == UR)
	{
		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "Ultimate...");
			ApplyTempAttrib(entity, 2, 5.0, 4.0);
			ApplyTempAttrib(entity, 6, 3.0, 4.0);
			ClientCommand(client, "playgamesound misc/ks_tier_03.wav");
		}
		else
		{
			PrintCenterText(client, "Ultimate!");
			ApplyTempAttrib(entity, 2, 10.0, 5.0);
			ApplyTempAttrib(entity, 6, 3.0, 5.0);
			ClientCommand(client, "playgamesound misc/ks_tier_04.wav");
		}

		cooldown = 3.0;
		TF2_StunPlayer(client, 3.0, 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT);
		TF2_AddCondition(client, TFCond_MarkedForDeath, 5.0);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L' L, R
// L, L' R
public Action SF_AOE(int client, int entity, int first, int second, int third, float &cooldown)
{
	if((first == UL || first == DL) && (second == UL || second == DL) && first != second && third == NR)
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		SpawnSmallExplosionNotRandom(pos);

		int stale = GetStaleAmount(client, CurrentCombo[client]);
		if(stale)
		{
			PrintCenterText(client, "AOE...");
			Explode_Logic_Custom(float(SDKCall_GetMaxHealth(client)), client, client, entity, pos, 250.0, 1.0, 1.0);
		}
		else
		{
			PrintCenterText(client, "AOE!");
			Explode_Logic_Custom(float(SDKCall_GetMaxHealth(client) * 2), client, client, entity, pos, 350.0, 1.0, 1.0);
		}

		cooldown += 0.5;
		ClientCommand(client, "playgamesound misc/rd_robot_explosion01.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// L' L, L
// L, L' L
public Action SF_Slap(int client, int entity, int first, int second, int third, float &cooldown)
{
	if((first == UL || first == DL) && (second == UL || second == DL) && first != second && third == NL)
	{
		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward);
		
		int target = TR_GetEntityIndex(swingTrace);
		int stale = GetStaleAmount(client, CurrentCombo[client]);

		if(target > MaxClients)
		{
			float Duration_Stun = 0.75;
			float Duration_Stun_Boss = 0.5;

			if(!stale)
			{
				Duration_Stun = 2.5;
				Duration_Stun_Boss = 1.25;
			}

#if defined ZR
			if(!b_thisNpcIsABoss[target] && EntRefToEntIndex(RaidBossActive) != target)
#else
			if(!b_thisNpcIsABoss[target])
#endif
			{
				FreezeNpcInTime(target,Duration_Stun);
			}
			else
			{
				FreezeNpcInTime(target,Duration_Stun_Boss);
			}
		}

		delete swingTrace;
		FinishLagCompensation_Base_boss();

		if(stale)
		{
			PrintCenterText(client, "Slap...");
		}
		else
		{
			PrintCenterText(client, "Slap!");
		}

		cooldown += 0.25;
		ClientCommand(client, "playgamesound misc/rubberglove_snap.wav");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}