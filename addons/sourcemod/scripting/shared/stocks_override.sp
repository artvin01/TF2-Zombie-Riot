#pragma semicolon 1
#pragma newdecls required

//#define GetPlayerWeaponSlot GetPlayerWeaponSlot__DontUse

void Stock_TakeDamage(int entity = 0, int inflictor = 0, int attacker = 0, float damage = 0.0, int damageType=DMG_GENERIC, int weapon=-1,const float damageForce[3]=NULL_VECTOR, const float damagePosition[3]=NULL_VECTOR, bool bypassHooks = false, int Zr_damage_custom = 0)
{
	i_HexCustomDamageTypes[entity] = Zr_damage_custom;
	SDKHooks_TakeDamage(entity, inflictor, attacker, damage, damageType, IsValidEntity(weapon) ? weapon : -1, damageForce, damagePosition, bypassHooks);

}

//We need custom Defaults for this, mainly bypass hooks to FALSE. i dont want to spend 5 years on replacing everything.
//im sorry.
#define SDKHooks_TakeDamage Stock_TakeDamage

bool Stock_IsValidEntity(int entity)
{
	if(entity == 0 || entity == -1)
	{
		return false;
	}
	else
	{
		return IsValidEntity(entity);
	}

}

#define IsValidEntity Stock_IsValidEntity

stock void Stock_SetEntityMoveType(int entity, MoveType mt)
{
	if(b_ThisWasAnNpc[entity] && mt != MOVETYPE_CUSTOM)
	{
		ThrowError("Do not dare! Dont set SetEntityMoveType on an NPC that isnt MOVECUSTOM.");
		return;
	}

#if defined ZR
	if(entity > 0 && entity <= MaxClients && Vehicle_Driver(entity) != -1)
	{
		// Nuh uh, we're driving
		mt = MOVETYPE_NONE;
	}
#endif
	
	SetEntityMoveType(entity, mt);
}

#define SetEntityMoveType Stock_SetEntityMoveType


#define KillTimer KILLTIMER_DONOTUSE_USE_DELETE

/*
TODO:
	Instead of setting the colour, try to get the average so gold and blue becomes a fusion of both,
	instead of just hard cold blue in the case of the wand. This would also make any 0 in ALPHA not seeable.

	Also how the fuck do i for loop this? This looks like shit

*/

//Override normal one to add our own logic for our own needs so we dont need to make a whole new thing.

stock void Stock_SetEntityRenderMode(int entity, RenderMode mode, bool TrueEntityColour = true, int SetOverride = 0, bool ingore_wearables = true, bool dontchangewearablecolour = true, bool ForceColour = false)
{
	if(TrueEntityColour || SetOverride != 0)
	{
		if(!ingore_wearables && !dontchangewearablecolour)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex) && !b_EntityCantBeColoured[WearableEntityIndex])
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
					{
						if(SetOverride == 1)
						{
							i_EntityRenderOverride[WearableEntityIndex] = true;
						}
						else if (SetOverride == 2)
						{
							i_EntityRenderOverride[WearableEntityIndex] = false;
						}
						i_EntityRenderMode[WearableEntityIndex] = mode;		
					}
				}
			}
		}
		if(i_EntityRenderColour4[entity] != 0 || ForceColour) //If it has NO colour, then do NOT recolour.
		{
			if(SetOverride == 1)
			{
				i_EntityRenderOverride[entity] = true;
			}
			else if (SetOverride == 2)
			{
				i_EntityRenderOverride[entity] = false;
			}
			i_EntityRenderMode[entity] = mode;
		}
	}
		
	if(!i_EntityRenderOverride[entity] || !TrueEntityColour)
	{
		if(!ingore_wearables)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex) && !b_EntityCantBeColoured[WearableEntityIndex])
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
					{					
						if(!TrueEntityColour)
						{
							SetEntityRenderMode(WearableEntityIndex, mode);		
						}
						else
						{
							SetEntityRenderMode(WearableEntityIndex, i_EntityRenderMode[WearableEntityIndex]);		
						}	
					}
				}
			}
		}
		if(i_EntityRenderColour4[entity] != 0 && !i_EntityRenderOverride[entity] || (!TrueEntityColour && i_EntityRenderColour4[entity] != 0) || ForceColour) //If it has NO colour, then do NOT recolour.
		{
			SetEntityRenderMode(entity, mode);
		}
	}
}

#define SetEntityRenderMode Stock_SetEntityRenderMode


//Override normal one to add our own logic for our own needs so we dont need to make a whole new thing.
stock void Stock_SetEntityRenderColor(int entity, int r=255, int g=255, int b=255, int a=255, bool TrueEntityColour = true, bool ingore_wearables = true, bool dontchangewearablecolour = true, bool ForceColour = false)
{	
	bool ColorWasSet = false;
	if(TrueEntityColour)
	{
		if(!ingore_wearables && !dontchangewearablecolour)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex) && !b_EntityCantBeColoured[WearableEntityIndex])
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
					{
						i_EntityRenderColour1[WearableEntityIndex] = r;
						i_EntityRenderColour2[WearableEntityIndex] = g;
						i_EntityRenderColour3[WearableEntityIndex] = b;
						i_EntityRenderColour4[WearableEntityIndex] = a;
					}
				}
			}
		}
		if(i_EntityRenderColour4[entity] != 0 || ForceColour) //If it has NO colour, then do NOT recolour.
		{
			i_EntityRenderColour1[entity] = r;
			i_EntityRenderColour2[entity] = g;
			i_EntityRenderColour3[entity] = b;
			i_EntityRenderColour4[entity] = a;
			ColorWasSet = true;
		}
	}
	
	if(!i_EntityRenderOverride[entity] || !TrueEntityColour)
	{
		if(!ingore_wearables)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex) && !b_EntityCantBeColoured[WearableEntityIndex])
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0 || ForceColour)
					{
						if(!TrueEntityColour)
						{
							SetEntityRenderColor(WearableEntityIndex, r, g, b, a);
						}
						else
						{
							SetEntityRenderColor(WearableEntityIndex,
							i_EntityRenderColour1[WearableEntityIndex],
							i_EntityRenderColour2[WearableEntityIndex],
							i_EntityRenderColour3[WearableEntityIndex],
							i_EntityRenderColour4[WearableEntityIndex]);
						}	
					}						
				}
			}
		}
		if(ForceColour || (i_EntityRenderColour4[entity] != 0 && !i_EntityRenderOverride[entity]) || (ColorWasSet && !i_EntityRenderOverride[entity]) || (!TrueEntityColour && i_EntityRenderColour4[entity] != 0)) //If it has NO colour, then do NOT recolour.
		{
			SetEntityRenderColor(entity, r, g, b, a);
		}
	}
}

#define SetEntityRenderColor Stock_SetEntityRenderColor

//In this case i never need the world ever.

void Stock_SetHudTextParams(float x, float y, float holdTime, int r, int g, int b, int a, int effect = 1, float fxTime=0.1, float fadeIn=0.1, float fadeOut=0.1)
{
	SetHudTextParams(x, y, holdTime, r, g, b, a, effect, fxTime, fadeIn, fadeOut);
}

#define SetHudTextParams Stock_SetHudTextParams

int Stock_ShowSyncHudText(int client, Handle sync, const char[] message, any ...)
{
	int ReturnFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
	if(ReturnFlags & HIDEHUD_ALL) //hide.
		return 0;

	char buffer[512];
	VFormat(buffer, sizeof(buffer), message, 4);
	return ShowSyncHudText(client, sync, buffer);
}
#define ShowSyncHudText Stock_ShowSyncHudText

void Stock_PrintHintText(int client, const char[] format, any ...)
{
	int ReturnFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
	if(ReturnFlags & HIDEHUD_ALL) //hide.
		return;

	char buffer[512];
	VFormat(buffer, sizeof(buffer), format, 3);
	PrintHintText(client, buffer);
}
#define PrintHintText Stock_PrintHintText

stock void ResetToZero(any[] array, int length)
{
    for(int i; i<length; i++)
    {
        array[i] = 0;
    }
}

stock void ResetToZero2(any[][] array, int length1, int length2)
{
    for(int a; a<length1; a++)
    {
        for(int b; b<length2; b++)
        {
            array[a][b] = 0;
        }
    }
}

#define Zero(%1)        ResetToZero(%1, sizeof(%1))
#define Zero2(%1)    ResetToZero2(%1, sizeof(%1), sizeof(%1[]))

#define TF2_RemoveWeaponSlot RemoveSlotWeapons
#define TF2_RemoveAllWeapons RemoveAllWeapons

stock void RemoveSlotWeapons(int client, int slot)
{
	char buffer[36];
	int entity;
	bool found;
	do
	{
		found = false;
		
		int i;
		while(TF2_GetItem(client, entity, i))
		{
			GetEntityClassname(entity, buffer, sizeof(buffer));
			if(TF2_GetClassnameSlot(buffer, entity) == slot)
			{
				TF2_RemoveItem(client, entity);
				found = true;
				break;
			}
		}
	}
	while(found);
}

stock void RemoveAllWeapons(int client)
{
	PreMedigunCheckAntiCrash(client);
	int entity;
	bool found;
	do
	{
		found = false;

		int i;
		while(TF2_GetItem(client, entity, i))
		{
			TF2_RemoveItem(client, entity);
			found = true;
			break;
		}
	}
	while(found);
}

stock float ZR_GetGameTime(int entity = 0)
{
	if(entity == 0)
	{
		return GetGameTime();
	}
	else
	{
		float gameTime = GetGameTime();

#if defined RTS
		float speed = RTS_GameSpeed();
		if(speed != 1.0)
		{
			float lifetime = gameTime - flNpcCreationTime[entity];
			gameTime += lifetime * (speed - 1.0);
		}
#endif

		return gameTime - f_StunExtraGametimeDuration[entity];
		//This will allow for stuns and other stuff like that. Mainly used for tank and other stuns.
		//We will treat the tank stun as such.
	}
}

#define GetGameTime ZR_GetGameTime

//This is here for rpg, because it relies on triggers, teleportentity disables triggers for an entity for a frame for some reason.

stock void Custom_TeleportEntity(int entity, const float origin[3] = NULL_VECTOR, const float angles[3] = NULL_VECTOR, const float velocity[3] = NULL_VECTOR, bool do_original = false)
{
	if(!do_original && entity <= MaxClients)
	{
		if(origin[1] != NULL_VECTOR[1] || origin[0] != NULL_VECTOR[0] || origin[2] != NULL_VECTOR[2])
		{
			if(origin[0] == 0.0 && origin[1] == 0.0 && origin[2] == 0.0)
				LogStackTrace("Possible unintended 0 0 0 teleport");
			
			Custom_SDKCall_SetLocalOrigin(entity, origin);
		}

		if(angles[1] != NULL_VECTOR[1] || angles[0] != NULL_VECTOR[0] || angles[2] != NULL_VECTOR[2])
		{
			if(entity <= MaxClients)
			{
				float angles2[3];
				angles2 = angles;
				SnapEyeAngles(entity, angles2);
			}
			else
			{
				SetEntPropVector(entity, Prop_Data, "m_angRotation", angles); 
			}
		}

		if(velocity[0] != NULL_VECTOR[0] || velocity[1] != NULL_VECTOR[1] || velocity[2] != NULL_VECTOR[2])
		{
			Custom_SetAbsVelocity(entity, velocity);
		}
	}
	else
	{
		TeleportEntity(entity,origin,angles,velocity);
	}
}

stock void Custom_SDKCall_SetLocalOrigin(int index, const float localOrigin[3])
{
	if(g_hSetLocalOrigin)
	{
		SDKCall(g_hSetLocalOrigin, index, localOrigin);
	}
}
stock void Custom_SnapEyeAngles(int client, const float viewAngles[3])
{
	SDKCall(g_hSnapEyeAngles, client, viewAngles);
}

stock void Custom_SetAbsVelocity(int client, const float viewAngles[3])
{
	SDKCall(g_hSetAbsVelocity, client, viewAngles);
}

#define TeleportEntity Custom_TeleportEntity


void Edited_TF2_RegeneratePlayer(int client)
{
#if defined ZR
	PreMedigunCheckAntiCrash(client);
	TransferDispenserBackToOtherEntity(client, true);
	TF2_SetPlayerClass_ZR(client, CurrentClass[client], false, false);
#endif
#if defined ZR
	KillDyingGlowEffect(client);
#endif
	ForcePlayerCrouch(client, false);
	//delete at all times, they have no purpose here, you respawn.
	TF2_RegeneratePlayer(client);

	SDKCall_GiveCorrectAmmoCount(client);
	//player needs to be fully nowmally visible.
	Stocks_ColourPlayernormal(client);
}

#define TF2_RegeneratePlayer Edited_TF2_RegeneratePlayer


stock void Edited_TF2_RespawnPlayer(int client)
{
#if defined ZR
	PreMedigunCheckAntiCrash(client);
	TransferDispenserBackToOtherEntity(client, true);
	TF2_SetPlayerClass_ZR(client, CurrentClass[client], false, false);

	KillDyingGlowEffect(client);
#endif
	ForcePlayerCrouch(client, false);
	//delete at all times, they have no purpose here, you respawn.
	TF2_RespawnPlayer(client);

	//player needs to be fully nowmally visible.
	Stocks_ColourPlayernormal(client);
}

#define TF2_RespawnPlayer Edited_TF2_RespawnPlayer
/*
void SetPlayerClass(int client, TFClassType classType, bool weapons = false, bool persistent = true)
{
	if(CurrentClass[client] == WeaponClass[client])
	{
		LogStackTrace("%f - Set to %d %d", GetEngineTime(), classType, persistent);
	}
	else if(classType == CurrentClass[client])
	{
		LogStackTrace("%f - Set to CurrentClass %d", GetEngineTime(), persistent);
	}
	else if(classType == WeaponClass[client])
	{
		LogStackTrace("%f - Set to WeaponClass %d", GetEngineTime(), persistent);
	}
	else
	{
		LogStackTrace("%f - Set to %d %d", GetEngineTime(), classType, persistent);
	}

	TF2_SetPlayerClass_ZR(client, classType, weapons, persistent);
}

#define TF2_SetPlayerClass_ZR SetPlayerClass*/

stock void PrecacheSoundList(const char[][] array, int length)
{
    for(int i; i < length; i++)
    {
		PrecacheSound(array[i]);
    }
}

#define PrecacheSoundArray(%1)        PrecacheSoundList(%1, sizeof(%1))

#if defined ZR
void Edited_EmitSoundToAll(const char[] sample,
				 int entity = SOUND_FROM_PLAYER,
				 int channel = SNDCHAN_AUTO,
				 int level = SNDLEVEL_NORMAL,
				 int flags = SND_NOFLAGS,
				 float volume = SNDVOL_NORMAL,
				 int pitch = SNDPITCH_NORMAL,
				 int speakerentity = -1,
				 const float origin[3] = NULL_VECTOR,
				 const float dir[3] = NULL_VECTOR,
				 bool updatePos = true,
				 float soundtime = 0.0)
{
	//# will indicate its for music, reason:
	/*
		main issue is that the sounds still go through, but, they do not get played, but saved up,
		so if it happens too much, sounds gets bugged out, and that leads to an error and all sounds vanish,
		 reneabling the music slider will play them all at once.

	*/
	if(sample[0] != '#')
	{
		if(entity > 0 && b_ThisWasAnNpc[entity])
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if((f_ZombieVolumeSetting[client] + 1.0) != 0.0 && IsClientInGame(client) && (!IsFakeClient(client) || IsClientSourceTV(client)))
				{
					float volumeedited = volume;
					if(EnableSilentMode && !b_thisNpcIsARaid[entity])
					{
						if(RecentSoundList[client].FindString(sample) != -1)
							continue;
						
						RecentSoundList[client].PushString(sample);
						CreateTimer(0.1, Timer_RecentSoundRemove, client);	
						volumeedited *= 0.7; //Silent-er.
						//	level = RoundToCeil(float(level) * 0.85);
						//dont change level
					}
					volumeedited *= (f_ZombieVolumeSetting[client] + 1.0);
					if(volumeedited > 0.0 && !AprilFoolsSoundDo(volumeedited, client,entity,channel,level,flags,pitch,speakerentity,origin,dir,updatePos,soundtime))
						EmitSoundToClient(client, sample,entity,channel,level,flags,volumeedited,pitch,speakerentity,origin,dir,updatePos,soundtime);
				}
			}	
		}	
		else
		{
			EmitSoundToAll(sample,entity,channel,level,flags,volume,pitch,speakerentity,origin,dir,updatePos,soundtime);
		}
	}
	else
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client) && (f_ClientMusicVolume[client] > 0.05 || IsClientSourceTV(client)))
			{
				EmitSoundToClient(client, sample,entity,channel,level,flags,volume,pitch,speakerentity,origin,dir,updatePos,soundtime);
			}
		}
	}
}

#define EmitSoundToAll Edited_EmitSoundToAll
#endif	// ZR

#define TF2Attrib_GetByDefIndex OLD_CODE_FIX_IT
#define TF2Items_SetAttribute OLD_CODE_FIX_IT

int MaxInfractionsAcceptEntityInput;
float f_TimeSinceLastInfraction;

bool Stock_AcceptEntityInput(int dest, const char[] input, int activator=-1, int caller=-1, int outputid=0)
{
	if(!IsValidEntity(dest) && dest != 0)
	{
		if(f_TimeSinceLastInfraction > GetEngineTime())
		{
			MaxInfractionsAcceptEntityInput++;
		}
		else
		{
			MaxInfractionsAcceptEntityInput = 0;
		}
		f_TimeSinceLastInfraction = GetEngineTime() + 0.5;

		if(MaxInfractionsAcceptEntityInput > 10)
		{		
			/*
				too many infractions. slay all npcs no matter what, but do not grant bonuses if it was a raid.
				this is an emergency, it might actually spam this very very often. In this case, we nuke all npcs immediently.
				There is a rare bug where it sometimes just doesnt spawn the entity. such as NPC wearables.
				too many infractions. slay all npcs no matter what, but do not grant bonuses if it was a raid.
			*/
			int entity = -1;
			while((entity=FindEntityByClassname(entity, "zr_base_boss")) != -1)
			{
#if defined ZR
				if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
#else
				if(IsValidEntity(entity))
#endif
				{
					if(entity != 0)
					{
						i_RaidGrantExtra[entity] = 0;
						b_DissapearOnDeath[entity] = true;
						b_DoGibThisNpc[entity] = true;
						SmiteNpcToDeath(entity);
						SmiteNpcToDeath(entity);
						SmiteNpcToDeath(entity);
						SmiteNpcToDeath(entity);
					}
				}
			}
			LogStackTrace("We failed, man! Please look into this eventually!");
			CPrintToChatAll("{crimson}[Zombie-Riot] UN-RECOVEABLE ERROR!!! All Enemies have been slain to prevent major issues, Raids will not give rewards!");
			CPrintToChatAll("{crimson}[Zombie-Riot] UN-RECOVEABLE ERROR!!! All Enemies have been slain to prevent major issues, Raids will not give rewards!");
			CPrintToChatAll("{crimson}[Zombie-Riot] UN-RECOVEABLE ERROR!!! All Enemies have been slain to prevent major issues, Raids will not give rewards!");
			CPrintToChatAll("{crimson}[Zombie-Riot] UN-RECOVEABLE ERROR!!! All Enemies have been slain to prevent major issues, Raids will not give rewards!");
			MaxInfractionsAcceptEntityInput = 0;
		}
		return false;
	}
	return AcceptEntityInput(dest, input, activator, caller, outputid);
}

#define AcceptEntityInput Stock_AcceptEntityInput

stock void Stock_RemoveEntity(int entity)
{
	if(entity >= 0 && entity <= MaxClients)
	{
		ThrowError("Unintended RemoveEntity on entity %d.", entity);
		return;
	}

	if(entity > MaxClients && entity < MAXENTITIES && ViewChange_IsViewmodelRef(EntIndexToEntRef(entity)))
	{
		LogStackTrace("Possible unintended RemoveEntity entity index leaking.");
	}

	RemoveEntity(entity);
}

#define RemoveEntity Stock_RemoveEntity

stock int EntRefToEntIndexFast(int &ref)
{
	if(ref == -1)
		return ref;
	
	int entity = EntRefToEntIndex(ref);
	if(entity == -1)
		ref = -1;
	
	return entity;
}

//#define EntRefToEntIndex EntRefToEntIndexFast
/*
int GameruleEntity()
{
	int Gamerules = FindEntityByClassname(-1, "tf_gamerules");
	return Gamerules;
}

void GameRules_SetPropFloat_Replace(const char[] prop, any value, int element=0, bool changeState=false)
{
	SetEntPropFloat(GameruleEntity(), Prop_Send, prop, value, element);
}
void GameRules_SetProp_Replace(const char[] prop, any value, int size = 4, int element=0, bool changeState=false)
{
	SetEntProp(GameruleEntity(), Prop_Send, prop, value, size, element);
}
float GameRules_GetPropFloat_Replace(const char[] prop, int element=0)
{
	return GetEntPropFloat(GameruleEntity(), Prop_Send, prop, element);
}
int GameRules_GetProp_Replace(const char[] prop, int size = 4, int element=0)
{
	return GetEntProp(GameruleEntity(), Prop_Send, prop, size, element);
}
	
RoundState GameRules_GetRoundState_Replace()
{
	return view_as<RoundState>(GameRules_GetProp("m_iRoundState"));
}

#define GameRules_GetRoundState GameRules_GetRoundState_Replace
*/