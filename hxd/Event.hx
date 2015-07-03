package hxd;

// 事件类型
enum EventKind {
	// 鼠标按下
	EPush;
	// 鼠标松开, 似乎会触发二次??
	ERelease;	
	EMove;
	EOver;
	EOut;
	EWheel;
	EFocus;
	// 丢失焦点
	EFocusLost;
	EKeyDown;
	EKeyUp;
	EReleaseOutside;
	ETextInput;
	/**
		Used to check if we are still on the interactive if no EMove was triggered this frame.
	**/
	ECheck;
}

class Event {
	// 事件类型
	public var kind : EventKind;
	
	// 鼠标 X 相对于父对像.
	public var relX : Float;
	public var relY : Float;
	public var relZ : Float;
	/**
		Will propagate the event to other interactives that are below the current one.
		
		将会传播事件到其他低于当前的互动活动。
	**/
	public var propagate : Bool;
	/**
		Will cancel the default behavior for this event as if it had happen outside of the interactive zone.
		
		将取消此事件的默认行为。{当有事件发生在交互区域外时???} 
	**/
	public var cancel : Bool;
	
	// 这个值好像一直为 0, 像是没有实现 右键 或中键.
	public var button : Int = 0;
	public var touchId : Int;
	public var keyCode : Int;
	public var charCode : Int;
	public var wheelDelta : Float;

	public function new(k,x=0.,y=0.) {
		kind = k;
		this.relX = x;
		this.relY = y;
	}

	public function toString() {
		return kind + "[" + Std.int(relX) + "," + Std.int(relY) + "]" + switch( kind ) {
		case EPush, ERelease, EReleaseOutside: ",button=" + button;
		case EMove, EOver, EOut, EFocus, EFocusLost, ECheck: "";
		case EWheel: ",wheelDelta=" + wheelDelta;
		case EKeyDown, EKeyUp: ",keyCode=" + keyCode;
		case ETextInput: ",charCode=" + charCode;
		}
	}

}