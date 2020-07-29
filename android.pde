/*
 * android.pde
 *
 * All android-specific utility methods.
 * To run in Java mode, simply comment out
 * this whole file and anywhere that calls
 * these methods.
 *
 * Created on: January 12, 2020
 *     Author: Sean LaPlante
 */

int SCREEN_ORIENTATION_PORTRAIT = 1;
int FLAG_KEEP_SCREEN_ON = 128;


void androidSetup() {
    /*
     * Utility method used to set the window flag to keep the screen on while
     * in our app and to set the game orientation to be fixed in PORTRAIT mode. 
     * 
     * The 'keep screen on' bit must be done this way to avoid CalledFromWrongThreadException
     * since this flag must be added in the UI thread.
     *
     * This method uses Class.forName(), getMethod(), etc. so that we can seamlessly
     * switch Processing between Android and Java mode without commenting out code.
     */
    Class activity_cls = null;
    Object activity_inst = null;
    Method setRequestedOrientationMethod = null;
    Method runOnUiThreadMethod = null;

    try {
        activity_cls = Class.forName("android.app.Activity");
        runOnUiThreadMethod = activity_cls.getMethod("runOnUiThread", Runnable.class);
        setRequestedOrientationMethod = activity_cls.getMethod("setRequestedOrientation", int.class);
        
        // Fix orientation to PORTRAIT only
        activity_inst = invokeInternalProcessingMethod("getActivity");
        setRequestedOrientationMethod.invoke(activity_inst, SCREEN_ORIENTATION_PORTRAIT);
        
        // Keep the screen on while in the game
        runOnUiThreadMethod.invoke(activity_inst, new Runnable() {
            @Override
            public void run() {
                try {
                    Class window_cls = Class.forName("android.view.Window");
                    Object window_inst = invokeInternalProcessingMethod("getWindow");
                    Method addFlagsMethod = window_cls.getMethod("addFlags", int.class);
                    addFlagsMethod.invoke(window_inst, FLAG_KEEP_SCREEN_ON);
                } catch (Exception e) {
                    println("androidSetup failed to set FLAG_KEEP_SCREEN_ON: ", e);
                    e.printStackTrace();
                }
            }
        });
    } catch (Exception e) {
        println("androidSetup failed: ", e);
        e.printStackTrace();
    }
}
