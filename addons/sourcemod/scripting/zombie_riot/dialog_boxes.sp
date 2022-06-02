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

*/