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
      var s_CustomOutput :ansistring;
      var s_UseCustomOutput : boolean;
      function GetINIPath() : string;
      function ParseSettingsArgs(args:ansistring) : ansistring;
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
  s_CustomOutput := Ini.ReadString('Main', 'CustomOutput', '');
  s_UseCustomOutput := StrtoBool (Ini.ReadString('Main', 'UseCustomOutput', 'False'));
  Ini.Free();
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
        Ini.WriteString('Main', 'CustomOutput', s_CustomOutput);
        Ini.WriteString('Main', 'UseCustomOutput', BoolToStr(s_UseCustomOutput,TRUE));
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

procedure TMySettings.SaveSettings();
var iniPath : string;
begin
   iniPath := GetINIPath();
   WriteToINI(iniPath);
end;

function TMySettings.ParseSettingsArgs(args:ansistring) : ansistring;
begin
  Result := args+' --ffmpeg-location "'+ s_FFMPG_FOLDER+'"';
  if (s_OutputFolder.Length > 1) then
     Result += ' -P "' +s_OutputFolder + '"' ;
  if (s_UseCustomOutput and (s_CustomOutput.Length > 1)) then
     Result += ' -o "'+s_CustomOutput+'"';

end;

end.

