unit jre_input;

{$mode objfpc}{$H+}

interface

uses
  SDL2, jre_types;

const
  JRE_MAX_KEYS = 512;

type
  TMouseButton = (mbLeft = 1, mbMiddle = 2, mbRight = 3);

  TJREInput = class
  private
    FKeyDown: array[0..JRE_MAX_KEYS - 1] of Boolean;
    FKeyPressed: array[0..JRE_MAX_KEYS - 1] of Boolean;
    FKeyReleased: array[0..JRE_MAX_KEYS - 1] of Boolean;
    FMouseDown: array[TMouseButton] of Boolean;
    FMousePressed: array[TMouseButton] of Boolean;
    FMouseReleased: array[TMouseButton] of Boolean;
    FMousePos: TVector2;
    FMouseDelta: TVector2;
    FScrollDelta: TVector2;
    FQuitRequested: Boolean;
    function  KeyIdx(Key: TSDL_Scancode): Integer; inline;
    function  ValidButton(B: Integer): Boolean; inline;
  public
    procedure BeginFrame;
    procedure ProcessEvent(const Event: TSDL_Event);

    function IsKeyDown(Key: TSDL_Scancode): Boolean;
    function IsKeyPressed(Key: TSDL_Scancode): Boolean;
    function IsKeyReleased(Key: TSDL_Scancode): Boolean;
    function IsMouseDown(Button: TMouseButton): Boolean;
    function IsMousePressed(Button: TMouseButton): Boolean;
    function IsMouseReleased(Button: TMouseButton): Boolean;

    property MousePos: TVector2 read FMousePos;
    property MouseDelta: TVector2 read FMouseDelta;
    property ScrollDelta: TVector2 read FScrollDelta;
    property QuitRequested: Boolean read FQuitRequested;
  end;

implementation

function TJREInput.KeyIdx(Key: TSDL_Scancode): Integer;
begin
  Result := Integer(Key);
end;

function TJREInput.ValidButton(B: Integer): Boolean;
begin
  Result := (B >= Ord(Low(TMouseButton))) and (B <= Ord(High(TMouseButton)));
end;

procedure TJREInput.BeginFrame;
var
  B: TMouseButton;
begin
  FillChar(FKeyPressed,  SizeOf(FKeyPressed),  0);
  FillChar(FKeyReleased, SizeOf(FKeyReleased), 0);
  for B := Low(TMouseButton) to High(TMouseButton) do
  begin
    FMousePressed[B]  := False;
    FMouseReleased[B] := False;
  end;
  FMouseDelta.X  := 0; FMouseDelta.Y  := 0;
  FScrollDelta.X := 0; FScrollDelta.Y := 0;
end;

procedure TJREInput.ProcessEvent(const Event: TSDL_Event);
var
  Idx: Integer;
  B: TMouseButton;
begin
  case Event.type_ of
    SDL_QUITEV:
      FQuitRequested := True;

    SDL_KEYDOWN:
    begin
      Idx := KeyIdx(Event.key.keysym.scancode);
      if (Idx >= 0) and (Idx < JRE_MAX_KEYS) then
      begin
        if not FKeyDown[Idx] then FKeyPressed[Idx] := True;
        FKeyDown[Idx] := True;
      end;
    end;

    SDL_KEYUP:
    begin
      Idx := KeyIdx(Event.key.keysym.scancode);
      if (Idx >= 0) and (Idx < JRE_MAX_KEYS) then
      begin
        FKeyDown[Idx]     := False;
        FKeyReleased[Idx] := True;
      end;
    end;

    SDL_MOUSEMOTION:
    begin
      FMousePos.X    := Event.motion.x;
      FMousePos.Y    := Event.motion.y;
      FMouseDelta.X  := FMouseDelta.X + Event.motion.xrel;
      FMouseDelta.Y  := FMouseDelta.Y + Event.motion.yrel;
    end;

    SDL_MOUSEBUTTONDOWN:
    begin
      if ValidButton(Event.button.button) then
      begin
        B := TMouseButton(Event.button.button);
        if not FMouseDown[B] then FMousePressed[B] := True;
        FMouseDown[B] := True;
      end;
    end;

    SDL_MOUSEBUTTONUP:
    begin
      if ValidButton(Event.button.button) then
      begin
        B := TMouseButton(Event.button.button);
        FMouseDown[B]     := False;
        FMouseReleased[B] := True;
      end;
    end;

    SDL_MOUSEWHEEL:
    begin
      FScrollDelta.X := Event.wheel.x;
      FScrollDelta.Y := Event.wheel.y;
    end;
  end;
end;

function TJREInput.IsKeyDown(Key: TSDL_Scancode): Boolean;
var Idx: Integer;
begin
  Idx := KeyIdx(Key);
  Result := (Idx >= 0) and (Idx < JRE_MAX_KEYS) and FKeyDown[Idx];
end;

function TJREInput.IsKeyPressed(Key: TSDL_Scancode): Boolean;
var Idx: Integer;
begin
  Idx := KeyIdx(Key);
  Result := (Idx >= 0) and (Idx < JRE_MAX_KEYS) and FKeyPressed[Idx];
end;

function TJREInput.IsKeyReleased(Key: TSDL_Scancode): Boolean;
var Idx: Integer;
begin
  Idx := KeyIdx(Key);
  Result := (Idx >= 0) and (Idx < JRE_MAX_KEYS) and FKeyReleased[Idx];
end;

function TJREInput.IsMouseDown(Button: TMouseButton): Boolean;
begin
  Result := FMouseDown[Button];
end;

function TJREInput.IsMousePressed(Button: TMouseButton): Boolean;
begin
  Result := FMousePressed[Button];
end;

function TJREInput.IsMouseReleased(Button: TMouseButton): Boolean;
begin
  Result := FMouseReleased[Button];
end;

end.
