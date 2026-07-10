unit UOptionsFrame;
{ Copyright (c) 2026 CelularBat
  Licensed under GPLv3: https://www.gnu.org/licenses/gpl-3.0.html }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  LCLIntf, ExtCtrls, Buttons, FileUtil, FileInfo, RegExpr,
  pobierak.settings,pobierak.Engine,
  FolderButtonFrameUnit,CustomFormatsForm,decorator_StaticText_Link;

type

  { TFrameOptions }

    TFrameOptions = class(TFrame)
    btnJsRuntime: TButton;
    btnEditOutputList: TButton;
    btnFFMPG: TButton;
    btnOutputFolder: TButton;
    btnSave: TButton;
    btnInfo: TButton;
    btnYTBinary: TButton;
    chboxJSRuntime: TCheckBox;
    chboxOutputfile: TCheckBox;
    chboxCookie: TCheckBox;
    cmbboxJSRuntimeSel: TComboBox;
    cmbboxOutputTemplate: TComboBox;
    cmbboxBrowserSel: TComboBox;
    edtJsRuntimePath: TEdit;
    edtProxy: TEdit;
    edtOutputFolder: TEdit;
    edtBrowserCookiePath: TEdit;
    edtYtDlpBinary: TEdit;
    edtFFMPGfolder: TEdit;
    FolderButtonFrame1: TFolderButtonFrame;
    GroupBoxPathes: TGroupBox;
    GroupBoxOutput: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    btnUpdateYTdlp: TButton;
    StaticText5: TStaticText;
    procedure btnEditOutputListClick(Sender: TObject);
    procedure btnJsRuntimeClick(Sender: TObject);
    procedure chboxCookieChange(Sender: TObject);
    procedure chboxJSRuntimeChange(Sender: TObject);
    procedure cmbboxBrowserSelChange(Sender: TObject);
    procedure cmbboxJSRuntimeSelChange(Sender: TObject);
    procedure cmbboxOutputTemplateChange(Sender: TObject);
    constructor Create(AOwner: TComponent);
    procedure btnFFMPGClick(Sender: TObject);
    procedure btnOutputFolderClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnYTBinaryClick(Sender: TObject);
    procedure btnInfoClick(Sender: TObject);
    procedure btnUpdateYTdlpClick(Sender: TObject);
    procedure chboxOutputfileChange(Sender: TObject);
    procedure edtBrowserCookiePathExit(Sender: TObject);
    procedure edtProxyExit(Sender: TObject);
    procedure LoadSettingsIntoGUI();

  end;

function DoesFileMaskExistInDir(const ADirectory, AFilenameMask: string): boolean;

implementation

{$R *.lfm}// This links to your UOptionsFrame.lfm file

{ TFrameOptions }

constructor TFrameOptions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  self.LoadSettingsIntoGUI();
  TStaticTextLinkDecorator.Create(StaticText2);
  TStaticTextLinkDecorator.Create(StaticText4);

end;



procedure TFrameOptions.LoadSettingsIntoGUI();
begin
  // Load settings into GUI:

  self.edtFFMPGfolder.Text := g_PobierakSettings.s_FFMPG_FOLDER;
  self.edtYtDlpBinary.Text := g_PobierakSettings.s_YTdl_PATH;
  self.edtOutputFolder.Text := g_PobierakSettings.s_OutputFolder;
  self.edtProxy.Text := g_PobierakSettings.s_Proxy;
  if g_PobierakSettings.s_Cookiedir <> '' then
    begin
      self.edtBrowserCookiePath.Text := g_PobierakSettings.s_Cookiedir;
    end
  else
    begin
      self.edtBrowserCookiePath.Text := 'Browser' + #39 + 's profile directory (optional)';
    end;

  if g_PobierakSettings.s_JSruntimedir <> '' then
    begin
      self.edtJsRuntimePath.Text := g_PobierakSettings.s_JSruntimedir;
    end
  else
    begin
      self.edtJsRuntimePath.Text := 'JS Runtime' + #39 + 's directory (if not placed together with yt-dlp)';
    end;

  self.FolderButtonFrame1.SetFolderPath(g_PobierakSettings.s_OutputFolder);

  self.chboxOutputFile.Checked := g_PobierakSettings.s_UseCustomOutput;
  self.chboxCookie.Checked := g_PobierakSettings.s_UseCookie;
  self.chboxJSRuntime.Checked := g_PobierakSettings.s_SetJSruntime;
  self.GroupBoxOutput.Enabled := g_PobierakSettings.s_UseCustomOutput;
  g_PobierakSettings.UpdateComboBox_WithCFA(cmbboxOutputTemplate,
    g_PobierakSettings.s_CustomOutputsStrings);
  self.cmbboxOutputTemplate.ItemIndex := g_PobierakSettings.s_CustomOutputIdx;
  self.cmbboxBrowserSel.ItemIndex := g_PobierakSettings.s_BrowserIdx;
  self.cmbboxJSRuntimeSel.ItemIndex := g_PobierakSettings.s_JSruntimeIdx;
  AppGlobalSettings.G_Browser := cmbboxBrowserSel.Text;
  AppGlobalSettings.G_JsRuntime := cmbboxJSRuntimeSel.Text;
end;


procedure TFrameOptions.btnYTBinaryClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    if fileExists(OpenDialog1.Filename) then
    begin
      g_PobierakSettings.s_YTdl_PATH := OpenDialog1.Filename;
      edtYtDlpBinary.Text := g_PobierakSettings.s_YTdl_PATH;
    end;
end;

function DoesFileMaskExistInDir(const ADirectory, AFilenameMask: string): boolean;
var
  FoundFiles: TStringList;
begin
  FoundFiles := TStringList.Create;
  try
    // Find all files matching the mask in the specified directory (non-recursive)
    FileUtil.FindAllFiles(FoundFiles, ADirectory, AFilenameMask, False);
    Result := FoundFiles.Count > 0; // Return true if at least one file was found
  finally
    FoundFiles.Free;
  end;
end;

procedure TFrameOptions.btnFFMPGClick(Sender: TObject);
var
  SelectedDir: string;
  FoundFFmpeg: boolean;
  FoundFFprobe: boolean;
begin
  if SelectDirectoryDialog1.Execute then
    if directoryExists(SelectDirectoryDialog1.Filename) then
    begin
      // Ensure the directory path ends with a path delimiter (e.g., '\' on Windows, '/' on Linux)
      SelectedDir := IncludeTrailingPathDelimiter(SelectDirectoryDialog1.Filename);

      FoundFFmpeg := DoesFileMaskExistInDir(SelectedDir, 'ffmpeg*.exe') or
        DoesFileMaskExistInDir(SelectedDir, 'FFMPEG*.exe');

      FoundFFprobe := DoesFileMaskExistInDir(SelectedDir, 'ffprobe*.exe') or
        DoesFileMaskExistInDir(SelectedDir, 'FFPROBE*.exe');

      if (FoundFFmpeg and FoundFFprobe) then
      begin
        g_PobierakSettings.s_FFMPG_FOLDER := SelectDirectoryDialog1.Filename;
        edtFFMPGfolder.Text := g_PobierakSettings.s_FFMPG_FOLDER;
      end
      else   // Check the /bin folder
      begin
        SelectedDir := IncludeTrailingPathDelimiter(SelectDirectoryDialog1.Filename);
        SelectedDir := SelectedDir + 'bin';
        SelectedDir := IncludeTrailingPathDelimiter(SelectedDir);
        FoundFFmpeg := DoesFileMaskExistInDir(SelectedDir, 'ffmpeg*.exe') or
          DoesFileMaskExistInDir(SelectedDir, 'FFMPEG*.exe');
        FoundFFprobe := DoesFileMaskExistInDir(SelectedDir, 'ffprobe*.exe') or
          DoesFileMaskExistInDir(SelectedDir, 'FFPROBE*.exe');
        if (FoundFFmpeg and FoundFFprobe) then
        begin
          g_PobierakSettings.s_FFMPG_FOLDER := SelectedDir;
          edtFFMPGfolder.Text := g_PobierakSettings.s_FFMPG_FOLDER;
        end
        else
        begin
          MessageDlg('The chosen directory does not contain all required files.' +
            LineEnding + 'Please select a directory that contains:' +
            LineEnding + '- ffmpeg.exe (or FFMPEG.exe)' + LineEnding +
            '- ffprobe.exe (or FFPROBE.exe)' + LineEnding,
            mtError, [mbOK], 0);
        end;
      end;

    end;
end;

procedure TFrameOptions.btnOutputFolderClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
    if directoryExists(SelectDirectoryDialog1.Filename) then
    begin
      g_PobierakSettings.s_OutputFolder := SelectDirectoryDialog1.Filename;
      edtOutputFolder.Text := g_PobierakSettings.s_OutputFolder;
      self.FolderButtonFrame1.SetFolderPath(g_PobierakSettings.s_OutputFolder);
    end;
end;

procedure TFrameOptions.btnSaveClick(Sender: TObject);
begin
  g_PobierakSettings.SaveSettings();
  PrintLineConsole('Settings saved at: ' + g_PobierakSettings.GetINIPath());
end;

function GetApplicationVersionString: string;
var
  FileVersionInfo: TFileVersionInfo;
  ProgramVersion: TProgramVersion;
  VersionStr: string;
  GotVersion: boolean;
begin
  GotVersion := GetProgramVersion(ProgramVersion);

  if GotVersion then
  begin
    // Format the numeric version
    VersionStr := ProgramVersionToStr(ProgramVersion);

    FileVersionInfo := TFileVersionInfo.Create(nil); // nil means current application
    try
      FileVersionInfo.FileName := '';
      FileVersionInfo.ReadFileInfo;

      if FileVersionInfo.VersionStrings.Values['ProductName'] <> '' then
        Result := Result + #13#10 + 'Product: ' +
          FileVersionInfo.VersionStrings.Values['ProductName'];
      if FileVersionInfo.VersionStrings.Values['FileDescription'] <> '' then
        Result := Result + ' (' +
          FileVersionInfo.VersionStrings.Values['FileDescription'] + ')';
      Result := Result + #13#10 + 'Version: ' + VersionStr;
      if FileVersionInfo.VersionStrings.Values['CompanyName'] <> '' then
        Result := Result + #13#10 + 'Author: ' +
          FileVersionInfo.VersionStrings.Values['CompanyName'];
      if FileVersionInfo.VersionStrings.Values['InternalName'] <> '' then
        Result := Result + #13#10 + 'Project site: ' +
          FileVersionInfo.VersionStrings.Values['InternalName'];
      if FileVersionInfo.VersionStrings.Values['LegalCopyright'] <> '' then
        Result := Result + #13#10 + 'Licence: ' +
          FileVersionInfo.VersionStrings.Values['LegalCopyright'];

    finally
      FileVersionInfo.Free;
    end;
  end
  else
    Result := 'Version Info Not Available';
end;

procedure TFrameOptions.btnInfoClick(Sender: TObject);
var
  versionString: string;
begin
  versionString := GetApplicationVersionString();
  RunInConsole('--verbose', [versionString, ' ', 'DEPENDENCIES INFORMATION:']);
end;


procedure TFrameOptions.btnUpdateYTdlpClick(Sender: TObject);
var
  response: integer;
begin
  response := MessageDlg('Do you want to auto-update YT-dlp using "yt-dlp -U"',
    mtConfirmation, [mbYes, mbNo], 0);
  if response = mrYes then
    RunTab('-U', 'AutoUpdate');
end;

procedure TFrameOptions.chboxOutputfileChange(Sender: TObject);
begin
  self.GroupBoxOutput.Enabled := self.chboxOutputFile.Checked;

  if (cmbboxOutputTemplate.ItemIndex > -1) then
  begin
    g_PobierakSettings.s_UseCustomOutput := chboxOutputFile.Checked;
  end
  else
  begin
    g_PobierakSettings.s_UseCustomOutput := false;
  end;

end;

procedure TFrameOptions.edtBrowserCookiePathExit(Sender: TObject);
begin
  if directoryExists(edtBrowserCookiePath.Text) then
    AppGlobalSettings.G_CookieDir := edtBrowserCookiePath.Text;
end;

function ProxyValidation(const AText: string): Boolean;
var
  Regex: TRegExpr;
  Pattern: string;
  PortNum: longint;
begin
  Result := False;
  Pattern := '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?):([0-9]{1,5})$';
  Regex := TRegExpr.Create(Pattern);
  try
    if Regex.Exec(AText) then
    begin
      PortNum := StrToIntDef(Regex.Match[4], 0);
      if (PortNum >= 1) and (PortNum <= 65535) then
        Result := True;
    end;
  finally
    Regex.Free;
  end;
end;

procedure TFrameOptions.edtProxyExit(Sender: TObject);
begin
  if ProxyValidation(edtProxy.Text) then
    begin
      g_PobierakSettings.s_Proxy := edtProxy.Text;
      AppGlobalSettings.G_Proxy := edtProxy.Text;
    end
  else
    begin
      ShowMessage('Please check the proxy address in Options tab. Only support IP:Port format (e.g., 127.0.0.1:10001). Adding "http://" or "https://" is not supported');
    end;
end;

procedure TFrameOptions.btnEditOutputListClick(Sender: TObject);
begin
  CustomOutputsForm.ShowModal();
  g_PobierakSettings.UpdateComboBox_WithCFA(cmbboxOutputTemplate,
    g_PobierakSettings.s_CustomOutputsStrings);
end;

procedure TFrameOptions.btnJsRuntimeClick(Sender: TObject);
begin
    if SelectDirectoryDialog1.Execute then
    if directoryExists(SelectDirectoryDialog1.Filename) then
    begin
      edtJsRuntimePath.Text := SelectDirectoryDialog1.Filename;
      g_PobierakSettings.s_JSruntimedir := SelectDirectoryDialog1.Filename;
      AppGlobalSettings.G_JsDir := SelectDirectoryDialog1.Filename;
    end;
end;

procedure TFrameOptions.chboxCookieChange(Sender: TObject);
begin
    if chboxCookie.Checked = true then
     begin
       cmbboxBrowserSel.Enabled := true;
       edtBrowserCookiePath.Enabled := true;
       g_PobierakSettings.s_UseCookie := true;
       AppGlobalSettings.G_CookieEnabled := true;
     end
  else
     begin
       cmbboxBrowserSel.Enabled := false;
       edtBrowserCookiePath.Enabled := false;
       g_PobierakSettings.s_UseCookie := false;
       AppGlobalSettings.G_CookieEnabled := false;
     end;
end;

procedure TFrameOptions.chboxJSRuntimeChange(Sender: TObject);
begin
    if chboxJSRuntime.Checked = true then
     begin
       cmbboxJSRuntimeSel.Enabled := true;
       edtJsRuntimePath.Enabled := true;
       g_PobierakSettings.s_SetJSruntime := true;
       AppGlobalSettings.G_JsEnabled := true;
     end
  else
     begin
       cmbboxJSRuntimeSel.Enabled := false;
       edtJsRuntimePath.Enabled := false;
       g_PobierakSettings.s_SetJSruntime := false;
       AppGlobalSettings.G_JsEnabled := false;
     end;
end;

procedure TFrameOptions.cmbboxBrowserSelChange(Sender: TObject);
begin
  g_PobierakSettings.s_BrowserIdx := cmbboxBrowserSel.ItemIndex;
  AppGlobalSettings.G_Browser := cmbboxBrowserSel.Text;
end;

procedure TFrameOptions.cmbboxJSRuntimeSelChange(Sender: TObject);
begin
  g_PobierakSettings.s_JSruntimeIdx := cmbboxJSRuntimeSel.ItemIndex;
  AppGlobalSettings.G_JsRuntime := cmbboxJSRuntimeSel.Text;
end;

procedure TFrameOptions.cmbboxOutputTemplateChange(Sender: TObject);
begin
    g_PobierakSettings.s_CustomOutputIdx := cmbboxOutputTemplate.ItemIndex;
end;






end.
