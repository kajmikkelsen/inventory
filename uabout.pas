unit uabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFAbout }

  TFAbout = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FAbout: TFAbout;

implementation
Uses
  MyLib;
{$R *.lfm}

{ TFAbout }

procedure TFAbout.FormCreate(Sender: TObject);
begin
  RestoreForm(FAbout);
end;

procedure TFAbout.Button1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TFAbout.FormDestroy(Sender: TObject);
begin
  SaveForm(FAbout);
end;

end.

