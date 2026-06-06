unit jre_renderer;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SDL2, SDL2_image, SDL2_ttf,
  jre_types, jre_window;

type
  TTexture = record
    Handle: PSDL_Texture;
    Width, Height: Integer;
  end;

  TFont = record
    Handle: PTTF_Font;
    Size: Integer;
  end;

  TFlip = (fNone, fHorizontal, fVertical, fBoth);

  TJRERenderer = class
  private
    FHandle: PSDL_Renderer;
    FClearColor: TColor;
  public
    constructor Create(Window: TJREWindow; VSync: Boolean = True);
    destructor Destroy; override;

    { Frame lifecycle }
    procedure BeginFrame;
    procedure EndFrame;

    { Primitives }
    procedure DrawPoint(X, Y: Single; const AColor: TColor);
    procedure DrawLine(X1, Y1, X2, Y2: Single; const AColor: TColor);
    procedure DrawRect(const R: TRectF; const AColor: TColor);
    procedure FillRect(const R: TRectF; const AColor: TColor);

    { Textures }
    procedure DrawTexture(const T: TTexture; X, Y: Single); overload;
    procedure DrawTexture(const T: TTexture; const Dest: TRectF;
      Angle: Double = 0; Flip: TFlip = fNone); overload;
    procedure DrawTextureSrc(const T: TTexture; const Src, Dest: TRectF;
      Angle: Double = 0; Flip: TFlip = fNone);

    function  LoadTexture(const Path: string): TTexture;
    procedure FreeTexture(var T: TTexture);

    { Fonts / text }
    function  LoadFont(const Path: string; Size: Integer): TFont;
    procedure FreeFont(var F: TFont);
    procedure DrawText(const F: TFont; const Text: string;
      X, Y: Single; const AColor: TColor);
    procedure MeasureText(const F: TFont; const Text: string;
      out W, H: Integer);

    procedure SetClearColor(const AColor: TColor);
    property Handle: PSDL_Renderer read FHandle;
    property ClearColor: TColor read FClearColor write SetClearColor;
  end;

implementation

const
  IMG_FLAGS = IMG_INIT_PNG or IMG_INIT_JPG;

function FlipToSDL(F: TFlip): TSDL_RenderFlip;
begin
  case F of
    fHorizontal: Result := SDL_FLIP_HORIZONTAL;
    fVertical:   Result := SDL_FLIP_VERTICAL;
    fBoth:       Result := SDL_FLIP_HORIZONTAL or SDL_FLIP_VERTICAL;
  else
    Result := SDL_FLIP_NONE;
  end;
end;

constructor TJRERenderer.Create(Window: TJREWindow; VSync: Boolean);
var
  Flags: UInt32;
begin
  Flags := SDL_RENDERER_ACCELERATED;
  if VSync then
    Flags := Flags or SDL_RENDERER_PRESENTVSYNC;

  FHandle := SDL_CreateRenderer(Window.Handle, -1, Flags);
  if FHandle = nil then
    raise Exception.CreateFmt('Failed to create renderer: %s', [SDL_GetError()]);

  SDL_SetRenderDrawBlendMode(FHandle, SDL_BLENDMODE_BLEND);
  FClearColor := COLOR_BLACK;

  if IMG_Init(IMG_FLAGS) and IMG_FLAGS = 0 then
    raise Exception.CreateFmt('SDL_image init failed: %s', [IMG_GetError()]);

  if TTF_Init <> 0 then
    raise Exception.CreateFmt('SDL_ttf init failed: %s', [TTF_GetError()]);
end;

destructor TJRERenderer.Destroy;
begin
  TTF_Quit;
  IMG_Quit;
  if FHandle <> nil then
  begin
    SDL_DestroyRenderer(FHandle);
    FHandle := nil;
  end;
  inherited;
end;

procedure TJRERenderer.BeginFrame;
begin
  SDL_SetRenderDrawColor(FHandle,
    FClearColor.R, FClearColor.G, FClearColor.B, FClearColor.A);
  SDL_RenderClear(FHandle);
end;

procedure TJRERenderer.EndFrame;
begin
  SDL_RenderPresent(FHandle);
end;

procedure TJRERenderer.DrawPoint(X, Y: Single; const AColor: TColor);
begin
  SDL_SetRenderDrawColor(FHandle, AColor.R, AColor.G, AColor.B, AColor.A);
  SDL_RenderDrawPointF(FHandle, X, Y);
end;

procedure TJRERenderer.DrawLine(X1, Y1, X2, Y2: Single; const AColor: TColor);
begin
  SDL_SetRenderDrawColor(FHandle, AColor.R, AColor.G, AColor.B, AColor.A);
  SDL_RenderDrawLineF(FHandle, X1, Y1, X2, Y2);
end;

procedure TJRERenderer.DrawRect(const R: TRectF; const AColor: TColor);
var
  SR: TSDL_FRect;
begin
  SDL_SetRenderDrawColor(FHandle, AColor.R, AColor.G, AColor.B, AColor.A);
  SR.x := R.X; SR.y := R.Y; SR.w := R.W; SR.h := R.H;
  SDL_RenderDrawRectF(FHandle, @SR);
end;

procedure TJRERenderer.FillRect(const R: TRectF; const AColor: TColor);
var
  SR: TSDL_FRect;
begin
  SDL_SetRenderDrawColor(FHandle, AColor.R, AColor.G, AColor.B, AColor.A);
  SR.x := R.X; SR.y := R.Y; SR.w := R.W; SR.h := R.H;
  SDL_RenderFillRectF(FHandle, @SR);
end;

procedure TJRERenderer.DrawTexture(const T: TTexture; X, Y: Single);
var
  D: TSDL_FRect;
begin
  D.x := X; D.y := Y; D.w := T.Width; D.h := T.Height;
  SDL_RenderCopyF(FHandle, T.Handle, nil, @D);
end;

procedure TJRERenderer.DrawTexture(const T: TTexture; const Dest: TRectF;
  Angle: Double; Flip: TFlip);
var
  D: TSDL_FRect;
begin
  D.x := Dest.X; D.y := Dest.Y; D.w := Dest.W; D.h := Dest.H;
  SDL_RenderCopyExF(FHandle, T.Handle, nil, @D, Angle, nil, FlipToSDL(Flip));
end;

procedure TJRERenderer.DrawTextureSrc(const T: TTexture;
  const Src, Dest: TRectF; Angle: Double; Flip: TFlip);
var
  S: TSDL_Rect;
  D: TSDL_FRect;
begin
  S.x := Round(Src.X); S.y := Round(Src.Y);
  S.w := Round(Src.W); S.h := Round(Src.H);
  D.x := Dest.X; D.y := Dest.Y; D.w := Dest.W; D.h := Dest.H;
  SDL_RenderCopyExF(FHandle, T.Handle, @S, @D, Angle, nil, FlipToSDL(Flip));
end;

function TJRERenderer.LoadTexture(const Path: string): TTexture;
begin
  Result.Handle := IMG_LoadTexture(FHandle, PAnsiChar(AnsiString(Path)));
  if Result.Handle = nil then
    raise Exception.CreateFmt('Failed to load texture "%s": %s',
      [Path, IMG_GetError()]);
  SDL_QueryTexture(Result.Handle, nil, nil, @Result.Width, @Result.Height);
end;

procedure TJRERenderer.FreeTexture(var T: TTexture);
begin
  if T.Handle <> nil then
  begin
    SDL_DestroyTexture(T.Handle);
    T.Handle := nil;
  end;
end;

function TJRERenderer.LoadFont(const Path: string; Size: Integer): TFont;
begin
  Result.Handle := TTF_OpenFont(PAnsiChar(AnsiString(Path)), Size);
  if Result.Handle = nil then
    raise Exception.CreateFmt('Failed to load font "%s": %s',
      [Path, TTF_GetError()]);
  Result.Size := Size;
end;

procedure TJRERenderer.FreeFont(var F: TFont);
begin
  if F.Handle <> nil then
  begin
    TTF_CloseFont(F.Handle);
    F.Handle := nil;
  end;
end;

procedure TJRERenderer.DrawText(const F: TFont; const Text: string;
  X, Y: Single; const AColor: TColor);
var
  SDLColor: TSDL_Color;
  Surface: PSDL_Surface;
  Tex: PSDL_Texture;
  D: TSDL_FRect;
  W, H: Integer;
begin
  SDLColor.r := AColor.R; SDLColor.g := AColor.G;
  SDLColor.b := AColor.B; SDLColor.a := AColor.A;

  Surface := TTF_RenderText_Blended(F.Handle,
    PAnsiChar(AnsiString(Text)), SDLColor);
  if Surface = nil then Exit;

  Tex := SDL_CreateTextureFromSurface(FHandle, Surface);
  SDL_FreeSurface(Surface);
  if Tex = nil then Exit;

  SDL_QueryTexture(Tex, nil, nil, @W, @H);
  D.x := X; D.y := Y; D.w := W; D.h := H;
  SDL_RenderCopyF(FHandle, Tex, nil, @D);
  SDL_DestroyTexture(Tex);
end;

procedure TJRERenderer.MeasureText(const F: TFont; const Text: string;
  out W, H: Integer);
begin
  TTF_SizeText(F.Handle, PAnsiChar(AnsiString(Text)), @W, @H);
end;

procedure TJRERenderer.SetClearColor(const AColor: TColor);
begin
  FClearColor := AColor;
end;

end.
