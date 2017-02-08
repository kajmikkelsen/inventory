// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"


unit MyLib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, inifiles, Forms;

type
  TSaveFile = class(TIniFile)
  public
    IniFl: TIniFile;
    constructor Create(const Name: string);
    procedure PutIniVar(Sect, Name, St: string; Nr: integer);
    function GetIniVar(Sect, Name, St: string; Nr: integer): string;
    procedure EraseSection(Sect: string);
  end;

procedure WriteLog(St: string);
function DoCommand(Cmd: string; Output: TStringList): integer;
procedure PutStdIni(Sect, Name, St: string);
function GetStdIni(Sect, Name, St: string): string;
procedure SaveForm(Form: TForm);
procedure RestoreForm(Form: TForm);
procedure BrowseUrl(URL: string);
function EpochToDateTime(Epoch: longint): TdateTime;
procedure Split(St: string; Ch: char; var MyList: TStringList);
function UniformMAC(St: string; Ch: char): string;
function IsValidIP(IP: string): boolean;
function IPToLong(St: string): longword;
function LongToIP(I: longword): string;
function GetFieldByDelimiter(No: integer; St: string; Ch: char): string;

var

  DatDir, HomeDir: string;


implementation

uses
  Process, LCLProc, UTF8Process, LazHelpHTML, UnixUtil, Dialogs, cnetdb, sockets, unix;
//,libc

function GetFieldByDelimiter(No: integer; St: string; Ch: char): string;
var
  MyList: TStringList;
  Res: string;
begin
  MyList := TStringList.Create;
  Split(St, Ch, MyList);
  try
    Res := MyList[No];
  except
    Res := '';
  end;
  MyList.Free;
  Result := Res;
end;


function EpochToDateTime(Epoch: longint): TdateTime;
var
  year, month, day, hour, minute, second, Dformat: word;
  ResDate: TDateTime;
begin
  EpochToLocal(Epoch, year, month, day, hour, minute, second);
  DFormat := 0;
  with DefaultFormatSettings do
  begin
    if ShortDateFormat = 'd/m/y' then
      Dformat := 1;
    if ShortDateFormat = 'm/d/y' then
      Dformat := 2;
    if ShortDateFormat = 'y/m/d' then
      Dformat := 3;
    case DFormat of
      0: ShowMessage('Unknown ShortDateFormat ' + ShortDateFormat);
      1: ResDate := StrToDateTime(IntToStr(Day) + DateSeparator +
          IntToStr(Month) + DateSeparator + IntToStr(Year) + ' ' +
          IntToStr(Hour) + ':' + IntToStr(Minute) + ':' + IntToStr(Second));
      2: ResDate := StrToDateTime(IntToStr(Month) + DateSeparator +
          IntToStr(Day) + DateSeparator + IntToStr(Year) + ' ' +
          IntToStr(Hour) + ':' + IntToStr(Minute) + ':' + IntToStr(Second));
      3: ResDate := StrToDateTime(IntToStr(Year) + DateSeparator +
          IntToStr(Month) + DateSeparator + IntToStr(Year) + ' ' +
          IntToStr(Hour) + ':' + IntToStr(Minute) + ':' + IntToStr(Second));
    end; //Case
  end;
  Result := ResDate;
end;

procedure Split(St: string; Ch: char; var MyList: TStringList);
var
  i: integer;
  St1: string;
begin
  if St[Length(st)] <> Ch then
    St := St + Ch;
  MyList.Clear;
  repeat
    i := Pos(ch, St);
    St1 := Copy(St, 1, i - 1);
    MyList.Add(st1);
    Delete(St, 1, i);
  until St = '';
end;

function UniformMAC(St: string; Ch: char): string;
var
  OctList: TStringList;
  St1, St2: string;
  i: integer;
begin

  OctList := TStringList.Create;
  OctList.Clear;
  Split(St, Ch, OctList);
  if OctList.Count <> 6 then
  begin
    Result := 'Mac Format error ' + IntToStr(OctList.Count);
    Exit;
  end;

  St2 := '';
  for i := 0 to 5 do
  begin
    St1 := UpperCase(OctList[i]);
    if Length(St1) = 1 then
      St1 := '0' + St1;
    St2 := St2 + St1;
    if i < 5 then
      St2 := St2 + ':';
  end;
  OctList.Free;
  Result := st2;
end;


function IsValidIP(IP: string): boolean;
var
  i, i1, MyPos: integer;
  St: string;
begin
  IP := IP + '.';
  for i := 0 to 3 do
  begin
    MyPos := pos('.', IP);
    if Mypos = 0 then
    begin
      Result := False;
      Exit;
    end;
    St := Copy(IP, 1, MyPos - 1);
    try
      i1 := StrToInt(St);
      if (I1 < 0) or (i1 > 255) then
      begin
        Result := False;
        Exit;
      end;
    except
      Result := False;
      Exit;
    end;
    Delete(St, 1, MyPos);
  end;
  Result := True;
end;

function IPToLong(St: string): longword;
var
  MySt: TStringList;
begin
  MySt := TStringList.Create();
  Split(St, '.', MySt);
  Result := StrToInt(MySt[0]) * 256 * 256 * 256 + StrToInt(MySt[1]) *
    256 * 256 + StrToInt(MySt[2]) * 256 + StrToInt(MySt[3]);
  MySt.Free;
end;

function LongToIP(I: longword): string;
var
  i1, i2, i3: integer;
begin
  i1 := I div (256 * 256 * 256);
  i := i mod (256 * 256 * 256);
  i2 := i div (256 * 256);
  i := i mod (256 * 256);
  i3 := i div 256;
  i := i mod 256;
  Result := IntToStr(i1) + '.' + IntToStr(i2) + '.' + IntToStr(i3) + '.' + IntToStr(i);
end;



procedure BrowseUrl(URL: string);
var
  v: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  p: longint;
  BrowserProcess: TProcessUTF8;
begin
  v := THTMLBrowserHelpViewer.Create(nil);
  try
    v.FindDefaultBrowser(BrowserPath, BrowserParams);
    p := System.Pos('%s', BrowserParams);
    System.Delete(BrowserParams, p, 2);
    System.Insert(URL, BrowserParams, p);
    BrowserProcess := TProcessUTF8.Create(nil);
    try
      BrowserProcess.CommandLine := BrowserPath + ' ' + BrowserParams;
      BrowserProcess.Execute;
    finally
      BrowserProcess.Free;
    end;
  finally
    v.Free;
  end;
end;

function DoCommand(Cmd: string; Output: TStringList): integer;
const
  READ_BYTES = 2048;
var
  AProcess: TProcess;
  MemStream: TMemoryStream;
  NumBytes: longint;
  BytesRead: longint;
begin
  MemStream := TMemoryStream.Create;
  BytesRead := 0;
  AProcess := TProcess.Create(nil);
  AProcess.CommandLine := Cmd;
  AProcess.Options := AProcess.Options + [poUsePipes, poStderrToOutPut];
  AProcess.Execute;

  while AProcess.Running do
  begin
    MemStream.SetSize(BytesRead + READ_BYTES);
    NumBytes := AProcess.Output.Read((MemStream.Memory + BytesRead)^, READ_BYTES);
    if NumBytes > 0 then
    begin
      Inc(BytesRead, NumBytes);
    end
    else
    begin
      Sleep(100);
    end;
  end;
  repeat
    // make sure we have room
    MemStream.SetSize(BytesRead + READ_BYTES);
    // try reading it
    NumBytes := AProcess.Output.Read((MemStream.Memory + BytesRead)^, READ_BYTES);
    if NumBytes > 0 then
    begin
      Inc(BytesRead, NumBytes);
    end;
  until NumBytes <= 0;
  MemStream.SetSize(BytesRead);
  OutPut.LoadFromStream(MemStream);
  Result := AProcess.ExitCode;
  AProcess.Free;
  MemStream.Free;

end;

procedure ReplaceChar(Source, Dest: char; var St: string);
var
  i: integer;
begin
  for i := 1 to Length(St) do
    if St[i] = Source then
      St[i] := Dest;
end; // ReplaceChar


procedure SaveForm(Form: TForm);
var
  Fl: TSaveFile;
  St: string;
begin

  St := Form.Caption;
  ReplaceChar(' ', '_', St);
  FL := TSaveFile.Create(HomeDir + ExtractFileName(ParamStr(0)) + '.ini');
  Fl.WriteInteger('Place', St + '_top', Form.Top);
  Fl.WriteInteger('Place', St + '_left', Form.Left);
  Fl.WriteInteger('Place', St + '_height', Form.Height);
  Fl.WriteInteger('Place', St + '_width', Form.Width);
  Fl.Free;
end; (* SaveForm *)

procedure RestoreForm(Form: TForm);
var
  Fl: TSaveFile;
  St: string;
begin
  St := Form.Caption;
  ReplaceChar(' ', '_', St);
  FL := TSaveFile.Create(HomeDir + ExtractFileName(ParamStr(0)) + '.ini');
  Form.Top := Fl.ReadInteger('Place', St + '_top', Form.Top);
  Form.Left := Fl.ReadInteger('Place', St + '_left', Form.Left);
  Form.Height := Fl.ReadInteger('Place', St + '_height', Form.Height);
  Form.Width := Fl.ReadInteger('Place', St + '_width', Form.Width);
  Fl.Free;
end; (* SaveForm *)

procedure WriteLog(St: string);
var
  Fl: TextFile;
  FileName: string;
begin
  FileName := HomeDir + ExtractFileName(ParamStr(0)) + '.log';
  Assign(fl, FileName);
  if FileExists(FileName) then
    Append(Fl)
  else
    ReWrite(Fl);
  WriteLn(Fl, DateTimeToStr(Now), ' ', St);
  Close(fl);
end; (* WriteLog *)

constructor TSaveFile.Create(const Name: string);
begin
  inherited Create(Name);
end;  (* Create *)

function PadCh(Len: integer; Ch: char; St: string): string;
var
  i, i1: integer;
begin
  i1 := Len - Length(st);
  for i := 1 to I1 do
    St := ch + St;
  PadCh := St;
end; (* PadCh *)

function LeftPadCh(Len: integer; Ch: char; St: string): string;
begin
  while Length(St) < Len do
    St := St + Ch;
  LeftPadCh := St;
end; (* PadCh *)

procedure TSaveFile.PutIniVar(Sect, Name, St: string; Nr: integer);
begin
  Name := Name + PadCh(4, '0', IntToStr(Nr));
  WriteString(Sect, Name, St);
end; (* SaveIniVar *)

procedure TSaveFile.EraseSection(Sect: string);
begin
  EraseSection(Sect);
end; (* EraseSection *)

function TSaveFile.GetIniVar(Sect, Name, St: string; Nr: integer): string;
begin
  Name := Name + PadCh(4, '0', IntToStr(Nr));
  GetIniVar := ReadString(Sect, Name, St);
end; (* GetIniVar *)

procedure PutStdIni(Sect, Name, St: string);
var
  Fl: TSaveFile;
begin
  FL := TSaveFile.Create(GetAppConfigFile(False));
  Fl.WriteString(Sect, Name, St);
  Fl.Free;
end; // PutStdIni

function GetStdIni(Sect, Name, St: string): string;
var
  Fl: TSaveFile;
begin
  FL := TSaveFile.Create(GetAppConfigFile(False));
  St := Fl.ReadString(Sect, Name, St);
  Fl.Free;
  GetStdIni := St;
end; // GettStdIni


end.
