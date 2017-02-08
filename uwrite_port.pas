// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

unit uwrite_port;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TFWrite_Port }

  TFWrite_Port = class(TForm)
    Button1: TButton;
    CancelButton: TButton;
    RadioGroup1: TRadioGroup;
    SD1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FWrite_Port: TFWrite_Port;

implementation

uses
  MyLib, Main;

{$R *.lfm}

{ TFWrite_Port }

procedure TFWrite_Port.CancelButtonClick(Sender: TObject);
begin
  modalResult := mrCancel;
end;

procedure TFWrite_Port.Button1Click(Sender: TObject);
var
  Fl: TextFile;
begin
  if Sd1.Execute then
  begin
    PutStdIni('Settings', 'WriteSaveDir', SD1.InitialDir);
    PutStdIni('Settings', 'WriteSaveFile', SD1.FileName);
    try
      AssignFile(fl, SD1.FileName);
      Rewrite(Fl);
    except
      ShowMessage('Could not write to file' + SD1.FileName);
      Exit;
    end;
    with MainForm.BufDataset1 do
    begin
      First;
      while not EOF do
      begin
        if FieldByName(RadioGroup1.Items[RadioGroup1.ItemIndex]).AsBoolean then
          if FieldByName('Hostname').AsString <> '' then
            WriteLn(fl, FieldByName('Hostname').AsString);
        Next;
      end;
    end;
    CloseFile(Fl);
  end;
  ModalResult := mrOk;
end;

procedure TFWrite_Port.FormCreate(Sender: TObject);
begin
  RestoreForm(Fwrite_Port);
end;

procedure TFWrite_Port.FormDestroy(Sender: TObject);
begin
  SaveForm(FWrite_Port);
end;

end.
