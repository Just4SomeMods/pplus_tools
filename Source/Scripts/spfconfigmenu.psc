Scriptname spfconfigmenu extends Quest

Actor Property PlayerRef Auto
SexLabFramework Property SexLab auto
sslSystemConfig Property Config auto
import b612
int lastUsed = -1
float _updateTimer = 0.5
string currentTarget = ""
bool cumOutside = false
bool playerIsAllowedToOrgasm = true
int MagickaCost = 10
string lastTarget = ""
import MCM

event OnInit()
	Maintenance()
EndEvent

Event advanceAnim()
	sslThreadController _thread =  Sexlab.GetPlayerController()
	if _thread
		_thread.AdvanceStage(Input.IsKeyPressed( GetModSettingInt("spf_slso","iModifierHotkey:Main") ))
	endif
EndEvent
;
;Event OnKeyDown(Int KeyCode)
;	int i = 0
;	sslThreadController _thread =  Sexlab.GetPlayerController()
;	_thread.ResetScene(_thread.GetActiveScene())
;	;while i < 9
;	;	_thread.AdvanceStage(true)
;	;	i+= 1
;	;endwhile
;EndEvent

Function PlayerStart(Form FormRef, int tid)
	playerIsAllowedToOrgasm = true
	_updateTimer = GetModSettingFloat("spf_slso","fUpdateInterval:Main")
	MagickaCost = GetModSettingInt("spf_slso","fMagickaCost:Main") as int
;	if GetModSettingBool("spf_slso","bGoBack:Main")
;		RegisterForKey(57)
;	endif
	lastTarget = ""

endFunction

;Event PlayerAnimChange(int aiThreadID, bool abHasPlayer)
;	if abHasPlayer
;		sslThreadController _thread =  Sexlab.GetPlayerController()
;		string[] text_arr =  SexLabRegistry.GetSTageTags(_thread.getactivescene(), _thread.GetActiveStage())
;		string text_out = ""
;		int i = text_arr.length
;		while i > 0
;			i -= 1
;			if text_arr[i] == "Anal" || text_arr[i] == "Vaginal" || text_arr[i] == "Oral"
;					text_out += text_arr[i] +" "
;			endif
;		endwhile
;		if text_out == ""
;			text_out = "N/A"
;		endif
;		int StageCount = SexLabRegistry.GetPathMax(   _thread.getactivescene()  , "").Length
;		int Stage_in = StageCount   - SexLabRegistry.GetPathMax(_thread.getactivescene() ,_thread.GetActiveStage()).Length + 1
;		String add_text = " " + Stage_in  + "/" + StageCount + " "
;
;		Debug.Notification(add_text + text_out)
;		lastTarget = text_out
;	endif
;EndEvent

Function PlayerEnd(Form FormRef, int tid)
	UnRegisterForKey(57)
endFunction

string Function GetCumTarget(string scene_id) global
	int stage_nums = SexLabRegistry.GetPathMax(  scene_id, "").Length
	string text_out =  "->"
	if stage_nums!=5
		text_out = "|" + stage_nums + text_out 
	endif
	int i = 3
	string[] targets_of = new string[3]
	targets_of[0] = "Anal"
	targets_of[1] = "Vaginal"
	targets_of[2] = "Oral"
	while i > 0
		i -= 1
		if SexlabRegistry.IsSceneTag(scene_id, targets_of[i])
			text_out += StringUtil.getNthChar(targets_of[i],0) +" "
		endif
	endwhile
	return text_out
endFunction


string Function GetCumTargetUnFormatted(string scene_id)
	string text_out = ""
	string[] targets_of = new string[3]
	targets_of[0] = "Anal"
	targets_of[1] = "Vaginal"
	targets_of[2] = "Oral"
	int i = 3
	while i > 0
		i -= 1
		if SexlabRegistry.IsSceneTag(scene_id, targets_of[i])
			text_out += targets_of[i] +"|"
		endif
	endwhile
	return text_out	
endFunction


Function Maintenance()
	RegisterForModEvent("PlayerTrack_Start", "PlayerStart")
	RegisterForModEvent("PlayerTrack_End", "PlayerEnd")
	;RegisterForModEvent("HookStageStart", "PlayerAnimChange")
EndFunction

Function OpenListMenuSelection()
    sslThreadController _thread =  Sexlab.GetPlayerController()
	SexLabThread cur_thread = Sexlab.GetThreadByActor(PlayerRef)


	sslThreadController cur_con = Sexlab.GetPlayerController()
	if !cur_thread 
		return none
	endif
	bool con = cur_Thread.GetSubmissive(PlayerRef)
    b612_SelectList mySelectList = GetSelectList()
    String[] myItems = StringUtil.Split("Change Animation;Cum Outside;Cum Inside->;Edging;Disavow;Stop!",";")
    if con
		myItems[4] = "Avow"
    endif
	if !playerIsAllowedToOrgasm
		myItems[3] = "Stop Edging"
	endif
    Int result
    if Input.IsKeyPressed( GetModSettingInt("spf_slso","iModifierHotkey:Main") )
        result = lastUsed
    else
        result = mySelectList.Show(myItems)
        if result > -1
            lastUsed = result
        endif
    endif

    if result == 0
		actionChangeAnim()
	elseif result == 1
        String[] asScenes = SexLabRegistry.LookupScenesA( _thread.GetPositions()  , "AirCum", _thread.GetSubmissives(), 0, none )
		cumOutside = true
        _thread.ResetScene(asScenes[Utility.RandomInt(0, asScenes.Length)])
    elseif result == 2
		String[] myTargets = StringUtil.Split("Vaginal;Anal;Oral",";")
		currentTarget = myTargets[mySelectList.Show(myTargets)]
        String[] asScenes = SexLabRegistry.LookupScenesA( _thread.GetPositions()  , "-AirCum, "+currentTarget,  _thread.GetSubmissives(), 0, none )
		cumOutside = false
        _thread.ResetScene(asScenes[Utility.RandomInt(0, asScenes.Length)])
    elseif result == 3
		EdgyStopOrgasm()
		RegisterForSingleUpdate(_updateTimer)
    elseif result == 4
        cur_Thread.SetIsSubmissive(PlayerRef, !con)
		String[] asScenes = SexLabRegistry.LookupScenesA( _thread.GetPositions()  , currentTarget,  _thread.GetSubmissives(), 0, none )
		_thread.ResetScene(asScenes[Utility.RandomInt(0, asScenes.Length)])
    elseif result == 5
        _thread.EndAnimation()
    EndIf
EndFunction


Function EdgyStopOrgasm()
    sslThreadController _thread =  Sexlab.GetPlayerController()
    if _thread
        sslActorAlias playeralias = _thread.ActorAlias(PlayerRef)
        bool is_allowed = TogglePlayerOrgasmAllowed(_thread)
    endif
EndFunction

Function actionChangeAnim()
    sslThreadController _thread =  Sexlab.GetPlayerController()
	SexLabThread cur_thread = Sexlab.GetThreadByActor(PlayerRef)
	
	UIListMenu ListMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	string cur_sc = cur_thread.GetActiveScene()
	string cur_name = SexlabRegistry.GetSceneName(cur_sc)
	string[] scenenames = cur_Thread.GetPlayingScenes()
	if !cumOutside && currentTarget != ""
		scenenames =  SexLabRegistry.LookupScenesA( _thread.GetPositions()  , "-AirCum, "+currentTarget,  _thread.GetSubmissives(), 0, none )
	elseif cumOutside
		scenenames =  SexLabRegistry.LookupScenesA( _thread.GetPositions()  , "AirCum",  _thread.GetSubmissives(), 0, none )
	endif

	int num = scenenames.Length
	int i = 0
	int offset = 0
	if num > 14
		offset = 7
	endif
	int curr = scenenames.find(cur_sc )
	;Debug.Messagebox(curr + cur_name + curr % num)
	while i < num - 1
		int cursed_i = (i + curr - offset) % num
		string c_n =  SexlabRegistry.GetSceneName(scenenames[cursed_i])		
		if c_n == cur_name
			c_n = ">>> " + c_n
		endif
		if StringUtil.getLength(c_n)>35
			c_n = StringUtil.substring( c_n, 0, 30) + "..."
		endif
		string cum_t = GetCumTarget( scenenames[cursed_i] )
		ListMenu.AddEntryItem(c_n + cum_t )
		i+=1
		
	endwhile
	ListMenu.OpenMenu()
	Int Selected = ListMenu.GetResultInt()
	if Selected>=0
		cur_thread.ResetScene(scenenames[(Selected+curr-offset) % num])
	endif
	
EndFunction


Event OnUpdate()
    sslThreadController _thread =  Sexlab.GetPlayerController()
    if _thread
        bool was_allowed = _thread.IsOrgasmAllowed(PlayerRef)
        if !was_allowed && _thread.GetEnjoyment(PlayerRef) > 90
            PlayerRef.DamageActorValue("Magicka", _updateTimer * (10 as float) )
            if PlayerRef.GetAV("Magicka") < 10
                TogglePlayerOrgasmAllowed(_thread)
            endif
        endif
    endif
	RegisterForSingleUpdate(_updateTimer)
EndEvent

bool Function TogglePlayerOrgasmAllowed(sslThreadController _thread)
	bool was_allowed = playerIsAllowedToOrgasm
	playerIsAllowedToOrgasm = !playerIsAllowedToOrgasm
    _thread.DisableOrgasm(PlayerRef, was_allowed)
    if was_allowed
        GetAnnouncement().Show("No... not yet.", "icon.dds", aiDelay = 2.0)
    else
        GetAnnouncement().Show("Can't hold back!", "icon.dds", aiDelay = 2.0)
    endif
    return !was_allowed

EndFunction


