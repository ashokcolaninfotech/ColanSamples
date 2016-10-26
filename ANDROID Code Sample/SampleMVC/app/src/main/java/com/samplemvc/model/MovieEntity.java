package com.samplemvc.model;

import java.util.ArrayList;

/**
 * Created by CIPL0349 on 10/26/2016.
 */

public class MovieEntity {

    private String title, image;
    private int year;
    private double rating;
    private ArrayList<String> genre;

    public MovieEntity() {
    }

    public MovieEntity(String name, String image, int year, double rating,
                       ArrayList<String> genre) {
        this.title = name;
        this.image = image;
        this.year = year;
        this.rating = rating;
        this.genre = genre;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String name) {
        this.title = name;
    }

    public String getimage() {
        return image;
    }

    public void setimage(String image) {
        this.image = image;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public ArrayList<String> getGenre() {
        return genre;
    }

    public void setGenre(ArrayList<String> genre) {
        this.genre = genre;
    }

}
