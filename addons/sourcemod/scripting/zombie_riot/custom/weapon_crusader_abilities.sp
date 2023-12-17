#pragma semicolon 1
#pragma newdecls required

Handle Timer_Banner_Management[MAXPLAYERS+1] = {null, ...};
int i_SetBannerType[MAXPLAYERS+1];
bool b_ClientHasAncientBanner[MAXENTITIES];
bool b_EntityRecievedBuff[MAXENTITIES];

#define CRUSADER_FLAG_MODEL "models/props_medieval/pendant_flag/pendant_flag.mdl"
#define CRUSADER_FLAG_MODEL_SIZE 0.25

#define CRUSADER_TAUNT_FLAG_PLACE "taunt_the_profane_puppeteer"
#define CRUSADER_TAUNT_FLAG_PLACE_PROGRESS
//55 / 227 frames, find it lol.

//model is soldier