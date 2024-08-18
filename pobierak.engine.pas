unit pobierak.Engine;

{$mode ObjFPC}{$H+}

interface

uses
  {$ifdef unix}cthreads,{$endif} Classes, SysUtils, StdCtrls, pobierak.settings,copyttab,ComCtrls,dialogs,memothread
  ;

type TJobTab = record
   idx : integer;
   memo: TMemo;
   memoThr:TMemoThr;
   isWorking: boolean;
end;

type TJobTabArray = array of TJobTab;


var g_JobTabs : TJobTabArray;
var g_UniqueTabID : integer;


function RunInNewTab(  ARGS : string; var PageControl :TPageControl; newName :string ) : boolean;


implementation



function RunInNewTab(  ARGS : string; var PageControl :TPageControl; newName :string ) : boolean;
var
  fullName : string;
  page :TTabSheet;
  m :Tmemo;
  MemoThread : TMemoThr;
  l :integer;
begin

     fullName := newName +  inttostr(g_UniqueTabID);
    SpawnNewTab(PageControl,0,fullName,page,m);
    Result := RunWithMemoConsole(m, ARGS,MemoThread);
    l := Length(g_JobTabs);
    SetLength(g_JobTabs,l+1);
    with g_JobTabs[l] do
    begin
      idx := g_UniqueTabID;
      memo := m;
      memoThr := MemoThread;
    end;
    Inc(g_UniqueTabID);

end;



end.

