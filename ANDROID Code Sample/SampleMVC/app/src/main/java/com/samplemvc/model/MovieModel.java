package com.samplemvc.model;

import android.os.AsyncTask;

import com.samplemvc.api.ApiManager;

import java.util.ArrayList;
import java.util.List;

import de.greenrobot.event.EventBus;

/**
 * Created by CIPL0349 on 10/26/2016.
 */

public class MovieModel {

    private final List<MovieEntity> mItemList = new ArrayList<>();
    private int mItemCount = 0;
    private boolean mIsBusy = false;

    public MovieModel() {
    }

    public List<MovieEntity> getItemList() {
        return mItemList;
    }

    public int getItemCount() {
        return mItemCount;
    }

    public void load() {

        if (mIsBusy) {
            return;
        }
        // API
        new AsyncTask<Void, Void, List<MovieEntity>>() {
            @Override
            protected void onPreExecute() {
                super.onPreExecute();
                mIsBusy = true;
            }

            @Override
            protected List<MovieEntity> doInBackground(Void... voids) {
                return ApiManager.getMovieItem();
            }

            @Override
            protected void onPostExecute(List<MovieEntity> result) {
                super.onPostExecute(result);
                mItemList.clear();
                mItemList.addAll(result);
                mItemCount = result.size();
                mIsBusy = false;
                // EventBus
                EventBus.getDefault().post(new MovieModel.ItemLoadedEvent(true));
            }
        }.execute();
    }

    public static class ItemLoadedEvent {
        private boolean isSuccess;

        private ItemLoadedEvent(boolean isSuccess) {
            this.isSuccess = isSuccess;
        }

        public boolean isSuccess() {
            return isSuccess;
        }
    }

}
