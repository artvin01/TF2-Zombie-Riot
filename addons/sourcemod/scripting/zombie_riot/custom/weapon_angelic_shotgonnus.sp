#pragma semicolon 1
#pragma newdecls required
static float f_AngelicShotgunHudCD[MAXPLAYERS];
#define ANGELIC_STACKS_UNTILL_DOUBLE 2
#define ANGELIC_ABILITY_CHARGE_0 10
#define ANGELIC_ABILITY_CHARGE_1 32
#define ANGELIC_ABILITY_CHARGE_2 40
#define ANGELIC_SHOTGUN_ABILTIY_SOUND_1 "items/powerup_pickup_vampire.wav"
#define ANGELIC_SHOTGUN_SHOOT_ABILITY "weapons/shotgun/shotgun_dbl_fire7.wav"
static Handle h_TimerAngelicShotgun[MAXPLAYERS+1] = {null, ...};
static int i_Current_Pap[MAXPLAYERS+1] = {0, ...};
static int i_AbilityChargeAngelic[MAXPLAYERS+1] = {0, ...};
static int i_AngelicShotgunHalo[MAXPLAYERS+1][24];
static bool i_AbilityActiveAngelic[MAXPLAYERS+1] = {false, ...};
static float f_DoubleHitGameTime[MAXENTITIES];
static float f_DoubleHitGameTimeTimeSince[MAXENTITIES];
static int f_DoubleHitStack[MAXENTITIES];
static bool b_PossesItemTraining[MAXPLAYERS+1] = {false, ...};

#define ANGELIC_HIT_1	"npc/scanner/scanner_electric1.wav"

static int b_HasHitAlreadyAngelic[MAXENTITIES];
static bool FireCritOntoEnemy[MAXPLAYERS+1];

public void AngelicShotgun_MapStart()
{
	Zero(f_AngelicShotgunHudCD);
	PrecacheSound(ANGELIC_SHOTGUN_ABILTIY_SOUND_1);
	PrecacheSound(ANGELIC_SHOTGUN_SHOOT_ABILITY);
	PrecacheSound(ANGELIC_HIT_1);
	Zero(i_AbilityActiveAngelic);
	Zero(i_AbilityChargeAngelic);
	Zero(f_DoubleHitGameTimeTimeSince);
}

void AngelicShotgun_Enable(int client, int weapon)
{
	if (h_TimerAngelicShotgun[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANGELIC_SHOTGUN)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerAngelicShotgun[client];
			h_TimerAngelicShotgun[client] = null;
			i_Current_Pap[client] = Fantasy_Blade_Get_Pap(weapon);
			b_PossesItemTraining[client] = Items_HasNamedItem(client, "Iberian and Expidonsan Training");
			DataPack pack;
			h_TimerAngelicShotgun[client] = CreateDataTimer(0.1, Timer_Management_Angelic_Shotgun, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_ANGELIC_SHOTGUN)
	{
		i_Current_Pap[client] = Fantasy_Blade_Get_Pap(weapon);
		
		b_PossesItemTraining[client] = Items_HasNamedItem(client, "Iberian and Expidonsan Training");
		DataPack pack;
		h_TimerAngelicShotgun[client] = CreateDataTimer(0.1, Timer_Management_Angelic_Shotgun, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

bool AngelicShotgun_CritDo(int client)
{
	float RandmValue = GetRandomFloat(1.0,0.0);
	float ValueToCalc = 0.0;
	switch(i_Current_Pap[client])
	{
		case 3:
		{
			ValueToCalc = 0.34;
		}
		case 2:
		{
			ValueToCalc = 0.25;
		}
		case 1:
		{
			ValueToCalc = 0.18;
		}
		default:
		{
			ValueToCalc = 0.15;
		}
	}
	int ExtraChance;
	if(i_AbilityActiveAngelic[client])
	{
		if(i_Current_Pap[client] >= 2)
		{
			ExtraChance = ANGELIC_ABILITY_CHARGE_2 - i_AbilityChargeAngelic[client];
		}
		else if(i_Current_Pap[client] >= 1)
		{
			ExtraChance = ANGELIC_ABILITY_CHARGE_1 - i_AbilityChargeAngelic[client];
		}
		else
		{
			ExtraChance = ANGELIC_ABILITY_CHARGE_0 - i_AbilityChargeAngelic[client];
		}
	}
	ValueToCalc += float(ExtraChance) * 0.015; //each ammo spend gives an extra 1.5% chance to crit.
	
	if(RandmValue < ValueToCalc)
	{
		return true;
	}
	return false;
}
public void Weapon_AngelicShotgun(int attacker, float &damage, int damagetype)
{
	if(damagetype & DMG_CLUB)
	{
		if(i_AbilityActiveAngelic[attacker])
		{
			if(i_Current_Pap[attacker] == 0)
			{
				damage *= 1.3;
			}
			else
			{	
				damage *= 1.65;
			}
		}
	}
}
static int Fantasy_Blade_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	return pap;
}

void PlayCustomSoundAngelica(int client)
{
	int pitch = GetRandomInt(125,135);
	EmitSoundToAll(ANGELIC_HIT_1, client, SNDCHAN_AUTO, 75,_,0.6,pitch);
}
void Angelic_Shotgun_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	switch(i_Current_Pap[client])
	{
		case 3:
		{
			CustomMeleeRange = MELEE_RANGE * 1.25;
			CustomMeleeWide = MELEE_BOUNDS * 1.25;
			enemies_hit_aoe = 3;
		}
		case 1,2:
		{
			CustomMeleeRange = MELEE_RANGE * 1.2;
			CustomMeleeWide = MELEE_BOUNDS * 1.2;
			enemies_hit_aoe = 3;
		}
		default:
		{
			CustomMeleeRange = MELEE_RANGE * 1.15;
			CustomMeleeWide = MELEE_BOUNDS * 1.15;
			enemies_hit_aoe = 2;
		}
	}
	if(i_AbilityActiveAngelic[client])
	{
		CustomMeleeRange *= 1.15;
		CustomMeleeWide *= 1.15;	
	}
}

public Action Timer_Management_Angelic_Shotgun(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerAngelicShotgun[client] = null;
		RestoreOrDestroyAngelicShotgun(client, false);
		return Plugin_Stop;
	}	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		int MetalAmmo = GetAmmo(client, Ammo_Metal);
		if(MetalAmmo < 10)
		{
			SetAmmo(client, Ammo_Metal, 10);
		}
		//anti safe softlock
		//and that free 10 ammo just isnt worth it lol
		RestoreOrDestroyAngelicShotgun(client, i_AbilityActiveAngelic[client]);
	}
	else
	{
		RestoreOrDestroyAngelicShotgun(client, false);
	}
	Angelic_Shotgun_Cooldown_Logic(client, weapon);
	return Plugin_Continue;
}

public void Angelic_Shotgun_Cooldown_Logic(int client, int weapon)
{
	if(f_AngelicShotgunHudCD[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			char AbilityHud[255];

			switch(i_Current_Pap[client])
			{
				case 3:
				{
					if(i_AbilityActiveAngelic[client])
					{
						FormatEx(AbilityHud, sizeof(AbilityHud), "TELA [%i/%i]",i_AbilityChargeAngelic[client] / 2,ANGELIC_ABILITY_CHARGE_2 / 2);
					}
					else
					{
						if(i_AbilityChargeAngelic[client] >= ANGELIC_ABILITY_CHARGE_2)
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Absolutus ordo [READY]");
						}
						else
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Absolutus ordo [%i/%i]",i_AbilityChargeAngelic[client],ANGELIC_ABILITY_CHARGE_2);
						}					
					}
				}
				case 2:
				{
					if(i_AbilityActiveAngelic[client])
					{
						FormatEx(AbilityHud, sizeof(AbilityHud), "AMMO [%i/%i]",i_AbilityChargeAngelic[client] / 2,ANGELIC_ABILITY_CHARGE_2 / 2);
					}
					else
					{
						if(i_AbilityChargeAngelic[client] >= ANGELIC_ABILITY_CHARGE_2)
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Provisio iuris [READY]");
						}
						else
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Provisio iuris [%i/%i]",i_AbilityChargeAngelic[client],ANGELIC_ABILITY_CHARGE_2);
						}					
					}
				}
				case 1:
				{
					if(i_AbilityActiveAngelic[client])
					{
						FormatEx(AbilityHud, sizeof(AbilityHud), "AMMO [%i/%i]",i_AbilityChargeAngelic[client] / 2,ANGELIC_ABILITY_CHARGE_1 / 2);
					}
					else
					{
						if(i_AbilityChargeAngelic[client] >= ANGELIC_ABILITY_CHARGE_1)
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Angelic Law [READY]");
						}
						else
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Angelic Law [%i/%i]",i_AbilityChargeAngelic[client],ANGELIC_ABILITY_CHARGE_1);
						}					
					}

				}
				default:
				{
					if(i_AbilityActiveAngelic[client])
					{
						FormatEx(AbilityHud, sizeof(AbilityHud), "AMMO [%i/%i]",i_AbilityChargeAngelic[client] / 2,ANGELIC_ABILITY_CHARGE_0 / 2);
					}
					else
					{
						if(i_AbilityChargeAngelic[client] >= ANGELIC_ABILITY_CHARGE_1)
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Angelic Code [READY]");
						}
						else
						{
							FormatEx(AbilityHud, sizeof(AbilityHud), "Angelic Code [%i/%i]",i_AbilityChargeAngelic[client],ANGELIC_ABILITY_CHARGE_0);
						}					
					}
				}
			}
			PrintHintText(client,"%s",AbilityHud);
			
			f_AngelicShotgunHudCD[client] = GetGameTime() + 0.5;
		}
	}
}




void Angelic_Shotgun_Meleetrace_Hit_Before(int client, float &damage, int enemy)
{
	if(b_thisNpcIsARaid[enemy])
		damage *= 1.10;
		
	if(!i_AbilityActiveAngelic[client])
	{
		if(!b_HasHitAlreadyAngelic[client])
		{
			switch(i_Current_Pap[client])
			{
				case 2,3:
				{
					i_AbilityChargeAngelic[client] += 1;
					if(b_thisNpcIsARaid[enemy])
						i_AbilityChargeAngelic[client] += 1;
					if(i_AbilityChargeAngelic[client] >= ANGELIC_ABILITY_CHARGE_2)
					{
						i_AbilityChargeAngelic[client] = ANGELIC_ABILITY_CHARGE_2;
					}
				}
				case 1:
				{
					i_AbilityChargeAngelic[client] += 1;
					if(b_thisNpcIsARaid[enemy])
						i_AbilityChargeAngelic[client] += 1;

					if(i_AbilityChargeAngelic[client] >= ANGELIC_ABILITY_CHARGE_1)
					{
						i_AbilityChargeAngelic[client] = ANGELIC_ABILITY_CHARGE_1;
					}
				}
				case 0:
				{
					i_AbilityChargeAngelic[client] += 1;
					if(b_thisNpcIsARaid[enemy])
						i_AbilityChargeAngelic[client] += 1;

					if(i_AbilityChargeAngelic[client] >= ANGELIC_ABILITY_CHARGE_0)
					{
						i_AbilityChargeAngelic[client] = ANGELIC_ABILITY_CHARGE_0;
					}
				}
			}
		}
	}
	b_HasHitAlreadyAngelic[client] = true;
	if(FireCritOntoEnemy[client])
	{
		damage *= 1.35;
		bool PlaySound = false;
		if(f_MinicritSoundDelay[client] < GetGameTime())
		{
			PlaySound = true;
			f_MinicritSoundDelay[client] = GetGameTime() + 0.01;
		}
		DisplayCritAboveNpc(enemy, client, PlaySound); //Display crit above head
	}
	switch(i_Current_Pap[client])
	{
		case 3:
		{
			if(dieingstate[client] == 0)
			{
				float HealingPerHit = 10.0;
				if(b_thisNpcIsARaid[enemy])
					HealingPerHit *= 2.0;
				else if(b_thisNpcIsABoss[enemy])
					HealingPerHit *= 1.35;
				if(i_AbilityActiveAngelic[client])
					HealingPerHit *= 1.5;
				if(FireCritOntoEnemy[client])
					HealingPerHit *= 1.25;

				HealingPerHit *= 1.1;

				HealEntityGlobal(client, client, HealingPerHit, 1.35,_,HEAL_SELFHEAL);

			}
		}
		case 2:
		{
			if(dieingstate[client] == 0)
			{
				float HealingPerHit = 6.0;
				if(b_thisNpcIsARaid[enemy])
					HealingPerHit *= 2.0;
				else if(b_thisNpcIsABoss[enemy])
					HealingPerHit *= 1.35;
				if(i_AbilityActiveAngelic[client])
					HealingPerHit *= 1.5;
				if(FireCritOntoEnemy[client])
					HealingPerHit *= 1.25;

				HealingPerHit *= 1.1;
				HealEntityGlobal(client, client, HealingPerHit, 1.25,_,HEAL_SELFHEAL);
			}
		}
		case 1:
		{
			if(dieingstate[client] == 0)
			{
				float HealingPerHit = 5.0;
				if(b_thisNpcIsARaid[enemy])
					HealingPerHit *= 2.0;
				else if(b_thisNpcIsABoss[enemy])
					HealingPerHit *= 1.35;
				if(i_AbilityActiveAngelic[client])
					HealingPerHit *= 1.5;
				if(FireCritOntoEnemy[client])
					HealingPerHit *= 1.25;

				HealingPerHit *= 1.1;
				HealEntityGlobal(client, client, HealingPerHit, 1.25,_,HEAL_SELFHEAL);
			}
		}
		default:
		{
			if(dieingstate[client] == 0)
			{
				float HealingPerHit = 2.0;
				if(b_thisNpcIsARaid[enemy])
					HealingPerHit *= 2.0;
				else if(b_thisNpcIsABoss[enemy])
					HealingPerHit *= 1.35;
					
				if(i_AbilityActiveAngelic[client])
					HealingPerHit *= 1.5;
				if(FireCritOntoEnemy[client])
					HealingPerHit *= 1.25;

				HealingPerHit *= 1.1;

				HealEntityGlobal(client, client, HealingPerHit, 1.15,_,HEAL_SELFHEAL);
			}
		}
	}
}


void Angelic_Shotgun_Meleetrace_Hit_After(int client, float &damage)
{
	switch(i_Current_Pap[client])
	{
		case 3:
		{
			damage *= 0.65;
		}
		case 2:
		{
			damage *= 0.65;
		}
		case 1:
		{
			damage *= 0.55;
		}
		default:
		{
			damage *= 0.5;
		}
	}
}
public void Angelic_ShotgunEffectM1(int client, int weapon, bool crit, int slot)
{
	AddAmmoClient(client, 3, 1, 1.0, true);
	bool GiveDoubleStrike = false;
	//reset hud due to fast doublehits
	f_HudCooldownAntiSpam[client] = 0.0;
	f_HudCooldownAntiSpamRaid[client] = 0.0;
	if(i_AbilityActiveAngelic[client])
	{
		GiveDoubleStrike = true;
		i_AbilityChargeAngelic[client] -= 1;
	}
	else
	{
		b_HasHitAlreadyAngelic[client] = false;
		if(f_DoubleHitGameTimeTimeSince[client] < GetGameTime() || i_NextAttackDoubleHit[weapon])
		{
			f_DoubleHitGameTime[client] = 0.0;
			f_DoubleHitStack[client] = 0;
		}
		if(f_DoubleHitGameTime[client] != GetGameTime())
		{
			if(f_DoubleHitGameTimeTimeSince[client] > GetGameTime() && !i_NextAttackDoubleHit[weapon])
			{
				if(i_Current_Pap[client] >= 3)
					f_DoubleHitStack[client] += 1;

				f_DoubleHitStack[client] += 1;
			}
		}
		f_DoubleHitGameTime[client] = GetGameTime();
		f_DoubleHitGameTimeTimeSince[client] = GetGameTime() + 5.0;
		if(f_DoubleHitStack[client] >= ANGELIC_STACKS_UNTILL_DOUBLE)
		{
			GiveDoubleStrike = true;
			f_DoubleHitStack[client] = 0;
		}
		if(i_AbilityActiveAngelic[client] && i_NextAttackDoubleHit[weapon] == 0)
		{
			GiveDoubleStrike = true;
		}
		
	}
	if(GiveDoubleStrike)
	{
		f_DoubleHitStack[client] = 0;
		float attackspeed = Attributes_Get(weapon, 6, 1.0);
		if(!b_WeaponAttackSpeedModified[weapon]) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
		{
			if(i_AbilityActiveAngelic[client])
				EmitSoundToAll(ANGELIC_SHOTGUN_SHOOT_ABILITY, client, _, 75, _, 0.60);
			i_NextAttackDoubleHit[weapon] = 2;
			b_WeaponAttackSpeedModified[weapon] = true;
			attackspeed = (attackspeed * 0.08);
			Attributes_Set(weapon, 6, attackspeed);
		}
		else
		{
			if(i_AbilityActiveAngelic[client])
				i_NextAttackDoubleHit[weapon] = 0;
			else
				i_NextAttackDoubleHit[weapon] = 1;
			b_WeaponAttackSpeedModified[weapon] = false;
			attackspeed = (attackspeed / 0.08);
			Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
		}
	}
	else
	{
		i_NextAttackDoubleHit[weapon] = 0;
		float attackspeed = Attributes_Get(weapon, 6, 1.0);
		if(b_WeaponAttackSpeedModified[weapon]) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
		{
			i_NextAttackDoubleHit[weapon] = 1;
			b_WeaponAttackSpeedModified[weapon] = false;
			attackspeed = (attackspeed / 0.08);
			Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
		}
	}

	if(i_AbilityActiveAngelic[client])
	{
		if(i_AbilityChargeAngelic[client] <= 0)
		{
			i_AbilityActiveAngelic[client] = false;
			i_AbilityChargeAngelic[client] = 0;
		}
	}
	if(AngelicShotgun_CritDo(client))
	{
		FireCritOntoEnemy[client] = true;
	}
	else
	{
		FireCritOntoEnemy[client] = false;
	}
	//effects below.
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(viewmodelModel))
		return;
	
	/*
	float flPos[3];
	float flAng[3];
	float flPos2[3];
	float flAng2[3];
	GetAttachment(weapon, "muzzle", flPos2, flAng);
	GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng2);
	int particle = ParticleEffectAt(flPos, "rocketbackblast", 0.25);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetEntPropVector(particle, Prop_Data, "m_angRotation", flAng); 
	*/
	static float angles[3];
	static float startPoint[3];
	static float endPoint[3];
	
	
	GetClientEyePosition(client, startPoint);
	GetClientEyeAngles(client, angles);

	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		float RangeDo;
		float RangeDo2;
		bool invalid1;
		int invalid2;
		Angelic_Shotgun_DoSwingTrace(client, RangeDo, RangeDo2, invalid1, invalid2);
		RangeDo *= Attributes_Get(weapon, 4001, 1.0);
		RangeDo *= 2.5;
		TR_GetEndPosition(endPoint, trace);
		ConformLineDistance(endPoint, startPoint, endPoint, RangeDo);
		
		static float belowBossEyes[3];
		GetClientEyePosition(client, belowBossEyes);
		belowBossEyes[2] -= 25.0;
		float tmp[3];
		float actualBeamOffset[3];
		tmp[0] = 15.0;
		tmp[1] = -8.0;
		tmp[2] = 0.0;
		float diameter = float(10 * 2);
		int r = 125;
		int g = 125;
		int b = 255;
		VectorRotate(tmp, angles, actualBeamOffset);
		actualBeamOffset[2] = 0.0;
		belowBossEyes[0] += actualBeamOffset[0];
		belowBossEyes[1] += actualBeamOffset[1];
		belowBossEyes[2] += actualBeamOffset[2];
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, 60);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer4, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, endPoint, Shared_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0,  colorLayer4, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, endPoint, g_Ruina_BEAM_Combine_Black, 0, 0, 66, 0.22, ClampBeamWidth(diameter * 0.4 * 1.28), ClampBeamWidth(diameter * 0.4 * 1.28), 0, 1.0,  {255,255,255,125}, 3);
		TE_SendToAll(0.0);

		TE_SetupBeamPoints(belowBossEyes, endPoint, Shared_BEAM_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, colorLayer4, 1);
		TE_SendToAll(0.0);
	}
}


static bool BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}


public void Angelic_ShotgunAbilityM2(int client, int weapon, bool crit, int slot)
{
	if(i_AbilityActiveAngelic[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	switch(i_Current_Pap[client])
	{
		case 2,3:
		{
			if(i_AbilityChargeAngelic[client] < ANGELIC_ABILITY_CHARGE_2)
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "Not Enough Shards");
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}

		}
		case 1:
		{
			if(i_AbilityChargeAngelic[client] < ANGELIC_ABILITY_CHARGE_1)
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "Not Enough Shards");
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}

		}
		default:
		{
			if(i_AbilityChargeAngelic[client] < ANGELIC_ABILITY_CHARGE_0)
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "Not Enough Shards");
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}

		}
	}

	MakePlayerGiveResponseVoice(client, 1); //haha!
	switch(i_Current_Pap[client])
	{
		case 0,1,2,3:
		{
			EmitSoundToAll(ANGELIC_SHOTGUN_ABILTIY_SOUND_1, client, _, 75, _, 0.60);
		}
	}
	//effects below.
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	i_AbilityActiveAngelic[client] = true;
	if(!IsValidEntity(viewmodelModel))
		return;
	
	RestoreOrDestroyAngelicShotgun(client, i_AbilityActiveAngelic[client]);
}



void RestoreOrDestroyAngelicShotgun(int client, bool Activate)
{
	if(!Activate)
	{
		AngelicShotgunRemoveEffects(client);
		return;
	}
	else
	{
		if(!AngelicShotgun_MissingEffects(client))
		{
			return;
		}
	}
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(viewmodelModel))
		return;

	float Amp = 1.0;
	
	if(b_PossesItemTraining[client])
	{
		Amp = 2.5;
	}
	
	AngelicShotgunRemoveEffects(client);

	switch(i_Current_Pap[client])
	{
		case 3:
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "unusual_symbols_parent_ice", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(viewmodelModel, particle, "head");
			i_AngelicShotgunHalo[client][0] = EntIndexToEntRef(particle);


			int red = 200;
			int green = 200;
			int blue = 255;

			int particle_1 = InfoTargetParentAt({0.0,0.0,0.0},"", 0.0); //This is the root bone basically

			int particle_2 = InfoTargetParentAt({0.0,9.0,-9.0},"", 0.0); //First offset we go by
			int particle_3 = InfoTargetParentAt({0.0,9.0,9.0},"", 0.0); //First offset we go by
			int particle_4 = InfoTargetParentAt({0.0,-9.0,9.0},"", 0.0); //First offset we go by
			int particle_5 = InfoTargetParentAt({0.0,-9.0,-9.0},"", 0.0); //First offset we go by

			SetParent(particle_1, particle_2, "",_, true);
			SetParent(particle_1, particle_3, "",_, true);
			SetParent(particle_1, particle_4, "",_, true);
			SetParent(particle_1, particle_5, "",_, true);

			Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
			SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
			SetParent(viewmodelModel, particle_1, "effect_hand_r",_);

			int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, 2.0, 2.0, Amp, LASERBEAM, client);
			int Laser_2 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, 2.0, 2.0, Amp, LASERBEAM, client);
			int Laser_3 = ConnectWithBeamClient(particle_4, particle_5, red, green, blue, 2.0, 1.0, Amp, LASERBEAM, client);
			int Laser_4 = ConnectWithBeamClient(particle_5, particle_2, red, green, blue, 2.0, 1.0, Amp, LASERBEAM, client);
			

			i_AngelicShotgunHalo[client][1] = EntIndexToEntRef(particle_1);
			i_AngelicShotgunHalo[client][2] = EntIndexToEntRef(particle_2);
			i_AngelicShotgunHalo[client][3] = EntIndexToEntRef(particle_3);
			i_AngelicShotgunHalo[client][4] = EntIndexToEntRef(particle_4);
			i_AngelicShotgunHalo[client][5] = EntIndexToEntRef(particle_5);
			i_AngelicShotgunHalo[client][6] = EntIndexToEntRef(Laser_1);
			i_AngelicShotgunHalo[client][7] = EntIndexToEntRef(Laser_2);
			i_AngelicShotgunHalo[client][8] = EntIndexToEntRef(Laser_3);
			i_AngelicShotgunHalo[client][9] = EntIndexToEntRef(Laser_4);

			//Broken 2nd halo
			red = 100;
			green = 100;
			blue = 200;
			int particle_1_2 = InfoTargetParentAt({0.0,0.0,0.0},"", 0.0); //This is the root bone basically

			int particle_2_2 = InfoTargetParentAt({-12.0,12.0,2.0},"", 0.0); //First offset we go by
			int particle_3_2 = InfoTargetParentAt({12.0,12.0,-2.0},"", 0.0); //First offset we go by
			int particle_4_2 = InfoTargetParentAt({9.0,-9.0,0.0},"", 0.0); //First offset we go by
			int particle_5_2 = InfoTargetParentAt({-9.0,-9.0,0.0},"", 0.0); //First offset we go by

			SetParent(particle_1_2, particle_2_2, "",_, true);
			SetParent(particle_1_2, particle_3_2, "",_, true);
			SetParent(particle_1_2, particle_4_2, "",_, true);
			SetParent(particle_1_2, particle_5_2, "",_, true);

			Custom_SDKCall_SetLocalOrigin(particle_1_2, flPos);
			SetEntPropVector(particle_1_2, Prop_Data, "m_angRotation", flAng); 
			SetParent(viewmodelModel, particle_1_2, "head",_);

			int Laser_1_2 = ConnectWithBeamClient(particle_2_2, particle_3_2, red, green, blue, 2.0, 2.0, Amp, LASERBEAM, client);
			int Laser_2_2 = ConnectWithBeamClient(particle_3_2, particle_4_2, red, green, blue, 2.0, 2.0, Amp, LASERBEAM, client);
			int Laser_3_2 = ConnectWithBeamClient(particle_4_2, particle_5_2, red, green, blue, 2.0, 1.0, Amp, LASERBEAM, client);
			int Laser_4_2 = ConnectWithBeamClient(particle_5_2, particle_2_2, red, green, blue, 2.0, 1.0, Amp, LASERBEAM, client);

			i_AngelicShotgunHalo[client][10] = EntIndexToEntRef(particle_1_2);
			i_AngelicShotgunHalo[client][11] = EntIndexToEntRef(particle_2_2);
			i_AngelicShotgunHalo[client][12] = EntIndexToEntRef(particle_3_2);
			i_AngelicShotgunHalo[client][13] = EntIndexToEntRef(particle_4_2);
			i_AngelicShotgunHalo[client][14] = EntIndexToEntRef(particle_5_2);
			i_AngelicShotgunHalo[client][15] = EntIndexToEntRef(Laser_1_2);
			i_AngelicShotgunHalo[client][16] = EntIndexToEntRef(Laser_2_2);
			i_AngelicShotgunHalo[client][17] = EntIndexToEntRef(Laser_3_2);
			i_AngelicShotgunHalo[client][18] = EntIndexToEntRef(Laser_4_2);
		}
		case 2:
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "unusual_symbols_parent_ice", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(viewmodelModel, particle, "head");
			i_AngelicShotgunHalo[client][0] = EntIndexToEntRef(particle);


			int red = 200;
			int green = 200;
			int blue = 255;
			int particle_1 = InfoTargetParentAt({0.0,0.0,0.0},"", 0.0); //This is the root bone basically

			int particle_2 = InfoTargetParentAt({0.0,9.0,-9.0},"", 0.0); //First offset we go by
			int particle_3 = InfoTargetParentAt({0.0,9.0,9.0},"", 0.0); //First offset we go by
			int particle_4 = InfoTargetParentAt({0.0,-9.0,9.0},"", 0.0); //First offset we go by
			int particle_5 = InfoTargetParentAt({0.0,-9.0,-9.0},"", 0.0); //First offset we go by

			SetParent(particle_1, particle_2, "",_, true);
			SetParent(particle_1, particle_3, "",_, true);
			SetParent(particle_1, particle_4, "",_, true);
			SetParent(particle_1, particle_5, "",_, true);

			Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
			SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
			SetParent(viewmodelModel, particle_1, "effect_hand_r",_);

			int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, 2.0, 2.0, Amp, LASERBEAM, client);
			int Laser_2 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, 2.0, 2.0, Amp, LASERBEAM, client);
			int Laser_3 = ConnectWithBeamClient(particle_4, particle_5, red, green, blue, 2.0, 1.0, Amp, LASERBEAM, client);
			int Laser_4 = ConnectWithBeamClient(particle_5, particle_2, red, green, blue, 2.0, 1.0, Amp, LASERBEAM, client);
			

			i_AngelicShotgunHalo[client][1] = EntIndexToEntRef(particle_1);
			i_AngelicShotgunHalo[client][2] = EntIndexToEntRef(particle_2);
			i_AngelicShotgunHalo[client][3] = EntIndexToEntRef(particle_3);
			i_AngelicShotgunHalo[client][4] = EntIndexToEntRef(particle_4);
			i_AngelicShotgunHalo[client][5] = EntIndexToEntRef(particle_5);
			i_AngelicShotgunHalo[client][6] = EntIndexToEntRef(Laser_1);
			i_AngelicShotgunHalo[client][7] = EntIndexToEntRef(Laser_2);
			i_AngelicShotgunHalo[client][8] = EntIndexToEntRef(Laser_3);
			i_AngelicShotgunHalo[client][9] = EntIndexToEntRef(Laser_4);
		}
		case 1:
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "unusual_symbols_parent_ice", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(viewmodelModel, particle, "head");
			i_AngelicShotgunHalo[client][0] = EntIndexToEntRef(particle);
		}
	}

}


bool AngelicShotgun_MissingEffects(int client)
{
	for(int loop = 0; loop<LoopAmountEffects(client); loop++)
	{
		int entity = EntRefToEntIndex(i_AngelicShotgunHalo[client][loop]);
		if(!IsValidEntity(entity))
		{
			return true;
		}
	}
	return false;
}

void AngelicShotgunRemoveEffects(int client)
{
	for(int loop = 0; loop<20; loop++)
	{
		int entity = EntRefToEntIndex(i_AngelicShotgunHalo[client][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_AngelicShotgunHalo[client][loop] = INVALID_ENT_REFERENCE;
	}
}

int LoopAmountEffects(int client)
{
	switch(i_Current_Pap[client])
	{
		case 3:
			return 19;
		case 2:
			return 10;
		case 1:
			return 1;
		default:
			return 0;
	}
}