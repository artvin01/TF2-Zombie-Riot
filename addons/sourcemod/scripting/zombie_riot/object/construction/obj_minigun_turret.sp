#pragma semicolon 1
#pragma newdecls required

static char g_ShootingSound[][] = {
	"weapons/csgo_awp_shoot.wav",
};

static int NPCId;
void Object_MinigunTurret_MapStart()
{
	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel("models/buildables/sentry2.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Minigun Turret");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_minigun_turret");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_minigun_turret");
	build.Cost = 600;
	build.Health = 50;
	build.Cooldown = 30.0;
	build.Func = ClotCanBuild;
	Building_Add(build);

	PrecacheSound("weapons/minigun_wind_down.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Object_MinigunTurret(client, vecPos, vecAng);
}

methodmap Object_MinigunTurret < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.7, 90);
	}
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayMinigunSound(bool Shooting) 
	{
		if(Shooting)
		{
			if(this.i_GunMode != 0)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
				EmitSoundToAll("weapons/minigun_shoot.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
				EmitSoundToAll("weapons/minigun_wind_down.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 1;
		}
	}
	public Object_MinigunTurret(int client, const float vecPos[3], const float vecAng[3])
	{
		Object_MinigunTurret npc = view_as<Object_MinigunTurret>(ObjectGeneric(client, vecPos, vecAng, "models/buildables/sentry2.mdl", "2.0", "50", {40.0, 40.0, 90.0},_,false));

		npc.m_bConstructBuilding = true;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCThink[npc.index] = Object_MinigunTurret_ClotThink;
		func_NPCDeath[npc.index] = Object_MinigunTurret_Death;
		SetRotateByDefaultReturn(npc.index, -180.0);
		SDKUnhook(npc.index, SDKHook_ThinkPost, ObjBaseThinkPost);
		SDKHook(npc.index, SDKHook_ThinkPost, ObjBaseThinkPostSentry);
		npc.PlayMinigunSound(false);

		return npc;
	}
}

void Object_MinigunTurret_Death(int entity)
{
	Object_MinigunTurret npc = view_as<Object_MinigunTurret>(entity);
	npc.PlayMinigunSound(false);
}
void Object_MinigunTurret_ClotThink(Object_MinigunTurret npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		Owner = npc.index;
	}

	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + 0.05;
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		float DistanceLimit = 800.0;

		npc.m_iTarget = GetClosestTarget(npc.index,_,DistanceLimit,.CanSee = true, .UseVectorDistance = true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.AddActivityViaSequence("idle_off");
		npc.PlayMinigunSound(false);
		//longer think so it doesnt lag.
		npc.m_flNextDelayTime = gameTime + 0.5;
		return;
	}
	if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.AddActivityViaSequence("idle_off");
		npc.PlayMinigunSound(false);
		return;
	}
//	if(npc.m_flNextMeleeAttack > gameTime)
//	{
//		return;
//	}

	Handle swingTrace;
	int target;
	Sentrygun_FaceEnemy(npc.index, npc.m_iTarget);

	static float rocketAngle[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", rocketAngle);

	if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }))
	{
		target = TR_GetEntityIndex(swingTrace);	
			
	//	npc.AddActivityViaSequence("fire");
		npc.AddActivityViaSequence("idle_off");
		float vecHit[3];
		TR_GetEndPosition(vecHit, swingTrace);
		float origin[3];
		float angles[3];
		if(npc.Anger)
		{
			view_as<CClotBody>(npc.index).GetAttachment("muzzle_l", origin, angles);
			npc.Anger = false;
		}
		else
		{
			view_as<CClotBody>(npc.index).GetAttachment("muzzle_r", origin, angles);
			npc.Anger = true;
		}
		ShootLaser(npc.index, "bullet_tracer02_red", origin, vecHit, false );
	//	npc.m_flNextMeleeAttack = gameTime + 0.05;
		npc.PlayMinigunSound(true);
		if(IsValidEnemy(npc.index, target))
		{
			float damageDealt = 1000.0;
			if(Construction_HasNamedResearch("Base Level III"))
				damageDealt *= 3.0;
			if(Construction_GetRisk() >= 6)
				damageDealt *= 2.0;

			if(ShouldNpcDealBonusDamage(target))
				damageDealt *= 3.0;
				
			SDKHooks_TakeDamage(target, npc.index, Owner, damageDealt, DMG_BULLET, -1, _, vecHit);
		}
	}
	delete swingTrace;
}


static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		
		if(!CvarInfiniteCash.BoolValue && !Construction_HasNamedResearch("Minigun Turret"))
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
