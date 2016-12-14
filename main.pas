unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, StdCtrls, DBGrids,  ExtCtrls, upreferences, mylib,
  BufDataset, db,
netdb,laz2_DOM
  ,laz2_XMLRead
  ,laz2_XMLUtils;

type

  { TMainForm }

  TMainForm = class(TForm)
    AClear: TAction;
    AAbout: TAction;
    AWriteFile_ports: TAction;
    AGetHostNames: TAction;
    AgroupEdit: TAction;
    AGetOpenPorts: TAction;
    AVersions: TAction;
    AOS: TAction;
    AGroups: TAction;
    ASave: TAction;
    AOpen: TAction;
    BufDataset1: TBufDataset;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MClear: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MGetHost: TMenuItem;
    MVersions: TMenuItem;
    MOS: TMenuItem;
    MGroups: TMenuItem;
    OD1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    SD1: TSaveDialog;
    Scan: TAction;
    APreferences: TAction;
    Quit: TAction;
    AL1: TActionList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MPreferences: TMenuItem;
    MExit1: TMenuItem;
    MSave: TMenuItem;
    MLoad: TMenuItem;
    MFiles: TMenuItem;
    MEdit: TMenuItem;
    MExit: TMenuItem;
    procedure AAboutExecute(Sender: TObject);
    procedure AClearExecute(Sender: TObject);
    procedure AGetHostNamesExecute(Sender: TObject);
    procedure AGetOpenPortsExecute(Sender: TObject);
    procedure AgroupEditExecute(Sender: TObject);
    procedure AGroupsExecute(Sender: TObject);
    procedure AOSExecute(Sender: TObject);
    procedure ASaveExecute(Sender: TObject);
    procedure AOpenExecute(Sender: TObject);
    procedure APreferencesExecute(Sender: TObject);
    procedure AVersionsExecute(Sender: TObject);
    procedure AWriteFile_portsExecute(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure DBGrid1ColumnSized(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure ScanExecute(Sender: TObject);
  private
    { private declarations }
    Procedure DoTheXML(FlNm: String);
    Procedure LoadDataBase(FlNm:String);
    Procedure EmptyDatabase;
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation
{$R *.lfm}
Uses
  UEdit,UAbout,UGroups,UGroupEdit,UWrite_Port,sockets;

Var
  DataBaseChanged: Boolean;
{ TMainForm }

procedure TMainForm.ScanExecute(Sender: TObject);
Var
  Str: TStringList;

  Cmd,Interf,St: String;
  i: Integer;
  SavedCursor: TCursor;
begin
  SavedCursor := Cursor;
  Cursor := crHourGlass;
  Interf := GetStdIni('Settings','IFcmd','eth0');
  Cmd := GetSTdIni('Commands','ScanCmd','arp-scan -I <Interface> -l -q | tail  -n +3 | head -n -3');

  //  Cmd := 'arp-scan -I'+Interf+' -l -q | tail  -n +3 | head -n -3';
  Cmd := StringReplace(Cmd,'<Interface>',Interf,[]);
  ShowMessage('This may take a while');
  Application.ProcessMessages;
  Str := TStringList.Create;
//  DoCommand('/bin/bash -c "sudo ls -l"',Str);

  If DoCommand('/bin/bash -c "'+Cmd+'"',Str) = 0 Then
  Begin
    Memo1.Lines.Clear;
    Memo1.Lines.Add('New:');
    With BufDataSet1 Do
    Begin

      If Not BufDataSet1.Active Then
        CreateDataSet;
      If Str.Count < 4 Then
        ShowMessage('To few devices')
      Else
      Begin
        For i := 0 To Str.Count - 1 Do
        Begin
          St := UniformMac(GetFieldByDelimiter(1,Str[i],#9),':');
          If Not BufDataset1.Locate('Mac',St,[]) Then
          Begin
            Append;
            FieldByName('Mac').AsString := UniformMac(GetFieldByDelimiter(1,Str[i],#9),':');
            FieldByName('Hostname').AsString := '';
            FieldByName('OS').AsString := '';
            FieldByName('Groups').AsString := '';
            FieldByName('SSH').AsBoolean := False;
            FieldByName('HTTP').AsBoolean := False;
            FieldByName('HTTPS').AsBoolean := False;
            FieldByName('FTP').AsBoolean := False;
            FieldByName('SNMP').AsBoolean := False;
            FieldByName('Nagios').AsBoolean := False;
            Memo1.Lines.Add(St);
          end
          Else
            Edit;
          FieldByName('IP').AsString := GetFieldByDelimiter(0,Str[i],#9);
          post;
          Application.ProcessMessages;
        end;
      end;
    end;

  end
  Else
  Begin
    Memo1.Clear;
    Memo1.Lines.Add('Error in executing command '+cmd);
  end;
  Str.Free;
  Cursor := SavedCursor;
end;

procedure TMainForm.QuitExecute(Sender: TObject);
begin
  If DataBaseChanged Then
  Begin
    If MessageDlg('Warning','Database not saved, do you really want to exit',mtConfirmation,[mbYes,mbNo] ,0) = mrYes Then
      Application.terminate;
  end
  Else
    Application.Terminate;
end;

procedure TMainForm.APreferencesExecute(Sender: TObject);
begin
  FPref.ShowModal;
end;

procedure TMainForm.AVersionsExecute(Sender: TObject);
begin
  FGroups.Typ := 'Versions';
  FGroups.ShowModal;
end;

procedure TMainForm.AWriteFile_portsExecute(Sender: TObject);
begin
  FWrite_Port.ShowModal;
end;

procedure TMainForm.AOpenExecute(Sender: TObject);
Var
  Fl:TextFile;
begin

  OD1.InitialDir:=GetStdIni('Settings','SaveDir','~/.Inventory');
  OD1.FileName:=GetStdIni('Settings','SaveFile','Inventory.csv');
  If OD1.Execute Then
  begin
    PutStdIni('Settings','SaveDir',OD1.InitialDir);
    PutStdIni('Settings','SaveFile',OD1.FileName);
    LoadDataBase(OD1.FileName);
  end;
end;

procedure TMainForm.ASaveExecute(Sender: TObject);
Var
  Fl: TextFile;
begin
  Sd1.InitialDir:=GetStdIni('Settings','SaveDir','~/.Inventory');
  SD1.FileName:=GetStdIni('Settings','SaveFile','Inventory.csv');
  If SD1.Execute Then
  begin
    PutStdIni('Settings','SaveDir',SD1.InitialDir);
    PutStdIni('Settings','SaveFile',SD1.FileName);
    AssignFile(Fl,SD1.FileName);
    ReWrite(fl);
    With  BufDataSet1 Do
    Begin
      First;
      While Not EOF DO
      begin
        WriteLn(Fl,
        FieldByName('Mac').AsString+';'+
        FieldByName('IP').AsString+';'+
        FieldByName('Hostname').AsString+';'+
        FieldByName('OS').AsString+';'+
        FieldByName('Groups').AsString+';'+
        FieldByName('SSH').AsString+';'+
        FieldByName('HTTP').AsString+';'+
        FieldByName('HTTPS').AsString+';'+
        FieldByName('FTP').AsString+';'+
        FieldByName('SNMP').AsString+';'+
        FieldByName('Nagios').AsString);
        Next;
      end;
    end;
    CloseFile(Fl);
    DataBaseChanged:= False;
    Memo1.Lines.Clear;
    Panel1.Caption:= 'Database unchanged';
  end;
end;

procedure TMainForm.AGroupsExecute(Sender: TObject);
begin
  FGroups.Typ := 'Group';
  FGroups.ShowModal;
end;

procedure TMainForm.AGetOpenPortsExecute(Sender: TObject);
Var
  St,St1,Cmd:string;
  Str1:TStringList;
  Fl:TextFile;
  SavedCursor: TCursor;
begin
  SavedCursor := Cursor;
  Cursor := crHourGlass;

  St := '/tmp/'+IntToStr(GetProcessId)+'_files.txt';
  St1 := '/tmp/'+IntToStr(GetProcessId)+'_out.txt';
  AssignFile(fl,St);
  Rewrite(fl);
  With BufDataSet1 Do
  begin
    First;
    While Not Eof Do
    Begin
      WriteLn(Fl,FieldByName('IP').AsString);
      Next;
      Application.Processmessages;
     End;
  end;
  CloseFile(Fl);
  Cmd := GetSTdIni('Commands','NmapCmd','nmap -iL <FileName1> -p 80,20,22,443,161 -oX <FileName2>');
  Cmd := StringReplace(Cmd,'<FileName1>',St,[]);
  Cmd := StringReplace(Cmd,'<FileName2>',St1,[]);
  ShowMessage('This may take a while');
  Application.ProcessMessages;
  Str1 := TStringList.Create;
  If (DoCommand('/bin/bash -c "'+Cmd+'"',Str1) = 0) Then
    DoTheXML(St1)
  Else
    ShowMessage('Could not execute '+Cmd);
  Str1.Free;
//  DeleteFile(st);
   Cursor := SavedCursor;

end;

procedure TMainForm.AgroupEditExecute(Sender: TObject);
begin
  FGroupEdit.Groups := BufDataSet1.FieldByName('Groups').AsString;
  If FGroupEdit.ShowModal = mrOk Then
  begin
    BufDataSet1.FieldByName('Groups').AsString := FGroupEdit.Groups;
  end;
end;

procedure TMainForm.AClearExecute(Sender: TObject);
begin
  EmptyDataBase;
end;

procedure TMainForm.AAboutExecute(Sender: TObject);
begin
  FAbout.ShowModal;
end;

procedure TMainForm.AGetHostNamesExecute(Sender: TObject);
Var
  H : THostEntry;
  SavedCursor: TCursor;
begin
  SavedCursor := Cursor;
  Cursor := crHourGlass;
  With BufDataSet1 Do
  Begin
    First;
    While Not EoF Do
    Begin
      If ResolveHostByAddr(StrToHostAddr(FieldByName('IP').AsString),H) then
      Begin
        Application.ProcessMessages;
        Edit;
        FieldByName('Hostname').AsString := H.Name;
        Post;
      End;
      Next;
    end;
  End;
  Cursor := SavedCursor;
end;

procedure TMainForm.AOSExecute(Sender: TObject);
begin
  FGroups.Typ := 'OS';
  FGroups.ShowModal;
end;

procedure TMainForm.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  DataBaseChanged:= True;
  Panel1.Caption := 'Database modified';
  Panel2.Caption := 'Items: '+IntToStr(BufDataSet1.RecordCount);
end;

procedure TMainForm.DBGrid1ColumnSized(Sender: TObject);
Var
    i: Integer;
    St: String;
begin
  For i := 0 to DBGrid1.Columns.Count-1 do
  Begin
    If i < 10 Then
      St := 'Col0'+IntToStr(i)
    Else
      St := 'Col'+IntToStr(i);
    PutStdIni('Datagrid',st,IntToStr(DBGrid1.Columns[i].Width));
  End;
end;

procedure TMainForm.DBGrid1DblClick(Sender: TObject);
begin
  EditForm.SHowModal;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  If DataBaseChanged Then
  If MessageDlg('Warning','Database not saved, do you really want to exit',mtConfirmation,[mbYes,mbNo] ,0) = mrNo Then
    CanClose := False
  else
    CanClose := True;
end;


procedure TMainForm.FormCreate(Sender: TObject);
Var
  i:Integer;
  Flnm,St:String;
  Str:TStringList;
begin
  HomeDir := GetUserDir+'/.inventory/';
  If Not DirectoryExists(HomeDir) Then
  Begin
    CreateDir(HomeDir);
  end;
  RestoreForm(MainForm);
  BufDataSet1.CreateDataset;
  For i := 0 to DBGrid1.Columns.Count-1 do
  Begin
    If i < 10 Then
      St := 'Col0'+IntToStr(i)
    Else
      St := 'Col'+IntToStr(i);
    DBGrid1.Columns[i].Width:= StrToInt(GetStdIni('Datagrid',st,IntToStr(DBGrid1.Columns[i].Width)));
  End;
  Panel5.Caption := 'Interface: '+GetStdIni('Settings','IFcmd','eth0');
  If GetEnvironmentVariable('USER') <> 'root' Then
    ShowMessage('To run the scan options, this program needs to be run as root');
  Str := TStringList.Create;
  If DoCommand('/bin/bash -c "which arp-scan"',Str) <> 0 Then
  Begin
    ShowMessage('Cannot find the arp-scan application. If not installed, you cannot do any scanning.');
    Scan.Enabled := False;
  end;
  If DoCommand('/bin/bash -c "which nmap"',Str) <> 0 Then
  Begin
    ShowMessage('Cannot find the nmap application. If not installed, you cannot do any scanning for names and open ports');
    AGetOpenPorts.Enabled := False;
  end;
  Str.Free;
  If GetSTdIni('Settings','LoadLast','True') = 'True' Then
    Flnm := GetStdIni('Settings','SaveFile','');
  If Flnm <> '' Then
   LoadDataBase(Flnm);
  DataBaseChanged:= False;

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SaveForm(MainForm);
end;

Procedure TMainForm.DoTheXML(FlNm: String);
Var
  Doc: TXMLDocument;
  Node,node1,node2,node3: TDomNode;
  mac,port,portstatus,hostname:String;
  Count:Integer;
begin
  Memo1.Lines.Add('Nmap xml file: '+FlNm);
  Count := 0;
  try
    ReadXMLFile(Doc, FlNm);
    Node := Doc.DocumentElement.FindNode('host');
    While Node <> nil Do
    Begin
      Hostname := '';
      Inc(Count);
      Node1 := Node.FirstChild;
      while Node1 <> Nil do
      begin
        If Node1.Nodename = 'hostnames' Then
        Begin
          Node2 := Node1.FirstChild;
          If Node2 <> Nil Then
          if Node2.HasAttributes then
            hostname := node2.Attributes.GetNamedItem('name').NodeValue
          Else
            hostname := '';
        end;
        If Node1.Nodename = 'address' Then
        Begin
          if Node1.HasAttributes then
            begin
              if node1.Attributes.GetNamedItem('addrtype').NodeValue = 'mac' then
                Begin
                  mac := uniformmac(node1.Attributes.GetNamedItem('addr').NodeValue,':');
                  If BufDataSet1.Locate('Mac',Mac,[]) Then
                  begin
                    BufDataSet1.Edit;
                  end;
                end;
            end;
        end;
        If Node1.NodeName = 'ports' Then
        begin
          Node2 := Node1.FirstChild;
          While Node2 <> nil Do
          begin
            If node2.NodeName = 'port' Then
              Port := node2.Attributes.GetNamedItem('portid').NodeValue;
            Node3 := Node2.FirstChild;
            If node3.NodeName = 'state' Then
              PortStatus := node3.Attributes.GetNamedItem('state').NodeValue;
              If port = '20' Then
                BufDataSet1.FieldByName('FTP').AsBoolean := (PortStatus = 'open');
              If port = '22' Then
                BufDataSet1.FieldByName('SSH').AsBoolean := (PortStatus = 'open');
              If port = '80' Then
                BufDataSet1.FieldByName('HTTP').AsBoolean := (PortStatus = 'open');
              If port = '161' Then
                BufDataSet1.FieldByName('SNMP').AsBoolean := (PortStatus = 'open');
              If port = '443' Then
                BufDataSet1.FieldByName('HTTPS').AsBoolean := (PortStatus = 'open');
            Node2 := node2.Nextsibling;
          end;
        end;
        Node1 := Node1.NextSibling;
      end;
      If BufDataSet1.State = dsEdit Then
      Begin
        BufDataSet1.FieldByName('Hostname').AsString := Hostname;
        BufDataSet1.Post;
      end;
      Application.Processmessages;
      Node := Node.NextSibling;
    end;
  finally
    Doc.Free;
  end;
  Memo1.Lines.Add(IntToStr(Count)+' IP addresses was scanned');
end;

Procedure TMainForm.LoadDataBase(FlNm:String);
Var
  Fl:TextFile;
  St:String;
  StL: TStringList;

begin
  If BufDataSet1.Active Then
    If BufDataSet1.RecordCount > 0 Then
      If MessageDlg('Do you want to ovwerwrite the database?',mtWarning,[mbyes,mbNo],0) = mrYes Then
          EmptyDataBase
      Else
        Exit;

  StL:= TStringList.Create;
  Try
    AssignFile(Fl,FlNm);
    Reset(Fl);
    ReadLn(Fl,St);
    Split(St,';',Stl);
    CloseFile(Fl);
  Except
    ShowMessage ('Cannot open '+Flnm);
    Exit;
  end;
  If StL.Count <> 11 Then
  begin
    ShowMessage(OD1.Filename+' has a wrong format');
  end
  Else
  begin
    If Not BufDataSet1.Active Then
      BufDataSet1.CreateDataSet;
    Reset(Fl);
    While Not EoF(Fl) Do
    begin
      ReadLn(Fl,St);
      Split(St,';',Stl);
      Try
        With  BufDataSet1 Do
        Begin
          Append;
          FieldByName('Mac').AsString := StL[0];
          FieldByName('IP').AsString := StL[1];
          FieldByName('Hostname').AsString := StL[2];
          FieldByName('OS').AsString := Stl[3];
          FieldByName('Groups').AsString := StL[4];
          FieldByName('SSH').AsString := StL[5];
          FieldByName('HTTP').AsString := StL[6];
          FieldByName('HTTPS').AsString := StL[7];
          FieldByName('FTP').AsString := StL[8];
          FieldByName('SNMP').AsString := StL[9];
          FieldByName('Nagios').AsString := StL[10];
          Post;
        end;
      Except
        ShowMessage('Could not read the line: '+St);
      end;
    end;
    CloseFile(Fl);
  end;
  StL.Free;

end;

Procedure TMainForm.EmptyDatabase;
begin
  With BufDataset1 Do
  begin
    First;
    While Not EoF Do
    begin
      Edit;
      Delete;
      First;
    end;
  end;
end;
end.

