unit pobierak.settings;
{ Copyright (c) 2026 CelularBat
  Licensed under GPLv3: https://www.gnu.org/licenses/gpl-3.0.html }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Forms, Dialogs,StdCtrls;

type
  TCustomFormatString = record
    CustomString: string;
    Description: string;
  end;

type
  TCustomFormatArray = array of TCustomFormatString;

type
  TGlobalSettings = Record
  G_Proxy, G_Browser, G_CookieDir, G_JsRuntime, G_JsDir: string;
  G_JsIdx: shortint;
  G_JsEnabled, G_CookieEnabled: Boolean;
  end;

type
  TMySettings = class
    constructor Create();
  const
    sc_DEFAULT_OUTPUT_FORMAT = '"%(uploader)s/%(title)s.%(ext)s"';
  var
    s_YTdl_PATH: ansistring;
    s_FFMPG_FOLDER: ansistring;
    s_OutputFolder: ansistring;
    s_Proxy: ansistring;
    s_Cookiedir: ansistring;
    s_JSruntimedir: ansistring;
    s_CustomOutputIdx: integer;
    s_BrowserIdx: integer;
    s_JSruntimeIdx: integer;
    s_UseCustomOutput: boolean;
    s_UseCookie: boolean;
    s_SetJSruntime: boolean;
    sg_AreDepsSet: boolean;

    s_CustomFormatStrings: TCustomFormatArray;
    s_CustomCommandsStrings: TCustomFormatArray;
    s_CustomOutputsStrings: TCustomFormatArray;

  public
    procedure SaveCustomAVList();
    procedure SaveCustomCommands();
    procedure SaveCustomOutputs();
    function CustomFormatsToStrings(const arr: TCustomFormatArray): TStringArray;
    procedure UpdateComboBox_WithCFA(aComboBox: TComboBox; const CustomFormats: TCustomFormatArray);

    function LoadSettings(): boolean;
    procedure SaveSettings();

    function ParseSettingsArgs(igoreOutputFormat: boolean = False): ansistring;

    function GetINIPath(): string;

  private
    procedure Autodetect();


    procedure _ReadFromINI(iniPath: string);
    procedure _WriteToINI(iniPath: string);
    function _RemoveTrailingBackslash(const S: string): string;

    function _MaskQuotes(const AValue: string): string;
    function _UnmaskQuotes(const AValue: string): string;

    procedure _LoadCustomFormats(const iniPath: string;
      const sectionName: string; var arr: TCustomFormatArray);
    procedure _SaveCustomFormats(const iniPath: string;
      const sectionName: string; var arr: TCustomFormatArray);

  end;



var
  g_PobierakSettings: TMySettings;
  AppGlobalSettings: TGlobalSettings;

const
  INIFILE_NAME = 'PobierakYT_Settings.ini';
  YTDLP_EXE = 'yt-dlp.exe';
  FFMPEG_EXE = 'ffmpeg.exe';
  DEPS_FOLDER = 'PobierakYT-dependencies';


implementation

constructor TMySettings.Create();
begin
  s_YTdl_PATH := '';
  s_FFMPG_FOLDER := '';
  s_OutputFolder := '';
  s_Cookiedir := '';
  s_OutputFolder := '';
  s_JSruntimedir := '';
  s_Proxy := '';

  s_UseCustomOutput := False;

  LoadSettings();
end;



procedure TMySettings.Autodetect();
var
  ytDlpPath_App, ytDlpPath_Deps: string;
  appPath, depsPath: string;
  ffmpegPath_App, ffmpegPath_Deps: string;
begin

  appPath := ExtractFilePath(Application.ExeName);
  depsPath := IncludeTrailingPathDelimiter(appPath + DEPS_FOLDER);

  // --- Autodetect yt-dlp.exe ---
  // Only run detection if the path is not already set
  if s_YTdl_PATH = '' then
  begin
    ytDlpPath_App := appPath + YTDLP_EXE;
    ytDlpPath_Deps := depsPath + YTDLP_EXE;
    // 1. Check in the same folder as the application
    if FileExists(ytDlpPath_App) then
    begin
      s_YTdl_PATH := ytDlpPath_App;
    end
    // 2. Check in the 'Pobierak-deps' subfolder
    else if DirectoryExists(depsPath) and FileExists(ytDlpPath_Deps) then
    begin
      s_YTdl_PATH := ytDlpPath_Deps;
    end;
  end;

  // --- Autodetect ffmpeg.exe ---
  // Only run detection if the folder is not already set
  if s_FFMPG_FOLDER = '' then
  begin
    ffmpegPath_App := appPath + FFMPEG_EXE;
    ffmpegPath_Deps := depsPath + FFMPEG_EXE;

    // 1. Check in the same folder as the application
    if FileExists(ffmpegPath_App) then
    begin
      s_FFMPG_FOLDER := _RemoveTrailingBackslash(appPath);
    end
    // 2. Check in the 'Pobierak-deps' subfolder
    else if DirectoryExists(depsPath) and FileExists(ffmpegPath_Deps) then
    begin
      s_FFMPG_FOLDER := _RemoveTrailingBackslash(depsPath);
    end;
  end;
end;

function TMySettings.GetINIPath(): string;
var
  appPath: string;
begin
  appPath := ExtractFilePath(Application.ExeName);
  Result := appPath + INIFILE_NAME;
end;

function TMySettings.LoadSettings(): boolean;
var
  iniPath: string;
begin
  iniPath := GetINIPath();
  Result := False;
  if FileExists(iniPath) then
  begin
    _ReadFromINI(iniPath);
    // Custom lists
    _LoadCustomFormats(iniPAth, 'CustomAVFormats', s_CustomFormatStrings);
    _LoadCustomFormats(iniPAth, 'CustomCommands', s_CustomCommandsStrings);
    _LoadCustomFormats(iniPAth, 'CustomOutputs', s_CustomOutputsStrings);
    Result := True;
  end;
  Autodetect();

end;

procedure TMySettings._ReadFromINI(iniPath: string);
var
  Ini: TIniFile;
  tempPath: string;
begin
  Ini := TIniFile.Create(iniPath);
  
  tempPath := Ini.ReadString('Main', 'YTdl_PATH', '');
  if FileExists(tempPath) then
	s_YTdl_PATH := tempPath
  else
	ShowMessage('File yt-dlp: '+tempPath+' does not exist!');
	
  tempPath := Ini.ReadString('Main', 'FFMPG_FOLDER', '');
  if DirectoryExists(tempPath) then
	s_FFMPG_FOLDER := tempPath
  else
	ShowMessage('Directory FFMPEG '+tempPath+' does not exist!');
	
  tempPath := Ini.ReadString('Main', 'OutputFolder', '');
  if DirectoryExists(tempPath) then
	s_OutputFolder := tempPath
  else if tempPath <> '' then
	ShowMessage('Directory output '+tempPath+' does not exist!');

  tempPath := Ini.ReadString('Main', 'Cookiedir', '');
      if DirectoryExists(tempPath) then
      begin
	s_Cookiedir := tempPath;
        AppGlobalSettings.G_CookieDir := tempPath;
      end;

  tempPath := Ini.ReadString('Main', 'JSruntimedir', '');
      if DirectoryExists(tempPath) then
      begin
	s_JSruntimedir := tempPath;
        AppGlobalSettings.G_JsDir:= tempPath;
      end;

  s_Proxy := Ini.ReadString('Main', 'Proxy', '');
  AppGlobalSettings.G_Proxy := Ini.ReadString('Main', 'Proxy', '');
  s_CustomOutputIdx := Ini.ReadInteger ('Main', 'CustomOutputIdx', -1);
  s_BrowserIdx := Ini.ReadInteger ('Main', 'BrowserIdx', -1);
  s_JSruntimeIdx := Ini.ReadInteger ('Main', 'JSruntimeIdx', -1);
  AppGlobalSettings.G_JsIdx := Ini.ReadInteger ('Main', 'JSruntimeIdx', -1);
  s_UseCustomOutput := Ini.ReadBool ('Main', 'UseCustomOutput', False);
  s_UseCookie := Ini.ReadBool ('Main', 'UseCookie', False);
  s_SetJSruntime := Ini.ReadBool ('Main', 'SetJSruntime', False);
  AppGlobalSettings.G_CookieEnabled := Ini.ReadBool ('Main', 'UseCookie', False);
  AppGlobalSettings.G_JsEnabled := Ini.ReadBool ('Main', 'SetJSruntime', False);
  Ini.Free();
end;

procedure TMySettings._WriteToINI(iniPath: string);
var
  Ini: TMemIniFile;
begin
  try
    try
      Ini := TMemIniFile.Create(iniPath);
      Ini.WriteString('Main', 'YTdl_PATH', s_YTdl_PATH);
      Ini.WriteString('Main', 'FFMPG_FOLDER', s_FFMPG_FOLDER);
      Ini.WriteString('Main', 'OutputFolder', s_OutputFolder);
      Ini.WriteString('Main', 'Proxy', s_Proxy);
      Ini.WriteString('Main', 'Cookiedir', s_Cookiedir);
      Ini.WriteString('Main', 'JSruntimedir', s_JSruntimedir);
      Ini.WriteInteger('Main', 'CustomOutputIdx', s_CustomOutputIdx);
      Ini.WriteInteger('Main', 'BrowserIdx', s_BrowserIdx);
      Ini.WriteInteger('Main', 'JSruntimeIdx', s_JSruntimeIdx);
      Ini.WriteBool ('Main', 'UseCustomOutput', s_UseCustomOutput);
      Ini.WriteBool ('Main', 'UseCookie', s_UseCookie);
      Ini.WriteBool ('Main', 'SetJSruntime', s_SetJSruntime);
      Ini.UpdateFile();
    except
      on E: Exception do
      begin
        ShowMessage('Error saving settings in INI file: ' + iniPath +
          '  ' + E.Message);
      end;
    end;

  finally
    if Assigned(Ini) then
      Ini.Free;
  end;

end;

procedure TMySettings.SaveSettings();
var
  iniPath: string;
begin
  iniPath := GetINIPath();
  _WriteToINI(iniPath);
end;

function TMySettings.ParseSettingsArgs(igoreOutputFormat: boolean = False): ansistring;
begin
  Result := ' --ffmpeg-location "' + s_FFMPG_FOLDER + '"';
  if (s_OutputFolder.Length > 1) then
    Result += ' -P "' + s_OutputFolder + '"';
  if ((not igoreOutputFormat) and (s_UseCustomOutput and (s_CustomOutputIdx > -1)
     and (Length(s_CustomOutputsStrings[s_CustomOutputIdx].CustomString)>0)) )then
    Result += ' -o ' + s_CustomOutputsStrings[s_CustomOutputIdx].CustomString;

end;

function TMySettings._RemoveTrailingBackslash(const S: string): string;
begin
  Result := S;
  if (Length(Result) > 0) and ((Result[Length(Result)] = '\') or
    (Result[Length(Result)] = '/')) then
    Delete(Result, Length(Result), 1);
end;

////// Replacing quotes in ini with another symbol:
const _QUOTE_MASK = '§';

function TMySettings._MaskQuotes(const AValue: string): string;
begin
  Result := StringReplace(AValue, '"', _QUOTE_MASK, [rfReplaceAll]);
end;

function TMySettings._UnmaskQuotes(const AValue: string): string;
begin
  Result := StringReplace(AValue, _QUOTE_MASK, '"', [rfReplaceAll]);
end;

procedure TMySettings._SaveCustomFormats(const iniPath: string;
  const sectionName: string; 
  var arr: TCustomFormatArray);
var
  i: integer;
  section: string;
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(iniPath);
  try
    Ini.EraseSection(sectionName);
    Ini.WriteInteger(sectionName, 'Count', Length(arr));

    for i := 0 to High(arr) do
    begin
      section := sectionName + '_' + IntToStr(i);
      Ini.WriteString(section, 'CustomString', _MaskQuotes(arr[i].CustomString));
      Ini.WriteString(section, 'Description', _MaskQuotes(arr[i].Description));
    end;
  finally
    Ini.Free;
  end;
end;


procedure TMySettings._LoadCustomFormats(const iniPath: string;
  const sectionName: string; var arr: TCustomFormatArray);
var
  i, Count: integer;
  section: string;
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(iniPath);
  try
    Count := Ini.ReadInteger(sectionName, 'Count', 0);
    SetLength(arr, Count);

    for i := 0 to Count - 1 do
    begin
      section := sectionName + '_' + IntToStr(i);
      arr[i].CustomString := _UnmaskQuotes (Ini.ReadString(section, 'CustomString', ''));
      arr[i].Description := _UnmaskQuotes (Ini.ReadString(section, 'Description', ''));
    end;
  finally
    Ini.Free;
  end;
end;

procedure TMySettings.SaveCustomAVList();
var
  iniPath: string;
begin
  iniPath := GetINIPath();
  _SaveCustomFormats(iniPath, 'CustomAVFormats', s_CustomFormatStrings);
end;

procedure TMySettings.SaveCustomCommands();
var
  iniPath: string;
begin
  iniPath := GetINIPath();
  _SaveCustomFormats(iniPath, 'CustomCommands', s_CustomCommandsStrings);
end;

procedure TMySettings.SaveCustomOutputs();
var
  iniPath: string;
begin
  iniPath := GetINIPath();
  _SaveCustomFormats(iniPath, 'CustomOutputs', s_CustomOutputsStrings);
end;



function TMySettings.CustomFormatsToStrings(const arr: TCustomFormatArray): TStringArray;
var
  i, j, Count: integer;
begin
  // counting non-empty elements
  Count := 0;
  for i := 0 to High(arr) do
    if arr[i].CustomString <> '' then
      Inc(Count);

  SetLength(Result, Count);

  j := 0;
  for i := 0 to High(arr) do
    if arr[i].CustomString <> '' then
    begin
      Result[j] := arr[i].CustomString + ' #(' + arr[i].Description + ')';
      Inc(j);
    end;
end;

procedure TMySettings.UpdateComboBox_WithCFA(aComboBox: TComboBox;
  const CustomFormats: TCustomFormatArray);
var
  strs: TStringArray;
begin

  strs := g_PobierakSettings.CustomFormatsToStrings(CustomFormats);
  aComboBox.Items.Clear;
  aComboBox.Items.AddStrings(strs);

  if Length(strs) > 0 then
    aComboBox.ItemIndex := 0
  else
    aComboBox.Text:='';


end;



end.
