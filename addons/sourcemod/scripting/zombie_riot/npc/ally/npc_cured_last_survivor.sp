#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"vo/ravenholm/monk_death07.wav",
};

static char g_HurtSounds[][] = {
	"vo/ravenholm/monk_pain01.wav",
	"vo/ravenholm/monk_pain02.wav",
	"vo/ravenholm/monk_pain03.wav",
	"vo/ravenholm/monk_pain04.wav",
	"vo/ravenholm/monk_pain05.wav",
	"vo/ravenholm/monk_pain06.wav",
	"vo/ravenholm/monk_pain07.wav",
	"vo/ravenholm/monk_pain08.wav",
	"vo/ravenholm/monk_pain09.wav",
	"vo/ravenholm/monk_pain10.wav",
	"vo/ravenholm/monk_pain12.wav",
};

static char g_IdleSounds[][] = {
	"vo/ravenholm/monk_kill01.wav",
	"vo/ravenholm/monk_kill02.wav",
	"vo/ravenholm/monk_kill03.wav",
	"vo/ravenholm/monk_kill04.wav",
	"vo/ravenholm/monk_kill05.wav",
	"vo/ravenholm/monk_kill06.wav",
	"vo/ravenholm/monk_kill07.wav",
	"vo/ravenholm/monk_kill08.wav",
	"vo/ravenholm/monk_kill09.wav",
	"vo/ravenholm/monk_kill10.wav",
	"vo/ravenholm/monk_kill11.wav",
	
};

static char g_IdleAlertedSounds[][] = {
	"vo/ravenholm/monk_rant01.wav",
	"vo/ravenholm/monk_rant02.wav",
	"vo/ravenholm/monk_rant04.wav",
	"vo/ravenholm/monk_rant05.wav",
	"vo/ravenholm/monk_rant06.wav",
	"vo/ravenholm/monk_rant07.wav",
	"vo/ravenholm/monk_rant08.wav",
	"vo/ravenholm/monk_rant09.wav",
	"vo/ravenholm/monk_rant10.wav",
	"vo/ravenholm/monk_rant11.wav",
	"vo/ravenholm/monk_rant12.wav",
	"vo/ravenholm/monk_rant13.wav",
	"vo/ravenholm/monk_rant14.wav",
	"vo/ravenholm/monk_rant15.wav",
	"vo/ravenholm/monk_rant16.wav",
	"vo/ravenholm/monk_rant17.wav",
	"vo/ravenholm/monk_rant19.wav",
	"vo/ravenholm/monk_rant20.wav",
	"vo/ravenholm/monk_rant21.wav",
	"vo/ravenholm/monk_rant22.wav",
	"vo/ravenholm/yard_shepherd.wav",
	"vo/ravenholm/yard_suspect.wav",
	"vo/ravenholm/shotgun_stirreduphell.wav",
	"vo/ravenholm/shotgun_theycome.wav",
	"vo/ravenholm/wrongside_seekchurch.wav",
	"vo/ravenholm/wrongside_town.wav",
	"vo/ravenholm/pyre_keepeye.wav",
	"vo/ravenholm/pyre_anotherlife.wav",
	"vo/ravenholm/madlaugh01.wav",
	"vo/ravenholm/madlaugh02.wav",
	"vo/ravenholm/madlaugh03.wav",
	"vo/ravenholm/madlaugh04.wav",
	"vo/ravenholm/grave_stayclose.wav",
	"vo/ravenholm/grave_follow.wav",
	"vo/ravenholm/attic_apologize.wav",
	"vo/ravenholm/aimforhead.wav",
	"vo/ravenholm/bucket_guardwell.wav",
	"vo/ravenholm/cartrap_iamgrig.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/vort/foot_hit.wav",
};
static char g_MeleeAttackSounds[][] = {
	"vo/ravenholm/monk_blocked01.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/shotgun/shotgun_fire6.wav",
	"weapons/shotgun/shotgun_fire7.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	"vo/ravenholm/monk_helpme01.wav",
	"vo/ravenholm/monk_helpme02.wav",
	"vo/ravenholm/monk_helpme03.wav",
	"vo/ravenholm/monk_helpme04.wav",
	"vo/ravenholm/monk_helpme05.wav",
};

static char g_PullSounds[][] = {
	"vo/ravenholm/monk_mourn02.wav",
	"vo/ravenholm/monk_mourn03.wav",
};


static char g_RangedReloadSound[][] = {
	"weapons/shotgun/shotgun_reload1.wav",
};

static char g_SadDueToAllyDeath[][] = {
	"vo/ravenholm/monk_mourn01.wav",
	"vo/ravenholm/monk_mourn02.wav",
	"vo/ravenholm/monk_mourn03.wav",
	"vo/ravenholm/monk_mourn04.wav",
	"vo/ravenholm/monk_mourn05.wav",
	"vo/ravenholm/monk_mourn06.wav",
	"vo/ravenholm/monk_mourn07.wav",
};

static char g_KilledEnemy[][] = {
	"vo/ravenholm/monk_kill01.wav",
	"vo/ravenholm/monk_kill02.wav",
	"vo/ravenholm/monk_kill03.wav",
	"vo/ravenholm/monk_kill04.wav",
	"vo/ravenholm/monk_kill05.wav",
	"vo/ravenholm/monk_kill06.wav",
	"vo/ravenholm/monk_kill07.wav",
	"vo/ravenholm/monk_kill08.wav",
	"vo/ravenholm/monk_kill09.wav",
	"vo/ravenholm/monk_kill10.wav",
	"vo/ravenholm/monk_kill11.wav",
};

static int NPCId;
#define GREGPOINTS_REV_NEEDED 40

public void CuredFatherGrigori_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_SadDueToAllyDeath));   i++) { PrecacheSound(g_SadDueToAllyDeath[i]);   }
	for (int i = 0; i < (sizeof(g_KilledEnemy));   i++) { PrecacheSound(g_KilledEnemy[i]);   }
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/explode_9.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Cured Father Grigori");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cured_last_survivor");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int CuredFatherGrigori_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CuredFatherGrigori(vecPos, vecAng, team);
}

static bool BoughtGregHelp;

methodmap CuredFatherGrigori < CClotBody
{
	
	property float m_flCustomAnimDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flVerySadCry
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		Citizen_LiveCitizenReaction(this.index);	
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(48.0, 60.0);
	}
	
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0, 0.0, 80.0}, endingtextscroll);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		Citizen_LiveCitizenReaction(this.index);
		
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		else
		{
			switch(GetURandomInt() % 68)
			{
				case 0:
				{
					this.Speech("Hey Niko, how come you are here?");
				}
				case 1:
				{
					this.Speech("It feels like i somehow became real, doesnt feel real.");
				}
				case 2:
				{
					this.Speech("Why are you with these men here niko?");
				}
				case 3:
				{
					this.Speech("This feels way too dangerous, you should leave.");
				}
				case 4:
				{
					this.Speech("I wonder where you left the sun, you dont seem to talk much anymore.");
				}
				case 5:
				{
					this.Speech("Quack? Im not a duck. Oh you mean 'meow'", "...");
				}
				case 6:
				{
					this.Speech("Why do they treat me like im Niko?");
				}
				case 7:
				{
					this.Speech("I can give discounts, i cant alter too much.");
				}
				case 8:
				{
					this.Speech("Where i come from? Im not sure how i came here.");
				}
				case 9:
				{
					this.Speech("Ex-Pi what? Im not whatever that is.");
				}
				case 10:
				{
					this.Speech("I need a drink, oh wait i cant have one.");
				}
				case 11:
				{
					this.Speech("These enemies, i sometimes feel like they arent enemies.");
				}
				case 12:
				{
					this.Speech("What if we are the bad guys? Nah.");
				}
				case 13:
				{
					this.Speech("It feels very wrong that everything is actually real this time.");
				}
				case 14:
				{
					this.Speech("Break the 4th wall? This is the real world this time.");
				}
				case 15:
				{
					this.Speech("As a machine, i can only do so much..");
				}
				case 16:
				{
					this.Speech("You ever wonder how these weapons reach you? Me too.");
				}
				case 17:
				{
					this.Speech("Sometimes, i think about cheese, oh wait, wrong line.");
				}
				case 18:
				{
					this.Speech("Aha! Its barney!");
				}
				case 19:
				{
					this.Speech("I like Niko the most.");
				}
				case 20:
				{
					this.Speech("I dislike water on my face.");
				}
				case 21:
				{
					this.Speech("Your back hurts? Stop your bad posture!");
				}
				case 22:
				{
					this.Speech("I talk as much as who?");
				}
				case 23:
				{
					this.Speech("I dont know this world, i came from another, dont ask me too much.");
				}
				case 24:
				{
					this.Speech("Waaaah! I worry, do we have to fight?");
				}
				case 25:
				{
					this.Speech("hm","...");
				}
				case 26:
				{
					this.Speech("What do you mean im niko? Im litterally not.");
				}
				case 27:
				{
					this.Speech("Not touching me, or else i will slap your hand away from me.");
				}
				case 28:
				{
					this.Speech("Incase you need help, talk to me.");
				}
				case 29:
				{
					this.Speech("Its weird that only niko was the real one in that world.");
				}
				case 30:
				{
					this.Speech("Since... when can niko use such weapons???");
				}
				case 31:
				{
					this.Speech("BOO!");
					this.AddGesture("ACT_GMOD_GESTURE_TAUNT_ZOMBIE"); //lol no caps
				}
				case 32:
				{
					this.Speech("You think im annoying? Ok bye.");
				}
				case 33:
				{
					this.Speech("This is a test message, if you see this, Dont report it! Gotcha!");
				}
				case 34:
				{
					this.Speech("What is your favorite OS you say? well, whats your favorite country?");
				}
				case 35:
				{
					this.Speech("Do you feel scared? Me too, for different reasons, probably.");
				}
				case 36:
				{
					this.Speech("Blah blah blah blah.");
				}
				case 37:
				{
					this.Speech("*Scratches self*");
					this.AddGesture("ACT_GMOD_GESTURE_WAVE"); //lol no caps
				}
				case 38:
				{
					this.Speech("Cheeck out my moves!");
					switch(GetURandomInt() % 2)
					{
						case 0:
						{
							int iActivity = this.LookupActivity("ACT_GMOD_TAUNT_DANCE");
							if(iActivity > 0) this.StartActivity(iActivity);
							this.m_bisWalking = false;
							this.m_iChanged_WalkCycle = 999;
							this.StopPathing();
							this.m_flCustomAnimDo = GetGameTime(this.index) + 6.0;
						}
						case 1:
						{
							int iActivity = this.LookupActivity("ACT_GMOD_TAUNT_ROBOT");
							if(iActivity > 0) this.StartActivity(iActivity);
							this.m_bisWalking = false;
							this.m_iChanged_WalkCycle = 999;
							this.StopPathing();
							this.m_flCustomAnimDo = GetGameTime(this.index) + 6.0;
						}
					}
				}
				case 39:
				{
					this.Speech("gnwes nghwfdhbdfhedbrvapifsdf");
				}
				case 40:
				{
					this.Speech("Im not a cat, i didnt think of that.");
				}
				case 41:
				{
					this.Speech("Why im like a hologram? Dunno.");
				}
				case 42:
				{
					this.Speech("Wish i had a remote to turn you off sometimes.");
				}
				case 43:
				{
					this.Speech("So mean.");
				}
				case 44:
				{
					this.Speech("Look i can type in chat too. hold on.","...");
					CreateTimer(4.5, Timer_TypeInChat);
				}
				case 45:
				{
					this.Speech("Stop asking me what 'tame' means Niko.");
				}
				case 46:
				{
					this.Speech(":steamhappy:");
				}
				case 47:
				{
					this.Speech("I cant build paps.");
				}
				case 48:
				{
					this.Speech("I wont be your builder.");
				}
				case 49:
				{
					this.Speech("If i give bigger discounts, i might get sm_perished!");
				}
				case 50:
				{
					this.Speech("My original Creator has abandoned me a long time ago", "...");
				}
				case 51:
				{
					this.Speech("What does 'Sigma' mean? Why are you so obssesed with it?");
				}
				case 52:
				{
					this.Speech("Who is this chat youre reffering to? Nah just kidding i can see it.");
				}
				case 53:
				{
					this.Speech("Wanna hear a joke?\nType ''quit smoking'' in console!");
				}
				case 54:
				{
					this.Speech("I hope to see you soon again when we part ways!");
				}
				case 55:
				{
					this.Speech("My eye is missing? No thats just you.");
				}
				case 56:
				{
					this.Speech("''zombie_riot/npc/ally/npc_cured_last_survivor.sp''\nIs where i reside, with someone else.");
				}
				case 57:
				{
					this.Speech("You want a free virus?\nwww.freevirus.com");
				}
				case 58:
				{
					this.Speech("You wanna know what my first words were?\nHELLO WORLD!");
				}
				case 59:
				{
					this.Speech("[print]Goodbye World[/print]");
				}
				case 60:
				{
					this.Speech("I know what you are.\nNot me!");
				}
				case 61:
				{
					this.Speech("You have some weird files\nMinecraft? Ew.");
				}
				case 62:
				{
					this.Speech("I\nDont\nLike\nPeople\nWho\nWrite\nLike\nThis.");
				}
				case 63:
				{
					this.Speech("I wish you best of luck.");
					this.AddGesture("ACT_GMOD_GESTURE_BOW"); //lol no caps
				}
				case 64:
				{
					this.Speech("Ah you want the Boomstick on sale?\nToo bad!");
					this.AddGesture("ACT_GMOD_GESTURE_DISAGREE"); //lol no caps
				}
				case 65:
				{
					this.Speech("My eyes are itchy.");
					this.AddGesture("ACT_GMOD_GESTURE_BECON"); //lol no caps
				}
				case 66:
				{
					this.Speech("Its never the end\nIts never the end\nIts never the end\nIts never the end\nIts never the end\nIts never the end");
				}
				case 67:
				{
					this.Speech("Im not in your walls.");
				}
				case 68:
				{
					this.Speech("yaur kompoutar haz wairus.");
				}
				case 69:
				{
					this.Speech("My connection is slow.");
				}
				case 70:
				{
					this.Speech("Please dont smoke near me.\nSmoking is bad.");
				}
				case 71:
				{
					this.Speech("If you drink beer or whatever, dont talk to me while drunk.");
				}
			}
		}
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 38.0);
		

	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		

	}
	
	public void PlayDeathSound() {
	
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, 90, _, 1.0);
		
	}
	
	public void PlayMeleeSound() {
	//	if (GetRandomInt(0, 5) == 2)
		{
			if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
			
		}
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, 95, _, 1.0);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, 95, _, 1.0);
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 90, _, 1.0);
		
	}
	
	public void PlayKilledEnemy() {
		
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_KilledEnemy[GetRandomInt(0, sizeof(g_KilledEnemy) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		else
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
				{
					this.Speech("Gotta do something atleast.");
				}
				case 1:
				{
					this.Speech("Dont touch niko!");
				}
				case 2:
				{
					this.Speech("Evil Beings!");
				}
				case 3:
				{
					this.Speech("Begone!");
				}
			}
		}
		this.m_flNextIdleSound += 2.0;

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
	}
	public void PlaySadMourn() {
		if(i_SpecialGrigoriReplace == 0)
			EmitSoundToAll(g_SadDueToAllyDeath[GetRandomInt(0, sizeof(g_SadDueToAllyDeath) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		else
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
				{
					this.Speech("I tried what i could...");
				}
				case 1:
				{
					this.Speech("I cant intefeer too much...");
				}
				case 2:
				{
					this.Speech("You can come back, right?");
				}
				case 3:
				{
					this.Speech("This isnt real, dont worry...! R-Right?");
				}
			}
		}
		
		this.m_flNextIdleSound += 2.0;
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
		
	}
	property float m_MakeGrigoriGlow
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
	}
	
	public CuredFatherGrigori(float vecPos[3], float vecAng[3], int ally)
	{
		i_SpecialGrigoriReplace = 0;

		if(ForceNiko)
			i_SpecialGrigoriReplace = 2;
		else
		{
			int ThereIsANiko = 0;
			int TotalPlayers = 0;
			
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && GetTeam(client) == TFTeam_Red && TeutonType[client] != TEUTON_WAITING)
				{
					if(i_PlayerModelOverrideIndexWearable[client] == NIKO_2)
						ThereIsANiko++;

					TotalPlayers++;
				}
			}
			if(GetRandomFloat(0.0,1.0) < (ThereIsANiko / TotalPlayers))
				i_SpecialGrigoriReplace = 2;
		}

		char ModelDo[256];
		char SizeDo[256];

		if(i_SpecialGrigoriReplace == 0)
			FormatEx(ModelDo, sizeof(ModelDo), "models/monk.mdl");
		else
			FormatEx(ModelDo, sizeof(ModelDo), "models/sasamin/oneshot/zombie_riot_edit/niko_05.mdl");
			
		if(i_SpecialGrigoriReplace == 0)
			FormatEx(SizeDo, sizeof(SizeDo), "1.15");
		else
			FormatEx(SizeDo, sizeof(SizeDo), "1.0");
	
		CuredFatherGrigori npc = view_as<CuredFatherGrigori>(CClotBody(vecPos, vecAng, ModelDo, SizeDo, "10000", ally, true, false));
		
		if(i_SpecialGrigoriReplace == 2)
		{
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "The World Machine");
			b_NameNoTranslation[npc.index] = true;
		}

		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		if(i_SpecialGrigoriReplace == 0)
		{
			int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_flSpeed = 250.0;
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_flSpeed = 300.0;
		}
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		func_NPCDeath[npc.index] = CuredFatherGrigori_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CuredFatherGrigori_OnTakeDamage;
		func_NPCThink[npc.index] = CuredFatherGrigori_ClotThink;
		func_NPCFuncWin[npc.index] = view_as<Function>(NikoCryThingLoose);
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flNextMeleeAttack = 0.0;
					
		//IDLE
		npc.m_bThisEntityIgnored = true;
		npc.m_iState = 0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedBarrage_Spam = 0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
		npc.m_bNextRangedBarrage_OnGoing = false;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		npc.m_iAttacksTillReload = 2;
		npc.m_bWasSadAlready = false;
		npc.Anger = false;
		npc.m_bScalesWithWaves = true;
		npc.StartPathing();
		npc.m_flNextRangedSpecialAttack = 0.0;
		
		
		if(i_SpecialGrigoriReplace == 0)
		{
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_annabelle.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		else
		{
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", WEAPON_CUSTOM_WEAPONRY_1);
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetVariantInt(16);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			
			npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			npc.m_bTeamGlowDefault = false;
			SetVariantColor(view_as<int>({150, 0, 150, 255}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		}
		if(i_SpecialGrigoriReplace == 2)
		{
			SetEntityRenderFx(npc.index, RENDERFX_HOLOGRAM);
			SetEntityRenderColor(npc.index, 150, 0, 150, 255);
		}
		
		npc.m_flAttackHappenswillhappen = false;
		BoughtGregHelp = false;
		
		return npc;
	}
}

public void NikoCryThingLoose(int entity)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(entity);
	func_NPCFuncWin[entity] = INVALID_FUNCTION;
	npc.m_flVerySadCry = 1.0;
}

public void CuredFatherGrigori_ClotThink(int iNPC)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(npc.m_flVerySadCry)
	{
		if(npc.m_flVerySadCry < GetGameTime(npc.index))
		{
			int iActivity = npc.LookupActivity("ACT_HL2MP_IDLE_COWER");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 999;
			npc.StopPathing();
			
			npc.m_flCustomAnimDo = GetGameTime(npc.index) + 10.0;
			npc.m_flNextIdleSound = GetGameTime(npc.index) + GetRandomFloat(50.0, 50.0);
			npc.Speech("N-No...");
		}
	}
	if(npc.m_flCustomAnimDo)
	{
		if(npc.m_flCustomAnimDo < GetGameTime(npc.index))
		{
			npc.m_flCustomAnimDo = 0.0;
		}
		return;
	}
	if(IsValidEntity(npc.m_iTeamGlow))
	{
		if(Waves_InSetup())
		{
			if(npc.m_MakeGrigoriGlow != 3.0)
			{
				npc.m_MakeGrigoriGlow = 3.0;
				SetVariantColor(view_as<int>({255, 255, 255, 255}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			}
		}
		else
		{
			if(npc.m_MakeGrigoriGlow != 2.0)
			{
				npc.m_MakeGrigoriGlow = 2.0;
				if(i_SpecialGrigoriReplace == 2)
					SetVariantColor(view_as<int>({150, 0, 150, 255}));
				else
					SetVariantColor(view_as<int>({150, 0, 0, 255}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			}
		}
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	if(BoughtGregHelp || CurrentPlayers <= 4)
	{
		if(i_SpecialGrigoriReplace == 2 && IsValidEntity(npc.m_iWearable1) && !npc.Anger)
		{
			npc.Anger = true;
			AcceptEntityInput(npc.m_iWearable1, "Enable");
		}
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		}
	}
	else
	{
		if(i_SpecialGrigoriReplace == 2 && IsValidEntity(npc.m_iWearable1) && npc.Anger)
		{
			npc.Anger = false;
			AcceptEntityInput(npc.m_iWearable1, "Disable");
		}
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(npc.m_flReloadDelay > GetGameTime(npc.index))
	{
		npc.m_iChanged_WalkCycle = 999;
		npc.m_flSpeed = 0.0;
		return;
	}
	
	if(!npc.m_iTargetWalkTo)
	{
		npc.m_iTargetWalkTo = GetClosestAllyPlayerGreg(npc.index);
	}
	
	if(npc.m_iTargetWalkTo > 0)
	{
		if (GetTeam(npc.m_iTargetWalkTo)==GetTeam(npc.index) && 
		b_BobsCuringHand_Revived[npc.m_iTargetWalkTo] >= GREGPOINTS_REV_NEEDED &&
		 TeutonType[npc.m_iTargetWalkTo] == TEUTON_NONE &&
		  dieingstate[npc.m_iTargetWalkTo] > 0 && 
		  !b_LeftForDead[npc.m_iTargetWalkTo])
		{
			//walk to client.
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < (70.0*70.0))
			{
				//slowly revive
				ReviveClientFromOrToEntity(npc.m_iTargetWalkTo, npc.index, 1);
				if(npc.m_flNextRangedSpecialAttack && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
				{
					npc.m_flNextRangedSpecialAttack = 0.0;
					npc.SetPlaybackRate(0.0);	
				}
				if(npc.m_iChanged_WalkCycle != 11) 	
				{
					npc.StopPathing();
					
					npc.AddActivityViaSequence("Open_door_towards_right");
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 0.7;
					npc.m_iChanged_WalkCycle = 11;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					//forgot to add walk.
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 250.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUM");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
					}
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					//forgot to add walk.
				}
				npc.SetGoalEntity(npc.m_iTargetWalkTo);
				npc.StartPathing();
			}
		}
		else
		{
			npc.m_iTargetWalkTo = 0;
		}
		return;
	}
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
						
	if((BoughtGregHelp || CurrentPlayers <= 4) && IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		} else {
			npc.SetGoalEntity(PrimaryThreatIndex);
		}

		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 15000 && flDistanceToTarget < 1000000 && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			int Enemy_I_See;
		
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			
			
			if(!IsValidEnemy(npc.index, Enemy_I_See))
			{
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 150.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 200.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_WALK");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 200.0;
						}
					}
					npc.m_iChanged_WalkCycle = 4;
					npc.m_bisWalking = true;
				}
				npc.StartPathing();
				
			}
			else
			{
				
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_RUN");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
					}
					npc.m_iChanged_WalkCycle = 5;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 0.0;
				}
				if (npc.m_iAttacksTillReload == 0)
				{
					if(i_SpecialGrigoriReplace == 0)
						npc.AddGesture("ACT_RELOAD_shotgun"); //lol no caps
					else
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY_PRIMARY3", .SetGestureSpeed = 0.35); //lol no caps
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
					npc.m_iAttacksTillReload = 2;
					npc.PlayRangedReloadSound();
					return; //bye
				}
				
				npc.StopPathing();
				
				
				npc.FaceTowards(vecTarget, 10000.0);
				
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.2;
				
				float vecSpread = 0.1;
			
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				
				float x, y;
			//	x = GetRandomFloat( -0.0, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			//	y = GetRandomFloat( -0.0, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
				MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				npc.m_iAttacksTillReload -= 1;
				
				if(i_SpecialGrigoriReplace == 0)
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");
				else
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");

				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				float DamageDelt = 50.0;
				if(BoughtGregHelp && CurrentPlayers <= 4)
				{
					DamageDelt = 75.0;
				}
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, DamageDelt, 9000.0, DMG_BULLET, "bullet_tracer01_red", Owner , _ , "0");

				npc.PlayRangedSound();
				
				if(GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth") < 0)
				{
					npc.PlayKilledEnemy();
				}
			}
		}
		
				
		//Target close enough to hit
		if((flDistanceToTarget < 15000 && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
		{
			npc.StartPathing();
				//Walk at all times when they are close enough.
				
			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				if(i_SpecialGrigoriReplace == 0)
				{
					int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_flSpeed = 250.0;
				}
				else
				{
					if(BoughtGregHelp || CurrentPlayers <= 4)
					{
						int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 200.0;
					}
					else
					{
						int iActivity = npc.LookupActivity("ACT_HL2MP_RUN");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 200.0;
					}
				}
				npc.m_iChanged_WalkCycle = 2;
				npc.m_bisWalking = true;
				//forgot to add walk.
			}
			
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
				{
					npc.m_flSpeed = 0.0;
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.5;
						npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.5;
						if(i_SpecialGrigoriReplace == 0)
							npc.AddGesture("ACT_MELEE_ATTACK");
						else
							npc.AddGesture("ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND", .SetGestureSpeed = 0.6);

						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,2))
						{
								
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								float DamageDelt = 85.0;
								if(BoughtGregHelp && CurrentPlayers <= 4)
								{
									DamageDelt = 100.0;
								}
								SDKHooks_TakeDamage(target, npc.index, Owner, DamageDelt, DMG_CLUB, -1, _, vecHit);
								
								// Hit particle
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
								if(GetEntProp(target, Prop_Data, "m_iHealth") < 0)
								{
									npc.PlayKilledEnemy();
								}
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}
	}
	else
	{
		if(BoughtGregHelp || CurrentPlayers <= 4)
		{
			if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
			{
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
				npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					return;
				}	
			}
		}
		if(!npc.m_bGetClosestTargetTimeAlly)
		{
			npc.m_iTargetAlly = GetClosestAllyPlayer(npc.index);
			npc.m_bGetClosestTargetTimeAlly = true; //Yeah he just picks one.
			npc.m_iChanged_WalkCycle = -1; //Reset
		}
		
		if(IsValidAllyPlayer(npc.index, npc.m_iTargetAlly))
		{
			if(i_SpecialGrigoriReplace == 2)
			{
				if(npc.m_iTargetAlly > 0)
				{
					float WorldSpaceVec2[3]; WorldSpaceCenter(npc.m_iTargetAlly, WorldSpaceVec2);
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					
					float flDistanceToTarget = GetVectorDistance(WorldSpaceVec2, WorldSpaceVec, true);
					if(flDistanceToTarget < (200.0*200.0))
					{
						npc.FaceTowards(WorldSpaceVec2, 500.0);
						WorldSpaceVec2[2] += 30.0;
						int iPitch = npc.LookupPoseParameter("body_pitch");
						if(iPitch >= 0)
						{
							//Body pitch
							float v[3], ang[3];
							SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
							NormalizeVector(v, v);
							GetVectorAngles(v, ang); 
							
							float flPitch = npc.GetPoseParameter(iPitch);
							
						//	ang[0] = clamp(ang[0], -44.0, 89.0);
							npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
						}
					
					}
				}
			}
			npc.m_bWasSadAlready = false;
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget > 250000) //500 units
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 250.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_RUN");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 300.0;
						}
					}
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					npc.StartPathing();
					
				}
				npc.SetGoalEntity(npc.m_iTargetAlly);	
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);		
				
			}
			else if(flDistanceToTarget > 90000 && flDistanceToTarget < 250000) //300 units
			{
				if(npc.m_iChanged_WalkCycle != 1) 	
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_WALK_AR2_RELAXED");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_flSpeed = 125.0;
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_WALK");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
					}
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = true;
					npc.StartPathing();
					
				}
				npc.SetGoalEntity(npc.m_iTargetAlly);	
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);		
				
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 0) 	//Just copypaste this and alter the id for any and all activities. Standing idle for example is 0.
													//Just alter both id's and add a new walk cylce if you wish to change it, found out that this is the easiest way to do it.
				{
					if(i_SpecialGrigoriReplace == 0)
					{
						int iActivity = npc.LookupActivity("ACT_MONK_GUN_IDLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
					}
					else
					{
						if(BoughtGregHelp || CurrentPlayers <= 4)
						{
							int iActivity = npc.LookupActivity("ACT_MP_STAND_PRIMARY");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
						else
						{
							int iActivity = npc.LookupActivity("ACT_HL2MP_WALK");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_flSpeed = 175.0;
						}
					}
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
					
				}
				if (npc.m_iAttacksTillReload != 2)
				{
					if(i_SpecialGrigoriReplace == 0)
						npc.AddGesture("ACT_RELOAD_shotgun"); //lol no caps
					else
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY_PRIMARY3", .SetGestureSpeed = 0.35); //lol no caps
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
					npc.m_iAttacksTillReload = 2;
					npc.PlayRangedReloadSound();
				}
				//Stand still.
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
			}
		}
		else
		{
			if(!npc.m_bWasSadAlready)
			{
				npc.PlaySadMourn();
				npc.m_bWasSadAlready = true;
			}
			npc.m_bGetClosestTargetTimeAlly = false;
			npc.StopPathing();
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
		}
	}
	npc.PlayIdleAlertSound();
}

public Action CuredFatherGrigori_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (damage < 9999999.0)	//So they can be slayed.
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public void CuredFatherGrigori_NPCDeath(int entity)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(entity);
//	npc.PlayDeathSound(); He cant die.
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

int GetClosestAllyPlayerGreg(int entity)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if (IsValidClient(i))
		{
			if (GetTeam(i) == GetTeam(entity) /*&& b_BobsCuringHand[i] */&& b_BobsCuringHand_Revived[i] >= GREGPOINTS_REV_NEEDED && TeutonType[i] == TEUTON_NONE && dieingstate[i] > 0 && !b_LeftForDead[i]) //&& CheckForSee(i)) we dont even use this rn and probably never will.
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetClientAbsOrigin( i, TargetLocation ); 
				
				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						ClosestTarget = i; 
						TargetDistance = distance;		  
					}
				} 
				else 
				{
					ClosestTarget = i; 
					TargetDistance = distance;
				}					
			}
		}
	}
	return ClosestTarget; 
}

public void OnBuy_BuffGreg(int client)
{
	int greg = EntRefToEntIndex(SalesmanAlive);
	BoughtGregHelp = true;
	if(greg > 0)
	{
		SetEntPropEnt(greg, Prop_Send, "m_hOwnerEntity",client);
	}
	
	CancelClientMenu(client, true);
}


public Action Timer_TypeInChat(Handle timer)
{
	CPrintToChatAll("{purple}The World Machine{default}: See, I can type too! Hello chat!");
	return Plugin_Stop;
}
