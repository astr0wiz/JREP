unit jre;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SDL2,
  jre_types,
  jre_window,
  jre_renderer,
  jre_input,
  jre_audio,
  jre_assets,
  jre_entity,
  jre_scene;

type
  TJREConfig = record
    Title:      string;
    Width:      Integer;
    Height:     Integer;
    TargetFPS:  Integer;
    Fullscreen: Boolean;
    VSync:      Boolean;
    AssetPath:  string;
  end;

  TJREEngine = class
  private
    FWindow:    TJREWindow;
    FRenderer:  TJRERenderer;
    FInput:     TJREInput;
    FAudio:     TJREAudio;
    FAssets:    TJREAssets;
    FScene:     TScene;
    FRunning:   Boolean;
    FDeltaTime: Single;
    FFrameMs:   UInt32;
    procedure ProcessEvents;
  public
    constructor Create(const Config: TJREConfig);
    destructor Destroy; override;
    procedure Run;
    procedure Quit;
    property Window:    TJREWindow   read FWindow;
    property Renderer:  TJRERenderer read FRenderer;
    property Input:     TJREInput    read FInput;
    property Audio:     TJREAudio    read FAudio;
    property Assets:    TJREAssets   read FAssets;
    property Scene:     TScene       read FScene;
    property DeltaTime: Single       read FDeltaTime;
    property Running:   Boolean      read FRunning;
  end;

function JREConfig(const Title: string; Width, Height: Integer;
  FPS: Integer = 60; Fullscreen: Boolean = False;
  VSync: Boolean = True; const AssetPath: string = 'assets'): TJREConfig;

implementation

function JREConfig(const Title: string; Width, Height, FPS: Integer;
  Fullscreen, VSync: Boolean; const AssetPath: string): TJREConfig;
begin
  Result.Title      := Title;
  Result.Width      := Width;
  Result.Height     := Height;
  Result.TargetFPS  := FPS;
  Result.Fullscreen := Fullscreen;
  Result.VSync      := VSync;
  Result.AssetPath  := AssetPath;
end;

constructor TJREEngine.Create(const Config: TJREConfig);
begin
  if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO or SDL_INIT_JOYSTICK) < 0 then
    raise Exception.CreateFmt('SDL_Init failed: %s', [SDL_GetError()]);

  FFrameMs := 0;
  if Config.TargetFPS > 0 then
    FFrameMs := 1000 div Config.TargetFPS;

  FWindow   := TJREWindow.Create(Config.Title, Config.Width, Config.Height,
                 Config.Fullscreen);
  FRenderer := TJRERenderer.Create(FWindow, Config.VSync);
  FInput    := TJREInput.Create;
  FAudio    := TJREAudio.Create;
  FAssets   := TJREAssets.Create(FRenderer, FAudio, Config.AssetPath);
  FScene    := TScene.Create;
  FRunning  := False;
  FDeltaTime := 1.0 / 60.0;
end;

destructor TJREEngine.Destroy;
begin
  FScene.Free;
  FAssets.Free;
  FAudio.Free;
  FInput.Free;
  FRenderer.Free;
  FWindow.Free;
  SDL_Quit;
  inherited;
end;

procedure TJREEngine.ProcessEvents;
var
  Event: TSDL_Event;
begin
  FInput.BeginFrame;
  while SDL_PollEvent(@Event) <> 0 do
    FInput.ProcessEvent(Event);
end;

procedure TJREEngine.Run;
var
  FrameStart, FrameEnd, Elapsed: UInt32;
begin
  FRunning := True;

  while FRunning do
  begin
    FrameStart := SDL_GetTicks;

    ProcessEvents;
    if FInput.QuitRequested then
      FRunning := False;

    FScene.Update(FDeltaTime);

    FRenderer.BeginFrame;
    FScene.Render(FRenderer);
    FRenderer.EndFrame;

    FrameEnd := SDL_GetTicks;
    Elapsed  := FrameEnd - FrameStart;

    if (FFrameMs > 0) and (Elapsed < FFrameMs) then
      SDL_Delay(FFrameMs - Elapsed);

    FrameEnd := SDL_GetTicks;
    if FrameEnd > FrameStart then
      FDeltaTime := (FrameEnd - FrameStart) / 1000.0
    else
      FDeltaTime := FFrameMs / 1000.0;
  end;
end;

procedure TJREEngine.Quit;
begin
  FRunning := False;
end;

end.
