#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "misc/rd_robot_explosion01.wav";
static char g_EmergencyExtractionSound[] = "weapons/rocket_ll_shoot.wav";
static int NPCId;
static bool SilentDestruction;
static bool OneCaramelldansen;
static float g_CD_LandingSound;
static float FactoryTooLuod;

void VictorianFactory_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Factory");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_factory");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_factory");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_EmergencyExtractionSound);
	PrecacheSound("misc/rd_points_return01.wav");
	PrecacheSound("misc/doomsday_lift_start.wav");
	PrecacheSound("misc/hologram_start.wav");
	PrecacheSound("items/bomb_warning.wav");
	PrecacheModel("models/props_c17/substation_transformer01a.mdl");
	PrecacheModel("models/props_c17/lockers001a.mdl");
	PrecacheModel("models/props_skybox/train_building004_skybox.mdl");
	PrecacheSoundCustom("#zombiesurvival/aprilfools/caramelldansen.mp3");
}

int VictorianFactory_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	vecAng[0]=0.0;
	vecAng[1]=0.0;
	vecAng[2]=0.0;
	return VictorianFactory(vecPos, vecAng, ally, data);
}

static char[] GetBuildingHealth()
{
	int health = 120;
	
	health = RoundToNearest(float(health) * ZRStocks_PlayerScalingDynamic()); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	float wave = float(Waves_GetRoundScale()+1) / 0.75;
	
	if(wave < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + wave) * wave),1.20));
	}
	else if(wave < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + wave) * wave),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + wave) * wave),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	health = RoundToCeil(float(health) * 1.2);
	health = RoundToCeil(float(health) * 0.67);//wtf
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

methodmap VictorianFactory < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayEmergencyExtractionSound()
	{
		if(g_CD_LandingSound > GetGameTime())
			return;
		EmitSoundToAll(g_EmergencyExtractionSound, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_EmergencyExtractionSound, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		g_CD_LandingSound = GetGameTime() + 10.0;
	}
	public void PlayLandingSound()
	{
		if(g_CD_LandingSound > GetGameTime())
			return;
		EmitSoundToAll("misc/hologram_start.wav", _, _, _, _, 1.0);
		EmitSoundToAll("misc/hologram_start.wav", _, _, _, _, 1.0);
		g_CD_LandingSound = GetGameTime() + 10.0;
	}
	
	/*property int i_GetWave
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}*/
	property float m_flBaseBuildTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flLastManAdvantage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flLifeTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flMusicEnd
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public VictorianFactory (float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianFactory npc = view_as<VictorianFactory>(CClotBody(vecPos, vecAng, "models/props_skybox/train_building004_skybox.mdl", "2.0", GetBuildingHealth(), ally, _, true, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		func_NPCDeath[npc.index] = Factory_Got_Explod;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = FactoryCPU;
		
		npc.m_flSpeed = 0.0;
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flBaseBuildTime = 10.0;
		npc.m_flLastManAdvantage = 2.5;
		i_AttacksTillMegahit[npc.index] = 0;
		npc.Anger = false;

		npc.m_flMeleeArmor = 0.0;
		npc.m_flRangedArmor = 0.0;
		b_IgnorePlayerCollisionNPC[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		npc.m_bDissapearOnDeath = true;
		i_NpcIsABuilding[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = false;
		f_ExtraOffsetNpcHudAbove[npc.index] = 1.0;
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		
		i_GunAmmo[npc.index]=0;
		b_we_are_reloading[npc.index]=false;
		npc.m_flLifeTime=20.0;
		i_ammo_count[npc.index]=0;
		bool DontUseTeleport;
		
		//default: type-a (old ver)
		//Maybe used for special waves
		static char countext[8][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "type-b") != -1)
			{
				//Automatic Fragments Spawn
				ReplaceString(countext[i], sizeof(countext[]), "type-b", "");
				npc.m_iState = 1;
			}
			else if(StrContains(countext[i], "type-c") != -1)
			{
				//Automatic Anvil Spawn
				ReplaceString(countext[i], sizeof(countext[]), "type-c", "");
				npc.m_iState = 2;
			}
			else if(StrContains(countext[i], "type-d") != -1)
			{
				//Spawn Disable - Victoria Wave uses this setting.
				ReplaceString(countext[i], sizeof(countext[]), "type-d", "");
				npc.m_iState = -4;
			}
			else if(StrContains(countext[i], "buildtime") != -1)
			{
				//For Automatic Spawn
				ReplaceString(countext[i], sizeof(countext[]), "buildtime", "");
				npc.m_flBaseBuildTime = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "lastmanadvantage") != -1)
			{
				//For Automatic Spawn
				ReplaceString(countext[i], sizeof(countext[]), "lastmanadvantage", "");
				npc.m_flLastManAdvantage = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "lifetime") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "lifetime", "");
				npc.m_flLifeTime = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "mk2") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "mk2", "");
				b_we_are_reloading[npc.index] = true;
			}
			else if(StrContains(countext[i], "tracking") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "tracking", "");
				i_GunAmmo[npc.index]=1;
			}
			else if(StrContains(countext[i], "caramelldansen") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "caramelldansen", "");
				if(!OneCaramelldansen)
				{
					int RollRandom = StringToInt(countext[i]);
					if(!RollRandom)RollRandom=300;
					if(!(GetURandomInt() % RollRandom))
					{
						OneCaramelldansen=true;
						npc.Anger=true;
					}
				}
			}
			else if(StrContains(countext[i], "donusetele") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "donusetele", "");
				DontUseTeleport=true;
			}
		}
		
		if(npc.m_iState!=0)
		{
			MakeObjectIntangeable(npc.index);
			AddNpcToAliveList(npc.index, 1);
		}
		
		i_current_wave[npc.index]=(Waves_GetRoundScale()+1);
		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("misc/rd_points_return01.wav", _, _, _, _, 1.0);
				EmitSoundToAll("misc/rd_points_return01.wav", _, _, _, _, 1.0);
			}
			LastSpawnDiversio = GetGameTime() + 5.0;
			if(!DontUseTeleport)
			{
				int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 1000.0);
				switch(Decicion)
				{
					case 2:
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 250.0);
							if(Decicion == 2)
							{
								Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0);
							}
						}
					}
					case 3:
					{
						//todo code on what to do if random teleport is disabled
					}
				}
			}
		}

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 80, 50, 50, 60);

		npc.m_iWearable3 = npc.EquipItemSeperate("models/props_c17/substation_transformer01a.mdl",_,1,1.001,5100.0,true);
		SetEntityRenderColor(npc.m_iWearable3, 80, 50, 50, 255);
		GetAbsOrigin(npc.m_iWearable3, vecPos);
		vecPos[1] += 20.0;
		TeleportEntity(npc.m_iWearable3, vecPos, {0.0, 90.0, 0.0}, NULL_VECTOR);
		npc.m_bTeamGlowDefault = false;
		return npc;
	}
}

static void FactoryCPU(int iNPC)
{
	VictorianFactory npc = view_as<VictorianFactory>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(i_AttacksTillMegahit[npc.index] >= 600)
	{
		float BuildTime=npc.m_flBaseBuildTime;
		if(LastMann) BuildTime*=npc.m_flLastManAdvantage;
		if(i_AttacksTillMegahit[npc.index] <= 600)
		{
			float Vec[3], Ang[3];
			GetAbsOrigin(npc.m_iWearable3, Vec);
			//CreateTimer(0.1, Timer_MachineShop, npc.index, TIMER_FLAG_NO_MAPCHANGE);
			//VictorianFactory npc = view_as<VictorianFactory>(iNPC);
			float entitypos[3], distance;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && entity!=npc.index && GetTeam(entity) != GetTeam(npc.index))
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(Vec, entitypos);
					if(distance<200.0)
					{
						float MaxHealth = float(ReturnEntityMaxHealth(entity));
						float damage=(MaxHealth*2.0);
						SDKHooks_TakeDamage(entity, npc.index, npc.index, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
					}
				}
			}
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE && GetTeam(target) != GetTeam(npc.index))
				{
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(Vec, entitypos);
					if(distance<=200.0)
					{
						int health = GetClientHealth(target);
						SDKHooks_TakeDamage(target, npc.index, npc.index, float(health)*10.0, DMG_TRUEDAMAGE|DMG_CRIT);
					}
				}
			}
			b_IgnorePlayerCollisionNPC[npc.index] = false;
			npc.m_iWearable1 = npc.EquipItemSeperate("models/props_c17/lockers001a.mdl",_,1,2.0,_,true);
			GetAbsOrigin(npc.m_iWearable1, Vec);
			//GetEntPropVector(npc.m_iWearable3, Prop_Data, "m_angRotation", Ang);
			Ang[0] = 0.0;
			Ang[1] = 180.0;
			Ang[2] = 0.0;
			Vec[0] -= 65.0;
			Vec[1] -= 8.0;
			Vec[2] += 55.0;
			if(IsValidEntity(npc.m_iWearable1))
			{
				TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
				SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);
			}
			
			npc.m_iWearable2 = npc.EquipItemSeperate("models/props_c17/lockers001a.mdl",_,1,2.0,_,true);
			//GetEntPropVector(npc.m_iWearable3, Prop_Data, "m_angRotation", Ang);
			GetAbsOrigin(npc.m_iWearable2, Vec);
			Ang[0] = 0.0;
			Ang[1] = 0.0;
			Ang[2] = 0.0;
			Vec[0] += 65.0;
			Vec[1] -= 8.0;
			Vec[2] += 55.0;
			if(IsValidEntity(npc.m_iWearable2))
			{
				TeleportEntity(npc.m_iWearable2, Vec, NULL_VECTOR, NULL_VECTOR);
				SetEntityRenderColor(npc.m_iWearable2, 80, 50, 50, 255);
			}
			
			if(FactoryTooLuod < gameTime)
			{
				EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
				EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
				FactoryTooLuod = gameTime + 4.0;
			}
			i_AttacksTillMegahit[npc.index] = 601;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] >= 601 && i_AttacksTillMegahit[npc.index] < 606)
		{
			float Vec[3];
			if(IsValidEntity(npc.m_iWearable1))
			{
				GetAbsOrigin(npc.m_iWearable1, Vec);
				Vec[0] -= 12.5;
				TeleportEntity(npc.m_iWearable1, Vec, NULL_VECTOR, NULL_VECTOR);
			}
			if(IsValidEntity(npc.m_iWearable2))
			{
				GetAbsOrigin(npc.m_iWearable2, Vec);
				Vec[0] += 12.5;
				TeleportEntity(npc.m_iWearable2, Vec, NULL_VECTOR, NULL_VECTOR);
			}
			i_AttacksTillMegahit[npc.index] += 1;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] <= 606)
		{
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.index);
			MakeObjectIntangeable(npc.m_iWearable1);
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.index);
			MakeObjectIntangeable(npc.m_iWearable2);
			npc.PlayLandingSound();
			if(IsValidEntity(npc.m_iTeamGlow))
				RemoveEntity(npc.m_iTeamGlow);
			npc.m_flAttackHappens = gameTime + BuildTime;
			i_AttacksTillMegahit[npc.index] = 607;
			if(npc.m_iState==0)
			{
				npc.m_flMeleeArmor = 2.0;
				npc.m_flRangedArmor = 0.5;
				b_NpcIsInvulnerable[npc.index] = false;
				b_ThisEntityIgnored[npc.index] = false;
				npc.m_flAttackHappens = gameTime + 1.0;
			}
			return;
		}
		if(i_AttacksTillMegahit[npc.index] <= 607)
		{
			switch(npc.m_iState)
			{
				case -5:
				{
					//I was lazy to make a smooth RGB loop
					static int GET_R;
					static int GET_G;
					static int GET_B;
					int RGESPeed=17;
					switch(npc.m_iOverlordComboAttack)
					{
						case 0:
						{
							GET_R=255;
							GET_G=0;
							GET_B+=RGESPeed;
							if(GET_B>255)
							{
								GET_B=255;
								npc.m_iOverlordComboAttack++;
							}
						}
						case 1:
						{
							GET_R-=RGESPeed;
							GET_G=0;
							GET_B=255;
							if(GET_R<=0)
							{
								GET_R=0;
								npc.m_iOverlordComboAttack++;
							}
						}
						case 2:
						{
							GET_R=0;
							GET_G+=RGESPeed;
							GET_B=255;
							if(GET_G>255)
							{
								GET_G=255;
								npc.m_iOverlordComboAttack++;
							}
						}
						case 3:
						{
							GET_R=0;
							GET_G=255;
							GET_B-=RGESPeed;
							if(GET_B<=0)
							{
								GET_B=0;
								npc.m_iOverlordComboAttack++;
							}
						}
						case 4:
						{
							GET_R+=RGESPeed;
							GET_G=255;
							GET_B=0;
							if(GET_R>255)
							{
								GET_R=255;
								npc.m_iOverlordComboAttack++;
							}
						}
						case 5:
						{
							GET_R=255;
							GET_G-=RGESPeed;
							GET_B=0;
							if(GET_G<=0)
							{
								GET_G=0;
								npc.m_iOverlordComboAttack++;
							}
						}
						default: npc.m_iOverlordComboAttack=0;
					}
					if(IsValidEntity(npc.m_iTeamGlow))
					{
						int iColor[4];
						SetColorRGBA(iColor, GET_R, GET_G, GET_B, 200);
						SetVariantColor(iColor);
						AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
					}
					if(npc.m_flMusicEnd < gameTime)
					{
						OneCaramelldansen=false;
						npc.Anger=false;
						if(IsValidEntity(npc.m_iTeamGlow))
							RemoveEntity(npc.m_iTeamGlow);
						for(int client=1; client<=MaxClients; client++)
						{
							if(IsClientInGame(client) && !IsFakeClient(client))
							{
								SetMusicTimer(client, GetTime() + 1);
								StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/aprilfools/caramelldansen.mp3");
								StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/aprilfools/caramelldansen.mp3");
							}
						}
						npc.m_iState = -4;
					}
				}
				case -4:
				{
					if(npc.Anger)
					{
						MusicEnum CustomMusic;
						strcopy(CustomMusic.Path, sizeof(CustomMusic.Path), "#zombiesurvival/aprilfools/caramelldansen.mp3");
						CustomMusic.Time = 175;
						CustomMusic.Volume = 1.0;
						CustomMusic.Custom = true;
						npc.m_flMusicEnd = gameTime+175.0;
						if(CustomMusic.Path[0])
						{
							for(int client=1; client<=MaxClients; client++)
							{
								if(IsClientInGame(client) && !IsFakeClient(client))
								{
									Music_Stop_All(client);
									EmitCustomToClient(client, CustomMusic.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, CustomMusic.Volume);
								}
							}
						}
						if(!IsValidEntity(npc.m_iTeamGlow))
							npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
						npc.m_flAttackHappens=gameTime;
						npc.m_iState = -5;
					}
				}
				//Old ver
				case -1, -2, -3:
				{
					float Vec[3];
					GetAbsOrigin(npc.m_iWearable3, Vec);
					if(IsValidEntity(npc.m_iWearable4))
					{
						if(gameTime > npc.m_flAttackHappens)
						{
							GetAbsOrigin(npc.m_iWearable3, Vec);
							int spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, Vec, {0.0,0.0,0.0}, GetTeam(npc.index), "factory;mk2;isvoli");
							if(spawn_index > MaxClients)
							{
								NpcStats_CopyStats(npc.index, spawn_index);
								int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.25);
								NpcAddedToZombiesLeftCurrently(spawn_index, true);
								SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
								SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
								fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
								fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
								fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
								fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
								IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 1.0);
							}
							npc.m_flAttackHappens = gameTime + 1.0;
							npc.m_iState -= 1;
						}
					}
					else
					{
						float Ang[3];
						npc.GetAttachment("m_vecAbsOrigin", Vec, Ang);
						Vec[2]+=140.0;
						npc.m_iWearable4 = ParticleEffectAt_Parent(Vec, "cart_flashinglight_red", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
						npc.GetAttachment("", Vec, Ang);
						EmitSoundToAll("items/bomb_warning.wav", npc.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					}
				}
				case 0:
				{
					if(!IsValidEntity(npc.m_iTeamGlow))
					{
						npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
						int iColor[4];
						SetColorRGBA(iColor, 255, 255, 255, 200);
						SetVariantColor(iColor);
						AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
					}
					bool GetClosed=false;
					float Vec[3], entitypos[3], distance;
					GetAbsOrigin(npc.m_iWearable3, Vec);
					for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
					{
						int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
						if(IsValidEntity(entity) && entity!=npc.index && GetTeam(entity) != GetTeam(npc.index))
						{
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
							distance = GetVectorDistance(Vec, entitypos, true);
							if(distance<(400.0*400.0)) GetClosed=true;
						}
					}
					for(int target=1; target<=MaxClients; target++)
					{
						if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE && GetTeam(target) != GetTeam(npc.index))
						{
							GetEntPropVector(target, Prop_Send, "m_vecOrigin", entitypos);
							distance = GetVectorDistance(Vec, entitypos, true);
							if(distance<=(400.0*400.0)) GetClosed=true;
						}
					}
					if(GetClosed)
						npc.m_iState = -1;
				}
				//New ver
				case 1, 2:
				{
					if(Waves_InSetup() || i_current_wave[npc.index]!=(Waves_GetRoundScale()+1))
					{
						npc.m_flAttackHappens = gameTime + BuildTime;
						i_current_wave[npc.index]=(Waves_GetRoundScale()+1);
						return;
					}
					if(IsValidEntity(npc.m_iTeamGlow))
					{
						int iColor[4];
						SetColorRGBA(iColor, 145+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*110.0),
						10+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*245.0),
						0+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*255.0),
						200+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*55.0));
						SetVariantColor(iColor);
						AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
					}
					else
						npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
					if(npc.m_flAttackHappens < gameTime)
					{
						float Vec[3]; GetAbsOrigin(npc.m_iWearable3, Vec);
						char Adddeta[512];
						if(b_we_are_reloading[npc.index])
							FormatEx(Adddeta, sizeof(Adddeta), "%s;mk2", Adddeta);
						FormatEx(Adddeta, sizeof(Adddeta), "%s;lifetime%.1f", Adddeta, npc.m_flLifeTime);
						if(npc.m_iState==1 && i_GunAmmo[npc.index])
							FormatEx(Adddeta, sizeof(Adddeta), "%s;tracking", Adddeta);
						Vec[2]+=45.0;
						int spawn_index;
						if(npc.m_iState==1)
							spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, Vec, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
						else
							spawn_index = NPC_CreateByName("npc_victoria_anvil", npc.index, Vec, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
						if(spawn_index > MaxClients)
						{
							int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.7);
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
							SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
							SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
							fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
							fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
							fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
							fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
							FreezeNpcInTime(spawn_index, 3.0, true);
							IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 3.0);
						}
						
						npc.m_flAttackHappens = gameTime + BuildTime;
						EmitSoundToAll("items/bomb_warning.wav", npc.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					}
				}
				case 3, 4, 5, 6:
				{
					if(IsValidEntity(npc.m_iTeamGlow))
					{
						int iColor[4];
						SetColorRGBA(iColor, 145+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*110.0),
						10+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*245.0),
						0+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*255.0),
						200+RoundToCeil(((npc.m_flAttackHappens-gameTime)/BuildTime)*55.0));
						SetVariantColor(iColor);
						AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
					}
					else
						npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
					if(npc.m_flAttackHappens < gameTime)
					{
						float Vec[3]; GetAbsOrigin(npc.m_iWearable3, Vec);
						char Adddeta[512];
						/*if(MK2[npc.index])
							FormatEx(Adddeta, sizeof(Adddeta), "%s;mk2", Adddeta);
						if(Limit[npc.index])
							FormatEx(Adddeta, sizeof(Adddeta), "%s;limit", Adddeta);
						FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, target);*/
						Vec[2]+=45.0;
						int spawn_index;
						if(npc.m_iState==1)
							spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, Vec, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
						else
							spawn_index = NPC_CreateByName("npc_victoria_anvil", npc.index, Vec, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
						if(spawn_index > MaxClients)
						{
							int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.7);
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
							SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
							SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
							FreezeNpcInTime(spawn_index, 3.0, true);
							IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 3.0);
						}
						
						npc.m_flAttackHappens = gameTime + BuildTime;
						EmitSoundToAll("items/bomb_warning.wav", npc.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					}
				}
			}
			return;
		}
		if(i_AttacksTillMegahit[npc.index] >= 608 && i_AttacksTillMegahit[npc.index] < 613)
		{
			if(IsValidEntity(npc.m_iTeamGlow))
				RemoveEntity(npc.m_iTeamGlow);
			if(IsValidEntity(npc.m_iWearable1))
			{
				SetVariantString("!activator");
				AcceptEntityInput(npc.m_iWearable1, "ClearParent");
			}
			if(IsValidEntity(npc.m_iWearable2))
			{
				SetVariantString("!activator");
				AcceptEntityInput(npc.m_iWearable2, "ClearParent");
			}
			float Vec[3];
			if(IsValidEntity(npc.m_iWearable1))
			{
				GetAbsOrigin(npc.m_iWearable1, Vec);
				Vec[0] += 12.5;
				TeleportEntity(npc.m_iWearable1, Vec, NULL_VECTOR, NULL_VECTOR);
			}
			if(IsValidEntity(npc.m_iWearable2))
			{
				GetAbsOrigin(npc.m_iWearable2, Vec);
				Vec[0] -= 12.5;
				TeleportEntity(npc.m_iWearable2, Vec, NULL_VECTOR, NULL_VECTOR);
			}
			i_AttacksTillMegahit[npc.index] += 1;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] <= 613)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
			float Vec[3];
			if(IsValidEntity(npc.m_iWearable3))
			{
				GetAbsOrigin(npc.m_iWearable3, Vec);
				Vec[2]-=80.0;
				npc.m_iWearable1=ParticleEffectAt(Vec, "rockettrail", 0.0);
				SetVariantString("!activator");
				AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.m_iWearable3);
				npc.m_flAttackHappens_bullshit = gameTime + 3.0;
				i_AttacksTillMegahit[npc.index] = 614;
			}
			return;
		}
		if(i_AttacksTillMegahit[npc.index] <= 614)
		{
			if(npc.m_flAttackHappens_bullshit >= gameTime)
				return;
			npc.PlayEmergencyExtractionSound();
			i_AttacksTillMegahit[npc.index] = 615;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] <= 615)
		{
			float Vec[3], Parts[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
			if(IsValidEntity(npc.m_iWearable3))
				GetEntPropVector(npc.m_iWearable3, Prop_Send, "m_vecOrigin", Parts);
			Vec[0]=Parts[0];
			Vec[1]=Parts[1];
			Vec[2]+=55.0;
			float YPOS = GetVectorDistance(Vec, Parts);
			if(YPOS>5100.0)
			{
				i_RaidGrantExtra[npc.index] = 0;
				b_DissapearOnDeath[npc.index] = true;
				b_DoGibThisNpc[npc.index] = true;
				SilentDestruction = true;
				SmiteNpcToDeath(npc.index);
			}
			else
			{
				float UpSpeed=5.0;
				if(YPOS>1000.0)
					UpSpeed=100.0;
				else if(YPOS>100.0)
					UpSpeed=50.0;
				else if(YPOS>20.0)
					UpSpeed=10.0;
				Parts[2]+=UpSpeed;
				if(IsValidEntity(npc.m_iWearable3))
					TeleportEntity(npc.m_iWearable3, Parts, NULL_VECTOR, NULL_VECTOR);
			}
			return;
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
		float Vec[3], Parts[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
		if(IsValidEntity(npc.m_iWearable3))
			GetEntPropVector(npc.m_iWearable3, Prop_Send, "m_vecOrigin", Parts);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
		Vec[0]=Parts[0];
		Vec[1]=Parts[1];
		Vec[2]+=55.0;
		float YPOS = GetVectorDistance(Vec, Parts);
		if(YPOS<10.0)
		{
			if(IsValidEntity(npc.m_iWearable3))
			{
				TeleportEntity(npc.m_iWearable3, Vec, NULL_VECTOR, NULL_VECTOR);
				SetVariantString("!activator");
				AcceptEntityInput(npc.m_iWearable3, "SetParent", npc.index);
				MakeObjectIntangeable(npc.m_iWearable3);
			}
			i_AttacksTillMegahit[npc.index] = 600;
		}
		else
		{
			float DownSpeed=5.0;
			if(YPOS>1000.0)
				DownSpeed=100.0;
			else if(YPOS>100.0)
				DownSpeed=50.0;
			else if(YPOS>20.0)
				DownSpeed=10.0;
			Parts[2]-=DownSpeed;
			if(IsValidEntity(npc.m_iWearable3))
				TeleportEntity(npc.m_iWearable3, Parts, NULL_VECTOR, NULL_VECTOR);
			i_AttacksTillMegahit[npc.index] += 1;
		}
	}
}


static void Factory_Got_Explod(int entity)
{
	VictorianFactory npc = view_as<VictorianFactory>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	if(!SilentDestruction)
		npc.PlayDeathSound();
	SilentDestruction=false;
	
	if(OneCaramelldansen && npc.Anger)
	{
		OneCaramelldansen=false;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
			{
				SetMusicTimer(client, GetTime() + 1);
				StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/aprilfools/caramelldansen.mp3");
				StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/aprilfools/caramelldansen.mp3");
			}
		}
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}
