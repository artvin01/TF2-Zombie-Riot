// #include <spooky_stocks>
#include <sdkhooks>
#include <sdktools>
#include <tf2_stocks>

static int AnimEntity[MAXPLAYERS+1] = {-1, ...};
static int Animator_CameraEntity[MAXPLAYERS+1] = {-1, ...};
//static int Animator_RenderColor[MAXPLAYERS+1][4];

static float Animator_MaxTilt_Pitch[MAXPLAYERS+1] = {0.0, ...};
static float Animator_CurrentTilt_Pitch[MAXPLAYERS+1] = {0.0, ...};
static float Animator_MaxTilt_Roll[MAXPLAYERS+1] = {0.0, ...};
static float Animator_CurrentTilt_Roll[MAXPLAYERS+1] = {0.0, ...};
static float Animator_TiltMod[MAXPLAYERS+1] = {0.0, ...};

static bool Animator_TiltActive[MAXPLAYERS+1] = {false, ...};
static bool Animator_CameraFrozen[MAXPLAYERS+1] = {false, ...};

static char Animator_BaseModel[MAXPLAYERS+1][255];

/**
 * Retrieves the entity used to handle a client's animations.
 *
 * @param client        Client index. Must be alive.
 *
 * @return              Entity index for the client's animation handler entity (-1 if handler is invalid or does not exist).
 *
 * @error               Invalid client index, or the handler does not exist.
*/
stock int Animator_GetHandler(int client)
{
	int ReturnValue = -1;
	
	if (client > 0 && client <= MaxClients)
	{
		ReturnValue = EntRefToEntIndex(AnimEntity[client]);
	}
		
	return ReturnValue;
}

/**
 * Creates a generic player animation.
 *
 * @param client		Client to be animated. Must be alive.
 * @param animation	Name of the animation sequence to force.
 * @param duration		Animation length; you can find this by dividing the animation's frame count by its frame rate. If <= 0.0, the duration will be assumed to be infinite.
 * @param rate			Animation playback rate.
 *
 * @error				Invalid client index.
 */
stock void Animator_PlayGeneric(int client, char animation[255], float duration = 0.0, float rate = 1.0)
{
	if (client < 1 || client > MaxClients)
	{
		return;
	}
	
	AnimEntity[client] = Animator_CreateHandler(client);
	Animator_SetAnimation(client, animation, rate);
	SDKUnhook(client, SDKHook_PreThink, Animator_PreThink);
	SDKHook(client, SDKHook_PreThink, Animator_PreThink);
	
	if (duration > 0.0)
	{
		CreateTimer(duration, Animator_EndTimedAnimation, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

Action Animator_EndTimedAnimation(Handle Animator_EndTimedAnimation, int ID)
{
	int client = GetClientOfUserId(ID);
	if (!client)
		return Plugin_Continue;
		
	Animator_EndAnimation(client, false, false, false, false);
	return Plugin_Continue;
}

/**
 * Forces a player to look at an animation from a given camera angle.
 *
 * @param client	Client to be forced to watch.
 * @param blockInput	Whether or not to freeze the client's input while they're watching the animation.
 * @param cameraEntity	Entity whose model to use as a "camera"
 * @param cameraBone	Name of cameraEntity's attachment to act as the camera's point of origin.
 * @param targetEntity	Entity to aim the camera at.
 * @param targetBone	Specific bone to aim the camera at.
 * @param duration		Duration to lock camera view point (<= 0.0: infinite, use Animator_ExitCamera to stop it)
 * @param autoLook		Whether or not to automatically aim the camera at the target every frame.
 * @param direct		Look DIRECTLY at the target entity, instead of an attachment point?
 * @param xOffset		Camera's starting angles modifier (pitch)
 * @param yOffset		Camera's starting angles modifier (yaw)
 * @param zOffset		Camera's starting angles modifier (roll)
 * @param xOverride		If != 0.0, camera's starting pitch will ALWAYS be this
 * @param yOverride		If != 0.0, camera's starting yaw will ALWAYS be this
 * @param zOverride		If != 0.0, camera's starting roll will ALWAYS be this
 * @param test			Prints debug info in the chat.
 *
 * @return The camera entity (-1 if an error occurs). Use Animator_GetTargetEntity after calling this method to retrieve the camera's target.
 * @error Invalid client index, invalid cameraEntity, or invalid targetEntity.
 */
stock int Animator_ForceCameraView(int client, bool blockInput, int cameraEntity, float duration, bool autoLook = true, bool direct = false, float xOffset = 0.0, float yOffset = 0.0, float zOffset = 0.0, float xOverride = 0.0, float yOverride = 0.0, float zOverride = 0.0, bool test = false)
{
	if (client < 1 || client > MaxClients || !IsValidEntity(cameraEntity))
		return -1;
		
	int camera = Camera_AttachCamera(cameraEntity, client, xOffset, yOffset, zOffset, xOverride, yOverride, zOverride, test);
	
	if (!IsValidEntity(camera))
		return -1;
		
	Animator_CameraEntity[client] = EntIndexToEntRef(camera);
	
	Handle pack;
	CreateDataTimer(0.0, Camera_ApplyCamera, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, EntIndexToEntRef(cameraEntity));
	WritePackFloat(pack, duration);
	
	return camera;
}

Action Camera_ApplyCamera(Handle apply, any pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float duration = ReadPackFloat(pack);
	
	if (!client)
		return Plugin_Continue;
		
	int camera = EntRefToEntIndex(Animator_CameraEntity[client]);
	
	if (!IsValidEntity(camera) || !IsValidEntity(ent))
		return Plugin_Continue;
	
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
	
	TF2_AddCondition(client, TFCond_FreezeInput);
	Animator_CameraFrozen[client] = true;
	
	SDKUnhook(client, SDKHook_PreThink, Camera_PreThink);
	SDKHook(client, SDKHook_PreThink, Camera_PreThink);
	
	if (duration > 0.0)
	{
		CreateTimer(duration, Camera_EndOnTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

stock int Camera_AttachCamera(int ent, int client, float xOffset, float yOffset, float zOffset, float xOverride = 0.0, float yOverride = 0.0, float zOverride = 0.0, bool test = false)
{
	int cam = CreateEntityByName("info_particle_system");
	int info = CreateEntityByName("info_target");
	if (IsValidEntity(cam) && IsValidEntity(ent) && IsValidEntity(info))
	{
		float pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		PrintToChatAll("%f,%f,%f",pos[0],pos[1],pos[2]);
		SDKCall_SetLocalOrigin(info,pos);
		
		DispatchKeyValue(cam, "effect_name", "");
		
		SetVariantString("!activator");
		AcceptEntityInput(info, "SetParent", ent, info);
		DispatchSpawn(info);
		ActivateEntity(info);
		AcceptEntityInput(info, "Start");
	
		float origin[3], rotation[3], finalAng[3];
//		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", origin);
		GetEntPropVector(ent, Prop_Send, "m_angRotation", rotation);
		GetEntPropVector(info, Prop_Data, "m_vecAbsOrigin", origin);
		PrintToChatAll("%f,%f,%f",origin[0],origin[1],origin[2]);
		
		
		for (int i = 0; i < 5; i++) //I know this is stupid, but if I don't do this, the camera angles randomly break, even after EVERYTHING else I had to do to make this plugin work
		{
			TeleportEntity(cam, origin, rotation, NULL_VECTOR);
			char AnglesString[255];
			Format(AnglesString, sizeof(AnglesString), "%i %i %i", RoundFloat(rotation[0]), RoundFloat(rotation[1]), RoundFloat(rotation[2]));
			DispatchKeyValue(cam, "angles", AnglesString);
		}
		
		SetVariantString("!activator");
		AcceptEntityInput(cam, "SetParent", ent, cam);
		
		Handle pack;
		CreateDataTimer(0.0, Camera_FinalizeCamera, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, EntIndexToEntRef(cam));
		WritePackCell(pack, EntIndexToEntRef(ent));
		return cam;
	}
	return -1;
}

stock float[] Camera_GetOffset(int ent, char bone[255])
{
	float originalAngles[3], tempAngles[3], vecOffset[3], dummyOrigin[3];
	for (int i = 0; i < 3; i++)
	{
		tempAngles[i] = 0.0;
	}
	
	GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", originalAngles);
	TeleportEntity(ent, NULL_VECTOR, tempAngles, NULL_VECTOR);
//	GetAttachment(ent, bone, dummyOrigin, vecOffset);
	TeleportEntity(ent, NULL_VECTOR, originalAngles, NULL_VECTOR);
	
	return vecOffset;
}

public Action Camera_FinalizeCamera(Handle final, any pack)
{
	ResetPack(pack);
	int cam = EntRefToEntIndex(ReadPackCell(pack));
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	
	if (IsValidEntity(cam) && IsValidEntity(ent))
	{
		DispatchKeyValue(cam, "targetname", "cam"); 
		DispatchSpawn(cam);
		ActivateEntity(cam);
		AcceptEntityInput(cam, "Start");
	}
	return Plugin_Continue;
}

/**
 * Gets the camera entity being used by a given client.
 *
 * @param client		Camera's owner.
 
 * @return Camera's entity index (-1 if invalid/doesn't exist).
 * @error Invalid client index.
 */
public int Animator_GetCameraEntity(int client)
{
	if (client < 1 || client > MaxClients)
		return -1;
		
	return IsValidEntity(EntRefToEntIndex(Animator_CameraEntity[client])) ? EntRefToEntIndex(Animator_CameraEntity[client]) : -1;
}

public Action Camera_PreThink(int client)
{
	if (client < 1 || client > MaxClients)
		return Plugin_Continue;
		
	int camera = EntRefToEntIndex(Animator_CameraEntity[client]);
	
	if (!IsValidEntity(camera))
		return Plugin_Continue;
	
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
	SetClientViewEntity(client, camera);
	return Plugin_Continue;
}

public Action Camera_EndOnTimer(Handle endIt, int id)
{
	int client = GetClientOfUserId(id);
	if (client > 0 && client <= MaxClients)
	{
		Animator_EndCamera(client);
	}
	return Plugin_Continue;
}

/**
 * Disables the special animator camera for a given client.
 *
 * @param client	Client to end camera for.
 *
 * @error Invalid client index.
 */
public void Animator_EndCamera(int client)
{
	if (client < 1 || client > MaxClients)
		return;
		
	SetClientViewEntity(client, client);
	if (Animator_CameraFrozen[client])
	{
		TF2_RemoveCondition(client, TFCond_FreezeInput);
		Animator_CameraFrozen[client] = false;
	}
		
	SDKUnhook(client, SDKHook_PreThink, Camera_PreThink);
	
	int camera = EntRefToEntIndex(Animator_CameraEntity[client]);
	
	Animator_CameraEntity[client] = -1;
	
	if (!IsValidEntity(camera))
		return;
		
	AcceptEntityInput(camera, "kill");
}

 /**
  * Creates a player animation with advanced settings.
  *
  * @param client		Client to be animated. Must be alive.
  * @param animation	Name of the animation sequence to force.
  * @param duration		Animation length; you can find this by dividing the animation's frame count by its frame rate. If <= 0.0, the duration will be assumed to be infinite.
  * @param rate			Animation playback rate.
  * @param freeze		Should the player be frozen while this animation is active?
  * @param invuln		Should the player be invulnerable while this animation is active?
  * @param blockTurn	Should the player be unable to move their camera while the animation is active?
  * @param thirdPerson  Should the player be forced into a third person perspective when this animation is activated?
  * @param tiltModel	Should the model tilt based on the player's movements?
  * @param tiltMod		The rate at which the model tilts, if tiltModel == true.
  * @param maxTilt_Pitch	The maximum angle at which the model can tilt forward or back, if tiltModel == true.
  * @param maxTilt_Roll		The maximum angle at which the model can tilt left or right, if tiltModel == true.
  * @param ForceParent		Whether or not the animator's model should always be at the player's location
  * @param ModelOverride	Alternative model to use instead of the player's base model. Leave empty to just use the player's base model.
  *
  * @error				Invalid client index.
  */
stock void Animator_PlayAdvanced(int client, char animation[255], float duration = 0.0, float rate = 1.0, bool freeze = true, bool invuln = true, bool blockTurn = false, bool thirdPerson = true, bool tiltModel = false, float tiltMod = 1.0, float maxTilt_Pitch = 15.0, float maxTilt_Roll = 25.0, bool ForceParent = true, char ModelOverride[255] = "")
{
	if (client < 1 || client > MaxClients)
	{
		return;
	}
	
	AnimEntity[client] = Animator_CreateHandler(client, ForceParent, ModelOverride);
	Animator_SetAnimation(client, animation, rate);
	
	if (ForceParent)
	{
		SDKUnhook(client, SDKHook_PreThink, Animator_PreThink);
		SDKHook(client, SDKHook_PreThink, Animator_PreThink);
	}
	
	if (freeze)
	{
		SetEntityMoveType(client, MOVETYPE_NONE);
	}
	
	if (invuln)
	{
		TF2_AddCondition(client, TFCond_UberchargedHidden);
		TF2_AddCondition(client, TFCond_UberBlastResist);
	}
	
	if (blockTurn)
	{
		TF2_AddCondition(client, TFCond_FreezeInput);
	}
	
	if (thirdPerson)
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
	
	if (tiltModel)
	{
		Animator_MaxTilt_Roll[client] = maxTilt_Roll;
		Animator_MaxTilt_Pitch[client] = maxTilt_Pitch;
		Animator_TiltMod[client] = tiltMod;
		Animator_TiltActive[client] = true;
	}
	
	if (duration > 0.0)
	{
		Handle pack;
		CreateDataTimer(duration, Animator_EndTimedAnimation_Advanced, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, view_as<int>(freeze));
		WritePackCell(pack, view_as<int>(invuln));
		WritePackCell(pack, view_as<int>(blockTurn));
		WritePackCell(pack, view_as<int>(thirdPerson));
	}
}

 /**
  * Creates a model entity and forces an animation on it.
  *
  * @param model		The model to be used.
  * @param animation	Name of the animation sequence to force.
  * @param spawnLoc		The location to spawn the model at.
  * @param spawnAng		The model's starting angles.
  * @param skin			The skin to be used for the model.
  * @param rate			Animation playback rate.
  * @param life		    How long should the model exist for? (0.0 or below = infinite)
  *
  * @return				The entity index of the created model.
  *
  * @error				Invalid client index.
  */
stock int Animator_SpawnDummy(char model[255], char animation[255], float spawnLoc[3], float spawnAng[3], char skin[255], float rate = 1.0, float life = 0.0)
{
	int ReturnValue = -1;
	
	ReturnValue = CreateEntityByName("prop_dynamic_override");
	
	if(IsValidEntity(ReturnValue))
	{
		TeleportEntity(ReturnValue, spawnLoc, NULL_VECTOR, NULL_VECTOR);
	
		DispatchKeyValue(ReturnValue, "skin", skin);
		DispatchKeyValue(ReturnValue, "model", model);	
		
		DispatchKeyValueVector(ReturnValue, "angles", spawnAng);
		
		DispatchSpawn(ReturnValue);
		ActivateEntity(ReturnValue);
		
		SetVariantString(animation);
		AcceptEntityInput(ReturnValue, "SetAnimation");
		DispatchKeyValueFloat(ReturnValue, "playbackrate", rate);
		
		if (life > 0.0)
		{
			CreateTimer(life, Timer_RemoveEntity, EntIndexToEntRef(ReturnValue), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}

public Action Animator_EndTimedAnimation_Advanced(Handle Animator_EndTimedAnimation_Advanced, any pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	if (client < 1 || client > MaxClients)
		return Plugin_Continue;
		
	bool unfreeze = view_as<bool>(ReadPackCell(pack));
	bool removeInvuln = view_as<bool>(ReadPackCell(pack));
	bool allowTurn = view_as<bool>(ReadPackCell(pack));
	bool firstPerson = view_as<bool>(ReadPackCell(pack));
	
	Animator_EndAnimation(client, unfreeze, removeInvuln, allowTurn, firstPerson);
	return Plugin_Continue;
}

public Action Animator_PreThink(int client)
{
	if (client < 1 || client > MaxClients)
		return Plugin_Continue;
		
	int anim = EntRefToEntIndex(AnimEntity[client]);
	if (IsValidEntity(anim))
	{
		float Origin[3];
		GetClientAbsOrigin(client, Origin);
		DispatchKeyValueVector(anim, "origin", Origin);
		
		if (Animator_TiltActive[client])
		{
			float Angles[3];
			GetClientEyeAngles(client, Angles);
				
			int buttons = GetClientButtons(client);
					
			if (buttons & IN_FORWARD != 0)
			{
				Animator_CurrentTilt_Pitch[client] += Animator_TiltMod[client];
			}
			if (buttons & IN_BACK != 0)
			{
				Animator_CurrentTilt_Pitch[client] += -Animator_TiltMod[client];
			}
					
			if (buttons & IN_FORWARD == 0 && buttons & IN_FORWARD == 0)
			{
				if (Animator_CurrentTilt_Pitch[client] > 0.0)
				{
					Animator_CurrentTilt_Pitch[client] += -Animator_TiltMod[client];
					if (Animator_CurrentTilt_Pitch[client] < 0.0)
					{
						Animator_CurrentTilt_Pitch[client] = 0.0;
					}
				}
				else if (Animator_CurrentTilt_Pitch[client] < 0.0)
				{
					Animator_CurrentTilt_Pitch[client] += Animator_TiltMod[client];
					if (Animator_CurrentTilt_Pitch[client] > 0.0)
					{
						Animator_CurrentTilt_Pitch[client] = 0.0;
					}
				}
			}
					
			if (buttons & IN_MOVERIGHT != 0)
			{
				Animator_CurrentTilt_Roll[client] += Animator_TiltMod[client];
			}
			if (buttons & IN_MOVELEFT != 0)
			{
				Animator_CurrentTilt_Roll[client] += -Animator_TiltMod[client];
			}
					
			if (buttons & IN_MOVERIGHT == 0 && buttons & IN_MOVELEFT == 0)
			{
				if (Animator_CurrentTilt_Roll[client] > 0.0)
				{
					Animator_CurrentTilt_Roll[client] += -Animator_TiltMod[client];
					if (Animator_CurrentTilt_Roll[client] < 0.0)
					{
						Animator_CurrentTilt_Roll[client] = 0.0;
					}
				}
				else if (Animator_CurrentTilt_Roll[client] < 0.0)
				{
					Animator_CurrentTilt_Roll[client] += Animator_TiltMod[client];
					if (Animator_CurrentTilt_Roll[client] > 0.0)
					{
						Animator_CurrentTilt_Roll[client] = 0.0;
					}
				}
			}
					
			if (Animator_CurrentTilt_Pitch[client] > Animator_MaxTilt_Pitch[client])
			{
				Animator_CurrentTilt_Pitch[client] = Animator_MaxTilt_Pitch[client];
			}
			else if (Animator_CurrentTilt_Pitch[client] < -Animator_MaxTilt_Pitch[client])
			{
				Animator_CurrentTilt_Pitch[client] = -Animator_MaxTilt_Pitch[client];
			}
					
			if (Animator_CurrentTilt_Roll[client] > Animator_MaxTilt_Roll[client])
			{
				Animator_CurrentTilt_Roll[client] = Animator_MaxTilt_Roll[client];
			}
			else if (Animator_CurrentTilt_Roll[client] < -Animator_MaxTilt_Roll[client])
			{
				Animator_CurrentTilt_Roll[client] = -Animator_MaxTilt_Roll[client];
			}
					
			Angles[0] = Animator_CurrentTilt_Pitch[client];
			Angles[2] = Animator_CurrentTilt_Roll[client];
					
			DispatchKeyValueVector(anim, "angles", Angles);
		}
	}
	return Plugin_Continue;
}

 /**
  * Changes the active animation of an existing animation handler.
  *
  * @param client		Client to be animated. Must be alive.
  * @param animation	Name of the new animation sequence to force.
  *
  * @error	Invalid client index, or their animation handler is not valid.
  */
stock void Animator_SetAnimation(int client, char animation[255], float rate = 1.0)
{
	if (client < 1 || client > MaxClients)
	{
		return;
	}
	
	int anim = EntRefToEntIndex(AnimEntity[client]);
	if (IsValidEntity(anim))
	{
		SetVariantString(animation);
		AcceptEntityInput(anim, "SetAnimation");
		DispatchKeyValueFloat(anim, "playbackrate", rate);
	}
}

 /**
  * Changes the active animation of an entity.
  *
  * @param ent			Entity to be animated.
  * @param animation	Name of the new animation sequence to force.
  * @param rate			Playback rate.
  *
  * @error	Invalid entity index.
  */
stock void Animator_SetModelAnimation(int ent, char animation[255], float rate = 1.0)
{
	if (!IsValidEdict(ent))
	{
		return;
	}

	SetVariantString(animation);
	AcceptEntityInput(ent, "SetAnimation");
	DispatchKeyValueFloat(ent, "playbackrate", rate);
}

/**
 * Ends a client's animation, and returns them to their normal model.
 *
 * @param client		Client index. Does not need to be alive.
 * @param unfreeze		Do you want to unfreeze the client?
 * @param allowTurn		Do you want to allow the client to move their camera again?
 * @param firstPerson	Do you want to force the client back into a first person perspective?
 *
 * @error		Invalid client index.
 */
stock void Animator_EndAnimation(int client, bool unfreeze = true, bool removeInvuln = true, bool allowTurn = true, bool firstPerson = true)
{
	if (client < 1 || client > MaxClients)
	{
		return;
	}
	
	Animator_CurrentTilt_Pitch[client] = 0.0;
	Animator_CurrentTilt_Roll[client] = 0.0;
	Animator_TiltActive[client] = false;
	SDKUnhook(client, SDKHook_PreThink, Animator_PreThink);
	
	if (IsPlayerAlive(client))
	{
		SetVariantString(Animator_BaseModel[client]);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", true);
		
		if (unfreeze)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
		
		if (removeInvuln)
		{
			TF2_RemoveCondition(client, TFCond_UberchargedHidden);
			TF2_RemoveCondition(client, TFCond_UberBlastResist);
		}
		
		if (allowTurn)
		{
			TF2_RemoveCondition(client, TFCond_FreezeInput);
		}
		
		if (firstPerson)
		{
			SetVariantInt(0);
			AcceptEntityInput(client, "SetForcedTauntCam");
		}
	}
	
	Animator_DestroyHandler(client);
}

/**
 * Removes a client's animation handler. Called automatically by Animator_EndAnimation, which you should probably use instead unless you know EXACTLY what you're doing.
 *
 * @param client	The client whose animation handler should be removed.
 *
 * @error		Invalid client index.
 */
stock void Animator_DestroyHandler(int client)
{
	if (client < 1 || client > MaxClients)
	{
		return;
	}
	
	//SetEntityRenderColor(client, Animator_RenderColor[client][0], Animator_RenderColor[client][1], Animator_RenderColor[client][2], Animator_RenderColor[client][3]);
	int anim = EntRefToEntIndex(AnimEntity[client]);
	if (IsValidEntity(anim))
	{
		RemoveEntity(anim);
		AnimEntity[client] = -1;
	}
}

/**
 * Creates a client's animation handler. Called automatically by every method which forces an animation.
 *
 * @param client	Client to create a handler for.
 *
 * @return	The entity index of the newly-created animation handler.
 *
 * @error Invalid client index, or the client is not alive.
 */
stock int Animator_CreateHandler(int client, bool ForceParent = true, char ModelOverride[255] = "")
{
	int ReturnValue = -1;
	
	if (client < 1 || client > MaxClients)
	{
		return ReturnValue;
	}
	
	Animator_DestroyHandler(client);
	
	ReturnValue = EntIndexToEntRef(CreateEntityByName("prop_dynamic_override"));
	
	int temp = EntRefToEntIndex(ReturnValue);
	if(IsValidEntity(temp))
	{
		float pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(temp, pos, NULL_VECTOR, NULL_VECTOR);
	
		GetEntPropString(client, Prop_Data, "m_ModelName", Animator_BaseModel[client], sizeof(Animator_BaseModel[]));
		DispatchKeyValue(temp, "skin", GetClientTeam(client)==3 ? "1" : "0");
		
		if (StrEqual(ModelOverride, ""))
		{
			DispatchKeyValue(temp, "model", Animator_BaseModel[client]);
		}
		else
		{
			DispatchKeyValue(temp, "model", ModelOverride);
		}
	
		GetClientEyeAngles(client, pos);
		pos[0] = 0.0;
		pos[2] = 0.0
		DispatchKeyValueVector(temp, "angles", pos);
	
		if (ForceParent)
		{
			SetEntPropEnt(temp, Prop_Send, "m_hOwnerEntity", client);
			SetVariantString("root");
			AcceptEntityInput(temp, "SetParentAttachmentMaintainOffset", temp, temp);
			DispatchKeyValue(temp, "targetname", "present");
		}
		
		DispatchSpawn(temp);
		ActivateEntity(temp);
	
		//TF2_CreateGlow(temp, GetClientTeam(client));
	
		SetVariantString("models/empty.mdl");
		AcceptEntityInput(client, "SetCustomModel");
		
		//GetEntityRenderColor(client, Animator_RenderColor[client][0], Animator_RenderColor[client][1], Animator_RenderColor[client][2], Animator_RenderColor[client][3]);
		
		//SetEntityRenderMode(client, RENDER_TRANSALPHA);
		//SetEntityRenderColor(client, 0, 0, 0, 0);
		
		AnimEntity[client] = ReturnValue;
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}