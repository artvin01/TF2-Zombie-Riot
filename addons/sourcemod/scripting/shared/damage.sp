#pragma semicolon 1
#pragma newdecls required

#define RES_BATTILONS 0.85
#define RES_MEDIGUN_LOW 0.95

#define DMG_MEDIGUN_LOW 1.25
#define DMG_WIDOWS_WINE 1.35
#define DMG_ANTI_RAID 1.1

float BarbariansMindNotif[MAXTF2PLAYERS];
void DamageModifMapStart()
{
	Zero(BarbariansMindNotif);
}

stock bool Damage_Modifiy(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//LogEntryInvicibleTest(victim, attacker, damage, 5);
	
	if(Damage_AnyVictim(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
		return true;

	//LogEntryInvicibleTest(victim, attacker, damage, 6);
	if(victim <= MaxClients)
	{
#if !defined RTS
		if(Damage_PlayerVictim(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
			return true;
		//LogEntryInvicibleTest(victim, attacker, damage, 7);
#endif
	}
	else if(!b_NpcHasDied[victim])
	{
		if(Damage_NPCVictim(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
			return true;
		//LogEntryInvicibleTest(victim, attacker, damage, 8);
	}
	else if(i_IsABuilding[victim])
	{
		if(Damage_BuildingVictim(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
			return true;
		//LogEntryInvicibleTest(victim, attacker, damage, 9);
	}

	if(attacker > 0)
	{
		if(Damage_AnyAttacker(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
			return true;

		//LogEntryInvicibleTest(victim, attacker, damage, 13);
		if(attacker <= MaxClients)
		{
#if !defined RTS
			if(Damage_PlayerAttacker(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
				return true;
#endif
			//LogEntryInvicibleTest(victim, attacker, damage, 14);
		}
		else if(!b_NpcHasDied[attacker])
		{
			if(Damage_NPCAttacker(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
				return true;
			//LogEntryInvicibleTest(victim, attacker, damage, 15);
		}
		else if(i_IsABuilding[attacker])
		{
			if(Damage_BuildingAttacker(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
				return true;
			//LogEntryInvicibleTest(victim, attacker, damage, 16);
		}
	}

	return false;
}

stock bool Damage_AnyVictim(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
//	float GameTime = GetGameTime();

#if defined ZR
	if(Rogue_Mode() && GetTeam(victim) == TFTeam_Red)
	{
		int scale = Rogue_GetRoundScale();
		if(scale < 2)
		{
			damage *= 0.50;
		}
		else if(scale < 4)
		{
			damage *= 0.75;
		}
	}
#endif

	return false;
}

#if !defined RTS
stock bool Damage_PlayerVictim(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
#if defined RPG
	if(!(damagetype & (DMG_FALL|DMG_DROWN)))
		RPG_FlatRes(victim, attacker, weapon, damage);
#endif

#if defined ZR
	if(attacker > MaxClients && b_ThisNpcIsSawrunner[attacker])
		return false;

	if(attacker <= MaxClients && attacker > 0 && attacker != 0)
	{
#if defined RPG
		if(!(RPGCore_PlayerCanPVP(attacker,victim)))
#endif
			return true;

#if defined RPG
		LastHitRef[victim] = EntIndexToEntRef(attacker);
#endif	
	}
	float GameTime = GetGameTime();

	if(Medival_Difficulty_Level != 0.0)
	{
		damage *= 2.0 - Medival_Difficulty_Level; //More damage !! only upto double.
	}

	//FOR ANY WEAPON THAT NEEDS CUSTOM LOGIC WHEN YOURE HURT!!
	//It will just return the same damage if nothing is done.
	int Victim_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(Victim_weapon))
	{
		OnTakeDamage_ProvokedAnger(Victim_weapon);
		damage = Player_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, Victim_weapon, damagePosition);
	}

	if(OnTakeDamage_ShieldLogic(victim, damagetype))
		return true;

	if(RaidbossIgnoreBuildingsLogic(1) && i_HealthBeforeSuit[victim] > 0)
		damage *= 3.0;	//when a raid is alive, make quantum armor 8x as bad at tanking.

	switch(i_CurrentEquippedPerk[victim])
	{
		case 6:
		{
			int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
			int flMaxHealth = SDKCall_GetMaxHealth(victim);
		
			if((damage > float(flMaxHealth / 20) || flHealth < flMaxHealth / 5 || damage > 25.0) && f_WidowsWineDebuffPlayerCooldown[victim] < GameTime) //either too much dmg, or your health is too low.
			{
				f_WidowsWineDebuffPlayerCooldown[victim] = GameTime + 20.0;
				
				float vecVictim[3]; WorldSpaceCenter(victim, vecVictim);
				
				ParticleEffectAt(vecVictim, "peejar_impact_cloud_milk", 0.5);
				
				EmitSoundToAll("weapons/jar_explode.wav", victim, SNDCHAN_AUTO, 80, _, 1.0);
				
				damage *= 0.25;
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
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
									f_WidowsWineDebuff[baseboss_index] = GameTime + FL_WIDOWS_WINE_DURATION;
								}
							}
						}
					}
				}
			}
		}
	}
	OnTakeDamageResistanceBuffs(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);

	if(i_HealthBeforeSuit[victim] == 0)
	{
		int armorEnt = victim;
		int vehicle = GetEntPropEnt(victim, Prop_Data, "m_hVehicle");
		if(vehicle != -1)
			armorEnt = vehicle;

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
				int damage_recieved_after_calc;
				damage_recieved_after_calc = RoundToCeil(damage) - Armor_Charge[armorEnt];
				Armor_Charge[armorEnt] = 0;
				damage = float(damage_recieved_after_calc);

				//armor is broken!
				if(f_Armor_BreakSoundDelay[victim] < GetGameTime())
				{
					f_Armor_BreakSoundDelay[victim] = GetGameTime() + 5.0;	
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

		if(armorEnt == victim)
		{
			float percentage = ArmorPlayerReduction(victim);
			damage *= percentage;
		}
		else
		{
			damage *= 0.65;
		}
	}
#endif	// ZR

#if defined RPG
	Player_Ability_Warcry_OnTakeDamage(attacker, victim, damage);

	if(TrueStength_ClientBuff(victim))
		damage *= 0.85;

	switch(BubbleProcStatusLogicCheck(victim))
	{
		case -1:
			damage *= 0.85;
		
		case 1:
			damage *= 1.15;
	}

	if(WarCry_Enabled_Buff(victim))
		damage *= WarCry_ResistanceBuff(victim);

	RPG_BobsPureRage(victim, attacker, damage);
	NPC_Ability_TrueStrength_OnTakeDamage(attacker, victim, weapon, damagetype, i_HexCustomDamageTypes[victim]);
#endif	// RPG

	return false;
}
#endif	// Non-RTS

stock bool Damage_NPCVictim(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	view_as<CClotBody>(victim).m_bGib = false;

	float GameTime = GetGameTime();
	
#if defined ZR
	if(Rogue_Mode() && GetTeam(victim) != TFTeam_Red)
	{
		int scale = Rogue_GetRoundScale();
		if(scale < 2)
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
#endif

#if defined ZR || defined NOG || defined RPG
		OnTakeDamageNpcBaseArmorLogic(victim, attacker, damage, damagetype, _,weapon);
#endif

#if defined ZR || defined NOG
		VausMagicaShieldLogicNpcOnTakeDamage(attacker, victim, damage, damagetype,i_HexCustomDamageTypes[victim], weapon);
#endif

#if defined ZR
		OnTakeDamageWidowsWine(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);
		OnTakeDamage_RogueItemGeneric(attacker, damage, damagetype, inflictor);
#endif


#if !defined RTS
		OnTakeDamageDamageBuffs(victim, attacker, inflictor, basedamage, damage, damagetype, weapon, GameTime);

		OnTakeDamageResistanceBuffs(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);
		
		if(attacker <= MaxClients && attacker > 0)
			OnTakeDamagePlayerSpecific(victim, attacker, inflictor, damage, damagetype, weapon);
#endif

#if defined ZR			
		OnTakeDamageScalingWaveDamage(victim, attacker, inflictor, damage, damagetype, weapon);
#endif

#if !defined RTS
		OnTakeDamageVehicleDamage(attacker, inflictor, damage, damagetype);
#endif

		if(attacker <= MaxClients && attacker > 0)
		{
			if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
			{

#if defined ZR
				DoClientHitmarker(attacker);
#endif

				if(IsValidEntity(weapon))
				{

#if defined ZR
					damage = NPC_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, i_HexCustomDamageTypes[victim]);
					OnTakeDamage_HandOfElderMages(attacker, weapon);
#endif

#if !defined RTS
					OnTakeDamageOldExtraWeapons(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);
					OnTakeDamageBackstab(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);
#endif

				}
			}
			
#if defined ZR
			if(TF2_IsPlayerInCondition(attacker, TFCond_NoHealingDamageBuff) || (damagetype & DMG_CRIT))
			{
				damage *= 1.35;
				bool PlaySound = false;
				if(f_MinicritSoundDelay[attacker] < GetGameTime())
				{
					PlaySound = true;
					f_MinicritSoundDelay[attacker] = GetGameTime() + 0.25;
				}
				
				DisplayCritAboveNpc(victim, attacker, PlaySound,_,_,true); //Display crit above head

				damagetype &= ~DMG_CRIT;
			}
#endif
		}
	}
	
#if defined RTS
	RTS_TakeDamage(victim, damage, damagetype);
#endif

#if defined RPG
	NPC_Ability_TrueStrength_OnTakeDamage(attacker, victim, weapon, damagetype, i_HexCustomDamageTypes[victim]);
	RPG_ChaosSurgance(victim, attacker, weapon, damage);
	RPG_BobsPureRage(victim, attacker, damage);

	//this should be last.
	RPG_FlatRes(victim, attacker, weapon, damage);
#endif

	NpcSpecificOnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

#if defined ZR
	if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS))
	{
		if(attacker <= MaxClients && attacker > 0)
		{
			if(IsValidEntity(weapon))
				NPC_OnTakeDamage_Equipped_Weapon_Logic_PostCalc(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);	
		}
	}
#endif

	return false;
}

stock bool Damage_BuildingVictim(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	float GameTime = GetGameTime();
	OnTakeDamageResistanceBuffs(victim, attacker, inflictor, damage, damagetype, weapon, GameTime);

	if(!b_NpcIsTeamkiller[attacker])
	{
		if(GetTeam(attacker) == GetTeam(victim)) //should be entirely ignored
		{
			return true;
		}
	}
	if(b_ThisEntityIgnored[victim])
	{
		damage = 0.0;
		return true;
	}
	OnTakeDamageNpcBaseArmorLogic(victim, attacker, damage, damagetype, _,weapon);
	return false;
}

stock bool Damage_AnyAttacker(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	float GameTime = GetGameTime();
	
	if(!NpcStats_IsEnemySilenced(attacker))
	{
		if(f_HussarBuff[attacker] > GameTime) //hussar!
		{
			damage += basedamage * 0.1;
		}
	}
	
	if(f_PernellBuff[attacker] > GameTime)
		damage += basedamage * 0.5; //50% more damage!
	
	if(f_GodAlaxiosBuff[attacker] > GameTime)
		damage += basedamage * 0.5; //50% more damage!
	
	if(f_Ocean_Buff_Stronk_Buff[attacker] > GameTime)
	{
		damage += basedamage * 0.25;
	}
	else if(f_Ocean_Buff_Weak_Buff[attacker] > GameTime)
	{
		damage += basedamage * 0.1;
	}

	if(f_EmpowerStateOther[attacker] > GameTime)
		damage += basedamage * 0.1;
	
	if(f_EmpowerStateSelf[attacker] > GameTime)
		damage += basedamage * 0.15;
	
	if(f_BuffBannerNpcBuff[attacker] > GameTime)
		damage += basedamage * 0.25;
	
	if(Increaced_Overall_damage_Low[attacker] > GameTime)	//this doesnt get applied in groups.
		damage += basedamage * (DMG_MEDIGUN_LOW - 1.0);
	
	return false;
}

#if !defined RTS
stock bool Damage_PlayerAttacker(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	float GameTime = GetGameTime();

#if defined ZR
	if(Rogue_InItallianWrath(weapon))
		damage *= 2.0;
#endif

	OnTakeDamageBuildingBonusDamage(attacker, inflictor, damage, damagetype, weapon, GameTime);

	return false;
}
#endif

stock bool Damage_NPCAttacker(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
#if defined ZR
	float GameTime = GetGameTime();

	//freeplay causes more damage taken for allies only.
	if(GetTeam(victim) == TFTeam_Red && f_FreeplayDamageExtra != 1.0 && !b_thisNpcIsARaid[attacker])
	{
		damage *= f_FreeplayDamageExtra;
	}

	if(!(damagetype & (DMG_CLUB|DMG_SLASH))) //if its not melee damage
	{
		if(i_CurrentEquippedPerk[attacker] == 5)
		{
			damage *= 1.25;
		}
	}

	if(f_PotionShrinkEffect[attacker] > GameTime)
	{
		damage *= 0.75;
	}

	if(f_EnfeebleEffect[attacker] > GameTime)
	{
		// Enfeeble fades out with time
		float resist = (f_EnfeebleEffect[attacker] - GameTime) / 15.0;
		if(resist < 0.9)
			resist = 0.9;
		
		damage *= resist;
	}

	if(f_LeeSuperEffect[attacker] > GameTime)
	{
		damage *= 0.72;
	}
	else if(f_LeeMajorEffect[attacker] > GameTime)
	{
		damage *= 0.86;
	}
	else if(f_LeeMinorEffect[attacker] > GameTime)
	{
		damage *= 0.93;
	}
	
	if(f_Ruina_Attack_Buff[attacker] > GameTime)
		damage += basedamage * f_Ruina_Attack_Buff_Amt[attacker];	//x% dmg bonus
#endif
	return false;
}

stock bool Damage_BuildingAttacker(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return false;
}

#if defined ZR
static float Player_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3])
{
	switch(i_CustomWeaponEquipLogic[equipped_weapon])
	{
		case WEAPON_ARK: // weapon_ark
		{
			return Player_OnTakeDamage_Ark(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_NEARL, WEAPON_FUSION_PAP2:
		{
			return Player_OnTakeDamage_Fusion(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_RIOT_SHIELD:
		{
			return Player_OnTakeDamage_Riot_Shield(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_MLYNAR: // weapon_ark
		{
			Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon);
		}
		case WEAPON_MLYNAR_PAP: // weapon_ark
		{
			Player_OnTakeDamage_Mlynar(victim, damage, attacker, equipped_weapon, 1);
		}
		case WEAPON_OCEAN, WEAPON_SPECTER:
		{
			return Gladiia_OnTakeDamageAlly(victim, attacker, damage);
		}
		case WEAPON_GLADIIA:
		{
			return Gladiia_OnTakeDamageSelf(victim, attacker, damage);
		}
		case WEAPON_BLEMISHINE:
		{
			return Player_OnTakeDamage_Blemishine(victim, attacker, damage);
		}
		case WEAPON_BOARD:
		{
			return Player_OnTakeDamage_Board(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_LEPER_MELEE_PAP, WEAPON_LEPER_MELEE:
		{
			return WeaponLeper_OnTakeDamagePlayer(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_FLAGELLANT_MELEE, WEAPON_FLAGELLANT_HEAL:
		{
			Flagellant_OnTakeDamage(victim, damage);
		}
		case WEAPON_RAPIER:
		{
			Player_OnTakeDamage_Rapier(victim, attacker, damage);
		}
		case WEAPON_RED_BLADE:
		{
			WeaponRedBlade_OnTakeDamage(attacker, victim, damage);
		}
		case WEAPON_HEAVY_PARTICLE_RIFLE:
		{
			return Player_OnTakeDamage_Heavy_Particle_Rifle(victim, damage, attacker, equipped_weapon, damagePosition);
		}
		case WEAPON_MERCHANT:
		{
			Merchant_SelfTakeDamage(victim, attacker, damage);
		}
	}
	return damage;
}
#endif	// ZR

bool BarbariansMindLogic(int attacker, int weapon, float &damage, int damagetype)
{
	if(attacker <= MaxClients)
	{
		if(i_BarbariansMind[attacker] == 1)	// Deal extra damage with melee, but none with everything else
		{
			int slot = -1;
			if(IsValidEntity(weapon))
			{
				char classname[64];
				GetEntityClassname(weapon, classname, sizeof(classname));
				slot = TF2_GetClassnameSlot(classname);

				if(i_OverrideWeaponSlot[weapon] != -1)
				{
					slot = i_OverrideWeaponSlot[weapon];
				}
			}

			if(slot == 2 || (damagetype & (DMG_CLUB|DMG_SLASH))) // if you want anything to be melee based, just give them this.
			{
				damage *= 1.1;
			}
			else
			{
				if(BarbariansMindNotif[attacker] > GetGameTime())
				{
					SetGlobalTransTarget(attacker);
					PrintToChat(attacker,"%t", "Barbarians Mind Warning");
					BarbariansMindNotif[attacker] = GetGameTime() + 15.0;
				}
				return true;
			}
		}
	}
	return false;
}
static bool NullfyDamageAndNegate(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int damagecustom)
{
#if defined ZR
	if(BarbariansMindLogic(attacker, weapon, damage, damagetype))
	{
		return true;
	}
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
	if(!b_NpcIsTeamkiller[attacker])
	{
		if(GetTeam(attacker) == GetTeam(victim)) //should be entirely ignored
		{
			return true;
		}
	}
	return false;
}

static bool OnTakeDamageAbsolutes(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{
	//we list off all on hit things that are neccecary, or absolute damage resistances that apply no matter what.
	f_TimeUntillNormalHeal[victim] = GameTime + 4.0;
	i_HasBeenBackstabbed[victim] = false;
	if(f_TraceAttackWasTriggeredSameFrame[victim] != GameTime)
	{
		i_HasBeenHeadShotted[victim] = false;
	}
#if !defined RPG
	if(b_npcspawnprotection[victim])
		damage *= 0.25;
#endif
		
#if defined ZR
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
#endif
	CClotBody npcBase = view_as<CClotBody>(victim);
	if(f_IsThisExplosiveHitscan[attacker] == GameTime)
	{
		float v[3];
		CalculateDamageForceSelfCalculated(attacker, 10000.0, v);
		npcBase.m_vecpunchforce(v, true);
		damagetype |= DMG_BULLET; //add bullet logic
		damagetype &= ~DMG_BLAST; //remove blast logic			
	}
	return false;
}

static stock float NPC_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
#if defined ZR
	//did we hit any headshot ?
	if(b_MeleeCanHeadshot[weapon])
	{
		static int DummyAmmotype = 0; //useless but needed
		NPC_TraceAttack(victim, attacker, inflictor, damage, damagetype, DummyAmmotype, 0, i_MeleeHitboxHit[attacker]);
	}
	
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_BOUNCING:
		{
			return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_MAIMMOAB:
		{
			return SniperMonkey_MaimMoab(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_CRIPPLEMOAB:
		{
			return SniperMonkey_CrippleMoab(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_IRENE:
		{
			Npc_OnTakeDamage_Iberia(attacker, damagetype);
		}
		case 7://WEAPON_PHLOG:
		{
			Npc_OnTakeDamage_Phlog(attacker);
		}
		case WEAPON_NEARL: //pap fusion
		{
			return Npc_OnTakeDamage_PaP_Fusion(attacker, victim, damage, weapon);
		}
		case WEAPON_LAPPLAND: //pap ark alt
		{
			return Npc_OnTakeDamage_LappLand(damage, attacker, damagetype, inflictor, victim);
		}
		case WEAPON_QUIBAI: //pap ark alt
		{
			return Npc_OnTakeDamage_Quibai(damage, attacker, damagetype, inflictor, victim, weapon);
		}
		case WEAPON_SPECTER:
		{
			Specter_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_YAMATO:
		{
			Npc_OnTakeDamage_Yamato(attacker, damagetype);
		}
		case WEAPON_BEAM_PAP:
		{
			Npc_OnTakeDamage_BeamWand_Pap(attacker, damagetype);
		}
		case WEAPON_GLADIIA:
		{
			Gladiia_OnTakeDamageEnemy(victim, attacker, damage);
		}
		case WEAPON_BLEMISHINE:
		{
			NPC_OnTakeDamage_Blemishine(attacker, victim, damage,weapon);
		}
		case WEAPON_HAZARD, WEAPON_HAZARD_UNSTABLE, WEAPON_HAZARD_LUNATIC, WEAPON_HAZARD_CHAOS, WEAPON_HAZARD_STABILIZED, WEAPON_HAZARD_DEMI, WEAPON_HAZARD_PERFECT:
		{
			NPC_OnTakeDamage_Hazard(attacker, victim, damage,weapon);
		}
		case WEAPON_CASINO:
		{
			Npc_OnTakeDamage_Casino(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_FANTASY_BLADE:
		{
			Npc_OnTakeDamage_Fantasy_Blade(attacker, damagetype);
		}
		case WEAPON_SPEEDFISTS:
		{
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
			Vamp_ApplyBloodlust(attacker, victim, 1, false, false);
		}
		case WEAPON_VAMPKNIVES_2:
		{
			Vamp_ApplyBloodlust(attacker, victim, 2, false, false);
		}
		case WEAPON_VAMPKNIVES_2_CLEAVER:
		{
			Vamp_ApplyBloodlust(attacker, victim, 2, true, false);
		}
		case WEAPON_VAMPKNIVES_3:
		{
			Vamp_ApplyBloodlust(attacker, victim, 3, false, false);
		}
		case WEAPON_VAMPKNIVES_3_CLEAVER:
		{
			Vamp_ApplyBloodlust(attacker, victim, 3, true, false);
		}
		case WEAPON_VAMPKNIVES_4:
		{
			Vamp_ApplyBloodlust(attacker, victim, 4, false, false);
		}
		case WEAPON_VAMPKNIVES_4_CLEAVER:
		{
			Vamp_ApplyBloodlust(attacker, victim, 4, true, false);
		}
		case WEAPON_SENSAL_SCYTHE, WEAPON_SENSAL_SCYTHE_PAP_1, WEAPON_SENSAL_SCYTHE_PAP_2, WEAPON_SENSAL_SCYTHE_PAP_3:
		{
			WeaponSensal_Scythe_OnTakeDamage(attacker, victim,weapon, zr_custom_damage);
		}
		case WEAPON_LEPER_MELEE_PAP, WEAPON_LEPER_MELEE:
		{
			WeaponLeper_OnTakeDamage(attacker, damage,weapon, zr_custom_damage);
		}
		case WEAPON_TEXAN_BUISNESS:
		{
			Weapon_TexanBuisness(attacker, damage, damagetype);
		}
		case WEAPON_ANGELIC_SHOTGUN:
		{
			Weapon_AngelicShotgun(attacker, damage, damagetype);
		}
		case WEAPON_RAPIER:
		{
			NPC_OnTakeDamage_Rapier(attacker, victim, damage, weapon);
		}
		case WEAPON_GRAVATON_WAND:
		{
			NPC_OnTakeDmg_Gravaton_Wand(attacker, damagetype);
		}
		case WEAPON_RED_BLADE:
		{
			WeaponRedBlade_OnTakeDamageNpc(attacker,victim, damagetype,weapon, damage);
		}
		case WEAPON_SICCERINO:
		{
			return Npc_OnTakeDamage_Siccerino(attacker, victim, damage, weapon);
		}
		case WEAPON_DIMENSION_RIPPER:
		{
			Npc_OnTakeDamage_DimensionalRipper(attacker);
		}	
		case WEAPON_OBUCH:
		{
			Npc_OnTakeDamage_ObuchHammer(attacker, weapon);
		}
		case WEAPON_MERCHANT:
		{
			Merchant_NPCTakeDamage(victim, attacker, damage, weapon);
		}
		case WEAPON_MERCHANTGUN:
		{
			Merchant_GunTakeDamage(victim, attacker, damage);
		}
		case WEAPON_RUSTY_RIFLE:
		{
			return Rusty_OnNPCDamaged(victim, attacker, damage);
		}
	}
#endif

#if defined RPG
	switch(i_CustomWeaponEquipLogic[weapon])
	{

	}
#endif

	return damage;
}

static stock void NPC_OnTakeDamage_Equipped_Weapon_Logic_PostCalc(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
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
	}
#endif
}

#if defined RPG
stock bool OnTakeDamageRpgPartyLogic(int victim, int attacker, float GameTime)
{
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
	if(b_NpcIsInADungeon[victim] || attacker > MaxClients || Level[victim] > 1000000)
	{
		return false;	
	}

	if(RPGCore_ClientAllowedToTargetNpc(victim, attacker))
	{
		i_NpcFightOwner[victim] = attacker;
		f_NpcFightTime[victim] = GameTime + 10.0;
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
			if(!NpcStats_IsEnemySilenced(victim))
			{
				if(Medival_Difficulty_Level != 0.0 && GetTeam(victim) != TFTeam_Red)
				{
					TotalMeleeRes *= Medival_Difficulty_Level;
				}
			}

			if(!b_thisNpcIsARaid[victim] && GetTeam(victim) != TFTeam_Red && XenoExtraLogic(true))
			{
				TotalMeleeRes *= 0.85;
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
	else if(!(damagetype & DMG_SLASH))
	{
		if(!trueArmorOnly)
		{
			float TotalMeleeRes = 1.0;
#if defined ZR
			if(!b_NpcHasDied[attacker] && i_CurrentEquippedPerk[attacker] == 5)
			{
				TotalMeleeRes *= 1.25;
			}
			if(!NpcStats_IsEnemySilenced(victim))
			{
				if(Medival_Difficulty_Level != 0.0 && GetTeam(victim) != TFTeam_Red)
				{
					TotalMeleeRes *= Medival_Difficulty_Level;
				}
			}
#endif
			TotalMeleeRes *= fl_RangedArmor[victim];
			TotalMeleeRes *= fl_Extra_RangedArmor[victim];

#if defined ZR
			if(!b_thisNpcIsARaid[victim] && GetTeam(victim) != TFTeam_Red && XenoExtraLogic(true))
			{
				TotalMeleeRes *= 0.85;
			}
#endif

			damage *= TotalMeleeRes;
		}
		damage *= fl_TotalArmor[victim];
	}
	else if((damagetype & DMG_SLASH))
	{
		if(!trueArmorOnly)
		{
#if defined ZR
			if(!b_NpcHasDied[attacker] && i_CurrentEquippedPerk[attacker] == 5)
			{
				damage *= 1.25;
			}
#endif
			if(fl_RangedArmor[victim] > 1.0)
				damage *= fl_RangedArmor[victim];
			if(fl_Extra_RangedArmor[victim] > 1.0)
				damage *= fl_Extra_RangedArmor[victim];
			if(fl_MeleeArmor[victim] > 1.0)
				damage *= fl_MeleeArmor[victim];
			if(fl_Extra_MeleeArmor[victim] > 1.0)
				damage *= fl_Extra_MeleeArmor[victim];
		}
		if(fl_TotalArmor[victim] > 1.0)
			damage *= fl_TotalArmor[victim];
	}
	if(!trueArmorOnly)
	{
		damage *= fl_Extra_Damage[attacker];
	}
}

#if defined ZR
static stock void OnTakeDamageWidowsWine(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{
	if(i_CurrentEquippedPerk[victim] == 6)
	{
		if(f_WidowsWineDebuffPlayerCooldown[victim] < GameTime) //either too much dmg, or your health is too low.
		{
			f_WidowsWineDebuffPlayerCooldown[victim] = GameTime + 20.0;
				
			float vecVictim[3]; WorldSpaceCenter(victim,vecVictim);
				
			ParticleEffectAt(vecVictim, "peejar_impact_cloud_milk", 0.5);
				
			EmitSoundToAll("weapons/jar_explode.wav", victim, SNDCHAN_AUTO, 60, _, 1.0);

			damage *= 0.5;
			f_WidowsWineDebuff[attacker] = GameTime + FL_WIDOWS_WINE_DURATION;
		}
	}
}

static stock bool OnTakeDamageScalingWaveDamage(int &victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon)
{	
	float ExtraDamageDealt;

	ExtraDamageDealt = CurrentCash * 0.001; //at wave 60, this will equal to 60* dmg
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

static stock void OnTakeDamageVehicleDamage(int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if((damagetype & DMG_VEHICLE) && IsValidEntity(inflictor) && b_IsVehicle[inflictor])
	{
		static ConVar cvar;
		if(!cvar)
			cvar = FindConVar("vehicle_physics_damage_modifier");
		
		if(cvar)
			damage *= cvar.FloatValue;
	}
}

#if !defined RTS
static stock bool OnTakeDamageOldExtraWeapons(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{	
	if(!IsValidEntity(weapon))
		return false;

#if defined ZR
	if(i_HighTeslarStaff[weapon] == 1)
	{
		f_HighTeslarDebuff[victim] = GameTime + 5.0;
	}
	else if(i_LowTeslarStaff[weapon] == 1)
	{
		f_LowTeslarDebuff[victim] = GameTime + 5.0;
	}
#endif
	return false;
}

static stock bool OnTakeDamageBackstab(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{
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
					i_HasBeenBackstabbed[victim] = true;
						
					float attack_speed;

					attack_speed = 1.0;
					
					attack_speed *= Attributes_FindOnWeapon(attacker, weapon, 6, true, 1.0);
					attack_speed *= Attributes_FindOnWeapon(attacker, weapon, 396, true, 1.0); //Extra
						
					EmitSoundToAll("weapons/knife_swing_crit.wav", attacker, _, _, _, 0.7);
						
					DataPack pack = new DataPack();
					RequestFrame(DoMeleeAnimationFrameLater, pack);
					pack.WriteCell(EntIndexToEntRef(viewmodel));
					pack.WriteCell(melee);

					attack_speed *= f_BackstabCooldown[weapon]; //extra delay.

					damage *= 5.25;

#if defined ZR
					CClotBody npc = view_as<CClotBody>(victim);
					if(LastMann)
					{
						attack_speed *= 0.5; //extra delay.
					}

					if(b_FaceStabber[attacker] || i_NpcIsABuilding[victim] || IsEntityTowerDefense(victim))
#endif
					if(i_NpcIsABuilding[victim])
					{
						damage *= 0.35; //cut damage in half and then some.
					}	
					
					bool IsTargeter = false;
#if defined ZR
					if(attacker == npc.m_iTarget && !b_FaceStabber[attacker])
					{
						IsTargeter = true;
						damage *= 2.0; // EXTRA BONUS DAMAGE GIVEN BEACUSE OF THE AI BEING SMARTER AND AVOIDING HITS BETTER! But not for facestabbers.
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
					if(i_CurrentEquippedPerk[attacker] == 5) //Deadshot!
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
						SepcialBackstabLaughSpy(attacker);
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
		f_InBattleHudDisableDelay[attacker] = GetGameTime() + f_Data_InBattleHudDisableDelay[attacker] + 2.0;
#endif
		f_InBattleDelay[attacker] = GetGameTime() + 3.0;
		if(damagetype & DMG_CRIT)
		{		
			damage *= 1.35;
			DisplayCritAboveNpc(victim, attacker, true); //Display crit above head
			damagetype &= ~DMG_CRIT;
#if defined ZR
			if(i_HeadshotAffinity[attacker] == 1)
			{
				damage *= 1.35;
			}
			if(i_CurrentEquippedPerk[attacker] == 5) //Just give them 25% more damage if they do crits with the huntsman, includes buffbanner i guess
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

static stock bool OnTakeDamageBuildingBonusDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{	
	if(IsValidEntity(inflictor) && inflictor>MaxClients)// && attacker<=MaxClients)
	{
		if(i_IsABuilding[inflictor])
		{
			if(Increaced_Sentry_damage_Low[inflictor] > GameTime)
			{
				damage *= 1.15;
			}
			else if(Increaced_Sentry_damage_High[inflictor] > GameTime)
			{
				damage *= 1.3;
			}
		}
	}
	return false;
}

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
#endif

//when downed, reduce dmg
#if defined ZR
	if(dieingstate[attacker] > 0 && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_IGNORE_DEATH_PENALTY))
	{
		if(b_XenoVial[attacker])
			damage *= 0.45;
		else
			damage *= 0.25;
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

stock void OnTakeDamageResistanceBuffs(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float GameTime)
{
	float DamageRes = 1.0;
	//Resistance buffs will not count towards this flat decreace, they will be universal!hussar!
	if(f_PernellBuff[victim] > GameTime)
	{
		DamageRes *= 0.6;
	}
	if(f_GodAlaxiosBuff[victim] > GameTime) //hussar!
	{
		DamageRes *= 0.75;
	}
	if(f_BattilonsNpcBuff[victim] > GameTime)
		DamageRes *= RES_BATTILONS;

	if(f_EmpowerStateOther[victim] > GameTime) //Allow stacking.
		DamageRes *= 0.93;

	if(Resistance_Overall_Low[victim] > GameTime)
		DamageRes *= RES_MEDIGUN_LOW;


	if(Adaptive_MedigunBuff[victim][0] > GameTime)
		DamageRes *= 0.95;

	if(damagetype & (DMG_CLUB)) // if you want anything to be melee based, just give them this.
	{
		if(Adaptive_MedigunBuff[victim][1] > GameTime)
			DamageRes *= 0.85;
	}
	else
	{
		if(Adaptive_MedigunBuff[victim][2] > GameTime)
			DamageRes *= 0.85;
	}

	if(!NpcStats_IsEnemySilenced(victim))
	{
		if(f_HussarBuff[victim] > GameTime) //hussar!
		{
			DamageRes *= 0.90;
		}
	}
			
#if defined RPG
	switch(BubbleProcStatusLogicCheck(victim))
	{
		case -1:
		{
			DamageRes *= 0.85;
		}
		case 1:
		{
			DamageRes *= 1.15;
		}
	}
#endif
	
	if(RaidbossIgnoreBuildingsLogic(1) && GetTeam(victim) == TFTeam_Red)
	{
		//invert, then convert!
		float NewRes = 1.0 + ((DamageRes - 1.0) * PlayerCountResBuffScaling);
		DamageRes = NewRes;
	}

	damage *= DamageRes;	

	//this shouldnt be scaled.
	if(f_EmpowerStateSelf[victim] > GameTime) //Allow stacking.
		damage *= 0.9;
		
	if(f_MultiDamageTaken[victim] != 1.0)
	{
		damage *= f_MultiDamageTaken[victim];
	}
	if(f_MultiDamageTaken_Flat[victim] != 1.0)
	{
		damage *= f_MultiDamageTaken_Flat[victim];
	}

	if(i_CurrentEquippedPerk[victim] == 2)
		damage *= 0.85;
}

static stock void OnTakeDamageDamageBuffs(int victim, int &attacker, int &inflictor, float basedamage, float &damage, int &damagetype, int &weapon, float GameTime)
{
#if defined ZR
	if(inflictor > 0)
	{
		if(b_ThisWasAnNpc[inflictor])
		{
			if(!(damagetype & (DMG_CLUB|DMG_SLASH))) //if its not melee damage
			{
				if(i_CurrentEquippedPerk[inflictor] == 5)
				{
					damage *= 1.25; //this should stack
				}
			}
		}
	}
#endif

	float DamageBuffExtraScaling = 1.0;

#if defined ZR
	if(attacker <= MaxClients || inflictor <= MaxClients)
	{
		if(b_thisNpcIsARaid[victim])
			DamageBuffExtraScaling = PlayerCountBuffScaling;
	}
#endif

	if(f_HighTeslarDebuff[victim] > GameTime)
	{
		damage += basedamage * (0.25 * DamageBuffExtraScaling);
	}
	else if(f_LowTeslarDebuff[victim] > GameTime)
	{
		damage += basedamage * (0.2 * DamageBuffExtraScaling);
	}
	else if(f_LudoDebuff[victim] > GameTime)
	{
		damage += basedamage * (GetRandomFloat(0.05,0.15) * DamageBuffExtraScaling);
	}
	else if(f_SpadeLudoDebuff[victim] > GameTime)
	{
		damage += basedamage * (GetRandomFloat(0.10,0.15) * DamageBuffExtraScaling);
	}
	if(f_PotionShrinkEffect[victim] > GameTime)
	{
		damage += basedamage * (0.35 * DamageBuffExtraScaling);
	}
#if defined ZR	
	if(f_HighIceDebuff[victim] > GameTime)
	{
		if(IsZombieFrozen(victim))
			damage += basedamage * (0.30 * DamageBuffExtraScaling);
		else
			damage += basedamage * (0.15 * DamageBuffExtraScaling);
	}
	else if(f_LowIceDebuff[victim] > GameTime)
	{
		if(IsZombieFrozen(victim))
			damage += basedamage * (0.20 * DamageBuffExtraScaling);
		else
			damage += basedamage * (0.10 * DamageBuffExtraScaling);
	}
	else if(f_VeryLowIceDebuff[victim] > GameTime)
	{
		if(IsZombieFrozen(victim))
			damage += basedamage * (0.10 * DamageBuffExtraScaling);
		else
			damage += basedamage * (0.05 * DamageBuffExtraScaling);
	}
#endif
	if(f_BuildingAntiRaid[victim] > GameTime)
	{
		damage += basedamage * ((DMG_ANTI_RAID - 1.0)* DamageBuffExtraScaling);
	}
	if(f_WidowsWineDebuff[victim] > GameTime)
	{
		damage += basedamage * ((DMG_WIDOWS_WINE - 1.0) * DamageBuffExtraScaling);
	}
	
	if(f_CrippleDebuff[victim] > GameTime)
	{
		damage += basedamage * (0.3 * DamageBuffExtraScaling);
	}

	if(f_CudgelDebuff[victim] > GameTime)
	{
		damage += basedamage * (0.3 * DamageBuffExtraScaling);
	}	
#if defined RUINA_BASE
	if(f_Ruina_Defense_Buff[victim] > GameTime) //This is a resistance buff, but it works differently, so let it stay here for now.
	{
		damage -= basedamage * f_Ruina_Defense_Buff_Amt[victim];	//x% dmg resist
	}
#endif
}
#endif	// Non-RTS


void EntityBuffHudShow(int victim, int attacker, char[] Debuff_Adder_left, char[] Debuff_Adder_right)
{
	//This hud is for debuffs thats shared between players and enemies

	float GameTime = GetGameTime();

	int SizeOfChar = 64;
	
	//All debuffs go here!
	if(f_HighTeslarDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "⌁⌁");
	}
	else if(f_LowTeslarDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "⌁");
	}
	if (f_FallenWarriorDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s⋡", Debuff_Adder_left);	
	}
	if(f_LudoDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s^", Debuff_Adder_left);	
	}
	if(f_SpadeLudoDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s^^", Debuff_Adder_left);	
	}	
	if(BleedAmountCountStack[victim] > 0) //bleed
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s❣(%i)", Debuff_Adder_left, BleedAmountCountStack[victim]);			
	}
#if defined RPG
	if(victim < MaxClients)
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

	if(IgniteFor[victim] > 0) //burn
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s~", Debuff_Adder_left);			
	}
	if(f_HighIceDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s❅❅❅", Debuff_Adder_left);
	}
	else if(f_LowIceDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s❅❅", Debuff_Adder_left);
	}
	else if (f_VeryLowIceDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s❅", Debuff_Adder_left);	
	}
	if (f_BuildingAntiRaid[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%sR", Debuff_Adder_left);	
	}
	if(f_WidowsWineDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s४", Debuff_Adder_left);
	}
	if(f_CrippleDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s⯯", Debuff_Adder_left);
	}
	if(f_CudgelDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s‼", Debuff_Adder_left);
	}
	if(f_MaimDebuff[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s↓", Debuff_Adder_left);
	}
	if(f_PotionShrinkEffect[victim] > GameTime || f_EnfeebleEffect[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s▼", Debuff_Adder_left);
	}
	if(f_LeeMinorEffect[victim] > GameTime || f_LeeMajorEffect[victim] > GameTime || f_LeeSuperEffect[victim] > GameTime)
	{
		Format(Debuff_Adder_left, SizeOfChar, "%s☯", Debuff_Adder_left);
	}
	if(NpcStats_IsEnemySilenced(victim))
	{
		Format(Debuff_Adder_left, SizeOfChar, "%sX", Debuff_Adder_left);
	}


	//BUFFS GO HERE.
	if(Increaced_Overall_damage_Low[victim] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "⌃%s", Debuff_Adder_right);
	}
	if(Adaptive_MedigunBuff[victim][0] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "⍫%s", Debuff_Adder_right);
	}
	if(Adaptive_MedigunBuff[victim][1] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "⍬%s", Debuff_Adder_right);
	}
	if(Adaptive_MedigunBuff[victim][2] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "⍭%s", Debuff_Adder_right);
	}
	if(Resistance_Overall_Low[victim] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "⌅%s", Debuff_Adder_right);
	}
	if(f_EmpowerStateSelf[victim] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "⍋%s", Debuff_Adder_right);
	}
	if(f_EmpowerStateOther[victim] > GameTime) //Do not show fusion self buff.
	{
		Format(Debuff_Adder_right, SizeOfChar, "⍋%s", Debuff_Adder_right);
	}
#if defined ZR
	if(VausMagicaShieldLeft(victim) > 0)
	{
		Format(Debuff_Adder_right, SizeOfChar, "S(%i)%s",VausMagicaShieldLeft(victim),Debuff_Adder_right);
	}
#endif
	if(f_HussarBuff[victim] > GameTime) //hussar!
	{
		Format(Debuff_Adder_right, SizeOfChar, "ᐩ%s", Debuff_Adder_right);
	}
	if(f_PernellBuff[victim] > GameTime) //hussar!
	{
		Format(Debuff_Adder_right, SizeOfChar, "P%s", Debuff_Adder_right);
	}
	if(f_GodAlaxiosBuff[victim] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "ß%s", Debuff_Adder_right);
	}
	if(f_Ocean_Buff_Stronk_Buff[victim] > GameTime) //hussar!
	{
		Format(Debuff_Adder_right, SizeOfChar, "⍟%s", Debuff_Adder_right);
	}
	else if(f_Ocean_Buff_Weak_Buff[victim] > GameTime) //hussar!
	{
		Format(Debuff_Adder_right, SizeOfChar, "⌾%s", Debuff_Adder_right);
	}
	if(f_BattilonsNpcBuff[victim] > GameTime) //hussar!
	{
		Format(Debuff_Adder_right, SizeOfChar, "⛨%s", Debuff_Adder_right);
	}
	if(f_BuffBannerNpcBuff[victim] > GameTime) //hussar!
	{
		Format(Debuff_Adder_right, SizeOfChar, "↖%s", Debuff_Adder_right);
	}
	if(f_AncientBannerNpcBuff[victim] > GameTime) //hussar!
	{
		Format(Debuff_Adder_right, SizeOfChar, "➤%s", Debuff_Adder_right);
	}
#if defined RUINA_BASE
	if(f_Ruina_Defense_Buff[victim] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "♜%s", Debuff_Adder_right);
	}
	if(f_Ruina_Speed_Buff[victim] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "♝%s", Debuff_Adder_right);
	}
	if(f_Ruina_Attack_Buff[victim] > GameTime)
	{
		Format(Debuff_Adder_right, SizeOfChar, "♟%s", Debuff_Adder_right);
	}
#endif
#if defined ZR
	if(victim <= MaxClients)
	{
		if(Wands_Potions_HasBuff(victim))
		{
			Format(Debuff_Adder_right, SizeOfChar, "⌂%s", Debuff_Adder_right);
		}
		if(Wands_Potions_HasTonicBuff(victim))
		{
			Format(Debuff_Adder_right, SizeOfChar, "⌇%s", Debuff_Adder_right);
		}

		static int VillageBuffs;
		VillageBuffs = Building_GetClientVillageFlags(victim);

		if(VillageBuffs & VILLAGE_000)
		{
			Format(Debuff_Adder_right, SizeOfChar, "⌒%s", Debuff_Adder_right);
		}
		if(VillageBuffs & VILLAGE_200)
		{
			Format(Debuff_Adder_right, SizeOfChar, "⌭%s", Debuff_Adder_right);
		}
		if(VillageBuffs & VILLAGE_030)
		{
			Format(Debuff_Adder_right, SizeOfChar, "⌬%s", Debuff_Adder_right);
		}
		if(VillageBuffs & VILLAGE_050) //This has priority.
		{
			Format(Debuff_Adder_right, SizeOfChar, "⍣%s", Debuff_Adder_right);
		}
		else if(VillageBuffs & VILLAGE_040)
		{
			Format(Debuff_Adder_right, SizeOfChar, "⍤%s", Debuff_Adder_right);
		}
		if(VillageBuffs & VILLAGE_005) //This has priority.
		{
			Format(Debuff_Adder_right, SizeOfChar, "i%s", Debuff_Adder_right);
		}
	}
#endif
}
