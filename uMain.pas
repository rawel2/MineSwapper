unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ExtCtrls, WinApi.CommCtrl, System.Types, ucoremineswapper,
  Vcl.Menus, Vcl.ComCtrls, Vcl.ToolWin, Vcl.StdCtrls, Vcl.Buttons;

type
  TfmMain = class(TForm)
    SpriteList: TImageList;
    MineField: TPaintBox;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    iNewGame: TMenuItem;
    N3: TMenuItem;
    iBeginner: TMenuItem;
    iFun: TMenuItem;
    iProfessional: TMenuItem;
    iCustom: TMenuItem;
    N8: TMenuItem;
    iExit: TMenuItem;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    inowa: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    NowaGra1: TMenuItem;
    Pocztkujcy1: TMenuItem;
    Gracz1: TMenuItem;
    Profesionalista1: TMenuItem;
    Wybr1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure MineFieldPaint(Sender: TObject);
    procedure MineFieldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure iExitClick(Sender: TObject);
    procedure iNewGameClick(Sender: TObject);
    procedure iBeginnerClick(Sender: TObject);
    procedure iFunClick(Sender: TObject);
    procedure iProfessionalClick(Sender: TObject);
    procedure iCustomClick(Sender: TObject);
    procedure MineFieldMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure iNewGameDlg(dlg: string; mH, mW, mM: integer);

  private
    { Private declarations }
    mFieldHeight: integer;
    mFieldWidth: integer;
    mFieldMines: integer;

  public
    { Public declarations }
    CoreMineSwapper: TCoreMineSwapper;
    czas : LONG ;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses uCustomForm;

procedure getGameState(const Win: boolean);
begin
  if Win then
    MessageBox(0,PWideChar('Rozminowa³eœ grê w czasie '+inttostr(fmMain.czas)+' s !!!'), PWideChar('Sukces!'), MB_ICONINFORMATION)
  else
    MessageBox(0,PWideChar('Trafi³eœ na minê w czasie '+inttostr(fmMain.czas)+' s !!!'), PWideChar('B³¹d!!!'), MB_ICONERROR);
end;

procedure getFlagsState(const Flags: integer);
begin
  fmMain.Caption := inttostr(Flags)+' / '+ inttostr(fmMain.CoreMineSwapper.MineCount);
  fmMain.StatusBar1.Panels[1].Text := fmMain.Caption;
  fmMain.TrayIcon1.Hint := fmMain.Caption;

end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Randomize;

  CoreMineSwapper := TCoreMineSwapper.Create(Self);
  CoreMineSwapper.Canvas := @MineField.Canvas;
  CoreMineSwapper.LoadSprite(SpriteList.Height, SpriteList.Width, SpriteList);

  CoreMineSwapper.GameState := @getGameState;
  CoreMineSwapper.FlagsState := @getFlagsState;

  MineField.Top  := 35;
  MineField.Left := 10;

  iNewGameDlg('',16,16,40);
end;



procedure TfmMain.iExitClick(Sender: TObject);
begin
  close;
end;

procedure TfmMain.iNewGameDlg(dlg: string;mH , mW , mM: integer);
begin
  if not CoreMineSwapper.EndGame then
    if (length(dlg)> 0) and (MessageDlg(dlg,mtConfirmation, [mbYes, mbNo],0) = mrNo) then exit;

  mFieldHeight := mH;
  mFieldWidth := mW;
  mFieldMines := Mm;
  CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);
  czas:=0;
  MineField.Height := CoreMineSwapper.FieldHeightPixel;
  MineField.Width  := CoreMineSwapper.FieldWidthPixel;

  ClientHeight := MineField.Height + 60;
  ClientWidth  := MineField.Width  + 20;
end;

procedure TfmMain.iNewGameClick(Sender: TObject);
begin
  iNewGameDlg('Czy rozpocz¹æ now¹ grê?',mFieldHeight,mFieldWidth,mFieldMines);
end;

procedure TfmMain.iBeginnerClick(Sender: TObject);
begin
  iNewGameDlg('Czy zmieniæ poziom gry na Pocz¹tkuj¹cy?',9,9,10);
end;

procedure TfmMain.iFunClick(Sender: TObject);
begin
  iNewGameDlg('Czy zmieniæ poziom gry na Gracz?',16,16,40);
end;

procedure TfmMain.iProfessionalClick(Sender: TObject);
begin
  iNewGameDlg('Czy zmieniæ poziom gry na Profesionalista?',16,32,99);
end;

procedure TfmMain.iCustomClick(Sender: TObject);
var
  frm: TfmCustomForm;
begin
  frm := TfmCustomForm.Create(self);

  frm.edHeight.Text := inttostr( CoreMineSwapper.Height );
  frm.edWidth.Text := inttostr( CoreMineSwapper.Width );
  frm.edMines.Text := inttostr( CoreMineSwapper.MineCount );

  if frm.ShowModal = mrOk then begin
    mFieldHeight := strtoint(frm.edHeight.Text);
    mFieldWidth := strtoint(frm.edWidth.Text);
    mFieldMines := strtoint(frm.edMines.Text);

    if mFieldWidth < 5 then mFieldWidth := 5;
    if mFieldHeight < 5 then mFieldHeight := 5;
    if mFieldWidth > 40 then mFieldWidth := 40;
    if mFieldHeight > 40 then mFieldHeight := 40;
    if mFieldMines < 5 then mFieldMines := 5;
    if mFieldMines > mFieldWidth*mFieldHeight div 3 then
      mFieldMines := mFieldWidth*mFieldHeight div 3;

    iNewGameDlg('',mFieldHeight,mFieldWidth,mFieldMines);
  end;

  frm.Free;
end;

procedure TfmMain.MineFieldMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  fX, fY: integer;
begin
    fX := X div CoreMineSwapper.SpriteWidth;
    fY := Y div CoreMineSwapper.SpriteHeight;

  if CoreMineSwapper.isMine(fX,fY) then
     StatusBar1.Panels[0].Text := '.'
     else
     StatusBar1.Panels[0].Text := ' ';
end;

procedure TfmMain.MineFieldMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  fX, fY: integer;
begin
  if CoreMineSwapper.EndGame then
  begin
    CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);
    czas:=0;
    exit;
  end;

  fX := X div CoreMineSwapper.SpriteWidth;
  fY := Y div CoreMineSwapper.SpriteHeight;

  if (Button = mbLeft) then CoreMineSwapper.OpenCell(fX, fY);
  if (Button = mbRight) then CoreMineSwapper.SetFlag(fX, fY);

end;

procedure TfmMain.MineFieldPaint(Sender: TObject);
begin
  CoreMineSwapper.Repaint;
end;


procedure TfmMain.Timer1Timer(Sender: TObject);
begin
  czas := czas+1;
  StatusBar1.Panels[2].Text := inttostr(czas);
end;

end.
