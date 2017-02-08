// Copyright 2017, Kaj Mikkelsen
// This software is distributed under the GPL 3 license
// The full text of the license can be found in the aboutbox
// as well as in the file "Copying"

unit UMyShowMessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFMyShowMessage }

  TFMyShowMessage = class(TForm)
    Button1: TButton;
    CB1: TCheckBox;
    Message: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FMyShowMessage: TFMyShowMessage;

implementation

uses
  mylib;

{$R *.lfm}

{ TFMyShowMessage }

procedure TFMyShowMessage.FormCreate(Sender: TObject);
begin
  RestoreForm(FMyShowMessage);
end;

procedure TFMyShowMessage.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if CB1.Checked then
    PutStdIni('Messages', message.Caption, 'False');
end;

procedure TFMyShowMessage.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFMyShowMessage.FormDestroy(Sender: TObject);
begin
  SaveForm(FMyShowMessage);
end;

end.
