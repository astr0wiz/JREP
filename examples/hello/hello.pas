program hello;

{$mode objfpc}{$H+}

uses
  SDL2,
  jre,
  jre_types,
  jre_entity,
  jre_renderer,
  jre_input;

type
  TBox = class(TEntity)
  private
    FColor: TColor;
    FVelocity: TVector2;
    FBoundsW, FBoundsH: Single;
  public
    constructor Create(X, Y, W, H: Single; const AColor: TColor;
      VX, VY, BW, BH: Single); reintroduce;
    procedure Update(DeltaTime: Single); override;
    procedure Render(Renderer: TJRERenderer); override;
  end;

constructor TBox.Create(X, Y, W, H: Single; const AColor: TColor;
  VX, VY, BW, BH: Single);
begin
  inherited Create;
  FPosition  := TVector2.Create(X, Y);
  FSize      := TVector2.Create(W, H);
  FColor     := AColor;
  FVelocity  := TVector2.Create(VX, VY);
  FBoundsW   := BW;
  FBoundsH   := BH;
end;

procedure TBox.Update(DeltaTime: Single);
begin
  FPosition.X := FPosition.X + FVelocity.X * DeltaTime;
  FPosition.Y := FPosition.Y + FVelocity.Y * DeltaTime;
  if FPosition.X < 0 then
    begin FPosition.X := 0; FVelocity.X := -FVelocity.X; end;
  if FPosition.Y < 0 then
    begin FPosition.Y := 0; FVelocity.Y := -FVelocity.Y; end;
  if FPosition.X + FSize.X > FBoundsW then
    begin FPosition.X := FBoundsW - FSize.X; FVelocity.X := -FVelocity.X; end;
  if FPosition.Y + FSize.Y > FBoundsH then
    begin FPosition.Y := FBoundsH - FSize.Y; FVelocity.Y := -FVelocity.Y; end;
end;

procedure TBox.Render(Renderer: TJRERenderer);
begin
  Renderer.FillRect(GetBounds, FColor);
  Renderer.DrawRect(GetBounds, COLOR_WHITE);
end;

var
  Engine: TJREEngine;
begin
  Engine := TJREEngine.Create(JREConfig('JRE - Hello World', 800, 600));
  try
    Engine.Scene.Add(TBox.Create(100, 100, 60, 60, COLOR_RED,    150, 110, 800, 600));
    Engine.Scene.Add(TBox.Create(300, 200, 45, 45, COLOR_GREEN,  -90, 130, 800, 600));
    Engine.Scene.Add(TBox.Create(500, 150, 70, 70, COLOR_BLUE,   120, -80, 800, 600));
    Engine.Scene.Add(TBox.Create(200, 350, 35, 35, COLOR_YELLOW, -70,  95, 800, 600));
    Engine.Run;
  finally
    Engine.Free;
  end;
end.
