#pragma semicolon 1
#pragma newdecls required

static Handle LockDownTimer[MAXPLAYERS] = {null, ...};
static int Key_HitEntities[MAXENTITIES];
static float KeyofOrdered_charges[MAXPLAYERS];
static float KeyofOrdered_charges_Max[MAXPLAYERS];
static int i_Current_Pap[MAXPLAYERS];
static float fl_hud_timer[MAXPLAYERS];
static float KeyofOrdered_duration[MAXPLAYERS];
static float Passive_delay[MAXPLAYERS];
static float f3_LastGravitonHitLoc[MAXPLAYERS][3];

static int g_Laser;

static const char Energy_Sound[][] = {
	"weapons/physcannon/energy_sing_flyby1.wav",
	"weapons/physcannon/energy_sing_flyby2.wav"
};

public void LockDown_Wand_MapStart()
{
	PrecacheSound("misc/halloween/clock_tick.wav", true);
	PrecacheSoundCustom("baka_zr/keyofordered_1.mp3");
	PrecacheSoundCustom("baka_zr/keyofordered_2.mp3");
	PrecacheSoundArray(Energy_Sound);
	g_Laser = PrecacheModel(LASERBEAM);

	Zero(fl_hud_timer);
	Zero(Key_HitEntities);
	Zero(KeyofOrdered_duration);
	Zero(KeyofOrdered_charges);
	Zero(KeyofOrdered_charges_Max);
	Zero(LockDownTimer);
	Zero(Passive_delay);
}

public void LockDown_Enable(int client, int weapon)
{
	if(LockDownTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_LOCKDOWN)
		{
			i_Current_Pap[client] = RoundToFloor(Attributes_Get(weapon, 122, 0.0));
			delete LockDownTimer[client];
			LockDownTimer[client] = null;
			DataPack pack;
			LockDownTimer[client] = CreateDataTimer(0.1, Timer_LockDown_Wand, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
	else if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LOCKDOWN)
	{
		i_Current_Pap[client] = RoundToFloor(Attributes_Get(weapon, 122, 0.0));
		DataPack pack;
		LockDownTimer[client] = CreateDataTimer(0.1, Timer_LockDown_Wand, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_LockDown_Wand(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		LockDownTimer[client] = null;
		return Plugin_Stop;
	}

	float GameTime = GetGameTime();
	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		if(i_Current_Pap[client]>=1)
		{
			LockDown_Wand_Hud(client, GameTime);
			
			KeyofOrdered_charges_Max[client]=110*(1.0/Attributes_Get(weapon, 41, 1.0));
			if(KeyofOrdered_charges[client] < KeyofOrdered_charges_Max[client])KeyofOrdered_charges[client] += 0.1;
			if(KeyofOrdered_charges[client] > KeyofOrdered_charges_Max[client])KeyofOrdered_charges[client] = KeyofOrdered_charges_Max[client];
			if(i_Current_Pap[client]>=2 && Passive_delay[client] < GameTime)
			{
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
					if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
					{
						ApplyStatusEffect(client, entity, "Subjective Time Dilation", 1.0);
					}
				}
			}
		}

	}

	return Plugin_Continue;
}

public void LockDown_Wand_Secondary_Attack(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(400.0*Mana_Regen_Level[client]);

	if(mana_cost <= Current_Mana[client])
	{
		if(KeyofOrdered_charges[client] >= KeyofOrdered_charges_Max[client] && KeyofOrdered_charges[client] != 0.0)
		{
			float duration = 23.0;
			Rogue_OnAbilityUse(client, weapon);
			KeyofOrdered_duration[client]= GetGameTime() + float(i_Current_Pap[client]) + duration;
			Current_Mana[client]=0;
			KeyofOrdered_charges[client]=0.0;
			SDKhooks_SetManaRegenDelayTime(client, 0.1);
			float EntLoc[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
			SpawnSmallExplosion(EntLoc);
			int particle_power = ParticleEffectAt(EntLoc, "teleporter_blue_wisps_level3", float(i_Current_Pap[client]) + (duration-0.5));
			SetParent(client, particle_power);
			particle_power = ParticleEffectAt(EntLoc, "utaunt_mysticfusion_parent", float(i_Current_Pap[client]) + duration);
			SetParent(client, particle_power);
			EmitSoundToAll("misc/halloween/clock_tick.wav", client, SNDCHAN_AUTO, 75,_,0.8,80);
			DataPack pack;
			CreateDataTimer(float(i_Current_Pap[client]) + duration, Secondary_Is_End, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Not enough energy");
			return;
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
}

public void LockDown_Wand_Primary_Attack(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(KeyofOrdered_duration[client] >= GetGameTime())
	{
		mana_cost = RoundToCeil((400.0*Mana_Regen_Level[client])*0.75);
		if(mana_cost <= Current_Mana[client])
		{
			float Range = 1250.0;
			Current_Mana[client] -= mana_cost;
			SDKhooks_SetManaRegenDelayTime(client, 3.0);
			Range *= Attributes_Get(weapon, 103, 1.0);
			Range *= Attributes_Get(weapon, 104, 1.0);
			Range *= Attributes_Get(weapon, 475, 1.0);
			Range *= Attributes_Get(weapon, 101, 1.0);
			Range *= Attributes_Get(weapon, 102, 1.0);

			float damage = 500.0;
				
			damage *= Attributes_Get(weapon, 410, 1.0);
			
			damage *= 1.25;
		
			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteFloat(damage);
			pack.WriteFloat(Range);
			RequestFrames(Laser_Key_of_Ordered, 12, pack);
			EmitSoundToAll("baka_zr/keyofordered_1.mp3", client, SNDCHAN_AUTO, 75,_,1.0,100);
			float Time=GetGameTime();
			CreateTimer(2.2, KeyofOrdered_Is_Back, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", Time+3.0);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", Time+3.0);
			return;
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
			return;
		}
	}
	
	if(mana_cost <= Current_Mana[client])
	{
		bool WeakerCast = false;
		float Range = 750.0;
		float Radius = 100.0;
		Current_Mana[client] -=mana_cost;
		SDKhooks_SetManaRegenDelayTime(client, 2.0);
		Range *= Attributes_Get(weapon, 103, 1.0);
		Range *= Attributes_Get(weapon, 104, 1.0);
		Range *= Attributes_Get(weapon, 475, 1.0);
		Range *= Attributes_Get(weapon, 101, 1.0);
		Range *= Attributes_Get(weapon, 102, 1.0);

		Radius *= Attributes_Get(weapon, 103, 1.0);
		Radius *= Attributes_Get(weapon, 104, 1.0);
		Radius *= Attributes_Get(weapon, 475, 1.0);
		Radius *= Attributes_Get(weapon, 101, 1.0);
		Radius *= Attributes_Get(weapon, 102, 1.0);

		float damage = 250.0;
			
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		damage *= 1.25;
		
		float vec[3];

		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Range, false, 45.0, true); //infinite range, and ignore walls!

		int target = TR_GetEntityIndex(swingTrace);	
		if(IsValidEnemy(client, target))
		{
			WorldSpaceCenter(target, vec);
		}
		else
		{
			delete swingTrace;
			int MaxTargethit = -1;
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Range, false, 45.0, true,MaxTargethit); //infinite range, and ignore walls!
			TR_GetEndPosition(vec, swingTrace);
		}
		FinishLagCompensation_Base_boss();
		delete swingTrace;

		float distance = GetVectorDistance(f3_LastGravitonHitLoc[client], vec);

		if(distance < 30.0)
		{
			WeakerCast = true;
			damage *= 0.5;
		}
		f3_LastGravitonHitLoc[client] = vec;

		int color[4];
		color[0] = 240;
		color[1] = 240;
		color[2] = 240;
		color[3] = 120;

		if(WeakerCast)
		{
			color[3] = 60;
		}

		int viewmodelModel;
		viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

		if(IsValidEntity(viewmodelModel))
		{
			float fPos[3], fAng[3];
			GetAttachment(viewmodelModel, "effect_hand_l", fPos, fAng);
			TE_SetupBeamPoints(fPos, vec, g_Laser, 0, 0, 0, 0.25, 2.5, 2.5, 1, 4.0, color, 0);
			TE_SendToAll();
		}
		else
		{
			float pos[3];
			GetClientEyePosition(client, pos);
			TE_SetupBeamPoints(pos, vec, g_Laser, 0, 0, 0, 0.25, 2.5, 2.5, 1, 4.0, color, 0);
			TE_SendToAll();
		}
		
		Explode_Logic_Custom(damage, client, client, weapon, vec, Radius,_,_,_,i_Current_Pap[client]+3, _, 1.0, UGotSlowDown);
		vec[2]+=20.0;
		ParticleEffectAt(vec, "utaunt_wispyworks_yellowpurple_head", 0.35);
		ParticleEffectAt(vec, "eyeboss_vortex_blue", 1.0);
		ParticleEffectAt(vec, "projectile_fireball_crit_blue_trail", 0.2);
		EmitSoundToAll(Energy_Sound[GetRandomInt(0, sizeof(Energy_Sound)-1)], 0, SNDCHAN_STATIC, 80, _, 1.0, SNDPITCH_NORMAL, -1, vec);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public Action KeyofOrdered_Is_Back(Handle timer, int ref)
{
	int client = GetClientOfUserId(ref);
	if(IsValidClient(client))
		EmitSoundToAll("baka_zr/keyofordered_2.mp3", client, SNDCHAN_AUTO, 75,_,1.0,100);
	return Plugin_Stop;
}

public Action Secondary_Is_End(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client))
	{
		Current_Mana[client]=0;
		KeyofOrdered_charges[client]=0.0;
		SDKhooks_SetManaRegenDelayTime(client, 5.0);
		float Time=GetGameTime();
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", Time+3.0);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", Time+3.0);
		Passive_delay[client] = Time + 3.0;
	}
	return Plugin_Stop;
}

void UGotSlowDown(int attacker, int victim, float damage, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	ApplyStatusEffect(attacker, victim, "Slowdown", 3.0);
}

static void LockDown_Wand_Hud(int client, float GameTime)
{
	if(fl_hud_timer[client] > GameTime)
	{
		return;
	}
	fl_hud_timer[client] = GameTime+0.5;

	char HUDText[255] = "";

	if(KeyofOrdered_duration[client] < GameTime)
	{
		if(KeyofOrdered_charges[client] >= KeyofOrdered_charges_Max[client])
			Format(HUDText, sizeof(HUDText), "%sKey of Ordered Ready!", HUDText);
		else
			Format(HUDText, sizeof(HUDText), "%sKey of Ordered Charges: [%.1f/%.1f]", HUDText, KeyofOrdered_charges[client], KeyofOrdered_charges_Max[client]);
	}
	else
	{
		int Mana_Max = RoundToCeil(400.0*Mana_Regen_Level[client]);
		float Duration = KeyofOrdered_duration[client]-GameTime;
		Format(HUDText, sizeof(HUDText), "%sKey of Ordered Active! [%.1f]", HUDText, Duration);
		if(Current_Mana[client] < Mana_Max)
		{
			Current_Mana[client]+=RoundToCeil(float(Mana_Max)*0.15);
			if(Current_Mana[client] > Mana_Max) Current_Mana[client]=Mana_Max;
		}
	}
	

	PrintHintText(client, HUDText);

	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}

stock bool IsAbleToSee(int client, int target, float angle=90.0, float distance=0.0)
{
    // Skip all traces if the player isn't within the field of view.
    // - Temporarily disabled until eye angle prediction is added.
    // if (IsInFieldOfView(g_vEyePos[client], g_vEyeAngles[client], g_vAbsCentre[entity]))
    
	if (IsTargetInSightRange(client, target, angle, distance))
	{
		float vecOrigin[3], vecEyePos[3];
		GetClientAbsOrigin(client, vecOrigin);
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", vecEyePos);
		vecEyePos[2]+=10.0;
		
		// Check if centre is visible.
		if (IsPointVisible(vecEyePos, vecOrigin))
		{
			return true;
		}
		
		float vecEyePos_ent[3], vecEyeAng[3];
		GetClientEyeAngles(client, vecEyeAng);
		GetClientEyePosition(client, vecEyePos_ent);
		// Check if weapon tip is visible.
		if (IsFwdVecVisible(vecEyePos, vecEyeAng, vecEyePos_ent))
		{
			return true;
		}
		
		float mins[3], maxs[3];
		GetEntPropVector(target, Prop_Send, "m_vecMins", mins);
		GetEntPropVector(target, Prop_Send, "m_vecMaxs", maxs);
		// Check outer 4 corners of player.
		if (IsRectangleVisible(vecEyePos, vecOrigin, mins, maxs, 1.30))
		{
			return true;
		}

		// Check inner 4 corners of player.
		if (IsRectangleVisible(vecEyePos, vecOrigin, mins, maxs, 0.65))
		{
			return true;
		}
		
		return false;
	}
	return false;
}

bool IsRectangleVisible(const float start[3], const float end[3], const float mins[3], const float maxs[3], float scale=1.0)
{
    float ZpozOffset = maxs[2];
    float ZnegOffset = mins[2];
    float WideOffset = ((maxs[0] - mins[0]) + (maxs[1] - mins[1])) / 4.0;

    // This rectangle is just a point!
    if (ZpozOffset == 0.0 && ZnegOffset == 0.0 && WideOffset == 0.0)
    {
        return IsPointVisible(start, end);
    }

    // Adjust to scale.
    ZpozOffset *= scale;
    ZnegOffset *= scale;
    WideOffset *= scale;
    
    // Prepare rotation matrix.
    float angles[3], fwd[3], right[3];

    SubtractVectors(start, end, fwd);
    NormalizeVector(fwd, fwd);

    GetVectorAngles(fwd, angles);
    GetAngleVectors(angles, fwd, right, NULL_VECTOR);

    float vRectangle[4][3], vTemp[3];

    // If the player is on the same level as us, we can optimize by only rotating on the z-axis.
    if (FloatAbs(fwd[2]) <= 0.7071)
    {
        ScaleVector(right, WideOffset);
        
        // Corner 1, 2
        vTemp = end;
        vTemp[2] += ZpozOffset;
        AddVectors(vTemp, right, vRectangle[0]);
        SubtractVectors(vTemp, right, vRectangle[1]);
        
        // Corner 3, 4
        vTemp = end;
        vTemp[2] += ZnegOffset;
        AddVectors(vTemp, right, vRectangle[2]);
        SubtractVectors(vTemp, right, vRectangle[3]);
        
    }
    else if (fwd[2] > 0.0) // Player is below us.
    {
        fwd[2] = 0.0;
        NormalizeVector(fwd, fwd);
        
        ScaleVector(fwd, scale);
        ScaleVector(fwd, WideOffset);
        ScaleVector(right, WideOffset);
        
        // Corner 1
        vTemp = end;
        vTemp[2] += ZpozOffset;
        AddVectors(vTemp, right, vTemp);
        SubtractVectors(vTemp, fwd, vRectangle[0]);
        
        // Corner 2
        vTemp = end;
        vTemp[2] += ZpozOffset;
        SubtractVectors(vTemp, right, vTemp);
        SubtractVectors(vTemp, fwd, vRectangle[1]);
        
        // Corner 3
        vTemp = end;
        vTemp[2] += ZnegOffset;
        AddVectors(vTemp, right, vTemp);
        AddVectors(vTemp, fwd, vRectangle[2]);
        
        // Corner 4
        vTemp = end;
        vTemp[2] += ZnegOffset;
        SubtractVectors(vTemp, right, vTemp);
        AddVectors(vTemp, fwd, vRectangle[3]);
    }
    else // Player is above us.
    {
        fwd[2] = 0.0;
        NormalizeVector(fwd, fwd);
        
        ScaleVector(fwd, scale);
        ScaleVector(fwd, WideOffset);
        ScaleVector(right, WideOffset);

        // Corner 1
        vTemp = end;
        vTemp[2] += ZpozOffset;
        AddVectors(vTemp, right, vTemp);
        AddVectors(vTemp, fwd, vRectangle[0]);
        
        // Corner 2
        vTemp = end;
        vTemp[2] += ZpozOffset;
        SubtractVectors(vTemp, right, vTemp);
        AddVectors(vTemp, fwd, vRectangle[1]);
        
        // Corner 3
        vTemp = end;
        vTemp[2] += ZnegOffset;
        AddVectors(vTemp, right, vTemp);
        SubtractVectors(vTemp, fwd, vRectangle[2]);
        
        // Corner 4
        vTemp = end;
        vTemp[2] += ZnegOffset;
        SubtractVectors(vTemp, right, vTemp);
        SubtractVectors(vTemp, fwd, vRectangle[3]);
    }

    // Run traces on all corners.
    for(int i = 0; i < 4; i++)
    {
        if (IsPointVisible(start, vRectangle[i]))
        {
            return true;
        }
    }

    return false;
}

public void Laser_Key_of_Ordered(DataPack pack)
{
	pack.Reset();
	int client = 	GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadFloat();
	float range = pack.ReadFloat();
	if(IsValidClient(client) && IsValidCurrentWeapon(client, weapon))
	{
		//This melee is too unique, we have to code it in a different way.
		static float pos2[3], ang2[3];
		GetClientEyePosition(client, pos2);
		GetClientEyeAngles(client, ang2);
		/*
			Extra effects on bare swing
		*/
		static float AngEffect[3];
		AngEffect = ang2;

		AngEffect[1] -= 90.0;
		int MaxRepeats = 4;
		float Speed = 1500.0;
		int PreviousProjectile;

		for(int repeat; repeat <= MaxRepeats; repeat ++)
		{
			int projectile = Wand_Projectile_Spawn(client, Speed, 99999.9, 0.0, -1, weapon, "", AngEffect);
			DataPack pack2 = new DataPack();
			int laser = projectile;
			if(IsValidEntity(PreviousProjectile))
			{
				laser = ConnectWithBeam(projectile, PreviousProjectile, 111, 153, 242, 10.0, 10.0, 1.0);
			}
			SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
			PreviousProjectile = projectile;
			pack2.WriteCell(EntIndexToEntRef(projectile));
			pack2.WriteCell(EntIndexToEntRef(laser));
			RequestFrames(Key_of_Ordered_DeleteLaserAndParticle, 46, pack2);
			AngEffect[1] += (180.0 / float(MaxRepeats));
		}

		float vecSwingForward[3];
		GetAngleVectors(ang2, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
		ang2[0] = fixAngle(ang2[0]);
		ang2[1] = fixAngle(ang2[1]);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
			
		for(int i=0; i < MAXENTITIES; i++)
		{
			Key_HitEntities[i] = false;
		}
		TR_EnumerateEntitiesSphere(pos2, range, PARTITION_NON_STATIC_EDICTS, TraceKey_of_Ordered, client);

	//	bool Hit = false;
		for (int entity_traced = 0; entity_traced < 8; entity_traced++)
		{
			if(Key_HitEntities[entity_traced] > 0)
			{
				static float ang3[3];

				float pos1[3];
				WorldSpaceCenter(Key_HitEntities[entity_traced], pos1);
				GetVectorAnglesTwoPoints(pos2, pos1, ang3);

				// fix all angles
				ang3[0] = fixAngle(ang3[0]);
				ang3[1] = fixAngle(ang3[1]);

				// verify angle validity
				if(!(fabs(ang2[0] - ang3[0]) <= 90.0 ||
				(fabs(ang2[0] - ang3[0]) >= (360.0-90.0))))
					continue;

				if(!(fabs(ang2[1] - ang3[1]) <= 90.0 ||
				(fabs(ang2[1] - ang3[1]) >= (360.0-90.0))))
					continue;

				// ensure no wall is obstructing
				if(Can_I_See_Enemy_Only(client, Key_HitEntities[entity_traced]))
				{
					// success
			//		Hit = true;
					float damage_force[3]; CalculateDamageForce(vecSwingForward, 100000.0, damage_force);
					SDKHooks_TakeDamage(Key_HitEntities[entity_traced], client, client, damage, DMG_PLASMA, weapon, damage_force, pos1);
					GetEntPropVector(Key_HitEntities[entity_traced], Prop_Send, "m_vecOrigin", damage_force);
					damage_force[2]+=30.0;
					ApplyStatusEffect(client, Key_HitEntities[entity_traced], "Power Slowdown", 2.0);
					/*GetVectorAnglesTwoPoints(pos2, damage_force, ang2);
					static float vel[3];
					GetAngleVectors(ang2, vel, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(vel, 400.0);
					if((GetEntityFlags(Key_HitEntities[entity_traced]) & FL_ONGROUND) && vel[2]<300.0)
						vel[2]=300.0;
					TeleportEntity(Key_HitEntities[entity_traced], NULL_VECTOR, NULL_VECTOR, vel);*/
				}
			}
			else
			{
				break;
			}
		}
		FinishLagCompensation_Base_boss();
	}
	delete pack;
}

public void Key_of_Ordered_DeleteLaserAndParticle(DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Laser = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile))
	{
		int particle = EntRefToEntIndex(i_WandParticle[Projectile]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		
		RemoveEntity(Projectile);
	}
	if(Projectile != Laser)
	{
		if(IsValidEntity(Laser))
			RemoveEntity(Laser);
	}
	delete pack;
}

public bool TraceKey_of_Ordered(int entity, int filterentity)
{
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		//This will automatically take care of all the checks, very handy. force it to also target invul enemies.
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!Key_HitEntities[i])
			{
				Key_HitEntities[i] = entity;
				break;
			}
		}
	}
	//always keep going!
	return true;
}

bool IsPointVisible(const float start[3], const float end[3])
{
    TR_TraceRayFilter(start, end, MASK_VISIBLE, RayType_EndPoint, Filter_NoPlayers);

    return TR_GetFraction() == 1.0;
}

public bool Filter_NoPlayers(int entity, int contentsMask, any data)
{
    return (entity > MaxClients && !(0 < GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") <= MaxClients));
}

bool IsFwdVecVisible(const float start[3], const float angles[3], const float end[3])
{
    float fwd[3];
    
    GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(fwd, 50.0);
    AddVectors(end, fwd, fwd);

    return IsPointVisible(start, fwd);
}

stock bool IsTargetInSightRange(int client, int target, float angle=90.0, float distance=0.0, bool heightcheck=true, bool negativeangle=false)
{
	if(angle > 360.0 || angle < 0.0)
		ThrowError("Angle Max : 360 & Min : 0. %d isn't proper angle.", angle);
	if(!IsValidEntity(target) || !IsValidEntity(client))
		ThrowError("is not Valid Entity");
		
	float clientpos[3], targetpos[3], anglevector[3], targetvector[3], resultangle, resultdistance;
	
	GetClientEyeAngles(client, anglevector);
	anglevector[0] = anglevector[2] = 0.0;
	GetAngleVectors(anglevector, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	if(negativeangle)
		NegateVector(anglevector);

	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", clientpos);
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetpos);
	if(heightcheck && distance > 0)
		resultdistance = GetVectorDistance(clientpos, targetpos);
	clientpos[2] = targetpos[2] = 0.0;
	MakeVectorFromPoints(clientpos, targetpos, targetvector);
	NormalizeVector(targetvector, targetvector);
	
	resultangle = RadToDeg(ArcCosine(GetVectorDotProduct(targetvector, anglevector)));
	
	if(resultangle <= angle/2)	
	{
		if(distance > 0)
		{
			if(!heightcheck)
				resultdistance = GetVectorDistance(clientpos, targetpos);
			if(distance >= resultdistance)
				return true;
			else
				return false;
		}
		else
			return true;
	}
	else
		return false;
}