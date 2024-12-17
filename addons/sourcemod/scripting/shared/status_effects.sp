


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

	char HudDisplay[2]; //what it should say in the damage or hurt hud
	char AboveEnemyDisplay[2]; //Should it display above their head, like silence X
	float DamageTakenMulti; //Resistance or vuln
	float DamageDealMulti;	//damage buff or nerf
	bool Positive;//Is it a good buff, if yes, do true
	bool ShouldScaleWithPlayerCount; 
	int Slot; 
	int SlotPriority; 
	//If its a buff like the medigun buff where it only affects 1 more person, then it shouldnt do anything.


	//Incase more complex stuff is needed, afaik nothing should use this right now.
	Function OnTakeDamage_TakenFunc;
	Function OnTakeDamage_DealFunc;

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

	void ApplyStatusEffect_Internal(int owner, int victim, bool HadBuff, int ArrayPosition)
	{
		if(!E_AL_StatusEffects[victim])
			E_AL_StatusEffects[victim] = new ArrayList(sizeof(E_StatusEffect));

		Apply_StatusEffect.TotalOwners[owner] = true;

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
		();
}

int StatusEffect_AddGlobal(StatusEffect data)
{
	return AL_StatusEffects.PushArray(data);
}


void StatusEffects_TeslarStick()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Teslar Shock");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌁");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 1.25;
	data.DamageDealMulti			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 1; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Teslar Electricution");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⏧");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 1.35;
	data.DamageDealMulti			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 1;
	data.SlotPriority				= 2;
	StatusEffect_AddGlobal(data);
}

void ApplyStatusEffect(int owner, int victim, const char[] name, float Duration)
{
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
	int CurrentSlotSaved = AL_StatusEffects.Slot;
	int CurrentPriority = AL_StatusEffects.SlotPriority;
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
	Apply_StatusEffect.ApplyStatusEffect_Internal(owner, entity, HadBuffBefore, ArrayPosition);
}
