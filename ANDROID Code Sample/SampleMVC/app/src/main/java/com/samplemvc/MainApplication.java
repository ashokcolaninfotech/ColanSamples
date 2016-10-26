package com.samplemvc;

import android.app.Application;

import com.samplemvc.common.FragmentRouter;
import com.samplemvc.common.ModeLocator;
import com.samplemvc.model.MovieModel;
import com.samplemvc.viewController.ListFragment;

public class MainApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        // ModelManager
        ModeLocator.register(ModeLocator.Tag.Movie, new MovieModel());

        // FragmentManager
        FragmentRouter.register(FragmentRouter.Tag.LIST, ListFragment.class);

    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }
}
