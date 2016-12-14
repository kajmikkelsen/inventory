unit UGroups;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids;

type

  { TFGroups }

  TFGroups = class(TForm)
    SaveButton: TButton;
    CancelButton: TButton;
    SG1: TStringGrid;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure SG1Resize(Sender: TObject);
  private
    { private declarations }
  public
    Typ: String;
    { public declarations }
  end;

var
  FGroups: TFGroups;

implementation
 Uses
   MyLib;

{$R *.lfm}

 { TFGroups }

procedure TFGroups.FormCreate(Sender: TObject);
Var
  i:Integer;
  St: String;
begin
  RestoreForm(FGroups);
  SG1.DefaultColWidth:=SG1.Width-2;
  For i := 0 to 14 Do
  begin
    If i < 10 Then
      St := Typ+'0'+IntToSTr(i)
    Else
      St := Typ+IntToStr(i);
    SG1.Cells[0,i] := GetStdIni(Typ,St,'');
  end;
end;

procedure TFGroups.CancelButtonClick(Sender: TObject);
Var
  i:Integer;
  St: String;
begin
  For i := 0 to 14 Do
  begin
    If i < 10 Then
      St := typ+'0'+IntToSTr(i)
    Else
      St := Typ+IntToStr(i);
    SG1.Cells[0,i] := GetStdIni(Typ,St,'');
  end;
  ModalResult := MrCancel;
end;

procedure TFGroups.FormActivate(Sender: TObject);
  Var
    i:Integer;
    St: String;
  begin
    Caption := Typ;
    For i := 0 to 14 Do
    begin
      If i < 10 Then
        St := typ+'0'+IntToSTr(i)
      Else
        St := Typ+IntToStr(i);
      SG1.Cells[0,i] := GetStdIni(Typ,St,'');
    end;
end;

 procedure TFGroups.FormDestroy(Sender: TObject);
 begin
   SaveForm(FGroups);
 end;

procedure TFGroups.SaveButtonClick(Sender: TObject);
Var
  i,Count: Integer;
  St: String;
begin
  Count := 0;
  For I := 0 to 14 Do
  begin
    If SG1.Cells[0,i] <> '' Then
    Begin
      If Count < 10 Then
        St := Typ+'0'+IntToStr(Count)
      Else
        St := Typ+IntToStr(Count);
      PutStdIni(Typ,St,SG1.Cells[0,i]);
      Count := Count+1;
    end;
  end;
  For i := Count to 14 Do
  Begin
    If Count < 10 Then
      St := Typ+'0'+IntToStr(i)
    Else
      St := Typ+IntToStr(i);
    PutStdIni(Typ,St,'');
  end;
  ModalResult := MrOK;
end;

procedure TFGroups.SG1Resize(Sender: TObject);
begin
  SG1.DefaultColWidth:=SG1.Width-2;
end;

end.

