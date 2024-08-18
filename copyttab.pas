unit copyTTab;

{$mode ObjFPC}{$H+}



interface

uses
  Classes, SysUtils, Forms,Controls, Graphics, ComCtrls,dialogs,StdCtrls;

type PTTabSheet = ^TTabSheet;

procedure CloneActivePage(PageControl: TPageControl);
function SpawnNewTab(var PageControl: TPageControl;CloneIdx : integer; newName : string ; out page : TTabSheet; out Memo :Tmemo) : boolean;

function _StripUnicode(const Input: string): string;
implementation




// code from:
// https://forum.lazarus.freepascal.org/index.php/topic,37456.msg251745.html#msg251745


procedure CopyProperties(FromControl, ToControl: TControl);
var
  TempMem: TMemoryStream;
  FromName: string;
begin
  FromName := FromControl.Name;
  FromControl.Name := '';
  try
    TempMem := TMemoryStream.Create;
    try
      TempMem.WriteComponent(FromControl);
      TempMem.Position := 0;
      TempMem.ReadComponent(ToControl);
    finally
      TempMem.Free;
    end;
  finally
    FromControl.Name := FromName;
  end;
end;


function CloneControl(FromControl: TControl): TControl;
var
  C: TControl;
begin
  Result := TControlClass(FromControl.ClassType).Create(FromControl.Owner);
  if FromControl.Name <> '' then
    Result.Name := FromControl.Name + '_';
  CopyProperties(FromControl, Result);
  if FromControl is TWinControl then
    for C in TWinControl(FromControl).GetEnumeratorControls do
      CloneControl(C).Parent := TWinControl(Result);
end;


procedure CloneActivePage(PageControl: TPageControl);
var
  Page: TTabSheet;
begin
  if PageControl.ActivePage <> nil then
  begin
    Page := CloneControl(PageControl.ActivePage) as TTabSheet;
    Page.PageControl := PageControl;
    PageControl.ActivePage := Page;
  end;
end;



//////////// Implementation for PobierakYT///////////////////////////////////////////////////
function _StripUnicode(const Input: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(Input) do
    if Ord(Input[i]) < 128 then
      Result := Result + Input[i];
end;

function CloneTabEx(FromControl: TControl; newName : string): TControl;
var
  C: TControl;
begin
  Result := TControlClass(FromControl.ClassType).Create(FromControl.Owner);
  Result.Name := newName;
  CopyProperties(FromControl, Result);
  if FromControl is TWinControl then
    for C in TWinControl(FromControl).GetEnumeratorControls do
      CloneControl(C).Parent := TWinControl(Result);
end;



function SpawnNewTab(var PageControl: TPageControl;CloneIdx : integer; newName : string ; out page : TTabSheet; out Memo :Tmemo) : boolean;
var
  safeName : string; // component name stripped from special characters
  i:integer;
  t :Tcontrol;
begin
    safeName := 'C'+_StripUnicode(newName);
    page := CloneTabEx(PageControl.Pages[0],safeName ) as TTabSheet;
    page.PageControl := PageControl;
    page.Parent := PageControl;
    PageControl.ActivePage := page;


    for i := 0  to page.ControlCount-1 do
    begin
       page.Controls[i].name  := safeName +'___' + inttostr(i);
       page.Controls[i].Parent := page;
       if ( page.Controls[i] is TMemo ) then
       begin
         Memo := page.Controls[i] as TMemo;
         break;
       end;

    end;
    Memo.Lines.Clear();
    page.Caption := newName;
end;








end.

