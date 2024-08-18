unit debugUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TByteArr = array of byte;
  PTByteArr = ^TByteArr;

function ByteArrayToHexString(AByteArray: array of byte; ASep: string = ''): string;

implementation

function ByteArrayToHexString(AByteArray: array of byte; ASep: string = ''): string;
var
  i, k: integer;
begin
  result := '';

  if ASep = '' then begin
     for i := low(AByteArray) to high(AByteArray) do
       result := result + IntToHex(AByteArray[i], 2);
  end else begin
     k := high(AByteArray);
     for i := low(AByteArray) to k do begin
        result := result + IntToHex(AByteArray[i], 2);
        if k <> i then result := result + ASep;
     end;
  end;
end;

{function ByteArrayToHexString(P_STATIC_byte_array : Pointer; Buffer_size : integer; ASep: string = ''): string; overload;
var PBA : PTByteArr;
  BA : TByteArr;
begin

   ByteArrayToHexString

end;        }

end.

