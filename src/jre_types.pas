unit jre_types;

{$mode objfpc}{$H+}

interface

uses Math;

type
  TVector2 = record
    X, Y: Single;
    class function Create(AX, AY: Single): TVector2; static; inline;
    function Add(const V: TVector2): TVector2; inline;
    function Sub(const V: TVector2): TVector2; inline;
    function Scale(Factor: Single): TVector2; inline;
    function Length: Single;
    function Normalized: TVector2;
    function Dot(const V: TVector2): Single; inline;
  end;

  TVector2i = record
    X, Y: Integer;
    class function Create(AX, AY: Integer): TVector2i; static; inline;
  end;

  TRectF = record
    X, Y, W, H: Single;
    class function Create(AX, AY, AW, AH: Single): TRectF; static; inline;
    function Contains(const V: TVector2): Boolean; inline;
    function Intersects(const R: TRectF): Boolean; inline;
  end;

  TColor = record
    R, G, B, A: Byte;
    class function Create(AR, AG, AB: Byte; AA: Byte = 255): TColor; static; inline;
  end;

const
  COLOR_WHITE: TColor = (R: 255; G: 255; B: 255; A: 255);
  COLOR_BLACK: TColor = (R: 0;   G: 0;   B: 0;   A: 255);
  COLOR_RED:   TColor = (R: 255; G: 0;   B: 0;   A: 255);
  COLOR_GREEN: TColor = (R: 0;   G: 255; B: 0;   A: 255);
  COLOR_BLUE:  TColor = (R: 0;   G: 0;   B: 255; A: 255);
  COLOR_YELLOW:TColor = (R: 255; G: 255; B: 0;   A: 255);
  COLOR_CLEAR: TColor = (R: 0;   G: 0;   B: 0;   A: 0);

implementation

class function TVector2.Create(AX, AY: Single): TVector2;
begin
  Result.X := AX;
  Result.Y := AY;
end;

function TVector2.Add(const V: TVector2): TVector2;
begin
  Result.X := X + V.X;
  Result.Y := Y + V.Y;
end;

function TVector2.Sub(const V: TVector2): TVector2;
begin
  Result.X := X - V.X;
  Result.Y := Y - V.Y;
end;

function TVector2.Scale(Factor: Single): TVector2;
begin
  Result.X := X * Factor;
  Result.Y := Y * Factor;
end;

function TVector2.Length: Single;
begin
  Result := Sqrt(X * X + Y * Y);
end;

function TVector2.Normalized: TVector2;
var
  Len: Single;
begin
  Len := Length;
  if Len > 0 then
  begin
    Result.X := X / Len;
    Result.Y := Y / Len;
  end
  else
    Result := Self;
end;

function TVector2.Dot(const V: TVector2): Single;
begin
  Result := X * V.X + Y * V.Y;
end;

class function TVector2i.Create(AX, AY: Integer): TVector2i;
begin
  Result.X := AX;
  Result.Y := AY;
end;

class function TRectF.Create(AX, AY, AW, AH: Single): TRectF;
begin
  Result.X := AX;
  Result.Y := AY;
  Result.W := AW;
  Result.H := AH;
end;

function TRectF.Contains(const V: TVector2): Boolean;
begin
  Result := (V.X >= X) and (V.X <= X + W) and
             (V.Y >= Y) and (V.Y <= Y + H);
end;

function TRectF.Intersects(const R: TRectF): Boolean;
begin
  Result := (X < R.X + R.W) and (X + W > R.X) and
             (Y < R.Y + R.H) and (Y + H > R.Y);
end;

class function TColor.Create(AR, AG, AB: Byte; AA: Byte): TColor;
begin
  Result.R := AR;
  Result.G := AG;
  Result.B := AB;
  Result.A := AA;
end;

end.
