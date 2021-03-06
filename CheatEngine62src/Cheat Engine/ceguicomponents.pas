unit ceguicomponents;

{Modified components so they don't show unsupported properties}


{$mode delphi}

interface

uses
  zstream, Classes, SysUtils, Controls, forms,ComCtrls, StdCtrls, ExtCtrls, Buttons, lcltype,
  dialogs, JvDesignSurface, DOM, typinfo, LResources, JvDesignImp, JvDesignUtils,
  graphics, math, xmlread,xmlwrite, WSStdCtrls;

type TCETreeview=class(TCustomTreeview)
  property Align;
  property Anchors;
  property AutoExpand;
  property BorderSpacing;
  //property BiDiMode;
  property BackgroundColor;
  property BorderStyle;
  property BorderWidth;
  property Color;
  property Constraints;
  property DefaultItemHeight;
  property DragKind;
  property DragCursor;
  property DragMode;
  //property Enabled;
  property ExpandSignType;
  property Font;
  property HideSelection;
  property HotTrack;
  //property Images;
  property Indent;
  property MultiSelect;
  property MultiSelectStyle;
  //property ParentBiDiMode;
  property ParentColor default False;
  property ParentFont;
  property ParentShowHint;
  property PopupMenu;
  property ReadOnly;
  property RightClickSelect;
  property RowSelect;
  property ScrollBars;
  property SelectionColor;
  property ShowButtons;
  property ShowHint;
  property ShowLines;
  property ShowRoot;
  property SortType;
  property StateImages;
  property TabOrder;
  property TabStop default True;
  property Tag;
  property ToolTips;
  property Visible;
  //property OnAddition;
  //property OnAdvancedCustomDraw;
  //property OnAdvancedCustomDrawItem;
  //property OnChange;
  //property OnChanging;
  property OnClick;
  //property OnCollapsed;
  //property OnCollapsing;
  //property OnCompare;
  //property OnContextPopup;
  //property OnCreateNodeClass;
  //property OnCustomCreateItem;
  //property OnCustomDraw;
  //property OnCustomDrawItem;
  property OnDblClick;
  //property OnDeletion;
  //property OnDragDrop;
 // property OnDragOver;
  //property OnEdited;
  //property OnEditing;
  //property OnEditingEnd;
  //property OnEndDock;
  //property OnEndDrag;
  property OnEnter;
  property OnExit;
  //property OnExpanded;
  //property OnExpanding;
  //property OnGetImageIndex;
  //property OnGetSelectedIndex;
  //property OnKeyDown;
  property OnKeyPress;
  //property OnKeyUp;
  property OnMouseDown;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnMouseMove;
  property OnMouseUp;
  property OnSelectionChanged;
  //property OnShowHint;
  //property OnStartDock;
  //property OnStartDrag;
  //property OnUTF8KeyPress;
  property Options;
  property Items;
  property TreeLineColor;
  property TreeLinePenStyle;
  property ExpandSignColor;
end;

type TCESplitter=class(TCustomSplitter)
  property Align;
  property Anchors;
  property AutoSnap;
  property Beveled;
  property Color;
  property Constraints;
  property Cursor;
  property Height;
  property MinSize;
 // property OnCanResize;
  property OnChangeBounds;
  property OnMoved;
  property ParentColor;
  property ParentShowHint;
 // property PopupMenu;
  property ResizeAnchor;
  property ResizeStyle;
  property ShowHint;
  property Visible;
  property Width;
end;

type TCETimer=class(Ttimer);

type TCESaveDialog=class(TSaveDialog);
type TCEOpenDialog=class(TOpendialog);

type TCEListView=class(TCustomListView)
published
  property Align;
  property AllocBy;
  property Anchors;
  property BorderSpacing;
  property BorderStyle;
  property BorderWidth;
  property Checkboxes;
  property Color;
  property Items;
  property Columns;
  property ColumnClick;
  property Constraints;
 // property DragCursor;
//  property DragKind;
//  property DragMode;

  property Enabled;
  property Font;
  property HideSelection;
  property IconOptions;

 // property LargeImages;
  property MultiSelect;
//  property OwnerData;
  property ParentColor default False;
  property ParentFont;
  property ParentShowHint;
//  property PopupMenu;
  property ReadOnly;
  property RowSelect;
  property ScrollBars;
  property ShowColumnHeaders;
  property ShowHint;
//  property SmallImages;
  property SortColumn;
  property SortType;
//  property StateImages;
  property TabStop;
  property TabOrder;
  property ToolTips;
  property Visible;
  property ViewStyle;
//  property OnAdvancedCustomDraw;
///  property OnAdvancedCustomDrawItem;
 // property OnAdvancedCustomDrawSubItem;
//  property OnChange;
  property OnClick;
//  property OnColumnClick;
//  property OnCompare;
//  property OnContextPopup;
//  property OnCustomDraw;
//  property OnCustomDrawItem;
//  property OnCustomDrawSubItem;
//  property OnData;
  property OnDblClick;
 // property OnDeletion;
 // property OnDragDrop;
 // property OnDragOver;
 // property OnEndDock;
//  property OnEndDrag;
  property OnEnter;
  property OnExit;
  property OnItemChecked;
//  property OnKeyDown;
  property OnKeyPress;
//  property OnKeyUp;
  property OnMouseDown;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnMouseMove;
  property OnMouseUp;
  property OnResize;
//  property OnSelectItem;
 // property OnStartDock;
 // property OnStartDrag;
 // property OnUTF8KeyPress;
end;

type TCEProgressBar=class(TCustomProgressBar)
published
  property Align;
  property Anchors;
  property BorderSpacing;
  property BorderWidth;
  property Constraints;
//  property DragCursor;
//  property DragKind;
//  property DragMode;
  property Enabled;
  property Hint;
  property Max;
  property Min;
  property Position;
 // property OnContextPopup;
//  property OnDragDrop;
//  property OnDragOver;
//  property OnEndDrag;
  property OnEnter;
  property OnExit;
  property OnMouseDown;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnMouseMove;
  property OnMouseUp;
//  property OnStartDock;
//  property OnStartDrag;
  property Orientation;
  property ParentShowHint;
 // property PopupMenu;

  property ShowHint;
  property Smooth;
  property Step;
  property Style;
  property TabOrder;
  property TabStop;
  property Visible;
  property BarShowText;
end;

type TCETrackBar=class(TCustomTrackBar)
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
 //   property DragCursor;
 //   property DragMode;
    property Enabled;
    property Frequency;
    property Hint;
    property LineSize;
    property Max;
    property Min;
    property OnChange;
    property OnChangeBounds;
    property OnClick;
 //   property OnContextPopup;
//    property OnDragDrop;
//    property OnDragOver;
//    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
 //   property OnMouseWheel;
 //   property OnMouseWheelDown;
 //   property OnMouseWheelUp;
 //   property OnKeyDown;
    property OnKeyPress;
 //   property OnKeyUp;
    property OnResize;
 //   property OnStartDrag;
 //   property OnUTF8KeyPress;
    property Orientation;
    property PageSize;
    property ParentShowHint;
 //   property PopupMenu;
    property Position;
    property Reversed;
    property ScalePos;
    property SelEnd;
    property SelStart;
    property ShowHint;
    property ShowSelRange;
    property TabOrder;
    property TabStop;
    property TickMarks;
    property TickStyle;
    property Visible;
  end;

type TCEListBox=class(TCustomListBox)
  published
    property Align;
    property Anchors;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property ClickOnSelChange;
    property Color;
    property Columns;
    property Constraints;
//    property DragCursor;
//    property DragKind;
//    property DragMode;
    property ExtendedSelect;
    property Enabled;
    property Font;
    property IntegralHeight;
    property Items;
    property ItemHeight;
    property MultiSelect;
    property OnChangeBounds;
    property OnClick;
    //property OnContextPopup;
    property OnDblClick;
  //  property OnDragDrop;
  //  property OnDragOver;
 //   property OnDrawItem;
    property OnEnter;
  //  property OnEndDrag;
    property OnExit;
    property OnKeyPress;
 //   property OnKeyDown;
 //   property OnKeyUp;
 //   property OnMeasureItem;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
 //   property OnMouseWheel;
 //   property OnMouseWheelDown;
 //   property OnMouseWheelUp;
    property OnResize;
    property OnSelectionChange;
 //   property OnShowHint;
//    property OnStartDrag;
//    property OnUTF8KeyPress;
    property ParentBidiMode;
    property ParentColor;
    property ParentShowHint;
    property ParentFont;
  //  property PopupMenu;
    property ShowHint;
    property Sorted;
    property Style;
    property TabOrder;
    property TabStop;
    property TopIndex;
    property Visible;
  end;

type TCEComboBox=class(TcustomComboBox)
published
  property Align;
  property Anchors;
  property ArrowKeysTraverseList;
  property AutoComplete;
  property AutoCompleteText;
  property AutoDropDown;
  property AutoSelect;
  property AutoSize;// Note: windows has a fixed height in some styles
  property BidiMode;
  property BorderSpacing;
  property CharCase;
  property Color;
  property Constraints;
//  property DragCursor;
//  property DragKind;
//  property DragMode;
  property DropDownCount;
  property Enabled;
  property Font;
  property ItemHeight;
  property ItemIndex;
  property Items;
  property ItemWidth;
  property MaxLength;
  property OnChange;
  property OnChangeBounds;
  property OnClick;
  property OnCloseUp;
 // property OnContextPopup;
  property OnDblClick;
////  property OnDragDrop;
 // property OnDragOver;
 // property OnDrawItem;
//  property OnEndDrag;
//  property OnDropDown;
  property OnEditingDone;
  property OnEnter;
  property OnExit;
  property OnGetItems;
 // property OnKeyDown;
  property OnKeyPress;
//  property OnKeyUp;
 // property OnMeasureItem;
  property OnMouseDown;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnMouseMove;
  property OnMouseUp;
 // property OnStartDrag;
  property OnSelect;
 // property OnUTF8KeyPress;
 // property ParentBidiMode;
  property ParentColor;
  property ParentFont;
  property ParentShowHint;
//  property PopupMenu;
  property ReadOnly;
  property ShowHint;
  property Sorted;
  property Style;
  property TabOrder;
  property TabStop;
  property Text;
  property Visible;
end;


type TCEGroupBox=class(TCustomGroupBox)
published
  property Align;
  property Anchors;
  property AutoSize;
  property BidiMode;
  property BorderSpacing;
  property Caption;
  property ChildSizing;
  property ClientHeight;
  property ClientWidth;
  property Color;
  property Constraints;
  //property DockSite;
 // property DragCursor;
 // property DragKind;
 // property DragMode;
  property Enabled;
  property Font;
  property ParentBidiMode;
  property ParentColor;
  property ParentFont;
  property ParentShowHint;
//  property PopupMenu;
  property ShowHint;
  property TabOrder;
  property TabStop;
  property Visible;
  property OnChangeBounds;
  property OnClick;
 // property OnContextPopup;
  property OnDblClick;
//  property OnDragDrop;
//  property OnDockDrop;
//  property OnDockOver;
//  property OnDragOver;
//  property OnEndDock;
//  property OnEndDrag;
  property OnEnter;
  property OnExit;
 // property OnGetSiteInfo;
 // property OnKeyDown;
  property OnKeyPress;
 // property OnKeyUp;
  property OnMouseDown;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnMouseMove;
  property OnMouseUp;
  property OnResize;
//  property OnStartDock;
//  property OnStartDrag;
//  property OnUnDock;
//  property OnUTF8KeyPress;
end;

type TCERadioGroup=class(TCustomRadioGroup)
published
    property Align;
    property Anchors;
    property AutoFill;
    property AutoSize;
    property BidiMode;
    property BorderSpacing;
    property Caption;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property ColumnLayout;
    property Columns;
    property Constraints;
//    property DragCursor;
//    property DragMode;
    property Enabled;
    property Font;
    property ItemIndex;



    property Items;
    property OnChangeBounds;
    property OnClick;
    property OnDblClick;
  //  property OnDragDrop;
  //  property OnDragOver;
  //  property OnEndDrag;
    property OnEnter;
    property OnExit;
  //  property OnKeyDown;
    property OnKeyPress;
  //  property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
 //   property OnStartDrag;
 //   property OnUTF8KeyPress;
    property ParentBidiMode;
    property ParentFont;
    property ParentColor;
    property ParentShowHint;
//   property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
end;

type TCECheckBox=class(TCustomCheckBox)
  public
    constructor Create(TheOwner: TComponent); override;
  published
    //property Action;
    property Align;
    property AllowGrayed;
    property Anchors;
    property AutoSize default True;
    property BidiMode;
    property BorderSpacing;
    property Caption;
    property Checked;
    property Color nodefault;
    property Constraints;
  //  property DragCursor;
  //  property DragKind;
  //  property DragMode;
    property Enabled;
    property Font;
    property Hint;
    property OnChange;
    property OnChangeBounds;
    property OnClick;
    //property OnContextPopup;
   // property OnDragDrop;
   // property OnDragOver;
   // property OnEditingDone;
   // property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyPress;
  //  property OnKeyDown;
  //  property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
 //   property OnStartDrag;
 //   property OnUTF8KeyPress;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ParentBidiMode;
  //  property PopupMenu;
    property ShowHint;
    property State;
    property TabOrder;
    property TabStop default True;
    property Visible;
  end;


type TCEToggleBox=class(TToggleBox); //there is no custom...


type TCEEdit=class(TCustomEdit)
  public
    property AutoSelected;
  published
  //  property Action;
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property AutoSelect;
    property BidiMode;
    property BorderStyle;
    property BorderSpacing;
    property CharCase;
    property Color;
    property Constraints;
//    property DragCursor;
//    property DragKind;
//    property DragMode;
    property EchoMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property ParentBidiMode;
    property OnChange;
    property OnChangeBounds;
    property OnClick;
 //   property OnContextPopup;
    property OnDblClick;
 //   property OnDragDrop;
 //   property OnDragOver;
 //   property OnEditingDone;
 //   property OnEndDrag;
    property OnEnter;
    property OnExit;
 //   property OnKeyDown;
    property OnKeyPress;
 //   property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
 //   property OnStartDrag;
  //  property OnUTF8KeyPress;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
   // property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabStop;
    property TabOrder;
    property Text;
    property Visible;
  end;

type TCEForm=class(TCustomForm)
  private
    saveddesign: TMemorystream;
    fDoNotSaveInTable: boolean;
    procedure paint; override;
    procedure OnWriteMethod(Writer: TWriter; Instance: TPersistent; PropInfo: PPropInfo; const MethodValue, DefMethodValue: TMethod; var Handled: boolean);
    procedure WriteComponentAsBinaryToStreamWithMethods(Astream: TStream);
    procedure setActive(state: boolean);
    function getActive: boolean;

    procedure SetMethodProperty(Reader: TReader; Instance: TPersistent; PropInfo: PPropInfo; const TheMethodName: string; var Handled: boolean);

  public
    designsurface: TJvDesignSurface;
    procedure ResyncWithLua(Base: TComponent); overload;
    procedure ResyncWithLua; overload;
    procedure SaveToFile(filename: string);
    procedure LoadFromFile(filename: string);
    procedure SaveToXML(Node: TDOMNode);
    procedure LoadFromXML(Node: TDOMNode);
    procedure RestoreToDesignState;
    procedure SaveCurrentStateasDesign;
    destructor destroy; override;

    property  active: boolean read getActive write setActive;

  published
    property Align;
   // property AllowDropFiles;
    property AlphaBlend default False;
    property AlphaBlendValue default 255;
    property Anchors;
    property AutoScroll;
    property AutoSize;
    property BiDiMode;
    property BorderIcons;
    property BorderStyle;
    property BorderWidth;
    property Caption;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property Constraints;
    property DefaultMonitor;
    property DockSite;
    property DragKind;
    property DragMode;
    //property Enabled;
    property Font;
    property FormStyle;
   // property HelpFile;
    property Icon;
    property KeyPreview;
    //property Menu;
    property OnActivate;
    property OnChangeBounds;
    property OnClick;
    property OnClose;
  //  property OnCloseQuery;
    property OnContextPopup;
    property OnCreate;
    property OnDblClick;
    property OnDeactivate;
    property OnDestroy;
   // property OnDockDrop;
  //  property OnDockOver;
   // property OnDragDrop;
  //  property OnDragOver;
  //  property OnDropFiles;
  //  property OnEndDock;
  //  property OnGetSiteInfo;
 //   property OnHelp;
    property OnHide;
   // property OnKeyDown;
    property OnKeyPress;
  //  property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
//    property OnMouseWheel;
//    property OnMouseWheelDown;
  //  property OnMouseWheelUp;
    property OnPaint;
   // property OnResize;
   // property OnShortCut;
    property OnShow;
   // property OnShowHint;
    //property OnStartDock;
  //  property OnUnDock;
  //  property OnUTF8KeyPress;
    property OnWindowStateChange;
    property ParentBiDiMode;
    property ParentFont;
    property PixelsPerInch;
//    property PopupMenu;
 //   property PopupMode;
  //  property PopupParent;
    property Position;
   // property SessionProperties;
  //  property ShowHint;
    property ShowInTaskBar;
  //  property UseDockManager;
 //   property LCLVersion: string read FLCLVersion write FLCLVersion stored LCLVersionIsStored;
    //property Visible;
    property WindowState;

    property DoNotSaveInTable: boolean read fDoNotSaveInTable write fDoNotSaveInTable default False;
end;

type TCEMemo=class(TCustomMemo)
  published
    property Align;
    property Alignment;
    property Anchors;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
//    property DragCursor;
//    property DragKind;
//    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
   // property Text;
    property Lines;
    property MaxLength;
    property OnChange;
    property OnClick;
  //  property OnContextPopup;
    property OnDblClick;
   // property OnDragDrop;
  //  property OnDragOver;
    property OnEditingDone;
   // property OnEndDrag;
    property OnEnter;
    property OnExit;
  //  property OnKeyDown;
    property OnKeyPress;
 //   property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
 //   property OnMouseWheel;
 //   property OnMouseWheelDown;
 //   property OnMouseWheelUp;
  //  property OnStartDrag;
  //  property OnUTF8KeyPress;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
 //   property PopupMenu;
    property ParentShowHint;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property WantReturns;
    property WantTabs;
    property WordWrap;
  end;


type TCEImage=class(TCustomImage)
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property Center;
    property Constraints;
 //   property DragCursor;
//    property DragMode;
    property Enabled;
    //property OnChangeBounds;
    property OnClick;
    property OnDblClick;
   // property OnDragDrop;
   // property OnDragOver;
  //  property OnEndDrag;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  //  property OnMouseWheel;
  //  property OnMouseWheelDown;
  //  property OnMouseWheelUp;
    property OnPaint;
    property OnPictureChanged;
    property OnResize;
    //property OnStartDrag;
    property ParentShowHint;
    property Picture;
   // property PopupMenu;
    property Proportional;
    property ShowHint;
    property Stretch;
    property Transparent;
    property Visible;
  end;

type TCEPanel=class(TCustomPanel)
published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BidiMode;
    property BorderWidth;
    property BorderStyle;
    property Caption;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property Constraints;
    property DockSite;
//    property DragCursor;
//    property DragKind;
//    property DragMode;
    property Enabled;
    property Font;
    property FullRepaint;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    //property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property UseDockManager default True;
    property Visible;
    property OnClick;
   // property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
   // property OnDragDrop;
  //  property OnDragOver;
  //  property OnEndDock;
  //  property OnEndDrag;
    property OnEnter;
    property OnExit;
  //  property OnGetSiteInfo;
  //  property OnGetDockCaption;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  //  property OnStartDock;
   // property OnStartDrag;
   // property OnUnDock;
  end;

type TCELabel=class(TCustomLabel)
published
  property Align;
  property Alignment;
  property Anchors;
  property AutoSize;
  property BidiMode;
  property BorderSpacing;
  property Caption;
  property Color;
  property Constraints;
//  property DragCursor;
// property DragKind;
 // property DragMode;
  property Enabled;
//  property FocusControl;
  property Font;
  property Layout;
  property ParentBidiMode;
  property ParentColor;
  property ParentFont;
  property ParentShowHint;
 // property PopupMenu;
  property ShowAccelChar;
  property ShowHint;
  property Transparent;
  property Visible;  //doesn't work well
  property WordWrap;
  property OnClick;
  property OnDblClick;
  //property OnDragDrop;
  //property OnDragOver;
  //property OnEndDrag;
  property OnMouseDown;
  property OnMouseMove;
  property OnMouseUp;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnChangeBounds;
  //property OnContextPopup;
  property OnResize;
  property OnStartDrag;
  property OptimalFill;
end;

type TCEButton=class(TCustomButton)
  private
  published
   //
    property Align;
    property Anchors;
    property AutoSize;
    property BidiMode;
    property BorderSpacing;
    property Cancel;
    property Caption;
   // property Color;
    property Constraints;
    property Default;
 //   property DragCursor;
 //   property DragKind;
 //   property DragMode;
    property Enabled;
    property Font;
    //property ParentBidiMode;
    property ModalResult;
    property OnChangeBounds;
    property OnClick;
    //property OnContextPopup;
    //property OnDragDrop;
    //property OnDragOver;
    //property OnEndDrag;
    property OnEnter;
    property OnExit;
    //
    property OnKeyPress;
    //property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    //property OnStartDrag;
   // property OnUTF8KeyPress;
    property ParentFont;
    property ParentShowHint;
    //property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
end;


implementation

uses luahandler,luacaller, formdesignerunit;

constructor TCECheckBox.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fCompStyle := csCheckbox;
  TabStop := True;
  AutoSize := True;
end;

//ceform

procedure TCEForm.setActive(state: boolean);
var oldstate: boolean;
begin
  if formdesigner=nil then exit;

  if state then
  begin

    if active=false then
      RestoreToDesignState; //it was disabled so change it to the saved state if possible and edit from there



    //check if it is currenty being designed, if not, create a surface for this form
    if designsurface=nil then
    begin
      //still here so the surface needs to be created for this form
      designsurface:=TJvDesignSurface.Create(nil);

      designsurface.Container:=self;
      designsurface.ControllerClass:=TJvDesignController;;

      designsurface.MessengerClass:= TJvDesignWinControlHookMessenger;
      //Surface.MessengerClass:=TJvDesignDesignerMessenger;
      designsurface.SelectorClass:=TJvDesignSelector;

      designsurface.OnGetAddClass:=formdesigner.DesignerGetAddClass;
      designsurface.OnSelectionChange:=formdesigner.DesignerSelectionChange;
      designsurface.OnChange:=formdesigner.surfaceOnChange;


      designsurface.name:='Surface';

    end;

    designsurface.Active:=true;
  end
  else
  begin

    if designsurface<>nil then
    begin
      if designsurface.active then
        SaveCurrentStateasDesign; //save the current state as the designed state

      designsurface.active:=false;
    end;
  end;


end;

function TCEForm.getActive: boolean;
begin
  result:=false;
  if designsurface<>nil then
    result:=designsurface.active;
end;

procedure TCEForm.OnWriteMethod(Writer: TWriter; Instance: TPersistent; PropInfo: PPropInfo; const MethodValue, DefMethodValue: TMethod; var Handled: boolean);
begin
  if (MethodValue.data<>nil) and (tobject(MethodValue.data) is TLuaCaller)  then
  begin
    writer.Driver.BeginProperty(propinfo.Name);
    writer.Driver.WriteMethodName(TLuaCaller(MethodValue.data).luaroutine);
    writer.Driver.EndProperty;
  end;
  handled:=true;
end;

procedure TCEForm.WriteComponentAsBinaryToStreamWithMethods(AStream: TStream);
var
  Writer: TWriter;
  DestroyDriver: Boolean;
  g: tguid;
begin
  if name='' then
  begin
    //an object NEEDS a name
    CreateGUID(g);
    name:='NoName_'+GUIDToString(g);
  end;

  DestroyDriver:=false;
  Writer:=nil;
  try
    Writer:=CreateLRSWriter(AStream,DestroyDriver);
    Writer.OnWriteMethodProperty:=OnWriteMethod;
    Writer.WriteDescendent(self,nil);
  finally
    if DestroyDriver then
      Writer.Driver.Free;
    Writer.Free;
  end;
end;

procedure TCEForm.SetMethodProperty(Reader: TReader; Instance: TPersistent; PropInfo: PPropInfo; const TheMethodName: string; var Handled: boolean);
var t: TLuaCaller;
  m: TMethod;
begin
  t:=TLuaCaller.create;
  t.luaroutine:=TheMethodName;
  t.owner:=Instance;


  //I wonder if I could use a case here...
  //Note: If changed here, also change in formDesigner.pas at method TFormDesigner.onCreateMethod
  if propinfo.PropType=TypeInfo(TLVCheckedItemEvent) then
    SetMethodProp(instance, propinfo, TMethod(TLVCheckedItemEvent(t.LVCheckedItemEvent)))
  else
  if propinfo.PropType=TypeInfo(TCloseEvent) then
    SetMethodProp(instance, propinfo, TMethod(TCloseEvent(t.CloseEvent)))
  else
  if propinfo.PropType=TypeInfo(TMouseEvent) then
    SetMethodProp(instance, propinfo, TMethod(TMouseEvent(t.MouseEvent)))
  else
  if propinfo.PropType=TypeInfo(TMouseMoveEvent) then
    SetMethodProp(instance, propinfo, TMethod(TMouseMoveEvent(t.MouseMoveEvent)))
  else
  if propinfo.PropType=TypeInfo(TKeyPressEvent) then
    SetMethodProp(instance, propinfo, TMethod(TKeyPressEvent(t.KeyPressEvent)))
  else
  if propinfo.PropType=TypeInfo(TSelectionChangeEvent) then
    SetMethodProp(instance, propinfo, TMethod(TSelectionChangeEvent(t.SelectionChangeEvent)))
  else
    SetMethodProp(instance, propinfo, TMethod(TNotifyEvent(t.NotifyEvent)));

  handled:=true;
end;


procedure TCEForm.RestoreToDesignState;
var wasactive: boolean;
  reader: TReader;
  DestroyDriver: boolean;

  i: integer;
begin
  wasactive:=active;
  active:=false;


  //RegisterPropertyToSkip(TCEForm, 'Visible', '','');

  if savedDesign<>nil then
  begin
    name:='';
    while ComponentCount>0 do
      Components[0].Free;

    while ControlCount>0 do
      Controls[0].Free;

    savedDesign.position:=0;
    DestroyDriver:=false;
    reader:=CreateLRSReader(savedDesign,DestroyDriver);

    reader.OnSetMethodProperty:=SetMethodProperty;

    reader.ReadRootComponent(self);

    if DestroyDriver then
      reader.Driver.free;

  end;

  active:=wasactive;

  ResyncWithLua;
end;

procedure TCEForm.SaveCurrentStateasDesign;
//var ss: tstringstream;
begin
  if saveddesign=nil then
    savedDesign:=Tmemorystream.create;

  savedDesign.position:=0;
  WriteComponentAsBinaryToStreamWithMethods(savedDesign);

  savedDesign.position:=0;

  ResyncWithLua;
 // ss:=tstringstream.create('');
 // LRSObjectBinaryToText(savedDesign, ss);
 // showmessage(ss.DataString);
end;

procedure TCEForm.SaveToXML(Node: TDOMNode);
var doc: TXMLDocument;
  outputastext: pchar;
  g: TGuid;
  wasactive: boolean;

  m: TMemorystream;
  c: Tcompressionstream;

  size: dword;
begin
  wasactive:=active;
  if active then active:=false;

  if saveddesign=nil then exit; //nothing to save

  //for now use a binarystream instead of xml. the xmlwriter/reader does not support stringlists
  //create a stream for storage
  outputastext:=nil;
  try
{
    WriteComponentAsBinaryToStreamWithMethods(m);}

    //compress the design
    m:=tmemorystream.create;
    c:=Tcompressionstream.create(clmax, m, true);
    size:=saveddesign.size;
    c.write(size, sizeof(size));
    c.write(saveddesign.Memory^, size);
    c.free;

    //and now save the stream as text to the xml file
    doc:=TXMLDocument(node.OwnerDocument);



    getmem(outputastext, m.size*2+1);
    BinToHex(pchar(m.Memory), outputastext, m.Size);

    outputastext[m.size*2]:=#0; //add a 0 terminator

    m.free;


    Node.AppendChild(doc.CreateElement(name)).TextContent:=outputastext;
  finally
    if outputastext<>nil then
      freemem(outputastext);
  end;

  active:=wasactive;
end;

procedure TCEForm.LoadFromXML(Node: TDOMNode);
var s: string;
  b: pchar;
  m: TMemorystream;
  dc: Tdecompressionstream;
  size: integer;
  read: integer;

  realsize: dword;
  wasActive: boolean;
begin
  wasActive:=active;
  active:=false;


  if saveddesign=nil then
    saveddesign:=TMemorystream.create;

  saveddesign.Clear;

  s:=node.TextContent;

  size:=length(s) div 2;
  getmem(b, size);
  try
    HexToBin(pchar(s), b, size);

    m:=tmemorystream.create;
    m.WriteBuffer(b^, size);
    m.position:=0;
    dc:=Tdecompressionstream.create(m, true);

    dc.read(realsize,sizeof(realsize));

    freemem(b);
    getmem(b, realsize);

    read:=dc.read(b^, realsize);
    saveddesign.WriteBuffer(b^, read);
  finally
    freemem(b);
  end;

  RestoreToDesignState;

  active:=wasActive;
end;

procedure TCEForm.SaveToFile(filename: string);
var
  xmldoc: TXMLDocument;
  formnode: TDOMNode;
begin
  xmldoc:=TXMLDocument.Create;

  formnode:=xmldoc.appendchild(xmldoc.createElement('FormData'));

  SaveCurrentStateasDesign;
  SaveToXML(formnode);

  WriteXML(xmldoc, filename);
end;

procedure TCEForm.LoadFromFile(filename: string);
var
  formnode: TDOMNode;
  xmldoc: TXMLDocument;
begin
  xmldoc:=nil;
  ReadXMLFile(xmldoc, filename);

  if xmldoc<>nil then
  begin
    formnode:=xmldoc.FindNode('FormData');

    LoadFromXML(formnode);
    ResyncWithLua;
  end;
end;

procedure TCEForm.paint;
begin
  inherited paint;

  if active then
  begin
    if color<>clDefault then
      DesignPaintGrid(Canvas, ClientRect, ColorToRGB(color), InvertColor(ColorToRGB(color)))
    else
      DesignPaintGrid(Canvas, ClientRect);
  end;
end;

procedure TCEForm.ResyncWithLua(base: TComponent);
var i: integer;
begin
  for i:=0 to base.ComponentCount-1 do
    ResyncWithLua(base.Components[i]);

  if base=self then
    Lua_RegisterObject(base.Name, base)
  else
    Lua_RegisterObject(name+'_'+base.Name, base)


end;

procedure TCEForm.ResyncWithLua;
begin
  ResyncWithLua(self);
end;

destructor TCEForm.destroy;
begin
  if designsurface<>nil then
  begin
    designsurface.active:=false;
    freeandnil(designsurface);
  end;
  inherited destroy;
end;


initialization
  RegisterClass(TCEButton);
  RegisterClass(TCELabel);
  RegisterClass(TCEPanel);
  RegisterClass(TCEImage);
  RegisterClass(TCEMemo);
  RegisterClass(TCEEdit);
  {$ifdef windows} //some components are not implemented in other os's yet
  RegisterClass(TCEToggleBox);
  {$endif}

  RegisterClass(TCEComboBox);
  RegisterClass(TCEListBox);

  RegisterClass(TCECheckBox);
  RegisterClass(TCEGroupBox);
  RegisterClass(TCERadioGroup);
  RegisterClass(TCETimer);
  RegisterClass(TCESaveDialog);
  RegisterClass(TCEOpenDialog);
  RegisterClass(TCEProgressBar);
  RegisterClass(TCETrackbar);
  RegisterClass(TCEListView);
  RegisterClass(TCESplitter);

  RegisterClass(TCETreeview); //todo: Make usable

  RegisterClass(tceform);


end.

