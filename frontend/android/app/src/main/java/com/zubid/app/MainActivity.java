package com.zubid.app;

import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        super.onCreate(savedInstanceState);

        // Configure status bar
        configureStatusBar();

        // Keep screen on during auction viewing (optional)
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    private void configureStatusBar() {
        // Set status bar to light icons on dark background
        View decorView = getWindow().getDecorView();
        WindowInsetsControllerCompat insetsController =
            WindowCompat.getInsetsController(getWindow(), decorView);

        if (insetsController != null) {
            // Light status bar (dark icons) - set to false for dark status bar (light icons)
            insetsController.setAppearanceLightStatusBars(false);
            insetsController.setAppearanceLightNavigationBars(true);
        }

        // Set status bar color to orange theme
        getWindow().setStatusBarColor(getResources().getColor(R.color.colorPrimary, getTheme()));

        // Set navigation bar color to white
        getWindow().setNavigationBarColor(getResources().getColor(R.color.white, getTheme()));
    }

    @Override
    public void onResume() {
        super.onResume();
        // Re-apply status bar configuration when app resumes
        configureStatusBar();
    }
}
