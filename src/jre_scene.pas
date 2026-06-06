unit jre_scene;

{$mode objfpc}{$H+}

interface

uses
  fgl,
  jre_entity, jre_renderer;

type
  TEntityList = specialize TFPGObjectList<TEntity>;

  TScene = class
  private
    FEntities:      TEntityList;
    FPendingAdd:    TEntityList;
    FPendingRemove: TEntityList;
    procedure FlushPending;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Entity: TEntity);
    procedure Remove(Entity: TEntity);
    procedure Update(DeltaTime: Single);
    procedure Render(Renderer: TJRERenderer);
    procedure Clear;
    function  FindByTag(const Tag: string): TEntity;
    function  Count: Integer;
  end;

implementation

constructor TScene.Create;
begin
  FEntities      := TEntityList.Create(True);
  FPendingAdd    := TEntityList.Create(False);
  FPendingRemove := TEntityList.Create(False);
end;

destructor TScene.Destroy;
begin
  FPendingAdd.Free;
  FPendingRemove.Free;
  FEntities.Free;
  inherited;
end;

procedure TScene.FlushPending;
var
  E: TEntity;
begin
  for E in FPendingAdd do
    FEntities.Add(E);
  FPendingAdd.Clear;

  for E in FPendingRemove do
    FEntities.Remove(E);
  FPendingRemove.Clear;
end;

procedure TScene.Add(Entity: TEntity);
begin
  FPendingAdd.Add(Entity);
end;

procedure TScene.Remove(Entity: TEntity);
begin
  FPendingRemove.Add(Entity);
end;

procedure TScene.Update(DeltaTime: Single);
var
  E: TEntity;
begin
  FlushPending;
  for E in FEntities do
    if E.Active then
      E.Update(DeltaTime);
end;

procedure TScene.Render(Renderer: TJRERenderer);
var
  E: TEntity;
begin
  for E in FEntities do
    if E.Visible then
      E.Render(Renderer);
end;

procedure TScene.Clear;
begin
  FPendingAdd.Clear;
  FPendingRemove.Clear;
  FEntities.Clear;
end;

function TScene.FindByTag(const Tag: string): TEntity;
var
  E: TEntity;
begin
  Result := nil;
  for E in FEntities do
    if E.Tag = Tag then
    begin
      Result := E;
      Exit;
    end;
end;

function TScene.Count: Integer;
begin
  Result := FEntities.Count;
end;

end.
