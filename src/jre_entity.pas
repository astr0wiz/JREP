unit jre_entity;

{$mode objfpc}{$H+}

interface

uses
  jre_types, jre_renderer;

type
  TEntity = class
  protected
    FPosition: TVector2;
    FSize:     TVector2;
    FActive:   Boolean;
    FVisible:  Boolean;
    FTag:      string;
    FLayer:    Integer;
  public
    constructor Create; virtual;
    procedure Update(DeltaTime: Single); virtual;
    procedure Render(Renderer: TJRERenderer); virtual;
    function  GetBounds: TRectF;
    function  Intersects(Other: TEntity): Boolean;
    property Position: TVector2 read FPosition write FPosition;
    property Size:     TVector2 read FSize     write FSize;
    property Active:   Boolean  read FActive   write FActive;
    property Visible:  Boolean  read FVisible  write FVisible;
    property Tag:      string   read FTag      write FTag;
    property Layer:    Integer  read FLayer    write FLayer;
  end;

implementation

constructor TEntity.Create;
begin
  FActive  := True;
  FVisible := True;
  FLayer   := 0;
  FPosition := TVector2.Create(0, 0);
  FSize     := TVector2.Create(0, 0);
end;

procedure TEntity.Update(DeltaTime: Single);
begin
end;

procedure TEntity.Render(Renderer: TJRERenderer);
begin
end;

function TEntity.GetBounds: TRectF;
begin
  Result := TRectF.Create(FPosition.X, FPosition.Y, FSize.X, FSize.Y);
end;

function TEntity.Intersects(Other: TEntity): Boolean;
begin
  Result := GetBounds.Intersects(Other.GetBounds);
end;

end.
