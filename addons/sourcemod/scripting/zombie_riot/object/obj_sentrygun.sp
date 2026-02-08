#pragma semicolon 1
#pragma newdecls required

static char g_ShootingSound[][] = {
	"weapons/sentry_shoot_mini.wav",
};

void ObjectSentrygun_MapStart()
{
	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel("models/buildables/sentry1.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sentrygun");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_sentrygun");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_sentrygun");
	build.Cost = 600;
	build.Health = 30;
	build.Cooldown = 30.0;
	build.Func = ObjectGeneric_CanBuildSentry;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectSentrygun(client, vecPos, vecAng);
}

methodmap ObjectSentrygun < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	}
	public ObjectSentrygun(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectSentrygun npc = view_as<ObjectSentrygun>(ObjectGeneric(client, vecPos, vecAng, "models/buildables/sentry1.mdl", "0.75","50", {15.0, 15.0, 34.0},_,false));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildSentry;
		func_NPCThink[npc.index] = ObjectSentrygun_ClotThink;
		SetRotateByDefaultReturn(npc.index, 180.0);
		SDKUnhook(npc.index, SDKHook_ThinkPost, ObjBaseThinkPost);
		SDKHook(npc.index, SDKHook_ThinkPost, ObjBaseThinkPostSentry);
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		return npc;
	}
}

bool IsEntitySentrygun(int sentry)
{
	return func_NPCThink[sentry] == ObjectSentrygun_ClotThink;
}
//think every tick.
public void ObjBaseThinkPostSentry(int building)
{
	CBaseCombatCharacter(building).SetNextThink(GetGameTime());
}

void ObjectSentrygun_ClotThink(ObjectSentrygun npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		return;
	}

	float gameTime = GetGameTime(npc.index);
	float ReduceTime = Owner > MaxClients ? (view_as<Citizen>(Owner).m_fGunFirerate * 4.0) : Attributes_GetOnPlayer(Owner, 343, true, true);
	npc.m_flNextDelayTime = gameTime + (0.1 * ReduceTime);
//	CBaseCombatCharacter(npc.index).SetNextThink(GetGameTime() + (0.1 * ReduceTime)); //this needs to be set, otherwise it doesnt think fast enough to shoot
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		float DistanceLimit = 1000.0;
		if(Owner > MaxClients)
		{
			DistanceLimit *= view_as<Citizen>(Owner).m_fGunRangeBonus;
		}
		else
		{
			DistanceLimit *= Attributes_GetOnPlayer(Owner, 344, true, true);
		}
		
		npc.m_iTarget = GetClosestTarget(npc.index,_,DistanceLimit,.CanSee = true, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	if(npc.m_flNextMeleeAttack > gameTime)
	{
		return;
	}

	Handle swingTrace;
	int target;
	Sentrygun_FaceEnemy(npc.index, npc.m_iTarget);
	if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }))
	{
		target = TR_GetEntityIndex(swingTrace);	
			
		float vecHit[3];
		TR_GetEndPosition(vecHit, swingTrace);
		float origin[3];
		float angles[3];
		view_as<CClotBody>(npc.index).GetAttachment("muzzle", origin, angles);
		ShootLaser(npc.index, "bullet_tracer01_red", origin, vecHit, false );
		npc.m_flNextMeleeAttack = gameTime + (0.25 * ReduceTime);
	//	npc.AddGesture("ACT_RANGE_ATTACK1", false);
		npc.PlayShootSound();
		if(IsValidEnemy(npc.index, target))
		{
			float damageDealt = 10.0;
			if(Owner <= MaxClients)
			{
				damageDealt *= Attributes_GetOnPlayer(Owner, 287, true, true);
			}
			else
			{
				damageDealt = view_as<Citizen>(Owner).GetDamage();
			}

			if(ShouldNpcDealBonusDamage(target))
				damageDealt *= 3.0;
				
			SDKHooks_TakeDamage(target, npc.index, Owner, damageDealt, DMG_BULLET, -1, _, vecHit);
		}
	}
	delete swingTrace;
}

void Sentrygun_FaceEnemy(int sentry, int Target, int turnthis = 0)
{
	static float rocketAngle[3];
	GetEntPropVector(sentry, Prop_Data, "m_angRotation", rocketAngle);

	static float tmpAngles[3];
	static float rocketOrigin[3];
	GetEntPropVector(sentry, Prop_Data, "m_vecAbsOrigin", rocketOrigin);

	float pos1[3];
	WorldSpaceCenter(Target, pos1);
	GetRayAngles(rocketOrigin, pos1, tmpAngles);
	
	// Thanks to mikusch for pointing out this function to use instead
	// we had a simular function but i forgot that it existed before
	// https://github.com/Mikusch/ChaosModTF2/pull/4/files
	rocketAngle[0] = 0.0;
	rocketAngle[1] = ApproachAngle(tmpAngles[1], rocketAngle[1], 500.0);

	if(turnthis)
		TeleportEntity(turnthis, NULL_VECTOR, rocketAngle, NULL_VECTOR);
	else
		TeleportEntity(sentry, NULL_VECTOR, rocketAngle, NULL_VECTOR);
}
