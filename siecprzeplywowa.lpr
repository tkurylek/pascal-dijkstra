program siecprzeplywowa;

uses
  SysUtils;

const
  INFINITY = -1;

type
  NodePointer = ^Node;

  Node = record
    id: integer;
    neighbors: array of NodePointer;
    distanceToNeighbors: array of integer;
  end;

  function createNode(id: integer; neighborsCount: integer): NodePointer;
  var
    buildedNode: Node;
  begin
    buildedNode.id := id;
    SetLength(buildedNode.neighbors, neighborsCount);
    SetLength(buildedNode.distanceToNeighbors, neighborsCount);
    createNode := @buildedNode;
  end;


const
  TESTERS_COUNT = 10;
var
  testers: array[0..TESTERS_COUNT] of NodePointer;
  id: integer;
begin
  for id := 0 to TESTERS_COUNT - 1 do
  begin
    testers[id] := createNode(id, TESTERS_COUNT);
  end;

  writeln('Hello World!');
  readln();
end.
