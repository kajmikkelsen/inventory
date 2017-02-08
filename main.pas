// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

// Version History
// 0.01 Initial release
// 0.02 Error in Regular Expression happened for all records.
//      Changed so filter is discarded on RegEx error

unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, StdCtrls, DBGrids, ExtCtrls, Buttons, upreferences, mylib,
  BufDataset, DB,
  netdb, laz2_DOM
  , laz2_XMLRead
  , laz2_XMLUtils;

type

  { TMainForm }

  TMainForm = class(TForm)
    AClear: TAction;
    AAbout: TAction;
    AWriteAll: TAction;
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
    Button1: TButton;
    Button2: TButton;
    CB1: TComboBox;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
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
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
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
    SD2: TSaveDialog;
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
    procedure AWriteAllExecute(Sender: TObject);
    procedure AWriteFile_portsExecute(Sender: TObject);
    procedure BufDataset1FilterRecord(DataSet: TDataSet; var Accept: boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure DBGrid1ColumnSized(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MExitClick(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure ScanExecute(Sender: TObject);
  private
    { private declarations }
    procedure DoTheXML(FlNm: string);
    procedure LoadDataBase(FlNm: string);
    procedure EmptyDatabase;
    procedure ShowMyMessage(Message: string);
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}
uses
  UEdit, UAbout, UGroups, UGroupEdit, UWrite_Port, sockets, UMyShowMessage, RegExpr;

var
  DataBaseChanged: boolean;
{ TMainForm }

procedure TMainForm.ScanExecute(Sender: TObject);
var
  Str: TStringList;

  Cmd, Interf, St: string;
  i: integer;
  SavedCursor: TCursor;
begin
  SavedCursor := Cursor;
  Cursor := crHourGlass;
  Panel6.Caption := 'Scanning';
  Interf := GetStdIni('Settings', 'IFcmd', 'eth0');
  Cmd := GetStdIni('Commands', 'ScanCmd',
    'arp-scan -I <Interface> -l -q | tail  -n +3 | head -n -3');

  //  Cmd := 'arp-scan -I'+Interf+' -l -q | tail  -n +3 | head -n -3';
  Cmd := StringReplace(Cmd, '<Interface>', Interf, []);
  ShowMyMessage('This may take a while');
  Application.ProcessMessages;
  Str := TStringList.Create;
  //  DoCommand('/bin/bash -c "sudo ls -l"',Str);
  if DoCommand('/bin/bash -c "' + Cmd + '"', Str) = 0 then
  begin
    Memo1.Lines.Clear;
    Memo1.Lines.Add('New:');
    with BufDataSet1 do
    begin

      if not BufDataSet1.Active then
        CreateDataSet;
      if Str.Count < 4 then
        ShowMessage('To few devices')
      else
      begin
        for i := 0 to Str.Count - 1 do
        begin
          St := UniformMac(GetFieldByDelimiter(1, Str[i], #9), ':');
          if not BufDataset1.Locate('Mac', St, []) then
          begin
            Append;
            FieldByName('Mac').AsString :=
              UniformMac(GetFieldByDelimiter(1, Str[i], #9), ':');
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
          else
            Edit;
          FieldByName('IP').AsString := GetFieldByDelimiter(0, Str[i], #9);
          post;
          Application.ProcessMessages;
        end;
      end;
    end;

  end
  else
  begin
    Memo1.Clear;
    Memo1.Lines.Add('Error in executing command ' + cmd);
  end;
  Str.Free;
  Panel6.Caption := '';
  Cursor := SavedCursor;
end;

procedure TMainForm.QuitExecute(Sender: TObject);
begin
  if DataBaseChanged then
  begin
    if MessageDlg('Warning', 'Database not saved, do you really want to exit',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      Application.terminate;
  end
  else
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

procedure TMainForm.AWriteAllExecute(Sender: TObject);
var
  Fl: TextFile;
begin
  SD2.InitialDir := GetStdIni('Settings', 'WriteSaveDir', '~/.Inventory');
  SD2.FileName := GetStdIni('Settings', 'WriteSaveFile', '');
  if SD2.Execute then
  begin
    PutStdIni('Settings', 'WriteSaveDir', SD2.InitialDir);
    PutStdIni('Settings', 'WriteSaveFile', SD2.FileName);
    try
      AssignFile(fl, SD2.FileName);
      Rewrite(Fl);
    except
      ShowMessage('Could not write to file' + SD2.FileName);
      Exit;
    end;
    with BufDataset1 do
    begin
      First;
      while not EOF do
      begin
        if FieldByName('Hostname').AsString <> '' then
          WriteLn(fl, FieldByName('Hostname').AsString);
        Next;
      end;
    end;
    CloseFile(Fl);
  end;
end;

procedure TMainForm.AWriteFile_portsExecute(Sender: TObject);
begin
  FWrite_Port.ShowModal;
end;

procedure TMainForm.BufDataset1FilterRecord(DataSet: TDataSet; var Accept: boolean);
var
  RegEx: TRegExpr;
  St: string;
begin
  RegEx := TRegExpr.Create;
  try
    try
      RegEx.Expression := Edit1.Text;
      St := BufDataSet1.FieldByName(CB1.Text).AsString;
      if RegEx.Exec(St) then
        Accept := True
      else
        Accept := False;
    except
      ShowMessage('Error in Regular Expression, filter discarded ');
      BufDataSet1.Filtered:=false;
    end;
  finally
    RegEx.Free;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  BufDataSet1.Filtered := False;
  BufDataSet1.Filtered := True;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  BufDataSet1.Filtered := False;
  Edit1.Text := '';
end;

procedure TMainForm.AOpenExecute(Sender: TObject);
var
  Fl: TextFile;
begin

  OD1.InitialDir := GetStdIni('Settings', 'SaveDir', '~/.Inventory');
  OD1.FileName := GetStdIni('Settings', 'SaveFile', 'Inventory.csv');
  if OD1.Execute then
  begin
    PutStdIni('Settings', 'SaveDir', OD1.InitialDir);
    PutStdIni('Settings', 'SaveFile', OD1.FileName);
    LoadDataBase(OD1.FileName);
  end;
end;

procedure TMainForm.ASaveExecute(Sender: TObject);
var
  Fl: TextFile;
begin
  if BufDataSet1.Filtered then
  begin
    if MessageDlg('Clear filter before saving', mtConfirmation, [mbYes, mbNo], 0) =
      mrYes then
    begin
      BufDataSet1.Filtered := False;
      Edit1.Text := '';
    end;
  end;
  Sd1.InitialDir := GetStdIni('Settings', 'SaveDir', '~/.Inventory');
  SD1.FileName := GetStdIni('Settings', 'SaveFile', 'Inventory.csv');
  if SD1.Execute then
  begin
    PutStdIni('Settings', 'SaveDir', SD1.InitialDir);
    PutStdIni('Settings', 'SaveFile', SD1.FileName);
    AssignFile(Fl, SD1.FileName);
    ReWrite(fl);
    with  BufDataSet1 do
    begin
      First;
      while not EOF do
      begin
        WriteLn(Fl,
          FieldByName('Mac').AsString + ';' + FieldByName('IP').AsString +
          ';' + FieldByName('Hostname').AsString + ';' +
          FieldByName('OS').AsString + ';' + FieldByName('Groups').AsString +
          ';' + FieldByName('SSH').AsString + ';' + FieldByName('HTTP').AsString +
          ';' + FieldByName('HTTPS').AsString + ';' + FieldByName('FTP').AsString +
          ';' + FieldByName('SNMP').AsString + ';' + FieldByName('Nagios').AsString);
        Next;
      end;
    end;
    CloseFile(Fl);
    DataBaseChanged := False;
    Memo1.Lines.Clear;
    Panel1.Caption := 'Database unchanged';
  end;
end;

procedure TMainForm.AGroupsExecute(Sender: TObject);
begin
  FGroups.Typ := 'Group';
  FGroups.ShowModal;
end;

procedure TMainForm.AGetOpenPortsExecute(Sender: TObject);
var
  St, St1, Cmd: string;
  Str1: TStringList;
  Fl: TextFile;
  SavedCursor: TCursor;
begin
  SavedCursor := Cursor;
  Cursor := crHourGlass;
  Panel6.Caption := 'Scanning';
  St := '/tmp/' + IntToStr(GetProcessId) + '_files.txt';
  St1 := '/tmp/' + IntToStr(GetProcessId) + '_out.txt';
  AssignFile(fl, St);
  Rewrite(fl);
  with BufDataSet1 do
  begin
    First;
    while not EOF do
    begin
      WriteLn(Fl, FieldByName('IP').AsString);
      Next;
      Application.ProcessMessages;
    end;
  end;
  CloseFile(Fl);
  Cmd := GetSTdIni('Commands', 'NmapCmd',
    'nmap -iL <FileName1> -p 80,20,22,443,161 -oX <FileName2>');
  Cmd := StringReplace(Cmd, '<FileName1>', St, []);
  Cmd := StringReplace(Cmd, '<FileName2>', St1, []);
  ShowMyMessage('This may take a while');
  Application.ProcessMessages;
  Str1 := TStringList.Create;
  if (DoCommand('/bin/bash -c "' + Cmd + '"', Str1) = 0) then
    DoTheXML(St1)
  else
    ShowMessage('Could not execute ' + Cmd);
  Str1.Free;
  DeleteFile(St);
  DeleteFile(st1);
  Cursor := SavedCursor;
  Panel6.Caption := '';
end;

procedure TMainForm.AgroupEditExecute(Sender: TObject);
begin
  FGroupEdit.Groups := BufDataSet1.FieldByName('Groups').AsString;
  if FGroupEdit.ShowModal = mrOk then
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
var
  H: THostEntry;
  SavedCursor: TCursor;
begin
  SavedCursor := Cursor;
  Cursor := crHourGlass;
  Panel6.Caption := 'Scanning';
  with BufDataSet1 do
  begin
    First;
    while not EOF do
    begin
      if ResolveHostByAddr(StrToHostAddr(FieldByName('IP').AsString), H) then
      begin
        Edit;
        FieldByName('Hostname').AsString := H.Name;
        Post;
      end;
      Application.ProcessMessages;
      Next;
    end;
  end;
  Panel6.Caption := '';
  Cursor := SavedCursor;
end;

procedure TMainForm.AOSExecute(Sender: TObject);
begin
  FGroups.Typ := 'OS';
  FGroups.ShowModal;
end;

procedure TMainForm.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  DataBaseChanged := True;
  Panel1.Caption := 'Database modified';
  Panel2.Caption := 'Items: ' + IntToStr(BufDataSet1.RecordCount);
end;

procedure TMainForm.DBGrid1ColumnSized(Sender: TObject);
var
  i: integer;
  St: string;
begin
  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    if i < 10 then
      St := 'Col0' + IntToStr(i)
    else
      St := 'Col' + IntToStr(i);
    PutStdIni('Datagrid', st, IntToStr(DBGrid1.Columns[i].Width));
  end;
end;

procedure TMainForm.DBGrid1DblClick(Sender: TObject);
begin
  EditForm.SHowModal;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if DataBaseChanged then
    if MessageDlg('Warning', 'Database not saved, do you really want to exit',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      CanClose := False
    else
      CanClose := True;
end;


procedure TMainForm.FormCreate(Sender: TObject);
var
  i: integer;
  Flnm, St: string;
  Str: TStringList;
begin
  HomeDir := GetUserDir + '/.inventory/';
  if not DirectoryExists(HomeDir) then
  begin
    CreateDir(HomeDir);
  end;
  RestoreForm(MainForm);
  BufDataSet1.CreateDataset;
  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    if i < 10 then
      St := 'Col0' + IntToStr(i)
    else
      St := 'Col' + IntToStr(i);
    DBGrid1.Columns[i].Width :=
      StrToInt(GetStdIni('Datagrid', st, IntToStr(DBGrid1.Columns[i].Width)));
  end;
  Panel5.Caption := 'Interface: ' + GetStdIni('Settings', 'IFcmd', 'eth0');
  if GetEnvironmentVariable('USER') <> 'root' then
    ShowMessage('To run the scan options, this program needs to be run as root');
  Str := TStringList.Create;
  if DoCommand('/bin/bash -c "which arp-scan"', Str) <> 0 then
  begin
    ShowMessage('Cannot find the arp-scan application. If not installed, you cannot do any scanning.');
    Scan.Enabled := False;
  end;
  if DoCommand('/bin/bash -c "which nmap"', Str) <> 0 then
  begin
    ShowMessage('Cannot find the nmap application. If not installed, you cannot do any scanning for names and open ports');
    AGetOpenPorts.Enabled := False;
  end;
  Str.Free;
  if GetSTdIni('Settings', 'LoadLast', 'True') = 'True' then
    Flnm := GetStdIni('Settings', 'SaveFile', '');
  if Flnm <> '' then
    LoadDataBase(Flnm);
  DataBaseChanged := False;
  Panel6.Caption := '';
  CB1.Items.Clear;
  for i := 0 to BufDataSet1.FieldCount - 1 do
    CB1.Items.Add(BufDataSet1.Fields[i].FieldName);
  CB1.ItemIndex := 0;
  ;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SaveForm(MainForm);
end;

procedure TMainForm.MenuItem10Click(Sender: TObject);
begin
  AL1.ActionByName('AAbout');
end;

procedure TMainForm.MExitClick(Sender: TObject);
begin
  AL1.ActionByName('Quit');
end;

procedure TMainForm.DoTheXML(FlNm: string);
var
  Doc: TXMLDocument;
  Node, node1, node2, node3: TDomNode;
  mac, port, portstatus, hostname: string;
  Count: integer;
begin
  Memo1.Lines.Add('Nmap xml file: ' + FlNm);
  Count := 0;
  try
    ReadXMLFile(Doc, FlNm);
    Node := Doc.DocumentElement.FindNode('host');
    while Node <> nil do
    begin
      Hostname := '';
      Inc(Count);
      Node1 := Node.FirstChild;
      while Node1 <> nil do
      begin
        if Node1.Nodename = 'hostnames' then
        begin
          Node2 := Node1.FirstChild;
          if Node2 <> nil then
            if Node2.HasAttributes then
              hostname := node2.Attributes.GetNamedItem('name').NodeValue
            else
              hostname := '';
        end;
        if Node1.Nodename = 'address' then
        begin
          if Node1.HasAttributes then
          begin
            if node1.Attributes.GetNamedItem('addrtype').NodeValue = 'mac' then
            begin
              mac := uniformmac(node1.Attributes.GetNamedItem('addr').NodeValue, ':');
              if BufDataSet1.Locate('Mac', Mac, []) then
              begin
                BufDataSet1.Edit;
              end;
            end;
          end;
        end;
        if Node1.NodeName = 'ports' then
        begin
          Node2 := Node1.FirstChild;
          while Node2 <> nil do
          begin
            if node2.NodeName = 'port' then
              Port := node2.Attributes.GetNamedItem('portid').NodeValue;
            Node3 := Node2.FirstChild;
            if node3.NodeName = 'state' then
              PortStatus := node3.Attributes.GetNamedItem('state').NodeValue;
            if port = '20' then
              BufDataSet1.FieldByName('FTP').AsBoolean := (PortStatus = 'open');
            if port = '22' then
              BufDataSet1.FieldByName('SSH').AsBoolean := (PortStatus = 'open');
            if port = '80' then
              BufDataSet1.FieldByName('HTTP').AsBoolean := (PortStatus = 'open');
            if port = '161' then
              BufDataSet1.FieldByName('SNMP').AsBoolean := (PortStatus = 'open');
            if port = '443' then
              BufDataSet1.FieldByName('HTTPS').AsBoolean := (PortStatus = 'open');
            Node2 := node2.Nextsibling;
          end;
        end;
        Node1 := Node1.NextSibling;
      end;
      if BufDataSet1.State = dsEdit then
      begin
        BufDataSet1.FieldByName('Hostname').AsString := Hostname;
        BufDataSet1.Post;
      end;
      Application.ProcessMessages;
      Node := Node.NextSibling;
    end;
  finally
    Doc.Free;
  end;
  Memo1.Lines.Add(IntToStr(Count) + ' IP addresses was scanned');
end;

procedure TMainForm.LoadDataBase(FlNm: string);
var
  Fl: TextFile;
  St: string;
  StL: TStringList;

begin
  if BufDataSet1.Active then
    if BufDataSet1.RecordCount > 0 then
      if MessageDlg('Do you want to ovwerwrite the database?', mtWarning,
        [mbYes, mbNo], 0) = mrYes then
        EmptyDataBase
      else
        Exit;

  StL := TStringList.Create;
  try
    AssignFile(Fl, FlNm);
    Reset(Fl);
    ReadLn(Fl, St);
    Split(St, ';', Stl);
    CloseFile(Fl);
  except
    ShowMessage('Cannot open ' + Flnm);
    Exit;
  end;
  if StL.Count <> 11 then
  begin
    ShowMessage(OD1.Filename + ' has a wrong format');
  end
  else
  begin
    if not BufDataSet1.Active then
      BufDataSet1.CreateDataSet;
    Reset(Fl);
    while not EOF(Fl) do
    begin
      ReadLn(Fl, St);
      Split(St, ';', Stl);
      try
        with  BufDataSet1 do
        begin
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
      except
        ShowMessage('Could not read the line: ' + St);
      end;
    end;
    CloseFile(Fl);
  end;
  StL.Free;

end;

procedure TMainForm.EmptyDatabase;
begin
  with BufDataset1 do
  begin
    First;
    while not EOF do
    begin
      Edit;
      Delete;
      First;
    end;
  end;
end;

procedure TMainForm.ShowMyMessage(Message: string);
var
  ShowIt: string;
begin
  FMyShowMessage.Message.Caption := Message;
  ShowIt := GetStdIni('Messages', Message, 'True');
  if ShowIt = 'True' then
    FMyShowMessage.ShowModal;

end;

end.
