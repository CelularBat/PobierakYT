unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, LCLIntf,
  ExtCtrls, IniFiles, Process, RunExternal,pobierak.Settings, pobierak.Engine,copyttab,memothread;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnFFMPG: TButton;
    btnOutputFolder: TButton;
    btnSave: TButton;
    btnInfo: TButton;
    btnYTBinary: TButton;
    btnClearTabMemo: TButton;
    btnDownload: TButton;
    btnGetInfo: TButton;
    bntDebug: TButton;
    btnFormatData: TButton;
    btnUpdateYTdlp: TButton;
    btnCheckSubs: TButton;
    btnCloseTab: TButton;
    chboxFragment: TCheckBox;
    chboxCustomArgs: TCheckBox;
    chboxForceKeyFrames: TCheckBox;
    chboxByChapter: TCheckBox;
    chboxSplitChapters: TCheckBox;
    cmbboxQuickQuality: TComboBox;
    edtFormatNumA: TEdit;
    edtOutputFolder: TEdit;
    edtSubtitlesURL: TEdit;
    edtChapters: TEdit;
    edtFormatNumV: TEdit;
    edtCustomArgs: TEdit;
    edtTimeFrom: TEdit;
    edtTimeTo: TEdit;
    EditVideoURL: TEdit;
    edtYtDlpBinary: TEdit;
    edtFFMPGfolder: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    PageControlTabs: TPageControl;
    radioQuick: TRadioButton;
    radioAdvanced: TRadioButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    TabSheet1: TTabSheet;
    TabSubtitles: TTabSheet;
    TabSingleVideo: TTabSheet;
    StatusBar1: TStatusBar;
    TabOptions: TTabSheet;
    TabPlaylist: TTabSheet;
    procedure bntDebugClick(Sender: TObject);
    procedure btnFFMPGClick(Sender: TObject);
    procedure btnOutputFolderClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnYTBinaryClick(Sender: TObject);
    procedure btnInfoClick(Sender: TObject);
    procedure btnAddTabClick(Sender: TObject);
    procedure btnClearTabMemoClick(Sender: TObject);
    procedure btnDownloadClick(Sender: TObject);
    procedure btnFormatDataClick(Sender: TObject);
    procedure btnGetInfoClick(Sender: TObject);
    procedure btnUpdateYTdlpClick(Sender: TObject);
    procedure btnCloseTabClick(Sender: TObject);
    procedure EditVideoURLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure radioAdvancedChange(Sender: TObject);
    procedure GroupBox3Click(Sender: TObject);

    function parseArgs() : string;
    function parseQualitySetting() : string;
    procedure radioQuickChange(Sender: TObject);
    function RunInConsole (var Memo : Tmemo; ARGS: string; out MemoThread : TMemoThr ) : boolean;
    function RunInConsole (ARGS: string) : boolean; overload;
    function RunInConsole (ARGS: string; HEADER : TStringArray ) : boolean;  overload;

    procedure StaticTextURLMouseEnter(Sender: TObject);
    procedure StaticTextURLMouseLeave(Sender: TObject);
    procedure StaticTextURLDblClick(Sender: TObject);

  end;






var  Form1: TForm1;
var MemoThr : TMemoThr;


implementation

{$R *.lfm}

{ TForm1 }




procedure TForm1.FormCreate(Sender: TObject);
begin

  Memo1.ScrollBars:=ssVertical;

  g_PobierakSettings := TMySettings.Create();
  if g_PobierakSettings.LoadSettings() then
  begin
    self.edtFFMPGfolder.Text := g_PobierakSettings.s_FFMPG_FOLDER;
    self.edtYtDlpBinary.Text := g_PobierakSettings.s_YTdl_PATH;
    self.edtOutputFolder.Text := g_PobierakSettings.s_OutputFolder;
  end;
    //TESTING PURPOSE
    EditVideoURL.Text := 'https://www.youtube.com/watch?v=C0DPdy98e4c';
end;



function TForm1.RunInConsole (var Memo : Tmemo; ARGS: string; out MemoThread : TMemoThr ) : boolean;
begin
    Result := RunWithMemoConsole(Memo, g_PobierakSettings.s_YTdl_PATH, ARGS, MemoThread, [args] );
end;

function TForm1.RunInConsole (ARGS: string) : boolean;  overload;
begin
    Result := RunWithMemoConsole(Memo1, g_PobierakSettings.s_YTdl_PATH, ARGS, MemoThr, [args] );
end;

function TForm1.RunInConsole (ARGS: string; HEADER : TStringArray ) : boolean;  overload;
begin
    Result := RunWithMemoConsole(Memo1, g_PobierakSettings.s_YTdl_PATH, ARGS, MemoThr, HEADER);
end;





/// --- SINGLE VIDEO Tab Interface ---  ///
///////////////////////////////////////////



procedure TForm1.radioAdvancedChange(Sender: TObject);
begin
  edtFormatNumV.Enabled:= TRUE;
  edtFormatNumA.Enabled:= TRUE;
end;

procedure TForm1.radioQuickChange(Sender: TObject);
begin
  edtFormatNumV.Enabled:= FALSE;
  edtFormatNumA.Enabled:= FALSE;
end;




procedure TForm1.btnDownloadClick(Sender: TObject);
begin
  RunInNewTab(EditVideoURL.Text + ' ' +parseArgs(),PageControlTabs,'⬇');
end;

procedure TForm1.btnFormatDataClick(Sender: TObject);
begin
    RunInNewTab(EditVideoURL.Text + ' -F ""' ,PageControlTabs,'F');
end;

procedure TForm1.btnGetInfoClick(Sender: TObject);
var addArgs, args : string;

begin
   addArgs := '';
   addArgs += ' --get-title ';
   addArgs += ' --get-duration ';
   addArgs += ' --get-description ';

   args := EditVideoURL.Text + addArgs + ' ""';
   RunInConsole (args, ['GET VIDEO INFO:',args] );
end;



procedure TForm1.EditVideoURLClick(Sender: TObject);
begin
    EditVideoURL.SetFocus;
    EditVideoURL.SelectAll;
end;

function TForm1.parseQualitySetting() : string;
var
  adv_V,adv_A :string;
begin
   Result := '-f ';
   if radioQuick.Checked then
   begin
     case cmbboxQuickQuality.ItemIndex of
     -1 : //yt_dlg default quality
          Result := '';
     0 :  // best a/v separately and joined
          Result += 'bestvideo*+bestaudio/best';
     1 :  // best a/v precompiled
          Result += 'best';
     2 :  // medium a/v precompiled
          Result += 'best.3';
     3 :  // worst a/v precompiled
          Result := '-S +size,+br'; // := not +=
     4 :  // best audio only
          Result += 'bestaudio';
     5 :  // best video only
          Result += 'bestvideo';
     end;
   end else if radioAdvanced.Checked then
   begin
     adv_V := edtFormatNumV.Text;
     adv_A := edtFormatNumA.Text;
     if((adv_V.Length>0) and (adv_A.Length>0)) then
       Result += adv_V +'+'+ adv_A
     else
       Result += adv_V + adv_A;
   end;
end;

function TForm1.parseArgs() : string;
var
  tempStrArr : TStringArray;
  i :integer;
begin
   // quality settings
   Result := ' '+parseQualitySetting()+' ';

   // time cut from-to
   if chboxFragment.Checked then
   begin
      Result += ' --download-sections "*'+edtTimeFrom.text + '-' + edttimeTo.text+'"';
   end;

   // chapters
   if chboxByChapter.Checked then
   begin
      tempStrArr := string(edtChapters.Text).Split(';') ;
      for i:= 0 to length(tempStrArr)-1 do
      begin
           Result += ' --download-sections "'+tempStrArr[i]+'"';
      end;
      if length(tempStrArr) > 1 then
         Result += ' -o "%(title)s_%(chapter)s.%(ext)s"';             /// needs work !!!
   end;

   // force key frames
   if chboxForceKeyframes.Checked then
      Result += ' --force-keyframes-at-cuts';

   // add custom args
   if chboxCustomArgs.Checked then
      Result += edtCustomArgs.Text;

   //Finally add YT-DLP settings
   Result := g_PobierakSettings.ParseYTArgs(Result);
end;

 /// --- g_PobierakSettings Tab Interface ---  ///
 //////////////////////////////////////

procedure TForm1.btnYTBinaryClick(Sender: TObject);
begin
  if OpenDialog1.execute then
     if fileExists(OpenDialog1.Filename) then
     begin
          g_PobierakSettings.s_YTdl_PATH := OpenDialog1.Filename;
          edtYtDlpBinary.Text := g_PobierakSettings.s_YTdl_PATH;
     end;
end;

procedure TForm1.btnFFMPGClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.execute then
     if directoryExists(SelectDirectoryDialog1.Filename) then
     begin
          g_PobierakSettings.s_FFMPG_FOLDER:= SelectDirectoryDialog1.Filename;
          edtFFMPGfolder.Text := g_PobierakSettings.s_FFMPG_FOLDER;
     end;

end;

procedure TForm1.btnOutputFolderClick(Sender: TObject);
begin
     if SelectDirectoryDialog1.execute then
       if directoryExists(SelectDirectoryDialog1.Filename) then
       begin
            g_PobierakSettings.s_OutputFolder:= SelectDirectoryDialog1.Filename;
            edtOutputFolder.Text := g_PobierakSettings.s_OutputFolder;
       end;

end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
  g_PobierakSettings.SaveSettings();
  Memo1.Lines.Add('Setting saved at: ' + g_PobierakSettings.GetINIPath() );
end;

procedure TForm1.bntDebugClick(Sender: TObject);
begin
    if MemoThr <> nil then
       ShowMessage( MemoThr._DebugState(true) );
end;

procedure TForm1.btnInfoClick(Sender: TObject);
begin

  RunInConsole ('--verbose');
end;

procedure TForm1.btnUpdateYTdlpClick(Sender: TObject);
var response : integer;
begin
  response := MessageDlg('Do you want to auto-update YT-dlp using "yt-dlp -U"', mtConfirmation, [mbYes, mbNo], 0);
  if response = mrYes then
     RunInNewTab('-U',PageControlTabs,'AutoUpdate');
end;


procedure TForm1.StaticTextURLMouseEnter(Sender: TObject);
begin
   TStaticText(Sender).Cursor := crHandPoint;
  TStaticText(Sender).Font.Color := clBlue;
end;

procedure TForm1.StaticTextURLMouseLeave(Sender: TObject);
begin
   TStaticText(Sender).Font.Color := clHighlight;
end;

procedure TForm1.StaticTextURLDblClick(Sender: TObject);
var url :string;
begin
  url := TStaticText(Sender).Caption;
  OpenURL(url);
end;



 /// --- other Interfaces ---  ///
 /////////////////////////////////

procedure TForm1.btnAddTabClick(Sender: TObject);

begin
     RunInNewTab('',PageControlTabs,'Task');
end;

procedure TForm1.btnClearTabMemoClick(Sender: TObject);
var activeTab : TTabSheet;
var m :TMemo;
var id:integer;
begin
     activeTab := PageControlTabs.ActivePage;
     id := activeTab.Tag;
     if (id = -1 ) then
     begin
        m := Memo1;
        m.Lines.Clear();
     end
     else
         g_JobTabs[id].ClearMemo();
end;

procedure TForm1.btnCloseTabClick(Sender: TObject);
var activeTab : TTabSheet;
  id :integer;
begin
    id := PageControlTabs.ActivePage.Tag;
    if (id >= 0) then
       g_JobTabs[id].closeTab();
end;

end.

