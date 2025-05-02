static Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
static int i_TransformInitLevel[MAXPLAYERS+1];
static int iref_Halo[MAXPLAYERS+1][3];
static bool Expidonsa_MegaForm[MAXPLAYERS+1];
static float Ability4thFormCooldown[MAXPLAYERS+1];
static bool Expidonsa_InRageMode[MAXPLAYERS+1];

#define COOLDOWN_OF_OVERSTRESS 120.0
void Transform_Expidonsa_MapStart()
{
	PrecacheSound("player/taunt_wormshhg.wav");
	PrecacheSound("ambient/levels/labs/electric_explosion4.wav");
	PrecacheSound("weapons/sentry_explode.wav");
	PrecacheSound("misc/halloween/spell_mirv_explode_secondary.wav");
	Zero(Ability4thFormCooldown);
	PrecacheSound("items/powerup_pickup_strength.wav");
}

public void Halo_Activation_Enable_form_1(int client)
{
	Halo_Activation_Enable_Global(client, 1);
}

public void Halo_Activation_Enable_form_2(int client)
{
	Halo_Activation_Enable_Global(client, 2);
}

public void Halo_Activation_Enable_form_3(int client)
{
	Halo_Activation_Enable_Global(client, 3);
}
public void Halo_Activation_Enable_form_4(int client)
{
	Halo_Activation_Enable_Global(client, 4);
}
public void Halo_Activation_Disable_form_4(int client)
{
	Expidonsa_InRageMode[client] = false;
	Expidonsa_MegaForm[client] = false;
}

public void Expidonsan_4thFormNameSpecial(int client, char name[256])
{
	if(Expidonsa_InRageMode[client])
	{
		strcopy(name, sizeof(name), "Unleashed Expidonsan Power");
	}
	else if(Expidonsa_MegaForm[client])
		strcopy(name, sizeof(name), "Released Expidonsan Secret");
}

public bool Expidonsan_4thFormTransSpecial(int client)
{
	if(!Expidonsa_MegaForm[client])
	{
		return false;
	}
	if(Ability4thFormCooldown[client] < GetGameTime())
	{
		int MaxHealth = ReturnEntityMaxHealth(client);
		int Health = GetEntProp(client, Prop_Data, "m_iHealth");

		if((float(Health) / float(MaxHealth)) <= 0.25)
		{
			HealEntityGlobal(client, client, float(MaxHealth) / 2, 1.0, 4.0, HEAL_SELFHEAL);
			RPGCore_StaminaAddition(client, 999999999);
			RPGCore_ResourceAddition(client, 999999999);
			
			//Fill up everytning out max!
			Ability4thFormCooldown[client] = GetGameTime() + COOLDOWN_OF_OVERSTRESS;
			Expidonsa_InRageMode[client] = true;
			EmitSoundToAll("items/powerup_pickup_strength.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 90);

			//YOU CANNOT TRANSFORM UNTILL YOU RUN OUT !!!!
			f_TransformationDelay[client] = FAR_FUTURE;
			
			CreateTimer(0.1, Timer_RemoveEntityParticle, iref_Halo[client][1], TIMER_FLAG_NO_MAPCHANGE);

			
			float flPos[3];
			int viewmodelModel;
			viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(viewmodelModel))
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				int particler = ParticleEffectAt(flPos, "utaunt_elebound_yellow_parent", 0.0);
				SetParent(client, particler);
				iref_Halo[client][1] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
			Store_ApplyAttribs(client);
			UpdateLevelAbovePlayerText(client);

			return true;
		}
	}
	return false;
}

public void Expidonsan_4thFormStatMulti(int client, int WhatStat, float StatNum,  float &MultiCurrent)
{
	if(!Expidonsa_InRageMode[client])
	{
		return;
	}
	if(!Expidonsa_MegaForm[client])
		return;
	switch(WhatStat)
	{
		default:
		{
			if(StatNum >= 1.0)
				MultiCurrent *= 1.2;
			else
				MultiCurrent *= 0.8;
		}
	}
}

public void Expidonsan_4thFormDrainSpecial(int client, float &DrainCurrent)
{
	if(!Expidonsa_InRageMode[client])
	{
		return;
	}
	if(!Expidonsa_MegaForm[client])
		return;
	DrainCurrent *= 1.2;

	float TimeLeft = GetGameTime() - Ability4thFormCooldown[client];
	if(TimeLeft >= 0.0)
	{
		//They stayed in it too long.
		De_TransformClient(client);
	}

	TimeLeft *= -1.0;
	TimeLeft = COOLDOWN_OF_OVERSTRESS / TimeLeft;
	TimeLeft *= 1.5;
	DrainCurrent *= TimeLeft;
}

public bool Expidonsan_4thFormTransReq(int client)
{
	Race race;
	if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
	{
		//we want the 3rd form to be at atleast 150 mastery.
		Form form;
		race.Forms.GetArray(2, form);

		float MasteryHas = Stats_GetFormMastery(client, form.Name);
		float MasteryMax = form.Mastery;
		
		if(MasteryHas / MasteryMax >= 0.75)
		{
			return true;
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			ShowGameText(client,"leaderboard_streak", 0, "Your previous form needs to be mastered by 75 Percent.");
		}

	}
	return false;
}

public void Halo_Activation_Enable_Global(int client, int level)
{
	Expidonsa_MegaForm[client] = false;
	Expidonsa_InRageMode[client] = false;
	if(level == 4)
	{
		Race race;
		if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
		{
			//we want the 3rd form to be at atleast 150 mastery.
			Form form;
			race.Forms.GetArray(level - 1, form);

			float MasteryHas = Stats_GetFormMastery(client, form.Name);
			float MasteryMax = form.Mastery;
			
			if(MasteryHas / MasteryMax >= 0.25)
			{
				Expidonsa_MegaForm[client] = true;
			}
		}
	}
	switch(level)
	{
		case 1:
		{
			EmitSoundToAll("player/taunt_wormshhg.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("ambient/levels/labs/electric_explosion4.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("weapons/sentry_explode.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 4:
		{
			EmitSoundToAll("misc/halloween/spell_mirv_explode_secondary.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 90);
			if(Expidonsa_MegaForm[client])
			{
				EmitSoundToAll("player/taunt_wormshhg.wav", client, SNDCHAN_AUTO, 80, _, 1.0, 90);
			}
		}
	}
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerExpidonsan_Transform, pack, TIMER_REPEAT);
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
		if(level == 1 || level == 2 || level == 3 || level == 4)
		{
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_symbols_parent_lightning", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-3.0});
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 20.0;
			ParticleEffectAt(flPos, "bombinomicon_flash", 1.0);
		}
		if(level == 4)
		{

			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler = ParticleEffectAt(flPos, "utaunt_aestheticlogo_orange_lines", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
		}
		if(level == 3)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler = ParticleEffectAt(flPos, "utaunt_arcane_yellow_sparkle", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
		}
		if(level == 2 || level == 3)
		{
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			int particle_halo = ParticleEffectAt(flPos, "unusual_sparkletree_gold_starglow", 0.0);
			iref_Halo[client][2] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-3.0});
		}
		if(level == 4)
		{
			if(!Expidonsa_MegaForm[client])
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 20.0;
				int particler = ParticleEffectAt(flPos, "utaunt_beams_glow_yellow", 0.0);
				SetParent(client, particler, "root", {0.0,0.0,15.0});
				iref_Halo[client][2] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
			else
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				int particler = ParticleEffectAt(flPos, "utaunt_poweraura_yellow_beam", 0.0);
				flPos[2] += 10.0;
				SetParent(client, particler, "root", {0.0,0.0,10.0});
				iref_Halo[client][2] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
		}
	}
}


public Action TimerExpidonsan_Transform(Handle timer, DataPack pack)
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
		if(IsValidEntity(iref_Halo[client][2]))
		{
			AcceptEntityInput(iref_Halo[client][2], "ClearParent");
			TeleportEntity(iref_Halo[client][2], {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, iref_Halo[client][2], TIMER_FLAG_NO_MAPCHANGE);
			iref_Halo[client][2] = -1;
		}

		i_TransformInitLevel[client] = -1;
		Timer_Expidonsan_Transform[client] = null;
		return Plugin_Stop;
	}	
	if(i_TransformationLevel[client] == 4 && Expidonsa_MegaForm[client])
	{
		char LeperHud[256];
		if(Expidonsa_InRageMode[client])
		{
			Format(LeperHud, sizeof(LeperHud), "OVERSTRESSING!");
		}
		else if(Ability4thFormCooldown[client] < GetGameTime())
		{
			int MaxHealth = ReturnEntityMaxHealth(client);
			int Health = GetEntProp(client, Prop_Data, "m_iHealth");

			if((float(Health) / float(MaxHealth)) <= 0.25)
			{

				Format(LeperHud, sizeof(LeperHud), "OVERSTRESS USE! PRESS E + CROUCH!");
			}
			else
				Format(LeperHud, sizeof(LeperHud), "Overstress Ready.");
		}
		else
		{
			Format(LeperHud, sizeof(LeperHud), "Overstress Cooldown[%.1fs]", Ability4thFormCooldown[client] - GetGameTime());
		}
		//This is the 4th form, just a hud, nothing else.
		PrintHintText(client,"%s",LeperHud);
		
	}
	return Plugin_Continue;
}