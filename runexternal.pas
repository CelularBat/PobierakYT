unit RunExternal;

{$mode ObjFPC}{$H+}

interface

uses
 {$ifdef unix}cthreads,{$endif} Classes, SysUtils,Process,Dialogs,debugUtils;
{TO DO:
 *   procedure Run(); change to func():boolean ,with check if exe file exist.

}


{ Run external application ( in new TProcess )  and store output in TStream ( copping is done in new Thread ). You can get output anytime you want.


// Example for writing output in real-time.

var RE : TRunExternal;
var strBuff : string;
begin
      RE := TRunExternal.Create(PATH,ARGS);
      RE.Run();                                    // now process runs asynchronously in another thread

                                                   // to get process output:
      while ( not RE.IsStreamFinished() ) do begin
          if RE.ReadOutputChunk(1000,strBuff ) then writeln(strBuff);
          sleep(500);
      end;
end;

// Or wait till process is finished and it's Output copied to Stream, and then grab all output at once

var RE : TRunExternal;

begin
      RE := TRunExternal.Create(PATH,ARGS);
      RE.Run();                                    // now process runs asynchronously in another thread

                                                   // to get process output:
      while ( not RE._PipeFinished  ) do begin
          sleep(500);
      end;

      writeln(ReadOutputAll());
end;

}

type TStreamThread = class;

type TRunExternal = class

     public
     constructor Create(path : string; args :string);
     destructor Destroy(); override;
     procedure Run();

     function ReadOutputAll(var OutBuffer): LongInt;
     function ReadOutputAll(): string; overload;

     function ReadOutputChunk(var OutBuffer;  Count: LongInt): LongInt;
     function ReadOutputChunk(Count: LongInt; var ResultString : string): boolean; overload;
     function IsStreamFinished() : Boolean; // Stream is finished when you've read the last chunk of data using ReadOutputChunk(). WARNING: Calling ReadOutputAll() doesn't make it finished.
     function IsProcessFinished() : Boolean;

     public

     StreamPosTracker : LongInt; // This tracks position in Stream at which last ReadOutputChunk() ended. In this class it's used for reading from Stream to Main application
                                 // it's different from TStream.position, which is changed by TStream.Write/Read calls and in this class used internally for writing from Process Output to Stream
     Updated : Boolean; // This flag informs if a new input was loaded into the stream since the last read() function.

     _PipeFinished : Boolean;   // It's TRUE when all Process Output was loaded into Stream ; and Process is not running
     //private
     _Proc : TProcess;
     _CriticalSection: TRTLCriticalSection;
     _Stream : TMemoryStream;
     _Thread : TStreamThread;



end;

type TStreamThread = class(TThread)
     procedure Execute(); override;
     Constructor Create(CreateSuspended : boolean; var RunExternal : TRunExternal);
     private
     RE : TRunExternal;
end;


implementation

Constructor  TRunExternal.Create(path : string; args :string);
begin
     _Stream := TMemoryStream.Create; // Stream for holding process output
     _Proc := TProcess.Create(nil);
     _Thread := TStreamThread.Create(TRUE , self );
     InitCriticalSection(_CriticalSection);

     _Proc.Executable := path;
     _Proc.Parameters.Add(args);
     _Proc.Options := [poUsePipes , poStderrToOutPut];
     _Proc.ShowWindow:=swoHide;
     StreamPosTracker := 0;
end;

destructor TRunExternal.Destroy();
begin
    _Stream.Clear();
    _Stream.Free();
    _Proc.Free();

    //_Thread.Free();   // ?? ACCESS VIOLATION
    DoneCriticalsection(_CriticalSection);

end;

procedure TRunExternal.Run() ;
begin
     _Thread.Start;
end;

function TRunExternal.IsStreamFinished() : Boolean;
begin
     Result := _PipeFinished and  (StreamPosTracker >= _Stream.Position )  ;
end;

function TRunExternal.ReadOutputChunk(var OutBuffer;  Count: LongInt): LongInt;
var tempPosContainer : Int64;
begin
     Result := 0;
     if (StreamPosTracker >= _Stream.Position) then
     begin
          Updated := False;
     end else begin
         EnterCriticalSection(_CriticalSection);
         Try
            tempPosContainer := _Stream.Position;
            _Stream.Seek(StreamPosTracker,soBeginning);
            Result := _Stream.Read(OutBuffer,Count);
            _Stream.Seek(tempPosContainer,soBeginning);
         Finally
            LeaveCriticalSection(_CriticalSection);
            StreamPosTracker := StreamPosTracker + Result;
         end;
     end;
end;


function TRunExternal.ReadOutputChunk(Count: LongInt; var ResultString : string): boolean; overload;
var size:longInt;
var buf : PChar;
begin
     Result := FALSE;
     Updated := False;
     buf := stralloc(count);
     size:= ReadOutputChunk(buf^,Count);
     if size>0 then
     begin
          (buf+size)^ := #0;
          ResultString := '' + buf;

          Result :=TRUE;
     end;

     StrDispose(buf);
end;

function TRunExternal.ReadOutputAll(var OutBuffer): LongInt;
var tempPosContainer : Int64;
begin
     Result := 0;
     EnterCriticalSection(_CriticalSection);
     Try
        tempPosContainer := _Stream.Position;
        _Stream.Seek(0,soBeginning);
        Result := _Stream.Read(OutBuffer,_Stream.Size);
        _Stream.Seek(tempPosContainer,soBeginning);
     Finally
        LeaveCriticalSection(_CriticalSection);
     end;
     Updated := False;
end;

function TRunExternal.ReadOutputAll(): string; overload;
var size:longInt;
var buf : PChar;
begin
     buf := stralloc(_Stream.Size);
     size := ReadOutputAll(buf^);
     Result := '' + buf;
     StrDispose(buf);
end;

function TRunExternal.IsProcessFinished() : Boolean;
begin
     Result := not _Proc.Running;
end;

// ----------------  TStreamThread -------------------

Constructor TStreamThread.Create(CreateSuspended : boolean; var RunExternal : TRunExternal);
begin
     inherited Create(CreateSuspended);
     FreeOnTerminate := True;
     RE := RunExternal;
end;


procedure TStreamThread.Execute();
const
  BUF_SIZE = 2048;
var
  BytesRead : longint;
  Buffer : array[1..BUF_SIZE] of byte;
begin

     try
       RE._Proc.Execute();
     except
           on E: Exception do
           begin
              ShowMessage( 'Error: '+ E.ClassName + #13#10 + E.Message + #13#10 + 'Failed to execute: '+RE._Proc.Executable );
              Exit;
           end;
     end;

      while (not Terminated)and(RE._Proc.Running) do begin
              if RE._Proc.Output.NumBytesAvailable > 0 then begin
                  BytesRead := RE._Proc.Output.Read(Buffer, BUF_SIZE);
                  RE._Stream.Write(Buffer, BytesRead);
                  RE.Updated:=True;

              end;
              sleep(100); // When process is not sending data we are relaxing

              // Now the external process is done. But make sure to check if anything has left in the pipe
              sleep(500);
              if RE._Proc.Output.NumBytesAvailable > 0 then begin
                repeat
                  BytesRead := RE._Proc.Output.Read(Buffer, BUF_SIZE);
                  RE._Stream.Write(Buffer, BytesRead);
                  sleep(50);
                ///  Showmessage(ByteArrayToHexString(Buffer,' '));
                until RE._Proc.Output.NumBytesAvailable = 0;
                RE.Updated:=True;
              end;
      end;
      RE._PipeFinished := True;

end;

begin
end.
