static Handle Timer_Expidonsan_Transform[MAXPLAYERS+1] = {null, ...};
static int i_TransformInitLevel[MAXPLAYERS+1];
static int iref_Halo[MAXPLAYERS+1][2];
static bool Expidonsa_InRageMode[MAXPLAYERS+1];
static float f_HumanRevivalLogic[MAXPLAYERS+1];

void Transform_MercHuman_MapStart()
{
	PrecacheSound("ui/rd_2base_alarm.wav");
	PrecacheSound("ui/quest_decode_halloween.wav");
	PrecacheSound("ui/halloween_boss_tagged_other_it.wav");
	PrecacheSound("items/powerup_pickup_base.wav");
	Zero(f_HumanRevivalLogic);
}

public void MercHuman_Activation_Enable_form_1(int client)
{
	//Respawn Resolve
	MercHuman_Activation_Enable_Global(client, 1);
}

public void MercHuman_Activation_Enable_form_2(int client)
{
	//Merasmus Magic!
	MercHuman_Activation_Enable_Global(client, 2);
}
public void MercHuman_Activation_Enable_form_3(int client)
{
	//Merasmus Magic!
	MercHuman_Activation_Enable_Global(client, 3);
}
public void MercHuman_Activation_Enable_form_4(int client)
{
	//Merasmus Magic!
	MercHuman_Activation_Enable_Global(client, 4);
}

public void MercHuman_4thFormNameSpecial(int client, char name[256])
{
	if(Expidonsa_InRageMode[client])
	{
		strcopy(name, sizeof(name), "Unbreakable Human Spirit");
	}
}
public void MercHuman_Activation_DEEnable_form_4(int client)
{
	Expidonsa_InRageMode[client] = false;
}

public void MercHuman_TakeDamage4th(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(Expidonsa_InRageMode[victim] && f_HumanRevivalLogic[victim] < GetGameTime())
	{
		int flHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
		//damage is more then their health, they will die.
		//PrintToConsole(victim, "[ZR] THIS IS DEBUG! IGNORE! Player_OnTakeDamageAlive_DeathCheck 2, Health: %i, damage float %f damage int:%i ",flHealth, damage,RoundToCeil(damage));
		if(RoundToCeil(damage) >= flHealth)
		{
			damage = 0.0;
			f_HumanRevivalLogic[victim] = GetGameTime() + 200.0;
			GiveCompleteInvul(victim, 2.0);
			EmitSoundToAll("misc/halloween/spell_overheal.wav", victim, SNDCHAN_STATIC, 80, _, 0.8);
			int MaxHealth = ReturnEntityMaxHealth(victim);
			HealEntityGlobal(victim, victim, float(MaxHealth) / 2.0, 1.0, 4.0, HEAL_SELFHEAL);
			RPGCore_StaminaAddition(victim, i_MaxStamina[victim] / 2);
			HealEntityGlobal(victim, victim, float(MaxHealth) / 1.4, 1.0, 10.0, HEAL_SELFHEAL);
			RPGCore_ResourceAddition(victim, RoundToCeil(max_mana[victim] / 2.0));
			MakePlayerGiveResponseVoice(victim, 4); //haha!
		}
	}
}

public void MercHuman_Activation_Enable_Global(int client, int level)
{
	Expidonsa_InRageMode[client] = false;
	switch(level)
	{
		case 1:
		{
			EmitSoundToAll("ui/rd_2base_alarm.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 2:
		{
			EmitSoundToAll("ui/quest_decode_halloween.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("ui/halloween_boss_tagged_other_it.wav", client, SNDCHAN_AUTO, 80, _, 1.0);
		}
		case 4:
		{
			EmitSoundToAll("items/powerup_pickup_base.wav", client, SNDCHAN_AUTO, 80, _, 0.5, 110);
			
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
					MakePlayerGiveResponseVoice(client, 1); //haha!
					Expidonsa_InRageMode[client] = true;
				}
			}
		}
	}
	delete Timer_Expidonsan_Transform[client];
	DataPack pack;
	Timer_Expidonsan_Transform[client] = CreateDataTimer(0.5, TimerMercHuman_Transform, pack, TIMER_REPEAT);
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
			flPos[2] -= 10.0;
			int particle_halo = ParticleEffectAt(flPos, "unusual_phantomcrown_purple_parent", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-10.0});
		}
		if(level == 2)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler = ParticleEffectAt(flPos, "utaunt_merasmus_fire_embers", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);
		}
		if(level == 3)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 10.0;
			int particler = ParticleEffectAt(flPos, "eyeboss_aura_grumpy", 0.0);
			SetParent(client, particler);
			iref_Halo[client][1] = EntIndexToEntRef(particler);
			AddEntityToThirdPersonTransitMode(client, particler);

			
			GetAttachment(viewmodelModel, "head", flPos, flAng);
			flPos[2] += 10.0;
			int particle_halo = ParticleEffectAt(flPos, "unusual_eyeboss_parent", 0.0);
			iref_Halo[client][0] = EntIndexToEntRef(particle_halo);
			AddEntityToThirdPersonTransitMode(client, particle_halo);
			SetParent(viewmodelModel, particle_halo, "head", {0.0,0.0,-10.0});
		}
		if(level == 4)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particler;
			if(Expidonsa_InRageMode[client])
			{
				particler = ParticleEffectAt(flPos, "utaunt_tarotcard_teamcolor_red", 0.0);
				SetParent(client, particler);
				iref_Halo[client][1] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
			else
			{
				particler = ParticleEffectAt(flPos, "utaunt_tarotcard_red_glow", 0.0);
				SetParent(client, particler);
				iref_Halo[client][1] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
				
				particler = ParticleEffectAt(flPos, "utaunt_tarotcard_red_wind", 0.0);
				SetParent(client, particler);
				iref_Halo[client][0] = EntIndexToEntRef(particler);
				AddEntityToThirdPersonTransitMode(client, particler);
			}
		}
	}
}


public Action TimerMercHuman_Transform(Handle timer, DataPack pack)
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

	if(i_TransformationLevel[client] == 4 && Expidonsa_InRageMode[client])
	{
		char LeperHud[256];
		//This is the 4th form, just a hud, nothing else.
		if(f_HumanRevivalLogic[client] > GetGameTime())
		{
			Format(LeperHud, sizeof(LeperHud), "Spirit Weakened [%.1fs]",f_HumanRevivalLogic[client] - GetGameTime());
		}
		else
		{
			Format(LeperHud, sizeof(LeperHud), "Spirit Stength");
		}
		PrintHintText(client,"%s",LeperHud);
		
	}
	return Plugin_Continue;
}