unit jre_window;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SDL2;

type
  TJREWindow = class
  private
    FHandle: PSDL_Window;
    FWidth: Integer;
    FHeight: Integer;
    FTitle: string;
  public
    constructor Create(const ATitle: string; AWidth, AHeight: Integer;
      AFullscreen: Boolean = False);
    destructor Destroy; override;
    procedure SetTitle(const ATitle: string);
    procedure GetSize(out AWidth, AHeight: Integer);
    property Handle: PSDL_Window read FHandle;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Title: string read FTitle;
  end;

implementation

constructor TJREWindow.Create(const ATitle: string; AWidth, AHeight: Integer;
  AFullscreen: Boolean);
var
  Flags: UInt32;
begin
  FTitle  := ATitle;
  FWidth  := AWidth;
  FHeight := AHeight;

  Flags := SDL_WINDOW_SHOWN;
  if AFullscreen then
    Flags := Flags or SDL_WINDOW_FULLSCREEN_DESKTOP;

  FHandle := SDL_CreateWindow(
    PAnsiChar(AnsiString(ATitle)),
    SDL_WINDOWPOS_CENTERED,
    SDL_WINDOWPOS_CENTERED,
    AWidth, AHeight,
    Flags
  );

  if FHandle = nil then
    raise Exception.CreateFmt('Failed to create window: %s', [SDL_GetError()]);
end;

destructor TJREWindow.Destroy;
begin
  if FHandle <> nil then
  begin
    SDL_DestroyWindow(FHandle);
    FHandle := nil;
  end;
  inherited;
end;

procedure TJREWindow.SetTitle(const ATitle: string);
begin
  FTitle := ATitle;
  SDL_SetWindowTitle(FHandle, PAnsiChar(AnsiString(ATitle)));
end;

procedure TJREWindow.GetSize(out AWidth, AHeight: Integer);
begin
  SDL_GetWindowSize(FHandle, @AWidth, @AHeight);
  FWidth  := AWidth;
  FHeight := AHeight;
end;

end.
