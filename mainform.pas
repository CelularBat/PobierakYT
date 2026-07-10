unit MainForm;
{ Copyright (c) 2026 CelularBat
  Licensed under GPLv3: https://www.gnu.org/licenses/gpl-3.0.html }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, LCLType,
  pobierak.Settings, pobierak.Engine,
  USubtitlesFrame, UOptionsFrame, UVideosFrame,
  CustomFormatsForm;

type

  { TForm1 }
  TForm1 = class(TForm)
    btnClearTabMemo: TButton;
    btnCloseTab: TButton;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    PageControlConsole: TPageControl;
    ConsoleTab: TTabSheet;
    FrameOptions: TFrameOptions;

    TabSingleVideo: TTabSheet;

    SubtitlesFrame: TSubtitlesFrame;
    TabSubtitles2: TTabSheet;

    OptionsFrame: TFrameOptions;
    TabOptions2: TTabSheet;

    VideosFrame: TVideosFrame;
    TabVideos2: TTabSheet;

    StatusBar1: TStatusBar;

    procedure btnClearTabMemoClick(Sender: TObject);
    procedure btnCloseTabClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);

    procedure LoadTabs();
    procedure PageControl1Change(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

  Memo1.ScrollBars := ssVertical;

  Application.ShowHint := True;
  Application.HintPause := 500;
  Application.HintHidePause := 2500;
  Application.HintShortPause := 50;


  g_PobierakSettings := TMySettings.Create();



  CustomAVFormatsForm := TCustomFormatsForm.Create(Self);
  CustomAVFormatsForm.InitForm('Custom Quality Format String', 'Custom AV Format String',
    'https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#format-selection',
    g_PobierakSettings.s_CustomFormatStrings,
    @g_PobierakSettings.SaveCustomAVList,
    clWhite, clGradientInactiveCaption);

  CustomCommandsForm := TCustomFormatsForm.Create(Self);
  CustomCommandsForm.InitForm('Custom Command String', 'Custom Command String',
    'https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options',
    g_PobierakSettings.s_CustomCommandsStrings,
    @g_PobierakSettings.SaveCustomCommands,
    clWhite, clMoneyGreen);

  CustomOutputsForm := TCustomFormatsForm.Create(Self);
  CustomOutputsForm.InitForm('Custom Output Template', 'Custom Output Template',
    'https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#output-template',
    g_PobierakSettings.s_CustomOutputsStrings,
    @g_PobierakSettings.SaveCustomOutputs,
    clCream, $007DA8FF);

  LoadTabs();

  //TESTING PURPOSE
  // EditVideoURL.Text := 'https://www.youtube.com/watch?v=C0DPdy98e4c';

end;




procedure TForm1.LoadTabs();
begin
  SubtitlesFrame := TSubtitlesFrame.Create(Self);
  // Create the instance, MainForm is the owner
  SubtitlesFrame.Parent := TabSubtitles2;
  // Assign it to the TabSubtitles tab sheet
  SubtitlesFrame.Align := alClient;// Make it fill the entire tab sheet

  OptionsFrame := TFrameOptions.Create(Self);
  OptionsFrame.Parent := TabOptions2;
  OptionsFrame.Align := alClient;

  VideosFrame := TVideosFrame.Create(Self);
  VideosFrame.Parent := TabVideos2;
  VideosFrame.Align := alClient;

  TabSingleVideo.Free();

end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin

end;

/// --- SINGLE VIDEO Tab Interface ---  ///
/////////////////////////////////////////// moved

/// ---  Options Tab  ---  ///
////////////////////////////////////// moved

/// --- Subtitles Tab ---  ///
//////////////////////////////////// moved

/// --- Console Interfaces ---  ///
/////////////////////////////////


procedure TForm1.btnClearTabMemoClick(Sender: TObject);
var
  activeTab: TTabSheet;
var
  m: TMemo;
var
  id: integer;
begin
  activeTab := PageControlConsole.ActivePage;
  id := activeTab.Tag;
  if (id = -1) then
  begin
    m := Memo1;
    m.Lines.Clear();
  end
  else
    g_JobTabs[id].ClearMemo();
end;

procedure TForm1.btnCloseTabClick(Sender: TObject);
var
  id: integer;
begin
  id := PageControlConsole.ActivePage.Tag;
  if (id >= 0) then
    g_JobTabs[id].closeTab();
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  id: integer;
begin
  if (Key = VK_DELETE) or (Key = VK_A) then
  begin
    id := PageControlConsole.ActivePage.Tag;
    if (id >= 0) then
    begin
      g_JobTabs[id].closeTab();

    end;
  end;
end;



end.
