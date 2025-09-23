#pragma semicolon 1
#pragma newdecls required

#define MORTAR_SHOT	"weapons/mortar/mortar_fire1.wav"
#define MORTAR_BOOM	"beams/beamstart5.wav"

#define MORTAR_SHOT_INCOMMING	"weapons/mortar/mortar_shell_incomming1.wav"

#define MORTAR_RELOAD	"vehicles/tank_readyfire1.wav"

static const char g_ShootingSound[] = "weapons/sentry_shoot_mini.wav";

void ObjectMortar_MapStart()
{
	PrecacheSound(g_ShootingSound);
	PrecacheModel("models/zombie_riot/buildings/mortar_2.mdl");
	PrecacheSound(MORTAR_SHOT);
	PrecacheSound(MORTAR_BOOM);
	PrecacheSound(MORTAR_SHOT_INCOMMING);
	PrecacheSound(MORTAR_RELOAD);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mortar");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_mortar");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_mortar");
	build.Cost = 600;
	build.Health = 30;
	build.Cooldown = 30.0;
	build.Func = ObjectGeneric_CanBuildSentry;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectMortar(client, vecPos, vecAng);
}

methodmap ObjectMortar < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound, this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	}
	public ObjectMortar(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectMortar npc = view_as<ObjectMortar>(ObjectGeneric(client, vecPos, vecAng, "models/zombie_riot/buildings/mortar_2.mdl", "0.7","50", {15.0, 15.0, 100.0},_,false));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildSentry;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;
		npc.SetActivity("MORTAR_IDLE");

		SetRotateByDefaultReturn(npc.index, 180.0);
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		return npc;
	}
}

static void ClotThink(ObjectMortar npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(Owner))
	{
		return;
	}
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime - 10.0)
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_iChanged_WalkCycle = 1;
				float pos_obj[3];
				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos_obj);
				pos_obj[2] += 100.0;
				npc.SetActivity("MORTAR_RELOAD");		
				EmitSoundToAll(MORTAR_RELOAD, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, pos_obj);
				EmitSoundToAll(MORTAR_RELOAD, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, pos_obj);	
			}
		}
		else if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			npc.SetActivity("MORTAR_IDLE");
		}
	}
}


static bool ClotInteract(int client, int weapon, ObjectHealingStation npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(Owner != client)
		return false;
		
	if(f_BuildingIsNotReady[client] > GetGameTime())
		return false;
	
	if(f_MedicCallIngore[client] < GetGameTime())
		return false;

	BuildingMortarAction(client, npc.index);
	return true;
}

//todo: When pressing E, Actives All Building stuff
public void BuildingMortarAction(int client, int mortar)
{
	float spawnLoc[3];
	float eyePos[3];
	float eyeAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	FinishLagCompensation_Base_boss();
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(spawnLoc, trace);
	} 
	int color[4];
	color[0] = 255;
	color[1] = 255;
	color[2] = 0;
	color[3] = 255;
									
	if (GetTeam(client) == TFTeam_Blue)
	{
		color[2] = 255;
		color[0] = 0;
	}
	GetAttachment(client, "effect_hand_R", eyePos, eyeAng);
	int SPRITE_INT = PrecacheModel("materials/sprites/laserbeam.vmt", false);
	float amp = 0.2;
	float life = 0.1;
	TE_SetupBeamPoints(eyePos, spawnLoc, SPRITE_INT, 0, 0, 0, life, 2.0, 2.2, 1, amp, color, 0);
	TE_SendToAll();
								
	delete trace;
	EmitSoundToAll("weapons/drg_wrench_teleport.wav", client, SNDCHAN_AUTO, 70);
	static float pos[3];
	
	DataPack pack;
	CreateDataTimer(1.0, MortarFire_Anims, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(mortar));
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteFloat(spawnLoc[0]);
	pack.WriteFloat(spawnLoc[1]);
	pack.WriteFloat(spawnLoc[2]);
	float position[3];
	position[0] = spawnLoc[0];
	position[1] = spawnLoc[1];
	position[2] = spawnLoc[2];
				
	position[2] += 3000.0;

	int particle = ParticleEffectAt(position, "kartimpacttrail", 2.0);
	SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));
	float pos_obj[3];
	ParticleEffectAt(pos, "utaunt_portalswirl_purple_warp2", 2.0);
	CreateTimer(1.7, MortarFire_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);	
	GetEntPropVector(mortar, Prop_Send, "m_vecOrigin", pos_obj);
	pos_obj[2] += 100.0;
	CClotBody npcstats = view_as<CClotBody>(mortar);
	npcstats.m_flAttackHappens = GetGameTime() + 10.0;
	f_BuildingIsNotReady[client] = GetGameTime() + 10.0;
	ParticleEffectAt(pos_obj, "skull_island_embers", 2.0);
}

public Action MortarFire_Falling_Shot(Handle timer, int ref)
{
	int particle = EntRefToEntIndex(ref);
	if(particle>MaxClients && IsValidEntity(particle))
	{
		float position[3];
		GetEntPropVector(particle, Prop_Send, "m_vecOrigin", position);
		position[2] -= 3700;
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
	}
	return Plugin_Handled;
}

public Action MortarFire_Anims(Handle timer, DataPack pack)
{
	pack.Reset();
	int Building = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	float ParticlePos[3];
	ParticlePos[0] = pack.ReadFloat();
	ParticlePos[1] = pack.ReadFloat();
	ParticlePos[2] = pack.ReadFloat();

	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		if(IsValidEntity(Building))
		{
			EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, ParticlePos);
			EmitSoundToAll(MORTAR_SHOT_INCOMMING, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, ParticlePos);
		//	SetColorRGBA(glowColor, r, g, b, alpha);
			ParticleEffectAt(ParticlePos, "taunt_flip_land_ring", 1.0);
			DataPack pack2;
			CreateDataTimer(1.0, MortarFire, pack2, TIMER_FLAG_NO_MAPCHANGE);
			pack2.WriteCell(EntIndexToEntRef(Building));
			pack2.WriteCell(EntIndexToEntRef(client));
			pack2.WriteFloat(ParticlePos[0]);
			pack2.WriteFloat(ParticlePos[1]);
			pack2.WriteFloat(ParticlePos[2]);
		}	
	}	
	return Plugin_Handled;
}
public Action MortarFire(Handle timer, DataPack pack)
{
	pack.Reset();
	int Building = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	float ParticlePos[3];
	ParticlePos[0] = pack.ReadFloat();
	ParticlePos[1] = pack.ReadFloat();
	ParticlePos[2] = pack.ReadFloat();
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		if(IsValidEntity(Building))
		{
			float damage = 10.0;
							
			damage *= 30.0;
			
			float attack_speed;
			float sentry_range;

			attack_speed = 1.0 / Attributes_GetOnPlayer(client, 343, true, true); //Sentry attack speed bonus
				
			damage = attack_speed * damage * Attributes_GetOnPlayer(client, 287, true, true);			//Sentry damage bonus
			
			sentry_range = Attributes_GetOnPlayer(client, 344, true, true);			//Sentry Range bonus
			
			float AOE_range = 350.0 * sentry_range;

			Explode_Logic_Custom(damage, client, client, -1, ParticlePos, AOE_range, 0.75, _, false);
			
			CreateEarthquake(ParticlePos, 0.5, 350.0, 16.0, 255.0);
			EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, ParticlePos);
			EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, ParticlePos);
			ParticleEffectAt(ParticlePos, "rd_robot_explosion", 1.0);
		}
	}
	return Plugin_Handled;
}
