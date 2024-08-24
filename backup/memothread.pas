unit MemoThread;

{$mode ObjFPC}{$H+}

// This unit is for running external console application , and writing console output to Tmemo, asychronously, and by not blocking anything.
// it uses RunExternal

// Model: External_Process_Output --> Pipe --> Stream --> TMemo

// Implementation:
// External_Process ( RunExternal._Proc ) ---{ automatically }--> Pipe
// Pipe ---{ RunExternal._Thread copies from Pipe }--> Stream (RunExternal._Stream)
interface

uses
  {$ifdef unix}cthreads,{$endif} Classes, SysUtils, StdCtrls, RunExternal, pobierak.settings,copyttab,ComCtrls,dialogs,LazUTF8;

type
 TMemoThr = class(TThread)
     procedure Execute; override;
     Constructor Create( var Memo : Tmemo; var RunExternal :TRunExternal);

     public
     MyMemo : Tmemo;
     RE :TRunExternal;
     isTaskFinished :boolean;

     function _DebugState (showMessage : boolean) : string;
     procedure StopAndTerminate();
 end;

function RunWithMemoConsole(var Memo : Tmemo; EXE_PATH , ARGS : string; out MemoThr : TMemoThr; HEADERS: TStringArray) : boolean;
function RunWithMemoConsole(var Memo : Tmemo; EXE_PATH , ARGS : string;  out MemoThr : TMemoThr) : boolean; overload;
//function RunWithMemoConsole(var Memo : Tmemo; ARGS: string; out MemoThr : TMemoThr) : boolean;  overload;    // customized for PobierakYT


implementation


 ///////// TMemo handling section

constructor TMemoThr.Create(var Memo : Tmemo; var RunExternal :TRunExternal);
begin
  inherited Create(True);
  RE := RunExternal;
  MyMemo := Memo;
  isTaskFinished := False;
  FreeOnTerminate := True;
  MyMemo.Lines.Options:=[];
end;

procedure TMemoThr.Execute();
var tempBuffer : string;
begin
      while (not Terminated)and(not RE.IsStreamFinished()) do begin
           if (RE.Updated)or(RE._PipeFinished) then
           begin
               if RE.ReadOutputChunk(4096,tempBuffer) then
                  //MyMemo.Lines.AddText (tempBuffer);  // this way it adds new line at the end every time.
                    MyMemo.Text := MyMemo.Text + WinCPToUTF8(tempBuffer); //  yt-dlp output is encoded in local CodePage, so must be converted
           end;

           sleep(200);
      end;
      if RE.IsStreamFinished() then RE.Free();

      MyMemo.Lines.Add ('');
      MyMemo.Lines.Add ('< ...Task finished >');
      isTaskFinished := True;
      self.Free;
end;

function TMemoThr._DebugState (showMessage : boolean) : string;
begin
  Result := 'Is Process finished: ' + booltostr( RE.IsProcessFinished() ,true );
  Result += #13#10 +'Is Stream finished: ' + booltostr( RE.IsStreamFinished () ,true);
  Result += #13#10 +'Is Pipe finished: ' + booltostr( RE._PipeFinished ,true);
  Result += #13#10 +'RE Pos Tracker: ' + inttostr( RE.StreamPosTracker );

end;

procedure tMemoThr.StopAndTerminate();
begin
  self.Re.Destroy();
  self.Terminate();
end;

function RunWithMemoConsole(var Memo : Tmemo; EXE_PATH , ARGS : string;  out MemoThr : TMemoThr; HEADERS: TStringArray) : boolean;
  var RE : TRunExternal;
  var i:integer;
begin
       Memo.Lines.Add('< Starting new task... >');
       for i:=0 to Length(HEADERS)-1 do
           Memo.Lines.Add(HEADERS[i]);
       Memo.Lines.Add('');

       Result := False;
       try
         RE := TRunExternal.Create(EXE_PATH,ARGS);
         RE.Run();
         MemoThr:= TmemoThr.Create(Memo,RE);
         MemoThr.Start();
         Result := True;
       except
         on E: Exception do
            begin
              Memo.Lines.Add('< RunWithMemoConsole() Error: ' + E.Message + ' >');
              Re.Destroy();
              MemoThr.Terminate();
              Exit;
            end;
       end;

end;

function RunWithMemoConsole(var Memo : Tmemo; EXE_PATH , ARGS : string;  out MemoThr : TMemoThr) : boolean; overload;
begin
    Result := RunWithMemoConsole(Memo, EXE_PATH, ARGS, MemoThr, []);
end;

begin
   Result := RunWithMemoConsole(Memo, Options.s_YTdl_PATH, Options.ParseYTArgs(args), MemoThr);
end;

end.
