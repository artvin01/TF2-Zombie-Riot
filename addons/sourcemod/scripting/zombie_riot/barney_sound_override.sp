
static const char g_Yes[][] = {
	"vo/npc/barney/ba_yell.wav",
};
static const char g_No[][] = {
	"vo/npc/barney/ba_no01.wav",
	"vo/npc/barney/ba_no02.wav",
};
static const char g_DeathSound[][] = {
	"vo/npc/barney/ba_ohshit03.wav",
};
static const char g_Help[][] = {
	"vo/npc/barney/ba_gordonhelp.wav",
	"vo/npc/barney/ba_covermegord.wav",
	"vo/npc/barney/ba_littlehelphere.wav"
};

static const char g_GoGoGo[][] = {
	"vo/npc/barney/ba_openfiregord.wav",
};
static const char g_Neagtive[][] =
{
	"vo/npc/barney/ba_damnit.wav",
	"vo/npc/barney/ba_danger02.wav"
};

static const char g_Positive[][] =
{
	"vo/npc/barney/ba_laugh01.wav",
	"vo/npc/barney/ba_laugh02.wav",
	"vo/npc/barney/ba_laugh03.wav",
	"vo/npc/barney/ba_laugh04.wav",
};

static const char g_Jeers[][] =
{
	"vo/npc/barney/ba_wounded01.wav",
	"vo/npc/barney/ba_wounded02.wav",
	"vo/npc/barney/ba_wounded03.wav",
	"vo/k_lab/ba_saidlasttime.wav",
	"vo/k_lab/ba_thingaway02.wav"
};
static const char g_Cheers[][] =
{
	"vo/npc/barney/ba_losttouch.wav",
	"vo/npc/barney/ba_ohyeah.wav",
	"vo/trainyard/ba_thatbeer02.wav",
	"vo/trainyard/ba_rememberme.wav",
	"vo/trainyard/ba_sorryscare.wav"
};

static const char g_Spy[][] =
{
	"vo/npc/barney/ba_grenade01.wav",
	"vo/npc/barney/ba_grenade02.wav",
};

static const char g_Incoming[][] =
{
	"vo/npc/barney/ba_uhohheretheycome.wav",
};
static const char g_Battlecry[][] =
{
	"vo/npc/barney/ba_soldiers.wav",
	"vo/npc/barney/ba_goingdown.wav",
	"vo/trainyard/ba_crowbar02.wav",
};

static const char g_HurtSound[][] =
{
	"vo/npc/barney/ba_pain01.wav",
	"vo/npc/barney/ba_pain02.wav",
	"vo/npc/barney/ba_pain03.wav",
	"vo/npc/barney/ba_pain04.wav",
	"vo/npc/barney/ba_pain05.wav",
	"vo/npc/barney/ba_pain06.wav",
	"vo/npc/barney/ba_pain07.wav",
	"vo/npc/barney/ba_pain08.wav",
	"vo/npc/barney/ba_pain09.wav",
	"vo/npc/barney/ba_pain10.wav",
};

static const char g_Thanks[][] =
{
	"vo/k_lab2/ba_goodnews_c.wav",
	"vo/k_lab/ba_geethanks.wav",
};
static const char g_NiceShot[][] =
{
	"vo/streetwar/rubble/ba_illbedamned.wav",
};
static const char g_GoodJob[][] =
{
	"vo/k_lab/ba_sarcastic01.wav",
};

bool BarneySoundOverride(int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, int &seed)
{
	if(StrContains(sample, "thanks", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Thanks[GetRandomInt(0, sizeof(g_Thanks) - 1)]);
		return true;
	}
	if(StrContains(sample, "negative", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Neagtive[GetRandomInt(0, sizeof(g_Neagtive) - 1)]);
		return true;
	}
	if(StrContains(sample, "jeers", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Jeers[GetRandomInt(0, sizeof(g_Jeers) - 1)]);
		return true;
	}
	if(StrContains(sample, "help", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Help[GetRandomInt(0, sizeof(g_Help) - 1)]);
		return true;
	}
	if(StrContains(sample, "incoming", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Incoming[GetRandomInt(0, sizeof(g_Incoming) - 1)]);
		return true;
	}
	if(StrContains(sample, "cloakedspy", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Spy[GetRandomInt(0, sizeof(g_Spy) - 1)]);
		return true;
	}
	if(StrContains(sample, "positive", false) != -1 || StrContains(sample, "laughshort", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Positive[GetRandomInt(0, sizeof(g_Positive) - 1)]);
		return true;
	}
	if(StrContains(sample, "cheers", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Cheers[GetRandomInt(0, sizeof(g_Cheers) - 1)]);
		return true;
	}
	if(StrContains(sample, "battlecry", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Battlecry[GetRandomInt(0, sizeof(g_Battlecry) - 1)]);
		return true;
	}
	if(StrContains(sample, "painsevere", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)]);
		return true;
	}
	if(StrContains(sample, "painsharp", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)]);
		return true;
	}
	if(StrContains(sample, "paincrticialdeath", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_DeathSound[GetRandomInt(0, sizeof(g_DeathSound) - 1)]);
		return true;
	}
	if(StrContains(sample, "niceshot", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_NiceShot[GetRandomInt(0, sizeof(g_NiceShot) - 1)]);
		return true;
	}
	if(StrContains(sample, "goodjob", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_GoodJob[GetRandomInt(0, sizeof(g_GoodJob) - 1)]);
		return true;
	}
	if(StrContains(sample, "go", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_GoGoGo[GetRandomInt(0, sizeof(g_GoGoGo) - 1)]);
		return true;
	}
	if(StrContains(sample, "yes", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Yes[GetRandomInt(0, sizeof(g_Yes) - 1)]);
		return true;
	}
	if(StrContains(sample, "no", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_No[GetRandomInt(0, sizeof(g_No) - 1)]);
		return true;
	}
	return false;
}
void BarneySoundOverrideMapStart()
{
	PrecacheSoundArray(g_Yes);
	PrecacheSoundArray(g_Help);
	PrecacheSoundArray(g_Jeers);
	PrecacheSoundArray(g_Neagtive);
	PrecacheSoundArray(g_GoGoGo);
	PrecacheSoundArray(g_Incoming);
	PrecacheSoundArray(g_Spy);
	PrecacheSoundArray(g_Positive);
	PrecacheSoundArray(g_Cheers);
	PrecacheSoundArray(g_Battlecry);
	PrecacheSoundArray(g_No);
	PrecacheSoundArray(g_DeathSound);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_Thanks);
	PrecacheSoundArray(g_NiceShot);
	PrecacheSoundArray(g_GoodJob);
}