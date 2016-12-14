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
Uses
  MyLib,Main;
{$R *.lfm}

{ TFWrite_Port }

procedure TFWrite_Port.CancelButtonClick(Sender: TObject);
begin
  modalResult := mrCancel;
end;

procedure TFWrite_Port.Button1Click(Sender: TObject);
Var
  Fl:TextFile;
begin
  If Sd1.Execute Then
  Begin
    PutStdIni('Settings','WriteSaveDir',SD1.InitialDir);
    PutStdIni('Settings','WriteSaveFile',SD1.FileName);
    Try
      AssignFile(fl,SD1.FileName);
      Rewrite(Fl);
    Except
      ShowMessage('Could not write to file'+SD1.FileName);
      Exit;
    end;
    With MainForm.BufDataset1 do
    begin
      First;
      While Not Eof Do
      begin
        If FieldByName(RadioGroup1.Items[RadioGroup1.ItemIndex]).AsBoolean Then
          WriteLn(fl,FieldByName('Hostname').AsString);
        Next;
      end;
    end;
  end;
  CloseFile(Fl);
  ModalResult := mrOK;
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

