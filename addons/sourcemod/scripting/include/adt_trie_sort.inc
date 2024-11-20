#if defined _adt_trie_sort_included
	#endinput
#endif
#define _adt_trie_sort_included

#include <adt_array>
#include <adt_trie>

#define ADTTRIESORTSIZE	512

methodmap SortedSnapshot < ArrayList
{
	public int GetKey(int index, char[] buffer, int maxlength)
	{
		return GetArrayString(this, index, buffer, maxlength);
	}
	
	public int KeyBufferSize(int index)
	{
		static char buffer[ADTTRIESORTSIZE];
		return GetArrayString(this, index, buffer, sizeof(buffer));
	}
}

SortedSnapshot CreateSortedSnapshot(Handle map, SortOrder order = Sort_Ascending)
{
	ArrayList list;
	StringMapSnapshot snap = view_as<StringMapSnapshot>(CreateTrieSnapshot(map));
	
	list = new ArrayList(ByteCountToCells(ADTTRIESORTSIZE));
	
	int entires = snap.Length;
	for(int i; i < entires; i++)
	{
		int length = snap.KeyBufferSize(i) + 1;
		if(length > ADTTRIESORTSIZE)
			length = ADTTRIESORTSIZE;
		
		char[] buffer = new char[length];
		snap.GetKey(i, buffer, length);
		
		list.PushString(buffer);
	}
	
	delete snap;
	
	if(order == Sort_Random)
	{
		list.Sort(order, Sort_String);
	}
	else
	{
		list.SortCustom(_SortedSnapshotSorting, order == Sort_Ascending ? map : INVALID_HANDLE);
	}
	return view_as<SortedSnapshot>(list);
}

public int _SortedSnapshotSorting(int index1, int index2, Handle array, Handle data)
{
	static char buffer1[ADTTRIESORTSIZE], buffer2[ADTTRIESORTSIZE];
	
	int length1 = GetArrayString(array, index1, buffer1, sizeof(buffer1));
	int length2 = GetArrayString(array, index2, buffer2, sizeof(buffer2));
	
	int value1 = StringToInt(buffer1);
	int value2 = StringToInt(buffer2);
	
	if(value1 > value2)
	{
		return data ? 1 : -1;
	}
	else if(value2 > value1)
	{
		return data ? -1 : 1;
	}
	else
	{
		for(int i; ; i++)
		{
			if(length1 == i)
			{
				if(length2 == i)
					break;
				
				return data ? -1 : 1;
			}
			else if(length2 == i || buffer1[i] > buffer2[i])
			{
				return data ? 1 : -1;
			}
			else if(buffer1[i] < buffer2[i])
			{
				return data ? -1 : 1;
			}
		}
	}
	return 0;
}
