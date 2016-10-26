package com.samplemvc.api;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.samplemvc.common.Const;
import com.samplemvc.model.MovieEntity;

import java.util.List;

import retrofit.RestAdapter;
import retrofit.converter.GsonConverter;
import retrofit.http.GET;

public class ApiManager {

    private interface ApiService {

        @GET(Const.Movie_ITEMS)
        public List<MovieEntity> getMovieItem();

    }

    // Gson
    private static Gson json = new GsonBuilder()
            .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
            .create();

    // Retrofit
    private static RestAdapter restAdapterMovie = new RestAdapter.Builder()
            .setEndpoint(Const.API_BASE)
            .setConverter(new GsonConverter(json))
            .build();

    public static List<MovieEntity> getMovieItem() {
        ApiService apiService = restAdapterMovie.create(ApiService.class);
        return apiService.getMovieItem(); // API
    }
}
