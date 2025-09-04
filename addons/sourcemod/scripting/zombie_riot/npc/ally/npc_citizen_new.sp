#pragma semicolon 1
#pragma newdecls required

#define BARNEY_MODEL	"models/barney.mdl"
#define ALYX_MODEL	"models/alyx.mdl"
#define CAMO_REBEL_DMG_PENALTY 0.65

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

enum
{
	Cit_Fighter = 0,
	Cit_Builder,
	//Cit_Medic = 5
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

static int NPCId;
static int ThereCanBeOnlyOne = -1;
static bool FirstBlood[MAXENTITIES];
static int IsDowned[MAXENTITIES];
static int SeakingObject[MAXENTITIES];
static int HasPerk[MAXENTITIES];
static int ReviveTime[MAXENTITIES];
static int GunType[MAXENTITIES];
static int GunValue[MAXENTITIES];
static int PerkType[MAXENTITIES];
static bool RebelAggressive[MAXENTITIES];
static float GunDamage[MAXENTITIES];
static float GunBonusDamage[MAXENTITIES];
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
static bool IgnorePlayer[MAXPLAYERS];
static int CanBuild[MAXENTITIES];
static int PendingGesture[MAXENTITIES];
static float CommandCooldown[MAXENTITIES];
static bool TempRebel[MAXENTITIES];
static int PlayerRenameWho[MAXPLAYERS];

void Citizen_OnMapStart()
{
	PrecacheModel(BARNEY_MODEL);
	PrecacheModel(ALYX_MODEL);
	Zero(PlayerRenameWho);
	
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

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Rebel");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_citizen");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Citizen(vecPos, vecAng, team, data);
}

methodmap Citizen < CClotBody
{
	public Citizen(float vecPos[3], float vecAng[3], int team, const char[] data)
	{
		if(IsValidEntity(EntRefToEntIndex(ThereCanBeOnlyOne)))
			return view_as<Citizen>(-1);
		
		bool barney = data[0] == 'b';
		bool alyx = data[0] == 'a';
		bool chaos = data[0] == 'c';
		bool temp = data[0] == 't';
		
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
		
		Citizen npc = view_as<Citizen>(CClotBody(vecPos, vecAng, buffer, "1.15", "150", team, true));
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iAnimationState = -1;
		npc.SetActivity("ACT_BUSY_SIT_GROUND", 0.0);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		b_NpcUnableToDie[npc.index] = team == TFTeam_Red;
		 
		func_NPCDeath[npc.index] = Citizen_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Citizen_OnTakeDamage;
		func_NPCThink[npc.index] = Citizen_ClotThink;
		
		int glow = npc.m_iTeamGlow;
		if(glow > 0)
			AcceptEntityInput(glow, "Disable");
		
		if(barney)
		{
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Barney");
		}
		else if(alyx)
		{
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Alyx");
		}
		
		npc.m_iSeed = seed;
		

		npc.m_nDowned = 1;
		npc.m_bThisEntityIgnored = true;
		npc.m_iReviveTicks = 0;
		npc.m_bFirstBlood = false;
		npc.m_iGunType = Cit_None;
		npc.m_iGunValue = 0;
		npc.m_iClassRole = -1;
		npc.m_iWearable1 = -1;
		npc.m_iWearable2 = -1;
		npc.m_iWearable3 = -1;
		npc.m_b_stand_still = false;
		npc.m_iSeakingObject = 0;
		npc.m_iHasPerk = Cit_None;
		GunBonusDamage[npc.index] = 1.0;
		GunBonusFireRate[npc.index] = 1.0;
		GunBonusReload[npc.index] = 1.0;
		GunRangeBonus[npc.index] = 1.0;
		CanBuild[npc.index] = 0;
		PendingGesture[npc.index] = 0;
		Damage_dealt_in_total[npc.index] = 0.0;
		Healing_done_in_total[npc.index] = 0;
		Resupplies_Supplied[npc.index] = 0;
		i_BarricadeHasBeenDamaged[npc.index] = 0;
		i_PlayerDamaged[npc.index] = 0;
		TempRebel[npc.index] = temp;
		
		npc.m_iAttacksTillReload = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_flSpeed = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flidle_talk = 0.0;
		f_NpcTurnPenalty[npc.index] = 3.0;
		
		Zero(HealingCooldown);
		Zero(IgnorePlayer);
		Zero(CommandCooldown);

		if(team != TFTeam_Red || TempRebel[npc.index])
		{
			npc.SetDowned(0);
			if(!chaos)
			{
				npc.m_bStaticNPC = true;
				AddNpcToAliveList(npc.index, 1);
			}
		}
		if(!Waves_Started())
		{
			npc.SetDowned(0);
		}

		if(chaos)
		{
			float flPos[3], flAng[3];
					
			npc.GetAttachment("eyes", flPos, flAng);
			npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {10.0,0.0,-5.0});
			npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {10.0,0.0,-20.0});
			npc.StartPathing();
			SetEntityRenderColor(npc.index, 125, 125, 125, 255);
			npc.m_bRebelAgressive = true;
			npc.m_bStaticNPC = false;
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Chaos Rebel");
		}
		
		return npc;
	}
	property float m_flTeleportCooldownAntiStuck
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
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
	property int m_iClassRole
	{
		public get()		{ return PerkType[this.index]; }
		public set(int value) 	{ PerkType[this.index] = value; }
	}
	property bool m_bRebelAgressive
	{
		public get()		{ return RebelAggressive[this.index]; }
		public set(bool value) 	{ RebelAggressive[this.index] = value; }
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
	property float m_fGunBonusDamage
	{
		public get()		{ return GunBonusDamage[this.index]; }
		public set(float value) 	{ GunBonusDamage[this.index] = value; }
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
	property int m_iSeakingObject
	{
		public get()		{ return SeakingObject[this.index]; }
		public set(int value) 	{ SeakingObject[this.index] = value; }
	}
	property int m_iHasPerk
	{
		public get()		{ return HasPerk[this.index]; }
		public set(int value) 	{ HasPerk[this.index] = value; }
	}
	property int m_iCanBuild
	{
		public get()		{ return CanBuild[this.index]; }
		public set(int value) 	{ CanBuild[this.index] = value; }
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

			if(this.m_iClassRole == Cit_Fighter && (this.m_iHasPerk == Cit_Pistol || this.m_iHasPerk == Cit_Shotgun || this.m_iHasPerk == Cit_RPG))
			{
				fl_Speed[this.index] = value * (this.m_bAlyx ? 1.2 : 1.1);
			}
			else if(this.m_bAlyx)
			{
				fl_Speed[this.index] = value * 1.1;
			}
			else
			{
				fl_Speed[this.index] = value;
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
			if(this.m_iClassRole == Cit_Fighter && (this.m_iHasPerk == Cit_SMG || this.m_iHasPerk == Cit_AR))
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
			this.bCantCollidie = true;
		}
		else
		{
			this.bCantCollidie = false;
		}
	}
	public void UpdateModel()
	{
		if(!this.m_bHero)
		{
			int type = Cit_Unarmed;
			
			if(this.m_iClassRole == Cit_Medic)
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

		if(this.m_bCamo)
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
	public void SetActivity(const char[] animation, float speed, float playback = 1.0, bool Is_sequence = false)
	{
		// Anim breaks if too fast
		if(playback > 2.0)
			playback = 2.0;
		
		if(Is_sequence)
		{
			int sequence = this.LookupSequence(animation);
			if(sequence > 0 && sequence != this.m_iAnimationState)
			{
				this.m_flSpeed = speed;
				this.m_iAnimationState = sequence;
				this.m_bisWalking = false;
				this.m_iActivity = 0;
				
				this.SetSequence(sequence);
				this.SetPlaybackRate(playback);
				this.SetCycle(0.0);
				this.ResetSequenceInfo();
			}
		}
		else
		{
			int activity = this.LookupActivity(animation);
			if(activity > 0 && activity != this.m_iAnimationState)
			{
				this.m_flSpeed = speed;
				this.m_iAnimationState = activity;
				this.m_bisWalking = false;
				this.StartActivity(activity);

				if(playback != 1.0)
					this.SetPlaybackRate(playback);
			}
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
			PendingGesture[this.index] = 1;
			
			if(this.m_bPathing)
			{
				this.StopPathing();
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
			PendingGesture[this.index] = 1;
			
			if(this.m_bPathing)
			{
				this.StopPathing();
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
			if(this.m_bHero || TempRebel[this.index] || GetTeam(this.index) != TFTeam_Red)
				Citizen_SetRandomRole(this.index);
			
			this.m_bThisEntityIgnored = false;
			PendingGesture[this.index] = 2;
			this.m_flReloadDelay = GetGameTime(this.index) + 0.8;
			
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
				}

				if(client)
					HealEntityGlobal(client, client, float(ReturnEntityMaxHealth(client)) * 0.1, 1.0, 1.0, HEAL_ABSOLUTE);
				
				HealEntityGlobal(client ? client : this.index, this.index, ReturnEntityMaxHealth(this.index) * 0.2, 1.0, 1.0, HEAL_ABSOLUTE);
				int ent = this.index;
				Rogue_TriggerFunction(Artifact::FuncRevive, ent);

				i_npcspawnprotection[this.index] = NPC_SPAWNPROT_UNSTUCK;
				CreateTimer(2.0, Remove_Spawn_Protection, EntIndexToEntRef(this.index), TIMER_FLAG_NO_MAPCHANGE);
			}
			else if(client)
			{
				this.PlaySound(Cit_Found);
			}

			SetEntityRenderMode(this.index, RENDER_NORMAL);

			this.UpdateModel();
			
			if(client > 0 && client <= MaxClients)
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
	public float GetDamage()
	{
		float damage = this.m_fGunDamage * this.m_fGunBonusDamage;

		switch(CurrentPlayers)
		{
			case 0:
				CheckAlivePlayers(); //???? what
			
			case 1:
				damage *= 0.4;
			
			case 2:
				damage *= 0.55;
			
			case 3:
				damage *= 0.65;

			case 4:
				damage *= 0.8;
		}
		if(this.m_bCamo)
		{
			damage *= CAMO_REBEL_DMG_PENALTY;
		}
		else if(this.m_bRebelAgressive)
		{
			damage *= 1.15;
		}

		return damage;
	}
	public void ThinkFriendly(const char[] text)
	{
		bool DEBUG_REBEL_ON;
		
		if(!DEBUG_REBEL_ON)
			return;

		int Text_Entity = EntRefToEntIndex(i_SpeechBubbleEntity[this.index]);
		if(!IsValidEntity(Text_Entity))
		{
			Text_Entity = SpawnFormattedWorldText(text, {0.0, 0.0, 140.0}, 7, {55, 255, 55, 255}, this.index);
			DispatchKeyValue(Text_Entity, "font", "9");
			i_SpeechBubbleEntity[this.index] = EntIndexToEntRef(Text_Entity);
		}

		DispatchKeyValue(Text_Entity, "message", text);
	}
	public void ThinkCombat(const char[] text)
	{
		bool DEBUG_REBEL_ON;
		if(!DEBUG_REBEL_ON)
			return;
		
		int Text_Entity = this.m_iWearable4;
		if(!IsValidEntity(Text_Entity))
		{
			Text_Entity = SpawnFormattedWorldText(text, {0.0, 0.0, 160.0}, 7, {255, 55, 55, 255}, this.index);
			DispatchKeyValue(Text_Entity, "font", "9");
			this.m_iWearable4 = Text_Entity;
		}

		DispatchKeyValue(Text_Entity, "message", text);
	}
	public bool CanPathToAlly(int target)
	{
		CNavArea startArea = TheNavMesh.GetNavAreaEntity(this.index, view_as<GetNavAreaFlags_t>(0), 1000.0);
		if(startArea == NULL_AREA)
			return false;
		
		CNavArea endArea = TheNavMesh.GetNavAreaEntity(target, view_as<GetNavAreaFlags_t>(0), 1000.0);
		if(endArea == NULL_AREA)
			return false;
		
		float pos[3];
		GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
		return TheNavMesh.BuildPath(startArea, endArea, pos);
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

stock void Citizen_PlayerReplacement(int client)
{
	PlayerRenameWho[client] = -1;
	if(b_IsPlayerABot[client])
		return;
	
	if(!Waves_Started())
		return;
	if(Waves_InSetup())
		return;
	//were they alive?
	if(TeutonType[client] != TEUTON_NONE)
		return;
	//were they here since the start of the wave?
	if(!b_HasBeenHereSinceStartOfWave[client])
		return;
	

	if(IsClientInGame(client))
	{
		//easy, just spawn where they disconnected!
		Citizen_SpawnAtPoint("temp", client);
		return;
	}
	//hmm, they crashed and this somehow doesnt work out...
	Citizen_SpawnAtPoint("temp", 0, f3_VecTeleportBackSave_OutOfBounds[client]);
}

int Citizen_SpawnAtPoint(const char[] data = "", int client = 0, float VecPos[3] = {0.0,0.0,0.0})
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
				if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetTeam(entity) == 2)
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
		float pos[3], ang[3];
		int entity;
		if(VecPos[0] == 0.0)
		{
			entity = list[GetURandomInt() % count];
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		}
		else
		{
			pos = VecPos;
		}
		
		entity = NPC_CreateByName("npc_citizen", client, pos, ang, TFTeam_Red, data);
		if(IsValidEntity(entity))
		{
			Citizen npc = view_as<Citizen>(entity);
			if(npc.m_nDowned)
			{
				npc.m_iWearable3 = TF2_CreateGlow(npc.index);

				SetVariantColor(view_as<int>({0, 255, 0, 255}));
				AcceptEntityInput(npc.m_iWearable3, "SetGlowColor");
					
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 255, 255, 125);
			}
			if(client != 0)
			{
				GetClientName(client, c_NpcName[entity], sizeof(c_NpcName[]));
				b_NameNoTranslation[entity] = true;
				Format(c_NpcName[entity], sizeof(c_NpcName[]), "%s's Replacement",c_NpcName[entity]);
			}
			ApplyStatusEffect(entity, entity, "UBERCHARGED", 2.0);

			return entity;
		}
	}

	return -1;
}

bool Citizen_IsIt(int entity)
{
	return (i_NpcInternalId[entity] == NPCId);
}

bool Citizen_ThatIsDowned(int entity)
{
	return (i_NpcInternalId[entity] == NPCId && view_as<Citizen>(entity).m_nDowned);
}

int Citizen_ReviveTicks(int entity, int amount, int client, bool NoAutoRevive = false)
{
	Citizen npc = view_as<Citizen>(entity);
	npc.m_iReviveTicks -= amount;
	if(NoAutoRevive)
	{
		if(npc.m_iReviveTicks < 1)
			npc.m_iReviveTicks = 1;
	}
	if(npc.m_iReviveTicks < 1)
		npc.SetDowned(0, client);
	
	return npc.m_iReviveTicks;
}

int Citizen_ShowInteractionHud(int entity, int client)
{
	if(i_NpcInternalId[entity] == NPCId && GetTeam(entity) == TFTeam_Red)
	{
		Citizen npc = view_as<Citizen>(entity);
		
		if(npc.m_nDowned == 2)
		{
			return 0;
		}
		else if(npc.m_nDowned == 1)
		{
			if(IsValidClient(client))
			{
				SetGlobalTransTarget(client);
				char ButtonDisplay[255];
				PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
				PrintCenterText(client, "%s%t", ButtonDisplay,"Revive Teammate tooltip");	
			}
			return -1;
		}
	}
	return 0;
}

static int MenuEntRef[MAXPLAYERS];

bool Citizen_Interact(int client, int entity)
{
	if(i_NpcInternalId[entity] == NPCId)
	{
		Citizen npc = view_as<Citizen>(entity);
		
		if(!npc.m_nDowned)
		{
			IgnorePlayer[client] = false;

			npc.PlaySound(Cit_Greet);

			MenuEntRef[client] = EntIndexToEntRef(entity);
			CitizenMenu(client);
			return true;
		}
	}
	return false;
}

static int GetCitizenPoints(int entity)
{
	int Points;
	
	Points += Healing_done_in_total[entity] / 3;

	if(Rogue_Mode())
	{
		Points += RoundToCeil(Damage_dealt_in_total[entity]) / 250;
	}
	else
	{
		Points += RoundToCeil(Damage_dealt_in_total[entity]) / 50;
	}

	Points += Resupplies_Supplied[entity] * 4;
	
	Points += i_BarricadeHasBeenDamaged[entity] / 5;

	if(Rogue_Mode())
	{
		Points += i_PlayerDamaged[entity] / 10;
	}
	else
	{
		Points += i_PlayerDamaged[entity] / 5;
	}
	
	Points /= 10;

	return Points;
}

static void CitizenMenu(int client, int page = 0)
{
	Citizen npc = view_as<Citizen>(EntRefToEntIndex(MenuEntRef[client]));
	if(npc.index == -1)
		return;
	
	int ally = npc.m_iTargetAlly;
	if(IsValidEntity(ally))
	{
		// Unstuck me
		if(!npc.CanPathToAlly(ally))
		{
			npc.m_iTargetAlly = 0;
			npc.m_iSeakingObject = 0;
		}
	}
	AnyMenuOpen[client] = 1.0;

	SetGlobalTransTarget(client);

	char buffer[128];

	char points[32], healing[32], tanked[32];
	IntToString(GetCitizenPoints(npc.index), points, sizeof(points));
	ThousandString(points, sizeof(points));
	IntToString(RoundFloat(Damage_dealt_in_total[npc.index]), buffer, sizeof(buffer));
	ThousandString(buffer, sizeof(buffer));
	IntToString(Healing_done_in_total[npc.index], healing, sizeof(healing));
	ThousandString(healing, sizeof(points));
	IntToString(i_PlayerDamaged[npc.index] + i_BarricadeHasBeenDamaged[npc.index], tanked, sizeof(tanked));
	ThousandString(tanked, sizeof(tanked));
	
	char bufname[32];
	if(!b_NameNoTranslation[npc.index])
		Format(bufname, sizeof(bufname), "%t",c_NpcName[npc.index]);
	else
		Format(bufname, sizeof(bufname), "%s",c_NpcName[npc.index]);

	Menu menu = new Menu(CitizenMenuH);
	menu.SetTitle("%s\n \n%t %s\n%t %s\n%t %s\n%t %s\n ", bufname,
			"Total Score", points,
			"Damage Dealt", buffer,
			"Healing Done", healing,
			"Damage Tanked", tanked);

	switch(page)
	{
		case 1:
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Class Vote Citizen Do");
			menu.AddItem("-99999", buffer, ITEMDRAW_DISABLED);

			int VoteObtain[4];
			CitizenVoteResults(npc.index, VoteObtain);
			FormatEx(buffer, sizeof(buffer), "(%i) %t", VoteObtain[0], "DPS Class");
			menu.AddItem("4", buffer, ITEMDRAW_DEFAULT);

			FormatEx(buffer, sizeof(buffer), "(%i) %t",  VoteObtain[1],"Tank Class");
			menu.AddItem("5", buffer, ITEMDRAW_DEFAULT);

			FormatEx(buffer, sizeof(buffer), "(%i) %t",  VoteObtain[2],"Healer Class");
			menu.AddItem("6", buffer, ITEMDRAW_DEFAULT);

			FormatEx(buffer, sizeof(buffer), "(%i) %t",  VoteObtain[3],"Builder Class");
			menu.AddItem("7", buffer, ITEMDRAW_DEFAULT);

			menu.ExitBackButton = true;
		}
		case 2:
		{
			switch(npc.m_iClassRole)
			{
				case Cit_Medic:
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Pistol");
					menu.AddItem("9", buffer, npc.m_iGunType == Cit_Pistol ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "SMG");
					menu.AddItem("11", buffer, npc.m_iGunType == Cit_SMG ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "Shotgun");
					menu.AddItem("10", buffer, npc.m_iGunType == Cit_Shotgun ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
				case Cit_Builder:
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Pistol");
					menu.AddItem("9", buffer, npc.m_iGunType == Cit_Pistol ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "AR2");
					menu.AddItem("12", buffer, npc.m_iGunType == Cit_AR ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "Shotgun");
					menu.AddItem("10", buffer, npc.m_iGunType == Cit_Shotgun ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
				default:
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Pistol");
					menu.AddItem("9", buffer, npc.m_iGunType == Cit_Pistol ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "SMG");
					menu.AddItem("11", buffer, npc.m_iGunType == Cit_SMG ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "Shotgun");
					menu.AddItem("10", buffer, npc.m_iGunType == Cit_Shotgun ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "RPG");
					menu.AddItem("13", buffer, npc.m_iGunType == Cit_RPG ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t", "Crowbar");
					menu.AddItem("8", buffer, npc.m_iGunType == Cit_Melee ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
			}

			menu.ExitBackButton = true;
		}
		case 3:
		{
			if(npc.m_bAlyx)
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Preference Alyx");
				menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
			}
			else if(npc.m_bHero)
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Preference Barney");
				menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
			}
			else
			{
				switch(npc.m_iSeed % 11)
				{
					case 2, 3:
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Preference Speed");
						menu.AddItem(NULL_STRING, buffer);
					}
					case 4, 5:
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Preference Heavy");
						menu.AddItem(NULL_STRING, buffer);
					}
					case 6:
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Preference No Clip");
						menu.AddItem(NULL_STRING, buffer);
					}
					case 7:
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Preference Super Speed");
						menu.AddItem(NULL_STRING, buffer);
					}
					case 8:
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Preference Super Heavy");
						menu.AddItem(NULL_STRING, buffer);
					}
					default:
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Preference Normal");
						menu.AddItem(NULL_STRING, buffer);
					}
				}
			}

			menu.ExitBackButton = true;
		}
		default:
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Don't Follow Me");
			menu.AddItem("1", buffer);

			if(!npc.m_bHero && !TempRebel[npc.index])
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Switch Class");
				menu.AddItem("2", buffer, ITEMDRAW_DEFAULT);

				FormatEx(buffer, sizeof(buffer), "%t", "Switch Weapons");
				menu.AddItem("3", buffer, ITEMDRAW_DEFAULT);
			}

			FormatEx(buffer, sizeof(buffer), "%t", "Weapon Preference");
			menu.AddItem("14", buffer);
			
			switch(npc.m_iClassRole)
			{
				case Cit_Medic:
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Build Healing Station At Me");
					menu.AddItem("16", buffer);
				}
				case Cit_Builder:
				{
					bool DontAllowBuilding = false;
					if(HealingCooldown[npc.index] > GetGameTime())
					{
						DontAllowBuilding = true;
					}
					if(Waves_InSetup() || f_AllowInstabuildRegardless > GetGameTime())
					{
						DontAllowBuilding = false;
					}
					if(Construction_Mode())
					{
						DontAllowBuilding = false;
						if(HealingCooldown[npc.index] > GetGameTime())
							DontAllowBuilding = true;

						if(!Waves_Started())
							DontAllowBuilding = false;
					}
					
					int MaxBuildingsSee = 0;
					int BuildingsSee = 0;
					BuildingsSee = BuildingAmountRebel(npc.index, 2, MaxBuildingsSee);
					FormatEx(buffer, sizeof(buffer), "%t (%i/%i)", "Build Barricade At Me",BuildingsSee, MaxBuildingsSee);
					menu.AddItem("15", buffer, DontAllowBuilding ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					BuildingsSee = BuildingAmountRebel(npc.index, 1, MaxBuildingsSee);
					FormatEx(buffer, sizeof(buffer), "%t (%i/%i)", "Build Sentry At Me",BuildingsSee, MaxBuildingsSee);
					menu.AddItem("16", buffer);

					BuildingsSee = BuildingAmountRebel(npc.index, 3, MaxBuildingsSee);
					FormatEx(buffer, sizeof(buffer), "%t (%i/%i)", "Build Ammo Box At Me",BuildingsSee, MaxBuildingsSee);
					menu.AddItem("17", buffer, DontAllowBuilding ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t (%i/%i)", "Build Armor Table At Me",BuildingsSee, MaxBuildingsSee);
					menu.AddItem("18", buffer, DontAllowBuilding ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t (%i/%i)", "Build Perk Machine At Me",BuildingsSee, MaxBuildingsSee);
					menu.AddItem("19", buffer, DontAllowBuilding ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

					FormatEx(buffer, sizeof(buffer), "%t (%i/%i)", "Build Pack-a-Punch At Me",BuildingsSee, MaxBuildingsSee);
					menu.AddItem("20", buffer, DontAllowBuilding ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
				}
			}
			if(!npc.m_bHero && !TempRebel[npc.index])
			{
				FormatEx(buffer, sizeof(buffer), "%t", "Name Rebel");
				menu.AddItem("25", buffer, ITEMDRAW_DEFAULT);
			}
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

static int CitizenMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
			if(choice == MenuCancel_ExitBack)
				CitizenMenu(client);
		}
		case MenuAction_Select:
		{
			Citizen npc = view_as<Citizen>(EntRefToEntIndex(MenuEntRef[client]));
			if(npc.index == -1 || npc.m_nDowned)
				return 0;
			
			int page = 0;

			char buffer[16];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int index = StringToInt(buffer);
			switch(index)
			{
				case 1:
				{
					IgnorePlayer[client] = true;
					return 0;
				}
				case 2:
				{
					page = 1;
				}
				case 3:
				{
					page = 2;
				}
				case 4:
				{
					CitizenVoteFor(npc.index, client, 0);
					CommandCooldown[npc.index] = GetGameTime() + 30.0;
				}
				case 5:
				{
					CitizenVoteFor(npc.index, client, 1);
					CommandCooldown[npc.index] = GetGameTime() + 30.0;
				}
				case 6:
				{
					CitizenVoteFor(npc.index, client, 2);
					CommandCooldown[npc.index] = GetGameTime() + 30.0;
				}
				case 7:
				{
					CitizenVoteFor(npc.index, client, 3);
					CommandCooldown[npc.index] = GetGameTime() + 30.0;
				}
				case 8, 9, 10, 11, 12, 13:
				{
					Citizen_UpdateStats(npc.index, index - 7, npc.m_iClassRole);
					CommandCooldown[npc.index] = GetGameTime() + 30.0;
				}
				case 14:
				{
					page = 3;
				}
				case 15, 16, 17, 18, 19, 20:
				{
					if(npc.CanPathToAlly(client))
					{
						int CheckWhich;
						switch(index)
						{
							case 15:
								CheckWhich = 2;
							case 16:
								CheckWhich = 1;
							default:
								CheckWhich = 3;
						}
						int MaxBuildingsSee = 0;
						int BuildingsSee = 0;
						BuildingsSee = BuildingAmountRebel(npc.index, CheckWhich, MaxBuildingsSee);

						if((MaxBuildingsSee - BuildingsSee) <= 0)
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");
							CitizenMenu(client, page);
							return 0;
						}

						npc.m_iTargetAlly = client;
						npc.m_iSeakingObject = index - 9;
						HealingCooldown[npc.index] = GetGameTime() + 2.0;
					}
				}
				case 25:
				{
					PlayerRenameWho[client] = EntIndexToEntRef(npc.index);
					CPrintToChat(client, "Type the name in chat for the rebel!");
				}
			}

			CitizenMenu(client, page);
		}
	}

	return 0;
}

bool Rebel_Rename(int client)
{
	int EntityName = EntRefToEntIndex(PlayerRenameWho[client]);
	if(!IsValidEntity(EntityName))
		return false;

	PlayerRenameWho[client] = -1;
	if(!Native_CanRenameNpc(client))
	{
		CPrintToChat(client, "Youre muted buddy.");
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return false;
	}
	char buffer[32];
	GetCmdArgString(buffer, sizeof(buffer));
	ReplaceString(buffer, sizeof(buffer), "\"", "");
	CRemoveTags(buffer, sizeof(buffer));

	if(!buffer[0])
		return true;
	
	b_NameNoTranslation[EntityName] = true;
	//This REALLY shouldnt say [SM].
	SPrintToChatAll("%N renamed \"%s\" to \"%s\"", client, c_NpcName[EntityName], buffer);
	strcopy(c_NpcName[EntityName], sizeof(c_NpcName[]), buffer);
	return true;
}

void Citizen_SetRandomRole(int entity)
{
	Citizen npc = view_as<Citizen>(entity);
	
	int team = GetTeam(entity);
	bool hasBuilder;
	int medicCount;
	int longCount;
	int shortCount;
	int totalCount;
	int seed = npc.m_bHero ? GetURandomInt() : npc.m_iSeed;

	if(!npc.m_bAlyx)
	{
		int i = -1;
		while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
		{
			if(i_NpcInternalId[i] == NPCId && GetTeam(i) == team)
			{
				totalCount++;

				switch(npc.m_iClassRole)
				{
					case Cit_Builder:
						hasBuilder = true;
					
					case Cit_Medic:
						medicCount++;
				}

				switch(npc.m_iGunType)
				{
					case Cit_Melee, Cit_Shotgun, Cit_SMG, Cit_AR:
						shortCount++;
					
					case Cit_Pistol, Cit_RPG:
						longCount++;
				}
			}
		}
		
		if(team != TFTeam_Red)
		{
			i = -1;
			while((i = FindEntityByClassname(i, "obj_building")) != -1)
			{
				if(i_NpcInternalId[i] == ObjectBarricade_ID())
				{
					hasBuilder = true;
					break;
				}
			}

			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && GetClientTeam(client) == TFTeam_Red)
				{
					totalCount++;

					if(Store_HasNamedItem(client, "Doctor Certificate"))
					{
						medicCount++;
					}
				}
			}
		}
	}

	int type = Cit_Pistol;
	int role = Cit_Fighter;

	if(!npc.m_bAlyx)
	{
		if((seed % 4) && medicCount < (totalCount / 6))
		{
			type = (seed % 6) ? Cit_SMG : Cit_AR;
			role = Cit_Medic;
		}
		else if((seed % 3) == 0 && totalCount > 2 && !hasBuilder)
		{
			type = Cit_AR;
			role = Cit_Builder;
		}
		else if(shortCount < longCount)
		{
			type = (seed % 8) > 6 ? Cit_Shotgun : Cit_SMG;
			if((seed % 8) < (Construction_Mode() ? 3 : 1))
				type = Cit_Melee;
		}
		else
		{
			type = (seed % 8) > 2 ? Cit_Pistol : Cit_RPG;
		}
	}

	Citizen_UpdateStats(entity, type, role);
}

void Citizen_UpdateStats(int entity, int type, int role)
{
	Citizen npc = view_as<Citizen>(entity);
	
	bool changed = npc.m_iClassRole != role || npc.m_iGunType != type;

	if(!npc.m_bAlyx && npc.m_iClassRole != role)
	{
		int obj = MaxClients + 1;
		while((obj = FindEntityByClassname(obj, "obj_building")) != -1)
		{
			if(GetEntPropEnt(obj, Prop_Send, "m_hOwnerEntity") == npc.index)
				DestroyBuildingDo(obj);
		}
	}

	npc.m_iClassRole = npc.m_bAlyx ? Cit_Medic : (npc.m_bHero ? Cit_Fighter : role);
	npc.m_iGunType = npc.m_bAlyx ? Cit_Pistol : type;
	npc.m_iGunValue = CurrentCash;
	if(npc.m_iGunValue > 100000)
	{
		npc.m_iGunValue = 100000;
	}
	else if(npc.m_iGunValue < 1000)
	{
		npc.m_iGunValue = 1000;
	}

	//Building_ClearRefBuffs(EntIndexToEntRef(entity));
	
	int health = (npc.m_bAlyx ? 380 : 180) + npc.m_iGunValue / 50;
	if(GetTeam(entity) != TFTeam_Red)
		health *= 200;
	
	SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(ReturnEntityMaxHealth(npc.index)) * float(health)));
	SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
	
	switch(npc.m_iGunType)
	{
		case Cit_Melee:
		{
			// 0.25 DPS
			npc.m_fGunDamage = 0.2 * npc.m_iGunValue;
			npc.m_fGunFirerate = 0.8;
			npc.m_fGunReload = 1.0;
			npc.m_iGunClip = 0;
		}
		case Cit_Pistol:
		{
			// 0.2 DPS
			npc.m_fGunDamage = 0.04 * npc.m_iGunValue;
			npc.m_fGunFirerate = 0.2;
			npc.m_fGunReload = 1.0;
			npc.m_iGunClip = 18;
		}
		case Cit_SMG:
		{
			// 0.2 DPS
			npc.m_fGunDamage = 0.015 * npc.m_iGunValue;
			npc.m_fGunFirerate = 0.075;
			npc.m_fGunReload = 1.0;
			npc.m_iGunClip = 45;
		}
		case Cit_AR:
		{
			// 0.2 DPS
			npc.m_fGunDamage = 0.02 * npc.m_iGunValue;
			npc.m_fGunFirerate = 0.1;
			npc.m_fGunReload = 1.0;
			npc.m_iGunClip = 30;
		}
		case Cit_Shotgun:
		{
			// 0.23 DPS
			npc.m_fGunDamage = 0.2 * npc.m_iGunValue;
			npc.m_fGunFirerate = 0.88;
			npc.m_fGunReload = 1.0;
			npc.m_iGunClip = 6;
		}
		case Cit_RPG:
		{
			// 0.2 DPS
			npc.m_fGunDamage = 0.38 * npc.m_iGunValue;
			npc.m_fGunFirerate = 2.0;
			npc.m_fGunReload = 1.0;
			npc.m_iGunClip = 2;
		}
	}
	
	if(npc.m_bAlyx)
	{
		npc.m_fGunDamage *= 1.5;
		npc.m_fGunFirerate *= 2.0;
	}
	else
	{
		int rand = npc.m_bHero ? GetURandomInt() : npc.m_iSeed;
		switch(rand % 11)
		{
			case 2, 3:
			{
				// Speedy
				npc.m_fGunDamage *= 0.8;
				npc.m_fGunFirerate *= 0.8;
				npc.m_fGunReload *= 0.8;
			}
			case 4, 5:
			{
				// Heavy
				npc.m_fGunDamage *= 1.25;
				npc.m_fGunFirerate *= 1.25;
				npc.m_fGunReload *= 1.25;
			}
			case 6:
			{
				// No Clip
				npc.m_fGunFirerate *= 1.2;
				npc.m_iGunClip = 0;
			}
			case 7:
			{
				// Super Speed
				npc.m_fGunDamage *= 0.65;
				npc.m_fGunFirerate *= 0.65;
				npc.m_fGunReload *= 0.65;
				npc.m_iGunClip *= 2;
			}
			case 8:
			{
				// Super Heavy
				npc.m_fGunDamage *= 2.0;
				npc.m_fGunFirerate *= 2.0;
				npc.m_fGunReload *= 2.0;
				npc.m_iGunClip /= 2;
			}
		}

		switch(npc.m_iClassRole)
		{
			case Cit_Medic:
			{
				npc.m_fGunFirerate *= 3.0;
				npc.m_iGunClip /= 2;
			}
			case Cit_Builder:
			{
				npc.m_fGunDamage *= 0.5;
			}
		}
	}

	if(GetTeam(entity) != TFTeam_Red)
		npc.m_fGunDamage /= 50.0;
	
	//npc.m_fGunRangeBonus = 1.0;
	npc.m_iAttacksTillReload = npc.m_iGunClip;
	npc.m_bFirstBlood = false;

	//Rogue_AllySpawned(npc.index);
	//Waves_AllySpawned(npc.index);
	
	npc.UpdateModel();

	if(changed)
	{
		npc.PlaySound(Cit_NewWeapon);
		PendingGesture[npc.index] = 3;
		npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
	}
	
	if(npc.m_iWearable1 > 0)
		RemoveEntity(npc.m_iWearable1);
	
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

int Citizen_Count()
{
	int count;

	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[i] == NPCId && GetTeam(i) == TFTeam_Red)
		{
			Citizen npc = view_as<Citizen>(i);
			//BARNEY NO SCALE BAD !!!!!!!!!!!!!!!!!!!!!! (and alyx ig)
			//and temp rebels!
			if(!npc.m_bHero && TempRebel[i])
				count++;
		}
	}

	return count;
}

void RespawnCheckCitizen()
{
	
	int a, i;
	while((i = FindEntityByNPC(a)) != -1)
	{
		if(i_NpcInternalId[i] == NPCId)
		{
			Citizen npc = view_as<Citizen>(i);

			if(TempRebel[npc.index])
			{
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				continue;
			}
		}
	}
}
void Citizen_WaveStart()
{
	int a, i;
	while((i = FindEntityByNPC(a)) != -1)
	{
		if(i_NpcInternalId[i] == NPCId)
		{
			Citizen npc = view_as<Citizen>(i);

			if(TempRebel[npc.index])
			{
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				continue;
			}

			if(npc.m_iGunType == Cit_None && !npc.m_nDowned)
			{
				Citizen_SetRandomRole(npc.index);
			}

			int team = GetTeam(i);
			if(team == TFTeam_Red)
			{
				int maxValue = 0;
				npc.m_iCanBuild = (BuildingAmountRebel(npc.index, 1, maxValue) > 0) ? 0 : 1;
				
				if(npc.m_iClassRole == Cit_Builder)
				{
					int amount = BuildingAmountRebel(npc.index, 2, maxValue);
					if(amount < maxValue)
						npc.m_iCanBuild += 2;
					
					amount = BuildingAmountRebel(npc.index, 3, maxValue);
					if(amount < maxValue)
						npc.m_iCanBuild += 4;
				}
			}
			else if(npc.m_iClassRole == Cit_Builder)
			{
				npc.m_iCanBuild = 1;
				
				int b, entity;
				while((entity = FindEntityByNPC(b)) != -1)
				{
					if(i_NpcInternalId[entity] == MedivalBuilding_Id() && GetTeam(entity) == team)
					{
						npc.m_iCanBuild = 0;
						break;
					}
				}
			}
		}
	}
}

void Citizen_SetupStart()
{
	int a, i;
	while((i = FindEntityByNPC(a)) != -1)
	{
		if(i_NpcInternalId[i] == NPCId)
		{
			Citizen npc = view_as<Citizen>(i);

			if(!npc.m_nDowned)
			{
				if(npc.m_iGunType == Cit_None || npc.m_bHero)
				{
					Citizen_SetRandomRole(npc.index);
				}
				else
				{
					Citizen_UpdateStats(npc.index, npc.m_iGunType, npc.m_iClassRole);
				}
			}
		}
	}
}

public void Citizen_ClotThink(int iNPC)
{
	Citizen npc = view_as<Citizen>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;

	switch(PendingGesture[npc.index])
	{
		case 1:
		{
			npc.SetActivity("ACT_BUSY_SIT_GROUND", 0.0);
			npc.AddGesture("ACT_BUSY_SIT_GROUND_ENTRY");
			PendingGesture[npc.index] = 0;
		}
		case 2:
		{
			npc.SetActivity("ACT_BUSY_SIT_GROUND_EXIT", 0.0, 2.0);
			PendingGesture[npc.index] = 0;
		}
		case 3:
		{
			npc.SetActivity("ACT_PICKUP_RACK", 0.0);
			PendingGesture[npc.index] = 0;
		}
	}

	if(npc.m_nDowned)
	{
		npc.m_iTargetAlly = 0;
		npc.m_iSeakingObject = 0;
		npc.m_flNextThinkTime = gameTime + 0.15;
		
		if(npc.m_nDowned != 2)
		{
			npc.ThinkCombat(":(");
			npc.ThinkFriendly(":(");

			if(b_IsAloneOnServer || npc.m_iReviveTicks > 50)
			{
				npc.m_iReviveTicks--;
				if(npc.m_iReviveTicks <= 0)
				{
					Citizen_ReviveTicks(npc.index, 1, npc.index, false);
				}
			}

			

			if(npc.m_flidle_talk == 0.0)
			{
				npc.m_flidle_talk = gameTime + 30.0 + (float(npc.m_iSeed) / 214748364.7);
			}
			else if(npc.m_flidle_talk < gameTime)
			{
				npc.PlaySound(Cit_Lost);
				npc.m_flidle_talk = 0.0;
			}
		}
		return;
	}

	// This heal happens every second on players, for npcs this think happens way more often, subtract.
	HealEntityGlobal(npc.index, npc.index, ReturnEntityMaxHealth(npc.index) * 0.04 * 0.01, (npc.m_iClassRole == Cit_Medic ? 1.0 : 0.5), 0.0, HEAL_SELFHEAL|HEAL_PASSIVE_NO_NOTIF);

	bool noSafety = (npc.m_bCamo || VIPBuilding_Active());
	bool autoSeek = (noSafety || npc.m_bRebelAgressive || RaidbossIgnoreBuildingsLogic(1) || GetTeam(npc.index) != TFTeam_Red);
	bool helpAlly;

	if(Construction_Mode() && Construction_InSetup())
		autoSeek = true;

	// See if our target is still valid
	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target, true, true))
	{
		npc.m_flGetClosestTargetTime = 0.0;
		i_Target[npc.index] = -1;
	}

	// See if our ally is still valid
	int ally = npc.m_iTargetAlly;
	if(i_TargetAlly[npc.index] != -1 && (!IsValidEntity(ally) || (ally > MaxClients && b_NpcHasDied[ally] && b_BuildingHasDied[ally]) || (ally <= MaxClients && !IsPlayerAlive(ally))))
	{
		i_TargetAlly[npc.index] = -1;
	}
	else if((ally <= MaxClients && dieingstate[ally] > 0) || Citizen_ThatIsDowned(ally))
	{
		helpAlly = true;
	}
	
	// Cancel any seeking
	if(i_TargetAlly[npc.index] == -1)
		npc.m_iSeakingObject = 0;	// Seaking a building

	// Find new target
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		autoSeek = true;
		int newTarget = GetClosestTarget(npc.index, false, autoSeek ? FAR_FUTURE : (BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus), npc.m_bCamo, .CanSee = !autoSeek);
		if(newTarget > 0)
		{
			target = newTarget;
			npc.m_iTarget = newTarget;
		}

		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		npc.m_bGetClosestTargetTimeAlly = true;	// Can do a GetClosest check
	}

	// Meleeing
	if(npc.m_flAttackHappens)
	{
		npc.ThinkCombat("Melee combat!");
		npc.ThinkFriendly("...");

		npc.m_iTargetAlly = 0;
		npc.m_iSeakingObject = 0;
		
		if(npc.m_iGunType != Cit_Melee)
		{
			npc.m_flAttackHappens = 0.0;
		}
		else if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget, npc.m_bCamo))
			{
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				
				if(target > 0) 
				{
					KillFeed_SetKillIcon(npc.index, "wrench_jag");
					SDKHooks_TakeDamage(target, npc.index, npc.index, npc.GetDamage(), DMG_CLUB, -1, _, VecEnemy);
					
					//Did we kill them?
					if(GetEntProp(target, Prop_Data, "m_iHealth") < 1)
					{
						if(!npc.m_bFirstBlood && npc.CanTalk())
						{
							npc.m_bFirstBlood = true;
							npc.PlaySound(Cit_FirstBlood);
						}
						
						HealEntityGlobal(npc.index, npc.index, ReturnEntityMaxHealth(npc.index) / 20.0, _, 1.0, HEAL_SELFHEAL);
					}
				}
			}
			return;
		}
		else
		{
			if(IsValidEnemy(npc.index, npc.m_iTarget, npc.m_bCamo))
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 500.0);
			}
			
			return;
		}
	}

	if(npc.m_flReloadDelay > gameTime)
	{
		npc.ThinkCombat("Doing something...");
		npc.ThinkFriendly("Doing something...");

		npc.m_iTargetAlly = 0;
		npc.m_iSeakingObject = 0;
		npc.StopPathing();
		return;
	}

	// Status Variables
	bool combat = !Waves_InSetup();
	int team = GetTeam(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	bool injured = (health < 60) || (health < (maxhealth / 5));
	bool seakAlly = npc.m_bGetClosestTargetTimeAlly;
	
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	float vecTarget[3];
	static char buffer[32];

	// Reload check
	int reloadStatus;
	if(npc.m_iGunClip > 0)
	{
		if(npc.m_iAttacksTillReload == 0)
		{
			reloadStatus = 2;	// I need to reload now
		}
		else if(npc.m_iAttacksTillReload < (npc.m_iGunClip * 3 / 4))
		{
			reloadStatus = 1;	// Reload when free
		}
	}

	// Additional check to see if we're surrounded
	if(!noSafety && target > 0 && (injured || npc.m_iGunType != Cit_Melee) && (ally > 0 || npc.m_iSeakingObject || seakAlly))
	{
		WorldSpaceCenter(target, vecTarget);
		if(GetVectorDistance(vecMe, vecTarget, true) < 20000.0)
		{
			seakAlly = false;
			helpAlly = false;
			
			ally = -1;
			i_TargetAlly[npc.index] = -1;

			npc.m_iSeakingObject = 0;
			npc.m_bGetClosestTargetTimeAlly = false;
		}
	}

	// Seek any objects
	if(!npc.m_iSeakingObject && seakAlly)
	{
		// Medic role
		if(npc.m_iClassRole == Cit_Medic && HealingCooldown[npc.index] < gameTime)
		{
			npc.ThinkFriendly("Nobody to heal...");

			npc.m_bGetClosestTargetTimeAlly = false;

			float distance = FAR_FUTURE;

			int a, entity;
			while((entity = FindEntityByNPC(a)) != -1)
			{
				if(entity != npc.index && !i_NpcIsABuilding[entity] && !b_NpcIsInvulnerable[entity] && GetTeam(entity) == team)
				{
					if(i_NpcInternalId[entity] == NPCId && view_as<Citizen>(entity).m_iSeakingObject)
					{
						// Rebel is running, don't follow
						continue;
					}

					if(Citizen_ThatIsDowned(entity))
					{
						if(GetClosestTarget(entity, true, 600.0, true, .IgnorePlayers = true) > MaxClients)
							continue;
					}
					else if(combat)
					{
						if(GetEntProp(entity, Prop_Data, "m_iHealth") > (ReturnEntityMaxHealth(entity) / 2))
							continue;
					}
					else if(GetEntProp(entity, Prop_Data, "m_iHealth") >= ReturnEntityMaxHealth(entity))
					{
						continue;
					}

					WorldSpaceCenter(entity, vecTarget);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < distance)
					{
						distance = dist;
						ally = entity;
						npc.m_iTargetAlly = ally;
						npc.m_iSeakingObject = 4;
					}
				}
			}

			if(team == TFTeam_Red)
			{
				for(int client = 1; client <= MaxClients; client++)
				{
					if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
					{
						if(dieingstate[client] > 0)
						{
							if(GetClosestTarget(client, true, 600.0, true, .IgnorePlayers = true) > MaxClients)
								continue;
						}
						else if(combat)
						{
							if(GetClientHealth(client) > (ReturnEntityMaxHealth(client) / 2))
								continue;
						}
						else if(GetClientHealth(client) >= ReturnEntityMaxHealth(client))
						{
							continue;
						}

						WorldSpaceCenter(client, vecTarget);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
						{
							distance = dist;
							ally = client;
							npc.m_iTargetAlly = ally;
							npc.m_iSeakingObject = 4;
						}
					}
				}
			}
		}

		else if(helpAlly)
		{
			// Don't do anything if we're going to revive someone
		}

		// Forced ally revive check
		else if(team == TFTeam_Red && !(GetURandomInt() % 19))
		{
			npc.ThinkFriendly("Nobody to revive...");

			npc.m_bGetClosestTargetTimeAlly = false;

			float distance = FAR_FUTURE;

			int a, entity;
			while((entity = FindEntityByNPC(a)) != -1)
			{
				if(entity != npc.index && Citizen_ThatIsDowned(entity) && GetTeam(entity) == team)
				{
					if(GetClosestTarget(entity, true, 600.0, true, .IgnorePlayers = true) > MaxClients)
						continue;
					
					WorldSpaceCenter(entity, vecTarget);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < distance)
					{
						distance = dist;
						ally = entity;
						npc.m_iTargetAlly = ally;
						npc.m_iSeakingObject = 4;
					}
				}
			}

			for(int client = 1; client <= MaxClients; client++)
			{
				if(TeutonType[client] == TEUTON_NONE && dieingstate[client] > 0 && IsClientInGame(client) && IsPlayerAlive(client))
				{
					if(GetClosestTarget(client, true, 600.0, true, .IgnorePlayers = true) > MaxClients)
						continue;

					WorldSpaceCenter(client, vecTarget);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist < distance)
					{
						distance = dist;
						ally = client;
						npc.m_iTargetAlly = ally;
						npc.m_iSeakingObject = 4;
					}
				}
			}
		}

		// Repair check
		else if(npc.m_iClassRole == Cit_Builder && (GetURandomInt() % 3))
		{
			npc.ThinkFriendly("Nothing to repair...");

			npc.m_bGetClosestTargetTimeAlly = false;

			float distance = FAR_FUTURE;

			if(team == TFTeam_Red)
			{
				int entity = MaxClients + 1;
				while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
				{
					if(b_ThisEntityIgnored[entity])
						continue;
					
					if(GetEntProp(entity, Prop_Data, "m_iHealth") >= ReturnEntityMaxHealth(entity))
						continue;
					
					if(Object_GetRepairHealth(entity) < 1)
						continue;

					GetAbsOrigin(entity, vecTarget);
					float dist = GetVectorDistance(vecTarget, vecMe, true);
					if(dist > distance)
						continue;
					
					if(!npc.CanPathToAlly(entity))
						continue;
					
					distance = dist;
					ally = entity;
					npc.m_iTargetAlly = ally;
					npc.m_iSeakingObject = 5;
				}
			}
			else
			{
				int a, entity;
				while((entity = FindEntityByNPC(a)) != -1)
				{
					if(i_NpcIsABuilding[entity] && GetTeam(entity) == team)
					{
						if(i_NpcInternalId[entity] != MedivalBuilding_Id() || i_AttacksTillMegahit[entity] > 254)
						{
							if(GetEntProp(entity, Prop_Data, "m_iHealth") >= ReturnEntityMaxHealth(entity))
								continue;
						}
						
						GetAbsOrigin(entity, vecTarget);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
							continue;
					
						if(!npc.CanPathToAlly(entity))
							continue;
						
						distance = dist;
						ally = entity;
						npc.m_iTargetAlly = ally;
						npc.m_iSeakingObject = 5;
					}
				}
			}
		}

		// Sentry Buildings
		else if(team == TFTeam_Red && (npc.m_iCanBuild & 1) && (npc.m_iClassRole == Cit_Medic || npc.m_iClassRole == Cit_Builder) && (GetURandomInt() % 2))
		{
			npc.ThinkFriendly("Nowhere to build my sentry...");

			npc.m_bGetClosestTargetTimeAlly = false;
			
			float distance = FAR_FUTURE;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
			{
				if(b_ThisEntityIgnored[entity])
					continue;
				
				if(IsValidEntity(Building_HasThisBuilding(entity)) || Building_OnThisBuilding(entity) != -1)
					continue;
				
				NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
				if(npc.m_iClassRole == Cit_Builder)
				{
					// Sentries on Decorative Objects
					if(StrContains(buffer, "obj_decorative") == -1 && StrContains(buffer, "obj_barricade") == -1)
						continue;
				}
				else
				{
					// Healing Station on Healing Stations
					if(StrContains(buffer, "obj_healingstation") == -1 && StrContains(buffer, "obj_grill") == -1)
						continue;
				}

				// Ignore if someone else planned to build on it
				int other = -1;
				while((other = FindEntityByClassname(other, "zr_base_npc")) != -1)
				{
					if(i_NpcInternalId[other] == NPCId && view_as<Citizen>(other).m_iTargetAlly == entity)
						break;
				}

				if(other != -1)
					continue;

				GetAbsOrigin(entity, vecTarget);
				float dist = GetVectorDistance(vecTarget, vecMe, true);
				if(dist < distance)
					continue;
				
				if(!npc.CanPathToAlly(entity))
					continue;
				
				distance = dist;
				ally = entity;
				npc.m_iTargetAlly = ally;
				npc.m_iSeakingObject = 7;
			}
		}

		// Enemy Rebel Building
		else if(team != TFTeam_Red && npc.m_iCanBuild && npc.m_iClassRole == Cit_Builder && !Waves_InSetup())
		{
			npc.ThinkFriendly("Nowhere to build my tower...");

			npc.m_bGetClosestTargetTimeAlly = false;

			float AproxRandomSpaceToWalkTo[3];

			GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);

			AproxRandomSpaceToWalkTo[2] += 50.0;

			AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 800.0),(AproxRandomSpaceToWalkTo[0] + 800.0));
			AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 800.0),(AproxRandomSpaceToWalkTo[1] + 800.0));

			Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
			
			TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
			delete ToGroundTrace;

			CNavArea area = TheNavMesh.GetNearestNavArea(AproxRandomSpaceToWalkTo, true);
			if(area != NULL_AREA)
			{
				int NavAttribs = area.GetAttributes();
				if(!(NavAttribs & NAV_MESH_AVOID))
				{
					area.GetCenter(AproxRandomSpaceToWalkTo);

					AproxRandomSpaceToWalkTo[2] += 18.0;
					
					static float hullcheckmaxs_Player_Again[3];
					static float hullcheckmins_Player_Again[3];

					hullcheckmaxs_Player_Again = view_as<float>( { 30.0, 30.0, 82.0 } ); //Fat
					hullcheckmins_Player_Again = view_as<float>( { -30.0, -30.0, 0.0 } );	

					if(!IsSpaceOccupiedIgnorePlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
					{
						if(!IsPointHazard(AproxRandomSpaceToWalkTo))
						{
							AproxRandomSpaceToWalkTo[2] += 18.0;
							if(!IsPointHazard(AproxRandomSpaceToWalkTo))
							{
								AproxRandomSpaceToWalkTo[2] -= 18.0;
								AproxRandomSpaceToWalkTo[2] -= 18.0;
								AproxRandomSpaceToWalkTo[2] -= 18.0;

								if(!IsPointHazard(AproxRandomSpaceToWalkTo))
								{
									AproxRandomSpaceToWalkTo[2] += 18.0;
									AproxRandomSpaceToWalkTo[2] += 18.0;

									npc.m_iCanBuild = 0;

									int spawn_index = NPC_CreateByName("npc_medival_building", -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, team);
									if(spawn_index > MaxClients)
									{
										if(team != TFTeam_Red)
											NpcAddedToZombiesLeftCurrently(spawn_index, true);
										
										i_AttacksTillMegahit[spawn_index] = 1;
										SetEntityRenderMode(spawn_index, RENDER_NONE);
										SetEntityRenderColor(spawn_index, 255, 255, 255, 0);
									}
								}
							}
						}
					}
				}
			}
		}

		// Support Buildings
		else if(team == TFTeam_Red && npc.m_iCanBuild > 1 && (GetURandomInt() % 2))
		{
			npc.ThinkFriendly("Nowhere to build my buildings...");

			npc.m_bGetClosestTargetTimeAlly = false;
			
			float distance = FAR_FUTURE;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
			{
				if(b_ThisEntityIgnored[entity])
					continue;
				
				if(IsValidEntity(Building_HasThisBuilding(entity)) || Building_OnThisBuilding(entity) != -1)
					continue;
				
				int type;

				// Build with the same object type
				NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
				if(!StrContains(buffer, "obj_ammobox"))
				{
					type = 8;
				}
				else if(!StrContains(buffer, "obj_armortable"))
				{
					type = 9;
				}
				else if(!StrContains(buffer, "obj_barricade"))
				{
					type = 6;
				}

				if(!type)
					continue;

				if(type == 6)
				{
					if(!(npc.m_iCanBuild & 2))
						continue;
				}
				else
				{
					if(!(npc.m_iCanBuild & 4))
						continue;
				}

				// Ignore if someone else planned to build on it
				int other = -1;
				while((other = FindEntityByClassname(other, "zr_base_npc")) != -1)
				{
					if(i_NpcInternalId[other] == NPCId && view_as<Citizen>(other).m_iTargetAlly == entity)
						break;
				}

				if(other != -1)
					continue;
				
				// Replace with Perk or Pap if they don't exist
				if(type != 6)
				{
					if(Object_NamedBuildings(_, "obj_packapunch") == 0)
					{
						type = 11;
					}
					else if(Object_NamedBuildings(_, "obj_perkmachine") == 0)
					{
						type = 10;
					}
				}

				GetAbsOrigin(entity, vecTarget);
				float dist = GetVectorDistance(vecTarget, vecMe, true);
				if(dist < distance)
					continue;
				
				if(!npc.CanPathToAlly(entity))
					continue;
				
				distance = dist;
				ally = entity;
				npc.m_iTargetAlly = ally;
				npc.m_iSeakingObject = type;
			}
		}

		// Healing check
		else if(team == TFTeam_Red && health < maxhealth && (!combat || injured || (target == -1 && (health < (maxhealth / 3)))))
		{
			npc.ThinkFriendly("No Free Healing Station...");

			npc.m_bGetClosestTargetTimeAlly = false;

			float distance = FAR_FUTURE;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
			{
				if(HealingCooldown[entity] < gameTime)
				{
					NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
					if(!StrContains(buffer, "obj_healingstation") || (!StrContains(buffer, "obj_grill") && view_as<CClotBody>(entity).g_TimesSummoned))
					{
						GetAbsOrigin(entity, vecTarget);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
							continue;
						
						if(!npc.CanPathToAlly(entity))
							continue;
						
						distance = dist;
						ally = entity;
						npc.m_iTargetAlly = ally;
						npc.m_iSeakingObject = 1;
					}
				}
			}
		}
		// Look for Perk Machines
		else if(team == TFTeam_Red && (!combat || (target == -1 && npc.m_iClassRole != Cit_Fighter)) && npc.m_iGunType != Cit_None && npc.m_iHasPerk != npc.m_iGunType)
		{
			npc.ThinkFriendly("No Free Perk Machine...");

			npc.m_bGetClosestTargetTimeAlly = false;

			float distance = FAR_FUTURE;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
			{
				if(HealingCooldown[entity] < gameTime)
				{
					NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
					if(!StrContains(buffer, "obj_perkmachine"))
					{
						GetAbsOrigin(entity, vecTarget);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
							continue;
						
						if(!npc.CanPathToAlly(entity))
							continue;
						
						distance = dist;
						ally = entity;
						npc.m_iTargetAlly = ally;
						npc.m_iSeakingObject = 3;
					}
				}
			}
		}
		// Look for Armor Tables
		else if((team == TFTeam_Red && (Elemental_HasDamage(npc.index) || npc.m_flArmorCount <= 0.0)) && (!combat || (target == -1 && Elemental_GoingCritical(npc.index))))
		{
			npc.ThinkFriendly("No Free Armor Table...");

			npc.m_bGetClosestTargetTimeAlly = false;

			float distance = FAR_FUTURE;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "obj_building")) != -1)
			{
				if(HealingCooldown[entity] < gameTime)
				{
					NPC_GetPluginById(i_NpcInternalId[entity], buffer, sizeof(buffer));
					if(!StrContains(buffer, "obj_armortable"))
					{
						GetAbsOrigin(entity, vecTarget);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
							continue;
						
						if(!npc.CanPathToAlly(entity))
							continue;
						
						distance = dist;
						ally = entity;
						npc.m_iTargetAlly = ally;
						npc.m_iSeakingObject = 2;
					}
				}
			}
		}
		else
		{
			npc.ThinkFriendly("Everything is fine");
		}
	}

	int walkStatus;

	// Run up to a building
	if(npc.m_iSeakingObject)
	{
		npc.ThinkCombat("Retreating!");

		WorldSpaceCenter(ally, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(distance < 10000.0)
		{
			npc.FaceTowards(vecTarget, 10000.0);

			if(npc.m_iSeakingObject == 5)
			{
				npc.ThinkFriendly("Repairing!");

				// Repairing
				npc.SetActivity("ACT_COVER_LOW", 0.0);
				walkStatus = -1;	// Don't move

				if(npc.m_flNextMeleeAttack < gameTime)
				{
					if(i_NpcInternalId[ally] == MedivalBuilding_Id() && i_AttacksTillMegahit[ally] < 255)
					{
						i_AttacksTillMegahit[ally]++;
					}
					else
					{
						npc.m_flNextMeleeAttack = gameTime + (npc.m_iHasPerk == npc.m_iGunType ? 0.16 : 0.2);
						
						int healing = RoundToCeil(npc.m_iGunValue * 0.004);
						if(healing < 2)
							healing = 2;

						if(healing > 50)
							healing = 50;
						
						if(team != TFTeam_Red)
							healing *= 200;
						
						int buildingMax = ReturnEntityMaxHealth(ally);
						int buildingHP = GetEntProp(ally, Prop_Data, "m_iHealth");
						int repairHP = team == TFTeam_Red ? GetEntProp(ally, Prop_Data, "m_iRepair") : 99999;

						// Limit max health
						if((buildingHP + healing) > buildingMax)
							healing -= (buildingHP + healing) - buildingMax;
						
						// Limit repair left
						if(healing > repairHP)
							healing = repairHP;

						if(healing > 0)
						{
							healing = HealEntityGlobal(npc.index, ally, float(healing));

							repairHP -= healing;

							if(repairHP < 1)
							{
								repairHP = 0;
								npc.m_iSeakingObject = 0;
							}
							
							if(team == TFTeam_Red)
								SetEntProp(ally, Prop_Data, "m_iRepair", repairHP);
							
							switch(GetURandomInt() % 2)
							{
								case 0:
								{
									//particle can spawn stuff at 0 0 0 in world spawn, oops!
									TE_Particle("manmelter_impact_sparks01", vecTarget, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
									EmitSoundToAll("physics/metal/metal_box_strain2.wav", ally, SNDCHAN_AUTO, 70,_,1.0, 120);
								}
								case 1:
								{
									TE_Particle("manmelter_impact_sparks01", vecTarget, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
									EmitSoundToAll("physics/metal/metal_box_strain4.wav", ally, SNDCHAN_AUTO, 70,_,1.0, 120);
								}
							}
						}
						else
						{
							npc.m_iSeakingObject = 0;
						}
					}
				}
			}
			else
			{
				bool doneThing = true;
				walkStatus = -1;	// Don't move

				switch(npc.m_iSeakingObject)
				{
					case 1:	// Healing Station
					{
						HealingCooldown[ally] = gameTime + 90.0;

						health += 100 + (maxhealth / 10);
						if(health > maxhealth)
							health = maxhealth;

						HealEntityGlobal(npc.index, npc.index, 100.0 + (ReturnEntityMaxHealth(npc.index) / 5.0), _, 1.0);
					}
					case 2:	// Armor Table
					{
						HealingCooldown[ally] = gameTime + 45.0;
						
						GrantEntityArmor(npc.index, false, 0.25, 0.25, 0);
						//Same as medigun giving armor, exact same logic, same amount.
						Elemental_ClearDamage(npc.index);
					}
					case 3:	// Perk Machine
					{
						HealingCooldown[ally] = gameTime + 40.0;

						npc.m_iHasPerk = npc.m_iGunType;
					}
					case 4:	// Medic
					{
						if((ally <= MaxClients && dieingstate[ally] > 0) || Citizen_ThatIsDowned(ally))
						{
							// Reviving first
							doneThing = false;
						}
						else
						{
							HealingCooldown[npc.index] = gameTime + 10.0;

							float healing = npc.m_iGunValue * 0.03;
							if(team != TFTeam_Red)
								healing *= 100;
							
							if(f_TimeUntillNormalHeal[ally] - 2.0 > GetGameTime())
							{
								healing *= 0.5;
							}
							int BeamIndex = ConnectWithBeam(npc.index, ally, 50, 125, 50, 1.5, 1.5, 1.35, "sprites/laserbeam.vmt");
							SetEntityRenderFx(BeamIndex, RENDERFX_FADE_FAST);
							CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
							HealEntityGlobal(npc.index, ally, healing, _, 3.0);

							ApplyStatusEffect(npc.index, npc.index, "Healing Resolve", 7.0);
							ApplyStatusEffect(npc.index, ally, "Healing Resolve", 7.0);
							
							if(ally <= MaxClients)
								ClientCommand(ally, "playgamesound items/smallmedkit1.wav");
						}
					}
					case 6, 7, 8, 9, 10, 11: // Building
					{
						if(!b_ThisEntityIgnoredBeingCarried[ally])
						{
							float vecPos[3], vecAng[3];
							GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", vecPos);
							vecPos[2] += 30.0;
							GetEntPropVector(ally, Prop_Data, "m_angRotation", vecAng);
							vecAng[0] = 0.0;
							vecAng[2] = 0.0;

							static const char BuildingPlugin[][] =
							{
								"obj_barricade",
								"obj_decorative",
								"obj_ammobox",
								"obj_armortable",
								"obj_perkmachine",
								"obj_packapunch",
								"obj_sentrygun",
								"obj_mortar",
								"obj_railgun",
								"obj_healingstation"
							};

							int id = npc.m_iSeakingObject - 6;
							if(id == 1)
								id = npc.m_iClassRole == Cit_Builder ? 6 : 9;

							int entity = Building_BuildByName(BuildingPlugin[id], npc.index, vecPos, vecAng);
							if(entity != -1)
							{
								bool TryPlace = false;
								TryPlace = Building_AttemptPlace(entity, npc.index, _ , 0.0);
								for(int loop = 1; loop <= 4; loop++)
								{
									if(TryPlace)
										break;
									TryPlace = Building_AttemptPlace(entity, npc.index, _ , float(20 * loop));
								}

								if(TryPlace)
								{
									if(view_as<ObjectGeneric>(entity).SentryBuilding)
									{
										i_PlayerToCustomBuilding[npc.index] = EntIndexToEntRef(entity);
									}
									if(id == 9)
									{
										for(int client = 1; client <= MaxClients; client++)
										{
											if(IsClientInGame(client))
												ApplyBuildingCollectCooldown(entity, client, 30.0);
										}
									}

									if(npc.m_iCanBuild)
									{
										npc.m_iCanBuild = 0;
									}
									else
									{
										HealingCooldown[npc.index] = GetGameTime() + 20.0;
									}
								}
								else
								{
									DestroyBuildingDo(entity);
								}
							}
						}
					}
				}

				if(doneThing)
				{
					npc.SetActivity("ACT_CIT_HEAL", 0.0, 2.0);
					ally = 0;
					npc.m_iTargetAlly = 0;
					npc.m_iSeakingObject = 0;
					npc.m_flReloadDelay = gameTime + 0.75;
				}
			}
		}
		else
		{
			npc.ThinkFriendly("Going somewhere!");
			walkStatus = 5;	// Run to ally (activity handled)

			switch(npc.m_iSeakingObject)
			{
				case 1:
				{
					// Cancel going to healing station if we got healed enough
					if(combat && health > (maxhealth / 2))
					{
						npc.m_iSeakingObject = 0;
					}
				}
				case 4:
				{
					// Cancel going to ally if they running away
					if(combat && i_NpcInternalId[ally] == NPCId && view_as<Citizen>(ally).m_iSeakingObject)
					{
						npc.m_iSeakingObject = 0;
					}
				}
			}
		}
	}

	// We have a target
	else if(target > 0)
	{
		npc.m_flidle_talk = 0.0;
		WorldSpaceCenter(target, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(RunFromNPC(target) && view_as<SawRunner>(target).m_iTarget == npc.index && distance < 250000.0)
		{
			npc.ThinkCombat("Run away!");
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
						npc.ThinkCombat("Melee fighting!");

						npc.SetActivity("ACT_MELEE_ANGRY_MELEE", 0.0);
						walkStatus = -1;	// Don't move
						
						npc.FaceTowards(vecTarget, 1000.0);

						if(npc.m_flNextMeleeAttack < gameTime)
						{
							npc.AddGesture("ACT_MELEE_ATTACK_SWING", .SetGestureSpeed = 0.8 / (npc.m_fGunFirerate * npc.m_fGunBonusFireRate));
							
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
					else if(!injured && !helpAlly)
					{
						npc.ThinkCombat("Too far away to fight!");

						npc.SetActivity("ACT_RUN_CROUCH", 320.0);
						walkStatus = 1;	// Walk up
						
						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Enable");
					}
					else
					{
						npc.ThinkCombat("Standby");
					}
				}
				case Cit_Pistol:
				{
					if(npc.m_flNextRangedAttack > gameTime)	// On cooldown
					{
						npc.ThinkCombat("Pistol fighting!");

						npc.FaceTowards(vecTarget, 500.0);
						npc.SetActivity("ACT_RANGE_ATTACK_PISTOL", 0.0);
						walkStatus = -1;	// Don't move

						if(npc.m_iWearable1 > 0)
							AcceptEntityInput(npc.m_iWearable1, "Enable");
					}
					else
					{
						bool outOfRange = (distance > ((BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus) * (BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus)));

						if(reloadStatus == 2 || (outOfRange && reloadStatus == 1))	// We need to reload now
						{
							if(!noSafety && distance < 250000.0 && CanOutRun(target))
							{
								npc.ThinkCombat("Too close to reload!");

								// Too close to safely reload
								npc.SetActivity("ACT_RUN", 320.0);
								walkStatus = 3;	// Back off
							}

							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Disable");
						}
						else if(helpAlly)
						{
							npc.ThinkCombat("Standby");
						}
						else if(outOfRange)
						{
							npc.ThinkCombat("Too far away to fight!");

							// Too far away, walk up
							npc.SetActivity("ACT_RUN", 320.0);
							walkStatus = 1;
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Disable");
						}
						else if(!noSafety && distance < 100000.0 && CanOutRun(target))	// Too close for the Pistol
						{
							npc.ThinkCombat("Too close to fight!");

							npc.SetActivity("ACT_RUN", 320.0);
							walkStatus = 3;	// Back off
							
							if(npc.m_iWearable1 > 0)
								AcceptEntityInput(npc.m_iWearable1, "Disable");
						}
						else	// Try to shoot
						{
							float npc_pos[3];
							WorldSpaceCenter(npc.index, npc_pos);
							
							int enemy = Can_I_See_Enemy(npc.index, target);
							
							if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
							{
								npc.ThinkCombat("Pistol fighting!");
								KillFeed_SetKillIcon(npc.index, "pistol");
								npc.FaceTowards(vecTarget, 15000.0);
								npc.SetActivity("ACT_RANGE_ATTACK_PISTOL", 0.0);
								walkStatus = -1;	// Don't move
								
								if(npc.m_iWearable1 > 0)
									AcceptEntityInput(npc.m_iWearable1, "Enable");
								
								npc.m_iAnimationState = -1;
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
								
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.GetDamage(), 9000.0, DMG_BULLET, "bullet_tracer01_red", _, _, "muzzle");
								npc.PlayPistolSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
							else
							{
								npc.ThinkCombat("Target out of sight!");

								if(npc.m_iWearable1 > 0)
									AcceptEntityInput(npc.m_iWearable1, "Disable");

								if(autoSeek)
									walkStatus = 1;
							}
						}
					}
				}
				case Cit_SMG:
				{
					bool cooldown = npc.m_flNextRangedAttack > gameTime;
					bool outOfRange = (!cooldown && distance > ((BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus) * (BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus)));
					
					if(!cooldown && (reloadStatus == 2 || (reloadStatus == 1 && outOfRange)))	// We need to reload now
					{
						if(!noSafety && distance < 250000.0 && CanOutRun(target))
						{
							npc.ThinkCombat("Too close to reload!");

							// Too close to safely reload
							npc.SetActivity("ACT_RUN_RIFLE", 320.0);
							walkStatus = 3;	// Back off
						}
					}
					else if(outOfRange)
					{
						npc.ThinkCombat("Too far away to fight!");

						if(!helpAlly)
						{
							// Too far away, walk up
							npc.SetActivity("ACT_RUN_RIFLE", 320.0);
							walkStatus = 1;
						}
					}
					else
					{
						if(helpAlly || (!noSafety && distance < 250000.0))	// Too close, walk backwards
						{
							npc.ThinkCombat("SMG, moving back!");

							npc.SetActivity("ACT_WALK_AIM_RIFLE", 224.0);
							walkStatus = 2;	// Back off
						}
						else
						{
							npc.ThinkCombat("SMG, standing here!");

							npc.SetActivity((npc.m_iSeed % 5) ? "ACT_IDLE_ANGRY_SMG1" : "ACT_IDLE_AIM_RIFLE_STIMULATED", 0.0);
							walkStatus = -1;	// Don't move
						}

						if(!cooldown)
						{
							float npc_pos[3];
							WorldSpaceCenter(npc.index, npc_pos);
							
							int enemy = Can_I_See_Enemy(npc.index, target);
							
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
								
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.GetDamage(), 9000.0, DMG_BULLET, "bullet_tracer01_red", _, _ , "muzzle");
								npc.PlaySMGSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
							else
							{
								if(autoSeek)
									walkStatus = 1;
							}
						}
					}
				}
				case Cit_AR:
				{
					bool cooldown = npc.m_flNextRangedAttack > gameTime;
					bool outOfRange = (!cooldown && distance > ((BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus) * (BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus)));
					
					if(!cooldown && (reloadStatus == 2 || (reloadStatus == 1 && outOfRange)))	// We need to reload now
					{
						if(!noSafety && distance < 250000.0 && CanOutRun(target))
						{
							npc.ThinkCombat("Too close to reload!");

							// Too close to safely reload
							npc.SetActivity("ACT_RUN_AR2", 320.0);
							walkStatus = 3;	// Back off
						}
					}
					else if(outOfRange)
					{
						npc.ThinkCombat("Too far away to fight!");

						if(!helpAlly)
						{
							// Too far away, walk up
							npc.SetActivity("ACT_RUN_AR2", 320.0);
							walkStatus = 1;
						}
					}
					else
					{
						if(helpAlly || (!noSafety && distance < 250000.0))	// Too close, walk backwards
						{
							npc.ThinkCombat("AR2, moving back!");

							npc.SetActivity("ACT_WALK_AIM_AR2", 224.0);
							walkStatus = 2;	// Back off
						}
						else
						{
							npc.ThinkCombat("AR2, standing here!");

							npc.SetActivity("ACT_IDLE_ANGRY_AR2", 0.0);
							walkStatus = -1;	// Don't move
						}

						if(!cooldown)
						{
							float npc_pos[3];
							WorldSpaceCenter(npc.index, npc_pos);
							
							int enemy = Can_I_See_Enemy(npc.index, target);
							
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
								
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.GetDamage(), 9000.0, DMG_BULLET, "bullet_tracer01_red", _, _, "muzzle");
								npc.PlayARSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
							else
							{
								if(autoSeek)
									walkStatus = 1;
							}
						}
					}
				}
				case Cit_Shotgun:
				{
					if(npc.m_flNextRangedAttack > gameTime)	// On cooldown
					{
						npc.ThinkCombat("Shotgun fighting!");

						npc.FaceTowards(vecTarget, 500.0);
						npc.SetActivity("ACT_IDLE_ANGRY_AR2", 0.0);
						walkStatus = -1;	// Don't move
					}
					else
					{
						bool outOfRange = (distance > ((BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus) * (BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus)));
						
						if(reloadStatus == 2 || (reloadStatus == 1 && outOfRange))	// We need to reload now
						{
							if(!noSafety && distance < 150000.0 && CanOutRun(target))
							{
								npc.ThinkCombat("Too close to reload!");

								// Too close to safely reload
								npc.SetActivity("ACT_RUN_AR2", 320.0);
								walkStatus = 3;	// Back off
							}
						}
						else if(helpAlly)
						{
							npc.ThinkCombat("Standby");
						}
						else if(outOfRange)
						{
							npc.ThinkCombat("Too far away to fight!");
							
							// Too far away, walk up
							npc.SetActivity("ACT_RUN_AR2", 320.0);
							walkStatus = 1;
						}
						else	// Try to shoot
						{
							float npc_pos[3];
							WorldSpaceCenter(npc.index, npc_pos);

							int enemy = Can_I_See_Enemy(npc.index, target);
							
							if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
							{
								npc.ThinkCombat("Shotgun fighting!");
								KillFeed_SetKillIcon(npc.index, "shotgun_primary");
								npc.FaceTowards(vecTarget, 15000.0);
								npc.SetActivity("ACT_IDLE_ANGRY_AR2", 0.0);
								walkStatus = -1;	// Don't move
								
								npc.m_iAnimationState = -1;
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
								
								FireBullet(npc.index, npc.m_iWearable1, npc_pos, vecDir, npc.GetDamage(), 9000.0, DMG_BULLET, "bullet_tracer01_red", _, _, "muzzle");
								npc.PlayShotgunSound();
								
								if(!npc.m_bFirstBlood && npc.CanTalk() && GetEntProp(npc.m_iTarget, Prop_Data, "m_iHealth") < 1)
								{
									npc.m_bFirstBlood = true;
									npc.PlaySound(Cit_FirstBlood);
								}
							}
							else
							{
								npc.ThinkCombat("Target out of sight!");
								if(autoSeek)
									walkStatus = 1;
							}
						}
					}
				}
				case Cit_RPG:
				{
					if(npc.m_flNextRangedAttack > gameTime)	// On cooldown
					{
						npc.ThinkCombat("RPG fighting!");

						npc.FaceTowards(vecTarget, 500.0);
						npc.SetActivity("ACT_IDLE_ANGRY_RPG", 0.0);
						walkStatus = -1;	// Don't move
					}
					else
					{
						bool outOfRange = (distance > ((BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus) * (BaseRange[npc.m_iGunType] * npc.m_fGunRangeBonus)));
						
						if(reloadStatus == 2 || (reloadStatus == 1 && outOfRange))	// We need to reload now
						{
							if(!noSafety && distance < 250000.0 && CanOutRun(target))
							{
								npc.ThinkCombat("Too close to reload!");

								// Too close to safely reload
								npc.SetActivity("ACT_RUN_RPG", 320.0);
								walkStatus = 3;	// Back off
							}
						}
						else if(helpAlly)
						{
							npc.ThinkCombat("Standby");
						}
						else if(outOfRange)
						{
							npc.ThinkCombat("Too far away to fight!");

							// Too far away, walk up
							npc.SetActivity("ACT_RUN_RPG", 320.0);
							walkStatus = 1;
						}
						else if(!noSafety && distance < 100000.0 && CanOutRun(target))	// Too close for the RPG
						{
							npc.ThinkCombat("Too close to fight!");

							npc.SetActivity("ACT_RUN_RPG", 320.0);
							walkStatus = 3;	// Back off
						}
						else	// Try to shoot
						{
							float npc_pos[3];
							WorldSpaceCenter(npc.index, npc_pos);
							
							int enemy = Can_I_See_Enemy(npc.index, target);
							
							if(IsValidEnemy(npc.index, enemy, true))	// We can see a target
							{
								npc.ThinkCombat("RPG fighting!");

								KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
								PredictSubjectPositionForProjectiles(npc, target, 1100.0, _, vecTarget);
								npc.FaceTowards(vecTarget, 15000.0);
								npc.SetActivity("ACT_IDLE_ANGRY_RPG", 0.0);
								walkStatus = -1;	// Don't move
								
								npc.m_iAnimationState = -1;
								npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_RPG");

								npc.m_flNextRangedAttack = gameTime + (npc.m_fGunFirerate * npc.m_fGunBonusFireRate);
								npc.m_iAttacksTillReload--;
								
								npc.FireRocket(vecTarget, npc.GetDamage(), 1100.0);
								npc.PlayRPGSound();
							}
							else
							{
								npc.ThinkCombat("Target out of sight!");
								if(autoSeek)
									walkStatus = 1;
							}
						}
					}
				}
			}
		}
	}
	else
	{
		npc.ThinkCombat("...");
	}

	// Reload
	if(!walkStatus && reloadStatus)
	{
		npc.m_iAttacksTillReload = npc.m_iGunClip;
		walkStatus = -1;	// Don't move
		
		switch(npc.m_iGunType)
		{
			case Cit_Pistol:
			{
				npc.SetActivity("ACT_RELOAD_PISTOL", 0.0, 2.0 / (npc.m_fGunReload * npc.m_fGunBonusReload));
				npc.m_flReloadDelay = gameTime + (0.65 * (npc.m_fGunReload * npc.m_fGunBonusReload));
				npc.PlayPistolReloadSound();

				if(npc.m_iWearable1 > 0)
					AcceptEntityInput(npc.m_iWearable1, "Enable");
				
				if(npc.m_iTarget > 0)
					npc.PlaySound(Cit_Reload);
			}
			case Cit_SMG:
			{
				npc.SetActivity("ACT_RELOAD_SMG1", 0.0, 2.0 / (npc.m_fGunReload * npc.m_fGunBonusReload));
				npc.m_flReloadDelay = gameTime + (1.2 * (npc.m_fGunReload * npc.m_fGunBonusReload));
				npc.PlaySMGReloadSound();
				
				if(npc.m_iTarget > 0)
					npc.PlaySound(Cit_Reload);
			}
			case Cit_AR:
			{
				npc.SetActivity("ACT_RELOAD_AR2", 0.0, 2.0 / (npc.m_fGunReload * npc.m_fGunBonusReload));
				npc.m_flReloadDelay = gameTime + (0.9 * (npc.m_fGunReload * npc.m_fGunBonusReload));
				npc.PlayARReloadSound();
				
				if(npc.m_iTarget > 0)
					npc.PlaySound(Cit_Reload);
			}
			case Cit_Shotgun:
			{
				npc.SetActivity("ACT_RELOAD_shotgun", 0.0, 2.0 / (npc.m_fGunReload * npc.m_fGunBonusReload));
				npc.m_flReloadDelay = gameTime + (1.25 * (npc.m_fGunReload * npc.m_fGunBonusReload));
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

	// Follow ally player
	if(!walkStatus || walkStatus == 3)
	{
		if(npc.m_iSeakingObject == 0 && seakAlly)
		{
			ally = 0;
			npc.m_iTargetAlly = 0;
			npc.m_iSeakingObject = 0;

			if(team == TFTeam_Red)
			{
				// Find an downed client to walk to
				float distance = 65000000.0;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(dieingstate[client] > 0 && TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
					{
						WorldSpaceCenter(client, vecTarget);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < distance)
						{
							distance = dist;
							ally = client;
							npc.m_iTargetAlly = ally;
						}
					}
				}

				// Find an downed rebel to walk to
				if(ally == 0)
				{
					int a, entity;
					while((entity = FindEntityByNPC(a)) != -1)
					{
						if(entity != npc.index && Citizen_ThatIsDowned(entity))
						{
							WorldSpaceCenter(entity, vecTarget);
							float dist = GetVectorDistance(vecTarget, vecMe, true);
							if(dist < distance)
							{
								distance = dist;
								ally = entity;
								npc.m_iTargetAlly = ally;
							}
						}
					}
				}

				// Find an alive client to walk to
				if(ally == 0 && (!combat || !npc.m_bRebelAgressive))
				{
					for(int client = 1; client <= MaxClients; client++)
					{
						if(!IgnorePlayer[client] && IsClientInGame(client) && IsEntityAlive(client))
						{
							WorldSpaceCenter(client, vecTarget);
							float dist = GetVectorDistance(vecTarget, vecMe, true);
							if(dist < distance)
							{
								distance = dist;
								ally = client;
								npc.m_iTargetAlly = ally;
							}
						}
					}
				}
			}
			
			if(ally == 0)
			{
				bool alpha;

				// Follow the alpha rebel
				int a, entity;
				while((entity = FindEntityByNPC(a)) != -1)
				{
					if(i_NpcInternalId[entity] == NPCId && GetTeam(entity) == team)
					{
						if(entity == npc.index)
						{
							alpha = true;
						}
						else
						{
							ally = entity;
							npc.m_iTargetAlly = ally;
						}

						break;
					}
				}

				if(alpha)
				{
					// Follow bosses
					a = 0;
					while((entity = FindEntityByNPC(a)) != -1)
					{
						if(entity != npc.index && i_NpcInternalId[entity] != NPCId && GetTeam(entity) == team && b_thisNpcIsABoss[entity])
						{
							WorldSpaceCenter(entity, vecTarget);
							if(b_thisNpcIsARaid[entity] || GetVectorDistance(vecTarget, vecMe, true) < 2000000.0)
							{
								ally = entity;
								npc.m_iTargetAlly = ally;
								break;
							}
						}
					}
				}
			}

			if(ally)
			{
				// How do I get to you
				if(npc.m_flTeleportCooldownAntiStuck < gameTime)
				{
					//dont spam expensive logic.
					npc.m_flTeleportCooldownAntiStuck = gameTime + 2.0;
					if(!npc.CanPathToAlly(ally))
					{
						WorldSpaceCenter(ally, vecTarget);
						TeleportEntity(npc.index, vecTarget);
						npc.m_flTeleportCooldownAntiStuck = gameTime + 15.0;
					}
				}
			}
		}

		if(!walkStatus && ally > 0)
		{
			WorldSpaceCenter(ally, vecTarget);
			float distance = GetVectorDistance(vecTarget, vecMe, true);
			if((ally <= MaxClients && dieingstate[ally] > 0) || Citizen_ThatIsDowned(ally))
			{
				if(distance > 10000.0)
					walkStatus = 5;	// Run to ally (activity handled)
			}
			else if(distance > 200000.0 || (combat && distance > 60000.0))
			{
				walkStatus = 5;	// Run to ally (activity handled)
			}
			else if(distance > 20000.0 || (combat && distance > (6000.0 + (fabs(float(npc.m_iSeed)) / 214748.3647))))
			{
				walkStatus = 4;	// Walk to ally (activity handled)

				//if(!combat)
				{
					// Don't go into other rebels
					int a, entity;
					bool allow;
					while((entity = FindEntityByNPC(a)) != -1)
					{
						if(entity == npc.index)
						{
							allow = true;
							break;
						}

						if(!allow && i_NpcInternalId[entity] == NPCId)
						{
							WorldSpaceCenter(entity, vecTarget);
							distance = GetVectorDistance(vecTarget, vecMe, true);
							if(distance < 6000.0)
							{
								walkStatus = 0;
								break;
							}
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
			npc.m_flidle_talk = 0.0;

			npc.SetActivity("ACT_RUN_PANICKED", 320.0);

			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.PlaySound(Cit_CadeDeath);
				npc.m_flNextMeleeAttack = gameTime + 10.0;
			}
			
			BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vecTarget);
			npc.SetGoalVector(vecTarget);
			
			npc.StartPathing();
		}
		case 5:	// Run up to our ally
		{
			npc.m_bAllowBackWalking = false;
			npc.m_flidle_talk = 0.0;
			
			switch(npc.m_iGunType)
			{
				case Cit_SMG:
				{
					npc.SetActivity(combat ? "ACT_RUN_RIFLE" : injured ? "ACT_RUN_RIFLE_STIMULATED" : "ACT_RUN_RIFLE_RELAXED", combat ? 320.0 : 240.0);
				}
				case Cit_AR, Cit_Shotgun:
				{
					npc.SetActivity(combat ? "ACT_RUN_AR2" : injured ? "ACT_RUN_AR2_STIMULATED" : "ACT_RUN_AR2_RELAXED", combat ? 320.0 : 240.0);
				}
				case Cit_RPG:
				{
					npc.SetActivity(combat ? "ACT_RUN_RPG" : "ACT_RUN_RPG_RELAXED", combat ? 320.0 : 240.0);
				}
				default:
				{
					npc.SetActivity("ACT_RUN", combat ? 320.0 : 240.0);
					
					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Disable");
				}
			}

			if(ally > 0)
			{
				npc.SetGoalEntity(ally);
				npc.StartPathing();
			}
		}
		case 4:	// Walk up to our ally
		{
			npc.m_bAllowBackWalking = false;
			npc.m_flidle_talk = 0.0;

			switch(npc.m_iGunType)
			{
				case Cit_Melee:
				{
					npc.SetActivity("ACT_WALK", 90.0);
					
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

			if(ally > 0)
			{
				npc.SetGoalEntity(ally);
				npc.StartPathing();
			}
		}
		case 2, 3:	// Walk away against our target
		{
			npc.m_flidle_talk = 0.0;
			npc.m_bAllowBackWalking = walkStatus == 2; // Walk backwards against our target

			bool found;
			
			if(ally > 0)
			{
				// Check if the enemy is too close to me
				WorldSpaceCenter(target, vecTarget);
				if(GetVectorDistance(vecMe, vecTarget, true) > 80000.0)
				{
					// Check if the enemy is too close to our ally
					WorldSpaceCenter(ally, vecMe);
					if(GetVectorDistance(vecMe, vecTarget, true) > 300000.0)
					{
						npc.SetGoalEntity(ally);
						found = true;
					}
				}
			}

			if(!found)
			{
				BackoffFromOwnPositionAndAwayFromEnemy(npc, target, _, vecTarget);
				npc.SetGoalVector(vecTarget, true);
			}
			
			npc.StartPathing();
		}
		case 1:	// Walk up to our target
		{
			npc.m_flidle_talk = 0.0;
			npc.m_bAllowBackWalking = false;
			
			WorldSpaceCenter(target, vecTarget);
			if(GetVectorDistance(vecMe, vecTarget, true) > 29000.0)
			{
				npc.SetGoalEntity(target);
			}
			else
			{
				PredictSubjectPosition(npc, target, _, _, vecTarget);
				npc.SetGoalVector(vecTarget);
			}
			
			npc.StartPathing();
		}
		default:
		{
			npc.StopPathing();
		}
	}

	bool isReviving;

	// Revive check
	if(walkStatus < 1 && ally > 0 && team == TFTeam_Red)
	{
		bool medic = npc.m_iClassRole == Cit_Medic && npc.m_iHasPerk == npc.m_iGunType;
		
		float VecAlly[3]; WorldSpaceCenter(ally, VecAlly );
		float Vecself[3]; WorldSpaceCenter(npc.index, Vecself);	
		float flDistanceToTarget = GetVectorDistance(VecAlly, Vecself, true);
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.8))
		{
			if(ally <= MaxClients)
			{
				if(dieingstate[ally] > 0)
				{
					ReviveClientFromOrToEntity(ally, npc.index, _, medic ? 0 : 1);
					isReviving = true;
				}
			}
			else if(Citizen_ThatIsDowned(ally))
			{
				int speed = medic ? 6 : 3;
				Rogue_ReviveSpeed(speed);
				Citizen_ReviveTicks(ally, speed, 0);
				isReviving = true;
			}
		}
	}

	// We standing, doing nothing
	if(!walkStatus || isReviving)
	{
		if(npc.m_flidle_talk == 0.0)
			npc.m_flidle_talk = gameTime + 10.0 + (GetURandomFloat() * 10.0) + (float(npc.m_iSeed) / 214748364.7);
		
		/*
		if(isReviving)
		{
			if(npc.m_iGunType != Cit_Melee)
			{
				int iPitch = npc.LookupPoseParameter("aim_pitch");
				if(iPitch > 0)
				{
					npc.SetPoseParameter(iPitch, 50.0);
				}
			}
		}
		else
		{
			int iPitch = npc.LookupPoseParameter("aim_pitch");
			if(iPitch > 0)
			{
				npc.SetPoseParameter(iPitch, 0.0);
			}
		}
		*/
		switch(npc.m_iGunType)
		{
			case Cit_Melee:
			{
				if(!npc.m_bHero && !npc.m_bFemale)
				{
					if(!isReviving)
						npc.SetActivity("ACT_IDLE_ANGRY_MELEE", 0.0);
					else
						npc.SetActivity("ACT_COVER_LOW", 0.0);
					
					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
				else
				{
					if(!isReviving)
						npc.SetActivity("ACT_IDLE", 0.0);
					else
						npc.SetActivity("ACT_COVER_LOW", 0.0);

					if(npc.m_iWearable1 > 0)
						AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
			}
			case Cit_SMG:
			{
				if(!isReviving)
					npc.SetActivity(combat ? "ACT_IDLE_SMG1" : injured ? "ACT_IDLE_SMG1_STIMULATED" : "ACT_IDLE_SMG1_RELAXED", 0.0);
				else
					npc.SetActivity("ACT_RANGE_AIM_SMG1_LOW", 0.0);
			}
			case Cit_AR:
			{
				if(!isReviving)
					npc.SetActivity(combat ? "ACT_IDLE_AR2" : injured ? "ACT_IDLE_AR2_STIMULATED" : "ACT_IDLE_AR2_RELAXED", 0.0);
				else
					npc.SetActivity("ACT_RANGE_AIM_SMG1_LOW", 0.0);
			}
			case Cit_Shotgun:
			{
				if(!isReviving)
					npc.SetActivity(combat ? "ACT_IDLE_SHOTGUN_AGITATED" : injured ? "ACT_IDLE_SHOTGUN_STIMULATED" : "ACT_IDLE_SHOTGUN_RELAXED", 0.0);
				else
					npc.SetActivity("ACT_RANGE_AIM_SMG1_LOW", 0.0);
			}
			case Cit_RPG:
			{
				if(!isReviving)
					npc.SetActivity(combat ? "ACT_IDLE_RPG" : "ACT_IDLE_RPG_RELAXED", 0.0);
				else
					npc.SetActivity("ACT_RANGE_AIM_SMG1_LOW", 0.0);
			}
			default:
			{
				if(!isReviving)
					npc.SetActivity((!npc.m_bHero && combat) ? "ACT_IDLE_ANGRY" : "ACT_IDLE", 0.0);
				else
					npc.SetActivity("ACT_COVER_LOW", 0.0);
				
				if(npc.m_iWearable1 > 0)
					AcceptEntityInput(npc.m_iWearable1, "Disable");
			}
		}
		
		if(npc.m_flidle_talk < gameTime)
		{
			npc.m_flidle_talk = 0.0;

			if(combat)
			{
				if(ally > 0 && ally <= MaxClients)
					IgnorePlayer[ally] = true;
			}

			if(injured)
			{
				npc.PlaySound(Cit_LowHealth);
			}
			else
			{
				int talkingTo;
				float distance = 60000.0;
				
				int i = -1;
				while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
				{
					if(i_NpcInternalId[i] == NPCId && i != npc.index && view_as<Citizen>(i).m_flidle_talk != 0.0)
					{
						WorldSpaceCenter(i, vecTarget);
						float dist = GetVectorDistance(vecTarget, vecMe, true);
						if(dist < 60000.0)
						{
							if(combat)
							{
								view_as<Citizen>(i).m_flidle_talk = 0.0;
							}
							else if(dist < distance)
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
					WorldSpaceCenter(client, vecTarget);
					if(GetVectorDistance(vecTarget, vecMe, true) < distance)
						talkingTo = client;
				}
				
				if(talkingTo)
				{
					if(talkingTo > MaxClients)
						WorldSpaceCenter(talkingTo, vecTarget);
					
					npc.SlowTurn(vecTarget);
					
					if(npc.m_iClassRole == Cit_Medic && talkingTo <= MaxClients && GetClientHealth(talkingTo) < (SDKCall_GetMaxHealth(talkingTo) / 2))
					{
						npc.PlaySound(Cit_Healer);
					}
					else if(npc.m_iClassRole == Cit_Builder && talkingTo <= MaxClients)
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
						view_as<Citizen>(talkingTo).m_flidle_talk = 0.0;
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
}

static bool CanOutRun(int target)
{
	if(target <= MaxClients)
		return true;
	if(b_ThisWasAnNpc[target])
	{
		return (300.0 > view_as<CClotBody>(target).GetRunSpeed());
	}
	return true;
}

void Citizen_MiniBossSpawn()
{
	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[i] == NPCId && GetTeam(i) == TFTeam_Red && view_as<Citizen>(i).CanTalk())
		{
			view_as<Citizen>(i).PlaySound(Cit_MiniBoss);
			view_as<Citizen>(i).m_flidle_talk = 0.0;

			if(GetURandomInt() % 2)
				break;
		}
	}
}

void Citizen_MiniBossDeath(int entity)
{
	int talkingTo;
	float distance;
	
	float vecMe[3]; WorldSpaceCenter(entity, vecMe);
	float vecTarget[3];
	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[i] == NPCId && GetTeam(i) == TFTeam_Red && view_as<Citizen>(i).CanTalk())
		{
			WorldSpaceCenter(i, vecTarget);
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
		view_as<Citizen>(talkingTo).m_flidle_talk = 0.0;
	}
}

void Citizen_LiveCitizenReaction(int entity)
{
	int talkingTo;
	float distance = 60000.0;
	
	float vecMe[3]; WorldSpaceCenter(entity, vecMe);
	float vecTarget[3];
	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[i] == NPCId && i != entity && view_as<Citizen>(i).m_flidle_talk != 0.0)
		{
			WorldSpaceCenter(i, vecTarget);
			float dist = GetVectorDistance(vecTarget, vecMe, true);
			if(dist < distance)
			{
				talkingTo = i;
				distance = dist;
			}
		}
	}
	
	int client = GetClosestAllyPlayer(entity);
	if(client > 0)
	{
		WorldSpaceCenter(client, vecTarget );
		if(GetVectorDistance(vecTarget, vecMe, true) < distance)
			talkingTo = client;
	}
	
	if(talkingTo)
	{
		if(talkingTo > MaxClients)
		{
			WorldSpaceCenter(talkingTo, vecTarget);
			view_as<Citizen>(talkingTo).SlowTurn(vecMe);
			view_as<Citizen>(talkingTo).m_flidle_talk = 0.0;
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
		
		float vecMe[3]; WorldSpaceCenter(client, vecMe);
		float vecTarget[3];
		int i = -1;
		while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
		{
			if(i_NpcInternalId[i] == NPCId && GetTeam(i) == TFTeam_Red)
			{
				view_as<Citizen>(i).m_flidle_talk = 0.0;
				
				WorldSpaceCenter(i, vecTarget);
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
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	if(StrContains(npc_classname, "npc_sawrunner") != -1 ||
		StrContains(npc_classname, "npc_3650") != -1 ||
		StrContains(npc_classname, "npc_lastknight") != -1 ||
		StrContains(npc_classname, "npc_saintcarmen") != -1)
	{
		return true;
	}
	else if(StrContains(npc_classname, "npc_stalker_combine") != -1 && b_StaticNPC[entity])
	{
		return true;
	}
	else if(StrContains(npc_classname, "npc_stalker_father") != -1 && b_StaticNPC[entity] && !b_movedelay[entity])
	{
		return true;
	}
	else
	{
		return b_NpcIsInvulnerable[entity];
	}
}

stock void Citizen_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damage < 9999999.0)
	{
		Citizen npc = view_as<Citizen>(victim);
		if(npc.m_nDowned || (attacker > 0 && GetTeam(victim) == GetTeam(attacker)))
		{
			damage = 0.0;
		}
		else
		{
			if(npc.m_bRebelAgressive)
			{
				damage *= 0.85;
			}

			int value = npc.m_iGunValue;
			if(value > 40000)
			{
				damage *= 0.8;
			}
			else if(value > 20000)
			{
				damage *= 0.85;
			}
			else if(value > 10000)
			{
				damage *= 0.9;
			}
			else if(value > 5000)
			{
				damage *= 0.95;
			}
			
			if(npc.m_iGunType == Cit_Melee)
			{
				damage *= 0.7;

				if(damagetype & (DMG_CLUB|DMG_TRUEDAMAGE))
				{
					if(value > 40000)
					{
						damage *= 0.75;
					}
					else if(value > 20000)
					{
						damage *= 0.8;
					}
					else if(value > 10000)
					{
						damage *= 0.85;
					}
					else if(value > 5000)
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
				if(GetTeam(victim) == TFTeam_Red)
				{
					KillFeed_Show(victim, inflictor, attacker, 0, weapon, damagetype);
					npc.SetDowned(1);
					damage = 0.0;
				}
			}
			else
			{
				i_PlayerDamaged[victim] += RoundFloat(damage);
				npc.PlaySound(Cit_Hurt);

				if(npc.m_iTarget < 1)
					npc.m_iTarget = attacker;
			}
		}
	}
}

public void Citizen_NPCDeath(int entity)
{
	Citizen npc = view_as<Citizen>(entity);
	
	if(npc.m_iWearable1 > 0 && IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(npc.m_iWearable2 > 0 && IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(npc.m_iWearable3 > 0 && IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(npc.m_iWearable4 > 0 && IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

// 1 is sentry
// 2 is barricade
// 3 is Support buildings
int BuildingAmountRebel(int rebel, int buildingType, int &buildingmax)
{
	Citizen npc = view_as<Citizen>(rebel);
	int limit = 2 + (npc.m_iGunValue / 4000);
	if(limit > 12)
		limit = 12;

	switch(buildingType)
	{
		case 1:
			limit = 1;
		case 2:
		{
			limit = 2 + (npc.m_iGunValue / 4000);
			if(limit > 4)
				limit = 4;
		}
	}
	int ActiveLimit = 0;
	switch(buildingType)
	{
		case 1:
		{
			if(IsValidEntity(Object_GetSentryBuilding(rebel)))
				ActiveLimit++;
		} 
		case 2:
			ActiveLimit = ObjectBarricade_Buildings(rebel);
		case 3:
			ActiveLimit = Object_SupportBuildings(rebel);
	}
	buildingmax = limit;
	return ActiveLimit;

}


enum struct CitizenVoteRoleEnum
{
	int RebelVoted;
	int IDClient_VotedWho;
	int VotedWhat;
}
static ArrayList CitizenVoteRole;

void CitizenVoteResults(int entity, int VoteFor[4])
{
	if(!CitizenVoteRole)
		return;

	CitizenVoteRoleEnum data;
	int length = CitizenVoteRole.Length;
	for(int i; i < length; i++)
	{
		// Loop through the arraylist
		//Did they vote already?
		CitizenVoteRole.GetArray(i, data);
		int client = GetClientOfUserId(data.IDClient_VotedWho);
		if(!IsValidClient(client))
		{
			CitizenVoteRole.Erase(i);
			i--;
			length--;
			continue;
		}
		if (TeutonType[client] == TEUTON_WAITING)
		{
			CitizenVoteRole.Erase(i);
			i--;
			length--;
			continue;
		}
		if(!IsValidEntity(data.RebelVoted))
		{
			CitizenVoteRole.Erase(i);
			i--;
			length--;
			continue;
		}
		
		if(data.RebelVoted == entity)
		{
			VoteFor[data.VotedWhat]++;
		}
	}
}

void CitizenVoteFor(int entity, int client, int VoteFor)
{
	if(!CitizenVoteRole)
		CitizenVoteRole = new ArrayList(sizeof(CitizenVoteRoleEnum));

	int ClientID = GetClientUserId(client);

	bool AddEntry = true;
	CitizenVoteRoleEnum data;
	int length = CitizenVoteRole.Length;
	for(int i; i < length; i++)
	{
		// Loop through the arraylist
		//Did they vote already?
		CitizenVoteRole.GetArray(i, data);
		if(data.IDClient_VotedWho == ClientID && data.RebelVoted == entity)
		{
			//They voted already! Change vote!
			data.VotedWhat = VoteFor;
			CitizenVoteRole.SetArray(i, data);
			AddEntry = false;
			break;
		}
	}

	if(AddEntry)
	{
		//No vote was found?
		// Create a new entry!
		data.IDClient_VotedWho = ClientID;
		data.RebelVoted = entity;
		data.VotedWhat = VoteFor;
		CitizenVoteRole.PushArray(data);
	}

	Citizen npc = view_as<Citizen>(entity);
	int VoteForex[4];
	CitizenVoteResults(entity, VoteForex);

	int SwitchToWho = -1;
	int CurrentHighest = 0;
	
	for(int loop; loop < sizeof(VoteForex); loop ++)
	{
		if(VoteForex[loop] > CurrentHighest)
		{
			SwitchToWho = loop;
			CurrentHighest = VoteForex[loop];
		}
	}
	if(SwitchToWho == -1)
		return;

	switch(SwitchToWho)
	{
		case 0:
		{
			if(npc.m_iClassRole == Cit_Fighter)
			{
				if(npc.m_iGunType != Cit_Melee)
					return;
			}

			static const int Types[] = {Cit_Pistol, Cit_SMG, Cit_RPG};
			Citizen_UpdateStats(entity, Types[GetURandomInt() % sizeof(Types)], Cit_Fighter);
		}
		case 1:
		{
			if(npc.m_iGunType == Cit_Melee)
				return;

			Citizen_UpdateStats(entity, Cit_Melee, Cit_Fighter);
		}
		case 2:
		{
			if(npc.m_iClassRole == Cit_Medic)
				return;

			Citizen_UpdateStats(entity, Cit_SMG, Cit_Medic);
		}
		case 3:
		{
			if(npc.m_iClassRole == Cit_Builder)
				return;

			Citizen_UpdateStats(entity, Cit_AR, Cit_Builder);
		}
	}
}