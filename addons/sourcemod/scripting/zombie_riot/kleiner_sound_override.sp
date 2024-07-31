
static const char g_Yes[][] = {
	"vo/novaprospekt/kl_yesalyx.wav",
};
static const char g_No[][] = {
	"vo/k_lab/kl_hedyno03.wav",
};
static const char g_DeathSound[][] = {
	"vo/k_lab/kl_ahhhh.wav",
};
static const char g_Help[][] = {
	"vo/k_lab/kl_thenwhere.wav",
};

static const char g_GoGoGo[][] = {
	"vo/k_lab/kl_gordongo.wav",
	"vo/k_lab/kl_getoutrun03.wav"
};
static const char g_Neagtive[][] =
{
	"vo/k_lab/kl_nocareful.wav",
};

static const char g_Positive[][] =
{
	"vo/k_lab/kl_hedyno01.wav",
	"vo/k_lab2/kl_greatscott.wav",
	"vo/k_lab2/kl_givenuphope.wav",
	"vo/k_lab/kl_moduli02.wav",
};

static const char g_Jeers[][] =
{
	"vo/k_lab/kl_fiddlesticks.wav",
	"vo/k_lab/kl_whatisit.wav",
	"vo/k_lab/kl_ohdear.wav",
	"vo/k_lab/kl_coaxherout.wav",
};
static const char g_Cheers[][] =
{
	"vo/k_lab/kl_nonsense.wav",
};

static const char g_Spy[][] =
{
	"vo/k_lab2/kl_nolongeralone.wav",
};

static const char g_Incoming[][] =
{
	"vo/k_lab/kl_heremypet01.wav",
};
static const char g_Battlecry[][] =
{
	"vo/k_lab/kl_interference.wav",
};

static const char g_HurtSound[][] =
{
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};

static const char g_Thanks[][] =
{
	"vo/k_lab/kl_weowe.wav",
};
static const char g_NiceShot[][] =
{
	"vo/k_lab/kl_barneysturn.wav",
};
static const char g_GoodJob[][] =
{
	"vo/k_lab/kl_barneyhonor.wav",
};
static const char g_DispenserCat[][] =
{
	"vo/k_lab/kl_islamarr.wav",
	"vo/k_lab/kl_lamarr.wav",
	"vo/k_lab2/kl_lamarr.wav",
	"vo/k_lab/kl_hedyno01.wav"
};

bool KleinerSoundOverride(int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, int &seed)
{
	if(StrContains(sample, "dispenser", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_DispenserCat[GetRandomInt(0, sizeof(g_DispenserCat) - 1)]);
		return true;
	}
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
void KleinerSoundOverrideMapStart()
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
	PrecacheSoundArray(g_DispenserCat);
}