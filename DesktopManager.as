package
{

    import mx.core.Container;

    /**
     * DesktopManger manage a container as desktop.
     * The children of container wanted to be managed must implement IDesktopIcon interface
     * The children implemented IDesktopIcon can be selected,dragged as icon in desktop
     *
     * @author xw
     */
    public class DesktopManager {

        //--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------

        /**
         *  @private
         *  Linker dependency on implementation class.
         */
        private static var _impl:IDesktopManager;


        /**
         *  @private
         *  The singleton instance of DesktopManagerImpl
         */
        private static function get impl():IDesktopManager{
            if(!_impl){
                _impl = new DesktopManagerImpl();
            }
            return _impl;
        }

        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------

        /**
         * add a container to the manager
         * @param platform the container to be managed
         */

        public static function addPlatform(platform:Container):void {
            impl.addPlatform(platform);
        }

        /**
         * remove a container from the manager
         * @param platform the container to be removed
         */
        public static function removePlatform(platform:Container):void{
            impl.removePlatform(platform);
        }

    }

}
