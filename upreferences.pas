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
    CB1: TComboBox;
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
Uses
  MyLib;
Var
  GetIFcmd: String;
{$R *.lfm}

{ TFPref }

procedure TFPref.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TFPref.Button1Click(Sender: TObject);
begin
  PutStdIni('Settings','IFcmd',CB1.Text);
  PutStdIni('Commands','ScanCmd',EScanCmd.Text);
  PutStdIni('Commands','GetIfCmd',EIfCmd.Text);
  PutStdIni('Commands','NmapCmd',ENmap.Text);
  If LoadLast.Checked Then
    PutStdIni('Settings','LoadLast','True')
  Else
    PutStdIni('Settings','LoadLast','False');

  Close;
end;

procedure TFPref.FormActivate(Sender: TObject);
Var
  StrList: TStringList;
begin
  EifCmd.Text := GetStdIni('Commands','GetIfCmd','ifconfig -a | grep Link | grep -v inet6| awk '' { print $1 }  ''');
  EScanCmd.Text := GetStdIni('Commands','ScanCmd','arp-scan -I <Interface> -l -q | tail  -n +3 | head -n -3');
  ENmap.Text := GetSTdIni('Commands','NmapCmd','nmap -iL <FileName1> -p 80,20,22,443,161 -oX <FileName2>');
  LoadLast.Checked := (GetSTdIni('Settings','LoadLast','True') = 'True');

  GetIFcmd := '/bin/bash -c "'+EIfCmd.Text+'"';

  If CB1.Items.Count = 0 Then
  Begin

    StrList := TStringList.Create;
    DoCommand(GetIFcmd,StrList);
    CB1.Items.Assign(StrList);
    CB1.Text := GetStdIni('Settings','IFcmd',CB1.Items[0]);
    StrList.Free;
  end;
end;

procedure TFPref.FormCreate(Sender: TObject);
begin
  RestoreForm(FPref);

end;

procedure TFPref.FormDestroy(Sender: TObject);
begin
  SaveForm(FPref)
end;

end.

