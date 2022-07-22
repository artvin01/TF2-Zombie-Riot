enum
{
	Cit_Custom = -1,
	Cit_AllyDeathAnswer = 0,
	Cit_AllyDeathQuestion,
	Cit_Ammo,
	Cit_Answer,
	Cit_Behind,
	Cit_Busy,
	Cit_CadeDeath,
	Cit_Combine,
	Cit_DoSomething,
	Cit_FirstBlood,
	Cit_Found,
	Cit_Greet,
	Cit_Headcrab,
	Cit_Healer,
	Cit_Hurt,
	Cit_Lost,
	Cit_LowHealth,
	Cit_MiniBoss,
	Cit_MiniBossDead,
	Cit_NewWeapon,
	Cit_Question,
	Cit_Reload,
	Cit_ReloadCombat,
	Cit_Staying,
	Cit_MAX
}

enum
{
	Cit_Unarmed = 2,
	Cit_Normal,
	Cit_Camo,
	Cit_Medic
}

enum
{
	Cit_None = 0,
	Cit_Melee,
	Cit_Pistol,
	Cit_Shotgun,
	Cit_SMG,
	Cit_AR,
	Cit_RPG
}

static void Citizen_GenerateModel(int seed, bool female, int group, char[] buffer, int length)
{
	if(female)
	{
		int rand = seed % 6;
		if(rand > 3)
		{
			rand += 2;
		}
		else
		{
			rand++;
		}
		
		Format(buffer, length, "female_0%d", rand);
	}
	else
	{
		Format(buffer, length, "male_0%d", 1 + (seed % 9));
	}
	
	switch(group)
	{
		case Cit_Unarmed:
			Format(buffer, length, "models/humans/group02/%s.mdl", buffer);
		
		case Cit_Normal:
			Format(buffer, length, "models/humans/group03/%s.mdl", buffer);
		
		case Cit_Camo:
			Format(buffer, length, "models/humans/group03/%s_bloody.mdl", buffer);
		
		case Cit_Medic:
			Format(buffer, length, "models/humans/group03m/%s.mdl", buffer);
		
		default:
			Format(buffer, length, "models/humans/group01/%s.mdl", buffer);
		
	}
}

static void Citizen_GenerateSound(int type, int seed, bool female, char[] buffer, int length)
{
	switch(type)
	{
		case Cit_Ammo:
		{
			Format(buffer, length, "ammo0%d", 3 + (seed % 3));
		}
		case Cit_Answer:
		{
			int rand = seed % 39;
			if(rand > 4)
			{
				rand += 2;
			}
			else
			{
				rand++;
			}
			
			Format(buffer, length, "answer%002d", rand);
		}
		case Cit_Behind:
		{
			Format(buffer, length, "behindyou0%d", 1 + (seed % 2));
		}
		case Cit_Busy:
		{
			strcopy(buffer, length, "busy02");
		}
		case Cit_Combine:
		{
			Format(buffer, length, "combine0%d", 1 + (seed % 2));
		}
		case Cit_ReloadCombat:
		{
			Format(buffer, length, "coverwhilereload0%d", 1 + (seed % 2));
		}
		case Cit_DoSomething:
		{
			int rand = seed % 9;
			if(rand == 8)
			{
				strcopy(buffer, length, "waitingsomebody");
			}
			else if(rand > 5)
			{
				Format(buffer, length, "readywhenyouare0%d", rand - 5);
			}
			else if(rand > 3)
			{
				Format(buffer, length, "letsgo0%d", rand - 3);
			}
			else if(rand > 1)
			{
				Format(buffer, length, "leadtheway0%d", rand - 1);
			}
			else if(rand == 1)
			{
				strcopy(buffer, length, "doingsomething");
			}
			else
			{
				strcopy(buffer, length, "getgoingsoon");
			}
		}
		case Cit_NewWeapon:
		{
			int rand = seed % 3;
			if(rand == 2)
			{
				strcopy(buffer, length, "yeah02");
			}
			else if(rand == 1)
			{
				strcopy(buffer, length, "thislldonicely01");
			}
			else
			{
				strcopy(buffer, length, "evenodds");
			}
		}
		case Cit_CadeDeath:
		{
			int rand = seed % 5;
			if(rand == 4)
			{
				strcopy(buffer, length, "strider_run");
			}
			else if(rand == 3)
			{
				strcopy(buffer, length, "gethellout");
			}
			else
			{
				Format(buffer, length, "runforyourlife0%d", rand + 1);
			}
		}
		case Cit_AllyDeathQuestion:
		{
			int rand = seed % 8;
			if(rand == 7)
			{
				// 7 -> 17
				rand = 17;
			}
			else if(rand == 6)
			{
				// 6 -> 14
				rand = 14;
			}
			else if(rand > 3)
			{
				// 4/5 -> 10/11
				rand += 6;
			}
			else if(rand > 1)
			{
				// 2/3 -> 6/7
				rand += 4;
			}
			else
			{
				// 0/1 -> 1/2
				rand++;
			}
			
			Format(buffer, length, "gordead_ques%002d", rand);
		}
		case Cit_AllyDeathAnswer:
		{
			Format(buffer, length, "gordead_ans%002d", 1 + (seed % 19));
		}
		case Cit_FirstBlood:
		{
			int rand = seed % 3;
			if(rand == 2)
			{
				strcopy(buffer, length, "oneforme");
			}
			else
			{
				Format(buffer, length, "gotone0%d", rand + 1);
			}
		}
		case Cit_Reload:
		{
			strcopy(buffer, length, "gottareload01");
		}
		case Cit_Headcrab:
		{
			int rand = seed % 4;
			if(rand > 1)
			{
				Format(buffer, length, "headcrabs0%d", rand - 1);
			}
			else
			{
				Format(buffer, length, "zombies0%d", rand + 1);
			}
		}
		case Cit_MiniBoss:
		{
			int rand = seed % 5;
			if(rand == 4)
			{
				strcopy(buffer, length, "uhoh");
			}
			else if(rand == 3)
			{
				strcopy(buffer, length, "ohno");
			}
			else if(rand == 2)
			{
				strcopy(buffer, length, "incoming02");
			}
			else
			{
				Format(buffer, length, "headsup0%d", 1 + (seed % 2));
			}
		}
		case Cit_Healer:
		{
			Format(buffer, length, "health0%d", 1 + (seed % 5));
		}
		case Cit_Lost:
		{
			int rand = seed % 2;
			if(rand == 1)
			{
				strcopy(buffer, length, "help01");
			}
			else
			{
				strcopy(buffer, length, "overhere01");
			}
		}
		case Cit_Greet:
		{
			int rand = seed % 5;
			if(rand == 4)
			{
				strcopy(buffer, length, "nice");
			}
			else if(rand > 1)
			{
				Format(buffer, length, "heydoc0%d", rand - 1);
			}
			else
			{
				Format(buffer, length, "hi0%d", rand + 1);
			}
		}
		case Cit_MiniBossDead:
		{
			strcopy(buffer, length, "likethat");
		}
		case Cit_LowHealth:
		{
			int rand = seed % 9;
			if(rand > 3)
			{
				Format(buffer, length, "moan0%d", rand - 3);
			}
			else if(rand > 1)
			{
				Format(buffer, length, "imhurt0%d", rand - 1);
			}
			else
			{
				Format(buffer, length, "hitingut0%d", rand + 1);
			}
		}
		case Cit_Staying:
		{
			int rand = seed % 5;
			if(rand == 4)
			{
				strcopy(buffer, length, "littlecorner01");
			}
			else if(rand == 3)
			{
				strcopy(buffer, length, "imstickinghere01");
			}
			else if(rand == 2)
			{
				strcopy(buffer, length, "illstayhere01");
			}
			else
			{
				Format(buffer, length, "holddownspot0%d", rand + 1);
			}
		}
		case Cit_Found:
		{
			int rand = seed % 7;
			if(rand == 6)
			{
				strcopy(buffer, length, "yougotit02");
			}
			else if(rand == 5)
			{
				strcopy(buffer, length, "squad_reinforce_single04");
			}
			else if(rand > 1)
			{
				Format(buffer, length, "okimready0%d", rand - 1);
			}
			else
			{
				Format(buffer, length, "ok0%d", rand + 1);
			}
		}
		case Cit_Hurt:
		{
			int rand = seed % 11;
			if(rand > 1)
			{
				Format(buffer, length, "pain0%d", rand - 1);
			}
			else
			{
				Format(buffer, length, "ow0%d", rand + 1);
			}
		}
		case Cit_Question:
		{
			int rand = seed % 30;
			if(rand > 23)
			{
				rand += 2;
			}
			else
			{
				rand++;
			}
			
			Format(buffer, length, "question%002d", rand);
		}
	}
	
	Format(buffer, length, "vo/npc/%s/%s.wav", female ? "female01" : "male01", buffer);
	PrecacheSound(buffer);
}

static char g_RangedAttackSounds[][] =
{
	"weapons/shotgun/shotgun_fire6.wav",
	"weapons/shotgun/shotgun_fire7.wav",
};

static char g_RangedReloadSound[][] =
{
	"weapons/shotgun/shotgun_reload1.wav",
	"weapons/shotgun/shotgun_reload2.wav",
	"weapons/shotgun/shotgun_reload3.wav",
};

void Citizen_OnMapStart()
{
	char buffer[PLATFORM_MAX_PATH];
	for(int i; i < Cit_MAX; i++)
	{
		for(int a; a < 39; a++)
		{
			Citizen_GenerateSound(i, a, false, buffer, sizeof(buffer));
			PrecacheSound(buffer);
			
			Citizen_GenerateSound(i, a, true, buffer, sizeof(buffer));
			PrecacheSound(buffer);
		}
	}
	
	for(int i; i < 9; i++)
	{
		for(int a = 1; a <= Cit_Medic; a++)
		{
			Citizen_GenerateModel(i, false, a, buffer, sizeof(buffer));
			PrecacheModel(buffer);
			
			Citizen_GenerateModel(i, true, a, buffer, sizeof(buffer));
			PrecacheModel(buffer);
		}
	}
	
	PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav");
}

static int ThereCanBeOnlyOne = -1;
static bool FirstBlood[MAXENTITIES];
static bool IsDowned[MAXENTITIES];
static int ReviveTime[MAXENTITIES];
static int GunType[MAXENTITIES];
static int GunValue[MAXENTITIES];
static int PerkType[MAXENTITIES];
static float GunDamage[MAXENTITIES];
static float GunFireRate[MAXENTITIES];
static float GunReload[MAXENTITIES];
static int GunClip[MAXENTITIES];
static float TalkCooldown[MAXENTITIES];
static float TalkTurnPos[MAXENTITIES][3];
static float TalkTurningFor[MAXENTITIES];

methodmap Citizen < CClotBody
{
	public Citizen(int client, float vecPos[3], float vecAng[3])
	{
		if(IsValidEntity(EntRefToEntIndex(ThereCanBeOnlyOne)))
			return view_as<Citizen>(-1);
		
		int seed = GetURandomInt();
		bool female = !(seed % 2);
		
		char buffer[PLATFORM_MAX_PATH];
		Citizen_GenerateModel(seed, female, Cit_Unarmed, buffer, sizeof(buffer));
		
		Citizen npc = view_as<Citizen>(CClotBody(vecPos, vecAng, buffer, "1.15", "200", true, true));
		i_NpcInternalId[npc.index] = CITIZEN;
		
		npc.m_iState = -1;
		npc.SetActivity("ACT_BUSY_SIT_GROUND");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;	
		
		SetEntProp(npc.index, Prop_Send, "m_iTeamNum", TFTeam_Red);
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Citizen_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Citizen_ClotThink);
		
		npc.m_iSeed = seed;
		
		npc.m_bDowned = true;
		npc.m_bThisEntityIgnored = true;
		npc.m_iReviveTicks = 0;
		npc.m_bFirstBlood = false;
		npc.m_iGunType = Cit_None;
		npc.m_iGunValue = 0;
		npc.m_iBuildingType = -1;
		npc.m_iWearable1 = -1;
		npc.m_iWearable2 = -1;
		npc.m_iWearable3 = -1;
		npc.m_b_stand_still = false;
		
		npc.m_iAttacksTillReload = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_flSpeed = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flidle_talk = FAR_FUTURE;
		return npc;
	}
	
	property int m_iSeed
	{
		public get()		{ return i_OverlordComboAttack[this.index]; }
		public set(int value) 	{ i_OverlordComboAttack[this.index] = value; }
	}
	property bool m_bFemale
	{
		public get()		{ return !(this.m_iSeed % 2); }
	}
	
	property bool m_bDowned
	{
		public get()		{ return IsDowned[this.index]; }
		public set(bool value) 	{ IsDowned[this.index] = value; }
	}
	property int m_iReviveTicks
	{
		public get()		{ return ReviveTime[this.index]; }
		public set(int value) 	{ ReviveTime[this.index] = value; }
	}
	property bool m_bFollowing
	{
		public get()		{ return this.m_b_follow; }
		public set(bool value) 	{ this.m_b_follow = value; }
	}
	property int m_iBuildingType
	{
		public get()		{ return PerkType[this.index]; }
		public set(int value) 	{ PerkType[this.index] = value; }
	}
	property int m_iGunType
	{
		public get()		{ return GunType[this.index]; }
		public set(int value) 	{ GunType[this.index] = value; }
	}
	property int m_iGunValue
	{
		public get()		{ return GunValue[this.index]; }
		public set(int value) 	{ GunValue[this.index] = value; }
	}
	property bool m_bFirstBlood
	{
		public get()		{ return FirstBlood[this.index]; }
		public set(bool value) 	{ FirstBlood[this.index] = value; }
	}
	property float m_fGunDamage
	{
		public get()		{ return GunDamage[this.index]; }
		public set(float value) 	{ GunDamage[this.index] = value; }
	}
	property float m_fGunFirerate
	{
		public get()		{ return GunFireRate[this.index]; }
		public set(float value) 	{ GunFireRate[this.index] = value; }
	}
	property float m_fGunReload
	{
		public get()		{ return GunReload[this.index]; }
		public set(float value) 	{ GunReload[this.index] = value; }
	}
	property float m_fTalkTimeIn
	{
		public get()		{ return TalkCooldown[this.index]; }
		public set(float value) 	{ TalkCooldown[this.index] = value; }
	}
	property int m_iGunClip
	{
		public get()		{ return GunClip[this.index]; }
		public set(int value) 	{ GunClip[this.index] = value; }
	}
	
	public void SlowTurn(const float pos[3])
	{
		TalkTurningFor[this.index] = GetGameTime() + 1.25;
		TalkTurnPos[this.index][0] = pos[0];
		TalkTurnPos[this.index][1] = pos[1];
		TalkTurnPos[this.index][2] = pos[2];
	}
	public void UpdateModel()
	{
		int type = Cit_Unarmed;
		
		if(this.m_iBuildingType == 7)
		{
			type = Cit_Medic;
		}
		else if(this.m_iGunType != Cit_None)
		{
			type = this.m_bCamo ? Cit_Camo : Cit_Normal;
		}
		
		char buffer[PLATFORM_MAX_PATH];
		Citizen_GenerateModel(this.m_iSeed, this.m_bFemale, type, buffer, sizeof(buffer));
	}
	public void SetActivity(const char[] animation)
	{
		int activity = this.LookupActivity(animation);
		if(activity > 0 && activity != this.m_iState)
		{
			this.m_iState = activity;
			this.m_bisWalking = false;
			this.StartActivity(activity);
		}
	}
	public void SetDowned(bool state)
	{
		this.m_bDowned = state;
		
		if(this.m_bDowned)
		{
			Change_Npc_Collision(this.index, 3);
			this.bCantCollidie = true;
			this.m_bThisEntityIgnored = true;
			this.m_iReviveTicks = 250;
			this.SetActivity("ACT_BUSY_SIT_GROUND");
			this.AddGesture("ACT_BUSY_SIT_GROUND_ENTRY");
			
			if(this.m_bPathing)
			{
				PF_StopPathing(this.index);
				this.m_bPathing = false;
			}
			
			if(this.m_iWearable1 > 0)
				AcceptEntityInput(this.m_iWearable1, "Disable");
			
			if(this.m_iWearable3 > 0)
				RemoveEntity(this.m_iWearable3);
			
			this.m_iWearable3 = TF2_CreateGlow(this.index);
			
			SetVariantColor(view_as<int>({0, 255, 0, 255}));
			AcceptEntityInput(this.m_iWearable3, "SetGlowColor");
			
			SetEntityRenderMode(this.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(this.index, 255, 255, 255, 125);
		}
		else
		{
			Change_Npc_Collision(this.index, 4);
			this.bCantCollidie = false;
			this.m_bThisEntityIgnored = false;
			this.SetActivity("ACT_BUSY_SIT_GROUND_EXIT");
			this.m_flReloadDelay = GetGameTime() + 2.4;
			
			if(this.m_iWearable1 > 0)
				AcceptEntityInput(this.m_iWearable1, "Enable");
			
			if(this.m_iWearable3 > 0)
			{
				RemoveEntity(this.m_iWearable3);
				this.m_iWearable3 = -1;
				
				SetEntProp(this.index, Prop_Data, "m_iHealth", 50);
				SetEntityRenderColor(this.index, 255, 255, 255, 255);
				SetEntityRenderMode(this.index, RENDER_NORMAL);
			}
			else
			{
				this.PlaySound(Cit_Found);
			}
		}
	}
	public bool CanTalk()
	{
		return this.m_fTalkTimeIn < GetGameTime();
	}
	public void PlaySound(int type)
	{
		float gameTime = GetGameTime();
		if(this.m_fTalkTimeIn < gameTime)
		{
			this.m_fTalkTimeIn = gameTime + 3.0;
			
			char buffer[PLATFORM_MAX_PATH];
			Citizen_GenerateSound(type, GetURandomInt(), this.m_bFemale, buffer, sizeof(buffer));
			EmitSoundToAll(buffer, this.index, SNDCHAN_VOICE, 95, _, 1.0);
		}
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll("weapons/iceaxe/iceaxe_swing1.wav", this.index, _, 80, _, 1.0);
	}
	public void PlayPistolSound()
	{
		EmitSoundToAll("weapons/pistol/pistol_fire2.wav", this.index, _, 80, _, 0.7);
	}
	public void PlayPistolReloadSound()
	{
		EmitSoundToAll("weapons/pistol/pistol_reload1.wav", this.index, _, 80, _, 1.0);
	}
	public void PlaySMGSound()
	{
		EmitSoundToAll("weapons/smg1/smg1_fire1.wav", this.index, _, 80, _, 0.7);
	}
	public void PlaySMGReloadSound()
	{
		EmitSoundToAll("weapons/smg1/smg1_reload.wav", this.index, _, 80, _, 1.0);
	}
	public void PlayShotgunSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, 80, _, 0.7);
	}
	public void PlayShotgunReloadSound()
	{
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, 80, _, 1.0);
	}
	public void PlayARSound()
	{
		EmitSoundToAll("weapons/ar2/fire1.wav", this.index, _, 80, _, 0.7);
	}
	public void PlayARReloadSound()
	{
		EmitSoundToAll("weapons/ar2/npc_ar2_reload.wav", this.index, _, 80, _, 1.0);
	}
	public void PlayRPGSound()
	{
		EmitSoundToAll("weapons/rpg/rocketfire1.wav", this.index, _, 80, _, 1.0);
	}
}

bool Citizen_ThatIsDowned(int entity)
{
	return (i_NpcInternalId[entity] == CITIZEN && view_as<Citizen>(entity).m_bDowned);
}

int Citizen_ReviveTicks(int entity, int amount)
{
	Citizen npc = view_as<Citizen>(entity);
	npc.m_iReviveTicks -= amount;
	if(npc.m_iReviveTicks < 1)
		npc.SetDowned(false);
	
	return npc.m_iReviveTicks;
}

int Citizen_ShowInteractionHud(int entity, int client)
{
	if(i_NpcInternalId[entity] == CITIZEN)
	{
		Citizen npc = view_as<Citizen>(entity);
		
		if(npc.m_bDowned)
		{
			SetGlobalTransTarget(client);
			PrintCenterText(client, "%t", "Revive Teammate tooltip");
			return -1;
		}
	
		return npc.m_iBuildingType;
	}
	return 0;
}

int Citizen_BuildingInteract(int entity)
{
	if(i_NpcInternalId[entity] == CITIZEN)
	{
		Citizen npc = view_as<Citizen>(entity);
		
		if(npc.m_bDowned)
			return 0;
		
		return npc.m_iBuildingType;
	}
	return 0;
}

bool Citizen_Interact(int client, int entity)
{
	//PrintToChatAll("Citizen_Interact %d", i_NpcInternalId[entity]);
	if(i_NpcInternalId[entity] == CITIZEN)
	{
		//PrintToChatAll("Found");
		Citizen npc = view_as<Citizen>(entity);
		
		if(npc.m_bDowned)
			return false;
	
		npc.PlaySound(Cit_Greet);
		Store_OpenGiftStore(client, npc.index, npc.m_iGunValue);
		return true;
	}
	return false;
}

bool Citizen_GivePerk(int entity, int type)
{
	Citizen npc = view_as<Citizen>(entity);
	
	if(npc.m_iBuildingType == type)
		return false;
	
	npc.m_iBuildingType = type;
	npc.m_bCamo = npc.m_iBuildingType == 0;
	
	npc.m_flReloadDelay = GetGameTime() + 1.0;
	npc.UpdateModel();
	
	npc.SetActivity("ACT_PICKUP_RACK");
	npc.m_flSpeed = 0.0;
	
	if(npc.m_iWearable2 > 0)
		RemoveEntity(npc.m_iWearable2);
	
	float flPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
	flPos[2] += 100.0;
	
	switch(npc.m_iBuildingType)
	{
		case 1:
		{
			npc.m_iWearable2 = ParticleEffectAt_Building_Custom(flPos, "powerup_icon_resist", npc.index);
		}
		case 2:
		{
			npc.m_iWearable2 = ParticleEffectAt_Building_Custom(flPos, "powerup_icon_regen", npc.index);
		}
		case 5:
		{
			npc.m_iWearable2 = ParticleEffectAt_Building_Custom(flPos, "powerup_icon_king", npc.index);
		}
		case 6:
		{
			npc.m_iWearable2 = ParticleEffectAt_Building_Custom(flPos, "powerup_icon_knockout", npc.index); //ze pap :)
		}
		case 7:
		{
			npc.m_iWearable2 = ParticleEffectAt_Building_Custom(flPos, "powerup_icon_vampire", npc.index); //ze healing station
		}
		default:
		{
			npc.m_iWearable2 = -1;
		}
	}
	return true;
}

bool Citizen_UpdateWeaponStats(int entity, int type, int sell, const ItemInfo info)
{
	Citizen npc = view_as<Citizen>(entity);
	
	if(npc.m_bDowned)
		return false;
	
	if(type > 9)
		return Citizen_GivePerk(entity, type - 10);
	
	npc.m_iGunType = type;
	npc.m_iGunValue = sell;
	
	if(info.Attrib[0] == 99999)
	{
		ThereCanBeOnlyOne = EntIndexToEntRef(entity);
		
		int amount;
		
		for(int i = MaxClients + 1; i < MAXENTITIES; i++)
		{
			if(i_NpcInternalId[i] == CITIZEN && i != npc.index && IsValidEntity(i))
			{
				amount += view_as<Citizen>(i).m_iGunValue;
				if(view_as<Citizen>(i).m_iBuildingType)
					amount += 1000;
				
				SDKHooks_TakeDamage(i, 0, 0, 999999999.0, DMG_GENERIC);
			}
		}
		
		int health = 29000 + (amount / 15);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		
		npc.m_iGunValue += amount;
		npc.m_fGunDamage = 3000.0 + (float(amount) / 10.0);
		npc.m_fGunFirerate = 0.0;
		npc.m_fGunReload = 0.0;
		npc.m_iGunClip = -1;
	}
	else
	{
		int health = 200 + npc.m_iGunValue / 20;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		
		WeaponData data;
		if(Config_CreateNPCStats(info.Classname, info.Attrib, info.Value, info.Attribs, data))
		{
			npc.m_fGunDamage = data.Damage * data.Pellets;
			npc.m_fGunFirerate = data.FireRate;
			npc.m_fGunReload = data.Reload;
			npc.m_iGunClip = RoundFloat(data.Clip);
		}
	}
	
	npc.m_iAttacksTillReload = npc.m_iGunClip;
	npc.m_bFirstBlood = false;
	npc.m_flReloadDelay = GetGameTime() + 1.0;
	
	npc.UpdateModel();
	npc.PlaySound(Cit_NewWeapon);
	
	npc.SetActivity("ACT_PICKUP_RACK");
	npc.m_flSpeed = 0.0;
	
	if(npc.m_iWearable1 > 0)
		RemoveEntity(npc.m_iWearable1);
	
	if(info.Attrib[0] == 99999)
	{
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_crowbar.mdl");
		ParticleEffectAt_Parent(WorldSpaceCenter(npc.index), "raygun_projectile_red_crit", npc.index, "anim_attachment_RH");
	}
	else
	{
		switch(npc.m_iGunType)
		{
			case Cit_Melee:
			{
				npc.m_iAttacksTillReload = -1;
				npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_crowbar.mdl");
			}
			case Cit_Pistol:
			{
				npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
			}
			case Cit_SMG:
			{
				npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_smg1.mdl");
			}
			case Cit_Shotgun:
			{
				npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_shotgun.mdl");
			}
			case Cit_AR:
			{
				npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
			}
			case Cit_RPG:
			{
				npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_rocket_launcher.mdl");
			}
			default:
			{
				npc.m_iWearable1 = -1;
			}
		}
	}
	return true;
}

public void Citizen_ClotThink(int iNPC)
{
	Citizen npc = view_as<Citizen>(iNPC);
	
	float gameTime = GetGameTime();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_bDowned)
	{
		//PrintCenterTextAll("CIV: Downed");
		if(npc.m_flidle_talk == FAR_FUTURE)
		{
			npc.m_flidle_talk = gameTime + 30.0 + (float(npc.m_iSeed) / 214748364.7);
		}
		else if(npc.m_flidle_talk < gameTime)
		{
			npc.PlaySound(Cit_Lost);
			npc.m_flidle_talk = FAR_FUTURE;
		}
		return;
	}
	
	if(npc.m_flAttackHappens)
	{
		//PrintCenterTextAll("CIV: Throwing Melee");
		if(npc.m_iGunType != Cit_Melee)
		{
			npc.m_flAttackHappens = 0.0;
		}
		else if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget, npc.m_bCamo))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 2))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, npc.m_fGunDamage, DMG_CLUB);
						
						// Hit particle
						npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", vecHit, NULL_VECTOR, NULL_VECTOR);
						
						//Did we kill them?
						if(GetEntProp(target, Prop_Data, "m_iHealth") < 1)
						{
							if(!npc.m_bFirstBlood && npc.CanTalk())
							{
								npc.m_bFirstBlood = true;
								npc.PlaySound(Cit_FirstBlood);
							}
							
							int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
							int health = GetEntProp(npc.index, Prop_Data, "m_iHealth") + (maxhealth / 50);
							if(health > maxhealth)
								health = maxhealth;
							
							SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
						}
					}
				}
				delete swingTrace;
			}
			return;
		}
		else
		{
			return;
		}
	}
	
	if(npc.m_flReloadDelay > gameTime)
	{
		//PrintCenterTextAll("CIV: Reloading");
		if(npc.m_bPathing)
		{
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
		}
		return;
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_bGetClosestTargetTimeAlly = false;
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		if(npc.m_iGunType != Cit_None)
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _, 1000.0, npc.m_bCamo);
			if(npc.m_iTarget > 0 && npc.m_bCamo)
				npc.PlaySound(Cit_Behind);
		}
	}
	
	bool moveBack = true;
	bool wantReload = npc.m_iAttacksTillReload == 0;
	if(npc.m_iTarget > 0)
	{
		//PrintCenterTextAll("CIV: Attacking");
		npc.m_flidle_talk = FAR_FUTURE;
		moveBack = false;
		wantReload = false;
		
		if(npc.m_iGunType == Cit_None || !IsValidEnemy(npc.index, npc.m_iTarget, npc.m_bCamo))
		{
			//Stop chasing dead target.
			npc.m_iTarget = 0;
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
		}
		else
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			
			bool moveUp;
			float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(i_NpcInternalId[npc.m_iTarget] == SAWRUNNER && view_as<SawRunner>(npc.m_iTarget).m_iTarget == npc.index && distance < 250000.0)
			{
				moveBack = true;
				
				npc.SetActivity("ACT_RUN_PANICKED");
				npc.m_flSpeed = 260.0;
				
				if(npc.m_flNextMeleeAttack < gameTime)
				{
					npc.PlaySound(Cit_CadeDeath);
					npc.m_flNextMeleeAttack = gameTime + 10.0;
				}
			}
			else
			{
				switch(npc.m_iGunType)
				{
					case Cit_Melee:
					{
						if(distance < 14500.0 && npc.m_flNextMeleeAttack < gameTime)
						{
							//Look at target so we hit.
							npc.FaceTowards(vecTarget, 1500.0);
							
							npc.SetActivity("ACT_MELEE_ANGRY_MELEE");
							npc.m_flSpeed = 0.0;
							
							npc.AddGesture("ACT_MELEE_ATTACK_SWING");
							
							npc.PlayMeleeSound();
							
							npc.m_flAttackHappens = gameTime + 0.2;
							npc.m_flReloadDelay = gameTime + 0.45;
							npc.m_flNextMeleeAttack = gameTime + npc.m_fGunFirerate;
							
							if(npc.m_flReloadDelay > npc.m_flNextMeleeAttack)
								npc.m_flReloadDelay = npc.m_flNextMeleeAttack;
							
							if(npc.m_flAttackHappens > npc.m_flNextMeleeAttack)
								npc.m_flAttackHappens = npc.m_flNextMeleeAttack;
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Enable");
						}
						else if(distance < 160000.0)
						{
							npc.SetActivity("ACT_RUN_CROUCH");
							npc.m_flSpeed = 240.0;
							moveUp = true;
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Enable");
						}
						else
						{
							npc.SetActivity("ACT_RUN");
							npc.m_flSpeed = 240.0;
							moveBack = true;
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Disable");
						}
					}
					case Cit_Pistol:
					{
						if(distance > 22500.0 && distance < 1000000.0 && npc.m_iAttacksTillReload != 0)
						{
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Enable");
							
							npc.SetActivity("ACT_RANGE_ATTACK_PISTOL");
							npc.m_flSpeed = 0.0;
							
							if(npc.m_flNextRangedAttack < gameTime)
							{
								float vecSpread = 0.1;
								
								float npc_pos[3];
								npc_pos = GetAbsOrigin(npc.index);
									
								npc_pos[2] += 30.0;
									
								float eyePitch[3];
								GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
								
								float x, y;
								x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								
								float vecDirShooting[3], vecRight[3], vecUp[3];
								
								vecTarget[2] += 15.0;
								MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
								GetVectorAngles(vecDirShooting, vecDirShooting);
								vecDirShooting[1] = eyePitch[1];
								GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
								
								float m_vecSrc[3];
								
								m_vecSrc = npc_pos;
								
								float vecEnd[3];
								vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
								vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
								vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
								
								//add the spray
								float vecbro[3];
								vecbro[0] = vecDirShooting[0] + 0.0 * vecSpread * vecRight[0] + 0.0 * vecSpread * vecUp[0]; 
								vecbro[1] = vecDirShooting[1] + 0.0 * vecSpread * vecRight[1] + 0.0 * vecSpread * vecUp[1]; 
								vecbro[2] = vecDirShooting[2] + 0.0 * vecSpread * vecRight[2] + 0.0 * vecSpread * vecUp[2]; 
								NormalizeVector(vecbro, vecbro);
								
								npc.FaceTowards(vecTarget, 1000.0);
								npc.m_flNextRangedAttack = gameTime + npc.m_fGunFirerate;
								npc.m_iAttacksTillReload--;
								
								//add the spray
								float vecDir[3];
								vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
								vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
								vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
								NormalizeVector(vecDir, vecDir);
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_BULLET, "bullet_tracer01_red", npc.index, _ , "muzzle");
								npc.PlayPistolSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
						}
						else if(distance > 22500.0 && npc.m_flNextRangedAttack < gameTime && npc.m_iAttacksTillReload == 0)
						{
							wantReload = true;
						}
						else
						{
							npc.SetActivity("ACT_RUN");
							npc.m_flSpeed = 240.0;
							moveBack = true;
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Disable");
						}
					}
					case Cit_SMG:
					{
						if(distance < 600000.0 && npc.m_iAttacksTillReload != 0)	// Attack at 800 HU
						{
							if(distance < 150000.0)	// Walk backwards at 400 HU
							{
								npc.SetActivity("ACT_WALK_AIM_RIFLE");
								npc.m_flSpeed = 90.0;
								moveBack = true;
							}
							else
							{
								npc.SetActivity((npc.m_iSeed % 4) ? "ACT_IDLE_ANGRY_SMG1" : "ACT_IDLE_AIM_RIFLE_STIMULATED");
								npc.m_flSpeed = 0.0;
							}
							
							if(npc.m_flNextRangedAttack < gameTime)
							{
								npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
								
								float vecSpread = 0.1;
								
								float npc_pos[3];
								npc_pos = GetAbsOrigin(npc.index);
									
								npc_pos[2] += 30.0;
									
								float eyePitch[3];
								GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
								
								float x, y;
								x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								
								float vecDirShooting[3], vecRight[3], vecUp[3];
								
								vecTarget[2] += 15.0;
								MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
								GetVectorAngles(vecDirShooting, vecDirShooting);
								vecDirShooting[1] = eyePitch[1];
								GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
								
								float m_vecSrc[3];
								
								m_vecSrc = npc_pos;
								
								float vecEnd[3];
								vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
								vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
								vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
								
								//add the spray
								float vecbro[3];
								vecbro[0] = vecDirShooting[0] + 0.0 * vecSpread * vecRight[0] + 0.0 * vecSpread * vecUp[0]; 
								vecbro[1] = vecDirShooting[1] + 0.0 * vecSpread * vecRight[1] + 0.0 * vecSpread * vecUp[1]; 
								vecbro[2] = vecDirShooting[2] + 0.0 * vecSpread * vecRight[2] + 0.0 * vecSpread * vecUp[2]; 
								NormalizeVector(vecbro, vecbro);
								
								npc.FaceTowards(vecTarget, 1000.0);
								npc.m_flNextRangedAttack = gameTime + npc.m_fGunFirerate;
								npc.m_iAttacksTillReload--;
								
								//add the spray
								float vecDir[3];
								vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
								vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
								vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
								NormalizeVector(vecDir, vecDir);
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_BULLET, "bullet_tracer01_red", npc.index, _ , "muzzle");
								npc.PlaySMGSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
						}
						else
						{
							if(distance < 250000.0)
							{
								npc.SetActivity("ACT_WALK_AIM_RIFLE");
								npc.m_flSpeed = 90.0;
								moveBack = true;
							}
							else
							{
								npc.SetActivity((npc.m_iSeed % 4) ? "ACT_IDLE_ANGRY_SMG1" : "ACT_IDLE_AIM_RIFLE_STIMULATED");
								npc.m_flSpeed = 0.0;
							}
							
							if(npc.m_flNextRangedAttack < gameTime && npc.m_iAttacksTillReload == 0)
								wantReload = true;
						}
					}
					case Cit_AR:
					{
						if(distance < 800000.0 && npc.m_iAttacksTillReload != 0)	// Attack at 900 HU
						{
							if(distance < 150000.0)	// Walk backwards at 400 HU
							{
								npc.SetActivity("ACT_WALK_AIM_AR2");
								npc.m_flSpeed = 90.0;
								moveBack = true;
							}
							else
							{
								npc.SetActivity("ACT_IDLE_ANGRY_AR2");
								npc.m_flSpeed = 0.0;
							}
							
							if(npc.m_flNextRangedAttack < gameTime)
							{
								npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
								
								float vecSpread = 0.1;
								
								float npc_pos[3];
								npc_pos = GetAbsOrigin(npc.index);
									
								npc_pos[2] += 30.0;
									
								float eyePitch[3];
								GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
								
								float x, y;
								x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								
								float vecDirShooting[3], vecRight[3], vecUp[3];
								
								vecTarget[2] += 15.0;
								MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
								GetVectorAngles(vecDirShooting, vecDirShooting);
								vecDirShooting[1] = eyePitch[1];
								GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
								
								float m_vecSrc[3];
								
								m_vecSrc = npc_pos;
								
								float vecEnd[3];
								vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
								vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
								vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
								
								//add the spray
								float vecbro[3];
								vecbro[0] = vecDirShooting[0] + 0.0 * vecSpread * vecRight[0] + 0.0 * vecSpread * vecUp[0]; 
								vecbro[1] = vecDirShooting[1] + 0.0 * vecSpread * vecRight[1] + 0.0 * vecSpread * vecUp[1]; 
								vecbro[2] = vecDirShooting[2] + 0.0 * vecSpread * vecRight[2] + 0.0 * vecSpread * vecUp[2]; 
								NormalizeVector(vecbro, vecbro);
								
								npc.FaceTowards(vecTarget, 1000.0);
								npc.m_flNextRangedAttack = gameTime + npc.m_fGunFirerate;
								npc.m_iAttacksTillReload--;
								
								//add the spray
								float vecDir[3];
								vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
								vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
								vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
								NormalizeVector(vecDir, vecDir);
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_BULLET, "bullet_tracer01_red", npc.index, _ , "muzzle");
								npc.PlayARSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
						}
						else
						{
							if(distance < 250000.0)
							{
								npc.SetActivity("ACT_WALK_AIM_RIFLE");
								npc.m_flSpeed = 90.0;
								moveBack = true;
							}
							
							if(npc.m_flNextRangedAttack < gameTime && npc.m_iAttacksTillReload == 0)
								wantReload = true;
						}
					}
					case Cit_Shotgun:
					{
						if(distance < 125000.0 && npc.m_iAttacksTillReload != 0)	// Attack at 350 HU
						{
							npc.SetActivity("ACT_IDLE_ANGRY_AR2");
							npc.m_flSpeed = 0.0;
							
							if(npc.m_flNextRangedAttack < gameTime)
							{
								npc.AddGesture("ACT_RANGE_ATTACK_SHOTGUN");
								
								float vecSpread = 0.1;
								
								float npc_pos[3];
								npc_pos = GetAbsOrigin(npc.index);
									
								npc_pos[2] += 30.0;
									
								float eyePitch[3];
								GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
								
								float x, y;
								x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
								
								float vecDirShooting[3], vecRight[3], vecUp[3];
								
								vecTarget[2] += 15.0;
								MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
								GetVectorAngles(vecDirShooting, vecDirShooting);
								vecDirShooting[1] = eyePitch[1];
								GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
								
								float m_vecSrc[3];
								
								m_vecSrc = npc_pos;
								
								float vecEnd[3];
								vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
								vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
								vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
								
								//add the spray
								float vecbro[3];
								vecbro[0] = vecDirShooting[0] + 0.0 * vecSpread * vecRight[0] + 0.0 * vecSpread * vecUp[0]; 
								vecbro[1] = vecDirShooting[1] + 0.0 * vecSpread * vecRight[1] + 0.0 * vecSpread * vecUp[1]; 
								vecbro[2] = vecDirShooting[2] + 0.0 * vecSpread * vecRight[2] + 0.0 * vecSpread * vecUp[2]; 
								NormalizeVector(vecbro, vecbro);
								
								npc.FaceTowards(vecTarget, 1000.0);
								npc.m_flNextRangedAttack = gameTime + npc.m_fGunFirerate;
								npc.m_iAttacksTillReload--;
								
								//add the spray
								float vecDir[3];
								vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
								vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
								vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
								NormalizeVector(vecDir, vecDir);
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_BULLET, "bullet_tracer01_red", npc.index, _ , "muzzle");
								npc.PlayShotgunSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
						}
						else if(npc.m_iAttacksTillReload == 0 && npc.m_flNextRangedAttack < gameTime)
						{
							if(distance < 40000.0)
							{
								npc.SetActivity("ACT_RUN_AR2");
								npc.m_flSpeed = 210.0;
								moveBack = true;
							}
							else
							{
								wantReload = true;
							}
						}
						else
						{
							npc.SetActivity("ACT_IDLE_SHOTGUN_AGITATED");
							npc.m_flSpeed = 0.0;
						}
					}
					case Cit_RPG:
					{
						if(distance > 22500.0)
						{
							npc.SetActivity("ACT_IDLE_ANGRY_RPG");
							npc.m_flSpeed = 0.0;
							
							if(npc.m_flNextRangedAttack < gameTime)
							{
								if(npc.m_iAttacksTillReload == 0)
								{
									wantReload = true;
								}
								else
								{
									npc.FaceTowards(vecTarget, 1000.0);
									npc.m_flNextRangedAttack = gameTime + npc.m_fGunFirerate;
									npc.m_iAttacksTillReload--;
									
									npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_RPG");
									npc.FireRocket(vecTarget, npc.m_fGunDamage, 1100.0);
									npc.PlayRPGSound();
								}
							}
						}
						else
						{
							npc.SetActivity("ACT_RUN_RPG");
							npc.m_flSpeed = 240.0;
							moveBack = true;
						}
					}
				}
			}
			
			if(moveUp)
			{
				if(distance > 170.0)
				{
					PF_SetGoalEntity(npc.index, npc.m_iTarget);
				}
				else
				{
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
					PF_SetGoalVector(npc.index, vPredictedPos);
				}
			}
			else if(!moveBack)
			{
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}	
			}
		}
	}
	
	if(wantReload)
	{
		//PrintCenterTextAll("CIV: Wants to Reload");
		switch(npc.m_iGunType)
		{
			case Cit_Pistol:
			{
				npc.SetActivity("ACT_RELOAD_PISTOL");
				npc.m_flSpeed = 0.0;
				npc.m_iAttacksTillReload = npc.m_iGunClip;
				npc.m_flReloadDelay = gameTime + 1.4;
				npc.PlayPistolReloadSound();
				
				if(npc.m_iWearable1 > 0)
					AcceptEntityInput(npc.m_iWearable1, "Enable");
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				return;
			}
			case Cit_SMG:
			{
				npc.SetActivity("ACT_RELOAD_SMG1");
				npc.m_flSpeed = 0.0;
				npc.m_iAttacksTillReload = npc.m_iGunClip;
				npc.m_flReloadDelay = gameTime + 3.4;
				npc.PlaySMGReloadSound();
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				return;
			}
			case Cit_AR:
			{
				npc.SetActivity("ACT_RELOAD_AR2");
				npc.m_flSpeed = 0.0;
				npc.m_iAttacksTillReload = npc.m_iGunClip;
				npc.m_flReloadDelay = gameTime + 1.6;
				npc.PlayARReloadSound();
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				return;
			}
			case Cit_Shotgun:
			{
				npc.SetActivity("ACT_RELOAD_shotgun");
				npc.m_flSpeed = 0.0;
				npc.m_iAttacksTillReload = npc.m_iGunClip;
				npc.m_flReloadDelay = gameTime + 1.6;
				npc.PlayShotgunReloadSound();
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				return;
			}
			case Cit_RPG:
			{
				npc.SetActivity("ACT_IDLE_ANGRY_RPG");
				npc.m_flSpeed = 0.0;
				npc.m_flReloadDelay = gameTime + npc.m_fGunReload;
				npc.m_iAttacksTillReload = npc.m_iGunClip;
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				return;
			}
			default:
			{
				npc.m_iAttacksTillReload = -1;
			}
		}
	}
	else if(moveBack)
	{
		if(!npc.m_bGetClosestTargetTimeAlly)
		{
			npc.m_iTargetAlly = GetClosestAllyPlayer(npc.index);
			npc.m_bGetClosestTargetTimeAlly = true;
		}
		
		//PrintCenterTextAll("CIV: Moving Back %d", npc.m_iTargetAlly);
		
		if(npc.m_iTargetAlly > 0)
		{
			if(npc.m_iTarget > 0)
			{
				npc.StartPathing();
				PF_SetGoalEntity(npc.index, npc.m_iTargetAlly);
				return;
			}
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			bool combat = !Waves_InSetup();
			bool low = GetEntProp(npc.index, Prop_Data, "m_iHealth") < 200;
			
			if(distance > 100000.0 || (combat && distance > 20000.0))
			{
				npc.m_flidle_talk = FAR_FUTURE;
				
				switch(npc.m_iGunType)
				{
					case Cit_SMG:
					{
						npc.SetActivity(combat ? "ACT_RUN_RIFLE" : low ? "ACT_RUN_RIFLE_STIMULATED" : "ACT_RUN_RIFLE_RELAXED");
						npc.m_flSpeed = combat ? 210.0 : 240.0;
					}
					case Cit_AR, Cit_Shotgun:
					{
						npc.SetActivity(combat ? "ACT_RUN_AR2" : low ? "ACT_RUN_AR2_STIMULATED" : "ACT_RUN_AR2_RELAXED");
						npc.m_flSpeed = combat ? 210.0 : 240.0;
					}
					case Cit_RPG:
					{
						npc.SetActivity(combat ? "ACT_RUN_RPG" : "ACT_RUN_RPG_RELAXED");
						npc.m_flSpeed = 240.0;
					}
					default:
					{
						npc.SetActivity("ACT_RUN");
						npc.m_flSpeed = 240.0;
						
						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Disable");
					}
				}
				
				npc.StartPathing();
				PF_SetGoalVector(npc.index, vecTarget);
				return;
			}
			
			if(distance > 20000.0 || (combat && distance > (2500.0 + (float(npc.m_iSeed) / 2147483.647 * 2.0))))
			{
				switch(npc.m_iGunType)
				{
					case Cit_Melee:
					{
						npc.SetActivity("ACT_WALK_SUITCASE");
						npc.m_flSpeed = 90.0;
						
						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Enable");
					}
					case Cit_SMG:
					{
						npc.SetActivity(combat ? "ACT_WALK_RIFLE" : low ? "ACT_WALK_RIFLE_STIMULATED" : "ACT_WALK_RIFLE_RELAXED");
						npc.m_flSpeed = 90.0;
					}
					case Cit_AR, Cit_Shotgun:
					{
						npc.SetActivity(combat ? "ACT_WALK_AR2" : low ? "ACT_WALK_AR2_STIMULATED" : "ACT_WALK_AR2_RELAXED");
						npc.m_flSpeed = 90.0;
					}
					case Cit_RPG:
					{
						npc.SetActivity(combat ? "ACT_WALK_RPG" : "ACT_WALK_RPG_RELAXED");
						npc.m_flSpeed = 90.0;
					}
					default:
					{
						npc.SetActivity("ACT_WALK");
						npc.m_flSpeed = 90.0;
						
						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Disable");
					}
				}
				
				npc.StartPathing();
				PF_SetGoalVector(npc.index, vecTarget);
				return;
			}
		}
	}
	
	//PrintCenterTextAll("CIV: Idle");
	
	bool combat = !Waves_InSetup();
	bool low = GetEntProp(npc.index, Prop_Data, "m_iHealth") < 200;
	
	if(npc.m_flidle_talk == FAR_FUTURE)
		npc.m_flidle_talk = gameTime + 10.0 + (GetURandomFloat() * 10.0) + (float(npc.m_iSeed) / 214748364.7);
	
	switch(npc.m_iGunType)
	{
		case Cit_Melee:
		{
			npc.SetActivity(combat ? "ACT_IDLE_ANGRY_MELEE" : "ACT_IDLE_SUITCASE");
			npc.m_flSpeed = 0.0;
			
			if(npc.m_iWearable1 > 0)
				AcceptEntityInput(npc.m_iWearable1, "Enable");
		}
		case Cit_SMG:
		{
			npc.SetActivity(combat ? "ACT_IDLE_SMG1" : low ? "ACT_IDLE_SMG1_STIMULATED" : "ACT_IDLE_SMG1_RELAXED");
			npc.m_flSpeed = 0.0;
		}
		case Cit_AR:
		{
			npc.SetActivity(combat ? "ACT_IDLE_AR2" : low ? "ACT_IDLE_AR2_STIMULATED" : "ACT_IDLE_AR2_RELAXED");
			npc.m_flSpeed = 0.0;
		}
		case Cit_Shotgun:
		{
			npc.SetActivity(combat ? "ACT_IDLE_SHOTGUN_AGITATED" : low ? "ACT_IDLE_SHOTGUN_STIMULATED" : "ACT_IDLE_SHOTGUN_RELAXED");
			npc.m_flSpeed = 0.0;
		}
		case Cit_RPG:
		{
			npc.SetActivity(combat ? "ACT_IDLE_RPG" : "ACT_IDLE_RPG_RELAXED");
			npc.m_flSpeed = 0.0;
		}
		default:
		{
			npc.SetActivity(combat ? "ACT_IDLE_ANGRY" : "ACT_IDLE");
			npc.m_flSpeed = 0.0;
			
			if(npc.m_iWearable1 > 0)
				AcceptEntityInput(npc.m_iWearable1, "Disable");
		}
	}
	
	if(npc.m_flidle_talk < gameTime)
	{
		npc.m_flidle_talk = gameTime + 50.0;
		
		if(low)
		{
			npc.PlaySound(Cit_LowHealth);
		}
		else
		{
			int talkingTo;
			float distance = 60000.0;
			
			float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
			float vecTarget[3];
			for(int i = MaxClients + 1; i < MAXENTITIES; i++)
			{
				if(i_NpcInternalId[i] == CITIZEN && i != npc.index && view_as<Citizen>(i).m_flidle_talk != FAR_FUTURE && IsValidEntity(i))
				{
					vecTarget = WorldSpaceCenter(i);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < 60000.0)
					{
						view_as<Citizen>(i).m_flidle_talk += 15.0;
						
						if(!combat && dist < distance)
						{
							talkingTo = i;
							distance = dist;
						}
					}
				}
			}
			
			int client = GetClosestAllyPlayer(npc.index);
			if(client > 0)
			{
				vecTarget = WorldSpaceCenter(client);
				if(GetVectorDistance(vecTarget, vecMe, true) < distance)
					talkingTo = client
			}
			
			if(talkingTo)
			{
				if(talkingTo > MaxClients)
					vecTarget = WorldSpaceCenter(talkingTo);
				
				npc.SlowTurn(vecTarget);
				
				if(npc.m_iBuildingType == 7 && talkingTo <= MaxClients && GetClientHealth(talkingTo) < 100)
				{
					npc.PlaySound(Cit_Healer);
				}
				else if(npc.m_iBuildingType == 2 && talkingTo <= MaxClients)
				{
					npc.PlaySound(Cit_Ammo);
				}
				else if(combat)
				{
					npc.PlaySound(Cit_DoSomething);
				}
				else if(talkingTo <= MaxClients)
				{
					npc.PlaySound((npc.m_iSeed % 3) ? Cit_Answer : Cit_Question);
				}
				else
				{
					view_as<Citizen>(talkingTo).SlowTurn(vecMe);
					view_as<Citizen>(talkingTo).m_flidle_talk += 35.0;
					npc.PlaySound(Cit_Question);
					CreateTimer(3.0, Citizen_ReactionTimer, EntIndexToEntRef(talkingTo), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
	
	if(TalkTurningFor[npc.index] > gameTime)
		npc.FaceTowards(TalkTurnPos[npc.index], 300.0);
	
	if(npc.m_bPathing)
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
	}
}

void Citizen_LiveCitizenReaction(int entity)
{
	int talkingTo;
	float distance = 60000.0;
	
	float vecMe[3]; vecMe = WorldSpaceCenter(entity);
	float vecTarget[3];
	for(int i = MaxClients + 1; i < MAXENTITIES; i++)
	{
		if(i_NpcInternalId[i] == CITIZEN && i != entity && view_as<Citizen>(i).m_flidle_talk != FAR_FUTURE && IsValidEntity(i))
		{
			vecTarget = WorldSpaceCenter(i);
			float dist = GetVectorDistance(vecTarget, vecMe, true);
			if(dist < 60000.0)
			{
				view_as<Citizen>(i).m_flidle_talk += 15.0;
				
				if(dist < distance)
				{
					talkingTo = i;
					distance = dist;
				}
			}
		}
	}
	
	int client = GetClosestAllyPlayer(entity);
	if(client > 0)
	{
		vecTarget = WorldSpaceCenter(client);
		if(GetVectorDistance(vecTarget, vecMe, true) < distance)
			talkingTo = client
	}
	
	if(talkingTo)
	{
		if(talkingTo > MaxClients)
		{
			vecTarget = WorldSpaceCenter(talkingTo);
			view_as<Citizen>(talkingTo).SlowTurn(vecMe);
			view_as<Citizen>(talkingTo).m_flidle_talk += 35.0;
			CreateTimer(3.0, Citizen_ReactionTimer, EntIndexToEntRef(talkingTo), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Citizen_ReactionTimer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
		view_as<Citizen>(entity).PlaySound(Cit_Answer);
	
	return Plugin_Continue;
}

public Action Citizen_DeathTimer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != INVALID_ENT_REFERENCE)
		view_as<Citizen>(entity).PlaySound(Cit_AllyDeathAnswer);
	
	return Plugin_Continue;
}

void Citizen_PlayerDeath(int client)
{
	if(client && !Waves_InSetup())
	{
		int talker, talkingTo;
		float distance = 10000000.0;
		
		float vecMe[3]; vecMe = WorldSpaceCenter(client);
		float vecTarget[3];
		for(int i = MaxClients + 1; i < MAXENTITIES; i++)
		{
			if(i_NpcInternalId[i] == CITIZEN && view_as<Citizen>(i).m_flidle_talk != FAR_FUTURE && IsValidEntity(i))
			{
				vecTarget = WorldSpaceCenter(i);
				float dist = GetVectorDistance(vecTarget, vecMe, true);
				if(view_as<Citizen>(i).CanTalk() && dist < distance)
				{
					talkingTo = talker;
					talker = i;
					distance = dist;
				}
			}
		}
		
		if(talker)
		{
			view_as<Citizen>(talker).PlaySound(Cit_AllyDeathQuestion);
			if(talkingTo)
				CreateTimer(3.0, Citizen_DeathTimer, EntIndexToEntRef(talkingTo), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Citizen_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damage > 9999999.0)
		return Plugin_Continue;
	
	if(view_as<Citizen>(victim).m_bDowned || (attacker > 0 && GetEntProp(victim, Prop_Send, "m_iTeamNum") == GetEntProp(attacker, Prop_Send, "m_iTeamNum")))
		return Plugin_Handled;
	
	int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToFloor(damage);
	if(health < 1)
	{
		view_as<Citizen>(victim).SetDowned(true);
	}
	else
	{
		SetEntProp(victim, Prop_Data, "m_iHealth", health);
		view_as<Citizen>(victim).PlaySound(Cit_Hurt);
	}
	return Plugin_Handled;
}

public void Citizen_NPCDeath(int entity)
{
	Citizen npc = view_as<Citizen>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Citizen_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Citizen_ClotThink);
	
	PF_StopPathing(npc.index);
	npc.m_bPathing = false;
	
	SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC);
	
	if(npc.m_iWearable1 > 0 && IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(npc.m_iWearable2 > 0 && IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(npc.m_iWearable3 > 0 && IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
