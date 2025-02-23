


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
	bool ElementalLogic;

	int LinkedStatusEffect; //Which status effect is used for below
	int LinkedStatusEffectNPC; //Which status effect is used for below
	float AttackspeedBuff;	//damage buff or nerf

	//IS it elemental? If yes, dont get blocked or removed.
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
	Function OnTakeDamage_PostVictim;
	Function OnTakeDamage_PostAttacker;

	void Blank()
	{
		this.DamageTakenMulti = -1.0;
		this.DamageDealMulti = -1.0;
		this.MovementspeedModif = -1.0;
	}
}


static const char Categories[][] =
{
	"Positive",
	"Negative",
};
#define MAXBUFFSEXPLAIN 500
//thres never gonna be more then 500 lol
bool DisplayBuffHintToClient[MAXPLAYERS][MAXBUFFSEXPLAIN];
float DisplayChatBuffCD[MAXPLAYERS];

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

void ResetExplainBuffStatus(int client)
{
	DisplayChatBuffCD[client] = 0.0;
	for(int c = 0; c < MAXBUFFSEXPLAIN; c++)
	{
		DisplayBuffHintToClient[client][c] = false;
	}
}
void DeleteStatusEffectsFromAll()
{
	for(int c = 0; c < MAXENTITIES; c++)
	{
		delete E_AL_StatusEffects[c];
	}
}
void InitStatusEffects()
{
	//First delete everything
	delete AL_StatusEffects;
	AL_StatusEffects = new ArrayList(sizeof(StatusEffect));

	DeleteStatusEffectsFromAll();
	//clear all existing ones
	StatusEffects_TeslarStick();
	StatusEffects_Ludo();
	StatusEffects_Cryo();
	StatusEffects_PotionWand();
	StatusEffects_Enfeeble();
	StatusEffects_BuildingAntiRaid();
	StatusEffects_WidowsWine();
	StatusEffects_CrippleDebuff();
#if defined ZR
	StatusEffects_MagnesisStrangle();
#endif
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
	StatusEffects_MERLT0N_BUFF();
	StatusEffects_SupportWeapons();
	StatusEffects_BobDuck();
	StatusEffects_ElementalWand();
	StatusEffects_FallenWarrior();
	StatusEffects_CasinoDebuff();
	StatusEffects_Ruiania();
	StatusEffects_WeaponSpecific_VisualiseOnly();
	StatusEffects_StatusEffectListOnly();
	StatusEffects_PurnellKitDeBuffs();
	StatusEffects_PurnellKitBuffs();
	StatusEffects_Construction();
	StatusEffects_BubbleWand1();
	StatusEffects_BubbleWand2();

	//freeplay last.
	StatusEffects_Freeplay1();
	StatusEffects_Freeplay2();
	StatusEffects_Freeplay3();
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
		char buffer3[400];
		FormatEx(buffer, sizeof(buffer), "%s Desc", data.BuffName);
		if(data.BuffName[0])
		{
			if(TranslationPhraseExists(buffer))
			{
				Format(buffer, sizeof(buffer), "%t", buffer);
				if(data.ElementalLogic)
					Format(buffer3, sizeof(buffer3), "%t", "Is Elemental");

				menu.SetTitle("%s\n%t\n \n%s\n%s\n", data.HudDisplay, data.BuffName, buffer, buffer3);
			}
			else
			{
				menu.SetTitle("%s\n%t\n ", data.HudDisplay, data.BuffName);
			}
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
			if(data.BuffName[0] && data.Positive != view_as<bool>(CategoryPage[client]))
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
#if defined ZR
					Store_Menu(client);
#endif
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

int StatusEffect_AddBlank()
{
	StatusEffect data;
	data.Blank();
	return AL_StatusEffects.PushArray(data);
}

int StatusEffect_AddGlobal(StatusEffect data)
{
	return AL_StatusEffects.PushArray(data);
}

stock void RemoveSpecificBuff(int victim, const char[] name, int IndexID = -1)
{
	int index;
	if(IndexID != -1)
		index = IndexID;
	else
		index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);

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
int HasSpecificBuff(int victim, const char[] name, int IndexID = -1)
{
	//doesnt even have abuff...
	if(!E_AL_StatusEffects[victim])
		return 0;

	int index;
	if(IndexID != -1)
		index = IndexID;
	else
		index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);

	if(index == -1)
	{
		CPrintToChatAll("{crimson} A DEV FUCKED UP!!!!!!!!! Name %s GET AN ADMIN RIGHT NOWWWWWWWWWWWWWW!^!!!!!!!!!!!!!!!!!!one111 (more then 0)",name);
		LogError("ApplyStatusEffect A DEV FUCKED UP!!!!!!!!! Name %s",name);
		return 0;
	}
	E_StatusEffect Apply_StatusEffect;
	int ArrayPosition;
	int Return = false;
	ArrayPosition = E_AL_StatusEffects[victim].FindValue(index, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			if(Apply_StatusEffect.TotalOwners[victim])
				Return = 2;
			else
				Return = 1;
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
	return Return;
}
stock void RemoveAllBuffs(int victim, bool RemoveGood, bool Everything = false)
{
	if(!E_AL_StatusEffects[victim])
		return;
		
	if(Everything)
	{
		delete E_AL_StatusEffects[victim];
		return;
	}
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	for(int i; i<E_AL_StatusEffects[victim].Length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			continue;
		}
		//They do not have a buffname, this means that it can break other things depending on this!
		if(!Apply_MasterStatusEffect.BuffName[0])
		{
			continue;
		}
		if(!Apply_MasterStatusEffect.Positive && !RemoveGood && !Apply_MasterStatusEffect.ElementalLogic)
		{
			StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect);
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			continue;
		}
		else if(Apply_MasterStatusEffect.Positive && RemoveGood && !Apply_MasterStatusEffect.ElementalLogic)
		{
			StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect);
			E_AL_StatusEffects[victim].Erase(i);
			i--;
			continue;
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
}
void ApplyStatusEffect(int owner, int victim, const char[] name, float Duration, int IndexID = -1)
{
	int index;
	if(IndexID != -1)
		index = IndexID;
	else
		index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);

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
		if(!Apply_MasterStatusEffect.Positive && !Apply_MasterStatusEffect.ElementalLogic)
		{
			//Immunity to all debuffs except elementals, dont ignore buffs with no name, this is due to them having internal logic.
			if(Apply_MasterStatusEffect.BuffName[0])
				return;
		}
	}

#if defined ZR
	if(!Apply_MasterStatusEffect.Positive)
		Rogue_ParadoxDLC_DebuffTime(victim, Duration);
#endif
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
						StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect);
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

	if(owner > 0 && owner <= MaxClients && owner != victim)
		ExplainBuffToClient(owner, Apply_MasterStatusEffect, Apply_StatusEffect, true);

	int linked = Apply_MasterStatusEffect.LinkedStatusEffect;
	if(linked > 0)
	{
		ApplyStatusEffect(owner, victim, "", Duration - 0.5, linked);
	}
}

void StatusEffect_UpdateAttackspeedAsap(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(Apply_MasterStatusEffect.AttackspeedBuff > 0.0)
	{
		//Instatly remove the sub,par buffs they had
		//do twice due to npc buffs and such.
		RemoveSpecificBuff(victim, "", Apply_MasterStatusEffect.LinkedStatusEffectNPC);
		Status_Effects_AttackspeedBuffChange(victim, Apply_MasterStatusEffect, Apply_StatusEffect);
		RemoveSpecificBuff(victim, "", Apply_MasterStatusEffect.LinkedStatusEffect);
		Status_Effects_AttackspeedBuffChange(victim, Apply_MasterStatusEffect, Apply_StatusEffect);
	}
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

	//nope!! no resistances!!
	if(damagetype & DMG_TRUEDAMAGE)
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
		if(Apply_MasterStatusEffect.OnTakeDamage_TakenFunc != INVALID_FUNCTION && Apply_MasterStatusEffect.OnTakeDamage_TakenFunc)
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
	//Nope, damage nef doesnt work on true damage!
	if(damagetype & DMG_TRUEDAMAGE)
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
		if(Apply_MasterStatusEffect.OnTakeDamage_DealFunc != INVALID_FUNCTION && Apply_MasterStatusEffect.OnTakeDamage_DealFunc)
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
		if(!Apply_MasterStatusEffect.ShouldScaleWithPlayerCount || Apply_StatusEffect.TotalOwners[attacker])
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
		delete E_AL_StatusEffects[attacker];
}

//Damage vulnerabilities, when i get HURT, this means i TAKE more damage
#if defined ZR
float StatusEffect_OnTakeDamage_TakenNegative(int victim, int attacker, int inflictor, float &basedamage, int damagetype)
#else
float StatusEffect_OnTakeDamage_TakenNegative(int victim, int attacker, float &basedamage, int damagetype)
#endif
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
		if(Apply_MasterStatusEffect.OnTakeDamage_TakenFunc != INVALID_FUNCTION && Apply_MasterStatusEffect.OnTakeDamage_TakenFunc)
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
#if defined ZR
float StatusEffect_OnTakeDamage_DealPositive(int victim, int attacker, int inflictor, float &basedamage, int damagetype)
#else
float StatusEffect_OnTakeDamage_DealPositive(int victim, int attacker, float &basedamage, int damagetype)
#endif
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
		if(Apply_MasterStatusEffect.OnTakeDamage_DealFunc != INVALID_FUNCTION && Apply_MasterStatusEffect.OnTakeDamage_DealFunc)
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
			ExtraDamageAdd += basedamage * (Apply_MasterStatusEffect.DamageDealMulti * DamageBuffScalingDo);
		}
	}
	if(length < 1) 		
		delete E_AL_StatusEffects[attacker];

	return ExtraDamageAdd;
}


//strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty

void ExplainBuffToClient(int client, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, bool AppliedOntoOthers = false)
{
	//Debuff has no icon, so we dont care.
	if(!Apply_MasterStatusEffect.HudDisplay[0])
		return;

	if(DisplayBuffHintToClient[client][Apply_StatusEffect.BuffIndex])
		return;
	
	if(!Apply_MasterStatusEffect.BuffName[0])
		return;

	if(b_DisableStatusEffectHints[client])
		return;
		
	if(DisplayChatBuffCD[client] > GetGameTime())
		return;

	DisplayChatBuffCD[client] = GetGameTime() + 5.0;
	
 	char buffer[400];
	DisplayBuffHintToClient[client][Apply_StatusEffect.BuffIndex] = true;
	FormatEx(buffer, sizeof(buffer), "%s Desc", Apply_MasterStatusEffect.BuffName);
	if(!TranslationPhraseExists(buffer))
		return;
	char DisplayToChat[255];

	Format(DisplayToChat, sizeof(DisplayToChat), "%s%s - ", DisplayToChat, Apply_MasterStatusEffect.HudDisplay);
	Format(DisplayToChat, sizeof(DisplayToChat), "%s%t\n", DisplayToChat, Apply_MasterStatusEffect.BuffName);
	if(AppliedOntoOthers)
		Format(DisplayToChat, sizeof(DisplayToChat), "%s%t\n", DisplayToChat, "Applied Onto Others");
	if(!Apply_MasterStatusEffect.Positive)
		Format(DisplayToChat, sizeof(DisplayToChat), "%s%s", DisplayToChat, "{crimson}");
	else
		Format(DisplayToChat, sizeof(DisplayToChat), "%s%s", DisplayToChat, "{green}");
		
	Format(DisplayToChat, sizeof(DisplayToChat), "%s%t", DisplayToChat, buffer);
	CPrintToChat(client,"%s",DisplayToChat);
	if(Apply_MasterStatusEffect.ShouldScaleWithPlayerCount)
	{
		CPrintToChat(client,"%t","Scale With Player");
	}
	DisplayBuffHintToClient[client][Apply_StatusEffect.BuffIndex] = true;
}
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
		if(length != E_AL_StatusEffects[victim].Length)
		{
			// Something was changed
			i -= (length - E_AL_StatusEffects[victim].Length);
			length = E_AL_StatusEffects[victim].Length
			if(i < 0)
			{
				i = -1;
				continue;
			}
		}

		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		//left are debuffs
		//Right are buffs
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(i);
			continue;
		}
		/*
			We want to give attackspeed buffs here
			Reason being: Its a timer basically.
		*/

		//We only give this to the client, as itll loop through all their weapaons.
		//0 means npcs
		if(DisplayWeapon >= 0 && Apply_MasterStatusEffect.AttackspeedBuff > 0.0)
		{
			Status_Effects_AttackspeedBuffChange(victim, Apply_MasterStatusEffect, Apply_StatusEffect);
		}
		if(!Apply_MasterStatusEffect.HudDisplay[0])
			continue;

		//only show to players.
		int ShowToClient = 0;
		if(victim > 0 && victim <= MaxClients)
			ShowToClient = victim;

		int owner = GetEntPropEnt(victim, Prop_Data, "m_hOwnerEntity");
		if(owner > 0 && owner <= MaxClients)
			ShowToClient = owner;

		if(ShowToClient > 0 && ShowToClient <= MaxClients)
			ExplainBuffToClient(ShowToClient, Apply_MasterStatusEffect, Apply_StatusEffect);

		if(Apply_MasterStatusEffect.HudDisplay_Func != INVALID_FUNCTION && Apply_MasterStatusEffect.HudDisplay_Func)
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

void Status_Effects_AttackspeedBuffChange(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	bool HasBuff = false;
	float BuffAmount = 1.0;
	//LinkedStatusEffect
	if(Apply_MasterStatusEffect.Positive)
	{	
		if(!Apply_MasterStatusEffect.ShouldScaleWithPlayerCount || Apply_StatusEffect.TotalOwners[victim])
		{
			BuffAmount = Apply_MasterStatusEffect.AttackspeedBuff;
			//We are the owner, get full buff instead.
		}
		else
		{
			bool ScaleWithCount = false;
#if defined ZR
			BarrackBody npc = view_as<BarrackBody>(victim);
			if(victim <= MaxClients || Citizen_IsIt(victim) || npc.OwnerUserId)
			{
				if(GetTeam(victim) == TFTeam_Red)
					ScaleWithCount = true;
			}
			if(ScaleWithCount)
			{
				BuffAmount = MaxNumBuffValue(Apply_MasterStatusEffect.AttackspeedBuff, 1.0, PlayerCountBuffAttackspeedScaling);
			}
			else
#endif
				BuffAmount = Apply_MasterStatusEffect.AttackspeedBuff;
		}
	}
	else
	{
		//For now, attackspeed debuffs dont do anythingfor scaling.
		//usually above 1.0 tho
		BuffAmount = Apply_MasterStatusEffect.AttackspeedBuff;
	}
	static StatusEffect link_Apply_MasterStatusEffect;
	static E_StatusEffect link_Apply_StatusEffect;
	int ArrayPosition;
	ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_MasterStatusEffect.LinkedStatusEffect , E_StatusEffect::BuffIndex);
//	int SaveLinkId = Apply_MasterStatusEffect.LinkedStatusEffect;
	if(ArrayPosition != -1)
	{
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, link_Apply_StatusEffect);
		AL_StatusEffects.GetArray(link_Apply_StatusEffect.BuffIndex, link_Apply_MasterStatusEffect);
		if(link_Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
			//Ran out, remove buffs?
		}
		else
		{
			HasBuff = true;
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
	Status_Effects_GrantAttackspeedBonus(victim, HasBuff, BuffAmount, Apply_MasterStatusEffect.LinkedStatusEffect, Apply_MasterStatusEffect.LinkedStatusEffectNPC);
}

bool Status_Effects_GrantAttackspeedBonus(int entity, bool HasBuff, float BuffAmount, int BuffCheckerID, int BuffCheckerIDNPC)
{
	//They still have the test buff
	if(IsValidClient(entity))
		Status_effects_DoAttackspeedLogic(entity, 1, HasBuff, BuffAmount, BuffCheckerID, BuffCheckerIDNPC);
	else 
		Status_effects_DoAttackspeedLogic(entity, 2, HasBuff, BuffAmount, BuffCheckerID, BuffCheckerIDNPC);

	return true;
}


static void Status_effects_DoAttackspeedLogic(int entity, int type, bool GrantBuff, float BuffOriginal, int BuffCheckerID, int BuffCheckerIDNPC)
{
	if(type == 1)
	{
		int i, weapon;
		while(TF2_GetItem(entity, weapon, i))
		{
			//They dont even have the buff.
			if(!HasSpecificBuff(weapon, "", BuffCheckerID))
			{	
				//We want to give the buff
				if(GrantBuff)
				{
					//No extra logic needed
					ApplyStatusEffect(entity, weapon, "", 9999999.9, BuffCheckerID);
					StatusEffects_SetCustomValue(weapon, BuffOriginal, BuffCheckerID);
					//inf
					if(Attributes_Has(weapon, 6))
						Attributes_SetMulti(weapon, 6, BuffOriginal);	// Fire Rate
					
					if(Attributes_Has(weapon, 97))
						Attributes_SetMulti(weapon, 97, BuffOriginal);	// Reload Time

					if(Attributes_Has(weapon, 733))
						Attributes_SetMulti(weapon, 733, BuffOriginal);	// mana cost
					
					if(Attributes_Has(weapon, 8))
						Attributes_SetMulti(weapon, 8, 1.0 / BuffOriginal);	// Heal Rate
				}
			}
			else
			{
				float BuffRevert = Status_Effects_GetCustomValue(weapon, BuffCheckerID);
				//Is the buff still the same as before?
				//if it changed, we need to update it.

				//dont be null either.
				if((BuffRevert != BuffOriginal || !GrantBuff) && BuffRevert != 0.0)
				{
					//Just remove the buff it had.
					if(Attributes_Has(weapon, 6))
						Attributes_SetMulti(weapon, 6, 1.0 / (BuffRevert));	// Fire Rate
					
					if(Attributes_Has(weapon, 97))
						Attributes_SetMulti(weapon, 97, 1.0 / (BuffRevert));	// Reload Time
						
					if(Attributes_Has(weapon, 733))
						Attributes_SetMulti(weapon, 733, 1.0 / (BuffRevert));	// mana cost

					if(Attributes_Has(weapon, 8))
						Attributes_SetMulti(weapon, 8, BuffRevert);	// Heal Rate
				
					RemoveSpecificBuff(weapon, "", BuffCheckerID);
				}
				if(GrantBuff && BuffRevert != BuffOriginal)
				{
					//No extra logic needed
					ApplyStatusEffect(entity, weapon, "", 9999999.9, BuffCheckerID);
					StatusEffects_SetCustomValue(weapon, BuffOriginal, BuffCheckerID);
					//inf
					if(Attributes_Has(weapon, 6))
						Attributes_SetMulti(weapon, 6, BuffOriginal);	// Fire Rate
					
					if(Attributes_Has(weapon, 97))
						Attributes_SetMulti(weapon, 97, BuffOriginal);	// Reload Time

					if(Attributes_Has(weapon, 733))
						Attributes_SetMulti(weapon, 733, BuffOriginal);	// mana cost

					if(Attributes_Has(weapon, 8))
						Attributes_SetMulti(weapon, 8, 1.0 / BuffOriginal);	// Heal Rate
				}
			}
		}
	}
	else if(type == 2)
	{
		//They dont even have the buff.
		if(!HasSpecificBuff(entity, "", BuffCheckerIDNPC))
		{	
			//We want to give the buff
			if(GrantBuff)
			{
				//No extra logic needed
				ApplyStatusEffect(entity, entity, "", 9999999.9, BuffCheckerIDNPC);
				StatusEffects_SetCustomValue(entity, BuffOriginal, BuffCheckerIDNPC);
				
#if defined ZR
				//They have never recieved a buff yet.
				if(Citizen_IsIt(entity) || view_as<BarrackBody>(entity).OwnerUserId)
				{
					view_as<Citizen>(entity).m_fGunFirerate *= BuffOriginal;
					view_as<Citizen>(entity).m_fGunReload *= BuffOriginal;
					view_as<BarrackBody>(entity).BonusFireRate *= BuffOriginal;
				}
				else
#endif
				{
					f_AttackSpeedNpcIncreace[entity] *= BuffOriginal;
				}
				ApplyStatusEffect(entity, entity, "", 9999999.9, BuffCheckerIDNPC);
				StatusEffects_SetCustomValue(entity, BuffOriginal, BuffCheckerIDNPC);
			}
		}
		else
		{
			float BuffRevert = Status_Effects_GetCustomValue(entity, BuffCheckerIDNPC);
			//Is the buff still the same as before?
			//if it changed, we need to update it.
			if((BuffRevert != BuffOriginal || !GrantBuff) && BuffRevert != 0.0)
			{

#if defined ZR				
				//They have never recieved a buff yet.
				if(Citizen_IsIt(entity) || view_as<BarrackBody>(entity).OwnerUserId)
				{
					view_as<Citizen>(entity).m_fGunFirerate *= 1.0 / (BuffRevert);
					view_as<Citizen>(entity).m_fGunReload *= 1.0 / (BuffRevert);
					view_as<BarrackBody>(entity).BonusFireRate *= 1.0 / (BuffRevert);
				}
				else
#endif
				{
					f_AttackSpeedNpcIncreace[entity] *= 1.0 / (BuffRevert);
				}
				RemoveSpecificBuff(entity, "", BuffCheckerIDNPC);
			}
			if(GrantBuff && BuffRevert != BuffOriginal)
			{
				//No extra logic needed
				ApplyStatusEffect(entity, entity, "", 9999999.9, BuffCheckerIDNPC);
				StatusEffects_SetCustomValue(entity, BuffOriginal, BuffCheckerIDNPC);
				
#if defined ZR
				//They have never recieved a buff yet.
				if(Citizen_IsIt(entity) || view_as<BarrackBody>(entity).OwnerUserId)
				{
					view_as<Citizen>(entity).m_fGunFirerate *= BuffOriginal;
					view_as<Citizen>(entity).m_fGunReload *= BuffOriginal;
					view_as<BarrackBody>(entity).BonusFireRate *= BuffOriginal;
				}
				else
#endif
				{
					f_AttackSpeedNpcIncreace[entity] *= BuffOriginal;
				}
			}
		}
	}
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
		if(Apply_MasterStatusEffect.Status_SpeedFunc != INVALID_FUNCTION && Apply_MasterStatusEffect.Status_SpeedFunc)
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
			if(!HasSpecificBuff(victim, "Fluid Movement"))
			{
				SpeedWasNerfed = true;
				TotalSlowdown *= SpeedModif;
			}
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ẝ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.15;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.15;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.ElementalLogic				= true;
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ệ");
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
	data.ElementalLogic				= true;
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

#if defined ZR
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
#endif
void StatusEffects_Freeplay1()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Cheesy Presence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "c");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.85;
	data.DamageDealMulti			= 0.15;
	data.MovementspeedModif			= 1.25;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.85;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Eloquence I");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Σ1");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 7; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Eloquence II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Σ2");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.2;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 7; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Eloquence III");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Σ3");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.3;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 7; //0 means ignored
	data.SlotPriority				= 3; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_Freeplay2()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Spotter's Rally");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "S");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.34;
	data.DamageDealMulti			= 1.0;
	data.MovementspeedModif			= 1.25;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.65;
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect = 0;
	data.LinkedStatusEffectNPC = 0;
	data.AttackspeedBuff = 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Rampart I");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ξ1");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.9;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 8; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Rampart II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ξ2");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.8;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 8; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Rampart III");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ξ3");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.7;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 8; //0 means ignored
	data.SlotPriority				= 3; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_Freeplay3()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Hurtle I");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), ">1");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 8; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.93;
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect = 0;
	data.LinkedStatusEffectNPC = 0;
	data.AttackspeedBuff = 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Hurtle II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), ">2");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 8; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.86;
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect = 0;
	data.LinkedStatusEffectNPC = 0;
	data.AttackspeedBuff = 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Freeplay Hurtle III");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), ">3");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 8; //0 means ignored
	data.SlotPriority				= 3; //if its higher, then the lower version is entirely ignored.
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.79;
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect = 0;
	data.LinkedStatusEffectNPC = 0;
	data.AttackspeedBuff = 0.0;
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
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.65;
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
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 1.035;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.Slot						= 4;
	data.SlotPriority				= 1;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Prosperity II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☯");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 1.07;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.Slot						= 4;
	data.SlotPriority				= 2;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Prosperity III");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☯");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 1.14;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.Slot						= 4;
	data.SlotPriority				= 3;
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
	data.ShouldScaleWithPlayerCount = false;
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
int RapidSuturingIndex;
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
	data.AttackspeedBuff			= 1.05;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	SilenceIndex = StatusEffect_AddGlobal(data);

	data.AttackspeedBuff			= 0.0;
	data.LinkedStatusEffect 		= 0;
	data.LinkedStatusEffectNPC 		= 0;
	//Immunity to all Negative debuffs.
	strcopy(data.BuffName, sizeof(data.BuffName), "Hardened Aura");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "֏");
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

	//Immunity To Bleed
	strcopy(data.BuffName, sizeof(data.BuffName), "Thick Blood");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₰");
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

	//Cleanses all Bleeding that happend before this time.
	strcopy(data.BuffName, sizeof(data.BuffName), "Rapid Suturing");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	RapidSuturingIndex = StatusEffect_AddGlobal(data);

	//Immunity to stun effects
	strcopy(data.BuffName, sizeof(data.BuffName), "Clear Head");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ֆ");
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

	//Immunity to stun effects
	strcopy(data.BuffName, sizeof(data.BuffName), "Shook Head");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "s");
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

	//Immunity to displacing
	strcopy(data.BuffName, sizeof(data.BuffName), "Solid Stance");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ѯ");
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

	//Immunity to slows
	strcopy(data.BuffName, sizeof(data.BuffName), "Fluid Movement");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ѷ");
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
}

stock void ApplyRapidSuturing(int victim)
{
	ApplyStatusEffect(victim, victim, "Rapid Suturing", 1.0);
	BleedAmountCountStack[victim] = 0;
	//Instantly clean all bleed.
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(RapidSuturingIndex , E_StatusEffect::BuffIndex);
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
			Apply_StatusEffect.DataForUse = GetGameTime();
			E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
}
stock bool StatusEffects_RapidSuturingCheck(int victim, float BleedTimeActive)
{
	if(!E_AL_StatusEffects[victim])
		return false;
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(RapidSuturingIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			if(BleedTimeActive <= Apply_StatusEffect.DataForUse)
			{
				return true;
				//This current bleedstack was already calculated to be invalid, remove.
			}
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;

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
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
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
	data.DamageDealMulti			= 0.125;
	data.MovementspeedModif			= 1.5;
	data.AttackspeedBuff			= 0.75;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
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
void StatusEffects_MERLT0N_BUFF()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "MERLT0N-BUFF");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Μ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.5;
	data.DamageDealMulti			= 0.5;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Extreme Anxiety");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "È");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 0.75;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

float Hussar_Warscream_DamageDealFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	float damagereturn = 0.0;
	if(!NpcStats_IsEnemySilenced(victim))
		damagereturn += basedamage * (0.1 * DamageBuffExtraScaling);

	return damagereturn;
}

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
	
	strcopy(data.BuffName, sizeof(data.BuffName), "War Cry");
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Defensive Backup");
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Healing Resolve");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌅");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.95;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "UBERCHARGED");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ü");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= 0.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= UberTakeDamageLogic;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	StatusEffect_AddGlobal(data);

	data.OnTakeDamage_TakenFunc = INVALID_FUNCTION;
	
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
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Ancient Melodies");
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
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.8;
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect 		= 0;
	data.LinkedStatusEffectNPC 		= 0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Zealot's Random Drinks");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Z");
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
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Zealot's Rush");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ź");
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
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Weapon Overclock");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ω");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.5;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.7;
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim	= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker	= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
	data.HudDisplay_Func 			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Weapon Clocking");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "o");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.9;
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim	= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker	= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
	data.HudDisplay_Func 			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
}

	
float UberTakeDamageLogic(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	// Enfeeble fades out with time
	if(RaidbossIgnoreBuildingsLogic(1) || ((damagetype & DMG_TRUEDAMAGE) && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)))
	{
		if(!(damagetype & DMG_TRUEDAMAGE))
			return 0.5;
	}
	return 0.0;
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
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 1.5;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
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
				E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
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
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
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
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
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
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
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
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			//Buffs the damgae for casino, and saves it, as its random somewhat
			if(Apply_StatusEffect.DataForUse == 0.0 || NewBuffValue >= Apply_StatusEffect.DataForUse)
			{
				Apply_StatusEffect.DataForUse = NewBuffValue;
				E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
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
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			//Buffs the damgae for casino, and saves it, as its random somewhat
			if(Apply_StatusEffect.DataForUse == 0.0 || NewBuffValue >= Apply_StatusEffect.DataForUse)
			{
				Apply_StatusEffect.DataForUse = NewBuffValue;
				E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
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
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			E_AL_StatusEffects[victim].Erase(ArrayPosition);
		}
		else
		{
			//Buffs the damgae for casino, and saves it, as its random somewhat
			if(Apply_StatusEffect.DataForUse == 0.0 || NewBuffValue >= Apply_StatusEffect.DataForUse)
			{
				Apply_StatusEffect.DataForUse = NewBuffValue;
				E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Ulpianus' Seriousness");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "U");
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
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Abyssal Skills");
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Tonic Affliction Hide");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.44;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.ElementalLogic				= true; //dont get removed.
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	data.ElementalLogic				= false;
	strcopy(data.BuffName, sizeof(data.BuffName), "Tonic Affliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌇");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "T"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.333;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect 		= 0;
	data.LinkedStatusEffectNPC 		= 0;
	data.AttackspeedBuff			= 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Mystery Beer");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌂");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "B"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.8;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect 		= 0;
	data.LinkedStatusEffectNPC 		= 0;
	data.AttackspeedBuff			= 0.0;
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Osmosis'ity");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⟁");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.ElementalLogic				= true;
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
	if(attacker < 0 || attacker > MaxClients)
		return;

#if defined ZR
	if(!Osmosis_ClientGaveBuff[victim][attacker])
		Format(HudToDisplay, SizeOfChar, "⟁");
#endif
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Heavy Laccerations");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⸗");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);
}


void StatusEffect_OnTakeDamagePostVictim(int victim, int attacker, float damage, int damagetype)
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
		if(Apply_MasterStatusEffect.OnTakeDamage_PostVictim != INVALID_FUNCTION && Apply_MasterStatusEffect.OnTakeDamage_PostVictim)
		{
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.OnTakeDamage_PostVictim);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushFloat(damage);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_PushCell(damagetype);
		}
	}

	if(length < 1)
		delete E_AL_StatusEffects[victim];
}
void StatusEffect_OnTakeDamagePostAttacker(int victim, int attacker, float damage, int damagetype)
{
	if(!E_AL_StatusEffects[attacker])
		return;
	
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
		if(Apply_MasterStatusEffect.OnTakeDamage_PostAttacker != INVALID_FUNCTION && Apply_MasterStatusEffect.OnTakeDamage_PostAttacker)
		{
			//We have a valid function ignore the original value.
			Call_StartFunction(null, Apply_MasterStatusEffect.OnTakeDamage_PostAttacker);
			Call_PushCell(attacker);
			Call_PushCell(victim);
			Call_PushFloat(damage);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_PushCell(damagetype);
		}
	}

	if(length < 1)
		delete E_AL_StatusEffects[attacker];
}

void StatusEffects_PurnellKitBuffs()
{

	//20% Faster attackspeed.
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Hectic Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ᵽ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.8;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	data.LinkedStatusEffect 		= 0;
	data.LinkedStatusEffectNPC 		= 0;
	data.AttackspeedBuff			= 0.0;

	//20% more Damage
	strcopy(data.BuffName, sizeof(data.BuffName), "Physical Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₱");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.2;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//15% Resistance
	strcopy(data.BuffName, sizeof(data.BuffName), "Ensuring Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "℘");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.85;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//10% damage and resistance, and 20% speed for npcs
	strcopy(data.BuffName, sizeof(data.BuffName), "Overall Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⅌");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.9;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= 0.2;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//5% resistance, 15% damage
	strcopy(data.BuffName, sizeof(data.BuffName), "Powering Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♇");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.95;
	data.DamageDealMulti			= 0.15;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	//15% resistance, 5% damage , and 10% speed for npcs
	strcopy(data.BuffName, sizeof(data.BuffName), "Calling Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ꟼ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.85;
	data.DamageDealMulti			= 0.05;
	data.MovementspeedModif			= 0.1;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//25% resistance, 25% damage , and 20% speed for npcs
	strcopy(data.BuffName, sizeof(data.BuffName), "Caffinated Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ꟼ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.75;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= 0.2;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//10% resistance, 10% damage , and slow hp regen
	strcopy(data.BuffName, sizeof(data.BuffName), "Regenerating Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ꟼ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.9;
	data.DamageDealMulti			= 0.9;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}





void StatusEffects_PurnellKitDeBuffs()
{
	//Same as Cryo
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Icy Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ḟ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.10;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.10;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	//Same as ant raid
	strcopy(data.BuffName, sizeof(data.BuffName), "Raiding Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₣");
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
	
	//Same as ant raid
	strcopy(data.BuffName, sizeof(data.BuffName), "Degrading Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "℉");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.9;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//Same as Near Zero
	strcopy(data.BuffName, sizeof(data.BuffName), "Zero Therapy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ꟻ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.15;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.15;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//Same as Golden Curse
	strcopy(data.BuffName, sizeof(data.BuffName), "Debt Causing Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ϝ");
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
	
	//Same as cudgelled
	strcopy(data.BuffName, sizeof(data.BuffName), "Headache Incuding Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ϝ");
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
	
	//Same as TEslar
	strcopy(data.BuffName, sizeof(data.BuffName), "Shocking Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "f");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.2;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.25;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//Same as Specter Aura
	strcopy(data.BuffName, sizeof(data.BuffName), "Therapists Aura");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ϝ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.6;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//Same as Teslar Electricution
	strcopy(data.BuffName, sizeof(data.BuffName), "Electric Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "𐌅");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.25;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.35;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	//Same as Caffinated Drain
	strcopy(data.BuffName, sizeof(data.BuffName), "Caffinated Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ɸ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.25; //take 25% more damage
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}


void StatusEffects_Construction()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Lighthouse Enlightment");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "l");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	//-0.5
	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	data.AttackspeedBuff			= 0.7;
	StatusEffect_AddGlobal(data);
}

void StatusEffects_BubbleWand1()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Soggy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ԅ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.95;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 10; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Soggiest");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ԇ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.93;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 10; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_BubbleWand2()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Bubble Frenzy");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ꞗ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.ElementalLogic				= true;
	//-0.5
//	data.LinkedStatusEffect 		= StatusEffect_AddBlank();
//	data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
//	data.AttackspeedBuff			= 0.5;
	StatusEffect_AddGlobal(data);
}


stock void StatusEffects_SetCustomValue(int victim, float NewBuffValue, int Index)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Index , E_StatusEffect::BuffIndex);
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
			//We always set it instantly.
			Apply_StatusEffect.DataForUse = NewBuffValue;
			E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
}

stock float Status_Effects_GetCustomValue(int victim, int Index)
{
	float BuffValuereturn = 1.0;
	if(!E_AL_StatusEffects[victim])
		return BuffValuereturn;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Index , E_StatusEffect::BuffIndex);
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
			BuffValuereturn = Apply_StatusEffect.DataForUse;
			//add scaling?
			if(Apply_StatusEffect.TotalOwners[victim])
			{
				BuffValuereturn = Apply_StatusEffect.DataForUse;
				//We are the owner, get full buff instead.
			}
			E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return BuffValuereturn;
}
