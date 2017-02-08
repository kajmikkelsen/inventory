// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

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
    Typ: string;
    { public declarations }
  end;

const
  MaxPoster = 25;

var
  FGroups: TFGroups;

implementation

uses
  MyLib;

{$R *.lfm}

{ TFGroups }

procedure TFGroups.FormCreate(Sender: TObject);
var
  i: integer;
  St: string;
begin
  SG1.RowCount := MaxPoster;
  RestoreForm(FGroups);
  SG1.DefaultColWidth := SG1.Width - 2;
  for i := 0 to MaxPoster - 1 do
  begin
    if i < 10 then
      St := Typ + '0' + IntToStr(i)
    else
      St := Typ + IntToStr(i);
    SG1.Cells[0, i] := GetStdIni(Typ, St, '');
  end;
end;

procedure TFGroups.CancelButtonClick(Sender: TObject);
var
  i: integer;
  St: string;
begin
  for i := 0 to MaxPoster - 1 do
  begin
    if i < 10 then
      St := typ + '0' + IntToStr(i)
    else
      St := Typ + IntToStr(i);
    SG1.Cells[0, i] := GetStdIni(Typ, St, '');
  end;
  ModalResult := mrCancel;
end;

procedure TFGroups.FormActivate(Sender: TObject);
var
  i: integer;
  St: string;
begin
  Caption := Typ;
  for i := 0 to MaxPoster - 1 do
  begin
    if i < 10 then
      St := typ + '0' + IntToStr(i)
    else
      St := Typ + IntToStr(i);
    SG1.Cells[0, i] := GetStdIni(Typ, St, '');
  end;
end;

procedure TFGroups.FormDestroy(Sender: TObject);
begin
  SaveForm(FGroups);
end;

procedure TFGroups.SaveButtonClick(Sender: TObject);
var
  i, Count: integer;
  St: string;
begin
  Count := 0;
  for I := 0 to MaxPoster - 1 do
  begin
    if SG1.Cells[0, i] <> '' then
    begin
      if Count < 10 then
        St := Typ + '0' + IntToStr(Count)
      else
        St := Typ + IntToStr(Count);
      PutStdIni(Typ, St, SG1.Cells[0, i]);
      Count := Count + 1;
    end;
  end;
  for i := Count to MaxPoster - 1 do
  begin
    if Count < 10 then
      St := Typ + '0' + IntToStr(i)
    else
      St := Typ + IntToStr(i);
    PutStdIni(Typ, St, '');
  end;
  ModalResult := mrOk;
end;

procedure TFGroups.SG1Resize(Sender: TObject);
begin
  SG1.DefaultColWidth := SG1.Width - 2;
end;

end.
