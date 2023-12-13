unit Constants;

interface

type
  // Не перепутай: atStart - "голова" стрелки (<-), atEnd - "хвост" стрелки (--)
  // То есть выполнение идёт от "хвоста" стрелки к "голове"
  TArrowTail = (atStart, atEnd);
  TArrowStyle = (eg2, eg4);
  TArrowType = (horiz, vert);
  TBlockPort = (North, East, West, South);
  TDragObj = (none, st, en, pnt);

const
  HotRadius = 5;
  ArrW = 4;
  ArrH = 10;
  BlockMargin = 12;
  MinDrag = 5;

implementation

end.
