static Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
static int i_TransformInitLevel[MAXPLAYERS+1];
static int iref_Halo[MAXPLAYERS+1][3];
static bool Expidonsa_InRageMode[MAXPLAYERS+1];

static const char MissSound[][] =
{
	"weapons/fx/nearmiss/bulletltor08.wav",
	"weapons/fx/nearmiss/bulletltor09.wav",
	"weapons/fx/nearmiss/bulletltor10.wav",
	"weapons/fx/nearmiss/bulletltor11.wav",
	"weapons/fx/nearmiss/bulletltor13.wav",
	"weapons/fx/nearmiss/bulletltor14.wav",
};
void Transform_Iberian_MapStart()
{
	PrecacheSoundArray(MissSound);
	PrecacheSound("player/taunt_yeti_appear_snow.wav");
	PrecacheSound("replay/enterperformancemode.wav");
	PrecacheSound("items/powerup_pickup_precision.wav");
	PrecacheSound("weapons/bumper_car_speed_boost_stop.wav");
}


public void Iberian_Activation_Enable_form_1(int client)
{
	Iberian_Activation_Enable_Global(client, 1);
}

public void Iberian_Activation_Enable_form_2(int client)
{
	Iberian_Activation_Enable_Global(client, 2);
}
public void Iberian_Activation_Enable_form_3(int client)
{
	Iberian_Activation_Enable_Global(client, 3);
}
public void Iberian_Activation_Enable_form_4(int client)
{
	Iberian_Activation_Enable_Global(client, 4);
}

public void Iberian_Activation_Deactivate_form_4(int client)
{
	Expidonsa_InRageMode[client] = false;
}
public void Iberian_4thFormNameSpecial(int client, char name[256])
{
	if(Expidonsa_InRageMode[client])
	{
		strcopy(name, sizeof(name), "Perfected Instinct");
	}
}
public void Iberian_TakeDamage4th(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(Expidonsa_InRageMode[victim])
	{
		float HitChance = 0.8;
		int MaxHealth = ReturnEntityMaxHealth(victim);
		int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
		Health *= 1.3;

		HitChance *=float(Health) / float(MaxHealth);

		if(HitChance <= 0.3)
			HitChance = 0.3;

		if(HitChance >= 0.8)
			HitChance = 0.8;

		if(GetRandomFloat(0.0, 1.0) < HitChance)
			return;

		float chargerPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		chargerPos[2] += 90.0;
		TE_ParticleInt(g_particleMissText, chargerPos);
		TE_SendToAll();
		int Rand = GetRandomInt(0, sizeof(MissSound) - 1);
		EmitSoundToAll(MissSound[Rand], victim, _, 80);
		damage = 0.0;
	}
}
public void Iberian_4thFormStatMulti(int client, int WhatStat, float StatNum,  float &MultiCurrent)
{
	if(!Expidonsa_InRageMode[client])
	{
		return;
	}
	int MaxHealth = ReturnEntityMaxHealth(client);
	int Health = GetEntProp(client, Prop_Data, "m_iHealth");

	float RateLeft = float(Health) / float(MaxHealth);
	RateLeft -= 1.0;
	RateLeft *= -1.0;
	RateLeft *= 0.33;
	RateLeft += 1.0;
	switch(WhatStat)
	{
		case Form::AgilityAdd:
		{
			if(StatNum >= 1.0)
				MultiCurrent *= RateLeft;
			else
				MultiCurrent *= 1.0 / RateLeft;
		}
	}
}
public void Iberian_Activation_Enable_Global(int client, int level)
{
	Expidonsa_InRageMode[client] = false;
	switch(level)
	{
		case 1:
		{
			EmitSoundToAll("player/taunt_yeti_appear_snow.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("replay/enterperformancemode.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("items/powerup_pickup_precision.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 4:
		{
			
			Race race;
			if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
			{
				//we want the 4rd form to be at atleast 150 mastery.
				Form form;
				race.Forms.GetArray(3, form);

				float MasteryHas = Stats_GetFormMastery(client, form.Name);
				float MasteryMax = form.Mastery;
				
				if(MasteryHas / MasteryMax >= 0.25)
				{
					EmitSoundToAll("weapons/bumper_car_speed_boost_stop.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 80);
					EmitSoundToAll("replay/enterperformancemode.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 80);
					Expidonsa_InRageMode[client] = true;
				}
				else
				{
					EmitSoundToAll("replay/enterperformancemode.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 80);
				}
			}
		}
	}
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerIberian_Transform, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	i_TransformInitLevel[client] = i_TransformationLevel[client];
	
	if(IsValidEntity(iref_Halo[client][0]))
	{
		CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][0], TIMER_FLAG_NO_MAPCHANGE);
	}

	if(IsValidEntity(iref_Halo[client][1]))
	{
		CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][1], TIMER_FLAG_NO_MAPCHANGE);
	}
	if(IsValidEntity(iref_Halo[client][2]))
	{
		CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][2], TIMER_FLAG_NO_MAPCHANGE);
	}

	float flPos[3];
	float flAng[3];
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		if(level == 1 || level == 2)
		{
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_genplasmos_b_glow2", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-5.0});
		}
		if(level == 2 || level == 3)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 70.0;
			int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
		}
		if(level == 3)
		{
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_sapper_teamcolor_blue", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-1.0});
		}
		if(level == 4)
		{
			
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler = ParticleEffectAt(flPos, "utaunt_aestheticlogo_blue_lines", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
			
			if(Expidonsa_InRageMode[client])
			{
				GetAttachment(viewmodelModel, "head", flPos, flAng);
				int particle_halo = ParticleEffectAt(flPos, "unusual_stardust_white_glow1", 0.0);
				iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
				AddEntityToThirdPersonTransitMode(client, particle_halo);
				SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-3.0});

				
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				particler = ParticleEffectAt(flPos, "utaunt_mysticfusion_ring", 0.0);
				SetParent(client, particler);
				iref_Halo[client][2] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
			else
			{
				GetAttachment(viewmodelModel, "head", flPos, flAng);
				int particle_halo = ParticleEffectAt(flPos, "unusual_robot_time_warp_edge", 0.0);
				iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
				AddEntityToThirdPersonTransitMode(client, particle_halo);
				SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-3.0});
			}
		}
	}
}


public Action TimerIberian_Transform(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || i_TransformationLevel[client] != i_TransformInitLevel[client])
	{
		//To remove the particle without it lasting, unparent, then teleport off the map.
		if(IsValidEntity(iref_Halo[client][0]))
		{
			CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][0], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][0] = -1;
		}
		if(IsValidEntity(iref_Halo[client][1]))
		{
			CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][1], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][1] = -1;
		}
		if(IsValidEntity(iref_Halo[client][2]))
		{
			CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][2], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][2] = -1;
		}

		i_TransformInitLevel[client] = -1;
		Timer_Expidonsan_Transform[client] = null;
		return Plugin_Stop;
	}	
	if(i_TransformationLevel[client] == 4)
	{
		if(Expidonsa_InRageMode[client])
		{
			TFClassType ClassForStats = WeaponClass[client];
			Stats_ApplyMovementSpeedUpdate(client, ClassForStats);
			SDKCall_SetSpeed(client);
		}
	}
	return Plugin_Continue;
}


