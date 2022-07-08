/*
abstract_class IServerPluginHelpers
{
public:
	// creates an onscreen menu with various option buttons
	//	The keyvalues param can contain these fields:
	//	"title" - (string) the title to show in the hud and in the title bar
	//	"msg" - (string) a longer message shown in the GameUI
	//  "color" - (color) the color to display the message in the hud (white by default)
	//	"level" - (int) the priority of this message (closer to 0 is higher), only 1 message can be outstanding at a time
	//	"time" - (int) the time in seconds this message should stay active in the GameUI (min 10 sec, max 200 sec)
	//
	// For DIALOG_MENU add sub keys for each option with these fields:
	//  "command" - (string) client command to run if selected
	//  "msg" - (string) button text for this option
	//
	virtual void CreateMessage( edict_t *pEntity, DIALOG_TYPE type, KeyValues *data, IServerPluginCallbacks *plugin ) = 0;
	virtual void ClientCommand( edict_t *pEntity, const char *cmd ) = 0;
	
	// Call this to find out the value of a cvar on the client.
	//
	// It is an asynchronous query, and it will call IServerPluginCallbacks::OnQueryCvarValueFinished when
	// the value comes in from the client.
	//
	// Store the return value if you want to match this specific query to the OnQueryCvarValueFinished call.
	// Returns InvalidQueryCvarCookie if the entity is invalid.
	virtual QueryCvarCookie_t StartQueryCvarValue( edict_t *pEntity, const char *pName ) = 0;
};
*/

/*

typedef enum
{
	DIALOG_MSG = 0,		// just an on screen message
	DIALOG_MENU,		// an options menu
	DIALOG_TEXT,		// a richtext dialog
	DIALOG_ENTRY,		// an entry box
	DIALOG_ASKCONNECT	// Ask the client to connect to a specified IP address. Only the "time" and "title" keys are used.
} DIALOG_TYPE;



void			SetPenetrate( bool bPenetrate = false ) { m_bPenetrate = bPenetrate; SetSolidFlags( FSOLID_NOT_SOLID | FSOLID_TRIGGER ); }
bool			CanPenetrate() const { return m_bPenetrate; }


https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/shared/basecombatweapon_shared.cpp#L2547

https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/shared/baseentity_shared.cpp#L1762

*/


#include <sdktools>
public void OnPluginStart() {
    RegAdminCmd("sm_spawncoords", ListSpawnCoords, ADMFLAG_ROOT);
}

Action ListSpawnCoords(int client, int argc) {
    for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) {
        float origin[3];
        GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", origin);
        ReplyToCommand(client, "[%d] %.2f %.2f %.2f (valid? %b)", ent,
                origin[0], origin[1], origin[2], IsValidEntity(ent));
        
    }
}