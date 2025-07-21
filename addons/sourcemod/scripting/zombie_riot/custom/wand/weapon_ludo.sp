#pragma semicolon 1
#pragma newdecls required

#define DRAW_CARD_SOUND		"items/pumpkin_pickup.wav"
#define BLACKJACK_SOUND		"ui/mm_level_six_achieved.wav"
#define BLACKJACK_FAIL		"player/taunt_sorcery_fail.wav"
#define CARD_SHOOT		 	"player/taunt_heavy_upper_cut.wav"
#define CARD_BOOM			"misc/halloween/merasmus_hiding_explode.wav"

Handle Timer_Ludo_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};

static int BlackJack[MAXPLAYERS];
static int BlackjackCounter[MAXPLAYERS];
static int BlackjackCounterRandom[MAXPLAYERS]; 
static int CardCounter[MAXPLAYERS];
static int i_CardParticle[MAXPLAYERS];
static int i_Current_Pap[MAXPLAYERS+1];

static char CardParticle[MAXPLAYERS][48];

static char FirstCard[MAXPLAYERS][3];
static char SecondCard[MAXPLAYERS][3];
static char ThirdCard[MAXPLAYERS][3];
static char FourthCard[MAXPLAYERS][3];
static char FifthCard[MAXPLAYERS][3];
static char SixthCard[MAXPLAYERS][3];
static char SeventhCard[MAXPLAYERS][3];

static char FirstCardSymbol[MAXPLAYERS][3];
static char SecondCardSymbol[MAXPLAYERS][3];
static char ThirdCardSymbol[MAXPLAYERS][3];
static char FourthCardSymbol[MAXPLAYERS][3];
static char FifthCardSymbol[MAXPLAYERS][3];
static char SixthCardSymbol[MAXPLAYERS][3];
static char SeventhCardSymbol[MAXPLAYERS][3];

static int SpadeCounter[MAXPLAYERS];
static int DiamondCounter[MAXPLAYERS];
static bool HasClubs[MAXPLAYERS];

static float Ludo_hud_delay[MAXPLAYERS];

static bool AceReserve[MAXPLAYERS];
static bool SecondReserve[MAXPLAYERS];
static bool ThirdReserve[MAXPLAYERS];
static bool FourthReserve[MAXPLAYERS];
static bool FifthReserve[MAXPLAYERS];
static bool SixthReserve[MAXPLAYERS];
static bool SeventhReserve[MAXPLAYERS];
static bool EighthReserve[MAXPLAYERS];
static bool NinethReserve[MAXPLAYERS];
static bool TenthReserve[MAXPLAYERS];
static bool JackReserve[MAXPLAYERS];
static bool QueenReserve[MAXPLAYERS];
static bool KingReserve[MAXPLAYERS];

static int Second[MAXPLAYERS];
static int Third[MAXPLAYERS];
static int Fourth[MAXPLAYERS];
static int Fifth[MAXPLAYERS];
static int Sixth[MAXPLAYERS];
static int Seventh[MAXPLAYERS];
static int Eighth[MAXPLAYERS];
static int Nineth[MAXPLAYERS];
static int Tenth[MAXPLAYERS];
static int Jack[MAXPLAYERS];
static int Queen[MAXPLAYERS];
static int King[MAXPLAYERS];

static int SixthDebuff[MAXPLAYERS];
static int SeventhDebuff[MAXPLAYERS];
static int EighthDebuff[MAXPLAYERS];
static int NinethDebuff[MAXPLAYERS];
static int TenthDebuff[MAXPLAYERS];

static bool OverLimit[MAXPLAYERS];

void Weapon_Ludo_MapStart()
{
	PrecacheSound(CARD_BOOM);
	PrecacheSound(CARD_SHOOT);
	PrecacheSound(BLACKJACK_SOUND);
	PrecacheSound(BLACKJACK_FAIL);
	PrecacheSound(DRAW_CARD_SOUND);
	
	Zero(AceReserve);
	Zero(SecondReserve);
	Zero(ThirdReserve);
	Zero(FourthReserve);
	Zero(FifthReserve);
	Zero(SixthReserve);
	Zero(SeventhReserve);
	Zero(EighthReserve);
	Zero(NinethReserve);
	Zero(TenthReserve);
	Zero(JackReserve);
	Zero(QueenReserve);
	Zero(KingReserve);

	Zero(Second);
	Zero(Third);
	Zero(Fourth);
	Zero(Fifth);
	Zero(Sixth);
	Zero(Seventh);
	Zero(Eighth);
	Zero(Nineth);
	Zero(Tenth);
	Zero(Jack);
	Zero(Queen);
	Zero(King);

	Zero(SixthDebuff);
	Zero(SeventhDebuff);
	Zero(EighthDebuff);
	Zero(NinethDebuff);
	Zero(TenthDebuff);

	Zero(SpadeCounter);
	Zero(DiamondCounter);
	Zero(HasClubs);

	Zero(Ludo_hud_delay);

	Zero(Timer_Ludo_Management);
}

public void Weapon_Ludo_M1(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = (RoundToCeil(Attributes_Get(weapon, 733, 1.0)) * 2) * CardCounter[client];
	if(mana_cost > 300)
		mana_cost = 300;
	if(CardCounter[client] > 1 && mana_cost <= Current_Mana[client])
	{
		float damage = 110.0;
		float damageModBlackjack;
		float damageModCards;
		switch(OverLimit[client])
		{
			case false:
			{
				damageModBlackjack = (float(BlackJack[client]) - 10.0) / 10.0;
				if(damageModBlackjack < 0.05)
					damageModBlackjack = 0.0;
			}
			case true:
			{
				switch(BlackJack[client])
				{
					case 22,23:
					{
						damageModBlackjack = -0.10;
					}
					case 24,25:
					{
						damageModBlackjack = -0.2;
					}
					case 26:
					{
						damageModBlackjack = -0.3;
					}
					case 27:
					{
						damageModBlackjack = -0.4;
					}
					default:
					{
						damageModBlackjack = -0.5;
					}
				}
				Second[client] = 0;
				Third[client] = 0;
				Fourth[client] = 0;
				Fifth[client] = 0;
				Sixth[client] = 0;
				Seventh[client] = 0;
				Eighth[client] = 0;
				Nineth[client] = 0;
				Tenth[client] = 0;
				Jack[client] = 0;
				Queen[client] = 0;
				King[client] = 0;
			}
		}
		switch(CardCounter[client])
		{
			case 2:
			{
				damageModCards = 0.55;
			}
			case 3:
			{
				damageModCards = 0.765;
			}
			case 4:
			{
				damageModCards = 1.1;
			}
			case 5:
			{
				damageModCards = 1.3;
			}
			case 6:
			{
				damageModCards = 1.6;
			}
			case 7:
			{
				damageModCards = 50.0; //huge dmg as this is incredibly rare, feel free to reduce if getting 7 cards is too common
			}
			default:
			{
				damageModCards = 1.0;
			}
		}

		float DiamondBuff = 1.0;

		if(BlackJack[client] == 21)
			damageModBlackjack = 1.5;

		if(DiamondCounter[client] > 2 && OverLimit[client] == false)
		{
			damageModBlackjack += 0.5;
			DiamondBuff = 2.0;
		}

		damage += damageModBlackjack * 100;
		damage += float(SpadeCounter[client]) * 10;
		damage *= damageModCards;
		damage *= Attributes_Get(weapon, 410, 1.0);

		float speed = 1400.0 * DiamondBuff;
		if(Fourth[client] > 0)
			speed /= 2;

		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);	
		speed *= Attributes_Get(weapon, 475, 1.0);
	
		float time = 500.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);		
		time *= Attributes_Get(weapon, 102, 1.0);
		
		DiamondBuff = 1.0;
		DestroyCardEffect(client);
		EmitSoundToAll(CARD_SHOOT, client, _, 65, _, 0.5, 85);
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		if(Jack[client] > 0 || Queen[client] > 0 || King[client] > 0)
		{
			switch(Jack[client]) //high speed bigger dmg
			{
				case 1:
				{
					speed *= 4;
					damage *= 1.2;
				}
				case 2:
				{
					speed *= 8;
					damage *= 1.4;
				}
			}
			switch(Queen[client]) //more projectile!!!!
			{
				case 1:
				{
					float damageQueenMod = ((CardCounter[client] * 4)/100.0 + 1.0);
					CardCounter[client] *= 2;
					damage /= CardCounter[client];
					damage *= damageQueenMod;
					for(int i; i < (CardCounter[client] - 1); i++)
					{
						speed *= GetRandomFloat(0.5,1.2);
						int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LUDO, weapon, CardParticle[client]);
						//PrintToChatAll("projectile fired");
						if(Fourth[client] > 0 || Third[client] > 0 || Second[client] > 0)
						{
							int homing = Second[client];
							homing += Third[client];
							homing += Fourth[client];
							static float angle[3];
							GetEntPropVector(projectile, Prop_Send, "m_angRotation", angle);
							switch(homing) // first time trying homing please dont kill me
							{
								case 1:
								{
									Initiate_HomingProjectile(projectile,
											client,
											20.0,		// float lockonAngleMax,
											15.0,		// float homingaSec,
											true,		// bool LockOnlyOnce,
											true,		// bool changeAngles,
											angle);
								}
								case 2:
								{
									Initiate_HomingProjectile(projectile,
											client,
											80.0,		// float lockonAngleMax,
											80.0,		// float homingaSec,
											false,		// bool LockOnlyOnce,
											true,		// bool changeAngles,
											angle);
								}
							} 
						}
					}
				}
				case 2:
				{
					float damageQueenMod = ((CardCounter[client] * 4)/100.0 + 1.0);
					CardCounter[client] *= 2;
					damage /= CardCounter[client] + 1;
					damage *= damageQueenMod;
					for(int i; i < CardCounter[client]; i++)
					{
						speed *= GetRandomFloat(0.5,1.2);
						int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LUDO, weapon, CardParticle[client]);
						if(Fourth[client] > 0 || Third[client] > 0 || Second[client] > 0)
						{
							int homing = Second[client];
							homing += Third[client];
							homing += Fourth[client];
							static float angle[3];
							GetEntPropVector(projectile, Prop_Send, "m_angRotation", angle);
							switch(homing) // first time trying homing please dont kill me
							{
								case 1:
								{
									Initiate_HomingProjectile(projectile,
											client,
											20.0,		// float lockonAngleMax,
											15.0,		// float homingaSec,
											true,		// bool LockOnlyOnce,
											true,		// bool changeAngles,
											angle);
								}
								case 2:
								{
									Initiate_HomingProjectile(projectile,
											client,
											80.0,		// float lockonAngleMax,
											80.0,		// float homingaSec,
											false,		// bool LockOnlyOnce,
											true,		// bool changeAngles,
											angle);
								}
							} 
						}
					}
				}
			}
			switch(King[client]) //slow projectile very high dmg - TODO for future: figure out how to do aoe???
			{
				case 1:
				{
					speed *= 0.2;
					damage *= 1.5;
				}
				case 2:
				{
					speed *= 0.2;
					damage *= 2.0;
				}
			}
		}
		int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_LUDO, weapon, CardParticle[client]);
		if(Fourth[client] > 0 || Third[client] > 0 || Second[client] > 0)
		{
			int homing = Second[client];
			homing += Third[client];
			homing += Fourth[client];
			static float angle[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", angle);
			switch(homing) // first time trying homing please dont kill me
			{
				case 1:
				{
					Initiate_HomingProjectile(projectile,
							client,
							20.0,		// float lockonAngleMax,
							15.0,		// float homingaSec,
							true,		// bool LockOnlyOnce,
							true,		// bool changeAngles,
							angle);
				}
				default:
				{
					Initiate_HomingProjectile(projectile,
							client,
							80.0,		// float lockonAngleMax,
							80.0,		// float homingaSec,
							false,		// bool LockOnlyOnce,
							true,		// bool changeAngles,
							angle);
				}
			} 
		}
		SDKhooks_SetManaRegenDelayTime(client, 3.0);
		Mana_Hud_Delay[client] = 0.0;
		switch(Fifth[client])
		{
			case 0:
			{
				Current_Mana[client] -= mana_cost;
			}
			case 1:
			{
				Current_Mana[client] += mana_cost;
			}
			case 2:
			{
				Current_Mana[client] += mana_cost * 2;
			}
		}
		
		delay_hud[client] = 0.0;

		CardCounter[client] = 0;
		BlackJack[client] = 0;
		SpadeCounter[client] = 0;
		DiamondCounter[client] = 0;

		AceReserve[client] = false;
		SecondReserve[client] = false;
		ThirdReserve[client] = false;
		FourthReserve[client] = false;
		FifthReserve[client] = false;
		SixthReserve[client] = false;
		SeventhReserve[client] = false;
		EighthReserve[client] = false;
		NinethReserve[client] = false;
		TenthReserve[client] = false;
		JackReserve[client] = false;
		QueenReserve[client] = false;
		KingReserve[client] = false;

		SixthDebuff[client] = Sixth[client];
		SeventhDebuff[client] = Seventh[client];
		EighthDebuff[client] = Eighth[client];
		NinethDebuff[client] =	Nineth[client];
		TenthDebuff[client] = Tenth[client];

		Second[client] = 0;
		Third[client] = 0;
		Fourth[client] = 0;
		Fifth[client] = 0;
		Sixth[client] = 0;
		Seventh[client] = 0;
		Eighth[client] = 0;
		Nineth[client] = 0;
		Tenth[client] = 0;
		Jack[client] = 0;
		Queen[client] = 0;
		King[client] = 0;

		OverLimit[client] = false;
		Ludo_CardRNG(client);
		BlackjackCounterRandom[client] = BlackjackCounter[client] + GetRandomInt(-1,1);
		if(BlackjackCounterRandom[client] > 11)
			BlackjackCounterRandom[client] = 11;

		if(BlackjackCounterRandom[client] == 0)
			BlackjackCounterRandom[client] = 1;
	}
	else if(CardCounter[client] > 1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction,"You need to draw more cards!");
	}
}

static void Ludo_CardRNG(int client) //generates a card for the future
{
	int RandomCard = GetRandomInt(1,11);
	switch(RandomCard)
	{
		case 1:
		{
			if(AceReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			AceReserve[client] = true;
			BlackjackCounter[client] = 1;
		}
		case 2:
		{
			if(SecondReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			SecondReserve[client] = true;
			BlackjackCounter[client] = 2;
		}
		case 3:
		{
			if(ThirdReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			ThirdReserve[client] = true;
			BlackjackCounter[client] = 3;
		}
		case 4:
		{
			if(FourthReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			FourthReserve[client] = true;
			BlackjackCounter[client] = 4;
		}
		case 5:
		{
			if(FifthReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			FifthReserve[client] = true;
			BlackjackCounter[client] = 5;
		}
		case 6:
		{
			if(SixthReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			SixthReserve[client] = true;
			BlackjackCounter[client] = 6;
		}
		case 7:
		{
			if(SeventhReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			SeventhReserve[client] = true;
			BlackjackCounter[client] = 7;
		}
		case 8:
		{
			if(EighthReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			EighthReserve[client] = true;
			BlackjackCounter[client] = 8;
		}
		case 9:
		{
			if(NinethReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			NinethReserve[client] = true;
			BlackjackCounter[client] = 9;
		}
		case 10:
		{
			if(TenthReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			TenthReserve[client] = true;
			BlackjackCounter[client] = 10;
		}
		case 11:
		{
			if(JackReserve[client] || QueenReserve[client] || KingReserve[client])
			{
				Ludo_CardRNG(client);
				return;
			}
			int JQK = GetRandomInt(1,99);
			if (JQK < 34)
			{
				JackReserve[client] = true;
				BlackjackCounter[client] = 11;
			}
			else if(33 < JQK < 67)
			{
				QueenReserve[client] = true;
				BlackjackCounter[client] = 12;
			}
			else
			{
				KingReserve[client] = true;
				BlackjackCounter[client] = 13;
			}
		}
	}
}

static void Ludo_BlackjackRNG(int client) //draws the generated card from ludo card rng
{
	int pap = i_Current_Pap[client];	
	if(pap == 1) //symbol things
		{
			int SymbolRNG = GetRandomInt(1,4);
			switch(SymbolRNG)
			{
				case 1: //heart $
				{
					switch(CardCounter[client])
					{
						case 0: //first card, contrary to the 0
						{
							Format(FirstCardSymbol[client], sizeof(FirstCardSymbol[]), "%s","$");
						}
						case 1: // second
						{
							Format(SecondCardSymbol[client], sizeof(SecondCardSymbol[]), "%s","$");
						}
						case 2: // third
						{
							Format(ThirdCardSymbol[client], sizeof(ThirdCardSymbol[]), "%s","$");
						}
						case 3: // fourth
						{
							Format(FourthCardSymbol[client], sizeof(FourthCardSymbol[]), "%s","$");
						}
						case 4: // fifth
						{
							Format(FifthCardSymbol[client], sizeof(FifthCardSymbol[]), "%s","$");
						}
						case 5: //sixth
						{
							Format(SixthCardSymbol[client], sizeof(SixthCardSymbol[]), "%s","$");
						}
						case 6: //seventh
						{
							Format(SeventhCardSymbol[client], sizeof(SeventhCardSymbol[]), "%s","$");
						}
					}
					BlackJack[client]--;
				}
				case 2: //spades
				{
					switch(CardCounter[client])
					{
						case 0: //first CardSymbol, contrary to the 0
						{
							Format(FirstCardSymbol[client], sizeof(FirstCardSymbol[]), "%s","^");
						}
						case 1: // second
						{
							Format(SecondCardSymbol[client], sizeof(SecondCardSymbol[]), "%s","^");
						}
						case 2: // third
						{
							Format(ThirdCardSymbol[client], sizeof(ThirdCardSymbol[]), "%s","^");
						}
						case 3: // fourth
						{
							Format(FourthCardSymbol[client], sizeof(FourthCardSymbol[]), "%s","^");
						}
						case 4: // fifth
						{
							Format(FifthCardSymbol[client], sizeof(FifthCardSymbol[]), "%s","^");
						}
						case 5: //sixth
						{
							Format(SixthCardSymbol[client], sizeof(SixthCardSymbol[]), "%s","^");
						}
						case 6: //seventh
						{
							Format(SeventhCardSymbol[client], sizeof(SeventhCardSymbol[]), "%s","^");
						}
					}
					SpadeCounter[client]++;
				}
				case 3: //diamonds
				{
					switch(CardCounter[client])
					{
						case 0: //first CardSymbol, contrary to the 0
						{
							Format(FirstCardSymbol[client], sizeof(FirstCardSymbol[]), "%s","#");
						}
						case 1: // second
						{
							Format(SecondCardSymbol[client], sizeof(SecondCardSymbol[]), "%s","#");
						}
						case 2: // third
						{
							Format(ThirdCardSymbol[client], sizeof(ThirdCardSymbol[]), "%s","#");
						}
						case 3: // fourth
						{
							Format(FourthCardSymbol[client], sizeof(FourthCardSymbol[]), "%s","#");
						}
						case 4: // fifth
						{
							Format(FifthCardSymbol[client], sizeof(FifthCardSymbol[]), "%s","#");
						}
						case 5: //sixth
						{
							Format(SixthCardSymbol[client], sizeof(SixthCardSymbol[]), "%s","#");
						}
						case 6: //seventh
						{
							Format(SeventhCardSymbol[client], sizeof(SeventhCardSymbol[]), "%s","#");
						}
					}
					DiamondCounter[client]++;
				}
				case 4: //clubs
				{
					switch(CardCounter[client])
					{
						case 0: //first CardSymbol, contrary to the 0
						{
							Format(FirstCardSymbol[client], sizeof(FirstCardSymbol[]), "%s","*");
						}
						case 1: // second
						{
							Format(SecondCardSymbol[client], sizeof(SecondCardSymbol[]), "%s","*");
						}
						case 2: // third
						{
							Format(ThirdCardSymbol[client], sizeof(ThirdCardSymbol[]), "%s","*");
						}
						case 3: // fourth
						{
							Format(FourthCardSymbol[client], sizeof(FourthCardSymbol[]), "%s","*");
						}
						case 4: // fifth
						{
							Format(FifthCardSymbol[client], sizeof(FifthCardSymbol[]), "%s","*");
						}
						case 5: //sixth
						{
							Format(SixthCardSymbol[client], sizeof(SixthCardSymbol[]), "%s","*");
						}
						case 6: //seventh
						{
							Format(SeventhCardSymbol[client], sizeof(SeventhCardSymbol[]), "%s","*");
						}
					}
					HasClubs[client] = true;
				} 
			}
		}
	
	switch(BlackjackCounter[client])
	{
		case 1:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","1");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","1");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","1");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","1");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","1");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","1");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","1");
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client]++;
		}
		case 2:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","2");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","2");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","2");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","2");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","2");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","2");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","2");
				}
			}
			switch(HasClubs[client]) //homing card
			{
				case false:
				{
					Second[client]++;
				}
				case true:
				{
					Second[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 2;
		}
		case 3:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","3");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","3");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","3");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","3");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","3");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","3");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","3");
				}
			}
			switch(HasClubs[client]) //homing card
			{
				case false:
				{
					Third[client]++;
				}
				case true:
				{
					Third[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 3;
		}
		case 4:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","4");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","4");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","4");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","4");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","4");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","4");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","4");
				}
			}
			switch(HasClubs[client]) //homing card
			{
				case false:
				{
					Fourth[client]++;
				}
				case true:
				{
					Fourth[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 4;
		}
		case 5:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","5");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","5");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","5");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","5");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","5");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","5");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","5");
				}
			}
			switch(HasClubs[client]) //mana card
			{
				case false:
				{
					Fifth[client]++;
				}
				case true:
				{
					Fifth[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 5;
		}
		case 6:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","6");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","6");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","6");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","6");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","6");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","6");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","6");
				}
			}
			switch(HasClubs[client]) //stun card
			{
				case false:
				{
					Sixth[client]++;
				}
				case true:
				{
					Sixth[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 6;
		}
		case 7:
		{
			switch(CardCounter[client]) //silence card
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","7");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","7");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","7");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","7");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","7");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","7");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","7");
				}
			}
			switch(HasClubs[client])
			{
				case false:
				{
					Seventh[client]++;
				}
				case true:
				{
					Seventh[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 7;
		}
		case 8:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","8");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","8");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","8");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","8");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","8");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","8");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","8");
				}
			}
			switch(HasClubs[client]) //weak bleed card
			{
				case false:
				{
					Eighth[client]++;
				}
				case true:
				{
					Eighth[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 8;
		}
		case 9:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","9");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","9");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","9");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","9");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","9");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","9");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","9");
				}
			}
			switch(HasClubs[client]) //bleed card
			{
				case false:
				{
					Nineth[client]++;
				}
				case true:
				{
					Nineth[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 9;
		}
		case 10:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","10");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","10");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","10");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","10");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","10");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","10");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","10");
				}
			}
			switch(HasClubs[client]) //debuff card
			{
				case false:
				{
					Tenth[client]++;
				}
				case true:
				{
					Tenth[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 10;
		}
		case 11:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","J");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","J");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","J");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","J");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","J");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","J");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","J");
				}
			}
			switch(HasClubs[client])
			{
				case false:
				{
					Jack[client]++;
				}
				case true:
				{
					Jack[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 11;
		}
		case 12:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","Q");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","Q");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","Q");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","Q");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","Q");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","Q");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","Q");
				}
			}
			switch(HasClubs[client])
			{
				case false:
				{
					Queen[client]++;
				}
				case true:
				{
					Queen[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 11;
		}
		case 13:
		{
			switch(CardCounter[client])
			{
				case 0: //first card, contrary to the 0
				{
					Format(FirstCard[client], sizeof(FirstCard[]), "%s","K");
				}
				case 1: // second
				{
					Format(SecondCard[client], sizeof(SecondCard[]), "%s","K");
				}
				case 2: // third
				{
					Format(ThirdCard[client], sizeof(ThirdCard[]), "%s","K");
				}
				case 3: // fourth
				{
					Format(FourthCard[client], sizeof(FourthCard[]), "%s","K");
				}
				case 4: // fifth
				{
					Format(FifthCard[client], sizeof(FifthCard[]), "%s","K");
				}
				case 5: //sixth
				{
					Format(SixthCard[client], sizeof(SixthCard[]), "%s","K");
				}
				case 6: //seventh
				{
					Format(SeventhCard[client], sizeof(SeventhCard[]), "%s","K");
				}
			}
			switch(HasClubs[client])
			{
				case false:
				{
					King[client]++;
				}
				case true:
				{
					King[client] += 2;
				}
			}
			BlackjackCounter[client] = 0;
			BlackJack[client] += 11;	
		}
		default:
		{
			PrintToChatAll("haha error message :) complain to mened :)"); //error message lol
		}
	}
	CardCounter[client]++;
	HasClubs[client] = false;
	if(BlackJack[client] == 21)
	{
		EmitSoundToClient(client,BLACKJACK_SOUND, _, _, _, _, 0.8, 115);
	}

	if(BlackJack[client] > 21)
	{
		EmitSoundToClient(client,BLACKJACK_FAIL, _, _, _, _, 1.0, 115);
	}
}

void CreateCardEffect(int client)
{
	DestroyCardEffect(client);
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float flPos[3]; 
		float flAng[3];
		int particle = ParticleEffectAt(flPos, CardParticle[client], 0.0);
		GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
		SetParent(viewmodelModel, particle, "effect_hand_r");
		i_CardParticle[client] = EntIndexToEntRef(particle);
	}
}

void DestroyCardEffect(int client)
{
	int entity = EntRefToEntIndex(i_CardParticle[client]);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	i_CardParticle[client] = INVALID_ENT_REFERENCE;
}

public void Weapon_Ludo_M2(int client, int weapon, bool crit, int slot)
{ 
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		if(OverLimit[client] == true)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "You went over the limit.");
			return;
		}
		if(BlackJack[client] == 21)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Your Blackjack limit is at 21 already!");
			return;
		}

		int mana_need;
		mana_need = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
		if(mana_need <= Current_Mana[client] && BlackJack[client] < 21)
		{	
			SDKhooks_SetManaRegenDelayTime(client, 1.0);
			Mana_Hud_Delay[client] = 0.0;
			Current_Mana[client] -= mana_need;
			
			delay_hud[client] = 0.0;

			Ludo_BlackjackRNG(client);
			Ludo_CardRNG(client);
			BlackjackCounterRandom[client] = BlackjackCounter[client] + GetRandomInt(-1,1);
			if(BlackjackCounterRandom[client] > 11)
				BlackjackCounterRandom[client] = 11;

			if(BlackjackCounterRandom[client] == 0)
				BlackjackCounterRandom[client] = 1;

			if(BlackJack[client] > 21)
				OverLimit[client] = true;
			
			EmitSoundToClient(client,DRAW_CARD_SOUND, _, _, _, _, 0.8, 70 + (CardCounter[client] * 10));
			switch(CardCounter[client])
			{
				case 1,2:
				{
					DestroyCardEffect(client);
					Format(CardParticle[client], sizeof(CardParticle[]), "%s","critical_rocket_blue"); //white
					CreateCardEffect(client);
				}
				case 3,4:
				{
					DestroyCardEffect(client);
					Format(CardParticle[client], sizeof(CardParticle[]), "%s","critical_rocket_red"); // green
					CreateCardEffect(client);
				}
				case 5,6:
				{
					DestroyCardEffect(client);
					Format(CardParticle[client], sizeof(CardParticle[]), "%s","eyeboss_projectile"); // purple
					CreateCardEffect(client);
				}
				case 7:
				{
					DestroyCardEffect(client);
					Format(CardParticle[client], sizeof(CardParticle[]), "%s","halloween_rockettrail"); // Golden.
					CreateCardEffect(client);
				}
			}
			Ability_Apply_Cooldown(client, slot, 0.5);
		}	
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_need);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public void Weapon_Ludo_WandTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		if(SixthDebuff[owner] > 0 || SeventhDebuff[owner] > 0 || EighthDebuff[owner] > 0 || NinethDebuff[owner] > 0 || TenthDebuff[owner] > 0)
		{
			switch(SixthDebuff[owner])
			{
				case 1:
				{
					float StunDuration = 3.0;
					if(b_thisNpcIsABoss[target])
					{
						StunDuration = 1.7;
					}	
					if(b_thisNpcIsARaid[target])
					{
						StunDuration = 1.0;
					}	

					FreezeNpcInTime(target, StunDuration);
				}
				case 2:
				{
					float StunDuration = 5.0;
					if(b_thisNpcIsABoss[target])
					{
						StunDuration = 2.0;
					}	
					if(b_thisNpcIsARaid[target])
					{
						StunDuration = 1.25;
					}	

					FreezeNpcInTime(target, StunDuration);
				}
			}
			switch(SeventhDebuff[owner])
			{
				case 1:
				{
					ApplyStatusEffect(owner, target, "Silenced", 10.0);
				}
				case 2:
				{
					ApplyStatusEffect(owner, target, "Silenced", 15.0);
				}
			}
			switch(EighthDebuff[owner])
			{
				case 1:
				{
					StartBleedingTimer(target, owner, (100 * Attributes_Get(weapon, 410, 1.0)) * 0.03, 4, weapon, DMG_PLASMA);
				}
				case 2:
				{
					StartBleedingTimer(target, owner, (100 * Attributes_Get(weapon, 410, 1.0)) * 0.05, 4, weapon, DMG_PLASMA);
				}
			}
			switch(NinethDebuff[owner])
			{
				case 1:
				{
					StartBleedingTimer(target, owner, f_WandDamage[entity] * 0.03, 4, weapon, DMG_PLASMA);
				}
				case 2:
				{
					StartBleedingTimer(target, owner, f_WandDamage[entity] * 0.05, 4, weapon, DMG_PLASMA);
				}
			}
			switch(TenthDebuff[owner])
			{
				case 1:
				{
					ApplyStatusEffect(owner, target, "Ludo-Maniancy", 12.5);
				}
				case 2:
				{
					ApplyStatusEffect(owner, target, "Spade Ludo-Maniancy", 20.0);
				}
			}
		}
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(CARD_BOOM, entity, SNDCHAN_STATIC, 90, _, 1.0);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(CARD_BOOM, entity, SNDCHAN_STATIC, 90, _, 1.0);
		RemoveEntity(entity);
	}
	SixthDebuff[owner] = 0;
	SeventhDebuff[owner] = 0;
	EighthDebuff[owner] = 0;
	NinethDebuff[owner] = 0;
	TenthDebuff[owner] = 0;
}

static int Ludo_Get_Pap(int weapon) //deivid inspired pap detection system (as in literally a copy-paste from fantasy blade)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	return pap;
}

public void Ludo_OnBuy(int client)
{
	Ludo_CardRNG(client);
	BlackjackCounterRandom[client] = BlackjackCounter[client] + GetRandomInt(-1,1);
	if(BlackjackCounterRandom[client] > 11)
		BlackjackCounterRandom[client] = 11;

	if(BlackjackCounterRandom[client] == 0)
		BlackjackCounterRandom[client] = 1;
}

/// hud stuff
static void Ludo_Show_Hud(int client)
{
	int pap = i_Current_Pap[client];
	switch(pap)
	{
		case 0:
		{
			switch(CardCounter[client])
			{
				case 0:
				{
					PrintHintText(client,"[No cards drawn!]\n[%.1i] Cards\nBlackjack Value: %.1i/21", CardCounter[client], BlackJack[client]);
					
				}
				case 1:
				{
					PrintHintText(client,"[%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21", FirstCard[client], CardCounter[client], BlackJack[client]);
					
				}
				case 2:
				{
					PrintHintText(client,"[%s | %s]\n[%.1i] Cards\nBlackjack Value: %.1i/21", FirstCard[client], SecondCard[client], CardCounter[client], BlackJack[client]);
					
				}
				case 3:
				{
					PrintHintText(client,"[%s | %s | %s]\n[%.1i] Cards\nBlackjack Value: %.1i/21", FirstCard[client], SecondCard[client], ThirdCard[client], CardCounter[client], BlackJack[client]);
					
				}
				case 4:
				{
					PrintHintText(client,"[%s | %s | %s | %s]\n[%.1i] Cards\nBlackjack Value: %.1i/21", FirstCard[client], SecondCard[client], ThirdCard[client], FourthCard[client], CardCounter[client], BlackJack[client]);
					
				}
				case 5:
				{
					PrintHintText(client,"[%s | %s | %s | %s | %s]\n[%.1i] Cards\nBlackjack Value: %.1i/21", FirstCard[client], SecondCard[client], ThirdCard[client], FourthCard[client], FifthCard[client], CardCounter[client], BlackJack[client]);
					
				}
				case 6:
				{
					PrintHintText(client,"[%s | %s | %s | %s | %s | %s]\n[%.1i] Cards\nBlackjack Value: %.1i/21", FirstCard[client], SecondCard[client], ThirdCard[client], FourthCard[client], FifthCard[client], SixthCard[client], CardCounter[client], BlackJack[client]);
					
				}
				case 7:
				{
					PrintHintText(client,"[%s | %s | %s | %s | %s | %s | %s]\n[%.1i] Cards\nBlackjack Value: %.1i/21", FirstCard[client], SecondCard[client], ThirdCard[client], FourthCard[client], FifthCard[client], SixthCard[client], SeventhCard[client], CardCounter[client], BlackJack[client]);
					
				}
				default:
				{
					PrintHintText(client,"Error! Press M2, if this persists contact Mened and SCREAM AT THEM!!!!!");
					
				}
			}
		}
		case 1:
		{
			switch(CardCounter[client])
			{
				case 0:
				{
					PrintHintText(client,"[No cards drawn!]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				case 1:
				{
					PrintHintText(client,"[%s%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", FirstCard[client], FirstCardSymbol[client], CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				case 2:
				{
					PrintHintText(client,"[%s%s | %s%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", FirstCard[client], FirstCardSymbol[client], SecondCard[client], SecondCardSymbol[client], CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				case 3:
				{
					PrintHintText(client,"[%s%s | %s%s | %s%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", FirstCard[client], FirstCardSymbol[client], SecondCard[client], SecondCardSymbol[client], ThirdCard[client], ThirdCardSymbol[client], CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				case 4:
				{
					PrintHintText(client,"[%s%s | %s%s | %s%s | %s%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", FirstCard[client], FirstCardSymbol[client], SecondCard[client], SecondCardSymbol[client], ThirdCard[client], ThirdCardSymbol[client], FourthCard[client], FourthCardSymbol[client], CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				case 5:
				{
					PrintHintText(client,"[%s%s | %s%s | %s%s | %s%s | %s%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", FirstCard[client], FirstCardSymbol[client], SecondCard[client], SecondCardSymbol[client], ThirdCard[client], ThirdCardSymbol[client], FourthCard[client], FourthCardSymbol[client], FifthCard[client], FifthCardSymbol[client], CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				case 6:
				{
					PrintHintText(client,"[%s%s | %s%s | %s%s | %s%s | %s%s | %s%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", FirstCard[client], FirstCardSymbol[client], SecondCard[client], SecondCardSymbol[client], ThirdCard[client], ThirdCardSymbol[client], FourthCard[client], FourthCardSymbol[client], FifthCard[client], FifthCardSymbol[client], SixthCard[client], SixthCardSymbol[client], CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				case 7:
				{
					PrintHintText(client,"[%s%s | %s%s | %s%s | %s%s | %s%s | %s%s | %s%s]\n[%.1i] Cards\nBlackjack Value: %.1i/21\nMathematical Foresight: [%.1i]", FirstCard[client], FirstCardSymbol[client], SecondCard[client], SecondCardSymbol[client], ThirdCard[client], ThirdCardSymbol[client], FourthCard[client], FourthCardSymbol[client], FifthCard[client], FifthCardSymbol[client], SixthCard[client], SixthCardSymbol[client], SeventhCard[client], SeventhCardSymbol[client], CardCounter[client], BlackJack[client], BlackjackCounterRandom[client]);
					
				}
				default:
				{
					PrintHintText(client,"Error! Press M2, if this persists contact Mened and SCREAM AT THEM!!!!!");
					
				}
			}
		}
	}
}

public void Enable_Ludo(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Ludo_Management[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LUDO)
		{
			//Is the weapon it again?
			//Yes?
			i_Current_Pap[client] = Ludo_Get_Pap(weapon);
			delete Timer_Ludo_Management[client];
			Timer_Ludo_Management[client] = null;
			DataPack pack;
			Timer_Ludo_Management[client] = CreateDataTimer(0.1, Timer_Management_Ludo, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_LUDO) //
	{
		i_Current_Pap[client] = Ludo_Get_Pap(weapon);

		DataPack pack;
		Timer_Ludo_Management[client] = CreateDataTimer(0.1, Timer_Management_Ludo, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Ludo(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Ludo_Management[client] = null;
		return Plugin_Stop;
	}	

	Ludo_Cooldown_Logic(client, weapon);

	return Plugin_Continue;
}

public void Ludo_Cooldown_Logic(int client, int weapon)
{
	//Do your code here :) < ok :)
	if(Ludo_hud_delay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			Ludo_Show_Hud(client);
			i_Current_Pap[client] = Ludo_Get_Pap(weapon);
		}
		Ludo_hud_delay[client] = GetGameTime() + 0.5;
	}
}