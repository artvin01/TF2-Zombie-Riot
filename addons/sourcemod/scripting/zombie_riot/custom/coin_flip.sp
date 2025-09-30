#pragma semicolon 1
#pragma newdecls required

#define MODEL_GORDON_PROP "models/roller_spikes.mdl"
#define SOUND_GORDON_MINE_TOSS "weapons/grenade_throw.wav"
#define SOUND_GORDON_MINE_DET	"npc/roller/mine/rmine_explode_shock1.wav"

static const float gf_gordon_propthrowforce	= 900.0;
static const float gf_gordon_propthrowoffset = 90.0;
static int Coin_flip[MAXPLAYERS];
static int particle_1[MAXPLAYERS];
static bool mb_coin[MAXENTITIES];
static bool already_ricocated[MAXENTITIES];
static int Beam_Laser;
static int Entity_Owner[MAXENTITIES];
static float damage_multiplier[MAXENTITIES];
static float f_Thrownrecently[MAXENTITIES];
static float mf_extra_damage[MAXENTITIES];
static int coins_flipped[MAXPLAYERS];

//	if (Ability_Check_Cooldown(client, slot) < 0.0)
//	{
//		Ability_Apply_Cooldown(client, slot, 10.0);
		
// Ability_Check_Cooldown(client, slot);

void CoinEntityCreated(int entity)
{
	mb_coin[entity] = false;
}

public void Ability_Coin_Flip(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Ability_Apply_Cooldown(client, slot, 30.0);
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public void Ability_Coin_Flip2(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 && coins_flipped[client] <= 1)
	{
		coins_flipped[client] += 1;
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
		if(coins_flipped[client] >= 2)
		{
			coins_flipped[client] = 0;
			Ability_Apply_Cooldown(client, slot, 30.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public void Ability_Coin_Flip3(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 && coins_flipped[client] <= 2)
	{
		coins_flipped[client] += 1;
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
		if(coins_flipped[client] >= 3)
		{
			coins_flipped[client] = 0;
			Ability_Apply_Cooldown(client, slot, 30.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}
public void Ability_Coin_Flip4(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 && coins_flipped[client] <= 3)
	{
		coins_flipped[client] += 1;
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
		if(coins_flipped[client] >= 4)
		{
			coins_flipped[client] = 0;
			Ability_Apply_Cooldown(client, slot, 30.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action short_bonus_damage(Handle timer, int ref) 
{
	int entity = EntRefToEntIndex(ref);
	if(entity > 0)
	{
		float chargerPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", chargerPos);
		mf_extra_damage[entity] = GetGameTime() + 0.7; //how much time is given for extra damage to apply for the flash appeared
		ParticleEffectAt(chargerPos, "raygun_projectile_blue_crit", 0.3);
	}
	return Plugin_Stop;
}

public Action Coin_on_for_too_long(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > 0)
	{
		mb_coin[entity] = false;
		Entity_Owner[entity] = 0;
		AcceptEntityInput(entity, "break");
	}
	return Plugin_Stop;
}
public Action Coin_on_ground(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > 0)
	{
		float targPos[3];
		float chargerPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", targPos);
		
		chargerPos[0] = targPos[0];
		chargerPos[1] = targPos[1];
		chargerPos[2] = targPos[2];
		
		chargerPos[2] -= 20.0;
		
		TR_TraceRayFilter(targPos, chargerPos, MASK_SHOT, RayType_EndPoint, HitOnlyWorld, entity);
		if (TR_DidHit())
		{
			AcceptEntityInput(entity, "break");
			return Plugin_Stop;
		}
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}




public Action flip_extra(Handle timer, int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) != TFWeaponSlot_Melee)
	{
		
		float fPlayerPos[3];
		float fPlayerAngles[3];
		float fThrowingVector[3];
		
		GetClientEyeAngles( client, fPlayerAngles );
		GetClientEyePosition( client, fPlayerPos );

		fPlayerAngles[0] += GetRandomFloat(-5.0, 5.0);
		fPlayerAngles[1] += GetRandomFloat(-5.0, 5.0);
	
		float fLen = gf_gordon_propthrowoffset * Sine( DegToRad( fPlayerAngles[0] + 90.0 ) );
		
		int entity = CreateEntityByName( "prop_physics_multiplayer" );
		if(entity != -1)
		{
			AddEntityToLagCompList(entity);
			b_DoNotIgnoreDuringLagCompAlly[entity] = true;
			Entity_Owner[entity] = client;
			f_Thrownrecently[entity] = GetGameTime () + 0.35;

			fPlayerPos[0] = fPlayerPos[0] + fLen * Cosine( DegToRad( fPlayerAngles[1] + 0.0) );
			fPlayerPos[1] = fPlayerPos[1] + fLen * Sine( DegToRad( fPlayerAngles[1] + 0.0) );
			fPlayerPos[2] = fPlayerPos[2] + gf_gordon_propthrowoffset * Sine( DegToRad( -1 * (fPlayerAngles[0] + 0.0)) );
		
			DispatchKeyValue(entity, "model", MODEL_GORDON_PROP);
			DispatchKeyValue(entity, "massScale", "0.1");
			DispatchKeyValue(entity, "disableshadows", "1");
			DispatchKeyValue( entity, "solid", "6");
			DispatchKeyValue( entity, "spawnflags", "12288");
			
			DispatchSpawn(entity);
			ActivateEntity(entity);

			SetEntProp(entity, Prop_Send, "m_usSolidFlags", 8);			// Fire trigger even if not solid (8)
			
			DispatchKeyValueFloat(entity, "modelscale", 0.65);
		
			Coin_flip[client] = EntIndexToEntRef(entity);
			mb_coin[entity] = true;
			
			SetTeam(entity, TFTeam_Spectator);
			
			SDKHook(entity, SDKHook_OnTakeDamage, Coin_HookDamaged);
			
			CreateTimer(3.0, Coin_on_for_too_long, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			
			CreateTimer(0.1, Coin_on_ground, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			float fScal = gf_gordon_propthrowforce * Sine( DegToRad( fPlayerAngles[0] + 90.0 ) );

			fThrowingVector[0] = fScal * Cosine( DegToRad( fPlayerAngles[1] ) );
			fThrowingVector[1] = fScal * Sine( DegToRad( fPlayerAngles[1] ) );
			fThrowingVector[2] = gf_gordon_propthrowforce * Sine( DegToRad( -1 * fPlayerAngles[0] ) );
			
			CreateTimer(0.33, short_bonus_damage, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			
			float newVel[3];
			
			damage_multiplier[entity] = 40.0;
			
			damage_multiplier[entity] *= Attributes_Get(weapon, 2, 1.0);
				
			damage_multiplier[entity] *= 2.0;
			damage_multiplier[entity] *= 1.4;
			
			if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
			{
				damage_multiplier[entity] *= 1.25;
			}
			
			if(i_HeadshotAffinity[client] == 1)
			{
				damage_multiplier[entity] *= 1.20;
			}
			
			newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
			newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
			newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
							
			for (int i = 0; i < 3; i++)
			{
				fThrowingVector[i] += newVel[i];
			}

			TeleportEntity( entity, fPlayerPos, fPlayerAngles, fThrowingVector );
			
			
			int trail = Trail_Attach(entity, ARROW_TRAIL_RED, 255, 0.3, 3.0, 3.0, 5);
					
			particle_1[client] = EntIndexToEntRef(trail);
					
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
			
			SetParent(entity, particle_1[client]);
			
			EmitSoundToAll(SOUND_GORDON_MINE_TOSS, entity);
		}
	}
	return Plugin_Handled;
}
/*
public Action coin_land_detection(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int entity = EntRefToEntIndex(Coin_flip[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			if(GetEntProp(entity, Prop_Send, "m_bTouched"))
			{
				AcceptEntityInput(entity, "break");
    			PrintToChatAll("collision2");
			}
		}
	}
}

*/
public Action coin_got_rioceted(Handle timer, int client)
{
	int victim = EntRefToEntIndex(client);
	
	if (IsValidEntity(victim))
	{
		float chargerPos[3];
		
		already_ricocated[victim] = false;
		
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", -1, _, _, _, _, _, _, chargerPos);
			}
			case 2:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet2.wav", -1, _, _, _, _, _, _, chargerPos);
			}
			case 3:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet3.wav", -1, _, _, _, _, _, _, chargerPos);
			}
		}
		
		Do_Coin_calc(victim);
		
		Entity_Owner[victim] = 0;
		mb_coin[victim] = false;
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		ParticleEffectAt(chargerPos, "raygun_projectile_red_crit", 0.3);
		SetEntityMoveType(victim, MOVETYPE_NONE);
		AcceptEntityInput(victim, "break");
	}
	return Plugin_Handled;
}

public Action Coin_HookDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
//	if(GetTeam(victim) != GetTeam(attacker))
//		return Plugin_Continue;
		
	//Valid attackers only.
	if(attacker < 0)
		return Plugin_Continue;
	
	if (Entity_Owner[victim] != attacker)
		return Plugin_Continue;
		
	
//	damage_multiplier[victim] = damage_multiplier[inflictor] * 3.0;

	SetEntityMoveType(victim, MOVETYPE_NONE);
	
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(attacker));
	pack.WriteCell(EntIndexToEntRef(victim));
	RequestFrame(DoCoinCalcFrameLater, pack);
	
	return Plugin_Handled;
}

void DoCoinCalcFrameLater(DataPack pack)
{
	pack.Reset();
	int attacker = EntRefToEntIndex(pack.ReadCell());
	int victim = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(attacker) && IsValidEntity(victim))
	{
		float targPos[3];
		float chargerPos[3];
		float flAng_l[3];
		
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker);
			}
			case 2:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker);
			}
			case 3:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker);
			}
		}
		
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		
		GetAttachment(attacker, "effect_hand_R", targPos, flAng_l);
		
		TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 3.0, 5.0, 1, 1.0, view_as<int>({160, 160, 255, 255}), 30);
		TE_SendToAll();
										
		
		already_ricocated[victim] = false;
		
		Do_Coin_calc(victim);
				
		Entity_Owner[victim] = 0;
		mb_coin[victim] = false;
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		ParticleEffectAt(chargerPos, "raygun_projectile_red_crit", 0.3);
		AcceptEntityInput(victim, "break");
	}
	delete pack;
}


stock void Do_Coin_calc(int victim)
{
	float targPos[3];
	float chargerPos[3];
		
	SetTeam(victim, TFTeam_Red);
	int Closest_entity = GetClosestTarget_Coin(victim);
	SetTeam(victim, TFTeam_Spectator);
	if(mf_extra_damage[victim] > GetGameTime()) //You got one second.
	{
		damage_multiplier[victim] *= 1.20;
		float chargerPos2[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos2);
		if(IsValidClient(Entity_Owner[victim]))
		{
			DisplayCritAboveNpc(victim, Entity_Owner[victim], true,chargerPos2,_,true); //Display minicrit
		}
	}
	if (IsValidEntity(Closest_entity))
	{
		if(f_Thrownrecently[victim] > GetGameTime())
		{
			damage_multiplier[victim] *= 0.25;
		}
		damage_multiplier[Closest_entity] = damage_multiplier[victim]; //Extra bonus dmg
		
		static char classname[36];
		GetEntityClassname(Closest_entity, classname, sizeof(classname));
		if (mb_coin[Closest_entity] && !StrContains(classname, "prop_physics_multiplayer", true))
		{
			SetEntityMoveType(Closest_entity, MOVETYPE_NONE);
			GetEntPropVector(Closest_entity, Prop_Data, "m_vecAbsOrigin", chargerPos);
			ParticleEffectAt(chargerPos, "raygun_projectile_red_crit", 0.3);
			
			GetEntPropVector(Closest_entity, Prop_Data, "m_vecAbsOrigin", targPos);
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
			if (GetVectorDistance(chargerPos, targPos) <= 1200.0 && !already_ricocated[victim] && Closest_entity != victim)
			{
				//increase damage.
				damage_multiplier[victim] *= 1.65;
				already_ricocated[victim] = true;
				damage_multiplier[Closest_entity] = damage_multiplier[victim]; //Extra bonus dmg
				CreateTimer(0.05, coin_got_rioceted, EntIndexToEntRef(Closest_entity), TIMER_FLAG_NO_MAPCHANGE);
				mb_coin[Closest_entity] = false;
				
				TR_TraceRayFilter( chargerPos, targPos, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, WorldOnly, victim );
				if(TR_DidHit())
				{
					int target = TR_GetEntityIndex();	
					if ( target != Closest_entity && b_ThisWasAnNpc[target] && (GetTeam(target) != GetTeam(victim)))
					{
						SDKHooks_TakeDamage(target, victim, Entity_Owner[victim], damage_multiplier[victim], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
					}
					TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 3.0, 5.0, 1, 1.0, view_as<int>({255, 0, 0, 255}), 30);
					TE_SendToAll();
				}
				else
				{
					TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 3.0, 5.0, 1, 1.0, view_as<int>({160, 160, 255, 255}), 30);
					TE_SendToAll();
				}
			}
			else
			{
				if (IsValidEntity(Closest_entity))
				{
					
					if (b_ThisWasAnNpc[Closest_entity] && (GetTeam(Closest_entity) != GetTeam(victim)))
					{
						GetEntPropVector(Closest_entity, Prop_Data, "m_vecAbsOrigin", targPos);
						targPos[2] += 35;
						GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
						if (GetVectorDistance(chargerPos, targPos) <= 1300.0 && !already_ricocated[victim])
						{
							already_ricocated[victim] = true;
							TR_TraceRayFilter( chargerPos, targPos, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, WorldOnly, victim );
							if(TR_DidHit())
							{
								int target = TR_GetEntityIndex();	
								if ( target != Closest_entity && b_ThisWasAnNpc[target] && (GetTeam(target) != GetTeam(victim)))
								{
									SDKHooks_TakeDamage(target, victim, Entity_Owner[victim], damage_multiplier[victim], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
								}
								TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 3.0, 5.0, 1, 1.0, view_as<int>({255, 0, 0, 255}), 30);
								TE_SendToAll();
							}
							else
							{
								TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 3.0, 5.0, 1, 1.0, view_as<int>({160, 160, 255, 255}), 30);
								TE_SendToAll();
							}
							
							EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
							EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
							
							DataPack pack_boom = new DataPack();
							pack_boom.WriteFloat(targPos[0]);
							pack_boom.WriteFloat(targPos[1]);
							pack_boom.WriteFloat(targPos[2]);
							pack_boom.WriteCell(0);
							RequestFrame(MakeExplosionFrameLater, pack_boom);
				
							SDKHooks_TakeDamage(Closest_entity, victim, Entity_Owner[victim], damage_multiplier[victim], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
						}
					}
				}
			}
		}
		else
		{
			if (IsValidEntity(Closest_entity))
			{
				if (b_ThisWasAnNpc[Closest_entity] && (GetTeam(Closest_entity) != GetTeam(victim)))
				{
					GetEntPropVector(Closest_entity, Prop_Data, "m_vecAbsOrigin", targPos);
					targPos[2] += 35;
					GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
					if (GetVectorDistance(chargerPos, targPos) <= 1300.0 && !already_ricocated[victim])
					{
						already_ricocated[victim] = true;
						TR_TraceRayFilter( chargerPos, targPos, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, WorldOnly, victim );
						if(TR_DidHit())
						{
							int target = TR_GetEntityIndex();	
							if ( target != Closest_entity && b_ThisWasAnNpc[target] && (GetTeam(target) != GetTeam(victim)))
							{
								SDKHooks_TakeDamage(target, victim, Entity_Owner[victim], damage_multiplier[victim], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
							}
							TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 3.0, 5.0, 1, 1.0, view_as<int>({255, 0, 0, 255}), 30);
							TE_SendToAll();
						}
						else
						{
							TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 3.0, 5.0, 1, 1.0, view_as<int>({160, 160, 255, 255}), 30);
							TE_SendToAll();
						}
						
						EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
						EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
						
						DataPack pack_boom = new DataPack();
						pack_boom.WriteFloat(targPos[0]);
						pack_boom.WriteFloat(targPos[1]);
						pack_boom.WriteFloat(targPos[2]);
						pack_boom.WriteCell(0);
						RequestFrame(MakeExplosionFrameLater, pack_boom);
							
						SDKHooks_TakeDamage(Closest_entity, victim, Entity_Owner[victim], damage_multiplier[victim], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
					}
				}
			}
		}
		mb_coin[victim] = false;
	}
}
/*
public Action Coin_HookTouch(int entity, int other)
{
	if(other == 0)
	{
		mb_coin[entity] = false;
	//	AcceptEntityInput(entity, "break");
		PrintToChatAll("collision2");
		return Plugin_Continue;
    }
}
*/
void Abiltity_Coin_Flip_Map_Change()
{
	PrecacheSound(SOUND_GORDON_MINE_TOSS, true);
	PrecacheSound(SOUND_GORDON_MINE_DET, true);
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav", true);
	PrecacheSound("physics/metal/metal_box_impact_bullet2.wav", true);
	PrecacheSound("physics/metal/metal_box_impact_bullet3.wav", true);
	
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Zero(coins_flipped);
//	PrecacheSound("weapons/shotgun/shotgun_cock.wav", true);
}

stock int GetClosestTarget_Coin(int entity)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	int Health = 0;

	for(int new_entity=1; new_entity <= MAXENTITIES; new_entity++)
	{
		if (IsValidEntity(new_entity))
		{
			static char classname[36];
			GetEntityClassname(new_entity, classname, sizeof(classname));
			if (mb_coin[new_entity] && !StrContains(classname, "prop_physics_multiplayer", false) && entity != new_entity && Entity_Owner[entity] == Entity_Owner[new_entity])
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetEntPropVector( new_entity, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
				
				if(distance <= (1300.0 * 1300.0))
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = new_entity; 
							TargetDistance = distance;          
						}
					} 
					else 
					{
						ClosestTarget = new_entity; 
						TargetDistance = distance;
					}
				}
			}
		}
	}
	if (ClosestTarget > 0)
	{
		return ClosestTarget; 
	}
	for(int new_entity=1; new_entity <= MAXENTITIES; new_entity++)
	{
		if (IsValidEntity(new_entity) && !b_NpcHasDied[new_entity])
		{
			if(IsValidEnemy(entity, new_entity))
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetEntPropVector( new_entity, Prop_Data, "m_vecAbsOrigin", TargetLocation );
				TargetLocation[2] += 35;				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				
				int HighestHealth;
				
				HighestHealth = GetEntProp(new_entity, Prop_Data, "m_iHealth");
				
				if(distance <= (1300.0 * 1300.0))
				{
					if( Health ) 
					{
						if( HighestHealth > Health ) 
						{
							ClosestTarget = new_entity; 
							Health = HighestHealth;          
						}
					} 
					else 
					{
						ClosestTarget = new_entity; 
						Health = HighestHealth;
					}
				}
			}
		}
	}
	return ClosestTarget; 
}


public bool WorldOnly(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	else if(GetTeam(iExclude) == GetTeam(entity))
		return false;
	
	return !(entity == iExclude);
}