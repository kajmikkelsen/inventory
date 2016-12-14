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
    Groups: String;
  end;

var
  FGroupEdit: TFGroupEdit;

implementation

{$R *.lfm}
Uses
  MyLib;

{ TFGroupEdit }

procedure TFGroupEdit.OKButtonClick(Sender: TObject);
Var
  i:Integer;
  MyComponent: TComponent;
begin
  Groups := '';
  For i := 1 to 15 Do
  begin
    MyComponent := FGroupEdit.FindComponent('CheckBox'+IntToStr(i));
    If TCheckBox(MyComponent).Checked Then
    Begin
      If Groups <> '' Then
        Groups := Groups+',';
      Groups := Groups+TCheckBox(MyComponent).Caption;
    end;
  end;
  ModalResult := mrOk;
end;

procedure TFGroupEdit.CancelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFGroupEdit.FormActivate(Sender: TObject);
Var
    i,i1:Integer;
    St:STring;
    MyComponent: TComponent;
    Strl: TStringList;
begin
  Strl := TStringList.Create;
  If Groups <> '' Then
    Split(Groups,',',Strl);
   For i := 0 to 14 Do
  begin
    If i < 10 Then
      St := 'Group0'+IntToSTr(i)
    Else
      St := 'Group'+IntToStr(i);
    MyComponent := FGroupEdit.FindComponent('CheckBox'+IntToStr(i+1));
    If MyComponent <> Nil Then
    Begin
      TCheckBox(MyComponent).Caption := GetStdIni('Group',St,'');
      TCheckBox(MyComponent).Checked := False;
      If TCheckBox(MyComponent).Caption <> '' Then
      Begin
        TCheckBox(MyComponent).Enabled := True;
        For i1 := 0 To Strl.Count - 1 Do
          If TCheckBox(MyComponent).Caption = Strl[i1] Then
             TCheckBox(MyComponent).Checked := True;
      end
      Else
        TCheckBox(MyComponent).Enabled := False;
    end;
  end;
   Strl.Free;
end;

procedure TFGroupEdit.FormCreate(Sender: TObject);
begin
  RestoreForm(FGroupEdit)
end;

procedure TFGroupEdit.FormDestroy(Sender: TObject);
begin
  SaveForm(FGroupEdit);
end;

end.

