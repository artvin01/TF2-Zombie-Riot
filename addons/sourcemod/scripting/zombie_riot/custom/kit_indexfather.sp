#pragma semicolon 1
#pragma newdecls required

static Handle Handle_Timer[MAXPLAYERS] = {null, ...};
static ArrayList CurrentPrescript[MAXPLAYERS];

enum PrescriptAddition
{
	PA_WhileInAir,
	PA_WhileLookingDown,
	PA_WhileLookingUp,
	PA_WhileCrouching,
}
/*
	Example:
	PA_WhileInAir + PT_DealDamage -> PT_WhileCrouching + PT_SpinInPlace -> 50 seconds

	While in the air, Deal 5015 Damage, Then While Crouching, Spin in place for 3 seconds, you have 50 seconds.

*/
enum PrescriptType
{
	PT_StandStill, 			//Stand still
	PT_KillTarget,			//Kill specific target
	PT_UseSpecificBuilding, //Use any building with what it asks
	PT_DealDamage,			
	PT_TakeDamage,			
	PT_DontTakeDamage,
	PT_Taunt,
	PT_Jump,
	PT_JumpSpecificTime,	//i.e. only jump 6 times
	PT_HitEnemyFromBehind,
	PT_StayAwayFromAllies,
	PT_TalkToAllies,		//Pressing R on rebel or grigori, if neither are present, it auto wins you
	PT_BuildSpecicBuilding,
	PT_DodgeSuccessfully, 	//Kit will have a build in dodge, this requires you to dodge
	PT_SpinInPlace,			//Spin in place
	PT_HumpAlly,			//Spam W and S behind an ally, if no ally is present, autowins
}
enum struct Prescript
{
	float Goal;
	float Current;
	float ExtraInfo;
	PrescriptType WhatPrescript;
	PrescriptAddition Addition;
	
}
enum struct ThePrescript
{
	Prescript CurrentGoal_1;
	Prescript CurrentGoal_2;
	float Timelimit;
}

void IndexFather_MapStart()
{

}
void IndexFather_WeaponLoad(int client, int weapon)
{
	IndexFather_GeneratePrescript(client, false);
}


void IndexFather_GeneratePrescript(int client, bool ForceNew)
{
	if(CurrentPrescript[client] != null)
	{
		if(!ForceNew)
			return;
		//Make a new script?
		delete CurrentPrescript[client];
	}
	CurrentPrescript[client] = new ArrayList(sizeof(ThePrescript));
	ThePrescript data;

	CurrentPrescript[client].GetArray(0, data);

	if(GetRandomInt(1,4) == 1)
		data.Timelimit = FAR_FUTURE; //infinite
	else
		data.Timelimit = GetGameTime() + GetRandomFloat(30.0,60.0);



	PrescriptType SelectRandom = GetRandomInt(0, sizof(PrescriptType));


	if(GetRandomInt(1,4) == 1)
	{
		data.CurrentGoal_2.Goal
	}
}

Prescript IndexFather_SelectRandomGoal()
{
	Prescript data;

	PrescriptType SelectRandom = GetRandomInt(0, sizof(PrescriptType));

	switch(SelectRandom)
	{
		case PT_StandStill:
		{
			data.Goal = GetRandomFloat(3.0, 6.0);
		}
		case PT_KillTarget:
		{
			data.Goal = RoundFloat(GetRandomFloat(1.0, 5.0));
		}
		case PT_UseSpecificBuilding:
		{
			data.Goal = RoundFloat(GetRandomFloat(1.0, 2.0));
		}
		case PT_DealDamage:
		{
			
		}
		case PT_TakeDamage:
		{
			
		}
		case PT_DontTakeDamage:
		{
			
		}
		case PT_Taunt:
		{
			
		}
		case PT_Jump:
		{
			
		}
		case PT_JumpSpecificTime:
		{
			
		}
		case PT_HitEnemyFromBehind:
		{
			
		}
		case PT_StayAwayFromAllies:
		{
			
		}
		case PT_TalkToAllies:
		{
			
		}
		case PT_BuildSpecicBuilding:
		{
			
		}
		case PT_DodgeSuccessfully:
		{
			
		}
		case PT_SpinInPlace:
		{
			
		}
		case PT_HumpAlly:
		{
			
		}
		default:
		{
			LogStackTrace("Error! Prescript is undefined!");
			PrintToChatAll("Error! Prescript is undefined! Report to an admin!");
		}
	}


	return data;
}