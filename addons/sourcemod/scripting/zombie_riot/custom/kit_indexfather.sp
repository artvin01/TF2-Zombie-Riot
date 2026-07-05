#pragma semicolon 1
#pragma newdecls required

static float HudCooldown[MAXPLAYERS] = {0.0, ...};
static Handle Handle_Timer[MAXPLAYERS] = {null, ...};
static ArrayList CurrentPrescript[MAXPLAYERS];
static float PrescriptCooldown[MAXPLAYERS] = {0.0, ...};
static float PrescriptPunishPlayerIgnoring[MAXPLAYERS] = {0.0, ...};
static float OptimiseCmd[MAXPLAYERS] = {0.0, ...};
static Function SaveEntityOnBuildObject[MAXPLAYERS][2];
static int i_PreviousWeapon[MAXPLAYERS];
static float f_SwitchWeaponsRandomly[MAXPLAYERS];
static float f_HoldBasicVialTime[MAXPLAYERS];
static int i_CurrentWeaponSet[MAXPLAYERS];
static int i_DodgesAvailable[MAXPLAYERS] = {15, ...};
static float f_DodgeCooldown[MAXPLAYERS];
static float f_DodgeBetweenDashes[MAXPLAYERS];
static float f_DodgeActive[MAXPLAYERS];
static float f_ResetMoveSpeedPenalty[MAXPLAYERS];
static int GraceOfPrescript[MAXPLAYERS];
static bool UnlockedShin[MAXPLAYERS];
static int i_FuriosoReady[MAXPLAYERS];

#define IDX_FURI_WEAPON_1	 	(1 << 1)
#define IDX_FURI_WEAPON_2		(1 << 2)
#define IDX_FURI_WEAPON_3	 	(1 << 3)
#define IDX_FURI_WEAPON_4	 	(1 << 4)
#define IDX_FURI_WEAPON_5	 	(1 << 5)
#define IDX_FURI_WEAPON_6		(1 << 6)
#define IDX_FURI_WEAPON_7		(1 << 7)
#define IDX_FURI_WEAPON_8	 	(1 << 8)
#define IDX_FURI_WEAPON_9	 	(1 << 9)

static char g_AllWeaponsExist[][] = {
	
	//3 blunt weapons
	"Prescript Hatchet", 		//Give poise on hit
	"Prescript Hammer",			//Inflictrs knockback, and applies tremor
	"Prescript Whip", 			//Make a new debuff, fragile, like most debuffs
	
	//3 pierce weapons
	"Prescript Stiletto",		//hit gives sinking
	"Prescript Rapier",			//Make a new debuff, fragile, like most debuffs
	"Prescript Lance",			//Make a new debuff, fragile, like most debuffs

	//3 slash weapons
	"Prescript Bastardsword",	//Give tempomary damage buff/1 strength from redmist, copy that
	"Prescript Greatsword",		//Make a new debuff, fragile, like most debuffs
	"Prescript Scythe",			//guranteed crits
};
enum
{
	PrescriptWeapon_Hatchet,
	PrescriptWeapon_Hammer,
	PrescriptWeapon_Whip,

	PrescriptWeapon_Stiletto,
	PrescriptWeapon_Rapier,
	PrescriptWeapon_Lance,
	
	PrescriptWeapon_Bastardsword,
	PrescriptWeapon_Greatsword,
	PrescriptWeapon_Sycthe,

}

static char g_RecieveNewPrescript[][] = {
	"ui/quest_status_tick_advanced_friend.wav",
	"ui/quest_status_tick_novice_friend.wav",
};
static char g_SuccessPrescript[][] = {
	"ui/quest_alert.wav",
};
static char g_FailPrescript[][] = {
	"ui/quest_decode.wav",
};
static char g_NewPrescriptAvailable[][] = {
	"ui/quest_status_tick_expert_pda.wav",
};
static char g_GenerateRandomWeapon[][] = {
	"items/battery_pickup.wav",
};
static char g_AquireNewWeapon[][] = {
	"items/suitchargeok1.wav",
};

enum PrescriptAddition
{
	PA_WhileInAir = 1,
	PA_WhileLookingDown,
	PA_WhileLookingUp,
	PA_WhileCrouching,

	PA_MAX,
}
/*
	Example:
	PA_WhileInAir + PT_DealDamage -> PT_WhileCrouching + PT_SpinInPlace -> 50 seconds

	While in the air, Deal 5015 Damage, Then While Crouching, Spin in place for 3 seconds, you have 50 seconds.

*/
enum PrescriptType
{
	PT_StandStill = 1, 			//Stand still
	PT_KillTarget,			//Kill specific target
	PT_UseSpecificBuilding, //Use any building with what it asks
	PT_DealDamage,			
	PT_TakeDamage,			
	PT_DontTakeDamage,  //todo make work
	PT_Taunt,
	PT_Jump,
	PT_JumpSpecificTime,	//i.e. only jump 6 times
	PT_HitEnemyFromBehind,
	PT_StayAwayFromAllies,
	PT_TalkToAllies,		//Pressing R on rebel or grigori, if neither are present, it auto wins you
	PT_BuildSpecicBuilding,	
	PT_DodgeSuccessfully, 	//Kit will have a build in dodge, this requires you to dodge, todo make
	PT_SpinInPlace,			//Spin in place
	PT_HumpAlly,			//Spam W and S behind an ally

	PT_MAX,
}
enum struct Prescript
{
	float Goal;
	float Current;
	float ExtraInfo;
	char sExtraInfo[64];
	PrescriptType WhatPrescript;
	PrescriptAddition Addition;
	
}
enum struct ThePrescript
{
	Prescript CurrentGoal_1;
	Prescript CurrentGoal_2;
	float Timelimit;
}

public void IndexFather_MapStart()
{
	Zero(HudCooldown);
	Zero(PrescriptCooldown);
	Zero(OptimiseCmd);
	Zero(f_HoldBasicVialTime);
	Zero(f_SwitchWeaponsRandomly);
	PrecacheSoundArray(g_RecieveNewPrescript);
	PrecacheSoundArray(g_SuccessPrescript);
	PrecacheSoundArray(g_FailPrescript);
	PrecacheSoundArray(g_NewPrescriptAvailable);
	PrecacheSoundArray(g_AquireNewWeapon);
	PrecacheSoundArray(g_GenerateRandomWeapon);
}
public void IndexFather_PluginStart()
{
	LoadTranslations("zombieriot.phrases.prescript"); 
	RegAdminCmd("sm_prescript_debug", Command_GiveForcePrescript, ADMFLAG_ROOT, "Enable PVP");
}

public Action Command_GiveForcePrescript(int client, int args)
{
	//What are you.
	if(args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_prescript_debug <Target> <prescript number>");
        return Plugin_Handled;
    }
    
	static char targetName[MAX_TARGET_LENGTH];
    
	static char pattern[PLATFORM_MAX_PATH];
	GetCmdArg(1, pattern, sizeof(pattern));
	
	static int PrescriptTest;
	PrescriptTest = GetCmdArgInt(2);

	int targets[MAXPLAYERS], matches;
	bool targetNounIsMultiLanguage;
	if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), 0, targetName, sizeof(targetName), targetNounIsMultiLanguage)) < 1)
	{
		ReplyToTargetError(client, matches);
		return Plugin_Handled;
	}
	
	for(int target; target<matches; target++)
	{
		IndexFather_GeneratePrescript(targets[target], true, PrescriptTest);
	}
	
	return Plugin_Handled;
}

public void IndexFather_NewPrescript(int client, int weapon, bool &result, int slot)
{
	if(CurrentPrescript[client] != null)
	{
		ThePrescript data;
		CurrentPrescript[client].GetArray(0, data);
		if(IndexFather_IsPrescriptfullfilledAll(data, true))
		{	
			IndexFather_PrescriptEnd(client, true);
		}
		//if nothing, dont do anything
	}
	if((CurrentPrescript[client] == null && PrescriptCooldown[client] < GetGameTime()) || CvarInfiniteCash.BoolValue)
	{
		IndexFather_GeneratePrescript(client, true);
	}
}
public void IndexFather_WeaponLoad(int client, int weapon)
{
	IndexFather_GeneratePrescript(client, false);

	if(Handle_Timer[client] != null)
		delete Handle_Timer[client];
	Handle_Timer[client] = null;

	SDKUnhook(client, SDKHook_PreThink, IndexFather_DodgeLogic);
	SDKHook(client, SDKHook_PreThink, IndexFather_DodgeLogic);

	DataPack pack;
	Handle_Timer[client] = CreateDataTimer(0.1, Timer_Base, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	SaveEntityOnBuildObject[client][0] 	= EntityOnBuildObject[weapon];
	SaveEntityOnBuildObject[client][1]	= EntityOnAllyInteract[weapon];
}
public void IndexFather_WeaponVial(int client, int weapon)
{
	i_PreviousWeapon[client] = EntIndexToEntRef(weapon);
	f_HoldBasicVialTime[client] = GetGameTime() + 0.0;
	f_SwitchWeaponsRandomly[client] = GetGameTime() + 1.0;
}

static Action Timer_Base(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientIDX = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		if(IsValidClient(client))
			SDKUnhook(clientIDX, SDKHook_PreThink, IndexFather_DodgeLogic);
		Handle_Timer[clientIDX] = null;
		return Plugin_Stop;
	}
	ApplyStatusEffect(client, client, "Index Father Dodge", 1.0);
	if(UnlockedShin[client])
		ApplyStatusEffect(client, client, "Shin - Rien", 1.0);
	if(GraceOfPrescript[client])
		ApplyStatusEffect(client, client, "Grace Of Prescript", 1.0);
	if(FuriosoReady(client))
		ApplyStatusEffect(client, client, "Furioso Charges", 1.0);
	if(f_HoldBasicVialTime[client] && f_HoldBasicVialTime[client] < GetGameTime())
	{
		IndexFather_GrantRandomWeapon(client, weapon);
		f_HoldBasicVialTime[client] = 0.0;
		f_SwitchWeaponsRandomly[client] = GetGameTime() + 10.0;
	}
	if(f_SwitchWeaponsRandomly[client] < GetGameTime())
	{
		IndexFather_GrantVial(client);
		f_HoldBasicVialTime[client] = GetGameTime() + 1.0;
		f_SwitchWeaponsRandomly[client] = GetGameTime() + 15.0;
		int viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(viewmodelModel))
		{
			float flBasePos[3]; // original
			float flAng[3]; // original
			GetAttachment(viewmodelModel, "effect_hand_R", flBasePos, flAng);
			int particle = ParticleEffectAt(flBasePos, "spell_teleport_black", 1.0);
			SetParent(viewmodelModel, particle, "effect_hand_R");
			AddEntityToThirdPersonTransitMode(client, particle);
		}
		int EntityWeaponModel = EntRefToEntIndex(HandRef[client]);
		if(IsValidEntity(EntityWeaponModel))
		{
			float flBasePos[3]; // original
			float flAng[3]; // original
			GetAttachment(EntityWeaponModel, "weapon_bone", flBasePos, flAng);
			int particle = ParticleEffectAt(flBasePos, "spell_teleport_black", 1.0);
			SetParent(EntityWeaponModel, particle, "weapon_bone");
			AddEntityToFirstPersonTransmitMode(client, particle);
		}
	}
	EntityOnBuildObject[client] = SaveEntityOnBuildObject[client][0];
	EntityOnAllyInteract[client] = SaveEntityOnBuildObject[client][1];
	KitHudShow(client);
	return Plugin_Continue;
}

static void KitHudShow(int client)
{
	if(HudCooldown[client] > GetGameTime())
		return;
	HudCooldown[client] = GetGameTime() + 0.4;
	char WeaponHud[128];

	if(CurrentPrescript[client] == null)
	{
		if(PrescriptCooldown[client] > GetGameTime())
		{
			Format(WeaponHud, sizeof(WeaponHud), "%s%T",WeaponHud, "Prescript None Exist", client);
		}
		else
		{
			if(PrescriptCooldown[client])
			{
				EmitSoundToClient(client, g_NewPrescriptAvailable[GetRandomInt(0, sizeof(g_NewPrescriptAvailable) - 1)], client, SNDCHAN_STATIC, 80, _, 0.8, 110);
				PrescriptCooldown[client] = 0.0;
			}
			Format(WeaponHud, sizeof(WeaponHud), "%s%T",WeaponHud, "Prescript Avaiable Check Device", client);
			if(PrescriptPunishPlayerIgnoring[client] && PrescriptPunishPlayerIgnoring[client] < GetGameTime())
			{
				//ignored prescript
				PrescriptPunishPlayerIgnoring[client] = 0.0;
				IndexFather_PrescriptEnd(client, false);
			}
		}
	}
	else
	{
		ThePrescript data;
		CurrentPrescript[client].GetArray(0, data);
		IndexFather_ReturnTextInfo(client, data.CurrentGoal_1, WeaponHud, sizeof(WeaponHud));

		if(data.CurrentGoal_2.Goal != 0.0)
		{
			Format(WeaponHud, sizeof(WeaponHud), "%s\n%T",WeaponHud, "Prescript Continue", client);
			IndexFather_ReturnTextInfo(client, data.CurrentGoal_2, WeaponHud, sizeof(WeaponHud));
		}
		Format(WeaponHud, sizeof(WeaponHud), "%s\n%T",WeaponHud, "Prescript Time Limit", client, data.Timelimit - GetGameTime(), client);
		if(data.Timelimit < GetGameTime())
		{
			IndexFather_PrescriptEnd(client, IndexFather_IsPrescriptfullfilledAll(data, false));
		}
	}
	PrintHintText(client,"%s", WeaponHud);
}
void IndexFather_GeneratePrescript(int client, bool ForceNew, int PrescriptForce = 0)
{
	if(CurrentPrescript[client] != null)
	{
		if(!ForceNew)
			return;
		//Make a new script?
		delete CurrentPrescript[client];
	}
	if(PrescriptForce != 0)
	{
		if(PrescriptCooldown[client] > GetGameTime())
		{
			return;
		}
	}
	EmitSoundToClient(client, g_RecieveNewPrescript[GetRandomInt(0, sizeof(g_RecieveNewPrescript) - 1)], client, SNDCHAN_STATIC, 80, _, 0.8, 110);
	CurrentPrescript[client] = new ArrayList(sizeof(ThePrescript));
	ThePrescript data;

	data.Timelimit = GetGameTime() + GetRandomFloat(45.0,75.0);
	Prescript data2;
	IndexFather_SelectRandomGoal(client, data2, PrescriptForce);
	IndexFather_SelectRandomAddition(data2);
	data.CurrentGoal_1 = data2;
	
	if(GetRandomInt(1,4) == 1 && !PrescriptForce)
	{
		Prescript data3;
		IndexFather_SelectRandomGoal(client,data3,_, 1);
		IndexFather_SelectRandomAddition(data3);
		data.CurrentGoal_2 = data3;
	}
	CurrentPrescript[client].PushArray(data);
	
}

void IndexFather_ReturnTextInfo(int client, Prescript data, char[] CharToEnter, int SizeofChar)
{

	switch(data.Addition)
	{
		case PA_WhileInAir:
		{
			Format(CharToEnter, SizeofChar, "%s%T ",CharToEnter, "Prescript Addition While In Air", client);
		}
		case PA_WhileLookingDown:
		{
			Format(CharToEnter, SizeofChar, "%s%T ",CharToEnter, "Prescript Addition Looking Down", client);
		}
		case PA_WhileLookingUp:
		{
			Format(CharToEnter, SizeofChar, "%s%T ",CharToEnter, "Prescript Addition Looking Up", client);
		}
		case PA_WhileCrouching:
		{
			Format(CharToEnter, SizeofChar, "%s%T ",CharToEnter, "Prescript Addition While Crouching", client);
		}
		default:
		{

		}
	}
	switch(data.WhatPrescript)
	{
		case PT_StandStill:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Stand Still", client, data.Goal);
		}
		case PT_KillTarget:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Kill Targets", client, RoundFloat(data.Goal));
		}
		case PT_UseSpecificBuilding:
		{
			char buffer1[255];
			NPC_GetNameByPlugin(data.sExtraInfo, buffer1, sizeof(buffer1));
			Format(buffer1, sizeof(buffer1), "%T",buffer1, client);
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Use Specific Building", client, RoundFloat(data.Goal), buffer1);
		}
		case PT_DealDamage:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Deal Damage", client, data.Goal);
		}
		case PT_TakeDamage:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Take Damage", client, data.Goal);
		}
		case PT_DontTakeDamage:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Dont Take Damage", client, data.ExtraInfo);
		}
		case PT_Taunt:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Taunt", client, RoundFloat(data.Goal));
		}
		case PT_Jump:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Jump", client, RoundFloat(data.Goal));
		}
		//todo: Prevent getting this if the previous one was a jump one
		case PT_JumpSpecificTime:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Jump Specific Time", client, RoundFloat(data.Goal));
		}
		case PT_HitEnemyFromBehind:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Hit From Behind", client, RoundFloat(data.Goal));
		}
		case PT_StayAwayFromAllies:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Stay Away From Allies", client, data.Goal);
		}
		case PT_TalkToAllies:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Talk To Ally", client);
		}
		case PT_BuildSpecicBuilding:
		{
			char buffer1[255];
			NPC_GetNameByPlugin(data.sExtraInfo, buffer1, sizeof(buffer1));
			Format(buffer1, sizeof(buffer1), "%T",buffer1, client);
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Build Specific Building", client, buffer1);
		}
		case PT_DodgeSuccessfully:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Dodge Successfully", client, RoundFloat(data.Goal));
		}
		case PT_SpinInPlace:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Spin In Place", client, data.Goal);
		}
		case PT_HumpAlly:
		{
			Format(CharToEnter, SizeofChar, "%s%T",CharToEnter, "Prescript Hump Ally", client, data.Goal);
		}
	}
}
void IndexFather_SelectRandomGoal(int client, Prescript data, int PrescriptForce = 0, int extra = 0)
{
	PrescriptType SelectRandom = view_as<PrescriptType>(GetRandomInt(1, view_as<int>(PT_MAX) - 1));
	if(PrescriptForce)
	{
		SelectRandom = view_as<PrescriptType>(PrescriptForce);
	}
	data.WhatPrescript = SelectRandom;
	switch(SelectRandom)
	{
		case PT_StandStill:
		{
			data.Goal = GetRandomFloat(3.0, 6.0);
		}
		case PT_KillTarget:
		{
			data.Goal = float(GetRandomInt(1, 5));
		}
		case PT_UseSpecificBuilding:
		{
			data.Goal = float(GetRandomInt(1, 2));
			char TestPrint[255];
			RandomBuildingGet(client, TestPrint, sizeof(TestPrint));
			Format(data.sExtraInfo, sizeof(data.sExtraInfo), "%s",TestPrint);
		}
		case PT_DealDamage:
		{
			//todo, add damage scaling
			data.Goal = IndexFather_DamageDealTreshhold();
		}
		case PT_TakeDamage:
		{
			//todo, add damage scaling
			data.Goal = IndexFather_DamageTakeTreshhold();
		}
		case PT_DontTakeDamage:
		{
			data.ExtraInfo = GetRandomFloat(10.0, 15.0);
			data.Goal = GetGameTime();
		}
		case PT_Taunt:
		{
			data.Goal = float(GetRandomInt(1, 2));
		}
		case PT_Jump:
		{
			data.Goal = float(GetRandomInt(5, 10));
		}
		case PT_JumpSpecificTime:
		{
			if(extra == 1)
			{
				//cant have this as a 2nd one as it can result in impossible ones.
				data.WhatPrescript = PT_Jump;
				data.Goal = float(GetRandomInt(5, 20));
			}
			data.Goal = float(GetRandomInt(5, 10));
		}
		case PT_HitEnemyFromBehind:
		{
			data.Goal = float(GetRandomInt(3, 6));
		}
		case PT_StayAwayFromAllies:
		{
			data.Goal = GetRandomFloat(10.0, 15.0);
		}
		case PT_TalkToAllies:
		{
			data.Goal = 1.0;
		}
		case PT_BuildSpecicBuilding:
		{
			data.Goal = 1.0;
			char TestPrint[255];
			RandomBuildingGet(client, TestPrint, sizeof(TestPrint));
			Format(data.sExtraInfo, sizeof(data.sExtraInfo), "%s",TestPrint);
		}
		case PT_DodgeSuccessfully:
		{
			data.Goal = float(GetRandomInt(2, 7));
		}
		case PT_SpinInPlace:
		{
			data.Goal = float(GetRandomInt(2, 3));
		}
		case PT_HumpAlly:
		{
			data.Goal = float(GetRandomInt(2, 3));
		}
		default:
		{
			LogStackTrace("Error! Prescript is undefined!");
			PrintToChatAll("Error! Prescript is undefined! Report to an admin!");
		}
	}
}


void IndexFather_SelectRandomAddition(Prescript data)
{
	if(GetRandomInt(1,4) != 1)
	{
		return;
		//none.
	}
	PrescriptAddition Addition = view_as<PrescriptAddition>(GetRandomInt(1, view_as<int>(PA_MAX) - 1));
	

	bool Allow = true;
	switch(Addition)
	{
		case PA_WhileInAir:
		{
			switch(data.WhatPrescript)
			{
				case PT_StandStill, PT_Taunt, PT_Jump, PT_JumpSpecificTime:
				{
					Allow = false;
					//disallow
				}
			}
		}
		case PA_WhileLookingDown:
		{
			switch(data.WhatPrescript)
			{
				case PT_Taunt:
				{
					Allow = false;
					//disallow
				}
			}
		}
		case PA_WhileLookingUp:
		{
			
			switch(data.WhatPrescript)
			{
				case PT_Taunt:
				{
					Allow = false;
					//disallow
				}
			}
		}
		case PA_WhileCrouching:
		{
			switch(data.WhatPrescript)
			{
				case PT_Taunt, PT_Jump, PT_JumpSpecificTime:
				{
					Allow = false;
					//disallow
				}
			}
		}
	}
	if(Allow)
	{
		data.Addition = Addition; 
	}
}
public void IndexFather_PlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(CurrentPrescript[client] == null)
	{
		return;
	}
	if(OptimiseCmd[client] > GetGameTime())
		return;
	ThePrescript data;
	CurrentPrescript[client].GetArray(0, data);
//	Prescript CurrentGoal = data.CurrentGoal_1;
	
	if(!IndexFather_PrescriptPassRestriction(client, data))
	{
		return;
	}
	Prescript data2;
	IndexFather_WhichScriptCurrent(data, data2);
	bool ApplyChange = false;

	switch(data2.WhatPrescript)
	{
		case PT_Jump, PT_JumpSpecificTime:
		{
			if(IndexFather_CheckIfJump(client))
			{
				data2.Current += float(1);
				ApplyChange = true;
			}
		}
		case PT_Taunt:
		{
			if(IndexFather_CheckIfTaunt(client))
			{
				data2.Current += float(1);
				ApplyChange = true;
			}
		}
		case PT_StandStill:
		{
			OptimiseCmd[client] = GetGameTime() + 0.25;
			if(AreVectorsEqual(vel, view_as<float>({0.0,0.0,0.0})))
			{
				data2.Current += 0.25;
				ApplyChange = true;
			}
		}
		case PT_StayAwayFromAllies:
		{
			OptimiseCmd[client] = GetGameTime() + 0.5;
			if(IndexFather_NearAllies(client))
			{
				data2.Current += 0.5;
				ApplyChange = true;
			}
		}
		case PT_HumpAlly:
		{
			OptimiseCmd[client] = GetGameTime() + 0.5;
			if(IndexFather_NearAllies(client, true))
			{
				data2.Current += 0.5;
				ApplyChange = true;
			}
		}
		case PT_SpinInPlace:
		{
			if(IndexFather_Spinning(client, angles))
			{
				data2.Current += 0.15;
				ApplyChange = true;
			}
		}
	}
	if(ApplyChange)
		IndexFather_SetScriptData(client, data, data2.Current);
}

public void IndexFather_BuildEntity(int client, int buildobject)
{
	if(CurrentPrescript[client] == null)
	{
		return;
	}
	ThePrescript data;
	CurrentPrescript[client].GetArray(0, data);
	
	if(!IndexFather_PrescriptPassRestriction(client, data))
	{
		return;
	}
	Prescript data2;
	IndexFather_WhichScriptCurrent(data, data2);
	bool ApplyChange = false;
	switch(data2.WhatPrescript)
	{
		case PT_BuildSpecicBuilding:
		{
			if(i_IsABuilding[buildobject])
			{
				char plugin[255];
				NPC_GetPluginById(i_NpcInternalId[buildobject], plugin, sizeof(plugin));
				if(StrEqual(plugin, data2.sExtraInfo, true))
				{
					ApplyChange = true;
					data2.Current += 1.0;
				}
			}
			ApplyChange = true;
			data2.Current += 1.0;
		}
	}
	if(ApplyChange)
		IndexFather_SetScriptData(client, data, data2.Current);
}
public void IndexFather_InteractAlly(int client, int InteractedEntity)
{
	if(CurrentPrescript[client] == null)
	{
		return;
	}
	ThePrescript data;
	CurrentPrescript[client].GetArray(0, data);
	
	if(!IndexFather_PrescriptPassRestriction(client, data))
	{
		return;
	}
	Prescript data2;
	IndexFather_WhichScriptCurrent(data, data2);
	bool ApplyChange = false;
	switch(data2.WhatPrescript)
	{
		case PT_TalkToAllies:
		{
			if(!i_IsABuilding[InteractedEntity])
			{
				ApplyChange = true;
				data2.Current += 1.0;
			}
		}
		case PT_UseSpecificBuilding:
		{
			if(i_IsABuilding[InteractedEntity])
			{
				char plugin[255];
				NPC_GetPluginById(i_NpcInternalId[InteractedEntity], plugin, sizeof(plugin));
				if(StrEqual(plugin, data2.sExtraInfo, true))
				{
					ApplyChange = true;
					data2.Current += 1.0;
				}
			}
		}
	}
	if(ApplyChange)
		IndexFather_SetScriptData(client, data, data2.Current);
}
public void IndexFather_OnKill(int victim, int killer, int weapon)
{
	if(CurrentPrescript[killer] == null)
	{
		return;
	}
	ThePrescript data;
	CurrentPrescript[killer].GetArray(0, data);
	
	if(!IndexFather_PrescriptPassRestriction(killer, data))
	{
		return;
	}
	Prescript data2;
	IndexFather_WhichScriptCurrent(data, data2);
	bool ApplyChange = false;
	switch(data2.WhatPrescript)
	{
		case PT_KillTarget:
		{
			data2.Current += 1.0;
			ApplyChange = true;
		}
	}
	if(ApplyChange)
		IndexFather_SetScriptData(killer, data, data2.Current);

}
int IndexFather_CheckIfTaunt(int client)
{
	OptimiseCmd[client] = GetGameTime() + 0.5;
	static bool GavePoint[MAXPLAYERS];
	if(TF2_IsPlayerInCondition(client, TFCond_Taunting))
	{
		if(!GavePoint[client])
		{
			GavePoint[client] = true;
			return 1;
		}
	}
	else
	{
		GavePoint[client] = false;
	}
	return 0;

}
int IndexFather_CheckIfJump(int client)
{
	static bool GavePoint[MAXPLAYERS];
	if(GetEntProp(client, Prop_Send, "m_bJumping"))
	{
		if(!GavePoint[client])
		{
			GavePoint[client] = true;
			return 1;
		}
	}
	else
	{
		GavePoint[client] = false;
	}
	return 0;

}


bool IndexFather_IsPrescriptfullfilledAll(ThePrescript data, bool manual = false)
{
	if(IndexFather_IsPrescriptfullfilled(data.CurrentGoal_1, manual))
	{
		if(data.CurrentGoal_2.WhatPrescript == view_as<PrescriptType>(0) || IndexFather_IsPrescriptfullfilled(data.CurrentGoal_2))
		{
			return true;
		}
	}
	return false;
}
enum
{
	BiggerOrEqual = 0,
	MustBeEqual = 1,
	DontTakedamage = 2,
}
bool IndexFather_IsPrescriptfullfilled(Prescript WhatPrescript, bool manual = false)
{
	bool Allow = true;
	int WinSettings = BiggerOrEqual;
	switch(WhatPrescript.WhatPrescript)
	{
		case PT_JumpSpecificTime:
		{
			WinSettings = MustBeEqual;
		}
		case PT_DontTakeDamage:
		{
			WinSettings = DontTakedamage;
		}
	}
	if(manual)
	{
		switch(WhatPrescript.WhatPrescript)
		{
			case PT_JumpSpecificTime:
			{
				Allow = false;
			}
		}
	}
	if(!Allow)
	{
		return false;
	}
	switch(WinSettings)
	{
		case MustBeEqual:
		{
			if(WhatPrescript.Current == WhatPrescript.Goal)
				return true;
		}
		case DontTakedamage:
		{
			if((WhatPrescript.Current - WhatPrescript.ExtraInfo) < GetGameTime())
			{
				return true;
			}
		}
		default:
		{
			if(WhatPrescript.Current >= WhatPrescript.Goal)
				return true;
		}
	}
	return false;
}

public void IndexFather_TakeDamageDealTakePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, int equipped_weapon, float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;


	if(CurrentPrescript[victim] == null)
	{
		return;
	}
	ThePrescript data;
	CurrentPrescript[victim].GetArray(0, data);
	if(!IndexFather_PrescriptPassRestriction(victim, data))
	{
		return;
	}
	
	Prescript data2;
	IndexFather_WhichScriptCurrent(data, data2);
	bool ApplyChange = false;
	switch(data2.WhatPrescript)
	{
		case PT_TakeDamage:
		{
			data2.Current += damage;
			ApplyChange = true;
			CurrentPrescript[victim].SetArray(0, data);
		}
		case PT_DontTakeDamage:
		{
			data2.Current = GetGameTime();
			ApplyChange = true;
		}
	}
	if(ApplyChange)
		IndexFather_SetScriptData(victim, data, data2.Current);
}
public void IndexFather_TakeDamageDeal(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(HasSpecificBuff(attacker, "Sizzling Wound"))
		damage *= 1.1;

	damage *= float(GraceOfPrescript[attacker]) * 0.1;
	if(CheckInHud())
		return;

	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;

	StatusEffects_PoiseAddStuff(attacker, 1, 2.0);
	switch(i_CurrentWeaponSet[attacker])
	{
		case PrescriptWeapon_Hatchet:
		{
			StatusEffects_PoiseAddStuff(attacker, 1, 1.5);
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_1);
		}
		case PrescriptWeapon_Hammer:
		{
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_2);

		}
		case PrescriptWeapon_Whip:
		{
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_3);
			
		}
		case PrescriptWeapon_Stiletto:
		{
			ApplyStatusEffect(victim, attacker, "Sinking", 10.0);
			StatusEffects_SinkingDebuffAdd(victim, 1);
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_4);
		}
		case PrescriptWeapon_Rapier:
		{
			StatusEffects_FragileAddStuff(attacker,victim, 1, 1.5);
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_5);
		}
		case PrescriptWeapon_Lance:
		{
			StatusEffects_FragileAddStuff(attacker, victim, 1, 1.5);
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_6);
		}
		case PrescriptWeapon_Bastardsword:
		{
			ApplyStatusEffect(attacker, attacker, "Oceanic Singing", 1.0);
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_7);
		}
		case PrescriptWeapon_Greatsword:
		{
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_8);
		}
		case PrescriptWeapon_Sycthe:
		{
			AddWeaponToFurioso(attacker, IDX_FURI_WEAPON_9);
			damage *= 1.3;
		}
	}
	if(CurrentPrescript[attacker] == null)
	{
		return;
	}
	ThePrescript data;
	CurrentPrescript[attacker].GetArray(0, data);
	if(!IndexFather_PrescriptPassRestriction(attacker, data))
	{
		return;
	}
	Prescript data2;
	IndexFather_WhichScriptCurrent(data, data2);
	bool ApplyChange = false;
	switch(data2.WhatPrescript)
	{
		case PT_DealDamage:
		{
			data2.Current += damage;
			ApplyChange = true;
			CurrentPrescript[attacker].SetArray(0, data);
		}
		case PT_HitEnemyFromBehind:
		{
			if(IsBehindAndFacingTarget(attacker, victim))
			{
				data2.Current += damage;
				ApplyChange = true;
				CurrentPrescript[attacker].SetArray(0, data);
			}
		}
	}
	if(ApplyChange)
		IndexFather_SetScriptData(attacker, data, data2.Current);
}
void IndexFather_PrescriptEnd(int client, bool Win)
{
	if(Win)
	{
		EmitSoundToClient(client, g_SuccessPrescript[GetRandomInt(0, sizeof(g_SuccessPrescript) - 1)], client, SNDCHAN_STATIC, 80, _, 0.8, 110);
		float NewScript = GetRandomFloat(180.0, 240.0);	
		PrescriptCooldown[client] = NewScript + GetGameTime();
		PrescriptPunishPlayerIgnoring[client] = (NewScript * 2.0) + GetGameTime();
		GivePrescriptGrace(client);
	}
	else
	{
		EmitSoundToClient(client, g_FailPrescript[GetRandomInt(0, sizeof(g_FailPrescript) - 1)], client, SNDCHAN_STATIC, 80, _, 0.8, 110);
		float NewScript = GetRandomFloat(30.0, 50.0);
		PrescriptCooldown[client] = NewScript + GetGameTime();
		PrescriptPunishPlayerIgnoring[client] = (NewScript * 2.0) + GetGameTime();
	}
	if(CurrentPrescript[client] != null)
	{
		delete CurrentPrescript[client];
	}
}

int IndexFather_NearAllies(int client, bool BehindAlly = false)
{
	int ally = GetClosestAlly(client, (300.0 * 300.0), client);
	if(BehindAlly && ally > 0)
	{
		if(IsBehindAndFacingTarget(client, ally))
			return 1;

	}
	else if(ally <= 0)
	{
		return 1;
	}
	return 0;

}

void IndexFather_WhichScriptCurrent(ThePrescript data, Prescript data2)
{
	if(!IndexFather_IsPrescriptfullfilled(data.CurrentGoal_1, false))
	{
		data2 = data.CurrentGoal_1;
		return;
	}
	data2 = data.CurrentGoal_2;
}
void IndexFather_SetScriptData(int client, ThePrescript data, float Add)
{
	if(!IndexFather_IsPrescriptfullfilled(data.CurrentGoal_1, false))
	{
		data.CurrentGoal_1.Current = Add;
		CurrentPrescript[client].SetArray(0, data);
	}
	else
	{
		data.CurrentGoal_2.Current = Add;
		CurrentPrescript[client].SetArray(0, data);
	}
}
int IndexFather_Spinning(int client, float angles[3])
{
	OptimiseCmd[client] = GetGameTime() + 0.15;
	static float PreviousVectors[MAXPLAYERS][3];

	if(GetDifferenceBetweenAngles(PreviousVectors[client], angles) >= 35.0)
	{
		PreviousVectors[client] = angles;
		return 1;
	}
	PreviousVectors[client] = angles;
	return 0;

}
bool IndexFather_PrescriptPassRestriction(int client, ThePrescript data)
{
	Prescript data2;
	IndexFather_WhichScriptCurrent(data, data2);
	if(data2.Addition == view_as<PrescriptAddition>(0))
	{
		return true;
	}

	switch(data2.Addition)
	{
		case PA_WhileInAir:
		{
			int fCurFlags1	= GetEntityFlags(client);
			if (!(fCurFlags1 & FL_ONGROUND))
			{
				return true;
			}
		}
		case PA_WhileLookingDown:
		{
			float Ang[3];
			GetClientEyeAngles(client, Ang);
			if(Ang[0] > 60.0)
			{
				return true;
			}
		}
		case PA_WhileLookingUp:
		{
			float Ang[3];
			GetClientEyeAngles(client, Ang);
			if(Ang[0] < -60.0)
			{
				return true;
			}
			
		}
		case PA_WhileCrouching:
		{
			
			if(GetClientButtons(client) & IN_DUCK)
			{
				return true;
			}
		}
	}
	return false;
}

stock float IndexFather_DamageDealTreshhold()
{
	int MinCashMaxGain = CurrentCash;
	if(MinCashMaxGain <= 1000)
		MinCashMaxGain = 1000;

	MinCashMaxGain -= 250;

	if(MinCashMaxGain >= 100000)
	{
		MinCashMaxGain = 100000;
	}
	
	float DamageForMaxCharge = (Pow(2.0 * MinCashMaxGain, 1.2) + MinCashMaxGain * 3.0);
	
	DamageForMaxCharge *= 0.25;
	DamageForMaxCharge *= 0.25;
	DamageForMaxCharge *= GetRandomFloat(0.75,1.25);
	return DamageForMaxCharge;
}
stock float IndexFather_DamageTakeTreshhold()
{
	int MinCashMaxGain = CurrentCash;

	MinCashMaxGain -= 750;

	if(MinCashMaxGain >= 100000)
	{
		MinCashMaxGain = 100000;
	}
	
	float DamageForMaxCharge = (Pow(2.0 * MinCashMaxGain, 1.2) + MinCashMaxGain * 3.0);
	
	DamageForMaxCharge *= 0.001;
	DamageForMaxCharge *= 0.25;
	DamageForMaxCharge *= GetRandomFloat(0.75,1.25);
	return DamageForMaxCharge;
}
void IndexFather_GrantVial(int client)
{
	if(IsValidEntity(i_PreviousWeapon[client]))
	{
		TF2_RemoveItem(client, EntRefToEntIndex(i_PreviousWeapon[client]));
	}
	Store_GiveSpecificItem(client, "Golden Vial With a Chain");
	for(int i; i < sizeof(g_AllWeaponsExist); i++)
	{
		Store_RemoveSpecificItem(client, g_AllWeaponsExist[i]);
	}
	EmitSoundToAll(g_GenerateRandomWeapon[GetRandomInt(0, sizeof(g_GenerateRandomWeapon) - 1)], client, SNDCHAN_STATIC, 70, _, 0.8, 100);
}

void IndexFather_GrantRandomWeapon(int client, int originalweapon)
{
	Store_RemoveSpecificItem(client, "Golden Vial With a Chain", true);
	if(IsValidEntity(i_PreviousWeapon[client]))
	{
		TF2_RemoveItem(client, EntRefToEntIndex(i_PreviousWeapon[client]));
	}
	int weapon_index = Store_GiveSpecificItem(client, g_AllWeaponsExist[GetRandomInt(0, sizeof(g_AllWeaponsExist) - 1)]);

	if(weapon_index == -1)
		return;

	EntityFuncPlayerRunCmd[weapon_index]  	=  EntityFuncPlayerRunCmd[originalweapon];	
	EntityFuncTakeDamage[weapon_index][0] 	=  EntityFuncTakeDamage[originalweapon][0];	
	EntityFuncTakeDamage[weapon_index][1]  	=  EntityFuncTakeDamage[originalweapon][1];	
	EntityFuncTakeDamage[weapon_index][2] 	=  EntityFuncTakeDamage[originalweapon][2];	
	EntityFuncOnKill[weapon_index]  		=  EntityFuncOnKill[originalweapon];	
	EntityOnAllyInteract[weapon_index]  	=  EntityOnAllyInteract[originalweapon];	
	EntityCustomTraceMelee[weapon_index] 	=  EntityCustomTraceMelee[originalweapon];	
	EntityOnBuildObject[weapon_index] 		=  EntityOnBuildObject[originalweapon];	
	i_CurrentWeaponSet[client] = GetRandomInt(0, sizeof(g_AquireNewWeapon) - 1);
	EmitSoundToAll(g_AquireNewWeapon[i_CurrentWeaponSet[client]], client, SNDCHAN_STATIC, 70, _, 0.8, 100);
	i_PreviousWeapon[client] = EntIndexToEntRef(weapon_index);
}
void Func_DodgesHud(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	if(f_DodgeCooldown[victim] && f_DodgeCooldown[victim] < GetGameTime())
	{
		f_DodgeCooldown[victim] = 0.0;
		i_DodgesAvailable[victim] = IndexFather_DodgeMaxReturn(victim);
	}
	if(f_DodgeCooldown[victim] > GetGameTime())
		Format(HudToDisplay, SizeOfChar, "⮌(%.1fs)", f_DodgeCooldown[victim] - GetGameTime());
	else
		Format(HudToDisplay, SizeOfChar, "⮌(%i)", i_DodgesAvailable[victim]);
}
float Func_Dodge_TakeDamage(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	if(CheckInHud())
		return 1.0;
	bool DoDodge = false;
	if(i_DodgesAvailable[victim] <= 0)
		return 1.0;

	if(f_DodgeActive[victim] > GetGameTime())
	{
		DoDodge = true;
	}

	if(DoDodge)
	{
		i_DodgesAvailable[victim]--;
		DoDodgeEffect(victim);
		if(i_DodgesAvailable[victim] <= 0)
		{
			i_DodgesAvailable[victim] = 0;
			f_DodgeCooldown[victim] = GetGameTime() + 25.0;
		}
		return 0.0;
	}
	return 1.0;
}	

public void IndexFather_DodgeLogic(int client)
{
	if(Handle_Timer[client] == null)
	{
		SDKUnhook(client, SDKHook_PreThink, IndexFather_DodgeLogic);
		return;
	}
	
	if(f_ResetMoveSpeedPenalty[client] && f_ResetMoveSpeedPenalty[client] < GetGameTime())
	{
		f_Client_BackwardsWalkPenalty[client] = f_Weapon_BackwardsWalkPenalty[EntRefToEntIndex(i_PreviousWeapon[client])];
		f_ResetMoveSpeedPenalty[client] = 0.0;
		f_Client_LostFriction[client] = 0.1;
	}

	if(dieingstate[client] != 0)
		return;


	static int holding[MAXPLAYERS];
	int buttons = GetClientButtons(client);
	if(holding[client] & IN_ATTACK2)
	{
		if(!(buttons & IN_ATTACK2))
			holding[client] &= ~IN_ATTACK2;

		return;
	}
	else
	{
		if(!(buttons & IN_ATTACK2))
			return;

		holding[client] |= IN_ATTACK2;
	}

	//only continune if they tapped reload.
	float AngleDeviate = 0.0;
	if((buttons & IN_MOVELEFT))
	{
		AngleDeviate += 90.0;
		if((buttons & IN_BACK))
			AngleDeviate += 45.0;
		else if((buttons & IN_FORWARD))
			AngleDeviate -= 45.0;
		//Dodge to left
	}
	if((buttons & IN_MOVERIGHT))
	{
		AngleDeviate -= 90.0;
		if((buttons & IN_BACK))
			AngleDeviate -= 45.0;
		else if((buttons & IN_FORWARD))
			AngleDeviate += 45.0;
		//Dodge to right
	}
	if(AngleDeviate == 0.0 && (buttons & IN_BACK))
	{
		AngleDeviate += 180.0;
		//Dodge to back
	}
	if(AngleDeviate == 0.0 && (buttons & IN_FORWARD))
	{
		AngleDeviate += 0.01;
		//Dodge to .... front?
	}

	//Not holding Reload. block.
	//wasnt dodging.
	if(AngleDeviate == 0.0)
		return;

	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	{
		
	}
	else
	{
		//NOT IN AIR!!!
		return;
	}
	if(f_DodgeBetweenDashes[client] > GetGameTime())
		return;
	if(i_DodgesAvailable[client] <= 0)
	{
		float Ability_CD = f_DodgeCooldown[client] - GetGameTime();

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	i_DodgesAvailable[client] -= 5;
	if(i_DodgesAvailable[client] <= 0)
	{
		i_DodgesAvailable[client] = 0;
		f_DodgeCooldown[client] = GetGameTime() + 25.0;
	}
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(weapon))
		Rogue_OnAbilityUse(client, weapon);


	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	anglesB[1] += AngleDeviate;
	anglesB[0] = 0.0;
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 800.0;
	TF2_AddCondition(client, TFCond_LostFooting, 0.15);
	TF2_AddCondition(client, TFCond_AirCurrent, 0.15);
	// knockback is the overall force with which you be pushed, don't touch other stuff
	ScaleVector(velocity, knockback);
	f_Client_BackwardsWalkPenalty[client] = 1.0;
	f_Client_LostFriction[client] = 0.0;
	f_ResetMoveSpeedPenalty[client] = GetGameTime() + 0.15;
	f_DodgeBetweenDashes[client] = GetGameTime() + 0.15;
	f_DodgeActive[client] = GetGameTime() + 0.25;

	EmitSoundToAll("passtime/projectile_swoosh3.wav", client, SNDCHAN_STATIC,80,_,1.0, GetRandomInt(100, 105));
	float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
	
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	//Not holding Reload. block.
}

void GivePrescriptGrace(int client)
{
	GraceOfPrescript[client]++;

	if(GraceOfPrescript[client] >= 9)
	{
		GraceOfPrescript[client] = 9;
	}
}

public void IndexFather_AbilityR(int client, int weapon, bool &result, int slot)
{
	if(GetClientButtons(client) & IN_DUCK)
	{
		if(!HasSpecificBuff(client, "Sizzling Wound") && dieingstate[client] > 0)
		{
			//force revive yourself and gain the debuff sizzling wound
			ApplySizzlingWound(client);
			dieingstate[client] = 0;
			i_CurrentEquippedPerk[client] = i_CurrentEquippedPerkPreviously[client];
			ForcePlayerCrouch(client, false);
			Store_ApplyAttribs(client);
			SDKCall_SetSpeed(client);
			int entity, i;
			while(TF2U_GetWearable(client, entity, i))
			{
				if(i_WeaponVMTExtraSetting[entity] != -1)
					continue;

				SetEntityRenderMode(entity, RENDER_NORMAL);
				SetEntityRenderColor(entity, 255, 255, 255, 255);
			}
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			SetEntityCollisionGroup(client, 5);
			DoOverlay(client, "", 2);
			SetEntityMoveType(client, MOVETYPE_WALK);

			SetEntityHealth(client, 50);
			Rogue_TriggerFunction(Artifact::FuncRevive, client);

			HealEntityGlobal(client, client, float(SDKCall_GetMaxHealth(client)), (i_CurrentEquippedPerk[client] & PERK_REGENE) ? 0.2 : 0.1, 1.0, HEAL_ABSOLUTE);

			GiveCompleteInvul(client, 1.5);
			CheckLastMannStanding(0);
		}
		return;
	}
	if(!FuriosoReady(client))
		return;
}


void ApplySizzlingWound(int client)
{
	ApplyStatusEffect(client, client, "Sizzling Wound", 60.0 * 6.0);
}


void Func_GraceOfPrescript(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar, "༅(%i)", GraceOfPrescript[victim]);
}
void Func_FuriosoHud(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar, "ᚫ(%i/9)", FuriosoReady(victim));
}
void AddWeaponToFurioso(int attacker, int flag)
{
	i_FuriosoReady[attacker] |= flag;
}
int FuriosoReady(int attacker)
{
	int ReadyFurioso = 0;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_1)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_2)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_3)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_4)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_5)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_6)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_7)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_8)
		ReadyFurioso++;
	if(i_FuriosoReady[attacker] & IDX_FURI_WEAPON_9)
		ReadyFurioso++;

	return ReadyFurioso;
}

int IndexFather_DodgeMaxReturn(int client)
{
	return 50;
}