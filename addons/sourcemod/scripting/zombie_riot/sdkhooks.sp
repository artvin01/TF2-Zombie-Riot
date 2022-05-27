#if !defined NoSendProxyClass
static const float ViewHeights[] =
{
	75.0,
	65.0,
	75.0,
	68.0,
	68.0,
	75.0,
	75.0,
	68.0,
	75.0,
	68.0
};
#endif

//static int g_offsPlayerPunchAngleVel = -1;
#define SF2_PLAYER_VIEWBOB_TIMER 10.0
#define SF2_PLAYER_VIEWBOB_SCALE_X 0.05
#define SF2_PLAYER_VIEWBOB_SCALE_Y 0.0
#define SF2_PLAYER_VIEWBOB_SCALE_Z 0.0

static float Armor_regen_delay[MAXTF2PLAYERS];
//static float Check_Standstill_Delay[MAXTF2PLAYERS];
//static bool Check_Standstill_Applied[MAXTF2PLAYERS];

float max_mana[MAXTF2PLAYERS];
float mana_regen[MAXTF2PLAYERS];
bool has_mage_weapon[MAXTF2PLAYERS];

public void SDKHooks_ClearAll()
{
	Zero(Armor_regen_delay);
	
}
void SDKHook_PluginStart()
{
	/*
	g_offsPlayerPunchAngleVel = FindSendPropInfo("CBasePlayer", "m_vecPunchAngleVel");
	if (g_offsPlayerPunchAngleVel == -1) LogError("Couldn't find CBasePlayer offset for m_vecPunchAngleVel!");
	*/
	AddNormalSoundHook(SDKHook_NormalSHook);
}

void SDKHook_MapStart()
{
	int entity = FindEntityByClassname(MaxClients+1, "tf_player_manager");
	if(entity != -1)
		SDKHook(entity, SDKHook_ThinkPost, SDKHook_ScoreThink);
}

public void SDKHook_ScoreThink(int entity)
{
	static int offset = -1;
	if(offset == -1) 
		offset = FindSendPropInfo("CTFPlayerResource", "m_iTotalScore");
	
	SetEntDataArray(entity, offset, PlayerPoints, MaxClients + 1);
}

void SDKHook_HookClient(int client)
{
	SDKUnhook(client, SDKHook_PostThink, OnPostThink);
	SDKUnhook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKUnhook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	
	SDKHook(client, SDKHook_PostThink, OnPostThink);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKHook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	
	#if !defined NoSendProxyClass
	SDKUnhook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	#endif
}

public void OnPreThinkPost(int client)
{
	if(CvarMpSolidObjects)
		CvarMpSolidObjects.IntValue	= b_PhasesThroughBuildingsCurrently[client] ? 0 : 1;
}

public void OnPostThink(int client)
{
	float gameTime = GetGameTime();
#if !defined NoSendProxyClass
//	if(IsPlayerAlive(client)) //This isnt needed if you dont got send proxy 
#endif
	{
#if !defined NoSendProxyClass
		if(WeaponClass[client]!=TFClass_Unknown)
		{
			TF2_SetPlayerClass(client, WeaponClass[client], false, false);
			if(GetEntPropFloat(client, Prop_Send, "m_vecViewOffset[2]") > 64.0)	// Otherwise, shaking
				SetEntPropFloat(client, Prop_Send, "m_vecViewOffset[2]", ViewHeights[WeaponClass[client]]);
		}
#endif
		/*
		if(Check_Standstill_Delay[client] < gameTime)
		{
			float vec[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
			if(vec[0] == 0 && vec[1] == 0)
			{
				if(!Check_Standstill_Applied[client])
				{
					int weapon = GetPlayerWeaponSlot(client, 2);
					if(weapon >= MaxClients && !i_NoBonusRange[weapon])
					{
						TF2Attrib_SetByDefIndex(weapon, 264, 2.25);
					}
					Check_Standstill_Applied[client] = true;
				}
				Check_Standstill_Delay[client] = gameTime + 0.1;
			}
			else
			{
				if(Check_Standstill_Applied[client])
				{
					Check_Standstill_Applied[client] = false;
					int weapon = GetPlayerWeaponSlot(client, 2);
					if(weapon >= MaxClients && !i_NoBonusRange[weapon])
					{
						TF2Attrib_SetByDefIndex(weapon, 264, 1.25);
					}
				}
				Check_Standstill_Delay[client] = gameTime + 1.0;				
			}
		}
		*/
		if(Mana_Regen_Delay[client] < gameTime)	
		{
			Mana_Regen_Delay[client] = gameTime + 0.4;
			
			int weapon = GetPlayerWeaponSlot(client, 2);
			if(!EscapeMode && IsValidEntity(weapon))
			{
				max_mana[client] = 600.0;
				mana_regen[client] = 10.0;
				
				if(LastMann)
					mana_regen[client] *= 20.0; // 20x the regen to help last man mage cus they really suck otherwise alone.
					
				if(i_CurrentEquippedPerk[client] == 4)
				{
					mana_regen[client] *= 1.35;
				}
				
				if(Mana_Regen_Level[weapon])
				{			
					mana_regen[client] *= Mana_Regen_Level[weapon];
					max_mana[client] *= Mana_Regen_Level[weapon];	
					has_mage_weapon[client] = true;
				}
				else
				{
					has_mage_weapon[client] = false;
				}
				/*
				Current_Mana[client] += RoundToCeil(mana_regen[client]);
					
				if(Current_Mana[client] < RoundToCeil(max_mana[client]))
					Current_Mana[client] = RoundToCeil(max_mana[client]);
				*/
				
				if(Current_Mana[client] < RoundToCeil(max_mana[client]))
				{
					Current_Mana[client] += RoundToCeil(mana_regen[client]);
					
					if(Current_Mana[client] > RoundToCeil(max_mana[client])) //Should only apply during actual regen
						Current_Mana[client] = RoundToCeil(max_mana[client]);
				}
					
				Mana_Hud_Delay[client] = 0.0;
			}
			else if (IsValidEntity(weapon))
			{
			//	if(Mana_Regen_Level[weapon])
			//	{				
			//		has_mage_weapon[client] = true;
			//	}
				has_mage_weapon[client] = true;
				max_mana[client] = 1200.0;
				mana_regen[client] = 20.0;
				if(i_CurrentEquippedPerk[client] == 4)
				{
					mana_regen[client] *= 1.35;
				}
				Current_Mana[client] += RoundToCeil(mana_regen[client]);
					
				if(Current_Mana[client] > RoundToCeil(max_mana[client]))
					Current_Mana[client] = RoundToCeil(max_mana[client]);
				
				Mana_Hud_Delay[client] = 0.0;
			}
		}
		if(Armor_regen_delay[client] < gameTime)
		{
			Armour_Level_Current[client] = 0;
			int flHealth = GetEntProp(client, Prop_Send, "m_iHealth");
			int flMaxHealth = SDKCall_GetMaxHealth(client);
				
			if (Jesus_Blessing[client] == 1)
			{
				
				int flMaxHealthJesus;
				
				flMaxHealthJesus = flMaxHealth;
				
				flMaxHealthJesus /= 2;
				
				if(flHealth < flMaxHealthJesus)
				{
					
					int healing_Amount = flMaxHealthJesus / 50;
					
					if(dieingstate[client] > 0)
					{
						healing_Amount = 3;
					}
					int newHealth = flHealth + healing_Amount;
						
					if(newHealth >= flMaxHealthJesus)
					{
						healing_Amount -= newHealth - flMaxHealthJesus;
						newHealth = flMaxHealthJesus;
					}
					
					SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
				
				}
			}
			if(i_BadHealthRegen[client] == 1)
			{
				if(flHealth < flMaxHealth)
				{
					int healing_Amount = 1;
					
					int newHealth = flHealth + healing_Amount;
						
					if(newHealth >= flMaxHealth)
					{
						healing_Amount -= newHealth - flMaxHealth;
						newHealth = flMaxHealth;
					}
					
					SetEntProp(client, Prop_Send, "m_iHealth", newHealth);
				}
				
			}
			int Armor_Max = 50;
			int Extra = 0;
		
			Extra = Armor_Level[client];
				
			Armor_Max = MaxArmorCalculation(Extra, client, 0.25);
			
			if(Extra == 50)
			{
				Armour_Level_Current[client] = 1;
			}
			if(Extra == 100)
			{
				Armour_Level_Current[client] = 2;
			}
				
			if(Extra == 150)
			{
				Armour_Level_Current[client] = 3;
			}
			if(Extra == 200)
			{
				Armour_Level_Current[client] = 4;
			}
			
			if(Extra >= 50)
			{			
				if(Armor_Charge[client] < Armor_Max)
				{
					if(Extra == 50)
					{
						Armor_Charge[client] += 1;
					}
					else if(Extra == 100)
					{
						Armor_Charge[client] += 2;
					}
					else if(Extra == 150)
					{
						Armor_Charge[client] += 3;
					}
					else if(Extra == 200)
					{
						Armor_Charge[client] += 5;
					}
				}
			}
			Armor_regen_delay[client] = gameTime + 1.0;
		}
	}
	if(has_mage_weapon[client] && Mana_Hud_Delay[client] < gameTime)	
	{
		Mana_Hud_Delay[client] = gameTime + 0.4;
		int red = 255;
		int green = 0;
		int blue = 255;
		
		red = Current_Mana[client] * 255  / RoundToFloor(max_mana[client]);
		
		blue = Current_Mana[client] * 255  / RoundToFloor(max_mana[client]);
		 
		red = 255 - red;
		
		if(red > 255)
			red = 255;
		
		if(blue > 255)
			blue = 255;
			
		if(red < 0)
			red = 0;
			
		if(blue < 0)
			blue = 0;
		
		SetHudTextParams(-1.0, 0.85, 3.01, red, green, blue, 255);
		
			
			
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_WandMana, "%t", "Current Mana", Current_Mana[client], max_mana[client], mana_regen[client]);
	}
	if(delay_hud[client] < gameTime)	
	{
		UpdatePlayerPoints(client);
		delay_hud[client] = gameTime + 0.4;
		
		if(LastMann || dieingstate[client] > 0)
		{
			DoOverlay(client, "debug/yuv");
		}
		//Removed "Medi-Kit Cooldown", Heal_CD
		/*
		float Heal_CD = healing_cooldown[client] - gameTime;
		
		if(Heal_CD <= 0.0)
			Heal_CD = 0.0;
		*/
		/*
		float Armor_CD = Armor_Ready[client] - gameTime;
		
		if(Armor_CD <= 0.0)
			Armor_CD = 0.0;
		*/
		
		if(Waves_Started())
		{
			if(!TeutonType[client])
			{
				if(!EscapeMode)
				{
					PrintKeyHintText(client, "%t\n%t\n%t\n%t\n%t\n%t\n%t\n%t",
					"Credits_Menu", CurrentCash-CashSpent[client], Resupplies_Supplied[client] * 10,	
					"Wave", CurrentRound+1, CurrentWave+1,
					"Armor Counter", Armor_Charge[client],
					"Ammo Crate Supplies", Ammo_Count_Ready[client], //This bugs in russian
					"Healing Done", Healing_done_in_total[client],
					"Damage Dealt", Damage_dealt_in_total[client],
					PerkNames[i_CurrentEquippedPerk[client]],
					"Zombies Left", Zombies_Currently_Still_Ongoing);
				}
				else
				{
					PrintKeyHintText(client, "%t\n%t\n%t",
					"Armor Counter", Armor_Charge[client],
					"Healing Done", Healing_done_in_total[client],
					"Damage Dealt", Damage_dealt_in_total[client]);/*,
					PerkNames[i_CurrentEquippedPerk[client]]);		*/	
				}
			}
			else if (TeutonType[client] == TEUTON_DEAD)
			{
				PrintKeyHintText(client, "%t\n%t\n%t","You Died Teuton",
											"Wave", CurrentRound+1, CurrentWave+1,
											"Zombies Left", Zombies_Currently_Still_Ongoing);
			}
			else
			{
				PrintKeyHintText(client, "%t\n%t\n%t","You Wait Teuton",
											"Wave", CurrentRound+1, CurrentWave+1,
											"Zombies Left", Zombies_Currently_Still_Ongoing);
			}
		}
	}
	if(f_DelayLookingAtHud[client] < GetGameTime())
	{
		if (IsPlayerAlive(client))
		{
			StartPlayerOnlyLagComp(client, true);
			int entity = GetClientPointVisible(client); //So you can also correctly interact with players holding shit.
			EndPlayerOnlyLagComp();
			Building_ShowInteractionHud(client, entity);
			f_DelayLookingAtHud[client] = GetGameTime() + 0.2;	
		}
		else
		{
			f_DelayLookingAtHud[client] = GetGameTime() + 2.0;
		}
	}
	
	Music_PostThink(client);
}

#if !defined NoSendProxyClass
public void OnPostThinkPost(int client)
{
	if(IsPlayerAlive(client) && CurrentClass[client]!=TFClass_Unknown)
		TF2_SetPlayerClass(client, CurrentClass[client], false, false);
}
#endif

/*
public void OnPreThink(int client)
{
	
	float flPunchVel[3];
	float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
	float flpercenthpfrommax = flHealth / 200.0;
	
	if(flpercenthpfrommax < 0.25 || LastMann)
	{
		if(flpercenthpfrommax < 0.25 && !is_low_hp[client])
		{
			is_low_hp[client] = true;
			CreateTimer(0.1, Timer_EnableFp_Force, client);	
		}
		
		if(LastMann && flpercenthpfrommax > 0.25)
			flHealth = 100.0;
			
		if (GetEntityFlags(client) & FL_ONGROUND)
		{
			float flVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVelocity);
			float flSpeed = GetVectorLength(flVelocity);
			
			float flPunchIdle[3];
			
			if (flSpeed > 0.0)
			{	
				flPunchIdle[0] = Sine(gameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_X / 1200.0;
				flPunchIdle[1] = Sine(2.0 * gameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_Y / 1200.0;
				flPunchIdle[2] = Sine(1.6 * gameTime * SF2_PLAYER_VIEWBOB_TIMER) * flSpeed/4 * SF2_PLAYER_VIEWBOB_SCALE_Z / 1200.0;
					
				AddVectors(flPunchVel, flPunchIdle, flPunchVel);
				
				// Calculate roll.
				float flForward[3], flVelocityDirection[3];
				GetClientEyeAngles(client, flForward);
				GetVectorAngles(flVelocity, flVelocityDirection);
						
				float flYawDiff = AngleDiff(flForward[1], flVelocityDirection[1]);
				if (FloatAbs(flYawDiff) > 90.0) flYawDiff = AngleDiff(flForward[1] + 180.0, flVelocityDirection[1]) * -1.0;
						
				float flWalkSpeed = 300.0;
				float flRollScalar = flSpeed / flWalkSpeed;
				if (flRollScalar > 1.0) flRollScalar = 1.0;
						
				float flRollScale = (flYawDiff / 90.0) * 0.25 * flRollScalar;
				flPunchIdle[0] = 0.0;
				flPunchIdle[1] = 0.0;
				flPunchIdle[2] = flRollScale * -1.0;
						
				AddVectors(flPunchVel, flPunchIdle, flPunchVel);
			}
		}
		ClientViewPunch(client, flPunchVel);
	}
	else if (flpercenthpfrommax >= 0.25 && is_low_hp[client])
	{
		is_low_hp[client] = false;
		if(thirdperson[client])
		{
			CreateTimer(0.1, Timer_EnableTp_Force, client);	
		}
	}
	
}
*/

float f_OneShotProtectionTimer[MAXTF2PLAYERS];

public Action Player_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(TeutonType[victim])
		return Plugin_Handled;
		
		
	float gameTime = GetGameTime();
	
	if(IsInvuln(victim))	
	{
		f_TimeUntillNormalHeal[victim] = gameTime + 4.0;
		return Plugin_Continue;	
	}
		
		
	float Replicated_Damage;
	Replicated_Damage = Replicate_Damage_Medications(victim, damage, damagetype);
	
	int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
	if(dieingstate[victim] > 0)
	{
		if(flHealth < 1)
		{
			if(!(damagetype & DMG_DROWN))
			{
				SDKHooks_TakeDamage(victim, victim, victim, 9999.0, DMG_DROWN, _, _, _, true);
			}
			damage = 9999.0;
			return Plugin_Continue;	
		}
		return Plugin_Handled;
	}
	else
	{
		if(victim == attacker)
			return Plugin_Handled;
	}
	
	if(attacker <= MaxClients && attacker > 0)	
		return Plugin_Handled;	
		
		
	f_TimeUntillNormalHeal[victim] = gameTime + 4.0;
	
	if(damagetype & DMG_DROWN)
	{
		f_TimeUntillNormalHeal[victim] = gameTime + 4.0;
		Replicated_Damage *= 2.0;
		damage *= 2.0;
		return Plugin_Changed;	
	}

	if(EscapeMode)
	{
		int Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(Victim_weapon))
		{
			if(!IsWandWeapon(Victim_weapon)) //Make sure its not wand.
			{
				char melee_classname[64];
				GetEntityClassname(Victim_weapon, melee_classname, 64);
				
				if (TFWeaponSlot_Melee == TF2_GetClassnameSlot(melee_classname))
				{
					Replicated_Damage *= 0.45;
					damage *= 0.45;
				}
			}
		}
	}
	
	if(i_CurrentEquippedPerk[victim] == 2)
	{
		Replicated_Damage *= 0.85;
		damage *= 0.85;
	}
	
	if(damagetype & DMG_FALL)
	{
		if(RaidBossActive)
		{
			Replicated_Damage *= 0.2;
			damage *= 0.2;			
		}
		else if(i_SoftShoes[victim] == 1)
		{
			Replicated_Damage *= 0.5;
			damage *= 0.5;
		}
	}
	else
	{
		bool Though_Armor = false;
		
		if(Resistance_Overall_Low[victim] > gameTime)
		{
			Replicated_Damage *= 0.85;
			damage *= 0.85;
		}
			
		if(Armor_Charge[victim] > 0)
		{
			int dmg_through_armour = RoundToCeil(Replicated_Damage * 0.1);
			
			if(RoundToCeil(Replicated_Damage * 0.9) >= Armor_Charge[victim])
			{
				int damage_recieved_after_calc;
				damage_recieved_after_calc = RoundToCeil(Replicated_Damage) - Armor_Charge[victim];
				Armor_Charge[victim] = 0;
				damage = float(damage_recieved_after_calc);
				Replicated_Damage  = float(damage_recieved_after_calc);
				EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.25);
			}
			else
			{
				Armor_Charge[victim] -= RoundToCeil(Replicated_Damage * 0.9);
				damage = 0.0;
				damage += float(dmg_through_armour);
				Replicated_Damage = 0.0;
				Replicated_Damage += float(dmg_through_armour);
				Though_Armor = true;
			}
		}
		switch(Armour_Level_Current[victim])
		{
			case 1:
			{
				damage *= 0.9;
				Replicated_Damage *= 0.9;
				if(Though_Armor)
					EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
			}
			case 2:
			{
				damage *= 0.85;
				Replicated_Damage *= 0.85;
				if(Though_Armor)
					EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
			}
			case 3:
			{
				damage *= 0.8;
				Replicated_Damage *= 0.80;
				if(Though_Armor)
					EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
			}
			case 4:
			{
				damage *= 0.75;
				Replicated_Damage *= 0.75;
				if(Though_Armor)
					EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.15);
			}
			default:
			{
				damage *= 1.0;
				Replicated_Damage *= 1.0;
			}
		}
	}
	if((RoundToCeil(Replicated_Damage) >= flHealth || RoundToCeil(damage) >= flHealth) && (LastMann || b_IsAloneOnServer) && f_OneShotProtectionTimer[victim] < GetGameTime())
	{
		damage = float(flHealth - 1); //survive with 1 hp!
		TF2_AddCondition(victim, TFCond_UberchargedCanteen, 1.0);
		TF2_AddCondition(victim, TFCond_MegaHeal, 1.0);
		EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
		f_OneShotProtectionTimer[victim] = gameTime + 120.0; // 120 second cooldown
		return Plugin_Changed;
	}
	else if((RoundToCeil(Replicated_Damage) >= flHealth || RoundToCeil(damage) >= flHealth) && !LastMann && !b_IsAloneOnServer)
	{
		bool Any_Left = false;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client) && TeutonType[client] != TEUTON_WAITING)
			{
				if(victim != client && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
				{
					Any_Left = true;
				}
			}
		}
		
		if(!Any_Left)
		{
			CheckAlivePlayers(_, victim);
			return Plugin_Handled;
		}
	
		i_CurrentEquippedPerk[victim] = 0;
		SetEntityHealth(victim, 200);
		dieingstate[victim] = 250;
		SetEntityCollisionGroup(victim, 1);
		CClotBody player = view_as<CClotBody>(victim);
		player.m_bThisEntityIgnored = true;
		TF2Attrib_SetByDefIndex(victim, 489, 0.15);
		TF2Attrib_SetByDefIndex(victim, 820, 1.0);
		TF2Attrib_SetByDefIndex(victim, 819, 1.0);	
		TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 0.00001);
		
		int entity = EntRefToEntIndex(i_DyingParticleIndication[victim]);
		if(entity > MaxClients)
			RemoveEntity(entity);
		
		entity = TF2_CreateGlow(victim);
		i_DyingParticleIndication[victim] = EntIndexToEntRef(entity);
		
		SetVariantColor(view_as<int>({0, 255, 0, 255}));
		AcceptEntityInput(entity, "SetGlowColor");
		
		CreateTimer(0.1, Timer_Dieing, victim, TIMER_REPEAT);
		
		int i;
		while(TF2U_GetWearable(victim, entity, i))
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 255, 255, 255, 125);
		}
		SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
		SetEntityRenderColor(victim, 255, 255, 255, 125);
		return Plugin_Handled;
	}
	return Plugin_Changed;
}



public float Replicate_Damage_Medications(int victim, float damage, int damagetype)
{
	if(TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffed))
	{
		if(damagetype & (DMG_CRIT))
		{
			damage /= 3.0; //Remove crit shit from the calcs!, there are no minicrits here, so i dont have to care
		}
		damage *= 0.65;
	}
	float value;
	
	if(damagetype & (DMG_CLUB|DMG_SLASH))
	{
		value = Attributes_FindOnPlayer(victim, 206);	// MELEE damage resitance
		if(value)
			damage *= value;
	}
		
	value = Attributes_FindOnPlayer(victim, 412);	// Overall damage resistance
	if(value)
		damage *= value;	
		
	return damage;
}

public Action SDKHook_NormalSHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(StrContains(sample, "sentry_", true) != -1)
	{
		volume *= 0.4;
		level = SNDLEVEL_NORMAL;
		
		if(StrContains(sample, "sentry_spot", true) != -1)
			volume *= 0.35;
			
		return Plugin_Changed;
	}
	if(StrContains(sample, "misc/halloween/spell_") != -1)
	{
		volume *= 0.75;
		level = SNDLEVEL_NORMAL;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void OnWeaponSwitchPost(int client, int weapon)
{
	if(weapon != -1)
	{
		int weapon2 = weapon;
		
		char buffer[36];
		GetEntityClassname(weapon2, buffer, sizeof(buffer));
		Building_WeaponSwitchPost(client, weapon2, buffer);
		ViewChange_Switch(client, weapon2, buffer);
	}
}

/*
static void ClientViewPunch(int client, const float angleOffset[3])
{
	if (g_offsPlayerPunchAngleVel == -1) return;
	
	float flOffset[3];
	for (int i = 0; i < 3; i++) flOffset[i] = angleOffset[i];
	ScaleVector(flOffset, 20.0);
	
	
	if (!IsFakeClient(client))
	{
		// Latency compensation.
		float flLatency = GetClientLatency(client, NetFlow_Outgoing);
		float flLatencyCalcDiff = 60.0 * Pow(flLatency, 2.0);
		
		for (int i = 0; i < 3; i++) flOffset[i] += (flOffset[i] * flLatencyCalcDiff);
	}
	
	
	float flAngleVel[3];
	GetEntDataVector(client, g_offsPlayerPunchAngleVel, flAngleVel);
	AddVectors(flAngleVel, flOffset, flOffset);
	SetEntDataVector(client, g_offsPlayerPunchAngleVel, flOffset, true);
}
*/