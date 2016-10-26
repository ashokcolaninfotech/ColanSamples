package com.samplemvc.viewController;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.TextView;

import com.samplemvc.common.ModeLocator;
import com.samplemvc.R;
import com.samplemvc.model.MovieEntity;
import com.samplemvc.model.MovieModel;

import java.util.ArrayList;
import java.util.List;

import de.greenrobot.event.EventBus;

public class ListFragment extends Fragment {

    TextView mItemCountTextView;
    ListView mItemListView;

    private final List<MovieEntity> mItemList = new ArrayList<>();
    private ItemListAdapter mItemListAdapter;

    public ListFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_list, container, false);
        mItemCountTextView = (TextView) view.findViewById(R.id.itemCountTextView);
        mItemListView = (ListView) view.findViewById(R.id.ItemListView);

        return view;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mItemListAdapter = new ItemListAdapter(
                getActivity(),
                R.layout.adapter_item_list,
                mItemList
        );
        mItemListView.setAdapter(mItemListAdapter);
    }

    @Override
    public void onStart() {
        super.onStart();
        ((MovieModel) ModeLocator.get(ModeLocator.Tag.Movie)).load();
        updateView();
    }

    @Override
    public void onResume() {
        super.onResume();
        EventBus.getDefault().register(this); // EventBus
    }

    @Override
    public void onPause() {
        super.onPause();
        EventBus.getDefault().unregister(this); // EventBus
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }

    // EventBus
    @SuppressWarnings("unused")
    public void onEventMainThread(MovieModel.ItemLoadedEvent event) {
        if (event.isSuccess()) {
            updateView();
        }
    }

    // View
    private void updateView() {
        mItemCountTextView.setText(((MovieModel) ModeLocator.get(ModeLocator.Tag.Movie)).getItemCount() + " items");
        mItemList.clear();
        mItemList.addAll(((MovieModel) ModeLocator.get(ModeLocator.Tag.Movie)).getItemList());
        mItemListAdapter.notifyDataSetChanged();
    }
}
