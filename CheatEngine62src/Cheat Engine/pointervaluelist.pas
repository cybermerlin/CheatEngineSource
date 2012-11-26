unit pointervaluelist;

{$MODE Delphi}

{
The pointerlist will hold a map of all possible pointer values, and the addresses that link to them
it also contains some extra information like if it's static just so the pointerscan can save some calls doing it itself eachtime
}

interface

uses windows, LCLIntf, dialogs, SysUtils, classes, ComCtrls, CEFuncProc, NewKernelHandler,
     symbolhandler, math,bigmemallochandler;

type
  PStaticData=^TStaticData;
  TStaticData=record
    moduleindex: dword; //for searching the saved modulelist
    offset: dword; //no need to convert this to a ptrUint, max size of an executable is still 4GB in 64-bit
  end;

  TPointerDataArray=array [0..0] of record
    address: ptrUint;
    staticdata: PStaticData; //is set to not nil if it is a static address
  end;

  PPointerDataArray=^TPointerDataArray;



  PPointerList=^TPointerList;
  TPointerlist=record
    maxsize: integer;
    expectedsize: integer;
    pos: integer;
    list: PPointerDataArray;

    //Linked list
    PointerValue: ptrUint;
    Previous: PPointerList;
    Next: PPointerList;
  end;

  PReversePointerTable=^TReversePointerTable;
  PReversePointerListArray=^TReversePointerListArray;
  TReversePointerTable=record
    case integer of
      1: (pointerlist: PPointerList); //if this is the last level (maxlevel) this is an PPointerList
      2: (ReversePointerlistArray: PReversePointerListArray);   //else it's a PReversePointerListArray
  end;
  TReversePointerListArray=array [0..15] of TReversePointerTable;



  //-
  TMemrectablearraylist = array [0..15] of record
     arr:PReversePointerListArray;
     entrynr: ValUInt;
  end;

  PMemrectablearraylist=^TMemrectablearraylist;
  //^

  TReversePointerListHandler=class
  private
    memoryregion: array of TMemoryRegion;
    level0list: PReversePointerListArray;
    maxlevel: ValUInt;

    firstPointerValue: PPointerList;
    lastPointerValue: PPointerList;

    bigalloc: TBigMemoryAllocHandler;
    function BinSearchMemRegions(address: ptrUint): integer;
    function ispointer(address: ptrUint): boolean;
    procedure quicksortmemoryregions(lo,hi: integer);

    procedure addpointer(pointervalue: ptrUint; pointerwiththisvalue: ptrUint; add:boolean);
    procedure DeletePath(addresslist: PReversePointerListArray; level: integer);

    //--
    function findMaxOfPath(lvl: PMemrectablearraylist; a: PReversePointerListArray; level: ValUInt):PPointerList;
    function findprevious(lvl: PMemrectablearraylist; level: ValUInt):PPointerList;
    function findClosestPointer(addresslist: PReversePointerListArray; entrynr: integer; level: integer; maxvalue: ptrUint): PPointerList;

    procedure fillList(addresslist: PReversePointerListArray; level: integer; var prev: PPointerList);
    procedure fillLinkedList;
  public
    count: qword;

    modulelist: tstringlist;

    procedure saveModuleListToResults(s: TStream);

    function findPointerValue(startvalue: ptrUint; var stopvalue: ptrUint): PPointerList;
    constructor create(start, stop: ptrUint; alligned: boolean; progressbar: tprogressbar; noreadonly: boolean);
    destructor destroy; override;
  end;

implementation

resourcestring
  rsPointerValueSetupError = 'Pointer value setup error';
  rsNoMemoryFoundInTheSpecifiedRegion = 'No memory found in the specified '
    +'region';
  rsAllocatingBytesToBuffer = 'Allocating %s bytes to ''buffer''';
  rsNotEnoughMemoryFreeToScan = 'Not enough memory free to scan';

type TMemoryRegion2 = record
  Address: ptrUint;
  Size: dword;
  Protect: dword;
end;


function TReversePointerListHandler.BinSearchMemRegions(address: ptrUint): integer;
var
  First: Integer;
  Last: Integer;
  Found: Boolean;
  Pivot: integer;
begin

  First  := 0; //Sets the first item of the range
  Last   := length(memoryregion)-1; //Sets the last item of the range
  Found  := False; //Initializes the Found flag (Not found yet)
  Result := -1; //Initializes the Result

  while (First <= Last) and (not Found) do
  begin

    //Gets the middle of the selected range
    Pivot := (First + Last) div 2;
    //Compares the String in the middle with the searched one
    if (address>=memoryregion[Pivot].BaseAddress ) and (address<memoryregion[Pivot].BaseAddress+memoryregion[Pivot].MemorySize) then
    begin
      Found  := True;
      Result := Pivot;
    end
    //If the Item in the middle has a bigger value than
    //the searched item, then select the first half
    else if memoryregion[Pivot].BaseAddress > address then
      Last := Pivot - 1
        //else select the second half
    else
      First := Pivot + 1;
  end;
end;

function TReversePointerListHandler.ispointer(address: ptrUint): boolean;
{
Check the memoryregion array for this address. If it's in, return true
}
begin
  result:=BinSearchMemRegions(address)<>-1;
end;

procedure TReversePointerListHandler.quicksortmemoryregions(lo,hi: integer);
var i,j: integer;
    x,h: TMemoryRegion;
begin
  i:=lo;
  j:=hi;

  x:=memoryregion[(lo+hi) div 2];

  repeat
    while (memoryregion[i].BaseAddress<x.BaseAddress) do inc(i);
    while (memoryregion[j].BaseAddress>x.BaseAddress) do dec(j);

    if i<=j then
    begin
      h:=memoryregion[i];
      memoryregion[i]:=memoryregion[j];
      memoryregion[j]:=h;
      inc(i);
      dec(j);
    end;

  until i>j;

  if (lo<j) then quicksortmemoryregions(lo,j);
  if (i<hi) then quicksortmemoryregions(i,hi);
end;

procedure TReversePointerListHandler.addpointer(pointervalue: ptrUint; pointerwiththisvalue: ptrUint; add: boolean);
var
  level: integer;
  entrynr: integer;
  temp, currentarray: PReversePointerListArray;
  mi: Tmoduleinfo;

  plist: PPointerList;

  size: integer;

begin
  currentarray:=level0list;

  level:=0;

  while level<maxlevel do
  begin
    //add the path if needed
    entrynr:=pointervalue shr ((maxlevel-level)*4) and $f;
    if currentarray[entrynr].ReversePointerlistArray=nil then //allocate
    begin
      size:=sizeof(TReversePointerListArray);

      temp:=bigalloc.alloc(size);
      ZeroMemory(temp, size);
      currentarray[entrynr].ReversePointerlistArray:=temp;
    end;

    currentarray:=currentarray[entrynr].ReversePointerlistArray;
    inc(level);
  end;

  //got till level (maxlevel)

  entrynr:=pointervalue shr ((maxlevel-level)*4) and $f;
  plist:=currentarray[entrynr].pointerlist;
    
  if plist=nil then //allocate one
  begin
    currentarray[entrynr].pointerlist:=bigalloc.alloc(sizeof(TPointerlist));
    plist:=currentarray[entrynr].pointerlist;
    plist.PointerValue:=pointervalue;

    plist.list:=nil;
    plist.pos:=0;
    plist.maxsize:=0;
    if not add then
      plist.expectedsize:=0
    else
    begin
      //guess the number of pointers there will be with this exact value
      plist.expectedsize:=2;

      if pointervalue mod $10=0 then
      begin
        plist.expectedsize:=5;
        if pointervalue mod $100=0 then
        begin
          plist.expectedsize:=10;
          if pointervalue mod $1000=0 then
          begin
            plist.expectedsize:=20;
            if pointervalue mod $10000=0 then
              plist.expectedsize:=50;
          end;
        end;
      end
    end;
  end;

  if not add then
    inc(plist.expectedsize)
  else
  begin
    //actually add a pointer address for this value
    if plist.list=nil then //create the list
    begin
      plist.list:=bigalloc.alloc(plist.expectedsize*sizeof(TPointerDataArray));
      ZeroMemory(plist.list, plist.expectedsize*sizeof(TPointerDataArray));

      plist.maxsize:=plist.expectedsize;
    end;

    if plist.pos>=plist.maxsize then  //the new entry will be over the maximum. Reallocate
    begin
      //quadrupple the storage
      plist.list:=bigalloc.realloc(plist.list, plist.maxsize*sizeof(TPointerDataArray), plist.maxsize*sizeof(TPointerDataArray)*4);
      plist.maxsize:=plist.maxsize*4;
    end;

    plist.list[plist.pos].address:=pointerwiththisvalue;
    if symhandler.getmodulebyaddress(pointerwiththisvalue, mi) then
    begin
      //it's a static, so create and fill in the static data
      plist.list[plist.pos].staticdata:=bigalloc.alloc(sizeof(TStaticData));
      plist.list[plist.pos].staticdata.moduleindex:=modulelist.IndexOf(mi.modulename);
      plist.list[plist.pos].staticdata.offset:=pointerwiththisvalue-mi.baseaddress;
    end
    else
      plist.list[plist.pos].staticdata:=nil;

    inc(plist.pos);
  end;
end;

procedure TReversePointerListHandler.saveModuleListToResults(s: TStream);
var i: integer;
  x: dword;
begin
  //save the number of modules
  x:=modulelist.Count;
  s.Write(x,sizeof(x));

  for i:=0 to modulelist.Count-1 do
  begin
    //for each module
    //save the length
    x:=length(modulelist[i]);
    s.Write(x,sizeof(x));

    //and the name
    s.Write(modulelist[i][1],x);
  end;
end;




function TReversePointerListHandler.findMaxOfPath(lvl: PMemrectablearraylist; a: PReversePointerListArray; level: ValUInt):PPointerList;
var
  i: ValSInt;
begin
  result:=nil;
  if level<maxlevel then
  begin
    for i:=$F downto 0 do
    begin
      if a[i].ReversePointerlistArray<>nil then
      begin
        lvl[level].entrynr:=i;
        lvl[level+1].arr:=a[i].ReversePointerlistArray;
        result:=findMaxOfPath(lvl, a[i].ReversePointerlistArray,level+1);
        if result<>nil then exit;
      end;
    end;
  end
  else
  begin
    //end reached
    for i:=$F downto 0 do
    begin
      if a[i].pointerlist<>nil then
      begin
        lvl[level].entrynr:=i;
        result:=a[i].pointerlist;
        exit;
      end;
    end;
  end

end;

function TReversePointerListHandler.findprevious(lvl: PMemrectablearraylist; level: ValUInt):PPointerList;
var
  i: ValSInt;
  currentarray: PReversePointerListArray;
begin
  result:=nil;

  if level<maxlevel then
  begin
    currentarray:=lvl[level].arr;
    for i:=lvl[level].entrynr-1 downto 0 do
    begin
      if currentarray[i].ReversePointerlistArray<>nil then
      begin
        lvl[level].entrynr:=i;
        lvl[level+1].arr:=currentarray[i].ReversePointerlistArray;
        result:=findMaxOfPath(lvl, currentarray[i].ReversePointerlistArray,level+1);
        if result<>nil then exit;
      end;
    end;
  end
  else
  begin
    //max level reached
    currentarray:=lvl[level].arr;
    for i:=lvl[level].entrynr-1 downto 0 do
    begin
      if currentarray[i].pointerlist<>nil then
      begin
        lvl[level].entrynr:=i;
        result:=currentarray[i].pointerlist;
        exit;
      end;
    end;
  end;

  //still here, so try a higher level
  if level>0 then
  begin
    lvl[level].entrynr:=$f;
    result:=findprevious(lvl,level-1);
  end;
end;


function TReversePointerListHandler.findClosestPointer(addresslist: PReversePointerListArray; entrynr: integer; level: integer; maxvalue: ptrUint): PPointerList;
{
The pointer was not found exactly, but we are in an addresslist that has been allocated, so something is filled in at least
}
var i: integer;
begin
  //first try the top

  for i:=entrynr+1 to $F do
  begin
    if addresslist[i].ReversePointerlistArray<>nil then
    begin
      if level=maxlevel then
      begin
        result:=addresslist[i].pointerlist;
        while (result<>nil) and (result.pointervalue>maxvalue) do //should only run one time
          result:=result.previous;

        if result=nil then
          result:=firstPointerValue;

        exit;
      end
      else //dig deeper
      begin
        result:=findClosestPointer(addresslist[i].ReversePointerlistArray, -1, level+1, maxvalue); //so it will be found by the next top scan
        if result<>nil then exit;
      end;
    end;
  end;


  //nothing at the top, try the bottom
  for i:=entrynr-1 downto 0 do
  begin
    if addresslist[i].ReversePointerlistArray<>nil then
    begin
      if level=maxlevel then
      begin
        result:=addresslist[i].pointerlist;
        while (result<>nil) and (result.pointervalue>maxvalue) do //should never happen
          result:=result.previous;

        if result=nil then
          result:=firstPointerValue;

        exit;
      end
      else //dig deeper
      begin
        result:=findClosestPointer(addresslist[i].ReversePointerlistArray, $10, level+1, maxvalue); //F downto 0
        if result<>nil then exit;
      end;
    end;
  end;
end;

function TReversePointerListHandler.findPointerValue(startvalue: ptrUint; var stopvalue: ptrUint): PPointerList;
var
  _maxlevel: ValSInt;
  level: ValSInt;
  currentarray: PReversePointerListArray;
  entrynr: ValSInt;

  _stopvalue: ptrUint;
begin
  result:=nil;

  //find a node that falls in the region of stopvalue and startvalue
  _maxlevel:=maxlevel;
  _stopvalue:=stopvalue;
  currentarray:=level0list;


  for level:=0 to _maxlevel do
  begin
    entrynr:=_stopvalue shr ((maxlevel-level)*4) and $f;
    if currentarray[entrynr].ReversePointerlistArray=nil then //not found
    begin
      result:=findClosestPointer(currentarray, entrynr, level, _stopvalue);
      break;
    end
    else
    begin
      if level=_maxlevel then
      begin
        result:=currentarray[entrynr].pointerlist;
        break;
      end;
    end;
    currentarray:=currentarray[entrynr].ReversePointerlistArray;
  end;

  stopvalue:=result.pointervalue;

  //clean up bad results
  if (result.pointerValue<startvalue) then
    result:=nil
end;

procedure TReversePointerListHandler.DeletePath(addresslist: PReversePointerListArray; level: integer);
//var
//  i,j: integer;
begin
  //obsolete, freeing the bigmem alloc handler frees this now

  {
  if level=maxlevel then
  begin
    for i:=0 to $F do
    begin
      if addresslist[i].pointerlist<>nil then
      begin
        for j:=0 to addresslist[i].pointerlist.pos-1 do
          freemem(addresslist[i].pointerlist.list[j].staticdata);

        freemem(addresslist[i].pointerlist.list);

        freemem(addresslist[i].pointerlist);
        addresslist[i].pointerlist:=nil;
      end;
    end;
  end
  else
  begin
    for i:=0 to $F do
    begin
      if addresslist[i].ReversePointerlistArray<>nil then
      begin
        deletepath(addresslist[i].ReversePointerlistArray,level+1);
        freemem(addresslist[i].ReversePointerlistArray);
        addresslist[i].ReversePointerlistArray:=nil;
      end;
    end;
  end;

  }
end;

destructor TReversePointerListHandler.destroy;
begin
  setlength(memoryregion,0);
  deletepath(level0list,0);

  if bigalloc<>nil then
    bigalloc.free;
end;


procedure TReversePointerListHandler.fillList(addresslist: PReversePointerListArray; level: integer; var prev: PPointerList);
var i: integer;
begin
  if level=maxlevel then
  begin
    for i:=0 to $f do
    begin
      if addresslist[i].pointerlist<>nil then
      begin
        if prev<>nil then
          prev.next:=addresslist[i].pointerlist
        else
          firstPointerValue:=addresslist[i].pointerlist;

        addresslist[i].pointerlist.previous:=prev;
        prev:=addresslist[i].pointerlist;

      end;
    end;
  end
  else
  begin
    for i:=0 to $F do
    begin
      if addresslist[i].ReversePointerlistArray<>nil then
        fillList(addresslist[i].ReversePointerlistArray,level+1, prev);
    end;
  end;
end;

procedure TReversePointerListHandler.fillLinkedList;
var current: PPointerList;
begin
  current:=nil;
  fillList(level0list,0,current);

  lastPointerValue:=current;

  if lastPointerValue=nil then
    raise exception.create(rsPointerValueSetupError);
end;

constructor TReversePointerListHandler.create(start, stop: ptrUint; alligned: boolean; progressbar: tprogressbar; noreadonly: boolean);
var bytepointer: PByte;
    dwordpointer: PDword absolute bytepointer;
    qwordpointer: PQword absolute bytepointer;


    mbi : _MEMORY_BASIC_INFORMATION;
    address: ptrUint;
    size:       dword;

    i: Integer;
    j: Integer;

    actualread: dword;
    TotalToRead: qword;

    maxsize: dword;

    buffer: pointer;

    memoryregion2: array of TMemoryRegion2;
    lastaddress: ptrUint;

begin
  OutputDebugString('TReversePointerListHandler.create');
  try
    bigalloc:=TBigMemoryAllocHandler.create;


    modulelist:=tstringlist.create;
    symhandler.getModuleList(modulelist);

    if processhandler.is64Bit then
    begin
      maxlevel:=15;
     // pointermask:=7; //AND the value/address with this value. If the result=0 it's aligned
    end
    else
    begin
      maxlevel:=7;
     // pointermask:=3;
    end;

    count:=0;

    address:=start;

    size:=sizeof(TReversePointerListArray);

    level0list:=bigalloc.alloc(size);
    ZeroMemory(level0list, size);

    OutputDebugString('Querying memoryregions');

    while (Virtualqueryex(processhandle,pointer(address),mbi,sizeof(mbi))<>0) and (address<stop) and ((address+mbi.RegionSize)>address) do
    begin
      if (not symhandler.inSystemModule(ptrUint(mbi.baseAddress))) and (not (not scan_mem_private and (mbi._type=mem_private))) and (not (not scan_mem_image and (mbi._type=mem_image))) and (not (not scan_mem_mapped and ((mbi._type and mem_mapped)>0))) and (mbi.State=mem_commit) and ((mbi.Protect and page_guard)=0) and ((mbi.protect and page_noaccess)=0) then  //look if it is commited
      begin
        if Skip_PAGE_NOCACHE then
          if (mbi.AllocationProtect and PAGE_NOCACHE)=PAGE_NOCACHE then
          begin
            address:=ptrUint(mbi.BaseAddress)+mbi.RegionSize;
            continue;
          end;

        if noreadonly then
        begin
          //check if it's read only
          if mbi.protect in [PAGE_READONLY, PAGE_EXECUTE, PAGE_EXECUTE_READ] then
          begin
            address:=ptrUint(mbi.BaseAddress)+mbi.RegionSize;
            continue;
          end;
        end;

        setlength(memoryregion,length(memoryregion)+1);

        memoryregion[length(memoryregion)-1].BaseAddress:=ptrUint(mbi.baseaddress);  //just remember this location
        memoryregion[length(memoryregion)-1].MemorySize:=mbi.RegionSize;
       // outputdebugstring(inttohex(ptrUint(mbi.baseaddress),8));
      end;


      address:=ptrUint(mbi.baseaddress)+mbi.RegionSize;
    end;

    setlength(memoryregion2,length(memoryregion));
    for i:=0 to length(memoryregion2)-1 do
    begin
      memoryregion2[i].Address:=memoryregion[i].BaseAddress;
      memoryregion2[i].Size:=memoryregion[i].MemorySize;


      if Virtualqueryex(processhandle,pointer(memoryregion2[i].Address),mbi,sizeof(mbi))<>0 then
        memoryregion2[i].Protect:=mbi.Protect
      else
        memoryregion2[i].Protect:=page_readonly;
    end;


    if length(memoryregion)=0 then
    begin
      OutputDebugString('No memory found in the specified region');
      raise exception.create(rsNoMemoryFoundInTheSpecifiedRegion);
    end;

    //lets search really at the start of the location the user specified
    if (memoryregion[0].BaseAddress<start) and (memoryregion[0].MemorySize-(start-memoryregion[0].BaseAddress)>0) then
    begin
      memoryregion[0].MemorySize:=memoryregion[0].MemorySize-(start-memoryregion[0].BaseAddress);
      memoryregion[0].BaseAddress:=start;
    end;

    //also the right end
    if (memoryregion[length(memoryregion)-1].BaseAddress+memoryregion[length(memoryregion)-1].MemorySize)>stop then
      dec(memoryregion[length(memoryregion)-1].MemorySize,(memoryregion[length(memoryregion)-1].BaseAddress+memoryregion[length(memoryregion)-1].MemorySize)-stop-1);

    //if anything went ok memoryregions should now contain all the addresses and sizes
    //to speed it up combine the regions that are attached to eachother.

    j:=0;
    address:=memoryregion[0].BaseAddress;
    size:=memoryregion[0].MemorySize;

    for i:=1 to length(memoryregion)-1 do
    begin
      if memoryregion[i].BaseAddress=address+size then
        inc(size,memoryregion[i].MemorySize)
      else
      begin
        memoryregion[j].BaseAddress:=address;
        memoryregion[j].MemorySize:=size;

        address:=memoryregion[i].BaseAddress;
        size:=memoryregion[i].MemorySize;
        inc(j);
      end;
    end;

    memoryregion[j].BaseAddress:=address;
    memoryregion[j].MemorySize:=size;
    setlength(memoryregion,j+1);

    //split up the memory regions into small chunks of max 512KB (so don't allocate a fucking 1GB region)
    i:=0;
    while i<length(memoryregion) do
    begin
      if memoryregion[i].MemorySize>512*1024 then
      begin
        //too big, so cut into pieces
        //create new entry with 512KB less
        setlength(memoryregion,length(memoryregion)+1);
        memoryregion[length(memoryregion)-1].BaseAddress:=memoryregion[i].BaseAddress+512*1024;
        memoryregion[length(memoryregion)-1].MemorySize:=memoryregion[i].MemorySize-512*1024;
        memoryregion[i].MemorySize:=512*1024; //set the current region to be 512KB

      end;
      inc(i); //next item. Eventually the new items will be handled, and they will also be split untill the list is finally cut into small enough chunks
    end;

    //sort memoryregions from small to high
    quicksortmemoryregions(0,length(memoryregion)-1);

    TotalToRead:=0;
    For i:=0 to length(memoryregion)-1 do
      inc(TotalToRead,Memoryregion[i].MemorySize);

    progressbar.Min:=0;
    progressbar.Step:=1;
    progressbar.Position:=0;
    progressbar.max:=length(memoryregion)*2+1;


    maxsize:=0;
    for i:=0 to length(memoryregion)-1 do
      maxsize:=max(maxsize, memoryregion[i].MemorySize);

    outputdebugstring(Format(rsAllocatingBytesToBuffer, [inttostr(maxsize)]));

    buffer:=nil;
    try
      getmem(buffer,maxsize);
    except
      outputdebugstring('Not enough memory free to scan');
      raise exception.Create(rsNotEnoughMemoryFreeToScan);
    end;

    try

      //initial scan to fetch the counts of memory

      outputdebugstring('Initial scan to determine the memory needed');

      for i:=0 to length(memoryregion)-1 do
      begin
        actualread:=0;
        if readprocessmemory(processhandle,pointer(Memoryregion[i].BaseAddress),buffer,Memoryregion[i].MemorySize,actualread) then
        begin
          bytepointer:=buffer;



          lastaddress:=ptrUint(buffer)+Memoryregion[i].MemorySize-processhandler.pointersize;

          if processhandler.is64Bit then
          begin
            while ptrUint(bytepointer)<=lastaddress do
            begin

              if (alligned and ((qwordpointer^ mod 8)=0) and ispointer(qwordpointer^)) or
                 ((not alligned) and ispointer(qwordpointer^) ) then
              begin
                //initial add
                addpointer(qwordpointer^, Memoryregion[i].BaseAddress+(ptrUint(qwordpointer)-ptrUint(buffer)),false);
              end;

              if alligned then
                inc(qwordpointer)
              else
                inc(bytepointer);
            end;
          end
          else
          begin
            while ptrUint(bytepointer)<=lastaddress do
            begin

              if (alligned and ((dwordpointer^ mod 4)=0) and ispointer(dwordpointer^)) or
                 ((not alligned) and ispointer(dwordpointer^) ) then
              begin
                //initial add
                addpointer(dwordpointer^, Memoryregion[i].BaseAddress+(ptrUint(dwordpointer)-ptrUint(buffer)),false);
              end;

              if alligned then
                inc(dwordpointer)
              else
                inc(bytepointer);
            end;
          end;


        end;

        progressbar.StepIt;
      end;

      //actual add
      OutputDebugString('Secondary scan actually allocating the memory and filling in the data');

      for i:=0 to length(memoryregion)-1 do
      begin
        actualread:=0;
        if readprocessmemory(processhandle,pointer(Memoryregion[i].BaseAddress),buffer,Memoryregion[i].MemorySize,actualread) then
        begin
          bytepointer:=buffer;
          lastaddress:=ptrUint(buffer)+Memoryregion[i].MemorySize;

          if processhandler.is64Bit then
          begin
            while ptrUint(bytepointer)<lastaddress do
            begin
              if (alligned and ((qwordpointer^ mod 8)=0) and ispointer(qwordpointer^)) or
                 ((not alligned) and ispointer(qwordpointer^) ) then
              begin
                //initial add
                addpointer(qwordpointer^, Memoryregion[i].BaseAddress+(ptrUint(qwordpointer)-ptrUint(buffer)),true);
                inc(count);
              end;

              if alligned then
                inc(qwordpointer) //increase with 8
              else
                inc(bytepointer);
            end;
          end
          else
          begin
            while ptrUint(bytepointer)<lastaddress do
            begin
              if (alligned and ((dwordpointer^ mod 4)=0) and ispointer(dwordpointer^)) or
                 ((not alligned) and ispointer(dwordpointer^) ) then
              begin
                //initial add
                addpointer(dwordpointer^, Memoryregion[i].BaseAddress+(ptrUint(dwordpointer)-ptrUint(buffer)),true);
                inc(count);
              end;

              if alligned then
                inc(dwordpointer) //increase with 4
              else
                inc(bytepointer);
            end;

          end;
        end;

        progressbar.StepIt;
      end;

      //and fill in the linked list
      OutputDebugString('filling linked list');
      fillLinkedList;

      progressbar.Position:=0;

    finally
      OutputDebugString('Freeing the buffer');
      if buffer<>nil then
        freemem(buffer);
    end;

    OutputDebugString('TReversePointerListHandler.create: Finished without an exception');

  except
    on e: exception do
    begin
      outputdebugstring('TReversePointerListHandler.create: Exception:'+e.message+'  (count='+inttostr(count)+')');
      raise Exception.Create(e.message);
    end;
  end;
end;

end.

