package com.cbt.model;

public class User {
    private int userId;
    private String email;
    private String name;
    private String role;
    private String themePreference;
    private double fontScale = 1.0;

    public User() {}

    public User(int userId, String email, String name, String role) {
        this.userId = userId;
        this.email = email;
        this.name = name;
        this.role = role;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getThemePreference() { return themePreference; }
    public void setThemePreference(String themePreference) { this.themePreference = themePreference; }
    public double getFontScale() { return fontScale; }
    public void setFontScale(double fontScale) { this.fontScale = fontScale; }
}
