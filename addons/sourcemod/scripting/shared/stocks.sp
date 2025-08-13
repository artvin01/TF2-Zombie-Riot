#pragma semicolon 1

enum ParticleAttachment_t {
	PATTACH_ABSORIGIN = 0,
	PATTACH_ABSORIGIN_FOLLOW,
	PATTACH_CUSTOMORIGIN,
	PATTACH_POINT,
	PATTACH_POINT_FOLLOW,
	PATTACH_WORLDORIGIN,
	PATTACH_ROOTBONE_FOLLOW
};

enum SolidFlags_t
{
	FSOLID_CUSTOMRAYTEST		= 0x0001,	// Ignore solid type + always call into the entity for ray tests
	FSOLID_CUSTOMBOXTEST		= 0x0002,	// Ignore solid type + always call into the entity for swept box tests
	FSOLID_NOT_SOLID			= 0x0004,	// Are we currently not solid?
	FSOLID_TRIGGER				= 0x0008,	// This is something may be collideable but fires touch functions
											// even when it's not collideable (when the FSOLID_NOT_SOLID flag is set)
	FSOLID_NOT_STANDABLE		= 0x0010,	// You can't stand on this
	FSOLID_VOLUME_CONTENTS		= 0x0020,	// Contains volumetric contents (like water)
	FSOLID_FORCE_WORLD_ALIGNED	= 0x0040,	// Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
	FSOLID_USE_TRIGGER_BOUNDS	= 0x0080,	// Uses a special trigger bounds separate from the normal OBB
	FSOLID_ROOT_PARENT_ALIGNED	= 0x0100,	// Collisions are defined in root parent's local coordinate space
	FSOLID_TRIGGER_TOUCH_DEBRIS	= 0x0200,	// This trigger will touch debris objects

	FSOLID_MAX_BITS	= 10
};

stock int abs(int x)
{
	return x < 0 ? -x : x;
}

stock float fabs(float value)
{
	return value < 0 ? -value : value;
}

stock int min(int n1, int n2)
{
	return n1 < n2 ? n1 : n2;
}

stock float fmin(float n1, float n2)
{
	return n1 < n2 ? n1 : n2;
}

stock int max(int n1, int n2)
{
	return n1 > n2 ? n1 : n2;
}

stock float fmax(float n1, float n2)
{
	return n1 > n2 ? n1 : n2;
}

stock float fClamp(float fValue, float fMin, float fMax)
{
	if (fValue < fMin) {
		return fMin;
	}

	if (fValue > fMax) {
		return fMax;
	}

	return fValue;
}

stock int GetSpellbook(int client)
{
	int i, entity;
	while(TF2_GetItem(client, entity, i))
	{
		static char buffer[36];
		if(GetEntityClassname(entity, buffer, sizeof(buffer)) && StrEqual(buffer, "tf_weapon_spellbook"))
			return entity;
	}
	return -1;
}

stock int GivePropAttachment(int entity, const char[] model)
{
	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		DispatchKeyValue(prop, "model", model);
		SetEntityCollisionGroup(prop, 1);
		DispatchSpawn(prop);
		SetEntProp(prop, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES);

		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", entity, prop);

		SetVariantString("head");
		AcceptEntityInput(prop, "SetParentAttachmentMaintainOffset"); 

		SetEntPropFloat(prop, Prop_Send, "m_fadeMinDist", MIN_FADE_DISTANCE);
		SetEntPropFloat(prop, Prop_Send, "m_fadeMaxDist", MAX_FADE_DISTANCE);

	}
	return prop;
}

stock int InfoTargetParentAt(float position[3], const char[] todo_remove_massreplace_fix, float duration = 0.1)
{
	int info = CreateEntityByName("info_teleport_destination");
	if (info != -1)
	{
		if(todo_remove_massreplace_fix[0])
		{
			PrintToChatAll("an info target had a name, please report this to admins!!!!");
			ThrowError("shouldnt have a name, but does, fix it!");
		}
		TeleportEntity(info, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(info, Prop_Data, "m_flSimulationTime", GetGameTime());
		
		DispatchSpawn(info);

		//if it has no effect name, then it should always display, as its for other reasons.
		if (duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(info), TIMER_FLAG_NO_MAPCHANGE);
	}
	return info;
}

stock int ParticleEffectAt(float position[3], const char[] effectName, float duration = 0.1)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(particle, Prop_Data, "m_flSimulationTime", GetGameTime());
		DispatchKeyValue(particle, "targetname", "rpg_fortress");
		if(effectName[0])
			DispatchKeyValue(particle, "effect_name", effectName);
		else
			DispatchKeyValue(particle, "effect_name", "3rd_trail");

		DispatchSpawn(particle);
		if(effectName[0])
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}
		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));	
		//if it has no effect name, then it should always display, as its for other reasons.
		if (duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	return particle;
}

stock int ParticleEffectAt_Parent(float position[3], char[] effectName, int iParent, const char[] szAttachment = "", float vOffsets[3] = {0.0,0.0,0.0}, bool start = true)
{
	int particle = CreateEntityByName("info_particle_system");

	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(particle, Prop_Data, "m_flSimulationTime", GetGameTime());

		DispatchKeyValue(particle, "targetname", "rpg_fortress");
		if(effectName[0])
			DispatchKeyValue(particle, "effect_name", effectName);
		else
			DispatchKeyValue(particle, "effect_name", "3rd_trail");
			
		if(iParent > MAXPLAYERS) //Exclude base_bosses from this, or any entity, then it has to always be rendered.
		{
			b_IsEntityAlwaysTranmitted[particle] = true;
		}

		if (start)
			DispatchSpawn(particle);

		SetParent(iParent, particle, szAttachment, vOffsets);

		if(effectName[0] && start)
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}
		//CreateTimer(0.1, Activate_particle_late, particle, TIMER_FLAG_NO_MAPCHANGE);
	}

	return particle;
}

stock int ParticleEffectAtWithRotation(float position[3], float rotation[3], char[] effectName, float duration = 0.1)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropVector(particle, Prop_Data, "m_angRotation", rotation);
		DispatchKeyValue(particle, "targetname", "rpg_fortress");
		if(effectName[0])
			DispatchKeyValue(particle, "effect_name", effectName);
		else
			DispatchKeyValue(particle, "effect_name", "3rd_trail");
		DispatchSpawn(particle);
		if(effectName[0])
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}
		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));	
		if (duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	return particle;
}


stock bool FindInfoTarget(const char[] name)
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "info_target")) != -1)
	{
		static char buffer[32];
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
			return true;
	}
	return false;
}
stock int FindInfoTargetInt(const char[] name)
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "info_target")) != -1)
	{
		static char buffer[32];
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
			return entity;
	}
	return 0;
}

stock bool ExcuteRelay(const char[] name, const char[] input="Trigger")
{
	bool found;
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "logic_relay")) != -1)
	{
		static char buffer[32];
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(StrEqual(buffer, name, false))
		{
			AcceptEntityInput(entity, input, entity, entity);
			found = true;
		}
	}
	return found;
}

void ResetReplications()
{
	for(int client=1; client<=MaxClients; client++)
	{
		ReplicateClient_Svairaccelerate[client] = -1.0;
		ReplicateClient_BackwardsWalk[client] = -1.0;
		ReplicateClient_Tfsolidobjects[client] = -1;
		ReplicateClient_RollAngle[client] = -1;
	}
}

stock void CreateAttachedAnnotation(int client, int entity, float time, const char[] buffer)
{
	Event event = CreateEvent("show_annotation");
	if(event)
	{
		static float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		event.SetFloat("worldNormalX", pos[0]);
		event.SetFloat("worldNormalY", pos[1]);
		event.SetFloat("worldNormalZ", pos[2]);
		event.SetInt("follow_entindex", entity);
		event.SetFloat("lifetime", time);
		event.SetInt("visibilityBitfield", (1<<client));
		//event.SetBool("show_effect", effect);
		event.SetString("text", buffer);
		event.SetString("play_sound", "vo/null.mp3");
		event.SetInt("id", 6000+entity); //What to enter inside? Need a way to identify annotations by entindex!
		event.Fire();
	}
}

stock bool StartFuncByPluginName(const char[] pluginname, const char[] funcname)
{
	Handle iter = GetPluginIterator();
	while(MorePlugins(iter))
	{
		Handle plugin = ReadPlugin(iter);
		static char buffer[256];
		GetPluginFilename(plugin, buffer, sizeof(buffer));
		if(StrContains(buffer, pluginname, false) != -1)
		{
			Function func = GetFunctionByName(plugin, funcname);
			if(func != INVALID_FUNCTION)
			{
				Call_StartFunction(plugin, func);
				delete iter;
				return true;
			}
			break;
		}
	}
	delete iter;
	return false;
}

stock int ExplodeStringInt(const char[] text, const char[] split, int[] buffers, int maxInts)
{
	int reloc_idx, idx, total;

	if (maxInts < 1 || !split[0])
	{
		return 0;
	}

	char buffer[16];
	while ((idx = SplitString(text[reloc_idx], split, buffer, sizeof(buffer))) != -1)
	{
		reloc_idx += idx;
		buffers[total] = StringToInt(buffer);
		if (++total == maxInts)
			return total;
	}

	buffers[total++] = StringToInt(text[reloc_idx]);
	return total;
}

stock void MergeStringInt(int[] buffers, int maxInts, const char[] split, char[] buffer, int length)
{
	IntToString(buffers[0], buffer, length);
	for(int i=1; i<maxInts; i++)
	{
		Format(buffer, length, "%s%s%d", buffer, split, buffers[i]);
	}
}

stock int ExplodeStringFloat(const char[] text, const char[] split, float[] buffers, int maxFloats)
{
	int reloc_idx, idx, total;

	if (maxFloats < 1 || !split[0])
	{
		return 0;
	}

	char buffer[16];
	while ((idx = SplitString(text[reloc_idx], split, buffer, sizeof(buffer))) != -1)
	{
		reloc_idx += idx;
		buffers[total] = StringToFloat(buffer);
		if (++total == maxFloats)
			return total;
	}

	buffers[total++] = StringToFloat(text[reloc_idx]);
	return total;
}

stock void KvGetTranslation(KeyValues kv, const char[] string, char[] buffer, int length, const char[] defaul = "")
{
	kv.GetString(string, buffer, length, defaul);
	if(buffer[0] && !TranslationPhraseExists(buffer))
	{
		LogError("[Config] Missing translation '%s'", buffer);
		strcopy(buffer, length, defaul);
	}
}

stock Function KvGetFunction(KeyValues kv, const char[] string, Function defaul = INVALID_FUNCTION)
{
	char buffer[64];
	kv.GetString(string, buffer, sizeof(buffer));
	if(buffer[0])
		return GetFunctionByName(null, buffer);

	return defaul;
}

static bool i_PreviousInteractedEntityDo[MAXENTITIES];
static float f_PreviousInteractedEntityDo[MAXENTITIES];

void ResetIgnorePointVisible()
{
	Zero(f_PreviousInteractedEntityDo);
}
stock int GetClientPointVisible(int iClient, float flDistance = 100.0, bool ignore_allied_npc = false, bool mask_shot = false, float vecEndOrigin[3] = {0.0, 0.0, 0.0}, int repeatsretry = 2)
{
	float vecOrigin[3], vecAngles[3];
	GetClientEyePosition(iClient, vecOrigin);
	GetClientEyeAngles(iClient, vecAngles);
	
	Handle hTrace;

	//Mask shot here, reasoning being that it should be easiser to interact with buildings and npcs if they are very close to eachother or inside (This wont fully fix it, but i see not other way.)
	//This is client compensated anyways, and reviving is still via hull and not hitboxes.

	//
	int flags = CONTENTS_SOLID;

	if(!mask_shot)
	{
		flags |= MASK_SOLID;
	}
	else
	{
		flags |= MASK_SOLID;
		//Mask shot is entirely unnececarry, as it doesnt work and with the ignore entity method its unnececcary
	//	flags |= MASK_SHOT;
	}

	int iReturn = -1;
	int iHit;
	//loop upto twice
	if(repeatsretry == 1)
	{
		i_PreviousInteractedEntityDo[iClient] = false;
	}
	else
	{
		i_PreviousInteractedEntityDo[iClient] = true;
	}

	if(repeatsretry >= 2)
	{
		if(f_PreviousInteractedEntityDo[iClient] < GetGameTime())
		{
			//Our last interaction was a second ago, dont try to phase throguh the previous ignored one.
			i_PreviousInteractedEntity[iClient] = -1; //didnt find any
		}
		f_PreviousInteractedEntityDo[iClient] = GetGameTime() + 1.0;
	}

	for(int repeat; repeat < repeatsretry; repeat++)
	{
		delete hTrace;
		if(!ignore_allied_npc)
		{
			hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, ( flags ), RayType_Infinite, Trace_DontHitEntityOrPlayer, iClient);
			TR_GetEndPosition(vecEndOrigin, hTrace);
		}
		else
		{
			hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, ( flags ), RayType_Infinite, Trace_DontHitEntityOrPlayerOrAlliedNpc, iClient);
			TR_GetEndPosition(vecEndOrigin, hTrace);		
		}
		iHit = TR_GetEntityIndex(hTrace);
		if(iHit > 0)
		{
			break;
		}
		if(repeat == 0)
		{
			if(repeatsretry >= 2)
				i_PreviousInteractedEntity[iClient] = -1; //didnt find any
		}
	}


	if(repeatsretry >= 2)
		i_PreviousInteractedEntity[iClient] = iHit;

	bool DoAlternativeCheck = false;
	if(IsValidEntity(iHit) && i_IsABuilding[iHit])
	{
#if defined ZR
		//if a building is mounted, we grant extra range.
		int Building_Index = EntRefToEntIndex(Building_Mounted[iHit]);
		if(IsValidClient(Building_Index))
		{
			//intercted with a player
			DoAlternativeCheck = true;
		}
#endif
	}
	else if(IsValidClient(iHit))
	{
		//intercted with a player
		DoAlternativeCheck = true;
	}
	
	if (!TR_DidHit(hTrace) || iHit == iClient || !IsValidEntity(iHit))
	{
		delete hTrace;
		return iReturn;
	}
	
	if(DoAlternativeCheck)
	{
		float VecAbsClient[3];
		float VecAbsEntity[3];
		GetEntPropVector(iClient, Prop_Data, "m_vecAbsOrigin", VecAbsClient);
		GetEntPropVector(iHit, Prop_Data, "m_vecAbsOrigin", VecAbsEntity);
		flDistance *= 2.0;
		if(GetVectorDistance(VecAbsClient, VecAbsEntity, true) < ((flDistance) * (flDistance)))
			iReturn = iHit;
	}
	else
	{
		if (GetVectorDistance(vecOrigin, vecEndOrigin, true) < (flDistance * flDistance))
			iReturn = iHit;
	}
	
	delete hTrace;
	return iReturn;
}

stock void ShowGameText(int client, const char[] icon="leaderboard_streak", int color=0, const char[] buffer, any ...)
{
	char message[512];
	VFormat(message, sizeof(message), buffer, 5);

	BfWrite bf = view_as<BfWrite>(StartMessageOne("HudNotifyCustom", client));
	if(bf)
	{
		bf.WriteString(message);
		bf.WriteString(icon);
		bf.WriteByte(color);
		EndMessage();
	}
}

stock void CreateExplosion(int owner, const float origin[3], float damage, int magnitude, int radius)
{
	int explosion = CreateEntityByName("env_explosion");
	if(IsValidEntity(explosion))
	{
		DispatchKeyValueFloat(explosion, "DamageForce", damage);
		
		SetEntProp(explosion, Prop_Data, "m_iMagnitude", magnitude);
		SetEntProp(explosion, Prop_Data, "m_iRadiusOverride", radius);
		SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", owner);
		
		if(DispatchSpawn(explosion))
		{
			TeleportEntity(explosion, origin, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(explosion, "Explode");
			RemoveEntity(explosion);
		}
	}
}

#if defined __tf_econ_data_included
stock TFClassType TF2_GetWeaponClass(int index, TFClassType defaul=TFClass_Unknown, int checkSlot=-1)
{
	switch(index)
	{
		case 25, 26:
			return TFClass_Engineer;
		
		case 735, 736, 810, 831, 933, 1080, 1102:
			return TFClass_Spy;
	}
	
	if(defaul != TFClass_Unknown)
	{
		int slot = TF2Econ_GetItemLoadoutSlot(index, defaul);
		if(checkSlot != -1)
		{
			if(slot == checkSlot)
				return defaul;
		}
		else if(slot>=0 && slot<6)
		{
			return defaul;
		}
	}

	TFClassType backup;
	for(TFClassType class=TFClass_Engineer; class>TFClass_Unknown; class--)
	{
		if(defaul == class)
			continue;

		int slot = TF2Econ_GetItemLoadoutSlot(index, class);
		if(checkSlot != -1)
		{
			if(slot == checkSlot)
				return class;
			
			if(!backup && slot >= 0 && slot < 6)
				backup = class;
		}
		else if(slot >= 0 && slot < 6)
		{
			return class;
		}
	}

	if(checkSlot != -1 && backup)
		return backup;
	
	return defaul;
}
#endif

stock bool TF2_GetItem(int client, int &weapon, int &pos)
{
	//Could be looped through client slots, but would cause issues with >1 weapons in same slot
	int maxWeapons = GetMaxWeapons(client);

	//Loop though all weapons (non-wearables)
	while(pos < maxWeapons)
	{
		weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", pos);
		pos++;

		if(weapon > MaxClients)
			return true;
	}
	return false;
}

stock bool TF2_GetWearable(int client, int &entity)
{
	while((entity=FindEntityByClassname(entity, "tf_wear*")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
			return true;
	}
	return false;
}
stock int TF2_GetClassnameSlot(const char[] classname, int entity = -1)
{
	//if we already got the slot, dont bother.
	if(entity != -1 && i_SavedActualWeaponSlot[entity] != -1)
	{
		return i_SavedActualWeaponSlot[entity];
	}
	//This is a bandaid fix.
	int Index = TF2_GetClassnameSlotInternal(classname, false);
	if(entity != -1)
	{
		i_SavedActualWeaponSlot[entity] = Index;
	}
	return Index;
}

stock int TF2_GetClassnameSlotInternal(const char[] classname, bool econ=false)
{
	if(StrEqual(classname, "tf_weapon_scattergun") ||
	   StrEqual(classname, "tf_weapon_handgun_scout_primary") ||
	   StrEqual(classname, "tf_weapon_soda_popper") ||
	   StrEqual(classname, "tf_weapon_pep_brawler_blaster") ||
	  !StrContains(classname, "tf_weapon_rocketlauncher") ||
	   StrEqual(classname, "tf_weapon_particle_cannon") ||
	   StrEqual(classname, "tf_weapon_flamethrower") ||
	   StrEqual(classname, "tf_weapon_grenadelauncher") ||
	   StrEqual(classname, "tf_weapon_cannon") ||
	   StrEqual(classname, "tf_weapon_minigun") ||
	   StrEqual(classname, "tf_weapon_shotgun_primary") ||
	   StrEqual(classname, "tf_weapon_sentry_revenge") ||
	   StrEqual(classname, "tf_weapon_drg_pomson") ||
	   StrEqual(classname, "tf_weapon_shotgun_building_rescue") ||
	   StrEqual(classname, "tf_weapon_syringegun_medic") ||
	   StrEqual(classname, "tf_weapon_crossbow") ||
	  !StrContains(classname, "tf_weapon_sniperrifle") ||
	   StrEqual(classname, "tf_weapon_compound_bow"))
	{
		return TFWeaponSlot_Primary;
	}
	else if(!StrContains(classname, "tf_weapon_pistol") ||
	  !StrContains(classname, "tf_weapon_lunchbox") ||
	  !StrContains(classname, "tf_weapon_jar") ||
	   StrEqual(classname, "tf_weapon_handgun_scout_secondary") ||
	   StrEqual(classname, "tf_weapon_cleaver") ||
	  !StrContains(classname, "tf_weapon_shotgun") ||
	   StrEqual(classname, "tf_weapon_buff_item") ||
	   StrEqual(classname, "tf_weapon_raygun") ||
	  !StrContains(classname, "tf_weapon_flaregun") ||
	  !StrContains(classname, "tf_weapon_rocketpack") ||
	  !StrContains(classname, "tf_weapon_pipebomblauncher") ||
	   StrEqual(classname, "tf_weapon_laser_pointer") ||
	   StrEqual(classname, "tf_weapon_mechanical_arm") ||
	   StrEqual(classname, "tf_weapon_medigun") ||
	   StrEqual(classname, "tf_weapon_smg") ||
	   StrEqual(classname, "tf_weapon_charged_smg"))
	{
		return TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_re"))	// Revolver
	{
		return econ ? TFWeaponSlot_Secondary : TFWeaponSlot_Primary;
	}
	else if(StrEqual(classname, "tf_weapon_sa"))	// Sapper
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_i") || !StrContains(classname, "tf_weapon_pda_engineer_d"))	// Invis & Destory PDA
	{
		return econ ? TFWeaponSlot_Item1 : TFWeaponSlot_Building;
	}
	else if(!StrContains(classname, "tf_weapon_p"))	// Disguise Kit & Build PDA
	{
		return econ ? TFWeaponSlot_PDA : TFWeaponSlot_Grenade;
	}
	else if(!StrContains(classname, "tf_weapon_bu"))	// Builder Box
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_PDA;
	}
	else if(!StrContains(classname, "tf_weapon_sp"))	 // Spellbook
	{
		return TFWeaponSlot_Item1;
	}
	return TFWeaponSlot_Melee;
}
stock int GetAmmo(int client, int type)
{
	/*
	if(type == Ammo_Metal_Sub)
	{
		type = Ammo_Metal;
	}
	*/
	int ammo = GetEntProp(client, Prop_Data, "m_iAmmo", _, type);
	if(ammo < 0)
		ammo = 0;

	return ammo;
}

stock void SetAmmo(int client, int type, int ammo)
{
	if(type == Ammo_Metal)
	{
		if(ammo < 10)
			ammo = 10;
		//Never ever set lower then 1!!!
		SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, Ammo_Metal_Sub);
	}
	SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, type);
}

#if defined _tf2items_included
stock int SpawnWeapon(int client, char[] name, int index, int level, int qual, const int[] attrib, const float[] value, int count, int custom_classSetting = 0)
{
	if(custom_classSetting == 11)
	{
		custom_classSetting = 0;
	}
	int weapon = SpawnWeaponBase(client, name, index, level, qual, custom_classSetting);
	if(weapon != -1)
	{
		HandleAttributes(weapon, attrib, value, count); //Thanks suza! i love my min models
	}
	return weapon;
}

static int SpawnWeaponBase(int client, char[] name, int index, int level, int qual, int custom_classSetting = 0)
{
	Handle weapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION|PRESERVE_ATTRIBUTES);
	if(weapon == INVALID_HANDLE)
		return -1;
	
	TF2Items_SetClassname(weapon, name);
	TF2Items_SetItemIndex(weapon, index);
	TF2Items_SetLevel(weapon, level);
	TF2Items_SetQuality(weapon, qual);
	TF2Items_SetNumAttributes(weapon, 0);

#if defined ZR || defined RPG

	TFClassType class = TF2_GetWeaponClass(index, CurrentClass[client], TF2_GetClassnameSlot(name, true));
	if(custom_classSetting != 0)
	{
		class = view_as<TFClassType>(custom_classSetting);
	}
	TF2_SetPlayerClass_ZR(client, class, _, false);
#endif
	
	int entity = TF2Items_GiveNamedItem(client, weapon);
	delete weapon;
	if(entity > MaxClients)
	{
#if defined ZR
		f_TimeSinceLastGiveWeapon[entity] = 0.0;
#endif

		Attributes_EntityDestroyed(entity);

		//for(int i; i < count; i++)
		//{
		//	Attributes_Set(entity, attrib[i], value[i]);
		//}
		
		if(StrEqual(name, "tf_weapon_sapper"))
		{
			SetEntProp(entity, Prop_Send, "m_iObjectType", 3);
			SetEntProp(entity, Prop_Data, "m_iSubType", 3);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 3);
		}
		else if(StrEqual(name, "tf_weapon_builder"))
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 0);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 1);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 2);
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}

		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
		SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));

		EquipPlayerWeapon(client, entity);
	}

#if defined ZR || defined RPG
	TF2_SetPlayerClass_ZR(client, CurrentClass[client], _, false);
#endif
	return entity;
}

//										 info.Attribs, info.Value, info.Attribs);
public void HandleAttributes(int weapon, const int[] attributes, const float[] values, int count)
{
	RemoveAllDefaultAttribsExceptStrings(weapon);
	
	for(int i = 0; i < count; i++) 
	{
		Attributes_Set(weapon, attributes[i], values[i]);
	}
}

void RemoveAllDefaultAttribsExceptStrings(int entity)
{
	Attributes_RemoveAll(entity);
	
	char valueType[2];
	char valueFormat[64];
	
	int currentAttrib;
	
	ArrayList staticAttribs = TF2Econ_GetItemStaticAttributes(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"));
	char Weaponname[64];
	GetEntityClassname(entity, Weaponname, sizeof(Weaponname));
	DHook_HookStripWeapon(entity);
	
	for(int i = 0; i < staticAttribs.Length; i++)
	{
		currentAttrib = staticAttribs.Get(i, .block = 0);
	
		// Probably overkill
		if(currentAttrib == 796 || currentAttrib == 724 || currentAttrib == 817 || currentAttrib == 834 
			|| currentAttrib == 745 || currentAttrib == 731 || currentAttrib == 746)
			continue;
	
		// "stored_as_integer" is absent from the attribute schema if its type is "string".
		// TF2ED_GetAttributeDefinitionString returns false if it can't find the given string.
		if(!TF2Econ_GetAttributeDefinitionString(currentAttrib, "stored_as_integer", valueType, sizeof(valueType)))
			continue;
	
		TF2Econ_GetAttributeDefinitionString(currentAttrib, "description_format", valueFormat, sizeof(valueFormat));
	
		// Since we already know what we're working with and what we're looking for, we can manually handpick
		// the most significative chars to check if they match. Eons faster than doing StrEqual or StrContains.
	
		
		if(valueFormat[9] == 'a' && valueFormat[10] == 'd') // value_is_additive & value_is_additive_percentage
		{
			Attributes_Set(entity, currentAttrib, 0.0, true);
		}
		else if((valueFormat[9] == 'i' && valueFormat[18] == 'p')
			|| (valueFormat[9] == 'p' && valueFormat[10] == 'e')) // value_is_percentage & value_is_inverted_percentage
		{
			Attributes_Set(entity, currentAttrib, 1.0, true);
		}
		else if(valueFormat[9] == 'o' && valueFormat[10] == 'r') // value_is_or
		{
			Attributes_Set(entity, currentAttrib, 0.0, true);
		}
		
		NullifySpecificAttributes(entity,currentAttrib);
	}
	
	delete staticAttribs;	
}

stock void NullifySpecificAttributes(int entity, int attribute)
{
	switch(attribute)
	{
		case 781: //Is sword
		{
			Attributes_Set(entity, attribute, 0.0);	
		}
		case 128: //Provide on active
		{
			Attributes_Set(entity, attribute, 0.0);	
		}
	}
}
#endif

stock void TF2_RemoveItem(int client, int weapon)
{
	/*if(TF2_IsWearable(weapon))
	{
		TF2_RemoveWearable(client, weapon);
		return;
	}*/

	int entity = GetEntPropEnt(weapon, Prop_Send, "m_hExtraWearable");
	if(entity != -1)
		TF2_RemoveWearable(client, entity);

	entity = GetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel");
	if(entity != -1)
		TF2_RemoveWearable(client, entity);

	RemovePlayerItem(client, weapon);
	RemoveEntity(weapon);
}

stock int GetMaxWeapons(int client)
{
	static int maxweps;
	if(!maxweps)
		maxweps = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");

	return maxweps;
}

stock float ClassHealth(TFClassType class)
{
	switch(class)
	{
		case TFClass_Soldier:
			return 200.0;

		case TFClass_Pyro, TFClass_DemoMan:
			return 175.0;

		case TFClass_Heavy:
			return 300.0;

		case TFClass_Medic:
			return 150.0;
	}
	
	return 125.0;
}

stock float RemoveExtraHealth(TFClassType class, float value)
{
	return value - ClassHealth(class);
}

stock float RemoveExtraSpeed(TFClassType class, float value)
{
	switch(class)
	{
		case TFClass_Scout:
			return value / 400.0;

		case TFClass_Soldier:
			return value / 240.0;

		case TFClass_DemoMan:
			return value / 280.0;

		case TFClass_Heavy:
			return value / 230.0;

		case TFClass_Medic, TFClass_Spy:
			return value / 320.0;

		default:
			return value / 300.0;
	}
}

void RequestFrames(RequestFrameCallback func, int frames, any data=0)
{
	frames = RoundToNearest(TickrateModify * float(frames));
	DataPack pack = new DataPack();
	pack.WriteCell(frames);
	pack.WriteFunction(func);
	pack.WriteCell(data);
	RequestFrame(RequestFramesCallback, pack);
}

public void RequestFramesCallback(DataPack pack)
{
	pack.Reset();

	int frames = pack.ReadCell();
	if(frames < 1)
	{
		Function func = pack.ReadFunction();
		any data = pack.ReadCell();
		delete pack;
		
		Call_StartFunction(null, func);
		Call_PushCell(data);
		Call_Finish();
	}
	else
	{
		pack.Position--;
		pack.WriteCell(frames-1, false);
		RequestFrame(RequestFramesCallback, pack);
	}
}


stock int TF2_CreateGlow(int iEnt, bool RenderModeAllow = false)
{
	char oldEntName[64];
	GetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));

	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);
	
	int ent = CreateEntityByName("tf_glow");
	DispatchKeyValue(ent, "targetname", "RainbowGlow");
	DispatchKeyValue(ent, "target", strName);
	DispatchKeyValue(ent, "Mode", "0");

	DispatchSpawn(ent);
	AcceptEntityInput(ent, "Enable");
	
	if(RenderModeAllow)
		SetEdictFlags(ent, (GetEdictFlags(ent) & ~FL_EDICT_ALWAYS));	

	if(RenderModeAllow)
		Hook_DHook_UpdateTransmitState(ent);
	
	//Change name back to old name because we don't need it anymore.
	SetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName);

	return ent;
}

int TF2_CreateGlow_White(const char[] model, int victim, float modelsize)
{
	int entity = CreateEntityByName("tf_taunt_prop");
	if(IsValidEntity(entity))
	{
	//	SetEntProp(entity, Prop_Data, "m_iInitialTeamNum", 2);
	//	SetEntProp(entity, Prop_Send, "m_iTeamNum", 2);

		DispatchSpawn(entity);

		SetEntityModel(entity, model);
		SetEntPropEnt(entity, Prop_Data, "m_hEffectEntity", victim);
		SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", victim);
		SetEntProp(entity, Prop_Send, "m_bGlowEnabled", true);
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(victim, Prop_Send, "m_fEffects")|EF_BONEMERGE|EF_NOSHADOW|EF_NOINTERP);

	//	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 990.0);
	//	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 1000.0);	
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", modelsize);
		//we gotta copy several things.......
		SetEntProp(entity, Prop_Send, "m_nSkin", GetEntProp(victim, Prop_Send, "m_nSkin"));
		SetEntProp(entity, Prop_Send, "m_nBody", GetEntProp(victim, Prop_Send, "m_nBody"));
		
		SetParent(victim, entity);
	}
	return entity;
}

stock void SetParent(int iParent, int iChild, const char[] szAttachment = "", const float vOffsets[3] = {0.0,0.0,0.0}, bool maintain_anyways = false)
{
	SetVariantString("!activator");
	AcceptEntityInput(iChild, "SetParent", iParent, iChild);
	
	if (szAttachment[0] != '\0') // Use at least a 0.01 second delay between SetParent and SetParentAttachment inputs.
	{
		if (szAttachment[0]) // do i even have anything?
		{
			SetVariantString(szAttachment); // "head"

			if (maintain_anyways || !AreVectorsEqual(vOffsets, view_as<float>({0.0,0.0,0.0}))) // NULL_VECTOR
			{
				if(!maintain_anyways)
				{
					float Vecpos[3];

					Vecpos = vOffsets;
					SDKCall_SetLocalOrigin(iChild,Vecpos);
				}
				AcceptEntityInput(iChild, "SetParentAttachmentMaintainOffset", iParent, iChild);
			}
			else
			{
				AcceptEntityInput(iChild, "SetParentAttachment", iParent, iChild);
			}
		}
	}
}

stock int GiveWearable(int client, int index)
{
	int entity = CreateEntityByName("tf_wearable");
	if(entity > MaxClients)	// Weapon viewmodel
	{
		if(index != 0)
		{
			SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", index);
			SetEntProp(entity, Prop_Send, "m_bInitialized", true);
		}
		SetEntProp(entity, Prop_Send, "m_iEntityQuality", 1);
		SetEntProp(entity, Prop_Send, "m_iEntityLevel", 1);
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
		SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));
		
		DispatchSpawn(entity);
		SDKCall_EquipWearable(client, entity);
		
		return entity;
	}
	return -1;
}

stock bool AreVectorsEqual(const float vVec1[3], const float vVec2[3])
{
	return (vVec1[0] == vVec2[0] && vVec1[1] == vVec2[1] && vVec1[2] == vVec2[2]);
} 

stock bool AreVectorsEqualAprox(const float vVec1[3], const float vVec2[3])
{
	return (vVec1[0] == vVec2[0] && vVec1[1] == vVec2[1] && vVec1[2] == vVec2[2]);
} 

public Action Timer_RemoveEntity(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}
public Action Timer_RemoveEntityFancy(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		SetEntityRenderFx(entity, RENDERFX_FADE_FAST);
		CreateTimer(1.5, Timer_RemoveEntity, entid, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Stop;
}
public Action Timer_RemoveEntityParticle(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		AcceptEntityInput(entid, "ClearParent");
		TeleportEntity(entid, {16000.0,16000.0,16000.0});
		CreateTimer(0.1, Timer_RemoveEntity, entid, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Stop;
}

public Action Timer_RemoveEntity_CustomProjectile(Handle timer, DataPack pack)
{
	pack.Reset();
	int iCarrier = EntRefToEntIndex(pack.ReadCell());
	int particle = EntRefToEntIndex(pack.ReadCell());
	int iRot = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(particle) && particle>MaxClients)
	{
		RemoveEntity(particle);
	}
	if(IsValidEntity(iCarrier) && iCarrier>MaxClients)
	{
		RemoveEntity(iCarrier);
	}
	if(IsValidEntity(iRot) && iRot>MaxClients)
	{
		RemoveEntity(iRot);
	}
	return Plugin_Stop; 
}

public Action Timer_DisableMotion(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
		AcceptEntityInput(entity, "DisableMotion");
	return Plugin_Stop;
}


stock void StartBleedingTimer(int victim, int attacker, float damage, int amount, int weapon, int damagetype, int customtype = 0, int effectoverride = 0)
{
	if(IsValidEntity(victim) && IsValidEntity(attacker))
	{
		if(HasSpecificBuff(victim, "Hardened Aura"))
			return;

		if(HasSpecificBuff(victim, "Thick Blood") && effectoverride != 1)
			return;

		if(damagetype & DMG_TRUEDAMAGE)
		{
			StatusEffect_OnTakeDamage_DealNegative(victim, attacker, damage, DMG_CLUB);
		}

		if(attacker > 0 && attacker <= MaxClients)
			Force_ExplainBuffToClient(attacker, "Bleed");
		else if(victim > 0 && victim <= MaxClients)
			Force_ExplainBuffToClient(victim, "Bleed");

		BleedAmountCountStack[victim] += 1;
		DataPack pack;
		CreateDataTimer(0.5, Timer_Bleeding, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(victim));
		pack.WriteCell(victim);
		pack.WriteFloat(GetGameTime());
		if(IsValidEntity(weapon))
			pack.WriteCell(EntIndexToEntRef(weapon));
		else
			pack.WriteCell(-1);
		pack.WriteCell(EntIndexToEntRef(attacker));
		pack.WriteCell(effectoverride);
		pack.WriteCell(damagetype);
		pack.WriteCell(customtype);
		pack.WriteFloat(damage);
		pack.WriteCell(amount);
	}
}

public Action Timer_Bleeding(Handle timer, DataPack pack)
{
	pack.Reset();
	int victim = EntRefToEntIndex(pack.ReadCell());
	int OriginalIndex = pack.ReadCell();
	float GameTimeClense = pack.ReadFloat();
	if(!IsValidEntity(victim))
	{
		BleedAmountCountStack[OriginalIndex] -= 1;
		if(BleedAmountCountStack[OriginalIndex] < 0)
			BleedAmountCountStack[OriginalIndex] = 0;
		return Plugin_Stop;
	}
		
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(weapon<=MaxClients || !IsValidEntity(weapon))
	{
		//if weapon isnt valid, just do -1
		//dont remove the bleed
		weapon = -1;
	}

	int attacker = EntRefToEntIndex(pack.ReadCell());
	if(attacker > 0 && attacker <= MaxClients)
	{
		if(!attacker || !IsClientInGame(attacker))
		{
			BleedAmountCountStack[OriginalIndex] -= 1;
			if(BleedAmountCountStack[OriginalIndex] < 0)
				BleedAmountCountStack[OriginalIndex] = 0;
			return Plugin_Stop;
		}
	}
	else
	{
		if(!IsValidEntity(attacker))
			attacker = 0; //Make it the world that attacks them?
	}

	int effectoverride = pack.ReadCell();
	if(StatusEffects_RapidSuturingCheck(victim, GameTimeClense))
	{
		return Plugin_Stop;
	}
	if(HasSpecificBuff(victim, "Hardened Aura"))
	{
		BleedAmountCountStack[OriginalIndex] -= 1;
		if(BleedAmountCountStack[OriginalIndex] < 0)
			BleedAmountCountStack[OriginalIndex] = 0;
		return Plugin_Stop;
	}
	if(HasSpecificBuff(victim, "Thick Blood") && effectoverride != -1)
	{
		BleedAmountCountStack[OriginalIndex] -= 1;
		if(BleedAmountCountStack[OriginalIndex] < 0)
			BleedAmountCountStack[OriginalIndex] = 0;
		return Plugin_Stop;
	}
	float pos[3];
	
	WorldSpaceCenter(victim, pos);
	int damagetype = pack.ReadCell(); //Same damagetype as the weapon.
	int customtype = pack.ReadCell() | ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED;
	float DamageDeal = pack.ReadFloat();
	if(NpcStats_ElementalAmp(victim))
	{
		DamageDeal *= 1.15;
	}
	SDKHooks_TakeDamage(victim, attacker, attacker, DamageDeal, damagetype | DMG_PREVENT_PHYSICS_FORCE, weapon, _, pos, false, customtype);

	victim = pack.ReadCell();
	if(victim < 1)
	{
		BleedAmountCountStack[OriginalIndex] -= 1;
		return Plugin_Stop;
	}

	pack.Position--;
	pack.WriteCell(victim-1, false);
	return Plugin_Continue;
}
/*
#define HEAL_NO_RULES	            0     	 
//Nothing special.
#define HEAL_SELFHEAL				(1 << 1) 
//Most healing debuffs shouldnt work with this.
#define HEAL_ABSOLUTE				(1 << 2) 
//Any and all healing changes or buffs or debuffs dont work that dont affect the weapon directly.
#define HEAL_SILENCEABLE			(1 << 3) 
//Silence Entirely nukes this heal
#define HEAL_PASSIVE_NO_NOTIF		(1 << 4) 
//Heals but doesnt notify anyone
*/
//this will return the amount of healing it actually did.

stock void DealTruedamageToEnemy(int attacker, int victim, float truedamagedeal)
{
	SDKHooks_TakeDamage(victim, attacker, attacker, truedamagedeal, DMG_TRUEDAMAGE, -1);
}
stock int HealEntityGlobal(int healer, int reciever, float HealTotal, float Maxhealth = 1.0, float HealOverThisDuration = 0.0, int flag_extrarules = HEAL_NO_RULES, int MaxHealPermitted = 99999999)
{
	/*
		MaxHealPermitted is used for HealEntityViaFloat
		Good for ammo based healing.
	*/
	if(HasSpecificBuff(reciever, "Anti-Waves"))
	{
		//Ignore all healing that isnt absolute
		if(!(flag_extrarules & (HEAL_ABSOLUTE)))
			return 0;
	}
	if(HealTotal < 0)
	{
		if(healer > 0)
			HealTotal *= fl_Extra_Damage[healer];
		//the heal total is negative, this means this is trated as true damage.
	}
#if defined ZR
	if(reciever <= MaxClients)
		if(isPlayerMad(reciever) && !(flag_extrarules & (HEAL_SELFHEAL)))
			return 0;
#endif

	if(!(flag_extrarules & (HEAL_ABSOLUTE)))
	{
#if defined ZR
		if(HasSpecificBuff(healer, "Dimensional Turbulence"))
		{
			HealTotal *= 1.5;
		}
		if(b_HealthyEssence && GetTeam(reciever) == TFTeam_Red)
			HealTotal *= 1.25;
			
		if(HasSpecificBuff(reciever, "Growth Blocker"))
		{
			HealTotal *= 0.85;
		}
		if(HasSpecificBuff(reciever, "Burn"))
			HealTotal *= 0.75;

		if((CurrentModifOn() == 3|| CurrentModifOn() == 2) && GetTeam(healer) != TFTeam_Red && GetTeam(reciever) != TFTeam_Red)
		{
			HealTotal *= 1.5;
		}

		if(Classic_Mode() && GetTeam(reciever) == TFTeam_Red)
			HealTotal *= 0.5;
#endif

#if !defined RTS
		//Extra healing bonuses or penalty for all healing except absolute
		if(reciever <= MaxClients)
			HealTotal *= Attributes_GetOnPlayer(reciever, 526, true, false);

		//healing bonus or penalty non self heal
		if(!(flag_extrarules & (HEAL_SELFHEAL)))
		{
			if(reciever <= MaxClients)
				HealTotal *= Attributes_GetOnPlayer(reciever, 734, true, false);
		}
#endif
	}
#if defined ZR
	if(healer != reciever && HealOverThisDuration != 0.0)
	{
		Healing_done_in_total[healer] += RoundToNearest(HealTotal);
	}
#endif
	if(HealOverThisDuration == 0.0)
	{
		int HealingDoneInt;
		HealingDoneInt = HealEntityViaFloat(reciever, HealTotal, Maxhealth, MaxHealPermitted);
		if(HealingDoneInt > 0)
		{
#if defined ZR
			if(healer != reciever)
			{
				Healing_done_in_total[healer] += HealingDoneInt;
				if(healer <= MaxClients)
				{
					//dont get it from healing buildings
					if(!i_IsABuilding[reciever])
					{
						AddHealthToUbersaw(healer, HealingDoneInt, 0.0);
						HealPointToReinforce(healer, HealingDoneInt, 0.0);
						GiveRageOnDamage(healer, float(HealingDoneInt) * 2.0);
					}
				}
			}
#endif
//only apply heal event if its not a passive self heal
			if(!(flag_extrarules & (HEAL_PASSIVE_NO_NOTIF)))
				ApplyHealEvent(reciever, HealingDoneInt, healer);
		}
		return HealingDoneInt;
	}
	else
	{
		float HealTotalTimer = HealOverThisDuration / 0.1;

		DataPack pack;
		CreateDataTimer(0.1, Timer_Healing, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if(healer > 0)
			pack.WriteCell(EntIndexToEntRef(healer));
		else
			pack.WriteCell(0);
		pack.WriteCell(EntIndexToEntRef(reciever));
		pack.WriteFloat(HealTotal / HealTotalTimer);
		pack.WriteCell(Maxhealth);
		pack.WriteCell(RoundToNearest(HealTotalTimer));		
		return 0; //this is a timer, we cant really quantify this.
	}
}

void DisplayHealParticleAbove(int entity)
{
	if(f_HealDelayParticle[entity] < GetGameTime())
	{
		f_HealDelayParticle[entity] = GetGameTime() + 0.5;
		float ProjLoc[3];
		float ProjLoc2[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		ProjLoc2[2] += 70.0;
		ProjLoc2[2] += f_ExtraOffsetNpcHudAbove[entity];
		ProjLoc2[2] *= GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
		ProjLoc2[2] += 10.0;
		ProjLoc[2] += ProjLoc2[2];
		if(GetTeam(entity) != TFTeam_Red)
			TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		else
			TE_Particle("healthgained_red", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	}
}

float f_IncrementalSmallHeal[MAXENTITIES];

public Action Timer_Healing(Handle timer, DataPack pack)
{
	pack.Reset();
	int healer = EntRefToEntIndex(pack.ReadCell());
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity <= MaxClients)
	{
		
#if defined ZR
		if(entity < 1 || !IsClientInGame(entity) || !IsPlayerAlive(entity) || dieingstate[entity] > 0)
#else
		if(entity < 1 || !IsClientInGame(entity) || !IsPlayerAlive(entity))
#endif
		
		{
			return Plugin_Stop;
		}
	}
	else if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	// Our Current Health + Leftover Float Health + New Health Gained
	float HealthToGive = pack.ReadFloat();
	float HealthMaxPercentage = pack.ReadCell();
	int HealthHealed = HealEntityViaFloat(entity, HealthToGive, HealthMaxPercentage);
	if(HealthHealed > 0)
	{
		ApplyHealEvent(entity, HealthHealed, healer);	// Show healing number
		if(healer > 0 && healer != entity)
		{
			Healing_done_in_total[healer] += HealthHealed;
#if defined ZR
			if(healer <= MaxClients)
			{
				AddHealthToUbersaw(healer, HealthHealed, 0.0);
				HealPointToReinforce(healer, HealthHealed, 0.0);
				GiveRageOnDamage(healer, float(HealthHealed) * 2.0);
			}
#endif
		}
	}

	int current = pack.ReadCell();
	if(current <= 1)
		return Plugin_Stop;

	pack.Position--;
	pack.WriteCell(current-1, false);
	return Plugin_Continue;
}

//doing this litterally every heal spams it, so we make a 0.5 second delay, and thus, will stack it, and then show it all at once.
Handle h_Timer_HealEventApply[MAXPLAYERS+1] = {null, ...};
Handle h_Timer_HealEventApply_Ally[MAXPLAYERS+1] = {null, ...};
ArrayList h_Arraylist_HealEventAlly[MAXPLAYERS+1];

enum struct HealEventSaveInfo
{
	int HealedTarget;
	int HealAmount;
	int ArmorAmount;
}

static int i_HealsDone_Event[MAXENTITIES]={0, ...};

stock void ApplyHealEvent(int entindex, int amount, int ownerheal = 0)
{
	if(IsValidClient(entindex))
	{
		i_HealsDone_Event[entindex] += amount;
			
		if (h_Timer_HealEventApply[entindex] == null)
		{
			DataPack pack;
			h_Timer_HealEventApply[entindex] = CreateDataTimer(0.5, Timer_HealEventApply, pack, _);
			pack.WriteCell(entindex);
			pack.WriteCell(EntIndexToEntRef(entindex));
		}
	}
	else
	{
		DisplayHealParticleAbove(entindex);
	}
	if(ownerheal <= MaxClients && ownerheal > 0 && ownerheal != entindex)
	{
		if(!h_Arraylist_HealEventAlly[ownerheal])
			h_Arraylist_HealEventAlly[ownerheal] = new ArrayList(sizeof(HealEventSaveInfo));

		HealEventSaveInfo data;
		bool FoundTarget = false;
		int length = h_Arraylist_HealEventAlly[ownerheal].Length;
		for(int i; i < length; i++)
		{
			// Loop through the arraylist to find the Heal Target
			h_Arraylist_HealEventAlly[ownerheal].GetArray(i, data);
			
			if(EntRefToEntIndex(data.HealedTarget) != entindex)
				continue;

			//we found a match
			data.HealAmount += amount;
			FoundTarget = true;
			h_Arraylist_HealEventAlly[ownerheal].SetArray(i, data);
		}
		if(!FoundTarget)
		{
			// Create a new entry
			data.HealedTarget = EntIndexToEntRef(entindex);
			data.HealAmount = amount;
			h_Arraylist_HealEventAlly[ownerheal].PushArray(data);
		}

		
		if (h_Timer_HealEventApply_Ally[ownerheal] == null)
		{
			DataPack pack;
			h_Timer_HealEventApply_Ally[ownerheal] = CreateDataTimer(1.0, Timer_HealEventApply_Ally, pack, _);
			pack.WriteCell(ownerheal);
			pack.WriteCell(EntIndexToEntRef(ownerheal));
		}
	}
}
stock void ApplyArmorEvent(int entindex, int amount, int ownerheal = 0)
{
	if(ownerheal <= MaxClients && ownerheal > 0 && ownerheal != entindex)
	{
		if(!h_Arraylist_HealEventAlly[ownerheal])
			h_Arraylist_HealEventAlly[ownerheal] = new ArrayList(sizeof(HealEventSaveInfo));

		HealEventSaveInfo data;
		bool FoundTarget = false;
		int length = h_Arraylist_HealEventAlly[ownerheal].Length;
		for(int i; i < length; i++)
		{
			// Loop through the arraylist to find the Heal Target
			h_Arraylist_HealEventAlly[ownerheal].GetArray(i, data);
			
			if(EntRefToEntIndex(data.HealedTarget) != entindex)
				continue;

			//we found a match
			data.ArmorAmount += amount;
			FoundTarget = true;
			h_Arraylist_HealEventAlly[ownerheal].SetArray(i, data);
		}
		if(!FoundTarget)
		{
			// Create a new entry
			data.HealedTarget = EntIndexToEntRef(entindex);
			data.ArmorAmount = amount;
			h_Arraylist_HealEventAlly[ownerheal].PushArray(data);
		}
		
		if (h_Timer_HealEventApply_Ally[ownerheal] == null)
		{
			DataPack pack;
			h_Timer_HealEventApply_Ally[ownerheal] = CreateDataTimer(1.0, Timer_HealEventApply_Ally, pack, _);
			pack.WriteCell(ownerheal);
			pack.WriteCell(EntIndexToEntRef(ownerheal));
		}
	}
}


public Action Timer_HealEventApply_Ally(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientOriginalIndex = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());

	if (!IsValidMulti(client))
	{
		h_Timer_HealEventApply_Ally[clientOriginalIndex] = null;
		delete h_Arraylist_HealEventAlly[clientOriginalIndex];
		return Plugin_Stop;
	}
	HealEventSaveInfo data;
	int length = h_Arraylist_HealEventAlly[clientOriginalIndex].Length;
	for(int i; i < length; i++)
	{
		// Loop through the arraylist to find the Heal Target
		h_Arraylist_HealEventAlly[clientOriginalIndex].GetArray(i, data);
		
		if(!IsValidEntity(data.HealedTarget))
			continue;
	
		if(data.HealAmount)
		{
			Event event = CreateEvent("building_healed", true);
			event.SetInt("priority", 1);
			event.SetInt("building", EntRefToEntIndex(data.HealedTarget));
			event.SetInt("healer", clientOriginalIndex);
			event.SetInt("amount", data.HealAmount);
			event.FireToClient(clientOriginalIndex);
			event.Cancel();
		}
		if(data.ArmorAmount)
		{
			Event event = CreateEvent("player_bonuspoints", true);
			event.SetInt("priority", 1);
			event.SetInt("source_entindex", EntRefToEntIndex(data.HealedTarget));
			event.SetInt("player_entindex", clientOriginalIndex);
			event.SetInt("points", data.ArmorAmount * 10);
			event.FireToClient(clientOriginalIndex);
			event.Cancel();
		}
	}
	delete h_Arraylist_HealEventAlly[clientOriginalIndex];
	h_Timer_HealEventApply_Ally[clientOriginalIndex] = null;
	return Plugin_Stop;
}


public Action Timer_HealEventApply(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientOriginalIndex = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());

	if (!IsValidMulti(client))
	{
		i_HealsDone_Event[clientOriginalIndex] = 0;
		h_Timer_HealEventApply[clientOriginalIndex] = null;
		return Plugin_Stop;
	}

	if(i_HealsDone_Event[clientOriginalIndex] > 0)
	{
		Event event = CreateEvent("player_healonhit", true);
		event.SetInt("entindex", client);
		event.SetInt("amount", i_HealsDone_Event[clientOriginalIndex]);
		event.Fire();
	}
	i_HealsDone_Event[clientOriginalIndex] = 0;
	h_Timer_HealEventApply[clientOriginalIndex] = null;
	return Plugin_Stop;
}

public bool Trace_WorldOnly(int entity, int mask, any data)
{
	return entity == 0;
}

public bool Trace_DontHitEntity(int entity, int mask, any data)
{
	return entity!=data;
}

public bool Trace_OnlyPlayer(int entity, int mask, any data)
{
	if(entity > MaxClients || entity == 0)
	{
		return false;
	}
	
#if defined ZR
	else if(TeutonType[entity] != TEUTON_NONE)
	{
		return false;
	}
#endif
	
	return entity!=data;
}

public bool Trace_DontHitEntityOrPlayerOrAlliedNpc(int entity, int mask, any data)
{
	if(entity <= MaxClients)
	{
		
#if defined ZR
		if(entity != data) //make sure that they are not dead, if they are then just ignore them/give special shit
		{
			if(i_PreviousInteractedEntity[data] != entity || !i_PreviousInteractedEntityDo[data])
			{
				int Building_Index = EntRefToEntIndex(Building_Mounted[entity]);
				if(dieingstate[entity] > 0)
				{
					if(!b_LeftForDead[entity])
					{
						return entity!=data;
					}
					else
					{
						return false;	
					}
				}
				else if(Building_Index == 0 || !IsValidEntity(Building_Index))
				{
					return false;
				}
				return Building_Index!=data;
			}
		}
#else
		return false;
#endif
		
	}
	
#if defined ZR
	if(entity > MaxClients && !b_NpcHasDied[entity] && GetTeam(entity) == TFTeam_Red)
	{
		return false;
	}
#endif

	if(b_ThisEntityIgnored[entity] && i_IsABuilding[entity])
	{
		//if the building is ignored, prevent interaction with it.
		//Edit: if its a barricade this is ignored so they can reclaim it.
#if defined ZR
		if(i_NpcInternalId[entity] != ObjectBarricade_ID())
#endif	
			return false;
			
		//dont allow interaction within itself, i.e. i as the player cant ray trace my own mounted building
#if defined ZR
		if(data == EntRefToEntIndex(Building_Mounted[entity]))
			return false;
#endif
	}	
	if(i_PreviousInteractedEntity[data] == entity && i_PreviousInteractedEntityDo[data])
	{
		return false;
	}
	
	return entity!=data;
}

public bool Trace_DontHitEntityOrPlayer(int entity, int mask, any data)
{
	if(entity <= MaxClients)
	{
#if defined ZR
		if(entity != data) //make sure that they are not dead, if they are then just ignore them/give special shit
		{
			if(i_PreviousInteractedEntity[data] != entity || !i_PreviousInteractedEntityDo[data])
			{
				int Building_Index = EntRefToEntIndex(Building_Mounted[entity]);
				if(dieingstate[entity] > 0)
				{
					if(!b_LeftForDead[entity])
					{
						return entity!=data;
					}
					else
					{
						return false;	
					}
				}
				else if(Building_Index == 0 || !IsValidEntity(Building_Index))
				{
					return false;
				}
				return Building_Index!=data;
			}
		}
#else
		return false;
#endif		
	}
#if defined RPG
	else if(entity > MaxClients && entity < MAXENTITIES)
	{
		if(b_is_a_brush[entity])//THIS is for brushes that act as collision boxes for NPCS inside quests.sp
		{
			int entityfrombrush = BrushToEntity(entity);
			if(entityfrombrush != -1)
			{
				if(i_PreviousInteractedEntity[data] != entityfrombrush || !i_PreviousInteractedEntityDo[data])
				{
					return entityfrombrush!=data;
				}
			}
		}
		if(Textstore_CanSeeItem(entity, data))
		{
			if(i_PreviousInteractedEntity[data] != entity || !i_PreviousInteractedEntityDo[data])
			{
				return entity!=data;
			}
		}
		else if(!b_NpcHasDied[entity] && GetTeam(entity) == TFTeam_Red)
		{
			if(i_PreviousInteractedEntity[data] != entity || !i_PreviousInteractedEntityDo[data])
			{
				return entity!=data;
			}
		}
		else
		{
			return false;
		}
	}
#endif	

	if(b_ThisEntityIgnored[entity] && i_IsABuilding[entity])
	{
		//if the building is ignored, prevent interaction with it.
		//Edit: if its a barricade this is ignored so they can reclaim it.
#if defined ZR
		if(i_NpcInternalId[entity] != ObjectBarricade_ID())
			return false;

		//dont allow interaction within itself, i.e. i as the player cant ray trace my own mounted building
		if(data == EntRefToEntIndex(Building_Mounted[entity]))
			return false;
#else
		return false;
#endif
	}	
	
	if(i_PreviousInteractedEntity[data] == entity && i_PreviousInteractedEntityDo[data])
	{
		return false;
	}

	return entity!=data;
}


public bool Trace_DontHitAlivePlayer(int entity, int mask, any data)
{
	if(entity <= MaxClients)
	{
		if(entity != data)
		{
#if defined ZR
			if(dieingstate[entity] <= 0)
			{
				return false;
			}
			if(b_LeftForDead[entity])
#endif
			{
				return false;
			}
		}
	}
	
#if defined ZR
	else if(!Citizen_ThatIsDowned(entity))
#else
	else
#endif
	
	{
		return false;
	}

#if defined ZR
	if(f_Reviving_This_Client[data] > GetGameTime())
	{
		if(i_Reviving_This_Client[data] != entity)
		{
			return false;
		}
	}
#endif
	
	return entity!=data;
}

stock void GetAbsOrigin(int client, float v[3])
{
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", v);
}

stock bool IsValidClient( int client)
{	
	if ( client <= 0 || client > MaxClients )
		return false; 
	if ( !IsClientInGame( client ) ) 
		return false; 
		
	return true; 
}

stock bool IsBehindAndFacingTarget(int owner, int target, int weapon = -1)
{
	float vecToTarget[3], vecEyeAngles[3];
	WorldSpaceCenter(target, vecToTarget);
	WorldSpaceCenter(owner, vecEyeAngles);
	SubtractVectors(vecToTarget, vecEyeAngles, vecToTarget);

	vecToTarget[2] = 0.0;
	NormalizeVector(vecToTarget, vecToTarget);
	
	if(owner <= MaxClients)
		GetClientEyeAngles(owner, vecEyeAngles);
	else
		GetEntPropVector(owner, Prop_Data, "m_angRotation", vecEyeAngles);
		
	float vecOwnerForward[3];
	GetAngleVectors(vecEyeAngles, vecOwnerForward, NULL_VECTOR, NULL_VECTOR);
	vecOwnerForward[2] = 0.0;
	NormalizeVector(vecOwnerForward, vecOwnerForward);
	
	if(target <= MaxClients)
		GetClientEyeAngles(target, vecEyeAngles);
	else
		GetEntPropVector(target, Prop_Data, "m_angRotation", vecEyeAngles);

	float vecTargetForward[3];
	GetAngleVectors(vecEyeAngles, vecTargetForward, NULL_VECTOR, NULL_VECTOR);
	vecTargetForward[2] = 0.0;
	NormalizeVector(vecTargetForward, vecTargetForward);
	
	float flPosVsTargetViewDot = GetVectorDotProduct(vecToTarget, vecTargetForward);
	float flPosVsOwnerViewDot = GetVectorDotProduct(vecToTarget, vecOwnerForward);
	float flViewAnglesDot = GetVectorDotProduct(vecTargetForward, vecOwnerForward);
	if(weapon > 0)
	{
#if defined ZR
		if(b_BackstabLaugh[weapon])
		{
			int AllCorrect = 0;
			if(flPosVsTargetViewDot > -0.6)
				AllCorrect++;

			if(flPosVsOwnerViewDot > 0.5)
				AllCorrect++;
				
			if(flViewAnglesDot > -0.8)
				AllCorrect++;
			
			if(AllCorrect >= 3)
				return true;
			else
				return false;
		}
#endif
	}
	return ( flPosVsTargetViewDot > 0.0 && flPosVsOwnerViewDot > 0.5 && flViewAnglesDot > -0.3 );
}

stock float AngleDiff(float firstAngle, float secondAngle)
{
	float diff = secondAngle - firstAngle;
	return AngleNormalize(diff);
}

stock float AngleNormalize(float angle)
{
	while (angle > 180.0) angle -= 360.0;
	while (angle < -180.0) angle += 360.0;
	return angle;
}

stock void DoOverlay(int client, const char[] overlay, int Methods = 0)
{
	if(Methods == 1 || Methods == 2)
	{
		int flags = GetCommandFlags("r_screenoverlay");
		SetCommandFlags("r_screenoverlay", flags & ~FCVAR_CHEAT);
		if(overlay[0])
		{
			ClientCommand(client, "r_screenoverlay \"%s\"", overlay);
		}
		else
		{
			ClientCommand(client, "r_screenoverlay off");
		}
		SetCommandFlags("r_screenoverlay", flags);
	}
	if(Methods == 0 || Methods == 2)
	{
		SetEntPropString(client, Prop_Send, "m_szScriptOverlayMaterial", overlay);
	}
}

public bool PlayersOnly(int entity, int contentsMask, any iExclude)
{
	if(entity > MAXPLAYERS)
	{
		return false;
	}
	
	else if(GetTeam(iExclude) != GetTeam(entity))
		return false;
		
	
	return !(entity == iExclude);
}

stock bool Client_Shake(int client, int command=SHAKE_START, float amplitude=50.0, float frequency=150.0, float duration=3.0, bool respectSetting = true)
{
	//allow settings for the sick who cant handle screenshake.
	//can cause headaches.
	if(respectSetting && !b_HudScreenShake[client])
	{
		return false;
	}
	if (command == SHAKE_STOP) {
		amplitude = 0.0;
	}
	else if (amplitude <= 0.0) {
		return false;
	}

	Handle userMessage = StartMessageOne("Shake", client);

	if (userMessage == INVALID_HANDLE) {
		return false;
	}

	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available
		&& GetUserMessageType() == UM_Protobuf) {

		PbSetInt(userMessage,   "command",		 command);
		PbSetFloat(userMessage, "local_amplitude", amplitude);
		PbSetFloat(userMessage, "frequency",	   frequency);
		PbSetFloat(userMessage, "duration",		duration);
	}
	else {
		BfWriteByte(userMessage,	command);	// Shake Command
		BfWriteFloat(userMessage,	amplitude);	// shake magnitude/amplitude
		BfWriteFloat(userMessage,	frequency);	// shake noise frequency
		BfWriteFloat(userMessage,	duration);	// shake lasts this long
	}

	EndMessage();

	return true;
}

stock void PrintKeyHintText(int client, const char[] format, any ...)
{
	char buffer[254]; //maybe 255 is the limit.
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);

	Handle userMessage = StartMessageOne("KeyHintText", client);
	if(userMessage == INVALID_HANDLE)
		return;

	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType")==FeatureStatus_Available && GetUserMessageType()==UM_Protobuf)
	{
		PbSetString(userMessage, "hints", buffer);
	}
	else
	{
		BfWriteByte(userMessage, 1); 
		BfWriteString(userMessage, buffer); 
	}
	
	EndMessage();
}

stock int FindEntityByClassname2(int startEnt, const char[] classname)
{
	while(startEnt>-1 && !IsValidEntity(startEnt))
	{
		startEnt--;
	}
	return FindEntityByClassname(startEnt, classname);
}

stock bool IsEven( int iNum )
{
	return iNum % 2 == 0;
} 

stock bool IsInvuln(int client, bool IgnoreNormalUber = false) //Borrowed from Batfoxkid
{
	if(!IsValidClient(client))
	{
		if(!IsValidEntity(client))
		{
			return false;
		}
		if(HasSpecificBuff(client, "Unstoppable Force"))
			return true;

		if(b_NpcIsInvulnerable[client])
			return true;
		
		return false;
	}

	if(!IgnoreNormalUber)
	{
		if(HasSpecificBuff(client, "UBERCHARGED"))
			return true;
		return (TF2_IsPlayerInCondition(client, TFCond_Ubercharged) ||
			TF2_IsPlayerInCondition(client, TFCond_UberchargedCanteen) ||
			TF2_IsPlayerInCondition(client, TFCond_UberchargedHidden) ||
			TF2_IsPlayerInCondition(client, TFCond_UberchargedOnTakeDamage) ||
			TF2_IsPlayerInCondition(client, TFCond_Bonked) ||
			TF2_IsPlayerInCondition(client, TFCond_HalloweenGhostMode) ||
			//TF2_IsPlayerInCondition(client, TFCond_MegaHeal) ||
			!GetEntProp(client, Prop_Data, "m_takedamage"));

	}
	else
	{

		return (TF2_IsPlayerInCondition(client, TFCond_UberchargedCanteen) ||
			TF2_IsPlayerInCondition(client, TFCond_UberchargedHidden) ||
			TF2_IsPlayerInCondition(client, TFCond_UberchargedOnTakeDamage) ||
			TF2_IsPlayerInCondition(client, TFCond_Bonked) ||
			TF2_IsPlayerInCondition(client, TFCond_HalloweenGhostMode) ||
			//TF2_IsPlayerInCondition(client, TFCond_MegaHeal) ||
			!GetEntProp(client, Prop_Data, "m_takedamage"));		
	}
}

stock void ModelIndexToString(int index, char[] model, int size)
{
	int table = FindStringTable("modelprecache");
	ReadStringTable(table, index, model, size);
}

stock int ParseColor(char[] colorStr)
{
	int ret = 0;
	ret |= charToHex(colorStr[0])<<20;
	ret |= charToHex(colorStr[1])<<16;
	ret |= charToHex(colorStr[2])<<12;
	ret |= charToHex(colorStr[3])<<8;
	ret |= charToHex(colorStr[4])<<4;
	ret |= charToHex(colorStr[5]);
	return ret;
}

stock void VectorRotate(float inPoint[3], float angles[3], float outPoint[3])
{
	float matRotate[3][4];
	AngleMatrix(angles, matRotate);
	VectorRotate2(inPoint, matRotate, outPoint);
}


stock void VectorRotate2(float in1[3], float in2[3][4], float out[3])
{
	out[0] = DotProduct(in1, in2[0]);
	out[1] = DotProduct(in1, in2[1]);
	out[2] = DotProduct(in1, in2[2]);
}

stock float ClampBeamWidth(float w) { return w > 128.0 ? 128.0 : w; }
stock int GetR(int c) { return abs((c>>16)&0xff); }
stock int GetG(int c) { return abs((c>>8 )&0xff); }
stock int GetB(int c) { return abs((c	)&0xff); }



stock void ConformLineDistance(float result[3], const float src[3], const float dst[3], float maxDistance, bool canExtend = false)
{
	float distance = GetVectorDistance(src, dst);
	if (distance <= maxDistance && !canExtend)
	{
		// everything's okay.
		result[0] = dst[0];
		result[1] = dst[1];
		result[2] = dst[2];
	}
	else
	{
		// need to find a point at roughly maxdistance. (FP irregularities aside)
		float distCorrectionFactor = maxDistance / distance;
		result[0] = ConformAxisValue(src[0], dst[0], distCorrectionFactor);
		result[1] = ConformAxisValue(src[1], dst[1], distCorrectionFactor);
		result[2] = ConformAxisValue(src[2], dst[2], distCorrectionFactor);
	}
}


stock void SetColorRGBA(int color[4], int r, int g, int b, int a)
{
	color[0] = abs(r)%256;
	color[1] = abs(g)%256;
	color[2] = abs(b)%256;
	color[3] = abs(a)%256;
}


/*stock float DEG2RAD(float n)
{
	return n * 0.017453;
}*/

stock float DotProduct(float v1[3], float v2[4])
{
	return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}

stock int charToHex(int c)
{
	if (c >= '0' && c <= '9')
		return c - '0';
	else if (c >= 'a' && c <= 'f')
		return c - 'a' + 10;
	else if (c >= 'A' && c <= 'F')
		return c - 'A' + 10;
	
	// this is a user error, so print this out (it won't spam)
	PrintToConsoleAll("Invalid hex character, probably while parsing something's color. Please only use 0-9 and A-F in your color. c=%d", c);
	return 0;
}
stock float ConformAxisValue(float src, float dst, float distCorrectionFactor)
{
	return src - ((src - dst) * distCorrectionFactor);
}

stock void AngleMatrix(float angles[3], float matrix[3][4])
{
	float sr = 0.0;
	float sp = 0.0;
	float sy = 0.0;
	float cr = 0.0;
	float cp = 0.0;
	float cy = 0.0;
	sy = Sine(DEG2RAD(angles[1]));
	cy = Cosine(DEG2RAD(angles[1]));
	sp = Sine(DEG2RAD(angles[0]));
	cp = Cosine(DEG2RAD(angles[0]));
	sr = Sine(DEG2RAD(angles[2]));
	cr = Cosine(DEG2RAD(angles[2]));
	matrix[0][0] = cp * cy;
	matrix[1][0] = cp * sy;
	matrix[2][0] = -sp;
	float crcy = cr * cy;
	float crsy = cr * sy;
	float srcy = sr * cy;
	float srsy = sr * sy;
	matrix[0][1] = sp * srcy - crsy;
	matrix[1][1] = sp * srsy + crcy;
	matrix[2][1] = sr * cp;
	matrix[0][2] = sp * crcy + srsy;
	matrix[1][2] = sp * crsy - srcy;
	matrix[2][2] = cr * cp;
	matrix[0][3] = 0.0;
	matrix[1][3] = 0.0;
	matrix[2][3] = 0.0;
}

public bool Base_Boss_Hit(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(entity != iExclude && (StrEqual(class, "obj_dispenser") || StrEqual(class, "obj_teleporter") || StrEqual(class, "obj_sentrygun")))
	{
		if(GetTeam(iExclude) == GetTeam(entity))
		{
			return true;
		}
		
		else if(GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed") >= 0.1)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
		
	
	return !(entity == iExclude);
}

public bool Detect_BaseBoss(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(!b_ThisWasAnNpc[entity])
	{
		return false;
	}
	
	if(entity != iExclude)
	{
		if(GetTeam(iExclude) == GetTeam(entity))
		{
			return false;
		}
		else
		{
			return true;
		}
	}
		
	
	return !(entity == iExclude);
}

stock void AnglesToVelocity(const float ang[3], float vel[3], float speed=1.0)
{
	vel[0] = Cosine(DegToRad(ang[1]));
	vel[1] = Sine(DegToRad(ang[1]));
	vel[2] = Sine(DegToRad(ang[0])) * -1.0;
	
	NormalizeVector(vel, vel);
	
	ScaleVector(vel, speed);
}

stock bool ObstactleBetweenEntities(int entity1, int entity2)
{
	static float pos1[3], pos2[3];
	if(IsValidClient(entity1))
	{
		GetClientEyePosition(entity1, pos1);
	}
	else
	{
		GetEntPropVector(entity1, Prop_Send, "m_vecOrigin", pos1);
	}

	GetEntPropVector(entity2, Prop_Send, "m_vecOrigin", pos2);

	Handle trace = TR_TraceRayFilterEx(pos1, pos2, MASK_ALL, RayType_EndPoint, Trace_DontHitEntity, entity1);

	bool hit = TR_DidHit(trace);
	int index = TR_GetEntityIndex(trace);
	delete trace;

	if(!hit || index!=entity2)
		return true;

	return false;
}

stock bool IsEntityStuck(int entity)
{
	static float minn[3], maxx[3], pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecMins", minn);
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxx);
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	TR_TraceHullFilter(pos, pos, minn, maxx, MASK_SOLID, Trace_DontHitEntity, entity);
	return (TR_DidHit());
}

#if defined _tf2items_included
stock int SpawnWeapon_Special(int client, char[] name, int index, int level, int qual, const char[] att, bool visible=true)
{
	if(StrEqual(name, "saxxy", false))	// if "saxxy" is specified as the name, replace with appropiate name
	{ 
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Scout:	ReplaceString(name, 64, "saxxy", "tf_weapon_bat", false);
			case TFClass_Pyro:	ReplaceString(name, 64, "saxxy", "tf_weapon_fireaxe", false);
			case TFClass_DemoMan:	ReplaceString(name, 64, "saxxy", "tf_weapon_bottle", false);
			case TFClass_Heavy:	ReplaceString(name, 64, "saxxy", "tf_weapon_fists", false);
			case TFClass_Engineer:	ReplaceString(name, 64, "saxxy", "tf_weapon_wrench", false);
			case TFClass_Medic:	ReplaceString(name, 64, "saxxy", "tf_weapon_bonesaw", false);
			case TFClass_Sniper:	ReplaceString(name, 64, "saxxy", "tf_weapon_club", false);
			case TFClass_Spy:	ReplaceString(name, 64, "saxxy", "tf_weapon_knife", false);
			default:		ReplaceString(name, 64, "saxxy", "tf_weapon_shovel", false);
		}
	}
	else if(StrEqual(name, "tf_weapon_shotgun", false))	// If using tf_weapon_shotgun for Soldier/Pyro/Heavy/Engineer
	{
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Pyro:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_pyro", false);
			case TFClass_Heavy:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_hwg", false);
			case TFClass_Engineer:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_primary", false);
			default:		ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_soldier", false);
		}
	}

	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if(hWeapon == INVALID_HANDLE)
		return -1;

	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	TF2Items_SetNumAttributes(hWeapon, 0);

	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	delete hWeapon;
	if(entity == -1)
		return -1;
	
	Attributes_EntityDestroyed(entity);
	
	char atts[32][32];
	int count = ExplodeString(att, ";", atts, 32, 32);

	if(count % 2)
		--count;
	
	for(int i; i < count; i += 2)
	{
		int attrib = StringToInt(atts[i]);
		if(attrib)
		{
			Attributes_Set(entity, attrib, StringToFloat(atts[i+1]));
		}
	}

	EquipPlayerWeapon(client, entity);

	if(visible)
	{
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
	}
	else
	{
		SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	}
	return entity;
}
#endif

stock void GetRayAngles(float startPoint[3], float endPoint[3], float angle[3])
{
	static float tmpVec[3];
	tmpVec[0] = endPoint[0] - startPoint[0];
	tmpVec[1] = endPoint[1] - startPoint[1];
	tmpVec[2] = endPoint[2] - startPoint[2];
	GetVectorAngles(tmpVec, angle);
}

public bool RW_IsValidHomingTarget(int target, int owner)
{
	if(!IsValidEntity(target))
		return false;
	
	if(b_NpcHasDied[target])
		return false;
	
	if(b_IsCamoNPC[target])
		return false;
		
	return true;
}

public bool TraceWallsOnly(int entity, int contentsMask)
{
	return false;
}

stock bool AngleWithinTolerance(float entityAngles[3], float targetAngles[3], float tolerance)
{
	static bool tests[2];
	
	for (int i = 0; i < 2; i++)
		tests[i] = fabs(entityAngles[i] - targetAngles[i]) <= tolerance || fabs(entityAngles[i] - targetAngles[i]) >= 360.0 - tolerance;
	
	return tests[0] && tests[1];
}

stock float fixAngle(float angle)
{
	int sanity = 0;
	while (angle < -180.0 && (sanity++) <= 10)
		angle = angle + 360.0;
	while (angle > 180.0 && (sanity++) <= 10)
		angle = angle - 360.0;
		
	return angle;
}

#if defined _tf2items_included
stock int Spawn_Buildable(int client, int AllowBuilding = -1)
{
	int entity = SpawnWeapon(client, "tf_weapon_builder", 28, 1, 0, view_as<int>({148}), view_as<float>({1.0}), 1); 
	if(entity > MaxClients)
	{
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
		SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));
		Attributes_Set(entity, 148, 0.0);
		
		if(AllowBuilding == -1)
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		else if(AllowBuilding == 0)
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		else if(AllowBuilding == 2)
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", true, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		else
		{
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 0); //Dispenser
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 1); //Teleporter
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 2); //Sentry
			SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, 3);
		}
		
	//	PrintToChatAll("%i",GetEntPropEnt(entity, Prop_Send, "m_hOwner"));
		
		Attributes_Set(client, 353, 1.0);
		
		Attributes_Set(entity, 292, 3.0);
		Attributes_Set(entity, 293, 59.0);
		Attributes_Set(entity, 495, 60.0); //Kill eater score shit, i dont know.
	//	TF2_SetPlayerClass_ZR(client, TFClass_Engineer);
		return entity;
	}	
	return -1;
}
#endif

public void CreateEarthquake(float position[3], float duration, float radius, float amplitude, float frequency)
{
	int earthquake = CreateEntityByName("env_shake");
	if (IsValidEntity(earthquake))
	{
	
		DispatchKeyValueFloat(earthquake, "amplitude", amplitude);
		DispatchKeyValueFloat(earthquake, "radius", radius * 2);
		DispatchKeyValueFloat(earthquake, "duration", duration + 1.0);
		DispatchKeyValueFloat(earthquake, "frequency", frequency);

		SetVariantString("spawnflags 4"); // no physics (physics is 8), affects people in air (4)
		AcceptEntityInput(earthquake, "AddOutput");

		// create
		DispatchSpawn(earthquake);
		TeleportEntity(earthquake, position, NULL_VECTOR, NULL_VECTOR);

		AcceptEntityInput(earthquake, "StartShake", 0);
		CreateTimer(duration + 0.1, Timer_RemoveEntity, EntIndexToEntRef(earthquake), TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock bool TF2U_GetWearable(int client, int &entity, int &index, const char[] classname = "tf_wear*")
{
	/*#if defined __nosoop_tf2_utils_included
	if(Loaded)
	{
		int length = TF2Util_GetPlayerWearableCount(client);
		while(index < length)
		{
			entity = TF2Util_GetPlayerWearable(client, index++);
			if(entity > MaxClients)
				return true;
		}
	}
	else
	#endif*/
	{
		if(index >= -1 && index <= MaxClients)
			index = MaxClients + 1;
		
		if(index > -2)
		{
			while((index=FindEntityByClassname(index, classname)) != -1)
			{
				if(GetEntPropEnt(index, Prop_Send, "m_hOwnerEntity") == client)
				{
					entity = index;
					return true;
				}
			}
			
			index = -(MaxClients + 1);
		}
		
		entity = -index;
		while((entity=FindEntityByClassname(entity, "tf_powerup_bottle")) != -1)
		{
			if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
			{
				index = -entity;
				return true;
			}
		}
	}
	return false;
}

stock void spawnRing(int client, float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0, bool personal = false) //Spawns a TE beam ring at a client's/entity's location
{
	if (IsValidEntity(client))
	{
		float center[3];
		
		if (IsValidMulti(client, true, true, false)) //If our entity is a living player, grab their abs origin
		{
			GetClientAbsOrigin(client, center);
		}
		else if (client > MaxClients) //If our entity is just an entity, grab its m_vecOrigin
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", center);
		}
		
		if (IsValidMulti(client, true, false, false)) //If the entity is a dead player, abort
		{
			return;
		}
		
		center[0] += modif_X;
		center[1] += modif_Y;
		center[2] += modif_Z;
		
		
		int ICE_INT = PrecacheModel(sprite);
		
		int color[4];
		color[0] = r;
		color[1] = g;
		color[2] = b;
		color[3] = alpha;
		
		if (endRange == -69.0)
		{
			endRange = range + 0.5;
		}
		
		TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
		if(personal)
		{
			TE_SendToClient(client);
		}
		else
		{
			TE_SendToAll();
		}
	}
}

stock bool IsSpaceOccupiedIgnorePlayersOnlyNpc(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayOnlyNpc, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask) //Borrowed from Apocalips
{
	return entity > MaxClients;
}

public bool TraceRayOnlyNpc(int entity, int contentsMask, any data)
{
	static char class[12];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(StrEqual(class, "zr_base_npc"))
		return true;

	if(StrEqual(class, "zr_base_stationary"))
		return true;
	
	return !(entity == data);
}

stock bool IsValidMulti(int client, bool checkAlive=true, bool isAlive=true, bool checkTeam=false, int team=TFTeam_Red) //An extension of IsValidClient that also checks for boss status, alive-ness, and optionally a team. Send is used for debug purposes to inform the programmer when and why this stock returns false.
{
	if (!IsValidClient(client)) //Self-explanatory
	{
		return false;
	}
	
	if (checkAlive) //Do we want to check if the player is alive?
	{
		if (isAlive && !IsPlayerAlive(client)) //If we need the player to be alive, but they're dead, return false.
		{
			return false;
		}
		if (!isAlive && IsPlayerAlive(client)) //If we need the player to be dead, but they're alive, return false.
		{
			return false;
		}
	}
	
	if (checkTeam) //Do we want to check the client's team?
	{
		if (GetTeam(client) != team) //If they aren't on the desired team, return false.
		{
			return false;
		}
	}
	return true; //If all desired conditions are met, return true.
}

public bool AntiTraceEntityFilterPlayer(int entity, any contentsMask) //Borrowed from Apocalips
{
	return entity <= MaxClients;
}

#define EXPLOSION_PARTICLE_SMALL_1 "ExplosionCore_MidAir"
#define EXPLOSION_PARTICLE_SMALL_2 "ExplosionCore_buildings"
#define EXPLOSION_PARTICLE_SMALL_3 "ExplosionCore_Wall"
#define EXPLOSION_PARTICLE_SMALL_4 "rd_robot_explosion"

public void SpawnSmallExplosion(float DetLoc[3])
{
	float pos[3];
	pos[0] += DetLoc[0] + GetRandomFloat(-25.0, 25.0);
	pos[1] += DetLoc[1] + GetRandomFloat(-25.0, 25.0);
	pos[2] += DetLoc[2] + GetRandomFloat(0.0, 25.0);
	
	TE_Particle(EXPLOSION_PARTICLE_SMALL_1, pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
}

public void SpawnSmallExplosionNotRandom(float DetLoc[3])
{
	TE_Particle(EXPLOSION_PARTICLE_SMALL_1, DetLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
}

stock void GetVectorAnglesTwoPoints(const float startPos[3], const float endPos[3], float angles[3])
{
	static float tmpVec[3];
	tmpVec[0] = endPos[0] - startPos[0];
	tmpVec[1] = endPos[1] - startPos[1];
	tmpVec[2] = endPos[2] - startPos[2];
	GetVectorAngles(tmpVec, angles);
}

stock void TE_DrawBox(int client, float m_vecOrigin[3], float m_vecMins[3], float m_vecMaxs[3], float flDur = 0.1, const int color[4])
{
	//Trace top down
	/*
	float tStart[3]; tStart = m_vecOrigin;
	
	tStart[2] = (tStart[2] + m_vecMaxs[2]);
	*/
//	TE_ShowPole(tStart, view_as<int>( { 255, 0, 255, 255 } ));
//	TE_ShowPole(tEnd, view_as<int>( { 0, 255, 255, 255 } ));
	/*
	Handle trace = TR_TraceHullFilterEx(tStart, tEnd, m_vecMins, m_vecMaxs, MASK_SHOT|CONTENTS_GRATE, IngorePlayersAndBuildingsHull, client);
	bool bDidHit = TR_DidHit(trace);
	*/
	/*
	if( m_vecMins[0] == m_vecMaxs[0] && m_vecMins[1] == m_vecMaxs[1] && m_vecMins[2] == m_vecMaxs[2] )
	{
		m_vecMins = view_as<float>({-15.0, -15.0, -15.0});
		m_vecMaxs = view_as<float>({15.0, 15.0, 15.0});
	}
	else
	{
		*/
	AddVectors(m_vecOrigin, m_vecMaxs, m_vecMaxs);
	AddVectors(m_vecOrigin, m_vecMins, m_vecMins);
//	}
	
	float vPos1[3], vPos2[3], vPos3[3], vPos4[3], vPos5[3], vPos6[3];
	vPos1 = m_vecMaxs;
	vPos1[0] = m_vecMins[0];
	vPos2 = m_vecMaxs;
	vPos2[1] = m_vecMins[1];
	vPos3 = m_vecMaxs;
	vPos3[2] = m_vecMins[2];
	vPos4 = m_vecMins;
	vPos4[0] = m_vecMaxs[0];
	vPos5 = m_vecMins;
	vPos5[1] = m_vecMaxs[1];
	vPos6 = m_vecMins;
	vPos6[2] = m_vecMaxs[2];

	TE_SendBeam(client, m_vecMaxs, vPos1, flDur, color);
	TE_SendBeam(client, m_vecMaxs, vPos2, flDur, color);
	TE_SendBeam(client, m_vecMaxs, vPos3, flDur, color);
	TE_SendBeam(client, vPos6, vPos1, flDur, color);
	TE_SendBeam(client, vPos6, vPos2, flDur, color);
	TE_SendBeam(client, vPos6, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos4, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos5, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos5, vPos1, flDur, color);
	TE_SendBeam(client, vPos5, vPos3, flDur, color);
	TE_SendBeam(client, vPos4, vPos3, flDur, color);
	TE_SendBeam(client, vPos4, vPos2, flDur, color);
	/*
	for( int i = 0; i < 3; i++ ) 
	{
	//	tStart[i] = 0.0;
		vPos1[i] = 0.0;
		vPos2[i] = 0.0;
		vPos3[i] = 0.0;
		vPos4[i] = 0.0;
		vPos5[i] = 0.0;
		vPos6[i] = 0.0;
		m_vecMaxs[i] = 0.0;
		m_vecMins[i] = 0.0;
	}
	*/
//	delete trace;
	
//	return true;
}

void TE_SendBeam(int client, float m_vecMins[3], float m_vecMaxs[3], float flDur = 0.1, const int color[4])
{
	TE_SetupBeamPoints(m_vecMins, m_vecMaxs, g_iLaserMaterial_Trace, g_iHaloMaterial_Trace, 0, 0, flDur, 1.0, 1.0, 1, 0.0, color, 0);
	TE_SendToClient(client);
}


stock int Target_Hit_Wand_Detection(int owner_projectile, int other_entity)
{
	if(owner_projectile < 1)
	{
		return -1; //I dont exist?
	}
	if(other_entity < 0)
	{
		return -1; //I dont exist?
	}
	else if(other_entity == 0)
	{
		return 0;
	}
	else if(b_ThisEntityIsAProjectileForUpdateContraints[owner_projectile] && b_ThisEntityIsAProjectileForUpdateContraints[other_entity])
	{
		return -1;
	}
	//Re-use b_AllowCollideWithSelfTeam here
	else if(!b_AllowCollideWithSelfTeam[owner_projectile] && i_IsABuilding[other_entity])
	{
		return -1;
	}
#if defined ZR
	else if(GetTeam(other_entity) == TFTeam_Red)
	{
		if(b_NpcIsTeamkiller[owner_projectile])
			return other_entity;
		else
			return -1;
	}
#endif
	else if(other_entity <= MaxClients)
	{
#if defined RPG
		if(RPGCore_PlayerCanPVP(owner_projectile, other_entity))
			return other_entity;
		else
			return -1;
#else
			return -1;
#endif	
	}
//	else if(IsValidEnemy(owner_projectile, other_entity, true, true))
	else if(!b_NpcHasDied[other_entity]) //way less cheap, lets see how that goes.
	{
#if defined RPG
	int owner = GetEntPropEnt(owner_projectile, Prop_Send, "m_hOwnerEntity");
	if(OnTakeDamageRpgPartyLogic(other_entity, owner, GetGameTime()))
		return -1;
#endif
		return other_entity;
	}
	return 0;
}


stock void CalculateDamageForce( const float vecBulletDir[3], float flScale, float vecForce[3])
{
	vecForce = vecBulletDir;
	NormalizeVector( vecForce, vecForce );
	ScaleVector(vecForce, FindConVar("phys_pushscale").FloatValue);
	ScaleVector(vecForce, flScale);
}

stock void CalculateDamageForceSelfCalculated(int client, float flScale, float vec[3])
{
	float vecSwingForward[3];
	float ang[3];
	GetClientEyeAngles(client, ang);
	
	GetAngleVectors(ang, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	
	CalculateDamageForce(vecSwingForward, flScale, vec);
}

float ImpulseScale( float flTargetMass, float flDesiredSpeed )
{
	return (flTargetMass * flDesiredSpeed);
}

#define INNER_RADIUS_FRACTION 0.25


void CalculateExplosiveDamageForce(const float vec_Explosive[3], const float vecEndPosition[3], float damage_Radius, float vecForce[3])
{
	float flClampForce = ImpulseScale( 75.0, 400.0 );

	// Calculate an impulse large enough to push a 75kg man 4 in/sec per point of damage
	float flForceScale = 100.0 * ImpulseScale( 75.0, 4.0 );

	if( flForceScale > flClampForce )
		flForceScale = flClampForce;

	// Fudge blast forces a little bit, so that each
	// victim gets a slightly different trajectory. 
	// This simulates features that usually vary from
	// person-to-person variables such as bodyweight,
	// which are all indentical for characters using the same model.
	flForceScale *= GetRandomFloat( 0.85, 1.15 );
	
	float vecSegment[3];
	float Ignore[3];
	SubtractVectors( vec_Explosive, vecEndPosition, vecSegment ); 
	float flDistance;
	
	flDistance = NormalizeVector( vecSegment, Ignore );
		
	float flFactor = 1.0 / ( damage_Radius * (INNER_RADIUS_FRACTION - 1.0) );
	float flFactor_Post = flFactor * flFactor;
	float flScale = flDistance - damage_Radius;
	float flScale_Post = flScale * flScale * flFactor_Post;
	
	if ( flScale_Post > 1.0 ) 
	{ 
		flScale_Post = 1.0; 
	}
	else if ( flScale_Post < 0.35 ) 
	{ 
		flScale_Post = 0.35; 
	}
		
	// Calculate the vector and stuff it into the takedamageinfo
	vecForce = vecSegment;
	NormalizeVector( vecForce, vecForce );
	ScaleVector(vecForce, flForceScale);
	ScaleVector(vecForce, FindConVar("phys_pushscale").FloatValue);
	ScaleVector(vecForce, flScale_Post);
	
	vecForce[0] *= -1.0;
	vecForce[1] *= -1.0;
	vecForce[2] *= -1.0;
}
int SavedFromLastTimeCount = 0;
int CountPlayersOnRed(int alive = 0, bool saved = false)
{
	if(saved)
		return SavedFromLastTimeCount;

	int amount;
	for(int client=1; client<=MaxClients; client++)
	{
#if defined ZR
		if(!b_IsPlayerABot[client] && b_HasBeenHereSinceStartOfWave[client] && IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING)
#else
		if(!b_IsPlayerABot[client] && IsClientInGame(client) && GetClientTeam(client)==2)
#endif
		{
			if(alive == 0)
			{
				amount++;
				continue;
			}
#if defined ZR
			else
			{
				if(alive == 1) //check if just not teuton
				{
					if(TeutonType[client] == TEUTON_NONE)
					{
						amount++;
						continue;
					}
				}
				else if(alive == 2) //check if downed too
				{
					if(TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
					{
						amount++;
						continue;
					}
				}
			}
#endif
		}
	}
	SavedFromLastTimeCount = amount;
	return amount;
	
}
#if defined ZR

//alot is  borrowed from CountPlayersOnRed
float ZRStocks_PlayerScalingDynamic(float rebels = 0.5, bool IgnoreMulti = false, bool IgnoreLevelLimit = false)
{
	//dont be 0
	float ScaleReturn = 0.01;
	for(int client=1; client<=MaxClients; client++)
	{
		if(!b_IsPlayerABot[client] && b_HasBeenHereSinceStartOfWave[client] && IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING)
		{ 
			if(!IgnoreLevelLimit && Database_IsCached(client) && Level[client] <= 20)
			{
				float CurrentLevel = float(Level[client]);
				CurrentLevel += 20.0;
				//so lvl 0 is atleast resulting in 0.5 Scaling
				ScaleReturn += (CurrentLevel / 40.0);
			}
			else
			{
				ScaleReturn += 1.0;
			}
		}
	}
	
	//in construction mode, rebels are not THAT usefull toi warrant extra scaling, so it is blocked in this mode.
	if(!Construction_Mode())
		if(rebels)
			ScaleReturn += Citizen_Count() * rebels;

	if(!IgnoreMulti)
		ScaleReturn *= zr_multi_scaling.FloatValue;
	
	return ScaleReturn;
}

#endif


int CountPlayersOnServer()
{
	int amount;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientConnected(client))
		{
			if(!IsFakeClient(client))
				amount++;
		}
	}
	
	return amount;
	
}

void Projectile_DealElementalDamage(int victim, int attacker, float Scale = 1.0)
{
#if defined ZR
	if(i_ChaosArrowAmount[attacker] > 0)
	{
		Elemental_AddChaosDamage(victim, attacker, RoundToCeil(float(i_ChaosArrowAmount[attacker]) * Scale));
	}
	if(i_VoidArrowAmount[attacker] > 0)
	{
		Elemental_AddVoidDamage(victim, attacker, RoundToCeil(float(i_VoidArrowAmount[attacker]) * Scale));
	}
#endif
	if(i_NervousImpairmentArrowAmount[attacker] > 0)
	{
#if defined ZR
		Elemental_AddNervousDamage(victim, attacker, RoundToCeil(float(i_NervousImpairmentArrowAmount[attacker]) * Scale));
#elseif defined RPG
		SeaShared_DealCorrosion(victim, attacker, RoundToCeil(float(i_NervousImpairmentArrowAmount[attacker]) * Scale));
#endif
	}
}


stock void Explode_Logic_Custom(float damage,
int client, //To get attributes from and to see what is my enemy!
int entity,	//Entity that gets forwarded or traced from/Distance checked.
int weapon,	//What to get attributes from aswell, if its from an npc, always -1
//Idealy: entity is projectile if its a projectile weapon
//If its happening from an NPC or player itself, set both client and entity to the same thing.
float spawnLoc[3] = {0.0,0.0,0.0},
float explosionRadius = EXPLOSION_RADIUS,
float ExplosionDmgMultihitFalloff = EXPLOSION_AOE_DAMAGE_FALLOFF,
float explosion_range_dmg_falloff = EXPLOSION_RANGE_FALLOFF,
bool FromBlueNpc = false,
int maxtargetshit = 10,
bool ignite = false,
float dmg_against_entity_multiplier = 3.0,
Function FunctionToCallOnHit = INVALID_FUNCTION,
Function FunctionToCallBeforeHit = INVALID_FUNCTION,
int inflictor = 0)
{

	float damage_reduction = 1.0;

#if defined ZR || defined RPG
	if(IsValidEntity(weapon))
	{
		float value = Attributes_Get(weapon, 99, 1.0);//increased blast radius attribute (Check weapon only)
		explosionRadius *= value;
		if(maxtargetshit == 10)
			maxtargetshit = RoundToNearest(Attributes_Get(weapon, 4011, 10.0));

		if(ExplosionDmgMultihitFalloff == EXPLOSION_AOE_DAMAGE_FALLOFF)
			ExplosionDmgMultihitFalloff = Attributes_Get(weapon, 4013, EXPLOSION_AOE_DAMAGE_FALLOFF);

		if(explosion_range_dmg_falloff == EXPLOSION_RANGE_FALLOFF)
			explosion_range_dmg_falloff = Attributes_Get(weapon, Attrib_OverrideExplodeDmgRadiusFalloff, EXPLOSION_RANGE_FALLOFF);
	}
#endif

	//this should make explosives during raids more usefull.
	if(!FromBlueNpc) //make sure that there even is any valid npc before we do these huge calcs.
	{ 
		if(entity > 0 && spawnLoc[0] == 0.0)
		{
			if(b_ThisWasAnNpc[entity])
			{
				WorldSpaceCenter(entity, spawnLoc);
			}
			else
			{	
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", spawnLoc);
				spawnLoc[2] += 5.0;
			}
		}
	}
	else //only nerf blue npc radius!
	{
		explosionRadius *= 0.90;
		if(explosion_range_dmg_falloff != EXPLOSION_RANGE_FALLOFF)
		{
			explosion_range_dmg_falloff = 0.8;
		}
		if(entity > 0 && spawnLoc[0] == 0.0) //only get position if thhey got notin
		{
			if(b_ThisWasAnNpc[entity])
			{
				WorldSpaceCenter(entity, spawnLoc);
			}
			else
			{	
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", spawnLoc);
				spawnLoc[2] += 5.0;
			}
		} 
	}
	
	int damage_flags = 0;
	int custom_flags = 0;
	if((i_ExplosiveProjectileHexArray[entity] & EP_DEALS_CLUB_DAMAGE))
	{
		damage_flags |= DMG_CLUB;
	}
	if((i_ExplosiveProjectileHexArray[entity] & EP_DEALS_PLASMA_DAMAGE))
	{
		damage_flags |= DMG_PLASMA;
	}
	if((i_ExplosiveProjectileHexArray[entity] & EP_DEALS_TRUE_DAMAGE))
	{
		damage_flags |= DMG_TRUEDAMAGE;
	}
	if(damage_flags == 0)
	{
		damage_flags |= DMG_BLAST;
	}

	if((i_ExplosiveProjectileHexArray[entity] & EP_GIBS_REGARDLESS))
	{
		custom_flags |= ZR_DAMAGE_GIB_REGARDLESS;
	}
	if((i_ExplosiveProjectileHexArray[entity] & EP_IS_ICE_DAMAGE))
	{
		custom_flags |= ZR_DAMAGE_ICE;
	}
	if((i_ExplosiveProjectileHexArray[entity] & EP_IS_ICE_DAMAGE))
	{
		custom_flags |= ZR_DAMAGE_ICE;
	}
	
	if((i_ExplosiveProjectileHexArray[entity] & ZR_DAMAGE_IGNORE_DEATH_PENALTY))
	{
		custom_flags |= ZR_DAMAGE_IGNORE_DEATH_PENALTY;
	}
	int entityToEvaluateFrom = 0;
	int EntityToForward = 0;

	if(IsValidEntity(entity))
	{
		EntityToForward = entity;
	}
	else
	{
		EntityToForward = client;
	}

	if(IsValidEntity(client))
	{
		entityToEvaluateFrom = client;
	}
	else
	{
		entityToEvaluateFrom = entity;
	}

	if(inflictor == 0)
	{
		inflictor = entityToEvaluateFrom;
	}

	if(entityToEvaluateFrom < 1)
	{
		//something went wrong, evacuate.
		LogError("something went wrong, entity was : [%i] | Client if any: [%i]",entityToEvaluateFrom, client);
		return;
	}
	//I exploded, do custom logic additionally if neccecary.
	if(i_ProjectileExtraFunction[entity] != INVALID_FUNCTION)
	{
		Call_StartFunction(null, i_ProjectileExtraFunction[entity]);
		Call_PushCell(entity);
		Call_PushFloat(damage);
		Call_PushArray(spawnLoc, sizeof(spawnLoc));
		Call_Finish();
		//info to give:
		/*
			Who the originator is
			Whats the original damage
			where did i explode
		*/
	}
	ArrayList HitEntitiesSphereExplosionTrace = new ArrayList();
	DoExlosionTraceCheck(spawnLoc, explosionRadius, entityToEvaluateFrom, HitEntitiesSphereExplosionTrace);
	/*
	This trace does not filter on what is hit first, thats kinda bad, it filters by what entity number is smaller.
	solution: Trace all entities, get all their distances, and do a rating, with this we get what entity is the closest
	and then  do the rest from there
	downside: still no solution to the fucking distance checks, but it is still 10x better then doing 4k checks all the time
	*/

	//This will sort the entity in order, first entity is the first to be hit there etc.
	static float distance[MAXENTITIES];
	static float VicPos[MAXENTITIES][3];

	if(FromBlueNpc && maxtargetshit == 10) //Npcs do not have damage falloff, dodge.
	{
		maxtargetshit = 20; //we do not care.
	}
	
	int length = HitEntitiesSphereExplosionTrace.Length;
	for (int i = 0; i < length; i++)
	{
		int entity_traced = HitEntitiesSphereExplosionTrace.Get(i);
		
		WorldSpaceCenter(entity_traced, VicPos[entity_traced]);
		distance[entity_traced] = GetVectorDistance(VicPos[entity_traced], spawnLoc, true);
		//Save their distances.
	}
	
	//do another check, this time we only need the amount of entities we actually hit.
	//Im lazy and dumb, i dont know a better way.

	
	for (int repeatloop = 0; repeatloop < maxtargetshit && length > 0; repeatloop++)
	{
		float ClosestDistance;
		int ClosestIndex;
		for (int i = 0; i < length; i++)
		{
			int entity_traced = HitEntitiesSphereExplosionTrace.Get(i);
			
			if( ClosestDistance ) 
			{
				if( distance[entity_traced] < ClosestDistance ) 
				{
					ClosestIndex = i; 
					ClosestDistance = distance[entity_traced];  
				}
			} 
			else 
			{
				ClosestIndex = i; 
				ClosestDistance = distance[entity_traced];
			}
		}

		int ClosestTarget = HitEntitiesSphereExplosionTrace.Get(ClosestIndex);
		HitEntitiesSphereExplosionTrace.Erase(ClosestIndex);
		length--;
		
	//	We will filter out each entity and them damage them accordingly.
		
		if(IsValidEntity(ClosestTarget))
		{	
			static float vicpos[3];
			vicpos = VicPos[ClosestTarget];
			//if its a blue npc, then we want to do a trace to see if we even hit them.
			if(FromBlueNpc)
			{
				Handle trace; 
				trace = TR_TraceRayFilterEx(spawnLoc, vicpos, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, HitOnlyTargetOrWorld, ClosestTarget);
				int Traced_Target;
									
				Traced_Target = TR_GetEntityIndex(trace);
				delete trace;
									
				if(Traced_Target != ClosestTarget)
				{	
					continue;
				}
			}
			if(ignite)
			{
				NPC_Ignite(ClosestTarget, entityToEvaluateFrom, 5.0, weapon);
			}
			static float damage_1;
			damage_1 = damage;

			if(ShouldNpcDealBonusDamage(ClosestTarget))
			{
				damage_1 *= dmg_against_entity_multiplier; //enemy is an entityt that takes bonus dmg, and i am an npc.
			}
			//against raids, any aoe ability should be better as they are usually alone or its only two.
			if(b_thisNpcIsARaid[ClosestTarget])
			{
				damage_1 *= 1.3;
			}
			damage_1 *= f_ExplodeDamageVulnerabilityNpc[ClosestTarget];
			float GetBeforeDamage;
			if(FunctionToCallBeforeHit != INVALID_FUNCTION)
			{
				Call_StartFunction(null, FunctionToCallBeforeHit);
				Call_PushCell(EntityToForward);
				Call_PushCell(ClosestTarget);
				Call_PushFloatRef(damage_1);
				Call_PushCell(weapon);
				Call_Finish(GetBeforeDamage);
			}
			if(damage_1 > 0.0)
			{
				//npcs do not take damage from drown damage, so what we will do instead
				//is to make it do slash damage, slash damage ignores most resistances like drown does.

				damage_1 += GetBeforeDamage;

				ClosestDistance -= 1600.0;// Give 60 units of range cus its not going from their hurt pos

				if(ClosestDistance < 0.1)
				{
					ClosestDistance = 0.1;
				}
				//we apply 50% more range, reason being is that this goes for collision boxes, so it can be abit off
				//idealy we should fire a trace and see the distance from the trace
				//ill do it in abit if i dont forget.
				float ExplosionRangeFalloff = Pow(explosion_range_dmg_falloff, (ClosestDistance/((explosionRadius * explosionRadius) * 1.5))); //this is 1000, we use squared for optimisations sake
				damage_1 *= ExplosionRangeFalloff; //this is 1000, we use squared for optimisations sake

				damage_1 *= damage_reduction;
				
				float v[3];
				CalculateExplosiveDamageForce(spawnLoc, vicpos, explosionRadius, v);
				//dont do damage ticks if its actually 0 dmg.

				if(damage_1 != 0.0)
					SDKHooks_TakeDamage(ClosestTarget, entityToEvaluateFrom, inflictor, damage_1, damage_flags, weapon, v, vicpos, false, custom_flags);	

				Projectile_DealElementalDamage(ClosestTarget, EntityToForward, ExplosionRangeFalloff);
			}
			if(FunctionToCallOnHit != INVALID_FUNCTION)
			{
				Call_StartFunction(null, FunctionToCallOnHit);
				Call_PushCell(EntityToForward);
				Call_PushCell(ClosestTarget);
				//do not allow division by 0
				damage_1 *= damage_reduction;
				Call_PushFloat(damage_1);
					
				Call_PushCell(weapon);
				Call_Finish();
			}
			//i want owner entity and hit entity
			if(!FromBlueNpc) //Npcs do not have damage falloff, dodge.
			{
				damage_reduction *= ExplosionDmgMultihitFalloff;
			}
		}
		
		ClosestTarget = false;
		ClosestDistance = 0.0;
	}
	delete HitEntitiesSphereExplosionTrace;
}

//#define PARTITION_SOLID_EDICTS        (1 << 1) /**< every edict_t that isn't SOLID_TRIGGER or SOLID_NOT (and static props) */
//#define PARTITION_TRIGGER_EDICTS      (1 << 2) /**< every edict_t that IS SOLID_TRIGGER */
//#define PARTITION_NON_STATIC_EDICTS   (1 << 5) /**< everything in solid & trigger except the static props, includes SOLID_NOTs */
//#define PARTITION_STATIC_PROPS        (1 << 7)

void DoExlosionTraceCheck(const float pos1[3], float radius, int entity, ArrayList HitEntitiesSphereExplosionTrace)
{
	DataPack packFilter = new DataPack();
	packFilter.WriteCell(HitEntitiesSphereExplosionTrace);
	packFilter.WriteCell(entity);
	TR_EnumerateEntitiesSphere(pos1, radius, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_EnumerateEntitiesInRange, packFilter);

	delete packFilter;
	//It does all needed logic here.
}

public bool TraceEntityEnumerator_EnumerateEntitiesInRange(int entity, DataPack packFilter)
{
	packFilter.Reset();
	ArrayList HitEntitiesSphereExplosionTrace = packFilter.ReadCell();
	int filterentity = packFilter.ReadCell();
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		//This will automatically take care of all the checks, very handy. force it to also target invul enemies.
		//Add a new entity to the arrray list
		HitEntitiesSphereExplosionTrace.Push(entity);
		
	}
	//always keep going!
	return true;
}

stock void DisplayCritAboveNpc(int victim = -1, int client, bool sound, float position[3] = {0.0,0.0,0.0}, int ParticleIndex = -1, bool minicrit = false)
{
	float chargerPos[3];
	if(victim != -1)
	{
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		if(b_BoundingBoxVariant[victim] == 1)
		{
			chargerPos[2] += 120.0;
		}
		else
		{
			chargerPos[2] += 82.0;
		}
	}
	else
	{
		chargerPos = position;
	}

	if(sound)
	{
		if(minicrit)
		{
			switch(GetRandomInt(1,5))
			{
				case 1:
				{
					EmitSoundToClient(client, "player/crit_hit_mini.wav", _, _, 80, _, 0.8, 100);
				}
				case 2:
				{
					EmitSoundToClient(client, "player/crit_hit_mini2.wav", _, _, 80, _, 0.8, 100);
				}
				case 3:
				{
					EmitSoundToClient(client, "player/crit_hit_mini3.wav", _, _, 80, _, 0.8, 100);
				}
				case 4:
				{
					EmitSoundToClient(client, "player/crit_hit_mini4.wav", _, _, 80, _, 0.8, 100);
				}
				
			}			
		}
		else
		{
			switch(GetRandomInt(1,5))
			{
				case 1:
				{
					EmitSoundToClient(client, "player/crit_hit.wav", _, _, 80, _, 0.8, 100);
				}
				case 2:
				{
					EmitSoundToClient(client, "player/crit_hit2.wav", _, _, 80, _, 0.8, 100);
				}
				case 3:
				{
					EmitSoundToClient(client, "player/crit_hit3.wav", _, _, 80, _, 0.8, 100);
				}
				case 4:
				{
					EmitSoundToClient(client, "player/crit_hit4.wav", _, _, 80, _, 0.8, 100);
				}
				case 5:
				{
					EmitSoundToClient(client, "player/crit_hit5.wav", _, _, 80, _, 0.8, 100);
				}
				
			}		
		}

	}
	if(ParticleIndex != -1)
	{
		TE_ParticleInt(ParticleIndex, chargerPos);
		TE_SendToClient(client);	
	}
	else
	{
		if(minicrit)
		{
			TE_ParticleInt(g_particleMiniCritText, chargerPos);
			TE_SendToClient(client);
		}
		else
		{
			TE_ParticleInt(g_particleCritText, chargerPos);
			TE_SendToClient(client);	
		}	
	}
}

public bool HitOnlyTargetOrWorld(int entity, int contentsMask, any iExclude)
{
	if(entity == 0)
	{
		return true;
	}
	if(entity == iExclude)
	{
		return true;
	}
		
	
	return false;
}


public bool HitOnlyWorld(int entity, int contentsMask, any iExclude)
{
	if(entity == 0)
	{
		return true;
	}	
	
	return false;
}

public void CauseDamageLaterSDKHooks_Takedamage(DataPack pack)
{
	pack.Reset();
	int Victim = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	int inflictor = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadFloat();
	int damage_type = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float damage_force[3];
	damage_force[0] = pack.ReadFloat();
	damage_force[1] = pack.ReadFloat();
	damage_force[2] = pack.ReadFloat();
	float playerPos[3];
	playerPos[0] = pack.ReadFloat();
	playerPos[1] = pack.ReadFloat();
	playerPos[2] = pack.ReadFloat();
	int damage_type_Custom = pack.ReadCell();
	if(IsValidEntity(Victim) && IsValidEntity(client)/* && IsValidEntity(weapon) */&& IsValidEntity(inflictor))
	{
		SDKHooks_TakeDamage(Victim, client, inflictor, damage, damage_type, weapon, damage_force, playerPos, _,damage_type_Custom);
	}
//	pack.delete;
	delete pack;
}

stock void LookAtTarget(int client, int target)
{
	float angles[3];
	float clientEyes[3];
	float targetEyes[3];
	float resultant[3]; 
		
	GetClientEyePosition(client, clientEyes);
	if(target > 0 && target <= MaxClients && IsClientInGame(target))
	{
		GetClientEyePosition(target, targetEyes);
	}
	else
	{
		WorldSpaceCenter(target, targetEyes);
	}
	MakeVectorFromPoints(targetEyes, clientEyes, resultant); 
	GetVectorAngles(resultant, angles); 
	if(angles[0] >= 270){ 
		angles[0] -= 270; 
		angles[0] = (90-angles[0]); 
	}else{ 
		if(angles[0] <= 90){ 
			angles[0] *= -1; 
		} 
	} 
	angles[1] -= 180; 
	SnapEyeAngles(client, angles);
} 


int Trail_Attach(int entity, char[] trail, int alpha, float lifetime=1.0, float startwidth=22.0, float endwidth=0.0, int rendermode)
{
	int entIndex = CreateEntityByName("env_spritetrail");
	if (entIndex > 0 && IsValidEntity(entIndex))
	{
		char strTargetName[MAX_NAME_LENGTH];

		DispatchKeyValue(entity, "targetname", strTargetName);
		Format(strTargetName,sizeof(strTargetName),"trail%d",EntIndexToEntRef(entity));
		DispatchKeyValue(entity, "targetname", strTargetName);
		DispatchKeyValue(entIndex, "parentname", strTargetName);
		

		DispatchKeyValue(entIndex, "spritename", trail);
		SetEntPropFloat(entIndex, Prop_Send, "m_flTextureRes", 1.0);
			
		char sTemp[5];
		IntToString(alpha, sTemp, sizeof(sTemp));
		DispatchKeyValue(entIndex, "renderamt", sTemp);
			
		DispatchKeyValueFloat(entIndex, "lifetime", lifetime);
		DispatchKeyValueFloat(entIndex, "startwidth", startwidth);
		DispatchKeyValueFloat(entIndex, "endwidth", endwidth);
		
		IntToString(rendermode, sTemp, sizeof(sTemp));
		DispatchKeyValue(entIndex, "rendermode", sTemp);
			
		DispatchSpawn(entIndex);
		float f_origin[3];
		GetAbsOrigin(entity, f_origin);
		TeleportEntity(entIndex, f_origin, NULL_VECTOR, NULL_VECTOR);
		SetVariantString(strTargetName);
		SetParent(entity, entIndex, "", _, false);
		return entIndex;
	}	
	return -1;
}

stock void ConstrainDistance(const float[] startPoint, float[] endPoint, float distance, float maxDistance, bool do2)
{
	float constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	if(do2)
		endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}

public void MakeExplosionFrameLater(DataPack pack)
{
	pack.Reset();
	float vec_pos[3];
	vec_pos[0] = pack.ReadFloat();
	vec_pos[1] = pack.ReadFloat();
	vec_pos[2] = pack.ReadFloat();
	int Do_Sound = pack.ReadCell();
	
	int ent = CreateEntityByName("env_explosion");
	if(ent != -1)
	{
	//	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
		
		if(Do_Sound == 1)
		{		
			EmitAmbientSound("ambient/explosions/explode_3.wav", vec_pos, _, 75, _,0.7, GetRandomInt(75, 110));
		}
		
		DispatchKeyValueVector(ent, "origin", vec_pos);
		DispatchKeyValue(ent, "spawnflags", "581");
						
		DispatchKeyValue(ent, "rendermode", "0");
		DispatchKeyValue(ent, "fireballsprite", "spirites/zerogxplode.spr");
										
		DispatchKeyValueFloat(ent, "DamageForce", 0.0);								
		SetEntProp(ent, Prop_Data, "m_iMagnitude", 0); 
		SetEntProp(ent, Prop_Data, "m_iRadiusOverride", 0); 
									
		DispatchSpawn(ent);
		ActivateEntity(ent);
									
		AcceptEntityInput(ent, "explode");
		AcceptEntityInput(ent, "kill");
	}		
	SpawnSmallExplosionNotRandom(vec_pos);
	delete pack;
}


public void TeleportEntityLocalPos_FrameDelay(int entity, float VecPos[3])
{
	DataPack pack_boom = new DataPack();
	pack_boom.WriteCell(EntIndexToEntRef(entity));
	pack_boom.WriteFloat(VecPos[0]);
	pack_boom.WriteFloat(VecPos[1]);
	pack_boom.WriteFloat(VecPos[2]);
	RequestFrames(TeleportEntityLocalPos_FrameDelayDo, 5, pack_boom);
}

public void TeleportEntityLocalPos_FrameDelayDo(DataPack pack)
{
	pack.Reset();
	int Entity = EntRefToEntIndex(pack.ReadCell());
	float vec_pos[3];
	if(IsValidEntity(Entity))
	{
		vec_pos[0] = pack.ReadFloat();
		vec_pos[1] = pack.ReadFloat();
		vec_pos[2] = pack.ReadFloat();
		SDKCall_SetAbsOrigin(Entity, vec_pos);
		SDKCall_SetLocalOrigin(Entity,vec_pos);
	}
	
	delete pack;
}
stock void SetPlayerActiveWeapon(int client, int weapon)
{
	TF2Util_SetPlayerActiveWeapon(client, weapon);
#if defined ZR
//	WeaponSwtichToWarningPostDestroyed(weapon);
#endif
	/*
	char buffer[64];
	GetEntityClassname(weapon, buffer, sizeof(buffer));
	FakeClientCommand(client, "use %s", buffer); 					//allow client to change
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);	//Force client to change.
	OnWeaponSwitchPost(client, weapon);
	*/
}

stock void DHook_CreateDetour(GameData gamedata, const char[] name, DHookCallback preCallback = INVALID_FUNCTION, DHookCallback postCallback = INVALID_FUNCTION)
{
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, name);
	if(detour)
	{
		if(preCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, false, preCallback))
			LogError("[Gamedata] Failed to enable pre detour: %s", name);

		if(postCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, true, postCallback))
			LogError("[Gamedata] Failed to enable post detour: %s", name);

		delete detour;
	}
	else
	{
		LogError("[Gamedata] Could not find %s", name);
	}
}

#define ANNOTATION_REFRESH_RATE 0.1
#define ANNOTATION_OFFSET 8750

stock void ShowAnnotationToPlayer(int client, float pos[3], const char[] Text, float lifetime, int follow_who)
{
	Handle event = CreateEvent("show_annotation");
	if (event == INVALID_HANDLE) return;
	
	if(follow_who != -1)
	{
		SetEventInt(event, "follow_entindex", follow_who);
	}
	SetEventFloat(event, "worldPosX", pos[0]);
	SetEventFloat(event, "worldPosY", pos[1]);
	SetEventFloat(event, "worldPosZ", pos[2]);
	SetEventFloat(event, "lifetime", lifetime);
//	SetEventInt(event, "id", annotation_id*MAXPLAYERS + client + ANNOTATION_OFFSET);
	SetEventString(event, "text", Text);
	SetEventString(event, "play_sound", "vo/null.wav");
	SetEventInt(event, "visibilityBitfield", (1 << client));
	FireEvent(event);
	
}

public void GiveCompleteInvul(int client, float time)
{
	f_ClientInvul[client] = GetGameTime() + time;
	TF2_AddCondition(client, TFCond_UberchargedCanteen, time);
	TF2_AddCondition(client, TFCond_MegaHeal, time);
}

public void RemoveInvul(int client)
{
	f_ClientInvul[client] = 0.0;
	TF2_RemoveCondition(client, TFCond_UberchargedCanteen);
	TF2_RemoveCondition(client, TFCond_MegaHeal);
}

stock int SpawnFormattedWorldText(const char[] format, float origin[3], int textSize = 10, const int colour[4] = {255,255,255,255}, int entity_parent = -1, bool rainbow = false, bool teleport = false)
{
	int worldtext = CreateEntityByName("point_worldtext");
	if(IsValidEntity(worldtext))
	{
		DispatchKeyValue(worldtext, "targetname", "rpg_fortress");
		DispatchKeyValue(worldtext, "message", format);
		char intstring[8];
		IntToString(textSize, intstring, sizeof(intstring));
		DispatchKeyValue(worldtext, "textsize", intstring);

		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", colour[0], colour[1], colour[2], colour[3]);
		DispatchKeyValue(worldtext,     "color", sColor);

		DispatchSpawn(worldtext);
		SetEdictFlags(worldtext, (GetEdictFlags(worldtext) & ~FL_EDICT_ALWAYS));	
		DispatchKeyValue(worldtext, "orientation", "1");
		if(rainbow)
			DispatchKeyValue(worldtext, "rainbow", "1");
		
		if(entity_parent != -1 && !teleport)
		{
			float vector[3];
			GetAbsOrigin(entity_parent, vector);
			
			vector[0] += origin[0];
			vector[1] += origin[1];
			vector[2] += origin[2];

			TeleportEntity(worldtext, vector, NULL_VECTOR, NULL_VECTOR);
			SetParent(entity_parent, worldtext, "", origin);
		}
		else
		{
			if(teleport)
			{
				DataPack pack;
				CreateDataTimer(0.1, TeleportTextTimer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(EntIndexToEntRef(worldtext));
				pack.WriteCell(EntIndexToEntRef(entity_parent));
				pack.WriteFloat(origin[0]);
				pack.WriteFloat(origin[1]);
				pack.WriteFloat(origin[2]);
			}
			SDKCall_SetLocalOrigin(worldtext, origin);
		}	
	}
	return worldtext;
}

public Action TeleportTextTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int text_entity = EntRefToEntIndex(pack.ReadCell());
	int parented_entity = EntRefToEntIndex(pack.ReadCell());
	float vector_offset[3];
	vector_offset[0] = pack.ReadFloat();
	vector_offset[1] = pack.ReadFloat();
	vector_offset[2] = pack.ReadFloat();
	if(IsValidEntity(text_entity) && IsValidEntity(parented_entity))
	{
		float vector[3];
		GetAbsOrigin(parented_entity, vector);
		
		vector[0] += vector_offset[0];
		vector[1] += vector_offset[1];
		vector[2] += vector_offset[2];

		SDKCall_SetLocalOrigin(text_entity,vector);
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
	
}


stock int SpawnSeperateCollisionBox(int entity, float Mins[3] = {-24.0,-24.0,0.0}, float Maxs[3] = {24.0,24.0,82.0})
{
	static bool precached;

	if(!precached)
	{
		precached = true;
		PrecacheModel("models/error.mdl");
	}

	float vector[3];
	GetAbsOrigin(entity, vector);

	int brush = CreateEntityByName("func_brush");
        
	if (brush != -1)
	{
		DispatchKeyValueVector(brush, "origin", vector);
		DispatchKeyValue(brush, "spawnflags", "64");
		DispatchKeyValue(brush, "targetname", "rpg_fortress");

		DispatchSpawn(brush);
		ActivateEntity(brush);    

		SetEntityModel(brush, "models/error.mdl");
	//	SetEntityModel(brush, "models/error.mdl");
		SetEntProp(brush, Prop_Send, "m_nSolidType", 2);
		SetEntityCollisionGroup(brush, 5);
							
		SetEntPropVector(brush, Prop_Send, "m_vecMinsPreScaled", Mins);
							
		SetEntPropVector(brush, Prop_Send, "m_vecMaxsPreScaled", Maxs);
			
		SetEntPropVector(brush, Prop_Send, "m_vecMins", Mins);
		SetEntPropVector(brush, Prop_Send, "m_vecMaxs", Maxs);

		CClotBody npc = view_as<CClotBody>(brush);
		npc.UpdateCollisionBox();	
            
		SetEntProp(brush, Prop_Send, "m_fEffects", GetEntProp(brush, Prop_Send, "m_fEffects") | EF_NODRAW); 
		TeleportEntity(entity, vector, NULL_VECTOR, NULL_VECTOR);
		return brush;
	} 
	else
	{
		return -1;
	}
}


//static int b_TextEntityToOwner[MAXPLAYERS];
#if defined RPG

int BrushToEntity(int brush)
{
	int entity = EntRefToEntIndex(b_BrushToOwner[brush]);
	if(IsValidEntity(entity))
	{
		return entity;
	}
	return -1;
}

stock void UpdateLevelAbovePlayerText(int client, bool deleteText = false)
{
	Stats_UpdateLevel(client);
	int textentity = EntRefToEntIndex(i_TextEntity[client][0]);
	int textentity2 = EntRefToEntIndex(i_TextEntity[client][1]);
	int textentity3 = EntRefToEntIndex(i_TextEntity[client][2]);
	if(deleteText)
	{
		if(IsValidEntity(textentity))
		{
			RemoveEntity(textentity);
		}
		if(IsValidEntity(textentity2))
		{
			RemoveEntity(textentity2);
		}
		if(IsValidEntity(textentity3))
		{
			RemoveEntity(textentity3);
		}
	}
	if(deleteText)
		return;
		
	char LVLBuffer[64];
	IntToString(Level[client],LVLBuffer, sizeof(LVLBuffer));
	ThousandString(LVLBuffer, sizeof(LVLBuffer));
	if(IsValidEntity(textentity))
	{
		static char buffer[128];
		Format(buffer, sizeof(buffer), "LVL %s", LVLBuffer);
		DispatchKeyValue(textentity, "message", buffer);
	}
	else
	{
		float OffsetFromHead[3];

		OffsetFromHead[2] = 120.0;
		static char buffer[128];
		Format(buffer, sizeof(buffer), "LVL %s", LVLBuffer);
		int textentityMade = SpawnFormattedWorldText(buffer, OffsetFromHead, 10, {255,255,255,255}, client);
		i_TextEntity[client][0] = EntIndexToEntRef(textentityMade);
	}
	if(IsValidEntity(textentity2))
	{
		DispatchKeyValue(textentity2, "message", c_TagName[client]);
		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", i_TagColor[client][0], i_TagColor[client][1], i_TagColor[client][2], i_TagColor[client][3]);
		DispatchKeyValue(textentity2,     "color", sColor);
		if(i_TagColor[client][0] == 254)
		{
			DispatchKeyValue(textentity2, "rainbow", "1");
		}
		else
		{
			DispatchKeyValue(textentity2, "rainbow", "0");
		}
	}
	else
	{
		float OffsetFromHead[3];

		OffsetFromHead[2] = 110.0;
		static char buffer[128];
		Format(buffer, sizeof(buffer), c_TagName[client]);
		int textentityMade = SpawnFormattedWorldText(buffer, OffsetFromHead, 10, i_TagColor[client], client, false);
		
		if(i_TagColor[client][0] == 254)
		{
			DispatchKeyValue(textentityMade, "rainbow", "1");
		}
		else
		{
			DispatchKeyValue(textentityMade, "rainbow", "0");
		}
		
		i_TextEntity[client][1] = EntIndexToEntRef(textentityMade);
	}
	if(IsValidEntity(textentity3))
	{
		float Powerlevel = RPGStocks_CalculatePowerLevel(client);
		char c_Powerlevel[255];
		Format(c_Powerlevel, sizeof(c_Powerlevel), "%.0f", Powerlevel);
		ThousandString(c_Powerlevel, sizeof(c_Powerlevel));
		DispatchKeyValue(textentity3, "message", c_Powerlevel);
		char sColor[32];
		

		// form.Name
		static Form form;
		Races_GetClientInfo(client, _, form);
		int color4[4] = {255,255,255,255};
		if(i_TransformationLevel[client] > 0)
		{
			color4[0] = form.Form_RGBA[0];
			color4[1] = form.Form_RGBA[1];
			color4[2] = form.Form_RGBA[2];
			color4[3] = form.Form_RGBA[3];
		}
		Format(sColor, sizeof(sColor), " %d %d %d %d ", color4[0], color4[1], color4[2], color4[3]);
		DispatchKeyValue(textentity3,     "color", sColor);
	}
	else
	{
		float OffsetFromHead[3];

		OffsetFromHead[2] = 130.0;

		float Powerlevel = RPGStocks_CalculatePowerLevel(client);
		char c_Powerlevel[255];
		Format(c_Powerlevel, sizeof(c_Powerlevel), "%.0f", Powerlevel);
		ThousandString(c_Powerlevel, sizeof(c_Powerlevel));

		static Form form;
		Races_GetClientInfo(client, _, form);
		int color4[4] = {255,255,255,255};
		if(i_TransformationLevel[client] > 0)
		{
			color4[0] = form.Form_RGBA[0];
			color4[1] = form.Form_RGBA[1];
			color4[2] = form.Form_RGBA[2];
			color4[3] = form.Form_RGBA[3];
		}
		int textentityMade = SpawnFormattedWorldText(c_Powerlevel, OffsetFromHead, 10, color4, client, false);
		
		i_TextEntity[client][2] = EntIndexToEntRef(textentityMade);
	}
}

float RPGStocks_CalculatePowerLevel(int client)
{
	int total;
	float BigTotal;
	total = Stats_Strength(client);
	total *= 3;
	BigTotal += float(total);

	total = Stats_Precision(client);
	total *= 3;
	BigTotal += float(total);

	total = Stats_Artifice(client);
	total *= 3;
	BigTotal += float(total);

	total = Stats_Endurance(client);
	total *= 2;
	BigTotal += float(total);

	total = Stats_Structure(client);
	total *= 4;
	BigTotal += float(total);

	total = Stats_Capacity(client);
	total *= 3;
	BigTotal += float(total);


	static Race race;
	static Form form;
	Races_GetClientInfo(client, race, form);
	float ResMulti;
	ResMulti = form.GetFloatStat(client, Form::DamageResistance, Stats_GetFormMastery(client, form.Name));
	
	BigTotal *= (1.0 / ResMulti);

	//These stats are abit different
	total = Stats_Agility(client);
	total *= 30;
	BigTotal += float(total);
	//luck doesnt exist

	return BigTotal;
}

/*
public Action SDKHook_Settransmit_TextParentedToPlayer(int entity, int client)
{
	SetEdictFlags(entity, GetEdictFlags(entity) &~ FL_EDICT_ALWAYS);
	if(client == b_TextEntityToOwner[entity])
	{
		PrintToChatAll("bruh");
		return Plugin_Handled;
	}
	PrintToChatAll("bruh1");
	return Plugin_Continue;
}
*/
#endif


stock void spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0, int client = 0) //Spawns a TE beam ring at a client's/entity's location
{
	float PosUse[3];
	PosUse = center;
	PosUse[0] += modif_X;
	PosUse[1] += modif_Y;
	PosUse[2] += modif_Z;
			
	int ICE_INT = PrecacheModel(sprite);
		
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
		
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(PosUse, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	if(client > 0)
	{
		TE_SendToClient(client);
	}
	else
	{
		TE_SendToAll();
	}
}

stock char[] CharInt(int value)
{
	static char buffer[16];
	IntToString(value, buffer, sizeof(buffer));
	if(value > 0)
	{
		for(int i = sizeof(buffer) - 1; i > 0; i--)
		{
			buffer[i] = buffer[i-1];
		}

		buffer[0] = '+';
	}
	return buffer;
}

stock char[] CharPercent(float value)
{
	static char buffer[16];
	if(value < 1.0)
	{
		Format(buffer, sizeof(buffer), "%d％", 100 - RoundFloat((1.0 / value) * 100.0));
	}
	else
	{
		Format(buffer, sizeof(buffer), "+%d％", RoundFloat((value - 1.0) * 100.0));
	}
	return buffer;
} 

#if defined ZR

stock bool AmmoBlacklist(int Ammotype)
{
	if(Ammotype >= 0 && Ammotype<= 2 || Ammotype == -1 || Ammotype >= Ammo_Hand_Grenade)
	{
		return false;
	}
	return true;
} 


#endif

stock void GetBeamDrawStartPoint_Stock(int client, float startPoint[3] = {0.0,0.0,0.0}, float Beamoffset[3] = {0.0,0.0,0.0}, float Angles[3] = {0.0,0.0,0.0})
{
	if(startPoint[0] == 0.0 && startPoint[1] == 0.0 && startPoint[2] == 0.0)
	{
		GetClientEyePosition(client, startPoint);
		startPoint[2] -= 25.0;
	}
	
	if(Angles[0] == 0.0 && Angles[1] == 0.0 && Angles[2] == 0.0)
	{
		GetClientEyeAngles(client, Angles);
	}

	if (0.0 == Beamoffset[0] && 0.0 == Beamoffset[1] && 0.0 == Beamoffset[2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = Beamoffset[0];
	tmp[1] = Beamoffset[1];
	tmp[2] = Beamoffset[2];
	VectorRotate(tmp, Angles, actualBeamOffset);
	actualBeamOffset[2] = Beamoffset[2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

// Thank you miku:)
// https://github.com/Mikusch/PropHunt/blob/985808f13d8738945a2c9980db0b75865a20c99c/addons/sourcemod/scripting/prophunt.sp#L332

static bool HazardResult;

stock bool IsPointHazard(const float pos1[3])
{
	HazardResult = false;
	TR_EnumerateEntities(pos1, pos1, PARTITION_TRIGGER_EDICTS, RayType_EndPoint, TraceEntityEnumerator_EnumerateTriggers);
	return HazardResult;
}
public bool TraceEntityEnumerator_EnumerateTriggers(int entity, int client)
{
	if(b_IsATriggerHurt[entity])
	{
		if(!GetEntProp(entity, Prop_Data, "m_bDisabled"))
		{
			Handle trace = TR_ClipCurrentRayToEntityEx(MASK_ALL, entity);
			bool didHit = TR_DidHit(trace);
			delete trace;
			if (didHit)
			{
				HazardResult = true;
				return false;
			}
		}
	}
	
	return true;
}


stock bool IsBoxHazard(const float pos1[3],const float mins[3],const float maxs[3])
{
	HazardResult = false;
	TR_EnumerateEntitiesHull(pos1, pos1, mins, maxs, PARTITION_TRIGGER_EDICTS, TraceEntityEnumerator_EnumerateTriggers, _);
	return HazardResult;
}
stock bool IsPointNoBuild(const float pos1[3],const float mins[3],const float maxs[3])
{
	HazardResult = false;
	TR_EnumerateEntitiesHull(pos1, pos1, mins, maxs, PARTITION_TRIGGER_EDICTS, TraceEntityEnumerator_EnumerateTriggers_noBuilds);
	return HazardResult;
}

public bool TraceEntityEnumerator_EnumerateTriggers_noBuilds(int entity, int client)
{
	char classname[16];
	if(b_IsATriggerHurt[entity] || (GetEntityClassname(entity, classname, sizeof(classname)) && !StrContains(classname, "func_nobuild")))
	{
		if(!GetEntProp(entity, Prop_Data, "m_bDisabled"))
		{
			Handle trace = TR_ClipCurrentRayToEntityEx(MASK_ALL, entity);
			bool didHit = TR_DidHit(trace);
			delete trace;
			
			if (didHit)
			{
				HazardResult = true;
				return false;
			}
		}
	}
	
	return true;
}

stock void SetDefaultHudPosition(int client, int red = 34, int green = 139, int blue = 34, float duration = 1.01)
{
	float HudY = 0.75;
	float HudX = -1.0;
#if defined ZR
	HudX += f_NotifHudOffsetY[client];
	HudY += f_NotifHudOffsetX[client];
#endif
	SetHudTextParams(HudX, HudY, duration, red, green, blue, 255);
}

#if !defined RTS
stock void ApplyTempAttrib(int entity, int index, float multi, float duration = 0.3)
{
#if defined RPG
	ApplyTempAttrib_Internal(entity, index, multi, duration);
	return;
#endif
#if defined ZR
	if(Attributes_Has(entity,index))
	{
		//We need to get the owner!!
		int owner;
		if(entity <= MaxClients)
			owner = entity;
		else
			owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

		TempAttribStore TempStoreAttrib;
		TempStoreAttrib.Attribute = index;
		TempStoreAttrib.Value = multi;
		TempStoreAttrib.GameTimeRemoveAt = GetGameTime() + duration;
		if(entity <= MaxClients)
		{
			int clientid = GetSteamAccountID(entity);
			TempStoreAttrib.Weapon_StoreIndex = clientid;
			TempStoreAttrib.ClientOnly_ResetCountSave = ClientAttribResetCount[owner];
		}
		else
			TempStoreAttrib.Weapon_StoreIndex = StoreWeapon[entity];
		
		TempStoreAttrib.Apply_TempAttrib(owner, entity);
	}
#endif
}

stock void ApplyTempAttrib_Internal(int entity, int index, float multi, float duration = 0.3, int ClientResetCount = 0)
{
	/*
	Applying this onto players might cause issues, as player attributes are spread across wearbles
	TODO: find a fix

	*/
	if(Attributes_Has(entity,index))
	{
		Attributes_SetMulti(entity, index, multi);
		//Attributes_Get(weapon, 466, 1.0);
		
		DataPack pack;
		CreateDataTimer(duration, ApplyTempAttrib_Revert, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(index);
		pack.WriteFloat(multi);
		pack.WriteCell(ClientResetCount);
	}
}

public Action ApplyTempAttrib_Revert(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != INVALID_ENT_REFERENCE)
	{
		int index = pack.ReadCell();
		float AttribCount = pack.ReadFloat();
		if(entity <= MaxClients)
		{
			int ClientResetCount = pack.ReadCell();
			if(ClientAttribResetCount[entity] != ClientResetCount)
			{
				return Plugin_Stop;
			}
		}
		Attributes_SetMulti(entity, index, 1.0 / AttribCount);
		if(Attribute_IsMovementSpeed(index))
		{
			int owner;
			if(entity <= MaxClients)
				owner = entity;
			else
				owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
				
			if(owner > 0 && owner <= MaxClients)
			{
				SDKCall_SetSpeed(owner);
			}
		}
	}
	return Plugin_Stop;
}
#endif

/*
void PlayFakeDeathSound(int client)
{
	int victim;
	for(int bot=1; bot<MaxClients; bot++)
	{
		if(IsValidClient(bot) && b_IsPlayerABot[bot])
		{
			victim = bot;
			break;
		}
	}
	if(victim == 0)
	{
		return;
	}
	PrintToChatAll("%i",victim);

	Event event = CreateEvent("player_hurt", true);
	event.SetInt("userid", GetClientUserId(victim));
	event.SetInt("health", -25);
	event.SetInt("attacker", GetClientUserId(client));
	event.SetInt("damageamount", 99);
	event.SetBool("crit", false);
	event.FireToClient(client);
	delete event;
}
*/

stock bool ShouldNpcDealBonusDamage(int entity)
{
	if(entity < 1)
	{
		return false;
	}
	if(i_NpcIsABuilding[entity])
	{
		return true;
	}
	return i_IsABuilding[entity];
}


stock int ConnectWithBeamClient(int iEnt, int iEnt2, int iRed=255, int iGreen=255, int iBlue=255,
							float fStartWidth=0.8, float fEndWidth=0.8, float fAmp=1.35, char[] Model = "sprites/laserbeam.vmt", int ClientToHideFirstPerson = 0)
{
	int iBeam = CreateEntityByName("env_beam");
	if(iBeam <= MaxClients)
		return -1;

	if(!IsValidEntity(iBeam))
		return -1;

	SetEntityModel(iBeam, Model);
	char sColor[16];
	Format(sColor, sizeof(sColor), "%d %d %d", iRed, iGreen, iBlue);

	DispatchKeyValue(iBeam, "rendercolor", sColor);
	DispatchKeyValue(iBeam, "life", "0");

	DispatchSpawn(iBeam);

	if(ClientToHideFirstPerson > 0)
	{
		AddEntityToThirdPersonTransitMode(ClientToHideFirstPerson, iBeam);
	}

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt));

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt2), 1);

	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	SetEntPropFloat(iBeam, Prop_Data, "m_fAmplitude", fAmp);

	SetVariantFloat(32.0);
	AcceptEntityInput(iBeam, "Amplitude");
	AcceptEntityInput(iBeam, "TurnOn");

	SetVariantInt(0);
	AcceptEntityInput(iBeam, "TouchType");

	SetVariantString("0");
	AcceptEntityInput(iBeam, "damage");
	//its delayed by a frame to avoid it not rendering at all.
//	RequestFrames(ApplyBeamThinkRemoval, 15, EntIndexToEntRef(iBeam));

	return iBeam;
}

void AddEntityToThirdPersonTransitMode(int client, int entity)
{
	i_OwnerEntityEnvLaser[entity] = EntIndexToEntRef(client);
	SDKHook(entity, SDKHook_SetTransmit, ThirdersonTransmitEnvLaser);
}

public Action ThirdersonTransmitEnvLaser(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		if(b_FirstPersonUsesWorldModel[client])
		{
			return Plugin_Continue;
		}
		int owner = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);
		if(owner == client)
		{
			if(TF2_IsPlayerInCondition(client, TFCond_Taunting) || GetEntProp(client, Prop_Send, "m_nForceTauntCam"))
			{
				return Plugin_Continue;
			}
		}
		else if(GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") != owner || GetEntProp(client, Prop_Send, "m_iObserverMode") != 4)
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}


//bool identified if it went above max health or not.

//No need to delele it, its just 1 ho difference, wow so huge.
int HealEntityViaFloat(int entity, float healing_Amount, float MaxHealthOverMulti = 1.0, int MaxHealingPermitted = 9999999)
{
//	bool isNotClient = false;
	
	int flHealth, flMaxHealth;

	#if defined ZR
	if(i_IsVehicle[entity])
	{
		flHealth = Armor_Charge[entity];
		flMaxHealth = 10000;
	}
	else
	#endif
	{
		flHealth = GetEntProp(entity, Prop_Data, "m_iHealth");
		flMaxHealth = ReturnEntityMaxHealth(entity);
	}

	int i_TargetHealAmount; //Health to actaully apply

	if (healing_Amount <= 1.0 && healing_Amount > 0.0)
	{
		f_IncrementalSmallHeal[entity] += healing_Amount;
			
		if(f_IncrementalSmallHeal[entity] >= 1.0)
		{
			f_IncrementalSmallHeal[entity] -= 1.0;
			i_TargetHealAmount = 1;
		}
	}
	else
	{
		if(i_TargetHealAmount < 0.0) //negative heal
		{
			i_TargetHealAmount = RoundToFloor(healing_Amount);
		}
		else
		{
			i_TargetHealAmount = RoundToFloor(healing_Amount);
		
			float Decimal_healing = FloatFraction(healing_Amount);
								
								
			f_IncrementalSmallHeal[entity] += Decimal_healing;
								
			while(f_IncrementalSmallHeal[entity] >= 1.0)
			{
				f_IncrementalSmallHeal[entity] -= 1.0;
				i_TargetHealAmount += 1;
			}
		}		
	}
	if(i_TargetHealAmount > MaxHealingPermitted)
	{
		i_TargetHealAmount = MaxHealingPermitted;
	}
	//scale down the healing.
	int newHealth = flHealth + i_TargetHealAmount;
	int HealAmount = 0;
	int MaxHeal = RoundToNearest(float(flMaxHealth) * MaxHealthOverMulti);
	if(flHealth < MaxHeal)
	{
		if(newHealth >= MaxHeal) //allow 1 tick of overheal.
		{
			#if defined ZR
			if(i_IsVehicle[entity])
			{
				Armor_Charge[entity] = MaxHeal;
			}
			else
			#endif
			{
				SetEntProp(entity, Prop_Data, "m_iHealth", MaxHeal);
			}
			
			newHealth = MaxHeal;

			HealAmount = newHealth - flHealth;
		}
		else
		{
			#if defined ZR
			if(i_IsVehicle[entity])
			{
				Armor_Charge[entity] = newHealth;
			}
			else
			#endif
			{
				SetEntProp(entity, Prop_Data, "m_iHealth", newHealth);
			}

			HealAmount = newHealth - flHealth;
		}
	}
	if(newHealth <= 0)
	{
		SDKHooks_TakeDamage(entity, 0, 0, 100.0 - newHealth);
	}
	return HealAmount;
}

static const char g_ScoutDownedResponse[][] = {
	"vo/scout_paincrticialdeath01.mp3",
	"vo/scout_paincrticialdeath02.mp3",
	"vo/scout_paincrticialdeath03.mp3",
};

static const char g_SoldierDownedResponse[][] = {
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3",
	"vo/soldier_paincrticialdeath04.mp3",
};

static const char g_SniperDownedResponse[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
	"vo/sniper_paincrticialdeath04.mp3",
};

static const char g_DemomanDownedResponse[][] = {
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3",
};

static const char g_MedicDownedResponse[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
	"vo/medic_paincrticialdeath04.mp3",
};

static const char g_PyroDownedResponse[][] = {
	"vo/pyro_paincrticialdeath01.mp3",
	"vo/pyro_paincrticialdeath02.mp3",
	"vo/pyro_paincrticialdeath03.mp3",
};
static const char g_HeavyDownedResponse[][] = {
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3",
};

static const char g_SpyDownedResponse[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_EngineerDownedResponse[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
	"vo/engineer_paincrticialdeath04.mp3",
	"vo/engineer_paincrticialdeath05.mp3",
	"vo/engineer_paincrticialdeath06.mp3",
};

//revive!

static const char g_ScoutReviveResponse[][] = {
	"vo/scout_mvm_resurrect01.mp3",
	"vo/scout_mvm_resurrect02.mp3",
	"vo/scout_mvm_resurrect03.mp3",
	"vo/scout_mvm_resurrect04.mp3",
	"vo/scout_mvm_resurrect05.mp3",
	"vo/scout_mvm_resurrect06.mp3",
	"vo/scout_mvm_resurrect07.mp3",
	"vo/scout_mvm_resurrect08.mp3",
};

static const char g_SoldierReviveResponse[][] = {
	"vo/soldier_mvm_resurrect01.mp3",
	"vo/soldier_mvm_resurrect02.mp3",
	"vo/soldier_mvm_resurrect03.mp3",
	"vo/soldier_mvm_resurrect04.mp3",
	"vo/soldier_mvm_resurrect05.mp3",
	"vo/soldier_mvm_resurrect06.mp3",
};

static const char g_SniperReviveResponse[][] = {
	"vo/sniper_mvm_resurrect01.mp3",
	"vo/sniper_mvm_resurrect02.mp3",
	"vo/sniper_mvm_resurrect03.mp3",
	"vo/sniper_mvm_resurrect04.mp3",
};

static const char g_DemomanReviveResponse[][] = {
	"vo/demoman_mvm_resurrect01.mp3",
	"vo/demoman_mvm_resurrect02.mp3",
	"vo/demoman_mvm_resurrect03.mp3",
	"vo/demoman_mvm_resurrect04.mp3",
	"vo/demoman_mvm_resurrect05.mp3",
	"vo/demoman_mvm_resurrect06.mp3",
	"vo/demoman_mvm_resurrect07.mp3",
	"vo/demoman_mvm_resurrect08.mp3",
	"vo/demoman_mvm_resurrect09.mp3",
	"vo/demoman_mvm_resurrect10.mp3",
	"vo/demoman_mvm_resurrect11.mp3",
};

static const char g_MedicReviveResponse[][] = {
	"vo/medic_mvm_resurrect01.mp3",
	"vo/medic_mvm_resurrect02.mp3",
	"vo/medic_mvm_resurrect03.mp3",
};

static const char g_PyroReviveResponse[][] = {
	"vo/pyro_laughhappy01.mp3",
};
static const char g_HeavyReviveResponse[][] = {
	"vo/heavy_mvm_resurrect01.mp3",
	"vo/heavy_mvm_resurrect02.mp3",
	"vo/heavy_mvm_resurrect03.mp3",
	"vo/heavy_mvm_resurrect04.mp3",
	"vo/heavy_mvm_resurrect05.mp3",
	"vo/heavy_mvm_resurrect06.mp3",
	"vo/heavy_mvm_resurrect07.mp3",
};

static const char g_SpyReviveResponse[][] = {
	"vo/spy_mvm_resurrect01.mp3",
	"vo/spy_mvm_resurrect02.mp3",
	"vo/spy_mvm_resurrect03.mp3",
	"vo/spy_mvm_resurrect04.mp3",
	"vo/spy_mvm_resurrect05.mp3",
	"vo/spy_mvm_resurrect06.mp3",
	"vo/spy_mvm_resurrect07.mp3",
	"vo/spy_mvm_resurrect08.mp3",
	"vo/spy_mvm_resurrect09.mp3",
};

static const char g_EngineerReviveResponse[][] = {
	"vo/engineer_mvm_resurrect01.mp3",
	"vo/engineer_mvm_resurrect02.mp3",
	"vo/engineer_mvm_resurrect03.mp3",
};


//Saga Ability!

static const char g_ScoutSagaResponse[][] = {
	"vo/scout_stunballhit01.mp3",
	"vo/scout_stunballhit02.mp3",
	"vo/scout_stunballhit04.mp3",
	"vo/scout_stunballhit05.mp3",
	"vo/scout_stunballhit07.mp3",
	"vo/scout_stunballhit09.mp3",
	"vo/scout_stunballhit11.mp3",
	"vo/scout_stunballhit12.mp3",
	"vo/scout_stunballhit15.mp3",
};

static const char g_SoldierSagaResponse[][] = {
	"vo/taunts/soldier_taunts14.mp3",
	"vo/taunts/soldier_taunts17.mp3",
	"vo/soldier_specialcompleted02.mp3",
	"vo/soldier_specialcompleted05.mp3",
};

static const char g_SniperSagaResponse[][] = {
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_cheers08.mp3",
	"vo/sniper_cheers02.mp3",
	"vo/sniper_cheers03.mp3",
	"vo/sniper_cheers01.mp3",
};

static const char g_DemomanSagaResponse[][] = {
	"vo/demoman_battlecry01.mp3",
	"vo/demoman_battlecry03.mp3",
	"vo/demoman_battlecry04.mp3",
	"vo/demoman_battlecry07.mp3",
};

static const char g_MedicSagaResponse[][] = {
	"vo/medic_battlecry04.mp3",
	"vo/medic_battlecry05.mp3",
	"vo/medic_battlecry02.mp3",
};

static const char g_PyroSagaResponse[][] = {
	"vo/pyro_battlecry01.mp3",
	"vo/pyro_battlecry02.mp3",
};
static const char g_HeavySagaResponse[][] = {
	"vo/heavy_battlecry06.mp3",
	"vo/heavy_battlecry05.mp3",
	"vo/heavy_battlecry04.mp3",
	"vo/heavy_battlecry03.mp3",
	"vo/heavy_battlecry01.mp3",
};

static const char g_SpySagaResponse[][] = {
	"vo/spy_stabtaunt04.mp3",
	"vo/spy_stabtaunt05.mp3",
	"vo/spy_stabtaunt06.mp3",
	"vo/spy_stabtaunt08.mp3",
	"vo/spy_stabtaunt12.mp3",
	"vo/spy_stabtaunt12.mp3",
};

static const char g_EngineerSagaResponse[][] = {
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
};


#define VOICERESPONSESOUNDAREA 90
void PrecachePlayerGiveGiveResponseVoice()
{
	PrecacheSound("vo/taunts/scout_taunts06.mp3");
	PrecacheSound("vo/taunts/soldier_taunts17.mp3");
	PrecacheSound("vo/taunts/sniper_taunts22.mp3");
	PrecacheSound("vo/taunts/demoman_taunts11.mp3");
	PrecacheSound("vo/taunts/medic_taunts13.mp3");
	PrecacheSound("vo/pyro_laughevil01.mp3");
	PrecacheSound("vo/taunts/heavy_taunts16.mp3");
	PrecacheSound("vo/taunts/spy_taunts12.mp3");
	PrecacheSound("vo/taunts/engineer_taunts04.mp3");

	for (int i = 0; i < (sizeof(g_ScoutDownedResponse));	   i++) { PrecacheSound(g_ScoutDownedResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SoldierDownedResponse));	   i++) { PrecacheSound(g_SoldierDownedResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SniperDownedResponse));	   i++) { PrecacheSound(g_SniperDownedResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_DemomanDownedResponse));	   i++) { PrecacheSound(g_DemomanDownedResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_PyroDownedResponse));	   i++) { PrecacheSound(g_PyroDownedResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_HeavyDownedResponse));	   i++) { PrecacheSound(g_HeavyDownedResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SpyDownedResponse));	   i++) { PrecacheSound(g_SpyDownedResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_EngineerDownedResponse));	   i++) { PrecacheSound(g_EngineerDownedResponse[i]);	   }


	for (int i = 0; i < (sizeof(g_ScoutReviveResponse));	   i++) { PrecacheSound(g_ScoutReviveResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SoldierReviveResponse));	   i++) { PrecacheSound(g_SoldierReviveResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SniperReviveResponse));	   i++) { PrecacheSound(g_SniperReviveResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_DemomanReviveResponse));	   i++) { PrecacheSound(g_DemomanReviveResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_PyroReviveResponse));	   i++) { PrecacheSound(g_PyroReviveResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_HeavyReviveResponse));	   i++) { PrecacheSound(g_HeavyReviveResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SpyReviveResponse));	   i++) { PrecacheSound(g_SpyReviveResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_EngineerReviveResponse));	   i++) { PrecacheSound(g_EngineerReviveResponse[i]);	   }


	for (int i = 0; i < (sizeof(g_ScoutSagaResponse));	   i++) { PrecacheSound(g_ScoutSagaResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SoldierSagaResponse));	   i++) { PrecacheSound(g_SoldierSagaResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SniperSagaResponse));	   i++) { PrecacheSound(g_SniperSagaResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_DemomanSagaResponse));	   i++) { PrecacheSound(g_DemomanSagaResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_PyroSagaResponse));	   i++) { PrecacheSound(g_PyroSagaResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_HeavySagaResponse));	   i++) { PrecacheSound(g_HeavySagaResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_SpySagaResponse));	   i++) { PrecacheSound(g_SpySagaResponse[i]);	   }
	for (int i = 0; i < (sizeof(g_EngineerSagaResponse));	   i++) { PrecacheSound(g_EngineerSagaResponse[i]);	   }
}


stock void MakePlayerGiveResponseVoice(int client, int status)
{
	int ClassShown = view_as<int>(CurrentClass[client]);

	switch(status)
	{	
		case 1: //Irene cocky talk
		{
			switch(ClassShown)
			{
				case 1:
				{
					EmitSoundToAll("vo/taunts/scout_taunts06.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 2:
				{
					EmitSoundToAll("vo/taunts/sniper_taunts22.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 3:
				{
					EmitSoundToAll("vo/taunts/soldier_taunts17.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 4:
				{
					EmitSoundToAll("vo/taunts/demoman_taunts11.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 5:
				{
					EmitSoundToAll("vo/taunts/medic_taunts13.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 6:
				{
					EmitSoundToAll("vo/taunts/heavy_taunts16.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 7:
				{
					EmitSoundToAll("vo/pyro_laughevil01.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 8:
				{
					EmitSoundToAll("vo/taunts/spy_taunts12.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 9:
				{
					EmitSoundToAll("vo/taunts/engineer_taunts04.mp3", client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
			}
		}
		case 2: //downed, help!
		{
			switch(ClassShown)
			{
				case 1:
				{
					EmitSoundToAll(g_ScoutDownedResponse[GetRandomInt(0, sizeof(g_ScoutDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 2:
				{
					EmitSoundToAll(g_SniperDownedResponse[GetRandomInt(0, sizeof(g_SniperDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 3:
				{
					EmitSoundToAll(g_SoldierDownedResponse[GetRandomInt(0, sizeof(g_SoldierDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 4:
				{
					EmitSoundToAll(g_DemomanDownedResponse[GetRandomInt(0, sizeof(g_DemomanDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 5:
				{
					EmitSoundToAll(g_MedicDownedResponse[GetRandomInt(0, sizeof(g_MedicDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 6:
				{
					EmitSoundToAll(g_HeavyDownedResponse[GetRandomInt(0, sizeof(g_HeavyDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 7:
				{
					EmitSoundToAll(g_PyroDownedResponse[GetRandomInt(0, sizeof(g_PyroDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 8:
				{
					EmitSoundToAll(g_SpyDownedResponse[GetRandomInt(0, sizeof(g_SpyDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 9:
				{
					EmitSoundToAll(g_EngineerDownedResponse[GetRandomInt(0, sizeof(g_EngineerDownedResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
			}
		}
		case 3: //back from the dead!
		{
			switch(ClassShown)
			{
				case 1:
				{
					EmitSoundToAll(g_ScoutReviveResponse[GetRandomInt(0, sizeof(g_ScoutReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 2:
				{
					EmitSoundToAll(g_SniperReviveResponse[GetRandomInt(0, sizeof(g_SniperReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 3:
				{
					EmitSoundToAll(g_SoldierReviveResponse[GetRandomInt(0, sizeof(g_SoldierReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 4:
				{
					EmitSoundToAll(g_DemomanReviveResponse[GetRandomInt(0, sizeof(g_DemomanReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 5:
				{
					EmitSoundToAll(g_MedicReviveResponse[GetRandomInt(0, sizeof(g_MedicReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 6:
				{
					EmitSoundToAll(g_HeavyReviveResponse[GetRandomInt(0, sizeof(g_HeavyReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 7:
				{
					EmitSoundToAll(g_PyroReviveResponse[GetRandomInt(0, sizeof(g_PyroReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 8:
				{
					EmitSoundToAll(g_SpyReviveResponse[GetRandomInt(0, sizeof(g_SpyReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 9:
				{
					EmitSoundToAll(g_EngineerReviveResponse[GetRandomInt(0, sizeof(g_EngineerReviveResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
			}
		}
		case 4: //Saga Scream!
		{
			switch(ClassShown)
			{
				case 1:
				{
					EmitSoundToAll(g_ScoutSagaResponse[GetRandomInt(0, sizeof(g_ScoutSagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 2:
				{
					EmitSoundToAll(g_SniperSagaResponse[GetRandomInt(0, sizeof(g_SniperSagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 3:
				{
					EmitSoundToAll(g_SoldierSagaResponse[GetRandomInt(0, sizeof(g_SoldierSagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 4:
				{
					EmitSoundToAll(g_DemomanSagaResponse[GetRandomInt(0, sizeof(g_DemomanSagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 5:
				{
					EmitSoundToAll(g_MedicSagaResponse[GetRandomInt(0, sizeof(g_MedicSagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 6:
				{
					EmitSoundToAll(g_HeavySagaResponse[GetRandomInt(0, sizeof(g_HeavySagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 7:
				{
					EmitSoundToAll(g_PyroSagaResponse[GetRandomInt(0, sizeof(g_PyroSagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 8:
				{
					EmitSoundToAll(g_SpySagaResponse[GetRandomInt(0, sizeof(g_SpySagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
				case 9:
				{
					EmitSoundToAll(g_EngineerSagaResponse[GetRandomInt(0, sizeof(g_EngineerSagaResponse) - 1)], client, SNDCHAN_VOICE, VOICERESPONSESOUNDAREA, _, 1.0);
				}
			}
		}
	}
}

#if defined ZR
void KillDyingGlowEffect(int client)
{
	int entity = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
	if(entity > MaxClients)
		RemoveEntity(entity);

	entity = EntRefToEntIndex(i_DyingParticleIndication[client][1]);
	if(entity > MaxClients)
		RemoveEntity(entity);
}
#endif	// ZR

enum g_Collision_Group
{
    COLLISION_GROUP_NONE  = 0,
    COLLISION_GROUP_DEBRIS,            // Collides with nothing but world and static stuff
    COLLISION_GROUP_DEBRIS_TRIGGER,        // Same as debris, but hits triggers
    COLLISION_GROUP_INTERACTIVE_DEBRIS,    // Collides with everything except other interactive debris or debris
    COLLISION_GROUP_INTERACTIVE,        // Collides with everything except interactive debris or debris    Can be hit by bullets, explosions, players, projectiles, melee
    COLLISION_GROUP_PLAYER,            // Can be hit by bullets, explosions, players, projectiles, melee
    COLLISION_GROUP_BREAKABLE_GLASS,
    COLLISION_GROUP_VEHICLE,
    COLLISION_GROUP_PLAYER_MOVEMENT,    // For HL2, same as Collision_Group_Player, for TF2, this filters out other players and CBaseObjects

    COLLISION_GROUP_NPC,        // Generic NPC group
    COLLISION_GROUP_IN_VEHICLE,    // for any entity inside a vehicle    Can be hit by explosions. Melee unknown.
    COLLISION_GROUP_WEAPON,        // for any weapons that need collision detection
    COLLISION_GROUP_VEHICLE_CLIP,    // vehicle clip brush to restrict vehicle movement
    COLLISION_GROUP_PROJECTILE,    // Projectiles!
    COLLISION_GROUP_DOOR_BLOCKER,    // Blocks entities not permitted to get near moving doors
    COLLISION_GROUP_PASSABLE_DOOR,    // ** sarysa TF2 note: Must be scripted, not passable on physics prop (Doors that the player shouldn't collide with)
    COLLISION_GROUP_DISSOLVING,    // Things that are dissolving are in this group
    COLLISION_GROUP_PUSHAWAY,    // ** sarysa TF2 note: I could swear the collision detection is better for this than NONE. (Nonsolid on client and server, pushaway in player code) // Can be hit by bullets, explosions, projectiles, melee
    COLLISION_GROUP_NPC_ACTOR,        // Used so NPCs in scripts ignore the player.
    COLLISION_GROUP_NPC_SCRIPTED = 19,    // Used for NPCs in scripts that should not collide with each other.

    LAST_SHARED_COLLISION_GROUP,

    TF_COLLISIONGROUP_GRENADE = 20,
    TFCOLLISION_GROUP_OBJECT,
    TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT,
    TFCOLLISION_GROUP_COMBATOBJECT,
    TFCOLLISION_GROUP_ROCKETS,        // Solid to players, but not player movement. ensures touch calls are originating from rocket
    TFCOLLISION_GROUP_RESPAWNROOMS,
    TFCOLLISION_GROUP_TANK,
    TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS
	
};

float f_HitmarkerSameFrame[MAXPLAYERS];

stock void DoClientHitmarker(int client)
{
	if(b_HudHitMarker[client] && f_HitmarkerSameFrame[client] != GetGameTime())
	{
		EmitCustomToClient(client, "zombiesurvival/hm.mp3", _, _, 90, _, 0.75, 100);
		SetHudTextParams(-1.0, -1.0, 0.01, 125, 125, 125, 65);
		ShowHudText(client, 10, "X"); //we use 10
		f_HitmarkerSameFrame[client] = GetGameTime();	
	}
}


/*
	taken from 
	https://github.com/Daisreich/customguns-tf/blob/4b7b0eed2b2847052e11e7cb015b4ad05df5b2d6/scripting/include/customguns/stocks.inc#L503

*/

stock void UTIL_ImpactTrace(const float start[3], int iDamageType, const char[] pCustomImpactName = "Impact")
{
	if(TR_GetEntityIndex() == -1 || TR_GetFraction() == 1.0)
	{ 
		//+check sky
		return;
	}
	float origin[3]; TR_GetEndPosition(origin);

	TE_SetupEffectDispatch(origin, start, NULL_VECTOR, NULL_VECTOR, 0, 0.0, 1.0, 0, 0,
		getEffectDispatchStringTableIndex(pCustomImpactName), 0, iDamageType, TR_GetHitGroup(), TR_GetEntityIndex(), 0, 0.0, false,
		NULL_VECTOR, NULL_VECTOR, false, 0, NULL_VECTOR);
	TE_SendToAll();
}


stock void TE_SetupEffectDispatch(const float origin[3], const float start[3], const float angles[3], const float normal[3],
	int flags, float magnitude, float scale, int attachmentIndex, int surfaceProp, int effectName, int material, int damageType,
	int hitbox, int entindex, int color, float radius, bool customColors, const float customColor1[3], const float customColor2[3],
	bool controlPoint1, int cp1ParticleAttachment, const float cp1Offset[3])
{
	TE_Start("EffectDispatch");
	TE_WriteFloat("m_vOrigin[0]", origin[0]);
	TE_WriteFloat("m_vOrigin[1]", origin[1]);
	TE_WriteFloat("m_vOrigin[2]", origin[2]);
	TE_WriteFloat("m_vStart[0]", start[0]);
	TE_WriteFloat("m_vStart[1]", start[1]);
	TE_WriteFloat("m_vStart[2]", start[2]);
	TE_WriteVector("m_vAngles", angles);
	TE_WriteVector("m_vNormal", normal);
	TE_WriteNum("m_fFlags", flags);
	TE_WriteFloat("m_flMagnitude", magnitude);
	TE_WriteFloat("m_flScale", scale);
	TE_WriteNum("m_nAttachmentIndex", attachmentIndex);
	TE_WriteNum("m_nSurfaceProp", surfaceProp);
	TE_WriteNum("m_iEffectName", effectName);
	TE_WriteNum("m_nMaterial", material);
	TE_WriteNum("m_nDamageType", damageType);
	TE_WriteNum("m_nHitBox", hitbox);
	TE_WriteNum("entindex", entindex);
	TE_WriteNum("m_nColor", color);
	TE_WriteFloat("m_flRadius", radius);
	TE_WriteNum("m_bCustomColors", customColors);
	if(customColor1[0] == 110.0)
		TE_WriteVector("m_CustomColors.m_vecColor1", customColor1);
	if(customColor2[0] == 110.0)
		TE_WriteVector("m_CustomColors.m_vecColor2", customColor2);
	TE_WriteNum("m_bControlPoint1", controlPoint1);
	TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", cp1ParticleAttachment);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", cp1Offset[0]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", cp1Offset[1]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", cp1Offset[2]);
}

stock int getEffectDispatchStringTableIndex(const char[] effectName){
	static int table = INVALID_STRING_TABLE;
	if(table == INVALID_STRING_TABLE){
		table = FindStringTable("EffectDispatch");
	}
	int index;
	if( (index = FindStringIndex(table, effectName)) != INVALID_STRING_INDEX)
		return index;
	AddToStringTable(table, effectName);
	return FindStringIndex(table, effectName);
}

stock void SpawnTimer(float time)
{
	int timer = -1;
	while((timer = FindEntityByClassname(timer, "team_round_timer")) != -1)
	{
		SetVariantInt(0);
		AcceptEntityInput(timer, "ShowInHUD");
	}

	timer = CreateEntityByName("team_round_timer");
	DispatchKeyValue(timer, "show_in_hud", "1");
	DispatchSpawn(timer);
	
	SetVariantInt(RoundToCeil(time));
	AcceptEntityInput(timer, "SetTime");
	AcceptEntityInput(timer, "Resume");
	AcceptEntityInput(timer, "Enable");
	SetEntProp(timer, Prop_Send, "m_bAutoCountdown", false);
	GameRules_SetPropFloat("m_flStateTransitionTime", GetGameTime() + time);
	f_AllowInstabuildRegardless = GetGameTime() + time;
	CreateTimer(time, Timer_RemoveEntity, EntIndexToEntRef(timer));
	
	Event event = CreateEvent("teamplay_update_timer", true);
	event.Fire();
}

stock int GetOwnerLoop(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner > 0 && owner != entity)
		return GetOwnerLoop(owner);
	else
		return entity;
}

stock bool AtEdictLimit(int type)
{
	switch(type)
	{
		case EDICT_NPC:
		{
			if(CurrentEntities < 1600)
				return false;
		}
		case EDICT_PLAYER:
		{
			if(CurrentEntities < 1700)
				return false;
		}
		case EDICT_RAID:
		{
			if(CurrentEntities < 1800)
				return false;
		}
		case EDICT_EFFECT:
		{
			if(CurrentEntities < 1900)
				return false;
		}
	}

	return true;
}

stock int GetParticleEffectIndex(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("ParticleEffectNames");
	}
	
	int iIndex = FindStringIndex(table, sEffectName);
	if(iIndex != INVALID_STRING_INDEX)
		return iIndex;
	
	// This is the invalid string index
	return 0;
}

stock int GetEffectIndex(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("EffectDispatch");
	}
	
	int iIndex = FindStringIndex(table, sEffectName);
	if(iIndex != INVALID_STRING_INDEX)
		return iIndex;
	
	// This is the invalid string index
	return 0;
}

stock TE_SetupParticleEffect(const String:sParticleName[], ParticleAttachment_t:iAttachType, entity)//, const Float:fOrigin[3] = NULL_VECTOR, const Float:fAngles[3] = NULL_VECTOR, const Float:fStart[3] = NULL_VECTOR, iAttachmentPoint = -1, bool:bResetAllParticlesOnEntity = false)
{
	TE_Start("EffectDispatch");
	
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(sParticleName));
	
	new fFlags;
	if(entity > 0)
	{
		new Float:fEntityOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", fEntityOrigin);
		TE_WriteFloatArray("m_vOrigin[0]", fEntityOrigin, 3);

		if(iAttachType != PATTACH_WORLDORIGIN)
		{
			TE_WriteNum("entindex", entity);
			fFlags |= PARTICLE_DISPATCH_FROM_ENTITY;
		}
	}
	
	/*if(fOrigin != NULL_VECTOR)
		TE_WriteFloatArray("m_vOrigin[0]", fOrigin, 3);
	if(fStart != NULL_VECTOR)
		TE_WriteFloatArray("m_vStart[0]", fStart, 3);
	if(fAngles != NULL_VECTOR)
		TE_WriteVector("m_vAngles", fAngles);*/
	
	//if(bResetAllParticlesOnEntity)
	//	fFlags |= PARTICLE_DISPATCH_RESET_PARTICLES;
	
	TE_WriteNum("m_fFlags", fFlags);
	TE_WriteNum("m_nDamageType", _:iAttachType);
	TE_WriteNum("m_nAttachmentIndex", -1);
	
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffect"));
}

stock PrecacheEffect(const String:sEffectName[])
{
	static table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("EffectDispatch");
	}
	
	new bool:save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
stock PrecacheParticleEffect(const String:sEffectName[])
{
	static table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("ParticleEffectNames");
	}
	
	new bool:save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}

stock void Vector_DegToRad(float vecVector[3])
{
	vecVector[0] = DegToRad(vecVector[0]);
	vecVector[1] = DegToRad(vecVector[1]);
	vecVector[2] = DegToRad(vecVector[2]);
}

stock void Matrix_VectorMultiply(float matMatrix[3][3], float vecVector[3], float vecResult[3])
{
	vecResult[0] = matMatrix[0][0]*vecVector[0] + matMatrix[0][1]*vecVector[1] + matMatrix[0][2]*vecVector[2];
	vecResult[1] = matMatrix[1][0]*vecVector[0] + matMatrix[1][1]*vecVector[1] + matMatrix[1][2]*vecVector[2];
	vecResult[2] = matMatrix[2][0]*vecVector[0] + matMatrix[2][1]*vecVector[1] + matMatrix[2][2]*vecVector[2];
}

stock void Matrix_Set(float matMatrix[3][3], float f00, float f01, float f02, float f10, float f11, float f12, float f20, float f21, float f22)
{
	matMatrix[0][0] = f00;	matMatrix[0][1] = f01;	matMatrix[0][2] = f02;
	matMatrix[1][0] = f10;	matMatrix[1][1] = f11;	matMatrix[1][2] = f12;
	matMatrix[2][0] = f20;	matMatrix[2][1] = f21;	matMatrix[2][2] = f22;
}

stock void Matrix_GetRotationMatrix(float matMatrix[3][3], float fA, float fB, float fG)
{
	float fSinA = Sine(fA);
	float fCosA = Cosine(fA);

	float fSinB = Sine(fB);
	float fCosB = Cosine(fB);

	float fSinG = Sine(fG);
	float fCosG = Cosine(fG);

	Matrix_Set(matMatrix,
		fCosB*fCosG, 	fSinA*fSinB*fCosG - fCosA*fSinG, 	fCosA*fSinB*fCosG + fSinA*fSinG,
		fCosB*fSinG,	fSinA*fSinB*fSinG + fCosA*fCosG, 	fCosA*fSinB*fSinG - fSinA*fCosG,
		     -fSinB,		                fSinA*fCosB,	                    fCosA*fCosB
	);
}

stock void ForcePlayerCrouch(int client, bool enable, bool thirdpers = true)
{
	if(enable)
	{
		SetVariantInt(thirdpers);
		AcceptEntityInput(client, "SetForcedTauntCam");
		SetForceButtonState(client, true, IN_DUCK);
		SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 0);
		b_NetworkedCrouch[client] = true;
		SetEntProp(client, Prop_Send, "m_bDucked", true);
		SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
	}
	else
	{
		int Buttons = GetEntProp(client, Prop_Data, "m_afButtonForced");
		if(Buttons & IN_DUCK)
		{
			if(thirdperson[client])
			{
				SetVariantInt(1);
				AcceptEntityInput(client, "SetForcedTauntCam");
			}
			else
			{
				SetVariantInt(0);
				AcceptEntityInput(client, "SetForcedTauntCam");
#if defined ZR || defined RPG
				ViewChange_Update(client);
#endif
			}
			SetForceButtonState(client, false, IN_DUCK);
			b_NetworkedCrouch[client] = false;
			SetEntProp(client, Prop_Send, "m_bAllowAutoMovement", 1);
			SetEntProp(client, Prop_Send, "m_bDucked", false);
			SetEntityFlags(client, GetEntityFlags(client)&~FL_DUCKING);	
		}
	}
}

stock void SetForceButtonState(int client, bool apply, int button_flag)
{
	int Buttons = GetEntProp(client, Prop_Data, "m_afButtonForced");

	if(apply)
	{
		Buttons |= button_flag;
	}
	else
	{
		Buttons &= ~button_flag;
	}
	SetEntProp(client, Prop_Data, "m_afButtonForced", Buttons);
}

stock int GetTeam(int entity)
{
	if(entity > 0 && entity <= MAXENTITIES)
	{
		if(i_IsVehicle[entity])
		{
#if defined ZR
			entity = Vehicle_Driver(entity);
#else
			entity = GetEntPropEnt(entity, Prop_Data, "m_hPlayer");
#endif
			if(entity == -1)
				return -1;
		}

//#if !defined RTS
//		if(entity && entity <= MaxClients)
//			return GetClientTeam(entity);
//#endif

		if(TeamNumber[entity] == -1)
			TeamNumber[entity] = GetEntProp(entity, Prop_Data, "m_iTeamNum");
		
		return TeamNumber[entity];
	}
	return GetEntProp(entity, Prop_Data, "m_iTeamNum");
}

stock void SetTeam(int entity, int teamSet)
{
	if(entity > 0 && entity <= MAXENTITIES)
	{
		TeamNumber[entity] = teamSet;
		if(teamSet <= TFTeam_Blue)
		{
			if(entity <= MaxClients)
			{
				ChangeClientTeam(entity, teamSet);
			}
			else
			{
				SetEntProp(entity, Prop_Data, "m_iTeamNum", teamSet);
			}
		}
		else if(teamSet > TFTeam_Blue)
		{
			if(entity <= MaxClients)
			{
				if(teamSet >= 4)
				{
					ChangeClientTeam(entity, TFTeam_Red);
					//With this we set custom teams=
				}
				else
				{
					ChangeClientTeam(entity, TFTeam_Blue);	
				}
			}
			else
			{
				SetEntProp(entity, Prop_Data, "m_iTeamNum", 4);
			}
		}
	}
	else
	{
		SetEntProp(entity, Prop_Data, "m_iTeamNum", teamSet);
	}
}

stock bool FailTranslation(const char[] phrase)
{
	if(TranslationPhraseExists(phrase))
		return false;
	
	LogError("Translation '%s' does not exist", phrase);
	return true;
}

stock any GetItemInArray(any[] array, int pos)
{
	return array[pos];
}

//MaxNumBuffValue(0.6, 1.0, 0.0) = 1.0
//MaxNumBuffValue(0.6, 1.0, 1.0) = 0.6
//MaxNumBuffValue(0.6, 1.0, 1.25) = 0.55

stock float MaxNumBuffValue(float start, float max = 1.0, float valuenerf)
{
	// Our base number is max, the number when valuenerf is 0
	// Our high number is start, the number when valuenerf is 1

	// start = 0.6, max = 1.0
	//     1.0 + ((-0.4) * valuenerf)
	return max + ((start - max) * valuenerf);
}

/**
 * Spawns a 2-point particle (IE medigun beam, dispenser beam, etc) and connects it through 2 entities.
 * 
 * @param startEnt		The entity to start from.
 * @param startPoint	The point to attach the starting entity to. Can be left blank to use WorldSpaceCenter.
 * @param startXOff		Starting point X-axis offset.
 * @param startYOff		Starting point Y-axis offset.
 * @param startZOff		Starting point Z-axis offset.
 * @param endEnt		The entity to end at.
 * @param endPoint		The point to attach the end entity to. Can be left blank to use WorldSpaceCenter.
 * @param endXOff		Ending point X-axis offset.
 * @param endYOff		Ending point Y-axis offset.
 * @param endZOff		Ending point Z-axis offset.
 * @param effect		The particle to connect.
 * @param returnStart	Return parameter for the particle created at the start of the effect.
 * @param returnEnd		Return parameter for the particle created at the end of the effect.
 * @param duration		The duration of the effect. <= 0.0: infinite.
 */
#if defined ZR
stock void AttachParticle_ControlPoints(int startEnt, char startPoint[255] = "", float startXOff = 0.0, float startYOff = 0.0, float startZOff = 0.0, int endEnt = -1, char endPoint[255] = "", float endXOff = 0.0, float endYOff = 0.0, float endZOff = 0.0, char effect[255], int &returnStart, int &returnEnd, float duration = 0.0)
{
	float startPos[3], endPos[3], trash[3];
	if (!StrEqual(startPoint, ""))
		GetAttachment(startEnt, startPoint, startPos, trash);
	else
		WorldSpaceCenter(startEnt, startPos);

	if (!StrEqual(endPoint, ""))
		GetAttachment(endEnt, endPoint, endPos, trash);
	else
		WorldSpaceCenter(endEnt, endPos);

	//int particle = ParticleEffectAtOcean(startPos, effect, duration, false);
	//int particle2 = ParticleEffectAtOcean(endPos, effect, duration, false);
	int particle = ParticleEffectAt_Parent(startPos, effect, startEnt, startPoint, _, false);
	int particle2 = ParticleEffectAt_Parent(endPos, effect, endEnt, endPoint, _, false);
	if (duration > 0.0)
	{
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle2), TIMER_FLAG_NO_MAPCHANGE);
	}

	float offsets[3];
	offsets[0] = startXOff;
	offsets[1] = startYOff;
	offsets[2] = startZOff;
	SetParent(startEnt, particle, startPoint, offsets, true);

	offsets[0] = endXOff;
	offsets[1] = endYOff;
	offsets[2] = endZOff;
	SetParent(endEnt, particle2, endPoint, offsets, true);

	char szCtrlParti[128];
	Format(szCtrlParti, sizeof(szCtrlParti), "tf2ctrlpart%i", EntIndexToEntRef(particle2));
	DispatchKeyValue(particle, "targetname", szCtrlParti);

	DispatchKeyValue(particle2, "cpoint1", szCtrlParti);

	ActivateEntity(particle2);
	AcceptEntityInput(particle2, "start");

	returnStart = particle;
	returnEnd = particle2;
}

stock void GetPointFromAngles(float startLoc[3], float angles[3], float distance, float output[3], TraceEntityFilter filter, int traceFlags)
{
	float endLoc[3];
	
	TR_TraceRayFilter(startLoc, angles, traceFlags, RayType_Infinite, filter);
	TR_GetEndPosition(endLoc);
	constrainDistance(startLoc, endLoc, GetVectorDistance(startLoc, endLoc), distance);
	output = endLoc;
}

stock void SpawnBeam_Vectors(float StartLoc[3], float EndLoc[3], float beamTiming, int r, int g, int b, int a, int modelIndex, float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, int target = -1)
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
	
	TE_SetupBeamPoints(StartLoc, EndLoc, modelIndex, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	if (!IsValidClient(target))
	{
		TE_SendToAll();
	}
	else
	{
		TE_SendToClient(target);
	}
}

/**
 * Spawns the given effect multiple times in a ring surrounding the starting position.
 */
stock void SpawnParticlesInRing(float startPos[3], float radius, const char[] effect, int count, float duration = 0.2)
{
	for (float i = 0.0; i < 360.0; i += (360.0 / float(count)))
	{
		float spawnAng[3], endPos[3], Direction[3];
		spawnAng[0] = 0.0;
		spawnAng[1] = i;
		spawnAng[2] = 0.0;

		GetAngleVectors(spawnAng, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, radius);
		AddVectors(startPos, Direction, endPos);

		ParticleEffectAt(endPos, effect, duration);
	}
}

/**
 * Spawns the given effect multiple times in a ring surrounding the starting position, and returns all of the particles spawned by this in an ArrayList.
 */
stock ArrayList SpawnParticlesInRing_Return(float startPos[3], float radius, const char[] effect, int count, float duration = 2.0, bool ListShouldBeRefsAndNotIndexes = false)
{
	ArrayList returnValue = new ArrayList(255);

	for (float i = 0.0; i < 360.0; i += (360.0 / float(count)))
	{
		float spawnAng[3], endPos[3], Direction[3];
		spawnAng[0] = 0.0;
		spawnAng[1] = i;
		spawnAng[2] = 0.0;

		GetAngleVectors(spawnAng, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, radius);
		AddVectors(startPos, Direction, endPos);

		int particle = ParticleEffectAt(endPos, effect, duration);
		if (IsValidEntity(particle))
		{
			if (ListShouldBeRefsAndNotIndexes)
				PushArrayCell(returnValue, EntIndexToEntRef(particle));
			else
				PushArrayCell(returnValue, particle);
		}
	}

	return returnValue;
}

#endif

stock int FindEntityByNPC(int &i)
{
	for(; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != -1 && !b_NpcHasDied[entity])
		{
			i++;
			return entity;
		}
	}

	return -1;
}

enum
{
	HitCooldown = 0,
	SupportDisplayHurtHud = 1,
	IgniteClientside = 2,
	Osmosisdebuff = 3,
	TankThrowLogic = 4,
	
}

enum struct HitDetectionEnum
{
	int Attacker;
	int Victim;
	float Time;
	int Offset;
}
static ArrayList hGlobalHitDetectionLogic;

bool IsIn_HitDetectionCooldown(int attacker, int victim, int offset = 0)
{
	// ArrayList is empty currently
	if(!hGlobalHitDetectionLogic)
		return false;
	
	HitDetectionEnum data;
	int length = hGlobalHitDetectionLogic.Length;
	for(int i; i < length; i++)
	{
		// Loop through the arraylist to find the right attacker and victim
		hGlobalHitDetectionLogic.GetArray(i, data);
		if(data.Attacker == attacker && data.Victim == victim && data.Offset == offset)
		{
			// We found our match
			return data.Time > GetGameTime();
		}
	}

	// We found nothing
	return false;
}

void Set_HitDetectionCooldown(int attacker, int victim, float time, int offset = 0)
{
	// Create if empty
	if(!hGlobalHitDetectionLogic)
		hGlobalHitDetectionLogic = new ArrayList(sizeof(HitDetectionEnum));
	
	HitDetectionEnum data;
	int length = hGlobalHitDetectionLogic.Length;
	for(int i; i < length; i++)
	{
		// Loop through the arraylist to find the right attacker and victim
		hGlobalHitDetectionLogic.GetArray(i, data);
		if(data.Attacker == attacker && data.Victim == victim && data.Offset == offset)
		{
			// We found our match, update the value
			data.Time = time;
			hGlobalHitDetectionLogic.SetArray(i, data);
			return;
		}
	}

	// Create a new entry
	data.Attacker = attacker;
	data.Victim = victim;
	data.Offset = offset;
	data.Time = time;
	hGlobalHitDetectionLogic.PushArray(data);
}

// Deletes the entry if a entity died/removed/etc.
void EntityKilled_HitDetectionCooldown(int entity, int offset = -1)
{
	// ArrayList is empty currently
	if(!hGlobalHitDetectionLogic)
		return;
	
	HitDetectionEnum data;
	int length = hGlobalHitDetectionLogic.Length;
	for(int i; i < length; i++)
	{
		// Loop through the arraylist to find the right attacker and victim
		hGlobalHitDetectionLogic.GetArray(i, data);
		
		if(offset != -1 && data.Offset != offset)
			continue;

		if(data.Attacker == entity || data.Victim == entity)
		{
			// We found a match
			hGlobalHitDetectionLogic.Erase(i);
			i--;
			length--;
		}
	}
}

stock void GetMapName(char[] buffer, int size)
{
	GetCurrentMap(buffer, size);
	GetMapDisplayName(buffer, buffer, size);
}

stock int GetEntityFromHandle(any handle)
{
	int ent = handle & 0xFFF;
	if (ent == 0xFFF)
		ent = -1;

	return ent;
}

stock int GetEntityFromAddress(Address entity)
{
	if (entity == Address_Null)
		return -1;

	return GetEntityFromHandle(LoadFromAddress(entity + view_as<Address>(FindDataMapInfo(0, "m_angRotation") + 12), NumberType_Int32));
}

stock void RunScriptCode(int entity, int activator, int caller, const char[] format, any...)
{
    if (!IsValidEntity(entity))
        return;
    
    static char buffer[1024];
    VFormat(buffer, sizeof(buffer), format, 5);
    
    SetVariantString(buffer);
    AcceptEntityInput(entity, "RunScriptCode", activator, caller);
}


stock void Projectile_TeleportAndClip(int entity)
{
	float VecPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", VecPos);

	//todo: instead of angle, get speed of said projectile, and caclulate the angle from said speed
	//This is just a placeholder
	float VecAng[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", VecAng);
	Handle hTrace = TR_TraceRayFilterEx(VecPos, VecAng, ( MASK_SOLID | CONTENTS_SOLID ), RayType_Infinite, BulletAndMeleeTrace, entity);
	if ( TR_GetFraction(hTrace) < 1.0)
	{
		//collision
		TR_GetEndPosition(VecPos, hTrace);
		SDKCall_SetAbsOrigin(entity, VecPos);
	}
	delete hTrace;
}


void Stocks_ColourPlayernormal(int client)
{
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
#if defined ZR
		if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
			continue;
#endif

		SetEntityRenderMode(entity, RENDER_NORMAL);
		SetEntityRenderColor(entity, 255, 255, 255, 255);
	}
}

stock void SetEntityRenderColor_NpcAll(int entity, float r, float g, float b)
{	
	f_EntityRenderColour[entity][0] *= r;
	f_EntityRenderColour[entity][1] *= g;
	f_EntityRenderColour[entity][2] *= b;
	Update_SetEntityRenderColor(entity);
	for(int WearableSlot=0; WearableSlot<sizeof(i_Wearable[]); WearableSlot++)
	{
		int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
		if(IsValidEntity(WearableEntityIndex) && !b_EntityCantBeColoured[WearableEntityIndex])
		{	
			f_EntityRenderColour[WearableEntityIndex][0] *= r;
			f_EntityRenderColour[WearableEntityIndex][1] *= g;
			f_EntityRenderColour[WearableEntityIndex][2] *= b;
			Update_SetEntityRenderColor(WearableEntityIndex);
		}
	}
}
