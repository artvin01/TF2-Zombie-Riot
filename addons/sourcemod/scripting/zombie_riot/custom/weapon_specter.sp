#define SPECTER_DAMAGE_1	"ambient/sawblade_impact1.wav"
#define SPECTER_DAMAGE_2	"ambient/sawblade_impact2.wav"
#define SPECTER_BONEFRACTURE	"misc/halloween/hwn_wheel_of_fate.wav"
#define SPECTER_SURVIVEUSE	"items/powerup_pickup_strength.wav"
#define SPECTER_SURVIVEHIT	"items/powerup_pickup_knockout_melee_hit.wav"
#define SPECTER_SINGING		"ui/halloween_boss_summoned.wav"	// 5 seconds
#define SPECTER_CHARGED		"ui/halloween_boss_escape_ten.wav"

#define SPECTER_THREE	(1 << 0)
#define SPECTER_REVIVE	(1 << 1)

static int InSpecterHit;
static bool SpecterBigHit;
static float SpecterExpireIn[MAXTF2PLAYERS];
static int SpecterCharge[MAXTF2PLAYERS];
static float SpecterSurviveFor[MAXTF2PLAYERS];
static Handle SpecterTimer[MAXTF2PLAYERS];

void Specter_MapStart()
{
	PrecacheSound(SPECTER_DAMAGE_1);
	PrecacheSound(SPECTER_DAMAGE_2);
	PrecacheSound(SPECTER_SINGING);
	PrecacheSound(SPECTER_SURVIVEHIT);

	Zero(SpecterSurviveFor);
}

static int Specter_GetSpecterFlags(int weapon)
{
	int flags;
	Address address = TF2Attrib_GetByDefIndex(weapon, 122);
	if(address != Address_Null)
		flags = RoundFloat(TF2Attrib_GetValue(address));
	
	return flags;
}

stock void Specter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(InSpecterHit == victim)
	{
		damage = 0.0;
		return;
	}
	
	int flags = Specter_GetSpecterFlags(weapon);
	float gameTime = GetGameTime();
	bool survival = SpecterSurviveFor[attacker] > gameTime;
	
	if(survival)
	{
		int maxhealth = SDKCall_GetMaxHealth(attacker);
		float attackerHealthRatio = float(GetClientHealth(attacker)) / float(maxhealth);
		float victimHealthRatio = float(GetEntProp(victim, Prop_Data, "m_iHealth")) / float(GetEntProp(victim, Prop_Data, "m_iMaxHealth"));
		
		if(victimHealthRatio < attackerHealthRatio)
		{
			// If victim has less health %, self damage
			float selfdamage = float(maxhealth * 3 / 100);
			SDKHooks_TakeDamage(attacker, victim, victim, selfdamage, damagetype, weapon, damageForce, damagePosition);
		}
		else
		{
			// If victim has more health %, bonus damage
			damage *= 1.7;
			SpecterBigHit = true;
			DisplayCritAboveNpc(victim, attacker, false);
			if((flags & SPECTER_REVIVE) &&  dieingstate[attacker] < 1 && SpecterCharge[attacker] < 97)
				SpecterCharge[attacker] += 3;
		}
	}
	else if((flags & SPECTER_REVIVE) && dieingstate[attacker] < 1 && SpecterCharge[attacker] < 60)
	{
		SpecterCharge[attacker]++;
	}

	if(!InSpecterHit)
	{
		int value = i_ExplosiveProjectileHexArray[attacker];
		i_ExplosiveProjectileHexArray[attacker] = EP_DEALS_CLUB_DAMAGE;
		InSpecterHit = victim;
		
		Explode_Logic_Custom(damage, attacker, attacker, weapon, damagePosition, 75.0, 1.0, 0.0, false, survival ? 4 : ((flags & SPECTER_THREE) ? 3 : 2));
		
		i_ExplosiveProjectileHexArray[attacker] = value;
		InSpecterHit = 0;

		if(SpecterBigHit)
		{
			EmitSoundToAll(SPECTER_SURVIVEHIT, victim, SNDCHAN_AUTO, SNDLEVEL_CONVO);
			SpecterBigHit = false;
		}
		else
		{
			EmitSoundToAll((GetURandomInt() % 2) ? SPECTER_DAMAGE_1 : SPECTER_DAMAGE_2, victim, SNDCHAN_AUTO, SNDLEVEL_CONVO);
		}
		
		if(flags & SPECTER_REVIVE)
		{
			SpecterCharge[attacker]++;
			SpecterExpireIn[attacker] = gameTime + 30.0;
			if(!SpecterTimer[attacker])
				SpecterTimer[attacker] = CreateTimer(0.5, Specter_ReviveTimer, attacker, TIMER_REPEAT);
		}
	}
}

public void Weapon_SpecterBone(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		ClientCommand(client, "playgamesound %s", SPECTER_BONEFRACTURE);

		TF2_AddCondition(client, TFCond_MegaHeal, 6.75);
		TF2_AddCondition(client, TFCond_UberchargedHidden, 6.75);
		TF2_AddCondition(client, TFCond_NoHealingDamageBuff, 6.75);
		CreateTimer(6.6, Specter_BoneTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.1, Specter_DrainTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		Ability_Apply_Cooldown(client, slot, 206.6);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
}

public Action Specter_DrainTimer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(IsPlayerAlive(client) && TF2_IsPlayerInCondition(client, TFCond_UberchargedHidden))
		{
			int health = GetClientHealth(client) * 49 / 50;
			if(health < 1)
				health = 1;
			
			SetEntityHealth(client, health);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action Specter_BoneTimer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		TF2_RemoveCondition(client, TFCond_MegaHeal);
		TF2_RemoveCondition(client, TFCond_UberchargedHidden);
		TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
		SetEntityHealth(client, 1);
		
		TF2_StunPlayer(client, 5.0, 0.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_SOUND, 0);
		StopSound(client, SNDCHAN_STATIC, "player/pl_impact_stun.wav");
	}
	return Plugin_Stop;
}

public void Weapon_SpecterSurvive(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		ClientCommand(client, "playgamesound %s", SPECTER_SURVIVEUSE)

		SpecterSurviveFor[client] = GetGameTime() + 9.8;

		ApplyTempAttrib(weapon, 2, 3.6, 10.0);
		ApplyTempAttrib(weapon, 6, 2.0, 10.0);
		ApplyTempAttrib(weapon, 412, 0.333, 10.0);
		ApplyTempAttrib(weapon, 740, 0.333, 10.0);
		Ability_Apply_Cooldown(client, slot, 29.8);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
}

public Action Specter_ReviveTimer(Handle timer, int client)
{
	if(SpecterCharge[client] < 60 && SpecterExpireIn[client] > GetGameTime())
	{
		SpecterCharge[client]--;
		SpecterExpireIn[client] = GetGameTime() + 5.0;
	}

	bool endTimer;
	if(SpecterCharge[client] < 1 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		endTimer = true;
	}
	else if(dieingstate[client] > 150 || !b_LeftForDead[client])
	{
		if(SpecterCharge[client] > 59)
		{
			ClientCommand(client, "playgamesound %s", SPECTER_SINGING);

			b_LeftForDead[client] = true;
			dieingstate[client] = 150; // 5 seconds
			i_AmountDowned[client]--;
			SpecterCharge[client] -= 60;
			endTimer = true;

			PrintHintText(client, "Specter Revive Activated");
		}
	}
	else
	{
		PrintHintText(client, "Specter Revive [%d / 60]", SpecterCharge[client]);
		StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
	}

	if(!endTimer)
		return Plugin_Continue;
	
	SpecterExpireIn[client] = 0.0;
	SpecterCharge[client] = 0;
	SpecterTimer[client] = null;
	return Plugin_Stop;
}