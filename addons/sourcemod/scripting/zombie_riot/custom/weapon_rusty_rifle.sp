#pragma semicolon 1
#pragma newdecls required

//As per usual, I'm using arrays for stats on different pap levels. First entry is pap1, then pap2, etc.
//There is no pap0 entry for this weapon because it doesn't do anything which requires a plugin on pap0.

static int BigShot_MaxTargets[2] = { 4, 7 };						//The maximum number of zombies penetrated by the big shot.
static int BigShot_BrainBlastMaxTargets[2] = { 0, 15 };				//The maximum number of zombies hit by Brain Blast explosions (Brain Blast: if the M2 headshots every zombie it hits, trigger an explosion).

static float BigShot_BaseDMGMult[2] = { 1.33,  1.5 };				//Amount to multiply the base damage of the big shot.
static float BigShot_PerHeadshotMult[2] = { 1.25, 1.25 };			//Amount to multiply the damage dealt to zombies in the penetration chain for each zombie before them in the chain which was headshot.
static float BigShot_PerBodyshotMult[2] = { 0.66, 0.8 };			//Amount to multiply the damage dealt to zombies in the penetration chain for each zombie before them in the chain which was bodyshot. This is ignored for zombies which are headshot.
static float BigShot_BrainBlastDMG[2] = { 0.0, 1000.0 };			//The base damage of Brain Blast.
static float BigShot_BrainBlastBonus[2] = { 0.0, 500.0 };			//Amount to increase Brain Blast explosion damage for every zombie in the chain past 1.
static float BigShot_BrainBlastRadius[2] = { 0.0, 400.0 };			//The blast radius of blain blast.
static float BigShot_BrainBlastFalloff_Radius[2] = { 0.0, 0.5 };	//Maximum damage faloff of Brain Blast, based on radius.
static float BigShot_BrainBlastFalloff_MultiHit[2] = { 0.0, 0.8 };	//Amount to multiply damage dealt by Brain Blast for each zombie it hits.
static float BigShot_Cooldown[2] = { 15.0, 15.0 };					//Big Shot's cooldown.

static bool BigShot_BrainBlast[2] = { false, true };				//Is Brain Blast active on this pap tier?

//Client/entity-specific global variables below, don't touch these:
static bool BigShot_Active[MAXPLAYERS + 1] = { false, ... };
static int BigShot_Tier[MAXPLAYERS + 1] = { false, ... };
static float ability_cooldown[MAXPLAYERS + 1] = {0.0, ...};

public void Rusty_Rifle_ResetAll()
{
	for (int i = 0; i <= MaxClients; i++)
		BigShot_Active[i] = false;

	Zero(ability_cooldown);
}

#define SND_RUSTY_BIGSHOT		")mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav"
#define SND_RUSTY_BIGSHOT_2		")mvm/giant_common/giant_common_explodes_01.wav"
#define SND_RUSTY_BRAINBLAST	")mvm/giant_soldier/giant_soldier_explode.wav"

void Rusty_Rifle_Precache()
{
	PrecacheSound(SND_RUSTY_BIGSHOT);
	PrecacheSound(SND_RUSTY_BIGSHOT_2);
	PrecacheSound(SND_RUSTY_BRAINBLAST);
}

public void Weapon_Rusty_Rifle_Fire(int client, int weapon, bool crit)
{
	if (!BigShot_Active[client])
		return;

	BigShot_Active[client] = false;
	SetForceButtonState(client, false, IN_ATTACK);
	EmitSoundToAll(SND_RUSTY_BIGSHOT, client);
	EmitSoundToAll(SND_RUSTY_BIGSHOT_2, client, _, _, _, _, 80);
	Client_Shake(client, SHAKE_START, 30.0, 150.0, 1.25);

	RequestFrame(BigShot_RevertAttribs, EntIndexToEntRef(weapon));
}

public void BigShot_RevertAttribs(int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (!IsValidEntity(weapon))
		return;

	Attributes_Set(weapon, 305, 0.0);
	Attributes_Set(weapon, 266, 0.0);
}

public void Weapon_Rusty_Rifle_BigShot_Pap1(int client, int weapon, bool crit)
{
	BigShot_AttemptUse(client, weapon, crit, 0);
}

public void Weapon_Rusty_Rifle_BigShot_Pap2(int client, int weapon, bool crit)
{
	BigShot_AttemptUse(client, weapon, crit, 1);
}

public void BigShot_AttemptUse(int client, int weapon, bool crit, int tier)
{
	if (Ability_Check_Cooldown(client, 2) < 0.0)
	{
		float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
		if (GetGameTime() < nextAttack)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Rusty Ability Blocked");
		}
		else
		{
			//WHY WON'T YOU WORK??????????
			Attributes_Set(weapon, 305, 1.0);
			Attributes_Set(weapon, 266, float(BigShot_MaxTargets[tier]));

			
			Ability_Apply_Cooldown(client, 2, BigShot_Cooldown[tier]);
			SetForceButtonState(client, true, IN_ATTACK);
			BigShot_Active[client] = true;
			BigShot_Tier[client] = tier;
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);
				
		if(Ability_CD <= 0.0)
		Ability_CD = 0.0;
				
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Rusty Ability Cooldown", Ability_CD);
	}
}