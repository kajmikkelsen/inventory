unit MyLib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,StdCtrls,inifiles,Forms;
Type
TSaveFile = Class(TIniFile)
Public
   IniFl: TIniFile;
   Constructor Create(Const Name:String);
   Procedure PutIniVar(Sect,Name,St:String;Nr: Integer);
   Function GetIniVar(Sect,Name,St:String;Nr: Integer):String;
   Procedure EraseSection(Sect:String);
End;

Procedure WriteLog(St:String);
Function DoCommand(Cmd:String;Output:TStringList):Integer;
Procedure PutStdIni(Sect,Name,St:String);
Function GetStdIni(Sect,Name,St:String):String;
Procedure SaveForm(Form: TForm);
Procedure RestoreForm(Form: TForm);
Procedure BrowseUrl(URL: String);
Function EpochToDateTime(Epoch: LongInt):TdateTime;
Procedure Split(St:String;Ch:Char;Var MyList:TStringList);
Function UniformMAC(St: String;Ch: Char):String;
Function GetHostNamesFromIP(IP:String;Var Names:TStringList): Integer;
Function GetIPFromHostName(HostName:String; Var IP:TStringList): Integer;
Function GetNames(IP:String; var Names: TStringList): Integer;
Function IsValidIP(IP:String): Boolean;
Function IPToLong(St:String): LongWord;
Function LongToIP(I:LongWord): String;
Function GetFieldByDelimiter(No: Integer;St: String;Ch: Char): String;
Var

  DatDir,
  HomeDir: String;


implementation
Uses
  Process,LCLProc, UTF8Process, LazHelpHTML,UnixUtil,Dialogs,cnetdb,sockets,unix; //,libc

Function GetFieldByDelimiter(No: Integer;St: String;Ch: Char): String;
Var
  MyList: TStringList;
  Res: String;
Begin
  MyList := TStringList.Create;
  Split(St,Ch,MyList);
  Try
    Res := MyList[No];
  Except
    Res := '';
  end;
  MyList.Free;
  Result := Res;
end;


Function EpochToDateTime(Epoch: LongInt):TdateTime;
var
  year,
  month,
  day,
  hour,
  minute,
  second,Dformat: Word;
  ResDate: TDateTime;
Begin
    EpochToLocal(Epoch,year, month,day,hour,minute,second);
    DFormat := 0;
    With DefaultFormatSettings do
    Begin
      If ShortDateFormat = 'd/m/y' then Dformat := 1;
      If ShortDateFormat = 'm/d/y' then Dformat := 2;
      If ShortDateFormat = 'y/m/d' then Dformat := 3;
      Case DFormat of
        0: ShowMessage('Unknown ShortDateFormat '+ShortDateFormat);
        1:  ResDate := StrToDateTime(IntToStr(Day)+DateSeparator+IntTostr(Month)+DateSeparator+IntToStr(Year)+' '+
          IntToStr(Hour)+':'+IntToStr(Minute)+':'+IntToStr(Second));
        2:  ResDate := StrToDateTime(IntToStr(Month)+DateSeparator+IntTostr(Day)+DateSeparator+IntToStr(Year)+' '+
          IntToStr(Hour)+':'+IntToStr(Minute)+':'+IntToStr(Second));
        3:  ResDate := StrToDateTime(IntToStr(Year)+DateSeparator+IntTostr(Month)+DateSeparator+IntToStr(Year)+' '+
          IntToStr(Hour)+':'+IntToStr(Minute)+':'+IntToStr(Second));
      end; //Case
    end;
    Result := ResDate ;
End;

procedure Split(St: String; Ch: Char;Var MyList: TStringList);
Var
  i: Integer;
  St1:String;
begin
  If St[Length(st)] <> Ch Then
    St := St+Ch;
  MyList.CLear;
  Repeat
    i := Pos(ch,St);
      St1 := Copy(St,1,i-1);
      MyList.Add(st1);
      Delete(St,1,i);
  until St = '' ;
end;

function UniformMAC(St: String;Ch: Char): String;
Var
  OctList: TStringList;
  St1,St2: String;
  i: Integer;
begin

  OctList := TStringlist.Create;
  OctList.Clear;
  Split(St,Ch,OctList);
  If OctList.Count <> 6 Then
  Begin
    Result := 'Mac Format error '+IntTostr(OctList.Count);
    Exit;
  end;

  St2 := '';
  For i := 0 to 5 Do
  Begin
    St1 := UpperCase(OctList[i]);
    If Length(St1) = 1 Then St1 := '0' + St1;
    St2 := St2+St1;
    If i < 5 Then St2 := St2+':';
  end;
  OctList.Free;
  result := st2;
end;

Function GetNames(IP:String; var Names: TStringList): Integer;
Var
  a: SockAddr;
  sa: PsockAddr;
  salen: TSockLen;
  Host:Pchar;
  HostLen:TSize ;
  serv: Pchar;
  servlen: TSize;
  flags: Cint;
  Name:String;
  Status: Integer;
  pa: Pinaddr;


begin
  a.sin_family := AF_INET;
  flags := NI_NAMEREQD;
  sa := @a;
  // Needs to be fixed since libc is depreceated
  //  inet_pton(AF_INET, PCHar(IP), pa {@a.sin_addr} );
  Names.Clear;
  Status := getnameinfo(sa,SizeOf(a),Pchar(Name),SizeOf(Name),nil,0,flags);
  If Status = 0 Then
    Names.Add(Name)
  Else
   // Needs to be fixed since libc is depreceated

//    Names.Add('not found '+IntToStr(Status)+' '+gai_strerror(Status)+' '+StrPas(inet_ntoa(a.sin_addr)));

end;

function IsValidIP(IP: String): Boolean;
Var
 i,i1,MyPos: Integer;
 St: String;
begin
  IP := IP+'.';
  For i := 0 to 3 Do
  begin
    MyPos := pos('.',IP);
    If Mypos = 0 Then
    begin
      result := false;
      Exit;
    end;
    St := Copy(IP,1,MyPos -1);
    Try
      i1 := StrToInt(St);
      If (I1 < 0) or (i1 > 255) Then
      begin
        Result := False;
        Exit;
      end;
    Except
      Result := False;
      Exit;
    end;
    Delete(St,1,MyPos)
  end;
  Result := True;
end;

function IPToLong(St: String): LongWord;
Var
  MySt: TStringList;
begin
  MySt := TStringList.Create();
  Split(St,'.',MySt);
  Result := StrToInt(MySt[0])*256*256*256+StrToInt(MySt[1])*256*256+StrToInt(MySt[2])*256+StrToInt(MySt[3]);
  MySt.Free;
end;

function LongToIP(I: LongWord): String;
Var
  i1,i2,i3: Integer;
begin
  i1 := I div (256*256*256);
  i := i mod (256*256*256);
  i2 := i div (256*256);
  i:= i mod (256*256);
  i3 := i div 256;
  i := i mod 256;
  Result := IntToStr(i1)+'.'+IntToStr(i2)+'.'+IntToStr(i3)+'.'+IntToStr(i);
end;

function GetHostNamesFromIP(IP: String; var Names: TStringList): Integer;
{type
//  TaPInAddr = array [0..10] of PInaddr;
  TaPInAddr = array [0..100] of PChar;
  PaPInAddr = ^TaPInAddr;}
Var
  Command: String;
{  HostInfo: ^HostEnt;
  pptr: PaPInAddr;
  i: Integer;
  a: PChar;
  tst: in_addr;
  pa: Pinaddr;}
  // This command shoukd have been implemented used the clib call gethostbyaddr
  // But the implemntation is buggy, concerning multiple PTR records
  // So I use nslookup instead.
  // I keep the original coding in here just for reffernce.
begin
  Names.Clear;

{  a := PChar(IP);
  pa := @tst;
  inet_pton(AF_INET,a,pa);
  HostInfo := GetHostByAddr(pa,4,AF_INET);
  If HostInfo<>Nil Then
  Begin
    Names.Add(Hostinfo^.h_name);

(*    While HostInfo <> nil Do
    Begin
      ShowMessage('Here we are');
      Hostinfo := GetHostEnt();
      If Hostinfo <> nil then
        Names.Add(Hostinfo^.h_name);
    End;
*)
    pptr := PaPInAddr(Hostinfo^.h_aliases);
      i := 0;
    while pptr^[i] <> nil do
    begin
      Names.Add(StrPas(pptr^[i]));
       Inc(i);
    End;
  end;
 }
  Command :=  '/bin/bash -c "nslookup '+IP+' | grep -v NXDOMAIN | grep in-addr | cut -f 2 -d \= | sed s/.$// | sed s/^.//"';
  DoCommand(Command,Names);
  Result := Names.Count;
end;

function GetIPFromHostName(HostName: String; var IP: TStringList): Integer;
type
  TaPInAddr = array [0..10] of PInaddr;
  PaPInAddr = ^TaPInAddr;
Var
  HostInfo: ^HostEnt;
  pptr: PaPInAddr;
  i: Integer;
  a: PChar;
  tst: in_addr;
  pa: Pinaddr;
begin
  IP.Clear;
  HostInfo := GetHostByName(Pchar(HostName));
  i := 0;
  If HostInfo <> nil Then
  Begin
    pptr := PaPInAddr(Hostinfo^.h_addr_list);
    while pptr^[i] <> nil do
    begin
      // Needs to be fixed since libc is depreceated

//      IP.Add(StrPas(inet_ntoa(pptr^[i]^)));
       Inc(i);
    End;
  End;
  Result := IP.Count;
end;



Procedure BrowseUrl(URL: String);
var
  v: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  p: LongInt;
  BrowserProcess: TProcessUTF8;
begin
  v:=THTMLBrowserHelpViewer.Create(nil);
  Try
    v.FindDefaultBrowser(BrowserPath,BrowserParams);
    p:=System.Pos('%s', BrowserParams);
    System.Delete(BrowserParams,p,2);
    System.Insert(URL,BrowserParams,p);
    BrowserProcess:=TProcessUTF8.Create(nil);
    try
      BrowserProcess.CommandLine:=BrowserPath+' '+BrowserParams;
      BrowserProcess.Execute;
    finally
      BrowserProcess.Free;
    end;
  finally
    v.Free;
  end;
end;

Function DoCommand(Cmd:String;Output:TStringList):Integer;
const
  READ_BYTES = 2048;
var
  AProcess: TProcess;
  MemStream: TMemoryStream;
  NumBytes: LongInt;
  BytesRead: LongInt;
Begin
  MemStream := TMemoryStream.Create;
  BytesRead := 0;
  AProcess := TProcess.Create(nil);
  AProcess.CommandLine := Cmd;
//  AProcess.Executable := cmd;
//  AProcess.Parameters.Assign(Params);
  AProcess.Options := AProcess.Options + [ poUsePipes,poStderrToOutPut];
  AProcess.Execute;

  while AProcess.Running do
  begin
    MemStream.SetSize(BytesRead + READ_BYTES);
    NumBytes := AProcess.Output.Read((MemStream.Memory + BytesRead)^, READ_BYTES);
    If NumBytes > 0 Then
    Begin
      Inc(BytesRead,NumBytes);
    end
    Else
    begin
      Sleep(100);
    end;
  end;
  repeat
    // make sure we have room
    MemStream.SetSize(BytesRead + READ_BYTES);
    // try reading it
    NumBytes := AProcess.Output.Read((MemStream.Memory + BytesRead)^, READ_BYTES);
    if NumBytes > 0
    then begin
      Inc(BytesRead, NumBytes);
    end;
  until NumBytes <= 0;
  MemStream.SetSize(BytesRead);
  OutPut.LoadFromStream(MemStream);
  Result := AProcess.ExitCode;
  AProcess.Free;
  MemStream.Free;

end;

Procedure ReplaceChar(Source,Dest:Char;Var St: String);
Var
  i: Integer;
Begin
  For i := 1 To Length(St) Do
    If St[i] = Source Then St[i] := Dest;
End; // ReplaceChar


Procedure SaveForm(Form: TForm);
Var
  Fl: TSaveFile;
  St: String;
Begin

  St := Form.Caption;
  ReplaceChar(' ','_',St);
  FL := TSaveFile.Create(HomeDir+ExtractFileName(ParamStr(0))+'.ini');
  Fl.WriteInteger('Place',St+'_top',Form.Top);
  Fl.WriteInteger('Place',St+'_left',Form.Left);
  Fl.WriteInteger('Place',St+'_height',Form.Height);
  Fl.WriteInteger('Place',St+'_width',Form.Width);
  Fl.Free;
End; (* SaveForm *)

Procedure RestoreForm(Form: TForm);
Var
  Fl: TSaveFile;
  St: String;
Begin
  St := Form.Caption;
  ReplaceChar(' ','_',St);
  FL := TSaveFile.Create(HomeDir+ExtractFileName(ParamStr(0))+'.ini');
  Form.Top := Fl.ReadInteger('Place',St+'_top',Form.Top);
  Form.Left := Fl.ReadInteger('Place',St+'_left',Form.Left);
  Form.Height := Fl.ReadInteger('Place',St+'_height',Form.Height);
  Form.Width := Fl.ReadInteger('Place',St+'_width',Form.Width);
  Fl.Free;
End; (* SaveForm *)

Procedure WriteLog(St:String);
Var
  Fl: TextFile;
  FileName: String;
Begin
  FileName :=HomeDir+ExtractFileName(ParamStr(0))+'.log';
  Assign(fl,FileName);
  If FileExists(FileName) Then Append(Fl) Else ReWrite(Fl);
  WriteLn(Fl,DateTimeToStr(Now),' ',St);
  Close(fl);
End; (* WriteLog *)

Constructor TSaveFile.Create(Const Name: String);
Begin
  Inherited Create(Name);
End;  (* Create *)

Function PadCh(Len:Integer;Ch:Char;St:String):String;
Var
  i,i1: Integer;
Begin
  i1 := Len - Length(st);
  For i := 1 To I1  Do
    St := ch + St;
  PadCh := St;
End; (* PadCh *)

Function LeftPadCh(Len:Integer;Ch:Char;St:String):String;
Begin
  While Length(St) < Len Do
    St := St +Ch;
  LeftPadCh := St;
End; (* PadCh *)

Procedure TSaveFile.PutIniVar(Sect,Name,St:String;Nr: Integer);
Begin
  Name := Name + PadCh(4,'0',IntToStr(Nr));
  WriteString(Sect,Name,St);
End; (* SaveIniVar *)

Procedure TSaveFile.EraseSection(Sect:String);
Begin
  EraseSection(Sect);
End; (* EraseSection *)

Function TSaveFile.GetIniVar(Sect,Name,St:String;Nr: Integer):String;
Begin
  Name := Name + PadCh(4,'0',IntToStr(Nr));
  GetIniVar := ReadString(Sect,Name,St);
End; (* GetIniVar *)

Procedure PutStdIni(Sect,Name,St:String);
Var
  Fl: TSaveFile;
Begin
  FL := TSaveFile.Create(GetAppConfigFile(False));
  Fl.WriteString(Sect,Name,St);
  Fl.Free;
End; // PutStdIni

Function GetStdIni(Sect,Name,St:String):String;
Var
  Fl: TSaveFile;
Begin
  FL := TSaveFile.Create(GetAppConfigFile(False));
  St := Fl.ReadString(Sect,Name,St);
  Fl.Free;
  GetStdIni := St;
End; // GettStdIni


end.

