package
{
    import mx.core.IFlexDisplayObject;

    /**
     * interface of the children of the container managed by DesktopManager
     *
     * @author
     */

    public interface IDesktopIcon extends IFlexDisplayObject
    {
        /**
         * method when icon is selected
         */
        function onIconSelected():void;

        /**
         * method when icon is unselected
         */
        function onIconUnSelected():void;

        /**
         * method when icon is moving
         */
        function onIconMoving():void;

        /**
         * method when icon is stoped
         */
        function onIconStop():void;

    }
}
