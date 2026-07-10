unit UVideosFrame;
{ Copyright (c) 2026 CelularBat
  Licensed under GPLv3: https://www.gnu.org/licenses/gpl-3.0.html }

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RegExpr, ComCtrls, StdCtrls,
  LCLIntf, LCLType, LCLProc, ExtCtrls, Buttons,
  pobierak.Settings, pobierak.Engine,
  CustomFormatsForm;

type

  { TVideosFrame }

  TVideosFrame = class(TFrame)
    btnDownload: TButton;
    btnEditAVList: TButton;
    btnEditCommandsList: TButton;
    btnFormatData: TButton;
    btnGetInfo: TButton;
    chboxByChapter: TCheckBox;
    chboxThumb: TCheckBox;
    chboxCustomArgs: TCheckBox;
    chboxForceKeyFrames: TCheckBox;
    chboxFragment: TCheckBox;
    chboxSplitChapters: TCheckBox;
    cmbboxCustomCommands: TComboBox;
    cmbboxCustomQuality: TComboBox;
    cmbboxQuickQuality: TComboBox;
    EditVideoURL: TEdit;
    edtChapters: TEdit;
    edtFormatNumA: TEdit;
    edtFormatNumV: TEdit;
    edtTimeFrom: TEdit;
    edtTimeTo: TEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBoxCustom: TGroupBox;
    GroupBoxFragments: TGroupBox;
    GroupBoxQuality: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    radioAdvanced: TRadioButton;
    radioExpert: TRadioButton;
    radioQuick: TRadioButton;

    constructor Create(AOwner: TComponent); override;

    procedure radioExpertChange(Sender: TObject);
  procedure radioAdvancedChange(Sender: TObject);
  procedure radioQuickChange(Sender: TObject);
  procedure EditVideoURLClick(Sender: TObject);
  procedure btnDownloadClick(Sender: TObject);
  procedure btnFormatDataClick(Sender: TObject);
  procedure btnGetInfoClick(Sender: TObject);
  function parseQualitySetting(): string;
  function parseArgs(): string;
  procedure DetectVideoAndPlaylistURL(const URL: string; var dl_args: string);
  procedure btnEditAVListClick(Sender: TObject);
  procedure btnEditCommandsListClick(Sender: TObject);
  procedure chboxCustomArgsChange(Sender: TObject);
  private

  public
    //procedure PrCoJsChecks(var outputStr: string);
  end;

implementation

constructor TVideosFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  g_PobierakSettings.UpdateComboBox_WithCFA(cmbboxCustomQuality, g_PobierakSettings.s_CustomFormatStrings);
  g_PobierakSettings.UpdateComboBox_WithCFA(cmbboxCustomCommands,g_PobierakSettings.s_CustomCommandsStrings);

  //TESTING PURPOSE
   //EditVideoURL.Text := 'https://www.youtube.com/watch?v=C0DPdy98e4c';
   //EditVideoURL.Text :='https://www.youtube.com/watch?v=UEQSkaqrMZA;'
end;

procedure TVideosFrame.radioExpertChange(Sender: TObject);
begin
  GroupBox2.Enabled := False;
  GroupBox3.Enabled := False;
  GroupBox4.Enabled := True;

  GroupBox2.Color := clForm;
  GroupBox3.Color := clForm;
  GroupBox4.Color := clCream;
end;

procedure TVideosFrame.radioAdvancedChange(Sender: TObject);
begin
  GroupBox2.Enabled := False;
  GroupBox3.Enabled := True;
  GroupBox4.Enabled := False;

  GroupBox2.Color := clForm;
  GroupBox3.Color := clCream;
  GroupBox4.Color := clForm;
end;

procedure TVideosFrame.radioQuickChange(Sender: TObject);
begin
  GroupBox2.Enabled := True;
  GroupBox3.Enabled := False;
  GroupBox4.Enabled := False;

  GroupBox2.Color := clCream;
  GroupBox3.Color := clForm;
  GroupBox4.Color := clForm;
end;

procedure TVideosFrame.EditVideoURLClick(Sender: TObject);
begin
  EditVideoURL.SetFocus;
  EditVideoURL.SelectAll;
end;

{Function for validating if the proxy address entered in edtProxy TEdit box in
the UOptions frame fits in the "xxx.xxx.xxx.xxx:xxxxx" format. The address can't
start with "http://" or the like (maybe add support for it in the future).}
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

procedure TVideosFrame.btnDownloadClick(Sender: TObject);
begin
  if ProxyValidation(AppGlobalSettings.G_Proxy) then
  RunTab(EditVideoURL.Text + ' ' + parseArgs(), ' ⬇');
end;

Function PrCoJsChecks(var outputStr: string): Boolean;
  begin
  //Validate proxy address using the function above, and add proxy setting if passed.
  if AppGlobalSettings.G_Proxy <> '' then
    begin
      if ProxyValidation(AppGlobalSettings.G_Proxy) then
        begin
          outputStr := outputStr + ' --proxy ' + AppGlobalSettings.G_Proxy;
          Result := True;
        end
      else
        begin
          ShowMessage('Please check the proxy address in Options tab. Only support IP:Port format (e.g., 127.0.0.1:10001), Adding "http://" or "https://" is not supported');
          Exit;
        end
    end
  else
    begin
      Result := True;
    end;
  //Adding Cookie parameters
  if AppGlobalSettings.G_CookieEnabled = true then
    begin
      if (AppGlobalSettings.G_CookieDir <> '') and (directoryExists(AppGlobalSettings.G_CookieDir)) then
        begin
          outputStr += ' --cookies-from-browser ' + AppGlobalSettings.G_Browser + ':"' + AppGlobalSettings.G_CookieDir + '"';
        end
      else if AppGlobalSettings.G_CookieDir = '' then
        begin
          outputStr += ' --cookies-from-browser ' + AppGlobalSettings.G_Browser;
        end
    end;
{Adding JS runtime parameters, using "--no-js-runtimes" parameter here to
 make sure user's JS runtime selection is respected.}
  if AppGlobalSettings.G_JsEnabled = true then
    begin
      if (AppGlobalSettings.G_JsDir <> '') and (directoryExists(AppGlobalSettings.G_JsDir))then
        begin
          outputStr += ' --no-js-runtimes --js-runtimes ' + AppGlobalSettings.G_JsRuntime + ':"' + AppGlobalSettings.G_JsDir + '"';
        end
      else if AppGlobalSettings.G_JsDir = '' then
        begin
          outputStr += ' --no-js-runtimes --js-runtimes ' + AppGlobalSettings.G_JsRuntime;
        end
    end;
  end;


procedure TVideosFrame.btnFormatDataClick(Sender: TObject);
var addArgs: string;
  f_ignoreGlobalOutputFormat: boolean;
  {IDK how but adding "f_ignoreGlobalOutputFormat" and add it to argument solves
  the problem that my newly added parameters were not being read in
  Get video info and Get format list.}

begin
addArgs := ' -F';
if PrCoJsChecks(addArgs) = True then
  begin
    PrCoJsChecks(addArgs);
    RunTab(EditVideoURL.Text + addArgs + g_PobierakSettings.ParseSettingsArgs(f_ignoreGlobalOutputFormat), 'Format');
  end
else
  begin
    ShowMessage('Please check the proxy address in Options tab. Only support IP:Port format (e.g., 127.0.0.1:10001), Addresses starting with things like "http://" or "https://" is not supported');
    Exit;
  end;
end;

procedure TVideosFrame.btnGetInfoClick(Sender: TObject);
var
  addArgs, args: string;
  f_ignoreGlobalOutputFormat: boolean;
  {IDK how but adding "f_ignoreGlobalOutputFormat" and add it to argument solves
  the problem that my newly added parameters were not being read in
  Get video info and Get format list.}
begin
if PrCoJsChecks(addArgs) = True then
  begin
    addArgs := ' --skip-download';
    addArgs += ' --get-title';
    addArgs += ' --get-duration';
    addArgs += ' --get-description ';
    PrCoJsChecks(addArgs);
    args := EditVideoURL.Text + addArgs + g_PobierakSettings.ParseSettingsArgs(f_ignoreGlobalOutputFormat);
    RunTab(args, ['GET VIDEO INFO:', args], 'Info');
  end
else
  begin
    ShowMessage('Please check the proxy address in Options tab. Only support IP:Port format (e.g., 127.0.0.1:10001). Adding "http://" or "https://" is not supported');
  end;
end;

function TVideosFrame.parseQualitySetting(): string;
var
  adv_V, adv_A, temp: string;
  p: integer;
begin
  Result := '-f ';
  if radioQuick.Checked then
  begin
    case cmbboxQuickQuality.ItemIndex of
      -1: //yt_dlg default quality
        Result := '';
      0:  // best a/v separately and joined
        Result += 'bestvideo*+bestaudio/best';
      1:  // 1080p
        Result += '"b*[height=1080]+ba"';
      2:  //  720p
        Result += '"b*[height=720]+ba"';
      3:  // Best precompiled (for most videos 360p)
        Result += 'best';
      4:    // worst a/v
        Result += 'bestvideo*+bestaudio/best -S +size,+br';
      5:  // best audio only
        Result += 'bestaudio';
      6:  // best video only
        Result += 'bestvideo';
      7: // worst audio
        Result += 'ba -S +size,+br';

    end;
  end
  else if radioAdvanced.Checked then
  begin
    adv_V := edtFormatNumV.Text;
    adv_A := edtFormatNumA.Text;
    if ((adv_V.Length > 0) and (adv_A.Length > 0)) then
      Result += adv_V + '+' + adv_A
    else
      Result += adv_V + adv_A;
  end
  else
  begin
    Result += g_PobierakSettings.s_CustomFormatStrings[
      cmbboxCustomQuality.ItemIndex].CustomString;
  end;
end;

function TVideosFrame.parseArgs(): string;
var
  tempStrArr: TStringArray;
  i: integer;
  f_ignoreGlobalOutputFormat: boolean;
begin
  if PrCoJsChecks(Result) then
  begin
  // quality settings
  Result := ' ' + parseQualitySetting() + ' ';

  // time cut from-to
  if chboxFragment.Checked then
  begin
    Result += ' --download-sections "*' + edtTimeFrom.Text + '-' + edttimeTo.Text + '"';
  end;

  // chapters
  f_ignoreGlobalOutputFormat := False;

  if chboxSplitChapters.Checked then
  begin
    f_ignoreGlobalOutputFormat := True;
    // this will tell settings parsing func to ignore "-o"
    Result += ' --split-chapters';
  end;


  if chboxByChapter.Checked then
  begin
    f_ignoreGlobalOutputFormat := True;
    // this will tell settings parsing func to ignore "-o"
    tempStrArr := string(edtChapters.Text).Split(';');
    for i := 0 to length(tempStrArr) - 1 do
    begin
      Result += ' --download-sections "' + tempStrArr[i] + '"';
    end;
  end;

  if (f_ignoreGlobalOutputFormat) then  // needs work !!!
    Result += ' -o "%(uploader)s/%(title)s/[%(section_title|NO_SECTION_TITLE)s].%(ext)s"';


  // if other output is not set, and custom output is not set, then use default outpu
  if ((not f_ignoreGlobalOutputFormat) and (not g_PobierakSettings.s_UseCustomOutput) ) then
  begin
    Result += ' -o '+g_PobierakSettings.sc_DEFAULT_OUTPUT_FORMAT;
  end;


  // force key frames
  if chboxForceKeyframes.Checked then
    Result += ' --force-keyframes-at-cuts';

  // download thumbnail
  if chboxThumb.Checked then
    Result += ' --write-thumbnail';

  // add custom args
  if chboxCustomArgs.Checked then
    Result += ' '+g_PobierakSettings.s_CustomCommandsStrings[
      cmbboxCustomCommands.ItemIndex].CustomString;

  // add proxy, cookie and javascript runtime settings
  PrCoJsChecks(Result);

  // Detect if it's video+playlist link and ask the user what he wants
  DetectVideoAndPlaylistURL(EditVideoURL.Text, Result);

  //Finally add YT-DLP settings
  Result += g_PobierakSettings.ParseSettingsArgs(f_ignoreGlobalOutputFormat);
  end;
end;

procedure TVideosFrame.DetectVideoAndPlaylistURL(const URL: string; var dl_args: string);
var
  HasVideoParam: boolean;
  HasListParam: boolean;
  ChoiceResult: integer;
const
  mrSingleVideo = 20;
  mrFullPlaylist = 21;
begin
  HasVideoParam := Pos('v=', URL) > 0;
  HasListParam := Pos('list=', URL) > 0;

  if (HasVideoParam and HasListParam) then
  begin
    ChoiceResult := QuestionDlg('Download Mode', // Caption of the dialog
      'This URL contains both a single video and a playlist reference.' +
      LineEnding + 'What would you like to download?', // Message in the dialog
      mtCustom, // Use mtCustom for custom buttons
      [mrSingleVideo, 'Single video',
      // First button: ModalResult = mrSingleVideo, Caption = 'Single video'
      mrFullPlaylist, 'Full Playlist'
      // Second button: ModalResult = mrFullPlaylist, Caption = 'Full Playlist'
      ], '');

    if ChoiceResult = mrSingleVideo then
    begin
      dl_args := dl_args + ' --no-playlist';
    end;
  end;

end;




procedure TVideosFrame.btnEditAVListClick(Sender: TObject);
begin
  CustomAVFormatsForm.ShowModal();
  g_PobierakSettings.UpdateComboBox_WithCFA(cmbboxCustomQuality, g_PobierakSettings.s_CustomFormatStrings);
end;

procedure TVideosFrame.btnEditCommandsListClick(Sender: TObject);
begin
  CustomCommandsForm.ShowModal();
  g_PobierakSettings.UpdateComboBox_WithCFA(cmbboxCustomCommands,
    g_PobierakSettings.s_CustomCommandsStrings);
end;


procedure TVideosFrame.chboxCustomArgsChange(Sender: TObject);
begin
  GroupBoxCustom.Enabled := chboxCustomArgs.Checked;
end;

{$R *.lfm}

end.

