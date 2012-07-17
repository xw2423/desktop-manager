package
{
    import mx.core.Container;

    /**
     * Interface of DesktopManager
     *
     * @author xw
     */

    public interface IDesktopManager
    {
        function addPlatform(platform:Container):void;
        function removePlatform(platform:Container):void;
    }
}
