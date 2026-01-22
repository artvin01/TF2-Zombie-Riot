


static ArrayList AL_StatusEffects;

#define BUFF_ATTACKSPEED_BUFF_DISABLE (1 << 1)
#define BUFF_PROJECTILE_SPEED (1 << 2)
#define BUFF_PROJECTILE_RANGE (1 << 3)

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

	char HudDisplay[8]; //what it should say in the damage or hurt hud
	char AboveEnemyDisplay[8]; //Should it display above their head, like silence X
	float DamageTakenMulti; //Resistance or vuln
	float DamageDealMulti;	//damage buff or nerf
	float MovementspeedModif;	//damage buff or nerf
	bool Positive;//Is it a good buff, if yes, do true
	bool ElementalLogic;

	int LinkedStatusEffect; //Which status effect is used for below
	int LinkedStatusEffectNPC; //Which status effect is used for below
	float AttackspeedBuff;	//damage buff or nerf
	int FlagAttackspeedLogic;	//Extra Things

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
	Function TimerRepeatCall_Func; //for things such as regen. calls at a fixed 0.4.
	Function OnTakeDamage_PostVictim;
	Function OnTakeDamage_PostAttacker;
	Function OnBuffStarted;
	Function OnBuffStoreRefresh;
	Function OnBuffEndOrDeleted;

	void Blank()
	{
		this.OnTakeDamage_PostVictim	= INVALID_FUNCTION;
		this.OnTakeDamage_PostAttacker	= INVALID_FUNCTION;
		this.OnBuffStarted				= INVALID_FUNCTION;
		this.OnBuffStoreRefresh			= INVALID_FUNCTION;
		this.OnBuffEndOrDeleted			= INVALID_FUNCTION;
		this.HudDisplay_Func			= INVALID_FUNCTION;
		this.DamageTakenMulti 			= -1.0;
		this.DamageDealMulti 			= -1.0;
		this.MovementspeedModif 		= -1.0;
		this.AttackspeedBuff			= -1.0;
		this.ElementalLogic 			= false;
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
	int WearableUse;
	int WearableUse2;
	int VictimSave;
	bool MarkedForDeletion;

	void ApplyStatusEffect_Internal(int owner, int victim, bool HadBuff, int ArrayPosition)
	{
		if(!E_AL_StatusEffects[victim])
			E_AL_StatusEffects[victim] = new ArrayList(sizeof(E_StatusEffect));
		
		this.VictimSave = victim;

		if(owner > 0)
			this.TotalOwners[owner] = true;

		if(!HadBuff)
			E_AL_StatusEffects[victim].PushArray(this);
		else
			E_AL_StatusEffects[victim].SetArray(ArrayPosition, this);
	}

	void RemoveStatus(bool OnlyCastLogic = false)
	{
		static StatusEffect Apply_MasterStatusEffect;
		AL_StatusEffects.GetArray(this.BuffIndex, Apply_MasterStatusEffect);
	//	PrintToChatAll("RemoveStatus %s", Apply_MasterStatusEffect.BuffName);
		if(Apply_MasterStatusEffect.OnBuffEndOrDeleted != INVALID_FUNCTION && Apply_MasterStatusEffect.OnBuffEndOrDeleted)
		{
			Call_StartFunction(null, Apply_MasterStatusEffect.OnBuffEndOrDeleted);
			Call_PushCell(this.VictimSave);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(this, sizeof(this));
			Call_Finish();
		}
		if(!OnlyCastLogic)
		{
			int ArrayPosition = E_AL_StatusEffects[this.VictimSave].FindValue(this.BuffIndex, E_StatusEffect::BuffIndex);
			E_AL_StatusEffects[this.VictimSave].Erase(ArrayPosition);
		}
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
		StatusEffectReset(c, true);
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
#if defined ZR
	StatusEffects_Baka();
#endif
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
	StatusEffects_SevenHeavySouls();
	StatusEffects_SupportWeapons();
	StatusEffects_BobDuck();
	StatusEffects_ElementalWand();
	StatusEffects_FallenWarrior();
	StatusEffects_CasinoDebuff();
#if defined ZR
	StatusEffects_Aperture();
	StatusEffects_Ruiania();
#endif
	StatusEffects_WeaponSpecific_VisualiseOnly();
	StatusEffects_StatusEffectListOnly();
	StatusEffects_PurnellKitDeBuffs();
	StatusEffects_PurnellKitBuffs();
	StatusEffects_Construction();
	StatusEffects_BubbleWand1();
	StatusEffects_BubbleWand2();
	StatusEffects_Plasm();
	StatusEffects_Challenger();

	//freeplay last.
	StatusEffects_Freeplay1();
	StatusEffects_Freeplay2();
	StatusEffects_Freeplay3();
	StatusEffects_Modifiers();
	StatusEffects_Explainelemental();
	StatusEffects_Purge();
	StatusEffects_XenoLab();

#if defined ZR
	StatusEffects_Ritualist();
	StatusEffects_Rogue3();
	StatusEffects_SkullServants();
	StatusEffects_GamemodeMadnessSZF();
	StatusEffects_Raigeki();
#endif
	StatusEffects_Construction2();
	StatusEffects_AllyInvulnDebuffs();
}

static int CategoryPage[MAXPLAYERS];
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
				menu.SetTitle("%s\n%s\n ", data.HudDisplay, data.BuffName);
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
	if(data.AttackspeedBuff > 0.0)
	{
		/*
		//check for linked.
		if(!data.LinkedStatusEffect)
		{
			LogError("%s | NO LINKED BUFF FOR ATTACKSPEED.", data.BuffName);
		}
		if(!data.LinkedStatusEffectNPC)
		{
			LogError("%s | NO LINKED BUFF FOR ATTACKSPEED.", data.BuffName);
		}
		*/
		data.LinkedStatusEffect 		= StatusEffect_AddBlank();
		data.LinkedStatusEffectNPC 		= StatusEffect_AddBlank();
	}
	else
	{
		data.LinkedStatusEffect 		= 0;
		data.LinkedStatusEffectNPC 		= 0;
	}
	return AL_StatusEffects.PushArray(data);
}

stock void RemoveSpecificBuff(int victim, const char[] name, int IndexID = -1, bool UpdateAttackspeed = true)
{
	int index;
	if(IndexID != -1)
		index = IndexID;
	else
		index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);

	if(index == -1)
	{
		LogError("ApplyStatusEffect , invalid buff name: ''%s''",name);
		return;
	}
	E_StatusEffect Apply_StatusEffect;
	StatusEffect Apply_MasterStatusEffect;

	int ArrayPosition;
	if(E_AL_StatusEffects[victim])
	{
		ArrayPosition = E_AL_StatusEffects[victim].FindValue(index, E_StatusEffect::BuffIndex);
		if(ArrayPosition != -1)
		{
			E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
			AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
			if(UpdateAttackspeed)
				StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect, false);
			Apply_StatusEffect.RemoveStatus();
		}
		
		if(E_AL_StatusEffects[victim].Length < 1)
			delete E_AL_StatusEffects[victim];
	}
}
#if defined ZR
int Slowdown_I_Index;
int Slowdown_II_Index;
int Slowdown_III_Index;

void StatusEffects_Baka()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Major Steam's Launcher Resistance");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti				= -1.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc		= MajorSteam_Launcher_ResistanceFunc;
	data.OnTakeDamage_DealFunc		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
	data.HudDisplay_Func 				= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Subjective Time Dilation");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "↓");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti				= -1.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= 0.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount 	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= AOESlowdown_Func;
	data.HudDisplay_Func 				= INVALID_FUNCTION;
	Slowdown_I_Index=StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Slowdown");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "<");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti				= -1.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= 0.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount 	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= Slowdown_Func;
	data.HudDisplay_Func 				= INVALID_FUNCTION;
	Slowdown_II_Index=StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Power Slowdown");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "<<");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti				= -1.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= 0.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount 	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= SubjectiveTimeDilation_Func;
	data.HudDisplay_Func 				= INVALID_FUNCTION;
	Slowdown_III_Index=StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Cybergrind EX-Hard Enemy Buff");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛡");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti				= 0.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= 0.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount 	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc 		= Cybergrind_EX_Hard_ResistanceFunc;
	data.OnTakeDamage_DealFunc 		= Cybergrind_EX_Hard_DamageFunc;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= Cybergrind_EX_Hard_SpeedFunc;
	data.HudDisplay_Func 				= INVALID_FUNCTION;
	/*data.AttackspeedBuff				= INVALID_FUNCTION;
	data.OnBuffStarted				= INVALID_FUNCTION;
	data.OnBuffStoreRefresh			= INVALID_FUNCTION;
	data.OnBuffEndOrDeleted			= INVALID_FUNCTION;*/
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "True Fusion Warrior Effect");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "O");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti				= -1.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount 	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
	data.HudDisplay_Func 				= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Barricade Stabilizer");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛉");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti				= -1.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount 	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc 		= Barricade_Stabilizer_ResistanceFunc;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
	data.HudDisplay_Func 				= Barricade_Stabilizer_Hud_Func;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Chaos Coil Speed");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "✧");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti				= -1.0;
	data.AttackspeedBuff				= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount 	= false;
	data.Slot						= 0;
	data.SlotPriority					= 0;
	data.OnTakeDamage_TakenFunc 		= Chaos_Coil_Func;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim		= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker		= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
	data.HudDisplay_Func 				= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
}

float AOESlowdown_Func(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	float f_Speed = 0.1;
	if(b_thisNpcIsARaid[victim])f_Speed = 0.05;
	if(CheckBuffIndex(victim, Slowdown_II_Index))f_Speed = 0.0;
	if(CheckBuffIndex(victim, Slowdown_III_Index))f_Speed = 0.0;
	return f_Speed;
}

float Slowdown_Func(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	float f_Speed = 0.15;
	if(b_thisNpcIsARaid[victim])f_Speed = 0.05;
	if(CheckBuffIndex(victim, Slowdown_I_Index)) f_Speed += (b_thisNpcIsARaid[victim] ? 0.05 : 0.1);
	if(CheckBuffIndex(victim, Slowdown_III_Index))f_Speed = 0.0;
	return f_Speed;
}

float SubjectiveTimeDilation_Func(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	float f_Speed = 0.35;
	if(b_thisNpcIsARaid[victim])f_Speed = 0.1;
	if(CheckBuffIndex(victim, Slowdown_I_Index)) f_Speed += (b_thisNpcIsARaid[victim] ? 0.05 : 0.1);
	if(CheckBuffIndex(victim, Slowdown_II_Index)) f_Speed += (b_thisNpcIsARaid[victim] ? 0.05 : 0.15);
	return f_Speed;
}

float MajorSteam_Launcher_ResistanceFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	return f_MajorSteam_Launcher_Resistance(victim);
}

float Barricade_Stabilizer_ResistanceFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, int basedamage)
{
	float f_Resistance = 1.0;
	int building = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][victim]);
	if(building != -1)
	{
		if(StrEqual(c_NpcName[building], "Barricade"))
		{
			if(!CheckInHud())
			{
				int health = GetEntProp(building, Prop_Data, "m_iHealth") - RoundToCeil(basedamage*(RaidbossIgnoreBuildingsLogic(1) ? 1.5 : 1.0));
				if(health > 0)
				{
					ObjectGeneric objstats = view_as<ObjectGeneric>(building);
					SetEntProp(building, Prop_Data, "m_iHealth", health);
					objstats.PlayHurtSound();
				}
				else
				{
					int entity = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][victim]);
					if(IsValidEntity(i2_MountedInfoAndBuilding[1][victim]))
					{
						float posStacked[3]; 
						GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", posStacked);
						AcceptEntityInput(i2_MountedInfoAndBuilding[1][victim], "ClearParent");
						SDKCall_SetLocalOrigin(entity, posStacked);	
						i2_MountedInfoAndBuilding[1][victim] = INVALID_ENT_REFERENCE;
					}
					if(IsValidEntity(i2_MountedInfoAndBuilding[0][victim]))
					{
						RemoveEntity(i2_MountedInfoAndBuilding[0][victim]);
						i2_MountedInfoAndBuilding[0][victim] = INVALID_ENT_REFERENCE;
					}
					DestroyBuildingDo(building);
				}
			}
			f_Resistance=Barricade_Stabilizer_FeedBack(victim);
		}
	}
	return f_Resistance;
}

void Barricade_Stabilizer_Hud_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	if(!Inv_Barricade_Stabilizer[victim])
		RemoveSpecificBuff(victim, "Barricade Stabilizer");
	#if defined ZR
	float Ratio = 0.0;
	int building = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][victim]);
	if(building != -1)
	{
		if(StrEqual(c_NpcName[building], "Barricade"))
		{
			int health = GetEntProp(building, Prop_Data, "m_iHealth");
			int maxhealth = GetEntProp(building, Prop_Data, "m_iMaxHealth");
			Ratio = float(health)/float(maxhealth) * 100.0;
		}
	}
	Format(HudToDisplay, SizeOfChar, "[⛉ %.0f％]", Ratio);
	#endif
}

float Chaos_Coil_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, int basedamage)
{
	if(!Inv_Chaos_Coil[victim])
		RemoveSpecificBuff(victim, "Chaos Coil Speed");
	if(!CheckInHud())
		Elemental_AddChaosDamage(victim, attacker, basedamage);
	return 1.15;
}

float Cybergrind_EX_Hard_ResistanceFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	float f_Resistance = 0.8;
	int GetWaves = Waves_GetRound()+1;
	if(GetWaves>43)
	{
		if(CountPlayersOnRed()>4)
			f_Resistance = 0.8;
		else
			f_Resistance = 0.95;
	}
	else if(GetWaves>29)f_Resistance = 0.75;
	else if(GetWaves>28)f_Resistance = 0.8;
	else if(GetWaves>14)f_Resistance = 0.75;
	if(NpcStats_IsEnemySilenced(victim))f_Resistance*=1.0/(f_Resistance*1.2);
	if(f_Resistance>1.0)f_Resistance=1.0;
	return f_Resistance;
}

float Cybergrind_EX_Hard_DamageFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	float f_Damage = 1.25;
	int GetWaves = Waves_GetRound()+1;
	if(NpcStats_IsEnemySilenced(victim))f_Damage = 1.1;
	else if(GetWaves>44)
	{
		if(CountPlayersOnRed()>4)
			f_Damage = 1.25;
		else
			f_Damage = 1.15;
	}
	else if(GetWaves>43)f_Damage = 1.35;
	else if(GetWaves>29)f_Damage = 1.25;
	else if(GetWaves>28)f_Damage = 1.3;
	else if(GetWaves>14)f_Damage = 1.25;
	if(f_Damage<1.0)f_Damage=1.0;
	return f_Damage;
}

float Cybergrind_EX_Hard_SpeedFunc(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	float f_Speed = 1.06;
	if(NpcStats_IsEnemySilenced(victim))f_Speed = 1.0;
	else if(Waves_GetRound()>44)f_Speed = 1.05;
	else if(Waves_GetRound()>43)f_Speed = 1.06;
	else if(Waves_GetRound()>29)f_Speed = 1.05;
	else if(Waves_GetRound()>28)f_Speed = 1.06;
	else if(Waves_GetRound()>14)f_Speed = 1.06;
	return f_Speed;
}
#endif

//Got lazy, tired of doing so many indexs.

int HasSpecificBuff(int victim, const char[] name, int IndexID = -1, int attacker = 0)
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
		{
			if(Apply_StatusEffect.TotalOwners[attacker])
				Return = 3;
			else if(Apply_StatusEffect.TotalOwners[victim])
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
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime() || Apply_StatusEffect.MarkedForDeletion)
		{
			StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect, false);
			Apply_StatusEffect.RemoveStatus();
			i = 0;
			//reloop
			continue;
		}
		//They do not have a buffname, this means that it can break other things depending on this!
		if(!Apply_MasterStatusEffect.BuffName[0])
		{
			continue;
		}
		if(!Apply_MasterStatusEffect.Positive && !RemoveGood && !Apply_MasterStatusEffect.ElementalLogic)
		{
			StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect, false);
			Apply_StatusEffect.RemoveStatus();
			i = 0;
			//reloop
			continue;
		}
		else if(Apply_MasterStatusEffect.Positive && RemoveGood && !Apply_MasterStatusEffect.ElementalLogic)
		{
			StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect, false);
			Apply_StatusEffect.RemoveStatus();
			i = 0;
			//reloop
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
					continue;
				}
				if(CurrentSlotSaved == Apply_MasterStatusEffect.Slot)
				{
					if(CurrentPriority > Apply_MasterStatusEffect.SlotPriority)
					{
						// New buff is high priority, remove this one, stop the loop
						StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect, false);
						Apply_StatusEffect.RemoveStatus();
						i = 0;
						//reloop
						length = E_AL_StatusEffects[victim].Length;
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
	}
	Apply_StatusEffect.BuffIndex = index;
	if(!HadBuffBefore)
	{
		Apply_StatusEffect.TimeUntillOver = GetGameTime() + Duration;
	}
	Apply_StatusEffect.ApplyStatusEffect_Internal(owner, victim, HadBuffBefore, ArrayPosition);
	if(!HadBuffBefore)
	{
		AL_StatusEffects.GetArray(index, Apply_MasterStatusEffect);
		if(Apply_MasterStatusEffect.OnBuffStarted != INVALID_FUNCTION && Apply_MasterStatusEffect.OnBuffStarted)
		{
			Call_StartFunction(null, Apply_MasterStatusEffect.OnBuffStarted);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_Finish();
		}
	}

	if(owner > 0 && owner <= MaxClients && owner != victim)
		ExplainBuffToClient(owner, Apply_MasterStatusEffect, true);
	
	int linked = Apply_MasterStatusEffect.LinkedStatusEffect;
	if(linked > 0)
	{
		ApplyStatusEffect(owner, victim, "", 9999999.9, linked);
	}
	
}

void StatusEffect_UpdateAttackspeedAsap(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, bool HasBuff = true)
{
	if(Apply_MasterStatusEffect.AttackspeedBuff > 0.0)
	{
		//Instatly remove the sub,par buffs they had
		//do twice due to npc buffs and such.
		Status_Effects_AttackspeedBuffChange(victim, Apply_MasterStatusEffect, Apply_StatusEffect, HasBuff);
		RemoveSpecificBuff(victim, "", Apply_MasterStatusEffect.LinkedStatusEffectNPC, false);
		
		Status_Effects_AttackspeedBuffChange(victim, Apply_MasterStatusEffect, Apply_StatusEffect, HasBuff);
		RemoveSpecificBuff(victim, "", Apply_MasterStatusEffect.LinkedStatusEffect, false);
	}
}

void StatusEffectReset(int victim, bool force)
{
	if(!E_AL_StatusEffects[victim])
		return;
	
	static E_StatusEffect Apply_StatusEffect;
	int length = E_AL_StatusEffects[victim].Length;
	for(int i; i<length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		Apply_StatusEffect.RemoveStatus(true);
		//only remove effects.
	}

	if(force)
	{
		delete E_AL_StatusEffects[victim];
		return;
	}

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

void Force_ExplainBuffToClient(int client, const char[] name, bool IgnoreCooldown = false)
{
	int index;
	index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);
	if(index == -1)
	{
		CPrintToChatAll("{crimson} A DEV FUCKED UP!!!!!!!!! Name %s GET AN ADMIN RIGHT NOWWWWWWWWWWWWWW!^!!!!!!!!!!!!!!!!!!one111 (more then 0)",name);
		LogError("Force_ExplainBuffToClient A DEV FUCKED UP!!!!!!!!! Name %s",name);
		return;
	}
	StatusEffect Apply_MasterStatusEffect;
	AL_StatusEffects.GetArray(index, Apply_MasterStatusEffect);
	ExplainBuffToClient(client, Apply_MasterStatusEffect, false, index, IgnoreCooldown);
}

stock bool WasAlreadyExplainedToClient(int client, const char[] name)
{
	int index;
	index = AL_StatusEffects.FindString(name, StatusEffect::BuffName);
	if(index == -1)
	{
		CPrintToChatAll("{crimson} A DEV FUCKED UP!!!!!!!!! Name %s GET AN ADMIN RIGHT NOWWWWWWWWWWWWWW!^!!!!!!!!!!!!!!!!!!one111 (more then 0)",name);
		LogError("Force_ExplainBuffToClient A DEV FUCKED UP!!!!!!!!! Name %s",name);
		return false;
	}
	StatusEffect Apply_MasterStatusEffect;
	AL_StatusEffects.GetArray(index, Apply_MasterStatusEffect);
	if(index == -1)
	{
		index = AL_StatusEffects.FindString(Apply_MasterStatusEffect.BuffName, StatusEffect::BuffName);
		return DisplayBuffHintToClient[client][index];
	}
	return false;
}
void ExplainBuffToClient(int client, StatusEffect Apply_MasterStatusEffect, bool AppliedOntoOthers = false, int index = -1, bool IgnoreCooldown = false)
{
	//Bad client
	if(client <= 0 && client > MaxClients)
		return;
	//Debuff has no icon, so we dont care.
	if(!Apply_MasterStatusEffect.HudDisplay[0])
		return;

	if(!Apply_MasterStatusEffect.BuffName[0])
		return;
	if(index == -1)
	{
		index = AL_StatusEffects.FindString(Apply_MasterStatusEffect.BuffName, StatusEffect::BuffName);
	}
	if(DisplayBuffHintToClient[client][index])
		return;

	if(b_DisableStatusEffectHints[client])
		return;
		
	if(DisplayChatBuffCD[client] > GetGameTime() && !IgnoreCooldown)
		return;

	DisplayChatBuffCD[client] = GetGameTime() + 5.0;
	
	SetGlobalTransTarget(client);
 	char buffer[400];
	DisplayBuffHintToClient[client][index] = true;
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
			length = E_AL_StatusEffects[victim].Length;
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
			if(Status_Effects_AttackspeedBuffChange(victim, Apply_MasterStatusEffect, Apply_StatusEffect))
			{
				i = 0;
				//reloop
				length = E_AL_StatusEffects[victim].Length;
				continue;
			}
		}
		if(!Apply_MasterStatusEffect.HudDisplay[0])
			continue;

		//only show to players.
		int ShowToClient = 0;
		if(victim > 0 && victim <= MaxClients)
			ShowToClient = victim;

		int owner = GetEntPropEnt(victim, Prop_Data, "m_hOwnerEntity");
		if(!b_ThisWasAnNpc[victim] && owner > 0 && owner <= MaxClients) //Dont display to owner if the victimn was an npc
			ShowToClient = owner;


		if(ShowToClient > 0 && ShowToClient <= MaxClients)
			ExplainBuffToClient(ShowToClient, Apply_MasterStatusEffect);

		if(Apply_MasterStatusEffect.HudDisplay_Func != INVALID_FUNCTION && Apply_MasterStatusEffect.HudDisplay_Func)
		{
			char HudDisplayCustom[14];
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

bool Status_Effects_AttackspeedBuffChange(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, bool HasBuff = true)
{
	bool returnDo = false;
	float BuffAmount = 1.0;
	//LinkedStatusEffect
	int FlagAttackspeedLogicInternal = Apply_MasterStatusEffect.FlagAttackspeedLogic;

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
	
	
	Status_Effects_GrantAttackspeedBonus(victim, HasBuff, BuffAmount, Apply_MasterStatusEffect.LinkedStatusEffect, Apply_MasterStatusEffect.LinkedStatusEffectNPC, FlagAttackspeedLogicInternal);
	return returnDo;
}

bool Status_Effects_GrantAttackspeedBonus(int entity, bool HasBuff, float BuffAmount, int BuffCheckerID, int BuffCheckerIDNPC, int FlagAttackspeedLogicInternal)
{
	//They still have the test buff
	if(IsValidClient(entity))
		Status_effects_DoAttackspeedLogic(entity, 1, HasBuff, BuffAmount, BuffCheckerID, BuffCheckerIDNPC, FlagAttackspeedLogicInternal);
	else 
		Status_effects_DoAttackspeedLogic(entity, 2, HasBuff, BuffAmount, BuffCheckerID, BuffCheckerIDNPC, FlagAttackspeedLogicInternal);

	return true;
}

/*

#define BUFF_ATTACKSPEED_BUFF_DISABLE (1 << 1)
#define BUFF_PROJECTILE_SPEED (1 << 2)
#define BUFF_PROJECTILE_RANGE (1 << 3)

*/

static float BuffToASPD(float buff)
{
	return 1.0 - (1.0 / buff);
}

static float ASPDToBuff(float aspd)
{
	if(aspd <= -1.0)
		ThrowError("We weren't ready for this")
	
	return 1.0 / (1.0 + aspd);
}

static void Status_effects_DoAttackspeedLogic(int entity, int type, bool GrantBuff, float BuffOriginal, int BuffCheckerID, int BuffCheckerIDNPC, int FlagAttackspeedLogicInternal)
{	
	bool IsCheatMode = true;

	
#if defined ZR
	IsCheatMode = CvarInfiniteCash.BoolValue
#endif
	if(IsCheatMode && ((type == 3) || (type == 1 && BuffOriginal < 1.0)))
	{
		// Note this will break if two buffs share the same slot but have
		// a buffed attackspeed and the other a nerfed attackspeed
		// (The if statement above for "type == 1 && BuffOriginal < 1.0")

		float ASPDOriginal = BuffToASPD(BuffOriginal);

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
					if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
					{
						float currentASPD = Attributes_Get(weapon, Attrib_ASPD_StatusCalc, 0.0);
						float newAPSD = currentASPD + ASPDOriginal;
						Attributes_Set(weapon, Attrib_ASPD_StatusCalc, newAPSD);

						float currentBuff = ASPDToBuff(currentASPD);
						float newBuff = ASPDToBuff(newAPSD);

						float changedBuff = newBuff / currentBuff;

						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, changedBuff);	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, changedBuff);	// Reload Time

						if(Attributes_Has(weapon, 733))
							Attributes_SetMulti(weapon, 733, changedBuff);	// mana cost
						
						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, 1.0 / changedBuff);	// Heal Rate
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_SPEED))
					{
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, BuffOriginal);	// Projectile Speed
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_RANGE))
					{
						if(Attributes_Has(weapon, 101))
							Attributes_SetMulti(weapon, 101, 1.0 / BuffOriginal);	// Projectile Range
					}
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
					if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
					{
						float ASPDRevert = BuffToASPD(BuffRevert);

						float currentASPD = Attributes_Get(weapon, Attrib_ASPD_StatusCalc, 0.0);
						float newAPSD = currentASPD - ASPDRevert;
						Attributes_Set(weapon, Attrib_ASPD_StatusCalc, newAPSD);

						float currentBuff = ASPDToBuff(currentASPD);
						float newBuff = ASPDToBuff(newAPSD);

						float changedBuff = newBuff / currentBuff;

						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, changedBuff);	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, changedBuff);	// Reload Time
							
						if(Attributes_Has(weapon, 733))
							Attributes_SetMulti(weapon, 733, changedBuff);	// mana cost

						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, 1.0 / changedBuff);	// Heal Rate
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_SPEED))
					{
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, 1.0 / (BuffRevert));	// Projectile Speed
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_RANGE))
					{
						if(Attributes_Has(weapon, 101))
							Attributes_SetMulti(weapon, 101, BuffOriginal);	// Projectile Range
					}
				
					RemoveSpecificBuff(weapon, "", BuffCheckerID, false);
				}
				if(GrantBuff && BuffRevert != BuffOriginal)
				{
					//No extra logic needed
					ApplyStatusEffect(entity, weapon, "", 9999999.9, BuffCheckerID);
					StatusEffects_SetCustomValue(weapon, BuffOriginal, BuffCheckerID);
					//inf
					if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
					{
						float currentASPD = Attributes_Get(weapon, Attrib_ASPD_StatusCalc, 0.0);
						float newAPSD = currentASPD + ASPDOriginal;
						Attributes_Set(weapon, Attrib_ASPD_StatusCalc, newAPSD);

						float currentBuff = ASPDToBuff(currentASPD);
						float newBuff = ASPDToBuff(newAPSD);

						float changedBuff = newBuff / currentBuff;

						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, changedBuff);	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, changedBuff);	// Reload Time

						if(Attributes_Has(weapon, 733))
							Attributes_SetMulti(weapon, 733, changedBuff);	// mana cost

						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, 1.0 / changedBuff);	// Heal Rate
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_SPEED))
					{
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, BuffOriginal);	// Projectile Speed
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_RANGE))
					{
						if(Attributes_Has(weapon, 101))
							Attributes_SetMulti(weapon, 101, 1.0 / BuffOriginal);	// Projectile Range
					}
				}
			}
		}
	}
	else if(type == 1)
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
					if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
					{
						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, BuffOriginal);	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, BuffOriginal);	// Reload Time

						if(Attributes_Has(weapon, 733))
							Attributes_SetMulti(weapon, 733, BuffOriginal);	// mana cost
						
						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, 1.0 / BuffOriginal);	// Heal Rate
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_SPEED))
					{
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, BuffOriginal);	// Projectile Speed
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_RANGE))
					{
						if(Attributes_Has(weapon, 101))
							Attributes_SetMulti(weapon, 101, 1.0 / BuffOriginal);	// Projectile Range
					}
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
					if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
					{
						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, 1.0 / (BuffRevert));	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, 1.0 / (BuffRevert));	// Reload Time
							
						if(Attributes_Has(weapon, 733))
							Attributes_SetMulti(weapon, 733, 1.0 / (BuffRevert));	// mana cost

						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, BuffRevert);	// Heal Rate
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_SPEED))
					{
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, 1.0 / (BuffRevert));	// Projectile Speed
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_RANGE))
					{
						if(Attributes_Has(weapon, 101))
							Attributes_SetMulti(weapon, 101, BuffOriginal);	// Projectile Range
					}
				
					RemoveSpecificBuff(weapon, "", BuffCheckerID, false);
				}
				if(GrantBuff && BuffRevert != BuffOriginal)
				{
					//No extra logic needed
					ApplyStatusEffect(entity, weapon, "", 9999999.9, BuffCheckerID);
					StatusEffects_SetCustomValue(weapon, BuffOriginal, BuffCheckerID);
					//inf
					if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
					{
						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, BuffOriginal);	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, BuffOriginal);	// Reload Time

						if(Attributes_Has(weapon, 733))
							Attributes_SetMulti(weapon, 733, BuffOriginal);	// mana cost

						if(Attributes_Has(weapon, 8))
							Attributes_SetMulti(weapon, 8, 1.0 / BuffOriginal);	// Heal Rate
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_SPEED))
					{
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, BuffOriginal);	// Projectile Speed
					}
					if((FlagAttackspeedLogicInternal & BUFF_PROJECTILE_RANGE))
					{
						if(Attributes_Has(weapon, 101))
							Attributes_SetMulti(weapon, 101, 1.0 / BuffOriginal);	// Projectile Range
					}
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
				
				if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
				{
#if defined ZR
					//They have never received a buff yet.
					if(Citizen_IsIt(entity) || view_as<BarrackBody>(entity).OwnerUserId)
					{
						view_as<Citizen>(entity).m_fGunFirerate *= BuffOriginal;
						view_as<Citizen>(entity).m_fGunReload *= BuffOriginal;
						view_as<BarrackBody>(entity).BonusFireRate *= BuffOriginal;
					}
					else
#endif
					{
						f_AttackSpeedNpcIncrease[entity] *= BuffOriginal;
					}
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
				if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
				{
#if defined ZR				
					//They have never received a buff yet.
					if(Citizen_IsIt(entity) || view_as<BarrackBody>(entity).OwnerUserId)
					{
						view_as<Citizen>(entity).m_fGunFirerate *= 1.0 / (BuffRevert);
						view_as<Citizen>(entity).m_fGunReload *= 1.0 / (BuffRevert);
						view_as<BarrackBody>(entity).BonusFireRate *= 1.0 / (BuffRevert);
					}
					else
#endif
					{
						f_AttackSpeedNpcIncrease[entity] *= 1.0 / (BuffRevert);
					}
				}
				RemoveSpecificBuff(entity, "", BuffCheckerIDNPC, false);
			}
			if(GrantBuff && BuffRevert != BuffOriginal)
			{
				//No extra logic needed
				ApplyStatusEffect(entity, entity, "", 9999999.9, BuffCheckerIDNPC);
				StatusEffects_SetCustomValue(entity, BuffOriginal, BuffCheckerIDNPC);
				
				if(!(FlagAttackspeedLogicInternal & BUFF_ATTACKSPEED_BUFF_DISABLE))
				{
#if defined ZR
					//They have never received a buff yet.
					if(Citizen_IsIt(entity) || view_as<BarrackBody>(entity).OwnerUserId)
					{
						view_as<Citizen>(entity).m_fGunFirerate *= BuffOriginal;
						view_as<Citizen>(entity).m_fGunReload *= BuffOriginal;
						view_as<BarrackBody>(entity).BonusFireRate *= BuffOriginal;
					}
					else
#endif
					{
						f_AttackSpeedNpcIncrease[entity] *= BuffOriginal;
					}
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
	data.DamageTakenMulti 			= 0.1;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.1;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 2; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	Cryo1Index = StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Cryo");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❆");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.15;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.15;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 2;
	data.SlotPriority				= 2;
	Cryo2Index = StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Near Zero");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❈");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.20;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.20;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 2;
	data.SlotPriority				= 3;
	Cryo3Index = StatusEffect_AddGlobal(data);

	//elemental, shouldnt show here.
	strcopy(data.BuffName, sizeof(data.BuffName), "Frozen");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ẝ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.20;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.20;
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
	strcopy(data.BuffName, sizeof(data.BuffName), "Weakening Compound");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "▼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "\\/");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.35;
	data.DamageDealMulti			= 0.75;
	data.MovementspeedModif			= 0.35;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnBuffStarted				= WeakeningCompoundStart;
	data.OnBuffEndOrDeleted			= WeakeningCompoundEnd;
	ShrinkingStatusEffectIndex = StatusEffect_AddGlobal(data);

	data.OnBuffStarted				= INVALID_FUNCTION;
	data.OnBuffEndOrDeleted			= INVALID_FUNCTION;
	
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
	return CheckBuffIndex(victim, ShrinkingStatusEffectIndex);
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Paralysis");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⚡︎");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.5;	// -50% speed
	data.AttackspeedBuff			= 1.5;	// -50% attack speed
	data.Positive					= false;
	data.ShouldScaleWithPlayerCount	= true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.ElementalLogic				= true;
	data.OnTakeDamage_DealFunc		= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
}

float Enfeeble_Internal_DamageDealFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	// Enfeeble fades out with time
	float resist = (Apply_StatusEffect.TimeUntillOver - GetGameTime()) / 30.0;
	if(resist < 0.75)
		resist = 0.75;
	
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
	strcopy(data.BuffName, sizeof(data.BuffName), "Teslar Mule");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "४");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.30;
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

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Raid Strangle Protection");
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
	
	data.AttackspeedBuff			= (1.0 / 1.15);
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
	
	data.AttackspeedBuff			= (1.0 / 1.06);
	StatusEffect_AddGlobal(data);


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
	
	data.AttackspeedBuff			= (1.0 / 1.14);
	StatusEffect_AddGlobal(data);


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
	
	data.AttackspeedBuff			= (1.0 / 1.21);
	StatusEffect_AddGlobal(data);


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
	data.MovementspeedModif			= 0.5;
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
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.AttackspeedBuff			= 1.1;
	
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	SilenceIndex = StatusEffect_AddGlobal(data);

	data.AttackspeedBuff			= 0.0;
	//Immunity to all Negative debuffs.
	strcopy(data.BuffName, sizeof(data.BuffName), "Hardened Aura");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "֏");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ElementalLogic 			= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	/*
	This buff itself doesnt do anything, its visualiser only
	use 
	f_AntiStuckPhaseThrough[client] = GetGameTime() + 3.0 + 0.5;
	f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + 3.0 + 0.5;
	*/
	strcopy(data.BuffName, sizeof(data.BuffName), "Intangible");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ᶅ");
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

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Infinite Will");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ł");
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
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Blessing of Stars");
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Death is comming.");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ɖ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
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

	//Stunned
	strcopy(data.BuffName, sizeof(data.BuffName), "Stunned");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "?");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "?"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ElementalLogic				= true; //dont get removed.
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func 			= Func_StunnedHud;
	StatusEffect_AddGlobal(data);

	data.HudDisplay_Func 			= INVALID_FUNCTION;
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
void Func_StunnedHud(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar, "?(%.1f)", Apply_StatusEffect.TimeUntillOver - GetGameTime());
}
stock void ExtinguishTargetDebuff(int victim)
{
	IgniteFor[victim] = 0;
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
#if defined ZR
	if(!b_thisNpcIsARaid[victim])
		return false;
#endif

	return CheckBuffIndex(victim, SilenceIndex);
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
	return CheckBuffIndex(victim, DebuffMarkedIndex);
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
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 5; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Sea Presence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ṣ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 12; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Sea Strength");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ṣ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.9;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 12; //0 means ignored
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
	if((damagetype & DMG_TRUEDAMAGE)) //dont block true damage lol
		return 1.0;
	// Enfeeble fades out with time
	if(NpcStats_IsEnemySilenced(victim))
		return ((victim <= MaxClients) ? 0.95 : 0.9);
	else
		return ((victim <= MaxClients) ? 0.9 : 0.85);
}

float Void_Internal_2_DamageTakenFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	if((damagetype & DMG_TRUEDAMAGE)) //dont block true damage lol
		return 1.0;

	// Enfeeble fades out with time
	if(NpcStats_IsEnemySilenced(victim))
		return ((victim <= MaxClients) ? 0.9 : 0.85);
	else
		return ((victim <= MaxClients) ? 0.85 : 0.8);
}


stock bool NpcStats_WeakVoidBuff(int victim)
{
	return CheckBuffIndex(victim, VoidStrengthIndex1);
}
stock bool NpcStats_StrongVoidBuff(int victim)
{
	return CheckBuffIndex(victim, VoidStrengthIndex2);
}

static bool CheckBuffIndex(int victim, int buffIndex)
{
	if(!IsValidEntity(victim))
		return true; //they dont exist, pretend as if they are silenced.
	
	if(!E_AL_StatusEffects[victim])
		return false;
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(buffIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
			return true;
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}

void StatusEffects_CombineCommander()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Mazeat Command");
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
	data.AttackspeedBuff			= -1.0;
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
	data.DamageDealMulti			= 0.33; //Deal 33% more damage
	data.AttackspeedBuff			= 0.67;
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
	data.AttackspeedBuff			= -1.0;
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
	data.AttackspeedBuff			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	VictoriaCallToArmsIndex = StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Taurine");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "T");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.2;
	data.AttackspeedBuff			= 0.8;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Victorian Launcher Overdrive");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 0.5;
	
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 	= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim	= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker	= INVALID_FUNCTION;
	data.Status_SpeedFunc 		= INVALID_FUNCTION;
	data.HudDisplay_Func 			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Battery_TM Charge");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "B™");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.AttackspeedBuff			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.ElementalLogic				= true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.HudDisplay_Func			= Charge_BatteryTM_Hud_Func;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Ammo_TM Visualization");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "A™");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.AttackspeedBuff			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.ElementalLogic				= true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.HudDisplay_Func			= AmmoTM_Visual_Hud_Func;
	StatusEffect_AddGlobal(data);
}

stock bool NpcStats_VictorianCallToArms(int victim)
{
	return CheckBuffIndex(victim, VictoriaCallToArmsIndex);
}

void AmmoTM_Visual_Hud_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	if(!i_GunAmmoMAX[victim])
		RemoveSpecificBuff(victim, "Ammo_TM Visualization");
	/* is old Version */
	/*if(i_GunAmmo[victim])
	{
		Format(HudToDisplay, SizeOfChar, "|");
		for(int i = 1; i < i_OverlordComboAttack[victim]; i++)
		{
			if(i>10)
			{
				Format(HudToDisplay, SizeOfChar, "%s+%i", HudToDisplay, i_OverlordComboAttack[victim]-i);
				break;
			}
			else
				Format(HudToDisplay, SizeOfChar, "%s|", HudToDisplay);
		}
		Format(HudToDisplay, SizeOfChar, "[A™ %s]", HudToDisplay);
	}*/
	Format(HudToDisplay, SizeOfChar, "[A™ %i/%i]", i_GunAmmo[victim], i_GunAmmoMAX[victim]);
}

void Charge_BatteryTM_Hud_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	//Original code is RuinaBatteryHud_Func
	//It's just to change the symbol.
	if(fl_ruina_battery_max[victim] == 0.0)
	{
		RemoveSpecificBuff(victim, "Battery_TM Charge");
		return;
	}
	#if defined ZR
	if(fl_ruina_battery_timeout[victim] != FAR_FUTURE && fl_ruina_battery_timeout[victim] > GetGameTime(victim))
	{
		Format(HudToDisplay, SizeOfChar, "[B™ %.1fs]", fl_ruina_battery_timeout[victim] - GetGameTime(victim));
		return;
	}

	float Ratio = fl_ruina_battery[victim] / fl_ruina_battery_max[victim] * 100.0;

	if(Ratio >= 101.0)
	{
		Format(HudToDisplay, SizeOfChar, "[B™ MAX]", Ratio);
	}
	else
	{
		Format(HudToDisplay, SizeOfChar, "[B™ %.0f％]", Ratio);
	}
	#endif
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Expert's Mind");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "м");
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

int PikemanDebuffIndex;
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
	data.AttackspeedBuff			= (1.0 / 1.25);
	
	data.OnBuffStarted				= GodlyMotivaitonGive;
	data.OnBuffEndOrDeleted			= GodlyMotivaitonEnd;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	data.OnBuffStarted				= INVALID_FUNCTION;
	data.OnBuffEndOrDeleted			= INVALID_FUNCTION;

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Pikeman's Slashes");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "PI");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func 			= Func_PikemanMaxStacks;
	PikemanDebuffIndex = StatusEffect_AddGlobal(data);

	data.HudDisplay_Func 			= INVALID_FUNCTION;

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

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Flagellants Punishment");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₾");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.8;
	data.DamageDealMulti			= 0.35;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.AttackspeedBuff			= (1.0 / 1.1);
	
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "King's Dying Breath");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ʞ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.8;
	data.DamageDealMulti			= 0.35;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.AttackspeedBuff			= (1.0 / 1.1);
	
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
}
#define MAXPIKEMAN_STACKS 10

stock void StatusEffects_PikemanDebuffAdd(int victim, int valuetoadd)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(PikemanDebuffIndex , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
		{
			if(RoundToNearest(Apply_StatusEffect.DataForUse) >= MAXPIKEMAN_STACKS)
			{
				//we at max.
				return;
			}
			Apply_StatusEffect.DataForUse += float(valuetoadd);
			E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

}

void Func_PikemanMaxStacks(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar, "PI(%i/%i)", RoundToNearest(Apply_StatusEffect.DataForUse), MAXPIKEMAN_STACKS);
}

stock bool StatusEffects_PikemanDebuffMaxStacks(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return false;
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(PikemanDebuffIndex, E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_StatusEffect Apply_StatusEffect;
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
		{
			if(RoundToNearest(Apply_StatusEffect.DataForUse) >= 10)
			{
				//we at max.
				return true;
			}
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];

	return false;
}
void GodlyMotivaitonGive(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!(b_ThisWasAnNpc[victim] || victim <= MaxClients))
		return;
	
	if(IsValidEntity(Apply_StatusEffect.WearableUse))
		return;

	float flPos[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", flPos);
	int ParticleEffect = ParticleEffectAt_Parent(flPos, "utaunt_wispy_parent_g", victim, "", {0.0,0.0,0.0});
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
	Apply_StatusEffect.WearableUse = EntIndexToEntRef(ParticleEffect);
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
}
void GodlyMotivaitonEnd(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidEntity(Apply_StatusEffect.WearableUse))
		return;
	RemoveEntity(Apply_StatusEffect.WearableUse);
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
	data.AttackspeedBuff			= (1.0 / 1.25);
	
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_SevenHeavySouls()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Nightmare Terror");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "...");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false; //lol why was it on yes
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "7 Heavy Souls");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "♥");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.25;
	data.DamageDealMulti			= 1.0;
	data.MovementspeedModif			= 1.5;
	data.AttackspeedBuff			= 0.25;
	
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false; //lol why was it on yes
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

#if defined ZR

#define TIMEWARP_BUFF_MULTIPLIER 1.5

void StatusEffects_Aperture()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Hypodermic Toxin Injection");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⊙");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.2;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Cellular Breakdown");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⊚");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.2;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 1.2;
	
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Molecular Collapse");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⊛");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.2;
	data.DamageDealMulti			= 0.8;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 1.2;
	
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Quantum Entanglement");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛣");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.75;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= 1.25;
	data.AttackspeedBuff			= 0.75;
	
	data.OnBuffStarted				= QuantumEntanglementStart;
	data.OnBuffEndOrDeleted			= QuantumEntanglementEnd;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	data.OnBuffStarted				= INVALID_FUNCTION;
	data.OnBuffEndOrDeleted			= INVALID_FUNCTION;
	data.AttackspeedBuff			= 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Energizing Gel");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❁");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 1.5;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Vigorous Gel");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❂");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.5;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Hastening Gel");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "❃");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= 0.5;
	
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Kinetic Surge");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "∰");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= -1.0;
	data.DamageDealMulti			= 1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Envenomed");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "փ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Self-Degradation");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= -1.0;
	data.DamageDealMulti			= 1.0;
	data.MovementspeedModif			= 1.25;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Self-Degradation (Debuff)");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= 0.25;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Mind Warp");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⭮");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= (1.0 / TIMEWARP_BUFF_MULTIPLIER);
	data.AttackspeedBuff			= TIMEWARP_BUFF_MULTIPLIER;
	data.OnBuffStarted				= TimeWarp_Start;
	data.OnBuffStoreRefresh			= TimeWarp_Start;
	data.OnBuffEndOrDeleted			= TimeWarp_End;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Last Stand");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= 0.6;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "A.R.I.S. ARMOR MODE");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= 0.50;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "A.R.I.S. DAMAGE MODE");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= -1.0;
	data.DamageDealMulti			= 0.3;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "A.R.I.S. SPEED MODE");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 1.15;
	data.AttackspeedBuff			= -1.0;

	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}


static void QuantumEntanglementStart(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!(b_ThisWasAnNpc[victim] || victim <= MaxClients))
		return;
	
	if(IsValidEntity(Apply_StatusEffect.WearableUse))
		return;

	float flPos[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", flPos);
	int ParticleEffect = ParticleEffectAt_Parent(flPos, "player_recent_teleport_blue", victim, "", {0.0,0.0,0.0});
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
	Apply_StatusEffect.WearableUse = EntIndexToEntRef(ParticleEffect);
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
}

static void QuantumEntanglementEnd(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidEntity(Apply_StatusEffect.WearableUse))
		return;
	RemoveEntity(Apply_StatusEffect.WearableUse);
}

static void TimeWarp_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
	
	Attributes_SetMulti(victim, 442, (1.0 / TIMEWARP_BUFF_MULTIPLIER));
	SDKCall_SetSpeed(victim);
}

static void TimeWarp_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
	
	Attributes_SetMulti(victim, 442, TIMEWARP_BUFF_MULTIPLIER);
	SDKCall_SetSpeed(victim);
}

void TimeWarp_ApplyAll(int inflictor, float duration = 99999.0)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetTeam(i) >= TFTeam_Red)
		{
			if (!IsFakeClient(i))
			{
				SendConVarValue(i, sv_cheats, "1");
				Convars_FixClientsideIssues(i);
			}
			
			ApplyStatusEffect(inflictor, i, "Mind Warp", duration);
		}
	}
	
	for (int i = 0; i < i_MaxcountNpcTotal; i++)
    {
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if (entity != INVALID_ENT_REFERENCE)
		{
			ApplyStatusEffect(inflictor, entity, "Mind Warp", duration);
		}
	}
	
	ResetReplications();
	cvarTimeScale.SetFloat(TIMEWARP_BUFF_MULTIPLIER);
}

void TimeWarp_RemoveAll()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i))
			{
				SendConVarValue(i, sv_cheats, "0");
				Convars_FixClientsideIssues(i);
			}
			
			RemoveSpecificBuff(i, "Mind Warp");
		}
	}
	
	for (int i = 0; i < i_MaxcountNpcTotal; i++)
    {
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if (entity != INVALID_ENT_REFERENCE)
		{
			RemoveSpecificBuff(entity, "Mind Warp");
		}
	}
	
	ResetReplications();
	cvarTimeScale.SetFloat(1.0);
}

#endif // ZR

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

	strcopy(data.BuffName, sizeof(data.BuffName), "Expidonsan War Cry");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "↖↖");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.5;
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Very Defensive Backup");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛨⛨");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.5;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Extreamly Defensive Backup");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛨⛨⛨");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.1;
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
	data.DamageDealMulti			= -1.0;
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Unstoppable Force");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "שׁ");
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

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Archo's Posion");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ꜻ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
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
	
	data.AttackspeedBuff			= (1.0 / 1.2);
	StatusEffect_AddGlobal(data);


	data.AttackspeedBuff			= 0.0;

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
	data.DamageDealMulti			= 0.4;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	
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
	
	data.AttackspeedBuff			= 0.952;
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.OnTakeDamage_PostVictim	= INVALID_FUNCTION;
	data.OnTakeDamage_PostAttacker	= INVALID_FUNCTION;
	data.Status_SpeedFunc 			= INVALID_FUNCTION;
	data.HudDisplay_Func 			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);


	data.AttackspeedBuff			= 0.0;
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Empowering Domain Hidden");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.2;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Empowering Domain");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⨭");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.15;
	data.MovementspeedModif			= -1.0;
	
	data.AttackspeedBuff			= (1.0 / 1.25);
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
}

	
float UberTakeDamageLogic(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	return (UberLogicInternal());
}

float UberLogicInternal()
{
	if(RaidbossIgnoreBuildingsLogic(1))
	{
		return 0.5;
	}
	else
	{
		return 0.1;
	}
}
float AdaptiveMedigun_MeleeFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	if(damagetype & (DMG_CLUB)) // if its melee
	{
		if(!(damagetype & DMG_TRUEDAMAGE)) //dont block true damage lol
			return 0.85;
	}
	
	return 1.0;
}
float AdaptiveMedigun_RangedFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	if(!(damagetype & (DMG_CLUB))) // if not NOT melee
	{
		if(!(damagetype & DMG_TRUEDAMAGE)) //dont block true damage lol
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
	return CheckBuffIndex(victim, ElementalWandIndex);
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
	
	data.AttackspeedBuff			= 1.5;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Terrified");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "҂");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.5;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.OnBuffStarted				= Terrified_Start;
	data.OnBuffStoreRefresh			= Terrified_Start;
	data.OnBuffEndOrDeleted			= Terrified_End;
	
	data.AttackspeedBuff			= 1.5;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Unstable Umbral Rift");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "UR");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.OnBuffStarted				= UnstableUmbralRift_StartOnce;
	data.OnBuffStoreRefresh			= UnstableUmbralRift_Start;
	data.OnBuffEndOrDeleted			= UnstableUmbralRift_End;
	
	data.AttackspeedBuff			= 0.0;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	data.Blank();


	strcopy(data.BuffName, sizeof(data.BuffName), "Altered Functions");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ϡ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	
	data.OnTakeDamage_PostAttacker	= Altered_FunctionsBuffSpread;
	data.AttackspeedBuff			= (1.0 / 1.5);
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "John's Presence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "J");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.5;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	
	data.OnTakeDamage_PostAttacker	= INVALID_FUNCTION;
	data.AttackspeedBuff			= 1.5;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}
void Altered_FunctionsBuffSpread(int attacker, int victim, float damage, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	ApplyStatusEffect(attacker, victim, "Altered Functions", 2.5);
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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

#if defined ZR
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Ruina Battery Charge");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "۞");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.ElementalLogic				= true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= RuinaBatteryHud_Func;
	StatusEffect_AddGlobal(data);
}

void RuinaBatteryHud_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	//they do not have a valid battery, abort.
	if(fl_ruina_battery_max[victim] == 0.0)
	{
		RemoveSpecificBuff(victim, "Ruina Battery Charge");
		return;
	}

	//so, the npc has a battery timeout, this means that they cannot use their battery ability until its over. so we can show this on the hud!
	if(fl_ruina_battery_timeout[victim] != FAR_FUTURE && fl_ruina_battery_timeout[victim] > GetGameTime(victim))
	{
		Format(HudToDisplay, SizeOfChar, "[۞ %.1fs]", fl_ruina_battery_timeout[victim] - GetGameTime(victim));
		return;
	}

	//get the % of how much battery the npc has
	float Ratio = fl_ruina_battery[victim] / fl_ruina_battery_max[victim] * 100.0;

	if(Ratio >= 101.0)
	{
		Format(HudToDisplay, SizeOfChar, "[۞ MAX]", Ratio);
	}
	else
	{
		Format(HudToDisplay, SizeOfChar, "[۞ %.0f％]", Ratio);
	}
}


void VintulumBombHud_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	float TimeDisplay = Apply_StatusEffect.TimeUntillOver - GetGameTime();
	if(TimeDisplay <= 0.0)
	{
		Format(HudToDisplay, SizeOfChar, "");
		return;
	}
	Format(HudToDisplay, SizeOfChar, "[V %.1fs]", Apply_StatusEffect.TimeUntillOver - GetGameTime());
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
	if((damagetype & DMG_TRUEDAMAGE)) //dont block true damage lol
		return 1.0;
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
#endif	// ZR


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

	strcopy(data.BuffName, sizeof(data.BuffName), "King's Wrath");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ʞ");
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Explosault Rifle Buff");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "㎼");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
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

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Nightmareish Sawing");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "N");
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
	data.DamageDealMulti			= 0.7;
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
	
	data.AttackspeedBuff			= (1.0 / 2.0);
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);


	data.AttackspeedBuff			= 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Mystery Beer");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "b");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "b"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.AttackspeedBuff			= (1.0 / 1.2);
	data.Slot						= 11; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
	

	strcopy(data.BuffName, sizeof(data.BuffName), "Mystery Brew");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "B");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "B"); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.AttackspeedBuff			= (1.0 / 1.25);
	data.Slot						= 11; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);


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

	
#if defined ZR
	strcopy(data.BuffName, sizeof(data.BuffName), "Vuntulum Bomb EMP");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "V");
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
	data.HudDisplay_Func			= VintulumBombHud_Func;
	StatusEffect_AddGlobal(data);
#endif
	data.HudDisplay_Func			= INVALID_FUNCTION;
	strcopy(data.BuffName, sizeof(data.BuffName), "Vuntulum Bomb EMP Death");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "DEAD");
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
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Hand of Spark");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "HS");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.ElementalLogic				= true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.HudDisplay_Func			= HandOfSparkHud_Func;
	StatusEffect_AddGlobal(data);
}

void HandOfSparkHud_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	int owner = GetEntPropEnt(victim, Prop_Data, "m_hOwnerEntity");
	if(owner <= 0)
		return;
#if defined ZR
	float TimeDisplay = GetGameTime() - Hand2HunterLastTime_Return(owner);
	if(TimeDisplay >= 25.0)
	{
		Format(HudToDisplay, SizeOfChar, "[HS]");
		return;
	}
	Format(HudToDisplay, SizeOfChar, "[HS %.0f％]", TimeDisplay * 4.0)
#endif
}

stock bool NpcStats_KazimierzDodge(int victim)
{
	return CheckBuffIndex(victim, KazimierzDodgeIndex);
}
stock bool NpcStats_InOsmosis(int victim)
{
	return CheckBuffIndex(victim, OsmosisDebuffIndex);
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
	if(!IsIn_HitDetectionCooldown(victim,attacker, Osmosisdebuff))
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
	data.ShouldScaleWithPlayerCount = false; //none scale here!
	data.Slot						= 0;
	data.SlotPriority				= 0;
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Revealed");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "r");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Growth Blocker");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "g");
	data.Positive 					= false;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Elemental Curing");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ϓ");
	data.Positive 					= true;
	data.Slot						= 17;
	data.SlotPriority				= 1;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Armor Curing");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ϔ");
	data.Positive 					= true;
	data.Slot						= 17;
	data.SlotPriority				= 2;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Nethersea Antidote");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ξ");
	data.Positive 					= true;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Village Radar");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌒");
	data.Positive 					= true;
	data.AttackspeedBuff			= (1.0 / 1.1);
	data.FlagAttackspeedLogic 		= (BUFF_ATTACKSPEED_BUFF_DISABLE | BUFF_PROJECTILE_SPEED | BUFF_PROJECTILE_RANGE);
	StatusEffect_AddGlobal(data);

	data.FlagAttackspeedLogic		= 0;

	data.AttackspeedBuff			= 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Jungle Drums");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌭");
	data.Positive 					= true;
	data.AttackspeedBuff			= (1.0 / 1.025);
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Intelligence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⌬");
	data.Positive 					= true;
	data.DamageDealMulti			= 0.05;
	StatusEffect_AddGlobal(data);

	data.DamageDealMulti			= -1.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Homeland Defense");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍣");
	data.Positive 					= true;
	data.Slot						= 16;
	data.SlotPriority				= 2;
	data.AttackspeedBuff			= (1.0 / 1.24);
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Call To Arms");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⍤");
	data.Positive 					= true;
	data.Slot						= 16; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	data.AttackspeedBuff			= (1.0 / 1.12);
	StatusEffect_AddGlobal(data);

	data.Slot						= 0;
	data.SlotPriority				= 0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Iberia Light");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "i");
	data.Positive 					= true;
	data.AttackspeedBuff			= (1.0 / 1.1);
	StatusEffect_AddGlobal(data);
	
	data.FlagAttackspeedLogic		= 0;

	data.AttackspeedBuff			= 0.0;

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
	data.ElementalLogic				= true;
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

void StatusEffect_StoreRefresh(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return;
	
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	for(int i; i<E_AL_StatusEffects[victim].Length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect, false);
			Apply_StatusEffect.RemoveStatus();
			i = 0;
			continue;
		}
		if(Apply_MasterStatusEffect.OnBuffStoreRefresh != INVALID_FUNCTION && Apply_MasterStatusEffect.OnBuffStoreRefresh)
		{
			Call_StartFunction(null, Apply_MasterStatusEffect.OnBuffStoreRefresh);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_Finish();
		}
	}

}
void StatusEffect_TimerCallDo(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return;
	
	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	//No debuffs or status effects, skip.
	for(int i; i<E_AL_StatusEffects[victim].Length; i++)
	{
		E_AL_StatusEffects[victim].GetArray(i, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
		{
			StatusEffect_UpdateAttackspeedAsap(victim, Apply_MasterStatusEffect, Apply_StatusEffect, false);
			Apply_StatusEffect.RemoveStatus();
			i = 0;
			continue;
		}
		if(Apply_MasterStatusEffect.TimerRepeatCall_Func != INVALID_FUNCTION && Apply_MasterStatusEffect.TimerRepeatCall_Func)
		{
			Call_StartFunction(null, Apply_MasterStatusEffect.TimerRepeatCall_Func);
			Call_PushCell(victim);
			Call_PushArray(Apply_MasterStatusEffect, sizeof(Apply_MasterStatusEffect));
			Call_PushArray(Apply_StatusEffect, sizeof(Apply_StatusEffect));
			Call_Finish();
		}
	}

	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
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
			Call_Finish();
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
			Call_Finish();
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
	data.AttackspeedBuff			= (1 / 1.2);
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);


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
	data.MovementspeedModif			= 1.2;
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
	data.MovementspeedModif			= 1.1;
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
	data.MovementspeedModif			= 1.2;
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
	data.DamageDealMulti			= 0.1;
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

	strcopy(data.BuffName, sizeof(data.BuffName), "Therapy Duration");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ḟ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Icy Dereliction");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	data.AttackspeedBuff			= (1.0 / 1.3);
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Ziberian Flagship Weaponry");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "վ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.75;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	//-0.5
	data.AttackspeedBuff			= (1.0 / 1.1);
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Expidonsan Anger");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "á");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 1.15;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	//-0.5
	data.AttackspeedBuff			= (1.0 / 1.3);
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Rejuvinator's Medizine");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ʀ");
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
	data.AttackspeedBuff			= (1.0 / 1.3);
	StatusEffect_AddGlobal(data);
	

	data.AttackspeedBuff			= 0.0;
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Starting Grace");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "G");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.85;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Anti-Waves");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ם");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Cut Hair");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "H");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 14;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "We gotta go bald");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "H");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 14;
	data.SlotPriority				= 1;
	StatusEffect_AddGlobal(data);


	strcopy(data.BuffName, sizeof(data.BuffName), "Zeinas Protection");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ẕ");
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

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Medusa's Teslar");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ṯ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.DamageTakenMulti 			= 0.25;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 0.35;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0;
	data.SlotPriority				= 20;
	HighTeslarIndex = StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Zilius Prime Technology");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ö");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.AttackspeedBuff			= (1.0 / 1.2);
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
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

int StatusIdDepthPerceptionOwner;

int StatusIdDepthPerceptionOwnerFunc()
{
	return StatusIdDepthPerceptionOwner;
}
int StatusIdDepthPerception;
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
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Trigger Finger");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ḟ");
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
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Trigger Finger Hidden");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.85;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.ElementalLogic				= true;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Depth Percieve");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.ElementalLogic				= true; //shouldnt be removed.
	StatusIdDepthPerceptionOwner = StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Depth Percepted");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.ElementalLogic				= true; //shouldnt be removed.
	data.OnBuffEndOrDeleted			= DepthPerceptionOnRemove;
	StatusIdDepthPerception = StatusEffect_AddGlobal(data);
	
}


stock void StatusEffects_AddDepthPerception_Glow(int victim)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(StatusIdDepthPerception , E_StatusEffect::BuffIndex);
	if(ArrayPosition == -1) //we dont have this buff.
		return;

	E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
	AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
	if(Apply_StatusEffect.TimeUntillOver < GetGameTime())
	{
		return;
	}
	//Add a new glow if we dont have one.
	if(IsValidEntity(Apply_StatusEffect.WearableUse))
		return;

	int GlowEffectAm;
//	GlowEffectAm = TF2_CreateGlow(victim, true);
	int ModelIndex = GetEntProp(victim, Prop_Send, "m_nModelIndex");
	char model[PLATFORM_MAX_PATH];
	ModelIndexToString(ModelIndex, model, PLATFORM_MAX_PATH);
	GlowEffectAm = TF2_CreateGlow_White(model, victim, GetEntPropFloat(victim, Prop_Send, "m_flModelScale"));
	SetVariantColor(view_as<int>({255, 255, 255, 200}));
	AcceptEntityInput(GlowEffectAm, "SetGlowColor");
	i_OwnerEntityEnvLaser[GlowEffectAm] = EntIndexToEntRef(victim); //needed as we cannot get owner.
	SDKHook(GlowEffectAm, SDKHook_SetTransmit, DepthPerceptionGlowDo_Transmit);
	Apply_StatusEffect.WearableUse = EntIndexToEntRef(GlowEffectAm);
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
}

stock bool StatusEffects_AddDepthPerception_Glow_IsaOwner(int victim, int owner)
{
	if(!E_AL_StatusEffects[victim])
		return false;

//	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(StatusIdDepthPerception , E_StatusEffect::BuffIndex);
	if(ArrayPosition == -1) //we dont have this buff.
		return false;

	E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
	return Apply_StatusEffect.TotalOwners[owner];
}
stock void StatusEffects_AddDepthPerception_UseUpMark(int victim, int owner)
{
	if(!E_AL_StatusEffects[victim])
		return;

//	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(StatusIdDepthPerception , E_StatusEffect::BuffIndex);
	if(ArrayPosition == -1) //we dont have this buff.
		return;

	E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
	Apply_StatusEffect.TotalOwners[owner] = false;
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
	//gone.
}
public Action DepthPerceptionGlowDo_Transmit(int entity, int client)
{
	if(client <= 0 || client > MaxClients)
		return Plugin_Continue; //dont do anything.

	if(!HasSpecificBuff(client, "", StatusIdDepthPerceptionOwner))
		return Plugin_Stop;
	//the owner itself does not have this buff, do not render.
	int OwnerAm = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);
	if(OwnerAm < 0)
	{
		RemoveEntity(entity);
		//bye bye, our owner does not exist no more.
		return Plugin_Stop;
	}
	if(!StatusEffects_AddDepthPerception_Glow_IsaOwner(OwnerAm, client))
		return Plugin_Stop;
	//we are not the owner.

	return Plugin_Continue;
	//Render for client if possible.
}

void DepthPerceptionOnRemove(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidEntity(Apply_StatusEffect.WearableUse))
		return;

	RemoveEntity(Apply_StatusEffect.WearableUse);
}
void StatusEffects_Plasm()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Plasmatized Lethalitation");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ի");
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

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Plasma Heal Prevent");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
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
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Plasmatic Rampage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ϙ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.70;
	data.DamageDealMulti			= 0.30;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.AttackspeedBuff			= (1.0 / 1.3);
	StatusEffect_AddGlobal(data);


	data.AttackspeedBuff = 0.0;

	strcopy(data.BuffName, sizeof(data.BuffName), "Plasmic Layering I");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ϥ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.90;
	data.DamageDealMulti			= 0.15;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 15; //0 means ignored
	data.SlotPriority				= 1; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	strcopy(data.BuffName, sizeof(data.BuffName), "Plasmic Layering II");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ϥ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.85;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 15; //0 means ignored
	data.SlotPriority				= 2; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_Challenger()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Challenger");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⸸");
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
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


void StatusEffects_Modifiers()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Dimensional Turbulence");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "DT");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 1.2;
	data.AttackspeedBuff			= (1.0 / 2.0);
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false; //lol why was it on yes
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void StatusEffects_Explainelemental()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⛛");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Void Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Chaos Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Chaos Elemental Damage High");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Necrosis Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Corruption Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Nervous Impairment Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Plasmic Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Overmana Overload");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Mana Overflow");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Wrench Building");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Barracks Building Explain");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Explain Building Cash");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), " ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Warped Elemental Damage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ʬ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= 0.0;
	data.MovementspeedModif			= -1.0;
	data.ElementalLogic				= true;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.OnBuffStarted				= Warped_Start;
	data.OnBuffEndOrDeleted			= Warped_End;
	data.OnTakeDamage_DealFunc 		= Warped_DamageFunc;
	data.TimerRepeatCall_Func 		= Warped_FuncTimer;
	StatusEffect_AddGlobal(data);

	
	strcopy(data.BuffName, sizeof(data.BuffName), "Warped Elemental End");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.ElementalLogic				= true;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	data.OnBuffStarted			= INVALID_FUNCTION;
	data.OnBuffEndOrDeleted			= Warped_End_Death;
	data.OnTakeDamage_DealFunc 		= INVALID_FUNCTION;
	data.TimerRepeatCall_Func 		= INVALID_FUNCTION;
	StatusEffect_AddGlobal(data);
}

static const char g_IdleCreepSound[][] = {
	"vo/mvm/norm/pyro_mvm_jeers01.mp3",
	"vo/mvm/norm/pyro_mvm_jeers02.mp3",
};
static const char g_MarkSoundUmbral[][] = {
	"ui/hitsound_vortex1.wav",
};
static void Warped_FuncTimer(int entity, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
#if defined ZR
	float ratio = Elemental_DamageRatio(entity, Element_Warped);
	if(ratio < 0.0)
		ratio = 0.0;
	
	if(ratio >= 1.0)
		ratio = 1.0;
	//Extreamly creepy sound
	//prevent passive talk, mostly.
	CClotBody npc = view_as<CClotBody>(entity);
	npc.m_flNextIdleSound = FAR_FUTURE;
	float SoundLoudness = ratio;
	if(entity <= MaxClients)
	{
		if(SoundLoudness > 0.3)
			SoundLoudness = 0.3;
	}
	else
	{

		if(SoundLoudness < 0.7)
			SoundLoudness = 0.7;
	}
		
	EmitSoundToAll(g_IdleCreepSound[GetRandomInt(0, sizeof(g_IdleCreepSound) - 1)], entity, SNDCHAN_ITEM, NORMAL_ZOMBIE_SOUNDLEVEL, _, SoundLoudness, GetRandomInt(40, 45));
	if(entity <= MaxClients)
	{
		float sub = RemoveExtraHealth(WeaponClass[entity], 0.1);
		float nerfHealth = (Attributes_Get(entity, 125) - sub);

		float baseHealth = ReturnEntityMaxHealth(entity) - nerfHealth;
		nerfHealth = -baseHealth * 0.8 * ratio;

		Attributes_Set(entity, 125, (nerfHealth + sub));
	}
	else if(ratio > 0.0/* && GetTeam(entity) != TFTeam_Red*/)
	{
		int attacker = entity;
		
		for(int i; i < sizeof(Apply_StatusEffect.TotalOwners); i++)
		{
			if(i != entity && Apply_StatusEffect.TotalOwners[i])
			{
				attacker = i;
				break;
			}
		}

		Elemental_AddWarpedDamage(entity, attacker, RoundFloat(ReturnEntityMaxHealth(entity) * 0.027), false, _, true);
		if(!Citizen_IsIt(entity))
			if(f_AttackSpeedNpcIncrease[entity] > 0.2)
				f_AttackSpeedNpcIncrease[entity] *= 0.979;
	}

	if(!ratio)
	{
		Apply_StatusEffect.TimeUntillOver = 0.0;
		int ArrayPosition = E_AL_StatusEffects[entity].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
		E_AL_StatusEffects[entity].SetArray(ArrayPosition, Apply_StatusEffect);
	}
#endif
}
static float Warped_DamageFunc(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
#if defined ZR
	if(attacker <= MaxClients)
		return (basedamage * Elemental_DamageRatio(attacker, Element_Warped));
	
#endif
	return 0.0;
}
static void Warped_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!b_ThisWasAnNpc[victim])
		return;
	
	if(IsValidEntity(Apply_StatusEffect.WearableUse))
		return;

	float flPos[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", flPos);
	int ParticleEffect = ParticleEffectAt_Parent(flPos, "utaunt_constellations_blue_cloud", victim, "", {0.0,0.0,0.0});
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
	Apply_StatusEffect.WearableUse = EntIndexToEntRef(ParticleEffect);
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
}
static void Warped_End_Death(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(Apply_StatusEffect.DataForUse != 0.0)
		return;

	float WorldSpaceVec[3]; WorldSpaceCenter(victim, WorldSpaceVec);
	TE_Particle("spell_batball_impact_blue", WorldSpaceVec, NULL_VECTOR, {0.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	EmitSoundToAll("weapons/bottle_break.wav", victim, SNDCHAN_STATIC, 80, _, 1.0, 100);
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
	Apply_StatusEffect.DataForUse = 1.0;
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
}
static void Warped_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidEntity(Apply_StatusEffect.WearableUse))
		return;
	RemoveEntity(Apply_StatusEffect.WearableUse);
}

int PrimalFearIndex;
void StatusEffects_Purge()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Purging Intention");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "☠");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.ElementalLogic				= true;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);

	strcopy(data.BuffName, sizeof(data.BuffName), "Aimbot");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "A");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.ElementalLogic				= true;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Primal Fear");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⚠");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.ElementalLogic				= true;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.OnTakeDamage_TakenFunc 	= PrimalFear_Func;
	data.TimerRepeatCall_Func 		= PrimalFear_FuncTimer;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	PrimalFearIndex = StatusEffect_AddGlobal(data);

	//This is used to determine when it allows to cool down primal fear!
	strcopy(data.BuffName, sizeof(data.BuffName), "Primal Fear Hide");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.ElementalLogic				= true;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = false;
	data.OnTakeDamage_TakenFunc 	= INVALID_FUNCTION;
	data.TimerRepeatCall_Func 		= INVALID_FUNCTION;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	StatusEffect_AddGlobal(data);
}


void PrimalFear_FuncTimer(int entity, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(HasSpecificBuff(entity, "Primal Fear Hide"))
		return;
	NpcStats_PrimalFearChange(entity, -0.05);
}

float PrimalFear_Func(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	return (basedamage * (Apply_StatusEffect.DataForUse));
}

stock void NpcStats_PrimalFearChange(int victim, float AddBuff)
{
	if(!E_AL_StatusEffects[victim])
		return;

	static StatusEffect Apply_MasterStatusEffect;
	static E_StatusEffect Apply_StatusEffect;
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(PrimalFearIndex , E_StatusEffect::BuffIndex);
	if(ArrayPosition != -1)
	{
		E_AL_StatusEffects[victim].GetArray(ArrayPosition, Apply_StatusEffect);
		AL_StatusEffects.GetArray(Apply_StatusEffect.BuffIndex, Apply_MasterStatusEffect);
		if(Apply_StatusEffect.TimeUntillOver >= GetGameTime())
		{
			float NewBuffValue = Apply_StatusEffect.DataForUse;
			NewBuffValue += AddBuff;

			if(NewBuffValue >= 1.0)
				NewBuffValue = 1.0;
			else if(NewBuffValue <= 0.0)
			{
				//if its 0, or less
				RemoveSpecificBuff(victim, "Primal Fear");
				return;
			}
			
			Apply_StatusEffect.DataForUse = NewBuffValue;
			E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
		}
	}
	if(E_AL_StatusEffects[victim].Length < 1)
		delete E_AL_StatusEffects[victim];
}


void StatusEffects_XenoLab()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Xeno's Territory");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ӂ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.75;
	data.DamageDealMulti			= 0.25;
	data.MovementspeedModif			= 1.15;
	data.AttackspeedBuff			= (1.0 / 1.25);
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Corrupted Godly Power");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "¶");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.85;
	data.DamageDealMulti			= 0.1;
	data.MovementspeedModif			= -1.0;
	data.AttackspeedBuff			= (1.0 / 1.05);
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

void WeakeningCompoundStart(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	//not an npc, ignore.
	if(!b_ThisWasAnNpc[victim])
		return;
	
	SetEntityRenderColor_NpcAll(victim, 2.0, 2.0, 0.25);
}
void WeakeningCompoundEnd(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	//not an npc, ignore.
	if(!b_ThisWasAnNpc[victim])
		return;

	SetEntityRenderColor_NpcAll(victim, 0.5, 0.5, 4.0);
}


#if defined ZR
void StatusEffects_Rogue3()
{
	StatusEffect data;
	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Fisticuffs");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.Positive 					= false;
	data.Slot					= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Kolum's View");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "ꝃ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.Positive 					= false;
	data.ElementalLogic				= true;
	data.OnBuffStarted				= KolumView_Start;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Umbral Grace");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "₲");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.Positive 					= true;
	data.DamageTakenMulti 			= 0.75;
	data.DamageDealMulti			= 0.85;
	data.TimerRepeatCall_Func 		= UmbralGrace_Timer;
	data.OnBuffStarted				= UmbralGrace_Start;
	data.OnBuffEndOrDeleted			= UmbralGrace_End;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);


	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Brightening Light");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Br");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.Positive 					= true;
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.AttackspeedBuff			= (1.0 / 1.35);
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Revival Stim");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "RS");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.Positive 					= true;
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 1.15;
	data.OnBuffStarted				= RevivalStim_Start;
	data.OnBuffStoreRefresh			= RevivalStim_Start;
	data.OnBuffEndOrDeleted			= RevivalStim_End;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);

	
	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Umbral Grace Debuff");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.Positive 					= false;
	data.AttackspeedBuff			= 1.15;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Void Afflicted");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "Ɣ");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.75;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	data.OnBuffStarted				= VoidAffliction_Start;
	data.OnBuffEndOrDeleted			= VoidAffliction_End;
	data.OnTakeDamage_PostAttacker	= VoidAffliction_TakeDamageAttackerPost;
	ShrinkingStatusEffectIndex = StatusEffect_AddGlobal(data);
	
	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Ultra Rapid Fire");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "URF");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= -1.0;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 1.25;
	data.AttackspeedBuff			= (1.0 / 1.4);
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}


void UmbralGrace_Timer(int entity, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(entity <= MaxClients)
	{
		if(Armor_Charge[entity] >= 0)
			return;

		GiveArmorViaPercentage(entity, 0.025, 1.0, _, true);
	}
	else
	{
		if(!b_ThisWasAnNpc[entity])
			return;
		
		
		for(int i; i < Element_MAX; i++) // Remove all elementals except Plasma 
		{
			Elemental_RemoveDamage(entity, i, RoundToNearest(float(Elemental_TriggerDamage(entity, i)) * 0.025));
		}
	}
}
static void UmbralGrace_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!(b_ThisWasAnNpc[victim] || victim <= MaxClients))
		return;
	
	if(IsValidEntity(Apply_StatusEffect.WearableUse))
		return;

	float flPos[3];
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", flPos);
	int ParticleEffect = ParticleEffectAt_Parent(flPos, "utaunt_treespiral_blue_glow", victim, "", {0.0,0.0,0.0});
	
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
	Apply_StatusEffect.WearableUse = EntIndexToEntRef(ParticleEffect);
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
}

static void KolumView_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(victim > MaxClients)
		return;

	EmitSoundToClient(victim, g_MarkSoundUmbral[GetRandomInt(0, sizeof(g_MarkSoundUmbral) - 1)], victim, SNDCHAN_STATIC, _, _, 1.0, 20);
	EmitSoundToClient(victim, g_MarkSoundUmbral[GetRandomInt(0, sizeof(g_MarkSoundUmbral) - 1)], victim, SNDCHAN_STATIC, _, _, 1.0, 20);
}
static void UmbralGrace_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidEntity(Apply_StatusEffect.WearableUse))
		return;
	RemoveEntity(Apply_StatusEffect.WearableUse);
}

#endif



void StatusEffects_GamemodeMadnessSZF()
{
	StatusEffect data;
	data.Blank();
	strcopy(data.BuffName, sizeof(data.BuffName), "Damage Scaling");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	data.Positive 					= false;
	data.DamageTakenMulti 			= 0.1;
	data.DamageDealMulti			= 0.1;
	data.OnTakeDamage_TakenFunc 	= SZF_DamageScalingtaken;
	data.OnTakeDamage_DealFunc 		= SZF_DamageScalingdeal;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}

float SZF_DamageScalingtaken(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype, float basedamage, float DamageBuffExtraScaling)
{
	//look at how many enemies are left alive, and then scale off tha
	float ValueDo;
	int AliveAssume = CountPlayersOnRed(2);
	if(AliveAssume > 14)
		AliveAssume = 14;
	ValueDo = float(AliveAssume) / float(CountPlayersOnRed(0));
	float resist = ValueDo;
	if(resist >= 1.0)
	{
		resist = 1.0;
	}
	resist -= 1.0;
	resist *= -1.0;
	resist *= 10.0;
	return (basedamage * resist);
}

float SZF_DamageScalingdeal(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
	float ValueDo;
	int AliveAssume = CountPlayersOnRed(2);
	if(AliveAssume > 14)
		AliveAssume = 14;
	ValueDo = float(AliveAssume) / float(CountPlayersOnRed(0));
	float resist = ValueDo;
	return resist;
}


static void Terrified_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
		
	Attributes_SetMulti(victim, 442, 0.5);
	SDKCall_SetSpeed(victim);
}

static void Terrified_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
	Attributes_SetMulti(victim, 442, (1.0 / 0.5));
	SDKCall_SetSpeed(victim);
}


static void RevivalStim_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
		
	Attributes_SetMulti(victim, 442, 1.15);
	SDKCall_SetSpeed(victim);
}

static void RevivalStim_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
	Attributes_SetMulti(victim, 442, (1.0 / 1.15));
	SDKCall_SetSpeed(victim);
}



void VoidAffliction_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	//not an npc, ignore.
	if(!b_ThisWasAnNpc[victim])
		return;
	
	CClotBody npc = view_as<CClotBody>(victim);
	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
	Apply_StatusEffect.DataForUse = float(npc.m_iBleedType);
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
	npc.m_iBleedType = BLEEDTYPE_VOID;
	SetEntityRenderColor_NpcAll(victim, 1.25, 0.25, 1.25);
}
void VoidAffliction_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	//not an npc, ignore.
	if(!IsValidEntity(victim))
		return;
		
	if(!b_ThisWasAnNpc[victim])
		return;

	CClotBody npc = view_as<CClotBody>(victim);
	npc.m_iBleedType = RoundToNearest(Apply_StatusEffect.DataForUse);
	SetEntityRenderColor_NpcAll(victim, (1.0 / 1.25), (1.0 / 0.25), (1.0 / 1.25));
}


void VoidAffliction_TakeDamageAttackerPost(int attacker, int victim, float damage, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int damagetype)
{
#if defined ZR
	if(attacker == victim)
		return;
		
	Elemental_AddVoidDamage(victim, attacker, RoundToNearest(damage * 3.0), true, true);
#endif
}




static void UnstableUmbralRift_Start(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(!IsValidClient(victim))
		return;
		
	Attributes_SetMulti(victim, 442, 0.85);
	Attributes_SetMulti(victim, 610, 0.35);
	Attributes_SetMulti(victim, 326, 1.5);
	SDKCall_SetSpeed(victim);
}


static void UnstableUmbralRift_StartOnce(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(victim <= MaxClients)
		i_Client_Gravity[victim] /= 2;
	if(!IsValidClient(victim))
		return;
		
	Attributes_SetMulti(victim, 442, 0.85);
	Attributes_SetMulti(victim, 610, 0.35);
	Attributes_SetMulti(victim, 326, 1.75);
	SDKCall_SetSpeed(victim);
}

static void UnstableUmbralRift_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(victim <= MaxClients)
		i_Client_Gravity[victim] *= 2;
	if(!IsValidClient(victim))
		return;
		
	Attributes_SetMulti(victim, 442, (1.0 / 0.85));
	Attributes_SetMulti(victim, 610, (1.0 / 0.35));
	Attributes_SetMulti(victim, 326, (1.0 / 1.75));
	SDKCall_SetSpeed(victim);
}




void StatusEffects_Construction2()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Chaos Demon Possession");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "CD");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), "");
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.35;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= 1.15;
	data.Positive 					= true;
	data.ShouldScaleWithPlayerCount = false;
	data.Slot						= 0;
	data.SlotPriority				= 0;
	//-0.5
	data.OnBuffStarted				= ChaosDemonInfultration_StartOnce;
	data.OnBuffEndOrDeleted			= ChaosDemonInfultration_End;
	data.AttackspeedBuff			= (1.0 / 1.5);
	StatusEffect_AddGlobal(data);
}

static void ChaosDemonInfultration_StartOnce(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(IsValidEntity(Apply_StatusEffect.WearableUse))
		return;
	if(IsValidEntity(Apply_StatusEffect.WearableUse2))
		return;

	CClotBody npc = view_as<CClotBody>(victim);

	float maxhealth = float(ReturnEntityMaxHealth(victim));
	HealEntityGlobal(victim, victim, maxhealth, 1.0, 0.0, HEAL_SELFHEAL);
	float flPos[3];
	float flAng[3];
	npc.GetAttachment("eyes", flPos, flAng);
	int ParticleEffect_1 = ParticleEffectAt_Parent(flPos, "unusual_smoking", victim, "eyes", {10.0,0.0,-5.0});
	int ParticleEffect_2 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", victim, "eyes", {10.0,0.0,-20.0});

	int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
	Apply_StatusEffect.WearableUse = EntIndexToEntRef(ParticleEffect_1);
	Apply_StatusEffect.WearableUse2 = EntIndexToEntRef(ParticleEffect_2);
	E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
}

static void ChaosDemonInfultration_End(int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect)
{
	if(IsValidEntity(Apply_StatusEffect.WearableUse))
	{
		RemoveEntity(Apply_StatusEffect.WearableUse);
	}
	if(IsValidEntity(Apply_StatusEffect.WearableUse2))
	{
		RemoveEntity(Apply_StatusEffect.WearableUse2);
	}
}



void StatusEffects_AllyInvulnDebuffs()
{
	StatusEffect data;
	strcopy(data.BuffName, sizeof(data.BuffName), "Bob Debuff");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⸗");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.15;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
	
	strcopy(data.BuffName, sizeof(data.BuffName), "Bob Debuff Enrage");
	strcopy(data.HudDisplay, sizeof(data.HudDisplay), "⸗⸗");
	strcopy(data.AboveEnemyDisplay, sizeof(data.AboveEnemyDisplay), ""); //dont display above head, so empty
	//-1.0 means unused
	data.DamageTakenMulti 			= 0.25;
	data.DamageDealMulti			= -1.0;
	data.MovementspeedModif			= -1.0;
	data.Positive 					= false;
	data.ShouldScaleWithPlayerCount = true;
	data.Slot						= 0; //0 means ignored
	data.SlotPriority				= 0; //if its higher, then the lower version is entirely ignored.
	StatusEffect_AddGlobal(data);
}