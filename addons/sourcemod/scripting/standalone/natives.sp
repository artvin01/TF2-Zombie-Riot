#pragma semicolon 1
#pragma newdecls required

void Natives_PluginLoad()
{
	CreateNative("FuncToVal", Native_FuncToVal);
}