// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

unit UEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBCtrls;

type

  { TEditForm }

  TEditForm = class(TForm)
    Button1: TButton;
    CB1: TComboBox;
    CB2: TComboBox;
    DBCheckBox1: TDBCheckBox;
    DBCheckBox2: TDBCheckBox;
    DBCheckBox3: TDBCheckBox;
    DBCheckBox4: TDBCheckBox;
    DBCheckBox5: TDBCheckBox;
    DBCheckBox6: TDBCheckBox;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure CB1Change(Sender: TObject);
    procedure CB2Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  EditForm: TEditForm;

implementation

uses
  Main,
  MyLib;

{$R *.lfm}

{ TEditForm }

procedure TEditForm.FormCreate(Sender: TObject);
begin
  RestoreForm(EditForm);
end;

procedure TEditForm.CancelButtonClick(Sender: TObject);
begin
  MainForm.BufDataset1.Cancel;
  ModalResult := mrCancel;
end;

procedure TEditForm.CB1Change(Sender: TObject);
begin
  MainForm.BufDataSet1.FieldByName('OS').AsString := CB1.Text;
end;

procedure TEditForm.CB2Change(Sender: TObject);
begin
  MainForm.BufDataSet1.FieldByName('Version').AsString := CB2.Text;
end;

procedure TEditForm.FormActivate(Sender: TObject);
var
  i: integer;
  St, ST1: string;
begin
  CB1.Clear;
  CB2.Clear;
  CB1.Text := DBEdit4.Text;
  CB2.Text := DBEdit5.Text;
  for i := 0 to 24 do
  begin
    if i < 10 then
      St := 'OS0' + IntToStr(i)
    else
      St := 'OS' + IntToStr(i);
    St1 := GetStdIni('OS', St, '');
    if St1 <> '' then
      CB1.Items.Add(St1);
  end;

  for i := 0 to 24 do
  begin
    if i < 10 then
      St := 'Versions0' + IntToStr(i)
    else
      St := 'Versions' + IntToStr(i);
    ;
    St1 := GetStdIni('Versions', St, '');
    if St1 <> '' then
      CB2.Items.Add(St1);
  end;
  MainForm.BufDataset1.Edit;
end;

procedure TEditForm.FormDestroy(Sender: TObject);
begin
  SaveForm(EditForm);
  Close;
end;

procedure TEditForm.SaveButtonClick(Sender: TObject);
begin
  MainForm.BufDataset1.Post;
  ModalResult := mrOk;
end;

end.
