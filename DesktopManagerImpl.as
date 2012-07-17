package
{
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    import mx.core.Container;

    /**
     * @private
     * The impl of IDesktopManager
     *
     * @author xw
     */
    public class DesktopManagerImpl implements IDesktopManager
    {
        private var platform:Container;
        private var selected:Array = new Array();
        private var framed:Array = new Array();
        private var select:Boolean = false;
        private var move:Boolean = false;
        private var fx:int;
        private var fy:int;

        public function DesktopManagerImpl(){
            super();
        }

        public function addPlatform(_platform:Container):void{
            this.platform = _platform;

            this.platform.addEventListener(MouseEvent.MOUSE_DOWN, this.onSelectDown);
            this.platform.addEventListener(MouseEvent.MOUSE_UP, this.onSelectUp);

            var i:int = 0;
            var o:IDesktopIcon;
            while(i < this.platform.numChildren){
                if((this.platform.getChildAt(i)) is IDesktopIcon){
                    o = this.platform.getChildAt(i) as IDesktopIcon;
                    o.addEventListener(MouseEvent.MOUSE_DOWN,this.onIconClickDown);
                    o.addEventListener(MouseEvent.MOUSE_UP,this.onIconClickUp);
                }
                i++;
            }
        }

        public function removePlatform(_platform:Container):void{
            this.platform.removeEventListener(MouseEvent.MOUSE_DOWN, this.onSelectDown);
            this.platform.removeEventListener(MouseEvent.MOUSE_UP, this.onSelectUp);

            var i:int = 0;
            var o:IDesktopIcon;
            while(i < this.platform.numChildren){
                if((this.platform.getChildAt(i)) is IDesktopIcon){
                    o = this.platform.getChildAt(i) as IDesktopIcon;
                    o.removeEventListener(MouseEvent.MOUSE_DOWN,this.onIconClickDown);
                    o.removeEventListener(MouseEvent.MOUSE_UP,this.onIconClickUp);
                }
                i++;
            }
        }

        private function onSelectDown(e:MouseEvent):void{

            var p:Point = this.platform.globalToLocal(new Point(e.stageX,e.stageY));
            this.fx = p.x;
            this.fy = p.y;
            this.platform.addEventListener(MouseEvent.MOUSE_MOVE, this.onSelectMove);
            if(!e.ctrlKey){
                this.unSelect();
            }else{

            }
            this.framed = new Array();
            this.select = true;
        }

        private function onSelectUp(e:MouseEvent):void{
            this.platform.removeEventListener(MouseEvent.MOUSE_MOVE, this.onSelectMove);
            this.platform.graphics.clear();
            this.select = false;
        }

        private function onSelectMove(e:MouseEvent):void{
            //trace("moving: ",e.currentTarget, e);
            var p:Point = this.platform.globalToLocal(new Point(e.stageX,e.stageY));
            this.drawRect(this.fx, this.fy, p.x, p.y);
            var scrollx:int = this.platform.horizontalScrollPosition;
            var scrolly:int = this.platform.verticalScrollPosition;
            this.doSelect(this.fx + scrollx, this.fy + scrolly, p.x + scrollx, p.y + scrolly, e.ctrlKey);
        }

        private function onIconClickDown(e:MouseEvent):void{
            //trace("icon: ",e);
            e.stopPropagation();
            this.fx = this.platform.mouseX;
            this.fy = this.platform.mouseY;
            var io:IDesktopIcon = IDesktopIcon(e.currentTarget);
            if(this.selected.indexOf(io) < 0){
                if(!e.ctrlKey)
                    this.unSelect();
                this.selected.push(io);
                io.onIconSelected();
            }else if(e.ctrlKey){
                this.selected.splice(this.selected.indexOf(io), 1);
                io.onIconUnSelected();
            }
            this.platform.addEventListener(MouseEvent.MOUSE_MOVE,this.onIconMoving);
        }

        private function onIconClickUp(e:MouseEvent):void{
            if(!this.select){
                e.stopPropagation();
                this.platform.removeEventListener(MouseEvent.MOUSE_MOVE,this.onIconMoving);
                if(this.move){
                    for(var i:String in this.selected){
                        var o:IDesktopIcon = this.selected[i] as IDesktopIcon;
                        o.onIconStop();
                    }
                    this.move = false;
                }
            }
        }

        private function onIconMoving(e:MouseEvent):void{
            //trace("icon move: ",e);
            var dx:int = this.platform.mouseX - this.fx;
            var dy:int = this.platform.mouseY - this.fy;
            this.fx = this.platform.mouseX;
            this.fy = this.platform.mouseY;
            this.move = true;

            for(var i:String in this.selected){
                var o:IDesktopIcon = this.selected[i] as IDesktopIcon;
                o.x += dx;
                if(o.x < 0) o.x = 0;
                o.y += dy;
                if(o.y < 0) o.y = 0;
                o.onIconMoving();
            }
        }
        private function drawRect(fx:int,fy:int,sx:int,sy:int):void{
            var g:Graphics = this.platform.graphics;

            g.clear();
            g.lineStyle(2,0xFFFFFF,0.5);
            g.beginFill(0xffffff,0.1);
            g.drawRect(fx, fy, sx - fx, sy - fy);
            g.endFill(); 
        }

        private function doSelect(fx:int,fy:int,sx:int,sy:int,add:Boolean):void{
            var i:int = 0;
            var o:IDesktopIcon;
            var ox:int,oy:int;

            while(i < this.platform.numChildren){
                if((this.platform.getChildAt(i)) is IDesktopIcon){
                    o = this.platform.getChildAt(i) as IDesktopIcon;
                    ox = o.x + o.width / 2;
                    oy = o.y + o.height / 2;
                    if( ((ox - fx)*(ox - sx) < 0 && (oy - fy)*(oy - sy) < 0)
                            && this.framed.indexOf(o) < 0 ){
                        if(this.selected.indexOf(o) < 0){
                            o.onIconSelected();
                            this.selected.push(o);

                        }else if(add){
                            o.onIconUnSelected();
                            this.selected.splice(this.selected.indexOf(o),1);
                        }
                        this.framed.push(o);
                    }else
                        if( ((ox - fx)*(ox - sx) > 0 || (oy - fy)*(oy - sy) > 0)
                                && this.framed.indexOf(o) >= 0){
                            if(this.selected.indexOf(o) >= 0){
                                o.onIconUnSelected();
                                this.selected.splice(this.selected.indexOf(o),1);
                            }else if(add){
                                o.onIconSelected();
                                this.selected.push(o);
                            }
                            this.framed.splice(this.framed.indexOf(o),1);
                        }
                }
                i++;
            }
        }

        private function unSelect():void{
            while(this.selected.length > 0){
                var o:IDesktopIcon = this.selected.pop() as IDesktopIcon;
                o.onIconUnSelected();
            }
        }
    }
}
