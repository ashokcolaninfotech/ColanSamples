package com.samplemvc;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.view.KeyEvent;
import android.webkit.WebView;

import com.samplemvc.common.FragmentRouter;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            FragmentRouter.replace(getSupportFragmentManager(), R.id.container, FragmentRouter.Tag.LIST, null, FragmentRouter.Animation.NON, false);
        }
    }
}
