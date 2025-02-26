static Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
static int i_TransformInitLevel[MAXPLAYERS+1];
static int iref_Halo[MAXPLAYERS+1][2];
static bool Expidonsa_InRageMode[MAXPLAYERS+1];
static float EnergyLooseCooldown[MAXPLAYERS+1];

void Transform_Ruianian_MapStart()
{
	PrecacheSound("misc/halloween/spell_pickup.wav");
	PrecacheSound("misc/halloween/spell_meteor_impact.wav");
	PrecacheSound("misc/halloween/spell_lightning_ball_cast.wav");
	PrecacheSound("ui/killsound_space.wav");
	PrecacheSound("misc/ks_tier_04_death.wav");
	PrecacheSound("ui/killsound_electro.wav");
	PrecacheSound("weapons/physcannon/energy_bounce1.wav");
	PrecacheSound("weapons/physcannon/energy_bounce2.wav");
	Zero(EnergyLooseCooldown);
}

public void Ruianian_Activation_Enable_form_1(int client)
{
	//Respawn Resolve
	Ruianian_Activation_Enable_Global(client, 1);
}

public void Ruianian_Activation_Enable_form_2(int client)
{
	//Merasmus Magic!
	Ruianian_Activation_Enable_Global(client, 2);
}

public void Ruianian_Activation_Enable_form_3(int client)
{
	Ruianian_Activation_Enable_Global(client, 3);
}

public void Ruianian_Activation_Enable_form_4(int client)
{
	Ruianian_Activation_Enable_Global(client, 4);
}

public void Ruianian_Activation_Deactivate_form_4(int client)
{
	Expidonsa_InRageMode[client] = false;
}
public void Ruianian_4thFormNameSpecial(int client, char name[256])
{
	if(Expidonsa_InRageMode[client])
	{
		strcopy(name, sizeof(name), "Astral Acceptance");
	}
}
public bool Ruianian_EnergyRunOutLogic(int client)
{
	if(!Expidonsa_InRageMode[client])
	{
		return false;
	}
	if(EnergyLooseCooldown[client] < GetGameTime())
	{
		EmitSoundToAll("misc/halloween/spell_lightning_ball_cast.wav", client, SNDCHAN_AUTO, 80, _, 0.5, 110);
		TF2_AddCondition(client, TFCond_MegaHeal, 1.0);
		RPGCore_ResourceAddition(client, RoundToCeil(max_mana[client] / 2.0));
		EnergyLooseCooldown[client] = GetGameTime() + 120.0;
		int MaxHealth = ReturnEntityMaxHealth(client);
		HealEntityGlobal(client, client, float(MaxHealth) / 10, 1.0, 4.0, HEAL_SELFHEAL);
		return true;
	}
	return false;
}
public void Ruianian_4thFormStatMulti(int client, int WhatStat, float StatNum,  float &MultiCurrent)
{
	if(!Expidonsa_InRageMode[client])
	{
		return;
	}

	float RateLeft = (Current_Mana[client] + 1) / (max_mana[client] + 1);
	RateLeft -= 1.0;
	RateLeft *= -1.0;
	RateLeft *= 0.33;
	RateLeft += 1.0;
	switch(WhatStat)
	{
		default:
		{
			if(StatNum >= 1.0)
				MultiCurrent *= RateLeft;
			else
				MultiCurrent *= 1.0 / RateLeft;
		}
	}
}

public void Ruianian_Activation_Enable_Global(int client, int level)
{
	Expidonsa_InRageMode[client] = false;
	switch(level)
	{
		case 1:
		{
			EmitSoundToAll("misc/halloween/spell_pickup.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("misc/halloween/spell_meteor_impact.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("ui/killsound_space.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 4:
		{
			
			Race race;
			if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
			{
				//we want the 3rd form to be at atleast 150 mastery.
				Form form;
				race.Forms.GetArray(3, form);

				float MasteryHas = Stats_GetFormMastery(client, form.Name);
				float MasteryMax = form.Mastery;
				
				if(MasteryHas / MasteryMax >= 0.25)
				{
					EmitSoundToAll("weapons/physcannon/energy_bounce1.wav", client, SNDCHAN_AUTO, 80, _, 0.7, 70);
					EmitSoundToAll("weapons/physcannon/energy_bounce2.wav", client, SNDCHAN_AUTO, 80, _, 0.7, 70);
					Expidonsa_InRageMode[client] = true;
				}
				else
				{
					
					EmitSoundToAll("misc/halloween/spell_meteor_impact.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 140);
					EmitSoundToAll("ui/killsound_electro.wav", client, SNDCHAN_AUTO, 80, _, 0.5, 80);
				}
			}
		}
	}
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerRuianian_Transform, pack, TIMER_REPEAT);
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

	float flPos[3];
	float flAng[3];
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		if(level == 1 || level == 2)
		{
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_orbitingstar_parent", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head");
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
		}
		if(level == 2 || level == 3)
		{
			GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.0);
			iref_Halo[client][1] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "effect_hand_r");
		}
		if(level == 3)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler = ParticleEffectAt(flPos, "utaunt_constellations_blue_cloud", 0.0);
			SetParent(client, particler);
			iref_Halo[client][0] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
		}
		if(level == 4)
		{
			if(!Expidonsa_InRageMode[client])
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				int particler = ParticleEffectAt(flPos, "utaunt_spirit_winter_rings", 0.0);
				SetParent(client, particler);
				iref_Halo[client][0] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
				
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				particler = ParticleEffectAt(flPos, "utaunt_spirits_blue_glow", 0.0);
				SetParent(client, particler);
				iref_Halo[client][1] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
			else
			{

				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				int particler = ParticleEffectAt(flPos, "utaunt_mysticfusion_glow", 0.0);
				SetParent(client, particler);
				iref_Halo[client][0] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);

				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				particler = ParticleEffectAt(flPos, "utaunt_spirits_blue_glow", 0.0);
				SetParent(client, particler);
				iref_Halo[client][1] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
		}
	}
}


public Action TimerRuianian_Transform(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || i_TransformationLevel[client] != i_TransformInitLevel[client])
	{
		//To remove the particle without it lasting, unparent, then teleport off the map.
		if(IsValidEntity(iref_Halo[client][0]))
		{
			AcceptEntityInput(iref_Halo[client][0], "ClearParent");
			TeleportEntity(iref_Halo[client][0], {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, iref_Halo[client][0], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][0] = -1;
		}
		if(IsValidEntity(iref_Halo[client][1]))
		{
			AcceptEntityInput(iref_Halo[client][1], "ClearParent");
			TeleportEntity(iref_Halo[client][1], {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, iref_Halo[client][1], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][1] = -1;
		}

		i_TransformInitLevel[client] = -1;
		Timer_Expidonsan_Transform[client] = null;
		return Plugin_Stop;
	}	
	if(i_TransformationLevel[client] == 4)
	{
		if(Expidonsa_InRageMode[client])
		{
			static Race race;
			static Form form;
			Races_GetClientInfo(client, race, form);
			Attributes_Set(client, Attrib_FormRes, form.GetFloatStat(client, Form::DamageResistance, Stats_GetFormMastery(client, form.Name)));
			char LeperHud[256];
			//This is the 4th form, just a hud, nothing else.
			if(EnergyLooseCooldown[client] > GetGameTime())
			{
				Format(LeperHud, sizeof(LeperHud), "Ruanian Astral Vision [%.1fs]",EnergyLooseCooldown[client] - GetGameTime());
			}
			else
			{
				Format(LeperHud, sizeof(LeperHud), "Ruanian Astral Vision");
			}
			PrintHintText(client,"%s",LeperHud);
			
			UpdateLevelAbovePlayerText(client);
		}
	}
	return Plugin_Continue;
}