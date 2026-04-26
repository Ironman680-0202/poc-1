package com.poc1;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class AppTest {

    @Test
    public void testAdd() {
        assertEquals(20, App.add(10, 10));
    }
}