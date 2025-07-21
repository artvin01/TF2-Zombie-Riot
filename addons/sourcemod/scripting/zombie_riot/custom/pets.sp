#pragma semicolon 1
#pragma newdecls required

#define PET_ITEM_SLOT	5

enum
{
	Pet_Combine = 0
}

static const char PetModel[][] =
{
	COMBINE_CUSTOM_MODEL
};

static const float PetResize[] =
{
	0.6
};

static const char PetAnimation[][][] =
{
	// These are sequence names
	//{ "idle", "duck", "walk", "run", "attack", "stun", "taunt", "jump"	}
	{ "Idle_Baton", "Crouch_idle_pistol", "Crouch_all", "run_all", "pushplayer", "forcescanner", "activatebaton", "jump_holding_jump"	}
};

enum
{
	Anim_Idle = 0,
	Anim_Duck,
	Anim_Walk,
	Anim_Run,
	Anim_Attack,
	Anim_Taunt,
	Anim_Spawn,
	Anim_Jump,
	Anim_MAX
}

static int PetRef[MAXPLAYERS] = {INVALID_ENT_REFERENCE, ...};
static int PetEquipped[MAXPLAYERS];
static bool PlayingAnim[MAXPLAYERS];
static int TickAnim[MAXPLAYERS];
static int LastAnim[MAXPLAYERS];

void Pets_PlayerResupply(int client)
{
	int index = Store_GetSpecialOfSlot(client, PET_ITEM_SLOT);
	if(index == -1)
		return;
	
	TickAnim[client] = 0;
	PlayingAnim[client] = false;
	PetEquipped[client] = index;
	LastAnim[client] = Anim_MAX;
	
	int entity = CreateEntityByName("prop_dynamic");
	if(entity != -1)
	{
		DispatchKeyValue(entity, "model", PetModel[index]);
		DispatchKeyValue(entity, "solid", "0");
		DispatchKeyValueFloat(entity, "fademindist", 800.0);
		DispatchKeyValueFloat(entity, "fademaxdist", 1000.0);
		DispatchKeyValueFloat(entity, "modelscale", PetResize[index]);
		DispatchKeyValue(entity, "DefaultAnim", PetAnimation[index][Anim_Idle]);
		
		DispatchSpawn(entity);
		
		//SetEntPropEnt(entity, Prop_Data, "m_hEffectEntity", client);
		//SDKHook(entity, SDKHook_SetTransmit, PetTransmit);
		
		HookSingleEntityOutput(entity, "OnAnimationDone", Pets_AnimationDone);
		
		PetRef[client] = EntIndexToEntRef(entity);
		
		static float pos[3], ang[3];
		GetClientAbsOrigin(client, pos);
		GetClientEyeAngles(client, ang);
		ang[0] = 0.0;
		TeleportEntity(entity, pos, ang, NULL_VECTOR);
	}
}

void Pets_ClientDisconnect(int client)
{
	if(PetRef[client] != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(PetRef[client]);
		if(entity != INVALID_ENT_REFERENCE)
			RemoveEntity(entity);
		
		PetRef[client] = INVALID_ENT_REFERENCE;
	}
}

public void Pets_AnimationDone(const char[] output, int caller, int activator, float delay)
{
	int ref = EntIndexToEntRef(caller);
	for(int i=1; i<=MaxClients; i++)
	{
		if(PetRef[i] == ref)
		{
			PlayingAnim[i] = false;
			return;
		}
	}
	
	RemoveEntity(caller);
}

void Pets_OnTaunt(int client)
{
	if(PetRef[client] != INVALID_ENT_REFERENCE && PetAnimation[PetEquipped[client]][Anim_Taunt][0] && !PlayingAnim[client])
	{
		SetPetAnimation(client, Anim_Taunt);
		PlayingAnim[client] = true;
	}
}

void Pets_PlayerRunCmdPost(int client, int buttons, const float angles[3])
{
	if(PetRef[client] != INVALID_ENT_REFERENCE)
	{
		if(!IsPlayerAlive(client))
		{
			Pets_ClientDisconnect(client);
			return;
		}
		
		int entity = EntRefToEntIndex(PetRef[client]);
		if(entity == INVALID_ENT_REFERENCE)
		{
			Pets_ClientDisconnect(client);
			return;
		}
		
		bool jumping;
		static bool holdJump[MAXPLAYERS];
		if(holdJump[client])
		{
			if(!(buttons & IN_JUMP))
				holdJump[client] = false;
		}
		else if(buttons & IN_JUMP)
		{
			holdJump[client] = true;
			jumping = true;
		}
		
		bool attacking;
		static bool holdAttack[MAXPLAYERS];
		if(holdAttack[client])
		{
			if(!(buttons & IN_ATTACK))
				holdAttack[client] = false;
		}
		else if(buttons & IN_ATTACK)
		{
			holdAttack[client] = true;
			attacking = true;
		}
		
		static float newPos[3];
		GetClientAbsOrigin(client, newPos);
		
		static float lastPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", lastPos);
		
		float dist = GetVectorDistance(lastPos, newPos, true);
		bool away = dist > 8000.0;
		if(away || newPos[2] != lastPos[2])
		{
			if(away)
			{
				float maxi = dist / 20.0;
				if(maxi < 400.0)
					maxi = 400.0;
				
				ConstrainDistance(lastPos, newPos, dist, maxi, away);
			}
			else
			{
				newPos[0] = lastPos[0];
				newPos[1] = lastPos[1];
			}
			
			float ang[3];
			ang[1] = angles[1];
			
			TeleportEntity(entity, newPos, ang, NULL_VECTOR);
		}
			
		SetWalkingAnimation(client, away, attacking, view_as<bool>(GetEntityFlags(client) & FL_DUCKING), jumping);
	}
}

static void SetWalkingAnimation(int client, bool walking, bool attacking, bool ducked, bool jumping)
{
	int defaul = Anim_MAX;
	if(walking)
	{
		if(ducked)
		{
			defaul = Anim_Walk;
		}
		else
		{
			defaul = Anim_Run;
		}
	}
	else if(ducked)
	{
		defaul = Anim_Duck;
	}
	else
	{
		defaul = Anim_Idle;
	}
	
	bool playing;
	
	int anim = Anim_MAX;
	if(!PlayingAnim[client])
	{
		if(attacking && PetAnimation[PetEquipped[client]][Anim_Attack][0])
		{
			anim = Anim_Attack;
			playing = true;
		}
		else if(jumping && PetAnimation[PetEquipped[client]][Anim_Jump][0])
		{
			anim = Anim_Jump;
			playing = true;
		}
		else if(defaul >= LastAnim[client] || TickAnim[client] < GetGameTickCount())
		{
			TickAnim[client] = GetGameTickCount() + 20;
			if(defaul != LastAnim[client])
				anim = defaul;
		}
		else
		{
			return;
		}
	}
	
	LastAnim[client] = defaul;
	SetPetAnimation(client, anim, defaul);
	if(playing)
		PlayingAnim[client] = playing;
}

static void SetPetAnimation(int client, int ne=Anim_MAX, int defaul=Anim_MAX)
{
	if(PetRef[client] != INVALID_ENT_REFERENCE)
	{
		int entity = EntRefToEntIndex(PetRef[client]);
		if(entity != INVALID_ENT_REFERENCE)
		{
			if(ne != Anim_MAX)
			{
				SetVariantString(PetAnimation[PetEquipped[client]][ne]);
				AcceptEntityInput(entity, "SetAnimation");
			}
			
			if(defaul != Anim_MAX)
			{
				SetVariantString(PetAnimation[PetEquipped[client]][defaul]);
				AcceptEntityInput(entity, "SetDefaultAnimation");
			}
		}
	}
}