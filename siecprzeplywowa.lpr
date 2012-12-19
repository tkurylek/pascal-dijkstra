program siecprzeplywowa;

uses
  SysUtils;

const
  INFINITY = High(integer);

type
  NodePointer = ^Node;

  Edge = record
    endNode: NodePointer;
    distanceToEndNode: integer;
  end;

  Node = record
    id: integer;
    edges: array of Edge;
  end;

  function createNode(id: integer; edgesCount: integer): NodePointer;
  var
    buildedNode: Node;
  begin
    buildedNode.id := id;
    SetLength(buildedNode.edges, edgesCount);
    createNode := @buildedNode;
  end;

type
  NodesList = record
    currentNode: NodePointer;
    nextNode: NodePointer;
  end;

  function hasNextNode(listOfNodes: NodesList): boolean;
  begin
    hasNextNode := listOfNodes.nextNode <> nil;
  end;

begin
  writeln('Hello World!');
  readln();
end.
