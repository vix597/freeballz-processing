/*
 * utils.pde
 *
 * Utility methods
 *
 *  Created on: January 12, 2020
 *      Author: Sean LaPlante
 */
 
/*
import android.app.Activity;
import android.view.WindowManager;  // To access LayoutParams and FLAG_KEEP_SCREEN_ON
*/


//void keepScreenOn() {
    /*
     * Utility method used to set the window flag to keep the screen on while
     * in our app. Must be done this way to avoid CalledFromWrongThreadException
     * since this flag must be added in the UI thread.
     */
/*    
    Activity activity = getActivity();
    
    activity.runOnUiThread(new Runnable() {
        @Override
        public void run() {
            // Prevent screen from going off while in game.
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
    });
}
*/
