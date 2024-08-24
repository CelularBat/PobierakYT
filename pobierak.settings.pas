unit pobierak.settings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Forms, Dialogs;

type TMySettings = class
      Constructor Create();
      var s_YTdl_PATH : ansistring;
      var s_FFMPG_FOLDER : ansistring;
      var s_OutputFolder : ansistring;
      function GetINIPath() : string;
      function ParseYTArgs(args:ansistring) : ansistring;
      function LoadSettings() : boolean;
      procedure ReadFromINI(iniPath :string);
      procedure SaveSettings();
      procedure WriteToINI(iniPath :string);

end;

var g_PobierakSettings : TMySettings;
const INIFILE_NAME = 'PobierakYT_Settings.ini';


implementation

Constructor TMySettings.Create();
begin
end;

function TMySettings.GetINIPath() : string;
var appPath : string;
begin
     appPath := ExtractFilePath(Application.ExeName);
     Result := appPath+INIFILE_NAME;
end;

function TMySettings.LoadSettings() : boolean;
var iniPath : string;
begin
   iniPath := GetINIPath();
   Result := false;
   if FileExists(iniPath) then
   begin
        ReadFromINI(iniPath);
        Result := true;
   end;

end;

procedure TMySettings.ReadFromINI(iniPath :string);
var Ini :TIniFile;
begin
  Ini := TIniFile.Create(iniPath);
  s_YTdl_PATH := Ini.ReadString('Main','YTdl_PATH','');
  s_FFMPG_FOLDER := Ini.ReadString('Main','FFMPG_FOLDER','');
  s_OutputFolder := Ini.ReadString('Main', 'OutputFolder', '');
  Ini.Free();
end;

procedure TMySettings.SaveSettings();
var iniPath : string;
begin
   iniPath := GetINIPath();
   WriteToINI(iniPath);

end;

procedure TMySettings.WriteToINI(iniPath :string);
var Ini :TMemIniFile;

begin
   try
      try
        Ini := TMemIniFile.Create(iniPath);
        Ini.WriteString('Main','YTdl_PATH',s_YTdl_PATH);
        Ini.WriteString('Main','FFMPG_FOLDER',s_FFMPG_FOLDER);
        Ini.WriteString('Main', 'OutputFolder', s_OutputFolder);
        Ini.UpdateFile();
      except
          on E: Exception do
          begin
             ShowMessage('Error saving settings in INI file: '+iniPath+ '  ' + E.Message);
          end;
      end;

  finally
    if Assigned(Ini) then
        Ini.Free;
  end;

end;

function TMySettings.ParseYTArgs(args:ansistring) : ansistring;
begin
  Result := args+' --ffmpeg-location "'+ s_FFMPG_FOLDER+'"' + ' -P "' +s_OutputFolder + '"' ;

end;

end.

