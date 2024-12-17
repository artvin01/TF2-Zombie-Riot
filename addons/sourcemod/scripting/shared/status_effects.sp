


static ArrayList AL_StatusEffects;

//AL_StatusEffects.GetArray(BuffIndex, )

enum struct StatusEffect
{
	char BuffName[64];			 //Used to identify
	//Desc is just, the name + desc
	/*
	Example:
	Teslar Electric
	Desc will be:
	Texlar Electric Desc
	*/

	char HudDisplay[4]; //what it should say in the damage or hurt hud
	char AboveEnemyDisplay[4]; //Should it display above their head, like silence X
	float DamageTakenMulti; //Resistance or vuln
	float DamageDealMulti;	//damage buff or nerf
	float MovementspeedModif;	//damage buff or nerf
	bool Positive;//Is it a good buff, if yes, do true
	bool ShouldScaleWithPlayerCount; 
	int Slot; 
	int SlotPriority; 
	//If its a buff like the medigun buff where it only affects 1 more person, then it shouldnt do anything.


	//Incase more complex stuff is needed.
	//See Enfeeble
	Function OnTakeDamage_TakenFunc;
	Function OnTakeDamage_DealFunc;
	Function Status_SpeedFunc;
}



static ArrayList E_AL_StatusEffects[MAXENTITIES];

enum struct E_StatusEffect
{
	bool TotalOwners[MAXENTITIES];
	/*
		Example: Teslar stick gives 25% more damage
		on a full server it would nerf that bonus to 8%
		however the user would outright get less from it and their DPS drops
		This would solve the issue where, if the owner actually applied it, they'd get the max benifit (or only more)
	*/
	float TimeUntillOver;
	int BuffIndex;

	//This is used for function things
	float DataForUse;

	void ApplyStatusEffect_Internal(int owner, int victim, bool HadBuff, int ArrayPosition)
	{
		if(!E_AL_StatusEffects[victim])
			E_AL_StatusEffects[victim] = new ArrayList(sizeof(E_StatusEffect));

		this.TotalOwners[owner] = true;

		if(!HadBuff)
			E_AL_StatusEffects[victim].PushArray(this);
		else
			E_AL_StatusEffects[victim].SetArray(ArrayPosition, this);
	}
}


void InitStatusEffects()
{
	//First delete everything
	delete AL_StatusEffects;
	AL_StatusEffects = new ArrayList(sizeof(StatusEffect));

	for(int c = 0; c < MAXENTITIES; c++)
	{
		delete E_AL_StatusEffects[c];
	}
	//clear all existing ones
	StatusEffects_TeslarStick();
	StatusEffects_Ludo();
	StatusEffects_Cryo();
	StatusEffects_PotionWand();
	StatusEffects_Enfeeble();
}

int StatusEffect_AddGlobal(StatusEffect data)
{
	return AL_StatusEffects.PushArray(data);
}


void ApplyStatusEffect(int owner, int victim, const char[] name, float Duration)
{
	StatusEffect_Expired(victim);
	int index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);
	if(index == -1)
	{
		CPrintToChatAll("{crimson} A DEV FUCKED UP!!!!!!!!! Name %s GET AN ADMIN RIGHT NOWWWWWWWWWWWWWW!^!!!!!!!!!!!!!!!!!!one111 (more then 0)",name);
		LogError("ApplyStatusEffect A DEV FUCKED UP!!!!!!!!! Name %s",name);
		return;
	}
	StatusEffect Apply_MasterStatusEffect;
	E_StatusEffect Apply_StatusEffect;
	AL_StatusEffects.GetArray(index, Apply_MasterStatusEffect);
	int CurrentSlotSaved = Apply_MasterStatusEffect.Slot;
	int CurrentPriority = Apply_MasterStatusEffect.SlotPriority;
	if(CurrentSlotSaved > 0)
	{
		//This debuff has slot logic, this means we should see which debuff is prioritised
		if(E_AL_StatusEffects[victim])
		{
			//We need to see if they have a currently prioritised buff/debuff already
			//loop through the existing debuffs?
			int length = E_AL_StatusEffects[victim].Length;
			for(int i; i<length; i++)
			{
				E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
				AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
				if(CurrentSlotSaved == Apply_MasterStatusEffect.Slot)
				{
					if(CurrentPriority > Apply_MasterStatusEffect.SlotPriority)
					{
						// New buff is high priority, remove this one, stop the loop
						E_AL_StatusEffects[victim].Erase(i);
						break;
					}
					else if(CurrentPriority < Apply_MasterStatusEffect.SlotPriority)
					{
						// New buff is low priority, Extend the stronger one if this one is longer
						index = Apply_StatusEffect.BuffIndex;
						break;
					}
				}
			}
		}
		//if this was false, then they had none, ignore.
	}


	bool HadBuffBefore = false;
	int ArrayPosition;
	if(E_AL_StatusEffects[victim])
	{
		ArrayPosition = E_AL_StatusEffects[victim].FindValue(index, E_StatusEffect::BuffIndex);
		if(ArrayPosition != -1)
		{
			HadBuffBefore = true;
			E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
			float CurrentTime = Apply_StatusEffect.TimeUntillOver - GetGameTime();
			if(Duration > CurrentTime)
			{
				//longer duration was found, override.
				Apply_StatusEffect.TimeUntillOver = GetGameTime() + Duration;
			}
		}
		else
		{		
			Apply_StatusEffect.TimeUntillOver = GetGameTime() + Duration;
		}
	}
	else
	{		
		Apply_StatusEffect.TimeUntillOver = GetGameTime() + Duration;
	}
	Apply_StatusEffect.BuffIndex = index;
	Apply_StatusEffect.ApplyStatusEffect_Internal(owner, victim, HadBuffBefore, ArrayPosition);
}

void StatusEffect_Expired(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return;

	//No debuffs or status effects, skip.
	static E_StatusEffect Apply_StatusEffect;
	int length = E_AL_StatusEffects[victim].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
		}
	}
	//There are no buffs left, delete.
	if(length < 0)
	{
		delete E_AL_StatusEffects[victim];
	}
}
void StatusEffectReset(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return;

	delete E_AL_StatusEffects[victim];
}

//any buff that gives you resistances
void StatusEffect_OnTakeDamage_TakenPositive(int victim, int attacker, float &damage)
{
	if(!E_AL_StatusEffects[victim])
		return;

	float DamageRes = 1.0;
	
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	int length = E_AL_StatusEffects[victim].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_MasterStatusEffect.DamageTakenMulti == -1.0)
		{
			//Skip.
			continue;
		}
		if(!Apply_MasterStatusEffect.Positive)
		{
			//Not positive. skip.
			continue;
		}
		if(!Apply_MasterStatusEffect.ShouldScaleWithPlayerCount || Apply_StatusEffect.TotalOwners[attacker])
		{
			damage *= Apply_MasterStatusEffect.DamageTakenMulti;
		}
		else
		{
			DamageRes *= Apply_MasterStatusEffect.DamageTakenMulti;
		}
	}
#if defined ZR
	if(RaidbossIgnoreBuildingsLogic(1) && GetTeam(victim) == TFTeam_Red)
	{
		//invert, then convert!
		float NewRes = 1.0 + ((DamageRes - 1.0) * PlayerCountResBuffScaling);
		DamageRes = NewRes;
	}
#endif
	
	damage *= DamageRes;	
}

//any buff that makes you deal less damage
void StatusEffect_OnTakeDamage_DealNegative(int victim, int attacker, float &damage)
{
	if(!E_AL_StatusEffects[attacker])
		return;

	float DamageRes = 1.0;
	
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	int length = E_AL_StatusEffects[attacker].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[attacker].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_MasterStatusEffect.DamageDealMulti == -1.0)
		{
			//Skip.
			continue;
		}
		if(!Apply_MasterStatusEffect.Positive)
		{
			//Not positive. skip.
			continue;
		}
		float DamageToNegate = Apply_MasterStatusEffect.DamageDealMulti;
		if(Apply_MasterStatusEffect.OnTakeDamage_DealFunc != INVALID_FUNCTION)
		{
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.OnTakeDamage_DealFunc);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect);
			Call_PushArray(Apply_StatusEffect);
			Call_Finish(DamageToNegate);
		}
		if(!Apply_MasterStatusEffect.ShouldScaleWithPlayerCount || Apply_StatusEffect.TotalOwners[victim])
		{
			damage *= DamageToNegate;
		}
		else
		{
			DamageRes *= DamageToNegate;
		}
	}
#if defined ZR
	if(RaidbossIgnoreBuildingsLogic(1) && GetTeam(victim) == TFTeam_Red)
	{
		//invert, then convert!
		float NewRes = 1.0 + ((DamageRes - 1.0) * PlayerCountResBuffScaling);
		DamageRes = NewRes;
	}
#endif
	
	damage *= DamageRes;	
}

//Damage vulnerabilities!
void StatusEffect_OnTakeDamage_TakenNegative(int victim, int attacker, int inflictor, float &damage)
{
	if(!E_AL_StatusEffects[victim])
		return;

	float basedamage = damage;
	
	float DamageBuffExtraScaling = 1.0;

#if defined ZR
	if(attacker <= MaxClients || inflictor <= MaxClients)
	{
		//only scale if its a player, and if the attacking npc is red too
		if(GetTeam(attacker) == TFTeam_Red || GetTeam(inflictor) == TFTeam_Red)
			DamageBuffExtraScaling = PlayerCountBuffScaling;
	}
#endif
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	int length = E_AL_StatusEffects[victim].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_MasterStatusEffect.DamageTakenMulti == -1.0)
		{
			//Skip.
			continue;
		}
		if(Apply_MasterStatusEffect.Positive)
		{
			//positive. skip.
			continue;
		}
		static float DamageBuffScalingDo;
		DamageBuffScalingDo = DamageBuffExtraScaling;
		if(!Apply_MasterStatusEffect.ShouldScaleWithPlayerCount || Apply_StatusEffect.TotalOwners[attacker])
		{
			//It does NOT Scale, OR the user is the owner, give full buff/boosted buff
			if(DamageBuffScalingDo <= 1.0)
			{
				DamageBuffScalingDo = 1.0;
			}
		}
		damage += basedamage * (Apply_MasterStatusEffect.DamageTakenMulti * DamageBuffExtraScaling);
	}
	damage += StatusEffect_OnTakeDamage_DealPositive(victim, attacker, inflictor, basedamage);
}


//Damage Buffs!
float StatusEffect_OnTakeDamage_DealPositive(int victim, int attacker, int inflictor, float basedamage)
{
	if(!E_AL_StatusEffects[attacker])
		return 0.0;
	float DamageAdd;
	float DamageBuffExtraScaling = 1.0;

#if defined ZR
	if(attacker <= MaxClients || inflictor <= MaxClients)
	{
		//only scale if its a player, and if the attacking npc is red too
		if(GetTeam(attacker) == TFTeam_Red || GetTeam(inflictor) == TFTeam_Red)
			DamageBuffExtraScaling = PlayerCountBuffScaling;
	}
#endif
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	int length = E_AL_StatusEffects[attacker].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[attacker].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_MasterStatusEffect.DamageDealMulti == -1.0)
		{
			//Skip.
			continue;
		}
		if(!Apply_MasterStatusEffect.Positive)
		{
			//Not positive. skip.
			continue;
		}
		static float DamageBuffScalingDo;
		DamageBuffScalingDo = DamageBuffExtraScaling;
		if(!Apply_MasterStatusEffect.ShouldScaleWithPlayerCount || Apply_StatusEffect.TotalOwners[attacker])
		{
			//It does NOT Scale, OR the user is the owner, give full buff/boosted buff
			if(DamageBuffScalingDo <= 1.0)
			{
				DamageBuffScalingDo = 1.0;
			}
		}
		DamageAdd += basedamage * (Apply_MasterStatusEffect.DamageDealMulti * DamageBuffExtraScaling);
	}
	return DamageAdd;
}


//strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty

void StatusEffects_HudHurt(int victim, int attacker, char[] Debuff_Adder_left, char[] Debuff_Adder_right, int SizeOfChar)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	int length = E_AL_StatusEffects[victim].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		//left are debuffs
		//Right are buffs
		if(!Apply_MasterStatusEffect.HudDisplay[0])
			continue;

		if(!Apply_MasterStatusEffect.Positive)
		{
			Format(Debuff_Adder_left, SizeOfChar, "%s%s", Apply_MasterStatusEffect.HudDisplay, Debuff_Adder_left);
		}
		else
		{
			Format(Debuff_Adder_right, SizeOfChar, "%s%s", Apply_MasterStatusEffect.HudDisplay, Debuff_Adder_right);
		}
	}
}

void StatusEffects_HudAbove(int victim, int attacker, char[] HudAbove, int SizeOfChar)
{
	if(!E_AL_StatusEffects[victim])
		return;
		
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	int length = E_AL_StatusEffects[victim].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(!Apply_MasterStatusEffect.AboveEnemyDisplay[0])
			continue;

		Format(HudAbove, SizeOfChar, "%s%s", Apply_MasterStatusEffect.AboveEnemyDisplay, HudAbove);
	}
}

//Speed Buff modif!
void StatusEffect_SpeedModifier(int victim, float &SpeedModifPercentage)
{
	if(!E_AL_StatusEffects[victim])
		return;
	StatusEffect_Expired(victim);

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;

	static float TotalSlowdown;
	TotalSlowdown = SpeedModifPercentage;

	static float Effectiveness;
	Effectiveness = 1.0;

	if(b_thisNpcIsARaid[victim]) 		//Only 15% as effective
		Effectiveness = 0.25;
	else if(b_thisNpcIsABoss[victim]) 	//only 35% as effective
		Effectiveness = 0.4;

	bool SpeedWasNerfed = false
	int length = E_AL_StatusEffects[victim].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_MasterStatusEffect.MovementspeedModif == -1.0)
		{
			//Skip.
			continue;
		}
		if(Apply_MasterStatusEffect.Positive)
		{
			//If its a positive buff, do No penalty
			SpeedModifPercentage *= Apply_MasterStatusEffect.MovementspeedModif;
		}
		else
		{
			SpeedWasNerfed = true;
			TotalSlowdown *= Apply_MasterStatusEffect.MovementspeedModif;
		}
	}
	//speed debuffs will now behave the excat same as damage buffs
	if(SpeedWasNerfed)
		SpeedModifPercentage -= (TotalSlowdown * Effectiveness);
}


void StatusEffects_TeslarStick()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Teslar Shock");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌁");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.2;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.25;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 1; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Teslar Electricution");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⏧");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.25;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.35;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 1;
	data.SlotPriority				= 2;
	StatusEffect_AddGlobal(data);
}


void StatusEffects_Ludo()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Ludo-Maniancy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "^");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.10;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Spade Ludo-Maniancy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "^^");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.12;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
}


void StatusEffects_Cryo()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Freeze");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❉");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.05;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.05;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 2; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Cryo");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❆");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.10;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.10;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 2;
	data.SlotPriority				= 2;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Near Zero");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❈");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.15;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.15;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 2;
	data.SlotPriority				= 3;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Frozen");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "F");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.15;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.15;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
}

void StatusEffects_PotionWand()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Shrinking");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "▼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.35;
	data.DamageDealMulti			= 0.75;
	data.MovementspeedModif			= 0.5;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_Enfeeble()
{
	//dont display as its a direct cause of elemental
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Enfeeble");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.0;
	//Make sure it isnt ignored, set it to 0.0, on need for extra func checks either.
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_DealFunc 		= view_as<func>(Enfeeble_Internal_DamageDealFunc);
	StatusEffect_AddGlobal(data);
}

float Enfeeble_Internal_DamageDealFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	// Enfeeble fades out with time
	float resist = (Apply_StatusEffect.TimeUntillOver - GetGameTime()) / 15.0;
	if(resist < 0.9)
		resist = 0.9;
	
	return resist;
}

void StatusEffects_BuildingAntiRaid()
{
	//dont display as its a direct cause of elemental
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Iberia's Anti Raid");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "R");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.1;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}