
static const char g_Yes[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/rodgerthat.wav",
};
static const char g_No[][] = {
	"npc/metropolice/vo/nocontact.wav",
	"npc/metropolice/vo/noncitizen.wav",
};
static const char g_Help[][] = {
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/officerneedsassistance.wav",
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/backmeupimout.wav",
	"npc/metropolice/vo/getdown.wav",
};

static const char g_GoGoGo[][] = {
	"npc/metropolice/vo/move.wav",
	"npc/metropolice/vo/movealong.wav",
	"npc/metropolice/vo/movealong3.wav",
	"npc/metropolice/vo/moveit.wav",
	"npc/metropolice/vo/moveit2.wav",
};
static const char g_Neagtive[][] =
{
	"npc/metropolice/vo/loyaltycheckfailure.wav",
	"npc/metropolice/vo/youwantamalcomplianceverdict.wav",
	"npc/metropolice/vo/shit.wav"
};

static const char g_Positive[][] =
{
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/one.wav",
	"npc/metropolice/vo/two.wav",
	"npc/metropolice/vo/three.wav",
	"npc/metropolice/vo/four.wav",
	"npc/metropolice/vo/five.wav",
	"npc/metropolice/vo/six.wav",
	"npc/metropolice/vo/seven.wav",
	"npc/metropolice/vo/eight.wav",
	"npc/metropolice/vo/nine.wav",
	"npc/metropolice/vo/ten.wav",
	"npc/metropolice/vo/eleven.wav",
	"npc/metropolice/vo/twelve.wav",
};

static const char g_Jeers[][] =
{
	"npc/metropolice/vo/putitinthetrash1.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/vo/getoutofhere.wav",
};
static const char g_Cheers[][] =
{
	"npc/metropolice/vo/isaidmovealong.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/wearesociostablethislocation.wav"
};

static const char g_Spy[][] =
{
	"npc/metropolice/vo/bugs.wav",
	"npc/metropolice/vo/bugsontheloose.wav"
};

static const char g_Incoming[][] =
{
	"npc/metropolice/vo/getdown.wav",
	"npc/metropolice/vo/lookout.wav"
};
static const char g_Battlecry[][] =
{
	"npc/metropolice/vo/readytoprosecutefinalwarning.wav",
	"npc/metropolice/vo/readytoprosecute.wav",
	"npc/metropolice/vo/freenecrotics.wav",
};

bool TeutonSoundOverride(int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, int &seed)
{
	if(StrContains(sample, "demoman_negative", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Neagtive[GetRandomInt(0, sizeof(g_Neagtive) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_go", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_GoGoGo[GetRandomInt(0, sizeof(g_GoGoGo) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_yes", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Yes[GetRandomInt(0, sizeof(g_Yes) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_no", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_No[GetRandomInt(0, sizeof(g_No) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_jeers", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Jeers[GetRandomInt(0, sizeof(g_Jeers) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_help", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Help[GetRandomInt(0, sizeof(g_Help) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_incomming", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Incoming[GetRandomInt(0, sizeof(g_Incoming) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_cloakedspy", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Spy[GetRandomInt(0, sizeof(g_Spy) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_positive", false) != -1 || StrContains(sample, "demoman_laughshort", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Positive[GetRandomInt(0, sizeof(g_Positive) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_cheers", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Cheers[GetRandomInt(0, sizeof(g_Cheers) - 1)]);
		return true;
	}
	if(StrContains(sample, "demoman_battlecry", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Battlecry[GetRandomInt(0, sizeof(g_Battlecry) - 1)]);
		return true;
	}
	return false;
}
void TeutonSoundOverrideMapStart()
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
}