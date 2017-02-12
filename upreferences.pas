// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

unit upreferences;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFPref }

  TFPref = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CB1: TComboBox;
    ColorDialog1: TColorDialog;
    Edit1: TEdit;
    FontDialog1: TFontDialog;
    Label5: TLabel;
    Label6: TLabel;
    LoadLast: TCheckBox;
    EScanCmd: TEdit;
    EIfCmd: TEdit;
    ENmap: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FPref: TFPref;

implementation

uses
  MyLib, Main;

var
  GetIFcmd: string;

{$R *.lfm}

{ TFPref }

procedure TFPref.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TFPref.Button3Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
    Edit1.Color := ColorDialog1.Color;
  MainForm.OnlineCOlor := Edit1.Color;
end;

procedure TFPref.Button4Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
    Edit1.Font.Color := ColorDialog1.Color;
  MainForm.OnlineFontColor := Edit1.Font.Color;
end;

procedure TFPref.Button1Click(Sender: TObject);
begin
  PutStdIni('Settings', 'IFcmd', CB1.Text);
  PutStdIni('Commands', 'ScanCmd', EScanCmd.Text);
  PutStdIni('Commands', 'GetIfCmd', EIfCmd.Text);
  PutStdIni('Commands', 'NmapCmd', ENmap.Text);
  if LoadLast.Checked then
    PutStdIni('Settings', 'LoadLast', 'True')
  else
    PutStdIni('Settings', 'LoadLast', 'False');
  PutStdIni('Settings', 'OnlineTextColor', IntToStr(MainForm.OnlineFontColor));
  PutStdIni('Settings', 'OnlineTextBackGround', IntToStr(MainForm.OnlineCOlor));
  Close;
end;

procedure TFPref.FormActivate(Sender: TObject);
var
  StrList: TStringList;
begin
  EifCmd.Text := GetStdIni('Commands', 'GetIfCmd',
    'ifconfig -a | grep Link | grep -v inet6| awk '' { print $1 }  ''');
  EScanCmd.Text := GetStdIni('Commands', 'ScanCmd',
    'arp-scan -I <Interface> -l -q | tail  -n +3 | head -n -3');
  ENmap.Text := GetSTdIni('Commands', 'NmapCmd',
    'nmap -iL <FileName1> -p 80,20,22,443,161 -oX <FileName2>');
  LoadLast.Checked := (GetSTdIni('Settings', 'LoadLast', 'True') = 'True');

  GetIFcmd := '/bin/bash -c "' + EIfCmd.Text + '"';

  if CB1.Items.Count = 0 then
  begin

    StrList := TStringList.Create;
    DoCommand(GetIFcmd, StrList);
    StrList.Add('All');
    CB1.Items.Assign(StrList);
    CB1.Text := GetStdIni('Settings', 'IFcmd', CB1.Items[0]);
    StrList.Free;
  end;
  Edit1.Font.Color := StrToInt(
    GetStdIni('Settings', 'OnlineTextColor', IntToStr(ClBlack)));
  Edit1.Color := StrToInt(GetStdIni('Settings', 'OnlineTextBackGround',
    IntToStr(ClDefault)));

end;

procedure TFPref.FormCreate(Sender: TObject);
begin
  RestoreForm(FPref);

end;

procedure TFPref.FormDestroy(Sender: TObject);
begin
  SaveForm(FPref);
end;

end.
