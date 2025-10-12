#pragma semicolon 1
#pragma newdecls required

#define RES_BATTILONS 0.85
#define RES_MEDIGUN_LOW 0.95

#define DMG_MEDIGUN_LOW 1.25
#define DMG_WIDOWS_WINE 1.35

float BarbariansMindNotif[MAXPLAYERS];
void DamageModifMapStart()
{
	Zero(BarbariansMindNotif);
}

stock bool Damage_Modifiy(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//LogEntryInvicibleTest(victim, attacker, damage, 5);

#if defined ZR
	if(inflictor > 0 && inflictor < MAXENTITIES && i_IsVehicle[inflictor] == 2)
		attacker = Vehicle_Driver(inflictor);
#endif
	
	if(Damage_AnyVictim(victim, attacker, inflictor, damage, damagetype, weapon))
		return true;

	if(attacker >= 0)
	{
		if(Damage_AnyAttacker(victim, attacker, inflictor, damage, damagetype))
			return true;
		
		//LogEntryInvicibleTest(victim, attacker, damage, 13);
		if(attacker <= MaxClients)
		{
#if !defined RTS
			if(Damage_PlayerAttacker(attacker, damage, damagetype, weapon))
				return true;
#endif
			//LogEntryInvicibleTest(victim, attacker, damage, 14);
		}
		else if(b_ThisWasAnNpc[attacker])
		{
			if(Damage_NPCAttacker(attacker, damage, damagetype))
				return true;
			//LogEntryInvicibleTest(victim, attacker, damage, 15);
		}
		else if(i_IsABuilding[attacker])
		{
			if(Damage_BuildingAttacker(attacker, damage))
				return true;
			//LogEntryInvicibleTest(victim, attacker, damage, 16);
		}
	}
	
	//LogEntryInvicibleTest(victim, attacker, damage, 6);
	if(victim <= MaxClients)
	{
#if !defined RTS
		if(Damage_PlayerVictim(victim, attacker, inflictor, damage, damagetype, weapon, damagePosition))
			return true;
		//LogEntryInvicibleTest(victim, attacker, damage, 7);
#endif
	}
	else if(b_ThisWasAnNpc[victim])
	{
		if(Damage_NPCVictim(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
			return true;
		//LogEntryInvicibleTest(victim, attacker, damage, 8);
	}
	else if(i_IsABuilding[victim])
	{
		if(Damage_BuildingVictim(victim, attacker, inflictor, damage, damagetype, weapon))
			return true;
		//LogEntryInvicibleTest(victim, attacker, damage, 9);
	}
	Damage_AnyVictimPost(victim, damage, damagetype);
	return false;
}

stock void Damage_AnyVictimPost(int victim, float &damage, int &damagetype)
{
	if(!HasSpecificBuff(victim, "Expert's Mind"))
		return;

	if((damagetype & DMG_TRUEDAMAGE))
		return;

	float MaxHealth = float(ReturnEntityMaxHealth(victim));
	MaxHealth *= 0.25;
	if(MaxHealth <= 50.0)
		MaxHealth = 50.0;

	if(damage >= MaxHealth)
		damage = MaxHealth;
		
}
stock bool Damage_AnyVictim(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
#if defined ZR
	if(Rogue_Mode())
	{
		//Has to be here.
		damage *= RogueBladedance_DamageBonus(attacker, inflictor, victim);

		if(GetTeam(victim) == TFTeam_Red)
		{
			int scale = Waves_GetRoundScale();
			if(scale < 1)
			{
				damage *= 0.50;
			}
			else if(scale < 2)
			{
				damage *= 0.75;
			}
		}
	}
	if(!CheckInHud())
		Rogue_TakeDamage(victim, attacker, inflictor, damage, damagetype, weapon);
#endif
	if(!CheckInHud() && !b_NpcIsTeamkiller[attacker])
	{
		if(GetTeam(attacker) == GetTeam(victim)) //should be entirely ignored
		{
#if defined RPG
			if(attacker <= MaxClients && attacker > 0 && attacker != 0)
			{
				if(!(RPGCore_PlayerCanPVP(attacker,victim)))
					return true;

			}
			else
#endif
			{
				return true;
			}
		}
	}
	
#if defined RPG
	if(!CheckInHud())
		if(b_ThisWasAnNpc[attacker])
			f_InBattleDelay[attacker] = GetGameTime() + 6.0;
#endif

	return false;
}

#if !defined RTS
stock bool Damage_PlayerVictim(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damagePosition[3])
{
#if defined RPG
	if(attacker <= MaxClients && attacker > 0 && attacker != 0)
	{
		if(!(RPGCore_PlayerCanPVP(attacker,victim)))
			return true;

		if(!CheckInHud())
			LastHitRef[victim] = EntIndexToEntRef(attacker);
	}
#endif

	if(!CheckInHud())
		HudDamageIndicator(victim,damagetype, false);
#if defined ZR
	if(VIPBuilding_Active())
		return true;
	
	float GameTime = GetGameTime();

	//FOR ANY WEAPON THAT NEEDS CUSTOM LOGIC WHEN YOURE HURT!!
	//It will just return the same damage if nothing is done.
	int Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(Victim_weapon))
	{
		if(!CheckInHud())
			OnTakeDamage_ProvokedAnger(Victim_weapon);

		damage = Player_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, Victim_weapon, damagePosition);
	}
	
	if(OnTakeDamage_ShieldLogic(victim, damagetype))
		return true;

	if(!CheckInHud())
		if(RaidbossIgnoreBuildingsLogic(1) && i_HealthBeforeSuit[victim] > 0)
			damage *= 3.0;	//when a raid is alive, make quantum armor 8x as bad at tanking.
	
	if(!CheckInHud())
	{
		// Reduce damage taken as new players in extreme difficulties
		if(Level[victim] >= 0 && Level[victim] <= 10 && Database_IsCached(victim))
		{
			int rank = Waves_GetLevel();
			if(rank < 5)
				rank = 5;
			if(rank > 100)
				rank = 100;
			if(rank > Level[victim])
			{
				// Up to 50 level difference for 50% res
				float reduce = (rank - Level[victim]) / 100.0;
				if(reduce > 0.5)
					reduce = 0.5;
				
				// Between 20-29 make it less of a spike between handicap and none
				if(Level[victim] > 5)
					reduce *= (9 - Level[victim]) * 0.1;

				damage *= (1.0 - reduce);
			}
		}
	}

	if(!CheckInHud())
	{
		if(i_CurrentEquippedPerk[victim] & PERK_TESLAR_MULE)
		{
			int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
			int flMaxHealth = SDKCall_GetMaxHealth(victim);
		
			if((damage > float(flMaxHealth / 20) || flHealth < flMaxHealth / 5 || damage > 25.0) && f_WidowsWineDebuffPlayerCooldown[victim] < GameTime) //either too much dmg, or your health is too low.
			{
				f_WidowsWineDebuffPlayerCooldown[victim] = GameTime + 20.0;
				
				float vecVictim[3]; WorldSpaceCenter(victim, vecVictim);
				
				ParticleEffectAt(vecVictim, "peejar_impact_cloud_milk", 0.5);
				
				EmitSoundToAll("weapons/jar_explode.wav", victim, SNDCHAN_AUTO, 80, _, 1.0);

				if(!(damagetype & DMG_TRUEDAMAGE))
					damage *= 0.25;
					
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
					if (IsValidEntity(baseboss_index))
					{
						if(!b_NpcHasDied[baseboss_index])
						{
							if (GetTeam(victim)!=GetTeam(baseboss_index)) 
							{
								float vecTarget[3]; WorldSpaceCenter(baseboss_index, vecTarget);
								
								float flDistanceToTarget = GetVectorDistance(vecVictim, vecTarget, true);
								if(flDistanceToTarget < 90000)
								{
									ParticleEffectAt(vecTarget, "peejar_impact_cloud_milk", 0.5);
									ApplyStatusEffect(victim, baseboss_index, "Teslar Mule", FL_WIDOWS_WINE_DURATION);
								}
							}
						}
					}
				}
			}
		}
	}
	
#if defined ZR || defined NOG
		//true damage does NOT Ignore this.
		VausMagicaShieldLogicNpcOnTakeDamage(attacker, victim, damage,damagetype, i_HexCustomDamageTypes[victim], weapon);
#endif
	OnTakeDamageResistanceBuffs(victim, attacker, inflictor, damage, damagetype, weapon);

	int vehicle = Vehicle_Driver(victim);

	if(i_HealthBeforeSuit[victim] == 0)
	{
		int armorEnt = victim;
		if(vehicle != -1)
			armorEnt = vehicle;
		
		if(CheckInHud())
		{
			if(vehicle != -1 && Armor_Charge[armorEnt] > 0)
			{
				damage *= ZR_ARMOR_DAMAGE_REDUCTION_INVRERTED;
			}
		}
		else
		{
			if(Armor_Charge[armorEnt] > 0)
			{
				int dmg_through_armour = RoundToCeil(damage * ZR_ARMOR_DAMAGE_REDUCTION_INVRERTED);
				switch(GetRandomInt(1,3))
				{
					case 1:
						EmitSoundToClient(victim, "physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, 60, _, 0.25, GetRandomInt(95,105));
					
					case 2:
						EmitSoundToClient(victim, "physics/metal/metal_box_impact_bullet2.wav", victim, SNDCHAN_STATIC, 60, _, 0.25, GetRandomInt(95,105));
					
					case 3:
						EmitSoundToClient(victim, "physics/metal/metal_box_impact_bullet3.wav", victim, SNDCHAN_STATIC, 60, _, 0.25, GetRandomInt(95,105));
				}						
				if(RoundToCeil(damage * ZR_ARMOR_DAMAGE_REDUCTION) >= Armor_Charge[armorEnt])
				{
					int damage_received_after_calc;
					damage_received_after_calc = RoundToCeil(damage) - Armor_Charge[armorEnt];
					Armor_Charge[armorEnt] = 0;
					damage = float(damage_received_after_calc);

					//armor is broken!
					if(f_Armor_BreakSoundDelay[victim] < GetGameTime())
					{
						f_Armor_BreakSoundDelay[victim] = GetGameTime() + 5.0;	
						if(IsValidEntity(Victim_weapon))
						{
							//Give riotshield speedbonus in shield break
							if(i_CustomWeaponEquipLogic[Victim_weapon] == WEAPON_RIOT_SHIELD)
							{
								TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 1.5);
							}
						}
						EmitSoundToClient(victim, "npc/assassin/ball_zap1.wav", victim, SNDCHAN_STATIC, 60, _, 1.0, GetRandomInt(95,105));
						//\sound\npc\assassin\ball_zap1.wav
					}
				}
				else
				{
					Armor_Charge[armorEnt] -= RoundToCeil(damage * ZR_ARMOR_DAMAGE_REDUCTION);
					damage = 0.0;
					damage += float(dmg_through_armour);
				}
			}
		}

		if(!(damagetype & DMG_TRUEDAMAGE))
		{
			float percentage = ArmorPlayerReduction(victim);
			damage *= percentage;
		}
	}

	if(vehicle != -1)
	{
		// Driver
		damage *= 0.5;

		if(!(damagetype & DMG_TRUEDAMAGE) && Vehicle_Driver(vehicle) != victim)
		{
			// Passenger
			damage *= 0.2;
		}
	}
#endif	// ZR
	
#if defined RPG
	if(!CheckInHud())
		Player_Ability_Warcry_OnTakeDamage(victim, damage);

	if(!(damagetype & DMG_TRUEDAMAGE) && TrueStength_ClientBuff(victim))
		damage *= 0.85;

	switch(BubbleProcStatusLogicCheck(victim))
	{
		case -1:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				damage *= 0.85;
		}
		
		case 1:
			damage *= 1.15;
	}

	if(WarCry_Enabled_Buff(victim) && !(damagetype & DMG_TRUEDAMAGE))
		damage *= WarCry_ResistanceBuff(victim);
	
	RPG_BobsPureRage(victim, attacker, damage);
	if(!CheckInHud())
		NPC_Ability_TrueStrength_OnTakeDamage(attacker, victim, weapon, damagetype, i_HexCustomDamageTypes[victim]);
#endif	// RPG

	return false;
}
#endif	// Non-RTS

stock bool Damage_NPCVictim(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	view_as<CClotBody>(victim).m_bGib = false;
	float GameTime = GetGameTime();
	
#if defined ZR

	if(Rogue_Mode() && GetTeam(victim) != TFTeam_Red)
	{
		if(!CheckInHud())
		{
			if(Rogue_GetChaosLevel() > 1)
			{
				damage *= GetRandomFloat(0.9, 1.1);
			}

			if(Rogue_GetChaosLevel() > 2 && !(GetURandomInt() % 49))
			{
				if(attacker <= MaxClients)
					DisplayCritAboveNpc(victim, attacker, true, damagePosition);
				
				damage *= 2.0;
			}
		}

		int scale = Waves_GetRoundScale();
		if(scale < 1)
		{
			damage *= 1.6667;
		}
	}
#endif
	if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS))
	{

#if !defined RTS
		if(NullfyDamageAndNegate(victim, attacker, inflictor, damage, damagetype, weapon,damagecustom))
			return true;
		
		if(OnTakeDamageAbsolutes(victim, attacker, inflictor, damage, damagetype, weapon, GameTime))
			return true;
		
		if(!(damagetype & DMG_NOCLOSEDISTANCEMOD))
		{
			damagetype |= DMG_NOCLOSEDISTANCEMOD; 
		}
		if(damagetype & DMG_USEDISTANCEMOD)
		{
			damagetype &= ~DMG_USEDISTANCEMOD;
		}
		//Decide Damage falloff ourselves.
#endif

#if defined RPG
		if(!CheckInHud())
		{
			if(OnTakeDamageRpgPartyLogic(victim, attacker, GetGameTime()))
				return true;
			
			if(inflictor > 0 && inflictor <= MaxClients)
			{
				f_InBattleDelay[inflictor] = GetGameTime() + 3.0;
				RPGCore_AddClientToHurtList(victim, inflictor);
			}
			else if(attacker > 0 && attacker <= MaxClients)
			{
				f_InBattleDelay[attacker] = GetGameTime() + 3.0;
				RPGCore_AddClientToHurtList(victim, attacker);
			}
		}
#endif

#if defined ZR || defined NOG || defined RPG
		OnTakeDamageNpcBaseArmorLogic(victim, attacker, damage, damagetype, _,weapon);
#endif
		
#if defined ZR || defined NOG
		//true damage does NOT Ignore this.
		VausMagicaShieldLogicNpcOnTakeDamage(attacker, victim, damage,damagetype, i_HexCustomDamageTypes[victim], weapon);
#endif

#if defined ZR
		if(!CheckInHud())
			OnTakeDamageWidowsWine(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);
		OnTakeDamage_RogueItemGeneric(attacker, damage, damagetype, inflictor);
#endif

		
#if !defined RTS
		OnTakeDamageDamageBuffs(attacker, inflictor, damage, damagetype, weapon);

#if defined RPG	
		if(!CheckInHud() && damagePosition[2] != 6969420.0)
		{
			//There is crit damage from this item.
			damage *= RPG_BobWetstoneTakeDamage(attacker, victim, damagePosition);
		}
#endif

		OnTakeDamageResistanceBuffs(victim, attacker, inflictor, damage, damagetype, weapon);
		
		if(!CheckInHud() && attacker <= MaxClients && attacker > 0)
			OnTakeDamagePlayerSpecific(victim, attacker, inflictor, damage, damagetype, weapon);
#endif

#if defined ZR	
		if(!CheckInHud())		
			OnTakeDamageScalingWaveDamage(victim, attacker, inflictor, damage, damagetype, weapon);
#endif

		if(attacker <= MaxClients && attacker > 0)
		{
			if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
			{
				if(!CheckInHud())
					DoClientHitmarker(attacker);

				if(IsValidEntity(weapon))
				{
					damage = NPC_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, i_HexCustomDamageTypes[victim]);

					if(!CheckInHud())
					{
#if defined ZR
						OnTakeDamage_HandOfElderMages(attacker, weapon);
						OsmosisElementalEffect_Detection(attacker, victim);
#endif

#if !defined RTS
						OnTakeDamageOldExtraWeapons(victim, attacker, weapon);
						OnTakeDamageBackstab(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);
#endif
					}
				}
			}
			
#if defined ZR
			if(TF2_IsPlayerInCondition(attacker, TFCond_NoHealingDamageBuff) || (damagetype & DMG_CRIT))
			{
				damage *= 1.35;
				if(!CheckInHud())
				{
					bool PlaySound = false;
					if(f_MinicritSoundDelay[attacker] < GetGameTime())
					{
						PlaySound = true;
						f_MinicritSoundDelay[attacker] = GetGameTime() + 0.25;
					}
					
					DisplayCritAboveNpc(victim, attacker, PlaySound,_,_,true); //Display crit above head
				}

				damagetype &= ~DMG_CRIT;
			}
#endif
		}
	}
	
#if defined RTS
	RTS_TakeDamage(victim, damage, damagetype);
#endif

#if defined RPG
	if(!CheckInHud())
	{
		NPC_Ability_TrueStrength_OnTakeDamage(attacker, victim, weapon, damagetype, i_HexCustomDamageTypes[victim]);
		RPG_ChaosSurgance(victim, attacker, weapon, damage);
	}
	RPG_BobsPureRage(victim, attacker, damage);

	//this should be last for npcs.
	if(!CheckInHud())
		RPG_FlatRes(victim, attacker, weapon, damage);
#endif
	
	NpcArmorExtra(victim, attacker, inflictor, damage, damagetype);
	if(!CheckInHud())
		NpcSpecificOnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	if(!CheckInHud())
	{
		//Do armor.
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS))
		{
			if(attacker <= MaxClients && attacker > 0)
			{
				if(IsValidEntity(weapon))
					NPC_OnTakeDamage_Equipped_Weapon_Logic_PostCalc(victim, attacker, inflictor, damage, damagetype, weapon);	
			}
#if defined ZR
			BarracksUnitAttack_NPCTakeDamagePost(victim, inflictor, damage, damagetype);
#endif
		}
		
	}

	return false;
}

void NpcArmorExtra(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	CClotBody npc = view_as<CClotBody>(victim);
	if(npc.m_flArmorCount > 0.0)
	{
		if(!CheckInHud())
		{
			if(damagetype & DMG_CLUB)
			{
				npc.m_flArmorCount -= ((damage * ((npc.m_flArmorProtect - 1.0) * -1.0)) * 1.35);
				//armored enemies get more damage.
				int DisplayCritSoundTo;
				if(attacker <= MaxClients)
					DisplayCritSoundTo = attacker;
				else if(inflictor <= MaxClients)
					DisplayCritSoundTo = inflictor;
					
				if(DisplayCritSoundTo > 0 && DisplayCritSoundTo <= MaxClients)
				{
					bool PlaySound = false;
					if(f_MinicritSoundDelay[DisplayCritSoundTo] < GetGameTime())
					{
						PlaySound = true;
						f_MinicritSoundDelay[DisplayCritSoundTo] = GetGameTime() + 0.25;
					}
					
					DisplayCritAboveNpc(victim, DisplayCritSoundTo, PlaySound,_,_,true); //Display crit above head
				}

			}
			else
			{
				npc.m_flArmorCount -= (damage * ((npc.m_flArmorProtect - 1.0) * -1.0));
			}
		}
		damage *= npc.m_flArmorProtect; //negate damage
		if(!CheckInHud())
		{
			if(npc.m_iArmorType == 0)
				npc.PlayHurtArmorSound();

			if(npc.m_flArmorCount <= 0.0) //over damage, add as damage.
			{
				//let melee be really good against armor and stuff to reward them.
				damage -= npc.m_flArmorCount;
			}
		}
	}
}

stock bool Damage_BuildingVictim(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
#if defined ZR || defined RPG
	OnTakeDamageResistanceBuffs(victim, attacker, inflictor, damage, damagetype, weapon);
#endif

	if(b_ThisEntityIgnored[victim])
	{
		//True damage ignores this.
		if(!(damagetype & (DMG_TRUEDAMAGE)))
		{
			damage = 0.0;
			return true;
		}
	}
	OnTakeDamageNpcBaseArmorLogic(victim, attacker, damage, damagetype, _,weapon);
	return false;
}

stock bool Damage_AnyAttacker(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	float basedamage = damage;
	
#if defined ZR
	float DamageBuffExtraScaling = 1.0;

	if(attacker <= MaxClients || inflictor <= MaxClients)
	{
		//only scale if its a player, and if the attacking npc is red too
		if(GetTeam(attacker) == TFTeam_Red || GetTeam(inflictor) == TFTeam_Red)
			DamageBuffExtraScaling = PlayerCountBuffScaling;
	}
#endif

#if defined ZR
	if(MoraleBoostLevelAt(attacker) > 0)
		damage += basedamage * (EntityMoraleBoostReturn(attacker, 2) * DamageBuffExtraScaling);
#endif

	//This buffs up damage in anyway possible
#if defined ZR
	if(CheckInHud() != 2)
		damage += StatusEffect_OnTakeDamage_TakenNegative(victim, attacker, inflictor, basedamage, damagetype);
#else
	if(CheckInHud() != 2)
		damage += StatusEffect_OnTakeDamage_TakenNegative(victim, attacker, basedamage, damagetype);
#endif


#if defined ZR
	damage += StatusEffect_OnTakeDamage_DealPositive(victim, attacker,inflictor, basedamage, damagetype);
#else
	damage += StatusEffect_OnTakeDamage_DealPositive(victim, attacker, basedamage, damagetype);
#endif

#if defined ZR
	//Medieval buff stacks with any other attack buff.
	if(GetTeam(attacker) != TFTeam_Red && GetTeam(victim) == TFTeam_Red && Medival_Difficulty_Level != 0.0 && !NpcStats_IsEnemySilenced(attacker))
	{
		if(!CheckInHud() || CheckInHud() == 2)
			damage *= 2.0 - Medival_Difficulty_Level; //More damage !! only upto double.
	}
#endif
	return false;
}

#if !defined RTS
stock bool Damage_PlayerAttacker(int &attacker, float &damage, int &damagetype, int &weapon)
{
#if defined ZR
	//cant be 0
	if(attacker > 0 && Rogue_InItallianWrath(weapon))
		damage *= 2.0;
	
	if(!CheckInHud())
	{
		// Increase damage dealt as new players in extreme difficulties
		if(Level[attacker] < 29 && Database_IsCached(attacker))
		{
			int rank = Waves_GetLevel();
			if(rank > Level[attacker])
			{
				// Up to 50 level difference for 50% damage
				float increase = (rank - Level[attacker]) / 100.0;
				if(increase > 0.5)
					increase = 0.5;
				
				// Between 20-29 make it less of a spike between handicap and none
				if(Level[attacker] > 19)
					increase *= (29 - Level[attacker]) * 0.1;

				damage *= 1.0 + increase;
			}
		}
	}
#endif
	if(!CheckInHud())
		HudDamageIndicator(attacker,damagetype, true);
		
	return false;
}
#endif

stock bool Damage_NPCAttacker(int &attacker,float &damage, int &damagetype)
{
#if defined ZR
	if(!(damagetype & (DMG_CLUB|DMG_TRUEDAMAGE))) //if its not melee damage
	{
		if(i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER)
		{
			damage *= 1.25;
		}
	}
#endif	//zr
	return false;
}

stock bool Damage_BuildingAttacker(int &attacker, float &damage)
{
	if(b_thisNpcIsABoss[attacker])
	{
		damage *= 1.25;
	}
	return false;
}

#if defined ZR
static float Player_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3])
{
	switch(i_CustomWeaponEquipLogic[equipped_weapon])
	{
		case WEAPON_ARK: // weapon_ark
		{
			return Player_OnTakeDamage_Ark(victim, damage, attacker, equipped_weapon, damagePosition, damagetype);
		}
		case WEAPON_NEARL, WEAPON_FUSION_PAP2:
		{
			if(!CheckInHud())
				return Player_OnTakeDamage_Fusion(victim, damage, attacker, equipped_weapon, damagePosition, damagetype);
		}
		case WEAPON_EXPLORER:
		{
			return Player_OnTakeDamage_VoidBlade(victim, damage, attacker, equipped_weapon, damagePosition, damagetype);
		}
		case WEAPON_RIOT_SHIELD:
		{
			return Player_OnTakeDamage_Riot_Shield(victim, damage, attacker, equipped_weapon, damagePosition, damagetype);
		}
		case WEAPON_MLYNAR: // weapon_ark
		{
			if(!CheckInHud())
				Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon);
		}
		case WEAPON_MLYNAR_PAP: // weapon_ark
		{
			if(!CheckInHud())
				Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon, 1);
		}
		case WEAPON_MLYNAR_PAP_2: // weapon_ark
		{
			if(!CheckInHud())
				Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon, 2);
		}
		case WEAPON_OCEAN, WEAPON_OCEAN_PAP, WEAPON_SPECTER, WEAPON_ULPIANUS, WEAPON_SKADI:
		{
			if(!CheckInHud() && i_CustomWeaponEquipLogic[equipped_weapon] == WEAPON_ULPIANUS)
				Ulpianus_OnTakeDamageSelf(victim);
				
			if(!CheckInHud() && i_CustomWeaponEquipLogic[equipped_weapon] == WEAPON_SKADI)
				WeaponSkadi_OnTakeDamage(attacker, victim, damage, damagetype);
			
			return Gladiia_OnTakeDamageAlly(victim, attacker, damage, damagetype);
		}
		case WEAPON_GLADIIA:
		{
			return Gladiia_OnTakeDamageSelf(victim, attacker, damage, damagetype);
		}
		case WEAPON_BLEMISHINE:
		{
			return Player_OnTakeDamage_Blemishine(victim, attacker, damage, damagetype);
		}
		case WEAPON_BOARD:
		{
			return Player_OnTakeDamage_Board(victim, damage, attacker, equipped_weapon, damagePosition, damagetype);
		}
		case WEAPON_LEPER_MELEE_PAP, WEAPON_LEPER_MELEE:
		{
			return WeaponLeper_OnTakeDamagePlayer(victim, damage, attacker, equipped_weapon, damagePosition, damagetype);
		}
		case WEAPON_FLAGELLANT_MELEE, WEAPON_FLAGELLANT_HEAL:
		{
			if(!CheckInHud())
				Flagellant_OnTakeDamage(victim);
		}
		case WEAPON_RAPIER:
		{
			//uhhh idk
			if(!(damagetype & DMG_TRUEDAMAGE))
				Player_OnTakeDamage_Rapier(victim, attacker, damage);
		}
		case WEAPON_RED_BLADE:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				WeaponRedBlade_OnTakeDamage(attacker, victim, damage);
		}
		/*
		case WEAPON_HEAVY_PARTICLE_RIFLE:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				if(!CheckInHud())
					return Player_OnTakeDamage_Heavy_Particle_Rifle(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		*/
		case WEAPON_MERCHANT:
		{
			if(!CheckInHud())
				Merchant_SelfTakeDamage(victim, attacker, damage);
		}
		case WEAPON_FLAMETAIL:
		{
			if(!CheckInHud())
				Flametail_SelfTakeDamage(victim, damage, damagetype, equipped_weapon);
		}
		case WEAPON_WRATHFUL_BLADE:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				Player_OnTakeDamage_WrathfulBlade(victim, damage);
		}	
		case WEAPON_MAGNESIS:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				if(!CheckInHud())
					Player_OnTakeDamage_Magnesis(victim, damage, attacker);
		}
		case WEAPON_YAKUZA:
		{
			Yakuza_SelfTakeDamage(victim, attacker, damage, damagetype, equipped_weapon);
		}
		case WEAPON_FULLMOON:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				FullMoon_SanctuaryApplyBuffs(victim, damage);
		}
		case WEAPON_CASTLEBREAKER:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				WeaponCastleBreaker_OnTakeDamage(victim, damage);
		}
		case WEAPON_ZEALOT_MELEE, WEAPON_ZEALOT_GUN, WEAPON_ZEALOT_POTION:
		{
			if(!CheckInHud())
				return Player_OnTakeDamage_Zealot(victim, damage, attacker, equipped_weapon, damagePosition, damagetype);
		}
		case WEAPON_KIT_FRACTAL:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				return Player_OnTakeDamage_Fractal(victim, damage, damagePosition,attacker);
		}
	}
	return damage;
}

#endif	// ZR

static stock bool NullfyDamageAndNegate(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int damagecustom)
{
#if defined ZR
	if(damagecustom>=TF_CUSTOM_SPELL_TELEPORT && damagecustom<=TF_CUSTOM_SPELL_BATS)
		return true;

	switch (damagecustom) //Make sure taunts dont do any damage, cus op as fuck	
	{
		case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
		TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
		TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
		{
			return true;
		}
	}
	//should not steal.

	if(Saga_EnemyDoomed(victim) && attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE)
	{
		if(Saga_IsChargeWeapon(attacker, weapon))
		{
			return true;
		}
	}
#endif

	return false;
}

static bool OnTakeDamageAbsolutes(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{
	//we list off all on hit things that are neccecary, or absolute damage resistances that apply no matter what.
	if(!CheckInHud())
	{
		f_TimeUntillNormalHeal[victim] = GameTime + 4.0;
		i_HasBeenBackstabbed[victim] = false;
		if(f_TraceAttackWasTriggeredSameFrame[victim] != GameTime)
		{
			i_HasBeenHeadShotted[victim] = false;
		}
		
	}
		
#if defined ZR
	if(!CheckInHud())
	{
		if(GetTeam(victim) == TFTeam_Red)
		{
			if(f_FreeplayDamageExtra != 1.0 && !b_thisNpcIsARaid[attacker])
			{
				damage *= f_FreeplayDamageExtra;
			}
			if(OnTakeDamage_ShieldLogic(victim, damagetype))
			{
				return true;
			}
		}
	}
#endif
	return false;
}

static stock float NPC_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
#if defined ZR
	//did we hit any headshot ?
	if(!CheckInHud() && b_MeleeCanHeadshot[weapon])
	{
		static int DummyAmmotype = 0; //useless but needed
		NPC_TraceAttack(victim, attacker, inflictor, damage, damagetype, DummyAmmotype, 0, i_MeleeHitboxHit[attacker]);
	}
	
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_BOUNCING:
		{
			if(!CheckInHud())
				return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_MAIMMOAB:
		{
			if(!CheckInHud())
				return SniperMonkey_MaimMoab(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_CRIPPLEMOAB:
		{
			if(!CheckInHud())
				return SniperMonkey_CrippleMoab(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_IRENE:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_Iberia(attacker, damagetype);
		}
		case 7://WEAPON_PHLOG:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_Phlog(attacker);
		}
		case WEAPON_NEARL: //pap fusion
		{
			if(!CheckInHud())
				return Npc_OnTakeDamage_PaP_Fusion(attacker, victim, damage, weapon);
		}
		case WEAPON_LAPPLAND: //pap ark alt
		{
			if(!CheckInHud())
				return Npc_OnTakeDamage_LappLand(damage, attacker, damagetype, inflictor, victim);
		}
		case WEAPON_QUIBAI: //pap ark alt
		{
			if(!CheckInHud())
				return Npc_OnTakeDamage_Quibai(damage, attacker, damagetype, inflictor, victim, weapon);
		}
		case WEAPON_SPECTER:
		{
			if(!CheckInHud())
				Specter_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon);
		}
		case WEAPON_YAMATO:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_Yamato(attacker, damagetype);
		}
		case WEAPON_BEAM_PAP:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_BeamWand_Pap(attacker, damagetype);
		}
		case WEAPON_GLADIIA:
		{
			if(!CheckInHud())
				Gladiia_OnTakeDamageEnemy(victim, attacker, damage);
		}
		case WEAPON_BLEMISHINE:
		{
			if(!CheckInHud())
				NPC_OnTakeDamage_Blemishine(attacker, victim, damage,weapon);
		}
		case WEAPON_HAZARD, WEAPON_HAZARD_UNSTABLE, WEAPON_HAZARD_LUNATIC, WEAPON_HAZARD_CHAOS, WEAPON_HAZARD_STABILIZED, WEAPON_HAZARD_DEMI, WEAPON_HAZARD_PERFECT:
		{
			if(!CheckInHud())
				NPC_OnTakeDamage_Hazard(attacker, victim, damage,weapon);
		}
		case WEAPON_CASINO:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_Casino(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_FANTASY_BLADE:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_Fantasy_Blade(attacker, damagetype);
		}
		case WEAPON_CHAINSAW:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_Chainsaw(attacker, damagetype);
		}
		case WEAPON_SPEEDFISTS:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_SpeedFists(attacker,victim, damage);
		}
		case WEAPON_BOOMSTICK:
		{
			if(b_thisNpcIsARaid[victim])
			{
				damage *= 1.1; //due to how dangerous it is to get closer.
			}
		}
		case WEAPON_VAMPKNIVES_1:
		{
			if(!CheckInHud())
				Vamp_ApplyBloodlust(attacker, victim, 1, false, false);
		}
		case WEAPON_VAMPKNIVES_2:
		{
			if(!CheckInHud())
				Vamp_ApplyBloodlust(attacker, victim, 2, false, false);
		}
		case WEAPON_VAMPKNIVES_2_CLEAVER:
		{
			if(!CheckInHud())
				Vamp_ApplyBloodlust(attacker, victim, 2, true, false);
		}
		case WEAPON_VAMPKNIVES_3:
		{
			if(!CheckInHud())
				Vamp_ApplyBloodlust(attacker, victim, 3, false, false);
		}
		case WEAPON_VAMPKNIVES_3_CLEAVER:
		{
			if(!CheckInHud())
				Vamp_ApplyBloodlust(attacker, victim, 3, true, false);
		}
		case WEAPON_VAMPKNIVES_4:
		{
			if(!CheckInHud())
				Vamp_ApplyBloodlust(attacker, victim, 4, false, false);
		}
		case WEAPON_VAMPKNIVES_4_CLEAVER:
		{
			if(!CheckInHud())
				Vamp_ApplyBloodlust(attacker, victim, 4, true, false);
		}
		case WEAPON_SENSAL_SCYTHE, WEAPON_SENSAL_SCYTHE_PAP_1, WEAPON_SENSAL_SCYTHE_PAP_2, WEAPON_SENSAL_SCYTHE_PAP_3:
		{
			if(!CheckInHud())
				WeaponSensal_Scythe_OnTakeDamage(attacker, victim,weapon, zr_custom_damage);
		}
		case WEAPON_EXPLORER:
		{
			if(!CheckInHud())
				WeaponVoidBlade_OnTakeDamage(attacker, victim, zr_custom_damage);
		}
		case WEAPON_LEPER_MELEE_PAP, WEAPON_LEPER_MELEE:
		{
			if(!CheckInHud())
				WeaponLeper_OnTakeDamage(attacker, damage,weapon, zr_custom_damage);
		}
		case WEAPON_URANIUM_RIFLE:
		{
			WeaponUranium_OnTakeDamage(attacker,victim, damage, damagePosition);
		}
		case WEAPON_TEXAN_BUISNESS:
		{
			if(!CheckInHud())
				Weapon_TexanBuisness(attacker, damage, damagetype);
		}
		case WEAPON_ANGELIC_SHOTGUN:
		{
			if(!CheckInHud())
				Weapon_AngelicShotgun(attacker, damage, damagetype);
		}
		case WEAPON_RAPIER:
		{
			if(!CheckInHud())
				NPC_OnTakeDamage_Rapier(attacker, victim, damage, weapon);
		}
		case WEAPON_GRAVATON_WAND:
		{
			if(!CheckInHud())
				NPC_OnTakeDmg_Gravaton_Wand(attacker, damagetype);
		}
		case WEAPON_RED_BLADE:
		{
			WeaponRedBlade_OnTakeDamageNpc(attacker,victim, damagetype,weapon, damage);
		}
		case WEAPON_SICCERINO, WEAPON_WALDCH_SWORD_NOVISUAL, WEAPON_WALDCH_SWORD_REAL:
		{
			return Npc_OnTakeDamage_Siccerino(attacker, victim, damage, weapon, damagetype);
		}
		case WEAPON_DIMENSION_RIPPER:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_DimensionalRipper(attacker);
		}	
		case WEAPON_OBUCH:
		{
			if(!CheckInHud())
				Npc_OnTakeDamage_ObuchHammer(attacker, weapon);
		}
		case WEAPON_MERCHANT:
		{
			if(!CheckInHud())
				Merchant_NPCTakeDamage(victim, attacker, damage, weapon);
		}
		case WEAPON_MERCHANTGUN:
		{
			if(!CheckInHud())
				Merchant_GunTakeDamage(victim, attacker, damage);
		}
		case WEAPON_RUSTY_RIFLE:
		{
			if(!CheckInHud())
				return Rusty_OnNPCDamaged(victim, attacker, damage);
		}
		case WEAPON_FLAMETAIL:
		{
			if(!CheckInHud())
				Flametail_NPCTakeDamage(attacker, damage, weapon, damagePosition);
		}
		case WEAPON_MAGNESIS:
		{
			if(!CheckInHud())
				Magnesis_OnNPCDamaged(victim, damage);
		}
		case WEAPON_WRATHFUL_BLADE:
		{
			if(!CheckInHud())
				return WrathfulBlade_OnNPCDamaged(victim, attacker, weapon, damage, inflictor);
		}
		case WEAPON_SUPERUBERSAW:
		{
			if(!CheckInHud())
				Superubersaw_OnTakeDamage(victim, attacker, damage, weapon);
		}
		case WEAPON_YAKUZA:
		{
			if(!CheckInHud())
				Yakuza_NPCTakeDamage(victim, attacker, damage, weapon);
		}
		case WEAPON_SKADI:
		{
			if(!CheckInHud())
				WeaponSkadi_OnTakeDamageNpc(attacker,damage);
		}
		case WEAPON_WALTER:
		{
			if(!CheckInHud())
				Walter_NPCTakeDamage(victim, attacker, damage, weapon);
		}
		case WEAPON_CASTLEBREAKER:
		{
			if(!CheckInHud())
				WeaponCastleBreaker_OnTakeDamageNpc(attacker, victim, damage, weapon, damagetype);
		}
		case WEAPON_ZEALOT_MELEE:
		{
			if(!CheckInHud())
				WeaponZealot_OnTakeDamage(attacker, victim, damage);
		}
		case WEAPON_ZEALOT_GUN:
		{
			if(!CheckInHud())
				WeaponZealot_OnTakeDamage_Gun(attacker, victim, damage);
		}
		case WEAPON_KIT_PROTOTYPE_MELEE:
		{
			if(!CheckInHud())
				Wkit_Soldin_NPCTakeDamage_Melee(attacker, victim, damage, weapon, damagetype);
		}
		case WEAPON_KIT_PROTOTYPE:
		{
			Wkit_Soldin_NPCTakeDamage_Ranged(attacker, victim, damage, weapon, damagetype);
		}
		case WEAPON_CHEESY_MELEE:
		{
			if(!CheckInHud())
				Cheese_OnTakeDamage_Melee(attacker, victim, damage, damagetype, weapon);
		}
		case WEAPON_CHEESY_PRIMARY:
		{
			if(!CheckInHud())
				Cheese_OnTakeDamage_Primary(attacker, victim, damage, weapon);
		}
		case WEAPON_CHEMICAL_THROWER:
		{
			if(!CheckInHud())
				ChemicalThrower_NPCTakeDamage(attacker, victim, damage);
		}
		case WEAPON_SHERRIF, WEAPON_SHERRIF_LEVERACTION:
		{
			if(!CheckInHud())
				SherrifRevolver_NPCTakeDamage(attacker, victim, damage,weapon, i_CustomWeaponEquipLogic[weapon]);
		}
	}
#endif

#if defined RPG
	if(!CheckInHud())
	{
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_BIGFRYINGPAN:
			{
				if(b_thisNpcIsABoss[victim])
					Custom_Knockback(attacker, victim, 330.0);
				else
					Custom_Knockback(attacker, victim, 1000.0);
			}
		}
	}
#endif

	return damage;
}

static stock void NPC_OnTakeDamage_Equipped_Weapon_Logic_PostCalc(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
#if defined ZR
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_SAGA:
		{
			Saga_OnTakeDamage(victim, attacker, damage, weapon, damagetype);
		}
		case WEAPON_MERCHANT:
		{
			Merchant_NPCTakeDamagePost(attacker, damage, weapon);
		}
		case WEAPON_EXPLORER:
		{
			WeaponVoidBlade_OnTakeDamagePost(attacker, victim, damage);
		}
	}

	BlacksmithBrew_NPCTakeDamagePost(victim, attacker, damage);
	BlacksmithGrill_NPCTakeDamagePost(victim, attacker, damage);
#endif
}

#if defined RPG
stock bool OnTakeDamageRpgPartyLogic(int victim, int attacker, float GameTime, bool donotset = false)
{
	if(attacker == -1)
		return false;
	
	if(attacker > MaxClients && victim <= MaxClients)
	{
		int PrevAttack = attacker;
		int PrevVictim = victim;
		attacker = PrevVictim;
		victim = PrevAttack;
		//an npc is attacking a player, invert.
	}

	/*
		The npc is in a dungeon
		The attacker is not an npc
		The enemy is in a debug level state
	*/
	if(b_NpcIsInADungeon[victim] || attacker > MaxClients || b_NpcHasDied[victim] || Level[victim] > 1000000)
	{
		return false;	
	}

	if(RPGCore_ClientAllowedToTargetNpc(victim, attacker))
	{
		if(!donotset)
		{
			i_NpcFightOwner[victim] = attacker;
			f_NpcFightTime[victim] = GameTime + 10.0;

		}
	}
	else
	{
		return true;
	}
	
	return false;
}

static stock void OnTakeDamageRpgDungeonLogic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, float GameTime)
{
	if(!b_NpcIsInADungeon[victim] && Level[victim] < 100000)
	{
		// Reduces damage when fighting enemies higher level than you
		int underLv = Level[victim] - Level[attacker];
		if(underLv > 3)
		{
			damage /= Pow(float(underLv - 2), 0.5);
		}
	}
}

static stock void OnTakeDamageRpgAgressionOnHit(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, float GameTime)
{
	if(GetTeam(attacker)!=GetTeam(victim))
	{
		CClotBody npcBase = view_as<CClotBody>(victim);
		npcBase.m_flGetClosestTargetNoResetTime = GetGameTime(npcBase.index) + 5.0; //make them angry for 5 seconds if they are too far away.
		
		if(npcBase.m_iTarget == -1) //Only set it if they actaully have no target.
		{
			npcBase.m_iTarget = attacker;
		}
	}
}
#endif

stock void OnTakeDamageNpcBaseArmorLogic(int victim, int &attacker, float &damage, int &damagetype, bool trueArmorOnly = false, int weapon = 0)
{
	if((damagetype & DMG_CLUB)) //Needs to be here because it already gets it from the top.
	{
		if(!trueArmorOnly)
		{
			float TotalMeleeRes = 1.0;
#if defined ZR
			if(Medival_Difficulty_Level != 0.0 && GetTeam(victim) != TFTeam_Red)
			{
				TotalMeleeRes *= Medival_Difficulty_Level;
			}
#endif
			TotalMeleeRes *= fl_MeleeArmor[victim];
			TotalMeleeRes *= fl_Extra_MeleeArmor[victim];	
#if defined ZR
			if(IsValidEntity(weapon))
			{
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_TEUTON_DEAD)
				{
					if(TotalMeleeRes > 1.0)
					{
						TotalMeleeRes = 1.0;
					}
				}
			}
#endif
			damage *= TotalMeleeRes;
		}
		damage *= fl_TotalArmor[victim];
	}
	else if(!(damagetype & DMG_TRUEDAMAGE))
	{
		if(!trueArmorOnly)
		{
			float TotalMeleeRes = 1.0;
#if defined ZR
			if(!b_NpcHasDied[attacker] && (i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER))
			{
				TotalMeleeRes *= 1.25;
			}
			if(Medival_Difficulty_Level != 0.0 && GetTeam(victim) != TFTeam_Red)
			{
				TotalMeleeRes *= Medival_Difficulty_Level;
			}
#endif
			TotalMeleeRes *= fl_RangedArmor[victim];
			TotalMeleeRes *= fl_Extra_RangedArmor[victim];

			damage *= TotalMeleeRes;
		}
		damage *= fl_TotalArmor[victim];
	}
	else if((damagetype & DMG_TRUEDAMAGE))
	{
		if(!trueArmorOnly)
		{
#if defined ZR
			if(!b_NpcHasDied[attacker] && (i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER))
			{
				damage *= 1.25;
			}
#endif
			//we will treat these as if it was just one.
			float TotalRangedRes = fl_TotalArmor[victim] * fl_RangedArmor[victim] * fl_Extra_RangedArmor[victim];
			float TotalMeleeRes = fl_TotalArmor[victim] * fl_MeleeArmor[victim] * fl_Extra_MeleeArmor[victim];

			//for truedamage, only take in the weakest.
			if(TotalRangedRes >= 1.0 || TotalMeleeRes >= 1.0)
			{
				if(TotalRangedRes >= TotalMeleeRes)
				{
					damage *= TotalRangedRes;
				}
				else
				{
					damage *= TotalMeleeRes;
				}
				//any is bigger.
			}
		}
		else
		{
			//idk jsut multi fuck it.
			if(fl_TotalArmor[victim] > 1.0)
				damage *= fl_TotalArmor[victim];
		}
	}
	if(!trueArmorOnly)
	{
		//this only affects NPCS!!!
		damage *= fl_Extra_Damage[attacker];
	}
}

#if defined ZR
static stock void OnTakeDamageWidowsWine(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{
	if((i_CurrentEquippedPerk[victim] & PERK_TESLAR_MULE))
	{
		if(f_WidowsWineDebuffPlayerCooldown[victim] < GameTime) //either too much dmg, or your health is too low.
		{
			f_WidowsWineDebuffPlayerCooldown[victim] = GameTime + 20.0;
				
			float vecVictim[3]; WorldSpaceCenter(victim,vecVictim);
				
			ParticleEffectAt(vecVictim, "peejar_impact_cloud_milk", 0.5);
				
			EmitSoundToAll("weapons/jar_explode.wav", victim, SNDCHAN_AUTO, 60, _, 1.0);

			if(!(damagetype & DMG_TRUEDAMAGE))
				damage *= 0.5;

			ApplyStatusEffect(attacker, attacker, "Teslar Mule", FL_WIDOWS_WINE_DURATION_NPC);
		}
	}
}

float ExtraDamageWaveScaling()
{
	return (CurrentCash * 0.001);
}
stock bool OnTakeDamageScalingWaveDamage(int &victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{	
	float ExtraDamageDealt;

	ExtraDamageDealt = ExtraDamageWaveScaling(); //at wave 60, this will equal to 60* dmg
	if(ExtraDamageDealt <= 0.35)
	{
		ExtraDamageDealt = 0.35;
	}
	if(LastMann && GetTeam(victim) != TFTeam_Red)
	{
		damage *= 1.35;
		int DisplayCritSoundTo;
		if(attacker <= MaxClients)
			DisplayCritSoundTo = attacker;
		else if(inflictor <= MaxClients)
			DisplayCritSoundTo = inflictor;

		if(DisplayCritSoundTo > 0 && DisplayCritSoundTo <= MaxClients)
		{
			bool PlaySound = false;
			if(f_MinicritSoundDelay[DisplayCritSoundTo] < GetGameTime())
			{
				PlaySound = true;
				f_MinicritSoundDelay[DisplayCritSoundTo] = GetGameTime() + 0.25;
			}
			
			DisplayCritAboveNpc(victim, DisplayCritSoundTo, PlaySound,_,_,true); //Display crit above head
		}
	}
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_TEUTON_DEAD)
		{
			ExtraDamageDealt *= 0.5;
			damage *= ExtraDamageDealt;
		}
	}
	if(IsValidEntity(inflictor))
	{
		if(GetTeam(inflictor) == TFTeam_Red) 
		{
			CClotBody npc = view_as<CClotBody>(inflictor);
			if(npc.m_bScalesWithWaves)
			{
				damage *= ExtraDamageDealt;
			}
		}
	}
	return false;
}
#endif

#if !defined RTS
static stock bool OnTakeDamageOldExtraWeapons(int victim, int &attacker, int &weapon)
{	
	if(!IsValidEntity(weapon))
		return false;

#if defined ZR
	if(i_HighTeslarStaff[weapon] == 1)
	{
		ApplyStatusEffect(attacker, victim, "Teslar Electricution", 5.0);
	}
	else if(i_LowTeslarStaff[weapon] == 1)
	{
		ApplyStatusEffect(attacker, victim, "Teslar Shock", 5.0);
	}
#endif
	return false;
}

static stock bool OnTakeDamageBackstab(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{
	if(i_ExplosiveProjectileHexArray[weapon] & EP_GIBS_REGARDLESS) //Block explosives ?
		return false;

	if(f_BackstabDmgMulti[weapon] != 0.0 && !b_CannotBeBackstabbed[victim]) //Irene weapon cannot backstab.
	{
		if(damagetype & DMG_CLUB && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)) //Use dmg slash for any npc that shouldnt be scaled.
		{

#if defined ZR
			if(IsBehindAndFacingTarget(attacker, victim, weapon) || b_FaceStabber[attacker] || i_NpcIsABuilding[victim])
#else
			if(IsBehindAndFacingTarget(attacker, victim, weapon) || i_NpcIsABuilding[victim])
#endif

			{
				int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				int melee = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
				if(melee != 4 && melee != 1003 && viewmodel>MaxClients && IsValidEntity(viewmodel))
				{
#if defined ZR
					if((b_FaceStabber[attacker] && b_FaceStabber[victim]))
					{
						PrintToChat(attacker, "You think you can circumvent this challange?! Shame on you!");
						damage = 0.0;
						return false;
					}
#endif
					i_HasBeenBackstabbed[victim] = true;
						
					float attack_speed;

					attack_speed = 1.0;
					
					attack_speed *= Attributes_Get(weapon, 6, 1.0);
					attack_speed *= Attributes_Get(weapon, 396, 1.0); //Extra
						
					EmitSoundToAll("weapons/knife_swing_crit.wav", attacker, _, _, _, 0.7);
						
					DataPack pack = new DataPack();
					RequestFrame(DoMeleeAnimationFrameLater, pack);
					pack.WriteCell(EntIndexToEntRef(viewmodel));
					pack.WriteCell(melee);

					attack_speed *= f_BackstabCooldown[weapon]; //extra delay.

					damage *= 5.25;

#if defined ZR
					CClotBody npc = view_as<CClotBody>(victim);

					if(b_FaceStabber[attacker] || i_NpcIsABuilding[victim] || IsEntityTowerDefense(victim))
						damage *= 0.40; //extra delay.
#endif
					
					bool IsTargeter = false;
#if defined ZR
					if(attacker == npc.m_iTarget)
					{
						IsTargeter = true;
					}
#endif

					if(f_BackstabBossDmgPenalty[weapon] != 1.0)
					{
						bool DoPenalty = false;
						if(b_thisNpcIsABoss[victim] || b_thisNpcIsARaid[victim])
						{
							DoPenalty = true;
						}
						if(i_NpcIsABuilding[victim])
						{
							DoPenalty = false;
						}
						if(DoPenalty)
						{
							if(f_BackstabBossDmgPenaltyNpcTime[victim][attacker] > GetGameTime())
							{
								damage *= f_BackstabBossDmgPenalty[weapon];
							}
							f_BackstabBossDmgPenaltyNpcTime[victim][attacker] = GetGameTime() + 2.0;	
						}
					}

					damage *= f_BackstabDmgMulti[weapon];		
#if defined ZR
					if(i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER) //Deadshot!
					{
						damage *= 1.25;
					}	
#endif					
					if(!(GetClientButtons(attacker) & IN_DUCK)) //This shit only works sometimes, i blame tf2 for this.
					{
						Animation_Retry[attacker] = 4;
						RequestFrame(Try_Backstab_Anim_Again, EntIndexToEntRef(attacker));
						TE_Start("PlayerAnimEvent");
						Animation_Setting[attacker] = 1;
						Animation_Index[attacker] = 33;
						TE_WriteEnt("m_hPlayer",attacker);
						TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
						TE_WriteNum("m_nData", Animation_Index[attacker]);
						TE_SendToAll();
					}
#if defined ZR
					if(b_FaceStabber[attacker])
					{
						if(b_thisNpcIsARaid[victim])
						{
							damage *= 1.35;
						}
					}
					else
#endif
					{
						if(IsTargeter) //give more dmg if youre targetted
							damage *= 2.0;

						if(b_thisNpcIsARaid[victim])
						{
							if(IsTargeter) //give more dmg if youre targetted
							{
								damage *= 2.0;
							}
							else //Give less dmg if they arent focusing you, not as risky.
							{
								damage *= 1.35;
							}
						}
					}

					BackstabNpcInternalModifExtra(weapon, attacker, victim, 1.0);
					if(f_BackstabCooldown[weapon] != 0.0)
					{
						SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GameTime+(attack_speed));
						SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GameTime+(attack_speed));
					}

#if defined ZR
					if(b_BackstabLaugh[weapon])
					{
						if(i_CustomWeaponEquipLogic[weapon] == WEAPON_X10KNIFE)
						{
							SepcialBackstabLaughSpy(attacker);
						}
					}
					if(!b_FaceStabber[attacker] && !i_NpcIsABuilding[victim] && i_CustomWeaponEquipLogic[weapon] == WEAPON_RUINA_DRONE_KNIFE)
					{
						//See inside wind staff.
						RuinaNukeBackstabDo(victim, attacker, weapon);
					}
#endif
				}
			}
		}
	}
	else if(b_IsABow[weapon])
	{
		//arrows ignore inflictor?
#if defined ZR
		//f_InBattleHudDisableDelay[attacker] = GetGameTime() + f_Data_InBattleHudDisableDelay[attacker] + 2.0;
#endif
		f_InBattleDelay[attacker] = GetGameTime() + 3.0;
		if(damagetype & DMG_CRIT)
		{		
			damage *= f_HeadshotDamageMultiNpc[victim];
			damage *= 1.35;
			DisplayCritAboveNpc(victim, attacker, true); //Display crit above head
			damagetype &= ~DMG_CRIT;
#if defined ZR
			if(i_HeadshotAffinity[attacker] == 1)
			{
				damage *= 1.35;
			}
			if(i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER) //Just give them 25% more damage if they do crits with the huntsman, includes buffbanner i guess
			{
				damage *= 1.25;
			}
		}
		else
		{
			if(i_HeadshotAffinity[attacker] == 1) //if no crit, penalise
			{
				damage *= 0.75;
			}
#endif
		}
	}
	return false;
}
#endif	// Non-RTS


#if !defined RTS
static stock bool OnTakeDamagePlayerSpecific(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{	
#if defined RPG	
	//Random crit damage!
	//Yes, we allow those.
	if(GetRandomFloat(0.0, 1.0) < (float(1 + Stats_Luck(attacker)) * 0.001))
	{
		damage *= 3.0;
		DisplayCritAboveNpc(victim, attacker, true); //Display crit above head
	}
#else
	float CritChance = Attributes_GetOnPlayer(attacker, Attrib_CritChance, false,_, 0.0);
	if(CritChance && GetRandomFloat(0.0, 1.0) < (CritChance))
	{
		if(Rogue_Rift_BookOfWeakness())
			damage *= 2.0;
		else
			damage *= 3.0;
			
		DisplayCritAboveNpc(victim, attacker, true); //Display crit above head
	}

#endif

//when downed, reduce dmg
#if defined ZR
	if(dieingstate[attacker] > 0 && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_IGNORE_DEATH_PENALTY))
	{
//		if(b_XenoVial[attacker])
			damage *= 0.35;
			/*
		else
			damage *= 0.25;
	*/
	}
#endif
	//NPC STUFF FOR RECORD AND ON KILL
	LastHitRef[victim] = EntIndexToEntRef(attacker);
	DamageBits[victim] = damagetype;
	Damage[victim] = damage;
		
	if(weapon > MaxClients)
		LastHitWeaponRef[victim] = EntIndexToEntRef(weapon);
	else
		LastHitWeaponRef[victim] = -1;
	
	Attributes_OnHit(attacker, victim, weapon, damage, damagetype);
		
	return false;
}

stock void OnTakeDamageResistanceBuffs(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
	StatusEffect_OnTakeDamage_TakenPositive(victim, attacker, damage, damagetype);
	StatusEffect_OnTakeDamage_DealNegative(victim, attacker, damage, damagetype);
	float DamageRes = 1.0;
	//Resistance buffs will not count towards this flat decrease, they will be universal!hussar!
	//these are absolutes
#if !defined RPG
	if(victim > MaxClients && i_npcspawnprotection[victim] == NPC_SPAWNPROT_ON)
	{
		//dont give spawnprotection if both are
		if(attacker <= MaxClients)
		{
			DamageRes *= 0.05;
		}
		else if(i_npcspawnprotection[attacker] != NPC_SPAWNPROT_ON)
		{
			DamageRes *= 0.05;
		}
	}
#endif

#if defined ZR
	if(MoraleBoostLevelAt(victim) > 0)
		DamageRes *= EntityMoraleBoostReturn(victim, 3);
#endif
	

#if defined ZR
	if(GetTeam(victim) == 2 && Rogue_GetChaosLevel() > 0)
	{
		if(!(damagetype & DMG_TRUEDAMAGE))
			DamageRes *= 0.95;
	}
#endif
			
#if defined RPG
	switch(BubbleProcStatusLogicCheck(victim))
	{
		case -1:
		{
			if(!(damagetype & DMG_TRUEDAMAGE))
				DamageRes *= 0.85;
		}
		case 1:
		{
			DamageRes *= 1.15;
		}
	}
#endif
	
#if defined ZR
	if(RaidbossIgnoreBuildingsLogic(1) && GetTeam(victim) == TFTeam_Red)
	{
		//invert, then convert!
		float NewRes = 1.0 + ((DamageRes - 1.0) * PlayerCountResBuffScaling);
		DamageRes = NewRes;
	}
#endif

	damage *= DamageRes;	

#if !defined RPG
	if(attacker > MaxClients && i_npcspawnprotection[attacker] == NPC_SPAWNPROT_ON)
	{
		damage *= 1.5;
	}
#endif
	if(f_MultiDamageTaken[victim] != 1.0)
	{
		if((damagetype & DMG_TRUEDAMAGE))
		{
			if(f_MultiDamageTaken[victim] >= 1.0)
			{
				damage *= f_MultiDamageTaken[victim];
			}
		}
		else
			damage *= f_MultiDamageTaken[victim];
	}
	if(f_MultiDamageTaken_Flat[victim] != 1.0)
	{
		if((damagetype & DMG_TRUEDAMAGE))
		{
			if(f_MultiDamageTaken_Flat[victim] >= 1.0)
			{
				damage *= f_MultiDamageTaken_Flat[victim];
			}
		}
		else
			damage *= f_MultiDamageTaken_Flat[victim];
	}

#if defined ZR
	if((i_CurrentEquippedPerk[victim] & PERK_OBSIDIAN) && !(damagetype & DMG_TRUEDAMAGE))
		damage *= 0.85;
#endif
}

stock void OnTakeDamageDamageBuffs(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{
#if defined ZR
	if(inflictor > 0)
	{
		if(b_ThisWasAnNpc[inflictor])
		{
			if(!(damagetype & (DMG_CLUB|DMG_TRUEDAMAGE))) //if its not melee damage
			{
				if(i_CurrentEquippedPerk[inflictor] & PERK_MARKSMAN_BEER)
				{
					damage *= 1.25; //this should stack
				}
			}
		}
	}
#endif
}


void EntityBuffHudShow(int victim, int attacker, char[] Debuff_Adder_left, char[] Debuff_Adder_right, int SizeOfChar = 64)
{
	Debuff_Adder_left[0] = 0;
	Debuff_Adder_right[0] = 0;
	//This hud is for debuffs thats shared between players and enemies
	
	//These buffs/Debuffs stay how they are for the foreseeable future.
	if(BleedAmountCountStack[victim] > 0)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s❣(%i)", Debuff_Adder_left, BleedAmountCountStack[victim]);			
	}
#if defined RPG
	if(victim <= MaxClients)
	{
		if(TrueStength_ClientBuff(victim))
		{
			Format(Debuff_Adder_right, SizeOfChar, "%sT", Debuff_Adder_right);
		}
		float dummyNumber;
		if(RPG_BobsPureRage(victim, -1, dummyNumber))
		{
			Format(Debuff_Adder_right, SizeOfChar, "%sRA", Debuff_Adder_right);
		}
		if(WarCry_Enabled(victim))
		{
			Format(Debuff_Adder_left, SizeOfChar, "w%s", Debuff_Adder_left);
		}
		if(WarCry_Enabled_Buff(victim))
		{
			Format(Debuff_Adder_left, SizeOfChar, "W%s", Debuff_Adder_left);
		}
	}
	
	if(attacker > 0 && attacker <= MaxClients)
	{
		if(TrueStrength_StacksOnEntity(attacker, victim) > 0) //True stength!
		{
			if(TrueStrength_StacksOnEntity(attacker, victim) < TrueStrength_StacksOnEntityMax(attacker))
				Format(Debuff_Adder_left, SizeOfChar, "%sT(%i/%i)", Debuff_Adder_left, TrueStrength_StacksOnEntity(attacker, victim), TrueStrength_StacksOnEntityMax(attacker));			
			else
				Format(Debuff_Adder_left, SizeOfChar, "%sT(MAX)", Debuff_Adder_left);			
		}
	}

	switch(BubbleProcStatusLogicCheck(victim))
	{
		case -1:
		{
			Format(Debuff_Adder_right, SizeOfChar, "%sB!", Debuff_Adder_right);
		}
		case 1:
		{
			Format(Debuff_Adder_left, SizeOfChar, "b!%s", Debuff_Adder_left);
		}
	}
#endif

#if defined ZR
	if(attacker > 0 && attacker <= MaxClients)
	{
		if(i_HowManyBombsOnThisEntity[victim][attacker] > 0)
		{
			Format(Debuff_Adder_left, SizeOfChar, "%s!(%i)", Debuff_Adder_left, i_HowManyBombsOnThisEntity[victim][attacker]);
		}
	}
#endif

	char BufferAdd[6];
#if defined ZR
	if(Victoria_Support_RechargeTime(victim))
	{
		FormatEx(Debuff_Adder_left, SizeOfChar, "%s[◈ %i％]", Debuff_Adder_left, Victoria_Support_RechargeTime(victim));
	}
	else if(IsValidClient(victim) && Vs_LockOn[victim])
	{
		FormatEx(Debuff_Adder_left, SizeOfChar, "%s!Lock on!", Debuff_Adder_left);
	}
	if(VausMagicaShieldLeft(victim) > 0)
	{
		Format(Debuff_Adder_right, SizeOfChar, "S(%i)%s",VausMagicaShieldLeft(victim),Debuff_Adder_right);
	}
	if(GetTeam(victim) == 2 && Rogue_GetChaosLevel() > 0)
	{
		Format(Debuff_Adder_right, SizeOfChar, "⛡%s", Debuff_Adder_right);
	}
	if(MoraleBoostLevelAt(victim) > 0) //hussar!
	{
		//Display morale!
		MoraleIconShowHud(victim, Debuff_Adder_right, SizeOfChar);
	}
	
	//Display Modifiers here.
	if(Waves_InFreeplay())
		Freeplay_CharBuffToAdd(BufferAdd);
	else
		ZRModifs_CharBuffToAdd(BufferAdd);
#endif
	int Victim_weapon = -1;

	if(victim <= MaxClients)
		Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");

	StatusEffects_HudHurt(victim, attacker, Debuff_Adder_left, Debuff_Adder_right, SizeOfChar, Victim_weapon);

	if(BufferAdd[0])
	{
		if(GetTeam(victim) != TFTeam_Red)
		{
			Format(Debuff_Adder_right, SizeOfChar, "%c%s", BufferAdd,Debuff_Adder_right);
		}
		else
		{
			Format(Debuff_Adder_left, SizeOfChar, "%c%s", BufferAdd,Debuff_Adder_left);
		}
	}
}
