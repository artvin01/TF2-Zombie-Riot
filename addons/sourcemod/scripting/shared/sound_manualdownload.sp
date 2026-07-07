#pragma semicolon 1
#pragma newdecls required

static bool ClientHasManualDownload[MAXPLAYERS];

#define VERSION_NUMBER 2

public void SoundManual_OnClientPutInServer(int client)
{
	ClientHasManualDownload[client] = false;
	if(FileNetworkLib_Installed())
		SoundManualRequestFile(client);
}

bool SoundManualHas(int client)
{
	return ClientHasManualDownload[client];
}

void SoundManualRequestFile(int client)
{
#if defined _filenetwork_included
	char buffer[1028];
	FormatEx(buffer, sizeof(buffer), "sound/zr_manual/manual_file_check_%i.txt", VERSION_NUMBER);
	DataPack pack = new DataPack();
//	pack.WriteCell(2);
//	pack.WriteString(buffer);
//	pack.WriteFunction(func);

	if(!DeleteFile(buffer, true))
	{
		static char filecheck[PLATFORM_MAX_PATH];
		Format(filecheck, sizeof(filecheck), "download/%s", buffer);
		DeleteFile(filecheck);
	}
	FileNet_RequestFile(client, buffer, SoundManualRequestResult, pack, 10);
#else
	if(client) { }
#endif
}
#if defined _filenetwork_included

public void SoundManualRequestResult(int client, const char[] file, int id, bool success, DataPack pack)
{
	// If not found, send the actual file

	if(success)
	{
		//client has sound
		ClientHasManualDownload[client] = true;
		if(!DeleteFile(file, true))
		{
			static char filecheck[PLATFORM_MAX_PATH];
			Format(filecheck, sizeof(filecheck), "download/%s", file);
			DeleteFile(filecheck);
		}
	}

	delete pack;
}
#endif