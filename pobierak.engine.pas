unit pobierak.Engine;

{$mode ObjFPC}{$H+}

interface

uses
  {$ifdef unix}cthreads,{$endif} Classes, SysUtils, StdCtrls, pobierak.settings,copyttab,ComCtrls,dialogs,controls,memothread
  ;

type TJobTab = Object
   ID : integer; // g_UniqueTabID is assigned at creation, and saved into TJobTab.tab.Tag
   tab:TTabSheet;
   memo: TMemo;
   memoThr:TMemoThr;
   isWorking: boolean;
   isAlive: boolean;
   function closeTab():Boolean;
   procedure ClearMemo();
end;

type TJobTabArray = array of TJobTab;


var g_JobTabs : TJobTabArray;  // this is an array where all tabs are contained. Index in this array = ID
var g_UniqueTabID : integer; // This is tab index counter, which increases when new tab is added


function RunInNewTab(EXE_PATH,  ARGS : string; HEADERS: TStringArray; var PageControl :TPageControl; newName :string ) : boolean;
function RunInNewTab( ARGS : string; var PageControl :TPageControl; newName :string ) : boolean;
function RunInNewTab( ARGS : string; HEADERS: TStringArray; var PageControl :TPageControl; newName :string ) : boolean;

implementation



function RunInNewTab( EXE_PATH, ARGS : string; HEADERS: TStringArray; var PageControl :TPageControl; newName :string ) : boolean;
var
  fullName : string;
  page :TTabSheet;
  m :Tmemo;
  MemoThread : TMemoThr;
  l :integer;
begin

     fullName :='['+inttostr(g_UniqueTabID)+']'+ newName ;
    SpawnNewTab(PageControl,0,fullName,page,m);
    Result := RunWithMemoConsole(m,EXE_PATH, ARGS,MemoThread,HEADERS);

    l := Length(g_JobTabs);
    SetLength(g_JobTabs,l+1);
    with g_JobTabs[l] do
    begin
      ID := g_UniqueTabID;
      memo := m;
      memoThr := MemoThread;
      tab := page;
      isalive := TRUE;
    end;
    page.Tag := g_UniqueTabID;
    Inc(g_UniqueTabID);

end;

function RunInNewTab( ARGS : string; HEADERS: TStringArray; var PageControl :TPageControl; newName :string ) : boolean;
begin
  Result := RunInNewTab( g_PobierakSettings.s_YTdl_PATH , ARGS, HEADERS, PageControl, newName );
end;

function RunInNewTab( ARGS : string; var PageControl :TPageControl; newName :string ) : boolean;
begin
  Result := RunInNewTab( g_PobierakSettings.s_YTdl_PATH , ARGS,[args], PageControl, newName );
end;

procedure TJobTab.clearMemo();
Begin
   self.memo.Lines.clear();
end;

function TJobTab.closeTab():Boolean;
var response : integer;
begin
    Result := TRUE;
    id := self.tab.Tag;
    if (id = -1) then exit; // We don't want to close the main console
    if self.isWorking then
    begin
     response := MessageDlg('Tab is working, stop the job?', mtConfirmation, [mbYes, mbNo], 0);
     if response = mrYes then
        self.memoThr.StopAndTerminate()
     else
       begin
        Result := FALSE;
         exit;
       end;

    end;
    self.tab.Free;
    self.isAlive:= FALSE;
    Result := TRUE;

end;

end.

