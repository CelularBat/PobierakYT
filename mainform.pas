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
    btnAddTab: TButton;
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
    edtOutputFolder: TEdit;
    edtSubtitlesURL: TEdit;
    edtChapters: TEdit;
    edtFormatNum: TEdit;
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
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
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

    function parseAllAdditionalArgs() : string;
    function parseQualitySetting() : string;
    procedure radioQuickChange(Sender: TObject);
    function RunInConsole (var Memo : Tmemo; ARGS: string; out MemoThread : TMemoThr ) : boolean;
    function RunInConsole (ARGS: string) : boolean; overload;
    function RunInConsole (ARGS: string; HEADER : TStringArray ) : boolean;  overload;

    procedure StaticTextURLMouseEnter(Sender: TObject);
    procedure StaticTextURLMouseLeave(Sender: TObject);
    procedure StaticTextURLDblClick(Sender: TObject);

  end;




var
  Form1: TForm1;
var MemoThr : TMemoThr;

implementation

{$R *.lfm}

{ TForm1 }




procedure TForm1.FormCreate(Sender: TObject);
begin

  Memo1.ScrollBars:=ssAutoBoth;

  Options := TMySettings.Create();
  if Options.LoadSettings() then
  begin
    self.edtFFMPGfolder.Text := Options.s_FFMPG_FOLDER;
    self.edtYtDlpBinary.Text := Options.s_YTdl_PATH;
    self.edtOutputFolder.Text := Options.s_OutputFolder;
  end;

   // TESTING PURPOSE
  Options.s_YTdl_PATH:= 'E:\_PORTABLE APPS\Videomass-v4.0.1_x86_64-portable\yt-dlp.exe';
  Options.s_FFMPG_FOLDER := 'E:\_PORTABLE APPS\Videomass-v4.0.1_x86_64-portable\Videomass\FFMPEG\bin';
end;

function TForm1.RunInConsole (var Memo : Tmemo; ARGS: string; out MemoThread : TMemoThr ) : boolean;
begin
    Result := RunWithMemoConsole(Memo, Options.s_YTdl_PATH, Options.ParseYTArgs(args), MemoThread, [Options.ParseYTArgs(args)] );
end;

function TForm1.RunInConsole (ARGS: string) : boolean;  overload;
begin
    Result := RunWithMemoConsole(Memo1, Options.s_YTdl_PATH, Options.ParseYTArgs(ARGS), MemoThr, [Options.ParseYTArgs(args)] );
end;

function TForm1.RunInConsole (ARGS: string; HEADER : TStringArray ) : boolean;  overload;
begin
    Result := RunWithMemoConsole(Memo1, Options.s_YTdl_PATH, Options.ParseYTArgs(ARGS), MemoThr, HEADER);
end;





/// --- SINGLE VIDEO Tab Interface ---  ///
///////////////////////////////////////////



procedure TForm1.radioAdvancedChange(Sender: TObject);
begin
  edtFormatNum.Enabled:= TRUE;
end;

procedure TForm1.radioQuickChange(Sender: TObject);
begin
  edtFormatNum.Enabled:= FALSE;
end;

procedure TForm1.GroupBox3Click(Sender: TObject);
begin

end;


procedure TForm1.btnDownloadClick(Sender: TObject);
begin
   // RunInConsole (EditVideoURL.Text + ' ' +parseAllAdditionalArgs());
  RunInNewTab(EditVideoURL.Text + ' ' +parseAllAdditionalArgs(),PageControl2,'⬇⬇⬇');
end;

procedure TForm1.btnFormatDataClick(Sender: TObject);
begin
    RunInConsole (EditVideoURL.Text + ' -F');
end;

procedure TForm1.btnGetInfoClick(Sender: TObject);
var addArgs : string;
begin
   addArgs := ' ';
   addArgs += ' --get-title ';
   addArgs += ' --get-duration ';
   addArgs += ' --get-description ';


   RunInConsole (EditVideoURL.Text + ' ' + addArgs, ['GET VIDEO INFO:'] );
end;



procedure TForm1.EditVideoURLClick(Sender: TObject);
begin
    EditVideoURL.SetFocus;
    EditVideoURL.SelectAll;
end;

function TForm1.parseQualitySetting() : string;
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
          Result := '-S +size'; // := not +=
     4 :  // best audio only
          Result += 'bestaudio';
     5 :  // best video only
          Result += 'bestvideo';
     end;
   end else if radioAdvanced.Checked then
   begin
     Result += edtFormatNum.Text;
   end;
end;

function TForm1.parseAllAdditionalArgs() : string;
var
  tempStrArr : TStringArray;
  i :integer;
begin
   Result := ' '+parseQualitySetting()+' ';

   if chboxFragment.Checked then
   begin
      Result += ' --download-sections "*'+edtTimeFrom.text + '-' + edttimeTo.text+'"';
   end;
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
   if chboxForceKeyframes.Checked then
      Result += ' --force-keyframes-at-cuts';

   if chboxCustomArgs.Checked then
      Result += edtCustomArgs.Text;
end;

 /// --- OPTIONS Tab Interface ---  ///
 //////////////////////////////////////

procedure TForm1.btnYTBinaryClick(Sender: TObject);
begin
  if OpenDialog1.execute then
     if fileExists(OpenDialog1.Filename) then
     begin
          Options.s_YTdl_PATH := OpenDialog1.Filename;
          edtYtDlpBinary.Text := Options.s_YTdl_PATH;
     end;
end;

procedure TForm1.btnFFMPGClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.execute then
     if directoryExists(SelectDirectoryDialog1.Filename) then
     begin
          Options.s_FFMPG_FOLDER:= SelectDirectoryDialog1.Filename;
          edtFFMPGfolder.Text := Options.s_FFMPG_FOLDER;
     end;

end;

procedure TForm1.btnOutputFolderClick(Sender: TObject);
begin
     if SelectDirectoryDialog1.execute then
       if directoryExists(SelectDirectoryDialog1.Filename) then
       begin
            Options.s_OutputFolder:= SelectDirectoryDialog1.Filename;
            edtOutputFolder.Text := Options.s_OutputFolder;
       end;

end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
  Options.SaveSettings();
  Memo1.Lines.Add('Setting saved at: ' + Options.GetINIPath() );
end;

procedure TForm1.bntDebugClick(Sender: TObject);
begin
    if MemoThr <> nil then
       ShowMessage( MemoThr._DebugState(true) );
end;

procedure TForm1.btnInfoClick(Sender: TObject);
begin

  RunInConsole (' --verbose');
end;

procedure TForm1.btnUpdateYTdlpClick(Sender: TObject);
var response : integer;
begin
  response := MessageDlg('Do you want to auto-update YT-dlp using "yt-dlp -U"', mtConfirmation, [mbYes, mbNo], 0);
  if response = mrYes then
     RunInNewTab('-U',PageControl2,'AutoUpdate');
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
     RunInNewTab('',PageControl2,'Task');
end;

procedure TForm1.btnClearTabMemoClick(Sender: TObject);
var activeTab : TTabSheet;
var m :TMemo;
var idx:integer;
begin
     activeTab := PageControl2.ActivePage;
     idx := activeTab.PageIndex;
     if (idx = 0 ) then
        m := Memo1
     else
         m := g_JobTabs[idx-1].memo;

     m.Lines.Clear();

end;

procedure TForm1.btnCloseTabClick(Sender: TObject);
begin

end;

end.

