#pragma semicolon 1
#pragma newdecls required

#define LEPER_NORMAL_HIT	"weapons/halloween_boss/knight_axe_hit.wav"
#define LEPER_AOE_SWING_HIT	"ambient/rottenburg/barrier_smash.wav"

#define LEPER_NORMAL_SWING 0
#define LEPER_AOE_HEW 1
int LeperSwingType[MAXPLAYERS+1];
bool LeperSwingEffect[MAXPLAYERS+1];

void OnMapStartLeper()
{
	PrecacheSound(LEPER_NORMAL_HIT);
	PrecacheSound(LEPER_AOE_SWING_HIT);
	Zero(LeperSwingEffect);
	Zero(LeperSwingType);
}

int LeperEnemyAoeHit(int client, int weapon)
{
	switch(LeperSwingType[client])
	{
		case LEPER_NORMAL_SWING:
			return 1;

		case LEPER_AOE_HEW:
			return 5;
	}
	return 1;
}

void PlayCustomSoundLeper(int client, int victim)
{
	switch(LeperSwingType[client])
	{
		case LEPER_NORMAL_SWING:
		{
			int pitch = GetRandomInt(95,100);
			EmitSoundToAll(LEPER_NORMAL_HIT, client, SNDCHAN_AUTO, 75,_,0.8,pitch);			
		}
		case LEPER_AOE_HEW:
		{
			FreezeNpcInTime(victim, 0.5);
			Custom_Knockback(client, victim, 750.0, true, true, true);
			LeperOnSuperHitEffect(client);		
		}
	}
}

public void Weapon_LeperHewCharge(int client, int weapon, bool &result, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		LeperSwingType[client] = 1;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);	
	}
}

//Freeze in place and cause effect.
void LeperOnSuperHitEffect(int client)
{
	if(LeperSwingEffect[client])
		return;
	LeperSwingEffect[client] = true;

	int CameraDelete = SetCameraEffectLeper(client);
	DataPack pack;
	CreateDataTimer(0.8, Leper_SuperHitInitital_After, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(client);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(CameraDelete));


	TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
}

public Action Leper_SuperHitInitital_After(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientindex = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int camreadelete = EntRefToEntIndex(pack.ReadCell());
	LeperSwingEffect[clientindex] = false;

	if(camreadelete != -1)
		RemoveEntity(camreadelete);

	if(!client)
		return Plugin_Stop;

	SetClientViewEntity(client, client);
	TF2_RemoveCondition(client, TFCond_FreezeInput);
	SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 1);
	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 1);
	SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 1);
	SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 1);
	SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 0);	
	SetEntityMoveType(client, MOVETYPE_WALK);
	return Plugin_Stop;
}

#define LEPER_BOUNDS_VIEW_EFFECT 25.0
#define LEPER_MAXRANGE_VIEW_EFFECT 350.0

int SetCameraEffectLeper(int client)
{
	int pitch = GetRandomInt(95,100);
	EmitSoundToAll(LEPER_AOE_SWING_HIT, client, SNDCHAN_AUTO, 75,_,0.8,pitch);		
	for(int clientloop=1; clientloop<=MaxClients; clientloop++)
	{
		if(clientloop != client && !b_IsPlayerABot[clientloop] && IsClientInGame(clientloop))
		{
			EmitSoundToClient(client, LEPER_AOE_SWING_HIT, clientloop, SNDCHAN_AUTO, 0,_,0.8,pitch);	
		}
	}
	ClientCommand(client,"playgamesound ambient/rottenburg/barrier_smash.wav");
//	EmitSoundToClient(client, LEPER_AOE_SWING_HIT, SOUND_FROM_WORLD, SNDCHAN_AUTO, 999,_,0.8,pitch);	
	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	TE_Particle("crate_drop_dust", vOrigin, NULL_VECTOR, vAngles, -1, _, _, _, _, _, _, _, _, _, 0.0);

	//always from upwards somewhere.
	vAngles[0] = GetRandomFloat(-30.0 , -25.0);
	vAngles[1] += GetRandomFloat(-30.0 , 30.0);

	float LeperViewAnglesMins[3];
	float LeperViewAnglesMaxs[3];
	LeperViewAnglesMins = view_as<float>({-LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT, -LEPER_BOUNDS_VIEW_EFFECT});
	LeperViewAnglesMaxs = view_as<float>({LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT, LEPER_BOUNDS_VIEW_EFFECT});

	float vecSwingForward[3];
	GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);

	float vecSwingEnd[3];
	vecSwingEnd[0] = vOrigin[0] + vecSwingForward[0] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[1] = vOrigin[1] + vecSwingForward[1] * LEPER_MAXRANGE_VIEW_EFFECT;
	vecSwingEnd[2] = vOrigin[2] + vecSwingForward[2] * LEPER_MAXRANGE_VIEW_EFFECT;
	Handle trace = TR_TraceHullFilterEx( vOrigin, vecSwingEnd, LeperViewAnglesMins, LeperViewAnglesMaxs, ( MASK_SOLID ), TraceRayHitWorldOnly, client );
	if ( TR_GetFraction(trace) < 1.0)
	{
		//we hit nothing something, uh oh!
		TR_GetEndPosition(vecSwingEnd, trace);
	}
	int viewcontrol = CreateEntityByName("prop_dynamic");
	float vAngleCamera[3];
	if (IsValidEntity(viewcontrol))
	{
		GetVectorAnglesTwoPoints(vecSwingEnd, vOrigin, vAngleCamera);
		SetEntityModel(viewcontrol, "models/empty.mdl");
		DispatchKeyValueVector(viewcontrol, "origin", vecSwingEnd);
		DispatchKeyValueVector(viewcontrol, "angles", vAngleCamera);
		DispatchSpawn(viewcontrol);	
		SetClientViewEntity(client, viewcontrol);
	}
	float vabsAngles[3];
	float vabsOrigin[3];
	GetClientAbsOrigin(client, vabsOrigin);
	GetClientAbsAngles(client, vabsAngles);
	vabsAngles[0] = 0.0;

	int spawn_index = Npc_Create(WEAPON_LEPER_AFTERIMAGE, client, vabsOrigin, vabsAngles, GetEntProp(client, Prop_Send, "m_iTeamNum") == 2);
	if(spawn_index > 0)
	{

	}
	return viewcontrol;
}