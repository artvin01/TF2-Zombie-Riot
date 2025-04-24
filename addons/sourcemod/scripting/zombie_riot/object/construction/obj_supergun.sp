#pragma semicolon 1
#pragma newdecls required

static char g_ShootingSound[][] = {
	"weapons/csgo_awp_shoot.wav",
};

static int NPCId;
void ObjectHeavyCaliberTurret_MapStart()
{
	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel("models/buildables/sentry1_heavy.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Heavy Calliber");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_heavycalliber");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_heavycalliber");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectHeavyCaliberTurret(client, vecPos, vecAng);
}

methodmap ObjectHeavyCaliberTurret < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.7, 90);
	}
	public ObjectHeavyCaliberTurret(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectHeavyCaliberTurret npc = view_as<ObjectHeavyCaliberTurret>(ObjectGeneric(client, vecPos, vecAng, "models/buildables/sentry1_heavy.mdl", "2.0", "50", {40.0, 40.0, 90.0},_,false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ObjectHeavyCaliberTurret_ClotThink;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

void ObjectHeavyCaliberTurret_ClotThink(ObjectHeavyCaliberTurret npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		Owner = npc.index;
	}

	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.1;
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		float DistanceLimit = 1500.0;

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

	static float rocketAngle[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", rocketAngle);

	if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }))
	{
		target = TR_GetEntityIndex(swingTrace);	
			
		float vecHit[3];
		TR_GetEndPosition(vecHit, swingTrace);
		float origin[3];
		float angles[3];
		view_as<CClotBody>(npc.index).GetAttachment("muzzle", origin, angles);
		ShootLaser(npc.index, "bullet_tracer02_red_crit", origin, vecHit, false );
		npc.m_flNextMeleeAttack = gameTime + 0.5;
	//	npc.AddGesture("ACT_RANGE_ATTACK1", false);
		npc.PlayShootSound();
		if(IsValidEnemy(npc.index, target))
		{
			float damageDealt = 5000.0;
			if(Construction_HasNamedResearch("Base Level III"))
				damageDealt *= 3.0;
			if(Construction_GetRisk() >= 6)
				damageDealt *= 2.0;
		//	damageDealt = view_as<Citizen>(Owner).GetDamage();

			if(ShouldNpcDealBonusDamage(target))
				damageDealt *= 3.0;
				
			SDKHooks_TakeDamage(target, npc.index, Owner, damageDealt, DMG_BULLET, -1, _, vecHit);
		}
	}
//	rocketAngle[1] -= 90.0;
//	TeleportEntity(npc.index, NULL_VECTOR, rocketAngle, NULL_VECTOR);
	delete swingTrace;
}


static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Heavy Calliber"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 1;

		if(Construction_HasNamedResearch("Base Level III"))
			maxcount++;
		
		if(count >= maxcount)
			return false;
	}
	
	return true;
}


static int CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(NPCId == i_NpcInternalId[entity])
			count++;
	}

	return count;
}
