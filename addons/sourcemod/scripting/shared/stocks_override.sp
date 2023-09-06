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
	if(entity == 0)
	{
		return false;
	}
	else
	{
		return IsValidEntity(entity);
	}

}

#define IsValidEntity Stock_IsValidEntity
/*
TODO:
	Instead of setting the colour, try to get the average so gold and blue becomes a fusion of both,
	instead of just hard cold blue in the case of the wand. This would also make any 0 in ALPHA not seeable.

	Also how the fuck do i for loop this? This looks like shit

*/

//Override normal one to add our own logic for our own needs so we dont need to make a whole new thing.

/*
Always check if any of the wearables has this netprop. HasEntProp(WearableEntityIndex, Prop_Send, "m_nRenderMode"), this is needed cus what if
an npc uses a particle effect for example? (fusion warrior)
*/

stock void Stock_SetEntityRenderMode(int entity, RenderMode mode, bool TrueEntityColour = true, int SetOverride = 0, bool ingore_wearables = true, bool dontchangewearablecolour = true)
{
	if(TrueEntityColour || SetOverride != 0)
	{
		if(!ingore_wearables && !dontchangewearablecolour)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex) && HasEntProp(WearableEntityIndex, Prop_Send, "m_nRenderMode"))
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
		if(i_EntityRenderColour4[entity] != 0) //If it has NO colour, then do NOT recolour.
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
				if(IsValidEntity(WearableEntityIndex) && HasEntProp(WearableEntityIndex, Prop_Send, "m_nRenderMode"))
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
		if(i_EntityRenderColour4[entity] != 0 && !i_EntityRenderOverride[entity] || (!TrueEntityColour && i_EntityRenderColour4[entity] != 0)) //If it has NO colour, then do NOT recolour.
		{
			SetEntityRenderMode(entity, mode);
		}
	}
}

#define SetEntityRenderMode Stock_SetEntityRenderMode


//Override normal one to add our own logic for our own needs so we dont need to make a whole new thing.
stock void Stock_SetEntityRenderColor(int entity, int r=255, int g=255, int b=255, int a=255, bool TrueEntityColour = true, bool ingore_wearables = true, bool dontchangewearablecolour = true)
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
				if(IsValidEntity(WearableEntityIndex) && HasEntProp(WearableEntityIndex, Prop_Send, "m_nRenderMode"))
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
		if(i_EntityRenderColour4[entity] != 0) //If it has NO colour, then do NOT recolour.
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
				if(IsValidEntity(WearableEntityIndex) && HasEntProp(WearableEntityIndex, Prop_Send, "m_nRenderMode"))
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
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
		if((i_EntityRenderColour4[entity] != 0 && !i_EntityRenderOverride[entity]) || (ColorWasSet && !i_EntityRenderOverride[entity]) || (!TrueEntityColour && i_EntityRenderColour4[entity] != 0)) //If it has NO colour, then do NOT recolour.
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
			if(TF2_GetClassnameSlot(buffer) == slot)
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
		return (GetGameTime() - f_StunExtraGametimeDuration[entity]);
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
		if(origin[1] != NULL_VECTOR[1])
		{
			Custom_SDKCall_SetLocalOrigin(entity, origin);
		}

		if(angles[1] != NULL_VECTOR[1])
		{
			if(entity <= MaxClients)
			{
				Custom_SetAbsVelocity(entity, angles);
			}
			else
			{
				SetEntPropVector(entity, Prop_Data, "m_angRotation", angles); 
			}
		}

		if(velocity[1] != NULL_VECTOR[1])
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
	TF2_SetPlayerClass(client, CurrentClass[client], false, false);
#if defined ZR
	KillDyingGlowEffect(client);
#endif
	//delete at all times, they have no purpose here, you respawn.
	TF2_RegeneratePlayer(client);

	//player needs to be fully nowmally visible.
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
}

#define TF2_RegeneratePlayer Edited_TF2_RegeneratePlayer


void Edited_TF2_RespawnPlayer(int client)
{
	TF2_SetPlayerClass(client, CurrentClass[client], false, false);

#if defined ZR
	KillDyingGlowEffect(client);
#endif
	//delete at all times, they have no purpose here, you respawn.
	TF2_RespawnPlayer(client);

	//player needs to be fully nowmally visible.
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
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

	TF2_SetPlayerClass(client, classType, weapons, persistent);
}

#define TF2_SetPlayerClass SetPlayerClass*/
#if !defined UseDownloadTable
#define AddFileToDownloadsTable UseDownloadsCfgPlzThanks
#endif
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

		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
			{
				float volumeedited = volume;
				if(entity > 0 && !b_NpcHasDied[entity])
				{
					volumeedited *= (f_ZombieVolumeSetting[client] + 1.0);
				}
				if(volumeedited > 0.0)
					EmitSoundToClient(client, sample,entity,channel,level,flags,volumeedited,pitch,speakerentity,origin,dir,updatePos,soundtime);
			}
		}		
	}
	else
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client) && f_ClientMusicVolume[client] > 0.05)
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