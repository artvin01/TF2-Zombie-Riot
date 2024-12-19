


static ArrayList AL_StatusEffects;

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
	Function HudDisplay_Func;
}


static const char Categories[][] =
{
	"Positive",
	"Negative",
};


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

		if(owner > 0)
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
	StatusEffects_BuildingAntiRaid();
	StatusEffects_WidowsWine();
	StatusEffects_CrippleDebuff();
	StatusEffects_MagnesisStrangle();
	StatusEffects_Cudgel();
	StatusEffects_MaimDebuff();
	StatusEffects_Prosperity();
	StatusEffects_CombineCommander();
	StatusEffects_VoidLogic();
	StatusEffects_DebuffMarked();
	StatusEffects_Silence();
	StatusEffects_LogosDebuff();
	StatusEffects_Victoria();
	StatusEffects_Pernell();
	StatusEffects_Medieval();
	StatusEffects_SupportWeapons();
	StatusEffects_BobDuck();
	StatusEffects_ElementalWand();
	StatusEffects_FallenWarrior();
	StatusEffects_CasinoDebuff();
	StatusEffects_Ruiania();
	StatusEffects_WeaponSpecific_VisualiseOnly();
	StatusEffects_StatusEffectListOnly();
}

static int CategoryPage[MAXTF2PLAYERS];
void Items_StatusEffectListMenu(int client, int page = -1, bool inPage = false)
{
	Menu menu = new Menu(Items_StatusEffectListMenuH);
	SetGlobalTransTarget(client);

	if(inPage)
	{
		StatusEffect data;
		AL_StatusEffects.GetArray(page, data);
		

		char buffer[400];
		char buffer2[400];
		FormatEx(buffer, sizeof(buffer), "%s Desc", data.BuffName);
		if(TranslationPhraseExists(buffer))
		{
			Format(buffer, sizeof(buffer), "%t", buffer);

			menu.SetTitle("%s\n%t\n \n%s\n ", data.HudDisplay, data.BuffName, buffer);
		}
		else
		{
			menu.SetTitle("%s\n%t\n ", data.HudDisplay, data.BuffName);
		}
		
		IntToString(page, buffer2, sizeof(buffer2));
		FormatEx(buffer, sizeof(buffer), "%t", "Back");
		menu.AddItem(buffer2, buffer);

		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(page != -1)
	{
		//int kills;
		int pos;

		StatusEffect data;
		int length = AL_StatusEffects.Length;
		char buffer2[400];
		for(int i; i < length; i++)
		{
			AL_StatusEffects.GetArray(i, data);
			if(data.Positive != view_as<bool>(CategoryPage[client]))
			{
				IntToString(i, buffer2, sizeof(buffer2));
				Format(data.BuffName, sizeof(data.BuffName), "%s\n%s", data.HudDisplay, data.BuffName);

				if(i == page)
					pos = menu.ItemCount;
				
				menu.AddItem(buffer2, data.BuffName);
			}
		}

		menu.SetTitle("%t\n%t\n \n%t\n ", "TF2: Zombie Riot", "StatusEffectList", Categories[CategoryPage[client]]);

		menu.ExitBackButton = true;
		menu.DisplayAt(client, (pos / 7 * 7), MENU_TIME_FOREVER);
	}
	else
	{
		if(CategoryPage[client] < 0)
			CategoryPage[client] = 0;
		//menu.SetTitle("%t\n%t\n \n%t\n ", "TF2: Zombie Riot", "StatusEffectList", "Zombie Kills", kills);
		menu.SetTitle("%t\n%t\n ", "TF2: Zombie Riot", "StatusEffectList");

		char data[16], buffer[64];
		for(int i; i < sizeof(Categories); i++)
		{
			IntToString(i, data, sizeof(data));
			FormatEx(buffer, sizeof(buffer), "%s", Categories[i]);
			menu.AddItem(data, buffer);
		}

		menu.ExitBackButton = true;
		menu.DisplayAt(client, (CategoryPage[client] / 7 * 7), MENU_TIME_FOREVER);
		CategoryPage[client] = -1;
	}
}

public int Items_StatusEffectListMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				if(CategoryPage[client] == -1)
				{
					Store_Menu(client);
				}
				else
				{
					//char data[16];
					//if(menu.GetItem(1, data, sizeof(data)))	// Category -> Main
					{
						Items_StatusEffectListMenu(client, -1, false);
					}
					//else if(menu.GetItem(0, data, sizeof(data)))	// Item -> Category
					//{
					//	Items_StatusEffectListMenu(client, StringToInt(data), false);
					//}
				}
			}
			else
			{
				CategoryPage[client] = -1;
			}
		}
		case MenuAction_Select:
		{
			char buffer[16], data[16];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);

			if(CategoryPage[client] == -1)	// Main -> Category
			{
				CategoryPage[client] = id;
				Items_StatusEffectListMenu(client, 0, false);
			}
			else if(choice || menu.GetItem(1, data, sizeof(data)))	// Category -> Item
			{
				Items_StatusEffectListMenu(client, StringToInt(buffer), true);
			}
			else	// Item -> Category
			{
				Items_StatusEffectListMenu(client, StringToInt(buffer), false);
			}
		}
	}
	return 0;
}


int StatusEffect_AddGlobal(StatusEffect data)
{
	return AL_StatusEffects.PushArray(data);
}

void RemoveSpecificBuff(int victim, const char[] name)
{
	int index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);
	if(index == -1)
	{
		CPrintToChatAll("{crimson} A DEV FUCKED UP!!!!!!!!! Name %s GET AN ADMIN RIGHT NOWWWWWWWWWWWWWW!^!!!!!!!!!!!!!!!!!!one111 (more then 0)",name);
		LogError("ApplyStatusEffect A DEV FUCKED UP!!!!!!!!! Name %s",name);
		return;
	}
	E_StatusEffect Apply_StatusEffect;

	int ArrayPosition;
	if(E_AL_StatusEffects[victim])
	{
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		ArrayPosition = E_AL_StatusEffects[victim].FindValue(index, E_StatusEffect::BuffIndex);
		if(ArrayPosition != -1)
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		
		if(E_AL_StatusEffects[victim].Length < 1)
			delete E_AL_StatusEffects[victim];
	}
}

//Got lazy, tired of doing so many indexs.
bool HasSpecificBuff(int victim, const char[] name)
{
	int index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);
	if(index == -1)
	{
		CPrintToChatAll("{crimson} A DEV FUCKED UP!!!!!!!!! Name %s GET AN ADMIN RIGHT NOWWWWWWWWWWWWWW!^!!!!!!!!!!!!!!!!!!one111 (more then 0)",name);
		LogError("ApplyStatusEffect A DEV FUCKED UP!!!!!!!!! Name %s",name);
		return false;
	}
	E_StatusEffect Apply_StatusEffect;

	int ArrayPosition;
	if(E_AL_StatusEffects[victim])
	{
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		ArrayPosition = E_AL_StatusEffects[victim].FindValue(index, E_StatusEffect::BuffIndex);
		if(ArrayPosition != -1)
		{
			if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
			{
				E_AL_StatusEffects[victim].Erase(ArrayPosition);
			}
			else
			{
				return true;
			}
		}
		if(E_AL_StatusEffects[victim].Length < 1)
			delete E_AL_StatusEffects[victim];
	}
	return false;
}
void RemoveAllBuffs(int victim, bool RemoveGood)
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
		if(!Apply_MasterStatusEffect.Positive && !RemoveGood)
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
		else if(Apply_MasterStatusEffect.Positive && RemoveGood)
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
	}
	if(length < 1)
		delete E_AL_StatusEffects[victim];
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
	if(HasSpecificBuff(victim, "Hardened Aura"))
	{
		if(!Apply_MasterStatusEffect.Positive)
		{
			//Immunity to all debuffs, ignore.
			return;
		}
	}
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
				if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
				{
					E_AL_StatusEffects[victim].Erase(i);
					i--;
					length--;
					continue;
				}
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

//never usually needed
stock void StatusEffect_Expired(int victim)
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
	if(length < 1)
		delete E_AL_StatusEffects[victim];
}
void StatusEffectReset(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return;

	delete E_AL_StatusEffects[victim];
}

/*
bool StatusEffects_HasDebuffOrBuff(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return false;
	
	return true;
}
*/
//any buff that gives you resistances
/*
	Meaning the VICTIM gets LESS damage!!
*/
void StatusEffect_OnTakeDamage_TakenPositive(int victim, int attacker, float &damage, int damagetype)
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
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
		
		float DamageToNegate = Apply_MasterStatusEffect.DamageTakenMulti;
		if(Apply_MasterStatusEffect.OnTakeDamage_TakenFunc != INVALID_FUNCTION)
		{
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.OnTakeDamage_TakenFunc);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_PushCell(damagetype);
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
	if(length < 1)
		delete E_AL_StatusEffects[victim];
}

/*
	Me, as the attacker, will deal less damage towards other targets.
*/
void StatusEffect_OnTakeDamage_DealNegative(int victim, int attacker, float &damage, int damagetype)
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[attacker].Erase(i);
			i--;
			length--;
			continue;
		}
		if(Apply_MasterStatusEffect.DamageDealMulti == -1.0)
		{
			//Skip.
			continue;
		}
		if(Apply_MasterStatusEffect.Positive)
		{
			//Positive, skip
			continue;
		}
		float DamageToNegate = Apply_MasterStatusEffect.DamageDealMulti;
		if(Apply_MasterStatusEffect.OnTakeDamage_DealFunc != INVALID_FUNCTION)
		{
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.OnTakeDamage_DealFunc);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_PushCell(damagetype);
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
	if(length < 1)
		delete E_AL_StatusEffects[victim];
}

//Damage vulnerabilities, when i get HURT, this means i TAKE more damage
float StatusEffect_OnTakeDamage_TakenNegative(int victim, int attacker, int inflictor, float &basedamage, int damagetype)
{
	if(!E_AL_StatusEffects[victim])
		return 0.0;
	
	float ExtraDamageAdd;
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
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
		bool Ignore_NormalValue = false;
		if(Apply_MasterStatusEffect.OnTakeDamage_TakenFunc != INVALID_FUNCTION)
		{
			float DamageAdded;
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.OnTakeDamage_TakenFunc);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_PushCell(damagetype);
			Call_PushCell(basedamage);
			Call_PushFloat(DamageBuffScalingDo);
			Call_Finish(DamageAdded);
			ExtraDamageAdd += DamageAdded;
			Ignore_NormalValue = true;
		}
		if(!Ignore_NormalValue)
		{
			ExtraDamageAdd += basedamage * (Apply_MasterStatusEffect.DamageTakenMulti * DamageBuffScalingDo);
		}
	}
	if(length < 1)
		delete E_AL_StatusEffects[victim];

	return ExtraDamageAdd;
}

//Damage Buffs, when i attack!
float StatusEffect_OnTakeDamage_DealPositive(int victim, int attacker, int inflictor, float &basedamage, int damagetype)
{
	if(!E_AL_StatusEffects[attacker])
		return 0.0;

	float ExtraDamageAdd;
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[attacker].Erase(i);
			i--;
			length--;
			continue;
		}
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
		bool Ignore_NormalValue = false;
		
		if(!Apply_MasterStatusEffect.ShouldScaleWithPlayerCount || Apply_StatusEffect.TotalOwners[attacker])
		{
			//It does NOT Scale, OR the user is the owner, give full buff/boosted buff
			if(DamageBuffScalingDo <= 1.0)
			{
				DamageBuffScalingDo = 1.0;
			}
		}
		if(Apply_MasterStatusEffect.OnTakeDamage_DealFunc != INVALID_FUNCTION)
		{
			float DamageAdded;
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.OnTakeDamage_DealFunc);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_PushCell(damagetype);
			Call_PushCell(basedamage);
			Call_PushFloat(DamageBuffScalingDo);
			Call_Finish(DamageAdded);
			ExtraDamageAdd += DamageAdded;
			Ignore_NormalValue = true;
		}
		if(!Ignore_NormalValue)
		{
			ExtraDamageAdd += basedamage * (Apply_MasterStatusEffect.DamageDealMulti * DamageBuffExtraScaling);
		}
	}
	if(length < 1) 		
		delete E_AL_StatusEffects[attacker];

	return ExtraDamageAdd;
}


//strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty

void StatusEffects_HudHurt(int victim, int attacker, char[] Debuff_Adder_left, char[] Debuff_Adder_right, int SizeOfChar, int DisplayWeapon = -1)
{
	if(DisplayWeapon > 0)
	{
		//already checking weapon, so dont repeat!
		StatusEffects_HudHurt(DisplayWeapon, attacker, Debuff_Adder_left, Debuff_Adder_right, SizeOfChar, -1);
	}
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
		if(!Apply_MasterStatusEffect.HudDisplay[0])
			continue;
		
		if(Apply_MasterStatusEffect.HudDisplay_Func != INVALID_FUNCTION)
		{
			char HudDisplayCustom[12];
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.HudDisplay_Func);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_PushCell(sizeof(HudDisplayCustom));
			Call_PushStringEx(HudDisplayCustom, sizeof(HudDisplayCustom), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_Finish();

			if(!Apply_MasterStatusEffect.Positive)
			{
				Format(Debuff_Adder_left, SizeOfChar, "%s%s", HudDisplayCustom, Debuff_Adder_left);
			}
			else
			{
				Format(Debuff_Adder_right, SizeOfChar, "%s%s", HudDisplayCustom, Debuff_Adder_right);
			}
		}
		else
		{
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
	if(length < 1) 		
		delete E_AL_StatusEffects[victim];
}

void StatusEffects_HudAbove(int victim, char[] HudAbove, int SizeOfChar)
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
		if(!Apply_MasterStatusEffect.AboveEnemyDisplay[0])
			continue;

		Format(HudAbove, SizeOfChar, "%s%s", Apply_MasterStatusEffect.AboveEnemyDisplay, HudAbove);
	}
	if(length < 1) 		
		delete E_AL_StatusEffects[victim];
}

//Speed Buff modif!
void StatusEffect_SpeedModifier(int victim, float &SpeedModifPercentage)
{
	if(!E_AL_StatusEffects[victim])
		return;

	//No change
	if(b_CannotBeSlowed[victim])
		return;
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			length--;
			continue;
		}
		if(Apply_MasterStatusEffect.MovementspeedModif == -1.0)
		{
			//Skip.
			continue;
		}
		float SpeedModif = Apply_MasterStatusEffect.MovementspeedModif;
		if(Apply_MasterStatusEffect.Status_SpeedFunc != INVALID_FUNCTION)
		{
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.Status_SpeedFunc);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_Finish(SpeedModif);
		}
		if(Apply_MasterStatusEffect.Positive)
		{
			//If its a positive buff, do No penalty
			SpeedModifPercentage *= SpeedModif;
		}
		else
		{
			SpeedWasNerfed = true;
			TotalSlowdown *= SpeedModif;
		}
	}
	//speed debuffs will now behave the excat same as damage buffs
	if(SpeedWasNerfed)
		SpeedModifPercentage -= (TotalSlowdown * Effectiveness);

	//No magical backwards shit
	if(SpeedModifPercentage <= 0.0)
	{
		SpeedModifPercentage = 0.0;
	}
	if(length < 1) 		
		delete E_AL_StatusEffects[victim];
}

int LowTeslarIndex;
int HighTeslarIndex;
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
	LowTeslarIndex = StatusEffect_AddGlobal(data);

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
	HighTeslarIndex = StatusEffect_AddGlobal(data);


	strcopy(data.BuffName, sizeof(data.BuffName), "Specter's Aura");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₪");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.6;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Electric Impairability");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ꝿ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.8;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

stock bool NpcStats_IsEnemyTeslar(int victim, bool High)
{
	if(!E_AL_StatusEffects[victim])
		return false;

	int IndexCheck = LowTeslarIndex;
	if(High)
		IndexCheck = HighTeslarIndex;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(IndexCheck, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

void StatusEffects_Ludo()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Ludo-Maniancy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "L");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.10;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.2;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Spade Ludo-Maniancy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ḻ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.12;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.22;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
}

int Cryo1Index;
int Cryo2Index;
int Cryo3Index;
int Cryo4Index;
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
	Cryo1Index = StatusEffect_AddGlobal(data);

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
	Cryo2Index = StatusEffect_AddGlobal(data);

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
	Cryo3Index = StatusEffect_AddGlobal(data);

	//elemental, shouldnt show here.
	strcopy(data.BuffName, sizeof(data.BuffName), "Frozen");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.15;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.15;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	Cryo4Index = StatusEffect_AddGlobal(data);
}

stock bool NpcStats_IsEnemyFrozen(int victim, int TierDo)
{
	if(!E_AL_StatusEffects[victim])
		return false;

	int IndexCheck = Cryo1Index;
	
	switch(TierDo)
	{
		case 1:
			IndexCheck = Cryo1Index;
		case 2:
			IndexCheck = Cryo2Index;
		case 3:
			IndexCheck = Cryo3Index;
		case 4:
			IndexCheck = Cryo4Index;
	}

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(IndexCheck, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

int ShrinkingStatusEffectIndex;
void StatusEffects_PotionWand()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Shrinking");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "▼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.35;
	data.DamageDealMulti			= 0.75;
	data.MovementspeedModif			= 0.35;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	ShrinkingStatusEffectIndex = StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Golden Curse");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⯏");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.2;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

stock bool NpcStats_IsEnemyShank(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(ShrinkingStatusEffectIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
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
	data.OnTakeDamage_DealFunc 		= Enfeeble_Internal_DamageDealFunc;
	StatusEffect_AddGlobal(data);
}

float Enfeeble_Internal_DamageDealFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
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
void StatusEffects_WidowsWine()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Widows Wine");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "४");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.35;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.Status_SpeedFunc			= WidowsWine_SlowdownFunc;
	StatusEffect_AddGlobal(data);
}
float WidowsWine_SlowdownFunc(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	float slowdown_amount = Apply_StatusEffect.TimeUntillOver - GetGameTime();
	float max_amount = FL_WIDOWS_WINE_DURATION;
	slowdown_amount = slowdown_amount / max_amount;

	if(slowdown_amount > 0.8)
	{
		slowdown_amount = 0.8;
	}
	else if(slowdown_amount < 0.0)
	{
		slowdown_amount = 0.0;
	}
	
	return slowdown_amount;
}

void StatusEffects_CrippleDebuff()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Cripple");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⯯");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.3;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_MagnesisStrangle()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Stranglation I");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= MagnesisDamageBuff(0);
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 3; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Stranglation II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= MagnesisDamageBuff(1);
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 3; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	strcopy(data.BuffName, sizeof(data.BuffName), "Stranglation III");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= MagnesisDamageBuff(2);
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 3; //0 means ignored
	data.SlotPriority				= 3; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_Cudgel()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Cudgelled");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "‼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.3;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_MaimDebuff()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Maimed");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "↓");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.3;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.35;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}
void StatusEffects_Prosperity()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Prosperity I");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☯");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.95;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 4; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Prosperity II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☯");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.9;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 4; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Prosperity III");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☯");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.85;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 4; //0 means ignored
	data.SlotPriority				= 3; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_LogosDebuff()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Aeternam");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "#");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc = Aeternam_Internal_DamageTakenFunc;
	StatusEffect_AddGlobal(data);
}

float Aeternam_Internal_DamageTakenFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	float damagereturn = 0.0;
	if((damagetype & DMG_PLASMA) || (damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[victim] & ZR_DAMAGE_LASER_NO_BLAST))
	{
		damagereturn += basedamage * (0.1 * DamageBuffExtraScaling);
		damagereturn += 1500.0;
	}
	return damagereturn;
}

int SilenceIndex;
void StatusEffects_Silence()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Silenced");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "X");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "X"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	SilenceIndex = StatusEffect_AddGlobal(data);

	//Immunity to all Negative debuffs.
	strcopy(data.BuffName, sizeof(data.BuffName), "Hardened Aura");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "֏");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

stock bool NpcStats_IsEnemySilenced(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(SilenceIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

int DebuffMarkedIndex;
void StatusEffects_DebuffMarked()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Marked");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "M");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "X"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	DebuffMarkedIndex = StatusEffect_AddGlobal(data);
}

stock bool NpcStats_IberiaIsEnemyMarked(int victim)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(DebuffMarkedIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
		
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

int VoidStrengthIndex1;
int VoidStrengthIndex2;
void StatusEffects_VoidLogic()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Void Presence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌄");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 5; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Void Strength I");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "v");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "v"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= 0.0;
	data.MovementspeedModif			= 1.05;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 5; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= Void_Internal_1_DamageTakenFunc;
	data.OnTakeDamage_DealFunc 		= Void_Internal_1_DamageDealFunc;
	VoidStrengthIndex1 = StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Void Strength II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "vV");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "vV"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= 0.0;
	data.MovementspeedModif			= 1.15;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 5; //0 means ignored
	data.SlotPriority				= 3; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= Void_Internal_2_DamageTakenFunc;
	data.OnTakeDamage_DealFunc 		= Void_Internal_2_DamageDealFunc;
	VoidStrengthIndex2 = StatusEffect_AddGlobal(data);
}
float Void_Internal_1_DamageDealFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	float damagereturn = 0.0;
	if(NpcStats_IsEnemySilenced(victim))
		damagereturn += basedamage * (0.2 * DamageBuffExtraScaling);
	else
		damagereturn += basedamage * (0.1 * DamageBuffExtraScaling);
	return damagereturn;
}

float Void_Internal_2_DamageDealFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	float damagereturn = 0.0;
	if(NpcStats_IsEnemySilenced(victim))
		damagereturn += basedamage * (0.3 * DamageBuffExtraScaling);
	else
		damagereturn += basedamage * (0.15 * DamageBuffExtraScaling);
	return damagereturn;
}

float Void_Internal_1_DamageTakenFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	// Enfeeble fades out with time
	if(NpcStats_IsEnemySilenced(victim))
		return ((victim <= MaxClients) ? 0.95 : 0.9);
	else
		return ((victim <= MaxClients) ? 0.9 : 0.85);
}

float Void_Internal_2_DamageTakenFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	// Enfeeble fades out with time
	if(NpcStats_IsEnemySilenced(victim))
		return ((victim <= MaxClients) ? 0.9 : 0.85);
	else
		return ((victim <= MaxClients) ? 0.85 : 0.8);
}


stock bool NpcStats_WeakVoidBuff(int victim)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(VoidStrengthIndex1, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}
stock bool NpcStats_StrongVoidBuff(int victim)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(VoidStrengthIndex2, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

void StatusEffects_CombineCommander()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Combine Command");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛠");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.8;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

int VictoriaCallToArmsIndex;
void StatusEffects_Victoria()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Squad Leader");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "∏");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.9;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= 1.33;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	//This buff is unique, so we need 2 buffs at once.
	strcopy(data.BuffName, sizeof(data.BuffName), "Caffinated");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♨");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.5; //Deal 50% more damage
	data.MovementspeedModif			= 1.5;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Caffinated Drain");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	data.DamageTakenMulti 			= 0.25; //take 25% more damage
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Call To Victoria");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "@");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "@"); //dont display above head, so empty
	//Takes 20% less damage, and deals 20% more damage
	//while being 15% faster
	data.DamageTakenMulti 			= 0.8;
	data.DamageDealMulti			= 0.2;
	data.MovementspeedModif			= 1.15;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	VictoriaCallToArmsIndex = StatusEffect_AddGlobal(data);
}

stock bool NpcStats_VictorianCallToArms(int victim)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(VictoriaCallToArmsIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

void StatusEffects_Pernell()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "False Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "P");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.6;
	data.DamageDealMulti			= 0.5;
	data.MovementspeedModif			= 1.25;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_Medieval()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Godly Motivation");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ß");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.75;
	data.DamageDealMulti			= 0.5;
	data.MovementspeedModif			= 1.5;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Hussar's Warscream");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ᐩ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_DealFunc 		= Hussar_Warscream_DamageDealFunc;
	StatusEffect_AddGlobal(data);
}

float Hussar_Warscream_DamageDealFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	float damagereturn = 0.0;
	if(!NpcStats_IsEnemySilenced(victim))
		damagereturn += basedamage * (0.1 * DamageBuffExtraScaling);

	return damagereturn;
}

int AncientBannerIndex;
void StatusEffects_SupportWeapons()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Oceanic Singing");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌾");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 6; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Oceanic Scream");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍟");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 6; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Buff Banner");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "↖");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Battilons Backup");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛨");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.85;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Healing Strength");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌃");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 1.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Healing Resolve");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌅");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.95;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Healing Adaptiveness All");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍫");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.95;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Healing Adaptiveness Melee");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍬");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= AdaptiveMedigun_MeleeFunc;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Healing Adaptiveness Ranged");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍭");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= AdaptiveMedigun_RangedFunc;
	StatusEffect_AddGlobal(data);


	strcopy(data.BuffName, sizeof(data.BuffName), "Self Empowerment");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍋");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.9;
	data.DamageDealMulti			= 0.15;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Ally Empowerment");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍋");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.93;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Ancient Banner");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "➤");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	AncientBannerIndex = StatusEffect_AddGlobal(data);
}

stock bool NpcStats_AncientBanner(int victim)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(AncientBannerIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

	
float AdaptiveMedigun_MeleeFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	if(damagetype & (DMG_CLUB)) // if its melee
	{
		return 0.85;
	}
	
	return 1.0;
}
float AdaptiveMedigun_RangedFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	if(!(damagetype & (DMG_CLUB))) // if not NOT melee
	{
		return 0.85;
	}
	
	return 1.0;
}



void StatusEffects_BobDuck()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Bobs Duck Dubby");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "≝");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.9;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

int ElementalWandIndex;
void StatusEffects_ElementalWand()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Elemental Amplification");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⋔");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	ElementalWandIndex = StatusEffect_AddGlobal(data);
}

stock bool NpcStats_ElementalAmp(int victim)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(ElementalWandIndex , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}


int FallenWarriorIndex;
void StatusEffects_FallenWarrior()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Heavy Presence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⋡");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	FallenWarriorIndex = StatusEffect_AddGlobal(data);
}

stock bool NpcStats_HeavyPresence(int victim)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(FallenWarriorIndex , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}
int CasinoDebuffIndex;
void StatusEffects_CasinoDebuff()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Gambler's Ruin Total");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "$");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= GamblersRuin_DamageTakenFunc;
	CasinoDebuffIndex = StatusEffect_AddGlobal(data);
}
stock void NpcStats_CasinoDebuffStengthen(int victim, float NewBuffValue)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(CasinoDebuffIndex , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			//Buffs the damgae for casino, and saves it, as its random somewhat
			if(NewBuffValue >= Apply_StatusEffect.DataForUse)
			{
				Apply_StatusEffect.DataForUse = NewBuffValue;
			}
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

}

float GamblersRuin_DamageTakenFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	return (basedamage * (Apply_StatusEffect.DataForUse * DamageBuffExtraScaling));
}
int RuinaBuffSpeed;
int RuinaBuffDefense;
int RuinaBuffDamage;
void StatusEffects_Ruiania()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Ruina's Agility");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♝");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.Status_SpeedFunc 			= RuinasAgility_Func;
	RuinaBuffSpeed = StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Ruina's Defense");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♜");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= RuinasDefense_Func;
	RuinaBuffDefense = StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Ruina's Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♟");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_DealFunc 		= Ruinas_DamageFunc;
	RuinaBuffDamage = StatusEffect_AddGlobal(data);
}

stock void NpcStats_RuinaAgilityStengthen(int victim, float NewBuffValue)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(RuinaBuffSpeed , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			//Buffs the damgae for casino, and saves it, as its random somewhat
			if(NewBuffValue >= Apply_StatusEffect.DataForUse)
			{
				Apply_StatusEffect.DataForUse = NewBuffValue;
			}
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
}

float RuinasAgility_Func(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	return Apply_StatusEffect.DataForUse;
}

stock void NpcStats_RuinaDefenseStengthen(int victim, float NewBuffValue)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(RuinaBuffDefense , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			//Buffs the damgae for casino, and saves it, as its random somewhat
			if(NewBuffValue >= Apply_StatusEffect.DataForUse)
			{
				Apply_StatusEffect.DataForUse = NewBuffValue;
			}
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
}
float RuinasDefense_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	return Apply_StatusEffect.DataForUse;
}

stock void NpcStats_RuinaDamageStengthen(int victim, float NewBuffValue)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(RuinaBuffDamage , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			//Buffs the damgae for casino, and saves it, as its random somewhat
			if(NewBuffValue >= Apply_StatusEffect.DataForUse)
			{
				Apply_StatusEffect.DataForUse = NewBuffValue;
			}
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
}
float Ruinas_DamageFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	return (basedamage * (Apply_StatusEffect.DataForUse * DamageBuffExtraScaling));

}



int KazimierzDodgeIndex;
int OsmosisDebuffIndex;
void StatusEffects_WeaponSpecific_VisualiseOnly()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Waterless Training");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "G");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Specter's Resolve");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "S");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Specter's Aura");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₪");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.6;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Skadi's Skills");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "✣");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Castle Breaking Power");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "㎽");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Victorian Launcher's Call");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "㎾");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Tinkering Curiosity");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍡");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Crafted Potion");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⅋");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= PotionHudDisplay_Func;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Flaming Agility");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "F");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= INVALID_FUNCTION;
	KazimierzDodgeIndex = StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Tonic Affliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌇");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Mystery Beer");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌂");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Osmosis'ity");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⟁");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= OsmosisHud_Func;
	OsmosisDebuffIndex = StatusEffect_AddGlobal(data);
}

stock bool NpcStats_KazimierzDodge(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(KazimierzDodgeIndex , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}
stock bool NpcStats_InOsmosis(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return false;

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(OsmosisDebuffIndex , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}
void PotionHudDisplay_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar, "⅋(%.0fs)", Apply_StatusEffect.TimeUntillOver - GetGameTime());
}
void OsmosisHud_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	if(attacker < 0 && attacker > MaxClients)
		return;

	if(!Osmosis_ClientGaveBuff[victim][attacker])
		Format(HudToDisplay, SizeOfChar, "⟁");
}



void StatusEffects_StatusEffectListOnly()
{
	StatusEffect data;
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Village");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌒");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Jungle Drums");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌭");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Intelligence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌬");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Homeland Defense");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍣");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Call To Arms");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍤");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Iberia Light");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "i");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Victoria Nuke");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "◈");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Locked On");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "LOCK");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Shield");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "S");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Chaos Infliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛡");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Bleed");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❣");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Burn");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "~");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Iberia Morale Boost");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "W");
	data.Positive 					= true;
	StatusEffect_AddGlobal(data);
}