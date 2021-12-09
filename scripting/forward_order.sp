
#include <sourcemod>

Handle g_fwOnReady;
Handle g_fwOnReadyPost;
Handle g_fwOnCallForward;

enum struct PLInfo
{
	Handle plugin;
	char name[128];
	Function func;
	int rank;
}
enum struct ForwardInfo
{
	Handle owner;
	char name[128];
	ArrayList pluginList;
	KeyValues orderKV;
	
	void Init(KeyValues kv)
	{
		this.pluginList = new ArrayList(sizeof(PLInfo));
		this.orderKV = kv;
		
		if (this.orderKV.GotoFirstSubKey()) {
			int rank = 1;
			do {
				this.orderKV.SetNum("rank", rank++);
			}
			while (this.orderKV.GotoNextKey())
			
			this.orderKV.Rewind();
		}
	}
	void AddPlugin(PLInfo plInfo)
	{
		char buffer[128];
		Format(buffer, sizeof(buffer), "%s/rank", plInfo.name);
		plInfo.rank = this.orderKV.GetNum(buffer, 9999);
		this.pluginList.PushArray(plInfo, sizeof(plInfo));
	}
}
methodmap ForwardList < ArrayList
{
	public ForwardList()
	{
		return view_as<ForwardList>(new ArrayList(sizeof(ForwardInfo)));
	}
	public int FindForward(const char[] name, ForwardInfo info)
	{
		int len = this.Length;
		for (int i=0; i<len; i++) {
			this.GetArray(i, info, sizeof(info));
			
			if (StrEqual(info.name, name))
				return i;
		}
		
		return -1;
	}
	public void CallForward(const char[] name)
	{
		ForwardInfo forwardInfo;
		this.FindForward(name, forwardInfo, sizeof(forwardInfo));
		
		int len = forwardInfo.pluginList.Length;
		for (int i=0; i<len; i++) {
			PLInfo info;
			forwardInfo.pluginList.GetArray(i, info, sizeof(info));
			
			// Call_StartFunction(info.plugin, info.func);
			// Call_Finish();
		}
	}
	public void Reorder()
	{	
		ForwardInfo forwardInfo;
		for (int f=0; f<this.Length; f++) {
			this.GetArray(f, forwardInfo, sizeof(forwardInfo));
			
			PLInfo info1, info2;
			
			int len = forwardInfo.pluginList.Length;
			for (int i=0; i<len-1; i++) {
				forwardInfo.pluginList.GetArray(i, info1, sizeof(PLInfo));
				for (int k=1; k<len; k++) {
					forwardInfo.pluginList.GetArray(k, info2, sizeof(PLInfo));
					if (info1.rank > info2.rank)
						forwardInfo.pluginList.SwapAt(i, k);
				}
			}
			
			this.SetArray(f, forwardInfo, sizeof(forwardInfo));
		}
	}
}
ForwardList g_forwardList;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("FO_AddForward", Native_AddForward);
	CreateNative("FO_AddPlugin", Native_AddPlugin);
	CreateNative("FO_CallForward", Native_CallForward);
	
	g_fwOnReady = CreateGlobalForward("FO_OnReady", ET_Ignore);
	g_fwOnReadyPost = CreateGlobalForward("FO_OnReadyPost", ET_Ignore);
	
	g_fwOnCallForward = CreateGlobalForward("FO_OnCallForward", ET_Ignore);
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_forwardList = new ForwardList();
}

public void OnAllPluginsLoaded()
{
	Call_StartForward(g_fwOnReady);
	Call_Finish();
	
	Call_StartForward(g_fwOnReadyPost);
	Call_Finish();
	
	g_forwardList.Reorder();
}

//FO_AddForward(const char[] name, KeyValues kv)
public int Native_AddForward(Handle plugin, int numParams)
{
	ForwardInfo info;
	KeyValues kv = GetNativeCell(2);
	
	GetNativeString(1, info.name, sizeof(ForwardInfo::name));
	info.owner = plugin;
	info.Init(kv);
	
	g_forwardList.PushArray(info, sizeof(ForwardInfo));
	
	return 0;
}

//FO_AddPlugin(const char forwardName[], Function func);
public int Native_AddPlugin(Handle plugin, int numParams)
{
	char forwardName[128];
	GetNativeString(1, forwardName, sizeof(forwardName));
	Function func = GetNativeFunction(2);
	
	ForwardInfo forwardInfo;
	g_forwardList.FindForward(forwardName, forwardInfo);
	
	PLInfo info;
	info.plugin = plugin;
	info.func = func;
	GetPluginFilename(plugin, info.name, sizeof(info.name));
	forwardInfo.AddPlugin(info);
	
	return 0;
}

public int Native_CallForward(Handle plugin, int numParams)
{

	return 0;
}