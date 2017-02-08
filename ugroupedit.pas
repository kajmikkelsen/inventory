// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

unit ugroupedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFGroupEdit }

  TFGroupEdit = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    OKButton: TButton;
    CancelButton: TButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Groups: string;
  end;

var
  FGroupEdit: TFGroupEdit;

implementation

{$R *.lfm}
uses
  MyLib;

{ TFGroupEdit }
procedure TFGroupEdit.OKButtonClick(Sender: TObject);
var
  i: integer;
  MyComponent: TComponent;
begin
  Groups := '';
  for i := 1 to 15 do
  begin
    MyComponent := FGroupEdit.FindComponent('CheckBox' + IntToStr(i));
    if TCheckBox(MyComponent).Checked then
    begin
      if Groups <> '' then
        Groups := Groups + ',';
      Groups := Groups + TCheckBox(MyComponent).Caption;
    end;
  end;
  ModalResult := mrOk;
end;

procedure TFGroupEdit.CancelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFGroupEdit.FormActivate(Sender: TObject);
var
  i, i1: integer;
  St: string;
  MyComponent: TComponent;
  Strl: TStringList;
begin
  Strl := TStringList.Create;
  if Groups <> '' then
    Split(Groups, ',', Strl);
  for i := 0 to 14 do
  begin
    if i < 10 then
      St := 'Group0' + IntToStr(i)
    else
      St := 'Group' + IntToStr(i);
    MyComponent := FGroupEdit.FindComponent('CheckBox' + IntToStr(i + 1));
    if MyComponent <> nil then
    begin
      TCheckBox(MyComponent).Caption := GetStdIni('Group', St, '');
      TCheckBox(MyComponent).Checked := False;
      if TCheckBox(MyComponent).Caption <> '' then
      begin
        TCheckBox(MyComponent).Enabled := True;
        for i1 := 0 to Strl.Count - 1 do
          if TCheckBox(MyComponent).Caption = Strl[i1] then
            TCheckBox(MyComponent).Checked := True;
      end
      else
        TCheckBox(MyComponent).Enabled := False;
    end;
  end;
  Strl.Free;
end;

procedure TFGroupEdit.FormCreate(Sender: TObject);
begin
  RestoreForm(FGroupEdit);
end;

procedure TFGroupEdit.FormDestroy(Sender: TObject);
begin
  SaveForm(FGroupEdit);
end;

end.

