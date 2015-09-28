import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import android.util.Log;
import android.provider.Settings;
import android.widget.Toast;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.BitmapFactory;
import android.graphics.Bitmap;
import android.os.Environment;

import java.io.OutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import android.net.Uri;

public class Resize extends CordovaPlugin {
    public static final String TAG = "Cool Plugin";
    /**
    * Constructor.
    */
    public Resize() {}
    /**
    * Sets the context of the Command. This can then be used to do things like
    * get file paths associated with the Activity.
    *
    * @param cordova The context of the main Activity.
    * @param webView The CordovaWebView Cordova is running in.
    */
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        Log.v(TAG,"Init CoolPlugin");
    }

    public boolean execute(final String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        JSONObject obj = args.getJSONObject(0);
        final String uri = obj.getString("uri");
        final int maxDim = obj.getInt("maxDim");

        new Thread() {
            public void run() {
                try {
                BitmapFactory.Options bmOptions = new BitmapFactory.Options();
                bmOptions.inJustDecodeBounds = true;
                getBitmap(uri, bmOptions);
                int photoW = bmOptions.outWidth;
                int photoH = bmOptions.outHeight;
                System.out.println(photoW+" - "+photoH);
                int newW = photoW;
                int newH = photoH;
                if (photoW>photoH && photoW>maxDim) {
                    newW = maxDim;
                    newH = (int)((((float)maxDim)/photoW)*photoH);
                }
                else if (photoH>photoW && photoH>maxDim) {
                    newH = maxDim;
                    newW = (int)((((float)maxDim)/photoH)*photoW);
                }
                System.out.println("final: "+newW+" - "+newH);

                int scaleFactor = 1;
                if ((newW > 0) || (newH > 0)) {
                    scaleFactor = Math.min(photoW/newW, photoH/newH);
                }
                System.out.println("scale: "+scaleFactor);

                bmOptions.inJustDecodeBounds = false;
                bmOptions.inSampleSize = scaleFactor;
                Bitmap bitmap = getBitmap(uri, bmOptions);
                System.out.println("Aperta scalata: "+bmOptions.outWidth+" - "+bmOptions.outHeight);
                final String path = Environment.getExternalStorageDirectory().toString()+"/bikezaa-"+System.currentTimeMillis()+".jpg";
                OutputStream fOut = null;
                File file = new File(path); // the File to save to
                fOut = new FileOutputStream(file);

                bitmap.compress(Bitmap.CompressFormat.JPEG, 85, fOut); // saving the Bitmap to a file compressed as a JPEG with 85% compression rate
                fOut.flush();
                fOut.close(); // do not forget to close the stream
                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        callbackContext.success(path);
                    }
                });
                }
                catch (Exception e) {
                    callbackContext.error(e.toString()+ " "+uri);
                }

            }
        }.start();

        return true;
    }


    private Bitmap getBitmap(String imageUri, BitmapFactory.Options opt) {
        try {
    		Bitmap bmp;
    		InputStream fis = cordova.getActivity().getContentResolver().openInputStream(Uri.parse(imageUri));
    		bmp = BitmapFactory.decodeStream(fis, null, opt);
    		return bmp;
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return null;
	}




}
