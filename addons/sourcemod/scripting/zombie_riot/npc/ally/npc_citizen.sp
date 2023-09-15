#pragma semicolon 1
#pragma newdecls required

#define BARNEY_MODEL	"models/barney.mdl"
#define ALYX_MODEL	"models/alyx.mdl"

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

static const float BaseRange[] =
{
	0.0,
	400.0,
	1000.0,
	350.0,
	775.0,
	900.0,
	1000.0
};

void Citizen_GenerateModel(int seed, bool female, int group, char[] buffer, int length)
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
		case Cit_Reload:
		{
			int rand = seed % 3;
			if(rand == 2)
			{
				strcopy(buffer, length, "gottareload01");
			}
			else
			{
				Format(buffer, length, "coverwhilereload0%d", 1 + (seed % 2));
			}
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
}

static void Barney_GenerateSound(int type, int seed, char[] buffer, int length)
{
	switch(type)
	{
		case Cit_Answer:
		{
			int rand = seed % 9;
			switch(rand)
			{
				case 0:
					strcopy(buffer, length, "vo/trainyard/ba_tellme01.wav");
				
				case 1:
					strcopy(buffer, length, "vo/k_lab/ba_geethanks.wav");
				
				case 2:
					strcopy(buffer, length, "vo/k_lab/ba_guh.wav");
				
				case 3:
					strcopy(buffer, length, "vo/k_lab/ba_longer.wav");
				
				case 4:
					strcopy(buffer, length, "vo/k_lab/ba_myshift01.wav");
				
				case 5:
					strcopy(buffer, length, "vo/k_lab/ba_saidlasttime.wav");
				
				case 6:
					strcopy(buffer, length, "vo/k_lab/ba_sarcastic03.wav");
				
				default:
					Format(buffer, length, "vo/k_lab/ba_itsworking0%d.wav", rand - 6);
			}
		}
		case Cit_Behind:
		{
			strcopy(buffer, length, "vo/k_lab/ba_headhumper02.wav");
		}
		case Cit_Busy:
		{
			strcopy(buffer, length, "vo/trainyard/ba_thinking01.wav");
		}
		case Cit_Combine:
		{
			strcopy(buffer, length, "vo/npc/barney/ba_soldiers.wav");
		}
		case Cit_DoSomething:
		{
			switch(seed % 6)
			{
				case 0:
					strcopy(buffer, length, "vo/streetwar/sniper/ba_heycomeon.wav");
				
				case 1:
					strcopy(buffer, length, "vo/streetwar/sniper/ba_letsgetgoing.wav");
				
				case 2:
					strcopy(buffer, length, "vo/npc/barney/ba_followme02.wav");
				
				case 3:
					strcopy(buffer, length, "vo/npc/barney/ba_hurryup.wav");
				
				case 4:
					strcopy(buffer, length, "vo/k_lab2/ba_getgoing.wav");
				
				case 5:
					strcopy(buffer, length, "vo/k_lab/ba_dontblameyou.wav");
			}
		}
		case Cit_CadeDeath:
		{
			int rand = seed % 3;
			switch(rand)
			{
				case 0:
					strcopy(buffer, length, "vo/npc/barney/ba_lookout.wav");
				
				default:
					Format(buffer, length, "vo/npc/barney/ba_no0%d.wav", rand);
			}
		}
		case Cit_AllyDeathQuestion:
		{
			switch(seed % 3)
			{
				case 0:
					strcopy(buffer, length, "vo/npc/barney/ba_damnit.wav");
				
				case 1:
					strcopy(buffer, length, "vo/k_lab/ba_whatthehell.wav");
				
				case 2:
					strcopy(buffer, length, "vo/k_lab/ba_thingaway02.wav");
			}
		}
		case Cit_AllyDeathAnswer:
		{
			if(seed % 2)
			{
				strcopy(buffer, length, "vo/npc/barney/ba_danger02.wav");
			}
			else
			{
				strcopy(buffer, length, "vo/k_lab/ba_cantlook.wav");
			}
		}
		case Cit_FirstBlood:
		{
			int rand = seed % 6;
			switch(rand)
			{
				case 0:
					strcopy(buffer, length, "vo/npc/barney/ba_bringiton.wav");
				
				case 1:
					strcopy(buffer, length, "vo/npc/barney/ba_gotone.wav");
				
				default:
					Format(buffer, length, "vo/npc/barney/ba_laugh0%d.wav", rand - 1);
			}
		}
		case Cit_Headcrab:
		{
			strcopy(buffer, length, "vo/npc/barney/ba_headhumpers.wav");
		}
		case Cit_MiniBoss:
		{
			switch(seed % 4)
			{
				case 0:
					strcopy(buffer, length, "vo/npc/barney/ba_hereitcomes.wav");
				
				case 1:
					strcopy(buffer, length, "vo/npc/barney/ba_uhohheretheycome.wav");
				
				case 2:
					strcopy(buffer, length, "vo/k_lab2/ba_incoming.wav");
				
				case 3:
					strcopy(buffer, length, "vo/k_lab/ba_hesback01.wav");
			}
		}
		case Cit_Healer:
		{
			Format(buffer, length, "vo/k_lab/ba_careful0%d.wav", 1 + (seed % 2));
		}
		case Cit_Lost:
		{
			strcopy(buffer, length, "vo/streetwar/sniper/ba_overhere.wav");
		}
		case Cit_MiniBossDead:
		{
			if(seed % 2)
			{
				strcopy(buffer, length, "vo/npc/barney/ba_ohyeah.wav");
			}
			else
			{
				strcopy(buffer, length, "vo/npc/barney/ba_yell.wav");
			}
		}
		case Cit_LowHealth:
		{
			Format(buffer, length, "vo/npc/barney/ba_wounded0%d.wav", seed % 2 + 2);
		}
		case Cit_Found:
		{
			switch(seed % 8)
			{
				case 0:
					strcopy(buffer, length, "vo/npc/barney/ba_imwithyou.wav");
				
				case 1:
					strcopy(buffer, length, "vo/npc/barney/ba_letsgo.wav");
				
				case 2:
					strcopy(buffer, length, "vo/k_lab2/ba_goodnews.wav");
				
				case 3:
					strcopy(buffer, length, "vo/k_lab2/ba_goodnews_b.wav");
				
				case 4:
					strcopy(buffer, length, "vo/k_lab2/ba_goodnews_c.wav");
				
				case 5:
					strcopy(buffer, length, "vo/k_lab/ba_nottoosoon01.wav");
				
				case 6:
					strcopy(buffer, length, "vo/k_lab/ba_thereyouare.wav");
				
				case 7:
					strcopy(buffer, length, "vo/trainyard/ba_thatbeer02.wav");
			}
		}
		case Cit_Hurt:
		{
			Format(buffer, length, "vo/npc/barney/ba_pain%002d.wav", seed % 10 + 1);
		}
		case Cit_Question:
		{
			switch(seed % 3)
			{
				case 0:
					strcopy(buffer, length, "vo/streetwar/sniper/ba_hearcat.wav");
				
				case 1:
					strcopy(buffer, length, "vo/k_lab/ba_ishehere.wav");
				
				case 2:
					strcopy(buffer, length, "vo/k_lab/ba_itsworking04.wav");
			}
		}
		default:
		{
			strcopy(buffer, length, "vo/null.mp3");
		}
	}
}

static void Alyx_GenerateSound(int type, int seed, char[] buffer, int length)
{
	switch(type)
	{
		case Cit_AllyDeathAnswer:
		{
			Format(buffer, length, "vo/npc/alyx/no0%d.wav", (seed % 3) + 1);
		}
		case Cit_AllyDeathQuestion:
		{
			switch(seed % 3)
			{
				case 0:
					strcopy(buffer, length, "vo/npc/alyx/ohgod01.wav");
				
				case 1:
					strcopy(buffer, length, "vo/npc/alyx/ohno_startle01.wav");
				
				case 2:
					strcopy(buffer, length, "vo/npc/alyx/ohno_startle03.wav");
			}
		}
		case Cit_Ammo:
		{
			Format(buffer, length, "vo/npc/alyx/youreload0%d.wav", (seed % 2) + 1);
		}
		case Cit_Answer:
		{
			switch(seed % 7)
			{
				case 0:
					strcopy(buffer, length, "vo/k_lab/al_docsays02.wav");
				
				case 1:
					strcopy(buffer, length, "vo/k_lab2/al_whatdoyoumean.wav");
				
				case 2:
					strcopy(buffer, length, "vo/novaprospekt/al_betyoudid01.wav");
				
				case 3:
					strcopy(buffer, length, "vo/novaprospekt/al_enoughbs01.wav");
				
				case 4:
					strcopy(buffer, length, "vo/novaprospekt/al_youbeenworking.wav");
				
				case 5:
					strcopy(buffer, length, "vo/novaprospekt/al_youput01.wav");
				
				case 6:
					strcopy(buffer, length, "vo/eli_lab/al_letmedo.wav");
			}
		}
		case Cit_Behind:
		{
			Format(buffer, length, "vo/npc/alyx/watchout0%d.wav", (seed % 2) + 1);
		}
		case Cit_Busy:
		{
			strcopy(buffer, length, "vo/k_lab2/al_catchup_b.wav");
		}
		case Cit_CadeDeath:
		{
			int rand = seed % 3;
			switch(rand)
			{
				case 0:
					strcopy(buffer, length, "vo/npc/alyx/lookout01.wav");
				
				case 1:
					strcopy(buffer, length, "vo/npc/alyx/lookout03.wav");
			}
		}
		case Cit_DoSomething:
		{
			switch(seed % 3)
			{
				case 0:
					strcopy(buffer, length, "vo/k_lab/al_moveon02.wav");
				
				case 1:
					strcopy(buffer, length, "vo/k_lab/al_youcoming.wav");
				
				case 2:
					strcopy(buffer, length, "vo/novaprospekt/al_takingforever.wav");
			}
		}
		case Cit_Found:
		{
			switch(seed % 4)
			{
				case 0:
					strcopy(buffer, length, "vo/novaprospekt/al_findmyfather.wav");
				
				case 1:
					strcopy(buffer, length, "vo/novaprospekt/al_flyingblind.wav");
				
				case 2:
					strcopy(buffer, length, "vo/novaprospekt/al_gladtoseeyou.wav");
				
				case 3:
					strcopy(buffer, length, "vo/novaprospekt/al_letsgetout01.wav");
			}
		}
		case Cit_Lost:
		{
			strcopy(buffer, length, "vo/trainyard/al_overhere.wav");
		}
		case Cit_LowHealth:
		{
			Format(buffer, length, "vo/npc/alyx/gasp0%d.wav", seed % 2 + 2);
		}
		case Cit_Hurt:
		{
			Format(buffer, length, "vo/npc/alyx/hurt0%d.wav", ((seed % 3) + 2) * 2);	// 4,6,8
		}
		case Cit_MiniBoss:
		{
			switch(seed % 3)
			{
				case 0:
					strcopy(buffer, length, "vo/novaprospekt/al_elevator03.wav");
				
				case 1:
					strcopy(buffer, length, "vo/novaprospekt/al_sealdoor02.wav");
				
				case 2:
					strcopy(buffer, length, "vo/novaprospekt/al_uhoh_np.wav");
			}
		}
		case Cit_MiniBossDead:
		{
			if(seed % 2)
			{
				strcopy(buffer, length, "vo/eli_lab/al_earnedit01.wav");
			}
			else
			{
				strcopy(buffer, length, "vo/eli_lab/al_sweet.wav");
			}
		}
		case Cit_Question:
		{
			switch(seed % 6)
			{
				case 0:
					strcopy(buffer, length, "vo/k_lab/al_buyyoudrink03.wav");
				
				case 1:
					strcopy(buffer, length, "vo/k_lab2/al_wheresdoc01.wav");
				
				case 2:
					strcopy(buffer, length, "vo/novaprospekt/al_mutter.wav");
				
				case 3:
					strcopy(buffer, length, "vo/novaprospekt/al_readings01.wav");
				
				case 4:
					strcopy(buffer, length, "vo/streetwar/alyx_gate/al_watchmyback.wav");
				
				case 5:
					strcopy(buffer, length, "vo/eli_lab/al_thyristor02.wav");
			}
		}
		default:
		{
			strcopy(buffer, length, "vo/null.mp3");
		}
	}
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
	PrecacheModel(BARNEY_MODEL);
	PrecacheModel(ALYX_MODEL);
	
	char buffer[PLATFORM_MAX_PATH];
	for(int i; i < Cit_MAX; i++)
	{
		for(int a; a < 39; a++)
		{
			Citizen_GenerateSound(i, a, false, buffer, sizeof(buffer));
			PrecacheSound(buffer);
			
			Citizen_GenerateSound(i, a, true, buffer, sizeof(buffer));
			PrecacheSound(buffer);

			Barney_GenerateSound(i, a, buffer, sizeof(buffer));
			PrecacheSound(buffer);

			Alyx_GenerateSound(i, a, buffer, sizeof(buffer));
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

	PrecacheSound("weapons/rpg/rocketfire1.wav");
	PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav");
}

static int ThereCanBeOnlyOne = -1;
static bool FirstBlood[MAXENTITIES];
static int IsDowned[MAXENTITIES];
static bool SeakingMedic[MAXENTITIES];
static bool SeakingGeneric[MAXENTITIES];
static int HasPerk[MAXENTITIES];
static int ReviveTime[MAXENTITIES];
static int GunType[MAXENTITIES];
static int GunValue[MAXENTITIES];
static int GunSeller[MAXENTITIES];
static int PerkType[MAXENTITIES];
static float GunDamage[MAXENTITIES];
static float GunFireRate[MAXENTITIES];
static float GunBonusFireRate[MAXENTITIES];
static float GunBonusReload[MAXENTITIES];
static float GunReload[MAXENTITIES];
static int GunClip[MAXENTITIES];
static float GunRangeBonus[MAXENTITIES];
static float TalkCooldown[MAXENTITIES];
static float TalkTurnPos[MAXENTITIES][3];
static float TalkTurningFor[MAXENTITIES];
static float HealingCooldown[MAXENTITIES];
static bool IgnorePlayer[MAXTF2PLAYERS];
static int ArmorErosion[MAXENTITIES];

methodmap Citizen < CClotBody
{
	public Citizen(int client, float vecPos[3], float vecAng[3], const char[] data)
	{
		if(IsValidEntity(EntRefToEntIndex(ThereCanBeOnlyOne)))
			return view_as<Citizen>(-1);
		
		bool barney = data[0] == 'b';
		bool alyx = data[0] == 'a';
		
		int seed = barney ? -160920040 : (alyx ? -50 : GetURandomInt());
		bool female = !(seed % 2);
		
		char buffer[PLATFORM_MAX_PATH];
		if(barney)
		{
			strcopy(buffer, sizeof(buffer), BARNEY_MODEL);
		}
		else if(alyx)
		{
			strcopy(buffer, sizeof(buffer), ALYX_MODEL);
		}
		else
		{
			Citizen_GenerateModel(seed, female, Cit_Unarmed, buffer, sizeof(buffer));
		}
		
		Citizen npc = view_as<Citizen>(CClotBody(vecPos, vecAng, buffer, "1.15", "150", true, true));
		i_NpcInternalId[npc.index] = CITIZEN;
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iState = -1;
		npc.SetActivity("ACT_BUSY_SIT_GROUND", 0.0);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;	
		
		SetEntProp(npc.index, Prop_Send, "m_iTeamNum", TFTeam_Red);
		
		
		SDKHook(npc.index, SDKHook_Think, Citizen_ClotThink);
		
		int glow = npc.m_iTeamGlow;
		if(glow > 0)
			AcceptEntityInput(glow, "Disable");
		
		npc.m_iSeed = seed;
		
		npc.m_nDowned = 1;
		npc.m_bThisEntityIgnored = true;
		npc.m_iReviveTicks = 0;
		npc.m_bFirstBlood = false;
		npc.m_iGunType = Cit_None;
		npc.m_iGunValue = 0;
		npc.m_iGunSeller = 0;
		npc.m_iBuildingType = -1;
		npc.m_iWearable1 = -1;
		npc.m_iWearable2 = -1;
		npc.m_iWearable3 = -1;
		npc.m_b_stand_still = false;
		npc.m_bSeakingMedic = false;
		npc.m_bSeakingGeneric = false;
		npc.m_iHasPerk = Cit_None;
		npc.m_iArmorErosion = 0;
		GunBonusFireRate[npc.index] = 1.0;
		GunBonusReload[npc.index] = 1.0;
		
		npc.m_iAttacksTillReload = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_flSpeed = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flidle_talk = FAR_FUTURE;
		
		Zero(HealingCooldown);
		Zero(IgnorePlayer);
		
		return npc;
	}
	
	property int m_iSeed
	{
		public get()		{ return i_OverlordComboAttack[this.index]; }
		public set(int value) 	{ i_OverlordComboAttack[this.index] = value; }
	}
	property bool m_bHero
	{
		public get()		{ return (this.m_iSeed < 0); }
	}
	property bool m_bBarney
	{
		public get()		{ return (this.m_iSeed == -160920040); }
	}
	property bool m_bAlyx
	{
		public get()		{ return (this.m_iSeed == -50); }
	}
	property bool m_bFemale
	{
		public get()		{ return !(this.m_iSeed % 2); }
	}
	
	property int m_nDowned
	{
		public get()		{ return IsDowned[this.index]; }
		public set(int value) 	{ IsDowned[this.index] = value; }
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
	property int m_iGunSeller
	{
		public get()		{ return GunSeller[this.index]; }
		public set(int value) 	{ GunSeller[this.index] = value; }
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
	property float m_fGunBonusFireRate
	{
		public get()		{ return GunBonusFireRate[this.index]; }
		public set(float value) 	{ GunBonusFireRate[this.index] = value; }
	}
	property float m_fGunReload
	{
		public get()		{ return GunReload[this.index]; }
		public set(float value) 	{ GunReload[this.index] = value; }
	}
	property float m_fGunBonusReload
	{
		public get()		{ return GunBonusReload[this.index]; }
		public set(float value) 	{ GunBonusReload[this.index] = value; }
	}
	property int m_iGunClip
	{
		public get()		{ return GunClip[this.index]; }
		public set(int value) 	{ GunClip[this.index] = value; }
	}
	property float m_fGunRangeBonus
	{
		public get()		{ return GunRangeBonus[this.index]; }
		public set(float value) 	{ GunRangeBonus[this.index] = value; }
	}
	property float m_fTalkTimeIn
	{
		public get()		{ return TalkCooldown[this.index]; }
		public set(float value) 	{ TalkCooldown[this.index] = value; }
	}
	property bool m_bSeakingMedic
	{
		public get()		{ return SeakingMedic[this.index]; }
		public set(bool value) 	{ SeakingMedic[this.index] = value; }
	}
	property bool m_bSeakingGeneric
	{
		public get()		{ return SeakingGeneric[this.index]; }
		public set(bool value) 	{ SeakingGeneric[this.index] = value; }
	}
	property int m_iHasPerk
	{
		public get()		{ return HasPerk[this.index]; }
		public set(int value) 	{ HasPerk[this.index] = value; }
	}
	property int m_iArmorErosion
	{
		public get()		{ return ArmorErosion[this.index]; }
		public set(int value) 	{ ArmorErosion[this.index] = value; }
	}
	property float m_flSpeed
	{
		public get()
		{
			return this.m_flNextRangedBarrage_Spam;
		}
		public set(float value)
		{
			this.m_flNextRangedBarrage_Spam = value;

			if(!this.m_bSeakingGeneric && (this.m_iHasPerk == Cit_Pistol || this.m_iHasPerk == Cit_Shotgun || this.m_iHasPerk == Cit_RPG || (this.m_bCamo && this.m_iHasPerk == Cit_Melee)))
			{
				fl_Speed[this.index] = value * (this.m_bAlyx ? 1.66 : 1.55);
			}
			else if(this.m_bAlyx)
			{
				fl_Speed[this.index] = value * 1.6;
			}
			else
			{
				fl_Speed[this.index] = value * 1.5;
			}
		}
	}
	property float m_flReloadDelay
	{
		public get()
		{
			return fl_ReloadDelay[this.index];
		}
		public set(float value)
		{
			fl_ReloadDelay[this.index] = value;
			if(this.m_iHasPerk == Cit_SMG || this.m_iHasPerk == Cit_AR)
				fl_ReloadDelay[this.index] -= 0.2;
		}
	}
	
	public void SlowTurn(const float pos[3])
	{
		TalkTurningFor[this.index] = GetGameTime(this.index) + 1.25;
		TalkTurnPos[this.index][0] = pos[0];
		TalkTurnPos[this.index][1] = pos[1];
		TalkTurnPos[this.index][2] = pos[2];
	}
	public void UpdateCollision(bool state)
	{
		if(state)
		{
			Change_Npc_Collision(this.index, 3);
			this.bCantCollidie = true;
		}
		else
		{
			Change_Npc_Collision(this.index, 4);
			this.bCantCollidie = false;
		}
	}
	public void UpdateModel()
	{
		if(!this.m_bHero)
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
			SetEntityModel(this.index, buffer);
					
			SetEntPropVector(this.index, Prop_Send, "m_vecMaxsPreScaled", view_as<float>( { 1.0, 1.0, 2.0 } ));
			SetEntPropVector(this.index, Prop_Send, "m_vecMinsPreScaled", view_as<float>( { -1.0, -1.0, 0.0 } ));
			
			this.UpdateCollisionBox();
						
			SetEntPropVector(this.index, Prop_Data, "m_vecMaxs", view_as<float>( { 24.0, 24.0, 82.0 } ));
			SetEntPropVector(this.index, Prop_Data, "m_vecMins", view_as<float>( { -24.0, -24.0, 0.0 } ));
		}
		else if(this.m_bCamo)
		{
			SetEntityRenderMode(this.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(this.index, 255, 255, 255, 220);
		}
		else
		{
			SetEntityRenderColor(this.index, 255, 255, 255, 255);
			SetEntityRenderMode(this.index, RENDER_NORMAL);
		}
	}
	public void SetActivity(const char[] animation, float speed)
	{
		int activity = this.LookupActivity(animation);
		if(activity > 0 && activity != this.m_iState)
		{
			this.m_flSpeed = speed;
			this.m_iState = activity;
			this.m_bisWalking = false;
			this.StartActivity(activity);
		}
	}
	public void SetDowned(int state, int client = 0)
	{
		this.m_nDowned = state;
		this.UpdateCollision(state || this.m_bCamo);
		
		if(this.m_nDowned == 2)
		{
			this.m_iHasPerk = Cit_None;
			this.m_bThisEntityIgnored = true;
			this.m_iReviveTicks = 99999;
			this.SetActivity("ACT_BUSY_SIT_GROUND", 0.0);
			
			if(this.m_bPathing)
			{
				NPC_StopPathing(this.index);
				this.m_bPathing = false;
			}
			
			int glow = this.m_iTeamGlow;
			if(glow > 0)
				AcceptEntityInput(glow, "Disable");
			
			if(this.m_iWearable1 > 0)
				AcceptEntityInput(this.m_iWearable1, "Disable");
			
			if(this.m_iWearable3 > 0)
				RemoveEntity(this.m_iWearable3);
			
			SetEntityRenderMode(this.index, RENDER_NONE);
		}
		else if(this.m_nDowned)
		{
			this.m_iHasPerk = Cit_None;
			this.m_bThisEntityIgnored = true;
			this.m_iReviveTicks = 250;
			this.SetActivity("ACT_BUSY_SIT_GROUND", 0.0);
			this.AddGesture("ACT_BUSY_SIT_GROUND_ENTRY");
			
			if(this.m_bPathing)
			{
				NPC_StopPathing(this.index);
				this.m_bPathing = false;
			}
			
			int glow = this.m_iTeamGlow;
			if(glow > 0)
				AcceptEntityInput(glow, "Disable");
			
			if(this.m_iWearable1 > 0)
				AcceptEntityInput(this.m_iWearable1, "Disable");
			
			if(this.m_iWearable3 > 0)
				RemoveEntity(this.m_iWearable3);
			
			this.m_iWearable3 = TF2_CreateGlow(this.index);
			
			SetVariantColor(view_as<int>({0, 255, 0, 255}));
			AcceptEntityInput(this.m_iWearable3, "SetGlowColor");
			
			SetEntityRenderMode(this.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(this.index, 255, 255, 255, 125);
		}
		else
		{
			if(this.m_bHero && this.m_iGunType == Cit_None)
				Store_FindBarneyAGun(this.index, this.m_iGunValue, CurrentCash / 3, false);
			
			this.m_bThisEntityIgnored = false;
			if(!this.m_bAlyx)
			{
				this.SetActivity("ACT_BUSY_SIT_GROUND_EXIT", 0.0);
				this.SetPlaybackRate(2.0);
				this.m_flReloadDelay = GetGameTime(this.index) + 1.2;
			}
			
			int glow = this.m_iTeamGlow;
			if(glow > 0)
				AcceptEntityInput(glow, "Enable");
			
			if(this.m_iWearable1 > 0)
				AcceptEntityInput(this.m_iWearable1, "Enable");
			
			if(this.m_iWearable3 > 0)
			{
				RemoveEntity(this.m_iWearable3);
				
				SetEntProp(this.index, Prop_Data, "m_iHealth", 50);
				if(!this.m_bHero)
				{
					SetEntityRenderColor(this.index, 255, 255, 255, 255);
					SetEntityRenderMode(this.index, RENDER_NORMAL);
				}
			}
			else if(client)
			{
				this.PlaySound(Cit_Found);
				Items_GiveNPCKill(client, CITIZEN);
			}

			if(this.m_bHero)
				this.UpdateModel();
			
			IgnorePlayer[client] = false;
		}
	}
	public bool CanTalk()
	{
		return this.m_fTalkTimeIn < GetGameTime(this.index);
	}
	public void PlaySound(int type)
	{
		float gameTime = GetGameTime(this.index);
		if(this.m_fTalkTimeIn < gameTime)
		{
			this.m_fTalkTimeIn = gameTime + 3.0;
			
			char buffer[PLATFORM_MAX_PATH];
			if(this.m_bBarney)
			{
				Barney_GenerateSound(type, GetURandomInt(), buffer, sizeof(buffer));
			}
			else if(this.m_bAlyx)
			{
				Alyx_GenerateSound(type, GetURandomInt(), buffer, sizeof(buffer));
			}
			else
			{
				Citizen_GenerateSound(type, GetURandomInt(), this.m_bFemale, buffer, sizeof(buffer));
			}
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

int Citizen_SpawnAtPoint(const char[] data = "", int client = 0)
{
	int count;
	int[] list = new int[i_MaxcountSpawners];

	if(client)
	{
		list[count++] = client;
	}
	else
	{
		for(int i; i < i_MaxcountSpawners; i++)
		{
			int entity = i_ObjectsSpawners[i];
			if(IsValidEntity(entity))
			{
				if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetEntProp(entity, Prop_Data, "m_iTeamNum") == 2)
					list[count++] = entity;
			}
		}
		
		if(!count)
		{
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsClientInGame(target) && IsPlayerAlive(target))
					list[count++] = target;
			}
		}
	}
	
	if(count)
	{
		int entity = list[GetURandomInt() % count];
		
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		
		entity = Npc_Create(CITIZEN, client, pos, ang, true, data);
		
		if(IsValidEntity(entity))
		{
			Citizen npc = view_as<Citizen>(entity);
			
			npc.m_iWearable3 = TF2_CreateGlow(npc.index);
				
			SetVariantColor(view_as<int>({0, 255, 0, 255}));
			AcceptEntityInput(npc.m_iWearable3, "SetGlowColor");
				
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);

			return entity;
		}
	}

	return -1;
}

bool Citizen_ThatIsDowned(int entity)
{
	return (i_NpcInternalId[entity] == CITIZEN && view_as<Citizen>(entity).m_nDowned);
}

int Citizen_ReviveTicks(int entity, int amount, int client)
{
	Citizen npc = view_as<Citizen>(entity);
	npc.m_iReviveTicks -= amount;
	if(npc.m_iReviveTicks < 1)
		npc.SetDowned(0, client);
	
	return npc.m_iReviveTicks;
}

int Citizen_ShowInteractionHud(int entity, int client)
{
	if(i_NpcInternalId[entity] == CITIZEN)
	{
		Citizen npc = view_as<Citizen>(entity);
		
		if(npc.m_nDowned == 2)
		{
			return 0;
		}
		else if(npc.m_nDowned == 1)
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
		
		if(npc.m_nDowned)
			return 0;
		
		return npc.m_iBuildingType;
	}
	return 0;
}

bool Citizen_Interact(int client, int entity)
{
	if(i_NpcInternalId[entity] == CITIZEN)
	{
		Citizen npc = view_as<Citizen>(entity);
		
		if(!npc.m_nDowned)
		{
			IgnorePlayer[client] = false;

			if(!npc.m_bAlyx)
			{
				npc.PlaySound(Cit_Greet);
				Store_OpenGiftStore(client, npc.index, npc.m_iGunValue, npc.m_bHero);
				return true;
			}
		}
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
	npc.UpdateCollision(npc.m_bCamo);
	
	npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
	npc.UpdateModel();
	
	npc.SetActivity("ACT_PICKUP_RACK", 0.0);
	
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
	if(IsValidEntity(npc.m_iWearable2))
	{
		SDKUnhook(npc.m_iWearable2, SDKHook_SetTransmit, ParticleTransmit);
		SDKHook(npc.m_iWearable2, SDKHook_SetTransmit, ParticleTransmitCitizen);
	}
	return true;
}


bool Citizen_UpdateWeaponStats(int entity, int type, int sell, const ItemInfo info, int userid)
{
	Citizen npc = view_as<Citizen>(entity);
	
	if(npc.m_nDowned || type <= Cit_None)
		return false;
	
	if(type > 9)
		return Citizen_GivePerk(entity, type - 10);
	
	npc.m_iGunType = type;
	npc.m_iGunValue = sell;
	npc.m_iGunSeller = userid;
	
	Building_ClearRefBuffs(EntIndexToEntRef(entity));
	
	int wave = 90;
	
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
		
		int health = 1700 + (amount / 20);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		
		npc.m_iGunValue += amount;
		npc.m_fGunDamage = 2000.0 + (float(amount) / 10.0);
		npc.m_fGunFirerate = 0.45;
		npc.m_fGunReload = 0.0;
		npc.m_iGunClip = -1;
	}
	else
	{
		int health = (npc.m_bAlyx ? 400 : 200) + npc.m_iGunValue / 20;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		
		WeaponData data;
		if(Config_CreateNPCStats(info.Classname, info.Attrib, info.Value, info.Attribs, data))
		{
			npc.m_fGunDamage = data.Damage * data.Pellets;
			npc.m_fGunFirerate = data.FireRate;
			npc.m_fGunReload = 1.0;//data.Reload;
			npc.m_iGunClip = RoundFloat(data.Clip);
		}
		
		wave = Rogue_GetRoundScale() + 1;
		if(wave > 90)
			wave = 90;
		
		if(npc.m_bAlyx)
			wave += 15;
	}
	
	npc.m_fGunRangeBonus = 1.0;
	npc.m_iAttacksTillReload = npc.m_iGunClip;
	npc.m_bFirstBlood = false;
	npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
	npc.m_fGunDamage *= 1.0 + float(wave / 15);

	Rogue_AllySpawned(npc.index);
	
	npc.UpdateModel();
	npc.PlaySound(Cit_NewWeapon);
	
	npc.SetActivity("ACT_PICKUP_RACK", 0.0);
	
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

void Citizen_SetupStart()
{
	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[i] == CITIZEN)
		{
			Citizen npc = view_as<Citizen>(i);
			if(npc.m_bHero && !npc.m_nDowned && IsValidEntity(i))
			{
				int found;
				float distance = FAR_FUTURE;
				float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
				float vecTarget[3];
				int entity = MaxClients + 1;
				while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
				{
					if(i_NpcInternalId[entity] == CITIZEN && view_as<Citizen>(entity).m_iBuildingType == 7)
					{
						vecTarget = WorldSpaceCenter(entity);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(!found || dist < distance)
						{
							distance = dist;
							found = entity;
						}
					}
				}
				
				static char buffer[32];
				entity = MaxClients + 1;
				while((entity = FindEntityByClassname(entity, "obj_dispenser")) != -1)
				{
					GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
					if(!StrContains(buffer, "zr_packapunch"))
					{
						vecTarget = WorldSpaceCenter(entity);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(!found || dist < distance)
						{
							distance = dist;
							found = entity;
						}
					}
				}
				
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						entity = EntRefToEntIndex(Building_Mounted[client]);
						if(IsValidEntity(entity))
						{
							GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
							if(!StrContains(buffer, "zr_packapunch"))
							{
								vecTarget = WorldSpaceCenter(client);
								float dist = GetVectorDistance(vecTarget, vecMe, true);
								if(!found || dist < distance)
								{
									distance = dist;
									found = client;
								}
							}
						}
					}
				}
				
				if(Store_FindBarneyAGun(npc.index, npc.m_iGunValue, RoundToFloor(float(CurrentCash) * GetRandomFloat(npc.m_bAlyx ? 0.3 : 0.22, npc.m_bAlyx ? 0.4 : 0.3)), view_as<bool>(found)))
				{
					npc.m_iTargetAlly = found;
					npc.m_bSeakingGeneric = true;
				}
			}
		}
	}
}

public void Citizen_ClotThink(int iNPC)
{
	Citizen npc = view_as<Citizen>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_nDowned)
	{
		npc.m_iTargetAlly = 0;
		npc.m_bSeakingMedic = false;
		npc.m_bSeakingGeneric = false;
		npc.m_bGetClosestTargetTimeAlly = true;
		
		if(npc.m_nDowned != 2)
		{
			if(npc.m_flidle_talk == FAR_FUTURE)
			{
				npc.m_flidle_talk = gameTime + 30.0 + (float(npc.m_iSeed) / 214748364.7);
			}
			else if(npc.m_flidle_talk < gameTime)
			{
				npc.PlaySound(Cit_Lost);
				npc.m_flidle_talk = FAR_FUTURE;
			}
		}
		return;
	}

	if(npc.m_flAttackHappens)
	{
		npc.m_iTargetAlly = 0;
		npc.m_bSeakingMedic = false;
		npc.m_bSeakingGeneric = false;
		npc.m_bGetClosestTargetTimeAlly = true;
		
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
						KillFeed_SetKillIcon(npc.index, "wrench_jag");
						SDKHooks_TakeDamage(target, npc.index, GetClientOfUserId(npc.m_iGunSeller), npc.m_fGunDamage, DMG_SLASH, -1, _, vecHit);
						
						//Did we kill them?
						if(GetEntProp(target, Prop_Data, "m_iHealth") < 1)
						{
							if((npc.m_bBarney || !npc.m_bFirstBlood) && npc.CanTalk())
							{
								npc.m_bFirstBlood = true;
								npc.PlaySound(Cit_FirstBlood);
							}
							
							int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
							int health = GetEntProp(npc.index, Prop_Data, "m_iHealth") + (maxhealth / 15);
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
			if(IsValidEnemy(npc.index, npc.m_iTarget, npc.m_bCamo))
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 500.0);
			
			return;
		}
	}

	if(npc.m_flReloadDelay > gameTime)
	{
		npc.m_iTargetAlly = 0;
		npc.m_bSeakingMedic = false;
		npc.m_bSeakingGeneric = false;
		npc.m_bGetClosestTargetTimeAlly = true;

		if(npc.m_bPathing)
		{
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
		}
		return;
	}

	// See if our target is still valid
	if(npc.m_iTarget && (npc.m_iGunType == Cit_None || !IsValidEnemy(npc.index, npc.m_iTarget, npc.m_bCamo)))
	{
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_bGetClosestTargetTimeAlly = true;
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		if(npc.m_iGunType != Cit_None)
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _, npc.m_bCamo ? FAR_FUTURE : (BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus), npc.m_bCamo, _, _, _, true);
			if(npc.m_iTarget > 0 && view_as<CClotBody>(npc.m_iTarget).m_bCamo)
				npc.PlaySound(Cit_Behind);
		}
	}

	// See if our ally is still valid
	if(npc.m_iTargetAlly)
	{
		if(npc.m_iTargetAlly > MaxClients)
		{
			if(!IsValidEntity(npc.m_iTargetAlly))
			{
				npc.m_iTargetAlly = 0;
				npc.m_bSeakingMedic = false;
				npc.m_bSeakingGeneric = false;
				npc.m_bGetClosestTargetTimeAlly = true;
			}
		}
		else if(!IsValidClient(npc.m_iTargetAlly) ||
		        dieingstate[npc.m_iTargetAlly] ||
			!IsPlayerAlive(npc.m_iTargetAlly))
		{
			npc.m_iTargetAlly = 0;
			npc.m_bSeakingMedic = false;
			npc.m_bSeakingGeneric = false;
			npc.m_bGetClosestTargetTimeAlly = true;
		}
	}

	bool combat = !Waves_InSetup();
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	bool injured = (health < 60) || (health < (maxhealth / 5));
	float distance = 100000000.0;
	float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);

	int walkStatus;
	int reloadStatus;
	int healingTarget;
	float vecTarget[3];
	static char buffer[32];

	if(npc.m_iGunClip > 0)
	{
		if(npc.m_iAttacksTillReload == 0)
		{
			reloadStatus = 2;	// I need to reload now
		}
		else if(npc.m_iAttacksTillReload != npc.m_iGunClip)
		{
			reloadStatus = 1;	// Reload when free
		}
	}

	if(npc.m_bSeakingMedic)
	{
		healingTarget = npc.m_iTargetAlly;	// We already wanted to heal
	}
	else if((!combat && health >= maxhealth) || (combat && health > maxhealth * 3 / 5))
	{
		healingTarget = -1;	// I'm high, tank a bit
	}
	else if(injured && npc.m_bGetClosestTargetTimeAlly)	// I'm low, find healing
	{
		//distance = 100000000.0;
		int entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
		{
			if((i_NpcInternalId[entity] == CITIZEN && view_as<Citizen>(entity).m_iBuildingType == 7) ||
				i_NpcInternalId[entity] == BOB_THE_GOD_OF_GODS &&
				HealingCooldown[entity] < gameTime)
			{
				vecTarget = WorldSpaceCenter(entity);
				float dist = GetVectorDistance(vecTarget, vecMe, true);
				if(dist < distance)
				{
					distance = dist;
					healingTarget = entity;
				}
			}
		}
		
		entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "obj_sentrygun")) != -1)
		{
			if(HealingCooldown[entity] < gameTime)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrContains(buffer, "zr_healingstation"))
				{
					vecTarget = WorldSpaceCenter(entity);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < distance)
					{
						distance = dist;
						healingTarget = entity;
					}
				}
			}
		}
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(HealingCooldown[client] < gameTime && IsClientInGame(client))
			{
				entity = EntRefToEntIndex(Building_Mounted[client]);
				if(IsValidEntity(entity))
				{
					GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
					if(!StrContains(buffer, "zr_healingstation"))
					{
						vecTarget = WorldSpaceCenter(client);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
						{
							distance = dist;
							healingTarget = client;
						}
					}
				}
			}
		}
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget, npc.m_bCamo))
	{
		npc.m_flidle_talk = FAR_FUTURE;
		vecTarget = WorldSpaceCenter(npc.m_iTarget);
		distance = GetVectorDistance(vecTarget, vecMe, true);
		//todo, rewrite npcs so itdoes this code outside of this, i filtered out invinceable enemies.
		if(RunFromNPC(npc.m_iTarget) && view_as<SawRunner>(npc.m_iTarget).m_iTarget == npc.index && distance < 250000.0)
		{
			walkStatus = 69;	// Sawrunner spotted us
		}
		else
		{
			switch(npc.m_iGunType)
			{
				case Cit_Melee:
				{
					if(distance < (14500.0 * npc.m_fGunRangeBonus))
					{
						npc.SetActivity("ACT_MELEE_ANGRY_MELEE", 0.0);
						walkStatus = -1;	// Don't move
						
						npc.FaceTowards(vecTarget, 500.0);

						if(npc.m_flNextMeleeAttack < gameTime)
						{
							npc.AddGesture("ACT_MELEE_ATTACK_SWING");
							
							npc.PlayMeleeSound();
							
							npc.m_flAttackHappens = gameTime + 0.2;
							npc.m_flReloadDelay = gameTime + 0.45;
							npc.m_flNextMeleeAttack = gameTime + (npc.m_fGunFirerate * npc.m_fGunBonusFireRate);
							
							if(npc.m_flReloadDelay > npc.m_flNextMeleeAttack)
								npc.m_flReloadDelay = npc.m_flNextMeleeAttack;
								
							if(npc.m_flAttackHappens > npc.m_flNextMeleeAttack)
								npc.m_flAttackHappens = npc.m_flNextMeleeAttack;
						}
						
						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Enable");
					}
					else if(healingTarget < 1)	// Don't try to melee more if we're injured
					{
						npc.SetActivity("ACT_RUN_CROUCH", 240.0);
						walkStatus = 1;	// Walk up
						
						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Enable");
					}
				}
				case Cit_Pistol:
				{
					if(npc.m_flNextRangedAttack > gameTime)	// On cooldown
					{
						npc.FaceTowards(vecTarget, 500.0);
						npc.SetActivity("ACT_RANGE_ATTACK_PISTOL", 0.0);
						walkStatus = -1;	// Don't move

						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Enable");
					}
					else if(reloadStatus == 2)	// We need to reload now
					{
						if(!npc.m_bCamo && healingTarget != -1 && distance < 150000.0)
						{
							// Too close to safely reload
							npc.SetActivity("ACT_RUN", 240.0);
							walkStatus = 3;	// Back off
						}

						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Disable");
					}
					else if(!npc.m_bCamo && distance < 22500.0)	// Too close for the Pistol
					{
						npc.SetActivity("ACT_RUN", 240.0);
						walkStatus = 3;	// Back off
						
						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Disable");
					}
					else	// Try to shoot
					{
						float npc_pos[3];
						npc_pos = GetAbsOrigin(npc.index);
							
						npc_pos[2] += 30.0;
						
						Handle trace = TR_TraceRayFilterEx(npc_pos, vecTarget, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
						
						int enemy = TR_GetEntityIndex(trace);
						delete trace;
						
						if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
						{
							KillFeed_SetKillIcon(npc.index, "pistol");
							npc.FaceTowards(vecTarget, 15000.0);
							npc.SetActivity("ACT_RANGE_ATTACK_PISTOL", 0.0);
							walkStatus = -1;	// Don't move
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Enable");
							
							npc.m_iState = -1;
							npc.AddGesture("ACT_RANGE_ATTACK_PISTOL");
							
							float vecSpread = 0.1;
								
							float eyePitch[3];
							GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
							
							float x, y;
							x = GetRandomFloat( -0.1, 0.1 );
							y = GetRandomFloat( -0.1, 0.1 );
							
							float vecDirShooting[3], vecRight[3], vecUp[3];
							
							vecTarget[2] += 15.0;
							MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
							GetVectorAngles(vecDirShooting, vecDirShooting);
							vecDirShooting[1] = eyePitch[1];
							GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
							
							npc.m_flNextRangedAttack = gameTime + (npc.m_fGunFirerate * npc.m_fGunBonusFireRate);
							npc.m_iAttacksTillReload--;
							
							//add the spray
							float vecDir[3];
							vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_SLASH, "bullet_tracer01_red", GetClientOfUserId(npc.m_iGunSeller), _, "muzzle");
							npc.PlayPistolSound();
							
							if((npc.m_bBarney || !npc.m_bFirstBlood) && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
							{
								npc.m_bFirstBlood = true;
								npc.PlaySound(Cit_FirstBlood);
							}
						}
						else
						{
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Disable");
						}
					}
				}
				case Cit_SMG:
				{
					bool cooldown = npc.m_flNextRangedAttack > gameTime;
					if(reloadStatus == 2 && !cooldown)	// We need to reload now
					{
						if(!npc.m_bCamo && healingTarget != -1 && distance < 150000.0)
						{
							// Too close to safely reload
							npc.SetActivity("ACT_RUN_RIFLE", 210.0);
							walkStatus = 3;	// Back off
						}
					}
					else
					{
						if(!npc.m_bCamo && distance < 150000.0)	// Too close, walk backwards
						{
							npc.SetActivity("ACT_WALK_AIM_RIFLE", 90.0);
							walkStatus = 2;	// Back off
						}
						else
						{
							npc.SetActivity((npc.m_iSeed % 5) ? "ACT_IDLE_ANGRY_SMG1" : "ACT_IDLE_AIM_RIFLE_STIMULATED", 0.0);
							walkStatus = -1;	// Don't move
						}

						if(!cooldown)
						{
							float npc_pos[3];
							npc_pos = GetAbsOrigin(npc.index);
								
							npc_pos[2] += 30.0;
							
							Handle trace = TR_TraceRayFilterEx(npc_pos, vecTarget, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
							
							int enemy = TR_GetEntityIndex(trace);
							delete trace;
							
							if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
							{
								KillFeed_SetKillIcon(npc.index, "smg");
								npc.FaceTowards(vecTarget, 15000.0);
								npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
								
								float vecSpread = 0.1;
									
								float eyePitch[3];
								GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
								
								float x, y;
								x = GetRandomFloat( -0.2, 0.2 );
								y = GetRandomFloat( -0.2, 0.2 );
								
								float vecDirShooting[3], vecRight[3], vecUp[3];
								
								vecTarget[2] += 15.0;
								MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
								GetVectorAngles(vecDirShooting, vecDirShooting);
								vecDirShooting[1] = eyePitch[1];
								GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
								
								npc.m_flNextRangedAttack = gameTime + (npc.m_fGunFirerate * npc.m_fGunBonusFireRate);
								npc.m_iAttacksTillReload--;
								
								float vecDir[3];
								vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
								vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
								vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
								NormalizeVector(vecDir, vecDir);
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_SLASH, "bullet_tracer01_red", GetClientOfUserId(npc.m_iGunSeller), _ , "muzzle");
								npc.PlaySMGSound();
								
								if((npc.m_bBarney || !npc.m_bFirstBlood) && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
						}
					}
				}
				case Cit_AR:
				{
					bool cooldown = npc.m_flNextRangedAttack > gameTime;
					if(reloadStatus == 2 && !cooldown)	// We need to reload now
					{
						if(!npc.m_bCamo && healingTarget != -1 && distance < 150000.0)
						{
							// Too close to safely reload
							npc.SetActivity("ACT_RUN_AR2", 210.0);
							walkStatus = 3;	// Back off
						}
					}
					else
					{
						if(!npc.m_bCamo && distance < 150000.0)	// Too close, walk backwards
						{
							npc.SetActivity("ACT_WALK_AIM_AR2", 90.0);
							walkStatus = 2;	// Back off
						}
						else
						{
							npc.SetActivity("ACT_IDLE_ANGRY_AR2", 0.0);
							walkStatus = -1;	// Don't move
						}

						if(!cooldown)
						{
							float npc_pos[3];
							npc_pos = GetAbsOrigin(npc.index);
								
							npc_pos[2] += 30.0;
							
							Handle trace = TR_TraceRayFilterEx(npc_pos, vecTarget, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
							
							int enemy = TR_GetEntityIndex(trace);
							delete trace;
							
							if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
							{
								KillFeed_SetKillIcon(npc.index, "panic_attack");
								npc.FaceTowards(vecTarget, 15000.0);
								npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
								
								float vecSpread = 0.1;
									
								float eyePitch[3];
								GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
								
								float x, y;
								x = GetRandomFloat( -0.15, 0.15 );
								y = GetRandomFloat( -0.15, 0.15 );
								
								float vecDirShooting[3], vecRight[3], vecUp[3];
								
								vecTarget[2] += 15.0;
								MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
								GetVectorAngles(vecDirShooting, vecDirShooting);
								vecDirShooting[1] = eyePitch[1];
								GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
								
								npc.m_flNextRangedAttack = gameTime + (npc.m_fGunFirerate * npc.m_fGunBonusFireRate);
								npc.m_iAttacksTillReload--;
								
								float vecDir[3];
								vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
								vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
								vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
								NormalizeVector(vecDir, vecDir);
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_SLASH, "bullet_tracer01_red", GetClientOfUserId(npc.m_iGunSeller), _ , "muzzle");
								npc.PlayARSound();
								
								if((npc.m_bBarney || !npc.m_bFirstBlood) && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
						}
					}
				}
				case Cit_Shotgun:
				{
					if(npc.m_flNextRangedAttack > gameTime)	// On cooldown
					{
						npc.FaceTowards(vecTarget, 500.0);
						npc.SetActivity("ACT_IDLE_ANGRY_AR2", 0.0);
						walkStatus = -1;	// Don't move
					}
					else if(reloadStatus == 2)	// We need to reload now
					{
						if(!npc.m_bCamo && healingTarget != -1 && distance < 150000.0)
						{
							// Too close to safely reload
							npc.SetActivity("ACT_RUN_AR2", 210.0);
							walkStatus = 3;	// Back off
						}
					}
					else	// Try to shoot
					{
						float npc_pos[3];
						npc_pos = GetAbsOrigin(npc.index);
							
						npc_pos[2] += 30.0;
						
						Handle trace = TR_TraceRayFilterEx(npc_pos, vecTarget, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
						
						int enemy = TR_GetEntityIndex(trace);
						delete trace;
						
						if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
						{
							KillFeed_SetKillIcon(npc.index, "shotgun_primary");
							npc.FaceTowards(vecTarget, 15000.0);
							npc.SetActivity("ACT_IDLE_ANGRY_AR2", 0.0);
							walkStatus = -1;	// Don't move
							
							npc.m_iState = -1;
							npc.AddGesture("ACT_RANGE_ATTACK_SHOTGUN");
							
							float vecSpread = 0.1;
								
							float eyePitch[3];
							GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
							
							float x, y;
							x = GetRandomFloat( -0.25, 0.25 );
							y = GetRandomFloat( -0.25, 0.25 );
							
							float vecDirShooting[3], vecRight[3], vecUp[3];
							
							vecTarget[2] += 15.0;
							MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
							GetVectorAngles(vecDirShooting, vecDirShooting);
							vecDirShooting[1] = eyePitch[1];
							GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
							
							npc.m_flNextRangedAttack = gameTime + (npc.m_fGunFirerate * npc.m_fGunBonusFireRate);
							npc.m_iAttacksTillReload--;
							
							//add the spray
							float vecDir[3];
							vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.m_fGunDamage, 9000.0, DMG_SLASH, "bullet_tracer01_red", GetClientOfUserId(npc.m_iGunSeller), _ , "muzzle");
							npc.PlayShotgunSound();
							
							if((npc.m_bBarney || !npc.m_bFirstBlood) && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
							{
								npc.m_bFirstBlood = true;
								npc.PlaySound(Cit_FirstBlood);
							}
						}
					}
				}
				case Cit_RPG:
				{
					if(npc.m_flNextRangedAttack > gameTime)	// On cooldown
					{
						npc.FaceTowards(vecTarget, 500.0);
						npc.SetActivity("ACT_IDLE_ANGRY_RPG", 0.0);
						walkStatus = -1;	// Don't move
					}
					else if(reloadStatus == 2)	// We need to reload now
					{
						if(!npc.m_bCamo && healingTarget != -1 && distance < 150000.0)
						{
							// Too close to safely reload
							npc.SetActivity("ACT_RUN_RPG", 240.0);
							walkStatus = 3;	// Back off
						}
					}
					else if(!npc.m_bCamo && distance < 22500.0)	// Too close for the RPG
					{
						npc.SetActivity("ACT_RUN_RPG", 240.0);
						walkStatus = 3;	// Back off
					}
					else	// Try to shoot
					{
						float npc_pos[3];
						npc_pos = GetAbsOrigin(npc.index);
							
						npc_pos[2] += 30.0;
						
						Handle trace = TR_TraceRayFilterEx(npc_pos, vecTarget, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
						
						int enemy = TR_GetEntityIndex(trace);
						delete trace;
						
						if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
						{
							KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
							npc.FaceTowards(vecTarget, 15000.0);
							npc.SetActivity("ACT_IDLE_ANGRY_RPG", 0.0);
							walkStatus = -1;	// Don't move
							
							npc.m_iState = -1;
							npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_RPG");

							npc.m_flNextRangedAttack = gameTime + (npc.m_fGunFirerate * npc.m_fGunBonusFireRate);
							npc.m_iAttacksTillReload--;
							
							npc.FireRocket(vecTarget, npc.m_fGunDamage, 1100.0, _, _, EP_DEALS_SLASH_DAMAGE, _, GetClientOfUserId(npc.m_iGunSeller));
							npc.PlayRPGSound();
						}
					}
				}
			}
		}
	}

	if(!walkStatus)	// Reload/healing actions
	{
		if(reloadStatus)	// Reload
		{
			npc.m_iAttacksTillReload = npc.m_iGunClip;
			walkStatus = -1;	// Don't move
			
			switch(npc.m_iGunType)
			{
				case Cit_Pistol:
				{
					npc.SetActivity("ACT_RELOAD_PISTOL", 0.0);
					npc.SetPlaybackRate(2.0);
					npc.m_flReloadDelay = gameTime + (1.4 * (npc.m_fGunReload * npc.m_fGunBonusReload));
					npc.PlayPistolReloadSound();

					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Enable");
					
					if(npc.m_iTarget > 0)
						npc.PlaySound(Cit_Reload);
				}
				case Cit_SMG:
				{
					npc.SetActivity("ACT_RELOAD_SMG1", 0.0);
					npc.SetPlaybackRate(2.0);
					npc.m_flReloadDelay = gameTime + (2.4 * (npc.m_fGunReload * npc.m_fGunBonusReload));
					npc.PlaySMGReloadSound();
					
					if(npc.m_iTarget > 0)
						npc.PlaySound(Cit_Reload);
				}
				case Cit_AR:
				{
					npc.SetActivity("ACT_RELOAD_AR2", 0.0);
					npc.SetPlaybackRate(2.0);
					npc.m_flReloadDelay = gameTime + (1.6 * (npc.m_fGunReload * npc.m_fGunBonusReload));
					npc.PlayARReloadSound();
					
					if(npc.m_iTarget > 0)
						npc.PlaySound(Cit_Reload);
				}
				case Cit_Shotgun:
				{
					npc.SetActivity("ACT_RELOAD_shotgun", 0.0);
					npc.SetPlaybackRate(2.0);
					npc.m_flReloadDelay = gameTime + (2.6 * (npc.m_fGunReload * npc.m_fGunBonusReload));
					npc.PlayShotgunReloadSound();
					
					if(npc.m_iTarget > 0)
						npc.PlaySound(Cit_Reload);
				}
				default:
				{
					npc.SetActivity("ACT_IDLE_ANGRY_RPG", 0.0);
					npc.m_flReloadDelay = gameTime + (npc.m_fGunReload * npc.m_fGunBonusReload);
				}
			}
		}
		else if(npc.m_bSeakingMedic || npc.m_bSeakingGeneric)	// Go up to building
		{
			vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);

			distance = GetVectorDistance(vecTarget, vecMe, true);
			if(distance < 7000.0)
			{
				npc.SetActivity("ACT_CIT_HEAL", 0.0);
				walkStatus = -1;	// Don't move

				HealingCooldown[npc.m_iTargetAlly] = gameTime + 60.0;

				npc.m_iTargetAlly = 0;
				npc.m_bSeakingGeneric = false;
				npc.m_flReloadDelay = gameTime + 1.5;

				if(npc.m_bSeakingMedic)
				{
					npc.m_bSeakingMedic = false;

					health += 100 + (maxhealth / 10);
					if(health > maxhealth)
						health = maxhealth;
				
					SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				}
			}
			else
			{
				walkStatus = 5;	// Run to ally (activity handled)
			}
		}
		else if(healingTarget > 0)	// Set our healing ally
		{
			npc.m_iTargetAlly = healingTarget;
			npc.m_bSeakingMedic = true;
			vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			walkStatus = 5;	// Run to ally (activity handled)
		}
	}

	// Look for Perk Machines
	if(!walkStatus && npc.m_bGetClosestTargetTimeAlly && npc.m_iGunType != Cit_None && npc.m_iHasPerk != npc.m_iGunType)
	{
		distance = 100000000.0;
		int entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
		{
			if(i_NpcInternalId[entity] == CITIZEN && view_as<Citizen>(entity).m_iBuildingType == 5 && HealingCooldown[entity] < gameTime)
			{
				vecTarget = WorldSpaceCenter(entity);
				float dist = GetVectorDistance(vecTarget, vecMe, true);
				if(dist < distance)
				{
					distance = dist;
					npc.m_iTargetAlly = entity;
					npc.m_bSeakingGeneric = true;
				}
			}
		}
		
		entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "obj_dispenser")) != -1)
		{
			if(HealingCooldown[entity] < gameTime)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrContains(buffer, "zr_perkmachine"))
				{
					vecTarget = WorldSpaceCenter(entity);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < distance)
					{
						distance = dist;
						npc.m_iTargetAlly = entity;
						npc.m_bSeakingGeneric = true;
					}
				}
			}
		}
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(HealingCooldown[client] < gameTime && IsClientInGame(client))
			{
				entity = EntRefToEntIndex(Building_Mounted[client]);
				if(IsValidEntity(entity))
				{
					GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
					if(!StrContains(buffer, "zr_perkmachine"))
					{
						vecTarget = WorldSpaceCenter(client);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
						{
							distance = dist;
							npc.m_iTargetAlly = client;
							npc.m_bSeakingGeneric = true;
						}
					}
				}
			}
		}

		if(npc.m_bSeakingGeneric)
		{
			vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			walkStatus = 5;	// Run to ally (activity handled)
			npc.m_iHasPerk = npc.m_iGunType;
		}
	}

	if(!walkStatus && npc.m_bGetClosestTargetTimeAlly && npc.m_iArmorErosion > 0)
	{
		distance = 100000000.0;
		int entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
		{
			if(i_NpcInternalId[entity] == CITIZEN && view_as<Citizen>(entity).m_iBuildingType == 1 && HealingCooldown[entity] < gameTime)
			{
				vecTarget = WorldSpaceCenter(entity);
				float dist = GetVectorDistance(vecTarget, vecMe, true);
				if(dist < distance)
				{
					distance = dist;
					npc.m_iTargetAlly = entity;
					npc.m_bSeakingGeneric = true;
				}
			}
		}
		
		entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "obj_dispenser")) != -1)
		{
			if(HealingCooldown[entity] < gameTime)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(!StrContains(buffer, "zr_armortable"))
				{
					vecTarget = WorldSpaceCenter(entity);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < distance)
					{
						distance = dist;
						npc.m_iTargetAlly = entity;
						npc.m_bSeakingGeneric = true;
					}
				}
			}
		}
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(HealingCooldown[client] < gameTime && IsClientInGame(client))
			{
				entity = EntRefToEntIndex(Building_Mounted[client]);
				if(IsValidEntity(entity))
				{
					GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
					if(!StrContains(buffer, "zr_armortable"))
					{
						vecTarget = WorldSpaceCenter(client);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
						{
							distance = dist;
							npc.m_iTargetAlly = client;
							npc.m_bSeakingGeneric = true;
						}
					}
				}
			}
		}

		if(npc.m_bSeakingGeneric)
		{
			vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			walkStatus = 5;	// Run to ally (activity handled)
			npc.m_iArmorErosion = 0;
		}
	}

	// Go to ally players
	if(!walkStatus)
	{
		if(npc.m_bGetClosestTargetTimeAlly || !npc.m_iTargetAlly || !IsValidAlly(npc.index, npc.m_iTargetAlly))
		{
			npc.m_iTargetAlly = 0;
			npc.m_bSeakingGeneric = false;
			npc.m_bSeakingMedic = false;

			distance = 65000000.0;
			for(int client = 1; client <= MaxClients; client++)
			{
				if(!IgnorePlayer[client] && IsClientInGame(client) && IsEntityAlive(client))
				{
					vecTarget = WorldSpaceCenter(client);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < distance)
					{
						distance = dist;
						npc.m_iTargetAlly = client;
					}
				}
			}
		}
		
		if(npc.m_iTargetAlly > 0)
		{
			vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			distance = GetVectorDistance(vecTarget, vecMe, true);
			if(distance > 200000.0 || (combat && distance > 60000.0))
			{
				walkStatus = 5;	// Run to ally (activity handled)
			}
			else if(distance > 20000.0 || (combat && distance > (6000.0 + (fabs(float(npc.m_iSeed)) / 2147483.647 * 3.0))))
			{
				walkStatus = 4;	// Walk to ally (activity handled)

				int entity = MaxClients + 1;
				float vecTarget2[3];
				while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
				{
					if(i_NpcInternalId[entity] == CITIZEN)
					{
						vecTarget2 = WorldSpaceCenter(entity);
						distance = GetVectorDistance(vecTarget2, vecMe, true);
						if(distance < 6000.0 && !combat)
						{
							walkStatus = 0;
							break;
						}
						
						if(distance < 20000.0)
						{
							vecTarget = vecTarget2;
							break;
						}
					}
				}
			}
		}
	}

	switch(walkStatus)
	{
		case 69:	// Sawrunner spotted us
		{
			npc.m_bAllowBackWalking = false;
			npc.m_flidle_talk = FAR_FUTURE;

			npc.SetActivity("ACT_RUN_PANICKED", 260.0);

			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.PlaySound(Cit_CadeDeath);
				npc.m_flNextMeleeAttack = gameTime + 10.0;
			}

			npc.m_bAllowBackWalking = true;
			
			vecTarget = BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vecTarget);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 5:	// Run up to our ally
		{
			npc.m_bAllowBackWalking = false;
			npc.m_flidle_talk = FAR_FUTURE;
			
			switch(npc.m_iGunType)
			{
				case Cit_SMG:
				{
					npc.SetActivity(combat ? "ACT_RUN_RIFLE" : injured ? "ACT_RUN_RIFLE_STIMULATED" : "ACT_RUN_RIFLE_RELAXED", combat ? 210.0 : 240.0);
				}
				case Cit_AR, Cit_Shotgun:
				{
					npc.SetActivity(combat ? "ACT_RUN_AR2" : injured ? "ACT_RUN_AR2_STIMULATED" : "ACT_RUN_AR2_RELAXED", combat ? 210.0 : 240.0);
				}
				case Cit_RPG:
				{
					npc.SetActivity(combat ? "ACT_RUN_RPG" : "ACT_RUN_RPG_RELAXED", 240.0);
				}
				default:
				{
					npc.SetActivity("ACT_RUN", 240.0);
					
					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Disable");
				}
			}

			NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 4:	// Walk up to our ally
		{
			npc.m_bAllowBackWalking = false;
			npc.m_flidle_talk = FAR_FUTURE;

			switch(npc.m_iGunType)
			{
				case Cit_Melee:
				{
					npc.SetActivity("ACT_WALK_SUITCASE", 90.0);
					
					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
				case Cit_SMG:
				{
					npc.SetActivity(combat ? "ACT_WALK_RIFLE" : injured ? "ACT_WALK_RIFLE_STIMULATED" : "ACT_WALK_RIFLE_RELAXED", 90.0);
				}
				case Cit_AR, Cit_Shotgun:
				{
					npc.SetActivity(combat ? "ACT_WALK_AR2" : injured ? "ACT_WALK_AR2_STIMULATED" : "ACT_WALK_AR2_RELAXED", 90.0);
				}
				case Cit_RPG:
				{
					npc.SetActivity(combat ? "ACT_WALK_RPG" : "ACT_WALK_RPG_RELAXED", 90.0);
				}
				default:
				{
					npc.SetActivity("ACT_WALK", 90.0);
					
					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Disable");
				}
			}
			
			NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 3:	// Walk away against our target
		{
			npc.m_flidle_talk = FAR_FUTURE;
			npc.m_bAllowBackWalking = false;
			
			vecTarget = BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vecTarget);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 2:	// Walk backwards against our target
		{
			npc.m_flidle_talk = FAR_FUTURE;
			npc.m_bAllowBackWalking = true;
			
			vecTarget = BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vecTarget);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 1:	// Walk up to our target
		{
			npc.m_flidle_talk = FAR_FUTURE;
			npc.m_bAllowBackWalking = false;
			
			if(distance > 29000.0)
			{
				NPC_SetGoalEntity(npc.index, npc.m_iTarget);
			}
			else
			{
				vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vecTarget);
			}
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		default:
		{
			if(npc.m_bPathing)
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
		}
	}

	if(!walkStatus)	// We standing, doing nothing
	{
		if(npc.m_flidle_talk == FAR_FUTURE)
			npc.m_flidle_talk = gameTime + 10.0 + (GetURandomFloat() * 10.0) + (float(npc.m_iSeed) / 214748364.7);
		
		switch(npc.m_iGunType)
		{
			case Cit_Melee:
			{
				// TODO: Barney has an issue with ACT_IDLE_SUITCASE, same with Rebels?
				if(combat/* || !npc.m_bBarney*/)
				{
					npc.SetActivity(combat ? "ACT_IDLE_ANGRY_MELEE" : "ACT_IDLE_SUITCASE", 0.0);
					
					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
				else
				{
					npc.SetActivity("ACT_IDLE", 0.0);

					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
			}
			case Cit_SMG:
			{
				npc.SetActivity(combat ? "ACT_IDLE_SMG1" : injured ? "ACT_IDLE_SMG1_STIMULATED" : "ACT_IDLE_SMG1_RELAXED", 0.0);
			}
			case Cit_AR:
			{
				npc.SetActivity(combat ? "ACT_IDLE_AR2" : injured ? "ACT_IDLE_AR2_STIMULATED" : "ACT_IDLE_AR2_RELAXED", 0.0);
			}
			case Cit_Shotgun:
			{
				npc.SetActivity(combat ? "ACT_IDLE_SHOTGUN_AGITATED" : injured ? "ACT_IDLE_SHOTGUN_STIMULATED" : "ACT_IDLE_SHOTGUN_RELAXED", 0.0);
			}
			case Cit_RPG:
			{
				npc.SetActivity(combat ? "ACT_IDLE_RPG" : "ACT_IDLE_RPG_RELAXED", 0.0);
			}
			default:
			{
				npc.SetActivity(combat ? "ACT_IDLE_ANGRY" : "ACT_IDLE", 0.0);
				
				if(npc.m_iWearable1 > 0)
					AcceptEntityInput(npc.m_iWearable1, "Disable");
			}
		}
		
		if(npc.m_flidle_talk < gameTime)
		{
			npc.m_flidle_talk = gameTime + 50.0;

			if(combat)
			{
				if(npc.m_iTargetAlly > 0 && npc.m_iTargetAlly <= MaxClients)
					IgnorePlayer[npc.m_iTargetAlly] = true;
			}

			if(injured)
			{
				npc.PlaySound(Cit_LowHealth);
			}
			else
			{
				int talkingTo;
				distance = 60000.0;
				
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
						talkingTo = client;
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
			npc.FaceTowards(TalkTurnPos[npc.index], 400.0);
	}

	if(npc.m_flSpeed > 0.0)
	{
		npc.SetPlaybackRate(npc.GetRunSpeed() / npc.m_flSpeed);
	}

	npc.m_bGetClosestTargetTimeAlly = false;
}

void Citizen_MiniBossSpawn()
{
	for(int i = MaxClients + 1; i < MAXENTITIES; i++)
	{
		if(i_NpcInternalId[i] == CITIZEN && view_as<Citizen>(i).m_flidle_talk != FAR_FUTURE && IsValidEntity(i))
		{
			view_as<Citizen>(i).PlaySound(Cit_MiniBoss);
			view_as<Citizen>(i).m_flidle_talk += 15.0;
			break;
		}
	}
}

void Citizen_MiniBossDeath(int entity)
{
	int talkingTo;
	float distance;
	
	float vecMe[3]; vecMe = WorldSpaceCenter(entity);
	float vecTarget[3];
	for(int i = MaxClients + 1; i < MAXENTITIES; i++)
	{
		if(i_NpcInternalId[i] == CITIZEN && view_as<Citizen>(i).m_flidle_talk != FAR_FUTURE && IsValidEntity(i))
		{
			vecTarget = WorldSpaceCenter(i);
			float dist = GetVectorDistance(vecTarget, vecMe, true);
			if(!talkingTo || dist < distance)
			{
				talkingTo = i;
				distance = dist;
			}
		}
	}
	
	if(talkingTo)
	{
		view_as<Citizen>(talkingTo).PlaySound(Cit_MiniBossDead);
		view_as<Citizen>(talkingTo).m_flidle_talk += 15.0;
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
			talkingTo = client;
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
				view_as<Citizen>(i).m_flidle_talk = FAR_FUTURE;
				
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
				CreateTimer(2.0, Citizen_DeathTimer, EntIndexToEntRef(talkingTo), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

static bool RunFromNPC(int entity)
{
	return (i_NpcInternalId[entity] == SAWRUNNER ||
		(i_NpcInternalId[entity] == STALKER_COMBINE && b_StaticNPC[entity]) ||
		(i_NpcInternalId[entity] == STALKER_FATHER && b_StaticNPC[entity] && !b_movedelay[entity]));
}

stock void Citizen_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damage < 9999999.0)
	{
		Citizen npc = view_as<Citizen>(victim);
		if(npc.m_nDowned || (attacker > 0 && GetEntProp(victim, Prop_Send, "m_iTeamNum") == GetEntProp(attacker, Prop_Send, "m_iTeamNum")))
		{
			damage = 0.0;
		}
		else
		{
			int value = npc.m_iGunValue - npc.m_iArmorErosion;
			if(value > 10000)
			{
				damage *= 0.75;
			}
			else if(value > 7500)
			{
				damage *= 0.8;
			}
			else if(value > 5000)
			{
				damage *= 0.85;
			}
			else if(value > 2500)
			{
				damage *= 0.9;
			}
			
			if(npc.m_iGunType == Cit_Melee)
			{
				damage *= 0.8;
				if(damagetype & (DMG_CLUB|DMG_SLASH))
				{
					if(npc.m_iGunValue > 10000)
					{
						damage *= 0.65;
					}
					else if(npc.m_iGunValue > 7500)
					{
						damage *= 0.7;
					}
					else if(npc.m_iGunValue > 5000)
					{
						damage *= 0.8;
					}
					else if(npc.m_iGunValue > 2500)
					{
						damage *= 0.9;
					}
				}
			}

			if(npc.m_iHasPerk == Cit_Melee) //overall abit more.
				damage *= 0.9;

			int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
			if(health < 1)
			{
				KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype);
				npc.SetDowned(1);
				damage = 0.0;
			}
			else
			{
				npc.PlaySound(Cit_Hurt);
			}
		}
	}
}

public void Citizen_NPCDeath(int entity)
{
	Citizen npc = view_as<Citizen>(entity);
	
	
	SDKUnhook(npc.index, SDKHook_Think, Citizen_ClotThink);
	
	NPC_StopPathing(npc.index);
	npc.m_bPathing = false;
	
	SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC);
	
	if(npc.m_iWearable1 > 0 && IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(npc.m_iWearable2 > 0 && IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(npc.m_iWearable3 > 0 && IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
