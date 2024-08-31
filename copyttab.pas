unit copyTTab;

{$mode ObjFPC}{$H+}



interface

uses
  Classes, SysUtils, Forms,Controls, Graphics, ComCtrls,dialogs,StdCtrls;

type PTTabSheet = ^TTabSheet;


function SpawnNewTab(var PageControl: TPageControl;CloneIdx : integer; newName : string ; out page : TTabSheet; out Memo :Tmemo) : boolean;


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
       try
        TempMem.WriteComponent(FromControl);
        TempMem.Position := 0;
        TempMem.ReadComponent(ToControl);
       except
         on E: Exception do
           begin
              ShowMessage( 'Error: '+ E.ClassName + #13#10 + E.Message );
           end;
       end;

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

function _StripWrongChars(const Input: string): string;
var
  i: Integer;
begin
  Result:='';
  for i := 1 to Length(Input) do
  begin
    if Input[i] in ['0'..'9', 'A'..'Z', 'a'..'z'] then
      Result := Result + Input[i];
  end;
end;

{function CloneTabEx(FromControl: TControl; newName : string): TControl;
var
  C: TControl;
begin
  Result := TControlClass(FromControl.ClassType).Create(FromControl.Owner);
  Result.Name := newName;
  CopyProperties(FromControl, Result);
  if FromControl is TWinControl then
    for C in TWinControl(FromControl).GetEnumeratorControls do
      CloneControl(C).Parent := TWinControl(Result);
end; }



function SpawnNewTab(var PageControl: TPageControl;CloneIdx : integer; newName : string ; out page : TTabSheet; out Memo :Tmemo) : boolean;
var
  safeName : string; // component name stripped from special characters
  i:integer;
begin
    safeName := 'C'+_StripUnicode(newName);
    safeName := _StripWrongChars(safename);

    //page := CloneTabEx(PageControl.Pages[0],safeName ) as TTabSheet;
    page := CloneControl(PageControl.Pages[0] ) as TTabSheet;
    page.PageControl := PageControl;
    page.Parent := PageControl;



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
    PageControl.ActivePage := page;
end;








end.

