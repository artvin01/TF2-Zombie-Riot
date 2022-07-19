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
	Cit_LowHealth,
	Cit_MiniBoss,
	Cit_MiniBossDead,
	Cit_NewWeapon,
	Cit_Question,
	Cit_Reload,
	Cit_ReloadCombat,
	Cit_Staying,
	Cit_Unarmed,
	Cit_MAX
}

enum
{
	Cit_Unarmed = 2,
	Cit_Normal,
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

static const int State_Downed = 0;
static const int State_Lost = -1;
static const int State_Idle = 0;
static const int State_Attacking = 1;

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
			int rand = seed % 4;
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
		case Cit_Unarmed:
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
		Citizen_GenerateModel(i, false, buffer, sizeof(buffer));
		PrecacheModel(buffer);
		
		Citizen_GenerateModel(i, true, buffer, sizeof(buffer));
		PrecacheModel(buffer);
	}
	
	PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav");
}

static bool IsFemale[MAXENTITIES];
static bool FirstBlood[MAXENTITIES];
static int GunType[MAXENTITIES];
static int EquippedGun[MAXENTITIES];
static int EquippedEntRef[MAXENTITIES];
static float GunDamage[MAXENTITIES];
static float GunFireRate[MAXENTITIES];

methodmap Citizen < CClotBody
{
	public Citizen(int client, float vecPos[3], float vecAng[3])
	{
		int seed = GetURandomInt();
		bool female = !(seed % 2);
	
		char buffer[PLATFORM_MAX_PATH];
		Citizen_GenerateModel(seed, female, buffer, sizeof(buffer));
		
		Citizen npc = view_as<Citizen>(CClotBody(vecPos, vecAng, buffer, "1.15", "500", true, true));
		i_NpcInternalId[npc.index] = CITIZEN;
		
		int iActivity = npc.LookupActivity("ACT_CROUCH_PANICKED");
		if(iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;	
		
		SetEntProp(npc.index, Prop_Send, "m_iTeamNum", TFTeam_Red);
		
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 500);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 500);
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Citizen_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Citizen_ClotThink);
		
		npc.m_bFemale = female;
		npc.m_iSeed = seed;
		
		npc.m_bFirstBlood = false;
		npc.m_iEquipped = -1;
		npc.m_iWearable1 = -1;
		npc.m_bFollowing = false;
		
		npc.m_fbGunout = false;
		npc.m_bReloaded = true;
		npc.m_iAttacksTillReload = 24;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.m_bmovedelay_walk = false;
		npc.m_bmovedelay = false;
		npc.m_bmovedelay_run = false;
		
		npc.m_iMedkitAnnoyance = 0;
		
		npc.m_iState = State_Lost;
		npc.m_flSpeed = 180.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		
		return npc;
	}
	
	property int m_iSeed
	{
		public get()		{ return i_OverlordComboAttack[this.index]; }
		public set(int value) 	{ i_OverlordComboAttack[this.index] = value; }
	}
	property bool m_bFemale
	{
		public get()		{ return IsFemale[this.index]; }
		public set(int value) 	{ IsFemale[this.index] = value; }
	}
	
	property bool m_bFollowing
	{
		public get()		{ return this.m_b_follow; }
		public set(int value) 	{ this.m_b_follow = value; }
	}
	property int m_iEquipped
	{
		public get()		{ return EquippedGun[this.index]; }
		public set(int value) 	{ EquippedGun[this.index] = value; }
	}
	property int m_iEquippedEntRef
	{
		public get()		{ return EquippedEntRef[this.index]; }
		public set(int value) 	{ EquippedEntRef[this.index] = value; }
	}
	property int m_iGunType
	{
		public get()		{ return GunType[this.index]; }
		public set(int value) 	{ GunType[this.index] = value; }
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
	property int m_iGunClip
	{
		public get()		{ return GunClip[this.index]; }
		public set(int value) 	{ GunClip[this.index] = value; }
	}
	
	public void PlaySound(int type)
	{
		char buffer[PLATFORM_MAX_PATH];
		Citizen_GenerateSound(type, GetURandomInt(), this.m_bFemale, buffer, sizeof(buffer));
		EmitSoundToAll(buffer, this.index, SNDCHAN_VOICE, 95, _, 1.0);
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
	public void PlaySMGReloadSound()
	{
		EmitSoundToAll("weapons/ar2/npc_ar2_reload.wav", this.index, _, 80, _, 1.0);
	}
	public void PlayRPGSound()
	{
		EmitSoundToAll("weapons/rpg/rocketfire1.wav", this.index, _, 80, _, 1.0);
	}
}

void Citizen_UpdateWeaponStats(int entity, int type, const ItemInfo info)
{
	Citizen npc = view_as<Citizen>(entity);
	
	if(npc.m_iWearable1 > 0)
		RemoveEntity(npc.m_iWearable1);
	
	npc.m_iGunType = type;
	
	WeaponData data;
	if(Config_CreateNPCStats(info.Classname, info.Attrib, info.Value, info.Attribs, data))
	{
		npc.m_fGunDamage = data.Damage * data.Pellets;
		npc.m_fGunFirerate = data.FireRate;
		npc.m_fGunReload = data.Reload;
		npc.m_iGunClip = data.Clip;
	}
	
	npc.m_iAttacksTillReload = npc.m_iGunClip;
	
	switch(npc.m_iGunType)
	{
		case Cit_Melee:
		{
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_crowbar.mdl");
			
			AcceptEntityInput(npc.m_iWearable1, "Disable");
		}
		case Cit_Pistol:
		{
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
			
			AcceptEntityInput(npc.m_iWearable1, "Disable");
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
	}
}

public void Citizen_ClotThink(int iNPC)
{
	Citizen npc = view_as<Citizen>(iNPC);
	
	float gameTime = GetGameTime();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_iGunType != Cit_Melee)
		{
			npc.m_flAttackHappens = 0.0;
		}
		else if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget, true))
			{
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
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
						if(!npc.m_bFirstBlood && GetEntProp(target, Prop_Data, "m_iHealth") < 1)
						{
							npc.m_bFirstBlood = true;
							npc.PlaySound(Cit_FirstBlood);
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
	
	if(npc.m_iGunType != Cit_None && npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, 1000.0);
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
	}
	
	if(npc.m_flReloadDelay > gameTime)
	{
		if(npc.m_bPathing)
		{
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
		}
		return;
	}
	
	bool moveBack = true;
	bool wantReload = npc.m_iAttacksTillReload == 0;
	if(npc.m_iTarget > 0)
	{
		npc.m_iState = State_Attacking;
		moveBack = false;
		wantReload = false;
		
		if(npc.m_iGunType == Cit_None || !IsValidEnemy(npc.index, npc.m_iTarget, true))
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
				moveDown = true;
				
				int activity = npc.LookupActivity("ACT_RUN_PANICKED");
				if(activity > 0)
					npc.StartActivity(activity);
				
				npc.m_flSpeed = 225.0;
				
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
							
							int activity = npc.LookupActivity("ACT_MELEE_ANGRY_MELEE");
							if(activity > 0)
								npc.StartActivity(activity);
							
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
							int activity = npc.LookupActivity("ACT_RUN_CROUCH");
							if(activity > 0)
								npc.StartActivity(activity);
							
							moveUp = true;
							npc.m_flSpeed = 210.0;
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Enable");
						}
						else
						{
							int activity = npc.LookupActivity("ACT_RUN");
							if(activity > 0)
								npc.StartActivity(activity);
							
							moveBack = true;
							npc.m_flSpeed = 210.0;
							
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
							
							if(npc.m_flNextRangedAttack < gameTime)
							{
								int activity = npc.LookupActivity("ACT_RANGE_ATTACK_PISTOL");
								if(activity > 0)
									npc.StartActivity(activity);
								
								npc.m_flSpeed = 0.0;
								
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
								
								if(!npc.m_bFirstBlood && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
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
							int activity = npc.LookupActivity("ACT_RUN");
							if(activity > 0)
								npc.StartActivity(activity);
							
							moveBack = true;
							npc.m_flSpeed = 210.0;
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
								int activity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
								if(activity > 0)
									npc.StartActivity(activity);
								
								moveBack = true;
								npc.m_flSpeed = 80.0;
							}
							else
							{
								int activity = npc.LookupActivity((npc.m_iSeed % 4) ? "ACT_IDLE_ANGRY_SMG1" : "ACT_IDLE_AIM_RIFLE_STIMULATED");
								if(activity > 0)
									npc.StartActivity(activity);
								
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
								
								if(!npc.m_bFirstBlood && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
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
								int activity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
								if(activity > 0)
									npc.StartActivity(activity);
								
								moveBack = true;
								npc.m_flSpeed = 80.0;
							}
							else
							{
								int activity = npc.LookupActivity((npc.m_iSeed % 4) ? "ACT_IDLE_ANGRY_SMG1" : "ACT_IDLE_AIM_RIFLE_STIMULATED");
								if(activity > 0)
									npc.StartActivity(activity);
								
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
								int activity = npc.LookupActivity("ACT_WALK_AIM_AR2");
								if(activity > 0)
									npc.StartActivity(activity);
								
								moveBack = true;
								npc.m_flSpeed = 80.0;
							}
							else
							{
								int activity = npc.LookupActivity("ACT_IDLE_ANGRY_AR2");
								if(activity > 0)
									npc.StartActivity(activity);
								
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
								
								if(!npc.m_bFirstBlood && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
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
								int activity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
								if(activity > 0)
									npc.StartActivity(activity);
								
								moveBack = true;
								npc.m_flSpeed = 80.0;
							}
							
							if(npc.m_flNextRangedAttack < gameTime && npc.m_iAttacksTillReload == 0)
								wantReload = true;
						}
					}
					case Cit_Shotgun:
					{
						if(distance < 125000.0 && npc.m_iAttacksTillReload != 0)	// Attack at 350 HU
						{
							int activity = npc.LookupActivity("ACT_IDLE_ANGRY_AR2");
							if(activity > 0)
								npc.StartActivity(activity);
							
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
								npc.PlayPistolSound();
								
								if(!npc.m_bFirstBlood && npc.m_iTarget > 0 && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
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
								int activity = npc.LookupActivity("ACT_RUN_AR2");
								if(activity > 0)
									npc.StartActivity(activity);
								
								moveBack = true;
								npc.m_flSpeed = 180.0;
							}
							else
							{
								wantReload = true;
							}
						}
						else
						{
							int activity = npc.LookupActivity("ACT_IDLE_SHOTGUN_AGITATED");
							if(activity > 0)
								npc.StartActivity(activity);
							
							npc.m_flSpeed = 0.0;
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
			else if(!moveDown)
			{
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}	
			}
		}
	}
	
	else if (!npc.m_b_stand_still && npc.m_b_follow && IsValidClient(client) && IsPlayerAlive(client))
	{
		if (npc.m_flDoingSpecial < GetGameTime() && npc.m_iState == 1)
		{
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_iState = 0;
			int iActivity = npc.LookupActivity("ACT_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_flFollowing_Master_Now = GetGameTime() + 1.0;
			AcceptEntityInput(npc.m_iWearable2, "Disable");
			AcceptEntityInput(npc.m_iWearable1, "Enable");
		}
		else if ((npc.m_iState == 0 || npc.m_iState == 2) && npc.m_flFollowing_Master_Now < GetGameTime())
		{
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(client);
			
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index));
			
			if (flDistanceToTarget > 300 && npc.m_flReloadDelay < GetGameTime())
			{
				npc.StartPathing();
				
				PF_SetGoalEntity(npc.index, client);
				if (!npc.m_bmovedelay_run)
				{
					int iActivity_melee = npc.LookupActivity("ACT_RUN");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay_run = true;
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
					npc.m_fbGunout = false;
					npc.m_flSpeed = 260.0;
					npc.m_bmovedelay_walk = false;
					npc.m_bmovedelay = false;
				//	PrintHintText(client, "Bob The Second: I'm coming towards you, sir!");
				}
				npc.m_iState = 0;
			}
			else if (flDistanceToTarget > 140 && flDistanceToTarget < 300 && npc.m_flReloadDelay < GetGameTime())
			{
				npc.StartPathing();
				
				PF_SetGoalEntity(npc.index, client);
				if (!npc.m_bmovedelay_walk)
				{
					int iActivity_melee = npc.LookupActivity("ACT_WALK");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay_walk = true;
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
					npc.m_fbGunout = false;
					npc.m_flSpeed = 90.0;
					npc.m_bmovedelay_run = false;
					npc.m_bmovedelay = false;
				//	PrintHintText(client, "Bob The Second: Hello, sir!");
					npc.m_flidle_talk = GetGameTime() + GetRandomFloat(10.0, 20.0);
				}
				npc.m_iState = 0;
			}
			else if (npc.m_flReloadDelay > GetGameTime())
			{
				npc.m_bmovedelay_walk = false;
				npc.m_bmovedelay = false;
				npc.m_bmovedelay_run = false;
				PF_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
			
			else if (npc.m_iState != 2)
			{
				npc.m_bmovedelay_walk = false;
				npc.m_bmovedelay = false;
				npc.m_bmovedelay_run = false;
				PF_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_iState = 2;
				int iActivity_melee = npc.LookupActivity("ACT_IDLE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				if(npc.m_bIsFriendly)
				{
					SetGlobalTransTarget(client);
					PrintHintText(client, "%t %t","Bob The Second:", "I'll stand beside you, sir!");
										
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				}
				else if(!npc.m_bIsFriendly)
				{
					SetGlobalTransTarget(client);
					PrintHintText(client, "%t %t","Bob The Second:", "I'll guard you, sir!");
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				}
				npc.m_flidle_talk = GetGameTime() + GetRandomFloat(10.0, 20.0);
			}
			
			if (flDistanceToTarget < 250 && npc.m_iAttacksTillReload != 24)
			{
				npc.AddGesture("ACT_RELOAD_PISTOL");
				npc.m_flReloadDelay = GetGameTime() + 1.4;
				npc.m_iAttacksTillReload = 24;
				npc.PlayRangedReloadSound();
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				npc.m_bPathing = false;
				npc.m_fbGunout = true;
				npc.m_bReloaded = false;
				SetGlobalTransTarget(client);
				PrintHintText(client, "%t %t","Bob The Second:", "Reloading near you, sir!");
				StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			}
			else if(flDistanceToTarget < 250 && npc.m_flReloadDelay < GetGameTime() && npc.m_iAttacksTillReload == 24)
			{
				if (!npc.m_bReloaded)
				{
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
				npc.m_bReloaded = true;
				npc.m_bPathing = false;
				npc.m_fbGunout = false;
				if (npc.m_flidle_talk < GetGameTime()/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") >= 500*/)
				{
					npc.m_flidle_talk = GetGameTime() + GetRandomFloat(10.0, 20.0);
					SetGlobalTransTarget(client);
					switch(GetRandomInt(1, 8))
					{
						case 1:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "I'm pretty bored...");
						}
						case 2:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "I hope your day is going well!");
						}
						case 3:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "Sometimes i wonder why this war exists.");
						}
						case 4:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "I'm pretty bored...");
						}
						case 5:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "Just saying, never give up!");
						}
						case 6:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "Could i borrow your gun perhaps?");
						}
						case 7:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "Im pretty confident in my abilities!");
						}
						case 8:
						{
							PrintHintText(client, "%t %t","Bob The Second:", "Pick up that can.");
						}
					}
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");				
				}
				/*
				else if (npc.m_flidle_talk < GetGameTime() && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
				{
					npc.m_flidle_talk = GetGameTime() + GetRandomFloat(10.0, 20.0);
					switch(GetRandomInt(1, 7))
					{
						case 1:
						{
							PrintHintText(client, "Bob The Second: I don't feel good..");
						}
						case 2:
						{
							PrintHintText(client, "Bob The Second: I'm hurt...");
						}
						case 3:
						{
							PrintHintText(client, "Bob The Second: I hate this..");
						}
						case 4:
						{
							PrintHintText(client, "Bob The Second: I'm pretty exhausted...");
						}
						case 5:
						{
							PrintHintText(client, "Bob The Second: I'm tired...");
						}
						case 6:
						{
							PrintHintText(client, "Bob The Second: Can we relax, please?");
						}
						case 7:
						{
							PrintHintText(client, "Bob The Second: I might be a goner soon..");
						}
					}	
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
				}
				*/
			}
		}
	}
	
	npc.PlayIdleAlertSound();
}


public void roundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			Has_a_bob[client] = 0;
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, Citizen_Owner_Hurt);
		}
	}
}

public void Citizen_PluginBot_OnActorEmoted(int bot_entidx, int who, int concept)
{
//	PrintToServer(">>>>>>>>>> PluginBot_OnActorEmoted %i who %i concept %i", bot_entidx, who, concept);
	
	if (concept == 13)
	{
		//"Go go go!"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		SetGlobalTransTarget(client);
		PrintHintText(client, "%t %t","Bob The Second:", "On my way, sir!");
		npc.m_flidle_talk += 2.0;
		float StartOrigin[3], Angles[3], vecPos[3];
		GetClientEyeAngles(who, Angles);
		GetClientEyePosition(who, StartOrigin);
		
		Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
		if (TR_DidHit(TraceRay))
			TR_GetEndPosition(vecPos, TraceRay);
			
		delete TraceRay;
		
		
		npc.StartPathing();
		npc.m_fbGunout = false;
		
		PF_SetGoalVector(npc.index, vecPos);
		
		
		
		npc.FaceTowards(vecPos, 500.0);
		npc.m_flDoingSpecial = GetGameTime() + 3.5;
		
		npc.m_iState = 1;
		
		int iActivity_melee = npc.LookupActivity("ACT_RUN");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		npc.m_flSpeed = 260.0;

		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		npc.PlayMovingSound();
				
		CreateParticle("ping_circle", vecPos, NULL_VECTOR);
	}
	else if (concept == 19)
	{
		//"Incomming!"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			npc.AddGesture("ACT_METROPOLICE_POINT");
			
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Im watching there, dont worry!");
			npc.m_flidle_talk += 2.0;
			float StartOrigin[3], Angles[3], vecPos[3];
			GetClientEyeAngles(who, Angles);
			GetClientEyePosition(who, StartOrigin);
			
			Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
			if (TR_DidHit(TraceRay))
				TR_GetEndPosition(vecPos, TraceRay);
				
			delete TraceRay;
			
			npc.FaceTowards(vecPos, 10000.0);
			CreateParticle("ping_circle", vecPos, NULL_VECTOR);
		}
	}
	else if (concept == 20)
	{
		//"spy!"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Spy? I'm keeping my eye there.");
			npc.m_flidle_talk += 2.0;
			float StartOrigin[3], Angles[3], vecPos[3];
			GetClientEyeAngles(who, Angles);
			GetClientEyePosition(who, StartOrigin);
			
			Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
			if (TR_DidHit(TraceRay))
				TR_GetEndPosition(vecPos, TraceRay);
				
			delete TraceRay;
			
			int iActivity_melee = npc.LookupActivity("ACT_IDLE_ANGRY_PISTOL");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			npc.m_fbGunout = true;
			AcceptEntityInput(npc.m_iWearable2, "Enable");
			AcceptEntityInput(npc.m_iWearable1, "Disable");
					
			npc.FaceTowards(vecPos, 10000.0);
			CreateParticle("ping_circle", vecPos, NULL_VECTOR);
		}
	}
	else if (concept == 21)
	{
		//"Sentry Ahead"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Sentry here? Its better to wait for teammates to engage so i'll look.");
			npc.m_flidle_talk += 2.0;
			float StartOrigin[3], Angles[3], vecPos[3];
			GetClientEyeAngles(who, Angles);
			GetClientEyePosition(who, StartOrigin);
			
			Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
			if (TR_DidHit(TraceRay))
				TR_GetEndPosition(vecPos, TraceRay);
				
			delete TraceRay;
			
			int iActivity_melee = npc.LookupActivity("ACT_IDLE_ANGRY_PISTOL");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			npc.m_fbGunout = true;
			AcceptEntityInput(npc.m_iWearable2, "Enable");
			AcceptEntityInput(npc.m_iWearable1, "Disable");
					
			npc.FaceTowards(vecPos, 10000.0);
			CreateParticle("ping_circle", vecPos, NULL_VECTOR);
		}
	}
	else if (concept == 22)
	{
		//"Build teleporter!"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I cant build a teleporter, sorry.");
			npc.m_flidle_talk += 2.0;
		}
	}
	else if (concept == 23)
	{
		//"Build dispenser"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I cant build a teleporter, sorry.");
			npc.m_flidle_talk += 2.0;
		}
	}
	else if (concept == 24)
	{
		//"build sentry"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I cant build a sentry, sorry.");
			npc.m_flidle_talk += 2.0;
		}
	}
	else if (concept == 25)
	{
		//"Charge me!"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I can't give you ubercharge...");
			npc.m_flidle_talk += 2.0;
		}
	}
	
	else if (concept == 14)
	{
		//"Move Up!"	
		Citizen npc = view_as<Citizen>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		if(!npc.m_b_stand_still) //Already moving, geez!
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Standing right here!");
			npc.m_flidle_talk += 2.0;
			npc.m_b_stand_still = true;
			return;
		}
		
		else if(npc.m_b_stand_still) //Already moving, geez!
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I'm on my move again!");
			npc.m_flidle_talk += 2.0;
			npc.m_b_stand_still = false;
			return;
		}
		
	}
	else if (concept == 12)
	{
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		//"Help me!"
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget > 300)
		{
			CreateParticle("ping_circle", pos, NULL_VECTOR);
			
			int iActivity_melee = npc.LookupActivity("ACT_RUN");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			npc.m_bmovedelay_run = false;
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			npc.m_fbGunout = false;
			npc.m_flSpeed = 260.0;
			npc.m_bmovedelay_walk = false;
			npc.m_bmovedelay = false;
					
			PF_SetGoalEntity(npc.index, client);
			
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I am coming !");
			npc.m_flidle_talk += 2.0;
			
			npc.m_bIsFriendly = false;
			
			npc.m_flComeToMe = GetGameTime() + 3.0; 
			
		}
		else
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I'm already here!");
			npc.m_flidle_talk += 2.0;
		}	
		TeleportEntity(npc.index, pos, NULL_VECTOR, NULL_VECTOR); 
		return;

	}
	else if (concept == 58)
	{
		//"thanks!"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		if(flDistanceToTarget < 300)
		{
			int iActivity_melee = npc.LookupActivity("ACT_BUSY_THREAT");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I'm glad to help!");
			npc.m_flidle_talk += 2.0;
		}
		
		return;

	}
	else if (concept == 17)
	{
		//"yes"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		SetGlobalTransTarget(client);
		PrintHintText(client, "%t %t","Bob The Second:", "Follow? Sure!");
		npc.m_flidle_talk += 2.0;
		npc.m_b_follow = true;
		
		return;

	}
	else if (concept == 15)
	{
		//"left"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "My left or yours?");
			npc.m_flidle_talk += 2.0;
		}
		
		return;

	}
	else if (concept == 16)
	{
		//"right"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "My right or yours?");
			npc.m_flidle_talk += 2.0;
		}
		
		return;

	}
	else if (concept == 29)
	{
		//"cheers"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_MELEE_ATTACK_THRUST");
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Cheers to you too, like a drink, get it?");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			npc.AddGesture("ACT_PICKUP_GROUND");
			PrintHintText(client, "Bob The Second: Its more of a jeer, hurt here...");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		*/
		
		return;

	}
	else if (concept == 30)
	{
		//"jeers"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Ah come on, lighten your mood!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			PrintHintText(client, "Bob The Second: Yeah agreed...");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		*/
		return;

	}
	else if (concept == 31)
	{
		//"positive"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Positivity is the way to go!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			PrintHintText(client, "Bob The Second: Not the time for it...");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		*/
		return;

	}
	else if (concept == 32)
	{
		//"negative"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Why negative? Nothing to worry about!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			PrintHintText(client, "Bob The Second: Yeah its not looking great, but lets try to feel better...");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		*/
		return;

	}
	else if (concept == 18)
	{
		//"no"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
		
		SetGlobalTransTarget(client);
		PrintHintText(client, "%t %t","Bob The Second:", "Not Follow? Sure!");
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		npc.m_flidle_talk += 2.0;
		npc.m_b_follow = false;
		
		return;

	}
	else if (concept == 28)
	{
		//Battle Cry
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		if(!npc.m_bIsFriendly) //Already moving, geez!
		{
			//npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_DEACTIVATE_BATON");
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I'll hurt no one!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
			npc.m_bIsFriendly = true;
			return;
		}
		else if(npc.m_bIsFriendly) //Already moving, geez!
		{
			npc.AddGesture("ACT_ACTIVATE_BATON");
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I'll attack once more!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
			npc.m_bIsFriendly = false;
			return;
		}
		return;
	}
	else if (concept == 33)
	{
		//"Nice shot"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I try my best to aim well!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		
		return;

	}
	else if (concept == 34)
	{
		//"Good job"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "You are doing a good job aswell!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		
		return;

	}
	else if (concept == 5)
	{
		//"medic!"
		Citizen npc = view_as<Citizen>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
		
		if(flDistanceToTarget < 100 && npc.m_flheal_cooldown < GetGameTime())
		{
			npc.m_iMedkitAnnoyance = 0;
			npc.m_flheal_cooldown = GetGameTime() + GetRandomFloat(20.0, 30.0);
			npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_PUSH_PLAYER");
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Here, have this medkit!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
			CreateTimer(0.3, Citizen_showHud, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else if (npc.m_iMedkitAnnoyance == 0 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime())
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Sorry, i dont have a medkit on me...");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		else if (npc.m_iMedkitAnnoyance == 1 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime())
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Sorry, i dont have a medkit on me, please wait.");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		else if (npc.m_iMedkitAnnoyance == 2 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime())
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I do not have a medkit.");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		else if (npc.m_iMedkitAnnoyance == 3 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime())
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I dont have a medkit, have patience.");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		else if (flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime())
		{
			npc.m_iMedkitAnnoyance = 0;
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "I told you i do not have a medikit!!!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
			npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_PUSH_PLAYER");
			npc.PlayMeleeSound();
			CreateTimer(0.4, Citizen_anger_medkit, npc.index, TIMER_FLAG_NO_MAPCHANGE);		
		}
		else
		{
			SetGlobalTransTarget(client);
			PrintHintText(client, "%t %t","Bob The Second:", "Youre too far away!");
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			npc.m_flidle_talk += 2.0;
		}
		return;
	}
}

public Action Citizen_showHud(Handle dashHud, int client)
{
	if (IsValidClient(client))
	{
		EmitSoundToAll("items/smallmedkit1.wav", client, _, 90, _, 1.0);
		StartHealingTimer(client, 0.1, 1, 25, true);
	}
	return Plugin_Handled;
}

public Action Citizen_anger_medkit(Handle dashHud, int entity)
{
	if (IsValidEntity(entity))
	{
		Citizen npc = view_as<Citizen>(entity);
		
		int client = who_owns_this_bob[npc.index];
		
		if (IsValidClient(client) && IsPlayerAlive(client))
		{
			float pos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
			
			float flDistanceToTarget = GetVectorDistance(pos, WorldSpaceCenter(npc.index));	
			if(flDistanceToTarget < 150)
			{
				SDKHooks_TakeDamage(client, npc.index, client, 35.0, DMG_CLUB);
												
				float vAngles[3], vDirection[3];
											
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles); 
												
				if(vAngles[0] > -45.0)
				{
					vAngles[0] = -45.0;
				}
									
				npc.PlayMeleeHitSound();	
			
				if(client <= MaxClients)
					Client_Shake(client, 0, 75.0, 75.0, 0.5);
												
				GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
													
				ScaleVector(vDirection, 500.0);
																		
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vDirection); 
			}
		}
		else
		{
			npc.PlayMeleeMissSound();		
		}
	}
	return Plugin_Handled;
}

public bool TraceRayProp(int entityhit, int mask, any entity)
{
	if (entityhit > MaxClients && entityhit != entity)
	{
		return true;
	}
	
	return false;
}

public Action Bob_player_killed(Event hEvent, const char[] sEvName, bool bDontBroadcast) //Controls what happens when a player dies. 
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	if (IsValidClient(victim))
	{
		if(Has_a_bob[victim])
		{
			Citizen npc = view_as<Citizen>(Has_a_bob[victim]);
			
			npc.m_b_stand_still = false;
			npc.m_b_follow = true;
			npc.m_bIsFriendly = false;
		//	NPCDeath(npc.index);
			SetGlobalTransTarget(victim);
			PrintHintText(victim, "%t %t","Bob The Second:", "This can't be...");
			StopSound(victim, SNDCHAN_STATIC, "UI/hint.wav");
			
		}
	}
	return Plugin_Handled;
}


public Action Citizen_Owner_Hurt(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Friendly fire
	if(view_as<CClotBody>(attacker).GetTeam() == view_as<CClotBody>(victim).GetTeam())
		return Plugin_Continue;
		
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(attacker > MaxClients && !IsValidEnemy(victim, attacker, true))
		return Plugin_Continue;
		
	if (!Has_a_bob[victim])
	{
		SDKUnhook(victim, SDKHook_OnTakeDamageAlive, Citizen_Owner_Hurt);
		return Plugin_Continue;
	}
	
	Citizen npc = view_as<Citizen>(Has_a_bob[victim]);
	
	npc.m_iTarget = attacker;
	
	if(npc.m_flHurtie < GetGameTime() && !npc.m_bIsFriendly)
	{
		npc.m_flHurtie = GetGameTime() + 0.50;
		SetGlobalTransTarget(victim);
		PrintHintText(victim, "%t %t","Bob The Second:", "I will protect you!");
		StopSound(victim, SNDCHAN_STATIC, "UI/hint.wav");
	}
	else if(npc.m_flHurtie < GetGameTime() && npc.m_bIsFriendly)
	{
		npc.m_flHurtie = GetGameTime() + 0.50;
		SetGlobalTransTarget(victim);
		PrintHintText(victim, "%t %t","Bob The Second:", "You told me to be friendly.");
		StopSound(victim, SNDCHAN_STATIC, "UI/hint.wav");
	}
	return Plugin_Changed;
}


public Action Citizen_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (damage < 9999999.0)	//So they can be slayed.
		return Plugin_Handled;
		
	else
		return Plugin_Continue;
}

public void Citizen_NPCDeath(int entity)
{
	Citizen npc = view_as<Citizen>(entity);
	int client = who_owns_this_bob[npc.index];
	if(IsValidClient(client))
	{
	//	PrintHintText(client, "Bob has died :(");
	//	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, Citizen_Owner_Hurt);
	}
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Citizen_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Citizen_ClotThink);
	PF_StopPathing(npc.index);
	npc.m_bPathing = false;
	Has_a_bob[client] = 0;
	/*
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	*/
	//He cant die. He just goes away.
	SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC); //Kill it so it triggers the neccecary shit.
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
