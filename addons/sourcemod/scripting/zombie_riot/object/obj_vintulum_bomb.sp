#pragma semicolon 1
#pragma newdecls required


static char g_ActivationSound[][] = {
	"ambient/alarms/doomsday_lift_alarm.wav",
};
static char g_ExplosionRightBefore[][] = {
	"weapons/cow_mangler_over_charge_shot.wav",
};
static char g_ExplosionSound[][] = {
	"weapons/bombinomicon_explode1.wav",
};
static char g_ExplosionSound2[][] = {
	"mvm/giant_soldier/giant_soldier_explode.wav",
};
static char g_ExplosionAfter[][] = {
	"ambient_mp3/hell/hell_rumbles_06.mp3",
};
static int NPCId;
void ObjectVintulumBomb_MapStart()
{
	PrecacheSoundArray(g_ActivationSound);
	PrecacheSoundArray(g_ExplosionSound);
	PrecacheSoundArray(g_ExplosionSound2);
	PrecacheSoundArray(g_ExplosionAfter);
	PrecacheSoundArray(g_ExplosionRightBefore);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vuntulum Bomb");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_vintulum_bomb");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_vintulum_bomb");
	build.Cost = 2000;
	build.Health = 60;
	build.Cooldown = 120.0;
	build.Func = ObjectGeneric_CanBuildBomb;
	Building_Add(build);
}

int BombIdVintulum()
{
	return NPCId;
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectVintulumBomb(client, vecPos, vecAng);
}

methodmap ObjectVintulumBomb < ObjectGeneric
{
	public void PlayActivateSound() 
	{
		EmitSoundToAll(g_ActivationSound[GetRandomInt(0, sizeof(g_ActivationSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	
		float pos[3];
		WorldSpaceCenter(this.index, pos);
		this.m_iWearable3 = ParticleEffectAt_Parent(pos, "spell_fireball_small_trail_red",this.index, "");
	}
	public void PlayBeforeExplode() 
	{
		EmitSoundToAll(g_ExplosionRightBefore[GetRandomInt(0, sizeof(g_ExplosionRightBefore) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	}
	public void PlayExplodeDo(bool alreadydead) 
	{
		EmitSoundToAll(g_ExplosionSound[GetRandomInt(0, sizeof(g_ExplosionSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 1.0, 100);
		EmitSoundToAll(g_ExplosionSound[GetRandomInt(0, sizeof(g_ExplosionSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 1.0, 100);
		EmitSoundToAll(g_ExplosionSound2[GetRandomInt(0, sizeof(g_ExplosionSound2) - 1)], this.index, SNDCHAN_AUTO, 80, _, 1.0, 80);
		EmitSoundToAll(g_ExplosionAfter[GetRandomInt(0, sizeof(g_ExplosionAfter) - 1)], this.index, SNDCHAN_AUTO, 80, _, 1.0, 100);

		float ExplosionRadius = 600.0;
		float pos[3];
		WorldSpaceCenter(this.index, pos);
		CreateEarthquake(pos, 3.0, ExplosionRadius * 2.0, 35.0, 255.0);
		TE_Particle("hightower_explosion", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		
		int Owner = GetEntPropEnt(this.index, Prop_Send, "m_hOwnerEntity");
		if(!IsValidClient(Owner))
		{
			return;
		}
		float damage = 10.0;			
		damage *= 30.0;
		float attack_speed;
		float sentry_range;
		attack_speed = 1.0 / Attributes_GetOnPlayer(Owner, 343, true, true); //Sentry attack speed bonus
		damage = attack_speed * damage * Attributes_GetOnPlayer(Owner, 287, true, true);			//Sentry damage bonus
		sentry_range = Attributes_GetOnPlayer(Owner, 344, true, true);			//Sentry Range bonus
		float AOE_range = 350.0 * sentry_range;

		damage *= 5.0;
		//its like 5 mortars at once.
		Explode_Logic_Custom(damage, Owner, Owner, -1, pos, AOE_range, 0.75, _, false);
		ExpidonsaGroupHeal(Owner, AOE_range, 99, 1.0, 1.0, true, VintulumBombSelf, .LOS = true, .VecDoAt = pos);
		
		int entity = CreateEntityByName("light_dynamic");
		if(entity != -1)
		{
			TeleportEntity(entity, pos, {0.0,0.0,0.0}, NULL_VECTOR);
			
			DispatchKeyValue(entity, "brightness", "8");
			DispatchKeyValue(entity, "spotlight_radius", "1000");
			DispatchKeyValue(entity, "distance", "1000");
			DispatchKeyValue(entity, "_light", "255 255 0 255");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "LightOn");
			b_EntityCantBeColoured[entity] = true;
			CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.1, Timer_ReduceLighting, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if(!alreadydead)
			DestroyBuildingDo(this.index);
		
	}
	property float m_flBombExplodeTill
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property int m_PointAt
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	public ObjectVintulumBomb(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectVintulumBomb npc = view_as<ObjectVintulumBomb>(ObjectGeneric(client, vecPos, vecAng, "models/props_td/atom_bomb.mdl", "0.85","50", {20.0, 20.0, 32.0},_,false));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildBomb;

		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;
		func_NPCDeath[npc.index] = ClotDeath;

		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		return npc;
	}
}

static void ClotThink(ObjectVintulumBomb npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(Owner))
	{
		return;
	}
	if(!npc.m_flBombExplodeTill)
		return;
	float gameTime = GetGameTime(npc.index);

	float TimeLeft = npc.m_flBombExplodeTill - gameTime;
	switch(npc.m_PointAt)
	{
		case 1:
		{
			if(TimeLeft <= 1.0)
			{
				npc.m_PointAt = 2;
				npc.PlayBeforeExplode();
			}
		}
		case 2:
		{
			if(TimeLeft <= 0.0)
			{
				npc.m_PointAt = 3;
				npc.PlayExplodeDo(false);
			}
		}
	}
}


static bool ClotInteract(int client, int weapon, ObjectVintulumBomb npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(Owner != client)
		return false;
		
	if(f_BuildingIsNotReady[client] > GetGameTime())
		return false;
	
	if(f_MedicCallIngore[client] < GetGameTime())
		return false;

	if(npc.m_flBombExplodeTill)
		return false;

		
			   
	float spawnLoc[3];
	float eyePos[3];
	GetEntPropVector(Owner, Prop_Data, "m_vecAbsOrigin", eyePos);
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", spawnLoc);
	if (GetVectorDistance(eyePos, spawnLoc, true) >= (70.0 * 70.0))
	{
		if(EntRefToEntIndex(Building_Mounted[Owner]) != npc.index) 
		{
			//if its the same, just allow
			
			SetDefaultHudPosition(Owner);
			ShowSyncHudText(Owner,  SyncHud_Notifaction, "%T", "Too Far Away", Owner);
			return false;
		}
	}
	float CooldownGive = 120.0;
	if(Rogue_Mode())
		CooldownGive *= 0.5;
	SPrintToChat(Owner, "%T", "Global Cooldown Bomb", Owner, CooldownGive);
	f_VintulumBombRecentlyUsed[Owner] = GetGameTime() + CooldownGive;
	ApplyStatusEffect(Owner, Owner, "Vuntulum Bomb EMP", CooldownGive);
	npc.m_PointAt = 1;
	npc.m_flBombExplodeTill = GetGameTime() + 5.0;
	npc.PlayActivateSound();
	return true;
}


static void ClotDeath(int entity)
{
	ObjectVintulumBomb npc = view_as<ObjectVintulumBomb>(entity);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(!npc.m_flBombExplodeTill || npc.m_PointAt == 3)
		return;

	npc.PlayExplodeDo(true);
}



public Action Timer_ReduceLighting(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		float brightness = GetEntPropFloat(entity, Prop_Send, "m_Radius");
		brightness -= 50.0;
		if(brightness <= 0.0)
			brightness = 0.0;
		SetEntPropFloat(entity, Prop_Send, "m_Radius", brightness);
		SetEntPropFloat(entity, Prop_Send, "m_SpotRadius", brightness);
		return Plugin_Continue;
	}
	else
		return Plugin_Stop;
}


bool VintulumBombSelf(int entity, int victim, float &healingammount)
{
	if(entity != victim)
		return false;
	healingammount = 0.0;
	ApplyStatusEffect(victim, victim, "Nightmare Terror", 0.1);
	HealEntityGlobal(victim, victim, -9999999.9, _, _, HEAL_ABSOLUTE);
	if(!IsEntityAlive(victim))
		ApplyStatusEffect(victim, victim, "Vuntulum Bomb EMP Death", 99999.9);
	return false;
}



public bool ObjectGeneric_CanBuildBomb(int client, int &count, int &maxcount)
{
	if(!client)
		return false;

	if(ObjectBombs_Buildings() >= 3)
	{
		return false;
	}

	return ObjectGeneric_CanBuildSentry(client, count, maxcount);
}


int ObjectBombs_Buildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(BombIdVintulum() == i_NpcInternalId[entity])
			count++;
	}

	return count;
}