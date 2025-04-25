#pragma semicolon 1
#pragma newdecls required

static const char g_ShootingSound[] =
	"weapons/sniper_rifle_classic_shoot.wav";

static int NPCId;

void ObjectStunGun_MapStart()
{
	PrecacheSound(g_ShootingSound);
	PrecacheModel("models/combine_turrets/floor_turret.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Tranquilizer Turret");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_stungun");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_stungun");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectStunGun(client, vecPos, vecAng);
}

methodmap ObjectStunGun < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound, this.index, SNDCHAN_AUTO, 80, _, 0.7, 90);
	}
	public ObjectStunGun(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectStunGun npc = view_as<ObjectStunGun>(ObjectGeneric(client, vecPos, vecAng, "models/combine_turrets/floor_turret.mdl", "1.0", "50", {23.0, 23.0, 61.0}, _, false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = ClotThink;
		SetRotateByDefaultReturn(npc.index, -180.0);

		return npc;
	}
}

static void ClotThink(ObjectStunGun npc)
{
	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		float DistanceLimit = 1000.0;
		npc.m_iTarget = GetClosestTarget(npc.index, _, DistanceLimit, .CanSee = true, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget) || view_as<CClotBody>(npc.m_iTarget).m_flNextDelayTime > (GetGameTime(npc.m_iTarget) + DEFAULT_UPDATE_DELAY_FLOAT))
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

	Sentrygun_FaceEnemy(npc.index, npc.m_iTarget);

	if(npc.m_flNextMeleeAttack > gameTime)
		return;

	Handle swingTrace;
	if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }))
	{
		int target = TR_GetEntityIndex(swingTrace);	
			
		float vecHit[3];
		TR_GetEndPosition(vecHit, swingTrace);
		float origin[3];
		float angles[3];
		view_as<CClotBody>(npc.index).GetAttachment("light", origin, angles);
		ShootLaser(npc.index, "bullet_tracer02_red_crit", origin, vecHit, false );
		npc.m_flNextMeleeAttack = gameTime + 5.0;
		npc.PlayShootSound();
		if(IsValidEnemy(npc.index, target))
		{
			if(b_thisNpcIsARaid[target])
				FreezeNpcInTime(target, 0.4);
			else
				FreezeNpcInTime(target, 2.0);
		}
	}

	delete swingTrace;
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Tranquilizer Turret"))
		{
			maxcount = 0;
			return false;
		}

		maxcount = 1;

		if(Construction_HasNamedResearch("Base Level II"))
			maxcount++;

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
