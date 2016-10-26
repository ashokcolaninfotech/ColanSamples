package com.samplemvc.viewController;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.samplemvc.R;
import com.samplemvc.model.MovieEntity;
import com.squareup.picasso.Picasso;

import java.util.List;


public class ItemListAdapter extends ArrayAdapter<MovieEntity> {

    private Activity mActivity;
    private LayoutInflater mLayoutInflater;
    private int mResource;

    public ItemListAdapter(Context context, int resource, List<MovieEntity> objects) {
        super(context, resource, objects);
        mActivity = (Activity) context;
        mLayoutInflater = LayoutInflater.from(context);
        mResource = resource;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder viewHolder;
        if (convertView != null) {
            viewHolder = (ViewHolder) convertView.getTag();
        } else {
            convertView = mLayoutInflater.inflate(mResource, parent, false);
            viewHolder = new ViewHolder(convertView);
            convertView.setTag(viewHolder);
        }

        MovieEntity itemEntity = getItem(position);

        Picasso.with(mActivity)
                .load(itemEntity.getimage())
                .into(viewHolder.mProfileImageView);
        viewHolder.mTitleTextView.setText(itemEntity.getTitle());

        return convertView;
    }

    static class ViewHolder {
        ImageView mProfileImageView;
        TextView mTitleTextView;

        ViewHolder(View view) {
            mProfileImageView = (ImageView) view.findViewById(R.id.profileImageView);
            mTitleTextView = (TextView) view.findViewById(R.id.titleTextView);
        }
    }
}