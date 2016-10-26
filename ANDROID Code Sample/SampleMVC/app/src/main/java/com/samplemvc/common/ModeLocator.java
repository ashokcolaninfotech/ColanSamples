package com.samplemvc.common;

import java.util.HashMap;
import java.util.Map;

public class ModeLocator {

    public enum Tag {
        Movie
    }

    private static Map<Tag, Object> showcase = new HashMap<>();

    private ModeLocator() {
    }

    public static void register(Tag tag, Object object) {
        showcase.put(tag, object);
    }

    public static Object get(Tag tag) {
        return showcase.get(tag);
    }
}
