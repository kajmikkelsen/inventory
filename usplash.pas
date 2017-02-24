Unit usplash;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

Type

  { TFSplash }

  TFSplash = Class(TForm)
    Image1: TImage;
  Private
    { private declarations }
  Public
    { public declarations }
  End;

Var
  FSplash: TFSplash;

Implementation

{$R *.lfm}

End.

